# Bastion Line Upgrade Trees: tower rework

The 20 reworked towers' upgrade trees, built from `design/tower_roster.md` (issue #55) for the editable trees page.
Not game data: today's trees stay in `design/upgrade_trees.md` until the rework is implemented. Edits made on the page
come back here with `tools/design_pull.mjs`; carry them into `design/tower_roster.md` too.

## Rules

- Each tower has three paths of four upgrades and a mastery. Climb up to two paths, up to two upgrades each; the 3rd upgrade on either makes it the primary, which goes on to its mastery, and the other is capped at 2 with its full effects. The third path is locked. Masteries need the tower's Mastery research.
- The CAS Gunship is the exception: each path is one gun (its step 1 unlocks it; the light gun is built in), and all three paths are uncapped to their masteries.
- The Retrofit is an optional upgrade off to the side: the player picks one of three options when buying it, and the choice is locked. The Drone Bay has a single Retrofit.
- Prices come from the value formula in `design/towers.md` (Pricing), rounded to 5s and 0s, with the owner's overrides. Every number is a first pass for the balance probe. **The prices here are copied from `design/balance.md` by `tools/balance.mjs`: change them there.**

## Gun Turret
id: gun_turret · class: Assault · weapon: Ballistic · build: 75 cr · status: new · branches: Power (armour-piercing), Range/Visibility (precision), Multi-Target
A basic rotating machine gun turret. "It's a machine gun, Private!"
Tagline: Rotating machine gun: fast, cheap, hits air and ground.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Gun Turret | 75 |  | 75 credits; 16 damage, 130 range, 1.2 shots/s (about 19 damage per second). Air and ground. | new |
| 2 | r1 | Water-Cooled Barrel | 40 |  | +0.3 shots/s (1.5). | new |
| 2 | r2 | Shock Rounds | 5 |  | Every hit has a 5% chance to stun its target for 0.3 s. | new |
| 2 | r3 | Incendiary Rounds | 25 |  | Hits set the target burning for 3 damage per second for 2 s. | new |
| 3 | a | Heavier Rounds | 55 |  | +6 damage (22) | new |
| 4 | a | Hardened Tips | 165 |  | +6 damage (28); hits ignore 2 points of armour | new |
| 5 | a | AP Rounds | 530 |  | +8 damage (36); ignores 50% of armour | new |
| 6 | a | Tungsten Core | 1365 |  | +10 damage (46); ignores +25% of armour (75%) | new |
| M | a | Sabot Rounds | 3555 |  | +12 damage (58); ignores +25% of armour (100%): armour doesn't count | new |
| 3 | b | Long Barrel | 25 |  | +20 range (150) | new |
| 4 | b | Tracer Rounds | 60 |  | +10 range (160); a 10% chance of a critical hit (double damage); visible tracer lines | new |
| 5 | b | Rifled Barrels | 170 |  | +25 range (185); +5% crit chance (15%) | new |
| 6 | b | Rangefinder | 305 |  | +20 range (205); +5% crit chance (20%) | new |
| M | b | Targeting Computer | 980 |  | +25 range (230); +10% crit chance (30%) | new |
| 3 | c | Swivel Mount | 85 |  | +0.5 shots/s (1.7); turns onto a new target faster, and doesn't fire at enemies already about to die (no wasted rounds on swarms and holograms) | new |
| 4 | c | Side Gun | 440 |  | +0.5 shots/s (2.2); a small side gun fires at a second target at 50% damage | new |
| 5 | c | Twin Mount | 1155 |  | +0.5 shots/s (2.7); 2 targets at full damage | new |
| 6 | c | Belt Feed | 1100 |  | +0.5 shots/s on every barrel (3.2) | new |
| M | c | Triple Mount | 10325 |  | +0.5 shots/s (3.7); +1 target (3); the extra barrels go for the weakest enemies in range (swarms, holograms) | new |

## Mortar Tower
id: mortar_tower · class: Assault · weapon: Explosive · build: 150 cr · status: new · branches: Power/Penetration, Speed/Range (more tubes, more reach), Blast Radius/Multi-Target (cluster shells)
Lobs high-explosive shells at nearby enemies. "Toob."
Tagline: Lobs shells over the track for splash damage on the ground.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Mortar Tower | 150 |  | 150 credits; 30 damage per shell, a 60 px blast, 110 range, 0.6 shells/s; ground only. A little less single-target damage than the Gun Turret, but it hits a whole pack. | new |
| 2 | r1 | Field Kit | 120 |  | A reinforced baseplate, a ranging sight and an ammo rack: +4 damage (34), +10 range (120), +0.05 shells/s (0.65), +5 px blast (65). | new |
| 2 | r2 | Bunker Sight | 15 |  | It can target burrowed enemies inside Radar Tower range, at half damage (the Bunker Buster mastery does it at full). | new |
| 2 | r3 | Smoke Shells | 15 |  | Every 4th shell leaves a smoke cloud for 3 s that slows enemies inside it by 15%. | new |
| 3 | a | HE Charge | 80 |  | +8 damage (38) | new |
| 4 | a | Shaped Charge | 95 |  | Shells ignore 25% of armour | new |
| 5 | a | AP Shells | 685 |  | +10 damage (48); ignores +25% of armour (50%) | new |
| 6 | a | Delayed Fuse | 1350 |  | +8 damage (56); ignores +25% of armour (75%) | new |
| M | a | Bunker Buster | 3140 |  | +8 damage (64); shells dig in and hit burrowed enemies inside Radar Tower range | new |
| 3 | b | Quick Reload | 50 |  | +0.1 shells/s (0.7) | new |
| 4 | b | Extended Tube | 125 |  | +20 range (130) | new |
| 5 | b | Twin Tubes | 1170 |  | A second tube firing in succession: +0.5 shells/s (1.2) | new |
| 6 | b | Long Tubes | 1405 |  | +20 range (150); +0.1 shells/s (1.3) | new |
| M | b | Barrage Battery | 6165 |  | A third tube: +0.4 shells/s (1.7); +15 range (165) | new |
| 3 | c | Bigger Charge | 30 |  | +10 px blast (70) | new |
| 4 | c | Wide Burst | 60 |  | +10 px blast (80) | new |
| 5 | c | Cluster Shells | 1110 |  | Each shell also scatters 4 bomblets around the impact (10 damage, 30 px each) | new |
| 6 | c | Dense Cluster | 1230 |  | +2 bomblets (6); +5 px blast (85) | new |
| M | c | Carpet Shells | 5000 |  | +2 bomblets (8), each +2 damage (12) and +5 px (35), spread wider; +5 px blast (90) | new |

