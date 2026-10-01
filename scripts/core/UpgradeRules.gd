extends RefCounted
## Upgrade rules shared by the tower panel, the view-only upgrade tree and the upgrade preview
## (design/upgrade_rework.md):
## - what each upgrade card in the tower panel shows, and why it can't be bought;
## - which tree nodes a tower can still reach, and so preview;
## - the upgrade state a preview builds;
## - which enemies show an upgrade off.
##
## Tree node ids: "t1" and "t2" (the trunk), then "a1".."a4" and "am" (mastery) for each branch.

const Tower = preload("res://scripts/entities/Tower.gd")
const Enemies = preload("res://data/enemies.gd")

const KEYS := {"trunk": "U", "a": "U", "b": "I", "c": "O"}


## "a2" -> ["a", 2]; "am" -> ["a", 5]; "t1" -> ["", 1].
static func parse(id: String) -> Array:
	if id.begins_with("t"):
		return ["", int(id.substr(1))]
	return [id.substr(0, 1), 5 if id.ends_with("m") else int(id.substr(1))]


## The data node a tree id stands for on tower type `type`.
static func node_for(type: String, id: String) -> Dictionary:
	var p := parse(id)
	var tr: Dictionary = Tower.tree(type)
	if p[0] == "":
		return tr.tiers[int(p[1]) - 1]
	for br in tr.branches:
		if br.key == p[0]:
			return br.mastery if int(p[1]) == 5 else br.nodes[int(p[1]) - 1]
	return {}


# --- Tower panel cards ---------------------------------------------------------------------------

## The tower panel's cards for `t`: the Retrofit alone before it's bought, then one per branch.
static func card_keys(t) -> Array:
	return ["trunk"] if t.trunk < 2 else Tower.BRANCHES.duplicate()


## One card: {key, hotkey, state, node, cost, reason}.
## state: "buy" (can buy now), "short" (not enough credits), "research" (mastery needs research),
## "capped" (secondary at its cap), "locked" (two other branches started), "done" (mastered or
## fully upgraded). `node` is the upgrade the card is about (for "done", the last one owned).
static func card(t, key: String, gold: int) -> Dictionary:
	var c := {"key": key, "hotkey": KEYS[key], "state": "", "node": {}, "cost": 0, "reason": ""}
	if key == "trunk":
		c.node = Tower.tree(t.type).tiers[1]
		c.cost = t.upgrade_cost()
		c.state = "buy" if gold >= c.cost else "short"
		if c.state == "short":
			c.reason = "Need %d more credits" % (c.cost - gold)
		return c
	var br: Dictionary = t.branch(key)
	var d: int = t.depth[key]
	var why: String = t.block_reason(key)
	if why == "":
		c.node = t.next_node(key)
		c.cost = t.upgrade_cost(key)
		c.state = "buy" if gold >= c.cost else "short"
		if c.state == "short":
			c.reason = "Need %d more credits" % (c.cost - gold)
	elif why.begins_with("Needs"):
		c.node = br.mastery
		# What it will cost once researched (upgrade_cost is 0 while it can't be bought).
		c.cost = t._price(int(br.mastery.cost))
		c.state = "research"
		c.reason = why
	elif why.begins_with("Blocked"):
		c.node = br.nodes[mini(d, Tower.BRANCH_STEPS - 1)]
		c.state = "capped"
		c.reason = "Secondary capped at %d upgrades" % Tower.SECONDARY_CAP
	elif why.begins_with("Locked"):
		c.node = br.nodes[0]
		c.state = "locked"
		c.reason = "Branch locked (two branches started)"
	else:
		c.node = br.mastery if t.mastered and t.primary() == key else br.nodes[maxi(0, mini(d, Tower.BRANCH_STEPS) - 1)]
		c.state = "done"
		c.reason = "Mastered" if t.mastered and t.primary() == key else "Fully upgraded"
	return c


# --- Reachable nodes and preview state ---------------------------------------------------------

## Whether `t` could still get node `id` on its current path (owned nodes count). Masteries count
## even before their research; the third branch once two are started, and secondary steps past
## the cap, don't.
static func reachable(t, id: String) -> bool:
	var p := parse(id)
	var b: String = p[0]
	var k: int = p[1]
	if b == "" or t.trunk < 2:
		return true
	if not t.started.has(b) and t.started.size() >= 2:
		return false
	if t.locked_in() and b != t.primary():
		return k <= Tower.SECONDARY_CAP
	return true


