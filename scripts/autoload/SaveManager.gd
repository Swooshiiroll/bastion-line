extends Node
## Run saves and the player profile, stored as JSON under user://.
## Writes are atomic (write .tmp, verify, rename) and loads fall back to a surviving .tmp file.

const SaveCodec = preload("res://scripts/core/SaveCodec.gd")
const Difficulty = preload("res://data/difficulty.gd")
const Research = preload("res://scripts/core/Research.gd")

const RUN_FILE := "savegame.json"
const PROFILE_FILE := "profile.json"
const PROFILE_VERSION := 4
const DEFAULT_SETTINGS := {
	"sfx_volume": 0.8,
	"music_volume": 0.5,
	"damage_numbers": true,
	"fullscreen": false,
	"window_size": "auto",
	"vsync": true,
	"max_fps": 0,
	"vfx": 1.0,
	"screen_shake": true,
	"show_fps": false,
	"difficulty": "medium",
}
## Window sizes offered in Settings ("auto" fits the screen). The game fills any window shape, so
## these are only starting points: the window can also be resized freely.
const WINDOW_SIZES := ["auto", "1280x720", "1600x900", "1920x1080", "2560x1440", "3840x2160"]
## Frame caps offered in Settings (0 = no cap), and the effects levels (particle multipliers).
const FPS_CAPS := [0, 30, 60, 120, 144, 240]
const VFX_LEVELS := [["Low", 0.4], ["Medium", 0.7], ["High", 1.0]]
const BUS_SFX := "SFX"
const BUS_MUSIC := "Music"

var base_dir := "user://"
var profile := {}


func _ready() -> void:
	ensure_buses()
	load_profile()


func set_base_dir(dir: String) -> void:
	base_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	load_profile()


func run_path() -> String:
	return base_dir.path_join(RUN_FILE)


func profile_path() -> String:
	return base_dir.path_join(PROFILE_FILE)


# --- Run save --------------------------------------------------------------------------------

func has_run() -> bool:
	return FileAccess.file_exists(run_path()) or FileAccess.file_exists(run_path() + ".tmp")


func save_run(game) -> bool:
	if not game.can_save():
		return false
	return _write_json_atomic(run_path(), SaveCodec.encode(game))


## Returns {} when there is no save, {"game": Game} on success, or {"error": String}.
func load_run() -> Dictionary:
	var data = read_json(run_path())
	if data == null:
		data = read_json(run_path() + ".tmp")
	if data == null:
		if has_run():
			return {"error": "The save file is corrupted and can't be read."}
		return {}
	return SaveCodec.decode(data)


## Raw save contents for menu display, or {} if missing/unreadable.
func peek_run() -> Dictionary:
	var data = read_json(run_path())
	if data == null:
		data = read_json(run_path() + ".tmp")
	return data if data is Dictionary else {}


func delete_run() -> void:
	for p in [run_path(), run_path() + ".tmp"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)


# --- Profile ---------------------------------------------------------------------------------

func load_profile() -> void:
	profile = {"version": PROFILE_VERSION, "maps": {}, "research": [], "legacy_rp": 0, "settings": DEFAULT_SETTINGS.duplicate()}
	var d = read_json(profile_path())
	if d is Dictionary:
		var version := int(d.get("version", 1))
		if d.get("maps") is Dictionary:
			if version < 4:
				# v4 (game v3.0) replaced casual/normal/veteran and 25-wave stars with five modes and
				# medals. Old records don't count under the new rules, but the RP they earned is kept.
				profile["legacy_rp"] = Research.legacy_points(migrate_maps(d["maps"]))
			else:
				profile["maps"] = d["maps"]
				profile["legacy_rp"] = maxi(0, int(d.get("legacy_rp", 0)))
		# Anything the records can't pay for (e.g. a hand-edited file) is refunded.
		var owned := Research.sanitize(d.get("research", []))
		if Research.spent(owned) <= research_earned():
			profile["research"] = owned
		if d.get("settings") is Dictionary:
			for k in DEFAULT_SETTINGS:
				if d["settings"].has(k):
					profile["settings"][k] = d["settings"][k]
	var mode := Difficulty.resolve(str(profile.settings.difficulty))
	profile["settings"]["difficulty"] = mode if mode != "" else "medium"
	apply_settings(false)


## v1 profiles kept one record per map; v2-v3 kept one per map per difficulty (v1 records became
## Normal). Only used to work out legacy RP now.
static func migrate_maps(maps: Dictionary) -> Dictionary:
	var out := {}
	for id in maps:
		var rec = maps[id]
		if not (rec is Dictionary):
			continue
		if rec.has("best_wave") or rec.has("won"):
			out[id] = {"normal": rec}
		else:
			out[id] = rec
	return out


func save_profile() -> void:
	profile["version"] = PROFILE_VERSION
	_write_json_atomic(profile_path(), profile)


## One sector's record on one mode: the best round reached, whether its medal is earned, and the
## best round reached in endless mode after it (0 if never).
func map_record(map_id: String, mode := "medium") -> Dictionary:
	var per_map = profile.maps.get(map_id, {})
	var rec = per_map.get(mode, {}) if per_map is Dictionary else {}
	if not (rec is Dictionary):
		rec = {}
	return {
		"best_wave": int(rec.get("best_wave", 0)),
		"medal": bool(rec.get("medal", false)),
		"best_endless": int(rec.get("best_endless", 0)),
	}


