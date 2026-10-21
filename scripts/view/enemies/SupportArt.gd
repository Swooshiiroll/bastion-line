extends "res://scripts/view/enemies/EnemyKit.gd"
## Support role art (design/enemy_art_support.html, confirmed 2026-10-08): Repair Bot, Rally Beacon, Bulwark and Mender
## Hulk. White chevrons, glowing nodes and visible fields.
##
## State (from EnemyArt.state): "heal" and "grant" are seconds since the Repair Bot healed or the Bulwark handed out
## barriers; "regen" 0..1 while the Mender Hulk regenerates. Without them the page's own clocks run.

const REPAIR := {"hull": Color(0.45, 0.8, 0.6), "panel": Color(0.93, 0.95, 0.93), "dark": Color(0.2, 0.32, 0.27), "glow": Color(0.35, 1, 0.55)}
const RALLY := {"hull": Color(0.5, 0.32, 0.74), "panel": Color(0.74, 0.62, 0.9), "dark": Color(0.27, 0.17, 0.4), "glow": Color(1, 0.82, 0.3)}
const BULWARK := {"hull": Color(0.88, 0.85, 0.76), "panel": Color(0.97, 0.95, 0.88), "dark": Color(0.48, 0.46, 0.4), "glow": Color(0.55, 0.8, 1)}
const MENDER := {"hull": Color(0.1, 0.4, 0.31), "panel": Color(0.16, 0.55, 0.42), "dark": Color(0.05, 0.2, 0.16), "trim": Color(0.86, 0.7, 0.3), "glow": Color(0.4, 1, 0.62)}


static func chevrons(c: Vector2, x: float, h: float, r: float, col := Color(0.95, 0.96, 0.95)) -> void:
	for dx in [0.0, -0.16]:
		var p := c + Vector2((x + dx) * r, 0)
		var pts := PackedVector2Array([p + Vector2(-r * 0.08, -h * r), p + Vector2(r * 0.06, 0), p + Vector2(-r * 0.08, h * r)])
		polyline(pts, OUTLINE, 2.2)
		polyline(pts, col, 1.1)


static func node(p: Vector2, rr: float, t: float, col: Color) -> void:
	disc(p, rr + 0.7, OUTLINE)
	disc(p, rr, METAL_L)
	ring(p, rr * 0.65, al(col, 0.7), 0.7)
	glow_dot(p, rr * 0.35, al(col, blink(t, 1.5)))


## A running light bar: one lamp of `n` lit at a time.
static func lights(p: Vector2, n: int, w: float, t: float, col: Color) -> void:
	for i in n:
		var y := -w + 2.0 * w * float(i) / float(n - 1)
		var on := floori(fposmod(t * 4.0, float(n))) == i
		disc(p + Vector2(0, y), 1.0, OUTLINE)
		disc(p + Vector2(0, y), 0.7, col if on else al(col, 0.3))


static func hex_pulse(c: Vector2, r0: float, r1: float, u: float, col: Color) -> void:
	if u < 0.0 or u > 1.0:
		return
	var rr := r0 + (r1 - r0) * (1.0 - (1.0 - u) * (1.0 - u))
	fill(c, ngon(6, 1.0, PI / 6.0), al(col, 0.1 * (1.0 - u)), 0.0, rr)
	outline(c, ngon(6, 1.0, PI / 6.0), al(col, 0.7 * (1.0 - u)), 1.1, 0.0, rr)


static func sparks(p: Vector2, t: float, col: Color, rr: float) -> void:
	var k := floori(t * 12.0)
	for i in 3:
		var a := hsh(float(k * 3 + i)) * TAU
		var l := rr * (0.4 + hsh(float(k * 7 + i)))
		line(p, p + fa(a) * l, al(col, 0.9), 0.6)


