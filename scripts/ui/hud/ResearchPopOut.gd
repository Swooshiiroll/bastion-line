extends "res://scripts/ui/PopOut.gd"
## The Research Lab in battle. The game pauses while it is open; research bought or reset here
## applies to the running game at once (Game.apply_research). In Sandbox it's the same real Lab (#87): it spends and
## saves real research, and switches the run's research to Mine so the purchase applies.

const ResearchPanel = preload("res://scripts/ui/ResearchPanel.gd")

var hud
var screen
var panel


func _init(owner_hud) -> void:
	# 52 px of header above the panel; taller tiles grow the pop-out upward, bottom edge fixed.
	var h := ResearchPanel.panel_height() + 52.0
	super(Rect2(24, 752 - h, 1552, h), "RESEARCH LAB", Vector2(0, 24))
	hud = owner_hud
	screen = owner_hud.screen


func _build() -> void:
	var chip := PanelContainer.new()
	var sb := UiKit.box(Color(0.14, 0.12, 0.05), UiKit.GOLD, 5, 1, 8.0)
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	chip.add_theme_stylebox_override("panel", sb)
	chip.add_child(UiKit.label("GAME PAUSED", 12, UiKit.GOLD))
	header.add_child(chip)
	var note := "Research you buy or reset here applies to this run at once."
	if screen.game.sandbox:
		note = "Sandbox: this is your real research. Buying or resetting spends and saves your RP, and the run switches to Mine."
	panel = ResearchPanel.new(note)
	panel.position = Vector2(0, 6)
	body.add_child(panel)
	panel.bought.connect(func(_id):
		_apply()
		hud.toast("Researched. It applies now%s." % (" (the run now uses your research)" if screen.game.sandbox else ""), UiKit.GOOD))
	panel.reset_done.connect(func():
		_apply()
		hud.toast("Research reset. Its boosts are gone from this run.", UiKit.GOLD))


## Applies the profile's research to the run; in Sandbox that means switching the run to Mine.
func _apply() -> void:
	if screen.game.sandbox:
		screen.sandbox_research_mode = "mine"
		screen.game.sandbox_set_research("mine", SaveManager.research_owned())
	else:
		screen.game.apply_research(SaveManager.research_owned())


func has_modal() -> bool:
	return panel != null and panel.has_modal()
