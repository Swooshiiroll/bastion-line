extends RefCounted
## Rocket Salvo art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_04_rocket.html, tools/tower_art/data_p2_rocket.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c" (Tower.look_key): the Retrofit (-1 none, 0 proximity noses, 1 smoke canisters,
## 2 fuel warheads) and the depth of each path, 5 on the path that took its mastery. a = Power, b = Range, c = Reload/Payload.
## The launcher turns with the aim (baked, turned by the cache); the blinking lights, the loader arm and the muzzle flashes
## are live.

const Draw = preload("res://scripts/view/Draw.gd")
const Gun = preload("res://scripts/view/towers/GunTurretArt.gd")

const STEEL := Color(0.42, 0.45, 0.50)
const RED := Color(0.90, 0.22, 0.20)
const YEL := Color(1.0, 0.85, 0.20)
const ORANGE := Color(1.0, 0.55, 0.20)
const SEEK := Color(0.35, 0.75, 1.0)
const DARKR := Color(0.22, 0.22, 0.24)
const PALE := Color(0.86, 0.88, 0.92)
const SMOKEC := Color(0.55, 0.57, 0.60)
const BORE := Color(0.05, 0.05, 0.06)
const TALL_H := 7.0

# The owner's picks per step: Power, Range, Reload/Payload.
const PICKS := [["B", "B", "A", "A", "A"], ["A", "A", "A", "A", "C"], ["A", "A", "B", "C", "B"]]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "P": 0, "R": 0, "N": 0}
	return {"r": int(p[0]), "P": int(p[1]), "R": int(p[2]), "N": int(p[3])}


static func kp(L: Dictionary, pi: int, k: int) -> String:
	var d: int = [L.P, L.R, L.N][pi]
	return PICKS[pi][k] if d > k else ""


static func at(c: Vector2, aim: float, k: float, x: float, y: float) -> Vector2:
	return Gun.at(c, aim, k, x, y)


## Launch tubes by Payload depth: pods [y, width], mouths [x, y, r, upper?].
static func layout(L: Dictionary) -> Dictionary:
	if L.N >= 5:
		var m: Array = []
		for sg in [-1.0, 1.0]:
			m.append([11.5, sg * 5.0, 1.4, 1])
			m.append([11.5, sg * 9.8, 1.4, 1])
			m.append([11.5, sg * 5.0, 1.4, 0])
			m.append([11.5, sg * 9.8, 1.4, 0])
		return {"pods": [[-7.4, 11.0], [7.4, 11.0]], "tall": true, "mouths": m, "gold": true}
	if L.N >= 3:
		var m2: Array = []
		for y in [-10.4, -7.2, -4.0, 4.0, 7.2, 10.4]:
			m2.append([11.0, y, 1.3, 0])
		return {"pods": [[-7.2, 11.0], [7.2, 11.0]], "mouths": m2}
	if L.N >= 1:
		var m3: Array = []
		for y in [-8.0, -2.7, 2.7, 8.0]:
			m3.append([11.5, y, 1.6, 0])
		return {"pods": [[-8.0, 5.4], [-2.7, 5.4], [2.7, 5.4], [8.0, 5.4]], "mouths": m3}
	return {"pods": [[-6.5, 5.2], [0.0, 5.2], [6.5, 5.2]], "mouths": [[11.5, -6.5, 2.1, 0], [11.5, 0.0, 2.1, 0], [11.5, 6.5, 2.1, 0]]}


## Where rocket `i` leaves the launcher.
static func muzzle(c: Vector2, aim: float, k: float, look: String, i: int) -> Vector2:
	var L := levels(look)
	var lay := layout(L)
	var ms: Array = lay.mouths
	var mo: Array = ms[i % ms.size()]
	var p := at(c, aim, k, float(mo[0]) + 0.5, float(mo[1]))
	if lay.get("tall", false):
		p += Vector2(0, (-TALL_H * 0.78 if int(mo[3]) == 1 else -TALL_H * 0.28) * k)
	return p


