extends Panel
## The live tuner's content (issue #80, design/live_tuner.md), shown in TunerWindow beside the game: a readout of the run,
## a tab per area of design/balance.md listing its groups (an enemy, a tower, a script's rules) with their numbers and
## derived values, and the change list with revert and export.

const Tuner = preload("res://scripts/dev/Tuner.gd")
const UiKit = preload("res://scripts/ui/UiKit.gd")
const Game = preload("res://scripts/core/Game.gd")
const Enemies = preload("res://data/enemies.gd")

const TABS := [["enemies", "Enemies"], ["modifiers", "Modifiers"], ["towers", "Towers"], ["waves", "Waves"],
	["economy", "Economy"], ["difficulty", "Difficulty"], ["research", "Research"], ["abilities", "Abilities"], ["rules", "Rules"]]
## Rounds in the Waves formulas' table.
const ROUNDS := [1, 10, 20, 40, 60, 80, 100, 120]
const READOUT_EVERY := 0.3

## The top row's right end, for the window's own controls (its Dock switch).
var toolbar: HBoxContainer
var _readout: Label
var _field: Label
var _search: LineEdit
var _tabs: TabContainer
## Per area: {list: ItemList, rows: VBoxContainer, groups: [shown group ids], group: the selected one}.
var _areas := {}
## Per area, its groups in order and their fields: area → [[group, [fields]]].
var _groups := {}
var _changes: VBoxContainer
var _status: Label
var _clock := 0.0


func _init() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	for f in Tuner.fields():
		var list: Array = _groups.get(f.area, [])
		if list.is_empty() or list[-1][0] != f.group:
			list.append([f.group, []])
		list[-1][1].append(f)
		_groups[f.area] = list
	var margin := MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	add_child(margin)
	var col := UiKit.vbox(6)
	margin.add_child(col)

	var top := UiKit.hbox(8)
	top.add_child(UiKit.label("LIVE TUNER", 18, UiKit.ACCENT))
	_search = LineEdit.new()
	_search.placeholder_text = "Search (name or number's key)"
	_search.size_flags_horizontal = SIZE_EXPAND_FILL
	_search.clear_button_enabled = true
	_search.text_changed.connect(func(_t): _fill_lists())
	top.add_child(_search)
	toolbar = UiKit.hbox(6)
	top.add_child(toolbar)
	col.add_child(top)

	var read := PanelContainer.new()
	read.add_theme_stylebox_override("panel", UiKit.box(UiKit.BG_LIGHT, UiKit.BORDER, 4, 1, 8.0))
	var rv := UiKit.vbox(2)
	_readout = UiKit.label("", 13, UiKit.TEXT)
	_field = UiKit.label("", 13, UiKit.DIM)
	_field.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rv.add_child(_readout)
	rv.add_child(_field)
	read.add_child(rv)
	col.add_child(read)

	_tabs = TabContainer.new()
	_tabs.size_flags_vertical = SIZE_EXPAND_FILL
	_tabs.tab_changed.connect(func(_i): _show_current())
	col.add_child(_tabs)
	for t in TABS:
		_tabs.add_child(_area_tab(t[0], t[1]))
	_tabs.add_child(_changes_tab())
	_fill_lists()


func _area_tab(area: String, title: String) -> Control:
	var split := HSplitContainer.new()
	split.name = title
	var list := ItemList.new()
	list.custom_minimum_size = Vector2(180, 0)
	list.add_theme_font_size_override("font_size", 14)
	list.item_selected.connect(func(i): _select(area, i))
	split.add_child(list)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var rows := UiKit.vbox(3)
	rows.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.add_child(rows)
	split.add_child(scroll)
	_areas[area] = {"list": list, "rows": rows, "groups": [], "group": ""}
	return split


func _changes_tab() -> Control:
	var v := UiKit.vbox(6)
	v.name = "Changes"
	var bar := UiKit.hbox(6)
	bar.add_child(UiKit.button("Export", export, Vector2(90, 30)))
	bar.add_child(UiKit.button("Open folder", open_folder, Vector2(110, 30)))
	bar.add_child(UiKit.button("Revert all", _revert_all, Vector2(100, 30)))
	v.add_child(bar)
	_status = UiKit.label("", 13, UiKit.DIM)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_status)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_changes = UiKit.vbox(3)
	_changes.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.add_child(_changes)
	v.add_child(scroll)
	return v


func _process(delta: float) -> void:
	_clock -= delta
	if _clock <= 0.0:
		_clock = READOUT_EVERY
		_refresh_readout()


# --- Lists and groups ------------------------------------------------------------------------------

