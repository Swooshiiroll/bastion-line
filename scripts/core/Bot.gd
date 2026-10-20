extends RefCounted
## A simple heuristic player. Used by the headless balance tests, the balance and perf probes, and
## the screenshot tour. It builds on the tiles that see the most path, then upgrades. It plays the
## reworked towers (issue #59) unless `roster` is "old".

const Game = preload("res://scripts/core/Game.gd")
const Towers = preload("res://data/towers.gd")
const Tower = preload("res://scripts/entities/Tower.gd")
const Grid = preload("res://scripts/core/Grid.gd")

## The old roster's build order (`roster = "old"`, kept for comparison until the final swap).
const BUILD_ORDER := [
	"arrow", "arrow", "cannon", "scrap", "frost", "arrow", "tesla", "sniper", "missile", "sensor",
	"laser", "nova", "cannon", "amp", "flak", "scrap", "nullifier", "gravity", "tesla", "drones", "arrow",
	"sniper", "missile", "frost", "laser", "nova", "amp", "flak", "sensor", "cannon", "drones",
	"tesla", "nullifier", "gravity",
]
## The reworked roster's build order: the strongest damage per credit (Mortar, Rocket Salvo, Gun Turret) first, anti-air and a
## Radar before the first cloaked flyer (round 13), energy that hits air (Laser, Tesla) well before the Wraith, then the rest.
const NEW_ORDER := [
	"gun_turret", "mortar_tower", "rocket_salvo", "gun_turret", "anti_aircraft_turret", "mortar_tower", "laser_tower",
	"rocket_salvo", "radar_tower", "gun_turret", "scrapyard", "mortar_tower", "anti_aircraft_turret", "rocket_salvo",
	"laser_tower", "boost_tower", "mortar_tower", "rocket_salvo", "tesla_tower", "railgun", "drone_bay", "radar_tower",
	"artillery_cannon", "laser_tower", "shockwave_generator", "chemical_plant", "cryo_tower", "mine_layer", "rocket_salvo",
	"mortar_tower", "magneto_tower", "augmentation_tower", "anti_aircraft_turret", "tractor_tower", "cas_gunship", "scrapyard",
	"laser_tower", "tesla_tower",
]
## Towers whose choices the bot doesn't leave to the tile: the Radar takes the faster sweep (path b) and the longer reveal
## (Signal Processor), the Drone Bay its loadouts (path b, which reach the energy laser).
const PREFER := {
	"radar_tower": {"retrofit": 1, "paths": ["b", "a"]},
	"drone_bay": {"paths": ["b", "c"]},
}
## The upgrade key the bot uses for a reworked tower's Retrofit.
const RETROFIT := "retrofit"
## A Retrofit up to this price is bought after the first path step; a dearer one waits until both paths have two steps.
const CHEAP_RETROFIT := 300
## Reach the bot scores towers without a range by (Artillery, Drone Bay, CAS Gunship: they work anywhere).
const ANYWHERE_REACH := 320.0
## Radius of the busiest choke the Artillery shells (its splash) and the CAS Gunship circles (its orbit).
const SHELL_CHOKE := 60.0
const ORBIT_CHOKE := 90.0
const AIR_WEIGHT := 0.7
## How much a stretch of ground lane counts against a stretch of flight path when the bot places a Radar (cloaked enemies are
## mostly flyers; a Cloaked elite can walk).
const SCOUT_GROUND_WEIGHT := 0.3
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
## "new" (the reworked towers) or "old" (today's roster).
var roster := "new"
var order_idx := 0
var ground_samples := PackedVector2Array()
var air_samples := PackedVector2Array()
var _cover := {}
var _chokes := {}
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
	var order: Array = build_order()
	var want: String = order[order_idx % order.size()]
	var target_count := mini(3 + game.wave, MAX_TOWERS)
	if game.towers.size() < target_count:
		return _try_build(want)
	var up = best_upgrade()
	if up != null:
		var key := next_key(up)
		if game.gold >= cost_of(up, key):
			return buy(up, key)
		return false
	return _try_build(want)


func build_order() -> Array:
	return BUILD_ORDER if roster == "old" else NEW_ORDER


