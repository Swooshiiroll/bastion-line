extends Node2D
## Times Draw.tower for every tower type at each tier (used by PerfProbe; prints and frees itself).

const Draw = preload("res://scripts/view/Draw.gd")
const REPS := 20
var done := false


func _draw() -> void:
	if done:
		return
	done = true
	var types := ["arrow", "cannon", "frost", "sniper", "tesla", "laser", "missile", "flak", "sensor", "gravity", "amp", "nullifier", "nova", "drones", "scrap"]
	var line := "PERF draw.tower µs per call (tier 1 / 3 / 6):"
	for ty in types:
		var cells := []
		for tier in [1, 3, 6]:
			var t0 := Time.get_ticks_usec()
			for i in REPS:
				Draw.tower(self, ty, tier, Vector2(100, 100), 0.3, 1.0, float(i) * 0.1, 0.0, "", "")
			cells.append(str((Time.get_ticks_usec() - t0) / REPS))
		line += "  %s %s" % [ty, "/".join(cells)]
	print(line)
	var edefs: Dictionary = load("res://data/enemies.gd").ENEMIES
	var eline := "PERF draw.enemy us:"
	for ety in edefs:
		Draw.enemy(self, ety, Vector2(200, 100), Vector2.RIGHT, float(edefs[ety].get("radius", 12.0)), 0.0)
		var te := Time.get_ticks_usec()
		for i in REPS:
			Draw.enemy(self, ety, Vector2(200, 100), Vector2.RIGHT, float(edefs[ety].get("radius", 12.0)), float(i) * 0.1)
		eline += " %s %d" % [ety, (Time.get_ticks_usec() - te) / REPS]
	print(eline)
	var hex := Draw.ngon(6, 1.0)
	var parts := {}
	for part in ["pad", "plate", "outline", "orb", "fill", "aa line x6"]:
		var t3 := Time.get_ticks_usec()
		for i in REPS:
			match part:
				"pad": Draw._pad(self, Vector2(100, 100), 1.0, Color.CYAN, 3, 0.2)
				"plate": Draw.plate(self, Vector2(100, 100), hex, Color.GRAY, 0.0, 19.0, 1.0)
				"outline": Draw.outline(self, Vector2(100, 100), hex, Color.CYAN, 1.5, 0.0, 17.0)
				"orb": Draw.orb(self, Vector2(100, 100), 6.0, Color.CYAN)
				"fill": Draw.fill(self, Vector2(100, 100), hex, Color.GRAY, 0.0, 15.0)
				"aa line x6":
					for k in 6:
						draw_line(Vector2(k, 0), Vector2(k + 9, 9), Color.RED, 1.2, true)
		parts[part] = (Time.get_ticks_usec() - t3) / REPS
	print("PERF parts us: %s" % str(parts))
	var t1 := Time.get_ticks_usec()
	for i in 200:
		draw_circle(Vector2(50, 50), 5.0, Color.RED)
	var c := Time.get_ticks_usec() - t1
	t1 = Time.get_ticks_usec()
	for i in 200:
		draw_arc(Vector2(50, 50), 5.0, 0.0, TAU, 16, Color.RED, 1.2, true)
	var a := Time.get_ticks_usec() - t1
	t1 = Time.get_ticks_usec()
	var pts := PackedVector2Array([Vector2(0, 0), Vector2(10, 0), Vector2(12, 8), Vector2(4, 12), Vector2(-2, 6)])
	for i in 200:
		draw_colored_polygon(pts, Color.RED)
	var p := Time.get_ticks_usec() - t1
	t1 = Time.get_ticks_usec()
	var acc := 0.0
	for i in 1000000:
		acc += float(i) * 0.5
	print("PERF gdscript 1M float adds: %d ms (%s)" % [(Time.get_ticks_usec() - t1) / 1000, str(acc).left(3)])
	t1 = Time.get_ticks_usec()
	for i in 200:
		RenderingServer.canvas_item_add_circle(get_canvas_item(), Vector2(50, 50), 5.0, Color.RED)
	var rs := Time.get_ticks_usec() - t1
	print("PERF RenderingServer.canvas_item_add_circle: %.1f us" % (rs / 200.0))
	var tex := PlaceholderTexture2D.new()
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	var itex := ImageTexture.create_from_image(img)
	var bench := {}
	var ml := PackedVector2Array()
	for k in 16:
		ml.append(Vector2(cos(k * 0.4), sin(k * 0.4)) * 9.0)
		ml.append(Vector2(cos(k * 0.4 + 0.4), sin(k * 0.4 + 0.4)) * 9.0)
	for kind in ["rect", "line", "aa line", "texture", "polyline", "primitive", "multiline w1", "multiline w2", "multiline aa", "arc noaa", "polyline noaa", "quad"]:
		var t2 := Time.get_ticks_usec()
		for i in 200:
			match kind:
				"rect": draw_rect(Rect2(10, 10, 5, 5), Color.RED)
				"line": draw_line(Vector2(0, 0), Vector2(9, 9), Color.RED, 1.5)
				"aa line": draw_line(Vector2(0, 0), Vector2(9, 9), Color.RED, 1.5, true)
				"texture": draw_texture_rect(itex, Rect2(10, 10, 8, 8), false, Color.RED)
				"polyline": draw_polyline(pts, Color.RED, 1.2)
				"primitive": draw_primitive(PackedVector2Array([Vector2(0, 0), Vector2(5, 0), Vector2(0, 5)]), PackedColorArray([Color.RED]), PackedVector2Array())
				"multiline w1": draw_multiline(ml, Color.RED, -1.0)
				"multiline w2": draw_multiline(ml, Color.RED, 2.0)
				"multiline aa": draw_multiline(ml, Color.RED, 1.5, true)
				"arc noaa": draw_arc(Vector2(50, 50), 5.0, 0.0, TAU, 16, Color.RED, 1.2, false)
				"polyline noaa": draw_polyline(pts, Color.RED, 1.2, false)
				"quad": draw_primitive(PackedVector2Array([Vector2(0, 0), Vector2(5, 0), Vector2(5, 5), Vector2(0, 5)]), PackedColorArray([Color.RED]), PackedVector2Array())
		bench[kind] = (Time.get_ticks_usec() - t2) / 200.0
	print("PERF cheap?  %s" % str(bench))
	print("PERF primitives µs per call: circle %.1f  aa arc %.1f  polygon %.1f" % [c / 200.0, a / 200.0, p / 200.0])
	queue_free.call_deferred()
