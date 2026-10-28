extends RefCounted
## Gun Turret art (tower rework, issue #59): a faithful port of the confirmed second-pass page
## (design/tower_art_p2_01_gun.html, tools/tower_art/data_p2_gun.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c" (Tower.look_key): the Retrofit (-1 none, 0 water jacket, 1 coil wraps,
## 2 fuel canister) and the depth of each path, 5 on the path that took its mastery. a = Power, b = Range, c = Multi-Target.
## Everything that moves (the spinning barrels, the extra guns, flashes, vapour, gears) is drawn between Draw.dyn
## calls so the rest bakes into the turret sprite cache.

const Draw = preload("res://scripts/view/Draw.gd")

const STEEL := Color(0.42, 0.45, 0.50)
const GOLD := Color(1.0, 0.78, 0.30)
const RED_TIP := Color(1.0, 0.30, 0.25)
const SHOCK := Color(0.60, 0.85, 1.0)
const FIRE := Color(1.0, 0.55, 0.20)
const WATER := Color(0.30, 0.42, 0.50)
const BORE := Color(0.05, 0.05, 0.06)
const CANISTER := Color(0.70, 0.18, 0.12)
const FUEL_LINE := Color(0.50, 0.20, 0.12)


## Levels from a look key: {r, P, R, M}.
static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "P": 0, "R": 0, "M": 0}
	return {"r": int(p[0]), "P": int(p[1]), "R": int(p[2]), "M": int(p[3])}


static func main_len(R: int) -> float:
	return 24.0 if R >= 1 else 19.0


static func extra_len(R: int) -> float:
	return 15.0 if R >= 1 else 11.0


static func guns(M: int) -> int:
	return 3 if M >= 5 else (2 if M >= 2 else 1)


## An extra gun's mount, on the main turret's flanks (x along the aim, y to the side).
static func mount(i: int) -> Vector2:
	return Vector2(1.0, -10.5 if i == 1 else 10.5)


## Where game px (x along the aim, y to the side) lands around c; y points 90 degrees clockwise of the aim, as in the page.
static func at(c: Vector2, aim: float, k: float, x: float, y: float) -> Vector2:
	var d := Vector2.from_angle(aim)
	return c + (d * x + Vector2(-d.y, d.x) * y) * k


static func hazard(ci: CanvasItem, c: Vector2, aim: float, k: float, x0: float, x1: float, y: float, col: Color, w: float) -> void:
	var n := maxi(2, roundi(x1 - x0))
	for i in n:
		var xa := x0 + (x1 - x0) * float(i) / float(n)
		var xb := x0 + (x1 - x0) * float(i + 1) / float(n)
		Draw.line(ci, at(c, aim, k, xa, y), at(c, aim, k, xb, y), col if i % 2 == 0 else Color(0.06, 0.06, 0.07), w * k)


static func gear(ci: CanvasItem, p: Vector2, r: float, k: float, spin: float, teeth: int) -> void:
	var pts := PackedVector2Array()
	for i in teeth * 2:
		var a := spin + float(i) * PI / float(teeth)
		pts.append(Vector2.from_angle(a) * (r * 0.78 if i % 2 == 1 else r))
	Draw.solid(ci, p, pts, Draw.METAL_L, 0.0, k, 0.8)
	Draw.disc(ci, p, r * 0.35 * k, Draw.METAL_D)


## The spinning rotary cluster: n barrels from x0 to x1 at radius `rad`; fluted from Range 3. Drawn live.
static func cluster(ci: CanvasItem, c0: Vector2, a: float, k: float, flash: float, t: float, x0: float, x1: float, rad: float, w: float, n: int, ring_col: Color, R: int) -> void:
	var rc := clampf(flash / 0.12, 0.0, 1.0) * 1.5
	var sp := t * (30.0 if flash > 0.0 else 3.0)
	var bs: Array = []
	for i in n:
		bs.append({"y": sin(sp + float(i) * TAU / float(n)) * rad, "z": cos(sp + float(i) * TAU / float(n))})
	bs.sort_custom(func(p, q): return p.z < q.z)
	for b in bs:
		Draw.bar(ci, at(c0, a, k, x0 - rc, b.y), at(c0, a, k, x1 - rc, b.y), w * k, Draw.METAL_D.lerp(Draw.METAL_L, 0.5 + 0.5 * float(b.z)))
		if R >= 3 and b.z > 0.0:
			var x := x0 + 4.0
			while x <= x1 - 2.0:
				Draw.line(ci, at(c0, a, k, x - rc, b.y - w * 0.3), at(c0, a, k, x + 0.9 - rc, b.y + w * 0.3), Draw.METAL_L.lightened(0.35), 0.6 * k)
				x += 1.8
	for x in [x0 + 3.0, x1 - 1.0]:
		Draw.bar(ci, at(c0, a, k, x - rc, -rad - 1.4), at(c0, a, k, x - rc, rad + 1.4), 1.5 * k, ring_col)
	for b in bs:
		Draw.disc(ci, at(c0, a, k, x1 - rc, b.y), w * 0.32 * k, Color(BORE, 0.55 + 0.45 * maxf(0.0, float(b.z))))
	flash_tip(ci, at(c0, a, k, x1 - rc, bs[bs.size() - 1].y), k, w, flash)


