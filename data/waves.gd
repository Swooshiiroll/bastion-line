extends RefCounted
## Round compositions. Each round is a list of groups:
##   t = enemy type, n = count, i = seconds between spawns, d = delay from round start.
## Rounds 1-25 are hand-authored. From round 26 on, a seeded generator spends a threat budget that
## grows each round on the enemies unlocked so far, and a fixed schedule adds new-enemy
## introductions, recurring bosses and each mode's finale on its last round. Endless mode is
## the same generator continuing past the last round.


const AUTHORED := 25
const MAX_SPAWNS := 250

const WAVES := [
	[{"t": "grunt", "n": 8, "i": 1.2}],
	[{"t": "grunt", "n": 12, "i": 1.0}],
	[{"t": "grunt", "n": 10, "i": 0.9}, {"t": "runner", "n": 5, "i": 0.8, "d": 4.0}],
	[{"t": "runner", "n": 12, "i": 0.55}, {"t": "grunt", "n": 8, "i": 1.0, "d": 3.0}],
	[{"t": "grunt", "n": 10, "i": 0.8}, {"t": "juggernaut", "n": 1, "i": 1.0, "d": 6.0}],
	[{"t": "swarmling", "n": 24, "i": 0.25}, {"t": "grunt", "n": 8, "i": 1.0, "d": 4.0}],
	[{"t": "brute", "n": 5, "i": 2.0}, {"t": "grunt", "n": 12, "i": 0.8, "d": 1.0}],
	[{"t": "bat", "n": 10, "i": 0.9}, {"t": "runner", "n": 10, "i": 0.5, "d": 3.0}, {"t": "phantom", "n": 4, "i": 1.5, "d": 6.0}],
	[{"t": "shaman", "n": 3, "i": 3.0}, {"t": "grunt", "n": 16, "i": 0.6}, {"t": "aegis", "n": 3, "i": 2.5, "d": 6.0}],
	[{"t": "brute", "n": 6, "i": 1.6}, {"t": "swarmling", "n": 20, "i": 0.25, "d": 3.0}, {"t": "juggernaut", "n": 1, "i": 1.0, "d": 10.0}],
	[{"t": "bat", "n": 14, "i": 0.7}, {"t": "grunt", "n": 12, "i": 0.6, "d": 2.0}, {"t": "hydra", "n": 3, "i": 2.5, "d": 5.0}],
	[{"t": "runner", "n": 24, "i": 0.35}, {"t": "shaman", "n": 3, "i": 3.0, "d": 2.0}, {"t": "phantom", "n": 6, "i": 1.2, "d": 5.0}],
	[{"t": "brute", "n": 8, "i": 1.2}, {"t": "shaman", "n": 3, "i": 3.0, "d": 4.0}, {"t": "jammer", "n": 2, "i": 4.0, "d": 3.0}],
	[{"t": "swarmling", "n": 40, "i": 0.18}, {"t": "bat", "n": 10, "i": 0.8, "d": 4.0}, {"t": "aegis", "n": 4, "i": 2.0, "d": 6.0}],
	[{"t": "juggernaut", "n": 2, "i": 8.0}, {"t": "brute", "n": 6, "i": 1.5, "d": 3.0}, {"t": "shaman", "n": 2, "i": 4.0, "d": 5.0}],
	[{"t": "grunt", "n": 24, "i": 0.35}, {"t": "runner", "n": 16, "i": 0.3, "d": 4.0}, {"t": "hydra", "n": 4, "i": 2.0, "d": 2.0}, {"t": "phantom", "n": 6, "i": 1.0, "d": 7.0}],
	[{"t": "bat", "n": 24, "i": 0.5}, {"t": "brute", "n": 6, "i": 1.2, "d": 3.0}, {"t": "jammer", "n": 3, "i": 3.0, "d": 5.0}],
	[{"t": "shaman", "n": 6, "i": 2.0}, {"t": "brute", "n": 10, "i": 1.0}, {"t": "swarmling", "n": 30, "i": 0.2, "d": 5.0}, {"t": "aegis", "n": 5, "i": 1.8, "d": 7.0}],
	[{"t": "runner", "n": 30, "i": 0.25}, {"t": "bat", "n": 16, "i": 0.5, "d": 3.0}, {"t": "brute", "n": 6, "i": 1.2, "d": 6.0}, {"t": "phantom", "n": 10, "i": 0.8, "d": 8.0}],
	[{"t": "juggernaut", "n": 3, "i": 6.0}, {"t": "shaman", "n": 4, "i": 3.0, "d": 2.0}, {"t": "bat", "n": 16, "i": 0.5, "d": 6.0}],
	[{"t": "brute", "n": 12, "i": 0.8}, {"t": "swarmling", "n": 40, "i": 0.15, "d": 3.0}, {"t": "hydra", "n": 6, "i": 1.5, "d": 5.0}, {"t": "jammer", "n": 2, "i": 3.0, "d": 8.0}],
	[{"t": "bat", "n": 30, "i": 0.4}, {"t": "runner", "n": 24, "i": 0.3, "d": 2.0}, {"t": "phantom", "n": 10, "i": 0.7, "d": 5.0}],
	[{"t": "shaman", "n": 8, "i": 1.5}, {"t": "brute", "n": 12, "i": 0.9, "d": 2.0}, {"t": "grunt", "n": 24, "i": 0.3, "d": 4.0}, {"t": "aegis", "n": 7, "i": 1.5, "d": 6.0}],
	[{"t": "juggernaut", "n": 4, "i": 4.0}, {"t": "brute", "n": 10, "i": 1.0, "d": 2.0}, {"t": "bat", "n": 20, "i": 0.5, "d": 6.0}, {"t": "jammer", "n": 3, "i": 3.0, "d": 4.0}],
	[{"t": "juggernaut", "n": 2, "i": 5.0, "d": 4.0}, {"t": "brute", "n": 12, "i": 1.0}, {"t": "shaman", "n": 6, "i": 2.0, "d": 6.0}, {"t": "bat", "n": 20, "i": 0.5, "d": 8.0}, {"t": "aegis", "n": 5, "i": 2.0, "d": 3.0}, {"t": "phantom", "n": 8, "i": 0.8, "d": 10.0}],
]

