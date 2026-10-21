extends RefCounted
## Enemy movement patterns (enemy rework phase 5, issue #68; design/enemy_art.md): each enemy's confirmed path pattern,
## ported from the movement diagrams of the art pages (design/enemy_art_*.html). A pattern is
##   - a sideways offset from the track, in px, + to the right of the heading (`side`), and
##   - a pace, a multiplier on its speed that averages 1, so its average speed is unchanged (`pace`).
## `t` is the enemy's own movement clock (stunned time doesn't count), offset by its id so a crowd doesn't move in step.
## The pages' lane is 48 px wide and the game's 40, so offsets scale by 40/48.

const SCALE := 40.0 / 48.0
## A Shrike cluster's slots across the lane (the page's formation, in its Shrike radii of 7 px).
const CLUSTER_SIDE := [0.0, 1.4, -1.4, 2.8, -2.8]


static func side(e, t: float) -> float:
	return _side(e, t) * SCALE


static func _side(e, t: float) -> float:
	var alt := 1.0 if int(e.id) % 2 == 0 else -1.0
	match str(e.type):
		"swarmling":
			# Nanite: split and merge, two streams that part and rejoin.
			return alt * 9.0 * absf(sin(t * 1.1))
		"locust":
			return 6.0 * sin(t * 0.7) + 2.0 * (_hsh(floorf(t * 6.0)) - 0.5)
		"shrike":
			return 2.5 * sin(t * 0.6) + float(CLUSTER_SIDE[int(e.id) % 5]) * 7.0
		"runner":
			# Skitter: skittish swerves.
			return 10.0 * tanh(3.0 * sin(t * 1.7 + sin(t * 3.1)))
		"needle":
			# Twin weave: the pair crosses back and forth.
			return alt * 8.0 * sin(t * 3.0)
		"bat":
			return 3.0 * sin(t * 0.8)
		"fury":
			return 9.0 * sin(t * 2.3) + 5.0 * sin(t * 5.7)
		"gunship":
			return 2.0 * sin(t * 0.7)
		"shaman":
			# Repair Bot: weaves between units.
			return 8.0 * sin(t * 1.8)
		"siphon":
			return 3.0 * sin(t * 0.7)
		"shifter":
			# Side-shift: hops between the two sides of the lane.
			return 8.0 * (1.0 if int(floorf(t / 1.25)) % 2 == 1 else -1.0)
		"wraith":
			return 10.0 * sin(t * 0.7)
		"phantom":
			return 1.5 * sin(t * 0.9)
		"masquerade":
			# Scramble and dash, once uncovered.
			if e.disguised:
				return 0.0
			return 8.0 * (_hsh(floorf(t / 0.7)) - 0.5) * 2.0
		"mirage":
			return 7.0 * (1.0 if int(floorf(t / 1.5)) % 2 == 1 else -1.0)
		"leviathan":
			return 1.5 * sin(t * 0.5)
	return 0.0


static func pace(e, t: float) -> float:
	match str(e.type):
		"brute":
			# Siege Mech: a steady trudge, surging with each step.
			return 1.0 + 0.15 * sin(t * 6.0)
		"hydra":
			return 1.0 + 0.15 * sin(t * 5.0)
		"bulwark":
			# Brace and advance: holds still while its barriers go out, then moves up.
			return _burst(fposmod(_since_or(e, "grant", t), 6.0) / 6.0, 0.3)
		"blackout":
			# Stop and pulse: holds still for each blackout, then moves up.
			return _burst(fposmod(_since_or(e, "emp", t), 4.0) / 4.0, 0.35)
		"burrower":
			# Dive and surface: slow as it surfaces, fast underground (its cycle starts when it surfaces).
			var u: float = e.since("burrow") + (float(e.def.burrow_interval) - float(e.def.burrow_time) if e.burrowed else 0.0)
			if not e.fired.has("burrow"):
				u = t
			return 1.0 - 0.4 * cos(TAU * u / float(e.def.burrow_interval))
		"masquerade":
			if e.disguised:
				return 1.0
			return _burst(fposmod(t, 0.7) / 0.7, 0.3)
	return 1.0


## How far ahead of (or, negative, behind) its track distance it stands, in px: the Blink Stalker's feint, a step back
## just before each blink.
static func ahead(e) -> float:
	if str(e.type) != "stalker":
		return 0.0
	var left: float = e.blink_timer
	var span := 0.28 * float(e.def.blink_interval)
	if left >= span or left <= 0.0:
		return 0.0
	return -9.0 * SCALE * sin((1.0 - left / span) * PI)


## Stop for the first `wait` of each cycle (`u` 0..1), then go at 1 / (1 - wait): the same average.
static func _burst(u: float, wait: float) -> float:
	return 0.0 if u < wait else 1.0 / (1.0 - wait)


static func _since_or(e, what: String, t: float) -> float:
	return e.since(what) if e.fired.has(what) else t


## The art pages' `hash`: a repeatable pseudo-random number in [0, 1).
static func _hsh(n: float) -> float:
	var s := sin(n * 127.1 + 311.7) * 43758.5453
	return s - floorf(s)
