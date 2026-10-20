extends RefCounted
## Scrapyard art (tower rework, issue #59): the confirmed production line (design/tower_art_p2_17_scrap.html,
## tools/tower_art/data_p2_scrap.js), drawn as a summary: a 2x2 yard with a furnace stack (path a, Passive Income), a junkyard with a crane
## (path b, Kill Income) and a warehouse (path c, Discounts), each rebuilt bigger at every step and gold at its mastery, with the
## Retrofit's hammer mill, second conveyor and crane, or extra crates. Not every per-option detail of the page is drawn.
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 hammer mill, 1 faster loading, 2 surplus) and the depth of each
## path, 5 on the path that took its mastery. The scale is a 2x2 tower's: one unit here is a screen pixel at 48 px per tile.

const Draw = preload("res://scripts/view/Draw.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const RUST := Color(0.45, 0.30, 0.20)
const BRICK := Color(0.55, 0.27, 0.20)
const MOLTEN := Color(1.0, 0.55, 0.15)
const HOTM := Color(1.0, 0.85, 0.45)
const WOOD := Color(0.60, 0.43, 0.24)
const CONC := Color(0.29, 0.29, 0.30)
const ROOF := Color(0.44, 0.47, 0.50)
const DOOR := Color(0.80, 0.58, 0.20)
const CRANE := Color(0.92, 0.70, 0.20)
const LASER := Color(1.0, 0.22, 0.18)
const KILL := Color(1.0, 0.50, 0.20)
const DISCC := Color(0.45, 0.82, 0.95)
const STACKR := [14.0, 14.5, 15.0, 16.0, 16.5, 17.0]
const LOADS := [Color(0.35, 0.55, 0.80), Color(0.40, 0.65, 0.40), Color(0.75, 0.45, 0.30), Color(0.85, 0.70, 0.30)]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "I": 0, "K": 0, "D": 0}
	return {"r": int(p[0]), "I": int(p[1]), "K": int(p[2]), "D": int(p[3])}


static func gl(col: Color, gold: bool, u := 0.75) -> Color:
	return col.lerp(GOLD, u) if gold else col


static func scrap_pile(ci: CanvasItem, p: Vector2, r: float, k: float, seed: int, gold: bool) -> void:
	var pts := PackedVector2Array()
	for i in 9:
		var a := float(i) * TAU / 9.0
		pts.append(Vector2(cos(a), sin(a)) * r * (0.65 + 0.35 * fmod(absf(sin(float(seed + i) * 12.9898) * 43758.5453), 1.0)))
	Draw.ellipse(ci, p + Vector2(k * 1.5, k * 2.5), r * k, r * k * 0.5, Color(0, 0, 0, 0.3))
	Draw.solid(ci, p, pts, gl(RUST.lerp(Draw.METAL, 0.4), gold, 0.55), 0.0, k, 1.0)
	for i in 5:
		var q := p + Vector2(float(i) - 2.0, float(i % 3) - 1.0) * r * k * 0.28
		Draw.line(ci, q, q + Vector2.from_angle(float(i) * 1.7) * r * k * 0.35, (HOTM if i % 2 == 1 else GOLD) if gold else (Draw.METAL_L if i % 2 == 1 else RUST), 1.4 * k)


static func crate_stack(ci: CanvasItem, p: Vector2, cols: int, rows: int, k: float, gold: bool) -> void:
	var w := gl(WOOD, gold, 0.6)
	for r in rows:
		for q in cols:
			var c := p + Vector2((float(q) - float(cols - 1) / 2.0) * 6.4, (float(r) - float(rows - 1) / 2.0) * 6.4) * k
			Draw.plate(ci, c, Draw.rect_pts(2.9, 2.9), w, 0.0, k, 1.0)
			Draw.line(ci, c + Vector2(-2.2, -2.2) * k, c + Vector2(2.2, 2.2) * k, w.darkened(0.35), 0.8 * k)


static func conveyor(ci: CanvasItem, a: Vector2, b: Vector2, t: float, k: float, gold: bool) -> void:
	var d := (b - a).normalized()
	var n := d.orthogonal()
	var len := a.distance_to(b)
	Draw.line(ci, a, b, Draw.OUTLINE, 8.0 * k)
	Draw.line(ci, a, b, GOLD.darkened(0.15) if gold else Draw.METAL, 6.6 * k)
	Draw.line(ci, a, b, Color(0.14, 0.13, 0.12), 4.2 * k)
	for j in int(len / (3.0 * k)):
		var u := fmod(float(j) * 3.0 * k / len + t * 0.35, 1.0)
		var q := a.lerp(b, u)
		Draw.line(ci, q + n * 2.0 * k, q - n * 2.0 * k, Color(0.42, 0.40, 0.37), 0.9 * k)
	for e in [a, b]:
		Draw.disc(ci, e, 3.4 * k, Draw.OUTLINE)
		Draw.disc(ci, e, 2.7 * k, GOLD if gold else Draw.METAL_L)


