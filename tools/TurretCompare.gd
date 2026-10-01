extends Node
## --perf-compare: draws every tower's stock model and each branch at its mastery, at two aims,
## twice into identical offscreen images: once in full vector drawing and once through Draw's
## turret cache. Compares them tower by tower, saves both (full above, cached below) to
## res://screenshots/turret_compare.png and exits 1 if any tower differs by more than MAX_DIFF
## (mean RGB difference over its cell, 0-765), else 0.

const Draw = preload("res://scripts/view/Draw.gd")
const DrawNode = preload("res://scripts/view/DrawNode.gd")
const BRANCHES := {
	"arrow": ["gatling", "shredder", "flechette"], "cannon": ["siege", "napalm", "buster"], "frost": ["stasis", "shatter", "cryolock"],
	"sniper": ["deadeye", "lance", "nullslug"], "tesla": ["storm", "overload", "ionstorm"], "laser": ["prism", "focus", "sweeper"],
	"missile": ["swarm", "hellfire", "cluster"], "amp": ["overclock", "array", "suppression"], "flak": ["skyshred", "burst", "dualpurpose"],
	"sensor": ["deepscan", "painter", "disruptor"], "gravity": ["repulsor", "crush", "well"], "nullifier": ["purge", "dampener", "feedback"],
	"nova": ["supernova", "pulsereactor", "solarflare"], "drones": ["interceptors", "bombers", "hunters"], "scrap": ["mint", "collector", "depot"],
}
const AIMS := [-0.5, 2.4]
const SIZE := Vector2i(1700, 1500)
const CELL := 100.0
const MAX_DIFF := 12.0
var views: Array = []
var frames := 0


func _ready() -> void:
	for cached in [false, true]:
		var view := SubViewport.new()
		view.size = SIZE
		view.disable_3d = true
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		var node := DrawNode.new()
		node.draw_fn = func(ci: CanvasItem): _draw_grid(ci, cached)
		view.add_child(node)
		add_child(view)
		views.append([view, node])


func _process(_delta: float) -> void:
	frames += 1
	for v in views:
		v[1].queue_redraw()
	if frames == 10:
		_finish.call_deferred()


## One cell per look and aim: 8 per row (4 looks x 2 aims), one row per tower type. Cells are two
## apart and alternate rows are staggered, so long barrels and mastery rings stay in their cell.
func _cells() -> Array:
	var out := []
	var row := 0
	for type in BRANCHES:
		var looks: Array = [[1, ""]]
		for sp in BRANCHES[type]:
			looks.append([6, sp])
		var col := 0
		for look in looks:
			for aim in AIMS:
				out.append({"type": type, "tier": look[0], "spec": look[1], "aim": aim,
					"pos": Vector2(CELL * 0.5 + float(col) * CELL * 2.0 + float(row % 2) * CELL, CELL * 0.5 + float(row) * CELL)})
				col += 1
		row += 1
	return out


func _draw_grid(ci: CanvasItem, cached: bool) -> void:
	ci.draw_rect(Rect2(Vector2.ZERO, Vector2(SIZE)), Color(0.07, 0.09, 0.11))
	for cell in _cells():
		var s := 0.9 if cell.type == "drones" or cell.type == "scrap" else 1.0
		Draw.turret_cache = cached
		Draw.tower(ci, cell.type, cell.tier, cell.pos, cell.aim, s, 1.234, 0.05, cell.spec, cell.spec)
		Draw.turret_cache = false


func _finish() -> void:
	await RenderingServer.frame_post_draw
	var full: Image = views[0][0].get_texture().get_image()
	var fast: Image = views[1][0].get_texture().get_image()
	var worst := 0.0
	var worst_name := ""
	var bad := []
	for cell in _cells():
		var c: Vector2 = cell.pos
		var sum := 0.0
		var n := 0
		for y in range(int(c.y - CELL * 0.45), int(c.y + CELL * 0.45), 2):
			for x in range(int(c.x - CELL * 0.45), int(c.x + CELL * 0.45), 2):
				if x < 0 or y < 0 or x >= SIZE.x or y >= SIZE.y:
					continue
				var p := full.get_pixel(x, y)
				var q := fast.get_pixel(x, y)
				sum += (absf(p.r - q.r) + absf(p.g - q.g) + absf(p.b - q.b)) * 255.0
				n += 1
		var d := sum / maxf(1.0, float(n))
		var name := "%s t%d %s aim %.1f" % [cell.type, cell.tier, cell.spec, cell.aim]
		if d > worst:
			worst = d
			worst_name = name
		if d > MAX_DIFF:
			bad.append("%s (%.1f)" % [name, d])
	var both := Image.create(SIZE.x, SIZE.y * 2, false, full.get_format())
	both.blit_rect(full, Rect2i(Vector2i.ZERO, SIZE), Vector2i.ZERO)
	both.blit_rect(fast, Rect2i(Vector2i.ZERO, SIZE), Vector2i(0, SIZE.y))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://screenshots"))
	both.save_png(ProjectSettings.globalize_path("res://screenshots/turret_compare.png"))
	print("TURRET COMPARE: %d towers, worst %.1f (%s), limit %.1f" % [_cells().size(), worst, worst_name, MAX_DIFF])
	for b in bad:
		print("  DIFFERS: ", b)
	print("TURRET COMPARE: ", "OK" if bad.is_empty() else "%d DIFFER" % bad.size())
	get_tree().quit(0 if bad.is_empty() else 1)
