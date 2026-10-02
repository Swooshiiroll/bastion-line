extends Node2D
## Static battlefield art, drawn once: floor plating per theme, special tiles (high ground, power
## node sockets, rubble), wall props, smooth rounded lanes along the route curves (with sludge and
## shock-strip bases), warp gates and the station core. Animated parts live in Scenery and LaneFx.

const Grid = preload("res://scripts/core/Grid.gd")
const Draw = preload("res://scripts/view/Draw.gd")

## a/b: floor plate shades, seam: plate seams, lane: lane floor, edge: glowing lane rim,
## detail: small floor details, prop: decoration style for wall tiles, floor: plates | rock | ice.
const PALETTES := {
	"meadow": {
		"a": Color(0.13, 0.17, 0.19), "b": Color(0.15, 0.19, 0.21), "seam": Color(0.07, 0.09, 0.11),
		"lane": Color(0.05, 0.07, 0.09), "edge": Color(0.20, 0.80, 1.00), "detail": Color(0.24, 0.30, 0.33),
		"prop": "crates", "floor": "plates",
	},
	"canyon": {
		"a": Color(0.29, 0.13, 0.10), "b": Color(0.33, 0.16, 0.12), "seam": Color(0.19, 0.08, 0.06),
		"lane": Color(0.10, 0.10, 0.12), "edge": Color(1.00, 0.55, 0.20), "detail": Color(0.40, 0.20, 0.15),
		"prop": "crystals", "floor": "rock",
	},
	"delta": {
		"a": Color(0.16, 0.21, 0.26), "b": Color(0.19, 0.25, 0.30), "seam": Color(0.10, 0.13, 0.17),
		"lane": Color(0.05, 0.08, 0.11), "edge": Color(0.55, 0.90, 1.00), "detail": Color(0.33, 0.43, 0.50),
		"prop": "ice", "floor": "ice",
	},
	"crossroads": {
		"a": Color(0.10, 0.10, 0.18), "b": Color(0.12, 0.12, 0.21), "seam": Color(0.05, 0.05, 0.10),
		"lane": Color(0.04, 0.03, 0.08), "edge": Color(1.00, 0.35, 0.85), "detail": Color(0.20, 0.20, 0.32),
		"prop": "reactors", "floor": "plates",
	},
	"foundry": {
		"a": Color(0.17, 0.14, 0.11), "b": Color(0.20, 0.16, 0.12), "seam": Color(0.09, 0.07, 0.05),
		"lane": Color(0.07, 0.06, 0.05), "edge": Color(1.00, 0.72, 0.25), "detail": Color(0.32, 0.26, 0.19),
		"prop": "machines", "floor": "plates",
	},
	"singularity": {
		"a": Color(0.08, 0.06, 0.13), "b": Color(0.10, 0.08, 0.16), "seam": Color(0.04, 0.03, 0.07),
		"lane": Color(0.03, 0.02, 0.06), "edge": Color(0.70, 0.45, 1.00), "detail": Color(0.20, 0.16, 0.30),
		"prop": "obelisks", "floor": "plates",
	},
}
const LANE_W := 40.0
## How far the decorated surroundings extend past the playable grid (tiles), so the battlefield
## runs to the window edges instead of stopping, even on ultrawide (up to 32:9) or tall (4:3) windows.
const MARGIN_COLS := 18
const MARGIN_ROWS := 10
const SLUDGE := Color(0.30, 0.85, 0.50)
const SHOCK := Color(1.0, 0.88, 0.30)

var grid
## Rubble cells the player has cleared (the game's own `cleared` dictionary), drawn as open floor.
var cleared := {}
## Only draw the tiles in this cell rectangle (the upgrade preview shows a small part of a map).
## Empty: draw everything.
var clip := Rect2i()


static func palette(theme_name: String) -> Dictionary:
	return PALETTES.get(theme_name, PALETTES.meadow)


static func hash01(x: int, y: int, salt: int) -> float:
	var h := (x * 374761393 + y * 668265263 + salt * 982451653) & 0x7fffffff
	h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
	return float(h % 10000) / 10000.0


## A route's baked points clamped to the field, so lanes stop at the field's edge.
static func lane_points(curve: Curve2D) -> PackedVector2Array:
	var size := Grid.field_size()
	var out := PackedVector2Array()
	for p in curve.get_baked_points():
		out.append(Vector2(clampf(p.x, 0.0, size.x), clampf(p.y, 0.0, size.y)))
	return out


