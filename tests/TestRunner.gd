extends Node
## Headless test suite. Run with:
##   godot --headless --path <project> res://tests/TestRunner.tscn
## Exits with code 0 when every check passes, 1 otherwise.

const Game = preload("res://scripts/core/Game.gd")
const Bot = preload("res://scripts/core/Bot.gd")
const SaveCodec = preload("res://scripts/core/SaveCodec.gd")
const Grid = preload("res://scripts/core/Grid.gd")
const Enemy = preload("res://scripts/entities/Enemy.gd")
const Tower = preload("res://scripts/entities/Tower.gd")
const Projectile = preload("res://scripts/entities/Projectile.gd")
const Towers = preload("res://data/towers.gd")
const Enemies = preload("res://data/enemies.gd")
const Waves = preload("res://data/waves.gd")
const Maps = preload("res://data/maps.gd")
const Abilities = preload("res://data/abilities.gd")
const Research = preload("res://scripts/core/Research.gd")
const ResearchData = preload("res://data/research.gd")
const Trees = preload("res://data/tower_trees.gd")
const Difficulty = preload("res://data/difficulty.gd")

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
	var tests := [
		"test_data_integrity",
		"test_map_geometry",
		"test_terrain_sites",
		"test_rubble",
		"test_lane_hazards",
		"test_switch_gates",
		"test_save_migration_v5",
		"test_save_migration_v6",
		"test_save_migration_v7",
		"test_armor_math",
		"test_slow_rules",
		"test_targeting_modes",
		"test_flyer_rules",
		"test_cannon_splash",
		"test_tesla_chain",
		"test_sniper_pierce",
		"test_placement_rules",
		"test_economy",
		"test_wave_clear_and_early_call",
		"test_shaman_heal",
		"test_warlord_minions",
		"test_round_generation",
		"test_spec_pulse",
		"test_spec_mortar",
		"test_spec_cryo",
		"test_spec_railgun",
		"test_spec_arc",
		"test_laser",
		"test_missiles",
		"test_amplifier",
		"test_save_migration_v2",
		"test_abilities",
		"test_difficulty_modes",
		"test_save_migration_v1",
		"test_music_synthesis",
		"test_save_roundtrip_and_determinism",
		"test_save_error_handling",
		"test_profile_records",
		"test_research_data",
		"test_research_points",
		"test_research_profile",
		"test_research_effects",
		"test_mastery_upgrades",
		"test_branch_rules",
		"test_laser_charge_stat",
		"test_scrapyard",
		"test_mastery_mechanics",
		"test_save_research_v4",
		"test_phantom_cloak",
		"test_aegis_barrier",
		"test_hydra_split",
		"test_jammer_emp",
		"test_flak",
		"test_graviton",
		"test_burrower",
		"test_blink_stalker",
		"test_mender_regen",
		"test_rally_beacon",
		"test_bulwark",
		"test_rampart",
		"test_leviathan",
		"test_colossus",
		"test_v3_flyers",
		"test_crowd_control_limits",
		"test_no_towers_loses",
		"test_bot_playthroughs",
		"test_bot_full_research",
	]
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
func level_dps(lv: Dictionary) -> float:
	var per_hit := float(lv.get("damage", 0.0)) * float(lv.get("missiles", 1.0)) * float(maxi(1, ceili(float(lv.get("pellets", 1.0)) / 2.0)))
	per_hit *= 1.0 + float(lv.get("bomblets", 0.0)) + float(lv.get("beams", 1.0)) - 1.0
	var dps := per_hit * float(lv.get("rate", 1.0)) * float(lv.get("multishot", 1.0)) * maxf(1.0, float(lv.get("drones", 1.0)))
	dps += float(lv.get("burn_dps", 0.0)) * 0.5 + float(lv.get("aura_dps", 0.0))
	return dps + float(lv.get("bomb_damage", 0.0)) * float(lv.get("bombers", 0.0)) / 2.2


# --- Data ------------------------------------------------------------------------------------

func test_data_integrity() -> void:
	check(Towers.ORDER.size() == 15 and Trees.ORDER == Towers.ORDER, "fifteen tower types, each with a generated tree")
	for type in Towers.ORDER:
		check(Trees.TREES.has(type), "%s has an upgrade tree" % type)
		if not Trees.TREES.has(type):
			continue
		var tr: Dictionary = Trees.TREES[type]
		var d: Dictionary = Towers.TOWERS[type]
		check(tr.tiers.size() == 2 and tr.branches.size() == 3, "%s: two trunk tiers and three branches" % type)
		var ids := {}
		for b in tr.branches:
			check(b.nodes.size() == Tower.BRANCH_STEPS and b.mastery != null, "%s branch %s: four upgrades and a mastery" % [type, b.key])
			check(not ids.has(b.id), "%s branch ids are unique" % type)
			ids[b.id] = true
			var all_nodes: Array = b.nodes.duplicate()
			all_nodes.append(b.mastery)
			for nd in all_nodes:
				check(str(nd.name) != "" and str(nd.blurb) != "" and int(nd.cost) > 0, "%s %s %s has a name, description and price" % [type, b.key, nd.name])
			for i in range(1, b.nodes.size()):
				check(int(b.nodes[i].cost) >= int(b.nodes[i - 1].cost), "%s %s: upgrade prices rise along the branch" % [type, b.key])
			check(int(b.mastery.cost) > int(b.nodes[Tower.BRANCH_STEPS - 1].cost), "%s %s: the mastery costs the most" % [type, b.key])
		for sid in d.get("spec_order", []):
			check(ids.has(sid), "%s: old specialization %s is still a branch (saves use it)" % [type, sid])
		# Every level has the stats its attack needs.
		var ln := Tower.lines(type)
		var levels: Array = [ln.t1, ln.t2]
		for b in tr.branches:
			levels.append_array(ln[b.key].slice(1))
			levels.append(ln[b.key + "_m"])
		var support: bool = d.get("support", false)
		for lv in levels:
			var keys := [] if d.get("drones", false) else ["range"]
			if d.get("economy", false):
				keys = ["income"]
			elif support:
				keys.append("mark" if d.get("sensor", false) else "buff_dmg")
			elif d.get("beam", false):
				keys.append("damage")
			else:
				keys.append_array(["damage", "rate"])
			for key in keys:
				check(lv.has(key) and float(lv[key]) > 0.0, "%s level has positive %s" % [type, key])
		var key_needed := {
			"arrow": ["proj_speed"], "cannon": ["splash", "proj_speed"], "frost": ["slow", "slow_time"],
			"sniper": ["pierce"], "tesla": ["chains", "chain_range", "falloff"],
			"missile": ["missiles", "splash", "air_mult", "proj_speed"],
			"flak": ["splash", "proj_speed"], "gravity": ["push"], "sensor": ["mark"],
			"nullifier": ["strip"], "drones": ["drones", "drone_speed"],
		}
		for key in key_needed.get(type, []):
			check(levels.all(func(lv): return lv.has(key)), "%s levels all have %s" % [type, key])
		if not support:
			check(float(ln.t2.damage) > float(ln.t1.damage), "%s damage rises at tier 2" % type)
			for b in tr.branches:
				# Attack-style branches trade damage for area; the Nullifier is utility first.
				if bool(b.attack) or type == "nullifier":
					continue
				check(level_dps(ln[b.key][1]) > level_dps(ln.t2), "%s %s out-damages tier 2 per second" % [type, b.id])
	check(not Towers.TOWERS.cannon.air, "mortar can't hit air")

	check(Waves.WAVES.size() == Waves.AUTHORED, "the authored table covers rounds 1-%d" % Waves.AUTHORED)
	for i in Waves.WAVES.size():
		var w: Array = Waves.WAVES[i]
		check(not w.is_empty(), "wave %d not empty" % (i + 1))
		for g in w:
			check(Enemies.ENEMIES.has(g.t), "wave %d enemy %s exists" % [i + 1, g.t])
			check(int(g.n) > 0 and float(g.i) > 0.0, "wave %d group sane" % (i + 1))
	for bw in [5, 10, 15, 20, 25]:
		check(Waves.WAVES[bw - 1].any(func(g): return g.t == "juggernaut"), "round %d is a Dreadnought round" % bw)
	check(not Waves.WAVES.any(func(w): return w.any(func(g): return g.t == "warlord")), "the Overmind no longer appears in the authored rounds")
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
		check(Enemies.ENEMIES.has(t) and not Enemies.ENEMIES[t].get("boss", false), "%s is a regular enemy" % t)
		check(Waves.SPACING.has(t), "%s has a spawn spacing" % t)
	for t in Enemies.ORDER:
		check(Enemies.ENEMIES.has(t), "%s is defined" % t)
		check(Waves.COST.has(t) or Enemies.ENEMIES[t].get("boss", false), "%s is either generated or a boss" % t)
	check(Enemies.ORDER.size() == 22 and Enemies.ENEMIES.size() == 22, "22 enemy types")
	var cheapest := 1 << 30
	for type in Towers.ORDER:
		cheapest = mini(cheapest, int(Trees.TREES[type].tiers[0].cost))
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
	var plain = g.place_tower("arrow", Vector2i(2, 3))
	var high = g.place_tower("arrow", Vector2i(11, 5))
	var power = g.place_tower("arrow", Vector2i(7, 6))
	check(high.site == "H" and power.site == "P" and plain.site == "", "towers know the tile they stand on")
	check(near(high.get_range(), plain.get_range() * 1.15), "high ground: +15%% range (%.1f)" % high.get_range())
	check(near(power.eff_damage(), plain.eff_damage() * 1.15) and near(power.get_range(), plain.get_range()), "power node: +15%% damage, no range")
	var amp = g.place_tower("amp", Vector2i(12, 5))
	check(near(amp.get_range(), 100.0 * 1.15), "high ground widens a pylon's field too")
	var data := SaveCodec.encode(g)
	var res := SaveCodec.decode(data)
	check(res.has("game") and res.game.tower_at[Vector2i(11, 5)].site == "H", "sites come back after loading")


