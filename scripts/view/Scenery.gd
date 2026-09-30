extends Node2D
## Animated scenery drawn every frame over the static terrain: pulsing power nodes, bubbling
## sludge, crackling shock strips, the switch gates (open branches lit, cooldown ring) and a
## little per-theme ambience (beacons, rift glow, ice fog, reactor pulses, foundry sparks, the
## singularity's distortion). Kept to a few hundred primitives.

const Grid = preload("res://scripts/core/Grid.gd")
const Terrain = preload("res://scripts/view/Terrain.gd")
const Draw = preload("res://scripts/view/Draw.gd")

const GOLD := Color(1.0, 0.78, 0.3)

var world
var grid
var _power: Array = []
## Per hazard cell: [cell, lane point, lane direction] (see Terrain.lane_frame).
var _sludge: Array = []
var _shock: Array = []
var _props: Array = []
var _glow_cells: Array = []
## Per gate: [group index, fork cell, [direction per route]].
var _gates: Array = []
var _theme := ""
var _edge := Color.WHITE


func _ready() -> void:
	grid = world.game.grid
	_theme = grid.def.theme
	_edge = Terrain.palette(_theme).edge
	for c in grid.tiles:
		match grid.tiles[c]:
			"P":
				_power.append(c)
			"#":
				_props.append(c)
	for c in grid.hazards:
		var frame := Terrain.lane_frame(grid, c)
		(_sludge if grid.hazards[c] == "sludge" else _shock).append([c, frame[0], frame[1]])
	for y in Grid.ROWS:
		for x in Grid.COLS:
			var c := Vector2i(x, y)
			if grid.tile_at(c) == "." and Terrain.hash01(x, y, 17) > 0.9:
				_glow_cells.append(c)
	for gi in grid.groups.size():
		var group: Dictionary = grid.groups[gi]
		if group.fork == null:
			continue
		var dirs: Array = []
		for r in group.routes:
			var pts: Array = grid.waypoints[r]
			var i := pts.find(group.fork)
			var d: Vector2i = pts[i + 1] - pts[i]
			dirs.append(Vector2(signi(d.x), signi(d.y)))
		_gates.append([gi, group.fork, dirs])


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var t: float = world.anim_t
	_ambience(t)
	for c in _power:
		var ctr := Grid.cell_center(c)
		var p := 0.5 + 0.5 * sin(t * 2.6 + float(c.x))
		Draw.disc(self, ctr, 10.0 + 3.0 * p, Color(GOLD, 0.10 + 0.08 * p))
		Draw.glow_dot(self, ctr, 3.0 + p, Color(GOLD, 0.9))
	for h in _sludge:
		var c: Vector2i = h[0]
		var ctr: Vector2 = h[1]
		var dir: Vector2 = h[2]
		for k in 3:
			var ph := fmod(t * 0.6 + Terrain.hash01(c.x, c.y, k), 1.0)
			var p := ctr + dir * (Terrain.hash01(c.x, c.y, 30 + k) * 26.0 - 13.0) + dir.orthogonal() * (Terrain.hash01(c.x, c.y, 40 + k) * 20.0 - 10.0)
			Draw.arc(self, p, 1.5 + 4.0 * ph, 0.0, TAU, 10, Color(Terrain.SLUDGE, 0.5 * (1.0 - ph)), 1.2, true)
	for h in _shock:
		var c: Vector2i = h[0]
		var ctr: Vector2 = h[1]
		var dir: Vector2 = h[2]
		var slot := int(t * 9.0 + float(c.x * 3 + c.y * 7))
		if slot % 4 != 0:
			continue
		var pts := PackedVector2Array()
		for k in 5:
			var f := float(k) / 4.0
			var jitter := (Terrain.hash01(slot, c.x * 31 + c.y, k) - 0.5) * 16.0
			pts.append(ctr + dir * (-20.0 + 40.0 * f) + dir.orthogonal() * jitter)
		Draw.polyline(self, pts, Color(Terrain.SHOCK, 0.8), 1.6, true)
	for g in _gates:
		_gate(g, t)


