# Live Tuner: a dev window that changes balance numbers while the game runs

## Context
`design/balance.md` now holds every balance number, but testing a change still means editing, regenerating, rebuilding and replaying. The owner wants to change stats in real time while playing. When they like a change, the export should flow back into `balance.md`.

Owner's answers (2026-10-21):
- **Form:** an external window anchored to the game. Concretely, the game opens a second native OS window.
- **Exports:** go to a tweaks file. `balance.mjs --apply` writes that file into `balance.md`. Repo runs apply it directly.
- **When it's available:** any mode, behind a `--dev` launch flag.
- **Enemies already on the field:** update immediately.
- **Coverage:** everything `balance.md` owns.
- **Extras:** live derived values, a list of changed values with revert, and a live game readout.

Confirmed by the owner (2026-10-21).

## How it works

### 1. Launch
- `--dev` is parsed in `scripts/Boot.gd`, alongside the existing flags at :26-45, and sets `Boot.dev`.
- Without the flag nothing changes. The tuner isn't created and the scripts behave exactly as they do today.
- `tools/dev.sh lx` also drops a `Bastion Line (dev).sh` launcher into each LX build folder, which runs the game with `-- --dev`.

### 2. Making the numbers writable
- The data `const`s that `balance.md` owns become `static var`. Every existing call site, such as `Enemies.ENEMIES[...]` and `Rework.TREES[...]`, keeps working unchanged.
  - Files: `data/enemies.gd`, `waves.gd`, `modifiers.gd`, `difficulty.gd`, `research.gd`, `abilities.gd` and `rework_trees.gd`, plus the owned rule consts in `Game.gd`, `Enemy.gd` and `Tower.gd`.
  - `balance_lib.gdSpan` already accepts `static var` (tools/balance_lib.mjs:163), and nothing builds a const from these dicts.
  - `tools/tree_rework_data.mjs` emits `static var TREES`.
  - If a scalar is used in another const expression or a default parameter, it stays `const` and the plan notes it as not tunable.
- The tuner snapshots the original values with `duplicate(true)` at startup. That snapshot is what "revert" goes back to.

### 3. Tuner core: `scripts/dev/Tuner.gd`
- **Field registry.** It walks the writable data and lists every numeric leaf that `balance.md` owns.
  - Each field is keyed by the same GD path `balance.mjs` uses, for example `Enemies:ENEMIES.grunt.hp` or `Rework:TREES.gun_turret.a1.add.damage`.
  - It groups fields by area: enemies, modifiers, towers, waves, economy, difficulty, research, abilities and rules.
- **`set(key, value)`** writes the value, records the old and new values, and then refreshes the live game:
  - **Enemy types:** `Enemy.retune()` (new) recomputes `max_hp`, `speed`, `armor`, `bounty`, `radius` and `shield` from the def for every live enemy of that type.
    - Health keeps its current percentage.
    - Elites rebuild their def copy via `Modifiers.apply`.
    - `EnemyTraits._cache` is cleared.
  - **Towers, research and difficulty price:** reuse the refresh in `Game.apply_research` (Game.gd:162-180). That means `t.invalidate()` on every tower and `_recompute_buffs()`. A difficulty price change also rewrites `game.tower_mods[*].price`. New prices apply to the next purchase.
  - **Wave scaling and round makeup:** apply from the next queued round, because `_queue_round` (Game.gd:510) bakes in the multipliers. The readout says so.
  - **Economy and rules:** read live. Start credits only take effect in a new run.
- **`revert(key)` and `revert_all()`** restore the snapshot values and then run the same refresh.
- **Tuned runs:** once any value is changed, the run is marked tuned. It awards no medals or RP and isn't saved as a normal record, and the top bar shows TUNED.

### 4. The window: `scripts/dev/TunerWindow.gd`
- **Placement:** a native `Window` (`force_native = true`) that snaps to the right edge of the game window and follows it as it moves. A pin toggle lets you detach it, for example to drag it to a second monitor. It's built with the `UiKit` helpers, like the other panels.
- **Tabs, one per area:**
  - Each tab lists rows (an enemy, a tower node, a const) with spin boxes for their numbers.
  - A search box filters fields by name.
  - Edits apply when you press Enter or let go of a spin box.
- **Derived values** sit next to the inputs and recompute live, using the game's own functions:
  - Enemies: strength (`Enemies.strength`), leak cost, and HP at rounds 20, 60 and 100 (`Waves.hp_scale`).
  - Towers: DPS, credits spent, and DPS per 100 credits. This is a GDScript port of `paperDps` from `tools/balance.mjs`, tested against the `=DPS` column.
  - Waves: HP and speed multipliers, budget and elite share for the current round and the next one.
- **Changes tab:** every changed field as `old → new`, with a revert button per row, Revert all, and Export.
- **Live readout strip** along the top:
  - the round, the current and next round's HP and speed multipliers, threat budget and elite share;
  - credits and shields;
  - enemies on the field, by type with their HP.
