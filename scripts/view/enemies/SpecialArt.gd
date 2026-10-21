extends "res://scripts/view/enemies/EnemyKit.gd"
## Special role art (design/enemy_art_special.html, confirmed 2026-10-08): Phantom, Aegis Walker, Hydra Frame,
## Masquerade, Decoy Beacon and Mirage. Each carries the prototype mark (a violet cross on a white disc).
##
## State (from EnemyArt.state): "reveal" 0..1 as the Phantom is revealed; "barrier" the Aegis barrier's level 0..1,
## "crack" 0..1 while it takes hits and "shatter" 0..1 just after it breaks; "uncover" 0..1 as the Masquerade
## unfolds; "hologram" for a Mirage's projection. Without them the page's own clocks run.

const SwarmArt = preload("res://scripts/view/enemies/SwarmArt.gd")
const RusherArt = preload("res://scripts/view/enemies/RusherArt.gd")

const PHANTOM := {"hull": Color(0.32, 0.46, 0.47), "panel": Color(0.5, 0.64, 0.64), "dark": Color(0.16, 0.24, 0.25), "glow": Color(0.55, 1, 0.92)}
const AEGIS := {"hull": Color(0.9, 0.86, 0.74), "trim": Color(0.85, 0.64, 0.24), "dark": Color(0.42, 0.37, 0.28), "glow": Color(1, 0.78, 0.35)}
const HYDRA := {"hull": Color(0.55, 0.22, 0.18), "dark": Color(0.3, 0.12, 0.1), "glow": Color(1, 0.55, 0.3)}
const MASQ := {"hull": Color(0.42, 0.2, 0.4), "panel": Color(0.6, 0.36, 0.58), "dark": Color(0.22, 0.1, 0.21), "glow": Color(0.85, 0.5, 1)}
const DECOY := {"hull": Color(0.33, 0.35, 0.37), "panel": Color(0.47, 0.5, 0.53), "frame": Color(0.62, 0.55, 0.4), "dark": Color(0.17, 0.18, 0.19), "glow": Color(1, 0.3, 0.7)}
const MIRAGE := {"hull": Color(0.8, 0.82, 0.87), "dark": Color(0.4, 0.42, 0.48), "glow": Color(0.4, 0.95, 1)}
## The Masquerade's disguise: a Drone with a purple eye (the tell).
const DISGUISE_EYE := Color(0.8, 0.5, 1)
const DRONE_HULL := Color(0.3, 0.38, 0.52)
const LOCK := Color(0.4, 0.9, 1)


static func slit_s(p: Vector2, w: float, col: Color) -> void:
	slit(p, w, col, 2.2, 1.1)


static func lock_on(c: Vector2, r: float, k: float) -> void:
	if k <= 0.0:
		return
	for s in [-1.0, 1.0]:
		for q in [-1.0, 1.0]:
			var p := c + Vector2(s * r * 1.05, q * r * 1.05)
			polyline(PackedVector2Array([p + Vector2(-s * r * 0.3, 0), p, p + Vector2(0, -q * r * 0.3)]), al(LOCK, 0.8 * k), 1.0)


