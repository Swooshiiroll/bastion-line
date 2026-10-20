extends RefCounted
## Artillery Cannon art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_06_artillery.html, tools/tower_art/data_p2_artillery.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 shell magazine, 1 stabilised mount, 2 wide charge) and the
## depth of each path, 5 on the path that took its mastery. a = Power, b = Speed, c = Special Effects. The deck kit is fixed and
## cached (this tower is not turned by the cache); only the barrel and its breech parts turn, so they are drawn live.
## `extra` is [shell type index, shots fired] for the selector needle and the heavy-round light.

const Draw = preload("res://scripts/view/Draw.gd")
const Gun = preload("res://scripts/view/towers/GunTurretArt.gd")

const STEEL := Color(0.42, 0.45, 0.50)
const GOLD := Color(1.0, 0.78, 0.30)
const RED := Color(0.85, 0.20, 0.18)
const ORANGE := Color(1.0, 0.55, 0.20)
const YEL := Color(1.0, 0.85, 0.20)
const DARKSHELL := Color(0.20, 0.20, 0.22)
const FIRE := Color(1.0, 0.45, 0.12)
const CONC := Color(0.55, 0.85, 1.0)
const SHRAP := Color(0.82, 0.80, 0.72)
const AMMO := Color(0.35, 0.36, 0.30)
const GREEN := Color(0.40, 1.0, 0.50)

# The owner's picks per step: Power, Speed, Special Effects.
const PICKS := [["A", "B", "A", "C", "B"], ["A", "A", "A", "C", "A"], ["B", "B", "C", "C", "A"]]
const TYPE_COLORS := {"he": Color(0.8, 0.8, 0.8), "incendiary": FIRE, "shrapnel": SHRAP, "concussion": CONC, "combined": GOLD}
const BARREL := 25.0


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "P": 0, "S": 0, "X": 0}
	return {"r": int(p[0]), "P": int(p[1]), "S": int(p[2]), "X": int(p[3])}


static func kp(L: Dictionary, pi: int, k: int) -> String:
	var d: int = [L.P, L.S, L.X][pi]
	return PICKS[pi][k] if d > k else ""


static func at(c: Vector2, aim: float, k: float, x: float, y: float) -> Vector2:
	return Gun.at(c, aim, k, x, y)


static func fixed(c: Vector2, k: float, x: float, y: float) -> Vector2:
	return c + Vector2(x, y) * k


static func body_color(L: Dictionary) -> Color:
	return GOLD if L.P >= 5 else (DARKSHELL if L.P >= 3 else Draw.METAL_L)


## The shell types in the order the selector lists them: the Special path unlocks one more per step.
static func types(L: Dictionary) -> Array:
	var out: Array = ["he"]
	for i in mini(3, L.X):
		out.append(["incendiary", "shrapnel", "concussion"][i])
	if L.X >= 5:
		out.append("combined")
	return out


static func muzzle(c: Vector2, aim: float, k: float) -> Vector2:
	return at(c, aim, k, BARREL + 2.0, 0.0)


## One shell in a tray: round, or long and slim with a steel tip (Long Penetrators).
static func tray_shell(ci: CanvasItem, q: Vector2, k: float, L: Dictionary) -> void:
	var body := body_color(L)
	var r := 1.4 * k * (1.15 if L.P >= 1 else 1.0) * (1.2 if L.r == 2 else 1.0)
	if kp(L, 0, 3) == "C":
		Draw.bar(ci, q + Vector2(0, 1.6 * k), q + Vector2(0, -1.0 * k), r * 0.95, body)
		Draw.poly(ci, PackedVector2Array([q + Vector2(0, -2.5 * k), q + Vector2(-0.6 * k, -1.0 * k), q + Vector2(0.6 * k, -1.0 * k)]), STEEL)
		if L.P >= 3:
			Draw.line(ci, q + Vector2(-r * 0.5, 0.3 * k), q + Vector2(r * 0.5, 0.3 * k), YEL, 0.6 * k)
	else:
		Draw.orb(ci, q, r, body, k)
		if L.P >= 3:
			Draw.ring(ci, q, r * 0.7, YEL, 0.6 * k)
	if L.P >= 5:
		Draw.ring(ci, q, r * 0.5, GOLD, 0.6 * k)


