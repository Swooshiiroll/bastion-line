extends "res://scripts/ui/PopOut.gd"
## Tower shop pop-out: slides in from the right edge. Two columns of tower cards (name, cost,
## reach tag, hotkey) and the hovered card's details. Picking a card closes the shop and starts
## placing that tower; GameScreen reopens the shop once it is placed.

const DrawControl = preload("res://scripts/ui/DrawControl.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const TowerInfo = preload("res://scripts/ui/TowerInfo.gd")
const Towers = preload("res://data/towers.gd")
const Tower = preload("res://scripts/entities/Tower.gd")

const CARD := Vector2(136, 52)

var hud
var screen
var cards := {}
var _detail: VBoxContainer
var _shown := "?"


func _init(owner_hud) -> void:
	super(Rect2(1290, 44, 302, 760), "TOWER SHOP", Vector2(320, 0))
	hud = owner_hud
	screen = owner_hud.screen


func _build() -> void:
	for i in Towers.ORDER.size():
		var type: String = Towers.ORDER[i]
		var b := _card(type, TowerInfo.build_key(i))
		b.position = Vector2(10 + (i % 2) * (CARD.x + 8), 8 + (i / 2) * (CARD.y + 6))
		body.add_child(b)
		cards[type] = b
	var sep := ColorRect.new()
	sep.color = UiKit.BORDER
	sep.position = Vector2(12, 8 + ceili(Towers.ORDER.size() / 2.0) * (CARD.y + 6) + 2)
	sep.size = Vector2(rect.size.x - 24, 1)
	body.add_child(sep)
	_detail = UiKit.vbox(4)
	_detail.position = Vector2(14, sep.position.y + 10)
	_detail.size = Vector2(rect.size.x - 28, 150)
	body.add_child(_detail)


func _card(type: String, key: String) -> Button:
	var d: Dictionary = Towers.TOWERS[type]
	var b := UiKit.button("", Callable(screen, "shop_pick").bind(type), CARD)
	b.size = CARD
	b.tooltip_text = "%s  [%s]\n%s" % [d.name, key, d.blurb]
	var icon := DrawControl.new(func(ci): Draw.tower(ci, type, 1, ci.size / 2.0, -PI / 2.0, 0.68, Time.get_ticks_msec() / 1000.0, 0.0), Vector2(34, 40), true)
	icon.position = Vector2(2, 6)
	b.add_child(icon)
	var name_l := UiKit.label(d.name, 12)
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_l.position = Vector2(38, 3)
	name_l.size = Vector2(84, 30)
	name_l.add_theme_constant_override("line_spacing", -3)
	b.add_child(name_l)
	var tag: Array = TowerInfo.reach_tag(type)
	var cost_l := UiKit.label("%d cr" % screen.game.tower_cost(type), 12, UiKit.GOLD)
	cost_l.position = Vector2(38, 32)
	b.add_child(cost_l)
	var tag_l := UiKit.label(tag[0], 9, tag[1])
	tag_l.position = Vector2(78, 35)
	b.add_child(tag_l)
	var key_l := UiKit.label(key, 10, UiKit.DIM, HORIZONTAL_ALIGNMENT_RIGHT)
	key_l.position = Vector2(114, 2)
	key_l.size = Vector2(16, 14)
	b.add_child(key_l)
	b.mouse_entered.connect(func(): hud.hovered_build = type)
	b.mouse_exited.connect(func():
		if hud.hovered_build == type:
			hud.hovered_build = ""
	)
	return b


func refresh(_delta: float) -> void:
	var g = screen.game
	for type in cards:
		(cards[type] as Button).disabled = g.gold < g.tower_cost(type) or g.is_over()
	var want: String = hud.hovered_build
	if want == "":
		want = "help"
	if want != _shown:
		_shown = want
		_show(want)


func _show(type: String) -> void:
	for c in _detail.get_children():
		_detail.remove_child(c)
		c.queue_free()
	if type == "help":
		_detail.add_child(UiKit.wrap_label("Hover a tower for its details. Click one to place it: the shop closes while you build and reopens afterwards.", rect.size.x - 28, 12, UiKit.DIM))
		_detail.add_child(UiKit.wrap_label("Keys 1-9, 0, -, =, [, ] and \\ build directly.", rect.size.x - 28, 12, UiKit.DIM))
		return
	var g = screen.game
	var d: Dictionary = Towers.TOWERS[type]
	_detail.add_child(UiKit.label(d.name, 17, Draw.accent(type)))
	_detail.add_child(UiKit.label("%d cr  ·  %s" % [g.tower_cost(type), TowerInfo.reach_text(type)], 12, UiKit.GOLD))
	_detail.add_child(UiKit.wrap_label(d.blurb, rect.size.x - 28, 11, UiKit.DIM))
	_detail.add_child(TowerInfo.stats_grid(g.level_stats(type, 1), {}, bool(d.get("beam", false)), 11, 8))
	var specs: Array = Tower.tree(type).branches.map(func(b): return str(b.nodes[0].name))
	_detail.add_child(UiKit.label("Branches: %s" % ", ".join(PackedStringArray(specs)), 11, UiKit.GOLD))
