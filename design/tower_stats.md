# Bastion Line tower stats (machine-readable)

The numbers behind the reworked towers, for the game data. Issue #59 (implementation), design in
`design/tower_roster.md` (issue #55). `tools/tree_rework_data.mjs` reads this file and the names and prices in
`design/upgrade_trees_rework.md`, and writes `data/rework_trees.gd`. `tools/dev.sh check` fails if that file is stale.

Each tower has a table of nodes. A node id is `base`, `r1`..`r3` (the Retrofit's options), `a1`..`a4` and `am` (path A's
four upgrades and mastery), then `b..` and `c..`. A node's tokens are separated by ` · `. A token is `key value`: a value
with a sign (`+20`, `-0.5`) is added to the stat; one without (`16`, `0.5`) sets it; a bare `key` is a flag. Nodes apply
in order on top of the base: the Retrofit if bought, then each path's steps. A secondary path applies only its first two.

Stat keys are listed in `tools/tree_rework_data.mjs` (KEYS); an unknown key fails the generator, so typos can't slip in.

## gun_turret

air: yes · ground: yes · size: 1 · damage_kind: physical

| Node | Tokens |
|---|---|
| base | damage 16 · range 130 · rate 1.2 · proj_speed 800 |
| r1 | rate 1.5 |
| r2 | stun_chance 0.05 · stun_time 0.3 |
| r3 | ignite_dps 3 · ignite_time 2 |
| a1 | damage +6 |
| a2 | armor_flat 2 |
| a3 | armor_pct 0.5 · damage +6 |
| a4 | armor_pct 0.75 · damage +8 |
| am | armor_pct 1 · damage 44 |
| b1 | range +20 |
| b2 | range +10 · crit 0.10 · tracers |
| b3 | range +25 · crit 0.15 |
| b4 | range +20 · crit 0.20 |
| bm | range 230 · crit 0.30 |
| c1 | swivel |
| c2 | side_gun 0.5 |
| c3 | multishot 2 · side_gun 0 |
| c4 | rate +0.3 |
| cm | multishot 3 · weakest_extra |

## mortar_tower

air: no · ground: yes · size: 1 · damage_kind: physical

| Node | Tokens |
|---|---|
| base | damage 30 · splash 60 · range 110 · rate 0.6 · proj_speed 420 |
| r1 | damage +4 · range +10 · rate +0.05 · splash +5 |
| r2 | burrow_sight 0.5 |
| r3 | smoke_every 4 · smoke_slow 0.15 · smoke_time 3 |
| a1 | damage +8 |
| a2 | armor_pct 0.25 |
| a3 | armor_pct 0.5 · damage +10 |
| a4 | armor_pct 0.75 · damage +8 |
| am | damage 64 · armor_pct 0.75 · burrow_sight 1 |
| b1 | rate +0.1 |
| b2 | range +20 |
| b3 | tubes 2 · rate 1.2 |
| b4 | range +20 · rate 1.3 |
| bm | tubes 3 · rate 1.7 · range 165 |
| c1 | splash +10 |
| c2 | splash +10 |
| c3 | bomblets 4 · bomblet_damage 10 · bomblet_splash 30 |
| c4 | bomblets 6 · splash +5 |
| cm | bomblets 8 · bomblet_damage 12 · bomblet_splash 35 · bomblet_spread 1 · splash +5 |

## rocket_salvo

air: yes · ground: yes · size: 1 · damage_kind: physical

| Node | Tokens |
|---|---|
| base | damage 19 · splash 25 · range 180 · rate 0.4 · missiles 3 · proj_speed 330 |
| r1 | air_mult 1.4 |
| r2 | smoke_slow 0.1 · smoke_time 2 |
| r3 | ground_burn 3 · ground_burn_time 2 |
| a1 | damage +5 |
| a2 | splash +10 |
| a3 | damage +8 · splash +5 |
| a4 | damage +6 |
| am | damage +8 · splash +10 |
| b1 | range +20 |
| b2 | homing |
| b3 | retarget · range +30 |
| b4 | range +30 |
| bm | range 300 · never_miss |
| c1 | missiles 4 |
| c2 | rate 0.5 |
| c3 | missiles 6 |
| c4 | rate 0.588 |
| cm | missiles 8 · ripple |

## laser_tower

air: yes · ground: yes · size: 1 · damage_kind: energy · beam: yes

| Node | Tokens |
|---|---|
| base | damage 25 · range 150 · ramp 3 · ramp_time 3 · melt 1 · beams 1 · beam_power 0.4 |
| r1 | damage +8 |
| r2 | ramp 3.5 |
| r3 | ramp_keep 0.5 |
| a1 | ramp 3.5 |
| a2 | ramp_time 2.2 |
| a3 | ramp 5 |
| a4 | ramp 6 · ramp_time 1.8 |
| am | ramp 8 · ramp_time 1.5 |
| b1 | beams 2 · beam_power 0.4 |
| b2 | beam_power 0.6 |
| b3 | beams 3 · beam_power 0.6 |
| b4 | beam_power 0.75 |
| bm | beams 4 · beam_power 0.75 |
| c1 | range +15 |
| c2 | range +15 |
| c3 | range +30 |
| c4 | range +30 |
| cm | range 280 |

## anti_aircraft_turret

air: yes · ground: no · size: 1 · damage_kind: physical

| Node | Tokens |
|---|---|
| base | damage 25 · range 160 · rate 2.5 · proj_speed 900 |
| r1 | range +15 |
| r2 | rate +0.25 |
| r3 | damage +4 |
| a1 | range +20 |
| a2 | range +20 |
| a3 | range +40 |
| a4 | range +40 |
| am | range 330 |
| b1 | damage +6 |
| b2 | burst 20 |
| b3 | damage +5 · burst 30 |
| b4 | burst 40 |
| bm | damage 42 · burst 50 |
| c1 | rate 2.8 |
| c2 | rate 3.2 · turn_fast |
| c3 | rate 4.5 · barrels 2 |
| c4 | rate 5.2 |
| cm | rate 7 · barrels 4 |

## artillery_cannon

air: no · ground: yes · size: 1 · damage_kind: physical

| Node | Tokens |
|---|---|
| base | damage 75 · splash 70 · rate 0.25 · flight 1.5 · scatter 30 · burn_dps 15 · burn_time 3 · shrap_radius 40 · shrap_mult 0.7 · stun_time 0.5 |
| r1 | heavy_every 3 |
| r2 | scatter 15 |
| r3 | splash +15 |
| a1 | damage +15 |
| a2 | splash 85 |
| a3 | damage 110 |
| a4 | damage 120 · armor_pct 0.5 |
| am | damage 140 · splash 90 · armor_pct 0.75 |
| b1 | rate 0.303 |
| b2 | rate 0.345 |
| b3 | rate 0.5 |
| b4 | rate 0.588 |
| bm | rate 0.238 · barrage 3 |
| c1 | incendiary |
| c2 | shrapnel |
| c3 | concussion |
| c4 | burn_dps 22 · shrap_mult 0.85 · stun_time 0.7 |
| cm | combined |

## railgun

air: yes · ground: yes · size: 1 · damage_kind: physical

| Node | Tokens |
|---|---|
| base | damage 90 · range 380 · rate 0.4 · falloff 0.4 |
| r1 | rate 0.4545 |
| r2 | damage +15 · range +30 |
| r3 | falloff 0.3 |
| a1 | damage +30 |
| a2 | boss_mult 1.5 |
| a3 | damage 200 · rate 0.333 |
| a4 | damage 240 · boss_mult 2 |
| am | damage 280 · rate 0.303 · boss_mult 2.5 |
| b1 | rate 0.4545 |
| b2 | range +40 |
| b3 | rate 0.625 |
| b4 | rate 0.741 |
| bm | rate 0.833 · rails 2 |
| c1 | shatter 2 |
| c2 | falloff 0.25 |
| c3 | trail_dps 30 · trail_time 2 |
| c4 | shatter 4 · trail_dps 45 · falloff 0.15 |
| cm | shatter 6 · trail_dps 50 · falloff 0 |

## tesla_tower

air: yes · ground: yes · size: 1 · damage_kind: energy

| Node | Tokens |
|---|---|
| base | damage 32 · range 140 · rate 0.8 · jumps 3 · jump_range 70 · falloff 0.15 |
| r1 | damage +4 · range +15 |
| r2 | jumps +1 |
| r3 | rate 0.909 |
| a1 | damage +8 |
| a2 | overload |
| a3 | damage 48 · stun_time 0.3 |
| a4 | damage 54 · falloff 0.08 |
| am | damage 60 · falloff 0.03 · stun_time 0.5 |
| b1 | range +20 |
| b2 | jumps 4 |
| b3 | jumps 5 · storm_radius 25 · storm_dps 10 · storm_time 2 |
| b4 | range +20 · jumps 6 |
| bm | jumps 7 · storm_radius 30 · storm_dps 14 |
| c1 | rate 0.9 |
| c2 | rate 1.0 |
| c3 | rate 1.4 |
| c4 | rate 1.6 |
| cm | rate 2.1 |

## drone_bay

air: yes · ground: yes · size: 1 · damage_kind: physical

| Node | Tokens |
|---|---|
| base | damage 16 · rate 3 · drones 1 |
| r1 | drones 2 |
| a1 | damage 20 |
| a2 | damage 24 |
| a3 | damage 30 |
| a4 | damage 36 |
| am | damage 42 |
| b1 | lo_missiles |
| b2 | lo_bombs |
| b3 | lo_laser |
| b4 | loadout_mult 1.25 |
| bm | lo_full |
| c1 | rate 3.5 |
| c2 | rate 4 |
| c3 | rate 5 |
| c4 | rate 5.8 |
| cm | rate 7 |

## cas_gunship

air: yes · ground: yes · size: 1 · damage_kind: physical · uncapped: yes

| Node | Tokens |
|---|---|
| base | damage 12 · rate 5 · orbit 90 |
| r1 | radar |
| r2 | rate_mult 1.1 |
| r3 | orbit +25 |
| a1 | damage 15 |
| a2 | rate 6 |
| a3 | damage 19 |
| a4 | rate 7.5 |
| am | rate 9 |
| b1 | ac_damage 40 · ac_rate 1.5 · ac_splash 25 |
| b2 | ac_rate 1.8 |
| b3 | ac_damage 52 |
| b4 | ac_rate 2.2 |
| bm | ac_damage 58 · ac_splash 30 |
| c1 | ms_damage 150 · ms_rate 0.333 · ms_splash 45 |
| c2 | ms_rate 0.4 |
| c3 | ms_damage 190 |
| c4 | ms_rate 0.5 |
| cm | ms_volley 2 |

## mine_layer

air: no · ground: yes · size: 1 · damage_kind: physical

| Node | Tokens |
|---|---|
| base | damage 85 · splash 40 · range 120 · rate 0.667 · cap 20 |
| r1 | gel_slow 0.2 · gel_time 2 |
| r2 | damage +15 |
| r3 | range +20 |
| a1 | damage 100 |
| a2 | splash 50 |
| a3 | damage 125 |
| a4 | splash 60 |
| am | damage 150 · splash 65 |
| b1 | rate 0.752 · cap 24 |
| b2 | rate 0.833 · cap 28 |
| b3 | rate 1.053 · cap 32 |
| b4 | rate 1.176 · cap 36 |
| bm | rate 1.4286 · cap 45 |
| c1 | range 140 |
| c2 | range 160 |
| c3 | range 190 |
| c4 | range 220 |
| cm | range 260 |

## chemical_plant

air: yes · ground: yes · size: 1 · damage_kind: energy

| Node | Tokens |
|---|---|
| base | range 130 · rate 0.667 · soak_time 4 · armor_strip 3 · nozzles 1 |
| r1 | rate 0.75 · range +20 |
| r2 | mist |
| r3 | soak_time 5 |
| a1 | acid_perm |
| a2 | armor_strip 4 · acid_dps 5 |
| a3 | armor_strip 5 · acid_dps 10 |
| a4 | armor_strip 6 · acid_dps 15 |
| am | armor_strip 7 · acid_dps 20 |
| b1 | rate 0.8 |
| b2 | soak_time 5 |
| b3 | rate 1.0 · soak_time 6 |
| b4 | rate 1.2 |
| bm | rate 0.8 · nozzles 2 · soak_time 7 |
| c1 | gel_slow 0.15 |
| c2 | gel_slow 0.25 |
| c3 | gel_slow 0.35 |
| c4 | gel_slow 0.45 |
| cm | gel_slow 0.55 |

## cryo_tower

air: yes · ground: yes · size: 1 · damage_kind: energy

| Node | Tokens |
|---|---|
| base | range 110 · rate 0.5 · slow 0.2 · slow_time 1.5 |
| r1 | slow_time 2.2 |
| r2 | rate 0.588 |
| r3 | slow 0.25 |
| a1 | slow 0.28 |
| a2 | slow 0.35 |
| a3 | perm_slow 0.1 |
| a4 | slow 0.45 · perm_slow 0.15 |
| am | slow 0.5 · perm_slow 0.2 · freeze_every 4 · freeze_time 1 |
| b1 | damage 5 · range 120 |
| b2 | damage 10 · range 130 |
| b3 | damage 18 · range 145 |
| b4 | damage 26 |
| bm | damage 36 · range 165 |
| c1 | rate 0.571 |
| c2 | rate 0.667 |
| c3 | rate 0.833 |
| c4 | rate 1.0 |
| cm | cold_front |

## boost_tower

air: yes · ground: yes · size: 1 · damage_kind: physical · support: yes

| Node | Tokens |
|---|---|
| base | range 144 · buff_dmg 0.05 · buff_rate 0.05 · buff_range 0.05 |
| r1 | range 168 · buff_extra 0.05 |
| r2 | crit_link 0.03 |
| r3 | range 192 |
| a1 | buff_dmg 0.15 |
| a2 | buff_dmg 0.22 |
| a3 | buff_dmg 0.32 |
| a4 | buff_dmg 0.40 |
| am | buff_dmg 0.50 |
| b1 | buff_rate 0.15 |
| b2 | buff_rate 0.22 |
| b3 | buff_rate 0.32 |
| b4 | buff_rate 0.40 |
| bm | buff_rate 0.50 |
| c1 | buff_range 0.15 |
| c2 | buff_range 0.22 |
| c3 | buff_range 0.32 |
| c4 | buff_range 0.40 |
| cm | buff_range 0.50 |
