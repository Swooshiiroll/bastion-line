extends RefCounted
## Chemical Plant art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_12_chem.html, tools/tower_art/data_p2_chem.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 pressure pump, 1 mist nozzle, 2 bigger tanks) and the depth of
## each path, 5 on the path that took its mastery. a = Acid, b = Speed, c = Slowing. The plant is not turned by the sprite cache: the
## columns, pipes and domes are cached and the nozzle(s), which turn to their targets, are live. `extra` is [the second sprayer's angle].

const Draw = preload("res://scripts/view/Draw.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const STEEL := Color(0.42, 0.45, 0.50)
const GELC := Color(0.80, 1.0, 0.45)
const YEL := Color(1.0, 0.85, 0.20)
const BORE := Color(0.05, 0.05, 0.06)

# The owner's picks per step: Acid, Speed, Slowing.
const PICKS := [["B", "C", "C", "A", "C"], ["B", "C", "B", "A", "B"], ["B", "A", "B", "C", "A"]]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "A": 0, "S": 0, "G": 0}
	return {"r": int(p[0]), "A": int(p[1]), "S": int(p[2]), "G": int(p[3])}


static func kp(L: Dictionary, pi: int, k: int) -> String:
	var d: int = [L.A, L.S, L.G][pi]
	return PICKS[pi][k] if d > k else ""


## The spray and acid colour: yellower with Etching Acid, a dark bubbling green at Concentrated Acid, gold at the Dissolver.
static func acid_color(L: Dictionary, acc: Color) -> Color:
	if L.A >= 5:
		return GOLD
	if L.A >= 4:
		return Color(0.3, 0.8, 0.2)
	if L.A >= 2:
		return Color(0.7, 1.0, 0.25)
	return acc


static func at(c: Vector2, aim: float, k: float, x: float, y: float) -> Vector2:
	return c + (Vector2.from_angle(aim) * x + Vector2.from_angle(aim).orthogonal() * y) * k


## Where the first sprayer's nozzle ends (the spray starts here).
static func muzzle(c: Vector2, aim: float, k: float, look: String) -> Vector2:
	var L := levels(look)
	if L.S >= 3:
		return c + Vector2(0, -3.4 * k) + Vector2.from_angle(aim) * 13.0 * k
	return at(c, aim, k, 13.5, 0.0)


