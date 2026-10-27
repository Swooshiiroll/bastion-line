extends Node2D

const Draw = preload("res://scripts/view/Draw.gd")
## Short-lived visual effects: particles, expanding rings, lightning, tracers, flashes, floating text.
## Purely cosmetic; lives in real time independent of game speed.

const Grid = preload("res://scripts/core/Grid.gd")

const MAX_PARTICLES := 700
const MAX_TEXTS := 70

var particles: Array = []
var rings: Array = []
var bolts: Array = []
var tracers: Array = []
var flashes: Array = []
var texts: Array = []
var meteors: Array = []
var scorches: Array = []
var sprays: Array = []
var mists: Array = []
var shocks: Array = []
var puffs: Array = []
var fountains: Array = []
## Constant Spray's jet (#112): drops (or mist puffs) that keep the position and direction they left the head with.
var jets: Array = []
var warp_t := 0.0
var warp_max := 1.0
var _time := 0.0
var _font: Font


func _ready() -> void:
	_font = ThemeDB.fallback_font


func burst(pos: Vector2, color: Color, count: int, speed := 90.0, size := 2.5, life := 0.5, gravity := 0.0) -> void:
	# The Effects setting (Low / Medium / High) thins out particles.
	var n := maxi(1, roundi(float(count) * float(SaveManager.setting("vfx"))))
	for i in n:
		if particles.size() >= MAX_PARTICLES:
			return
		var v := Vector2.from_angle(randf() * TAU) * speed * randf_range(0.3, 1.0)
		var l := life * randf_range(0.6, 1.0)
		particles.append({"p": pos, "v": v, "life": l, "max": l, "c": color, "s": size * randf_range(0.6, 1.2), "g": gravity})


## An acid spray (Chemical Plant): a stream of drops lobbed from `from` onto `enemy` (following it; `to` once it's gone) over
## `life` seconds. `size` scales the drops; `glint` adds the gel's white glints, `bubbles` the Concentrated Acid's bubbles; a
## `mist` is a few soft puffs drifting over instead.
func spray(from: Vector2, enemy, to: Vector2, color: Color, size: float, glint: bool, bubbles: bool, mist := false, life := 0.35) -> void:
	sprays.append({"a": from, "e": enemy, "b": to, "c": color, "s": size, "g": glint, "bub": bubbles, "mist": mist, "life": life, "max": life})


func ring(pos: Vector2, r0: float, r1: float, color: Color, life := 0.35, width := 2.0, filled := false) -> void:
	rings.append({"p": pos, "r0": r0, "r1": r1, "c": color, "life": life, "max": life, "w": width, "f": filled})


func bolt(points: Array, color: Color, width := 2.5, life := 0.18) -> void:
	if points.size() < 2:
		return
	var jag := PackedVector2Array()
	for i in points.size() - 1:
		var a: Vector2 = points[i]
		var b: Vector2 = points[i + 1]
		var segs := maxi(2, int(a.distance_to(b) / 12.0))
		var nrm := (b - a).orthogonal().normalized()
		for k in segs:
			var p := a.lerp(b, float(k) / float(segs))
			if k > 0:
				p += nrm * randf_range(-5.0, 5.0)
			jag.append(p)
	jag.append(points[points.size() - 1])
	bolts.append({"pts": jag, "c": color, "w": width, "life": life, "max": life})


func tracer(a: Vector2, b: Vector2, color: Color, life := 0.14, width := 2.0) -> void:
	tracers.append({"a": a, "b": b, "c": color, "life": life, "max": life, "w": width})


func flash(pos: Vector2, r: float, color: Color, life := 0.1) -> void:
	flashes.append({"p": pos, "r": r, "c": color, "life": life, "max": life})


func text(pos: Vector2, s: String, color: Color, size := 14, life := 0.9, rise := 30.0) -> void:
	if texts.size() >= MAX_TEXTS:
		texts.pop_front()
	texts.append({"p": pos, "t": s, "c": color, "s": size, "life": life, "max": life, "rise": rise})


func meteor(target: Vector2, delay: float, radius: float) -> void:
	meteors.append({"p": target, "life": delay, "max": delay, "r": radius})


