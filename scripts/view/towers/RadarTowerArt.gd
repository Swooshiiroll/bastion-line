extends RefCounted
## Radar Tower art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_14_radar.html, tools/tower_art/data_p2_radar.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 bigger dish, 1 signal processor, 2 early warning) and the depth of
## each path, 5 on the path that took its mastery. a = Power/Range, b = Speed/Frequency, c = Special Targeting. The station is cached
## (it never turns); the dish and its sweep, the radiation circle, the panels' lights and the turrets are live. `extra[0]` is the
## time one sweep takes (the ping period; the dish turns once per sweep).

const Draw = preload("res://scripts/view/Draw.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const STEEL := Color(0.42, 0.45, 0.50)
const RAD := Color(1.0, 0.30, 0.25)
const DARKP := Color(0.12, 0.16, 0.16)
const YELLOW_W := Color(1.0, 0.85, 0.2)

# The owner's picks per step: Power/Range, Frequency, Unmasking.
const PICKS := [["A", "C", "C", "B", "A"], ["B", "B", "B", "B", "A"], ["B", "A", "A", "B", "B"]]
const PSLOT := [Vector3(0, 12.2, 0), Vector3(0, -12.2, PI), Vector3(12.8, 0, -PI / 2.0), Vector3(-12.8, 0, PI / 2.0)]
const CSLOT := [Vector2(-7.4, -7.4), Vector2(7.4, -7.4), Vector2(7.4, 7.4), Vector2(-7.4, 7.4)]
const DISH_R := [0.0, 1.2, 2.0, 2.2, 3.0, 3.4]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "P": 0, "F": 0, "U": 0}
	return {"r": int(p[0]), "P": int(p[1]), "F": int(p[2]), "U": int(p[3])}


static func kp(L: Dictionary, pi: int, k: int) -> String:
	var d: int = [L.P, L.F, L.U][pi]
	return PICKS[pi][k] if d > k else ""


## The mark a revealed (formerly cloaked) enemy shows: corner brackets, gold with the unmasking mastery.
static func reveal_mark(ci: CanvasItem, p: Vector2, r: float, col: Color, a: float) -> void:
	for i in 4:
		var d := Vector2.from_angle(PI / 4.0 + float(i) * PI / 2.0)
		var c0 := p + d * r
		Draw.line(ci, c0, c0 + d.rotated(PI * 0.75) * r * 0.6, Color(col, a), 1.5)
		Draw.line(ci, c0, c0 + d.rotated(-PI * 0.75) * r * 0.6, Color(col, a), 1.5)


static func rotated(c: Vector2, k: float, v: Vector2, rt: float) -> Vector2:
	return c + v.rotated(rt) * k


