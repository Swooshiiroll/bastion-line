extends Control
## A Control that draws through a callable (used for tower/enemy icons in the UI).

var draw_fn: Callable
var animate := false


func _init(fn: Callable = Callable(), px := Vector2(32, 32), anim := false) -> void:
	draw_fn = fn
	custom_minimum_size = px
	size = px
	animate = anim
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	if animate and is_visible_in_tree():
		queue_redraw()


func _draw() -> void:
	if draw_fn.is_valid():
		draw_fn.call(self)
