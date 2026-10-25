extends Node
## Headless test suite. Run with:
##   godot --headless --path <project> res://tests/TestRunner.tscn
## Exits with code 0 when every check passes, 1 otherwise.

const Game = preload("res://scripts/core/Game.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const Bot = preload("res://scripts/core/Bot.gd")
const SaveCodec = preload("res://scripts/core/SaveCodec.gd")
const Lore = preload("res://scripts/core/Lore.gd")
const UpgradeRules = preload("res://scripts/core/UpgradeRules.gd")
const Glossary = preload("res://data/glossary.gd")
const Grid = preload("res://scripts/core/Grid.gd")
const Enemy = preload("res://scripts/entities/Enemy.gd")
const EnemyTraits = preload("res://scripts/core/EnemyTraits.gd")
const GameScreen = preload("res://scripts/ui/GameScreen.gd")
const Modifiers = preload("res://data/modifiers.gd")
const Tower = preload("res://scripts/entities/Tower.gd")
const Projectile = preload("res://scripts/entities/Projectile.gd")
const Towers = preload("res://data/towers.gd")
const Enemies = preload("res://data/enemies.gd")
const Waves = preload("res://data/waves.gd")
const Maps = preload("res://data/maps.gd")
const Abilities = preload("res://data/abilities.gd")
const Research = preload("res://scripts/core/Research.gd")
const ResearchData = preload("res://data/research.gd")
const Difficulty = preload("res://data/difficulty.gd")
const EnemyArt = preload("res://scripts/view/enemies/EnemyArt.gd")
const EnemyMoves = preload("res://scripts/entities/EnemyMoves.gd")
const Tuner = preload("res://scripts/dev/Tuner.gd")
const TunerPanel = preload("res://scripts/dev/TunerPanel.gd")
const ShopPanel = preload("res://scripts/ui/hud/ShopPanel.gd")
const TreePopOut = preload("res://scripts/ui/hud/TreePopOut.gd")

const SANDBOX := "user://test_sandbox/"
const SIM_DT := 1.0 / 60.0

var failures: Array = []
var checks := 0
var current := ""
var only := ""


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--only="):
			only = a.substr(7)
	_run.call_deferred()


func _run() -> void:
	var t0 := Time.get_ticks_msec()
	var saved_dir: String = SaveManager.base_dir
	SaveManager.set_base_dir(SANDBOX)
	SaveManager.delete_run()
	for f in [SaveManager.profile_path(), SaveManager.profile_path() + ".tmp"]:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(f)
	SaveManager.load_profile()
	# Run order: this list first (some tests set up state for later ones), then any other test_*
	# method, so a new test never silently goes unrun.
	var tests := [
		"test_data_integrity",
		"test_map_geometry",
		"test_terrain_sites",
		"test_rubble",
		"test_lane_hazards",
		"test_switch_gates",
		"test_armor_math",
		"test_slow_rules",
		"test_targeting_modes",
		"test_flyer_rules",
		"test_placement_rules",
		"test_economy",
		"test_wave_clear_and_early_call",
		"test_shaman_heal",
		"test_warlord_minions",
		"test_round_generation",
		"test_abilities",
		"test_difficulty_modes",
		"test_music_synthesis",
		"test_save_roundtrip_and_determinism",
		"test_save_error_handling",
		"test_profile_records",
		"test_research_data",
		"test_research_points",
		"test_research_profile",
		"test_research_effects",
		"test_knowledge_base",
		"test_footprint",
		"test_target_priority",
		"test_mastery_needs_all_research",
		"test_phantom_cloak",
		"test_aegis_barrier",
		"test_hydra_split",
		"test_jammer_emp",
		"test_burrower",
		"test_blink_stalker",
		"test_mender_regen",
		"test_rally_beacon",
		"test_bulwark",
		"test_rampart",
		"test_is_boss_round",
		"test_launch_view",
		"test_sandbox_resources",
		"test_sandbox_spawn",
		"test_sandbox_call_round",
		"test_sandbox_clear_field",
		"test_sandbox_max_branch",
		"test_sandbox_no_medal",
		"test_sandbox_dps",
		"test_leviathan",
		"test_colossus",
		"test_v3_flyers",
		"test_crowd_control_limits",
		"test_no_towers_loses",
		"test_bot_playthroughs",
		"test_bot_full_research",
		"test_bot_new_roster",
	]
	var extra: Array = []
	for m in get_method_list():
		var mn := str(m.name)
		if mn.begins_with("test_") and not tests.has(mn) and not extra.has(mn):
			extra.append(mn)
	extra.sort()
	for name in tests:
		if not has_method(name):
			failures.append("%s is listed but not defined" % name)
	tests = tests.filter(func(n): return has_method(n)) + extra
	for name in tests:
		if only != "" and not name.contains(only):
			continue
		current = name
		var before := failures.size()
		var ts := Time.get_ticks_msec()
		call(name)
		var ok := failures.size() == before
		print("%s  %s  (%d ms)" % ["PASS" if ok else "FAIL", name, Time.get_ticks_msec() - ts])
	SaveManager.delete_run()
	SaveManager.set_base_dir(saved_dir)
	print("")
	print("%d checks, %d failed, %.1f s" % [checks, failures.size(), (Time.get_ticks_msec() - t0) / 1000.0])
	for f in failures:
		print("  FAILED: ", f)
	print("RESULT: ", "OK" if failures.is_empty() else "FAILURES")
	get_tree().quit(0 if failures.is_empty() else 1)


func check(cond: bool, msg: String) -> void:
	checks += 1
	if not cond:
		failures.append("%s: %s" % [current, msg])


func near(a: float, b: float, eps := 0.001) -> bool:
	return absf(a - b) <= eps


## Deep equality that treats 5 and 5.0 as equal (JSON turns ints into floats).
func deep_equal(a, b) -> bool:
	if (a is int or a is float) and (b is int or b is float):
		return near(float(a), float(b), 1e-6)
	if a is Dictionary and b is Dictionary:
		if a.size() != b.size():
			return false
		for k in a:
			if not b.has(k) or not deep_equal(a[k], b[k]):
				return false
		return true
	if a is Array and b is Array:
		if a.size() != b.size():
			return false
		for i in a.size():
			if not deep_equal(a[i], b[i]):
				return false
		return true
	return a == b


func new_game(map_id := "meadow", seed_v := 1234, diff := "medium"):
	var g = Game.new(map_id, seed_v, diff)
	g.emit_events = false
	return g


## Puts an enemy on the field at a given distance along a route and returns it.
func put(g, type: String, dist: float, path_idx := 0, hp_mult := 1.0):
	var e = g.spawn_enemy(type, path_idx, dist, hp_mult, -1)
	g.enemies.append(e)
	return e


func run_until(g, cond: Callable, max_seconds: float) -> bool:
	var ticks := int(max_seconds / SIM_DT)
	for i in ticks:
		if cond.call():
			return true
		g.tick(SIM_DT)
	return cond.call()


## Rough damage per second of a tower level: projectiles, pellets, bomblets and drones included.
# --- Data ------------------------------------------------------------------------------------

func test_data_integrity() -> void:
	check(Towers.ORDER.size() == 20 and Towers.ORDER == Towers.Rework.ORDER, "twenty tower types, each with generated data")
	for type in Towers.ORDER:
		var tr: Dictionary = Towers.Rework.TREES[type]
		check(tr.paths.size() == 3 and not tr.retrofits.is_empty() and tr.retrofits.size() <= 3, "%s: three paths and one to three Retrofits" % type)
		for p in tr.paths:
			check(p.nodes.size() == Tower.BRANCH_STEPS and p.mastery != null, "%s path %s: four upgrades and a mastery" % [type, p.key])
			var all_nodes: Array = p.nodes.duplicate()
			all_nodes.append(p.mastery)
			for nd in all_nodes:
				check(str(nd.name) != "" and str(nd.blurb) != "" and int(nd.cost) > 0, "%s %s %s has a name, description and price" % [type, p.key, nd.name])
		for r in tr.retrofits:
			check(str(r.name) != "" and int(r.cost) > 0, "%s Retrofit %s has a name and price" % [type, r.name])
		var d: Dictionary = Towers.def(type)
		var base: Dictionary = Tower.rework_base(type)
		if not d.support and not d.economy and not (type in ["artillery_cannon", "drone_bay", "cas_gunship"]):
			check(float(base.get("range", 0.0)) > 0.0, "%s has a range" % type)
	check(not Towers.def("mortar_tower").air, "the Mortar can't hit air")

	for w in range(1, 26):
		var groups: Array = Waves.get_wave(w)
		check(not groups.is_empty(), "wave %d not empty" % w)
		for g in groups:
			check(Enemies.ENEMIES.has(g.t), "wave %d enemy %s exists" % [w, g.t])
			check(int(g.n) > 0 and float(g.i) > 0.0, "wave %d group sane" % w)
	check(not Waves.get_wave(5).any(func(g): return g.t == "juggernaut"), "no more Dreadnought every 5th round")
	check(Waves.hp_scale(1) == 1.0 and Waves.speed_scale(1) == 1.0, "round 1 is the base strength")
	var prev_hp := 0.0
	var prev_sp := 0.0
	for w in range(1, 161):
		check(Waves.hp_scale(w) > prev_hp and Waves.speed_scale(w) >= prev_sp, "HP and speed never drop from round to round (%d)" % w)
		prev_hp = Waves.hp_scale(w)
		prev_sp = Waves.speed_scale(w)
	check(near(Waves.speed_scale(200), 1.5) and near(Waves.speed_scale(200, true), 1.25), "speed caps at +50% (bosses +25%)")
	check(Waves.hp_scale(120) > 5.0 * Waves.hp_scale(40), "round 120 is far tougher than round 40")
	check(Waves.bounty_scale(1) == 1.0 and Waves.bounty_scale(-1) == 1.0, "round-1 kills pay the base bounty")
	check(Waves.bounty_scale(95) > Waves.bounty_scale(60) and Waves.bounty_scale(60) > Waves.bounty_scale(20), "kill credits grow with the rounds")
	check(Waves.bounty_scale(95) < Waves.hp_scale(95), "kill credits grow slower than enemy HP")
	var bg = Game.new("meadow", 1)
	var be = bg.spawn_enemy("grunt", 0, 40.0, 1.0, 60)
	bg.enemies.append(be)
	var bg0: int = bg.gold
	bg.damage_enemy(be, 1e12, true, null)
	check(bg.gold - bg0 == int(floor(float(Enemies.ENEMIES.grunt.bounty) * Waves.bounty_scale(60) + 1e-6)), "a round-60 grunt pays its scaled bounty (%d)" % (bg.gold - bg0))
	for t in Waves.COST:
		check(Enemies.ENEMIES.has(t), "%s is an enemy" % t)
		check(Waves.SPACING.has(t), "%s has a spawn spacing" % t)
	for t in Enemies.ORDER:
		check(Enemies.ENEMIES.has(t), "%s is defined" % t)
		check(Waves.COST.has(t), "%s has a threat cost" % t)
		check(Waves.INTRO.has(t) or Enemies.ENEMIES[t].get("boss", false), "%s has an introduction round or is a boss" % t)
	check(Enemies.ORDER.size() == 34 and Enemies.ENEMIES.size() == 34, "34 enemy types")
	var cheapest := 1 << 30
	for type in Towers.ORDER:
		cheapest = mini(cheapest, int(Towers.Rework.TREES[type].cost))
	check(Game.START_GOLD >= cheapest * 3, "starting credits buy a few towers")


func test_map_geometry() -> void:
	check(Maps.ORDER.size() == 6, "six sectors")
	for id in Maps.ORDER:
		var m: Dictionary = Maps.MAPS[id]
		check(m.layout.size() == Grid.ROWS, "%s layout has %d rows" % [id, Grid.ROWS])
		for row in m.layout:
			check(str(row).length() == Grid.COLS, "%s layout rows are %d wide" % [id, Grid.COLS])
			for ch in str(row):
				check(ch in [".", "#", "H", "P", "R", "=", "~", "^", "G"], "%s uses known tile '%s'" % [id, ch])
		var grid = Grid.new(id)
		# Lane glyphs and route cells must agree exactly.
		for y in Grid.ROWS:
			for x in Grid.COLS:
				var c := Vector2i(x, y)
				var lane_glyph: bool = Grid.LANE_CHARS.contains(grid.tile_at(c))
				check(lane_glyph == grid.path_cells.has(c), "%s tile %s: lane glyph matches the routes" % [id, c])
		for pts in grid.waypoints:
			check(not Grid.in_bounds(pts[0]), "%s route starts off-grid" % id)
			check(not Grid.in_bounds(pts[pts.size() - 1]), "%s route ends off-grid" % id)
			for i in range(1, pts.size()):
				var a: Vector2i = pts[i - 1]
				var b: Vector2i = pts[i]
				check(a.x == b.x or a.y == b.y, "%s segment %s->%s axis-aligned" % [id, a, b])
		for i in grid.ground_paths.size():
			var curve: Curve2D = grid.ground_paths[i]
			check(curve.get_baked_length() > 500.0, "%s route %d has real length" % [id, i])
			check(grid.air_paths[i].get_baked_length() < curve.get_baked_length(), "%s flyers take a shortcut" % id)
			# Rounded corners keep enemies inside lane tiles.
			var d := 0.0
			var inside := true
			while d < curve.get_baked_length():
				var c: Vector2i = Grid.world_to_cell(curve.sample_baked(d))
				if Grid.in_bounds(c) and not grid.path_cells.has(c):
					inside = false
				d += 6.0
			check(inside, "%s route %d stays on its lane tiles" % [id, i])
		# Forks: shared prefix, a G tile at the fork, and rerouting distance before divergence.
		var gates := 0
		for y in Grid.ROWS:
			for x in Grid.COLS:
				if grid.tile_at(Vector2i(x, y)) == "G":
					gates += 1
		var forks := 0
		for group in grid.groups:
			if group.routes.size() < 2:
				check(group.fork == null, "%s single-route group has no fork" % id)
				continue
			forks += 1
			check(group.fork != null and grid.tile_at(group.fork) == "G", "%s fork %s sits on a G tile" % [id, group.fork])
			check(group.labels.size() == group.routes.size() and group.labels[0] != group.labels[1], "%s fork routes leave in different directions %s" % [id, str(group.labels)])
			var c0: Curve2D = grid.ground_paths[group.routes[0]]
			var c1: Curve2D = grid.ground_paths[group.routes[1]]
			var same := true
			var dd := 0.0
			while dd < group.fork_dist:
				if c0.sample_baked(dd).distance_to(c1.sample_baked(dd)) > 1.5:
					same = false
				dd += 4.0
			check(same, "%s routes coincide until the fork" % id)
			check(c0.sample_baked(group.fork_dist + 80.0).distance_to(c1.sample_baked(group.fork_dist + 80.0)) > 20.0, "%s routes diverge after the fork" % id)
		check(gates == forks, "%s has one G tile per fork (%d/%d)" % [id, gates, forks])
		var buildable := 0
		for y in Grid.ROWS:
			for x in Grid.COLS:
				if grid.is_buildable(Vector2i(x, y)):
					buildable += 1
		check(buildable >= 110, "%s has enough open tiles (%d)" % [id, buildable])
		var specials := {"H": 0, "P": 0, "R": 0}
		for c in grid.tiles:
			if specials.has(grid.tiles[c]):
				specials[grid.tiles[c]] += 1
		check(specials.H > 0 and specials.P > 0 and specials.R > 0, "%s has high ground, power nodes and rubble %s" % [id, str(specials)])


# --- The battlefield: special tiles, hazards, switch gates ----------------------------------

func test_terrain_sites() -> void:
	var g = new_game("meadow")
	g.gold = 5000
	var plain = g.place_tower("gun_turret", Vector2i(2, 3))
	var high = g.place_tower("gun_turret", Vector2i(11, 5))
	var power = g.place_tower("gun_turret", Vector2i(7, 6))
	check(high.site == "H" and power.site == "P" and plain.site == "", "towers know the tile they stand on")
	check(near(high.get_range(), plain.get_range() * 1.15), "high ground: +15%% range (%.1f)" % high.get_range())
	check(near(power.eff_damage(), plain.eff_damage() * 1.15) and near(power.get_range(), plain.get_range()), "power node: +15%% damage, no range")
	var amp = g.place_tower("boost_tower", Vector2i(12, 5))
	check(near(amp.get_range(), float(Tower.rework_base("boost_tower").range) * 1.15), "high ground widens a Boost Tower's field too")
	var data := SaveCodec.encode(g)
	var res := SaveCodec.decode(data)
	check(res.has("game") and res.game.tower_at[Vector2i(11, 5)].site == "H", "sites come back after loading")


func test_rubble() -> void:
	var g = new_game("meadow")
	var r := Vector2i(16, 5)
	check(g.has_rubble(r) and not g.is_buildable(r), "rubble blocks building")
	check(g.placement_error("gun_turret", r).contains("Rubble"), "placement explains rubble (%s)" % g.placement_error("gun_turret", r))
	g.gold = 30
	check(not g.clear_rubble(r) and g.rubble_error(r).contains("40"), "clearing needs 40 cr")
	g.gold = 100
	check(g.clear_rubble(r) and g.gold == 60, "clearing costs 40 cr")
	g.gold += 100
	check(not g.has_rubble(r) and g.is_buildable(r) and g.placement_error("gun_turret", r) == "", "cleared rubble is buildable")
	check(not g.clear_rubble(r) and not g.clear_rubble(Vector2i(2, 3)), "only rubble can be cleared, once")
	g.place_tower("gun_turret", r)
	var data := SaveCodec.encode(g)
	check(data.cleared == [[16, 5]], "cleared rubble is saved")
	var res := SaveCodec.decode(JSON.parse_string(JSON.stringify(data)))
	check(res.has("game") and res.game.cleared.has(r) and res.game.tower_at.has(r), "cleared rubble and its tower load back")
	var bad := data.duplicate(true)
	bad["cleared"] = [[2, 3]]
	check(SaveCodec.decode(bad).has("error"), "a save clearing non-rubble is rejected")
	var no_clear := data.duplicate(true)
	no_clear["cleared"] = []
	check(SaveCodec.decode(no_clear).has("error"), "a tower on uncleared rubble is rejected")


func test_lane_hazards() -> void:
	var g = new_game("canyon")
	g.state = Game.State.WAVE
	var grid = g.grid
	var sludge := Vector2i(3, 4)
	var shock_g = new_game("crossroads")
	check(grid.hazards.get(sludge) == "sludge", "Red Rift has sludge at %s" % sludge)
	# Put a drone right on the sludge by walking it there along its route.
	var e = put(g, "grunt", 10.0)
	var curve: Curve2D = grid.ground_paths[0]
	e.distance = curve.get_closest_offset(Grid.cell_center(sludge))
	g.tick(SIM_DT)
	check(near(e.slow_amount, 0.3), "sludge slows ground enemies 30%% (%.2f)" % e.slow_amount)
	var boss = put(g, "juggernaut", 10.0)
	boss.distance = e.distance
	g.tick(SIM_DT)
	check(near(boss.slow_amount, 0.15), "bosses resist half the sludge")
	var bat = put(g, "bat", 10.0)
	bat.pos = Grid.cell_center(sludge)
	g.tick(SIM_DT)
	check(bat.slow_amount == 0.0, "flyers skim over sludge")
	shock_g.state = Game.State.WAVE
	var shock := Vector2i(3, 2)
	check(shock_g.grid.hazards.get(shock) == "shock", "Nexus Station has a shock strip at %s" % shock)
	var s = put(shock_g, "grunt", 10.0, 0, 10.0)
	s.distance = shock_g.grid.ground_paths[0].get_closest_offset(Grid.cell_center(shock))
	var hp0: float = s.hp
	shock_g.tick(SIM_DT)
	check(near(hp0 - s.hp, s.max_hp * 0.04 * SIM_DT, 0.01), "shock deals 4%% of max HP per second")
	var sb = put(shock_g, "juggernaut", 10.0, 0, 3.0)
	sb.distance = s.distance
	var b0: float = sb.hp
	shock_g.tick(SIM_DT)
	check(near(b0 - sb.hp, sb.max_hp * 0.01 * SIM_DT, 0.01), "bosses take 1%% per second")


func test_switch_gates() -> void:
	var g = new_game("delta")
	var grid = g.grid
	check(grid.groups.size() == 1 and grid.groups[0].routes.size() == 2 and grid.groups[0].fork == Vector2i(4, 5), "Cryo Delta forks at the gate")
	check(grid.gate_group_at(Vector2i(4, 5)) == 0 and grid.gate_group_at(Vector2i(3, 5)) == -1, "the gate tile finds its group")
	check(g.gate_label(0) == "Split", "gates start split")
	# Split: spawns alternate between the two routes.
	g.start_wave()
	var seen := {}
	run_until(g, func(): return g.enemies.size() >= 4, 20.0)
	for e in g.enemies:
		seen[e.path_index] = true
	check(seen.size() == 2, "a split gate alternates routes (%s)" % str(seen.keys()))
	# Forcing one route reroutes enemies still before the fork, not those past it.
	var g2 = new_game("delta")
	g2.state = Game.State.WAVE
	var fork_dist: float = grid.groups[0].fork_dist
	var before = g2.spawn_enemy("grunt", 1, fork_dist - 60.0, 1.0, -1)
	var after = g2.spawn_enemy("grunt", 1, fork_dist + 90.0, 1.0, -1)
	g2.enemies.append_array([before, after])
	var pos_before: Vector2 = before.pos
	check(g2.cycle_gate(0) and g2.gate_label(0) == "North only", "first click: north only (%s)" % g2.gate_label(0))
	check(before.path_index == 0 and before.pos.distance_to(pos_before) < 2.0, "an enemy before the fork switches route in place")
	check(after.path_index == 1, "an enemy past the fork keeps its route")
	check(not g2.cycle_gate(0), "the gate has a cooldown")
	for i in int(6.1 / SIM_DT):
		g2.tick(SIM_DT)
	check(g2.cycle_gate(0) and g2.gate_label(0) == "South only", "second click: south only")
	var g3 = new_game("delta")
	g3.gates[0] = 2
	g3.start_wave()
	run_until(g3, func(): return g3.enemies.size() >= 3, 20.0)
	check(g3.enemies.all(func(e): return e.flying or e.path_index == 1), "a forced gate sends every new spawn one way")
	var data := SaveCodec.encode(g3)
	var res := SaveCodec.decode(JSON.parse_string(JSON.stringify(data)))
	check(res.has("game") and res.game.gates == [2], "gate states are saved")
	check(not new_game("meadow").cycle_gate(0), "maps without forks have no gate to flip")
	var sg = new_game("singularity")
	check(sg.grid.groups.size() == 2 and sg.gates.size() == 2, "Singularity Array has two gates")



# --- v3 enemies ------------------------------------------------------------------------------

func test_burrower() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var b = put(g, "burrower", 100.0)
	check(not b.burrowed and not b.is_hidden(), "starts on the surface")
	check(run_until(g, func(): return b.burrowed, 5.2), "dives after 5 s")
	check(b.is_hidden(), "untargetable while burrowed")
	var hp0: float = b.hp
	check(g.damage_enemy(b, 50.0, true, null) == 0.0 and b.hp == hp0, "can't be hurt while burrowed")
	check(run_until(g, func(): return not b.burrowed, 2.6), "surfaces after 2.5 s")
	check(g.damage_enemy(b, 50.0, true, null) > 0.0, "vulnerable again on the surface")


func test_blink_stalker() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var s = put(g, "stalker", 100.0)
	s.blink_timer = 0.001
	var d0: float = s.distance
	g.tick(SIM_DT)
	check(near(s.distance - d0, 80.0 + s.speed * SIM_DT, 0.5), "teleports 80 px ahead (%.1f)" % (s.distance - d0))
	check(near(s.blink_timer, 4.0), "the charge restarts")
	s.blink_timer = 1.0
	s.apply_slow(0.2, 1.0)
	check(near(s.blink_timer, 4.0), "a slow resets the charge")
	s.blink_timer = 1.0
	s.apply_stun(0.3)
	check(near(s.blink_timer, 4.0), "a stun resets the charge")


func test_mender_regen() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var m = put(g, "mender", 100.0)
	m.hp = m.max_hp * 0.5
	g.damage_enemy(m, 1.0, true, null)
	var hp0: float = m.hp
	run_until(g, func(): return false, 1.0)
	check(near(m.hp, hp0), "no repairs within 1.5 s of taking damage")
	run_until(g, func(): return false, 1.0)
	check(m.hp > hp0 + m.max_hp * 0.015, "repairs 4%%/s once left alone (%.1f -> %.1f)" % [hp0, m.hp])
	m.hp = m.max_hp - 0.01
	run_until(g, func(): return false, 1.0)
	check(m.hp <= m.max_hp, "never repairs past full health")


func test_rally_beacon() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var r = put(g, "rally", 200.0)
	var r2 = put(g, "rally", 215.0)
	var mate = put(g, "grunt", 230.0)
	var far = put(g, "grunt", 700.0)
	var boss = put(g, "juggernaut", 190.0)
	g.tick(SIM_DT)
	check(near(mate.haste, 0.25), "nearby enemies move 25% faster")
	check(near(far.haste, 0.0) and near(boss.haste, 0.0), "not far-off enemies or bosses")
	check(near(r.haste, 0.25) and near(r2.haste, 0.25), "beacons boost each other, not themselves, and never stack")
	var d0: float = mate.distance
	g.tick(SIM_DT)
	check(near(mate.distance - d0, mate.speed * 1.25 * SIM_DT, 0.01), "haste speeds movement")
	g.damage_enemy(r, 99999.0, true, null)
	g.damage_enemy(r2, 99999.0, true, null)
	g.tick(SIM_DT)
	check(near(mate.haste, 0.0), "the boost ends with the beacons")


func test_bulwark() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var b = put(g, "bulwark", 200.0)
	var mate = put(g, "grunt", 230.0)
	var boss = put(g, "juggernaut", 210.0)
	b.ability_timer = 0.001
	g.tick(SIM_DT)
	check(near(mate.shield, mate.max_hp * 0.25), "grants a barrier worth 25% of health")
	check(boss.shield == 0.0 and b.shield == 0.0, "not to bosses or itself")
	var hp0: float = mate.hp
	g.damage_enemy(mate, 5.0, false, null)
	check(near(mate.hp, hp0), "the barrier soaks damage first")


func test_rampart() -> void:
	var g = new_game()
	var r = put(g, "rampart", 200.0)
	r.apply_slow(0.5, 2.0)
	r.apply_stun(1.0)
	check(r.slow_amount == 0.0 and r.stun_timer == 0.0, "immune to slows and stuns")
	check(r.shove_immune(), "immune to shoves")
	var brute = put(g, "brute", 210.0)
	brute.apply_stun(1.0)
	check(brute.stun_timer > 0.0 and not brute.shove_immune(), "ordinary enemies still can be")
	check(near(g.damage_enemy(r, 10.0, false, null), 2.0), "8 armor (20% floor on a 10-damage hit)")


func test_is_boss_round() -> void:
	var g = new_game()
	var bosses := 0
	for n in range(1, g.final_round() + 1):
		if g.is_boss_round(n):
			bosses += 1
	check(bosses > 0, "some rounds are boss rounds (%d)" % bosses)
	check(not g.is_boss_round(1), "round 1 has no boss")
	check(g.is_boss_round(g.final_round()), "the final round has bosses")


func test_launch_view() -> void:
	var BottomBar = load("res://scripts/ui/hud/BottomBar.gd")
	var g = new_game()
	var v: Dictionary = BottomBar.launch_view(g, false)
	check(v.counter == "ROUND 1 / %d" % g.final_round(), "round 0 shows the first round: %s" % v.counter)
	check(v.action == "LAUNCH  [Space]" and v.can_launch and not v.red, "ready to launch, normal colour")
	g.auto_start = true
	check(BottomBar.launch_view(g, false).action.begins_with("LAUNCH IN 5s"), "auto-start counts down")
	g.auto_start = false
	check(BottomBar.launch_view(g, true).red and BottomBar.launch_view(g, true).counter.begins_with("BOSS ROUND 1 /"), "a boss round is red and labelled")
	g.wave = g.final_round() - 1
	v = BottomBar.launch_view(g, true)
	check(v.counter == "FINAL ROUND %d / %d" % [g.final_round(), g.final_round()] and v.red, "the final round is labelled: %s" % v.counter)
	g.wave = 3
	g.state = Game.State.WAVE
	g.spawn_queue.append({"time": 99.0, "type": "grunt", "wave": 3})
	v = BottomBar.launch_view(g, false)
	check(v.counter == "ROUND 3 / %d" % g.final_round() and not v.can_launch, "mid-round shows the current round, no launch")
	g.spawn_queue.clear()
	g.endless = true
	check(BottomBar.launch_view(g, false).counter == "ROUND 3  ENDLESS", "endless drops the total")


func sandbox_game(diff := "medium"):
	var g = new_game("meadow", 1234, diff)
	g.make_sandbox()
	return g


func test_sandbox_resources() -> void:
	var g = sandbox_game()
	check(g.gold == Game.SANDBOX_GOLD, "credits start pinned")
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	check(t != null, "towers can be built")
	g.upgrade_tower(t)
	g.tick(SIM_DT)
	check(g.gold == Game.SANDBOX_GOLD, "credits are topped back up after spending")
	check(g.sell_value(t) == t.spent, "selling refunds 100%")
	var lives0: int = g.lives
	var grunt = put(g, "grunt", 0.0)
	g._leak(grunt)
	check(g.lives == lives0 and not g.is_over(), "a leak costs no shields and ends nothing")
	var real = new_game()
	check(real.gold != Game.SANDBOX_GOLD and not real.sandbox, "a normal run is unaffected")
	check(sandbox_game().ability_cd.values().all(func(c): return c == 0.0), "abilities start ready")
	g.state = Game.State.WAVE
	check(g.cast_warp() and g.ability_cd["warp"] == 0.0, "a cast leaves no cooldown")


func test_sandbox_spawn() -> void:
	var g = sandbox_game()
	g.sandbox_spawn("grunt", 5)
	check(g.spawn_queue.size() == 5 and g.state == Game.State.WAVE, "five queued, round running")
	check(g.spawn_queue.all(func(s): return s.wave == -1), "tagged with no round (no clear bonus)")
	check(near(float(g.spawn_queue[0].hp_mult), g.hp_mult_for(1)), "base strength")
	var groups := {}
	for s in g.spawn_queue:
		groups[s.group] = true
	check(g.grid.groups.size() < 2 or groups.size() > 1, "lanes alternate")
	g.sandbox_spawn("brute", 2)
	check(g.spawn_queue.size() == 7, "spawns stack")
	var leak_before: int = g.stats["leaked"]
	check(run_until(g, func(): return g.state == Game.State.BUILD, 120.0), "the field empties by itself and returns to build")
	var normal = new_game()
	normal.sandbox_spawn("grunt", 3)
	check(normal.spawn_queue.is_empty(), "outside Sandbox the spawner does nothing")
	check(g.stats["leaked"] >= leak_before, "leaks counted, harmlessly")


func test_sandbox_call_round() -> void:
	var g = sandbox_game()
	var want := 0
	for grp in g.preview_wave(10):
		want += int(grp.n)
	g.sandbox_call_round(10)
	check(g.spawn_queue.size() == want and g.wave == 0, "round 10's real wave, round counter untouched (%d of %d)" % [g.spawn_queue.size(), want])
	check(near(float(g.spawn_queue[0].hp_mult), g.hp_mult_for(10)), "at round 10 strength")
	g.sandbox_call_round(40)
	check(g.spawn_queue.size() > want, "calls stack")
	check(g.wave_remaining.is_empty(), "no clear bonus is tracked")


func test_sandbox_clear_field() -> void:
	var g = sandbox_game()
	g.sandbox_call_round(20)
	put(g, "grunt", 50.0)
	var lives0: int = g.lives
	g.sandbox_clear_field()
	check(g.spawn_queue.is_empty() and g.enemies.is_empty(), "queue and field emptied")
	check(g.state == Game.State.BUILD and g.lives == lives0 and g.gold == Game.SANDBOX_GOLD, "back to build, nothing paid or lost")


func test_sandbox_max_branch() -> void:
	var g = sandbox_game()
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	var n: int = g.sandbox_max_branch(t, "a")
	check(n == Tower.BRANCH_STEPS, "a branch buys its %d steps, no mastery without research (%d)" % [Tower.BRANCH_STEPS, n])
	g.sandbox_set_research("all", [])
	var m: int = g.sandbox_max_branch(t, "a")
	check(m == 1 and t.tier >= Tower.MASTERY_TIER, "with research on, Max reaches the mastery (%d)" % m)
	g.sandbox_set_research("none", [])
	check(g.research.is_empty() and g.gold == Game.SANDBOX_GOLD, "research off again")
	g.sandbox_set_research("mine", ["gun_turret_1"])
	check(g.research == ["gun_turret_1"], "mine applies the player's own")


func test_sandbox_no_medal() -> void:
	var g = sandbox_game("easy")
	g.wave = g.final_round()
	g.state = Game.State.WAVE
	g.tick(SIM_DT)
	check(g.state == Game.State.BUILD and g.endless and not g.medal, "past the last round: endless, no medal")


func test_sandbox_dps() -> void:
	var g = sandbox_game()
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	var e = put(g, "grunt", 60.0, 0, 1000.0)
	g.state = Game.State.WAVE
	for i in int(6.0 / SIM_DT):
		g.tick(SIM_DT)
	var dps: float = t.live_dps(Game.DPS_BUCKET)
	check(dps > 0.0 and t.damage_dealt > 0.0, "the meter reads the tower's damage (%.1f)" % dps)
	check(t.dps_buckets.size() <= Game.DPS_BUCKETS, "a 5 s window")


func test_leviathan() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var lv = put(g, "leviathan", 300.0)
	check(lv.flying and lv.boss, "a flying boss")
	run_until(g, func(): return false, 6.1)
	var locusts: Array = g.enemies.filter(func(e): return e.type == "locust")
	check(locusts.size() == 6, "launches 6 Locusts every 6 s (%d)" % locusts.size())
	check(locusts.all(func(e): return e.flying), "Locusts fly")


func test_colossus() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var c = put(g, "colossus", 300.0)
	c.apply_stun(1.0)
	check(c.stun_timer == 0.0, "can't be stunned")
	var armor0: float = c.armor
	var speed0: float = c.speed
	g.damage_enemy(c, c.max_hp * 0.36, true, null)
	g.tick(SIM_DT)
	check(c.phase == 1 and near(c.armor, armor0 - 5.0) and near(c.speed, speed0 * 1.2), "below 66%: sheds armor and speeds up")
	check(g.enemies.filter(func(e): return e.type == "brute").size() == 2, "drops two Siege Mechs")
	g.damage_enemy(c, c.max_hp * 0.4, true, null)
	g.tick(SIM_DT)
	check(c.phase == 2 and near(c.armor, armor0 - 10.0), "below 33%: sheds more")
	check(g.enemies.filter(func(e): return e.type == "brute").size() == 4, "and drops two more")


func test_v3_flyers() -> void:
	var g = new_game()
	g.gold = 5000
	var mortar = g.place_tower("mortar_tower", Vector2i(2, 3))
	var locust = put(g, "locust", 60.0)
	var gunship = put(g, "gunship", 60.0)
	check(locust.flying and gunship.flying, "Locusts and Gunships fly")
	check(not mortar.can_target(locust) and not mortar.can_target(gunship), "mortars can't hit them")
	check(near(g.damage_enemy(gunship, 20.0, false, null), 15.0), "Gunship armor takes 5 off each hit")



func test_crowd_control_limits() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var e = put(g, "brute", 300.0)
	e.apply_stun(0.5)
	run_until(g, func(): return e.stun_timer <= 0.0, 1.0)
	e.apply_stun(0.5)
	check(e.stun_timer == 0.0, "can't be re-stunned right after a stun ends")
	run_until(g, func(): return false, 1.05)
	e.apply_stun(0.5)
	check(e.stun_timer > 0.0, "stunnable again after the guard window")
	var s = put(g, "grunt", 800.0)
	for i in 10:
		s.shove(100.0)
	check(near(s.shoved, Enemy.SHOVE_BUDGET) and s.shove_immune(), "shoves stop at the budget")
	check(near(s.distance, 800.0 - Enemy.SHOVE_BUDGET), "total pushback is capped (%.0f)" % s.distance)


# --- Combat rules ----------------------------------------------------------------------------

func test_armor_math() -> void:
	check(near(Enemy.mitigate(10.0, 0.0, false), 10.0), "no armor = full damage")
	check(near(Enemy.mitigate(10.0, 6.0, false), 4.0), "flat armor subtracts")
	check(near(Enemy.mitigate(10.0, 12.0, false), 2.0), "armor floor is 20%")
	check(near(Enemy.mitigate(10.0, 12.0, true), 10.0), "pierce ignores armor")
	var g = new_game()
	var e = put(g, "brute", 100.0)
	var hp0: float = e.hp
	g.damage_enemy(e, 20.0, false, null)
	check(near(e.hp, hp0 - 14.0), "brute takes 20-6 damage")


func test_slow_rules() -> void:
	var g = new_game()
	var e = put(g, "grunt", 50.0)
	e.apply_slow(0.35, 1.0)
	e.apply_slow(0.45, 1.0)
	check(near(e.slow_amount, 0.45), "strongest slow wins, no stacking")
	e.apply_slow(0.2, 3.0)
	check(near(e.slow_amount, 0.45), "weaker slow does not override")
	e.apply_slow(0.95, 1.0)
	check(near(e.slow_amount, Enemy.SLOW_CAP), "slow is capped")
	var boss = put(g, "juggernaut", 50.0)
	boss.apply_slow(0.5, 1.0)
	check(near(boss.slow_amount, 0.25), "boss resists half of a slow")
	var d0: float = e.distance
	e.step(0.5)
	check(near(e.distance - d0, e.speed * (1.0 - Enemy.SLOW_CAP) * 0.5, 0.01), "slowed movement")
	e.step(2.0)
	check(e.slow_amount == 0.0, "slow expires")


func test_targeting_modes() -> void:
	var g = new_game()
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	check(t != null, "arrow placed next to the road")
	var near_e = put(g, "grunt", 100.0)
	var far_e = put(g, "grunt", 200.0)
	var tough = put(g, "brute", 150.0)
	t.mode = Tower.Mode.FIRST
	check(g.pick_target(t) == far_e, "FIRST picks the enemy furthest along")
	t.mode = Tower.Mode.LAST
	check(g.pick_target(t) == near_e, "LAST picks the enemy least far along")
	t.mode = Tower.Mode.STRONG
	check(g.pick_target(t) == tough, "STRONG picks highest HP")
	t.mode = Tower.Mode.CLOSE
	var closest = null
	var cd := INF
	for e in [near_e, far_e, tough]:
		var d: float = t.pos.distance_to(e.pos)
		if d < cd:
			cd = d
			closest = e
	check(g.pick_target(t) == closest, "CLOSE picks the nearest enemy")
	var out_e = put(g, "grunt", 1200.0)
	t.mode = Tower.Mode.FIRST
	check(g.pick_target(t) != out_e, "out-of-range enemy ignored")
	g.cycle_mode(t)
	check(t.mode == Tower.Mode.LAST, "cycle_mode advances")


func test_strongest_by_strength_rank() -> void:
	var g = new_game()
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	t.mode = Tower.Mode.STRONG
	var mech = put(g, "brute", 150.0)
	var bot = put(g, "shaman", 160.0, 0, 5.0)
	check(bot.hp > mech.hp and g.pick_target(t) == mech, "a Siege Mech outranks a Repair Bot with more health (strength, not HP)")
	var mech2 = put(g, "brute", 140.0)
	mech.hp -= 50.0
	check(g.pick_target(t) == mech2, "same strength: the one with more health left")
	mech2.hp = mech.hp
	check(g.pick_target(t) == mech, "same strength and health: the one further along")
	var boss = put(g, "juggernaut", 130.0, 0, 0.01)
	check(g.pick_target(t) == boss, "a boss outranks everything, even nearly dead")
	var order: Array = Enemies.ORDER.duplicate()
	order.sort_custom(func(a, b): return Enemies.rank_score(a) < Enemies.rank_score(b))
	var by_rank := ["swarmling", "locust", "grunt", "shaman", "jammer", "mirage", "phantom", "shrike", "runner", "stalker", "aegis", "needle",
		"bat", "rally", "siphon", "bulwark", "hydra", "burrower", "fury", "mender", "blackout", "shifter", "brute", "wraith", "decoy",
		"capacitor", "masquerade", "rampart", "gunship", "titan", "juggernaut", "warlord", "leviathan", "colossus"]
	check(order == by_rank, "the roster's weakest-to-strongest order (%s)" % [order])


func test_support_priority() -> void:
	var g = new_game()
	g.gold = 5000
	var t = g.place_tower("mortar_tower", Vector2i(2, 3))
	t.mode = Tower.Mode.FIRST
	var front = put(g, "brute", 200.0)
	var helper = put(g, "rally", 150.0)
	var other = put(g, "aegis", 170.0)
	check(g.pick_target(t) == front, "Any: First takes the front enemy")
	check(GameScreen.has_priority(t), "a ground-only tower now has a priority")
	g.cycle_priority(t)
	check(t.priority == 3, "a ground-only tower skips Air and Ground, straight to Support")
	check(g.pick_target(t) == helper, "Support: the Rally Beacon first, though it is behind")
	var helper2 = put(g, "shaman", 180.0)
	check(g.pick_target(t) == helper2, "among Support enemies it uses its mode (First)")
	t.mode = Tower.Mode.LAST
	check(g.pick_target(t) == helper, "Last among Support enemies")
	check(other.role() == "special" and g.pick_target(t) != other, "Specials aren't Support")
	g.damage_enemy(helper, 1e9, true, null)
	g.damage_enemy(helper2, 1e9, true, null)
	t.mode = Tower.Mode.FIRST
	check(g.pick_target(t) == front, "with no Support enemy in range it falls back to everyone")
	g.cycle_priority(t)
	check(t.priority == 0, "Support cycles back to Any")
	var coil = g.place_tower("tesla_tower", spot(g, "tesla_tower", 80))
	check(coil.hits_air() and coil.hits_ground(), "a Tesla Tower hits both")
	var seen := []
	for i in 4:
		g.cycle_priority(coil)
		seen.append(coil.priority)
	check(seen == [1, 2, 3, 0], "a tower that hits both cycles Any, Air, Ground, Support")
	check(Enemies.ENEMIES.locust.hp == 15.0 and Enemies.ENEMIES.bat.hp == 100.0 and Enemies.ENEMIES.gunship.hp == 600.0, "the roster's stat adjustments")


func test_flyer_rules() -> void:
	var g = new_game()
	g.gold = 10000
	var cannon = g.place_tower("mortar_tower", Vector2i(2, 3))
	var arrow = g.place_tower("gun_turret", Vector2i(3, 3))
	var bat = put(g, "bat", 150.0)
	check(bat.flying, "bat flies")
	check(cannon.pos.distance_to(bat.pos) < cannon.get_range(), "bat is inside cannon range")
	check(g.pick_target(cannon) == null, "cannon ignores flyers")
	check(g.pick_target(arrow) == bat, "arrow targets flyers")


# --- Economy & rules -------------------------------------------------------------------------

func test_placement_rules() -> void:
	var g = new_game()
	check(g.placement_error("gun_turret", Vector2i(0, 2)) != "", "can't build on path")
	check(g.placement_error("gun_turret", Vector2i(1, 5)) != "", "can't build on blocked tile")
	check(g.placement_error("gun_turret", Vector2i(-1, 0)) != "", "can't build out of bounds")
	check(g.placement_error("gun_turret", Vector2i(Grid.COLS, 5)) != "", "can't build out of bounds (right)")
	check(g.placement_error("gun_turret", Vector2i(2, 3)) == "", "can build next to path")
	g.place_tower("gun_turret", Vector2i(2, 3))
	check(g.placement_error("gun_turret", Vector2i(2, 3)) != "", "can't stack towers")
	g.gold = 10
	check(g.placement_error("gun_turret", Vector2i(3, 3)) == "Not enough credits", "credits are required")
	check(g.place_tower("gun_turret", Vector2i(3, 3)) == null, "place fails without gold")


func test_economy() -> void:
	var g = new_game()
	var g0: int = g.gold
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	check(g.gold == g0 - 75, "build deducts cost")
	check(g.upgrade_tower(t, "a"), "a path step succeeds")
	check(g.gold == g0 - 130 and t.tier == 3 and t.spent == 130, "upgrade deducts and tracks spend")
	g.gold = 0
	check(not g.upgrade_tower(t, "b"), "upgrade needs credits")
	g.gold = 1000
	check(not g.upgrade_tower(t, "bogus"), "an unknown path is refused")
	check(t.upgrade_cost("b") == 25 and t.upgrade_cost() == 40, "path costs reported (the primary's next step without a key)")
	check(g.upgrade_tower(t, "b") and t.started == ["a", "b"], "a second path can be started")
	check(not g.upgrade_tower(t, "c"), "the third path is locked once two are started")
	check(g.gold == 1000 - 25, "the step's cost is deducted")
	var refund := g.sell_value(t)
	check(refund == int(floor(155 * 0.7)), "sell refunds 70%% of total spend (%d)" % refund)
	var before: int = g.gold
	g.sell_tower(t)
	check(g.gold == before + refund and not g.tower_at.has(Vector2i(2, 3)), "sell pays out and frees the tile")
	var e = put(g, "grunt", 100.0)
	var gold_before: int = g.gold
	g.damage_enemy(e, 1000.0, false, null)
	check(not e.alive and g.gold == gold_before + int(Enemies.ENEMIES.grunt.bounty), "kill pays bounty")
	check(g.stats.kills == 1, "kill counted")


func test_wave_clear_and_early_call() -> void:
	# Undefended (with spare lives) so enemies are still walking when spawning ends.
	var g = new_game()
	g.lives = 100
	check(g.start_wave(), "wave 1 starts")
	check(g.state == Game.State.WAVE and g.wave == 1, "in wave 1")
	check(not g.can_call_early(), "no early call while wave 1 still spawning")
	check(run_until(g, func(): return g.spawn_queue.is_empty(), 30.0), "wave 1 finished spawning")
	check(not g.enemies.is_empty(), "wave 1 enemies still on the field")
	check(g.can_call_early(), "early call available once spawns finish")
	var gold_before: int = g.gold
	check(g.start_wave(), "early call starts wave 2")
	check(g.gold == gold_before + Waves.early_call_bonus(2), "early call pays a bonus")
	check(g.wave == 2, "now in wave 2")
	check(run_until(g, func(): return g.state == Game.State.BUILD, 150.0), "field clears back to build phase")
	check(g.stats.waves_cleared == 2, "both overlapping waves paid a clear bonus")
	var leak_cost := 0
	for w in [1, 2]:
		for x in g.preview_wave(w):
			leak_cost += int(x.n) * int(Enemies.ENEMIES[x.t].lives)
	check(g.lives == 100 - leak_cost, "every enemy of both rounds leaked (%d, expected %d)" % [g.lives, 100 - leak_cost])
	check(g.can_save(), "can save in build phase")

	var d = new_game()
	d.gold = 5000
	for c in [Vector2i(2, 3), Vector2i(3, 3), Vector2i(5, 4), Vector2i(3, 1), Vector2i(5, 1)]:
		d.place_tower("railgun", c)
	d.start_wave()
	check(run_until(d, func(): return d.state == Game.State.BUILD, 120.0), "defended wave clears")
	check(d.lives == d.max_lives, "no leaks with five Railguns")
	var expected: int = 5000 - 5 * d.tower_cost("railgun") + 8 * int(Enemies.ENEMIES.grunt.bounty) + Waves.clear_bonus(1)
	check(d.gold == expected, "bounties and clear bonus paid (%d, expected %d)" % [d.gold, expected])


func test_shaman_heal() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var shaman = put(g, "shaman", 100.0)
	var grunt = put(g, "grunt", 110.0)
	grunt.hp = 10.0
	for i in int(2.1 / SIM_DT):
		g.tick(SIM_DT)
	check(grunt.hp > 10.0, "shaman healed a nearby grunt")
	check(grunt.hp <= grunt.max_hp, "heal never exceeds max HP")
	check(shaman.alive, "shaman still alive")


func test_warlord_minions() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var w = put(g, "warlord", 400.0)
	var n0: int = g.enemies.size()
	for i in int(5.2 / SIM_DT):
		g.tick(SIM_DT)
	var swarm := 0
	for e in g.enemies:
		if e.type == "swarmling":
			swarm += 1
	check(swarm == 3, "warlord summoned 3 swarmlings (%d)" % swarm)
	check(g.enemies.size() == n0 + 3, "minions joined the field")
	check(w.alive, "warlord still marching")


func test_round_generation() -> void:
	var g = new_game()
	check(deep_equal(g.preview_wave(47), g.preview_wave(47)), "preview_wave is stable")
	var other = Game.new("canyon", 424242, "hard")
	for w in [1, 12, 33, 60, 97]:
		check(deep_equal(g.preview_wave(w), other.preview_wave(w)), "round %d is the same on any seed, sector and mode" % w)
	check(g.preview_wave(1).size() == 1 and g.preview_wave(1)[0].t == "grunt", "round 1 is Drones")
	var prev_budget := 0.0
	for w in range(1, 161):
		var groups: Array = Waves.get_wave(w)
		var regular := 0
		for x in groups:
			check(Enemies.ENEMIES.has(x.t) and int(x.n) > 0 and float(x.i) > 0.0, "round %d group valid" % w)
			if not Enemies.ENEMIES[x.t].get("boss", false):
				regular += Waves.units(x)
				check(Waves.first_round(x.t) <= w, "round %d only uses enemies met by then (%s)" % [w, x.t])
			elif not Waves.boss_line(w).any(func(l): return l[0] == x.t):
				check(Waves.first_boss_round(x.t) < w and int(x.n) == 1, "a boss recurs alone, after its own round (%s, %d)" % [x.t, w])
			if x.has("m"):
				check(int(x.n) == 1 and not x.m.is_empty() and x.m.size() <= Modifiers.max_per_elite(w), "round %d: an elite is one enemy with 1-%d modifiers" % [w, Modifiers.max_per_elite(w)])
				for m in x.m:
					check(int(Modifiers.MODIFIERS[m].intro) <= w and Modifiers.allowed(x.t, m), "round %d: %s may carry %s" % [w, x.t, m])
		check(regular <= Waves.MAX_SPAWNS, "round %d respects the spawn cap (%d)" % [w, regular])
		if w >= 10:
			check(groups.size() >= 3, "round %d has several groups" % w)
		check(Waves.threat_budget(w) > prev_budget, "the budget grows every round (%d)" % w)
		prev_budget = Waves.threat_budget(w)
	check(near(Waves.threat_budget(1), 8.0) and near(Waves.threat_budget(25), 106.0, 1.0) and near(Waves.threat_budget(60), 290.0, 1.0), "the budget curve")
	check(Waves.elite_share(7) == 0.0 and near(Waves.elite_share(8), 0.10) and near(Waves.elite_share(60), 0.30) and near(Waves.elite_share(100), 0.30), "elites: 10% from round 8, 30% by 60")
	check(not Waves.get_wave(9).any(func(x): return x.has("m")), "no elites before the first modifier (round 10)")
	# Each regular enemy leads its introduction round; each modifier shows up on its own.
	for t in Waves.INTRO:
		if not Enemies.ENEMIES.has(t):
			continue
		var w := int(Waves.INTRO[t])
		check(g.preview_wave(w)[0].t == t, "%s leads round %d" % [t, w])
		check(Waves.first_round(t) == w, "%s first appears in round %d" % [t, w])
	for m in Modifiers.ORDER:
		var w := int(Modifiers.MODIFIERS[m].intro)
		check(Waves.get_wave(w).any(func(x): return x.has("m") and x.m.has(m)), "%s debuts on round %d" % [m, w])
		check(not Waves.get_wave(w - 1).any(func(x): return x.has("m") and x.m.has(m)), "not before")
	check(Waves.get_wave(45).any(func(x): return x.has("m") and x.m.size() >= 1), "late rounds have elites")
	# Boss rounds: every 20, each bigger than the last.
	var has := func(w: int, t: String) -> bool:
		return Waves.boss_groups(w).any(func(x): return x.t == t)
	check(has.call(20, "juggernaut") and has.call(40, "warlord") and has.call(60, "leviathan") and has.call(80, "colossus"), "a new boss at 20, 40, 60 and 80")
	check(Waves.boss_groups(30).is_empty() and Waves.boss_groups(45).is_empty(), "no boss line-up between boss rounds")
	var prev := 0.0
	for w in [20, 40, 60, 80, 100, 120, 140]:
		var threat := 0.0
		for x in Waves.boss_groups(w):
			threat += float(Waves.COST[x.t]) * int(x.n)
		check(threat > prev, "boss round %d is bigger than the last" % w)
		prev = threat
	check(Waves.first_round("warlord") == 40 and Waves.first_round("colossus") == 80, "a boss is first met on its round")
	for final in [40, 60, 80, 100, 120]:
		check(g.is_boss_round(final), "each mode's last round (%d) is a boss round" % final)


## Places a tower and upgrades it straight to a tier-3 spec with free credits.
func spec_tower(g, type: String, cell: Vector2i, spec: String):
	g.gold += 5000
	var t = g.place_tower(type, cell)
	g.upgrade_tower(t)
	g.upgrade_tower(t, spec)
	return t


func test_abilities() -> void:
	var g = new_game()
	check(not g.ability_ready("meteor") and not g.cast_meteor(Vector2(100, 120)), "no abilities in the build phase")
	check(g.ability_block_reason("warp") != "", "build phase gives a reason")
	g.start_wave()
	var a = put(g, "grunt", 100.0, 0, 5.0)
	var b = put(g, "brute", 110.0, 0, 5.0)
	var bat = put(g, "bat", 60.0, 0, 5.0)
	var far = put(g, "grunt", 600.0, 0, 5.0)
	var target: Vector2 = a.pos
	check(g.cast_meteor(target), "meteor casts during a wave")
	check(not g.cast_meteor(target), "meteor is on cooldown right after casting")
	check(g.ability_block_reason("meteor").contains("recharging"), "cooldown reason reported")
	for i in int(0.5 / SIM_DT):
		g.tick(SIM_DT)
	check(near(a.hp, a.max_hp), "meteor has a fall delay")
	for i in int(0.5 / SIM_DT):
		g.tick(SIM_DT)
	var dmg: float = float(Abilities.ABILITIES.meteor.damage) * Waves.hp_scale(1)
	check(near(a.max_hp - a.hp, dmg), "meteor hits the grunt (%.1f)" % (a.max_hp - a.hp))
	check(near(b.max_hp - b.hp, dmg), "meteor ignores armor")
	check(near(bat.max_hp - bat.hp, dmg), "meteor hits flyers")
	check(near(far.hp, far.max_hp), "meteor spares enemies outside the blast")
	var mcd := float(Abilities.ABILITIES.meteor.cooldown)
	check(g.ability_cd.meteor > mcd - 2.0 and g.ability_cd.meteor < mcd, "meteor cooldown ticking (%.2f)" % g.ability_cd.meteor)

	var boss = put(g, "juggernaut", 300.0)
	check(g.cast_warp(), "time warp casts")
	g.tick(SIM_DT)
	check(near(far.slow_amount, 0.6), "warp slows everything by 60%")
	check(near(boss.slow_amount, 0.3), "bosses resist half the warp")
	var late = put(g, "runner", 50.0)
	g.tick(SIM_DT)
	check(near(late.slow_amount, 0.6), "enemies arriving during the warp are slowed too")
	for i in int(5.5 / SIM_DT):
		g.tick(SIM_DT)
	check(g.warp_timer == 0.0 and far.slow_amount == 0.0, "warp wears off")


func test_difficulty_modes() -> void:
	check(Difficulty.ORDER == ["easy", "medium", "hard", "nightmare", "cataclysm"], "five modes in order")
	var expect := {"easy": [40, 200], "medium": [60, 100], "hard": [80, 50], "nightmare": [100, 25], "cataclysm": [120, 1]}
	for mode in expect:
		for id in ["meadow", "singularity"]:
			var g = new_game(id, 1, mode)
			check(g.final_round() == int(expect[mode][0]) and g.lives == int(expect[mode][1]) and g.max_lives == g.lives, "%s on %s: %d rounds, %d shields" % [mode, id, expect[mode][0], expect[mode][1]])
			check(g.gold == Game.START_GOLD, "%s on %s: the standard starting credits" % [mode, id])
	check(near(new_game("canyon", 1, "cataclysm").hp_mult_for(30), new_game("meadow", 1, "easy").hp_mult_for(30)), "enemy HP depends only on the round")
	check(new_game("meadow", 1, "casual").difficulty == "easy" and new_game("meadow", 1, "normal").difficulty == "medium" and new_game("meadow", 1, "veteran").difficulty == "hard", "old mode ids map to Easy/Medium/Hard")
	check(new_game("meadow", 1, "bogus").difficulty == "medium", "unknown modes fall back to Medium")
	# Tower prices climb with the mode (build and every upgrade).
	var prev_price := 0.0
	for mode in Difficulty.ORDER:
		var p := Difficulty.price(mode)
		check(p >= prev_price and p >= 1.0, "%s towers cost x%.2f, never less than an easier mode" % [mode, p])
		prev_price = p
		var pg = new_game("meadow", 1, mode)
		pg.gold = 100000
		var mt: Dictionary = Towers.Rework.TREES.mortar_tower
		check(pg.tower_cost("mortar_tower") == int(round(float(mt.cost) * p)), "%s: a Mortar Tower costs %d" % [mode, pg.tower_cost("mortar_tower")])
		var pt = pg.place_tower("mortar_tower", Vector2i(2, 3))
		check(pt.upgrade_cost("a") == int(round(float(mt.paths[0].nodes[0].cost) * p)), "%s: upgrades are priced x%.2f too" % [mode, p])
	check(Difficulty.price("cataclysm") > Difficulty.price("nightmare") and Difficulty.price("nightmare") > Difficulty.price("medium"), "Nightmare and Cataclysm cost more than the gentle modes")
	# Reinforced Core: +10% shields, rounded down (Cataclysm stays at 1).
	var want := {"easy": 220, "medium": 110, "hard": 55, "nightmare": 27, "cataclysm": 1}
	for mode in want:
		var r = Game.new("meadow", 1, mode, ["cmd_funds", "cmd_core"])
		check(r.lives == int(want[mode]), "%s with Reinforced Core: %d shields (%d)" % [mode, want[mode], r.lives])
	# Enemies spawn at their round's HP and speed.
	var s = new_game()
	s.wave = 59
	s.start_wave()
	run_until(s, func(): return not s.enemies.is_empty(), 10.0)
	var e = s.enemies[0]
	check(near(e.max_hp, float(e.def.hp) * Waves.hp_scale(60), 0.01), "round-60 enemies have round-60 HP")
	check(near(e.speed, float(e.def.speed) * Waves.speed_scale(60, e.boss), 0.01), "round-60 enemies have round-60 speed")
	# Clearing the last round earns the medal and rolls straight into endless mode.
	var m = new_game("meadow", 1, "easy")
	m.emit_events = true
	m.wave = 39
	m.start_wave()
	m.spawn_queue.clear()
	m.tick(SIM_DT)
	check(m.medal and m.endless and m.state == Game.State.BUILD and not m.is_over(), "round 40 on Easy earns the medal and keeps going")
	check(m.events.any(func(ev): return ev.type == "medal"), "a medal event is emitted")
	check(m.start_wave() and m.wave == 41, "endless round 41 launches")
	var md = new_game("meadow", 1, "medium")
	md.wave = 39
	md.start_wave()
	md.spawn_queue.clear()
	md.tick(SIM_DT)
	check(not md.medal and not md.endless, "round 40 on Medium is just another round")


func test_music_synthesis() -> void:
	var t0 := Time.get_ticks_msec()
	var m: PackedFloat32Array = Sfx.compose_music()
	var ms := Time.get_ticks_msec() - t0
	var expected := int(60.0 / Sfx.MUSIC_BPM * 4.0 * Sfx.PROGRESSION.size() * Sfx.RATE)
	check(m.size() == expected, "music loop is exactly 8 bars (%d samples)" % m.size())
	var peak := 0.0
	var energy := 0.0
	var worst_jump := 0.0
	for i in m.size():
		peak = maxf(peak, absf(m[i]))
		energy += m[i] * m[i]
		if i > 0:
			worst_jump = maxf(worst_jump, absf(m[i] - m[i - 1]))
	var rms := sqrt(energy / m.size())
	check(peak > 0.15 and peak < 1.0, "music is audible without clipping (peak %.2f)" % peak)
	check(rms > 0.03, "music is not near-silent (rms %.3f)" % rms)
	var seam := absf(m[0] - m[m.size() - 1])
	check(seam <= worst_jump + 0.01, "loop seam is no harsher than any other sample step (%.3f vs %.3f)" % [seam, worst_jump])
	print("    music: %.1f s loop, peak %.2f, rms %.3f, composed in %d ms (on a worker thread in-game)" % [m.size() / float(Sfx.RATE), peak, rms, ms])


# --- Saves -----------------------------------------------------------------------------------

func test_save_roundtrip_and_determinism() -> void:
	SaveManager.delete_run()
	check(not SaveManager.has_run(), "no save at start")
	var g = new_game("canyon", 4242, "hard")
	g.gold = 2000
	var t1 = g.place_tower("gun_turret", Vector2i(3, 2))
	var t2 = g.place_tower("mortar_tower", Vector2i(4, 5))
	g.place_tower("tesla_tower", Vector2i(8, 3))
	g.place_tower("cryo_tower", Vector2i(10, 5))
	g.place_tower("railgun", Vector2i(9, 2))
	g.upgrade_tower(t1, "a")
	g.upgrade_tower(t2, "a")
	g.cycle_mode(t1)
	g.auto_start = false
	g.speed = 2
	g.start_wave()
	check(not g.can_save(), "can't save mid-wave")
	check(not SaveManager.save_run(g), "save_run refuses mid-wave")
	run_until(g, func(): return g.state != Game.State.WAVE, 120.0)
	check(g.state == Game.State.BUILD, "wave 1 cleared")
	g.ability_cd["meteor"] = 12.5
	check(SaveManager.save_run(g), "save_run succeeds between waves")
	check(SaveManager.has_run(), "save file exists")
	check(not FileAccess.file_exists(SaveManager.run_path() + ".tmp"), "temp file cleaned up")
	var peek := SaveManager.peek_run()
	check(peek.get("map_id") == "canyon" and int(peek.get("wave", 0)) == 1, "peek shows map and wave")
	var res := SaveManager.load_run()
	check(res.has("game"), "load_run returns a game (%s)" % res.get("error", ""))
	if not res.has("game"):
		return
	var g2 = res.game
	g2.emit_events = false
	var a := SaveCodec.encode(g)
	var b := SaveCodec.encode(g2)
	a.erase("saved_at")
	b.erase("saved_at")
	check(deep_equal(a, b), "encode(load(save(g))) == encode(g)")
	check(g2.tower_at.size() == 5 and g2.towers.size() == 5, "towers restored")
	check(g2.difficulty == "hard" and near(g2.ability_cd.meteor, 12.5), "difficulty and ability cooldowns restored")
	check(g2.tower_at[Vector2i(3, 2)].depth.a == 1 and g2.tower_at[Vector2i(3, 2)].mode == 1, "upgrades and mode restored")
	# Determinism: both games play the next wave identically.
	g.start_wave()
	g2.start_wave()
	run_until(g, func(): return g.state != Game.State.WAVE, 150.0)
	run_until(g2, func(): return g2.state != Game.State.WAVE, 150.0)
	check(g.gold == g2.gold and g.lives == g2.lives and g.stats.kills == g2.stats.kills,
		"loaded game plays wave 2 identically (gold %d/%d lives %d/%d)" % [g.gold, g2.gold, g.lives, g2.lives])
	SaveManager.delete_run()
	check(not SaveManager.has_run(), "delete_run removes the save")


func test_save_error_handling() -> void:
	SaveManager.delete_run()
	check(SaveManager.load_run().is_empty(), "missing save loads as empty")
	_write_raw(SaveManager.run_path(), "{ this is not json")
	var r := SaveManager.load_run()
	check(r.has("error"), "corrupted JSON reports an error")
	SaveManager.delete_run()

	var good = new_game("meadow", 7)
	good.place_tower("gun_turret", Vector2i(2, 3))
	var data := SaveCodec.encode(good)

	var newer := data.duplicate(true)
	newer["version"] = 999
	check(str(SaveCodec.decode(newer).get("error", "")).contains("newer"), "newer save version rejected")
	var before_swap := data.duplicate(true)
	before_swap["version"] = 9
	check(str(SaveCodec.decode(before_swap).get("error", "")).contains("tower rework"), "a save from before the tower rework is rejected")
	var bad_map := data.duplicate(true)
	bad_map["map_id"] = "atlantis"
	check(SaveCodec.decode(bad_map).has("error"), "unknown map rejected")
	var on_path := data.duplicate(true)
	on_path["towers"][0]["col"] = 0
	on_path["towers"][0]["row"] = 2
	check(SaveCodec.decode(on_path).has("error"), "tower on the path rejected")
	var bad_tier := data.duplicate(true)
	bad_tier["towers"][0]["retrofit"] = 9
	check(SaveCodec.decode(bad_tier).has("error"), "impossible Retrofit option rejected")
	var bad_branch := data.duplicate(true)
	bad_branch["towers"][0]["depth"] = {"a": 3, "b": 3, "c": 0}
	bad_branch["towers"][0]["started"] = ["a", "b"]
	check(SaveCodec.decode(bad_branch).has("error"), "two primary branches rejected")
	var three := data.duplicate(true)
	three["towers"][0]["depth"] = {"a": 1, "b": 1, "c": 1}
	three["towers"][0]["started"] = ["a", "b", "c"]
	check(SaveCodec.decode(three).has("error"), "three started branches rejected")
	var dup := data.duplicate(true)
	dup["towers"].append(dup["towers"][0].duplicate())
	check(SaveCodec.decode(dup).has("error"), "duplicate tiles rejected")
	var no_lives := data.duplicate(true)
	no_lives["lives"] = 0
	check(SaveCodec.decode(no_lives).has("error"), "dead run rejected")
	var missing := data.duplicate(true)
	missing.erase("towers")
	check(SaveCodec.decode(missing).has("error"), "missing fields rejected")
	check(SaveCodec.decode([1, 2, 3]).has("error"), "non-object rejected")
	check(SaveCodec.decode(data).has("game"), "valid data decodes")

	# Crash between writing the temp file and renaming it: the temp copy is recovered.
	_write_raw(SaveManager.run_path() + ".tmp", JSON.stringify(data))
	check(SaveManager.has_run(), "temp-only save counts as a save")
	check(SaveManager.load_run().has("game"), "temp-only save is recovered")
	SaveManager.delete_run()


func test_profile_records() -> void:
	for f in [SaveManager.profile_path(), SaveManager.profile_path() + ".tmp"]:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(f)
	SaveManager.load_profile()
	SaveManager.record_run("meadow", "medium", 7, false, false)
	SaveManager.record_run("meadow", "medium", 4, false, false)
	var rec := SaveManager.map_record("meadow", "medium")
	check(rec.best_wave == 7 and not rec.medal, "best round kept, no medal")
	SaveManager.record_run("meadow", "medium", 60, true, false)
	SaveManager.record_run("meadow", "medium", 71, true, true)
	SaveManager.record_run("meadow", "hard", 10, false, false)
	SaveManager.load_profile()
	rec = SaveManager.map_record("meadow", "medium")
	check(rec.medal and rec.best_wave == 71 and rec.best_endless == 71, "medal and endless record persisted")
	var hard := SaveManager.map_record("meadow", "hard")
	check(hard.best_wave == 10 and not hard.medal, "records are tracked per mode")
	check(SaveManager.total_medals() == 1, "medals counted")
	SaveManager.record_run("canyon", "easy", 40, true, false)
	check(SaveManager.total_medals() == 2, "a second sector's medal counts too")
	# A v2-era profile (casual/normal/veteran, stars) keeps its RP as legacy RP; its records are cleared.
	var old := {"version": 3, "research": ["cmd_funds", "cmd_core"], "settings": {"difficulty": "veteran"}, "maps": {
		"meadow": {"normal": {"best_wave": 25, "won": true, "stars": 3, "best_endless": 47}, "casual": {"best_wave": 12}},
		"canyon": {"best_wave": 9, "won": false},
	}}
	_write_raw(SaveManager.profile_path(), JSON.stringify(old))
	SaveManager.load_profile()
	check(SaveManager.legacy_rp() == 10, "old records keep their RP: 6 for stars + 2 milestones + 2 endless (%d)" % SaveManager.legacy_rp())
	check(SaveManager.profile.maps.is_empty() and SaveManager.total_medals() == 0, "old records are cleared")
	check(SaveManager.research_owned() == ["cmd_funds", "cmd_core"], "bought research stays owned")
	check(SaveManager.research_earned() == 10 and SaveManager.research_available() == 10 - 3, "legacy RP counts toward the lab")
	check(SaveManager.setting("difficulty") == "hard", "the saved mode maps Veteran to Hard")
	SaveManager.record_run("meadow", "easy", 40, true, false)
	SaveManager.load_profile()
	check(SaveManager.legacy_rp() == 10 and SaveManager.research_earned() == 10 + 1 + 2, "legacy RP survives re-saving; new records add to it")
	var migrated := SaveManager.migrate_maps({"meadow": {"best_wave": 9, "won": true}, "canyon": {"normal": {"best_wave": 3}}})
	check(migrated.meadow.has("normal") and int(migrated.canyon.normal.best_wave) == 3, "v1 per-map records still read as Normal for legacy RP")
	SaveManager.set_setting("damage_numbers", false)
	SaveManager.load_profile()
	check(SaveManager.setting("damage_numbers") == false, "settings persist")
	SaveManager.set_setting("damage_numbers", true)
	for f in [SaveManager.profile_path(), SaveManager.profile_path() + ".tmp"]:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(f)
	SaveManager.load_profile()


func _write_raw(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()


# --- Research Lab and tier-4 masteries ------------------------------------------------------

func research_game(research: Array, map_id := "meadow", seed_v := 1234, diff := "medium"):
	var g = Game.new(map_id, seed_v, diff, research)
	g.emit_events = false
	return g


func test_research_data() -> void:
	var trees := {}
	for id in ResearchData.NODES:
		var nd: Dictionary = ResearchData.NODES[id]
		check(ResearchData.TREE_ORDER.has(nd.tree), "%s is in a known tree" % id)
		check(int(nd.cost) > 0, "%s has a positive cost" % id)
		check(str(nd.name) != "" and str(nd.blurb) != "" and str(nd.icon) != "", "%s has name, blurb and icon" % id)
		check(nd.slot.x >= -1 and nd.slot.x <= 1 and nd.slot.y >= 0 and nd.slot.y <= 2, "%s slot fits the diagram" % id)
		for r in nd.requires:
			check(ResearchData.NODES.has(r) and ResearchData.NODES[r].tree == nd.tree, "%s requirement %s is in its tree" % [id, r])
			check(ResearchData.NODES.get(r, {"slot": Vector2i(0, 9)}).slot.y < nd.slot.y, "%s requirement %s sits above it" % [id, r])
		check(nd.requires.is_empty() == (nd.slot.y == 0), "%s: only top-row nodes have no requirement" % id)
		if not trees.has(nd.tree):
			trees[nd.tree] = []
		check(not trees[nd.tree].has(nd.slot), "%s has its own slot" % id)
		trees[nd.tree].append(nd.slot)
	check(trees.size() == ResearchData.TREE_ORDER.size(), "every tree has nodes")
	for type in Towers.ORDER:
		check(Research.tree_nodes(type).size() == 4, "%s tree has 4 nodes" % type)
		var m := Research.mastery_node(type)
		check(m != "" and ResearchData.NODES[m].slot.y == 2, "%s tree ends in a Mastery node" % type)
	check(Research.tree_nodes("command").size() == 5, "command tree has 5 nodes")
	check(Research.max_points() == 150, "records can yield 150 RP across 6 sectors (%d)" % Research.max_points())
	check(Research.node_ids().size() == ResearchData.NODES.size(), "node_ids lists every node once")

	check(Research.sanitize(["gun_turret_m", "bogus", "gun_turret_1", "gun_turret_1", 7]) == ["gun_turret_1"], "sanitize drops unknown, duplicate and orphaned nodes")
	check(Research.sanitize(["gun_turret_2b", "gun_turret_1", "gun_turret_m", "gun_turret_2a"]) == ["gun_turret_1", "gun_turret_2a", "gun_turret_2b", "gun_turret_m"], "sanitize keeps a valid chain in canonical order")
	check(Research.sanitize(["gun_turret_2b", "gun_turret_1", "gun_turret_m"]) == ["gun_turret_1", "gun_turret_2b"], "a mastery without both branches is dropped (it needs the whole tree)")
	check(Research.sanitize(["arrow_1", "gun_turret_1"]) == ["gun_turret_1"], "research for the retired towers is dropped (its points come back)")
	check(Research.sanitize("nope").is_empty(), "sanitize tolerates garbage")


func test_research_points() -> void:
	check(Research.points_earned({}) == 0, "no records, no RP")
	check(Research.points_earned(null) == 0 and Research.points_earned([1]) == 0, "garbage records give 0")
	var maps := {"meadow": {"medium": {"best_wave": 60, "medal": true}}}
	check(Research.points_earned(maps) == 5, "Medium medal: 2 + milestones 20, 40, 60 (%d)" % Research.points_earned(maps))
	maps["canyon"] = {"easy": {"best_wave": 25}}
	check(Research.points_earned(maps) == 6, "reaching round 20 elsewhere adds 1")
	maps["meadow"]["easy"] = {"best_wave": 67, "best_endless": 67, "medal": true}
	check(Research.points_earned(maps) == 9, "Easy medal +1, and 27 endless rounds past 40 +2 (%d)" % Research.points_earned(maps))
	maps["meadow"]["cataclysm"] = {"best_wave": 400, "best_endless": 400, "medal": true}
	check(Research.points_earned(maps) == 19, "Cataclysm medal +5, milestones 80 and 100, endless capped at 5 per sector (%d)" % Research.points_earned(maps))
	maps["atlantis"] = {"medium": {"medal": true, "best_wave": 60}}
	maps["crossroads"] = {"medium": "junk", "normal": {"medal": true}}
	check(Research.points_earned(maps) == 19, "unknown sectors and modes and malformed records are ignored")
	var full := {}
	for id in Maps.ORDER:
		full[id] = {}
		for d in Difficulty.ORDER:
			full[id][d] = {"best_wave": 200, "best_endless": 200, "medal": true}
	check(Research.points_earned(full) == Research.max_points(), "a perfect profile earns exactly max_points")
	check(Research.legacy_points({"meadow": {"normal": {"best_wave": 25, "won": true, "stars": 3}}}) == 8, "old rules: 3-star win = 6 + 2 milestones")


func test_research_profile() -> void:
	for f in [SaveManager.profile_path(), SaveManager.profile_path() + ".tmp"]:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(f)
	SaveManager.load_profile()
	check(SaveManager.research_earned() == 0 and SaveManager.research_available() == 0, "fresh profile has no RP")
	check(SaveManager.buy_research("cmd_funds").contains("research points"), "can't buy without RP")
	SaveManager.record_run("meadow", "hard", 80, true, false)
	check(SaveManager.research_earned() == 7, "a Hard medal at round 80 earns 7 RP (3 + four milestones) (%d)" % SaveManager.research_earned())
	check(SaveManager.buy_research("gun_turret_m") != "", "can't skip to a mastery")
	check(SaveManager.buy_research("nope") != "", "unknown node refused")
	check(SaveManager.buy_research("gun_turret_1") == "", "root node bought")
	check(SaveManager.buy_research("gun_turret_1") != "", "can't buy twice")
	check(SaveManager.buy_research("gun_turret_2b") == "" and SaveManager.buy_research("gun_turret_m").contains("everything else"), "one branch isn't enough for the mastery")
	check(SaveManager.buy_research("gun_turret_2a") == "" and SaveManager.buy_research("gun_turret_m").contains("research points"), "with both branches the mastery only waits on RP")
	check(SaveManager.research_available() == 2, "7 - 1 - 2 - 2 = 2 RP left (%d)" % SaveManager.research_available())
	check(SaveManager.buy_research("mortar_tower_1") == "" and SaveManager.buy_research("mortar_tower_2a").contains("research points"), "runs out of RP")
	SaveManager.load_profile()
	check(SaveManager.research_owned() == ["gun_turret_1", "gun_turret_2a", "gun_turret_2b", "mortar_tower_1"], "research persists (%s)" % str(SaveManager.research_owned()))
	SaveManager.reset_research()
	SaveManager.load_profile()
	check(SaveManager.research_owned().is_empty() and SaveManager.research_available() == 7, "reset refunds everything")
	# A hand-edited profile claiming more research than its records pay for is refunded on load.
	SaveManager.profile["research"] = Research.node_ids()
	SaveManager.save_profile()
	SaveManager.load_profile()
	check(SaveManager.research_owned().is_empty(), "unaffordable research is refunded on load")
	for f in [SaveManager.profile_path(), SaveManager.profile_path() + ".tmp"]:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(f)
	SaveManager.load_profile()


func test_research_effects() -> void:
	var base = research_game([])
	var g = research_game(Research.node_ids())
	check(base.gold == Game.START_GOLD and base.lives == 100, "no research: the standard credits and Medium's shields")
	check(g.gold == int(round(Game.START_GOLD * 1.1)) and g.lives == 110, "Reserve Funds +10%% credits, Reinforced Core +10%% shields (%d, %d)" % [g.gold, g.lives])
	check(research_game(["gun_turret_m"]).research.is_empty(), "a run's research is sanitized too")
	g.gold += 5000
	var arrow = g.place_tower("gun_turret", Vector2i(2, 3))
	check(near(arrow.stats().damage, 16.96) and near(arrow.stats().range, 139.1) and near(arrow.stats().rate, 1.284), "Gun Turret research applies to damage, range and rate")
	check(not arrow.stats().has("splash"), "research never adds stats a level lacks")
	check(near(float(Tower.rework_base("gun_turret").damage), 16.0), "research never mutates the data table")
	var boost = g.place_tower("boost_tower", Vector2i(3, 4))
	check(near(boost.get_range(), float(Tower.rework_base("boost_tower").range) * 1.07), "Boost Tower research widens its field")
	g.upgrade_tower(arrow, "a")
	check(near(arrow.stats().damage, float(arrow.base_stats().damage) * 1.06), "research follows the tower through upgrades")
	check(g.sell_value(arrow) == int(floor(arrow.spent * 0.85)), "Salvage Protocols refund 85%")

	g.start_wave()
	check(g.cast_warp() and near(g.ability_cd.warp, 56.0), "Orbital Uplink: warp recharges in 56 s (%.1f)" % g.ability_cd.warp)
	# Bounty Contracts: +10%, fractions carried between kills.
	var before: int = g.gold
	var bounty := 0
	for i in 7:
		var e = put(g, "grunt", 40.0 + i)
		bounty += e.bounty
		g.damage_enemy(e, 1e9, true, null)
	check(g.gold - before == int(floor(bounty * 1.08 + 1e-6)), "Bounty Contracts pay +8%% with carry (%d of %d)" % [g.gold - before, bounty])
	var b0: int = base.gold
	base.start_wave()
	var e0 = put(base, "grunt", 40.0)
	base.damage_enemy(e0, 1e9, true, null)
	check(base.gold - b0 == e0.bounty and base.bounty_carry == 0.0, "no research: exact bounty, no carry")
	var partial = research_game(["gun_turret_1"])
	check(near(partial.level_stats("gun_turret").damage, 16.96) and near(partial.level_stats("mortar_tower").damage, float(Tower.rework_base("mortar_tower").damage)), "research only touches its own tower")


## Research bought or reset mid-run applies at once (playtest round 2, #29).
func test_live_research() -> void:
	var g = research_game([])
	g.gold += 5000
	var old = g.place_tower("gun_turret", Vector2i(2, 3))
	check(near(old.stats().damage, 16.0), "no research: 16 damage")
	g.apply_research(["gun_turret_1"])
	check(near(old.stats().damage, 16.96), "a boost bought mid-run reaches an existing tower (%.2f)" % old.stats().damage)
	var fresh = g.place_tower("gun_turret", Vector2i(8, 3))
	check(near(fresh.stats().damage, 16.96), "and new towers")
	check(g.research == ["gun_turret_1"], "the run's research list follows")

	# Masteries: a tower stopped before its mastery can buy it once the research is in.
	var gat = g.place_tower("gun_turret", Vector2i(10, 5))
	buy_steps(g, gat, "a", 4)
	check(gat.tier == 3 and not g.upgrade_tower(gat, "a"), "without Mastery research the path stops before the mastery")
	g.apply_research(["gun_turret_1", "gun_turret_2a", "gun_turret_2b", "gun_turret_m"])
	g.gold += 50000
	check(g.upgrade_tower(gat, "a") and gat.tier == 4, "with it, the mastery can be bought at once")

	# Run-start bonuses: the difference is granted on the spot.
	var c = research_game([])
	var gold0: int = c.gold
	c.apply_research(["cmd_funds", "cmd_core"])
	check(c.gold == gold0 + Game.start_gold(Research.run_mods(["cmd_funds"])) - Game.START_GOLD, "Reserve Funds adds its credits now (%d)" % c.gold)
	check(c.max_lives == 110 and c.lives == 110, "Reinforced Core adds its shields now (%d/%d)" % [c.lives, c.max_lives])

	# A reset takes it all back: boosts gone, bought masteries kept, credits >= 0, shields >= 1.
	g.apply_research([])
	check(near(old.stats().damage, 16.0) and near(fresh.stats().damage, 16.0), "a reset removes the boosts")
	check(gat.tier == 4, "a mastery already bought stays bought")
	c.gold = 10
	c.lives = 1
	c.apply_research([])
	check(c.gold == 0, "taking back the credit bonus never goes below 0 (%d)" % c.gold)
	check(c.max_lives == 100 and c.lives == 1, "shields come off the maximum, never below 1 (%d/%d)" % [c.lives, c.max_lives])
	var d = research_game(["cmd_core"])
	d.apply_research([])
	check(d.lives == 100 and d.max_lives == 100, "full shields are capped to the new maximum (%d)" % d.lives)

	# Saving after a live purchase keeps the same run.
	var h = research_game([])
	h.gold += 5000
	var ht = h.place_tower("gun_turret", Vector2i(2, 3))
	h.apply_research(["gun_turret_1", "cmd_core"])
	var res := SaveCodec.decode(JSON.parse_string(JSON.stringify(SaveCodec.encode(h))))
	check(res.has("game"), "the run saves and loads")
	if res.has("game"):
		var h2 = res.game
		check(h2.research == h.research and h2.gold == h.gold and h2.lives == h.lives and h2.max_lives == h.max_lives, "same research, credits and shields after loading")
		check(h2.towers.size() == 1 and near(h2.towers[0].stats().damage, ht.stats().damage), "same tower stats after loading")


## The MASTERY burst is for the mastery purchase only, not later secondaries (#32).
func test_upgrade_event_mastery() -> void:
	var g = research_game(["gun_turret_1", "gun_turret_2a", "gun_turret_2b", "gun_turret_m"])
	g.gold += 5000
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	while t.tier < 4 and t.depth.a < Tower.BRANCH_STEPS:
		g.gold += 1000
		g.upgrade_tower(t, "a")
	g.emit_events = true
	g.events.clear()
	g.gold += 5000
	check(g.upgrade_tower(t, "a") and t.tier == 4, "the mastery is bought")
	var ups: Array = g.events.filter(func(ev): return ev.type == "upgrade")
	check(ups.size() == 1 and bool(ups[0].get("mastery", false)), "its upgrade event is marked as the mastery")
	g.emit_events = true
	g.events.clear()
	check(g.upgrade_tower(t, "b"), "a secondary upgrade on the mastered tower")
	ups = g.events.filter(func(ev): return ev.type == "upgrade")
	check(ups.size() == 1 and not bool(ups[0].get("mastery", true)), "a secondary bought after the mastery is not marked")


func test_footprint() -> void:
	var g = new_game()
	g.gold = 100000
	check(Game.size_of("scrapyard") == 2 and Game.size_of("drone_bay") == 1 and Game.size_of("gun_turret") == 1, "the Scrapyard is 2x2, the rest 1x1")
	var y = g.place_tower("scrapyard", Vector2i(2, 5))
	check(y != null and y.size == 2, "a Scrapyard builds on a clear 2x2 block")
	var covered := [Vector2i(2, 5), Vector2i(3, 5), Vector2i(2, 6), Vector2i(3, 6)]
	check(covered.all(func(c): return g.tower_at.get(c) == y), "it fills all four tiles")
	check(y.pos == Vector2(144, 288), "it stands at the centre of its footprint (%s)" % str(y.pos))
	check(g.placement_error("gun_turret", Vector2i(3, 6)).contains("already has a tower"), "its other tiles are taken")
	check(g.placement_error("scrapyard", Vector2i(3, 4)).contains("lane"), "a 2x2 block can't overlap the lane")
	check(g.placement_error("scrapyard", Vector2i(31, 15)) == "Out of bounds", "or run off the grid")
	g.sell_tower(y)
	check(covered.all(func(c): return not g.tower_at.has(c)), "selling frees all four tiles")
	var hg = g.place_tower("scrapyard", Vector2i(11, 5))
	check(hg != null and hg.site == "H", "a 2x2 tower on high ground gets the high-ground bonus")
	var pn = g.place_tower("scrapyard", Vector2i(6, 5))
	check(pn != null and pn.site == "P", "one power-node tile under it is enough for the power bonus")
	# Save and load keep the footprint.
	var res := SaveCodec.decode(JSON.parse_string(JSON.stringify(SaveCodec.encode(g))))
	check(res.has("game"), "a game with 2x2 towers saves and loads")
	if res.has("game"):
		var lg = res.game
		check(lg.tower_at.get(Vector2i(12, 6)) != null and lg.tower_at.get(Vector2i(12, 6)).type == "scrapyard", "loading restores all four tiles")


func test_target_priority() -> void:
	var g = new_game()
	g.gold = 10000
	var t = g.place_tower("tesla_tower", Vector2i(6, 3))
	check(t.hits_air() and t.hits_ground() and t.priority == 0, "a Tesla Tower hits both and starts on Any")
	var walker = put(g, "grunt", 300.0)
	var flyer = g.spawn_enemy("bat", 0, 0.0, 1.0, -1)
	g.enemies.append(flyer)
	flyer.pos = t.pos + Vector2(40, 0)
	walker.pos = t.pos + Vector2(-30, 0)
	g.cycle_priority(t)
	check(t.priority == 1 and g.pick_target(t) == flyer, "Air picks the flyer")
	g.cycle_priority(t)
	check(t.priority == 2 and g.pick_target(t) == walker, "Ground picks the walker")
	walker.alive = false
	check(g.pick_target(t) == flyer, "with no walker in range, a Ground tower still shoots the flyer")
	g.cycle_priority(t)
	check(t.priority == 3, "then Support")
	g.cycle_priority(t)
	check(t.priority == 0, "the priority cycles back to Any")
	t.priority = 1
	var res := SaveCodec.decode(JSON.parse_string(JSON.stringify(SaveCodec.encode(g))))
	check(res.has("game") and res.game.tower_at[Vector2i(6, 3)].priority == 1, "the priority is saved")


func test_mastery_needs_all_research() -> void:
	check(not Research.prerequisites_met(["gun_turret_1", "gun_turret_2a"], "gun_turret_m"), "a mastery needs both branches")
	check(Research.prerequisites_met(["gun_turret_1", "gun_turret_2a", "gun_turret_2b"], "gun_turret_m"), "with the whole tree it's open")
	check(Research.prerequisites_met(["gun_turret_1"], "gun_turret_2a") and Research.prerequisites_met(["gun_turret_1"], "gun_turret_2b"), "branch nodes still need only the root")
	check(Research.buy_block_reason(["gun_turret_1", "gun_turret_2b"], "gun_turret_m", 99).contains("everything else"), "the reason says what's missing")


func test_knowledge_base() -> void:
	for id in Glossary.ENTRIES:
		var ge: Dictionary = Glossary.ENTRIES[id]
		var txt := Lore.text(id)
		check(str(ge.title) != "" and txt.length() > 40 and not txt.contains("{"), "Codex entry %s has text with its numbers filled in" % id)
		check(Glossary.CATEGORIES.has(ge.category), "Codex entry %s is in a known category" % id)
		for s in ge.see:
			check(Glossary.ENTRIES.has(s), "%s links to %s, which exists" % [id, s])
	var ability_keys := ["cloaked", "shield", "heal_pct", "split_type", "emp_radius", "burrow_interval", "blink_interval", "regen_pct", "aura_radius", "grant_interval", "spawn_type", "phases", "cc_immune", "stun_immune"]
	for t in Enemies.ORDER:
		var d: Dictionary = Enemies.ENEMIES[t]
		var ab := Lore.enemy_abilities(d)
		check(not ability_keys.any(func(k): return d.has(k)) or not ab.is_empty(), "the Codex describes %s's abilities" % t)
		check(not Lore.hitters(d).is_empty(), "the Codex lists towers that can hit %s" % t)
		for g in Lore.enemy_topics(d):
			check(Glossary.ENTRIES.has(g), "%s's tip %s exists" % [t, g])
	check(Lore.enemy_abilities(Enemies.ENEMIES.jammer).any(func(s): return s.contains("95 px") and s.contains("2 s")), "the Jammer's EMP quotes its real numbers")
	check(Lore.text("sludge").contains("%d%%" % roundi(Game.SLUDGE_SLOW * 100.0)), "glossary numbers come from the game's constants")
	for t in Towers.ORDER:
		var rows := Lore.tower_rows(t)
		check(rows.size() == 1 + Towers.Rework.TREES[t].retrofits.size() + 3 * 5, "the Codex lists %s's whole tree (%d rows)" % [t, rows.size()])
		check(rows.all(func(r): return int(r.cost) > 0 and str(r.blurb) != "" and not (r.stats as Dictionary).is_empty()), "every %s row has a price, description and stats" % t)


# --- Phantoms, Aegis Walkers, Hydra Frames, Jammers and the new towers -----------------------

func test_phantom_cloak() -> void:
	var g = new_game()
	g.gold = 5000
	var arrow = g.place_tower("gun_turret", Vector2i(2, 3))
	g.state = Game.State.WAVE
	var ph = put(g, "phantom", 150.0)
	check(ph.is_hidden(), "phantoms start cloaked")
	check(g.pick_target(arrow) == null and not arrow.can_target(ph), "towers can't target a cloaked phantom")
	for i in 30:
		g.tick(SIM_DT)
	check(g.projectiles.is_empty() and near(ph.hp, ph.max_hp), "the turret holds fire")
	var radar = g.place_tower("radar_tower", Vector2i(3, 4))
	check(not radar.is_support() and near(arrow.buff_dmg, 0.0), "the Radar isn't a support tower and boosts nothing")
	g.tick(SIM_DT)
	check(not ph.is_hidden(), "a Radar ping reveals phantoms in its circle")
	check(arrow.can_target(ph), "revealed phantoms can be targeted")
	for gone in [radar, arrow]:
		g.towers.erase(gone)
		g.tower_at.erase(gone.cell)
	g.projectiles.clear()
	for i in 90:
		g.tick(SIM_DT)
	check(ph.is_hidden(), "the cloak returns once the reveal wears off")
	check(not Bot.is_pylon("radar_tower") and Bot.is_pylon("boost_tower"), "the bot places Radars by what they reveal, pylons for boosts")


func test_aegis_barrier() -> void:
	var g = new_game()
	g.gold = 5000
	var coil = g.place_tower("tesla_tower", Vector2i(15, 6))
	var e = put(g, "aegis", 40.0)
	check(near(e.shield, 130.0) and near(e.max_shield, 130.0), "aegis starts with a full barrier")
	var d := g.damage_enemy(e, 50.0, false, null)
	check(near(d, 50.0) and near(e.shield, 80.0) and near(e.hp, e.max_hp), "the barrier soaks damage first, armor-free")
	g.damage_enemy(e, 20.0, false, coil)
	check(near(e.shield, 40.0), "Arc Coils hit barriers twice as hard (%.1f)" % e.shield)
	d = g.damage_enemy(e, 100.0, false, null)
	check(near(e.shield, 0.0) and near(e.hp, e.max_hp - 58.0) and near(d, 98.0), "overflow goes to the hull through armor (hp %.1f)" % e.hp)
	g.state = Game.State.WAVE
	for i in int(2.0 / SIM_DT):
		g.tick(SIM_DT)
	check(near(e.shield, 0.0), "no recharge while recently hit")
	for i in int(1.5 / SIM_DT):
		g.tick(SIM_DT)
	check(e.shield > 25.0 and e.shield < 40.0, "barrier recharges after 2.5 s (%.1f)" % e.shield)
	var big = put(g, "aegis", 40.0, 0, 3.0)
	check(near(big.max_shield, 390.0), "barriers scale with enemy HP")


func test_hydra_split() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	g.wave = 7
	g.wave_remaining[7] = 1
	var h = g.spawn_enemy("hydra", 0, 300.0, g.hp_mult_for(7), 7)
	g.enemies.append(h)
	g.damage_enemy(h, 1e9, true, null)
	check(not h.alive and int(g.wave_remaining[7]) == 3, "the wave now waits for 3 pieces")
	g.tick(SIM_DT)
	var pieces: Array = g.enemies.filter(func(e): return e.type == "runner")
	check(pieces.size() == 3, "a destroyed Hydra splits into 3 Skitters (%d)" % pieces.size())
	check(pieces.all(func(e): return absf(e.distance - 300.0) < 20.0 and near(e.max_hp, 45.0 * g.hp_mult_for(7))), "pieces start where it fell, at the wave's HP")
	for p in pieces:
		g.damage_enemy(p, 1e9, true, null)
	g.tick(SIM_DT)
	check(g.state == Game.State.BUILD and g.enemies.is_empty(), "the wave clears once the pieces are gone")


func test_jammer_emp() -> void:
	var g = new_game()
	g.gold = 5000
	var near_t = g.place_tower("gun_turret", Vector2i(2, 3))
	var far_t = g.place_tower("railgun", Vector2i(10, 2))
	g.state = Game.State.WAVE
	var j = put(g, "jammer", 100.0, 0, 20.0)
	j.ability_timer = 0.01
	g.tick(SIM_DT)
	check(near_t.disabled > 1.9 and far_t.disabled == 0.0, "EMP knocks out towers within 95 px only (%.2f)" % near_t.disabled)
	var shots := 0
	for i in int(1.5 / SIM_DT):
		g.tick(SIM_DT)
		for p in g.projectiles:
			if p.source == near_t:
				shots += 1
	check(shots == 0, "a disabled tower doesn't fire")
	for i in int(1.0 / SIM_DT):
		g.tick(SIM_DT)
	check(near_t.disabled == 0.0 and near_t.target != null, "the tower comes back online and re-acquires")


# --- Whole-game simulations ------------------------------------------------------------------

func test_no_towers_loses() -> void:
	for id in Maps.ORDER:
		var g = new_game(id, 1234, "hard")
		var limit := int(600.0 / SIM_DT)
		for i in limit:
			if g.is_over():
				break
			if g.state == Game.State.BUILD:
				g.start_wave()
			g.tick(SIM_DT)
		check(g.state == Game.State.GAMEOVER, "%s: doing nothing loses" % id)
		check(g.wave <= 4, "%s: undefended Hard run (50 shields) ends early (round %d)" % [id, g.wave])
	var c = new_game("meadow", 1234, "cataclysm")
	c.start_wave()
	run_until(c, func(): return c.is_over(), 120.0)
	check(c.is_over() and c.wave == 1 and c.stats.leaked == 1, "on Cataclysm the first leak ends the run")


func test_bot_playthroughs() -> void:
	for id in Maps.ORDER:
		var g = new_game(id, 2024, "easy")
		var bot = Bot.new(g)
		var final: int = g.final_round()
		var ticks := 0
		var limit := int(12000.0 / SIM_DT)
		var t0 := Time.get_ticks_msec()
		while not g.is_over() and not g.medal and ticks < limit:
			bot.update(SIM_DT)
			g.tick(SIM_DT)
			ticks += 1
		var tiers := [0, 0, 0]
		for t in g.towers:
			tiers[mini(t.tier, 3) - 1] += 1
		print("    %-10s %-6s round %2d/%d  lives %3d/%3d  gold %5d  towers %2d (t1 %d, t2 %d, t3 %d)  kills %4d  leaked %3d  %.0fs sim, %d ms" % [
			id, "MEDAL" if g.medal else "LOST", g.wave, final, g.lives, g.max_lives,
			g.gold, g.towers.size(), tiers[0], tiers[1], tiers[2], g.stats.kills, g.stats.leaked,
			ticks * SIM_DT, Time.get_ticks_msec() - t0])
		check(g.medal, "%s: the bot's reasonable build earns the Easy medal" % id)
		if not g.medal:
			continue
		# Endless mode continues on its own after the medal.
		check(g.endless and not g.is_over(), "%s: endless mode begins after the last round" % id)
		ticks = 0
		while not g.is_over() and g.wave < final + 3 and ticks < limit:
			bot.update(SIM_DT)
			g.tick(SIM_DT)
			ticks += 1
		print("    %-10s endless reached round %d (%s)" % [id, g.wave, "alive" if not g.is_over() else "fell"])
		check(g.wave >= final + 3, "%s: endless mode runs several rounds" % id)


func test_bot_full_research() -> void:
	var g = Game.new("crossroads", 2024, "medium", Research.node_ids())
	g.emit_events = false
	var bot = Bot.new(g)
	var ticks := 0
	var limit := int(15000.0 / SIM_DT)
	while not g.is_over() and not g.medal and ticks < limit:
		bot.update(SIM_DT)
		g.tick(SIM_DT)
		ticks += 1
	var t4: int = g.towers.filter(func(t): return t.tier == 4).size()
	print("    crossroads full research (Medium): %s round %d lives %d/%d, %d tier-4 towers" % [
		"MEDAL" if g.medal else "LOST", g.wave, g.lives, g.max_lives, t4])
	check(g.medal, "bot with full research earns the Medium medal")
	check(t4 > 0, "bot buys tier-4 masteries when researched")


## The bot plays the reworked towers: only new towers, Retrofits and paths within the path rules, the Artillery and the CAS
## Gunship aimed at a lane, the Drone Bay flying its newest loadout, and the Radar's preferred sweep and reveal.
func test_bot_new_roster() -> void:
	var g = new_game("meadow", 2024, "easy")
	var bot = Bot.new(g)
	check(Bot.is_pylon("boost_tower") and Bot.is_pylon("augmentation_tower") and not Bot.is_pylon("radar_tower") \
			and not Bot.is_pylon("scrapyard"), "Boost and Augmentation Towers are pylons; the Radar and Scrapyard aren't")
	g.gold = 500000
	g.wave = 30
	for i in 20:
		bot.act()
	check(g.towers.size() >= 20 and g.towers.all(func(t): return Towers.has(t.type)), "the bot builds only reworked towers")
	check(g.towers.any(func(t): return t.retrofit >= 0), "the bot buys Retrofits")
	var rules_kept := true
	for t in g.towers:
		if t.started.size() > 2 and not t.is_uncapped():
			rules_kept = false
		if not t.is_uncapped() and t.locked_in():
			var s: String = t.secondary()
			if s != "" and int(t.depth[s]) > Tower.SECONDARY_CAP:
				rules_kept = false
	check(rules_kept, "the bot's paths keep the two-path rule and the secondary's cap")
	for type in ["artillery_cannon", "cas_gunship", "drone_bay", "radar_tower"]:
		if not g.towers.any(func(t): return t.type == type):
			bot._try_build(type)
	var art = g.towers.filter(func(t): return t.type == "artillery_cannon").front()
	var cas = g.towers.filter(func(t): return t.type == "cas_gunship").front()
	check(art.aim_set and art.aim_point.distance_to(g.nearest_track_point(art.aim_point)) < 1.0, "the Artillery is aimed at a lane point")
	check(cas.aim_set and cas.aim_point == bot.choke(Bot.ORBIT_CHOKE), "the CAS Gunship circles the busiest choke")
	var bay = g.towers.filter(func(t): return t.type == "drone_bay").front()
	var radar = g.towers.filter(func(t): return t.type == "radar_tower").front()
	for t in [bay, radar]:
		for i in 12:
			var k: String = bot.next_key(t)
			if bot.cost_of(t, k) > 0:
				bot.buy(t, k)
	check(int(bay.depth.b) >= 3 and bay.available_loadouts().has("laser") and bay.loadout == bay.available_loadouts().back(),
			"the Drone Bay takes its loadout path and flies its newest loadout")
	check(radar.retrofit == 1 and radar.primary() == "b", "the Radar takes the longer reveal and the faster sweep")


## Every script in the project loads and compiles, including tools that only run from the
## command line (a parse error there would otherwise go unnoticed until someone runs them).
func test_scripts_parse() -> void:
	var paths: Array = []
	for dir in ["res://scripts", "res://data", "res://tools", "res://tests"]:
		_collect_scripts(dir, paths)
	check(paths.size() > 40, "found the project's scripts (%d)" % paths.size())
	for p in paths:
		var s = load(p)
		check(s is Script and s.can_instantiate(), "%s compiles" % p)


func _collect_scripts(dir: String, out: Array) -> void:
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):
		_collect_scripts(dir.path_join(d), out)


# --- Upgrade rework (design/upgrade_rework.md) ---------------------------------------------------

## A tower on meadow with plenty of credits, upgraded along `path` ("t" is the Retrofit, then branch
## keys), with its mastery research on if `research`. Returns [game, tower].
func _upgraded(type: String, path: String, research := false) -> Array:
	var g = Game.new("meadow", 5, "medium")
	g.gold = 1 << 30
	var t = g.place_tower(type, Vector2i(0, 0))
	if research:
		t.mods["mastery"] = true
		t.invalidate()
	for ch in path:
		g.upgrade_tower(t, ch)
	return [g, t]


func _card_state(t, key: String, gold := 1 << 30) -> String:
	return str(UpgradeRules.card(t, key, gold).state)


func test_upgrade_cards() -> void:
	var t = _upgraded("gun_turret", "")[1]
	check(UpgradeRules.card_keys(t) == ["retrofit", "a", "b", "c"], "a tower's panel offers the Retrofit and a card per path")
	check(_card_state(t, "retrofit") == "buy", "the Retrofit card can be bought with credits")
	var short := UpgradeRules.card(t, "retrofit", 0)
	check(short.state == "short" and str(short.reason) == "Cannot afford", "without credits the card says Cannot afford")
	check(["a", "b", "c"].all(func(k): return _card_state(t, k) == "buy"), "every path's first upgrade is buyable from stock")
	check(UpgradeRules.card(t, "b", 1 << 30).node == t.branch("b").nodes[0], "the card offers the path's first step first")
	var tg = _upgraded("gun_turret", "")
	tg[0].buy_retrofit(tg[1], 1)
	check(_card_state(tg[1], "retrofit") == "done" and str(UpgradeRules.card(tg[1], "retrofit", 0).reason) == "Retrofit installed", "a fitted Retrofit shows a finished card")
	t = _upgraded("gun_turret", "ab")[1]
	check(_card_state(t, "c") == "locked", "the third path is locked once two are started")
	check(str(UpgradeRules.card(t, "c", 1 << 30).reason).begins_with("Branch locked"), "and says so")
	t = _upgraded("gun_turret", "babab")[1]
	check(t.locked_in() and t.primary() == "b", "b locked in as the primary")
	check(_card_state(t, "a") == "capped", "the secondary's card is capped at 2")
	check(_card_state(t, "b") == "buy", "the primary keeps going")
	t = _upgraded("gun_turret", "bbbb")[1]
	check(_card_state(t, "b") == "research", "the mastery card needs research without it")
	check(str(UpgradeRules.card(t, "b", 1 << 30).reason).contains("Mastery research"), "and names the research")
	t = _upgraded("gun_turret", "bbbb", true)[1]
	check(_card_state(t, "b") == "buy" and UpgradeRules.card(t, "b", 1 << 30).node == t.branch("b").mastery, "with research the card offers the mastery")
	t = _upgraded("gun_turret", "bbbbb", true)[1]
	check(t.mastered and _card_state(t, "b") == "done", "a mastered path shows a finished card")
	check(str(UpgradeRules.card(t, "b", 1 << 30).reason) == "Mastered", "labelled Mastered")
	# Cards agree with what U / I / O would do.
	for type in Towers.ORDER:
		var tw = _upgraded(type, "c")[1]
		for k in ["a", "b", "c"]:
			var c := UpgradeRules.card(tw, k, 1 << 30)
			check((c.state == "buy") == tw.can_buy(k), "%s %s: card state matches the buy rules" % [type, k])


func test_range_map() -> void:
	var grid = Grid.new("range")
	check(grid.ground_paths.size() == 1 and grid.air_paths.size() == 1, "the test range has one lane")
	check(not Maps.ORDER.has("range"), "the test range isn't a playable sector")


# --- The tower rework (issue #59): the framework, through the Gun Turret ---------------------------

## The nth free buildable tile for a tower type (so tests don't depend on hand-picked cells).
func spot(g, type: String, n: int) -> Vector2i:
	var found := 0
	for y in 14:
		for x in 24:
			var c := Vector2i(x, y)
			if g.placement_error(type, c) == "":
				if found == n:
					return c
				found += 1
	return Vector2i(-1, -1)


## Buys `n` steps on path `key` of a reworked tower (money is no object).
func buy_steps(g, t, key: String, n: int) -> void:
	for i in n:
		g.gold += 10000
		g.upgrade_tower(t, key)


func test_rework_gun_turret_stock() -> void:
	var g = new_game()
	g.gold = 1000
	check(Towers.has("gun_turret"), "the Gun Turret is a tower")
	check(g.tower_cost("gun_turret") == 75, "it costs 75")
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	check(t != null and g.gold == 925, "it builds for 75")
	var s: Dictionary = t.stats()
	check(near(s.damage, 16.0) and near(s.range, 130.0) and near(s.rate, 1.2), "stock: 16 damage, 130 range, 1.2 shots/s")
	check(t.hits_air() and t.hits_ground(), "it hits air and ground")
	check(t.tier == 1 and t.display_name() == "Gun Turret", "stock tier and name")
	check(t.def["class"] == "Assault" and t.def.damage_kind == "physical", "an Assault tower with physical damage")


func test_rework_retrofit() -> void:
	var g = new_game()
	g.gold = 5000
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	check(t.retrofit_options().size() == 3, "three Retrofit options")
	check(t.retrofit_cost(0) == 40 and t.retrofit_cost(1) == 5 and t.retrofit_cost(2) == 25, "priced 40 / 5 / 25")
	var before: int = g.gold
	check(g.buy_retrofit(t, 0) and g.gold == before - 40 and t.retrofit == 0, "Water-Cooled Barrel bought")
	check(near(t.stats().rate, 1.5) and t.tier == 2, "its fire rate rises to 1.5")
	check(not g.buy_retrofit(t, 1) and t.retrofit == 0 and t.retrofit_cost(1) == 0, "the choice is locked")
	var u = g.place_tower("gun_turret", spot(g, "gun_turret", 30))
	check(g.buy_retrofit(u, 1) and near(u.stats().stun_chance, 0.05) and near(u.stats().stun_time, 0.3), "Shock Rounds adds a stun chance")
	var v = g.place_tower("gun_turret", spot(g, "gun_turret", 60))
	check(g.buy_retrofit(v, 2) and near(v.stats().ignite_dps, 3.0), "Incendiary Rounds adds a burn")
	var broke = new_game()
	broke.gold = 75
	var w = broke.place_tower("gun_turret", Vector2i(2, 3))
	check(not broke.buy_retrofit(w, 0) and w.retrofit == -1, "the Retrofit needs the credits")


func test_rework_paths() -> void:
	var g = new_game()
	g.gold = 10000
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	check(t.can_buy("a") and t.can_buy("b") and t.can_buy("c"), "the paths open from stock, no Retrofit needed")
	check(t.upgrade_cost("a") == 55 and t.upgrade_cost("b") == 25 and t.upgrade_cost("c") == 15, "step 1 prices 55 / 25 / 15")
	buy_steps(g, t, "a", 1)
	check(near(t.stats().damage, 22.0), "Heavier Rounds: +6 damage")
	buy_steps(g, t, "a", 1)
	check(near(t.stats().armor_flat, 2.0), "Hardened Tips: ignore 2 armour")
	check(t.upgrade_cost("a") == 405, "step 3 costs 405")
	buy_steps(g, t, "a", 1)
	check(t.primary() == "a" and near(t.stats().armor_pct, 0.5) and near(t.stats().damage, 28.0), "AP Rounds: the primary locks in")
	buy_steps(g, t, "b", 3)
	check(t.depth.b == 2 and not t.can_buy("b") and t.block_reason("b").contains("secondary"), "the secondary stops at 2")
	check(near(t.stats().crit, 0.10) and near(t.stats().range, 160.0), "its two steps still count (crit 10%, range +30)")
	check(not t.can_buy("c") and t.block_reason("c").contains("two"), "the third path is locked")
	buy_steps(g, t, "a", 1)
	check(near(t.stats().armor_pct, 0.75) and near(t.stats().damage, 36.0), "Tungsten Core: 75% and +8")
	check(t.block_reason("a").contains("Mastery"), "the mastery needs the tower's research (%s)" % t.block_reason("a"))
	t.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	t.invalidate()
	check(t.can_buy("a") and t.upgrade_cost("a") == 2475, "with the research the mastery opens at 2,475")
	buy_steps(g, t, "a", 1)
	check(t.mastered and near(t.stats().armor_pct, 1.0) and near(t.stats().damage, 44.0), "Sabot Rounds: full armour piercing, 44 damage")
	check(t.display_name() == "Sabot Rounds" and t.tier == 4, "it takes the mastery's name")


func test_rework_range_path_and_multi_path() -> void:
	var g = new_game()
	g.gold = 20000
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	t.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, t, "b", 5)
	check(t.mastered and near(t.stats().range, 230.0) and near(t.stats().crit, 0.30), "Targeting Computer: 230 range, 30% crit")
	var m = g.place_tower("gun_turret", spot(g, "gun_turret", 30))
	m.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, m, "c", 3)
	check(int(m.stats().multishot) == 2, "Twin Mount: 2 targets")
	buy_steps(g, m, "c", 2)
	check(int(m.stats().multishot) == 3 and bool(m.stats().weakest_extra) and near(m.stats().rate, 1.5), "Triple Mount: 3 targets (+0.3 shots/s from Belt Feed)")


