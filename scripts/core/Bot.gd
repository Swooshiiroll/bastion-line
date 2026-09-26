extends RefCounted
## A simple heuristic player. Used by the headless balance tests, the main-menu attract mode,
## and the screenshot tour. It builds on the tiles that see the most path, then upgrades.

const Game = preload("res://scripts/core/Game.gd")
const Towers = preload("res://data/towers.gd")
const Tower = preload("res://scripts/entities/Tower.gd")
const Grid = preload("res://scripts/core/Grid.gd")

const BUILD_ORDER := [
	"arrow", "arrow", "cannon", "scrap", "frost", "arrow", "tesla", "sniper", "missile", "sensor",
	"laser", "nova", "cannon", "amp", "flak", "scrap", "nullifier", "gravity", "tesla", "drones", "arrow",
	"sniper", "missile", "frost", "laser", "nova", "amp", "flak", "sensor", "cannon", "drones",
	"tesla", "nullifier", "gravity",
]
const AIR_WEIGHT := 0.7
## How much the bot values a Scrapyard upgrade against a tower upgrade (per credit).
const ECON_WEIGHT := 20.0
const MAX_TOWERS := 80
## High ground and power nodes are worth about this much more than an open tile.
const SITE_WEIGHT := 1.15
const HAZARD_SHOCK_WEIGHT := 200.0
const HAZARD_SLUDGE_WEIGHT := 100.0

const Abilities = preload("res://data/abilities.gd")

var game
var use_abilities := true
var use_gates := true
var order_idx := 0
var ground_samples := PackedVector2Array()
var air_samples := PackedVector2Array()
var _cover := {}
var _think := 0.0


func _init(g) -> void:
	game = g
	if use_gates and g.wave == 0:
		set_gates()
	ground_samples = _sample_routes(_active_routes())
	air_samples = _sample_routes(g.grid.air_paths)


## Before the first wave, point every switch gate at its "slowest" branch: the one where ground
## enemies spend longest in the field, counting hazard tiles as extra time. A player would click
## the gate; the bot just sets it during its setup.
func set_gates() -> void:
	var grid = game.grid
	for gi in grid.groups.size():
		var group: Dictionary = grid.groups[gi]
		if group.fork == null:
			continue
		var best := 0
		var best_score := -INF
		for k in group.routes.size():
			var r: int = group.routes[k]
			var score: float = grid.ground_paths[r].get_baked_length()
			for c in _route_cells(grid.waypoints[r]):
				match grid.hazards.get(c, ""):
					"shock":
						score += HAZARD_SHOCK_WEIGHT
					"sludge":
						score += HAZARD_SLUDGE_WEIGHT
			if score > best_score:
				best_score = score
				best = k
		game.gates[gi] = best + 1


## The routes enemies will actually take (all of them when a gate is split).
func _active_routes() -> Array:
	var out: Array = []
	var grid = game.grid
	for gi in grid.groups.size():
		var group: Dictionary = grid.groups[gi]
		var st := int(game.gates[gi])
		for k in group.routes.size():
			if st == 0 or st == k + 1:
				out.append(grid.ground_paths[group.routes[k]])
	return out


static func _route_cells(pts: Array) -> Array:
	var out: Array = []
	for i in range(1, pts.size()):
		var a: Vector2i = pts[i - 1]
		var b: Vector2i = pts[i]
		var step := Vector2i(signi(b.x - a.x), signi(b.y - a.y))
		var c := a
		while c != b:
			out.append(c)
			c += step
		out.append(b)
	return out


func update(dt: float) -> void:
	if game.is_over():
		return
	_think -= dt
	if _think <= 0.0:
		_think = 0.5
		act()
		if use_abilities:
			use_abilities_now()
	if game.state == Game.State.BUILD:
		act()
		game.start_wave()


func act() -> void:
	for guard in 60:
		if not _step():
			return


func _step() -> bool:
	if game.is_over():
		return false
	var want: String = BUILD_ORDER[order_idx % BUILD_ORDER.size()]
	var target_count := mini(3 + game.wave, MAX_TOWERS)
	if game.towers.size() < target_count:
		return _try_build(want)
	var up = best_upgrade()
	if up != null:
		var key := next_key(up)
		if game.gold >= up.upgrade_cost(key):
			return game.upgrade_tower(up, key)
		return false
	return _try_build(want)


func _try_build(type: String) -> bool:
	if game.gold < game.tower_cost(type):
		return false
	var cell = best_cell(type)
	if cell == null:
		order_idx += 1
		return true
	game.place_tower(type, cell)
	order_idx += 1
	return true


## Which upgrade to buy next on a tower: its specialization at tier 2, then two upgrades on a
## secondary branch once the primary has two, then the rest of the primary ("" = primary).
func next_key(t) -> String:
	if t.trunk < 2:
		return ""
	if t.needs_spec():
		return choose_spec(t)
	var p: String = t.primary()
	if t.started.size() == 1 and int(t.depth[p]) == 2:
		var others: Array = Tower.BRANCHES.filter(func(b): return b != p)
		return others[(t.cell.x * 3 + t.cell.y) % others.size()]
	if t.started.size() == 2 and not t.locked_in():
		var s: String = t.secondary()
		if int(t.depth[s]) < Tower.SECONDARY_CAP:
			return s
		return p
	return ""


