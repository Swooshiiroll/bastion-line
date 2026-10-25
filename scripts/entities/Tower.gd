extends RefCounted
## A placed tower: its type, upgrade state, research modifiers, buffs from pylons, and per-type
## state. Firing logic lives in Game so it can see every entity.
##
## Upgrades (issue #59): an optional Retrofit (one of up to three options, locked once bought) and three paths (a, b, c) of
## four steps each plus a mastery, all open from the start. A tower can climb two paths; the first to reach its third step
## becomes the primary and the other (the secondary) stops at two. The primary can go on to its mastery once the tower's
## Mastery is researched. The CAS Gunship is uncapped: every path takes every step and its own mastery.
##
## Stats: the base, the Retrofit, the secondary's steps, then the primary's steps and mastery (data/rework_trees.gd).

const Towers = preload("res://data/towers.gd")
const Research = preload("res://scripts/core/Research.gd")
const Rework = preload("res://data/rework_trees.gd")

enum Mode { FIRST, LAST, STRONG, CLOSE }
const MODE_NAMES := ["First", "Last", "Strongest", "Closest"]
## Which enemies a tower prefers (it falls back to the rest): Air and Ground for towers that hit both, Support for the Support role.
const PRIORITY_NAMES := ["Any", "Air", "Ground", "Support"]
const BRANCHES := ["a", "b", "c"]
const BRANCH_STEPS := 4
static var SECONDARY_CAP := 2
## Tiers: 1 stock, 2 retrofitted, 3 on a path, 4 mastered.
const SPEC_TIER := 3
const MASTERY_TIER := 4
## Terrain bonuses: high ground (H) +range, power node (P) +damage.
static var SITE_RANGE := 0.15
static var SITE_DAMAGE := 0.15

var type := ""
var def: Dictionary
## The Retrofit option bought (-1 until then).
var retrofit := -1:
	set(v):
		retrofit = v
		_dirty = true
## Tiles along each side of the footprint: 1, or 2 for the Scrapyard. `cell` is the
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
## Laser Tower: the beams are firing (it faces its main target); false while it turns onto a new one (#90).
var beam_on := false
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
## After an EMP wears off the tower can't be knocked offline again for this long (the Disruptors' disable guard).
var disable_guard := 0.0
## A Siphon's drain on this tower (the strongest Siphon in range): the share of fire rate and of range it loses. Set every tick.
var debuff_rate := 0.0
var debuff_range := 0.0
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
		return SPEC_TIER if not started.is_empty() else (2 if retrofit >= 0 else 1)

## What the tower looks like, as one string for the drawing code (see look_key).
var spec: String:
	get:
		return look_key()

var _cache := {}
var _dirty := true


func setup(tower_type: String, at_cell: Vector2i, at_pos: Vector2, research_mods := {}) -> void:
	type = tower_type
	def = Towers.def(tower_type)
	size = int(def.get("size", 1))
	cell = at_cell
	pos = at_pos
	mods = research_mods
	_dirty = true
	spent = build_cost()


# --- Tree data ---------------------------------------------------------------------------------

func branch(key: String) -> Dictionary:
	return _path(rework_tree(), key)


## The tower's data (base, retrofits, paths).
func rework_tree() -> Dictionary:
	return Rework.TREES[type]


static func _apply_node(base: Dictionary, node: Dictionary) -> Dictionary:
	var out := base.duplicate()
	for k in node.get("add", {}):
		out[k] = float(out.get(k, 0.0)) + float(node.add[k])
	for k in node.get("set", {}):
		out[k] = node.set[k]
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


# --- Retrofit and stats ---------------------------------------------------------------------------

## Why the Retrofit can't be bought right now ("" if it can).
func retrofit_block_reason() -> String:
	if retrofit >= 0:
		return "Already retrofitted"
	return ""


## Buys Retrofit option `option` (the caller has checked and charged for it). The choice is locked.
func buy_retrofit(option: int) -> void:
	retrofit = option


## The Retrofit options as data nodes ({name, cost, blurb, set, add}).
func retrofit_options() -> Array:
	return rework_tree().retrofits


