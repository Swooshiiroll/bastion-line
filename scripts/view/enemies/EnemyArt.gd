extends RefCounted
## Enemy art (enemy rework phase 5, issue #68): the confirmed looks and animations from design/enemy_art.md, drawn by
## the role scripts beside this one. Draw.enemy calls `draw`.
##
## A look is drawn at its page size (the page's radius times the caller's scale), facing its heading, through its
## animation: an offset, a turn and a stretch of the whole unit, plus a lift that thins its shadow. Effects that come
## from the game (an EMP, a heal, a blink, a shed...) take their timing from `state(e)` for an enemy on the field;
## without it (the Codex, panels, the spawner) each look runs the page's demo clocks, unmasked and uncloaked.

const Kit = preload("res://scripts/view/enemies/EnemyKit.gd")
const SwarmArt = preload("res://scripts/view/enemies/SwarmArt.gd")
const RusherArt = preload("res://scripts/view/enemies/RusherArt.gd")
const TankArt = preload("res://scripts/view/enemies/TankArt.gd")
const SupportArt = preload("res://scripts/view/enemies/SupportArt.gd")
const DisruptorArt = preload("res://scripts/view/enemies/DisruptorArt.gd")
const EvaderArt = preload("res://scripts/view/enemies/EvaderArt.gd")
const SpecialArt = preload("res://scripts/view/enemies/SpecialArt.gd")
const BossArt = preload("res://scripts/view/enemies/BossArt.gd")
const EnemyTraits = preload("res://scripts/core/EnemyTraits.gd")

## Enemy type: [role script, look function, the page's radius, flyer].
const LOOKS := {
	"swarmling": [SwarmArt, "nanite", 7.0, false],
	"locust": [SwarmArt, "locust", 8.0, true],
	"grunt": [SwarmArt, "drone", 11.0, false],
	"shrike": [SwarmArt, "shrike", 7.0, true],
	"runner": [RusherArt, "skitter", 10.0, false],
	"needle": [RusherArt, "needle", 8.0, false],
	"bat": [RusherArt, "strike_drone", 9.0, true],
	"fury": [RusherArt, "fury", 11.0, false],
	"brute": [TankArt, "siege", 14.0, false],
	"rampart": [TankArt, "rampart", 16.0, false],
	"gunship": [TankArt, "gunship", 16.0, true],
	"titan": [TankArt, "titan", 18.0, false],
	"shaman": [SupportArt, "repair", 11.0, false],
	"rally": [SupportArt, "rally", 12.0, false],
	"bulwark": [SupportArt, "bulwark", 13.0, false],
	"mender": [SupportArt, "mender", 15.0, false],
	"jammer": [DisruptorArt, "jammer", 12.0, false],
	"siphon": [DisruptorArt, "siphon", 13.0, false],
	"blackout": [DisruptorArt, "blackout", 15.0, false],
	"capacitor": [DisruptorArt, "capacitor", 16.0, false],
	"stalker": [EvaderArt, "stalker", 10.0, false],
	"burrower": [EvaderArt, "burrower", 11.0, false],
	"shifter": [EvaderArt, "shifter", 12.0, false],
	"wraith": [EvaderArt, "wraith", 13.0, true],
	"phantom": [SpecialArt, "phantom", 10.0, true],
	"aegis": [SpecialArt, "aegis", 13.0, false],
	"hydra": [SpecialArt, "hydra", 14.0, false],
	"masquerade": [SpecialArt, "masquerade", 12.0, false],
	"decoy": [SpecialArt, "decoy", 15.0, false],
	"mirage": [SpecialArt, "mirage", 12.0, false],
	"juggernaut": [BossArt, "dreadnought", 22.0, false],
	"warlord": [BossArt, "overmind", 26.0, false],
	"leviathan": [BossArt, "leviathan", 30.0, true],
	"colossus": [BossArt, "colossus", 32.0, false],
}
## What a look shows away from the field: uncloaked, above ground, unmasked, no hologram copies.
const ICON := {"reveal": 1.0, "under": 0.0, "uncover": 1.0, "hologram": false}


## The page radius of a type's look (its drawn size at scale 1).
static func radius(type: String, fallback := 10.0) -> float:
	return float(LOOKS[type][2]) if LOOKS.has(type) else fallback


static func has(type: String) -> bool:
	return LOOKS.has(type)


