extends RefCounted
## Playtest flag (#123): a playtest build marks itself played when it launches, silently. A playtest build is one with a
## BUILD.txt beside the executable (tools/dev.sh writes one into every LX, Apollyon and Brimstone build folder; release and CI
## builds have none). user://playtests.json maps each played build's commit to true; Claude pulls it over SSH.

const PATH := "user://playtests.json"


## Marks this build played, if it is a playtest build (never on an editor build, so never in tests or the editor).
static func on_launch() -> void:
	if OS.has_feature("editor"):
		return
	var info := OS.get_executable_path().get_base_dir().path_join("BUILD.txt")
	if not FileAccess.file_exists(info):
		return
	var commit := commit_of(FileAccess.get_file_as_string(info))
	if commit != "":
		mark(PATH, commit)


## The commit named on BUILD.txt's "Commit:" line, without any "+ uncommitted changes"; "" if there is none.
static func commit_of(build_txt: String) -> String:
	for line in build_txt.split("\n"):
		if line.begins_with("Commit:"):
			var parts := line.trim_prefix("Commit:").strip_edges().split(" ", false)
			return parts[0] if parts.size() > 0 else ""
	return ""


## Sets `commit` to true in the JSON file at `path`, keeping the builds already in it.
static func mark(path: String, commit: String) -> void:
	var played := {}
	if FileAccess.file_exists(path):
		var old = JSON.parse_string(FileAccess.get_file_as_string(path))
		if old is Dictionary:
			played = old
	played[commit] = true
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(played, "\t"))
