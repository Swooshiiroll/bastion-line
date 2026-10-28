extends RefCounted
## Text for the in-game Codex, generated from the game's own data so it always matches the rules:
## glossary entries with their numbers filled in from the constants, enemy ability sentences and
## counters, and each tower's full upgrade path with the stats the game actually uses.

const Glossary = preload("res://data/glossary.gd")
const Enemies = preload("res://data/enemies.gd")
const Towers = preload("res://data/towers.gd")
const Waves = preload("res://data/waves.gd")
const Modifiers = preload("res://data/modifiers.gd")
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
			"leak_1": roundi(float(Enemies.LEAK_BANDS[0])), "leak_2": roundi(float(Enemies.LEAK_BANDS[1])), "leak_3": roundi(float(Enemies.LEAK_BANDS[2])),
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
		if d.get("track", false):
			out.append("Flies along the track. Only towers that hit air can hit it.")
		else:
			out.append("Flies straight at the core on the air lane. Only towers that hit air can hit it.")
	if int(d.get("pack", 1)) > 1:
		out.append("Always arrives as a pair on one lane." if int(d.pack) == 2 else "Flies in clusters of %d; each one is its own enemy." % int(d.pack))
	if d.get("cloaked", false):
		out.append("Cloaked: towers can only target it when a Radar Tower ping reveals it, or briefly after damage hits it.")
	if d.get("energy_only", false):
		out.append("Only energy damage hurts it (beams, chains, fields, burns, Tesla arcs); physical hits do nothing.")
	if d.has("disguise"):
		out.append("Looks, moves and ranks like a %s until it drops below %s health; then it runs at %s px/s for %s s, as itself. A Radar Tower with Disguise Breaker uncovers it with a ping." % [ename.call(d.disguise), pct.call(d.reveal_at), _num(float(d.flee_speed)), _num(float(d.flee_time))])
	if d.get("fake_rank", false):
		out.append("Ranks above every non-boss (and shows as a %s), so Strongest towers aim at it, but it does nothing else. A Radar Tower with Signal Analysis sees through it." % str(d.get("shown_role", "tank")).capitalize())
	if d.has("holo_interval"):
		out.append("Every %s s projects %d holograms with 1 health that soak shots and walk to the core; they never leak and vanish when it dies. A Radar Tower with Illusion Filter marks them as fakes that towers ignore." % [_num(float(d.holo_interval)), int(d.holo_count)])
	if d.has("siphon_radius"):
		out.append("Towers within %s px fire %s slower and reach %s less far (the strongest Siphon applies)." % [_num(float(d.siphon_radius)), pct.call(d.siphon_rate), pct.call(d.siphon_range)])
	if d.has("adrenaline"):
		out.append("Below %s health it runs %s faster." % [pct.call(d.adrenaline_at), pct.call(d.adrenaline)])
	if d.has("shed_at"):
		out.append("Below %s health its plates come away: its armor drops to %s and it speeds up x%s." % [pct.call(d.shed_at), _num(float(d.shed_armor)), _num(float(d.shed_speed))])
	if d.has("shield"):
		out.append("Energy barrier of %s that absorbs damage before the hull (armor doesn't apply) and recharges after %s s without damage." % [_num(float(d.shield)), _num(float(d.shield_delay))])
	if d.has("heal_pct"):
		out.append("Repairs %s of max health to non-boss enemies within %s px every %s s." % [pct.call(d.heal_pct), _num(float(d.heal_radius)), _num(float(d.heal_interval))])
	if d.has("split_type"):
		out.append("Splits into %d %ss when destroyed." % [int(d.split_count), ename.call(d.split_type)])
	if d.has("emp_charge"):
		out.append("Every %s s it charges for %s s, then blacks out towers within %s px for %s s. A stun, silence or Overload Circuits arc during the charge cancels it." % [_num(float(d.emp_interval)), _num(float(d.emp_charge)), _num(float(d.emp_radius)), _num(float(d.emp_duration))])
	elif d.has("emp_radius"):
		out.append("EMP every %s s knocks towers within %s px offline for %s s." % [_num(float(d.emp_interval)), _num(float(d.emp_radius)), _num(float(d.emp_duration))])
	if d.has("burrow_interval"):
		out.append("Burrows for %s s every %s s: it can't be targeted or hurt, and hazards don't touch it." % [_num(float(d.burrow_time)), _num(float(d.burrow_interval))])
	if d.has("blink_interval"):
		out.append("Teleports %s px down the lane every %s s. A slow or stun resets the charge." % [_num(float(d.blink_distance)), _num(float(d.blink_interval))])
	if d.has("wake_radius"):
		out.append("Where it lands, other non-boss enemies within %s px move %s faster for %s s." % [_num(float(d.wake_radius)), pct.call(d.wake_haste), _num(float(d.wake_time))])
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


