extends RefCounted
## Round compositions (enemy rework, issue #68; design/enemies.md section 4). One generator makes every round, from round 1
## on through Endless, and it is seeded by the round number alone, so a round is the same on every playthrough and every
## mode. Each round is a list of groups:
##   t = enemy type, n = count, i = seconds between spawns, d = delay from round start, m = an elite's modifiers (then n is 1).
## A round spends a threat budget that grows with the round number: new enemies lead their introduction round, the rest
## goes on groups of enemies already met, and from round 8 a share goes on elites (single enemies with modifiers,
## data/modifiers.gd). Every 20th round adds a boss line-up; a boss met once can recur in later rounds.

const Enemies = preload("res://data/enemies.gd")
const Modifiers = preload("res://data/modifiers.gd")

const MAX_SPAWNS := 250
const MAX_ELITES := 12

## Round each regular enemy is introduced (its own group leads that round): one every two rounds, by tier (every role's T1,
## then the Specials and higher tiers).
const INTRO := {
	"grunt": 1, "swarmling": 2, "runner": 3, "shaman": 5, "brute": 7, "jammer": 9, "stalker": 11, "phantom": 13,
	"locust": 15, "aegis": 17, "needle": 19, "rally": 21, "mirage": 23, "bat": 25, "siphon": 27, "hydra": 29,
	"burrower": 31, "bulwark": 33, "rampart": 35, "decoy": 37, "blackout": 39, "shifter": 41, "gunship": 43,
	"masquerade": 45, "shrike": 47, "fury": 49, "mender": 51, "wraith": 53, "capacitor": 55, "titan": 57,
}

## Boss rounds (owner, 2026-10-20): every 20 rounds, each bigger than the last; 100 and 120 mix the bosses met so far.
const BOSS_ROUNDS := {
	20: [["juggernaut", 1]],
	40: [["warlord", 1], ["juggernaut", 1]],
	60: [["leviathan", 1], ["warlord", 1], ["juggernaut", 1]],
	80: [["colossus", 1], ["leviathan", 1], ["juggernaut", 2]],
	100: [["colossus", 1], ["leviathan", 1], ["warlord", 1], ["juggernaut", 2]],
	120: [["colossus", 2], ["leviathan", 1], ["warlord", 2], ["juggernaut", 3]],
}

## Threat each enemy costs the generator (roughly its round-1 toughness in Drones), per enemy: a Needle pair or a Shrike cluster
## costs its pack times this. Bosses only count when one recurs in a regular round; their own rounds come from BOSS_ROUNDS.
const COST := {
	"grunt": 1.0, "runner": 0.7, "brute": 3.8, "swarmling": 0.35, "bat": 1.4, "shaman": 1.8,
	"phantom": 1.2, "aegis": 4.0, "hydra": 3.0, "jammer": 2.1, "locust": 0.25, "rally": 2.4,
	"burrower": 2.3, "gunship": 8.6, "stalker": 1.6, "mender": 5.4, "bulwark": 2.9, "rampart": 7.4,
	"needle": 0.6, "fury": 1.9, "shrike": 1.0, "titan": 12.0, "siphon": 3.0, "blackout": 4.5, "capacitor": 7.5,
	"shifter": 3.8, "wraith": 6.0, "masquerade": 5.5, "decoy": 4.0, "mirage": 2.2,
	"juggernaut": 20.0, "warlord": 45.0, "leviathan": 60.0, "colossus": 95.0,
}

## Seconds between spawns within a group (between packs, for the Needle and the Shrike).
const SPACING := {
	"grunt": 0.35, "runner": 0.3, "brute": 0.9, "swarmling": 0.14, "bat": 0.45, "shaman": 1.8,
	"phantom": 0.5, "aegis": 1.2, "hydra": 1.1, "jammer": 2.0, "locust": 0.1, "rally": 1.6,
	"burrower": 0.8, "gunship": 1.5, "stalker": 0.6, "mender": 1.4, "bulwark": 1.6, "rampart": 1.8,
	"needle": 0.6, "fury": 0.5, "shrike": 1.2, "titan": 2.2, "siphon": 2.0, "blackout": 2.4, "capacitor": 3.0,
	"shifter": 1.0, "wraith": 1.0, "masquerade": 1.2, "decoy": 2.5, "mirage": 2.0,
	"juggernaut": 6.0, "warlord": 6.0, "leviathan": 6.0, "colossus": 6.0,
}