static func draw(ci: CanvasItem, c: Vector2, _aim: float, s: float, t: float, _flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s
	var col := acc
	var period: float = maxf(0.4, float(extra[0])) if extra.size() > 0 and extra[0] != null else 3.0
	var ang := t * TAU / period
	var gold1: bool = L.P >= 5
	var gold2: bool = L.F >= 5
	var gold3: bool = L.U >= 5
	var fixed := func(x: float, y: float) -> Vector2: return c + Vector2(x, y) * k
	var lc2: Color = GOLD if gold2 else col
	var lc3: Color = GOLD if gold3 else col
	# --- Cached: the footing, the mast, the Retrofit hub, the emitter kit, the panels, the corner stations. ---
	for i in 4:
		if L.F <= i:
			break
		var sl: Vector3 = PSLOT[i]
		var p: Vector2 = c + Vector2(sl.x, sl.y) * k
		var rt: float = sl.z
		var pts := PackedVector2Array()
		for j in 5:
			var a := -0.85 + float(j) * 0.425
			pts.append(p + Vector2(5.6 * sin(a), 3.2 * cos(a) - 1.8).rotated(rt) * k)
		Draw.polyline(ci, pts, Draw.OUTLINE, 3.6 * k)
		Draw.polyline(ci, pts, Draw.METAL_L, 2.2 * k)
		for q in pts:
			Draw.disc(ci, q, 1.0 * k, DARKP)
			if gold2:
				Draw.disc(ci, q, 0.62 * k, GOLD)
	if L.U > 0:
		var sz: float = [0.0, 2.6, 3.0, 3.4, 3.8, 4.2][L.U]
		var body: Color = GOLD.darkened(0.45) if gold3 else Draw.METAL_L
		for i in 4:
			var cp: Vector2 = CSLOT[i]
			var p: Vector2 = c + cp * k
			var out := cp.normalized()
			if L.U == 1:
				Draw.plate(ci, p, Draw.rect_pts(sz, sz * 0.8), body, 0.0, k, 1.2)
				Draw.rect(ci, Rect2(p.x - 1.9 * k, p.y - 1.4 * k, 3.8 * k, 2.8 * k), DARKP)
			if L.U >= 2:
				Draw.plate(ci, p, Draw.rect_pts(sz, sz), body, 0.0, k, 1.3)
				Draw.plate(ci, p, Draw.rect_pts(sz * 0.6, sz * 0.6), Draw.METAL_D, 0.0, k, 0.9)
				Draw.bar(ci, p, p + out * 4.4 * k, 0.8 * k, Draw.METAL_L)
				Draw.glow_dot(ci, p + out * 4.6 * k, 0.6 * k, lc3)
			if L.U >= 3:
				var tsz: float = [0.0, 0.0, 0.0, 2.1, 2.2, 2.3][L.U]
				if L.U == 4:
					Draw.disc(ci, p, tsz * k + 1.8 * k, Draw.OUTLINE)
					Draw.disc(ci, p, tsz * k + 1.4 * k, Color(lc3, 0.28))
					Draw.ring(ci, p, tsz * k + 1.4 * k, Draw.METAL_L, 1.0 * k)
				Draw.disc(ci, p, tsz * k + 1.2 * k, Draw.OUTLINE)
				Draw.disc(ci, p, tsz * k, Draw.METAL_L)
				Draw.ring(ci, p, tsz * 0.78 * k, STEEL, 1.0 * k)
				Draw.bar(ci, p, p + out * 3.0 * k, 1.2 * k, Draw.METAL_L)
				if L.U == 5:
					Draw.ring(ci, p, tsz * k + 1.1 * k, GOLD, 0.9 * k)
	# Path 1: the footing, the mast (a ringed base), the Retrofit's light ring, the emitters, the hub.
	var dc: Color = GOLD if (gold1 or gold2) else Draw.METAL_L
	var rd: float = 10.0 + DISH_R[L.P] + (1.2 if L.r == 0 else 0.0)
	Draw.plate(ci, c, Draw.ngon(6, 1.0, 0.0), Draw.METAL_D, 0.0, 7.0 * k, 1.2)
	Draw.ring(ci, c, 6.2 * k, Color(Draw.OUTLINE, 0.6), 1.0 * k)
	if L.P >= 2:
		Draw.disc(ci, c, 6.6 * k, Draw.OUTLINE)
		Draw.disc(ci, c, 6.1 * k, Draw.METAL_D)
		Draw.ring(ci, c, 5.0 * k, Draw.METAL_L, 1.0 * k)
		Draw.ring(ci, c, 3.7 * k, Draw.METAL, 1.0 * k)
		for i in 8:
			Draw.line(ci, c + Vector2.from_angle(float(i) * TAU / 8.0) * 3.7 * k, c + Vector2.from_angle(float(i) * TAU / 8.0) * 6.1 * k, STEEL, 0.8 * k)
	if L.r == 1:
		Draw.ring(ci, c, 4.9 * k, Draw.METAL_L, 1.8 * k)
		for i in 8:
			var q2: Vector2 = c + Vector2.from_angle(float(i) * TAU / 8.0 + 0.2) * 4.9 * k
			Draw.disc(ci, q2, 0.8 * k, Draw.OUTLINE)
	if L.r == 2:
		Draw.plate(ci, c, Draw.rect_pts(4.0, 4.0), Draw.METAL_L, PI / 4.0, k, 1.2)
		Draw.plate(ci, c, Draw.rect_pts(2.8, 2.8), Draw.METAL_D, PI / 4.0, k, 0.9)
		for i in 4:
			var d := Vector2.from_angle(PI / 4.0 + float(i) * PI / 2.0)
			Draw.bar(ci, c + d * 3.0 * k, c + d * 7.0 * k, 1.2 * k, Draw.METAL)
			Draw.disc(ci, c + d * 3.0 * k, 0.5 * k, YELLOW_W)
	var rc: Color = GOLD if (gold1 or gold2) else RAD
	if L.P >= 4:
		for i in 3:
			var q3: Vector2 = c + Vector2.from_angle(PI / 2.0 + float(i) * TAU / 3.0 + 0.5) * 4.8 * k
			Draw.disc(ci, q3, 1.7 * k, Draw.OUTLINE)
			Draw.disc(ci, q3, 1.4 * k, Draw.METAL_D)
			Draw.ring(ci, q3, 1.1 * k, Color(rc, 0.9), 0.8 * k)
	if L.P >= 5:
		for i in 8:
			var a2 := float(i) * TAU / 8.0 + 0.2
			Draw.fill(ci, c + Vector2.from_angle(a2) * 6.8 * k, PackedVector2Array([Vector2(-0.4, -0.8), Vector2(1.8, -1.5), Vector2(1.8, 1.5), Vector2(-0.4, 0.8)]), GOLD, a2, k)
	Draw.orb(ci, c, 4.0 * k, Draw.METAL, k)
	# --- Live: the radiation circle, the sweep, the dish turning on its struts, the panels' lights. ---
	Draw.dyn(true)
	var rad_px: float = [0.0, 0.0, 0.0, 60.0, 70.0, 80.0][L.P] * k * 0.3
	if rad_px > 0.0:
		var pulse := 0.5 + 0.5 * sin(t * 3.0)
		Draw.disc(ci, c, rad_px, Color(rc, 0.07 + 0.05 * pulse))
		Draw.ring(ci, c, rad_px * 0.92, Color(rc, 0.3), 1.0)
	var span := 24.0 * k
	for i in 6:
		var a0 := ang - float(i) * 0.08
		Draw.poly(ci, PackedVector2Array([c, c + Vector2.from_angle(a0 - 0.08) * span, c + Vector2.from_angle(a0) * span]), Color(lc2 if L.F >= 5 else col, 0.16 * (1.0 - float(i) / 6.0)))
	Draw.line(ci, c, c + Vector2.from_angle(ang) * span, Color(lc2 if L.F >= 5 else col, 0.7), 1.3)
	if L.F >= 5:
		Draw.line(ci, c, c + Vector2.from_angle(ang + PI) * span, Color(GOLD, 0.6), 1.0)
	for sg in [-1.0, 0.0, 1.0]:
		Draw.bar(ci, c, c + Vector2.from_angle(ang + sg * 0.85) * (rd - 0.2) * k, 1.1 * k, Draw.METAL_L)
	if L.F >= 5:
		var a3 := ang + PI
		var r3 := rd * 0.95
		Draw.arc(ci, c, r3 * k, a3 - 1.1, a3 + 1.1, 10, Draw.OUTLINE, 3.0 * k)
		Draw.arc(ci, c, r3 * k, a3 - 1.1, a3 + 1.1, 10, GOLD, 1.7 * k)
	Draw.arc(ci, c, rd * k, ang - 1.1, ang + 1.1, 12, Draw.OUTLINE, 3.0 * k)
	Draw.arc(ci, c, rd * k, ang - 1.1, ang + 1.1, 12, dc, 1.7 * k)
	Draw.arc(ci, c, (rd - 0.3) * k, ang - 0.9, ang - 0.1, 8, dc.lightened(0.4), 0.6 * k)
	if L.r == 0:
		Draw.arc(ci, c, rd * 0.6 * k, ang - 1.1, ang + 1.1, 10, Draw.OUTLINE, 2.4 * k)
		Draw.arc(ci, c, rd * 0.6 * k, ang - 1.1, ang + 1.1, 10, dc, 1.2 * k)
	Draw.line(ci, c, c + Vector2.from_angle(ang) * 6.2 * k, Draw.METAL_L, 1.0 * k)
	Draw.glow_dot(ci, c, 1.1 * k, GOLD if gold1 else col)
	var ph := t * (2.2 + 0.5 * float(L.F))
	for i in 4:
		if L.F <= i:
			break
		var sl2: Vector3 = PSLOT[i]
		var p2: Vector2 = c + Vector2(sl2.x, sl2.y) * k
		for j in 5:
			var a4 := -0.85 + float(j) * 0.425
			if not gold2 and fmod(ph - float(j) * 0.35, 2.0) < 0.7:
				Draw.glow_dot(ci, p2 + Vector2(5.6 * sin(a4), 3.2 * cos(a4) - 1.8).rotated(sl2.z) * k, 0.75 * k, lc2)
	if L.r == 1:
		for i in 8:
			Draw.disc(ci, c + Vector2.from_angle(float(i) * TAU / 8.0 + 0.2) * 4.9 * k, 0.55 * k, col if fmod(t * 2.0 + float(i) * 0.3, 1.5) < 0.6 else DARKP)
	if L.P >= 3:
		# The radiation emitter's spark gap between two posts.
		var a_pt: Vector2 = c + Vector2(-5.6, 0) * k
		var b_pt: Vector2 = c + Vector2(5.6, 0) * k
		var pts2 := PackedVector2Array([a_pt + Vector2(0, -2.0 * k)])
		for j in range(1, 6):
			pts2.append((a_pt + Vector2(0, -2.0 * k)).lerp(b_pt + Vector2(0, -2.0 * k), float(j) / 6.0) + Vector2(0, sin(floorf(t * 20.0) + float(j) * 1.7) * 1.2 * k))
		pts2.append(b_pt + Vector2(0, -2.0 * k))
		Draw.polyline(ci, pts2, Color(rc, 0.35), 3.0)
		Draw.polyline(ci, pts2, rc, 1.1)
	Draw.dyn(false)
