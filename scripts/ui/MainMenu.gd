extends Node
## Title screen: a drawn backdrop (the Bastion line on a planet's horizon, under attack) behind the
## title and the buttons to continue, start, research, configure or quit.

const TitleBackdrop = preload("res://scripts/ui/TitleBackdrop.gd")
const UiKit = preload("res://scripts/ui/UiKit.gd")
const SettingsPanel = preload("res://scripts/ui/SettingsPanel.gd")
const ConfirmDialog = preload("res://scripts/ui/ConfirmDialog.gd")
const Maps = preload("res://data/maps.gd")
const Difficulty = preload("res://data/difficulty.gd")

var app
var _layer: CanvasLayer
var _modal_layer: CanvasLayer
var _modal: Control = null
var _buttons: VBoxContainer


func _ready() -> void:
	var back := CanvasLayer.new()
	back.layer = -1
	add_child(back)
	back.add_child(UiKit.starfield())
	back.add_child(TitleBackdrop.new())
	_layer = CanvasLayer.new()
	_layer.layer = 5
	add_child(_layer)
	_modal_layer = CanvasLayer.new()
	_modal_layer.layer = 20
	add_child(_modal_layer)
	_build_ui()


func _build_ui() -> void:
	var root := UiKit.root()
	_layer.add_child(root)
	var title := UiKit.label("BASTION LINE", 84, Color(0.85, 0.97, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_constant_override("outline_size", 18)
	title.add_theme_color_override("font_outline_color", Color(0.05, 0.35, 0.6, 0.85))
	title.position = Vector2(0, 64)
	title.size = Vector2(1600, 100)
	root.add_child(title)
	var tag := UiKit.label("SECTOR DEFENSE PROTOCOL  //  6 SECTORS  //  5 MODES  //  UP TO 120 ROUNDS", 18, UiKit.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	tag.add_theme_constant_override("outline_size", 6)
	tag.position = Vector2(0, 166)
	tag.size = Vector2(1600, 30)
	root.add_child(tag)

	var panel := PanelContainer.new()
	panel.position = Vector2(630, 232)
	panel.custom_minimum_size = Vector2(340, 0)
	root.add_child(panel)
	_buttons = UiKit.vbox(10)
	panel.add_child(_buttons)
	_fill_buttons()

	var foot := UiKit.label("B shop   1-9, 0, -, =, [, ], \\ build   E upgrade tree   R research   Space launch round   Q / W abilities   Esc close menus", 13, UiKit.DIM, HORIZONTAL_ALIGNMENT_CENTER)
	foot.add_theme_constant_override("outline_size", 4)
	foot.position = Vector2(0, 836)
	foot.size = Vector2(1600, 20)
	root.add_child(foot)
	var ver := UiKit.label("v3.2.1  -  Godot %s" % Engine.get_version_info().string, 12, UiKit.DIM, HORIZONTAL_ALIGNMENT_RIGHT)
	ver.position = Vector2(1220, 872)
	ver.size = Vector2(364, 20)
	root.add_child(ver)


func _fill_buttons() -> void:
	for c in _buttons.get_children():
		_buttons.remove_child(c)
		c.queue_free()
	var first: Button = null
	if SaveManager.has_run():
		var peek := SaveManager.peek_run()
		var label := "Continue"
		if not peek.is_empty() and Maps.MAPS.has(str(peek.get("map_id", ""))):
			var wave_n := int(peek.get("wave", 0))
			var diff := Difficulty.resolve(str(peek.get("difficulty", "medium")))
			var tag := ""
			if diff != "":
				tag = " (%s%s)" % [Difficulty.DIFFICULTIES[diff].name, ", endless" if bool(peek.get("endless", false)) else ""]
			label = "Continue  -  %s, round %d%s" % [Maps.MAPS[str(peek.map_id)].name, wave_n + 1, tag]
		first = UiKit.button(label, _on_continue, Vector2(0, 46), true)
		_buttons.add_child(first)
	var new_btn := UiKit.button("New Game", _on_new_game, Vector2(0, 46), true)
	_buttons.add_child(new_btn)
	var avail: int = SaveManager.research_available()
	var lab := UiKit.button("Research Lab" + ("  -  %d RP ready" % avail if avail > 0 else ""), func(): app.show_research(), Vector2(0, 46), true)
	if avail > 0:
		lab.add_theme_color_override("font_color", UiKit.GOLD)
	_buttons.add_child(lab)
	_buttons.add_child(UiKit.button("Settings", _on_settings, Vector2(0, 46), true))
	_buttons.add_child(UiKit.button("Quit", func(): get_tree().quit(), Vector2(0, 46), true))
	(first if first != null else new_btn).grab_focus.call_deferred()


func _show_modal(c: Control) -> void:
	_close_modal()
	_modal = c
	_modal_layer.add_child(c)


func _close_modal() -> void:
	if _modal != null:
		_modal.queue_free()
		_modal = null


func _on_continue() -> void:
	var res := SaveManager.load_run()
	if res.has("game"):
		app.start_game_with(res.game)
		return
	var msg := str(res.get("error", "The save could not be loaded."))
	_show_modal(ConfirmDialog.new(
		"%s\n\nDelete the broken save?" % msg,
		func():
			SaveManager.delete_run()
			_close_modal()
			_fill_buttons(),
		func():
			_close_modal()
			_fill_buttons(),
		"Delete save", "Keep it"))


func _on_new_game() -> void:
	if SaveManager.has_run():
		_show_modal(ConfirmDialog.new(
			"Starting a new game will replace your saved run when you next save.\nContinue to map select?",
			func(): app.show_map_select(),
			func(): _close_modal(),
			"New Game", "Cancel"))
	else:
		app.show_map_select()


func _on_settings() -> void:
	_show_modal(SettingsPanel.new(func():
		_close_modal()
		_fill_buttons()
	))
