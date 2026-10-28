extends RefCounted
## Scrapyard art (tower rework, issue #59): a port of the confirmed production line (base: design/tower_art_p17_scrapyard.html, B Production
## Line with B Melt and Pour; second pass: design/tower_art_p2_17_scrap.html, tools/tower_art/data_p2_scrap.js) with the owner's picks
## hard-coded. A 2x2 yard: the junkyard down the left (heaps, a hauled-in wreck), a crane loading a belt that drops scrap into the furnace
## stack in the middle, a short ingot belt to the warehouse down the right, and the crate stack.
##  - Passive Income rebuilds the stack: Glowing Firebrick, Side Blower, Hot-Blast Stoves, Plasma Ring, Gold Shell.
##  - Kill Income rebuilds the junkyard: Tow Truck, Bridge Magnet, Laser Gantry, Flat Press, Gold Crane (and the x2 sign).
##  - Discounts rebuilds the warehouse: Open-Roof Shelves, Stacker Crane, Forklift Run, Twin Ramps, Gold Fleet.
##  - Retrofits: the Hammer Mill, Faster Loading (a second belt and grab crane from the top heap), Surplus (two more crates).
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 hammer mill, 1 faster loading, 2 surplus) and the depth of each
## path, 5 on the path that took its mastery. `extra[0]` is the time since its last payout (the doors roll up and the core flares).
## One unit is a screen pixel at 48 px per tile (the game draws 2x2 towers at s = 1.8). The yard never turns: the buildings, belts and
## machines' bodies are cached; the belts' slats, the scrap, the cranes, the wreck, the lasers, the fire, the doors and the smoke are live.

const Draw = preload("res://scripts/view/Draw.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const RUST := Color(0.45, 0.30, 0.20)
const BRICK := Color(0.55, 0.27, 0.20)
const MOLTEN := Color(1.0, 0.55, 0.15)
const HOTM := Color(1.0, 0.85, 0.45)
const STEEL := Color(0.42, 0.45, 0.50)
const WOOD := Color(0.60, 0.43, 0.24)
const DIRT := Color(0.27, 0.23, 0.19)
const CONC := Color(0.29, 0.29, 0.30)
const ROOF := Color(0.44, 0.47, 0.50)
const DOOR := Color(0.80, 0.58, 0.20)
const CRANE := Color(0.92, 0.70, 0.20)
const LASER := Color(1.0, 0.22, 0.18)
const KILL := Color(1.0, 0.50, 0.20)
const ARCC := Color(0.72, 0.88, 1.0)
const SCRAP := Color(0.72, 0.46, 0.30)
const STRIPE := Color(0.06, 0.06, 0.07)
const LOADS := [Color(0.35, 0.55, 0.80), Color(0.40, 0.65, 0.40), Color(0.75, 0.45, 0.30), Color(0.85, 0.70, 0.30)]
const STACKR := [14.0, 14.5, 15.0, 16.0, 16.5, 17.0]

# The feed lines: a crane loads a belt that drops the scrap into the furnace, one piece per 3.2 s. FEED2 is Faster Loading's second line.
const FEED := {"pv": Vector2(-36, 13), "heap": Vector2(-33, 0), "b0": Vector2(-24, 20), "rails": [-43.0, -13.0, -8.0, 35.0], "ofs": 0.0}
const FEED2 := {"pv": Vector2(-29.3, -20.8), "heap": Vector2(-31, -30), "b0": Vector2(-22, -22), "rails": [-43.0, -13.0, -40.0, -14.0], "ofs": 1.6}
const MOUTH := Vector2(0, -8)
const FEND := 9.5
const FT := 3.2
const FBELT := 0.35


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "I": 0, "K": 0, "D": 0}
	return {"r": int(p[0]), "I": int(p[1]), "K": int(p[2]), "D": int(p[3])}


static func gl(col: Color, gold: bool, u := 0.75) -> Color:
	return col.lerp(GOLD, u) if gold else col


## The pages' hash: a fixed pseudo-random 0..1 for x.
static func rnd(x: float) -> float:
	var v := sin(x * 12.9898) * 43758.5453
	return v - floorf(v)


static func smooth(x: float) -> float:
	x = clampf(x, 0.0, 1.0)
	return x * x * (3.0 - 2.0 * x)


## A point `(x, y)` units from `p`, turned by `ang`.
static func o(p: Vector2, ang: float, k: float, x: float, y: float) -> Vector2:
	return p + Vector2(x, y).rotated(ang) * k


## Hazard stripes along local x from x0 to x1 (the pages' hazard).
static func hazard(ci: CanvasItem, c: Vector2, ang: float, k: float, x0: float, x1: float, y: float, col: Color, w: float) -> void:
	var n := maxi(2, roundi((x1 - x0) / 2.0))
	for i in n:
		var x := x0 + (x1 - x0) * (float(i) + 0.5) / float(n)
		Draw.line(ci, o(c, ang, k, x - 0.8, y), o(c, ang, k, x + 0.8, y), STRIPE if i % 2 == 1 else Color(col, 0.95), w * k)


static func scrap_pile(ci: CanvasItem, p: Vector2, r: float, k: float, seed: int) -> void:
	var pts := PackedVector2Array()
	for i in 9:
		var a := float(i) * TAU / 9.0
		pts.append(Vector2(cos(a) * r * (0.65 + 0.35 * rnd(seed + i)), sin(a) * r * (0.65 + 0.35 * rnd(seed + i + 20))))
	Draw.ellipse(ci, p + Vector2(1.5, 2.5) * k, r * k, r * k * 0.5, Color(0, 0, 0, 0.3))
	Draw.solid(ci, p, pts, RUST.lerp(Draw.METAL, 0.4), 0.0, k, 1.0)
	for i in 5:
		var q := p + Vector2((rnd(seed + i * 3) - 0.5) * r * k * 1.1, (rnd(seed + i * 5) - 0.5) * r * k * 0.9)
		Draw.line(ci, q, q + Vector2.from_angle(rnd(seed + i) * TAU) * r * k * 0.35, Draw.METAL_L if i % 2 == 1 else RUST, 1.4 * k)


