extends RefCounted
## CAS Gunship art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_10_cas.html, tools/tower_art/data_p2_cas.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 radar dome, 1 extra ammo, 2 wide orbit) and the depth of each
## path (the light, medium and heavy gun), 5 on a path that took its mastery. The ground station is fixed and cached; the plane is
## drawn by `plane`, at twice the ground scale with its shadow far below. The upgrades show as tally marks on the fuselage.

const Draw = preload("res://scripts/view/Draw.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const STEEL := Color(0.42, 0.45, 0.50)
const RED := Color(0.85, 0.20, 0.18)
const ORANGE := Color(1.0, 0.55, 0.20)
const GREEN_T := Color(0.35, 1.0, 0.45)
const BLUE_T := Color(0.40, 0.65, 1.0)
const BORE := Color(0.05, 0.05, 0.06)
## The plane is drawn this much bigger than the ground.
const ZP := 2.0
## The fuselage's width (the page's 5, thinned at the owner's note).
const BODY_W := 4.0


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "L": 0, "M": 0, "H": 0}
	return {"r": int(p[0]), "L": int(p[1]), "M": int(p[2]), "H": int(p[3])}


static func at(p: Vector2, h: float, k: float, x: float, y: float) -> Vector2:
	return p + (Vector2.from_angle(h) * x + Vector2.from_angle(h).orthogonal() * y) * k


## The tracer's look from the light gun's path: width, white core, double line (the gold at its mastery).
static func gat_style(look: String, acc: Color) -> Dictionary:
	var L := levels(look)
	return {"w": 1.5 + (0.3 if L.L >= 1 else 0.0) + (0.2 if L.L >= 3 else 0.0), "col": GOLD if L.L >= 5 else acc, "core": L.L >= 3, "double": L.L >= 4}


