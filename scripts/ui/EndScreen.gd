extends Control
## End-of-run overlay (the core fell): run stats, the medal if this run earned it, and next steps.

const UiKit = preload("res://scripts/ui/UiKit.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const DrawControl = preload("res://scripts/ui/DrawControl.gd")
const Difficulty = preload("res://data/difficulty.gd")

var screen
var won := false
var rp_gain := 0


func _init(scr, did_win: bool, research_gain := 0) -> void:
	screen = scr
	won = did_win
	rp_gain = research_gain


func _ready() -> void:
	position = Vector2.ZERO
	size = UiKit.SCREEN
	theme = UiKit.theme()
	add_child(UiKit.dimmer(0.62))
	var g = screen.game
	var p := UiKit.centered_panel(520.0)
	add_child(p)
	var v := UiKit.vbox(10)
	p.add_child(v)
	var title := UiKit.label("SECTOR SECURED" if won else "CORE LOST", 50, UiKit.ACCENT if won else UiKit.BAD, HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_constant_override("outline_size", 10)
	v.add_child(title)
	var dd: Dictionary = Difficulty.DIFFICULTIES[g.difficulty]
	var mode_name := str(dd.name)
	if won:
		var sc := CenterContainer.new()
		var mode: String = g.difficulty
		sc.add_child(DrawControl.new(func(ci): Draw.medal(ci, ci.size / 2.0, 26.0, mode, true, Time.get_ticks_msec() / 1000.0), Vector2(80, 64), true))
		v.add_child(sc)
		v.add_child(UiKit.label("%s MEDAL" % mode_name.to_upper(), 16, dd.color, HORIZONTAL_ALIGNMENT_CENTER))
	var sub := ""
	if won:
		sub = "All %d rounds held on %s. Endless run ended at round %d." % [g.final_round(), g.map_def.name, g.wave]
	else:
		sub = "The core fell at round %d of %d on %s (%s)." % [g.wave, g.final_round(), g.map_def.name, mode_name]
	v.add_child(UiKit.label(sub, 17, UiKit.TEXT, HORIZONTAL_ALIGNMENT_CENTER))

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 40)
	grid.add_theme_constant_override("v_separation", 4)
	var rec: Dictionary = SaveManager.map_record(g.map_id, g.difficulty)
	var rows := [
		["Hostiles destroyed", str(g.stats.kills)],
		["Reached the core", str(g.stats.leaked)],
		["Rounds cleared", str(g.stats.waves_cleared)],
		["Credits earned", str(g.stats.gold_earned)],
		["Towers deployed", str(g.stats.towers_built)],
		["Core shields left", str(g.lives)],
		["Best on %s" % mode_name, ("Medal" if rec.medal else "Round %d" % rec.best_wave) + ("  (endless round %d)" % rec.best_endless if rec.best_endless > 0 else "")],
	]
	for r in rows:
		grid.add_child(UiKit.label(r[0], 15, UiKit.DIM))
		grid.add_child(UiKit.label(r[1], 15))
	var center := CenterContainer.new()
	center.add_child(grid)
	center.custom_minimum_size = Vector2(0, 190)
	v.add_child(center)
	if rp_gain > 0:
		var rp := UiKit.label("+%d RESEARCH POINT%s EARNED" % [rp_gain, "" if rp_gain == 1 else "S"], 20, UiKit.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
		rp.add_theme_constant_override("outline_size", 6)
		v.add_child(rp)

	var row := UiKit.hbox(10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	var again := UiKit.button("Play Again", Callable(screen, "restart"), Vector2(150, 40), true)
	row.add_child(again)
	row.add_child(UiKit.button("Choose Sector", Callable(screen, "map_select"), Vector2(150, 40), true))
	row.add_child(UiKit.button("Main Menu", Callable(screen.app, "show_menu"), Vector2(150, 40), true))
	v.add_child(row)
	var avail: int = SaveManager.research_available()
	if avail > 0:
		var lab := UiKit.button("Research Lab  -  %d RP to spend" % avail, Callable(screen.app, "show_research"), Vector2(0, 40), true)
		v.add_child(lab)
	again.grab_focus.call_deferred()
