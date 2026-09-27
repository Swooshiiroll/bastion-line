extends Node
## App root. Owns the current screen and routes between menu, map select and gameplay.
## Command-line user args (after `--`):
##   --run-tests         run the headless test suite and quit
##   --screenshot-tour   capture a scripted tour of every screen into res://screenshots/ and quit
##   --sprite-sheet      render every tower and enemy sprite to res://screenshots/sprite_sheet.png
##   --codex=<dir>       export data and sprites for the printable codex (tools/codex.mjs)

const MainMenu = preload("res://scripts/ui/MainMenu.gd")
const MapSelect = preload("res://scripts/ui/MapSelect.gd")
const GameScreen = preload("res://scripts/ui/GameScreen.gd")
const ResearchLab = preload("res://scripts/ui/ResearchLab.gd")
const ScreenshotTour = preload("res://tools/ScreenshotTour.gd")
const UiKit = preload("res://scripts/ui/UiKit.gd")

var current: Node = null


func _ready() -> void:
	ThemeDB.fallback_font = UiKit.font()
	# Screens are laid out at 1600×900 and centred in whatever shape the window is.
	get_viewport().size_changed.connect(_fit_view)
	get_tree().node_added.connect(_on_node_added)
	_fit_view()
	var args := OS.get_cmdline_user_args()
	if "--run-tests" in args:
		get_tree().change_scene_to_file.call_deferred("res://tests/TestRunner.tscn")
		return
	if Array(args).any(func(a): return str(a).begins_with("--codex=")):
		add_child(load("res://tools/Codex.gd").new())
		return
	if "--sprite-sheet" in args:
		add_child(load("res://tools/SpriteSheet.gd").new())
		return
	if "--screenshot-tour" in args:
		var tour = ScreenshotTour.new()
		tour.app = self
		add_child(tour)
		return
	SaveManager.apply_window()
	show_menu()


## Centres the 1600×900 layout in the window: shifts the world canvas and every CanvasLayer.
func _fit_view() -> void:
	var off := UiKit.view_offset()
	get_viewport().canvas_transform = Transform2D(0.0, off)
	for layer in get_tree().root.find_children("*", "CanvasLayer", true, false):
		layer.offset = off


func _on_node_added(node: Node) -> void:
	if node is CanvasLayer:
		node.offset = UiKit.view_offset()


func _set_screen(node: Node) -> void:
	if current != null:
		current.queue_free()
	current = node
	add_child(node)


func show_menu() -> void:
	var m = MainMenu.new()
	m.app = self
	_set_screen(m)


func show_map_select() -> void:
	var m = MapSelect.new()
	m.app = self
	_set_screen(m)


func show_codex() -> void:
	var k = load("res://scripts/ui/KnowledgeBase.gd").new()
	k.app = self
	_set_screen(k)


func show_research() -> void:
	var r = ResearchLab.new()
	r.app = self
	_set_screen(r)


func start_game(map_id: String, difficulty := "") -> void:
	if difficulty == "":
		difficulty = str(SaveManager.setting("difficulty"))
	var g = GameScreen.new()
	g.app = self
	g.setup_new(map_id, difficulty)
	_set_screen(g)


func start_game_with(game) -> void:
	var g = GameScreen.new()
	g.app = self
	g.setup_with(game)
	_set_screen(g)
