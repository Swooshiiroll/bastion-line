extends RefCounted
## Mortar Tower art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_02_mortar.html, tools/tower_art/data_p2_mortar.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c" (Tower.look_key): the Retrofit (-1 none, 0 field crate, 1 seismic probe, 2 smoke
## band) and the depth of each path, 5 on the path that took its mastery. a = Power, b = Speed/Range, c = Blast.
## Only the barrel(s) turn: the baseplate and the racks are fixed on the deck. The recoil is drawn as a muzzle flash and a
## puff of smoke (live); the tubes themselves stay in the cached layer.

const Draw = preload("res://scripts/view/Draw.gd")
const Gun = preload("res://scripts/view/towers/GunTurretArt.gd")

const STEEL := Color(0.42, 0.45, 0.50)
const COPPER := Color(0.78, 0.50, 0.28)
const RED := Color(0.85, 0.20, 0.18)
const DARKSHELL := Color(0.20, 0.20, 0.22)
const YEL := Color(1.0, 0.85, 0.20)
const SMOKE := Color(0.60, 0.62, 0.64)
const BORE := Color(0.05, 0.05, 0.06)
const GREEN := Color(0.40, 1.0, 0.50)
const MOUTH := 0.85
const RX := 1.4

# The owner's picks per step: Power, Speed/Range, Blast.
const PICKS := [["B", "A", "C", "A", "B"], ["C", "A", "C", "A", "B"], ["B", "B", "B", "B", "A"]]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "P": 0, "S": 0, "B": 0}
	return {"r": int(p[0]), "P": int(p[1]), "S": int(p[2]), "B": int(p[3])}


## The option used at path `pi`, step `k` ("" if not bought yet).
static func kp(L: Dictionary, pi: int, k: int) -> String:
	var d: int = [L.P, L.S, L.B][pi]
	return PICKS[pi][k] if d > k else ""


## Tube layout from Speed/Range: width and positions (x along the aim, y to the side).
static func tubes(L: Dictionary) -> Dictionary:
	if L.S >= 5:
		return {"w": 7.0, "pos": [Vector2(3, 0), Vector2(-3, -6.5), Vector2(-3, 6.5)]}
	if L.S >= 3:
		return {"w": 8.6, "pos": [Vector2(0, -5.5), Vector2(0, 5.5)], "cradle": true}
	return {"w": 11.0, "pos": [Vector2(0, 0)]}


static func tube_len(L: Dictionary) -> float:
	return 9.0 + (3.0 if L.S >= 2 else 0.0) + (2.5 if L.S >= 4 else 0.0)


static func at(c: Vector2, aim: float, k: float, x: float, y: float) -> Vector2:
	return Gun.at(c, aim, k, x, y)


static func ell(ci: CanvasItem, p: Vector2, rx: float, ry: float, a: float, col: Color, w: float) -> void:
	var pts := PackedVector2Array()
	for i in 21:
		var an := TAU * float(i) / 20.0
		pts.append(p + Vector2(cos(an) * rx, sin(an) * ry).rotated(a))
	Draw.polyline(ci, pts, col, w)


static func rack(ci: CanvasItem, c: Vector2, k: float, x: float, y: float, n: int, shell: Color, band: Color, has_band: bool, vertical: bool, nose: bool) -> void:
	var hw := 1.8 if vertical else float(n) * 1.6 + 0.6
	var hh := float(n) * 1.6 + 0.6 if vertical else 1.8
	Draw.plate(ci, at(c, 0.0, k, x, y), Draw.rect_pts(hw, hh), Draw.METAL_D, 0.0, k, 0.9)
	for i in n:
		var o := (float(i) - float(n - 1) / 2.0) * 3.0
		var q := at(c, 0.0, k, x, y + o) if vertical else at(c, 0.0, k, x + o, y)
		Draw.orb(ci, q, 1.3 * k, shell, k)
		if has_band:
			Draw.ring(ci, q, 0.8 * k, band, 0.7 * k)
		if nose:
			Draw.disc(ci, q + Vector2(0.5, -0.5) * k, 0.55 * k, Color(0.66, 0.69, 0.74))


static func grid_rack(ci: CanvasItem, c: Vector2, k: float, x: float, y: float, cols: int, rows: int, shell: Color) -> void:
	Draw.plate(ci, at(c, 0.0, k, x, y), Draw.rect_pts(float(cols) * 1.5 + 0.6, float(rows) * 1.5 + 0.6), Draw.METAL_D, 0.0, k, 0.9)
	for i in cols:
		for j in rows:
			Draw.orb(ci, at(c, 0.0, k, x + (float(i) - float(cols - 1) / 2.0) * 3.0, y + (float(j) - float(rows - 1) / 2.0) * 3.0), 1.3 * k, shell, k)


