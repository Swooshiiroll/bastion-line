extends RefCounted
## Laser Tower art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_03_laser.html, tools/tower_art/data_p2_laser.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c" (Tower.look_key): the Retrofit (-1 none, 0 capacitor ring, 1 radiator blocks,
## 2 afterglow crystal) and the depth of each path, 5 on the path that took its mastery. a = Power, b = Multi-Target,
## c = Range/Targeting. `g` (0..1) is the main beam's ramp, passed in `extra[0]`; everything that glows with it is live.
## The beams themselves are drawn by BeamLayer (see beam_origin and beam_style).

const Draw = preload("res://scripts/view/Draw.gd")
const Gun = preload("res://scripts/view/towers/GunTurretArt.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const STEEL := Color(0.42, 0.45, 0.50)
const COPPER := Color(0.78, 0.50, 0.28)
const WHITE := Color(1, 1, 1)
const BORE := Color(0.05, 0.05, 0.06)

# The owner's picks per step: Power, Multi-Target, Range/Targeting.
const PICKS := [["C", "C", "A", "B", "C"], ["A", "B", "C", "B", "C"], ["A", "A", "C", "A", "A"]]
const TIPS := [21.0, 24.0, 27.0, 31.0, 34.0, 37.0]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "P": 0, "M": 0, "R": 0}
	return {"r": int(p[0]), "P": int(p[1]), "M": int(p[2]), "R": int(p[3])}


static func kp(L: Dictionary, pi: int, k: int) -> String:
	var d: int = [L.P, L.M, L.R][pi]
	return PICKS[pi][k] if d > k else ""


static func tip_x(L: Dictionary) -> float:
	return TIPS[mini(L.R, 5)]


static func at(c: Vector2, aim: float, k: float, x: float, y: float) -> Vector2:
	return Gun.at(c, aim, k, x, y)


## Where beam `i` leaves the tower: the lance's tip, the extra beams a hair to either side.
static func beam_origin(c: Vector2, aim: float, k: float, look: String, i: int) -> Vector2:
	var L := levels(look)
	var o := at(c, aim, k, tip_x(L), 0.0)
	if i > 0:
		o += Vector2.from_angle(aim).orthogonal() * (1.0 if i % 2 == 1 else -1.0) * 1.2 * k
	return o


## The beam's look from its ramp `g` (0..1), the ceiling and its share of the power: width, colour, the gold wrap.
static func beam_style(look: String, g: float, ceiling: float, frac: float, acc: Color) -> Dictionary:
	var L := levels(look)
	var heat := minf(1.0, g * (ceiling - 2.0) / 6.0)
	var w := (1.2 + 3.4 * g * ceiling / 8.0) * sqrt(frac)
	return {
		"w": w,
		"col": acc.lerp(WHITE, 0.55 * heat) if L.P >= 3 else acc,
		"alpha": 0.6 + 0.4 * g,
		"gold": L.P >= 5 and g > 0.95,
	}


static func crystal(ci: CanvasItem, p: Vector2, aim: float, k: float, col: Color, z: float, gold: bool) -> void:
	var pts := PackedVector2Array([Vector2(3.8, 0), Vector2(0, 2.8), Vector2(-3.8, 0), Vector2(0, -2.8)])
	var scaled := PackedVector2Array()
	for q in pts:
		scaled.append(q * z)
	Draw.solid(ci, p, scaled, Color(GOLD if gold else col, 0.85), aim, k, 1.0)


