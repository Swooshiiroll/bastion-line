extends RefCounted
## Railgun art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_07_railgun.html, tools/tower_art/data_p2_railgun.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 capacitor coils, 1 longer rails, 2 penetrator tips) and the
## depth of each path, 5 on the path that took its mastery. a = Power, b = Range/Speed, c = Special Effects. `extra[0]` is the
## charge (0..1, how far the next shot has charged), `extra[1]` the shots fired and `extra[2]` the seconds since the last shot.
## The housing turns with the aim (baked) and recoils as a whole (Draw.shift); the charge glows, the spinning reel and the arc
## pylons' sparks are live.

const Draw = preload("res://scripts/view/Draw.gd")
const Gun = preload("res://scripts/view/towers/GunTurretArt.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const STEEL := Color(0.42, 0.45, 0.50)
const COPPER := Color(0.78, 0.50, 0.28)
const RED := Color(0.85, 0.20, 0.18)
const ORANGE := Color(1.0, 0.55, 0.20)
const TUNG := Color(0.20, 0.21, 0.24)
const BORE := Color(0.05, 0.05, 0.06)
## The housing kicks back this far (px) on each shot and returns over RECOIL_TIME seconds; twin rails recoil together.
const RECOIL := 2.5
const RECOIL_TIME := 0.3

# The owner's picks per step: Power, Range/Speed, Special Effects.
const PICKS := [["C", "B", "C", "B", "B"], ["C", "A", "B", "A", "A"], ["C", "B", "B", "A", "C"]]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "P": 0, "S": 0, "X": 0}
	return {"r": int(p[0]), "P": int(p[1]), "S": int(p[2]), "X": int(p[3])}


static func kp(L: Dictionary, pi: int, k: int) -> String:
	var d: int = [L.P, L.S, L.X][pi]
	return PICKS[pi][k] if d > k else ""


## Rail housings: width and [x, y] positions (one, or two with Twin Rails).
static func rails(L: Dictionary) -> Dictionary:
	if L.S >= 5:
		return {"w": 6.4, "pos": [Vector2(0, -3.5), Vector2(0, 3.5)], "clamps": true}
	return {"w": 8.0 + (1.2 if L.r == 1 else 0.0), "pos": [Vector2(0, 0)]}


static func length(L: Dictionary) -> float:
	return 24.0 + (4.0 if L.S >= 2 else 0.0) + (3.0 if L.r == 1 else 0.0)


static func at(c: Vector2, aim: float, k: float, x: float, y: float) -> Vector2:
	return Gun.at(c, aim, k, x, y)


## Where the slug leaves rail `i`.
static func muzzle(c: Vector2, aim: float, k: float, look: String, i: int) -> Vector2:
	var L := levels(look)
	var pos: Array = rails(L).pos
	var q: Vector2 = pos[i % pos.size()]
	return at(c, aim, k, q.x + length(L) + 2.0, q.y)