## Records a run's progress. Called when the medal is earned and again when the run ends.
func record_run(map_id: String, mode: String, round_reached: int, medal: bool, endless: bool) -> void:
	var rec := map_record(map_id, mode)
	rec["best_wave"] = maxi(int(rec["best_wave"]), round_reached)
	if medal:
		rec["medal"] = true
	if endless:
		rec["best_endless"] = maxi(int(rec["best_endless"]), round_reached)
	if not (profile.maps.get(map_id) is Dictionary):
		profile["maps"][map_id] = {}
	profile["maps"][map_id][mode] = rec
	save_profile()


func total_medals() -> int:
	var n := 0
	for id in profile.maps:
		var per_map = profile.maps[id]
		if per_map is Dictionary:
			for mode in per_map:
				if Difficulty.DIFFICULTIES.has(str(mode)) and map_record(id, mode).medal:
					n += 1
	return n


# --- Research --------------------------------------------------------------------------------

func research_owned() -> Array:
	return profile.get("research", []).duplicate()


func research_earned() -> int:
	return Research.points_earned(profile.maps) + legacy_rp()


## RP carried over from a v2 profile's old records (they were cleared when the modes changed).
func legacy_rp() -> int:
	return maxi(0, int(profile.get("legacy_rp", 0)))


func research_available() -> int:
	return research_earned() - Research.spent(profile.get("research", []))


## Buys a research node. Returns "" on success or the reason it can't be bought.
func buy_research(id: String) -> String:
	var owned := research_owned()
	var why := Research.buy_block_reason(owned, id, research_available())
	if why != "":
		return why
	owned.append(id)
	profile["research"] = Research.sanitize(owned)
	save_profile()
	return ""


## Refunds every node. Research is free to reassign.
func reset_research() -> void:
	profile["research"] = []
	save_profile()


func setting(key: String):
	return profile.settings.get(key, DEFAULT_SETTINGS.get(key))


func set_setting(key: String, value) -> void:
	profile["settings"][key] = value
	if key == "fullscreen" or key == "window_size":
		apply_window()
	else:
		apply_settings(false)
	save_profile()


static func ensure_buses() -> void:
	for bus in [BUS_SFX, BUS_MUSIC]:
		if AudioServer.get_bus_index(bus) == -1:
			AudioServer.add_bus()
			var idx := AudioServer.bus_count - 1
			AudioServer.set_bus_name(idx, bus)
			AudioServer.set_bus_send(idx, "Master")


func apply_settings(window_changed := true) -> void:
	ensure_buses()
	_set_bus_volume(BUS_SFX, float(setting("sfx_volume")))
	_set_bus_volume(BUS_MUSIC, float(setting("music_volume")))
	Engine.max_fps = maxi(0, int(setting("max_fps")))
	if DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if bool(setting("vsync")) else DisplayServer.VSYNC_DISABLED)
	var want_full := bool(setting("fullscreen"))
	var mode := DisplayServer.window_get_mode()
	var is_full := mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	if want_full and not is_full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif window_changed and not want_full and is_full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


## Applies fullscreen or the chosen window size (centred on the current screen).
func apply_window() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if bool(setting("fullscreen")):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var usable := DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen())
	var want := window_size_for(str(setting("window_size")), usable.size)
	DisplayServer.window_set_size(want)
	DisplayServer.window_set_position(usable.position + (usable.size - want) / 2)


## A window size in pixels for a WINDOW_SIZES key, never larger than the usable screen.
static func window_size_for(key: String, usable: Vector2i) -> Vector2i:
	var want := Vector2i(1600, 900)
	var parts := key.split("x")
	if parts.size() == 2 and parts[0].is_valid_int() and parts[1].is_valid_int():
		want = Vector2i(int(parts[0]), int(parts[1]))
	elif usable.x > 0 and usable.y > 0:
		# Auto: the largest 16:9 window that fits in 90% of the screen.
		var w := mini(int(usable.x * 0.9), int(usable.y * 0.9 * 16.0 / 9.0))
		want = Vector2i(w, roundi(w * 9.0 / 16.0))
	if usable.x > 0 and usable.y > 0:
		want = want.min(usable)
	return want.max(Vector2i(640, 360))


func _set_bus_volume(bus: String, vol: float) -> void:
	var idx := AudioServer.get_bus_index(bus)
	if idx == -1:
		return
	vol = clampf(vol, 0.0, 1.0)
	AudioServer.set_bus_mute(idx, vol <= 0.001)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(vol, 0.001)))


# --- JSON I/O --------------------------------------------------------------------------------

func read_json(path: String):
	if not FileAccess.file_exists(path):
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var text := f.get_as_text()
	f.close()
	var j := JSON.new()
	if j.parse(text) != OK:
		return null
	return j.data


func _write_json_atomic(path: String, data: Dictionary) -> bool:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("SaveManager: can't write %s (%s)" % [tmp, error_string(FileAccess.get_open_error())])
		return false
	f.store_string(JSON.stringify(data, "\t", true, true))
	f.close()
	if not (read_json(tmp) is Dictionary):
		push_warning("SaveManager: verification of %s failed" % tmp)
		return false
	var err := DirAccess.rename_absolute(tmp, path)
	if err != OK and FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		err = DirAccess.rename_absolute(tmp, path)
	if err != OK:
		push_warning("SaveManager: can't finalize %s (%s)" % [path, error_string(err)])
		return false
	return true
