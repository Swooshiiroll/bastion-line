extends RefCounted
## Enemy art kit (enemy rework phase 5, issue #68): the drawing helpers of the confirmed enemy art pages
## (design/enemy_art_*.html), ported one to one so each look reads like its page.
##
## A look draws in its own frame, in the page's pixels: x forward, y to the right of the heading. `begin` maps that
## frame onto the battlefield (position, facing, the animation's offset, turn and stretch), and every primitive maps
## its points through it. Shading is worked out after the mapping, so the light stays fixed on the screen (upper
## left), as on the pages. `push`/`pop` nest a turned sub-frame (the pages' `at`), and `push_alpha`/`pop_alpha`
## fade everything drawn in between (the pages' `withAlpha`).

const Draw = preload("res://scripts/view/Draw.gd")

const OUTLINE := Color(0.03, 0.04, 0.06, 0.95)
const METAL_D := Color(0.10, 0.115, 0.14)
const METAL := Color(0.18, 0.20, 0.24)
const METAL_L := Color(0.30, 0.33, 0.38)
const INK := Color(0.08, 0.08, 0.09)
const WHITE := Color(1, 1, 1)
const LIGHT := Vector2(-0.6, -0.8)

static var ci: CanvasItem
static var _o := Vector2.ZERO
static var _r := 0.0
static var _sx := 1.0
static var _sy := 1.0
static var _alpha := 1.0
static var _frames: Array = []
static var _alphas: Array = []


## Starts a look's frame: its origin, heading and stretch (x along the heading, y across it).
static func begin(canvas: CanvasItem, origin: Vector2, rot: float, sx: float, sy: float, alpha := 1.0) -> void:
	ci = canvas
	_o = origin
	_r = rot
	_sx = sx
	_sy = sy
	_alpha = alpha
	_frames.clear()
	_alphas.clear()


static func push(p: Vector2, ang: float) -> void:
	_frames.append([_o, _r])
	_o = W(p)
	_r += ang


static func pop() -> void:
	var f: Array = _frames.pop_back()
	_o = f[0]
	_r = f[1]


static func push_alpha(a: float) -> void:
	_alphas.append(_alpha)
	_alpha *= minf(1.0, maxf(0.0, a))


static func pop_alpha() -> void:
	_alpha = _alphas.pop_back()


## Frame point to battlefield point.
static func W(p: Vector2) -> Vector2:
	return _o + Vector2(p.x * _sx, p.y * _sy).rotated(_r)


static func _k() -> float:
	return sqrt(absf(_sx * _sy))


static func _c(col: Color) -> Color:
	return Color(col, col.a * _alpha)


## The screen's light direction seen from inside the frame.
static func light() -> Vector2:
	return LIGHT.rotated(-_r)


static func _map(pts: PackedVector2Array) -> PackedVector2Array:
	var o := PackedVector2Array()
	o.resize(pts.size())
	for i in pts.size():
		o[i] = W(pts[i])
	return o


# --- Colours and numbers -------------------------------------------------------------------------

static func al(col: Color, a: float) -> Color:
	return Color(col, a)


static func dk(col: Color, k: float) -> Color:
	return Color(col.r * (1.0 - k), col.g * (1.0 - k), col.b * (1.0 - k), col.a)


static func lt(col: Color, k: float) -> Color:
	return Color(col.r + (1.0 - col.r) * k, col.g + (1.0 - col.g) * k, col.b + (1.0 - col.b) * k, col.a)


## The pages' `hash`: a repeatable pseudo-random number in [0, 1).
static func hsh(n: float) -> float:
	var s := sin(n * 127.1 + 311.7) * 43758.5453
	return s - floorf(s)


static func blink(t: float, rate: float, ph := 0.0) -> float:
	return 1.0 if fposmod(t * rate + ph, 1.0) < 0.5 else 0.35


static func tri(x: float) -> float:
	return 2.0 * absf(2.0 * (x - floorf(x + 0.5))) - 1.0


static func fa(a: float) -> Vector2:
	return Vector2(cos(a), sin(a))


# --- Point lists ---------------------------------------------------------------------------------

static func P(arr: Array) -> PackedVector2Array:
	var o := PackedVector2Array()
	for q in arr:
		o.append(Vector2(q[0], q[1]))
	return o


static func xform(c: Vector2, pts: PackedVector2Array, r := 0.0, s := 1.0) -> PackedVector2Array:
	var o := PackedVector2Array()
	o.resize(pts.size())
	for i in pts.size():
		o[i] = c + (pts[i] * s).rotated(r)
	return o


