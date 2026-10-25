extends RefCounted
## Cryo Tower art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_15_cryo.html, tools/tower_art/data_p2_cryo.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 coolant tank, 1 compressor, 2 deep cold) and the depth of each
## path, 5 on the path that took its mastery. a = Slowing, b = Power/Range, c = Speed. The tower never turns, so the housing, the frost
## crystals and the stations' bodies are cached; the stations' moving parts (the coil, the pump's piston, the drill, the reactors' rings),
## the fan, the radial compressor's impeller and the lights are live. `extra[0]` is how recently a wave went out (0..1) and speeds the fan.
## The wave itself, a creeping mist, is FxLayer's (`mist`).

const Draw = preload("res://scripts/view/Draw.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const ICE := Color(0.75, 0.92, 1.0)
const DEEP := Color(0.35, 0.60, 0.85)
const STEEL := Color(0.42, 0.45, 0.50)
const RIME := Color(0.94, 0.98, 1.0)

# The owner's picks per step: Slowing (Cooling Coils, Cryo Pumps, Permafrost Drills, Cryo Reactors, Gold-Core Reactors), Power/Range (all Ice
# Crystals), Speed (all Swept Fan); the Retrofits Round Housing, Radial Compressor and Frost Collar.
const SIZES := [0.0, 2.4, 2.9, 3.3, 3.7, 4.1]
const EDGE_LEN := [0.0, 2.4, 3.2, 4.2, 5.2, 6.0]
const CORNERS := [Vector2(-10, -10), Vector2(10, -10), Vector2(10, 10), Vector2(-10, 10)]
const EDGES := [Vector3(0, -12.2, -PI / 2.0), Vector3(0, 12.2, PI / 2.0), Vector3(-12.2, 0, PI), Vector3(12.2, 0, 0)]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "S": 0, "P": 0, "F": 0}
	return {"r": int(p[0]), "S": int(p[1]), "P": int(p[2]), "F": int(p[3])}


## One corner station: the Slowing path's picks, a different design at every step (a coil, a cryo pump, a drill bit, a cryo reactor,
## and a gold-cored reactor at the mastery). `live` draws the moving parts, the rest is cached.
static func station(ci: CanvasItem, p: Vector2, lv: int, k: float, t: float, i: int, sz: float, tr: Color, out: Vector2, live: bool) -> void:
	var oa := out.angle()
	match lv:
		1:
			if not live:
				Draw.disc(ci, p, sz * k + 1.0 * k, Draw.OUTLINE)
				Draw.disc(ci, p, sz * k, Draw.METAL_D)
				return
			var pts := PackedVector2Array()
			for j in 21:
				pts.append(p + Vector2.from_angle(float(j) * 0.9 + t * 0.6) * (sz * 0.25 + float(j) * sz * 0.034) * k)
			Draw.polyline(ci, pts, Color(ICE, 0.95), 1.4 * k)
			Draw.glow_dot(ci, p, 0.45 * k, tr)
		2:
			if not live:
				Draw.plate(ci, p, Draw.rect_pts(sz * 1.2, sz * 0.7), Draw.METAL_L, oa, k, 1.2)
				Draw.disc(ci, p - out * sz * 0.9 * k, sz * 0.55 * k, Color(ICE, 0.85))
				return
			var ph := sin(t * 6.0 + float(i)) * 0.8
			Draw.bar(ci, p - out * sz * k, p + out * (sz * 1.5 + ph) * k, 1.2 * k, STEEL)
			Draw.disc(ci, p + out * (sz * 1.5 + ph) * k, 1.0 * k, Draw.METAL_L)
		3:
			if not live:
				Draw.disc(ci, p, sz * k + 1.0 * k, Draw.OUTLINE)
				Draw.ring(ci, p, sz * 0.95 * k, Color(ICE, 0.9), 1.6 * k)
				return
			for j in 5:
				Draw.fill(ci, p, PackedVector2Array([Vector2(0.4, 0), Vector2(sz * 0.95, 0.5), Vector2(sz * 0.55, -0.7)]), Draw.METAL_L, t * 4.0 + float(j) * TAU / 5.0, k)
			Draw.glow_dot(ci, p, 0.5 * k, tr)
		4:
			if not live:
				Draw.plate(ci, p, Draw.ngon(6, 1.0, 0.0), Draw.METAL_L, PI / 6.0, sz * k, 1.2)
				Draw.plate(ci, p, Draw.ngon(6, 1.0, 0.0), Draw.METAL_D, PI / 6.0, sz * 0.7 * k, 0.9)
				return
			Draw.arc_segments(ci, p, sz * 0.9 * k, 3, 0.7, t * 1.5 + float(i), Color(tr, 0.95), 1.2 * k)
			Draw.glow_dot(ci, p, 0.7 * k * (1.0 + 0.3 * sin(t * 4.0 + float(i))), tr)
		_:
			var z := sz * 0.68
			if not live:
				Draw.plate(ci, p, Draw.ngon(6, 1.0, 0.0), Draw.METAL_L, PI / 6.0, z * k, 1.2)
				Draw.plate(ci, p, Draw.ngon(6, 1.0, 0.0), GOLD.darkened(0.5), PI / 6.0, z * 0.7 * k, 0.9)
				Draw.ring(ci, p, z * k + 1.0 * k, Color(GOLD, 0.7), 0.8 * k)
				return
			Draw.arc_segments(ci, p, z * 0.9 * k, 3, 0.7, t * 1.5 + float(i), Color(GOLD, 0.95), 1.2 * k)
			Draw.glow_dot(ci, p, 0.6 * k * (1.0 + 0.3 * sin(t * 4.0 + float(i))), GOLD)


