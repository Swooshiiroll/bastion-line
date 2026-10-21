extends RefCounted
## Deterministic tower-defense simulation. No nodes, no rendering, no file I/O.
## The view layer calls tick() at a fixed step and drains `events` for effects and sound;
## headless tests drive the exact same code thousands of ticks at a time.

const Towers = preload("res://data/towers.gd")
const Enemies = preload("res://data/enemies.gd")
const Modifiers = preload("res://data/modifiers.gd")
const Waves = preload("res://data/waves.gd")
const Maps = preload("res://data/maps.gd")
const Abilities = preload("res://data/abilities.gd")
const Difficulty = preload("res://data/difficulty.gd")
const Grid = preload("res://scripts/core/Grid.gd")
const Research = preload("res://scripts/core/Research.gd")
const Tower = preload("res://scripts/entities/Tower.gd")
const Enemy = preload("res://scripts/entities/Enemy.gd")
const Projectile = preload("res://scripts/entities/Projectile.gd")

enum State { BUILD, WAVE, GAMEOVER }

const TICK := 1.0 / 60.0
const SELL_REFUND := 0.7
const SAVE_VERSION := 10
## Credits every run starts with, on every sector and mode (before research).
const START_GOLD := 500
## Sandbox runs keep the credit balance pinned here (see sandbox).
const SANDBOX_GOLD := 999999
## Sandbox DPS meter: seconds per bucket and buckets kept (a 5 s window).
const DPS_BUCKET := 0.25
const DPS_BUCKETS := 20
const AUTO_START_DELAY := 5.0
const RETARGET_DELAY := 0.1
const STAT_KEYS := ["kills", "gold_earned", "towers_built", "leaked", "waves_cleared"]
const BOSS_STUN_FACTOR := 0.3
## A critical hit does double damage (the Gun Turret's Range path; the Augmentation Tower's Precision Matrix raises it).
const CRIT_MULT := 2.0
const LASER_SECONDARY := 0.6
const MISSILE_TURN := 7.0
const MISSILE_MAX_LIFE := 3.0
const RAIL_WIDTH := 10.0
const SHIELD_EMP_MULT := 2.0
const RUBBLE_COST := 40
const GATE_COOLDOWN := 6.0
const SLUDGE_SLOW := 0.3
const SHOCK_PCT := 0.04
const SHOCK_BOSS_PCT := 0.01
## Seconds after an EMP wears off before a tower can be knocked offline again (every Disruptor, design/new_enemies.md).
const DISABLE_GUARD := 1.0
const BOSS_PUSH_FACTOR := 0.25
const REVEAL_TIME := 0.25
const HIT_REVEAL_TIME := 0.5

var map_id := ""
var map_def: Dictionary
var difficulty := "medium"
var diff_def: Dictionary
var grid
var state: int = State.BUILD
var gold := 0
var lives := 0
var max_lives := 0
var ability_cd := {}
var strikes: Array = []
var warp_timer := 0.0
var pools: Array = []
## Short-lived damage zones (the Tesla Tower's storms).
var storms: Array = []
## Railgun ion trails: {a, b, w, dps, t, source}. Everything on the line burns while one lasts, targeted or not, cloaked included.
var trails: Array = []
## Mine Layer mines on the track: {pos, source}. They go off under ground and burrowed enemies and clear when the round ends.
var mines: Array = []
var _boost_sig := 0

## Nested mini-nova depth, so a chain of kills can't recurse forever.
var wave := 0
var endless := false
## This run has cleared its mode's last round (the sector's medal for the mode is earned).
var medal := false
## Sandbox: a test bench. Infinite credits and shields, free upgrades, no ability cooldowns, nothing
## saved or earned. Set by the creator right after construction. See design/sandbox.md.
var sandbox := false
var _dps_clock := 0.0
## Balance-probe knob: extra enemy HP multiplier (1.0 in real games; not saved).
var hp_factor := 1.0
var auto_start := false
var auto_timer := 0.0
var speed := 1
var time := 0.0
var seed_value := 1
## Research nodes in effect. Set at the start of the run and again whenever research is bought or
## reset mid-run (apply_research); saved with the run.
var research: Array = []
var run_mods := {}
var tower_mods := {}
var sell_refund := SELL_REFUND
var bounty_carry := 0.0
## Scrapyards with a kill-credit field (rebuilt with the tower buffs).
var collectors: Array = []
## Rubble tiles the player has paid to clear: cell -> true.
var cleared := {}
## Switch gate per route group: 0 = split (alternate), k = only the group's route k-1.
var gates: Array = []
var gate_cd: Array = []
## Spawns per group so far, for alternating a split gate's routes deterministically.
var route_counters: Array = []

var towers: Array = []
var tower_at := {}
var enemies: Array = []
var projectiles: Array = []
var spawn_queue: Array = []
var wave_remaining := {}
var events: Array = []
var emit_events := true
var stats := {}

var _next_enemy_id := 1
var _roll_count := 0
## Smoke clouds left by Smoke Shells and Smoke Trails: {pos, r, t, slow}. They slow ground enemies inside while they last.
var smokes: Array = []
var _spawn_counter := 0
var _new_enemies: Array = []


func _init(id: String = "meadow", seed_in: int = 0, diff: String = "medium", research_in: Array = []) -> void:
	map_id = id
	map_def = Maps.MAPS[id]
	difficulty = Difficulty.resolve(diff)
	if difficulty == "":
		difficulty = "medium"
	diff_def = Difficulty.DIFFICULTIES[difficulty]
	grid = Grid.new(id)
	for gi in grid.groups.size():
		gates.append(0)
		gate_cd.append(0.0)
		route_counters.append(0)
	research = Research.sanitize(research_in)
	run_mods = Research.run_mods(research)
	for type in Towers.all_types():
		tower_mods[type] = Research.tower_mods(research, type)
		tower_mods[type]["price"] = Difficulty.price(difficulty)
	sell_refund = SELL_REFUND + float(run_mods.sell_refund)
	gold = start_gold(run_mods)
	lives = start_lives(difficulty, run_mods)
	max_lives = lives
	seed_value = seed_in if seed_in != 0 else (randi() | 1)
	for k in STAT_KEYS:
		stats[k] = 0
	for a in Abilities.ORDER:
		ability_cd[a] = 0.0


## Credits a run starts with: the standard amount plus the research bonus.
static func start_gold(mods: Dictionary) -> int:
	return int(round(float(START_GOLD) * (1.0 + float(mods.get("start_gold", 0.0)))))


## Applies research bought or reset during the run, at once: tower boosts and discounts (existing
## towers too), masteries, refunds and ability recharge. The run-start bonuses change by the
## difference: credits are added or taken back (never below 0), and the core's shields too
## (never below 1). Masteries already bought stay bought.
func apply_research(owned: Array) -> void:
	var old_mods := run_mods
	research = Research.sanitize(owned)
	run_mods = Research.run_mods(research)
	for type in Towers.all_types():
		var price = tower_mods[type].get("price", Difficulty.price(difficulty))
		tower_mods[type] = Research.tower_mods(research, type)
		tower_mods[type]["price"] = price
	sell_refund = SELL_REFUND + float(run_mods.sell_refund)
	for t in towers:
		t.mods = tower_mods[t.type]
		t.invalidate()
	_recompute_buffs()
	gold = maxi(0, gold + start_gold(run_mods) - start_gold(old_mods))
	var shields := start_lives(difficulty, run_mods) - start_lives(difficulty, old_mods)
	max_lives = maxi(1, max_lives + shields)
	lives = clampi(lives + maxi(0, shields), 1, max_lives) if lives > 0 else lives


## Core shields a run starts with: the mode's shields plus the research bonus (a fraction, rounded
## down, so Cataclysm's single shield stays single).
static func start_lives(mode: String, mods: Dictionary) -> int:
	var base := Difficulty.lives(mode)
	return base + int(floor(float(base) * float(mods.get("lives", 0.0)) + 1e-6))


## The mode's last round; clearing it earns the medal and starts endless mode.
func final_round() -> int:
	return Difficulty.rounds(difficulty)


## Enemy HP multiplier for a round (the same on every sector and mode).
func hp_mult_for(w: int) -> float:
	return Waves.hp_scale(maxi(1, w)) * hp_factor


func speed_mult_for(w: int, boss := false) -> float:
	return Waves.speed_scale(maxi(1, w), boss)


# --- Queries -------------------------------------------------------------------------------

func is_over() -> bool:
	return state == State.GAMEOVER


func is_idle() -> bool:
	return spawn_queue.is_empty() and enemies.is_empty()


func can_save() -> bool:
	return state == State.BUILD and is_idle() and not sandbox


func can_start_wave() -> bool:
	if state == State.BUILD:
		return true
	return can_call_early()


func can_call_early() -> bool:
	if state != State.WAVE:
		return false
	if not endless and wave >= final_round():
		return false
	for s in spawn_queue:
		if int(s.wave) == wave:
			return false
	return true


func enemies_remaining() -> int:
	return enemies.size() + spawn_queue.size()


func preview_wave(n: int) -> Array:
	return Waves.get_wave(n)


## True if round `n` contains a boss.
func is_boss_round(n: int) -> bool:
	for g in preview_wave(n):
		if bool(Enemies.ENEMIES[g.t].get("boss", false)):
			return true
	return false


func tower_cost(type: String) -> int:
	return Research.discounted(int(Towers.Rework.TREES[type].cost), tower_mods[type])


func sell_value(t) -> int:
	if sandbox:
		return t.spent
	return int(floor(t.spent * maxf(sell_refund, t.refund_field)))


## A tower type's stock stats as they'd be in this run (research applied).
func level_stats(type: String, _tier := 1, _spec := "", _depth := 1) -> Dictionary:
	return Research.apply(Tower.rework_base(type), tower_mods[type])


func mastery_unlocked(type: String) -> bool:
	return bool(tower_mods[type].get("mastery", false))


func ability_cooldown(id: String) -> float:
	return float(Abilities.ABILITIES[id].cooldown) * (1.0 - float(run_mods.ability_cd))


## Open floor, high ground, power nodes, and rubble that has been cleared.
func is_buildable(cell: Vector2i) -> bool:
	return grid.is_buildable(cell) or (grid.tile_at(cell) == "R" and cleared.has(cell))


func rubble_cost() -> int:
	return int(map_def.get("rubble_cost", RUBBLE_COST))


func has_rubble(cell: Vector2i) -> bool:
	return grid.tile_at(cell) == "R" and not cleared.has(cell)


## Why this rubble can't be cleared right now, or "".
func rubble_error(cell: Vector2i) -> String:
	if is_over():
		return "The battle is over"
	if not has_rubble(cell):
		return "No rubble there"
	if gold < rubble_cost():
		return "Clearing rubble costs %d cr" % rubble_cost()
	return ""


func clear_rubble(cell: Vector2i) -> bool:
	if rubble_error(cell) != "":
		return false
	gold -= rubble_cost()
	cleared[cell] = true
	_emit({"type": "rubble_cleared", "pos": Grid.cell_center(cell), "cost": rubble_cost()})
	return true


## Tower bonus from the tile a tower stands on.
static func site_of(tile: String) -> String:
	return tile if tile in ["H", "P"] else ""


## Tiles along each side a tower type takes (1, or 2 for the Scrapyard and Drone Bay).
static func size_of(type: String) -> int:
	return int(Towers.def(type).get("size", 1))


## The tiles a tower of `type` with its top-left tile at `anchor` covers.
static func footprint(type: String, anchor: Vector2i) -> Array:
	var out: Array = []
	var n := size_of(type)
	for dy in n:
		for dx in n:
			out.append(anchor + Vector2i(dx, dy))
	return out


## The centre of that footprint, where the tower stands.
static func footprint_center(type: String, anchor: Vector2i) -> Vector2:
	return Grid.cell_rect(anchor).position + Vector2.ONE * Grid.TILE * float(size_of(type)) / 2.0


## A power node anywhere under the footprint wins, then high ground.
func footprint_site(type: String, anchor: Vector2i) -> String:
	var tiles: Array = footprint(type, anchor).map(func(c): return grid.tile_at(c))
	return "P" if tiles.has("P") else ("H" if tiles.has("H") else "")


# --- Switch gates ----------------------------------------------------------------------------

func gate_label(gi: int) -> String:
	var st := int(gates[gi])
	if st == 0:
		return "Split"
	return "%s only" % grid.groups[gi].labels[st - 1]


## Cycles a group's gate: split -> route 1 only -> route 2 only -> split. Ground enemies of that
## group still before the fork switch to the newly opened route on the spot.
func cycle_gate(gi: int) -> bool:
	if is_over() or gi < 0 or gi >= gates.size() or grid.groups[gi].fork == null:
		return false
	if float(gate_cd[gi]) > 0.0:
		return false
	var n: int = grid.groups[gi].routes.size()
	gates[gi] = (int(gates[gi]) + 1) % (n + 1)
	gate_cd[gi] = GATE_COOLDOWN
	var st := int(gates[gi])
	if st > 0:
		var open_route: int = grid.groups[gi].routes[st - 1]
		var fork_dist: float = grid.groups[gi].fork_dist
		for e in enemies:
			if e.alive and e.on_track() and grid.route_group[e.path_index] == gi and e.path_index != open_route and e.distance < fork_dist:
				_move_to_route(e, open_route)
	_emit({"type": "gate", "group": gi, "state": st, "pos": Grid.cell_center(grid.groups[gi].fork)})
	return true


func _move_to_route(e, route: int) -> void:
	e.curve = grid.ground_paths[route]
	e.path_len = maxf(1.0, e.curve.get_baked_length())
	e.path_index = route
	e.pos = e.curve.sample_baked(minf(e.distance, e.path_len))


## The route a new spawn of group `gi` takes: the forced route, or alternate when split.
func _pick_route(gi: int) -> int:
	var routes: Array = grid.groups[gi].routes
	var st := int(gates[gi]) if gi < gates.size() else 0
	if st > 0:
		return routes[st - 1]
	var r: int = routes[route_counters[gi] % routes.size()]
	route_counters[gi] += 1
	return r


func placement_error(type: String, cell: Vector2i) -> String:
	if is_over():
		return "The battle is over"
	for c in footprint(type, cell):
		if not Grid.in_bounds(c):
			return "Out of bounds"
		if grid.path_cells.has(c):
			return "Can't build on the lane"
		if has_rubble(c):
			return "Rubble: clear it first (%d cr)" % rubble_cost()
		if not is_buildable(c):
			return "That tile is blocked"
		if tower_at.has(c):
			return "Tile already has a tower"
	if gold < tower_cost(type):
		return "Not enough credits"
	return ""


# --- Player actions ------------------------------------------------------------------------

func place_tower(type: String, cell: Vector2i):
	if placement_error(type, cell) != "":
		return null
	var t = Tower.new()
	t.setup(type, cell, footprint_center(type, cell), tower_mods[type])
	t.site = footprint_site(type, cell)
	var bd := build_discount_at(t.pos) if not t.is_economy() else 0.0
	if bd > 0.0:
		t.spent = int(round(float(t.spent) * (1.0 - bd)))
	gold -= t.spent
	towers.append(t)
	if type == "artillery_cannon":
		aim_artillery(t, nearest_track_point(t.pos))
	if type == "cas_gunship":
		designate_orbit(t, nearest_track_point(t.pos))
	for c in footprint(type, cell):
		tower_at[c] = t
	stats["towers_built"] += 1
	_recompute_buffs()
	_emit({"type": "build", "pos": t.pos, "tower": type})
	return t


## Buys the next step on path `key` (the primary when empty).
func upgrade_tower(t, key := "") -> bool:
	if is_over():
		return false
	return _upgrade_path(t, key)