## Laser Tower
id: laser_tower · class: Assault · weapon: Energy · build: 250 cr · status: new · branches: Power (faster, higher ramp), Multi-Target (prism split), Range/Targeting (long-range lance, shortened by the owner)
A High-Energy Laser Emitter affixed to a rotating turret. "It does more than just blind the enemy, that's for sure."
Tagline: A beam that ramps up the longer it holds one target.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Laser Tower | 250 |  | 250 credits; 25 damage per second, ramping up to ×3 over 3 s on the same target; 150 range; air and ground. Armour melt: the locked target loses 1 armour per second, down to 0. The armour stays gone, so other towers benefit. Switching targets resets the ramp but not the melted armour. | new |
| 2 | r1 | Capacitor Bank | 160 |  | +8 damage per second (33). | new |
| 2 | r2 | Heat Sinks | 60 |  | +0.5 ramp ceiling (×3.5). | new |
| 2 | r3 | Ramp Memory | 55 |  | Switching targets keeps half the ramp instead of resetting it. | new |
| 3 | a | Hotter Emitter | 60 |  | +0.5 ramp ceiling (×3.5) | new |
| 4 | a | Quick Focus | 60 |  | −0.8 s ramp time (2.2 s) | new |
| 5 | a | Overdrive | 815 |  | +1.5 ramp ceiling (×5) | new |
| 6 | a | Thermal Lock | 1425 |  | +1 ramp ceiling (×6); −0.4 s ramp time (1.8 s) | new |
| M | a | Annihilator | 5535 |  | +2 ramp ceiling (×8); −0.3 s ramp time (1.5 s): the boss killer | new |
| 3 | b | Beam Splitter | 200 |  | A second beam on another target at 40% power | new |
| 4 | b | Tuned Splitter | 200 |  | +20% second-beam power (60%) | new |
| 5 | b | Prism | 1190 |  | +1 beam (3); the extras at 60% | new |
| 6 | b | Clear Prism | 1190 |  | +15% extra-beam power (75%) | new |
| M | b | Prism Array | 5950 |  | +1 beam (4); each beam ramps on its own target | new |
| 3 | c | Extended Optics | 50 |  | +15 range (165) | new |
| 4 | c | Collimator | 100 |  | +15 range (180) | new |
| 5 | c | Lance | 395 |  | +30 range (210) | new |
| 6 | c | Long Lance | 795 |  | +30 range (240) | new |
| M | c | Deep Lance | 2115 |  | +40 range (280): still a mid-range tower, but with a long reach | new |

## Rocket Salvo
id: rocket_salvo · class: Assault · weapon: Explosive · build: 200 cr · status: new · branches: Power (heavier warheads), Range/Target Acquisition (homing), Reload/Payload (more rockets, faster reloads)
Launches a volley of rockets at oncoming enemies. "Instead of shooting bullets, it shoots very angry telephone poles that hate absolutely everything."
Tagline: Fires a salvo of rockets, each at a different enemy.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Rocket Salvo | 200 |  | 200 credits; a salvo of 3 rockets every 2.5 s, each on a different enemy, 19 damage with a 25 px blast; 180 range; air and ground. Without homing, rockets fly at where the target was, so very fast or blinking enemies can dodge them. | new |
| 2 | r1 | Proximity Fuses | 40 |  | Rockets burst beside flyers for +40% damage against air. | new |
| 2 | r2 | Smoke Trails | 20 |  | Rockets leave smoke along their path that slows enemies inside it by 10% for 2 s. | new |
| 2 | r3 | Incendiary Warheads | 125 |  | Blasts leave burning ground, 3 damage per second for 2 s. | new |
| 3 | a | HE Warheads | 105 |  | +5 damage per rocket (24) | new |
| 4 | a | Wider Burst | 155 |  | +10 px blast (35) | new |
| 5 | a | Heavy Warheads | 985 |  | +8 damage (32); +5 px blast (40) | new |
| 6 | a | Dense Payload | 1245 |  | +6 damage (38) | new |
| M | a | Thermobaric Rockets | 5710 |  | +8 damage (46); +10 px blast (50) | new |
| 3 | b | Booster Stage | 45 |  | +20 range (200) | new |
| 4 | b | Seeker Heads | 135 |  | Homing: rockets curve onto their target | new |
| 5 | b | Smart Seekers | 510 |  | +30 range (230); rockets re-target if their target dies | new |
| 6 | b | Long Burn | 670 |  | +30 range (260) | new |
| M | b | Hunter Seekers | 2315 |  | +40 range (300); seekers never miss, catching fast and blinking enemies | new |
| 3 | c | Extra Tube | 135 |  | +1 rocket per salvo (4) | new |
| 4 | c | Quick Loader | 265 |  | −0.5 s between salvos (2 s) | new |
| 5 | c | Six-Pack | 1335 |  | +2 rockets per salvo (6) | new |
| 6 | c | Auto-Loader | 1605 |  | −0.3 s between salvos (1.7 s) | new |
| M | c | Ripple Salvo | 6415 |  | +2 rockets per salvo (8), rippling out one after another | new |

## Anti-Aircraft Turret
id: anti_aircraft_turret · class: Assault · weapon: Ballistic · build: 150 cr · status: new · branches: Range (area denial), Power/Blast Radius (flak shells), Speed (barrels and rate of fire)
A fully automatic anti-aircraft gun. "We don't need a gun, or a nug!"
Tagline: Flak that shreds flyers; it ignores ground enemies.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Anti-Aircraft Turret | 150 |  | 150 credits; 25 damage per round, 2.5 rounds/s, 160 range; flyers only. That's about 62 damage per second against air: it shreds Locusts and Strike Drones and wears down Gunships. | new |
| 2 | r1 | Fire-Control Radar | 45 |  | +15 range (175). | new |
| 2 | r2 | Ammo Drum | 30 |  | +0.25 rounds/s (2.75). | new |
| 2 | r3 | Armoured Mount | 50 |  | +4 damage (29). | new |
| 3 | a | Long Barrel | 40 |  | +20 range (180) | new |
| 4 | a | Higher Mount | 75 |  | +20 range (200) | new |
| 5 | a | Sky Watch | 300 |  | +40 range (240) | new |
| 6 | a | High-Velocity Rounds | 600 |  | +40 range (280) | new |
| M | a | Sky Wall | 1500 |  | +50 range (330): covers a big circle of sky | new |
| 3 | b | Heavier Rounds | 70 |  | +6 damage (31) | new |
| 4 | b | Flak Rounds | 375 |  | Rounds burst near their target: a 20 px airburst on every flyer nearby | new |
| 5 | b | Flak Shells | 795 |  | +5 damage (36); +10 px airburst (30) | new |
| 6 | b | Wide Burst | 865 |  | +10 px airburst (40) | new |
| M | b | Flak Curtain | 4325 |  | +6 damage (42); +10 px airburst (50): whole flocks of Locusts and Shrikes go down together | new |
| 3 | c | Quick Cycle | 35 |  | +0.3 rounds/s (2.8) | new |
| 4 | c | Fast Traverse | 95 |  | +0.4 rounds/s (3.2); turns faster onto new flyers | new |
| 5 | c | Twin Barrels | 625 |  | Twin barrels: +1.3 rounds/s (4.5) | new |
| 6 | c | Belt Feed | 675 |  | +0.7 rounds/s (5.2) | new |
| M | c | Quad Mount | 3460 |  | Four barrels: +1.8 rounds/s (7), a wall of fire | new |

