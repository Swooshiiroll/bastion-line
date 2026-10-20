# Bastion Line Upgrade Trees: tower rework

The 20 reworked towers' upgrade trees, built from `design/tower_roster.md` (issue #55) for the editable trees page.
Not game data: today's trees stay in `design/upgrade_trees.md` until the rework is implemented. Edits made on the page
come back here with `tools/design_pull.mjs`; carry them into `design/tower_roster.md` too.

## Rules

- Each tower has three paths of four upgrades and a mastery. Climb up to two paths, up to two upgrades each; the 3rd upgrade on either makes it the primary, which goes on to its mastery, and the other is capped at 2 with its full effects. The third path is locked. Masteries need the tower's Mastery research.
- The CAS Gunship is the exception: each path is one gun (its step 1 unlocks it; the light gun is built in), and all three paths are uncapped to their masteries.
- The Retrofit is an optional upgrade off to the side: the player picks one of three options when buying it, and the choice is locked. The Drone Bay has a single Retrofit.
- Prices come from the value formula in `design/towers.md` (Pricing), rounded to 5s and 0s, with the owner's overrides. Every number is a first pass for the balance probe.

## Gun Turret
id: gun_turret · class: Assault · weapon: Ballistic · build: 75 cr · status: new · branches: Power (armour-piercing), Range/Visibility (precision), Multi-Target
A basic rotating machine gun turret. "It's a machine gun, Private!"

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Gun Turret | 75 |  | 75 credits; 16 damage, 130 range, 1.2 shots/s (about 19 damage per second, close to the Pulse Turret's 18, in fewer, harder hits). Air and ground. | new |
| 2 | r1 | Water-Cooled Barrel | 40 |  | Fire rate 1.2 to 1.5/s. | new |
| 2 | r2 | Shock Rounds | 5 |  | Every hit has a 5% chance to stun its target for 0.3 s. | new |
| 2 | r3 | Incendiary Rounds | 25 |  | Hits set the target burning for 3 damage per second for 2 s. Proposed: a new hit refreshes the burn rather than stacking it, so it adds 3 damage per second to the current target. | new |
| 3 | a | Heavier Rounds | 55 |  | +6 damage | new |
| 4 | a | Hardened Tips | 40 |  | Its hits ignore 2 points of armour | new |
| 5 | a | AP Rounds | 405 |  | Ignores 50% of armour; +6 damage | new |
| 6 | a | Tungsten Core | 1085 |  | Ignores 75% of armour; +8 damage | new |
| M | a | Sabot Rounds | 2475 |  | Ignores armour fully; 44 damage per hit | new |
| 3 | b | Long Barrel | 25 |  | +20 range | new |
| 4 | b | Tracer Rounds | 60 |  | +10 range; 10% chance of a critical hit (double damage); visible tracer lines | new |
| 5 | b | Rifled Barrels | 170 |  | +25 range; crit chance 15% | new |
| 6 | b | Rangefinder | 305 |  | +20 range; crit chance 20% | new |
| M | b | Targeting Computer | 980 |  | 230 range in all (+25); crit chance 30% | new |
| 3 | c | Swivel Mount | 15 |  | Switches to a new target instantly after a kill, and doesn't fire at enemies already about to die (no wasted rounds on swarms and holograms) | new |
| 4 | c | Side Gun | 165 |  | A small side gun fires at a second target at 50% damage | new |
| 5 | c | Twin Mount | 330 |  | 2 targets at full damage | new |
| 6 | c | Belt Feed | 660 |  | +0.3 shots/s on every barrel | new |
| M | c | Triple Mount | 3300 |  | 3 targets; the extra barrels go for the weakest enemies in range (swarms, holograms) | new |

## Mortar Tower
id: mortar_tower · class: Assault · weapon: Explosive · build: 150 cr · status: new · branches: Power/Penetration, Speed/Range (more tubes, more reach), Blast Radius/Multi-Target (cluster shells)
Lobs high-explosive shells at nearby enemies. "Toob."

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Mortar Tower | 150 |  | 150 credits; 30 damage per shell, a 60 px blast, 110 range, 0.6 shells/s; ground only. Its value matches the Gun Turret's credits per point: the Mortar does a little less single-target damage but hits a whole pack. | new |
| 2 | r1 | Field Kit | 120 |  | A reinforced baseplate (+4 damage), a ranging sight (+10 range) and an ammo rack (+0.05 shells/s, +5 px blast). | new |
| 2 | r2 | Bunker Sight | 15 |  | It can target burrowed enemies inside Radar Tower range, at half damage (the Bunker Buster mastery does it at full). | new |
| 2 | r3 | Smoke Shells | 15 |  | Every 4th shell leaves a smoke cloud for 3 s that slows enemies inside it by 15%. | new |
| 3 | a | HE Charge | 80 |  | +8 damage | new |
| 4 | a | Shaped Charge | 95 |  | Shells ignore 25% of armour | new |
| 5 | a | AP Shells | 685 |  | Ignore 50% of armour; +10 damage | new |
| 6 | a | Delayed Fuse | 1350 |  | Ignore 75% of armour; +8 damage | new |
| M | a | Bunker Buster | 3140 |  | 64 damage; ignores 75% of armour; shells dig in and hit burrowed enemies inside Radar Tower range | new |
| 3 | b | Quick Reload | 50 |  | 0.6 to 0.7 shells/s | new |
| 4 | b | Extended Tube | 125 |  | +20 range (130) | new |
| 5 | b | Twin Tubes | 1170 |  | A second tube firing in succession: 1.2 shells/s | new |
| 6 | b | Long Tubes | 1405 |  | +20 range (150); 1.3 shells/s | new |
| M | b | Barrage Battery | 6165 |  | Three tubes firing in succession: 1.7 shells/s, 165 range | new |
| 3 | c | Bigger Charge | 30 |  | Blast 60 to 70 px | new |
| 4 | c | Wide Burst | 60 |  | Blast 80 px | new |
| 5 | c | Cluster Shells | 1110 |  | Each shell also scatters 4 bomblets around the impact (10 damage, 30 px each) | new |
| 6 | c | Dense Cluster | 1230 |  | 6 bomblets; blast 85 px | new |
| M | c | Carpet Shells | 5000 |  | 8 bomblets of 12 damage, 35 px each, spread wider; blast 90 px | new |

## Laser Tower
id: laser_tower · class: Assault · weapon: Energy · build: 250 cr · status: new · branches: Power (faster, higher ramp), Multi-Target (prism split), Range/Targeting (long-range lance, shortened by the owner)
A High-Energy Laser Emitter affixed to a rotating turret. "It does more than just blind the enemy, that's for sure."

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Laser Tower | 250 |  | 250 credits; 25 damage per second, ramping up to ×3 over 3 s on the same target; 150 range; air and ground. Armour melt: the locked target loses 1 armour per second, down to 0. The armour stays gone, so other towers benefit. Switching targets resets the ramp but not the melted armour. | new |
| 2 | r1 | Capacitor Bank | 160 |  | +8 damage per second (25 to 33). | new |
| 2 | r2 | Heat Sinks | 60 |  | Ramp ceiling ×3 to ×3.5. | new |
| 2 | r3 | Ramp Memory | 55 |  | Switching targets keeps half the ramp instead of resetting it. | new |
| 3 | a | Hotter Emitter | 60 |  | Ramp ceiling ×3.5 | new |
| 4 | a | Quick Focus | 60 |  | Ramp time 3 to 2.2 s | new |
| 5 | a | Overdrive | 815 |  | Ramp ceiling ×5 | new |
| 6 | a | Thermal Lock | 1425 |  | Ceiling ×6; ramp time 1.8 s | new |
| M | a | Annihilator | 5535 |  | Ceiling ×8 in 1.5 s: the boss killer | new |
| 3 | b | Beam Splitter | 200 |  | A second beam on another target at 40% power | new |
| 4 | b | Tuned Splitter | 200 |  | The second beam at 60% | new |
| 5 | b | Prism | 1190 |  | 3 beams (extras at 60%) | new |
| 6 | b | Clear Prism | 1190 |  | Extra beams at 75% | new |
| M | b | Prism Array | 5950 |  | 4 beams (extras at 75%); each beam ramps on its own target | new |
| 3 | c | Extended Optics | 50 |  | +15 range (165) | new |
| 4 | c | Collimator | 100 |  | +15 range (180) | new |
| 5 | c | Lance | 395 |  | +30 range (210) | new |
| 6 | c | Long Lance | 795 |  | +30 range (240) | new |
| M | c | Deep Lance | 2115 |  | 280 range: still a mid-range tower, but with a long reach | new |

## Rocket Salvo
id: rocket_salvo · class: Assault · weapon: Explosive · build: 200 cr · status: new · branches: Power (heavier warheads), Range/Target Acquisition (homing), Reload/Payload (more rockets, faster reloads)
Launches a volley of rockets at oncoming enemies. "Instead of shooting bullets, it shoots very angry telephone poles that hate absolutely everything."

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Rocket Salvo | 200 |  | 200 credits; a salvo of 3 rockets every 2.5 s, each on a different enemy, 19 damage with a 25 px blast; 180 range; air and ground. Without homing, rockets fly at where the target was, so very fast or blinking enemies can dodge them. | new |
| 2 | r1 | Proximity Fuses | 40 |  | Rockets burst beside flyers for +40% damage against air. Replaces Guidance Fins, which partly overlapped Range step 2's homing. | new |
| 2 | r2 | Smoke Trails | 20 |  | Rockets leave smoke along their path that slows enemies inside it by 10% for 2 s. Replaces the Autoloader, which duplicated the Payload path's reloads (Quick Loader, Auto-Loader). | new |
| 2 | r3 | Incendiary Warheads | 125 |  | Blasts leave burning ground, 3 damage per second for 2 s. Replaces the Long Booster, which duplicated Range step 1 (Booster Stage). | new |
| 3 | a | HE Warheads | 105 |  | +5 damage per rocket (24) | new |
| 4 | a | Wider Burst | 155 |  | Blast 25 to 35 px | new |
| 5 | a | Heavy Warheads | 985 |  | 32 damage, 40 px blast | new |
| 6 | a | Dense Payload | 1245 |  | 38 damage | new |
| M | a | Thermobaric Rockets | 5710 |  | 46 damage, 50 px blast | new |
| 3 | b | Booster Stage | 45 |  | +20 range (200) | new |
| 4 | b | Seeker Heads | 135 |  | Homing: rockets curve onto their target | new |
| 5 | b | Smart Seekers | 510 |  | Rockets re-target if their target dies; +30 range (230) | new |
| 6 | b | Long Burn | 670 |  | +30 range (260) | new |
| M | b | Hunter Seekers | 2315 |  | 300 range; seekers never miss, catching fast and blinking enemies | new |
| 3 | c | Extra Tube | 135 |  | 4 rockets per salvo | new |
| 4 | c | Quick Loader | 265 |  | A salvo every 2 s | new |
| 5 | c | Six-Pack | 1335 |  | 6 rockets per salvo | new |
| 6 | c | Auto-Loader | 1605 |  | A salvo every 1.7 s | new |
| M | c | Ripple Salvo | 6415 |  | 8 rockets per salvo, rippling out one after another | new |

## Anti-Aircraft Turret
id: anti_aircraft_turret · class: Assault · weapon: Ballistic · build: 150 cr · status: new · branches: Range (area denial), Power/Blast Radius (flak shells), Speed (barrels and rate of fire)
A fully automatic anti-aircraft gun. "We don't need a gun, or a nug!"

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Anti-Aircraft Turret | 150 |  | 150 credits; 25 damage per round, 2.5 rounds/s, 160 range; flyers only. That's about 62 damage per second against air: it shreds Locusts and Strike Drones and wears down Gunships. | new |
| 2 | r1 | Fire-Control Radar | 45 |  | +15 range and steadier aim. | new |
| 2 | r2 | Ammo Drum | 30 |  | +10% fire rate (2.75 rounds/s). | new |
| 2 | r3 | Armoured Mount | 50 |  | +4 damage (29). | new |
| 3 | a | Long Barrel | 40 |  | +20 range (180) | new |
| 4 | a | Higher Mount | 75 |  | +20 range (200) | new |
| 5 | a | Sky Watch | 300 |  | +40 range (240) | new |
| 6 | a | High-Velocity Rounds | 600 |  | +40 range (280) | new |
| M | a | Sky Wall | 1500 |  | 330 range: covers a big circle of sky | new |
| 3 | b | Heavier Rounds | 70 |  | +6 damage (31) | new |
| 4 | b | Flak Rounds | 375 |  | Rounds burst near their target: a 20 px airburst on every flyer nearby | new |
| 5 | b | Flak Shells | 795 |  | 36 damage; 30 px airburst | new |
| 6 | b | Wide Burst | 865 |  | 40 px airburst | new |
| M | b | Flak Curtain | 4325 |  | 42 damage; 50 px airburst: whole flocks of Locusts and Shrikes go down together | new |
| 3 | c | Quick Cycle | 35 |  | 2.8 rounds/s | new |
| 4 | c | Fast Traverse | 95 |  | 3.2 rounds/s; turns faster onto new flyers | new |
| 5 | c | Twin Barrels | 625 |  | 4.5 rounds/s | new |
| 6 | c | Belt Feed | 675 |  | 5.2 rounds/s | new |
| M | c | Quad Mount | 3460 |  | 7 rounds/s from four barrels: a wall of fire | new |

## Artillery Cannon
id: artillery_cannon · class: Assault · weapon: Explosive · build: 300 cr · status: new · branches: Power (damage and blast, then armour piercing), Speed (faster reload), Special Effects (shell types)
A large-bore cannon that fires high-explosive shells very long distances. "It's not DiGiorno..."

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Artillery Cannon | 300 |  | 300 credits; a heavy shell every 4 s onto the aimed spot, 75 damage, a 70 px blast, 1.5 s flight time; ground only. A new cannon aims at the track point nearest to itself until you set it. | new |
| 2 | r1 | Shell Magazine | 120 |  | Every third shell is a heavy round for +50% damage (about +17% on average), with no change to reload time. | new |
| 2 | r2 | Stabilised Mount | 120 |  | Shells land within 15 px of the aimed spot instead of scattering up to 30 px, so the blast hits what you aimed at. | new |
| 2 | r3 | Wide Charge | 80 |  | +15 px blast (85). | new |
| 3 | a | Heavy Shells | 120 |  | +15 damage (90) | new |
| 4 | a | Wide Bursting Charge | 200 |  | Blast 70 to 85 px | new |
| 5 | a | HE Shells | 730 |  | 110 damage | new |
| 6 | a | Penetrator Shells | 2930 |  | 120 damage; ignores 50% of armour | new |
| M | a | Siege Shells | 7355 |  | 140 damage, 90 px blast, ignores 75% of armour | new |
| 3 | b | Drilled Crew | 120 |  | A shell every 3.3 s | new |
| 4 | b | Quick Breech | 240 |  | Every 2.9 s | new |
| 5 | b | Autoloader | 1450 |  | Every 2 s | new |
| 6 | b | Rapid Breech | 1935 |  | Every 1.7 s | new |
| M | b | Rolling Barrage | 3865 |  | Fires in 3-shell barrages that walk across the aimed spot: an average of one shell every 1.4 s | new |
| 3 | c | Incendiary Shells | 365 |  | Unlocks incendiary: the blast leaves burning ground (15 damage/s for 3 s) | new |
| 4 | c | Shrapnel Shells | 195 |  | Unlocks shrapnel: a 40 px wider blast at 70% damage | new |
| 5 | c | Concussion Shells | 1085 |  | Unlocks concussion: everything in the blast is stunned for 0.5 s (bosses 0.15 s) | new |
| 6 | c | Improved Payloads | 3505 |  | Every shell type stronger: burn 22/s, shrapnel at 85%, stun 0.7 s | new |
| M | c | Combined Payload | 5725 |  | A fourth type that does all three at once | new |

## Railgun
id: railgun · class: Assault · weapon: Ballistic · build: 500 cr · status: new · branches: Power (boss slayer and overcharge), Range/Speed (mostly recharge), Special Effects (shatter, penetration, ion trail)
A large cannon with magnetically polarized rails that launch a large projectile extremely far, extremely fast. "Known to cause cancer in the state of California."

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Railgun | 500 |  | 500 credits; a 90-damage slug every 2.5 s, 380 range; air and ground; armour applies (a Titan's 9 armour costs it only 10%). Penetration: the slug pierces every enemy on its line, losing 40% of its damage with each enemy it passes through (90, 54, 32...). | new |
| 2 | r1 | Capacitor Coils | 140 |  | Recharge 2.5 to 2.2 s. | new |
| 2 | r2 | Longer Rails | 265 |  | +15 damage (105) and +30 range (410). | new |
| 2 | r3 | Penetrator Tips | 65 |  | Falloff per enemy 40% to 30%. | new |
| 3 | a | Dense Slugs | 345 |  | +30 damage (120) | new |
| 4 | a | Boss Rounds | 275 |  | ×1.5 damage to bosses | new |
| 5 | a | Overcharge | 2260 |  | It charges each shot longer: 200 damage, a 3 s recharge | new |
| 6 | a | Kill Charge | 5125 |  | 240 damage; ×2 to bosses | new |
| M | a | Kingslayer | 6465 |  | 280 damage per charged shot (3.3 s); ×2.5 to bosses | new |
| 3 | b | Fast Capacitors | 140 |  | Recharge 2.2 s | new |
| 4 | b | Extended Rails | 245 |  | +40 range (420) | new |
| 5 | b | Rapid Capacitors | 1930 |  | Recharge 1.6 s | new |
| 6 | b | Supercapacitors | 2610 |  | Recharge 1.35 s | new |
| M | b | Twin Rails | 5000 |  | Two rails firing in turn: a slug every 1.2 s, twice the stock rate | new |
| 3 | c | Shatter Rounds | 60 |  | Each hit strips 2 armour permanently, so every tower benefits | new |
| 4 | c | Penetrator Core | 260 |  | Falloff per enemy 40% to 25% | new |
| 5 | c | Ionised Trail | 1535 |  | The line burns for 2 s: 30 energy damage/s to every enemy on it, targeted or not (cloaked ones too) | new |
| 6 | c | Hot Rail | 3685 |  | Shatter 4 armour; trail 45/s; falloff 15% | new |
| M | c | Ion Cannon | 6920 |  | Shatter 6; trail 50/s; no falloff: full damage to everything on the line | new |

## Tesla Tower
id: tesla_tower · class: Assault · weapon: Energy · build: 250 cr · status: new · branches: Power/Damage (raw voltage, stun, overload), Range/Chaining (storm field), Speed (faster discharges)
A large metal disk mounted atop of a large tower that generates high-voltage electrical arcs that damage incoming enemies. "It was built in a cave with a box of scraps."

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Tesla Tower | 250 |  | 250 credits; an arc every 1.25 s (0.8/s), 32 damage, jumping to 3 more enemies within 70 px and losing 15% per jump; 140 range; air and ground. It's Energy, so it ignores armour like other energy damage (to confirm), and it's a Wraith counter once the Wraith is revealed. | new |
| 2 | r1 | Bigger Disk | 120 |  | +4 damage (36), +15 range (155). | new |
| 2 | r2 | Grounding Rods | 65 |  | +1 jump (4). | new |
| 2 | r3 | Insulated Coils | 70 |  | An arc every 1.1 s. | new |
| 3 | a | High Voltage | 125 |  | +8 damage (40) | new |
| 4 | a | Overload Circuits | 100 |  | EMP-enemy overload: ×2 damage to Disruptors (Jammer, Siphon, Blackout Rig, Capacitor); a hit cancels a Capacitor's charge | new |
| 5 | a | Arc Stun | 1020 |  | 48 damage; arcs stun for 0.3 s (bosses 0.1 s) | new |
| 6 | a | Clean Conduction | 1705 |  | 54 damage; only 8% lost per jump | new |
| M | a | Lightning Rod | 4310 |  | 60 damage; 3% lost per jump; stun 0.5 s | new |
| 3 | b | Taller Coil | 70 |  | +20 range (160) | new |
| 4 | b | Extra Jump | 155 |  | 4 jumps | new |
| 5 | b | Storm Field | 2260 |  | 5 jumps; each arc leaves a 25 px storm for 2 s (10 energy damage/s to every enemy in it) | new |
| 6 | b | Wide Storm | 2390 |  | +20 range (180); 6 jumps | new |
| M | b | Tempest | 8140 |  | 7 jumps; storms of 14/s, 30 px | new |
| 3 | c | Quick Recharge | 60 |  | 0.9 arcs/s | new |
| 4 | c | Fast Capacitor | 125 |  | 1.0 arcs/s | new |
| 5 | c | Rapid Discharge | 995 |  | 1.4 arcs/s | new |
| 6 | c | Overclocked Coil | 995 |  | 1.6 arcs/s | new |
| M | c | Continuous Discharge | 4980 |  | 2.1 arcs/s: near-constant lightning | new |

## Drone Bay
id: drone_bay · class: Assault · weapon: Deployable · build: 300 cr · status: new · branches: Power (damage), Weaponry (loadouts, switchable on the bay's panel), Speed (rate of fire)
Houses combat drones that hunt after enemies. "The military really took the idea of same-day delivery and ran with it."

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Drone Bay | 300 |  | 300 credits; 1 combat drone with a gun: 16 damage, 3 shots/s, hunting the nearest enemy to the core, anywhere on the map; air and ground. The drone flies to its target, so far-off enemies take a moment to reach. | new |
| 2 | r1 | Second Hangar | 3200 |  | The owner kept it single when every other tower got a choice of three (2026-10-15). It launches the second drone, doubling the bay's firepower. The formula said 600; the owner set 3,200, since doubling the firepower is worth more than a step 1. | new |
| 3 | a | Heavier Guns | 150 |  | 20 damage | new |
| 4 | a | Hot Loads | 300 |  | 24 damage | new |
| 5 | a | Combat Firmware | 900 |  | 30 damage | new |
| 6 | a | Assault Frames | 1800 |  | 36 damage | new |
| M | a | Elite Drones | 3600 |  | 42 damage | new |
| 3 | b | Micro-Missiles | 60 |  | Unlocks missiles: slower shots with a 25 px blast | new |
| 4 | b | Bomb Racks | 120 |  | Unlocks bombs: heavy ground-only drops with a 40 px blast | new |
| 5 | b | Drone Laser | 290 |  | Unlocks laser: energy damage that ignores armour (a Wraith counter once it's revealed) | new |
| 6 | b | Upgraded Loadouts | 865 |  | Every loadout 25% stronger | new |
| M | b | Full Kit | 3360 |  | A combined loadout: guns, missiles and laser together | new |
| 3 | c | Fast Cycling | 100 |  | 3.5 shots/s | new |
| 4 | c | Twin Feed | 200 |  | 4 shots/s | new |
| 5 | c | Rotary Guns | 800 |  | 5 shots/s | new |
| 6 | c | Overclocked Feed | 1280 |  | 5.8 shots/s | new |
| M | c | Storm Drones | 3840 |  | 7 shots/s | new |

## CAS Gunship
id: cas_gunship · class: Assault · weapon: Deployable · build: 650 cr · status: new · branches: Light gun (gatling), built in, Medium gun (autocannon), Heavy gun (missiles)
A large slow-flying cargo plane capable of being with with a wide range of weaponry. "You know that feeling you get when its raining outside, but then the rain suddenly goes from being water to large metal bullets being shot at you from that giant plane above you? Yeah, I hate that feeling."

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | CAS Gunship | 650 |  | Gatling (light, built in), autocannon (medium), missiles (heavy). Research unlocks more weapons per class later (the Research Lab rework). - Attack: the tower can be placed anywhere; the gunship orbits a point you designate and side-fires on enemies inside its orbit. Re-designating is free, any time. - Targets: ground and air by default, chosen by the targeting option (the Any/Air/Ground priority). - EMPs under its orbit silence its guns, like the Drone Bay's drones. - Retrofit: Radar: it can detect cloaked enemies. - 650 credits to build. - The masteries need research, as other towers' do (owner). - The Radar reveals cloaked enemies to other towers too (owner). | new |
| 2 | r1 | Radar | 35 |  | Cloaked enemies inside the gunship's orbit (Phantom, Wraith) are revealed to every tower (owner), making it a mobile Radar Tower. The formula values it low since it only counts the gunship's own damage. | new |
| 2 | r2 | Extra Ammo | 70 |  | +10% fire rate on every gun. | new |
| 2 | r3 | Wide Orbit | 195 |  | +25 px orbit radius (115), covering more track. | new |
| 3 | a | Heavier Rounds | 175 |  | Damage 12 to 15 | new |
| 4 | a | Faster Spin | 350 |  | 6 rounds/s | new |
| 5 | a | Hardened Rounds | 1125 |  | 19 damage | new |
| 6 | a | Overdrive Motor | 2670 |  | 7.5 rounds/s | new |
| M | a | Twin Gatlings | 5345 |  | 9 rounds/s | new |
| 3 | b | Autocannon | 1145 |  | Unlocks the autocannon: 40 damage, 1.5 shots/s, 25 px blast | new |
| 4 | b | Faster Feed | 455 |  | 1.8 shots/s | new |
| 5 | b | HE Rounds | 1645 |  | 52 damage | new |
| 6 | b | Twin Feed | 3170 |  | 2.2 shots/s | new |
| M | b | Autocannon Battery | 7015 |  | 58 damage; 30 px blast | new |
| 3 | c | Missile Rack | 1235 |  | Unlocks guided missiles: 150 damage, one every 3 s, 45 px blast | new |
| 4 | c | Quick Rack | 525 |  | One every 2.5 s | new |
| 5 | c | Heavy Warheads | 1595 |  | 190 damage | new |
| 6 | c | Auto-Rack | 3785 |  | One every 2 s | new |
| M | c | Hellfire Volley | 13250 |  | Every third volley fires two missiles | new |

## Mine Layer
id: mine_layer · class: Defense · weapon: Explosive · build: 450 cr · status: new · branches: Power/Damage, Production Speed (faster laying, bigger cap), Range (toss distance)
Manufactures and tosses explosive mines onto the track that explode when an enemy passes over them. "You know it's a party when the high-speed confetti start flying in every direction."

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Mine Layer | 450 |  | 450 credits; tosses a mine onto the track within 120 px every 1.5 s, up to 20 at once. Each mine blasts 85 damage in 40 px when a ground or burrowed enemy passes over. Mines spread along the track in range, nearest the entrance end first. | new |
| 2 | r1 | Adhesive Mines | 40 |  | Each mine's blast leaves sticky gel on the track that slows enemies 20% for 2 s. | new |
| 2 | r2 | Shaped Charges | 160 |  | +15 damage per mine (100). | new |
| 2 | r3 | Long Arm | 150 |  | +20 toss range (140). | new |
| 3 | a | Heavier Charge | 160 |  | 100 damage | new |
| 4 | a | Wider Charge | 265 |  | 50 px blast | new |
| 5 | a | HE Mines | 1190 |  | 125 damage | new |
| 6 | a | Fragmentation Casing | 1325 |  | 60 px blast | new |
| M | a | Anti-Tank Mines | 6880 |  | 150 damage, 65 px blast | new |
| 3 | b | Quick Assembly | 110 |  | A mine every 1.33 s; cap 24 | new |
| 4 | b | Twin Press | 270 |  | Every 1.2 s; cap 28 | new |
| 5 | b | Assembly Line | 1080 |  | Every 0.95 s; cap 32 | new |
| 6 | b | Rapid Line | 1620 |  | Every 0.85 s; cap 36 | new |
| M | b | Mine Factory | 5395 |  | Every 0.7 s; cap 45 | new |
| 3 | c | Longer Arm | 150 |  | 140 px | new |
| 4 | c | Spring Launcher | 300 |  | 160 px | new |
| 5 | c | Mine Mortar | 900 |  | 190 px | new |
| 6 | c | Long Mortar | 1800 |  | 220 px | new |
| M | c | Minefield Launcher | 4795 |  | 260 px: covers a long stretch of track | new |

## Chemical Plant
id: chemical_plant · class: Support · weapon: Chemical · build: 250 cr · status: new · branches: Damage/Armor stripping (acid), Speed (spray rate and soak length), Slowing (gel)
A chemical manufacturing facility that produces and sprays chemicals on nearby enemies. "Known to cause cancer in the state of California."

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Chemical Plant | 250 |  | 250 credits; sprays one enemy every 1.5 s within 130 px, air and ground. The soak lasts 4 s, and the enemy loses 3 armour while soaked (it comes back when the soak ends). The plant always picks an unsoaked enemy. | new |
| 2 | r1 | Pressure Pump | 150 |  | A spray every 1.33 s, and +20 range (150). | new |
| 2 | r2 | Mist Nozzle | 300 |  | Each spray also soaks one more unsoaked enemy next to the target. | new |
| 2 | r3 | Bigger Tanks | 60 |  | Soaks last 5 s. | new |
| 3 | a | Corrosive Acid | 250 |  | Stripped armour stays gone permanently, so every tower benefits for the rest of the enemy's life | new |
| 4 | a | Etching Acid | 665 |  | 4 armour per soak; acid burns 5 damage/s | new |
| 5 | a | Fast-Acting Acid | 1335 |  | 5 armour, stripped faster; 10 damage/s | new |
| 6 | a | Concentrated Acid | 2665 |  | 6 armour; 15 damage/s | new |
| M | a | Dissolver | 5335 |  | 7 armour per soak; 20 damage/s | new |
| 3 | b | Quick Valve | 100 |  | A spray every 1.25 s | new |
| 4 | b | Long-Lasting Mix | 140 |  | The soak lasts 5 s | new |
| 5 | b | Twin Valves | 990 |  | A spray every second; the soak lasts 6 s | new |
| 6 | b | High-Flow Pump | 1470 |  | A spray every 0.83 s | new |
| M | b | Twin Nozzles | 7760 |  | Sprays two enemies at once (about 1.6 a second); the soak lasts 7 s | new |
| 3 | c | Sticky Gel | 250 |  | Soaked enemies are slowed 15% | new |
| 4 | c | Thick Gel | 335 |  | 25% | new |
| 5 | c | Glue | 665 |  | 35% | new |
| 6 | c | Setting Glue | 1335 |  | 45% | new |
| M | c | Quick-Set Foam | 2665 |  | 55%: nearly frozen | new |

## Boost Tower
id: boost_tower · class: Support · weapon: None · build: 400 cr · status: new · branches: Damage boost, Speed boost (fire rate), Range boost
Towers in range of the Rally Beacon are amped up and given stat boosts. "Are you feeling it now Mr. Krabs?"

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Boost Tower | 400 |  | 400 credits; towers within 144 px (3 tiles) get +5% damage, +5% fire rate and +5% range (confirmed by the owner). Doesn't attack. | new |
| 2 | r1 | Signal Booster | 1380 |  | The radius grows to 168 px, and +5% to all three boosts, stacking on top (+10% each). | new |
| 2 | r2 | Crit Link | 185 |  | Boosted towers gain a 3% crit chance (it adds to the Augmentation Tower's crits). | new |
| 2 | r3 | Wide Mast | 625 |  | The radius grows to 192 px (a 4-tile aura), with no boost change. | new |
| 3 | a | Amplifier | 615 |  | Damage boost +15% | new |
| 4 | a | Power Relay | 860 |  | +22% | new |
| 5 | a | Overcharge Link | 2460 |  | +32% | new |
| 6 | a | Surge Link | 3940 |  | +40% | new |
| M | a | Battle Network | 9845 |  | +50% damage | new |
| 3 | b | Clock Sync | 615 |  | Fire-rate boost +15% | new |
| 4 | b | Fast Sync | 860 |  | +22% | new |
| 5 | b | Overclock Link | 2460 |  | +32% | new |
| 6 | b | Turbo Link | 3940 |  | +40% | new |
| M | b | Rapid Network | 9845 |  | +50% fire rate | new |
| 3 | c | Spotting Relay | 370 |  | Range boost +15% | new |
| 4 | c | Wide Relay | 515 |  | +22% | new |
| 5 | c | Targeting Link | 1475 |  | +32% | new |
| 6 | c | Long Link | 2365 |  | +40% | new |
| M | c | Overwatch Network | 5910 |  | +50% range | new |

## Radar Tower
id: radar_tower · class: Utility · weapon: Energy · build: 575 cr · status: new · branches: Power/Range (range, then radiation), Speed/Frequency, Special Targeting (unmasking)
Radar is able to detect and alert nearby towers of stealthy or otherwise hidden enemies. "I've lost the bleeps, I've lost the sweeps, and I've lost the creeps."

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Radar Tower | 575 |  | 575 credits; a 160 px radius. Every 3 s it pings: for 1 s, cloaked enemies inside are targetable, and burrowed enemies show, so towers that can hit underground (the Mortar's Bunker Buster, the Mine Layer) can target them. Only towers within the radar's 160 px benefit. Doesn't attack. | new |
| 2 | r1 | Bigger Dish | 305 |  | +20 radius (180 px). | new |
| 2 | r2 | Signal Processor | 575 |  | Each reveal lasts 1.5 s. | new |
| 2 | r3 | Early Warning | 230 |  | Shows the next wave's hidden enemies (cloaked, burrowers, disguised) in the wave preview before it starts. | new |
| 3 | a | Bigger Array | 305 |  | 180 px radius | new |
| 4 | a | Tall Mast | 685 |  | 200 px | new |
| 5 | a | Radiation Emitter | 585 |  | Radiation circle: enemies within 60 px take 15 energy damage/s while inside | new |
| 6 | a | High-Power Emitter | 3995 |  | 220 px radius; radiation 25/s within 70 px | new |
| M | a | Microwave Array | 6440 |  | 230 px radius; radiation 40/s within 80 px | new |
| 3 | b | Faster Sweep | 255 |  | A ping every 2.7 s, revealing for 1.1 s | new |
| 4 | b | Pulse Compression | 640 |  | Every 2.4 s, for 1.2 s | new |
| 5 | b | Rapid Sweep | 2070 |  | Every 2 s, for 1.3 s | new |
| 6 | b | Phased Array | 4485 |  | Every 1.6 s, for 1.3 s | new |
| M | b | Constant Track | 10350 |  | Constant: everything hidden in range stays revealed | new |
| 3 | c | Signal Analysis | 230 |  | Pings expose the Decoy Beacon's fake rank: towers in range rank it correctly | new |
| 4 | c | Disguise Breaker | 460 |  | Pings unmask the Masquerade early | new |
| 5 | c | Track Lock | 1930 |  | Reveals last 1.3 s | new |
| 6 | c | Illusion Filter | 2390 |  | Pings mark Mirage holograms as fakes: towers in range stop shooting them | new |
| M | c | Total Exposure | 3590 |  | Revealed enemies can't re-cloak, re-disguise or re-burrow for 5 s after leaving the radar's range | new |

## Cryo Tower
id: cryo_tower · class: Support · weapon: Field · build: 150 cr · status: new · branches: Slowing (deeper, permanent, freeze), Power/Range (frostbite and range), Speed (faster waves and travel)
Produces a wave of sub-zero temperature gasses that stunt the mobility of enemies within range. "The military had to put restrictions on these machines after a group of soldiers got caught having a snowball fight in the middle of a heatwave."

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Cryo Tower | 150 |  | A deeper slow, then permanent slowing; the mastery freezes. - Path 2 (Power/Range): frostbite damage and range. - Path 3 (Speed): faster waves and faster travel (the gas spreads faster). - Retrofit: a coolant tank (a longer slow). | new |
| 2 | r1 | Coolant Tank | 80 |  | The slow lasts 2.2 s. | new |
| 2 | r2 | Compressor | 35 |  | A wave every 1.7 s. | new |
| 2 | r3 | Deep Cold | 75 |  | Slow 20% to 25%. | new |
| 3 | a | Colder Gas | 120 |  | Slow 28% | new |
| 4 | a | Sub-Zero Gas | 210 |  | Slow 35% | new |
| 5 | a | Permafrost | 1705 |  | Enemies chilled by it keep a permanent 10% slow for the rest of their life, even outside its range | new |
| 6 | a | Deep Chill | 2905 |  | Slow 45%; permanent 15% | new |
| M | a | Deep Freeze | 8460 |  | Slow 50%; permanent 20%; every 4th wave freezes enemies solid for 1 s (bosses 0.3 s) | new |
| 3 | b | Frostbite | 105 |  | Each wave does 5 damage; 120 px radius | new |
| 4 | b | Hard Frost | 230 |  | 10 damage; 130 px | new |
| 5 | b | Ice Storm | 790 |  | 18 damage; 145 px | new |
| 6 | b | Biting Cold | 695 |  | 26 damage | new |
| M | b | Blizzard | 4870 |  | 36 damage; 165 px | new |
| 3 | c | Faster Vents | 25 |  | A wave every 1.75 s; the gas spreads faster | new |
| 4 | c | Pressurised Gas | 65 |  | Every 1.5 s | new |
| 5 | c | Rapid Vents | 185 |  | Every 1.2 s | new |
| 6 | c | Turbo Vents | 290 |  | Every second | new |
| M | c | Cold Front | 1575 |  | A constant cold field: everything inside stays slowed | new |

## Shockwave Generator
id: shockwave_generator · class: Assault · weapon: Field · build: 450 cr · status: new · branches: Power/Range (bigger, stronger waves), Speed (more waves), Effect (barrier shatter)
Generates powerful shockwaves by creating small nuclear explosion. "Radioactive fallout? What radioactive fallout?"

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Shockwave Generator | 450 |  | 450 credits; a shockwave every 1.75 s hits every enemy within 100 px for 75 damage; air and ground; no aiming. Armour applies (proposed: it's a blast). | new |
| 2 | r1 | Wave Focus | 245 |  | +15 px radius (115). | new |
| 2 | r2 | Containment Coils | 120 |  | +10 damage (85). | new |
| 2 | r3 | Reactor Venting | 150 |  | A wave every 1.5 s. | new |
| 3 | a | Hotter Core | 210 |  | 85 damage; 105 px | new |
| 4 | a | Dense Core | 470 |  | 95 damage; 110 px | new |
| 5 | a | Critical Mass | 1870 |  | 110 damage; 120 px | new |
| 6 | a | Overpressure | 3200 |  | 125 damage; 125 px | new |
| M | a | Megaton Wave | 6690 |  | 135 damage; 132 px | new |
| 3 | b | Quick Cycle | 115 |  | A wave every 1.55 s | new |
| 4 | b | Fast Cycle | 220 |  | Every 1.4 s | new |
| 5 | b | Pulse Core | 980 |  | Every 1.15 s | new |
| 6 | b | Rapid Core | 1645 |  | Every second | new |
| M | b | Chain Pulse | 6310 |  | Every 0.8 s | new |
| 3 | c | Disruptor Wave | 45 |  | ×1.5 damage to barriers | new |
| 4 | c | Harmonic Wave | 55 |  | ×2 to barriers | new |
| 5 | c | Resonance | 145 |  | ×2.5 to barriers | new |
| 6 | c | Breaker Wave | 290 |  | ×3 to barriers | new |
| M | c | Shatter Shock | 1300 |  | Each wave shatters half of every barrier it hits, and barriers it hits can't regenerate for 5 s | new |

## Scrapyard
id: scrapyard · class: Utility · weapon: None · build: 875 cr · status: new · branches: Passive Income, Kill Income (bonus field), Discounts (towers near it)
Various collections of scrap metal sold at a profit. "One mans toxic waste is another mans potpourri"

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Scrapyard | 875 |  | 875 credits; pays 100 credits at each round's clear (× the round's income scale). A 150 px field (used by the Kill and Discount paths). Doesn't attack. | new |
| 2 | r1 | Hammer Mill | 525 |  | +30 income per round. | new |
| 2 | r2 | Faster Loading | 260 |  | +30 px to its fields (a second conveyor and a second crane feed the furnace). Its value depends on the paths, so the formula can't price it at stock; proposed at Surplus's price. | new |
| 2 | r3 | Surplus | 260 |  | Towers sold within its field refund 15% more (two extra crates of surplus stock). | new |
| 3 | a | Firebrick Lining | 525 |  | 130 per round | new |
| 4 | a | Forced Bellows | 1225 |  | 165 per round | new |
| 5 | a | Blast Furnace | 3850 |  | 220 per round | new |
| 6 | a | Arc Furnace | 7000 |  | 270 per round | new |
| M | a | Gold Foundry | 27440 |  | 320 per round, plus 3% interest on banked credits at each clear (up to 400) | new |
| 3 | b | Tow Hook | 345 |  | Enemies destroyed within 140 px pay 15% more | new |
| 4 | b | Magnet Crane | 625 |  | +25%; 150 px | new |
| 5 | b | Laser Cutter | 2095 |  | +35%; 170 px | new |
| 6 | b | Car Crusher | 5720 |  | +45%; 190 px | new |
| M | b | Breaker's Yard | 28945 |  | +60%; 210 px; bosses pay double | new |
| 3 | c | Parts Shelves | 190 |  | Towers within 140 px upgrade for 5% less | new |
| 4 | c | Pallet Racks | 495 |  | 10% off upgrades; 150 px | new |
| 5 | c | Forklift Bay | 2035 |  | 15% off upgrades, 5% off builds; 160 px | new |
| 6 | c | Loading Dock | 3865 |  | 20% off upgrades; 175 px | new |
| M | c | Parts Exchange | 20935 |  | 25% off upgrades, 10% off builds; 190 px; towers in the field sell back for everything spent on them | new |

## Magneto Tower
id: magneto_tower · class: Defense · weapon: Field · build: 525 cr · status: new · branches: Pull Strength (stronger slow, heavies too), Field Size, Polarity (strip, then permanent, then repel)
A massive electromagnet that magnetically pulls against enemies in range, slowing them down and pulling off armor. "Yeah, science!"

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Magneto Tower | 525 |  | 525 credits; a constant magnetic field of 120 px. Every enemy inside, air and ground, is slowed 25% while inside, scaled by weight. The strongest slow applies, as today. | new |
| 2 | r1 | Superconducting Coil | 210 |  | Slow 25% to 30%; the coil frosts over. | new |
| 2 | r2 | Field Stabiliser | 280 |  | +15 px radius (135). | new |
| 2 | r3 | Pole Shoes | 135 |  | Heavy roles resist 30% less. | new |
| 3 | a | Stronger Coil | 295 |  | Slow 32% | new |
| 4 | a | Heavy Grip | 565 |  | Slow 35%; heavy roles resist a quarter less | new |
| 5 | a | Mass Lock | 2060 |  | Slow 42%; heavy roles resist half as much | new |
| 6 | a | Dense Field | 2450 |  | Slow 48% | new |
| M | a | Absolute Pull | 13630 |  | Slow 55%; no role resists: Tanks and bosses are slowed fully | new |
| 3 | b | Wider Coil | 180 |  | 130 px | new |
| 4 | b | Field Extender | 395 |  | 140 px | new |
| 5 | b | Broad Field | 1290 |  | 155 px | new |
| 6 | b | Great Field | 2845 |  | 170 px | new |
| M | b | Magnetosphere | 10645 |  | 195 px | new |
| 3 | c | Plate Puller | 360 |  | Enemies in the field lose 2 armour while inside | new |
| 4 | c | Plate Ripper | 720 |  | 4 armour | new |
| 5 | c | Torn Plates | 1440 |  | Pulled armour is gone for good, even after they leave | new |
| 6 | c | Deep Pull | 2160 |  | 5 armour | new |
| M | c | Reverse Polarity | 9600 |  | Every 4 s the field flips to repel: enemies are flung into each other for impact damage and a 0.3 s stun | new |

## Tractor Tower
id: tractor_tower · class: Defense · weapon: Energy · build: 575 cr · status: new · branches: Pull Distance, Recharge, Grip
A dish-mounted emitter that locks a tractor beam onto a single enemy and hauls it back down the track before letting go. "You're my friend now."

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Tractor Tower | 575 |  | 575 credits; 160 px range; air and ground. It locks one enemy (by its targeting mode), holds it for 1.5 s while hauling it 80 px back along the track, releases it, then recharges for 6 s. While held, the enemy can't move forward, blink or use abilities (a hold counts as a stun for those rules). The pull scales by role weight, as on the Magneto (Swarm full, Tank half, Boss a quarter). | new |
| 2 | r1 | Twin Emitter | 575 |  | A second, weaker beam that holds another enemy at half the pull. | new |
| 2 | r2 | Longer Hold | 140 |  | Holds for 2 s. | new |
| 2 | r3 | Faster Recharge | 230 |  | Recharges in 5 s. | new |
| 3 | a | Longer Haul | 185 |  | 100 px pull | new |
| 4 | a | Stronger Beam | 535 |  | 120 px; holds 1.8 s | new |
| 5 | a | Rewind | 1840 |  | Sends the enemy back to where it was 3 s ago (by time, owner) | new |
| 6 | a | Long Rewind | 2945 |  | Back 4 s | new |
| M | a | Undo | 9215 |  | Back 5 s; and once per round, sends one non-boss enemy back to the start of its current track segment (owner: weaker than to the entrance) | new |
| 3 | b | Quick Release | 175 |  | Recharge 5.2 s | new |
| 4 | b | Capacitor Bank | 345 |  | 4.6 s | new |
| 5 | b | Rapid Lock | 1265 |  | 3.8 s | new |
| 6 | b | Overclocked Emitter | 2200 |  | 3.3 s | new |
| M | b | Dual Beam | 10035 |  | A second beam on another enemy, at a third of the pull | new |
| 3 | c | Firm Grip | 190 |  | Heavy roles resist half as much | new |
| 4 | c | Crushing Grip | 270 |  | The held enemy takes 15 energy damage/s | new |
| 5 | c | Lift and Drop | 1075 |  | Ground enemies are lifted, then slammed down, stunning everything within 50 px for 0.4 s | new |
| 6 | c | Grip Lock | 1610 |  | The held enemy's barrier and abilities switch off while held | new |
| M | c | Gravity Hammer | 5365 |  | The slam stuns everything within 80 px for 0.8 s and shatters barriers | new |

## Augmentation Tower
id: augmentation_tower · class: Support · weapon: None · build: 650 cr · status: new · branches: Energy Conversion, Critical Hits, Ricochet
Neighboring towers are given special augmentations to their weaponry through mysterious means. "So my 12-guage shotgun shoots thermonuclear explosives now apparently."

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Augmentation Tower | 650 |  | 650 credits; towers within 96 px get a 5% chance to crit (double damage) on every hit. Doesn't attack. | new |
| 2 | r1 | Wide Aura | 170 |  | A 3-tile radius (144 px). | new |
| 2 | r2 | Amplified Bonus | 135 |  | The stock crit chance doubles to 10%. | new |
| 2 | r3 | Remote Link | 75 |  | Towers up to twice its radius away get its effects at half strength. | new |
| 3 | a | Charged Rounds | 105 |  | 25% of nearby towers' damage counts as energy | new |
| 4 | a | Plasma Coating | 205 |  | 50% | new |
| 5 | a | Energy Weave | 410 |  | 75% | new |
| 6 | a | Full Conversion | 820 |  | 100%: every nearby tower's damage is energy, so even Ballistic and Explosive towers can hurt the Wraith | new |
| M | a | Overcharge | 4375 |  | 100% energy, plus +10% bonus energy damage | new |
| 3 | b | Targeting Assist | 80 |  | 8% crit chance | new |
| 4 | b | Weak-Point Scan | 165 |  | 11% | new |
| 5 | b | Precision Matrix | 1260 |  | 15%; crits do ×2.5 | new |
| 6 | b | Lethal Matrix | 985 |  | 18% | new |
| M | b | Executioner Link | 7440 |  | 22%; crits do ×3 | new |
| 3 | c | Deflector Rounds | 135 |  | 10% of hits bounce to another enemy within 60 px at 50% damage | new |
| 4 | c | Bounce Coating | 275 |  | 20% | new |
| 5 | c | Ricochet Field | 1205 |  | 30%; bounces at 70% | new |
| 6 | c | Chain Bounce | 1530 |  | 40% | new |
| M | c | Pinball | 7660 |  | 50%; a bounce can bounce again | new |