static func regen_motes(c: Vector2, r: float, t: float, k: float, col: Color) -> void:
	if k <= 0.0:
		return
	for i in 6:
		var u := fposmod(t * 0.8 + float(i) / 6.0, 1.0)
		var a := float(i) * 1.05 + t * 0.3
		disc(c + fa(a) * r * (1.1 - 0.7 * u), 0.9, al(col, k * 0.8 * sin(u * PI)))


## Repair Bot, look B Nano-sprayer walker: a heal pulse rings out each time it heals.
static func repair(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := REPAIR
	var sw := sin(t * 6.0)
	pulse(c, r * 0.6, r * 2.6, float(st.get("heal", fposmod(t, 2.0))) / 0.9, C.glow)
	for s in [-1.0, 1.0]:
		foot(c + Vector2(r * 0.3 * sw * s, s * r * 0.36), C.dark, r)
	var nz := c + Vector2(r * 0.85, r * 0.3)
	bar(c + Vector2(r * 0.15, r * 0.3), nz, 1.3, METAL_L)
	disc(nz, 1.4, OUTLINE)
	disc(nz, 1.0, C.panel)
	for i in 6:
		var u := fposmod(t * 0.9 + float(i) / 6.0, 1.0)
		disc(nz + Vector2(u * r * 1.1, sin(float(i) * 2.3) * u * r * 0.55), 0.8 + u * 1.6, al(C.glow, 0.45 * (1.0 - u)))
	plate(c, ngon(8, 0.5, PI / 8.0), C.hull, 0.0, r, 0.9)
	chevrons(c, 0.3, 0.2, r)
	var tk := c + Vector2(-r * 0.48, 0)
	disc(tk, r * 0.32, OUTLINE)
	disc(tk, r * 0.28, C.panel)
	ring(tk, r * 0.18, C.dark, 0.7)
	line(tk, tk + fa(t * 0.7) * r * 0.15, INK, 0.6)
	node(c + Vector2(r * 0.05, -r * 0.22), r * 0.11, t, C.glow)
	slit(c + Vector2(r * 0.4, 0), r * 0.14, C.glow, 2.4, 1.2)


## Rally Beacon, look A Banner walker.
static func rally(c: Vector2, t: float, r: float, _st: Dictionary) -> void:
	var C := RALLY
	arc_segments(c, r * 2.2, 10, 0.25, t * 0.8, al(C.glow, 0.35), 0.9)
	for q in [[1.0, 1.0, 0.0], [1.0, -1.0, PI], [-1.0, 1.0, PI], [-1.0, -1.0, 0.0]]:
		var sw := sin(t * 5.0 + q[2])
		var hip: Vector2 = c + Vector2(q[0] * r * 0.32, q[1] * r * 0.3)
		var ft: Vector2 = c + Vector2(q[0] * r * 0.5 + sw * r * 0.12, q[1] * r * 0.62)
		limb(PackedVector2Array([hip, ft]), 1.5, C.dark)
		disc(ft, 1.3, OUTLINE)
	plate(c, rect_pts(0.48, 0.4), C.hull, 0.0, r, 0.9)
	plate(c, rect_pts(0.3, 0.24), C.panel, 0.0, r, 0.6)
	chevrons(c, 0.36, 0.2, r, Color(1, 0.9, 0.6))
	var m := c + Vector2(r * 0.05, 0)
	var pts := PackedVector2Array([m])
	for i in range(1, 7):
		pts.append(m + Vector2(-float(i) * 0.2 * r, (sin(t * 6.0 - float(i) * 0.9) * 0.08 * float(i) - 0.05) * r))
	var back := PackedVector2Array()
	for i in range(pts.size() - 1, -1, -1):
		back.append(pts[i] + Vector2(0, r * 0.38))
	poly(pts + back, al(C.glow, 0.45))
	polyline(pts, al(C.glow, 0.9), 0.8)
	polyline(back, al(C.glow, 0.9), 0.8)
	node(m, r * 0.12, t, C.glow)
	lights(c + Vector2(-r * 0.42, 0), 3, r * 0.2, t, C.glow)


## Bulwark, look C Shield-wing bot: its wings open as it hands out barriers.
static func bulwark(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := BULWARK
	var u: float = st.get("grant", fposmod(t, 6.0))
	var open := u / 0.4 if u < 0.4 else (1.0 if u < 1.6 else (1.0 - (u - 1.6) / 0.6 if u < 2.2 else 0.0))
	var sw := sin(t * 4.0)
	hex_pulse(c, r * 0.7, r * 2.5, u / 1.4, C.glow)
	for s in [-1.0, 1.0]:
		foot(c + Vector2(r * 0.32 * sw * s, s * r * 0.3), C.dark, r)
	for s in [-1.0, 1.0]:
		var a0: float = s * (2.3 - 1.1 * open)
		var pts := arc_pts2(-0.05, 0.62, 0.86, a0 - 0.55 * s, a0 + 0.55 * s)
		fill(c, pts, al(C.glow, 0.25 + 0.3 * open), 0.0, r)
		outline(c, pts, al(C.glow, 0.9), 0.9, 0.0, r)
	plate(c, P([[0.4, 0], [0.24, 0.36], [-0.36, 0.36], [-0.48, 0], [-0.36, -0.36], [0.24, -0.36]]), C.hull, 0.0, r, 1.0)
	chevrons(c, 0.22, 0.18, r, C.dark)
	slit(c + Vector2(r * 0.32, 0), r * 0.14, C.glow, 2.4, 1.2)
	node(c + Vector2(-r * 0.18, 0), r * 0.13, t, C.glow)


## Mender Hulk, look B Repair-arm crawler: its arms spin up and sparks fly while it regenerates.
static func mender(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := MENDER
	var u := fposmod(t, 4.0)
	var k: float = st.get("regen", 0.0 if u < 1.5 else minf(1.0, (u - 1.5) / 0.4))
	for i in 3:
		for s in [-1.0, 1.0]:
			var ph := t * 3.5 + float(i) * 2.1 + (PI if s > 0.0 else 0.0)
			var root := c + Vector2(r * (0.3 - float(i) * 0.36), s * r * 0.42)
			var sw := sin(ph)
			var ft := root + Vector2(r * (-0.06 + 0.16 * sw), s * r * 0.62)
			limb(PackedVector2Array([root, root + Vector2(r * (0.16 + 0.08 * sw), s * r * 0.36), ft]), 1.8, C.dark)
			disc(ft, 1.5, OUTLINE)
	var body := P([[0.62, 0], [0.42, 0.48], [-0.5, 0.5], [-0.72, 0], [-0.5, -0.5], [0.42, -0.48]])
	plate(c, body, C.hull, 0.0, r, 1.0)
	rivets(c, body, 0.0, r, 0.8, 0.7)
	outline(c, body, al(C.glow, 0.1 + 0.7 * k), 0.8, 0.0, r * 0.62)
	plate(c + Vector2(-r * 0.1, 0), rect_pts(0.3, 0.2), C.panel, 0.0, r, 0.6)
	for q in [[0.25, 0.25, 0.0], [0.25, -0.25, 1.7], [-0.35, 0.25, 3.1], [-0.35, -0.25, 4.4]]:
		var b: Vector2 = c + Vector2(q[0] * r, q[1] * r)
		var tip: Vector2 = b + fa(q[2] + t * (0.8 + 1.6 * k)) * r * 0.22
		disc(b, 1.4, C.trim)
		limb(PackedVector2Array([b, tip]), 0.8, C.trim)
		if k > 0.0:
			glow_dot(tip, 0.7 * k, C.glow)
			sparks(tip, t + q[2], al(C.glow, k), r * 0.15)
	regen_motes(c, r, t, k, C.glow)
	slit(c + Vector2(r * 0.52, 0), r * 0.16, C.glow, 2.4, 1.2)
