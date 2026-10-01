extends Node
## Visual regression tour. Launch with:
##   godot --path <project> -- --screenshot-tour
## Walks through every screen with staged game states, saves PNGs to res://screenshots/, then quits.
## Uses a sandboxed save directory and mutes audio so it never touches real saves or speakers.

const Game = preload("res://scripts/core/Game.gd")
const Towers = preload("res://data/towers.gd")
const Bot = preload("res://scripts/core/Bot.gd")
const Enemies = preload("res://data/enemies.gd")
const Research = preload("res://scripts/core/Research.gd")
const Maps = preload("res://data/maps.gd")
const Grid = preload("res://scripts/core/Grid.gd")
const UiKit = preload("res://scripts/ui/UiKit.gd")

const OUT_DIR := "res://screenshots/"

var app


func _ready() -> void:
	_run()


func _run() -> void:
	AudioServer.set_bus_mute(0, true)
	SaveManager.set_base_dir("user://tour/")
	SaveManager.delete_run()
	for f in [SaveManager.profile_path()]:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(f)
	SaveManager.load_profile()
	AudioServer.set_bus_mute(0, true)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	await _wait(0.5)

	app.show_menu()
	await _wait(4.0)
	await _shot("01_main_menu")

	app.show_map_select()
	await _wait(0.6)
	await _shot("02_map_select")

	await _interaction_checks()
	await _popout_checks()
	await _field_checks()

	# Staged combat on Meadow: every tower type, every enemy type.
	var g = Game.new("meadow", 99)
	g.gold = 20000
	var layout := [
		["arrow", Vector2i(2, 3), 3, "gatling"], ["cannon", Vector2i(5, 5), 3, "napalm"], ["frost", Vector2i(7, 7), 3, "shatter"],
		["sniper", Vector2i(7, 4), 3, "lance"], ["tesla", Vector2i(10, 5), 3, "overload"], ["laser", Vector2i(8, 9), 2, ""],
		["missile", Vector2i(12, 4), 3, "swarm"], ["amp", Vector2i(11, 5), 3, "overclock"], ["laser", Vector2i(13, 7), 3, "focus"],
		["frost", Vector2i(15, 6), 1, ""], ["arrow", Vector2i(16, 8), 3, "shredder"], ["missile", Vector2i(11, 1), 1, ""],
		["amp", Vector2i(3, 4), 1, ""], ["sniper", Vector2i(10, 2), 3, "deadeye"],
	]
	var sniper = null
	var spec_pick = null
	for entry in layout:
		var t = g.place_tower(entry[0], entry[1])
		for k in int(entry[2]) - 1:
			g.upgrade_tower(t, entry[3] if t.tier == 2 else "")
		if entry[0] == "missile" and entry[2] == 3:
			sniper = t
		if entry[0] == "laser" and entry[2] == 2:
			spec_pick = t
	g.gold = 1250
	g.events.clear()
	app.start_game_with(g)
	await _wait(0.4)
	var screen = app.current
	g.start_wave()
	var spots := {"grunt": 260.0, "runner": 330.0, "brute": 470.0, "shaman": 640.0, "juggernaut": 800.0, "warlord": 1050.0}
	for type in spots:
		g.enemies.append(g.spawn_enemy(type, 0, spots[type], 4.0, -1))
	for d in [560.0, 575.0, 590.0, 605.0]:
		g.enemies.append(g.spawn_enemy("swarmling", 0, d, 4.0, -1))
	for d in [380.0, 440.0]:
		g.enemies.append(g.spawn_enemy("bat", 0, d, 4.0, -1))
	await _wait(1.3)
	await _shot("03_combat")

	screen.use_ability("meteor")
	screen.world.force_hover = Vector2i(5, 8)
	await _wait(0.3)
	await _shot("03b_meteor_aim")
	screen.world.force_hover = Vector2i(-99, -99)
	screen.cancel()
	g.cast_meteor(Vector2(5.5 * 48.0, 8.5 * 48.0))
	await _wait(0.45)
	await _shot("03c_meteor_falling")
	await _wait(0.6)
	await _shot("03d_meteor_impact")
	g.cast_warp()
	await _wait(1.0)
	await _shot("03e_time_warp")

	screen.world.selected_tower = sniper
	await _wait(0.4)
	await _shot("04_tower_selected")
	screen.world.selected_tower = spec_pick
	await _wait(0.4)
	await _shot("04b_spec_choice")

	screen.world.selected_tower = null
	screen.select_build("tesla")
	screen.world.force_hover = Vector2i(11, 6)
	await _wait(0.4)
	await _shot("05_build_preview")
	screen.world.force_hover = Vector2i(9, 5)
	await _wait(0.2)
	await _shot("05b_build_invalid")
	screen.world.force_hover = Vector2i(-99, -99)
	screen.cancel()

	screen.open_pause()
	await _wait(0.4)
	await _shot("06_pause")
	screen.open_settings()
	await _wait(0.4)
	await _shot("07_settings")
	screen.resume()

	# Natural mid-game states on the other maps: let the bot play a few waves off-screen first.
	for id in ["canyon", "crossroads"]:
		var mg = _bot_game(id, 12)
		app.start_game_with(mg)
		await _wait(0.3)
		mg.start_wave()
		await _wait(6.0)
		await _shot("08_midgame_%s" % id)

	# Defeat screen.
	var lose = _bot_game("crossroads", 7)
	app.start_game_with(lose)
	await _wait(0.3)
	lose.lives = 0
	lose.state = Game.State.GAMEOVER
	lose.events.append({"type": "gameover", "wave": lose.wave})
	await _wait(0.8)
	await _shot("09_defeat")

	# Medal: an Easy run holds its last round, then endless mode begins on its own.
	var win = _bot_game("canyon", 39, "easy")
	app.start_game_with(win)
	await _wait(0.3)
	win.start_wave()
	win.spawn_queue.clear()
	await _wait(1.0)
	_expect(win.medal and win.endless and not win.is_over() and win.state == Game.State.BUILD, "clearing the last round earns the medal and rolls into endless mode")
	_expect(SaveManager.map_record("canyon", "easy").medal, "the medal is recorded right away")
	await _shot("10_medal")
	win.lives = 0
	win.state = Game.State.GAMEOVER
	win.events.append({"type": "gameover", "wave": win.wave})
	await _wait(0.8)
	await _shot("10b_medal_end")

	app.show_map_select()
	await _wait(0.6)
	await _shot("11_map_select_with_records")

	await _research_checks()

	# Staged tier-4 masteries on Meadow with everything researched.
	var mg4 = Game.new("meadow", 99, "medium", Research.node_ids())
	mg4.gold = 30000
	var mlayout := [
		["arrow", Vector2i(2, 3), 4, "gatling"], ["cannon", Vector2i(5, 5), 4, "siege"], ["frost", Vector2i(7, 7), 4, "shatter"],
		["sniper", Vector2i(7, 4), 4, "lance"], ["tesla", Vector2i(10, 5), 4, "storm"], ["laser", Vector2i(8, 9), 4, "prism"],
		["missile", Vector2i(12, 4), 4, "hellfire"], ["amp", Vector2i(11, 5), 4, "array"], ["laser", Vector2i(13, 7), 4, "focus"],
		["arrow", Vector2i(16, 8), 3, "shredder"], ["sniper", Vector2i(10, 2), 4, "deadeye"], ["tesla", Vector2i(3, 4), 4, "overload"],
	]
	var t3 = null
	var t4 = null
	for entry in mlayout:
		var t = mg4.place_tower(entry[0], entry[1])
		while t.tier < int(entry[2]):
			if not mg4.upgrade_tower(t, entry[3] if t.tier == 2 else ""):
				break
		if t.tier == 3:
			_grow(mg4, t, "bbb")
			t3 = t
		if entry[0] == "sniper" and entry[3] == "lance":
			t4 = t
	mg4.gold = 1400
	mg4.events.clear()
	app.start_game_with(mg4)
	await _wait(0.4)
	var ms = app.current
	mg4.start_wave()
	var mspots := {"grunt": 260.0, "brute": 470.0, "shaman": 640.0, "juggernaut": 800.0, "runner": 900.0}
	for type in mspots:
		mg4.enemies.append(mg4.spawn_enemy(type, 0, mspots[type], 6.0, -1))
	for d in [560.0, 575.0, 590.0, 605.0, 1010.0, 1030.0]:
		mg4.enemies.append(mg4.spawn_enemy("swarmling", 0, d, 6.0, -1))
	for d in [380.0, 440.0]:
		mg4.enemies.append(mg4.spawn_enemy("bat", 0, d, 6.0, -1))
	await _wait(1.2)
	await _shot("14_mastery_combat")
	ms.world.selected_tower = t4
	await _wait(0.4)
	await _shot("14b_mastery_selected")
	ms.world.selected_tower = t3
	await _wait(0.4)
	await _shot("14c_mastery_offer")
	await _key(KEY_I)
	_expect(t3.tier == 4 and t3.display_name() == "Disintegrator", "I on a fully upgraded branch B buys its mastery")
	await _wait(0.5)
	await _shot("14d_mastery_bought")

	# New threats and the towers that answer them.
	var ng = Game.new("meadow", 99, "medium")
	ng.gold = 30000
	var nlayout := [
		["sensor", Vector2i(3, 4), 3, "painter"], ["flak", Vector2i(2, 3), 3, "burst"], ["gravity", Vector2i(5, 5), 3, "repulsor"],
		["tesla", Vector2i(5, 3), 2, ""], ["arrow", Vector2i(7, 7), 3, "gatling"], ["flak", Vector2i(10, 5), 1, ""],
		["gravity", Vector2i(8, 9), 3, "crush"], ["sensor", Vector2i(13, 7), 1, ""], ["sniper", Vector2i(10, 2), 2, ""],
		["arrow", Vector2i(3, 9), 2, ""], ["cannon", Vector2i(12, 4), 2, ""],
	]
	var sensor_t = null
	var jam_victim = null
	for entry in nlayout:
		var t = ng.place_tower(entry[0], entry[1])
		while t.tier < int(entry[2]):
			if not ng.upgrade_tower(t, entry[3] if t.tier == 2 else ""):
				break
		if entry[0] == "sensor" and sensor_t == null:
			sensor_t = t
		if entry[0] == "arrow" and entry[2] == 2:
			jam_victim = t
	ng.gold = 900
	ng.events.clear()
	app.start_game_with(ng)
	await _wait(0.4)
	var ns = app.current
	ng.start_wave()
	var nspots := {"aegis": 250.0, "hydra": 420.0, "grunt": 470.0, "brute": 640.0}
	for type in nspots:
		ng.enemies.append(ng.spawn_enemy(type, 0, nspots[type], 4.0, -1))
	for d in [150.0, 185.0, 880.0, 920.0]:
		ng.enemies.append(ng.spawn_enemy("phantom", 0, d, 4.0, -1))
	for d in [90.0, 130.0, 170.0]:
		ng.enemies.append(ng.spawn_enemy("bat", 0, d, 4.0, -1))
	var jam = ng.spawn_enemy("jammer", 0, 600.0, 4.0, -1)
	ng.enemies.append(jam)
	await _wait(0.9)
	jam.pos = jam_victim.pos + Vector2(0, -40)
	jam.ability_timer = 0.01
	await _wait(0.5)
	await _shot("15_new_threats")
	ns.world.selected_tower = sensor_t
	await _wait(0.3)
	await _shot("15b_sensor_selected")
	ns.world.selected_tower = null
	await _key(KEY_0)
	_expect(ns.world.build_type == "sensor", "key 0 selects the Sensor Array")
	await _key(KEY_MINUS)
	_expect(ns.world.build_type == "gravity", "key - selects the Graviton Projector")
	ns.world.force_hover = Vector2i(15, 6)
	await _wait(0.3)
	await _shot("15c_build_graviton")
	ns.world.force_hover = Vector2i(-99, -99)
	await _key(KEY_EQUAL)
	_expect(ns.world.build_type == "nullifier", "key = selects the Nullifier")
	await _key(KEY_BRACKETLEFT)
	_expect(ns.world.build_type == "nova", "key [ selects the Nova Reactor")
	await _key(KEY_BRACKETRIGHT)
	_expect(ns.world.build_type == "drones", "key ] selects the Drone Bay")
	await _key(KEY_BACKSLASH)
	_expect(ns.world.build_type == "scrap", "key \\ selects the Scrapyard")
	ns.cancel()
	ns.cancel()

	# The v3 roster: all eight new regulars and both new bosses on one field.
	var vg = Game.new("foundry", 99, "hard")
	vg.gold = 30000
	for entry in [["flak", Vector2i(4, 3), 3, "burst"], ["tesla", Vector2i(2, 6), 3, "storm"], ["laser", Vector2i(13, 8), 3, "focus"],
			["sniper", Vector2i(10, 6), 3, "deadeye"], ["frost", Vector2i(18, 12), 3, "stasis"], ["missile", Vector2i(21, 8), 3, "hellfire"]]:
		var t = vg.place_tower(entry[0], entry[1])
		while t != null and t.tier < int(entry[2]):
			if not vg.upgrade_tower(t, entry[3] if t.tier == 2 else ""):
				break
	vg.gold = 900
	vg.events.clear()
	app.start_game_with(vg)
	await _wait(0.4)
	vg.start_wave()
	vg.spawn_queue.clear()
	var vspots := {"burrower": 230.0, "stalker": 330.0, "mender": 450.0, "rally": 560.0, "bulwark": 620.0, "rampart": 760.0, "colossus": 1000.0}
	for type in vspots:
		vg.enemies.append(vg.spawn_enemy(type, 0, vspots[type], 4.0, -1))
	var vair := {"gunship": 380.0, "leviathan": 640.0}
	for type in vair:
		vg.enemies.append(vg.spawn_enemy(type, 0, vair[type], 4.0, -1))
	for d in [150.0, 165.0, 180.0, 195.0, 210.0, 225.0]:
		vg.enemies.append(vg.spawn_enemy("locust", 0, d, 4.0, -1))
	await _wait(1.2)
	await _shot("15d_v3_threats")

	# v3.1: the three new towers and the new C branches, with secondaries, against the v3 roster.
	var wg = Game.new("foundry", 99, "hard", Research.node_ids())
	wg.gold = 60000
	var wlayout := [
		["nullifier", Vector2i(4, 3), "Taaaaa"], ["nova", Vector2i(2, 6), "Tbbbbb"], ["drones", Vector2i(13, 8), "Taabbbb"],
		["drones", Vector2i(10, 6), "Tbbccc"], ["laser", Vector2i(18, 12), "Tccccc"], ["arrow", Vector2i(21, 8), "Tcccc"],
		["tesla", Vector2i(7, 9), "Taacccc"], ["gravity", Vector2i(18, 4), "Tccccc"], ["missile", Vector2i(12, 3), "Tccccc"],
		["nova", Vector2i(19, 3), "Tccaa"], ["nullifier", Vector2i(9, 12), "Tccbb"],
		["scrap", Vector2i(9, 9), "Tccbb"], ["scrap", Vector2i(14, 12), "Taaaaa"],
	]
	var sel_t = null
	var tree_t = null
	for entry in wlayout:
		var t = wg.place_tower(entry[0], entry[1])
		if t == null:
			_expect(false, "placed %s at %s" % [entry[0], entry[1]])
			continue
		_expect(_grow(wg, t, entry[2]), "%s grows along %s" % [entry[0], entry[2]])
		if entry[0] == "drones" and sel_t == null:
			sel_t = t
		if entry[0] == "tesla":
			tree_t = t
	wg.gold = 1500
	wg.events.clear()
	app.start_game_with(wg)
	await _wait(0.4)
	var ws = app.current
	wg.start_wave()
	wg.spawn_queue.clear()
	var wspots := {"bulwark": 240.0, "rampart": 330.0, "mender": 420.0, "burrower": 520.0, "stalker": 610.0, "brute": 700.0, "aegis": 780.0}
	for type in wspots:
		wg.enemies.append(wg.spawn_enemy(type, 0, wspots[type], 8.0, -1))
	for d in [200.0, 260.0, 380.0]:
		wg.enemies.append(wg.spawn_enemy("gunship", 0, d, 8.0, -1))
	for d in [150.0, 165.0, 180.0, 195.0, 210.0, 225.0, 480.0, 495.0]:
		wg.enemies.append(wg.spawn_enemy("locust", 0, d, 8.0, -1))
	await _wait(1.5)
	await _shot("30_v31_towers")
	ws.world.selected_tower = sel_t
	await _wait(0.3)
	await _shot("30b_drone_bay_selected")
	ws.world.selected_tower = tree_t
	await _wait(0.2)
	await _key(KEY_E)
	await _wait(0.4)
	await _shot("30c_tree_locked_in")
	await _key(KEY_ESCAPE)

	# Save/continue flow: the menu should now offer Continue for a saved run.
	var saved = _bot_game("meadow", 6)
	SaveManager.save_run(saved)
	app.show_menu()
	await _wait(1.0)
	await _shot("12_menu_continue")

	SaveManager.delete_run()
	print("TOUR COMPLETE: %s" % ("ALL PASSED" if failed_total == 0 else "%d FAILED" % failed_total))
	get_tree().quit(0 if failed_total == 0 else 1)


