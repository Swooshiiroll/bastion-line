extends "res://scripts/view/enemies/EnemyKit.gd"
## Boss role art (design/enemy_art_boss.html, confirmed 2026-10-08): Dreadnought, Overmind, Leviathan and Colossus.
## Each wears the boss crest (a gold crown on a red disc).
##
## State (from EnemyArt.state): "summon" seconds since the Overmind printed Nanites or the Leviathan launched
## Locusts; "s1"/"s2" 0..1 as the Colossus sheds its first and second armour, "d1"/"d2" 0..1 while the Siege Mechs
## of each shed climb down (-1 when not). Without them the page's own clocks run.

const SwarmArt = preload("res://scripts/view/enemies/SwarmArt.gd")
const TankArt = preload("res://scripts/view/enemies/TankArt.gd")

const DREAD := {"hull": Color(0.26, 0.27, 0.3), "panel": Color(0.4, 0.42, 0.46), "dark": Color(0.13, 0.14, 0.16), "glow": Color(1, 0.25, 0.2)}
const OVER := {"hull": Color(0.55, 0.38, 0.26), "panel": Color(0.68, 0.5, 0.34), "dark": Color(0.3, 0.2, 0.14), "glow": Color(1, 0.72, 0.25)}
const LEVI := {"hull": Color(0.3, 0.36, 0.22), "panel": Color(0.44, 0.5, 0.3), "dark": Color(0.17, 0.2, 0.12), "glow": Color(1, 0.92, 0.3)}
const COLO := {"plate": Color(0.86, 0.68, 0.16), "trim": Color(0.7, 0.5, 0.27), "frame": Color(0.15, 0.16, 0.19), "glow": Color(1, 0.45, 0.15)}
const CRIMSON := Color(1, 0.25, 0.2)
const NANITE_EYE := Color(1, 0.72, 0.25)


## Dreadnought, look B Dread tank: a land battleship on four tread units, three turrets and a command tower. Its
## frost ring forms and cracks away every 3 s, and its weight sends faint shock rings through the ground.
static func dreadnought(c: Vector2, t: float, r: float, _st: Dictionary) -> void:
	var C := DREAD
	var u := fposmod(t, 3.0)
	if u < 0.7:
		var q := u / 0.7
		ring(c, r * 1.15, Color(0.55, 0.85, 1, 0.7 * (1.0 - q)), 1.6)
		for i in 8:
			var a := float(i) * TAU / 8.0
			fill(c + fa(a) * r * (1.15 + 0.5 * q), P([[0.5, 0], [-0.3, 0.3], [-0.3, -0.3]]), Color(0.7, 0.9, 1, 0.7 * (1.0 - q)), a, r * 0.1)
	var f := fposmod(t, 0.8) / 0.8
	ring(c, r * (0.9 + 0.5 * f), Color(0.6, 0.55, 0.45, 0.25 * (1.0 - f)), 2.5)
	for q in [[0.55, 0.55], [0.55, -0.55], [-0.55, 0.55], [-0.55, -0.55]]:
		tread(c + Vector2(q[0] * r, q[1] * r), r * 0.32, r * 0.14, t, 0.6, 0.8)
	var hull := rr_pts(0.85, 0.5, 0.12)
	plate(c, hull, C.hull, 0.0, r, 1.2)
	rivets(c, hull, 0.0, r, 0.88, 0.8)
	for x in [0.5, 0.05, -0.45]:
		var tu := c + Vector2(x * r, 0)
		var a := 0.3 * sin(t * 0.7 + x * 3.0)
		bar(tu, tu + fa(a) * r * 0.5, 2.2, C.dark)
		disc(tu, r * 0.17, OUTLINE)
		disc(tu, r * 0.15, C.panel)
		disc(tu, r * 0.05, CRIMSON)
	crest(c + Vector2(-r * 0.2, r * 0.3), r * 0.12, t)


