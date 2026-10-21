extends "res://scripts/view/enemies/EnemyKit.gd"
## Disruptor role art (design/enemy_art_disruptor.html, confirmed 2026-10-08): Jammer, Siphon, Blackout Rig and
## Capacitor. Antenna arrays, crackling arcs and EMP rings.
##
## State (from EnemyArt.state): "emp" is seconds since the last pulse; "charge" 0..1 while a Capacitor charges.

const JAMMER := {"hull": Color(0.15, 0.16, 0.18), "panel": Color(0.3, 0.32, 0.36), "dark": Color(0.07, 0.07, 0.08), "glow": Color(0.35, 0.65, 1)}
const SIPHON := {"hull": Color(0.22, 0.18, 0.44), "panel": Color(0.36, 0.31, 0.62), "dark": Color(0.11, 0.09, 0.23), "glow": Color(0.72, 1, 0.25)}
const BLACKOUT := {"hull": Color(0.38, 0.4, 0.44), "panel": Color(0.52, 0.54, 0.58), "dark": Color(0.18, 0.19, 0.22), "glow": Color(0.72, 0.42, 1)}
const CAPACITOR := {"hull": Color(0.88, 0.88, 0.84), "copper": Color(0.8, 0.47, 0.25), "dark": Color(0.24, 0.24, 0.26), "glow": Color(1, 0.95, 0.6), "arc": Color(0.82, 0.9, 1)}


