extends RefCounted
## Tractor Tower art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_19_tractor.html, tools/tower_art/data_p2_tractor.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 beam sweep, 1 longer hold, 2 faster recharge) and the depth of each path,
## 5 on the path that took its mastery. a = Pull Distance (the emitter spike), b = Recharge (the base's cell ring), c = Grip (the dish's energy).
## The armoured dish and the spike turn with the aim (baked); the cells' charge, the focus arcs and the rewind coil are live.
## `extra` is [charge 0..1 (how far the next grab has recharged), holding 0/1].

const Draw = preload("res://scripts/view/Draw.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const STEEL := Color(0.42, 0.45, 0.50)
const COPPER := Color(0.78, 0.50, 0.28)
const ARMOUR := Color(0.36, 0.39, 0.44)
const HOTG := Color(1.0, 0.92, 0.60)
const DF := 10.0
const DR := 10.0
const DSPAN := 1.45
const DW := 2.0
const SB := 0.8
const SLEN := [13.4, 14.6, 15.6, 16.6, 17.6, 18.6]
const BASER := [9.4, 9.8, 10.2, 10.7, 11.1, 11.5]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "P": 0, "R": 0, "G": 0}
	return {"r": int(p[0]), "P": int(p[1]), "R": int(p[2]), "G": int(p[3])}


static func at(c: Vector2, aim: float, k: float, x: float, y: float) -> Vector2:
	return c + (Vector2.from_angle(aim) * x + Vector2.from_angle(aim).orthogonal() * y) * k


static func gl(col: Color, gold: bool, u := 0.75) -> Color:
	return col.lerp(GOLD, u) if gold else col


## Where the beam leaves: the antenna's tip.
static func muzzle(c: Vector2, aim: float, k: float, look: String) -> Vector2:
	return at(c, aim, k, float(SLEN[levels(look).P]) - 0.4, 0.0)


