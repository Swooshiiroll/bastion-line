extends Control
## The Research Lab's content as a reusable panel (1552×552): a carousel of trees (Command + each
## tower), the focused one centred at full size with its neighbours smaller on either side; hex
## nodes joined by circuit lines, and a detail strip with Research / Reset. Left/Right or the mouse
## wheel change the focused tree, Up/Down pick a node in it, Enter researches it (as does the button
## or a second click on the selected node). Clicking a node in a side tree focuses that tree.
## Used full-screen from the main menu (ResearchLab.gd) and as an in-battle pop-out.

const UiKit = preload("res://scripts/ui/UiKit.gd")
const DrawControl = preload("res://scripts/ui/DrawControl.gd")
const ConfirmDialog = preload("res://scripts/ui/ConfirmDialog.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const Research = preload("res://scripts/core/Research.gd")
const Data = preload("res://data/research.gd")
const Towers = preload("res://data/towers.gd")
const TowerTrees = preload("res://data/tower_trees.gd")

signal bought(id: String)

const SIZE := Vector2(1552, 552)
const COL_W := 96.0
const COL_TOP := 30.0
const COL_H := 350.0
const ROW_Y := [82.0, 168.0, 254.0]
const SLOT_DX := 28.0
const NODE_R := 17.0
const BTN := Vector2(44, 44)
## Carousel: side trees are drawn at SIDE_SCALE, spaced SPACING apart; the focused one at full size.
const SIDE_SCALE := 0.72
const SPACING := 78.0
const STRIP_H := 388.0
## Column headers are narrow; full names are in each node's details.
const SHORT_NAMES := {
	"command": "COMMAND", "arrow": "PULSE", "cannon": "MORTAR", "frost": "CRYO", "sniper": "RAILGUN",
	"tesla": "ARC COIL", "laser": "LASER", "missile": "MISSILE", "amp": "AMPLIFIER", "flak": "FLAK",
	"sensor": "SENSOR", "gravity": "GRAVITON", "nullifier": "NULLIFIER", "nova": "NOVA", "drones": "DRONE BAY", "scrap": "SCRAPYARD",
}

var note := ""
var node_buttons := {}
var _modal_layer: CanvasLayer
var _modal: Control = null
var _rp_label: Label
var _detail: Control
var _buy_btn: Button
var _buy_reason: Label
var _cols: Array = []
var _selected := "cmd_funds"
var _armed := ""
var _hovered := ""
var _shown := "?"
var _strip: Control
## The focused tree (index into Data.TREE_ORDER) and its animated position.
var focus := 0
var _focus_f := 0.0


func _init(note_text := "") -> void:
	note = note_text


func _ready() -> void:
	theme = UiKit.theme()
	size = SIZE
	mouse_filter = Control.MOUSE_FILTER_PASS
	_modal_layer = CanvasLayer.new()
	_modal_layer.layer = 30
	add_child(_modal_layer)
	var note_l := UiKit.label(note, 14, UiKit.TEXT)
	note_l.position = Vector2(8, 2)
	add_child(note_l)
	_rp_label = UiKit.label("", 18, UiKit.GOLD, HORIZONTAL_ALIGNMENT_RIGHT)
	_rp_label.add_theme_constant_override("outline_size", 5)
	_rp_label.position = Vector2(SIZE.x - 420, 0)
	_rp_label.size = Vector2(412, 26)
	add_child(_rp_label)
	_strip = Control.new()
	_strip.position = Vector2(0, 0)
	_strip.size = Vector2(SIZE.x, STRIP_H)
	_strip.clip_contents = true
	_strip.mouse_filter = Control.MOUSE_FILTER_PASS
	_strip.gui_input.connect(_on_strip_input)
	add_child(_strip)
	for i in Data.TREE_ORDER.size():
		_column(Data.TREE_ORDER[i], 0.0)
	_layout(true)

	var panel := UiKit.panel(Rect2(0, 392, SIZE.x, 160), UiKit.BG, 10)
	add_child(panel)
	_detail = Control.new()
	_detail.position = Vector2(18, 12)
	_detail.size = Vector2(SIZE.x - 340, 140)
	_detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(_detail)
	_buy_btn = UiKit.button("", _buy_current, Vector2(270, 46))
	_buy_btn.position = Vector2(SIZE.x - 292, 16)
	_buy_btn.size = Vector2(270, 46)
	panel.add_child(_buy_btn)
	_buy_reason = UiKit.label("", 13, UiKit.DIM, HORIZONTAL_ALIGNMENT_CENTER)
	_buy_reason.position = Vector2(SIZE.x - 292, 66)
	_buy_reason.size = Vector2(270, 20)
	panel.add_child(_buy_reason)
	var reset := UiKit.button("Reset Research", _confirm_reset, Vector2(170, 34))
	reset.position = Vector2(SIZE.x - 192, 112)
	reset.size = Vector2(170, 34)
	reset.tooltip_text = "Refund every research point. Free, any time."
	panel.add_child(reset)
	refresh_all()


func _column(tree: String, x: float) -> void:
	var col := UiKit.panel(Rect2(x + 3, COL_TOP, COL_W - 6, COL_H), Color(0.03, 0.045, 0.07, 0.88), 8)
	col.pivot_offset = Vector2((COL_W - 6.0) / 2.0, 0.0)
	_strip.add_child(col)
	var cx := COL_W / 2.0 - 3.0
	var acc := _tree_color(tree)
	var icon := DrawControl.new(func(ci):
		if tree == "command":
			Draw.shield(ci, ci.size / 2.0, 10.0, acc)
		else:
			Draw.tower(ci, tree, 1, ci.size / 2.0, -PI / 2.0, 0.62, Time.get_ticks_msec() / 1000.0, 0.0)
	, Vector2(30, 30), true)
	icon.position = Vector2(cx - 15, 6)
	col.add_child(icon)
	var name_l := UiKit.label(str(SHORT_NAMES.get(tree, Research.tree_name(tree).to_upper())), 11, acc, HORIZONTAL_ALIGNMENT_CENTER)
	name_l.position = Vector2(0, 36)
	name_l.size = Vector2(COL_W - 6, 16)
	name_l.clip_text = true
	col.add_child(name_l)
	var prog := UiKit.label("", 10, UiKit.DIM, HORIZONTAL_ALIGNMENT_CENTER)
	prog.position = Vector2(0, COL_H - 22)
	prog.size = Vector2(COL_W - 6, 16)
	col.add_child(prog)
	var ids := Research.tree_nodes(tree)
	col.add_child(DrawControl.new(func(ci): _draw_links(ci, ids, cx, acc), Vector2(COL_W - 6, COL_H), true))
	for id in ids:
		var slot: Vector2i = Data.NODES[id].slot
		var center := Vector2(cx + slot.x * SLOT_DX, ROW_Y[slot.y])
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.flat = true
		var empty := StyleBoxEmpty.new()
		for s in ["normal", "hover", "pressed", "focus", "disabled"]:
			b.add_theme_stylebox_override(s, empty)
		b.position = center - BTN / 2.0
		b.size = BTN
		b.tooltip_text = "%s  (%d RP)\n%s" % [Data.NODES[id].name, int(Data.NODES[id].cost), Data.NODES[id].blurb]
		var node_id: String = id
		b.add_child(DrawControl.new(func(ci): _draw_node(ci, node_id, acc), BTN, true))
		b.mouse_entered.connect(func(): _hovered = node_id)
		b.mouse_exited.connect(func():
			if _hovered == node_id:
				_hovered = ""
		)
		b.pressed.connect(func(): _on_node_pressed(node_id))
		b.gui_input.connect(_on_strip_input)
		node_buttons[node_id] = b
		col.add_child(b)
	_cols.append([tree, prog, col])


func _tree_color(tree: String) -> Color:
	return UiKit.GOLD if tree == "command" else Draw.accent(tree)


func _state(id: String) -> String:
	var owned := SaveManager.research_owned()
	if owned.has(id):
		return "owned"
	if not Research.prerequisites_met(owned, id):
		return "locked"
	if SaveManager.research_available() >= int(Data.NODES[id].cost):
		return "ready"
	return "short"


func _draw_links(ci: Control, ids: Array, cx: float, acc: Color) -> void:
	var owned := SaveManager.research_owned()
	for id in ids:
		var slot: Vector2i = Data.NODES[id].slot
		var to := Vector2(cx + slot.x * SLOT_DX, ROW_Y[slot.y])
		for req in Data.NODES[id].requires:
			var ps: Vector2i = Data.NODES[req].slot
			var from := Vector2(cx + ps.x * SLOT_DX, ROW_Y[ps.y])
			var col := Color(0.25, 0.32, 0.4, 0.5)
			var w := 2.0
			if owned.has(req) and owned.has(id):
				col = Color(UiKit.GOLD, 0.9)
				w = 3.0
			elif owned.has(req):
				col = Color(acc, 0.65)
			# Circuit-trace style: vertical, then diagonal into the child.
			var mid := Vector2(from.x, lerpf(from.y, to.y, 0.45))
			ci.draw_polyline(PackedVector2Array([from, mid, to]), col, w, true)
			if owned.has(req) and not owned.has(id):
				var t := fmod(Time.get_ticks_msec() / 1000.0 * 0.8, 1.0)
				var p := from.lerp(mid, minf(1.0, t * 2.0)) if t < 0.5 else mid.lerp(to, (t - 0.5) * 2.0)
				ci.draw_circle(p, 2.2, Color(acc, 0.9))


func _draw_node(ci: Control, id: String, acc: Color) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var c := ci.size / 2.0
	var nd: Dictionary = Data.NODES[id]
	var mastery := bool(nd.effects.get("mastery", false))
	var r := NODE_R + (2.0 if mastery else 0.0)
	var st := _state(id)
	var glyph := Draw.skill_hex(ci, c, r, st, acc, t, mastery)
	Draw.research_glyph(ci, str(nd.icon), c, r * 0.62, glyph, t)
	# Cost pips along the bottom edge.
	var cost := int(nd.cost)
	for k in cost:
		var px := c.x + (float(k) - float(cost - 1) / 2.0) * 6.0
		var pip := PackedVector2Array([Vector2(px, c.y + r - 1.0), Vector2(px + 2.2, c.y + r + 1.4), Vector2(px, c.y + r + 3.8), Vector2(px - 2.2, c.y + r + 1.4)])
		ci.draw_colored_polygon(pip, UiKit.GOLD if st == "owned" or st == "ready" else Color(0.5, 0.45, 0.3))
	if id == _selected:
		Draw.outline(ci, c, Draw.ngon(6, 1.0, PI / 6.0), Color(1, 1, 1, 0.85), 1.2, 0.0, r + 5.0)


func _process(delta: float) -> void:
	if not is_equal_approx(_focus_f, float(focus)):
		_focus_f = move_toward(_focus_f, float(focus), maxf(0.05, absf(float(focus) - _focus_f)) * delta * 10.0)
		_layout()
	var want := _hovered if _hovered != "" else _selected
	if want != _shown:
		_show_detail(want)


func _unhandled_input(event: InputEvent) -> void:
	if _modal != null or not is_visible_in_tree() or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_ENTER, KEY_KP_ENTER:
			_buy_current()
		KEY_LEFT:
			set_focus(focus - 1)
		KEY_RIGHT:
			set_focus(focus + 1)
		KEY_UP:
			_step_node(-1)
		KEY_DOWN:
			_step_node(1)
		_:
			return
	get_viewport().set_input_as_handled()


## Places the tree columns around the focused one: full size in the middle, smaller and dimmer with
## distance on either side.
func _layout(snap := false) -> void:
	if snap:
		_focus_f = float(focus)
	for i in _cols.size():
		var col: Control = _cols[i][2]
		var d := float(i) - _focus_f
		var k := clampf(absf(d), 0.0, 1.0)
		var s := lerpf(1.0, SIDE_SCALE, k)
		var cx := SIZE.x / 2.0 + d * SPACING + signf(d) * k * (COL_W - SPACING) * 0.5
		col.scale = Vector2(s, s)
		col.position = Vector2(cx - (COL_W - 6.0) / 2.0, COL_TOP + (1.0 - s) * COL_H * 0.5)
		col.modulate = Color(1, 1, 1, clampf(1.0 - 0.13 * absf(d), 0.3, 1.0))
		col.z_index = 10 - int(absf(d))


## Focuses a tree by index (clamped) and selects its first node still to research.
func set_focus(i: int) -> void:
	var want := clampi(i, 0, Data.TREE_ORDER.size() - 1)
	if want == focus:
		return
	focus = want
	var owned := SaveManager.research_owned()
	var ids := _ordered_nodes(Data.TREE_ORDER[focus])
	_selected = ids[0]
	for id in ids:
		if not owned.has(id):
			_selected = id
			break
	_armed = ""
	_shown = "?"


## Focuses a tree by id (the tour and callers use this).
func focus_tree(tree: String) -> void:
	set_focus(Data.TREE_ORDER.find(tree))
	_layout(true)


## A tree's nodes from the root down, left to right.
func _ordered_nodes(tree: String) -> Array:
	var ids := Research.tree_nodes(tree)
	ids.sort_custom(func(a, b):
		var sa: Vector2i = Data.NODES[a].slot
		var sb: Vector2i = Data.NODES[b].slot
		return sa.y < sb.y or (sa.y == sb.y and sa.x < sb.x))
	return ids


## Up/Down: the previous or next node in the focused tree.
func _step_node(dir: int) -> void:
	var ids := _ordered_nodes(Data.TREE_ORDER[focus])
	var i := ids.find(_selected)
	_selected = ids[clampi((0 if i < 0 else i + dir), 0, ids.size() - 1)]
	_armed = _selected
	_hovered = ""
	_shown = "?"


## The mouse wheel over the trees scrolls the carousel.
func _on_strip_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			set_focus(focus - 1)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			set_focus(focus + 1)
			get_viewport().set_input_as_handled()

func has_modal() -> bool:
	return _modal != null


func _on_node_pressed(id: String) -> void:
	var ti := Data.TREE_ORDER.find(str(Data.NODES[id].tree))
	if ti != focus:
		focus = ti
	if _armed == id and _state(id) == "ready":
		_buy(id)
		return
	_selected = id
	_armed = id
	_shown = "?"


func _buy_current() -> void:
	var id := _hovered if _hovered != "" else _selected
	if id != "":
		_buy(id)


func _buy(id: String) -> void:
	_selected = id
	var why := SaveManager.buy_research(id)
	if why == "":
		Sfx.play("upgrade", -6.0, 0.0)
		bought.emit(id)
	else:
		Sfx.play("error", -6.0, 0.0)
	refresh_all()


func _confirm_reset() -> void:
	if SaveManager.research_owned().is_empty():
		return
	_show_modal(ConfirmDialog.new(
		"Refund all %d spent research points?\nYou can spend them again right away." % Research.spent(SaveManager.research_owned()),
		func():
			SaveManager.reset_research()
			Sfx.play("sell", -6.0, 0.0)
			_close_modal()
			refresh_all(),
		func(): _close_modal(),
		"Reset", "Cancel"))


func _show_modal(c: Control) -> void:
	_close_modal()
	_modal = c
	_modal_layer.add_child(c)


func _close_modal() -> void:
	if _modal != null:
		UiKit.dismiss(_modal)
		_modal = null


func refresh_all() -> void:
	var avail := SaveManager.research_available()
	_rp_label.text = "%d RP available   /   %d earned" % [avail, SaveManager.research_earned()]
	var owned := SaveManager.research_owned()
	for entry in _cols:
		var ids := Research.tree_nodes(entry[0])
		var n := ids.filter(func(i): return owned.has(i)).size()
		var prog: Label = entry[1]
		prog.text = "%d / %d done" % [n, ids.size()]
		prog.add_theme_color_override("font_color", UiKit.GOLD if n == ids.size() else UiKit.DIM)
	_shown = "?"


func _show_detail(id: String) -> void:
	_shown = id
	for c in _detail.get_children():
		_detail.remove_child(c)
		c.queue_free()
	if id == "" or not Data.NODES.has(id):
		_buy_btn.visible = false
		_buy_reason.text = ""
		return
	var nd: Dictionary = Data.NODES[id]
	var tree: String = nd.tree
	var acc := _tree_color(tree)
	var head := UiKit.label(str(nd.name).to_upper(), 24, acc)
	head.add_theme_constant_override("outline_size", 5)
	_detail.add_child(head)
	var kind := "MASTERY" if nd.effects.get("mastery", false) else "UPGRADE"
	var meta := UiKit.label("%s TREE   -   %s   -   %d RP" % [Research.tree_name(tree).to_upper(), kind, int(nd.cost)], 12, UiKit.DIM)
	meta.position = Vector2(0, 34)
	_detail.add_child(meta)
	var blurb := UiKit.label(nd.blurb, 16, UiKit.TEXT)
	blurb.position = Vector2(0, 54)
	_detail.add_child(blurb)
	if nd.effects.get("mastery", false):
		var branches: Array = TowerTrees.TREES[tree].branches
		for i in branches.size():
			var br: Dictionary = branches[i]
			var m: Dictionary = br.mastery
			var box := UiKit.vbox(0)
			box.position = Vector2(i * 300, 80)
			box.add_child(UiKit.label("%s  >  %s   (%d cr)" % [br.nodes[0].name, m.name, int(m.cost)], 13, Draw.accent(tree, str(br.id))))
			box.add_child(UiKit.wrap_label(m.blurb, 285, 12, UiKit.DIM))
			_detail.add_child(box)
	elif not nd.requires.is_empty():
		var req_names: Array = nd.requires.map(func(r): return str(Data.NODES[r].name))
		var req := UiKit.label("Requires: %s" % " or ".join(PackedStringArray(req_names)), 13, UiKit.DIM)
		req.position = Vector2(0, 84)
		_detail.add_child(req)

	_buy_btn.visible = true
	var st := _state(id)
	var why := Research.buy_block_reason(SaveManager.research_owned(), id, SaveManager.research_available())
	_buy_btn.disabled = why != ""
	_buy_btn.text = "Researched" if st == "owned" else "Research  -  %d RP  [Enter]" % int(nd.cost)
	_buy_reason.text = "" if st == "owned" else why
	if st == "ready":
		_buy_reason.text = "or click the selected node again"
	_buy_reason.add_theme_color_override("font_color", UiKit.BAD if st == "short" else UiKit.DIM)
