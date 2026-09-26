extends RefCounted
## Sector geometry: the tile grid parsed from a map's ASCII layout (floor, walls, high ground,
## power nodes, rubble, lane hazards, switch gates), the routes enemies follow as smoothly rounded
## Curve2Ds, and route groups (one per warp gate) with their fork point.

const Maps = preload("res://data/maps.gd")

const COLS := 32
const ROWS := 16
const TILE := 48.0
## Radius of the rounded turns routes make at corners (px). Kept inside the lane tile.
const CORNER_R := 20.0
const LANE_CHARS := "=~^G"

var map_id := ""
var def: Dictionary
## Non-floor tiles: cell -> layout char ('#', 'H', 'P', 'R', '=', '~', '^', 'G').
var tiles := {}
var path_cells := {}
var blocked := {}
var rubble: Array = []
## Lane hazards: cell -> "sludge" | "shock".
var hazards := {}
## Per route (flat index): waypoints, rounded ground curve, straight flyer curve, its group.
var waypoints: Array = []
var ground_paths: Array = []
var air_paths: Array = []
var route_group: Array = []
## Per group (warp gate): {"routes": [route idx], "fork": Vector2i or null, "fork_dist": px,
## "labels": [direction name per route]}.
var groups: Array = []


func _init(id: String) -> void:
	map_id = id
	def = Maps.MAPS[id]
	var layout: Array = def.layout
	for y in layout.size():
		var row: String = layout[y]
		for x in row.length():
			var ch := row[x]
			if ch == ".":
				continue
			var c := Vector2i(x, y)
			tiles[c] = ch
			match ch:
				"#":
					blocked[c] = true
				"R":
					rubble.append(c)
				"~":
					hazards[c] = "sludge"
				"^":
					hazards[c] = "shock"
	for gi in def.entrances.size():
		var routes: Array = def.entrances[gi]
		var group := {"routes": [], "fork": null, "fork_dist": 0.0, "labels": []}
		for pts in routes:
			var idx := waypoints.size()
			waypoints.append(pts)
			for i in range(1, pts.size()):
				_mark_segment(pts[i - 1], pts[i])
			ground_paths.append(rounded_curve(pts))
			var air := Curve2D.new()
			air.bake_interval = 4.0
			air.add_point(cell_center(pts[0]))
			air.add_point(cell_center(pts[pts.size() - 1]))
			air_paths.append(air)
			route_group.append(gi)
			group.routes.append(idx)
		if routes.size() > 1:
			_find_fork(group)
		groups.append(group)


## A route through cell centres with each corner replaced by a quarter-turn of radius CORNER_R.
static func rounded_curve(pts: Array) -> Curve2D:
	var curve := Curve2D.new()
	curve.bake_interval = 4.0
	var k := CORNER_R * 0.5523
	for i in pts.size():
		var p := cell_center(pts[i])
		if i == 0 or i == pts.size() - 1:
			curve.add_point(p)
			continue
		var d1 := (p - cell_center(pts[i - 1])).normalized()
		var d2 := (cell_center(pts[i + 1]) - p).normalized()
		if d1.is_equal_approx(d2):
			curve.add_point(p)
			continue
		curve.add_point(p - d1 * CORNER_R, Vector2.ZERO, d1 * k)
		curve.add_point(p + d2 * CORNER_R, -d2 * k, Vector2.ZERO)
	return curve


## The fork is the last waypoint all routes of the group share. Routes are identical up to a
## little before it, which is where a switch gate can still move an enemy onto another route.
func _find_fork(group: Dictionary) -> void:
	var first: Array = waypoints[group.routes[0]]
	var n := first.size()
	for r in group.routes:
		var pts: Array = waypoints[r]
		var k := 0
		while k < mini(n, pts.size()) and pts[k] == first[k]:
			k += 1
		n = k
	var fork: Vector2i = first[n - 1]
	group["fork"] = fork
	var curve: Curve2D = ground_paths[group.routes[0]]
	group["fork_dist"] = curve.get_closest_offset(cell_center(fork)) - CORNER_R - 4.0
	for r in group.routes:
		var pts: Array = waypoints[r]
		group.labels.append(direction_name(pts[n] - fork))


static func direction_name(d: Vector2i) -> String:
	if d.x > 0:
		return "East"
	if d.x < 0:
		return "West"
	if d.y < 0:
		return "North"
	return "South"


static func cell_center(c: Vector2i) -> Vector2:
	return Vector2((c.x + 0.5) * TILE, (c.y + 0.5) * TILE)


static func cell_rect(c: Vector2i) -> Rect2:
	return Rect2(c.x * TILE, c.y * TILE, TILE, TILE)


static func in_bounds(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < COLS and c.y < ROWS


static func world_to_cell(p: Vector2) -> Vector2i:
	return Vector2i(floori(p.x / TILE), floori(p.y / TILE))


static func field_size() -> Vector2:
	return Vector2(COLS * TILE, ROWS * TILE)


func tile_at(c: Vector2i) -> String:
	return str(tiles.get(c, "."))


## Buildable ignoring cleared rubble (the Game tracks what has been cleared).
func is_buildable(c: Vector2i) -> bool:
	return in_bounds(c) and tile_at(c) in [".", "H", "P"]


## The group whose switch gate sits on `c`, or -1.
func gate_group_at(c: Vector2i) -> int:
	for gi in groups.size():
		if groups[gi].fork == c:
			return gi
	return -1


func _mark_segment(a: Vector2i, b: Vector2i) -> void:
	var step := Vector2i(signi(b.x - a.x), signi(b.y - a.y))
	var c := a
	for guard in 200:
		if in_bounds(c):
			path_cells[c] = true
		if c == b:
			return
		c += step
	push_error("Path segment %s -> %s on map '%s' is not axis-aligned" % [a, b, map_id])
