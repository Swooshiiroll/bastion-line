extends Node2D

const Draw = preload("res://scripts/view/Draw.gd")
## Animated, additively blended lane lighting: chevrons flowing toward the core (between rounds only), the warp-gate vortex
## and the core's pulse. Redrawn every frame; cheap enough (a few hundred primitives).

const Grid = preload("res://scripts/core/Grid.gd")
const Terrain = preload("res://scripts/view/Terrain.gd")
const Game = preload("res://scripts/core/Game.gd")

const SPACING := 36.0
const SPEED := 40.0
## Seconds for the direction chevrons to fade in (between rounds) or out (when a round starts).
const FADE_TIME := 0.6

var game

var grid
var t := 0.0
var _edge := Color(0.2, 0.8, 1.0)
var _routes: Array = []
## Chevron visibility, 0-1: shown only between rounds, so the lanes stay clean in combat.
var _show := 1.0


func _ready() -> void:
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat
	_edge = Terrain.palette(grid.def.theme).edge
	for curve in grid.ground_paths:
		_routes.append(curve)


func _process(delta: float) -> void:
	t += delta
	var want := 1.0 if game == null or game.state == Game.State.BUILD else 0.0
	_show = move_toward(_show, want, delta / FADE_TIME)
	queue_redraw()


func _draw() -> void:
	var field := Rect2(Vector2.ZERO, Grid.field_size())
	for curve in (_routes if _show > 0.01 else []):
		var length: float = curve.get_baked_length()
		var d := fmod(t * SPEED, SPACING)
		while d < length:
			var p: Vector2 = curve.sample_baked(d)
			if field.has_point(p):
				var ahead: Vector2 = curve.sample_baked(minf(d + 4.0, length))
				var dir := (ahead - p).normalized()
				if dir != Vector2.ZERO:
					var n := dir.orthogonal()
					var fade := 0.10 + 0.08 * sin(d * 0.05 - t * 2.0)
					var col := Color(_edge, fade * _show)
					Draw.polyline(self, PackedVector2Array([p - dir * 4.0 + n * 6.0, p + dir * 3.0, p - dir * 4.0 - n * 6.0]), col, 2.5, true)
			d += SPACING
	for group in grid.groups:
		var pts: Array = grid.waypoints[group.routes[0]]
		var gate := Terrain.gate_pos(pts)
		for i in 3:
			var r := 6.0 + 5.0 * float(i)
			var start := t * (2.5 - float(i) * 0.6) + float(i) * 2.0
			Draw.arc(self, gate, r, start, start + 3.6, 16, Color(1.0, 0.25, 0.6, 0.35), 2.0, true)
		Draw.disc(self, gate, 8.0 + 2.0 * sin(t * 5.0), Color(1.0, 0.2, 0.5, 0.18))
	var core := Terrain.core_pos(grid.waypoints[0])
	var pulse := 0.5 + 0.5 * sin(t * 2.5)
	Draw.disc(self, core, 14.0 + 4.0 * pulse, Color(0.3, 0.8, 1.0, 0.12))
	Draw.arc(self, core, 27.0 + 3.0 * pulse, 0.0, TAU, 48, Color(0.3, 0.85, 1.0, 0.25 * (1.0 - pulse)), 2.0, true)
