extends Window
## The live tuner's window (issue #80, design/live_tuner.md): a native window docked to the right of the game's, as tall
## as it, following it as it moves. Its Dock switch frees it (to drag it to another monitor); if the game fills the
## screen it docks inside the screen's right edge. Boot opens it when the game is launched with --dev; F8 shows or hides it.

const TunerPanel = preload("res://scripts/dev/TunerPanel.gd")
const UiKit = preload("res://scripts/ui/UiKit.gd")

const WIDTH := 640

var panel: Panel
var docked := true


func _init() -> void:
	title = "Bastion Line: Live Tuner"
	# A window can't turn native while it's shown, and windows start shown: hide it until it's in the tree.
	visible = false
	force_native = true
	size = Vector2i(WIDTH, 900)
	min_size = Vector2i(440, 360)
	theme = UiKit.theme()
	close_requested.connect(hide)
	panel = TunerPanel.new()
	add_child(panel)
	var dock := CheckBox.new()
	dock.text = "Dock"
	dock.button_pressed = true
	dock.focus_mode = Control.FOCUS_NONE
	dock.tooltip_text = "Keep the tuner beside the game's window"
	dock.toggled.connect(func(on: bool): docked = on)
	panel.toolbar.add_child(dock)


func _ready() -> void:
	show()
	_dock()


func _process(_delta: float) -> void:
	if docked and visible:
		_dock()


## Beside the game's window (outside its frame), at its height; inside the screen's right edge if there's no room.
func _dock() -> void:
	var main := DisplayServer.MAIN_WINDOW_ID
	var me := get_window_id()
	var frame := position - DisplayServer.window_get_position_with_decorations(me)
	var mp := DisplayServer.window_get_position_with_decorations(main)
	var ms := DisplayServer.window_get_size_with_decorations(main)
	var area := DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen(main))
	var want := Vector2i(mp.x + ms.x, mp.y) + frame
	if want.x + size.x + frame.x > area.end.x:
		want.x = area.end.x - size.x - frame.x
	var h := maxi(min_size.y, DisplayServer.window_get_size(main).y)
	if size.y != h:
		size = Vector2i(size.x, h)
	if position != want:
		position = want
