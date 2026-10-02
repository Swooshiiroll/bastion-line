extends "res://scripts/ui/PopOut.gd"
## The Research Lab in battle. The game pauses while it is open; research bought or reset here
## applies to the running game at once (Game.apply_research).

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
	panel = ResearchPanel.new("Research you buy or reset here applies to this run at once.")
	panel.position = Vector2(0, 6)
	body.add_child(panel)
	panel.bought.connect(func(_id):
		screen.game.apply_research(SaveManager.research_owned())
		hud.toast("Researched. It applies now.", UiKit.GOOD))
	panel.reset_done.connect(func():
		screen.game.apply_research(SaveManager.research_owned())
		hud.toast("Research reset. Its boosts are gone from this run.", UiKit.GOLD))


func has_modal() -> bool:
	return panel != null and panel.has_modal()
