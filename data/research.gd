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

const TREE_ORDER := ["command", "arrow", "cannon", "frost", "sniper", "tesla", "laser", "missile", "amp", "flak", "sensor", "gravity", "nullifier", "nova", "drones", "scrap"]

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
}

const TREE_NAMES := {"command": "Command"}
