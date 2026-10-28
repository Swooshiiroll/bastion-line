extends "res://scripts/view/enemies/EnemyKit.gd"
## Evader role art (design/enemy_art_evader.html, confirmed 2026-10-08): Blink Stalker, Burrower, Shifter and Wraith.
##
## State (from EnemyArt.state): "blink" seconds since the last blink and "blink_in" seconds to the next (Stalker,
## Shifter); "under" 0..1 as the Burrower goes underground and "pinged" while a Radar Tower's ping finds it there;
## "reveal" 0..1 as the Wraith is revealed. Without them the page's own clocks run.

const STALKER := {"hull": Color(0.24, 0.25, 0.28), "panel": Color(0.4, 0.42, 0.46), "dark": Color(0.12, 0.12, 0.14), "glow": Color(1, 0.5, 0.15)}
const BURROWER := {"hull": Color(0.45, 0.32, 0.2), "panel": Color(0.6, 0.45, 0.3), "dark": Color(0.25, 0.18, 0.11), "steel": Color(0.62, 0.64, 0.68), "glow": Color(1, 0.72, 0.25)}
const SHIFTER := {"hull": Color(0.72, 0.75, 0.79), "panel": Color(0.86, 0.88, 0.91), "dark": Color(0.38, 0.4, 0.44), "glow": Color(0.3, 0.95, 0.85)}
const WRAITH := {"hull": Color(0.14, 0.13, 0.18), "panel": Color(0.26, 0.24, 0.32), "dark": Color(0.07, 0.07, 0.09), "glow": Color(0.85, 0.82, 1)}
const SENS := Color(0.4, 0.92, 1)
## Corner brackets that lock on when a cloaked enemy is revealed.
const LOCK := Color(0.4, 0.9, 1)


## Before and after a blink: a ghost where it blinked from (on the field, "blink_from"; in a preview, `dist` behind),
## rings in and out, and motes gathering just before it.
static func blink_fx(c: Vector2, t: float, r: float, st: Dictionary, period: float, dist: float, col: Color, body: Callable) -> void:
	if st.get("ghost", false):
		return   # this is the after-image itself (EnemyArt.draw)
	var u: float = st.get("blink", fposmod(t, period))
	var left: float = st.get("blink_in", period - fposmod(t, period))
	var pre := (0.45 - left) / 0.45 if left < 0.45 else 0.0
	if u < 0.7:
		var a := 0.55 * (1.0 - u / 0.7)
		var g: Vector2 = L(st.blink_from) if st.has("blink_from") else c + Vector2(-dist, 0)
		if not st.has("blink_from"):
			# A preview: the ghost drawn here. On the field EnemyArt.draw draws a still one where it blinked from (#114).
			push_alpha(a)
			body.call(g)
			pop_alpha()
		ring(g, r * (0.6 + 1.2 * u), al(col, a), 1.0)
		ring(c, r * (1.6 - 1.4 * minf(1.0, u / 0.3)), al(col, 0.8 * (1.0 - u / 0.7)), 1.2)
	if pre > 0.0:
		ring(c, r * (1.5 - 0.8 * pre), al(col, 0.7 * pre), 1.0)
		for i in 4:
			disc(c + fa(float(i) * TAU / 4.0 + t * 6.0) * r * (1.4 - 0.7 * pre), 0.8, al(col, pre))


static func lock_on(c: Vector2, r: float, k: float) -> void:
	if k <= 0.0:
		return
	for s in [-1.0, 1.0]:
		for q in [-1.0, 1.0]:
			var p := c + Vector2(s * r * 1.05, q * r * 1.05)
			polyline(PackedVector2Array([p + Vector2(-s * r * 0.3, 0), p, p + Vector2(0, -q * r * 0.3)]), al(LOCK, 0.8 * k), 1.0)