static func wreck(ci: CanvasItem, p: Vector2, ang: float, k: float, sq: float) -> void:
	var kk := k * sq
	var body := RUST.lerp(Draw.METAL, 0.3).darkened(minf(0.5, (sq - 1.0) * 3.0))
	for sg in [-1.0, 1.0]:
		Draw.plate(ci, o(p, ang, kk, 0, sg * 7.4), Draw.rect_pts(12, 2), Color(0.13, 0.12, 0.12), ang, kk, 1.0)
	Draw.plate(ci, p, Draw.rect_pts(11, 6), body, ang, kk, 1.3)
	var tur := o(p, ang, kk, -2, 0)
	Draw.disc(ci, tur, 3.8 * kk, Draw.OUTLINE)
	Draw.disc(ci, tur, 3.1 * kk, Color(0.05, 0.05, 0.05))
	Draw.ring(ci, tur, 3.5 * kk, RUST, 1.2 * kk)
	Draw.line(ci, o(p, ang, kk, 5, -3.5), o(p, ang, kk, 9, 1), Color(0.3, 0.14, 0.1), 1.2 * kk)
	Draw.line(ci, o(p, ang, kk, 4, 1), o(p, ang, kk, 7, 4.5), Color(0.3, 0.14, 0.1), 1.2 * kk)


static func crates(ci: CanvasItem, p: Vector2, cols: int, rows: int, k: float) -> void:
	for r in rows:
		for q in cols:
			var c := p + Vector2((float(q) - float(cols - 1) / 2.0) * 6.4, (float(r) - float(rows - 1) / 2.0) * 6.4) * k
			Draw.plate(ci, c, Draw.rect_pts(2.9, 2.9), WOOD, 0.0, k, 1.0)
			Draw.line(ci, c + Vector2(-2.2, -2.2) * k, c + Vector2(2.2, 2.2) * k, WOOD.darkened(0.35), 0.8 * k)


## A conveyor's frame and end drums (cached); `conveyor_slats` draws its moving slats.
static func conveyor(ci: CanvasItem, a: Vector2, b: Vector2, k: float, gold: bool) -> void:
	Draw.line(ci, a, b, Draw.OUTLINE, 8.0 * k)
	Draw.line(ci, a, b, GOLD.darkened(0.15) if gold else Draw.METAL, 6.6 * k)
	Draw.line(ci, a, b, Color(0.14, 0.13, 0.12), 4.2 * k)
	for e in [a, b]:
		Draw.disc(ci, e, 3.4 * k, Draw.OUTLINE)
		Draw.disc(ci, e, 2.7 * k, GOLD if gold else Draw.METAL_L)
		Draw.disc(ci, e, 1.0 * k, Draw.METAL_D)


static func conveyor_slats(ci: CanvasItem, a: Vector2, b: Vector2, t: float, k: float) -> void:
	var d := (b - a).normalized()
	var n := d.orthogonal()
	var len := a.distance_to(b)
	var end := 3.4 * k / len
	for j in int(len / (3.0 * k)):
		var u := fmod(float(j) * 3.0 * k / len + t * 0.35, 1.0)
		if u < end or u > 1.0 - end:
			continue
		var q := a.lerp(b, u)
		Draw.line(ci, q + n * 2.0 * k, q - n * 2.0 * k, Color(0.42, 0.40, 0.37), 0.9 * k)


static func chunk(ci: CanvasItem, p: Vector2, sc: float, seed: float, k: float, col := Color(0, 0, 0, 0)) -> void:
	var c2: Color = col if col.a > 0.0 else SCRAP.lerp(Draw.METAL_L, 0.2 + 0.4 * rnd(seed))
	var pts := PackedVector2Array()
	for i in 6:
		var a := float(i) * TAU / 6.0
		pts.append(Vector2(cos(a) * 3.1 * (0.7 + 0.3 * rnd(seed + i)), sin(a) * 3.1 * (0.7 + 0.3 * rnd(seed + i + 9))))
	Draw.fill(ci, p, pts, c2, seed, k * sc)
	Draw.outline(ci, p, pts, Draw.OUTLINE, 1.2, seed, k * sc)
	Draw.line(ci, p - Vector2.from_angle(seed) * 1.2 * k * sc, p + Vector2.from_angle(seed) * 1.2 * k * sc, Color(1, 1, 1, 0.35), 0.9 * k * sc)


static func truck(ci: CanvasItem, p: Vector2, ang: float, k: float, col: Color, len: float) -> void:
	Draw.fill(ci, p + Vector2(1.5, 2) * k, PackedVector2Array([Vector2(-len - 2, -3.8), Vector2(len + 4, -3.8), Vector2(len + 4, 3.8), Vector2(-len - 2, 3.8)]), Color(0, 0, 0, 0.28), ang, k)
	Draw.plate(ci, o(p, ang, k, -2, 0), Draw.rect_pts(len, 3.6), col, ang, k, 1.2)
	for j in range(1, 4):
		var x := -2.0 - len + float(j) * len * 0.5
		Draw.line(ci, o(p, ang, k, x, -3.2), o(p, ang, k, x, 3.2), Color(Draw.OUTLINE, 0.35), 0.7 * k)
	Draw.plate(ci, o(p, ang, k, len + 1.4, 0), Draw.rect_pts(2.4, 3.2), col.darkened(0.12), ang, k, 1.2)
	Draw.fill(ci, o(p, ang, k, len + 2.6, 0), Draw.rect_pts(0.8, 2.4), Color(0.55, 0.75, 0.9, 0.85), ang, k)


static func forklift(ci: CanvasItem, p: Vector2, ang: float, k: float, col: Color, load: Variant) -> void:
	Draw.plate(ci, p, Draw.rect_pts(2.2, 1.6), col, ang, k, 1.0)
	Draw.disc(ci, o(p, ang, k, -0.8, 0), 0.8 * k, Draw.OUTLINE)
	Draw.line(ci, o(p, ang, k, 2.2, -1.5), o(p, ang, k, 2.2, 1.5), Draw.METAL_D, 0.9 * k)
	for y in [-0.8, 0.8]:
		Draw.line(ci, o(p, ang, k, 2.2, y), o(p, ang, k, 4.4, y), Draw.METAL_L, 0.7 * k)
	if load != null:
		Draw.plate(ci, o(p, ang, k, 3.4, 0), Draw.rect_pts(1.4, 1.4), load, ang, k, 0.9)


