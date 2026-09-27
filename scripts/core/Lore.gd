extends RefCounted
## Text for the in-game Codex, generated from the game's own data so it always matches the rules:
## glossary entries with their numbers filled in from the constants, enemy ability sentences and
## counters, and each tower's full upgrade path with the stats the game actually uses.

const Glossary = preload("res://data/glossary.gd")
const Enemies = preload("res://data/enemies.gd")
const Towers = preload("res://data/towers.gd")
const Trees = preload("res://data/tower_trees.gd")
const Waves = preload("res://data/waves.gd")
const Abilities = preload("res://data/abilities.gd")
const Game = preload("res://scripts/core/Game.gd")
const Enemy = preload("res://scripts/entities/Enemy.gd")
const Tower = preload("res://scripts/entities/Tower.gd")

static var _values := {}


## The numbers the glossary quotes, taken from the constants.
static func values() -> Dictionary:
	if _values.is_empty():
		var m: Dictionary = Abilities.ABILITIES.meteor
		var w: Dictionary = Abilities.ABILITIES.warp
		_values = {
			"min_damage": roundi(Enemy.MIN_DAMAGE_FRACTION * 100.0), "slow_cap": roundi(Enemy.SLOW_CAP * 100.0),
			"stun_guard": _num(Enemy.STUN_GUARD), "shove_budget": roundi(Enemy.SHOVE_BUDGET),
			"boss_stun": roundi(Game.BOSS_STUN_FACTOR * 100.0), "boss_push": roundi(Game.BOSS_PUSH_FACTOR * 100.0),
			"shock": _num(Game.SHOCK_PCT * 100.0), "shock_boss": _num(Game.SHOCK_BOSS_PCT * 100.0),
			"sludge": roundi(Game.SLUDGE_SLOW * 100.0), "hit_reveal": _num(Game.HIT_REVEAL_TIME),
			"site": roundi(Tower.SITE_DAMAGE * 100.0), "rubble": Game.RUBBLE_COST, "gate_cd": _num(Game.GATE_COOLDOWN),
			"sell": roundi(Game.SELL_REFUND * 100.0), "start_gold": Game.START_GOLD, "bounty_exp": _num(Waves.bounty_exp),
			"late_start": Waves.LATE_START, "secondary_cap": Tower.SECONDARY_CAP,
			"meteor_damage": roundi(float(m.damage)), "meteor_radius": roundi(float(m.radius)), "meteor_delay": _num(float(m.delay)),
			"meteor_cd": roundi(float(m.cooldown)), "warp_slow": roundi(float(w.slow) * 100.0), "warp_time": _num(float(w.duration)),
			"warp_cd": roundi(float(w.cooldown)),
		}
	return _values


static func _num(v: float) -> String:
	return str(roundi(v)) if is_equal_approx(v, roundf(v)) else ("%.2f" % v).rstrip("0")


## A glossary entry's text with its numbers filled in.
static func text(id: String) -> String:
	return str(Glossary.ENTRIES[id].text).format(values())


