# Changelog

Every pull request adds a line under **Unreleased**. Releasing turns that section into the new
version's: `## [x.y.z] - date`. The release workflow publishes that section as the release notes,
so write for players.

## [Unreleased]

### Added
- **Tower rework, first piece (in progress, #59):** the new Gun Turret joins the shop beside today's towers. Its three paths (Power, Range/Visibility, Multi-Target) open from the start, and its Retrofit is a choice of three (press Y, then 1-3) that is locked once fitted. It crits, pierces armour, and can stun or ignite; the Multi-Target path adds flank guns that turn on their own. Every enemy now has a role, and every hit is tagged physical or energy, ready for the rest of the rework.
- **Tower rework, batch 1 (in progress, #59):** the new Mortar Tower, Rocket Salvo, Laser Tower and Anti-Aircraft Turret join the shop beside today’s towers, each with a Retrofit of three and three open paths. Mortar shells ignore armour and scatter cluster bomblets; the Rocket Salvo sends each rocket at a different enemy; the Laser ramps on every beam separately and melts armour for good; the Anti-Aircraft Turret fires flak that bursts on every flyer nearby.
- **Tower rework, batch 2 (in progress, #59):** the new Artillery Cannon, Railgun and Tesla Tower join the shop. Click the track to aim the Artillery Cannon and pick its shell from the panel; the Railgun pierces everything on its line, shatters armour and leaves a burning ion trail; the Tesla Tower chains arcs that stun, overload Disruptors and leave storms.
- **Tower rework, batch 3 (in progress, #59):** the new Drone Bay and CAS Gunship join the shop. The Drone Bay sends one drone (two with the Second Hangar) hunting anywhere, with a loadout you switch on its panel. The CAS Gunship orbits a point you click and fires three guns, one per path; every path takes every upgrade and its own mastery.
- **Tower rework, batch 4 (in progress, #59):** the new Mine Layer, Chemical Plant, Cryo Tower and Boost Tower join the shop. Mines lie on the track and go off under walkers and burrowers; the Chemical Plant soaks one enemy at a time, stripping armour (for good with Corrosive Acid); the Cryo Tower pulses slowing mist; the Boost Tower strengthens towers around it, the strongest boost of each kind winning.
- **Tower rework, batch 5 (in progress, #59):** the new Radar Tower, Shockwave Generator and Scrapyard join the shop. The Radar pings to reveal cloaked and burrowed enemies and burns the ones it reveals; the Shockwave Generator hits everything around it, cloaked or not, with barriers breaking faster on its Effect path; the Scrapyard pays at each round clear and fields boost kills, discounts and sell-backs.
- **Tower rework, batch 6 (in progress, #59):** the last three new towers, the Magneto Tower, Tractor Tower and Augmentation Tower, join the shop. The Magneto slows and strips armour in a field, with heavier roles resisting more; the Tractor Tower grabs one enemy and hauls it back along the track; the Augmentation Tower gives nearby towers crits, energy damage and ricochets.
- **Enemy rework, groundwork (in progress, #68):** every enemy now has a tier within its role, matching the new roster (the Drone is a Swarm, the Bulwark a Support, the Burrower an Evader, the Rampart a Tank, the Dreadnought a Boss, the Aegis Walker and the Phantom Specials), and a strength score. Each enemy ability now runs on its own timer, so one enemy can carry two. Nothing else changes in play yet, apart from how much the reworked Magneto and Tractor towers' slows and pulls bite on the seven re-roled enemies.
- **Strongest goes by strength, and a Support priority (in progress, #68):** Strongest targeting now picks the strongest kind of enemy first (by its speed, armour and health, with every boss above the rest), then the one with the most health left, then the one furthest along. G now sets a fourth priority on every tower that picks targets, Support, which goes after Repair Bots, Rally Beacons, Bulwarks and Mender Hulks first and falls back to everyone else. The Rocket Salvo, Chemical Plant and missile towers now honour the priority too. Locusts have 15 health (was 18), Strike Drones 100 (was 64) and Gunships 600 (was 420), so each tier is stronger than the one below.
- **New rounds and elites (in progress, #68):** one generator now makes every round, the same on every playthrough, sector and mode; the hand-made rounds 1 to 25 are gone, and a new enemy leads every other round. From round 10 elites arrive: single enemies with a gold ring and a label naming their modifiers (Shielded, Hasty, Regenerating, Plated, Cloaked, Splitting, Jamming, Resolute, Commanding), up to two from round 40 and three from round 80; they pay double and cost a shield more if they leak. Bosses now come every 20 rounds (the Dreadnought at 20, the Overmind at 40, the Leviathan at 60, the Colossus at 80, then mixes) instead of a Dreadnought every 5th round, and a boss met once can turn up again. Enemy health grows more slowly (from round 60 it compounds 1% a round, was 4% from round 40), so late difficulty comes from tougher enemies and elites. The Intel panel, NEXT strip and enemy card show each enemy's role and tier, and the elites.
- **Twelve new enemies (in progress, #68):** the Needle (pairs), Fury Drone (adrenaline), Shrike (flying clusters of five), Titan (sheds its plates), Siphon (drains nearby towers), Blackout Rig (a bigger Jammer), Capacitor (a telegraphed blackout you can cancel with a stun, a silence or Overload Circuits), Shifter (blinks and speeds others up), Wraith (a cloaked flyer only energy hurts), Masquerade (disguised as a Drone), Decoy Beacon (bait for Strongest towers) and Mirage (holograms that soak shots). The Phantom now flies, along the track. A leak now costs shields by the enemy's strength (1 to 4, one more for an elite), and a boss costs its introduction round (20 to 80). After an EMP a tower can't be knocked offline again for 1 s.
- **Enemy art (in progress, #68):** every enemy has its new look, animation and way of moving on the lane, as designed in the enemy art rounds: a machine army whose roles share family traits (Swarm, Rusher, Tank, Support, Disruptor, Evader, Special, Boss). Their effects follow the game: a Jammer's antennae arc as its EMP rings out, a Bulwark's wings open as it hands out barriers and it holds still meanwhile, a Titan's plates fall away at half health, the Colossus's Siege Mechs climb down from its back, a Burrower vanishes underground and shows only inside a Radar ping, and the Phantom and Wraith shimmer until revealed. Some weave, swerve or side-step within the lane at the same average speed; a Shrike cluster spreads across it in formation.
- **Codex, Spawner and probe for the enemy rework (in progress, #68):** every enemy's Codex page shows its role, tier and strength, a line for each of its abilities, and the modifiers it can arrive with as an elite; new Codex pages list the roles and tiers and every modifier with the round it first appears. In Sandbox, the Spawner lays the enemies out by role and tier and has toggles for the nine modifiers, so any elite can be sent. The printable Codex is rebuilt for the new towers and enemies.

### Changed
- **The tower swap (#59):** the fifteen old towers are gone; the shop holds the twenty new ones, and there are no build hotkeys any more (pick towers in the shop; 1 to 3 pick a Retrofit). Their Research Lab trees are gone too (research bought in them is refunded), the title screen shows the new towers at their masteries, and the Codex describes each new tower's Retrofits and paths. Saves from before the swap can't be loaded. The upgrade tree view (E) and its live preview only worked for the old towers and are gone until a version for the new towers is designed. The bot that plays the balance tests now builds the new towers.
- **The Radar Tower's Special Targeting path works (#86):** its upgrades did nothing before. Signal Analysis now sees through a Decoy Beacon (it ranks as what it is, so Strongest towers stop chasing it), Disguise Breaker uncovers a Masquerade with a ping, Illusion Filter marks a Mirage's holograms with a red cross and towers stop shooting them, and Total Exposure keeps whatever a ping found revealed while it stays in range and for 5 s after it leaves (a Burrower can't dive meanwhile). Revealed flyers now show the reveal brackets too, gold while Total Exposure holds them.
- **Upgrades add, and towers start unloaded (#85):** every upgrade now adds to the stat it improves instead of replacing it, so a Retrofit and a second path stack with the main path (a Water-Cooled Barrel and Belt Feed take the Gun Turret from 1.2 to 1.8 shots a second instead of the path undoing the Retrofit); each path alone ends where it did. A new tower, and every tower when a round starts, loads before its first shot. The Swivel Mount turns onto a new target faster instead of skipping its reload after a kill, so the Gun Turret's fire rate no longer jumps when it switches. Mortar shells land where they were aimed (ahead of a walking target) instead of following it, Smoke Shells leave a visible cloud over the area they slow, burning enemies show bigger flames, and the Drone Bay takes 2×2 tiles.
- **The live tuner starts undocked (#94):** it still opens beside the game's window, but can be dragged anywhere straight away; tick Dock to make it follow the game.
- **Upgrade tree, Move target, Research in Sandbox, a tidier shop (#87):** E (or the tower panel's Tree button) opens the selected tower's whole upgrade tree and pauses: Retrofits on the left, each path a row of steps up to its mastery, every tile showing its cost and whether you own it, can buy it, can't afford it, need research or are locked out; hover for what it does, click a gold tile to buy. The Artillery Cannon and CAS Gunship get a Move target button (M): the next click sets the target, and a plain click no longer moves it. In Sandbox the Research Lab opens too (R, beside the Spawner); it's your real research, and buying switches the run to Mine. The shop is grouped by class, cheapest first, and towers you can't afford are greyed out. The Retrofit cards and the Spawner's buttons and names stay inside their borders.
- **Blinks round corners, and the Leviathan over its swarm (#88):** after a Blink Stalker or Shifter blinks, its after-image stays on the lane where it blinked from instead of hanging off the track past a corner, and it lands facing along the track rather than along the jump. The Leviathan is drawn over the Locusts it launches.
- **Smoother towers and circles (#89):** the three dark dashes on each side of every tower's hex deck are gone. Circles and curves stay round however big they are (the Chrono Field's ring was a polygon), and a turning tower no longer jumps every 45°: its shading now fades from one angle to the next.
- **Tower art against the design pages, group 1 (#90):**
  - **Every tower:** thick barrels and struts have round ends, as on the design pages (the Mortar's tube gets its rounded back), and the long lances and barrels of the Laser, Railgun and Anti-Aircraft Turret are no longer cut off.
  - **Gun Turret:** the Laser Rangefinder's red ranging line shows.
  - **Mortar Tower:** shells fly a high arc, point along it, and their trail follows it.
  - **Rocket Salvo:** each rocket leaves its own tube, straight out; the tubes empty when it fires and load again as it reloads.
  - **Laser Tower:** it turns to face a new target before its beam fires.
  - **Artillery Cannon:** shells leave the muzzle and fly an arc pointing the way they go; every shell of a Rolling Barrage fires with its own recoil; the Long Penetrator's yellow band fits on the shell, and a Shell Magazine's heavy round has a red band instead of a red ring.
- **Tower art against the design pages, group 2 (#90):**
  - Every turret keeps turning toward its next enemy while it reloads, instead of waiting for its next shot.
  - Railgun: the housing recoils on every shot, the copper coils and the mouth glow as it charges, and each of the Twin Rails fires from its own barrel in turn.
  - CAS Gunship: a slimmer fuselage; the plane takes off from the tower and flies to its orbit, and to each new one, instead of jumping there (its guns keep firing on the way).
  - Mine Layer: the launcher turns to where it throws next; each mine flies on an arc and lands with a ring; mines land at random spots along the track in reach, a little either side of the middle, instead of in a row from the entrance.
  - Chemical Plant: a lobbed stream of acid drops onto the enemy instead of a straight line (gel glints, bubbles in the Concentrated Acid, and a mist for the Mist Nozzle's neighbour); the Twin Nozzles' second sprayer sprays from its own nozzle.

### Behind the scenes
- **Bot balance verdicts paused for the rework (#96):** the bot still plays every test game, but whether it wins, reaches endless or buys masteries no longer fails the tests until the tower rework is done; those results print as PAUSED.
- **Balance master (#75):** `design/balance.md` holds every tower's numbers and prices, with generated columns showing each step's paper DPS, credits spent and DPS per 100 credits, a summary of every tower and mastery, and the formulas behind them. `node tools/balance.mjs` updates it and the game data is generated from it (`design/tower_stats.md` is retired). It also holds every enemy's stats and ability numbers (with generated strength, leak cost, and health and credits by round) the elite modifiers' numbers, and the waves (the round formulas, each enemy's introduction round, threat cost, spacing and group cap, the boss line-ups, and a generated table of the formulas by round), the economy, the difficulty modes, research, the abilities and the global rules, with every tower's price on each mode. Every balance number in the game is now in that one file.
- **The bot plays the new towers (#68):** the balance tests, the probes and the tour's bot games now build the reworked towers, with Retrofits, two paths each, aimed Artillery and CAS Gunships, Drone Bay loadouts and Radars placed by the towers they help. The balance probe ends a round that never finishes as STALLED instead of running for hours, and `--mods=none` or `--mods=<list>` turns elites off or limits their modifiers.
- **Live tuner (#80):** launched with `--dev` (or `Bastion Line (dev).sh` in an LX build), the game opens a second window beside its own that changes any number `design/balance.md` owns while you play: enemies already on the field (keeping their share of health), placed towers and prices follow at once, and round changes apply from the next round. It shows the derived values (strength, leak cost, health by round, each tower step's DPS and cost), a readout of the round and the field, and a change list with revert and export. `node tools/balance.mjs --apply <tweaks.json>` writes an export into `balance.md`, skipping any number edited there since. A run with changed numbers is marked TUNED, never saved and earns nothing.

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
