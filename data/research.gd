extends RefCounted
## Research Lab: a persistent skill tree bought with research points (RP) earned from sector records.
## One Command tree (run-wide bonuses) plus one tree per tower. Each tower tree ends in its Mastery
## node, which unlocks that tower's tier-4 upgrade for both specializations.
##
## Node `slot` is its place in the tree diagram: x in -1..1 (column), y in 0..2 (row).
## `requires` lists parent nodes; owning any one of them is enough.
## Effects:
##   tower trees   "mult": {stat: +fraction}, "add": {stat: +amount} (only on levels that have the stat),
##                 "cost": build/upgrade discount fraction, "mastery": true
##   command tree  "start_gold": +fraction, "lives": +fraction of the mode's shields, "sell_refund": +fraction,
##                 "ability_cd": -fraction, "bounty": +fraction

const TREE_ORDER := ["command", "arrow", "cannon", "frost", "sniper", "tesla", "laser", "missile", "amp", "flak", "sensor", "gravity", "nullifier", "nova", "drones", "scrap", "gun_turret", "mortar_tower", "rocket_salvo", "laser_tower", "anti_aircraft_turret", "artillery_cannon", "railgun", "tesla_tower", "drone_bay", "cas_gunship", "mine_layer", "chemical_plant", "cryo_tower", "boost_tower", "radar_tower", "shockwave_generator", "scrapyard", "magneto_tower", "tractor_tower", "augmentation_tower"]

## RP sources, all derived from profile records so they can't be farmed and are never lost.
## (Medals pay their mode's medal_rp, from data/difficulty.gd.)
const RP_ROUND_MILESTONES := [20, 40, 60, 80, 100]
const RP_ENDLESS_STEP := 10
const RP_ENDLESS_MAX_PER_SECTOR := 5

