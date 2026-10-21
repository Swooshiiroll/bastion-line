extends Node2D
## Times the battlefield tower path once Draw's caches are warm (frame 6): the whole Draw.tower
## with the turret cache on, and its pieces. Prints and frees itself (used by PerfProbe).

const Draw = preload("res://scripts/view/Draw.gd")
const REPS := 40
const LOOKS := [["scrapyard", 4, "1|5|2|0"], ["gun_turret", 4, "0|5|2|0"], ["gun_turret", 4, "2|0|2|5"], ["mortar_tower", 4, "1|5|2|3"], ["rocket_salvo", 4, "2|3|5|5"], ["laser_tower", 4, "1|5|3|3"], ["tesla_tower", 4, "2|3|5|5"], ["drone_bay", 4, "0|5|3|3"], ["cryo_tower", 4, "1|5|3|3"], ["radar_tower", 4, "1|5|3|3"], ["railgun", 4, "2|3|5|5"], ["boost_tower", 4, "1|5|3|3"]]
var frames := 0


func _process(_delta: float) -> void:
	frames += 1
	queue_redraw()


func _draw() -> void:
	# Warm every look's caches first (they're baked over the next frames).
	Draw.turret_cache = true
	for lk in LOOKS:
		Draw.tower(self, lk[0], lk[1], Vector2(-200, -200), 0.3, 1.0, 0.0, 0.0, lk[2], lk[2])
	Draw.turret_cache = false
	if frames != 6:
		return
	var out := "PERF warm tower us (cached / full):"
	for lk in LOOKS:
		var res := []
		for cached in [true, false]:
			Draw.turret_cache = cached
			var t0 := Time.get_ticks_usec()
			for i in REPS:
				Draw.tower(self, lk[0], lk[1], Vector2(-200, -200), 0.3, 1.0, float(i) * 0.05, 0.03, lk[2], lk[2])
			res.append(str((Time.get_ticks_usec() - t0) / REPS))
			Draw.turret_cache = false
		out += "  %s/%s %s" % [lk[0], lk[2], "/".join(res)]
	print(out)
	var parts := {}
	var t1 := Time.get_ticks_usec()
	for i in REPS:
		Draw._pad(self, Vector2(-200, -200), 1.0, Color.CYAN, 6, float(i) * 0.05)
	parts.pad = (Time.get_ticks_usec() - t1) / REPS
	t1 = Time.get_ticks_usec()
	for i in REPS:
		Draw.mastery_ring(self, Vector2(-200, -200), 1.0, Color.CYAN, float(i) * 0.05)
	parts.mastery_ring = (Time.get_ticks_usec() - t1) / REPS
	t1 = Time.get_ticks_usec()
	for i in REPS:
		var _k := "%s|%d|%s|%s|%.2f|%d" % ["gun_turret", 4, "0|5|2|0", Color.CYAN.to_html(), 1.0, 3]
	parts.key_format = (Time.get_ticks_usec() - t1) / REPS
	t1 = Time.get_ticks_usec()
	for i in REPS:
		Draw.glow_dot(self, Vector2(-200, -200), 1.5, Color.CYAN)
	parts.glow_dot = (Time.get_ticks_usec() - t1) / REPS
	print("PERF warm parts us: %s" % str(parts))
	queue_free.call_deferred()
