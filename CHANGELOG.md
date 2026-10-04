# Changelog

Every pull request adds a line under **Unreleased**. Releasing turns that section into the new
version's: `## [x.y.z] - date`. The release workflow publishes that section as the release notes,
so write for players.

## [Unreleased]

## [3.6.0] - 2026-10-04

### Added
- **Sandbox mode:** tick Sandbox on the sector screen for a test bench. Credits and shields are infinite, upgrades are free (branch cards get a Max button), selling refunds everything, and the abilities have no cooldown. Press S for the Spawner: click any enemy to send it (x1 / x5 / x10 / x25), call any round's real wave, clear the field, and switch research between All / Mine / None. Towers show live DPS, damage and kills in their panel. Nothing is saved or earned (#47).

## [3.5.4] - 2026-10-04

### Changed
- **Round counter on the Launch button:** it shows the round in every state (ROUND 3 / 40, or ROUND 3  ENDLESS), with the action under it. Boss rounds read BOSS ROUND and the last one FINAL ROUND, in red.
- **Top bar:** the map and difficulty are bigger and share one line; the round label moved to the Launch button.
- The sector banner at round 0 and the Round / Boss Round banners are gone.

### Fixed
- The sector banner no longer shows through the Research Lab at round 0 (#39).
- Laser Lance beams (every branch, including the Sweeper) start at the tip of the barrel instead of the middle of the tower (#44).
- Sweeper beams no longer stay on screen after a round ends (#45).

## [3.5.2] - 2026-10-02

### Added
- **Tower panel:** clicking a tower opens its panel on the side of the screen away from the tower.
  - It shows the tower's combat stats and the next upgrade on each branch as cards: name, price, key, stat changes and description.
  - Cards you can't buy yet stay visible and say why: credits, research, secondary capped or branch locked.
- **Upgrade preview:** in the upgrade tree, clicking an upgrade plays a live preview of it. Your tower fights a looping wave of enemies picked to show the upgrade off (armored for shred, flyers for anti-air, crowds for splash...), in the current sector's look.

### Changed
- **Upgrade tree:** it's for reading and planning; upgrades are bought in the tower panel (or with U / I / O). Its window is bigger, with the preview and the upgrade's details under the tree.
- **Bottom bar:** no longer has upgrade buttons.
- **Shop:** after placing a tower picked from the shop, the shop stays open for the next build (the new tower isn't selected). Pressing B with a tower selected swaps its panel for the shop.
- **Research applies at once:** research bought or reset in the middle of a run takes effect immediately. Tower boosts reach towers already built, masteries can be bought straight away, and starting credits and shields are granted (or taken back) on the spot.
- **Flechette volleys** draw one trace per flechette, scattered across the cone.
- **Research Lab:** research nodes are 50% larger, with roomier columns, and the selected node is drawn larger still, with a pulsing outline.

### Fixed
- Power-node tiles no longer have a black box under the boost hexagon.
- The MASTERY burst no longer plays when a secondary upgrade is bought on a mastered tower.
- The mouse wheel no longer zooms the battlefield while a menu (research, Codex, upgrade tree, pause) is open or the mouse is over the HUD.

### Behind the scenes
- **Development workflow:** the dev scripts (`tools/dev.sh`, `tools/dev.ps1`) are now in the repo, with a CI test build for every branch.
- **New checks:**
  - **Every script compiles.**
  - **New tests always run.**
  - **No slow draw calls in per-frame code.**
  - **Design data matches the design docs.**
  - **Render counts stay within budget.**
  - **Cached towers look identical to fully drawn ones.**
- **Version:** shown in the main menu from a single setting (`tools/dev.sh version x.y.z`).
- **Releases:** pushing a version tag builds and publishes the release, using that version's changelog section as the notes.
- **Models:** plans are made on Opus 5.5 (high effort) and carried out on Sonnet 5.5 (medium effort); see CLAUDE.md.

## [3.5.1] - 2026-09-30

### Changed
- **Performance:** the battlefield draws 4-7× faster, with the same look.
  - **Terrain** is drawn once and reused.
  - **Shapes** (circles, rings, arcs, polygons and outlines) come from cached textures and quads.
  - **Turrets:** each turret's static parts are drawn once per look and rotated to its aim; only moving parts are drawn live.
  - **Other cached parts:** base plates, mastery rings, Shredder saws and Cryo snowflakes.
  - **Result:** round 70 on Hard with 73 towers runs at 91 fps on an i7-12700K and RX 9070 XT (about 15-20 fps before).
- **Builds** include the playtest notes folder.
- **Performance probe:** `BastionLine.exe -- --perf=canyon,hard,70` plays to a round and prints frame times per layer.

## [3.5] - 2026-09-27

### Added
- **The Codex:** an in-game encyclopedia of every tower, enemy, effect, battlefield feature and rule.
  - **Opening it:** from the main menu, or in battle with `K`, `F1`, the top-bar button or the upgrade tree's link; the battle pauses.
  - **Towers:** the whole upgrade path with exact stat changes.
  - **Enemies:** abilities with their real numbers, health and credits by round, and counters.

## [3.4] - 2026-09-27

### Added
- **Zoom and pan:** the mouse wheel zooms (up to 2.5×); middle-drag or the arrow keys pan; `Home` resets.
- **Graphics options:** VSync, frame cap, visual effects level, screen shake and an FPS counter (`F3`).
- **Target priority (`G`):** towers that hit both air and ground can prefer one.
- **Research Lab carousel**, with keyboard controls.

### Changed
- **2×2 towers:** the Scrapyard and Drone Bay take a 2×2 block.
- **Naming:** Stock → Retrofit, then T1-T4 and a Mastery on each branch.
- **Stock look:** towers keep their stock name and colour until their primary locks in.
- **Mastery research** needs every other node in the tower's tree.

## [3.3] - 2026-09-27

### Changed
- **Starting credits:** runs start with 500 credits.
- **Launch:** a big Launch button.
- **Pause menu:** Restart Sector.
- **Tower card:** boost percentages.
- **Laser Lance:** shows its charge time.
- **Lanes:** direction arrows between rounds.
- **Railgun:** tracers run to the edge of the screen.
- **Menus:** rounded corners and open/close animations.

## [3.2.1] - 2026-09-27

### Fixed
- **Secondary branch:** it can take its 2nd upgrade after the primary locks in.
- **Cleared rubble:** it disappears from the field.
- **NEXT strip:** it fits its button.
- **Track corners:** they're rounded cleanly.

## [3.2] - 2026-09-26

### Added
- **Standalone builds:** Windows and Linux, with no Godot install needed.
- **Title screen:** a drawn one.
- **Any window size:** the game scales to any window size or shape.
- **15 towers:** each with three branches and a mastery.
- **New towers:** Nullifier, Nova Reactor, Drone Bay and the Scrapyard.
- **Economy:** kill credits grow with enemy health, and tower prices rise on the harder modes.
