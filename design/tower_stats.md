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