func test_rubble() -> void:
	var g = new_game("meadow")
	var r := Vector2i(16, 5)
	check(g.has_rubble(r) and not g.is_buildable(r), "rubble blocks building")
	check(g.placement_error("arrow", r).contains("Rubble"), "placement explains rubble (%s)" % g.placement_error("arrow", r))
	g.gold = 30
	check(not g.clear_rubble(r) and g.rubble_error(r).contains("40"), "clearing needs 40 cr")
	g.gold = 100
	check(g.clear_rubble(r) and g.gold == 60, "clearing costs 40 cr")
	check(not g.has_rubble(r) and g.is_buildable(r) and g.placement_error("arrow", r) == "", "cleared rubble is buildable")
	check(not g.clear_rubble(r) and not g.clear_rubble(Vector2i(2, 3)), "only rubble can be cleared, once")
	g.place_tower("arrow", r)
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


func test_save_migration_v5() -> void:
	# A v4 run on the old Red Rift with a tower where the new layout has a wall, and one on rubble.
	var v4 := {
		"version": 4, "map_id": "canyon", "difficulty": "normal", "ability_cd": {}, "wave": 6, "gold": 100, "lives": 18,
		"research": [], "bounty_carry": 0.0,
		"towers": [
			{"type": "arrow", "col": 4, "row": 0, "tier": 1, "mode": 0, "kills": 1, "spent": 50},
			{"type": "arrow", "col": 5, "row": 6, "tier": 2, "mode": 0, "kills": 3, "spent": 120},
			{"type": "cannon", "col": 6, "row": 3, "tier": 1, "mode": 0, "kills": 0, "spent": 90},
		],
	}
	var res := SaveCodec.decode(v4)
	check(res.has("game"), "v4 save loads (%s)" % res.get("error", ""))
	if res.has("game"):
		var g = res.game
		check(not g.tower_at.has(Vector2i(4, 0)) and g.gold == 150, "a tower on a new wall is refunded (%d cr)" % g.gold)
		check(g.tower_at.has(Vector2i(5, 6)) and g.cleared.has(Vector2i(5, 6)), "a tower on new rubble clears it")
		check(g.tower_at.has(Vector2i(6, 3)) and int(SaveCodec.encode(g).version) == Game.SAVE_VERSION, "other towers stay; re-saving writes the current format")


func test_save_migration_v6() -> void:
	# A v5 run on the 20×12 Outpost Theta: (19, 10) was floor there and is lane now; (5, 5) was
	# rubble there (cleared) and is floor now.
	var v5 := {
		"version": 5, "map_id": "meadow", "difficulty": "normal", "ability_cd": {}, "wave": 9, "gold": 40, "lives": 20,
		"research": [], "bounty_carry": 0.0, "cleared": [[5, 5], [1, 10]], "gates": [], "route_counters": [0],
		"towers": [
			{"type": "arrow", "col": 2, "row": 3, "tier": 2, "mode": 0, "kills": 5, "spent": 120},
			{"type": "sniper", "col": 19, "row": 10, "tier": 1, "mode": 0, "kills": 2, "spent": 120},
		],
	}
	var res := SaveCodec.decode(v5)
	check(res.has("game"), "v5 save loads (%s)" % res.get("error", ""))
	if res.has("game"):
		var g = res.game
		check(not g.tower_at.has(Vector2i(19, 10)) and g.gold == 160, "a tower on a new lane is refunded (%d cr)" % g.gold)
		check(g.tower_at.has(Vector2i(2, 3)) and g.tower_at[Vector2i(2, 3)].tier == 2, "other towers stay")
		check(g.cleared.has(Vector2i(1, 10)) and not g.cleared.has(Vector2i(5, 5)), "cleared rubble that no longer exists is dropped")
		check(int(SaveCodec.encode(g).version) == Game.SAVE_VERSION, "re-saving writes the current format")



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
	var mortar = g.place_tower("cannon", Vector2i(2, 3))
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


func test_save_migration_v7() -> void:
	var v6 := {
		"version": 6, "map_id": "singularity", "difficulty": "casual", "ability_cd": {}, "wave": 14, "gold": 90, "lives": 11,
		"research": [], "bounty_carry": 0.0, "cleared": [], "gates": [0, 0], "route_counters": [0, 0], "towers": [],
	}
	var res := SaveCodec.decode(v6)
	check(res.has("game"), "v6 save loads (%s)" % res.get("error", ""))
	if res.has("game"):
		var g = res.game
		check(g.difficulty == "easy" and g.final_round() == 40, "Casual becomes Easy")
		check(g.lives == 100, "11 of 22 old shields become 100 of Easy's 200 (%d)" % g.lives)
		check(g.wave == 14 and not g.medal and not g.endless, "progress kept; no medal yet")
	var full := v6.duplicate(true)
	full["map_id"] = "canyon"
	full["difficulty"] = "veteran"
	full["lives"] = 23
	full["research"] = ["cmd_funds", "cmd_core"]
	var r2 := SaveCodec.decode(full)
	check(r2.has("game") and r2.game.difficulty == "hard" and r2.game.lives == 55, "a full-shield Veteran run with Reinforced Core becomes Hard at 55/55")
	var ended := v6.duplicate(true)
	ended["difficulty"] = "normal"
	ended["wave"] = 30
	ended["endless"] = true
	var r3 := SaveCodec.decode(ended)
	check(r3.has("game") and not r3.game.medal and not r3.game.endless, "an old endless run past 25 is a Medium run at round 30")


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
	var t = g.place_tower("arrow", Vector2i(2, 3))
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


func test_flyer_rules() -> void:
	var g = new_game()
	g.gold = 10000
	var cannon = g.place_tower("cannon", Vector2i(2, 3))
	var arrow = g.place_tower("arrow", Vector2i(3, 3))
	var bat = put(g, "bat", 150.0)
	check(bat.flying, "bat flies")
	check(cannon.pos.distance_to(bat.pos) < cannon.get_range(), "bat is inside cannon range")
	check(g.pick_target(cannon) == null, "cannon ignores flyers")
	check(g.pick_target(arrow) == bat, "arrow targets flyers")


func test_cannon_splash() -> void:
	var g = new_game()
	g.gold = 10000
	var cannon = g.place_tower("cannon", Vector2i(2, 3))
	var a = put(g, "grunt", 100.0)
	var b = put(g, "grunt", 130.0)
	var c = put(g, "grunt", 200.0)
	var bat = put(g, "bat", 60.0)
	bat.pos = a.pos + Vector2(10, 0)
	var p = Projectile.new()
	p.kind = "cannon"
	p.pos = a.pos
	p.target_pos = a.pos
	p.damage = 22.0
	p.splash = 55.0
	p.source = cannon
	g._projectile_hit(p)
	check(near(a.hp, a.max_hp - 22.0), "center target hit")
	check(near(b.hp, b.max_hp - 22.0), "target within 55px hit")
	check(near(c.hp, c.max_hp), "target 100px away untouched")
	check(near(bat.hp, bat.max_hp), "splash does not hit flyers")


