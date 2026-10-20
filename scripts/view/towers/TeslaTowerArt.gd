extends RefCounted
## Tesla Tower art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_08_tesla.html, tools/tower_art/data_p2_tesla.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 bigger disk, 1 grounding rods, 2 insulated coils) and the
## depth of each path, 5 on the path that took its mastery. a = Power, b = Range/Chaining, c = Speed. This tower never turns, so
## everything is cached except what glows with the charge (`extra[0]`, 0..1 how far the next arc has charged) and the sparks.

const Draw = preload("res://scripts/view/Draw.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const STEEL := Color(0.42, 0.45, 0.50)
const COPPER := Color(0.78, 0.50, 0.28)
const CERAM := Color(0.86, 0.85, 0.80)
const YEL := Color(1.0, 0.85, 0.30)
const ORANGE := Color(1.0, 0.55, 0.20)

# The owner's picks per step: Power, Range/Chaining, Speed.
const PICKS := [["A", "B", "A", "C", "C"], ["A", "A", "A", "A", "B"], ["A", "B", "B", "C", "B"]]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "P": 0, "C": 0, "S": 0}
	return {"r": int(p[0]), "P": int(p[1]), "C": int(p[2]), "S": int(p[3])}


static func kp(L: Dictionary, pi: int, k: int) -> String:
	var d: int = [L.P, L.C, L.S][pi]
	return PICKS[pi][k] if d > k else ""


## The arcs' colour: gold at the Power mastery, else the tower's.
static func arc_color(L: Dictionary, acc: Color) -> Color:
	return GOLD if L.P >= 5 else acc


static func pol(c: Vector2, k: float, r: float, a: float) -> Vector2:
	return c + Vector2.from_angle(a) * r * k