const NODES := {
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

	# --- Pulse Turret -------------------------------------------------------------------------
	"arrow_1": {
		"tree": "arrow", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Capacitor Tuning", "blurb": "Pulse Turrets deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"arrow_2a": {
		"tree": "arrow", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["arrow_1"], "icon": "range",
		"name": "Long Barrels", "blurb": "Pulse Turrets get +7% range.",
		"effects": {"mult": {"range": 0.07}},
	},
	"arrow_2b": {
		"tree": "arrow", "slot": Vector2i(1, 1), "cost": 2, "requires": ["arrow_1"], "icon": "rate",
		"name": "Rapid Cyclers", "blurb": "Pulse Turrets fire 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"arrow_m": {
		"tree": "arrow", "slot": Vector2i(0, 2), "cost": 3, "requires": ["arrow_2a", "arrow_2b"], "icon": "mastery",
		"name": "Pulse Mastery", "blurb": "Unlocks the masteries: Storm Gatling, Disintegrator and Hailstorm.",
		"effects": {"mastery": true},
	},

	# --- Plasma Mortar ------------------------------------------------------------------------
	"cannon_1": {
		"tree": "cannon", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Dense Plasma", "blurb": "Plasma Mortars deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"cannon_2a": {
		"tree": "cannon", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["cannon_1"], "icon": "range",
		"name": "Ballistic Computer", "blurb": "Plasma Mortars get +7% range.",
		"effects": {"mult": {"range": 0.07}},
	},
	"cannon_2b": {
		"tree": "cannon", "slot": Vector2i(1, 1), "cost": 2, "requires": ["cannon_1"], "icon": "blast",
		"name": "Wide Shells", "blurb": "Plasma Mortar blasts are 10% wider.",
		"effects": {"mult": {"splash": 0.10}},
	},
	"cannon_m": {
		"tree": "cannon", "slot": Vector2i(0, 2), "cost": 3, "requires": ["cannon_2a", "cannon_2b"], "icon": "mastery",
		"name": "Mortar Mastery", "blurb": "Unlocks the masteries: Earthshaker, Inferno Mortar and Seismic Charge.",
		"effects": {"mastery": true},
	},

	# --- Cryo Emitter -------------------------------------------------------------------------
	"frost_1": {
		"tree": "frost", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "range",
		"name": "Wide Emitters", "blurb": "Cryo Emitter fields are 6% wider.",
		"effects": {"mult": {"range": 0.06}},
	},
	"frost_2a": {
		"tree": "frost", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["frost_1"], "icon": "slow",
		"name": "Deep Freeze", "blurb": "Cryo slows are 5 points stronger and last 0.4 s longer.",
		"effects": {"add": {"slow": 0.05, "slow_time": 0.4}},
	},
	"frost_2b": {
		"tree": "frost", "slot": Vector2i(1, 1), "cost": 2, "requires": ["frost_1"], "icon": "rate",
		"name": "Rapid Pulse", "blurb": "Cryo Emitters pulse 7% faster.",
		"effects": {"mult": {"rate": 0.07}},
	},
	"frost_m": {
		"tree": "frost", "slot": Vector2i(0, 2), "cost": 3, "requires": ["frost_2a", "frost_2b"], "icon": "mastery",
		"name": "Cryo Mastery", "blurb": "Unlocks the masteries: Absolute Zero, Cryo Fracture and Permafrost.",
		"effects": {"mastery": true},
	},

	# --- Railgun ------------------------------------------------------------------------------
	"sniper_1": {
		"tree": "sniper", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Heavy Slugs", "blurb": "Railguns deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"sniper_2a": {
		"tree": "sniper", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["sniper_1"], "icon": "range",
		"name": "Long-Range Optics", "blurb": "Railguns get +7% range.",
		"effects": {"mult": {"range": 0.07}},
	},
	"sniper_2b": {
		"tree": "sniper", "slot": Vector2i(1, 1), "cost": 2, "requires": ["sniper_1"], "icon": "rate",
		"name": "Capacitor Bank", "blurb": "Railguns recharge 8% faster.",
		"effects": {"mult": {"rate": 0.08}},
	},
	"sniper_m": {
		"tree": "sniper", "slot": Vector2i(0, 2), "cost": 3, "requires": ["sniper_2a", "sniper_2b"], "icon": "mastery",
		"name": "Railgun Mastery", "blurb": "Unlocks the masteries: Executioner, Ion Lance and Void Round.",
		"effects": {"mastery": true},
	},

	# --- Arc Coil -----------------------------------------------------------------------------
	"tesla_1": {
		"tree": "tesla", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Higher Voltage", "blurb": "Arc Coils deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"tesla_2a": {
		"tree": "tesla", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["tesla_1"], "icon": "range",
		"name": "Tesla Antennae", "blurb": "Arc Coils get +7% range and arcs jump 10% farther.",
		"effects": {"mult": {"range": 0.07, "chain_range": 0.10}},
	},
	"tesla_2b": {
		"tree": "tesla", "slot": Vector2i(1, 1), "cost": 2, "requires": ["tesla_1"], "icon": "chain",
		"name": "Conductive Arcs", "blurb": "Arcs jump to 1 more target.",
		"effects": {"add": {"chains": 1}},
	},
	"tesla_m": {
		"tree": "tesla", "slot": Vector2i(0, 2), "cost": 3, "requires": ["tesla_2a", "tesla_2b"], "icon": "mastery",
		"name": "Arc Mastery", "blurb": "Unlocks the masteries: Tempest Coil, Supercharger and Maelstrom.",
		"effects": {"mastery": true},
	},

	# --- Laser Lance --------------------------------------------------------------------------
	"laser_1": {
		"tree": "laser", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Beam Focusing", "blurb": "Laser Lances deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"laser_2a": {
		"tree": "laser", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["laser_1"], "icon": "range",
		"name": "Lens Array", "blurb": "Laser Lances get +7% range.",
		"effects": {"mult": {"range": 0.07}},
	},
	"laser_2b": {
		"tree": "laser", "slot": Vector2i(1, 1), "cost": 2, "requires": ["laser_1"], "icon": "rate",
		"name": "Heat Sinks", "blurb": "Laser damage ramps up 20% faster.",
		"effects": {"mult": {"ramp_time": -0.20}},
	},
	"laser_m": {
		"tree": "laser", "slot": Vector2i(0, 2), "cost": 3, "requires": ["laser_2a", "laser_2b"], "icon": "mastery",
		"name": "Laser Mastery", "blurb": "Unlocks the masteries: Refraction Grid, Singularity Lens and Scythe Array.",
		"effects": {"mastery": true},
	},

	# --- Missile Battery ----------------------------------------------------------------------
	"missile_1": {
		"tree": "missile", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Shaped Charges", "blurb": "Missiles deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"missile_2a": {
		"tree": "missile", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["missile_1"], "icon": "range",
		"name": "Radar Uplink", "blurb": "Missile Batteries get +7% range.",
		"effects": {"mult": {"range": 0.07}},
	},
	"missile_2b": {
		"tree": "missile", "slot": Vector2i(1, 1), "cost": 2, "requires": ["missile_1"], "icon": "blast",
		"name": "Warhead Packing", "blurb": "Missile blasts are 12% wider.",
		"effects": {"mult": {"splash": 0.12}},
	},
	"missile_m": {
		"tree": "missile", "slot": Vector2i(0, 2), "cost": 3, "requires": ["missile_2a", "missile_2b"], "icon": "mastery",
		"name": "Missile Mastery", "blurb": "Unlocks the masteries: Locust Swarm, Doomsday Warheads and Carpet Bomber.",
		"effects": {"mastery": true},
	},

	# --- Amplifier Pylon ----------------------------------------------------------------------
	"amp_1": {
		"tree": "amp", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "range",
		"name": "Field Coils", "blurb": "Amplifier fields are 8% wider.",
		"effects": {"mult": {"range": 0.08}},
	},
	"amp_2a": {
		"tree": "amp", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["amp_1"], "icon": "damage",
		"name": "Resonance", "blurb": "Amplifier damage boosts are 4 points stronger.",
		"effects": {"add": {"buff_dmg": 0.04}},
	},
	"amp_2b": {
		"tree": "amp", "slot": Vector2i(1, 1), "cost": 2, "requires": ["amp_1"], "icon": "credits",
		"name": "Modular Build", "blurb": "Amplifier Pylons and their upgrades cost 20% less.",
		"effects": {"cost": 0.20},
	},
	"amp_m": {
		"tree": "amp", "slot": Vector2i(0, 2), "cost": 3, "requires": ["amp_2a", "amp_2b"], "icon": "mastery",
		"name": "Amplifier Mastery", "blurb": "Unlocks the masteries: Hypercore Pylon, Command Array and Silence Pylon.",
		"effects": {"mastery": true},
	},

	# --- Flak Battery -------------------------------------------------------------------------
	"flak_1": {
		"tree": "flak", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Fused Shells", "blurb": "Flak Batteries deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"flak_2a": {
		"tree": "flak", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["flak_1"], "icon": "range",
		"name": "Tracking Radar", "blurb": "Flak Batteries get +7% range.",
		"effects": {"mult": {"range": 0.07}},
	},
	"flak_2b": {
		"tree": "flak", "slot": Vector2i(1, 1), "cost": 2, "requires": ["flak_1"], "icon": "blast",
		"name": "Fragmentation", "blurb": "Flak bursts are 12% wider.",
		"effects": {"mult": {"splash": 0.12}},
	},
	"flak_m": {
		"tree": "flak", "slot": Vector2i(0, 2), "cost": 3, "requires": ["flak_2a", "flak_2b"], "icon": "mastery",
		"name": "Flak Mastery", "blurb": "Unlocks the masteries: Aerial Denial, Thunderhead and Flak Curtain.",
		"effects": {"mastery": true},
	},

	# --- Sensor Array -------------------------------------------------------------------------
	"sensor_1": {
		"tree": "sensor", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "range",
		"name": "Signal Boost", "blurb": "Sensor fields are 8% wider.",
		"effects": {"mult": {"range": 0.08}},
	},
	"sensor_2a": {
		"tree": "sensor", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["sensor_1"], "icon": "damage",
		"name": "Resonant Marks", "blurb": "Sensor marks are 3 points stronger.",
		"effects": {"add": {"mark": 0.03}},
	},
	"sensor_2b": {
		"tree": "sensor", "slot": Vector2i(1, 1), "cost": 2, "requires": ["sensor_1"], "icon": "credits",
		"name": "Compact Arrays", "blurb": "Sensor Arrays and their upgrades cost 20% less.",
		"effects": {"cost": 0.20},
	},
	"sensor_m": {
		"tree": "sensor", "slot": Vector2i(0, 2), "cost": 3, "requires": ["sensor_2a", "sensor_2b"], "icon": "mastery",
		"name": "Sensor Mastery", "blurb": "Unlocks the masteries: Omniscient Grid, Kill Beacon and Blackout Grid.",
		"effects": {"mastery": true},
	},

	# --- Graviton Projector -------------------------------------------------------------------
	"gravity_1": {
		"tree": "gravity", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Dense Core", "blurb": "Graviton Projectors deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"gravity_2a": {
		"tree": "gravity", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["gravity_1"], "icon": "range",
		"name": "Field Lens", "blurb": "Graviton Projectors get +7% range.",
		"effects": {"mult": {"range": 0.07}},
	},
	"gravity_2b": {
		"tree": "gravity", "slot": Vector2i(1, 1), "cost": 2, "requires": ["gravity_1"], "icon": "push",
		"name": "Stronger Field", "blurb": "Graviton pulses shove enemies 12% farther.",
		"effects": {"mult": {"push": 0.12}},
	},
	"gravity_m": {
		"tree": "gravity", "slot": Vector2i(0, 2), "cost": 3, "requires": ["gravity_2a", "gravity_2b"], "icon": "mastery",
		"name": "Graviton Mastery", "blurb": "Unlocks the masteries: Singularity Engine, Event Horizon and Collapse Point.",
		"effects": {"mastery": true},
	},
	"nullifier_1": {
		"tree": "nullifier", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "shield",
		"name": "Null Coils", "blurb": "Nullifiers strip 6% more of every barrier.",
		"effects": {"mult": {"strip": 0.06}},
	},
	"nullifier_2a": {
		"tree": "nullifier", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["nullifier_1"], "icon": "range",
		"name": "Wide Emitters", "blurb": "Nullifier fields are 10% wider.",
		"effects": {"mult": {"range": 0.10}},
	},
	"nullifier_2b": {
		"tree": "nullifier", "slot": Vector2i(1, 1), "cost": 2, "requires": ["nullifier_1"], "icon": "rate",
		"name": "Rapid Discharge", "blurb": "Nullifiers pulse 10% more often.",
		"effects": {"mult": {"rate": 0.10}},
	},
	"nullifier_m": {
		"tree": "nullifier", "slot": Vector2i(0, 2), "cost": 3, "requires": ["nullifier_2a", "nullifier_2b"], "icon": "mastery",
		"name": "Nullifier Mastery", "blurb": "Unlocks the masteries: Absolute Null, Silence Engine and Overload Cascade.",
		"effects": {"mastery": true},
	},
	"nova_1": {
		"tree": "nova", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Reactor Tuning", "blurb": "Nova Reactors deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"nova_2a": {
		"tree": "nova", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["nova_1"], "icon": "range",
		"name": "Shock Lensing", "blurb": "Nova shockwaves reach 8% further.",
		"effects": {"mult": {"range": 0.08}},
	},
	"nova_2b": {
		"tree": "nova", "slot": Vector2i(1, 1), "cost": 2, "requires": ["nova_1"], "icon": "rate",
		"name": "Fusion Stability", "blurb": "Nova Reactors release waves 10% more often.",
		"effects": {"mult": {"rate": 0.10}},
	},
	"nova_m": {
		"tree": "nova", "slot": Vector2i(0, 2), "cost": 3, "requires": ["nova_2a", "nova_2b"], "icon": "mastery",
		"name": "Nova Mastery", "blurb": "Unlocks the masteries: Hypernova, Chain Reactor and Corona.",
		"effects": {"mastery": true},
	},
	"drones_1": {
		"tree": "drones", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "damage",
		"name": "Drone Firmware", "blurb": "Drones deal +6% damage.",
		"effects": {"mult": {"damage": 0.06}},
	},
	"drones_2a": {
		"tree": "drones", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["drones_1"], "icon": "uplink",
		"name": "Long-Range Uplink", "blurb": "Drones fly 10% faster.",
		"effects": {"mult": {"drone_speed": 0.10}},
	},
	"drones_2b": {
		"tree": "drones", "slot": Vector2i(1, 1), "cost": 2, "requires": ["drones_1"], "icon": "rate",
		"name": "Spare Airframes", "blurb": "Every Drone Bay launches one more drone.",
		"effects": {"add": {"drones": 1}},
	},
	"drones_m": {
		"tree": "drones", "slot": Vector2i(0, 2), "cost": 3, "requires": ["drones_2a", "drones_2b"], "icon": "mastery",
		"name": "Drone Bay Mastery", "blurb": "Unlocks the masteries: Swarm Carrier, Strike Wing and Assassin Protocol.",
		"effects": {"mastery": true},
	},
	"scrap_1": {
		"tree": "scrap", "slot": Vector2i(0, 0), "cost": 1, "requires": [], "icon": "credits",
		"name": "Scrap Contracts", "blurb": "Scrapyards pay 10% more credits per round.",
		"effects": {"mult": {"income": 0.10}},
	},
	"scrap_2a": {
		"tree": "scrap", "slot": Vector2i(-1, 1), "cost": 2, "requires": ["scrap_1"], "icon": "range",
		"name": "Long Cranes", "blurb": "Scrapyard fields are 10% wider.",
		"effects": {"mult": {"range": 0.10}},
	},
	"scrap_2b": {
		"tree": "scrap", "slot": Vector2i(1, 1), "cost": 2, "requires": ["scrap_1"], "icon": "salvage",
		"name": "Salvage Rights", "blurb": "Scrapyards and their upgrades cost 20% less.",
		"effects": {"cost": 0.20},
	},
	"scrap_m": {
		"tree": "scrap", "slot": Vector2i(0, 2), "cost": 3, "requires": ["scrap_2a", "scrap_2b"], "icon": "mastery",
		"name": "Scrapyard Mastery", "blurb": "Unlocks the masteries: Reserve Bank, Reclamation Plant and Forward Command.",
		"effects": {"mastery": true},
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