## Fills every area's group list, keeping only groups that match the search.
func _fill_lists() -> void:
	var q := _search.text.strip_edges().to_lower()
	for area in _areas:
		var a: Dictionary = _areas[area]
		var list: ItemList = a.list
		list.clear()
		a.groups = []
		for g in _groups.get(area, []):
			var gname := Tuner.group_name(g[0])
			if q != "" and not _matches(q, g[0], gname, g[1]):
				continue
			list.add_item(gname)
			list.set_item_tooltip(list.item_count - 1, g[0])
			a.groups.append(g[0])
		var at: int = a.groups.find(a.group)
		if at < 0 and not a.groups.is_empty():
			at = 0
		a.group = a.groups[at] if at >= 0 else ""
		if at >= 0:
			list.select(at)
	_show_current()


func _matches(q: String, group: String, gname: String, fields: Array) -> bool:
	if q in group.to_lower() or q in gname.to_lower():
		return true
	for f in fields:
		if q in str(f.key).to_lower() or q in Tuner.field_name(f).to_lower():
			return true
	return false


func _select(area: String, i: int) -> void:
	_areas[area].group = _areas[area].groups[i]
	_show_current()


## The current tab's area, or "" on the Changes tab.
func _area() -> String:
	return TABS[_tabs.current_tab][0] if _tabs.current_tab < TABS.size() else ""


## Rebuilds what the current tab shows (its group's rows, or the change list).
func _show_current() -> void:
	var area := _area()
	if area == "":
		_fill_changes()
		return
	var a: Dictionary = _areas[area]
	var rows: VBoxContainer = a.rows
	for c in rows.get_children():
		c.queue_free()
	var fields: Array = []
	for g in _groups.get(area, []):
		if g[0] == a.group:
			fields = g[1]
	if fields.is_empty():
		return
	var q := _search.text.strip_edges().to_lower()
	if area == "towers":
		for r in Tuner.tower_rows(a.group):
			var head := "%s  %s   =DPS %s · =Spent %d" % [r.id, r.name, _dps(r.dps), r.spent]
			if r.dps >= 0.0:
				head += " · %.2f /100cr" % (r.dps / maxf(1.0, r.spent) * 100.0)
			rows.add_child(_head(head))
			for f in fields:
				if f.node == r.id:
					rows.add_child(_edit_row(f, q))
		return
	if str(a.group).begins_with("ENEMIES."):
		var id := str(a.group).get_slice(".", 1)
		var e := Tuner.enemy_info(id)
		rows.add_child(_head("=Strength %.1f · =Leak %d · %s" % [e.strength, e.leak, Enemies.role_label(Enemies.ENEMIES[id])]))
		rows.add_child(_head("=HP  r20 %.0f · r60 %.0f · r100 %.0f" % [e.hp[20], e.hp[60], e.hp[100]]))
		rows.add_child(_head("=Credits  r20 %.1f · r60 %.1f · r100 %.1f" % [e.credits[20], e.credits[60], e.credits[100]]))
	for f in fields:
		rows.add_child(_edit_row(f, q))
	if a.group == "Waves":
		rows.add_child(_head("Round · =HP × · =Speed × · =Budget · =Elites · =Bounty × · =Clear"))
		for r in ROUNDS:
			var w := Tuner.round_info(r)
			rows.add_child(_head("%d · %.2f · %.2f · %.1f · %d%% · %.2f · %d" % [r, w.hp, w.speed, w.budget, roundi(w.elite * 100.0), w.bounty, w.clear]))


func _head(text: String) -> Label:
	var l := UiKit.label(text, 13, UiKit.BLUE)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


## One number: its name, − and + nudges, the value (Enter or leaving the box applies it), what balance.md has if it
## changed, and a revert button.
func _edit_row(f: Dictionary, q: String) -> HBoxContainer:
	var key: String = f.key
	var row := UiKit.hbox(4)
	var hit: bool = q != "" and (q in key.to_lower() or q in Tuner.field_name(f).to_lower())
	var lbl := UiKit.label(Tuner.field_name(f), 14, UiKit.GOLD if hit else UiKit.TEXT)
	lbl.size_flags_horizontal = SIZE_EXPAND_FILL
	lbl.clip_text = true
	lbl.tooltip_text = key
	lbl.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_child(lbl)
	var edit := LineEdit.new()
	edit.custom_minimum_size = Vector2(84, 0)
	edit.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	edit.text = _fmt(Tuner.value(key))
	edit.text_submitted.connect(func(_t): _commit(key, edit))
	edit.focus_exited.connect(func(): _commit(key, edit))
	row.add_child(UiKit.button("−", func(): _nudge(key, -1.0), Vector2(26, 26)))
	row.add_child(edit)
	row.add_child(UiKit.button("+", func(): _nudge(key, 1.0), Vector2(26, 26)))
	var was := UiKit.label("", 12, UiKit.GOLD)
	was.custom_minimum_size = Vector2(76, 0)
	var rev := UiKit.button("↺", func(): _revert(key), Vector2(26, 26))
	rev.tooltip_text = "Back to balance.md's value"
	if Tuner.changed(key):
		was.text = "was %s" % _fmt(Tuner.original(key))
	else:
		rev.modulate.a = 0.0
		rev.disabled = true
	row.add_child(was)
	row.add_child(rev)
	return row


