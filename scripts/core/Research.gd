extends RefCounted
## Research Lab rules: research points earned from profile records, buying nodes, and turning a set
## of owned nodes into the modifiers a run uses. Pure static functions (no profile or file access),
## so the simulation and the tests can use them directly.

const Data = preload("res://data/research.gd")
const Towers = preload("res://data/towers.gd")
const Maps = preload("res://data/maps.gd")
const Difficulty = preload("res://data/difficulty.gd")


## Every node id, grouped by tree in TREE_ORDER and top row first.
static func node_ids() -> Array:
	var out: Array = []
	for tree in Data.TREE_ORDER:
		out.append_array(tree_nodes(tree))
	return out


static func tree_nodes(tree: String) -> Array:
	var ids: Array = []
	for id in Data.NODES:
		if Data.NODES[id].tree == tree:
			ids.append(id)
	ids.sort_custom(func(a, b):
		var sa: Vector2i = Data.NODES[a].slot
		var sb: Vector2i = Data.NODES[b].slot
		return sa.y < sb.y or (sa.y == sb.y and sa.x < sb.x))
	return ids


static func tree_name(tree: String) -> String:
	if Data.TREE_NAMES.has(tree):
		return str(Data.TREE_NAMES[tree])
	return str(Towers.TOWERS[tree].name)


static func mastery_node(tower_type: String) -> String:
	for id in tree_nodes(tower_type):
		if bool(Data.NODES[id].effects.get("mastery", false)):
			return id
	return ""


static func total_cost() -> int:
	var n := 0
	for id in Data.NODES:
		n += int(Data.NODES[id].cost)
	return n


## The most RP the records can ever produce: every medal, every round milestone and the endless
## cap on every sector (legacy RP from v2 profiles comes on top).
static func max_points() -> int:
	var medals := 0
	for mode in Difficulty.ORDER:
		medals += int(Difficulty.DIFFICULTIES[mode].medal_rp)
	var per_sector := medals + Data.RP_ROUND_MILESTONES.size() + Data.RP_ENDLESS_MAX_PER_SECTOR
	return per_sector * Maps.ORDER.size()


## Research points earned from the profile's `maps` records ({map: {mode: record}}): each medal
## pays its mode's medal_rp, each round milestone reached pays 1 per sector (best on any mode),
## and endless mode pays 1 per RP_ENDLESS_STEP rounds past the mode's last round (best per sector).
static func points_earned(maps) -> int:
	if not (maps is Dictionary):
		return 0
	var total := 0
	for map_id in maps:
		var per_map = maps[map_id]
		if not (per_map is Dictionary) or not Maps.MAPS.has(str(map_id)):
			continue
		var best_round := 0
		var best_past := 0
		for mode in per_map:
			var rec = per_map[mode]
			if not (rec is Dictionary) or not Difficulty.DIFFICULTIES.has(str(mode)):
				continue
			if bool(rec.get("medal", false)):
				total += int(Difficulty.DIFFICULTIES[mode].medal_rp)
			best_round = maxi(best_round, int(rec.get("best_wave", 0)))
			best_past = maxi(best_past, int(rec.get("best_endless", 0)) - Difficulty.rounds(str(mode)))
		for m in Data.RP_ROUND_MILESTONES:
			if best_round >= int(m):
				total += 1
		total += mini(maxi(0, best_past) / Data.RP_ENDLESS_STEP, Data.RP_ENDLESS_MAX_PER_SECTOR)
	return total


## RP a v2 profile's records earned under the old rules (2 per star, 1 each for waves 10 and 20
## per sector, 1 per 10 endless waves past 25 up to 5 per sector). Kept forever as legacy RP.
static func legacy_points(maps) -> int:
	if not (maps is Dictionary):
		return 0
	var total := 0
	for map_id in maps:
		var per_map = maps[map_id]
		if not (per_map is Dictionary) or not Maps.MAPS.has(str(map_id)):
			continue
		var best_wave := 0
		var best_endless := 0
		for diff in per_map:
			var rec = per_map[diff]
			if not (rec is Dictionary):
				continue
			total += clampi(int(rec.get("stars", 0)), 0, 3) * 2
			best_wave = maxi(best_wave, int(rec.get("best_wave", 0)))
			best_endless = maxi(best_endless, int(rec.get("best_endless", 0)))
		for m in [10, 20]:
			if best_wave >= m:
				total += 1
		total += mini(maxi(0, best_endless - 25) / 10, 5)
	return total



static func spent(owned: Array) -> int:
	var n := 0
	for id in owned:
		if Data.NODES.has(id):
			n += int(Data.NODES[id].cost)
	return n


static func prerequisites_met(owned: Array, id: String) -> bool:
	var req: Array = Data.NODES[id].requires
	if req.is_empty():
		return true
	for r in req:
		if owned.has(r):
			return true
	return false


