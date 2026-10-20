extends RefCounted
## A placed tower: its type, upgrade state, research modifiers, buffs from pylons, and per-type
## state. Firing logic lives in Game so it can see every entity.
##
## Upgrades (v3.1): a two-tier trunk, then three branches (a, b, c) of four upgrades each (the first
## is the specialization) and a mastery. A tower can climb two branches freely up to two upgrades
## each; the first to reach its third upgrade becomes the primary and the other (the secondary) is
## blocked where it is. The primary can go on to its mastery once the tower's Mastery is researched.
##
## Stats: the primary branch's line at its depth, plus the secondary's difference from Tier 2.
## Branch data comes from data/tower_trees.gd (generated from design/upgrade_trees.md); keys the
## design file doesn't mention (projectile speed, chain falloff, ...) come from data/towers.gd.

const Towers = preload("res://data/towers.gd")
const Trees = preload("res://data/tower_trees.gd")
const Research = preload("res://scripts/core/Research.gd")
const Rework = preload("res://data/rework_trees.gd")

enum Mode { FIRST, LAST, STRONG, CLOSE }
const MODE_NAMES := ["First", "Last", "Strongest", "Closest"]
## Which kind of enemy a tower that hits both air and ground prefers (it falls back to the other).
const PRIORITY_NAMES := ["Any", "Air", "Ground"]
const BRANCHES := ["a", "b", "c"]
const BRANCH_STEPS := 4
const SECONDARY_CAP := 2
## Compatibility tiers for callers that think in v3.0 terms: 1-2 trunk, 3 on a branch, 4 mastered.
const SPEC_TIER := 3
const MASTERY_TIER := 4
## Terrain bonuses: high ground (H) +range, power node (P) +damage.
const SITE_RANGE := 0.15
const SITE_DAMAGE := 0.15

## What an attack-style specialization adds when it's the secondary instead of its stat line (see
## the Combinations section of design/upgrade_trees.md).
const ATTACK_SECONDARY := {
	"flechette": {"flechette_every": 3, "flechette_pellets": 3, "flechette_cone": 30.0},
	"ionstorm": {"storm_on_hit": 2.0, "storm_radius": 60.0, "storm_dps": 16.0},
	"sweeper": {"sweep_wobble": 25.0},
	"well": {"pull_alternate": 25.0},
	"bombers": {"bombers": 2.0, "bomb_damage": 60.0, "bomb_splash": 40.0},
}
const NON_STATS := ["name", "cost", "blurb", "mastery", "specs", "spec_order"]

var type := ""
var def: Dictionary
## The reworked towers (issue #59): no gating trunk; an optional Retrofit (one of up to three options, chosen when
## bought, -1 until then) and three paths from the start. Old towers keep the trunk.
var is_rework := false
var retrofit := -1:
	set(v):
		retrofit = v
		_dirty = true
