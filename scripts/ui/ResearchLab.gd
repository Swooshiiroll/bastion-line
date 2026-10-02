extends Node
## Research Lab screen (from the main menu): starfield, title, the shared ResearchPanel, Back.
## The same panel also opens in battle as a pop-out (see Hud.gd).

const UiKit = preload("res://scripts/ui/UiKit.gd")
const ResearchPanel = preload("res://scripts/ui/ResearchPanel.gd")
const Data = preload("res://data/research.gd")
const Difficulty = preload("res://data/difficulty.gd")

var app
var panel


func _ready() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := UiKit.root()
	layer.add_child(root)
	root.add_child(UiKit.starfield())
	var title := UiKit.label("RESEARCH LAB", 40, UiKit.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_constant_override("outline_size", 10)
	title.position = Vector2(0, 70)
	title.size = Vector2(1600, 56)
	root.add_child(title)
	var sub := UiKit.label("Permanent upgrades for every run you start. A tower's Mastery research, after the rest of its tree, unlocks its three masteries. Left / Right or the wheel browse the trees.", 14, UiKit.DIM, HORIZONTAL_ALIGNMENT_CENTER)
	sub.position = Vector2(0, 124)
	sub.size = Vector2(1600, 20)
	root.add_child(sub)
	panel = ResearchPanel.new()
	panel.position = Vector2(24, 162)
	root.add_child(panel)
	var back := UiKit.button("Back  [Esc]", func(): app.show_menu(), Vector2(150, 42))
	# Below the panel, which grows with the research tile size.
	var below := maxf(740.0, 174.0 + ResearchPanel.panel_height())
	back.position = Vector2(24, below)
	root.add_child(back)
	var medal_rp := PackedStringArray(Difficulty.ORDER.map(func(m): return "%s %d" % [Difficulty.DIFFICULTIES[m].name, int(Difficulty.DIFFICULTIES[m].medal_rp)]))
	var text := "Earn RP per sector: medals (%s),  1 each for reaching rounds %s,  1 per %d endless rounds (max %d)" % [
		", ".join(medal_rp), ", ".join(PackedStringArray(Data.RP_ROUND_MILESTONES.map(func(w): return str(w)))),
		Data.RP_ENDLESS_STEP, Data.RP_ENDLESS_MAX_PER_SECTOR]
	if SaveManager.legacy_rp() > 0:
		text += ".  +%d legacy RP from your old records" % SaveManager.legacy_rp()
	var rules := UiKit.label(text, 12, UiKit.DIM)
	rules.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rules.position = Vector2(200, below + 4.0)
	rules.size = Vector2(1376, 40)
	root.add_child(rules)


func _unhandled_input(event: InputEvent) -> void:
	if panel.has_modal() or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		app.show_menu()
		get_viewport().set_input_as_handled()
