extends RefCounted
## Magneto Tower art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_18_magneto.html, tools/tower_art/data_p2_magneto.js) with the owner's picks hard-coded (every step the first option).
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 superconducting coil, 1 field stabiliser, 2 pole shoes) and the depth of
## each path, 5 on the path that took its mastery. a = Pull Strength (the coil stack), b = Field Size (the base's emitter rings), c = Polarity (the
## pole cap). The tower never turns; the winding current, the emitter nodes and the turning pole cap are live. `extra[0]` is how many repels
## (flips) have happened, so the pole's red and blue swap at each one.

const Draw = preload("res://scripts/view/Draw.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const COPPER := Color(0.78, 0.50, 0.28)
const STEEL := Color(0.42, 0.45, 0.50)
const RED := Color(0.85, 0.20, 0.20)
const BLUEP := Color(0.28, 0.48, 0.95)
const GREYP := Color(0.62, 0.64, 0.68)
const FROST := Color(0.86, 0.95, 1.0)
const SCALE := [1.0, 1.04, 1.08, 1.13, 1.17, 1.2]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "P": 0, "F": 0, "L": 0}
	return {"r": int(p[0]), "P": int(p[1]), "F": int(p[2]), "L": int(p[3])}


static func gl(col: Color, gold: bool, u := 0.75) -> Color:
	return col.lerp(GOLD, u) if gold else col


## The outer edge of the coil stack (straps included), so the emitter rings clear it.
static func coil_outer(L: Dictionary) -> float:
	var r0: float = 12.0 * SCALE[L.P]
	return maxf(r0 + 1.6 * (1.0 + 0.12 * float(L.P)) + 0.7, r0 + 2.7 if L.P >= 2 else 0.0)


