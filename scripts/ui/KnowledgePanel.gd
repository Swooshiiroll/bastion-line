extends Control
## The Codex: an in-game encyclopedia of towers, enemies, effects, battlefield features and rules.
## Category tabs and a search box on the left, the entry list in the middle, the entry on the right.
## Towers and enemies are generated from the game data (scripts/core/Lore.gd); everything else comes
## from data/glossary.gd with its numbers filled in from the constants.
## Up / Down move through the list, Tab changes category, / or Ctrl+F searches. Used full-screen from
## the main menu (KnowledgeBase.gd) and as an in-battle pop-out (hud/KnowledgePopOut.gd).

const UiKit = preload("res://scripts/ui/UiKit.gd")
const DrawControl = preload("res://scripts/ui/DrawControl.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const TowerInfo = preload("res://scripts/ui/TowerInfo.gd")
const Lore = preload("res://scripts/core/Lore.gd")
const Glossary = preload("res://data/glossary.gd")
const Towers = preload("res://data/towers.gd")
const Trees = preload("res://data/tower_trees.gd")
const Enemies = preload("res://data/enemies.gd")
const Waves = preload("res://data/waves.gd")

const LEFT_W := 190.0
const LIST_W := 250.0
const GAP := 12.0
const ROW_H := 34.0
const SAMPLE_ROUNDS := [20, 40, 60, 80, 100, 120]

var panel_size := Vector2(1552, 552)
var category := "towers"
## The entry shown on the right (e.g. "tower:arrow", "enemy:grunt", "g:armor").
var current := ""
var _entries: Array = []
var _visible_ids: Array = []
var _tab_buttons := {}
var _list: VBoxContainer
var _list_scroll: ScrollContainer
var _detail: VBoxContainer
var _detail_scroll: ScrollContainer
var _search: LineEdit
var _row_buttons := {}


func _init(size_in := Vector2(1552, 552)) -> void:
	panel_size = size_in


func _ready() -> void:
	theme = UiKit.theme()
	size = panel_size
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build_index()
	var left := UiKit.vbox(6)
	left.position = Vector2.ZERO
	left.size = Vector2(LEFT_W, panel_size.y)
	add_child(left)
	_search = LineEdit.new()
	_search.placeholder_text = "Search  ( / )"
	_search.custom_minimum_size = Vector2(LEFT_W, 34)
	_search.text_changed.connect(func(_t): _refresh_list())
	left.add_child(_search)
	for cat in Glossary.CATEGORIES:
		var c: String = cat
		var b := UiKit.button(str(Glossary.CATEGORY_NAMES[c]), func(): set_category(c), Vector2(LEFT_W, 38))
		left.add_child(b)
		_tab_buttons[c] = b
	var hint := UiKit.wrap_label("Up / Down: entries\nTab: next category\n/ or Ctrl+F: search", LEFT_W, 11, UiKit.DIM)
	left.add_child(hint)

	_list_scroll = ScrollContainer.new()
	_list_scroll.position = Vector2(LEFT_W + GAP, 0)
	_list_scroll.size = Vector2(LIST_W, panel_size.y)
	_list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_list_scroll)
	_list = UiKit.vbox(3)
	_list.custom_minimum_size = Vector2(LIST_W - 14, 0)
	_list_scroll.add_child(_list)

	var detail_panel := UiKit.panel(Rect2(LEFT_W + LIST_W + GAP * 2, 0, panel_size.x - LEFT_W - LIST_W - GAP * 2, panel_size.y), UiKit.BG, 10)
	add_child(detail_panel)
	_detail_scroll = ScrollContainer.new()
	_detail_scroll.position = Vector2(16, 12)
	_detail_scroll.size = detail_panel.size - Vector2(24, 24)
	_detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_panel.add_child(_detail_scroll)
	_detail = UiKit.vbox(8)
	_detail.custom_minimum_size = Vector2(_detail_scroll.size.x - 18, 0)
	_detail_scroll.add_child(_detail)
	set_category(category)


