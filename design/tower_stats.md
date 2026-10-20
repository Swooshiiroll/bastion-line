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
