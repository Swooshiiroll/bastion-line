extends RefCounted
## Mine Layer art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_11_mines.html, tools/tower_art/data_p2_mines.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 adhesive mines, 1 shaped charges, 2 long arm) and the depth of
## each path, 5 on the path that took its mastery. a = Power, b = Production Speed, c = Range. The launcher turns with the aim (baked);
## the fixed kit (belt, press lamps, the loader arm) and the flash are live. `extra[0]` is the number of mines laid so far (the twin
## launchers take turns). Mines on the track are drawn by `mine`.

const Draw = preload("res://scripts/view/Draw.gd")
const Gun = preload("res://scripts/view/towers/GunTurretArt.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const STEEL := Color(0.42, 0.45, 0.50)
const RED := Color(0.85, 0.20, 0.18)
const YEL := Color(1.0, 0.85, 0.20)
const ORANGE := Color(1.0, 0.55, 0.20)
const GEL := Color(0.65, 0.90, 0.20)
const WHITE := Color(1, 1, 1)

# The owner's picks per step: Power, Production, Range.
const PICKS := [["A", "B", "A", "A", "A"], ["C", "A", "A", "A", "A"], ["A", "A", "B", "A", "C"]]
const RANGES := [120.0, 140.0, 160.0, 190.0, 220.0, 260.0]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "P": 0, "B": 0, "R": 0}
	return {"r": int(p[0]), "P": int(p[1]), "B": int(p[2]), "R": int(p[3])}


static func kp(L: Dictionary, pi: int, k: int) -> String:
	var d: int = [L.P, L.B, L.R][pi]
	return PICKS[pi][k] if d > k else ""


static func rail_len(L: Dictionary) -> float:
	return 15.0 + [0.0, 1.5, 3.0, 4.5, 6.0, 8.0][mini(L.R, 5)] + (1.5 if L.r == 2 else 0.0)


static func at(c: Vector2, aim: float, k: float, x: float, y: float) -> Vector2:
	return Gun.at(c, aim, k, x, y)


## A thrown mine flies this long (s) on its arc, this high (px at k 1), then a ring marks where it lands.
const FLIGHT := 0.6
const LOB := 29.0
const LAND_RING := 0.3


## Where mine `n` leaves the launcher: the twin launchers (Twin Press) take turns.
static func muzzle(c: Vector2, aim: float, k: float, look: String, n := 0) -> Vector2:
	var L := levels(look)
	return at(c, aim, k, rail_len(L) * 0.4, (4.5 if n % 2 == 1 else -4.5) if L.B >= 2 else 0.0)


## A mine on the track, `age` seconds after it was thrown from `from`: in flight on its arc (a little smaller, not blinking),
## then landed with a fading ring, then waiting with its blinking band.
static func laid(ci: CanvasItem, p: Vector2, from: Vector2, age: float, t: float, look: String, acc: Color, blink: bool) -> void:
	if age < FLIGHT:
		var u := age / FLIGHT
		mine(ci, from.lerp(p, u) - Vector2(0, sin(PI * u) * LOB), 0.85, t, look, acc, false)
		return
	if age < FLIGHT + LAND_RING:
		var v := (age - FLIGHT) / LAND_RING
		Draw.ring(ci, p, 9.6 * v, Color(1, 1, 1, 0.5 * (1.0 - v)), 1.0)
	mine(ci, p, 1.0, t, look, acc, blink)


