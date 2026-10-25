extends RefCounted
## One enemy: advances a distance along a Curve2D, takes damage through flat armor (and an energy
## barrier, if it has one), can be slowed, stunned, marked, and may be cloaked or burrowed.
## Timed abilities that need the rest of the game (healing, spawning, EMP, barriers, blinking,
## burrowing, auras, boss phases) run in Game._update_enemy; this class only keeps their state.

const Enemies = preload("res://data/enemies.gd")
const EnemyTraits = preload("res://scripts/core/EnemyTraits.gd")
const Modifiers = preload("res://data/modifiers.gd")
const EnemyMoves = preload("res://scripts/entities/EnemyMoves.gd")

static var MIN_DAMAGE_FRACTION := 0.2
static var SLOW_CAP := 0.7
## After a stun wears off, the enemy can't be stunned again for this long, so chained stuns can't
## pin it in place forever.
static var STUN_GUARD := 1.0
## Total distance Graviton shoves can push one enemy back over its life; after that it can't be
## shoved. Together with STUN_GUARD this guarantees every enemy keeps making progress.
static var SHOVE_BUDGET := 320.0

var id := 0
var type := ""
var def: Dictionary
var max_hp := 1.0
var hp := 1.0
var speed := 0.0
var armor := 0.0
var flying := false
var boss := false
## Its strength rank score (Enemies.rank_of): what Strongest targeting compares first.
var rank := 0.0
## An elite carries modifiers (data/modifiers.gd), merged into its `def`; it pays double bounty and costs a shield more.
var elite := false
var mods: Array = []
## Its modifiers' names in capitals, for the label over an elite ("HASTY PLATED").
var elite_label := ""
## The round's speed multiplier it spawned with (a speed change from its data is scaled by it).
var spd_mult := 1.0
## Fury Drone: its adrenaline speed multiplier (1 until it drops below half health). Titan: whether its plates have shed.
var rush := 1.0
var shed := false
## A Shifter's wake on this enemy: extra speed (multiplies with every other boost) and seconds left.
var wake := 0.0
var wake_timer := 0.0
## Capacitor: seconds left in its telegraphed charge (0 when not charging).
var charge_timer := 0.0
## Masquerade: disguised as its `disguise` enemy (look, speed, rank and role) until below half health; then it flees.
var disguised := false
var flee_timer := 0.0
## Mirage hologram: a 1-HP copy that never leaks or pays, and vanishes with the Mirage that projected it.
var hologram := false
var holo_owner = null
## Radar Illusion Filter: a ping marked this hologram as a fake, so towers stop choosing it as a target.
var fake_marked := false
## Radar Signal Analysis: a ping saw through this Decoy Beacon, so it ranks (and shows its role) as what it really is.
var decoy_exposed := false
## Radar Total Exposure: seconds left in which it can't re-cloak or re-burrow (kept full while inside that radar).
var track_timer := 0.0
## The kind ("physical" or "energy") of the last hit it took.
var last_hit_kind := ""
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
## Its traits (EnemyTraits), and a countdown per timed trait to its next firing.
var traits: Array = []
var trait_timers := {}
## Seconds it has been on the field, and the `age` at which things last happened to it (see `mark`).
var age := 0.0
var fired := {}
## Its movement pattern (EnemyMoves): seconds it has moved (not stunned), its point on the track, and how far it
## stands to the right of it (px).
var move_time := 0.0
var track_pos := Vector2.INF
var side := 0.0
## How fast the sideways offset can change (px per second).
const SIDE_SLEW := 90.0
## The old shared ability timer: setting it sets every timed ability's timer (heal, summon, EMP, barrier grant).
var ability_timer: float:
	get:
		for n in EnemyTraits.ABILITIES:
			if trait_timers.has(n):
				return float(trait_timers[n])
		return 0.0
	set(v):
		for n in EnemyTraits.ABILITIES:
			if trait_timers.has(n):
				trait_timers[n] = v