static func draw(ci: CanvasItem, c: Vector2, aim: float, s: float, t: float, flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s
	var ch: float = clampf(float(extra[0]), 0.0, 1.0) if extra.size() > 0 and extra[0] != null else 1.0
	var shots: int = int(extra[1]) if extra.size() > 1 and extra[1] != null else 0
	var since: float = float(extra[2]) if extra.size() > 2 and extra[2] != null else 9.0
	var T := rails(L)
	var pos: Array = T.pos
	var n := pos.size()
	var len := length(L)
	var w: float = T.w
	var gold: bool = L.P >= 5
	var col := acc
	var tc: Color = GOLD if gold else col
	var last := (shots - 1 + n * 1000) % n
	var fl := clampf(flash / 0.15, 0.0, 1.0)
	var colr: Color = TUNG if L.P >= 1 else Draw.METAL_L
	var ortho := Vector2.from_angle(aim).orthogonal()
	var kick := -Vector2.from_angle(aim) * RECOIL * maxf(0.0, 1.0 - since / RECOIL_TIME) * k
	Draw.dyn(true)
	Draw.shift(ci, kick)
	Draw.dyn(false)
	# --- The housings (baked, turning with the aim, recoiling together) ---
	for i in n:
		var xo: float = pos[i].x
		var y: float = pos[i].y
		var x0 := xo - 4.0
		var tel: bool = L.S >= 2
		var xe := xo + len - 4.0 if tel else xo + len
		var pt := func(x: float, yy: float) -> Vector2: return at(c, aim, k, x, y + yy)
		Draw.plate(ci, pt.call((x0 + xe) / 2.0, 0.0), Draw.rect_pts((xe - x0) / 2.0, w / 2.0), Draw.METAL, aim, k, 1.1)
		if tel:
			Draw.plate(ci, pt.call((xe + xo + len) / 2.0 - 0.2, 0.0), Draw.rect_pts((xo + len - xe) / 2.0 + 0.2, w * 0.35), Draw.METAL.lightened(0.06), aim, k, 1.1)
		Draw.line(ci, pt.call(x0, 0.0), pt.call(xe, 0.0), Color(Draw.METAL.darkened(0.3), 0.55), w * 0.3 * k)
		Draw.line(ci, pt.call(x0, 0.0) - ortho * w * 0.32 * k, pt.call(xe, 0.0) - ortho * w * 0.32 * k, Color(Draw.METAL.lightened(0.22), 0.8), w * 0.14 * k)
		# Power's marks: red bands (Armour Core), a white-hot tip, the Overcharge's arc pylons below.
		if L.P >= 2:
			for x in [xo + 12.0, xo + 13.6]:
				Draw.line(ci, pt.call(x, 0.0) + ortho * w * 0.54 * k, pt.call(x, 0.0) - ortho * w * 0.54 * k, RED, 1.0 * k)
		# Range/Speed: telescoping housing above; Rapid Capacitors' disc spine on the outer edge; field rings (Supercapacitors).
		if L.S >= 3:
			var sd := (1.0 if y > 0.0 else -1.0) if n > 1 else -1.0
			var edge := sd * w * 0.5
			Draw.bar(ci, pt.call(xo + 1.0, sd * (w * 0.5 + 0.6)), pt.call(xo + 14.0, sd * (w * 0.5 + 0.6)), 1.5 * k, Draw.METAL_D)
			for j in 5:
				var q: Vector2 = pt.call(xo + 2.0 + float(j) * 3.0, sd * (w * 0.5 + 1.5))
				Draw.line(ci, pt.call(xo + 2.0 + float(j) * 3.0, edge), q, Draw.METAL_D, 1.3 * k)
				Draw.disc(ci, q, 1.1 * k, Draw.OUTLINE)
				Draw.disc(ci, q, 0.8 * k, Draw.METAL_D)
		# Special Effects: the fracture lattice, the core feed port, the plasma tube's casing, the hot rail's edges.
		if L.X >= 1:
			for j in 5:
				var x := xo + len - 12.0 + float(j) * 2.0
				Draw.line(ci, pt.call(x, -w * 0.46), pt.call(x + 2.0, w * 0.46), Color(0, 0, 0, 0.6), 0.8 * k)
				Draw.line(ci, pt.call(x, w * 0.46), pt.call(x + 2.0, -w * 0.46), Color(0, 0, 0, 0.6), 0.8 * k)
		if L.X >= 2:
			Draw.plate(ci, pt.call(xo + 9.0, 0.0), Draw.rect_pts(2.0, w * 0.3), Draw.METAL_D, aim, k, 1.0)
		if L.X >= 3:
			var sd2 := (1.0 if y > 0.0 else -1.0) if n > 1 else 1.0
			Draw.bar(ci, pt.call(xo + 2.0, sd2 * w * 0.62), pt.call(xo + len - 3.0, sd2 * w * 0.62), 1.8 * k, Color(0.18, 0.22, 0.22))
		if L.X >= 4:
			for sg in [-1.0, 1.0]:
				Draw.line(ci, pt.call(xo - 2.0, sg * w * 0.5), pt.call(xo + len - 1.0, sg * w * 0.5), Color(ORANGE, 0.25), 3.0 * k)
				Draw.line(ci, pt.call(xo - 2.0, sg * w * 0.5), pt.call(xo + len - 1.0, sg * w * 0.5), Color(ORANGE, 0.95), 1.2 * k)
		if L.X >= 5:
			Draw.poly(ci, PackedVector2Array([pt.call(xo + len - 2.6, w * -0.34), pt.call(xo + len, w * -0.52), pt.call(xo + len, w * 0.52), pt.call(xo + len - 2.6, w * 0.34)]), GOLD)
		# Collars at 3, 10, 17 and one by the muzzle on longer housings.
		var xs: Array = [3.0, 10.0, 17.0]
		if len > 24.0:
			xs.append(len - 4.0)
		for x in xs:
			Draw.plate(ci, pt.call(xo + float(x), 0.0), Draw.rect_pts(1.2, w * 0.6), colr, aim, k, 1.0)
		if L.S >= 5:
			Draw.ring(ci, pt.call(xo + len + 0.4, 0.0), w * 0.68 * 0.38 * k, GOLD, 1.1 * k)
		if L.r == 0:
			for j in 5:
				var xx := xo + 2.0 + float(j) * 4.0
				Draw.line(ci, pt.call(xx, -w * 0.68 * 0.5), pt.call(xx + 1.6, w * 0.68 * 0.5), COPPER, 1.1 * k)
		# The mouth.
		var mp: Vector2 = pt.call(xo + len, 0.0)
		var ry := w * 0.5 * k * (0.7 if tel else 1.0)
		Draw.oval(ci, mp, ry * 0.5, ry * 1.04, aim, Draw.METAL_L.lightened(0.08), 1.2)
		Draw.oval(ci, mp + Vector2.from_angle(aim) * 0.5 * k, ry * 0.36, ry * 0.76, aim, BORE)
		if L.X >= 5:
			Draw.oval(ci, mp + Vector2.from_angle(aim) * 0.2 * k, ry * 0.62, ry * 1.06, aim, GOLD, 1.8)
			Draw.oval(ci, mp + Vector2.from_angle(aim) * 0.6 * k, ry * 0.36, ry * 0.76, aim, BORE)
	if L.S >= 5:
		for x in [3.0, 10.0, 17.0]:
			Draw.plate(ci, at(c, aim, k, x, 0.0), Draw.rect_pts(1.2, 3.5 + w * 0.62), colr, aim, k, 1.0)
	# --- Live, on the recoiling housing: the glow along it, the charge lights, the mouth's glow and the muzzle flash ---
	Draw.dyn(true)
	for i in n:
		var xo2: float = pos[i].x
		var y2: float = pos[i].y
		var a0 := at(c, aim, k, xo2 - 2.0, y2)
		var a1 := at(c, aim, k, xo2 + len - 1.0, y2)
		Draw.strip(ci, a0, a1, 0.8 * k * (0.8 if n > 1 else 1.0), Color(tc, minf(1.0, 0.2 + 0.6 * ch + 3.0 * (fl if i == last else 0.0))))
		if L.X >= 2:
			Draw.line(ci, at(c, aim, k, xo2 + 7.4, y2), at(c, aim, k, xo2 + 10.6, y2), Color(tc, 0.4 + 0.6 * ch), 1.1 * k)
		if L.X >= 3:
			var sd3 := (1.0 if y2 > 0.0 else -1.0) if n > 1 else 1.0
			var b0 := at(c, aim, k, xo2 + 2.0, y2 + sd3 * w * 0.62)
			var b1 := at(c, aim, k, xo2 + len - 3.0, y2 + sd3 * w * 0.62)
			for j in 5:
				Draw.glow_dot(ci, b0.lerp(b1, fmod(t * 0.9 + float(j) / 5.0, 1.0)), 0.5 * k, tc)
		if L.S >= 3:
			var sd4 := (1.0 if y2 > 0.0 else -1.0) if n > 1 else -1.0
			for j in 5:
				if ch * 5.0 > float(j):
					Draw.disc(ci, at(c, aim, k, xo2 + 2.0 + float(j) * 3.0, y2 + sd4 * (w * 0.5 + 1.5)), 0.8 * k, Color(tc, 0.95))
		if L.S >= 4:
			for x in [6.5, 13.5, 20.5]:
				var q2 := at(c, aim, k, xo2 + x, y2)
				Draw.line(ci, q2 + ortho * w * 0.56 * k, q2 - ortho * w * 0.56 * k, Color(tc, 0.3 + 0.7 * ch), 1.1 * k)
		if L.r == 0:
			for j in 5:
				if ch * 5.0 > float(j):
					var xx2 := xo2 + 2.0 + float(j) * 4.0
					Draw.line(ci, at(c, aim, k, xx2, y2 - w * 0.34), at(c, aim, k, xx2 + 1.6, y2 + w * 0.34), COPPER.lerp(col, 0.7), 1.1 * k)
		var ry := w * 0.5 * k * (0.7 if L.S >= 2 else 1.0)
		var mf := fl if i == last else 0.0
		Draw.oval(ci, at(c, aim, k, xo2 + len + 0.8, y2), ry * 0.22, ry * 0.5, aim, Color(tc, 0.3 + 0.7 * maxf(ch * 0.4, mf)))
		if mf > 0.0:
			Draw.glow_dot(ci, at(c, aim, k, xo2 + len + 1.5, y2), (1.2 + 5.0 * mf) * k, Color(tc, mf))
	Draw.shift(ci, Vector2.ZERO)
	Draw.dyn(false)
	# The capacitor drum above the housing (it stays put).
	var rd := 9.0 if n > 1 else 6.5
	var dr := at(c, aim, k, -8.0, 0.0)
	Draw.orb(ci, dr, rd * k, Draw.METAL_L, k)
	Draw.ring(ci, dr, rd * 0.68 * k, Draw.METAL_D, 1.6 * k)
	# --- Live: the charge ring, the reel, the pylons ---
	Draw.dyn(true)
	Draw.arc(ci, dr, rd * 0.68 * k, -PI / 2.0, -PI / 2.0 + TAU * ch, 24, Color(GOLD if (gold or L.S >= 5) else col, 0.95), 1.4 * k)
	if L.P >= 4:
		Draw.arc(ci, dr, rd * 0.9 * k, -PI / 2.0, -PI / 2.0 + TAU * ch, 24, Color(tc, 0.8), 1.0 * k)
	Draw.glow_dot(ci, dr, 1.4 * k, col)
	# The cable reel by the drum (Fast Capacitors), the arc pylons (Overcharge).
	if L.S >= 1:
		var rq := c + Vector2(-13.0, 10.5) * k
		Draw.disc(ci, rq, 3.4 * k, Draw.OUTLINE)
		Draw.disc(ci, rq, 3.0 * k, Draw.METAL_D)
		Draw.ring(ci, rq, 2.2 * k, Color(col, 0.3 + 0.5 * ch), 0.8 * k)
		var sp := t * (1.0 + 9.0 * ch)
		for j in 3:
			Draw.line(ci, rq + Vector2.from_angle(sp + float(j) * TAU / 3.0) * 0.6 * k, rq + Vector2.from_angle(sp + float(j) * TAU / 3.0) * 2.6 * k, Draw.METAL_L, 1.0 * k)
		Draw.orb(ci, rq, 0.9 * k, Draw.METAL, k)
		Draw.line(ci, rq + Vector2(2.4, -1.0) * k, dr, Color(0.15, 0.15, 0.18), 1.5 * k)
	if L.P >= 3:
		for sg in [-1.0, 1.0]:
			var pyl := at(c, aim, k, -14.5, sg * 9.5)
			Draw.bar(ci, pyl, at(c, aim, k, -14.5, sg * 12.0), 1.8 * k, Draw.METAL_L)
			Draw.disc(ci, at(c, aim, k, -14.5, sg * 9.0), 1.0 * k, Color(tc, 0.4 + 0.6 * ch))
			for j in 2:
				if ch > 0.15 + float(j) * 0.3:
					var tip := at(c, aim, k, -14.5, sg * 9.0)
					var mid := (tip + dr) * 0.5 + Vector2.from_angle(t * 14.0 + float(j) + sg * 5.0) * 1.6 * k
					Draw.polyline(ci, PackedVector2Array([tip, mid, dr + Vector2.from_angle(aim + (1.9 if sg > 0.0 else -1.9)) * 4.0 * k]), Color(tc, 0.5 + 0.5 * ch), 0.9 * k)
	Draw.dyn(false)