## A route's lane extended straight out past both ends to the edge of the surroundings, for
## drawing (enemies still spawn at the route's first point, where the warp gate stands).
static func extended_lane_points(curve: Curve2D) -> PackedVector2Array:
	var pts := curve.get_baked_points()
	if pts.size() < 2:
		return pts
	var reach := float(MARGIN_COLS + 1) * Grid.TILE
	var d0 := (pts[1] - pts[0]).normalized()
	var d1 := (pts[pts.size() - 1] - pts[pts.size() - 2]).normalized()
	var out := PackedVector2Array([pts[0] - d0 * reach])
	out.append_array(pts)
	out.append(pts[pts.size() - 1] + d1 * reach)
	return out


## Where a group's warp gate sits (where its enemies spawn, just outside the grid) and the core
## (just before the exit).
static func gate_pos(pts: Array) -> Vector2:
	return Grid.cell_center(pts[0])


static func core_pos(pts: Array) -> Vector2:
	var e1 := Grid.cell_center(pts[pts.size() - 1])
	var e0 := Grid.cell_center(pts[pts.size() - 2])
	return e1 - (e1 - e0).normalized() * (Grid.TILE * 0.5 + 16.0)


func _draw() -> void:
	var pal := palette(grid.def.theme)
	var field := Rect2(Vector2.ZERO, Grid.field_size())
	# Surroundings: the deck continues past the playable grid to the screen edges (and under the
	# bars), so the battlefield never just stops. Nothing can be built out here.
	var margin_lanes := _margin_lane_cells()
	for y in range(-MARGIN_ROWS, Grid.ROWS + MARGIN_ROWS):
		for x in range(-MARGIN_COLS, Grid.COLS + MARGIN_COLS):
			var c := Vector2i(x, y)
			if Grid.in_bounds(c) or (clip.has_area() and not clip.has_point(c)):
				continue
			_floor_tile(c, pal)
			if not margin_lanes.has(c) and hash01(x, y, 23) > 0.8:
				_prop(Grid.cell_center(c), pal, hash01(x, y, 7))
	# Floor everywhere, lanes included: the rounded lanes are drawn over it, and the corners of lane
	# tiles they don't cover show plain floor.
	for y in Grid.ROWS:
		for x in Grid.COLS:
			if not clip.has_area() or clip.has_point(Vector2i(x, y)):
				_floor_tile(Vector2i(x, y), pal)
	# Dim everything outside the build zone.
	var outer := Rect2(Vector2(-MARGIN_COLS, -MARGIN_ROWS) * Grid.TILE, Grid.field_size() + Vector2(MARGIN_COLS * 2, MARGIN_ROWS * 2) * Grid.TILE)
	var dim := Color(0.0, 0.01, 0.02, 0.38)
	draw_rect(Rect2(outer.position, Vector2(-outer.position.x, outer.size.y)), dim)
	draw_rect(Rect2(Vector2(field.end.x, outer.position.y), Vector2(outer.end.x - field.end.x, outer.size.y)), dim)
	draw_rect(Rect2(Vector2(0, outer.position.y), Vector2(field.size.x, -outer.position.y)), dim)
	draw_rect(Rect2(Vector2(0, field.end.y), Vector2(field.size.x, outer.end.y - field.end.y)), dim)
	_draw_lanes(pal)
	for c in grid.tiles:
		if clip.has_area() and not clip.has_point(c):
			continue
		match grid.tiles[c]:
			"H":
				_high_ground(c, pal)
			"P":
				_power_socket(c, pal)
			"R":
				if not cleared.has(c):
					_rubble(c, pal)
			"#":
				_prop(Grid.cell_center(c), pal, hash01(c.x, c.y, 7))
	for group in grid.groups:
		_warp_gate(gate_pos(grid.waypoints[group.routes[0]]), pal)
	_core(core_pos(grid.waypoints[0]), pal)
	# The build-zone rim: a thin lit border with corner brackets.
	draw_rect(field.grow(1.0), Color(0, 0, 0, 0.55), false, 3.0)
	draw_rect(field, Color(pal.edge, 0.22), false, 1.0)
	for corner in [field.position, Vector2(field.end.x, 0), Vector2(0, field.end.y), field.end]:
		var sx := 1.0 if corner.x == 0.0 else -1.0
		var sy := 1.0 if corner.y == 0.0 else -1.0
		draw_line(corner, corner + Vector2(14.0 * sx, 0), Color(pal.edge, 0.6), 2.0)
		draw_line(corner, corner + Vector2(0, 14.0 * sy), Color(pal.edge, 0.6), 2.0)


