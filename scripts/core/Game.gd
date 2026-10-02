extends RefCounted
## Deterministic tower-defense simulation. No nodes, no rendering, no file I/O.
## The view layer calls tick() at a fixed step and drains `events` for effects and sound;
## headless tests drive the exact same code thousands of ticks at a time.

const Towers = preload("res://data/towers.gd")
const Enemies = preload("res://data/enemies.gd")
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
const SAVE_VERSION := 9
## Credits every run starts with, on every sector and mode (before research).
const START_GOLD := 500
const AUTO_START_DELAY := 5.0
const RETARGET_DELAY := 0.1
const STAT_KEYS := ["kills", "gold_earned", "towers_built", "leaked", "waves_cleared"]
const BOSS_STUN_FACTOR := 0.3
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
## Short-lived damage zones (an Ion Storm secondary on a chaining Arc Coil).
var storms: Array = []

## Nested mini-nova depth, so a chain of kills can't recurse forever.
var _nova_depth := 0
var wave := 0
var endless := false
## This run has cleared its mode's last round (the sector's medal for the mode is earned).
var medal := false
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
	for type in Towers.ORDER:
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
	for type in Towers.ORDER:
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
	return state == State.BUILD and is_idle()


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
	return Waves.get_wave(n, _wave_rng(n), final_round())


func tower_cost(type: String) -> int:
	return Research.discounted(int(Tower.tree(type).tiers[0].cost), tower_mods[type])


func sell_value(t) -> int:
	return int(floor(t.spent * maxf(sell_refund, t.refund_field)))


## A tower level's stats as they'd be in this run (research applied). Tier 1-2 is the trunk; tier 3
## is the branch of `spec` (a specialization id or branch key) at `depth` upgrades; tier 4 is its mastery.
func level_stats(type: String, tier: int, spec := "", depth := 1) -> Dictionary:
	var ln := Tower.lines(type)
	var base: Dictionary = ln.t1 if tier <= 1 else ln.t2
	if tier >= Tower.SPEC_TIER:
		var key := ""
		for b in Tower.tree(type).branches:
			if b.key == spec or b.id == spec:
				key = b.key
		if key != "":
			base = ln[key + "_m"] if tier >= Tower.MASTERY_TIER else ln[key][clampi(depth, 1, Tower.BRANCH_STEPS)]
	return Research.apply(base, tower_mods[type])


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
	return int(Towers.TOWERS[type].get("size", 1))


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
			if e.alive and not e.flying and grid.route_group[e.path_index] == gi and e.path_index != open_route and e.distance < fork_dist:
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
	gold -= t.spent
	towers.append(t)
	for c in footprint(type, cell):
		tower_at[c] = t
	stats["towers_built"] += 1
	_recompute_buffs()
	_emit({"type": "build", "pos": t.pos, "tower": type})
	return t


## Tier 1 -> 2 needs no spec. Tier 2 -> 3 needs one of the tower's spec ids.
## Tier 3 -> 4 (the spec's mastery) needs no spec, but needs that tower's Mastery research.
## Buys the next upgrade on a tower. At tier 1 that's Tier 2. After that `key` picks the branch (a
## branch key or its specialization id); without one it continues the primary branch.
func upgrade_tower(t, key := "") -> bool:
	if is_over():
		return false
	var branch := ""
	if t.trunk >= 2:
		branch = t.resolve_key(key)
		if branch == "" or not t.can_buy(branch):
			return false
	var cost: int = t.upgrade_cost(branch)
	if cost <= 0 or gold < cost:
		return false
	var was_mastered: bool = t.tier >= 4
	gold -= cost
	t.spent += cost
	if t.trunk < 2:
		t.trunk = 2
	else:
		t.buy(branch)
	_recompute_buffs()
	# "mastery" is only for the purchase that reaches the mastery, not later secondary upgrades.
	_emit({"type": "upgrade", "pos": t.pos, "tier": t.tier, "spec": t.spec, "branch": branch, "depth": int(t.depth.get(branch, 0)) if branch != "" else 0, "mastery": not was_mastered and t.tier >= 4})
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
	var groups := preview_wave(wave)
	var hp_mult := hp_mult_for(wave)
	var total := 0
	var boss := false
	var n_groups: int = grid.groups.size()
	for g in groups:
		var etype: String = g.t
		var count := int(g.n)
		var interval := float(g.get("i", 1.0))
		var delay := float(g.get("d", 0.0))
		var is_boss := bool(Enemies.ENEMIES[etype].get("boss", false))
		if is_boss:
			boss = true
		var speed_mult := speed_mult_for(wave, is_boss)
		for k in count:
			spawn_queue.append({
				"time": time + delay + k * interval,
				"type": etype,
				"wave": wave,
				"group": _spawn_counter % n_groups,
				"hp_mult": hp_mult,
				"speed_mult": speed_mult,
			})
			_spawn_counter += 1
			total += 1
	spawn_queue.sort_custom(func(a, b): return a.time < b.time)
	wave_remaining[wave] = total
	_emit({"type": "wave_start", "wave": wave, "boss": boss})
	return true


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
	ability_cd["meteor"] = ability_cooldown("meteor")
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
	ability_cd["warp"] = ability_cooldown("warp")
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
	if state == State.BUILD:
		if auto_start:
			auto_timer += dt
			if auto_timer >= AUTO_START_DELAY:
				start_wave()
		return

	while not spawn_queue.is_empty() and float(spawn_queue[0].time) <= time:
		var s: Dictionary = spawn_queue.pop_front()
		enemies.append(spawn_enemy(s.type, _pick_route(int(s.get("group", 0))), 0.0, float(s.hp_mult), int(s.wave), float(s.get("speed_mult", 1.0))))

	_update_abilities(dt)
	_update_pools(dt)
	_update_storms(dt)

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
func spawn_enemy(type: String, path_idx: int, start_dist := 0.0, hp_mult := 1.0, wave_id := -1, speed_mult := 1.0):
	var e = Enemy.new()
	var flying := bool(Enemies.ENEMIES[type].get("flying", false))
	var route: Curve2D = grid.air_paths[path_idx] if flying else grid.ground_paths[path_idx]
	e.setup(type, route, hp_mult, wave_id, path_idx, start_dist, speed_mult)
	e.id = _next_enemy_id
	_next_enemy_id += 1
	if e.boss:
		_emit({"type": "boss_spawn", "enemy": type, "pos": e.pos})
	return e