## Artillery Cannon
id: artillery_cannon · class: Assault · weapon: Explosive · build: 300 cr · status: new · branches: Power (damage and blast, then armour piercing), Speed (faster reload), Special Effects (shell types)
A large-bore cannon that fires high-explosive shells very long distances. "It's not DiGiorno..."
Tagline: Long-range shells on a point of the track you choose.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Artillery Cannon | 300 |  | 300 credits; a heavy shell every 4 s onto the aimed spot, 75 damage, a 70 px blast, 1.5 s flight time; ground only. A new cannon aims at the track point nearest to itself until you set it. | new |
| 2 | r1 | Shell Magazine | 120 |  | Every third shell is a heavy round for +50% damage (about +17% on average), with no change to reload time. | new |
| 2 | r2 | Stabilised Mount | 120 |  | −15 px scatter (15 px): shells land closer to the aimed spot, so the blast hits what you aimed at. | new |
| 2 | r3 | Wide Charge | 80 |  | +15 px blast (85). | new |
| 3 | a | Heavy Shells | 120 |  | +15 damage (90) | new |
| 4 | a | Wide Bursting Charge | 200 |  | +15 px blast (85) | new |
| 5 | a | HE Shells | 730 |  | +20 damage (110) | new |
| 6 | a | Penetrator Shells | 2930 |  | +10 damage (120); ignores 50% of armour | new |
| M | a | Siege Shells | 7355 |  | +20 damage (140); +5 px blast (90); ignores +25% of armour (75%) | new |
| 3 | b | Drilled Crew | 120 |  | −0.7 s between shells (3.3 s) | new |
| 4 | b | Quick Breech | 240 |  | −0.4 s between shells (2.9 s) | new |
| 5 | b | Autoloader | 1450 |  | −0.9 s between shells (2 s) | new |
| 6 | b | Rapid Breech | 1935 |  | −0.3 s between shells (1.7 s) | new |
| M | b | Rolling Barrage | 3865 |  | Fires in 3-shell barrages that walk across the aimed spot: one shell every 1.4 s on average | new |
| 3 | c | Incendiary Shells | 365 |  | Unlocks incendiary: the blast leaves burning ground (15 damage/s for 3 s) | new |
| 4 | c | Shrapnel Shells | 195 |  | Unlocks shrapnel: a 40 px wider blast at 70% damage | new |
| 5 | c | Concussion Shells | 1085 |  | Unlocks concussion: everything in the blast is stunned for 0.5 s (bosses 0.15 s) | new |
| 6 | c | Improved Payloads | 3505 |  | Every shell type stronger: +7 burn damage/s (22), +15% shrapnel damage (85%), +0.2 s stun (0.7 s) | new |
| M | c | Combined Payload | 5725 |  | A fourth type that does all three at once | new |