## Draws one enemy. `st` is `state(e)` for an enemy on the field, or empty for a preview.
static func draw(ci: CanvasItem, type: String, c: Vector2, facing: Vector2, t: float, s := 1.0, st := {}) -> void:
	var look: Array = LOOKS[type]
	if st.is_empty():
		st = ICON
	var r: float = look[2]
	var rr := r * s
	var a := anim(type, t, st)
	var lift: float = a[5]
	var vis := 1.0
	if type in ["phantom", "wraith"]:
		vis = 0.1 + 0.9 * float(st.get("reveal", 1.0))
	elif type == "burrower":
		vis = 1.0 - float(st.get("under", 0.0))
	if vis > 0.01:
		if look[3]:
			Kit.Draw.ellipse(ci, c + Vector2(0, rr * (2.4 + lift)), rr * (1.0 - 0.2 * lift), rr * 0.32 * (1.0 - 0.2 * lift), Color(0, 0, 0, 0.18 * vis))
		else:
			var k := 1.0 - 0.35 * lift
			Kit.Draw.ellipse(ci, c + Vector2(0, rr * 0.75), rr * 1.1 * k, rr * 0.45 * k, Color(0, 0, 0, 0.3 * vis))
	var alpha: float = a[6]
	if not (type in ["phantom", "wraith"]) and float(st.get("reveal", 1.0)) < 1.0:
		# A Cloaked elite of another kind: a faint shimmer until revealed.
		alpha *= 0.25
	var ang := facing.angle()
	var off := Vector2(a[0], a[1]).rotated(ang) * rr
	Kit.begin(ci, c + off, ang + float(a[2]), float(a[3]) * s, float(a[4]) * s, alpha)
	(look[0] as Script).call(look[1], Vector2.ZERO, t, r, st)


## A look's animation at time t: [dx, dy, turn, stretch x, stretch y, lift, alpha] (offsets in its radii).
static func anim(type: String, t: float, st: Dictionary) -> Array:
	var dx := 0.0
	var dy := 0.0
	var rot := 0.0
	var sx := 1.0
	var sy := 1.0
	var lift := 0.0
	var alpha := 1.0
	match type:
		"swarmling":
			sx = 0.85 + 0.25 * maxf(0.0, sin(t * 2.0))
			sy = sx
		"locust":
			dy = 0.18 * sin(t * 3.0)
			rot = 0.05 * sin(t * 25.0)
		"grunt":
			rot = 0.06 * sin(t * 6.0)
			dy = -0.03 * absf(sin(t * 6.0))
		"shrike":
			dy = 0.08 * sin(t * 1.2)
		"runner":
			rot = 0.15 * sin(t * 14.0)
			dy = 0.06 * sin(t * 14.0)
		"needle":
			dy = 0.03 * sin(t * 40.0)
		"bat":
			var p := maxf(0.0, sin(t * 3.0))
			sx = 1.0 - 0.12 * p
			sy = sx
			lift = p
		"fury":
			rot = 0.12 * sin(t * 31.0)
			dx = 0.05 * sin(t * 43.0)
		"brute":
			var p := absf(sin(t * 4.0))
			dy = 0.05 * (1.0 - p)
			sx = 1.0 + 0.03 * (1.0 - p)
			sy = 1.0 - 0.03 * (1.0 - p)
		"rampart":
			var k := fposmod(t, 1.4)
			if k < 0.3:
				rot = 0.05 * sin(k * 60.0) * (1.0 - k / 0.3)
				dx = 0.03 * sin(k * 45.0)
		"gunship":
			dy = 0.06 * sin(t * 1.6)
			lift = 0.25 + 0.25 * sin(t * 1.6)
		"titan":
			var p := absf(sin(t * 2.2))
			dy = 0.05 * (1.0 - p)
			sx = 1.0 + 0.025 * (1.0 - p)
			sy = 1.0 - 0.025 * (1.0 - p)
			rot = 0.035 * sin(t * 2.2)
		"shaman":
			var n := floorf(t * 6.0)
			dx = (Kit.hsh(n) - 0.5) * 0.08
			rot = (Kit.hsh(n + 3.0) - 0.5) * 0.15
		"rally":
			var p := absf(sin(t * 5.0))
			dy = -0.06 * p
			sx = 1.0 + 0.03 * (1.0 - p)
			sy = 1.0 - 0.03 * (1.0 - p)
		"bulwark", "capacitor":
			dx = 0.012 * sin(t * 41.0)
			dy = 0.012 * sin(t * 37.0)
		"mender":
			rot = 0.06 * sin(t * 1.5)
			dx = 0.05 * maxf(0.0, sin(t * 3.0))
		"jammer":
			# Static jitter, wilder just after an EMP.
			var n := floorf(t * 14.0)
			var ju := float(st.get("emp", fposmod(t, 5.0)))
			var j := 0.03 + 0.1 * maxf(0.0, 1.0 - ju)
			dx = (Kit.hsh(n) - 0.5) * j
			dy = (Kit.hsh(n + 4.0) - 0.5) * j
		"siphon":
			var p := pow(maxf(0.0, sin(t * 2.2)), 2.0)
			sx = 1.0 + 0.06 * p
			sy = sx
		"blackout":
			dx = 0.06 * sin(t * 1.5)
			sx = 1.0 + 0.03 * sin(t * 1.5)
		"stalker":
			# Phase shimmer, stronger in the last moments before a blink.
			var left := float(st.get("blink_in", 4.0 - fposmod(t, 4.0)))
			var k := (0.8 - left) / 0.8 if left < 0.8 else 0.15
			sx = 1.0 + 0.07 * k * sin(t * 60.0)
			sy = 1.0 + 0.07 * k * sin(t * 53.0)
		"burrower":
			dx = 0.02 * sin(t * 37.0)
			dy = 0.02 * sin(t * 31.0)
		"shifter":
			dy = 0.04 * sin(t * 1.8)
			rot = 0.05 * sin(t * 1.8)
		"wraith":
			dy = 0.06 * sin(t * 1.4)
			rot = 0.04 * sin(t * 0.9)
		"phantom":
			# Camo flicker while hidden.
			var n := floorf(t * 24.0)
			var fl := 0.25 + 0.25 * Kit.hsh(n + 7.0) if Kit.hsh(n) < 0.45 else 1.0
			alpha = lerpf(fl, 1.0, float(st.get("reveal", 1.0)))
		"aegis":
			if float(st.get("crack", 0.0)) > 0.0:
				sx = 0.95
				sy = 1.04
				dx = -0.03 * absf(sin(t * 20.0))
		"hydra":
			var n := floorf(t * 10.0)
			dx = (Kit.hsh(n) - 0.5) * 0.06
			dy = (Kit.hsh(n + 3.0) - 0.5) * 0.06
		"masquerade":
			# Marches like a Drone while disguised; nervous jitters once uncovered.
			var k := float(st.get("uncover", 1.0))
			var n := floorf(t * 9.0)
			rot = 0.06 * sin(t * 6.0) * (1.0 - k)
			dy = -0.03 * absf(sin(t * 6.0)) * (1.0 - k) + (Kit.hsh(n + 5.0) - 0.5) * 0.06 * k
			dx = (Kit.hsh(n) - 0.5) * 0.06 * k
		"decoy":
			dy = 0.015 * sin(t * 33.0)
			dx = 0.01 * sin(t * 27.0)
		"mirage":
			dy = 0.05 * sin(t * 1.6)
		"juggernaut":
			var p := absf(sin(t * 2.5))
			dy = 0.03 * (1.0 - p)
			sx = 1.0 + 0.02 * (1.0 - p)
			sy = 1.0 - 0.02 * (1.0 - p)
		"warlord":
			# Print shudder, as it prints Nanites.
			var u := float(st.get("summon", fposmod(t, 5.0)))
			if u < 0.4:
				dx = 0.03 * sin(u * 70.0)
				sy = 1.0 - 0.04 * sin(u / 0.4 * PI)
		"leviathan":
			var h := 0.5 + 0.5 * sin(t * 0.7)
			lift = h * 0.6
			sx = 0.96 + 0.06 * h
			sy = sx
		"colossus":
			rot = 0.05 * sin(t * 0.9)
			dy = 0.02 * sin(t * 1.8)
	return [dx, dy, rot, sx, sy, lift, alpha]


