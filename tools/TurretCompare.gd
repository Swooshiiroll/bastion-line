extends Node2D
## --perf-compare: draws every tower's stock model and each branch at its mastery, at two aims, in
## full vector drawing (left of each pair) and through Draw's turret cache (right), saves the
## result to res://screenshots/turret_compare.png and quits. Pairs should look identical.

const Draw = preload("res://scripts/view/Draw.gd")
const BRANCHES := {
	"arrow": ["gatling", "shredder", "flechette"], "cannon": ["siege", "napalm", "buster"], "frost": ["stasis", "shatter", "cryolock"],
	"sniper": ["deadeye", "lance", "nullslug"], "tesla": ["storm", "overload", "ionstorm"], "laser": ["prism", "focus", "sweeper"],
	"missile": ["swarm", "hellfire", "cluster"], "amp": ["overclock", "array", "suppression"], "flak": ["skyshred", "burst", "dualpurpose"],
	"sensor": ["deepscan", "painter", "disruptor"], "gravity": ["repulsor", "crush", "well"], "nullifier": ["purge", "dampener", "feedback"],
	"nova": ["supernova", "pulsereactor", "solarflare"], "drones": ["interceptors", "bombers", "hunters"], "scrap": ["mint", "collector", "depot"],
}
const CELL := 52.0
const AIMS := [-0.5, 2.4]
var frames := 0


func _process(_delta: float) -> void:
	frames += 1
	queue_redraw()
	if frames == 8:
		_save.call_deferred()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1600, 900), Color(0.07, 0.09, 0.11))
	var row := 0
	for type in BRANCHES:
		var looks: Array = [[1, ""]]
		for sp in BRANCHES[type]:
			looks.append([6, sp])
		var x := 20.0
		for look in looks:
			for aim in AIMS:
				for cached in [false, true]:
					var p := Vector2(x + CELL * 0.5, 30.0 + float(row) * CELL)
					var s := 1.0 if type != "drones" and type != "scrap" else 0.9
					Draw.turret_cache = cached
					Draw.tower(self, type, int(look[0]), p, float(aim), s, 1.234, 0.05, str(look[1]), str(look[1]))
					Draw.turret_cache = false
					x += CELL
			x += 14.0
		row += 1


func _save() -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	var path := ProjectSettings.globalize_path("res://screenshots/turret_compare.png")
	print("PERF turret compare: ", error_string(img.save_png(path)), " ", path)
	get_tree().quit()