static func ngon(n: int, r: float, ph := 0.0) -> PackedVector2Array:
	var o := PackedVector2Array()
	for i in n:
		var a := ph + TAU * float(i) / float(n)
		o.append(Vector2(cos(a) * r, sin(a) * r))
	return o


static func rect_pts(hw: float, hh: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(-hw, -hh), Vector2(hw, -hh), Vector2(hw, hh), Vector2(-hw, hh)])


## A rounded rectangle.
static func rr_pts(hw: float, hh: float, rad: float, n := 3) -> PackedVector2Array:
	var o := PackedVector2Array()
	for q in [[hw - rad, hh - rad, 0.0], [-(hw - rad), hh - rad, PI / 2.0], [-(hw - rad), -(hh - rad), PI], [hw - rad, -(hh - rad), 1.5 * PI]]:
		for i in n + 1:
			var a: float = q[2] + (PI / 2.0) * float(i) / float(n)
			o.append(Vector2(q[0] + cos(a) * rad, q[1] + sin(a) * rad))
	return o


static func capsule(hw: float, hh: float, n := 6) -> PackedVector2Array:
	var o := PackedVector2Array()
	var k := hw - hh
	for i in n + 1:
		var a := -PI / 2.0 + PI * float(i) / float(n)
		o.append(Vector2(k + cos(a) * hh, sin(a) * hh))
	for i in n + 1:
		var a := PI / 2.0 + PI * float(i) / float(n)
		o.append(Vector2(-k + cos(a) * hh, sin(a) * hh))
	return o


## A curved band between radii r0 and r1 from angle a0 to a1, centred at (cx, 0).
static func arc_pts2(cx: float, r0: float, r1: float, a0: float, a1: float, n := 6) -> PackedVector2Array:
	var o := PackedVector2Array()
	for i in n + 1:
		var a := a0 + (a1 - a0) * float(i) / float(n)
		o.append(Vector2(cx + cos(a) * r1, sin(a) * r1))
	for i in range(n, -1, -1):
		var a := a0 + (a1 - a0) * float(i) / float(n)
		o.append(Vector2(cx + cos(a) * r0, sin(a) * r0))
	return o


# --- Primitives (frame coordinates) --------------------------------------------------------------

static func disc(c: Vector2, r: float, col: Color) -> void:
	if r <= 0.0:
		return
	Draw.disc(ci, W(c), r * _k(), _c(col))


static func arc(c: Vector2, r: float, a0: float, a1: float, col: Color, w: float) -> void:
	Draw.arc(ci, W(c), maxf(0.01, r) * _k(), a0 + _r, a1 + _r, 24, _c(col), (w if w > 0.0 else 1.0) * _k())


static func ring(c: Vector2, r: float, col: Color, w := 1.5) -> void:
	Draw.ring(ci, W(c), maxf(0.01, r) * _k(), _c(col), w * _k())


static func line(a: Vector2, b: Vector2, col: Color, w := 1.0) -> void:
	Draw.line(ci, W(a), W(b), _c(col), (w if w > 0.0 else 1.0) * _k())


static func polyline(pts: PackedVector2Array, col: Color, w := 1.0) -> void:
	if pts.size() < 2:
		return
	Draw.polyline(ci, _map(pts), _c(col), (w if w > 0.0 else 1.0) * _k())


static func poly(pts: PackedVector2Array, col: Color) -> void:
	Draw.poly(ci, _map(pts), _c(col))


static func fill(c: Vector2, pts: PackedVector2Array, col: Color, r := 0.0, s := 1.0) -> void:
	poly(xform(c, pts, r, s), col)


static func outline(c: Vector2, pts: PackedVector2Array, col: Color, w: float, r := 0.0, s := 1.0) -> void:
	var p := xform(c, pts, r, s)
	p.append(p[0])
	polyline(p, col, w)


static func ellipse(c: Vector2, rx: float, ry: float, col: Color) -> void:
	Draw.oval(ci, W(c), maxf(0.01, rx) * _sx, maxf(0.01, ry) * _sy, _r, _c(col))


static func glow_dot(c: Vector2, r: float, col: Color) -> void:
	disc(c, r * 2.2, al(col, 0.18 * col.a))
	disc(c, r * 1.4, al(col, 0.35 * col.a))
	disc(c, r, col)
	disc(c, r * 0.45, Color(1, 1, 1, 0.9 * col.a))