func _commit(key: String, edit: LineEdit) -> void:
	if not is_instance_valid(edit):
		return
	var t := edit.text.strip_edges()
	if not t.is_valid_float():
		edit.text = _fmt(Tuner.value(key))
		return
	if is_equal_approx(t.to_float(), float(Tuner.value(key))):
		return
	Tuner.set_value(key, t.to_float())
	_after_edit()


## + or −: one step of the number's size (1 for whole numbers under 100; for 0.25, 0.01).
func _nudge(key: String, dir: float) -> void:
	var v = Tuner.value(key)
	var mag := absf(float(v))
	var step := 0.01 if mag == 0.0 else pow(10.0, floorf(log(mag) / log(10.0)) - 1.0)
	if v is int:
		step = maxf(1.0, step)
	Tuner.set_value(key, float(v) + dir * step)
	_after_edit()


func _revert(key: String) -> void:
	Tuner.revert(key)
	_after_edit()


func _revert_all() -> void:
	Tuner.revert_all()
	_after_edit()


func _after_edit() -> void:
	_show_current.call_deferred()
	_refresh_readout()


static func _fmt(v) -> String:
	if v is int:
		return str(v)
	var s := String.num(float(v), 6)
	return s if "." in s else s + ".0"


static func _dps(d: float) -> String:
	return "-" if d < 0.0 else "%.1f" % d


# --- Changes and export ----------------------------------------------------------------------------

func _fill_changes() -> void:
	for c in _changes.get_children():
		c.queue_free()
	var names := {}
	for f in Tuner.fields():
		names[f.key] = "%s · %s" % [Tuner.group_name(f.group), ("%s %s" % [f.node, f.label]) if f.has("node") else Tuner.field_name(f)]
	var ch := Tuner.changes()
	_changes.add_child(UiKit.label("No changes" if ch.is_empty() else "%d changed" % ch.size(), 14, UiKit.DIM))
	for c in ch:
		var row := UiKit.hbox(6)
		var l := UiKit.label("%s:  %s → %s" % [names.get(c.key, c.key), _fmt(c.old), _fmt(c.new)], 14)
		l.size_flags_horizontal = SIZE_EXPAND_FILL
		l.clip_text = true
		l.tooltip_text = c.key
		l.mouse_filter = Control.MOUSE_FILTER_PASS
		row.add_child(l)
		var key: String = c.key
		row.add_child(UiKit.button("↺", func(): _revert(key), Vector2(26, 26)))
		_changes.add_child(row)


## Saves the changes as a tweaks file; on a repo run, also writes them into design/balance.md (tools/balance.mjs --apply).
func export() -> void:
	var path := Tuner.export_changes()
	if path == "":
		_status.text = "Nothing to export."
		return
	_status.text = "Saved %s" % ProjectSettings.globalize_path(path)
	if Tuner.in_repo():
		var res: Array = Tuner.apply_in_repo(path)
		_status.text += "\n%s\n%s" % ["Written into design/balance.md (check, test and commit it):" if res[0] else "Not applied:", res[1]]
	else:
		_status.text += "\nApply it in the repo: node tools/balance.mjs --apply <file>"
	_after_edit()


func open_folder() -> void:
	DirAccess.make_dir_recursive_absolute("user://tweaks")
	OS.shell_open(ProjectSettings.globalize_path("user://tweaks"))


# --- Readout -----------------------------------------------------------------------------------------

func _refresh_readout() -> void:
	var g = Tuner.game
	if g == null:
		_readout.text = "No run in play. Edits still change the numbers, and the next run starts tuned."
		_field.text = ""
		return
	var now := maxi(1, g.wave)
	var nxt: int = g.wave + 1
	var a := Tuner.round_info(now)
	var b := Tuner.round_info(nxt)
	var state := "running" if g.state == Game.State.WAVE else ("over" if g.is_over() else "cleared")
	_readout.text = "\n".join([
		"Round %d %s · next %d%s" % [g.wave, state, nxt, "   TUNED: not saved, earns nothing" if g.tuned else ""],
		"HP ×%.2f → %.2f · Speed ×%.2f → %.2f · Budget %.0f → %.0f · Elites %d%% → %d%%" % [a.hp, b.hp, a.speed, b.speed, a.budget, b.budget, roundi(a.elite * 100.0), roundi(b.elite * 100.0)],
		"Credits %d · Shields %d/%d · wave and round changes apply from the next round" % [g.gold, g.lives, g.max_lives],
	])
	var by := {}
	for e in g.enemies:
		if not e.alive or e.hologram:
			continue
		var s: Array = by.get(e.type, [0, 0.0])
		by[e.type] = [s[0] + 1, s[1] + e.hp]
	var parts: Array = []
	for t in by:
		parts.append("%s ×%d (%.0f HP)" % [Enemies.ENEMIES[t].name, by[t][0], by[t][1]])
	_field.text = "On the field: " + (" · ".join(parts) if not parts.is_empty() else "none")