static func draw(ci: CanvasItem, c: Vector2, _aim: float, s: float, t: float, _flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s
	var flips: int = int(extra[0]) if extra.size() > 0 and extra[0] != null else 0
	var col := acc
	var gp: bool = L.P >= 5
	var gf: bool = L.F >= 5
	var gl3: bool = L.L >= 5
	var steel := gl(STEEL, gp, 0.6)
	var fc: Color = GOLD if gf else col
	# --- Cached: the base's emitter rings (Field Size), then the coil stack's windings and clamps (Pull Strength). ---
	if L.r == 1:
		for i in 3:
			var a := float(i) * TAU / 3.0
			var q: Vector2 = c + Vector2.from_angle(a) * 18.2 * k
			Draw.plate(ci, q, Draw.rect_pts(3.4, 2.6), Draw.METAL_D, a + PI / 2.0, k, 1.2)
	if L.F > 0:
		var n: int = [0, 1, 2, 2, 3, 3][L.F]
		var r0: float = minf(19.5, maxf(17.0, coil_outer(L) + 1.2))
		if L.F >= 3:
			for i in 6:
				Draw.bar(ci, c + Vector2.from_angle(float(i) * PI / 3.0) * r0 * k, c + Vector2.from_angle(float(i) * PI / 3.0) * (r0 + float(n - 1) * 2.4) * k, 1.2 * k, steel)
		for j in n:
			var rr: float = r0 + float(j) * 2.4
			Draw.ring(ci, c, rr * k, Draw.OUTLINE, 2.6 * k)
			Draw.ring(ci, c, rr * k, steel, 1.6 * k)
	var r_stack: float = 12.0 * SCALE[L.P]
	var cu: Color = GOLD if gp else COPPER
	var wm := 1.0 + 0.12 * float(L.P)
	var tiers: Array = [[r_stack, 3.2], [r_stack * 0.717, 2.8], [r_stack * 0.45, 2.4]]
	for i in tiers.size():
		var r: float = tiers[i][0]
		var w: float = float(tiers[i][1]) * wm
		Draw.ring(ci, c, r * k, Draw.OUTLINE, (w + 1.4) * k)
		Draw.ring(ci, c, r * k, cu, w * k)
		var nw := int(round(r * 2.2))
		for j in nw:
			var an := float(j) * TAU / float(nw) + float(i) * 0.1
			Draw.line(ci, c + Vector2.from_angle(an) * (r - w * 0.45) * k, c + Vector2.from_angle(an) * (r + w * 0.45) * k, cu.darkened(0.3), 0.6 * k)
		if L.P >= 3:
			Draw.ring(ci, c, r * k, cu.darkened(0.35), 0.7 * k)
		Draw.arc(ci, c, r * k, PI * 1.05, PI * 1.6, 10, cu.lightened(0.4), w * 0.35 * k)
		if L.r == 0:
			Draw.ring(ci, c, r * k, Color(FROST, 0.25), (w * 0.6) * k)
	if L.P >= 2:
		for i in 4:
			var a2 := float(i) * PI / 2.0 + PI / 4.0
			var e: Vector2 = c + Vector2.from_angle(a2) * (r_stack + 1.8) * k
			Draw.bar(ci, c + Vector2.from_angle(a2) * 3.4 * k, e, 1.4 * k, steel)
			Draw.disc(ci, e, 0.9 * k, Draw.METAL_L)
	if L.r == 2:
		for sg in [-1.0, 1.0]:
			Draw.plate(ci, c + Vector2(sg * 5.0, 4.0) * k, Draw.rect_pts(1.6, 1.0), Draw.METAL_D, 0.0, k, 0.9)
	# --- Live: the winding current, the emitter nodes, the pole cap spinning with its torn plates. ---
	Draw.dyn(true)
	if L.P >= 4:
		for i in tiers.size():
			var r2: float = tiers[i][0]
			var a0 := t * (2.2 + 0.6 * float(i)) + float(i) * 2.0
			Draw.arc(ci, c, r2 * k, a0, a0 + 0.7, 6, Color(Color(1, 0.95, 0.7) if gp else col.lightened(0.35), 0.85), float(tiers[i][1]) * wm * 0.5 * k)
	if L.F > 0:
		var n2: int = [0, 1, 2, 2, 3, 3][L.F]
		var rr0: float = minf(19.5, maxf(17.0, coil_outer(L) + 1.2))
		var nodes: int = 6 + 2 * int(L.F)
		for j in n2:
			var rr2: float = rr0 + float(j) * 2.4
			for i in nodes:
				var a3 := float(i) * TAU / float(nodes) + float(j) * 0.2 + t * 0.2 * (-1.0 if j % 2 == 1 else 1.0)
				Draw.glow_dot(ci, c + Vector2.from_angle(a3) * rr2 * k, 0.7 * k, fc)
	var flip := gl3 and flips % 2 == 1
	var rc: Color = BLUEP if flip else RED
	var bc: Color = RED if flip else BLUEP
	var rim: Color = GOLD if gl3 else Draw.METAL_L
	if L.L == 0:
		Draw.orb(ci, c, 3.0 * k, RED, k)
		Draw.glow_dot(ci, c, (1.0 + 0.5 * sin(t * 5.0)) * k, col)
	else:
		var rp := 3.0 + 0.55 * float(L.L)
		if L.L >= 3:
			var nplates: int = 4 + 2 * (int(L.L) - 3)
			for i in nplates:
				var a4 := float(i) * TAU / float(nplates) + 0.3
				Draw.plate(ci, c + Vector2.from_angle(a4) * (rp + 3.0) * k, PackedVector2Array([Vector2(-1.8, -1.2), Vector2(1.8, -1.0), Vector2(1.4, 1.2), Vector2(-1.5, 1.1)]), gl(GREYP, gl3, 0.4), a4, k, 0.9)
		var sp := t * 0.8 if L.L >= 3 else 0.6
		Draw.disc(ci, c, (rp + 0.9) * k, Draw.OUTLINE)
		for h in 2:
			var a0b := sp + float(h) * PI
			var pts := PackedVector2Array([c])
			for j in 13:
				pts.append(c + Vector2.from_angle(a0b + float(j) * PI / 12.0) * rp * k)
			Draw.poly(ci, pts, rc if h == 0 else bc)
		Draw.disc(ci, c + Vector2(-rp * 0.3, -rp * 0.3) * k, rp * 0.3 * k, Color(1, 1, 1, 0.3))
		Draw.bar(ci, c + Vector2.from_angle(sp) * (rp + 0.5) * k, c + Vector2.from_angle(sp + PI) * (rp + 0.5) * k, (0.8 + 0.15 * float(L.L)) * k, rim)
		if L.L >= 2:
			Draw.ring(ci, c, (rp + 1.4) * k, rim, 0.9 * k)
		Draw.glow_dot(ci, c, (0.8 + 0.4 * sin(t * 5.0)) * k, GOLD if gl3 else col)
	Draw.dyn(false)