## Reworked towers: buys the next step on path `key` (the primary when empty).
func _upgrade_path(t, key: String) -> bool:
	var path: String = key if key != "" else t.primary()
	if path == "" or not t.can_buy(path):
		return false
	var cost: int = t.upgrade_cost(path)
	if cost <= 0 or gold < cost:
		return false
	var was_mastered: bool = t.mastered
	gold -= cost
	t.spent += cost
	t.buy(path)
	_recompute_buffs()
	_emit({"type": "upgrade", "pos": t.pos, "tier": t.tier, "spec": "", "branch": path, "depth": int(t.depth.get(path, 0)), "mastery": not was_mastered and t.mastered})
	return true


## Reworked towers: buys Retrofit option `option`; the choice is locked.
func buy_retrofit(t, option: int) -> bool:
	if is_over():
		return false
	var cost: int = t.retrofit_cost(option)
	if cost <= 0 or gold < cost:
		return false
	gold -= cost
	t.spent += cost
	t.buy_retrofit(option)
	_recompute_buffs()
	_emit({"type": "upgrade", "pos": t.pos, "tier": t.tier, "spec": "", "branch": "retrofit", "depth": option, "mastery": false})
	return true


func sell_tower(t) -> int:
	if is_over() or not tower_at.has(t.cell) or tower_at[t.cell] != t:
		return 0
	var value := sell_value(t)
	gold += value
	towers.erase(t)
	for c in footprint(t.type, t.cell):
		tower_at.erase(c)
	_recompute_buffs()
	_emit({"type": "sell", "pos": t.pos, "value": value})
	return value


func cycle_mode(t) -> void:
	t.mode = (t.mode + 1) % Tower.MODE_NAMES.size()


## Any -> Air -> Ground. Only matters for towers that hit both.
func cycle_priority(t) -> void:
	t.priority = (t.priority + 1) % Tower.PRIORITY_NAMES.size()
	# Air and Ground only mean something to a tower that hits both.
	while (t.priority == 1 or t.priority == 2) and not (t.hits_air() and t.hits_ground()):
		t.priority = (t.priority + 1) % Tower.PRIORITY_NAMES.size()


func start_wave() -> bool:
	if not can_start_wave():
		return false
	if state == State.WAVE:
		var bonus := Waves.early_call_bonus(wave + 1)
		_add_gold(bonus)
		_emit({"type": "early_call", "bonus": bonus})
	wave += 1
	state = State.WAVE
	auto_timer = 0.0
	var q := _queue_round(wave, wave)
	wave_remaining[wave] = q.total
	_emit({"type": "wave_start", "wave": wave, "boss": q.boss})
	return true


## Queues round `n`'s enemies at its strength, tagged `wave_id` (-1 for none: no clear bonus).
## Returns the enemy count and whether it holds a boss.
func _queue_round(n: int, wave_id: int) -> Dictionary:
	var hp_mult := hp_mult_for(n)
	var total := 0
	var boss := false
	var n_groups: int = grid.groups.size()
	for g in preview_wave(n):
		var etype: String = g.t
		var count := int(g.n)
		var interval := float(g.get("i", 1.0))
		var delay := float(g.get("d", 0.0))
		var is_boss := bool(Enemies.ENEMIES[etype].get("boss", false))
		if is_boss:
			boss = true
		var speed_mult := speed_mult_for(n, is_boss)
		var pack := 1 if g.has("m") else int(Enemies.ENEMIES[etype].get("pack", 1))
		var gap := float(Enemies.ENEMIES[etype].get("pack_gap", 0.0))
		for k in count:
			var lane: int = _spawn_counter % n_groups
			_spawn_counter += 1
			for p in pack:
				spawn_queue.append({
					"time": time + delay + k * interval + p * gap,
					"type": etype,
					"wave": wave_id,
					"group": lane,
					"hp_mult": hp_mult,
					"speed_mult": speed_mult,
					"mods": g.get("m", []),
				})
				total += 1
	spawn_queue.sort_custom(func(a, b): return a.time < b.time)
	return {"total": total, "boss": boss}


# --- Sandbox (design/sandbox.md) -------------------------------------------------------------

## Turns this run into a sandbox: credits pinned, shields never lost, nothing earned. Call right
## after construction.
func make_sandbox() -> void:
	sandbox = true
	gold = SANDBOX_GOLD


## Sends `n` of one enemy at round-1 strength (times the mode's factors), 0.4 s apart, alternating
## lanes. Stacks with whatever is on the field.
## With `mods`, each arrives as an elite carrying the ones it can take; returns the ones it can't (Modifiers.allowed).
func sandbox_spawn(type: String, n: int, mods: Array = []) -> Array:
	if not sandbox or is_over():
		return []
	var is_boss := bool(Enemies.ENEMIES[type].get("boss", false))
	var n_groups: int = grid.groups.size()
	var ok := mods.filter(func(m): return Modifiers.allowed(type, m))
	for k in n:
		spawn_queue.append({
			"time": time + k * 0.4,
			"type": type,
			"wave": -1,
			"group": _spawn_counter % n_groups,
			"hp_mult": hp_mult_for(1),
			"speed_mult": speed_mult_for(1, is_boss),
			"mods": ok.duplicate(),
		})
		_spawn_counter += 1
	spawn_queue.sort_custom(func(a, b): return a.time < b.time)
	state = State.WAVE
	return mods.filter(func(m): return not ok.has(m))


## Sends round `n`'s real wave without touching the round counter. Stacks with the field.
func sandbox_call_round(n: int) -> void:
	if not sandbox or is_over():
		return
	_queue_round(maxi(1, n), -1)
	state = State.WAVE


## Removes every enemy and pending spawn: no bounty, no leak.
func sandbox_clear_field() -> void:
	if not sandbox:
		return
	spawn_queue.clear()
	_new_enemies.clear()
	for e in enemies:
		e.alive = false
	enemies.clear()
	projectiles.clear()
	if state == State.WAVE and wave_remaining.is_empty():
		_on_field_clear()


## Buys upgrades on one branch of `t` until the rules (or the branch's end) stop it. Returns how many.
func sandbox_max_branch(t, key: String) -> int:
	var bought := 0
	while upgrade_tower(t, key):
		bought += 1
		if bought > 12:
			break
	return bought


## Switches a sandbox run's research: "all" (every node), "mine" (`mine`, the player's own) or "none".
func sandbox_set_research(mode: String, mine: Array) -> void:
	if not sandbox:
		return
	match mode:
		"all":
			apply_research(Research.node_ids())
		"mine":
			apply_research(mine)
		_:
			apply_research([])
	gold = SANDBOX_GOLD


## Rolls the DPS meters: each tower's damage over the last 5 s (sandbox only).
func _sample_dps(dt: float) -> void:
	_dps_clock += dt
	while _dps_clock >= DPS_BUCKET:
		_dps_clock -= DPS_BUCKET
		for t in towers:
			t.roll_dps(DPS_BUCKET, DPS_BUCKETS)


func ability_ready(id: String) -> bool:
	return state == State.WAVE and float(ability_cd.get(id, 0.0)) <= 0.0


## Why an ability can't be cast right now ("" if it can).
func ability_block_reason(id: String) -> String:
	if state != State.WAVE:
		return "Abilities can only be used during a round"
	var cd := float(ability_cd.get(id, 0.0))
	if cd > 0.0:
		return "%s is recharging (%ds)" % [Abilities.ABILITIES[id].name, ceili(cd)]
	return ""


func cast_meteor(pos: Vector2) -> bool:
	if not ability_ready("meteor"):
		return false
	var a: Dictionary = Abilities.ABILITIES.meteor
	ability_cd["meteor"] = 0.0 if sandbox else ability_cooldown("meteor")
	var strike := {
		"pos": pos, "t": float(a.delay), "radius": float(a.radius),
		"damage": float(a.damage) * Waves.hp_scale(maxi(1, wave)),
	}
	strikes.append(strike)
	_emit({"type": "meteor_cast", "pos": pos, "delay": float(a.delay), "radius": float(a.radius)})
	return true


func cast_warp() -> bool:
	if not ability_ready("warp"):
		return false
	var a: Dictionary = Abilities.ABILITIES.warp
	ability_cd["warp"] = 0.0 if sandbox else ability_cooldown("warp")
	warp_timer = float(a.duration)
	_emit({"type": "warp", "duration": warp_timer})
	return true


# --- Simulation ----------------------------------------------------------------------------

func tick(dt: float) -> void:
	if is_over():
		return
	for gi in gate_cd.size():
		gate_cd[gi] = maxf(0.0, float(gate_cd[gi]) - dt)
	time += dt
	if sandbox:
		gold = SANDBOX_GOLD
		_sample_dps(dt)
	if state == State.BUILD:
		for t in towers:
			t.sweep_angles = []
		if auto_start:
			auto_timer += dt
			if auto_timer >= AUTO_START_DELAY:
				start_wave()
		return

	while not spawn_queue.is_empty() and float(spawn_queue[0].time) <= time:
		var s: Dictionary = spawn_queue.pop_front()
		enemies.append(spawn_enemy(s.type, _pick_route(int(s.get("group", 0))), 0.0, float(s.hp_mult), int(s.wave), float(s.get("speed_mult", 1.0)), s.get("mods", [])))

	_update_abilities(dt)
	_update_pools(dt)
	_update_smokes(dt)
	_update_storms(dt)
	_update_boost_state()
	_update_trails(dt)
	_update_mines(dt)
	_update_soaks(dt)

	_update_auras()
	for e in enemies:
		if e.alive:
			_update_enemy(e, dt)
			if state == State.GAMEOVER:
				return
	if not _new_enemies.is_empty():
		enemies.append_array(_new_enemies)
		_new_enemies.clear()

	for t in towers:
		_update_tower(t, dt)
	for p in projectiles:
		if p.alive:
			_update_projectile(p, dt)
	if not _new_enemies.is_empty():
		enemies.append_array(_new_enemies)
		_new_enemies.clear()

	enemies = enemies.filter(func(e): return e.alive)
	projectiles = projectiles.filter(func(p): return p.alive)

	if state == State.WAVE and is_idle():
		_on_field_clear()


## Creates an enemy on a path at a distance. Does not add it to `enemies` (callers decide).
func spawn_enemy(type: String, path_idx: int, start_dist := 0.0, hp_mult := 1.0, wave_id := -1, speed_mult := 1.0, mods: Array = []):
	var e = Enemy.new()
	# Flyers take the straight flight line, except those that fly along the track (the Phantom).
	var d: Dictionary = Enemies.ENEMIES[type]
	var air_line := bool(d.get("flying", false)) and not bool(d.get("track", false))
	var route: Curve2D = grid.air_paths[path_idx] if air_line else grid.ground_paths[path_idx]
	e.setup(type, route, hp_mult, wave_id, path_idx, start_dist, speed_mult, mods)
	e.id = _next_enemy_id
	_next_enemy_id += 1
	if e.boss:
		_emit({"type": "boss_spawn", "enemy": type, "pos": e.pos})
	return e


## Deals damage after vulnerability, energy barrier and armor. Returns the damage actually dealt.
## A barrier soaks damage before armor applies; Tesla Tower arcs hit barriers twice as hard.
## `kind` overrides the hit's damage kind ("energy" for burns, acid and shock strips); by default a tower's hits are its own kind
## and everything else is physical. An energy-only enemy (the Wraith) takes nothing from physical hits.
func damage_enemy(e, amount: float, pierce: bool, source, flash := true, bypass_shield := false, reach_burrowed := false, no_aug := false, kind := "") -> float:
	if not e.alive or (e.burrowed and not reach_burrowed):
		return 0.0
	e.last_hit_kind = kind if kind != "" else (source.damage_kind() if source is Tower else "physical")
	var amt := amount
	if source is Tower and not no_aug:
		# The Augmentation Tower and the Boost Tower's Crit Link: a crit chance on every hit (continuous damage gets the average), and a share
		# of the damage counts as energy.
		if source.buff_crit > 0.0:
			if flash:
				if _roll(source.buff_crit):
					amt *= source.aug_crit_mult
			else:
				amt *= 1.0 + source.buff_crit * (source.aug_crit_mult - 1.0)
		if source.aug_energy > 0.0 and (source.aug_energy >= 1.0 or _roll(source.aug_energy)):
			e.last_hit_kind = "energy"
			if source.aug_energy_bonus > 0.0 and source.aug_energy >= 1.0:
				amt *= 1.0 + source.aug_energy_bonus
	if e.has_trait("energy_only") and e.last_hit_kind != "energy":
		return 0.0
	e.since_hit = 0.0
	if e.vuln_timer > 0.0:
		amt *= 1.0 + e.vuln_amount
	var absorbed := 0.0
	if e.shield > 0.0 and not bypass_shield:
		var mult := 1.0
		if source is Tower:
			mult = (SHIELD_EMP_MULT if source.type == "tesla_tower" else 1.0) * float(source.stats().get("shield_mult", 1.0))
		absorbed = minf(e.shield, amt * mult)
		e.shield -= absorbed
		e.shield_timer = float(e.def.get("shield_delay", 0.0))
		amt -= absorbed / mult
		if e.shield <= 0.0:
			_emit({"type": "shield_break", "pos": e.pos})
		if amt <= 0.0001:
			if flash:
				e.hit_flash = 0.08
			if source != null:
				source.damage_dealt += absorbed
			return absorbed
	if e.is_hidden():
		# A blast, field or arc landing on a hidden enemy makes its cloak flicker, so other towers
		# can follow up. Hits while already visible do not extend it.
		e.reveal_timer = maxf(e.reveal_timer, HIT_REVEAL_TIME)
	var dealt := Enemy.mitigate(amt, _armor_vs(e, source), pierce)
	if source != null:
		source.damage_dealt += absorbed
	e.hp -= dealt
	if flash:
		e.hit_flash = 0.08
	if source != null:
		source.damage_dealt += dealt
	if e.hp <= 0.0:
		_kill(e, source)
	else:
		if e.has_trait("phases"):
			_check_phase(e)
		_check_thresholds(e)
	return dealt + absorbed


## An enemy's armour as a source sees it: a tower with armour piercing ignores a flat amount and a share of it.
func _armor_vs(e, source) -> float:
	var a: float = e.effective_armor()
	if source is Tower:
		var s: Dictionary = source.stats()
		a = maxf(0.0, a - float(s.get("armor_flat", 0.0))) * (1.0 - clampf(float(s.get("armor_pct", 0.0)), 0.0, 1.0))
	return a


## Damage already on its way to `e` from shots in flight (Swivel Mount doesn't waste rounds on enemies about to die).
func _incoming(e) -> float:
	var sum := 0.0
	for p in projectiles:
		if p.alive and p.target == e:
			sum += p.damage
	return sum


## Best target in range for the tower's targeting mode, skipping anything in `exclude`.
func pick_target(t, exclude: Array = []):
	var air: bool = t.hits_air()
	var ground: bool = t.hits_ground()
	# A tower can prefer flyers or walkers (if it hits both) or Support enemies; with none of those in range it takes the rest.
	if t.priority == 3 or (air and ground and t.priority != 0):
		var pick = _pick_target(t, exclude, air, ground, true)
		if pick != null:
			return pick
	return _pick_target(t, exclude, air, ground)


## Whether `e` is what the tower's priority asks for: Air flyers, Ground walkers, Support the Support role (Any takes all).
func _prefers(t, e) -> bool:
	match t.priority:
		1:
			return e.flying
		2:
			return not e.flying
		3:
			return e.shown_role() == "support"
	return true