## Every entry: {id, title, category, search}.
func _build_index() -> void:
	_entries.clear()
	for t in Towers.ORDER:
		var tr: Dictionary = Trees.TREES[t]
		var words: Array = [str(Towers.TOWERS[t].blurb)]
		for b in tr.branches:
			for nd in b.nodes:
				words.append(str(nd.name))
			words.append(str(b.mastery.name))
		_entries.append({"id": "tower:" + t, "title": str(Towers.TOWERS[t].name), "category": "towers", "search": " ".join(PackedStringArray(words))})
	for e in Enemies.ORDER:
		var d: Dictionary = Enemies.ENEMIES[e]
		_entries.append({"id": "enemy:" + e, "title": str(d.name), "category": "enemies", "search": str(d.blurb) + " " + " ".join(PackedStringArray(Lore.enemy_abilities(d)))})
	for g in Glossary.ENTRIES:
		var ge: Dictionary = Glossary.ENTRIES[g]
		_entries.append({"id": "g:" + g, "title": str(ge.title), "category": str(ge.category), "search": Lore.text(g)})


func entry_ids() -> Array:
	return _entries.map(func(e): return e.id)


func set_category(cat: String) -> void:
	category = cat
	for c in _tab_buttons:
		var b: Button = _tab_buttons[c]
		b.add_theme_color_override("font_color", UiKit.GOLD if c == cat and _search.text == "" else UiKit.TEXT)
	_search.text = ""
	_refresh_list()
	if not _visible_ids.is_empty() and not _visible_ids.has(current):
		show_entry(_visible_ids[0])


## Jumps straight to an entry (deep links from the battle and See-also buttons).
func open_entry(id: String) -> void:
	for e in _entries:
		if e.id == id:
			category = e.category
			_search.text = ""
			for c in _tab_buttons:
				(_tab_buttons[c] as Button).add_theme_color_override("font_color", UiKit.GOLD if c == category else UiKit.TEXT)
			_refresh_list()
			show_entry(id)
			return


func _refresh_list() -> void:
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()
	_row_buttons.clear()
	var q := _search.text.strip_edges().to_lower()
	_visible_ids.clear()
	for e in _entries:
		if q == "":
			if e.category != category:
				continue
		elif not (str(e.title).to_lower().contains(q) or str(e.search).to_lower().contains(q)):
			continue
		_visible_ids.append(e.id)
		_list.add_child(_list_row(e))
	_mark_current()


func _list_row(e: Dictionary) -> Button:
	var id: String = e.id
	var b := UiKit.button("", func(): show_entry(id), Vector2(LIST_W - 14, ROW_H))
	var icon := _mini_icon(id)
	if icon != null:
		icon.position = Vector2(4, 2)
		b.add_child(icon)
	var l := UiKit.label(str(e.title), 13, _entry_color(id))
	l.position = Vector2(40, 7)
	l.size = Vector2(LIST_W - 60, 20)
	l.clip_text = true
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(l)
	_row_buttons[id] = b
	return b


func _mini_icon(id: String) -> Control:
	var parts := id.split(":")
	if parts[0] == "tower":
		var t := parts[1]
		return DrawControl.new(func(ci): Draw.tower(ci, t, 1, ci.size / 2.0, -PI / 2.0, 0.55, 0.0, 0.0), Vector2(30, 30))
	if parts[0] == "enemy":
		var et := parts[1]
		var r := float(Enemies.ENEMIES[et].radius)
		return DrawControl.new(func(ci): Draw.enemy(ci, et, ci.size / 2.0, Vector2.RIGHT, r, 0.0, false, 0.0, clampf(11.0 / r, 0.3, 1.2)), Vector2(30, 30))
	return null