## Tiles along each side of the footprint: 1, or 2 for the Scrapyard and Drone Bay. `cell` is the
## top-left tile and `pos` the footprint's centre.
var size := 1
var cell := Vector2i.ZERO
var pos := Vector2.ZERO
var mode := 0
var priority := 0
var kills := 0
var spent := 0
var cooldown := 0.0
var target = null
var aim := -PI / 2.0
var fire_flash := 0.0
var damage_dealt := 0.0
var buff_dmg := 0.0
var buff_rate := 0.0
var buff_range := 0.0
## Boost Tower Crit Link: extra crit chance for towers in its field.
var buff_crit := 0.0
## Augmentation Tower effects on this tower (the strongest of each from towers in range): crit multiplier, the share of its damage that is energy,
## bonus energy damage, ricochet chance and strength, and whether a bounce can bounce again.
var aug_crit_mult := 2.0
var aug_energy := 0.0
var aug_energy_bonus := 0.0
var aug_ricochet := 0.0
var aug_ricochet_str := 0.5
var aug_bounce_again := false
## Set by a Supply Depot in range: upgrade discount and sell refund (0 = none).
var discount := 0.0
var refund_field := 0.0
var ramp := 0.0
var ramp_mult := 1.0
var beam_targets: Array = []
## Laser Tower (reworked): seconds each beam has held its target, parallel to beam_targets.
var beam_ramps: Array = []
## Artillery Cannon: the spot it shells (chosen by the player; set to the nearest track point when built) and the shell type loaded.
var aim_point := Vector2.ZERO
var aim_set := false
var shell := "he"
## Drone Bay (reworked): the loadout its drones fly ("gun", "missiles", "bombs", "laser", "full").
var loadout := "gun"
## CAS Gunship: where the plane is on its orbit (radians) and each gun's cooldown. The orbit centre is `aim_point`.
var orbit_angle := 0.0
var gun_cds := {}
## Seconds left knocked offline by a Jammer's EMP.
var disabled := 0.0
## The special tile under the tower: "H" (high ground), "P" (power node) or "".
var site := ""
## Research modifiers for this tower type (see Research.tower_mods). Replaced by Game.apply_research
## when research changes mid-run; call invalidate() after.
var mods := {}
## Per-type attack state (pulse counters, sweep angle, drone wing...).
var pulse_count := 0
var sweep_t := 0.0
var sweep_angles: Array = []
## Sandbox DPS meter: damage dealt per 0.25 s bucket over the last 5 s, newest last.
var dps_buckets: Array = []
var _dps_mark := 0.0
## Drone Bay: its drones ({kind, pos, target, cd}). Not saved; rebuilt each round.
var wing: Array = []
## The enemies the last volley went at (gun 0 first); the view turns each extra gun toward its own.
var shot_targets: Array = []

## Upgrade state. Change it through buy(), or call invalidate() after editing it directly.
var trunk := 1:
	set(v):
		trunk = v
		_dirty = true
var depth := {"a": 0, "b": 0, "c": 0}
## Branch keys in the order they were started (at most two).
var started: Array = []
var mastered := false
## Uncapped towers (the CAS Gunship): the paths that took their mastery (each path has its own).
var mastered_paths: Array = []

var tier: int:
	get:
		if mastered:
			return MASTERY_TIER
		if is_rework:
			return SPEC_TIER if not started.is_empty() else (2 if retrofit >= 0 else 1)
		return SPEC_TIER if not started.is_empty() else trunk

## The primary branch's specialization id ("" before any branch is started).
var spec: String:
	get:
		if is_rework:
			return look_key()
		var p := primary()
		return str(branch(p).id) if p != "" else ""

## The specialization shown in the tower's name and colour: stock until the primary locks in at
## its third upgrade (the model still shows branch details from the first).
var shown_spec: String:
	get:
		if is_rework:
			return ""
		return spec if locked_in() else ""

var _cache := {}
var _dirty := true

static var _lines := {}


func setup(tower_type: String, at_cell: Vector2i, at_pos: Vector2, research_mods := {}) -> void:
	type = tower_type
	def = Towers.def(tower_type)
	is_rework = Towers.is_rework(tower_type)
	if is_rework:
		trunk = 2   # no gating trunk: the old upgrade rules read trunk >= 2 as "paths open"
	size = int(def.get("size", 1))
	cell = at_cell
	pos = at_pos
	mods = research_mods
	_dirty = true
	spent = build_cost()


# --- Tree data ---------------------------------------------------------------------------------

static func tree(tower_type: String) -> Dictionary:
	return Trees.TREES[tower_type]


func branch(key: String) -> Dictionary:
	if is_rework:
		for p in rework_tree().paths:
			if p.key == key:
				return p
		return {}
	for b in tree(type).branches:
		if b.key == key:
			return b
	return {}


## The reworked tower's data (base, retrofits, paths).
func rework_tree() -> Dictionary:
	return Rework.TREES[type]


## The branch key whose specialization id (or key) is `id_or_key`, or "".
func branch_key(id_or_key: String) -> String:
	for b in tree(type).branches:
		if b.key == id_or_key or b.id == id_or_key:
			return b.key
	return ""


func is_attack_style(key: String) -> bool:
	return not is_rework and bool(branch(key).get("attack", false))


static func _clean(d: Dictionary) -> Dictionary:
	var out := {}
	for k in d:
		if not (k in NON_STATS) and not (d[k] is Dictionary) and not (d[k] is Array):
			out[k] = d[k]
	return out


