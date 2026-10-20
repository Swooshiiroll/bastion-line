extends RefCounted
## Shockwave Generator art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_16_shock.html, tools/tower_art/data_p2_shock.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 wave focus, 1 containment coils, 2 reactor venting) and the depth of
## each path, 5 on the path that took its mastery. a = Power/Range (the core), b = Speed (the containment ring), c = Effect (the violet
## band). The tower never turns; the core's rings, the ring's blades and the band are live. `extra[0]` is the time since the last wave
## (the band stretches outward with a wave, then springs back and rings).

const Draw = preload("res://scripts/view/Draw.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const AMB := Color(1.0, 0.70, 0.28)
const HOT := Color(1.0, 0.95, 0.80)
const VIOLET := Color(0.72, 0.48, 1.0)
const CORE_R := [0.0, 3.4, 3.9, 4.4, 4.9, 5.3]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "P": 0, "S": 0, "E": 0}
	return {"r": int(p[0]), "P": int(p[1]), "S": int(p[2]), "E": int(p[3])}


static func draw(ci: CanvasItem, c: Vector2, _aim: float, s: float, t: float, _flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s
	var age: float = clampf(float(extra[0]), 0.0, 4.0) if extra.size() > 0 and extra[0] != null else 4.0
	var fl := exp(-age / 0.4)
	var g1: bool = L.P >= 5
	var g2: bool = L.S >= 5
	var g3: bool = L.E >= 5
	var col := acc
	var hc: Color = HOT if g1 else AMB.lerp(HOT, 0.12 * float(L.P))
	# --- Cached: the clamps, the Retrofits, the ring's base. ---
	Draw.ring(ci, c, 10.0 * k, Draw.OUTLINE, 6.4 * k)
	Draw.ring(ci, c, 10.0 * k, Draw.METAL_L, 5.0 * k)
	Draw.arc(ci, c, 10.0 * k, PI * 1.05, PI * 1.6, 12, Draw.METAL_L.lightened(0.4), 1.4 * k)
	for i in 3:
		var a := -PI / 2.0 + float(i) * TAU / 3.0
		Draw.plate(ci, c + Vector2.from_angle(a) * 10.0 * k, Draw.rect_pts(2.0, 3.6), Draw.METAL_D, a, k, 1.0)
	if L.r == 0:
		Draw.ring(ci, c, 12.6 * k, Draw.METAL_L, 1.6 * k)
	if L.r == 2:
		for sg in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
			Draw.plate(ci, c + sg * 10.8 * k, Draw.rect_pts(1.6, 1.6), Draw.METAL_D, sg.angle(), k, 0.9)
	Draw.disc(ci, c, 5.8 * k, Color(0.08, 0.06, 0.04))
	# --- Live: the turbine ring, the spinning core rings, the violet band, the glow. ---
	Draw.dyn(true)
	var rc: Color = GOLD if g2 else (HOT if g1 else col)
	var ra: float = t * float([0.0, 0.8, 1.2, 1.7, 2.4, 3.4][L.S]) * (1.6 if fl > 0.3 else 1.0)
	var n: int = 8 + 2 * int(L.S)
	if L.S > 0:
		for j in n:
			var a2 := ra + float(j) * TAU / float(n)
			Draw.fill(ci, c + Vector2.from_angle(a2) * 12.0 * k, PackedVector2Array([Vector2(0, -1), Vector2(1.6, 0.3), Vector2(-0.5, 1.2)]), GOLD if g2 else Draw.METAL, a2, k)
			Draw.fill(ci, c + Vector2.from_angle(a2) * 8.0 * k, PackedVector2Array([Vector2(0, -1), Vector2(-1.6, 0.3), Vector2(0.5, 1.2)]), GOLD if g2 else Draw.METAL, a2, k)
	Draw.ring(ci, c, 10.0 * k, Color(rc, 0.2 + 0.7 * fl), 1.2 * k)
	if L.P > 0:
		var rcore: float = CORE_R[L.P]
		var nr := mini(L.P + 1, 5)
		if g1:
			Draw.disc(ci, c, rcore * 1.3 * k, Color(HOT, 0.16))
		for j in nr:
			var rr := rcore * (0.3 + 0.7 * float(j + 1) / float(nr)) * k
			var sp := t * (1.0 + float(j) * 0.6) * (-1.0 if j % 2 == 1 else 1.0)
			for q in 3:
				var a3 := sp + float(q) * TAU / 3.0
				Draw.arc(ci, c, rr, a3, a3 + 0.8, 6, Color(hc, 0.95), 1.3 * k)
		Draw.glow_dot(ci, c, (1.2 + 2.0 * fl) * (1.6 if g1 else 1.0) * k, HOT if g1 else AMB.lerp(HOT, 0.3))
	else:
		Draw.glow_dot(ci, c, (2.4 + 3.0 * fl) * k, col.lightened(0.2 + 0.4 * fl))
	if L.E > 0:
		# The violet band round the ring: a gentle ripple, stretched outward on each wave, then it springs back and rings.
		var bend: float = [0.0, 0.8, 1.7, 2.9, 4.6, 7.5][L.E]
		var stretch: float = [0.0, 3.0, 5.0, 7.5, 10.5, 14.0][L.E]
		var rip: float = [0.0, 0.15, 0.25, 0.35, 0.45, 0.6][L.E]
		var al: float = [0.0, 0.3, 0.45, 0.62, 0.82, 0.95][L.E]
		var wd: float = [0.0, 0.8, 0.9, 1.0, 1.1, 1.3][L.E]
		var el := 1.0 - pow(1.0 - age / 0.18, 3.0) if age < 0.18 else exp(-(age - 0.18) * 1.15) * cos((age - 0.18) * 21.0)
		var el2 := exp(-age) * cos(age * 16.0 + 0.8)
		var el3 := exp(-age * 0.9) * cos(age * 12.0 + 1.6)
		var pts := PackedVector2Array()
		for j in 161:
			var a4 := float(j) * TAU / 160.0
			var rad := 10.0 + stretch * el + rip * sin(6.0 * a4 + t * 2.4) + rip * 0.4 * sin(9.0 * a4 - t * 1.9) + bend * (0.7 * sin(2.0 * a4 + 0.8) * el2 + 0.5 * sin(3.0 * a4 - 0.4) * el3)
			pts.append(c + Vector2.from_angle(a4) * rad * k)
		var bc: Color = GOLD if g3 else Color(1, 1, 1)
		Draw.polyline(ci, pts, Color(bc, al * 0.25), wd * 2.0 * k)
		Draw.polyline(ci, pts, Color(bc, al), wd * k)
	if L.r == 1:
		for j in 6:
			var a5 := t * 2.0 + float(j) * TAU / 6.0
			Draw.arc(ci, c, 6.4 * k, a5, a5 + 0.5, 5, Color(1.0, 0.7, 0.3, 0.8), 1.2 * k)
	Draw.dyn(false)