## Deals damage after vulnerability, energy barrier and armor. Returns the damage actually dealt.
## A barrier soaks damage before armor applies; Arc Coils hit barriers twice as hard.
func damage_enemy(e, amount: float, pierce: bool, source, flash := true, bypass_shield := false, reach_burrowed := false) -> float:
	if not e.alive or (e.burrowed and not reach_burrowed):
		return 0.0
	e.since_hit = 0.0
	var amt := amount
	if e.vuln_timer > 0.0:
		amt *= 1.0 + e.vuln_amount
	var absorbed := 0.0
	if e.shield > 0.0 and not bypass_shield:
		var mult := 1.0
		if source is Tower:
			mult = (SHIELD_EMP_MULT if source.type == "tesla" else 1.0) * float(source.stats().get("shield_mult", 1.0))
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
	var dealt := Enemy.mitigate(amt, e.effective_armor(), pierce)
	if source != null:
		source.damage_dealt += absorbed
	e.hp -= dealt
	if flash:
		e.hit_flash = 0.08
	if source != null:
		source.damage_dealt += dealt
	if e.hp <= 0.0:
		_kill(e, source)
	elif e.def.has("phases"):
		_check_phase(e)
	return dealt + absorbed


## Best target in range for the tower's targeting mode, skipping anything in `exclude`.
func pick_target(t, exclude: Array = []):
	var air: bool = t.hits_air()
	var ground: bool = t.hits_ground()
	# A tower that hits both can prefer one kind; with none of that kind in range it takes the other.
	if air and ground and t.priority != 0:
		var want_air: bool = t.priority == 1
		var pick = _pick_target(t, exclude, want_air, not want_air)
		if pick != null:
			return pick
	return _pick_target(t, exclude, air, ground)


func _pick_target(t, exclude: Array, air: bool, ground: bool):
	var r: float = t.get_range()
	var r2 := r * r
	var best = null
	var best_score := -INF
	for e in enemies:
		if not e.alive or (e.flying and not air) or (not e.flying and not ground) or e.is_hidden() or exclude.has(e):
			continue
		var d2: float = t.pos.distance_squared_to(e.pos)
		if d2 > r2:
			continue
		var score := _score(t, e, d2)
		if score > best_score:
			best_score = score
			best = e
	return best


func _score(t, e, d2: float) -> float:
	if t.mode == Tower.Mode.FIRST:
		return e.progress()
	if t.mode == Tower.Mode.LAST:
		return -e.progress()
	if t.mode == Tower.Mode.STRONG:
		return e.hp
	return -d2


