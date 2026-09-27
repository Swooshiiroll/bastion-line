extends Node
## Gameplay screen controller: owns the Game, World and HUD; routes input, sound, saves and modals.

const Game = preload("res://scripts/core/Game.gd")
const World = preload("res://scripts/view/World.gd")
const Hud = preload("res://scripts/ui/Hud.gd")
const PauseMenu = preload("res://scripts/ui/PauseMenu.gd")
const EndScreen = preload("res://scripts/ui/EndScreen.gd")
const SettingsPanel = preload("res://scripts/ui/SettingsPanel.gd")
const ConfirmDialog = preload("res://scripts/ui/ConfirmDialog.gd")
const UiKit = preload("res://scripts/ui/UiKit.gd")
const Towers = preload("res://data/towers.gd")
const Tower = preload("res://scripts/entities/Tower.gd")
const Research = preload("res://scripts/core/Research.gd")
const Enemies = preload("res://data/enemies.gd")
const Waves = preload("res://data/waves.gd")
const Difficulty = preload("res://data/difficulty.gd")

var app
var game
var world
var hud
var speed := 1
var paused := false
var modal: Control = null
var _modal_layer: CanvasLayer
var _ended := false
## Set when a tower was picked from the shop, so the shop reopens once it is placed.
var shop_return := false
var _last_click_ms := -100000
const DOUBLE_CLICK_MS := 350

## RP the medal paid this run (shown again on the end screen).
var _medal_rp := 0


func setup_new(map_id: String, difficulty := "medium") -> void:
	game = Game.new(map_id, 0, difficulty, SaveManager.research_owned())


func setup_with(g) -> void:
	game = g
	speed = clampi(int(g.speed), 1, 3)


func _ready() -> void:
	var back := CanvasLayer.new()
	back.layer = -1
	add_child(back)
	back.add_child(UiKit.starfield())
	world = World.new()
	world.base_pos = Hud.FIELD.position
	add_child(world)
	world.setup(game)
	world.field_clicked.connect(_on_field_clicked)
	hud = Hud.new()
	hud.screen = self
	add_child(hud)
	_modal_layer = CanvasLayer.new()
	_modal_layer.layer = 20
	add_child(_modal_layer)
	if game.wave == 0:
		var dd: Dictionary = Difficulty.DIFFICULTIES[game.difficulty]
		hud.show_banner(str(game.map_def.name).to_upper(), "%s: %d rounds, %d core shields. Deploy towers, then press Space to launch round 1." % [dd.name, game.final_round(), game.lives], UiKit.ACCENT)
	else:
		hud.show_banner("Welcome back", "Round %d cleared. Core %d, credits %d." % [game.wave, game.lives, game.gold], UiKit.TEXT)


func _process(delta: float) -> void:
	world.damage_numbers = bool(SaveManager.setting("damage_numbers"))
	# Arrow keys pan the battlefield unless a menu is using them.
	world.keys_enabled = modal == null and not hud.is_open("research") and not hud.is_open("tree")
	if not paused:
		for ev in world.simulate(delta, speed):
			_handle_event(ev)
	hud.refresh(delta)


