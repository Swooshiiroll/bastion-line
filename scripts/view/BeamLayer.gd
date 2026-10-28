extends Node2D
## Additively blended continuous effects read straight from game state each frame:
## laser beams (thicker as they ramp up) and the energy links from pylons to boosted towers.

const Draw = preload("res://scripts/view/Draw.gd")
const LaserTowerArt = preload("res://scripts/view/towers/LaserTowerArt.gd")

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
		elif tw.is_beam() and tw.beam_on and not tw.beam_targets.is_empty():
			_laser_beams(tw, t)
	for z in g.storms:
		_storm(z, t)
	for z in g.trails:
		_trail(z, t)
	for tw in g.towers:
		if tw.type == "tractor_tower" and tw.target != null and float(tw.gun_cds.get("hold_left", 0.0)) > 0.0 and tw.target.alive:
			_tractor_beam(tw, t)
		elif tw.type == "magneto_tower" and tw.disabled <= 0.0:
			_magneto_field(tw, t)


## The Laser Tower's beams (the confirmed art): each ramps on its own target, widening and whitening with the Power path, wrapped
## in gold at the mastery's full ramp; the extra beams are thinner by their share of the power.
func _laser_beams(tw, t: float) -> void:
	var acc := Draw.accent(tw.type, tw.spec)
	var s: Dictionary = tw.stats()
	var k := 1.0 if tw.size <= 1 else 1.8
	for i in tw.beam_targets.size():
		var e = tw.beam_targets[i]
		if e == null or not e.alive:
			continue
		var held: float = tw.beam_ramps[i] if i < tw.beam_ramps.size() else 0.0
		var g := clampf(held / float(s.ramp_time), 0.0, 1.0)
		var frac: float = 1.0 if i == 0 else float(s.get("beam_power", 0.4))
		var st := LaserTowerArt.beam_style(tw.spec, g, float(s.ramp), frac, acc)
		var src := LaserTowerArt.beam_origin(tw.pos, tw.aim, k, tw.spec, i)
		var col: Color = st.col
		var w: float = st.w
		var flick := 0.85 + 0.15 * sin(t * 50.0 + float(i))
		if st.gold:
			draw_line(src, e.pos, Color(Draw.GOLD, 0.35), w * 3.2, true)
		draw_line(src, e.pos, Color(col, 0.18 * flick), w * 4.0, true)
		draw_line(src, e.pos, Color(col, float(st.alpha) * flick), w * 1.6, true)
		draw_line(src, e.pos, Color(1, 1, 1, 0.8 * flick), maxf(1.0, w * 0.45), true)
		Draw.disc(self, e.pos, w * 2.2, Color(col, 0.35))
		Draw.disc(self, e.pos, w * 0.9, Color(1, 1, 1, 0.7))
	Draw.disc(self, LaserTowerArt.beam_origin(tw.pos, tw.aim, k, tw.spec, 0), 3.0 + tw.ramp_mult * 0.5, Color(acc, 0.4))


## The Tractor Tower's focus beam: a bright line to the held enemy with rings sliding back down it, afterimages of the enemy gliding backward.
func _tractor_beam(tw, t: float) -> void:
	var acc: Color = Draw.ACCENT.tractor_tower
	var src: Vector2 = tw.pos + Vector2.from_angle(tw.aim) * 18.0
	var dst: Vector2 = tw.target.pos
	draw_line(src, dst, Color(acc, 0.18), 7.0, true)
	draw_line(src, dst, Color(acc, 0.7), 2.4, true)
	draw_line(src, dst, Color(1, 1, 1, 0.8), 1.0, true)
	for i in 4:
		var u := fmod(t * 1.4 + float(i) / 4.0, 1.0)
		var p := dst.lerp(src, u)
		Draw.ring(self, p, 2.5 + 3.0 * (1.0 - u), Color(acc, 0.8 * (1.0 - u)), 1.0)
	Draw.disc(self, dst, tw.target.radius + 4.0, Color(acc, 0.25))


## The Magneto Tower's field: a faint ring at its reach, with a ring drawn inward toward the coil (the pull).
func _magneto_field(tw, t: float) -> void:
	var r: float = tw.get_range()
	var acc: Color = Draw.ACCENT.magneto_tower
	Draw.arc(self, tw.pos, r, 0.0, TAU, 56, Color(acc, 0.16), 1.2, true)
	for i in 2:
		var u := fmod(t * 0.5 + float(i) * 0.5, 1.0)
		Draw.arc(self, tw.pos, r * (1.0 - u), 0.0, TAU, 48, Color(acc, 0.12 * (1.0 - u)), 1.5, true)


## A Railgun ion trail: a lingering, crackling line of ion-blue (gold at the Power mastery) that fades with its time.
func _trail(z: Dictionary, t: float) -> void:
	var col: Color = Draw.ACCENT.railgun
	if z.source != null and z.source.mastered and z.source.primary() == "a":
		col = Draw.GOLD
	var k := clampf(float(z.t) / 2.0, 0.0, 1.0)
	var a: Vector2 = z.a
	var b: Vector2 = z.b
	draw_line(a, b, Color(col, 0.12 * k), float(z.w), true)
	draw_line(a, b, Color(col, 0.35 * k), 3.0, true)
	var d := (b - a).normalized()
	var o := d.orthogonal()
	var len := a.distance_to(b)
	for i in 8:
		var q := fmod(float(i) / 8.0 + t * 0.4, 1.0)
		var p := a + d * len * q
		var j := o * sin(t * 30.0 + float(i) * 2.3) * 5.0
		draw_line(p - j, p + j + d * 10.0, Color(col, 0.8 * k), 1.0, true)


## A short-lived storm zone (an Ion Storm secondary).
func _storm(z: Dictionary, t: float) -> void:
	var col: Color = Draw.ACCENT.tesla_tower
	if z.source != null and z.source.mastered and z.source.primary() == "b":
		col = Draw.GOLD
	var r := float(z.r)
	var k := clampf(float(z.t) / 0.5, 0.0, 1.0)
	Draw.disc(self, z.pos, r, Color(col, 0.07 * k))
	for i in 3:
		var a := t * 9.0 + float(i) * 2.1
		var p0: Vector2 = z.pos + Vector2.from_angle(a) * r * 0.3
		var p1: Vector2 = z.pos + Vector2.from_angle(a + 0.6) * r * 0.9
		draw_line(p0, p1, Color(col, 0.5 * k), 1.4, true)
	Draw.arc(self, z.pos, r, 0.0, TAU, 32, Color(col, 0.35 * k), 1.2, true)

func _pylon(a, g, t: float) -> void:
	# Scrapyards only show a field when a branch gives them one; only Supply Depots link to towers.
	if a.is_economy() and not a.stats().has("range"):
		return
	var links: bool = not a.is_economy() or float(a.stats().get("discount", 0.0)) > 0.0
	var acc := Draw.accent(a.type, a.spec)
	var r: float = a.get_range()
	var ph := fmod(t * 0.5, 1.0)
	Draw.arc(self, a.pos, r * ph, 0.0, TAU, 48, Color(acc, 0.12 * (1.0 - ph)), 2.0, true)
	for tw in g.towers:
		if not links or tw == a or tw.is_support() or a.pos.distance_to(tw.pos) > r:
			continue
		var k := fmod(t * 1.2 + float(tw.cell.x + tw.cell.y) * 0.21, 1.0)
		draw_line(a.pos, tw.pos, Color(acc, 0.08), 2.0, true)
		Draw.disc(self, a.pos.lerp(tw.pos, k), 2.2, Color(acc, 0.5))