static func draw(ci: CanvasItem, c: Vector2, aim: float, s: float, t: float, _flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s
	var ch: float = clampf(float(extra[0]), 0.0, 1.0) if extra.size() > 0 and extra[0] != null else 1.0
	var on: float = float(extra[1]) if extra.size() > 1 and extra[1] != null else 0.0
	var col := acc
	var gp: bool = L.P >= 5
	var gr: bool = L.R >= 5
	var gg: bool = L.G >= 5
	var base_r: float = BASER[L.R]
	var gc: Color = GOLD if gr else col
	var len: float = SLEN[L.P]
	# --- The base: a round platform, a ring of recharge cells (lit live), the rams. ---
	Draw.plate(ci, c, Draw.ngon(32, 1.0, 0.0), GOLD.darkened(0.08) if gr else Draw.METAL, aim, base_r * k, 1.3)
	Draw.ring(ci, c, base_r * 0.72 * k, Color(Draw.OUTLINE, 0.35), 0.8 * k)
	Draw.rivets(ci, c, Draw.ngon(10, 1.0, 0.0), aim, base_r * k, 0.84, 0.7 * k)
	var ncell: int = 8 + 2 * int(L.R)
	var rr: float = base_r * 0.8
	if L.R > 0:
		for i in ncell:
			var a: float = aim + PI + (float(i) / float(ncell - 1) - 0.5) * 2.7
			Draw.plate(ci, c + Vector2.from_angle(a) * rr * k, Draw.rect_pts(0.8, 1.2 + 0.1 * float(L.R)), Draw.METAL_D, a, k, 0.8)
	for v in [-1.0, 1.0]:
		var a0: Vector2 = at(c, aim, k, -6.5, 3.6 * v)
		var a1: Vector2 = at(c, aim, k, 1.0, 4.4 * v)
		Draw.bar(ci, a0, a1, 2.6 * k, GOLD.darkened(0.3) if gr else Draw.METAL_D)
		Draw.bar(ci, at(c, aim, k, -2.5, 4.0 * v), a1, 1.3 * k, GOLD.lightened(0.2) if gr else Draw.METAL_L)
	# --- The dish, seen from straight above: a thick armoured band curved round its focus. ---
	var f := at(c, aim, k, DF, 0.0)
	var arm := gl(ARMOUR, gg, 0.5)
	var d0 := aim + PI - DSPAN
	var d1 := aim + PI + DSPAN
	Draw.arc(ci, f, DR * k, d0, d1, 20, Draw.OUTLINE, (DW + 1.6) * k)
	Draw.arc(ci, f, DR * k, d0, d1, 20, arm, DW * k)
	Draw.arc(ci, f, (DR - DW * 0.28) * k, d0 + 0.04, d1 - 0.04, 20, arm.lightened(0.14), DW * 0.38 * k)
	for i in 7:
		var a2 := d0 + float(i) * (d1 - d0) / 6.0
		Draw.line(ci, f + Vector2.from_angle(a2) * (DR - DW / 2.0) * k, f + Vector2.from_angle(a2) * (DR + DW / 2.0) * k, Color(Draw.OUTLINE, 0.7), 0.8 * k)
	for i in 6:
		var a3 := d0 + (float(i) + 0.5) * (d1 - d0) / 6.0
		Draw.disc(ci, f + Vector2.from_angle(a3) * (DR + DW * 0.28) * k, 0.55 * k, GOLD if gg else Draw.METAL_L)
	for a4 in [d0, d1]:
		Draw.disc(ci, f + Vector2.from_angle(a4) * DR * k, (DW / 2.0 + 0.5) * k, Draw.OUTLINE)
		Draw.disc(ci, f + Vector2.from_angle(a4) * DR * k, DW / 2.0 * k, arm)
	# Beam Sweep: sweep vanes at the dish's ends.
	if L.r == 0:
		for a5 in [d0, d1]:
			var vp: Vector2 = f + Vector2.from_angle(a5) * (DR + 1.8) * k
			Draw.plate(ci, vp, Draw.rect_pts(1.6, 0.6), Draw.METAL_L, a5, k, 0.8)
	# --- The spike: a slim rod from a hub to a feed head, with steel collars; longer each step, gold at Undo. ---
	var sc := gl(Draw.METAL_L, gp, 0.75)
	var mid := at(c, aim, k, SB + (len - 0.8 - SB) * 0.62, 0.0)
	for sg in [-1.0, 1.0]:
		var e: Vector2 = f + Vector2.from_angle(aim + PI + sg * 0.75) * (DR - DW / 2.0) * k
		Draw.line(ci, e, mid, Draw.OUTLINE, 1.5 * k)
		Draw.line(ci, e, mid, gl(Draw.METAL_L, gp, 0.6), 0.7 * k)
	Draw.bar(ci, at(c, aim, k, SB, 0.0), at(c, aim, k, len - 0.8, 0.0), 1.1 * k, sc)
	Draw.plate(ci, at(c, aim, k, SB + 0.9, 0.0), Draw.rect_pts(1.1, 2.6), gl(Draw.METAL_D, gp, 0.5), aim, k, 1.1)
	for i in L.P + 1:
		var x := SB + 2.0 + float(i) * (len - SB - 5.0) / maxf(1.0, float(L.P))
		Draw.plate(ci, at(c, aim, k, x, 0.0), Draw.rect_pts(0.45, 1.1), gl(STEEL, gp, 0.6), aim, k, 0.8)
	var tip := at(c, aim, k, len - 0.4, 0.0)
	var nib_gold: bool = gp or gg
	Draw.disc(ci, tip, 1.7 * k, Draw.OUTLINE)
	Draw.disc(ci, tip, 1.3 * k, GOLD if nib_gold else Draw.METAL)
	# --- Live: the cells lighting as it recharges, the dish's focus arcs and rim, the rewind coil, the nib's glow. ---
	Draw.dyn(true)
	if L.R > 0:
		for i in ncell:
			if (float(i) + 0.5) / float(ncell) <= ch:
				var a6: float = aim + PI + (float(i) / float(ncell - 1) - 0.5) * 2.7
				var q: Vector2 = c + Vector2.from_angle(a6) * rr * k
				Draw.plate(ci, q, Draw.rect_pts(0.8, 1.2 + 0.1 * float(L.R)), gc, a6, k, 0.8)
				Draw.glow_dot(ci, q, 0.35 * k, gc)
	var ec: Color = GOLD if gg else col
	if L.G > 0:
		var n := 1 + mini(L.G, 3)
		for i in n:
			var u := fmod(t * 0.8 + float(i) / float(n), 1.0)
			var rad := (DR - DW / 2.0 - 0.8) * (1.0 - 0.75 * u)
			var sp := DSPAN * (1.0 - 0.3 * u)
			Draw.arc(ci, f, rad * k, aim + PI - sp, aim + PI + sp, 14, Color(ec, 0.35 + 0.55 * u), (0.45 + 0.05 * float(L.G)) * k)
	Draw.arc(ci, f, (DR - DW / 2.0 - 0.3) * k, d0, d1, 20, Color(ec, 0.45 + 0.5 * on + 0.1 * sin(t * 4.0)), (1.2 + 0.12 * float(L.G)) * k)
	if L.P >= 3:
		var q2 := at(c, aim, k, SB + (len - SB) * 0.5, 0.0)
		var rcoil := 2.6 + 0.4 * float(mini(L.P, 4) - 3)
		Draw.ring(ci, q2, rcoil * k, Draw.OUTLINE, 2.0 * k)
		Draw.ring(ci, q2, rcoil * k, GOLD if gp else col.lightened(0.2), 1.1 * k)
		for i in 8:
			var a7 := -2.5 * t + float(i) * PI / 4.0
			Draw.line(ci, q2 + Vector2.from_angle(a7) * rcoil * 0.55 * k, q2 + Vector2.from_angle(a7) * rcoil * 0.85 * k, HOTG if gp else col, 0.8 * k)
	Draw.glow_dot(ci, tip, (0.6 + 0.8 * on) * k, GOLD if nib_gold else col)
	Draw.dyn(false)
