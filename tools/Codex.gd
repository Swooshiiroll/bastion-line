extends Node
## Exports the data and art for the printable codex (tools/codex.mjs builds the PDF from it):
## codex.json with every enemy's stats and round scaling plus tower metadata, and one PNG per
## sprite (each tower at T1, T2 and every specialization and mastery; each enemy).
## Launch with:  godot --path <project> -- --codex=<absolute output dir>

const Draw = preload("res://scripts/view/Draw.gd")
const Towers = preload("res://data/towers.gd")
const TowerTrees = preload("res://data/tower_trees.gd")
const Enemies = preload("res://data/enemies.gd")
const Waves = preload("res://data/waves.gd")
const Difficulty = preload("res://data/difficulty.gd")
const DrawNode = preload("res://scripts/view/DrawNode.gd")

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
	for type in TowerTrees.ORDER:
		var td: Dictionary = Towers.TOWERS[type]
		var branches: Array = []
		for b in TowerTrees.TREES[type].branches:
			branches.append({"id": b.id, "color": Draw.accent(type, str(b.id)).to_html(false)})
		towers.append({
			"id": type, "name": TowerTrees.TREES[type].name, "key": TowerTrees.TREES[type].key,
			"color": Draw.accent(type).to_html(false), "air": bool(td.get("air", false)),
			"ground": bool(td.get("ground", true)), "support": bool(td.get("support", false)), "economy": bool(td.get("economy", false)), "branches": branches,
		})
	var modes: Array = []
	for m in Difficulty.ORDER:
		var md: Dictionary = Difficulty.DIFFICULTIES[m]
		modes.append({"id": m, "name": md.name, "rounds": md.rounds, "lives": md.lives, "price": Difficulty.price(m),
			"medal_rp": md.medal_rp, "color": md.color.to_html(false)})
	var data := {
		"enemies": enemies, "towers": towers, "modes": modes, "sample_rounds": SAMPLE_ROUNDS,
		"bounty_exp": Waves.bounty_exp, "late_start": Waves.LATE_START, "late_growth": Waves.late_growth,
	}
	var f := FileAccess.open(out_dir + "/codex.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))
	f.close()


func _render() -> void:
	var queue: Array = []
	for type in TowerTrees.ORDER:
		queue.append({"kind": "t", "type": type, "tier": 1, "spec": "", "file": "t_%s_1" % type})
		queue.append({"kind": "t", "type": type, "tier": 2, "spec": "", "file": "t_%s_2" % type})
		for b in TowerTrees.TREES[type].branches:
			queue.append({"kind": "t", "type": type, "tier": 3, "spec": str(b.id), "file": "t_%s_%s" % [type, b.id]})
			queue.append({"kind": "t", "type": type, "tier": 4, "spec": str(b.id), "file": "t_%s_%s_m" % [type, b.id]})
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
