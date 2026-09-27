extends RefCounted
## Shared tower-description helpers for the shop, the bottom bar and the upgrade tree:
## stat grids with upgrade deltas, one-line stat summaries, reach tags and research lines.

const UiKit = preload("res://scripts/ui/UiKit.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const Towers = preload("res://data/towers.gd")
const Research = preload("res://scripts/core/Research.gd")

## [label, stat key, format] for every optional stat, in display order.
const STAT_ROWS := [
	["Attacks/s", "rate", "%.2f"], ["Missiles", "missiles", "%d"], ["Blast radius", "splash", "%d"],
	["Burn dps", "burn_dps", "%d"], ["Slow", "slow", "pct"], ["Vulnerability", "vuln", "+pct"],
	["Chain targets", "chains", "%d"], ["Stun", "stun", "%.1fs"], ["Max ramp", "ramp", "x%.1f"],
	["Charge time", "ramp_time", "%.1fs"],
	["Beams", "beams", "%d"], ["Flyer damage", "air_mult", "x%.0f"], ["Armor shred", "shred_max", "%d"],
	["Boss damage", "boss_mult", "x%.1f"], ["Targets/volley", "multishot", "%d"], ["Execute below", "execute", "pct"],
	["Channel width", "rail_width", "%d"], ["Damage mark", "mark", "+pct"], ["Pushback", "push", "%d"],
	["Damage boost", "buff_dmg", "+pct"], ["Speed boost", "buff_rate", "+pct"], ["Range boost", "buff_range", "+pct"],
	["Flechettes", "pellets", "%d"], ["Cone", "cone", "deg"], ["Sweep arc", "sweep", "deg"], ["Bomblets", "bomblets", "%d"],
	["Barrier strip", "strip", "pct"], ["Feedback", "feedback", "pct"], ["Suppression", "suppress", "%.1fs"],
	["Armor break", "armor_break", "%d"], ["Armor break", "armor_field", "%d"], ["Pull", "pull", "%d"],
	["Implosion", "implode_pct", "pct"], ["Ground damage", "ground_mult", "pct"], ["Burn aura", "aura_dps", "%d"],
	["Mini-novas", "mini_nova", "%d"], ["Drones", "drones", "%d"], ["Bombers", "bombers", "%d"],
	["Bomb damage", "bomb_damage", "%d"], ["Drone speed", "drone_speed", "%d"], ["Lingers", "linger", "%.1fs"],
	["Field slow", "field_slow", "pct"], ["Static build-up", "static_vuln", "+pct"],
	["Credits per round", "income", "%d"], ["Kill credits in field", "bounty_bonus", "+pct"], ["Boss credits", "boss_bounty", "x%.0f"],
	["Upgrade discount in field", "discount", "pct"], ["Sell refund in field", "sell_field", "pct"],
	["Interest on banked credits", "interest", "pct"], ["Interest cap", "interest_cap", "%d"],
]
## Mechanic flags shown as a "yes" row: [label, stat key].
const FLAG_ROWS := [
	["Hits burrowed", "hits_burrowed"], ["Removes immunities", "expose"], ["Silences abilities", "dampen"],
	["Stops burrowing and blinking", "disrupt"], ["Stops repairs", "block_repair"], ["Stops barrier recharge", "block_barrier"],
	["Blocks Bulwark barriers", "block_grants"], ["Ignores barriers", "bypass_shield"], ["Hunts specialists", "hunt"],
	["Suppresses targets", "suppress_hit"], ["Jams support", "jam"],
]
## Short keys for the one-line summary.
const SHORT := {
	"rate": "/s", "splash": "blast", "chains": "chains", "slow": "slow", "vuln": "vuln", "stun": "stun",
	"ramp": "ramp", "beams": "beams", "ramp_time": "charge", "missiles": "missiles", "shred_max": "shred", "mark": "mark",
	"push": "push", "buff_dmg": "dmg boost", "buff_rate": "speed boost", "buff_range": "range boost",
	"multishot": "targets", "execute": "execute", "burn_dps": "burn", "boss_mult": "vs boss",
	"pellets": "flechettes", "cone": "cone", "sweep": "sweep", "bomblets": "bomblets", "strip": "strip",
	"suppress": "silence", "pull": "pull", "drones": "drones", "bombers": "bombers", "aura_dps": "aura",
	"ground_mult": "vs ground", "armor_break": "armor break", "armor_field": "armor break",
	"income": "cr/round", "bounty_bonus": "kill cr", "discount": "off upgrades", "interest": "interest",
}


static func fmt(v, f: String) -> String:
	match f:
		"pct":
			return "%d%%" % roundi(float(v) * 100.0)
		"+pct":
			return "+%d%%" % roundi(float(v) * 100.0)
		"pierce":
			return "ignored"
		"line":
			return "whole line"
		"%d":
			return "%d" % roundi(float(v))
		"deg":
			return "%d°" % roundi(float(v))
		"yes":
			return "yes"
	return f % float(v)


static func rows_for(cur: Dictionary, beam: bool) -> Array:
	var rows: Array = []
	if beam:
		rows.append(["Damage/s", "damage", "%d"])
	elif cur.has("damage"):
		rows.append(["Damage", "damage", "%d"])
	if cur.has("range"):
		rows.append(["Range" if not cur.has("income") else "Field", "range", "%d"])
	elif not cur.has("income"):
		rows.append(["Range", "", "anywhere"])
	for cand in STAT_ROWS:
		if cur.has(cand[1]) and float(cur[cand[1]]) != 0.0:
			rows.append(cand)
	for f in FLAG_ROWS:
		if cur.get(f[1], false):
			rows.append([f[0], f[1], "yes"])
	if cur.get("pierce", false):
		rows.append(["Armor", "pierce", "pierce"])
	if cur.get("line", false):
		rows.append(["Pierces", "line", "line"])
	return rows


## Stat rows for a level; with a non-empty `nxt`, green "-> value" deltas toward that level.
static func stats_grid(cur: Dictionary, nxt: Dictionary, beam: bool, size := 12, columns_gap := 10) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", columns_gap)
	grid.add_theme_constant_override("v_separation", 0)
	for r in rows_for(cur, beam):
		grid.add_child(UiKit.label(r[0], size, UiKit.DIM))
		grid.add_child(UiKit.label("whole map" if r[2] == "anywhere" else fmt(cur.get(r[1]), r[2]), size))
		var nt := ""
		if not nxt.is_empty() and nxt.has(r[1]) and nxt.get(r[1]) != cur.get(r[1]) and not (r[2] in ["pierce", "line", "yes", "anywhere"]):
			nt = "-> " + fmt(nxt.get(r[1]), r[2])
		grid.add_child(UiKit.label(nt, size, UiKit.GOOD))
	return grid


## "DMG 30 · RNG 177 · 3.21/s · shred 8" for the bottom bar.
static func summary(cur: Dictionary, beam: bool) -> String:
	var parts: Array = []
	if cur.has("damage"):
		parts.append(("DPS %d" if beam else "DMG %d") % roundi(float(cur.damage)))
	if cur.has("range"):
		parts.append("RNG %d" % roundi(float(cur.range)))
	elif not cur.has("income"):
		parts.append("whole map")
	for cand in STAT_ROWS:
		var k: String = cand[1]
		if not cur.has(k) or float(cur[k]) == 0.0 or parts.size() >= 5:
			continue
		if k == "rate":
			parts.append("%.2f/s" % float(cur.rate))
		else:
			parts.append("%s %s" % [SHORT.get(k, k), fmt(cur[k], cand[2])])
	if cur.get("pierce", false) and parts.size() < 6:
		parts.append("ignores armor")
	return "  ·  ".join(PackedStringArray(parts))


static func reach_tag(type: String) -> Array:
	var d: Dictionary = Towers.TOWERS[type]
	if d.get("economy", false):
		return ["ECONOMY", UiKit.GOLD]
	if d.get("support", false):
		return ["SUPPORT", Draw.ACCENT.amp]
	if not d.get("ground", true):
		return ["AIR ONLY", Draw.ACCENT.flak]
	if d.air:
		return ["AIR+GND", UiKit.BLUE]
	return ["GROUND", UiKit.DIM]


static func reach_text(type: String) -> String:
	var d: Dictionary = Towers.TOWERS[type]
	if d.get("economy", false):
		return "economy"
	if d.get("support", false):
		return "support"
	if not d.get("ground", true):
		return "air only"
	return "air and ground" if d.air else "ground only"


## "Research: +6% damage, +7% range", or "" when the tower type has none.
static func research_line(mods: Dictionary) -> String:
	var parts: Array = Research.describe(mods)
	if parts.is_empty():
		return ""
	return "Research: " + ", ".join(PackedStringArray(parts))


static func build_key(i: int) -> String:
	return ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "[", "]", "\\"][i] if i < 15 else ""


## A two-line blurb inside a button. Autowrap must be on before sizing, or the label keeps its
## one-line minimum width and runs past the button.
static func button_blurb(text: String, width: float, pos := Vector2(10, 21)) -> Label:
	var bl := UiKit.label(text, 11, UiKit.DIM)
	bl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bl.clip_text = true
	bl.position = pos
	bl.size = Vector2(width, 28)
	return bl