func _update_enemy(e, dt: float) -> void:
	e.step(dt)
	var d: Dictionary = e.def
	if d.has("burrow_interval"):
		# Burrower: dives for burrow_time, then surfaces for the rest of the interval.
		var grounded: bool = e.silenced() or e.no_dig > 0.0 or e.disrupt_timer > 0.0
		if grounded and e.burrowed:
			e.burrowed = false
			e.burrow_timer = float(d.burrow_interval) - float(d.burrow_time)
			_emit({"type": "burrow", "pos": e.pos, "down": false})
		if not grounded:
			e.burrow_timer -= dt
		if not grounded and e.burrow_timer <= 0.0:
			e.burrowed = not e.burrowed
			e.burrow_timer = float(d.burrow_time) if e.burrowed else float(d.burrow_interval) - float(d.burrow_time)
			_emit({"type": "burrow", "pos": e.pos, "down": e.burrowed})
	if not e.flying and not e.burrowed and not grid.hazards.is_empty():
		match grid.hazards.get(Grid.world_to_cell(e.pos), ""):
			"sludge":
				e.apply_slow(SLUDGE_SLOW, 0.2)
			"shock":
				damage_enemy(e, e.max_hp * (SHOCK_BOSS_PCT if e.boss else SHOCK_PCT) * dt, true, null, false)
				if not e.alive:
					return
	if e.dot_timer > 0.0:
		damage_enemy(e, e.dot_dps * dt, true, null, false)
		if not e.alive:
			return
	if d.has("blink_interval") and e.stun_timer <= 0.0 and not e.silenced() and e.disrupt_timer <= 0.0:
		# Blink Stalker: jumps ahead along its route (a slow or stun resets the charge, in Enemy).
		e.blink_timer -= dt
		if e.blink_timer <= 0.0:
			e.blink_timer = float(d.blink_interval)
			var from: Vector2 = e.pos
			e.distance = minf(e.distance + float(d.blink_distance), e.path_len)
			e.pos = e.curve.sample_baked(e.distance)
			_emit({"type": "blink", "from": from, "pos": e.pos})
	if d.has("heal_pct") and not e.silenced():
		e.ability_timer -= dt
		if e.ability_timer <= 0.0:
			e.ability_timer = float(d.heal_interval)
			var heal_r: float = d.heal_radius
			var healed := false
			for o in enemies:
				if o.alive and not o.boss and o.hp < o.max_hp and o.repair_block <= 0.0 and o.jam_timer <= 0.0 and o.pos.distance_squared_to(e.pos) <= heal_r * heal_r:
					o.hp = minf(o.max_hp, o.hp + o.max_hp * float(d.heal_pct))
					healed = true
			_emit({"type": "heal", "pos": e.pos, "radius": heal_r, "active": healed})
	if d.has("spawn_type") and not e.silenced(2):
		e.ability_timer -= dt
		if e.ability_timer <= 0.0:
			e.ability_timer = float(d.spawn_interval)
			_spawn_minions(e, str(d.spawn_type), int(d.spawn_count))
			_emit({"type": "minions", "pos": e.pos, "enemy": e.type})
	if d.has("emp_interval") and not e.silenced(2):
		e.ability_timer -= dt
		if e.ability_timer <= 0.0:
			e.ability_timer = float(d.emp_interval)
			var er := float(d.emp_radius)
			var hit := 0
			for t in towers:
				if t.pos.distance_squared_to(e.pos) <= er * er:
					t.disabled = maxf(t.disabled, float(d.emp_duration))
					hit += 1
			_emit({"type": "emp", "pos": e.pos, "radius": er, "hit": hit})
	if d.has("grant_interval") and not e.silenced():
		# Bulwark: projects a barrier onto nearby non-boss enemies (not itself).
		e.ability_timer -= dt
		if e.ability_timer <= 0.0:
			e.ability_timer = float(d.grant_interval)
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
	if e.reached_end():
		_leak(e)


## Rally Beacons: every other non-boss enemy near one moves faster. Recomputed each tick.
func _update_auras() -> void:
	var beacons: Array = []
	for e in enemies:
		e.haste = 0.0
		if e.alive and e.def.has("aura_radius") and not e.silenced():
			beacons.append(e)
	for b in beacons:
		var r := float(b.def.aura_radius)
		var h := float(b.def.aura_haste)
		for o in enemies:
			if o != b and o.alive and not o.boss and o.jam_timer <= 0.0 and o.pos.distance_squared_to(b.pos) <= r * r:
				o.haste = maxf(o.haste, h)


## Colossus: passing a health threshold sheds armor, speeds it up and drops escorts.
func _check_phase(e) -> void:
	var th: Array = e.def.phases
	while e.phase < th.size() and e.hp <= e.max_hp * float(th[e.phase]):
		e.phase += 1
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
	if t.disabled > 0.0:
		t.disabled = maxf(0.0, t.disabled - dt)
		t.target = null
		t.beam_targets.clear()
		t.ramp = 0.0
		t.ramp_mult = 1.0
		return
	if t.is_economy():
		return
	var s: Dictionary = t.stats()
	if t.is_sensor():
		_sensor_sweep(t)
		return
	if t.is_support():
		_support_field(t, s)
		return
	if t.type == "drones":
		_update_drones(t, s, dt)
		return
	if t.is_beam():
		if t.spec == "sweeper":
			_update_sweeper(t, s, dt)
		else:
			_update_laser(t, dt)
		return
	if t.type == "nova" and float(s.get("aura_dps", 0.0)) > 0.0:
		_nova_aura(t, s, dt)
	if t.target != null and not t.can_target(t.target):
		t.target = null
	t.cooldown -= dt
	if t.cooldown > 0.0:
		return

	match t.type:
		"frost":
			_frost_pulse(t, s)
			return
		"gravity":
			if t.spec == "well":
				_gravity_well(t, s)
			else:
				_gravity_pulse(t, s)
			return
		"missile":
			_fire_missiles(t, s)
			return
		"nullifier":
			_null_pulse(t, s)
			return
		"nova":
			_nova_pulse(t, s)
			return
		"tesla":
			if t.spec == "ionstorm":
				_ion_storm(t, s)
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
		"arrow":
			if t.spec == "flechette":
				_flechette(t, float(s.get("pellets", 6.0)), float(s.get("cone", 45.0)), bool(s.get("bypass_shield", false)))
				return
			_fire_volley(t, target, s)
			var every := int(s.get("flechette_every", 0))
			t.pulse_count += 1
			if every > 0 and t.pulse_count % every == 0:
				_flechette(t, float(s.flechette_pellets), float(s.flechette_cone), false)
		"cannon", "flak":
			_fire_volley(t, target, s)
		"sniper":
			_fire_rail(t, target, s)
		"tesla":
			_chain(t, target, s)