func _try_build(type: String) -> bool:
	if game.gold < game.tower_cost(type):
		return false
	var cell = best_cell(type)
	if cell == null:
		order_idx += 1
		return true
	var t = game.place_tower(type, cell)
	if t != null:
		aim(t)
	order_idx += 1
	return true


## Points an Artillery Cannon at the busiest choke on the active routes, and a CAS Gunship's orbit likewise (a player would
## click the track). Other towers need no aiming.
func aim(t) -> void:
	if ground_samples.is_empty():
		return
	if t.type == "artillery_cannon":
		game.aim_artillery(t, choke(SHELL_CHOKE))
	elif t.type == "cas_gunship":
		game.designate_orbit(t, choke(ORBIT_CHOKE))


## The route sample point with the most other route samples within `radius` (cached per radius).
func choke(radius: float) -> Vector2:
	if _chokes.has(radius):
		return _chokes[radius]
	var r2 := radius * radius
	var best := ground_samples[0]
	var best_n := -1
	for p in ground_samples:
		var n := 0
		for q in ground_samples:
			if p.distance_squared_to(q) <= r2:
				n += 1
		if n > best_n:
			best_n = n
			best = p
	_chokes[radius] = best
	return best


## The price of upgrade `key` on tower `t` (0 when there's nothing to buy): a path step, or `RETROFIT`.
func cost_of(t, key: String) -> int:
	if key == RETROFIT:
		return t.retrofit_cost(retrofit_pick(t))
	return t.upgrade_cost(key)


## Buys upgrade `key` on tower `t`, then puts any loadout or shell it unlocked to use.
func buy(t, key: String) -> bool:
	var ok: bool = game.buy_retrofit(t, retrofit_pick(t)) if key == RETROFIT else game.upgrade_tower(t, key)
	if ok:
		use_unlocks(t)
	return ok


## A Drone Bay flies its newest loadout and an Artillery Cannon fires its newest shell (each unlock is a step up).
func use_unlocks(t) -> void:
	if t.type == "drone_bay":
		var lo: Array = t.available_loadouts()
		if t.loadout != lo.back():
			game.set_loadout(t, lo.back())
	elif t.type == "artillery_cannon":
		var sh: Array = t.available_shells()
		if t.shell != sh.back():
			game.set_shell(t, sh.back())


## Deterministic but varied: the tower's tile picks its Retrofit option (unless `PREFER` names one).
func retrofit_pick(t) -> int:
	if PREFER.has(t.type) and PREFER[t.type].has("retrofit"):
		return int(PREFER[t.type].retrofit)
	var n: int = t.retrofit_options().size()
	return (t.cell.x + t.cell.y) % n if n > 0 else -1


## The path a reworked tower's tile makes its primary (`which` 0) or its secondary (1), unless `PREFER` names them.
static func path_pick(t, which: int) -> String:
	if PREFER.has(t.type) and PREFER[t.type].has("paths"):
		return str(PREFER[t.type].paths[which])
	return Tower.BRANCHES[(t.cell.x * 2 + t.cell.y + which) % Tower.BRANCHES.size()]


## A reworked tower's next upgrade: one step on its primary path, the Retrofit if it's cheap, a second primary step, two on
## the secondary, the Retrofit if it wasn't cheap, then the primary to its mastery. A CAS Gunship (every path uncapped) takes
## the Retrofit after its first step and otherwise raises its shallowest path.
func _rework_key(t) -> String:
	var retro: bool = t.retrofit < 0 and not t.retrofit_options().is_empty()
	if t.is_uncapped():
		if retro and int(t.depth.a) + int(t.depth.b) + int(t.depth.c) > 0:
			return RETROFIT
		var low := ""
		for b in Tower.BRANCHES:
			if t.can_buy(b) and (low == "" or int(t.depth[b]) < int(t.depth[low])):
				low = b
		return low
	var p := path_pick(t, 0)
	var s := path_pick(t, 1)
	if int(t.depth[p]) < 1:
		return p
	if retro and cost_of(t, RETROFIT) <= CHEAP_RETROFIT:
		return RETROFIT
	if int(t.depth[p]) < 2:
		return p
	if int(t.depth[s]) < Tower.SECONDARY_CAP:
		return s
	if retro:
		return RETROFIT
	return p