## Drives the real input pipeline (synthetic key presses and mouse clicks) and asserts outcomes.
func _interaction_checks() -> void:
	var fails := 0
	app.start_game("meadow")
	await _wait(0.5)
	var screen = app.current
	var g = screen.game
	var cell := Vector2i(2, 3)
	var cell_pos: Vector2 = screen.world.base_pos + Vector2((cell.x + 0.5) * 48.0, (cell.y + 0.5) * 48.0)

	await _key(KEY_1)
	fails += _expect(screen.world.build_type == "arrow", "key 1 selects Arrow Tower")
	await _click(cell_pos)
	fails += _expect(g.tower_at.has(cell), "click on a tile builds the tower")
	fails += _expect(g.gold == Game.START_GOLD - 50, "building costs 50 gold (%d)" % g.gold)
	fails += _expect(screen.world.selected_tower == g.tower_at.get(cell), "new tower is selected")
	await _key(KEY_U)
	fails += _expect(g.tower_at[cell].tier == 2, "U upgrades the selected tower")
	g.gold = 20
	await _key(KEY_I)
	fails += _expect(g.tower_at[cell].tier == 2, "I without enough credits leaves the tower at tier 2")
	g.gold += 500
	await _key(KEY_I)
	fails += _expect(g.tower_at[cell].spec == "shredder", "I picks the second specialization (Shredder)")
	await _key(KEY_T)
	fails += _expect(g.tower_at[cell].mode == 1, "T cycles targeting")
	await _key(KEY_ESCAPE)
	fails += _expect(screen.world.selected_tower == null, "Esc clears the selection")
	await _click(cell_pos)
	fails += _expect(screen.world.selected_tower != null, "clicking a tower selects it")
	await _key(KEY_2)
	await _click(cell_pos + Vector2(0, 48), MOUSE_BUTTON_RIGHT)
	fails += _expect(screen.world.build_type == "", "right-click cancels build mode")
	await _click(cell_pos + Vector2(-96, -48))
	fails += _expect(g.towers.size() == 1, "clicking the road with nothing selected builds nothing")
	await _key(KEY_3)
	await _click(cell_pos + Vector2(-96, -48))
	fails += _expect(g.towers.size() == 1, "can't build on the road")
	await _key(KEY_ESCAPE)

	var start_btn: Button = screen.hud.start_btn
	fails += _expect(start_btn.get_parent() == screen.hud.bottom and start_btn.get_global_rect().position.y > 800.0, "the Launch button sits in the bottom bar")
	await _click(start_btn.get_global_rect().get_center())
	fails += _expect(g.wave == 1 and g.state == Game.State.WAVE, "Start Wave button starts wave 1")
	await _key(KEY_F)
	fails += _expect(screen.speed == 2, "F toggles speed")
	await _key(KEY_Q)
	fails += _expect(screen.world.ability_target == "meteor", "Q arms Meteor Strike")
	await _click(cell_pos + Vector2(0, -48))
	fails += _expect(g.ability_cd.meteor > 0.0 and screen.world.ability_target == "", "clicking the field drops the meteor")
	await _key(KEY_Q)
	fails += _expect(screen.world.ability_target == "", "Q does nothing while the meteor recharges")
	await _key(KEY_W)
	fails += _expect(g.warp_timer > 0.0 and g.ability_cd.warp > 0.0, "W casts Time Warp")
	await _key(KEY_ESCAPE)
	fails += _expect(screen.modal != null and screen.paused, "Esc opens the pause menu")
	await _key(KEY_ESCAPE)
	fails += _expect(screen.modal == null and not screen.paused, "Esc again resumes")
	await _click(cell_pos)
	var before_sell: int = g.gold
	var spent: int = g.towers[0].spent if not g.towers.is_empty() else 0
	await _key(KEY_X)
	fails += _expect(g.towers.is_empty(), "X sells the selected tower")
	fails += _expect(g.gold == before_sell + int(floor(spent * 0.7)), "sell refunds 70%% of spend (%d)" % g.gold)
	print("INTERACTION CHECKS: %s" % ("ALL PASSED" if fails == 0 else "%d FAILED" % fails))


