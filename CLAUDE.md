# Bastion Line: working in this repo

A Godot 4.7 tower defense game (GDScript, gl_compatibility renderer). Two people work on it: the
owner, who decides and playtests, and Claude, who implements. Details of the game are in README.md.

## Models

- **Planning** (plan mode: design rounds, bug triage, the plan itself): Opus 5.5, high effort.
- **Carrying out an approved plan:** Sonnet 5.5, medium effort.

This is automatic: the owner's Claude Code user settings use `opusplan`, which switches from Opus to
Sonnet when a plan is approved, with the effort set per model. So plan in plan mode. If a session
is on the wrong model for the phase, say so; the owner switches with `/model`.

## Designing a feature first

For a **new feature or a rework** of an existing one (not bug fixes or small tweaks), design it
with the owner before writing any code.

1. **Ask questions, lots of them, in rounds.** Each round builds on the answers to the last. Keep
   going until nothing important is unclear.
   - Use multiple choice (AskUserQuestion) where there are clear options.
   - Ask open questions for creative matters: look, feel, names.
   - Never fill a gap with an assumption.

   Cover:
   - **Purpose:** what it's for, and the player experience it should create.
   - **Rules and numbers:** costs, limits, timings, stacking, how it scales by round and difficulty.
   - **Interactions:** towers and branches, research, difficulty modes, the economy, saves (format
     bump?), the bot, the Codex, the design pages.
   - **UI and controls:** where it lives, keys, feedback, tooltips, what the player sees.
   - **Visuals and sound:** look and animation, within the drawing performance rules below.
   - **Edge cases:** old saves, endless mode, 2×2 towers, flyers, bosses, selling and refunds.
   - **Balance targets:** how strong and how expensive, and how to check it with the bot probe.
   - **Scope:** what's out, and whether it ships in phases.
   - **Acceptance:** how we'll know it's right, and what the tests must check.
2. **Write the answers down.**
   - **Big features** (a new system, many files, a save change) go in `design/<feature>.md`, like
     `design/upgrade_trees.md` and `design/super_structures.md`. Give it an Open questions section.
   - **Small ones** get a spec in their issue.
   - Link the doc from the issue.
3. **Get the owner's confirmation** of the spec before creating the branch. Questions that come up
   while building go back to the owner too.
4. **Map the pull request to the spec.** Its description says which points it covers and any it
   leaves for later.

## Every change goes through a pull request

`main` is protected: it only takes pull requests whose CI checks pass. Never push to `main`.

1. **Start from an issue.** Find or create it (`gh issue list`, `gh issue create`).
   - Give it the templates' labels, and a milestone if it belongs to one.
   - Add it to the board with `--project "Bastion Line"`:
     https://github.com/users/Swooshiiroll/projects/1.
   - Columns: Backlog → Next → In progress → In review → Done.
   - Move the issue as work moves: `gh project item-edit`, or drag it on the board.
2. **Branch:** `feat/<issue>-slug`, `fix/…`, `perf/…`, `balance/…`, `design/…` or `chore/…`.
3. **Work in small commits.**
   - **Unit tests:** every behaviour change adds or updates unit tests in `tests/TestRunner.gd`.
   - **Before pushing:** run `tools/dev.sh check` and `tools/dev.sh test`.
   - **Visual changes:** also run `tools/dev.sh tour`.
4. **Open the pull request:** `gh pr create`, using the template.
   - Put `Closes #<issue>` in it.
   - Add a line to `CHANGELOG.md` under Unreleased.
5. **Wait for CI:** `gh pr checks --watch`. Then give the owner the test-build link: the run's
   Artifacts, `BastionLine-<branch>-<sha>-windows` / `-linux`.
   - **After every build, run `tools/dev.sh lx`.** It puts the build on Corundum-LX, where the owner
     playtests.
     - **Where:** each build gets its own folder inside
       `/home/swooshii/Documents/Bastion Line Testing`, named `<date> <time> <branch> (<commit>)`,
       with a BUILD.txt saying what it is. Older builds are kept.
     - **If LX is off,** it says so, and nothing else changes.
6. **Merge only when the owner says so:** `gh pr merge --squash --delete-branch`.

**Releasing:**
1. Move the Unreleased notes under a new `## [x.y.z] - date` heading.
2. Run `tools/dev.sh version x.y.z`.
3. Merge that pull request, then tag: `git tag vx.y.z && git push origin vx.y.z`.
4. The release workflow builds and publishes it. The codex PDF is still made by hand when it changes (README, "Codex PDF").

## Commands (`tools/dev.sh`, or `tools/dev.ps1` from PowerShell)

| Command | What it does |
|---|---|
| `import` | First run on a fresh checkout |
| `check` | Static checks: draw lint, design data in sync, version consistent |
| `test [--only=x]` | Unit tests (`tests/TestRunner.gd`, headless). Every `test_*` method runs; the list in TestRunner.gd only sets the order. CI runs them as the `unit-tests` check. |
| `tour` | Screenshot tour with interaction checks |
| `compare` | Full vs cached tower drawing, pixel by pixel |
| `perf [--update]` | Render counts against `tests/perf_budget.json`. Use `--update` only for an intended increase, and say so in the pull request. |
| `build [windows\|linux\|all]` | Exports to `build/` |
| `version x.y.z` | Sets the version everywhere |
| `lx` | Builds Linux and puts it in a new folder for this build inside Corundum-LX's `Bastion Line Testing` (skipped if LX is off) |

Logs go to `out/`.

## Rules that are easy to break

- **Drawing every frame:**
  - Never call `draw_circle`, `draw_arc`, `draw_colored_polygon` or `draw_polyline` directly. In
    this renderer they cost 12-30 µs each; use `Draw.disc`, `ring`, `arc`, `poly` and `polyline`.
  - A turret's animated parts go between `Draw.dyn(true)` and `dyn(false)`, and everything else in
    its drawer must be static. `check` and `compare` enforce both. See README, "Performance probe".
- **Renderer:** keep `gl_compatibility`. The owner plays over Remote Desktop at times.
- **Upgrade data:** edit `design/upgrade_trees.md`, then regenerate:
  - `node tools/tree_data.mjs` writes `data/tower_trees.gd`;
  - `node tools/tree_page.mjs` and `node tools/super_page.mjs` write the design pages.

  Commit the outputs too; `check` fails if they're stale. The editable design pages are pulled back
  with `tools/design_pull.mjs` before regenerating.
- **Playtest folder:** builds include `playtest/`, the owner's notes. The folder itself isn't
  committed.
- **Backups:** before editing a critical file outside this repo, copy it to
  `D:\<Device>\<DriveLetter>\<path>`.
- **Godot MCP:** never switch the `godot` MCP server to npx; it's pinned to a source build.
