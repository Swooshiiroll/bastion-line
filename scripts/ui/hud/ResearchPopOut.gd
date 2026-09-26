extends "res://scripts/ui/PopOut.gd"
## The Research Lab in battle. The game pauses while it is open; research bought here applies from
## the next run, so the current run (and its saved replay) stays exactly as it started.

const ResearchPanel = preload("res://scripts/ui/ResearchPanel.gd")

var hud
var screen
var panel


func _init(owner_hud) -> void:
	super(Rect2(24, 148, 1552, 604), "RESEARCH LAB", Vector2(0, 24))
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
	var n: int = screen.game.research.size()
	panel = ResearchPanel.new("Research you buy now applies from your next run. This run started with %d researched node%s." % [n, "" if n == 1 else "s"])
	panel.position = Vector2(0, 6)
	body.add_child(panel)
	panel.bought.connect(func(_id): hud.toast("Researched. It applies from your next run.", UiKit.GOOD))


func has_modal() -> bool:
	return panel != null and panel.has_modal()
