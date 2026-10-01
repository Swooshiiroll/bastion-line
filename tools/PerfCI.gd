extends Node
## --perf-ci=<out.json>: the performance gate's measurements. For each standard scenario it plays
## a bot game to the round with a fixed seed and step, runs 20 s into the wave, then freezes the
## battle and records the exact render counts: draw calls, primitives and Draw's slow fallback
## calls per frame, the gated numbers (tests/perf_budget.json, checked by tools/perf_check.mjs).
## A short live run adds timings (fps, µs per tower and enemy, ms per sim tick); those depend on
## the machine and are reported only. Writes the JSON and quits.

const Game = preload("res://scripts/core/Game.gd")
const Bot = preload("res://scripts/core/Bot.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const EntityLayer = preload("res://scripts/view/EntityLayer.gd")
const SCENARIOS := [["meadow", "medium", 40], ["canyon", "hard", 70]]
const SETTLE_FRAMES := 40
const FROZEN_FRAMES := 30
const LIVE_SECONDS := 3.0

var app
var out_path := ""
var results: Array = []


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if str(a).begins_with("--perf-ci="):
			out_path = str(a).substr(10)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	_run.call_deferred()


func _frame() -> void:
	await get_tree().process_frame


func _run() -> void:
	for sc in SCENARIOS:
		results.append(await _scenario(sc[0], sc[1], int(sc[2])))
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		printerr("PERF-CI cannot write ", out_path)
		get_tree().quit(2)
		return
	f.store_string(JSON.stringify({"scenarios": results, "viewport": [get_viewport().size.x, get_viewport().size.y],
		"renderer": RenderingServer.get_video_adapter_name()}, "  "))
	f.close()
	print("PERF-CI wrote ", out_path)
	get_tree().quit(0)


func _scenario(map_id: String, diff: String, target: int) -> Dictionary:
	var g = Game.new(map_id, 7, diff)
	g.emit_events = false
	var bot = Bot.new(g)
	var t0 := Time.get_ticks_usec()
	var ticks := 0
	while g.wave < target and not g.is_over():
		bot.update(Game.TICK)
		g.tick(Game.TICK)
		ticks += 1
	var tick_ms := (Time.get_ticks_usec() - t0) / 1000.0 / maxf(1.0, float(ticks))
	# Into the wave: start it and play 20 s so enemies and fire are on the field.
	if g.state == Game.State.BUILD:
		g.start_wave()
	for i in roundi(20.0 / Game.TICK):
		if g.is_over():
			break
		bot.update(Game.TICK)
		g.tick(Game.TICK)
	g.emit_events = true
	g.events = []
	app.start_game_with(g)
	var screen = app.current
	screen.paused = true
	# Frozen: let effects fade and caches bake, then count every frame.
	for i in SETTLE_FRAMES:
		await _frame()
	var calls := 0
	var prims := 0
	var slow := 0
	Draw.slow_calls = 0
	for i in FROZEN_FRAMES:
		await _frame()
		calls = maxi(calls, int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
		prims = maxi(prims, int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)))
		slow = maxi(slow, Draw.slow_calls)
		Draw.slow_calls = 0
	# Live: the battle running, timings only.
	screen.paused = false
	EntityLayer.timing = {}
	EntityLayer.timing_on = true
	var frames := 0
	var t1 := Time.get_ticks_usec()
	while (Time.get_ticks_usec() - t1) / 1e6 < LIVE_SECONDS:
		bot.update(get_process_delta_time())
		await _frame()
		frames += 1
	var secs := (Time.get_ticks_usec() - t1) / 1e6
	EntityLayer.timing_on = false
	var tm: Dictionary = EntityLayer.timing
	var fr := maxf(1.0, float(tm.get("frames", 0)))
	var r := {
		"scenario": "%s %s r%d" % [map_id, diff, target],
		"round": g.wave, "towers": g.towers.size(), "enemies": g.enemies.filter(func(e): return e.alive).size(),
		"draw_calls": calls, "primitives": prims, "slow_calls": slow,
		"fps": snappedf(float(frames) / secs, 0.1), "tick_ms": snappedf(tick_ms, 0.001),
		"towers_ms": snappedf(float(tm.get("towers", 0)) / fr / 1000.0, 0.01),
		"enemies_ms": snappedf(float(tm.get("enemies", 0)) / fr / 1000.0, 0.01),
	}
	print("PERF-CI ", JSON.stringify(r))
	app.show_menu()
	await _frame()
	return r
