extends RefCounted
## Converts between a Game and its JSON-safe save dictionary, validating everything on the way in.
## decode() never throws: it returns {"game": Game} or {"error": "reason"}.

const Game = preload("res://scripts/core/Game.gd")
const Maps = preload("res://data/maps.gd")
const Difficulty = preload("res://data/difficulty.gd")

const REQUIRED := ["map_id", "wave", "gold", "lives", "towers"]
## The oldest save format this game loads: v10 (game 4.0) replaced every tower, so older runs can't be rebuilt.
const MIN_VERSION := 10


static func encode(g) -> Dictionary:
	return g.to_save()


static func decode(data) -> Dictionary:
	if not (data is Dictionary):
		return {"error": "Save data is not a JSON object."}
	var v = data.get("version")
	if not (v is int or v is float):
		return {"error": "Save file has no version number."}
	var version := int(v)
	if version > Game.SAVE_VERSION:
		return {"error": "Save was made by a newer version of the game (format v%d)." % version}
	if version < MIN_VERSION:
		return {"error": "Save was made before the tower rework (format v%d) and can't be loaded." % version}
	for key in REQUIRED:
		if not data.has(key):
			return {"error": "Save is missing '%s'." % key}
	for key in ["wave", "gold", "lives"]:
		if not (data[key] is int or data[key] is float):
			return {"error": "Save field '%s' is not a number." % key}
	var map_id := str(data.map_id)
	if not Maps.MAPS.has(map_id):
		return {"error": "Save refers to unknown map '%s'." % map_id}
	if int(data.lives) <= 0:
		return {"error": "Save has no lives left."}
	if not (data.towers is Array):
		return {"error": "Save tower list is malformed."}
	var diff := str(data.get("difficulty", "medium"))
	if not Difficulty.DIFFICULTIES.has(diff):
		return {"error": "Save has unknown difficulty '%s'." % diff}
	var research = data.get("research", [])
	if not (research is Array):
		return {"error": "Save research list is malformed."}
	var seed_v = data.get("seed", 1)
	var g = Game.new(map_id, int(seed_v) if (seed_v is int or seed_v is float) else 1, diff, research)
	var err: String = g.apply_save(data)
	if err != "":
		return {"error": err}
	return {"game": g}