## Sorts `cands` best first: the tower's priority first, then its targeting mode (distances measured from `from`).
func _rank_targets(t, cands: Array, from: Vector2) -> void:
	var scores := {}
	for e in cands:
		scores[e] = _score(t, e, from.distance_squared_to(e.pos))
	var pref := {}
	if t.priority != 0:
		for e in cands:
			pref[e] = _prefers(t, e)
	cands.sort_custom(func(a, b): return pref.get(a, false) and not pref.get(b, false) or (pref.get(a, false) == pref.get(b, false) and scores[a] > scores[b]))


func _pick_target(t, exclude: Array, air: bool, ground: bool, preferred := false):
	var r: float = t.get_range()
	var r2 := r * r
	var best = null
	var best_score := Vector3(-INF, -INF, -INF)
	var swivel: bool = bool(t.stats().get("swivel", false))
	for e in enemies:
		if not e.alive or (e.flying and not air) or (not e.flying and not ground) or (e.is_hidden() and not _burrow_visible(t, e)) or exclude.has(e):
			continue
		if preferred and not _prefers(t, e):
			continue
		var d2: float = t.pos.distance_squared_to(e.pos)
		if d2 > r2:
			continue
		if swivel and _incoming(e) >= e.hp:
			continue
		var score := _score(t, e, d2)
		if score > best_score:
			best_score = score
			best = e
	return best


## How good a target `e` is for the tower's mode (higher is better; Vector3s compare x, then y, then z). Strongest goes by
## strength rank, then current HP, then progress.
func _score(t, e, d2: float) -> Vector3:
	if t.mode == Tower.Mode.FIRST:
		return Vector3(e.progress(), 0.0, 0.0)
	if t.mode == Tower.Mode.LAST:
		return Vector3(-e.progress(), 0.0, 0.0)
	if t.mode == Tower.Mode.STRONG:
		return strength_key(e)
	return Vector3(-d2, 0.0, 0.0)


## Orders enemies for Strongest: strength rank (bosses above all), then current HP, then progress along the route.
static func strength_key(e) -> Vector3:
	return Vector3(e.rank, e.hp, e.progress())


func _update_enemy(e, dt: float) -> void:
	e.step(dt)
	var d: Dictionary = e.def
	if e.has_trait("burrow"):
		_trait_burrow(e, d, dt)
	if not e.flying and not e.burrowed and not grid.hazards.is_empty():
		match grid.hazards.get(Grid.world_to_cell(e.pos), ""):
			"sludge":
				e.apply_slow(SLUDGE_SLOW, 0.2)
			"shock":
				damage_enemy(e, e.max_hp * (SHOCK_BOSS_PCT if e.boss else SHOCK_PCT) * dt, true, null, false, false, false, false, "energy")
				if not e.alive:
					return
	if e.dot_timer > 0.0:
		damage_enemy(e, e.dot_dps * dt, true, null, false, false, false, false, "energy")
		if not e.alive:
			return
	# Timed traits (EnemyTraits), each on its own timer. A silenced trait's timer holds.
	for tr in e.traits:
		match tr:
			"blink":
				if e.stun_timer <= 0.0 and not e.silenced() and e.disrupt_timer <= 0.0 and e.tick_trait("blink", dt):
					_trait_blink(e, d)
			"heal":
				if not e.silenced() and e.tick_trait("heal", dt):
					_trait_heal(e, d)
			"summon":
				if not e.silenced(2) and e.tick_trait("summon", dt):
					e.mark("summon")
					_spawn_minions(e, str(d.spawn_type), int(d.spawn_count))
					_emit({"type": "minions", "pos": e.pos, "enemy": e.type})
			"emp":
				if e.charge_timer > 0.0:
					# Capacitor: the telegraphed charge. A stun or silence cancels it; when it runs out, the pulse.
					if e.silenced(2) or e.stun_timer > 0.0:
						_cancel_charge(e)
					else:
						e.charge_timer = maxf(0.0, e.charge_timer - dt)
						if e.charge_timer <= 0.0:
							_trait_emp(e, d)
				elif not e.silenced(2) and e.tick_trait("emp", dt):
					if d.has("emp_charge"):
						e.charge_timer = float(d.emp_charge)
						_emit({"type": "charge", "pos": e.pos, "radius": float(d.emp_radius), "time": e.charge_timer})
					else:
						_trait_emp(e, d)
			"grant":
				if not e.silenced() and e.tick_trait("grant", dt):
					_trait_grant(e, d)
			"holo":
				if not e.silenced() and e.tick_trait("holo", dt):
					_trait_holo(e, d)
	if e.reached_end():
		if e.hologram:
			_vanish(e)
		else:
			_leak(e)


## Burrower: dives for burrow_time, then surfaces for the rest of the interval.
func _trait_burrow(e, d: Dictionary, dt: float) -> void:
	var grounded: bool = e.silenced() or e.no_dig > 0.0 or e.disrupt_timer > 0.0
	if grounded and e.burrowed:
		e.burrowed = false
		e.mark("burrow")
		e.burrow_timer = float(d.burrow_interval) - float(d.burrow_time)
		_emit({"type": "burrow", "pos": e.pos, "down": false})
	if not grounded:
		e.burrow_timer -= dt
	if not grounded and e.burrow_timer <= 0.0:
		e.burrowed = not e.burrowed
		e.mark("burrow")
		e.burrow_timer = float(d.burrow_time) if e.burrowed else float(d.burrow_interval) - float(d.burrow_time)
		_emit({"type": "burrow", "pos": e.pos, "down": e.burrowed})


## Blink Stalker: jumps ahead along its route (a slow or stun resets the charge, in Enemy).
func _trait_blink(e, d: Dictionary) -> void:
	var from: Vector2 = e.pos
	e.mark("blink")
	e.distance = minf(e.distance + float(d.blink_distance), e.path_len)
	e.pos = e.curve.sample_baked(e.distance)
	_emit({"type": "blink", "from": from, "pos": e.pos})
	if e.has_trait("wake"):
		# Shifter: where it lands, other non-boss enemies get a burst of speed (refreshed, never added).
		var wr := float(d.wake_radius)
		for o in enemies:
			if o != e and o.alive and not o.boss and o.pos.distance_squared_to(e.pos) <= wr * wr:
				o.wake = float(d.wake_haste)
				o.wake_timer = float(d.wake_time)
		_emit({"type": "wake", "pos": e.pos, "radius": wr})


## Repair Bot: repairs every damaged non-boss enemy nearby.
func _trait_heal(e, d: Dictionary) -> void:
	e.mark("heal")
	var heal_r: float = d.heal_radius
	var healed := false
	for o in enemies:
		if o.alive and not o.boss and o.hp < o.max_hp and o.repair_block <= 0.0 and o.jam_timer <= 0.0 and o.pos.distance_squared_to(e.pos) <= heal_r * heal_r:
			o.hp = minf(o.max_hp, o.hp + o.max_hp * float(d.heal_pct))
			healed = true
	_emit({"type": "heal", "pos": e.pos, "radius": heal_r, "active": healed})


## Jammer: an EMP that knocks nearby towers offline (a Drone Bay's wing and a CAS Gunship's orbit count as nearby).
func _trait_emp(e, d: Dictionary) -> void:
	e.mark("emp")
	var er := float(d.emp_radius)
	var hit := 0
	for t in towers:
		if t.disable_guard > 0.0 and t.disabled <= 0.0:
			continue
		if t.pos.distance_squared_to(e.pos) <= er * er or (t.type == "drone_bay" and t.wing.any(func(dr): return dr.pos.distance_squared_to(e.pos) <= er * er)) or (t.type == "cas_gunship" and t.aim_point.distance_to(e.pos) <= er + float(t.stats().get("orbit", 90.0))):
			t.disabled = maxf(t.disabled, float(d.emp_duration))
			hit += 1
	_emit({"type": "emp", "pos": e.pos, "radius": er, "hit": hit})


## Bulwark: projects a barrier onto nearby non-boss enemies (not itself).
func _trait_grant(e, d: Dictionary) -> void:
	e.mark("grant")
	var gr := float(d.grant_radius)
	var n := 0
	for o in enemies:
		if o == e or not o.alive or o.boss or o.grant_block > 0.0 or o.jam_timer > 0.0 or o.pos.distance_squared_to(e.pos) > gr * gr:
			continue
		var b: float = o.max_hp * float(d.grant_pct)
		if o.shield < b:
			o.shield = b
			o.max_shield = maxf(o.max_shield, b)
			n += 1
	_emit({"type": "bulwark", "pos": e.pos, "radius": gr, "count": n})


## Capacitor: its charge is cancelled (a stun, a silence, or an Overload Circuits arc); the next one comes a full interval later.
func _cancel_charge(e) -> void:
	if e.charge_timer <= 0.0:
		return
	e.charge_timer = 0.0
	_emit({"type": "charge_cancel", "pos": e.pos})


## Mirage: projects translucent 1-HP copies just behind it. They walk to the core and vanish there (never leaking, never paying),
## vanish with their Mirage, and count toward its round.
func _trait_holo(e, d: Dictionary) -> void:
	e.mark("holo")
	var n := int(d.holo_count)
	for k in n:
		var h = spawn_enemy(e.type, e.path_index, maxf(0.0, e.distance - 14.0 * (k + 1)), 1.0, e.wave_id, speed_mult_for(e.wave_id) if e.wave_id > 0 else 1.0)
		h.make_hologram(e)
		_new_enemies.append(h)
	if wave_remaining.has(e.wave_id):
		wave_remaining[e.wave_id] += n
	_emit({"type": "holograms", "pos": e.pos, "count": n})


## Health thresholds, each crossed once: the Fury Drone's adrenaline, the Titan's plate shed, the Masquerade dropping its disguise.
func _check_thresholds(e) -> void:
	var d: Dictionary = e.def
	if e.has_trait("adrenaline") and e.rush <= 1.0 and e.hp < e.max_hp * float(d.adrenaline_at):
		e.rush = 1.0 + float(d.adrenaline)
		_emit({"type": "adrenaline", "pos": e.pos})
	if e.has_trait("shed") and not e.shed and e.hp < e.max_hp * float(d.shed_at):
		e.shed = true
		e.mark("shed")
		e.armor = maxf(0.0, e.armor - (float(Enemies.ENEMIES[e.type].armor) - float(d.shed_armor)))
		e.speed *= float(d.shed_speed)
		_emit({"type": "shed", "pos": e.pos, "enemy": e.type})
	if e.disguised and e.hp < e.max_hp * float(d.reveal_at):
		e.reveal_disguise()
		_emit({"type": "unmask", "pos": e.pos, "enemy": e.type})


## A hologram leaves the field: no leak, no bounty.
func _vanish(e) -> void:
	e.alive = false
	_enemy_removed(e)


## Rally Beacons: every other non-boss enemy near one moves faster. Recomputed each tick.
func _update_auras() -> void:
	var beacons: Array = []
	for e in enemies:
		e.haste = 0.0
		if e.alive and e.has_trait("aura") and not e.silenced():
			beacons.append(e)
	for b in beacons:
		var r := float(b.def.aura_radius)
		var h := float(b.def.aura_haste)
		for o in enemies:
			if o != b and o.alive and not o.boss and o.jam_timer <= 0.0 and o.pos.distance_squared_to(b.pos) <= r * r:
				o.haste = maxf(o.haste, h)
	# Siphons: towers inside the aura fire slower and reach less far; the strongest Siphon applies.
	for t in towers:
		t.debuff_rate = 0.0
		t.debuff_range = 0.0
	for e in enemies:
		if not e.alive or not e.has_trait("siphon") or e.silenced() or e.hologram:
			continue
		var sr := float(e.def.siphon_radius)
		for t in towers:
			if t.pos.distance_squared_to(e.pos) <= sr * sr:
				t.debuff_rate = maxf(t.debuff_rate, float(e.def.siphon_rate))
				t.debuff_range = maxf(t.debuff_range, float(e.def.siphon_range))


## Colossus: passing a health threshold sheds armor, speeds it up and drops escorts.
func _check_phase(e) -> void:
	var th: Array = e.def.phases
	while e.phase < th.size() and e.hp <= e.max_hp * float(th[e.phase]):
		e.phase += 1
		e.mark("phase%d" % e.phase)
		e.armor = maxf(0.0, e.armor - float(e.def.phase_armor))
		e.speed *= float(e.def.phase_speed)
		_spawn_minions(e, str(e.def.phase_spawn), int(e.def.phase_spawn_count))
		_emit({"type": "phase", "pos": e.pos, "phase": e.phase, "enemy": e.type})


## Spawns `n` enemies of `type` just behind `e` on its route, at its round's strength. They join
## after this tick's loops and count toward its round.
func _spawn_minions(e, type: String, n: int) -> void:
	var hp := hp_mult_for(e.wave_id)
	var sp := speed_mult_for(e.wave_id)
	for k in n:
		_new_enemies.append(spawn_enemy(type, e.path_index, maxf(0.0, e.distance - 14.0 * (k + 1)), hp, e.wave_id, sp))
	if wave_remaining.has(e.wave_id):
		wave_remaining[e.wave_id] += n



func _update_tower(t, dt: float) -> void:
	t.fire_flash = maxf(0.0, t.fire_flash - dt)
	t.disable_guard = maxf(0.0, t.disable_guard - dt)
	if t.disabled > 0.0:
		t.disabled = maxf(0.0, t.disabled - dt)
		if t.disabled <= 0.0:
			t.disable_guard = DISABLE_GUARD
		t.target = null
		t.beam_targets.clear()
		t.beam_ramps.clear()
		t.sweep_angles = []
		t.ramp = 0.0
		t.ramp_mult = 1.0
		return
	if t.is_economy():
		return
	var s: Dictionary = t.stats()
	if t.is_support():
		_support_field(t, s)
		return
	if t.type == "drone_bay":
		_update_drone_bay(t, s, dt)
		return
	if t.type == "cas_gunship":
		_update_cas(t, s, dt)
		return
	if t.type == "mine_layer":
		_update_mine_layer(t, s, dt)
		return
	if t.type == "boost_tower":
		return
	if t.type == "augmentation_tower":
		return
	if t.type == "magneto_tower":
		_update_magneto(t, s, dt)
		return
	if t.type == "tractor_tower":
		_update_tractor(t, s, dt)
		return
	if t.type == "radar_tower":
		_update_radar(t, s, dt)
		return
	if t.type == "shockwave_generator":
		_update_shockwave(t, s, dt)
		return
	if t.is_beam():
		_update_laser_rework(t, s, dt)
		return
	if t.target != null and not t.can_target(t.target):
		t.target = null
	t.cooldown -= dt
	if t.cooldown > 0.0:
		return

	match t.type:
		"chemical_plant":
			_spray(t, s)
			return
		"cryo_tower":
			_cryo_wave(t, s)
			return
		"rocket_salvo":
			_fire_salvo(t, s)
			return
		"artillery_cannon":
			_fire_artillery(t, s)
			return

	var target = pick_target(t)
	t.target = target
	if target == null:
		t.cooldown = RETARGET_DELAY
		return
	t.cooldown = 1.0 / t.eff_rate()
	t.fire_flash = 0.12
	t.aim = (target.pos - t.pos).angle()
	match t.type:
		"gun_turret":
			_fire_gun(t, target, s)
		"mortar_tower":
			_fire_mortar(t, target, s)
		"railgun":
			_fire_railgun(t, target, s)
		"tesla_tower":
			_chain_rework(t, target, s)
		"anti_aircraft_turret":
			t.pulse_count += 1
			_fire_projectile(t, target, s)


## The point on any lane nearest to `pos`.
func nearest_track_point(pos: Vector2) -> Vector2:
	var best := pos
	var bd := INF
	for curve in grid.ground_paths:
		var q: Vector2 = curve.get_closest_point(pos)
		var d: float = q.distance_squared_to(pos)
		if d < bd:
			bd = d
			best = q
	return best