## Blink Stalker, look L Mag-lev orb.
static func stalker(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := STALKER
	var body := func(p: Vector2) -> void:
		disc(p, r * 0.7, al(C.glow, 0.08))
		for i in 3:
			var a := t * 1.6 + float(i) * TAU / 3.0
			var q := p + fa(a) * r * 0.62
			line(p, q, al(C.glow, 0.25), 0.6)
			disc(q, r * 0.13, OUTLINE)
			disc(q, r * 0.1, C.panel)
			disc(q, r * 0.04, C.glow)
		disc(p, r * 0.4, OUTLINE)
		disc(p, r * 0.37, C.hull)
		ring(p, r * 0.26, C.dark, 0.6)
		var ey := p + Vector2(r * 0.16, 0)
		disc(ey, r * 0.14, Color(0.06, 0.05, 0.05))
		glow_dot(ey, r * 0.06, C.glow)
	blink_fx(c, t, r, st, 4.0, float(st.get("blink_dist", r * 2.6)), C.glow, body)
	body.call(c)


## Burrower, look G Drill pod: it vanishes underground (no mound, no shadow); a Radar Tower's ping shows a doppler
## ring where it is.
static func burrower(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := BURROWER
	var u := fposmod(t, 5.0)
	var h: float = st.get("under", 0.0 if u < 2.2 else ((u - 2.2) / 0.3 if u < 2.5 else (1.0 if u < 4.7 else 1.0 - (u - 4.7) / 0.3)))
	var ping: float = 1.0 if st.get("pinged", false) else (0.0 if st.has("under") else (minf(1.0, minf((u - 3.2) / 0.2, (4.7 - u) / 0.2)) if u > 3.2 and u < 4.7 else 0.0))
	if ping > 0.0 and h >= 0.5:
		for i in 4:
			var age := fposmod(t * 1.1 + float(i) / 4.0, 1.0)
			ring(c + Vector2(-age * r * 1.3, 0), r * (0.3 + 1.7 * age), al(SENS, 0.7 * (1.0 - age) * ping), 1.0)
		glow_dot(c, 1.2, al(SENS, ping))
	if 1.0 - h <= 0.01:
		return
	push_alpha(1.0 - h)
	for sg in [-1.0, 1.0]:
		var j := c + Vector2(-r * 0.66, sg * r * 0.18)
		disc(j, r * 0.12, OUTLINE)
		disc(j, r * 0.1, C.dark)
		glow_dot(j + Vector2(-r * 0.05, 0), r * 0.05 * (1.0 + 0.3 * sin(t * 25.0 + sg)), C.glow)
	plate(c, capsule(0.62, 0.34), C.hull, 0.0, r, 0.9)
	line(c + Vector2(r * 0.2, -r * 0.33), c + Vector2(r * 0.2, r * 0.33), C.dark, 0.7)
	line(c + Vector2(-r * 0.3, -r * 0.33), c + Vector2(-r * 0.3, r * 0.33), C.dark, 0.7)
	for x in [-0.05, -0.5]:
		var pp := c + Vector2(x * r * 0.6, 0)
		disc(pp, r * 0.09, OUTLINE)
		disc(pp, r * 0.07, al(C.glow, 0.85))
	var d := c + Vector2(r * 0.55, 0)
	plate(d, P([[0.62, 0], [0, 0.32], [0, -0.32]]), C.steel, 0.0, r, 0.8)
	for k in 3:
		# The drill's flutes, running back along the cone.
		var uu := fposmod(t * 2.5 + float(k) / 3.0, 1.0) * 0.8
		var x0 := 0.03 + uu * 0.55
		var w0 := 0.32 * (1.0 - (x0 - 0.03) / 0.55)
		var w1 := 0.32 * (1.0 - (x0 + 0.08 - 0.03) / 0.55)
		line(d + Vector2(x0 * r, -w0 * r * 0.9), d + Vector2((x0 + 0.08) * r, w1 * r * 0.9), al(INK, 0.75), 0.9)
	plate(c + Vector2(r * 0.55, 0), rect_pts(0.05, 0.34), C.dark, 0.0, r, 0.6)
	pop_alpha()


## Shifter, look B Prism hover: a wake ring where it lands lifts the speed of those around it.
static func shifter(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := SHIFTER
	var body := func(p: Vector2) -> void:
		disc(p, r * 0.75, al(C.glow, 0.12))
		var tr := P([[0.85, 0], [-0.55, 0.65], [-0.55, -0.65]])
		plate(p, tr, C.hull, 0.0, r, 0.9)
		for i in 3:
			var k := 0.5 + 0.5 * sin(t * 3.0 + float(i) * 2.1)
			fill(p, PackedVector2Array([Vector2.ZERO, tr[i], tr[(i + 1) % 3]]), al(C.panel if i == 1 else C.dark, 0.35 + 0.3 * k), 0.0, r)
		outline(p, tr, al(C.glow, 0.7), 0.7, 0.0, r * 0.8)
		glow_dot(p, r * 0.08, C.glow)
		slit(p + Vector2(r * 0.45, 0), r * 0.1, C.glow, 2.2, 1.1)
	var wu := float(st.get("blink", fposmod(t, 5.0))) / 1.4
	if wu <= 1.0:
		var rr := r * (0.8 + 1.9 * (1.0 - (1.0 - wu) * (1.0 - wu)))
		ring(c, rr, al(C.glow, 0.7 * (1.0 - wu)), 1.2)
		ring(c, rr, al(C.glow, 0.15 * (1.0 - wu)), 4.0)
		for i in 6:
			var a := float(i) * TAU / 6.0
			var p := c + fa(a) * rr
			polyline(PackedVector2Array([p + fa(a + 2.3) * r * 0.18, p, p + fa(a - 2.3) * r * 0.18]), al(C.glow, 0.8 * (1.0 - wu)), 0.9)
	blink_fx(c, t, r, st, 5.0, float(st.get("blink_dist", r * 2.2)), C.glow, body)
	body.call(c)


## Wraith, look W Spectre wing: a soft spectral tail and faint trailing copies while undetected, a cold glow, and
## motes peeling off its wings.
static func wraith(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := WRAITH
	var G := lt(C.panel, 0.45)
	var u := fposmod(t, 6.0)
	var k: float = st.get("reveal", 0.0 if u < 4.0 else ((u - 4.0) / 0.3 if u < 4.3 else (1.0 if u < 5.7 else 1.0 - (u - 5.7) / 0.3)))
	var half := [[0.55, 0], [-0.25, 0.95], [-0.45, 0.85], [-0.35, 0.58], [-0.55, 0.42], [-0.4, 0.2], [-0.55, 0]]
	var wing := P(half)
	for i in range(half.size() - 2, 0, -1):
		wing.append(Vector2(half[i][0], -half[i][1]))
	var peel_pts := P([[-0.25, 0.95], [-0.45, 0.85], [-0.55, 0.42], [-0.55, 0], [-0.55, -0.42], [-0.45, -0.85], [-0.25, -0.95], [0.15, 0.48], [0.15, -0.48]])
	var b0 := func(q: Vector2, a: float) -> void:
		fill(q, wing, al(C.hull, 0.42 * a), 0.0, r)
		outline(q, wing, al(C.glow, 0.6 * a), 0.7, 0.0, r)
		line(q + Vector2(r * 0.55, 0), q + Vector2(-r * 0.55, 0), al(C.glow, 0.75 * a), 1.0)
		for sg in [-1.0, 1.0]:
			for kk in [0.2, 0.4, 0.6, 0.8]:
				line(q + Vector2(r * (0.5 - 0.7 * kk), 0), q + Vector2(r * (0.5 - 0.75 * kk - 0.1), sg * r * 0.92 * kk), al(C.glow, 0.5 * a), 0.6)
	var body := func(p: Vector2) -> void:
		b0.call(p + Vector2(-r * 0.4, sin(t * 2.0) * r * 0.08), 0.3)
		b0.call(p, 1.0)
		glow_dot(p, r * (0.08 + 0.03 * sin(t * 3.0)), C.glow)
		for i in peel_pts.size():
			for kk in 2:
				var pu := fposmod(t * 0.9 + float(kk) / 2.0 + float(i) * 0.37, 1.0)
				var q := peel_pts[i]
				disc(p + Vector2(q.x - 0.55 * pu, q.y + (hsh(float(i * 5 + kk)) - 0.5) * 0.25 * pu) * r, r * (0.035 + 0.03 * (1.0 - pu)), al(G, 0.75 * (1.0 - pu)))
	var un := 1.0 - k
	var j := r * 0.11 * un
	_ghost_tail(c, r, t, C.glow, 0.25 + 0.75 * un)
	if un > 0.01:
		push_alpha(0.2 * un)
		body.call(c + Vector2(sin(t * 9.0) * j - r * 0.18, cos(t * 7.0) * j))
		body.call(c + Vector2(-sin(t * 8.0) * j - r * 0.36, -cos(t * 11.0) * j))
		pop_alpha()
		push_alpha(0.18 * un * (0.7 + 0.3 * sin(t * 4.0)))
		body.call(c + Vector2(0, sin(t * 13.0) * r * 0.03))
		pop_alpha()
	push_alpha(0.1 + 0.9 * k)
	body.call(c)
	pop_alpha()
	if st.get("lock", false):
		lock_on(c, r, k)


## A chain of soft glow puffs growing out from under the hull, thinning and fading to the tip.
static func _ghost_tail(c: Vector2, r: float, t: float, col: Color, amt: float) -> void:
	if amt <= 0.01:
		return
	for i in 15:
		var u := float(i) / 14.0
		var ramp := sin(minf(1.0, u / 0.3) * PI / 2.0)
		var rad := r * (0.48 * pow(1.0 - u, 0.75) + 0.05) * ramp
		var p := c + Vector2(0.12 - 2.35 * u, sin(t * 3.0 - u * 6.0) * 0.2 * u) * r
		var a := amt * pow(1.0 - u, 0.7)
		if rad < 0.4:
			continue
		disc(p, rad, al(col, 0.08 * a))
		disc(p, rad * 0.5, al(col, 0.12 * a))
	for i in 5:
		var u := fposmod(t * 0.7 + float(i) / 5.0, 1.0)
		var y := sin(t * 3.0 - u * 6.0) * 0.2 * u + (hsh(float(i * 3)) - 0.5) * 0.7 * u
		disc(c + Vector2(-0.3 - 2.0 * u, y) * r, r * (0.04 + 0.05 * (1.0 - u)), al(col, 0.6 * amt * (1.0 - u)))