## Phantom, look E Camo glider: active camouflage as a faint double image until revealed.
static func phantom(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := PHANTOM
	var u := fposmod(t, 5.0)
	var k: float = st.get("reveal", 0.0 if u < 3.6 else ((u - 3.6) / 0.15 if u < 3.75 else (1.0 if u < 4.8 else maxf(0.0, 1.0 - (u - 4.8) / 0.2))))
	var body := func(p: Vector2) -> void:
		for sg in [-1.0, 1.0]:
			var w := P([[0.15, sg * 0.1], [-0.4, sg * 0.95], [-0.55, sg * 0.9], [-0.3, sg * 0.1]])
			fill(p, w, C.hull, 0.0, r)
			outline(p, w, al(OUTLINE, 0.9), 0.7, 0.0, r)
			for kk in 3:
				var uu := fposmod(t * 0.8 + float(kk) / 3.0, 1.0)
				line(p + Vector2(r * (0.1 - 0.5 * uu), sg * r * (0.15 + 0.7 * uu)), p + Vector2(r * (0.0 - 0.5 * uu), sg * r * (0.2 + 0.7 * uu)), al(C.glow, 0.4), 0.6)
		plate(p, P([[0.85, 0], [0.4, 0.1], [-0.65, 0.08], [-0.75, 0], [-0.65, -0.08], [0.4, -0.1]]), C.panel, 0.0, r, 0.7)
		proto_mark(p + Vector2(-r * 0.3, 0), r * 0.07, t)
		slit_s(p + Vector2(r * 0.55, 0), r * 0.08, C.glow)
	if k < 1.0:
		var un := 1.0 - k
		push_alpha(0.14 * un)
		body.call(c + Vector2(r * 0.05, 0))
		body.call(c + Vector2(-r * 0.05, r * 0.03))
		pop_alpha()
	push_alpha(0.1 + 0.9 * k)
	body.call(c)
	pop_alpha()
	if st.get("lock", false):
		lock_on(c, r, k)


## Aegis Walker, look E Siege hexapod: the amber hex barrier cracks under fire, shatters and rebuilds.
static func aegis(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := AEGIS
	for i in 3:
		for sg in [-1.0, 1.0]:
			var sw := sin(t * 3.0 + float(i) * 2.1 + (PI if sg > 0.0 else 0.0))
			var root := c + Vector2(r * (0.3 - float(i) * 0.32), sg * r * 0.38)
			var knee := root + Vector2(r * (0.14 + 0.06 * sw), sg * r * 0.32)
			var ft := root + Vector2(r * (-0.04 + 0.12 * sw), sg * r * 0.55)
			limb(PackedVector2Array([root, knee, ft]), 2.4, C.dark)
			disc(ft, 2.0, OUTLINE)
			disc(ft, 1.6, C.trim)
	var sh := rr_pts(0.6, 0.42, 0.14)
	plate(c, sh, C.hull, 0.0, r, 1.1)
	rivets(c, sh, 0.0, r, 0.82, 0.7)
	for x in [-0.2, 0.2]:
		line(c + Vector2(x * r, -r * 0.4), c + Vector2(x * r, r * 0.4), C.trim, 0.8)
	var dm := c + Vector2(-r * 0.15, 0)
	disc(dm, r * 0.26, OUTLINE)
	disc(dm, r * 0.23, C.trim)
	glow_dot(dm, r * 0.1, C.glow)
	proto_mark(c + Vector2(r * 0.3, r * 0.22), r * 0.08, t)
	slit_s(c + Vector2(r * 0.52, 0), r * 0.13, C.glow)
	# The barrier: the page's 8 s demo cycle, or the real barrier.
	var u := fposmod(t, 8.0)
	var lvl: float
	var crack: float
	var shat: float
	if st.has("barrier"):
		lvl = st.barrier
		crack = st.crack
		shat = st.shatter
	elif u < 3.0:
		lvl = 1.0; crack = 0.0; shat = -1.0
	elif u < 4.5:
		lvl = 1.0 - 0.75 * (u - 3.0) / 1.5; crack = (u - 3.0) / 1.5; shat = -1.0
	elif u < 5.1:
		lvl = 0.0; crack = 0.0; shat = (u - 4.5) / 0.6
	elif u < 7.0:
		lvl = 0.0; crack = 0.0; shat = -1.0
	else:
		lvl = u - 7.0; crack = 0.0; shat = -1.0
	var R := r * 1.25
	if lvl > 0.01:
		disc(c, R, al(C.glow, 0.08 * lvl))
		var n := maxi(1, roundi(12.0 * lvl)) if crack <= 0.0 and lvl < 1.0 else 12
		for i in n:
			var a := float(i) * TAU / 12.0 + t * 0.2
			outline(c + fa(a) * R * 0.9, ngon(6, 1.0, 0.0), al(C.glow, 0.55 * lvl), 0.7, a, R * 0.15)
		ring(c, R, al(C.glow, 0.75 * lvl), 1.1)
		if crack > 0.0:
			if fposmod(t, 0.35) < 0.08:
				ring(c, R, Color(1, 1, 1, 0.6), 1.6)
			for i in ceili(5.0 * crack):
				var a := hsh(float(i * 9)) * TAU
				polyline(PackedVector2Array([c + fa(a) * R, c + fa(a + 0.15) * R * 0.65, c + fa(a - 0.1) * R * 0.4]), Color(1, 1, 1, 0.7), 0.6)
	if shat >= 0.0:
		for i in 10:
			var a := float(i) * TAU / 10.0 + hsh(float(i)) * 0.5
			fill(c + fa(a) * R * (1.0 + 0.8 * shat), P([[0.5, 0], [-0.3, 0.35], [-0.3, -0.35]]), al(C.glow, 0.8 * (1.0 - shat)), a + shat * 3.0, R * 0.12)


## Hydra Frame, look H Cluster pod: a pod with three Skitters docked inside (they burst out when it dies).
static func hydra(c: Vector2, t: float, r: float, _st: Dictionary) -> void:
	var C := HYDRA
	for sg in [-1.0, 1.0]:
		fill(c, P([[-0.6, sg * 0.25], [-0.95, sg * 0.5], [-0.95, sg * 0.25]]), C.dark, 0.0, r)
	plate(c, rr_pts(0.75, 0.5, 0.42), C.hull, 0.0, r, 1.1)
	for a in [0.9, -0.9, PI]:
		line(c, c + fa(a) * r * 0.55, al(INK, 0.7), 0.8)
	ring(c, r * 0.18, C.dark, 1.0)
	for sg in [-1.0, 1.0]:
		glow_dot(c + Vector2(r * 0.55, sg * r * 0.18), 0.9, al(C.glow, blink(t, 1.2, 0.5 if sg > 0.0 else 0.0)))
	proto_mark(c + Vector2(-r * 0.2, r * 0.32), r * 0.07, t)


## Masquerade, look J Unfolding stilt-walker: it wears a Drone (with a purple eye) until it's uncovered, then the
## Drone shell bursts and it unfolds.
static func masquerade(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := MASQ
	var u := fposmod(t, 8.0)
	var k: float = st.get("uncover", 0.0 if u < 5.0 else minf(1.0, (u - 5.0) / 0.6))
	if k < 0.99:
		push_alpha(1.0 - k)
		SwarmArt.drone(c, t, r * 11.0 / 12.0, {}, DISGUISE_EYE, false)
		pop_alpha()
	if k > 0.0 and k < 1.0:
		ring(c, r * (0.4 + 1.2 * k), al(C.glow, 0.8 * (1.0 - k)), 1.3)
		for i in 8:
			var a := float(i) * TAU / 8.0
			fill(c + fa(a) * r * (0.5 + k), P([[0.4, 0], [-0.3, 0.3], [-0.3, -0.3]]), al(DRONE_HULL, 1.0 - k), a + k * 5.0, r * 0.14)
	if k <= 0.01:
		return
	push_alpha(k)
	for kk in 4:
		var d := fa(PI / 4.0 + float(kk) * PI / 2.0)
		var sw := sin(t * 4.0 + float(kk) * PI / 2.0) * r * 0.1
		var knee := c + d * r * 0.75 + Vector2(sw, 0)
		limb(PackedVector2Array([c + d * r * 0.25, knee, knee + d * r * 0.45]), 1.4, C.dark)
		disc(knee + d * r * 0.45, 1.4, OUTLINE)
	plate(c, rr_pts(0.36, 0.32, 0.1), C.hull, 0.0, r, 0.9)
	glow_dot(c, r * 0.09, C.glow)
	proto_mark(c + Vector2(-r * 0.2, 0), r * 0.07, t)
	slit_s(c + Vector2(r * 0.3, 0), r * 0.1, C.glow)
	pop_alpha()


## Decoy Beacon, look B Hologram heavy: a small tracked frame projecting a heavy unit's hologram, with a rank badge.
static func decoy(c: Vector2, t: float, r: float, _st: Dictionary) -> void:
	var C := DECOY
	var H := Color(0.72, 0.82, 0.95)
	var a := 1.0 if hsh(floorf(t * 10.0)) > 0.08 else 0.3
	for q in [[0.22, 0.2], [0.22, -0.2], [-0.22, 0.2], [-0.22, -0.2]]:
		wheel(c + Vector2(q[0] * r, q[1] * r), r * 0.09, t)
	plate(c, rect_pts(0.32, 0.18), C.frame, 0.0, r, 0.7)
	disc(c + Vector2(r * 0.3, 0), r * 0.09, OUTLINE)
	glow_dot(c + Vector2(r * 0.3, 0), r * 0.05, C.glow)
	proto_mark(c + Vector2(-r * 0.15, 0), r * 0.07, t)
	fill(c, rr_pts(0.85, 0.55, 0.12), al(H, 0.14 * a), 0.0, r)
	outline(c, rr_pts(0.85, 0.55, 0.12), al(H, 0.6 * a), 0.7, 0.0, r)
	for s in [-1.0, 1.0]:
		outline(c + Vector2(0, s * r * 0.62), rect_pts(0.8, 0.16), al(H, 0.45 * a), 0.6, 0.0, r)
	ring(c + Vector2(-r * 0.05, 0), r * 0.32, al(H, 0.6 * a), 0.7)
	line(c + Vector2(r * 0.25, 0), c + Vector2(r * 1.05, 0), al(H, 0.6 * a), 1.2)
	var off := fposmod(t * 5.0, 1.0) * r * 0.16
	for i in range(-3, 4):
		line(c + Vector2(-r * 0.85, float(i) * r * 0.16 + off), c + Vector2(r * 0.85, float(i) * r * 0.16 + off), al(H, 0.12 * a), 0.5)
	var pulse_a := 0.6 + 0.4 * sin(t * 4.0)
	var bp := c + Vector2(-r * 0.25, -r * 1.1)
	for i in 3:
		var q := bp + Vector2(float(i) * 2.4, 0)
		var pts := PackedVector2Array([q + Vector2(-1.5, -2.2), q + Vector2(0.6, 0), q + Vector2(-1.5, 2.2)])
		polyline(pts, OUTLINE, 2.0)
		polyline(pts, al(C.glow, pulse_a), 1.0)


## Mirage, look C Mirror-fan hover. Its holograms are the same unit, faint and flickering.
static func mirage(c: Vector2, t: float, r: float, st: Dictionary) -> void:
	var C := MIRAGE
	var body := func(p: Vector2) -> void:
		disc(p, r * 0.6, al(C.glow, 0.1))
		var blade := P([[0.3, -0.07], [0.3, 0.07], [-0.3, 0.1], [-0.3, -0.1]])
		for i in 5:
			var a := PI + (float(i) - 2.0) * 0.32
			var q := p + fa(a) * r * 0.55
			fill(q, blade, C.hull, a, r)
			outline(q, blade, al(C.glow, 0.4 + 0.4 * sin(t * 4.0 + float(i))), 0.6, a, r)
		disc(p, r * 0.32, OUTLINE)
		disc(p, r * 0.29, C.hull)
		ring(p, r * 0.18, C.dark, 0.7)
		proto_mark(p + Vector2(-r * 0.08, 0), r * 0.07, t)
		slit_s(p + Vector2(r * 0.24, 0), r * 0.1, C.glow)
	if st.get("hologram", false):
		var fl := 0.45 if hsh(floorf(t * 24.0)) < 0.3 else 1.0
		push_alpha(0.16 * fl)
		body.call(c + Vector2(r * 0.06, 0))
		body.call(c + Vector2(-r * 0.06, r * 0.04))
		pop_alpha()
		push_alpha(0.3 * fl)
		body.call(c)
		pop_alpha()
		return
	if not st.has("hologram"):
		# The page's demo: two projections either side, fading in and out every 6 s.
		var u := fposmod(t, 6.0)
		var a := u / 0.5 if u < 0.5 else ((6.0 - u) / 0.7 if u > 5.3 else 1.0)
		for sg in [1.0, -1.0]:
			var p := c + Vector2(sg * r * 1.7, 0)
			var fl := 0.45 if hsh(floorf(t * 24.0) + (0.0 if sg > 0.0 else 7.0)) < 0.3 else 1.0
			push_alpha(0.16 * a * fl)
			body.call(p + Vector2(r * 0.06, 0))
			body.call(p + Vector2(-r * 0.06, r * 0.04))
			pop_alpha()
			push_alpha(0.3 * a * fl)
			body.call(p)
			pop_alpha()
	body.call(c)