## The mouth of an angled tube seen from above.
static func bore(ci: CanvasItem, p: Vector2, k: float, f0: float, col: Color, L: Dictionary, flash: float, aim: float) -> void:
	var f := f0 * MOUTH
	var pm := kp(L, 0, 4)
	var x1 := kp(L, 2, 0)
	var p2 := kp(L, 0, 1)
	var s2 := kp(L, 1, 1)
	Draw.oval(ci, p, 3.9 * RX * k * f, 6.9 * k * f, aim, Draw.METAL_L, 1.2)
	Draw.oval(ci, p + Draw.LIGHT * 0.4 * k, 3.5 * k * f, 6.2 * k * f, aim, Draw.METAL_L.lightened(0.12))
	if x1 == "A":
		ell(ci, p, 3.6 * RX * k * f, 6.4 * k * f, aim, STEEL, 1.6 * k)
	if s2 == "C":
		for i in 8:
			var an := float(i) * TAU / 8.0
			Draw.line(ci, p + Vector2(cos(an) * 2.7 * RX * k * f, sin(an) * 4.6 * k * f).rotated(aim), p + Vector2(cos(an) * 3.6 * RX * k * f, sin(an) * 6.3 * k * f).rotated(aim), Color(0, 0, 0, 0.5), 1.0 * k)
	if pm == "B" or L.S >= 5:
		ell(ci, p, 3.5 * RX * k * f, 6.1 * k * f, aim, Draw.GOLD, 1.2 * k)
	Draw.oval(ci, p, 2.6 * RX * k * f, 4.5 * k * f, aim, BORE)
	if p2 == "B":
		ell(ci, p, 2.3 * RX * k * f, 3.9 * k * f, aim, COPPER, 0.9 * k)
	Draw.oval(ci, p, 1.9 * RX * k * f, 3.3 * k * f, aim, Color(col, 0.25 + 0.75 * flash))
	if flash > 0.0:
		Draw.glow_dot(ci, p, 3.2 * k * f * flash, col)


static func tube_shadow(ci: CanvasItem, c: Vector2, aim: float, k: float, x: float, y: float, len: float, w: float) -> void:
	Draw.line(ci, at(c, aim, k, x - 1.0, y) + Vector2(k, 2.0 * k), at(c, aim, k, x + len, y) + Vector2(3.0 * k, 5.0 * k), Color(0, 0, 0, 0.22), w * k)


static func angled_tube(ci: CanvasItem, c: Vector2, aim: float, k: float, x: float, y: float, len: float, w: float) -> void:
	var x0 := x - 1.0
	var x1 := x + len
	Draw.bar(ci, at(c, aim, k, x0, y), at(c, aim, k, x1, y), w * k, Draw.METAL_L)
	Draw.bar(ci, at(c, aim, k, x1 - 2.2, y - w * 0.56), at(c, aim, k, x1 - 2.2, y + w * 0.56), 1.6 * k, Draw.METAL_L.lightened(0.08))
	for sg in [-1.0, 1.0]:
		var tp := at(c, aim, k, x0 + (len + 1.0) * 0.3, y + sg * (w * 0.5 + 0.9))
		Draw.disc(ci, tp, 1.6 * k, Draw.OUTLINE)
		Draw.disc(ci, tp, 1.2 * k, STEEL)


## Where a shell leaves the tower: the mouth of tube `i`.
static func muzzle(c: Vector2, aim: float, k: float, look: String, i: int) -> Vector2:
	var L := levels(look)
	var T := tubes(L)
	var pos: Array = T.pos
	var q: Vector2 = pos[i % pos.size()]
	return at(c, aim, k, q.x + tube_len(L), q.y)