func _floor_tile(c: Vector2i, pal: Dictionary) -> void:
	var h := hash01(c.x, c.y, 1)
	var base: Color = (pal.a as Color).lerp(pal.b, 0.35 * float(posmod(c.x + c.y, 2)) + 0.4 * h)
	var r := Grid.cell_rect(c)
	draw_rect(r, base)
	match pal.floor:
		"rock":
			_rock_detail(c, pal)
		"ice":
			_ice_detail(r, c, pal)
		_:
			_plate_detail(r, c, pal)


## Tiles the extended lanes cross outside the grid (kept clear of props).
func _margin_lane_cells() -> Dictionary:
	var out := {}
	for curve in grid.ground_paths:
		for p in extended_lane_points(curve):
			var c := Grid.world_to_cell(p)
			for dy in [-1, 0, 1]:
				for dx in [-1, 0, 1]:
					out[c + Vector2i(dx, dy)] = true
	return out


## Smooth lanes: every route's glow, then every rim, then every floor, so forks and merges join
## cleanly. Hazard strips get their base colour on top of the floor.
func _draw_lanes(pal: Dictionary) -> void:
	var edge: Color = pal.edge
	var lines: Array = []
	for curve in grid.ground_paths:
		lines.append(extended_lane_points(curve))
	for pts in lines:
		draw_polyline(pts, Color(edge, 0.10), LANE_W + 14.0, true)
	for pts in lines:
		draw_polyline(pts, Color(0.30, 0.33, 0.38), LANE_W + 7.0, true)
		draw_polyline(pts, Color(edge, 0.8), LANE_W + 3.0, true)
	for pts in lines:
		draw_polyline(pts, pal.lane, LANE_W, true)
	# Lane texture: floor grating across the lane, a worn centre stripe and rim bolts.
	for pts in lines:
		var acc_d := 0.0
		for i in range(1, pts.size()):
			var a: Vector2 = pts[i - 1]
			var b: Vector2 = pts[i]
			var seg := a.distance_to(b)
			if seg < 0.001:
				continue
			var dir := (b - a) / seg
			var nrm := dir.orthogonal()
			var d := 0.0
			while d < seg:
				var along := acc_d + d
				var p := a + dir * d
				if int(along) % 12 == 0:
					draw_line(p - nrm * (LANE_W * 0.42), p + nrm * (LANE_W * 0.42), Color(1, 1, 1, 0.035), 1.0)
				if int(along) % 24 == 0:
					for sgn in [-1.0, 1.0]:
						var bp: Vector2 = p + nrm * sgn * (LANE_W * 0.5 - 2.5)
						draw_circle(bp, 1.3, Color(0, 0, 0, 0.6))
						draw_circle(bp, 0.8, Color(edge, 0.35))
				d += 1.0
			acc_d += seg
		draw_polyline(pts, Color(1, 1, 1, 0.03), 3.0, true)
		draw_polyline(pts, Color(edge, 0.06), 1.0, true)
	# Hazard bases follow the lane's centre line, so they bend with it around rounded corners.
	for run in _hazard_runs("sludge"):
		draw_polyline(run, Color(0.08, 0.25, 0.14, 0.9), 36.0)
	for run in _hazard_runs("shock"):
		for k in 3:
			var strip := _offset_line(run, (float(k) - 1.0) * 11.0)
			draw_polyline(strip, Color(0.35, 0.3, 0.1), 3.0, true)
			draw_polyline(strip, Color(SHOCK, 0.35), 1.0, true)
	for c in grid.hazards:
		var frame := lane_frame(grid, c)
		var ctr: Vector2 = frame[0]
		var dir: Vector2 = frame[1]
		if grid.hazards[c] == "sludge":
			for k in 3:
				var p := ctr + dir * (hash01(c.x, c.y, 40 + k) * 26.0 - 13.0) + dir.orthogonal() * (hash01(c.x, c.y, 50 + k) * 20.0 - 10.0)
				draw_circle(p, 3.0 + 3.0 * hash01(c.x, c.y, 60 + k), Color(SLUDGE, 0.35))
		else:
			for k in 2:
				var cp := ctr + dir * 12.0 * (float(k) * 2.0 - 1.0)
				draw_circle(cp, 3.5, Color(0.2, 0.18, 0.06))
				draw_circle(cp, 2.0, Color(SHOCK, 0.6))


