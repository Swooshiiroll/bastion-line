extends RefCounted
## Enemy balance table. `hp` and `speed` are round-1 values; both scale with the round number.
## `speed` is pixels per second, `armor` is flat damage removed per hit, `lives` is the cost of a leak.

const ORDER := ["grunt", "runner", "brute", "swarmling", "bat", "shaman", "phantom", "aegis", "hydra", "jammer",
	"locust", "rally", "burrower", "gunship", "stalker", "mender", "bulwark", "rampart",
	"needle", "fury", "shrike", "titan", "siphon", "blackout", "capacitor", "shifter", "wraith", "masquerade", "decoy", "mirage",
	"juggernaut", "warlord", "leviathan", "colossus"]

## What share of a slow or pull each role resists (the Magneto and Tractor towers, design/tower_roster.md). Every enemy has a
## `role`: swarm, rusher, evader, support, disruptor, special, tank or boss, and a `tier`: 1 to 4 in its role, 0 for special
## and boss (the role and tier grid in design/enemy_roster.md, issue #68).
const ROLE_RESIST := {"swarm": 0.0, "rusher": 0.10, "evader": 0.20, "support": 0.30, "disruptor": 0.30, "special": 0.30, "tank": 0.50, "boss": 0.75}

const ENEMIES := {
	"grunt": {
		"role": "swarm", "tier": 3,
		"name": "Drone", "hp": 70.0, "speed": 55.0, "armor": 0.0, "bounty": 4, "lives": 1, "radius": 11.0,
		"blurb": "Basic combat drone.",
	},
	"runner": {
		"role": "rusher", "tier": 1,
		"name": "Skitter", "hp": 45.0, "speed": 105.0, "armor": 0.0, "bounty": 4, "lives": 1, "radius": 10.0,
		"blurb": "Fast, fragile crawler bot.",
	},
	"brute": {
		"role": "tank", "tier": 1,
		"name": "Siege Mech", "hp": 265.0, "speed": 40.0, "armor": 6.0, "bounty": 10, "lives": 3, "radius": 14.0,
		"blurb": "Armor plating: every hit loses 6 damage. Bring big hitters, shredders or beams.",
	},
	"swarmling": {
		"role": "swarm", "tier": 1,
		"name": "Nanite", "hp": 22.0, "speed": 78.0, "armor": 0.0, "bounty": 2, "lives": 1, "radius": 6.0,
		"blurb": "Tiny self-replicating machines that come in swarms.",
	},
	"bat": {
		"role": "rusher", "tier": 3,
		"name": "Strike Drone", "hp": 100.0, "speed": 82.0, "armor": 0.0, "bounty": 5, "lives": 2, "radius": 9.0, "flying": true,
		"blurb": "Quad-rotor strike drone. Flies straight at the core, ignoring the lane. Mortars can't hit it.",
	},
	"shaman": {
		"role": "support", "tier": 1,
		"name": "Repair Bot", "hp": 125.0, "speed": 50.0, "armor": 1.0, "bounty": 11, "lives": 1, "radius": 11.0,
		"heal_pct": 0.08, "heal_radius": 90.0, "heal_interval": 2.0,
		"blurb": "Repairs nearby enemies (not bosses). Kill it first.",
	},
	"phantom": {
		"role": "special", "tier": 0,
		"name": "Phantom", "hp": 85.0, "speed": 72.0, "armor": 0.0, "bounty": 7, "lives": 1, "radius": 10.0, "flying": true,
		"cloaked": true, "track": true,
		"blurb": "Cloaked flying infiltrator that follows the track. Towers that hit air can only target it inside a Sensor Array field, or for a moment after it takes damage from a blast, field or arc.",
	},
	"aegis": {
		"role": "special", "tier": 0,
		"name": "Aegis Walker", "hp": 150.0, "speed": 44.0, "armor": 2.0, "bounty": 12, "lives": 2, "radius": 13.0,
		"shield": 130.0, "shield_regen": 0.25, "shield_delay": 2.5,
		"blurb": "Energy barrier absorbs damage before the hull (armor doesn't apply) and recharges when left alone. Arc Coils deal double damage to barriers.",
	},
	"hydra": {
		"role": "special", "tier": 0,
		"name": "Hydra Frame", "hp": 190.0, "speed": 46.0, "armor": 3.0, "bounty": 8, "lives": 2, "radius": 14.0,
		"split_type": "runner", "split_count": 3,
		"blurb": "Modular walker. Splits into three Skitters when destroyed.",
	},
	"jammer": {
		"role": "disruptor", "tier": 1,
		"name": "Jammer", "hp": 150.0, "speed": 50.0, "armor": 1.0, "bounty": 12, "lives": 1, "radius": 12.0,
		"emp_radius": 95.0, "emp_duration": 2.0, "emp_interval": 5.0,
		"blurb": "EMP bursts every 5 s knock nearby towers offline for 2 s. Kill it from range.",
	},
	"locust": {
		"role": "swarm", "tier": 2,
		"name": "Locust", "hp": 15.0, "speed": 115.0, "armor": 0.0, "bounty": 1, "lives": 1, "radius": 5.0, "flying": true,
		"blurb": "Tiny winged micro-drones that fly straight at the core in dense swarms. Flak shreds them.",
	},
	"gunship": {
		"role": "tank", "tier": 3,
		"name": "Gunship", "hp": 600.0, "speed": 42.0, "armor": 5.0, "bounty": 18, "lives": 4, "radius": 16.0, "flying": true,
		"blurb": "Armored heavy flyer: every hit loses 5 damage. Railguns, lasers and Hellfire missiles punch through.",
	},
	"burrower": {
		"role": "evader", "tier": 2,
		"name": "Burrower", "hp": 160.0, "speed": 62.0, "armor": 2.0, "bounty": 9, "lives": 2, "radius": 11.0,
		"burrow_interval": 5.0, "burrow_time": 2.5,
		"blurb": "Tunnels under the lane for 2.5 s every 5 s. While burrowed it can't be targeted or hurt, and hazards don't touch it.",
	},
	"stalker": {
		"role": "evader", "tier": 1,
		"name": "Blink Stalker", "hp": 110.0, "speed": 70.0, "armor": 1.0, "bounty": 8, "lives": 2, "radius": 10.0,
		"blink_interval": 4.0, "blink_distance": 80.0,
		"blurb": "Teleports 80 px down the lane every 4 s. Slowing or stunning it resets the charge.",
	},
	"mender": {
		"role": "support", "tier": 4,
		"name": "Mender Hulk", "hp": 380.0, "speed": 38.0, "armor": 3.0, "bounty": 14, "lives": 3, "radius": 15.0,
		"regen_pct": 0.04, "regen_delay": 1.5,
		"blurb": "Self-repairing hulk: regenerates 4% of its health per second after 1.5 s without taking damage. Keep hitting it.",
	},
	"rally": {
		"role": "support", "tier": 2,
		"name": "Rally Beacon", "hp": 170.0, "speed": 48.0, "armor": 2.0, "bounty": 12, "lives": 2, "radius": 12.0,
		"aura_radius": 100.0, "aura_haste": 0.25,
		"blurb": "Broadcasts an overdrive signal: other non-boss enemies within 100 px move 25% faster. Kill it first.",
	},
	"bulwark": {
		"role": "support", "tier": 3,
		"name": "Bulwark", "hp": 200.0, "speed": 42.0, "armor": 3.0, "bounty": 13, "lives": 2, "radius": 13.0,
		"grant_interval": 6.0, "grant_radius": 100.0, "grant_pct": 0.25,
		"blurb": "Every 6 s projects a barrier worth 25% of their health onto enemies within 100 px (not itself). Arc Coils hit barriers twice as hard.",
	},
	"rampart": {
		"role": "tank", "tier": 2,
		"name": "Rampart", "hp": 520.0, "speed": 34.0, "armor": 8.0, "bounty": 18, "lives": 4, "radius": 16.0,
		"cc_immune": true,
		"blurb": "Siege fortress on treads. Immune to slows, stuns and shoves, with 8 armor. Beams and armor-piercing shots work best.",
	},
	"needle": {
		"role": "rusher", "tier": 2,
		"name": "Needle", "hp": 30.0, "speed": 140.0, "armor": 0.0, "bounty": 5, "lives": 2, "radius": 8.0,
		"pack": 2, "pack_gap": 0.25,
		"blurb": "Hair-thin sprinter that always arrives in pairs. Single-target towers can't keep up. Slows, splash and rapid fire can.",
	},
	"fury": {
		"role": "rusher", "tier": 4,
		"name": "Fury Drone", "hp": 85.0, "speed": 125.0, "armor": 1.0, "bounty": 9, "lives": 2, "radius": 10.0,
		"adrenaline": 0.3, "adrenaline_at": 0.5,
		"blurb": "Hunter drone that overclocks when hurt: below half health it runs 30% faster. Kill it in one burst, and watch for Rally Beacons, because the boosts multiply.",
	},
	"shrike": {
		"role": "swarm", "tier": 4,
		"name": "Shrike", "hp": 55.0, "speed": 90.0, "armor": 0.0, "bounty": 3, "lives": 1, "radius": 7.0, "flying": true,
		"pack": 5, "pack_gap": 0.15,
		"blurb": "Winged blade clusters, five at a time, flying straight at the core. Mortars can't hit them. Flak and chain towers shred them.",
	},
	"titan": {
		"role": "tank", "tier": 4,
		"name": "Titan", "hp": 700.0, "speed": 30.0, "armor": 9.0, "bounty": 24, "lives": 4, "radius": 18.0,
		"slow_resist": 0.5, "shed_at": 0.5, "shed_armor": 5.0, "shed_speed": 1.2,
		"blurb": "Walking fortress with 9 armor and half resistance to slows. At half health its plates shed: armor drops to 5, but it speeds up 20%. Bring armor shredders and big hitters.",
	},
	"siphon": {
		"role": "disruptor", "tier": 2,
		"name": "Siphon", "hp": 190.0, "speed": 52.0, "armor": 2.0, "bounty": 12, "lives": 2, "radius": 12.0,
		"siphon_radius": 100.0, "siphon_rate": 0.2, "siphon_range": 0.15,
		"blurb": "Drains nearby towers: inside its 100 px aura they fire 20% slower and reach 15% less far. Two Siphons don't stack. Kill it from range.",
	},
	"blackout": {
		"role": "disruptor", "tier": 3,
		"name": "Blackout Rig", "hp": 260.0, "speed": 48.0, "armor": 3.0, "bounty": 15, "lives": 3, "radius": 14.0,
		"emp_radius": 130.0, "emp_duration": 2.5, "emp_interval": 4.0,
		"blurb": "A hulking Jammer. Its EMP reaches 130 px and knocks towers offline for 2.5 s every 4 s. Kill it from range.",
	},
	"capacitor": {
		"role": "disruptor", "tier": 4,
		"name": "Capacitor", "hp": 420.0, "speed": 44.0, "armor": 4.0, "bounty": 20, "lives": 3, "radius": 15.0,
		"emp_radius": 160.0, "emp_duration": 3.0, "emp_interval": 8.0, "emp_charge": 2.0,
		"blurb": "Charges for 2 s, then blacks out every tower within 160 px for 3 s, every 8 s. Stun or silence it during the charge (or hit it with Overload Circuits) to cancel the pulse.",
	},
	"shifter": {
		"role": "evader", "tier": 3,
		"name": "Shifter", "hp": 200.0, "speed": 68.0, "armor": 2.0, "bounty": 13, "lives": 3, "radius": 11.0,
		"blink_interval": 5.0, "blink_distance": 60.0, "wake_radius": 80.0, "wake_haste": 0.2, "wake_time": 2.0,
		"blurb": "Blinks 60 px every 5 s and speeds up nearby enemies by 20% for 2 s where it lands. Slow or stun it to reset its charge.",
	},
	"wraith": {
		"role": "evader", "tier": 4,
		"name": "Wraith", "hp": 260.0, "speed": 74.0, "armor": 2.0, "bounty": 18, "lives": 3, "radius": 11.0, "flying": true,
		"cloaked": true, "energy_only": true,
		"blurb": "Cloaked flyer immune to physical damage. Only energy hurts it: beams, chains, fields, burning and Tesla arcs. Bring something that reveals it.",
	},
	"masquerade": {
		"role": "special", "tier": 0,
		"name": "Masquerade", "hp": 320.0, "speed": 60.0, "armor": 3.0, "bounty": 14, "lives": 3, "radius": 11.0,
		"disguise": "grunt", "reveal_at": 0.5, "flee_speed": 80.0, "flee_time": 3.0,
		"blurb": "Looks, moves and ranks like a Drone, so Strongest targeting ignores it; watch for the purple eye. Below half health it drops the disguise and flees. Use First or Closest targeting to catch it.",
	},
	"decoy": {
		"role": "special", "tier": 0,
		"name": "Decoy Beacon", "hp": 400.0, "speed": 36.0, "armor": 6.0, "bounty": 10, "lives": 3, "radius": 14.0,
		"fake_rank": true, "shown_role": "tank",
		"blurb": "Ranks as a heavy unit so Strongest towers aim at it, but it does nothing else. Switch tower targeting, or kill it, to stop wasting fire.",
	},
	"mirage": {
		"role": "special", "tier": 0,
		"name": "Mirage", "hp": 140.0, "speed": 55.0, "armor": 1.0, "bounty": 12, "lives": 1, "radius": 11.0,
		"holo_interval": 6.0, "holo_count": 2,
		"blurb": "Projects two translucent copies every 6 s that soak shots and walk to the core. A single hit kills one, and they vanish with the Mirage. Splash and chain towers clear them.",
	},
	"juggernaut": {
		"role": "boss", "tier": 0,
		"name": "Dreadnought", "hp": 800.0, "speed": 32.0, "armor": 5.0, "bounty": 120, "lives": 20, "radius": 22.0,
		"boss": true, "slow_resist": 0.5,
		"blurb": "Boss of round 20. Heavily armored assault tank, half-immune to slows. A leak costs 20 shields.",
	},
	"warlord": {
		"role": "boss", "tier": 0,
		"name": "Overmind", "hp": 1900.0, "speed": 20.0, "armor": 10.0, "bounty": 500, "lives": 40, "radius": 26.0,
		"boss": true, "slow_resist": 0.6,
		"spawn_type": "swarmling", "spawn_count": 3, "spawn_interval": 5.0,
		"blurb": "Boss of round 40. A hive intelligence that spawns nanites as it advances. A leak costs 40 shields.",
	},
	"leviathan": {
		"role": "boss", "tier": 0,
		"name": "Leviathan", "hp": 2600.0, "speed": 24.0, "armor": 6.0, "bounty": 400, "lives": 60, "radius": 30.0, "flying": true,
		"boss": true, "slow_resist": 0.5,
		"spawn_type": "locust", "spawn_count": 6, "spawn_interval": 6.0,
		"blurb": "Boss of round 60. A colossal flying carrier that launches Locust swarms every 6 s. Only anti-air can touch it. A leak costs 60 shields.",
	},
	"colossus": {
		"role": "boss", "tier": 0,
		"name": "Colossus", "hp": 4200.0, "speed": 18.0, "armor": 14.0, "bounty": 700, "lives": 80, "radius": 32.0,
		"boss": true, "slow_resist": 0.6, "stun_immune": true,
		"phases": [0.66, 0.33], "phase_armor": 5.0, "phase_speed": 1.2, "phase_spawn": "brute", "phase_spawn_count": 2,
		"blurb": "Boss of round 80. A walking fortress that can't be stunned. At 66% and 33% health it sheds armor plates, speeds up and drops two Siege Mechs. A leak costs 80 shields.",
	},
}

