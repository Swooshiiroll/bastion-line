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
## Set by a Supply Depot in range: upgrade discount and sell refund (0 = none).
var discount := 0.0
var refund_field := 0.0
var ramp := 0.0
var ramp_mult := 1.0
var beam_targets: Array = []
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
## Drone Bay: its drones ({kind, pos, target, cd}). Not saved; rebuilt each round.
var wing: Array = []

## Upgrade state. Change it through buy(), or call invalidate() after editing it directly.
var trunk := 1:
	set(v):
		trunk = v
		_dirty = true
var depth := {"a": 0, "b": 0, "c": 0}
## Branch keys in the order they were started (at most two).
var started: Array = []
var mastered := false

var tier: int:
	get:
		if mastered:
			return MASTERY_TIER
		return SPEC_TIER if not started.is_empty() else trunk

## The primary branch's specialization id ("" before any branch is started).
var spec: String:
	get:
		var p := primary()
		return str(branch(p).id) if p != "" else ""

## The specialization shown in the tower's name and colour: stock until the primary locks in at
## its third upgrade (the model still shows branch details from the first).
var shown_spec: String:
	get:
		return spec if locked_in() else ""

var _cache := {}
var _dirty := true

static var _lines := {}


func setup(tower_type: String, at_cell: Vector2i, at_pos: Vector2, research_mods := {}) -> void:
	type = tower_type
	def = Towers.TOWERS[tower_type]
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
	for b in tree(type).branches:
		if b.key == key:
			return b
	return {}


## The branch key whose specialization id (or key) is `id_or_key`, or "".
func branch_key(id_or_key: String) -> String:
	for b in tree(type).branches:
		if b.key == id_or_key or b.id == id_or_key:
			return b.key
	return ""


func is_attack_style(key: String) -> bool:
	return bool(branch(key).get("attack", false))


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
	if trunk < 2:
		return "Retrofit it first"
	if not depth.has(key):
		return "No such branch"
	var d: int = depth[key]
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


## Applies the next upgrade on `key` (the caller has checked and charged for it).
func buy(key: String) -> void:
	var d: int = depth[key]
	if d >= BRANCH_STEPS:
		mastered = true
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
	return compose(trunk, depth, started, mastered)


## Current stats with research applied. Cached; rebuilt when the upgrade state changes.
func stats() -> Dictionary:
	if _dirty:
		_cache = Research.apply(base_stats(), mods)
		_dirty = false
	return _cache


## Stats after the next upgrade on `id_or_key` ({} if there is none). At tier 1 it's Tier 2.
func next_stats(id_or_key := "") -> Dictionary:
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
	var p := primary()
	if p == "" or not locked_in():
		return str(def.name)
	var b := branch(p)
	return str(b.mastery.name) if mastered else str(b.nodes[0].name)


func spec_ids() -> Array:
	return tree(type).branches.map(func(b): return str(b.id))


func is_support() -> bool:
	return bool(def.get("support", false))


## Scrapyard: an economy tower that never attacks.
func is_economy() -> bool:
	return bool(def.get("economy", false))


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
	return trunk == 2 and started.is_empty()


func build_cost() -> int:
	return Research.discounted(int(tree(type).tiers[0].cost), mods)


## Price of the next upgrade on `id_or_key` (0 when there is none). At tier 1 it's Tier 2's price;
## at tier 2 with nothing started and no key, the cheapest specialization.
func upgrade_cost(id_or_key := "") -> int:
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
