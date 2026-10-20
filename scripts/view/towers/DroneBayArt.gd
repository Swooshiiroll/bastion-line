extends RefCounted
## Drone Bay art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_09_drones.html, tools/tower_art/data_p2_drones.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 the second pad) and the depth of each path, 5 on the path that
## took its mastery. a = Power, b = Weaponry, c = Speed. The bay is fixed and cached; `extra` is [loadout index, docked]: the
## loadout selector's pointer, and whether the drones are still on their pads. The drones are drawn by `drone`, one per wing entry.

const Draw = preload("res://scripts/view/Draw.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const STEEL := Color(0.42, 0.45, 0.50)
const RED := Color(0.85, 0.20, 0.18)
const ORANGE := Color(1.0, 0.55, 0.20)
const CYAN := Color(0.40, 0.90, 1.0)
const WHITE := Color(1, 1, 1)
const LOADOUT_COLORS := {"gun": Color(0.85, 0.85, 0.85), "missiles": RED, "bombs": ORANGE, "laser": CYAN, "full": GOLD}

# The owner's picks per step: Power, Weaponry, Speed.
const PICKS := [["A", "A", "B", "A", "A"], ["A", "A", "A", "B", "C"], ["C", "A", "A", "A", "A"]]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "P": 0, "W": 0, "S": 0}
	return {"r": int(p[0]), "P": int(p[1]), "W": int(p[2]), "S": int(p[3])}


static func kp(L: Dictionary, pi: int, k: int) -> String:
	var d: int = [L.P, L.W, L.S][pi]
	return PICKS[pi][k] if d > k else ""


static func pads(L: Dictionary) -> Array:
	return [Vector2(-6.4, 0), Vector2(6.4, 0)] if L.r >= 0 else [Vector2(0, 0)]


static func pad_radius(L: Dictionary) -> float:
	return 5.2 if L.r >= 0 else 7.4


## The tracer's look from Power: width, colour (hot orange, gold at the mastery) and whether it has a white core.
static func tracer_style(look: String, acc: Color) -> Dictionary:
	var L := levels(look)
	return {"w": 1.3 + 0.3 * float(L.P), "col": GOLD if L.P >= 5 else (ORANGE if L.P >= 2 else acc), "core": L.P >= 3, "double": L.P >= 4}


static func rotor(ci: CanvasItem, p: Vector2, r: float, t: float, k: float) -> void:
	Draw.disc(ci, p, r, Color(0.8, 0.85, 0.95, 0.12))
	Draw.ring(ci, p, r, Color(0.8, 0.86, 0.95, 0.35), 0.8)
	for q in 2:
		Draw.line(ci, p, p + Vector2.from_angle(t * 40.0 + float(q) * PI) * r * 0.92, Color(0.85, 0.9, 1.0, 0.6), 0.5 * k)


