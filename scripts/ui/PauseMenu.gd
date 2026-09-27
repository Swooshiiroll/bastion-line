extends Control
## Pause overlay: resume, restart, save, settings, controls reference, quit.

const UiKit = preload("res://scripts/ui/UiKit.gd")

var screen
var _status: Label


func _init(scr) -> void:
	screen = scr


func _ready() -> void:
	position = Vector2.ZERO
	size = UiKit.SCREEN
	theme = UiKit.theme()
	add_child(UiKit.dimmer(0.55))
	var p := UiKit.centered_panel(420.0)
	add_child(p)
	var v := UiKit.vbox(10)
	p.add_child(v)
	v.add_child(UiKit.label("PAUSED", 34, UiKit.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var g = screen.game
	v.add_child(UiKit.label("%s  -  round %d  -  core %d  -  %d cr" % [g.map_def.name, g.wave, g.lives, g.gold], 13, UiKit.DIM, HORIZONTAL_ALIGNMENT_CENTER))
	var resume := UiKit.button("Resume  [Esc]", Callable(screen, "resume"), Vector2(0, 42), true)
	v.add_child(resume)
	v.add_child(UiKit.button("Restart Sector", Callable(screen, "confirm_restart"), Vector2(0, 42), true))
	var save := UiKit.button("Save Game", _on_save, Vector2(0, 42), true)
	save.disabled = not g.can_save()
	v.add_child(save)
	_status = UiKit.label("" if g.can_save() else "Saving is available between rounds.", 12, UiKit.DIM, HORIZONTAL_ALIGNMENT_CENTER)
	v.add_child(_status)
	v.add_child(UiKit.button("Settings", Callable(screen, "open_settings"), Vector2(0, 42), true))
	v.add_child(UiKit.button("Quit to Main Menu", Callable(screen, "quit_to_menu"), Vector2(0, 42), true))
	var help := UiKit.wrap_label("B shop  -  1-9, 0, -, =, [, ], \\ build  -  U / I / O upgrade  -  E upgrade tree\nX sell  -  T targeting  -  G air/ground priority  -  R research  -  N intel\nSpace launch / call round  -  Q orbital  -  W chrono  -  F speed  -  A auto\nWheel zoom  -  middle-drag / arrows pan  -  Home reset view  -  F3 FPS\nEsc closes every open menu", 380, 12, UiKit.DIM)
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(help)
	resume.grab_focus.call_deferred()


func _on_save() -> void:
	if screen.save_now():
		_status.text = "Saved."
		_status.add_theme_color_override("font_color", UiKit.GOOD)