## What the tower looks like, as one string for the drawing code: "retrofit|a|b|c", the Retrofit (-1 none) and each path's
## depth, 5 on the path that took its mastery. The tower's `spec` is this key.
func look_key(retro_override := -2) -> String:
	var p := primary()
	var ds: Array = []
	for key in BRANCHES:
		ds.append(5 if ((mastered and key == p) or mastered_paths.has(key)) else int(depth[key]))
	return "%d|%d|%d|%d" % [retrofit if retro_override == -2 else retro_override, ds[0], ds[1], ds[2]]


## Stat line for an upgrade state: the base, the Retrofit if bought, then the secondary path's
## steps (at most its first two), then the primary path's steps and mastery. Every node adds or sets on the line.
func compose(t_retro: int, t_depth: Dictionary, t_started: Array, t_mastered: bool) -> Dictionary:
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


## A tower type's stock stats (before research), for the shop and the build card.
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


# --- Stats -------------------------------------------------------------------------------------

## Stats of the current upgrade state, before research.
func base_stats() -> Dictionary:
	return compose(retrofit, depth, started, mastered)


## Current stats with research applied. Cached; rebuilt when the upgrade state changes.
func stats() -> Dictionary:
	if _dirty:
		_cache = Research.apply(base_stats(), mods)
		_dirty = false
	return _cache


## Stats after the next upgrade on path `key` (the primary when empty; {} if there is none).
func next_stats(key := "") -> Dictionary:
	var k := key if key != "" else primary()
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
	return Research.apply(compose(retrofit, nd, ns, nm), mods)


## The tower's name, or its mastery's once mastered.
func display_name() -> String:
	var p := primary()
	return str(branch(p).mastery.name) if (mastered and p != "") else str(def.name)


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
	return float(stats().get("rate", 1.0)) * (1.0 + float(stats().get("rate_pct", 0.0))) * (1.0 + buff_rate) * (1.0 - debuff_rate)


## Starts its weapons on a full reload (#85): a new tower, and every tower at the start of a round, has to load before
## its first shot. The Magneto's flip and the Tractor's recharge count as its reload; a Radar's ping is a sensor, not a
## shot, so it pings at once.
func load_up() -> void:
	var s := stats()
	match type:
		"magneto_tower":
			cooldown = float(s.get("flip_every", 0.0))
		"tractor_tower":
			cooldown = float(s.get("recharge", 0.0))
		"radar_tower":
			pass
		_:
			cooldown = 1.0 / maxf(0.01, eff_rate())
	if type == "cas_gunship":
		var mult: float = float(s.get("rate_mult", 1.0)) * (1.0 + buff_rate)
		gun_cds["gat"] = 1.0 / maxf(0.01, float(s.get("rate", 1.0)) * mult)
		if s.has("ac_rate"):
			gun_cds["ac"] = 1.0 / maxf(0.01, float(s.ac_rate) * mult)
		if s.has("ms_rate"):
			gun_cds["ms"] = 1.0 / maxf(0.01, float(s.ms_rate) * mult)


func get_range() -> float:
	return float(stats().get("range", 100.0)) * (1.0 + buff_range) * (1.0 + (SITE_RANGE if site == "H" else 0.0)) * (1.0 - debuff_range)


func hits_air() -> bool:
	return bool(def.air) and not bool(stats().get("ground_only", false))


func hits_ground() -> bool:
	return bool(def.get("ground", true)) or float(stats().get("ground_mult", 0.0)) > 0.0


func mastery_unlocked() -> bool:
	return bool(mods.get("mastery", false))


func build_cost() -> int:
	return Research.discounted(int(rework_tree().cost), mods)


## Price of the next upgrade on path `key` (the primary when empty; 0 when there is none).
func upgrade_cost(key := "") -> int:
	var k := key if key != "" else primary()
	var n := next_node(k) if k != "" else {}
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
	if e.untargetable() or (e.flying and not hits_air()) or (not e.flying and not hits_ground()):
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