## One volley of projectiles, plus Multishot's extra targets (Storm Gatling).
func _fire_volley(t, target, s: Dictionary) -> void:
	_fire_projectile(t, target, s)
	var shots: Array = [target]
	for k in int(s.get("multishot", 1)) - 1:
		var extra = pick_target(t, shots)
		if extra == null:
			break
		shots.append(extra)
		_fire_projectile(t, extra, s)


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


## Flechette: every enemy in a cone in front of the tower takes half the flechettes.
func _flechette(t, pellets: float, cone_deg: float, bypass: bool) -> void:
	var r: float = t.get_range()
	var half := deg_to_rad(cone_deg) * 0.5
	var dmg: float = t.eff_damage() * float(ceili(pellets / 2.0))
	for e in _enemies_near(t.pos, r, t.hits_air(), t.hits_ground()):
		if absf(angle_difference(t.aim, (e.pos - t.pos).angle())) <= half:
			var d := damage_enemy(e, dmg, false, t, true, bypass)
			_emit({"type": "hit", "pos": e.pos, "amount": d, "kind": "arrow"})
	_emit({"type": "flechette", "pos": t.pos, "aim": t.aim, "cone": cone_deg, "range": r, "tier": t.tier, "pellets": int(round(pellets))})


## Amplifier Pylon branch C: jams enemy support (and at the mastery, everything) inside its field.
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


## Moves `e` along its route toward the point nearest `p`, by at most `amount` px. Pulling it
## backwards counts against its shove budget.
func _pull(e, p: Vector2, amount: float) -> void:
	var goal: float = e.curve.get_closest_offset(p)
	var move := clampf(goal - e.distance, -amount, amount)
	if move < 0.0:
		e.shove(-move)
	else:
		e.distance = minf(e.distance + move, e.path_len)
		e.pos = e.curve.sample_baked(e.distance)


## Graviton Projector branch C: pulls enemies together, holds them slower, and implodes.
func _gravity_well(t, s: Dictionary) -> void:
	var r: float = t.get_range()
	var targets := _enemies_near(t.pos, r, false, true)
	if targets.is_empty():
		t.cooldown = RETARGET_DELAY
		return
	t.pulse_count += 1
	var every := int(s.get("implode_every", 0))
	var implode: bool = every > 0 and t.pulse_count % every == 0
	var push := float(s.get("push", 0.0))
	var shove_turn: bool = push > 0.0 and t.pulse_count % 2 == 1
	var pull := float(s.get("pull", 50.0))
	var stun := float(s.get("stun", 0.0))
	var hold := float(s.get("slow", 0.0))
	for e in targets:
		var f := BOSS_PUSH_FACTOR if e.boss else 1.0
		if shove_turn:
			e.shove(push * f)
		else:
			_pull(e, t.pos, pull * f)
		if hold > 0.0:
			e.apply_slow(hold, 1.0 / t.eff_rate() + 0.2)
		if stun > 0.0:
			e.apply_stun(stun * _boss_factor(e))
		damage_enemy(e, t.eff_damage(), false, t)
		if implode and e.alive:
			damage_enemy(e, e.max_hp * float(s.implode_pct) * (0.25 if e.boss else 1.0), true, t)
	t.cooldown = 1.0 / t.eff_rate()
	t.fire_flash = 0.35
	_emit({"type": "gravity", "pos": t.pos, "radius": r, "tier": t.tier, "spec": t.spec, "pull": true, "implode": implode})


## Nullifier: strips barriers (and at deeper upgrades armor, immunities and abilities) in its field.
func _null_pulse(t, s: Dictionary) -> void:
	var r: float = t.get_range()
	var targets := _enemies_near(t.pos, r, true, true, true)
	if targets.is_empty():
		t.cooldown = RETARGET_DELAY
		return
	var dur: float = 1.0 / t.eff_rate() + 0.3
	var strip := float(s.get("strip", 0.0))
	var feedback := float(s.get("feedback", 0.0))
	var cascade := float(s.get("cascade", 0.0))
	var cascade_r := float(s.get("cascade_radius", 60.0))
	var armor_field := float(s.get("armor_field", 0.0))
	var dampen := bool(s.get("dampen", false))
	var linger := float(s.get("linger", 0.0))
	var boss_sup := float(s.get("suppress_boss", 0.0))
	for e in targets:
		if not e.alive:
			continue
		if strip > 0.0 and e.shield > 0.0:
			var taken: float = e.shield * minf(strip, 1.0)
			e.shield -= taken
			if e.shield <= 0.01:
				e.shield = 0.0
				_emit({"type": "shield_break", "pos": e.pos})
			if feedback > 0.0:
				damage_enemy(e, taken * feedback, true, t, true, true, true)
			if cascade > 0.0:
				for o in _enemies_near(e.pos, cascade_r):
					if o != e:
						damage_enemy(o, taken * cascade, true, t, false)
				_emit({"type": "cascade", "pos": e.pos, "radius": cascade_r})
		if not e.alive:
			continue
		if bool(s.get("expose", false)):
			e.expose_timer = maxf(e.expose_timer, dur)
		if armor_field > 0.0:
			e.apply_armor_break(armor_field, dur)
		if bool(s.get("block_barrier", false)):
			e.barrier_block = maxf(e.barrier_block, dur)
			e.grant_block = maxf(e.grant_block, dur)
		if dampen and (not e.boss or boss_sup > 0.0):
			e.suppress_timer = maxf(e.suppress_timer, (dur + linger) * (boss_sup if e.boss else 1.0))
		damage_enemy(e, t.eff_damage(), false, t, false, false, true)
	t.cooldown = 1.0 / t.eff_rate()
	t.fire_flash = 0.3
	_emit({"type": "null_pulse", "pos": t.pos, "radius": r, "spec": t.spec})


