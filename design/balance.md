# Bastion Line balance master

Every balance number in the game, the math behind them, and the source the game's data is generated from (issue #75,
spec in `design/balance_master.md`). It holds the towers, enemies and modifiers, waves and scaling, the economy, difficulty,
research, abilities and the global rules.

## How to use this file

1. Edit any column whose header doesn't start with `=`: the tower tables' **Cost** and **Tokens** (and the meta line
   above each), and every other table's numbers and `key value` tokens.
2. Run `node tools/balance.mjs`. It writes the numbers into the game's scripts, rewrites every column headed `=` and
   the generated tables, and copies the tower prices into `design/upgrade_trees_rework.md` (the trees page shows them).
3. Run `node tools/tree_rework_data.mjs` to regenerate the game data (`data/rework_trees.gd`).
4. Run `tools/dev.sh check` and `tools/dev.sh test`, then the balance probe to see the effect.

Columns headed `=` are generated: an edit there is overwritten on the next run. Names and blurbs stay in
`design/upgrade_trees_rework.md`. `tools/dev.sh check` fails if this file or the game data is out of date.

## Formulas

**Tower nodes.** A node's tokens are separated by ` · `. A token is `key value`: the stock (`base`) row sets each stat
(`16`, `0.5`); every upgrade **adds** to it (owner, 2026-10-23, #85), so its values carry a sign (`+20`, `-0.5`) and a
plain number on an upgrade row fails the tool. A bare `key` is a flag. A stat the stock row doesn't set counts from 0.
In the game a tower applies its stock node, then its Retrofit if bought, then each path's steps in order (a secondary
path only its first 2 steps), each adding on top, so a Retrofit and a secondary path stack with the primary. Stat keys are listed in `tools/balance_lib.mjs` (KEYS); an unknown key fails the
tool, so typos can't slip in.

**=Spent** is the credits from a new tower to that node: the stock price, plus the Retrofit's price on a Retrofit row,
or every step of that path up to it. Prices are base prices; a mode multiplies every build and upgrade price.