## Jammer, look A Antenna walker: a fan of antennae that arc and ring out with each EMP.
static func jammer(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := JAMMER
	var ju := float(st.get("emp", fposmod(t, 5.0))) / 1.0
	emp(c, r * 0.6, r * 2.5, ju, C.glow, t)
	for q in [[1.0, 1.0, 0.0], [1.0, -1.0, PI], [-1.0, 1.0, PI], [-1.0, -1.0, 0.0]]:
		var sw := sin(t * 5.0 + q[2])
		var hip: Vector2 = c + Vector2(q[0] * r * 0.3, q[1] * r * 0.3)
		var ft: Vector2 = c + Vector2(q[0] * r * 0.5 + sw * r * 0.12, q[1] * r * 0.62)
		limb(PackedVector2Array([hip, ft]), 1.4, C.panel)
		disc(ft, 1.2, OUTLINE)
	plate(c, ngon(8, 0.48, PI / 8.0), C.hull, 0.0, r, 0.9)
	plate(c, rect_pts(0.2, 0.2), C.panel, 0.0, r, 0.6)
	var tips := PackedVector2Array()
	for i in 5:
		var a := PI + (float(i) - 2.0) * 0.55 + 0.08 * sin(t * 4.0 + float(i))
		var root := c + fa(a) * r * 0.2
		var tip := c + fa(a) * r * (0.95 + 0.12 * float(i % 2))
		line(root, tip, INK, 1.4)
		line(root, tip, C.panel, 0.7)
		tips.append(tip)
	for p in tips:
		glow_dot(p, 0.8, al(C.glow, 0.6 + 0.4 * sin(t * 9.0 + p.y)))
	if fposmod(t, 0.6) < 0.25 or ju < 0.4:
		bolt(tips[1], tips[3], C.glow, floori(t * 15.0))
	slit(c + Vector2(r * 0.38, 0), r * 0.14, C.glow, 2.4, 1.2)
	blink_lights(c + Vector2(r * 0.1, 0), 3, r * 0.14, t, C.glow)


## Siphon, look H Tether sapper: three tethers reach out and draw motes back in.
static func siphon(c: Vector2, t: float, r: float, _st: Dictionary) -> void:
	var C := SIPHON
	arc_segments(c, r * 2.3, 12, 0.2, -t * 0.6, al(C.glow, 0.22), 0.8)
	for i in 8:
		var u := fposmod(t * 0.6 + float(i) / 8.0, 1.0)
		var a := float(i) * TAU / 8.0 + u * 1.3
		disc(c + fa(a) * r * (2.3 - 1.7 * u), 0.9 + 0.5 * u, al(C.glow, 0.75 * sin(u * PI)))
	for i in 3:
		for sg in [-1.0, 1.0]:
			var ph := t * 6.0 + float(i) * 2.1 + (PI if sg > 0.0 else 0.0)
			var root := c + Vector2(r * (0.3 - float(i) * 0.3), sg * r * 0.38)
			limb(PackedVector2Array([root, root + Vector2(r * 0.1 * sin(ph), sg * r * 0.26), root + Vector2(r * 0.18 * sin(ph), sg * r * 0.44)]), 1.1, C.dark)
	plate(c, ngon(6, 0.56, 0.0), C.hull, 0.0, r, 0.9)
	slit(c + Vector2(r * 0.48, 0), r * 0.12, C.glow, 2.4, 1.2)
	for i in 3:
		var a := float(i) * TAU / 3.0 + PI / 3.0
		var m := c + fa(a) * r * 0.3
		var tgt := c + fa(a + 0.4 * sin(t * 0.5 + float(i))) * r * 2.2
		var d := tgt - m
		var l := maxf(0.001, d.length())
		var nd := Vector2(-d.y / l, d.x / l)
		var pts := PackedVector2Array()
		for k in 11:
			var u := float(k) / 10.0
			pts.append(m + d * u + nd * sin(u * PI * 3.0 - t * 8.0) * r * 0.06 * sin(u * PI))
		polyline(pts, al(C.glow, 0.25), 2.4)
		polyline(pts, al(C.glow, 0.8), 0.7)
		var u2 := 1.0 - fposmod(t * 1.2 + float(i) / 3.0, 1.0)
		disc(pts[roundi(u2 * 10.0)], 1.0, C.glow)
		glow_dot(tgt, 0.8, al(C.glow, 0.7))
		disc(m, r * 0.11, OUTLINE)
		disc(m, r * 0.09, METAL_L)
		glow_dot(m, r * 0.04, C.glow)


## Blackout Rig, look H Spider rig: a ring of antennae on six legs; each blackout darkens the ground around it.
static func blackout(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := BLACKOUT
	var bu := float(st.get("emp", fposmod(t, 4.0))) / 1.3
	emp(c, r * 0.6, r * 2.3, bu, C.glow, t, 0.25)
	for i in 3:
		for sg in [-1.0, 1.0]:
			var sw := sin(t * 3.5 + float(i) * 2.1 + (PI if sg > 0.0 else 0.0))
			var root := c + Vector2(r * (0.3 - float(i) * 0.3), sg * r * 0.4)
			var knee := root + Vector2(r * (0.15 + 0.08 * sw), sg * r * 0.42)
			var ft := root + Vector2(r * (-0.05 + 0.16 * sw), sg * r * 0.75)
			limb(PackedVector2Array([root, knee, ft]), 2.2, C.dark)
			disc(ft, 1.6, OUTLINE)
			disc(ft, 1.2, C.panel)
	var body := P([[0.62, 0], [0.42, 0.45], [-0.45, 0.48], [-0.65, 0], [-0.45, -0.48], [0.42, -0.45]])
	plate(c, body, C.hull, 0.0, r, 1.0)
	rivets(c, body, 0.0, r, 0.8, 0.7)
	var tips := PackedVector2Array()
	for i in 8:
		var a := float(i) * TAU / 8.0 + 0.06 * sin(t * 3.0 + float(i))
		var root := c + fa(a) * r * 0.18
		var tip := c + fa(a) * r * (0.85 + 0.1 * float(i % 2))
		line(root, tip, INK, 1.4)
		line(root, tip, C.panel, 0.7)
		tips.append(tip)
	for p in tips:
		glow_dot(p, 0.8, al(C.glow, 0.6 + 0.4 * sin(t * 8.0 + p.x)))
	if fposmod(t, 0.5) < 0.2 or bu < 0.5:
		var k := floori(t * 6.0) % 8
		bolt(tips[k], tips[(k + 1) % 8], C.glow, floori(t * 15.0))
	disc(c, r * 0.16, OUTLINE)
	disc(c, r * 0.13, C.dark)
	glow_dot(c, r * 0.07, C.glow)
	slit(c + Vector2(r * 0.55, 0), r * 0.12, C.glow, 2.4, 1.2)


## Capacitor, look C Ring-reactor tank: the copper ring spins up through the charge, warning segments close in, and
## the blackout rings out.
static func capacitor(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := CAPACITOR
	var u := fposmod(t, 8.0)
	var k: float = st.get("charge", (u - 6.0) / 2.0 if u >= 6.0 else 0.0)
	emp(c, r * 0.8, r * 2.8, float(st.get("emp", u)) / 1.3, C.glow, t, 0.15)
	if k > 0.0:
		arc_segments(c, r * (2.8 - 1.8 * k), 12, 0.22, -t * 2.0, al(C.glow, 0.3 + 0.6 * k), 1.0)
	for s in [-1.0, 1.0]:
		tread(c + Vector2(0, s * r * 0.62), r * 0.85, r * 0.2, t)
	plate(c, rect_pts(0.75, 0.48), C.dark, 0.0, r, 1.0)
	slit(c + Vector2(r * 0.68, 0), r * 0.18, C.glow, 2.4, 1.2)
	ring(c, r * 0.48, OUTLINE, 4.6)
	ring(c, r * 0.48, C.hull, 3.2)
	var sp := t * (0.8 + 7.0 * k)
	for i in 6:
		var a := sp + float(i) * TAU / 6.0
		arc(c, r * 0.48, a - 0.18, a + 0.18, C.copper, 3.2)
	disc(c, r * 0.2, OUTLINE)
	disc(c, r * 0.17, Color(0.3, 0.3, 0.32))
	glow_dot(c, r * (0.06 + 0.1 * k), C.glow)
	if k > 0.3:
		bolt(c + fa(sp) * r * 0.48, c + fa(sp + 2.5) * r * 0.48, C.arc, floori(t * 15.0))