## Nova Reactor: a shockwave that hits everything around it, air and ground.
func _nova_pulse(t, s: Dictionary) -> void:
	var r: float = t.get_range()
	var targets := _enemies_near(t.pos, r, true, true, true)
	if targets.is_empty():
		t.cooldown = RETARGET_DELAY
		return
	var strip := float(s.get("strip", 0.0))
	var dmg: float = t.eff_damage()
	for e in targets:
		if not e.alive:
			continue
		if strip > 0.0 and e.shield > 0.0:
			e.shield *= 1.0 - strip
		damage_enemy(e, dmg, false, t)
	var burn := float(s.get("burn_dps", 0.0))
	if burn > 0.0:
		pools.append({"pos": t.pos, "r": r, "dps": burn, "t": float(s.get("burn_time", 2.0)), "source": t})
	t.cooldown = 1.0 / t.eff_rate()
	t.fire_flash = 0.35
	_emit({"type": "nova", "pos": t.pos, "radius": r, "spec": t.spec, "burn": burn > 0.0})


## Corona: a constant burning aura around the reactor.
func _nova_aura(t, s: Dictionary, dt: float) -> void:
	var dps: float = float(s.aura_dps) * (1.0 + t.buff_dmg)
	for e in _enemies_near(t.pos, t.get_range(), true, true, true):
		damage_enemy(e, dps * dt, true, t, false)


## Arc Coil branch C: a storm field that damages everything inside it several times a second.
func _ion_storm(t, s: Dictionary) -> void:
	var r: float = t.get_range()
	var targets := _enemies_near(t.pos, r)
	if targets.is_empty():
		t.cooldown = RETARGET_DELAY
		return
	var interval: float = 1.0 / t.eff_rate()
	var stun := float(s.get("stun", 0.0))
	var vuln := float(s.get("static_vuln", 0.0))
	for e in targets:
		e.storm_time = e.storm_time + interval if e.storm_until >= time else 0.0
		e.storm_until = time + interval + 0.1
		if vuln > 0.0 and e.storm_time >= 2.0:
			e.apply_vuln(vuln, interval + 0.2)
		if bool(s.get("block_grants", false)):
			e.grant_block = maxf(e.grant_block, interval + 0.2)
		if stun > 0.0:
			e.apply_stun(stun * _boss_factor(e))
		damage_enemy(e, t.eff_damage(), false, t, false)
	t.cooldown = interval
	t.fire_flash = 0.2
	_emit({"type": "storm_tick", "pos": t.pos, "radius": r})


## Short-lived storm zones (an Ion Storm secondary on a chaining Arc Coil).
func _update_storms(dt: float) -> void:
	if storms.is_empty():
		return
	var keep: Array = []
	for z in storms:
		z["t"] = float(z.t) - dt
		for e in _enemies_near(z.pos, float(z.r)):
			damage_enemy(e, float(z.dps) * dt, false, z.source, false)
		if z.t > 0.0:
			keep.append(z)
	storms = keep


## Laser Lance branch C: beams sweep back and forth across an arc, burning everything they cross.
func _update_sweeper(t, s: Dictionary, dt: float) -> void:
	var r: float = t.get_range()
	if t.target == null or not t.can_target(t.target):
		t.target = pick_target(t)
	if t.target == null:
		t.sweep_angles = []
		return
	var center: float = (t.target.pos - t.pos).angle()
	t.aim = center
	var beams := maxi(1, int(s.get("beams", 1)))
	var arc := deg_to_rad(float(s.get("sweep", 70.0)))
	t.sweep_t += dt * 1.6 * (1.0 + float(s.get("sweep_speed", 0.0)))
	var angles: Array = []
	for i in beams:
		var dir := 1.0 if i % 2 == 0 else -1.0
		angles.append(center + sin(t.sweep_t * dir + float(i) * PI / float(beams)) * arc * 0.5)
	t.sweep_angles = angles
	t.fire_flash = 0.05
	var dps: float = t.eff_damage()
	var burn := float(s.get("burn_dps", 0.0))
	for e in _enemies_near(t.pos, r, t.hits_air(), t.hits_ground()):
		var rel: Vector2 = e.pos - t.pos
		for a in angles:
			var off := absf(rel.rotated(-float(a)).y)
			if off <= e.radius + 4.0 and rel.dot(Vector2.from_angle(float(a))) > 0.0:
				damage_enemy(e, dps * dt, true, t, false)
				if burn > 0.0:
					e.apply_burn(burn, float(s.get("burn_time", 1.0)))
				break