func _handle_event(ev: Dictionary) -> void:
	match ev.type:
		"fire":
			match ev.tower:
				"arrow":
					Sfx.play("arrow", -12.0)
				"missile":
					Sfx.play("missile", -8.0)
				_:
					Sfx.play("cannon", -10.0)
		"laser_lock":
			Sfx.play("laser", -12.0)
		"missile_hit":
			Sfx.play("boom", -14.0)
		"splash":
			Sfx.play("boom", -8.0)
		"chain":
			Sfx.play("zap", -9.0)
		"tracer":
			Sfx.play("sniper", -8.0)
		"frost":
			Sfx.play("frost", -14.0)
		"gravity":
			Sfx.play("boom", -12.0)
		"gate":
			Sfx.play("upgrade", -8.0, 0.0)
			hud.toast("Switch gate: %s" % game.gate_label(int(ev.group)), UiKit.GOLD)
		"rubble_cleared":
			Sfx.play("sell", -6.0, 0.0)
			hud.toast("Rubble cleared  -%d cr" % int(ev.cost), UiKit.DIM)
		"emp":
			Sfx.play("zap", -6.0)
			if int(ev.hit) > 0:
				hud.toast("Jammer EMP: %d tower%s offline" % [int(ev.hit), "" if int(ev.hit) == 1 else "s"], UiKit.BAD)
		"split":
			Sfx.play("death", -10.0)
		"shield_break":
			Sfx.play("zap", -16.0)
		"flak_hit":
			Sfx.play("boom", -18.0)
		"kill":
			if ev.boss:
				Sfx.play("boss_death", 0.0, 0.0)
				hud.toast("%s destroyed!  +%d cr" % [Enemies.ENEMIES[ev.enemy].name, int(ev.bounty)], UiKit.GOLD)
			else:
				Sfx.play("death", -12.0)
		"income":
			var total := 0
			for p in ev.paid:
				total += int(p[1])
				if p[0].x < 0.0:
					hud.toast("Reserve Bank interest  +%d cr" % int(p[1]), UiKit.GOLD)
			if total > 0:
				Sfx.play("coin", -8.0)
		"leak":
			Sfx.play("leak", -4.0)
			hud.flash_lives()
		"wave_start":
			if ev.boss:
				Sfx.play("boss", -2.0, 0.0)
				var title := "FINAL ROUND %d" if _is_final(int(ev.wave)) else "BOSS ROUND %d"
				hud.show_banner(title % ev.wave, _boss_line(int(ev.wave)), UiKit.BAD)
			else:
				Sfx.play("wave", -6.0, 0.0)
				var sub := "Final round!" if _is_final(int(ev.wave)) else ""
				hud.show_banner("Round %d" % ev.wave, sub)
		"wave_clear":
			Sfx.play("coin", -8.0, 0.0)
			hud.toast("Round %d cleared   +%d cr" % [ev.wave, ev.bonus], UiKit.GOLD)
		"early_call":
			hud.toast("Early call bonus   +%d cr" % ev.bonus, UiKit.GOLD)
		"field_clear":
			# Progress counts toward round milestones even if the run is quit later.
			SaveManager.record_run(game.map_id, game.difficulty, game.wave, false, game.endless)
			_autosave()
		"medal":
			_on_medal()
		"build":
			Sfx.play("build", -6.0)
		"upgrade":
			Sfx.play("upgrade", -6.0, 0.0)
		"sell":
			Sfx.play("sell", -6.0, 0.0)
		"heal":
			if ev.active:
				Sfx.play("heal", -16.0)
		"minions":
			if ev.get("enemy", "") == "leviathan":
				hud.toast("The Leviathan launches a Locust swarm!", UiKit.BAD)
			else:
				hud.toast("The Overmind is spawning nanites!", UiKit.BAD)
		"phase":
			Sfx.play("boom", -4.0, 0.0)
			hud.toast("The Colossus sheds its armor and drops Siege Mechs!", UiKit.BAD)
		"blink":
			Sfx.play("warp", -22.0)
		"burrow":
			Sfx.play("boom", -24.0)
		"gameover":
			_on_gameover()
		"meteor_cast":
			Sfx.play("meteor_fall", -4.0, 0.0)
		"meteor_impact":
			Sfx.play("meteor_impact", 0.0, 0.0)
		"warp":
			Sfx.play("warp", -2.0, 0.0)
			hud.show_banner("Chrono Field", "", UiKit.BLUE)


func _is_final(w: int) -> bool:
	return not game.endless and w == game.final_round()


func _boss_line(w: int) -> String:
	var names: Array = []
	for grp in game.preview_wave(w):
		var ed: Dictionary = Enemies.ENEMIES[grp.t]
		if bool(ed.get("boss", false)) and not names.has(ed.name):
			names.append(ed.name)
	if _is_final(w):
		return "Every boss they have: %s. Hold this and the medal is yours." % ", ".join(PackedStringArray(names))
	if names.has("Colossus"):
		return "A Colossus approaches. It can't be stunned and sheds armor as it breaks."
	if names.has("Leviathan"):
		return "A Leviathan approaches. Only anti-air can reach it."
	if names.has("Overmind"):
		return "The Overmind approaches. Don't let it reach the core."
	return "A Dreadnought approaches. Armored and slow-resistant."


# --- Player actions (called by HUD buttons and hotkeys) -------------------------------------

