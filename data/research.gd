extends RefCounted
## Research Lab: a persistent skill tree bought with research points (RP) earned from sector records.
## One Command tree (run-wide bonuses) plus one tree per tower. Each tower tree ends in its Mastery
## node, which unlocks that tower's masteries.
##
## Node `slot` is its place in the tree diagram: x in -1..1 (column), y in 0..2 (row).
## `requires` lists parent nodes; owning any one of them is enough.
## Effects:
##   tower trees   "mult": {stat: +fraction}, "add": {stat: +amount} (only on levels that have the stat),
##                 "cost": build/upgrade discount fraction, "mastery": true
##   command tree  "start_gold": +fraction, "lives": +fraction of the mode's shields, "sell_refund": +fraction,
##                 "ability_cd": -fraction, "bounty": +fraction

const TREE_ORDER := ["command", "gun_turret", "mortar_tower", "rocket_salvo", "laser_tower", "anti_aircraft_turret", "artillery_cannon", "railgun", "tesla_tower", "drone_bay", "cas_gunship", "mine_layer", "chemical_plant", "cryo_tower", "boost_tower", "radar_tower", "shockwave_generator", "scrapyard", "magneto_tower", "tractor_tower", "augmentation_tower"]

## RP sources, all derived from profile records so they can't be farmed and are never lost.
## (Medals pay their mode's medal_rp, from data/difficulty.gd.)
static var RP_ROUND_MILESTONES := [20, 40, 60, 80, 100]
static var RP_ENDLESS_STEP := 10
static var RP_ENDLESS_MAX_PER_SECTOR := 5

