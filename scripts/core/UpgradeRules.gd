extends RefCounted
## Upgrade rules for the tower panel: what each upgrade card shows, and why it can't be bought.

const Tower = preload("res://scripts/entities/Tower.gd")

const KEYS := {"a": "U", "b": "I", "c": "O"}


# --- Tower panel cards ---------------------------------------------------------------------------

## The tower panel's cards for `t`: the Retrofit, then one per path.
static func card_keys(_t) -> Array:
	return ["retrofit"] + Tower.BRANCHES


## One card: {key, hotkey, state, node, cost, reason}.
## state: "buy" (can buy now), "short" (not enough credits), "research" (mastery needs research),
## "capped" (secondary at its cap), "locked" (two other branches started), "done" (mastered or
## fully upgraded). `node` is the upgrade the card is about (for "done", the last one owned).
static func card(t, key: String, gold: int) -> Dictionary:
	var c := {"key": key, "hotkey": KEYS.get(key, "Y"), "state": "", "node": {}, "cost": 0, "reason": ""}
	if key == "retrofit":
		return _retrofit_card(t, c, gold)
	var br: Dictionary = t.branch(key)
	var d: int = t.depth[key]
	var why: String = t.block_reason(key)
	if why == "":
		c.node = t.next_node(key)
		c.cost = t.upgrade_cost(key)
		c.state = "buy" if gold >= c.cost else "short"
		if c.state == "short":
			c.reason = "Cannot afford"
	elif why.begins_with("Needs"):
		c.node = br.mastery
		# What it will cost once researched (upgrade_cost is 0 while it can't be bought).
		c.cost = t._price(int(br.mastery.cost))
		c.state = "research"
		c.reason = why
	elif why.begins_with("Blocked"):
		c.node = br.nodes[mini(d, Tower.BRANCH_STEPS - 1)]
		c.state = "capped"
		c.reason = "Secondary capped at %d upgrades" % Tower.SECONDARY_CAP
	elif why.begins_with("Locked"):
		c.node = br.nodes[0]
		c.state = "locked"
		c.reason = "Branch locked (two branches started)"
	else:
		c.node = br.mastery if t.mastered and t.primary() == key else br.nodes[maxi(0, mini(d, Tower.BRANCH_STEPS) - 1)]
		c.state = "done"
		c.reason = "Mastered" if t.mastered and t.primary() == key else "Fully upgraded"
	return c


## The Retrofit card: the chosen option once bought; before that, one card for the three options ("from" the
## cheapest price), which opens the pop-out.
static func _retrofit_card(t, c: Dictionary, gold: int) -> Dictionary:
	var opts: Array = t.retrofit_options()
	if t.retrofit >= 0:
		c.node = opts[t.retrofit]
		c.state = "done"
		c.reason = "Retrofit installed"
		return c
	var cheapest := 1 << 30
	var names: Array = []
	for i in opts.size():
		cheapest = mini(cheapest, t.retrofit_cost(i))
		names.append(str(opts[i].name))
	c.cost = cheapest
	c.node = {"name": "Retrofit", "blurb": "Pick one of %d: %s. The choice is locked." % [opts.size(), ", ".join(PackedStringArray(names))]}
	c.state = "buy" if gold >= cheapest else "short"
	if c.state == "short":
		c.reason = "Cannot afford"
	return c