static func arc_segments(c: Vector2, r: float, count: int, gap: float, rt: float, col: Color, w: float) -> void:
	var span := TAU / float(count)
	for i in count:
		var a0 := rt + span * float(i) + gap * 0.5
		arc(c, r, a0, a0 + span - gap, col, w)


static func orb(p: Vector2, r: float, col: Color) -> void:
	var l := light()
	disc(p, r + 1.1, OUTLINE)
	disc(p, r, dk(col, 0.3))
	disc(p + l * r * 0.12, r * 0.8, col)
	arc(p, r * 0.72, PI * 1.05 - _r, PI * 1.6 - _r, lt(col, 0.35), maxf(0.8, r * 0.16))
	disc(p + l * r * 0.45, maxf(0.6, r * 0.13), Color(1, 1, 1, 0.55))


## A bevelled plate: darker rim, face, light and shadow edges toward the screen's light, outline.
static func plate(c: Vector2, pts: PackedVector2Array, col: Color, r := 0.0, s := 1.0, lw := 1.2) -> void:
	var p := _map(xform(c, pts, r, s))
	var n := p.size()
	var k := _k()
	Draw.poly(ci, p, _c(dk(col, 0.22)))
	var ce := Vector2.ZERO
	for q in p:
		ce += q
	ce /= float(n)
	var inner := PackedVector2Array()
	inner.resize(n)
	for i in n:
		inner[i] = ce + (p[i] - ce) * 0.8
	Draw.poly(ci, inner, _c(col))
	var ew := maxf(0.8, lw * 0.8) * k
	for i in n:
		var a := p[i]
		var b := p[(i + 1) % n]
		var d := ((a + b) * 0.5 - ce).normalized().dot(LIGHT)
		if d > 0.15:
			Draw.line(ci, a + (ce - a) * 0.1, b + (ce - b) * 0.1, _c(lt(col, 0.45)), ew)
		elif d < -0.15:
			Draw.line(ci, a + (ce - a) * 0.1, b + (ce - b) * 0.1, _c(dk(col, 0.5)), ew)
	p.append(p[0])
	Draw.polyline(ci, p, _c(OUTLINE), lw * k)


static func rivets(c: Vector2, pts: PackedVector2Array, r: float, s: float, inset := 0.72, rr := 0.9) -> void:
	for q in xform(c, pts, r, s):
		var p := c + (q - c) * inset
		disc(p, rr + 0.3, OUTLINE)
		disc(p, rr, lt(METAL_L, 0.15))


## A shaded bar from a to b, lit on the side toward the screen's light.
static func bar(a: Vector2, b: Vector2, w: float, col: Color) -> void:
	var A := W(a)
	var B := W(b)
	var k := _k()
	var d := (B - A).normalized()
	var n := Vector2(d.y, -d.x)
	if n.dot(LIGHT) < 0.0:
		n = -n
	var wk := w * k
	Draw.line(ci, A, B, _c(OUTLINE), wk + 1.6 * k)
	Draw.line(ci, A, B, _c(dk(col, 0.25)), wk)
	Draw.line(ci, A + n * wk * 0.18, B + n * wk * 0.18, _c(col), wk * 0.55)
	Draw.line(ci, A + n * wk * 0.3, B + n * wk * 0.3, _c(lt(col, 0.4)), maxf(0.6 * k, wk * 0.16))


static func strip(a: Vector2, b: Vector2, w: float, col: Color) -> void:
	line(a, b, al(col, 0.25 * col.a), w * 2.6)
	line(a, b, col, w)
	line(a, b, Color(1, 1, 1, 0.6 * col.a), maxf(0.5, w * 0.35))


static func oval(c: Vector2, rx: float, ry: float, r: float, col: Color, ow := 0.0) -> void:
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * float(i) / 20.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry).rotated(r))
	if ow > 0.0:
		var big := PackedVector2Array()
		for q in pts:
			big.append(c + (q - c) * (1.0 + ow / maxf(rx, ry)))
		poly(big, OUTLINE)
	poly(pts, col)


static func shaded_oval(c: Vector2, rx: float, ry: float, r: float, col: Color) -> void:
	var m := minf(rx, ry)
	var l := light()
	oval(c, rx, ry, r, dk(col, 0.3), 1.3)
	oval(c + l * m * 0.12, rx * 0.8, ry * 0.78, r, col)
	disc(c + l * m * 0.5, maxf(0.6, m * 0.14), Color(1, 1, 1, 0.45))


