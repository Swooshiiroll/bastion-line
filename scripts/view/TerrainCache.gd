extends Node2D
## The static battlefield (Terrain) drawn once into textures and shown as sprites, instead of
## Terrain replaying its ~1 million primitives (tens of thousands of draw calls) every frame.
## Two bakes: the whole deck at the window's pixel scale, and the playable field again at up to
## the highest zoom, so it stays sharp when zoomed in. Rebaked when the window's scale changes and
## when the terrain itself changes (refresh(), e.g. cleared rubble).

const Terrain = preload("res://scripts/view/Terrain.gd")
const Grid = preload("res://scripts/core/Grid.gd")
const ZOOM_MAX := 2.5
## The field bake is capped so its texture stays under ~4600×2300 (about 42 MB).
const FIELD_SCALE_CAP := 3.0
const DECK_SCALE_CAP := 2.0

var grid
var cleared := {}
var _bakes: Array = []
var _scale := 0.0


func _ready() -> void:
	get_viewport().size_changed.connect(_on_resize)
	_build()


## Redraws the baked terrain (after the map changed, like cleared rubble).
func refresh() -> void:
	for b in _bakes:
		b.painter.queue_redraw()
		b.view.render_target_update_mode = SubViewport.UPDATE_ONCE


func _pixel_scale() -> float:
	return maxf(1.0, get_viewport().get_final_transform().get_scale().y)


func _on_resize() -> void:
	if not is_equal_approx(_pixel_scale(), _scale):
		_build()


func _build() -> void:
	_scale = _pixel_scale()
	var m := Vector2(Terrain.MARGIN_COLS, Terrain.MARGIN_ROWS) * Grid.TILE
	var rects := [Rect2(-m, Grid.field_size() + m * 2.0), Rect2(Vector2.ZERO, Grid.field_size())]
	var scales := [minf(_scale, DECK_SCALE_CAP), minf(_scale * ZOOM_MAX, FIELD_SCALE_CAP)]
	for i in rects.size():
		if i >= _bakes.size():
			_bakes.append(_new_bake())
		_fit(_bakes[i], rects[i], scales[i])


## One bake: a SubViewport that draws a Terrain once, shown by a sprite scaled back to world size.
## Rebuilds reuse it (resizing a live viewport is cheaper and cleaner than freeing it).
func _new_bake() -> Dictionary:
	var view := SubViewport.new()
	view.transparent_bg = true
	view.disable_3d = true
	var painter := Terrain.new()
	painter.grid = grid
	painter.cleared = cleared
	view.add_child(painter)
	add_child(view)
	var sprite := Sprite2D.new()
	sprite.centered = false
	sprite.texture = view.get_texture()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(sprite)
	return {"view": view, "painter": painter, "sprite": sprite}


func _fit(b: Dictionary, rect: Rect2, s: float) -> void:
	b.view.size = Vector2i((rect.size * s).ceil())
	b.view.canvas_transform = Transform2D(0.0, Vector2(s, s), 0.0, -rect.position * s)
	b.painter.queue_redraw()
	b.view.render_target_update_mode = SubViewport.UPDATE_ONCE
	b.sprite.position = rect.position
	b.sprite.scale = Vector2.ONE / s
