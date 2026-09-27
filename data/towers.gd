extends RefCounted
## Tower definitions: name, blurb and flags (air, ground, support, sensor, economy, beam, pulse, drones),
## plus `size` (tiles per side, default 1; the Scrapyard and Drone Bay are 2x2).
## Upgrade trees and their numbers live in data/tower_trees.gd (generated from
## design/upgrade_trees.md). The `tiers` and `specs` here only supply values the design file doesn't
## list (projectile speeds, chain falloff, laser ramp time...) for the original branches A and B.
## Ranges are pixels (one tile = 48 px); `rate` is attacks per second; laser `damage` is per second.
## Internal ids (arrow, cannon, ...) predate the sci-fi theme and are kept so old saves stay valid.

const ORDER := ["arrow", "cannon", "frost", "sniper", "tesla", "laser", "missile", "amp", "flak", "sensor", "gravity", "nullifier", "nova", "drones", "scrap"]

const TOWERS := {
	"arrow": {
		"name": "Pulse Turret",
		"blurb": "Cheap, rapid energy bolts at a single target. Hits flyers. Weak against heavy armor.",
		"air": true,
		"tiers": [
			{"cost": 50, "damage": 9.0, "range": 140.0, "rate": 2.0, "proj_speed": 760.0},
			{"cost": 70, "damage": 15.0, "range": 152.0, "rate": 2.4, "proj_speed": 820.0},
		],
		"spec_order": ["gatling", "shredder"],
		"specs": {
			"gatling": {
				"name": "Gatling Pulse", "cost": 140, "damage": 16.0, "range": 160.0, "rate": 5.0, "proj_speed": 900.0,
				"blurb": "Four spinning barrels: double the rate of fire.",
				"mastery": {
					"name": "Storm Gatling", "cost": 300, "damage": 18.0, "range": 170.0, "rate": 6.0, "proj_speed": 950.0,
					"multishot": 2,
					"blurb": "Twin ammo feeds: every volley also fires at a second target.",
				},
			},
			"shredder": {
				"name": "Shredder", "cost": 140, "damage": 28.0, "range": 165.0, "rate": 3.0, "proj_speed": 900.0,
				"shred": 1.0, "shred_max": 8.0,
				"blurb": "Each hit permanently strips 1 armor from the target (up to 8).",
				"mastery": {
					"name": "Disintegrator", "cost": 300, "damage": 42.0, "range": 175.0, "rate": 3.4, "proj_speed": 950.0,
					"shred": 2.0, "shred_max": 12.0,
					"blurb": "Each hit strips 2 armor (up to 12). Dreadnoughts come apart.",
				},
			},
		},
	},
	"cannon": {
		"name": "Plasma Mortar",
		"blurb": "Lobs plasma shells that burst on every ground enemy in the blast. Cannot hit flyers.",
		"air": false,
		"tiers": [
			{"cost": 90, "damage": 22.0, "range": 130.0, "rate": 0.7, "splash": 55.0, "proj_speed": 420.0},
			{"cost": 120, "damage": 40.0, "range": 140.0, "rate": 0.75, "splash": 65.0, "proj_speed": 450.0},
		],
		"spec_order": ["siege", "napalm"],
		"specs": {
			"siege": {
				"name": "Siege Mortar", "cost": 210, "damage": 80.0, "range": 165.0, "rate": 0.8, "splash": 90.0, "proj_speed": 480.0,
				"blurb": "Heavier shells, a much bigger blast and longer range.",
				"mastery": {
					"name": "Earthshaker", "cost": 380, "damage": 125.0, "range": 180.0, "rate": 0.85, "splash": 100.0, "proj_speed": 500.0,
					"stun": 0.4,
					"blurb": "Shockwave shells stun everything in the blast for 0.4 s (bosses 0.12 s).",
				},
			},
			"napalm": {
				"name": "Plasma Burn", "cost": 210, "damage": 55.0, "range": 150.0, "rate": 0.8, "splash": 70.0, "proj_speed": 480.0,
				"burn_dps": 32.0, "burn_time": 3.0,
				"blurb": "Leaves a plasma pool that burns ground enemies for 3 s, ignoring armor.",
				"mastery": {
					"name": "Inferno Mortar", "cost": 380, "damage": 75.0, "range": 160.0, "rate": 0.85, "splash": 80.0, "proj_speed": 500.0,
					"burn_dps": 55.0, "burn_time": 4.0,
					"blurb": "White-hot pools: 55 burn damage per second for 4 s, ignoring armor.",
				},
			},
		},
	},
	"frost": {
		"name": "Cryo Emitter",
		"blurb": "Pulses cryo-fields that slow everything nearby, flyers too, and deal light damage. The strongest slow applies; they don't stack.",
		"air": true,
		"tiers": [
			{"cost": 70, "damage": 3.0, "range": 105.0, "rate": 1.0, "slow": 0.35, "slow_time": 1.4},
			{"cost": 90, "damage": 6.0, "range": 118.0, "rate": 1.1, "slow": 0.45, "slow_time": 1.5},
		],
		"spec_order": ["stasis", "shatter"],
		"specs": {
			"stasis": {
				"name": "Stasis Field", "cost": 150, "damage": 10.0, "range": 145.0, "rate": 1.3, "slow": 0.65, "slow_time": 1.8,
				"blurb": "Near-freezing slow over a wide area.",
				"mastery": {
					"name": "Absolute Zero", "cost": 280, "damage": 18.0, "range": 175.0, "rate": 1.5, "slow": 0.7, "slow_time": 2.2,
					"blurb": "The maximum 70% slow over the widest field in the arsenal.",
				},
			},
			"shatter": {
				"name": "Shatter Field", "cost": 150, "damage": 12.0, "range": 132.0, "rate": 1.25, "slow": 0.5, "slow_time": 1.6,
				"vuln": 0.25,
				"blurb": "Chilled enemies take 25% more damage from every source.",
				"mastery": {
					"name": "Cryo Fracture", "cost": 280, "damage": 20.0, "range": 145.0, "rate": 1.35, "slow": 0.55, "slow_time": 1.7,
					"vuln": 0.4,
					"blurb": "Chilled enemies take 40% more damage from every source.",
				},
			},
		},
	},
	"sniper": {
		"name": "Railgun",
		"blurb": "Huge range and heavy slugs that ignore armor completely. Slow to recharge. Hits flyers.",
		"air": true,
		"tiers": [
			{"cost": 120, "damage": 55.0, "range": 290.0, "rate": 0.45, "pierce": true},
			{"cost": 150, "damage": 105.0, "range": 330.0, "rate": 0.5, "pierce": true},
		],
		"spec_order": ["deadeye", "lance"],
		"specs": {
			"deadeye": {
				"name": "Deadeye", "cost": 260, "damage": 170.0, "range": 420.0, "rate": 0.6, "pierce": true, "boss_mult": 2.0,
				"blurb": "Longest range in the arsenal, and double damage against bosses.",
				"mastery": {
					"name": "Executioner", "cost": 420, "damage": 250.0, "range": 460.0, "rate": 0.65, "pierce": true, "boss_mult": 2.5,
					"execute": 0.2,
					"blurb": "Destroys any non-boss target left under 20% health. 2.5x damage to bosses.",
				},
			},
			"lance": {
				"name": "Piercing Rail", "cost": 260, "damage": 130.0, "range": 380.0, "rate": 0.6, "pierce": true, "line": true,
				"blurb": "The slug punches through every enemy in a straight line.",
				"mastery": {
					"name": "Ion Lance", "cost": 420, "damage": 190.0, "range": 420.0, "rate": 0.7, "pierce": true, "line": true,
					"rail_width": 22.0,
					"blurb": "A wide ion channel: the line hits everything within 22 px of it.",
				},
			},
		},
	},
	"tesla": {
		"name": "Arc Coil",
		"blurb": "Lightning that arcs between nearby enemies, losing some power with each jump. Great against crowds. Hits flyers.",
		"air": true,
		"tiers": [
			{"cost": 130, "damage": 16.0, "range": 118.0, "rate": 0.9, "chains": 3, "chain_range": 90.0, "falloff": 0.8},
			{"cost": 160, "damage": 26.0, "range": 128.0, "rate": 1.0, "chains": 4, "chain_range": 95.0, "falloff": 0.8},
		],
		"spec_order": ["storm", "overload"],
		"specs": {
			"storm": {
				"name": "Storm Coil", "cost": 280, "damage": 36.0, "range": 145.0, "rate": 1.2, "chains": 9, "chain_range": 110.0, "falloff": 0.88,
				"blurb": "Arcs leap to 9 targets and lose less power per jump.",
				"mastery": {
					"name": "Tempest Coil", "cost": 420, "damage": 48.0, "range": 155.0, "rate": 1.3, "chains": 14, "chain_range": 120.0, "falloff": 0.9,
					"blurb": "Arcs leap to 14 targets, barely weakening between jumps.",
				},
			},
			"overload": {
				"name": "Overload", "cost": 280, "damage": 42.0, "range": 140.0, "rate": 1.1, "chains": 5, "chain_range": 100.0, "falloff": 0.8,
				"stun": 0.5,
				"blurb": "Every arc stuns its targets for 0.5 s (bosses 0.15 s).",
				"mastery": {
					"name": "Supercharger", "cost": 420, "damage": 58.0, "range": 150.0, "rate": 1.2, "chains": 6, "chain_range": 110.0, "falloff": 0.82,
					"stun": 0.8,
					"blurb": "Every arc stuns for 0.8 s (bosses 0.24 s) and hits harder.",
				},
			},
		},
	},
	"laser": {
		"name": "Laser Lance",
		"blurb": "A continuous beam that ignores armor and ramps up damage the longer it stays on one target. Hits flyers.",
		"air": true,
		"beam": true,
		"tiers": [
			{"cost": 140, "damage": 22.0, "range": 125.0, "ramp": 2.0, "ramp_time": 2.5},
			{"cost": 150, "damage": 36.0, "range": 135.0, "ramp": 2.5, "ramp_time": 2.5},
		],
		"spec_order": ["prism", "focus"],
		"specs": {
			"prism": {
				"name": "Prism Array", "cost": 300, "damage": 38.0, "range": 145.0, "ramp": 2.5, "ramp_time": 2.5, "beams": 3,
				"blurb": "Splits into three beams on different targets (extra beams at 60% power).",
				"mastery": {
					"name": "Refraction Grid", "cost": 450, "damage": 48.0, "range": 155.0, "ramp": 2.5, "ramp_time": 2.5, "beams": 5,
					"blurb": "Five beams on five targets (extra beams at 60% power).",
				},
			},
			"focus": {
				"name": "Focus Lens", "cost": 300, "damage": 50.0, "range": 150.0, "ramp": 4.0, "ramp_time": 3.0,
				"blurb": "Ramps up to 4x damage on a single target. Boss killer.",
				"mastery": {
					"name": "Singularity Lens", "cost": 450, "damage": 64.0, "range": 165.0, "ramp": 6.0, "ramp_time": 3.5,
					"blurb": "Ramps up to 6x damage on a single target. Nothing survives a long lock.",
				},
			},
		},
	},
	"missile": {
		"name": "Missile Battery",
		"blurb": "Long-range homing missiles with a small blast. Double damage to flyers.",
		"air": true,
		"tiers": [
			{"cost": 110, "damage": 18.0, "range": 190.0, "rate": 0.7, "missiles": 2, "splash": 28.0, "air_mult": 2.0, "proj_speed": 380.0},
			{"cost": 140, "damage": 26.0, "range": 200.0, "rate": 0.75, "missiles": 3, "splash": 30.0, "air_mult": 2.0, "proj_speed": 400.0},
		],
		"spec_order": ["swarm", "hellfire"],
		"specs": {
			"swarm": {
				"name": "Swarm Pods", "cost": 260, "damage": 24.0, "range": 210.0, "rate": 0.75, "missiles": 5, "splash": 30.0, "air_mult": 2.0, "proj_speed": 420.0,
				"blurb": "Five missiles per salvo, spread across targets.",
				"mastery": {
					"name": "Locust Swarm", "cost": 380, "damage": 26.0, "range": 225.0, "rate": 0.75, "missiles": 7, "splash": 32.0, "air_mult": 2.0, "proj_speed": 450.0,
					"blurb": "Seven missiles per salvo, spread across targets.",
				},
			},
			"hellfire": {
				"name": "Hellfire", "cost": 260, "damage": 65.0, "range": 215.0, "rate": 0.6, "missiles": 2, "splash": 50.0, "air_mult": 3.0, "proj_speed": 400.0,
				"blurb": "Heavy warheads with a big blast. Triple damage to flyers.",
				"mastery": {
					"name": "Doomsday Warheads", "cost": 380, "damage": 100.0, "range": 230.0, "rate": 0.6, "missiles": 2, "splash": 62.0, "air_mult": 3.0, "proj_speed": 420.0,
					"blurb": "Colossal warheads with a 62 px blast. Triple damage to flyers.",
				},
			},
		},
	},
	"amp": {
		"name": "Amplifier Pylon",
		"blurb": "Doesn't attack. Boosts the damage of every tower in its field. Pylons don't stack; the strongest boost applies.",
		"air": false,
		"support": true,
		"tiers": [
			{"cost": 100, "range": 100.0, "buff_dmg": 0.15},
			{"cost": 120, "range": 115.0, "buff_dmg": 0.25},
		],
		"spec_order": ["overclock", "array"],
		"specs": {
			"overclock": {
				"name": "Overclock Pylon", "cost": 220, "range": 125.0, "buff_dmg": 0.30, "buff_rate": 0.25,
				"blurb": "+30% damage and +25% attack speed to nearby towers.",
				"mastery": {
					"name": "Hypercore Pylon", "cost": 320, "range": 135.0, "buff_dmg": 0.40, "buff_rate": 0.35,
					"blurb": "+40% damage and +35% attack speed to nearby towers.",
				},
			},
			"array": {
				"name": "Targeting Array", "cost": 220, "range": 125.0, "buff_dmg": 0.25, "buff_range": 0.25,
				"blurb": "+25% damage and +25% range to nearby towers.",
				"mastery": {
					"name": "Command Array", "cost": 320, "range": 140.0, "buff_dmg": 0.35, "buff_range": 0.35,
					"blurb": "+35% damage and +35% range to nearby towers.",
				},
			},
		},
	},
	"flak": {
		"name": "Flak Battery",
		"blurb": "Anti-air cannon. Proximity shells burst among flyers and hit every flyer in the blast. Can't target ground units.",
		"air": true,
		"ground": false,
		"tiers": [
			{"cost": 80, "damage": 16.0, "range": 175.0, "rate": 1.4, "splash": 38.0, "proj_speed": 720.0},
			{"cost": 100, "damage": 28.0, "range": 190.0, "rate": 1.5, "splash": 42.0, "proj_speed": 760.0},
		],
		"spec_order": ["skyshred", "burst"],
		"specs": {
			"skyshred": {
				"name": "Sky Shredder", "cost": 190, "damage": 30.0, "range": 200.0, "rate": 3.2, "splash": 40.0, "proj_speed": 820.0,
				"blurb": "Twin autocannons: more than double the rate of fire.",
				"mastery": {
					"name": "Aerial Denial", "cost": 320, "damage": 36.0, "range": 215.0, "rate": 4.2, "splash": 46.0, "proj_speed": 860.0,
					"blurb": "Four autocannons saturate the sky with flak.",
				},
			},
			"burst": {
				"name": "Proximity Burst", "cost": 190, "damage": 80.0, "range": 210.0, "rate": 1.2, "splash": 70.0, "proj_speed": 760.0,
				"blurb": "Heavy shells with a huge airburst.",
				"mastery": {
					"name": "Thunderhead", "cost": 320, "damage": 130.0, "range": 230.0, "rate": 1.2, "splash": 85.0, "proj_speed": 780.0,
					"stun": 0.5,
					"blurb": "Massive airbursts that also stun flyers for 0.5 s.",
				},
			},
		},
	},
	"sensor": {
		"name": "Sensor Array",
		"blurb": "Support. Reveals cloaked Phantoms in its field so towers can target them, and marks every enemy in the field to take extra damage. Marks don't stack with other vulnerability; the strongest applies.",
		"air": true,
		"support": true,
		"sensor": true,
		"tiers": [
			{"cost": 75, "range": 130.0, "mark": 0.08},
			{"cost": 90, "range": 150.0, "mark": 0.12},
		],
		"spec_order": ["deepscan", "painter"],
		"specs": {
			"deepscan": {
				"name": "Deep Scan", "cost": 160, "range": 210.0, "mark": 0.14,
				"blurb": "Long-range scanning: the widest reveal field.",
				"mastery": {
					"name": "Omniscient Grid", "cost": 280, "range": 265.0, "mark": 0.18,
					"blurb": "Sees nearly half the sector at once.",
				},
			},
			"painter": {
				"name": "Target Painter", "cost": 160, "range": 160.0, "mark": 0.25,
				"blurb": "Laser designators: marked enemies take +25% damage.",
				"mastery": {
					"name": "Kill Beacon", "cost": 280, "range": 170.0, "mark": 0.35,
					"blurb": "Marked enemies take +35% damage from everything.",
				},
			},
		},
	},
	"gravity": {
		"name": "Graviton Projector",
		"blurb": "Gravity pulses shove every ground enemy in range back down the lane (bosses resist) and crush them for light damage. Can't affect flyers.",
		"air": false,
		"tiers": [
			{"cost": 150, "damage": 12.0, "range": 105.0, "rate": 0.25, "push": 40.0},
			{"cost": 160, "damage": 22.0, "range": 115.0, "rate": 0.28, "push": 52.0},
		],
		"spec_order": ["repulsor", "crush"],
		"specs": {
			"repulsor": {
				"name": "Repulsor", "cost": 290, "damage": 30.0, "range": 125.0, "rate": 0.3, "push": 85.0,
				"blurb": "Violent pulses hurl enemies far back down the lane.",
				"mastery": {
					"name": "Singularity Engine", "cost": 440, "damage": 45.0, "range": 135.0, "rate": 0.33, "push": 130.0,
					"blurb": "Throws whole columns of enemies back 130 px.",
				},
			},
			"crush": {
				"name": "Crush Field", "cost": 290, "damage": 75.0, "range": 120.0, "rate": 0.4, "push": 30.0,
				"stun": 0.6,
				"blurb": "Crushing gravity: heavy damage and a 0.6 s stun, but a short shove.",
				"mastery": {
					"name": "Event Horizon", "cost": 440, "damage": 120.0, "range": 130.0, "rate": 0.45, "push": 35.0,
					"stun": 1.0,
					"blurb": "Pins everything in the field for 1 s and crushes it.",
				},
			},
		},
	},
	"nullifier": {
		"name": "Nullifier",
		"blurb": "Pulses a dampening field that strips enemy barriers, and at tier 2 their crowd-control immunity. Hits flyers.",
		"air": true,
		"pulse": true,
		"tiers": [{}, {}],
	},
	"nova": {
		"name": "Nova Reactor",
		"blurb": "Releases a shockwave all around it that hits every enemy in range, air and ground.",
		"air": true,
		"pulse": true,
		"tiers": [{}, {}],
	},
	"drones": {
		"name": "Drone Bay",
		"size": 2,
		"blurb": "Launches combat drones that hunt enemies anywhere on the map.",
		"air": true,
		"drones": true,
		"tiers": [{}, {}],
	},
	"scrap": {
		"name": "Scrapyard",
		"size": 2,
		"blurb": "Economy. Doesn't attack: pays out credits every time a round is cleared, and its branches add kill credits or cheaper upgrades in its field.",
		"air": false,
		"ground": false,
		"support": true,
		"economy": true,
		"tiers": [{}, {}],
	},
}