## A tall bank: a box with a shadow, its visible sides and a top, gold bands wrapped round it.
static func tall_box(ci: CanvasItem, c: Vector2, aim: float, k: float, x0: float, x1: float, y: float, w: float, col: Color) -> void:
	var up := Vector2(0, -TALL_H * k)
	var q: Array = []
	for pr in [[x0, y - w / 2.0], [x1, y - w / 2.0], [x1, y + w / 2.0], [x0, y + w / 2.0]]:
		q.append(at(c, aim, k, pr[0], pr[1]))
	var sh := PackedVector2Array()
	for p in q:
		sh.append(p + Vector2(4.0 * k, 6.0 * k))
	Draw.poly(ci, sh, Color(0, 0, 0, 0.25))
	var ctr0 := Vector2.ZERO
	for p in q:
		ctr0 += p
	ctr0 /= 4.0
	for i in 4:
		var a: Vector2 = q[i]
		var b: Vector2 = q[(i + 1) % 4]
		var m := (a + b) * 0.5
		if m.y - ctr0.y > 0.01:
			var face := PackedVector2Array([a, b, b + up, a + up])
			Draw.poly(ci, face, Draw.OUTLINE)
			var fc := (face[0] + face[2]) * 0.5
			var inner := PackedVector2Array()
			for p in face:
				inner.append(fc + (p - fc) * 0.9)
			Draw.poly(ci, inner, col.darkened(0.25 if i == 1 else 0.4))
	var top := PackedVector2Array()
	for p in q:
		top.append(p + up)
	Draw.poly(ci, top, Draw.OUTLINE)
	var ctr := (top[0] + top[1] + top[2] + top[3]) * 0.25
	var ti := PackedVector2Array()
	for p in top:
		ti.append(ctr + (p - ctr) * 0.92)
	Draw.poly(ci, ti, col)
	for fr in [0.2, 0.85]:
		Draw.line(ci, top[0].lerp(top[1], fr), top[3].lerp(top[2], fr), Draw.GOLD, 1.1 * k)
		for pr in [[0, 1], [3, 2]]:
			var mm: Vector2 = (q[pr[0]] + q[pr[1]]) * 0.5
			if mm.y - ctr0.y > 0.01:
				var pp: Vector2 = (q[pr[0]] as Vector2).lerp(q[pr[1]], fr)
				Draw.line(ci, pp, pp + up, Draw.GOLD, 1.1 * k)