## Round each v3 enemy is introduced (its own group leads that round), one every two rounds.
const INTRO := {
	"locust": 26, "rally": 28, "burrower": 30, "gunship": 32,
	"stalker": 34, "mender": 36, "bulwark": 38, "rampart": 40,
}

## Threat each regular enemy costs the generator (roughly its round-1 toughness in Drones).
## Only these types are picked for generated groups; bosses come from the schedule.
const COST := {
	"grunt": 1.0, "runner": 0.7, "brute": 3.8, "swarmling": 0.35, "bat": 0.9, "shaman": 1.8,
	"phantom": 1.2, "aegis": 4.0, "hydra": 3.0, "jammer": 2.1, "locust": 0.3, "rally": 2.4,
	"burrower": 2.3, "gunship": 6.0, "stalker": 1.6, "mender": 5.4, "bulwark": 2.9, "rampart": 7.4,
}

## Seconds between spawns within a generated group.
const SPACING := {
	"grunt": 0.35, "runner": 0.3, "brute": 0.9, "swarmling": 0.14, "bat": 0.45, "shaman": 1.8,
	"phantom": 0.5, "aegis": 1.2, "hydra": 1.1, "jammer": 2.0, "locust": 0.1, "rally": 1.6,
	"burrower": 0.8, "gunship": 1.5, "stalker": 0.6, "mender": 1.4, "bulwark": 1.6, "rampart": 1.8,
}

## Support enemies stop being fun in bulk, so generated groups of them are capped.
const MAX_COUNT := {"shaman": 8, "jammer": 5, "rally": 6, "bulwark": 6}

## Each mode's last round (by round number): the boss line-up on top of the generated groups.
const FINALES := {
	40: [["juggernaut", 2], ["leviathan", 1], ["warlord", 1]],
	60: [["juggernaut", 2], ["warlord", 1], ["colossus", 1]],
	80: [["juggernaut", 3], ["leviathan", 1], ["warlord", 1], ["colossus", 1]],
	100: [["juggernaut", 3], ["leviathan", 1], ["warlord", 1], ["colossus", 1]],
	120: [["juggernaut", 4], ["leviathan", 2], ["warlord", 2], ["colossus", 2]],
}


## Past LATE_START, enemy HP also compounds by `late_growth` per round, so even a map full of
## maxed towers eventually breaks (the balance probe can override it with --growth=).
const LATE_START := 40
static var late_growth := 0.04


## Enemy HP multiplier for a round (the same on every mode).
static func hp_scale(wave: int) -> float:
	var w := float(maxi(wave, 1) - 1)
	var base := 1.0 + 0.06 * w + 0.0025 * w * w
	return base * pow(1.0 + late_growth, float(maxi(0, wave - LATE_START)))


## Enemy speed multiplier for a round: +0.45% per round, capped at +50%. Bosses get half.
static func speed_scale(wave: int, boss := false) -> float:
	var bonus := minf(0.5, 0.0045 * float(maxi(wave, 1) - 1))
	return 1.0 + bonus * (0.5 if boss else 1.0)


