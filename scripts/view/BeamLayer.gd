extends Node2D
## Additively blended continuous effects read straight from game state each frame:
## laser beams (thicker as they ramp up) and the energy links from pylons to boosted towers.

const Draw = preload("res://scripts/view/Draw.gd")

var world


func _ready() -> void:
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var g = world.game
	if g == null:
		return
	var t: float = world.anim_t
	for tw in g.towers:
		if tw.is_support():
			_pylon(tw, g, t)
		elif tw.is_beam() and not tw.sweep_angles.is_empty():
			_sweeps(tw, t)
		elif tw.is_beam() and not tw.beam_targets.is_empty():
			_beams(tw, t)
	for z in g.storms:
		_storm(z, t)


func _beams(tw, t: float) -> void:
	var acc := Draw.accent(tw.type, tw.spec)
	var d := Vector2.from_angle(tw.aim)
	var src: Vector2 = tw.pos + d * 11.0
	var ramp: float = tw.ramp_mult
	for i in tw.beam_targets.size():
		var e = tw.beam_targets[i]
		if e == null or not e.alive:
			continue
		var w := (1.5 + 1.1 * ramp) * (1.0 if i == 0 else 0.6)
		var flick := 0.85 + 0.15 * sin(t * 50.0 + float(i))
		draw_line(src, e.pos, Color(acc, 0.18 * flick), w * 4.0, true)
		draw_line(src, e.pos, Color(acc, 0.6 * flick), w * 1.6, true)
		draw_line(src, e.pos, Color(1, 1, 1, 0.8 * flick), maxf(1.0, w * 0.45), true)
		draw_circle(e.pos, w * 2.2, Color(acc, 0.35))
		draw_circle(e.pos, w * 0.9, Color(1, 1, 1, 0.7))
	draw_circle(src, 3.0 + ramp, Color(acc, 0.4))


## Laser Lance branch C: beams sweeping across their arc out to full range.
func _sweeps(tw, t: float) -> void:
	var acc := Draw.accent(tw.type, tw.spec)
	var r: float = tw.get_range()
	for a in tw.sweep_angles:
		var d := Vector2.from_angle(float(a))
		var src: Vector2 = tw.pos + d * 11.0
		var end: Vector2 = tw.pos + d * r
		var flick := 0.85 + 0.15 * sin(t * 45.0 + float(a))
		draw_line(src, end, Color(acc, 0.16 * flick), 9.0, true)
		draw_line(src, end, Color(acc, 0.55 * flick), 3.0, true)
		draw_line(src, end, Color(1, 1, 1, 0.7 * flick), 1.2, true)
		draw_circle(end, 4.0, Color(acc, 0.3))


## A short-lived storm zone (an Ion Storm secondary).
func _storm(z: Dictionary, t: float) -> void:
	var col := Draw.SPEC_ALT.ionstorm
	var r := float(z.r)
	var k := clampf(float(z.t) / 0.5, 0.0, 1.0)
	draw_circle(z.pos, r, Color(col, 0.07 * k))
	for i in 3:
		var a := t * 9.0 + float(i) * 2.1
		var p0: Vector2 = z.pos + Vector2.from_angle(a) * r * 0.3
		var p1: Vector2 = z.pos + Vector2.from_angle(a + 0.6) * r * 0.9
		draw_line(p0, p1, Color(col, 0.5 * k), 1.4, true)
	draw_arc(z.pos, r, 0.0, TAU, 32, Color(col, 0.35 * k), 1.2, true)

func _pylon(a, g, t: float) -> void:
	# Scrapyards only show a field when a branch gives them one; only Supply Depots link to towers.
	if a.is_economy() and not a.stats().has("range"):
		return
	var links: bool = not a.is_economy() or float(a.stats().get("discount", 0.0)) > 0.0
	var acc := Draw.accent(a.type, a.spec)
	var r: float = a.get_range()
	var ph := fmod(t * 0.5, 1.0)
	draw_arc(a.pos, r * ph, 0.0, TAU, 48, Color(acc, 0.12 * (1.0 - ph)), 2.0, true)
	for tw in g.towers:
		if not links or tw == a or tw.is_support() or a.pos.distance_to(tw.pos) > r:
			continue
		var k := fmod(t * 1.2 + float(tw.cell.x + tw.cell.y) * 0.21, 1.0)
		draw_line(a.pos, tw.pos, Color(acc, 0.08), 2.0, true)
		draw_circle(a.pos.lerp(tw.pos, k), 2.2, Color(acc, 0.5))