func select_build(type: String) -> void:
	if game.is_over():
		return
	world.ability_target = ""
	if world.build_type == type:
		world.build_type = ""
	else:
		world.build_type = type
		world.selected_tower = null


func cancel() -> void:
	if world.ability_target != "":
		world.ability_target = ""
	elif world.build_type != "":
		world.build_type = ""
		_return_to_shop()
	elif world.selected_tower != null:
		world.selected_tower = null


# --- Pop-outs --------------------------------------------------------------------------------

## A tower picked from the shop: close the shop while it's placed, reopen it afterwards.
func shop_pick(type: String) -> void:
	if game.is_over():
		return
	select_build(type)
	if world.build_type == type:
		shop_return = true
		hud.close("shop")


func _return_to_shop() -> void:
	if shop_return:
		shop_return = false
		if not game.is_over():
			hud.open("shop")


func toggle_shop() -> void:
	shop_return = false
	if hud.is_open("shop"):
		hud.close("shop")
	else:
		hud.open("shop")


func open_tree() -> void:
	if hud.is_open("tree"):
		hud.close("tree")
	elif world.selected_tower != null:
		hud.open("tree")
	else:
		hud.toast("Select a tower first", UiKit.DIM)


func toggle_intel() -> void:
	if hud.is_open("intel"):
		hud.close("intel")
	else:
		hud.open("intel")


func toggle_research() -> void:
	if hud.is_open("research"):
		close_popout("research")
	elif not _ended:
		hud.open("research")
		paused = true


func close_popout(kind: String) -> void:
	hud.close(kind)
	if kind == "research" and modal == null:
		paused = false


## Esc's first job: close every open pop-out (and stop building or aiming).
func close_popouts() -> void:
	var had_research: bool = hud.is_open("research")
	hud.close_all()
	shop_return = false
	world.build_type = ""
	world.ability_target = ""
	if had_research and modal == null:
		paused = false


func _on_field_clicked(cell: Vector2i, button: int, shift: bool, pos: Vector2) -> void:
	if modal != null or game.is_over():
		return
	if button == MOUSE_BUTTON_RIGHT:
		cancel()
		return
	if button != MOUSE_BUTTON_LEFT:
		return
	# Clicking the field with nothing picked up closes the shop (the click still selects a tower).
	if hud.is_open("shop") and world.build_type == "" and world.ability_target == "":
		hud.close("shop")
		shop_return = false
	if world.ability_target == "meteor":
		if game.cast_meteor(pos):
			world.ability_target = ""
		else:
			world.ability_target = ""
			hud.toast(game.ability_block_reason("meteor"), UiKit.BAD)
		return
	if world.build_type != "":
		var at: Vector2i = World.anchor_for(world.build_type, cell, pos)
		var err: String = game.placement_error(world.build_type, at)
		if err == "":
			var t = game.place_tower(world.build_type, at)
			if not shift:
				world.build_type = ""
				world.selected_tower = t
				_return_to_shop()
		elif game.tower_at.has(cell):
			world.build_type = ""
			shop_return = false
			world.selected_tower = game.tower_at[cell]
			Sfx.play("click", -8.0, 0.0)
		else:
			hud.toast(err, UiKit.BAD)
			Sfx.play("error", -6.0, 0.0)
		return
	if game.has_rubble(cell):
		world.selected_tower = null
		var why: String = game.rubble_error(cell)
		if why == "":
			game.clear_rubble(cell)
		else:
			hud.toast(why, UiKit.BAD)
			Sfx.play("error", -6.0, 0.0)
		return
	var gi: int = game.grid.gate_group_at(cell)
	if gi >= 0:
		world.selected_tower = null
		if not game.cycle_gate(gi):
			hud.toast("The gate is recharging (%ds)" % ceili(float(game.gate_cd[gi])), UiKit.BAD)
			Sfx.play("error", -6.0, 0.0)
		return
	if game.tower_at.has(cell):
		var t = game.tower_at[cell]
		var now := Time.get_ticks_msec()
		# Double-click a tower to open its upgrade tree.
		if world.selected_tower == t and now - _last_click_ms < DOUBLE_CLICK_MS:
			if not hud.is_open("tree"):
				hud.open("tree")
		world.selected_tower = t
		_last_click_ms = now
		Sfx.play("click", -8.0, 0.0)
	else:
		world.selected_tower = null