## The lane's centre line through hazard cells of one kind, as runs of consecutive route points.
func _hazard_runs(kind: String) -> Array:
	var runs: Array = []
	for curve in grid.ground_paths:
		var run := PackedVector2Array()
		for p in (curve as Curve2D).get_baked_points():
			if str(grid.hazards.get(Grid.world_to_cell(p), "")) == kind:
				run.append(p)
			else:
				if run.size() > 1:
					runs.append(run)
				run = PackedVector2Array()
		if run.size() > 1:
			runs.append(run)
	return runs


## A polyline shifted sideways by `dist` (along each point's normal).
static func _offset_line(pts: PackedVector2Array, dist: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in pts.size():
		var a: Vector2 = pts[maxi(0, i - 1)]
		var b: Vector2 = pts[mini(pts.size() - 1, i + 1)]
		var n := (b - a).normalized().orthogonal() if a.distance_squared_to(b) > 0.0001 else Vector2.ZERO
		out.append(pts[i] + n * dist)
	return out


## Where the lane runs through a cell: the closest point on any ground route to the cell's centre
## and the route's direction there. Hazard details use it so they sit on the lane at corners too.
static func lane_frame(g, c: Vector2i) -> Array:
	var ctr := Grid.cell_center(c)
	var best := [ctr, Vector2.RIGHT]
	var best_d := INF
	for curve in g.ground_paths:
		var cv: Curve2D = curve
		var off := cv.get_closest_offset(ctr)
		var p := cv.sample_baked(off)
		var d := p.distance_squared_to(ctr)
		if d < best_d:
			best_d = d
			var a := cv.sample_baked(maxf(0.0, off - 4.0))
			var b := cv.sample_baked(minf(cv.get_baked_length(), off + 4.0))
			best = [p, (b - a).normalized() if a.distance_squared_to(b) > 0.0001 else Vector2.RIGHT]
	return best


func _plate_detail(r: Rect2, c: Vector2i, pal: Dictionary) -> void:
	var seam: Color = pal.seam
	draw_rect(r, seam, false, 1.0)
	draw_line(r.position + Vector2(1, 1), Vector2(r.end.x - 1, r.position.y + 1), Color(1, 1, 1, 0.035), 1.0)
	for k in 4:
		var corner := r.position + Vector2(5.0 if k % 2 == 0 else r.size.x - 5.0, 5.0 if k < 2 else r.size.y - 5.0)
		draw_circle(corner, 1.1, pal.detail)
	var h := hash01(c.x, c.y, 3)
	var o := r.position
	if h > 0.78:
		# Vent grate.
		draw_rect(Rect2(o + Vector2(10, 12), Vector2(28, 24)), Color(0, 0, 0, 0.25))
		for i in 4:
			var y := o.y + 15.0 + float(i) * 5.0
			draw_line(Vector2(o.x + 12.0, y), Vector2(r.end.x - 12.0, y), pal.seam, 2.0)
			draw_line(Vector2(o.x + 12.0, y + 1.5), Vector2(r.end.x - 12.0, y + 1.5), Color(1, 1, 1, 0.04), 1.0)
	elif h < 0.08:
		# Service hatch with bolts and a status light.
		draw_rect(Rect2(o + Vector2(13, 13), Vector2(22, 22)), Color(0, 0, 0, 0.2))
		draw_rect(Rect2(o + Vector2(14, 14), Vector2(20, 20)), pal.detail, false, 1.5)
		for k in 4:
			draw_circle(o + Vector2(16.5 + 15.0 * float(k % 2), 16.5 + 15.0 * float(k / 2)), 1.0, pal.detail)
		draw_circle(r.get_center(), 2.0, Color(pal.edge, 0.35))
	elif h < 0.2:
		# A cable run across the plate, with a junction box.
		var y0 := o.y + 10.0 + 28.0 * hash01(c.x, c.y, 31)
		var pts := PackedVector2Array()
		for k in 6:
			var f := float(k) / 5.0
			pts.append(Vector2(o.x + f * 48.0, y0 + sin(f * PI * 2.0 + h * 9.0) * 3.0))
		draw_polyline(pts, Color(0.03, 0.03, 0.04), 3.0, true)
		draw_polyline(pts, (pal.detail as Color).darkened(0.2), 1.6, true)
		var jb := pts[3]
		draw_rect(Rect2(jb - Vector2(4, 3), Vector2(8, 6)), Color(0.05, 0.05, 0.06))
		draw_rect(Rect2(jb - Vector2(3, 2), Vector2(6, 4)), pal.detail)
		draw_circle(jb + Vector2(1.5, 0), 0.9, Color(pal.edge, 0.7))
	elif h < 0.34:
		# Panel split seam.
		draw_line(o + Vector2(24, 2), o + Vector2(24, 46), Color(0, 0, 0, 0.3), 1.0)
		draw_line(o + Vector2(25, 2), o + Vector2(25, 46), Color(1, 1, 1, 0.03), 1.0)
	# Scuffs and wear.
	for k in 2:
		if hash01(c.x, c.y, 40 + k) > 0.55:
			var p := o + Vector2(6.0 + 36.0 * hash01(c.x, c.y, 50 + k), 6.0 + 36.0 * hash01(c.x, c.y, 60 + k))
			var dv := Vector2.from_angle(hash01(c.x, c.y, 70 + k) * TAU) * (3.0 + 5.0 * hash01(c.x, c.y, 80 + k))
			draw_line(p, p + dv, Color(1, 1, 1, 0.035) if k == 0 else Color(0, 0, 0, 0.18), 1.0)
	_lane_edge_marking(c, r, pal)


## Hazard striping on floor plates bordering the lane, on the side facing it.
func _lane_edge_marking(c: Vector2i, r: Rect2, pal: Dictionary) -> void:
	for dv in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if not grid.path_cells.has(c + dv):
			continue
		var band: Rect2
		match dv:
			Vector2i.LEFT:
				band = Rect2(r.position + Vector2(1, 3), Vector2(4, 42))
			Vector2i.RIGHT:
				band = Rect2(Vector2(r.end.x - 5, r.position.y + 3), Vector2(4, 42))
			Vector2i.UP:
				band = Rect2(r.position + Vector2(3, 1), Vector2(42, 4))
			_:
				band = Rect2(Vector2(r.position.x + 3, r.end.y - 5), Vector2(42, 4))
		draw_rect(band, Color(0.05, 0.05, 0.06, 0.55))
		var horiz: bool = dv.y != 0
		var n := int(band.size.x / 6.0) if horiz else int(band.size.y / 6.0)
		for k in n:
			if k % 2 == 0:
				continue
			var p := band.position + (Vector2(6.0 * float(k), 0) if horiz else Vector2(0, 6.0 * float(k)))
			var q := PackedVector2Array([p, p + (Vector2(3, 0) if horiz else Vector2(0, 3)), p + (Vector2(5, 4) if horiz else Vector2(4, 5)), p + (Vector2(2, 4) if horiz else Vector2(4, 2))])
			draw_colored_polygon(q, Color(1.0, 0.78, 0.25, 0.28))


func _rock_detail(c: Vector2i, pal: Dictionary) -> void:
	var o := Vector2(c) * Grid.TILE
	var h := hash01(c.x, c.y, 3)
	if h > 0.6:
		var cp := o + Vector2(10.0 + 28.0 * hash01(c.x, c.y, 11), 10.0 + 28.0 * hash01(c.x, c.y, 12))
		var cr := 4.0 + 6.0 * hash01(c.x, c.y, 13)
		draw_circle(cp, cr, pal.seam)
		draw_arc(cp, cr, PI * 0.9, PI * 1.9, 10, pal.detail, 1.2, true)
	if h < 0.25:
		for i in 3:
			var p := o + Vector2(6.0 + 36.0 * hash01(c.x, c.y, 20 + i), 6.0 + 36.0 * hash01(c.x, c.y, 30 + i))
			draw_circle(p, 1.2, pal.detail)


func _ice_detail(r: Rect2, c: Vector2i, pal: Dictionary) -> void:
	draw_rect(r, Color(pal.seam, 0.6), false, 1.0)
	var h := hash01(c.x, c.y, 3)
	if h > 0.55:
		var a := r.position + Vector2(8.0 + 30.0 * hash01(c.x, c.y, 21), 6.0)
		var b := a + Vector2(-10.0 + 20.0 * hash01(c.x, c.y, 22), 34.0)
		draw_line(a, b, Color(0.7, 0.9, 1.0, 0.18), 1.2)
		draw_line(a.lerp(b, 0.5), a.lerp(b, 0.5) + Vector2(9, 5), Color(0.7, 0.9, 1.0, 0.12), 1.0)
	if h < 0.2:
		draw_circle(r.get_center() + Vector2(6, -4), 5.0, Color(0.8, 0.95, 1.0, 0.07))


## High ground: a raised plate with a bevel and range chevrons.
func _high_ground(c: Vector2i, pal: Dictionary) -> void:
	var r := Grid.cell_rect(c).grow(-2.0)
	var top: Color = (pal.b as Color).lightened(0.22)
	draw_rect(r, Color(0, 0, 0, 0.35))
	draw_rect(Rect2(r.position, r.size - Vector2(3, 3)), top)
	draw_line(r.position, Vector2(r.end.x - 3, r.position.y), Color(1, 1, 1, 0.22), 2.0)
	draw_line(r.position, Vector2(r.position.x, r.end.y - 3), Color(1, 1, 1, 0.14), 2.0)
	draw_line(Vector2(r.position.x, r.end.y - 3), r.end - Vector2(3, 3), Color(0, 0, 0, 0.35), 2.0)
	draw_line(Vector2(r.end.x - 3, r.position.y), r.end - Vector2(3, 3), Color(0, 0, 0, 0.3), 2.0)
	# Tread-plate texture and corner anchors.
	for k in 5:
		for m in 5:
			if (k + m) % 2 == 0:
				var tp := r.position + Vector2(6.0 + 8.0 * float(k), 5.0 + 6.0 * float(m))
				draw_line(tp, tp + Vector2(3, -1.5), Color(1, 1, 1, 0.08), 1.0)
	for q in [r.position + Vector2(4, 4), Vector2(r.end.x - 7, r.position.y + 4), Vector2(r.position.x + 4, r.end.y - 7), r.end - Vector2(7, 7)]:
		draw_circle(q, 1.6, Color(0, 0, 0, 0.5))
		draw_circle(q, 1.0, Color(1, 1, 1, 0.25))
	var ctr := r.get_center() + Vector2(0, 8)
	for k in 2:
		var y := ctr.y + 5.0 * float(k)
		draw_polyline(PackedVector2Array([Vector2(ctr.x - 6, y + 3), Vector2(ctr.x, y - 2), Vector2(ctr.x + 6, y + 3)]), Color(0.65, 0.88, 1.0, 0.55), 1.5, true)


## Power node: a dark hexagonal socket with a ring, on the floor tile; its glow pulses in Scenery.
func _power_socket(c: Vector2i, pal: Dictionary) -> void:
	var ctr := Grid.cell_center(c)
	Draw.fill(self, ctr, Draw.ngon(6, 1.0, PI / 6.0), Color(0.16, 0.14, 0.08), 0.0, 19.0)
	Draw.outline(self, ctr, Draw.ngon(6, 1.0, PI / 6.0), Color(1.0, 0.78, 0.3, 0.7), 1.5, 0.0, 19.0)
	for k in 6:
		var a := TAU * float(k) / 6.0
		draw_line(ctr + Vector2.from_angle(a) * 13.0, ctr + Vector2.from_angle(a) * 18.0, Color(1.0, 0.78, 0.3, 0.45), 1.5)


## Rubble: a pile of debris that must be cleared before building.
func _rubble(c: Vector2i, pal: Dictionary) -> void:
	var o := Vector2(c) * Grid.TILE
	Draw.ellipse(self, o + Vector2(24, 34), 20.0, 7.0, Color(0, 0, 0, 0.3))
	for k in 6:
		var p := o + Vector2(10.0 + 28.0 * hash01(c.x, c.y, 70 + k), 12.0 + 22.0 * hash01(c.x, c.y, 80 + k))
		var s := 5.0 + 6.0 * hash01(c.x, c.y, 90 + k)
		var rot := hash01(c.x, c.y, 100 + k) * TAU
		var shade := 0.5 + 0.5 * hash01(c.x, c.y, 110 + k)
		Draw.solid(self, p, Draw.ngon(4 + k % 2, 1.0, rot), (pal.detail as Color).lerp(Color(0.45, 0.4, 0.35), 0.4) * Color(shade, shade, shade), 0.0, s, 1.0)
	draw_line(o + Vector2(10, 30), o + Vector2(38, 22), Color(0.55, 0.5, 0.42), 2.5)


func _prop(p: Vector2, pal: Dictionary, h: float) -> void:
	var edge: Color = pal.edge
	match pal.prop:
		"crates":
			Draw.ellipse(self, p + Vector2(3, 14), 18.0, 6.0, Color(0, 0, 0, 0.35))
			if h > 0.5:
				draw_rect(Rect2(p + Vector2(-16, -10), Vector2(20, 20)), Color(0.24, 0.28, 0.30))
				draw_rect(Rect2(p + Vector2(-16, -10), Vector2(20, 20)), Color(0.05, 0.06, 0.08), false, 1.5)
				draw_line(p + Vector2(-16, -10), p + Vector2(4, 10), Color(0.12, 0.14, 0.16), 2.0)
				draw_rect(Rect2(p + Vector2(0, -2), Vector2(15, 15)), Color(0.55, 0.42, 0.18))
				draw_rect(Rect2(p + Vector2(0, -2), Vector2(15, 15)), Color(0.05, 0.06, 0.08), false, 1.5)
				draw_rect(Rect2(p + Vector2(2, 4), Vector2(11, 3)), Color(0.1, 0.1, 0.1))
			else:
				draw_circle(p, 12.0, Color(0.05, 0.06, 0.08))
				draw_circle(p, 10.5, Color(0.22, 0.26, 0.29))
				draw_arc(p + Vector2(0, -2), 9.0, PI * 1.1, PI * 1.9, 12, Color(0.55, 0.6, 0.65), 3.0, true)
				draw_line(p + Vector2(0, -2), p + Vector2(0, -16), Color(0.55, 0.6, 0.65), 1.5)
				Draw.glow_dot(self, p + Vector2(0, -16), 1.6, edge)
		"crystals":
			Draw.ellipse(self, p + Vector2(3, 12), 18.0, 6.0, Color(0, 0, 0, 0.35))
			draw_circle(p + Vector2(0, 4), 13.0, Color(0.22, 0.10, 0.08))
			for i in 4:
				var a := -PI / 2.0 + (float(i) - 1.5) * 0.45
				var length := 14.0 + 8.0 * hash01(int(h * 1000.0), i, 3)
				var base := p + Vector2((float(i) - 1.5) * 5.0, 6.0)
				var tip := base + Vector2.from_angle(a) * length
				var w := Vector2.from_angle(a).orthogonal() * 3.2
				draw_colored_polygon(PackedVector2Array([base + w, tip, base - w]), Color(0.95, 0.35, 0.2, 0.85))
				draw_line(base, tip, Color(1.0, 0.75, 0.55, 0.9), 1.0)
			draw_circle(p + Vector2(0, 2), 16.0, Color(1.0, 0.4, 0.2, 0.08))
		"ice":
			Draw.ellipse(self, p + Vector2(3, 14), 18.0, 6.0, Color(0, 0, 0, 0.3))
			for i in 3:
				var base := p + Vector2((float(i) - 1.0) * 9.0, 12.0)
				var tall := 22.0 + 10.0 * hash01(int(h * 1000.0), i, 5)
				var w := 5.0 + 2.0 * float(i % 2)
				draw_colored_polygon(PackedVector2Array([base + Vector2(-w, 0), base + Vector2(0, -tall), base + Vector2(w, 0)]), Color(0.62, 0.85, 0.98, 0.9))
				draw_line(base + Vector2(0, -tall), base + Vector2(-w * 0.4, 0), Color(1, 1, 1, 0.6), 1.2)
		"reactors":
			Draw.ellipse(self, p + Vector2(2, 14), 18.0, 6.0, Color(0, 0, 0, 0.35))
			draw_circle(p, 16.0, Color(0.05, 0.05, 0.1))
			draw_circle(p, 14.5, Color(0.2, 0.2, 0.3))
			Draw.arc_segments(self, p, 11.0, 6, 0.3, h * TAU, Color(0.12, 0.12, 0.2), 3.0)
			draw_circle(p, 7.0, Color(edge, 0.25))
			Draw.glow_dot(self, p, 3.5, edge)
		"machines":
			Draw.ellipse(self, p + Vector2(2, 15), 19.0, 6.0, Color(0, 0, 0, 0.35))
			draw_rect(Rect2(p + Vector2(-18, -14), Vector2(36, 28)), Color(0.08, 0.07, 0.06))
			draw_rect(Rect2(p + Vector2(-16, -12), Vector2(32, 24)), Color(0.28, 0.24, 0.19))
			draw_circle(p + Vector2(-6, 0), 7.0, Color(0.12, 0.1, 0.08))
			Draw.arc_segments(self, p + Vector2(-6, 0), 6.0, 6, 0.4, h * TAU, Color(0.5, 0.43, 0.32), 2.0)
			for k in 3:
				draw_rect(Rect2(p + Vector2(5, -8 + k * 6), Vector2(8, 3)), Color(edge, 0.55))
		"obelisks":
			Draw.ellipse(self, p + Vector2(2, 15), 14.0, 5.0, Color(0, 0, 0, 0.4))
			var pts := PackedVector2Array([p + Vector2(-7, 14), p + Vector2(-4, -16), p + Vector2(0, -21), p + Vector2(4, -16), p + Vector2(7, 14)])
			draw_colored_polygon(pts, Color(0.1, 0.07, 0.16))
			var closed := pts.duplicate()
			closed.append(pts[0])
			draw_polyline(closed, Color(edge, 0.55), 1.2, true)
			draw_line(p + Vector2(0, -14), p + Vector2(0, 8), Color(edge, 0.5), 1.5)
		_:
			draw_circle(p, 14.0, Color(0.3, 0.3, 0.35))


func _warp_gate(p: Vector2, pal: Dictionary) -> void:
	var col := Color(1.0, 0.25, 0.55)
	draw_circle(p, 32.0, Color(col, 0.08))
	# Armoured frame with clamp blocks.
	for k in 8:
		var a := TAU * float(k) / 8.0 + PI / 8.0
		Draw.plate(self, p + Vector2.from_angle(a) * 27.0, Draw.rect_pts(3.0, 4.0), Color(0.3, 0.31, 0.36), a, 1.0, 1.0)
	draw_circle(p, 24.5, Draw.OUTLINE)
	draw_circle(p, 23.5, Color(0.22, 0.2, 0.26))
	draw_arc(p, 22.0, PI * 1.0, PI * 1.6, 16, Color(1, 1, 1, 0.18), 2.0, true)
	draw_circle(p, 21.0, Color(0.06, 0.0, 0.08, 0.95))
	for i in 3:
		draw_arc(p, 7.0 + 4.5 * float(i), float(i) * 1.3, float(i) * 1.3 + 4.2, 20, Color(col, 0.45 + 0.15 * float(i)), 1.6, true)
	Draw.arc_segments(self, p, 22.5, 12, 0.18, 0.0, Color(col, 0.75), 1.4)
	for k in 4:
		Draw.glow_dot(self, p + Vector2.from_angle(TAU * float(k) / 4.0) * 24.0, 1.2, col)


func _core(p: Vector2, pal: Dictionary) -> void:
	var edge := Color(0.35, 0.85, 1.0)
	draw_circle(p, 32.0, Color(edge, 0.07))
	# Octagonal housing with shield emitters and conduits.
	Draw.plate(self, p, Draw.ngon(8, 1.0, PI / 8.0), Color(0.24, 0.27, 0.32), 0.0, 24.0, 1.4)
	for k in 4:
		var a := TAU * float(k) / 4.0 + PI / 4.0
		var e := p + Vector2.from_angle(a) * 20.0
		Draw.orb(self, e, 2.6, Color(0.3, 0.34, 0.4))
		Draw.glow_dot(self, e, 1.2, edge)
	draw_circle(p, 17.5, Draw.OUTLINE)
	draw_circle(p, 16.5, Color(0.04, 0.05, 0.07))
	Draw.arc_segments(self, p, 14.5, 6, 0.2, PI / 6.0, Color(0.32, 0.36, 0.42), 4.0)
	draw_circle(p, 11.0, Color(0.1, 0.12, 0.16))
	draw_circle(p, 9.0, Color(edge, 0.3))
	Draw.glow_dot(self, p, 5.0, edge)
	draw_arc(p, 28.0, 0.0, TAU, 48, Color(edge, 0.5), 1.5, true)