## Which upgrade to buy next on a tower: its specialization at tier 2, then two upgrades on a
## secondary branch once the primary has two, then the rest of the primary ("" = primary).
## Reworked towers follow `_rework_key`.
func next_key(t) -> String:
	if t.is_rework:
		return _rework_key(t)
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
	var d: Dictionary = Towers.def(type)
	return bool(d.get("support", false)) and not bool(d.get("sensor", false)) and not bool(d.get("economy", false))


## What a Radar at c would reveal to the towers already built: every stretch of flight path (and, for less, of lane) inside its
## circle, counted once per attacking tower that can shoot there.
func scout_value(c: Vector2i, r: float) -> float:
	var p := Grid.cell_center(c)
	var r2 := r * r
	var v := 0.0
	for q in air_samples:
		if p.distance_squared_to(q) <= r2:
			v += float(_shooters(q, true))
	for q in ground_samples:
		if p.distance_squared_to(q) <= r2:
			v += SCOUT_GROUND_WEIGHT * float(_shooters(q, false))
	return v


func _shooters(q: Vector2, air: bool) -> int:
	var n := 0
	for t in game.towers:
		if t.is_support() or t.is_economy() or t.type == "radar_tower":
			continue
		if (t.hits_air() if air else t.hits_ground()) and t.pos.distance_squared_to(q) <= t.get_range() * t.get_range():
			n += 1
	return n


## Number of attacking towers a pylon at c would boost.
func pylon_value(c: Vector2i, r: float) -> int:
	var p := Grid.cell_center(c)
	var n := 0
	for t in game.towers:
		if not t.is_support() and t.pos.distance_to(p) <= r:
			n += 1
	return n


func best_cell(type: String):
	# 2x2 towers need their whole footprint free (the cell is the top-left tile).
	var big: bool = Game.size_of(type) > 1
	# Scrapyards go among the towers, where Supply Depots and Scrap Collectors have the most to work on.
	if Towers.def(type).get("economy", false):
		var best_e = null
		var best_en := -1
		for y in Grid.ROWS:
			for x in Grid.COLS:
				var ec := Vector2i(x, y)
				if not game.grid.is_buildable(ec) or game.tower_at.has(ec):
					continue
				if big and game.placement_error(type, ec) != "":
					continue
				var en := pylon_value(ec, 140.0)
				if en > best_en:
					best_en = en
					best_e = ec
		return best_e
	if type == "radar_tower":
		var rr := reach(type, 160.0)
		var best_s = null
		var best_v := 0.0
		for y in Grid.ROWS:
			for x in Grid.COLS:
				var sc := Vector2i(x, y)
				if not game.grid.is_buildable(sc) or game.tower_at.has(sc):
					continue
				var v := scout_value(sc, rr)
				if v > best_v:
					best_v = v
					best_s = sc
		return best_s
	if is_pylon(type):
		var r: float = reach(type, 150.0)
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
			if big and game.placement_error(type, c) != "":
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
		var cost: int = cost_of(t, next_key(t))
		if cost <= 0:
			continue
		var val: float = value_at(t.type, t.cell, t.get_range()) / float(cost)
		if val > best_val:
			best_val = val
			best = t
	return best


## What a tower of `type` at `cell` is worth to the bot: a fixed weight for an economy tower, the towers it boosts for a
## pylon (within `r`, its stock range when not given), and the route it covers for anything else.
func value_at(type: String, cell: Vector2i, r := -1.0) -> float:
	if Towers.def(type).get("economy", false):
		return ECON_WEIGHT
	if is_pylon(type):
		return 12.0 * float(pylon_value(cell, r if r > 0.0 else reach(type, 150.0)))
	if type == "radar_tower":
		return scout_value(cell, r if r > 0.0 else reach(type, 160.0))
	return float(coverage(type).get(cell, 1.0))


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
	var d: Dictionary = Towers.def(type)
	# Drones fly anywhere, so where the bay sits barely matters; score it like a long-range tower.
	var r: float = reach(type, ANYWHERE_REACH)
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


## A tower type's stock range (`fallback` when it has none: towers that work anywhere on the field).
static func reach(type: String, fallback: float) -> float:
	if Towers.is_rework(type):
		return float(Tower.rework_base(type).get("range", fallback))
	return float(Tower.lines(type).t1.get("range", fallback))


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
