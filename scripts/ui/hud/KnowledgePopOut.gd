extends "res://scripts/ui/PopOut.gd"
## The Codex in battle. The game pauses while it is open, like the Research Lab.

const KnowledgePanel = preload("res://scripts/ui/KnowledgePanel.gd")

var hud
var screen
var panel
## The entry to open on (the selected tower or hovered enemy), or "" for the last one viewed.
var start_entry := ""
static var _last := ""


func _init(owner_hud, entry := "") -> void:
	super(Rect2(24, 148, 1552, 604), "CODEX", Vector2(0, 24))
	hud = owner_hud
	screen = owner_hud.screen
	start_entry = entry


func _build() -> void:
	var chip := PanelContainer.new()
	var sb := UiKit.box(Color(0.14, 0.12, 0.05), UiKit.GOLD, 5, 1, 8.0)
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	chip.add_theme_stylebox_override("panel", sb)
	chip.add_child(UiKit.label("GAME PAUSED", 12, UiKit.GOLD))
	header.add_child(chip)
	panel = KnowledgePanel.new(Vector2(1520, 540))
	panel.position = Vector2(16, 8)
	body.add_child(panel)
	var want := start_entry if start_entry != "" else _last
	if want != "":
		panel.open_entry.call_deferred(want)


func _exit_tree() -> void:
	if panel != null and panel.current != "":
		_last = panel.current
