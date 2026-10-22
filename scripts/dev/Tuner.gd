extends RefCounted
## Live tuner (issue #80, design/live_tuner.md): changes the numbers design/balance.md owns while the game runs. The
## numbers are static vars on their scripts, so an edit writes straight into the data the game reads; `_refresh` then
## brings the live run up to date (enemies on the field, placed towers, prices).
##
## A field's key is what `node tools/balance.mjs --apply` reads: "File:PATH" for a script's number (`Enemies:ENEMIES.grunt.hp`,
## `Game:SELL_REFUND`, `Enemies:LEAK_BANDS.0`, `Waves:BOSS_ROUNDS.20.0.1`), "Towers:slug.node.stat" for a tower node
## (`Towers:gun_turret.a1.damage`, `Towers:gun_turret.base.cost`; nodes base, r1-r3, a1-a4, am, b.., c..).

const Enemies = preload("res://data/enemies.gd")
const Modifiers = preload("res://data/modifiers.gd")
const Difficulty = preload("res://data/difficulty.gd")
const EnemyTraits = preload("res://scripts/core/EnemyTraits.gd")
const Rework = preload("res://data/rework_trees.gd")

## The scripts balance.md writes into, by the names tools/balance.mjs uses.
const SCRIPTS := {
	"Game": preload("res://scripts/core/Game.gd"),
	"Enemy": preload("res://scripts/entities/Enemy.gd"),
	"Tower": preload("res://scripts/entities/Tower.gd"),
	"Enemies": preload("res://data/enemies.gd"),
	"Waves": preload("res://data/waves.gd"),
	"Modifiers": preload("res://data/modifiers.gd"),
	"Research": preload("res://data/research.gd"),
	"Difficulty": preload("res://data/difficulty.gd"),
	"Abilities": preload("res://data/abilities.gd"),
}
## Every tunable static var, by script and area. Dictionaries and arrays are walked to their numbers; ENEMIES leaves out
## `tier` (not a balance number) and `lives` (derived from strength, see `_derive_leaks`).
const FIELDS := [
	["enemies", "Enemies", ["ENEMIES"]],
	["modifiers", "Modifiers", ["MODIFIERS", "SLOW_RESIST_CAP", "TWO_MODS_AT", "THREE_MODS_AT"]],
	["waves", "Waves", ["HP_LINEAR", "HP_QUAD", "LATE_START", "late_growth", "SPEED_PER_ROUND", "SPEED_CAP", "BOSS_SPEED_SHARE",
		"BUDGET_BASE", "BUDGET_LINEAR", "BUDGET_QUAD", "ELITE_FROM", "ELITE_FULL_AT", "ELITE_START", "ELITE_RISE", "MAX_ELITES",
		"MAX_SPAWNS", "BOSS_WEIGHT", "RECUR_BOSS_SHARE", "DEBUT_SHARE", "NEW_WEIGHT", "NEW_ROUNDS", "INTRO", "COST", "SPACING",
		"MAX_COUNT", "BOSS_ROUNDS"]],
	["economy", "Waves", ["bounty_exp", "CLEAR_BASE", "CLEAR_PER_ROUND", "CALL_BASE", "CALL_PER_ROUND"]],
	["economy", "Game", ["START_GOLD", "SELL_REFUND", "RUBBLE_COST"]],
	["difficulty", "Difficulty", ["DIFFICULTIES"]],
	["research", "Research", ["NODES", "RP_ROUND_MILESTONES", "RP_ENDLESS_STEP", "RP_ENDLESS_MAX_PER_SECTOR"]],
	["abilities", "Abilities", ["ABILITIES"]],
	["rules", "Enemies", ["LEAK_BANDS", "ROLE_RESIST"]],
	["rules", "Enemy", ["MIN_DAMAGE_FRACTION", "SLOW_CAP", "STUN_GUARD", "SHOVE_BUDGET"]],
	["rules", "Game", ["CRIT_MULT", "BOSS_STUN_FACTOR", "BOSS_PUSH_FACTOR", "DISABLE_GUARD", "GATE_COOLDOWN", "HIT_REVEAL_TIME",
		"SHIELD_EMP_MULT", "SHOCK_PCT", "SHOCK_BOSS_PCT", "SLUDGE_SLOW"]],
	["rules", "Tower", ["SECONDARY_CAP", "SITE_DAMAGE", "SITE_RANGE"]],
]
const SKIP := {"ENEMIES": ["tier", "lives"]}
const AREAS := ["enemies", "modifiers", "towers", "waves", "economy", "difficulty", "research", "abilities", "rules"]

