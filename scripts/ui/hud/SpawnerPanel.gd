extends "res://scripts/ui/PopOut.gd"
## Sandbox Spawner pop-out (design/sandbox.md): slides in from the left edge and never pauses the
## battle. From the top: the research switch (All / Mine / None), the spawn count, a card per enemy
## (bosses last), Call round N, and Clear field. Clicking an enemy sends that many at round-1 strength.

const DrawControl = preload("res://scripts/ui/DrawControl.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const Enemies = preload("res://data/enemies.gd")

const CARD := Vector2(66, 56)
const COUNTS := [1, 5, 10, 25]
const RESEARCH := [["all", "All"], ["mine", "Mine"], ["none", "None"]]

var hud
var screen
var _research_btns := {}
var _count_btns := {}
var _round_label: Label


func _init(owner_hud) -> void:
	super(Rect2(8, 44, 302, 748), "SPAWNER", Vector2(-320, 0))
	hud = owner_hud
	screen = owner_hud.screen


func _build() -> void:
	var y := 8.0
	y = _row_label("Research (this run only)", y)
	var rrow := UiKit.hbox(6)
	rrow.position = Vector2(10, y)
	body.add_child(rrow)
	for r in RESEARCH:
		var b := UiKit.button(r[1], Callable(screen, "sandbox_research").bind(r[0]), Vector2(90, 30))
		rrow.add_child(b)
		_research_btns[r[0]] = b
	y += 40.0
	y = _row_label("Spawn count", y)
	var crow := UiKit.hbox(6)
	crow.position = Vector2(10, y)
	body.add_child(crow)
	for c in COUNTS:
		var b := UiKit.button("x%d" % c, Callable(screen, "set_spawn_count").bind(c), Vector2(64, 30))
		crow.add_child(b)
		_count_btns[c] = b
	y += 40.0
	y = _enemy_grid(false, "Enemies", y)
	y = _enemy_grid(true, "Bosses", y)
	y = _row_label("Call a round (its real wave and strength)", y)
	var row := UiKit.hbox(6)
	row.position = Vector2(10, y)
	body.add_child(row)
	row.add_child(UiKit.button("-", Callable(screen, "step_call_round").bind(-1), Vector2(34, 32)))
	_round_label = UiKit.label("", 18, UiKit.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_round_label.custom_minimum_size = Vector2(56, 32)
	_round_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_round_label)
	row.add_child(UiKit.button("+", Callable(screen, "step_call_round").bind(1), Vector2(34, 32)))
	row.add_child(UiKit.button("+10", Callable(screen, "step_call_round").bind(10), Vector2(44, 32)))
	var call := UiKit.button("Call", Callable(screen, "sandbox_call"), Vector2(72, 32))
	call.tooltip_text = "Send this round's wave now. The round counter doesn't move."
	row.add_child(call)
	y += 44.0
	var clear := UiKit.button("Clear field", Callable(screen, "sandbox_clear"), Vector2(rect.size.x - 20, 34))
	clear.position = Vector2(10, y)
	clear.tooltip_text = "Remove every enemy and pending spawn. No credits, no leaks."
	body.add_child(clear)
	y += 44.0
	var help := UiKit.wrap_label("Sandbox: credits and shields are infinite, upgrades are free, and nothing is saved or earned. Towers show their live DPS in their panel; branch cards have a Max button.", rect.size.x - 20, 11, UiKit.DIM)
	help.position = Vector2(10, y)
	body.add_child(help)


func _row_label(text: String, y: float) -> float:
	var l := UiKit.label(text, 11, UiKit.DIM)
	l.position = Vector2(12, y)
	body.add_child(l)
	return y + 18.0


## A titled grid of enemy cards (the bosses, or everything else). Returns the y below it.
func _enemy_grid(bosses: bool, title_text: String, y: float) -> float:
	y = _row_label(title_text, y)
	var i := 0
	for type in Enemies.ORDER:
		var d: Dictionary = Enemies.ENEMIES[type]
		if bool(d.get("boss", false)) != bosses:
			continue
		var b := _card(type, d)
		b.position = Vector2(10 + (i % 4) * (CARD.x + 6), y + (i / 4) * (CARD.y + 6))
		body.add_child(b)
		i += 1
	return y + ceili(i / 4.0) * (CARD.y + 6) + 6.0


func _card(type: String, d: Dictionary) -> Button:
	var b := UiKit.button("", Callable(screen, "sandbox_spawn").bind(type), CARD)
	b.size = CARD
	b.tooltip_text = "%s\n%s" % [d.name, d.blurb]
	var r := float(d.radius)
	var icon := DrawControl.new(func(ci): Draw.enemy(ci, type, ci.size / 2.0, Vector2.RIGHT, r, Time.get_ticks_msec() / 1000.0, false, 0.0, clampf(17.0 / r, 0.4, 1.3)), Vector2(CARD.x, 34), true)
	icon.position = Vector2(0, 2)
	b.add_child(icon)
	var name_l := UiKit.label(str(d.name), 9, UiKit.DIM, HORIZONTAL_ALIGNMENT_CENTER)
	name_l.position = Vector2(0, 38)
	name_l.size = Vector2(CARD.x, 14)
	name_l.clip_text = true
	b.add_child(name_l)
	return b


func refresh(_delta: float) -> void:
	for mode in _research_btns:
		_style_toggle(_research_btns[mode], screen.sandbox_research_mode == mode)
	for c in _count_btns:
		_style_toggle(_count_btns[c], screen.spawn_count == c)
	_round_label.text = str(screen.call_round)


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