## One drone: a quadcopter whose gun, pods and racks follow the picks. `spin` scales the rotors (docked drones idle slowly).
static func drone(ci: CanvasItem, p: Vector2, dir: float, k: float, t: float, look: String, acc: Color, spin := 1.0) -> void:
	var L := levels(look)
	var d := Vector2.from_angle(dir)
	var gold: bool = L.P >= 5
	var hard := 1.25 if L.W >= 4 else 1.0
	var frame_c: Color = GOLD if kp(L, 0, 4) == "A" else Draw.METAL_D
	var rot_c: Color = GOLD if kp(L, 0, 4) == "B" else Color(0, 0, 0, 0)
	var at := func(x: float, y: float) -> Vector2: return p + (d * x + d.orthogonal() * y) * k
	for i in 4:
		Draw.bar(ci, p, p + Vector2.from_angle(dir + PI / 4.0 + float(i) * PI / 2.0) * 4.1 * k, 0.9 * k, frame_c)
	Draw.plate(ci, p, Draw.rect_pts(2.6, 2.0), GOLD.lightened(0.1) if kp(L, 0, 4) == "A" else Draw.METAL_L, dir, k, 0.9)
	if kp(L, 0, 2) == "B":
		Draw.glow_dot(ci, at.call(-1.0, 0.6), 0.45 * k, Color(0.4, 1.0, 0.5) if fmod(t * 3.0, 1.0) < 0.5 else Color(0.2, 0.4, 0.25))
	# The gun: one barrel, longer and thicker with Heavy Chin Gun; Hot Barrel Shroud wraps it in orange; the rotary cluster is
	# Rotary Guns' own pick (a spinning three-barrel cluster).
	var barrel_c: Color = GOLD if (kp(L, 0, 4) == "C" or kp(L, 2, 4) == "A") else Draw.METAL
	var bw := (0.9 + (0.5 if kp(L, 0, 0) == "A" else 0.0)) * k
	var sp := t * 3.0
	if kp(L, 2, 2) == "A":
		for j in 3:
			var a := sp + float(j) * TAU / 3.0
			var off := sin(a) * 0.55
			Draw.bar(ci, at.call(1.6, off), at.call(4.4, off), 0.45 * k, barrel_c)
		Draw.disc(ci, at.call(1.8, 0.0), 0.9 * k, Draw.OUTLINE)
		Draw.disc(ci, at.call(1.8, 0.0), 0.65 * k, Draw.METAL_L)
	else:
		Draw.bar(ci, at.call(1.5, 0.0), at.call(4.2 + (0.4 if kp(L, 0, 0) == "A" else 0.0), 0.0), bw, barrel_c)
	if kp(L, 0, 1) == "A":
		Draw.bar(ci, at.call(2.2, 0.0), at.call(3.2, 0.0), bw * 0.98, ORANGE)
	if kp(L, 2, 0) == "C":
		Draw.glow_dot(ci, at.call(-2.0, -1.3), 0.4 * k, Color(0.4, 1.0, 0.5))
	if kp(L, 2, 1) == "A":
		for sg in [-1.0, 1.0]:
			Draw.line(ci, at.call(-0.5, sg * 1.2), at.call(1.8, sg * 0.6), STEEL, 0.6 * k)
	if kp(L, 2, 3) == "A":
		Draw.plate(ci, at.call(-1.4, 1.4), Draw.rect_pts(0.8, 0.5), Draw.METAL_D, dir, k, 0.7)
		Draw.glow_dot(ci, at.call(-1.4, 1.4), 0.3 * k, ORANGE if fmod(t * 6.0, 1.0) < 0.5 else Color(ORANGE, 0.3))
	# Weaponry: the missile pods (a pair of small pods), the loadout parts.
	var wl := func(cc: Color) -> Color: return GOLD if kp(L, 1, 4) == "C" else cc
	if kp(L, 1, 0) == "A":
		for sg in [-1.0, 1.0]:
			Draw.bar(ci, at.call(0.6, sg * 2.4), at.call(-0.8, sg * 2.4), 1.1 * hard * k, Draw.METAL)
			Draw.disc(ci, at.call(0.7, sg * 2.4), 0.5 * k, wl.call(RED))
	if kp(L, 1, 1) == "A":
		Draw.plate(ci, at.call(-0.2, 0.0), Draw.rect_pts(1.3, 0.7), Draw.METAL_D, dir, k, 0.7)
	if kp(L, 1, 2) == "A":
		Draw.disc(ci, at.call(2.2, 0.9), 0.45 * k, Color(CYAN, 0.8))
	if kp(L, 1, 3) == "B":
		for sg in [-1.0, 1.0]:
			Draw.line(ci, at.call(-0.6, sg * 1.8), at.call(0.6, sg * 2.4), STEEL, 0.5 * k)
	if kp(L, 1, 4) == "C":
		for sg in [-1.0, 1.0]:
			Draw.line(ci, at.call(0.0, sg * 1.8), at.call(0.0, sg * 3.2), GOLD, 0.8 * k)
	Draw.glow_dot(ci, at.call(1.2, 0.0), 0.8 * k, GOLD if gold else acc)
	# The rotors turn above the arms and the body.
	for i in 4:
		var q: Vector2 = p + Vector2.from_angle(dir + PI / 4.0 + float(i) * PI / 2.0) * 4.1 * k
		rotor(ci, q, 2.05 * k, t * spin, k)
		if rot_c.a > 0.0:
			Draw.ring(ci, q, 2.05 * k, Color(rot_c, 0.9), 0.8 * k)


