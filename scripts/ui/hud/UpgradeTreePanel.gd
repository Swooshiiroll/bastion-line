extends "res://scripts/ui/PopOut.gd"
## Upgrade-tree pop-out for the selected tower, for reading and planning (design/upgrade_rework.md
## §3); upgrades are bought in the tower panel. The trunk (tier 1 -> tier 2) is on the left, then
## the three branches as rows of four upgrades ending in a mastery, drawn as hex nodes on circuit
## traces. Owned nodes are gold, the next buyable one pulses, blocked and locked ones are dim, and
## a marker after the second upgrade shows where a secondary branch stops. The header says which
## branch is primary.
## Under the tree, a strip: the selected node's live preview (UpgradePreview) on the left, and the
## hovered (else selected) node's description and stat changes on the right. Click a node to
## select it.

const DrawControl = preload("res://scripts/ui/DrawControl.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const TowerInfo = preload("res://scripts/ui/TowerInfo.gd")
const Tower = preload("res://scripts/entities/Tower.gd")
const Research = preload("res://scripts/core/Research.gd")
const UpgradeRules = preload("res://scripts/core/UpgradeRules.gd")
const UpgradePreview = preload("res://scripts/ui/hud/UpgradePreview.gd")

const NODE_R := 24.0
const BTN := Vector2(62, 62)
const KEYS := ["U", "I", "O"]
const ROW_Y := {"a": 64.0, "b": 170.0, "c": 276.0}
const COL_X := [330.0, 500.0, 670.0, 840.0, 1010.0]
const TRUNK := {"t1": Vector2(70, 170), "t2": Vector2(200, 170)}
const TREE_H := 350.0
const PREVIEW := Vector2(600, 300)

var hud
var screen
var tower = null
## Node id ("t1", "t2", "a1".."a4", "am", ...) -> Button (the screenshot tour clicks these).
var node_buttons := {}
var _pos := {}
var _labels := {}
var _hovered := ""
var _shown := "?"
var _key := ""
var _detail: Control
## The clicked node, whose preview plays ("" until the default is picked).
var selected := ""
## A node the tower panel is pointing at (its hovered card), outlined.
var _pointed := ""
var preview
var _status: HBoxContainer


func _init(owner_hud, t) -> void:
	super(Rect2(24, 46, 1250, 740), "%s  ·  UPGRADE TREE" % str(t.def.name).to_upper(), Vector2(0, 18))
	hud = owner_hud
	screen = owner_hud.screen
	tower = t
	title_color = Draw.accent(t.type)


func _build() -> void:
	_pos = TRUNK.duplicate()
	var codex := UiKit.button("Codex  [K]", func():
		screen.close_popout("tree")
		screen.toggle_codex(), Vector2(0, 26))
	codex.tooltip_text = "This tower's full entry in the Codex"
	codex.add_theme_font_size_override("font_size", 12)
	header.add_child(codex)
	for b in Tower.BRANCHES:
		for k in 4:
			_pos["%s%d" % [b, k + 1]] = Vector2(COL_X[k], ROW_Y[b])
		_pos[b + "m"] = Vector2(COL_X[4], ROW_Y[b])
	_status = UiKit.hbox(8)
	header.add_child(_status)
	body.add_child(DrawControl.new(_draw_links, Vector2(rect.size.x, TREE_H), true))
	for id in _pos:
		var nid: String = id
		var btn := Button.new()
		btn.focus_mode = Control.FOCUS_NONE
		btn.flat = true
		var empty := StyleBoxEmpty.new()
		for s in ["normal", "hover", "pressed", "focus", "disabled"]:
			btn.add_theme_stylebox_override(s, empty)
		btn.position = _pos[id] - BTN / 2.0
		btn.size = BTN
		btn.add_child(DrawControl.new(func(ci): _draw_node(ci, nid), BTN, true))
		btn.mouse_entered.connect(func(): _hovered = nid)
		btn.mouse_exited.connect(func():
			if _hovered == nid:
				_hovered = ""
		)
		btn.pressed.connect(func(): select(nid))
		body.add_child(btn)
		node_buttons[id] = btn
		var lab := UiKit.vbox(-2)
		lab.position = _pos[id] + Vector2(-78, NODE_R + 8)
		lab.size = Vector2(156, 34)
		lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		body.add_child(lab)
		_labels[id] = lab
	for b in Tower.BRANCHES:
		var tag := UiKit.label(b.to_upper(), 12, _branch_color(b), HORIZONTAL_ALIGNMENT_CENTER)
		tag.position = Vector2(COL_X[0] - 50, ROW_Y[b] - 24)
		tag.size = Vector2(24, 14)
		body.add_child(tag)
	var sep := ColorRect.new()
	sep.color = UiKit.BORDER
	sep.position = Vector2(16, TREE_H + 4)
	sep.size = Vector2(rect.size.x - 32, 1)
	body.add_child(sep)
	preview = UpgradePreview.new(PREVIEW)
	preview.position = Vector2(20, TREE_H + 16)
	body.add_child(preview)
	_detail = Control.new()
	_detail.position = Vector2(PREVIEW.x + 44, TREE_H + 16)
	_detail.size = Vector2(rect.size.x - PREVIEW.x - 64, PREVIEW.y)
	body.add_child(_detail)


static func _branch_color(b: String) -> Color:
	return {"a": Color(0.44, 0.72, 1.0), "b": Color(1.0, 0.62, 0.37), "c": Color(0.49, 1.0, 0.69)}.get(b, UiKit.ACCENT)


## "a2" -> ["a", 2]; "am" -> ["a", 5]; "t1"/"t2" -> ["", 1/2].
func _parse(id: String) -> Array:
	if id.begins_with("t"):
		return ["", int(id.substr(1))]
	var b := id.substr(0, 1)
	return [b, 5 if id.ends_with("m") else int(id.substr(1))]


func _node(id: String) -> Dictionary:
	var p := _parse(id)
	if p[0] == "":
		return Tower.tree(tower.type).tiers[int(p[1]) - 1]
	var br: Dictionary = tower.branch(p[0])
	return br.mastery if int(p[1]) == 5 else br.nodes[int(p[1]) - 1]


## owned | next | short | locked (mastery research) | blocked (branch rules) | future
func _state(id: String) -> String:
	var t = tower
	var p := _parse(id)
	var b: String = p[0]
	var k: int = p[1]
	var gold: int = screen.game.gold
	if b == "":
		if t.trunk >= k:
			return "owned"
		return "next" if gold >= t.upgrade_cost() else "short"
	var d: int = t.depth[b]
	# The secondary stops at its cap once a primary is locked in.
	if t.locked_in() and b != t.primary() and k > Tower.SECONDARY_CAP:
		return "owned" if d >= k else "blocked"
	if k == 5:
		if t.mastered and t.primary() == b:
			return "owned"
		if d >= 4 and t.primary() == b:
			if not t.mastery_unlocked():
				return "locked"
			return "next" if gold >= t.upgrade_cost(b) else "short"
		if t.block_reason(b) != "" and t.trunk >= 2 and d < 4:
			return "blocked" if t.block_reason(b).begins_with("Locked") or t.block_reason(b).begins_with("Blocked") else "future"
		return "locked" if not t.mastery_unlocked() else "future"
	if d >= k:
		return "owned"
	if d == k - 1 and t.trunk >= 2:
		var why: String = t.block_reason(b)
		if why == "":
			return "next" if gold >= t.upgrade_cost(b) else "short"
		return "blocked"
	if t.trunk >= 2 and t.block_reason(b) != "" and not t.block_reason(b).begins_with("Retrofit"):
		return "blocked"
	return "future"


func _cost(id: String) -> int:
	return Research.discounted(int(_node(id).cost), tower.mods)


func _link_pts(from: Vector2, to: Vector2) -> PackedVector2Array:
	if is_equal_approx(from.y, to.y):
		return PackedVector2Array([from, to])
	var midx := TRUNK.t2.x + 62.0
	return PackedVector2Array([from, Vector2(midx, from.y), Vector2(midx, to.y), to])


func _draw_links(ci: Control) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var links: Array = [["t1", "t2"]]
	for b in Tower.BRANCHES:
		links.append(["t2", b + "1"])
		for k in range(1, 4):
			links.append(["%s%d" % [b, k], "%s%d" % [b, k + 1]])
		links.append([b + "4", b + "m"])
	for l in links:
		var s0 := _state(l[0])
		var s1 := _state(l[1])
		var pts := _link_pts(_pos[l[0]], _pos[l[1]])
		if s1 == "owned":
			ci.draw_polyline(pts, UiKit.GOLD, 3.0, true)
		elif s1 in ["next", "short"] and s0 == "owned":
			ci.draw_polyline(pts, UiKit.ACCENT if s1 == "next" else Color(UiKit.ACCENT, 0.4), 2.5, true)
			var total := 0.0
			for i in range(1, pts.size()):
				total += pts[i - 1].distance_to(pts[i])
			var dd := fmod(t * 0.7, 1.0) * total
			for i in range(1, pts.size()):
				var seg := pts[i - 1].distance_to(pts[i])
				if dd <= seg:
					ci.draw_circle(pts[i - 1].lerp(pts[i], dd / maxf(seg, 0.001)), 3.0, UiKit.ACCENT)
					break
				dd -= seg
		else:
			var col := Color(0.16, 0.22, 0.28) if s1 == "blocked" else Color(0.22, 0.3, 0.37)
			for i in range(1, pts.size()):
				ci.draw_dashed_line(pts[i - 1], pts[i], col, 2.0, 6.0)
	# Where a secondary branch stops: after the second upgrade.
	var sec: String = tower.secondary() if tower.locked_in() else ""
	for b in Tower.BRANCHES:
		var x := (COL_X[1] + COL_X[2]) / 2.0
		var y: float = ROW_Y[b]
		var col := Color(1.0, 0.62, 0.37) if b == sec else Color(0.3, 0.38, 0.46, 0.55)
		ci.draw_line(Vector2(x, y - 26.0), Vector2(x, y + 26.0), col, 2.0 if b == sec else 1.0)
		if b == sec:
			ci.draw_string(UiKit.font(), Vector2(x - 50.0, y - 31.0), "SECONDARY CAP", HORIZONTAL_ALIGNMENT_CENTER, 100.0, 10, col)


func _draw_node(ci: Control, id: String) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var c := ci.size / 2.0
	var st := _state(id)
	var p := _parse(id)
	var b: String = p[0]
	var k: int = p[1]
	var sid: String = str(tower.branch(b).id) if b != "" else ""
	var acc := Draw.accent(tower.type, sid) if b != "" else Draw.accent(tower.type)
	var mastery := k == 5
	var hex_state: String = {"owned": "owned", "next": "ready", "short": "short", "blocked": "gone"}.get(st, "locked")
	var r := NODE_R + (3.0 if mastery else 0.0)
	Draw.skill_hex(ci, c, r, hex_state, acc, t, mastery)
	if b == "":
		Draw.tower(ci, tower.type, k, c, -PI / 2.0, 0.5, t, 0.0, "")
	elif k == 1 or mastery:
		Draw.tower(ci, tower.type, 4 if mastery else 3, c, -PI / 2.0, 0.5, t, 0.0, sid)
	else:
		var col := Color(1, 0.93, 0.7) if st == "owned" else (acc if st in ["next", "short"] else Color(0.4, 0.47, 0.55))
		ci.draw_string(UiKit.font(), c + Vector2(-10, 7), str(k), HORIZONTAL_ALIGNMENT_CENTER, 20, 19, col)
	if st in ["blocked", "future", "locked"]:
		Draw.fill(ci, c, Draw.ngon(6, 1.0, PI / 6.0), Color(0.02, 0.03, 0.05, 0.6), 0.0, r - 1.0)
	if st in ["locked", "blocked"]:
		Draw.lock(ci, c + Vector2(0, 1), 1.4, Color(0.75, 0.8, 0.86))
	if id == selected:
		Draw.outline(ci, c, Draw.ngon(6, 1.0, PI / 6.0), UiKit.GOLD, 2.0, 0.0, r + 9.0)
	elif id == _hovered or id == _pointed:
		Draw.outline(ci, c, Draw.ngon(6, 1.0, PI / 6.0), Color(UiKit.ACCENT, 0.7), 1.0, 0.0, r + 9.0)


func refresh(_delta: float) -> void:
	# Keyed on what the nodes show (their states), not raw credits, which change with every kill.
	var key := "%d:%s:%s:%s:%s" % [tower.trunk, str(tower.depth), str(tower.started), tower.mastered, ",".join(PackedStringArray(_pos.keys().map(func(id): return _state(id))))]
	if key != _key:
		_key = key
		for id in _labels:
			_label(id)
		_refresh_status()
		_shown = "?"
	if selected == "":
		select(_default_select())
	var want := _hovered if _hovered != "" else selected
	if want != _shown:
		_shown = want
		_show_detail(want)


func _refresh_status() -> void:
	for c in _status.get_children():
		_status.remove_child(c)
		c.queue_free()
	var t = tower
	for b in Tower.BRANCHES:
		var d: int = t.depth[b]
		var text := ""
		var col := _branch_color(b)
		if t.locked_in() and b == t.primary():
			text = "PRIMARY · %s T%d%s" % [b.to_upper(), d, " + MASTERY" if t.mastered else ""]
		elif t.locked_in() and d > 0:
			text = "SECONDARY · %s T%d (max T2)" % [b.to_upper(), d]
		elif d > 0:
			text = "%s T%d" % [b.to_upper(), d]
		elif t.started.size() >= 2:
			text = "%s LOCKED" % b.to_upper()
			col = Color(0.35, 0.42, 0.5)
		else:
			continue
		var pc := PanelContainer.new()
		var sb := UiKit.box(Color(0, 0, 0, 0), Color(col, 0.6), 3, 1, 6.0)
		sb.content_margin_top = 1
		sb.content_margin_bottom = 1
		pc.add_theme_stylebox_override("panel", sb)
		pc.add_child(UiKit.label(text, 11, col))
		pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_status.add_child(pc)


## The node selected when the tree opens: the next upgrade on the primary (its mastery once the
## branch is full), else the Retrofit.
func _default_select() -> String:
	if tower.trunk < 2:
		return "t2"
	var p: String = tower.primary()
	if p == "":
		return "t2"
	var d: int = tower.depth[p]
	return p + "m" if d >= Tower.BRANCH_STEPS else "%s%d" % [p, d + 1]


func _label(id: String) -> void:
	var lab: VBoxContainer = _labels[id]
	for c in lab.get_children():
		lab.remove_child(c)
		c.queue_free()
	var st := _state(id)
	var b: String = _parse(id)[0]
	var name_col := (_branch_color(b) if b != "" else UiKit.TEXT) if st in ["owned", "next", "short"] else Color(0.35, 0.42, 0.5)
	var node_name := Tower.trunk_name(int(_parse(id)[1])) if b == "" else str(_node(id).name)
	var n := UiKit.label(node_name, 12, name_col, HORIZONTAL_ALIGNMENT_CENTER)
	n.custom_minimum_size = Vector2(156, 0)
	n.clip_text = true
	lab.add_child(n)
	var status := ""
	var sc := UiKit.DIM
	match st:
		"owned":
			status = "OWNED"
			sc = UiKit.GOLD
		"next":
			status = "%d cr" % _cost(id)
			sc = UiKit.ACCENT
		"short":
			status = "%d cr" % _cost(id)
			sc = UiKit.BAD
		"blocked":
			status = "BLOCKED"
			sc = Color(0.35, 0.42, 0.5)
		"locked":
			status = "NEEDS RESEARCH"
			sc = Color(0.55, 0.6, 0.66)
		"future":
			status = "%d cr" % _cost(id)
			sc = Color(0.4, 0.47, 0.55)
	if _parse(id)[1] == 5 and st != "owned":
		status = "MASTERY · " + status
	var s := UiKit.label(status, 10, sc, HORIZONTAL_ALIGNMENT_CENTER)
	s.custom_minimum_size = Vector2(156, 0)
	lab.add_child(s)


func _show_detail(id: String) -> void:
	for c in _detail.get_children():
		_detail.remove_child(c)
		c.queue_free()
	var st := _state(id)
	var p := _parse(id)
	var b: String = p[0]
	var k: int = p[1]
	var nd := _node(id)
	var left := UiKit.vbox(4)
	left.size = Vector2(_detail.size.x, 150)
	var kind := "TRUNK  ·  %s" % Tower.trunk_name(k).to_upper()
	if b != "":
		kind = "BRANCH %s  ·  %s" % [b.to_upper(), "MASTERY" if k == 5 else ("T1  ·  SPECIALIZATION" if k == 1 else "T%d" % k)]
	var head := UiKit.hbox(12)
	head.add_child(UiKit.label(str(nd.name).to_upper(), 17, _branch_color(b) if b != "" else Draw.accent(tower.type)))
	head.add_child(UiKit.label(kind, 11, UiKit.DIM))
	left.add_child(head)
	left.add_child(UiKit.wrap_label(str(nd.blurb) if str(nd.blurb) != "" else str(tower.def.blurb), _detail.size.x, 13, UiKit.TEXT))
	if st == "locked":
		var node_name: String = Research.Data.NODES[Research.mastery_node(tower.type)].name
		left.add_child(UiKit.wrap_label("Research %s in the Research Lab [R] to unlock this tower's masteries. Research applies from your next run." % node_name, _detail.size.x, 12, UiKit.DIM))
	elif st == "blocked":
		left.add_child(UiKit.wrap_label(tower.block_reason(b) + ".", _detail.size.x, 12, UiKit.DIM))
	elif st in ["next", "short"]:
		var key: String = "U" if b == "" else KEYS[Tower.BRANCHES.find(b)]
		left.add_child(UiKit.label("%d cr  ·  buy it in the tower panel or with %s" % [_cost(id), key], 12, UiKit.GOLD if st == "next" else UiKit.BAD))
	var cur: Dictionary = tower.stats()
	var nxt: Dictionary = {}
	if st in ["next", "short"]:
		nxt = tower.next_stats(b)
	_detail.add_child(left)
	var grid := TowerInfo.stats_grid(cur, nxt, tower.is_beam(), 12, 12)
	grid.position = Vector2(0, 150)
	_detail.add_child(grid)


## Selects node `id` and plays its preview. Unreachable nodes say why instead.
func select(id: String) -> void:
	selected = id
	_shown = "?"
	if preview == null:
		return
	if UpgradeRules.reachable(tower, id):
		preview.show_node(screen.game, tower, id)
	else:
		var b: String = UpgradeRules.parse(id)[0]
		preview.show_node(screen.game, tower, "", "Not reachable on this tower: %s." % tower.block_reason(b).trim_suffix("."))


## Outlines node `id` for the tower panel (its hovered card); "" clears it.
func highlight(id: String) -> void:
	_pointed = id