## The battlefield through real input: every sector mid-battle, a switch gate flip, clearing
## rubble, and the bottom bar explaining a special tile.
func _field_checks() -> void:
	var fails := 0
	for id in Maps.ORDER:
		var mg = _bot_game(id, 9)
		app.start_game_with(mg)
		await _wait(0.3)
		mg.start_wave()
		await _wait(4.0)
		await _shot("17_sector_%s" % id)
	app.start_game("delta")
	await _wait(0.4)
	var screen = app.current
	var g = screen.game
	var gate_cell: Vector2i = g.grid.groups[0].fork
	var gate_pos: Vector2 = screen.world.base_pos + Grid.cell_center(gate_cell)
	await _hover(gate_pos)
	await _wait(0.3)
	fails += _expect(screen.hud.bottom.ctx_key.begins_with("tile:"), "hovering the gate explains it in the bottom bar")
	await _click(gate_pos)
	fails += _expect(g.gates[0] == 1 and g.gate_label(0) == "North only", "clicking the gate switches it (%s)" % g.gate_label(0))
	await _click(gate_pos)
	fails += _expect(g.gates[0] == 1, "the gate has a cooldown")
	await _wait(0.4)
	await _shot("18_gate")
	app.start_game("meadow")
	await _wait(0.4)
	screen = app.current
	g = screen.game
	var rub := Vector2i(16, 5)
	var rub_pos: Vector2 = screen.world.base_pos + Grid.cell_center(rub)
	var gold_before_rubble: int = g.gold
	await _hover(rub_pos)
	await _wait(0.3)
	await _shot("18b_rubble_hover")
	await _click(rub_pos)
	fails += _expect(not g.has_rubble(rub) and g.gold == gold_before_rubble - 40, "clicking rubble clears it for 40 cr")
	fails += _expect(screen.world.terrain.cleared.has(rub), "the terrain stops drawing cleared rubble")
	await _wait(0.2)
	await _shot("18b2_rubble_cleared")
	await _key(KEY_1)
	await _hover(screen.world.base_pos + Grid.cell_center(Vector2i(11, 5)))
	await _wait(0.3)
	await _shot("18c_build_high_ground")
	await _click(screen.world.base_pos + Grid.cell_center(Vector2i(11, 5)))
	fails += _expect(g.tower_at.has(Vector2i(11, 5)) and g.tower_at[Vector2i(11, 5)].site == "H", "a tower built on high ground gets the bonus")
	await _key(KEY_ESCAPE)
	print("FIELD CHECKS: %s" % ("ALL PASSED" if fails == 0 else "%d FAILED" % fails))


