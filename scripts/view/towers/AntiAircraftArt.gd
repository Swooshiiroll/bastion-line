extends RefCounted
## Anti-Aircraft Turret art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_05_aa.html, tools/tower_art/data_p2_aa.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 radar dish, 1 ammo drum, 2 armoured mount) and the depth
## of each path, 5 on the path that took its mastery. a = Range, b = Power/Blast Radius, c = Speed. `extra[0]` is the index of
## the barrel that fired last (the barrels fire in turn). The turret turns with the aim; the pedestal, the spinning radars and
## gears and the muzzle flashes are live.

const Draw = preload("res://scripts/view/Draw.gd")
const Gun = preload("res://scripts/view/towers/GunTurretArt.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const STEEL := Color(0.42, 0.45, 0.50)
const BRASS := Color(0.86, 0.68, 0.32)
const DARKR := Color(0.20, 0.20, 0.22)
const AMMO := Color(0.35, 0.36, 0.30)
const ORANGE := Color(1.0, 0.55, 0.20)

# The owner's picks per step: Range, Power/Blast, Speed.
const PICKS := [["A", "A", "B", "A", "A"], ["B", "A", "A", "B", "B"], ["A", "A", "A", "B", "A"]]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "R": 0, "P": 0, "S": 0}
	return {"r": int(p[0]), "R": int(p[1]), "P": int(p[2]), "S": int(p[3])}


static func kp(L: Dictionary, pi: int, k: int) -> String:
	var d: int = [L.R, L.P, L.S][pi]
	return PICKS[pi][k] if d > k else ""


static func barrel_len(L: Dictionary) -> float:
	return 21.0 + (4.0 if L.R >= 1 else 0.0) + (4.0 if L.R >= 4 else 0.0) + (2.0 if L.R >= 5 else 0.0)


## The barrels by Speed depth: [x, y] each, and their width.
static func barrels(L: Dictionary) -> Dictionary:
	if L.S >= 5:
		return {"list": [Vector2(0, -6), Vector2(0, -2), Vector2(0, 2), Vector2(0, 6)], "w": 2.4}
	if L.S >= 3:
		return {"list": [Vector2(0, -3.2), Vector2(0, 3.2)], "w": 3.2}
	return {"list": [Vector2(0, 0)], "w": 3.6}


static func at(c: Vector2, aim: float, k: float, x: float, y: float) -> Vector2:
	return Gun.at(c, aim, k, x, y)


## Where a round leaves barrel `i`.
static func muzzle(c: Vector2, aim: float, k: float, look: String, i: int) -> Vector2:
	var L := levels(look)
	var list: Array = barrels(L).list
	var b: Vector2 = list[i % list.size()]
	return at(c, aim, k, b.x + barrel_len(L) + 0.5 + 1.6, b.y)


static func gun_barrel(ci: CanvasItem, c: Vector2, aim: float, k: float, b: Vector2, len: float, w: float, L: Dictionary, gold: bool) -> void:
	var x := b.x
	var y := b.y
	Draw.bar(ci, at(c, aim, k, x + 2.0, y), at(c, aim, k, x + len, y), w * k, Draw.METAL_L)
	var ring_col: Color = Draw.METAL_L.lightened(0.1) if L.S >= 1 else Draw.METAL_L
	for xx in [6.0, 8.0]:
		Draw.ring(ci, at(c, aim, k, x + xx, y), w * 0.72 * k, ring_col, 1.0 * k)
	if L.S >= 1:
		Draw.ring(ci, at(c, aim, k, x + 10.0, y), w * 0.72 * k, Draw.METAL_L, 1.0 * k)
	if L.P >= 1:
		Draw.bar(ci, at(c, aim, k, x + 3.0, y), at(c, aim, k, x + 5.0, y), (w + 1.2) * k, Draw.METAL)
	if L.P >= 4:
		var xx := 9.0
		while xx < len - 4.0:
			Draw.line(ci, at(c, aim, k, x + xx, y - w * 0.5), at(c, aim, k, x + xx + 1.0, y + w * 0.5), Color(0, 0, 0, 0.35), 0.7 * k)
			xx += 2.0
	if gold:
		for xx in [10.0, len - 4.0]:
			Draw.line(ci, at(c, aim, k, x + xx, y - w * 0.55), at(c, aim, k, x + xx, y + w * 0.55), GOLD, 1.1 * k)
	Draw.plate(ci, at(c, aim, k, x + len + 0.5, y), Draw.rect_pts(1.6, w * 0.78), Draw.METAL, aim, k, 1.0)
	Draw.line(ci, at(c, aim, k, x + len + 0.5, y - w * 0.78), at(c, aim, k, x + len + 0.5, y + w * 0.78), Color(0, 0, 0, 0.5), 0.8 * k)