var alive := true
var wave_id := 0
var hit_flash := 0.0
var armor_shred := 0.0
## Chemical Plant soak: time left, acid damage per second, gel slow, and the plant that soaked it. Cryo Tower permanent chill.
var soak_timer := 0.0
var soak_dps := 0.0
var soak_slow := 0.0
var soak_source = null
var perm_slow := 0.0
## Tractor Tower: a distance sample every quarter second (the last six seconds), so it can rewind an enemy to where it was.
var dist_log: Array = []
var _log_clock := 0.0
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
var burrow_timer: float:
	get:
		return float(trait_timers.get("burrow", 0.0))
	set(v):
		trait_timers["burrow"] = v
## Blink Stalker: counts down to the next teleport; a slow or stun resets it.
var blink_timer: float:
	get:
		return float(trait_timers.get("blink", 0.0))
	set(v):
		trait_timers["blink"] = v
## Where it stood when it last blinked (its after-image stays there), or INF if it never has.
var blink_from := Vector2.INF
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


func setup(enemy_type: String, route: Curve2D, hp_mult: float, wave: int, path_idx: int, start_distance := 0.0, speed_mult := 1.0, modifiers: Array = []) -> void:
	type = enemy_type
	def = Enemies.ENEMIES[enemy_type]
	mods = modifiers.duplicate()
	elite = not mods.is_empty()
	if elite:
		def = Modifiers.apply(def, enemy_type, mods)
		elite_label = Modifiers.label(mods).to_upper()
	max_hp = float(def.hp) * hp_mult
	hp = max_hp
	speed = float(def.speed) * speed_mult
	spd_mult = speed_mult
	armor = float(def.get("armor", 0.0))
	flying = bool(def.get("flying", false))
	boss = bool(def.get("boss", false))
	rank = Enemies.rank_of(def)
	radius = float(def.radius)
	bounty = int(def.bounty) * (2 if elite else 1)
	lives_cost = int(def.lives) + (1 if elite else 0)
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
	set_traits(EnemyTraits.of_def(def) if elite else EnemyTraits.of(enemy_type))
	if def.has("disguise"):
		var look: Dictionary = Enemies.ENEMIES[def.disguise]
		disguised = true
		speed = float(look.speed) * speed_mult
		rank = Enemies.rank_of(look)
	if def.has("fake_rank"):
		# Decoy Beacon: ranks above every non-boss and below every boss, for good.
		rank = Enemies.BOSS_RANK - 1.0


## Live tuner (issue #80): its type's data was edited; `was` is its `def` from before. Health and barrier keep their
## share and scale by the change, speed scales by it, armor moves by it, and bounty, leak cost, radius, slow resistance
## and rank follow the new data. Ability numbers are read from `def` as they're used.
func retune(was: Dictionary) -> void:
	def = Modifiers.apply(Enemies.ENEMIES[type], type, mods) if elite else Enemies.ENEMIES[type]
	if hologram:
		return
	if float(def.hp) != float(was.hp):
		var mult := max_hp / maxf(0.001, float(was.hp))
		var share := hp / maxf(0.001, max_hp)
		max_hp = float(def.hp) * mult
		hp = max_hp * share
		max_shield *= float(def.hp) / maxf(0.001, float(was.hp))
		shield = minf(shield, max_shield)
	if float(def.get("shield", 0.0)) != float(was.get("shield", 0.0)):
		var share := shield / max_shield if max_shield > 0.0 else 1.0
		max_shield = float(def.get("shield", 0.0)) * max_hp / maxf(0.001, float(def.hp))
		shield = max_shield * share
	if not disguised and float(def.speed) != float(was.speed) and float(was.speed) > 0.0:
		speed *= float(def.speed) / float(was.speed)
	armor = maxf(0.0, armor + float(def.get("armor", 0.0)) - float(was.get("armor", 0.0)))
	radius = float(def.radius)
	bounty = int(def.bounty) * (2 if elite else 1)
	lives_cost = int(def.lives) + (1 if elite else 0)
	slow_resist = float(def.get("slow_resist", 0.0))
	if not disguised and (not def.has("fake_rank") or decoy_exposed):
		rank = Enemies.rank_of(def)