## A jointed limb: segments with a joint dot at each bend.
static func limb(pts: PackedVector2Array, w: float, col: Color) -> void:
	polyline(pts, OUTLINE, w + 1.4)
	polyline(pts, col, w)
	for i in range(1, pts.size() - 1):
		disc(pts[i], w * 0.75 + 0.4, OUTLINE)
		disc(pts[i], w * 0.75, lt(col, 0.25))


# --- Parts shared by several roles ---------------------------------------------------------------

## A slit eye or visor across the heading: an outline stroke, then the glow.
static func slit(p: Vector2, w: float, col: Color, ow := 2.2, iw := 1.1) -> void:
	line(p + Vector2(0, -w), p + Vector2(0, w), OUTLINE, ow)
	line(p + Vector2(0, -w), p + Vector2(0, w), col, iw)


static func foot(p: Vector2, col: Color, r: float, w := 0.22, h := 0.13) -> void:
	plate(p, rect_pts(w, h), col, 0.0, r, 0.6)


## A track: a dark slab with links running back along it.
static func tread(p: Vector2, ln: float, wid: float, t: float, spd := 0.9, lw := 0.7) -> void:
	plate(p, rect_pts(ln, wid), Color(0.11, 0.11, 0.12), 0.0, 1.0, lw)
	var n := maxi(3, roundi(ln / 2.0))
	for k in n:
		var x := (fposmod(t * spd + float(k) / float(n), 1.0) * 2.0 - 1.0) * ln * 0.88
		line(p + Vector2(x, -wid * 0.8), p + Vector2(x, wid * 0.8), Color(0.34, 0.34, 0.37), lw)


static func wheel(p: Vector2, rr: float, t: float) -> void:
	plate(p, rect_pts(rr, rr * 0.55), Color(0.1, 0.1, 0.11), 0.0, 1.0, 0.6)
	var x := (fposmod(t * 4.0, 1.0) - 0.5) * rr * 1.6
	line(p + Vector2(x, -rr * 0.45), p + Vector2(x, rr * 0.45), Color(0.36, 0.36, 0.38), 0.5)


## A spinning rotor disc (two blades, or three for the heavier ducts).
static func rotor(p: Vector2, rr: float, t: float, spd: float, blades := 2, col := Color(0.92, 0.94, 0.97)) -> void:
	disc(p, rr, al(col, 0.12))
	if blades == 2:
		ring(p, rr, al(col, 0.3), 0.5)
		for b in 2:
			line(p, p + fa(t * spd + float(b) * PI) * rr, al(col, 0.6), 0.7)
		disc(p, maxf(0.5, rr * 0.16), Color(0.18, 0.18, 0.2))
	else:
		for b in 3:
			line(p, p + fa(t * spd + float(b) * TAU / 3.0) * rr * 0.92, al(col, 0.55), 0.8)
		disc(p, maxf(0.7, rr * 0.16), INK)


## The swarm family's round sensor eye.
static func eye(p: Vector2, rr: float, col: Color) -> void:
	disc(p, rr + 0.7, OUTLINE)
	disc(p, rr, Color(0.07, 0.07, 0.09))
	glow_dot(p, rr * 0.55, col)


## The swarm family's hive-link antenna fin, its tip blinking.
static func fin(p: Vector2, ang: float, ln: float, t: float, col: Color) -> void:
	var tip := p + fa(ang) * ln
	poly(PackedVector2Array([p + fa(ang + 1.57) * ln * 0.28, tip, p + fa(ang - 1.57) * ln * 0.28]), Color(0.72, 0.74, 0.78))
	line(p, tip, OUTLINE, 0.4)
	if fposmod(t * 1.5, 1.0) < 0.3:
		glow_dot(tip, maxf(0.5, ln * 0.18), col)


static func stencil(p: Vector2, ang: float, s: float, col := Color(0.95, 0.92, 0.8, 0.85)) -> void:
	for k in [-1.0, 1.0]:
		line(p + Vector2(k * s * 0.25, -s * 0.3).rotated(ang), p + Vector2(k * s * 0.25, s * 0.3).rotated(ang), col, 0.5)


## Armour that peels away (Titan, Colossus): `k` 0 is on, 1 gone, drifting along `dir` and turning as it goes.
static func shed_plate(c: Vector2, pts: PackedVector2Array, dir: Vector2, k: float, col: Color, r: float, drift := 0.7, ow := 1.0) -> void:
	var a := 1.0 - k
	if a <= 0.02:
		return
	var p := c + dir * k * drift * r
	var sp := k * 0.5
	fill(p, pts, al(col, a), sp, r)
	outline(p, pts, al(OUTLINE, 0.95 * a), ow, sp, r)
	outline(p, pts, al(lt(col, 0.35), 0.5 * a), 0.5, sp, r * 0.86)