static func draw(ci: CanvasItem, c: Vector2, _aim: float, s: float, t: float, _flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s
	var puff: float = clampf(float(extra[0]), 0.0, 1.0) if extra.size() > 0 and extra[0] != null else 0.0
	var gold_s: bool = L.S >= 5
	var gold_p: bool = L.P >= 5
	var gold_f: bool = L.F >= 5
	var fixed := func(x: float, y: float) -> Vector2: return c + Vector2(x, y) * k
	var round_box: bool = L.r == 0
	# The housing: square, or round with the Coolant Tank (Round Housing; no external tank).
	if round_box:
		Draw.disc(ci, c, 11.9 * k, Draw.OUTLINE)
		Draw.disc(ci, c, 11.4 * k, Draw.METAL_L)
		Draw.disc(ci, c, 10.2 * k, Draw.METAL_D)
	else:
		Draw.plate(ci, c, Draw.rect_pts(11.5, 11.5), Draw.METAL_L, 0.0, k, 1.3)
		Draw.plate(ci, c, Draw.rect_pts(10.2, 10.2), Draw.METAL_D, 0.0, k, 0.9)
	# Power/Range: ice crystals on the middle of each edge (round the rim of the round housing), more and longer at every step.
	if L.P > 0:
		var ln: float = EDGE_LEN[L.P]
		var n: int = L.P + 2
		for e in EDGES:
			var a: float = e.z
			var p: Vector2 = c + Vector2(e.x, e.y) * k
			var o := Vector2.from_angle(a).orthogonal()
			for j in range(-int(ceil(float(n) / 2.0)), int(ceil(float(n) / 2.0)) + 1):
				var aj := a + float(j) * 2.3 / 11.6
				var q: Vector2 = c + Vector2.from_angle(aj) * 11.2 * k if round_box else p + o * float(j) * 2.3 * k
				var ra := aj if round_box else a
				var h := ln * (1.0 - absf(float(j)) * 0.18)
				Draw.fill(ci, q, PackedVector2Array([Vector2(0, -1), Vector2(h * 0.5, -1.2), Vector2(h, 0), Vector2(h * 0.5, 1.2), Vector2(0, 1)]), ICE.lerp(DEEP, 0.2), ra, k)
				Draw.line(ci, q, q + Vector2.from_angle(ra) * h * k, Color(1, 1, 1, 0.7), 0.7 * k)
				if gold_p:
					Draw.glow_dot(ci, q + Vector2.from_angle(ra) * h * k, 0.5 * k, GOLD)
	# Slowing: a station in each corner, a different design at every step.
	var tr: Color = GOLD if gold_s else ICE
	if L.S > 0:
		for i in 4:
			var cp: Vector2 = CORNERS[i]
			station(ci, c + cp * k, L.S, k, t, i, SIZES[L.S], tr, cp.normalized(), false)
	# Compressor (Radial Compressor): an impeller in a snail casing on the right side.
	var imp: Vector2 = fixed.call(14.6, 0.0)
	if L.r == 1:
		Draw.fill(ci, imp, PackedVector2Array([Vector2(-3, -2.8), Vector2(1.5, -3.6), Vector2(4.2, -1), Vector2(4.4, 1.4), Vector2(1.8, 3.6), Vector2(-3, 3)]), Draw.METAL_L, 0.0, k)
		Draw.disc(ci, imp, 2.3 * k, Draw.OUTLINE)
		Draw.disc(ci, imp, 2.0 * k, Draw.METAL_D)
		Draw.bar(ci, imp + Vector2(3.8, 0) * k, imp + Vector2(6.0, 0) * k, 1.2 * k, STEEL)
	# The fan's well.
	Draw.disc(ci, c, 8.6 * k, Draw.OUTLINE)
	Draw.disc(ci, c, 8.0 * k, Draw.METAL_D)
	# --- Live: the stations' moving parts, the impeller, the fan. ---
	Draw.dyn(true)
	if L.S > 0:
		for i in 4:
			var cp2: Vector2 = CORNERS[i]
			station(ci, c + cp2 * k, L.S, k, t, i, SIZES[L.S], tr, cp2.normalized(), true)
	if L.r == 1:
		for j in 7:
			Draw.fill(ci, imp, PackedVector2Array([Vector2(0.3, 0), Vector2(2, 0.7), Vector2(1.8, -0.5)]), ICE, t * 14.0 + float(j) * TAU / 7.0, k)
	# The fan: swept turbine blades, more of them each Speed step (only the blades and the light turn gold at the mastery).
	var nb := 5 + mini(L.F, 4)
	var fc: Color = GOLD if gold_f else Draw.METAL_L
	var fan := t * (4.0 + 3.0 * float(L.F) + 12.0 * puff) * (1.3 if gold_f else 1.0)
	for j in nb:
		var a2 := fan + float(j) * TAU / float(nb)
		if L.F > 0:
			var pts := PackedVector2Array()
			for q in 6:
				pts.append(c + Vector2.from_angle(a2 + float(q) * 0.13) * (1.4 + float(q) * 1.15) * k)
			Draw.polyline(ci, pts, Draw.OUTLINE, 3.0 * k)
			Draw.polyline(ci, pts, fc, 1.8 * k)
		else:
			Draw.fill(ci, c, PackedVector2Array([Vector2(1.4, 0), Vector2(7, 1.8), Vector2(7, -1.4)]), fc, a2, k)
	Draw.dyn(false)
	Draw.ring(ci, c, 8.0 * k, Draw.METAL, 1.2 * k)
	Draw.orb(ci, c, 1.9 * k, Draw.METAL, k)
	# Deep Cold (Frost Collar): a frost-white collar with inward fins round the fan.
	if L.r == 2:
		Draw.ring(ci, c, 8.5 * k, Color(RIME, 0.95), 2.4 * k)
		for q in 12:
			var af := float(q) * TAU / 12.0
			Draw.fill(ci, c + Vector2.from_angle(af) * 8.5 * k, PackedVector2Array([Vector2(0, -0.7), Vector2(-2.2, 0), Vector2(0, 0.7)]), RIME, af, k)
	Draw.dyn(true)
	Draw.glow_dot(ci, c, (1.0 + puff) * k, GOLD if gold_f else acc)
	Draw.dyn(false)