static func _apply_node(base: Dictionary, node: Dictionary) -> Dictionary:
	var out := base.duplicate()
	for k in node.get("add", {}):
		out[k] = float(out.get(k, 0.0)) + float(node.add[k])
	for k in node.get("set", {}):
		out[k] = node.set[k]
	return out


## Full stat lines for a tower type: {"t1", "t2", "<b>": [depth 0..4], "<b>_m": mastery}.
static func lines(tower_type: String) -> Dictionary:
	if _lines.has(tower_type):
		return _lines[tower_type]
	var legacy: Dictionary = Towers.TOWERS[tower_type]
	var tr := tree(tower_type)
	var legacy_tiers: Array = legacy.get("tiers", [{}, {}])
	var t1 := _apply_node(_clean(legacy_tiers[0]), tr.tiers[0])
	var t2 := _apply_node(_clean(legacy_tiers[1]), tr.tiers[1])
	var out := {"t1": t1, "t2": t2}
	var legacy_specs: Dictionary = legacy.get("specs", {})
	for b in tr.branches:
		var lspec: Dictionary = legacy_specs.get(b.id, {})
		var line: Array = [t2]
		var cur := t2.duplicate()
		for k in _clean(lspec):
			cur[k] = lspec[k]
		cur = _apply_node(cur, b.nodes[0])
		line.append(cur)
		for i in range(1, BRANCH_STEPS):
			cur = _apply_node(cur, b.nodes[i])
			line.append(cur)
		var m := cur.duplicate()
		if lspec.has("mastery"):
			for k in _clean(lspec.mastery):
				m[k] = lspec.mastery[k]
		m = _apply_node(m, b.mastery)
		out[b.key] = line
		out[b.key + "_m"] = m
	_lines[tower_type] = out
	return out


# --- Upgrade state -----------------------------------------------------------------------------

## The primary branch: the one at depth 3+, otherwise the deepest (earliest started on a tie).
func primary() -> String:
	var best := ""
	var best_d := 0
	for b in started:
		var d: int = depth[b]
		if d >= 3:
			return b
		if d > best_d:
			best = b
			best_d = d
	return best


## The other started branch, if any.
func secondary() -> String:
	var p := primary()
	for b in started:
		if b != p:
			return b
	return ""


func locked_in() -> bool:
	for b in started:
		if int(depth[b]) >= 3:
			return true
	return false


## Why branch `key` can't take its next upgrade right now ("" if it can).
func block_reason(key: String) -> String:
	if not is_rework and trunk < 2:
		return "Retrofit it first"
	if not depth.has(key):
		return "No such branch"
	var d: int = depth[key]
	if is_uncapped():
		# Every path takes all four upgrades and its own mastery; there is no primary or secondary.
		if d >= BRANCH_STEPS:
			if mastered_paths.has(key):
				return "Fully upgraded"
			if not mastery_unlocked():
				return "Needs %s Mastery research" % str(def.name)
		return ""
	if d >= BRANCH_STEPS:
		if mastered or key != primary():
			return "Fully upgraded"
		if not mastery_unlocked():
			return "Needs %s Mastery research" % str(def.name)
		return ""
	if d == 0 and started.size() >= 2:
		return "Locked: two branches are already started"
	# Once a primary is locked in, the other started branch stays a secondary: it can still reach
	# its cap of two upgrades, but no further.
	if locked_in() and key != primary() and d >= SECONDARY_CAP:
		return "Blocked: the secondary is capped at %d upgrades" % SECONDARY_CAP
	return ""


func can_buy(key: String) -> bool:
	return block_reason(key) == ""


## The data node the next upgrade on `key` buys ({} if none).
func next_node(key: String) -> Dictionary:
	if not can_buy(key):
		return {}
	var d: int = depth[key]
	var b := branch(key)
	return b.mastery if d >= BRANCH_STEPS else b.nodes[d]


# --- The reworked towers' Retrofit and stats --------------------------------------------------------

## Why the Retrofit can't be bought right now ("" if it can).
func retrofit_block_reason() -> String:
	if not is_rework:
		return "No Retrofit"
	if retrofit >= 0:
		return "Already retrofitted"
	return ""