## Aims an Artillery Cannon at the lane point nearest `pos` (free, any time).
func aim_artillery(t, pos: Vector2) -> void:
	t.aim_point = nearest_track_point(pos)
	t.aim_set = true
	t.aim = (t.aim_point - t.pos).angle()


## Loads a shell type, if the cannon has unlocked it. Takes effect from the next shell.
## Augmentation Tower: every attacking tower in range (not Support or Economy towers) takes the strongest of each effect: crit chance and
## multiplier, energy conversion, ricochet. Remote Link extends the reach to twice the radius at half strength.
func _apply_augmentation(a, s: Dictionary, r: float) -> void:
	var remote := bool(s.get("remote_link", false))
	for t in towers:
		if t == a or t.is_support() or t.is_economy() or not t.stats().has("damage"):
			continue
		var d2: float = a.pos.distance_squared_to(t.pos)
		var f := 1.0
		if d2 > r * r:
			if not remote or d2 > 4.0 * r * r:
				continue
			f = 0.5
		t.buff_crit = maxf(t.buff_crit, float(s.get("aug_crit", 0.0)) * f)
		t.aug_crit_mult = maxf(t.aug_crit_mult, 1.0 + (float(s.get("crit_mult", 2.0)) - 1.0) * f)
		t.aug_energy = maxf(t.aug_energy, float(s.get("energy_conv", 0.0)) * f)
		t.aug_energy_bonus = maxf(t.aug_energy_bonus, float(s.get("energy_bonus", 0.0)) * f)
		t.aug_ricochet = maxf(t.aug_ricochet, float(s.get("ricochet", 0.0)) * f)
		t.aug_ricochet_str = maxf(t.aug_ricochet_str, float(s.get("ricochet_str", 0.5)))
		t.aug_bounce_again = t.aug_bounce_again or bool(s.get("bounce_again", false))


## A ricochet: a single-target hit bounces to another enemy within 60 px at a share of its damage; with Pinball a bounce can bounce again.
func _ricochet(source, from, dmg: float, depth := 0) -> void:
	if source == null or not (source is Tower) or source.aug_ricochet <= 0.0 or depth > 3:
		return
	if depth > 0 and not source.aug_bounce_again:
		return
	if not _roll(source.aug_ricochet):
		return
	var best = null
	var bd := 60.0 * 60.0
	for e in enemies:
		if e.alive and e != from and not e.is_hidden():
			var d2: float = e.pos.distance_squared_to(from.pos)
			if d2 <= bd:
				bd = d2
				best = e
	if best == null:
		return
	var bdmg: float = dmg * source.aug_ricochet_str
	damage_enemy(best, bdmg, false, source, true, false, false, true)
	_emit({"type": "ricochet", "from": from.pos, "to": best.pos})
	_ricochet(source, best, bdmg, depth + 1)


## Magneto Tower: a constant field slows every enemy inside, air and ground, scaled by the enemy's role weight (heavier roles resist more;
## Pull Strength and the Pole Shoes make them resist less). Polarity pulls armour off while they are inside (for good with Torn Plates);
## Reverse Polarity flips the field every few seconds and flings enemies together for damage and a short stun.
func _update_magneto(t, s: Dictionary, dt: float) -> void:
	var r: float = t.get_range()
	var slow := float(s.slow)
	var relief := float(s.get("grip_relief", 0.0))
	var shoes := float(s.get("pole_shoes", 0.0))
	var pull := float(s.get("armor_pull", 0.0))
	var perm := bool(s.get("pull_perm", false))
	var inside := _enemies_near(t.pos, r, t.hits_air(), t.hits_ground())
	for e in inside:
		var resist: float = e.role_resist() * (1.0 - shoes) * (1.0 - relief)
		e.apply_slow(slow * (1.0 - resist), 0.25)
		if pull > 0.0:
			if perm:
				e.armor_shred = maxf(e.armor_shred, pull)
			else:
				e.armor_break = maxf(e.armor_break, pull)
				e.armor_break_timer = maxf(e.armor_break_timer, 0.3)
	var every := float(s.get("flip_every", 0.0))
	if every > 0.0:
		t.cooldown -= dt
		if t.cooldown <= 0.0:
			t.cooldown = every
			t.pulse_count += 1
			var hit := 0
			for e in inside:
				var crowded := false
				for o in inside:
					if o != e and o.pos.distance_squared_to(e.pos) <= 24.0 * 24.0:
						crowded = true
						break
				if crowded:
					damage_enemy(e, float(s.get("flip_damage", 40.0)), true, t)
					if e.alive:
						e.apply_stun(0.3 * _boss_factor(e))
					hit += 1
			t.fire_flash = 0.4
			_emit({"type": "magneto_flip", "pos": t.pos, "radius": r, "hit": hit, "look": t.look_key()})


## Tractor Tower: locks one enemy (by the targeting mode), holds it (a stun) while hauling it back along the track, releases it, then recharges.
## The pull scales with the enemy's role weight; Rewind sends it back to where it was a few seconds ago; Undo (once a round) sends one non-boss enemy
## back to the start of its track segment. While held it can take crushing damage and lose its barrier and abilities; Lift and Drop stuns what
## it lands among.
func _update_tractor(t, s: Dictionary, dt: float) -> void:
	var cds: Dictionary = t.gun_cds
	var held = t.target
	if held != null and (not held.alive or not t.can_target(held)) and float(cds.get("hold_left", 0.0)) > 0.0:
		cds["hold_left"] = 0.0
		held = null
	if held != null and float(cds.get("hold_left", 0.0)) > 0.0:
		cds["hold_left"] = float(cds.hold_left) - dt
		held.set_distance(held.distance - float(cds.get("pull_rate", 0.0)) * dt)
		held.apply_stun(0.2)
		if float(s.get("grip_dps", 0.0)) > 0.0:
			damage_enemy(held, float(s.grip_dps) * dt, true, t, false)
		if bool(s.get("grip_lock", false)):
			held.barrier_block = maxf(held.barrier_block, 0.3)
			held.suppress_timer = maxf(held.suppress_timer, 0.3)
		if float(s.get("beam_slow", 0.0)) > 0.0:
			for e in enemies:
				if e.alive and e != held and Geometry2D.get_closest_point_to_segment(e.pos, t.pos, held.pos).distance_to(e.pos) <= e.radius + 6.0:
					e.apply_slow(float(s.beam_slow), 0.3)
		if float(cds.hold_left) <= 0.0:
			_tractor_release(t, s, held)
		return
	t.cooldown -= dt
	if t.cooldown > 0.0:
		return
	var target = pick_target(t)
	if target == null:
		t.target = null
		t.cooldown = RETARGET_DELAY
		return
	t.target = target
	t.aim = (target.pos - t.pos).angle()
	var share: float = 1.0 - target.role_resist() * (1.0 - float(s.get("grip_relief", 0.0)))
	var hold := float(s.hold) * (0.5 if target.boss else 1.0)
	var back: float = float(s.pull) * share
	if float(s.get("rewind", 0.0)) > 0.0:
		back = maxf(0.0, target.distance - target.distance_ago(float(s.rewind))) * share
	if bool(s.get("undo", false)) and not target.boss and int(cds.get("undo_wave", -1)) != wave:
		cds["undo_wave"] = wave
		back = maxf(back, target.distance - _segment_start(target))
	cds["hold_left"] = hold
	cds["pull_rate"] = back / maxf(hold, 0.1)
	t.fire_flash = 0.2
	_emit({"type": "tractor_lock", "from": t.pos, "to": target.pos, "look": t.look_key()})


func _tractor_release(t, s: Dictionary, held) -> void:
	t.cooldown = float(s.recharge)
	t.gun_cds["hold_left"] = 0.0
	var radius := float(s.get("slam_radius", 0.0))
	if radius > 0.0 and not held.flying:
		for e in _enemies_near(held.pos, radius, false, true):
			e.apply_stun(float(s.get("slam_stun", 0.4)) * _boss_factor(e))
			if bool(s.get("slam_shatter", false)) and e.max_shield > 0.0:
				e.shield = 0.0
		_emit({"type": "tractor_slam", "pos": held.pos, "radius": radius, "look": t.look_key()})
	t.target = null


## The distance along its route of the start of the segment an enemy is on (its last waypoint), for the Undo.
func _segment_start(e) -> float:
	var best := 0.0
	if e.path_index >= 0 and e.path_index < grid.waypoints.size():
		for pt in grid.waypoints[e.path_index]:
			var off: float = e.curve.get_closest_offset(Grid.cell_center(pt))
			if off <= e.distance - 2.0:
				best = maxf(best, off)
	return best


## Boost fields switch off while an EMP has the Boost Tower down: recompute when any support tower's offline state changes.
func _update_boost_state() -> void:
	var sig := 0
	for i in towers.size():
		if towers[i].is_support() and towers[i].disabled > 0.0:
			sig += 1 << mini(i, 30)
	if sig != _boost_sig:
		_boost_sig = sig
		_recompute_buffs()


## Radar Tower: every ping_every seconds it pings, and for reveal_time seconds the cloaked enemies in range are revealed and the burrowed ones
## show (towers that can hit underground may target them); the Constant Track keeps everything revealed. The radiation circle (Radiation
## Emitter and on) burns every enemy inside it that is revealed, for as long as it is in the circle. Several radars don't stack.
func _update_radar(t, s: Dictionary, dt: float) -> void:
	var constant := bool(s.get("constant", false))
	var left := float(t.gun_cds.get("ping", 0.0)) - dt
	t.cooldown -= dt
	if not constant and t.cooldown <= 0.0:
		t.cooldown = float(s.get("ping_every", 3.0))
		left = float(s.get("reveal_time", 1.0))
		t.fire_flash = 0.5
		t.pulse_count += 1
		_emit({"type": "radar_ping", "pos": t.pos, "radius": t.get_range(), "look": t.look_key()})
	t.gun_cds["ping"] = maxf(0.0, left)
	var r: float = t.get_range()
	var active: bool = constant or left > 0.0
	if active:
		var hold := 0.3 if constant else left
		for e in _enemies_near(t.pos, r, true, true, true):
			if e.cloaked:
				e.reveal_timer = maxf(e.reveal_timer, hold)
	var dps := float(s.get("rad_dps", 0.0))
	if dps > 0.0:
		for e in _enemies_near(t.pos, float(s.get("rad_range", 60.0)), true, true, false):
			damage_enemy(e, dps * dt, true, t, false)


## Shockwave Generator: a wave every 1/rate seconds hits every enemy in its radius, air and ground, cloaked ones too (it needs no
## reveal; the hit reveals them briefly). Armour applies. Barriers take shield_mult times as much; the Shatter Shock halves what is
## left of a barrier it hits and keeps it from regenerating for a while.
func _update_shockwave(t, s: Dictionary, dt: float) -> void:
	t.cooldown -= dt
	if t.cooldown > 0.0:
		return
	var r: float = t.get_range()
	var any := false
	for e in _enemies_near(t.pos, r, true, true, true):
		any = true
		var dealt := damage_enemy(e, t.eff_damage(), false, t)
		_emit({"type": "hit", "pos": e.pos, "amount": dealt, "kind": "cannon"})
		if e.alive and bool(s.get("shatter_half", false)) and e.max_shield > 0.0 and e.shield > 0.0:
			e.shield *= 0.5
			e.barrier_block = maxf(e.barrier_block, float(s.get("regen_block", 5.0)))
	t.cooldown = 1.0 / t.eff_rate() if any else RETARGET_DELAY
	if any:
		t.fire_flash = 0.3
		t.pulse_count += 1
		t.gun_cds["wave_t"] = time
		_emit({"type": "shockwave", "pos": t.pos, "radius": r, "look": t.look_key()})


## The build discount of the best Scrapyard field covering `pos` (0 if none).
func build_discount_at(pos: Vector2) -> float:
	var best := 0.0
	for a in towers:
		if a.is_economy() and a.pos.distance_squared_to(pos) <= a.get_range() * a.get_range():
			best = maxf(best, float(a.stats().get("build_discount", 0.0)))
	return best


## Mine Layer: tosses a mine onto the track within range every 1/rate seconds, up to the cap, on the stretch nearest the entrance first,
## never within 18 px of another mine.
func _update_mine_layer(t, s: Dictionary, dt: float) -> void:
	t.cooldown -= dt
	if t.cooldown > 0.0:
		return
	var mine_count := 0
	for m in mines:
		if m.source == t:
			mine_count += 1
	if mine_count >= int(s.get("cap", 20)):
		t.cooldown = 0.2
		return
	var spot = _mine_spot(t, float(s.get("range", 120.0)))
	if spot == null:
		t.cooldown = 0.3
		return
	mines.append({"pos": spot, "source": t})
	t.pulse_count += 1
	t.cooldown = 1.0 / t.eff_rate()
	t.fire_flash = 0.12
	t.aim = (spot - t.pos).angle()
	_emit({"type": "mine_toss", "pos": t.pos, "to": spot, "look": t.look_key()})


## The first free point along the lanes (nearest the entrance) inside reach of the tower; null if there is none.
func _mine_spot(t, reach: float):
	for curve in grid.ground_paths:
		var length: float = curve.get_baked_length()
		var off := 0.0
		while off <= length:
			var p: Vector2 = curve.sample_baked(off)
			if p.distance_squared_to(t.pos) <= reach * reach:
				var free := true
				for m in mines:
					if m.pos.distance_squared_to(p) < 18.0 * 18.0:
						free = false
						break
				if free:
					return p
			off += 10.0
	return null


## A mine goes off under any ground or burrowed enemy (flyers pass over; holograms aren't solid): its blast hits every ground and
## burrowed enemy in its radius; Adhesive Mines leave a gel puddle that slows.
func _update_mines(_dt: float) -> void:
	if mines.is_empty():
		return
	var keep: Array = []
	for m in mines:
		var trig = null
		for e in enemies:
			if e.alive and not e.flying and not e.hologram and e.pos.distance_squared_to(m.pos) <= 14.0 * 14.0:
				trig = e
				break
		if trig == null:
			keep.append(m)
			continue
		var t = m.source
		var s: Dictionary = t.stats()
		var r := float(s.get("splash", 40.0))
		for e in _enemies_near(m.pos, r, false, true, true):
			var dealt := damage_enemy(e, t.eff_damage(), false, t, true, false, true)
			_emit({"type": "hit", "pos": e.pos, "amount": dealt, "kind": "cannon"})
		if float(s.get("gel_slow", 0.0)) > 0.0:
			smokes.append({"pos": m.pos, "r": r, "t": float(s.get("gel_time", 2.0)), "slow": float(s.gel_slow)})
		_emit({"type": "mine_blast", "pos": m.pos, "radius": r, "gel": float(s.get("gel_slow", 0.0)) > 0.0, "look": t.look_key()})
	mines = keep


## Chemical Plant: sprays the best unsoaked enemy in range (one, or two with the Twin Nozzles); a soaked enemy is ignored until the
## soak wears off. The soak strips armour (back when it ends, or for good with Corrosive Acid), burns with acid and slows with gel.
func _spray(t, s: Dictionary) -> void:
	var cands: Array = []
	for e in enemies:
		if t.can_target(e) and e.soak_timer <= 0.0 and not e.hologram:
			cands.append(e)
	if cands.is_empty():
		t.target = null
		t.cooldown = RETARGET_DELAY
		return
	_rank_targets(t, cands, t.pos)
	t.target = cands[0]
	t.cooldown = 1.0 / t.eff_rate()
	t.fire_flash = 0.15
	t.aim = (cands[0].pos - t.pos).angle()
	t.shot_targets = cands.slice(0, 2)
	var hit_n := int(s.get("nozzles", 1))
	var soaked: Array = []
	for i in mini(hit_n, cands.size()):
		soaked.append(cands[i])
	if bool(s.get("mist", false)):
		var extra = null
		for e in cands:
			if not soaked.has(e) and e.pos.distance_squared_to(soaked[0].pos) <= 40.0 * 40.0:
				extra = e
				break
		if extra != null:
			soaked.append(extra)
	var strip := float(s.get("armor_strip", 3.0))
	var time_s := float(s.get("soak_time", 4.0))
	for e in soaked:
		e.soak_timer = time_s
		e.soak_dps = float(s.get("acid_dps", 0.0))
		e.soak_slow = float(s.get("gel_slow", 0.0))
		e.soak_source = t
		if bool(s.get("acid_perm", false)):
			e.armor_shred = maxf(e.armor_shred, strip)
		else:
			e.armor_break = maxf(e.armor_break, strip)
			e.armor_break_timer = maxf(e.armor_break_timer, time_s)
		_emit({"type": "spray", "from": t.pos, "to": e.pos, "look": t.look_key()})


