extends "res://scripts/view/enemies/EnemyKit.gd"
## Tank role art (design/enemy_art_tank.html, confirmed 2026-10-07): Siege Mech, Rampart, Gunship and Titan. Riveted
## slab armour, visor slits and exhaust stacks.
##
## State (from EnemyArt.state): "shed" 0..1 as the Titan's plates come away (it sheds at half health).

const SIEGE := {"hull": Color(0.86, 0.68, 0.16), "dark": Color(0.42, 0.34, 0.12), "steel": Color(0.3, 0.31, 0.33), "glow": Color(1, 0.45, 0.15)}
const RAMPART := {"hull": Color(0.58, 0.58, 0.55), "dark": Color(0.36, 0.36, 0.34), "steel": Color(0.27, 0.27, 0.27), "glow": Color(1, 0.7, 0.2)}
const GUNSHIP := {"hull": Color(0.22, 0.27, 0.42), "dark": Color(0.13, 0.16, 0.26), "trim": Color(0.55, 0.6, 0.7), "glow": Color(1, 0.25, 0.2), "jet": Color(0.55, 0.8, 1)}
const TITAN := {"plate": Color(0.7, 0.5, 0.27), "frame": Color(0.15, 0.16, 0.19), "glow": Color(0.35, 0.95, 1)}


static func visor(p: Vector2, w: float, col: Color, t: float) -> void:
	slit(p, w, col, 2.6, 1.4)
	disc(p + Vector2(0, w * 0.8 * sin(t * 2.2)), 0.7, Color(1, 1, 1, 0.85))


## An exhaust stack puffing smoke back over the hull.
static func stack(p: Vector2, rr: float, t: float) -> void:
	for i in 3:
		var u := fposmod(t * 0.7 + float(i) / 3.0, 1.0)
		disc(p + Vector2(-u * rr * 7.0, -u * rr * 2.5), rr * (0.7 + u * 1.6), Color(0.55, 0.55, 0.57, 0.28 * (1.0 - u)))
	disc(p, rr + 0.6, OUTLINE)
	disc(p, rr, METAL_L)
	disc(p, rr * 0.55, INK)


static func duct(p: Vector2, rr: float, t: float, spd: float, col: Color) -> void:
	rotor(p, rr, t, spd, 3)
	ring(p, rr, OUTLINE, 2.4)
	ring(p, rr, col, 1.3)


## Siege Mech, look H Cannon-shoulder mech. `small` drops the arm's claw and the smoke (the Colossus's drop-offs).
static func siege(c: Vector2, t: float, r: float, _st: Dictionary, small := false) -> void:
	var C := SIEGE
	var st := sin(t * 4.0)
	for s in [-1.0, 1.0]:
		foot(c + Vector2(r * 0.4 * st * s, s * r * 0.28), C.steel, r, 0.24, 0.14)
	var sh := c + Vector2(r * 0.05, -r * 0.55)
	var wr := c + Vector2(r * (0.62 + 0.06 * st), -r * 0.62)
	bar(sh, wr, 2.0 if small else 2.6, C.dark)
	if not small:
		var op := 0.3 + 0.15 * sin(t * 3.0)
		for s in [-1.0, 1.0]:
			limb(PackedVector2Array([wr, wr + Vector2(r * 0.2, s * r * op * 0.5), wr + Vector2(r * 0.36, s * r * op * 0.15)]), 1.2, C.steel)
	var torso := P([[0.35, -0.5], [0.35, 0.5], [-0.35, 0.55], [-0.45, 0], [-0.35, -0.55]])
	plate(c, torso, C.hull, 0.0, r, 0.8 if small else 1.0)
	if not small:
		rivets(c, torso, 0.0, r, 0.8, 0.6)
	var cy := r * 0.5
	if not small:
		plate(c + Vector2(-r * 0.08, cy), rect_pts(0.3, 0.2), C.dark, 0.0, r, 0.8)
	bar(c + Vector2(r * 0.1, cy), c + Vector2(r * 1.25, cy), 2.0 if small else 2.6, C.steel)
	if not small:
		plate(c + Vector2(r * 1.22, cy), rect_pts(0.07, 0.11), C.steel, 0.0, r, 0.6)
	plate(c + Vector2(r * 0.1, -r * 0.05), rect_pts(0.17, 0.17), C.dark, 0.0, r, 0.6 if small else 0.7)
	if small:
		slit(c + Vector2(r * 0.22, -r * 0.05), r * 0.12, C.glow, 2.6, 1.4)
	else:
		visor(c + Vector2(r * 0.22, -r * 0.05), r * 0.12, C.glow, t)
		stack(c + Vector2(-r * 0.3, -r * 0.3), r * 0.07, t)