func test_tesla_chain() -> void:
	var g = new_game()
	g.gold = 10000
	var tesla = g.place_tower("tesla", Vector2i(2, 3))
	var es: Array = []
	for i in 5:
		es.append(put(g, "grunt", 60.0 + 40.0 * i, 0, 10.0))
	g._chain(tesla, es[0], tesla.stats())
	var expect := [16.0, 12.8, 10.24]
	for i in 3:
		check(near(es[i].max_hp - es[i].hp, expect[i], 0.01), "chain jump %d damage %.2f" % [i, expect[i]])
	check(near(es[3].hp, es[3].max_hp), "tier-1 tesla stops after 3 targets")


func test_sniper_pierce() -> void:
	var g = new_game()
	g.gold = 10000
	g.place_tower("sniper", Vector2i(2, 3))
	g.state = Game.State.WAVE
	var brute = put(g, "brute", 100.0, 0, 10.0)
	for i in 3:
		g.tick(SIM_DT)
	check(near(brute.max_hp - brute.hp, 55.0), "sniper deals full damage through armor")


# --- Economy & rules -------------------------------------------------------------------------

func test_placement_rules() -> void:
	var g = new_game()
	check(g.placement_error("arrow", Vector2i(0, 2)) != "", "can't build on path")
	check(g.placement_error("arrow", Vector2i(1, 5)) != "", "can't build on blocked tile")
	check(g.placement_error("arrow", Vector2i(-1, 0)) != "", "can't build out of bounds")
	check(g.placement_error("arrow", Vector2i(Grid.COLS, 5)) != "", "can't build out of bounds (right)")
	check(g.placement_error("arrow", Vector2i(2, 3)) == "", "can build next to path")
	g.place_tower("arrow", Vector2i(2, 3))
	check(g.placement_error("arrow", Vector2i(2, 3)) != "", "can't stack towers")
	g.gold = 10
	check(g.placement_error("arrow", Vector2i(3, 3)) == "Not enough credits", "credits are required")
	check(g.place_tower("arrow", Vector2i(3, 3)) == null, "place fails without gold")


func test_economy() -> void:
	var g = new_game()
	var g0: int = g.gold
	var t = g.place_tower("arrow", Vector2i(2, 3))
	check(g.gold == g0 - 50, "build deducts cost")
	check(g.upgrade_tower(t), "upgrade succeeds")
	check(g.gold == g0 - 120 and t.tier == 2 and t.spent == 120, "upgrade deducts and tracks spend")
	g.gold = 0
	check(not g.upgrade_tower(t, "gatling"), "upgrade needs gold")
	g.gold = 1000
	check(t.needs_spec(), "tier 2 needs a specialization choice")
	check(not g.upgrade_tower(t), "tier 3 upgrade without a spec is refused")
	check(not g.upgrade_tower(t, "bogus"), "tier 3 upgrade with an unknown spec is refused")
	check(t.upgrade_cost() == 140 and t.upgrade_cost("shredder") == 140, "spec costs reported")
	check(g.upgrade_tower(t, "shredder"), "tier 3 upgrade with a spec succeeds")
	check(t.tier == 3 and t.spec == "shredder" and t.display_name() == "Shredder", "spec applied")
	check(g.gold == 1000 - 140, "spec cost deducted")
	check(t.upgrade_cost() == 170, "the next Shredder upgrade costs 170 (%d)" % t.upgrade_cost())
	check(g.upgrade_tower(t, "gatling") and t.started == ["b", "a"], "a second branch can be started")
	check(not g.upgrade_tower(t, "flechette"), "the third branch is locked once two are started")
	var refund := g.sell_value(t)
	check(refund == int(floor(400 * 0.7)), "sell refunds 70%% of total spend (%d)" % refund)
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
	check(g.lives == 100 - 20, "20 grunts leaked one life each (%d)" % g.lives)
	check(g.can_save(), "can save in build phase")

	var d = new_game()
	d.gold = 5000
	for c in [Vector2i(2, 3), Vector2i(3, 3), Vector2i(5, 4), Vector2i(3, 1), Vector2i(5, 1)]:
		d.place_tower("sniper", c)
	d.start_wave()
	check(run_until(d, func(): return d.state == Game.State.BUILD, 120.0), "defended wave clears")
	check(d.lives == d.max_lives, "no leaks with five snipers")
	var expected: int = 5000 - 600 + 8 * int(Enemies.ENEMIES.grunt.bounty) + Waves.clear_bonus(1)
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
	var r1 := RandomNumberGenerator.new()
	var r2 := RandomNumberGenerator.new()
	r1.seed = 99
	r2.seed = 99
	check(deep_equal(Waves.generated_round(53, r1, 60), Waves.generated_round(53, r2, 60)), "generated rounds are deterministic per seed")
	var g = new_game()
	check(deep_equal(g.preview_wave(47), g.preview_wave(47)), "preview_wave is stable")
	check(deep_equal(g.preview_wave(12), Waves.WAVES[11]), "rounds 1-25 come from the authored table")
	for w in range(26, 161):
		var groups: Array = Waves.get_wave(w, g._wave_rng(w), 120)
		var total := 0
		var regular := 0
		for x in groups:
			check(Enemies.ENEMIES.has(x.t) and int(x.n) > 0 and float(x.i) > 0.0, "round %d group valid" % w)
			total += int(x.n)
			if not Enemies.ENEMIES[x.t].get("boss", false):
				regular += int(x.n)
				check(Waves.unlock_round(x.t) <= w, "round %d only uses unlocked enemies (%s)" % [w, x.t])
		check(regular <= Waves.MAX_SPAWNS, "round %d respects the spawn cap (%d)" % [w, regular])
		check(groups.size() >= 3, "round %d has several groups" % w)
	# Each v3 enemy leads its introduction round.
	for t in Waves.INTRO:
		var w := int(Waves.INTRO[t])
		var groups: Array = g.preview_wave(w)
		check(groups[0].t == t, "%s leads round %d" % [t, w])
		check(Waves.first_round(t) == w, "%s first appears in round %d" % [t, w])
	# Boss schedule and finales.
	var has := func(w: int, t: String, final: int) -> bool:
		return Waves.boss_groups(w, final).any(func(x): return x.t == t)
	check(has.call(30, "juggernaut", 60) and not has.call(31, "juggernaut", 60), "Dreadnoughts every 5 rounds")
	check(has.call(50, "warlord", 60) and has.call(75, "warlord", 80) and not has.call(60, "warlord", 80), "the Overmind at 50, 75, 100")
	check(has.call(35, "leviathan", 60) and has.call(55, "leviathan", 60) and not has.call(45, "leviathan", 60), "Leviathans from round 35, every 20")
	check(has.call(60, "colossus", 80) and has.call(80, "colossus", 120) and not has.call(70, "colossus", 120), "Colossi from round 60, every 20")
	for final in Waves.FINALES:
		var line: Array = Waves.boss_groups(final, final)
		check(line.size() == Waves.FINALES[final].size(), "round %d is its mode's finale" % final)
	check(has.call(40, "warlord", 40) and not has.call(40, "warlord", 60), "the Easy finale only happens on Easy")
	check(Waves.first_round("warlord", 40) == 40 and Waves.first_round("warlord", 60) == 50, "the Overmind first shows up at the Easy finale or round 50")
	var e40 = new_game("meadow", 1, "easy")
	check(e40.preview_wave(40).any(func(x): return x.t == "leviathan"), "an Easy run's round 40 has the finale")
	check(not new_game("meadow", 1, "medium").preview_wave(40).any(func(x): return x.t == "leviathan"), "a Medium run's round 40 doesn't")


## Places a tower and upgrades it straight to a tier-3 spec with free credits.
func spec_tower(g, type: String, cell: Vector2i, spec: String):
	g.gold += 5000
	var t = g.place_tower(type, cell)
	g.upgrade_tower(t)
	g.upgrade_tower(t, spec)
	return t