static func flash_tip(ci: CanvasItem, p: Vector2, k: float, w: float, flash: float) -> void:
	var f := maxf(0.0, (clampf(flash / 0.12, 0.0, 1.0) - 0.35) / 0.65)
	if f > 0.0:
		Draw.disc(ci, p, w * 0.45 * k, Color(1, 0.92, 0.7, f))
		Draw.disc(ci, p, w * 1.2 * k * f, Color(1, 0.95, 0.8, 0.3 * f))


## What's on every gun's barrels: the Retrofit sleeve (water jacket or shock coils), then Power's marked shroud.
static func barrel_kit(ci: CanvasItem, c0: Vector2, a: float, k: float, flash: float, t: float, x0: float, x1: float, half: float, L: Dictionary, gold: bool, col: Color) -> void:
	var rc := clampf(flash / 0.12, 0.0, 1.0) * 1.5
	if L.r == 0:
		Draw.plate(ci, at(c0, a, k, (x0 + x1) / 2.0 - rc, 0.0), Draw.rect_pts((x1 - x0) / 2.0, half + 0.8), WATER, a, k, 1.0)
	if L.r == 1:
		var x := x0
		while x <= x1:
			Draw.line(ci, at(c0, a, k, x - rc, -half - 1.0), at(c0, a, k, x + 0.7 - rc, half + 1.0), Color(0.35, 0.45, 0.6), 1.0 * k)
			x += 1.5
		Draw.glow_dot(ci, at(c0, a, k, (x0 + x1) / 2.0 - rc, 0.0), 0.7 * k, Color(SHOCK, 0.5 + 0.5 * sin(t * 9.0)))
	if L.P >= 2:
		var mc: Color = GOLD if gold else col
		for dx in [0.0, 1.4]:
			Draw.line(ci, at(c0, a, k, x1 + 2.0 - dx - rc, -half - 1.4), at(c0, a, k, x1 + 2.0 - dx - rc, half + 1.4), Color(mc, 0.95), 1.0 * k)


static func vapour(ci: CanvasItem, p: Vector2, flash: float, s: float) -> void:
	var f := clampf(flash / 0.12, 0.0, 1.0)
	if f > 0.6:
		Draw.disc(ci, p + Vector2(0, -s * 2.4), s * (2.0 + 3.0 * (1.0 - f)), Color(0.85, 0.9, 0.95, 0.35 * f))