## Buys Retrofit option `option` (the caller has checked and charged for it). The choice is locked.
func buy_retrofit(option: int) -> void:
	retrofit = option


## The Retrofit options as data nodes ({name, cost, blurb, set, add}).
func retrofit_options() -> Array:
	return rework_tree().retrofits if is_rework else []


## What a reworked tower looks like, as one string for the drawing code: "retrofit|a|b|c", the Retrofit (-1 none) and each
## path's depth, 5 on the path that took its mastery. A reworked tower's `spec` is this key.
func look_key(retro_override := -2) -> String:
	var p := primary()
	var ds: Array = []
	for key in BRANCHES:
		ds.append(5 if ((mastered and key == p) or mastered_paths.has(key)) else int(depth[key]))
	return "%d|%d|%d|%d" % [retrofit if retro_override == -2 else retro_override, ds[0], ds[1], ds[2]]


## Stat line of a reworked tower for an upgrade state: the base, the Retrofit if bought, then the secondary path's
## steps (at most its first two), then the primary path's steps and mastery. Every node adds or sets on the line.
func compose_rework(t_retro: int, t_depth: Dictionary, t_started: Array, t_mastered: bool) -> Dictionary:
	var rt := rework_tree()
	var s := _apply_node({}, rt.base)
	if t_retro >= 0:
		s = _apply_node(s, rt.retrofits[t_retro])
	if is_uncapped():
		for b in BRANCHES:
			var path := _path(rt, b)
			for i in mini(int(t_depth[b]), BRANCH_STEPS):
				s = _apply_node(s, path.nodes[i])
			if mastered_paths.has(b):
				s = _apply_node(s, path.mastery)
		return s
	var p := ""
	var best_d := 0
	for b in t_started:
		var dd: int = t_depth[b]
		if dd >= 3:
			p = b
			break
		if dd > best_d:
			p = b
			best_d = dd
	for b in t_started:
		if b == p:
			continue
		var path := _path(rt, b)
		for i in mini(int(t_depth[b]), SECONDARY_CAP):
			s = _apply_node(s, path.nodes[i])
	if p != "":
		var path := _path(rt, p)
		for i in mini(int(t_depth[p]), BRANCH_STEPS):
			s = _apply_node(s, path.nodes[i])
		if t_mastered:
			s = _apply_node(s, path.mastery)
	return s


## A reworked tower type's stock stats (before research), for the shop and the build card.
static func rework_base(tower_type: String) -> Dictionary:
	return _apply_node({}, Rework.TREES[tower_type].base)


static func _path(rt: Dictionary, key: String) -> Dictionary:
	for p in rt.paths:
		if p.key == key:
			return p
	return {}


## Applies the next upgrade on `key` (the caller has checked and charged for it).
func buy(key: String) -> void:
	var d: int = depth[key]
	if d >= BRANCH_STEPS:
		mastered = true
		if is_uncapped():
			mastered_paths.append(key)
	else:
		if d == 0:
			started.append(key)
		depth[key] = d + 1
	_dirty = true


## Marks the stat cache stale after the upgrade state was edited directly (e.g. loading a save).
func invalidate() -> void:
	_dirty = true


## The branch key a v3.0-style upgrade request means: a spec id or branch key, or "" for the
## primary (or the only started branch).
func resolve_key(id_or_key := "") -> String:
	var k := branch_key(id_or_key)
	if k != "":
		return k
	if id_or_key == "":
		return primary()
	return ""


# --- Stats -------------------------------------------------------------------------------------

