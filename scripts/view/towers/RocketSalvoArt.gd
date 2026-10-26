extends RefCounted
## Rocket Salvo art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_04_rocket.html, tools/tower_art/data_p2_rocket.js) with the owner's picks hard-coded.
##
## `look` is the tower's look key "r|a|b|c" (Tower.look_key): the Retrofit (-1 none, 0 proximity noses, 1 smoke canisters,
## 2 fuel warheads) and the depth of each path, 5 on the path that took its mastery. a = Power, b = Range, c = Reload/Payload.
## The launcher turns with the aim (baked, turned by the cache); the loaded rockets, the blinking lights, the loader arm and
## the muzzle flashes are live. The Payload mastery's Launch Cells (#104) never turn: eight cells in an armoured deck, their
## hatches opening as the rockets ripple out (see still()). `extra` is [reload look 0..1 (ready_of), seconds since the last salvo].

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
## Seconds between the rockets of a rippling salvo (Payload mastery); the game holds each rocket this much longer.
const RIPPLE_GAP := 0.09

# The owner's picks per step: Power, Range, Reload/Payload.
const PICKS := [["B", "B", "A", "A", "A"], ["A", "A", "A", "A", "C"], ["A", "A", "B", "C", "D"]]
## The Launch Cells: how far the cells sit from the centre, and how wide the armoured deck is.
const CELL_R := 9.6
const DECK_R := 15.0


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


## Whether the launcher stays still: the Launch Cells (Payload mastery) are set in the deck, so the cache doesn't turn them.
static func still(look: String) -> bool:
	return levels(look).N >= 5


## Launch tubes by Payload depth: pods [y, width], mouths [x, y, r, upper?]. The Launch Cells' mouths are the cells, in
## world space (x right, y down), not along the aim.
static func layout(L: Dictionary) -> Dictionary:
	if L.N >= 5:
		var m: Array = []
		for i in 8:
			var a := float(i) * TAU / 8.0 + PI / 8.0
			m.append([cos(a) * CELL_R, sin(a) * CELL_R, 1.4, 0])
		return {"pods": [], "cells": true, "mouths": m}
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


## Where rocket `i` leaves the launcher: its tube's mouth, `fwd` in front of it. The game launches each rocket from here (#90).
static func muzzle(c: Vector2, aim: float, k: float, look: String, i: int, fwd := 0.5) -> Vector2:
	var L := levels(look)
	var lay := layout(L)
	var ms: Array = lay.mouths
	var mo: Array = ms[i % ms.size()]
	if lay.get("cells", false):
		return c + Vector2(float(mo[0]), float(mo[1])) * k
	return at(c, aim, k, float(mo[0]) + fwd, float(mo[1]))


## How loaded tube `i` is (0 empty, 1 a full rocket) from `ready` (the reload: empty for its first quarter, then the rockets
## slide back in) and `since` (seconds since the salvo; a rippling salvo empties its tubes one after another).
static func loaded(L: Dictionary, i: int, ready: float, since: float) -> float:
	if L.N >= 5 and since < float(i) * RIPPLE_GAP:
		return 1.0
	return ready


## The reload's look from the tower's cooldown: 0 just after a salvo, 1 for its last quarter.
static func ready_of(cooldown: float, period: float) -> float:
	var since := period - cooldown
	return clampf((since - 0.25 * period) / maxf(0.5 * period, 0.001), 0.0, 1.0)