**=DPS** is the paper damage per second of the main attack over every target it hits, with no armour, splash, crits,
burns or boosts, at that node (a Retrofit on the stock tower; a path's steps on the stock tower):

- most towers: damage × rate × shots, where shots is
  - Rocket Salvo: missiles (each rocket at its own target);
  - Tesla Tower: the chain, 1 + keep + keep² + ... over 1 + jumps hits, keep = 1 - falloff (0.15 unless set);
  - Gun Turret: multishot when above 1, otherwise 1 + side_gun (the side gun's share of damage);
  - Drone Bay: drones;
  - otherwise 1 (the rate is already the total over tubes or barrels);
- Laser Tower: damage × ramp (its beams at full ramp) × (1 + beam_power × (beams - 1)), beam_power 0.4 unless set;
- CAS Gunship: damage × rate (light gun) + ac_damage × ac_rate + ms_damage × ms_rate × (ms_volley + 2) / 3 (a volley
  every third missile pulse);
- support, economy and control towers without damage show `-`.

Worked example, Gun Turret, path C at Twin Mount (c3): stock damage 16 and rate 1.2, c1 adds nothing to them, c2 sets
side_gun 0.5, c3 sets multishot 2 and side_gun 0, so =DPS = 16 × 1.2 × 2 = 38.4.

**=DPS/100cr** is =DPS divided by =Spent, times 100: damage per second per 100 credits spent.

**=Strength** (enemies) = (speed / 100)² × max(1, armor) × health, from round-1 stats. It orders Strongest targeting
(every boss above every non-boss) and sets the leak cost.

**Round table** (Waves): **=HP ×** as above; **=Speed ×** = 1 + min(SPEED_CAP, SPEED_PER_ROUND × w) (bosses get
BOSS_SPEED_SHARE of the bonus); **=Budget** = BUDGET_BASE + BUDGET_LINEAR·w + BUDGET_QUAD·w²; **=Elite share** = 0 before
ELITE_FROM, then ELITE_START + ELITE_RISE × (round - ELITE_FROM) / (ELITE_FULL_AT - ELITE_FROM), capped; **=Bounty ×** =
HP multiplier^bounty_exp; **=Clear bonus** = CLEAR_BASE + CLEAR_PER_ROUND × round; **=Early-call bonus** = CALL_BASE +
CALL_PER_ROUND × round.

**=Leak** = 1 shield below the first leak band, 2 below the second, 3 below the third, else 4; a boss costs the first
round it appears in a boss line-up (Waves). An elite costs one shield more in the game.

**=HP rN** = health × the round's HP multiplier (Waves: 1 + HP_LINEAR·w + HP_QUAD·w², w = round - 1, then
× (1 + late_growth)^(round - LATE_START) past LATE_START). **=Credits rN** = bounty × HP multiplier^bounty_exp.

Worked example, Drone at round 100: w = 99, multiplier = (1 + 0.05×99 + 0.0012×99²) × 1.01^40 = 17.71 × 1.489 = 26.37;
=HP r100 = 70 × 26.37 = 1,846.

## Towers

The summary lists each tower's stock price and =DPS, and what each path's mastery costs from a new tower and deals.

<!-- generated: tower_summary -->

| Tower | Stock cr | Stock =DPS | A mastery: cr / =DPS | B mastery: cr / =DPS | C mastery: cr / =DPS |
|---|---|---|---|---|---|
| Gun Turret | 75 | 19.2 | 5745 / 69.6 | 1615 / 19.2 | 6095 / 91.2 |
| Mortar Tower | 150 | 18.0 | 5500 / 38.4 | 9065 / 51.0 | 7580 / 18.0 |
| Rocket Salvo | 200 | 22.8 | 8400 / 55.2 | 3875 / 22.8 | 9955 / 89.4 |
| Laser Tower | 250 | 75.0 | 8145 / 200.0 | 8980 / 243.8 | 3705 / 75.0 |
| Anti-Aircraft Turret | 150 | 62.5 | 2665 / 62.5 | 6580 / 105.0 | 5040 / 175.0 |
| Artillery Cannon | 300 | 18.8 | 11635 / 35.0 | 7910 / 17.8 | 11175 / 18.8 |
| Railgun | 500 | 36.0 | 14970 / 84.8 | 10425 / 75.0 | 12960 / 36.0 |
| Tesla Tower | 250 | 81.6 | 7510 / 183.5 | 13265 / 124.2 | 7405 / 214.1 |
| Drone Bay | 300 | 48.0 | 7050 / 126.0 | 4995 / 48.0 | 6520 / 112.0 |
| CAS Gunship | 650 | 60.0 | 10315 / 171.0 | 14080 / 187.6 | 21040 / 186.7 |
| Mine Layer | 450 | 56.7 | 10270 / 100.1 | 8925 / 121.4 | 8395 / 56.7 |
| Chemical Plant | 250 | - | 10500 / - | 10710 / - | 5500 / - |
| Cryo Tower | 150 | - | 13550 / - | 6840 / 18.0 | 2290 / - |
| Boost Tower | 400 | - | 18120 / - | 18120 / - | 11035 / - |
| Radar Tower | 575 | - | 12585 / - | 18375 / - | 9175 / - |
| Shockwave Generator | 450 | 42.8 | 12890 / 77.1 | 9720 / 93.8 | 2285 / 42.8 |
| Scrapyard | 875 | - | 40915 / - | 38605 / - | 28395 / - |
| Magneto Tower | 525 | - | 19525 / - | 15880 / - | 14805 / - |
| Tractor Tower | 575 | - | 15295 / - | 26305 / - | 9085 / - |
| Augmentation Tower | 650 | - | 6565 / - | 10580 / - | 11455 / - |

<!-- /generated: tower_summary -->

### gun_turret

air: yes · ground: yes · size: 1 · damage_kind: physical

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Gun Turret | 75 | damage 16 · range 130 · rate 1.2 · proj_speed 800 | 19.2 | 75 | 25.60 |
| r1 | Water-Cooled Barrel | 40 | rate +0.3 | 24.0 | 115 | 20.87 |
| r2 | Shock Rounds | 5 | stun_chance +0.05 · stun_time +0.3 | 19.2 | 80 | 24.00 |
| r3 | Incendiary Rounds | 25 | ignite_dps +3 · ignite_time +2 | 19.2 | 100 | 19.20 |
| a1 | Heavier Rounds | 55 | damage +6 | 26.4 | 130 | 20.31 |
| a2 | Hardened Tips | 165 | armor_flat +2 · damage +6 | 33.6 | 295 | 11.39 |
| a3 | AP Rounds | 530 | armor_pct +0.5 · damage +8 | 43.2 | 825 | 5.24 |
| a4 | Tungsten Core | 1365 | armor_pct +0.25 · damage +10 | 55.2 | 2190 | 2.52 |
| am | Sabot Rounds | 3555 | armor_pct +0.25 · damage +12 | 69.6 | 5745 | 1.21 |
| b1 | Long Barrel | 25 | range +20 | 19.2 | 100 | 19.20 |
| b2 | Tracer Rounds | 60 | range +10 · crit +0.1 · tracers | 19.2 | 160 | 12.00 |
| b3 | Rifled Barrels | 170 | range +25 · crit +0.05 | 19.2 | 330 | 5.82 |
| b4 | Rangefinder | 305 | range +20 · crit +0.05 | 19.2 | 635 | 3.02 |
| bm | Targeting Computer | 980 | range +25 · crit +0.1 | 19.2 | 1615 | 1.19 |
| c1 | Swivel Mount | 30 | swivel · rate +0.1 | 20.8 | 105 | 19.81 |
| c2 | Side Gun | 220 | side_gun +0.5 · rate +0.1 | 33.6 | 325 | 10.34 |
| c3 | Twin Mount | 495 | multishot +2 · side_gun -0.5 · rate +0.1 | 48.0 | 820 | 5.85 |
| c4 | Belt Feed | 660 | rate +0.3 | 57.6 | 1480 | 3.89 |
| cm | Triple Mount | 4615 | multishot +1 · weakest_extra · rate +0.1 | 91.2 | 6095 | 1.50 |

### mortar_tower

air: no · ground: yes · size: 1 · damage_kind: physical

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Mortar Tower | 150 | damage 30 · splash 60 · range 110 · rate 0.6 · proj_speed 420 | 18.0 | 150 | 12.00 |
| r1 | Field Kit | 120 | damage +4 · range +10 · rate +0.05 · splash +5 | 22.1 | 270 | 8.19 |
| r2 | Bunker Sight | 15 | burrow_sight +0.5 | 18.0 | 165 | 10.91 |
| r3 | Smoke Shells | 15 | smoke_every +4 · smoke_slow +0.15 · smoke_time +3 | 18.0 | 165 | 10.91 |
| a1 | HE Charge | 80 | damage +8 | 22.8 | 230 | 9.91 |
| a2 | Shaped Charge | 95 | armor_pct +0.25 | 22.8 | 325 | 7.02 |
| a3 | AP Shells | 685 | armor_pct +0.25 · damage +10 | 28.8 | 1010 | 2.85 |
| a4 | Delayed Fuse | 1350 | armor_pct +0.25 · damage +8 | 33.6 | 2360 | 1.42 |
| am | Bunker Buster | 3140 | damage +8 · burrow_sight +1 | 38.4 | 5500 | 0.70 |
| b1 | Quick Reload | 50 | rate +0.1 | 21.0 | 200 | 10.50 |
| b2 | Extended Tube | 125 | range +20 | 21.0 | 325 | 6.46 |
| b3 | Twin Tubes | 1170 | tubes +2 · rate +0.5 | 36.0 | 1495 | 2.41 |
| b4 | Long Tubes | 1405 | range +20 · rate +0.1 | 39.0 | 2900 | 1.34 |
| bm | Barrage Battery | 6165 | tubes +1 · rate +0.4 · range +15 | 51.0 | 9065 | 0.56 |
| c1 | Bigger Charge | 30 | splash +10 | 18.0 | 180 | 10.00 |
| c2 | Wide Burst | 60 | splash +10 | 18.0 | 240 | 7.50 |
| c3 | Cluster Shells | 1110 | bomblets +4 · bomblet_damage +10 · bomblet_splash +30 | 18.0 | 1350 | 1.33 |
| c4 | Dense Cluster | 1230 | bomblets +2 · splash +5 | 18.0 | 2580 | 0.70 |
| cm | Carpet Shells | 5000 | bomblets +2 · bomblet_damage +2 · bomblet_splash +5 · bomblet_spread +1 · splash +5 | 18.0 | 7580 | 0.24 |

### rocket_salvo

air: yes · ground: yes · size: 1 · damage_kind: physical

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Rocket Salvo | 200 | damage 19 · splash 25 · range 180 · rate 0.4 · missiles 3 · proj_speed 330 | 22.8 | 200 | 11.40 |
| r1 | Proximity Fuses | 40 | air_mult +1.4 | 22.8 | 240 | 9.50 |
| r2 | Smoke Trails | 20 | smoke_slow +0.1 · smoke_time +2 | 22.8 | 220 | 10.36 |
| r3 | Incendiary Warheads | 125 | ground_burn +3 · ground_burn_time +2 | 22.8 | 325 | 7.02 |
| a1 | HE Warheads | 105 | damage +5 | 28.8 | 305 | 9.44 |
| a2 | Wider Burst | 155 | splash +10 | 28.8 | 460 | 6.26 |
| a3 | Heavy Warheads | 985 | damage +8 · splash +5 | 38.4 | 1445 | 2.66 |
| a4 | Dense Payload | 1245 | damage +6 | 45.6 | 2690 | 1.70 |
| am | Thermobaric Rockets | 5710 | damage +8 · splash +10 | 55.2 | 8400 | 0.66 |
| b1 | Booster Stage | 45 | range +20 | 22.8 | 245 | 9.31 |
| b2 | Seeker Heads | 135 | homing | 22.8 | 380 | 6.00 |
| b3 | Smart Seekers | 510 | retarget · range +30 | 22.8 | 890 | 2.56 |
| b4 | Long Burn | 670 | range +30 | 22.8 | 1560 | 1.46 |
| bm | Hunter Seekers | 2315 | range +40 · never_miss | 22.8 | 3875 | 0.59 |
| c1 | Extra Tube | 135 | missiles +1 | 30.4 | 335 | 9.07 |
| c2 | Quick Loader | 265 | rate +0.1 | 38.0 | 600 | 6.33 |
| c3 | Six-Pack | 1335 | missiles +2 | 57.0 | 1935 | 2.95 |
| c4 | Auto-Loader | 1605 | rate +0.088 | 67.0 | 3540 | 1.89 |
| cm | Ripple Salvo | 6415 | missiles +2 · ripple | 89.4 | 9955 | 0.90 |

### laser_tower

air: yes · ground: yes · size: 1 · damage_kind: energy · beam: yes

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Laser Tower | 250 | damage 25 · range 150 · ramp 3 · ramp_time 3 · melt 1 · beams 1 · beam_power 0.4 | 75.0 | 250 | 30.00 |
| r1 | Capacitor Bank | 160 | damage +8 | 99.0 | 410 | 24.15 |
| r2 | Heat Sinks | 60 | ramp +0.5 | 87.5 | 310 | 28.23 |
| r3 | Ramp Memory | 55 | ramp_keep +0.5 | 75.0 | 305 | 24.59 |
| a1 | Hotter Emitter | 60 | ramp +0.5 | 87.5 | 310 | 28.23 |
| a2 | Quick Focus | 60 | ramp_time -0.8 | 87.5 | 370 | 23.65 |
| a3 | Overdrive | 815 | ramp +1.5 | 125.0 | 1185 | 10.55 |
| a4 | Thermal Lock | 1425 | ramp +1 · ramp_time -0.4 | 150.0 | 2610 | 5.75 |
| am | Annihilator | 5535 | ramp +2 · ramp_time -0.3 | 200.0 | 8145 | 2.46 |
| b1 | Beam Splitter | 200 | beams +1 | 105.0 | 450 | 23.33 |
| b2 | Tuned Splitter | 200 | beam_power +0.2 | 120.0 | 650 | 18.46 |
| b3 | Prism | 1190 | beams +1 | 165.0 | 1840 | 8.97 |
| b4 | Clear Prism | 1190 | beam_power +0.15 | 187.5 | 3030 | 6.19 |
| bm | Prism Array | 5950 | beams +1 | 243.8 | 8980 | 2.71 |
| c1 | Extended Optics | 50 | range +15 | 75.0 | 300 | 25.00 |
| c2 | Collimator | 100 | range +15 | 75.0 | 400 | 18.75 |
| c3 | Lance | 395 | range +30 | 75.0 | 795 | 9.43 |
| c4 | Long Lance | 795 | range +30 | 75.0 | 1590 | 4.72 |
| cm | Deep Lance | 2115 | range +40 | 75.0 | 3705 | 2.02 |

### anti_aircraft_turret

air: yes · ground: no · size: 1 · damage_kind: physical

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Anti-Aircraft Turret | 150 | damage 25 · range 160 · rate 2.5 · proj_speed 900 | 62.5 | 150 | 41.67 |
| r1 | Fire-Control Radar | 45 | range +15 | 62.5 | 195 | 32.05 |
| r2 | Ammo Drum | 30 | rate +0.25 | 68.8 | 180 | 38.19 |
| r3 | Armoured Mount | 50 | damage +4 | 72.5 | 200 | 36.25 |
| a1 | Long Barrel | 40 | range +20 | 62.5 | 190 | 32.89 |
| a2 | Higher Mount | 75 | range +20 | 62.5 | 265 | 23.58 |
| a3 | Sky Watch | 300 | range +40 | 62.5 | 565 | 11.06 |
| a4 | High-Velocity Rounds | 600 | range +40 | 62.5 | 1165 | 5.36 |
| am | Sky Wall | 1500 | range +50 | 62.5 | 2665 | 2.35 |
| b1 | Heavier Rounds | 70 | damage +6 | 77.5 | 220 | 35.23 |
| b2 | Flak Rounds | 375 | burst +20 | 77.5 | 595 | 13.03 |
| b3 | Flak Shells | 795 | damage +5 · burst +10 | 90.0 | 1390 | 6.47 |
| b4 | Wide Burst | 865 | burst +10 | 90.0 | 2255 | 3.99 |
| bm | Flak Curtain | 4325 | damage +6 · burst +10 | 105.0 | 6580 | 1.60 |
| c1 | Quick Cycle | 35 | rate +0.3 | 70.0 | 185 | 37.84 |
| c2 | Fast Traverse | 95 | rate +0.4 · turn_fast | 80.0 | 280 | 28.57 |
| c3 | Twin Barrels | 625 | rate +1.3 · barrels +2 | 112.5 | 905 | 12.43 |
| c4 | Belt Feed | 675 | rate +0.7 | 130.0 | 1580 | 8.23 |
| cm | Quad Mount | 3460 | rate +1.8 · barrels +2 | 175.0 | 5040 | 3.47 |

### artillery_cannon

air: no · ground: yes · size: 1 · damage_kind: physical

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Artillery Cannon | 300 | damage 75 · splash 70 · rate 0.25 · flight 1.5 · scatter 30 · burn_dps 15 · burn_time 3 · shrap_radius 40 · shrap_mult 0.7 · stun_time 0.5 | 18.8 | 300 | 6.25 |
| r1 | Shell Magazine | 120 | heavy_every +3 | 18.8 | 420 | 4.46 |
| r2 | Stabilised Mount | 120 | scatter -15 | 18.8 | 420 | 4.46 |
| r3 | Wide Charge | 80 | splash +15 | 18.8 | 380 | 4.93 |
| a1 | Heavy Shells | 120 | damage +15 | 22.5 | 420 | 5.36 |
| a2 | Wide Bursting Charge | 200 | splash +15 | 22.5 | 620 | 3.63 |
| a3 | HE Shells | 730 | damage +20 | 27.5 | 1350 | 2.04 |
| a4 | Penetrator Shells | 2930 | damage +10 · armor_pct +0.5 | 30.0 | 4280 | 0.70 |
| am | Siege Shells | 7355 | damage +20 · splash +5 · armor_pct +0.25 | 35.0 | 11635 | 0.30 |
| b1 | Drilled Crew | 120 | rate +0.053 | 22.7 | 420 | 5.41 |
| b2 | Quick Breech | 240 | rate +0.042 | 25.9 | 660 | 3.92 |
| b3 | Autoloader | 1450 | rate +0.155 | 37.5 | 2110 | 1.78 |
| b4 | Rapid Breech | 1935 | rate +0.088 | 44.1 | 4045 | 1.09 |
| bm | Rolling Barrage | 3865 | rate -0.35 · barrage +3 | 17.8 | 7910 | 0.23 |
| c1 | Incendiary Shells | 365 | incendiary | 18.8 | 665 | 2.82 |
| c2 | Shrapnel Shells | 195 | shrapnel | 18.8 | 860 | 2.18 |
| c3 | Concussion Shells | 1085 | concussion | 18.8 | 1945 | 0.96 |
| c4 | Improved Payloads | 3505 | burn_dps +7 · shrap_mult +0.15 · stun_time +0.2 | 18.8 | 5450 | 0.34 |
| cm | Combined Payload | 5725 | combined | 18.8 | 11175 | 0.17 |

### railgun

air: yes · ground: yes · size: 1 · damage_kind: physical

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Railgun | 500 | damage 90 · range 380 · rate 0.4 · falloff 0.4 | 36.0 | 500 | 7.20 |
| r1 | Capacitor Coils | 140 | rate +0.0545 | 40.9 | 640 | 6.39 |
| r2 | Longer Rails | 265 | damage +15 · range +30 | 42.0 | 765 | 5.49 |
| r3 | Penetrator Tips | 65 | falloff -0.1 | 36.0 | 565 | 6.37 |
| a1 | Dense Slugs | 345 | damage +30 | 48.0 | 845 | 5.68 |
| a2 | Boss Rounds | 275 | boss_mult +1.5 | 48.0 | 1120 | 4.29 |
| a3 | Overcharge | 2260 | damage +80 · rate -0.067 | 66.6 | 3380 | 1.97 |
| a4 | Kill Charge | 5125 | damage +40 · boss_mult +0.5 | 79.9 | 8505 | 0.94 |
| am | Kingslayer | 6465 | damage +40 · rate -0.03 · boss_mult +0.5 | 84.8 | 14970 | 0.57 |
| b1 | Fast Capacitors | 140 | rate +0.0545 | 40.9 | 640 | 6.39 |
| b2 | Extended Rails | 245 | range +40 | 40.9 | 885 | 4.62 |
| b3 | Rapid Capacitors | 1930 | rate +0.1705 | 56.3 | 2815 | 2.00 |
| b4 | Supercapacitors | 2610 | rate +0.116 | 66.7 | 5425 | 1.23 |
| bm | Twin Rails | 5000 | rate +0.092 · rails +2 | 75.0 | 10425 | 0.72 |
| c1 | Shatter Rounds | 60 | shatter +2 | 36.0 | 560 | 6.43 |
| c2 | Penetrator Core | 260 | falloff -0.15 | 36.0 | 820 | 4.39 |
| c3 | Ionised Trail | 1535 | trail_dps +30 · trail_time +2 | 36.0 | 2355 | 1.53 |
| c4 | Hot Rail | 3685 | shatter +2 · trail_dps +15 · falloff -0.1 | 36.0 | 6040 | 0.60 |
| cm | Ion Cannon | 6920 | shatter +2 · trail_dps +5 · falloff -0.15 | 36.0 | 12960 | 0.28 |

### tesla_tower

air: yes · ground: yes · size: 1 · damage_kind: energy

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Tesla Tower | 250 | damage 32 · range 140 · rate 0.8 · jumps 3 · jump_range 70 · falloff 0.15 | 81.6 | 250 | 32.63 |
| r1 | Bigger Disk | 120 | damage +4 · range +15 | 91.8 | 370 | 24.80 |
| r2 | Grounding Rods | 65 | jumps +1 | 94.9 | 315 | 30.14 |
| r3 | Insulated Coils | 70 | rate +0.109 | 92.7 | 320 | 28.97 |
| a1 | High Voltage | 125 | damage +8 | 102.0 | 375 | 27.19 |
| a2 | Overload Circuits | 100 | overload | 102.0 | 475 | 21.47 |
| a3 | Arc Stun | 1020 | damage +8 · stun_time +0.3 | 122.4 | 1495 | 8.19 |
| a4 | Clean Conduction | 1705 | damage +6 · falloff -0.07 | 153.1 | 3200 | 4.79 |
| am | Lightning Rod | 4310 | damage +6 · falloff -0.05 · stun_time +0.2 | 183.5 | 7510 | 2.44 |
| b1 | Taller Coil | 70 | range +20 | 81.6 | 320 | 25.49 |
| b2 | Extra Jump | 155 | jumps +1 | 94.9 | 475 | 19.99 |
| b3 | Storm Field | 2260 | jumps +1 · storm_radius +25 · storm_dps +10 · storm_time +2 | 106.3 | 2735 | 3.89 |
| b4 | Wide Storm | 2390 | range +20 · jumps +1 | 116.0 | 5125 | 2.26 |
| bm | Tempest | 8140 | jumps +1 · storm_radius +5 · storm_dps +4 | 124.2 | 13265 | 0.94 |
| c1 | Quick Recharge | 60 | rate +0.1 | 91.8 | 310 | 29.60 |
| c2 | Fast Capacitor | 125 | rate +0.1 | 102.0 | 435 | 23.44 |
| c3 | Rapid Discharge | 995 | rate +0.4 | 142.8 | 1430 | 9.98 |
| c4 | Overclocked Coil | 995 | rate +0.2 | 163.2 | 2425 | 6.73 |
| cm | Continuous Discharge | 4980 | rate +0.5 | 214.1 | 7405 | 2.89 |

### drone_bay

air: yes · ground: yes · size: 2 · damage_kind: physical

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Drone Bay | 300 | damage 16 · rate 3 · drones 1 | 48.0 | 300 | 16.00 |
| r1 | Second Hangar | 3200 | drones +1 | 96.0 | 3500 | 2.74 |
| a1 | Heavier Guns | 150 | damage +4 | 60.0 | 450 | 13.33 |
| a2 | Hot Loads | 300 | damage +4 | 72.0 | 750 | 9.60 |
| a3 | Combat Firmware | 900 | damage +6 | 90.0 | 1650 | 5.45 |
| a4 | Assault Frames | 1800 | damage +6 | 108.0 | 3450 | 3.13 |
| am | Elite Drones | 3600 | damage +6 | 126.0 | 7050 | 1.79 |
| b1 | Micro-Missiles | 60 | lo_missiles | 48.0 | 360 | 13.33 |
| b2 | Bomb Racks | 120 | lo_bombs | 48.0 | 480 | 10.00 |
| b3 | Drone Laser | 290 | lo_laser | 48.0 | 770 | 6.23 |
| b4 | Upgraded Loadouts | 865 | loadout_mult +1.25 | 48.0 | 1635 | 2.94 |
| bm | Full Kit | 3360 | lo_full | 48.0 | 4995 | 0.96 |
| c1 | Fast Cycling | 100 | rate +0.5 | 56.0 | 400 | 14.00 |
| c2 | Twin Feed | 200 | rate +0.5 | 64.0 | 600 | 10.67 |
| c3 | Rotary Guns | 800 | rate +1 | 80.0 | 1400 | 5.71 |
| c4 | Overclocked Feed | 1280 | rate +0.8 | 92.8 | 2680 | 3.46 |
| cm | Storm Drones | 3840 | rate +1.2 | 112.0 | 6520 | 1.72 |

### cas_gunship

air: yes · ground: yes · size: 1 · damage_kind: physical · uncapped: yes

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | CAS Gunship | 650 | damage 12 · rate 5 · orbit 90 | 60.0 | 650 | 9.23 |
| r1 | Radar | 35 | radar | 60.0 | 685 | 8.76 |
| r2 | Extra Ammo | 70 | rate_mult +1.1 | 60.0 | 720 | 8.33 |
| r3 | Wide Orbit | 195 | orbit +25 | 60.0 | 845 | 7.10 |
| a1 | Heavier Rounds | 175 | damage +3 | 75.0 | 825 | 9.09 |
| a2 | Faster Spin | 350 | rate +1 | 90.0 | 1175 | 7.66 |
| a3 | Hardened Rounds | 1125 | damage +4 | 114.0 | 2300 | 4.96 |
| a4 | Overdrive Motor | 2670 | rate +1.5 | 142.5 | 4970 | 2.87 |
| am | Twin Gatlings | 5345 | rate +1.5 | 171.0 | 10315 | 1.66 |
| b1 | Autocannon | 1145 | ac_damage +40 · ac_rate +1.5 · ac_splash +25 | 120.0 | 1795 | 6.69 |
| b2 | Faster Feed | 455 | ac_rate +0.3 | 132.0 | 2250 | 5.87 |
| b3 | HE Rounds | 1645 | ac_damage +12 | 153.6 | 3895 | 3.94 |
| b4 | Twin Feed | 3170 | ac_rate +0.4 | 174.4 | 7065 | 2.47 |
| bm | Autocannon Battery | 7015 | ac_damage +6 · ac_splash +5 | 187.6 | 14080 | 1.33 |
| c1 | Missile Rack | 1235 | ms_damage +150 · ms_rate +0.333 · ms_splash +45 | 110.0 | 1885 | 5.83 |
| c2 | Quick Rack | 525 | ms_rate +0.067 | 120.0 | 2410 | 4.98 |
| c3 | Heavy Warheads | 1595 | ms_damage +40 | 136.0 | 4005 | 3.40 |
| c4 | Auto-Rack | 3785 | ms_rate +0.1 | 155.0 | 7790 | 1.99 |
| cm | Hellfire Volley | 13250 | ms_volley +2 | 186.7 | 21040 | 0.89 |

### mine_layer

air: no · ground: yes · size: 1 · damage_kind: physical

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Mine Layer | 450 | damage 85 · splash 40 · range 120 · rate 0.667 · cap 20 | 56.7 | 450 | 12.60 |
| r1 | Adhesive Mines | 40 | gel_slow +0.2 · gel_time +2 | 56.7 | 490 | 11.57 |
| r2 | Shaped Charges | 160 | damage +15 | 66.7 | 610 | 10.93 |
| r3 | Long Arm | 150 | range +20 | 56.7 | 600 | 9.45 |
| a1 | Heavier Charge | 160 | damage +15 | 66.7 | 610 | 10.93 |
| a2 | Wider Charge | 265 | splash +10 | 66.7 | 875 | 7.62 |
| a3 | HE Mines | 1190 | damage +25 | 83.4 | 2065 | 4.04 |
| a4 | Fragmentation Casing | 1325 | splash +10 | 83.4 | 3390 | 2.46 |
| am | Anti-Tank Mines | 6880 | damage +25 · splash +5 | 100.1 | 10270 | 0.97 |
| b1 | Quick Assembly | 110 | rate +0.085 · cap +4 | 63.9 | 560 | 11.41 |
| b2 | Twin Press | 270 | rate +0.081 · cap +4 | 70.8 | 830 | 8.53 |
| b3 | Assembly Line | 1080 | rate +0.22 · cap +4 | 89.5 | 1910 | 4.69 |
| b4 | Rapid Line | 1620 | rate +0.123 · cap +4 | 100.0 | 3530 | 2.83 |
| bm | Mine Factory | 5395 | rate +0.2526 · cap +9 | 121.4 | 8925 | 1.36 |
| c1 | Longer Arm | 150 | range +20 | 56.7 | 600 | 9.45 |
| c2 | Spring Launcher | 300 | range +20 | 56.7 | 900 | 6.30 |
| c3 | Mine Mortar | 900 | range +30 | 56.7 | 1800 | 3.15 |
| c4 | Long Mortar | 1800 | range +30 | 56.7 | 3600 | 1.57 |
| cm | Minefield Launcher | 4795 | range +40 | 56.7 | 8395 | 0.68 |

### chemical_plant

air: yes · ground: yes · size: 1 · damage_kind: energy

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Chemical Plant | 250 | range 130 · rate 0.667 · soak_time 4 · armor_strip 3 · nozzles 1 | - | 250 | - |
| r1 | Pressure Pump | 150 | rate +0.083 · range +20 | - | 400 | - |
| r2 | Mist Nozzle | 300 | mist | - | 550 | - |
| r3 | Bigger Tanks | 60 | soak_time +1 | - | 310 | - |
| a1 | Corrosive Acid | 250 | acid_perm | - | 500 | - |
| a2 | Etching Acid | 665 | armor_strip +1 · acid_dps +5 | - | 1165 | - |
| a3 | Fast-Acting Acid | 1335 | armor_strip +1 · acid_dps +5 | - | 2500 | - |
| a4 | Concentrated Acid | 2665 | armor_strip +1 · acid_dps +5 | - | 5165 | - |
| am | Dissolver | 5335 | armor_strip +1 · acid_dps +5 | - | 10500 | - |
| b1 | Quick Valve | 100 | rate +0.133 | - | 350 | - |
| b2 | Long-Lasting Mix | 140 | soak_time +1 | - | 490 | - |
| b3 | Twin Valves | 990 | rate +0.2 · soak_time +1 | - | 1480 | - |
| b4 | High-Flow Pump | 1470 | rate +0.2 | - | 2950 | - |
| bm | Twin Nozzles | 7760 | rate -0.4 · nozzles +1 · soak_time +1 | - | 10710 | - |
| c1 | Sticky Gel | 250 | gel_slow +0.15 | - | 500 | - |
| c2 | Thick Gel | 335 | gel_slow +0.1 | - | 835 | - |
| c3 | Glue | 665 | gel_slow +0.1 | - | 1500 | - |
| c4 | Setting Glue | 1335 | gel_slow +0.1 | - | 2835 | - |
| cm | Quick-Set Foam | 2665 | gel_slow +0.1 | - | 5500 | - |

### cryo_tower

air: yes · ground: yes · size: 1 · damage_kind: energy

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Cryo Tower | 150 | range 110 · rate 0.5 · slow 0.2 · slow_time 1.5 | - | 150 | - |
| r1 | Coolant Tank | 80 | slow_time +0.7 | - | 230 | - |
| r2 | Compressor | 35 | rate +0.088 | - | 185 | - |
| r3 | Deep Cold | 75 | slow +0.05 | - | 225 | - |
| a1 | Colder Gas | 120 | slow +0.08 | - | 270 | - |
| a2 | Sub-Zero Gas | 210 | slow +0.07 | - | 480 | - |
| a3 | Permafrost | 1705 | perm_slow +0.1 | - | 2185 | - |
| a4 | Deep Chill | 2905 | slow +0.1 · perm_slow +0.05 | - | 5090 | - |
| am | Deep Freeze | 8460 | slow +0.05 · perm_slow +0.05 · freeze_every +4 · freeze_time +1 | - | 13550 | - |
| b1 | Frostbite | 105 | damage +5 · range +10 | 2.5 | 255 | 0.98 |
| b2 | Hard Frost | 230 | damage +5 · range +10 | 5.0 | 485 | 1.03 |
| b3 | Ice Storm | 790 | damage +8 · range +15 | 9.0 | 1275 | 0.71 |
| b4 | Biting Cold | 695 | damage +8 | 13.0 | 1970 | 0.66 |
| bm | Blizzard | 4870 | damage +10 · range +20 | 18.0 | 6840 | 0.26 |
| c1 | Faster Vents | 25 | rate +0.071 | - | 175 | - |
| c2 | Pressurised Gas | 65 | rate +0.096 | - | 240 | - |
| c3 | Rapid Vents | 185 | rate +0.166 | - | 425 | - |
| c4 | Turbo Vents | 290 | rate +0.167 | - | 715 | - |
| cm | Cold Front | 1575 | cold_front | - | 2290 | - |

### boost_tower

air: yes · ground: yes · size: 1 · damage_kind: physical · support: yes

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Boost Tower | 400 | range 144 · buff_dmg 0.05 · buff_rate 0.05 · buff_range 0.05 | - | 400 | - |
| r1 | Signal Booster | 1380 | range +24 · buff_extra +0.05 | - | 1780 | - |
| r2 | Crit Link | 185 | crit_link +0.03 | - | 585 | - |
| r3 | Wide Mast | 625 | range +48 | - | 1025 | - |
| a1 | Amplifier | 615 | buff_dmg +0.1 | - | 1015 | - |
| a2 | Power Relay | 860 | buff_dmg +0.07 | - | 1875 | - |
| a3 | Overcharge Link | 2460 | buff_dmg +0.1 | - | 4335 | - |
| a4 | Surge Link | 3940 | buff_dmg +0.08 | - | 8275 | - |
| am | Battle Network | 9845 | buff_dmg +0.1 | - | 18120 | - |
| b1 | Clock Sync | 615 | buff_rate +0.1 | - | 1015 | - |
| b2 | Fast Sync | 860 | buff_rate +0.07 | - | 1875 | - |
| b3 | Overclock Link | 2460 | buff_rate +0.1 | - | 4335 | - |
| b4 | Turbo Link | 3940 | buff_rate +0.08 | - | 8275 | - |
| bm | Rapid Network | 9845 | buff_rate +0.1 | - | 18120 | - |
| c1 | Spotting Relay | 370 | buff_range +0.1 | - | 770 | - |
| c2 | Wide Relay | 515 | buff_range +0.07 | - | 1285 | - |
| c3 | Targeting Link | 1475 | buff_range +0.1 | - | 2760 | - |
| c4 | Long Link | 2365 | buff_range +0.08 | - | 5125 | - |
| cm | Overwatch Network | 5910 | buff_range +0.1 | - | 11035 | - |

### radar_tower

air: yes · ground: yes · size: 1 · damage_kind: energy

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Radar Tower | 575 | range 160 · ping_every 3 · reveal_time 1 | - | 575 | - |
| r1 | Bigger Dish | 305 | range +20 | - | 880 | - |
| r2 | Signal Processor | 575 | reveal_time +0.5 | - | 1150 | - |
| r3 | Early Warning | 230 | early_warning | - | 805 | - |
| a1 | Bigger Array | 305 | range +20 | - | 880 | - |
| a2 | Tall Mast | 685 | range +20 | - | 1565 | - |
| a3 | Radiation Emitter | 585 | rad_dps +15 · rad_range +60 | - | 2150 | - |
| a4 | High-Power Emitter | 3995 | range +20 · rad_dps +10 · rad_range +10 | - | 6145 | - |
| am | Microwave Array | 6440 | range +10 · rad_dps +15 · rad_range +10 | - | 12585 | - |
| b1 | Faster Sweep | 255 | ping_every -0.3 · reveal_time +0.1 | - | 830 | - |
| b2 | Pulse Compression | 640 | ping_every -0.3 · reveal_time +0.1 | - | 1470 | - |
| b3 | Rapid Sweep | 2070 | ping_every -0.4 · reveal_time +0.1 | - | 3540 | - |
| b4 | Phased Array | 4485 | ping_every -0.4 | - | 8025 | - |
| bm | Constant Track | 10350 | constant | - | 18375 | - |
| c1 | Signal Analysis | 230 | unmask_decoy | - | 805 | - |
| c2 | Disguise Breaker | 460 | unmask_mask | - | 1265 | - |
| c3 | Track Lock | 1930 | reveal_time +0.3 | - | 3195 | - |
| c4 | Illusion Filter | 2390 | unmask_mirage | - | 5585 | - |
| cm | Total Exposure | 3590 | exposure +5 | - | 9175 | - |

### shockwave_generator

air: yes · ground: yes · size: 1 · damage_kind: physical

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Shockwave Generator | 450 | damage 75 · range 100 · rate 0.571 | 42.8 | 450 | 9.52 |
| r1 | Wave Focus | 245 | range +15 | 42.8 | 695 | 6.16 |
| r2 | Containment Coils | 120 | damage +10 | 48.5 | 570 | 8.51 |
| r3 | Reactor Venting | 150 | rate +0.096 | 50.0 | 600 | 8.34 |
| a1 | Hotter Core | 210 | damage +10 · range +5 | 48.5 | 660 | 7.35 |
| a2 | Dense Core | 470 | damage +10 · range +5 | 54.2 | 1130 | 4.80 |
| a3 | Critical Mass | 1870 | damage +15 · range +10 | 62.8 | 3000 | 2.09 |
| a4 | Overpressure | 3200 | damage +15 · range +5 | 71.4 | 6200 | 1.15 |
| am | Megaton Wave | 6690 | damage +10 · range +7 | 77.1 | 12890 | 0.60 |
| b1 | Quick Cycle | 115 | rate +0.074 | 48.4 | 565 | 8.56 |
| b2 | Fast Cycle | 220 | rate +0.069 | 53.5 | 785 | 6.82 |
| b3 | Pulse Core | 980 | rate +0.156 | 65.3 | 1765 | 3.70 |
| b4 | Rapid Core | 1645 | rate +0.13 | 75.0 | 3410 | 2.20 |
| bm | Chain Pulse | 6310 | rate +0.25 | 93.8 | 9720 | 0.96 |
| c1 | Disruptor Wave | 45 | shield_mult +1.5 | 42.8 | 495 | 8.65 |
| c2 | Harmonic Wave | 55 | shield_mult +0.5 | 42.8 | 550 | 7.79 |
| c3 | Resonance | 145 | shield_mult +0.5 | 42.8 | 695 | 6.16 |
| c4 | Breaker Wave | 290 | shield_mult +0.5 | 42.8 | 985 | 4.35 |
| cm | Shatter Shock | 1300 | shatter_half · regen_block +5 | 42.8 | 2285 | 1.87 |

### scrapyard

air: no · ground: no · size: 2 · damage_kind: physical · economy: yes

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Scrapyard | 875 | income 100 · range 150 | - | 875 | - |
| r1 | Hammer Mill | 525 | income +30 | - | 1400 | - |
| r2 | Faster Loading | 260 | range +30 | - | 1135 | - |
| r3 | Surplus | 260 | sell_field +0.85 | - | 1135 | - |
| a1 | Firebrick Lining | 525 | income +30 | - | 1400 | - |
| a2 | Forced Bellows | 1225 | income +35 | - | 2625 | - |
| a3 | Blast Furnace | 3850 | income +55 | - | 6475 | - |
| a4 | Arc Furnace | 7000 | income +50 | - | 13475 | - |
| am | Gold Foundry | 27440 | income +50 · interest +0.03 · interest_cap +400 | - | 40915 | - |
| b1 | Tow Hook | 345 | bounty_bonus +0.15 · range -10 | - | 1220 | - |
| b2 | Magnet Crane | 625 | bounty_bonus +0.1 · range +10 | - | 1845 | - |
| b3 | Laser Cutter | 2095 | bounty_bonus +0.1 · range +20 | - | 3940 | - |
| b4 | Car Crusher | 5720 | bounty_bonus +0.1 · range +20 | - | 9660 | - |
| bm | Breaker's Yard | 28945 | bounty_bonus +0.15 · range +20 · boss_bounty +2 | - | 38605 | - |
| c1 | Parts Shelves | 190 | discount +0.05 · range -10 | - | 1065 | - |
| c2 | Pallet Racks | 495 | discount +0.05 · range +10 | - | 1560 | - |
| c3 | Forklift Bay | 2035 | discount +0.05 · build_discount +0.05 · range +10 | - | 3595 | - |
| c4 | Loading Dock | 3865 | discount +0.05 · range +15 | - | 7460 | - |
| cm | Parts Exchange | 20935 | discount +0.05 · build_discount +0.05 · range +15 · sell_field +1 | - | 28395 | - |

### magneto_tower

air: yes · ground: yes · size: 1 · damage_kind: energy

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Magneto Tower | 525 | range 120 · slow 0.25 | - | 525 | - |
| r1 | Superconducting Coil | 210 | slow +0.05 | - | 735 | - |
| r2 | Field Stabiliser | 280 | range +15 | - | 805 | - |
| r3 | Pole Shoes | 135 | pole_shoes +0.3 | - | 660 | - |
| a1 | Stronger Coil | 295 | slow +0.07 | - | 820 | - |
| a2 | Heavy Grip | 565 | slow +0.03 · grip_relief +0.25 | - | 1385 | - |
| a3 | Mass Lock | 2060 | slow +0.07 · grip_relief +0.25 | - | 3445 | - |
| a4 | Dense Field | 2450 | slow +0.06 | - | 5895 | - |
| am | Absolute Pull | 13630 | slow +0.07 · grip_relief +0.5 | - | 19525 | - |
| b1 | Wider Coil | 180 | range +10 | - | 705 | - |
| b2 | Field Extender | 395 | range +10 | - | 1100 | - |
| b3 | Broad Field | 1290 | range +15 | - | 2390 | - |
| b4 | Great Field | 2845 | range +15 | - | 5235 | - |
| bm | Magnetosphere | 10645 | range +25 | - | 15880 | - |
| c1 | Plate Puller | 360 | armor_pull +2 | - | 885 | - |
| c2 | Plate Ripper | 720 | armor_pull +2 | - | 1605 | - |
| c3 | Torn Plates | 1440 | pull_perm | - | 3045 | - |
| c4 | Deep Pull | 2160 | armor_pull +1 | - | 5205 | - |
| cm | Reverse Polarity | 9600 | flip_every +4 · flip_damage +40 | - | 14805 | - |

### tractor_tower

air: yes · ground: yes · size: 1 · damage_kind: energy

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Tractor Tower | 575 | range 160 · hold 1.5 · pull 80 · recharge 6 | - | 575 | - |
| r1 | Beam Sweep | 175 | beam_slow +0.3 | - | 750 | - |
| r2 | Longer Hold | 140 | hold +0.5 | - | 715 | - |
| r3 | Faster Recharge | 230 | recharge -1 | - | 805 | - |
| a1 | Longer Haul | 185 | pull +20 | - | 760 | - |
| a2 | Stronger Beam | 535 | pull +20 · hold +0.3 | - | 1295 | - |
| a3 | Rewind | 1840 | rewind +3 | - | 3135 | - |
| a4 | Long Rewind | 2945 | rewind +1 | - | 6080 | - |
| am | Undo | 9215 | rewind +1 · undo | - | 15295 | - |
| b1 | Quick Release | 175 | recharge -0.8 | - | 750 | - |
| b2 | Capacitor Bank | 345 | recharge -0.6 | - | 1095 | - |
| b3 | Rapid Lock | 1265 | recharge -0.8 | - | 2360 | - |
| b4 | Overclocked Emitter | 2200 | recharge -0.5 | - | 4560 | - |
| bm | Supercapacitor | 21745 | recharge -1.3 | - | 26305 | - |
| c1 | Firm Grip | 190 | grip_relief +0.5 | - | 765 | - |
| c2 | Crushing Grip | 270 | grip_dps +15 | - | 1035 | - |
| c3 | Lift and Drop | 1075 | slam_radius +50 · slam_stun +0.4 | - | 2110 | - |
| c4 | Grip Lock | 1610 | grip_lock | - | 3720 | - |
| cm | Gravity Hammer | 5365 | slam_radius +30 · slam_stun +0.4 · slam_shatter | - | 9085 | - |

### augmentation_tower

air: yes · ground: yes · size: 1 · damage_kind: physical · support: yes

| Node | =Name | Cost | Tokens | =DPS | =Spent | =DPS/100cr |
|---|---|---|---|---|---|---|
| base | Augmentation Tower | 650 | range 96 · aug_crit 0.05 · crit_mult 2 | - | 650 | - |
| r1 | Wide Aura | 170 | range +48 | - | 820 | - |
| r2 | Amplified Bonus | 135 | aug_crit +0.05 | - | 785 | - |
| r3 | Remote Link | 75 | remote_link | - | 725 | - |
| a1 | Charged Rounds | 105 | energy_conv +0.25 | - | 755 | - |
| a2 | Plasma Coating | 205 | energy_conv +0.25 | - | 960 | - |
| a3 | Energy Weave | 410 | energy_conv +0.25 | - | 1370 | - |
| a4 | Full Conversion | 820 | energy_conv +0.25 | - | 2190 | - |
| am | Overcharge | 4375 | energy_bonus +0.1 | - | 6565 | - |
| b1 | Targeting Assist | 80 | aug_crit +0.03 | - | 730 | - |
| b2 | Weak-Point Scan | 165 | aug_crit +0.03 | - | 895 | - |
| b3 | Precision Matrix | 1260 | aug_crit +0.04 · crit_mult +0.5 | - | 2155 | - |
| b4 | Lethal Matrix | 985 | aug_crit +0.03 | - | 3140 | - |
| bm | Executioner Link | 7440 | aug_crit +0.04 · crit_mult +0.5 | - | 10580 | - |
| c1 | Deflector Rounds | 135 | ricochet +0.1 · ricochet_str +0.5 | - | 785 | - |
| c2 | Bounce Coating | 275 | ricochet +0.1 | - | 1060 | - |
| c3 | Ricochet Field | 1205 | ricochet +0.1 · ricochet_str +0.2 | - | 2265 | - |
| c4 | Chain Bounce | 1530 | ricochet +0.1 | - | 3795 | - |
| cm | Pinball | 7660 | ricochet +0.1 · bounce_again | - | 11455 | - |

## Enemies

Every enemy's round-1 stats, and its ability numbers as tokens (`key value`, separated by ` · `; a key must already exist in
`data/enemies.gd`, which keeps the names, roles, tiers, flags and text). **=Leak** is generated and written into the game
as the enemy's leak cost. Each enemy's round makeup (introduction round, threat cost, spacing, group cap) is in Waves.