func _hover(canvas_pos: Vector2) -> void:
	var m := InputEventMouseMotion.new()
	m.position = get_viewport().get_final_transform() * (canvas_pos + UiKit.view_offset())
	m.global_position = m.position
	Input.parse_input_event(m)
	await get_tree().process_frame
	await get_tree().process_frame


## The pop-out HUD through real input: shop pick/place/reopen, Esc as master close, hotkeys,
## upgrade tree buying (and a locked mastery), in-battle research pausing, intel.
func _popout_checks() -> void:
	var fails := 0
	app.start_game("meadow")
	await _wait(0.5)
	var screen = app.current
	var g = screen.game
	var hud = screen.hud
	await _shot("16_hud_idle")
	# Zoom and pan the battlefield.
	var fpos: Vector2 = screen.world.base_pos + Grid.cell_center(Vector2i(16, 8))
	await _wheel(fpos, true)
	await _wheel(fpos, true)
	fails += _expect(screen.world.zoom > 1.2, "the mouse wheel zooms the battlefield (%.2f)" % screen.world.zoom)
	var pan0: Vector2 = screen.world.pan
	await _hold_key(KEY_RIGHT, 0.3)
	fails += _expect(screen.world.pan.x < pan0.x, "the arrow keys pan the zoomed battlefield")
	await _wait(0.2)
	await _shot("16h_zoomed")
	await _key(KEY_HOME)
	fails += _expect(is_equal_approx(screen.world.zoom, 1.0) and screen.world.pan == Vector2.ZERO, "Home resets the view")
	# A 2x2 Scrapyard builds on the block centred on the cursor.
	g.gold += 2000
	await _key(KEY_BACKSLASH)
	await _click(screen.world.base_pos + Vector2(3 * 48, 6 * 48))
	var yard = g.tower_at.get(Vector2i(2, 5))
	fails += _expect(yard != null and yard.type == "scrap" and g.tower_at.get(Vector2i(3, 6)) == yard, "a Scrapyard takes the 2x2 block under the cursor")
	await _key(KEY_ESCAPE)
	# Target priority on a tower that hits both.
	var coil = g.place_tower("tesla", Vector2i(6, 3))
	screen.world.selected_tower = coil
	await _wait(0.2)
	fails += _expect(_button_in(hud.bottom, "Priority: Any  [G]") != null, "a tower that hits air and ground shows a Priority button")
	await _key(KEY_G)
	fails += _expect(coil.priority == 1, "G sets it to prefer flyers")
	await _wait(0.2)
	await _shot("16i_priority")
	await _key(KEY_ESCAPE)
	# K opens the Codex on the selected tower and pauses the battle.
	var rail = g.place_tower("sniper", Vector2i(7, 4))
	screen.world.selected_tower = rail
	await _wait(0.1)
	await _key(KEY_K)
	await _wait(0.5)
	fails += _expect(hud.is_open("codex") and screen.paused and hud.popout("codex").panel.current == "tower:sniper", "K opens the Codex on the selected Railgun and pauses")
	await _shot("19d_codex_battle")
	await _key(KEY_ESCAPE)
	fails += _expect(not hud.is_open("codex") and not screen.paused, "Esc closes the Codex and resumes")
	screen.world.selected_tower = null
	# A late round lists many enemy types: the NEXT strip must fit its button.
	g.wave = 59
	await _wait(0.2)
	fails += _expect(hud.top.next_box.get_combined_minimum_size().x <= hud.top.next_btn.size.x - 8, "the NEXT strip fits its button on a crowded round (%d of %d px)" % [hud.top.next_box.get_combined_minimum_size().x, hud.top.next_btn.size.x])
	await _shot("16a_next_strip_crowded")
	g.wave = 0
	await _wait(0.2)
	await _key(KEY_B)
	fails += _expect(hud.is_open("shop"), "B opens the shop")
	await _wait(0.3)
	await _shot("16c_shop")
	fails += _expect(hud.popout("shop").cards.size() == Towers.ORDER.size(), "the shop lists all %d towers" % Towers.ORDER.size())
	var card: Button = hud.popout("shop").cards["arrow"]
	await _click(card.get_global_rect().get_center())
	fails += _expect(screen.world.build_type == "arrow" and not hud.is_open("shop"), "picking a card closes the shop and starts building")
	var cell := Vector2i(2, 3)
	var cell_pos: Vector2 = screen.world.base_pos + Vector2((cell.x + 0.5) * 48.0, (cell.y + 0.5) * 48.0)
	await _click(cell_pos)
	fails += _expect(g.tower_at.has(cell) and hud.is_open("shop"), "placing the tower reopens the shop")
	await _click(screen.world.base_pos + Grid.cell_center(Vector2i(8, 12)))
	fails += _expect(not hud.is_open("shop"), "clicking the field with an empty hand closes the shop")
	await _key(KEY_B)
	await _key(KEY_ESCAPE)
	fails += _expect(not hud.any_open() and screen.world.build_type == "" and not screen.paused, "Esc closes every pop-out (and doesn't pause)")
	await _key(KEY_2)
	var c2 := Vector2i(5, 5)
	await _click(screen.world.base_pos + Vector2((c2.x + 0.5) * 48.0, (c2.y + 0.5) * 48.0))
	fails += _expect(g.tower_at.has(c2) and not hud.is_open("shop"), "a hotkey build never opens the shop")
	g.place_tower("amp", Vector2i(3, 3))
	await _click(cell_pos)
	await _wait(0.2)
	fails += _expect(screen.hud.bottom._boosts(g.tower_at[cell]).has("+15% dmg (pylon)"), "the tower card lists the pylon boost as a percentage")
	await _shot("16b_hud_selected")
	# The tower panel (design/upgrade_rework.md): selecting a tower opens it in the shop's slot.
	var tw = g.tower_at[cell]
	fails += _expect(hud.is_open("tower") and hud.popout("tower").tower == tw, "selecting a tower opens its tower panel")
	fails += _expect(hud.popout("tower").cards.keys() == ["trunk"], "a stock tower's panel offers the Retrofit")
	await _key(KEY_E)
	fails += _expect(hud.is_open("tree"), "E opens the upgrade tree")
	var tree = hud.popout("tree")
	await _wait(0.3)
	await _click(tree.node_buttons["t2"].get_global_rect().get_center())
	fails += _expect(tw.tier == 1 and tree.selected == "t2", "clicking a tree node selects it and doesn't buy")
	fails += _expect(tree.preview.game != null, "a selected node plays its preview")
	await _card("trunk")
	fails += _expect(tw.tier == 2, "the panel's Retrofit card upgrades")
	g.gold += 3000
	await _card("b")
	fails += _expect(tw.tier == 3 and tw.spec == "shredder", "a branch card buys the specialization")
	await _card("a")
	fails += _expect(int(tw.depth.a) == 1 and tw.secondary() == "a", "another card starts a secondary branch")
	fails += _expect(hud.popout("tower").cards.has("c"), "the third branch keeps a card")
	await _card("c")
	fails += _expect(int(tw.depth.c) == 0, "the locked third branch's card buys nothing")
	await _card("b")
	await _card("a")
	await _card("b")
	fails += _expect(int(tw.depth.b) == 3 and tw.locked_in() and tw.primary() == "b", "a third upgrade locks the primary in")
	await _card("a")
	fails += _expect(int(tw.depth.a) == 2, "the capped secondary's card buys nothing")
	g.gold += 2000
	await _card("b")
	await _card("b")
	fails += _expect(int(tw.depth.b) == 4 and not tw.mastered, "a mastery without research can't be bought")
	await _wait(0.2)
	await _shot("16c_tower_panel")
	# The tree previews reachable nodes only.
	await _click(tree.node_buttons["b4"].get_global_rect().get_center())
	await _wait(1.6)
	fails += _expect(tree.selected == "b4" and tree.preview.game != null and tree.preview.tower.depth.b == 4, "the preview shows the clicked upgrade")
	await _shot("16d_tree")
	await _wait(3.0)
	await _shot("16d4_preview_combat")
	await _click(tree.node_buttons["c1"].get_global_rect().get_center())
	fails += _expect(tree.preview.game == null, "an unreachable node shows a note instead of a preview")
	await _key(KEY_E)
	fails += _expect(not hud.is_open("tree"), "E closes the tree")
	# The playtest case: the primary locks in while the secondary has only one upgrade.
	g.gold += 3000
	var sa = g.place_tower("sensor", Vector2i(12, 1))
	_grow(g, sa, "Tacaa")
	screen.world.selected_tower = sa
	await _wait(0.4)
	fails += _expect(hud.popout("tower") != null and hud.popout("tower").tower == sa, "the panel follows the selection")
	await _card("c")
	fails += _expect(int(sa.depth.c) == 2 and sa.locked_in(), "the secondary takes its second upgrade after the primary locks in")
	await _card("c")
	fails += _expect(int(sa.depth.c) == 2, "the secondary stops at 2")
	await _key(KEY_E)
	await _wait(0.6)
	await _shot("16d2_tree_secondary")
	await _key(KEY_ESCAPE)
	fails += _expect(not hud.is_open("tree") and screen.world.selected_tower == sa, "Esc closes the tree first")
	await _key(KEY_B)
	await _wait(0.2)
	fails += _expect(hud.is_open("shop") and not hud.is_open("tower") and screen.world.selected_tower == null, "B swaps the tower panel for the shop")
	await _key(KEY_ESCAPE)
	screen.world.selected_tower = tw
	await _wait(0.2)
	await _key(KEY_ESCAPE)
	await _wait(0.2)
	fails += _expect(screen.world.selected_tower == null and not hud.is_open("tower"), "Esc deselects, which closes the panel")
	screen.world.selected_tower = tw
	await _key(KEY_E)
	await _wait(0.3)
	tree = hud.popout("tree")
	var hover := InputEventMouseMotion.new()
	hover.position = get_viewport().get_final_transform() * (tree.node_buttons["bm"].get_global_rect().get_center() + UiKit.view_offset())
	hover.global_position = hover.position
	Input.parse_input_event(hover)
	await _wait(0.3)
	await _shot("16d3_tree_hover")
	await _key(KEY_R)
	fails += _expect(hud.is_open("research") and screen.paused, "R opens research and pauses the battle")
	await _wait(0.3)
	await _shot("16e_research")
	await _mouse_away()
	await _key(KEY_ESCAPE)
	fails += _expect(not hud.any_open() and not screen.paused, "Esc closes research and resumes")
	await _click(hud.top.next_btn.get_global_rect().get_center())
	fails += _expect(hud.is_open("intel"), "clicking NEXT opens the intel pop-out")
	await _wait(0.3)
	await _shot("16f_intel")
	await _key(KEY_N)
	fails += _expect(not hud.is_open("intel"), "N toggles intel")
	await _key(KEY_ESCAPE)
	await _key(KEY_ESCAPE)
	fails += _expect(screen.modal != null and screen.paused, "Esc with nothing open or selected opens the pause menu")
	await _wait(0.3)
	await _shot("16g_pause_menu")
	var restart_btn: Button = _button_in(screen.modal, "Restart Sector")
	fails += _expect(restart_btn != null, "the pause menu has Restart Sector")
	if restart_btn != null:
		await _click(restart_btn.get_global_rect().get_center())
		await _wait(0.3)
		var yes: Button = _button_in(screen.modal, "Restart")
		fails += _expect(yes != null and screen.modal.get_script() != null, "Restart asks for confirmation first")
		if yes != null:
			await _click(yes.get_global_rect().get_center())
			await _wait(0.5)
			var fresh = app.current
			fails += _expect(fresh != screen and fresh.game.wave == 0 and fresh.game.towers.is_empty() and fresh.game.map_id == g.map_id, "confirming restarts the sector from round 0 with no towers")
	else:
		await _key(KEY_ESCAPE)
	print("POPOUT CHECKS: %s" % ("ALL PASSED" if fails == 0 else "%d FAILED" % fails))