## Overmind, look A Brain hive: a domed neural core in a hex shell on eight long arachnid legs; it shudders as it
## prints Nanites from three bays.
static func overmind(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := OVER
	var bays := [[-0.62, 0.0, -1.0, 0.0], [0.0, 0.62, -0.3, 1.0], [0.0, -0.62, -0.3, -1.0]]
	for i in 4:
		for sg in [-1.0, 1.0]:
			var sw := sin(t * 2.5 + float(i) * 1.6 + (PI if sg > 0.0 else 0.0))
			var root := c + Vector2(r * (0.36 - float(i) * 0.24), sg * r * 0.4)
			var knee := root + Vector2(r * (0.28 - float(i) * 0.16 + 0.06 * sw), sg * r * 0.55)
			var ft := root + Vector2(r * (0.2 - float(i) * 0.3 + 0.12 * sw), sg * r * 0.98)
			limb(PackedVector2Array([root, knee, ft]), 2.2, C.dark)
			disc(knee, 1.6, C.panel)
			disc(ft, 1.4, OUTLINE)
	plate(c, ngon(6, 0.68, 0.0), C.hull, 0.0, r, 1.2)
	for b in bays:
		plate(c + Vector2(b[0] * r * 0.85, b[1] * r * 0.85), rect_pts(0.1, 0.1), C.dark, 0.0, r, 0.6)
	var core := c + Vector2(r * 0.08, 0)
	disc(core, r * 0.42, OUTLINE)
	disc(core, r * 0.39, Color(0.3, 0.16, 0.08))
	for i in 5:
		var pts := PackedVector2Array()
		for k in 9:
			var a := -1.2 + 2.4 * float(k) / 8.0
			pts.append(core + Vector2(cos(a) * r * (0.1 + 0.06 * float(i)), sin(a) * r * 0.32 + sin(float(k) * 1.7 + float(i) + t * 2.0) * r * 0.03))
		polyline(pts, al(C.glow, 0.45 + 0.35 * sin(t * 3.0 + float(i))), 0.9)
	glow_dot(core, r * 0.08, C.glow)
	crest(c + Vector2(-r * 0.42, 0), r * 0.11, t)
	var u: float = st.get("summon", fposmod(t, 5.0))
	if u < 1.8:
		var q := u / 1.8
		for i in bays.size():
			var b: Array = bays[i]
			var p: Vector2 = c + Vector2(b[0], b[1]) * r + Vector2(b[2], b[3]) * r * 1.1 * q
			if u < 0.25:
				glow_dot(c + Vector2(b[0], b[1]) * r, r * 0.1, NANITE_EYE)
			push_alpha(minf(1.0, 3.0 * (1.0 - q)))
			SwarmArt.nanite(p, t + float(i), r * 0.27, {})
			pop_alpha()


## Leviathan, look K Jet carrier: a giant airliner-like carrier with four jet pods and a high tail; six Locusts
## launch from its spine.
static func leviathan(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := LEVI
	for sg in [-1.0, 1.0]:
		plate(c, P([[0.2, sg * 0.12], [-0.3, sg * 1.0], [-0.45, sg * 0.98], [-0.25, sg * 0.12]]), C.hull, 0.0, r, 1.0)
		for k in [0.4, 0.75]:
			var e := c + Vector2(r * (0.02 - 0.42 * k), sg * r * (0.12 + 0.82 * k))
			plate(e, rr_pts(0.12, 0.05, 0.04), C.dark, 0.0, r, 0.6)
			glow_dot(e + Vector2(-r * 0.13, 0), r * 0.03 * (0.9 + 0.15 * sin(t * 22.0 + k * 9.0)), Color(1, 0.85, 0.45))
		fill(c, P([[-0.8, sg * 0.06], [-1.0, sg * 0.35], [-1.06, sg * 0.32], [-0.98, sg * 0.06]]), C.panel, 0.0, r)
	plate(c, P([[1.05, 0], [0.8, 0.13], [-0.95, 0.1], [-1.05, 0], [-0.95, -0.1], [0.8, -0.13]]), C.panel, 0.0, r, 1.0)
	for i in 6:
		plate(c + Vector2(r * (0.55 - float(i) * 0.22), 0), rect_pts(0.05, 0.05), C.dark, 0.0, r, 0.5)
	ellipse(c + Vector2(r * 0.85, 0), r * 0.1, r * 0.05, INK)
	crest(c + Vector2(r * 0.62, 0), r * 0.05, t)
	var u: float = st.get("summon", fposmod(t, 6.0))
	if u < 2.2:
		for i in 6:
			var q := maxf(0.0, (u - float(i) * 0.12) / 1.8)
			if q <= 0.0 or q >= 1.0:
				continue
			var dy := 1.0 if i % 2 == 1 else -1.0
			var p := c + Vector2(0.55 - float(i) * 0.22, 0) * r + Vector2(0.3, dy) * r * 1.4 * q
			push_alpha(minf(1.0, 3.0 * (1.0 - q)))
			push(p, atan2(dy, 0.3))
			SwarmArt.locust(Vector2.ZERO, t + float(i), r * 0.27, {})
			pop()
			pop_alpha()


## Colossus, look A Colossus mech: amber armour over a black frame; at each shed a plate set comes away and two Siege
## Mechs climb down from its back bays.
static func colossus(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := COLO
	var u := fposmod(t, 12.0)
	var s1: float = st.get("s1", 0.0 if u < 4.0 else minf(1.0, u - 4.0))
	var s2: float = st.get("s2", 0.0 if u < 8.0 else minf(1.0, u - 8.0))
	var d1: float = st.get("d1", (u - 4.0) / 2.2 if u >= 4.0 and u < 6.2 else -1.0)
	var d2: float = st.get("d2", (u - 8.0) / 2.2 if u >= 8.0 and u < 10.2 else -1.0)
	var sw := sin(t * 1.8)
	var bays := [[-0.55, 0.25, -1.0, 0.5], [-0.55, -0.25, -1.0, -0.5]]
	for d in [d1, d2]:
		if d < 0.0:
			continue
		for i in bays.size():
			var b: Array = bays[i]
			var p: Vector2 = c + Vector2(b[0], b[1]) * r + Vector2(b[2], b[3]) * r * 0.9 * d
			push_alpha(minf(1.0, 3.0 * (1.0 - d)))
			push(p, atan2(b[3], b[2]) + PI)
			TankArt.siege(Vector2.ZERO, t + float(i), r * 0.44, {}, true)
			pop()
			pop_alpha()
	for sg in [-1.0, 1.0]:
		var hip := c + Vector2(-r * 0.15, sg * r * 0.32)
		var ft := c + Vector2(r * (-0.1 + 0.28 * sw * sg), sg * r * 0.55)
		limb(PackedVector2Array([hip, ft]), 4.4, C.frame)
		foot(ft, C.frame, r, 0.25, 0.15)
	for sg in [-1.0, 1.0]:
		var sh := c + Vector2(r * 0.05, sg * r * 0.5)
		var fist := c + Vector2(r * (0.55 - 0.08 * sw * sg), sg * r * 0.66)
		limb(PackedVector2Array([sh, c + Vector2(r * 0.3, sg * r * 0.72), fist]), 4.0, C.frame)
		disc(fist, r * 0.12, OUTLINE)
		disc(fist, r * 0.1, C.trim)
	var body := rr_pts(0.45, 0.42, 0.12)
	plate(c, body, C.frame, 0.0, r, 1.2)
	outline(c, body, al(C.glow, 0.25 + 0.3 * s2), 0.8, 0.0, r * 0.82)
	glow_dot(c, r * (0.07 + 0.03 * s2), C.glow)
	for sg in [-1.0, 1.0]:
		shed_plate(c, P([[0.22, sg * 0.3], [0.18, sg * 0.75], [-0.32, sg * 0.78], [-0.42, sg * 0.3]]), Vector2(0.2, sg), s1, C.plate, r, 0.6, 1.1)
	shed_plate(c, P([[0.48, 0], [0.32, 0.22], [0.02, 0.22], [0.02, -0.22], [0.32, -0.22]]), Vector2(1, -0.3), s2, C.plate, r, 0.6, 1.1)
	shed_plate(c, P([[-0.1, 0.25], [-0.1, -0.25], [-0.45, -0.2], [-0.52, 0], [-0.45, 0.2]]), Vector2(-1, 0.3), s2, C.trim, r, 0.6, 1.1)
	slit(c + Vector2(r * 0.4, 0), r * 0.1, C.glow, 2.6, 1.4)
	crest(c + Vector2(-r * 0.15, 0), r * 0.09, t)