- **Export:**
  - writes `user://tweaks/tweaks-<date time>.json` with `{key, old, new}` per change;
  - shows the file path and has an Open folder button;
  - on a repo run (`OS.has_feature("editor")`, or `res://design/balance.md` exists on disk), it also runs `node tools/balance.mjs --apply <file>` and then `node tools/tree_rework_data.mjs` through `OS.execute` and reports the result. If node isn't found, it says so and keeps the file.

### 5. `tools/balance.mjs --apply <file>`
- While parsing, it builds a reverse map from GD path to its `balance.md` cell. Tables give a row and column, tokens give a row and token, consts give a row, and tower tokens give a node and token (`set` values or `+` adds).
- It writes each change into its cell and then runs the normal pass, which updates the scripts and the `=` columns.
- **Unknown keys fail the run.** If the cell no longer holds the `old` value, that change is reported and skipped, so a stale file doesn't overwrite later edits.
- It prints a summary of what was applied.
- When LX builds produce a tweaks file, I can pull it over SSH from LX's `~/.local/share/godot/app_userdata/Bastion Line/tweaks/`.

## As built (2026-10-21)
- **Where things live:**
  - `scripts/dev/Tuner.gd` is the data side: fields, set and revert, refresh, derived values and export.
  - `scripts/dev/TunerPanel.gd` is the content.
  - `scripts/dev/TunerWindow.gd` is the native window and docking.
  - `Boot.tuner` holds the window. Boot opens it on `--dev`, and F8 toggles it.
- **Field count:** 1,578, the same keys `balance.mjs --keys` lists. Two kinds of number aren't fields:
  - leak costs, which are derived;
  - arrays inside an entry, such as the Colossus's phases, which `balance.md` doesn't own either.
- **Docking:** when the game window leaves no room on its right, the tuner docks inside the screen's right edge.
- **Editing:** numbers are typed into a box, with − and + buttons (a step of the number's own size).
- **Exports:** `tweaks-<date>-<time>.json`, saved as `{game, made, changes: [{key, old, new}]}`.
- **Tests:** `test_live_tuner` and `test_live_tuner_panel`. The panel test holds the derived values to balance.md's `=` cells.

## Phases (built as three commits in one PR into v4-dev.1, branch `feat/80-live-tuner-core`)
1. **Data and core:**
   - the `static var` conversion;
   - `Tuner.gd` with set, revert, refresh and the tuned-run flag;
   - `Enemy.retune()`;
   - `balance.mjs --apply`.
   - No UI yet. Tests and `check` should come out byte-identical.
2. **Window:** `TunerWindow`, docking, tabs, derived values, the Changes tab, the readout, export, and the `--dev` launch path.
3. **LX and docs:**
   - the dev launcher in `dev.sh lx`;
   - a README "Live tuner" section, a CLAUDE.md line, and CHANGELOG lines;
   - spec copies to Apollyon and LX.

## Critical files
- **New:** `scripts/dev/Tuner.gd`, `scripts/dev/TunerWindow.gd`, `design/live_tuner.md`.
- **Edited:**
  - `scripts/Boot.gd` (the flag) and `scripts/ui/GameScreen.gd` (open the window; TUNED in the top bar);
  - `scripts/entities/Enemy.gd` (`retune`) and `scripts/core/Game.gd` (refresh hooks, no medals or RP on tuned runs);
  - `scripts/core/EnemyTraits.gd` (cache clear);
  - the `data/*.gd` files (`const` → `static var`);
  - `tools/balance.mjs` (`--apply`), `tools/tree_rework_data.mjs` (`static var` output) and `tools/dev.sh` (the LX dev launcher).
- **Reused:**
  - `Game.apply_research` refresh;
  - `Modifiers.apply`, `Enemies.strength`, `Waves.hp_scale`/`speed_scale`/`threat_budget`;
  - `SaveManager._write_json_atomic` for the export;
  - `UiKit` helpers;
  - the `balance_lib` reader and writer.

## Verification
- `tools/dev.sh check`, `test` and `tour` all pass. Phase 1 leaves `balance.md` and the generated data unchanged.
- **New unit tests:**
  - `Tuner.set` on Drone HP changes live enemies' `max_hp` and keeps their HP percentage, and `revert` restores it;
  - a tower damage edit changes `t.stats().damage` on a placed tower;
  - a tuned run awards no medal or RP;
  - the GDScript DPS port matches the `=DPS` cells.
- **`--apply` round trip:**
  - export Drone HP 70→300 and apply it: `balance.md` and `enemies.gd` show 300 with leak 2, and `check` passes;
  - a stale `old` value is skipped and reported;
  - revert and confirm `git diff` is clean.
- **Manual:** launch with `--dev`, check the window docks and follows, change a Siege Mech's armor mid-wave and watch the field update, then export.
- Push the build to LX with `tools/dev.sh lx`. The owner tests it with the dev launcher.