## Research Lab through real clicks: earn RP from records, buy nodes, check the menu badge.
func _research_checks() -> void:
	var fails := 0
	SaveManager.record_run("meadow", "hard", 80, true, false)
	SaveManager.record_run("meadow", "easy", 40, true, false)
	SaveManager.record_run("crossroads", "medium", 60, true, false)
	SaveManager.record_run("canyon", "nightmare", 100, true, false)
	for id in ["cmd_funds", "cmd_core", "arrow_1", "arrow_2a", "arrow_2b", "arrow_m", "sniper_1", "sniper_2b", "tesla_1", "laser_1"]:
		SaveManager.buy_research(id)
	app.show_menu()
	await _wait(0.6)
	var avail: int = SaveManager.research_available()
	var menu_btn: Button = null
	for b in app.current.find_children("*", "Button", true, false):
		if b.text.begins_with("Research Lab"):
			menu_btn = b
	fails += _expect(menu_btn != null and menu_btn.text.contains("%d RP" % avail), "menu shows the RP badge (%s)" % (menu_btn.text if menu_btn else "none"))
	await _click(menu_btn.get_global_rect().get_center())
	await _wait(0.4)
	var lab = app.current
	fails += _expect(lab.get("panel") != null, "Research Lab button opens the lab")
	var node_btn: Button = lab.panel.node_buttons["cmd_salvage"]
	await _click(node_btn.get_global_rect().get_center())
	fails += _expect(not SaveManager.research_owned().has("cmd_salvage"), "first click only selects a node")
	await _click(node_btn.get_global_rect().get_center())
	fails += _expect(SaveManager.research_owned().has("cmd_salvage") and SaveManager.research_available() == avail - 2, "second click researches it (-2 RP)")
	var locked: Button = lab.panel.node_buttons["cannon_m"]
	await _click(locked.get_global_rect().get_center())
	await _key(KEY_ENTER)
	fails += _expect(not SaveManager.research_owned().has("cannon_m"), "Enter can't buy a locked node")
	var f0: int = lab.panel.focus
	await _key(KEY_RIGHT)
	fails += _expect(lab.panel.focus == f0 + 1, "Right moves the lab to the next tree")
	await _key(KEY_LEFT)
	fails += _expect(lab.panel.focus == f0, "Left moves back")
	lab.panel.focus_tree("laser")
	await _wait(0.3)
	await _key(KEY_DOWN)
	await _key(KEY_UP)
	await _key(KEY_DOWN)
	await _key(KEY_ENTER)
	fails += _expect(SaveManager.research_owned().has("laser_2b") and not SaveManager.research_owned().has("laser_2a"), "Up/Down pick a node in the focused tree and Enter researches it")
	lab.panel.focus_tree("sniper")
	await _wait(0.4)
	# Hover the Railgun Mastery node so the detail panel shows its two tier-4 upgrades.
	var hover_at: Vector2 = get_viewport().get_final_transform() * (lab.panel.node_buttons["sniper_m"].get_global_rect().get_center() + UiKit.view_offset())
	var motion := InputEventMouseMotion.new()
	motion.position = hover_at
	motion.global_position = hover_at
	Input.parse_input_event(motion)
	await _wait(0.5)
	await _shot("13_research_lab")
	var sp_layer := CanvasLayer.new()
	sp_layer.layer = 40
	app.add_child(sp_layer)
	var sp = load("res://scripts/ui/SettingsPanel.gd").new(func(): pass)
	sp_layer.add_child(sp)
	await _wait(0.3)
	var labels: Array = sp.find_children("*", "Button", true, false).map(func(b): return (b as Button).text)
	fails += _expect(labels.has("VSync") and labels.has("Screen shake") and labels.has("Show FPS  [F3]") and sp.find_children("*", "OptionButton", true, false).size() >= 3, "Settings has VSync, frame cap, effects, shake and FPS options")
	await _shot("13b_settings")
	sp_layer.queue_free()
	await _wait(0.1)
	# Move off the node first: an open tooltip would take the first Esc.
	var away := InputEventMouseMotion.new()
	away.position = get_viewport().get_final_transform() * (Vector2(800, 90) + UiKit.view_offset())
	away.global_position = away.position
	Input.parse_input_event(away)
	await _wait(0.2)
	await _key(KEY_ESCAPE)
	fails += _expect(app.current != lab, "Esc leaves the lab")
	# The Codex from the main menu.
	await _wait(0.4)
	var cbtn: Button = _button_in(app.current, "Codex")
	fails += _expect(cbtn != null, "the main menu has a Codex button")
	if cbtn != null:
		await _click(cbtn.get_global_rect().get_center())
		await _wait(0.5)
		var kp = app.current.get("panel")
		fails += _expect(kp != null and str(kp.current).begins_with("tower:"), "the Codex opens on the towers")
		await _shot("19_codex_tower")
		var first: String = kp.current
		await _key(KEY_DOWN)
		fails += _expect(kp.current != first, "Down moves to the next entry")
		kp.set_category("enemies")
		await _wait(0.2)
		fails += _expect(kp._visible_ids.size() == Enemies.ORDER.size(), "the Enemies tab lists all %d enemies" % Enemies.ORDER.size())
		kp.open_entry("enemy:bulwark")
		await _wait(0.3)
		await _shot("19b_codex_enemy")
		kp._search.text = "barrier"
		kp._refresh_list()
		fails += _expect(kp._visible_ids.has("enemy:aegis") and kp._visible_ids.has("enemy:bulwark") and kp._visible_ids.has("g:barrier"), "searching 'barrier' finds the Aegis Walker, Bulwark and the Barrier entry")
		kp.open_entry("g:barrier")
		await _wait(0.3)
		await _shot("19c_codex_effect")
		var link: Button = _button_in(kp, "Barrier strip")
		if link != null:
			await _click(link.get_global_rect().get_center())
		fails += _expect(kp.current == "g:strip", "a See-also link jumps to its entry")
		await _key(KEY_ESCAPE)
		await _wait(0.3)
		fails += _expect(app.current.get("panel") == null, "Esc leaves the Codex")
	print("RESEARCH CHECKS: %s" % ("ALL PASSED" if fails == 0 else "%d FAILED" % fails))