## One sentence per ability an enemy has, with its real numbers.
static func enemy_abilities(d: Dictionary) -> Array:
	var out: Array = []
	var pct := func(v) -> String: return "%d%%" % roundi(float(v) * 100.0)
	var ename := func(id) -> String: return str(Enemies.ENEMIES[id].name)
	if d.get("flying", false):
		out.append("Flies straight at the core on the air lane. Only towers that hit air can hit it.")
	if d.get("cloaked", false):
		out.append("Cloaked: towers can only target it inside a Sensor Array field, or briefly after area damage.")
	if d.has("shield"):
		out.append("Energy barrier of %s that absorbs damage before the hull (armor doesn't apply) and recharges after %s s without damage." % [_num(float(d.shield)), _num(float(d.shield_delay))])
	if d.has("heal_pct"):
		out.append("Repairs %s of max health to non-boss enemies within %s px every %s s." % [pct.call(d.heal_pct), _num(float(d.heal_radius)), _num(float(d.heal_interval))])
	if d.has("split_type"):
		out.append("Splits into %d %ss when destroyed." % [int(d.split_count), ename.call(d.split_type)])
	if d.has("emp_radius"):
		out.append("EMP every %s s knocks towers within %s px offline for %s s." % [_num(float(d.emp_interval)), _num(float(d.emp_radius)), _num(float(d.emp_duration))])
	if d.has("burrow_interval"):
		out.append("Burrows for %s s every %s s: it can't be targeted or hurt, and hazards don't touch it." % [_num(float(d.burrow_time)), _num(float(d.burrow_interval))])
	if d.has("blink_interval"):
		out.append("Teleports %s px down the lane every %s s. A slow or stun resets the charge." % [_num(float(d.blink_distance)), _num(float(d.blink_interval))])
	if d.has("regen_pct"):
		out.append("Regenerates %s of max health per second after %s s without taking damage." % [pct.call(d.regen_pct), _num(float(d.regen_delay))])
	if d.has("aura_radius"):
		out.append("Other non-boss enemies within %s px move %s faster." % [_num(float(d.aura_radius)), pct.call(d.aura_haste)])
	if d.has("grant_interval"):
		out.append("Every %s s gives enemies within %s px (not itself) a barrier worth %s of their max health." % [_num(float(d.grant_interval)), _num(float(d.grant_radius)), pct.call(d.grant_pct)])
	if d.has("spawn_type"):
		out.append("%s %d %ss every %s s." % ["Launches" if d.get("flying", false) else "Spawns", int(d.spawn_count), ename.call(d.spawn_type), _num(float(d.spawn_interval))])
	if d.has("phases"):
		var at: Array = d.phases.map(func(p): return pct.call(p))
		out.append("At %s health it sheds %s armor, speeds up x%s and drops %d %ss." % [" and ".join(PackedStringArray(at)), _num(float(d.phase_armor)), _num(float(d.phase_speed)), int(d.phase_spawn_count), ename.call(d.phase_spawn)])
	if d.get("cc_immune", false):
		out.append("Immune to slows, stuns and shoves (unless exposed).")
	if d.get("stun_immune", false):
		out.append("Can't be stunned.")
	if d.has("slow_resist"):
		out.append("Resists %s of every slow." % pct.call(d.slow_resist))
	return out


## Glossary entries that explain how to deal with an enemy.
static func enemy_topics(d: Dictionary) -> Array:
	var out: Array = []
	if float(d.get("armor", 0.0)) >= 3.0:
		out.append("armor")
	for pair in [["shield", "barrier"], ["cloaked", "cloak"], ["burrow_interval", "burrow"], ["blink_interval", "blink"],
			["heal_pct", "regen"], ["regen_pct", "regen"], ["aura_radius", "haste"], ["grant_interval", "barrier_grant"],
			["emp_radius", "emp"], ["split_type", "split"], ["spawn_type", "split"], ["phases", "split"], ["cc_immune", "cc_immune"],
			["stun_immune", "cc_immune"], ["boss", "boss_rules"]]:
		var v = d.get(pair[0])
		if v != null and not (v is bool and not v) and not out.has(pair[1]):
			out.append(pair[1])
	return out


## Tower types that can hit this enemy.
static func hitters(d: Dictionary) -> Array:
	var flying: bool = d.get("flying", false)
	return Towers.ORDER.filter(func(t):
		var td: Dictionary = Towers.TOWERS[t]
		return not td.get("support", false) and (bool(td.get("air", false)) if flying else bool(td.get("ground", true))))


## A tower's whole upgrade path as rows: {label, name, cost, blurb, stats, prev}. `stats` are the
## composed stats at that step (what the game uses before research); `prev` the step before.
static func tower_rows(type: String) -> Array:
	var tr: Dictionary = Trees.TREES[type]
	var ln := Tower.lines(type)
	var rows: Array = []
	rows.append({"label": Tower.trunk_name(1), "name": tr.tiers[0].name, "cost": int(tr.tiers[0].cost), "blurb": tr.tiers[0].blurb, "stats": ln.t1, "prev": {}, "branch": ""})
	rows.append({"label": Tower.trunk_name(2), "name": tr.tiers[1].name, "cost": int(tr.tiers[1].cost), "blurb": tr.tiers[1].blurb, "stats": ln.t2, "prev": ln.t1, "branch": ""})
	for b in tr.branches:
		var key: String = b.key
		for i in b.nodes.size():
			var nd: Dictionary = b.nodes[i]
			rows.append({"label": "%s T%d" % [key.to_upper(), i + 1], "name": nd.name, "cost": int(nd.cost), "blurb": nd.blurb,
				"stats": ln[key][i + 1], "prev": ln.t2 if i == 0 else ln[key][i], "branch": str(b.id)})
		rows.append({"label": "%s Mastery" % key.to_upper(), "name": b.mastery.name, "cost": int(b.mastery.cost), "blurb": b.mastery.blurb,
			"stats": ln[key + "_m"], "prev": ln[key][b.nodes.size()], "branch": str(b.id)})
	return rows
