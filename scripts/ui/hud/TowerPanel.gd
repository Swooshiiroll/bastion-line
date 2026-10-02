extends "res://scripts/ui/PopOut.gd"
## The tower panel (design/upgrade_rework.md §1): opens in the shop's slot on the right while a
## tower is selected. Shows the tower's combat stats, then the next upgrade on each branch as a
## card to buy (click it, or U / I / O). Cards that can't be bought stay, dimmed, with the reason.
## GameScreen keeps it in step with the selection (_sync_side_panel).

const TowerInfo = preload("res://scripts/ui/TowerInfo.gd")
const Tower = preload("res://scripts/entities/Tower.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const UpgradeRules = preload("res://scripts/core/UpgradeRules.gd")

const BRANCH_COLORS := {"a": Color(0.44, 0.72, 1.0), "b": Color(1.0, 0.62, 0.37), "c": Color(0.49, 1.0, 0.69)}
const W := 302.0
## Where the panel sits on each side of the screen.
const RIGHT_X := 1290.0
const LEFT_X := 8.0

var hud
var screen
var tower
## "right" or "left": the side away from the tower (side_for).
var side := "right"
## Card key ("trunk", "a", "b", "c") -> its Button (the screenshot tour clicks these).
var cards := {}
var _content: VBoxContainer
var _key := ""


func _init(owner_hud, t, on_side := "right") -> void:
	side = on_side
	var left := side == "left"
	super(Rect2(LEFT_X if left else RIGHT_X, 44, W, 760), str(t.display_name()).to_upper(), Vector2(-320 if left else 320, 0))
	hud = owner_hud
	screen = owner_hud.screen
	tower = t
	title_color = Draw.accent(t.type, t.shown_spec) if t.shown_spec != "" else UiKit.TEXT


## The side of the screen away from tower `t`, so the panel never covers it: a tower on the left
## half of the screen (after zoom and pan) gets the panel on the right, and the other way round.
static func side_for(world, t) -> String:
	var x: float = world.position.x + float(t.pos.x) * float(world.zoom)
	return "left" if x > UiKit.SCREEN.x / 2.0 else "right"


func _build() -> void:
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(12, 8)
	scroll.size = Vector2(W - 20, body.size.y - 16)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	_content = UiKit.vbox(10)
	_content.custom_minimum_size = Vector2(W - 34, 0)
	scroll.add_child(_content)


func refresh(_delta: float) -> void:
	var t = tower
	# Rebuild only when something a card shows changes: the tower's upgrades, a card's state (e.g.
	# affordable or not), prices. Credits alone change with every kill; rebuilding then would swap
	# the card under the mouse mid-hover.
	var states := UpgradeRules.card_keys(t).map(func(k): return str(UpgradeRules.card(t, k, screen.game.gold).state))
	var key := "%d:%s:%s:%s:%s:%s:%.3f" % [t.trunk, str(t.depth), str(t.started), t.mastered, t.mastery_unlocked(), ",".join(PackedStringArray(states)), t.discount]
	if key != _key:
		_key = key
		_rebuild()
		_rehover.call_deferred()


func _rebuild() -> void:
	for c in _content.get_children():
		_content.remove_child(c)
		c.queue_free()
	cards.clear()
	var t = tower
	# The title follows the tower: its stock name until the primary locks in, then the branch name.
	var title_label := header.get_child(0) as Label
	title_label.text = str(t.display_name()).to_upper()
	title_label.add_theme_color_override("font_color", Draw.accent(t.type, t.shown_spec) if t.shown_spec != "" else UiKit.TEXT)
	# Where it is in its tree, then what it does now.
	var level := Tower.trunk_name(t.trunk)
	if not t.started.is_empty():
		level = " + ".join(PackedStringArray(t.started.map(func(b): return "%s · T%d" % [b.to_upper(), t.depth[b]])))
	if t.mastered:
		level = "%s · MASTERY" % t.primary().to_upper()
	_content.add_child(UiKit.label(level, 12, UiKit.GOLD if t.tier >= 3 else UiKit.DIM))
	_content.add_child(UiKit.label("COMBAT STATS", 11, UiKit.DIM))
	_content.add_child(TowerInfo.stats_grid(t.stats(), {}, t.is_beam(), 12, 10))
	_content.add_child(UiKit.label("UPGRADES", 11, UiKit.DIM))
	for k in UpgradeRules.card_keys(t):
		var c := UpgradeRules.card(t, k, screen.game.gold)
		var btn := _card(c)
		cards[k] = btn
		_content.add_child(btn)
	_content.add_child(UiKit.button("View upgrade tree  [E]", Callable(screen, "open_tree"), Vector2(W - 34, 34)))


func _card(c: Dictionary) -> Button:
	var t = tower
	var key: String = c.key
	var state: String = c.state
	var mastery: bool = key != "trunk" and c.node == t.branch(key).mastery
	var col: Color = UiKit.GOLD if mastery else BRANCH_COLORS.get(key, UiKit.ACCENT)
	var live := state == "buy"
	var btn := Button.new()
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(W - 34, 0)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if live else Control.CURSOR_ARROW
	var dim := 1.0 if state in ["buy", "short"] else 0.55
	for s in ["normal", "hover", "pressed", "focus", "disabled"]:
		var edge := col if (s == "hover" and live) else Color(col, 0.45 * dim)
		var sb := UiKit.box(Color(0.05, 0.08, 0.11, 0.95) if s != "hover" else Color(0.07, 0.11, 0.15, 0.98), edge, 6, 1, 0.0)
		sb.border_width_left = 4
		btn.add_theme_stylebox_override(s, sb)
	var box := UiKit.vbox(4)
	box.position = Vector2(12, 8)
	box.custom_minimum_size = Vector2(W - 58, 0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Name, then cost and hotkey.
	var head := UiKit.hbox(6)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tag := "RETROFIT" if key == "trunk" else ("%s · MASTERY" % key.to_upper() if mastery else "%s · T%d" % [key.to_upper(), mini(int(t.depth[key]) + 1, Tower.BRANCH_STEPS)])
	var name_l := UiKit.label(str(c.node.get("name", "")), 15, Color(col, dim))
	name_l.clip_text = true
	name_l.custom_minimum_size = Vector2(140, 0)
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(name_l)
	if state in ["buy", "short", "research"]:
		head.add_child(UiKit.label("%d cr  [%s]" % [int(c.cost), c.hotkey], 13, UiKit.GOLD if state == "buy" else (UiKit.BAD if state == "short" else UiKit.DIM)))
	box.add_child(head)
	box.add_child(UiKit.label(tag, 10, Color(UiKit.DIM, dim)))
	if state in ["buy", "short", "research"]:
		var nxt: Dictionary = t.next_stats("" if key == "trunk" else key) if state != "research" else {}
		if not nxt.is_empty():
			var grid := TowerInfo.stats_grid(t.stats(), nxt, t.is_beam(), 11, 8)
			grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
			box.add_child(grid)
	var blurb := str(c.node.get("blurb", ""))
	if blurb != "":
		var bl := UiKit.wrap_label(blurb, W - 60, 12, Color(UiKit.TEXT, 0.85 * dim))
		bl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(bl)
	if c.reason != "":
		var why := UiKit.wrap_label(str(c.reason), W - 60, 12, UiKit.BAD if state == "short" else Color(0.75, 0.8, 0.86))
		why.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(why)
	btn.add_child(box)
	# The button grows to fit its contents once they're laid out.
	box.resized.connect(func(): btn.custom_minimum_size.y = box.size.y + 16)
	btn.pressed.connect(func(): _buy(c))
	btn.mouse_entered.connect(func(): _highlight(c))
	btn.mouse_exited.connect(func(): _highlight({}))
	btn.tooltip_text = str(c.reason) if c.reason != "" else ""
	return btn


## After a rebuild, the card under a still mouse is re-highlighted in the tree.
func _rehover() -> void:
	var m := get_global_mouse_position()
	for k in cards:
		var b: Button = cards[k]
		if is_instance_valid(b) and b.get_global_rect().has_point(m):
			_highlight(UpgradeRules.card(tower, k, screen.game.gold))
			return


func _buy(c: Dictionary) -> void:
	if c.state != "buy":
		hud.toast(str(c.reason) if c.reason != "" else "Can't buy that", UiKit.BAD if c.state == "short" else UiKit.DIM)
		Sfx.play("error", -6.0, 0.0)
		return
	screen.upgrade_selected(0 if c.key == "trunk" else Tower.BRANCHES.find(c.key))
	_key = ""


## Lights up the card's node in the upgrade tree, if it's open.
func _highlight(c: Dictionary) -> void:
	var tree = hud.popout("tree")
	if tree == null:
		return
	if c.is_empty():
		tree.highlight("")
		return
	var id := "t2"
	if c.key != "trunk":
		var d: int = tower.depth[c.key]
		id = "%sm" % c.key if (d >= Tower.BRANCH_STEPS or c.state == "research" or (c.state == "done" and tower.mastered)) else "%s%d" % [c.key, mini(d + (0 if c.state in ["capped", "done"] else 1), Tower.BRANCH_STEPS)]
	tree.highlight(id)