## The upgrade state a preview of node `id` builds on `t`: what it owns now, plus everything on the
## way to `id` on its branch. {trunk, depth, started, mastered}
static func preview_state(t, id: String) -> Dictionary:
	var st := {"trunk": int(t.trunk), "depth": t.depth.duplicate(), "started": t.started.duplicate(), "mastered": bool(t.mastered)}
	var p := parse(id)
	var b: String = p[0]
	var k: int = p[1]
	if b == "":
		st.trunk = maxi(st.trunk, k)
		return st
	st.trunk = 2
	var want := mini(k, Tower.BRANCH_STEPS)
	if int(st.depth[b]) < want:
		if int(st.depth[b]) == 0:
			st.started.append(b)
		st.depth[b] = want
	if k == 5:
		st.mastered = true
	return st


# --- Preview enemies ---------------------------------------------------------------------------

## Which enemies show an upgrade off, from its stats (first matching rule, in order). Each entry is
## [stat keys that trigger it, enemies to send].
const ENEMY_RULES := [
	[["shred", "shred_max", "armor_break", "armor_break_time", "pierce", "armor_field"], ["brute", "rampart", "brute"]],
	[["air_mult"], ["bat", "gunship", "bat", "bat"]],
	[["splash", "chains", "chain_range", "cone", "pellets", "bomblets", "bomblet_splash", "burn_dps", "burn_time", "linger", "cascade", "cascade_radius", "multishot", "beams", "sweep", "missiles"], ["runner", "swarmling", "swarmling", "runner", "swarmling", "swarmling", "runner"]],
	[["slow", "slow_time", "stun", "push", "pull", "field_slow", "implode_pct", "implode_every"], ["runner", "grunt", "runner", "runner", "grunt"]],
	[["boss_mult", "boss_bounty"], ["juggernaut"]],
	[["disrupt", "unearth", "hits_burrowed"], ["burrower", "burrower", "grunt"]],
	[["mark", "expose", "vuln", "static_vuln", "sensor"], ["phantom", "phantom", "grunt"]],
	[["shield_mult", "bypass_shield", "strip", "block_barrier", "block_grants"], ["aegis", "aegis", "bulwark"]],
	[["suppress", "suppress_hit", "suppress_spread", "suppress_boss", "jam", "dampen", "block_repair"], ["shaman", "jammer", "grunt", "mender"]],
	[["buff_dmg", "buff_rate", "buff_range", "income", "discount", "interest", "interest_cap", "sell_field", "bounty_bonus"], ["grunt", "runner", "grunt", "grunt"]],
]
const DEFAULT_GROUND := ["grunt", "runner", "grunt", "grunt"]


## The enemies a preview of `node` sends, for a tower that hits air and/or ground. A rule is skipped
## if the tower can't hit any of its enemies (e.g. a ground rule for an air-only tower).
static func enemies_for(node: Dictionary, hits_air: bool, hits_ground: bool) -> Array:
	var keys: Array = []
	for part in ["set", "add"]:
		if node.has(part):
			keys.append_array((node[part] as Dictionary).keys())
	for rule in ENEMY_RULES:
		if not keys.any(func(k): return (rule[0] as Array).has(k)):
			continue
		var list: Array = (rule[1] as Array).filter(func(e): return _hittable(e, hits_air, hits_ground))
		if not list.is_empty():
			return list
	var out: Array = DEFAULT_GROUND.duplicate() if hits_ground else []
	if hits_air:
		out.append("bat")
		if not hits_ground:
			out.append_array(["bat", "locust", "bat"])
	return out


## Whether the preview puts a plain Pulse Turret next to the tower: support and economy towers
## (pylons, sensors, the Scrapyard) show what they do through a tower they help. The preview then
## picks enemies for what that partner can hit.
static func needs_partner(t) -> bool:
	return t.is_support() or t.is_economy()


static func _hittable(enemy: String, air: bool, ground: bool) -> bool:
	var flying := bool(Enemies.ENEMIES[enemy].get("flying", false))
	return (flying and air) or (not flying and ground)