static func draw(ci: CanvasItem, c: Vector2, _aim: float, s: float, t: float, _flash: float, look: String, acc: Color, extra: Array) -> void:
	var L := levels(look)
	var k := s
	var loadout_i: int = int(extra[0]) if extra.size() > 0 and extra[0] != null else 0
	var docked: bool = bool(extra[1]) if extra.size() > 1 and extra[1] != null else true
	var pd := pads(L)
	var pr := pad_radius(L)
	var col := acc
	# --- Cached: the hangar plate, its pads, the beacon, the loadout selector's dial. ---
	Draw.plate(ci, c, Draw.rect_pts(13.0, 13.0), Draw.METAL_D, 0.0, k, 1.3)
	Draw.rivets(ci, c, Draw.rect_pts(13.0, 13.0), 0.0, k, 0.88, 0.8 * k)
	for q in pd:
		var pc: Vector2 = c + q * k
		Draw.ring(ci, pc, pr * k, Color(col, 0.6), 1.2 * k)
		for dx in [-pr * 0.35, pr * 0.35]:
			Draw.line(ci, pc + Vector2(dx, -pr * 0.35) * k, pc + Vector2(dx, pr * 0.35) * k, Color(col, 0.75), 1.1 * k)
		Draw.line(ci, pc + Vector2(-pr * 0.35, 0.0) * k, pc + Vector2(pr * 0.35, 0.0) * k, Color(col, 0.75), 1.1 * k)
	Draw.bar(ci, c + Vector2(10, 10) * k, c + Vector2(10, -3) * k, 1.0 * k, Draw.METAL_L)
	var types: Array = ["gun"]
	for i in mini(3, L.W):
		types.append(["missiles", "bombs", "laser"][i])
	if L.W >= 5:
		types.append("full")
	if L.W >= 1:
		var dq := c + Vector2(-9.5, 9.0) * k
		Draw.disc(ci, dq, 3.6 * k, Draw.OUTLINE)
		Draw.disc(ci, dq, 3.0 * k, Draw.METAL)
		for i in types.size():
			Draw.glow_dot(ci, dq + Vector2.from_angle(-PI / 2.0 + float(i) * TAU / float(types.size())) * 1.9 * k, 0.6 * k, LOADOUT_COLORS[types[i]])
		if L.W >= 5:
			Draw.ring(ci, dq, 3.6 * k, GOLD, 1.0 * k)
	# --- Live: the beacon's blink, the dial's pointer, drones docked on their pads. ---
	Draw.dyn(true)
	if fmod(t * 1.3, 1.0) < 0.4:
		Draw.glow_dot(ci, c + Vector2(10, -3.8) * k, 1.1 * k, Color(1.0, 0.3, 0.3))
	if L.W >= 1:
		var dq2 := c + Vector2(-9.5, 9.0) * k
		var idx := clampi(loadout_i, 0, types.size() - 1)
		Draw.line(ci, dq2, dq2 + Vector2.from_angle(-PI / 2.0 + float(idx) * TAU / float(types.size())) * 1.7 * k, WHITE, 0.9 * k)
	if docked:
		for q in pd:
			drone(ci, c + q * k, -PI / 2.0, k, t, look, acc, 0.4)
	Draw.dyn(false)
