extends Control
## The title screen's backdrop: a planet's horizon with the Bastion core at its crest, a line of
## mastered towers along the ridge and a Leviathan crossing the sky with its escorts, the towers
## firing up at it. Drawn over the starfield; it bleeds past the 1600×900 layout to fill any window.

const Draw = preload("res://scripts/view/Draw.gd")
const UiKit = preload("res://scripts/ui/UiKit.gd")

## The planet: a huge circle whose crest sits just below the menu.
const PLANET_C := Vector2(800, 2400)
const PLANET_R := 1740.0
const CREST_Y := PLANET_C.y - PLANET_R
## Towers along the ridge: [type, spec, x]. The core sits at the crest between them.
const LINE := [
	["drones", "interceptors", 150.0], ["missile", "hellfire", 320.0], ["tesla", "storm", 480.0], ["arrow", "gatling", 640.0],
	["laser", "prism", 960.0], ["sniper", "lance", 1120.0], ["nova", "supernova", 1280.0], ["flak", "skyshred", 1450.0],
]
const SHOT_LIFE := 0.22

var t := 0.0
var _shots: Array = []
var _next_shot := 0.8
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	size = UiKit.SCREEN
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rng.seed = 7


func _process(delta: float) -> void:
	t += delta
	_next_shot -= delta
	if _next_shot <= 0.0:
		_next_shot = _rng.randf_range(0.18, 0.55)
		var i := _rng.randi() % LINE.size()
		var targets := _targets()
		if not targets.is_empty():
			_shots.append({"i": i, "to": targets[_rng.randi() % targets.size()] + Vector2(_rng.randf_range(-14, 14), _rng.randf_range(-10, 10)), "age": 0.0})
	for s in _shots:
		s.age += delta
	_shots = _shots.filter(func(s): return s.age < SHOT_LIFE)
	queue_redraw()


## Where a ridge x sits on the planet's surface.
static func ridge_y(x: float) -> float:
	var dx := x - PLANET_C.x
	return PLANET_C.y - sqrt(maxf(0.0, PLANET_R * PLANET_R - dx * dx))


func _leviathan_pos() -> Vector2:
	var full := UiKit.full_rect()
	var span := full.size.x + 700.0
	return Vector2(full.position.x - 350.0 + fmod(t * 26.0 + 900.0, span), 318.0 + sin(t * 0.4) * 14.0)


## The escorts: strike drones in a loose V behind the Leviathan, and a Locust swarm ahead.
func _escorts() -> Array:
	var lp := _leviathan_pos()
	var out: Array = []
	for k in 5:
		var side := 1.0 if k % 2 == 0 else -1.0
		var rank := float((k + 1) / 2)
		out.append(["bat", lp + Vector2(-110.0 - 55.0 * rank, side * 40.0 * rank + sin(t * 1.3 + k) * 6.0)])
	for k in 12:
		var ang := t * 0.9 + float(k) * 0.52
		out.append(["locust", lp + Vector2(150.0 + 40.0 * cos(ang) + float(k % 4) * 16.0, -60.0 + 30.0 * sin(ang * 1.3) + float(k / 4) * 22.0)])
	return out


func _targets() -> Array:
	var out: Array = [_leviathan_pos()]
	for e in _escorts():
		out.append(e[1])
	var full := UiKit.full_rect()
	return out.filter(func(p): return p.x > full.position.x + 20.0 and p.x < full.end.x - 20.0)