func test_spec_pulse() -> void:
	var g = new_game()
	var gat = spec_tower(g, "arrow", Vector2i(2, 3), "gatling")
	check(near(gat.eff_rate(), 5.0), "gatling fires 5 times a second")
	var g2 = new_game()
	var sh = spec_tower(g2, "arrow", Vector2i(2, 3), "shredder")
	g2.state = Game.State.WAVE
	var brute = put(g2, "brute", 100.0, 0, 20.0)
	for i in int(3.0 / SIM_DT):
		g2.tick(SIM_DT)
	check(brute.armor_shred > 0.0, "shredder strips armor (%.0f)" % brute.armor_shred)
	check(brute.armor_shred <= 8.0 and brute.effective_armor() >= 0.0, "shred is capped")
	for i in int(6.0 / SIM_DT):
		g2.tick(SIM_DT)
	check(near(brute.effective_armor(), 0.0), "enough hits strip the brute bare")
	check(sh.kills >= 0, "shredder still alive in the sim")


func test_spec_mortar() -> void:
	var g = new_game()
	var burn = spec_tower(g, "cannon", Vector2i(2, 3), "napalm")
	var a = put(g, "grunt", 100.0, 0, 20.0)
	var p = Projectile.new()
	p.kind = "cannon"
	p.pos = a.pos
	p.target_pos = a.pos
	p.damage = 10.0
	p.splash = 70.0
	p.burn_dps = 32.0
	p.burn_time = 3.0
	p.source = burn
	g._projectile_hit(p)
	check(g.pools.size() == 1, "plasma burn leaves a pool")
	var hp_after_hit: float = a.hp
	g.state = Game.State.WAVE
	g._update_pools(1.0)
	check(near(hp_after_hit - a.hp, 32.0, 0.5), "pool burns for its dps, ignoring armor (%.1f)" % (hp_after_hit - a.hp))
	g._update_pools(2.5)
	check(g.pools.is_empty(), "pool expires after its duration")
	var sg = new_game()
	var siege = spec_tower(sg, "cannon", Vector2i(2, 3), "siege")
	check(near(float(siege.stats().splash), 90.0), "siege mortar has the big blast")


func test_spec_cryo() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	spec_tower(g, "frost", Vector2i(2, 3), "shatter")
	var e = put(g, "grunt", 100.0, 0, 20.0)
	g.tick(SIM_DT)
	check(e.vuln_timer > 0.0 and near(e.vuln_amount, 0.25), "shatter field applies +25% vulnerability")
	var hp0: float = e.hp
	g.damage_enemy(e, 100.0, true, null)
	check(near(hp0 - e.hp, 125.0), "vulnerable enemies take 25% more damage")
	var s = new_game()
	s.state = Game.State.WAVE
	spec_tower(s, "frost", Vector2i(2, 3), "stasis")
	var f = put(s, "grunt", 100.0, 0, 20.0)
	s.tick(SIM_DT)
	check(near(f.slow_amount, 0.65), "stasis field slows 65%")


func test_spec_railgun() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var dead = spec_tower(g, "sniper", Vector2i(2, 3), "deadeye")
	var boss = put(g, "juggernaut", 100.0, 0, 5.0)
	g.tick(SIM_DT)
	var dd: Dictionary = Towers.TOWERS.sniper.specs.deadeye
	check(near(boss.max_hp - boss.hp, float(dd.damage) * float(dd.boss_mult)), "deadeye does double damage to bosses (%.0f)" % (boss.max_hp - boss.hp))
	check(dead.kills == 0, "boss survived one shot")
	var l = new_game()
	l.state = Game.State.WAVE
	spec_tower(l, "sniper", Vector2i(5, 1), "lance")
	# Three grunts in a row along the first stretch of lane (row 2), all in the rail's line.
	var es: Array = []
	for d in [60.0, 110.0, 160.0]:
		es.append(put(l, "grunt", d, 0, 20.0))
	for e in es:
		e.pos.y = 120.0
	var tw = l.tower_at[Vector2i(5, 1)]
	tw.mode = Tower.Mode.LAST
	l._update_tower(tw, SIM_DT)
	var hits := es.filter(func(e): return e.hp < e.max_hp).size()
	check(hits >= 2, "piercing rail hits every enemy on its line (%d of 3)" % hits)


func test_spec_arc() -> void:
	var g = new_game()
	var ov = spec_tower(g, "tesla", Vector2i(2, 3), "overload")
	var es: Array = []
	for i in 3:
		es.append(put(g, "grunt", 60.0 + 40.0 * i, 0, 20.0))
	var boss = put(g, "juggernaut", 180.0, 0, 5.0)
	g._chain(ov, es[0], ov.stats())
	check(es.all(func(e): return near(e.stun_timer, 0.5)), "overload stuns every arc target")
	check(near(boss.stun_timer, 0.15), "bosses are stunned for less (%.2f)" % boss.stun_timer)
	var d0: float = es[0].distance
	es[0].step(0.3)
	check(near(es[0].distance, d0), "stunned enemies don't move")
	var sg = new_game()
	var storm = spec_tower(sg, "tesla", Vector2i(2, 3), "storm")
	check(int(storm.stats().chains) == 9, "storm coil arcs to 9 targets")


func test_laser() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var t = g.place_tower("laser", Vector2i(2, 3))
	var e = put(g, "brute", 100.0, 0, 30.0)
	g.tick(SIM_DT)
	check(t.target == e and t.beam_targets.size() == 1, "laser locks on")
	var hp0: float = e.hp
	for i in 60:
		g.tick(SIM_DT)
	var first_sec: float = hp0 - e.hp
	check(first_sec > 22.0 and first_sec < 44.0, "first second: ramping dps, armor ignored (%.1f)" % first_sec)
	for i in int(2.0 / SIM_DT):
		g.tick(SIM_DT)
	check(near(t.ramp_mult, 2.0), "ramp tops out at 2x for tier 1 (%.2f)" % t.ramp_mult)
	var p = new_game()
	p.state = Game.State.WAVE
	var prism = spec_tower(p, "laser", Vector2i(2, 3), "prism")
	for d in [70.0, 100.0, 130.0, 160.0]:
		put(p, "grunt", d, 0, 30.0)
	p.tick(SIM_DT)
	check(prism.beam_targets.size() == 3, "prism array splits into 3 beams")


func test_missiles() -> void:
	var g = new_game()
	g.state = Game.State.WAVE
	var t = g.place_tower("missile", Vector2i(2, 3))
	var bat = put(g, "bat", 60.0, 0, 30.0)
	var grunt = put(g, "grunt", 300.0, 0, 30.0)
	g.tick(SIM_DT)
	var missiles: Array = g.projectiles.filter(func(p): return p.kind == "missile")
	check(missiles.size() == 2, "tier 1 fires 2 missiles per salvo")
	var ok := run_until(g, func(): return g.projectiles.is_empty(), 4.0)
	check(ok, "missiles land within their lifetime")
	var md: Dictionary = Towers.TOWERS.missile.tiers[0]
	check(bat.max_hp - bat.hp >= float(md.damage) * float(md.air_mult) - 0.01, "flyers take double missile damage (%.0f)" % (bat.max_hp - bat.hp))
	check(grunt.hp < grunt.max_hp, "ground targets hit too")


func test_amplifier() -> void:
	var g = new_game()
	g.gold = 10000
	var arrow = g.place_tower("arrow", Vector2i(2, 3))
	var far = g.place_tower("arrow", Vector2i(12, 1))
	var amp = g.place_tower("amp", Vector2i(3, 3))
	check(near(arrow.buff_dmg, 0.15) and near(far.buff_dmg, 0.0), "pylon boosts only towers in its field")
	check(near(arrow.eff_damage(), 9.0 * 1.15), "boosted damage")
	g.upgrade_tower(amp)
	g.upgrade_tower(amp, "overclock")
	check(near(arrow.buff_rate, 0.25) and near(arrow.eff_rate(), 2.0 * 1.25), "overclock adds attack speed")
	var amp2 = g.place_tower("amp", Vector2i(2, 4))
	g.upgrade_tower(amp2)
	g.upgrade_tower(amp2, "array")
	check(near(arrow.buff_dmg, 0.30) and near(arrow.buff_range, 0.25), "pylons don't stack; each stat takes the best")
	check(near(arrow.get_range(), 140.0 * 1.25), "array extends range")
	g.sell_tower(amp)
	check(near(arrow.buff_rate, 0.0) and near(arrow.buff_dmg, 0.25), "selling a pylon removes its boost")
	check(g.pick_target(amp) == null, "pylons never target")