## Rampart, look B Bastion crawler.
static func rampart(c: Vector2, t: float, r: float, _st: Dictionary) -> void:
	var C := RAMPART
	for s in [-1.0, 1.0]:
		tread(c + Vector2(0, s * r * 0.7), r * 0.75, r * 0.2, t)
	plate(c, ngon(6, 0.74, 0.0), C.hull, 0.0, r, 1.1)
	outline(c, ngon(6, 0.5, 0.0), C.dark, 0.9, 0.0, r)
	for i in [1, 2, 4, 5]:
		var p := c + fa(float(i) * PI / 3.0) * r * 0.72
		disc(p, r * 0.19, OUTLINE)
		disc(p, r * 0.17, lt(C.hull, 0.12))
		disc(p, r * 0.07, C.dark)
	plate(c, rect_pts(0.22, 0.22), C.dark, 0.0, r, 0.8)
	glow_dot(c, 1.6, al(C.glow, blink(t, 0.9)))
	visor(c + Vector2(r * 0.6, 0), r * 0.16, C.glow, t)
	stack(c + Vector2(-r * 0.5, 0), r * 0.08, t)


## Gunship, look A Armoured quad-rotor.
static func gunship(c: Vector2, t: float, r: float, _st: Dictionary) -> void:
	var C := GUNSHIP
	for q in [[0.72, 0.72], [0.72, -0.72], [-0.72, 0.72], [-0.72, -0.72]]:
		var p: Vector2 = c + Vector2(q[0] * r, q[1] * r)
		bar(c, p, 2.0, C.dark)
		duct(p, r * 0.38, t, 38.0 * signf(q[0] * q[1]), C.trim)
	for s in [-1.0, 1.0]:
		bar(c + Vector2(r * 0.1, s * r * 0.42), c + Vector2(r * 0.9, s * r * 0.42), 1.4, METAL_L)
		plate(c + Vector2(r * 0.15, s * r * 0.42), rect_pts(0.22, 0.1), C.dark, 0.0, r, 0.6)
	var body := P([[0.55, 0], [0.38, 0.32], [-0.45, 0.32], [-0.58, 0], [-0.45, -0.32], [0.38, -0.32]])
	plate(c, body, C.hull, 0.0, r, 1.0)
	rivets(c, body, 0.0, r, 0.75, 0.6)
	visor(c + Vector2(r * 0.38, 0), r * 0.16, Color(0.6, 0.9, 1), t)
	for s in [-1.0, 1.0]:
		glow_dot(c + Vector2(-r * 0.5, s * r * 0.26), 1.1, al(C.glow, blink(t, 1.1, 0.5 if s > 0.0 else 0.0)))


## Titan, look A Colossus walker: amber plates over a dark frame that come away at half health.
static func titan(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := TITAN
	var u := fposmod(t, 8.0)
	var k: float = st.get("shed", 0.0 if u < 5.0 else minf(1.0, u - 5.0))
	var sw := sin(t * 2.2)
	for s in [-1.0, 1.0]:
		var ph: float = sw * s
		var hip := c + Vector2(-r * 0.2, s * r * 0.42)
		var ft := c + Vector2(r * (-0.1 + 0.3 * ph), s * r * 0.82)
		limb(PackedVector2Array([hip, hip + Vector2(r * 0.1 * ph, s * r * 0.22), ft]), 3.0, C.frame)
		foot(ft, C.frame, r, 0.26, 0.16)
	for s in [-1.0, 1.0]:
		var sh := c + Vector2(r * 0.05, s * r * 0.5)
		var fist := c + Vector2(r * (0.62 - 0.08 * sw * s), s * r * 0.66)
		bar(sh, fist, 3.2, C.frame)
		disc(fist, r * 0.13, OUTLINE)
		disc(fist, r * 0.11, lt(C.frame, 0.12))
	var body := P([[0.46, 0], [0.3, 0.5], [-0.42, 0.5], [-0.58, 0], [-0.42, -0.5], [0.3, -0.5]])
	plate(c, body, C.frame, 0.0, r, 1.0)
	outline(c, body, al(C.glow, 0.5 + 0.45 * k), 0.8, 0.0, r * 0.8)
	for s in [-1.0, 1.0]:
		line(c + Vector2(-r * 0.35, s * r * 0.2), c + Vector2(r * 0.25, s * r * 0.2), al(C.glow, 0.45 + 0.5 * k), 0.8)
	glow_dot(c + Vector2(-r * 0.1, 0), r * (0.1 + 0.06 * k), C.glow)
	for s in [-1.0, 1.0]:
		shed_plate(c, P([[0.24, s * 0.3], [0.2, s * 0.74], [-0.3, s * 0.76], [-0.4, s * 0.3]]), Vector2(0.2, s), k, C.plate, r)
	shed_plate(c, P([[0.5, 0], [0.34, 0.2], [0.04, 0.2], [0.04, -0.2], [0.34, -0.2]]), Vector2(1, -0.3), k, C.plate, r)
	shed_plate(c, P([[-0.18, 0.22], [-0.18, -0.22], [-0.5, -0.18], [-0.6, 0], [-0.5, 0.18]]), Vector2(-1, 0.3), k, C.plate, r)
	visor(c + Vector2(r * 0.4, 0), r * 0.12, C.glow, t)