## Parks the mouse over empty top-bar space: an open tooltip would take the next Esc.
func _mouse_away() -> void:
	var away := InputEventMouseMotion.new()
	away.position = get_viewport().get_final_transform() * (Vector2(800, 20) + UiKit.view_offset())
	away.global_position = away.position
	Input.parse_input_event(away)
	await _wait(0.2)


## Buys a path of upgrades: T = trunk, a/b/c = the next node on that branch. False on any failure.
func _grow(g, t, path: String) -> bool:
	for ch in path:
		if not g.upgrade_tower(t, "" if ch == "T" else ch):
			return false
	return true

## The first visible button under `root` whose text is exactly `text`, or null.
func _button_in(root: Node, text: String) -> Button:
	if root == null:
		return null
	for b in root.find_children("*", "Button", true, false):
		if (b as Button).text == text and (b as Button).is_visible_in_tree():
			return b
	return null

## Clicks the selected tower's upgrade card for `key` ("trunk", "a", "b", "c") in the tower panel.
func _card(key: String) -> void:
	var panel = app.current.hud.popout("tower")
	if panel == null or not panel.cards.has(key):
		print("  (no %s card to click)" % key)
		return
	await _click(panel.cards[key].get_global_rect().get_center())
	await get_tree().process_frame


## Every failed expectation in the run; the tour exits with code 1 if there are any.
var failed_total := 0