func test_rework_armour_piercing() -> void:
	var g = new_game()
	g.gold = 10000
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	var brute = put(g, "brute", 100.0, 0, 20.0)
	var plain: float = g.damage_enemy(brute, 20.0, false, t)
	check(near(plain, 14.0), "a stock hit loses the brute's 6 armour (%.1f)" % plain)
	buy_steps(g, t, "a", 2)
	var hardened: float = g.damage_enemy(brute, 20.0, false, t)
	check(near(hardened, 16.0), "Hardened Tips ignores 2 of it (%.1f)" % hardened)
	buy_steps(g, t, "a", 1)
	var ap: float = g.damage_enemy(brute, 20.0, false, t)
	check(near(ap, 18.0), "AP Rounds ignores half of what's left (%.1f)" % ap)
	var other = g.place_tower("gun_turret", spot(g, "gun_turret", 30))
	check(near(g.damage_enemy(brute, 20.0, false, other), 14.0), "another tower is unaffected")


func test_rework_crit_and_hit_effects() -> void:
	var g = new_game()
	g.gold = 10000
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	var e = put(g, "grunt", 100.0, 0, 50.0)
	g._fire_projectile(t, e, {"proj_speed": 800.0, "crit": 1.0})
	var p = g.projectiles[g.projectiles.size() - 1]
	check(p.crit and near(p.damage, t.eff_damage() * 2.0), "a sure crit does double damage")
	g.projectiles.clear()
	g._fire_projectile(t, e, {"proj_speed": 800.0, "crit": 0.0})
	check(not g.projectiles[0].crit and near(g.projectiles[0].damage, t.eff_damage()), "no crit chance, no crit")
	g.projectiles.clear()
	var rolls := 0
	for i in 400:
		if g._roll(0.25):
			rolls += 1
	check(rolls > 60 and rolls < 140, "chance rolls come out near their odds (%d / 400)" % rolls)
	var u = g.place_tower("gun_turret", spot(g, "gun_turret", 30))
	g.buy_retrofit(u, 1)
	var stunned := 0
	for i in 60:
		var f = put(g, "grunt", 120.0 + float(i), 0, 50.0)
		var pr = Projectile.new()
		pr.kind = "gun_turret"
		pr.target = f
		pr.target_pos = f.pos
		pr.pos = f.pos
		pr.damage = 1.0
		pr.source = u
		g._projectile_hit(pr)
		if f.stun_timer > 0.0:
			stunned += 1
	check(stunned > 0 and stunned < 18, "Shock Rounds stuns only some hits (%d / 60)" % stunned)
	var v = g.place_tower("gun_turret", spot(g, "gun_turret", 60))
	g.buy_retrofit(v, 2)
	var burn = put(g, "grunt", 200.0, 0, 50.0)
	var bp = Projectile.new()
	bp.kind = "gun_turret"
	bp.target = burn
	bp.pos = burn.pos
	bp.damage = 1.0
	bp.source = v
	g._projectile_hit(bp)
	check(near(burn.dot_dps, 3.0) and near(burn.dot_timer, 2.0), "Incendiary Rounds set the target burning for 3 dps, 2 s")