static func draw(ci: CanvasItem, c: Vector2, aim: float, s: float, t: float, flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s
	var shell_i: int = int(extra[0]) if extra.size() > 0 and extra[0] != null else 0
	var shots: int = int(extra[1]) if extra.size() > 1 and extra[1] != null else 0
	var tys := types(L)
	var fl := clampf(flash / 0.15, 0.0, 1.0)
	var rc := fl * 3.5
	# --- The fixed deck kit (cached): tray, loader post, stabilisers, crates, selector dial. ---
	if L.S < 3:
		Draw.plate(ci, fixed(c, k, -6.0, -9.0), Draw.rect_pts(5.4, 2.4), AMMO, 0.0, k, 0.9)
		for i in 3:
			tray_shell(ci, fixed(c, k, -6.0 + (float(i) - 1.0) * 3.0, -9.0), k, L)
	if L.S >= 1:
		Draw.orb(ci, fixed(c, k, -8.0, 10.0), 1.6 * k, Draw.METAL, k)
	if L.S >= 5:
		for i in 3:
			Draw.glow_dot(ci, fixed(c, k, -14.0 + float(i) * 2.6, 12.2), 0.7 * k, GOLD)
	if L.X >= 1:
		var q := fixed(c, k, 12.0, 10.0)
		var big := 5.6 if L.X >= 5 else 4.2
		Draw.disc(ci, q, big * k, Draw.OUTLINE)
		Draw.disc(ci, q, (big - 0.6) * k, Draw.METAL_D)
		for i in tys.size():
			var a := -PI / 2.0 + float(i) * TAU / float(tys.size())
			Draw.glow_dot(ci, q + Vector2.from_angle(a) * (big - 1.6) * k, 0.8 * k, TYPE_COLORS[tys[i]])
		if L.X >= 5:
			Draw.ring(ci, q, big * k, GOLD, 1.2 * k)
	if kp(L, 2, 3) == "C":
		Draw.plate(ci, fixed(c, k, 14.0, 3.0), Draw.rect_pts(2.6, 2.0), Draw.METAL_D, 0.0, k, 1.0)
		for i in 3:
			Draw.line(ci, fixed(c, k, 12.8, 2.2 + float(i) * 0.8), fixed(c, k, 15.2, 2.2 + float(i) * 0.8), Color(GREEN, 0.8), 0.6 * k)
	if L.r == 1:
		for xy in [Vector2(-14, -12), Vector2(14, -12), Vector2(-14, 12), Vector2(14, 12)]:
			Draw.bar(ci, fixed(c, k, xy.x * 0.6, xy.y * 0.6), fixed(c, k, xy.x, xy.y), 1.6 * k, Draw.METAL)
			Draw.plate(ci, fixed(c, k, xy.x, xy.y), Draw.rect_pts(2.0, 2.0), Draw.METAL_L, 0.0, k, 1.0)
	if L.r == 2:
		Draw.plate(ci, fixed(c, k, 14.0, -9.0), Draw.rect_pts(3.0, 2.4), Draw.METAL_D, 0.0, k, 1.0)
		Draw.orb(ci, fixed(c, k, 13.0, -9.0), 1.6 * k, body_color(L), k)
		Draw.orb(ci, fixed(c, k, 15.4, -9.0), 1.6 * k, body_color(L), k)
	# --- Live: the parts that turn or move with each shot. ---
	Draw.dyn(true)
	if L.S >= 1:
		var base := fixed(c, k, -8.0, 10.0)
		Draw.bar(ci, base, base + Vector2.from_angle(PI * 1.25 + fl * 1.1) * 8.0 * k, 1.4 * k, Draw.METAL_L)
	if L.S >= 3:
		var q2 := fixed(c, k, -6.0, -9.0)
		Draw.disc(ci, q2, 5.0 * k, Draw.OUTLINE)
		Draw.disc(ci, q2, 4.4 * k, Draw.METAL_D)
		for i in 6:
			Draw.orb(ci, q2 + Vector2.from_angle(float(i) * TAU / 6.0 + t * 0.6) * 3.0 * k, 1.2 * k, body_color(L), k)
		Draw.disc(ci, q2, 1.2 * k, Draw.METAL_L)
	if L.S >= 5:
		for y in [-3.2, 0.0, 3.2]:
			Draw.bar(ci, fixed(c, k, -15.0, y), fixed(c, k, -6.0 - 4.0 * fl, y), 1.0 * k, GOLD)
	if L.X >= 1:
		var dial := fixed(c, k, 12.0, 10.0)
		var big2 := 5.6 if L.X >= 5 else 4.2
		var idx := clampi(shell_i, 0, tys.size() - 1)
		Draw.line(ci, dial, dial + Vector2.from_angle(-PI / 2.0 + float(idx) * TAU / float(tys.size())) * (big2 - 1.2) * k, Color(1, 1, 1), 1.0 * k)
	if L.r == 0:
		var mq := fixed(c, k, -13.0, -3.0)
		Draw.disc(ci, mq, 3.6 * k, Draw.OUTLINE)
		Draw.disc(ci, mq, 3.0 * k, Draw.METAL_D)
		for i in 5:
			Draw.orb(ci, mq + Vector2.from_angle(float(i) * TAU / 5.0 + t * 0.4) * 1.9 * k, 0.9 * k, body_color(L), k)
		for i in 3:
			Draw.glow_dot(ci, mq + Vector2(4.4 * k, (float(i) - 1.0) * 1.8 * k), 0.5 * k, RED if i == shots % 3 else Color(0.35, 0.18, 0.18))
	# The rammer, cradle and barrel, turning with the aim.
	var rr := 6.0 * fl
	var rods: Array = [-2.0, 2.0] if L.S >= 3 else [0.0]
	for y in rods:
		Draw.bar(ci, at(c, aim, k, -15.0, y), at(c, aim, k, -6.0 - rr * 0.5, y), 1.6 * k, Draw.METAL_L)
	Draw.plate(ci, at(c, aim, k, -15.0, 0.0), Draw.rect_pts(1.6, 4.6 if L.S >= 3 else 3.0), Draw.METAL_D, aim, k, 0.9)
	if L.S >= 4:
		for y in rods:
			for i in 4:
				Draw.line(ci, at(c, aim, k, -14.0 + float(i) * 2.0, y - 1.4), at(c, aim, k, -13.0 + float(i) * 2.0, y + 1.4), STEEL, 0.9 * k)
	Draw.plate(ci, at(c, aim, k, -3.0, 0.0), Draw.rect_pts(13.0, 4.2), Draw.METAL, aim, k, 1.1)
	if L.P >= 1:
		Draw.plate(ci, at(c, aim, k, -12.0, 0.0), Draw.rect_pts(2.6, 5.2), Draw.METAL_D, aim, k, 1.1)
	if L.S >= 2:
		for sg in [-1.0, 1.0]:
			Draw.bar(ci, at(c, aim, k, -14.0, sg * 5.0), at(c, aim, k, -8.0 - fl * 2.0, sg * 5.0), 1.6 * k, STEEL)
			Draw.orb(ci, at(c, aim, k, -14.0, sg * 5.0), 1.0 * k, Draw.METAL, k)
	var x0 := -rc
	var x1 := BARREL - rc
	Draw.bar(ci, at(c, aim, k, x0, 0.0), at(c, aim, k, x1, 0.0), 3.8 * k, Draw.METAL_L)
	Draw.bar(ci, at(c, aim, k, x0, 0.0), at(c, aim, k, 10.0 - rc, 0.0), 5.2 * k, Draw.METAL)
	var ortho := Vector2.from_angle(aim).orthogonal()
	var cross := func(x: float, w: float, col: Color, lw: float) -> void:
		var q := at(c, aim, k, x - rc, 0.0)
		Draw.line(ci, q + ortho * w * k, q - ortho * w * k, col, lw * k)
	if L.S < 4:
		for x in [8.0, 14.0]:
			cross.call(x, 1.9, Draw.METAL_D.lightened(0.15), 1.4)
	if L.P >= 3:
		cross.call(11.0, 2.1, YEL, 1.3)
	if L.P >= 2:
		Draw.plate(ci, at(c, aim, k, 16.0 - rc, 0.0), Draw.rect_pts(4.0, 2.4), DARKSHELL, aim, k, 1.0)
		for i in 3:
			cross.call(13.0 + float(i) * 3.0, 2.3, Color(0, 0, 0, 0.5), 0.8)
	if L.P >= 4:
		Draw.plate(ci, at(c, aim, k, 4.0 - rc, 0.0), Draw.rect_pts(1.6, 3.1), STEEL, aim, k, 1.0)
	if L.P >= 5 or L.S >= 5:
		Draw.plate(ci, at(c, aim, k, 23.5 - rc, 0.0), Draw.rect_pts(1.3, 3.3), GOLD, aim, k, 1.0)
	if kp(L, 2, 0) == "B":
		for i in 4:
			var q2 := at(c, aim, k, 15.0 + float(i) * 1.6 - rc, 0.0)
			var sgn := 1.0 if i % 2 == 1 else -1.0
			Draw.line(ci, q2 + ortho * 2.0 * k * sgn, q2 - ortho * 2.0 * k * sgn, ORANGE, 0.9 * k)
	Draw.plate(ci, at(c, aim, k, 25.5 - rc, 0.0), Draw.rect_pts(1.8, 3.0), Draw.METAL, aim, k, 1.0)
	if fl > 0.0:
		var mp := at(c, aim, k, 27.0 - rc, 0.0)
		var tc: Color = TYPE_COLORS[tys[clampi(shell_i, 0, tys.size() - 1)]] if shell_i > 0 else acc
		Draw.disc(ci, mp, 4.0 * k * fl, Color(1.0, 0.85, 0.5, 0.85 * fl))
		Draw.disc(ci, mp, 6.5 * k * fl, Color(tc, 0.3 * fl))
		Draw.disc(ci, mp + Vector2(0, -4.0 * k), (2.5 + 3.0 * (1.0 - fl)) * k, Color(0.85, 0.88, 0.9, 0.35 * fl))
	# The turret hub on top.
	Draw.plate(ci, c, Draw.ngon(8, 1.0, PI / 8.0), Draw.METAL_L, aim, 6.0 * k, 1.1)
	Draw.orb(ci, c, 3.0 * k, Draw.METAL, k)
	Draw.glow_dot(ci, c, 1.0 * k, acc)
	if L.r == 0 and shots % 3 == 2:
		Draw.ring(ci, c, 4.2 * k, RED, 1.0 * k)
	Draw.dyn(false)
