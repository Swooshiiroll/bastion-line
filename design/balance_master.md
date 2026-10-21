# Bastion Line balance master (design)

One Markdown file, `design/balance.md`, that holds every balance number in the game, shows the math behind them, and is
the source the game's data is generated from. Spec from the owner's answers (2026-10-20). Confirmed 2026-10-21, issue #75.

## Purpose

Tune the game from one place. Every number that sets how hard, fast, strong or expensive something is (health, speed,
armor, price, damage, range, rates, intervals, curves) sits in a table in one file. Next to it are the values derived
from it (DPS, strength, leak cost, health at round 100...) and the formulas that produce them, so an edit shows its
effect straight away.

## Decisions (owner, 2026-10-20)

- **Format:** Markdown source files (plain tables, like `design/tower_stats.md` today); no live calculators.
- **Layout:** one master file, `design/balance.md`, with a section per area and a Formulas section at the top.
  `design/tower_stats.md`'s tables move into it.
- **Scope:** towers, enemies and modifiers, waves and scaling, economy, difficulty and research.
- **Source of truth:** yes. The game's numbers move out of the scripts into data generated from `balance.md`. A
  generator applies edits, and `tools/dev.sh check` fails if the game data or the derived columns are out of date.
- **Derived values:** generated read-only columns beside the inputs, rewritten on every run.
- **Prices:** move into the balance file. `design/upgrade_trees_rework.md` keeps names and blurbs only.
- **Outcomes:** numbers and formulas only. Matchups and round outcomes stay with the balance probe.
- **Rules:** the global rule constants (armor floor, slow cap, crit, boss factors, sell refund, lane hazards...) are
  in the file, in a Rules section.
- **Confirmed** by the owner (2026-10-21). Issue #75.

## The file

`design/balance.md`, sections in this order. Input columns are edited by hand. Columns headed with `=` (e.g. `=DPS`)
are generated and are overwritten on every run.

1. **How to use this file:** edit, run `node tools/balance.mjs`, then `tools/dev.sh check`, `test` and the probe.
2. **Formulas:** every derived value with its formula and one worked example (below).
3. **Rules:** the global constants: armor floor, slow cap, stun guard, shove budget, crit multiplier, boss stun and
   push factors, sell refund, start credits, rubble cost, gate cooldown, lane hazards (sludge, shock), reveal times,
   secondary cap, high ground and power node bonuses.
4. **Towers:** one table per tower, as in `tower_stats.md` (nodes `base`, `r1`-`r3`, `a1`-`a4`, `am`, `b..`, `c..`),
   plus a **Cost** column per node. Derived columns:
   - `=DPS` after that node (damage × rate × hits per attack, armor ignored);
   - `=DPS/100cr` (DPS per 100 credits spent to reach that node);
   - `=Spent` (credits from a new tower to that node).

   A summary table lists every tower's stock cost, stock DPS, cost to a mastery on each path, and the mastery's DPS.
5. **Enemies:** one row per enemy: health, speed, armor, bounty, radius, threat cost, pack size and spacing, plus an
   ability table (intervals, radii, durations, percentages). Derived columns:
   - `=Strength` (speed² × armor × health);
   - `=Leak` (shields from the strength bands; bosses their round);
   - `=HP r20` / `r40` / `r60` / `r80` / `r100` / `r120`;
   - `=Credits r20` / ... (bounty × health multiplier^exponent).
6. **Modifiers:** the nine modifiers' numbers, cost multipliers and intro rounds.
7. **Waves and scaling:**
   - the HP curve coefficients (0.05, 0.0012, late start 60, late growth 1%) and speed growth;
   - threat budget, elite share, bosses' weight, spawn caps;
   - introduction rounds (the tier table) and boss rounds.

   Derived: a round table (1, 10, 20 ... 120 and endless samples) with the HP multiplier, speed multiplier, threat
   budget and elite share.
8. **Economy:** bounty exponent, clear bonus, early-call bonus, sell refund, start credits. Derived: clear bonus and
   bounty multiplier by round.
9. **Difficulty:** each mode's rounds, shields, price multiplier and medal RP. Derived: each tower's stock price per
   mode.
10. **Research:** every node's RP cost and effect value, and the RP milestones.
11. **Abilities:** Orbital Strike and Chrono Field numbers.

## Formulas (shown in the file, each with a worked example)

- Hit after armor: max(damage - armor, damage × 0.2); armor-piercing ignores armor; barriers soak first, armor-free.
- DPS = damage × rate × hits per attack (projectiles, pellets, chain targets); beams use their dps.
- Strength = (speed / 100)² × max(1, armor) × health (round-1 stats).
- Leak cost: 1 below 50 strength, 2 below 150, 3 below 400, else 4; +1 for an elite; a boss costs its intro round.
- HP multiplier(r) = (1 + 0.05w + 0.0012w²) × (1 + late growth)^(r - 60 if r > 60), w = r - 1.
- Speed multiplier(r) = 1 + 0.45% × (r - 1), capped at +50% (bosses: half).
- Bounty(r) = base × HP multiplier(r)^bounty exponent.
- Threat budget, elite share and clear bonus: their formulas as in `data/waves.gd`.
- Tower price on a mode = base × mode multiplier.

## How it becomes game data

- `tools/balance.mjs` reads `design/balance.md` (names and blurbs still come from their own files) and:
  - writes `data/balance.gd`: every number, as constants and dictionaries the game reads. `data/enemies.gd`,
    `data/waves.gd`, `data/modifiers.gd`, `data/difficulty.gd`, `data/research.gd`, `data/abilities.gd` and the rule
    constants in `Game.gd`, `Enemy.gd` and `Tower.gd` take their numbers from it, keeping their names and text;
  - feeds the tower sections to the existing tree generator, so `data/rework_trees.gd` is generated from `balance.md`
    plus the names in `upgrade_trees_rework.md` (`tower_stats.md` is retired);
  - rewrites the `=` columns in `balance.md`.
- Unknown keys or malformed rows fail the tool. `tools/dev.sh check` runs it in check mode: it fails if
  `data/balance.gd`, `data/rework_trees.gd` or a derived column is stale.
- Unit tests that pin a number read it from the balance data instead of a typed literal, so a tuning edit doesn't
  break them. Tests that check a rule (e.g. "a Titan sheds at half health") stay.

## Phasing (one PR each, into the v4-dev line)

1. **The file and the towers:** `balance.md` with Formulas and Towers (from `tower_stats.md`, plus prices),
   `tools/balance.mjs`, the derived tower columns, `check`.
2. **Enemies and modifiers.**
3. **Waves and scaling.**
4. **Economy, difficulty, research, abilities and the rule constants.**

Each phase changes no numbers: the game plays the same before and after. The tests, tour and a probe run confirm it
(same results at a fixed seed).

## Acceptance

- Every balance number the game uses comes from `design/balance.md`; changing one there and running the tool changes
  the game.
- Every derived column matches the game's own calculation (tested: for example, `=Strength` equals
  `Enemies.strength`, and `=HP r100` equals base × `Waves.hp_scale(100)`).
- `check` fails on a stale generated file or column.
- The probe gives identical results before and after each phase.

## Open questions

1. **Copies:** the file goes to Apollyon and LX like the other design docs, with versioned names. Edits made in a copy
   come back by diffing it against the repo file, as with the spec reviews.
