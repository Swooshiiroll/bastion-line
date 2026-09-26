extends Node
## Balance probe: runs the heuristic bot on every map at several enemy-HP multipliers and prints
## how far it gets. Run with:
##   godot --headless --path <project> res://tools/BalanceProbe.tscn [-- --factors=1.0,1.5,2.0]
## Other flags: --difficulty=hard (easy|medium|hard|nightmare|cataclysm), --no-abilities, --seeds=1,2,
## --maps=delta,foundry, --lives=1000 (override shields, e.g. to measure Cataclysm by rounds survived),
## --endless=20 (endless rounds to play past a medal), --research=all (every Research Lab node).

const Game = preload("res://scripts/core/Game.gd")
const Bot = preload("res://scripts/core/Bot.gd")
const Maps = preload("res://data/maps.gd")
const Research = preload("res://scripts/core/Research.gd")
const Waves = preload("res://data/waves.gd")
const Grid = preload("res://scripts/core/Grid.gd")
const Difficulty = preload("res://data/difficulty.gd")

const DT := 1.0 / 60.0
## Endless rounds the probe plays past a medal before stopping.
const ENDLESS_EXTRA := 20


func _ready() -> void:
	var factors := [1.0, 1.25, 1.5, 1.75, 2.0]
	var seeds := [2024]
	var diff := "medium"
	var lives := 0
	var endless := ENDLESS_EXTRA
	var abilities := true
	var research: Array = []
	var maps: Array = Maps.ORDER
	var detail := false
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--difficulty="):
			diff = a.substr(13)
		if a.begins_with("--research="):
			research = _research_set(a.substr(11))
		if a.begins_with("--growth="):
			Waves.late_growth = float(a.substr(9))
		if a.begins_with("--bounty="):
			Waves.bounty_exp = float(a.substr(9))
		if a.begins_with("--price="):
			Difficulty.price_override = float(a.substr(8))
		if a.begins_with("--endless="):
			endless = int(a.substr(10))
		if a.begins_with("--lives="):
			lives = int(a.substr(8))
		if a.begins_with("--maps="):
			maps = Array(a.substr(7).split(","))
		if a == "--detail":
			detail = true
		if a == "--no-abilities":
			abilities = false
		if a.begins_with("--factors="):
			factors = Array(a.substr(10).split(",")).map(func(s): return float(s))
		if a.begins_with("--seeds="):
			seeds = Array(a.substr(8).split(",")).map(func(s): return int(s))
	for f in factors:
		for id in maps:
			for sd in seeds:
				_probe(id, f, sd, diff, abilities, research, lives, endless, detail)
	get_tree().quit()


## "all", or comma-separated node ids, tree names ("command", "arrow"...), "towers" (every tower
## tree) or "nomastery" (every tower tree except its Mastery). Prerequisites are added as needed.
static func _research_set(spec: String) -> Array:
	var want: Array = []
	for tok in spec.split(","):
		for id in Research.node_ids():
			var nd: Dictionary = Research.Data.NODES[id]
			var mastery := bool(nd.effects.get("mastery", false))
			if tok == "all" or tok == id or tok == nd.tree \
					or (tok == "towers" and nd.tree != "command") \
					or (tok == "nomastery" and nd.tree != "command" and not mastery):
				want.append(id)
	# Pull in the nodes each one needs (first listed requirement), then drop anything unreachable.
	var changed := true
	while changed:
		changed = false
		for id in want.duplicate():
			var req: Array = Research.Data.NODES[id].requires
			if not req.is_empty() and not req.any(func(r): return want.has(r)):
				want.append(req[0])
				changed = true
	return Research.sanitize(want)


func _probe(map_id: String, factor: float, seed_v: int, diff: String, abilities: bool, research: Array, lives_override: int, endless_extra: int, detail := false) -> void:
	var g = Game.new(map_id, seed_v, diff, research)
	g.emit_events = false
	g.hp_factor = factor
	if lives_override > 0:
		g.lives = lives_override
		g.max_lives = lives_override
	var bot = Bot.new(g)
	bot.use_abilities = abilities
	var final: int = g.final_round()
	var checkpoints := {}
	var medal_lives := -1
	var ticks := 0
	var t0 := Time.get_ticks_msec()
	while not g.is_over() and not (g.medal and g.wave >= final + endless_extra) and ticks < int(float(final + endless_extra) * 900.0 / DT):
		bot.update(DT)
		g.tick(DT)
		ticks += 1
		if g.state == Game.State.BUILD and g.wave % 10 == 0 and not checkpoints.has(g.wave):
			checkpoints[g.wave] = "%d/%dt" % [g.lives, g.towers.size()]
			if detail:
				_detail(g, bot)
		if g.medal and medal_lives < 0:
			medal_lives = g.lives
	var cp := ""
	for w in range(10, final + endless_extra + 1, 10):
		cp += " r%d:%s" % [w, str(checkpoints.get(w, "-"))]
	var won: bool = g.medal
	print("%-9s x%.2f %-11s seed %5d  %-5s round %3d/%3d lives %4d/%4d |%s | towers %2d | endless reached %d | %ds" % [
		diff, factor, map_id, seed_v, "MEDAL" if won else "LOST", final if won else g.wave, final,
		medal_lives if won else g.lives, g.max_lives, cp, g.towers.size(), g.wave if won else 0,
		(Time.get_ticks_msec() - t0) / 1000])



## One checkpoint line on how full the map is: towers against free tiles (all, and those the bot
## would build on), how far the towers are upgraded, and where the credits are.
static func _detail(g, bot) -> void:
	var free := 0
	var useful := 0
	var cov: Dictionary = bot.coverage("arrow")
	for y in Grid.ROWS:
		for x in Grid.COLS:
			var c := Vector2i(x, y)
			if g.is_buildable(c) and not g.tower_at.has(c) and not g.grid.path_cells.has(c):
				free += 1
				if float(cov.get(c, 0.0)) > 0.5:
					useful += 1
	var maxed := 0
	var mastered := 0
	var spent := 0
	for t in g.towers:
		spent += int(t.spent)
		if t.mastered:
			mastered += 1
		var k: String = bot.next_key(t)
		if t.upgrade_cost(k) <= 0 or (t.trunk >= 2 and not t.can_buy(t.resolve_key(k))):
			maxed += 1
	print("    r%-3d towers %2d (maxed %2d, mastered %2d) | free tiles %3d, near a lane %3d | bank %6d, spent on towers %7d, avg %5d/tower" % [
		g.wave, g.towers.size(), maxed, mastered, free, useful, g.gold, spent, spent / maxi(1, g.towers.size())])
