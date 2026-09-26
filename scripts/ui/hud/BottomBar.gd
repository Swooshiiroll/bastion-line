extends Control
## In-game bottom bar (1600×92): the two ability buttons, then a context card that follows what the
## player is doing: the selected tower (identity, path strip, stats, upgrade/tree/target/sell),
## the tower being built or hovered in the shop, a hovered enemy, orbital-strike aiming, or hints.

const UiKit = preload("res://scripts/ui/UiKit.gd")
const DrawControl = preload("res://scripts/ui/DrawControl.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const TowerInfo = preload("res://scripts/ui/TowerInfo.gd")
const Tower = preload("res://scripts/entities/Tower.gd")
const Towers = preload("res://data/towers.gd")
const Abilities = preload("res://data/abilities.gd")
const Research = preload("res://scripts/core/Research.gd")
const Game = preload("res://scripts/core/Game.gd")

const HEIGHT := 92.0
const CTX_X := 190.0

var hud
var screen
var ability_btns := {}
var _ability_status := {}
var ctx: Control
var ctx_key := ""
# Live pieces of the current context, updated every frame.
var _live_labels := {}
var _cost_buttons: Array = []
var _sell_btn: Button = null
var _status_label: Label = null


var _bg: Control
var _line: ColorRect

func _ready() -> void:
	size = Vector2(UiKit.SCREEN.x, HEIGHT)
	position = Vector2(0, UiKit.SCREEN.y - HEIGHT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_bg = UiKit.panel(Rect2(Vector2.ZERO, size))
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)
	var line := ColorRect.new()
	_line = line
	line.color = Color(UiKit.ACCENT, 0.5)
	line.size = Vector2(size.x, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line)
	for i in Abilities.ORDER.size():
		var id: String = Abilities.ORDER[i]
		var b := _ability_button(id)
		b.position = Vector2(8 + i * 90, 8)
		add_child(b)
		ability_btns[id] = b
	var sep := ColorRect.new()
	sep.color = UiKit.BORDER
	sep.position = Vector2(CTX_X - 8, 10)
	sep.size = Vector2(1, HEIGHT - 20)
	add_child(sep)
	ctx = Control.new()
	ctx.position = Vector2(CTX_X, 0)
	ctx.size = Vector2(size.x - CTX_X - 8, HEIGHT)
	get_viewport().size_changed.connect(_fit_view)
	_fit_view.call_deferred()
	ctx.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(ctx)


func _ability_button(id: String) -> Button:
	var a: Dictionary = Abilities.ABILITIES[id]
	var b := UiKit.button("", Callable(screen, "use_ability").bind(id), Vector2(84, 78))
	b.size = Vector2(84, 78)
	b.tooltip_text = "%s  [%s]\n%s\nCooldown %ds." % [a.name, a.key, a.blurb, roundi(screen.game.ability_cooldown(id))]
	var icon := DrawControl.new(func(ci): Draw.ability_icon(ci, id, ci.size / 2.0, 12.0, Time.get_ticks_msec() / 1000.0), Vector2(30, 30), true)
	icon.position = Vector2(27, 4)
	b.add_child(icon)
	var name_l := UiKit.label("%s  %s" % [a.short, a.key], 13, UiKit.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	name_l.position = Vector2(0, 36)
	name_l.size = Vector2(84, 18)
	b.add_child(name_l)
	var status := UiKit.label("", 11, UiKit.DIM, HORIZONTAL_ALIGNMENT_CENTER)
	status.position = Vector2(0, 56)
	status.size = Vector2(84, 16)
	b.add_child(status)
	_ability_status[id] = status
	var shade := DrawControl.new(func(ci):
		var g = screen.game
		var frac := clampf(float(g.ability_cd.get(id, 0.0)) / g.ability_cooldown(id), 0.0, 1.0)
		if frac > 0.0:
			ci.draw_rect(Rect2(Vector2.ZERO, Vector2(ci.size.x, ci.size.y * frac)), Color(0, 0, 0, 0.5))
		if screen.world.ability_target == id:
			ci.draw_rect(Rect2(Vector2(1, 1), ci.size - Vector2(2, 2)), UiKit.GOLD, false, 2.0)
	, Vector2(84, 78), true)
	b.add_child(shade)
	return b


# --- Per-frame -------------------------------------------------------------------------------

func refresh(_delta: float) -> void:
	var g = screen.game
	for id in ability_btns:
		var status: Label = _ability_status[id]
		var cd := float(g.ability_cd.get(id, 0.0))
		if g.is_over():
			status.text = ""
		elif cd > 0.0:
			status.text = "%d s" % ceili(cd)
			status.add_theme_color_override("font_color", UiKit.DIM)
		elif g.state == Game.State.WAVE:
			status.text = "READY"
			status.add_theme_color_override("font_color", UiKit.GOOD)
		else:
			status.text = "next round"
			status.add_theme_color_override("font_color", UiKit.DIM)
		ability_btns[id].disabled = not g.ability_ready(id)

	var w = screen.world
	var key := "idle"
	var t = w.selected_tower
	var build: String = w.build_type if w.build_type != "" else hud.hovered_build
	if w.ability_target == "meteor":
		key = "meteor"
	elif t != null:
		key = "t:%d:%d:%s:%s:%d:%.2f%.2f%.2f" % [t.get_instance_id(), t.trunk, str(t.depth), t.mastered, t.mode, t.buff_dmg, t.buff_rate, t.buff_range]
	elif build != "":
		key = "b:" + build
	elif w.hover_enemy != null and w.hover_enemy.alive:
		key = "e:%d" % w.hover_enemy.id
	elif w.mouse_in_field and g.tower_at.has(w.hover_cell):
		key = "h:%d" % g.tower_at[w.hover_cell].get_instance_id()
	elif w.mouse_in_field and _tile_kind(w.hover_cell) != "":
		var hc: Vector2i = w.hover_cell
		key = "tile:%d:%d:%s" % [hc.x, hc.y, _tile_kind(hc)]
	if key != ctx_key:
		ctx_key = key
		_rebuild(key)
	_update_live()


func _clear() -> void:
	for c in ctx.get_children():
		ctx.remove_child(c)
		c.queue_free()
	_live_labels = {}
	_cost_buttons = []
	_sell_btn = null
	_status_label = null


func _rebuild(key: String) -> void:
	_clear()
	var w = screen.world
	var g = screen.game
	if key == "meteor":
		_hint(["Click the battlefield to call the Orbital Strike.", "Right-click or Esc cancels."])
	elif key.begins_with("t:"):
		_tower_card(w.selected_tower)
	elif key.begins_with("b:"):
		_build_card(key.substr(2))
	elif key.begins_with("e:"):
		_enemy_card()
	elif key.begins_with("tile:"):
		_tile_card(w.hover_cell)
	elif key.begins_with("h:"):
		var ht = g.tower_at[w.hover_cell]
		_hint(["%s (tier %d): %d kills." % [ht.display_name(), ht.tier, ht.kills], "Click to select it."])
	else:
		_hint(["B  open the shop", "Space  launch the round", "Click a tower for its details and upgrades", "Esc  menu"])


func _hint(parts: Array) -> void:
	var row := UiKit.hbox(28)
	row.position = Vector2(8, 34)
	for i in parts.size():
		var p: String = parts[i]
		var sp := p.find("  ")
		if sp > 0:
			var h := UiKit.hbox(6)
			h.add_child(UiKit.label(p.substr(0, sp), 15, UiKit.GOLD))
			h.add_child(UiKit.label(p.substr(sp + 2), 15, UiKit.DIM))
			row.add_child(h)
		else:
			row.add_child(UiKit.label(p, 15, UiKit.DIM))
	ctx.add_child(row)


func _chip(text: String, kind: String, tip := "") -> PanelContainer:
	var pc := PanelContainer.new()
	var col := UiKit.DIM
	var border := Color(0.14, 0.2, 0.25)
	var bg := Color(0.03, 0.05, 0.07)
	var bw := 1
	match kind:
		"own":
			col = UiKit.GOLD
			border = UiKit.GOLD
			bg = Color(0.14, 0.12, 0.05)
		"cur":
			col = Color(1, 1, 1)
			border = Color(1, 1, 1)
			bg = Color(0.12, 0.12, 0.14)
			bw = 2
		"next":
			col = UiKit.ACCENT
			border = UiKit.ACCENT
		"gone":
			col = Color(0.3, 0.38, 0.45)
		"lock":
			col = Color(0.5, 0.56, 0.62)
	var sb := UiKit.box(bg, border, 5, bw, 7.0)
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	pc.add_theme_stylebox_override("panel", sb)
	var l := UiKit.label(("× " if kind == "gone" else "") + text, 12, col)
	pc.add_child(l)
	pc.tooltip_text = tip
	pc.mouse_filter = Control.MOUSE_FILTER_PASS
	return pc


func _arrow() -> Label:
	return UiKit.label("▸", 12, Color(0.3, 0.38, 0.45))


func _tower_card(t) -> void:
	var g = screen.game
	var d: Dictionary = t.def
	var type: String = t.type
	var tier: int = t.tier
	var spec: String = t.spec
	var acc: Color = Draw.accent(type, spec)
	var icon := DrawControl.new(func(ci): Draw.tower(ci, type, tier, ci.size / 2.0, -PI / 2.0, 1.15, Time.get_ticks_msec() / 1000.0, 0.0, spec), Vector2(58, 58), true)
	icon.position = Vector2(0, 18)
	ctx.add_child(icon)
	var id_box := UiKit.vbox(0)
	id_box.position = Vector2(64, 4)
	id_box.size = Vector2(250, 86)
	id_box.add_child(UiKit.label(t.display_name().to_upper(), 20, acc if spec != "" else UiKit.TEXT))
	var sub := "Tier %d  ·  %s" % [t.trunk, d.name] if t.started.is_empty() else "%s  ·  %s" % [" + ".join(PackedStringArray(t.started.map(func(b): return "%s%d" % [b.to_upper(), t.depth[b]]))), d.name]
	if tier >= Tower.MASTERY_TIER:
		sub = "MASTERY  ·  %s" % d.name
	id_box.add_child(UiKit.label(sub, 12, UiKit.GOLD if tier >= 3 else UiKit.DIM))
	var kills := UiKit.label("", 12, UiKit.DIM)
	id_box.add_child(kills)
	_live_labels["kills"] = kills
	var summ := UiKit.label(TowerInfo.summary(t.stats(), t.is_beam()), 12, Color(0.72, 0.81, 0.88))
	summ.clip_text = true
	summ.custom_minimum_size = Vector2(250, 0)
	var extras: Array = []
	if t.buff_dmg > 0.0 or t.buff_rate > 0.0 or t.buff_range > 0.0:
		extras.append("Pylon boost active")
	var rl := TowerInfo.research_line(t.mods)
	if rl != "":
		extras.append(rl)
	summ.tooltip_text = "\n".join(PackedStringArray([summ.text] + extras))
	summ.mouse_filter = Control.MOUSE_FILTER_PASS
	id_box.add_child(summ)
	ctx.add_child(id_box)

	# Branch strip: the trunk, then each branch with its progress.
	var strip := UiKit.hbox(5)
	strip.position = Vector2(326, 10)
	strip.add_child(UiKit.label("PATH", 11, UiKit.DIM))
	strip.add_child(_chip("T1", "own"))
	strip.add_child(_arrow())
	if t.trunk < 2:
		strip.add_child(_chip("T2 · %d cr" % t.upgrade_cost(), "next"))
	else:
		strip.add_child(_chip("T2", "own"))
	for b in Tower.BRANCHES:
		strip.add_child(_arrow())
		var br: Dictionary = t.branch(b)
		var dep: int = t.depth[b]
		var why: String = t.block_reason(b)
		var label := "%s %s" % [b.to_upper(), br.nodes[0].name]
		var state := "future"
		if t.mastered and t.primary() == b:
			label += " · " + str(br.mastery.name)
			state = "cur"
		elif dep > 0:
			var cap := Tower.SECONDARY_CAP if (t.locked_in() and b != t.primary()) else Tower.BRANCH_STEPS
			label += " %d/%d" % [dep, cap]
			state = "cur" if b == t.primary() else "own"
		elif t.trunk >= 2 and why == "":
			state = "next"
		elif why.begins_with("Locked") or why.begins_with("Blocked"):
			state = "gone"
		strip.add_child(_chip(label, state, br.nodes[0].blurb if why == "" else why))
	ctx.add_child(strip)

	# Action buttons: the next upgrade on each branch that can take one.
	var row := UiKit.hbox(8)
	row.position = Vector2(326, 44)
	if t.trunk < 2:
		var c1: int = t.upgrade_cost()
		var up := UiKit.button("Upgrade to tier 2  ·  %d cr  [U]" % c1, Callable(screen, "upgrade_selected").bind(0), Vector2(0, 34))
		row.add_child(up)
		_cost_buttons.append([up, c1])
	else:
		for i in Tower.BRANCHES.size():
			var b: String = Tower.BRANCHES[i]
			var nd: Dictionary = t.next_node(b)
			if nd.is_empty():
				continue
			var cst: int = t.upgrade_cost(b)
			var is_m: bool = int(t.depth[b]) >= Tower.BRANCH_STEPS
			var bb := UiKit.button("%s%s  ·  %d cr  [%s]" % ["Mastery: " if is_m else "", nd.name, cst, ["U", "I", "O"][i]], Callable(screen, "upgrade_selected").bind(i), Vector2(0, 34))
			bb.add_theme_color_override("font_color", UiKit.GOLD if is_m else Draw.accent(type, str(t.branch(b).id)))
			bb.tooltip_text = str(nd.blurb)
			row.add_child(bb)
			_cost_buttons.append([bb, cst])
		var p: String = t.primary()
		if p != "" and int(t.depth[p]) >= Tower.BRANCH_STEPS and not t.mastered and not t.mastery_unlocked():
			var node_name: String = Research.Data.NODES[Research.mastery_node(type)].name
			var lock := UiKit.label("Mastery needs %s research" % node_name, 12, UiKit.DIM)
			row.add_child(lock)

	var tree := UiKit.button("Tree  [E]", Callable(screen, "open_tree"), Vector2(0, 34))
	row.add_child(tree)
	if not t.is_support() and not (type in ["frost", "gravity"]):
		var tb := UiKit.button("Target: %s  [T]" % Tower.MODE_NAMES[t.mode], Callable(screen, "cycle_target"), Vector2(0, 34))
		tb.tooltip_text = "Which enemy in range this tower attacks"
		row.add_child(tb)
	_sell_btn = UiKit.button("Sell +%d  [X]" % g.sell_value(t), Callable(screen, "sell_selected"), Vector2(0, 34))
	row.add_child(_sell_btn)
	for b in row.get_children():
		if b is Button:
			(b as Button).add_theme_font_size_override("font_size", 14)
	ctx.add_child(row)


func _build_card(type: String) -> void:
	var g = screen.game
	var d: Dictionary = Towers.TOWERS[type]
	var icon := DrawControl.new(func(ci): Draw.tower(ci, type, 1, ci.size / 2.0, -PI / 2.0, 1.15, Time.get_ticks_msec() / 1000.0, 0.0), Vector2(58, 58), true)
	icon.position = Vector2(0, 18)
	ctx.add_child(icon)
	var id_box := UiKit.vbox(0)
	id_box.position = Vector2(64, 6)
	id_box.add_child(UiKit.label(str(d.name).to_upper(), 20, Draw.accent(type)))
	var idx := Towers.ORDER.find(type)
	id_box.add_child(UiKit.label("%d cr  ·  %s  ·  key %s" % [g.tower_cost(type), TowerInfo.reach_text(type), TowerInfo.build_key(idx)], 12, UiKit.GOLD))
	var research := TowerInfo.research_line(g.tower_mods[type])
	if research != "":
		id_box.add_child(UiKit.label(research, 12, UiKit.GOOD))
	ctx.add_child(id_box)
	var right := UiKit.vbox(2)
	right.position = Vector2(326, 8)
	right.add_child(UiKit.label(TowerInfo.summary(g.level_stats(type, 1), bool(d.get("beam", false))), 13, Color(0.72, 0.81, 0.88)))
	var bl := UiKit.label(d.blurb, 12, UiKit.DIM)
	bl.clip_text = true
	bl.custom_minimum_size = Vector2(1060, 0)
	bl.tooltip_text = d.blurb
	bl.mouse_filter = Control.MOUSE_FILTER_PASS
	right.add_child(bl)
	var specs: Array = Tower.tree(type).branches.map(func(b): return str(b.nodes[0].name))
	right.add_child(UiKit.label("Branches: %s%s" % [" / ".join(PackedStringArray(specs)), "   ·   masteries unlocked" if g.mastery_unlocked(type) else ""], 12, UiKit.GOLD))
	_status_label = UiKit.label("", 12, UiKit.GOOD)
	right.add_child(_status_label)
	ctx.add_child(right)


## "high" | "power" | "rubble" | "gate" | "sludge" | "shock" | "" for the tile under the mouse.
func _tile_kind(c: Vector2i) -> String:
	var g = screen.game
	if g.grid.gate_group_at(c) >= 0:
		return "gate"
	match g.grid.tile_at(c):
		"H":
			return "high"
		"P":
			return "power"
		"R":
			return "rubble" if g.has_rubble(c) else ""
		"~":
			return "sludge"
		"^":
			return "shock"
	return ""


const TILE_INFO := {
	"high": ["HIGH GROUND", "Towers built here get +15% range. Great spots: they often reach two lanes at once."],
	"power": ["POWER NODE", "Towers built here deal +15% damage. Pylons and sensors gain nothing from the socket."],
	"rubble": ["RUBBLE", "Blocks building until it's cleared. Click it to clear it."],
	"gate": ["SWITCH GATE", "Picks the branch arriving enemies take: Split sends them down both. Click to switch (6 s cooldown). Enemies already past the fork keep going."],
	"sludge": ["SLUDGE", "Ground enemies crossing it are slowed 30% (bosses resist half). Flyers skim over it."],
	"shock": ["SHOCK STRIP", "Ground enemies on it lose 4% of their max HP per second (bosses 1%), ignoring armor."],
}


func _tile_card(c: Vector2i) -> void:
	var g = screen.game
	var kind := _tile_kind(c)
	var info: Array = TILE_INFO[kind]
	var col: Color = {"high": Color(0.6, 0.85, 1.0), "power": UiKit.GOLD, "rubble": Color(1.0, 0.65, 0.35), "gate": UiKit.GOLD,
		"sludge": Color(0.4, 0.95, 0.6), "shock": Color(1.0, 0.9, 0.35)}[kind]
	var icon := DrawControl.new(func(ci):
		var ctr: Vector2 = ci.size / 2.0
		match kind:
			"high":
				Draw.research_glyph(ci, "range", ctr, 18.0, col)
			"power":
				Draw.research_glyph(ci, "damage", ctr, 18.0, col)
			"rubble":
				Draw.research_glyph(ci, "credits", ctr, 18.0, col)
			"gate":
				Draw.research_glyph(ci, "push", ctr, 18.0, col)
			"sludge":
				Draw.research_glyph(ci, "slow", ctr, 18.0, col)
			"shock":
				Draw.research_glyph(ci, "chain", ctr, 18.0, col)
	, Vector2(58, 58))
	icon.position = Vector2(0, 18)
	ctx.add_child(icon)
	var box := UiKit.vbox(2)
	box.position = Vector2(64, 10)
	box.add_child(UiKit.label(info[0], 20, col))
	var sub := UiKit.label("", 13, UiKit.GOLD)
	box.add_child(sub)
	_live_labels["tile"] = [sub, kind, c]
	var bl := UiKit.label(info[1], 13, UiKit.DIM)
	bl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bl.custom_minimum_size = Vector2(1300, 0)
	box.add_child(bl)
	ctx.add_child(box)


func _enemy_card() -> void:
	var e = screen.world.hover_enemy
	var etype: String = e.type
	var r: float = e.radius
	var icon := DrawControl.new(func(ci): Draw.enemy(ci, etype, ci.size / 2.0, Vector2.RIGHT, r, Time.get_ticks_msec() / 1000.0, false, 0.0, minf(1.0, 22.0 / r)), Vector2(58, 58), true)
	icon.position = Vector2(0, 18)
	ctx.add_child(icon)
	var id_box := UiKit.vbox(0)
	id_box.position = Vector2(64, 8)
	id_box.add_child(UiKit.label(str(e.def.name).to_upper(), 20, Draw.ENEMY_COLOR.get(etype, UiKit.TEXT)))
	var stats := UiKit.label("", 13, UiKit.TEXT)
	id_box.add_child(stats)
	_live_labels["enemy"] = stats
	var bl := UiKit.label(e.def.blurb, 12, UiKit.DIM)
	bl.clip_text = true
	bl.custom_minimum_size = Vector2(1320, 0)
	id_box.add_child(bl)
	ctx.add_child(id_box)


func _update_live() -> void:
	var w = screen.world
	var g = screen.game
	var t = w.selected_tower
	if _live_labels.has("kills") and t != null:
		(_live_labels.kills as Label).text = "Kills %d  ·  Damage %d" % [t.kills, int(t.damage_dealt)]
	if _live_labels.has("enemy") and w.hover_enemy != null:
		var e = w.hover_enemy
		var extra := ""
		if e.flying:
			extra += "  ·  flying"
		if e.max_shield > 0.0:
			extra += "  ·  barrier %d" % ceili(e.shield)
		if e.slow_amount > 0.0:
			extra += "  ·  slowed %d%%" % roundi(e.slow_amount * 100.0)
		if e.armor_shred > 0.0 and e.armor > 0.0:
			extra += "  ·  shredded"
		(_live_labels.enemy as Label).text = "HP %d / %d   ·   Armor %d   ·   Speed %d%s" % [ceili(e.hp), ceili(e.max_hp), int(e.effective_armor()), int(e.speed), extra]
	if _live_labels.has("tile"):
		var tl: Array = _live_labels.tile
		var sub: Label = tl[0]
		var c: Vector2i = tl[2]
		match tl[1]:
			"rubble":
				var why: String = g.rubble_error(c)
				sub.text = "Clear for %d cr" % g.rubble_cost() + ("" if why == "" else "   (%s)" % why)
			"gate":
				var gi: int = g.grid.gate_group_at(c)
				var cd := float(g.gate_cd[gi])
				sub.text = "Now: %s" % g.gate_label(gi) + ("   ·   ready" if cd <= 0.0 else "   ·   recharging %ds" % ceili(cd))
			"high":
				sub.text = "+15% range"
			"power":
				sub.text = "+15% damage"
			_:
				sub.text = "Lane hazard"
	for entry in _cost_buttons:
		var b: Button = entry[0]
		b.disabled = g.gold < int(entry[1]) or g.is_over()
	if _sell_btn != null:
		_sell_btn.disabled = g.is_over()
	if _status_label != null:
		if w.build_type != "" and w.mouse_in_field:
			var err: String = g.placement_error(w.build_type, w.hover_cell)
			_status_label.text = err if err != "" else "Click to deploy here.  Shift+click keeps building.  Right-click cancels."
			_status_label.add_theme_color_override("font_color", UiKit.BAD if err != "" else UiKit.GOOD)
		elif w.build_type != "":
			_status_label.text = "Click a tile on the battlefield to deploy."
			_status_label.add_theme_color_override("font_color", UiKit.BLUE)
		else:
			_status_label.text = ""


## Spans the whole window width at its bottom edge (the layout itself is centred).
func _fit_view() -> void:
	var off := UiKit.view_offset()
	var w := UiKit.view_size().x
	position = Vector2(-off.x, UiKit.SCREEN.y - HEIGHT + off.y)
	size.x = w
	_bg.size.x = w
	_line.size.x = w
	ctx.size.x = w - CTX_X - 8
