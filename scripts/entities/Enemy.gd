extends RefCounted
## One enemy: advances a distance along a Curve2D, takes damage through flat armor (and an energy
## barrier, if it has one), can be slowed, stunned, marked, and may be cloaked or burrowed.
## Timed abilities that need the rest of the game (healing, spawning, EMP, barriers, blinking,
## burrowing, auras, boss phases) run in Game._update_enemy; this class only keeps their state.

const Enemies = preload("res://data/enemies.gd")

const MIN_DAMAGE_FRACTION := 0.2
const SLOW_CAP := 0.7
## After a stun wears off, the enemy can't be stunned again for this long, so chained stuns can't
## pin it in place forever.
const STUN_GUARD := 1.0
## Total distance Graviton shoves can push one enemy back over its life; after that it can't be
## shoved. Together with STUN_GUARD this guarantees every enemy keeps making progress.
const SHOVE_BUDGET := 320.0

var id := 0
var type := ""
var def: Dictionary
var max_hp := 1.0
var hp := 1.0
var speed := 0.0
var armor := 0.0
var flying := false
var boss := false
var radius := 10.0
var bounty := 0
var lives_cost := 1
var slow_resist := 0.0
var curve: Curve2D
var path_len := 1.0
var path_index := 0
var distance := 0.0
var pos := Vector2.ZERO
var facing := Vector2.RIGHT
var slow_amount := 0.0
var slow_timer := 0.0
var ability_timer := 0.0
var alive := true
var wave_id := 0
var hit_flash := 0.0
var armor_shred := 0.0
var vuln_amount := 0.0
var vuln_timer := 0.0
var stun_timer := 0.0
var stun_guard := 0.0
var shoved := 0.0
var max_shield := 0.0
var shield := 0.0
var shield_timer := 0.0
var cloaked := false
var reveal_timer := 0.0
## Burrower: under the lane (untargetable, can't be hurt) while `burrowed`; `burrow_timer` counts
## down to the next change.
var burrowed := false
var burrow_timer := 0.0
## Blink Stalker: counts down to the next teleport; a slow or stun resets it.
var blink_timer := 0.0
## Mender Hulk: seconds since it last took damage.
var since_hit := 0.0
## Rally Beacon overdrive on this enemy (fraction of extra speed), refreshed every tick.
var haste := 0.0
## Colossus: how many of its phase thresholds it has passed.
var phase := 0
## v3.1 status effects from towers (all in seconds unless noted):
## suppress: every ability is off (heal, spawn, EMP, barrier grants, aura, blink, burrow, regeneration).
## jam: support abilities off (level 1) or everything (level 2) while inside a Suppression Pylon.
## repair_block: can't regenerate or be healed. barrier_block: barrier doesn't recharge.
## grant_block: can't receive Bulwark barriers. expose: loses crowd-control immunity.
## no_dig: can't burrow. disrupt: can't burrow or blink, and its cloak fails.
var suppress_timer := 0.0
var jam_timer := 0.0
var jam_level := 0
var repair_block := 0.0
var barrier_block := 0.0
var grant_block := 0.0
var expose_timer := 0.0
var no_dig := 0.0
var disrupt_timer := 0.0
## Temporary armor reduction (Bunker Buster, Nullifier) and its timer.
var armor_break := 0.0
var armor_break_timer := 0.0
## Damage over time (burning), in damage per second.
var dot_dps := 0.0
var dot_timer := 0.0
## Seconds spent inside an Ion Storm (for Static Build-up).
var storm_time := 0.0
var in_storm := false
var storm_until := -99.0


func setup(enemy_type: String, route: Curve2D, hp_mult: float, wave: int, path_idx: int, start_distance := 0.0, speed_mult := 1.0) -> void:
	type = enemy_type
	def = Enemies.ENEMIES[enemy_type]
	max_hp = float(def.hp) * hp_mult
	hp = max_hp
	speed = float(def.speed) * speed_mult
	armor = float(def.get("armor", 0.0))
	flying = bool(def.get("flying", false))
	boss = bool(def.get("boss", false))
	radius = float(def.radius)
	bounty = int(def.bounty)
	lives_cost = int(def.lives)
	slow_resist = float(def.get("slow_resist", 0.0))
	max_shield = float(def.get("shield", 0.0)) * hp_mult
	shield = max_shield
	cloaked = bool(def.get("cloaked", false))
	curve = route
	path_len = maxf(1.0, curve.get_baked_length())
	path_index = path_idx
	distance = start_distance
	pos = curve.sample_baked(minf(distance, path_len))
	var ahead := curve.sample_baked(minf(distance + 4.0, path_len))
	if ahead.distance_squared_to(pos) > 0.0001:
		facing = (ahead - pos).normalized()
	wave_id = wave
	ability_timer = float(def.get("heal_interval", def.get("spawn_interval", def.get("emp_interval", def.get("grant_interval", 0.0)))))
	burrow_timer = float(def.get("burrow_interval", 0.0))
	blink_timer = float(def.get("blink_interval", 0.0))