## Drone Bay: keeps its wing at strength and flies every drone.
func _update_drones(t, s: Dictionary, dt: float) -> void:
	var want := {"gun": int(s.get("drones", 0)), "bomber": int(s.get("bombers", 0))}
	for kind in want:
		var have: Array = t.wing.filter(func(d): return d.kind == kind)
		for k in range(have.size(), int(want[kind])):
			t.wing.append({"kind": kind, "pos": t.pos, "target": null, "cd": 0.3 * float(k)})
		for k in range(int(want[kind]), have.size()):
			t.wing.erase(have[k])
	var speed := float(s.get("drone_speed", 170.0))
	var dmg: float = t.eff_damage()
	var air_mult := float(s.get("air_mult", 1.0))
	var reach_burrowed := bool(s.get("hits_burrowed", false))
	for i in t.wing.size():
		var d: Dictionary = t.wing[i]
		var bomber: bool = d.kind == "bomber"
		var tg = d.target
		if tg == null or not tg.alive or (tg.is_hidden() and not (bomber and reach_burrowed and tg.burrowed)) or (bomber and tg.flying):
			d["target"] = _drone_target(t, s, bomber)
			tg = d.target
		var goal: Vector2
		if tg == null:
			goal = t.pos + Vector2.from_angle(time * 1.4 + float(i) * TAU / maxf(1.0, float(t.wing.size()))) * 34.0
		elif bomber:
			goal = tg.pos
		else:
			goal = tg.pos + Vector2.from_angle(time * 2.0 + float(i)) * 44.0
		var v: float = speed * (0.75 if bomber else 1.0) * dt
		var to: Vector2 = goal - d.pos
		d["pos"] = goal if to.length() <= v else d.pos + to.normalized() * v
		d["cd"] = float(d.cd) - dt
		if tg == null or float(d.cd) > 0.0:
			continue
		if bomber:
			if d.pos.distance_to(tg.pos) > 20.0:
				continue
			var splash := float(s.get("bomb_splash", s.get("splash", 40.0)))
			for e in _enemies_near(d.pos, splash, false, true, reach_burrowed):
				damage_enemy(e, float(s.get("bomb_damage", 60.0)) * (1.0 + t.buff_dmg), false, t, true, false, reach_burrowed)
			d["cd"] = 2.2 / (1.0 + float(s.get("rate_pct", 0.0)))
			_emit({"type": "drone_bomb", "pos": d.pos, "radius": splash})
		else:
			if d.pos.distance_to(tg.pos) > 80.0:
				continue
			damage_enemy(tg, dmg * (air_mult if tg.flying else 1.0), false, t)
			var mark := float(s.get("mark", 0.0))
			if mark > 0.0:
				tg.apply_vuln(mark, 1.2)
			if bool(s.get("suppress_hit", false)) and not tg.boss:
				tg.suppress_timer = maxf(tg.suppress_timer, 1.0)
			d["cd"] = 1.0 / t.eff_rate()
			_emit({"type": "drone_shot", "from": d.pos, "to": tg.pos})


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
		if t.priority != 0 and e.flying == (t.priority == 1):
			score += 8.0
		score -= float(taken.get(e, 0)) * 3.0
		if score > best_score:
			best_score = score
			best = e
	return best


func _frost_pulse(t, s: Dictionary) -> void:
	var r: float = t.get_range()
	var hit := false
	var vuln := float(s.get("vuln", 0.0))
	for e in enemies:
		if e.alive and e.pos.distance_squared_to(t.pos) <= r * r:
			e.apply_slow(float(s.slow), float(s.slow_time))
			if bool(s.get("block_repair", false)):
				e.repair_block = maxf(e.repair_block, 1.0 / t.eff_rate() + 0.2 + float(s.get("linger", 0.0)))
			if bool(s.get("block_barrier", false)):
				e.barrier_block = maxf(e.barrier_block, 1.0 / t.eff_rate() + 0.2)
			if vuln > 0.0:
				e.apply_vuln(vuln, float(s.slow_time))
			damage_enemy(e, t.eff_damage(), false, t)
			hit = true
	if hit:
		t.cooldown = 1.0 / t.eff_rate()
		t.fire_flash = 0.3
		_emit({"type": "frost", "pos": t.pos, "radius": r, "tier": t.tier, "spec": t.spec})
	else:
		t.cooldown = RETARGET_DELAY


## Sensor Array: reveals cloaked enemies in its field and marks everything there (as vulnerability).
func _sensor_sweep(t) -> void:
	var r: float = t.get_range()
	var s: Dictionary = t.stats()
	var mark := float(s.get("mark", 0.0))
	var hold := REVEAL_TIME + float(s.get("linger", 0.0))
	var disrupt := bool(s.get("disrupt", false))
	var expose := bool(s.get("expose", false))
	for e in enemies:
		if e.alive and e.pos.distance_squared_to(t.pos) <= r * r:
			e.reveal_timer = maxf(e.reveal_timer, hold)
			if disrupt:
				e.disrupt_timer = maxf(e.disrupt_timer, hold)
			if expose:
				e.expose_timer = maxf(e.expose_timer, REVEAL_TIME)
			if mark > 0.0:
				e.apply_vuln(mark, hold)