## What it shows itself as: the Masquerade's disguise while disguised, otherwise itself.
func look_type() -> String:
	return str(def.disguise) if disguised else type


## Notes that something just happened to it (an ability fired, it burrowed, shed...), for its art and movement.
func mark(what: String) -> void:
	fired[what] = age


## Seconds since `mark(what)`, or a large number if it never happened.
func since(what: String) -> float:
	return age - float(fired.get(what, -1e6))


## The Masquerade drops its disguise: its true rank and role, and a burst of speed before it settles at its own.
func reveal_disguise() -> void:
	disguised = false
	mark("uncover")
	rank = Enemies.rank_of(def)
	speed = float(def.flee_speed) * spd_mult
	flee_timer = float(def.flee_time)


## Radar Signal Analysis: the Decoy Beacon is seen for what it is (its true rank and role), for good.
func expose_decoy() -> void:
	decoy_exposed = true
	mark("analysed")
	rank = Enemies.rank_of(def)


## Turns it into a Mirage's hologram: 1 HP, no armor, barrier or abilities, no bounty or leak cost, and its Mirage's rank.
func make_hologram(owner) -> void:
	hologram = true
	holo_owner = owner
	max_hp = 1.0
	hp = 1.0
	armor = 0.0
	max_shield = 0.0
	shield = 0.0
	bounty = 0
	lives_cost = 0
	rank = owner.rank
	set_traits([])


## Gives it the traits `list` (read from `def`), each timed one starting a full interval from now.
func set_traits(list: Array) -> void:
	traits = list
	trait_timers = {}
	for n in traits:
		if EnemyTraits.timed(n):
			trait_timers[n] = EnemyTraits.interval(def, n)


## Its tier in its role (1 to 4; 0 for special and boss).
func tier() -> int:
	return int(def.get("tier", 0))


func has_trait(name: String) -> bool:
	return traits.has(name)


## Counts timed trait `name` down by `dt`; when it runs out, restarts it and returns true (fire now).
func tick_trait(name: String, dt: float) -> bool:
	var left: float = float(trait_timers.get(name, 0.0)) - dt
	if left <= 0.0:
		trait_timers[name] = EnemyTraits.interval(def, name)
		return true
	trait_timers[name] = left
	return false


static func mitigate(amount: float, armor_value: float, pierce: bool) -> float:
	if pierce:
		return amount
	return maxf(amount - armor_value, amount * MIN_DAMAGE_FRACTION)


## Its role (swarm, rusher, evader, support, disruptor, special, tank or boss), from its data.
func role() -> String:
	return str(def.get("role", "rusher"))


## The role it shows (what the Support priority and labels read): a Masquerade's disguise, a Decoy Beacon's heavy hull.
func shown_role() -> String:
	if disguised:
		return str(Enemies.ENEMIES[def.disguise].role)
	return role() if decoy_exposed else str(def.get("shown_role", role()))


## The data it shows (name, blurb, role and tier): its disguise's while disguised.
func shown_def() -> Dictionary:
	return Enemies.ENEMIES[def.disguise] if disguised else def


## The share of a slow or pull it resists, by role.
func role_resist() -> float:
	return float(Enemies.ROLE_RESIST.get(role(), 0.0))


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


## Puts the enemy at `d` px along its route (clamped), moving it there at once.
func set_distance(d: float) -> void:
	distance = clampf(d, 0.0, path_len)
	pos = curve.sample_baked(minf(distance, path_len))


## A blink: it leaves an after-image where it stands and lands `dist` px further along its route, on the track and
## facing along it (not along the jump, which cuts across a corner).
func blink(dist: float) -> void:
	blink_from = pos
	set_distance(distance + dist)
	track_pos = pos
	var ahead := curve.sample_baked(minf(distance + 4.0, path_len))
	if ahead.distance_squared_to(pos) > 0.0001:
		facing = (ahead - pos).normalized()