<!-- table: enemies -->
| Id | =Name | HP | Speed | Armor | Bounty | Radius | Abilities | =Strength | =Leak |
|---|---|---|---|---|---|---|---|---|---|
| grunt | Drone | 70 | 55 | 0 | 4 | 11 | - | 21.2 | 1 |
| runner | Skitter | 45 | 105 | 0 | 4 | 10 | - | 49.6 | 1 |
| brute | Siege Mech | 265 | 40 | 6 | 10 | 14 | - | 254.4 | 3 |
| swarmling | Nanite | 22 | 78 | 0 | 2 | 6 | - | 13.4 | 1 |
| bat | Strike Drone | 100 | 82 | 0 | 5 | 9 | - | 67.2 | 2 |
| shaman | Repair Bot | 125 | 50 | 1 | 11 | 11 | heal_pct 0.08 · heal_radius 90 · heal_interval 2 | 31.3 | 1 |
| phantom | Phantom | 85 | 72 | 0 | 7 | 10 | - | 44.1 | 1 |
| aegis | Aegis Walker | 150 | 44 | 2 | 12 | 13 | shield 130 · shield_regen 0.25 · shield_delay 2.5 | 58.1 | 2 |
| hydra | Hydra Frame | 190 | 46 | 3 | 8 | 14 | split_count 3 | 120.6 | 2 |
| jammer | Jammer | 150 | 50 | 1 | 12 | 12 | emp_radius 95 · emp_duration 2 · emp_interval 5 | 37.5 | 1 |
| locust | Locust | 15 | 115 | 0 | 1 | 5 | - | 19.8 | 1 |
| gunship | Gunship | 600 | 42 | 5 | 18 | 16 | - | 529.2 | 4 |
| burrower | Burrower | 160 | 62 | 2 | 9 | 11 | burrow_interval 5 · burrow_time 2.5 | 123.0 | 2 |
| stalker | Blink Stalker | 110 | 70 | 1 | 8 | 10 | blink_interval 4 · blink_distance 80 | 53.9 | 2 |
| mender | Mender Hulk | 380 | 38 | 3 | 14 | 15 | regen_pct 0.04 · regen_delay 1.5 | 164.6 | 3 |
| rally | Rally Beacon | 170 | 48 | 2 | 12 | 12 | aura_radius 100 · aura_haste 0.25 | 78.3 | 2 |
| bulwark | Bulwark | 200 | 42 | 3 | 13 | 13 | grant_interval 6 · grant_radius 100 · grant_pct 0.25 | 105.8 | 2 |
| rampart | Rampart | 520 | 34 | 8 | 18 | 16 | - | 480.9 | 4 |
| needle | Needle | 30 | 140 | 0 | 5 | 8 | pack 2 · pack_gap 0.25 | 58.8 | 2 |
| fury | Fury Drone | 85 | 125 | 1 | 9 | 10 | adrenaline 0.3 · adrenaline_at 0.5 | 132.8 | 2 |
| shrike | Shrike | 55 | 90 | 0 | 3 | 7 | pack 5 · pack_gap 0.15 | 44.6 | 1 |
| titan | Titan | 700 | 30 | 9 | 24 | 18 | slow_resist 0.5 · shed_at 0.5 · shed_armor 5 · shed_speed 1.2 | 567.0 | 4 |
| siphon | Siphon | 190 | 52 | 2 | 12 | 12 | siphon_radius 100 · siphon_rate 0.2 · siphon_range 0.15 | 102.8 | 2 |
| blackout | Blackout Rig | 260 | 48 | 3 | 15 | 14 | emp_radius 130 · emp_duration 2.5 · emp_interval 4 | 179.7 | 3 |
| capacitor | Capacitor | 420 | 44 | 4 | 20 | 15 | emp_radius 160 · emp_duration 3 · emp_interval 8 · emp_charge 2 | 325.2 | 3 |
| shifter | Shifter | 200 | 68 | 2 | 13 | 11 | blink_interval 5 · blink_distance 60 · wake_radius 80 · wake_haste 0.2 · wake_time 2 | 185.0 | 3 |
| wraith | Wraith | 260 | 74 | 2 | 18 | 11 | - | 284.8 | 3 |
| masquerade | Masquerade | 320 | 60 | 3 | 14 | 11 | reveal_at 0.5 · flee_speed 80 · flee_time 3 | 345.6 | 3 |
| decoy | Decoy Beacon | 400 | 36 | 6 | 10 | 14 | - | 311.0 | 3 |
| mirage | Mirage | 140 | 55 | 1 | 12 | 11 | holo_interval 6 · holo_count 2 | 42.4 | 1 |
| juggernaut | Dreadnought | 800 | 32 | 5 | 120 | 22 | slow_resist 0.5 | 409.6 | 20 |
| warlord | Overmind | 1900 | 20 | 10 | 500 | 26 | slow_resist 0.6 · spawn_count 3 · spawn_interval 5 | 760.0 | 40 |
| leviathan | Leviathan | 2600 | 24 | 6 | 400 | 30 | slow_resist 0.5 · spawn_count 6 · spawn_interval 6 | 898.6 | 60 |
| colossus | Colossus | 4200 | 18 | 14 | 700 | 32 | slow_resist 0.6 · phase_armor 5 · phase_speed 1.2 · phase_spawn_count 2 | 1905.1 | 80 |