func _draw() -> void:
	var full := UiKit.full_rect()
	# Nebulae: soft layered glows behind everything.
	for n in [[Vector2(260, 180), 300.0, Color(0.45, 0.25, 0.85)], [Vector2(1380, 120), 260.0, Color(0.15, 0.55, 0.85)], [Vector2(1050, 430), 200.0, Color(0.85, 0.3, 0.55)]]:
		for k in 6:
			draw_circle(n[0], n[1] * (1.0 - 0.14 * k), Color(n[2], 0.022))
	# Enemies in the sky.
	var lp := _leviathan_pos()
	for e in _escorts():
		Draw.enemy(self, e[0], e[1], Vector2.RIGHT, 9.0 if e[0] == "bat" else 5.0, t + e[1].x * 0.01, false, 0.0, 1.5 if e[0] == "bat" else 1.4)
	Draw.enemy(self, "leviathan", lp, Vector2.RIGHT, 30.0, t, false, 0.0, 2.2)
	# The planet: atmosphere glow, the dark body, a lit rim and faint latitude lines.
	for k in 10:
		draw_circle(PLANET_C, PLANET_R + 70.0 - 7.0 * k, Color(0.2, 0.75, 1.0, 0.018))
	draw_circle(PLANET_C, PLANET_R, Color(0.025, 0.04, 0.065))
	draw_arc(PLANET_C, PLANET_R, PI, TAU, 256, Color(0.35, 0.85, 1.0, 0.85), 2.5, true)
	draw_arc(PLANET_C, PLANET_R - 4.0, PI, TAU, 256, Color(0.35, 0.85, 1.0, 0.25), 6.0, true)
	for k in 4:
		draw_arc(PLANET_C, PLANET_R - 60.0 - 70.0 * k, PI * 1.1, PI * 1.9, 180, Color(0.35, 0.75, 1.0, 0.05), 1.5, true)
	var lanes := fmod(t * 0.05, 1.0)
	draw_arc(PLANET_C, PLANET_R - 22.0, PI * (1.2 + 0.2 * lanes), PI * (1.45 + 0.2 * lanes), 60, Color(1.0, 0.8, 0.35, 0.12), 3.0, true)
	# The Bastion core at the crest.
	_core(Vector2(800, CREST_Y + 6.0))
	# Tracers from the ridge up into the sky.
	for s in _shots:
		var from: Vector2 = _tower_pos(int(s.i)) + Vector2(0, -16)
		var k: float = 1.0 - float(s.age) / SHOT_LIFE
		var col: Color = Draw.accent(LINE[int(s.i)][0], LINE[int(s.i)][1])
		draw_line(from, s.to, Color(col, 0.25 * k), 5.0, true)
		draw_line(from, s.to, Color(col, 0.9 * k), 1.6, true)
		draw_circle(s.to, 6.0 * k, Color(1.0, 0.9, 0.7, 0.8 * k))
	# The line of towers along the ridge, aiming at the Leviathan.
	for i in LINE.size():
		var p := _tower_pos(i)
		var flash := 0.0
		for s in _shots:
			if int(s.i) == i:
				flash = maxf(flash, 0.15 * (1.0 - float(s.age) / SHOT_LIFE))
		var aim := (lp - p).angle()
		Draw.tower(self, LINE[i][0], 4, p, aim, 2.3, t + float(i) * 0.7, flash, LINE[i][1])
	# Ground haze along the horizon, so the planet reads as a surface.
	var haze_y := CREST_Y + 40.0
	draw_rect(Rect2(full.position.x, haze_y, full.size.x, full.end.y - haze_y), Color(0.0, 0.01, 0.03, 0.35))


func _tower_pos(i: int) -> Vector2:
	var x: float = LINE[i][2]
	return Vector2(x, ridge_y(x) - 18.0)


## The core: a domed hex station with turning rings and a glowing heart.
func _core(c: Vector2) -> void:
	var pulse := 0.5 + 0.5 * sin(t * 2.0)
	for k in 5:
		draw_circle(c, 90.0 - 12.0 * k, Color(0.3, 0.85, 1.0, 0.03 + 0.01 * pulse))
	Draw.plate(self, c + Vector2(0, 8), Draw.ngon(6, 1.0, PI / 6.0), Draw.METAL_D, 0.0, 54.0, 2.0)
	Draw.plate(self, c, Draw.ngon(6, 1.0, PI / 6.0), Draw.METAL, 0.0, 42.0, 2.0)
	for k in 3:
		var r := 30.0 - 7.0 * k
		Draw.arc_segments(self, c, r, 3 + k, 0.35, t * (0.6 + 0.3 * k) * (1.0 if k % 2 == 0 else -1.0), Color(0.4, 0.9, 1.0, 0.7), 2.0)
	draw_circle(c, 14.0 + 3.0 * pulse, Color(0.4, 0.9, 1.0, 0.35))
	draw_circle(c, 10.0, Color(0.55, 0.95, 1.0))
	draw_circle(c, 5.0, Color(1, 1, 1))