## Support enemies stop being fun in bulk, so groups of them are capped; a boss recurs alone.
const MAX_COUNT := {"shaman": 8, "jammer": 5, "rally": 6, "bulwark": 6, "siphon": 5, "blackout": 4, "capacitor": 3, "decoy": 3, "mirage": 5,
	"juggernaut": 1, "warlord": 1, "leviathan": 1, "colossus": 1}

## A recurring boss turns up less often than a regular enemy, and only when it costs at most RECUR_BOSS_SHARE of the round's
## budget. A new enemy's own group gets DEBUT_SHARE of the budget on its round, and for NEW_ROUNDS rounds after its introduction
## an enemy is picked NEW_WEIGHT times as often.
const BOSS_WEIGHT := 0.4
const RECUR_BOSS_SHARE := 0.5
const DEBUT_SHARE := 0.3
const NEW_WEIGHT := 2.5
const NEW_ROUNDS := 12


## Past LATE_START, enemy HP also compounds by `late_growth` per round, so even a map full of
## maxed towers eventually breaks (the balance probe can override it with --growth=).
const LATE_START := 60
static var late_growth := 0.01


## The round formulas' numbers (design/balance.md owns them; tools/balance.mjs writes them here).
## HP multiplier: 1 + HP_LINEAR·w + HP_QUAD·w², w = round - 1, compounding late_growth a round past LATE_START.
const HP_LINEAR := 0.05
const HP_QUAD := 0.0012
## Speed: +SPEED_PER_ROUND a round, capped at SPEED_CAP; bosses get BOSS_SPEED_SHARE of it.
const SPEED_PER_ROUND := 0.0045
const SPEED_CAP := 0.5
const BOSS_SPEED_SHARE := 0.5
## Threat budget: BUDGET_BASE + BUDGET_LINEAR·w + BUDGET_QUAD·w².
const BUDGET_BASE := 8.0
const BUDGET_LINEAR := 3.6
const BUDGET_QUAD := 0.02
## Elite share of the budget: none before ELITE_FROM, then ELITE_START rising by ELITE_RISE until ELITE_FULL_AT.
const ELITE_FROM := 8
const ELITE_START := 0.10
const ELITE_RISE := 0.20
const ELITE_FULL_AT := 60


## Enemy HP multiplier for a round (the same on every mode). Lowered in the rework: late difficulty comes from the tier mix
## and the elites.
static func hp_scale(wave: int) -> float:
	var w := float(maxi(wave, 1) - 1)
	var base := 1.0 + HP_LINEAR * w + HP_QUAD * w * w
	return base * pow(1.0 + late_growth, float(maxi(0, wave - LATE_START)))


## Enemy speed multiplier for a round. Bosses get a share of it.
static func speed_scale(wave: int, boss := false) -> float:
	var bonus := minf(SPEED_CAP, SPEED_PER_ROUND * float(maxi(wave, 1) - 1))
	return 1.0 + bonus * (BOSS_SPEED_SHARE if boss else 1.0)


## Threat a round spends, in Drone-equivalents.
static func threat_budget(wave: int) -> float:
	var w := float(maxi(wave, 1) - 1)
	return BUDGET_BASE + BUDGET_LINEAR * w + BUDGET_QUAD * w * w


## The share of a round's budget that goes on elites.
static func elite_share(wave: int) -> float:
	if wave < ELITE_FROM:
		return 0.0
	return ELITE_START + ELITE_RISE * clampf(float(wave - ELITE_FROM) / float(ELITE_FULL_AT - ELITE_FROM), 0.0, 1.0)


## Kill credits grow with the round's enemy HP (raised to `bounty_exp`), so income keeps up with
## tougher rounds. The balance probe can override the exponent with --bounty=.
static var bounty_exp := 0.3


static func bounty_scale(wave: int) -> float:
	return pow(hp_scale(maxi(wave, 1)), bounty_exp)