## Where the enemy was `seconds` ago along its route (its distance then), or 0 if it hasn't been alive that long.
func distance_ago(seconds: float) -> float:
	var back := int(round(seconds / 0.25))
	if back > dist_log.size():
		return 0.0
	return float(dist_log[dist_log.size() - back]) if back >= 1 else distance


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


## Moves along the track (ground enemies, and flyers that follow it, like the Phantom) rather than a straight flight line.
func on_track() -> bool:
	return not flying or bool(def.get("track", false))


## Towers can't pick it as a target: burrowed, or cloaked and not revealed (a Radar Tower ping or its Total Exposure).
func is_hidden() -> bool:
	return burrowed or (cloaked and reveal_timer <= 0.0 and disrupt_timer <= 0.0 and track_timer <= 0.0)


## Towers won't choose it as a target: hidden, or a hologram a Radar's Illusion Filter marked as a fake. Blasts and beams
## still hit whatever is in their way.
func untargetable() -> bool:
	return is_hidden() or fake_marked


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
	if has_trait("blink"):
		blink_timer = float(def.blink_interval)


func step(dt: float) -> void:
	age += dt
	hit_flash = maxf(0.0, hit_flash - dt)
	reveal_timer = maxf(0.0, reveal_timer - dt)
	since_hit += dt
	_log_clock += dt
	if _log_clock >= 0.25:
		_log_clock = 0.0
		dist_log.append(distance)
		if dist_log.size() > 24:
			dist_log.pop_front()
	if soak_timer > 0.0:
		soak_timer = maxf(0.0, soak_timer - dt)
		if soak_timer <= 0.0:
			soak_dps = 0.0
			soak_slow = 0.0
			soak_source = null
	for f in ["suppress_timer", "jam_timer", "repair_block", "barrier_block", "grant_block", "expose_timer", "no_dig", "disrupt_timer", "armor_break_timer", "track_timer"]:
		if float(get(f)) > 0.0:
			set(f, maxf(0.0, float(get(f)) - dt))
	if dot_timer > 0.0:
		dot_timer = maxf(0.0, dot_timer - dt)
		if dot_timer <= 0.0:
			dot_dps = 0.0
	if has_trait("regen") and since_hit >= float(def.regen_delay) and hp < max_hp and repair_block <= 0.0 and not silenced():
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
	if wake_timer > 0.0:
		wake_timer = maxf(0.0, wake_timer - dt)
		if wake_timer <= 0.0:
			wake = 0.0
	if flee_timer > 0.0:
		flee_timer = maxf(0.0, flee_timer - dt)
		if flee_timer <= 0.0:
			speed = float(def.speed) * spd_mult
	stun_guard = maxf(0.0, stun_guard - dt)
	if stun_timer > 0.0:
		stun_timer = maxf(0.0, stun_timer - dt)
		if stun_timer <= 0.0:
			stun_guard = STUN_GUARD
		return
	# Its movement pattern (EnemyMoves): a pace along the track and a sideways offset from it, eased toward so a
	# side-step slides rather than jumps. It faces along the track.
	move_time += dt
	var mt := move_time + float(id) * 0.37
	distance += speed * (1.0 - slow_amount) * (1.0 + haste) * rush * (1.0 + wake) * EnemyMoves.pace(self, mt) * dt
	var np := curve.sample_baked(clampf(distance + EnemyMoves.ahead(self), 0.0, path_len))
	if track_pos == Vector2.INF:
		track_pos = np
	var d := np - track_pos
	if d.length_squared() > 0.0001:
		facing = d.normalized()
	track_pos = np
	side = move_toward(side, EnemyMoves.side(self, mt), SIDE_SLEW * dt)
	pos = np + Vector2(-facing.y, facing.x) * side


func reached_end() -> bool:
	return distance >= path_len