## Every boss ranks above every non-boss, whatever the scores.
const BOSS_RANK := 100000.0
## Leak cost bands for non-bosses (owner, 2026-10-20): strength below 50 costs 1 shield, below 150 costs 2, below 400 costs 3, else 4.
## A boss costs its introduction round; an elite one shield more.
const LEAK_BANDS := [50.0, 150.0, 400.0]


## The shields a non-boss of strength `str_score` costs when it leaks.
static func leak_band(str_score: float) -> int:
	var n := 1
	for b in LEAK_BANDS:
		if str_score >= float(b):
			n += 1
	return n


## The strength score (design/enemy_roster.md): spd² × (max(1, armor) × hp), with spd = speed / 100, from round-1 stats.
static func strength(type: String) -> float:
	return strength_of(ENEMIES[type])


## The strength score of enemy data `d` (an elite's, with its modifiers merged in, scores its changed speed and armor).
static func strength_of(d: Dictionary) -> float:
	var spd := float(d.speed) / 100.0
	return spd * spd * maxf(1.0, float(d.get("armor", 0.0))) * float(d.hp)


## Its strength rank score: the strength score, with every boss above every non-boss.
static func rank_score(type: String) -> float:
	return rank_of(ENEMIES[type])


## Its role and tier for labels: "Swarm T3", "Special", "Boss".
static func role_label(d: Dictionary) -> String:
	var r := str(d.get("role", "")).capitalize()
	return r if int(d.get("tier", 0)) <= 0 else "%s T%d" % [r, int(d.tier)]


static func rank_of(d: Dictionary) -> float:
	return strength_of(d) + (BOSS_RANK if bool(d.get("boss", false)) else 0.0)
