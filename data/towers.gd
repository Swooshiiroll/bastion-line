extends RefCounted
## Tower definitions. The towers (issue #59) and their Retrofits, paths and stats live in data/rework_trees.gd (generated from
## design/tower_stats.md and design/upgrade_trees_rework.md by tools/tree_rework_data.mjs); `def` gives each one a flat
## definition: name, blurb, flags (air, ground, support, economy, beam, uncapped), `size` (tiles per side; the Scrapyard is
## 2x2), class, weapon and damage kind. Ranges are pixels (one tile = 48 px); `rate` is attacks per second.

const Rework = preload("res://data/rework_trees.gd")

## Every tower, in shop order.
const ORDER: Array = Rework.ORDER


static func all_types() -> Array:
	return ORDER


static func has(type: String) -> bool:
	return Rework.TREES.has(type)


static func def(type: String) -> Dictionary:
	var r: Dictionary = Rework.TREES[type]
	return {"name": r.name, "blurb": r.blurb, "air": r.air, "ground": r.ground, "size": r.size,
		"class": r["class"], "weapon": r.weapon, "damage_kind": r.damage_kind, "beam": r.get("beam", false),
		"uncapped": r.get("uncapped", false), "support": r.get("support", false), "economy": r.get("economy", false)}