func _entry_color(id: String) -> Color:
	var parts := id.split(":")
	if parts[0] == "tower":
		return Draw.accent(parts[1])
	if parts[0] == "enemy":
		return Draw.ENEMY_COLOR.get(parts[1], UiKit.TEXT)
	return UiKit.TEXT


func _mark_current() -> void:
	for id in _row_buttons:
		(_row_buttons[id] as Button).add_theme_color_override("font_color", UiKit.GOLD if id == current else UiKit.TEXT)
		(_row_buttons[id] as Button).modulate = Color(1, 1, 1) if id == current else Color(0.85, 0.88, 0.92)


func show_entry(id: String) -> void:
	current = id
	_mark_current()
	for c in _detail.get_children():
		_detail.remove_child(c)
		c.queue_free()
	var parts := id.split(":")
	match parts[0]:
		"tower":
			_show_tower(parts[1])
		"enemy":
			_show_enemy(parts[1])
		"g":
			_show_glossary(parts[1])
	_detail_scroll.scroll_vertical = 0


# --- Entry pages -------------------------------------------------------------------------------

func _header(icon: Control, title: String, col: Color, sub: String, blurb: String) -> void:
	var h := UiKit.hbox(16)
	if icon != null:
		h.add_child(icon)
	var v := UiKit.vbox(2)
	var t := UiKit.label(title.to_upper(), 26, col)
	t.add_theme_constant_override("outline_size", 5)
	v.add_child(t)
	if sub != "":
		v.add_child(UiKit.label(sub, 13, UiKit.GOLD))
	if blurb != "":
		v.add_child(UiKit.wrap_label(blurb, _detail.custom_minimum_size.x - 150, 14, UiKit.TEXT))
	h.add_child(v)
	_detail.add_child(h)


func _section(text: String) -> void:
	var l := UiKit.label(text.to_upper(), 13, UiKit.ACCENT)
	l.add_theme_constant_override("outline_size", 3)
	_detail.add_child(l)


func _para(text: String, size := 14, col := UiKit.TEXT) -> void:
	_detail.add_child(UiKit.wrap_label(text, _detail.custom_minimum_size.x, size, col))


func _links(title: String, ids: Array) -> void:
	var valid := ids.filter(func(i): return entry_ids().has(i))
	if valid.is_empty():
		return
	_section(title)
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 6)
	flow.add_theme_constant_override("v_separation", 6)
	flow.custom_minimum_size = Vector2(_detail.custom_minimum_size.x, 0)
	for i in valid:
		var target: String = i
		var name := ""
		for e in _entries:
			if e.id == target:
				name = e.title
		var b := UiKit.button(name, func(): open_entry(target), Vector2(0, 30))
		b.add_theme_color_override("font_color", _entry_color(target))
		flow.add_child(b)
	_detail.add_child(flow)


