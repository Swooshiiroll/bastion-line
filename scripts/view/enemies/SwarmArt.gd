extends "res://scripts/view/enemies/EnemyKit.gd"
## Swarm role art (design/enemy_art_swarm.html, confirmed 2026-10-07): Nanite, Locust, Drone and Shrike. Stamped-metal
## hulls, one round sensor eye and a hive-link fin with a blinking tip.

const NANITE := {"hull": Color(0.68, 0.48, 0.32), "dark": Color(0.46, 0.32, 0.22), "eye": Color(1, 0.72, 0.25)}
const LOCUST := {"hull": Color(0.44, 0.5, 0.26), "dark": Color(0.28, 0.32, 0.16), "eye": Color(1, 0.92, 0.3)}
const DRONE := {"hull": Color(0.3, 0.38, 0.52), "dark": Color(0.18, 0.23, 0.33), "eye": Color(0.95, 0.97, 1)}
const SHRIKE := {"hull": Color(0.9, 0.9, 0.92), "dark": Color(0.62, 0.64, 0.7), "eye": Color(0.35, 0.95, 1)}


## Nanite, look A Assembly hub: a mother unit whose bots orbit and dock.
static func nanite(c: Vector2, t: float, r: float, _st: Dictionary) -> void:
	var C := NANITE
	var dock := 0.5 + 0.5 * sin(t * 1.2)
	for k in 4:
		var a := t * 2.0 + float(k) * TAU / 4.0
		var p := c + fa(a) * r * (0.6 + 0.55 * dock)
		plate(p, rect_pts(0.5, 0.5), C.hull, a, r * 0.4, 0.6)
		disc(p, r * 0.08, C.eye)
	plate(c, ngon(6, 1.0, PI / 6.0), C.dark, 0.0, r * 0.68, 0.9)
	rivets(c, ngon(6, 1.0, PI / 6.0), 0.0, r * 0.68, 0.75, 0.45)
	line(c + Vector2(-r * 0.3, 0), c + Vector2(r * 0.3, 0), Color(0.6, 0.45, 0.32), 0.5)
	eye(c + Vector2(r * 0.15, 0), r * 0.2, C.eye)
	fin(c + Vector2(-r * 0.4, 0), PI, r * 0.45, t, C.eye)


## Locust, look F Cutter-wing flyer: serrated cutter wings and a tail rotor.
static func locust(c: Vector2, t: float, r: float, _st: Dictionary) -> void:
	var C := LOCUST
	var sweep := 0.9 + 0.1 * sin(t * 5.0)
	for s2 in [-1.0, 1.0]:
		var w := P([[0.3, s2 * 0.15], [-0.15, s2 * 1.1 * sweep], [-0.45, s2 * 1.05 * sweep], [-0.3, s2 * 0.15]])
		plate(c, w, C.hull, 0.0, r, 0.7)
		var q := xform(c, w, 0.0, r)
		for k in 5:
			var u := float(k) / 5.0
			var e := q[0] + (q[1] - q[0]) * (u + 0.1)
			var d := (q[1] - q[0]).normalized()
			poly(PackedVector2Array([e, e + d * r * 0.12, e + d.rotated(-s2 * 1.57) * r * 0.1]), Color(0.8, 0.82, 0.86))
	plate(c, P([[0.7, 0], [0.35, 0.2], [-0.8, 0.14], [-0.8, -0.14], [0.35, -0.2]]), C.dark, 0.0, r, 0.7)
	rotor(c + Vector2(-r * 0.9, 0), r * 0.32, t, 60.0)
	eye(c + Vector2(r * 0.4, 0), r * 0.11, C.eye)
	fin(c + Vector2(-r * 0.45, 0), PI / 2.0, r * 0.28, t, C.eye)
	stencil(c + Vector2(-r * 0.1, 0), 0.0, r * 0.16)


## Drone, look B Sentry walker: four legs and a turret. `eye_col` lets the Masquerade wear it with a purple eye.
static func drone(c: Vector2, t: float, r: float, _st: Dictionary, eye_col := Color(0.95, 0.97, 1), with_fin := true) -> void:
	var C := DRONE
	for k in 4:
		var d := fa(PI / 4.0 + float(k) * PI / 2.0)
		var step := sin(t * 7.0 + float(k) * PI / 2.0) * r * 0.12
		var knee := c + d * r * 0.65 + Vector2(step, 0)
		limb(PackedVector2Array([c + d * r * 0.3, knee, knee + d * r * 0.3]), 1.8, C.dark)
	plate(c, rect_pts(0.5, 0.5), C.hull, 0.0, r, 1.0)
	rivets(c, rect_pts(0.5, 0.5), 0.0, r, 0.78, 0.5)
	stencil(c + Vector2(-r * 0.3, r * 0.3), 0.0, r * 0.18)
	var aim := 0.35 * sin(t * 0.9)
	orb(c, r * 0.28, C.dark)
	bar(c, c + fa(aim) * r * 0.85, 1.6, METAL_L)
	eye(c + fa(aim) * r * 0.15, r * 0.1, eye_col)
	if with_fin:
		fin(c + Vector2(-r * 0.45, 0), PI, r * 0.3, t, eye_col)


## Shrike, look C Lancer squadron: a forward-swept lance drone (each of the five flies as its own enemy).
static func shrike(c: Vector2, _t: float, r: float, _st: Dictionary) -> void:
	var C := SHRIKE
	for s in [-1.0, 1.0]:
		fill(c, P([[-0.45, s * 0.12], [0.15, s * 0.85], [0.0, s * 0.9], [-0.65, s * 0.15]]), C.hull, 0.0, r)
	plate(c, P([[0.8, 0], [0.4, 0.15], [-0.75, 0.15], [-0.75, -0.15], [0.4, -0.15]]), C.hull, 0.0, r, 0.6)
	line(c + Vector2(r * 0.8, 0), c + Vector2(r * 1.45, 0), Color(0.75, 0.78, 0.82), 0.8)
	line(c + Vector2(r * 0.6, 0), c + Vector2(-r * 0.6, 0), al(C.eye, 0.8), 0.5)
	for s in [-1.0, 1.0]:
		glow_dot(c + Vector2(-r * 0.8, s * r * 0.1), r * 0.09, C.eye)
	eye(c + Vector2(r * 0.45, 0), r * 0.08, C.eye)