static func mitigate(amount: float, armor_value: float, pierce: bool) -> float:
	if pierce:
		return amount
	return maxf(amount - armor_value, amount * MIN_DAMAGE_FRACTION)


func progress() -> float:
	return distance / path_len


func apply_slow(amount: float, duration: float) -> void:
	if bool(def.get("cc_immune", false)) and not exposed():
		return
	_reset_blink()
	var a := minf(amount * (1.0 - slow_resist), SLOW_CAP)
	if a >= slow_amount:
		slow_amount = a
		slow_timer = maxf(slow_timer, duration)


func effective_armor() -> float:
	return maxf(0.0, armor - armor_shred - (armor_break if armor_break_timer > 0.0 else 0.0))


func exposed() -> bool:
	return expose_timer > 0.0


## Its own abilities are shut off (suppressed, or jammed at `level` or above).
func silenced(level := 1) -> bool:
	return suppress_timer > 0.0 or (jam_timer > 0.0 and jam_level >= level)


func apply_armor_break(amount: float, duration: float) -> void:
	if amount >= armor_break or armor_break_timer <= 0.0:
		armor_break = amount
	armor_break_timer = maxf(armor_break_timer, duration)


func apply_burn(dps: float, duration: float) -> void:
	if dps >= dot_dps or dot_timer <= 0.0:
		dot_dps = dps
	dot_timer = maxf(dot_timer, duration)


func shred(amount: float, cap: float) -> void:
	armor_shred = minf(cap, armor_shred + amount)


## Take `amount` extra damage (0.25 = +25%) for `duration`. The strongest active vulnerability applies.
func apply_vuln(amount: float, duration: float) -> void:
	if amount >= vuln_amount or vuln_timer <= 0.0:
		vuln_amount = amount
		vuln_timer = maxf(vuln_timer, duration)


## Towers can't pick it as a target: burrowed, or cloaked and not revealed by a Sensor Array.
func is_hidden() -> bool:
	return burrowed or (cloaked and reveal_timer <= 0.0 and disrupt_timer <= 0.0)


## Can't be stunned (Rampart, Colossus).
func stun_immune() -> bool:
	return (bool(def.get("cc_immune", false)) or bool(def.get("stun_immune", false))) and not exposed()


## Can't be shoved by a Graviton Projector: Rampart, burrowed, or its shove budget is used up.
func shove_immune() -> bool:
	return burrowed or (bool(def.get("cc_immune", false)) and not exposed()) or shoved >= SHOVE_BUDGET


## Shoves it back along its route by up to `push` px (limited by the shove budget).
func shove(push: float) -> void:
	if shove_immune():
		return
	var p := minf(push, SHOVE_BUDGET - shoved)
	shoved += p
	distance = maxf(0.0, distance - p)
	pos = curve.sample_baked(minf(distance, path_len))


func apply_stun(duration: float) -> void:
	if stun_immune() or stun_guard > 0.0:
		return
	_reset_blink()
	stun_timer = maxf(stun_timer, duration)


func _reset_blink() -> void:
	if def.has("blink_interval"):
		blink_timer = float(def.blink_interval)


func step(dt: float) -> void:
	hit_flash = maxf(0.0, hit_flash - dt)
	reveal_timer = maxf(0.0, reveal_timer - dt)
	since_hit += dt
	for f in ["suppress_timer", "jam_timer", "repair_block", "barrier_block", "grant_block", "expose_timer", "no_dig", "disrupt_timer", "armor_break_timer"]:
		if float(get(f)) > 0.0:
			set(f, maxf(0.0, float(get(f)) - dt))
	if dot_timer > 0.0:
		dot_timer = maxf(0.0, dot_timer - dt)
		if dot_timer <= 0.0:
			dot_dps = 0.0
	if def.has("regen_pct") and since_hit >= float(def.regen_delay) and hp < max_hp and repair_block <= 0.0 and not silenced():
		hp = minf(max_hp, hp + max_hp * float(def.regen_pct) * dt)
	if max_shield > 0.0 and shield < max_shield and def.has("shield_regen") and barrier_block <= 0.0:
		shield_timer -= dt
		if shield_timer <= 0.0:
			shield = minf(max_shield, shield + max_shield * float(def.shield_regen) * dt)
	if slow_timer > 0.0:
		slow_timer -= dt
		if slow_timer <= 0.0:
			slow_timer = 0.0
			slow_amount = 0.0
	if vuln_timer > 0.0:
		vuln_timer -= dt
		if vuln_timer <= 0.0:
			vuln_timer = 0.0
			vuln_amount = 0.0
	stun_guard = maxf(0.0, stun_guard - dt)
	if stun_timer > 0.0:
		stun_timer = maxf(0.0, stun_timer - dt)
		if stun_timer <= 0.0:
			stun_guard = STUN_GUARD
		return
	distance += speed * (1.0 - slow_amount) * (1.0 + haste) * dt
	var np := curve.sample_baked(minf(distance, path_len))
	var d := np - pos
	if d.length_squared() > 0.0001:
		facing = d.normalized()
	pos = np


func reached_end() -> bool:
	return distance >= path_len