func _show_tower(type: String) -> void:
	var d: Dictionary = Towers.TOWERS[type]
	var tr: Dictionary = Trees.TREES[type]
	var beam := bool(d.get("beam", false))
	var icon := DrawControl.new(func(ci): Draw.tower(ci, type, 2, ci.size / 2.0, -PI / 3.0, 3.0, Time.get_ticks_msec() / 1000.0, 0.0), Vector2(110, 110), true)
	var idx := Towers.ORDER.find(type)
	var size_note := "  ·  takes 2×2 tiles" if int(d.get("size", 1)) > 1 else ""
	_header(icon, str(d.name), Draw.accent(type), "Key %s  ·  %d cr  ·  %s%s" % [TowerInfo.build_key(idx), int(tr.tiers[0].cost), TowerInfo.reach_text(type), size_note], str(d.blurb))
	_section("Upgrade path")
	var rows := Lore.tower_rows(type)
	var cur_branch := "?"
	for r in rows:
		if str(r.branch) != cur_branch:
			cur_branch = str(r.branch)
			if cur_branch != "":
				var bc := Draw.accent(type, cur_branch)
				var bh := UiKit.hbox(8)
				var spec: String = cur_branch
				bh.add_child(DrawControl.new(func(ci): Draw.tower(ci, type, 3, ci.size / 2.0, -PI / 3.0, 1.1, Time.get_ticks_msec() / 1000.0, 0.0, spec), Vector2(36, 36), true))
				var bl := UiKit.label("%s  ·  %s" % [str(r.label).substr(0, 1), str(r.name).to_upper()], 15, bc)
				bl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
				bh.add_child(bl)
				for b in tr.branches:
					if str(b.id) == cur_branch and bool(b.get("attack", false)):
						var note := UiKit.label("changes the attack: as a secondary it adds its attack alongside the primary's", 11, UiKit.DIM)
						note.size_flags_vertical = Control.SIZE_SHRINK_CENTER
						bh.add_child(note)
				_detail.add_child(bh)
		_detail.add_child(_upgrade_row(r, beam, type))
	var see: Array = ["g:trees", "g:primary", "g:mastery", "g:targeting", "g:selling"]
	if int(d.get("size", 1)) > 1:
		see.append("g:footprint")
	_links("See also", see)


func _upgrade_row(r: Dictionary, beam: bool, type: String) -> Control:
	var row := UiKit.hbox(10)
	var lab := UiKit.label(str(r.label), 12, UiKit.DIM)
	lab.custom_minimum_size = Vector2(92, 0)
	row.add_child(lab)
	var col := Draw.accent(type, str(r.branch)) if str(r.branch) != "" else UiKit.TEXT
	var name_l := UiKit.label(str(r.name), 13, col)
	name_l.custom_minimum_size = Vector2(168, 0)
	name_l.clip_text = true
	row.add_child(name_l)
	var cost := UiKit.label("%d cr" % int(r.cost), 12, UiKit.GOLD)
	cost.custom_minimum_size = Vector2(62, 0)
	row.add_child(cost)
	var v := UiKit.vbox(0)
	var w := _detail.custom_minimum_size.x - 92 - 168 - 62 - 30
	var stats_text := TowerInfo.summary(r.stats, beam) if (r.prev as Dictionary).is_empty() else _changes(r.stats, r.prev, beam)
	v.add_child(UiKit.wrap_label(stats_text, w, 12, Color(0.72, 0.81, 0.88)))
	v.add_child(UiKit.wrap_label(str(r.blurb), w, 12, UiKit.DIM))
	row.add_child(v)
	return row


## "Damage 16 → 19  ·  Range 160 → 175": every stat the step changes, and new mechanics it adds.
static func _changes(cur: Dictionary, prev: Dictionary, beam: bool) -> String:
	var parts: Array = []
	for r in TowerInfo.rows_for(cur, beam):
		var k: String = r[1]
		if k == "":
			continue
		var f: String = r[2]
		if f in ["yes", "pierce", "line"]:
			if not prev.get(k, false):
				parts.append(str(r[0]))
			continue
		if not prev.has(k):
			parts.append("%s %s" % [r[0], TowerInfo.fmt(cur[k], f)])
		elif not is_equal_approx(float(prev[k]), float(cur[k])):
			parts.append("%s %s → %s" % [r[0], TowerInfo.fmt(prev[k], f), TowerInfo.fmt(cur[k], f)])
	return "No stat changes: see the description." if parts.is_empty() else "  ·  ".join(PackedStringArray(parts))