## A mine: a squat canister whose look follows the Power steps (a bigger canister, a charge core, a dark yellow-banded HE mine,
## segment lines, gold rings) and the Retrofit (a glossy gel coat). `mini` is a small one for the magazine; `thrown` adds the Wide
## Flange to a mine in flight or on the track.
static func mine(ci: CanvasItem, p: Vector2, k: float, t: float, look: String, acc: Color, blink: bool, mini := false, thrown := true) -> void:
	var L := levels(look)
	var z := (1.12 if L.P >= 1 else 1.0) * (1.25 if L.P >= 5 else 1.0) * (0.55 if mini else 1.0)
	var r := 3.6 * k * z
	Draw.ellipse(ci, p + Vector2(k * 0.8, k * 1.6), 4.0 * k * z, 1.8 * k * z, Color(0, 0, 0, 0.3))
	if thrown and not mini and kp(L, 0, 1) == "B":
		Draw.disc(ci, p, r * 1.3, Draw.OUTLINE)
		Draw.disc(ci, p, r * 1.22, STEEL)
		for i in 8:
			Draw.disc(ci, p + Vector2.from_angle(float(i) * TAU / 8.0 + 0.2) * r * 1.22, 0.45 * k * z, Draw.METAL_L)
	Draw.disc(ci, p, r, Draw.OUTLINE)
	Draw.disc(ci, p, r * 0.86, Color(0.2, 0.2, 0.22) if L.P >= 3 else Draw.METAL_L)
	if L.P >= 1:
		Draw.disc(ci, p, r * 0.42, Color(0.12, 0.12, 0.14))
		Draw.ring(ci, p, r * 0.42, WHITE, 0.5 * k * z)
	if L.P >= 5:
		Draw.ring(ci, p, r * 0.95, GOLD, 1.0 * k)
		Draw.ring(ci, p, r * 0.55, GOLD, 0.7 * k)
	if L.P >= 3:
		Draw.ring(ci, p, r * 0.62, YEL, 0.9 * k * z)
	if L.P >= 4:
		for i in 6:
			Draw.line(ci, p + Vector2.from_angle(float(i) * TAU / 6.0) * r * 0.25, p + Vector2.from_angle(float(i) * TAU / 6.0) * r * 0.85, Color(0, 0, 0, 0.5), 0.5 * k)
	if L.r == 0:
		Draw.disc(ci, p, r * 1.05, Color(GEL, 0.55))
		for i in 5:
			Draw.disc(ci, p + Vector2.from_angle(float(i) * TAU / 5.0 + 0.4) * r * 1.05, 0.5 * k * z, GEL)
	if L.r == 1:
		Draw.plate(ci, p + Vector2(r * 0.15, -r * 0.1), Draw.rect_pts(0.9, 1.3), STEEL, 0.0, k * z, 0.7)
	Draw.ring(ci, p, r * 0.6, Color(GOLD if L.P >= 5 else acc, 1.0 if blink else 0.5), 0.9 * k * z)
	Draw.disc(ci, p, r * 0.3, Draw.METAL)
	if blink:
		Draw.glow_dot(ci, p, 1.2 * k * z, GOLD if L.P >= 5 else acc)