## Stats before research for a given upgrade state.
func compose(t_trunk: int, t_depth: Dictionary, t_started: Array, t_mastered: bool) -> Dictionary:
	var ln := lines(type)
	if t_trunk <= 1:
		return ln.t1
	var p := ""
	var best_d := 0
	for b in t_started:
		var d: int = t_depth[b]
		if d >= 3:
			p = b
			break
		if d > best_d:
			p = b
			best_d = d
	if p == "":
		return ln.t2
	var s: Dictionary = (ln[p + "_m"] if t_mastered else ln[p][t_depth[p]]).duplicate()
	var t2: Dictionary = ln.t2
	for b in t_started:
		if b == p or int(t_depth[b]) == 0:
			continue
		var bd := branch(b)
		if bool(bd.get("attack", false)):
			var extra: Dictionary = ATTACK_SECONDARY.get(str(bd.id), {})
			for k in extra:
				s[k] = float(s.get(k, 0.0)) + float(extra[k]) if (extra[k] is float or extra[k] is int) else extra[k]
			continue
		var lb: Dictionary = ln[b][t_depth[b]]
		for k in lb:
			var v = lb[k]
			var base = t2.get(k)
			if (v is float or v is int) and not (v is bool):
				var b0 := float(base) if ((base is float or base is int) and not (base is bool)) else 0.0
				var delta := float(v) - b0
				if absf(delta) > 1e-9:
					var cur = s.get(k, b0)
					s[k] = (float(cur) if ((cur is float or cur is int) and not (cur is bool)) else b0) + delta
			elif not s.has(k):
				s[k] = v
	return s


## Stats of the current upgrade state, before research.
func base_stats() -> Dictionary:
	if is_rework:
		return compose_rework(retrofit, depth, started, mastered)
	return compose(trunk, depth, started, mastered)


## Current stats with research applied. Cached; rebuilt when the upgrade state changes.
func stats() -> Dictionary:
	if _dirty:
		_cache = Research.apply(base_stats(), mods)
		_dirty = false
	return _cache


## Stats after the next upgrade on `id_or_key` ({} if there is none). At tier 1 it's Tier 2.
func next_stats(id_or_key := "") -> Dictionary:
	if is_rework:
		var rk := id_or_key if id_or_key != "" else primary()
		if rk == "" or not can_buy(rk):
			return {}
		var rd := depth.duplicate()
		var rs := started.duplicate()
		var rm := mastered
		if int(rd[rk]) >= BRANCH_STEPS:
			rm = true
		else:
			if int(rd[rk]) == 0:
				rs.append(rk)
			rd[rk] = int(rd[rk]) + 1
		return Research.apply(compose_rework(retrofit, rd, rs, rm), mods)
	if trunk == 1:
		return Research.apply(lines(type).t2, mods)
	var k := resolve_key(id_or_key)
	if k == "" or not can_buy(k):
		return {}
	var nd := depth.duplicate()
	var ns := started.duplicate()
	var nm := mastered
	if int(nd[k]) >= BRANCH_STEPS:
		nm = true
	else:
		if int(nd[k]) == 0:
			ns.append(k)
		nd[k] = int(nd[k]) + 1
	return Research.apply(compose(trunk, nd, ns, nm), mods)


## Player-facing names for the trunk: the tower as built, then its one trunk upgrade.
static func trunk_name(trunk_tier: int) -> String:
	return "Stock" if trunk_tier <= 1 else "Retrofit"


func display_name() -> String:
	if is_rework:
		var pm := primary()
		return str(branch(pm).mastery.name) if (mastered and pm != "") else str(def.name)
	var p := primary()
	if p == "" or not locked_in():
		return str(def.name)
	var b := branch(p)
	return str(b.mastery.name) if mastered else str(b.nodes[0].name)


func spec_ids() -> Array:
	if is_rework:
		return []
	return tree(type).branches.map(func(b): return str(b.id))


## "physical" or "energy": what a hit from this tower counts as. Set by the weapon type; the Augmentation Tower's Energy
## Conversion (a share of nearby towers' damage; full at 100%) turns it to energy. Nothing reacts to it until the Wraith (#53).
func damage_kind() -> String:
	if str(def.get("damage_kind", "physical")) == "energy" or float(stats().get("energy_convert", 0.0)) >= 1.0:
		return "energy"
	return "physical"


func is_support() -> bool:
	return bool(def.get("support", false))


## Scrapyard: an economy tower that never attacks.
func is_economy() -> bool:
	return bool(def.get("economy", false))


## The shell types an Artillery Cannon has unlocked, plain high explosive first.
func available_shells() -> Array:
	var s := stats()
	var out: Array = ["he"]
	for k in ["incendiary", "shrapnel", "concussion", "combined"]:
		if bool(s.get(k, false)):
			out.append(k)
	return out