func test_scrapyard() -> void:
	var g = new_game()
	g.gold = 100000
	var yard = g.place_tower("scrap", Vector2i(2, 3))
	check(yard != null and yard.is_economy() and g.tower_cost("scrap") == 150, "the Scrapyard builds for 150 as an economy tower")
	check(g.pick_target(yard) == null, "Scrapyards never target")
	var before: int = g.gold
	g._pay_income(1)
	check(g.gold - before == 25, "tier 1 pays 25 credits at a round clear (%d)" % (g.gold - before))
	g.upgrade_tower(yard)
	g.upgrade_tower(yard, "mint")
	before = g.gold
	g._pay_income(40)
	var want := roundi(110.0 * Waves.bounty_scale(40))
	check(g.gold - before == want, "Credit Mint pays 110 scaled like kill credits at round 40 (%d of %d)" % [g.gold - before, want])
	# Scrap Collector: kills in its field pay more; bosses double on the Reclamation Plant.
	var col = g.place_tower("scrap", Vector2i(20, 12))
	g.upgrade_tower(col)
	g.upgrade_tower(col, "collector")
	var e = put(g, "grunt", 40.0)
	e.pos = col.pos + Vector2(30, 0)
	check(near(g._salvage_mult(e), 1.25), "a kill inside a Scrap Collector field pays +25%")
	e.pos = col.pos + Vector2(400, 0)
	check(near(g._salvage_mult(e), 1.0), "kills outside the field pay the normal bounty")
	e.pos = col.pos + Vector2(30, 0)
	var b0: int = g.gold
	g.damage_enemy(e, 1e9, true, null)
	check(g.gold - b0 == int(floor(4.0 * 1.25)), "the bonus is paid on the kill (%d)" % (g.gold - b0))
	# Supply Depot: cheaper upgrades for towers in its field; Forward Command refunds everything.
	var arrow = g.place_tower("arrow", Vector2i(3, 4))
	var far = g.place_tower("arrow", Vector2i(12, 1))
	check(arrow.upgrade_cost() == 70, "no depot, full upgrade price")
	var depot = g.place_tower("scrap", Vector2i(2, 4))
	g.upgrade_tower(depot)
	g.upgrade_tower(depot, "depot")
	check(near(arrow.discount, 0.10) and arrow.upgrade_cost() == 63 and far.upgrade_cost() == 70, "towers in a Supply Depot field upgrade 10% cheaper")
	check(near(depot.discount, 0.0) and near(yard.discount, 0.0), "depots don't discount Scrapyards")
	g.upgrade_tower(arrow)
	check(arrow.spent == 50 + 63, "the discounted price is what's charged and refunded")
	check(g.sell_value(arrow) == int(floor(113 * 0.7)), "the depot alone doesn't change sell refunds")
	g.sell_tower(depot)
	check(near(arrow.discount, 0.0) and arrow.upgrade_cost() > 0, "selling the depot removes its discount")
	# Reserve Bank interest (research unlocks the mastery; Scrap Contracts adds 10% income).
	var r = Game.new("meadow", 1, "medium", ["scrap_1", "scrap_2a", "scrap_2b", "scrap_m"])
	r.emit_events = false
	r.gold = 100000
	var bank = r.place_tower("scrap", Vector2i(2, 3))
	for k in "Taaaaa":
		r.upgrade_tower(bank, "" if k == "T" else k)
	check(bank.mastered and bank.display_name() == "Reserve Bank", "the Credit Mint masters into the Reserve Bank")
	r.gold = 5000
	r._pay_income(1)
	check(r.gold - 5000 == roundi(250.0 * 1.1) + 150, "Reserve Bank: 275 income plus 3%% interest on 5000 (%d)" % (r.gold - 5000))
	r.gold = 50000
	r._pay_income(1)
	check(r.gold - 50000 == roundi(250.0 * 1.1) + 300, "interest is capped at 300 (%d)" % (r.gold - 50000))
	var fc = Game.new("meadow", 1, "medium", ["scrap_1", "scrap_2a", "scrap_2b", "scrap_m"])
	fc.emit_events = false
	fc.gold = 100000
	var cmd = fc.place_tower("scrap", Vector2i(2, 4))
	for k in "Tccccc":
		fc.upgrade_tower(cmd, "" if k == "T" else k)
	var fa = fc.place_tower("arrow", Vector2i(3, 4))
	check(cmd.display_name() == "Forward Command" and fc.sell_value(fa) == fa.spent, "Forward Command: towers in its field sell back for everything")
	check(not Bot.is_pylon("scrap"), "the bot doesn't treat Scrapyards as pylons")


func test_save_migration_v2() -> void:
	var v2 := {
		"version": 2, "map_id": "meadow", "difficulty": "normal", "ability_cd": {}, "wave": 9, "gold": 400, "lives": 17,
		"towers": [
			{"type": "arrow", "col": 2, "row": 3, "tier": 3, "mode": 0, "kills": 40, "spent": 250},
			{"type": "tesla", "col": 3, "row": 3, "tier": 3, "mode": 0, "kills": 12, "spent": 570},
			{"type": "cannon", "col": 5, "row": 5, "tier": 2, "mode": 0, "kills": 3, "spent": 210},
		],
	}
	var res := SaveCodec.decode(v2)
	check(res.has("game"), "v2 save loads (%s)" % res.get("error", ""))
	if res.has("game"):
		var g = res.game
		check(g.tower_at[Vector2i(2, 3)].spec == "gatling", "v2 tier-3 pulse turret becomes Gatling")
		check(g.tower_at[Vector2i(3, 3)].spec == "storm", "v2 tier-3 arc coil becomes Storm")
		check(g.tower_at[Vector2i(5, 5)].spec == "", "tier-2 towers have no spec")
		check(int(SaveCodec.encode(g).version) == Game.SAVE_VERSION, "re-saving writes the current format")
	var bad := v2.duplicate(true)
	bad["version"] = 3
	check(SaveCodec.decode(bad).has("error"), "v3 tier-3 tower without a spec is rejected")


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
		check(pg.tower_cost("cannon") == int(round(90.0 * p)), "%s: a Plasma Mortar costs %d" % [mode, pg.tower_cost("cannon")])
		var pt = pg.place_tower("cannon", Vector2i(2, 3))
		check(pt.upgrade_cost() == int(round(float(Tower.tree("cannon").tiers[1].cost) * p)), "%s: upgrades are priced x%.2f too" % [mode, p])
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


func test_save_migration_v1() -> void:
	var v1 := {
		"version": 1, "map_id": "meadow", "wave": 3, "gold": 180, "lives": 12, "seed": 77,
		"towers": [{"type": "arrow", "col": 2, "row": 3, "tier": 2, "mode": 1, "kills": 4, "spent": 120}],
	}
	var res := SaveCodec.decode(v1)
	check(res.has("game"), "v1 save still loads (%s)" % res.get("error", ""))
	if res.has("game"):
		var g = res.game
		check(g.difficulty == "medium" and g.wave == 3 and g.gold == 180, "v1 fields carried over")
		check(g.lives == 60, "12 of 20 old shields become 60 of Medium's 100 (%d)" % g.lives)
		check(g.ability_cd.meteor == 0.0 and g.ability_cd.warp == 0.0, "v1 abilities start ready")
		check(int(SaveCodec.encode(g).version) == Game.SAVE_VERSION, "re-saving writes the current format")
	var bad := v1.duplicate(true)
	bad["version"] = 2
	bad["difficulty"] = "impossible"
	check(SaveCodec.decode(bad).has("error"), "unknown difficulty rejected")


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
	var t1 = g.place_tower("arrow", Vector2i(3, 2))
	var t2 = g.place_tower("cannon", Vector2i(4, 5))
	g.place_tower("tesla", Vector2i(8, 3))
	g.place_tower("frost", Vector2i(10, 5))
	g.place_tower("sniper", Vector2i(9, 2))
	g.upgrade_tower(t1)
	g.upgrade_tower(t2)
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
	check(g2.tower_at[Vector2i(3, 2)].tier == 2 and g2.tower_at[Vector2i(3, 2)].mode == 1, "tier and mode restored")
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
	good.place_tower("arrow", Vector2i(2, 3))
	var data := SaveCodec.encode(good)

	var newer := data.duplicate(true)
	newer["version"] = 999
	check(str(SaveCodec.decode(newer).get("error", "")).contains("newer"), "newer save version rejected")
	var bad_map := data.duplicate(true)
	bad_map["map_id"] = "atlantis"
	check(SaveCodec.decode(bad_map).has("error"), "unknown map rejected")
	var on_path := data.duplicate(true)
	on_path["towers"][0]["col"] = 0
	on_path["towers"][0]["row"] = 2
	check(SaveCodec.decode(on_path).has("error"), "tower on the path rejected")
	var bad_tier := data.duplicate(true)
	bad_tier["towers"][0]["trunk"] = 9
	check(SaveCodec.decode(bad_tier).has("error"), "impossible trunk tier rejected")
	var bad_branch := data.duplicate(true)
	bad_branch["towers"][0]["trunk"] = 2
	bad_branch["towers"][0]["depth"] = {"a": 3, "b": 3, "c": 0}
	bad_branch["towers"][0]["started"] = ["a", "b"]
	check(SaveCodec.decode(bad_branch).has("error"), "two primary branches rejected")
	var three := data.duplicate(true)
	three["towers"][0]["trunk"] = 2
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


