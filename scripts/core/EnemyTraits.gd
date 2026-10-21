extends RefCounted
## Enemy traits (enemy rework, issue #68, design/enemies.md): what an enemy can do, read from the flat keys in its data.
## Each timed trait keeps its own timer (`Enemy.trait_timers`), so one enemy can carry two timed abilities without them
## sharing a clock. Game runs the timed ones every tick (`Game._update_enemy`); the others are read where they act: aura and
## siphon (`Game._update_auras`), split (`Game._kill`), regen and barrier (`Enemy.step`), cloak (`Enemy.is_hidden`), phases,
## adrenaline, shed and disguise (`Game._check_thresholds`), wake (`Game._trait_blink`), energy_only (`Game.damage_enemy`) and
## decoy (`Enemy.setup`, its rank).

const Enemies = preload("res://data/enemies.gd")

## Every trait, in the order they run: the data key that gives an enemy the trait and, for timed ones, the key of its interval.
const TRAITS := {
	"burrow": {"key": "burrow_interval", "interval": "burrow_interval"},
	"blink": {"key": "blink_interval", "interval": "blink_interval"},
	"heal": {"key": "heal_pct", "interval": "heal_interval"},
	"summon": {"key": "spawn_type", "interval": "spawn_interval"},
	"emp": {"key": "emp_interval", "interval": "emp_interval"},
	"grant": {"key": "grant_interval", "interval": "grant_interval"},
	"aura": {"key": "aura_radius"},
	"split": {"key": "split_type"},
	"regen": {"key": "regen_pct"},
	"barrier": {"key": "shield"},
	"cloak": {"key": "cloaked"},
	"phases": {"key": "phases"},
	"holo": {"key": "holo_interval", "interval": "holo_interval"},
	"siphon": {"key": "siphon_radius"},
	"wake": {"key": "wake_radius"},
	"adrenaline": {"key": "adrenaline"},
	"shed": {"key": "shed_at"},
	"energy_only": {"key": "energy_only"},
	"disguise": {"key": "disguise"},
	"decoy": {"key": "fake_rank"},
}

## The abilities an enemy fires on its own timer (not burrowing, which switches state); the old shared `ability_timer` drove these.
const ABILITIES := ["heal", "summon", "emp", "grant"]

static var _cache := {}


## The traits of an enemy with data `def`, in run order.
static func of_def(def: Dictionary) -> Array:
	var out: Array = []
	for name in TRAITS:
		if def.has(str(TRAITS[name].key)):
			out.append(name)
	return out


## The traits of enemy type `type` (cached per type).
static func of(type: String) -> Array:
	if not _cache.has(type):
		_cache[type] = of_def(Enemies.ENEMIES[type])
	return _cache[type]


static func timed(name: String) -> bool:
	return TRAITS.has(name) and TRAITS[name].has("interval")


## The seconds between two firings of timed trait `name` for an enemy with data `def` (0 if it doesn't have it).
static func interval(def: Dictionary, name: String) -> float:
	return float(def.get(str(TRAITS[name].get("interval", "")), 0.0))