## A jagged lightning bolt from a to b.
static func bolt(a: Vector2, b: Vector2, col: Color, sd: int, w := 0.7) -> void:
	var d := b - a
	var l := d.length()
	if l < 0.5:
		return
	var nd := Vector2(-d.y / l, d.x / l)
	var pts := PackedVector2Array([a])
	for i in range(1, 5):
		pts.append(a + d * float(i) / 5.0 + nd * (hsh(float(sd) * 7.3 + float(i)) - 0.5) * l * 0.4)
	pts.append(b)
	polyline(pts, al(col, 0.3 * col.a), w * 3.0)
	polyline(pts, col, w)


static func blink_lights(p: Vector2, n: int, w: float, t: float, col: Color) -> void:
	for i in n:
		var y := -w + 2.0 * w * float(i) / float(n - 1)
		disc(p + Vector2(0, y), 0.9, OUTLINE)
		disc(p + Vector2(0, y), 0.6, al(col, blink(t, 3.0, float(i) * 0.33)))


## The prototype mark of the special role: a white disc with a violet cross.
static func proto_mark(p: Vector2, s: float, t: float, a := 1.0) -> void:
	const PROTO := Color(0.8, 0.55, 1.0)
	disc(p, s + 0.6, al(OUTLINE, a))
	disc(p, s, Color(0.92, 0.9, 0.96, a))
	var w := maxf(0.6, s * 0.35)
	line(p + Vector2(-s * 0.55, -s * 0.55), p + Vector2(s * 0.55, s * 0.55), al(PROTO, a), w)
	line(p + Vector2(-s * 0.55, s * 0.55), p + Vector2(s * 0.55, -s * 0.55), al(PROTO, a), w)
	if fposmod(t * 0.7, 1.0) < 0.12:
		glow_dot(p, s * 0.6, al(PROTO, a))


## The bosses' crest: a gold crown on a red disc.
static func crest(p: Vector2, s: float, t: float) -> void:
	const GOLD := Color(0.95, 0.75, 0.3)
	disc(p, s + 0.8, OUTLINE)
	disc(p, s, Color(0.18, 0.06, 0.06))
	ring(p, s * 0.8, GOLD, maxf(0.8, s * 0.18))
	for i in 3:
		var a := -PI / 2.0 + (float(i) - 1.0) * 0.7
		poly(PackedVector2Array([p + fa(a - 0.18) * s * 0.75, p + fa(a) * s * 1.45, p + fa(a + 0.18) * s * 0.75]), GOLD)
	glow_dot(p, s * 0.35 * (0.8 + 0.2 * sin(t * 3.0)), Color(1, 0.25, 0.2))


## A pulse ring that grows from r0 to r1 as `u` runs from 0 to 1 (nothing outside that).
static func pulse(c: Vector2, r0: float, r1: float, u: float, col: Color, w := 1.3) -> void:
	if u < 0.0 or u > 1.0:
		return
	var rr := r0 + (r1 - r0) * (1.0 - (1.0 - u) * (1.0 - u))
	ring(c, rr, al(col, 0.65 * (1.0 - u)), w)
	ring(c, rr, al(col, 0.14 * (1.0 - u)), w * 3.0)


## An EMP burst: a jagged ring that grows as `u` runs from 0 to 1, darkening inside when `dark` > 0.
static func emp(c: Vector2, r0: float, r1: float, u: float, col: Color, t: float, dark := 0.0) -> void:
	if u < 0.0 or u > 1.0:
		return
	var rr := r0 + (r1 - r0) * (1.0 - (1.0 - u) * (1.0 - u))
	if dark > 0.0:
		disc(c, rr, Color(0, 0, 0, dark * (1.0 - u)))
	ring(c, rr, al(col, 0.12 * (1.0 - u)), 4.0)
	var sd := floori(t * 15.0)
	var pts := PackedVector2Array()
	for i in 29:
		var a := TAU * float(i) / 28.0
		pts.append(c + fa(a) * rr * (1.0 + 0.09 * (hsh(float(sd * 31 + i % 28)) - 0.5) * 2.0))
	polyline(pts, al(col, 0.8 * (1.0 - u)), 1.0)