## Credits for clearing a round: CLEAR_BASE + CLEAR_PER_ROUND × round; for calling it early, CALL_BASE + CALL_PER_ROUND × round.
const CLEAR_BASE := 20
const CLEAR_PER_ROUND := 3
const CALL_BASE := 10
const CALL_PER_ROUND := 2


static func clear_bonus(wave: int) -> int:
	return CLEAR_BASE + CLEAR_PER_ROUND * wave


static func early_call_bonus(wave: int) -> int:
	return CALL_BASE + CALL_PER_ROUND * wave


## The groups for round `wave`.
static func get_wave(wave: int) -> Array:
	return generated_round(wave)


## The round's own random numbers: seeded by the round number alone.
static func round_rng(wave: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = 7919 * maxi(wave, 1) + 104729
	return r


## Whether `etype` is in the enemy table.
static func exists(etype: String) -> bool:
	return Enemies.ENEMIES.has(etype)


## How many enemies one spawn of `etype` sends (a Needle pair, a Shrike cluster).
static func pack(etype: String) -> int:
	return int(Enemies.ENEMIES[etype].get("pack", 1))


## How many enemies a group sends (an elite comes alone, whatever its pack).
static func units(grp: Dictionary) -> int:
	return int(grp.n) * (1 if grp.has("m") else pack(str(grp.t)))


## First round enemy `etype` can appear in (999 if never): its introduction, or its first boss round.
static func first_round(etype: String) -> int:
	if INTRO.has(etype):
		return int(INTRO[etype])
	for w in BOSS_ROUNDS:
		for entry in BOSS_ROUNDS[w]:
			if entry[0] == etype:
				return mini(first_boss_round(etype), int(w))
	return 999


static func first_boss_round(etype: String) -> int:
	var best := 999
	for w in BOSS_ROUNDS:
		for entry in BOSS_ROUNDS[w]:
			if entry[0] == etype:
				best = mini(best, int(w))
	return best


## The boss line-up for a round: BOSS_ROUNDS, and past round 120 every 20th round brings the 120 line-up with one more of
## each boss for every 20 rounds beyond it.
static func boss_line(wave: int) -> Array:
	if BOSS_ROUNDS.has(wave):
		return BOSS_ROUNDS[wave]
	if wave > 120 and wave % 20 == 0:
		var extra := (wave - 120) / 20
		var line: Array = []
		for entry in BOSS_ROUNDS[120]:
			line.append([entry[0], int(entry[1]) + extra])
		return line
	return []


static func boss_groups(wave: int) -> Array:
	var out: Array = []
	var line := boss_line(wave)
	for k in line.size():
		var entry: Array = line[k]
		out.append({"t": entry[0], "n": int(entry[1]), "i": 6.0, "d": 4.0 + 7.0 * k})
	return out


## Balance probe switch (--mods): null plays the game's modifiers; a list allows only those (empty: no elites at all).
static var mods_only = null


## The modifiers that can appear on round `wave`.
static func open_modifiers(wave: int) -> Array:
	return Modifiers.ORDER.filter(func(m): return int(Modifiers.MODIFIERS[m].intro) <= wave and (mods_only == null or (mods_only as Array).has(m)))


static func generated_round(wave: int) -> Array:
	var rng := round_rng(wave)
	var groups: Array = []
	var budget := threat_budget(wave)
	var elite_budget := budget * elite_share(wave) if not open_modifiers(wave).is_empty() else 0.0
	budget -= elite_budget
	var pool: Array = []
	for t in INTRO:
		if exists(t) and int(INTRO[t]) < wave:
			pool.append(t)
	var bosses: Array = []
	for t in COST:
		if bool(Enemies.ENEMIES[t].get("boss", false)) and first_boss_round(t) < wave and float(COST[t]) <= budget * RECUR_BOSS_SHARE:
			bosses.append(t)
	var delay := 0.0
	for t in INTRO:
		if exists(t) and int(INTRO[t]) == wave:
			var share := DEBUT_SHARE if not pool.is_empty() else 1.0
			groups.append(_group(t, budget * share, 0.0))
			budget *= 1.0 - share
			delay = 3.0
	var choices: Array = pool + bosses
	var n_groups := 1 if wave <= 2 else (2 if wave < 10 else (3 if wave < 30 else mini(6, 4 + (wave - 30) / 20)))
	var picks: Array = []
	for g in n_groups:
		if budget <= 0.0:
			break
		var total := 0.0
		var weights: Array = []
		for t in choices:
			var wt := 0.0
			if not picks.has(t):
				# Newer enemies turn up more often while they're fresh; a recurring boss less often.
				wt = BOSS_WEIGHT if bosses.has(t) else (NEW_WEIGHT if int(INTRO[t]) >= wave - NEW_ROUNDS else 1.0)
			weights.append(wt)
			total += wt
		if total <= 0.0:
			break
		var roll := rng.randf() * total
		for k in choices.size():
			roll -= float(weights[k])
			if roll <= 0.0 and float(weights[k]) > 0.0:
				picks.append(choices[k])
				break
	var shares: Array = []
	var share_sum := 0.0
	for p in picks:
		var s := rng.randf_range(0.7, 1.3)
		shares.append(s)
		share_sum += s
	for k in picks.size():
		groups.append(_group(picks[k], budget * float(shares[k]) / share_sum, delay))
		delay += rng.randf_range(2.0, 5.0)
	groups.append_array(_elites(wave, rng, elite_budget, pool, maxf(delay, 6.0)))
	# Cap the spawn count for performance; beyond it, rounds get tougher through HP, speed and elites.
	var count := 0
	for grp in groups:
		count += units(grp)
	if count > MAX_SPAWNS:
		var f := float(MAX_SPAWNS) / float(count)
		count = 0
		for grp in groups:
			grp["n"] = maxi(1, int(float(grp.n) * f))
			count += units(grp)
		# Single enemies (elites) can't shrink, so trim the biggest group for what they add.
		while count > MAX_SPAWNS:
			var big: Dictionary = groups[0]
			for grp in groups:
				if units(grp) > units(big):
					big = grp
			big["n"] = int(big.n) - 1
			count -= pack(str(big.t)) if not big.has("m") else 1
	groups.append_array(boss_groups(wave))
	return groups


## Spends `budget` on single elites from `pool`, each with one or more modifiers open on this round. A modifier on its
## introduction round goes on the first elite, so it always shows up when the schedule says.
static func _elites(wave: int, rng: RandomNumberGenerator, budget: float, pool: Array, span: float) -> Array:
	var out: Array = []
	var open := open_modifiers(wave)
	if budget <= 0.0 or pool.is_empty() or open.is_empty():
		return out
	var debut: Array = open.filter(func(m): return int(Modifiers.MODIFIERS[m].intro) == wave)
	var tries := 0
	while budget > 0.0 and out.size() < MAX_ELITES and tries < 40:
		tries += 1
		var t: String = pool[rng.randi() % pool.size()]
		var want := 1 + rng.randi() % Modifiers.max_per_elite(wave)
		var mods: Array = []
		if out.is_empty() and not debut.is_empty() and Modifiers.allowed(t, debut[0]):
			mods.append(debut[0])
		var options: Array = open.filter(func(m): return Modifiers.allowed(t, m) and not mods.has(m))
		while mods.size() < want and not options.is_empty():
			var m: String = options[rng.randi() % options.size()]
			mods.append(m)
			options.erase(m)
		if mods.is_empty() or (out.is_empty() and not debut.is_empty() and not mods.has(debut[0])):
			continue
		var cost := float(COST[t]) * Modifiers.cost_mult(mods)
		if cost > budget and not out.is_empty():
			break
		budget -= cost
		out.append({"t": t, "n": 1, "i": 1.0, "d": rng.randf_range(2.0, span + 4.0), "m": mods})
	return out


static func _group(etype: String, threat: float, delay: float) -> Dictionary:
	var n := clampi(int(round(threat / (float(COST[etype]) * pack(etype)))), 1, int(MAX_COUNT.get(etype, 999)))
	return {"t": etype, "n": n, "i": float(SPACING[etype]), "d": delay}