func test_rework_multi_target() -> void:
	var g = new_game()
	g.gold = 20000
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	var a = put(g, "grunt", 60.0, 0, 100.0)
	var b = put(g, "grunt", 70.0, 0, 100.0)
	a.pos = t.pos + Vector2(40, 0)
	b.pos = t.pos + Vector2(60, 0)
	g._fire_gun(t, a, t.stats())
	check(g.projectiles.size() == 1, "stock: one round")
	g.projectiles.clear()
	buy_steps(g, t, "c", 2)
	g._fire_gun(t, a, t.stats())
	check(g.projectiles.size() == 2 and near(g.projectiles[1].damage, t.eff_damage() * 0.5), "Side Gun: a second target at 50% damage")
	g.projectiles.clear()
	buy_steps(g, t, "c", 1)
	g._fire_gun(t, a, t.stats())
	check(g.projectiles.size() == 2 and near(g.projectiles[1].damage, t.eff_damage()), "Twin Mount: two targets at full damage")


func test_rework_swivel_mount() -> void:
	var g = new_game()
	g.gold = 20000
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	buy_steps(g, t, "c", 1)
	var weak = put(g, "grunt", 60.0, 0, 0.1)
	weak.pos = t.pos + Vector2(40, 0)
	var strong = put(g, "grunt", 70.0, 0, 50.0)
	strong.pos = t.pos + Vector2(60, 0)
	check(g.pick_target(t) != null, "a target in range")
	var p = Projectile.new()
	p.target = weak
	p.damage = weak.hp + 5.0
	g.projectiles.append(p)
	check(g.pick_target(t) == strong, "Swivel Mount skips an enemy that shots in flight will already kill")
	t.cooldown = 1.0
	g._kill(weak, t)
	check(near(t.cooldown, 0.0), "and a kill frees the gun to fire at once")


