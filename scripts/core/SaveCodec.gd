extends RefCounted
## Converts between a Game and its JSON-safe save dictionary, validating everything on the way in.
## decode() never throws: it returns {"game": Game} or {"error": "reason"}.

const Game = preload("res://scripts/core/Game.gd")
const Maps = preload("res://data/maps.gd")
const Difficulty = preload("res://data/difficulty.gd")
const Towers = preload("res://data/towers.gd")
const Trees = preload("res://data/tower_trees.gd")
const Research = preload("res://scripts/core/Research.gd")

const REQUIRED := ["map_id", "wave", "gold", "lives", "towers"]
## v6 sectors' own core shields, for rescaling a v6 run's shields to its new mode.
const V6_SECTOR_LIVES := {"meadow": 20, "canyon": 20, "delta": 18, "crossroads": 15, "foundry": 15, "singularity": 12}


static func encode(g) -> Dictionary:
	return g.to_save()


static func decode(data) -> Dictionary:
	if not (data is Dictionary):
		return {"error": "Save data is not a JSON object."}
	var v = data.get("version")
	if not (v is int or v is float):
		return {"error": "Save file has no version number."}
	var version := int(v)
	if version > Game.SAVE_VERSION:
		return {"error": "Save was made by a newer version of the game (format v%d)." % version}
	if version < 1:
		return {"error": "Save format v%d is not supported." % version}
	data = _migrate(data, version)
	for key in REQUIRED:
		if not data.has(key):
			return {"error": "Save is missing '%s'." % key}
	for key in ["wave", "gold", "lives"]:
		if not (data[key] is int or data[key] is float):
			return {"error": "Save field '%s' is not a number." % key}
	var map_id := str(data.map_id)
	if not Maps.MAPS.has(map_id):
		return {"error": "Save refers to unknown map '%s'." % map_id}
	if int(data.lives) <= 0:
		return {"error": "Save has no lives left."}
	if not (data.towers is Array):
		return {"error": "Save tower list is malformed."}
	var diff := str(data.get("difficulty", "medium"))
	if not Difficulty.DIFFICULTIES.has(diff):
		return {"error": "Save has unknown difficulty '%s'." % diff}
	var research = data.get("research", [])
	if not (research is Array):
		return {"error": "Save research list is malformed."}
	var seed_v = data.get("seed", 1)
	var g = Game.new(map_id, int(seed_v) if (seed_v is int or seed_v is float) else 1, diff, research)
	var err: String = g.apply_save(data)
	if err != "":
		return {"error": err}
	return {"game": g}