func _show_enemy(type: String) -> void:
	var d: Dictionary = Enemies.ENEMIES[type]
	var r := float(d.radius)
	var icon := DrawControl.new(func(ci): Draw.enemy(ci, type, ci.size / 2.0, Vector2.RIGHT.rotated(-0.3), r, Time.get_ticks_msec() / 1000.0, false, 0.0, clampf(40.0 / r, 1.0, 5.0)), Vector2(110, 110), true)
	var cls := ("Flying boss" if d.get("flying", false) else "Boss") if d.get("boss", false) else ("Flyer" if d.get("flying", false) else "Ground")
	_header(icon, str(d.name), Draw.ENEMY_COLOR.get(type, UiKit.TEXT), "%s  ·  first seen in round %d" % [cls, Waves.first_round(type)], str(d.blurb))
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 18)
	for pair in [["Health (round 1)", str(roundi(float(d.hp)))], ["Speed", "%d px/s" % roundi(float(d.speed))], ["Armor", str(roundi(float(d.get("armor", 0.0))))],
			["Credits", str(int(d.bounty))], ["Leak cost", "%d shield%s" % [int(d.lives), "" if int(d.lives) == 1 else "s"]], ["Size", "%d px" % roundi(r)]]:
		grid.add_child(UiKit.label(pair[0], 12, UiKit.DIM))
		grid.add_child(UiKit.label(pair[1], 13, UiKit.TEXT))
	_detail.add_child(grid)
	var ab := Lore.enemy_abilities(d)
	if not ab.is_empty():
		_section("Abilities")
		for a in ab:
			_para("•  " + str(a), 13)
	_section("Health and credits by round")
	var table := GridContainer.new()
	table.columns = SAMPLE_ROUNDS.size() + 1
	table.add_theme_constant_override("h_separation", 22)
	table.add_child(UiKit.label("Round", 12, UiKit.DIM))
	for w in SAMPLE_ROUNDS:
		table.add_child(UiKit.label(str(w), 12, UiKit.DIM))
	table.add_child(UiKit.label("Health", 12, UiKit.DIM))
	for w in SAMPLE_ROUNDS:
		table.add_child(UiKit.label(str(roundi(float(d.hp) * Waves.hp_scale(w))), 12, UiKit.TEXT))
	table.add_child(UiKit.label("Credits", 12, UiKit.DIM))
	for w in SAMPLE_ROUNDS:
		table.add_child(UiKit.label("%.1f" % (float(d.bounty) * Waves.bounty_scale(w)), 12, UiKit.GOLD))
	_detail.add_child(table)
	_links("Hit by", Lore.hitters(d).map(func(t): return "tower:" + t))
	_links("How to deal with it", Lore.enemy_topics(d).map(func(g): return "g:" + g))


func _show_glossary(id: String) -> void:
	var ge: Dictionary = Glossary.ENTRIES[id]
	_header(null, str(ge.title), UiKit.ACCENT, str(Glossary.CATEGORY_NAMES[ge.category]), "")
	_para(Lore.text(id), 15)
	_links("See also", (ge.see as Array).map(func(g): return "g:" + g))


# --- Keys --------------------------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree() or not (event is InputEventKey) or not event.pressed:
		return
	if _search.has_focus():
		if event.keycode == KEY_DOWN or event.keycode == KEY_ENTER:
			_search.release_focus()
			get_viewport().set_input_as_handled()
		return
	match event.keycode:
		KEY_UP:
			_step(-1)
		KEY_DOWN:
			_step(1)
		KEY_TAB:
			var i := Glossary.CATEGORIES.find(category)
			set_category(Glossary.CATEGORIES[(i + (-1 if event.shift_pressed else 1) + Glossary.CATEGORIES.size()) % Glossary.CATEGORIES.size()])
		KEY_SLASH:
			_search.grab_focus()
		KEY_F:
			if not event.ctrl_pressed:
				return
			_search.grab_focus()
		_:
			return
	get_viewport().set_input_as_handled()


func _step(dir: int) -> void:
	if _visible_ids.is_empty():
		return
	var i := _visible_ids.find(current)
	show_entry(_visible_ids[clampi((0 if i < 0 else i + dir), 0, _visible_ids.size() - 1)])
	var b: Control = _row_buttons.get(current)
	if b != null:
		_list_scroll.ensure_control_visible(b)