## Every tick: acid burns soaked enemies, gel and chill slow them.
func _update_soaks(dt: float) -> void:
	for t in towers:
		if t.type == "cryo_tower" and t.disabled <= 0.0 and bool(t.stats().get("cold_front", false)):
			var s: Dictionary = t.stats()
			for e in _enemies_near(t.pos, t.get_range(), t.hits_air(), t.hits_ground()):
				e.apply_slow(float(s.slow) * (0.5 if e.boss else 1.0), 0.25)
	for e in enemies:
		if not e.alive:
			continue
		if e.soak_timer > 0.0:
			if e.soak_dps > 0.0 and e.soak_source != null:
				damage_enemy(e, e.soak_dps * dt, true, e.soak_source, false, false, false, false, "energy")
			if e.soak_slow > 0.0:
				e.apply_slow(e.soak_slow, 0.25)
		if e.perm_slow > 0.0:
			e.apply_slow(e.perm_slow, 0.25)


## Cryo Tower: a wave of cold gas slows every enemy in the radius (air and ground; bosses half), does frostbite damage, leaves a
## permanent chill, and every few waves freezes them solid. The Cold Front keeps the slow on everything inside, always.
func _cryo_wave(t, s: Dictionary) -> void:
	var r: float = t.get_range()
	var hit := false
	t.pulse_count += 1
	var freeze: bool = int(s.get("freeze_every", 0)) > 0 and t.pulse_count % int(s.freeze_every) == 0
	for e in _enemies_near(t.pos, r, t.hits_air(), t.hits_ground()):
		var half := 0.5 if e.boss else 1.0
		e.apply_slow(float(s.slow) * half, float(s.slow_time))
		if float(s.get("perm_slow", 0.0)) > 0.0:
			e.perm_slow = maxf(e.perm_slow, float(s.perm_slow) * half)
		if float(s.get("damage", 0.0)) > 0.0:
			damage_enemy(e, t.eff_damage(), true, t)
		if freeze and e.alive:
			e.apply_stun(float(s.get("freeze_time", 1.0)) * (0.3 if e.boss else 1.0))
		hit = true
	t.cooldown = 1.0 / t.eff_rate() if hit else RETARGET_DELAY
	if hit:
		t.fire_flash = 0.3
		_emit({"type": "frost", "pos": t.pos, "radius": r, "tier": t.tier, "spec": t.spec, "look": t.look_key(), "freeze": freeze})


## Designates the point a CAS Gunship orbits (free, any time, anywhere on the map).
func designate_orbit(t, pos: Vector2) -> void:
	t.aim_point = pos.clamp(Vector2.ZERO, Grid.field_size())
	t.aim_set = true


## CAS Gunship: the plane circles `aim_point` and its guns fire at enemies inside the orbit. The gatling takes the best target,
## the autocannon the next, the missiles the last, so they spread over a pack. The Radar Retrofit reveals cloaked enemies inside
## the orbit to every tower. An EMP over the orbit switches the guns off (see the EMP code).
func _update_cas(t, s: Dictionary, dt: float) -> void:
	if not t.aim_set:
		designate_orbit(t, nearest_track_point(t.pos))
	var radius := float(s.get("orbit", 90.0))
	t.orbit_angle = fmod(t.orbit_angle + 0.5 * dt, TAU)
	var plane: Vector2 = t.aim_point + Vector2.from_angle(t.orbit_angle) * radius
	if bool(s.get("radar", false)):
		for e in enemies:
			if e.alive and e.cloaked and e.pos.distance_squared_to(t.aim_point) <= radius * radius:
				e.reveal_timer = maxf(e.reveal_timer, 0.4)
	var foes := _cas_targets(t, radius, plane)
	if foes.is_empty():
		return
	var mult: float = float(s.get("rate_mult", 1.0)) * (1.0 + t.buff_rate)
	var bonus: float = 1.0 + t.buff_dmg
	var cds: Dictionary = t.gun_cds
	cds["gat"] = float(cds.get("gat", 0.0)) - dt
	if float(cds.gat) <= 0.0:
		cds["gat"] = 1.0 / (float(s.rate) * mult)
		var tg = foes[0]
		var dealt := damage_enemy(tg, float(s.damage) * bonus, false, t)
		t.fire_flash = 0.1
		_emit({"type": "cas_shot", "gun": "gat", "from": plane, "to": tg.pos, "look": t.look_key()})
	if s.has("ac_damage"):
		cds["ac"] = float(cds.get("ac", 0.0)) - dt
		if float(cds.ac) <= 0.0:
			cds["ac"] = 1.0 / (float(s.ac_rate) * mult)
			var tg2 = foes[mini(1, foes.size() - 1)]
			for e in _enemies_near(tg2.pos, float(s.ac_splash)):
				damage_enemy(e, float(s.ac_damage) * bonus, false, t)
			_emit({"type": "cas_shot", "gun": "ac", "from": plane, "to": tg2.pos, "look": t.look_key(), "radius": float(s.ac_splash)})
	if s.has("ms_damage"):
		cds["ms"] = float(cds.get("ms", 0.0)) - dt
		if float(cds.ms) <= 0.0:
			cds["ms"] = 1.0 / (float(s.ms_rate) * mult)
			t.pulse_count += 1
			var volley := int(s.get("ms_volley", 1)) if t.pulse_count % 3 == 0 else 1
			for j in volley:
				var tg3 = foes[maxi(0, foes.size() - 1 - j)]
				var p = Projectile.new()
				p.kind = "missile"
				p.pos = plane
				p.start = plane
				p.vel = (tg3.pos - plane).normalized().orthogonal() * (120.0 if j % 2 == 0 else -120.0) + (tg3.pos - plane).normalized() * 60.0
				p.target = tg3
				p.target_pos = tg3.pos
				p.speed = 300.0
				p.damage = float(s.ms_damage) * bonus
				p.splash = float(s.ms_splash)
				p.air_mult = 1.0
				p.tier = t.tier
				p.source = t
				projectiles.append(p)
			_emit({"type": "cas_shot", "gun": "ms", "from": plane, "to": foes[foes.size() - 1].pos, "look": t.look_key()})


## Enemies inside a CAS Gunship's orbit, best first by its targeting mode and priority (air or ground first).
func _cas_targets(t, radius: float, plane: Vector2) -> Array:
	var out: Array = []
	for e in enemies:
		if e.alive and not e.is_hidden() and e.pos.distance_squared_to(t.aim_point) <= radius * radius:
			out.append(e)
	if t.priority != 0 and out.any(func(e): return _prefers(t, e)):
		out = out.filter(func(e): return _prefers(t, e))
	_rank_targets(t, out, plane)
	return out


func set_loadout(t, kind: String) -> bool:
	if not t.available_loadouts().has(kind):
		return false
	t.loadout = kind
	return true


## The weapons a Drone Bay's drones carry for a loadout: damage and rate as shares of the bay's gun, a blast, whether it only
## hits the ground, whether it is energy (ignores armour). Loadout numbers are proposals the balance probe tunes. The Full Kit
## fires all three of gun, missiles and laser at 70% each.
const LOADOUTS := {
	"gun": [{"name": "gun", "dmg": 1.0, "rate": 1.0, "splash": 0.0, "ground": false, "energy": false}],
	"missiles": [{"name": "missiles", "dmg": 2.5, "rate": 0.4, "splash": 25.0, "ground": false, "energy": false}],
	"bombs": [{"name": "bombs", "dmg": 4.0, "rate": 0.25, "splash": 40.0, "ground": true, "energy": false}],
	"laser": [{"name": "laser", "dmg": 0.9, "rate": 1.0, "splash": 0.0, "ground": false, "energy": true}],
	"full": [
		{"name": "gun", "dmg": 0.7, "rate": 1.0, "splash": 0.0, "ground": false, "energy": false},
		{"name": "missiles", "dmg": 1.75, "rate": 0.4, "splash": 25.0, "ground": false, "energy": false},
		{"name": "laser", "dmg": 0.63, "rate": 1.0, "splash": 0.0, "ground": false, "energy": true},
	],
}


func _loadout_weapons(t, s: Dictionary) -> Array:
	var kind: String = t.loadout if t.available_loadouts().has(t.loadout) else "gun"
	var out: Array = []
	var boost := float(s.get("loadout_mult", 1.0))
	for w in LOADOUTS[kind]:
		var c: Dictionary = w.duplicate()
		c["dmg"] = float(w.dmg) * boost
		out.append(c)
	return out


## Drone Bay (reworked): one drone (two with the Second Hangar) hunts anywhere on the map, spread over different targets. Each
## drone circles its target and fires the loadout's weapons from close range. Enemies can't hurt drones, but an EMP over one
## switches the bay off for its duration (see the EMP code).
func _update_drone_bay(t, s: Dictionary, dt: float) -> void:
	var want := int(s.get("drones", 1))
	while t.wing.size() < want:
		t.wing.append({"kind": "gun", "pos": t.pos, "target": null, "cds": {}})
	while t.wing.size() > want:
		t.wing.pop_back()
	var weapons := _loadout_weapons(t, s)
	var ground_only: bool = weapons.all(func(w): return bool(w.ground))
	var dmg: float = t.eff_damage()
	var rate: float = t.eff_rate()
	for i in t.wing.size():
		var d: Dictionary = t.wing[i]
		var tg = d.target
		if tg == null or not tg.alive or tg.is_hidden() or (ground_only and tg.flying):
			d["target"] = _drone_target(t, s, ground_only)
			tg = d.target
		var goal: Vector2
		if tg == null:
			goal = t.pos + Vector2.from_angle(time * 1.4 + float(i) * PI) * 34.0
		else:
			goal = tg.pos + Vector2.from_angle(time * 2.0 + float(i) * PI) * 44.0
		var v := 170.0 * dt
		var to: Vector2 = goal - d.pos
		d["pos"] = goal if to.length() <= v else d.pos + to.normalized() * v
		if tg == null:
			continue
		for w in weapons:
			var cds: Dictionary = d.cds
			cds[w.name] = float(cds.get(w.name, 0.0)) - dt
			if float(cds[w.name]) > 0.0 or d.pos.distance_to(tg.pos) > 80.0 or (bool(w.ground) and tg.flying):
				continue
			cds[w.name] = 1.0 / (rate * float(w.rate))
			var hit: float = dmg * float(w.dmg)
			_drone_hit(t, d, tg, w, hit)


func _drone_hit(t, d: Dictionary, tg, w: Dictionary, hit: float) -> void:
	var energy := bool(w.energy)
	if float(w.splash) > 0.0:
		for e in _enemies_near(tg.pos, float(w.splash), not bool(w.ground), true):
			damage_enemy(e, hit, energy, t)
		_emit({"type": "drone_bomb" if bool(w.ground) else "drone_shot", "pos": tg.pos, "from": d.pos, "to": tg.pos, "radius": float(w.splash), "kind": w.name, "look": t.look_key()})
		return
	damage_enemy(tg, hit, energy, t)
	_emit({"type": "drone_shot", "from": d.pos, "to": tg.pos, "kind": w.name, "look": t.look_key()})


func set_shell(t, kind: String) -> bool:
	if not t.available_shells().has(kind):
		return false
	t.shell = kind
	return true


## A deterministic offset inside a circle of radius `r` (shell scatter), from the run's seed and a counter.
func _scatter(r: float) -> Vector2:
	_roll_count += 1
	var a := sin(float(seed_value % 100003) * 12.9898 + float(_roll_count) * 78.233) * 43758.5453
	var b := sin(float(seed_value % 100003) * 39.346 + float(_roll_count) * 11.135) * 24634.6345
	return Vector2.from_angle((a - floor(a)) * TAU) * r * sqrt(b - floor(b))


## Artillery Cannon: shells the aimed spot on a loop, whether or not anything is there. Every third shell is heavy with the
## Shell Magazine; the Rolling Barrage walks a barrage of shells across the spot, one after another.
func _fire_artillery(t, s: Dictionary) -> void:
	if not t.aim_set:
		aim_artillery(t, nearest_track_point(t.pos))
	t.cooldown = 1.0 / t.eff_rate()
	t.fire_flash = 0.15
	t.pulse_count += 1
	var dir: Vector2 = (t.aim_point - t.pos).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT
	t.aim = dir.angle()
	var kind: String = t.shell if t.available_shells().has(t.shell) else "he"
	var n := maxi(1, int(s.get("barrage", 1)))
	var heavy_every := int(s.get("heavy_every", 0))
	var heavy: bool = heavy_every > 0 and t.pulse_count % heavy_every == 0
	for i in n:
		var spot: Vector2 = t.aim_point + dir * (float(i) - float(n - 1) / 2.0) * 30.0 + _scatter(float(s.get("scatter", 30.0)))
		var p = Projectile.new()
		p.kind = t.type
		p.pos = t.pos + dir * 18.0
		p.start = p.pos
		p.target_pos = spot
		p.total = maxf(1.0, p.pos.distance_to(spot))
		p.speed = p.total / float(s.get("flight", 1.5))
		p.damage = t.eff_damage() * (1.5 if heavy else 1.0)
		p.crit = heavy
		p.splash = float(s.splash)
		p.shell = kind
		p.look = t.look_key()
		p.tier = t.tier
		p.source = t
		p.hold = float(i) * 0.2
		projectiles.append(p)
	_emit({"type": "fire", "tower": t.type, "pos": t.pos, "tier": t.tier, "spec": t.spec, "count": n})


## Tesla Tower: an arc at the target that jumps to the nearest unhit enemy in reach, up to `jumps` times, losing `falloff` of its
## damage with each. It's energy (armour doesn't count). Arc Stun stuns each enemy it hits; Overload doubles it against
## Disruptors; the Storm Field leaves a crackling zone where the arc started.
func _chain_rework(t, first, s: Dictionary) -> void:
	var hit: Array = [first]
	var points: Array = [t.pos + Vector2(0, -6), first.pos]
	var dmg: float = t.eff_damage()
	var cur = first
	var jump_r := float(s.get("jump_range", 70.0))
	var keep := 1.0 - float(s.get("falloff", 0.15))
	var stun := float(s.get("stun_time", 0.0))
	var overload := bool(s.get("overload", false))
	var n := 1 + int(s.get("jumps", 3))
	if float(s.get("storm_dps", 0.0)) > 0.0:
		storms.append({"pos": first.pos, "r": float(s.storm_radius), "dps": float(s.storm_dps), "t": float(s.get("storm_time", 2.0)), "source": t, "pierce": true})
		_emit({"type": "storm_zone", "pos": first.pos, "radius": float(s.storm_radius), "time": float(s.get("storm_time", 2.0)), "look": t.look_key()})
	for k in n:
		var hit_dmg: float = dmg * (2.0 if overload and cur.role() == "disruptor" else 1.0)
		if overload:
			_cancel_charge(cur)
		var dealt := damage_enemy(cur, hit_dmg, true, t)
		if stun > 0.0 and cur.alive:
			cur.apply_stun(stun * _boss_factor(cur))
			_emit({"type": "stun_hit", "pos": cur.pos})
		_emit({"type": "hit", "pos": cur.pos, "amount": dealt, "kind": "tesla"})
		if k == n - 1:
			break
		var nxt = null
		var nd := jump_r * jump_r
		for e in enemies:
			if not e.alive or hit.has(e) or e.is_hidden() or (e.flying and not t.hits_air()) or (not e.flying and not t.hits_ground()):
				continue
			var d2: float = e.pos.distance_squared_to(cur.pos)
			if d2 <= nd:
				nd = d2
				nxt = e
		if nxt == null:
			break
		hit.append(nxt)
		points.append(nxt.pos)
		cur = nxt
		dmg *= keep
	_emit({"type": "chain", "points": points, "tier": t.tier, "spec": t.spec, "look": t.look_key()})