## A crackling arc from a to b.
static func zap(ci: CanvasItem, a: Vector2, b: Vector2, seed: float, w: float, t: float, k: float) -> void:
	var pts := PackedVector2Array([a])
	var n := (b - a).normalized().orthogonal()
	for j in range(1, 5):
		pts.append(a.lerp(b, float(j) / 5.0) + n * (rnd(seed + float(j) + floorf(t * 14.0) * 3.1) - 0.5) * 2.2 * k)
	pts.append(b)
	Draw.polyline(ci, pts, Color(ARCC, 0.35), w * 2.6)
	Draw.polyline(ci, pts, Color(0.95, 0.98, 1.0), w)


static func draw(ci: CanvasItem, c: Vector2, _aim: float, s: float, t: float, _flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s / 1.8
	var age: float = float(extra[0]) if extra.size() > 0 and extra[0] != null else 99.0
	var S := func(x: float, y: float) -> Vector2: return c + Vector2(x, y) * k
	# --- Cached: the yard's floor and the junkyard's dirt. ---
	Draw.ellipse(ci, c + Vector2(0, 8) * k, 44.0 * k, 16.0 * k, Color(0, 0, 0, 0.3))
	Draw.plate(ci, c, Draw.rect_pts(46, 46), Draw.METAL_D.lightened(0.04), 0.0, k, 1.3)
	Draw.fill(ci, c, Draw.rect_pts(44, 44), CONC, 0.0, k)
	for i in range(-3, 4):
		Draw.line(ci, c + Vector2(float(i) * 12.0, -44.0) * k, c + Vector2(float(i) * 12.0, 44.0) * k, Color(0, 0, 0, 0.1), 0.8 * k)
		Draw.line(ci, c + Vector2(-44.0, float(i) * 12.0) * k, c + Vector2(44.0, float(i) * 12.0) * k, Color(0, 0, 0, 0.1), 0.8 * k)
	Draw.outline(ci, c, Draw.rect_pts(44, 44), Color(acc, 0.5), 1.3 * k, 0.0, k)
	Draw.fill(ci, S.call(-29.5, 0.0), Draw.rect_pts(14.5, 44), DIRT, 0.0, k)
	for i in 14:
		Draw.disc(ci, S.call(-44.0 + 29.0 * rnd(5 + i), -44.0 + 88.0 * rnd(5 + i + 40)), (0.5 + rnd(5 + i + 80)) * k, Color(0.2, 0.17, 0.14))
	_junk_static(ci, S, L, k)
	_ware_static(ci, S, L, k)
	# The ingot belt from the stack to the warehouse.
	var gi: bool = L.I >= 5
	conveyor(ci, S.call(10, -8), S.call(23, -8), k, gi)
	_stack_static(ci, S, L, k)
	# Hammer Mill: a hammer mill by the belt's foot, with a chute onto the belt.
	if L.r == 0:
		Draw.bar(ci, S.call(-13, 24), S.call(-18.8, 13.9), 2.6 * k, Draw.METAL)
		Draw.plate(ci, S.call(-9, 27), Draw.rect_pts(6, 4.6), Draw.METAL_D, 0.0, k, 1.2)
		Draw.disc(ci, S.call(-9, 27), 3.8 * k, Draw.OUTLINE)
		Draw.disc(ci, S.call(-9, 27), 3.3 * k, Draw.METAL)
	_feed_static(ci, S, L, k, FEED, true)
	if L.r == 1:
		_feed_static(ci, S, L, k, FEED2, false)
	# --- Live: everything that moves. ---
	Draw.dyn(true)
	_junk_live(ci, S, L, t, k)
	_ware_live(ci, S, L, t, age, k)
	var sr: float = STACKR[L.I]
	conveyor_slats(ci, S.call(10, -8), S.call(23, -8), t, k)
	for i in 2:
		var x := lerpf(10.0, 23.0, fmod(t * 0.35 + float(i) / 2.0, 1.0))
		if x > sr + 1.0:
			Draw.fill(ci, S.call(x, -8), Draw.rect_pts(2.2, 1.3), GOLD if gi else Color(0.82, 0.62, 0.45), 0.0, k)
			Draw.outline(ci, S.call(x, -8), Draw.rect_pts(2.2, 1.3), Draw.OUTLINE, 1.0, 0.0, k)
	_stack_live(ci, S, L, t, age, k)
	if L.r == 0:
		var hm: Vector2 = S.call(-9, 27)
		for j in 4:
			var a := t * 9.0 + float(j) * PI / 2.0
			Draw.bar(ci, hm, hm + Vector2.from_angle(a) * 4.0 * k, 1.1 * k, Draw.METAL_L)
			Draw.disc(ci, hm + Vector2.from_angle(a) * 4.0 * k, 0.9 * k, STEEL)
	_feed_live(ci, S, L, t, k, FEED, "C" if L.K > 1 else "", true)
	if L.r == 1:
		_feed_live(ci, S, L, t, k, FEED2, "", false)
	# Melt and Pour: embers rising from the stack, and its smoke.
	var m: Vector2 = S.call(0, -8)
	for i in 8:
		var q := t * 0.9 + float(i) / 8.0
		var u := fmod(q, 1.0)
		var dx := (rnd(floorf(q) * 7.0 + float(i)) - 0.5) * 16.8
		Draw.disc(ci, m + Vector2(dx * u, -u * 26.4) * k, (0.9 * (1.0 - u) + 0.3) * k, Color(1.0, 0.7, 0.3, 1.0 - u))
	var nsm: int = 6 + L.I
	for i in nsm:
		var u2 := fmod(t * 0.32 + float(i) / float(nsm), 1.0)
		Draw.disc(ci, m + Vector2(sr * 0.2 + u2 * 14.0, -(sr * 0.15 + u2 * 24.0)) * k, (2.0 + u2 * 6.0) * k, Color(0.5, 0.48, 0.46, 0.42 * (1.0 - u2)))
	Draw.dyn(false)


# --- Kill Income: the junkyard -----------------------------------------------------------------------------------------------------------

static func _junk_static(ci: CanvasItem, S: Callable, L: Dictionary, k: float) -> void:
	scrap_pile(ci, S.call(-31, -30), 8.0, k, 2)
	scrap_pile(ci, S.call(-33, 0), 9.0, k, 13)
	var g: bool = L.K >= 5
	# Tow Hook (Tow Truck): the truck that hauls the wreck in.
	if L.K >= 1:
		truck(ci, S.call(-9, 42), 0.0, k, gl(CRANE, g, 0.6), 3.5)
		Draw.bar(ci, S.call(-14.5, 42), S.call(-17.5, 42), 1.4 * k, gl(STEEL, g, 0.7))
	# Breaker's Yard: a gold x2 sign for bosses.
	if g:
		var q: Vector2 = S.call(-22, -41)
		Draw.plate(ci, q, Draw.rect_pts(4.4, 2.4), GOLD.darkened(0.3), 0.0, k, 1.0)
		var w := 0.6 * k
		Draw.line(ci, q + Vector2(-2.8, -1.2) * k, q + Vector2(-0.6, 1.2) * k, GOLD, w)
		Draw.line(ci, q + Vector2(-0.6, -1.2) * k, q + Vector2(-2.8, 1.2) * k, GOLD, w)
		Draw.polyline(ci, PackedVector2Array([q + Vector2(0.4, -0.7) * k, q + Vector2(1.4, -1.3) * k, q + Vector2(2.6, -0.7) * k, q + Vector2(0.4, 1.2) * k, q + Vector2(2.8, 1.2) * k]), GOLD, w)


static func _junk_live(ci: CanvasItem, S: Callable, L: Dictionary, t: float, k: float) -> void:
	var g: bool = L.K >= 5
	var steel := gl(STEEL, g, 0.7)
	var dark: Color = GOLD.darkened(0.55) if g else Draw.METAL_D
	# The wreck is hauled in by the tow truck's cable, then (Car Crusher, Flat Press) flattened where it lies.
	var hc := fmod(t / 6.0, 1.0)
	var haul := smooth(hc / 0.7) if hc < 0.7 else 1.0 - smooth((hc - 0.7) / 0.3)
	var wy := 34.0
	var wx := -32.0
	if L.K >= 1:
		wx = -36.0 + 5.0 * haul
	if L.K >= 4:
		wx = -30.0
	var sq := 1.0
	if L.K >= 4:
		var pc := fmod(t / 3.0, 1.0)
		sq = 1.0 + 0.14 * (smooth(pc / 0.3) if pc < 0.3 else (1.0 if pc < 0.7 else 1.0 - smooth((pc - 0.7) / 0.3)))
	Draw.ellipse(ci, S.call(wx, wy) + Vector2(1.5, 2.5) * k, 13.0 * k, 7.0 * k, Color(0, 0, 0, 0.3))
	if L.K >= 1:
		Draw.line(ci, S.call(-17.5, 42), S.call(wx + 11.0, wy), Draw.METAL_L, 0.9 * k)
	wreck(ci, S.call(wx, wy), 0.05, k, sq)
	if L.K >= 4:
		var q: Vector2 = S.call(wx, wy)
		for sx in [-1.0, 1.0]:
			Draw.plate(ci, q + Vector2(sx * 14.0, 0) * k, Draw.rect_pts(2, 5), dark, 0.0, k, 1.2)
		for sy in [-1.0, 1.0]:
			Draw.bar(ci, q + Vector2(-14.0, sy * 4.4) * k, q + Vector2(14.0, sy * 4.4) * k, 2.0 * k, steel)
		Draw.fill(ci, q, Draw.rect_pts(12, 6.4), Color(steel, 0.25 + 2.5 * (sq - 1.0)), 0.0, k)
		Draw.disc(ci, q, 2.4 * k, Draw.OUTLINE)
		Draw.disc(ci, q, 1.9 * k, steel)


# --- Discounts: the warehouse ----------------------------------------------------------------------------------------------------------

## The warehouse's shape for the Discounts depth: [centre, half length, door count, how much roof is off (0, 0.5, 1), the rack style].
static func _ware_spec(S: Callable, L: Dictionary) -> Array:
	if L.D == 0:
		return [S.call(33, 0), 40.0, 4, 0.0, "shelf"]
	return [S.call(33, -10), 30.0, 3, 1.0 if L.D >= 2 else 0.5, "stacker" if L.D >= 2 else "shelf"]


static func _ware_static(ci: CanvasItem, S: Callable, L: Dictionary, k: float) -> void:
	var g: bool = L.D >= 5
	var sp := _ware_spec(S, L)
	var p: Vector2 = sp[0]
	var hw: float = sp[1]
	var hh := 9.5
	var ang := PI / 2.0
	var nd: int = sp[2]
	var open: float = sp[3]
	Draw.fill(ci, p + Vector2(2.5, 3.5) * k, Draw.rect_pts(hw, hh), Color(0, 0, 0, 0.3), ang, k)
	for i in nd:
		var dx := _door_x(i, nd, hw)
		Draw.fill(ci, o(p, ang, k, dx, hh + 1.4), Draw.rect_pts(4.4, 2.4), CONC, ang, k)
		hazard(ci, o(p, ang, k, dx, hh + 3.6), ang, k, -4, 4, 0, DOOR, 1.0)
	Draw.plate(ci, p, Draw.rect_pts(hw, hh), ROOF, ang, k, 1.5)
	# The roof comes off from x0 to the end (Open-Roof Shelves, then the whole roof for the Stacker Crane's racks).
	var x0 := -hw if open >= 1.0 else (0.0 if open > 0.0 else hw)
	if x0 < hw:
		var a := x0 + 1.2
		var b := hw - 1.2
		var cx := (a + b) / 2.0
		var hx := (b - a) / 2.0
		var shelf: bool = sp[4] == "shelf"
		var rows: Array = [-5.2, 5.2] if shelf else [-5.6, -2.6, 2.6, 5.6]
		Draw.fill(ci, o(p, ang, k, cx, 0), Draw.rect_pts(hx, hh - 1.2), Color(0.15, 0.15, 0.16), ang, k)
		for ri in rows.size():
			var y: float = rows[ri]
			Draw.fill(ci, o(p, ang, k, cx, y), Draw.rect_pts(hx - 0.4, 1.3 if shelf else 1.2), gl(Draw.METAL_D, g, 0.6), ang, k)
			var x := a + 1.4
			var j := 0
			while x < b - 1.0:
				var col: Color = LOADS[int(floorf(rnd(float(j) * 3.1 + float(ri) * 7.0) * 4.0))]
				if shelf:
					Draw.disc(ci, o(p, ang, k, x, y), 0.55 * k, col)
				else:
					Draw.fill(ci, o(p, ang, k, x, y), Draw.rect_pts(1.1, 0.9), col, ang, k)
					Draw.outline(ci, o(p, ang, k, x, y), Draw.rect_pts(1.1, 0.9), Draw.OUTLINE, 0.7, ang, k)
				x += 1.9 if shelf else 2.8
				j += 1
		var xb := a + 6.0
		while xb < b:
			Draw.line(ci, o(p, ang, k, xb, -hh + 0.6), o(p, ang, k, xb, hh - 0.6), Color(gl(Draw.METAL_L, g, 0.6), 0.8), 0.9 * k)
			xb += 8.0
		Draw.outline(ci, o(p, ang, k, cx, 0), Draw.rect_pts(hx, hh - 1.2), Draw.OUTLINE, 1.0, ang, k)
	var r1 := minf(hw, x0)
	if r1 > -hw + 3.0:
		var xr := -hw + 2.2
		while xr < r1 - 1.0:
			Draw.line(ci, o(p, ang, k, xr, -hh + 0.9), o(p, ang, k, xr, hh - 0.9), ROOF.darkened(0.2), 0.8 * k)
			xr += 2.2
		Draw.bar(ci, o(p, ang, k, -hw + 0.8, 0), o(p, ang, k, r1 - 0.8, 0), 1.8 * k, ROOF.lightened(0.12))
		for xs in [-hw + (r1 + hw) * 0.25, -hw + (r1 + hw) * 0.75]:
			Draw.fill(ci, o(p, ang, k, xs, -hh * 0.5), Draw.rect_pts(2.8, 1.8), Color(0.7, 0.86, 0.96, 0.55), ang, k)
	if g:
		Draw.outline(ci, p, Draw.rect_pts(hw + 0.3, hh + 0.3), GOLD, 1.3 * k, ang, k)
	# Loading Dock (Twin Ramps): two levelled ramps with a truck at each (gold with the Gold Fleet).
	if L.D >= 4:
		for x in [28.0, 38.0]:
			Draw.plate(ci, S.call(x, 25), Draw.rect_pts(3.6, 1.2), CONC.lightened(0.1), 0.0, k, 1.0)
			truck(ci, S.call(x, 35), PI / 2.0, k, GOLD if g else Color(0.6, 0.35, 0.3), 4.6)
	# The crate stack, with Surplus's two more crates to its left.
	if L.r == 2:
		crates(ci, S.call(0.8, 32), 3, 2, k)
	else:
		crates(ci, S.call(4, 32), 2, 2, k)


static func _door_x(i: int, nd: int, hw: float) -> float:
	return (float(i) - float(nd - 1) / 2.0) * (hw * 2.0 - 6.0) / float(nd)


static func _ware_live(ci: CanvasItem, S: Callable, L: Dictionary, t: float, age: float, k: float) -> void:
	var g: bool = L.D >= 5
	var sp := _ware_spec(S, L)
	var p: Vector2 = sp[0]
	var hw: float = sp[1]
	var hh := 9.5
	var ang := PI / 2.0
	var nd: int = sp[2]
	# Pallet Racks (Stacker Crane): the crane runs up and down the open racks.
	if L.D >= 2:
		var a := -hw + 1.2
		var b := hw - 1.2
		var sx := (a + b) / 2.0 + sin(t * 0.5) * (b - a) / 2.0 * 0.8
		Draw.bar(ci, o(p, ang, k, sx, -hh + 0.8), o(p, ang, k, sx, hh - 0.8), 1.4 * k, gl(CRANE, g, 0.6))
		Draw.plate(ci, o(p, ang, k, sx, sin(t * 1.3) * 3.0), Draw.rect_pts(1.4, 1.2), Draw.METAL_D, ang, k, 1.0)
	# The doors roll up at each payout.
	var op := smooth(age / 0.4) if age < 0.4 else (1.0 if age < 1.4 else 1.0 - smooth(minf(1.0, (age - 1.4) / 0.4)))
	for i in nd:
		var dx := _door_x(i, nd, hw)
		var d := o(p, ang, k, dx, hh - 0.2)
		Draw.fill(ci, d, Draw.rect_pts(3.6, 1.3), DOOR.lerp(Color(0.04, 0.04, 0.04), op), ang, k)
		Draw.outline(ci, d, Draw.rect_pts(3.6, 1.3), Draw.OUTLINE, 1.0, ang, k)
		if op < 0.9:
			for j in [-0.5, 0.5]:
				Draw.line(ci, o(p, ang, k, dx - 3.2, hh - 0.2 + j), o(p, ang, k, dx + 3.2, hh - 0.2 + j), Color(DOOR.darkened(0.4), 1.0 - op), 0.7 * k)
	# Forklift Bay (Forklift Run): a forklift carries pallets out to the yard and drives back.
	if L.D >= 3:
		var c6 := fmod(t / 6.0, 1.0)
		var out := c6 < 0.5
		var u := smooth(c6 / 0.5) if out else 1.0 - smooth((c6 - 0.5) / 0.5)
		var fa: Vector2 = S.call(20.5, 8)
		var fb: Vector2 = S.call(11, 23)
		var hd := (fb - fa).angle() + (0.0 if out else PI)
		forklift(ci, fa.lerp(fb, u), hd, k, GOLD if g else CRANE, LOADS[1] if out else null)


# --- Passive Income: the furnace stack ------------------------------------------------------------------------------------------------

static func _stack_static(ci: CanvasItem, S: Callable, L: Dictionary, k: float) -> void:
	var lv: int = L.I
	var g := lv >= 5
	var p: Vector2 = S.call(0, -8)
	var R: float = STACKR[lv]
	var shell := gl(BRICK, g, 0.55)
	var band: Color = GOLD if g else Draw.METAL
	var band_l: Color = GOLD.lightened(0.25) if g else Draw.METAL_L
	var steel := gl(STEEL, g, 0.7)
	var dark: Color = GOLD.darkened(0.55) if g else Draw.METAL_D
	var melt: Color = MOLTEN.lerp(GOLD, 0.6) if g else MOLTEN
	var tall := 1.35 if lv >= 3 else 1.0
	Draw.disc(ci, p + Vector2(R * 0.5 * tall, R * 0.6 * tall) * k, R * 1.05 * k, Color(0, 0, 0, 0.32))
	# Blast Furnace (Hot-Blast Stoves): two round stoves behind it piping in hot air.
	if lv >= 3:
		for sx in [-1.0, 1.0]:
			var q := p + Vector2(sx * 10.0, -27.0) * k
			Draw.bar(ci, q, p + Vector2(sx * 4.0, -R + 2.0) * k, 2.6 * k, steel)
			Draw.disc(ci, q + Vector2(2, 2.6) * k, 6.2 * k, Color(0, 0, 0, 0.3))
			Draw.disc(ci, q, 7.4 * k, Draw.OUTLINE)
			Draw.disc(ci, q, 6.2 * k, steel)
			Draw.disc(ci, q + Vector2(-1.2, -1.2) * k, 6.2 * 0.62 * k, steel.lightened(0.18))
			Draw.ring(ci, q, 6.2 * 0.8 * k, band_l, 1.1 * k)
	# Forced Bellows (Side Blower): a fan housing on the stack's side, bigger once it's a blast furnace.
	if lv >= 2:
		var bs := 1.25 if lv >= 3 else 1.0
		var q2 := p + Vector2.from_angle(-0.75) * (R + 7.0 * bs) * k
		var r := 5.2 * bs
		Draw.bar(ci, q2, p + Vector2.from_angle(-0.75) * (R - 1.0) * k, 3.0 * k, steel)
		Draw.disc(ci, q2, (r + 1.2) * k, Draw.OUTLINE)
		Draw.disc(ci, q2, r * k, dark)
		Draw.ring(ci, q2, r * k, band, 1.2 * k)
	# The stack; Firebrick Lining (Glowing Firebrick): a two-course firebrick shell with glowing joints.
	Draw.disc(ci, p, (R + 1.6) * k, Draw.OUTLINE)
	Draw.disc(ci, p, R * k, shell)
	if lv == 0:
		for i in 26:
			var a := float(i) * TAU / 26.0
			Draw.line(ci, p + Vector2.from_angle(a) * R * 0.8 * k, p + Vector2.from_angle(a) * R * k, Color(0.32, 0.15, 0.1), 1.0 * k)
	else:
		Draw.ring(ci, p, R * 0.82 * k, Color(melt, 0.4), 0.9 * k)
		for c2 in 2:
			var r0 := 0.82 if c2 == 1 else 0.66
			var r1 := 1.0 if c2 == 1 else 0.82
			var n := 34 if c2 == 1 else 28
			for i in n:
				var a := (float(i) + 0.5 * float(c2)) * TAU / float(n)
				Draw.line(ci, p + Vector2.from_angle(a) * R * r0 * k, p + Vector2.from_angle(a) * R * r1 * k, Color(melt, 0.52), 0.8 * k)
	Draw.ring(ci, p, (R - 0.7) * k, band, 1.8 * k)
	var in_r := 0.66 if lv >= 1 else 0.8
	Draw.disc(ci, p, R * in_r * k, shell.lightened(0.1))
	Draw.ring(ci, p, R * in_r * k, band_l, 1.6 * k)
	for i in 8:
		Draw.disc(ci, p + Vector2.from_angle(float(i) * TAU / 8.0 + 0.2) * R * in_r * k, 0.8 * k, band_l.lightened(0.15))
	Draw.disc(ci, p, R * 0.63 * k, dark)
	Draw.ring(ci, p, R * 0.63 * k, Draw.OUTLINE, 1.2 * k)
	# Arc Furnace (Plasma Ring): six electrodes ring the mouth.
	if lv >= 4:
		for i in 6:
			var e := p + Vector2.from_angle(float(i) * TAU / 6.0 + 0.3) * R * 0.52 * k
			Draw.disc(ci, e, 1.9 * k, Draw.OUTLINE)
			Draw.disc(ci, e, 1.5 * k, GOLD.darkened(0.3) if g else Color(0.24, 0.24, 0.26))
	if g:
		Draw.ring(ci, p, (R + 0.4) * k, Color(GOLD, 0.9), 1.2 * k)


static func _stack_live(ci: CanvasItem, S: Callable, L: Dictionary, t: float, age: float, k: float) -> void:
	var lv: int = L.I
	var g := lv >= 5
	var p: Vector2 = S.call(0, -8)
	var R: float = STACKR[lv]
	var melt: Color = MOLTEN.lerp(GOLD, 0.6) if g else MOLTEN
	var pay := maxf(0.0, 1.0 - age / 1.4) if age >= 0.0 else 0.0
	var fl := 0.5 + 0.5 * sin(t * 6.3) * sin(t * 2.1 + 1.0)
	if lv >= 3:
		for sx in [-1.0, 1.0]:
			Draw.glow_dot(ci, p + Vector2(sx * 10.0, -27.0) * k, 0.8 * k, Color(melt, 0.6 + 0.4 * fl))
	if lv >= 2:
		var bs := 1.25 if lv >= 3 else 1.0
		var q2 := p + Vector2.from_angle(-0.75) * (R + 7.0 * bs) * k
		var r := 5.2 * bs
		var band_l: Color = GOLD.lightened(0.25) if g else Draw.METAL_L
		for j in 5:
			Draw.fill(ci, q2, PackedVector2Array([Vector2(0.6, -0.5), Vector2(r * 0.9, -1.4), Vector2(r * 0.9, 1.4), Vector2(0.6, 0.5)]), band_l, t * 14.0 + float(j) * TAU / 5.0, k)
		Draw.disc(ci, q2, 1.4 * k, gl(STEEL, g, 0.7))
	if lv >= 4:
		# The plasma core, arcing to the electrodes; it flares at a payout.
		var pc := R * (0.3 + 0.04 * fl + 0.06 * pay)
		Draw.disc(ci, p, pc * 1.5 * k, Color(ARCC, 0.25))
		Draw.disc(ci, p, pc * k, ARCC.lerp(Color(1, 1, 1), 0.5 + 0.3 * fl))
		Draw.glow_dot(ci, p, (1.8 + 1.5 * pay) * k, Color(1, 1, 1))
		for i in 6:
			if rnd(float(i) + floorf(t * 13.0) * 1.9) > 0.3:
				zap(ci, p + Vector2.from_angle(float(i) * TAU / 6.0 + 0.3) * R * 0.52 * k, p, float(i) * 5.0, 0.8 * k, t, k)
	else:
		# The molten core; it flares at a payout.
		Draw.disc(ci, p, R * 0.5 * k, Color(0.35, 0.08, 0.03).lerp(melt, 0.45 + 0.3 * fl + 0.25 * pay))
		Draw.ring(ci, p, R * 0.56 * k, Color(melt, 0.25 + 0.2 * fl + 0.4 * pay), 2.0 * k)
		Draw.disc(ci, p, R * (0.24 + 0.05 * fl + 0.1 * pay) * k, Color(HOTM, 0.9))
		Draw.glow_dot(ci, p, (2.0 + 2.2 * pay) * k, HOTM)
	# Gold Foundry (Gold Shell): glints running round the rim.
	if g:
		var a := t * 1.3
		Draw.arc(ci, p, R * k, a, a + 0.7, 8, Color(1, 1, 0.85, 0.9), 1.6 * k)
		Draw.arc(ci, p, R * 0.63 * k, -a, -a + 0.5, 6, Color(1, 1, 0.85, 0.8), 1.2 * k)


# --- The feed lines: a crane (a grab, or Magnet Crane's bridge magnet) loads a belt that drops the scrap into the stack -------------------

static func _feed_geo(F: Dictionary) -> Dictionary:
	var b0: Vector2 = F.b0
	var dir := (MOUTH - b0).normalized()
	var e := MOUTH - dir * FEND
	return {"dir": dir, "e": e, "lu": b0.distance_to(e), "lp": b0 + dir * 2.5}


static func _feed_static(ci: CanvasItem, S: Callable, L: Dictionary, k: float, F: Dictionary, _main: bool) -> void:
	var gm := _feed_geo(F)
	var b0: Vector2 = F.b0
	var e: Vector2 = gm.e
	conveyor(ci, S.call(b0.x, b0.y), S.call(e.x, e.y), k, L.K >= 5)


static func _feed_live(ci: CanvasItem, S: Callable, L: Dictionary, t: float, k: float, F: Dictionary, style: String, main: bool) -> void:
	var lv: int = L.K
	var g := lv >= 5
	var tt: float = t - float(F.ofs)
	var gm := _feed_geo(F)
	var b0: Vector2 = F.b0
	var dir: Vector2 = gm.dir
	var e: Vector2 = gm.e
	var lu: float = gm.lu
	var lp: Vector2 = gm.lp
	var v := FBELT * lu
	var ride := (lu - 2.5) / v
	var n := floorf(tt / FT)
	var steel := gl(STEEL, g, 0.7)
	var yel := gl(CRANE, g, 0.7)
	var dark: Color = GOLD.darkened(0.55) if g else Draw.METAL_D
	var P := func(q: Vector2) -> Vector2: return S.call(q.x, q.y)
	conveyor_slats(ci, P.call(b0), P.call(e), t, k)
	# The scrap rides up the belt and drops into the stack's mouth, glowing as it falls.
	for i in 4:
		var m := n - float(i)
		var a := tt - (m + 0.56) * FT
		var sd := m * 1.7 + 1.0 + float(F.ofs) * 5.0
		if a < 0.0:
			continue
		if a < ride:
			chunk(ci, P.call(b0 + dir * (a * v + 2.5)), 1.0, sd, k)
		else:
			var u := (a - ride) / 0.4
			if u < 1.0:
				chunk(ci, P.call(e.lerp(MOUTH, smooth(u))), 1.0 - 0.65 * u, sd, k, SCRAP.lerp(MOLTEN, u))
			elif u < 2.5:
				Draw.glow_dot(ci, P.call(MOUTH), (1.4 + 2.2 * (1.0 - (u - 1.0) / 1.5)) * k, Color(HOTM, 1.0 - (u - 1.0) / 1.5))
	# Laser Cutter (Laser Gantry): a gantry straddles the main belt; its laser head sweeps across it in a spray of sparks.
	if main and lv >= 3:
		_laser_gantry(ci, P, b0, dir, t, k, g)
	# The crane: grab at the heap, swing, drop on the belt's foot, swing back.
	var ph := fmod(tt / FT, 1.0)
	var sw := 0.0 if ph < 0.14 else (smooth((ph - 0.14) / 0.36) if ph < 0.5 else (1.0 if ph < 0.6 else 1.0 - smooth((ph - 0.6) / 0.4)))
	var op := 1.0 - ph / 0.14 if ph < 0.14 else (0.0 if ph < 0.5 else ((ph - 0.5) / 0.1 if ph < 0.6 else 1.0))
	var carry := n * 1.7 + 1.0 + float(F.ofs) * 5.0 if ph > 0.06 and ph < 0.56 else -1.0
	var heap: Vector2 = F.heap
	if style == "C":
		# Magnet Crane (Bridge Magnet): an overhead bridge on rails over the junkyard, its trolley magnet carrying the scrap.
		var mr: float = [0.0, 0.0, 3.0, 3.4, 3.8, 4.2][lv] if main else 3.4
		var tp := heap.lerp(lp, sw)
		var rl: Array = F.rails
		for x in [rl[0], rl[1]]:
			Draw.line(ci, S.call(x, rl[2]), S.call(x, rl[3]), Draw.OUTLINE, 2.6 * k)
			Draw.line(ci, S.call(x, rl[2]), S.call(x, rl[3]), steel, 1.4 * k)
			for y in [rl[2], rl[3]]:
				Draw.plate(ci, S.call(x, y), Draw.rect_pts(1.6, 0.9), dark, 0.0, k, 1.0)
		Draw.bar(ci, S.call(rl[0], tp.y), S.call(rl[1], tp.y), 2.6 * k, yel)
		for x in [rl[0], rl[1]]:
			Draw.plate(ci, S.call(x, tp.y), Draw.rect_pts(2, 2.6), dark, 0.0, k, 1.0)
		var q: Vector2 = P.call(tp)
		Draw.plate(ci, q, Draw.rect_pts(2.8, 2.2), dark, 0.0, k, 1.0)
		if carry >= 0.0:
			chunk(ci, q + Vector2(mr * 0.5, mr * 0.6) * k, 1.0, carry, k)
		if g:
			Draw.disc(ci, q, (mr + 2.2) * k, Color(GOLD, 0.3))
		Draw.disc(ci, q, (mr + 0.7) * k, Draw.OUTLINE)
		Draw.disc(ci, q, mr * k, GOLD.darkened(0.25) if g else Draw.METAL_D)
		Draw.ring(ci, q, mr * 0.62 * k, GOLD if g else KILL, 1.0 * k)
		Draw.disc(ci, q, mr * 0.3 * k, GOLD if g else Draw.METAL_L)
		if carry >= 0.0:
			Draw.glow_dot(ci, q, 0.7 * k, Color(0.7, 0.9, 1.0, 0.9))
		return
	# The grab crane on its pivot.
	var pvu: Vector2 = F.pv
	var pv: Vector2 = P.call(pvu)
	var ah := (heap - pvu).angle()
	var al := (lp - pvu).angle()
	var rh := pvu.distance_to(heap)
	var rl2 := pvu.distance_to(lp)
	var ang := ah + (al - ah) * sw
	var tip := pv + Vector2.from_angle(ang) * (rh + (rl2 - rh) * sw) * k
	Draw.disc(ci, pv + Vector2(1.5, 2) * k, 5.4 * k, Color(0, 0, 0, 0.3))
	Draw.disc(ci, pv, 5.4 * k, Draw.OUTLINE)
	Draw.disc(ci, pv, 4.6 * k, yel.darkened(0.15))
	Draw.bar(ci, pv, tip, 2.6 * k, yel)
	Draw.plate(ci, pv, Draw.rect_pts(3.2, 2.6), dark, ang, k, 1.1)
	if carry >= 0.0:
		chunk(ci, tip, 1.0, carry, k)
	for i in 4:
		var b := ang + float(i) * TAU / 4.0 + PI / 4.0
		Draw.line(ci, tip, tip + Vector2.from_angle(b) * (2.2 + 1.6 * op) * k, Draw.METAL_L, 1.3 * k)
	Draw.disc(ci, tip, 1.6 * k, Draw.METAL_D)


static func _laser_gantry(ci: CanvasItem, P: Callable, b0: Vector2, dir: Vector2, t: float, k: float, g: bool) -> void:
	var q := b0 + dir * 12.5
	var n := Vector2(-dir.y, dir.x)
	var ang := dir.angle()
	var dark: Color = GOLD.darkened(0.55) if g else Draw.METAL_D
	var cq := q - dir * 3.2
	var pu := 0.6 + 0.4 * sin(t * 9.0)
	var w := 0.6 + 0.4 * pu
	var la: Vector2 = P.call(cq - n * 4.2)
	var lb: Vector2 = P.call(cq + n * 4.2)
	Draw.line(ci, la, lb, Color(LASER, 0.3), 4.0 * w * k)
	Draw.line(ci, la, lb, LASER, 1.4 * w * k)
	Draw.line(ci, la, lb, Color(1, 0.88, 0.82, 0.95), 0.5 * w * k)
	for sg in [-1.0, 1.0]:
		_sparks(ci, P, cq + n * sg * 4.2 * sin(t * 2.4), 21.0 + sg, t, k)
	for e in [q - n * 7.0, q + n * 7.0]:
		Draw.plate(ci, P.call(e), Draw.rect_pts(2.4, 2.4), dark, ang, k, 1.2)
	Draw.bar(ci, P.call(q - n * 7.0), P.call(q + n * 7.0), 3.4 * k, gl(STEEL, g, 0.6))
	var hd := q + n * sin(t * 2.4) * 2.6
	Draw.plate(ci, P.call(hd), Draw.rect_pts(2.4, 2.6), gl(CRANE, g, 0.6), ang, k, 1.2)
	Draw.disc(ci, P.call(hd), 1.1 * k, LASER)
	Draw.glow_dot(ci, P.call(hd), 0.8 * k, LASER)
	_sparks(ci, P, hd, 3.0, t, k)


static func _sparks(ci: CanvasItem, P: Callable, p: Vector2, seed: float, t: float, k: float) -> void:
	for j in 7:
		var q := t * 2.6 + float(j) / 7.0
		var u := fmod(q, 1.0)
		var a := rnd(floorf(q) * 5.0 + float(j) + seed) * TAU
		Draw.disc(ci, P.call(p + Vector2.from_angle(a) * u * 4.5), (1.1 * (1.0 - u) + 0.25) * k, Color(1.0, 0.75 + 0.2 * rnd(float(j)), 0.35, 1.0 - u))
	Draw.glow_dot(ci, P.call(p), 0.9 * k, Color(1.0, 0.6, 0.5))
