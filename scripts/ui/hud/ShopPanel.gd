extends "res://scripts/ui/PopOut.gd"
## Tower shop pop-out: slides in from the right edge. Tower cards (name, cost, reach tag) in two columns, grouped by class
## under a header (Assault, Support, Defense, Utility), cheapest first within each (#87); a card you can't afford is greyed
## out. Below them, the hovered card's details. Picking a card closes the shop and starts placing that tower; GameScreen
## reopens the shop once it is placed.

const DrawControl = preload("res://scripts/ui/DrawControl.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const TowerInfo = preload("res://scripts/ui/TowerInfo.gd")
const Towers = preload("res://data/towers.gd")
const Tower = preload("res://scripts/entities/Tower.gd")

const CARD := Vector2(136, 52)
## The class sections, in shop order.
const CLASSES := ["Assault", "Support", "Defense", "Utility"]
## Room kept under the cards for the hovered tower's details.
const DETAIL_H := 176.0
## A card's tint while it can't be afforded.
const GREYED := Color(0.55, 0.55, 0.55, 0.6)

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
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(0, 4)
	scroll.size = Vector2(rect.size.x, body.size.y - DETAIL_H - 8)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var grid := Control.new()
	scroll.add_child(grid)
	var y := 4.0
	for cls in CLASSES:
		var types: Array = sorted_types(cls, screen.game)
		if types.is_empty():
			continue
		var head := UiKit.label(str(cls).to_upper(), 11, TowerInfo.CLASS_COLORS.get(cls, UiKit.DIM))
		head.position = Vector2(12, y)
		grid.add_child(head)
		y += 18.0
		for i in types.size():
			var b := _card(types[i], "")
			b.position = Vector2(10 + (i % 2) * (CARD.x + 8), y + (i / 2) * (CARD.y + 6))
			grid.add_child(b)
			cards[types[i]] = b
		y += ceili(types.size() / 2.0) * (CARD.y + 6) + 4.0
	grid.custom_minimum_size = Vector2(rect.size.x - 12, y)
	var sep := ColorRect.new()
	sep.color = UiKit.BORDER
	sep.position = Vector2(12, scroll.position.y + scroll.size.y + 2)
	sep.size = Vector2(rect.size.x - 24, 1)
	body.add_child(sep)
	_detail = UiKit.vbox(4)
	_detail.position = Vector2(14, sep.position.y + 8)
	_detail.size = Vector2(rect.size.x - 28, DETAIL_H - 14)
	body.add_child(_detail)


## The towers of class `cls`, cheapest first (ties keep the roster order).
static func sorted_types(cls: String, g) -> Array:
	var all: Array = Towers.all_types()
	var out: Array = all.filter(func(t): return str(Towers.def(t)["class"]) == cls)
	out.sort_custom(func(a, b): return g.tower_cost(a) < g.tower_cost(b) or (g.tower_cost(a) == g.tower_cost(b) and all.find(a) < all.find(b)))
	return out


func _card(type: String, key: String) -> Button:
	var d: Dictionary = Towers.def(type)
	var b := UiKit.button("", Callable(screen, "shop_pick").bind(type), CARD)
	b.size = CARD
	b.tooltip_text = "%s%s
%s" % [d.name, "  [%s]" % key if key != "" else "  (%s)" % d["class"], _tagline(type, d)]
	if d.has("class"):
		# Reworked towers: the tile is tinted by class (Assault, Support, Defense, Utility).
		var cc: Color = TowerInfo.CLASS_COLORS.get(d["class"], UiKit.ACCENT)
		for s in ["normal", "hover", "pressed", "focus", "disabled"]:
			var sb := UiKit.box(Color(cc, 0.16 if s != "hover" else 0.28), Color(cc, 0.8 if s == "hover" else 0.5), 6, 1, 0.0)
			sb.border_width_left = 4
			b.add_theme_stylebox_override(s, sb)
	var icon := DrawControl.new(func(ci): Draw.tower(ci, type, 1, ci.size / 2.0, -PI / 2.0, 0.68, 0.0, 0.0), Vector2(34, 40), false)   # still icons (#116)
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
		var b: Button = cards[type]
		b.disabled = g.gold < g.tower_cost(type) or g.is_over()
		b.modulate = GREYED if b.disabled else Color.WHITE
	var want: String = hud.hovered_build
	if want == "":
		want = "help"
	if want != _shown:
		_shown = want
		_show(want)


## The one-line tagline the shop shows (#116): the full blurb, with its flavour quote, stays in the Codex.
func _tagline(type: String, d: Dictionary) -> String:
	var tr: Dictionary = Towers.Rework.TREES.get(type, {})
	var tag: String = str(tr.get("tagline", ""))
	return tag if tag != "" else str(d.get("blurb", ""))


func _show(type: String) -> void:
	for c in _detail.get_children():
		_detail.remove_child(c)
		c.queue_free()
	if type == "help":
		_detail.add_child(UiKit.wrap_label("Hover a tower for its details. Click one to place it: the shop closes while you build and reopens afterwards.", rect.size.x - 28, 12, UiKit.DIM))
		return
	var g = screen.game
	var d: Dictionary = Towers.def(type)
	_detail.add_child(UiKit.label(d.name, 17, Draw.accent(type)))
	_detail.add_child(UiKit.label("%d cr  ·  %s" % [g.tower_cost(type), TowerInfo.reach_text(type)], 12, UiKit.GOLD))
	_detail.add_child(UiKit.wrap_label(_tagline(type, d), rect.size.x - 28, 11, UiKit.DIM))
	_detail.add_child(TowerInfo.stats_grid(g.level_stats(type, 1), {}, bool(d.get("beam", false)), 11, 8))
	var specs: Array = Towers.Rework.TREES[type].paths.map(func(p): return str(p.name))
	_detail.add_child(UiKit.label("%s: %s" % ["Paths", ", ".join(PackedStringArray(specs))], 11, UiKit.GOLD))