func _expect(cond: bool, what: String) -> int:
	if not cond:
		failed_total += 1
	print("  %s %s" % ["ok  " if cond else "FAIL", what])
	return 0 if cond else 1


func _wheel(canvas_pos: Vector2, up: bool) -> void:
	var p: Vector2 = get_viewport().get_final_transform() * (canvas_pos + UiKit.view_offset())
	var mv := InputEventMouseMotion.new()
	mv.position = p
	mv.global_position = p
	Input.parse_input_event(mv)
	await get_tree().process_frame
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN
	ev.pressed = true
	ev.position = p
	ev.global_position = p
	Input.parse_input_event(ev)
	var rel := InputEventMouseButton.new()
	rel.button_index = ev.button_index
	rel.pressed = false
	rel.position = p
	rel.global_position = p
	Input.parse_input_event(rel)
	await get_tree().process_frame
	await get_tree().process_frame


func _hold_key(code: Key, secs: float) -> void:
	var ev := InputEventKey.new()
	ev.keycode = code
	ev.physical_keycode = code
	ev.pressed = true
	Input.parse_input_event(ev)
	await _wait(secs)
	var up := InputEventKey.new()
	up.keycode = code
	up.physical_keycode = code
	Input.parse_input_event(up)
	await get_tree().process_frame


