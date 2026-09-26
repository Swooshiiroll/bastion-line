extends Node2D
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
var warp_t := 0.0
var warp_max := 1.0
var _time := 0.0
var _font: Font


func _ready() -> void:
	_font = ThemeDB.fallback_font


func burst(pos: Vector2, color: Color, count: int, speed := 90.0, size := 2.5, life := 0.5, gravity := 0.0) -> void:
	for i in count:
		if particles.size() >= MAX_PARTICLES:
			return
		var v := Vector2.from_angle(randf() * TAU) * speed * randf_range(0.3, 1.0)
		var l := life * randf_range(0.6, 1.0)
		particles.append({"p": pos, "v": v, "life": l, "max": l, "c": color, "s": size * randf_range(0.6, 1.2), "g": gravity})


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
		draw_circle(s.p, s.r, Color(0.08, 0.05, 0.03, 0.45 * minf(1.0, k * 2.0)))
		draw_circle(s.p, s.r * 0.6, Color(0.05, 0.03, 0.02, 0.35 * minf(1.0, k * 2.0)))
	if warp_t > 0.0:
		var fade := minf(1.0, warp_t / 0.6) * minf(1.0, (warp_max - warp_t) / 0.3)
		draw_rect(Rect2(Vector2.ZERO, Grid.field_size()), Color(0.45, 0.35, 1.0, 0.13 * fade))
		var center := Grid.field_size() / 2.0
		for i in 3:
			var ph := fmod(_time * 0.6 + i / 3.0, 1.0)
			draw_arc(center, 40.0 + ph * 520.0, 0.0, TAU, 96, Color(0.7, 0.6, 1.0, 0.25 * (1.0 - ph) * fade), 3.0, true)
	for m in meteors:
		var k: float = m.life / m.max
		var pulse := 0.5 + 0.5 * sin(_time * 18.0)
		draw_circle(m.p, m.r, Color(1.0, 0.3, 0.15, 0.08 + 0.06 * pulse))
		draw_arc(m.p, m.r, 0.0, TAU, 48, Color(1.0, 0.45, 0.2, 0.7), 2.0, true)
		draw_arc(m.p, m.r * (0.3 + 0.7 * k), 0.0, TAU, 32, Color(1.0, 0.7, 0.3, 0.5), 1.5, true)
		# Orbital targeting: a thin guide beam from orbit that thickens as the strike charges.
		var top := Vector2(m.p.x, -60.0)
		var charge := 1.0 - k
		draw_line(top, m.p, Color(1.0, 0.5, 0.25, 0.15 + 0.3 * charge), 2.0 + 6.0 * charge, true)
		draw_line(top, m.p, Color(1.0, 0.9, 0.7, 0.4 + 0.4 * charge), 1.0 + 1.5 * charge, true)
		for i in 3:
			var a := _time * 3.0 + TAU * float(i) / 3.0
			draw_arc(m.p, m.r * (0.35 + 0.1 * float(i)), a, a + 1.2, 10, Color(1.0, 0.7, 0.35, 0.6), 2.0, true)
	for f in flashes:
		var k: float = f.life / f.max
		draw_circle(f.p, f.r * (0.6 + 0.4 * k), Color(f.c, f.c.a * k))
	for r in rings:
		var k: float = 1.0 - r.life / r.max
		var radius: float = lerpf(r.r0, r.r1, 1.0 - pow(1.0 - k, 3.0))
		if r.f:
			draw_circle(r.p, radius, Color(r.c, 0.12 * (1.0 - k)))
		draw_arc(r.p, radius, 0.0, TAU, 48, Color(r.c, r.c.a * (1.0 - k)), r.w, true)
	for b in bolts:
		var k: float = b.life / b.max
		draw_polyline(b.pts, Color(b.c, 0.3 * k), b.w * 3.5, true)
		draw_polyline(b.pts, Color(b.c, k), b.w, true)
		draw_polyline(b.pts, Color(1, 1, 1, k), maxf(1.0, b.w * 0.4), true)
	for tr in tracers:
		var k: float = tr.life / tr.max
		draw_line(tr.a, tr.b, Color(tr.c, 0.35 * k), tr.w * 3.0, true)
		draw_line(tr.a, tr.b, Color(tr.c, k), tr.w * k + 0.5, true)
	for p in particles:
		var k: float = p.life / p.max
		draw_circle(p.p, p.s * (0.4 + 0.6 * k), Color(p.c, p.c.a * k))
	for t in texts:
		var k: float = t.life / t.max
		var size: int = t.s
		var w := _font.get_string_size(t.t, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var pos: Vector2 = t.p - Vector2(w / 2.0, 0)
		var col := Color(t.c, minf(1.0, k * 2.0))
		draw_string_outline(_font, pos, t.t, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 4, Color(0, 0, 0, 0.8 * col.a))
		draw_string(_font, pos, t.t, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)