## Upgrades older save formats to the current one, one version step at a time.
static func _migrate(data: Dictionary, from_version: int) -> Dictionary:
	var d := data.duplicate(true)
	if from_version < 2:
		# v2 added difficulty modes and ability cooldowns. v1 runs were all Normal.
		d["difficulty"] = "normal"
		d["ability_cd"] = {}
		d["version"] = 2
	if from_version < 3:
		# v3 added tier-3 specializations. A v2 tier-3 tower becomes its first spec,
		# which keeps the closest stats to the old single tier 3.
		var tl = d.get("towers", [])
		if tl is Array:
			for entry in tl:
				if entry is Dictionary and int(entry.get("tier", 1)) >= 3 and Towers.TOWERS.has(str(entry.get("type", ""))):
					entry["spec"] = Towers.TOWERS[str(entry.type)].spec_order[0]
		d["version"] = 3
	if from_version < 4:
		# v4 added the Research Lab. Older runs started with no research.
		d["research"] = []
		d["bounty_carry"] = 0.0
		d["version"] = 4
	if from_version < 5:
		# v5 reworked the sector layouts (walls, rubble, special tiles) and added switch gates.
		# A v4 tower now standing on rubble clears that rubble; one on a new wall is refunded.
		d["cleared"] = []
		d["gates"] = []
		d["route_counters"] = []
		var mid := str(d.get("map_id", ""))
		var tl = d.get("towers", [])
		if Maps.MAPS.has(mid) and tl is Array:
			var layout: Array = Maps.MAPS[mid].layout
			var keep: Array = []
			for entry in tl:
				if not (entry is Dictionary):
					keep.append(entry)
					continue
				var x := int(entry.get("col", -1))
				var y := int(entry.get("row", -1))
				var ch := "."
				if y >= 0 and y < layout.size() and x >= 0 and x < str(layout[y]).length():
					ch = str(layout[y])[x]
				if ch == "R":
					d.cleared.append([x, y])
				if ch == "#":
					d["gold"] = int(d.get("gold", 0)) + int(entry.get("spent", 0))
					continue
				keep.append(entry)
			d["towers"] = keep
		d["version"] = 5
	if from_version < 6:
		# v6 grew every sector from 20×12 to 32×16 and rerouted the lanes into the new space.
		# A tower now standing on a lane or wall is refunded; cleared rubble that is gone is dropped.
		var mid := str(d.get("map_id", ""))
		var tl = d.get("towers", [])
		var cl = d.get("cleared", [])
		if Maps.MAPS.has(mid) and tl is Array and cl is Array:
			var layout: Array = Maps.MAPS[mid].layout
			var at := func(x: int, y: int) -> String:
				if y >= 0 and y < layout.size() and x >= 0 and x < str(layout[y]).length():
					return str(layout[y])[x]
				return "#"
			var cleared: Array = []
			for entry in cl:
				if entry is Array and entry.size() == 2 and at.call(int(entry[0]), int(entry[1])) == "R":
					cleared.append(entry)
			var keep: Array = []
			for entry in tl:
				if not (entry is Dictionary):
					keep.append(entry)
					continue
				var x := int(entry.get("col", -1))
				var y := int(entry.get("row", -1))
				var ch: String = at.call(x, y)
				if ch == "R" and not cleared.any(func(e): return int(e[0]) == x and int(e[1]) == y):
					cleared.append([x, y])
				elif not (ch in [".", "H", "P", "R"]):
					d["gold"] = int(d.get("gold", 0)) + int(entry.get("spent", 0))
					continue
				keep.append(entry)
			d["towers"] = keep
			d["cleared"] = cleared
		d["version"] = 6
	if from_version < 7:
		# v7 (game v3.0) replaced casual/normal/veteran with five modes that set the run length and
		# shields. A run keeps its share of shields, rescaled to the new mode's total.
		var old_mode := str(d.get("difficulty", "normal"))
		var mode := Difficulty.resolve(old_mode)
		if mode != "":
			d["difficulty"] = mode
			var research = d.get("research", [])
			var owned: Array = research if research is Array else []
			var old_max := int(V6_SECTOR_LIVES.get(str(d.get("map_id", "")), 20)) + (10 if old_mode == "casual" else 0) + (3 if owned.has("cmd_core") else 0)
			var new_max: int = Game.start_lives(mode, Research.run_mods(owned))
			var lv = d.get("lives", 0)
			if (lv is int or lv is float) and int(lv) > 0:
				d["lives"] = clampi(int(round(float(lv) / float(maxi(1, old_max)) * float(new_max))), 1, new_max)
		d["version"] = 7
	if from_version < 8:
		# v8 (game v3.1) replaced tier 1-4 with a trunk plus three branches. A tier-3 tower owns the first
		# upgrade of its specialization's branch; a tier-4 tower owns the whole branch and its mastery.
		var tl8 = d.get("towers", [])
		if tl8 is Array:
			for entry in tl8:
				if not (entry is Dictionary) or entry.has("trunk") or not Trees.TREES.has(str(entry.get("type", ""))):
					continue
				var tier := int(entry.get("tier", 1))
				var key := ""
				for b in Trees.TREES[str(entry.type)].branches:
					if b.id == str(entry.get("spec", "")):
						key = b.key
				var dep := {"a": 0, "b": 0, "c": 0}
				var st: Array = []
				if tier >= 3 and key != "":
					dep[key] = 4 if tier >= 4 else 1
					st.append(key)
				# A tier-3+ tower with no known specialization stays invalid, so loading reports it.
				entry["trunk"] = 3 if (tier >= 3 and key == "") else mini(maxi(tier, 1), 2)
				entry["depth"] = dep
				entry["started"] = st
				entry["mastery"] = tier >= 4 and key != ""
				entry.erase("tier")
				entry.erase("spec")
		d["version"] = 8
	if from_version < 9:
		# v9 (game v3.4) made the Scrapyard and Drone Bay 2x2 (their col/row is the top-left tile) and
		# added a per-tower target priority. Nothing to convert here: loading keeps an old 1x1 one if
		# its 2x2 footprint fits and refunds it otherwise, and a missing priority means "Any".
		d["version"] = 9
	return d
