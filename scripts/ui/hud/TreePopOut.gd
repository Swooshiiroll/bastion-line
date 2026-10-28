extends "res://scripts/ui/PopOut.gd"
## The upgrade-tree viewer (#87): the selected tower's whole tree. The Retrofit choices on the left, then each path as a row of
## its four steps and its mastery, left to right. Each tile shows its name, its cost and its state (owned, buyable, too
## expensive, needs research, locked by the path rules, or later); hovering it shows the effect and the stat changes.
## Clicking a buyable next step or Retrofit buys it, as the tower panel does. Opens with the panel's Tree button or E, and
## pauses the battle while open.

const TowerInfo = preload("res://scripts/ui/TowerInfo.gd")
const Tower = preload("res://scripts/entities/Tower.gd")
const UpgradeRules = preload("res://scripts/core/UpgradeRules.gd")
const Draw = preload("res://scripts/view/Draw.gd")

const TILE := Vector2(168, 72)
const GAP := 12.0
const RETRO_W := 210.0
const NAME_W := 132.0
## Tile border colours by state.
const STATE_COLORS := {"owned": UiKit.GOOD, "buy": UiKit.GOLD, "short": UiKit.BAD, "research": Color(0.75, 0.55, 1.0),
	"locked": UiKit.DIM, "later": UiKit.BORDER}
const BRANCH_COLORS := {"a": Color(0.44, 0.72, 1.0), "b": Color(1.0, 0.62, 0.37), "c": Color(0.49, 1.0, 0.69)}

var hud
var screen
var tower
## "retrofit:<i>" or "<path>:<step>" (step 4 is the mastery) -> its tile Button (the tour clicks these).
var tiles := {}
var _sig := ""


func _init(owner_hud, t) -> void:
	var w := 16.0 + RETRO_W + 24.0 + NAME_W + 5.0 * TILE.x + 4.0 * GAP + 16.0
	var h := TITLE_H + 34.0 + 3.0 * (TILE.y + 18.0) + 30.0
	super(Rect2((UiKit.SCREEN.x - w) / 2.0, 120, w, h), "%s: UPGRADE TREE" % str(t.display_name()).to_upper(), Vector2(0, -16))
	hud = owner_hud
	screen = owner_hud.screen
	tower = t
	title_color = Draw.accent(t.type)


func _build() -> void:
	var chip := PanelContainer.new()
	var sb := UiKit.box(Color(0.14, 0.12, 0.05), UiKit.GOLD, 5, 1, 8.0)
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	chip.add_theme_stylebox_override("panel", sb)
	chip.add_child(UiKit.label("GAME PAUSED", 12, UiKit.GOLD))
	header.add_child(chip)
	_fill()


## Rebuilds the tiles when what they show changes (a purchase, or credits crossing a price).
func refresh(_delta: float) -> void:
	var g = screen.game
	if tower == null or not g.towers.has(tower) or screen.world.selected_tower != tower:
		screen.close_popout("tree")
		return
	if _signature() != _sig:
		for c in body.get_children():
			body.remove_child(c)
			c.queue_free()
		_fill()


func _signature() -> String:
	var g = screen.game
	var s: String = tower.look_key()
	for i in tower.retrofit_options().size():
		s += "1" if g.gold >= tower.retrofit_cost(i) else "0"
	for key in Tower.BRANCHES:
		s += str(UpgradeRules.card(tower, key, g.gold).state)
	return s