## The run being tuned (null between runs). Edits made between runs still change the data; the next run is tuned.
static var game = null
## Each changed field's value before its first change (its value in balance.md): key → value.
static var _orig := {}
static var _fields: Array = []


## Starts tuning `g` (GameScreen, when a run starts or loads). A run that starts with tuned data is a tuned run.
static func attach(g) -> void:
	game = g
	if g != null and not _orig.is_empty():
		g.tuned = true


## Every tunable field: [{key, area, group, label}], in a stable order. `group` is the row it belongs to (an enemy, a
## tower node, a script), `label` the number's own name.
static func fields() -> Array:
	if _fields.is_empty():
		for f in FIELDS:
			var script = SCRIPTS[f[1]]
			for name in f[2]:
				var leaves: Array = []
				_walk(script.get(name), name, leaves, SKIP.get(name, []))
				for p in leaves:
					_fields.append(_field("%s:%s" % [f[1], p], f[0]))
		for slug in Rework.ORDER:
			for id in node_ids(slug):
				var n := _node(slug, id)
				_fields.append({"key": "Towers:%s.%s.cost" % [slug, id], "area": "towers", "group": "%s %s" % [slug, id], "label": "cost"})
				for part in ["set", "add"]:
					for k in n.get(part, {}):
						if n[part][k] is int or n[part][k] is float:
							_fields.append({"key": "Towers:%s.%s.%s" % [slug, id, k], "area": "towers", "group": "%s %s" % [slug, id], "label": k})
	return _fields


## A script field: an entry's numbers group under the entry (`ENEMIES.grunt`), anything else under its script.
static func _field(key: String, area: String) -> Dictionary:
	var path := key.get_slice(":", 1).split(".")
	if path.size() > 2:
		return {"key": key, "area": area, "group": "%s.%s" % [path[0], path[1]], "label": ".".join(path.slice(2))}
	return {"key": key, "area": area, "group": key.get_slice(":", 0), "label": ".".join(path)}


## Appends the path of every number in `v`; `skip` names an entry's keys to leave out. Dictionaries are walked, arrays
## only as a whole static var or a boss line-up (as balance.md: an array inside an entry, like the Colossus's phases,
## isn't a balance number).
static func _walk(v, path: String, out: Array, skip: Array) -> void:
	if v is Dictionary:
		for k in v:
			if path.count(".") == 1 and skip.has(str(k)):
				continue
			_walk(v[k], "%s.%s" % [path, k], out, skip)
	elif v is Array and (path.count(".") == 0 or path.begins_with("BOSS_ROUNDS")):
		for i in v.size():
			_walk(v[i], "%s.%d" % [path, i], out, skip)
	elif v is int or v is float:
		out.append(path)


## A tower's node ids in table order (base, its Retrofits r1.., then each path's four steps and mastery).
static func node_ids(slug: String) -> Array:
	var rt: Dictionary = Rework.TREES[slug]
	var out: Array = ["base"]
	for i in rt.retrofits.size():
		out.append("r%d" % (i + 1))
	for p in rt.paths:
		for i in p.nodes.size():
			out.append("%s%d" % [p.key, i + 1])
		out.append("%sm" % p.key)
	return out


## A tower node's data (`base`, `r1`, `a3`, `am`...).
static func _node(slug: String, id: String) -> Dictionary:
	var rt: Dictionary = Rework.TREES[slug]
	if id == "base":
		return rt.base
	if id.begins_with("r"):
		return rt.retrofits[int(id.substr(1)) - 1]
	for p in rt.paths:
		if p.key == id.substr(0, 1):
			return p.mastery if id.ends_with("m") else p.nodes[int(id.substr(1)) - 1]
	return {}


## The field's current value (null if the key names nothing).
static func value(key: String):
	var at = _locate(key)
	return null if at == null else _read(at)