func scorch(pos: Vector2, r: float) -> void:
	scorches.append({"p": pos, "r": r, "life": 6.0, "max": 6.0})


## The Cryo Tower's wave of creeping mist (its page, Creeping Mist): pale puffs spreading out to `radius` over 1.8 s behind a faint
## front ring; with the Cold Front mastery the field is constant, the puffs filling the range at once with no front.
func mist(pos: Vector2, radius: float, color: Color, constant := false) -> void:
	mists.append({"p": pos, "r": radius, "c": color, "k": constant, "seed": randf() * 100.0, "life": 2.4, "max": 2.4})


func warp(duration: float) -> void:
	warp_t = duration
	warp_max = duration


func _process(delta: float) -> void:
	_time += delta
	warp_t = maxf(0.0, warp_t - delta)
	for m in meteors:
		if randf() < 0.5:
			var k: float = m.life / m.max
			burst(m.p + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * m.r * k, Color(1.0, 0.6, 0.3), 1, 20.0, 2.0, 0.3)
	for p in particles:
		p["v"] = p.v * (1.0 - 2.5 * delta) + Vector2(0, p.g * delta)
		p["p"] = p.p + p.v * delta
	for t in texts:
		t["p"] = t.p + Vector2(0, -t.rise * delta)
	particles = _age(particles, delta)
	rings = _age(rings, delta)
	bolts = _age(bolts, delta)
	tracers = _age(tracers, delta)
	flashes = _age(flashes, delta)
	texts = _age(texts, delta)
	meteors = _age(meteors, delta)
	scorches = _age(scorches, delta)
	for q in sprays:
		if q.e != null and is_instance_valid(q.e) and q.e.alive:
			q["b"] = q.e.pos
	sprays = _age(sprays, delta)
	mists = _age(mists, delta)
	shocks = _age(shocks, delta)
	fountains = _age(fountains, delta)
	jets = _age(jets, delta)
	var live: Array = []
	for q in puffs:
		if _time - float(q.t0) < float(q.max):
			live.append(q)
	puffs = live
	queue_redraw()


func _age(list: Array, dt: float) -> Array:
	var out: Array = []
	for it in list:
		it["life"] = it.life - dt
		if it.life > 0.0:
			out.append(it)
	return out