static func draw(ci: CanvasItem, c: Vector2, _aim: float, s: float, t: float, _flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s
	var ch: float = clampf(float(extra[0]), 0.0, 1.0) if extra.size() > 0 and extra[0] != null else 0.0
	var gold: bool = L.P >= 5
	var col := acc
	var node_col: Color = GOLD if gold else col
	var fixed := func(x: float, y: float) -> Vector2: return c + Vector2(x, y) * k
	# --- Cached: corner kit, the disk's Retrofit, the toroids and their marks. ---
	if kp(L, 0, 3) == "C":
		for i in 4:
			var a := PI / 4.0 + float(i) * PI / 2.0
			Draw.bar(ci, pol(c, k, 13.0, a), pol(c, k, 16.6, a), 1.3 * k, COPPER)
	if L.r == 1:
		var qs: Array = []
		for q in [Vector2(-8.5, -13.5), Vector2(8.5, -13.5), Vector2(8.5, 13.5), Vector2(-8.5, 13.5)]:
			qs.append(c + q * k)
		for i in 4:
			Draw.disc(ci, qs[i], 1.0 * k, COPPER)
			Draw.line(ci, qs[i], qs[(i + 1) % 4], Color(COPPER, 0.6), 0.8 * k)
	if L.r == 0:
		Draw.disc(ci, c, 14.2 * k, Draw.OUTLINE)
		Draw.disc(ci, c, 13.6 * k, Draw.METAL_D)
	var outer_c: Color = Draw.METAL_L
	if kp(L, 0, 4) == "B":
		outer_c = Draw.METAL_L.lerp(GOLD, 0.45)
	for pr in [[11.0, 4.0], [6.5, 3.0]]:
		var rr: float = pr[0]
		var w: float = pr[1]
		Draw.ring(ci, c, rr * k, Draw.OUTLINE, (w + 1.4) * k)
		Draw.ring(ci, c, rr * k, outer_c if rr > 8.0 else Draw.METAL_L, w * k)
		Draw.arc(ci, c, rr * k, PI * 1.05, PI * 1.6, 12, Draw.METAL_L.lightened(0.4), w * 0.35 * k)
	if kp(L, 1, 0) == "A":
		for i in 3:
			Draw.ring(ci, c, (5.6 + float(i) * 0.8) * k, COPPER.darkened(0.15) if i % 2 == 1 else COPPER, 0.8 * k)
	if kp(L, 2, 1) == "B":
		for i in 8:
			var a2 := float(i) * TAU / 8.0 + 0.2
			Draw.line(ci, pol(c, k, 8.2, a2), pol(c, k, 9.8, a2), STEEL, 1.2 * k)
	if kp(L, 0, 1) == "B":
		for i in 8:
			var a3 := float(i) * TAU / 8.0 + 0.4
			Draw.polyline(ci, PackedVector2Array([pol(c, k, 8.0, a3), pol(c, k, 8.8, a3 + 0.08), pol(c, k, 9.6, a3)]), Color(YEL, 0.85), 0.9 * k)
	if kp(L, 0, 2) == "A":
		for i in 4:
			var a4 := float(i) * PI / 2.0
			Draw.bar(ci, pol(c, k, 12.6, a4), pol(c, k, 16.0, a4), 1.4 * k, Draw.METAL_L)
			Draw.glow_dot(ci, pol(c, k, 16.4, a4), 0.7 * k, Color(0.8, 0.95, 1.0))
	if kp(L, 1, 3) == "A":
		Draw.ring(ci, c, 15.8 * k, Draw.METAL_D, 1.4 * k)
		for i in 4:
			Draw.disc(ci, pol(c, k, 15.8, float(i) * PI / 2.0), 1.0 * k, Draw.METAL_L)
	if kp(L, 1, 4) == "B":
		for i in 4:
			var a5 := PI / 4.0 + float(i) * PI / 2.0
			Draw.bar(ci, pol(c, k, 14.0, a5), pol(c, k, 16.4, a5), 1.8 * k, GOLD)
			Draw.glow_dot(ci, pol(c, k, 16.8, a5), 0.8 * k, YEL)
	if kp(L, 1, 1) == "A":
		for i in 4:
			var a6 := PI / 4.0 + float(i) * PI / 2.0
			Draw.plate(ci, pol(c, k, 14.6, a6), Draw.rect_pts(1.2, 1.2), Draw.METAL_D, a6, k, 0.9)
	if kp(L, 2, 4) == "B":
		for i in 8:
			var a7 := float(i) * TAU / 8.0
			Draw.line(ci, pol(c, k, 8.2, a7), pol(c, k, 9.6, a7), GOLD, 1.6 * k)
	if L.r == 2:
		for i in 4:
			var a8 := float(i) * PI / 2.0 + 0.78
			Draw.plate(ci, pol(c, k, 6.5, a8), Draw.rect_pts(1.1, 1.6), CERAM, a8, k, 0.9)
	if kp(L, 2, 2) == "B":
		for i in 8:
			var a9 := float(i) * TAU / 8.0
			Draw.line(ci, pol(c, k, 8.2, a9), pol(c, k, 9.6, a9), Draw.METAL_D, 1.4 * k)
	if kp(L, 2, 0) == "A":
		for i in 3:
			Draw.plate(ci, fixed.call(-7.8 + float(i) * 2.6, 13.0), Draw.rect_pts(1.0, 1.8), Draw.METAL_D, 0.0, k, 0.9)
	# Charge nodes round the outer toroid (bigger orbs with the first Power step), then the spire.
	for i in 8:
		var q2 := pol(c, k, 11.0, float(i) * TAU / 8.0 + PI / 8.0)
		if kp(L, 0, 0) == "A":
			Draw.disc(ci, q2, 2.1 * k, Draw.OUTLINE)
			Draw.orb(ci, q2, 1.7 * k, Draw.METAL_L, k)
		else:
			Draw.disc(ci, q2, 1.2 * k, Draw.OUTLINE)
	Draw.orb(ci, c, 3.2 * k, Draw.METAL, k)
	# --- Live: everything that glows with the charge, and the sparks. ---
	Draw.dyn(true)
	if L.r == 0:
		Draw.ring(ci, c, 13.8 * k, Color(col, 0.2 + 0.4 * ch), 1.2 * k)
		Draw.ring(ci, c, 14.8 * k, Color(col, 0.1 + 0.25 * ch), 1.4 * k)
	for i in 8:
		Draw.glow_dot(ci, pol(c, k, 11.0, float(i) * TAU / 8.0 + PI / 8.0), ((0.9 if kp(L, 0, 0) == "A" else 0.6) + 0.5 * ch) * k, Color(node_col, 0.6 + 0.4 * ch))
	if kp(L, 1, 1) == "A":
		for i in 4:
			var ab := PI / 4.0 + float(i) * PI / 2.0
			Draw.glow_dot(ci, pol(c, k, 14.6, ab), 0.6 * k, Color(col, 0.3 + 0.7 * ch))
	if kp(L, 1, 2) == "A":
		for i in 12:
			Draw.glow_dot(ci, pol(c, k, 15.2, float(i) * TAU / 12.0), 0.6 * k, Color(col, 0.4 + 0.5 * sin(t * 3.0 + float(i))))
	if kp(L, 2, 0) == "A":
		for i in 3:
			var h := clampf(ch * 3.0 - float(i), 0.0, 1.0)
			Draw.bar(ci, fixed.call(-7.8 + float(i) * 2.6, 14.4), fixed.call(-7.8 + float(i) * 2.6, 14.4 - 2.6 * h), 1.0 * k, Color(col, 0.95))
	if kp(L, 2, 2) == "B":
		for i in 8:
			if ch * 8.0 > float(i):
				var ac := float(i) * TAU / 8.0
				Draw.line(ci, pol(c, k, 8.2, ac), pol(c, k, 9.6, ac), Color(col, 0.95), 1.4 * k)
	if kp(L, 2, 3) == "C":
		Draw.ring(ci, c, 8.8 * k, Color(ORANGE, 0.5 + 0.4 * ch), 1.3 * k)
	Draw.glow_dot(ci, c, (1.6 + 1.8 * ch) * k, node_col)
	for i in 2 + (3 if L.S >= 5 else 0):
		var ar := fmod(sin(floorf(t * 12.0) + float(i) * 3.0) * 43758.5453, 1.0)
		var an := absf(ar) * TAU
		Draw.polyline(ci, PackedVector2Array([pol(c, k, 8.6, an), pol(c, k, 6.3, an + 0.1), pol(c, k, 4.0, an + 0.2)]), Color(node_col, 0.4 + 0.6 * ch), 0.7 * k)
	Draw.dyn(false)