static func draw(ci: CanvasItem, c: Vector2, aim: float, s: float, t: float, flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s
	var ac := acid_color(L, acc)
	var fl := clampf(flash / 0.15, 0.0, 1.0)
	var a2: float = float(extra[0]) if extra.size() > 0 and extra[0] != null else aim
	var fixed := func(x: float, y: float) -> Vector2: return c + Vector2(x, y) * k
	var big_cols: bool = L.r == 2
	var col_r := 4.9 if big_cols else 4.0
	var angs: Array = [-PI / 2.0, PI / 6.0, 5.0 * PI / 6.0]
	var pw := 2.8 if kp(L, 1, 0) == "B" else 1.4
	var gel_cols: bool = kp(L, 2, 1) == "A" or kp(L, 2, 0) == "A"
	var gel_main: bool = kp(L, 2, 0) == "B"
	# The cooling coil under everything (Setting Glue's pick), the pump house, the ring mains.
	if kp(L, 2, 3) == "C":
		Draw.ring(ci, c, 7.4 * k, Color(0.5, 0.8, 1.0), 2.0 * k)
		for i in 12:
			var an := float(i) * TAU / 12.0
			Draw.line(ci, c + Vector2.from_angle(an) * 6.6 * k, c + Vector2.from_angle(an) * 8.2 * k, Color(0.85, 0.95, 1.0, 0.7), 0.7 * k)
	if L.r == 0:
		var ph: Vector2 = fixed.call(-14.2, -2.4)
		Draw.line(ci, ph, c, Color(0.1, 0.1, 0.12), 2.6 * k)
		Draw.line(ci, ph, c, Draw.METAL, 1.4 * k)
		Draw.plate(ci, ph, Draw.rect_pts(3.6, 3.0), Draw.METAL_L, 0.0, k, 1.2)
		Draw.plate(ci, ph, Draw.rect_pts(3.1, 2.5), Draw.METAL_D, 0.0, k, 0.9)
		Draw.disc(ci, ph + Vector2(2.2, -1.6) * k, 0.9 * k, Draw.OUTLINE)
		Draw.disc(ci, ph + Vector2(2.2, -1.6) * k, 0.6 * k, Draw.METAL)
	if L.S >= 2:
		Draw.ring(ci, c, 14.4 * k, Draw.OUTLINE, 3.8 * k)
		Draw.ring(ci, c, 14.4 * k, Draw.METAL_L, 2.6 * k)
		for i in 12:
			Draw.disc(ci, c + Vector2.from_angle(float(i) * TAU / 12.0 + 0.26) * 14.4 * k, 0.6 * k, STEEL)
		for a in angs:
			Draw.line(ci, c + Vector2.from_angle(a) * 13.0 * k, c + Vector2.from_angle(a) * 14.4 * k, Draw.METAL, 2.0 * k)
	if gel_main:
		Draw.ring(ci, c, 12.6 * k, GELC, 1.6 * k)
		for i in 3:
			Draw.line(ci, c + Vector2.from_angle(float(i) * TAU / 3.0 + 0.5) * 10.0 * k, c + Vector2.from_angle(float(i) * TAU / 3.0 + 0.5) * 12.6 * k, GELC, 1.2 * k)
	# The columns round the still.
	for i in angs.size():
		var q: Vector2 = c + Vector2.from_angle(angs[i]) * 10.0 * k
		var body: Color = Draw.METAL_L.lerp(GELC, 0.35) if gel_cols else Draw.METAL_L
		Draw.bar(ci, c, q, pw * k, Draw.METAL)
		Draw.orb(ci, q, col_r * k, body, k)
		Draw.ring(ci, q, (col_r - 1.2) * k, Draw.METAL, 0.8 * k)
		if big_cols:
			Draw.orb(ci, q + Vector2(0, -1.6 * k), (col_r - 0.8) * k, body, k)
		if gel_cols:
			Draw.arc(ci, q, (col_r - 0.6) * k, PI * 1.1, PI * 1.9, 10, Color(GELC, 0.9), 1.4 * k)
			Draw.ring(ci, q, col_r * k, Color(GELC, 0.45), 0.8 * k)
		if L.G >= 3:
			Draw.orb(ci, q, 5.4 * k, Color(0.45, 0.4, 0.22), k)
			for rr in [4.2, 2.8]:
				Draw.ring(ci, q, rr * k, Draw.METAL, 0.9 * k)
		if L.A >= 1 and i == 0:
			Draw.plate(ci, q + Vector2(0, -col_r * k - 1.6 * k), Draw.rect_pts(2.6, 1.2), Draw.METAL_D, 0.0, k, 0.9)
		if L.A >= 2:
			Draw.ring(ci, q, (col_r - 2.2) * k, Color(ac, 0.7), 1.2 * k)
		if L.A >= 5:
			Draw.ring(ci, q, col_r * k, GOLD, 1.0 * k)
	# The still: twin stills (Twin Valves' pick), with the pump hall's piston.
	if L.S >= 3:
		var hall: bool = L.S >= 4
		if hall:
			Draw.bar(ci, c + Vector2(0, -3.4) * k, c + Vector2(0, 3.4) * k, 11.8 * k, Draw.OUTLINE)
			Draw.bar(ci, c + Vector2(0, -3.4) * k, c + Vector2(0, 3.4) * k, 10.8 * k, Draw.METAL_L)
			for yy in [-3.4, 3.4]:
				Draw.ring(ci, c + Vector2(0, yy) * k, 4.9 * k, Draw.METAL, 1.0 * k)
				Draw.bar(ci, c + Vector2(-2.6, yy) * k, c + Vector2(-7.0, yy) * k, 1.4 * k, STEEL)
		for yy in [-3.4, 3.4]:
			Draw.orb(ci, c + Vector2(0, yy) * k, 4.0 * k, Draw.METAL_L.lerp(ac, 0.15), k)
			Draw.ring(ci, c + Vector2(0, yy) * k, 2.6 * k, Draw.METAL, 0.8 * k)
		Draw.bar(ci, c + Vector2(0, -3.4) * k, c + Vector2(0, 3.4) * k, 1.6 * k, Draw.METAL)
	else:
		Draw.orb(ci, c, (6.2 if kp(L, 1, 0) == "A" else 5.0) * k, Draw.METAL_L.lerp(ac, 0.15), k)
	# Fixed kit the acid picks keep.
	if L.A >= 4:
		Draw.bar(ci, fixed.call(-5.0, 12.5), fixed.call(-1.0, 12.5), 1.6 * k, Draw.METAL)
		Draw.orb(ci, fixed.call(-5.8, 12.5), 1.4 * k, Draw.METAL_L, k)
	if L.G >= 2:
		Draw.disc(ci, c, 7.2 * k, Color(GELC, 0.16))
		Draw.ring(ci, c, 7.2 * k, Color(GELC, 0.8), 1.2 * k)
	if L.G >= 5:
		Draw.disc(ci, c, 7.6 * k, Color(GOLD, 0.14))
		Draw.ring(ci, c, 7.6 * k, GOLD, 1.4 * k)
		Draw.ring(ci, c, 6.2 * k, Color(GOLD, 0.6), 0.8 * k)
	if L.A >= 5:
		Draw.ring(ci, c, 5.0 * k, GOLD, 1.0 * k)
	# --- Live: the pipes' glow, the flywheel, and the nozzle(s) turning to their enemies. ---
	Draw.dyn(true)
	for i in angs.size():
		var q2: Vector2 = c + Vector2.from_angle(angs[i]) * 10.0 * k
		Draw.glow_dot(ci, q2, 0.9 * k, Color(GELC if gel_cols else ac, 0.5 + 0.5 * sin(t * 2.0 + float(i))))
	if L.A >= 3:
		for i in 3:
			Draw.glow_dot(ci, fixed.call(3.0 + float(i) * 2.0, 13.0), 0.5 * k, Color(ac, 0.4 + 0.5 * sin(t * 4.0 + float(i))))
	if L.r == 0:
		var fw: Vector2 = fixed.call(-14.8, -2.0)
		Draw.disc(ci, fw, 1.6 * k, Draw.OUTLINE)
		Draw.ring(ci, fw, 1.3 * k, Draw.METAL_L, 0.8 * k)
		for i in 3:
			Draw.line(ci, fw, fw + Vector2.from_angle((t * 12.0 if fl > 0.0 else t * 1.2) + float(i) * TAU / 3.0) * 1.3 * k, Draw.METAL_L, 0.8 * k)
	var twin_stills: bool = L.S >= 3
	var piv1: Vector2 = c + Vector2(0, -3.4 * k) if twin_stills else c
	var piv2: Vector2 = c + Vector2(0, 3.4 * k) if twin_stills else c
	if L.S >= 5:
		# Two independent sprayers, each with its own pipe and head, growing from its own still.
		for pr in [[piv1, aim, 13.0], [piv2, a2, 13.0]]:
			var pv: Vector2 = pr[0]
			var an: float = pr[1]
			var ln: float = pr[2]
			Draw.bar(ci, pv, pv + Vector2.from_angle(an) * 6.0 * k, 2.2 * k, GOLD)
			Draw.bar(ci, pv + Vector2.from_angle(an) * 6.0 * k, pv + Vector2.from_angle(an) * ln * k, 1.6 * k, Draw.METAL)
			Draw.glow_dot(ci, pv + Vector2.from_angle(an) * (ln + 0.4) * k, (0.7 + 1.4 * fl) * k, Color(ac, 0.5 + 0.5 * fl))
		Draw.ring(ci, piv1, 4.0 * k, GOLD, 1.0 * k)
		Draw.ring(ci, piv2, 4.0 * k, GOLD, 1.0 * k)
	else:
		var neck := 3.6 if kp(L, 1, 0) == "C" else 2.4
		Draw.bar(ci, piv1, at(piv1, aim, k, 6.0, 0.0), neck * k, Draw.METAL)
		Draw.bar(ci, at(piv1, aim, k, 6.0, 0.0), at(piv1, aim, k, 13.0, 0.0), 1.6 * k, Draw.METAL)
		Draw.glow_dot(ci, at(piv1, aim, k, 13.4, 0.0), (0.7 + 1.4 * fl) * k, Color(ac, 0.5 + 0.5 * fl))
	if L.r == 1:
		# The refined mist head on the end of each sprayer.
		var sprayers: Array = [[piv1, aim]] if L.S < 5 else [[piv1, aim], [piv2, a2]]
		for sp in sprayers:
			var ln2 := 13.2
			var o := at(sp[0], sp[1], k, ln2, 0.0)
			var hd := PackedVector2Array([Vector2(0, -1), Vector2(2.4, -2.4), Vector2(4, -2.9), Vector2(4, 2.9), Vector2(2.4, 2.4), Vector2(0, 1)])
			Draw.plate(ci, o, hd, Draw.METAL_L, sp[1], k, 1.1)
			for q in range(-2, 3):
				Draw.disc(ci, at(o, sp[1], k, 3.7, float(q) * 1.1), 0.34 * k, BORE)
	Draw.glow_dot(ci, c, 1.1 * k, ac)
	Draw.dyn(false)