Leak bands, and how much of a Magneto field or Tractor pull each role resists:

<!-- table: enemy_rules -->
| Constant | Value | Meaning |
|---|---|---|
| `Enemies.LEAK_BANDS.0` | 50 | Strength below this leaks for 1 shield |
| `Enemies.LEAK_BANDS.1` | 150 | ... below this, 2 shields |
| `Enemies.LEAK_BANDS.2` | 400 | ... below this, 3; at or above it, 4 |
| `Enemies.ROLE_RESIST.swarm` | 0 | Share of a Magneto Tower's field and a Tractor Tower's pull the swarm role resists |
| `Enemies.ROLE_RESIST.rusher` | 0.10 | Share of a Magneto Tower's field and a Tractor Tower's pull the rusher role resists |
| `Enemies.ROLE_RESIST.evader` | 0.20 | Share of a Magneto Tower's field and a Tractor Tower's pull the evader role resists |
| `Enemies.ROLE_RESIST.support` | 0.30 | Share of a Magneto Tower's field and a Tractor Tower's pull the support role resists |
| `Enemies.ROLE_RESIST.disruptor` | 0.30 | Share of a Magneto Tower's field and a Tractor Tower's pull the disruptor role resists |
| `Enemies.ROLE_RESIST.special` | 0.30 | Share of a Magneto Tower's field and a Tractor Tower's pull the special role resists |
| `Enemies.ROLE_RESIST.tank` | 0.50 | Share of a Magneto Tower's field and a Tractor Tower's pull the tank role resists |
| `Enemies.ROLE_RESIST.boss` | 0.75 | Share of a Magneto Tower's field and a Tractor Tower's pull the boss role resists |
| `Modifiers.SLOW_RESIST_CAP` | 0.9 | The most of any slow an enemy can resist, with modifiers |