static func draw(ci: CanvasItem, c: Vector2, aim: float, s: float, t: float, flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s
	var n: int = int(extra[0]) if extra.size() > 0 and extra[0] != null else 0
	var fl := clampf(flash / 0.12, 0.0, 1.0)
	var len := rail_len(L)
	var gold: bool = L.P >= 5
	var col := acc
	# --- Fixed, live: the belt that feeds the mount, the loader arm, the press lamps. ---
	Draw.dyn(true)
	var fixed := func(x: float, y: float) -> Vector2: return c + Vector2(x, y) * k
	if L.B >= 3 or L.B >= 5:
		var from: Vector2 = fixed.call(-15.0, 10.0)
		Draw.bar(ci, from, c, 2.8 * k, GOLD if L.B >= 5 else Draw.METAL_D)
		Draw.line(ci, from, c, Color(0, 0, 0, 0.4), 0.6 * k)
		for i in 4:
			var u := fmod(t * 0.45 + float(i) / 4.0, 1.0)
			if u < 0.82:
				mine(ci, from.lerp(c, u), k * 0.5, t, look, acc, false, true)
	if L.B >= 1:
		var q: Vector2 = fixed.call(-12.0, 8.0)
		var a := PI * 1.25 + fl * 1.2
		Draw.orb(ci, q, 1.5 * k, Draw.METAL, k)
		Draw.bar(ci, q, q + Vector2.from_angle(a) * 5.0 * k, 1.3 * k, Draw.METAL_L)
		Draw.disc(ci, q + Vector2.from_angle(a) * 5.4 * k, 0.9 * k, STEEL)
	if L.B >= 4:
		for sa in [PI * 0.62, PI * 1.38]:
			var lq: Vector2 = c + Vector2.from_angle(sa) * 10.4 * k
			Draw.plate(ci, lq, Draw.rect_pts(1.8, 1.3), Draw.METAL_D, sa, k, 0.9)
			Draw.glow_dot(ci, lq + Vector2.from_angle(sa) * 0.2 * k, 0.45 * k, ORANGE if fmod(t * 5.0, 1.0) < 0.5 else Color(ORANGE, 0.3))
	Draw.dyn(false)
	# --- The round mount, then the turning launcher(s). ---
	Draw.disc(ci, c, 10.0 * k, Draw.OUTLINE)
	Draw.disc(ci, c, 9.2 * k, Draw.METAL)
	if L.B >= 4:
		var w := 0.8 + 0.5 * float(L.B - 3)
		Draw.dyn(true)
		for i in 16:
			var an := float(i) * TAU / 16.0 + t * w
			Draw.line(ci, c + Vector2.from_angle(an) * 8.3 * k, c + Vector2.from_angle(an) * 9.3 * k, Color(GOLD if gold else Draw.METAL_L, 0.85), 0.8 * k)
		Draw.dyn(false)
	# The magazine: three canisters behind the mount.
	for i in 3:
		mine(ci, at(c, aim, k, -6.0, float(i - 1) * 4.2), k * 0.55, t, look, acc, false, true, false)
	var launchers: Array = [4.5, -4.5] if L.B >= 2 else [0.0]
	var hf := 2.6
	for yc in launchers:
		var ry: Array = [yc - hf, yc + hf]
		for y in ry:
			Draw.bar(ci, at(c, aim, k, -2.0, y), at(c, aim, k, len, y), 1.8 * k, Draw.METAL_L.lerp(GOLD, 0.5) if L.R >= 5 else Draw.METAL_L)
		var x := 3.0
		while x < len - 2.0:
			Draw.bar(ci, at(c, aim, k, x, yc - hf - 1.4), at(c, aim, k, x, yc + hf + 1.4), 1.4 * k, col.darkened(0.2))
			x += 6.0
		if L.R >= 2:
			for y in ry:
				for i in 4:
					Draw.line(ci, at(c, aim, k, 1.0 + float(i) * 3.0, y - 1.0), at(c, aim, k, 2.4 + float(i) * 3.0, y + 1.0), STEEL, 1.0 * k)
		if L.R >= 3:
			Draw.plate(ci, at(c, aim, k, 0.0, yc), Draw.rect_pts(2.6, hf + 2.4), Draw.METAL_D, aim, k, 1.0)
		if L.R >= 5:
			for y in [yc - hf - 2.0, yc + hf + 2.0]:
				Draw.bar(ci, at(c, aim, k, 2.0, y), at(c, aim, k, len - 3.0, y), 1.0 * k, GOLD)
	Draw.dyn(true)
	for yc in launchers:
		var act := fl if (launchers.size() == 1 or (n % 2 == (1 if yc > 0.0 else 0))) else 0.0
		Draw.strip(ci, at(c, aim, k, 0.0, yc), at(c, aim, k, len, yc), 0.6 * k, Color(col, 0.3 + 0.7 * act))
	Draw.dyn(false)
	# The hub's central eye.
	Draw.orb(ci, c, 3.8 * k, Draw.METAL, k)
	Draw.ring(ci, c, 3.8 * k, Draw.OUTLINE, 1.0 * k)
	Draw.glow_dot(ci, c, 1.8 * k, GOLD if gold else col)