## The game state an on-field enemy's look reacts to (see the role scripts for each key).
static func state(e) -> Dictionary:
	var st := {}
	var d: Dictionary = e.def
	for n in ["heal", "emp", "grant", "summon", "blink"]:
		if e.trait_timers.has(n):
			st[n] = e.since(n)
	if e.trait_timers.has("blink"):
		st.blink_in = float(e.trait_timers.blink)
		st.blink_dist = float(d.get("blink_distance", 0.0))
	if e.has_trait("burrow"):
		var u: float = minf(1.0, e.since("burrow") / 0.3)
		st.under = u if e.burrowed else 1.0 - u
		if not e.fired.has("burrow"):
			st.under = 1.0 if e.burrowed else 0.0
	if e.cloaked or e.has_trait("cloak"):
		st.reveal = 0.0 if e.is_hidden() else 1.0
		st.lock = true
	if e.has_trait("disguise"):
		st.uncover = 0.0 if e.disguised else minf(1.0, e.since("uncover") / 0.6)
	if e.has_trait("shed"):
		st.shed = minf(1.0, e.since("shed")) if e.shed else 0.0
	if e.has_trait("phases"):
		for i in 2:
			var key := "phase%d" % (i + 1)
			var since: float = e.since(key)
			st["s%d" % (i + 1)] = minf(1.0, since) if e.fired.has(key) else 0.0
			st["d%d" % (i + 1)] = since / 2.2 if e.fired.has(key) and since < 2.2 else -1.0
	if e.has_trait("regen"):
		var on: bool = e.hp < e.max_hp and e.since_hit >= float(d.regen_delay) and e.repair_block <= 0.0 and not e.silenced()
		st.regen = minf(1.0, (e.since_hit - float(d.regen_delay)) / 0.4) if on else 0.0
	if e.max_shield > 0.0 and e.has_trait("barrier"):
		var lvl: float = e.shield / e.max_shield
		st.barrier = lvl
		st.crack = (1.0 - lvl) if e.shield > 0.0 and e.since_hit < 0.4 else 0.0
		st.shatter = e.since_hit / 0.6 if e.shield <= 0.0 and e.since_hit < 0.6 else -1.0
	if d.has("emp_charge"):
		st.charge = 1.0 - e.charge_timer / float(d.emp_charge) if e.charge_timer > 0.0 else 0.0
	st.hologram = e.hologram
	return st