## [container, key or index] holding the field's number, or null.
static func _locate(key: String):
	var file := key.get_slice(":", 0)
	var path := key.get_slice(":", 1).split(".")
	if file == "Towers":
		if path.size() != 3 or not Rework.TREES.has(path[0]) or not node_ids(path[0]).has(path[1]):
			return null
		var n := _node(path[0], path[1])
		if path[2] == "cost":
			return [n, "cost"]
		for part in ["set", "add"]:
			if n.get(part, {}).has(path[2]):
				return [n[part], path[2]]
		return null
	if not SCRIPTS.has(file):
		return null
	var script = SCRIPTS[file]
	if path.size() == 1:
		return [script, path[0]] if script.get(path[0]) is int or script.get(path[0]) is float else null
	var c = script.get(path[0])
	for i in range(1, path.size()):
		var k = _key(c, path[i])
		if k == null:
			return null
		if i == path.size() - 1:
			return [c, k]
		c = c[k]
	return null


static func _key(c, s: String):
	if c is Dictionary:
		if c.has(s):
			return s
		if s.is_valid_int() and c.has(int(s)):
			return int(s)
	elif c is Array and s.is_valid_int() and int(s) < c.size():
		return int(s)
	return null


## Sets a field and brings the live run up to date. Returns false if the key names nothing.
static func set_value(key: String, v: float) -> bool:
	var at = _locate(key)
	if at == null:
		return false
	var was = _read(at)
	var nv = int(round(v)) if was is int else v
	if not _orig.has(key):
		_orig[key] = was
	var before := _snapshot()
	_write(at, nv)
	if key.begins_with("Towers:") and key.ends_with(".base.cost"):
		Rework.TREES[key.get_slice(":", 1).get_slice(".", 0)]["cost"] = nv
	if is_equal_approx(float(_orig[key]), float(nv)):
		_orig.erase(key)
	_refresh(before)
	return true


static func _read(at: Array):
	return at[0].get(at[1]) if at[0] is Script else at[0][at[1]]


static func _write(at: Array, v) -> void:
	if at[0] is Script:
		at[0].set(at[1], v)
	else:
		at[0][at[1]] = v


## Puts one field back to its balance.md value.
static func revert(key: String) -> void:
	if _orig.has(key):
		set_value(key, float(_orig[key]))


static func revert_all() -> void:
	for key in _orig.keys():
		revert(key)


## The changed fields: [{key, old (balance.md's value), new}], in field order.
static func changes() -> Array:
	var out: Array = []
	for f in fields():
		if _orig.has(f.key):
			out.append({"key": f.key, "old": _orig[f.key], "new": value(f.key)})
	return out


static func changed(key: String) -> bool:
	return _orig.has(key)


## Each live enemy's data before an edit (its `def`, copied), so `Enemy.retune` can see what changed.
static func _snapshot() -> Dictionary:
	var out := {}
	if game != null:
		for e in game.enemies:
			out[e] = e.def.duplicate(true)
	return out


## After an edit: leak costs follow strength, enemies on the field and placed towers take the new numbers, prices
## follow the mode's multiplier (research refresh: Game.apply_research), and the run is marked tuned.
static func _refresh(before: Dictionary) -> void:
	EnemyTraits._cache = {}
	_derive_leaks()
	if game == null:
		return
	for e in before:
		e.retune(before[e])
	for type in game.tower_mods:
		game.tower_mods[type]["price"] = Difficulty.price(game.difficulty)
	game.apply_research(game.research)
	if not _orig.is_empty():
		game.tuned = true


## Every enemy's leak cost, as tools/balance.mjs derives it: a boss its first boss round, else its strength band.
static func _derive_leaks() -> void:
	var waves = SCRIPTS.Waves
	var rounds: Array = waves.BOSS_ROUNDS.keys()
	rounds.sort()
	for id in Enemies.ENEMIES:
		var d: Dictionary = Enemies.ENEMIES[id]
		var lives := Enemies.leak_band(Enemies.strength_of(d))
		for r in rounds:
			if waves.BOSS_ROUNDS[r].any(func(x): return x[0] == id):
				lives = int(r)
				break
		d["lives"] = lives