## Railgun
id: railgun · class: Assault · weapon: Ballistic · build: 500 cr · status: new · branches: Power (boss slayer and overcharge), Range/Speed (mostly recharge), Special Effects (shatter, penetration, ion trail)
A large cannon with magnetically polarized rails that launch a large projectile extremely far, extremely fast. "Known to cause cancer in the state of California."
Tagline: A slow, piercing shot through every enemy in a line.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Railgun | 500 |  | 500 credits; a 90-damage slug every 2.5 s, 380 range; air and ground; armour applies (a Titan's 9 armour costs it only 10%). Penetration: the slug pierces every enemy on its line, losing 40% of its damage with each enemy it passes through (90, 54, 32...). | new |
| 2 | r1 | Capacitor Coils | 140 |  | −0.3 s recharge (2.2 s). | new |
| 2 | r2 | Longer Rails | 265 |  | +15 damage (105); +30 range (410). | new |
| 2 | r3 | Penetrator Tips | 65 |  | −10% damage lost per enemy pierced (30%). | new |
| 3 | a | Dense Slugs | 345 |  | +30 damage (120) | new |
| 4 | a | Boss Rounds | 275 |  | ×1.5 damage to bosses | new |
| 5 | a | Overcharge | 2260 |  | It charges each shot longer: +80 damage (200), +0.5 s recharge (3 s) | new |
| 6 | a | Kill Charge | 5125 |  | +40 damage (240); +0.5 boss multiplier (×2) | new |
| M | a | Kingslayer | 6465 |  | +40 damage (280); +0.3 s recharge (3.3 s); +0.5 boss multiplier (×2.5) | new |
| 3 | b | Fast Capacitors | 140 |  | −0.3 s recharge (2.2 s) | new |
| 4 | b | Extended Rails | 245 |  | +40 range (420) | new |
| 5 | b | Rapid Capacitors | 1930 |  | −0.6 s recharge (1.6 s) | new |
| 6 | b | Supercapacitors | 2610 |  | −0.25 s recharge (1.35 s) | new |
| M | b | Twin Rails | 5000 |  | Two rails firing in turn: −0.15 s recharge (a slug every 1.2 s), twice the stock rate | new |
| 3 | c | Shatter Rounds | 60 |  | Each hit strips 2 armour permanently, so every tower benefits | new |
| 4 | c | Penetrator Core | 260 |  | −15% damage lost per enemy pierced (25%) | new |
| 5 | c | Ionised Trail | 1535 |  | The line burns for 2 s: 30 energy damage/s to every enemy on it, targeted or not (cloaked ones too) | new |
| 6 | c | Hot Rail | 3685 |  | +2 armour stripped (4); +15 trail damage/s (45); −10% lost per enemy (15%) | new |
| M | c | Ion Cannon | 6920 |  | +2 armour stripped (6); +5 trail damage/s (50); −15% lost per enemy (0%): full damage to everything on the line | new |

## Tesla Tower
id: tesla_tower · class: Assault · weapon: Energy · build: 250 cr · status: new · branches: Power/Damage (raw voltage, stun, overload), Range/Chaining (storm field), Speed (faster discharges)
A large metal disk mounted atop of a large tower that generates high-voltage electrical arcs that damage incoming enemies. "It was built in a cave with a box of scraps."
Tagline: Lightning that chains from enemy to enemy.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Tesla Tower | 250 |  | 250 credits; an arc every 1.25 s (0.8/s), 32 damage, jumping to 3 more enemies within 70 px and losing 15% per jump; 140 range; air and ground. It's Energy, so armour doesn't count, and it's a Wraith counter once the Wraith is revealed. | new |
| 2 | r1 | Bigger Disk | 120 |  | +4 damage (36); +15 range (155). | new |
| 2 | r2 | Grounding Rods | 65 |  | +1 jump (4). | new |
| 2 | r3 | Insulated Coils | 70 |  | +0.11 arcs/s (0.91): an arc every 1.1 s. | new |
| 3 | a | High Voltage | 125 |  | +8 damage (40) | new |
| 4 | a | Overload Circuits | 100 |  | EMP-enemy overload: ×2 damage to Disruptors (Jammer, Siphon, Blackout Rig, Capacitor); a hit cancels a Capacitor's charge | new |
| 5 | a | Arc Stun | 1020 |  | +8 damage (48); arcs stun for 0.3 s (bosses 0.1 s) | new |
| 6 | a | Clean Conduction | 1705 |  | +6 damage (54); −7% lost per jump (8%) | new |
| M | a | Lightning Rod | 4310 |  | +6 damage (60); −5% lost per jump (3%); +0.2 s stun (0.5 s) | new |
| 3 | b | Taller Coil | 70 |  | +20 range (160) | new |
| 4 | b | Extra Jump | 155 |  | +1 jump (4) | new |
| 5 | b | Storm Field | 2260 |  | +1 jump (5); each arc leaves a 25 px storm for 2 s (10 energy damage/s to every enemy in it) | new |
| 6 | b | Wide Storm | 2390 |  | +20 range (180); +1 jump (6) | new |
| M | b | Tempest | 8140 |  | +1 jump (7); +4 storm damage/s (14); +5 px storms (30) | new |
| 3 | c | Quick Recharge | 60 |  | +0.1 arcs/s (0.9) | new |
| 4 | c | Fast Capacitor | 125 |  | +0.1 arcs/s (1) | new |
| 5 | c | Rapid Discharge | 995 |  | +0.4 arcs/s (1.4) | new |
| 6 | c | Overclocked Coil | 995 |  | +0.2 arcs/s (1.6) | new |
| M | c | Continuous Discharge | 4980 |  | +0.5 arcs/s (2.1): near-constant lightning | new |

## Drone Bay
id: drone_bay · class: Assault · weapon: Deployable · build: 300 cr · status: new · branches: Power (damage), Weaponry (loadouts, switchable on the bay's panel), Speed (rate of fire)
Houses combat drones that hunt after enemies. "The military really took the idea of same-day delivery and ran with it."
Tagline: Launches drones that hunt enemies across the map.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Drone Bay | 300 |  | 300 credits; 1 combat drone with a gun: 16 damage, 3 shots/s, hunting the nearest enemy to the core, anywhere on the map; air and ground. The drone flies to its target, so far-off enemies take a moment to reach. | new |
| 2 | r1 | Second Hangar | 3200 |  | Launches a second drone, doubling the bay's firepower. | new |
| 3 | a | Heavier Guns | 150 |  | +4 damage (20) | new |
| 4 | a | Hot Loads | 300 |  | +4 damage (24) | new |
| 5 | a | Combat Firmware | 900 |  | +6 damage (30) | new |
| 6 | a | Assault Frames | 1800 |  | +6 damage (36) | new |
| M | a | Elite Drones | 3600 |  | +6 damage (42) | new |
| 3 | b | Micro-Missiles | 60 |  | Unlocks missiles: slower shots with a 25 px blast | new |
| 4 | b | Bomb Racks | 120 |  | Unlocks bombs: heavy ground-only drops with a 40 px blast | new |
| 5 | b | Drone Laser | 290 |  | Unlocks laser: energy damage that ignores armour (a Wraith counter once it's revealed) | new |
| 6 | b | Upgraded Loadouts | 865 |  | Every loadout 25% stronger | new |
| M | b | Full Kit | 3360 |  | A combined loadout: guns, missiles and laser together | new |
| 3 | c | Fast Cycling | 100 |  | +0.5 shots/s (3.5) | new |
| 4 | c | Twin Feed | 200 |  | +0.5 shots/s (4) | new |
| 5 | c | Rotary Guns | 800 |  | +1 shot/s (5) | new |
| 6 | c | Overclocked Feed | 1280 |  | +0.8 shots/s (5.8) | new |
| M | c | Storm Drones | 3840 |  | +1.2 shots/s (7) | new |

## CAS Gunship
id: cas_gunship · class: Assault · weapon: Deployable · build: 650 cr · status: new · branches: Light gun (gatling), built in, Medium gun (autocannon), Heavy gun (missiles)
A large slow-flying cargo plane capable of being with with a wide range of weaponry. "You know that feeling you get when its raining outside, but then the rain suddenly goes from being water to large metal bullets being shot at you from that giant plane above you? Yeah, I hate that feeling."
Tagline: A gunship that circles a spot you choose, guns blazing.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | CAS Gunship | 650 |  | 650 credits; place it anywhere. The gunship orbits a point you choose (move it any time, for free) and side-fires on enemies inside its 90 px orbit with its built-in Gatling: 12 damage, 5 rounds/s. Air and ground, by its targeting option. Its paths add an autocannon and missiles. EMPs under its orbit silence its guns. | new |
| 2 | r1 | Radar | 35 |  | Cloaked enemies inside the gunship's orbit (Phantom, Wraith) are revealed to every tower, making it a mobile Radar Tower. | new |
| 2 | r2 | Extra Ammo | 70 |  | +10% fire rate on every gun. | new |
| 2 | r3 | Wide Orbit | 195 |  | +25 px orbit radius (115), covering more track. | new |
| 3 | a | Heavier Rounds | 175 |  | +3 damage (15) | new |
| 4 | a | Faster Spin | 350 |  | +1 round/s (6) | new |
| 5 | a | Hardened Rounds | 1125 |  | +4 damage (19) | new |
| 6 | a | Overdrive Motor | 2670 |  | +1.5 rounds/s (7.5) | new |
| M | a | Twin Gatlings | 5345 |  | +1.5 rounds/s (9) | new |
| 3 | b | Autocannon | 1145 |  | Unlocks the autocannon: 40 damage, 1.5 shots/s, 25 px blast | new |
| 4 | b | Faster Feed | 455 |  | +0.3 shots/s (1.8) | new |
| 5 | b | HE Rounds | 1645 |  | +12 damage (52) | new |
| 6 | b | Twin Feed | 3170 |  | +0.4 shots/s (2.2) | new |
| M | b | Autocannon Battery | 7015 |  | +6 damage (58); +5 px blast (30) | new |
| 3 | c | Missile Rack | 1235 |  | Unlocks guided missiles: 150 damage, one every 3 s, 45 px blast | new |
| 4 | c | Quick Rack | 525 |  | −0.5 s between missiles (2.5 s) | new |
| 5 | c | Heavy Warheads | 1595 |  | +40 damage (190) | new |
| 6 | c | Auto-Rack | 3785 |  | −0.5 s between missiles (2 s) | new |
| M | c | Hellfire Volley | 13250 |  | Every third volley fires two missiles | new |

## Mine Layer
id: mine_layer · class: Defense · weapon: Explosive · build: 450 cr · status: new · branches: Power/Damage, Production Speed (faster laying, bigger cap), Range (toss distance)
Manufactures and tosses explosive mines onto the track that explode when an enemy passes over them. "You know it's a party when the high-speed confetti start flying in every direction."
Tagline: Throws mines onto the track that burst under enemies.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Mine Layer | 450 |  | 450 credits; tosses a mine onto the track within 120 px every 1.5 s, up to 20 at once. Each mine blasts 85 damage in 40 px when a ground or burrowed enemy passes over. Mines land just ahead of the enemies in reach, or anywhere along the track in reach when there are none. | new |
| 2 | r1 | Adhesive Mines | 40 |  | Each mine's blast leaves sticky gel on the track that slows enemies 20% for 2 s. | new |
| 2 | r2 | Shaped Charges | 160 |  | +15 damage per mine (100). | new |
| 2 | r3 | Long Arm | 150 |  | +20 throw range (140). | new |
| 3 | a | Heavier Charge | 160 |  | +15 damage (100) | new |
| 4 | a | Wider Charge | 265 |  | +10 px blast (50) | new |
| 5 | a | HE Mines | 1190 |  | +25 damage (125) | new |
| 6 | a | Fragmentation Casing | 1325 |  | +10 px blast (60) | new |
| M | a | Anti-Tank Mines | 6880 |  | +25 damage (150); +5 px blast (65) | new |
| 3 | b | Quick Assembly | 110 |  | −0.17 s between mines (1.33 s); +4 mine cap (24) | new |
| 4 | b | Twin Press | 270 |  | −0.13 s between mines (1.2 s); +4 mine cap (28) | new |
| 5 | b | Assembly Line | 1080 |  | −0.25 s between mines (0.95 s); +4 mine cap (32) | new |
| 6 | b | Rapid Line | 1620 |  | −0.1 s between mines (0.85 s); +4 mine cap (36) | new |
| M | b | Mine Factory | 5395 |  | −0.15 s between mines (0.7 s); +9 mine cap (45) | new |
| 3 | c | Longer Arm | 150 |  | +20 throw range (140) | new |
| 4 | c | Spring Launcher | 300 |  | +20 throw range (160) | new |
| 5 | c | Mine Mortar | 900 |  | +30 throw range (190) | new |
| 6 | c | Long Mortar | 1800 |  | +30 throw range (220) | new |
| M | c | Minefield Launcher | 4795 |  | +40 throw range (260): covers a long stretch of track | new |

## Chemical Plant
id: chemical_plant · class: Support · weapon: Chemical · build: 250 cr · status: new · branches: Damage/Armor stripping (acid), Speed (spray rate and soak length), Slowing (gel)
A chemical manufacturing facility that produces and sprays chemicals on nearby enemies. "Known to cause cancer in the state of California."
Tagline: Sprays acid that strips armour, burns and slows.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Chemical Plant | 250 |  | 250 credits; sprays one enemy every 1.5 s within 130 px, air and ground. The soak lasts 4 s, and the enemy loses 3 armour while soaked (it comes back when the soak ends). The plant always picks an unsoaked enemy. | new |
| 2 | r1 | Pressure Pump | 150 |  | −0.17 s between sprays (1.33 s); +20 range (150). | new |
| 2 | r2 | Mist Nozzle | 300 |  | Each spray also soaks one more unsoaked enemy next to the target; with Constant Spray the jet becomes a mist cloud. | new |
| 2 | r3 | Bigger Tanks | 60 |  | +1 s soak (5 s). | new |
| 3 | a | Corrosive Acid | 250 |  | Stripped armour stays gone permanently, so every tower benefits for the rest of the enemy's life | new |
| 4 | a | Etching Acid | 665 |  | +1 armour stripped per soak (4); acid burns 5 damage/s | new |
| 5 | a | Fast-Acting Acid | 1335 |  | +1 armour stripped (5); +5 acid damage/s (10) | new |
| 6 | a | Concentrated Acid | 2665 |  | +1 armour stripped (6); +5 acid damage/s (15) | new |
| M | a | Dissolver | 5335 |  | +1 armour stripped (7); +5 acid damage/s (20) | new |
| 3 | b | Quick Valve | 100 |  | −0.25 s between sprays (1.25 s) | new |
| 4 | b | Long-Lasting Mix | 140 |  | +1 s soak (5 s) | new |
| 5 | b | Twin Valves | 990 |  | −0.25 s between sprays (1 s); +1 s soak (6 s) | new |
| 6 | b | High-Flow Pump | 1470 |  | −0.17 s between sprays (0.83 s) | new |
| M | b | Constant Spray | 8810 |  | Sprays without stopping, sweeping a 40° fan centred on its target once every 0.83 s; every enemy the jet crosses is soaked or topped up. −2 s soak (4 s) | new |
| 3 | c | Sticky Gel | 250 |  | Soaked enemies are slowed 15% | new |
| 4 | c | Thick Gel | 335 |  | +10% slow (25%) | new |
| 5 | c | Glue | 665 |  | +10% slow (35%) | new |
| 6 | c | Setting Glue | 1335 |  | +10% slow (45%) | new |
| M | c | Quick-Set Foam | 2665 |  | +10% slow (55%): nearly frozen | new |

## Boost Tower
id: boost_tower · class: Support · weapon: None · build: 400 cr · status: new · branches: Damage boost, Speed boost (fire rate), Range boost
Towers in range of the Rally Beacon are amped up and given stat boosts. "Are you feeling it now Mr. Krabs?"
Tagline: Boosts the damage, fire rate and range of nearby towers.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Boost Tower | 400 |  | 400 credits; towers within 144 px (3 tiles) get +5% damage, +5% fire rate and +5% range. Doesn't attack. | new |
| 2 | r1 | Signal Booster | 1380 |  | +24 px radius (168); +5% to all three boosts (10% each). | new |
| 2 | r2 | Crit Link | 185 |  | Boosted towers gain a 3% crit chance (it adds to the Augmentation Tower's crits). | new |
| 2 | r3 | Wide Mast | 625 |  | +48 px radius (192, a 4-tile aura), with no boost change. | new |
| 3 | a | Amplifier | 615 |  | +10% damage boost (15%) | new |
| 4 | a | Power Relay | 860 |  | +7% damage boost (22%) | new |
| 5 | a | Overcharge Link | 2460 |  | +10% damage boost (32%) | new |
| 6 | a | Surge Link | 3940 |  | +8% damage boost (40%) | new |
| M | a | Battle Network | 9845 |  | +10% damage boost (50%) | new |
| 3 | b | Clock Sync | 615 |  | +10% fire-rate boost (15%) | new |
| 4 | b | Fast Sync | 860 |  | +7% fire-rate boost (22%) | new |
| 5 | b | Overclock Link | 2460 |  | +10% fire-rate boost (32%) | new |
| 6 | b | Turbo Link | 3940 |  | +8% fire-rate boost (40%) | new |
| M | b | Rapid Network | 9845 |  | +10% fire-rate boost (50%) | new |
| 3 | c | Spotting Relay | 370 |  | +10% range boost (15%) | new |
| 4 | c | Wide Relay | 515 |  | +7% range boost (22%) | new |
| 5 | c | Targeting Link | 1475 |  | +10% range boost (32%) | new |
| 6 | c | Long Link | 2365 |  | +8% range boost (40%) | new |
| M | c | Overwatch Network | 5910 |  | +10% range boost (50%) | new |

## Radar Tower
id: radar_tower · class: Utility · weapon: Energy · build: 575 cr · status: new · branches: Power/Range (range, then radiation), Speed/Frequency, Special Targeting (unmasking)
Radar is able to detect and alert nearby towers of stealthy or otherwise hidden enemies. "I've lost the bleeps, I've lost the sweeps, and I've lost the creeps."
Tagline: Pings to reveal cloaked and burrowed enemies.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Radar Tower | 575 |  | 575 credits; a 160 px radius. Every 3 s it pings: for 1 s, cloaked enemies inside are targetable, and burrowed enemies show, so towers that can hit underground (the Mortar's Bunker Buster, the Mine Layer) can target them. Only towers within the radar's 160 px benefit. Doesn't attack. | new |
| 2 | r1 | Bigger Dish | 305 |  | +20 px radius (180). | new |
| 2 | r2 | Signal Processor | 575 |  | +0.5 s per reveal (1.5 s). | new |
| 2 | r3 | Early Warning | 230 |  | Shows the next wave's hidden enemies (cloaked, burrowers, disguised) in the wave preview before it starts. | new |
| 3 | a | Bigger Array | 305 |  | +20 px radius (180) | new |
| 4 | a | Tall Mast | 685 |  | +20 px radius (200) | new |
| 5 | a | Radiation Emitter | 585 |  | Radiation circle: enemies within 60 px take 15 energy damage/s while inside | new |
| 6 | a | High-Power Emitter | 3995 |  | +20 px radius (220); +10 radiation damage/s (25); +10 px radiation circle (70) | new |
| M | a | Microwave Array | 6440 |  | +10 px radius (230); +15 radiation damage/s (40); +10 px radiation circle (80) | new |
| 3 | b | Faster Sweep | 255 |  | −0.3 s between pings (2.7 s); +0.1 s per reveal (1.1 s) | new |
| 4 | b | Pulse Compression | 640 |  | −0.3 s between pings (2.4 s); +0.1 s per reveal (1.2 s) | new |
| 5 | b | Rapid Sweep | 2070 |  | −0.4 s between pings (2 s); +0.1 s per reveal (1.3 s) | new |
| 6 | b | Phased Array | 4485 |  | −0.4 s between pings (1.6 s) | new |
| M | b | Constant Track | 10350 |  | Constant: everything hidden in range stays revealed | new |
| 3 | c | Signal Analysis | 230 |  | Pings expose the Decoy Beacon's fake rank: towers in range rank it correctly | new |
| 4 | c | Disguise Breaker | 460 |  | Pings unmask the Masquerade early | new |
| 5 | c | Track Lock | 1930 |  | +0.3 s per reveal (1.3 s) | new |
| 6 | c | Illusion Filter | 2390 |  | Pings pop Mirage holograms in range | new |
| M | c | Total Exposure | 3590 |  | Revealed enemies can't re-cloak, re-disguise or re-burrow for 5 s after leaving the radar's range | new |

## Cryo Tower
id: cryo_tower · class: Support · weapon: Field · build: 150 cr · status: new · branches: Slowing (deeper, permanent, freeze), Power/Range (frostbite and range), Speed (faster waves and travel)
Produces a wave of sub-zero temperature gasses that stunt the mobility of enemies within range. "The military had to put restrictions on these machines after a group of soldiers got caught having a snowball fight in the middle of a heatwave."
Tagline: Waves of cold that slow everything around it.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Cryo Tower | 150 |  | 150 credits; every 2 s a wave of freezing mist fills 110 px, slowing every enemy inside by 20% for 1.5 s; air and ground. | new |
| 2 | r1 | Coolant Tank | 80 |  | +0.7 s slow (2.2 s). | new |
| 2 | r2 | Compressor | 35 |  | −0.3 s between waves (1.7 s). | new |
| 2 | r3 | Deep Cold | 75 |  | +5% slow (25%). | new |
| 3 | a | Colder Gas | 120 |  | +8% slow (28%) | new |
| 4 | a | Sub-Zero Gas | 210 |  | +7% slow (35%) | new |
| 5 | a | Permafrost | 1705 |  | Enemies chilled by it keep a permanent 10% slow for the rest of their life, even outside its range | new |
| 6 | a | Deep Chill | 2905 |  | +10% slow (45%); +5% permanent slow (15%) | new |
| M | a | Deep Freeze | 8460 |  | +5% slow (50%); +5% permanent slow (20%); every 4th wave freezes enemies solid for 1 s (bosses 0.3 s) | new |
| 3 | b | Frostbite | 105 |  | Each wave does 5 damage; +10 px radius (120) | new |
| 4 | b | Hard Frost | 230 |  | +5 damage (10); +10 px radius (130) | new |
| 5 | b | Ice Storm | 790 |  | +8 damage (18); +15 px radius (145) | new |
| 6 | b | Biting Cold | 695 |  | +8 damage (26) | new |
| M | b | Blizzard | 4870 |  | +10 damage (36); +20 px radius (165) | new |
| 3 | c | Faster Vents | 25 |  | −0.25 s between waves (1.75 s); the gas spreads faster | new |
| 4 | c | Pressurised Gas | 65 |  | −0.25 s between waves (1.5 s) | new |
| 5 | c | Rapid Vents | 185 |  | −0.3 s between waves (1.2 s) | new |
| 6 | c | Turbo Vents | 290 |  | −0.2 s between waves (1 s) | new |
| M | c | Cold Front | 1575 |  | A constant cold field: everything inside stays slowed | new |

## Shockwave Generator
id: shockwave_generator · class: Assault · weapon: Field · build: 450 cr · status: new · branches: Power/Range (bigger, stronger waves), Speed (more waves), Effect (barrier shatter)
Generates powerful shockwaves by creating small nuclear explosion. "Radioactive fallout? What radioactive fallout?"
Tagline: Blasts that hit every enemy around it, air and ground.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Shockwave Generator | 450 |  | 450 credits; a shockwave every 1.75 s hits every enemy within 100 px for 75 damage; air and ground; no aiming. Armour applies. | new |
| 2 | r1 | Wave Focus | 245 |  | +15 px radius (115). | new |
| 2 | r2 | Containment Coils | 120 |  | +10 damage (85). | new |
| 2 | r3 | Reactor Venting | 150 |  | −0.25 s between waves (1.5 s). | new |
| 3 | a | Hotter Core | 210 |  | +10 damage (85); +5 px radius (105) | new |
| 4 | a | Dense Core | 470 |  | +10 damage (95); +5 px radius (110) | new |
| 5 | a | Critical Mass | 1870 |  | +15 damage (110); +10 px radius (120) | new |
| 6 | a | Overpressure | 3200 |  | +15 damage (125); +5 px radius (125) | new |
| M | a | Megaton Wave | 6690 |  | +10 damage (135); +7 px radius (132) | new |
| 3 | b | Quick Cycle | 115 |  | −0.2 s between waves (1.55 s) | new |
| 4 | b | Fast Cycle | 220 |  | −0.15 s between waves (1.4 s) | new |
| 5 | b | Pulse Core | 980 |  | −0.25 s between waves (1.15 s) | new |
| 6 | b | Rapid Core | 1645 |  | −0.15 s between waves (1 s) | new |
| M | b | Chain Pulse | 6310 |  | −0.2 s between waves (0.8 s) | new |
| 3 | c | Disruptor Wave | 45 |  | ×1.5 damage to barriers | new |
| 4 | c | Harmonic Wave | 55 |  | +0.5 barrier multiplier (×2) | new |
| 5 | c | Resonance | 145 |  | +0.5 barrier multiplier (×2.5) | new |
| 6 | c | Breaker Wave | 290 |  | +0.5 barrier multiplier (×3) | new |
| M | c | Shatter Shock | 1300 |  | Each wave shatters half of every barrier it hits, and barriers it hits can't regenerate for 5 s | new |

## Scrapyard
id: scrapyard · class: Utility · weapon: None · build: 875 cr · status: new · branches: Passive Income, Kill Income (bonus field), Discounts (towers near it)
Various collections of scrap metal sold at a profit. "One mans toxic waste is another mans potpourri"
Tagline: Earns credits every round; its upgrades grow your economy.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Scrapyard | 875 |  | 875 credits; pays 100 credits at each round's clear (× the round's income scale). A 150 px field (used by the Kill and Discount paths). Doesn't attack. | new |
| 2 | r1 | Hammer Mill | 525 |  | +30 income per round (130). | new |
| 2 | r2 | Faster Loading | 260 |  | +30 px to its fields (180): a second conveyor and a second crane feed the furnace. | new |
| 2 | r3 | Surplus | 260 |  | Towers sold within its field refund 15% more (two extra crates of surplus stock). | new |
| 3 | a | Firebrick Lining | 525 |  | +30 income per round (130) | new |
| 4 | a | Forced Bellows | 1225 |  | +35 income per round (165) | new |
| 5 | a | Blast Furnace | 3850 |  | +55 income per round (220) | new |
| 6 | a | Arc Furnace | 7000 |  | +50 income per round (270) | new |
| M | a | Gold Foundry | 27440 |  | +50 income per round (320), plus 3% interest on banked credits at each clear (up to 400) | new |
| 3 | b | Tow Hook | 345 |  | Enemies destroyed in its field pay 15% more; −10 px field (140) | new |
| 4 | b | Magnet Crane | 625 |  | +10% bounty (25%); +10 px field (150) | new |
| 5 | b | Laser Cutter | 2095 |  | +10% bounty (35%); +20 px field (170) | new |
| 6 | b | Car Crusher | 5720 |  | +10% bounty (45%); +20 px field (190) | new |
| M | b | Breaker's Yard | 28945 |  | +15% bounty (60%); +20 px field (210); bosses pay double | new |
| 3 | c | Parts Shelves | 190 |  | Towers in its field upgrade for 5% less; −10 px field (140) | new |
| 4 | c | Pallet Racks | 495 |  | +5% off upgrades (10%); +10 px field (150) | new |
| 5 | c | Forklift Bay | 2035 |  | +5% off upgrades (15%) and 5% off builds; +10 px field (160) | new |
| 6 | c | Loading Dock | 3865 |  | +5% off upgrades (20%); +15 px field (175) | new |
| M | c | Parts Exchange | 20935 |  | +5% off upgrades (25%); +5% off builds (10%); +15 px field (190); towers in the field sell back for everything spent on them | new |

## Magneto Tower
id: magneto_tower · class: Defense · weapon: Field · build: 525 cr · status: new · branches: Pull Strength (stronger slow, heavies too), Field Size, Polarity (strip, then permanent, then repel)
A massive electromagnet that magnetically pulls against enemies in range, slowing them down and pulling off armor. "Yeah, science!"
Tagline: A magnetic field that slows enemies and drags them back.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Magneto Tower | 525 |  | 525 credits; a constant magnetic field of 120 px. Every enemy inside, air and ground, is slowed 25% while inside, scaled by weight. Only the strongest slow on an enemy applies. | new |
| 2 | r1 | Superconducting Coil | 210 |  | +5% slow (30%); the coil frosts over. | new |
| 2 | r2 | Field Stabiliser | 280 |  | +15 px radius (135). | new |
| 2 | r3 | Pole Shoes | 135 |  | Heavy roles resist 30% less. | new |
| 3 | a | Stronger Coil | 295 |  | +7% slow (32%) | new |
| 4 | a | Heavy Grip | 565 |  | +3% slow (35%); heavy roles resist a quarter less | new |
| 5 | a | Mass Lock | 2060 |  | +7% slow (42%); heavy roles resist half as much | new |
| 6 | a | Dense Field | 2450 |  | +6% slow (48%) | new |
| M | a | Absolute Pull | 13630 |  | +7% slow (55%); no role resists: Tanks and bosses are slowed fully | new |
| 3 | b | Wider Coil | 180 |  | +10 px radius (130) | new |
| 4 | b | Field Extender | 395 |  | +10 px radius (140) | new |
| 5 | b | Broad Field | 1290 |  | +15 px radius (155) | new |
| 6 | b | Great Field | 2845 |  | +15 px radius (170) | new |
| M | b | Magnetosphere | 10645 |  | +25 px radius (195) | new |
| 3 | c | Plate Puller | 360 |  | Enemies in the field lose 2 armour while inside | new |
| 4 | c | Plate Ripper | 720 |  | +2 armour pulled (4) | new |
| 5 | c | Torn Plates | 1440 |  | Pulled armour is gone for good, even after they leave | new |
| 6 | c | Deep Pull | 2160 |  | +1 armour pulled (5) | new |
| M | c | Reverse Polarity | 9600 |  | Every 4 s the field flips to repel: enemies are flung into each other for 40 impact damage and a 0.3 s stun | new |

## Tractor Tower
id: tractor_tower · class: Defense · weapon: Energy · build: 575 cr · status: new · branches: Pull Distance, Recharge, Grip
A dish-mounted emitter that locks a tractor beam onto a single enemy and hauls it back down the track before letting go. "You're my friend now."
Tagline: Grabs one enemy and hauls it back along the track.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Tractor Tower | 575 |  | 575 credits; 160 px range; air and ground. It locks one enemy (by its targeting mode), holds it for 1.5 s while hauling it 80 px back along the track, releases it, then recharges for 6 s. While held, the enemy can't move forward, blink or use abilities (a hold counts as a stun for those rules). The pull scales by role weight, as on the Magneto (Swarm full, Tank half, Boss a quarter). | new |
| 2 | r1 | Beam Sweep | 175 |  | While holding, the beam slows every other enemy it crosses by 30%. | new |
| 2 | r2 | Longer Hold | 140 |  | +0.5 s hold (2 s). | new |
| 2 | r3 | Faster Recharge | 230 |  | −1 s recharge (5 s). | new |
| 3 | a | Longer Haul | 185 |  | +20 px pull (100) | new |
| 4 | a | Stronger Beam | 535 |  | +20 px pull (120); +0.3 s hold (1.8 s) | new |
| 5 | a | Rewind | 1840 |  | Sends the enemy back to where it was 3 s ago | new |
| 6 | a | Long Rewind | 2945 |  | +1 s rewind (4 s) | new |
| M | a | Undo | 9215 |  | +1 s rewind (5 s); once per round, sends one non-boss enemy back to the start of its current track segment | new |
| 3 | b | Quick Release | 175 |  | −0.8 s recharge (5.2 s) | new |
| 4 | b | Capacitor Bank | 345 |  | −0.6 s recharge (4.6 s) | new |
| 5 | b | Rapid Lock | 1265 |  | −0.8 s recharge (3.8 s) | new |
| 6 | b | Overclocked Emitter | 2200 |  | −0.5 s recharge (3.3 s) | new |
| M | b | Supercapacitor | 21745 |  | −1.3 s recharge (2 s) | new |
| 3 | c | Firm Grip | 190 |  | Heavy roles resist half as much | new |
| 4 | c | Crushing Grip | 270 |  | The held enemy takes 15 energy damage/s | new |
| 5 | c | Lift and Drop | 1075 |  | Ground enemies are lifted, then slammed down, stunning everything within 50 px for 0.4 s | new |
| 6 | c | Grip Lock | 1610 |  | The held enemy's barrier and abilities switch off while held | new |
| M | c | Gravity Hammer | 5365 |  | +30 px slam (80); +0.4 s stun (0.8 s); the slam shatters barriers | new |

## Augmentation Tower
id: augmentation_tower · class: Support · weapon: None · build: 650 cr · status: new · branches: Energy Conversion, Critical Hits, Ricochet
Neighboring towers are given special augmentations to their weaponry through mysterious means. "So my 12-guage shotgun shoots thermonuclear explosives now apparently."
Tagline: Gives nearby towers a chance of critical hits.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Augmentation Tower | 650 |  | 650 credits; towers within 96 px get a 5% chance to crit (double damage) on every hit. Doesn't attack. | new |
| 2 | r1 | Wide Aura | 170 |  | +48 px radius (144, 3 tiles). | new |
| 2 | r2 | Amplified Bonus | 135 |  | +5% crit chance (10%). | new |
| 2 | r3 | Remote Link | 75 |  | Towers up to twice its radius away get its effects at half strength. | new |
| 3 | a | Charged Rounds | 105 |  | 25% of nearby towers' damage counts as energy | new |
| 4 | a | Plasma Coating | 205 |  | +25% counted as energy (50%) | new |
| 5 | a | Energy Weave | 410 |  | +25% counted as energy (75%) | new |
| 6 | a | Full Conversion | 820 |  | +25% counted as energy (100%): every nearby tower's damage is energy, so even Ballistic and Explosive towers can hurt the Wraith | new |
| M | a | Overcharge | 4375 |  | +10% bonus energy damage | new |
| 3 | b | Targeting Assist | 80 |  | +3% crit chance (8%) | new |
| 4 | b | Weak-Point Scan | 165 |  | +3% crit chance (11%) | new |
| 5 | b | Precision Matrix | 1260 |  | +4% crit chance (15%); +0.5 crit multiplier (×2.5) | new |
| 6 | b | Lethal Matrix | 985 |  | +3% crit chance (18%) | new |
| M | b | Executioner Link | 7440 |  | +4% crit chance (22%); +0.5 crit multiplier (×3) | new |
| 3 | c | Deflector Rounds | 135 |  | 10% of hits bounce to another enemy within 60 px at 50% damage | new |
| 4 | c | Bounce Coating | 275 |  | +10% bounce chance (20%) | new |
| 5 | c | Ricochet Field | 1205 |  | +10% bounce chance (30%); +20% bounce damage (70%) | new |
| 6 | c | Chain Bounce | 1530 |  | +10% bounce chance (40%) | new |
| M | c | Pinball | 7660 |  | +10% bounce chance (50%); a bounce can bounce again | new |
