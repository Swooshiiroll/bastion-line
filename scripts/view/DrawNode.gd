extends Node2D
## A Node2D that draws through a callable. Handy for one-off layers such as the build ghost.

var draw_fn: Callable


func _draw() -> void:
	if draw_fn.is_valid():
		draw_fn.call(self)