func _fill() -> void:
	_sig = _signature()
	tiles.clear()
	var t = tower
	var g = screen.game
	var note := UiKit.label("Click a gold tile to buy it. Hover any tile for what it does.  E or Esc closes.", 12, UiKit.DIM)
	note.position = Vector2(16, 8)
	body.add_child(note)
	var top := 36.0
	# The Retrofit column.
	var rhead := UiKit.label("RETROFIT (pick one)", 11, UiKit.GOLD)
	rhead.position = Vector2(16, top)
	body.add_child(rhead)
	var opts: Array = t.retrofit_options()
	var rh := (3.0 * (TILE.y + 18.0) - 18.0 - float(opts.size() - 1) * 8.0) / float(maxi(1, opts.size()))
	for i in opts.size():
		var o: Dictionary = opts[i]
		var cost: int = t.retrofit_cost(i)
		var state := "owned" if t.retrofit == i else ("locked" if t.retrofit >= 0 else ("buy" if g.gold >= cost else "short"))
		var why: String = {"owned": "Fitted", "locked": "Another Retrofit is fitted (the choice is locked)", "buy": "", "short": "Cannot afford"}[state]
		var b := _tile(o, cost, state, why, Vector2(RETRO_W, rh), Callable(screen, "buy_retrofit").bind(i))
		b.position = Vector2(16, top + 18.0 + float(i) * (rh + 8.0))
		body.add_child(b)
		tiles["retrofit:%d" % i] = b
	# One row per path.
	var x0 := 16.0 + RETRO_W + 24.0
	for pi in Tower.BRANCHES.size():
		var key: String = Tower.BRANCHES[pi]
		var br: Dictionary = t.branch(key)
		var y := top + 18.0 + float(pi) * (TILE.y + 18.0)
		var pname := UiKit.label(str(br.name).to_upper(), 13, BRANCH_COLORS[key])
		pname.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		pname.position = Vector2(x0, y + 4.0)
		pname.size = Vector2(NAME_W - 10.0, TILE.y)
		body.add_child(pname)
		var card: Dictionary = UpgradeRules.card(t, key, g.gold)
		var d: int = t.depth[key]
		var mastered_here: bool = (t.mastered and t.primary() == key) or t.mastered_paths.has(key)
		for s in Tower.BRANCH_STEPS + 1:
			var node: Dictionary = br.mastery if s == Tower.BRANCH_STEPS else br.nodes[s]
			var state := "later"
			var why := "Buy the steps before it first"
			if s < d or (s == Tower.BRANCH_STEPS and mastered_here):
				state = "owned"
				why = "Owned"
			elif s == d:
				match str(card.state):
					"buy", "short", "research":
						state = card.state
						why = card.reason
					_:
						state = "locked"
						why = card.reason
			elif card.state in ["locked", "capped"]:
				state = "locked"
				why = card.reason
			var b := _tile(node, t._price(int(node.cost)), state, why, TILE, Callable(screen, "upgrade_selected").bind(pi))
			b.position = Vector2(x0 + NAME_W + float(s) * (TILE.x + GAP), y)
			body.add_child(b)
			tiles["%s:%d" % [key, s]] = b
			if s < Tower.BRANCH_STEPS:
				var arrow := UiKit.label("›", 18, UiKit.DIM, HORIZONTAL_ALIGNMENT_CENTER)
				arrow.position = Vector2(b.position.x + TILE.x, y + TILE.y / 2.0 - 13.0)
				arrow.size = Vector2(GAP, 24)
				body.add_child(arrow)
	var legend := UiKit.label("Owned   ·   Gold: buy now   ·   Red: not enough credits   ·   Violet: needs research   ·   Grey: locked or later", 11, UiKit.DIM)
	legend.position = Vector2(16, body.size.y - 26.0)
	body.add_child(legend)


## One tile: name, cost and state, bordered by its state; only a buyable tile can be clicked.
func _tile(node: Dictionary, cost: int, state: String, why: String, sz: Vector2, buy: Callable) -> Button:
	var b := UiKit.button("", buy, sz)
	b.size = sz
	b.clip_contents = true
	var col: Color = STATE_COLORS[state]
	for st in ["normal", "hover", "pressed", "disabled", "focus"]:
		var bg := Color(col, 0.10 if st != "hover" else 0.2) if state in ["owned", "buy"] else Color(0.05, 0.07, 0.1, 0.9)
		var box := UiKit.box(bg, Color(col, 0.9 if state != "later" else 0.6), 6, 2 if state == "buy" else 1, 0.0)
		b.add_theme_stylebox_override(st, box)
	b.disabled = state != "buy"
	b.mouse_filter = Control.MOUSE_FILTER_STOP
	b.tooltip_text = _tooltip(node, cost, why)
	var name_l := UiKit.label(str(node.name), 13, UiKit.TEXT if state != "later" else UiKit.DIM)
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_l.max_lines_visible = 2
	name_l.position = Vector2(10, 6)
	name_l.size = Vector2(sz.x - 20, 36)
	b.add_child(name_l)
	var tag := "OWNED" if state == "owned" else ("%d cr" % cost)
	if state == "research":
		tag += "  ·  research"
	elif state == "locked":
		tag = "LOCKED"
	var cost_l := UiKit.label(tag, 12, col if state != "later" else UiKit.DIM)
	cost_l.position = Vector2(10, sz.y - 22)
	b.add_child(cost_l)
	return b


## The hover text: name, price and why it can't be bought, then its effect and the stat changes it makes.
static func _tooltip(node: Dictionary, cost: int, why: String) -> String:
	var lines: Array = ["%s  (%d cr)" % [node.name, cost]]
	if why != "":
		lines.append(why)
	lines.append(str(node.get("blurb", "")))
	var ch := changes(node)
	if ch != "":
		lines.append(ch)
	return "\n".join(PackedStringArray(lines))


## A node's stat changes in words, e.g. "Attacks/s +0.3 · Range 230 · Sees through decoys".
static func changes(node: Dictionary) -> String:
	var names := {"damage": ["Damage", "%d"], "range": ["Range", "%d"]}
	for r in TowerInfo.STAT_ROWS:
		names[r[1]] = [r[0], r[2]]
	for r in TowerInfo.FLAG_ROWS:
		names[r[1]] = [r[0], "yes"]
	var out: Array = []
	for k in node.get("add", {}):
		var v := float(node.add[k])
		var label: String = names[k][0] if names.has(k) else str(k)
		var f: String = names[k][1] if names.has(k) else "%.2f"
		var txt := TowerInfo.fmt(absf(v), f).trim_prefix("+")
		out.append("%s %s%s" % [label, "+" if v >= 0.0 else "-", txt])
	for k in node.get("set", {}):
		var v = node.set[k]
		var label: String = names[k][0] if names.has(k) else str(k)
		if v is bool:
			if v:
				out.append(label)
		else:
			out.append("%s %s" % [label, TowerInfo.fmt(v, names[k][1] if names.has(k) else "%.2f")])
	return "  ·  ".join(PackedStringArray(out))