static func draw(ci: CanvasItem, c: Vector2, aim: float, s: float, t: float, flash: float, look: String, acc: Color, extra: Array = []) -> void:
	var L := levels(look)
	var ready: float = float(extra[0]) if extra.size() > 0 and extra[0] != null else 1.0
	var since: float = float(extra[1]) if extra.size() > 1 and extra[1] != null else 99.0
	var lay := layout(L)
	var k := s
	if lay.get("cells", false):
		draw_cells(ci, c, k, lay, L, ready, since, acc)
		return
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
	for pd in pods:
		var y: float = pd[0]
		var w: float = pd[1]
		if w > 8.0:
			var cx := (pod_len - 8.0) / 2.0
			Draw.plate(ci, at(c, aim, k, cx, y), Draw.rect_pts((pod_len + 8.0) / 2.0, w / 2.0), Draw.METAL_L, aim, k, 1.2)
			Draw.rivets(ci, at(c, aim, k, cx, y), Draw.rect_pts((pod_len + 8.0) / 2.0, w / 2.0), aim, k, 0.9, 0.7 * k)
		else:
			Draw.bar(ci, at(c, aim, k, -8.0, y), at(c, aim, k, pod_len, y), w * k, Draw.METAL_L)
		# The Retrofit's smoke canisters on every pod.
		if L.r == 1:
			Draw.bar(ci, at(c, aim, k, -6.0, y + w * 0.35), at(c, aim, k, -1.0, y + w * 0.35), 1.2 * k, SMOKEC)
	# The mouths (the loaded rockets in them are live, below).
	var rocket_body: Color = DARKR if L.P >= 4 else PALE
	var nose: Color = SEEK if L.R >= 2 else (Draw.GOLD if L.P >= 5 else RED)
	for i in lay.mouths.size():
		var q := muzzle(c, aim, k, look, i, 0.0)
		var mr: float = lay.mouths[i][2]
		Draw.disc(ci, q, (mr + 0.4) * k, Draw.OUTLINE)
		Draw.disc(ci, q, mr * k, BORE)
		if L.r == 0:
			Draw.line(ci, q, q + Vector2.from_angle(aim) * 1.8 * k, STEEL, 0.5 * k)
	# The Hunter Eye on top at the Range mastery; otherwise the hub.
	if L.R >= 5:
		var e := at(c, aim, k, -1.0, 0.0)
		Draw.orb(ci, e, 2.4 * k, Draw.METAL, k)
		Draw.ring(ci, e, 2.6 * k, Draw.GOLD, 1.0 * k)
		Draw.glow_dot(ci, e, 1.0 * k, SEEK)
	Draw.orb(ci, at(c, aim, k, -4.0, 0.0), 2.4 * k, Draw.METAL, k)
	Draw.glow_dot(ci, at(c, aim, k, -4.0, 0.0), 1.0 * k, acc)
	# Live: the loaded rockets (gone when fired, sliding back in as it reloads, #90), the seeker lights (Smart Seekers),
	# the loader arm after each salvo, the muzzle flashes.
	Draw.dyn(true)
	for i in lay.mouths.size():
		var f := loaded(L, i, ready, since)
		if f > 0.05:
			var q := muzzle(c, aim, k, look, i, 0.0)
			var mr: float = lay.mouths[i][2]
			Draw.orb(ci, q, mr * 0.8 * k * f, rocket_body, k)
			Draw.disc(ci, q + Vector2.from_angle(aim) * 0.4 * k, mr * 0.36 * k * f, nose)
	if L.R >= 3:
		for pd in pods:
			Draw.glow_dot(ci, at(c, aim, k, -6.0, float(pd[0])), 0.6 * k, SEEK if fmod(t * 2.0 + float(pd[0]), 1.0) < 0.5 else Color(SEEK, 0.3))
	if L.N >= 2:
		var b0 := at(c, aim, k, -7.0, 9.0)
		var a := aim + PI * 0.8 - fl * 0.8
		Draw.bar(ci, b0, b0 + Vector2.from_angle(a) * 7.0 * k, 1.2 * k, Draw.METAL_L)
	if fl > 0.0:
		for i in lay.mouths.size():
			Draw.glow_dot(ci, muzzle(c, aim, k, look, i), float(lay.mouths[i][2]) * k * fl, acc)
	Draw.dyn(false)


## The Launch Cells (Payload mastery: the owner's pick D, with the turret in the middle removed): an armoured octagonal deck
## of eight launch cells round a small fixed light. Nothing turns. Each hatch slides open as its rocket leaves (rippling round
## the deck), with a flash and a puff of smoke, and shuts again as the reload brings a new rocket up.
static func draw_cells(ci: CanvasItem, c: Vector2, k: float, lay: Dictionary, L: Dictionary, ready: float, since: float, acc: Color) -> void:
	var ms: Array = lay.mouths
	Draw.plate(ci, c, Draw.ngon(8, 1.0, PI / 8.0), Draw.METAL_D, 0.0, DECK_R * k, 1.3)
	Draw.ring(ci, c, 13.4 * k, Color(Draw.GOLD, 0.85), 0.9 * k)
	for mo in ms:
		var q := c + Vector2(float(mo[0]), float(mo[1])) * k
		Draw.plate(ci, q, Draw.rect_pts(2.7, 2.7), Draw.METAL, Vector2(float(mo[0]), float(mo[1])).angle(), k, 1.1)
		Draw.disc(ci, q, 1.8 * k, BORE)
	Draw.orb(ci, c, 2.4 * k, Draw.METAL, k)
	Draw.glow_dot(ci, c, 1.0 * k, acc)
	# Live: the hatches, the launch flashes and the smoke.
	Draw.dyn(true)
	for i in ms.size():
		var d := Vector2(float(ms[i][0]), float(ms[i][1])).normalized()
		var q := c + d * CELL_R * k
		var f := loaded(L, i, ready, since)
		var lid := q + d * (1.0 - f) * 3.9 * k
		Draw.plate(ci, lid, Draw.rect_pts(lerpf(1.1, 2.3, f), 2.3), Draw.METAL_L, d.angle(), k, 0.9)
		if f > 0.6:
			Draw.line(ci, lid - d.orthogonal() * 1.5 * k, lid + d.orthogonal() * 1.5 * k, Draw.GOLD, 0.7 * k)
		var si := since - float(i) * RIPPLE_GAP
		if si >= 0.0 and si < 0.25:
			Draw.glow_dot(ci, q, 1.9 * k * (1.0 - si / 0.25), acc)
		for j in 3:
			var w := si * 1.4 - float(j) * 0.15
			if w > 0.0 and w < 1.0:
				Draw.disc(ci, q + Vector2((float(j) - 1.0) * 1.2 * k, -w * 7.0 * k), (1.0 + w * 2.4) * k, Color(0.62, 0.64, 0.66, 0.4 * (1.0 - w)))
	Draw.dyn(false)