static func draw(ci: CanvasItem, c: Vector2, _aim: float, s: float, t: float, _flash: float, look: String, acc: Color, _extra: Array) -> void:
	var L := levels(look)
	var k := s / 1.8
	var gi: bool = L.I >= 5
	var gk: bool = L.K >= 5
	var gd: bool = L.D >= 5
	var fixed := func(x: float, y: float) -> Vector2: return c + Vector2(x, y) * k
	# The yard floor, a 2x2 slab with a grid.
	Draw.ellipse(ci, c + Vector2(0, 8.0 * k), 44.0 * k, 16.0 * k, Color(0, 0, 0, 0.3))
	Draw.plate(ci, c, Draw.rect_pts(46.0, 46.0), Draw.METAL_D.lightened(0.04), 0.0, k, 1.3)
	Draw.fill(ci, c, Draw.rect_pts(44.0, 44.0), CONC, 0.0, k)
	for i in range(-3, 4):
		Draw.line(ci, c + Vector2(float(i) * 12.0, -44.0) * k, c + Vector2(float(i) * 12.0, 44.0) * k, Color(0, 0, 0, 0.1), 0.8 * k)
		Draw.line(ci, c + Vector2(-44.0, float(i) * 12.0) * k, c + Vector2(44.0, float(i) * 12.0) * k, Color(0, 0, 0, 0.1), 0.8 * k)
	# The conveyors: scrap from the junkyard up to the furnace, ingots on to the warehouse (a second pair with Faster Loading).
	Draw.dyn(true)
	conveyor(ci, fixed.call(-26.0, 20.0), fixed.call(-8.0, -2.0), t, k * 0.8, gi or gk)
	conveyor(ci, fixed.call(8.0, -2.0), fixed.call(26.0, 20.0), t, k * 0.8, gi or gd)
	if L.r == 1:
		conveyor(ci, fixed.call(-30.0, 8.0), fixed.call(-12.0, -8.0), t + 0.4, k * 0.6, gk)
	Draw.dyn(false)
	# The junkyard (path b): a scrap pile that grows with a crane, a magnet, a laser cutter, a crusher and wrecks.
	var jy: Vector2 = fixed.call(-22.0, 24.0)
	scrap_pile(ci, jy, 10.0 + float(L.K), k, 3, gk)
	if L.K >= 1:
		Draw.bar(ci, jy + Vector2(8, -2) * k, jy + Vector2(8, -22) * k, 2.2 * k, gl(CRANE, gk, 0.5))
		Draw.bar(ci, jy + Vector2(8, -22) * k, jy + Vector2(-6, -16) * k, 1.8 * k, gl(CRANE, gk, 0.5))
		Draw.disc(ci, jy + Vector2(-6, -12) * k, 2.0 * k if L.K < 2 else 3.0 * k, Draw.OUTLINE)
		Draw.disc(ci, jy + Vector2(-6, -12) * k, 1.4 * k if L.K < 2 else 2.4 * k, STEEL_OR_GOLD(gk))
	if L.K >= 3:
		Draw.line(ci, jy + Vector2(-6, -12) * k, jy + Vector2(-6, 0) * k, Color(LASER, 0.35), 3.0 * k)
	if L.K >= 4:
		Draw.plate(ci, jy + Vector2(-12, 6) * k, Draw.rect_pts(5.0, 3.0), gl(RUST, gk, 0.4), 0.0, k, 1.2)
		Draw.plate(ci, jy + Vector2(-12, 2) * k, Draw.rect_pts(5.0, 1.0), Draw.METAL, 0.0, k, 1.0)
	# The furnace stack (path a): a brick drum with bands, taller each step, two hot-blast stoves from Blast Furnace, gold at the Foundry.
	var sp: Vector2 = fixed.call(0.0, -8.0)
	var r: float = STACKR[L.I] * k * 0.8
	var shell := gl(BRICK, gi, 0.55)
	Draw.disc(ci, sp + Vector2(r * 0.5, r * 0.6), r * 1.05, Color(0, 0, 0, 0.32))
	if L.I >= 3:
		for sx in [-1.0, 1.0]:
			var q: Vector2 = sp + Vector2(sx * 9.0, -16.0) * k * 0.8
			Draw.bar(ci, q, sp + Vector2(sx * 4.0, -r * 0.6), 2.6 * k * 0.8, gl(Draw.METAL.lightened(0.3), gi, 0.7))
			Draw.disc(ci, q, 6.2 * k * 0.8 + 1.0, Draw.OUTLINE)
			Draw.disc(ci, q, 6.2 * k * 0.8, gl(Draw.METAL.lightened(0.3), gi, 0.7))
	if L.I >= 2:
		Draw.disc(ci, sp + Vector2(-r - 4.0 * k, 2.0 * k), 4.0 * k + 1.0, Draw.OUTLINE)
		Draw.disc(ci, sp + Vector2(-r - 4.0 * k, 2.0 * k), 4.0 * k, Draw.METAL_D)
	Draw.orb(ci, sp, r, shell, k)
	for i in 1 + mini(L.I, 4):
		Draw.ring(ci, sp, r * (0.4 + 0.15 * float(i)), (GOLD if gi else Draw.METAL), 1.2 * k)
	Draw.disc(ci, sp, r * 0.34, Color(0.08, 0.05, 0.03))
	# The warehouse (path c): a roofed building with a loading door; racks, a forklift, a dock and gold at the Exchange.
	var wp: Vector2 = fixed.call(22.0, 24.0)
	var wsize := 9.0 + float(L.D) * 0.6
	Draw.plate(ci, wp, Draw.rect_pts(wsize, 7.0), gl(ROOF, gd, 0.5), 0.0, k, 1.3)
	Draw.plate(ci, wp + Vector2(0, 5.0) * k, Draw.rect_pts(3.4, 2.0), gl(DOOR, gd, 0.4), 0.0, k, 1.0)
	for i in mini(L.D, 4):
		Draw.rect(ci, Rect2(wp.x - (wsize - 2.0 - float(i) * 4.0) * k, wp.y - 6.0 * k, 3.0 * k, 3.0 * k), LOADS[i])
	if L.D >= 3:
		Draw.plate(ci, wp + Vector2(-wsize - 4.0, 10.0) * k, Draw.rect_pts(2.2, 1.6), CRANE, 0.0, k, 1.0)
	if L.D >= 4:
		Draw.plate(ci, wp + Vector2(wsize + 6.0, 4.0) * k, Draw.rect_pts(6.0, 3.4), Draw.METAL_L, 0.0, k, 1.2)
	# The Retrofit: a hammer mill beside the furnace, or two extra crates left of the crate stack.
	if L.r == 0:
		Draw.plate(ci, fixed.call(-30.0, -20.0), Draw.rect_pts(5.0, 4.0), Draw.METAL_L, 0.0, k, 1.2)
		Draw.bar(ci, fixed.call(-30.0, -20.0), fixed.call(-30.0, -28.0), 1.8 * k, Draw.METAL)
	if L.r == 2:
		crate_stack(ci, fixed.call(-36.0, -28.0), 1, 2, k, false)
	crate_stack(ci, fixed.call(32.0, -26.0), 2, 2, k, gd)
	# Live: the flare and the vented coins at the stack's top, a pulse on the warehouse door.
	Draw.dyn(true)
	var fl := 0.5 + 0.5 * sin(t * 6.3) * sin(t * 2.1 + 1.0)
	Draw.glow_dot(ci, sp, (3.0 + 2.0 * fl) * k, MOLTEN.lerp(GOLD, 0.6) if gi else MOLTEN)
	if L.I >= 1:
		for i in 3:
			var u := fmod(t * 0.4 + float(i) / 3.0, 1.0)
			Draw.disc(ci, sp + Vector2(sin(float(i) * 2.0) * 3.0, -r * 0.5 - u * 14.0 * k), 1.6 * k, Color(GOLD, 0.8 * (1.0 - u)))
	if L.K >= 3:
		Draw.glow_dot(ci, jy + Vector2(-6, -12) * k, (1.0 + 0.4 * sin(t * 9.0)) * k, LASER)
	Draw.dyn(false)


static func STEEL_OR_GOLD(gold: bool) -> Color:
	return GOLD if gold else Color(0.42, 0.45, 0.50)
