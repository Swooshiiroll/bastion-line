extends Node
## Exports the data and art for the printable codex (tools/codex.mjs builds the PDF from it): codex.json with every
## enemy (stats, role and tier, strength, round scaling, the Codex's ability lines, the modifiers it can roll), every
## tower's whole tree as the Codex shows it (Lore.tower_rows), the modifiers, roles, boss rounds and modes; and one PNG
## per sprite (each tower stock, retrofitted, at the end of each path and at each mastery; each enemy).
## Launch with:  godot --path <project> -- --codex=<absolute output dir>

const Draw = preload("res://scripts/view/Draw.gd")
const Towers = preload("res://data/towers.gd")
const TowerInfo = preload("res://scripts/ui/TowerInfo.gd")
const Enemies = preload("res://data/enemies.gd")
const Waves = preload("res://data/waves.gd")
const Difficulty = preload("res://data/difficulty.gd")
const DrawNode = preload("res://scripts/view/DrawNode.gd")
const Lore = preload("res://scripts/core/Lore.gd")
const Modifiers = preload("res://data/modifiers.gd")
const KnowledgePanel = preload("res://scripts/ui/KnowledgePanel.gd")
const Tower = preload("res://scripts/entities/Tower.gd")
const Game = preload("res://scripts/core/Game.gd")

const TILE := 360
const BG := Color(0.07, 0.09, 0.12)
const SAMPLE_ROUNDS := [1, 20, 40, 60, 80, 100, 120]

var out_dir := ""
## The sprite being drawn this frame: {kind, type, tier, spec}.
var item := {}
## Sprites render into a fixed-size offscreen viewport, so the window size and display scaling
## don't change the output.
var _vp: SubViewport
var _canvas: Node2D


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--codex="):
			out_dir = a.substr(8)
	DirAccess.make_dir_recursive_absolute(out_dir + "/icons")
	_vp = SubViewport.new()
	_vp.size = Vector2i(TILE, TILE)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_vp)
	_canvas = DrawNode.new()
	_canvas.draw_fn = _paint
	_vp.add_child(_canvas)
	_write_data()
	_render.call_deferred()