## The line under an enemy's name: role and tier, strength, how it moves, and the round it's first seen.
static func enemy_line(type: String) -> String:
	var d: Dictionary = Enemies.ENEMIES[type]
	var cls := ("Flying boss" if d.get("flying", false) else "Boss") if d.get("boss", false) else ("Flyer" if d.get("flying", false) else "Ground")
	return "%s  ·  strength %s  ·  %s  ·  first seen in round %d" % [Enemies.role_label(d), _num(roundf(Enemies.strength(type))), cls, Waves.first_round(type)]


## The modifiers enemy `type` can arrive with as an elite (none for bosses and tricks).
static func enemy_mods(type: String) -> Array:
	return Modifiers.ORDER.filter(func(m): return Modifiers.allowed(type, m))


## Every modifier as {id, name, intro, blurb}, in order.
static func modifier_rows() -> Array:
	return Modifiers.ORDER.map(func(m):
		var md: Dictionary = Modifiers.MODIFIERS[m]
		return {"id": m, "name": str(md.name), "intro": int(md.intro), "blurb": str(md.blurb)})


## The roster by role: [{role, tiers: [[type...] for T1..T4], other: [type...]}]. Tier-0 members (specials, bosses) go in `other`.
static func role_rows() -> Array:
	var out: Array = []
	for role in ["swarm", "rusher", "tank", "support", "disruptor", "evader", "special", "boss"]:
		var row := {"role": role, "tiers": [[], [], [], []], "other": []}
		for t in Enemies.ORDER:
			var d: Dictionary = Enemies.ENEMIES[t]
			if str(d.get("role", "")) != role:
				continue
			var tier := int(d.get("tier", 0))
			if tier >= 1 and tier <= 4:
				(row.tiers[tier - 1] as Array).append(t)
			else:
				(row.other as Array).append(t)
		out.append(row)
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
		var td: Dictionary = Towers.def(t)
		if td.support or td.economy:
			return false
		return bool(td.air) if flying else bool(td.ground))


## A tower's whole upgrade tree as rows: {label, name, cost, blurb, stats, prev, branch}. `stats` are the composed stats at
## that step (what the game uses before research); `prev` the step before. The stock tower, each Retrofit option (on the
## stock tower), then each path's four steps and its mastery (on the stock tower).
static func tower_rows(type: String) -> Array:
	var tr: Dictionary = Towers.Rework.TREES[type]
	var base: Dictionary = Tower.rework_base(type)
	var rows: Array = []
	rows.append({"label": "Stock", "name": tr.name, "cost": int(tr.cost), "blurb": tr.base.get("blurb", tr.blurb), "stats": base, "prev": {}, "branch": ""})
	for r in tr.retrofits:
		rows.append({"label": "Retrofit", "name": r.name, "cost": int(r.cost), "blurb": r.blurb, "stats": Tower._apply_node(base, r), "prev": base, "branch": ""})
	for p in tr.paths:
		var key: String = p.key
		var cur: Dictionary = base
		for n in p.nodes.size():
			var nd: Dictionary = p.nodes[n]
			var nxt: Dictionary = Tower._apply_node(cur, nd)
			rows.append({"label": "%s T%d" % [key.to_upper(), n + 1], "name": nd.name, "cost": int(nd.cost), "blurb": nd.blurb,
				"stats": nxt, "prev": cur, "branch": key})
			cur = nxt
		rows.append({"label": "%s Mastery" % key.to_upper(), "name": p.mastery.name, "cost": int(p.mastery.cost), "blurb": p.mastery.blurb,
			"stats": Tower._apply_node(cur, p.mastery), "prev": cur, "branch": key})
	return rows