static func draw(ci: CanvasItem, c: Vector2, aim: float, s: float, t: float, _flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s
	var g: float = float(extra[0]) if extra.size() > 0 and extra[0] != null else 0.0
	var tip := tip_x(L)
	var gold: bool = L.P >= 5
	var col := acc
	# The Capacitor Bank's ring round the deck brightens with the ramp.
	if L.r == 0:
		Draw.ring(ci, c, 13.5 * k, Draw.OUTLINE, 3.0 * k)
		Draw.ring(ci, c, 13.5 * k, Draw.METAL, 2.0 * k)
	# Heat sinks: fins on the flanks, or the Retrofit's radiator blocks (which Power's fin steps grow and gild instead).
	var big: bool = kp(L, 0, 3) == "B"
	var gild: bool = gold and kp(L, 0, 4) == "C"
	if L.r == 1:
		var hw := 2.4 if big else 1.6
		for y in [-1.0, 1.0]:
			var yy: float = y * (8.0 if big else 7.5)
			Draw.plate(ci, at(c, aim, k, -6.0, yy), Draw.rect_pts(4.4 if big else 3.4, hw), GOLD if gild else Draw.METAL, aim, k, 1.0)
			for i in (5 if big else 4):
				Draw.line(ci, at(c, aim, k, -9.0 + float(i) * 1.6, yy - hw * 0.75), at(c, aim, k, -9.0 + float(i) * 1.6, yy + hw * 0.75), Color(0, 0, 0, 0.4), 0.7 * k)
	else:
		var fin_l := 11.0 if big else 9.0
		for y in [-1.0, 1.0]:
			for i in 3:
				Draw.bar(ci, at(c, aim, k, -3.0 - 2.3 * float(i), y * 5.0), at(c, aim, k, -3.0 - 2.3 * float(i), y * fin_l), 1.3 * k, GOLD if gild else Draw.METAL_L)
	# The hull.
	Draw.plate(ci, c, PackedVector2Array([Vector2(7, 0), Vector2(1, 6), Vector2(-9, 5), Vector2(-11, 0), Vector2(-9, -5), Vector2(1, -6)]), Draw.METAL_L, aim, k, 1.2)
	if kp(L, 2, 2) == "C":
		for y in [-2.2, 2.2]:
			Draw.bar(ci, at(c, aim, k, 6.0, y), at(c, aim, k, tip - 2.0, y), 0.9 * k, Draw.METAL_L)
	# The lance, swapped longer along the Range path, its focusing rings spread along it.
	Draw.bar(ci, at(c, aim, k, 4.0, 0.0), at(c, aim, k, tip, 0.0), 3.0 * k, Draw.METAL)
	var ring_col: Color = GOLD if (L.R >= 5 and kp(L, 2, 4) != "C") else col.darkened(0.2)
	var ring_xs: Array = []
	for x in [8.0, 12.0, 16.0]:
		ring_xs.append(4.0 + (x - 4.0) * (tip - 4.0) / 17.0)
	for x in ring_xs:
		Draw.bar(ci, at(c, aim, k, x, -3.2), at(c, aim, k, x, 3.2), 1.5 * k, ring_col)
	if kp(L, 2, 1) == "A":
		for x in ring_xs:
			Draw.bar(ci, at(c, aim, k, float(x) + 1.6, -2.6), at(c, aim, k, float(x) + 1.6, 2.6), 1.0 * k, Draw.METAL_L)
	# The tip: a crystal, or a prism once the beam splits.
	var tp := at(c, aim, k, tip, 0.0)
	if L.M >= 1:
		var n := 4 if L.M >= 5 else 3
		var pts := Draw.ngon(n, 3.6, aim)
		Draw.solid(ci, tp, pts, Color(col, 0.75), 0.0, k, 1.0)
		if L.M >= 5:
			Draw.outline(ci, tp, pts, GOLD, 1.2 * k, 0.0, k)
	else:
		crystal(ci, tp, aim, k, col, 1.0, false)
	if L.R >= 5 and kp(L, 2, 4) == "C":
		Draw.orb(ci, tp, 4.2 * k, col.lerp(WHITE, 0.3), k)
	# The capacitor orb; Overdrive's core is bigger.
	Draw.orb(ci, at(c, aim, k, -4.0, 0.0), (3.0 if kp(L, 0, 2) == "A" else 2.2) * k, col.darkened(0.3), k)
	# Live: everything that glows with the ramp, the prism halo, the afterglow.
	Draw.dyn(true)
	if L.r == 0:
		Draw.ring(ci, c, 13.5 * k, Color(col, 0.2 + 0.6 * g), 0.8 * k)
	if kp(L, 0, 0) == "C":
		for y in [-3.0, 3.0]:
			Draw.line(ci, at(c, aim, k, -8.0, y), at(c, aim, k, -2.0, y), Color(1.0, 0.5, 0.2, 0.3 + 0.6 * g * (0.6 + 0.4 * sin(t * 20.0 + y))), 1.2 * k)
	Draw.strip(ci, at(c, aim, k, 5.0, 0.0), at(c, aim, k, tip, 0.0), 0.6 * k, Color(col, 0.35 + 0.6 * g))
	if L.M < 1:
		Draw.glow_dot(ci, tp, (0.8 + 1.8 * g) * k, WHITE)
	else:
		Draw.glow_dot(ci, tp, (0.9 + 1.5 * g) * k, WHITE)
	if L.M >= 5 and kp(L, 1, 4) == "C":
		for i in 4:
			Draw.solid(ci, tp + Vector2.from_angle(aim + float(i) * PI / 2.0 + t) * 6.0 * k, Draw.ngon(3, 1.2, t), Color(GOLD, 0.9), 0.0, k, 0.6)
	if kp(L, 0, 2) == "A":
		Draw.glow_dot(ci, at(c, aim, k, -4.0, 0.0), (0.8 + 1.4 * g) * k, col.lerp(WHITE, 0.4))
	if L.r == 2:
		Draw.glow_dot(ci, tp, (1.2 + 0.8 * maxf(0.5, g)) * k, Color(col, 0.6))
	Draw.dyn(false)