func _write_data() -> void:
	var enemies: Array = []
	for type in Enemies.ORDER:
		var d: Dictionary = Enemies.ENEMIES[type].duplicate()
		d["id"] = type
		d["color"] = Draw.ENEMY_COLOR.get(type, Color.WHITE).to_html(false)
		d["first_round"] = Waves.first_round(type)
		# The Codex's own lines (Lore), so the PDF says exactly what the game does.
		d["role_label"] = Enemies.role_label(d)
		d["strength"] = roundi(Enemies.strength(type))
		d["abilities"] = Lore.enemy_abilities(Enemies.ENEMIES[type])
		d["mods"] = Lore.enemy_mods(type).map(func(m): return str(Modifiers.MODIFIERS[m].name))
		d["hitters"] = Lore.hitters(Enemies.ENEMIES[type]).map(func(t): return str(Towers.def(t).name))
		var hp := {}
		var credits := {}
		for w in SAMPLE_ROUNDS:
			hp[str(w)] = roundi(float(d.hp) * Waves.hp_scale(w))
			credits[str(w)] = snappedf(float(d.bounty) * Waves.bounty_scale(w), 0.1)
		d["hp_by_round"] = hp
		d["bounty_by_round"] = credits
		d["speed_120"] = snappedf(float(d.speed) * Waves.speed_scale(120, bool(d.get("boss", false))), 0.1)
		enemies.append(d)
	var towers: Array = []
	for i in Towers.ORDER.size():
		var type: String = Towers.ORDER[i]
		var td: Dictionary = Towers.def(type)
		var tr: Dictionary = Towers.Rework.TREES[type]
		var beam := bool(td.get("beam", false))
		var branches: Array = []
		for p in tr.paths:
			branches.append({"id": p.key, "name": str(p.name), "color": Draw.accent(type, str(p.key)).to_html(false)})
		# Every row of its tree (Lore.tower_rows), with the stat line the Codex shows: full stats for the stock tower,
		# the changes for every step after.
		var rows: Array = []
		for r in Lore.tower_rows(type):
			var stats := TowerInfo.summary(r.stats, beam) if (r.prev as Dictionary).is_empty() else KnowledgePanel._changes(r.stats, r.prev, beam)
			rows.append({"label": str(r.label), "name": str(r.name), "cost": int(r.cost), "blurb": str(r.blurb), "stats": stats, "branch": str(r.branch)})
		towers.append({
			"id": type, "name": td.name, "class": str(td.get("class", "")), "cost": int(tr.cost), "blurb": str(td.blurb),
			"reach": TowerInfo.reach_text(type), "uncapped": bool(tr.get("uncapped", false)),
			"color": Draw.accent(type).to_html(false), "air": bool(td.get("air", false)),
			"ground": bool(td.get("ground", true)), "support": bool(td.get("support", false)), "economy": bool(td.get("economy", false)), "size": int(td.get("size", 1)),
			"branches": branches, "rows": rows,
		})
	var mods: Array = Lore.modifier_rows()
	var roles: Array = []
	for row in Lore.role_rows():
		var names := func(ids: Array) -> Array: return ids.map(func(t): return str(Enemies.ENEMIES[t].name))
		roles.append({"role": str(row.role).capitalize(), "tiers": (row.tiers as Array).map(func(c): return names.call(c)), "other": names.call(row.other)})
	var boss_rounds: Array = []
	for w in Waves.BOSS_ROUNDS:
		boss_rounds.append({"round": int(w), "line": (Waves.BOSS_ROUNDS[w] as Array).map(func(p): return "%s%s" % [Enemies.ENEMIES[p[0]].name, "" if int(p[1]) == 1 else " ×%d" % int(p[1])])})
	var hp_curve := {}
	for w in [1, 20, 40, 60, 80, 100, 120]:
		hp_curve[str(w)] = snappedf(Waves.hp_scale(w), 0.01)
	var modes: Array = []
	for m in Difficulty.ORDER:
		var md: Dictionary = Difficulty.DIFFICULTIES[m]
		modes.append({"id": m, "name": md.name, "rounds": md.rounds, "lives": md.lives, "price": Difficulty.price(m),
			"medal_rp": md.medal_rp, "color": md.color.to_html(false)})
	var data := {
		"enemies": enemies, "towers": towers, "modes": modes, "sample_rounds": SAMPLE_ROUNDS,
		"bounty_exp": Waves.bounty_exp, "late_start": Waves.LATE_START, "late_growth": Waves.late_growth,
		"modifiers": mods, "roles": roles, "boss_rounds": boss_rounds, "hp_curve": hp_curve,
		"leak_bands": Enemies.LEAK_BANDS, "secondary_cap": Tower.SECONDARY_CAP, "start_gold": Game.START_GOLD,
		"version": str(ProjectSettings.get_setting("application/config/version", "")),
	}
	var f := FileAccess.open(out_dir + "/codex.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))
	f.close()


func _render() -> void:
	var queue: Array = []
	# Each tower stock, retrofitted, and at the end of each path and its mastery (looks are "retrofit|a|b|c").
	for type in Towers.ORDER:
		queue.append({"kind": "t", "type": type, "tier": 1, "spec": "-1|0|0|0", "file": "t_%s_1" % type})
		queue.append({"kind": "t", "type": type, "tier": 2, "spec": "0|0|0|0", "file": "t_%s_2" % type})
		for k in ["a", "b", "c"]:
			for m in [4, 5]:
				var look := "-1|%d|%d|%d" % [m if k == "a" else 0, m if k == "b" else 0, m if k == "c" else 0]
				queue.append({"kind": "t", "type": type, "tier": m - 1, "spec": look, "file": "t_%s_%s%s" % [type, k, "_m" if m == 5 else ""]})
	for type in Enemies.ORDER:
		queue.append({"kind": "e", "type": type, "file": "e_%s" % type})
	for it in queue:
		item = it
		_canvas.queue_redraw()
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var img := _vp.get_texture().get_image()
		img.save_png(out_dir + "/icons/" + str(it.file) + ".png")
	print("codex: %d sprites and codex.json written to %s" % [queue.size(), out_dir])
	get_tree().quit()


func _paint(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(0, 0, TILE, TILE), BG)
	if item.is_empty():
		return
	var c := Vector2(TILE, TILE) / 2.0
	if item.kind == "t":
		Draw.tower(ci, item.type, int(item.tier), c, -PI / 3.0, 5.6, 1.3, 0.0, str(item.spec))
	else:
		var ed: Dictionary = Enemies.ENEMIES[item.type]
		var s := clampf(95.0 / float(ed.radius), 2.4, 12.0)
		Draw.enemy(ci, item.type, c, Vector2.RIGHT.rotated(-0.3), float(ed.radius), 1.3, false, 0.0, s)
