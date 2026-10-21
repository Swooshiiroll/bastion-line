extends "res://scripts/ui/PopOut.gd"
## Sandbox Spawner pop-out (design/sandbox.md; role × tier picker and modifiers, enemy rework phase 6, issue #68): slides in
## from the left edge and never pauses the battle. From the top: the research switch (All / Mine / None), the spawn
## count and Clear field, the enemies in a role × tier grid (Specials and bosses in their own rows), the elite modifier
## toggles, and Call round N. Clicking an enemy sends that many at round-1 strength, as elites carrying the toggled
## modifiers it can take.

const DrawControl = preload("res://scripts/ui/DrawControl.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const Enemies = preload("res://data/enemies.gd")
const Modifiers = preload("res://data/modifiers.gd")

const CARD := Vector2(62, 44)
const ROLE_W := 28.0
const COUNTS := [1, 5, 10, 25]
const RESEARCH := [["all", "All"], ["mine", "Mine"], ["none", "None"]]
## Grid rows: tiered roles first, then the Specials and the bosses.
const ROLES := [["swarm", "SWM"], ["rusher", "RSH"], ["tank", "TNK"], ["support", "SUP"], ["disruptor", "DIS"], ["evader", "EVA"], ["special", "SPC"], ["boss", "BOS"]]
const ELITE_COLOR := Color(1.0, 0.82, 0.30)

var hud
var screen
var _research_btns := {}
var _count_btns := {}
var _mod_btns := {}
var _round_label: Label


func _init(owner_hud) -> void:
	super(Rect2(8, 44, 302, 748), "SPAWNER", Vector2(-320, 0))
	hud = owner_hud
	screen = owner_hud.screen


func _build() -> void:
	var y := 6.0
	y = _row_label("Research (this run only)", y)
	var rrow := UiKit.hbox(6)
	rrow.position = Vector2(10, y)
	body.add_child(rrow)
	for r in RESEARCH:
		var b := UiKit.button(r[1], Callable(screen, "sandbox_research").bind(r[0]), Vector2(90, 28))
		rrow.add_child(b)
		_research_btns[r[0]] = b
	y += 34.0
	y = _row_label("Spawn count", y)
	var crow := UiKit.hbox(6)
	crow.position = Vector2(10, y)
	body.add_child(crow)
	for c in COUNTS:
		var b := UiKit.button("x%d" % c, Callable(screen, "set_spawn_count").bind(c), Vector2(46, 28))
		crow.add_child(b)
		_count_btns[c] = b
	var clear := UiKit.button("Clear field", Callable(screen, "sandbox_clear"), Vector2(84, 28))
	clear.tooltip_text = "Remove every enemy and pending spawn. No credits, no leaks."
	crow.add_child(clear)
	y += 34.0
	y = _enemy_grid(y)
	y = _row_label("Elite modifiers (cards spawn with the ones it can take)", y)
	var mw := (rect.size.x - 20.0 - 8.0) / 3.0
	for i in Modifiers.ORDER.size():
		var m: String = Modifiers.ORDER[i]
		var md: Dictionary = Modifiers.MODIFIERS[m]
		var b := UiKit.button(str(md.name), Callable(screen, "toggle_spawn_mod").bind(m), Vector2(mw, 26))
		b.position = Vector2(10 + (i % 3) * (mw + 4), y + (i / 3) * 30)
		b.tooltip_text = "%s (from round %d)\n%s" % [md.name, int(md.intro), md.blurb]
		body.add_child(b)
		_mod_btns[m] = b
	y += ceili(Modifiers.ORDER.size() / 3.0) * 30.0 + 4.0
	y = _row_label("Call a round (its real wave and strength)", y)
	var row := UiKit.hbox(6)
	row.position = Vector2(10, y)
	body.add_child(row)
	row.add_child(UiKit.button("-", Callable(screen, "step_call_round").bind(-1), Vector2(34, 30)))
	_round_label = UiKit.label("", 18, UiKit.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_round_label.custom_minimum_size = Vector2(56, 30)
	_round_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_round_label)
	row.add_child(UiKit.button("+", Callable(screen, "step_call_round").bind(1), Vector2(34, 30)))
	row.add_child(UiKit.button("+10", Callable(screen, "step_call_round").bind(10), Vector2(44, 30)))
	var call := UiKit.button("Call", Callable(screen, "sandbox_call"), Vector2(72, 30))
	call.tooltip_text = "Send this round's wave now. The round counter doesn't move."
	row.add_child(call)


func _row_label(text: String, y: float) -> float:
	var l := UiKit.label(text, 11, UiKit.DIM)
	l.position = Vector2(12, y)
	body.add_child(l)
	return y + 16.0


## The enemies by role (rows) and tier (columns T1-T4); Specials and bosses fill their rows in order. Returns the y below it.
func _enemy_grid(y: float) -> float:
	for t in 4:
		var h := UiKit.label("T%d" % (t + 1), 11, UiKit.DIM, HORIZONTAL_ALIGNMENT_CENTER)
		h.position = Vector2(10 + ROLE_W + t * (CARD.x + 4), y)
		h.size = Vector2(CARD.x, 14)
		body.add_child(h)
	y += 16.0
	for role in ROLES:
		var members: Array = Enemies.ORDER.filter(func(t): return str(Enemies.ENEMIES[t].get("role", "")) == role[0])
		var tiered := members.all(func(t): return int(Enemies.ENEMIES[t].get("tier", 0)) >= 1)
		var rows := 1 if tiered else ceili(members.size() / 4.0)
		var tag := UiKit.label(role[1], 10, UiKit.ACCENT)
		tag.position = Vector2(10, y + CARD.y / 2.0 - 7.0)
		tag.tooltip_text = str(role[0]).capitalize()
		tag.mouse_filter = Control.MOUSE_FILTER_PASS
		body.add_child(tag)
		for i in members.size():
			var type: String = members[i]
			var col := int(Enemies.ENEMIES[type].tier) - 1 if tiered else i % 4
			var b := _card(type, Enemies.ENEMIES[type])
			b.position = Vector2(10 + ROLE_W + col * (CARD.x + 4), y + (0 if tiered else (i / 4)) * (CARD.y + 2))
			body.add_child(b)
		y += rows * (CARD.y + 2)
	return y + 4.0


func _card(type: String, d: Dictionary) -> Button:
	var b := UiKit.button("", Callable(screen, "sandbox_spawn").bind(type), CARD)
	b.size = CARD
	b.tooltip_text = "%s  (%s)\n%s" % [d.name, Enemies.role_label(d), d.blurb]
	var r := float(d.radius)
	var icon := DrawControl.new(func(ci): Draw.enemy(ci, type, ci.size / 2.0, Vector2.RIGHT, r, Time.get_ticks_msec() / 1000.0, false, 0.0, clampf(13.0 / r, 0.35, 1.1)), Vector2(CARD.x, 30), true)
	icon.position = Vector2(0, 1)
	b.add_child(icon)
	var name_l := UiKit.label(str(d.name), 9, UiKit.DIM, HORIZONTAL_ALIGNMENT_CENTER)
	name_l.position = Vector2(0, 30)
	name_l.size = Vector2(CARD.x, 12)
	name_l.clip_text = true
	b.add_child(name_l)
	return b


func refresh(_delta: float) -> void:
	for mode in _research_btns:
		_style_toggle(_research_btns[mode], screen.sandbox_research_mode == mode)
	for c in _count_btns:
		_style_toggle(_count_btns[c], screen.spawn_count == c)
	for m in _mod_btns:
		_style_toggle(_mod_btns[m], screen.spawn_mods.has(m), ELITE_COLOR)
	_round_label.text = str(screen.call_round)


func _style_toggle(b: Button, on: bool, col := UiKit.GOLD) -> void:
	if on:
		var sel := UiKit.box(Color(0.12, 0.11, 0.06), col, 6, 2, 8.0)
		for s in ["normal", "hover", "pressed"]:
			b.add_theme_stylebox_override(s, sel)
		b.add_theme_color_override("font_color", col)
	else:
		for s in ["normal", "hover", "pressed"]:
			b.remove_theme_stylebox_override(s)
		b.remove_theme_color_override("font_color")
