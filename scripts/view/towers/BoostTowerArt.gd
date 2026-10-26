extends RefCounted
## Boost Tower art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_13_boost.html, tools/tower_art/data_p2_boost.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 signal booster, 1 crit link, 2 wide mast) and the depth of each
## path, 5 on the path that took its mastery. a = Damage boost, b = Speed boost, c = Range boost. A round drum with three struts and
## one disc-shaped module per path (orange, cyan, lime) that fades further toward gold with every step. The tower never turns.

const Draw = preload("res://scripts/view/Draw.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const STEEL := Color(0.42, 0.45, 0.50)
const SCOL := [Color(1.0, 0.5, 0.2), Color(0.4, 0.9, 1.0), Color(0.7, 1.0, 0.3)]

# The owner's picks: every step of every path is the ringed disc (B).


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "D": 0, "S": 0, "R": 0}
	return {"r": int(p[0]), "D": int(p[1]), "S": int(p[2]), "R": int(p[3])}


static func draw(ci: CanvasItem, c: Vector2, _aim: float, s: float, t: float, _flash: float, look: String, acc: Color, _extra: Array) -> void:
	var L := levels(look)
	var k := s
	var col := acc
	var lvs: Array = [L.D, L.S, L.R]
	var wide: bool = L.r == 2
	var crown: bool = L.r == 1
	# The drum and its three struts.
	for i in 3:
		var d := Vector2.from_angle(PI / 2.0 + float(i) * TAU / 3.0)
		Draw.bar(ci, c + d * 9.0 * k, c + d * 14.0 * k, 2.0 * k, Draw.METAL)
	Draw.disc(ci, c, 11.0 * k, Draw.OUTLINE)
	Draw.disc(ci, c, 10.3 * k, Draw.METAL_L)
	Draw.disc(ci, c, 8.6 * k, Draw.METAL_D)
	# One module per path: a disc with an inner ring and a core, fading from its colour toward gold with every step.
	for st in 3:
		var lv: int = lvs[st]
		var a := PI / 2.0 + float(st) * TAU / 3.0
		var q := c + Vector2.from_angle(a) * 6.2 * k
		var fade := float(lv) / 5.0
		var mc: Color = SCOL[st].lerp(GOLD, fade)
		var r := 3.2 * k
		Draw.disc(ci, q, r + 0.6 * k, Draw.OUTLINE)
		Draw.disc(ci, q, r, mc.darkened(0.45))
		if lv == 0:
			Draw.ring(ci, q, r * 0.6, Color(SCOL[st], 0.5), 0.9 * k)
			continue
		Draw.disc(ci, q, r * 0.88, Draw.METAL_L.lerp(mc, 0.8 + 0.2 * fade))
		Draw.ring(ci, q, r * 0.58, Color(mc.darkened(0.3), 0.9), 1.0 * k)
		Draw.disc(ci, q, r * 0.3, mc)
	# The Retrofits: a spire (Signal Booster), a gold crown of teeth (Crit Link), a ring with ticks (Wide Mast).
	if L.r == 0:
		Draw.fill(ci, c, PackedVector2Array([Vector2(0, -5.4), Vector2(1.8, 1.8), Vector2(-1.8, 1.8)]), Draw.METAL_L, 0.0, k)
		Draw.ring(ci, c, 2.4 * k, Draw.METAL, 1.0 * k)
	if crown:
		for i in 12:
			var an := float(i) * TAU / 12.0
			Draw.fill(ci, c + Vector2.from_angle(an) * 11.2 * k, PackedVector2Array([Vector2(0, -0.9), Vector2(2.2, 0), Vector2(0, 0.9)]), GOLD, an, k)
	if wide:
		Draw.ring(ci, c, 13.0 * k, Draw.METAL_L, 1.6 * k)
		for i in 6:
			Draw.line(ci, c + Vector2.from_angle(float(i) * TAU / 6.0) * 11.0 * k, c + Vector2.from_angle(float(i) * TAU / 6.0) * 13.0 * k, Draw.METAL_L, 1.2 * k)
	# --- Live: the beat rippling out of the drum, the modules' pulse, the centre light. ---
	Draw.dyn(true)
	var beat := fmod(t * 1.2, 1.0)
	for i in 3:
		var rr := fmod(beat + float(i) / 3.0, 1.0)
		Draw.ring(ci, c, (2.0 + 6.4 * rr) * k, Color(col, 0.6 * (1.0 - rr)), 1.1 * k)
	for st in 3:
		var lv2: int = lvs[st]
		var q2 := c + Vector2.from_angle(PI / 2.0 + float(st) * TAU / 3.0) * 6.2 * k
		Draw.glow_dot(ci, q2, 0.55 * k * (1.0 + 0.35 * sin(t * 5.0 + float(st))), SCOL[st].lerp(GOLD, float(lv2) / 5.0))
	if L.r == 0:
		Draw.glow_dot(ci, c + Vector2(0, -5.6 * k), 0.7 * k, Color(1.0, 0.3, 0.3))
	Draw.glow_dot(ci, c, (1.2 + 0.8 * (1.0 - beat)) * k, col)
	Draw.dyn(false)