static var NODES := {
	# --- Command ------------------------------------------------------------------------------
	"cmd_funds": {
		"tree": "command", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "credits",
		"name": "Reserve Funds", "blurb": "+10% starting credits.",
		"effects": {"start_gold": 0.10},
	},
	"cmd_salvage": {
		"tree": "command", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["cmd_funds"], "icon": "salvage",
		"name": "Salvage Protocols", "blurb": "Selling a tower refunds 85% instead of 70%.",
		"effects": {"sell_refund": 0.15},
	},
	"cmd_core": {
		"tree": "command", "slot": Vector2i(1, 1), "cost": 2, "requires": ["cmd_funds"], "icon": "shield",
		"name": "Reinforced Core", "blurb": "+10% core shields (rounded down, so Cataclysm stays at 1).",
		"effects": {"lives": 0.1},
	},
	"cmd_bounty": {
		"tree": "command", "slot": Vector2i(-1, 2), "cost": 3, "requires": ["cmd_salvage"], "icon": "credits",
		"name": "Bounty Contracts", "blurb": "+8% credits from destroyed hostiles.",
		"effects": {"bounty": 0.08},
	},
	"cmd_uplink": {
		"tree": "command", "slot": Vector2i(1, 2), "cost": 2, "requires": ["cmd_core"], "icon": "uplink",
		"name": "Orbital Uplink", "blurb": "Orbital Strike and Chrono Field recharge 20% faster.",
		"effects": {"ability_cd": 0.20},
	},

	# --- Gun Turret (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"gun_turret_1": {
		"tree": "gun_turret", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Hardened Barrels", "blurb": "Gun Turrets deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"gun_turret_2a": {
		"tree": "gun_turret", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["gun_turret_1"], "icon": "range",
		"name": "Ranging Optics", "blurb": "Gun Turrets get +7% range.",
		"effects": {"mult": {"range": 0.07}},
	},
	"gun_turret_2b": {
		"tree": "gun_turret", "slot": Vector2i(1, 1), "cost": 2, "requires": ["gun_turret_1"], "icon": "rate",
		"name": "Quick Feed", "blurb": "Gun Turrets fire 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"gun_turret_m": {
		"tree": "gun_turret", "slot": Vector2i(0, 2), "cost": 3, "requires": ["gun_turret_2a", "gun_turret_2b"], "icon": "mastery",
		"name": "Gun Turret Mastery", "blurb": "Unlocks the masteries: Sabot Rounds, Targeting Computer and Triple Mount.",
		"effects": {"mastery": true},
	},

	# --- Mortar Tower (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"mortar_tower_1": {
		"tree": "mortar_tower", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Heavy Charges", "blurb": "Mortars deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"mortar_tower_2a": {
		"tree": "mortar_tower", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["mortar_tower_1"], "icon": "range",
		"name": "Long Tubes", "blurb": "Mortars get +7% range.",
		"effects": {"mult": {"range": 0.07}},
	},
	"mortar_tower_2b": {
		"tree": "mortar_tower", "slot": Vector2i(1, 1), "cost": 2, "requires": ["mortar_tower_1"], "icon": "rate",
		"name": "Autoloaders", "blurb": "Mortars fire 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"mortar_tower_m": {
		"tree": "mortar_tower", "slot": Vector2i(0, 2), "cost": 3, "requires": ["mortar_tower_2a", "mortar_tower_2b"], "icon": "mastery",
		"name": "Mortar Tower Mastery", "blurb": "Unlocks the masteries: Bunker Buster, Barrage Battery and Carpet Shells.",
		"effects": {"mastery": true},
	},

	# --- Rocket Salvo (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"rocket_salvo_1": {
		"tree": "rocket_salvo", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Warhead Casings", "blurb": "Rocket Salvos deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"rocket_salvo_2a": {
		"tree": "rocket_salvo", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["rocket_salvo_1"], "icon": "range",
		"name": "Booster Fuel", "blurb": "Rocket Salvos get +7% range.",
		"effects": {"mult": {"range": 0.07}},
	},
	"rocket_salvo_2b": {
		"tree": "rocket_salvo", "slot": Vector2i(1, 1), "cost": 2, "requires": ["rocket_salvo_1"], "icon": "rate",
		"name": "Quick Racks", "blurb": "Rocket Salvos fire 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"rocket_salvo_m": {
		"tree": "rocket_salvo", "slot": Vector2i(0, 2), "cost": 3, "requires": ["rocket_salvo_2a", "rocket_salvo_2b"], "icon": "mastery",
		"name": "Rocket Salvo Mastery", "blurb": "Unlocks the masteries: Thermobaric Rockets, Hunter Seekers and Ripple Salvo.",
		"effects": {"mastery": true},
	},

	# --- Laser Tower (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"laser_tower_1": {
		"tree": "laser_tower", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Cleaner Optics", "blurb": "Laser Towers deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"laser_tower_2a": {
		"tree": "laser_tower", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["laser_tower_1"], "icon": "range",
		"name": "Focusing Mirrors", "blurb": "Laser Towers get +7% range.",
		"effects": {"mult": {"range": 0.07}},
	},
	"laser_tower_2b": {
		"tree": "laser_tower", "slot": Vector2i(1, 1), "cost": 2, "requires": ["laser_tower_1"], "icon": "rate",
		"name": "Capacitor Tuning", "blurb": "Laser Towers fire 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"laser_tower_m": {
		"tree": "laser_tower", "slot": Vector2i(0, 2), "cost": 3, "requires": ["laser_tower_2a", "laser_tower_2b"], "icon": "mastery",
		"name": "Laser Tower Mastery", "blurb": "Unlocks the masteries: Annihilator, Prism Array and Deep Lance.",
		"effects": {"mastery": true},
	},

	# --- Anti-Aircraft Turret (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"anti_aircraft_turret_1": {
		"tree": "anti_aircraft_turret", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Heavy Rounds", "blurb": "Anti-Aircraft Turrets deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"anti_aircraft_turret_2a": {
		"tree": "anti_aircraft_turret", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["anti_aircraft_turret_1"], "icon": "range",
		"name": "Radar Sights", "blurb": "Anti-Aircraft Turrets get +7% range.",
		"effects": {"mult": {"range": 0.07}},
	},
	"anti_aircraft_turret_2b": {
		"tree": "anti_aircraft_turret", "slot": Vector2i(1, 1), "cost": 2, "requires": ["anti_aircraft_turret_1"], "icon": "rate",
		"name": "Fast Feed", "blurb": "Anti-Aircraft Turrets fire 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"anti_aircraft_turret_m": {
		"tree": "anti_aircraft_turret", "slot": Vector2i(0, 2), "cost": 3, "requires": ["anti_aircraft_turret_2a", "anti_aircraft_turret_2b"], "icon": "mastery",
		"name": "Anti-Aircraft Turret Mastery", "blurb": "Unlocks the masteries: Flak Curtain, Quad Mount and Sky Wall.",
		"effects": {"mastery": true},
	},
	# --- Artillery Cannon (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"artillery_cannon_1": {
		"tree": "artillery_cannon", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Heavy Charges", "blurb": "Artillery shells deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"artillery_cannon_2a": {
		"tree": "artillery_cannon", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["artillery_cannon_1"], "icon": "damage",
		"name": "Wide Charges", "blurb": "Artillery shells burst 6% wider.",
		"effects": {"mult": {"splash": 0.06}},
	},
	"artillery_cannon_2b": {
		"tree": "artillery_cannon", "slot": Vector2i(1, 1), "cost": 2, "requires": ["artillery_cannon_1"], "icon": "rate",
		"name": "Autoloaders", "blurb": "Artillery fires 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"artillery_cannon_m": {
		"tree": "artillery_cannon", "slot": Vector2i(0, 2), "cost": 3, "requires": ["artillery_cannon_2a", "artillery_cannon_2b"], "icon": "mastery",
		"name": "Artillery Cannon Mastery", "blurb": "Unlocks the masteries: Siege Shells, Rolling Barrage and Combined Payload.",
		"effects": {"mastery": true},
	},

	# --- Railgun (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"railgun_1": {
		"tree": "railgun", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Dense Slugs", "blurb": "Railguns deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"railgun_2a": {
		"tree": "railgun", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["railgun_1"], "icon": "range",
		"name": "Long Rails", "blurb": "Railguns get +7% range.",
		"effects": {"mult": {"range": 0.07}},
	},
	"railgun_2b": {
		"tree": "railgun", "slot": Vector2i(1, 1), "cost": 2, "requires": ["railgun_1"], "icon": "rate",
		"name": "Fast Capacitors", "blurb": "Railguns recharge 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"railgun_m": {
		"tree": "railgun", "slot": Vector2i(0, 2), "cost": 3, "requires": ["railgun_2a", "railgun_2b"], "icon": "mastery",
		"name": "Railgun Mastery", "blurb": "Unlocks the masteries: Kingslayer, Twin Rails and Ion Cannon.",
		"effects": {"mastery": true},
	},

	# --- Tesla Tower (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"tesla_tower_1": {
		"tree": "tesla_tower", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "High Voltage", "blurb": "Tesla Towers deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"tesla_tower_2a": {
		"tree": "tesla_tower", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["tesla_tower_1"], "icon": "range",
		"name": "Taller Coils", "blurb": "Tesla Towers get +7% range.",
		"effects": {"mult": {"range": 0.07}},
	},
	"tesla_tower_2b": {
		"tree": "tesla_tower", "slot": Vector2i(1, 1), "cost": 2, "requires": ["tesla_tower_1"], "icon": "rate",
		"name": "Quick Discharge", "blurb": "Tesla Towers fire 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"tesla_tower_m": {
		"tree": "tesla_tower", "slot": Vector2i(0, 2), "cost": 3, "requires": ["tesla_tower_2a", "tesla_tower_2b"], "icon": "mastery",
		"name": "Tesla Tower Mastery", "blurb": "Unlocks the masteries: Lightning Rod, Tempest and Continuous Discharge.",
		"effects": {"mastery": true},
	},
	# --- Drone Bay (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"drone_bay_1": {
		"tree": "drone_bay", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Heavier Guns", "blurb": "Drone Bays deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"drone_bay_2a": {
		"tree": "drone_bay", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["drone_bay_1"], "icon": "rate",
		"name": "Fast Cycling", "blurb": "Drone Bays fire 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"drone_bay_2b": {
		"tree": "drone_bay", "slot": Vector2i(1, 1), "cost": 2, "requires": ["drone_bay_1"], "icon": "rate",
		"name": "Spare Parts", "blurb": "Drone Bays fire 4% faster.",
		"effects": {"mult": {"rate": 0.04}},
	},
	"drone_bay_m": {
		"tree": "drone_bay", "slot": Vector2i(0, 2), "cost": 3, "requires": ["drone_bay_2a", "drone_bay_2b"], "icon": "mastery",
		"name": "Drone Bay Mastery", "blurb": "Unlocks the masteries: Elite Drones, Full Kit and Storm Drones.",
		"effects": {"mastery": true},
	},
	# --- CAS Gunship (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"cas_gunship_1": {
		"tree": "cas_gunship", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Heavier Rounds", "blurb": "CAS Gunships deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"cas_gunship_2a": {
		"tree": "cas_gunship", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["cas_gunship_1"], "icon": "range",
		"name": "Wide Orbit", "blurb": "CAS Gunships orbit 7% wider.",
		"effects": {"mult": {"orbit": 0.07}},
	},
	"cas_gunship_2b": {
		"tree": "cas_gunship", "slot": Vector2i(1, 1), "cost": 2, "requires": ["cas_gunship_1"], "icon": "rate",
		"name": "Faster Spin", "blurb": "CAS Gunships fire 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"cas_gunship_m": {
		"tree": "cas_gunship", "slot": Vector2i(0, 2), "cost": 3, "requires": ["cas_gunship_2a", "cas_gunship_2b"], "icon": "mastery",
		"name": "CAS Gunship Mastery", "blurb": "Unlocks the masteries: Twin Gatlings, Autocannon Battery and Hellfire Volley.",
		"effects": {"mastery": true},
	},
	# --- Mine Layer (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"mine_layer_1": {
		"tree": "mine_layer", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Heavier Charges", "blurb": "Mine Layers deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"mine_layer_2a": {
		"tree": "mine_layer", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["mine_layer_1"], "icon": "range",
		"name": "Longer Arms", "blurb": "Mine Layers toss 7% farther.",
		"effects": {"mult": {"range": 0.07}},
	},
	"mine_layer_2b": {
		"tree": "mine_layer", "slot": Vector2i(1, 1), "cost": 2, "requires": ["mine_layer_1"], "icon": "rate",
		"name": "Faster Presses", "blurb": "Mine Layers lay mines 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"mine_layer_m": {
		"tree": "mine_layer", "slot": Vector2i(0, 2), "cost": 3, "requires": ["mine_layer_2a", "mine_layer_2b"], "icon": "mastery",
		"name": "Mine Layer Mastery", "blurb": "Unlocks the masteries: Anti-Tank Mines, Mine Factory and Minefield Launcher.",
		"effects": {"mastery": true},
	},
	# --- Chemical Plant (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"chemical_plant_1": {
		"tree": "chemical_plant", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "range",
		"name": "Wider Spray", "blurb": "Chemical Plants reach 7% farther.",
		"effects": {"mult": {"range": 0.07}},
	},
	"chemical_plant_2a": {
		"tree": "chemical_plant", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["chemical_plant_1"], "icon": "rate",
		"name": "Quick Valves", "blurb": "Chemical Plants spray 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"chemical_plant_2b": {
		"tree": "chemical_plant", "slot": Vector2i(1, 1), "cost": 2, "requires": ["chemical_plant_1"], "icon": "rate",
		"name": "Long-Lasting Mix", "blurb": "Soaks last 10% longer.",
		"effects": {"mult": {"soak_time": 0.1}},
	},
	"chemical_plant_m": {
		"tree": "chemical_plant", "slot": Vector2i(0, 2), "cost": 3, "requires": ["chemical_plant_2a", "chemical_plant_2b"], "icon": "mastery",
		"name": "Chemical Plant Mastery", "blurb": "Unlocks the masteries: Dissolver, Twin Nozzles and Quick-Set Foam.",
		"effects": {"mastery": true},
	},
	# --- Cryo Tower (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"cryo_tower_1": {
		"tree": "cryo_tower", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "range",
		"name": "Wider Vents", "blurb": "Cryo Towers reach 7% farther.",
		"effects": {"mult": {"range": 0.07}},
	},
	"cryo_tower_2a": {
		"tree": "cryo_tower", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["cryo_tower_1"], "icon": "rate",
		"name": "Colder Gas", "blurb": "Cryo Towers slow 7% more.",
		"effects": {"mult": {"slow": 0.07}},
	},
	"cryo_tower_2b": {
		"tree": "cryo_tower", "slot": Vector2i(1, 1), "cost": 2, "requires": ["cryo_tower_1"], "icon": "rate",
		"name": "Quick Vents", "blurb": "Cryo Towers pulse 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"cryo_tower_m": {
		"tree": "cryo_tower", "slot": Vector2i(0, 2), "cost": 3, "requires": ["cryo_tower_2a", "cryo_tower_2b"], "icon": "mastery",
		"name": "Cryo Tower Mastery", "blurb": "Unlocks the masteries: Deep Freeze, Blizzard and Cold Front.",
		"effects": {"mastery": true},
	},
	# --- Boost Tower (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"boost_tower_1": {
		"tree": "boost_tower", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "range",
		"name": "Wider Field", "blurb": "Boost Towers reach 7% farther.",
		"effects": {"mult": {"range": 0.07}},
	},
	"boost_tower_2a": {
		"tree": "boost_tower", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["boost_tower_1"], "icon": "damage",
		"name": "Stronger Signal", "blurb": "Damage boosts are 10% stronger.",
		"effects": {"mult": {"buff_dmg": 0.1}},
	},
	"boost_tower_2b": {
		"tree": "boost_tower", "slot": Vector2i(1, 1), "cost": 2, "requires": ["boost_tower_1"], "icon": "rate",
		"name": "Faster Sync", "blurb": "Fire-rate boosts are 10% stronger.",
		"effects": {"mult": {"buff_rate": 0.1}},
	},
	"boost_tower_m": {
		"tree": "boost_tower", "slot": Vector2i(0, 2), "cost": 3, "requires": ["boost_tower_2a", "boost_tower_2b"], "icon": "mastery",
		"name": "Boost Tower Mastery", "blurb": "Unlocks the masteries: Battle Network, Rapid Network and Overwatch Network.",
		"effects": {"mastery": true},
	},
	# --- Radar Tower (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"radar_tower_1": {
		"tree": "radar_tower", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "range",
		"name": "Wider Dish", "blurb": "Radar Towers reach 7% farther.",
		"effects": {"mult": {"range": 0.07}},
	},
	"radar_tower_2a": {
		"tree": "radar_tower", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["radar_tower_1"], "icon": "rate",
		"name": "Fast Sweep", "blurb": "Radar Towers ping 8% more often.",
		"effects": {"mult": {"ping_every": -0.08}},
	},
	"radar_tower_2b": {
		"tree": "radar_tower", "slot": Vector2i(1, 1), "cost": 2, "requires": ["radar_tower_1"], "icon": "rate",
		"name": "Long Hold", "blurb": "Reveals last 10% longer.",
		"effects": {"mult": {"reveal_time": 0.1}},
	},
	"radar_tower_m": {
		"tree": "radar_tower", "slot": Vector2i(0, 2), "cost": 3, "requires": ["radar_tower_2a", "radar_tower_2b"], "icon": "mastery",
		"name": "Radar Tower Mastery", "blurb": "Unlocks the masteries: Microwave Array, Constant Track and Total Exposure.",
		"effects": {"mastery": true},
	},
	# --- Shockwave Generator (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"shockwave_generator_1": {
		"tree": "shockwave_generator", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Hotter Core", "blurb": "Shockwave Generators deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"shockwave_generator_2a": {
		"tree": "shockwave_generator", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["shockwave_generator_1"], "icon": "range",
		"name": "Wave Focus", "blurb": "Shockwave Generators reach 7% farther.",
		"effects": {"mult": {"range": 0.07}},
	},
	"shockwave_generator_2b": {
		"tree": "shockwave_generator", "slot": Vector2i(1, 1), "cost": 2, "requires": ["shockwave_generator_1"], "icon": "rate",
		"name": "Fast Cycle", "blurb": "Shockwave Generators pulse 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"shockwave_generator_m": {
		"tree": "shockwave_generator", "slot": Vector2i(0, 2), "cost": 3, "requires": ["shockwave_generator_2a", "shockwave_generator_2b"], "icon": "mastery",
		"name": "Shockwave Generator Mastery", "blurb": "Unlocks the masteries: Megaton Wave, Chain Pulse and Shatter Shock.",
		"effects": {"mastery": true},
	},
	# --- Scrapyard (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"scrapyard_1": {
		"tree": "scrapyard", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Better Linings", "blurb": "Scrapyards pay 6% more per round.",
		"effects": {"mult": {"income": 0.06}},
	},
	"scrapyard_2a": {
		"tree": "scrapyard", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["scrapyard_1"], "icon": "range",
		"name": "Wider Yard", "blurb": "Scrapyard fields reach 7% farther.",
		"effects": {"mult": {"range": 0.07}},
	},
	"scrapyard_2b": {
		"tree": "scrapyard", "slot": Vector2i(1, 1), "cost": 2, "requires": ["scrapyard_1"], "icon": "rate",
		"name": "Hard Bargains", "blurb": "Scrapyard kill bonuses are 10% stronger.",
		"effects": {"mult": {"bounty_bonus": 0.1}},
	},
	"scrapyard_m": {
		"tree": "scrapyard", "slot": Vector2i(0, 2), "cost": 3, "requires": ["scrapyard_2a", "scrapyard_2b"], "icon": "mastery",
		"name": "Scrapyard Mastery", "blurb": "Unlocks the masteries: Gold Foundry, Breaker's Yard and Parts Exchange.",
		"effects": {"mastery": true},
	},
	# --- Magneto Tower (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"magneto_tower_1": {
		"tree": "magneto_tower", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "range",
		"name": "Wider Coil", "blurb": "Magneto Towers reach 7% farther.",
		"effects": {"mult": {"range": 0.07}},
	},
	"magneto_tower_2a": {
		"tree": "magneto_tower", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["magneto_tower_1"], "icon": "rate",
		"name": "Stronger Coil", "blurb": "Magneto Towers slow 7% more.",
		"effects": {"mult": {"slow": 0.07}},
	},
	"magneto_tower_2b": {
		"tree": "magneto_tower", "slot": Vector2i(1, 1), "cost": 2, "requires": ["magneto_tower_1"], "icon": "rate",
		"name": "Cold Windings", "blurb": "Magneto Towers slow 4% more.",
		"effects": {"mult": {"slow": 0.04}},
	},
	"magneto_tower_m": {
		"tree": "magneto_tower", "slot": Vector2i(0, 2), "cost": 3, "requires": ["magneto_tower_2a", "magneto_tower_2b"], "icon": "mastery",
		"name": "Magneto Tower Mastery", "blurb": "Unlocks the masteries: Absolute Pull, Magnetosphere and Reverse Polarity.",
		"effects": {"mastery": true},
	},
	# --- Tractor Tower (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"tractor_tower_1": {
		"tree": "tractor_tower", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "range",
		"name": "Long Dish", "blurb": "Tractor Towers reach 7% farther.",
		"effects": {"mult": {"range": 0.07}},
	},
	"tractor_tower_2a": {
		"tree": "tractor_tower", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["tractor_tower_1"], "icon": "rate",
		"name": "Quick Release", "blurb": "Tractor Towers recharge 7% faster.",
		"effects": {"mult": {"recharge": -0.07}},
	},
	"tractor_tower_2b": {
		"tree": "tractor_tower", "slot": Vector2i(1, 1), "cost": 2, "requires": ["tractor_tower_1"], "icon": "rate",
		"name": "Steady Beam", "blurb": "Holds last 8% longer.",
		"effects": {"mult": {"hold": 0.08}},
	},
	"tractor_tower_m": {
		"tree": "tractor_tower", "slot": Vector2i(0, 2), "cost": 3, "requires": ["tractor_tower_2a", "tractor_tower_2b"], "icon": "mastery",
		"name": "Tractor Tower Mastery", "blurb": "Unlocks the masteries: Undo, Supercapacitor and Gravity Hammer.",
		"effects": {"mastery": true},
	},
	# --- Augmentation Tower (the tower rework, issue #59: a minimal tree until the research pass) ----------
	"augmentation_tower_1": {
		"tree": "augmentation_tower", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "range",
		"name": "Wider Aura", "blurb": "Augmentation Towers reach 7% farther.",
		"effects": {"mult": {"range": 0.07}},
	},
	"augmentation_tower_2a": {
		"tree": "augmentation_tower", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["augmentation_tower_1"], "icon": "damage",
		"name": "Sharper Crits", "blurb": "Crit chances are 10% higher.",
		"effects": {"mult": {"aug_crit": 0.1}},
	},
	"augmentation_tower_2b": {
		"tree": "augmentation_tower", "slot": Vector2i(1, 1), "cost": 2, "requires": ["augmentation_tower_1"], "icon": "rate",
		"name": "Lucky Bounces", "blurb": "Ricochet chances are 10% higher.",
		"effects": {"mult": {"ricochet": 0.1}},
	},
	"augmentation_tower_m": {
		"tree": "augmentation_tower", "slot": Vector2i(0, 2), "cost": 3, "requires": ["augmentation_tower_2a", "augmentation_tower_2b"], "icon": "mastery",
		"name": "Augmentation Tower Mastery", "blurb": "Unlocks the masteries: Overcharge, Executioner Link and Pinball.",
		"effects": {"mastery": true},
	},
}

const TREE_NAMES := {"command": "Command"}