## U, I and O: at tier 1, U upgrades to tier 2. After that they buy the next upgrade on branch A, B or
## C (the branch's specialization first, its mastery last).
func upgrade_selected(choice := 0) -> void:
	var t = world.selected_tower
	if t == null:
		return
	if t.trunk < 2:
		if choice != 0:
			return
		if not game.upgrade_tower(t):
			hud.toast("Not enough credits to upgrade", UiKit.BAD)
			Sfx.play("error", -6.0, 0.0)
		return
	var key: String = Tower.BRANCHES[clampi(choice, 0, 2)]
	var why: String = t.block_reason(key)
	if why != "":
		hud.toast(why, UiKit.DIM)
		Sfx.play("error", -10.0, 0.0)
		return
	if not game.upgrade_tower(t, key):
		hud.toast("Not enough credits to upgrade", UiKit.BAD)
		Sfx.play("error", -6.0, 0.0)
		return
	var b: Dictionary = t.branch(key)
	if t.mastered and t.primary() == key:
		hud.toast("MASTERY: %s online" % t.display_name(), UiKit.GOLD)
	elif int(t.depth[key]) == 1:
		hud.toast("%s online" % str(b.nodes[0].name), UiKit.GOLD)
	else:
		hud.toast("%s installed" % str(b.nodes[int(t.depth[key]) - 1].name), UiKit.TEXT)


func sell_selected() -> void:
	var t = world.selected_tower
	if t == null:
		return
	if game.sell_tower(t) > 0:
		world.selected_tower = null


func cycle_target() -> void:
	var t = world.selected_tower
	if t != null and not t.is_support() and not (t.type in ["frost", "gravity"]):
		game.cycle_mode(t)


## Only for towers that hit both air and ground (G).
func cycle_priority() -> void:
	var t = world.selected_tower
	if t != null and has_priority(t):
		game.cycle_priority(t)


static func has_priority(t) -> bool:
	return t.hits_air() and t.hits_ground() and not t.is_support()


func use_ability(id: String) -> void:
	var why: String = game.ability_block_reason(id)
	if why != "":
		hud.toast(why, UiKit.BAD)
		Sfx.play("error", -6.0, 0.0)
		return
	if id == "warp":
		game.cast_warp()
		return
	if world.ability_target == id:
		world.ability_target = ""
		return
	world.ability_target = id
	world.build_type = ""
	world.selected_tower = null


func start_wave() -> void:
	if not game.start_wave():
		Sfx.play("error", -6.0, 0.0)


func toggle_speed() -> void:
	speed = speed % 3 + 1
	game.speed = speed


func toggle_auto() -> void:
	game.auto_start = not game.auto_start
	game.auto_timer = 0.0
	hud.toast("Auto-start %s" % ("on: next round starts 5s after each clear" if game.auto_start else "off"), UiKit.DIM)


func save_now() -> bool:
	if not game.can_save():
		hud.toast("You can only save between rounds", UiKit.BAD)
		Sfx.play("error", -6.0, 0.0)
		return false
	if SaveManager.save_run(game):
		hud.toast("Game saved", UiKit.GOOD)
		return true
	hud.toast("Saving failed!", UiKit.BAD)
	return false


func _autosave() -> void:
	if game.can_save() and SaveManager.save_run(game):
		hud.toast("Autosaved", UiKit.DIM)


# --- Modals ----------------------------------------------------------------------------------

func _show_modal(c: Control) -> void:
	_close_modal()
	modal = c
	_modal_layer.add_child(c)


func _close_modal() -> void:
	if modal != null:
		UiKit.dismiss(modal)
		modal = null


func open_pause() -> void:
	if _ended:
		return
	paused = true
	world.build_type = ""
	hud.close_all()
	shop_return = false
	_show_modal(PauseMenu.new(self))


func resume() -> void:
	_close_modal()
	paused = false


func open_settings() -> void:
	_show_modal(SettingsPanel.new(func(): open_pause()))


func quit_to_menu() -> void:
	if game.state == Game.State.WAVE:
		_show_modal(ConfirmDialog.new(
			"Quit to the main menu?\nThe current round is in progress; you'll resume from your last save (start of this round).",
			func(): app.show_menu(),
			func(): open_pause(),
			"Quit", "Keep playing"))
	else:
		if game.can_save():
			SaveManager.save_run(game)
		app.show_menu()