func test_rework_data_and_unlocks() -> void:
	var tr: Dictionary = Towers.Rework.TREES["gun_turret"]
	check(tr.paths.size() == 3 and tr.retrofits.size() == 3, "three paths and three Retrofits")
	for p in tr.paths:
		check(p.nodes.size() == 4 and not p.mastery.is_empty(), "path %s has 4 steps and a mastery" % p.key)
	check(Research.mastery_node("gun_turret") == "gun_turret_m", "the Gun Turret has a Mastery research node")
	check(Research.tower_mods(["gun_turret_1", "gun_turret_2a", "gun_turret_2b", "gun_turret_m"], "gun_turret").mastery, "its research unlocks the masteries")
	var g = research_game(["gun_turret_1"])
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	check(near(t.stats().damage, 16.0 * 1.06), "research applies to a reworked tower")


func test_enemy_tiers_and_strength() -> void:
	var grid := {"swarm": ["swarmling", "locust", "grunt"], "rusher": ["runner", "", "bat"], "tank": ["brute", "rampart", "gunship"],
		"support": ["shaman", "rally", "bulwark", "mender"], "disruptor": ["jammer"], "evader": ["stalker", "burrower"]}
	for role in grid:
		for i in grid[role].size():
			var id: String = grid[role][i]
			if id != "":
				check(Enemies.ENEMIES[id].role == role and int(Enemies.ENEMIES[id].tier) == i + 1, "%s is %s T%d" % [id, role, i + 1])
	for id in ["phantom", "aegis", "hydra"]:
		check(Enemies.ENEMIES[id].role == "special" and int(Enemies.ENEMIES[id].tier) == 0, "%s is a special, untiered" % id)
	for id in ["juggernaut", "warlord", "leviathan", "colossus"]:
		check(Enemies.ENEMIES[id].role == "boss" and int(Enemies.ENEMIES[id].tier) == 0, "%s is a boss, untiered" % id)
	check(near(Enemies.strength("swarmling"), 13.38, 0.01) and near(Enemies.strength("brute"), 254.40, 0.01), "strength = spd² × max(1, armor) × hp")
	check(near(Enemies.strength("shaman"), 31.25, 0.01), "armor 1 counts as unarmored")
	check(Enemies.rank_score("juggernaut") > Enemies.rank_score("rampart"), "a boss ranks above every non-boss (Dreadnought over Rampart)")
	var g = new_game()
	check(put(g, "bulwark", 50.0).tier() == 3, "an enemy knows its tier")


func test_enemy_traits() -> void:
	check(EnemyTraits.of("shaman") == ["heal"] and EnemyTraits.of("jammer") == ["emp"] and EnemyTraits.of("warlord") == ["summon"], "timed abilities read from the data")
	check(EnemyTraits.of("burrower") == ["burrow"] and EnemyTraits.of("stalker") == ["blink"] and EnemyTraits.of("bulwark") == ["grant"], "burrow, blink, grant")
	check(EnemyTraits.of("rally") == ["aura"] and EnemyTraits.of("hydra") == ["split"] and EnemyTraits.of("mender") == ["regen"], "aura, split, regen")
	check(EnemyTraits.of("aegis") == ["barrier"] and EnemyTraits.of("phantom") == ["cloak"] and EnemyTraits.of("colossus") == ["phases"], "barrier, cloak, phases")
	check(EnemyTraits.of("grunt").is_empty(), "a Drone has none")
	# Two timed traits on one enemy keep their own clocks: a Repair Bot carrying a Jammer's EMP too.
	var g = new_game()
	g.gold = 5000
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	g.state = Game.State.WAVE
	var e = put(g, "shaman", 100.0, 0, 1e4)
	var mate = put(g, "grunt", 110.0, 0, 1e4)
	e.speed = 0.0
	mate.speed = 0.0
	var def: Dictionary = e.def.duplicate()
	def.merge(Enemies.ENEMIES.jammer)
	e.def = def
	e.set_traits(EnemyTraits.of_def(def))
	check(e.traits == ["heal", "emp"] and near(e.trait_timers.heal, 2.0) and near(e.trait_timers.emp, 5.0), "each timed trait starts its own interval")
	mate.hp = mate.max_hp * 0.5
	run_until(g, func(): return false, 2.05)
	check(mate.hp > mate.max_hp * 0.5 and t.disabled == 0.0, "the heal fires at 2 s, the EMP hasn't yet")
	run_until(g, func(): return t.disabled > 0.0, 3.1)
	check(t.disabled > 1.9, "the EMP fires at 5 s on its own clock")
	check(near(e.trait_timers.heal, 1.0, 0.05), "the heal kept its 2 s rhythm (%.2f)" % e.trait_timers.heal)
	e.suppress_timer = 1.0
	var held: float = e.trait_timers.emp
	g.tick(SIM_DT)
	check(near(e.trait_timers.emp, held), "a silenced trait's timer holds")


func test_elite_modifiers() -> void:
	var g = new_game()
	g.gold = 5000
	g.state = Game.State.WAVE
	var plain = put(g, "grunt", 60.0)
	var e = g.spawn_enemy("grunt", 0, 80.0, 1.0, -1, 1.0, ["hasty", "plated"])
	g.enemies.append(e)
	check(e.elite and not plain.elite and e.elite_label == "HASTY PLATED", "an elite knows its modifiers")
	check(near(e.speed, 55.0 * 1.35) and near(e.armor, 4.0), "Hasty +35% speed, Plated +4 armor")
	check(e.rank > plain.rank and near(e.rank, Enemies.strength_of({"speed": 55.0 * 1.35, "armor": 4.0, "hp": 70.0})), "both re-score its rank")
	check(e.bounty == 2 * plain.bounty and e.lives_cost == plain.lives_cost + 1, "double bounty, one more shield on a leak")
	check(not Enemies.ENEMIES.grunt.has("shield") and near(float(Enemies.ENEMIES.grunt.speed), 55.0), "the enemy table is left alone")
	var s = g.spawn_enemy("brute", 0, 100.0, 2.0, -1, 1.0, ["shielded"])
	check(near(s.max_shield, s.max_hp * 0.5) and s.has_trait("barrier") and near(s.rank, Enemies.rank_score("brute")), "Shielded: a barrier worth half its health; rank unchanged")
	var r = g.spawn_enemy("brute", 0, 100.0, 1.0, -1, 1.0, ["resolute"])
	r.apply_stun(1.0)
	check(r.stun_timer == 0.0 and near(r.slow_resist, 0.5), "Resolute: can't be stunned, resists half of a slow")
	check(Modifiers.split_type("brute") == "runner" and Modifiers.split_type("bulwark") == "rally" and Modifiers.split_type("aegis") == "runner", "Splitting: the tier below in its role, else Skitters")
	var sp = g.spawn_enemy("bulwark", 0, 120.0, 1.0, -1, 1.0, ["splitting"])
	g.enemies.append(sp)
	var n0: int = g.enemies.size()
	g.damage_enemy(sp, 1e9, true, null)
	g.tick(SIM_DT)
	check(g.enemies.filter(func(x): return x.alive and x.type == "rally").size() == 2, "a Splitting Bulwark breaks into two Rally Beacons")
	var tw = g.place_tower("gun_turret", Vector2i(2, 3))
	var jm = g.spawn_enemy("grunt", 0, 100.0, 1e4, -1, 1.0, ["jamming"])
	jm.speed = 0.0
	g.enemies.append(jm)
	jm.trait_timers.emp = 0.01
	g.tick(SIM_DT)
	check(jm.has_trait("emp") and near(tw.disabled, 1.5, 0.05), "Jamming: an EMP that knocks towers out for 1.5 s")
	var cm = g.spawn_enemy("brute", 0, 300.0, 1.0, -1, 1.0, ["commanding"])
	var mate = put(g, "grunt", 320.0)
	g.enemies.append(cm)
	g.tick(SIM_DT)
	check(near(mate.haste, 0.15) and near(cm.haste, 0.0), "Commanding: others nearby +15% speed")
	check(not Modifiers.allowed("jammer", "jamming") and not Modifiers.allowed("aegis", "shielded") and not Modifiers.allowed("rampart", "resolute"), "never a trait it already has")
	check(not Modifiers.allowed("juggernaut", "hasty"), "bosses are never elites")
	check(near(Modifiers.cost_mult(["hasty", "plated"]), 2.56), "modifier costs multiply")
	check(Modifiers.max_per_elite(39) == 1 and Modifiers.max_per_elite(40) == 2 and Modifiers.max_per_elite(80) == 3, "1, 2 from round 40, 3 from round 80")
	# A real round's elites arrive with their modifiers.
	var g2 = new_game()
	g2.wave = 9
	g2.start_wave()
	var seen_elite := false
	for i in int(40.0 / SIM_DT):
		g2.tick(SIM_DT)
		for x in g2.enemies:
			if x.elite and x.mods.has("shielded"):
				seen_elite = true
		if seen_elite:
			break
	check(seen_elite, "round 10 sends its Shielded elite")


func test_leak_bands() -> void:
	for id in Enemies.ORDER:
		var d: Dictionary = Enemies.ENEMIES[id]
		if bool(d.get("boss", false)):
			check(int(d.lives) == Waves.first_boss_round(id), "%s costs its introduction round (%d)" % [id, int(d.lives)])
		else:
			check(int(d.lives) == Enemies.leak_band(Enemies.strength(id)), "%s leaks by its strength band (%d)" % [id, int(d.lives)])
	check(Enemies.leak_band(49.9) == 1 and Enemies.leak_band(50.0) == 2 and Enemies.leak_band(150.0) == 3 and Enemies.leak_band(400.0) == 4, "bands: <50, 50-150, 150-400, 400+")
	var g = new_game()
	g.lives = 100
	var e = g.spawn_enemy("brute", 0, 0.0, 1.0, -1, 1.0, ["hasty"])
	g.enemies.append(e)
	e.distance = e.path_len
	g.state = Game.State.WAVE
	g.tick(SIM_DT)
	check(g.lives == 100 - 4, "an elite Siege Mech leaks for its band (3) plus one")


func test_packs_and_phantom_flight() -> void:
	check(bool(Enemies.ENEMIES.phantom.flying), "the Phantom flies")
	var gp = new_game()
	var ph = gp.spawn_enemy("phantom", 0)
	var bat = gp.spawn_enemy("bat", 0)
	check(ph.flying and ph.on_track() and ph.curve == gp.grid.ground_paths[0], "the Phantom flies along the track")
	check(not bat.on_track() and bat.curve == gp.grid.air_paths[0], "other flyers take the flight line")
	var g = new_game()
	g.wave = 18
	g.start_wave()
	var needles: Array = g.spawn_queue.filter(func(s): return s.type == "needle")
	check(needles.size() >= 2 and needles.size() % 2 == 0, "Needles come in pairs (%d)" % needles.size())
	needles.sort_custom(func(a, b): return a.time < b.time)
	check(int(needles[0].group) == int(needles[1].group) and near(float(needles[1].time) - float(needles[0].time), 0.25), "a pair shares a lane, 0.25 s apart")
	var g2 = new_game()
	g2.wave = 46
	g2.start_wave()
	var shrikes: Array = g2.spawn_queue.filter(func(s): return s.type == "shrike")
	check(shrikes.size() >= 5 and shrikes.size() % 5 == 0, "Shrikes come in clusters of five (%d)" % shrikes.size())


func test_fury_and_titan() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var f = put(g, "fury", 100.0)
	g.damage_enemy(f, f.max_hp * 0.4, true, null)
	check(near(f.rush, 1.0), "no adrenaline above half health")
	g.damage_enemy(f, f.max_hp * 0.2, true, null)
	check(near(f.rush, 1.3), "adrenaline below half health: +30%")
	f.hp = f.max_hp
	g.damage_enemy(f, 1.0, true, null)
	check(near(f.rush, 1.3), "healing doesn't undo it")
	f.haste = 0.25
	var d0: float = f.distance
	f.step(SIM_DT)
	check(near(f.distance - d0, f.speed * 1.3 * 1.25 * SIM_DT, 0.01), "adrenaline and Rally haste multiply")
	var t = put(g, "titan", 200.0)
	var sp0: float = t.speed
	check(near(t.armor, 9.0) and near(t.slow_resist, 0.5), "Titan: 9 armor, half resists slows")
	g.damage_enemy(t, t.max_hp * 0.55, true, null)
	check(t.shed and near(t.armor, 5.0) and near(t.speed, sp0 * 1.2), "at half health the plates shed: armor 5, +20% speed")
	t.hp = t.max_hp
	g.damage_enemy(t, 1.0, true, null)
	check(near(t.armor, 5.0), "for good")


func test_siphon_drain() -> void:
	var g = new_game()
	g.gold = 5000
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	var rate0: float = t.eff_rate()
	var range0: float = t.get_range()
	g.state = Game.State.WAVE
	var s = put(g, "siphon", 100.0, 0, 1e4)
	s.speed = 0.0
	s.pos = t.pos + Vector2(60, 0)
	g.tick(SIM_DT)
	check(near(t.eff_rate(), rate0 * 0.8) and near(t.get_range(), range0 * 0.85), "inside the aura: -20% fire rate, -15% range")
	var s2 = put(g, "siphon", 100.0, 0, 1e4)
	s2.speed = 0.0
	s2.pos = t.pos + Vector2(-60, 0)
	g.tick(SIM_DT)
	check(near(t.eff_rate(), rate0 * 0.8), "two Siphons don't stack")
	s.suppress_timer = 5.0
	s2.suppress_timer = 5.0
	g.tick(SIM_DT)
	check(near(t.eff_rate(), rate0), "a silenced Siphon drains nothing")


func test_disruptors_and_disable_guard() -> void:
	var g = new_game()
	g.gold = 5000
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	g.state = Game.State.WAVE
	var b = put(g, "blackout", 100.0, 0, 1e4)
	b.speed = 0.0
	b.pos = t.pos + Vector2(120, 0)
	b.trait_timers.emp = 0.01
	g.tick(SIM_DT)
	check(near(t.disabled, 2.5, 0.05), "Blackout Rig: 130 px, offline 2.5 s")
	b.pos = t.pos + Vector2(400, 0)
	run_until(g, func(): return t.disabled <= 0.0, 3.0)
	check(t.disable_guard > 0.9, "back online with a 1 s guard")
	b.pos = t.pos + Vector2(60, 0)
	b.trait_timers.emp = 0.01
	g.tick(SIM_DT)
	check(t.disabled == 0.0, "an EMP inside the guard does nothing")
	run_until(g, func(): return t.disable_guard <= 0.0, 1.1)
	b.trait_timers.emp = 0.01
	g.tick(SIM_DT)
	check(t.disabled > 2.0, "after the guard it can be knocked out again")
	# Capacitor: a telegraphed 2 s charge, then a 3 s blackout; a stun during the charge cancels it.
	var g2 = new_game()
	g2.gold = 5000
	var t2 = g2.place_tower("gun_turret", Vector2i(2, 3))
	g2.state = Game.State.WAVE
	var c = put(g2, "capacitor", 100.0, 0, 1e4)
	c.speed = 0.0
	c.pos = t2.pos + Vector2(150, 0)
	c.trait_timers.emp = 0.01
	g2.tick(SIM_DT)
	check(c.charge_timer > 1.9 and t2.disabled == 0.0, "it charges first")
	run_until(g2, func(): return t2.disabled > 0.0, 2.2)
	check(near(t2.disabled, 3.0, 0.1), "then blacks out towers within 160 px for 3 s")
	c.trait_timers.emp = 0.01
	g2.tick(SIM_DT)
	check(c.charge_timer > 0.0, "charging again")
	c.apply_stun(0.5)
	g2.tick(SIM_DT)
	check(c.charge_timer == 0.0, "a stun cancels the charge")
	c.trait_timers.emp = 0.01
	g2.tick(SIM_DT)
	c.suppress_timer = 1.0
	g2.tick(SIM_DT)
	check(c.charge_timer == 0.0, "so does a silence")


func test_shifter_wake() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var s = put(g, "shifter", 100.0)
	var mate = put(g, "grunt", 170.0)
	var boss = put(g, "juggernaut", 165.0)
	s.blink_timer = 0.001
	g.tick(SIM_DT)
	check(near(mate.wake, 0.2) and near(mate.wake_timer, 2.0, 0.05), "where it lands, others get +20% speed for 2 s")
	check(boss.wake == 0.0 and s.wake == 0.0, "not bosses, not itself")
	run_until(g, func(): return false, 2.1)
	check(mate.wake == 0.0, "the wake wears off")


func test_wraith_energy_only() -> void:
	var g = new_game()
	g.gold = 5000
	var w = put(g, "wraith", 100.0)
	check(w.flying and w.cloaked, "the Wraith flies, cloaked")
	var gun = g.place_tower("gun_turret", Vector2i(2, 3))
	var hp0: float = w.hp
	check(g.damage_enemy(w, 50.0, true, gun) == 0.0 and w.hp == hp0, "physical hits do nothing")
	check(g.damage_enemy(w, 50.0, true, null) == 0.0, "nor does untyped physical damage")
	check(g.damage_enemy(w, 50.0, true, null, false, false, false, false, "energy") > 0.0, "energy hurts it")
	w.apply_burn(20.0, 2.0)
	var hp1: float = w.hp
	g.state = Game.State.WAVE
	g.tick(SIM_DT)
	check(w.hp < hp1, "burning counts as energy")


func test_masquerade_and_decoy() -> void:
	var g = new_game()
	g.gold = 5000
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	t.mode = Tower.Mode.STRONG
	var m = put(g, "masquerade", 150.0)
	var mech = put(g, "brute", 140.0)
	check(m.disguised and m.look_type() == "grunt" and m.shown_role() == "swarm" and near(m.rank, Enemies.rank_score("grunt")), "disguised as a Drone: look, role and rank")
	check(near(m.speed, 55.0), "at the Drone's speed")
	check(g.pick_target(t) == mech, "Strongest ignores it while disguised")
	g.damage_enemy(m, m.max_hp * 0.55, true, null)
	check(not m.disguised and m.look_type() == "masquerade" and near(m.rank, Enemies.rank_score("masquerade")), "below half health it drops the disguise")
	check(near(m.speed, 80.0), "and flees at 80")
	check(g.pick_target(t) == m, "now Strongest goes for it")
	g.state = Game.State.WAVE
	run_until(g, func(): return false, 3.1)
	check(near(m.speed, 60.0), "settling at 60 after 3 s")
	var d = put(g, "decoy", 120.0)
	var ti = put(g, "titan", 130.0)
	var boss = put(g, "juggernaut", 160.0)
	check(d.rank > ti.rank and d.rank > Enemies.rank_score("rampart") and d.rank < boss.rank, "a Decoy Beacon outranks every non-boss, never a boss")
	check(d.shown_role() == "tank" and d.role() == "special", "it shows as a heavy hull")
	g.damage_enemy(boss, 1e9, true, null)
	check(g.pick_target(t) == d, "so Strongest towers shoot it")
	check(not Modifiers.allowed("masquerade", "hasty") and not Modifiers.allowed("decoy", "plated"), "tricks are never elites")


func test_mirage_holograms() -> void:
	var g = new_game()
	g.lives = 50
	g.state = Game.State.WAVE
	var m = put(g, "mirage", 300.0)
	m.speed = 0.0
	m.trait_timers.holo = 0.001
	g.tick(SIM_DT)
	g.tick(SIM_DT)
	var holos: Array = g.enemies.filter(func(e): return e.alive and e.hologram)
	check(holos.size() == 2, "projects two holograms (%d)" % holos.size())
	check(holos.all(func(h): return h.max_hp == 1.0 and h.bounty == 0 and h.lives_cost == 0 and near(h.rank, m.rank) and h.traits.is_empty()), "1 HP, no bounty or leak cost, its Mirage's rank, no abilities")
	var gold0: int = g.gold
	g.damage_enemy(holos[0], 5.0, false, null)
	check(not holos[0].alive and g.gold == gold0, "any hit pops one, for nothing")
	holos[1].distance = holos[1].path_len
	g.tick(SIM_DT)
	check(not holos[1].alive and g.lives == 50, "at the core it vanishes without leaking")
	m.trait_timers.holo = 0.001
	g.tick(SIM_DT)
	g.tick(SIM_DT)
	var more: Array = g.enemies.filter(func(e): return e.alive and e.hologram)
	check(more.size() == 2, "and again")
	g.damage_enemy(m, 1e9, true, null)
	g.tick(SIM_DT)
	check(more.all(func(h): return not h.alive), "they vanish with their Mirage")
	check(not g.enemies.any(func(e): return e.alive and e.hologram), "none left")