## The whole tower. `extra` is the smoothed aim of each extra gun (index 1, 2); a missing one follows the main gun.
static func draw(ci: CanvasItem, c: Vector2, aim: float, s: float, t: float, flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s
	var rc := clampf(flash / 0.12, 0.0, 1.0) * 1.5
	var length := main_len(L.R)
	var n := guns(L.M)
	var gold: bool = L.P >= 5 or L.M >= 5
	var drum := at(c, aim, k, -7.0, 6.0) if L.M >= 5 else at(c, aim, k, -1.0, 8.5)
	var ex: Array = [0.0]
	for i in range(1, n):
		ex.append(float(extra[i]) if (i < extra.size() and extra[i] != null) else aim)
	# Under the turret: Multi-Target 1's geared swivel ring.
	if L.M >= 1:
		Draw.ring(ci, c, 9.5 * k, Draw.OUTLINE, 2.6 * k)
		Draw.ring(ci, c, 9.5 * k, Draw.METAL_L, 1.6 * k)
		for i in 16:
			var d2 := Vector2.from_angle(float(i) * TAU / 16.0 + aim)
			Draw.line(ci, c + d2 * 9.5 * k, c + d2 * 11.0 * k, Draw.METAL_L, 1.0 * k)
	# The back: the vent block, Power 4's counterweight.
	Draw.plate(ci, at(c, aim, k, -8.0, 0.0), Draw.rect_pts(3.0, 5.5), Draw.METAL_D.lightened(0.1), aim, k, 1.0)
	for i in 3:
		Draw.line(ci, at(c, aim, k, -9.5 + float(i) * 1.5, -4.0), at(c, aim, k, -9.5 + float(i) * 1.5, 4.0), Color(acc, 0.5 + (0.4 if i == 2 else 0.0)), 0.9 * k)
	if L.P >= 4:
		Draw.plate(ci, at(c, aim, k, -11.5, 0.0), Draw.rect_pts(2.4, 6.4), STEEL, aim, k, 1.1)
		hazard(ci, c, aim, k, -13.0, -10.0, 6.8, acc, 1.2)
		hazard(ci, c, aim, k, -13.0, -10.0, -6.8, acc, 1.2)
	# The main gun: barrels swapped longer at Range 1, fluted at Range 3, the Retrofit sleeve, the marked shroud.
	Draw.dyn(true)
	cluster(ci, c, aim, k, flash, t, 5.0, length, 3.4, 1.8, 4, GOLD if L.M >= 5 else Draw.METAL_L, L.R)
	barrel_kit(ci, c, aim, k, flash, t, 9.0, length - 3.0, 3.4, L, gold, acc)
	if L.r == 0:
		vapour(ci, at(c, aim, k, length + 1.0, 0.0), flash, k)
	if L.P >= 1:
		Draw.plate(ci, at(c, aim, k, 4.5 - rc, 0.0), Draw.rect_pts(2.2, 5.4), STEEL, aim, k, 1.0)
		Draw.rivets(ci, at(c, aim, k, 4.5 - rc, 0.0), Draw.rect_pts(2.2, 5.4), aim, k, 0.7, 0.6 * k)
	Draw.dyn(false)
	# The drum (a red ring from Range 2's tracers), the body, its cheeks, the lens crown, the gold mastery ring.
	Draw.orb(ci, drum, 4.2 * k, Draw.METAL, k)
	Draw.ring(ci, drum, 2.8 * k, RED_TIP if L.R >= 2 else Color(acc, 0.7), 1.2 * k)
	Draw.plate(ci, c, Draw.ngon(6, 1.0, 0.0), Draw.METAL_L, aim, 6.8 * k, 1.2)
	Draw.orb(ci, c, 3.6 * k, Draw.METAL, k)
	Draw.glow_dot(ci, at(c, aim, k, 1.2, 0.0), 1.2 * k, acc)
	if L.P >= 3:
		for sg in [-1.0, 1.0]:
			Draw.plate(ci, at(c, aim, k, 0.0, sg * 6.4), PackedVector2Array([Vector2(5, -sg * 1.2), Vector2(5, sg * 1.6), Vector2(-5, sg * 2.2), Vector2(-6, -sg * 1.0)]), STEEL, aim, k, 1.0)
	if L.R >= 5:
		Draw.plate(ci, c, Draw.ngon(6, 1.0, 0.0), Draw.METAL_L, aim, 5.6 * k, 1.0)
		Draw.outline(ci, c, Draw.ngon(6, 1.0, 0.0), GOLD, 1.2 * k, aim, 5.6 * k)
		Draw.disc(ci, c, 3.4 * k, Color(acc, 0.55))
		Draw.disc(ci, c + Draw.LIGHT * 1.2 * k, 1.2 * k, Color(1, 1, 1, 0.6))
	if L.P >= 5:
		Draw.ring(ci, c, 7.6 * k, GOLD, 1.2 * k)
		Draw.glow_dot(ci, c, 1.8 * k, Color(1.0, 0.6, 0.3))
	if L.R >= 4:
		var e := at(c, aim, k, 5.0, 5.5 if n > 1 else -5.5)
		Draw.plate(ci, e, Draw.rect_pts(1.6, 1.2), Draw.METAL, aim, k, 0.8)
		# The ranging line reaches well past the turret's cached sprite, so it's drawn live (#90).
		Draw.dyn(true)
		Draw.line(ci, e, e + Vector2.from_angle(aim) * 67.0 * s, Color(1, 0.25, 0.25, 0.25), 0.8)
		Draw.glow_dot(ci, e, 0.6 * k, Color(1.0, 0.3, 0.3))
		Draw.dyn(false)
	# Extra guns on their own swivel mounts (bodies bigger than their barrels), each with the main gun's kit.
	Draw.dyn(true)
	for i in range(1, n):
		var mp := at(c, aim, k, mount(i).x, mount(i).y)
		var a: float = ex[i]
		var el := extra_len(L.R)
		if L.M >= 3:
			cluster(ci, mp, a, k, flash, t, 1.0, el, 2.4, 1.4, 4, GOLD if L.M >= 5 else Draw.METAL_L, L.R)
		else:
			Draw.bar(ci, at(mp, a, k, 1.0 - rc, 0.0), at(mp, a, k, el - rc, 0.0), 1.8 * k, Draw.METAL_L)
			if L.R >= 3:
				var x := 4.0
				while x <= el - 2.0:
					Draw.line(ci, at(mp, a, k, x - rc, -0.6), at(mp, a, k, x + 0.9 - rc, 0.6), Draw.METAL_L.lightened(0.35), 0.5 * k)
					x += 1.8
		barrel_kit(ci, mp, a, k, flash, t, 4.0, el - 2.0, 2.4 if L.M >= 3 else 1.0, L, gold, acc)
		if L.M < 3:
			Draw.disc(ci, at(mp, a, k, el - rc, 0.0), 0.6 * k, BORE)
			flash_tip(ci, at(mp, a, k, el - rc, 0.0), k, 1.8, flash)
		Draw.plate(ci, mp, Draw.ngon(6, 1.0, 0.0), Draw.METAL_L, a, 5.0 * k, 1.1)
		Draw.orb(ci, mp, 2.6 * k, Draw.METAL, k)
		Draw.glow_dot(ci, at(mp, a, k, 1.0, 0.0), 0.8 * k, acc)
		if L.P >= 1:
			Draw.plate(ci, at(mp, a, k, 3.0, 0.0), PackedVector2Array([Vector2(0.8, -3.6), Vector2(0.8, 3.6), Vector2(-0.8, 3.0), Vector2(-0.8, -3.0)]), STEEL, a, k, 0.9)
		if L.r == 0:
			vapour(ci, at(mp, a, k, el + 1.0, 0.0), flash, k)
		if L.r == 2:
			Draw.line(ci, at(c, aim, k, -4.5, -6.0), mp, FUEL_LINE, 1.1 * k)
	if L.M >= 4:
		for y in [-5.0, 5.0]:
			gear(ci, at(c, aim, k, -5.0, y), 2.2, k, t * 6.0 * (1.0 if y > 0.0 else -1.0), 8)
		for i in range(1, n):
			var mp2 := at(c, aim, k, mount(i).x, mount(i).y)
			gear(ci, at(mp2, ex[i], k, -3.4, 0.0), 1.6, k, t * 7.0, 6)
	Draw.dyn(false)
	# The Retrofit on the body: the fuel canister and its line.
	if L.r == 2:
		Draw.bar(ci, at(c, aim, k, -7.0, -6.0), at(c, aim, k, -2.0, -6.0), 3.0 * k, CANISTER)
		Draw.line(ci, at(c, aim, k, -2.0, -6.0), at(c, aim, k, 4.0, -2.0), FUEL_LINE, 1.2 * k)


## Where a shot leaves gun `i` (0 the main gun), for tracers: the muzzle, on the top barrel of the cluster.
static func muzzle(c: Vector2, aim: float, k: float, look: String, i: int, extra: Array, t: float) -> Vector2:
	var L := levels(look)
	var n := guns(L.M)
	i = i % n
	if i == 0:
		return at(c, aim, k, main_len(L.R), top_barrel_y(t, 3.4, 4))
	var a: float = float(extra[i]) if (i < extra.size() and extra[i] != null) else aim
	return at(at(c, aim, k, mount(i).x, mount(i).y), a, k, extra_len(L.R), top_barrel_y(t, 2.4, 4) if L.M >= 3 else 0.0)


static func top_barrel_y(t: float, rad: float, n: int) -> float:
	var sp := t * 30.0
	var best := -2.0
	var y := 0.0
	for i in n:
		var z := cos(sp + float(i) * TAU / float(n))
		if z > best:
			best = z
			y = sin(sp + float(i) * TAU / float(n)) * rad
	return y