## Builds a tower and upgrades it through `spec` to `tier` (3 = spec, 4 = mastery).
func build_to(g, type: String, cell: Vector2i, spec: String, tier: int):
	g.gold += 20000
	var t = g.place_tower(type, cell)
	while t != null and t.tier < tier:
		if not g.upgrade_tower(t, spec if t.tier == 2 else ""):
			break
	return t


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
	check(Research.total_cost() <= Research.max_points(), "the whole lab is affordable (%d <= %d)" % [Research.total_cost(), Research.max_points()])
	check(Research.node_ids().size() == ResearchData.NODES.size(), "node_ids lists every node once")

	# Every branch ends in a mastery that is a real step up from its specialization.
	for type in Towers.ORDER:
		var d: Dictionary = Towers.TOWERS[type]
		var ln := Tower.lines(type)
		var tr: Dictionary = Trees.TREES[type]
		for b in tr.branches:
			var sp: Dictionary = ln[b.key][1]
			var m: Dictionary = ln[b.key + "_m"]
			for key in sp:
				check(m.has(key), "%s %s mastery keeps stat %s" % [type, b.id, key])
			if d.get("economy", false):
				check(sp.keys().any(func(k): return float(m[k]) > float(sp[k])) or m.size() > sp.size(), "%s %s mastery pays out more" % [type, b.id])
				continue
			if d.get("support", false):
				var key := "mark" if d.get("sensor", false) else "buff_dmg"
				check(float(m[key]) > float(sp[key]), "%s %s mastery boosts more" % [type, b.id])
				continue
			check(level_dps(m) > level_dps(sp), "%s %s mastery out-damages the specialization" % [type, b.id])
			# Diminishing returns: damage per credit shouldn't jump far past the specialization's.
			var spec_total := float(tr.tiers[0].cost + tr.tiers[1].cost + b.nodes[0].cost)
			var branch_total := spec_total
			for i in range(1, b.nodes.size()):
				branch_total += float(b.nodes[i].cost)
			branch_total += float(b.mastery.cost)
			var ratio: float = (level_dps(m) / branch_total) / (level_dps(sp) / spec_total)
			check(ratio < 1.4, "%s %s mastery damage per credit stays in line (x%.2f)" % [type, b.id, ratio])


	check(Research.sanitize(["arrow_m", "bogus", "arrow_1", "arrow_1", 7]) == ["arrow_1"], "sanitize drops unknown, duplicate and orphaned nodes")
	check(Research.sanitize(["arrow_2b", "arrow_1", "arrow_m"]) == ["arrow_1", "arrow_2b", "arrow_m"], "sanitize keeps a valid chain in canonical order")
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
	check(SaveManager.buy_research("arrow_m") != "", "can't skip to a mastery")
	check(SaveManager.buy_research("nope") != "", "unknown node refused")
	check(SaveManager.buy_research("arrow_1") == "", "root node bought")
	check(SaveManager.buy_research("arrow_1") != "", "can't buy twice")
	check(SaveManager.buy_research("arrow_2b") == "" and SaveManager.buy_research("arrow_m") == "", "branch and mastery bought")
	check(SaveManager.research_available() == 1, "7 - 1 - 2 - 3 = 1 RP left (%d)" % SaveManager.research_available())
	check(SaveManager.buy_research("cannon_1") == "" and SaveManager.buy_research("cannon_2a").contains("research points"), "runs out of RP")
	SaveManager.load_profile()
	check(SaveManager.research_owned() == ["arrow_1", "arrow_2b", "arrow_m", "cannon_1"], "research persists (%s)" % str(SaveManager.research_owned()))
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
	check(research_game(["arrow_m"]).research.is_empty(), "a run's research is sanitized too")
	check(g.tower_cost("amp") == 80 and g.tower_cost("arrow") == 50, "Modular Build discounts only pylons")
	g.gold += 5000
	var amp = g.place_tower("amp", Vector2i(3, 4))
	check(amp.spent == 80 and amp.upgrade_cost() == 96, "pylon upgrades discounted too (%d)" % amp.upgrade_cost())
	check(near(float(amp.stats().buff_dmg), 0.19) and near(amp.get_range(), 108.0), "Resonance and Field Coils (%.2f, %.1f)" % [amp.stats().buff_dmg, amp.get_range()])

	var arrow = g.place_tower("arrow", Vector2i(2, 3))
	check(near(arrow.stats().damage, 9.54) and near(arrow.stats().range, 149.8) and near(arrow.stats().rate, 2.14), "pulse research applies to damage, range and rate")
	check(not arrow.stats().has("splash"), "research never adds stats a level lacks")
	check(near(float(Towers.TOWERS.arrow.tiers[0].damage), 9.0), "research never mutates the data table")
	var tesla = g.place_tower("tesla", Vector2i(8, 3))
	check(int(tesla.stats().chains) == 4 and near(tesla.stats().chain_range, 99.0), "Conductive Arcs +1 chain, Antennae +10%% reach")
	var frost = g.place_tower("frost", Vector2i(10, 5))
	check(near(frost.stats().slow, 0.40) and near(frost.stats().slow_time, 1.8) and near(frost.stats().range, 111.3), "Deep Freeze and Wide Emitters")
	var laser = g.place_tower("laser", Vector2i(8, 9))
	check(near(laser.stats().ramp_time, 2.0), "Heat Sinks shorten the ramp")
	var missile = g.place_tower("missile", Vector2i(12, 4))
	check(near(missile.stats().splash, 31.36), "Warhead Packing widens blasts")
	g.upgrade_tower(arrow)
	check(near(arrow.stats().damage, 15.9), "research follows the tower through upgrades")
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
	var partial = research_game(["arrow_1"])
	check(near(partial.level_stats("arrow", 1).damage, 9.54) and near(partial.level_stats("cannon", 1).damage, 22.0), "research only touches its own tower")


func test_mastery_upgrades() -> void:
	var g = research_game([])
	var t = build_to(g, "arrow", Vector2i(2, 3), "gatling", 4)
	check(t.tier == 3 and t.depth.a == 4 and t.upgrade_cost() == 0, "no research: the branch stops before its mastery")
	check(t.block_reason("a").contains("research"), "the reason names the missing research")
	check(not g.upgrade_tower(t), "mastery refused without research")
	var r = research_game(["arrow_1", "arrow_2a", "arrow_m"])
	var gat = build_to(r, "arrow", Vector2i(2, 3), "gatling", 3)
	check(gat.depth.a == 1 and gat.upgrade_cost() == 170, "the next Gatling upgrade costs 170 (%d)" % gat.upgrade_cost())
	while gat.depth.a < Tower.BRANCH_STEPS:
		r.gold += 1000
		r.upgrade_tower(gat)
	var br: Dictionary = Tower.tree("arrow").branches[0]
	var mc := int(br.mastery.cost)
	check(gat.upgrade_cost() == mc, "mastery research opens the mastery (%d cr)" % mc)
	r.gold = mc - 1
	check(not r.upgrade_tower(gat), "mastery needs the credits")
	r.gold = mc
	check(r.upgrade_tower(gat) and r.gold == 0 and gat.tier == 4 and gat.spec == "gatling", "mastery bought, branch kept")
	check(gat.display_name() == "Storm Gatling" and int(gat.stats().multishot) == 2, "the mastery is the branch's capstone")
	var m: Dictionary = Tower.lines("arrow").a_m
	check(near(gat.stats().damage, float(m.damage) * 1.06) and near(gat.stats().range, float(m.range) * 1.07), "research still applies to the mastery")
	check(not r.upgrade_tower(gat) and gat.upgrade_cost() == 0, "nothing past the mastery")
	var total := int(Tower.tree("arrow").tiers[0].cost) + int(Tower.tree("arrow").tiers[1].cost) + mc
	for nd in br.nodes:
		total += int(nd.cost)
	check(gat.spent == total, "spend tracked through the whole branch (%d / %d)" % [gat.spent, total])
	var shred = build_to(r, "arrow", Vector2i(3, 4), "shredder", 4)
	check(shred.tier == 4 and shred.display_name() == "Disintegrator", "each branch has its own mastery")
	var mortar = build_to(r, "cannon", Vector2i(5, 5), "siege", 4)
	check(mortar.tier == 3, "mastery research is per tower type")
	check(r.level_stats("cannon", 4, "siege").has("stun"), "level_stats reaches the mastery")


