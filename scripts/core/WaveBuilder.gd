extends RefCounted
## The Sandbox wave builder's waves (#118, design/sandbox.md "Wave builder"). A wave is a list of groups; a group is one enemy
## type sent `n` times, `gap` s apart, then `delay` s before the next group starts, with elite modifiers `mods`:
## {"t": type, "n": count, "gap": s, "delay": s, "mods": [ids]}. Group i+1 starts when group i's last enemy has spawned, plus
## group i's delay. Limits and steps are the builder's, not balance numbers.

const Enemies = preload("res://data/enemies.gd")
const Modifiers = preload("res://data/modifiers.gd")

const MAX_GROUPS := 30
const COUNT_MIN := 1
const COUNT_MAX := 100
const GAP_MIN := 0.1
const GAP_MAX := 5.0
const DELAY_MIN := 0.0
const DELAY_MAX := 30.0
## One click of a stepper; Shift steps five times as far.
const STEP := {"n": 1.0, "gap": 0.1, "delay": 0.5}
const SHIFT_STEPS := 5
## A new group's gap (the Spawner's spacing) and delay.
const DEFAULT_GAP := 0.4
const DEFAULT_DELAY := 1.0


## A new group of `type`, `n` strong, carrying the mods of `mods` it can take.
static func group(type: String, n: int, mods: Array = []) -> Dictionary:
	return clamp_group({"t": type, "n": n, "gap": DEFAULT_GAP, "delay": DEFAULT_DELAY, "mods": mods.filter(func(m): return Modifiers.allowed(type, m))})


## `g` with every value inside the builder's limits (gap and delay to their step).
static func clamp_group(g: Dictionary) -> Dictionary:
	var type := str(g.get("t", ""))
	return {
		"t": type,
		"n": clampi(int(g.get("n", 1)), COUNT_MIN, COUNT_MAX),
		"gap": clampf(snappedf(float(g.get("gap", DEFAULT_GAP)), 0.1), GAP_MIN, GAP_MAX),
		"delay": clampf(snappedf(float(g.get("delay", DEFAULT_DELAY)), 0.5), DELAY_MIN, DELAY_MAX),
		"mods": Array(g.get("mods", [])).filter(func(m): return Modifiers.MODIFIERS.has(m) and Modifiers.allowed(type, m)),
	}


## A wave from a save: groups of enemies that no longer exist are dropped, values clamped, at most MAX_GROUPS kept.
static func sanitize(raw) -> Array:
	var out: Array = []
	if not (raw is Array):
		return out
	for g in raw:
		if g is Dictionary and Enemies.ENEMIES.has(str(g.get("t", ""))) and out.size() < MAX_GROUPS:
			out.append(clamp_group(g))
	return out


## `g` with `field` ("n", "gap" or "delay") stepped `dir` (+1 / -1) clicks, `big` for a Shift step.
static func stepped(g: Dictionary, field: String, dir: int, big := false) -> Dictionary:
	var out := g.duplicate(true)
	out[field] = float(g[field]) + float(dir) * float(STEP[field]) * (SHIFT_STEPS if big else 1)
	return clamp_group(out)


## How many enemies the wave sends.
static func total(groups: Array) -> int:
	var n := 0
	for g in groups:
		n += int(g.n)
	return n


## When each group starts, in seconds after Send.
static func starts(groups: Array) -> Array:
	var out: Array = []
	var t := 0.0
	for g in groups:
		out.append(t)
		t += float(int(g.n) - 1) * float(g.gap) + float(g.delay)
	return out


## Seconds from Send to the wave's last spawn.
static func duration(groups: Array) -> float:
	if groups.is_empty():
		return 0.0
	var g: Dictionary = groups[-1]
	return float(starts(groups)[-1]) + float(int(g.n) - 1) * float(g.gap)
