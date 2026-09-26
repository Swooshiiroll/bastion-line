extends Control
## Settings overlay (volume, damage numbers, fullscreen, window size). Values persist in the profile.

const UiKit = preload("res://scripts/ui/UiKit.gd")

var on_close: Callable


func _init(close_cb: Callable) -> void:
	on_close = close_cb


func _ready() -> void:
	position = Vector2.ZERO
	size = UiKit.SCREEN
	theme = UiKit.theme()
	add_child(UiKit.dimmer(0.55))
	var p := UiKit.centered_panel(420.0)
	add_child(p)
	var v := UiKit.vbox(12)
	p.add_child(v)
	v.add_child(UiKit.label("SETTINGS", 30, UiKit.GOLD, HORIZONTAL_ALIGNMENT_CENTER))

	v.add_child(_volume_row("Effects", "sfx_volume", true))
	v.add_child(_volume_row("Music", "music_volume", false))

	var dmg := CheckBox.new()
	dmg.text = "Show damage numbers"
	dmg.button_pressed = bool(SaveManager.setting("damage_numbers"))
	dmg.toggled.connect(func(on: bool): SaveManager.set_setting("damage_numbers", on))
	v.add_child(dmg)

	var full := CheckBox.new()
	full.text = "Fullscreen"
	full.button_pressed = bool(SaveManager.setting("fullscreen"))
	v.add_child(full)

	var size_row := UiKit.hbox(12)
	var size_l := UiKit.label("Window", 16)
	size_l.custom_minimum_size = Vector2(80, 0)
	size_row.add_child(size_l)
	var sizes := OptionButton.new()
	sizes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for key in SaveManager.WINDOW_SIZES:
		sizes.add_item("Auto (fit the screen)" if key == "auto" else str(key).replace("x", " × "))
	sizes.selected = maxi(0, SaveManager.WINDOW_SIZES.find(str(SaveManager.setting("window_size"))))
	sizes.disabled = full.button_pressed
	sizes.item_selected.connect(func(i: int): SaveManager.set_setting("window_size", SaveManager.WINDOW_SIZES[i]))
	size_row.add_child(sizes)
	v.add_child(size_row)
	full.toggled.connect(func(on: bool):
		SaveManager.set_setting("fullscreen", on)
		sizes.disabled = on)
	var hint := UiKit.label("The game fills any window shape. You can also drag the window edges to any size.", 12, UiKit.DIM)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size = Vector2(380, 0)
	v.add_child(hint)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	v.add_child(spacer)
	var close := UiKit.button("Back", func(): on_close.call(), Vector2(0, 42), true)
	v.add_child(close)
	close.grab_focus.call_deferred()


func _volume_row(title: String, key: String, ping: bool) -> HBoxContainer:
	var row := UiKit.hbox(12)
	var l := UiKit.label(title, 16)
	l.custom_minimum_size = Vector2(80, 0)
	row.add_child(l)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = float(SaveManager.setting(key))
	slider.custom_minimum_size = Vector2(190, 28)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var pct := UiKit.label("%d%%" % roundi(slider.value * 100.0), 14, UiKit.DIM)
	pct.custom_minimum_size = Vector2(44, 0)
	slider.value_changed.connect(func(val: float):
		SaveManager.set_setting(key, val)
		pct.text = "%d%%" % roundi(val * 100.0)
	)
	if ping:
		slider.drag_ended.connect(func(_changed: bool): Sfx.play("coin", -6.0, 0.0))
	row.add_child(slider)
	row.add_child(pct)
	return row


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		on_close.call()