Health and kill credits by round (round-1 values × the Waves formulas):

<!-- generated: enemy_scaling -->

| Enemy | =HP r20 | =HP r40 | =HP r60 | =HP r80 | =HP r100 | =HP r120 | =Credits r20 | =Credits r60 | =Credits r100 |
|---|---|---|---|---|---|---|---|---|---|
| Drone | 167 | 334 | 569 | 1062 | 1846 | 3045 | 5.2 | 7.5 | 10.7 |
| Skitter | 107 | 215 | 366 | 683 | 1187 | 1957 | 5.2 | 7.5 | 10.7 |
| Siege Mech | 632 | 1265 | 2154 | 4022 | 6988 | 11527 | 13.0 | 18.7 | 26.7 |
| Nanite | 52 | 105 | 179 | 334 | 580 | 957 | 2.6 | 3.7 | 5.3 |
| Strike Drone | 238 | 478 | 813 | 1518 | 2637 | 4350 | 6.5 | 9.4 | 13.3 |
| Repair Bot | 298 | 597 | 1016 | 1897 | 3296 | 5437 | 14.3 | 20.6 | 29.4 |
| Phantom | 203 | 406 | 691 | 1290 | 2241 | 3697 | 9.1 | 13.1 | 18.7 |
| Aegis Walker | 357 | 716 | 1219 | 2277 | 3955 | 6525 | 15.6 | 22.5 | 32.0 |
| Hydra Frame | 453 | 907 | 1544 | 2884 | 5010 | 8265 | 10.4 | 15.0 | 21.4 |
| Jammer | 357 | 716 | 1219 | 2277 | 3955 | 6525 | 15.6 | 22.5 | 32.0 |
| Locust | 36 | 72 | 122 | 228 | 396 | 652 | 1.3 | 1.9 | 2.7 |
| Gunship | 1430 | 2865 | 4876 | 9107 | 15822 | 26099 | 23.4 | 33.7 | 48.0 |
| Burrower | 381 | 764 | 1300 | 2429 | 4219 | 6960 | 11.7 | 16.9 | 24.0 |
| Blink Stalker | 262 | 525 | 894 | 1670 | 2901 | 4785 | 10.4 | 15.0 | 21.4 |
| Mender Hulk | 906 | 1815 | 3088 | 5768 | 10020 | 16529 | 18.2 | 26.2 | 37.4 |
| Rally Beacon | 405 | 812 | 1382 | 2580 | 4483 | 7395 | 15.6 | 22.5 | 32.0 |
| Bulwark | 477 | 955 | 1625 | 3036 | 5274 | 8700 | 16.9 | 24.4 | 34.7 |
| Rampart | 1239 | 2483 | 4226 | 7893 | 13712 | 22619 | 23.4 | 33.7 | 48.0 |
| Needle | 71 | 143 | 244 | 455 | 791 | 1305 | 6.5 | 9.4 | 13.3 |
| Fury Drone | 203 | 406 | 691 | 1290 | 2241 | 3697 | 11.7 | 16.9 | 24.0 |
| Shrike | 131 | 263 | 447 | 835 | 1450 | 2392 | 3.9 | 5.6 | 8.0 |
| Titan | 1668 | 3343 | 5689 | 10625 | 18459 | 30448 | 31.1 | 45.0 | 64.1 |
| Siphon | 453 | 907 | 1544 | 2884 | 5010 | 8265 | 15.6 | 22.5 | 32.0 |
| Blackout Rig | 620 | 1242 | 2113 | 3946 | 6856 | 11309 | 19.5 | 28.1 | 40.0 |
| Capacitor | 1001 | 2006 | 3413 | 6375 | 11075 | 18269 | 26.0 | 37.5 | 53.4 |
| Shifter | 477 | 955 | 1625 | 3036 | 5274 | 8700 | 16.9 | 24.4 | 34.7 |
| Wraith | 620 | 1242 | 2113 | 3946 | 6856 | 11309 | 23.4 | 33.7 | 48.0 |
| Masquerade | 763 | 1528 | 2601 | 4857 | 8438 | 13919 | 18.2 | 26.2 | 37.4 |
| Decoy Beacon | 953 | 1910 | 3251 | 6071 | 10548 | 17399 | 13.0 | 18.7 | 26.7 |
| Mirage | 334 | 669 | 1138 | 2125 | 3692 | 6090 | 15.6 | 22.5 | 32.0 |
| Dreadnought | 1907 | 3820 | 6502 | 12143 | 21096 | 34798 | 155.7 | 225.0 | 320.3 |
| Overmind | 4528 | 9073 | 15442 | 28839 | 50102 | 82645 | 648.8 | 937.5 | 1334.4 |
| Leviathan | 6196 | 12416 | 21131 | 39463 | 68561 | 113094 | 519.0 | 750.0 | 1067.6 |
| Colossus | 10009 | 20056 | 34134 | 63748 | 110752 | 182690 | 908.3 | 1312.4 | 1868.2 |