## Graviton Projector: shoves ground enemies in range back along their route, then crushes them.
func _gravity_pulse(t, s: Dictionary) -> void:
	var r: float = t.get_range()
	var push := float(s.push)
	var alt := float(s.get("pull_alternate", 0.0))
	t.pulse_count += 1
	var pull_turn: bool = alt > 0.0 and t.pulse_count % 2 == 0
	var stun := float(s.get("stun", 0.0))
	var hit := false
	for e in enemies:
		if not e.alive or e.flying or e.pos.distance_squared_to(t.pos) > r * r:
			continue
		if pull_turn:
			_pull(e, t.pos, alt * (BOSS_PUSH_FACTOR if e.boss else 1.0))
		else:
			e.shove(push * (BOSS_PUSH_FACTOR if e.boss else 1.0))
		if stun > 0.0:
			e.apply_stun(stun * (BOSS_STUN_FACTOR if e.boss else 1.0))
		damage_enemy(e, t.eff_damage(), false, t)
		hit = true
	if hit:
		t.cooldown = 1.0 / t.eff_rate()
		t.fire_flash = 0.35
		_emit({"type": "gravity", "pos": t.pos, "radius": r, "tier": t.tier, "spec": t.spec})
	else:
		t.cooldown = RETARGET_DELAY


func _fire_projectile(t, target, s: Dictionary) -> void:
	var p = Projectile.new()
	p.kind = t.type
	p.pos = t.pos + Vector2.from_angle(t.aim) * 16.0
	p.start = p.pos
	p.target = target
	p.target_pos = target.pos
	p.speed = float(s.proj_speed)
	p.damage = t.eff_damage()
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
	_emit({"type": "fire", "tower": t.type, "pos": p.pos, "tier": t.tier, "spec": t.spec})


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


func _fire_missiles(t, s: Dictionary) -> void:
	var cands: Array = []
	for e in enemies:
		if t.can_target(e):
			cands.append(e)
	if cands.is_empty():
		t.target = null
		t.cooldown = RETARGET_DELAY
		return
	var scores := {}
	for e in cands:
		scores[e] = _score(t, e, t.pos.distance_squared_to(e.pos))
	cands.sort_custom(func(a, b): return scores[a] > scores[b])
	t.target = cands[0]
	t.cooldown = 1.0 / t.eff_rate()
	t.fire_flash = 0.15
	t.aim = (cands[0].pos - t.pos).angle()
	var n := int(s.missiles)
	var dir := Vector2.from_angle(t.aim)
	for i in n:
		var tgt = cands[i % cands.size()]
		var side := 1.0 if i % 2 == 0 else -1.0
		var p = Projectile.new()
		p.kind = "missile"
		p.pos = t.pos + dir.orthogonal() * side * 7.0
		p.start = p.pos
		p.vel = dir.orthogonal() * side * (150.0 + 15.0 * float(i)) + dir * 60.0
		p.target = tgt
		p.target_pos = tgt.pos
		p.speed = float(s.proj_speed)
		p.damage = t.eff_damage()
		p.splash = float(s.splash)
		p.air_mult = float(s.air_mult)
		p.tier = t.tier
		p.source = t
		projectiles.append(p)
	_emit({"type": "fire", "tower": "missile", "pos": t.pos, "tier": t.tier, "spec": t.spec, "count": n})


func _update_laser(t, dt: float) -> void:
	var s: Dictionary = t.stats()
	var beams := int(s.get("beams", 1))
	var keep: Array = []
	for e in t.beam_targets:
		if keep.size() < beams and t.can_target(e):
			keep.append(e)
	while keep.size() < beams:
		var nt = pick_target(t, keep)
		if nt == null:
			break
		keep.append(nt)
	t.beam_targets = keep
	if keep.is_empty():
		t.target = null
		t.ramp = 0.0
		t.ramp_mult = 1.0
		return
	if keep[0] != t.target:
		t.target = keep[0]
		t.ramp = 0.0
		_emit({"type": "laser_lock", "pos": t.pos})
	t.ramp += dt
	var ramp_max := float(s.ramp)
	var frac := clampf(t.ramp / float(s.ramp_time), 0.0, 1.0)
	t.ramp_mult = 1.0 + (ramp_max - 1.0) * frac
	t.aim = (keep[0].pos - t.pos).angle()
	t.fire_flash = 0.05
	var dps: float = t.eff_damage() * t.ramp_mult
	var second := float(s.get("secondary_beam", LASER_SECONDARY))
	for i in keep.size():
		damage_enemy(keep[i], dps * dt * (1.0 if i == 0 else second), true, t, false)
	var wobble := deg_to_rad(float(s.get("sweep_wobble", 0.0))) * 0.5
	if wobble > 0.0:
		for e in _enemies_near(t.pos, t.get_range(), t.hits_air(), t.hits_ground()):
			if not keep.has(e) and absf(angle_difference(t.aim, (e.pos - t.pos).angle())) <= wobble:
				damage_enemy(e, dps * dt * 0.5, true, t, false)