## Railgun: a slug along the line through the target out to the end of its range. It passes through every enemy on the line,
## losing `falloff` of its damage with each one. Armour applies. Shatter strips armour for good; bosses take extra; the Ionised
## Trail leaves the line burning.
func _fire_railgun(t, target, s: Dictionary) -> void:
	t.pulse_count += 1
	var dir: Vector2 = (target.pos - t.pos).normalized()
	t.aim = dir.angle()
	t.fire_flash = 0.15
	var from: Vector2 = t.pos + dir * 26.0
	var to: Vector2 = t.pos + dir * t.get_range()
	var width := 4.0
	var on_line: Array = []
	for e in enemies:
		if not e.alive or e.is_hidden() or (e.flying and not t.hits_air()) or (not e.flying and not t.hits_ground()):
			continue
		var closest := Geometry2D.get_closest_point_to_segment(e.pos, from, to)
		if closest.distance_to(e.pos) <= e.radius + width:
			on_line.append({"e": e, "d": from.distance_to(closest)})
	on_line.sort_custom(func(a, b): return a.d < b.d)
	var keep := 1.0 - float(s.get("falloff", 0.4))
	var dmg: float = t.eff_damage()
	var shatter := float(s.get("shatter", 0.0))
	var boss := float(s.get("boss_mult", 1.0))
	for entry in on_line:
		var e = entry.e
		var hit: float = dmg * (boss if e.boss else 1.0)
		var dealt := damage_enemy(e, hit, false, t)
		if shatter > 0.0 and e.alive:
			e.shred(shatter, 999.0)
		_emit({"type": "hit", "pos": e.pos, "amount": dealt, "kind": "sniper"})
		dmg *= keep
	var trail := float(s.get("trail_dps", 0.0))
	if trail > 0.0:
		trails.append({"a": from, "b": to, "w": 12.0, "dps": trail, "t": float(s.get("trail_time", 2.0)), "source": t})
	_emit({"type": "rail_shot", "from": from, "to": to, "look": t.look_key(), "trail": trail > 0.0, "n": t.pulse_count})


## Ion trails burn every enemy on their line (energy damage over time ignores armour), cloaked ones too, and reveal them briefly.
func _update_trails(dt: float) -> void:
	if trails.is_empty():
		return
	for z in trails:
		z["t"] = float(z.t) - dt
		for e in enemies:
			if not e.alive:
				continue
			var closest := Geometry2D.get_closest_point_to_segment(e.pos, z.a, z.b)
			if closest.distance_to(e.pos) <= e.radius + float(z.w) * 0.5:
				damage_enemy(e, float(z.dps) * dt, true, z.source, false)
				if e.cloaked:
					e.reveal_timer = maxf(e.reveal_timer, 0.5)
	trails = trails.filter(func(z): return z.t > 0.0)


## Mortar Tower: a shell at the target; every few shells (Smoke Shells) one leaves a cloud. The tube that fires cycles
## (the art shows tubes firing in succession); the rate stat already is the total across the tubes.
func _fire_mortar(t, target, s: Dictionary) -> void:
	t.pulse_count += 1
	_fire_projectile(t, target, s)
	var every := int(s.get("smoke_every", 0))
	if every > 0 and t.pulse_count % every == 0:
		projectiles[projectiles.size() - 1].smoke = true


## Slows ground enemies inside each smoke cloud, and retires the spent ones.
func _update_smokes(dt: float) -> void:
	if smokes.is_empty():
		return
	for c in smokes:
		c.t -= dt
		var r2: float = float(c.r) * float(c.r)
		for e in enemies:
			if e.alive and (c.get("air", false) or not e.flying) and e.pos.distance_squared_to(c.pos) <= r2:
				e.apply_slow(float(c.slow), 0.25)
	smokes = smokes.filter(func(c): return c.t > 0.0)


## True if a burrowed enemy at `pos` is inside a pinging (or constant) Radar Tower's range, so a
## tower with burrow sight may target it.
func _radar_covers(pos: Vector2) -> bool:
	for o in towers:
		if o.type == "radar_tower" and o.disabled <= 0.0 and o.pos.distance_squared_to(pos) <= o.get_range() * o.get_range() and (float(o.gun_cds.get("ping", 0.0)) > 0.0 or bool(o.stats().get("constant", false))):
			return true
	return false


func _burrow_visible(t, e) -> bool:
	return e.burrowed and float(t.stats().get("burrow_sight", 0.0)) > 0.0 and _radar_covers(e.pos)


## Gun Turret: a round at the target; Multi-Target adds a side gun (a second target at part damage) or extra barrels
## (more targets at full damage, the weakest enemies in range at the mastery). Crits, armour piercing, stun and
## ignite ride on the round (see _fire_projectile and _projectile_hit).
func _fire_gun(t, target, s: Dictionary) -> void:
	_fire_projectile(t, target, s)
	var shots: Array = [target]
	t.shot_targets = shots
	var extra := int(s.get("multishot", 1)) - 1
	var side := float(s.get("side_gun", 0.0))
	if extra <= 0 and side > 0.0:
		extra = 1
	for k in extra:
		var other = _weakest_target(t, shots) if bool(s.get("weakest_extra", false)) else pick_target(t, shots)
		if other == null:
			break
		shots.append(other)
		_fire_projectile(t, other, s, side if (side > 0.0 and int(s.get("multishot", 1)) <= 1) else 1.0)


## The enemy with the least health in the tower's range (Triple Mount's extra barrels), skipping `exclude`.
func _weakest_target(t, exclude: Array):
	var best = null
	var best_hp := INF
	for e in enemies:
		if e in exclude or not t.can_target(e):
			continue
		if e.hp < best_hp:
			best_hp = e.hp
			best = e
	return best


# --- v3.1 attacks ------------------------------------------------------------------------------

## Enemies within `r` of `p` that an attack can reach (living; hidden and burrowed ones only when asked).
func _enemies_near(p: Vector2, r: float, air := true, ground := true, hidden := false) -> Array:
	var out: Array = []
	var r2 := r * r
	for e in enemies:
		if not e.alive or (e.flying and not air) or (not e.flying and not ground):
			continue
		if not hidden and e.is_hidden():
			continue
		if e.pos.distance_squared_to(p) <= r2:
			out.append(e)
	return out


func _boss_factor(e) -> float:
	return BOSS_STUN_FACTOR if e.boss else 1.0


## A support tower's field: jams enemy support and slows, when its stats give it a jam or a field slow.
func _support_field(t, s: Dictionary) -> void:
	var jam := int(s.get("jam", 0))
	var slow := float(s.get("field_slow", 0.0))
	if jam == 0 and slow <= 0.0:
		return
	for e in _enemies_near(t.pos, t.get_range(), true, true, true):
		if jam > 0:
			e.jam_level = jam if e.jam_timer <= 0.0 else maxi(e.jam_level, jam)
			e.jam_timer = 0.25
		if slow > 0.0:
			e.apply_slow(slow, 0.25)


func _rail_effects(t, e, s: Dictionary) -> void:
	var strip := float(s.get("strip", 0.0))
	if strip > 0.0 and e.shield > 0.0:
		e.shield *= maxf(0.0, 1.0 - strip)
		if e.shield <= 0.0:
			_emit({"type": "shield_break", "pos": e.pos})
	var sup := float(s.get("suppress", 0.0))
	if sup <= 0.0:
		return
	var hit: Array = [e]
	var spread := float(s.get("suppress_spread", 0.0))
	if spread > 0.0:
		for o in _enemies_near(e.pos, spread, true, true, true):
			if o != e:
				hit.append(o)
	for o in hit:
		if o.boss:
			continue
		o.suppress_timer = maxf(o.suppress_timer, sup)
		if bool(s.get("expose", false)):
			o.expose_timer = maxf(o.expose_timer, sup)
	_emit({"type": "suppress", "pos": e.pos, "radius": maxf(spread, 20.0)})


## Short-lived storm zones (the Tesla Tower's storms).
func _update_storms(dt: float) -> void:
	if storms.is_empty():
		return
	var keep: Array = []
	for z in storms:
		z["t"] = float(z.t) - dt
		var energy: bool = bool(z.get("pierce", false))
		for e in _enemies_near(z.pos, float(z.r), true, true, energy):
			damage_enemy(e, float(z.dps) * dt, energy, z.source, false)
		if z.t > 0.0:
			keep.append(z)
	storms = keep


const HUNTED := ["stalker", "rally", "bulwark", "mender", "jammer", "shaman"]
const HUNTED_EXTRA := ["phantom", "gunship"]


## Picks a target anywhere on the map for a drone, spreading the wing over several enemies.
func _drone_target(t, s: Dictionary, bomber: bool):
	var hunt := bool(s.get("hunt", false))
	var extra := bool(s.get("hunt_extra", false))
	var interceptor := float(s.get("air_mult", 1.0)) > 1.0 and not bomber
	var reach_burrowed := bool(s.get("hits_burrowed", false))
	var taken := {}
	for d in t.wing:
		if d.target != null:
			taken[d.target] = int(taken.get(d.target, 0)) + 1
	var best = null
	var best_score := -INF
	for e in enemies:
		if not e.alive or (bomber and e.flying):
			continue
		if e.is_hidden() and not (bomber and reach_burrowed and e.burrowed):
			continue
		var score: float = e.progress()
		if hunt and (e.type in HUNTED or (extra and e.type in HUNTED_EXTRA)):
			score += 10.0
		if interceptor and e.flying:
			score += 5.0
		if t.priority != 0 and _prefers(t, e):
			score += 8.0
		score -= float(taken.get(e, 0)) * 3.0
		if score > best_score:
			best_score = score
			best = e
	return best


func _fire_projectile(t, target, s: Dictionary, dmg_mult := 1.0) -> void:
	var p = Projectile.new()
	p.kind = t.type
	p.pos = t.pos + Vector2.from_angle(t.aim) * 16.0
	p.start = p.pos
	p.target = target
	p.target_pos = target.pos
	p.speed = float(s.proj_speed)
	p.damage = t.eff_damage() * dmg_mult
	if float(s.get("crit", 0.0)) > 0.0 and _roll(float(s.get("crit", 0.0))):
		p.damage *= CRIT_MULT
		p.crit = true
	p.look = t.look_key()
	p.splash = float(s.get("splash", 0.0))
	p.shred = float(s.get("shred", 0.0))
	p.shred_max = float(s.get("shred_max", 0.0))
	p.burn_dps = float(s.get("burn_dps", 0.0))
	p.burn_time = float(s.get("burn_time", 0.0))
	p.stun = float(s.get("stun", 0.0))
	p.tier = t.tier
	p.source = t
	p.total = maxf(1.0, p.pos.distance_to(target.pos))
	projectiles.append(p)
	_emit({"type": "fire", "tower": t.type, "pos": p.pos, "tier": t.tier, "spec": t.spec, "crit": p.crit, "tracers": bool(s.get("tracers", false))})


func _fire_rail(t, target, s: Dictionary) -> void:
	var dir := Vector2.from_angle(t.aim)
	var muzzle: Vector2 = t.pos + dir * 26.0
	var dmg: float = t.eff_damage()
	if bool(s.get("line", false)):
		var end: Vector2 = t.pos + dir * t.get_range()
		var width := float(s.get("rail_width", RAIL_WIDTH))
		for e in enemies:
			if not e.alive or (e.flying and not t.hits_air()):
				continue
			var closest := Geometry2D.get_closest_point_to_segment(e.pos, muzzle, end)
			if closest.distance_to(e.pos) <= e.radius + width:
				var d := damage_enemy(e, dmg, true, t)
				if e.alive:
					_rail_effects(t, e, s)
				_emit({"type": "hit", "pos": e.pos, "amount": d, "kind": "sniper"})
		_emit({"type": "tracer", "from": muzzle, "to": end, "tier": t.tier, "spec": t.spec, "width": width})
		return
	if target.boss:
		dmg *= float(s.get("boss_mult", 1.0))
	_rail_effects(t, target, s)
	var dealt := damage_enemy(target, dmg, true, t)
	# Execute (Executioner): a non-boss survivor under the threshold is destroyed outright.
	var execute := float(s.get("execute", 0.0))
	if execute > 0.0 and target.alive and not target.boss and target.hp <= target.max_hp * execute:
		dealt += target.hp
		t.damage_dealt += target.hp
		_emit({"type": "execute", "pos": target.pos})
		_kill(target, t)
	_emit({"type": "tracer", "from": muzzle, "to": target.pos, "tier": t.tier, "spec": t.spec})
	_emit({"type": "hit", "pos": target.pos, "amount": dealt, "kind": "sniper"})


## Rocket Salvo: one salvo, each rocket at a different enemy (best first); when there are more rockets than enemies the spares
## go to the strongest. A rippling salvo (the mastery) leaves its tubes one after another.
func _fire_salvo(t, s: Dictionary) -> void:
	var cands: Array = []
	for e in enemies:
		if t.can_target(e):
			cands.append(e)
	if cands.is_empty():
		t.target = null
		t.cooldown = RETARGET_DELAY
		return
	_rank_targets(t, cands, t.pos)
	var strongest = cands[0]
	for e in cands:
		if strength_key(e) > strength_key(strongest):
			strongest = e
	t.target = cands[0]
	t.cooldown = 1.0 / t.eff_rate()
	t.fire_flash = 0.15
	t.aim = (cands[0].pos - t.pos).angle()
	var n := int(s.get("missiles", 3))
	var dir := Vector2.from_angle(t.aim)
	var ripple := bool(s.get("ripple", false))
	for i in n:
		var tgt = cands[i] if i < cands.size() else strongest
		var side := 1.0 if i % 2 == 0 else -1.0
		var p = Projectile.new()
		p.kind = "rocket_salvo"
		p.pos = t.pos + dir.orthogonal() * side * 7.0
		p.start = p.pos
		p.vel = dir.orthogonal() * side * (150.0 + 15.0 * float(i)) + dir * 60.0
		p.target = tgt
		p.target_pos = tgt.pos
		p.speed = float(s.proj_speed)
		p.damage = t.eff_damage()
		p.splash = float(s.get("splash", 25.0))
		p.air_mult = float(s.get("air_mult", 1.0))
		p.homing = bool(s.get("homing", false))
		p.retarget = bool(s.get("retarget", false))
		p.never_miss = bool(s.get("never_miss", false))
		p.smoke_slow = float(s.get("smoke_slow", 0.0))
		p.smoke_time = float(s.get("smoke_time", 0.0))
		p.ground_burn = float(s.get("ground_burn", 0.0))
		p.ground_burn_time = float(s.get("ground_burn_time", 0.0))
		p.hold = float(i) * 0.09 if ripple else 0.0
		p.look = t.look_key()
		p.tier = t.tier
		p.source = t
		projectiles.append(p)
	_emit({"type": "fire", "tower": "rocket_salvo", "pos": t.pos, "tier": t.tier, "spec": t.spec, "count": n})