## Why `id` can't be bought right now, or "" if it can.
static func buy_block_reason(owned: Array, id: String, available: int) -> String:
	if not Data.NODES.has(id):
		return "Unknown research."
	if owned.has(id):
		return "Already researched."
	if not prerequisites_met(owned, id):
		return "Research a connected node above it first."
	if available < int(Data.NODES[id].cost):
		return "Needs %d research points." % int(Data.NODES[id].cost)
	return ""


## Known ids only, no duplicates, every node's prerequisites owned, in canonical order.
static func sanitize(owned) -> Array:
	var have: Array = []
	if owned is Array:
		for id in owned:
			if Data.NODES.has(str(id)) and not have.has(str(id)):
				have.append(str(id))
	var out: Array = []
	var changed := true
	while changed:
		changed = false
		for id in node_ids():
			if have.has(id) and not out.has(id) and prerequisites_met(out, id):
				out.append(id)
				changed = true
	var ordered: Array = []
	for id in node_ids():
		if out.has(id):
			ordered.append(id)
	return ordered


# --- Turning research into run modifiers ------------------------------------------------------

## Command-tree bonuses for a run.
static func run_mods(owned: Array) -> Dictionary:
	var m := {"start_gold": 0.0, "lives": 0.0, "sell_refund": 0.0, "ability_cd": 0.0, "bounty": 0.0}
	for id in owned:
		if not Data.NODES.has(id) or Data.NODES[id].tree != "command":
			continue
		var fx: Dictionary = Data.NODES[id].effects
		for k in fx:
			m[k] = float(m[k]) + float(fx[k])
	return m


## Modifiers for one tower type: {"mult": {stat: frac}, "add": {stat: n}, "cost": frac, "mastery": bool}.
static func tower_mods(owned: Array, tower_type: String) -> Dictionary:
	var m := {"mult": {}, "add": {}, "cost": 0.0, "mastery": false}
	for id in owned:
		if not Data.NODES.has(id) or Data.NODES[id].tree != tower_type:
			continue
		var fx: Dictionary = Data.NODES[id].effects
		for k in fx.get("mult", {}):
			m.mult[k] = float(m.mult.get(k, 0.0)) + float(fx.mult[k])
		for k in fx.get("add", {}):
			m.add[k] = m.add.get(k, 0) + fx.add[k]
		m["cost"] = float(m.cost) + float(fx.get("cost", 0.0))
		if bool(fx.get("mastery", false)):
			m["mastery"] = true
	return m


## A tower level's stats with research applied. Multipliers and additions only touch stats the
## level already has, so e.g. +blast radius never gives a Pulse Turret splash.
static func apply(level: Dictionary, mods: Dictionary) -> Dictionary:
	var mult: Dictionary = mods.get("mult", {})
	var add: Dictionary = mods.get("add", {})
	if mult.is_empty() and add.is_empty():
		return level
	var out := level.duplicate()
	for k in mult:
		if out.has(k) and k != "cost":
			out[k] = float(out[k]) * (1.0 + float(mult[k]))
	for k in add:
		if out.has(k) and k != "cost":
			if out[k] is int:
				out[k] = int(out[k]) + int(add[k])
			else:
				out[k] = float(out[k]) + float(add[k])
	return out


static func discounted(cost: int, mods: Dictionary) -> int:
	var d := clampf(float(mods.get("cost", 0.0)), 0.0, 0.9)
	return int(round(float(cost) * float(mods.get("price", 1.0)) * (1.0 - d)))


## Short human-readable list of what research does to a tower, e.g. ["+10% damage", "+1 chains"].
static func describe(mods: Dictionary) -> Array:
	var names := {
		"damage": "damage", "range": "range", "rate": "attack speed", "splash": "blast radius",
		"chain_range": "arc reach", "ramp_time": "ramp time", "push": "pushback",
		"strip": "barrier strip", "drone_speed": "drone speed",
	}
	var out: Array = []
	var mult: Dictionary = mods.get("mult", {})
	for k in mult:
		var v := float(mult[k])
		out.append("%s%d%% %s" % ["+" if v >= 0.0 else "", roundi(v * 100.0), names.get(k, k)])
	var add: Dictionary = mods.get("add", {})
	for k in add:
		match k:
			"slow":
				out.append("+%d%% slow" % roundi(float(add[k]) * 100.0))
			"slow_time":
				out.append("+%.1fs slow" % float(add[k]))
			"buff_dmg":
				out.append("+%d%% boost" % roundi(float(add[k]) * 100.0))
			"mark":
				out.append("+%d%% mark" % roundi(float(add[k]) * 100.0))
			"chains":
				out.append("+%d chain" % int(add[k]))
			"drones":
				out.append("+%d drone" % int(add[k]))
			_:
				out.append("+%s %s" % [str(add[k]), k])
	if float(mods.get("cost", 0.0)) > 0.0:
		out.append("-%d%% cost" % roundi(float(mods.cost) * 100.0))
	return out