func _draw() -> void:
	for s in scorches:
		var k: float = s.life / s.max
		Draw.disc(self, s.p, s.r, Color(0.08, 0.05, 0.03, 0.45 * minf(1.0, k * 2.0)))
		Draw.disc(self, s.p, s.r * 0.6, Color(0.05, 0.03, 0.02, 0.35 * minf(1.0, k * 2.0)))
	if warp_t > 0.0:
		var fade := minf(1.0, warp_t / 0.6) * minf(1.0, (warp_max - warp_t) / 0.3)
		draw_rect(Rect2(Vector2.ZERO, Grid.field_size()), Color(0.45, 0.35, 1.0, 0.13 * fade))
		var center := Grid.field_size() / 2.0
		for i in 3:
			var ph := fmod(_time * 0.6 + i / 3.0, 1.0)
			Draw.arc(self, center, 40.0 + ph * 520.0, 0.0, TAU, 96, Color(0.7, 0.6, 1.0, 0.25 * (1.0 - ph) * fade), 3.0, true)
	for m in meteors:
		var k: float = m.life / m.max
		var pulse := 0.5 + 0.5 * sin(_time * 18.0)
		Draw.disc(self, m.p, m.r, Color(1.0, 0.3, 0.15, 0.08 + 0.06 * pulse))
		Draw.arc(self, m.p, m.r, 0.0, TAU, 48, Color(1.0, 0.45, 0.2, 0.7), 2.0, true)
		Draw.arc(self, m.p, m.r * (0.3 + 0.7 * k), 0.0, TAU, 32, Color(1.0, 0.7, 0.3, 0.5), 1.5, true)
		# Orbital targeting: a thin guide beam from orbit that thickens as the strike charges.
		var top := Vector2(m.p.x, -60.0)
		var charge := 1.0 - k
		draw_line(top, m.p, Color(1.0, 0.5, 0.25, 0.15 + 0.3 * charge), 2.0 + 6.0 * charge, true)
		draw_line(top, m.p, Color(1.0, 0.9, 0.7, 0.4 + 0.4 * charge), 1.0 + 1.5 * charge, true)
		for i in 3:
			var a := _time * 3.0 + TAU * float(i) / 3.0
			Draw.arc(self, m.p, m.r * (0.35 + 0.1 * float(i)), a, a + 1.2, 10, Color(1.0, 0.7, 0.35, 0.6), 2.0, true)
	for q in sprays:
		_spray(q)
	for m in mists:
		_mist(m)
	for q in puffs:
		_puff(q)
	for w in shocks:
		_shock(w)
	for f in fountains:
		_fountain(f)
	for j in jets:
		_jet(j)
	for f in flashes:
		var k: float = f.life / f.max
		Draw.disc(self, f.p, f.r * (0.6 + 0.4 * k), Color(f.c, f.c.a * k))
	for r in rings:
		var k: float = 1.0 - r.life / r.max
		var radius: float = lerpf(r.r0, r.r1, 1.0 - pow(1.0 - k, 3.0))
		if r.f:
			Draw.disc(self, r.p, radius, Color(r.c, 0.12 * (1.0 - k)))
		Draw.arc(self, r.p, radius, 0.0, TAU, 48, Color(r.c, r.c.a * (1.0 - k)), r.w, true)
	for b in bolts:
		var k: float = b.life / b.max
		Draw.polyline(self, b.pts, Color(b.c, 0.3 * k), b.w * 3.5, true)
		Draw.polyline(self, b.pts, Color(b.c, k), b.w, true)
		Draw.polyline(self, b.pts, Color(1, 1, 1, k), maxf(1.0, b.w * 0.4), true)
	for tr in tracers:
		var k: float = tr.life / tr.max
		draw_line(tr.a, tr.b, Color(tr.c, 0.35 * k), tr.w * 3.0, true)
		draw_line(tr.a, tr.b, Color(tr.c, k), tr.w * k + 0.5, true)
	for p in particles:
		var k: float = p.life / p.max
		Draw.disc(self, p.p, p.s * (0.4 + 0.6 * k), Color(p.c, p.c.a * k))
	for t in texts:
		var k: float = t.life / t.max
		var size: int = t.s
		var w := _font.get_string_size(t.t, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var pos: Vector2 = t.p - Vector2(w / 2.0, 0)
		var col := Color(t.c, minf(1.0, k * 2.0))
		draw_string_outline(_font, pos, t.t, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 4, Color(0, 0, 0, 0.8 * col.a))
		draw_string(_font, pos, t.t, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)


func _spray(q: Dictionary) -> void:
	var u: float = 1.0 - q.life / q.max
	var a: Vector2 = q.a
	var b: Vector2 = q.b
	var col: Color = q.c
	if q.mist:
		var p := a.lerp(b, u)
		for i in 4:
			Draw.disc(self, p + Vector2.from_angle(float(i) * 1.7 + u * 7.0) * 2.0, 2.4 + u * 2.4, Color(col, 0.3))
		return
	# Each drop flies to the enemy and is gone just after it lands, so the stream doesn't sit on the target (#112).
	for i in 9:
		var f := u * 1.6 - float(i) * 0.06
		if f < 0.0 or f > 1.12:
			continue
		var fade := 1.0 if f <= 1.0 else 1.0 - (f - 1.0) / 0.12
		f = minf(f, 1.0)
		var p := a.lerp(b, f) - Vector2(0, sin(PI * f) * 12.0)
		var r: float = (1.6 + 0.4 * float(i % 2)) * q.s
		Draw.disc(self, p, r, Color(col, (0.9 - float(i) * 0.06) * fade))
		if q.g:
			Draw.disc(self, p + Vector2(-0.4, -0.4), r * 0.35, Color(1, 1, 1, 0.55 * (1.0 - float(i) * 0.08)))
		if q.bub and i % 3 == 0:
			Draw.ring(self, p + Vector2(0, -2), 1.3, Color(col.lightened(0.4), 0.5), 0.6)


func _mist(m: Dictionary) -> void:
	var age: float = m.max - m.life
	var travel := 1.0 if m.k else 1.8
	var raw := age / travel
	var u := minf(1.0, raw)
	var fade := minf(1.0, m.life / 0.6)
	var a := (0.55 + 0.45 * (1.0 - minf(1.0, raw / 2.0))) * fade
	var r: float = m.r
	if m.k:
		Draw.disc(self, m.p, r, Color(m.c, 0.08 * fade))
	for i in 22:
		var sd: float = m.seed + float(i)
		var ang := _rnd(sd) * TAU + _time * 0.1 * (1.0 if i % 2 == 1 else -1.0)
		var rr := r * minf(1.0 if m.k else u, _rnd(sd + 9.0))
		Draw.disc(self, m.p + Vector2.from_angle(ang) * rr, 5.8 + 1.9 * sin(_time * 1.5 + float(i)), Color(m.c, 0.16 * a))
	if not m.k and raw < 1.2:
		Draw.arc(self, m.p, r * u, 0.0, TAU, 48, Color(m.c, 0.35 * (1.0 - raw / 1.2)), 2.0, true)


## The design pages' hash: a fixed pseudo-random 0..1 for x.
static func _rnd(x: float) -> float:
	var v := sin(x * 12.9898) * 43758.5453
	return v - floor(v)


## The Shockwave Generator's blast (its page, Mushroom Pulse): two rings roll out to `radius` in 0.6 s, each enemy they cross (`hits`)
## flashes as the wave reaches it; the Megaton Wave adds a nuclear flash. `pw` thickens the rings with the Power path.
func shock_wave(pos: Vector2, radius: float, color: Color, pw: float, hits: Array, mega: bool, sc: float) -> void:
	shocks.append({"p": pos, "r": radius, "c": color, "pw": pw, "hits": hits, "mega": mega, "sc": sc, "life": 1.1, "max": 1.1})


## One smoke puff with its own lifetime: it flies out along `vel` slowing with `drag`, grows by `grow` px, and cools from `hot` to `col`
## over `hot_t` s (a fire puff, `fire`, burns amber to red first, then cools to `col` over `hot_t`, or 1.3 s if it's 0). `al` is its
## start alpha, `f2` how much faster it fades late.
func puff(p0: Vector2, vel: Vector2, drag: float, r0: float, grow: float, col: Color, hot: Color, hot_t: float, al: float, life: float, delay := 0.0, oy := 0.0, f2 := 0.3, fire := false) -> void:
	puffs.append({"p": p0, "v": vel, "d": drag, "r0": r0, "g": grow, "c": col, "h": hot, "ht": hot_t, "al": al, "t0": _time + delay, "max": life, "oy": oy, "f2": f2, "fire": fire})


func _puff(q: Dictionary) -> void:
	var age: float = _time - float(q.t0)
	if age < 0.0:
		return
	var u: float = age / float(q.max)
	var dr: float = (1.0 - exp(-float(q.d) * age)) / float(q.d)
	var p: Vector2 = q.p + q.v * dr + Vector2(0, q.oy)
	var col: Color = q.c
	if q.fire:
		col = Color(1.0, 0.7, 0.28).lerp(Color(0.95, 0.3, 0.1), minf(1.0, age / 0.7)).lerp(q.c, minf(1.0, age / (float(q.ht) if float(q.ht) > 0.0 else 1.3)))
	elif float(q.ht) > 0.0:
		col = q.c.lerp(q.h, maxf(0.0, 1.0 - age / float(q.ht)) * 0.8)
	Draw.disc(self, p, float(q.r0) + float(q.g) * minf(1.0, u * 1.3), Color(col, float(q.al) * (1.0 - u) * (1.0 - u * float(q.f2))))


## How far out a blast's leading ring is (0..1 of its radius) at `age` of its `life`: easing out over the whole life, so it
## is still moving as it fades.
static func shock_front(age: float, life: float) -> float:
	var x := clampf(age / maxf(life, 0.001), 0.0, 1.0)
	return 1.0 - (1.0 - x) * (1.0 - x)


func _shock(w: Dictionary) -> void:
	var age: float = w.max - w.life
	# The rings ease out over the blast's whole life and fade as they go, so they never stop before fading (#110).
	var x: float = age / float(w.max)
	var u := shock_front(age, float(w.max))
	var a := 1.0 - x
	var r: float = w.r
	if w.mega and age < 0.4:
		var fu := age / 0.4
		Draw.disc(self, w.p, 29.8 * minf(1.0, fu * 3.0) * float(w.sc), Color(1, 0.97, 0.85, 0.8 * (1.0 - fu)))
		Draw.disc(self, w.p, 14.4 * minf(1.0, fu * 3.0), Color(1, 1, 1, 0.9 * (1.0 - fu)))
	for j in 2:
		var q := u - float(j) * 0.15
		if q > 0.0:
			Draw.arc(self, w.p, r * q, 0.0, TAU, 48, Color(w.c, 0.7 * a * (1.0 - float(j) * 0.4)), 2.5 + float(w.pw) - float(j), true)
	for e in w.hits:
		# The moment the leading ring reaches the enemy: invert the easing.
		var h: float = age - float(w.max) * (1.0 - sqrt(maxf(0.0, 1.0 - minf(1.0, float(e.d) / maxf(r, 1.0)))))
		if h >= 0.0 and h < 0.3:
			var er: float = e.r
			Draw.glow_dot(self, e.p, er * 0.6 * (1.0 - h / 0.3) * (0.9 + 0.2 * float(w.pw)), Color(1.0, 0.95, 0.8, 0.8))
			Draw.arc(self, e.p, er + h * 14.0, 0.0, TAU, 20, Color(w.c, 1.0 - h / 0.3), 1.5, true)


## One of Constant Spray's drops, or a mist puff (`mist`): it leaves `from` along `dir` and reaches `reach` px further at the end
## of its life, whatever the head does meanwhile. A puff spreads off its line, billows, rises a little and thins as it goes.
func jet(from: Vector2, dir: Vector2, reach: float, color: Color, size: float, mist: bool, life: float) -> void:
	jets.append({"p": from, "d": dir, "reach": reach, "c": color, "s": size, "mist": mist, "j": randf() - 0.5, "far": 0.75 + 0.2 * randf(), "life": life, "max": life})


func _jet(j: Dictionary) -> void:
	var u: float = 1.0 - j.life / j.max
	var s: float = j.s
	if j.mist:
		var d: Vector2 = (j.d as Vector2).rotated(float(j.j) * 0.4 * u)
		var p: Vector2 = j.p + d * u * float(j.reach) * float(j.far) - Vector2(0, u * u * 6.0 * s)
		var rr := (3.0 + u * 13.0) * 0.6 * s
		Draw.disc(self, p, rr, Color(j.c, 0.16 * (1.0 - u)))
		Draw.disc(self, p, rr * 0.55, Color((j.c as Color).lightened(0.35), 0.2 * (1.0 - u)))
		return
	var d2: Vector2 = (j.d as Vector2).rotated(float(j.j) * 0.05 * u)
	Draw.disc(self, j.p + d2 * u * float(j.reach), (1.2 + u * 3.2) * 0.8 * s, Color(j.c, 0.75 * (1.0 - u)))


## The Scrapyard's payout (its page, Melt and Pour): a flare and a fan of six coins vented from the furnace's mouth, falling back.
func fountain(pos: Vector2) -> void:
	fountains.append({"p": pos, "life": 1.6, "max": 1.6})


func _fountain(f: Dictionary) -> void:
	var v: float = 1.0 - f.life / f.max
	if v < 0.25:
		Draw.glow_dot(self, f.p, 10.6 * (1.0 - v / 0.25), Color(1.0, 0.85, 0.45))
	for i in 6:
		var d := Vector2.from_angle(-PI / 2.0 + (float(i) - 2.5) * 0.35)
		var p: Vector2 = f.p + d * 24.0 * minf(1.0, v * 2.0) + Vector2(0, v * v * 19.2)
		Draw.disc(self, p, 3.2, Color(Draw.OUTLINE, 0.95 * (1.0 - v)))
		Draw.disc(self, p, 2.2, Color(Draw.GOLD, 1.0 - v))
