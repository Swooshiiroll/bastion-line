extends "res://scripts/view/enemies/EnemyKit.gd"
## Rusher role art (design/enemy_art_rusher.html, confirmed 2026-10-07): Skitter, Needle, Strike Drone and Fury Drone.
## Low-slung chassis, forward-raked prows, exposed thrusters and a speed stripe along the spine.

const SKITTER := {"hull": Color(0.78, 0.72, 0.58), "dark": Color(0.5, 0.45, 0.35), "stripe": Color(0.9, 0.2, 0.18), "glow": Color(1, 0.6, 0.3)}
const NEEDLE := {"hull": Color(0.9, 0.93, 0.96), "dark": Color(0.62, 0.66, 0.72), "stripe": Color(0.2, 0.35, 0.85), "glow": Color(0.5, 0.75, 1)}
const STRIKE := {"hull": Color(0.24, 0.48, 0.48), "dark": Color(0.15, 0.3, 0.3), "stripe": Color(1, 0.55, 0.15), "glow": Color(1, 0.7, 0.35)}
const FURY := {"hull": Color(0.2, 0.12, 0.14), "dark": Color(0.12, 0.07, 0.08), "stripe": Color(0.85, 0.12, 0.2), "glow": Color(1, 0.25, 0.75)}


static func stripe(a: Vector2, b: Vector2, col: Color) -> void:
	line(a, b, OUTLINE, 2.2)
	line(a, b, col, 1.3)


static func thruster(p: Vector2, rr: float, t: float, col: Color) -> void:
	disc(p, rr + 0.6, OUTLINE)
	disc(p, rr, Color(0.2, 0.2, 0.22))
	glow_dot(p, rr * (0.65 + 0.15 * sin(t * 30.0)), col)


## Skitter, look A Six-leg scuttler. `legs` off draws the bare body (a Hydra Frame's docked Skitters).
static func skitter(c: Vector2, t: float, r: float, _st: Dictionary, legs := true) -> void:
	var C := SKITTER
	if legs:
		for i in 3:
			for s in [-1.0, 1.0]:
				var ph := t * 26.0 + float(i) * 2.1 + (PI if s > 0.0 else 0.0)
				var root := c + Vector2(r * (0.35 - float(i) * 0.35), s * r * 0.25)
				limb(PackedVector2Array([root, root + Vector2(r * 0.18 * sin(ph), s * r * 0.45), root + Vector2(r * 0.3 * sin(ph), s * r * 0.7)]), 0.8, C.dark)
	plate(c, P([[0.85, 0], [0.45, 0.3], [-0.65, 0.28], [-0.65, -0.28], [0.45, -0.3]]), C.hull, 0.0, r, 0.8)
	stripe(c + Vector2(r * 0.6, 0), c + Vector2(-r * 0.55, 0), C.stripe)
	slit(c + Vector2(r * 0.55, 0), r * 0.18, C.glow, 1.8, 1.0)
	thruster(c + Vector2(-r * 0.68, 0), r * 0.12, t, C.glow)


## Needle, look A Needle racer (each of the pair is its own enemy).
static func needle(c: Vector2, t: float, r: float, _st: Dictionary) -> void:
	var C := NEEDLE
	for s in [-1.0, 1.0]:
		fill(c, P([[-0.4, s * 0.1], [-0.8, s * 0.45], [-0.95, s * 0.4], [-0.75, s * 0.1]]), C.dark, 0.0, r)
	plate(c, P([[1.6, 0], [0.5, 0.13], [-0.9, 0.15], [-0.9, -0.15], [0.5, -0.13]]), C.hull, 0.0, r, 0.6)
	stripe(c + Vector2(r * 1.2, 0), c + Vector2(-r * 0.8, 0), C.stripe)
	thruster(c + Vector2(-r * 0.95, 0), r * 0.1, t, C.glow)


## Strike Drone, look B Twin-rotor attack drone.
static func strike_drone(c: Vector2, t: float, r: float, _st: Dictionary) -> void:
	var C := STRIKE
	for s in [-1.0, 1.0]:
		bar(c, c + Vector2(0, s * r * 0.75), 1.1, C.dark)
		rotor(c + Vector2(0, s * r * 0.75), r * 0.55, t, 40.0 * s)
	plate(c, P([[0.9, 0], [0.4, 0.3], [-0.6, 0.25], [-0.6, -0.25], [0.4, -0.3]]), C.hull, 0.0, r, 0.8)
	stripe(c + Vector2(r * 0.6, 0), c + Vector2(-r * 0.45, 0), C.stripe)
	bar(c + Vector2(r * 0.6, 0), c + Vector2(r * 1.2, 0), 1.0, METAL_L)
	slit(c + Vector2(r * 0.55, 0), r * 0.12, Color(0.6, 0.95, 1), 1.8, 1.0)
	thruster(c + Vector2(-r * 0.62, 0), r * 0.1, t, C.glow)


## Fury Drone, look C One-wheel spike bike.
static func fury(c: Vector2, t: float, r: float, _st: Dictionary) -> void:
	var C := FURY
	plate(c, rect_pts(1.05, 0.3), Color(0.14, 0.14, 0.15), 0.0, r, 0.9)
	for k in 7:
		var x := (fposmod(t * 3.0 + float(k) / 7.0, 1.0) * 2.0 - 1.0) * r
		for s in [-1.0, 1.0]:
			poly(PackedVector2Array([c + Vector2(x - r * 0.06, s * r * 0.3), c + Vector2(x, s * r * 0.48), c + Vector2(x + r * 0.06, s * r * 0.3)]), Color(0.8, 0.82, 0.86))
	plate(c, P([[0.35, 0], [0.15, 0.2], [-0.35, 0.2], [-0.35, -0.2], [0.15, -0.2]]), C.hull, 0.0, r, 0.8)
	outline(c, rect_pts(0.3, 0.16), al(C.glow, 0.7), 0.6, 0.0, r)
	slit(c + Vector2(r * 0.25, 0), r * 0.12, C.glow, 1.8, 1.0)
	stripe(c + Vector2(r * 0.1, -r * 0.12), c + Vector2(-r * 0.3, -r * 0.12), C.stripe)
	thruster(c + Vector2(-r * 0.45, 0), r * 0.09, t, C.glow)