func _update_projectile(p, dt: float) -> void:
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
		"cannon":
			var r: float = p.splash
			var burrowed := bool(s.get("hits_burrowed", false))
			var armor_break := float(s.get("armor_break", 0.0))
			var unearth := float(s.get("unearth", 0.0))
			for e in enemies:
				if e.alive and not e.flying and e.pos.distance_squared_to(p.pos) <= r * r:
					if e.burrowed and not burrowed:
						continue
					if unearth > 0.0 and e.burrowed:
						e.burrowed = false
						e.burrow_timer = float(e.def.burrow_interval) - float(e.def.burrow_time)
						e.no_dig = maxf(e.no_dig, unearth)
						_emit({"type": "burrow", "pos": e.pos, "down": false})
					if armor_break > 0.0:
						e.apply_armor_break(armor_break, float(s.get("armor_break_time", 4.0)))
					if p.stun > 0.0:
						e.apply_stun(p.stun * (BOSS_STUN_FACTOR if e.boss else 1.0))
					var dealt := damage_enemy(e, p.damage, false, p.source, true, false, burrowed)
					_emit({"type": "hit", "pos": e.pos, "amount": dealt, "kind": "cannon"})
			if p.burn_dps > 0.0:
				pools.append({"pos": p.pos, "r": r * 0.8, "dps": p.burn_dps, "t": p.burn_time, "source": p.source})
			_emit({"type": "splash", "pos": p.pos, "radius": r, "burn": p.burn_dps > 0.0, "stun": p.stun > 0.0})
		"flak":
			# Airburst: every flyer in the blast; with timed fuses (Dual Purpose) ground units too.
			var r: float = p.splash
			var ground := float(s.get("ground_mult", 0.0))
			var shred := float(s.get("shred", 0.0))
			for e in enemies:
				if not e.alive or e.pos.distance_squared_to(p.pos) > r * r or (not e.flying and ground <= 0.0):
					continue
				if p.stun > 0.0 and e.flying:
					e.apply_stun(p.stun)
				if shred > 0.0:
					e.shred(shred, float(s.get("shred_max", shred * 6.0)))
				var dealt := damage_enemy(e, p.damage * (1.0 if e.flying else ground), false, p.source)
				_emit({"type": "hit", "pos": e.pos, "amount": dealt, "kind": "flak"})
			_emit({"type": "flak_hit", "pos": p.pos, "radius": r})
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
				_emit({"type": "arrow_hit", "pos": p.pos, "shred": p.shred > 0.0})



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
	for a in towers:
		if not a.is_support() or a.is_sensor() or a.is_economy():
			continue
		var s: Dictionary = a.stats()
		var r: float = a.get_range()
		for t in towers:
			if t.is_support() or a.pos.distance_squared_to(t.pos) > r * r:
				continue
			t.buff_dmg = maxf(t.buff_dmg, float(s.get("buff_dmg", 0.0)))
			t.buff_rate = maxf(t.buff_rate, float(s.get("buff_rate", 0.0)))
			t.buff_range = maxf(t.buff_range, float(s.get("buff_range", 0.0)))
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
	e.alive = false
	e.hp = 0.0
	# Kill credits scale with the round's HP, and bounty research pays fractional credits; the remainder carries over to the next kill.
	bounty_carry += float(e.bounty) * Waves.bounty_scale(e.wave_id) * (1.0 + float(run_mods.bounty)) * _salvage_mult(e)
	var gain := int(floor(bounty_carry + 1e-6))
	bounty_carry = maxf(0.0, bounty_carry - float(gain))
	_add_gold(gain)
	stats["kills"] += 1
	if source != null:
		source.kills += 1
	_emit({"type": "kill", "pos": e.pos, "enemy": e.type, "bounty": gain, "boss": e.boss})
	# Chain Reactor: a Nova kill sets off a small shockwave (limited depth so chains stay finite).
	if source is Tower and source.type == "nova" and _nova_depth < 2:
		var mn := float(source.stats().get("mini_nova", 0.0))
		if mn > 0.0:
			_nova_depth += 1
			for o in _enemies_near(e.pos, mn, true, true, true):
				if o != e:
					damage_enemy(o, source.eff_damage() * 0.5, false, source, false)
			_nova_depth -= 1
			_emit({"type": "mini_nova", "pos": e.pos, "radius": mn})
	if e.def.has("split_type"):
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
	warp_timer = 0.0
	for t in towers:
		t.cooldown = 0.0
		t.target = null
		t.fire_flash = 0.0
		t.ramp = 0.0
		t.ramp_mult = 1.0
		t.beam_targets.clear()
		t.disabled = 0.0
	if not endless and wave >= final_round():
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


func _wave_rng(n: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed_value * 1000 + n
	return r


# --- Persistence ---------------------------------------------------------------------------

func to_save() -> Dictionary:
	var tl: Array = []
	for t in towers:
		tl.append({
			"type": t.type, "col": t.cell.x, "row": t.cell.y, "trunk": t.trunk, "depth": t.depth.duplicate(),
			"started": t.started.duplicate(), "mastery": t.mastered, "mode": t.mode, "priority": t.priority, "kills": t.kills, "spent": t.spent,
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
	var trunk := int(entry.get("trunk", 1))
	if trunk < 1 or trunk > 2:
		return "invalid trunk tier %d." % trunk
	t.trunk = trunk
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
	if t.started.size() > 2 or deep > 1 or (trunk < 2 and not t.started.is_empty()):
		return "upgrades break the branch rules."
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
		if not Towers.TOWERS.has(type):
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