static func draw(ci: CanvasItem, c: Vector2, aim: float, s: float, t: float, flash: float, look: String, acc: Color) -> void:
	var L := levels(look)
	var lay := layout(L)
	var k := s
	var tall: bool = lay.get("tall", false)
	var gold: bool = L.P >= 5
	var fl := clampf(flash / 0.15, 0.0, 1.0)
	var pod_len := 11.5
	var pods: Array = lay.pods
	# The launcher: blast deflector, cross frame, the loader arm's post (Reload 2), the conveyor (Reload 4).
	Draw.plate(ci, at(c, aim, k, -11.0, 0.0), Draw.rect_pts(1.6, 11.0), Draw.METAL_L, aim, k, 1.0)
	Gun.hazard(ci, c, aim, k, -12.0, -10.0, 0.0, acc, 1.2)
	for x in [-4.0, 6.0]:
		Draw.bar(ci, at(c, aim, k, x, -11.5), at(c, aim, k, x, 11.5), 2.4 * k, Draw.METAL_D.lightened(0.15))
	if L.N >= 4:
		Draw.bar(ci, at(c, aim, k, -9.0, 12.0), at(c, aim, k, -9.0, -12.0), 1.6 * k, Color(0.3, 0.3, 0.32))
	if L.N >= 2:
		Draw.orb(ci, at(c, aim, k, -7.0, 9.0), 1.5 * k, Draw.METAL, k)
	if tall:
		Draw.orb(ci, at(c, aim, k, -4.0, 0.0), 2.4 * k, Draw.METAL, k)
		Draw.glow_dot(ci, at(c, aim, k, -4.0, 0.0), 1.0 * k, acc)
		for pd in pods:
			tall_box(ci, c, aim, k, -8.0, pod_len, float(pd[0]), float(pd[1]), Draw.METAL_L)
	else:
		for pd in pods:
			var y: float = pd[0]
			var w: float = pd[1]
			if w > 8.0:
				var cx := (pod_len - 8.0) / 2.0
				Draw.plate(ci, at(c, aim, k, cx, y), Draw.rect_pts((pod_len + 8.0) / 2.0, w / 2.0), Draw.METAL_L, aim, k, 1.2)
				Draw.rivets(ci, at(c, aim, k, cx, y), Draw.rect_pts((pod_len + 8.0) / 2.0, w / 2.0), aim, k, 0.9, 0.7 * k)
			else:
				Draw.bar(ci, at(c, aim, k, -8.0, y), at(c, aim, k, pod_len, y), w * k, Draw.METAL_L)
			# Pod bands and kit: gold bands with the Payload mastery's bank; the Retrofit's canisters.
			if lay.get("gold", false) and kp(L, 2, 4) != "C":
				for x in [-2.0, 9.5]:
					Draw.line(ci, at(c, aim, k, x, y - w * 0.5), at(c, aim, k, x, y + w * 0.5), Draw.GOLD, 1.1 * k)
			if L.r == 1:
				Draw.bar(ci, at(c, aim, k, -6.0, y + w * 0.35), at(c, aim, k, -1.0, y + w * 0.35), 1.2 * k, SMOKEC)
	# The mouths, with the loaded rockets.
	var front := (not tall) or sin(aim) > 0.08
	var rocket_body: Color = DARKR if L.P >= 4 else PALE
	var nose: Color = SEEK if L.R >= 2 else (Draw.GOLD if L.P >= 5 else RED)
	if front:
		for i in lay.mouths.size():
			var m: Array = lay.mouths[i]
			var q := at(c, aim, k, float(m[0]), float(m[1]))
			if tall:
				q += Vector2(0, (-TALL_H * 0.78 if int(m[3]) == 1 else -TALL_H * 0.28) * k)
			var mr: float = m[2]
			Draw.disc(ci, q, (mr + 0.4) * k, Draw.OUTLINE)
			Draw.disc(ci, q, mr * k, BORE)
			if L.r == 0:
				Draw.line(ci, q, q + Vector2.from_angle(aim) * 1.8 * k, STEEL, 0.5 * k)
			Draw.orb(ci, q, mr * 0.8 * k, rocket_body, k)
			Draw.disc(ci, q + Vector2.from_angle(aim) * 0.4 * k, mr * 0.36 * k, nose)
	# The Hunter Eye on top at the Range mastery; otherwise the hub.
	if L.R >= 5:
		var e := at(c, aim, k, -1.0, 0.0)
		Draw.orb(ci, e, 2.4 * k, Draw.METAL, k)
		Draw.ring(ci, e, 2.6 * k, Draw.GOLD, 1.0 * k)
		Draw.glow_dot(ci, e, 1.0 * k, SEEK)
	if not tall:
		Draw.orb(ci, at(c, aim, k, -4.0, 0.0), 2.4 * k, Draw.METAL, k)
		Draw.glow_dot(ci, at(c, aim, k, -4.0, 0.0), 1.0 * k, acc)
	# Live: the seeker lights (Smart Seekers), the loader arm after each salvo, the muzzle flashes.
	Draw.dyn(true)
	if L.R >= 3:
		for pd in (pods if not tall else []):
			Draw.glow_dot(ci, at(c, aim, k, -6.0, float(pd[0])), 0.6 * k, SEEK if fmod(t * 2.0 + float(pd[0]), 1.0) < 0.5 else Color(SEEK, 0.3))
	if L.N >= 2:
		var b0 := at(c, aim, k, -7.0, 9.0)
		var a := aim + PI * 0.8 - fl * 0.8
		Draw.bar(ci, b0, b0 + Vector2.from_angle(a) * 7.0 * k, 1.2 * k, Draw.METAL_L)
	if fl > 0.0:
		for i in lay.mouths.size():
			Draw.glow_dot(ci, muzzle(c, aim, k, look, i), float(lay.mouths[i][2]) * k * fl, acc)
	Draw.dyn(false)
