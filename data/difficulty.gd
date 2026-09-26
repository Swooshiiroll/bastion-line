extends RefCounted
## Difficulty modes. A mode sets how many rounds a run lasts and how many core shields you start
## with, and how much towers cost to build and upgrade (`price`). Enemy strength depends only on the
## round number, so longer modes reach tougher rounds.
## Clearing a mode's last round earns that sector's medal for the mode, then endless mode begins.

const ORDER := ["easy", "medium", "hard", "nightmare", "cataclysm"]

const DIFFICULTIES := {
	"easy": {
		"name": "Easy", "rounds": 40, "lives": 200, "medal_rp": 1, "price": 1.0,
		"blurb": "40 rounds, 200 core shields.",
		"color": Color(0.46, 0.86, 0.46),
	},
	"medium": {
		"name": "Medium", "rounds": 60, "lives": 100, "medal_rp": 2, "price": 1.0,
		"blurb": "60 rounds, 100 core shields.",
		"color": Color(0.98, 0.80, 0.36),
	},
	"hard": {
		"name": "Hard", "rounds": 80, "lives": 50, "medal_rp": 3, "price": 1.1,
		"blurb": "80 rounds, 50 core shields. Towers cost 10% more.",
		"color": Color(1.0, 0.56, 0.28),
	},
	"nightmare": {
		"name": "Nightmare", "rounds": 100, "lives": 25, "medal_rp": 4, "price": 1.5,
		"blurb": "100 rounds, 25 core shields. Towers cost 50% more.",
		"color": Color(0.96, 0.36, 0.42),
	},
	"cataclysm": {
		"name": "Cataclysm", "rounds": 120, "lives": 1, "medal_rp": 5, "price": 2.0,
		"blurb": "120 rounds, 1 core shield: a single leak ends the run. Towers cost double.",
		"color": Color(0.78, 0.44, 1.0),
	},
}

## Old (v2) mode ids and what they became.
const LEGACY := {"casual": "easy", "normal": "medium", "veteran": "hard"}


static func rounds(mode: String) -> int:
	return int(DIFFICULTIES.get(mode, DIFFICULTIES.medium).rounds)


static func lives(mode: String) -> int:
	return int(DIFFICULTIES.get(mode, DIFFICULTIES.medium).lives)


## Balance-probe override for every mode's tower price (0 = use the mode's own).
static var price_override := 0.0


## Multiplier on every tower build and upgrade price in this mode.
static func price(mode: String) -> float:
	if price_override > 0.0:
		return price_override
	return float(DIFFICULTIES.get(mode, DIFFICULTIES.medium).get("price", 1.0))


## A current mode id for `mode`, mapping old ids across; "" if it's unknown.
static func resolve(mode: String) -> String:
	if DIFFICULTIES.has(mode):
		return mode
	return str(LEGACY.get(mode, ""))
