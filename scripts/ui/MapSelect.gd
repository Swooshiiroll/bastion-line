extends Node
## Sector selection: a mode picker plus a card per sector with a mini-map, blurb, its row of five
## medals (one per mode) and your record on the selected mode.

const UiKit = preload("res://scripts/ui/UiKit.gd")
const DrawControl = preload("res://scripts/ui/DrawControl.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const Grid = preload("res://scripts/core/Grid.gd")
const Terrain = preload("res://scripts/view/Terrain.gd")
const Maps = preload("res://data/maps.gd")
const Difficulty = preload("res://data/difficulty.gd")
const Research = preload("res://scripts/core/Research.gd")
const Game = preload("res://scripts/core/Game.gd")

var app
var _layer: CanvasLayer
var _grids := {}
## Sandbox toggle (design/sandbox.md): kept while this screen is open, off by default.
var sandbox := false


func _ready() -> void:
	_layer = CanvasLayer.new()
	add_child(_layer)
	for id in Maps.ORDER:
		_grids[id] = Grid.new(id)
	_build()


func _build() -> void:
	for c in _layer.get_children():
		_layer.remove_child(c)
		c.queue_free()
	var diff := Difficulty.resolve(str(SaveManager.setting("difficulty")))
	if diff == "":
		diff = "medium"
	var root := UiKit.root()
	_layer.add_child(root)
	root.add_child(UiKit.starfield())

	var title := UiKit.label("SELECT SECTOR", 40, UiKit.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_constant_override("outline_size", 10)
	title.position = Vector2(0, 40)
	title.size = Vector2(1600, 56)
	root.add_child(title)

	var row := UiKit.hbox(8)
	row.position = Vector2(0, 104)
	row.size = Vector2(1600, 38)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(row)
	for d in Difficulty.ORDER:
		var dd: Dictionary = Difficulty.DIFFICULTIES[d]
		var b := UiKit.button(dd.name, _set_difficulty.bind(d), Vector2(160, 36), true)
		b.tooltip_text = dd.blurb
		if d == diff:
			var sel := UiKit.box(Color(0.2, 0.22, 0.2), dd.color, 6, 2)
			for s in ["normal", "hover", "pressed", "focus"]:
				b.add_theme_stylebox_override(s, sel)
			b.add_theme_color_override("font_color", dd.color)
			b.add_theme_color_override("font_focus_color", dd.color)
		row.add_child(b)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(24, 0)
	row.add_child(gap)
	var sb := UiKit.button("Sandbox: On" if sandbox else "Sandbox: Off", _toggle_sandbox, Vector2(160, 36), true)
	sb.tooltip_text = "A test bench: infinite credits and shields, free upgrades, spawn any enemy or round. Nothing is saved or earned."
	if sandbox:
		var on := UiKit.box(Color(0.2, 0.22, 0.2), UiKit.GOLD, 6, 2)
		for s in ["normal", "hover", "pressed", "focus"]:
			sb.add_theme_stylebox_override(s, on)
		sb.add_theme_color_override("font_color", UiKit.GOLD)
		sb.add_theme_color_override("font_focus_color", UiKit.GOLD)
	row.add_child(sb)
	var rm := Research.run_mods(SaveManager.research_owned())
	var gold := int(round(float(Game.START_GOLD) * (1.0 + float(rm.start_gold))))
	var blurb := UiKit.label("%s  Starting credits: %d on every sector." % [Difficulty.DIFFICULTIES[diff].blurb, gold], 14, UiKit.DIM, HORIZONTAL_ALIGNMENT_CENTER)
	blurb.position = Vector2(0, 148)
	blurb.size = Vector2(1600, 20)
	root.add_child(blurb)

	var first: Button = null
	for i in Maps.ORDER.size():
		var id: String = Maps.ORDER[i]
		var b := _card(root, id, diff, Vector2(36 + (i % 3) * 516, 200 + (i / 3) * 280))
		if first == null:
			first = b
	var back := UiKit.button("Back", func(): app.show_menu(), Vector2(140, 42), true)
	back.position = Vector2(40, 836)
	root.add_child(back)
	var total := UiKit.label("Medals: %d / %d" % [SaveManager.total_medals(), Maps.ORDER.size() * Difficulty.ORDER.size()], 15, UiKit.GOLD, HORIZONTAL_ALIGNMENT_RIGHT)
	total.position = Vector2(1120, 846)
	total.size = Vector2(440, 24)
	root.add_child(total)
	first.grab_focus.call_deferred()


func _set_difficulty(d: String) -> void:
	SaveManager.set_setting("difficulty", d)
	_build.call_deferred()


func _toggle_sandbox() -> void:
	sandbox = not sandbox
	_build.call_deferred()


func _card(root: Control, id: String, diff: String, at: Vector2) -> Button:
	var m: Dictionary = Maps.MAPS[id]
	var card := UiKit.panel(Rect2(at, Vector2(496, 260)), UiKit.BG, 10)
	root.add_child(card)
	var grid = _grids[id]
	var mini := DrawControl.new(func(ci): _draw_mini(ci, grid, m.theme), Vector2(256, 128))
	mini.position = Vector2(12, 12)
	card.add_child(mini)

	var col := UiKit.vbox(2)
	col.position = Vector2(284, 10)
	col.size = Vector2(200, 134)
	var name_l := UiKit.label(m.name, 22)
	name_l.clip_text = true
	name_l.custom_minimum_size = Vector2(200, 0)
	col.add_child(name_l)
	var dd: Dictionary = Difficulty.DIFFICULTIES[diff]
	col.add_child(UiKit.label("%d warp gate%s" % [grid.groups.size(), "" if grid.groups.size() == 1 else "s"], 12, UiKit.DIM))
	for f in _features(grid):
		col.add_child(UiKit.label(f[0], 11, f[1]))
	card.add_child(col)

	var blurb := UiKit.label(m.blurb, 13, UiKit.DIM)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.position = Vector2(14, 152)
	blurb.size = Vector2(468, 60)
	card.add_child(blurb)

	# One medal per mode; the selected mode's medal is ringed.
	for k in Difficulty.ORDER.size():
		var mode: String = Difficulty.ORDER[k]
		var mrec: Dictionary = SaveManager.map_record(id, mode)
		var earned: bool = mrec.medal
		var selected := mode == diff
		var md := DrawControl.new(func(ci):
			if selected:
				ci.draw_arc(ci.size / 2.0 - Vector2(0, 3), 15.5, 0.0, TAU, 28, Color(dd.color, 0.8), 1.5, true)
			Draw.medal(ci, ci.size / 2.0 - Vector2(0, 3), 11.0, mode, earned, Time.get_ticks_msec() / 1000.0)
		, Vector2(34, 40), earned)
		md.position = Vector2(10 + k * 34, 212)
		md.mouse_filter = Control.MOUSE_FILTER_PASS
		var mname := str(Difficulty.DIFFICULTIES[mode].name)
		md.tooltip_text = ("%s medal earned" % mname) if earned else ("%s: best round %d / %d" % [mname, int(mrec.best_wave), Difficulty.rounds(mode)] if int(mrec.best_wave) > 0 else "%s: not played yet" % mname)
		card.add_child(md)
	var rec: Dictionary = SaveManager.map_record(id, diff)
	var rec_text := "Not played on %s" % dd.name
	var rec_color := UiKit.DIM
	if rec.medal:
		rec_text = "%s medal" % dd.name + ("  ·  endless round %d" % int(rec.best_endless) if int(rec.best_endless) > 0 else "")
		rec_color = dd.color
	elif int(rec.best_wave) > 0:
		rec_text = "Best: round %d / %d" % [int(rec.best_wave), Difficulty.rounds(diff)]
		rec_color = UiKit.TEXT
	var rec_l := UiKit.label(rec_text, 12, rec_color)
	rec_l.position = Vector2(186, 226)
	card.add_child(rec_l)

	var play := UiKit.button("Deploy", func(): app.start_game(id, diff, sandbox), Vector2(118, 34), true)
	play.position = Vector2(366, 216)
	play.size = Vector2(118, 34)
	card.add_child(play)
	return play


## Short feature tags for a sector card: forks, hazards and special tiles.
static func _features(grid) -> Array:
	var out: Array = []
	var forks := 0
	for g in grid.groups:
		if g.fork != null:
			forks += 1
	if forks > 0:
		out.append(["%d switch gate%s" % [forks, "" if forks == 1 else "s"], UiKit.GOLD])
	var hz := {}
	for c in grid.hazards:
		hz[grid.hazards[c]] = true
	var parts: Array = []
	if hz.has("sludge"):
		parts.append("sludge")
	if hz.has("shock"):
		parts.append("shock strips")
	if not parts.is_empty():
		out.append([" + ".join(PackedStringArray(parts)).capitalize(), Color(0.55, 0.95, 0.7)])
	return out


func _draw_mini(ci: Control, grid, theme_name: String) -> void:
	var pal := Terrain.palette(theme_name)
	var s: float = ci.size.x / Grid.field_size().x
	var t := Grid.TILE * s
	ci.draw_rect(Rect2(Vector2.ZERO, ci.size), pal.a)
	for y in Grid.ROWS:
		for x in Grid.COLS:
			var c := Vector2i(x, y)
			var r := Rect2(Vector2(c) * t, Vector2(t, t))
			match grid.tile_at(c):
				".":
					if (x + y) % 2 == 0:
						ci.draw_rect(r, Color(pal.b, 0.6))
				"#":
					ci.draw_rect(r.grow(-1.0), pal.detail)
				"H":
					ci.draw_rect(r.grow(-1.0), Color(0.45, 0.7, 0.9, 0.75))
				"P":
					ci.draw_rect(r.grow(-1.5), Color(1.0, 0.78, 0.3, 0.9))
				"R":
					ci.draw_rect(r.grow(-1.5), Color(0.6, 0.45, 0.3, 0.8))
	for curve in grid.ground_paths:
		var pts := PackedVector2Array()
		for p in Terrain.lane_points(curve):
			pts.append(p * s)
		ci.draw_polyline(pts, Color(pal.edge, 0.55), t * 0.95, true)
		ci.draw_polyline(pts, pal.lane, t * 0.75, true)
	for c in grid.hazards:
		var col := Color(0.35, 0.95, 0.6, 0.8) if grid.hazards[c] == "sludge" else Color(1.0, 0.9, 0.3, 0.85)
		ci.draw_circle(Grid.cell_center(c) * s, t * 0.22, col)
	for g in grid.groups:
		var pts: Array = grid.waypoints[g.routes[0]]
		var gp: Vector2 = Terrain.gate_pos(pts) * s
		gp = gp.clamp(Vector2(t * 0.45, t * 0.45), ci.size - Vector2(t * 0.45, t * 0.45))
		ci.draw_circle(gp, t * 0.45, Color(0.85, 0.2, 0.35))
		if g.fork != null:
			ci.draw_rect(Rect2(Vector2(g.fork) * t, Vector2(t, t)).grow(-1.0), Color(1.0, 0.8, 0.3), false, 1.5)
		for i in grid.air_paths.size():
			if grid.route_group[i] != grid.groups.find(g):
				continue
			var a: Vector2 = grid.air_paths[i].get_point_position(0) * s
			var b: Vector2 = grid.air_paths[i].get_point_position(1) * s
			var n := int(a.distance_to(b) / 8.0)
			for k in n:
				if k % 2 == 0:
					ci.draw_line(a.lerp(b, float(k) / n), a.lerp(b, float(k + 1) / n), Color(0.75, 0.55, 1.0, 0.35), 1.0)
	ci.draw_circle(Terrain.core_pos(grid.waypoints[0]) * s, t * 0.45, Color(0.35, 0.55, 1.0))
	ci.draw_rect(Rect2(Vector2.ZERO, ci.size), Color(0, 0, 0, 0.6), false, 2.0)