func restart() -> void:
	app.start_game(game.map_id, game.difficulty)


## Pause-menu restart: asks first, since this run's progress is lost.
func confirm_restart() -> void:
	var dd: Dictionary = Difficulty.DIFFICULTIES[game.difficulty]
	_show_modal(ConfirmDialog.new(
		"Restart %s on %s from round 1?\nThis run's progress is lost." % [game.map_def.name, dd.name],
		func(): restart(),
		func(): open_pause(),
		"Restart", "Keep playing"))


func map_select() -> void:
	app.show_map_select()


func _on_gameover() -> void:
	_ended = true
	hud.close_all()
	shop_return = false
	world.build_type = ""
	Sfx.play("gameover", -2.0, 0.0)
	var rp_before: int = SaveManager.research_earned()
	SaveManager.record_run(game.map_id, game.difficulty, game.wave, game.medal, game.endless)
	SaveManager.delete_run()
	_show_modal(EndScreen.new(self, game.medal, SaveManager.research_earned() - rp_before + _medal_rp))


## The mode's last round is held: record the medal now, then play straight on into endless mode.
func _on_medal() -> void:
	var rp_before: int = SaveManager.research_earned()
	SaveManager.record_run(game.map_id, game.difficulty, game.wave, true, false)
	_medal_rp = SaveManager.research_earned() - rp_before
	Sfx.play("victory", -2.0, 0.0)
	var dd: Dictionary = Difficulty.DIFFICULTIES[game.difficulty]
	var rp := "  +%d RP" % _medal_rp if _medal_rp > 0 else ""
	hud.show_banner("%s MEDAL EARNED" % str(dd.name).to_upper(), "All %d rounds held on %s.%s  Endless mode begins: how long can you last?" % [game.wave, game.map_def.name, rp], dd.color)
	hud.hold_banner(5.0)
	_autosave()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if modal != null:
		if event.keycode == KEY_ESCAPE and not _ended:
			if modal is PauseMenu:
				resume()
			else:
				open_pause()
			get_viewport().set_input_as_handled()
		return
	if hud.is_open("research"):
		# The battle is paused behind the lab: only closing keys work.
		if event.keycode in [KEY_ESCAPE, KEY_R]:
			if not hud.popout("research").has_modal():
				if event.keycode == KEY_ESCAPE:
					close_popouts()
				else:
					close_popout("research")
			get_viewport().set_input_as_handled()
		return
	var handled := true
	match event.keycode:
		KEY_B:
			toggle_shop()
		KEY_E:
			open_tree()
		KEY_R:
			toggle_research()
		KEY_N:
			toggle_intel()
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			select_build(Towers.ORDER[event.keycode - KEY_1])
		KEY_0:
			select_build(Towers.ORDER[9])
		KEY_MINUS:
			select_build(Towers.ORDER[10])
		KEY_EQUAL:
			select_build(Towers.ORDER[11])
		KEY_BRACKETLEFT:
			select_build(Towers.ORDER[12])
		KEY_BRACKETRIGHT:
			select_build(Towers.ORDER[13])
		KEY_BACKSLASH:
			select_build(Towers.ORDER[14])
		KEY_SPACE:
			start_wave()
		KEY_Q:
			use_ability("meteor")
		KEY_W:
			use_ability("warp")
		KEY_U:
			upgrade_selected(0)
		KEY_I:
			upgrade_selected(1)
		KEY_O:
			upgrade_selected(2)
		KEY_X, KEY_DELETE:
			sell_selected()
		KEY_T:
			cycle_target()
		KEY_G:
			cycle_priority()
		KEY_HOME:
			world.reset_view()
		KEY_F3:
			SaveManager.set_setting("show_fps", not bool(SaveManager.setting("show_fps")))
		KEY_F:
			toggle_speed()
		KEY_A:
			toggle_auto()
		KEY_P:
			open_pause()
		KEY_ESCAPE:
			# The master close: pop-outs first, then build/aim/selection, then the pause menu.
			if hud.any_open():
				close_popouts()
			elif world.build_type != "" or world.selected_tower != null or world.ability_target != "":
				shop_return = false
				cancel()
			else:
				open_pause()
		_:
			handled = false
	if handled:
		get_viewport().set_input_as_handled()