func test_rework_roles_and_damage_kinds() -> void:
	var valid: Array = Enemies.ROLE_RESIST.keys()
	for id in Enemies.ORDER:
		check(valid.has(str(Enemies.ENEMIES[id].get("role", ""))), "%s has a role" % id)
	var g = new_game()
	check(Enemies.ENEMIES.warlord.role == "boss" and Enemies.ENEMIES.brute.role == "tank" and Enemies.ENEMIES.swarmling.role == "swarm", "roles read sensibly")
	var boss = put(g, "warlord", 50.0)
	var swarm = put(g, "swarmling", 60.0)
	check(near(boss.role_resist(), 0.75) and near(swarm.role_resist(), 0.0), "a boss resists 75%, a swarm nothing")
	g.gold = 5000
	var t = g.place_tower("gun_turret", spot(g, "gun_turret", 5))
	check(t.damage_kind() == "physical", "the Gun Turret's hits are physical")
	g.damage_enemy(swarm, 1.0, false, t)
	check(swarm.last_hit_kind == "physical", "a hit records its kind")
	var arc = g.place_tower("tesla_tower", spot(g, "tesla_tower", 80))
	g.damage_enemy(swarm, 1.0, false, null)
	check(swarm.last_hit_kind == "physical", "a hit with no tower is physical")


func test_rework_save_roundtrip() -> void:
	var g = research_game(["gun_turret_1", "gun_turret_2a", "gun_turret_2b", "gun_turret_m"], "canyon", 99, "hard")
	g.gold = 50000
	var a = g.place_tower("gun_turret", spot(g, "gun_turret", 3))
	g.buy_retrofit(a, 2)
	buy_steps(g, a, "a", 3)
	buy_steps(g, a, "c", 2)
	var m = g.place_tower("gun_turret", spot(g, "gun_turret", 40))
	buy_steps(g, m, "b", 5)
	check(m.mastered, "the mastery is bought")
	var data := SaveCodec.encode(g)
	var dec := SaveCodec.decode(JSON.parse_string(JSON.stringify(data)))
	check(dec.has("game"), "the save decodes (%s)" % dec.get("error", ""))
	if not dec.has("game"):
		return
	var g2 = dec.game
	check(g2.towers.size() == 2, "both towers come back")
	var a2 = g2.tower_at[a.cell]
	check(a2.retrofit == 2 and a2.depth.a == 3 and a2.depth.c == 2 and a2.primary() == "a", "the Retrofit and the paths are restored")
	check(a2.look_key() == a.look_key() and near(a2.stats().ignite_dps, 3.0) and near(a2.stats().armor_pct, 0.5), "its stats are restored")
	var m2 = g2.tower_at[m.cell]
	check(m2.mastered and m2.look_key() == m.look_key() and near(m2.stats().range, m.stats().range) and near(m2.stats().range, 230.0 * 1.07), "the mastery is restored (research still applies)")
	var bad = JSON.parse_string(JSON.stringify(data))
	bad.towers[0]["retrofit"] = 7
	check(SaveCodec.decode(bad).has("error"), "an invalid Retrofit option is refused")


func test_rework_mortar() -> void:
	var g = new_game()
	g.gold = 20000
	var t = g.place_tower("mortar_tower", spot(g, "mortar_tower", 0))
	check(t != null and g.tower_cost("mortar_tower") == 150, "the Mortar Tower builds for 150")
	var s: Dictionary = t.stats()
	check(near(s.damage, 30.0) and near(s.splash, 60.0) and near(s.range, 110.0) and near(s.rate, 0.6), "stock: 30 damage, 60 px blast, 110 range, 0.6/s")
	check(t.hits_ground() and not t.hits_air(), "ground only")
	# Retrofits.
	check(g.buy_retrofit(t, 0) and near(t.stats().damage, 34.0) and near(t.stats().range, 120.0) and near(t.stats().splash, 65.0), "Field Kit: +4 damage, +10 range, +5 px")
	var b = g.place_tower("mortar_tower", spot(g, "mortar_tower", 20))
	check(g.buy_retrofit(b, 1) and near(b.stats().burrow_sight, 0.5), "Bunker Sight")
	var sm = g.place_tower("mortar_tower", spot(g, "mortar_tower", 40))
	check(g.buy_retrofit(sm, 2) and int(sm.stats().smoke_every) == 4, "Smoke Shells")
	# Armour is cracked by the Power path.
	var p = g.place_tower("mortar_tower", spot(g, "mortar_tower", 60))
	buy_steps(g, p, "a", 3)
	var brute = put(g, "brute", 100.0, 0, 20.0)
	check(near(g.damage_enemy(brute, 20.0, false, p), 20.0 - 6.0 * 0.5), "AP shells ignore half the armour")
	# Cluster bomblets scatter round the impact.
	var c = g.place_tower("mortar_tower", spot(g, "mortar_tower", 80))
	buy_steps(g, c, "c", 3)
	check(int(c.stats().bomblets) == 4 and near(c.stats().splash, 80.0), "Cluster Shells: 4 bomblets, 80 px blast")
	g.emit_events = true
	g.events.clear()
	var e = put(g, "grunt", 100.0, 0, 50.0)
	g._fire_projectile(c, e, c.stats())
	var sh = g.projectiles[g.projectiles.size() - 1]
	sh.pos = e.pos
	g._projectile_hit(sh)
	var bombs := 0
	for ev in g.events:
		if ev.type == "bomblet":
			bombs += 1
	check(bombs == 4, "four bomblet bursts (%d)" % bombs)
	# Twin then barrage tubes.
	var tb = g.place_tower("mortar_tower", spot(g, "mortar_tower", 100))
	tb.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, tb, "b", 5)
	check(tb.mastered and int(tb.stats().tubes) == 3 and near(tb.stats().rate, 1.7) and near(tb.stats().range, 165.0), "Barrage Battery: 3 tubes, 1.7/s, 165 range")
	# Smoke: every 4th shell, and the cloud slows ground enemies inside.
	var tgt = put(g, "grunt", 100.0, 0, 50.0)
	var flagged := 0
	for i in 8:
		g._fire_mortar(sm, tgt, sm.stats())
		if g.projectiles[g.projectiles.size() - 1].smoke:
			flagged += 1
	check(flagged == 2, "every 4th shell is a smoke shell (%d / 8)" % flagged)
	g.smokes.append({"pos": tgt.pos, "r": 60.0, "t": 3.0, "slow": 0.15})
	g._update_smokes(0.1)
	check(tgt.slow_amount > 0.1, "the cloud slows it")
	g._update_smokes(3.5)
	check(g.smokes.is_empty(), "the cloud fades")
	# Burrowed enemies: a Bunker Sight only counts inside a sensor's field.
	var bur = put(g, "grunt", 100.0, 0, 50.0)
	bur.burrowed = true
	check(not g._burrow_visible(b, bur), "burrowed and uncovered: unseen")
	check(not g._burrow_visible(t, bur), "no sight, no targeting")
	var hp: float = bur.hp
	var ms = g.place_tower("mortar_tower", spot(g, "mortar_tower", 120))
	buy_steps(g, ms, "a", 0)
	ms.retrofit = 1
	ms.invalidate()
	g._fire_projectile(ms, bur, ms.stats())
	var sh2 = g.projectiles[g.projectiles.size() - 1]
	sh2.pos = bur.pos
	g._projectile_hit(sh2)
	check(bur.hp < hp and bur.hp > hp - ms.stats().damage * 0.6, "Bunker Sight hits a burrowed enemy at half damage")
	var stock = g.place_tower("mortar_tower", spot(g, "mortar_tower", 140))
	var hp2: float = bur.hp
	g._fire_projectile(stock, bur, stock.stats())
	var sh3 = g.projectiles[g.projectiles.size() - 1]
	sh3.pos = bur.pos
	g._projectile_hit(sh3)
	check(near(bur.hp, hp2), "a stock Mortar can't hurt a burrowed enemy")


func test_rework_rocket_salvo() -> void:
	var g = new_game()
	g.gold = 40000
	g.emit_events = true
	var t = g.place_tower("rocket_salvo", spot(g, "rocket_salvo", 0))
	check(t != null and g.tower_cost("rocket_salvo") == 200, "the Rocket Salvo builds for 200")
	var s: Dictionary = t.stats()
	check(near(s.damage, 19.0) and near(s.splash, 25.0) and near(s.range, 180.0) and near(s.rate, 0.4) and int(s.missiles) == 3, "stock: 3 rockets of 19, 25 px blast, 180 range, a salvo every 2.5 s")
	check(t.hits_air() and t.hits_ground(), "air and ground")
	check(g.buy_retrofit(t, 0) and near(t.stats().air_mult, 1.4), "Proximity Fuses: +40% against air")
	var sm = g.place_tower("rocket_salvo", spot(g, "rocket_salvo", 20))
	check(g.buy_retrofit(sm, 1) and near(sm.stats().smoke_slow, 0.1), "Smoke Trails")
	var fl = g.place_tower("rocket_salvo", spot(g, "rocket_salvo", 40))
	check(g.buy_retrofit(fl, 2) and near(fl.stats().ground_burn, 3.0), "Incendiary Warheads")
	# One salvo: each rocket at a different enemy, the spares on the strongest.
	var e1 = put(g, "grunt", 100.0, 0, 5.0)
	var e2 = put(g, "grunt", 110.0, 0, 50.0)
	var shooter = g.place_tower("rocket_salvo", spot(g, "rocket_salvo", 60))
	shooter.pos = e1.pos + Vector2(40, 0)
	g._fire_salvo(shooter, shooter.stats())
	var rockets: Array = g.projectiles.filter(func(p): return p.kind == "rocket_salvo")
	check(rockets.size() == 3, "three rockets (%d)" % rockets.size())
	var tg: Array = []
	for p in rockets:
		tg.append(p.target)
	check(tg.has(e1) and tg.has(e2) and tg.filter(func(x): return x == e2).size() == 2, "two enemies get a rocket each; the spare goes to the strongest")
	# Hits: air bonus, burning ground, smoke trail.
	g.projectiles.clear()
	var fly = put(g, "bat", 100.0, 0, 50.0)
	var base_hp: float = fly.hp
	g._fire_salvo(t, t.stats())
	check(true, "fired")
	var hit_p = Projectile.new()
	hit_p.kind = "rocket_salvo"
	hit_p.pos = fly.pos
	hit_p.splash = 25.0
	hit_p.damage = 19.0
	hit_p.air_mult = 1.4
	hit_p.source = t
	g._projectile_hit(hit_p)
	check(fly.hp < base_hp, "a rocket's blast hurts a flyer")
	g.pools.clear()
	var fp = Projectile.new()
	fp.kind = "rocket_salvo"
	fp.pos = e2.pos
	fp.splash = 25.0
	fp.damage = 1.0
	fp.ground_burn = 3.0
	fp.ground_burn_time = 2.0
	fp.source = fl
	g._projectile_hit(fp)
	check(g.pools.size() == 1 and near(g.pools[0].dps, 3.0), "Incendiary Warheads leave burning ground")
	# Paths.
	var pw = g.place_tower("rocket_salvo", spot(g, "rocket_salvo", 80))
	buy_steps(g, pw, "a", 2)
	check(near(pw.stats().damage, 24.0) and near(pw.stats().splash, 35.0), "Power 2: 24 damage, 35 px")
	var rg = g.place_tower("rocket_salvo", spot(g, "rocket_salvo", 100))
	rg.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, rg, "b", 2)
	check(bool(rg.stats().homing) and near(rg.stats().range, 200.0), "Seeker Heads: homing, 200 range")
	buy_steps(g, rg, "b", 3)
	check(rg.mastered and near(rg.stats().range, 300.0) and bool(rg.stats().never_miss) and bool(rg.stats().retarget), "Hunter Seekers: 300 range, never miss")
	var pl = g.place_tower("rocket_salvo", spot(g, "rocket_salvo", 120))
	pl.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pl, "c", 5)
	check(pl.mastered and int(pl.stats().missiles) == 8 and bool(pl.stats().ripple) and near(pl.stats().rate, 0.588), "Ripple Salvo: 8 rockets, rippling")
	g.projectiles.clear()
	var tgt = put(g, "grunt", 100.0, 0, 50.0)
	pl.pos = tgt.pos + Vector2(40, 0)
	g._fire_salvo(pl, pl.stats())
	var holds: Array = g.projectiles.map(func(p): return p.hold)
	check(holds.size() == 8 and near(holds[0], 0.0) and near(holds[7], 0.63), "the salvo ripples out one after another")
	# Re-targeting: a homing rocket whose target died picks the nearest enemy.
	g.enemies.clear()
	g.projectiles.clear()
	var a = put(g, "grunt", 100.0, 0, 50.0)
	var b = put(g, "grunt", 130.0, 0, 50.0)
	var rp = Projectile.new()
	rp.kind = "rocket_salvo"
	rp.pos = a.pos
	rp.vel = Vector2.ZERO
	rp.speed = 330.0
	rp.homing = true
	rp.retarget = true
	rp.source = rg
	rp.target = a
	rp.target_pos = a.pos
	a.alive = false
	g._update_rocket(rp, 0.05)
	check(rp.target == b, "a re-targeting rocket switches to the nearest enemy")
	# Smoke trail clouds also slow flyers.
	g.smokes.clear()
	var tr = Projectile.new()
	tr.kind = "rocket_salvo"
	tr.pos = Vector2(10, 10)
	tr.target_pos = Vector2(400, 10)
	tr.vel = Vector2(330, 0)
	tr.speed = 330.0
	tr.smoke_slow = 0.1
	tr.smoke_time = 2.0
	tr.source = sm
	for i in 20:
		g._update_rocket(tr, 0.05)
	check(g.smokes.size() >= 5 and g.smokes[0].air, "a smoke-trail rocket leaves a line of clouds")


func test_rework_laser_tower() -> void:
	var g = new_game()
	g.gold = 60000
	var t = g.place_tower("laser_tower", spot(g, "laser_tower", 0))
	check(t != null and g.tower_cost("laser_tower") == 250, "the Laser Tower builds for 250")
	var s: Dictionary = t.stats()
	check(near(s.damage, 25.0) and near(s.range, 150.0) and near(s.ramp, 3.0) and near(s.ramp_time, 3.0) and int(s.beams) == 1, "stock: 25 dps, x3 over 3 s, 150 range")
	check(t.is_beam() and t.hits_air() and t.hits_ground() and t.def.damage_kind == "energy", "an energy beam that hits air and ground")
	check(g.buy_retrofit(t, 0) and near(t.stats().damage, 33.0), "Capacitor Bank: +8 dps")
	var hs = g.place_tower("laser_tower", spot(g, "laser_tower", 20))
	check(g.buy_retrofit(hs, 1) and near(hs.stats().ramp, 3.5), "Heat Sinks: ceiling x3.5")
	var rm = g.place_tower("laser_tower", spot(g, "laser_tower", 40))
	check(g.buy_retrofit(rm, 2) and near(rm.stats().ramp_keep, 0.5), "Ramp Memory")
	# The ramp, and the armour melting for good.
	var bt = g.place_tower("laser_tower", spot(g, "laser_tower", 60))
	var brute = put(g, "brute", 100.0, 0, 50.0)
	bt.pos = brute.pos + Vector2(30, 0)
	var armor0: float = brute.armor_now() if brute.has_method("armor_now") else brute.armor
	for i in 60:
		g._update_laser_rework(bt, bt.stats(), 0.05)
	check(near(bt.ramp, 3.0, 0.01) and near(bt.ramp_mult, 3.0, 0.01), "after 3 s the beam is at x3")
	check(near(brute.armor_shred, 3.0, 0.01), "three seconds of melt take 3 armour")
	var shred_before: float = brute.armor_shred
	bt.beam_targets.clear()
	bt.beam_ramps.clear()
	check(near(brute.armor_shred, shred_before), "the melted armour stays gone")
	# Power path.
	var pw = g.place_tower("laser_tower", spot(g, "laser_tower", 80))
	pw.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pw, "a", 2)
	check(near(pw.stats().ramp, 3.5) and near(pw.stats().ramp_time, 2.2), "Power 2: x3.5 in 2.2 s")
	buy_steps(g, pw, "a", 3)
	check(pw.mastered and near(pw.stats().ramp, 8.0) and near(pw.stats().ramp_time, 1.5), "Annihilator: x8 in 1.5 s")
	# Multi-target: extra beams on their own targets, at a share of the power, each ramping alone.
	var mt = g.place_tower("laser_tower", spot(g, "laser_tower", 100))
	mt.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, mt, "b", 1)
	check(int(mt.stats().beams) == 2 and near(mt.stats().beam_power, 0.4), "Beam Splitter: 2 beams, the second at 40%")
	buy_steps(g, mt, "b", 4)
	check(mt.mastered and int(mt.stats().beams) == 4 and near(mt.stats().beam_power, 0.75), "Prism Array: 4 beams at 75%")
	g.enemies.clear()
	var e1 = put(g, "grunt", 100.0, 0, 500.0)
	var e2 = put(g, "grunt", 104.0, 0, 500.0)
	var e3 = put(g, "grunt", 108.0, 0, 500.0)
	mt.pos = e1.pos + Vector2(30, 0)
	for i in 10:
		g._update_laser_rework(mt, mt.stats(), 0.05)
	check(mt.beam_targets.size() == 3 and mt.beam_ramps.size() == 3, "three enemies, three beams")
	check(near(mt.beam_ramps[0], 0.5, 0.01) and near(mt.beam_ramps[2], 0.5, 0.01), "each beam ramps on its own")
	var hp1: float = mt.beam_targets[0].max_hp - mt.beam_targets[0].hp
	var hp3: float = mt.beam_targets[2].max_hp - mt.beam_targets[2].hp
	check(hp3 > 0.0 and hp3 < hp1, "an extra beam hits for less (%.1f vs %.1f)" % [hp3, hp1])
	# Ramp Memory: a new target inherits half the ramp of the one it replaces.
	var rmem = g.place_tower("laser_tower", spot(g, "laser_tower", 120))
	g.buy_retrofit(rmem, 2)
	g.enemies.clear()
	var a = put(g, "grunt", 100.0, 0, 500.0)
	rmem.pos = a.pos + Vector2(30, 0)
	for i in 40:
		g._update_laser_rework(rmem, rmem.stats(), 0.05)
	check(near(rmem.ramp, 2.0, 0.01), "two seconds on the target")
	a.alive = false
	var b = put(g, "grunt", 100.0, 0, 500.0)
	g._update_laser_rework(rmem, rmem.stats(), 0.05)
	check(rmem.target == b and near(rmem.ramp, 1.05, 0.02), "Ramp Memory: the new target starts at half (%.2f)" % rmem.ramp)
	var plain = g.place_tower("laser_tower", spot(g, "laser_tower", 140))
	plain.pos = b.pos + Vector2(30, 0)
	for i in 40:
		g._update_laser_rework(plain, plain.stats(), 0.05)
	b.alive = false
	var c2 = put(g, "grunt", 100.0, 0, 500.0)
	g._update_laser_rework(plain, plain.stats(), 0.05)
	check(near(plain.ramp, 0.05, 0.01), "without it the ramp starts over")
	# Range path.
	var rg = g.place_tower("laser_tower", spot(g, "laser_tower", 160))
	rg.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, rg, "c", 5)
	check(rg.mastered and near(rg.stats().range, 280.0), "Deep Lance: 280 range")


func test_rework_anti_aircraft() -> void:
	var g = new_game()
	g.gold = 60000
	g.emit_events = true
	var t = g.place_tower("anti_aircraft_turret", spot(g, "anti_aircraft_turret", 0))
	check(t != null and g.tower_cost("anti_aircraft_turret") == 150, "the Anti-Aircraft Turret builds for 150")
	var s: Dictionary = t.stats()
	check(near(s.damage, 25.0) and near(s.range, 160.0) and near(s.rate, 2.5), "stock: 25 damage, 160 range, 2.5 rounds/s")
	check(t.hits_air() and not t.hits_ground(), "air only")
	check(g.buy_retrofit(t, 0) and near(t.stats().range, 175.0), "Fire-Control Radar: +15 range")
	var dr = g.place_tower("anti_aircraft_turret", spot(g, "anti_aircraft_turret", 20))
	check(g.buy_retrofit(dr, 1) and near(dr.stats().rate, 2.75), "Ammo Drum: +0.25 rounds/s")
	var am = g.place_tower("anti_aircraft_turret", spot(g, "anti_aircraft_turret", 40))
	check(g.buy_retrofit(am, 2) and near(am.stats().damage, 29.0), "Armoured Mount: +4 damage")
	# It ignores ground enemies and shoots flyers.
	var shooter = g.place_tower("anti_aircraft_turret", spot(g, "anti_aircraft_turret", 60))
	var walker = put(g, "grunt", 100.0, 0, 50.0)
	shooter.pos = walker.pos + Vector2(30, 0)
	check(g.pick_target(shooter) == null, "a ground enemy is never a target")
	var flyer = put(g, "bat", 100.0, 0, 50.0)
	check(g.pick_target(shooter) == flyer, "a flyer is")
	# Stock rounds are direct hits: a second flyer next to the target is untouched.
	var other = put(g, "bat", 100.0, 0, 50.0)
	other.pos = flyer.pos + Vector2(10, 0)
	var hp_o: float = other.hp
	g._fire_projectile(shooter, flyer, shooter.stats())
	var rnd = g.projectiles[g.projectiles.size() - 1]
	rnd.pos = flyer.pos
	g._projectile_hit(rnd)
	check(flyer.hp < flyer.max_hp and near(other.hp, hp_o), "a stock round hits only its target")
	# Flak Rounds: the airburst hurts every flyer nearby, and only flyers.
	var fk = g.place_tower("anti_aircraft_turret", spot(g, "anti_aircraft_turret", 80))
	buy_steps(g, fk, "b", 2)
	check(near(fk.stats().burst, 20.0), "Flak Rounds: a 20 px airburst")
	fk.pos = flyer.pos + Vector2(30, 0)
	hp_o = other.hp
	var ground_hp: float = walker.hp
	walker.pos = flyer.pos + Vector2(3, 0)
	g._fire_projectile(fk, flyer, fk.stats())
	var fr = g.projectiles[g.projectiles.size() - 1]
	fr.pos = flyer.pos
	g._projectile_hit(fr)
	check(other.hp < hp_o, "the burst hit the flyer beside the target")
	check(near(walker.hp, ground_hp), "the burst doesn't touch ground enemies")
	var far_flyer = put(g, "bat", 100.0, 0, 50.0)
	far_flyer.pos = flyer.pos + Vector2(40, 0)
	var hp_far: float = far_flyer.hp
	g._projectile_hit(fr)
	check(near(far_flyer.hp, hp_far), "outside the burst radius is safe")
	# Paths.
	buy_steps(g, fk, "b", 1)
	check(near(fk.stats().damage, 36.0), "Flak Shells: 36 damage (%.0f)" % fk.stats().damage)
	check(near(fk.stats().burst, 30.0), "30 px airburst")
	var rg = g.place_tower("anti_aircraft_turret", spot(g, "anti_aircraft_turret", 100))
	rg.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, rg, "a", 5)
	check(rg.mastered and near(rg.stats().range, 330.0), "Sky Wall: 330 range")
	var sp = g.place_tower("anti_aircraft_turret", spot(g, "anti_aircraft_turret", 120))
	sp.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, sp, "c", 2)
	check(near(sp.stats().rate, 3.2) and bool(sp.stats().turn_fast), "Fast Traverse: 3.2 rounds/s, turns faster")
	buy_steps(g, sp, "c", 3)
	check(sp.mastered and near(sp.stats().rate, 7.0) and int(sp.stats().barrels) == 4, "Quad Mount: 7 rounds/s from 4 barrels")
	var pm = g.place_tower("anti_aircraft_turret", spot(g, "anti_aircraft_turret", 140))
	pm.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pm, "b", 5)
	check(pm.mastered and near(pm.stats().damage, 42.0) and near(pm.stats().burst, 50.0), "Flak Curtain: 42 damage, 50 px")


func test_rework_artillery_cannon() -> void:
	var g = new_game()
	g.gold = 90000
	g.emit_events = true
	var t = g.place_tower("artillery_cannon", spot(g, "artillery_cannon", 0))
	check(t != null and g.tower_cost("artillery_cannon") == 300, "the Artillery Cannon builds for 300")
	var s: Dictionary = t.stats()
	check(near(s.damage, 75.0) and near(s.splash, 70.0) and near(s.rate, 0.25) and near(s.flight, 1.5) and near(s.scatter, 30.0), "stock: 75 damage, 70 px, a shell every 4 s, 30 px scatter")
	check(t.hits_ground() and not t.hits_air(), "ground only")
	check(t.aim_set and t.aim_point.distance_to(g.nearest_track_point(t.pos)) < 0.01, "a new cannon aims at the track point nearest itself")
	var far: Vector2 = g.nearest_track_point(Vector2(1100, 600))
	g.aim_artillery(t, Vector2(1100, 600))
	check(t.aim_point.distance_to(far) < 0.01, "re-aiming snaps to the lane")
	# Retrofits.
	check(g.buy_retrofit(t, 0) and int(t.stats().heavy_every) == 3, "Shell Magazine: every third shell is heavy")
	var st = g.place_tower("artillery_cannon", spot(g, "artillery_cannon", 20))
	check(g.buy_retrofit(st, 1) and near(st.stats().scatter, 15.0), "Stabilised Mount: 15 px scatter")
	var wc = g.place_tower("artillery_cannon", spot(g, "artillery_cannon", 40))
	check(g.buy_retrofit(wc, 2) and near(wc.stats().splash, 85.0), "Wide Charge: +15 px")
	# It shells the spot on a loop, enemies or not; the third shell is heavy.
	g.enemies.clear()
	g.projectiles.clear()
	t.cooldown = 0.0
	g._fire_artillery(t, t.stats())
	check(g.projectiles.size() == 1, "a shell is fired at an empty spot")
	var p1 = g.projectiles[0]
	check(p1.target_pos.distance_to(t.aim_point) <= 30.0 and near(p1.total / p1.speed, 1.5), "it lands within the scatter after 1.5 s of flight")
	g._fire_artillery(t, t.stats())
	g._fire_artillery(t, t.stats())
	var heavy: Array = g.projectiles.filter(func(p): return p.crit)
	check(heavy.size() == 1 and near(heavy[0].damage, g.projectiles[0].damage * 1.5), "every third shell is heavy (+50%)")
	# Blast: ground only, armour pierced by the Power path.
	g.projectiles.clear()
	var pw = g.place_tower("artillery_cannon", spot(g, "artillery_cannon", 60))
	pw.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pw, "a", 5)
	check(pw.mastered and near(pw.stats().damage, 140.0) and near(pw.stats().splash, 90.0) and near(pw.stats().armor_pct, 0.75), "Siege Shells: 140 damage, 90 px, 75% armour")
	var brute = put(g, "brute", 100.0, 0, 50.0)
	var bat = put(g, "bat", 100.0, 0, 50.0)
	bat.pos = brute.pos
	pw.pos = brute.pos + Vector2(60, 0)
	g.aim_artillery(pw, brute.pos)
	var hp_bat: float = bat.hp
	var hp_b: float = brute.hp
	g._fire_artillery(pw, pw.stats())
	var sh = g.projectiles[g.projectiles.size() - 1]
	sh.pos = brute.pos
	g._projectile_hit(sh)
	check(brute.hp < hp_b and near(bat.hp, hp_bat), "the blast hurts ground enemies and never flyers")
	# Rolling Barrage: three shells walking across the spot, one after another.
	var rb = g.place_tower("artillery_cannon", spot(g, "artillery_cannon", 80))
	rb.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, rb, "b", 5)
	g.projectiles.clear()
	g._fire_artillery(rb, rb.stats())
	check(g.projectiles.size() == 3 and near(g.projectiles[1].hold, 0.2) and near(rb.stats().rate, 0.238), "Rolling Barrage: three shells, 0.2 s apart")
	# Shell types.
	var sp = g.place_tower("artillery_cannon", spot(g, "artillery_cannon", 100))
	check(sp.available_shells() == ["he"] and not g.set_shell(sp, "incendiary"), "only high explosive at first")
	buy_steps(g, sp, "c", 3)
	check(sp.available_shells() == ["he", "incendiary", "shrapnel", "concussion"], "three paths steps unlock three shells")
	check(g.set_shell(sp, "incendiary") and not g.set_shell(sp, "combined"), "a shell type can be loaded once unlocked")
	g.enemies.clear()
	g.pools.clear()
	var e = put(g, "grunt", 100.0, 0, 500.0)
	sp.pos = e.pos + Vector2(60, 0)
	g.aim_artillery(sp, e.pos)
	g._fire_artillery(sp, sp.stats())
	var inc = g.projectiles[g.projectiles.size() - 1]
	inc.pos = e.pos
	g._projectile_hit(inc)
	check(g.pools.size() == 1 and near(g.pools[0].dps, 15.0), "incendiary: burning ground, 15/s")
	g.set_shell(sp, "concussion")
	g._fire_artillery(sp, sp.stats())
	var con = g.projectiles[g.projectiles.size() - 1]
	con.pos = e.pos
	g._projectile_hit(con)
	check(e.stun_timer > 0.4, "concussion: stunned (%.2f s)" % e.stun_timer)
	g.set_shell(sp, "shrapnel")
	g._fire_artillery(sp, sp.stats())
	var shr = g.projectiles[g.projectiles.size() - 1]
	shr.pos = e.pos
	var evs: int = g.events.size()
	g._projectile_hit(shr)
	var rad := 0.0
	for i in range(evs, g.events.size()):
		if g.events[i].type == "splash":
			rad = float(g.events[i].radius)
	check(near(rad, sp.stats().splash + 40.0), "shrapnel: a 40 px wider blast (%.0f)" % rad)
	var cm = g.place_tower("artillery_cannon", spot(g, "artillery_cannon", 120))
	cm.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, cm, "c", 5)
	check(cm.mastered and cm.available_shells().has("combined"), "Combined Payload unlocks a fourth shell")
	check(near(cm.stats().burn_dps, 22.0) and near(cm.stats().shrap_mult, 0.85) and near(cm.stats().stun_time, 0.7), "Improved Payloads strengthen every type")
	# Saves keep the aim and the loaded shell.
	var g3 = research_game(["artillery_cannon_1", "artillery_cannon_2a"], "canyon", 99, "hard")
	g3.gold = 50000
	var sv = g3.place_tower("artillery_cannon", spot(g3, "artillery_cannon", 3))
	buy_steps(g3, sv, "c", 2)
	g3.aim_artillery(sv, Vector2(900, 500))
	g3.set_shell(sv, "shrapnel")
	var data := SaveCodec.encode(g3)
	var dec := SaveCodec.decode(JSON.parse_string(JSON.stringify(data)))
	check(dec.has("game"), "the save decodes (%s)" % dec.get("error", ""))
	if dec.has("game"):
		var sv2 = dec.game.tower_at[sv.cell]
		check(sv2.aim_point.distance_to(sv.aim_point) < 0.01 and sv2.shell == "shrapnel", "the aim point and shell type are saved")