static func draw(ci: CanvasItem, c: Vector2, aim: float, s: float, t: float, flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s
	var len := barrel_len(L)
	var B := barrels(L)
	var list: Array = B.list
	var n := list.size()
	var w: float = B.w
	var col := acc
	var fired: int = (int(extra[0]) if extra.size() > 0 and extra[0] != null else 0) % n
	var gold_b: bool = L.S >= 5 or L.P >= 5
	# The raised pedestal under the body (Higher Mount): fixed, so live.
	if L.R >= 2:
		Draw.dyn(true)
		Draw.ellipse(ci, c + Vector2(3.0 * k, 5.0 * k), 12.0 * k, 6.0 * k, Color(0, 0, 0, 0.25))
		Draw.disc(ci, c, 10.0 * k, Draw.OUTLINE)
		Draw.disc(ci, c, 9.3 * k, Draw.METAL_D)
		Draw.ring(ci, c, 8.0 * k, Draw.METAL, 1.2 * k)
		Draw.dyn(false)
	# The traverse ring on the baseplate, under the turret (Fast Traverse).
	if L.S >= 2:
		Draw.ring(ci, c, 9.0 * k, Draw.OUTLINE, 2.4 * k)
		for i in 16:
			var d := Vector2.from_angle(float(i) * TAU / 16.0 + aim)
			Draw.line(ci, c + d * 8.4 * k, c + d * 10.0 * k, Draw.METAL_L, 1.0 * k)
	# The rangefinder bar across the back.
	Draw.bar(ci, at(c, aim, k, -7.0, -12.0), at(c, aim, k, -7.0, 12.0), 2.2 * k, Draw.METAL)
	for y in [-12.0, 12.0]:
		Draw.orb(ci, at(c, aim, k, -7.0, y), 1.9 * k, Draw.METAL_L, k)
		Draw.glow_dot(ci, at(c, aim, k, -6.2, y), 0.8 * k, col)
	for b in list:
		gun_barrel(ci, c, aim, k, b, len, w, L, gold_b)
	# The body, the ammo drum (or crate), the armoured mount's shield.
	Draw.plate(ci, c, Draw.ngon(8, 1.0, PI / 8.0), Draw.METAL_L, aim, 7.5 * k, 1.2)
	Draw.rivets(ci, c, Draw.ngon(8, 1.0, PI / 8.0), aim, 7.5 * k, 0.82, 0.6 * k)
	if L.r == 1:
		Draw.orb(ci, at(c, aim, k, -1.0, 9.5), 3.6 * k, Draw.METAL, k)
		Draw.ring(ci, at(c, aim, k, -1.0, 9.5), 2.4 * k, Color(col, 0.6), 1.0 * k)
		Draw.disc(ci, at(c, aim, k, -1.0, 9.5), 0.9 * k, Draw.METAL_D)
	else:
		Draw.plate(ci, at(c, aim, k, -1.0, 9.5), Draw.rect_pts(4.0, 2.6), AMMO, aim, k, 1.0)
	if kp(L, 0, 2) == "B":
		Draw.plate(ci, at(c, aim, k, -1.0, -5.5), Draw.rect_pts(2.0, 2.6), Draw.METAL, aim, k, 1.0)
		for y in [-1.2, 1.2]:
			Draw.glow_dot(ci, at(c, aim, k, 1.2, -5.5 + y), 0.6 * k, col)
	if L.r == 2:
		Draw.plate(ci, c, Draw.ngon(8, 1.0, PI / 8.0), STEEL, aim, 6.0 * k, 1.0)
	Draw.orb(ci, c, 3.6 * k, Draw.METAL, k)
	Draw.glow_dot(ci, at(c, aim, k, 1.2, 0.0), 1.2 * k, col)
	# Live: spinning radars and gears, the muzzle flash of the barrel that fired.
	Draw.dyn(true)
	if L.r == 0:
		var q := at(c, aim, k, -4.0, 6.0)
		var a := t * 3.0
		Draw.arc(ci, q, 2.6 * k, a - 1.2, a + 1.2, 8, Draw.OUTLINE, 2.0 * k)
		Draw.arc(ci, q, 2.6 * k, a - 1.2, a + 1.2, 8, Color(col, 0.9), 1.2 * k)
	if L.R >= 5:
		var q2 := at(c, aim, k, -3.0, -5.0)
		var a2 := t * 2.0
		Draw.arc(ci, q2, 4.4 * k, a2 - 1.0, a2 + 1.0, 8, Draw.OUTLINE, 2.4 * k)
		Draw.arc(ci, q2, 4.4 * k, a2 - 1.0, a2 + 1.0, 8, GOLD, 1.4 * k)
		Draw.glow_dot(ci, q2, 0.6 * k, col)
	if kp(L, 2, 3) == "B":
		for y in [-4.5, 4.5]:
			var q3 := at(c, aim, k, -4.0, y)
			Draw.disc(ci, q3, 1.6 * k, Draw.OUTLINE)
			for i in 6:
				Draw.line(ci, q3, q3 + Vector2.from_angle(t * 9.0 * signf(y) + float(i)) * 1.4 * k, Draw.METAL_L, 0.7 * k)
	if flash > 0.0:
		var fl := clampf(flash / 0.12, 0.0, 1.0)
		var mp := muzzle(c, aim, k, look, fired)
		Draw.disc(ci, mp, w * 0.9 * k * fl, Color(1.0, 0.92, 0.7, fl))
		Draw.disc(ci, mp, w * 2.0 * k * fl, Color(1.0, 0.8, 0.4, 0.3 * fl))
	Draw.dyn(false)