## Laser Tower: up to `beams` beams, each on its own target and ramping on its own (damage grows from x1 to the ceiling over the
## ramp time); the extra beams carry `beam_power` of the main beam. A beam that picks up a new target keeps `ramp_keep` of the
## ramp it just lost (Ramp Memory). The beam melts the target's armour for good, which every other tower then enjoys.
func _update_laser_rework(t, s: Dictionary, dt: float) -> void:
	var beams := int(s.get("beams", 1))
	var keep: Array = []
	var ramps: Array = []
	var lost: Array = []
	for i in t.beam_targets.size():
		var e = t.beam_targets[i]
		var held: float = t.beam_ramps[i] if i < t.beam_ramps.size() else 0.0
		if keep.size() < beams and t.can_target(e):
			keep.append(e)
			ramps.append(held)
		else:
			lost.append(held)
	var carry := float(s.get("ramp_keep", 0.0))
	while keep.size() < beams:
		var nt = pick_target(t, keep)
		if nt == null:
			break
		keep.append(nt)
		ramps.append((lost.pop_back() if not lost.is_empty() else 0.0) * carry)
	t.beam_targets = keep
	if keep.is_empty():
		t.beam_ramps.clear()
		t.target = null
		t.ramp = 0.0
		t.ramp_mult = 1.0
		return
	if keep[0] != t.target:
		t.target = keep[0]
		_emit({"type": "laser_lock", "pos": t.pos})
	var ramp_max := float(s.ramp)
	var ramp_time := float(s.ramp_time)
	var power := float(s.get("beam_power", 0.4))
	var melt := float(s.get("melt", 0.0))
	var dps: float = t.eff_damage()
	for i in keep.size():
		ramps[i] = float(ramps[i]) + dt
		var mult := 1.0 + (ramp_max - 1.0) * clampf(float(ramps[i]) / ramp_time, 0.0, 1.0)
		damage_enemy(keep[i], dps * mult * dt * (1.0 if i == 0 else power), true, t, false)
		if melt > 0.0:
			keep[i].shred(melt * dt, 999.0)
		if i == 0:
			t.ramp = ramps[0]
			t.ramp_mult = mult
	t.beam_ramps = ramps
	t.aim = (keep[0].pos - t.pos).angle()
	t.fire_flash = 0.05


func _update_projectile(p, dt: float) -> void:
	if p.hold > 0.0 and p.kind != "rocket_salvo":
		p.hold -= dt
		return
	if p.kind == "rocket_salvo":
		_update_rocket(p, dt)
		return
	if p.target != null and p.target.alive:
		p.target_pos = p.target.pos
	if p.kind == "missile":
		_update_missile(p, dt)
		return
	var to: Vector2 = p.target_pos - p.pos
	var step: float = p.speed * dt
	p.traveled += step
	if to.length() <= step:
		p.pos = p.target_pos
		p.alive = false
		_projectile_hit(p)
	else:
		p.pos += to.normalized() * step


## A Rocket Salvo rocket: waits out its hold (a rippling salvo), then flies. Without seekers it goes to where its target was;
## homing curves onto it, re-targeting steers onto the nearest enemy if it dies, never-miss turns fast enough to always arrive.
func _update_rocket(p, dt: float) -> void:
	if p.hold > 0.0:
		p.hold -= dt
		return
	p.life += dt
	if p.homing:
		if (p.target == null or not p.target.alive) and p.retarget and p.source != null:
			p.target = _nearest_for(p.source, p.pos, 200.0)
		if p.target != null and p.target.alive:
			p.target_pos = p.target.pos
	var to: Vector2 = p.target_pos - p.pos
	p.vel = p.vel.lerp(to.normalized() * p.speed, clampf((40.0 if p.never_miss else MISSILE_TURN) * dt, 0.0, 1.0))
	var step: Vector2 = p.vel * dt
	p.traveled += step.length()
	if p.smoke_slow > 0.0:
		p.smoke_acc += step.length()
		while p.smoke_acc >= 20.0:
			p.smoke_acc -= 20.0
			smokes.append({"pos": p.pos, "r": 16.0, "t": p.smoke_time, "slow": p.smoke_slow, "air": true})
	if to.length() <= maxf(step.length(), 10.0) or p.life >= (6.0 if p.never_miss else MISSILE_MAX_LIFE):
		if to.length() <= 30.0:
			p.pos = p.target_pos
		p.alive = false
		_projectile_hit(p)
	else:
		p.pos += step


## The nearest living enemy to `pos` (within `r`) that tower `t` can hit.
func _nearest_for(t, pos: Vector2, r: float):
	var best = null
	var bd := r * r
	for e in enemies:
		if e.alive and not e.is_hidden() and (not e.flying or t.hits_air()) and (e.flying or t.hits_ground()):
			var d: float = pos.distance_squared_to(e.pos)
			if d <= bd:
				bd = d
				best = e
	return best


func _update_missile(p, dt: float) -> void:
	p.life += dt
	var to: Vector2 = p.target_pos - p.pos
	var desired: Vector2 = to.normalized() * p.speed
	p.vel = p.vel.lerp(desired, clampf(MISSILE_TURN * dt, 0.0, 1.0))
	var step: Vector2 = p.vel * dt
	p.traveled += step.length()
	if to.length() <= maxf(step.length(), 10.0) or p.life >= MISSILE_MAX_LIFE:
		if to.length() <= 30.0:
			p.pos = p.target_pos
		p.alive = false
		_projectile_hit(p)
	else:
		p.pos += step


func _projectile_hit(p) -> void:
	var s: Dictionary = p.source.stats() if p.source != null else {}
	match p.kind:
		"artillery_cannon":
			# Artillery Cannon: a blast on every ground enemy. Shrapnel widens it at part damage, incendiary leaves burning
			# ground, concussion stuns what it hits; the combined shell does all three.
			var kind := String(p.shell)
			var shrap: bool = kind == "shrapnel" or kind == "combined"
			var burn: bool = kind == "incendiary" or kind == "combined"
			var stun: bool = kind == "concussion" or kind == "combined"
			var r: float = p.splash + (float(s.get("shrap_radius", 40.0)) if shrap else 0.0)
			var dmg: float = p.damage * (float(s.get("shrap_mult", 0.7)) if shrap else 1.0)
			for e in _enemies_near(p.pos, r, false, true):
				var dealt := damage_enemy(e, dmg, false, p.source)
				_emit({"type": "hit", "pos": e.pos, "amount": dealt, "kind": "cannon"})
				if stun and e.alive:
					e.apply_stun(float(s.get("stun_time", 0.5)) * _boss_factor(e))
			if burn:
				pools.append({"pos": p.pos, "r": r * 0.8, "dps": float(s.get("burn_dps", 15.0)), "t": float(s.get("burn_time", 3.0)), "source": p.source})
			_emit({"type": "splash", "pos": p.pos, "radius": r, "burn": burn, "stun": stun, "look": p.look})
		"anti_aircraft_turret":
			# Anti-Aircraft Turret: stock rounds are direct hits; from Flak Rounds each round also bursts, hurting every flyer in
			# the burst radius around its target.
			var burst := float(s.get("burst", 0.0))
			if burst > 0.0:
				var c: Vector2 = p.target.pos if (p.target != null and p.target.alive) else p.pos
				for e in enemies:
					if e.alive and e.flying and e.pos.distance_squared_to(c) <= burst * burst:
						var dealt := damage_enemy(e, p.damage, false, p.source)
						_emit({"type": "hit", "pos": e.pos, "amount": dealt, "kind": "flak"})
				_emit({"type": "flak_hit", "pos": c, "radius": burst, "look": p.look})
			elif p.target != null and p.target.alive:
				var dealt2 := damage_enemy(p.target, p.damage, false, p.source)
				_emit({"type": "hit", "pos": p.target.pos, "amount": dealt2, "kind": "flak"})
				_rework_hit_effects(p, s)
				_ricochet(p.source, p.target, p.damage)
		"rocket_salvo":
			# Rocket Salvo: a blast on flyers and ground alike (more against air with Proximity Fuses); Incendiary Warheads
			# leave burning ground.
			var r: float = p.splash
			for e in enemies:
				if e.alive and e.pos.distance_squared_to(p.pos) <= r * r:
					var dealt := damage_enemy(e, p.damage * (p.air_mult if e.flying else 1.0), false, p.source)
					_emit({"type": "hit", "pos": e.pos, "amount": dealt, "kind": "missile"})
			if p.ground_burn > 0.0:
				pools.append({"pos": p.pos, "r": r * 0.8, "dps": p.ground_burn, "t": p.ground_burn_time, "source": p.source})
			_emit({"type": "missile_hit", "pos": p.pos, "radius": r, "look": p.look})
		"mortar_tower":
			# Mortar Tower: a blast on every ground enemy in range; armour is cracked by the Power path (damage_enemy reads it),
			# burrowed ones take it only with burrow sight (half damage, full at the mastery); cluster bomblets scatter round the impact.
			var r: float = p.splash
			var sight := float(s.get("burrow_sight", 0.0))
			for e in enemies:
				if e.alive and not e.flying and e.pos.distance_squared_to(p.pos) <= r * r:
					if e.burrowed and sight <= 0.0:
						continue
					var dmg: float = p.damage * (sight if e.burrowed else 1.0)
					var dealt := damage_enemy(e, dmg, false, p.source, true, false, sight > 0.0)
					_emit({"type": "hit", "pos": e.pos, "amount": dealt, "kind": "cannon"})
			var n := int(s.get("bomblets", 0))
			if n > 0:
				var br := float(s.get("bomblet_splash", 30.0))
				var ring := 30.0 * (1.5 if float(s.get("bomblet_spread", 0.0)) > 0.0 else 1.0)
				for k in n:
					var bp: Vector2 = p.pos + Vector2.from_angle(TAU * float(k) / float(n) + float(k) * 0.7) * ring
					for e in _enemies_near(bp, br, false, true):
						damage_enemy(e, float(s.get("bomblet_damage", 10.0)) * (1.0 + (p.source.buff_dmg if p.source != null else 0.0)), false, p.source, false)
					_emit({"type": "bomblet", "pos": bp, "radius": br})
			if p.smoke:
				smokes.append({"pos": p.pos, "r": r, "t": float(s.get("smoke_time", 3.0)), "slow": float(s.get("smoke_slow", 0.15))})
				_emit({"type": "smoke", "pos": p.pos, "radius": r})
			_emit({"type": "splash", "pos": p.pos, "radius": r, "burn": false, "stun": false})
		"missile":
			var r: float = p.splash
			for e in enemies:
				if e.alive and e.pos.distance_squared_to(p.pos) <= r * r:
					var dmg: float = p.damage * (p.air_mult if e.flying else 1.0)
					damage_enemy(e, dmg, false, p.source)
			_emit({"type": "missile_hit", "pos": p.pos, "radius": r})
			# Cluster Munitions: the missile bursts into bomblets around the impact.
			var n := int(s.get("bomblets", 0))
			if n > 0:
				var br := float(s.get("bomblet_splash", 26.0))
				var pierce := bool(s.get("pierce", false))
				for k in n:
					var bp: Vector2 = p.pos + Vector2.from_angle(TAU * float(k) / float(n) + float(k) * 0.7) * 30.0
					for e in _enemies_near(bp, br):
						damage_enemy(e, p.damage * (p.air_mult if e.flying else 1.0), pierce, p.source, false)
					_emit({"type": "bomblet", "pos": bp, "radius": br})
		_:
			if p.target != null and p.target.alive:
				if p.shred > 0.0:
					p.target.shred(p.shred, p.shred_max)
				damage_enemy(p.target, p.damage, false, p.source)
				if p.source != null:
					_rework_hit_effects(p, s)
					_ricochet(p.source, p.target, p.damage)
				_emit({"type": "arrow_hit", "pos": p.pos, "shred": p.shred > 0.0, "crit": p.crit, "look": p.look})



## On-hit effects of the reworked towers' rounds: a stun chance (Shock Rounds) and a burn (Incendiary Rounds).
func _rework_hit_effects(p, s: Dictionary) -> void:
	var e = p.target
	if e == null or not e.alive:
		return
	var chance := float(s.get("stun_chance", 0.0))
	if chance > 0.0 and _roll(chance):
		e.apply_stun(float(s.get("stun_time", 0.3)) * _boss_factor(e))
		_emit({"type": "stun_hit", "pos": e.pos})
	var ignite := float(s.get("ignite_dps", 0.0))
	if ignite > 0.0:
		e.apply_burn(ignite, float(s.get("ignite_time", 2.0)))


## A deterministic chance roll (crits, stun chances) from the run's seed and a counter.
func _roll(chance: float) -> bool:
	_roll_count += 1
	var h := sin(float(seed_value % 100003) * 12.9898 + float(_roll_count) * 78.233) * 43758.5453
	return (h - floor(h)) < chance


func _update_pools(dt: float) -> void:
	if pools.is_empty():
		return
	var keep: Array = []
	for pool in pools:
		pool["t"] = float(pool.t) - dt
		var r: float = pool.r
		for e in enemies:
			if e.alive and not e.flying and e.pos.distance_squared_to(pool.pos) <= r * r:
				damage_enemy(e, float(pool.dps) * dt, true, pool.source, false)
		if pool.t > 0.0:
			keep.append(pool)
	pools = keep


func _chain(t, first, s: Dictionary) -> void:
	if float(s.get("storm_on_hit", 0.0)) > 0.0:
		storms.append({"pos": first.pos, "r": float(s.storm_radius), "dps": float(s.storm_dps), "t": float(s.storm_on_hit), "source": t})
		_emit({"type": "storm_zone", "pos": first.pos, "radius": float(s.storm_radius), "time": float(s.storm_on_hit)})
	var hit: Array = [first]
	var points: Array = [t.pos + Vector2(0, -6), first.pos]
	var dmg: float = t.eff_damage()
	var cur = first
	var chain_r := float(s.chain_range)
	var n := int(s.chains)
	var stun := float(s.get("stun", 0.0))
	for k in n:
		if stun > 0.0:
			cur.apply_stun(stun * (BOSS_STUN_FACTOR if cur.boss else 1.0))
		var dealt := damage_enemy(cur, dmg, false, t)
		_emit({"type": "hit", "pos": cur.pos, "amount": dealt, "kind": "tesla"})
		if k == n - 1:
			break
		var nxt = null
		var nd := chain_r * chain_r
		for e in enemies:
			if not e.alive or hit.has(e):
				continue
			var d2: float = e.pos.distance_squared_to(cur.pos)
			if d2 <= nd:
				nd = d2
				nxt = e
		if nxt == null:
			break
		hit.append(nxt)
		points.append(nxt.pos)
		cur = nxt
		dmg *= float(s.falloff)
	_emit({"type": "chain", "points": points, "tier": t.tier, "spec": t.spec})


func _update_abilities(dt: float) -> void:
	for k in ability_cd:
		ability_cd[k] = maxf(0.0, float(ability_cd[k]) - dt)
	if warp_timer > 0.0:
		warp_timer = maxf(0.0, warp_timer - dt)
		var slow := float(Abilities.ABILITIES.warp.slow)
		for e in enemies:
			if e.alive:
				e.apply_slow(slow, 0.25)
	if strikes.is_empty():
		return
	var pending: Array = []
	for s in strikes:
		s["t"] = float(s.t) - dt
		if s.t > 0.0:
			pending.append(s)
			continue
		var r: float = s.radius
		for e in enemies:
			if e.alive and e.pos.distance_squared_to(s.pos) <= r * r:
				var dealt := damage_enemy(e, float(s.damage), true, null)
				_emit({"type": "hit", "pos": e.pos, "amount": dealt, "kind": "meteor"})
		_emit({"type": "meteor_impact", "pos": s.pos, "radius": r})
	strikes = pending