## A switch gate: a housing on the fork tile with one arrow per branch, lit when that branch is
## open, dimmed and crossed when closed, and a ring showing the cooldown.
func _gate(g: Array, t: float) -> void:
	var gi: int = g[0]
	var ctr := Grid.cell_center(g[1])
	var game = world.game
	var st := int(game.gates[gi])
	var cd := float(game.gate_cd[gi])
	var hover: bool = world.interactive and world.mouse_in_field and world.hover_cell == g[1] and world.build_type == ""
	Draw.fill(self, ctr, Draw.ngon(8, 1.0, PI / 8.0), Color(0.04, 0.05, 0.07, 0.92), 0.0, 17.0)
	Draw.outline(self, ctr, Draw.ngon(8, 1.0, PI / 8.0), Color(GOLD, 0.95 if hover else 0.7), 2.0 if hover else 1.5, 0.0, 17.0)
	var dirs: Array = g[2]
	for k in dirs.size():
		var d: Vector2 = dirs[k]
		var open := st == 0 or st == k + 1
		var col := Color(GOLD, 0.95) if open else Color(0.55, 0.2, 0.2, 0.8)
		var tip := ctr + d * 13.0
		var base := ctr + d * 3.0
		var n := d.orthogonal()
		draw_line(base, tip, col, 2.5, true)
		Draw.polyline(self, PackedVector2Array([tip - d * 5.0 + n * 4.0, tip, tip - d * 5.0 - n * 4.0]), col, 2.0, true)
		if not open:
			var x := ctr + d * 20.0
			draw_line(x + Vector2(-3, -3), x + Vector2(3, 3), col, 1.6)
			draw_line(x + Vector2(-3, 3), x + Vector2(3, -3), col, 1.6)
	Draw.disc(self, ctr, 3.0, Color(GOLD, 0.6 + 0.3 * sin(t * 4.0)))
	if cd > 0.0:
		var f := cd / 6.0
		Draw.arc(self, ctr, 21.0, -PI / 2.0, -PI / 2.0 + TAU * f, 24, Color(0.9, 0.9, 1.0, 0.7), 2.0, true)


func _ambience(t: float) -> void:
	match _theme:
		"meadow":
			for c in _props:
				if Terrain.hash01(c.x, c.y, 7) <= 0.5:
					var on := fmod(t * 0.7 + Terrain.hash01(c.x, c.y, 8) * 3.0, 2.0) < 0.25
					if on:
						Draw.glow_dot(self, Grid.cell_center(c) + Vector2(0, -16), 2.6, _edge)
		"canyon":
			for c in _glow_cells:
				var p := 0.5 + 0.5 * sin(t * 1.3 + Terrain.hash01(c.x, c.y, 3) * 6.0)
				var ctr := Grid.cell_center(c)
				draw_line(ctr + Vector2(-12, -6), ctr + Vector2(4, 2), Color(1.0, 0.45, 0.15, 0.25 * p), 2.0)
				draw_line(ctr + Vector2(4, 2), ctr + Vector2(12, -2), Color(1.0, 0.45, 0.15, 0.2 * p), 1.5)
		"delta":
			var size := Grid.field_size()
			for k in 14:
				var x := fmod(Terrain.hash01(k, 1, 91) * size.x + t * (8.0 + 6.0 * Terrain.hash01(k, 2, 91)), size.x + 160.0) - 80.0
				var y := Terrain.hash01(k, 3, 91) * size.y + sin(t * 0.4 + float(k)) * 12.0
				Draw.disc(self, Vector2(x, y), 34.0 + 20.0 * Terrain.hash01(k, 4, 91), Color(0.75, 0.9, 1.0, 0.035))
		"crossroads":
			for c in _props:
				var ph := fmod(t * 0.5 + Terrain.hash01(c.x, c.y, 9), 1.0)
				Draw.arc(self, Grid.cell_center(c), 10.0 + 14.0 * ph, 0.0, TAU, 20, Color(_edge, 0.3 * (1.0 - ph)), 1.2, true)
		"foundry":
			for c in _props:
				var slot := int(t * 6.0 + Terrain.hash01(c.x, c.y, 5) * 10.0)
				if slot % 5 == 0:
					var ctr := Grid.cell_center(c)
					for k in 3:
						var a := -PI / 2.0 + (Terrain.hash01(slot, c.x + k, 2) - 0.5) * 1.8
						var d := 6.0 + 10.0 * Terrain.hash01(slot, c.y + k, 4)
						Draw.disc(self, ctr + Vector2(8, -12) + Vector2.from_angle(a) * d, 1.2, Color(1.0, 0.75, 0.3, 0.9))
		"singularity":
			var core := Terrain.core_pos(grid.waypoints[0])
			for k in 3:
				var r := 36.0 + 14.0 * float(k) + 4.0 * sin(t * 1.5 + float(k))
				Draw.arc_segments(self, core, r, 5, 0.7, t * (0.3 + 0.15 * float(k)) * (1.0 if k % 2 == 0 else -1.0), Color(_edge, 0.18 - 0.04 * float(k)), 1.5)
			for c in _props:
				var p := 0.5 + 0.5 * sin(t * 1.8 + Terrain.hash01(c.x, c.y, 6) * 6.0)
				Draw.glow_dot(self, Grid.cell_center(c) + Vector2(0, -18), 1.5 + p, Color(_edge, 0.5 + 0.4 * p))