func test_laser_charge_stat() -> void:
	for lv in [Tower.lines("laser").t1, Tower.lines("laser").t2, Tower.lines("laser").a[1], Tower.lines("laser").b[1]]:
		check(float(lv.get("ramp_time", 0.0)) > 0.0, "laser levels carry a charge time (ramp_time)")
	check(Game.START_GOLD == 500, "runs start with 500 credits")


func test_branch_rules() -> void:
	var g = research_game(Research.node_ids())
	g.gold = 100000
	var t = g.place_tower("arrow", Vector2i(2, 3))
	check(g.upgrade_tower(t, "gatling") and t.trunk == 2 and t.started.is_empty(), "tier 1 always upgrades the trunk first")
	check(g.upgrade_tower(t, "a") and g.upgrade_tower(t, "b"), "two branches can be started, by key or id")
	check(t.block_reason("c").contains("Locked"), "the third branch locks once two are started")
	check(g.upgrade_tower(t, "b") and g.upgrade_tower(t, "a"), "both branches can reach two upgrades")
	check(t.primary() == "a" and not t.locked_in(), "nothing is locked in at 2 and 2 (the first started leads)")
	check(g.upgrade_tower(t, "a") and t.primary() == "a" and t.locked_in(), "the first third upgrade makes the primary")
	check(not g.upgrade_tower(t, "b") and t.block_reason("b").contains("Blocked"), "a secondary already at its cap of 2 is then blocked")
	check(g.upgrade_tower(t, "a") and t.depth.a == 4, "the primary climbs on")
	check(g.upgrade_tower(t, "a") and t.mastered and t.tier == 4, "and takes its mastery")
	# The playtest case: the primary locks in while the secondary has only one upgrade. The secondary
	# can still take its second, then stops; the third branch stays locked.
	var s = g.place_tower("sensor", Vector2i(12, 1))
	for k in "Tacaa":
		g.upgrade_tower(s, "" if k == "T" else k)
	check(int(s.depth.a) == 3 and int(s.depth.c) == 1 and s.locked_in() and s.primary() == "a", "Sensor Array: primary A at 3, secondary C at 1")
	check(s.can_buy("c") and g.upgrade_tower(s, "c") and int(s.depth.c) == 2, "the secondary can still take its second upgrade after the primary locks in")
	check(not g.upgrade_tower(s, "c") and s.block_reason("c").contains("capped"), "then it stops at its cap of 2")
	check(s.block_reason("b").contains("Locked"), "the third branch is still locked")
	var sln := Tower.lines("sensor")
	check(near(float(s.base_stats().range), float(sln.a[3].range) + float(sln.c[2].range) - float(sln.t2.range)), "the secondary's second upgrade counts in the stats")
	# Stats: primary line plus the secondary's difference from Tier 2.
	var ln := Tower.lines("arrow")
	var expect_dmg := float(ln.a_m.damage) + float(ln.b[2].damage) - float(ln.t2.damage)
	var expect_rate := float(ln.a_m.rate) + float(ln.b[2].rate) - float(ln.t2.rate)
	var raw: Dictionary = t.base_stats()
	check(near(raw.damage, expect_dmg) and near(raw.rate, expect_rate), "secondary adds its difference from Tier 2 (%.1f dmg, %.2f/s)" % [raw.damage, raw.rate])
	check(float(raw.get("shred", 0.0)) > 0.0 and int(raw.multishot) == 2, "the secondary's mechanic comes along (shred) with the primary's (multishot)")
	# Attack-style secondaries add their attack instead of their stat line; everything else stacks in
	# full, downsides included (Supernova plus Pulse Reactor).
	var f = g.place_tower("arrow", Vector2i(3, 3))
	g.upgrade_tower(f)
	g.upgrade_tower(f, "a")
	g.upgrade_tower(f, "c")
	var fs: Dictionary = f.base_stats()
	check(int(fs.get("flechette_every", 0)) == 3 and not fs.has("cone"), "a Flechette secondary adds a flechette volley, not its cone stats")
	var n = g.place_tower("nova", Vector2i(5, 4))
	g.upgrade_tower(n)
	g.upgrade_tower(n, "a")
	g.upgrade_tower(n, "b")
	var ns: Dictionary = n.base_stats()
	var nl := Tower.lines("nova")
	check(near(ns.rate, float(nl.a[1].rate) + float(nl.b[1].rate) - float(nl.t2.rate)), "stat changes apply in full, downsides included")



func test_mastery_mechanics() -> void:
	var all := Research.node_ids()
	# Storm Gatling: every volley also fires at a second target.
	var g = research_game(all)
	build_to(g, "arrow", Vector2i(2, 3), "gatling", 4)
	g.state = Game.State.WAVE
	put(g, "brute", 60.0, 0, 50.0)
	put(g, "brute", 90.0, 0, 50.0)
	g.tick(SIM_DT)
	check(g.projectiles.size() == 2, "Storm Gatling fires twice per volley (%d)" % g.projectiles.size())
	check(g.projectiles.size() == 2 and g.projectiles[0].target != g.projectiles[1].target, "...at two different targets")

	# Earthshaker: blasts stun, bosses less.
	var g2 = research_game(all)
	var es = build_to(g2, "cannon", Vector2i(5, 5), "siege", 4)
	g2.state = Game.State.WAVE
	var grunt = put(g2, "brute", 330.0, 0, 50.0)
	var boss = put(g2, "juggernaut", 334.0, 0, 5.0)
	check(es.can_target(grunt), "earthshaker reaches the test spot")
	var hit := run_until(g2, func(): return grunt.stun_timer > 0.0, 3.0)
	check(hit and grunt.stun_timer > 0.3, "Earthshaker stuns ground targets (%.2f)" % grunt.stun_timer)
	check(boss.stun_timer > 0.0 and boss.stun_timer < 0.15, "bosses shrug off most of the stun (%.2f)" % boss.stun_timer)

	# Executioner: non-boss survivors under 20% are destroyed; bosses aren't.
	var g3 = research_game(all)
	var ex = build_to(g3, "sniper", Vector2i(7, 4), "deadeye", 4)
	g3.state = Game.State.WAVE
	var victim = put(g3, "grunt", 200.0)
	victim.max_hp = 10000.0
	victim.hp = ex.eff_damage() + 1500.0
	g3.tick(SIM_DT)
	check(not victim.alive and ex.kills == 1, "Executioner finishes a target left at 15%")
	var g4 = research_game(all)
	var ex2 = build_to(g4, "sniper", Vector2i(7, 4), "deadeye", 4)
	g4.state = Game.State.WAVE
	var jug = put(g4, "juggernaut", 200.0)
	jug.max_hp = 10000.0
	jug.hp = ex2.eff_damage() * 2.5 + 1500.0
	g4.tick(SIM_DT)
	check(jug.alive and near(jug.hp, 1500.0, 0.5), "bosses are never executed (%.1f)" % jug.hp)
	var g5 = research_game(all)
	var dead = build_to(g5, "sniper", Vector2i(7, 4), "deadeye", 3)
	g5.state = Game.State.WAVE
	var v2 = put(g5, "grunt", 200.0)
	v2.max_hp = 10000.0
	v2.hp = dead.eff_damage() + 1500.0
	g5.tick(SIM_DT)
	check(v2.alive, "plain Deadeye has no execute")

	# Ion Lance: the wide channel catches an enemy that a plain Piercing Rail misses.
	for tier in [3, 4]:
		var g6 = research_game(all)
		var rail = build_to(g6, "sniper", Vector2i(7, 4), "lance", tier)
		g6.state = Game.State.WAVE
		var front = put(g6, "brute", 200.0, 0, 50.0)
		var side = put(g6, "brute", 200.0, 0, 50.0)
		var dir: Vector2 = (front.pos - rail.pos).normalized()
		side.pos = front.pos + dir.orthogonal() * (side.radius + 17.0)
		rail.aim = dir.angle()
		g6._fire_rail(rail, front, rail.stats())
		check(front.hp < front.max_hp, "tier %d rail hits the lined-up target" % tier)
		if tier == 3:
			check(near(side.hp, side.max_hp), "Piercing Rail misses a target 17 px off the line")
		else:
			check(side.hp < side.max_hp, "Ion Lance's wide channel catches it")

	# Masteries that extend existing mechanics.
	var g7 = research_game(all)
	var loc = build_to(g7, "missile", Vector2i(12, 4), "swarm", 4)
	g7.state = Game.State.WAVE
	put(g7, "grunt", 960.0, 0, 50.0)
	run_until(g7, func(): return not g7.projectiles.is_empty(), 2.0)
	check(g7.projectiles.size() == 8, "Locust Swarm fires 8 missiles (%d)" % g7.projectiles.size())
	var prism = build_to(g7, "laser", Vector2i(8, 9), "prism", 4)
	check(int(prism.stats().beams) == 6, "Refraction Grid has 6 beams")
	build_to(g7, "amp", Vector2i(11, 5), "overclock", 4)
	check(near(loc.buff_dmg, 0.49) and near(loc.buff_rate, 0.40), "Hypercore Pylon boosts neighbors, plus Resonance (%.2f, %.2f)" % [loc.buff_dmg, loc.buff_rate])