func test_rework_railgun() -> void:
	var g = new_game()
	g.gold = 90000
	g.emit_events = true
	var t = g.place_tower("railgun", spot(g, "railgun", 0))
	check(t != null and g.tower_cost("railgun") == 500, "the Railgun builds for 500")
	var s: Dictionary = t.stats()
	check(near(s.damage, 90.0) and near(s.range, 380.0) and near(s.rate, 0.4) and near(s.falloff, 0.4), "stock: 90 damage, 380 range, a slug every 2.5 s, 40% falloff")
	check(t.hits_air() and t.hits_ground(), "air and ground")
	check(g.buy_retrofit(t, 0) and near(t.stats().rate, 0.4545), "Capacitor Coils: 2.2 s")
	var lr = g.place_tower("railgun", spot(g, "railgun", 20))
	check(g.buy_retrofit(lr, 1) and near(lr.stats().damage, 105.0) and near(lr.stats().range, 410.0), "Longer Rails: +15 damage, +30 range")
	var pt = g.place_tower("railgun", spot(g, "railgun", 40))
	check(g.buy_retrofit(pt, 2) and near(pt.stats().falloff, 0.3), "Penetrator Tips: 30% falloff")
	# The slug pierces the line, losing a share of its damage with each enemy.
	g.enemies.clear()
	var shooter = g.place_tower("railgun", spot(g, "railgun", 60))
	var e1 = put(g, "grunt", 100.0, 0, 50.0)
	var e2 = put(g, "grunt", 104.0, 0, 50.0)
	var e3 = put(g, "grunt", 108.0, 0, 50.0)
	for e in [e1, e2, e3]:
		e.armor = 0.0
		e.hp = 100000.0
		e.max_hp = 100000.0
	var ahead: Vector2 = (e2.pos - e1.pos).normalized()
	shooter.pos = e1.pos - ahead * 60.0
	var before := [e1.hp, e2.hp, e3.hp]
	g._fire_railgun(shooter, e1, shooter.stats())
	var d := [before[0] - e1.hp, before[1] - e2.hp, before[2] - e3.hp]
	d.sort()
	d.reverse()
	check(near(d[0], 90.0, 0.5) and near(d[1], 54.0, 0.5) and near(d[2], 32.4, 0.5), "90, 54, 32 down the line (%.1f %.1f %.1f)" % [d[0], d[1], d[2]])
	# Armour applies to the slug; Shatter strips it for good.
	var armored = put(g, "brute", 100.0, 0, 50.0)
	var sh = g.place_tower("railgun", spot(g, "railgun", 80))
	sh.pos = armored.pos + Vector2(40, 0)
	buy_steps(g, sh, "c", 1)
	var a0: float = armored.armor_now() if armored.has_method("armor_now") else armored.armor
	g.enemies.erase(e1)
	g.enemies.erase(e2)
	g.enemies.erase(e3)
	g._fire_railgun(sh, armored, sh.stats())
	check(near(armored.armor_shred, 2.0), "Shatter Rounds: each hit strips 2 armour for good")
	# Boss rounds.
	var bp = g.place_tower("railgun", spot(g, "railgun", 100))
	bp.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, bp, "a", 5)
	check(bp.mastered and near(bp.stats().damage, 280.0) and near(bp.stats().rate, 0.303) and near(bp.stats().boss_mult, 2.5), "Kingslayer: 280 damage, 3.3 s, x2.5 to bosses")
	g.enemies.clear()
	var boss = put(g, "colossus", 100.0, 0, 1.0)
	var grunt = put(g, "grunt", 100.0, 0, 50.0)
	bp.pos = boss.pos + Vector2(60, 0)
	var bh: float = boss.hp
	g._fire_railgun(bp, boss, bp.stats())
	check(bh - boss.hp > 280.0 * 1.5, "a boss takes the bonus (%.0f)" % (bh - boss.hp))
	# The ionised trail burns everything on the line, cloaked or not, then fades.
	g.enemies.clear()
	g.trails.clear()
	var it = g.place_tower("railgun", spot(g, "railgun", 120))
	it.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, it, "c", 3)
	check(near(it.stats().trail_dps, 30.0) and near(it.stats().trail_time, 2.0), "Ionised Trail: 30/s for 2 s")
	var tgt = put(g, "grunt", 100.0, 0, 5000.0)
	var side = put(g, "grunt", 103.0, 0, 5000.0)
	side.cloaked = true
	it.pos = tgt.pos - (side.pos - tgt.pos).normalized() * 60.0
	var sh0: float = side.hp
	g._fire_railgun(it, tgt, it.stats())
	check(g.trails.size() == 1, "the shot leaves a trail")
	var hp1: float = side.hp
	for i in 20:
		g._update_trails(0.05)
	check(side.hp < hp1 - 20.0 and side.reveal_timer > 0.0, "the trail burns an unseen enemy on the line and reveals it (%.1f)" % (hp1 - side.hp))
	for i in 60:
		g._update_trails(0.05)
	check(g.trails.is_empty(), "the trail fades after 2 s")
	# Twin Rails and the Ion Cannon mastery.
	var tw = g.place_tower("railgun", spot(g, "railgun", 140))
	tw.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, tw, "b", 5)
	check(tw.mastered and int(tw.stats().rails) == 2 and near(tw.stats().rate, 0.833), "Twin Rails: a slug every 1.2 s")
	var ic = g.place_tower("railgun", spot(g, "railgun", 160))
	ic.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, ic, "c", 5)
	check(ic.mastered and near(ic.stats().shatter, 6.0) and near(ic.stats().falloff, 0.0) and near(ic.stats().trail_dps, 50.0), "Ion Cannon: shatter 6, 50/s, no falloff")


func test_rework_tesla_tower() -> void:
	var g = new_game()
	g.gold = 90000
	g.emit_events = true
	var t = g.place_tower("tesla_tower", spot(g, "tesla_tower", 0))
	check(t != null and g.tower_cost("tesla_tower") == 250, "the Tesla Tower builds for 250")
	var s: Dictionary = t.stats()
	check(near(s.damage, 32.0) and near(s.range, 140.0) and near(s.rate, 0.8) and int(s.jumps) == 3 and near(s.falloff, 0.15), "stock: 32 damage, 140 range, 0.8 arcs/s, 3 jumps, 15% lost per jump")
	check(t.hits_air() and t.hits_ground() and t.def.damage_kind == "energy", "an energy tower that hits air and ground")
	check(g.buy_retrofit(t, 0) and near(t.stats().damage, 36.0) and near(t.stats().range, 155.0), "Bigger Disk: +4 damage, +15 range")
	var gr = g.place_tower("tesla_tower", spot(g, "tesla_tower", 20))
	check(g.buy_retrofit(gr, 1) and int(gr.stats().jumps) == 4, "Grounding Rods: +1 jump")
	var ic = g.place_tower("tesla_tower", spot(g, "tesla_tower", 40))
	check(g.buy_retrofit(ic, 2) and near(ic.stats().rate, 0.909), "Insulated Coils: an arc every 1.1 s")
	# The chain: four enemies in a row, each hit for less; armour doesn't count.
	g.enemies.clear()
	var es: Array = []
	for i in 5:
		var e = put(g, "brute", 100.0 + float(i) * 2.0, 0, 500.0)
		es.append(e)
	var shooter = g.place_tower("tesla_tower", spot(g, "tesla_tower", 60))
	shooter.pos = es[0].pos + Vector2(40, 0)
	for e in es:
		e.pos = es[0].pos + Vector2(0, 30.0 * float(es.find(e)))
	var before: Array = es.map(func(e): return e.hp)
	g._chain_rework(shooter, es[0], shooter.stats())
	var lost: Array = []
	for i in 5:
		lost.append(before[i] - es[i].hp)
	check(near(lost[0], 32.0, 0.1) and near(lost[1], 27.2, 0.1) and near(lost[2], 23.12, 0.1) and near(lost[3], 19.65, 0.1) and near(lost[4], 0.0), "four enemies hit, each 15%% weaker (%s)" % str(lost.map(func(v): return snappedf(v, 0.1))))
	# A lone arc with nothing in reach just hits once.
	g.enemies.clear()
	var lone = put(g, "grunt", 100.0, 0, 50.0)
	var hp0: float = lone.hp
	shooter.pos = lone.pos + Vector2(40, 0)
	g._chain_rework(shooter, lone, shooter.stats())
	check(near(hp0 - lone.hp, 32.0, 0.1), "an isolated enemy takes one hit")
	# Power path: stun, overload, less falloff.
	var pw = g.place_tower("tesla_tower", spot(g, "tesla_tower", 80))
	pw.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pw, "a", 3)
	check(near(pw.stats().damage, 48.0) and near(pw.stats().stun_time, 0.3) and pw.stats().overload, "Arc Stun: 48 damage, 0.3 s stun, with Overload")
	g.enemies.clear()
	var st = put(g, "grunt", 100.0, 0, 500.0)
	pw.pos = st.pos + Vector2(40, 0)
	g._chain_rework(pw, st, pw.stats())
	check(st.stun_timer > 0.25, "an arc stuns what it hits (%.2f s)" % st.stun_timer)
	var jam = put(g, "jammer", 100.0, 0, 500.0)
	jam.pos = st.pos + Vector2(0, 200)
	var plain = put(g, "jammer", 100.0, 0, 500.0)
	plain.pos = jam.pos + Vector2(400, 0)
	var jhp: float = jam.hp
	g._chain_rework(pw, jam, pw.stats())
	var ohp: float = plain.hp
	var other = g.place_tower("tesla_tower", spot(g, "tesla_tower", 100))
	g._chain_rework(other, plain, other.stats())
	check(near(jhp - jam.hp, 96.0, 0.5) and near(ohp - plain.hp, 32.0, 0.5), "Overload: double damage to a Disruptor (%.0f vs %.0f)" % [jhp - jam.hp, ohp - plain.hp])
	buy_steps(g, pw, "a", 1)
	check(pw.mastered == false and near(pw.stats().falloff, 0.08), "Clean Conduction: 8% lost per jump")
	buy_steps(g, pw, "a", 1)
	check(pw.mastered and near(pw.stats().damage, 60.0) and near(pw.stats().falloff, 0.03) and near(pw.stats().stun_time, 0.5), "Lightning Rod: 60 damage, 3% lost, 0.5 s stun")
	# Chaining path: jumps and storms; the storm hurts a cloaked enemy standing in it.
	var ch = g.place_tower("tesla_tower", spot(g, "tesla_tower", 120))
	ch.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, ch, "b", 3)
	check(int(ch.stats().jumps) == 5 and near(ch.stats().storm_radius, 25.0) and near(ch.stats().storm_dps, 10.0), "Storm Field: 5 jumps, a 25 px storm of 10/s")
	buy_steps(g, ch, "b", 2)
	check(ch.mastered and int(ch.stats().jumps) == 7 and near(ch.stats().storm_dps, 14.0) and near(ch.stats().storm_radius, 30.0) and near(ch.stats().range, 180.0), "Tempest: 7 jumps, storms of 14/s and 30 px")
	g.enemies.clear()
	g.storms.clear()
	var foe = put(g, "grunt", 100.0, 0, 5000.0)
	var ghost = put(g, "grunt", 100.0, 0, 5000.0)
	ghost.pos = foe.pos + Vector2(10, 0)
	ghost.cloaked = true
	ch.pos = foe.pos + Vector2(40, 0)
	g._chain_rework(ch, foe, ch.stats())
	check(g.storms.size() == 1, "an arc leaves a storm where it starts")
	var gh: float = ghost.hp
	for i in 20:
		g._update_storms(0.05)
	check(ghost.hp < gh, "the storm burns a cloaked enemy inside it (%.1f)" % (gh - ghost.hp))
	# Speed path.
	var sp = g.place_tower("tesla_tower", spot(g, "tesla_tower", 140))
	sp.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, sp, "c", 5)
	check(sp.mastered and near(sp.stats().rate, 2.1), "Continuous Discharge: 2.1 arcs/s")


func test_rework_drone_bay() -> void:
	var g = new_game()
	g.gold = 90000
	g.emit_events = true
	var t = g.place_tower("drone_bay", spot(g, "drone_bay", 0))
	check(t != null and g.tower_cost("drone_bay") == 300, "the Drone Bay builds for 300")
	var s: Dictionary = t.stats()
	check(near(s.damage, 16.0) and near(s.rate, 3.0) and int(s.drones) == 1, "stock: one drone, 16 damage, 3 shots/s")
	check(t.hits_air() and t.hits_ground() and not t.stats().has("range"), "air and ground, anywhere on the map")
	check(t.retrofit_options().size() == 1 and t.retrofit_cost(0) == 3200, "its one Retrofit is the Second Hangar at 3,200")
	check(g.buy_retrofit(t, 0) and int(t.stats().drones) == 2, "the Second Hangar launches a second drone")
	# One drone hunts a far enemy and shoots from close range.
	var one = g.place_tower("drone_bay", spot(g, "drone_bay", 20))
	var far = put(g, "grunt", 300.0, 0, 50.0)
	var hp: float = far.hp
	for i in 400:
		g._update_drone_bay(one, one.stats(), 0.05)
		g.time += 0.05
	check(one.wing.size() == 1 and far.hp < hp, "the drone flew to a far-off enemy and shot it")
	# Two drones pick different targets.
	g.enemies.clear()
	var e1 = put(g, "grunt", 100.0, 0, 500.0)
	var e2 = put(g, "grunt", 160.0, 0, 500.0)
	var two = g.place_tower("drone_bay", spot(g, "drone_bay", 40))
	g.buy_retrofit(two, 0)
	g._update_drone_bay(two, two.stats(), 0.05)
	check(two.wing.size() == 2 and two.wing[0].target != two.wing[1].target, "two drones take different targets")
	# Loadouts.
	var lo = g.place_tower("drone_bay", spot(g, "drone_bay", 60))
	check(lo.available_loadouts() == ["gun"] and not g.set_loadout(lo, "missiles"), "only the gun at first")
	buy_steps(g, lo, "b", 3)
	check(lo.available_loadouts() == ["gun", "missiles", "bombs", "laser"], "three steps unlock missiles, bombs and the laser")
	g.enemies.clear()
	var tgt = put(g, "grunt", 100.0, 0, 500.0)
	var near_t = put(g, "grunt", 100.0, 0, 500.0)
	near_t.pos = tgt.pos + Vector2(20, 0)
	var weapons := g._loadout_weapons(lo, lo.stats())
	check(weapons.size() == 1 and weapons[0].name == "gun", "gun loadout by default")
	g.set_loadout(lo, "missiles")
	var h1: float = near_t.hp
	var d0 = {"pos": tgt.pos, "cds": {}}
	g._drone_hit(lo, d0, tgt, g._loadout_weapons(lo, lo.stats())[0], 40.0)
	check(near_t.hp < h1, "missiles blast the enemy beside the target")
	g.set_loadout(lo, "bombs")
	var air = put(g, "bat", 100.0, 0, 50.0)
	air.pos = tgt.pos
	var ah: float = air.hp
	g._drone_hit(lo, d0, tgt, g._loadout_weapons(lo, lo.stats())[0], 40.0)
	check(near(air.hp, ah), "bombs never hit flyers")
	var brute = put(g, "brute", 100.0, 0, 50.0)
	g.set_loadout(lo, "laser")
	var bh: float = brute.hp
	var lw: Dictionary = g._loadout_weapons(lo, lo.stats())[0]
	g._drone_hit(lo, d0, brute, lw, 20.0)
	check(near(bh - brute.hp, 20.0), "the laser ignores armour (%.1f)" % (bh - brute.hp))
	check(brute.last_hit_kind in ["physical", "energy"], "hit kind recorded")
	buy_steps(g, lo, "b", 1)
	check(near(lo.stats().loadout_mult, 1.25) and near(float(g._loadout_weapons(lo, lo.stats())[0].dmg), 0.9 * 1.25), "Upgraded Loadouts: 25% stronger")
	var fk = g.place_tower("drone_bay", spot(g, "drone_bay", 80))
	fk.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, fk, "b", 5)
	g.set_loadout(fk, "full")
	check(fk.mastered and g._loadout_weapons(fk, fk.stats()).size() == 3, "Full Kit: guns, missiles and laser together")
	# Power and Speed.
	var pw = g.place_tower("drone_bay", spot(g, "drone_bay", 100))
	pw.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pw, "a", 5)
	check(pw.mastered and near(pw.stats().damage, 42.0), "Elite Drones: 42 damage")
	var sp = g.place_tower("drone_bay", spot(g, "drone_bay", 120))
	sp.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, sp, "c", 5)
	check(sp.mastered and near(sp.stats().rate, 7.0), "Storm Drones: 7 shots/s")
	# An EMP over a drone switches the bay off.
	g.enemies.clear()
	var jam = put(g, "jammer", 100.0, 0, 50.0)
	var dd = g.place_tower("drone_bay", spot(g, "drone_bay", 140))
	dd.wing.append({"kind": "gun", "pos": jam.pos + Vector2(10, 0), "target": null, "cds": {}})
	check(dd.disabled == 0.0, "online before the EMP")
	g._update_enemy(jam, 0.0)
	jam.ability_timer = 0.0
	g._update_enemy(jam, 0.05)
	check(dd.disabled > 0.0, "an EMP over a drone knocks the bay offline")


func test_rework_cas_gunship() -> void:
	var g = new_game()
	g.gold = 400000
	g.emit_events = true
	var t = g.place_tower("cas_gunship", spot(g, "cas_gunship", 0))
	check(t != null and t.is_uncapped() and g.tower_cost("cas_gunship") == 650, "the CAS Gunship builds for 650 and is uncapped")
	var s: Dictionary = t.stats()
	check(near(s.damage, 12.0) and near(s.rate, 5.0) and near(s.orbit, 90.0) and not s.has("ac_damage") and not s.has("ms_damage"), "stock: a gatling of 12 at 5/s, a 90 px orbit")
	check(t.aim_set and t.hits_air() and t.hits_ground() and not s.has("range"), "orbits the track point nearest it; air and ground; no range")
	# Retrofits.
	check(g.buy_retrofit(t, 0) and t.stats().radar, "Radar")
	var ea = g.place_tower("cas_gunship", spot(g, "cas_gunship", 20))
	check(g.buy_retrofit(ea, 1) and near(ea.stats().rate_mult, 1.1), "Extra Ammo: +10% fire rate")
	var wo = g.place_tower("cas_gunship", spot(g, "cas_gunship", 40))
	check(g.buy_retrofit(wo, 2) and near(wo.stats().orbit, 115.0), "Wide Orbit: 115 px")
	# Uncapped: every path takes every step, all three at once, no secondary cap, no lock.
	var u = g.place_tower("cas_gunship", spot(g, "cas_gunship", 60))
	buy_steps(g, u, "a", 4)
	buy_steps(g, u, "b", 4)
	buy_steps(g, u, "c", 4)
	check(u.depth.a == 4 and u.depth.b == 4 and u.depth.c == 4 and u.block_reason("a") == "Needs CAS Gunship Mastery research" or u.block_reason("a").contains("Mastery"), "all three paths reach step 4 (%s)" % u.block_reason("a"))
	var us: Dictionary = u.stats()
	check(near(us.damage, 19.0) and near(us.rate, 7.5), "gatling: 19 damage, 7.5/s")
	check(near(us.ac_damage, 52.0) and near(us.ac_rate, 2.2) and near(us.ac_splash, 25.0), "autocannon: 52 damage, 2.2/s, 25 px")
	check(near(us.ms_damage, 190.0) and near(us.ms_rate, 0.5) and near(us.ms_splash, 45.0), "missiles: 190, one every 2 s, 45 px")
	check(u.upgrade_cost("b") == 0 or u.block_reason("b") != "", "the mastery is gated by research")
	# Each path takes its own mastery.
	u.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, u, "a", 1)
	buy_steps(g, u, "b", 1)
	buy_steps(g, u, "c", 1)
	check(u.mastered_paths == ["a", "b", "c"], "all three masteries are bought")
	us = u.stats()
	check(near(us.rate, 9.0) and near(us.ac_damage, 58.0) and near(us.ac_splash, 30.0) and int(us.ms_volley) == 2, "Twin Gatlings 9/s, Autocannon Battery 58 and 30 px, Hellfire Volley")
	check(u.look_key() == "-1|5|5|5", "the look shows three masteries (%s)" % u.look_key())
	check(u.block_reason("a") == "Fully upgraded", "a mastered path is done")
	# Orbit and guns.
	g.enemies.clear()
	var e1 = put(g, "grunt", 100.0, 0, 500.0)
	var far = put(g, "grunt", 300.0, 0, 500.0)
	var gun = g.place_tower("cas_gunship", spot(g, "cas_gunship", 80))
	g.designate_orbit(gun, e1.pos)
	check(gun.aim_point.distance_to(e1.pos) < 0.01, "designating puts the orbit anywhere")
	var hp: float = e1.hp
	var fhp: float = far.hp
	for i in 20:
		g._update_cas(gun, gun.stats(), 0.05)
	check(e1.hp < hp and near(far.hp, fhp), "the gatling hits enemies inside the orbit only")
	check(absf(gun.orbit_angle - 0.5) < 0.01, "the plane circles at 0.5 rad/s")
	# Guns spread over targets; missiles fly as projectiles.
	var multi = g.place_tower("cas_gunship", spot(g, "cas_gunship", 100))
	buy_steps(g, multi, "b", 1)
	buy_steps(g, multi, "c", 1)
	g.enemies.clear()
	var a1 = put(g, "grunt", 100.0, 0, 5000.0)
	var a2 = put(g, "grunt", 104.0, 0, 5000.0)
	var a3 = put(g, "grunt", 108.0, 0, 5000.0)
	g.designate_orbit(multi, a1.pos)
	g.projectiles.clear()
	g._update_cas(multi, multi.stats(), 0.05)
	var missiles: Array = g.projectiles.filter(func(p): return p.kind == "missile")
	check(missiles.size() == 1 and missiles[0].damage == 150.0 and missiles[0].splash == 45.0, "a missile of 150 with a 45 px blast leaves the plane")
	var shots: Array = g.events.filter(func(e): return e.type == "cas_shot")
	check(shots.size() >= 3, "gatling, autocannon and missile all fired (%d)" % shots.size())
	# Hellfire Volley: every third volley fires two.
	var hv = g.place_tower("cas_gunship", spot(g, "cas_gunship", 120))
	hv.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, hv, "c", 5)
	g.designate_orbit(hv, a1.pos)
	g.projectiles.clear()
	var per_volley: Array = []
	for v in 3:
		hv.gun_cds.clear()
		var before: int = g.projectiles.size()
		g._update_cas(hv, hv.stats(), 0.05)
		per_volley.append(g.projectiles.size() - before)
	check(per_volley == [1, 1, 2], "every third volley fires two missiles (%s)" % str(per_volley))
	# Radar reveals cloaked enemies inside the orbit to every tower.
	g.enemies.clear()
	var ghost = put(g, "grunt", 100.0, 0, 500.0)
	ghost.cloaked = true
	var rd = g.place_tower("cas_gunship", spot(g, "cas_gunship", 140))
	g.buy_retrofit(rd, 0)
	g.designate_orbit(rd, ghost.pos)
	check(ghost.is_hidden(), "cloaked before the radar")
	g._update_cas(rd, rd.stats(), 0.05)
	check(not ghost.is_hidden(), "the radar reveals it")
	# Priority: air first when asked.
	g.enemies.clear()
	var walker = put(g, "grunt", 100.0, 0, 500.0)
	var flyer = put(g, "bat", 100.0, 0, 500.0)
	flyer.pos = walker.pos
	var pr = g.place_tower("cas_gunship", spot(g, "cas_gunship", 160))
	g.designate_orbit(pr, walker.pos)
	pr.priority = 1
	check(g._cas_targets(pr, 90.0, walker.pos)[0] == flyer, "Air priority: flyers first")
	pr.priority = 2
	check(g._cas_targets(pr, 90.0, walker.pos)[0] == walker, "Ground priority: walkers first")
	# An EMP over the orbit silences it.
	g.enemies.clear()
	var jam = put(g, "jammer", 100.0, 0, 50.0)
	var sil = g.place_tower("cas_gunship", spot(g, "cas_gunship", 180))
	g.designate_orbit(sil, jam.pos + Vector2(20, 0))
	jam.ability_timer = 0.0
	g._update_enemy(jam, 0.05)
	check(sil.disabled > 0.0, "an EMP over the orbit switches the guns off")
	# Saves keep the orbit point, uncapped upgrades and masteries.
	var g3 = research_game(["cas_gunship_1", "cas_gunship_2a", "cas_gunship_2b", "cas_gunship_m"], "canyon", 99, "hard")
	g3.gold = 400000
	var sv = g3.place_tower("cas_gunship", spot(g3, "cas_gunship", 3))
	buy_steps(g3, sv, "a", 5)
	buy_steps(g3, sv, "b", 3)
	buy_steps(g3, sv, "c", 1)
	g3.designate_orbit(sv, Vector2(700, 400))
	var data := SaveCodec.encode(g3)
	var dec := SaveCodec.decode(JSON.parse_string(JSON.stringify(data)))
	check(dec.has("game"), "the save decodes (%s)" % dec.get("error", ""))
	if dec.has("game"):
		var sv2 = dec.game.tower_at[sv.cell]
		check(sv2.depth.a == 4 and sv2.depth.b == 3 and sv2.depth.c == 1 and sv2.mastered_paths == ["a"] and sv2.aim_point.distance_to(Vector2(700, 400)) < 0.01, "depths, the mastery and the orbit point are restored (%s %s %s)" % [str(sv2.depth), str(sv2.mastered_paths), str(sv2.aim_point)])
		check(near(sv2.stats().rate, sv.stats().rate) and near(sv2.stats().ac_damage, sv.stats().ac_damage), "its stats are restored")


func test_rework_mine_layer() -> void:
	var g = new_game()
	g.gold = 90000
	g.emit_events = true
	var t = g.place_tower("mine_layer", spot(g, "mine_layer", 0))
	check(t != null and g.tower_cost("mine_layer") == 450, "the Mine Layer builds for 450")
	var s: Dictionary = t.stats()
	check(near(s.damage, 85.0) and near(s.splash, 40.0) and near(s.range, 120.0) and int(s.cap) == 20, "stock: 85 damage, 40 px, 120 toss range, cap 20")
	check(t.hits_ground() and not t.hits_air(), "ground only")
	check(g.buy_retrofit(t, 0) and near(t.stats().gel_slow, 0.2), "Adhesive Mines: a 20% gel")
	var sc = g.place_tower("mine_layer", spot(g, "mine_layer", 20))
	check(g.buy_retrofit(sc, 1) and near(sc.stats().damage, 100.0), "Shaped Charges: +15 damage")
	var la = g.place_tower("mine_layer", spot(g, "mine_layer", 40))
	check(g.buy_retrofit(la, 2) and near(la.stats().range, 140.0), "Long Arm: +20 range")
	# It lays mines on the track within reach, one at a time, never within 18 px of another.
	var cell := Vector2i(-1, -1)
	var best := INF
	for y in 14:
		for x in 24:
			var c := Vector2i(x, y)
			if g.placement_error("mine_layer", c) == "":
				var d: float = g.nearest_track_point(Game.footprint_center("mine_layer", c)).distance_to(Game.footprint_center("mine_layer", c))
				if d < best:
					best = d
					cell = c
	var m = g.place_tower("mine_layer", cell)
	check(m != null, "a Mine Layer beside the lane")
	g.mines.clear()
	m.cooldown = 0.0
	g._update_mine_layer(m, m.stats(), 0.0)
	check(g.mines.size() == 1 and g.mines[0].pos.distance_to(m.pos) <= 120.0 + 1.0, "it tosses a mine onto the track within reach")
	for i in 40:
		m.cooldown = 0.0
		g._update_mine_layer(m, m.stats(), 0.0)
	var ok := true
	for i in g.mines.size():
		for j in range(i + 1, g.mines.size()):
			if g.mines[i].pos.distance_to(g.mines[j].pos) < 17.9:
				ok = false
	check(ok and g.mines.size() > 3 and g.mines.size() <= 20, "mines keep their distance and respect the cap (%d)" % g.mines.size())
	# A mine goes off under a ground enemy (and a burrowed one), not under a flyer.
	g.mines.clear()
	g.enemies.clear()
	var foe = put(g, "brute", 100.0, 0, 50.0)
	var fly = put(g, "bat", 100.0, 0, 50.0)
	fly.pos = foe.pos
	g.mines.append({"pos": foe.pos, "source": m})
	var fhp: float = fly.hp
	var hp: float = foe.hp
	g._update_mines(0.05)
	check(g.mines.is_empty() and foe.hp < hp and fly.hp < fhp + 0.01 and near(fly.hp, fhp), "the mine blasts the walker and not the flyer")
	var bur = put(g, "burrower", 100.0, 0, 50.0)
	bur.burrowed = true
	g.mines.append({"pos": bur.pos, "source": m})
	var bh: float = bur.hp
	g._update_mines(0.05)
	check(bur.hp < bh, "a burrowed enemy sets a mine off and takes the blast")
	g.enemies.clear()
	var sky = put(g, "bat", 100.0, 0, 50.0)
	g.mines.append({"pos": sky.pos, "source": m})
	g._update_mines(0.05)
	check(g.mines.size() == 1, "a flyer alone doesn't trigger it")
	# Gel puddle, round end, early start.
	g.mines.clear()
	g.smokes.clear()
	var gm = g.place_tower("mine_layer", spot(g, "mine_layer", 60))
	g.buy_retrofit(gm, 0)
	var gfoe = put(g, "grunt", 100.0, 0, 50.0)
	g.mines.append({"pos": gfoe.pos, "source": gm})
	g._update_mines(0.05)
	check(g.smokes.size() == 1 and near(g.smokes[0].slow, 0.2), "Adhesive Mines leave a gel that slows")
	g.mines.append({"pos": Vector2(500, 500), "source": m})
	g._on_field_clear()
	check(g.mines.is_empty(), "mines clear when the round ends")
	# Paths.
	var pw = g.place_tower("mine_layer", spot(g, "mine_layer", 80))
	pw.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pw, "a", 5)
	check(pw.mastered and near(pw.stats().damage, 150.0) and near(pw.stats().splash, 65.0), "Anti-Tank Mines: 150 damage, 65 px")
	var pr = g.place_tower("mine_layer", spot(g, "mine_layer", 100))
	pr.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pr, "b", 5)
	check(pr.mastered and int(pr.stats().cap) == 45 and near(pr.stats().rate, 1.4286), "Mine Factory: a mine every 0.7 s, cap 45")
	var rg = g.place_tower("mine_layer", spot(g, "mine_layer", 120))
	rg.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, rg, "c", 5)
	check(rg.mastered and near(rg.stats().range, 260.0), "Minefield Launcher: 260 px")


func test_rework_chemical_plant() -> void:
	var g = new_game()
	g.gold = 90000
	g.emit_events = true
	var t = g.place_tower("chemical_plant", spot(g, "chemical_plant", 0))
	check(t != null and g.tower_cost("chemical_plant") == 250, "the Chemical Plant builds for 250")
	var s: Dictionary = t.stats()
	check(near(s.range, 130.0) and near(s.rate, 0.667) and near(s.soak_time, 4.0) and near(s.armor_strip, 3.0), "stock: 130 range, a spray every 1.5 s, a 4 s soak, 3 armour stripped")
	check(t.hits_air() and t.hits_ground(), "air and ground")
	check(g.buy_retrofit(t, 0) and near(t.stats().rate, 0.75) and near(t.stats().range, 150.0), "Pressure Pump: 1.33 s, +20 range")
	var mn = g.place_tower("chemical_plant", spot(g, "chemical_plant", 20))
	check(g.buy_retrofit(mn, 1) and mn.stats().mist, "Mist Nozzle")
	var bt = g.place_tower("chemical_plant", spot(g, "chemical_plant", 40))
	check(g.buy_retrofit(bt, 2) and near(bt.stats().soak_time, 5.0), "Bigger Tanks: a 5 s soak")
	# Spray: one enemy at a time, soaked enemies ignored, armour stripped for the soak.
	g.enemies.clear()
	var sp = g.place_tower("chemical_plant", spot(g, "chemical_plant", 60))
	var a = put(g, "brute", 100.0, 0, 500.0)
	var b = put(g, "brute", 110.0, 0, 500.0)
	sp.pos = a.pos + Vector2(40, 0)
	var armor0: float = a.effective_armor()
	sp.cooldown = 0.0
	g._spray(sp, sp.stats())
	var soaked: Array = [a, b].filter(func(e): return e.soak_timer > 0.0)
	check(soaked.size() == 1, "one enemy at a time (%d)" % soaked.size())
	check(near(soaked[0].effective_armor(), maxf(0.0, armor0 - 3.0)), "the soak strips 3 armour (%.1f -> %.1f)" % [armor0, soaked[0].effective_armor()])
	sp.cooldown = 0.0
	g._spray(sp, sp.stats())
	check([a, b].all(func(e): return e.soak_timer > 0.0), "the next spray goes to the other, unsoaked enemy")
	sp.cooldown = 0.0
	g._spray(sp, sp.stats())
	check(sp.target == null, "everyone soaked: nothing to spray")
	for i in 100:
		a.step(0.05)
	check(a.soak_timer <= 0.0 and near(a.effective_armor(), armor0), "when the soak ends the armour comes back")
	# Acid: permanent strip, damage over time. Gel: slow.
	var ac = g.place_tower("chemical_plant", spot(g, "chemical_plant", 80))
	ac.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, ac, "a", 1)
	g.enemies.clear()
	var d = put(g, "brute", 100.0, 0, 500.0)
	ac.pos = d.pos + Vector2(40, 0)
	ac.cooldown = 0.0
	var dar: float = d.effective_armor()
	g._spray(ac, ac.stats())
	for i in 100:
		d.step(0.05)
	check(near(d.armor_shred, 3.0) and near(d.effective_armor(), maxf(0.0, dar - 3.0)), "Corrosive Acid: the stripped armour stays gone (%.1f %.1f %.1f)" % [d.armor_shred, d.effective_armor(), dar])
	buy_steps(g, ac, "a", 4)
	check(ac.mastered and near(ac.stats().armor_strip, 7.0) and near(ac.stats().acid_dps, 20.0), "Dissolver: 7 armour, 20/s")
	var e2 = put(g, "grunt", 100.0, 0, 5000.0)
	e2.soak_timer = 3.0
	e2.soak_dps = 20.0
	e2.soak_source = ac
	var h2: float = e2.hp
	for i in 20:
		g._update_soaks(0.05)
	check(h2 - e2.hp > 15.0, "acid burns a soaked enemy (%.1f)" % (h2 - e2.hp))
	var gl = g.place_tower("chemical_plant", spot(g, "chemical_plant", 100))
	gl.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, gl, "c", 5)
	check(gl.mastered and near(gl.stats().gel_slow, 0.55), "Quick-Set Foam: 55% slow")
	var slowed = put(g, "grunt", 100.0, 0, 500.0)
	slowed.soak_timer = 3.0
	slowed.soak_slow = 0.55
	g._update_soaks(0.05)
	check(slowed.slow_amount > 0.4, "a soaked enemy is slowed (%.2f)" % slowed.slow_amount)
	# Speed path: twin nozzles soak two at once and the soak is longer.
	var tw = g.place_tower("chemical_plant", spot(g, "chemical_plant", 120))
	tw.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, tw, "b", 5)
	check(tw.mastered and int(tw.stats().nozzles) == 2 and near(tw.stats().soak_time, 7.0) and near(tw.stats().rate, 0.8), "Twin Nozzles: two at once, a 7 s soak")
	g.enemies.clear()
	var x1 = put(g, "grunt", 100.0, 0, 500.0)
	var x2 = put(g, "grunt", 130.0, 0, 500.0)
	var x3 = put(g, "grunt", 160.0, 0, 500.0)
	tw.pos = x2.pos + Vector2(40, 0)
	tw.cooldown = 0.0
	g._spray(tw, tw.stats())
	check([x1, x2, x3].filter(func(e): return e.soak_timer > 0.0).size() == 2, "two enemies soaked by one spray")
	# Mist soaks a neighbour too.
	g.enemies.clear()
	var m1 = put(g, "grunt", 100.0, 0, 500.0)
	var m2 = put(g, "grunt", 100.0, 0, 500.0)
	m2.pos = m1.pos + Vector2(20, 0)
	mn.pos = m1.pos + Vector2(40, 0)
	mn.cooldown = 0.0
	g._spray(mn, mn.stats())
	check(m1.soak_timer > 0.0 and m2.soak_timer > 0.0, "Mist Nozzle soaks the one next to it")