## Pylons boost towers in their field. Boosts don't stack: each stat takes the strongest pylon.
func _recompute_buffs() -> void:
	for t in towers:
		t.buff_dmg = 0.0
		t.buff_rate = 0.0
		t.buff_range = 0.0
		t.buff_crit = 0.0
		t.aug_crit_mult = 2.0
		t.aug_energy = 0.0
		t.aug_energy_bonus = 0.0
		t.aug_ricochet = 0.0
		t.aug_ricochet_str = 0.5
		t.aug_bounce_again = false
	for a in towers:
		if not a.is_support() or a.is_economy() or a.disabled > 0.0:
			continue
		var s: Dictionary = a.stats()
		var r: float = a.get_range()
		if a.type == "augmentation_tower":
			_apply_augmentation(a, s, r)
			continue
		# The Boost Tower's Retrofit adds a flat share on top of whatever each boost is (the strongest of each kind still wins).
		var extra := float(s.get("buff_extra", 0.0))
		for t in towers:
			if t.is_support() or a.pos.distance_squared_to(t.pos) > r * r:
				continue
			t.buff_dmg = maxf(t.buff_dmg, float(s.get("buff_dmg", 0.0)) + (extra if s.has("buff_dmg") else 0.0))
			t.buff_rate = maxf(t.buff_rate, float(s.get("buff_rate", 0.0)) + (extra if s.has("buff_rate") else 0.0))
			t.buff_range = maxf(t.buff_range, float(s.get("buff_range", 0.0)) + (extra if s.has("buff_range") else 0.0))
			t.buff_crit = maxf(t.buff_crit, float(s.get("crit_link", 0.0)))
	_recompute_economy()


## Scrapyards: Supply Depot discounts and sell refunds on towers in their fields, and the list of
## Scrap Collectors that raise kill credits. None of it stacks: each takes the best Scrapyard.
func _recompute_economy() -> void:
	collectors.clear()
	for t in towers:
		t.discount = 0.0
		t.refund_field = 0.0
	for a in towers:
		if not a.is_economy():
			continue
		var s: Dictionary = a.stats()
		if float(s.get("bounty_bonus", 0.0)) > 0.0:
			collectors.append(a)
		var disc := float(s.get("discount", 0.0))
		var refund := float(s.get("sell_field", 0.0))
		if disc <= 0.0 and refund <= 0.0:
			continue
		var r: float = a.get_range()
		for t in towers:
			if t.is_economy() or a.pos.distance_squared_to(t.pos) > r * r:
				continue
			t.discount = maxf(t.discount, disc)
			t.refund_field = maxf(t.refund_field, refund)


## Credits every Scrapyard pays at a round clear (scaled like kill credits), plus Reserve Bank
## interest on the credits already banked (the best bank only). Returns [[pos, amount], ...].
func _pay_income(w: int) -> Array:
	var paid: Array = []
	var rate := 0.0
	var cap := 0.0
	for t in towers:
		if not t.is_economy():
			continue
		var s: Dictionary = t.stats()
		var amount := roundi(float(s.get("income", 0.0)) * Waves.bounty_scale(w))
		if float(s.get("interest", 0.0)) > rate:
			rate = float(s.interest)
			cap = float(s.get("interest_cap", 0.0))
		if amount > 0:
			paid.append([t.pos, amount])
	var interest := mini(int(cap), int(floor(float(gold) * rate)))
	for p in paid:
		_add_gold(int(p[1]))
	if interest > 0:
		_add_gold(interest)
		paid.append([Vector2(-1, -1), interest])
	return paid


## Scrap Collector bonus for a kill at the enemy's position: the best collector in range applies.
func _salvage_mult(e) -> float:
	var best := 1.0
	for a in collectors:
		if a.pos.distance_squared_to(e.pos) > a.get_range() * a.get_range():
			continue
		var s: Dictionary = a.stats()
		var m := 1.0 + float(s.bounty_bonus)
		if e.boss:
			m *= float(s.get("boss_bounty", 1.0))
		best = maxf(best, m)
	return best


func _kill(e, source) -> void:
	if e.hologram:
		e.hp = 0.0
		_vanish(e)
		_emit({"type": "hologram_pop", "pos": e.pos})
		return
	e.alive = false
	e.hp = 0.0
	if e.has_trait("holo"):
		for h in enemies + _new_enemies:
			if h.alive and h.hologram and h.holo_owner == e:
				_vanish(h)
	# Kill credits scale with the round's HP, and bounty research pays fractional credits; the remainder carries over to the next kill.
	bounty_carry += float(e.bounty) * Waves.bounty_scale(e.wave_id) * (1.0 + float(run_mods.bounty)) * _salvage_mult(e)
	var gain := int(floor(bounty_carry + 1e-6))
	bounty_carry = maxf(0.0, bounty_carry - float(gain))
	_add_gold(gain)
	stats["kills"] += 1
	if source != null:
		source.kills += 1
		if source is Tower and bool(source.stats().get("swivel", false)):
			source.cooldown = 0.0   # Swivel Mount: a new target at once after a kill
	_emit({"type": "kill", "pos": e.pos, "enemy": e.type, "bounty": gain, "boss": e.boss})
	if e.has_trait("split"):
		# Hydra Frame: the pieces keep walking from where it fell. Added after this tick's loops.
		var n := int(e.def.split_count)
		var hp_mult := hp_mult_for(e.wave_id) if e.wave_id > 0 else 1.0
		var speed_mult := speed_mult_for(e.wave_id) if e.wave_id > 0 else 1.0
		for k in n:
			var off := (float(k) - float(n - 1) / 2.0) * 12.0
			var piece = spawn_enemy(str(e.def.split_type), e.path_index, clampf(e.distance + off, 0.0, e.path_len - 1.0), hp_mult, e.wave_id, speed_mult)
			_new_enemies.append(piece)
		if wave_remaining.has(e.wave_id):
			wave_remaining[e.wave_id] += n
		_emit({"type": "split", "pos": e.pos, "count": n})
	_enemy_removed(e)


func _leak(e) -> void:
	e.alive = false
	if not sandbox:
		lives = maxi(0, lives - e.lives_cost)
	stats["leaked"] += 1
	_emit({"type": "leak", "pos": e.pos, "lives": e.lives_cost, "enemy": e.type})
	if lives <= 0 and state != State.GAMEOVER:
		state = State.GAMEOVER
		_emit({"type": "gameover", "wave": wave})
	_enemy_removed(e)


func _enemy_removed(e) -> void:
	var w: int = e.wave_id
	if not wave_remaining.has(w):
		return
	wave_remaining[w] -= 1
	if wave_remaining[w] <= 0:
		wave_remaining.erase(w)
		if state == State.GAMEOVER:
			return
		var bonus := Waves.clear_bonus(w)
		_add_gold(bonus)
		stats["waves_cleared"] += 1
		_emit({"type": "wave_clear", "wave": w, "bonus": bonus})
		var paid := _pay_income(w)
		if not paid.is_empty():
			_emit({"type": "income", "paid": paid})


func _on_field_clear() -> void:
	# Reset transient combat state so a save made now fully describes the game.
	state = State.BUILD
	auto_timer = 0.0
	projectiles.clear()
	strikes.clear()
	pools.clear()
	storms.clear()
	mines.clear()
	smokes.clear()
	trails.clear()
	warp_timer = 0.0
	for t in towers:
		t.cooldown = 0.0
		t.target = null
		t.fire_flash = 0.0
		t.ramp = 0.0
		t.ramp_mult = 1.0
		t.beam_targets.clear()
		t.disabled = 0.0
	if sandbox and not endless and wave >= final_round():
		# A test bench earns nothing: past the last round it just carries on, endless.
		endless = true
		_emit({"type": "field_clear", "wave": wave})
	elif not endless and wave >= final_round():
		# The mode's last round is held: the medal is earned and endless mode begins right away.
		medal = true
		endless = true
		_emit({"type": "medal", "wave": wave})
	else:
		_emit({"type": "field_clear", "wave": wave})


func _add_gold(n: int) -> void:
	gold += n
	stats["gold_earned"] += n


func _emit(ev: Dictionary) -> void:
	if emit_events:
		events.append(ev)


# --- Persistence ---------------------------------------------------------------------------

func to_save() -> Dictionary:
	var tl: Array = []
	for t in towers:
		tl.append({
			"type": t.type, "col": t.cell.x, "row": t.cell.y, "depth": t.depth.duplicate(),
			"aim_x": t.aim_point.x, "aim_y": t.aim_point.y, "shell": t.shell, "loadout": t.loadout, "masteries": t.mastered_paths.duplicate(),
			"retrofit": t.retrofit, "started": t.started.duplicate(), "mastery": t.mastered, "mode": t.mode, "priority": t.priority, "kills": t.kills, "spent": t.spent,
		})
	return {
		"version": SAVE_VERSION,
		"map_id": map_id,
		"difficulty": difficulty,
		"ability_cd": ability_cd.duplicate(),
		"wave": wave,
		"gold": gold,
		"lives": lives,
		"endless": endless,
		"medal": medal,
		"auto_start": auto_start,
		"speed": speed,
		"seed": seed_value,
		"spawn_counter": _spawn_counter,
		"time": time,
		"stats": stats.duplicate(),
		"research": research.duplicate(),
		"bounty_carry": bounty_carry,
		"cleared": cleared.keys().map(func(c): return [c.x, c.y]),
		"gates": gates.duplicate(),
		"route_counters": route_counters.duplicate(),
		"towers": tl,
		"saved_at": int(Time.get_unix_time_from_system()),
	}


## Restores a saved tower's upgrade state after checking it follows the branch rules.
func _restore_upgrades(t, entry: Dictionary) -> String:
	t.loadout = str(entry.get("loadout", "gun"))
	if (t.type == "artillery_cannon" or t.type == "cas_gunship") and entry.has("aim_x"):
		t.aim_point = Vector2(float(entry.aim_x), float(entry.aim_y))
		t.aim_set = true
		t.shell = str(entry.get("shell", "he"))
	# An optional Retrofit (one of its options, -1 for none) and three open paths.
	var ro := int(entry.get("retrofit", -1))
	if ro < -1 or ro >= t.retrofit_options().size():
		return "invalid Retrofit option %d." % ro
	t.retrofit = ro
	var dep = entry.get("depth", {})
	var st = entry.get("started", [])
	if not (dep is Dictionary) or not (st is Array):
		return "malformed upgrade state."
	var deep := 0
	for b in Tower.BRANCHES:
		var d := int(dep.get(b, 0))
		if d < 0 or d > Tower.BRANCH_STEPS:
			return "branch %s has invalid depth %d." % [b, d]
		if d > 0 and not st.has(b):
			return "branch %s has upgrades but was never started." % b
		if d >= 3:
			deep += 1
		t.depth[b] = d
	for b in st:
		if not (str(b) in Tower.BRANCHES) or int(t.depth[str(b)]) == 0:
			return "invalid started branch list."
		t.started.append(str(b))
	if not t.is_uncapped() and (t.started.size() > 2 or deep > 1):
		return "upgrades break the branch rules."
	if t.is_uncapped():
		var ms = entry.get("masteries", [])
		if not (ms is Array):
			return "malformed masteries."
		for k in ms:
			if not (str(k) in Tower.BRANCHES) or int(t.depth[str(k)]) < Tower.BRANCH_STEPS or t.mastered_paths.has(str(k)):
				return "invalid mastery path."
			t.mastered_paths.append(str(k))
		t.mastered = not t.mastered_paths.is_empty()
		t.invalidate()
		if t.mastered and not t.mastery_unlocked():
			return "it has a mastery, but this run has no %s research." % (Research.tree_name(t.type) + " Mastery")
		return ""
	t.mastered = bool(entry.get("mastery", false))
	t.invalidate()
	if t.mastered:
		if not t.mastery_unlocked():
			return "it has a mastery, but this run has no %s research." % (Research.tree_name(t.type) + " Mastery")
		if t.primary() == "" or int(t.depth[t.primary()]) < Tower.BRANCH_STEPS:
			return "it has a mastery before finishing its branch."
	return ""

## Restores state from a decoded (and migrated) save. Returns "" on success or a readable error.
func apply_save(data: Dictionary) -> String:
	wave = maxi(0, int(data.wave))
	gold = maxi(0, int(data.gold))
	lives = int(data.lives)
	medal = bool(data.get("medal", false)) or wave >= final_round()
	endless = medal
	auto_start = bool(data.get("auto_start", false))
	speed = clampi(int(data.get("speed", 1)), 1, 3)
	_spawn_counter = maxi(0, int(data.get("spawn_counter", 0)))
	time = float(data.get("time", 0.0))
	bounty_carry = clampf(float(data.get("bounty_carry", 0.0)), 0.0, 1.0)
	cleared.clear()
	var cl = data.get("cleared", [])
	if not (cl is Array):
		return "Cleared-rubble list is malformed."
	for entry in cl:
		if not (entry is Array) or entry.size() != 2:
			return "A cleared-rubble entry is malformed."
		var c := Vector2i(int(entry[0]), int(entry[1]))
		if grid.tile_at(c) != "R":
			return "Save clears rubble at %s, but there is none there." % c
		cleared[c] = true
	var gs = data.get("gates", [])
	if gs is Array:
		for gi in mini(gs.size(), gates.size()):
			gates[gi] = clampi(int(gs[gi]), 0, grid.groups[gi].routes.size())
	var rc = data.get("route_counters", [])
	if rc is Array:
		for gi in mini(rc.size(), route_counters.size()):
			route_counters[gi] = maxi(0, int(rc[gi]))
	var st = data.get("stats", {})
	if st is Dictionary:
		for k in STAT_KEYS:
			stats[k] = int(st.get(k, 0))
	var cds = data.get("ability_cd", {})
	if cds is Dictionary:
		for a in Abilities.ORDER:
			ability_cd[a] = clampf(float(cds.get(a, 0.0)), 0.0, ability_cooldown(a))
	towers.clear()
	tower_at.clear()
	for entry in data.towers:
		if not (entry is Dictionary):
			return "A tower entry is malformed."
		var type := str(entry.get("type", ""))
		if not Towers.has(type):
			return "Unknown tower type '%s'." % type
		var cell := Vector2i(int(entry.get("col", -1)), int(entry.get("row", -1)))
		var tiles := footprint(type, cell)
		if size_of(type) > 1 and tiles.any(func(c): return not is_buildable(c) or tower_at.has(c)):
			# A Scrapyard or Drone Bay from before they were 2x2 whose footprint doesn't fit: refund it.
			gold += maxi(0, int(entry.get("spent", 0)))
			continue
		if not is_buildable(cell):
			return "Tower at %s is not on a buildable tile." % cell
		if tower_at.has(cell):
			return "Two towers share tile %s." % cell
		var t = Tower.new()
		t.setup(type, cell, footprint_center(type, cell), tower_mods[type])
		t.site = footprint_site(type, cell)
		var err := _restore_upgrades(t, entry)
		if err != "":
			return "Tower at %s: %s" % [cell, err]
		t.mode = clampi(int(entry.get("mode", 0)), 0, Tower.MODE_NAMES.size() - 1)
		t.priority = clampi(int(entry.get("priority", 0)), 0, Tower.PRIORITY_NAMES.size() - 1)
		t.kills = maxi(0, int(entry.get("kills", 0)))
		t.spent = maxi(0, int(entry.get("spent", t.spent)))
		towers.append(t)
		for c in tiles:
			tower_at[c] = t
	_recompute_buffs()
	state = State.BUILD
	return ""
