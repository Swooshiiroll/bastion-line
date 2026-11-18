extends "res://scripts/ui/PopOut.gd"
## Sandbox wave builder pop-out (#118, design/sandbox.md "Wave builder"): opens beside the Spawner (its button or V) and
## closes with it. A scrolling list of groups (up to 30): ↑ ↓ to reorder, the enemy's still icon, name and tier, steppers for
## the count, the gap between its enemies and the delay before the next group (Shift steps 5×), its modifiers as chips (click
## one to drop it), copy and remove. While it's open, a Spawner card adds a group instead of spawning. At the foot: the
## wave's total and length (or, while it spawns, which group and how many to come), Send wave, Loop, Stop wave and Clear.
## Rows are rebuilt only when groups are added, removed or moved; a stepper only rewrites its own number (#116's rule).

const DrawControl = preload("res://scripts/ui/DrawControl.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const Enemies = preload("res://data/enemies.gd")
const Modifiers = preload("res://data/modifiers.gd")
const WaveBuilder = preload("res://scripts/core/WaveBuilder.gd")

const ROW_H := 96.0
const FOOT_H := 96.0
const ELITE_COLOR := Color(1.0, 0.82, 0.30)

var hud
var screen
var _list: Control
var _scroll: ScrollContainer
var _summary: Label
var _loop_btn: Button
## Each row's value labels, by field: [{"n": Label, "gap": Label, "delay": Label}].
var _values: Array = []
## What the rows were built from (types and mods per group), and the foot when last written.
var _shape := ""
var _foot := ""


func _init(owner_hud) -> void:
	super(Rect2(318, 44, 340, 748), "WAVE BUILDER", Vector2(-680, 0))
	hud = owner_hud
	screen = owner_hud.screen


func _build() -> void:
	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(0, 4)
	_scroll.size = Vector2(rect.size.x, body.size.y - FOOT_H - 8)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(_scroll)
	_list = Control.new()
	_scroll.add_child(_list)
	var sep := ColorRect.new()
	sep.color = UiKit.BORDER
	sep.position = Vector2(12, body.size.y - FOOT_H)
	sep.size = Vector2(rect.size.x - 24, 1)
	body.add_child(sep)
	_summary = UiKit.label("", 12, UiKit.GOLD)
	_summary.position = Vector2(14, body.size.y - FOOT_H + 8)
	_summary.size = Vector2(rect.size.x - 28, 16)
	body.add_child(_summary)
	var row1 := UiKit.hbox(6)
	row1.position = Vector2(10, body.size.y - FOOT_H + 30)
	body.add_child(row1)
	var send := _fit(UiKit.button("Send wave", Callable(screen, "builder_send"), Vector2(150, 30)))
	send.tooltip_text = "Send the wave now, at round-1 strength. It stacks with whatever is on the field."
	row1.add_child(send)
	_loop_btn = _fit(UiKit.button("Loop", Callable(screen, "builder_loop"), Vector2(150, 30)))
	_loop_btn.tooltip_text = "Send the wave again each time its enemies are all gone (keeps going with the panels closed)."
	row1.add_child(_loop_btn)
	var row2 := UiKit.hbox(6)
	row2.position = Vector2(10, body.size.y - FOOT_H + 64)
	body.add_child(row2)
	var stop := _fit(UiKit.button("Stop wave", Callable(screen, "builder_stop"), Vector2(150, 26)), 12)
	stop.tooltip_text = "Cancel the built waves' enemies still to come and turn Loop off. Enemies already out stay."
	row2.add_child(stop)
	var clear := _fit(UiKit.button("Clear", Callable(screen, "builder_clear"), Vector2(150, 26)), 12)
	clear.tooltip_text = "Empty the list."
	row2.add_child(clear)
	refresh(0.0)


func refresh(_delta: float) -> void:
	var groups: Array = screen.wave_groups
	var shape := str(groups.map(func(g): return [g.t, g.mods]))
	if shape != _shape:
		_shape = shape
		_rebuild(groups)
	for i in mini(_values.size(), groups.size()):
		var g: Dictionary = groups[i]
		var v: Dictionary = _values[i]
		_set_text(v.n, "x%d" % int(g.n))
		_set_text(v.gap, "%.1fs" % float(g.gap))
		_set_text(v.delay, "%.1fs" % float(g.delay))
	var foot := "%s|%s|%s" % [summary_text(screen.game, groups), screen.game.built_loop, groups.size()]
	if foot != _foot:
		_foot = foot
		_summary.text = summary_text(screen.game, groups)
		_style_toggle(_loop_btn, screen.game.built_loop)


## The foot's line: the wave's size and length, or how the last copy is getting on while it spawns.
static func summary_text(g, groups: Array) -> String:
	if groups.is_empty():
		return "Click a Spawner card to add a group."
	var pr: Dictionary = g.built_progress()
	if int(pr.to_come) > 0:
		return "Group %d of %d, %d to come" % [int(pr.group) + 1, groups.size(), int(pr.to_come)]
	return "%d group%s · %d enemies · %.1f s" % [groups.size(), "" if groups.size() == 1 else "s", WaveBuilder.total(groups), WaveBuilder.duration(groups)]


func _rebuild(groups: Array) -> void:
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()
	_values.clear()
	for i in groups.size():
		_list.add_child(_row(i, groups[i]))
	_list.custom_minimum_size = Vector2(rect.size.x - 12, groups.size() * ROW_H + 4.0)


func _row(i: int, g: Dictionary) -> Control:
	var d: Dictionary = Enemies.ENEMIES[g.t]
	var row := Control.new()
	row.position = Vector2(0, 4.0 + i * ROW_H)
	row.size = Vector2(rect.size.x - 12, ROW_H - 4)
	var bg := Panel.new()
	bg.add_theme_stylebox_override("panel", UiKit.box(Color(0.06, 0.09, 0.13), UiKit.BORDER, 6, 1, 0.0))
	bg.size = Vector2(rect.size.x - 20, ROW_H - 6)
	bg.position = Vector2(4, 0)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(bg)
	var up := _small("↑", Callable(screen, "builder_move").bind(i, -1), Vector2(8, 4))
	up.tooltip_text = "Move up"
	row.add_child(up)
	var down := _small("↓", Callable(screen, "builder_move").bind(i, 1), Vector2(8, 32))
	down.tooltip_text = "Move down"
	row.add_child(down)
	var r := float(d.radius)
	var icon := DrawControl.new(func(ci): Draw.enemy(ci, g.t, ci.size / 2.0, Vector2.RIGHT, r, 0.0, false, 0.0, clampf(13.0 / r, 0.35, 1.1)), Vector2(28, 22), false)
	icon.position = Vector2(32, 1)
	row.add_child(icon)
	var name_l := UiKit.label("%s  T%d" % [d.name, int(d.get("tier", 0))] if int(d.get("tier", 0)) > 0 else str(d.name), 13)
	name_l.position = Vector2(64, 4)
	name_l.size = Vector2(170, 18)
	name_l.clip_text = true
	row.add_child(name_l)
	var copy := _small("⧉", Callable(screen, "builder_copy").bind(i), Vector2(rect.size.x - 76, 4))
	copy.tooltip_text = "Copy this group"
	row.add_child(copy)
	var del := _small("×", Callable(screen, "builder_remove").bind(i), Vector2(rect.size.x - 48, 4))
	del.tooltip_text = "Remove this group"
	row.add_child(del)
	var v := {}
	var x := 32.0
	for f in [["n", "", "How many"], ["gap", "gap", "Seconds between its enemies"], ["delay", "then", "Seconds after its last enemy before the next group"]]:
		if f[1] != "":
			var tag := UiKit.label(f[1], 10, UiKit.DIM)
			tag.position = Vector2(x, 35)
			row.add_child(tag)
			x += 22.0 if f[1] == "gap" else 26.0
		var minus := _small("−", Callable(screen, "builder_step").bind(i, f[0], -1), Vector2(x, 32))
		minus.tooltip_text = f[2] + "  (Shift: 5 steps)"
		row.add_child(minus)
		var val := UiKit.label("", 12, UiKit.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
		val.position = Vector2(x + 22, 34)
		val.size = Vector2(34, 16)
		row.add_child(val)
		v[f[0]] = val
		var plus := _small("+", Callable(screen, "builder_step").bind(i, f[0], 1), Vector2(x + 56, 32))
		plus.tooltip_text = minus.tooltip_text
		row.add_child(plus)
		x += 80.0
	_values.append(v)
	var cx := 32.0
	for m in g.mods:
		var text := "%s ×" % Modifiers.MODIFIERS[m].name
		var cw := UiKit.font().get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x + 12.0
		var chip := UiKit.button(text, Callable(screen, "builder_remove_mod").bind(i, m), Vector2(cw, 18))
		chip.add_theme_font_size_override("font_size", 11)
		for st in ["normal", "hover", "pressed"]:
			chip.add_theme_stylebox_override(st, UiKit.box(Color(0.12, 0.11, 0.06), ELITE_COLOR if st != "normal" else Color(ELITE_COLOR, 0.6), 4, 1, 0.0))
		chip.size = Vector2(cw, 18)
		chip.position = Vector2(cx, 63)
		chip.add_theme_color_override("font_color", ELITE_COLOR)
		chip.tooltip_text = "Drop %s from this group" % Modifiers.MODIFIERS[m].name
		row.add_child(chip)
		cx += chip.size.x + 4.0
	return row


## A small square button (arrows, steppers, copy, remove): no inner margin, or its symbol is clipped away.
func _small(text: String, cb: Callable, at: Vector2) -> Button:
	var b := UiKit.button(text, cb, Vector2(22, 20))
	b.add_theme_font_size_override("font_size", 13)
	for st in [["normal", UiKit.BORDER, 0.10], ["hover", UiKit.ACCENT, 0.16], ["pressed", UiKit.ACCENT, 0.22]]:
		b.add_theme_stylebox_override(st[0], UiKit.box(Color(0.06, 0.1, 0.15).lightened(st[2] - 0.1), st[1], 4, 1, 0.0))
	b.size = Vector2(22, 20)
	b.position = at
	return b


static func _set_text(l: Label, text: String) -> void:
	if l.text != text:
		l.text = text


## Keeps a button at its given size whatever its text (as the Spawner's).
func _fit(b: Button, font := 13) -> Button:
	b.add_theme_font_size_override("font_size", font)
	b.clip_text = true
	b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	b.size = b.custom_minimum_size
	return b


func _style_toggle(b: Button, on: bool) -> void:
	if on:
		var sel := UiKit.box(Color(0.12, 0.11, 0.06), UiKit.GOLD, 6, 2, 8.0)
		for s in ["normal", "hover", "pressed"]:
			b.add_theme_stylebox_override(s, sel)
		b.add_theme_color_override("font_color", UiKit.GOLD)
	else:
		for s in ["normal", "hover", "pressed"]:
			b.remove_theme_stylebox_override(s)
		b.remove_theme_color_override("font_color")