## Threat the generator spends on a round's regular groups.
static func threat_budget(wave: int) -> float:
	return 100.0 + 2.4 * float(maxi(0, wave - AUTHORED))


## Kill credits grow with the round's enemy HP (raised to `bounty_exp`), so income keeps up with
## tougher rounds. The balance probe can override the exponent with --bounty=.
static var bounty_exp := 0.3


static func bounty_scale(wave: int) -> float:
	return pow(hp_scale(maxi(wave, 1)), bounty_exp)


static func clear_bonus(wave: int) -> int:
	return 20 + 3 * wave


static func early_call_bonus(wave: int) -> int:
	return 10 + 2 * wave


## The groups for `wave` in a run whose last round is `final` (0: no finale anywhere).
static func get_wave(wave: int, rng: RandomNumberGenerator, final := 0) -> Array:
	if wave >= 1 and wave <= WAVES.size():
		return WAVES[wave - 1]
	return generated_round(wave, rng, final)


## First round a regular enemy can appear in (authored waves, then v3 introductions).
static func unlock_round(etype: String) -> int:
	if INTRO.has(etype):
		return int(INTRO[etype])
	for i in WAVES.size():
		for grp in WAVES[i]:
			if grp.t == etype:
				return i + 1
	return 999


## The scheduled boss groups for a round (none in the authored rounds).
static func boss_groups(wave: int, final := 0) -> Array:
	var out: Array = []
	if wave <= AUTHORED:
		return out
	var line: Array = []
	if final > 0 and wave == final and FINALES.has(final):
		line = FINALES[final]
	else:
		if wave % 5 == 0:
			line.append(["juggernaut", 1 + (wave - AUTHORED) / 20])
		if wave >= 50 and wave % 25 == 0:
			line.append(["warlord", 1 + (wave - 50) / 75])
		if wave >= 35 and (wave - 35) % 20 == 0:
			line.append(["leviathan", 1 + (wave - 35) / 60])
		if wave >= 60 and (wave - 60) % 20 == 0:
			line.append(["colossus", 1 + (wave - 60) / 60])
	for k in line.size():
		var entry: Array = line[k]
		out.append({"t": entry[0], "n": int(entry[1]), "i": 6.0, "d": 4.0 + 7.0 * k})
	return out


## First round `etype` appears in a run whose last round is `final` (999 if never).
static func first_round(etype: String, final := 0) -> int:
	if COST.has(etype):
		return unlock_round(etype)
	var authored := unlock_round(etype)
	if authored < 999:
		return authored
	for w in range(AUTHORED + 1, maxi(final, 150) + 1):
		for grp in boss_groups(w, final):
			if grp.t == etype:
				return w
	return 999


static func generated_round(wave: int, rng: RandomNumberGenerator, final := 0) -> Array:
	var groups: Array = []
	var budget := threat_budget(wave)
	var delay := 0.0
	for t in INTRO:
		if int(INTRO[t]) == wave:
			groups.append(_group(t, budget * 0.3, 0.0))
			budget *= 0.7
			delay = 3.0
	var pool: Array = []
	for t in COST:
		if unlock_round(t) < wave:
			pool.append(t)
	var n_groups := 3 + clampi((wave - 26) / 20, 0, 3)
	var picks: Array = []
	for g in n_groups:
		var total := 0.0
		var weights: Array = []
		for t in pool:
			var wt := 0.0
			if not picks.has(t):
				# Newer enemies turn up more often while they're fresh.
				wt = 2.5 if unlock_round(t) >= wave - 12 else 1.0
			weights.append(wt)
			total += wt
		if total <= 0.0:
			break
		var roll := rng.randf() * total
		for k in pool.size():
			roll -= float(weights[k])
			if roll <= 0.0 and float(weights[k]) > 0.0:
				picks.append(pool[k])
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
	# Cap the spawn count for performance; beyond it, rounds get tougher through HP and speed.
	var count := 0
	for grp in groups:
		count += int(grp.n)
	if count > MAX_SPAWNS:
		var f := float(MAX_SPAWNS) / float(count)
		for grp in groups:
			grp["n"] = maxi(1, int(float(grp.n) * f))
	groups.append_array(boss_groups(wave, final))
	return groups


static func _group(etype: String, threat: float, delay: float) -> Dictionary:
	var n := clampi(int(round(threat / float(COST[etype]))), 1, int(MAX_COUNT.get(etype, 999)))
	return {"t": etype, "n": n, "i": float(SPACING[etype]), "d": delay}
