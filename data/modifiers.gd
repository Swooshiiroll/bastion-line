extends RefCounted
## Elite modifiers (enemy rework, issue #68; design/enemies.md section 4, numbers confirmed by the owner 2026-10-20).
## A modifier goes on a single elite, never on a whole group. It is a set of flat keys merged into the enemy's data, so the
## trait registry (EnemyTraits) picks up what it adds, plus a few stat changes:
##   speed_mult, armor_add, slow_resist_add, shield_pct (a barrier worth that share of its HP).
## `trait` is the trait it gives: an enemy that already has it never gets the modifier. `cost` multiplies the enemy's threat
## cost in the round budget; `intro` is the first round it can appear. A modifier that changes speed or armor changes the
## enemy's strength rank too (its score is worked out from the changed stats); the rest leave the rank alone.
## An elite also pays double bounty and costs one more shield when it leaks.

const Enemies = preload("res://data/enemies.gd")

const ORDER := ["shielded", "hasty", "regenerating", "plated", "cloaked", "splitting", "jamming", "resolute", "commanding"]

const MODIFIERS := {
	"shielded": {
		"name": "Shielded", "cost": 1.5, "intro": 10, "trait": "barrier",
		"shield_pct": 0.5, "keys": {"shield_regen": 0.25, "shield_delay": 2.5},
		"blurb": "A barrier worth half its health that recharges when left alone. Counter: Tesla arcs and Shockwave pulses break barriers fast.",
	},
	"hasty": {
		"name": "Hasty", "cost": 1.6, "intro": 12,
		"speed_mult": 1.35,
		"blurb": "Moves 35% faster (and ranks higher for it). Counter: slows.",
	},
	"regenerating": {
		"name": "Regenerating", "cost": 1.4, "intro": 14, "trait": "regen",
		"keys": {"regen_pct": 0.03, "regen_delay": 2.0},
		"blurb": "Repairs 3% of its health per second after 2 s without damage. Counter: steady damage, burns and acid.",
	},
	"plated": {
		"name": "Plated", "cost": 1.6, "intro": 16,
		"armor_add": 4.0,
		"blurb": "4 more armor (and ranks higher for it). Counter: armor-piercing hits, armor shred and beams.",
	},
	"cloaked": {
		"name": "Cloaked", "cost": 1.5, "intro": 18, "trait": "cloak",
		"keys": {"cloaked": true},
		"blurb": "Cloaked: towers can't target it unless a Radar ping or area damage reveals it. Counter: Radar Towers and area damage.",
	},
	"splitting": {
		"name": "Splitting", "cost": 1.6, "intro": 22, "trait": "split",
		"keys": {"split_count": 2},
		"blurb": "Breaks into two of its role's tier below when destroyed (two Skitters from a T1 or a Special). Counter: area damage.",
	},
	"jamming": {
		"name": "Jamming", "cost": 1.6, "intro": 24, "trait": "emp",
		"keys": {"emp_radius": 80.0, "emp_duration": 1.5, "emp_interval": 6.0},
		"blurb": "An EMP every 6 s knocks towers within 80 px offline for 1.5 s. Counter: long range.",
	},
	"resolute": {
		"name": "Resolute", "cost": 1.4, "intro": 28,
		"slow_resist_add": 0.5, "keys": {"stun_immune": true},
		"blurb": "Resists half of every slow and can't be stunned. No counter: bring more damage.",
	},
	"commanding": {
		"name": "Commanding", "cost": 1.5, "intro": 32, "trait": "aura",
		"keys": {"aura_radius": 90.0, "aura_haste": 0.15},
		"blurb": "Other non-boss enemies within 90 px move 15% faster. Counter: kill it first (the Support priority doesn't pick it unless it is a Support).",
	},
}

## The most slow resist a modifier can give.
const SLOW_RESIST_CAP := 0.9
## An elite carries one modifier, two from round TWO_MODS_AT and three from round THREE_MODS_AT.
const TWO_MODS_AT := 40
const THREE_MODS_AT := 80


## How many modifiers one elite can carry on round `wave`: one, two from round 40, three from round 80.
static func max_per_elite(wave: int) -> int:
	return 3 if wave >= THREE_MODS_AT else (2 if wave >= TWO_MODS_AT else 1)


## Whether enemy `etype` can take modifier `mod`: never a boss or a trick (Masquerade, Decoy Beacon), and never a trait it already has.
static func allowed(etype: String, mod: String) -> bool:
	var d: Dictionary = Enemies.ENEMIES[etype]
	if bool(d.get("boss", false)) or d.has("disguise") or d.has("fake_rank"):
		return false
	var m: Dictionary = MODIFIERS[mod]
	if mod == "resolute" and (bool(d.get("cc_immune", false)) or bool(d.get("stun_immune", false))):
		return false
	match str(m.get("trait", "")):
		"barrier":
			return not d.has("shield")
		"regen":
			return not d.has("regen_pct")
		"cloak":
			return not d.has("cloaked")
		"split":
			return not d.has("split_type")
		"emp":
			return not d.has("emp_interval")
		"aura":
			return not d.has("aura_radius")
	return true


## The threat-cost multiplier of a set of modifiers.
static func cost_mult(mods: Array) -> float:
	var m := 1.0
	for k in mods:
		m *= float(MODIFIERS[k].cost)
	return m


## What a Splitting elite of `etype` breaks into: the next tier down in its role that exists, else Skitters.
static func split_type(etype: String) -> String:
	var d: Dictionary = Enemies.ENEMIES[etype]
	var role := str(d.get("role", ""))
	for t in range(int(d.get("tier", 0)) - 1, 0, -1):
		for id in Enemies.ORDER:
			var o: Dictionary = Enemies.ENEMIES[id]
			if str(o.get("role", "")) == role and int(o.get("tier", 0)) == t:
				return id
	return "runner"


## Enemy data `def` (of type `etype`) with modifiers `mods` merged in: a new dictionary, the table is left alone.
static func apply(def: Dictionary, etype: String, mods: Array) -> Dictionary:
	var d := def.duplicate(true)
	for k in mods:
		var m: Dictionary = MODIFIERS[k]
		d.merge(m.get("keys", {}), true)
		if m.has("speed_mult"):
			d["speed"] = float(d.speed) * float(m.speed_mult)
		if m.has("armor_add"):
			d["armor"] = float(d.get("armor", 0.0)) + float(m.armor_add)
		if m.has("slow_resist_add"):
			d["slow_resist"] = minf(SLOW_RESIST_CAP, float(d.get("slow_resist", 0.0)) + float(m.slow_resist_add))
		if m.has("shield_pct"):
			d["shield"] = float(d.hp) * float(m.shield_pct)
		if k == "splitting":
			d["split_type"] = split_type(etype)
	return d


## The modifiers' names, joined for a label ("Hasty Plated").
static func label(mods: Array) -> String:
	var parts: Array = []
	for k in mods:
		parts.append(str(MODIFIERS[k].name))
	return " ".join(parts)