func test_rework_cryo_tower() -> void:
	var g = new_game()
	g.gold = 90000
	g.emit_events = true
	var t = g.place_tower("cryo_tower", spot(g, "cryo_tower", 0))
	check(t != null and g.tower_cost("cryo_tower") == 150, "the Cryo Tower builds for 150")
	var s: Dictionary = t.stats()
	check(near(s.range, 110.0) and near(s.rate, 0.5) and near(s.slow, 0.2) and near(s.slow_time, 1.5) and not s.has("damage"), "stock: a 110 px wave every 2 s, 20% slow for 1.5 s, no damage")
	check(g.buy_retrofit(t, 0) and near(t.stats().slow_time, 2.2), "Coolant Tank: 2.2 s")
	var cp = g.place_tower("cryo_tower", spot(g, "cryo_tower", 20))
	check(g.buy_retrofit(cp, 1) and near(cp.stats().rate, 0.588), "Compressor: a wave every 1.7 s")
	var dc = g.place_tower("cryo_tower", spot(g, "cryo_tower", 40))
	check(g.buy_retrofit(dc, 2) and near(dc.stats().slow, 0.25), "Deep Cold: 25%")
	# A wave slows ground and air, bosses half.
	g.enemies.clear()
	var w = g.place_tower("cryo_tower", spot(g, "cryo_tower", 60))
	var e1 = put(g, "grunt", 100.0, 0, 500.0)
	var e2 = put(g, "bat", 100.0, 0, 500.0)
	e2.pos = e1.pos + Vector2(10, 0)
	var far = put(g, "grunt", 300.0, 0, 500.0)
	w.pos = e1.pos + Vector2(30, 0)
	w.cooldown = 0.0
	g._cryo_wave(w, w.stats())
	check(near(e1.slow_amount, 0.2) and near(e2.slow_amount, 0.2) and far.slow_amount == 0.0, "air and ground in the radius are slowed 20%; the far one isn't")
	var boss = put(g, "colossus", 100.0, 0, 1.0)
	boss.pos = e1.pos
	w.cooldown = 0.0
	g._cryo_wave(w, w.stats())
	check(boss.slow_amount < 0.11 and boss.slow_amount > 0.0, "a boss is slowed less (%.2f)" % boss.slow_amount)
	# Slowing path: permanent chill, freeze every 4th wave.
	var sl = g.place_tower("cryo_tower", spot(g, "cryo_tower", 80))
	sl.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, sl, "a", 3)
	check(near(sl.stats().perm_slow, 0.1), "Permafrost: a permanent 10% chill")
	g.enemies.clear()
	var ch = put(g, "grunt", 100.0, 0, 5000.0)
	sl.pos = ch.pos + Vector2(30, 0)
	sl.cooldown = 0.0
	g._cryo_wave(sl, sl.stats())
	check(near(ch.perm_slow, 0.1), "a chilled enemy keeps a permanent slow")
	ch.pos += Vector2(300, 0)
	ch.slow_timer = 0.0
	ch.slow_amount = 0.0
	g._update_soaks(0.05)
	check(ch.slow_amount >= 0.09, "even outside its range (%.2f)" % ch.slow_amount)
	buy_steps(g, sl, "a", 2)
	check(sl.mastered and near(sl.stats().slow, 0.5) and near(sl.stats().perm_slow, 0.2) and int(sl.stats().freeze_every) == 4, "Deep Freeze: 50%, permanent 20%, a freeze every 4th wave")
	sl.pos = ch.pos + Vector2(30, 0)
	sl.pulse_count = 0
	var froze := 0
	for i in 8:
		ch.stun_timer = 0.0
		ch.stun_guard = 0.0
		sl.cooldown = 0.0
		g._cryo_wave(sl, sl.stats())
		if ch.stun_timer > 0.9:
			froze += 1
	check(froze == 2, "every 4th wave freezes it solid (%d of 8)" % froze)
	# Power/Range path: frostbite damage and radius.
	var pw = g.place_tower("cryo_tower", spot(g, "cryo_tower", 100))
	pw.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pw, "b", 5)
	check(pw.mastered and near(pw.stats().damage, 36.0) and near(pw.stats().range, 165.0), "Blizzard: 36 damage, 165 px")
	var fb = put(g, "brute", 100.0, 0, 500.0)
	pw.pos = fb.pos + Vector2(30, 0)
	var fh: float = fb.hp
	pw.cooldown = 0.0
	g._cryo_wave(pw, pw.stats())
	check(near(fh - fb.hp, 36.0, 0.1), "frostbite ignores armour (%.1f)" % (fh - fb.hp))
	# Speed path: Cold Front keeps the slow on, always.
	var cf = g.place_tower("cryo_tower", spot(g, "cryo_tower", 120))
	cf.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, cf, "c", 5)
	check(cf.mastered and cf.stats().cold_front, "Cold Front unlocked")
	g.enemies.clear()
	var in_f = put(g, "grunt", 100.0, 0, 500.0)
	cf.pos = in_f.pos + Vector2(30, 0)
	g._update_soaks(0.05)
	check(in_f.slow_amount > 0.15, "everything inside a Cold Front stays slowed (%.2f)" % in_f.slow_amount)


func test_rework_boost_tower() -> void:
	var g = new_game()
	g.gold = 90000
	g.emit_events = true
	var b = g.place_tower("boost_tower", spot(g, "boost_tower", 0))
	check(b != null and b.is_support() and g.tower_cost("boost_tower") == 400, "the Boost Tower builds for 400")
	var s: Dictionary = b.stats()
	check(near(s.range, 144.0) and near(s.buff_dmg, 0.05) and near(s.buff_rate, 0.05) and near(s.buff_range, 0.05), "stock: 144 px, +5% damage, fire rate and range")
	# A tower inside the field is boosted; outside isn't.
	var inside = g.place_tower("gun_turret", spot(g, "gun_turret", 5))
	var outside = g.place_tower("gun_turret", spot(g, "gun_turret", 200))
	b.pos = inside.pos + Vector2(40, 0)
	g._recompute_buffs()
	check(near(inside.buff_dmg, 0.05) and near(inside.buff_rate, 0.05) and near(inside.buff_range, 0.05), "a tower in the field gets +5% of each")
	check(outside.pos.distance_to(b.pos) <= 144.0 or outside.buff_dmg == 0.0, "a tower out of the field doesn't")
	# Retrofits.
	check(g.buy_retrofit(b, 0) and near(b.stats().range, 168.0) and near(b.stats().buff_extra, 0.05), "Signal Booster: 168 px and +5% on top")
	g._recompute_buffs()
	check(near(inside.buff_dmg, 0.10) and near(inside.buff_rate, 0.10) and near(inside.buff_range, 0.10), "stock plus the Retrofit: +10% each")
	var cl = g.place_tower("boost_tower", spot(g, "boost_tower", 20))
	check(g.buy_retrofit(cl, 1) and near(cl.stats().crit_link, 0.03), "Crit Link")
	var wm = g.place_tower("boost_tower", spot(g, "boost_tower", 40))
	check(g.buy_retrofit(wm, 2) and near(wm.stats().range, 192.0), "Wide Mast: 192 px")
	# A path replaces the stock 5% for that stat; the Retrofit's extra stacks.
	buy_steps(g, b, "a", 1)
	g._recompute_buffs()
	check(near(inside.buff_dmg, 0.20) and near(inside.buff_rate, 0.10), "Damage path: +15%% plus the Retrofit's +5%% (%.2f)" % inside.buff_dmg)
	# Overlapping Boost Towers don't stack: the strongest of each kind applies.
	var second = g.place_tower("boost_tower", spot(g, "boost_tower", 60))
	second.pos = inside.pos + Vector2(-40, 0)
	g._recompute_buffs()
	check(near(inside.buff_dmg, 0.20), "two Boost Towers don't stack (%.2f)" % inside.buff_dmg)
	# Boosts apply to damage, rate and range.
	var base_dmg: float = inside.stats().damage
	check(near(inside.eff_damage(), base_dmg * (1.0 + inside.buff_dmg)), "the damage boost reaches the tower's shots")
	# Crit link adds crit chance.
	cl.pos = inside.pos + Vector2(20, 0)
	g._recompute_buffs()
	check(near(inside.buff_crit, 0.03), "Crit Link: +3% crit chance")
	# An EMP switches the boost off.
	b.disabled = 3.0
	cl.disabled = 3.0
	second.disabled = 3.0
	g._update_boost_state()
	check(near(inside.buff_dmg, 0.0) and near(inside.buff_crit, 0.0), "an offline Boost Tower boosts nothing")
	b.disabled = 0.0
	cl.disabled = 0.0
	second.disabled = 0.0
	g._update_boost_state()
	check(inside.buff_dmg > 0.0, "and it comes back when it's online again")
	# Masteries.
	var m = g.place_tower("boost_tower", spot(g, "boost_tower", 80))
	m.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, m, "a", 5)
	check(m.mastered and near(m.stats().buff_dmg, 0.50), "Battle Network: +50% damage")
	var r = g.place_tower("boost_tower", spot(g, "boost_tower", 100))
	r.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, r, "b", 5)
	check(r.mastered and near(r.stats().buff_rate, 0.50), "Rapid Network: +50% fire rate")
	var rg = g.place_tower("boost_tower", spot(g, "boost_tower", 120))
	rg.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, rg, "c", 5)
	check(rg.mastered and near(rg.stats().buff_range, 0.50), "Overwatch Network: +50% range")


func test_rework_radar_tower() -> void:
	var g = new_game()
	g.gold = 90000
	g.emit_events = true
	var t = g.place_tower("radar_tower", spot(g, "radar_tower", 0))
	check(t != null and g.tower_cost("radar_tower") == 575, "the Radar Tower builds for 575")
	var s: Dictionary = t.stats()
	check(near(s.range, 160.0) and near(s.ping_every, 3.0) and near(s.reveal_time, 1.0), "stock: 160 px, a ping every 3 s revealing for 1 s")
	check(g.buy_retrofit(t, 0) and near(t.stats().range, 180.0), "Bigger Dish: 180 px")
	var sp = g.place_tower("radar_tower", spot(g, "radar_tower", 20))
	check(g.buy_retrofit(sp, 1) and near(sp.stats().reveal_time, 1.5), "Signal Processor: reveals last 1.5 s")
	var ew = g.place_tower("radar_tower", spot(g, "radar_tower", 40))
	check(g.buy_retrofit(ew, 2) and ew.stats().early_warning, "Early Warning")
	# A ping reveals a cloaked enemy in range for its duration, and the reveal fades.
	g.enemies.clear()
	var ghost = put(g, "grunt", 100.0, 0, 500.0)
	ghost.cloaked = true
	var far = put(g, "grunt", 300.0, 0, 500.0)
	far.cloaked = true
	far.pos = Vector2(5000, 5000)
	var r = g.place_tower("radar_tower", spot(g, "radar_tower", 60))
	r.pos = ghost.pos + Vector2(40, 0)
	r.cooldown = 0.0
	check(ghost.is_hidden(), "hidden before the ping")
	g._update_radar(r, r.stats(), 0.05)
	check(not ghost.is_hidden() and far.is_hidden(), "a ping reveals the cloaked enemy in range, not the far one")
	for i in 30:
		g._update_radar(r, r.stats(), 0.05)
		ghost.reveal_timer = maxf(0.0, ghost.reveal_timer - 0.05)
	check(ghost.is_hidden(), "the reveal fades before the next ping")
	# A burrowed enemy shows to towers that can hit underground only while a ping is on.
	g.enemies.clear()
	var bur = put(g, "burrower", 100.0, 0, 500.0)
	bur.burrowed = true
	var ms = g.place_tower("mortar_tower", spot(g, "mortar_tower", 80))
	g.buy_retrofit(ms, 1)
	r.pos = bur.pos + Vector2(40, 0)
	r.gun_cds["ping"] = 0.0
	check(not g._burrow_visible(ms, bur), "a burrowed enemy is unseen with no ping")
	r.cooldown = 0.0
	g._update_radar(r, r.stats(), 0.05)
	check(g._burrow_visible(ms, bur), "a ping lets a Bunker Sight mortar see it")
	# Radiation: needs a revealed enemy inside the inner circle.
	var pw = g.place_tower("radar_tower", spot(g, "radar_tower", 100))
	pw.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pw, "a", 3)
	check(near(pw.stats().rad_dps, 15.0) and near(pw.stats().rad_range, 60.0), "Radiation Emitter: 15/s within 60 px")
	g.enemies.clear()
	var in_c = put(g, "grunt", 100.0, 0, 5000.0)
	var ghost2 = put(g, "grunt", 100.0, 0, 5000.0)
	ghost2.pos = in_c.pos + Vector2(10, 0)
	ghost2.cloaked = true
	pw.pos = in_c.pos + Vector2(30, 0)
	pw.cooldown = 99.0
	var h1: float = in_c.hp
	var h2: float = ghost2.hp
	for i in 20:
		g._update_radar(pw, pw.stats(), 0.05)
	check(h1 - in_c.hp > 10.0, "radiation burns the revealed enemy inside (%.1f)" % (h1 - in_c.hp))
	check(near(ghost2.hp, h2), "a cloaked enemy takes nothing until a ping lands")
	pw.cooldown = 0.0
	for i in 20:
		g._update_radar(pw, pw.stats(), 0.05)
	check(ghost2.hp < h2, "once a ping reveals it, it burns too")
	buy_steps(g, pw, "a", 2)
	check(pw.mastered and near(pw.stats().range, 230.0) and near(pw.stats().rad_dps, 40.0) and near(pw.stats().rad_range, 80.0), "Microwave Array: 230 px, 40/s within 80 px")
	# Frequency: more often, constant at the mastery.
	var fq = g.place_tower("radar_tower", spot(g, "radar_tower", 120))
	fq.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, fq, "b", 4)
	check(near(fq.stats().ping_every, 1.6) and near(fq.stats().reveal_time, 1.3), "Phased Array: every 1.6 s for 1.3 s")
	buy_steps(g, fq, "b", 1)
	check(fq.mastered and fq.stats().constant, "Constant Track")
	g.enemies.clear()
	var c1 = put(g, "grunt", 100.0, 0, 500.0)
	c1.cloaked = true
	fq.pos = c1.pos + Vector2(40, 0)
	g._update_radar(fq, fq.stats(), 0.05)
	check(not c1.is_hidden(), "a constant radar keeps everything revealed")
	# Unmasking hooks.
	var um = g.place_tower("radar_tower", spot(g, "radar_tower", 140))
	um.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, um, "c", 5)
	check(um.mastered and um.stats().unmask_decoy and um.stats().unmask_mask and um.stats().unmask_mirage and near(um.stats().exposure, 5.0) and near(um.stats().reveal_time, 1.3), "Total Exposure: the unmasking flags and a 5 s exposure")


## The shop lists every tower once, by class (Assault, Support, Defense, Utility), cheapest first within each (#87).
func test_shop_by_class_then_price() -> void:
	var g = new_game()
	var seen: Array = []
	for cls in ShopPanel.CLASSES:
		var types: Array = ShopPanel.sorted_types(cls, g)
		check(types.all(func(t): return str(Towers.def(t)["class"]) == cls), "%s holds only its own class" % cls)
		var sorted := true
		for i in range(1, types.size()):
			if g.tower_cost(types[i - 1]) > g.tower_cost(types[i]):
				sorted = false
		check(sorted, "%s is cheapest first" % cls)
		seen.append_array(types)
	check(seen.size() == Towers.all_types().size() and Towers.all_types().all(func(t): return seen.has(t)), "every tower appears once")
	check(ShopPanel.sorted_types("Assault", g)[0] == "gun_turret", "the Gun Turret (75) leads Assault")


## The tree viewer's hover text names a step's stat changes in words (#87).
func test_tree_changes_text() -> void:
	check(TreePopOut.changes({"add": {"rate": 0.3, "range": -10.0}}) == "Attacks/s +0.30  ·  Range -10", "adds read as signed changes (%s)" % TreePopOut.changes({"add": {"rate": 0.3, "range": -10.0}}))
	check(TreePopOut.changes({"set": {"homing": true}}) == "Homing", "a flag reads as its label")
	check(TreePopOut.changes({}) == "", "no changes, no text")


func test_rework_shockwave_generator() -> void:
	var g = new_game()
	g.gold = 90000
	g.emit_events = true
	var t = g.place_tower("shockwave_generator", spot(g, "shockwave_generator", 0))
	check(t != null and g.tower_cost("shockwave_generator") == 450, "the Shockwave Generator builds for 450")
	var s: Dictionary = t.stats()
	check(near(s.damage, 75.0) and near(s.range, 100.0) and near(s.rate, 0.571), "stock: 75 damage, 100 px, a wave every 1.75 s")
	check(g.buy_retrofit(t, 0) and near(t.stats().range, 115.0), "Wave Focus: +15 px")
	var cc = g.place_tower("shockwave_generator", spot(g, "shockwave_generator", 20))
	check(g.buy_retrofit(cc, 1) and near(cc.stats().damage, 85.0), "Containment Coils: +10 damage")
	var rv = g.place_tower("shockwave_generator", spot(g, "shockwave_generator", 40))
	check(g.buy_retrofit(rv, 2) and near(rv.stats().rate, 0.667), "Reactor Venting: a wave every 1.5 s")
	# One wave hits everything in the radius, air and ground, cloaked too; armour applies.
	g.enemies.clear()
	var w = g.place_tower("shockwave_generator", spot(g, "shockwave_generator", 60))
	var e1 = put(g, "brute", 100.0, 0, 500.0)
	var e2 = put(g, "bat", 100.0, 0, 500.0)
	e2.pos = e1.pos + Vector2(10, 0)
	var e3 = put(g, "grunt", 100.0, 0, 500.0)
	e3.pos = e1.pos + Vector2(-10, 0)
	e3.cloaked = true
	var far = put(g, "grunt", 300.0, 0, 500.0)
	w.pos = e1.pos + Vector2(40, 0)
	var hs: Array = [e1.hp, e2.hp, e3.hp, far.hp]
	w.cooldown = 0.0
	g._update_shockwave(w, w.stats(), 0.0)
	check(e1.hp < hs[0] and e2.hp < hs[1] and e3.hp < hs[2] and near(far.hp, hs[3]), "one wave hits the walker, the flyer and the cloaked enemy, not the far one")
	check(near(hs[0] - e1.hp, 75.0 - e1.effective_armor(), 0.5), "armour applies to the wave (%.1f)" % (hs[0] - e1.hp))
	check(not e3.is_hidden(), "the hit reveals the cloaked enemy briefly")
	check(w.cooldown > 1.7 and w.cooldown < 1.8, "the next wave comes in 1.75 s (%.2f)" % w.cooldown)
	# Power path.
	var pw = g.place_tower("shockwave_generator", spot(g, "shockwave_generator", 80))
	pw.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pw, "a", 5)
	check(pw.mastered and near(pw.stats().damage, 135.0) and near(pw.stats().range, 132.0), "Megaton Wave: 135 damage, 132 px")
	var sp = g.place_tower("shockwave_generator", spot(g, "shockwave_generator", 100))
	sp.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, sp, "b", 5)
	check(sp.mastered and near(sp.stats().rate, 1.25), "Chain Pulse: a wave every 0.8 s")
	# Effect path: barriers take more; the mastery halves and locks them.
	var ef = g.place_tower("shockwave_generator", spot(g, "shockwave_generator", 120))
	ef.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, ef, "c", 4)
	check(near(ef.stats().shield_mult, 3.0), "Breaker Wave: x3 to barriers")
	g.enemies.clear()
	var aegis = put(g, "aegis", 100.0, 0, 50.0)
	check(aegis.max_shield > 0.0, "an Aegis Walker carries a barrier")
	ef.pos = aegis.pos + Vector2(40, 0)
	var sh0: float = aegis.shield
	ef.cooldown = 0.0
	g._update_shockwave(ef, ef.stats(), 0.0)
	var plain_w = g.place_tower("shockwave_generator", spot(g, "shockwave_generator", 140))
	var aegis2 = put(g, "aegis", 100.0, 0, 50.0)
	aegis2.pos = aegis.pos + Vector2(0, 5)
	plain_w.pos = aegis2.pos + Vector2(40, 0)
	var sh1: float = aegis2.shield
	plain_w.cooldown = 0.0
	g.enemies.erase(aegis)
	g._update_shockwave(plain_w, plain_w.stats(), 0.0)
	check((sh0 - aegis.shield) > (sh1 - aegis2.shield) * 2.0, "the barrier takes far more from the Effect path (%.1f vs %.1f)" % [sh0 - aegis.shield, sh1 - aegis2.shield])
	buy_steps(g, ef, "c", 1)
	check(ef.mastered and ef.stats().shatter_half, "Shatter Shock")
	g.enemies.clear()
	var ag3 = put(g, "aegis", 100.0, 0, 50.0)
	ef.pos = ag3.pos + Vector2(40, 0)
	ag3.shield = ag3.max_shield
	ef.cooldown = 0.0
	g._update_shockwave(ef, ef.stats(), 0.0)
	check(ag3.shield < ag3.max_shield * 0.5 and ag3.barrier_block >= 4.9, "the wave halves the barrier and stops it regenerating (%.1f of %.1f, block %.1f)" % [ag3.shield, ag3.max_shield, ag3.barrier_block])


func test_rework_scrapyard() -> void:
	var g = new_game()
	g.gold = 900000
	g.emit_events = true
	var t = g.place_tower("scrapyard", spot(g, "scrapyard", 0))
	check(t != null and t.is_economy() and t.size == 2 and g.tower_cost("scrapyard") == 875, "the Scrapyard builds for 875, 2x2")
	var s: Dictionary = t.stats()
	check(near(s.income, 100.0) and near(s.range, 150.0), "stock: 100 per round, a 150 px field")
	check(g.buy_retrofit(t, 0) and near(t.stats().income, 130.0), "Hammer Mill: +30 per round")
	var fl = g.place_tower("scrapyard", spot(g, "scrapyard", 30))
	check(g.buy_retrofit(fl, 1) and near(fl.stats().range, 180.0), "Faster Loading: +30 px")
	var su = g.place_tower("scrapyard", spot(g, "scrapyard", 60))
	check(g.buy_retrofit(su, 2) and near(su.stats().sell_field, 0.85), "Surplus: towers sell back more")
	# Income is paid at each round's clear, and several Scrapyards stack.
	var before: int = g.gold
	var paid: Array = g._pay_income(1)
	check(g.gold - before == 130 + 100 + 100 and paid.size() == 3, "all three pay at a clear and stack (%d)" % (g.gold - before))
	# Kill field: enemies destroyed inside pay more; the best field applies.
	var kf = g.place_tower("scrapyard", spot(g, "scrapyard", 90))
	kf.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, kf, "b", 3)
	check(near(kf.stats().bounty_bonus, 0.35) and near(kf.stats().range, 170.0), "Laser Cutter: +35%, 170 px")
	g.enemies.clear()
	var foe = put(g, "grunt", 100.0, 0, 50.0)
	foe.pos = kf.pos + Vector2(20, 0)
	check(near(g._salvage_mult(foe), 1.35), "a kill inside the field pays 35% more (%.2f)" % g._salvage_mult(foe))
	buy_steps(g, kf, "b", 2)
	check(kf.mastered and near(kf.stats().bounty_bonus, 0.6) and near(kf.stats().boss_bounty, 2.0) and near(kf.stats().range, 210.0), "Breaker's Yard: +60%, bosses pay double, 210 px")
	# Discounts: upgrades near it cost less; builds too from Forklift Bay.
	var df = g.place_tower("scrapyard", spot(g, "scrapyard", 120))
	df.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, df, "c", 3)
	check(near(df.stats().discount, 0.15) and near(df.stats().build_discount, 0.05) and near(df.stats().range, 160.0), "Forklift Bay: 15% off upgrades, 5% off builds, 160 px")
	var near_t = g.place_tower("gun_turret", spot(g, "gun_turret", 40))
	near_t.pos = df.pos + Vector2(40, 0)
	g._recompute_buffs()
	check(near(near_t.discount, 0.15), "a tower in the field gets 15% off upgrades")
	var cost_before: int = near_t.upgrade_cost("a")
	var plain = g.place_tower("gun_turret", spot(g, "gun_turret", 80))
	plain.pos = Vector2(5000, 5000)
	check(cost_before < plain.upgrade_cost("a"), "so its upgrade is cheaper (%d vs %d)" % [cost_before, plain.upgrade_cost("a")])
	check(near(g.build_discount_at(df.pos + Vector2(40, 0)), 0.05) and g.build_discount_at(Vector2(5000, 5000)) == 0.0, "builds inside the field are 5% cheaper")
	buy_steps(g, df, "c", 2)
	check(df.mastered and near(df.stats().discount, 0.25) and near(df.stats().sell_field, 1.0), "Parts Exchange: 25% off, towers sell back in full")
	g._recompute_buffs()
	near_t.spent = 1000
	check(g.sell_value(near_t) == 1000, "a tower in the field sells for everything spent")
	# Passive path.
	var ps = g.place_tower("scrapyard", spot(g, "scrapyard", 150))
	ps.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, ps, "a", 5)
	check(ps.mastered and near(ps.stats().income, 320.0) and near(ps.stats().interest, 0.03) and near(ps.stats().interest_cap, 400.0), "Gold Foundry: 320 per round and 3% interest")
	# Its own upgrades aren't discounted by itself.
	check(near(ps.discount, 0.0), "a Scrapyard's own upgrades aren't discounted")


func test_rework_magneto_tower() -> void:
	var g = new_game()
	g.gold = 900000
	g.emit_events = true
	var t = g.place_tower("magneto_tower", spot(g, "magneto_tower", 0))
	check(t != null and g.tower_cost("magneto_tower") == 525, "the Magneto Tower builds for 525")
	var s: Dictionary = t.stats()
	check(near(s.range, 120.0) and near(s.slow, 0.25), "stock: a 120 px field, 25% slow")
	check(g.buy_retrofit(t, 0) and near(t.stats().slow, 0.30), "Superconducting Coil: 30%")
	var fs = g.place_tower("magneto_tower", spot(g, "magneto_tower", 20))
	check(g.buy_retrofit(fs, 1) and near(fs.stats().range, 135.0), "Field Stabiliser: 135 px")
	var ps = g.place_tower("magneto_tower", spot(g, "magneto_tower", 40))
	check(g.buy_retrofit(ps, 2) and near(ps.stats().pole_shoes, 0.3), "Pole Shoes")
	# The slow, scaled by role weight; air and ground; outside the field nothing.
	g.enemies.clear()
	var m = g.place_tower("magneto_tower", spot(g, "magneto_tower", 60))
	var swarm = put(g, "swarmling", 100.0, 0, 500.0)
	var tank = put(g, "brute", 100.0, 0, 500.0)
	var bat = put(g, "bat", 100.0, 0, 500.0)
	var boss = put(g, "colossus", 100.0, 0, 1.0)
	var far = put(g, "grunt", 100.0, 0, 500.0)
	far.pos = Vector2(5000, 5000)
	for e in [swarm, tank, bat, boss]:
		e.pos = m.pos + Vector2(30, 0)
	m.cooldown = 99.0
	g._update_magneto(m, m.stats(), 0.05)
	check(near(swarm.slow_amount, 0.25, 0.01) and bat.slow_amount > 0.2 and far.slow_amount == 0.0, "air and ground in the field are slowed; the far one isn't")
	check(tank.slow_amount < swarm.slow_amount and boss.slow_amount < tank.slow_amount, "heavier roles resist more (swarm %.2f, brute %.2f, boss %.2f)" % [swarm.slow_amount, tank.slow_amount, boss.slow_amount])
	# Pull Strength: heavy roles resist less; the mastery slows everyone fully.
	var pw = g.place_tower("magneto_tower", spot(g, "magneto_tower", 80))
	pw.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pw, "a", 5)
	check(pw.mastered and near(pw.stats().slow, 0.55) and near(pw.stats().grip_relief, 1.0), "Absolute Pull: 55%, no role resists")
	pw.pos = tank.pos
	boss.slow_amount = 0.0
	boss.slow_timer = 0.0
	pw.cooldown = 99.0
	g._update_magneto(pw, pw.stats(), 0.05)
	check(near(boss.slow_amount, 0.55 * (1.0 - boss.slow_resist), 0.02), "even a boss is slowed fully (%.2f)" % boss.slow_amount)
	# Field size.
	var fz = g.place_tower("magneto_tower", spot(g, "magneto_tower", 100))
	fz.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, fz, "b", 5)
	check(fz.mastered and near(fz.stats().range, 195.0), "Magnetosphere: 195 px")
	# Polarity: armour comes off while inside, for good with Torn Plates.
	var pl = g.place_tower("magneto_tower", spot(g, "magneto_tower", 120))
	pl.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pl, "c", 2)
	check(near(pl.stats().armor_pull, 4.0), "Plate Ripper: 4 armour")
	g.enemies.clear()
	var brute = put(g, "brute", 100.0, 0, 500.0)
	pl.pos = brute.pos + Vector2(30, 0)
	pl.cooldown = 99.0
	var a0: float = brute.effective_armor()
	g._update_magneto(pl, pl.stats(), 0.05)
	check(near(brute.effective_armor(), maxf(0.0, a0 - 4.0)), "armour is pulled off inside the field (%.1f)" % brute.effective_armor())
	for i in 20:
		brute.step(0.05)
	check(near(brute.effective_armor(), a0), "and comes back when it leaves")
	buy_steps(g, pl, "c", 1)
	g._update_magneto(pl, pl.stats(), 0.05)
	for i in 20:
		brute.step(0.05)
	check(brute.armor_shred >= 4.0 and brute.effective_armor() < a0, "Torn Plates: gone for good (%.1f)" % brute.effective_armor())
	# Reverse polarity: a flip flings crowded enemies together.
	buy_steps(g, pl, "c", 2)
	check(pl.mastered and int(pl.stats().flip_every) == 4 and near(pl.stats().flip_damage, 40.0), "Reverse Polarity: a flip every 4 s")
	g.enemies.clear()
	var a = put(g, "grunt", 100.0, 0, 5000.0)
	var b = put(g, "grunt", 100.0, 0, 5000.0)
	b.pos = a.pos + Vector2(10, 0)
	var lone = put(g, "grunt", 100.0, 0, 5000.0)
	lone.pos = a.pos + Vector2(0, 80)
	pl.pos = a.pos + Vector2(30, 0)
	pl.cooldown = 0.0
	var ha: float = a.hp
	var hl: float = lone.hp
	g._update_magneto(pl, pl.stats(), 0.05)
	check(a.hp < ha and b.hp < b.max_hp and near(lone.hp, hl) and a.stun_timer > 0.2, "the flip hurts and stuns the crowded, not the lone one")