## Deterministic but varied: the tower's tile picks which of the three specializations it gets.
func choose_spec(t) -> String:
	if not t.needs_spec():
		return ""
	var ids: Array = t.spec_ids()
	return ids[(t.cell.x + t.cell.y) % ids.size()]


## Amplifier-style support (boosts neighbours) rather than a sensor, which is placed for coverage.
static func is_pylon(type: String) -> bool:
	var d: Dictionary = Towers.TOWERS[type]
	return bool(d.get("support", false)) and not bool(d.get("sensor", false)) and not bool(d.get("economy", false))


## Number of attacking towers a pylon at c would boost.
func pylon_value(c: Vector2i, r: float) -> int:
	var p := Grid.cell_center(c)
	var n := 0
	for t in game.towers:
		if not t.is_support() and t.pos.distance_to(p) <= r:
			n += 1
	return n


func best_cell(type: String):
	# Scrapyards go among the towers, where Supply Depots and Scrap Collectors have the most to work on.
	if Towers.TOWERS[type].get("economy", false):
		var best_e = null
		var best_en := -1
		for y in Grid.ROWS:
			for x in Grid.COLS:
				var ec := Vector2i(x, y)
				if not game.grid.is_buildable(ec) or game.tower_at.has(ec):
					continue
				var en := pylon_value(ec, 140.0)
				if en > best_en:
					best_en = en
					best_e = ec
		return best_e
	if is_pylon(type):
		var r: float = float(Tower.lines(type).t1.get("range", 150.0))
		var best_c = null
		var best_n := 1
		for y in Grid.ROWS:
			for x in Grid.COLS:
				var pc := Vector2i(x, y)
				if not game.grid.is_buildable(pc) or game.tower_at.has(pc):
					continue
				var n := pylon_value(pc, r)
				if n > best_n:
					best_n = n
					best_c = pc
		return best_c
	var cov := coverage(type)
	var best = null
	var best_score := 0.5
	for y in Grid.ROWS:
		for x in Grid.COLS:
			var c := Vector2i(x, y)
			if not cov.has(c) or game.tower_at.has(c):
				continue
			var sc: float = cov[c]
			if game.grid.tile_at(c) in ["H", "P"]:
				sc *= SITE_WEIGHT
			if sc > best_score:
				best_score = sc
				best = c
	return best


func best_upgrade():
	var best = null
	var best_val := 0.0
	for t in game.towers:
		var cost: int = t.upgrade_cost(next_key(t))
		if cost <= 0:
			continue
		var val: float
		if t.is_economy():
			val = ECON_WEIGHT / float(cost)
		elif is_pylon(t.type):
			val = 12.0 * float(pylon_value(t.cell, t.get_range())) / float(cost)
		else:
			val = float(coverage(t.type).get(t.cell, 1.0)) / float(cost)
		if val > best_val:
			best_val = val
			best = t
	return best


## Time Warp when a boss or a big crowd is on the field; Meteor on the best cluster (or a boss).
func use_abilities_now() -> void:
	if game.state != Game.State.WAVE:
		return
	var alive: Array = game.enemies.filter(func(e): return e.alive)
	var boss_up := alive.any(func(e): return e.boss)
	if game.ability_ready("warp") and (boss_up or alive.size() >= 25):
		game.cast_warp()
	if not game.ability_ready("meteor") or alive.is_empty():
		return
	var r: float = Abilities.ABILITIES.meteor.radius
	var best_pos := Vector2.ZERO
	var best_score := 0.0
	for c in alive:
		# Aim slightly ahead of the candidate along its heading, since the meteor takes time to land.
		var aim: Vector2 = c.pos + c.facing * c.speed * 0.5
		var score := 0.0
		for e in alive:
			if e.pos.distance_squared_to(aim) <= r * r:
				score += 6.0 if e.boss else 1.0
		if score > best_score:
			best_score = score
			best_pos = aim
	if best_score >= 6.0:
		game.cast_meteor(best_pos)


## Score per buildable tile: how many route sample points a tier-1 tower of this type would reach.
func coverage(type: String) -> Dictionary:
	var d: Dictionary = Towers.TOWERS[type]
	# Drones fly anywhere, so where the bay sits barely matters; score it like a long-range tower.
	var r: float = float(Tower.lines(type).t1.get("range", 320.0))
	var air: bool = d.air
	var ground: bool = d.get("ground", true)
	var key := "%d:%d:%d" % [int(r), int(air), int(ground)]
	if _cover.has(key):
		return _cover[key]
	var out := {}
	var r2 := r * r
	for y in Grid.ROWS:
		for x in Grid.COLS:
			var c := Vector2i(x, y)
			if not game.grid.is_buildable(c):
				continue
			var p := Grid.cell_center(c)
			var score := 0.0
			if ground:
				for q in ground_samples:
					if p.distance_squared_to(q) <= r2:
						score += 1.0
			if air:
				for q in air_samples:
					if p.distance_squared_to(q) <= r2:
						score += AIR_WEIGHT
			out[c] = score
	_cover[key] = out
	return out


static func _sample_routes(curves: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	var field := Rect2(Vector2.ZERO, Grid.field_size())
	for curve in curves:
		var length: float = curve.get_baked_length()
		var d := 0.0
		while d <= length:
			var p: Vector2 = curve.sample_baked(d)
			if field.has_point(p):
				out.append(p)
			d += 16.0
	return out