static func plane(ci: CanvasItem, p: Vector2, h: float, s: float, t: float, look: String, acc: Color, firing: bool) -> void:
	var L := levels(look)
	var k := s * ZP
	var w := 18.0 + (4.0 if L.r == 2 else 0.0)
	var d := Vector2.from_angle(h)
	var o := d.orthogonal()
	# The shadow, far below.
	var q := p + Vector2(k * 10.0, k * 16.0)
	Draw.fill(ci, q, Draw.rect_pts(13.0, BODY_W * 0.52), Color(0, 0, 0, 0.14), h, k)
	Draw.fill(ci, q, Draw.rect_pts(2.4, w), Color(0, 0, 0, 0.14), h, k)
	# Fuselage, tail, wing.
	Draw.bar(ci, at(p, h, k, -12.0, 0.0), at(p, h, k, 13.0, 0.0), BODY_W * k, Draw.METAL_L)
	Draw.plate(ci, at(p, h, k, -11.0, 0.0), Draw.rect_pts(1.6, 6.5), Draw.METAL, h, k, 0.9)
	Draw.plate(ci, at(p, h, k, 2.0, 0.0), Draw.rect_pts(2.4, w), Draw.METAL_L, h, k, 1.0)
	if L.r == 2:
		for sg in [-1.0, 1.0]:
			Draw.plate(ci, at(p, h, k, 2.0, sg * (w + 0.4)), PackedVector2Array([Vector2(2.4, 0), Vector2(1.0, sg * 2.2), Vector2(-1.6, sg * 2.2), Vector2(-2.4, 0)]), Draw.METAL, h, k, 0.9)
	# Four engines, each a nacelle with its propeller disc seen edge-on in front.
	for y in [-12.0, -6.0, 6.0, 12.0]:
		Draw.bar(ci, at(p, h, k, -0.5, y), at(p, h, k, 5.0, y), 2.2 * k, Draw.METAL)
		Draw.orb(ci, at(p, h, k, 5.4, y), 0.9 * k, Draw.METAL_L, k)
		var pc := at(p, h, k, 6.4, y)
		Draw.oval(ci, pc, 0.9 * k, 2.7 * k, h, Color(0.85, 0.9, 1.0, 0.16))
		for bl in 2:
			var th: float = t * 26.0 + float(y) + float(bl) * PI
			Draw.line(ci, pc, at(p, h, k, 6.4 + 0.9 * sin(th), y + 2.7 * cos(th)), Color(0.9, 0.93, 1.0, 0.55), 0.45 * k)
	Draw.glow_dot(ci, at(p, h, k, 12.0, 0.0), 0.8 * k, acc)
	Draw.glow_dot(ci, at(p, h, k, 2.0, -w), 0.7 * k, Color(1.0, 0.25, 0.25))
	Draw.glow_dot(ci, at(p, h, k, 2.0, w), 0.7 * k, Color(0.3, 1.0, 0.45))
	# The guns sit inside the fuselage behind plain wells that glow while they fire.
	var hy := 1.2
	var hatch := func(x: float, y: float, frame: Color) -> void:
		Draw.plate(ci, at(p, h, k, x, y), Draw.rect_pts(1.07, 0.7), frame, h, k, 0.8)
		Draw.plate(ci, at(p, h, k, x, y), Draw.rect_pts(0.85, 0.5), BORE, h, k, 0.8)
		if firing:
			Draw.glow_dot(ci, at(p, h, k, x, y), 0.5 * k, Color(ORANGE, 0.9))
	hatch.call(6.4, hy, GOLD if L.L >= 5 else STEEL)
	if L.L >= 5:
		hatch.call(6.4, -hy, GOLD)
	if L.M >= 1:
		hatch.call(-6.5, hy, GOLD if L.M >= 5 else STEEL)
		if L.M >= 5:
			hatch.call(-6.5, -hy, GOLD)
	# The Retrofit: the radar dish (Radar).
	if L.r == 0:
		var dc := at(p, h, k, -3.4, 0.0)
		Draw.disc(ci, dc, 2.3 * k, Draw.OUTLINE)
		Draw.disc(ci, dc, 1.9 * k, Draw.METAL_D)
		Draw.line(ci, dc, dc + Vector2.from_angle(t * 3.0) * 1.6 * k, Color(acc, 0.9), 0.4 * k)
	# Tally marks on the fuselage: one stroke per step bought, green / red / blue for the light, medium and heavy guns; the
	# mastery strikes the four through and turns the path's marks gold.
	var rows := [[GREEN_T, 3.4, L.L], [RED, 2.0, L.M], [BLUE_T, 0.6, L.H]]
	for row in rows:
		var lv: int = row[2]
		var gold: bool = lv >= 5
		var c1: Color = GOLD if gold else row[0]
		var xr: float = row[1]
		for i in mini(lv, 4):
			var y2 := -0.9 + float(i) * 0.6
			var a := at(p, h, k, xr - 0.5, y2)
			var b := at(p, h, k, xr + 0.5, y2)
			Draw.line(ci, a, b, Color(c1, 0.3), 1.0 * k)
			Draw.line(ci, a, b, c1, 0.35 * k)
		if gold:
			var sa := at(p, h, k, xr + 0.65, -1.15)
			var sb := at(p, h, k, xr - 0.65, 1.15)
			Draw.line(ci, sa, sb, Color(GOLD, 0.3), 1.0 * k)
			Draw.line(ci, sa, sb, GOLD, 0.4 * k)


static func draw(ci: CanvasItem, c: Vector2, _aim: float, s: float, t: float, _flash: float, _look: String, acc: Color, _extra: Array) -> void:
	var k := s
	Draw.plate(ci, c, Draw.rect_pts(12.0, 12.0), Draw.METAL_D, 0.0, k, 1.2)
	for i in 4:
		Draw.rect(ci, Rect2(c.x - 1.0 * k, c.y + (-10.0 + float(i) * 5.0) * k, 2.0 * k, 2.6 * k), Color(0.85, 0.85, 0.8, 0.8))
	Draw.bar(ci, c + Vector2(7, 7) * k, c + Vector2(7, -2) * k, 1.2 * k, Draw.METAL_L)
	Draw.dyn(true)
	var pu := fmod(t * 1.2, 1.0)
	Draw.glow_dot(ci, c + Vector2(7, -2.8) * k, (0.9 + 0.6 * (1.0 - pu)) * k, acc)
	Draw.ring(ci, c + Vector2(7, -2.8) * k, (1.5 + 5.0 * pu) * k, Color(acc, 0.6 * (1.0 - pu)), 1.0)
	Draw.dyn(false)
