extends Node
## --perf[=map,difficulty,round]: fast-forwards a bot-played game to a busy round, then renders it
## live and reports frame times, first with everything on and then with each visual layer switched
## off in turn, so the cost of every layer shows up as the time saved without it. Prints and quits.

const Game = preload("res://scripts/core/Game.gd")
const EntityLayer = preload("res://scripts/view/EntityLayer.gd")
const Bot = preload("res://scripts/core/Bot.gd")
const WARMUP := 1.5
const PHASE := 4.0

var app
var game
var screen
var bot
var phases: Array = []
var phase := -1
var phase_t := 0.0
var samples: Array = []


func _ready() -> void:
	if "--perf-compare" in OS.get_cmdline_user_args():
		add_child(load("res://tools/TurretCompare.gd").new())
		return
	var map_id := "meadow"
	var diff := "medium"
	var target := 40
	for a in OS.get_cmdline_user_args():
		if str(a).begins_with("--perf="):
			var p := str(a).substr(7).split(",")
			map_id = p[0]
			if p.size() > 1:
				diff = p[1]
			if p.size() > 2:
				target = int(p[2])
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	game = Game.new(map_id, 7, diff)
	game.emit_events = false
	bot = Bot.new(game)
	var t0 := Time.get_ticks_usec()
	var ticks := 0
	while game.wave < target and not game.is_over():
		bot.update(Game.TICK)
		game.tick(Game.TICK)
		ticks += 1
	print("PERF fast-forward: %s %s to round %d in %.1f s (%d ticks, %.3f ms/tick average), %d towers" % [
		map_id, diff, game.wave, (Time.get_ticks_usec() - t0) / 1e6, ticks, (Time.get_ticks_usec() - t0) / 1000.0 / maxf(1.0, ticks), game.towers.size()])
	var mix := {}
	for tw in game.towers:
		var k := "%s/%s" % [tw.type, tw.spec if tw.spec != "" else "-"]
		mix[k] = int(mix.get(k, 0)) + 1
	print("PERF tower mix: %s" % str(mix))
	if game.is_over():
		print("PERF the bot lost before round %d; measuring anyway" % target)
	game.emit_events = true
	var bench = load("res://tools/DrawBench.gd").new()
	add_child(bench)
	add_child(load("res://tools/DrawBench2.gd").new())
	app.start_game_with(game)
	screen = app.current
	var w = screen.world
	phases = [
		["everything", null],
		["no terrain", w.terrain], ["no lane fx", w.lane_fx], ["no scenery", w.scenery],
		["no ground fx", w.ground_fx], ["no entities", w.entities], ["no beams", w.beams], ["no fx", w.fx],
		["no overlay", w.overlay], ["no hud", screen.hud], ["no world at all", w],
		["everything 3x", "speed3"],
	]
	_next()


func _next() -> void:
	if phase >= 0:
		_report()
		var node = phases[phase][1]
		if node is Object:
			node.visible = true
	phase += 1
	phase_t = -WARMUP
	samples = []
	EntityLayer.timing = {}
	EntityLayer.timing_on = true
	if phase >= phases.size():
		get_tree().quit()
		return
	var node = phases[phase][1]
	if node is Object:
		node.visible = false
	screen.speed = 3 if str(node) == "speed3" else 1


func _process(delta: float) -> void:
	if screen == null or phase >= phases.size():
		return
	# Keep the round busy: the bot builds and upgrades, and a new round starts as soon as one ends.
	bot.update(delta * float(screen.speed))
	if game.state == Game.State.BUILD and not game.is_over():
		game.start_wave()
	phase_t += delta
	if phase_t >= 0.0:
		samples.append([delta, Performance.get_monitor(Performance.TIME_PROCESS),
			Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
			Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)])
	if phase_t >= PHASE:
		_next()


func _report() -> void:
	if samples.is_empty():
		return
	var ft: Array = samples.map(func(s): return float(s[0]) * 1000.0)
	ft.sort()
	var avg := 0.0
	var proc := 0.0
	var calls := 0.0
	var prims := 0.0
	for s in samples:
		avg += float(s[0]) * 1000.0
		proc += float(s[1]) * 1000.0
		calls += float(s[2])
		prims += float(s[3])
	var n := float(samples.size())
	var live: int = game.enemies.filter(func(e): return e.alive).size()
	print("PERF %-16s %6.1f fps  frame %6.2f ms (p95 %6.2f)  scripts %6.2f ms  draw calls %5d  primitives %7d  | round %d, %d enemies, %d towers, %d projectiles" % [
		phases[phase][0], 1000.0 / (avg / n), avg / n, ft[int(n * 0.95) - 1] if n >= 20 else ft[-1], proc / n, roundi(calls / n), roundi(prims / n),
		game.wave, live, game.towers.size(), game.projectiles.size()])
	var tm: Dictionary = EntityLayer.timing
	var fr := maxf(1.0, float(tm.get("frames", 0)))
	if tm.has("frames"):
		print("PERF   entity draw per frame: towers %.2f ms, enemies+projectiles %.2f ms, bars %.2f ms" % [float(tm.get("towers", 0)) / fr / 1000.0, float(tm.get("enemies", 0)) / fr / 1000.0, float(tm.get("bars", 0)) / fr / 1000.0])
