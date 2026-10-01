# Bastion Line: working in this repo

A Godot 4.7 tower defense game (GDScript, gl_compatibility renderer). Two people work on it: the
owner, who decides and playtests, and Claude, who implements. Details of the game are in README.md.

## Every change goes through a pull request

`main` is protected: it only takes pull requests whose CI checks pass. Never push to `main`.

1. **Start from an issue.** Find or create it (`gh issue list`, `gh issue create`). Use the
   templates' labels and a milestone if it belongs to one.
2. **Branch:** `feat/<issue>-slug`, `fix/…`, `perf/…`, `balance/…`, `design/…` or `chore/…`.
3. **Work in small commits.** Before pushing, run `tools/dev.sh check` and `tools/dev.sh test`. If
   you changed anything visual, also run `tools/dev.sh tour`.
4. **Open the pull request:** `gh pr create`, using the template.
   - Put `Closes #<issue>` in it.
   - Add a line to `CHANGELOG.md` under Unreleased.
5. **Wait for CI:** `gh pr checks --watch`. Then give the owner the test-build link: the run's
   Artifacts, `BastionLine-<branch>-<sha>-windows` / `-linux`.
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
| `test [--only=x]` | Headless test suite. Every `test_*` method runs; the list in TestRunner.gd only sets the order. |
| `tour` | Screenshot tour with interaction checks |
| `compare` | Full vs cached tower drawing, pixel by pixel |
| `perf [--update]` | Render counts against `tests/perf_budget.json`. Use `--update` only for an intended increase, and say so in the pull request. |
| `build [windows\|linux\|all]` | Exports to `build/` |
| `version x.y.z` | Sets the version everywhere |

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