## The loadouts a Drone Bay has unlocked, the gun first.
func available_loadouts() -> Array:
	var s := stats()
	var out: Array = ["gun"]
	for pr in [["lo_missiles", "missiles"], ["lo_bombs", "bombs"], ["lo_laser", "laser"], ["lo_full", "full"]]:
		if bool(s.get(pr[0], false)):
			out.append(pr[1])
	return out


func is_uncapped() -> bool:
	return bool(def.get("uncapped", false))


func is_beam() -> bool:
	return bool(def.get("beam", false))


func eff_damage() -> float:
	return float(stats().get("damage", 0.0)) * (1.0 + buff_dmg) * (1.0 + (SITE_DAMAGE if site == "P" else 0.0))


func eff_rate() -> float:
	return float(stats().get("rate", 1.0)) * (1.0 + float(stats().get("rate_pct", 0.0))) * (1.0 + buff_rate)


func get_range() -> float:
	return float(stats().get("range", 100.0)) * (1.0 + buff_range) * (1.0 + (SITE_RANGE if site == "H" else 0.0))


func is_sensor() -> bool:
	return bool(def.get("sensor", false))


func hits_air() -> bool:
	return bool(def.air) and not bool(stats().get("ground_only", false))


func hits_ground() -> bool:
	return bool(def.get("ground", true)) or float(stats().get("ground_mult", 0.0)) > 0.0


func mastery_unlocked() -> bool:
	return bool(mods.get("mastery", false))


## Compatibility: 4 once this tower type's Mastery is researched, otherwise 3.
func max_tier() -> int:
	return MASTERY_TIER if mastery_unlocked() else SPEC_TIER


## True at tier 2 before any branch is started (the next upgrade needs a branch choice).
func needs_spec() -> bool:
	return not is_rework and trunk == 2 and started.is_empty()


func build_cost() -> int:
	if is_rework:
		return Research.discounted(int(rework_tree().cost), mods)
	return Research.discounted(int(tree(type).tiers[0].cost), mods)


## Price of the next upgrade on `id_or_key` (0 when there is none). At tier 1 it's Tier 2's price;
## at tier 2 with nothing started and no key, the cheapest specialization.
func upgrade_cost(id_or_key := "") -> int:
	if is_rework:
		var rk := id_or_key if id_or_key != "" else primary()
		var rn := next_node(rk) if rk != "" else {}
		return _price(int(rn.cost)) if not rn.is_empty() else 0
	if trunk == 1:
		return _price(int(tree(type).tiers[1].cost))
	var k := resolve_key(id_or_key)
	if k == "" and started.is_empty():
		var best := 1 << 30
		for b in tree(type).branches:
			best = mini(best, int(b.nodes[0].cost))
		return _price(best)
	var n := next_node(k)
	return _price(int(n.cost)) if not n.is_empty() else 0


## Price of Retrofit option `option` (0 when it can't be bought).
func retrofit_cost(option: int) -> int:
	if retrofit_block_reason() != "" or option < 0 or option >= retrofit_options().size():
		return 0
	return _price(int(retrofit_options()[option].cost))


## An upgrade price after research, the mode's price and any Supply Depot discount.
func _price(cost: int) -> int:
	return int(round(float(Research.discounted(cost, mods)) * (1.0 - discount)))


func can_target(e) -> bool:
	if e == null or not e.alive:
		return false
	if e.is_hidden() or (e.flying and not hits_air()) or (not e.flying and not hits_ground()):
		return false
	var r := get_range()
	return pos.distance_squared_to(e.pos) <= r * r


## Closes one DPS bucket of `secs` seconds, keeping the last `keep`. Called by Game while sandboxed.
func roll_dps(_secs: float, keep: int) -> void:
	dps_buckets.append(damage_dealt - _dps_mark)
	_dps_mark = damage_dealt
	if dps_buckets.size() > keep:
		dps_buckets.pop_front()


## Damage per second over the buckets kept (the last 5 s once the meter has run that long).
func live_dps(secs_per_bucket: float) -> float:
	if dps_buckets.is_empty():
		return 0.0
	var sum := 0.0
	for b in dps_buckets:
		sum += float(b)
	return sum / (float(dps_buckets.size()) * secs_per_bucket)
