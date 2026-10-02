extends Control
## In-game top bar (1600×40): sector and mode, round, core shields, credits, the NEXT strip (click for the
## Intel pop-out) and the Launch / speed / auto / Shop / Research / Menu buttons.

const UiKit = preload("res://scripts/ui/UiKit.gd")
const DrawControl = preload("res://scripts/ui/DrawControl.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const Game = preload("res://scripts/core/Game.gd")
const Waves = preload("res://data/waves.gd")
const Enemies = preload("res://data/enemies.gd")
const Difficulty = preload("res://data/difficulty.gd")

const HEIGHT := 40.0

var hud
var screen
var wave_label: Label
var lives_label: Label
var gold_label: Label
var next_btn: Button
var next_box: HBoxContainer
var speed_btn: Button
var auto_btn: Button
var fps_label: Label

## Enemy types shown in the NEXT strip before it collapses the rest into "+N".
const NEXT_TYPES := 4

var shop_btn: Button
var research_btn: Button
var _next_key := ""
var _lit := {}
var _lit_style: StyleBoxFlat


var _bg: Control
var _line: ColorRect
var _row: HBoxContainer

func _ready() -> void:
	size = Vector2(UiKit.SCREEN.x, HEIGHT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_lit_style = UiKit.box(Color(0.12, 0.11, 0.06), UiKit.GOLD, 6, 2, 8.0)
	_bg = UiKit.panel(Rect2(Vector2.ZERO, size))
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)
	var line := ColorRect.new()
	_line = line
	line.color = Color(UiKit.ACCENT, 0.5)
	line.position = Vector2(0, HEIGHT - 1)
	line.size = Vector2(size.x, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line)

	_row = UiKit.hbox(10)
	var row := _row
	row.position = Vector2(10, 4)
	row.size = Vector2(size.x - 20, HEIGHT - 8)
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	add_child(row)
	get_viewport().size_changed.connect(_fit_view)
	_fit_view.call_deferred()
	var g = screen.game
	var who := UiKit.vbox(-2)
	who.custom_minimum_size = Vector2(92, 0)
	who.add_child(UiKit.label(str(g.map_def.name).to_upper(), 11, UiKit.ACCENT))
	var dd: Dictionary = Difficulty.DIFFICULTIES[g.difficulty]
	who.add_child(UiKit.label(str(dd.name).to_upper(), 10, dd.color))
	row.add_child(who)
	wave_label = UiKit.label("", 19)
	wave_label.custom_minimum_size = Vector2(236, 0)
	row.add_child(wave_label)
	row.add_child(_icon_value(func(ci): Draw.shield(ci, ci.size / 2.0, 8.0, UiKit.ACCENT), "lives"))
	row.add_child(_icon_value(func(ci): Draw.coin(ci, ci.size / 2.0, 8.0), "gold"))

	next_btn = UiKit.button("", Callable(screen, "toggle_intel"), Vector2(300, 30))
	next_btn.clip_contents = true
	next_btn.tooltip_text = "Next round. Click (or N) for full intel."
	next_box = UiKit.hbox(6)
	next_box.position = Vector2(8, 3)
	next_box.size = Vector2(286, 24)
	next_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	next_btn.add_child(next_box)
	row.add_child(next_btn)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(spacer)
	fps_label = UiKit.label("", 12, UiKit.DIM)
	fps_label.custom_minimum_size = Vector2(56, 0)
	fps_label.tooltip_text = "Frames per second (F3 or Settings to hide)"
	row.add_child(fps_label)
	speed_btn = UiKit.button("", Callable(screen, "toggle_speed"), Vector2(58, 30))
	speed_btn.tooltip_text = "Game speed"
	auto_btn = UiKit.button("", Callable(screen, "toggle_auto"), Vector2(96, 30))
	auto_btn.tooltip_text = "Automatically launch the next round 5 seconds after each clear"
	shop_btn = UiKit.button("Shop  [B]", Callable(screen, "toggle_shop"), Vector2(84, 30))
	shop_btn.tooltip_text = "Tower shop"
	research_btn = UiKit.button("Research  [R]", Callable(screen, "toggle_research"), Vector2(108, 30))
	research_btn.tooltip_text = "Research Lab (pauses the battle; purchases apply at once)"
	var codex_btn := UiKit.button("Codex  [K]", Callable(screen, "toggle_codex"), Vector2(92, 30))
	codex_btn.tooltip_text = "Codex: every tower, enemy, effect and rule (pauses the battle). Opens on your selection."
	var menu_btn := UiKit.button("Menu  [Esc]", Callable(screen, "open_pause"), Vector2(96, 30))
	for b in [next_btn, speed_btn, auto_btn, shop_btn, research_btn, codex_btn, menu_btn]:
		b.add_theme_font_size_override("font_size", 14)
		if b != next_btn:
			row.add_child(b)
	_lit = {"shop": shop_btn, "research": research_btn, "codex": codex_btn, "intel": next_btn}


func _icon_value(fn: Callable, which: String) -> HBoxContainer:
	var h := UiKit.hbox(5)
	h.add_child(DrawControl.new(fn, Vector2(20, 30)))
	var l := UiKit.label("", 18, UiKit.GOLD if which == "gold" else UiKit.TEXT)
	l.custom_minimum_size = Vector2(52 if which == "gold" else 28, 0)
	h.add_child(l)
	if which == "gold":
		gold_label = l
	else:
		lives_label = l
	return h


func refresh(_delta: float) -> void:
	var g = screen.game
	fps_label.visible = bool(SaveManager.setting("show_fps"))
	if fps_label.visible:
		fps_label.text = "%d FPS" % roundi(Engine.get_frames_per_second())
	wave_label.text = ("ROUND %d  ENDLESS" % g.wave) if g.endless else ("ROUND %d / %d" % [g.wave, g.final_round()])
	lives_label.text = str(g.lives)
	lives_label.modulate = Color(1, 1, 1).lerp(Color(1, 0.3, 0.3), clampf(hud.lives_flash / 0.3, 0.0, 1.0))
	gold_label.text = str(g.gold)
	speed_btn.text = "%dx  [F]" % screen.speed
	auto_btn.text = "Auto: %s  [A]" % ("On" if g.auto_start else "Off")
	for kind in _lit:
		var b: Button = _lit[kind]
		var want: bool = hud.is_open(kind)
		if want != b.has_theme_stylebox_override("normal"):
			for s in ["normal", "hover"]:
				if want:
					b.add_theme_stylebox_override(s, _lit_style)
				else:
					b.remove_theme_stylebox_override(s)
	_refresh_next(g)


func _refresh_next(g) -> void:
	var next: int = g.wave + 1
	var has_next: bool = not g.is_over()
	var key := "%d:%s" % [next, has_next]
	if key == _next_key:
		return
	_next_key = key
	for c in next_box.get_children():
		next_box.remove_child(c)
		c.queue_free()
	var lbl := UiKit.label("NEXT" if has_next else "BATTLE OVER", 11, UiKit.DIM)
	next_box.add_child(lbl)
	if not has_next:
		return
	var counts := {}
	var order: Array = []
	for grp in g.preview_wave(next):
		if not counts.has(grp.t):
			counts[grp.t] = 0
			order.append(grp.t)
		counts[grp.t] += int(grp.n)
	for et in order.slice(0, NEXT_TYPES):
		var ed: Dictionary = Enemies.ENEMIES[et]
		var etype: String = et
		var boss: bool = ed.get("boss", false)
		var item := UiKit.hbox(1)
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.add_child(DrawControl.new(func(ci): Draw.enemy(ci, etype, ci.size / 2.0, Vector2.RIGHT, float(ed.radius), 0.0, false, 0.0, 0.4 if boss else 0.75), Vector2(20, 24)))
		item.add_child(UiKit.label("×%d" % counts[et], 12, UiKit.BAD if boss else UiKit.TEXT))
		next_box.add_child(item)
	if order.size() > NEXT_TYPES:
		next_box.add_child(UiKit.label("+%d" % (order.size() - NEXT_TYPES), 12, UiKit.DIM))


## Spans the whole window width at its top edge (the layout itself is centred).
func _fit_view() -> void:
	var off := UiKit.view_offset()
	var w := UiKit.view_size().x
	position = -off
	size.x = w
	_bg.size.x = w
	_line.size.x = w
	_row.size.x = w - 20
