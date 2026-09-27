extends Control
## Base for the in-game pop-out menus (shop, upgrade tree, research, intel): a holo panel with a
## title strip and a close button that slides in from `slide` and swallows clicks, so nothing
## underneath (the battlefield) reacts to them. Subclasses fill `body` in _build().

const UiKit = preload("res://scripts/ui/UiKit.gd")

signal close_requested

const TITLE_H := 44.0
const SLIDE_TIME := 0.16
const CLOSE_TIME := 0.12

var title := ""
var title_color := UiKit.ACCENT
var rect := Rect2()
## Offset the panel slides in from (e.g. Vector2(320, 0) = from the right).
var slide := Vector2(0, -16)
var body: Control
var header: HBoxContainer
var _tween: Tween


func _init(panel_rect: Rect2, title_text: String, slide_from := Vector2(0, -16)) -> void:
	rect = panel_rect
	title = title_text
	slide = slide_from


func _ready() -> void:
	# A panel that slides in from the right edge stays against the window's right edge when the
	# window is wider than the layout.
	if slide.x > 0.0:
		rect.position.x += UiKit.view_offset().x
	theme = UiKit.theme()
	position = rect.position
	size = rect.size
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := Panel.new()
	var sb := UiKit.box(Color(0.03, 0.045, 0.07, 0.97), UiKit.ACCENT, 10, 1, 0.0)
	sb.shadow_color = Color(UiKit.ACCENT, 0.18)
	sb.shadow_size = 14
	bg.add_theme_stylebox_override("panel", sb)
	bg.size = rect.size
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	header = UiKit.hbox(12)
	header.position = Vector2(16, 8)
	header.size = Vector2(rect.size.x - 60, 30)
	header.alignment = BoxContainer.ALIGNMENT_BEGIN
	add_child(header)
	var t := UiKit.label(title, 16, title_color)
	t.add_theme_constant_override("outline_size", 4)
	header.add_child(t)
	var x := UiKit.button("×", func(): close_requested.emit(), Vector2(30, 30))
	x.tooltip_text = "Close  [Esc]"
	x.position = Vector2(rect.size.x - 40, 7)
	add_child(x)
	var line := ColorRect.new()
	line.color = UiKit.BORDER
	line.position = Vector2(10, TITLE_H - 1)
	line.size = Vector2(rect.size.x - 20, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line)
	body = Control.new()
	body.position = Vector2(0, TITLE_H)
	body.size = Vector2(rect.size.x, rect.size.y - TITLE_H)
	body.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(body)
	_build()
	# Slide and fade in.
	modulate.a = 0.0
	position = rect.position + slide
	_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position", rect.position, SLIDE_TIME)
	_tween.tween_property(self, "modulate:a", 1.0, SLIDE_TIME)


## Slides and fades back out the way it came in, then frees itself. The HUD has already dropped
## it, so it counts as closed at once; it just stops taking clicks while it goes.
func dismiss() -> void:
	propagate_call("set", ["mouse_filter", Control.MOUSE_FILTER_IGNORE])
	if _tween != null:
		_tween.kill()
	_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "position", rect.position + slide, CLOSE_TIME)
	_tween.tween_property(self, "modulate:a", 0.0, CLOSE_TIME)
	_tween.chain().tween_callback(queue_free)


## Subclasses add their content to `body` (and optionally to `header`).
func _build() -> void:
	pass


## Called every frame by the HUD while open.
func refresh(_delta: float) -> void:
	pass
