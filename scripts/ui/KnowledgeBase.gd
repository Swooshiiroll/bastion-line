extends Node
## Codex screen (from the main menu): starfield, title, the shared KnowledgePanel, Back.
## The same panel also opens in battle as a pop-out (K or F1).

const UiKit = preload("res://scripts/ui/UiKit.gd")
const KnowledgePanel = preload("res://scripts/ui/KnowledgePanel.gd")

var app
var panel


func _ready() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := UiKit.root()
	layer.add_child(root)
	root.add_child(UiKit.starfield())
	var title := UiKit.label("CODEX", 40, UiKit.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_constant_override("outline_size", 10)
	title.position = Vector2(0, 40)
	title.size = Vector2(1600, 56)
	root.add_child(title)
	var sub := UiKit.label("Every tower, enemy, effect and rule in Bastion Line. In battle, K or F1 opens it on whatever you have selected.", 14, UiKit.DIM, HORIZONTAL_ALIGNMENT_CENTER)
	sub.position = Vector2(0, 94)
	sub.size = Vector2(1600, 20)
	root.add_child(sub)
	panel = KnowledgePanel.new(Vector2(1552, 600))
	panel.position = Vector2(24, 128)
	root.add_child(panel)
	var back := UiKit.button("Back  [Esc]", func(): app.show_menu(), Vector2(150, 42))
	back.position = Vector2(24, 744)
	root.add_child(back)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		app.show_menu()