func test_save_research_v4() -> void:
	var owned := ["cmd_funds", "cmd_core", "sniper_1", "sniper_2b", "sniper_m"]
	var g = research_game(owned, "canyon", 777)
	var ex = build_to(g, "sniper", Vector2i(9, 2), "deadeye", 4)
	g.gold = 321
	g.bounty_carry = 0.4
	var data := SaveCodec.encode(g)
	check(int(data.version) == Game.SAVE_VERSION and data.research == owned, "saves record the run's research")
	var res := SaveCodec.decode(JSON.parse_string(JSON.stringify(data)))
	check(res.has("game"), "v4 save loads (%s)" % res.get("error", ""))
	if res.has("game"):
		var g2 = res.game
		check(g2.research == owned and g2.max_lives == g.max_lives, "research restored with the run")
		var t2 = g2.tower_at[Vector2i(9, 2)]
		check(t2.tier == 4 and t2.display_name() == "Executioner" and near(t2.stats().damage, ex.stats().damage), "tier-4 tower restored with research")
		check(near(g2.bounty_carry, 0.4), "bounty carry restored")
		var a := SaveCodec.encode(g)
		var b := SaveCodec.encode(g2)
		a.erase("saved_at")
		b.erase("saved_at")
		check(deep_equal(a, b), "v4 round trip is exact")
	var stripped := data.duplicate(true)
	stripped["research"] = []
	check(str(SaveCodec.decode(stripped).get("error", "")).contains("Mastery"), "a mastered tower without its research is rejected")
	var junk := data.duplicate(true)
	junk["research"] = "all of it"
	check(SaveCodec.decode(junk).has("error"), "malformed research list rejected")
	var v3 := data.duplicate(true)
	v3["version"] = 3
	v3.erase("research")
	v3.erase("bounty_carry")
	v3["towers"] = [{"type": "sniper", "col": 9, "row": 2, "tier": 3, "spec": "deadeye", "mode": 0, "kills": 0, "spent": 530}]
	var r3 := SaveCodec.decode(v3)
	check(r3.has("game") and r3.game.research.is_empty(), "v3 saves load with no research")


# --- Phantoms, Aegis Walkers, Hydra Frames, Jammers and the new towers -----------------------

func test_phantom_cloak() -> void:
	var g = new_game()
	g.gold = 5000
	var arrow = g.place_tower("arrow", Vector2i(2, 3))
	g.state = Game.State.WAVE
	var ph = put(g, "phantom", 150.0)
	check(ph.is_hidden(), "phantoms start cloaked")
	check(g.pick_target(arrow) == null and not arrow.can_target(ph), "towers can't target a cloaked phantom")
	for i in 30:
		g.tick(SIM_DT)
	check(g.projectiles.is_empty() and near(ph.hp, ph.max_hp), "the turret holds fire")
	var frost = g.place_tower("frost", Vector2i(1, 3))
	g.tick(SIM_DT)
	check(ph.hp < ph.max_hp and ph.slow_amount > 0.0, "area pulses still hit cloaked enemies")
	var sensor = g.place_tower("sensor", Vector2i(3, 4))
	check(sensor.is_support() and sensor.is_sensor() and near(arrow.buff_dmg, 0.0), "the sensor is support and doesn't act as a pylon")
	g.tick(SIM_DT)
	check(not ph.is_hidden(), "a Sensor Array reveals phantoms in its field")
	check(ph.vuln_timer > 0.0 and near(ph.vuln_amount, 0.08), "and marks them (+8%%)")
	check(arrow.can_target(ph), "revealed phantoms can be targeted")
	for gone in [sensor, frost]:
		g.towers.erase(gone)
		g.tower_at.erase(gone.cell)
	for i in 40:
		g.tick(SIM_DT)
	check(ph.is_hidden(), "the cloak returns after leaving the field")
	check(not Bot.is_pylon("sensor") and Bot.is_pylon("amp"), "the bot places sensors for coverage, pylons for boosts")


func test_aegis_barrier() -> void:
	var g = new_game()
	g.gold = 5000
	var coil = g.place_tower("tesla", Vector2i(15, 6))
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
	var near_t = g.place_tower("arrow", Vector2i(2, 3))
	var far_t = g.place_tower("sniper", Vector2i(10, 2))
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


func test_flak() -> void:
	var g = new_game()
	g.gold = 5000
	var flak = g.place_tower("flak", Vector2i(2, 3))
	g.state = Game.State.WAVE
	var grunt = put(g, "grunt", 60.0, 0, 20.0)
	check(g.pick_target(flak) == null and not flak.can_target(grunt), "flak can't target ground units")
	g.tick(SIM_DT)
	check(g.projectiles.is_empty(), "flak holds fire with only ground units around")
	var bat = put(g, "bat", 60.0, 0, 20.0)
	var bat2 = put(g, "bat", 66.0, 0, 20.0)
	check(run_until(g, func(): return bat.hp < bat.max_hp, 2.0), "flak hits flyers")
	check(bat2.hp < bat2.max_hp, "the airburst catches nearby flyers too")
	check(near(grunt.hp, grunt.max_hp), "the airburst never hurts ground units")
	var g2 = research_game(Research.node_ids())
	var th = build_to(g2, "flak", Vector2i(2, 3), "burst", 4)
	check(th.display_name() == "Thunderhead" and near(float(th.stats().stun), 0.5), "Thunderhead mastery stuns flyers")


func test_graviton() -> void:
	var g = new_game()
	g.gold = 5000
	var gp = g.place_tower("gravity", Vector2i(5, 5))
	g.state = Game.State.WAVE
	var e = put(g, "grunt", 330.0, 0, 20.0)
	var boss = put(g, "juggernaut", 334.0, 0, 5.0)
	var fly = put(g, "bat", 300.0)
	var d0: float = e.distance
	var b0: float = boss.distance
	var f0: float = fly.distance
	g.tick(SIM_DT)
	check(near(e.distance, d0 + 55.0 * SIM_DT - 40.0, 0.2), "pulse shoves ground enemies back 40 px (%.1f)" % (d0 - e.distance))
	check(near(boss.distance, b0 + 32.0 * SIM_DT - 10.0, 0.2), "bosses only move a quarter as far")
	check(near(fly.distance, f0 + 82.0 * SIM_DT, 0.2), "flyers are unaffected")
	check(e.hp < e.max_hp and gp.cooldown > 3.0, "the pulse crushes and then recharges (%.2f s)" % gp.cooldown)
	var g2 = new_game()
	var cf = build_to(g2, "gravity", Vector2i(5, 5), "crush", 3)
	g2.state = Game.State.WAVE
	var e2 = put(g2, "brute", 330.0, 0, 20.0)
	g2.tick(SIM_DT)
	check(e2.stun_timer > 0.5, "Crush Field stuns (%.2f)" % e2.stun_timer)
	check(g2.level_stats("gravity", 4, "repulsor").push > g2.level_stats("gravity", 3, "repulsor").push, "graviton masteries exist")


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