<!-- /generated: enemy_scaling -->

## Modifiers

The nine elite modifiers: the round each first appears (**Intro**), what it multiplies the enemy's threat cost by
(**Cost**), and its numbers (`keys.x` are values merged into the enemy's data). Names and blurbs stay in
`data/modifiers.gd`.

<!-- table: modifiers -->
| Id | =Name | Intro | Cost | Numbers |
|---|---|---|---|---|
| shielded | Shielded | 10 | 1.5 | shield_pct 0.5 · keys.shield_regen 0.25 · keys.shield_delay 2.5 |
| hasty | Hasty | 12 | 1.6 | speed_mult 1.35 |
| regenerating | Regenerating | 14 | 1.4 | keys.regen_pct 0.03 · keys.regen_delay 2 |
| plated | Plated | 16 | 1.6 | armor_add 4 |
| cloaked | Cloaked | 18 | 1.5 | - |
| splitting | Splitting | 22 | 1.6 | keys.split_count 2 |
| jamming | Jamming | 24 | 1.6 | keys.emp_radius 80 · keys.emp_duration 1.5 · keys.emp_interval 6 |
| resolute | Resolute | 28 | 1.4 | slow_resist_add 0.5 |
| commanding | Commanding | 32 | 1.5 | keys.aura_radius 90 · keys.aura_haste 0.15 |

## Waves and scaling

One generator makes every round, the same on every playthrough, sector and mode. Each round has a threat budget (in
Drone-equivalents) that it spends on groups of enemies, part of it on elites. A boss round adds its boss line-up. How
the generator splits a round into groups and spaces them in time is its own mechanics, in `data/waves.gd`.

<!-- table: wave_rules -->
| Constant | Value | Meaning |
|---|---|---|
| `Waves.HP_LINEAR` | 0.05 | HP multiplier: + this × w (w = round - 1) |
| `Waves.HP_QUAD` | 0.0012 | HP multiplier: + this × w² |
| `Waves.LATE_START` | 60 | From this round, HP also compounds |
| `Waves.late_growth` | 0.01 | ... by this much a round (1%) |
| `Waves.SPEED_PER_ROUND` | 0.0045 | Speed: + this a round |
| `Waves.SPEED_CAP` | 0.5 | ... up to this much in all |
| `Waves.BOSS_SPEED_SHARE` | 0.5 | Bosses get this share of the speed growth |
| `Waves.BUDGET_BASE` | 8 | Threat budget: this at round 1 |
| `Waves.BUDGET_LINEAR` | 3.6 | ... + this × w |
| `Waves.BUDGET_QUAD` | 0.02 | ... + this × w² |
| `Waves.ELITE_FROM` | 8 | No elites before this round |
| `Waves.ELITE_START` | 0.10 | Elites' share of the budget from then |
| `Waves.ELITE_RISE` | 0.20 | ... rising by this much |
| `Waves.ELITE_FULL_AT` | 60 | ... reached at this round |
| `Waves.MAX_ELITES` | 12 | Most elites in one round |
| `Modifiers.TWO_MODS_AT` | 40 | An elite carries 2 modifiers from this round |
| `Modifiers.THREE_MODS_AT` | 80 | ... and 3 from this round |
| `Waves.MAX_SPAWNS` | 250 | Most enemies in one round |
| `Waves.BOSS_WEIGHT` | 0.4 | How often a recurring boss is picked (a regular enemy is 1) |
| `Waves.RECUR_BOSS_SHARE` | 0.5 | A boss recurs only if it costs at most this share of the budget |
| `Waves.DEBUT_SHARE` | 0.3 | A new enemy's own group gets this share of the budget on its round |
| `Waves.NEW_WEIGHT` | 2.5 | A recently introduced enemy is picked this many times as often |
| `Waves.NEW_ROUNDS` | 12 | ... for this many rounds after its introduction |

Each enemy's round makeup: the round it's introduced (its own group leads that round), its threat cost (a Needle pair or
a Shrike cluster costs its pack times this), the seconds between spawns in its group, and the most in one group. A
blank cell means none (bosses aren't introduced in regular rounds).

<!-- table: round_makeup -->
| Id | =Name | Intro | Threat | Spacing | Max |
|---|---|---|---|---|---|
| grunt | Drone | 1 | 1 | 0.35 | - |
| runner | Skitter | 3 | 0.7 | 0.3 | - |
| brute | Siege Mech | 7 | 3.8 | 0.9 | - |
| swarmling | Nanite | 2 | 0.35 | 0.14 | - |
| bat | Strike Drone | 25 | 1.4 | 0.45 | - |
| shaman | Repair Bot | 5 | 1.8 | 1.8 | 8 |
| phantom | Phantom | 13 | 1.2 | 0.5 | - |
| aegis | Aegis Walker | 17 | 4 | 1.2 | - |
| hydra | Hydra Frame | 29 | 3 | 1.1 | - |
| jammer | Jammer | 9 | 2.1 | 2 | 5 |
| locust | Locust | 15 | 0.25 | 0.1 | - |
| gunship | Gunship | 43 | 8.6 | 1.5 | - |
| burrower | Burrower | 31 | 2.3 | 0.8 | - |
| stalker | Blink Stalker | 11 | 1.6 | 0.6 | - |
| mender | Mender Hulk | 51 | 5.4 | 1.4 | - |
| rally | Rally Beacon | 21 | 2.4 | 1.6 | 6 |
| bulwark | Bulwark | 33 | 2.9 | 1.6 | 6 |
| rampart | Rampart | 35 | 7.4 | 1.8 | - |
| needle | Needle | 19 | 0.6 | 0.6 | - |
| fury | Fury Drone | 49 | 1.9 | 0.5 | - |
| shrike | Shrike | 47 | 1 | 1.2 | - |
| titan | Titan | 57 | 12 | 2.2 | - |
| siphon | Siphon | 27 | 3 | 2 | 5 |
| blackout | Blackout Rig | 39 | 4.5 | 2.4 | 4 |
| capacitor | Capacitor | 55 | 7.5 | 3 | 3 |
| shifter | Shifter | 41 | 3.8 | 1 | - |
| wraith | Wraith | 53 | 6 | 1 | - |
| masquerade | Masquerade | 45 | 5.5 | 1.2 | - |
| decoy | Decoy Beacon | 37 | 4 | 2.5 | 3 |
| mirage | Mirage | 23 | 2.2 | 2 | 5 |
| juggernaut | Dreadnought | - | 20 | 6 | 1 |
| warlord | Overmind | - | 45 | 6 | 1 |
| leviathan | Leviathan | - | 60 | 6 | 1 |
| colossus | Colossus | - | 95 | 6 | 1 |

The boss line-ups (count per boss; which bosses, and their order, are set in `data/waves.gd`):

<!-- table: boss_rounds -->
| Round | Line-up |
|---|---|
| 20 | juggernaut 1 |
| 40 | warlord 1 · juggernaut 1 |
| 60 | leviathan 1 · warlord 1 · juggernaut 1 |
| 80 | colossus 1 · leviathan 1 · juggernaut 2 |
| 100 | colossus 1 · leviathan 1 · warlord 1 · juggernaut 2 |
| 120 | colossus 2 · leviathan 1 · warlord 2 · juggernaut 3 |

The round formulas at sample rounds:

<!-- generated: round_table -->

| Round | =HP × | =Speed × | =Boss speed × | =Budget | =Elite share | =Bounty × | =Clear bonus | =Early-call bonus |
|---|---|---|---|---|---|---|---|---|
| 1 | 1.00 | 1.00 | 1.00 | 8.0 | 0% | 1.00 | 23 | 12 |
| 10 | 1.55 | 1.04 | 1.02 | 42.0 | 11% | 1.14 | 50 | 30 |
| 20 | 2.38 | 1.09 | 1.04 | 83.6 | 15% | 1.30 | 80 | 50 |
| 30 | 3.46 | 1.13 | 1.07 | 129.2 | 18% | 1.45 | 110 | 70 |
| 40 | 4.78 | 1.18 | 1.09 | 178.8 | 22% | 1.60 | 140 | 90 |
| 50 | 6.33 | 1.22 | 1.11 | 232.4 | 26% | 1.74 | 170 | 110 |
| 60 | 8.13 | 1.27 | 1.13 | 290.0 | 30% | 1.87 | 200 | 130 |
| 70 | 11.23 | 1.31 | 1.16 | 351.6 | 30% | 2.07 | 230 | 150 |
| 80 | 15.18 | 1.36 | 1.18 | 417.2 | 30% | 2.26 | 260 | 170 |
| 90 | 20.16 | 1.40 | 1.20 | 486.8 | 30% | 2.46 | 290 | 190 |
| 100 | 26.37 | 1.45 | 1.22 | 560.4 | 30% | 2.67 | 320 | 210 |
| 120 | 43.50 | 1.50 | 1.25 | 719.6 | 30% | 3.10 | 380 | 250 |
| 140 | 69.02 | 1.50 | 1.25 | 894.8 | 30% | 3.56 | 440 | 290 |
| 160 | 106.26 | 1.50 | 1.25 | 1086.0 | 30% | 4.05 | 500 | 330 |

<!-- /generated: round_table -->

## Economy

<!-- table: economy -->
| Constant | Value | Meaning |
|---|---|---|
| `Game.START_GOLD` | 500 | Credits at the start of a run (research can raise it) |
| `Game.SELL_REFUND` | 0.7 | Share of what a tower cost that selling it refunds |
| `Game.RUBBLE_COST` | 40 | Credits to clear a rubble tile |
| `Waves.bounty_exp` | 0.3 | Kill credits grow with the round's HP multiplier to this power |
| `Waves.CLEAR_BASE` | 20 | Round-clear bonus: this ... |
| `Waves.CLEAR_PER_ROUND` | 3 | ... + this × the round |
| `Waves.CALL_BASE` | 10 | Calling a round early pays this ... |
| `Waves.CALL_PER_ROUND` | 2 | ... + this × the round |

## Difficulty

Each mode's length, core shields, medal research points, and tower price multiplier (every build and upgrade price).
Names, blurbs and colours stay in `data/difficulty.gd`.

<!-- table: difficulty -->
| Id | =Name | Rounds | Shields | Medal RP | Price |
|---|---|---|---|---|---|
| easy | Easy | 40 | 200 | 1 | 1 |
| medium | Medium | 60 | 100 | 2 | 1 |
| hard | Hard | 80 | 50 | 3 | 1.1 |
| nightmare | Nightmare | 100 | 25 | 4 | 1.5 |
| cataclysm | Cataclysm | 120 | 1 | 5 | 2 |

Every tower's stock price on each mode (price × multiplier, rounded):

<!-- generated: mode_prices -->

| Tower | =Easy | =Medium | =Hard | =Nightmare | =Cataclysm |
|---|---|---|---|---|---|
| Gun Turret | 75 | 75 | 83 | 113 | 150 |
| Mortar Tower | 150 | 150 | 165 | 225 | 300 |
| Rocket Salvo | 200 | 200 | 220 | 300 | 400 |
| Laser Tower | 250 | 250 | 275 | 375 | 500 |
| Anti-Aircraft Turret | 150 | 150 | 165 | 225 | 300 |
| Artillery Cannon | 300 | 300 | 330 | 450 | 600 |
| Railgun | 500 | 500 | 550 | 750 | 1000 |
| Tesla Tower | 250 | 250 | 275 | 375 | 500 |
| Drone Bay | 300 | 300 | 330 | 450 | 600 |
| CAS Gunship | 650 | 650 | 715 | 975 | 1300 |
| Mine Layer | 450 | 450 | 495 | 675 | 900 |
| Chemical Plant | 250 | 250 | 275 | 375 | 500 |
| Cryo Tower | 150 | 150 | 165 | 225 | 300 |
| Boost Tower | 400 | 400 | 440 | 600 | 800 |
| Radar Tower | 575 | 575 | 633 | 863 | 1150 |
| Shockwave Generator | 450 | 450 | 495 | 675 | 900 |
| Scrapyard | 875 | 875 | 963 | 1313 | 1750 |
| Magneto Tower | 525 | 525 | 578 | 788 | 1050 |
| Tractor Tower | 575 | 575 | 633 | 863 | 1150 |
| Augmentation Tower | 650 | 650 | 715 | 975 | 1300 |

<!-- /generated: mode_prices -->

## Research

Every Research Lab node's cost in research points (**RP**) and its effects (`key value`, as fractions: 0.1 is +10%).
Names, blurbs, the tree layout and the prerequisites stay in `data/research.gd`.

<!-- table: research_rules -->
| Constant | Value | Meaning |
|---|---|---|
| `Research.RP_ROUND_MILESTONES.0` | 20 | Reaching this round on a sector (any mode) earns 1 RP ... |
| `Research.RP_ROUND_MILESTONES.1` | 40 | ... and this one another |
| `Research.RP_ROUND_MILESTONES.2` | 60 | ... |
| `Research.RP_ROUND_MILESTONES.3` | 80 | ... |
| `Research.RP_ROUND_MILESTONES.4` | 100 | ... |
| `Research.RP_ENDLESS_STEP` | 10 | In endless, 1 RP for every this many rounds past the mode's last round ... |
| `Research.RP_ENDLESS_MAX_PER_SECTOR` | 5 | ... up to this many per sector |

<!-- table: research -->
| Id | =Name | RP | Effects |
|---|---|---|---|
| cmd_funds | Reserve Funds | 1 | start_gold 0.10 |
| cmd_salvage | Salvage Protocols | 2 | sell_refund 0.15 |
| cmd_core | Reinforced Core | 2 | lives 0.1 |
| cmd_bounty | Bounty Contracts | 3 | bounty 0.08 |
| cmd_uplink | Orbital Uplink | 2 | ability_cd 0.20 |
| gun_turret_1 | Hardened Barrels | 1 | mult.damage 0.06 |
| gun_turret_2a | Ranging Optics | 2 | mult.range 0.07 |
| gun_turret_2b | Quick Feed | 2 | mult.rate 0.07 |
| gun_turret_m | Gun Turret Mastery | 3 | - |
| mortar_tower_1 | Heavy Charges | 1 | mult.damage 0.06 |
| mortar_tower_2a | Long Tubes | 2 | mult.range 0.07 |
| mortar_tower_2b | Autoloaders | 2 | mult.rate 0.07 |
| mortar_tower_m | Mortar Tower Mastery | 3 | - |
| rocket_salvo_1 | Warhead Casings | 1 | mult.damage 0.06 |
| rocket_salvo_2a | Booster Fuel | 2 | mult.range 0.07 |
| rocket_salvo_2b | Quick Racks | 2 | mult.rate 0.07 |
| rocket_salvo_m | Rocket Salvo Mastery | 3 | - |
| laser_tower_1 | Cleaner Optics | 1 | mult.damage 0.06 |
| laser_tower_2a | Focusing Mirrors | 2 | mult.range 0.07 |
| laser_tower_2b | Capacitor Tuning | 2 | mult.rate 0.07 |
| laser_tower_m | Laser Tower Mastery | 3 | - |
| anti_aircraft_turret_1 | Heavy Rounds | 1 | mult.damage 0.06 |
| anti_aircraft_turret_2a | Radar Sights | 2 | mult.range 0.07 |
| anti_aircraft_turret_2b | Fast Feed | 2 | mult.rate 0.07 |
| anti_aircraft_turret_m | Anti-Aircraft Turret Mastery | 3 | - |
| artillery_cannon_1 | Heavy Charges | 1 | mult.damage 0.06 |
| artillery_cannon_2a | Wide Charges | 2 | mult.splash 0.06 |
| artillery_cannon_2b | Autoloaders | 2 | mult.rate 0.07 |
| artillery_cannon_m | Artillery Cannon Mastery | 3 | - |
| railgun_1 | Dense Slugs | 1 | mult.damage 0.06 |
| railgun_2a | Long Rails | 2 | mult.range 0.07 |
| railgun_2b | Fast Capacitors | 2 | mult.rate 0.07 |
| railgun_m | Railgun Mastery | 3 | - |
| tesla_tower_1 | High Voltage | 1 | mult.damage 0.06 |
| tesla_tower_2a | Taller Coils | 2 | mult.range 0.07 |
| tesla_tower_2b | Quick Discharge | 2 | mult.rate 0.07 |
| tesla_tower_m | Tesla Tower Mastery | 3 | - |
| drone_bay_1 | Heavier Guns | 1 | mult.damage 0.06 |
| drone_bay_2a | Fast Cycling | 2 | mult.rate 0.07 |
| drone_bay_2b | Spare Parts | 2 | mult.rate 0.04 |
| drone_bay_m | Drone Bay Mastery | 3 | - |
| cas_gunship_1 | Heavier Rounds | 1 | mult.damage 0.06 |
| cas_gunship_2a | Wide Orbit | 2 | mult.orbit 0.07 |
| cas_gunship_2b | Faster Spin | 2 | mult.rate 0.07 |
| cas_gunship_m | CAS Gunship Mastery | 3 | - |
| mine_layer_1 | Heavier Charges | 1 | mult.damage 0.06 |
| mine_layer_2a | Longer Arms | 2 | mult.range 0.07 |
| mine_layer_2b | Faster Presses | 2 | mult.rate 0.07 |
| mine_layer_m | Mine Layer Mastery | 3 | - |
| chemical_plant_1 | Wider Spray | 1 | mult.range 0.07 |
| chemical_plant_2a | Quick Valves | 2 | mult.rate 0.07 |
| chemical_plant_2b | Long-Lasting Mix | 2 | mult.soak_time 0.1 |
| chemical_plant_m | Chemical Plant Mastery | 3 | - |
| cryo_tower_1 | Wider Vents | 1 | mult.range 0.07 |
| cryo_tower_2a | Colder Gas | 2 | mult.slow 0.07 |
| cryo_tower_2b | Quick Vents | 2 | mult.rate 0.07 |
| cryo_tower_m | Cryo Tower Mastery | 3 | - |
| boost_tower_1 | Wider Field | 1 | mult.range 0.07 |
| boost_tower_2a | Stronger Signal | 2 | mult.buff_dmg 0.1 |
| boost_tower_2b | Faster Sync | 2 | mult.buff_rate 0.1 |
| boost_tower_m | Boost Tower Mastery | 3 | - |
| radar_tower_1 | Wider Dish | 1 | mult.range 0.07 |
| radar_tower_2a | Fast Sweep | 2 | mult.ping_every -0.08 |
| radar_tower_2b | Long Hold | 2 | mult.reveal_time 0.1 |
| radar_tower_m | Radar Tower Mastery | 3 | - |
| shockwave_generator_1 | Hotter Core | 1 | mult.damage 0.06 |
| shockwave_generator_2a | Wave Focus | 2 | mult.range 0.07 |
| shockwave_generator_2b | Fast Cycle | 2 | mult.rate 0.07 |
| shockwave_generator_m | Shockwave Generator Mastery | 3 | - |
| scrapyard_1 | Better Linings | 1 | mult.income 0.06 |
| scrapyard_2a | Wider Yard | 2 | mult.range 0.07 |
| scrapyard_2b | Hard Bargains | 2 | mult.bounty_bonus 0.1 |
| scrapyard_m | Scrapyard Mastery | 3 | - |
| magneto_tower_1 | Wider Coil | 1 | mult.range 0.07 |
| magneto_tower_2a | Stronger Coil | 2 | mult.slow 0.07 |
| magneto_tower_2b | Cold Windings | 2 | mult.slow 0.04 |
| magneto_tower_m | Magneto Tower Mastery | 3 | - |
| tractor_tower_1 | Long Dish | 1 | mult.range 0.07 |
| tractor_tower_2a | Quick Release | 2 | mult.recharge -0.07 |
| tractor_tower_2b | Steady Beam | 2 | mult.hold 0.08 |
| tractor_tower_m | Tractor Tower Mastery | 3 | - |
| augmentation_tower_1 | Wider Aura | 1 | mult.range 0.07 |
| augmentation_tower_2a | Sharper Crits | 2 | mult.aug_crit 0.1 |
| augmentation_tower_2b | Lucky Bounces | 2 | mult.ricochet 0.1 |
| augmentation_tower_m | Augmentation Tower Mastery | 3 | - |

## Abilities

The Orbital Strike and Chrono Field. Names, keys and blurbs stay in `data/abilities.gd`.

<!-- table: abilities -->
| Id | =Name | Numbers |
|---|---|---|
| meteor | Orbital Strike | cooldown 45 · damage 110 · radius 85 · delay 0.9 |
| warp | Chrono Field | cooldown 70 · slow 0.6 · duration 5 |

## Rules

The global rules every tower and enemy follows.

<!-- table: rules -->
| Constant | Value | Meaning |
|---|---|---|
| `Enemy.MIN_DAMAGE_FRACTION` | 0.2 | Armour can't cut a hit below this share of its damage |
| `Enemy.SLOW_CAP` | 0.7 | The strongest slow an enemy can be under |
| `Enemy.STUN_GUARD` | 1 | Seconds after a stun ends before it can be stunned again |
| `Enemy.SHOVE_BUDGET` | 320 | The most an enemy can be pushed back along the track in all (px) |
| `Game.BOSS_STUN_FACTOR` | 0.3 | Bosses are stunned this share as long |
| `Game.BOSS_PUSH_FACTOR` | 0.25 | Bosses are pushed this share as far |
| `Game.CRIT_MULT` | 2 | A critical hit deals this many times the damage |
| `Game.SHIELD_EMP_MULT` | 2 | Tesla Tower arcs hit barriers this many times as hard |
| `Game.DISABLE_GUARD` | 1 | Seconds after an EMP wears off before a tower can be knocked offline again |
| `Game.HIT_REVEAL_TIME` | 0.5 | Seconds a cloaked enemy stays revealed after damage hits it |
| `Game.GATE_COOLDOWN` | 6 | Seconds between switches of a switch gate |
| `Game.SLUDGE_SLOW` | 0.3 | Sludge tiles slow walkers by this much |
| `Game.SHOCK_PCT` | 0.04 | Shock strips deal this share of an enemy's max health per second ... |
| `Game.SHOCK_BOSS_PCT` | 0.01 | ... and this share of a boss's |
| `Tower.SECONDARY_CAP` | 2 | Steps a secondary path can take |
| `Tower.SITE_RANGE` | 0.15 | High ground: + this share of range |
| `Tower.SITE_DAMAGE` | 0.15 | Power node: + this share of damage |