func test_rework_tractor_tower() -> void:
	var g = new_game()
	g.gold = 900000
	g.emit_events = true
	var t = g.place_tower("tractor_tower", spot(g, "tractor_tower", 0))
	check(t != null and g.tower_cost("tractor_tower") == 575, "the Tractor Tower builds for 575")
	var s: Dictionary = t.stats()
	check(near(s.range, 160.0) and near(s.hold, 1.5) and near(s.pull, 80.0) and near(s.recharge, 6.0), "stock: 160 px, hold 1.5 s, pull 80 px, recharge 6 s")
	check(g.buy_retrofit(t, 0) and near(t.stats().beam_slow, 0.3), "Beam Sweep")
	var lh = g.place_tower("tractor_tower", spot(g, "tractor_tower", 20))
	check(g.buy_retrofit(lh, 1) and near(lh.stats().hold, 2.0), "Longer Hold: 2 s")
	var fr = g.place_tower("tractor_tower", spot(g, "tractor_tower", 40))
	check(g.buy_retrofit(fr, 2) and near(fr.stats().recharge, 5.0), "Faster Recharge: 5 s")
	# A grab: locks one enemy, holds it (no forward motion), hauls it back, releases it, recharges.
	g.enemies.clear()
	var tr = g.place_tower("tractor_tower", spot(g, "tractor_tower", 60))
	var e = put(g, "grunt", 200.0, 0, 5000.0)
	tr.pos = e.pos + Vector2(30, 0)
	tr.cooldown = 0.0
	var d0: float = e.distance
	g._update_tractor(tr, tr.stats(), 0.05)
	check(tr.target == e and float(tr.gun_cds.hold_left) > 1.4, "it locks the enemy")
	for i in 31:
		g._update_tractor(tr, tr.stats(), 0.05)
		e.step(0.05)
	check(d0 - e.distance > 70.0 and d0 - e.distance < 95.0, "a swarm-weight enemy is hauled back about 80 px (%.1f)" % (d0 - e.distance))
	check(tr.cooldown > 5.5 and tr.target == null, "released, then it recharges 6 s")
	# Role weight: a boss is pulled a quarter as far and held half as long.
	var boss = put(g, "colossus", 200.0, 0, 1.0)
	var btr = g.place_tower("tractor_tower", spot(g, "tractor_tower", 80))
	btr.pos = boss.pos + Vector2(30, 0)
	g.enemies.erase(e)
	btr.cooldown = 0.0
	g._update_tractor(btr, btr.stats(), 0.05)
	check(float(btr.gun_cds.hold_left) < 0.8 and float(btr.gun_cds.pull_rate) * float(btr.gun_cds.hold_left) < 25.0, "a boss: shorter hold, about a quarter of the pull")
	# Pull path: longer, then Rewind by time, then Undo.
	var pu = g.place_tower("tractor_tower", spot(g, "tractor_tower", 100))
	pu.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pu, "a", 3)
	check(near(pu.stats().rewind, 3.0), "Rewind: back to where it was 3 s ago")
	g.enemies.clear()
	var rw = put(g, "grunt", 50.0, 0, 5000.0)
	for i in 80:
		rw.step(0.05)
		if i % 5 == 4:
			rw.dist_log.append(rw.distance)
	var then: float = rw.distance_ago(3.0)
	check(then < rw.distance and rw.distance - then > 10.0, "the enemy remembers where it was (%.0f now, %.0f then)" % [rw.distance, then])
	pu.pos = rw.pos + Vector2(30, 0)
	pu.cooldown = 0.0
	g._update_tractor(pu, pu.stats(), 0.05)
	check(float(pu.gun_cds.pull_rate) * float(pu.gun_cds.hold_left) > (rw.distance - then) * 0.8, "the pull is the rewind distance")
	buy_steps(g, pu, "a", 2)
	check(pu.mastered and near(pu.stats().rewind, 5.0) and pu.stats().undo, "Undo: back 5 s, and once a round to the segment start")
	# Undo: once per round, a non-boss goes back to the start of its segment.
	g.enemies.clear()
	var u = put(g, "grunt", 400.0, 0, 5000.0)
	pu.pos = u.pos + Vector2(30, 0)
	pu.cooldown = 0.0
	pu.gun_cds.clear()
	var seg: float = g._segment_start(u)
	g._update_tractor(pu, pu.stats(), 0.05)
	check(float(pu.gun_cds.pull_rate) * float(pu.gun_cds.hold_left) >= (u.distance - seg) * 0.95 or seg <= 0.0, "Undo sends it back to its segment start (%.0f -> %.0f)" % [u.distance, seg])
	check(int(pu.gun_cds.undo_wave) == g.wave, "it's used for this round")
	# Recharge path.
	var rc = g.place_tower("tractor_tower", spot(g, "tractor_tower", 120))
	rc.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, rc, "b", 5)
	check(rc.mastered and near(rc.stats().recharge, 2.0), "Supercapacitor: recharge 2 s")
	# Grip path: crushing damage, lock, slam.
	var gr = g.place_tower("tractor_tower", spot(g, "tractor_tower", 140))
	gr.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, gr, "c", 2)
	check(near(gr.stats().grip_relief, 0.5) and near(gr.stats().grip_dps, 15.0), "Crushing Grip: 15/s")
	g.enemies.clear()
	var hv = put(g, "brute", 200.0, 0, 5000.0)
	gr.pos = hv.pos + Vector2(30, 0)
	gr.cooldown = 0.0
	var hp: float = hv.hp
	g._update_tractor(gr, gr.stats(), 0.05)
	for i in 20:
		g._update_tractor(gr, gr.stats(), 0.05)
	check(hp - hv.hp > 10.0, "the held enemy takes crushing damage (%.1f)" % (hp - hv.hp))
	hv.alive = false
	buy_steps(g, gr, "c", 3)
	check(gr.mastered and near(gr.stats().slam_radius, 80.0) and near(gr.stats().slam_stun, 0.8) and gr.stats().slam_shatter and gr.stats().grip_lock, "Gravity Hammer: an 80 px slam, 0.8 s, shatters barriers")
	g.enemies.clear()
	var held = put(g, "aegis", 200.0, 0, 5000.0)
	gr.pos = held.pos + Vector2(40, 0)
	gr.cooldown = 0.0
	g._update_tractor(gr, gr.stats(), 0.05)
	check(held.barrier_block == 0.0, "no lock before the grab ticks")
	g._update_tractor(gr, gr.stats(), 0.05)
	check(held.barrier_block > 0.0 and held.suppress_timer > 0.0, "Grip Lock: the held enemy's barrier and abilities are off (%.2f %.2f %s %.2f)" % [held.barrier_block, held.suppress_timer, str(gr.target == held), float(gr.gun_cds.get("hold_left", -1.0))])
	var nb = put(g, "grunt", 200.0, 0, 5000.0)
	nb.pos = held.pos + Vector2(30, 0)
	gr.gun_cds["hold_left"] = 0.01
	g._update_tractor(gr, gr.stats(), 0.05)
	check(nb.stun_timer > 0.5 and held.shield == 0.0, "the slam stuns what is near it and shatters the barrier")


func test_rework_augmentation_tower() -> void:
	var g = new_game()
	g.gold = 900000
	g.emit_events = true
	var a = g.place_tower("augmentation_tower", spot(g, "augmentation_tower", 0))
	check(a != null and a.is_support() and g.tower_cost("augmentation_tower") == 650, "the Augmentation Tower builds for 650")
	var s: Dictionary = a.stats()
	check(near(s.range, 96.0) and near(s.aug_crit, 0.05) and near(s.crit_mult, 2.0), "stock: 96 px, a 5% crit chance (x2)")
	check(g.buy_retrofit(a, 0) and near(a.stats().range, 144.0), "Wide Aura: 144 px")
	var ab = g.place_tower("augmentation_tower", spot(g, "augmentation_tower", 20))
	check(g.buy_retrofit(ab, 1) and near(ab.stats().aug_crit, 0.10), "Amplified Bonus: 10%")
	var rl = g.place_tower("augmentation_tower", spot(g, "augmentation_tower", 40))
	check(g.buy_retrofit(rl, 2) and rl.stats().remote_link, "Remote Link")
	# Towers in range get the effects; Support towers and itself don't.
	var base = g.place_tower("augmentation_tower", spot(g, "augmentation_tower", 60))
	var gun = g.place_tower("gun_turret", spot(g, "gun_turret", 5))
	var far_gun = g.place_tower("gun_turret", spot(g, "gun_turret", 150))
	base.pos = gun.pos + Vector2(40, 0)
	far_gun.pos = Vector2(5000, 5000)
	g._recompute_buffs()
	check(near(gun.buff_crit, 0.05) and far_gun.buff_crit == 0.0 and base.buff_crit == 0.0, "a tower in range gets 5% crit; one out of range and the Augmentation itself don't")
	# Crits double a hit (a sure crit), continuous damage gets the average.
	gun.buff_crit = 1.0
	gun.aug_crit_mult = 2.0
	g.enemies.clear()
	var e = put(g, "grunt", 100.0, 0, 5000.0)
	var h0: float = e.hp
	var d1 := g.damage_enemy(e, 10.0, true, gun)
	check(near(d1, 20.0), "a sure crit does double damage (%.1f)" % d1)
	var d2 := g.damage_enemy(e, 10.0, true, gun, false)
	check(near(d2, 20.0), "continuous damage takes the average (x2 at 100%% here: %.1f)" % d2)
	gun.buff_crit = 0.0
	# Crit path.
	var cp = g.place_tower("augmentation_tower", spot(g, "augmentation_tower", 80))
	cp.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, cp, "b", 3)
	check(near(cp.stats().aug_crit, 0.15) and near(cp.stats().crit_mult, 2.5), "Precision Matrix: 15%, crits x2.5")
	buy_steps(g, cp, "b", 2)
	check(cp.mastered and near(cp.stats().aug_crit, 0.22) and near(cp.stats().crit_mult, 3.0), "Executioner Link: 22%, x3")
	cp.pos = gun.pos + Vector2(40, 0)
	base.pos = Vector2(5000, 5000)
	g._recompute_buffs()
	check(near(gun.buff_crit, 0.22) and near(gun.aug_crit_mult, 3.0), "the tower takes the strongest crit effect")
	# Two Augmentation Towers don't stack.
	var cp2 = g.place_tower("augmentation_tower", spot(g, "augmentation_tower", 100))
	cp2.pos = gun.pos + Vector2(-40, 0)
	g._recompute_buffs()
	check(near(gun.buff_crit, 0.22), "overlapping Augmentation Towers don't stack")
	# Energy conversion: a share of the damage counts as energy; full conversion tags every hit.
	var ec = g.place_tower("augmentation_tower", spot(g, "augmentation_tower", 120))
	ec.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, ec, "a", 4)
	check(near(ec.stats().energy_conv, 1.0), "Full Conversion: 100%")
	cp.pos = Vector2(5000, 5000)
	cp2.pos = Vector2(5000, 5000)
	ec.pos = gun.pos + Vector2(40, 0)
	g._recompute_buffs()
	check(near(gun.aug_energy, 1.0), "a nearby tower's damage is all energy")
	e.last_hit_kind = "physical"
	g.damage_enemy(e, 1.0, true, gun)
	check(e.last_hit_kind == "energy", "so the hit is tagged energy")
	buy_steps(g, ec, "a", 1)
	g._recompute_buffs()
	var before: float = e.hp
	var dealt: float = g.damage_enemy(e, 10.0, true, gun)
	check(ec.mastered and near(gun.aug_energy_bonus, 0.10) and dealt >= 10.9, "Overcharge: +10%% energy damage (%.1f)" % dealt)
	# Ricochet: a single-target hit bounces to another enemy within 60 px at a share of its damage.
	var rc = g.place_tower("augmentation_tower", spot(g, "augmentation_tower", 140))
	rc.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, rc, "c", 3)
	check(near(rc.stats().ricochet, 0.30) and near(rc.stats().ricochet_str, 0.7), "Ricochet Field: 30%, bounces at 70%")
	ec.pos = Vector2(5000, 5000)
	rc.pos = gun.pos + Vector2(40, 0)
	g._recompute_buffs()
	gun.aug_ricochet = 1.0
	g.enemies.clear()
	var e1 = put(g, "grunt", 100.0, 0, 5000.0)
	var e2 = put(g, "grunt", 100.0, 0, 5000.0)
	e2.pos = e1.pos + Vector2(30, 0)
	var e3 = put(g, "grunt", 100.0, 0, 5000.0)
	e3.pos = e1.pos + Vector2(0, 300)
	var h2: float = e2.hp
	g._ricochet(gun, e1, 100.0)
	check(near(h2 - e2.hp, 100.0 * gun.aug_ricochet_str, 0.5) and near(e3.hp, e3.max_hp), "a bounce hits the nearest other enemy within 60 px at its share (%.1f)" % (h2 - e2.hp))
	var h3: float = e2.hp
	var e4 = put(g, "grunt", 100.0, 0, 5000.0)
	e4.pos = e2.pos + Vector2(30, 0)
	g._ricochet(gun, e1, 100.0)
	check(near(e4.hp, e4.max_hp), "without Pinball a bounce doesn't bounce again")
	gun.aug_bounce_again = true
	g._ricochet(gun, e1, 100.0)
	check(e4.hp < e4.max_hp, "with Pinball it does")
	var pb = g.place_tower("augmentation_tower", spot(g, "augmentation_tower", 160))
	pb.mods = {"mult": {}, "add": {}, "cost": 0.0, "mastery": true}
	buy_steps(g, pb, "c", 5)
	check(pb.mastered and near(pb.stats().ricochet, 0.5) and pb.stats().bounce_again, "Pinball: 50%, a bounce can bounce again")
	# Remote Link: twice the radius at half strength.
	var rem = g.place_tower("augmentation_tower", spot(g, "augmentation_tower", 180))
	g.buy_retrofit(rem, 2)
	var far2 = g.place_tower("gun_turret", spot(g, "gun_turret", 170))
	rc.pos = Vector2(5000, 5000)
	pb.pos = Vector2(5000, 5000)
	rem.pos = far2.pos + Vector2(150, 0)
	gun.pos = Vector2(5000, 4000)
	g._recompute_buffs()
	check(near(far2.buff_crit, 0.025), "Remote Link: a tower up to twice the radius away gets half the effect (%.3f)" % far2.buff_crit)
	# An EMP switches it off.
	rem.disabled = 3.0
	g._update_boost_state()
	check(far2.buff_crit == 0.0, "an offline Augmentation Tower gives nothing")


## Enemy art (enemy rework phase 5): every enemy has its confirmed look and identity colour.
func test_enemy_art_covers_every_enemy() -> void:
	for type in Enemies.ENEMIES:
		check(EnemyArt.has(type), "%s has a look" % type)
		check(Draw.ENEMY_COLOR.has(type) and Draw.ENEMY_BODY.has(type), "%s has its palette colours" % type)
		check(EnemyArt.anim(type, 1.3, {}).size() == 7, "%s has an animation" % type)


## Movement patterns: a pace that keeps the average speed, an offset that stays on the lane, and the facing along the
## track, not the weave.
func test_enemy_moves() -> void:
	var g = new_game()
	for type in ["brute", "hydra", "bulwark", "blackout", "masquerade"]:
		var e = put(g, type, 100.0)
		e.disguised = false
		var sum := 0.0
		var n := 0
		var tt := 0.0
		while tt < 120.0:
			sum += EnemyMoves.pace(e, tt)
			n += 1
			tt += 0.01
		check(absf(sum / float(n) - 1.0) < 0.02, "%s's pace averages 1 (%.3f)" % [type, sum / float(n)])
	var widest := 0.0
	for type in Enemies.ENEMIES:
		for i in 5:
			var e = put(g, type, 100.0)
			e.disguised = false
			for k in 300:
				widest = maxf(widest, absf(EnemyMoves.side(e, float(k) * 0.1)))
	check(widest <= 20.0, "every pattern stays on the 40 px lane (widest %.1f px)" % widest)
	# A Skitter swerves off the track line but keeps its heading along it, and covers the same ground as before.
	var sk = put(g, "runner", 200.0)
	var swerve := 0.0
	var aligned := true
	for i in 240:
		sk.step(SIM_DT)
		var tp: Vector2 = sk.curve.sample_baked(sk.distance)
		swerve = maxf(swerve, sk.pos.distance_to(tp))
		var ahead: Vector2 = sk.curve.sample_baked(minf(sk.distance + 4.0, sk.path_len)) - tp
		if ahead.length() > 1.0 and sk.facing.dot(ahead.normalized()) < 0.9:
			aligned = false
	check(swerve > 2.0 and swerve <= 20.0, "a Skitter swerves on the lane (%.1f px)" % swerve)
	check(aligned, "it faces along the track while it swerves")
	check(near(sk.distance, 200.0 + float(sk.speed) * 240.0 * SIM_DT, 0.5), "a steady-paced enemy covers its usual ground")
	# A Siege Mech surges and slows step by step, but over a minute it covers its usual ground.
	var sm = put(g, "brute", 100.0)
	for i in 3600:
		sm.step(SIM_DT)
	var want := 100.0 + float(sm.speed) * 60.0
	check(absf(sm.distance - want) < want * 0.02, "a Siege Mech's trudge keeps its average speed (%.0f of %.0f)" % [sm.distance, want])
	# A Bulwark holds still while its barriers go out.
	var bw = put(g, "bulwark", 300.0)
	bw.mark("grant")
	var d0: float = bw.distance
	for i in 60:
		bw.step(SIM_DT)
	check(near(bw.distance, d0), "a Bulwark braces for its barrier grant")
	# A Shrike cluster spreads across the lane, one slot each.
	var slots := {}
	for i in 5:
		var e = put(g, "shrike", 100.0)
		slots[snappedf(EnemyMoves.side(e, 0.0), 0.1)] = true
	check(slots.size() == 5, "a Shrike cluster flies in five slots")


## The art's game state: abilities stamp when they fire, and each look's effects take their timing from it.
func test_enemy_art_state() -> void:
	var g = new_game()
	var j = put(g, "jammer", 150.0)
	check(j.since("emp") > 1e5, "an ability that never fired is long ago")
	check(EnemyArt.state(j).emp > 1e5, "so the Jammer's EMP ring isn't showing")
	g._trait_emp(j, j.def)
	j.step(0.25)
	check(near(j.since("emp"), 0.25) and near(EnemyArt.state(j).emp, 0.25), "an EMP stamps the moment it fires")
	var b = put(g, "burrower", 150.0)
	check(near(EnemyArt.state(b).under, 0.0), "a Burrower on the surface shows")
	b.burrowed = true
	b.mark("burrow")
	b.step(0.15)
	check(near(EnemyArt.state(b).under, 0.5, 0.01), "it sinks out of sight as it burrows")
	b.step(0.3)
	check(near(EnemyArt.state(b).under, 1.0), "then it's gone")
	var m = put(g, "masquerade", 150.0)
	check(m.disguised and near(EnemyArt.state(m).uncover, 0.0), "a disguised Masquerade looks like a Drone")
	m.reveal_disguise()
	m.step(0.6)
	check(near(EnemyArt.state(m).uncover, 1.0), "uncovered, it unfolds over 0.6 s")
	var ph = put(g, "phantom", 150.0)
	var hidden_st := EnemyArt.state(ph)
	check(near(hidden_st.reveal, 0.0) and hidden_st.lock, "a hidden Phantom is camouflaged")
	ph.reveal_timer = 1.0
	check(near(EnemyArt.state(ph).reveal, 1.0), "a revealed one shows in full")
	var ti = put(g, "titan", 150.0)
	check(near(EnemyArt.state(ti).shed, 0.0), "a Titan wears its plates")
	g.damage_enemy(ti, ti.max_hp * 0.6, true, null)
	ti.step(1.0)
	check(ti.shed and near(EnemyArt.state(ti).shed, 1.0), "below half health its plates come away")
	var ae = put(g, "aegis", 150.0)
	check(near(EnemyArt.state(ae).barrier, 1.0), "an Aegis Walker's barrier is full")
	var holo = put(g, "mirage", 150.0)
	holo.make_hologram(put(g, "mirage", 160.0))
	check(EnemyArt.state(holo).hologram, "a Mirage's hologram draws as a flickering copy")


## The Codex (enemy rework phase 6): role, tier and strength, a line for every trait, the modifiers it can roll, and the
## roles and elites pages.
func test_codex_enemy_rework() -> void:
	check(Lore.enemy_line("grunt").begins_with("Swarm T3  ·  strength "), "an enemy's line leads with its role, tier and strength")
	check(Lore.enemy_line("juggernaut").begins_with("Boss  ·  "), "a boss is just a Boss")
	var says := func(type: String, bit: String) -> bool:
		return Lore.enemy_abilities(Enemies.ENEMIES[type]).any(func(l): return str(l).contains(bit))
	check(says.call("wraith", "Only energy damage hurts it"), "the Wraith's energy-only line")
	check(says.call("capacitor", "charges for 2 s") and not says.call("capacitor", "EMP every"), "the Capacitor charges instead of a plain EMP")
	check(says.call("siphon", "fire 20% slower"), "the Siphon's drain")
	check(says.call("shifter", "move 20% faster for 2 s"), "the Shifter's wake")
	check(says.call("fury", "runs 30% faster"), "the Fury Drone's adrenaline")
	check(says.call("titan", "armor drops to 5"), "the Titan sheds")
	check(says.call("masquerade", "like a Drone"), "the Masquerade's disguise")
	check(says.call("decoy", "Strongest towers aim at it"), "the Decoy Beacon's false rank")
	check(says.call("mirage", "holograms"), "the Mirage's holograms")
	check(says.call("needle", "pair") and says.call("shrike", "clusters of 5"), "pairs and clusters")
	check(says.call("phantom", "along the track"), "the Phantom flies along the track")
	check(Lore.enemy_mods("juggernaut").is_empty() and Lore.enemy_mods("masquerade").is_empty() and Lore.enemy_mods("decoy").is_empty(), "bosses and tricks are never elites")
	check(not Lore.enemy_mods("aegis").has("shielded") and Lore.enemy_mods("grunt").size() == Modifiers.ORDER.size(), "an enemy rolls only the modifiers it can take")
	check(Lore.modifier_rows().size() == Modifiers.ORDER.size() and int(Lore.modifier_rows()[0].intro) == int(Modifiers.MODIFIERS[Modifiers.ORDER[0]].intro), "the elites page lists every modifier with its first round")
	var roles := Lore.role_rows()
	var listed := 0
	for r in roles:
		for c in r.tiers:
			listed += (c as Array).size()
		listed += (r.other as Array).size()
	check(listed == Enemies.ORDER.size(), "the roles page places every enemy once")
	check(Glossary.ENTRIES.has("roles") and not Lore.text("roles").contains("{") and Lore.text("roles").contains(str(roundi(float(Enemies.LEAK_BANDS[0])))), "the roles entry quotes the leak bands from the data")


## The Sandbox Spawner's modifiers: cards spawn elites with the toggled modifiers the enemy can take.
func test_sandbox_spawn_modifiers() -> void:
	var g = sandbox_game()
	var skipped: Array = g.sandbox_spawn("aegis", 2, ["shielded", "hasty"])
	check(skipped == ["shielded"], "a modifier it already has is skipped and named")
	check(g.spawn_queue.size() == 2 and g.spawn_queue.all(func(s): return s.mods == ["hasty"]), "the rest go on every one spawned")
	check(run_until(g, func(): return not g.enemies.is_empty(), 10.0), "it arrives")
	check(g.enemies[0].elite and g.enemies[0].mods == ["hasty"], "as an elite")
	var plain: Array = g.sandbox_spawn("grunt", 1)
	check(plain.is_empty() and g.spawn_queue.filter(func(s): return s.type == "grunt").all(func(s): return (s.mods as Array).is_empty()), "no toggles: a plain enemy")
	check(g.sandbox_spawn("juggernaut", 1, ["plated"]) == ["plated"], "a boss is never an elite")


## The balance probe's --mods switch: no elites, or only the listed modifiers.
func test_probe_mods_switch() -> void:
	var count := func(wave: int) -> Dictionary:
		var seen := {}
		for grp in Waves.get_wave(wave):
			for m in grp.get("m", []):
				seen[m] = true
		return seen
	var any := false
	for w in range(40, 61):
		any = any or not count.call(w).is_empty()
	check(any, "rounds 40-60 have elites by default")
	Waves.mods_only = []
	var none := true
	for w in range(40, 61):
		none = none and count.call(w).is_empty()
	check(none, "--mods=none: no elites")
	Waves.mods_only = ["hasty"]
	var only := true
	var some := false
	for w in range(40, 61):
		var seen: Dictionary = count.call(w)
		some = some or not seen.is_empty()
		only = only and seen.keys().all(func(m): return m == "hasty")
	Waves.mods_only = null
	check(some and only, "--mods=hasty: elites carry only Hasty")


## The balance master (issue #75): design/balance.md's generated columns agree with the game's own formulas.
func test_balance_master() -> void:
	var enemies := _balance_rows("<!-- table: enemies -->")
	check(enemies.size() == Enemies.ORDER.size(), "every enemy has a row in balance.md")
	for r in enemies:
		var id: String = r.Id
		check(absf(float(r["=Strength"]) - Enemies.strength(id)) < 0.06, "%s: =Strength matches Enemies.strength" % id)
		check(int(r["=Leak"]) == int(Enemies.ENEMIES[id].lives), "%s: =Leak is its leak cost" % id)
		check(is_equal_approx(float(r.HP), float(Enemies.ENEMIES[id].hp)), "%s: its health is the game's" % id)
	var scaling := _balance_rows("<!-- generated: enemy_scaling -->")
	for r in scaling:
		var id := ""
		for t in Enemies.ORDER:
			if str(Enemies.ENEMIES[t].name) == str(r.Enemy):
				id = t
		for w in [20, 60, 100, 120]:
			check(int(r["=HP r%d" % w]) == roundi(float(Enemies.ENEMIES[id].hp) * Waves.hp_scale(w)), "%s: =HP r%d matches Waves.hp_scale" % [id, w])
	var mods := _balance_rows("<!-- table: modifiers -->")
	check(mods.size() == Modifiers.ORDER.size(), "every modifier has a row")


## The rows of the balance.md table after `marker`, as {column header: cell}.
func _balance_rows(marker: String) -> Array:
	var text := FileAccess.get_file_as_string("res://design/balance.md").replace("\r\n", "\n")
	var at := text.find(marker)
	if at < 0:
		return []
	var lines := text.substr(at).split("\n")
	var head: Array = []
	var out: Array = []
	for i in range(1, lines.size()):
		var l: String = lines[i]
		if not l.begins_with("|"):
			if head.is_empty():
				continue
			break
		var c := Array(l.split("|")).slice(1, -1).map(func(x): return str(x).strip_edges())
		if head.is_empty():
			head = c
		elif not str(c[0]).begins_with("---"):
			var row := {}
			for k in head.size():
				row[head[k]] = c[k]
			out.append(row)
	return out


## The balance master's Waves section agrees with data/waves.gd's own functions.
func test_balance_master_waves() -> void:
	var rows := _balance_rows("<!-- generated: round_table -->")
	check(rows.size() >= 10, "the round table has its sample rounds")
	for r in rows:
		var w := int(r.Round)
		check(is_equal_approx(snappedf(Waves.hp_scale(w), 0.01), float(r["=HP ×"])), "round %d: =HP × matches Waves.hp_scale" % w)
		check(is_equal_approx(snappedf(Waves.speed_scale(w), 0.01), float(r["=Speed ×"])), "round %d: =Speed × matches" % w)
		check(absf(Waves.threat_budget(w) - float(r["=Budget"])) < 0.06, "round %d: =Budget matches" % w)
		check(roundi(Waves.elite_share(w) * 100.0) == int(str(r["=Elite share"]).trim_suffix("%")), "round %d: =Elite share matches" % w)
		check(Waves.clear_bonus(w) == int(r["=Clear bonus"]) and Waves.early_call_bonus(w) == int(r["=Early-call bonus"]), "round %d: the bonuses match" % w)
	for r in _balance_rows("<!-- table: round_makeup -->"):
		var id: String = r.Id
		check((r.Intro == "-") != Waves.INTRO.has(id) and (r.Intro == "-" or int(r.Intro) == int(Waves.INTRO[id])), "%s: Intro is the game's" % id)
		check(is_equal_approx(float(r.Threat), float(Waves.COST[id])), "%s: Threat is the game's" % id)


## The balance master's economy, difficulty and research sections agree with the game.
func test_balance_master_economy() -> void:
	var modes := _balance_rows("<!-- table: difficulty -->")
	check(modes.size() == Difficulty.ORDER.size(), "every mode has a row")
	for r in modes:
		var d: Dictionary = Difficulty.DIFFICULTIES[r.Id]
		check(int(r.Rounds) == int(d.rounds) and int(r.Shields) == int(d.lives) and is_equal_approx(float(r.Price), float(d.price)), "%s: its row is the game's" % r.Id)
	for r in _balance_rows("<!-- generated: mode_prices -->"):
		var type := ""
		for t in Towers.ORDER:
			if str(Towers.def(t).name) == str(r.Tower):
				type = t
		for m in Difficulty.ORDER:
			var want := Research.discounted(int(Towers.Rework.TREES[type].cost), {"price": Difficulty.price(m)})
			check(int(r["=" + str(Difficulty.DIFFICULTIES[m].name)]) == want, "%s on %s: =price is what the game charges" % [type, m])
	var nodes := _balance_rows("<!-- table: research -->")
	check(nodes.size() == ResearchData.NODES.size(), "every research node has a row")
	for r in nodes:
		check(int(r.RP) == int(ResearchData.NODES[r.Id].cost), "%s: its RP cost is the game's" % r.Id)


## Live tuner (issue #80): every number balance.md owns is a field; an edit reaches enemies on the field (health keeps
## its share), placed towers and prices; revert puts balance.md's values back; a tuned run can't be saved.
func test_live_tuner() -> void:
	var keys := {}
	for f in Tuner.fields():
		keys[f.key] = true
	var dicts := ["ENEMIES", "MODIFIERS", "DIFFICULTIES", "NODES", "ABILITIES", "INTRO", "COST", "SPACING", "MAX_COUNT", "BOSS_ROUNDS"]
	var consts := {}
	for t in ["rules", "wave_rules", "economy", "enemy_rules", "research_rules"]:
		for r in _balance_rows("<!-- table: %s -->" % t):
			var c := str(r.Constant).replace("`", "")
			consts[c.get_slice(".", 0) + ":" + c.substr(c.find(".") + 1)] = true
	check(consts.size() > 50, "the Rules tables are read")
	for k in consts:
		check(keys.has(k), "%s is tunable" % k)
	for k in keys:
		if not str(k).begins_with("Towers:") and not dicts.has(str(k).get_slice(":", 1).get_slice(".", 0)):
			check(consts.has(k), "%s is a row in balance.md" % k)
	for r in _balance_rows("<!-- table: enemies -->"):
		check(keys.has("Enemies:ENEMIES.%s.hp" % r.Id), "%s's HP is tunable" % r.Id)
	check(keys.has("Towers:gun_turret.a1.damage") and keys.has("Towers:gun_turret.base.cost"), "tower nodes are tunable")
	check(not keys.has("Enemies:ENEMIES.grunt.lives") and not keys.has("Enemies:ENEMIES.colossus.phases.0"), "derived and non-balance numbers aren't")
	check(Tuner.changes().is_empty(), "nothing is changed to start with")

	var g = new_game("meadow")
	g.gold = 5000
	Tuner.attach(g)
	var hp0 := int(Enemies.ENEMIES.grunt.hp)
	var e = put(g, "grunt", 40.0, 0, 2.0)
	e.hp = e.max_hp * 0.5
	var elite = g.spawn_enemy("grunt", 0, 60.0, 1.0, -1, 1.0, ["plated"])
	g.enemies.append(elite)
	var armor0: float = elite.armor
	var t = g.place_tower("gun_turret", Vector2i(2, 3))
	var dmg0: float = t.stats().damage
	var cost0: int = g.tower_cost("gun_turret")
	check(Tuner.set_value("Enemies:ENEMIES.grunt.hp", 300.0), "an enemy's HP is set")
	check(is_equal_approx(e.max_hp, 600.0) and is_equal_approx(e.hp, 300.0), "a Drone on the field takes it and keeps its share of health")
	check(int(Enemies.ENEMIES.grunt.lives) == 2 and e.lives_cost == 2 and elite.lives_cost == 3, "its leak cost follows its strength")
	check(g.tuned and not g.can_save(), "the run is tuned: it can't be saved")
	Tuner.set_value("Enemies:ENEMIES.grunt.armor", 2.0)
	check(is_equal_approx(elite.armor, armor0 + 2.0), "an elite's armor moves by the change")
	Tuner.set_value("Towers:gun_turret.base.damage", 20.0)
	check(t.stats().damage > dmg0, "a placed tower takes a damage change")
	Tuner.set_value("Towers:gun_turret.base.cost", 100.0)
	check(int(Tower.Rework.TREES.gun_turret.cost) == 100 and g.tower_cost("gun_turret") > cost0, "a price change reaches the shop")
	Tuner.set_value("Difficulty:DIFFICULTIES.%s.price" % g.difficulty, 2.0)
	check(is_equal_approx(float(g.tower_mods.gun_turret.price), 2.0), "the mode's price multiplier reaches the run")
	check(not Tuner.set_value("Enemies:ENEMIES.grunt.nope", 1.0), "an unknown key is refused")
	var ch: Array = Tuner.changes()
	check(ch.size() == 5 and int(ch[0].old) == hp0 and int(ch[0].new) == 300, "the changes list old and new values")
	Tuner.revert_all()
	check(Tuner.changes().is_empty() and int(Enemies.ENEMIES.grunt.hp) == hp0 and int(Enemies.ENEMIES.grunt.lives) == 1, "revert puts balance.md's values back")
	check(is_equal_approx(e.max_hp, hp0 * 2.0) and is_equal_approx(elite.armor, armor0), "and the field follows")
	check(is_equal_approx(t.stats().damage, dmg0) and g.tower_cost("gun_turret") == cost0, "and the towers and prices")
	Tuner.attach(null)


## Live tuner (issue #80): its derived values are balance.md's = columns, and its panel lists, edits, reverts and exports.
func test_live_tuner_panel() -> void:
	for slug in Towers.Rework.ORDER:
		var want := {}
		for r in _balance_rows("### %s\n" % slug):
			want[r.Node] = r
		for row in Tuner.tower_rows(slug):
			var w: Dictionary = want.get(row.id, {})
			# Compared as numbers: printf rounds a half to even on Linux (56.25 → 56.2), balance.mjs and Windows up.
			var same: bool = not w.is_empty() and (str(w["=DPS"]) == "-" if row.dps < 0.0 else absf(float(w["=DPS"]) - row.dps) <= 0.0501)
			check(same and int(w["=Spent"]) == row.spent, "%s %s: =DPS %.2f and =Spent %d are balance.md's" % [slug, row.id, row.dps, row.spent])
	for r in _balance_rows("<!-- table: enemies -->"):
		var e := Tuner.enemy_info(r.Id)
		check(absf(float(r["=Strength"]) - e.strength) <= 0.0501 and e.leak == int(r["=Leak"]), "%s: =Strength and =Leak are balance.md's" % r.Id)

	var g = new_game("meadow")
	Tuner.attach(g)
	put(g, "grunt", 40.0)
	var p = TunerPanel.new()
	add_child(p)
	check(p._areas.enemies.groups.size() == Enemies.ENEMIES.size() and p._areas.towers.groups.size() == Towers.Rework.ORDER.size(), "every enemy and tower has a group")
	p._search.text = "proj_speed"
	p._fill_lists()
	check(p._areas.towers.groups.size() > 0 and p._areas.enemies.groups.is_empty(), "the search keeps groups with a matching number")
	p._search.text = ""
	p._fill_lists()
	p._refresh_readout()
	check("Round 0" in p._readout.text and "Drone ×1" in p._field.text, "the readout shows the round and the field")
	var edit := LineEdit.new()
	edit.text = "90"
	p._commit("Enemies:ENEMIES.grunt.hp", edit)
	check(int(Enemies.ENEMIES.grunt.hp) == 90 and Tuner.changes().size() == 1, "a value typed in is applied")
	p._nudge("Enemies:ENEMIES.grunt.hp", 1.0)
	check(int(Enemies.ENEMIES.grunt.hp) == 91, "+ steps a whole number by 1")
	p._nudge("Waves:HP_LINEAR", -1.0)
	check(Tuner.changed("Waves:HP_LINEAR"), "− steps a decimal")
	p._tabs.current_tab = p.TABS.size()
	check(p._changes.get_child_count() == 3, "the Changes tab lists them")
	var dir := SANDBOX + "tweaks"
	var path := Tuner.export_changes(dir)
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	check(data is Dictionary and data.changes.size() == 2 and str(data.changes[0].key) == "Enemies:ENEMIES.grunt.hp" and int(data.changes[0].new) == 91, "export writes the changes")
	p._revert_all()
	check(Tuner.changes().is_empty() and int(Enemies.ENEMIES.grunt.hp) == 70, "revert all")
	check(Tuner.export_changes(dir) == "", "nothing to export once reverted")
	edit.free()
	p.free()
	Tuner.attach(null)
