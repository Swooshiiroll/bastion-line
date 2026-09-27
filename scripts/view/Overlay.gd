extends Node2D
## Interaction overlay: buildable-tile grid, placement preview with range, selection and hover rings.

const Grid = preload("res://scripts/core/Grid.gd")
const Game = preload("res://scripts/core/Game.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const Towers = preload("res://data/towers.gd")
const DrawNode = preload("res://scripts/view/DrawNode.gd")
const Abilities = preload("res://data/abilities.gd")
const Tower = preload("res://scripts/entities/Tower.gd")

const OK_COLOR := Color(0.35, 0.95, 0.45)
const BAD_COLOR := Color(1.0, 0.35, 0.3)
const SELECT_COLOR := Color(0.98, 0.82, 0.4)

var world
var _ghost: Node2D


func _ready() -> void:
	_ghost = DrawNode.new()
	_ghost.modulate = Color(1, 1, 1, 0.6)
	_ghost.draw_fn = _draw_ghost
	add_child(_ghost)


func refresh() -> void:
	queue_redraw()
	_ghost.queue_redraw()


func _draw() -> void:
	var g = world.game
	if g == null or not world.interactive:
		return
	var build: String = world.build_type
	if world.ability_target == "meteor" and world.mouse_in_field:
		_meteor_reticle(g, world.hover_pos)
	if build != "":
		for y in Grid.ROWS:
			for x in Grid.COLS:
				var c := Vector2i(x, y)
				if g.tower_at.has(c):
					continue
				if g.is_buildable(c):
					var tile: String = g.grid.tile_at(c)
					var tint := Color(1, 1, 1, 0.06)
					if tile == "H":
						tint = Color(0.5, 0.8, 1.0, 0.16)
					elif tile == "P":
						tint = Color(1.0, 0.78, 0.3, 0.16)
					draw_rect(Grid.cell_rect(c).grow(-2.0), tint)
				elif g.has_rubble(c):
					draw_rect(Grid.cell_rect(c).grow(-2.0), Color(1.0, 0.5, 0.25, 0.08))
		if world.mouse_in_field:
			var cell: Vector2i = world.build_anchor()
			var ok: bool = g.placement_error(build, cell) == ""
			var col := OK_COLOR if ok else BAD_COLOR
			var site: String = g.footprint_site(build, cell)
			var ctr := Game.footprint_center(build, cell)
			var r: float = float(g.level_stats(build, 1).get("range", 0.0))
			if site == "H":
				r *= 1.0 + Tower.SITE_RANGE
			_range(ctr, r, col)
			draw_rect(_footprint_rect(build, cell).grow(-1.0), Color(col, 0.9), false, 2.0)
			if Game.footprint(build, cell).any(func(c): return g.has_rubble(c)):
				_tag(ctr + Vector2(0, -30.0 * Game.size_of(build)), "clear first: %d cr" % g.rubble_cost(), BAD_COLOR)
			elif ok and site != "":
				_tag(ctr + Vector2(0, -30.0 * Game.size_of(build)), "+15% range" if site == "H" else "+15% damage", Color(1.0, 0.85, 0.4))
	var sel = world.selected_tower
	if sel != null:
		_range(sel.pos, _reach(sel), SELECT_COLOR)
		draw_rect(_footprint_rect(sel.type, sel.cell).grow(-1.0), Color(SELECT_COLOR, 0.9), false, 2.0)
	elif build == "" and world.mouse_in_field:
		var hc: Vector2i = world.hover_cell
		if g.tower_at.has(hc):
			var ht = g.tower_at[hc]
			_range(ht.pos, _reach(ht), Color(1, 1, 1))
		elif g.has_rubble(hc):
			var can: bool = g.rubble_error(hc) == ""
			draw_rect(Grid.cell_rect(hc).grow(-1.0), Color(1.0, 0.6, 0.3, 0.9), false, 2.0)
			_tag(Grid.cell_center(hc) + Vector2(0, -30), "click: clear %d cr" % g.rubble_cost(), Color(1.0, 0.85, 0.4) if can else BAD_COLOR)
		elif g.grid.gate_group_at(hc) >= 0:
			var gi: int = g.grid.gate_group_at(hc)
			var cd := float(g.gate_cd[gi])
			_tag(Grid.cell_center(hc) + Vector2(0, -32), "gate: %s  (%s)" % [g.gate_label(gi), "click to switch" if cd <= 0.0 else "%.0fs" % ceilf(cd)], Color(1.0, 0.85, 0.4))
		elif g.is_buildable(hc):
			draw_rect(Grid.cell_rect(hc).grow(-2.0), Color(1, 1, 1, 0.08))
	var he = world.hover_enemy
	if he != null and he.alive:
		draw_arc(he.pos, he.radius + 5.0, 0.0, TAU, 32, Color(1, 1, 1, 0.85), 1.5, true)


func _meteor_reticle(g, p: Vector2) -> void:
	var r: float = Abilities.ABILITIES.meteor.radius
	var pulse := 0.5 + 0.5 * sin(world.anim_t * 8.0)
	draw_circle(p, r, Color(1.0, 0.4, 0.15, 0.10 + 0.05 * pulse))
	draw_arc(p, r, 0.0, TAU, 64, Color(1.0, 0.55, 0.25, 0.95), 2.5, true)
	draw_arc(p, r * 0.55, 0.0, TAU, 40, Color(1.0, 0.7, 0.35, 0.5), 1.5, true)
	for a in 4:
		var d := Vector2.from_angle(a * PI / 2.0 + PI / 4.0)
		draw_line(p + d * (r - 12.0), p + d * (r + 8.0), Color(1.0, 0.6, 0.3), 2.5, true)
	for e in g.enemies:
		if e.alive and e.pos.distance_squared_to(p) <= r * r:
			draw_arc(e.pos, e.radius + 4.0, 0.0, TAU, 24, Color(1.0, 0.5, 0.2, 0.9), 2.0, true)


## A small label with a dark backing, centred on `p`.
func _tag(p: Vector2, text: String, col: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
	var r := Rect2(p - Vector2(w / 2.0 + 6.0, 11.0), Vector2(w + 12.0, 18.0))
	var size := Grid.field_size()
	r.position.x = clampf(r.position.x, 2.0, size.x - r.size.x - 2.0)
	r.position.y = maxf(r.position.y, 2.0)
	draw_rect(r, Color(0.02, 0.03, 0.05, 0.85))
	draw_rect(r, Color(col, 0.6), false, 1.0)
	draw_string(font, r.position + Vector2(6.0, 13.5), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, col)


## A tower's reach for its ring; 0 (no ring) for towers that reach the whole map.
func _reach(t) -> float:
	return t.get_range() if t.stats().has("range") else 0.0


func _range(center: Vector2, r: float, col: Color) -> void:
	if r <= 0.0:
		return
	draw_circle(center, r, Color(col, 0.09))
	draw_arc(center, r, 0.0, TAU, 72, Color(col, 0.75), 2.0, true)


## The rectangle a tower of `type` at `anchor` covers.
static func _footprint_rect(type: String, anchor: Vector2i) -> Rect2:
	return Rect2(Grid.cell_rect(anchor).position, Vector2.ONE * Grid.TILE * float(Game.size_of(type)))


## Drawing scale for a tower of `size` tiles per side.
static func tower_scale(size: int) -> float:
	return 1.0 if size <= 1 else 1.8


func _draw_ghost(ci: CanvasItem) -> void:
	if world.interactive and world.build_type != "" and world.mouse_in_field:
		var a: Vector2i = world.build_anchor()
		Draw.tower(ci, world.build_type, 1, Game.footprint_center(world.build_type, a), -PI / 2.0, tower_scale(Game.size_of(world.build_type)), world.anim_t, 0.0)