func _key(code: Key) -> void:
	for pressed in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = code
		ev.physical_keycode = code
		ev.pressed = pressed
		Input.parse_input_event(ev)
		await get_tree().process_frame
	await get_tree().process_frame


func _click(canvas_pos: Vector2, button := MOUSE_BUTTON_LEFT) -> void:
	var win_pos: Vector2 = get_viewport().get_final_transform() * (canvas_pos + UiKit.view_offset())
	var motion := InputEventMouseMotion.new()
	motion.position = win_pos
	motion.global_position = win_pos
	Input.parse_input_event(motion)
	await get_tree().process_frame
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = button
		ev.position = win_pos
		ev.global_position = win_pos
		ev.pressed = pressed
		Input.parse_input_event(ev)
		await get_tree().process_frame
	await get_tree().process_frame


func _bot_game(map_id: String, waves: int, mode := "medium"):
	var g = Game.new(map_id, 555, mode)
	g.emit_events = false
	var bot = Bot.new(g)
	var ticks := 0
	while not g.is_over() and ticks < 400000:
		if g.state == Game.State.BUILD and g.wave >= waves:
			break
		bot.update(Game.TICK)
		g.tick(Game.TICK)
		ticks += 1
	bot.act()
	g.emit_events = true
	g.events.clear()
	return g


func _wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout


func _shot(shot_name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	var path := ProjectSettings.globalize_path(OUT_DIR + shot_name + ".png")
	var err := img.save_png(path)
	print("shot %-26s %dx%d %s" % [shot_name, img.get_width(), img.get_height(), error_string(err)])