static func draw(ci: CanvasItem, c: Vector2, aim: float, s: float, t: float, flash: float, look: String, acc: Color) -> void:
	var L := levels(look)
	var k := s
	var T := tubes(L)
	var pos: Array = T.pos
	var n := pos.size()
	var len := tube_len(L)
	var f: float = float(T.w) / 11.0
	var w: float = float(T.w)
	var gold5: bool = L.B >= 5
	# The stationary baseplate.
	Draw.plate(ci, c, Draw.ngon(8, 1.0, PI / 8.0), Draw.METAL, 0.0, 9.5 * k, 1.2)
	Draw.rivets(ci, c, Draw.ngon(8, 1.0, PI / 8.0), 0.0, 9.5 * k, 0.84, 0.7 * k)
	for i in n:
		tube_shadow(ci, c, aim, k, pos[i].x, pos[i].y, len, 11.0 * f)
	# Racks show the current shells: Power restyles them; Power's own rack appears only when there's none.
	var shell: Color = Draw.GOLD if gold5 else (DARKSHELL if L.P >= 3 else Draw.METAL_L)
	var band: Color = Color(0.42, 0.42, 0.44) if L.r == 2 else YEL
	var has_band: bool = L.r == 2 or L.P >= 3
	var nose: bool = L.P >= 2
	var ready: bool = L.S >= 1
	var field: bool = L.r == 0
	if ready:
		rack(ci, c, k, -12.5, 4.5, 3, shell, band, has_band, true, nose)
	if field:
		Draw.plate(ci, at(c, 0.0, k, 0.0, -12.5), Draw.rect_pts(5.4, 2.4), Color(0.5, 0.42, 0.28), 0.0, k, 1.0)
		rack(ci, c, k, 0.0, -12.5, 3, shell, band, has_band, false, nose)
	if not ready and not field and L.P >= 2:
		rack(ci, c, k, -12.5, -4.5, 3 if L.P >= 3 else 2, shell, band, has_band, true, nose)
	if L.B >= 3:
		grid_rack(ci, c, k, 12.5, 0.0, 2 if L.B >= 4 else 1, 4 if L.B >= 5 else 3, Draw.GOLD if gold5 else Color(0.5, 0.52, 0.48))
	if L.r == 1:
		var q := at(c, 0.0, k, 10.0, -11.0)
		Draw.bar(ci, q, at(c, 0.0, k, 10.0, -7.5), 1.0 * k, Draw.METAL_L)
		Draw.dyn(true)
		var ph := fmod(t, 1.0)
		Draw.glow_dot(ci, q, (1.0 if fmod(t * 1.2, 1.0) < 0.3 else 0.5) * k, GREEN)
		Draw.ring(ci, q, ph * 5.0 * k, Color(GREEN, 0.5 * (1.0 - ph)), 1.0)
		Draw.dyn(false)
	if T.get("cradle", false):
		Draw.plate(ci, c, Draw.rect_pts(4.0, 9.5), Draw.METAL_L, aim, k, 1.0)
		Draw.orb(ci, at(c, aim, k, -4.0, 0.0), 1.6 * k, Draw.METAL, k)
		Draw.glow_dot(ci, at(c, aim, k, -3.4, 0.0), 0.6 * k, acc)
	# The tubes, each with the same kit.
	for i in n:
		var x: float = pos[i].x
		var y: float = pos[i].y
		angled_tube(ci, c, aim, k, x, y, len, w)
		var tb := func(fr: float) -> Vector2: return at(c, aim, k, x - 1.0 + (len + 1.0) * fr, y)
		var ortho := Vector2.from_angle(aim).orthogonal()
		if kp(L, 0, 0) == "B":
			ell(ci, tb.call(1.0), 4.1 * RX * k * f * MOUTH, 7.1 * k * f * MOUTH, aim, STEEL, 1.8 * k)
		if kp(L, 0, 3) == "A":
			var lp: Vector2 = tb.call(0.4) - ortho * w * 0.62 * k
			Draw.plate(ci, lp, Draw.rect_pts(1.4, 1.0), Draw.METAL_D, aim, k, 0.8)
			Draw.glow_dot(ci, lp, 0.5 * k, RED)
		if kp(L, 2, 1) == "B":
			for j in range(1, 4):
				Draw.line(ci, tb.call(float(j) * 0.22), tb.call(float(j) * 0.22 + 0.08), Color(0, 0, 0, 0.35), w * 0.9 * k)
		if L.r == 0 and i == 0:
			Draw.bar(ci, tb.call(0.3) - ortho * w * 0.55 * k, tb.call(0.75) - ortho * w * 0.55 * k, 1.1 * k, Draw.METAL_D)
		bore(ci, tb.call(1.0), k, f, acc, L, 0.0, aim)
	# The muzzle flash and the puff: live.
	Draw.dyn(true)
	if flash > 0.0:
		var fl := clampf(flash / 0.12, 0.0, 1.0)
		for i in n:
			var mp := muzzle(c, aim, k, look, i)
			Draw.disc(ci, mp, 4.0 * k * fl, Color(1.0, 0.85, 0.5, 0.8 * fl))
			Draw.disc(ci, mp + Vector2(0, -3.0 * k), (2.0 + 3.0 * (1.0 - fl)) * k, Color(0.85, 0.88, 0.9, 0.35 * fl))
	Draw.dyn(false)
