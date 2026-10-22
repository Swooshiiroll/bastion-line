# Bastion Line

A sci-fi tower defense game built in Godot 4.7 (GDScript).

- **Towers:** 20 (including the Scrapyard, an economy tower), each with a Retrofit (a choice of three) and three upgrade paths
  of four upgrades plus a mastery, open from the start. You climb one path as the primary and can take up to two upgrades on a
  secondary.
- **Research Lab:** a persistent skill tree (a Command tree plus one tree per tower) bought with
  research points earned from your sector records. Mastery research unlocks each tower's masteries.
- **Enemies:** 22 robotic types, including four bosses. Some are cloaked, shielded, burrowing or
  teleporting; some split, repair, speed up or shield their escorts; some jam towers.
- **Abilities:** 2 orbital-command abilities.
- **Sectors:** 6 maps with high ground, power nodes, rubble to clear, lane hazards, and forking
  lanes with switch gates. Each earns a medal for every difficulty mode it's completed on.
- **Difficulty modes:** 5, from Easy (40 rounds, 200 shields) to Cataclysm (120 rounds, 1 shield).
  Enemies get tougher and faster every round; endless mode starts as soon as the last round is won.
- **Saves:** save and continue.

All art is drawn procedurally and all sound and music is synthesized at startup, so the project
ships no art or sound files. The glow comes from additive blending. UI text uses Windows' Bahnschrift font; on
Linux and other systems it uses the bundled Barlow font (`fonts/`, SIL Open Font License), a similar
DIN-style face.

## Playing

- **Standalone:** `build\BastionLine.exe` (about 110 MB, game data embedded). It doesn't need Godot installed,
  so you can copy it to any 64-bit Windows PC.
- **Linux:** `build/linux/BastionLine.x86_64` (about 74 MB, x86_64, game data embedded). Mark it
  executable (`chmod +x`) and run it. Tested on Nobara Linux 44 (KDE). Saves go to
  `~/.local/share/godot/app_userdata/Bastion Line/`.
- **From source** (needs Godot 4.7 installed): double-click `Play.cmd` (Windows) or run `./Play.sh` (Linux).
  Without Godot, `Play.cmd` runs `build\BastionLine.exe` if it has been built, and otherwise explains
  where to download the standalone build. A clone of the repo has no exe, because builds live on the
  GitHub releases page.
- **To edit:** `godot --path "C:\Users\anode admin\Documents\TowerDefense" --editor`, then press F5 to run.

Both the exe and the source build share the same saves and profile.

### Display

- **Any window size or shape.** Screens are designed at 1600×900 and scale to the window. On a window
  that isn't 16:9 (16:10, 4:3, ultrawide, an odd remote-desktop size) there are no black bars:
  - the layout stays centred at its designed proportions
  - backgrounds and the battlefield's surroundings run to the window edges
  - the top and bottom HUD bars stretch to the full width and stick to the window's top and bottom
  - the tower shop opens against the right edge
- **Settings:** Fullscreen, or a window size. Auto (the default) opens the largest 16:9 window that
  fits 90% of the screen; the fixed choices run from 1280 × 720 to 3840 × 2160, never larger than the
  screen. The window can also be resized freely by dragging its edges.
- **Graphics options** (Settings): VSync, a frame cap (30 / 60 / 120 / 144 / 240 or none), visual effects level
  (Low / Medium / High thins out particles), screen shake on or off, and an FPS counter (also F3).
- **Title screen:** a drawn scene rather than a live game. It shows the Bastion core on a planet's
  horizon, a ridge of mastered towers firing up at a Leviathan and its escorts, and the menu.

### Rebuilding the builds

The Windows and Linux (x86_64) export templates for 4.7.2 are installed in
`%APPDATA%\Godot\export_templates\4.7.2.stable`. They were extracted from the official release
archive after checking it against the release's SHA512-SUMS. The presets live in
`export_presets.cfg`. They leave out `screenshots/` and `tests/`, and include `playtest/` along with
its notes.

```
tools/dev.sh build all
```

This exports `build/BastionLine.exe` and `build/linux/BastionLine.x86_64`, and packs
`build/BastionLine-linux-x86_64.tar.gz`. CI and the release workflow build the same way (see
Workflow).

### Controls

| Input | Action |
|---|---|
| `B` or the Shop button | Open the tower shop. Picking a tower closes it while you place it; it reopens once the tower is placed. Clicking the field with nothing picked up closes it |
| Left-click a tile | Build (Shift+click to keep building) |
| Left-click rubble / a switch gate | Clear the rubble (40 cr) / switch which branch arriving enemies take |
| Left-click a tower | Select it: its **tower panel** opens on the right (in the shop's place) with its combat stats, its Retrofit and the next upgrade on each path as cards to buy; cards that can't be bought say why. The bottom bar shows its Retrofit, kills, paths, actions and any boosts (Boost Tower, high ground, power node, Scrapyard) as percentages |
| Right-click | Cancel build mode, targeting or selection |
| `Y`, then `1`-`3` | Fit one of the selected tower's three Retrofits (the choice is locked) |
| `U` / `I` / `O` | Buy the next upgrade on path A / B / C (the mastery after its T4) |
| `X` | Sell the selected tower (refunds 70% of everything spent on it) |
| `T` | Cycle the selected tower's targeting: First, Last, Strongest (by strength, then health left), Closest |
| `G` | Target priority: Any, Air, Ground (towers that hit both) or Support (Support enemies first); it still shoots the rest when none of those are in range |
| Mouse wheel, middle-drag, arrow keys, `Home` | Zoom the battlefield (up to 2.5×), pan it, reset the view |
| `F3` | Show or hide the FPS counter |
| `K` or `F1`, or the Codex button | The Codex: every tower, enemy, effect and rule. In battle it pauses and opens on the selected tower (or the enemy under the cursor) |
| `R` | Research Lab in battle (pauses; purchases and resets apply at once) |
| `N` or click NEXT | Intel on the next round: enemies, counts, traits, HP and speed scale, bonuses |
| `Space` or the Launch button (bottom right) | Launch the next round, or call it early for bonus credits once the current round has finished spawning |
| `Q` then click | Orbital Strike: armor-piercing blast at the clicked spot after 0.9 s (45 s cooldown) |
| `W` | Chrono Field: slows every enemy 60% for 5 s; bosses resist half (70 s cooldown) |
| `F` | Game speed 1x / 2x / 3x |
| `A` | Auto-launch the next round 5 s after each clear |
| `Esc` | Closes every open menu at once; with nothing open it cancels build/selection, then opens the pause menu |
| `P` | Pause menu (resume, restart the sector, save, settings, quit) |

### Towers and upgrade trees

Every tower has the same tree shape (the full design, with every node's stats and description, lives in
`design/upgrade_trees_rework.md` and `design/balance.md`, and its rendered view `design/upgrade_trees_rework.html`):

- **Stock:** the tower as built.
- **Retrofit:** a choice of three (one for the Drone Bay), fitted with `Y` then `1`-`3`. The choice is locked.
- **Three paths (A, B, C)**, open from the start, each **T1 to T4** plus a mastery; the mastery needs that tower's Mastery
  research.
- **A primary and a secondary.** You can climb two paths freely until one of them gets its **3rd** upgrade. That path becomes
  the primary; the other is capped where it is (at most 2), and the third path is locked as soon as two are started. A
  secondary keeps its effects. The **CAS Gunship** is the exception: every path takes every upgrade and its own mastery.
- **Physical or energy.** Every hit counts as one or the other; the Laser, Tesla, Chemical Plant, Cryo, Radar, Magneto and
  Tractor towers deal energy, and the Augmentation Tower can convert a nearby tower's damage.
- The **Scrapyard takes 2×2 tiles**; the build preview centres the block on the cursor, and it gets a high-ground or
  power-node bonus if any of its four tiles has one.
- **Aiming:** click the track to aim an Artillery Cannon (and pick its shell in its panel) or to set a CAS Gunship's orbit;
  the Drone Bay's loadout is picked in its panel.

| Tower | Cost | Class | Hits | Retrofit (one of) | Path A | Path B | Path C |
|---|---|---|---|---|---|---|---|
| Gun Turret | 75 | Assault | air and ground | Water-Cooled Barrel / Shock Rounds / Incendiary Rounds | Power → Sabot Rounds | Range/Visibility → Targeting Computer | Multi-Target → Triple Mount |
| Mortar Tower | 150 | Assault | ground | Field Kit / Bunker Sight / Smoke Shells | Power/Penetration → Bunker Buster | Speed/Range → Barrage Battery | Blast Radius/Multi-Target → Carpet Shells |
| Rocket Salvo | 200 | Assault | air and ground | Proximity Fuses / Smoke Trails / Incendiary Warheads | Power → Thermobaric Rockets | Range/Target Acquisition → Hunter Seekers | Reload/Payload → Ripple Salvo |
| Laser Tower | 250 | Assault | air and ground, energy | Capacitor Bank / Heat Sinks / Ramp Memory | Power → Annihilator | Multi-Target → Prism Array | Range/Targeting → Deep Lance |
| Anti-Aircraft Turret | 150 | Assault | air | Fire-Control Radar / Ammo Drum / Armoured Mount | Range → Sky Wall | Power/Blast Radius → Flak Curtain | Speed → Quad Mount |
| Artillery Cannon | 300 | Assault | ground | Shell Magazine / Stabilised Mount / Wide Charge | Power → Siege Shells | Speed → Rolling Barrage | Special Effects → Combined Payload |
| Railgun | 500 | Assault | air and ground | Capacitor Coils / Longer Rails / Penetrator Tips | Power → Kingslayer | Range/Speed → Twin Rails | Special Effects → Ion Cannon |
| Tesla Tower | 250 | Assault | air and ground, energy | Bigger Disk / Grounding Rods / Insulated Coils | Power/Damage → Lightning Rod | Range/Chaining → Tempest | Speed → Continuous Discharge |
| Drone Bay | 300 | Assault | air and ground | Second Hangar | Power → Elite Drones | Weaponry → Full Kit | Speed → Storm Drones |
| CAS Gunship | 650 | Assault | air and ground | Radar / Extra Ammo / Wide Orbit | Light gun → Twin Gatlings | built in → Autocannon Battery | Medium gun → Hellfire Volley |
| Mine Layer | 450 | Defense | ground | Adhesive Mines / Shaped Charges / Long Arm | Power/Damage → Anti-Tank Mines | Production Speed → Mine Factory | Range → Minefield Launcher |
| Chemical Plant | 250 | Support | air and ground, energy | Pressure Pump / Mist Nozzle / Bigger Tanks | Damage/Armor stripping → Dissolver | Speed → Twin Nozzles | Slowing → Quick-Set Foam |
| Cryo Tower | 150 | Support | air and ground, energy | Coolant Tank / Compressor / Deep Cold | Slowing → Deep Freeze | Power/Range → Blizzard | Speed → Cold Front |
| Boost Tower | 400 | Support | - | Signal Booster / Crit Link / Wide Mast | Damage boost → Battle Network | Speed boost → Rapid Network | Range boost → Overwatch Network |
| Radar Tower | 575 | Utility | air and ground, energy | Bigger Dish / Signal Processor / Early Warning | Power/Range → Microwave Array | Speed/Frequency → Constant Track | Special Targeting → Total Exposure |
| Shockwave Generator | 450 | Assault | air and ground | Wave Focus / Containment Coils / Reactor Venting | Power/Range → Megaton Wave | Speed → Chain Pulse | Effect → Shatter Shock |
| Scrapyard | 875 | Utility | - | Hammer Mill / Faster Loading / Surplus | Passive Income → Gold Foundry | Kill Income → Breaker's Yard | Discounts → Parts Exchange |
| Magneto Tower | 525 | Defense | air and ground, energy | Superconducting Coil / Field Stabiliser / Pole Shoes | Pull Strength → Absolute Pull | Field Size → Magnetosphere | Polarity → Reverse Polarity |
| Tractor Tower | 575 | Defense | air and ground, energy | Beam Sweep / Longer Hold / Faster Recharge | Pull Distance → Undo | Recharge → Supercapacitor | Grip → Gravity Hammer |
| Augmentation Tower | 650 | Support | - | Wide Aura / Amplified Bonus / Remote Link | Energy Conversion → Overcharge | Critical Hits → Executioner Link | Ricochet → Pinball |

The **Scrapyard** is the only tower that doesn't fight: it pays its credits when a round is cleared, and its paths add
kill credits, discounts and sell-backs in its field.

A mastered tower has a gold ring around its pad.

### Codex

An in-game encyclopedia, from the main menu (Codex) or in battle (`K`, `F1`, the top-bar button, or the
upgrade tree's Codex link; the battle pauses). Categories: Towers, Enemies, Effects, Battlefield and
Rules, plus a search box (`/` or Ctrl+F); Up / Down move through the list and Tab changes category.
- **Towers:** role, key, cost, reach and size, then the whole upgrade path (Stock, Retrofit, every
  branch from T1 to its Mastery), each step with its price, description and exactly what it changes.
- **Enemies:** stats, the round they first appear, every ability with its real numbers, health and
  credits by round, the towers that can hit them, and tips on dealing with them.
- **Effects, Battlefield and Rules:** armor, barriers, slows, stuns, suppression, sludge, gates,
  targeting, economy, research and the rest, with See-also links between them.

Tower and enemy pages are generated from the game data (`scripts/core/Lore.gd`); the rest is written in
`data/glossary.gd`, whose numbers are placeholders filled from the game's constants, so the Codex can't
drift from the rules.

### Research Lab

Open it from the main menu (or the end-of-run screen). The trees sit side by side in a carousel: Left / Right or
the mouse wheel move to the previous or next tree (the focused one is centred and full size), Up / Down
pick a node in it, and Enter researches it. Every tree is a small diamond: a root
node, two branch nodes, and a Mastery capstone that needs everything else in its tree. Research is bought with research
points (RP) and applies to every run you start afterwards. A saved run keeps the research it
started with. Reset Research refunds everything for free.
Since v3.4 a Mastery needs every other node in its tree. A profile that bought a Mastery with only one
branch gets that Mastery's RP refunded on load, to spend again once both branches are done.

- **Earning RP.** RP is worked out from your records, so it can't be farmed or lost:
  - each medal pays its mode's RP (Easy 1, Medium 2, Hard 3, Nightmare 4, Cataclysm 5)
  - 1 RP per sector for each of rounds 20, 40, 60, 80 and 100 reached (on any mode)
  - 1 RP per 10 endless rounds past a mode's last round, up to 5 per sector

  That's 150 RP across the 6 sectors. The whole lab costs 170 with the twenty tower trees, so it can't all be bought
  yet; the research pass of the tower rework (#59) sets the final tree sizes and prices.
  Profiles from before v3.0 keep the RP their old records earned as **legacy RP** (shown in the lab);
  the old records themselves are cleared, since they were 25-wave runs under different rules.
- **Command tree** (10 RP):
  - Reserve Funds: +10% starting credits
  - Salvage Protocols: sell refund 85%
  - Reinforced Core: +10% shields, rounded down (Cataclysm stays at 1)
  - Bounty Contracts: +8% kill credits
  - Orbital Uplink: abilities recharge 20% faster
- **Tower trees** (8 RP each, 20 trees, a minimal tree each until the research pass). Each has a root bonus (usually +6%
  damage), two branch nodes (usually range and fire rate), then the Mastery.

  A tower's Mastery research unlocks all three of its masteries.

### Enemies

Every enemy's health and speed scale with the round number, the same on every sector and mode (see
[Rounds and scaling](#rounds-and-scaling)). "From" is the first round it can appear.

| Enemy | From | Traits |
|---|---|---|
| Drone | 1 | Basic |
| Nanite | 2 | Tiny, comes in swarms |
| Skitter | 3 | Fast, fragile |
| Repair Bot | 5 | Heals nearby non-boss enemies |
| Siege Mech | 7 | 6 flat armor per hit (minimum 20% of damage gets through) |
| Jammer | 9 | EMP every 5 s knocks towers within 95 px offline for 2 s |
| Blink Stalker | 11 | Teleports 80 px down the lane every 4 s. A slow or stun resets the charge |
| Phantom | 13 | Cloaked flyer that follows the track. Towers that hit air can only target it when a Radar Tower ping reveals it, or for 0.5 s after damage hits it while hidden |
| Locust | 15 | Tiny, fast flyer in dense swarms. Flak's favourite target |
| Aegis Walker | 17 | Energy barrier (scales with HP) soaks damage before armor applies and recharges after 2.5 s untouched. Tesla Tower arcs hit barriers twice as hard |
| Needle | 19 | Very fast, light; always in pairs on one lane |
| Rally Beacon | 21 | Other non-boss enemies within 100 px move 25% faster (doesn't stack). Kill it first |
| Mirage | 23 | Every 6 s projects two 1-HP holograms that soak shots, never leak and vanish with it |
| Strike Drone | 25 | Quad-rotor flyer; flies straight from the warp gate to the core, ignoring the lane |
| Siphon | 27 | Towers within 100 px fire 20% slower and reach 15% less far (the strongest Siphon applies) |
| Hydra Frame | 29 | Armored walker that splits into three Skitters when destroyed |
| Burrower | 31 | Tunnels under the lane for 2.5 s every 5 s: untargetable, unhurt and immune to lane hazards while under |
| Bulwark | 33 | Every 6 s gives nearby non-boss enemies (not itself) a barrier worth 25% of their health |
| Rampart | 35 | Immune to slows, stuns and shoves; 8 armor |
| Decoy Beacon | 37 | Ranks above every non-boss so Strongest towers aim at it; does nothing else |
| Blackout Rig | 39 | A bigger Jammer: EMP radius 130, towers offline 2.5 s every 4 s |
| Shifter | 41 | Blinks 60 px every 5 s; others where it lands get +20% speed for 2 s |
| Gunship | 43 | Armored heavy flyer (5 armor) |
| Masquerade | 45 | Looks, moves and ranks like a Drone (purple eye) until below half health, then flees |
| Shrike | 47 | Flying clusters of five |
| Fury Drone | 49 | +30% speed below half health (multiplies with other boosts) |
| Mender Hulk | 51 | Regenerates 4% of its health per second after 1.5 s without taking damage |
| Wraith | 53 | Cloaked flyer that only energy damage hurts (beams, chains, fields, burns, Tesla arcs) |
| Capacitor | 55 | Charges 2 s, then blacks out towers within 160 px for 3 s, every 8 s; a stun, silence or Overload Circuits arc cancels the charge |
| Titan | 57 | 9 armor, half resists slows; at half health sheds to 5 armor and speeds up 20% |
| **Dreadnought** (boss) | 20 | Boss of round 20, back in every later boss round. Armored, half-immune to slows, costs 20 shields if it leaks |
| **Leviathan** (boss) | 60 | Flying carrier that launches 6 Locusts every 6 s. Boss of round 60. Costs 60 shields |
| **Overmind** (boss) | 40 | Spawns Nanites as it advances. Boss of round 40. Costs 40 shields |
| **Colossus** (boss) | 80 | Can't be stunned. At 66% and 33% health it sheds 5 armor, speeds up 20% and drops two Siege Mechs. Boss of round 80. Costs 80 shields |

A leak costs shields by the enemy's strength: 1 below 50, 2 below 150, 3 below 400, else 4 (one more for an
elite); a boss costs its introduction round. After an EMP wears off a tower can't be knocked offline again for
1 s.

Bosses get half the round speed bonus and resist slows and shoves. After a stun wears off, an enemy
can't be stunned again for 1 s, and shoves can push any one enemy back at most 320 px in total.


### Abilities

Abilities recharge only while a round is running and can only be cast then. Orbital Strike damage grows
with the round number, so it stays useful late. The HUD's bottom-left buttons show the cooldown.

### Sectors, modes and medals

Sectors are pure maps: every run starts with 500 credits, and enemy strength depends only on the
round. What makes a sector harder is its layout.

| Sector | Layout |
|---|---|
| Outpost Theta | One winding lane; a high-ground ridge inside the loop, a power node, some rubble |
| Red Rift | Long switchbacks with sludge on two turns and high-ground mesas; flyers take a short diagonal |
| Cryo Delta | The lane forks around an ice island: short north branch or long slushy south branch, one switch gate |
| Nexus Station | Two warp gates that merge; shock strips before the merge, power nodes beside it |
| Foundry Nine | Shock conveyors or a long safe loop behind one gate; rubble everywhere, so clearing it buys build space |
| Singularity Array | Two warp gates, each with its own fork and gate, converging on the core |

Pick a mode on the sector select screen. It sets how long the run is, how many core shields you
get, and what towers cost (to build and to upgrade). Easy to Hard are meant to be gentle, Nightmare
hard, and Cataclysm brutal:

| Mode | Rounds | Shields | Tower prices | Medal RP |
|---|---|---|---|---|
| 40 | 200 | ×1.0 | 1 |
| 60 | 100 | ×1.0 | 2 |
| 80 | 50 | ×1.1 | 3 |
| 100 | 25 | ×1.5 | 4 |
| 120 | 1 | ×2.0 | 5 |

- Clearing a mode's last round earns that sector's **medal** for the mode (a banner announces it and
  it's recorded at once), and **endless mode** begins straight away: the rounds keep coming until the
  core falls. There are 30 medals in all; each sector card shows its row of five.
- Every 20th round is a **boss round**, so each mode's last round is one (Easy: the Overmind and a
  Dreadnought; Cataclysm: two Colossi, a Leviathan, two Overminds and three Dreadnoughts).
- On Cataclysm a single leak ends the run.

### Rounds and scaling

- **One generator** makes every round, seeded by the round number alone, so a round is the same on
  every playthrough, sector and mode. It spends a threat budget that grows every round on the enemies
  met so far, favouring recent ones. A new enemy leads its round every two rounds (`Waves.INTRO`).
- **Elites** (from round 10): single enemies with modifiers, a gold ring and a label. Their share of
  the budget grows from 10% to 30% by round 60 (design/enemies.md, section 4).
- **Bosses**: every 20th round has a boss line-up, each bigger than the last: the Dreadnought at 20,
  the Overmind at 40, the Leviathan at 60, the Colossus at 80, then mixes. A boss met once can recur
  alone in later rounds.
- **HP** grows every round (about 4.8× base by round 40), and from round 60 it also compounds by 1%
  per round, so a map full of maxed towers eventually breaks.
- **Speed** grows 0.45% per round up to +50% (bosses +25%).
- **Kill credits** grow with enemy HP: a kill pays its base bounty × (the round's HP multiplier)^0.3,
  about ×1.6 at round 40, ×1.9 at round 60 and ×3.2 at round 95. Without this, income fell so far
  behind late HP that a full map of towers could only afford to master about one in six.
- A round never spawns more than 250 regular enemies; past that, it gets tougher through HP and speed.


### The battlefield

The game is laid out at 1600 × 900 and fills any window (see Display). The battlefield fills the
screen: the deck, props and lanes continue past the playable grid to the window edges, dimmed
slightly, with corner brackets marking the build zone. Warp gates stand where enemies appear, just
outside the grid. Chevrons along the lanes show which way enemies will come; they show between rounds
and fade out while a round is in progress.

Each sector is a 32 × 16 grid of 48 px tiles (1536 × 768, everything between the top and bottom
bars), laid out as ASCII in `data/maps.gd`. Each keeps its original 20 × 12 design in the top-left
corner and extends into the rest with longer routes, more special tiles and props. Lanes turn with
rounded corners, and enemies follow the curves.

| Tile | Effect |
|---|---|
| High ground | Towers built on it get +15% range (a pylon's field and a sensor's reveal radius too) |
| Power node | Towers built on it deal +15% damage |
| Rubble | Blocks building. Click it to clear it for 40 cr; after that it's normal floor |
| Sludge (lane) | Ground enemies on it are slowed 30%; bosses resist half; flyers are unaffected |
| Shock strip (lane) | Ground enemies on it lose 4% of max HP per second (bosses 1%), ignoring armor |
| Switch gate (lane) | Sits where a warp gate's lane forks. Click it to cycle **Split** (enemies alternate branches), **one branch only**, **the other only**. 6 s cooldown. Enemies still before the fork switch branch on the spot; ones past it keep going |

In build mode, high ground and power nodes are tinted, and the placement preview shows the bonus.
Hovering any special tile explains it in the bottom bar.

## Saves

- Runs save to `%APPDATA%\Godot\app_userdata\Bastion Line\savegame.json`.
  - Use the Save button or the pause menu between rounds.
  - An autosave happens after every cleared round.
  - If you quit mid-round, you resume from the start of that round.
- Writes are atomic: the game writes a `.tmp` file, verifies it, then renames it. A leftover `.tmp` is recovered on load.
- Saves carry a format `version`, and corrupted or incompatible files are reported in the menu instead of crashing.
  - v10 (game 4.0) replaced every tower with the reworked roster. Saves from before it can't be loaded; the menu says so.
- `profile.json` in the same folder holds:
  - per-sector, per-mode records (best round, medal, best endless round)
  - legacy RP carried over from pre-v3.0 records
  - owned research
  - settings

  Research the records can't pay for, such as in a hand-edited file, is refunded on load.

## Development

The simulation (`scripts/core/Game.gd`) is deterministic, fixed-step (60 Hz) and node-free. The view
layer (`scripts/view/`) only draws it and turns its events into effects; the UI lives in `scripts/ui/`.
Balance numbers live in `data/*.gd`.

### Workflow

**Planning.** Work is tracked as GitHub issues, with milestones v3.6–v3.9 and Backlog, on the board
at https://github.com/users/Swooshiiroll/projects/1. The issue templates are Bug, Playtest note and
Feature.

**Making a change.**
1. Branch from an issue: `feat/<issue>-slug`, `fix/…`, `perf/…`, `balance/…`, `design/…` or `chore/…`.
2. Open a pull request that closes the issue.
3. `main` only accepts pull requests whose five CI checks pass.

The CI checks run on every push to any branch:

| Check | What it does |
|---|---|
| `check` | Static checks: draw lint, design data in sync, version consistent |
| `unit-tests` | The unit tests in `tests/TestRunner.gd` (about 12,000 checks, about 3 min) |
| `visual` | Screenshot tour, turret comparison and sprite sheet, under Xvfb with software OpenGL |
| `perf` | Render counts against `tests/perf_budget.json`. The run's summary has the table. |
| `build` | Windows and Linux exports |

**Test builds.** Every push uploads a Windows and a Linux build as the run's artifacts:
`BastionLine-<branch>-<commit>-windows` and `-linux`, kept for 14 days. Open the branch's latest run
under Actions to download them.

**Releasing.**
1. Move the Unreleased notes in `CHANGELOG.md` under the new version.
2. Run `tools/dev.sh version x.y.z` and merge that.
3. Push the tag `vx.y.z`.
4. The release workflow tests it, builds both platforms and publishes the release with those notes.
   A suffixed tag such as `v3.6.0-rc1` makes a pre-release.

**Running checks locally.** Everything runs through `tools/dev.sh <command>`, or `tools\dev.ps1`
from PowerShell. The commands are `import`, `check`, `test`, `tour`, `compare`, `perf`, `build` and
`version`. They are listed in `CLAUDE.md` and at the top of the script.

### Printable codex

`design/BastionLine-Codex.pdf` lists every enemy (role, tier, strength, abilities, the modifiers it can roll), the
elite modifiers, and every tower with its Retrofits, paths and masteries, all taken from the game's own data and the
in-game Codex's text (`tools/Codex.gd` exports it, `tools/codex.mjs` lays it out). Rebuild it after changing enemies
or the tower data (`design/balance.md`, `design/upgrade_trees_rework.md`):

```
godot_console --path . -- --codex="%CD%\design\codex"
node tools/codex.mjs
msedge --headless=new --no-pdf-header-footer --print-to-pdf="%CD%\design\BastionLine-Codex.pdf" design/codex/codex.html
```

### Balance master

`design/balance.md` holds every balance number in the game: tower stats and prices, enemy stats and abilities, the
elite modifiers, the round formulas and round makeup, the economy, the difficulty modes, research, the abilities and
the global rules. Generated columns (headed `=`) show the math: paper DPS and DPS per credit, enemy strength and leak
cost, health and credits by round, the round formulas by round, and tower prices per mode; its Formulas section explains
each. Edit a number there and run `node tools/balance.mjs` (it writes the number into the game's scripts) and
`node tools/tree_rework_data.mjs` (the tower data); `tools/dev.sh check` fails if anything disagrees.

### Live tuner

Launch the game with `--dev` (`godot --path . -- --dev`, or `./Bastion Line (dev).sh` in an LX build folder) and the
live tuner opens in its own window beside the game's, following it (its Dock switch frees it; F8 hides it). It edits
every number `design/balance.md` owns while the game runs (design/live_tuner.md, issue #80):

- a tab per area (enemies, modifiers, towers, waves, economy, difficulty, research, abilities, rules) lists its groups;
  type a value and press Enter, or use − and +. Search finds a group by name or by a number's key;
- enemies already on the field take the change (health keeps its share), placed towers and prices follow at once,
  and wave and round changes apply from the next round queued;
- the derived values sit beside the numbers (strength, leak cost, health and credits by round, each tower node's paper
  DPS and credits spent, the round formulas), and a readout shows the round, its multipliers, credits, shields and the
  enemies on the field;
- the Changes tab lists every change against balance.md's value, with revert, Revert all and Export. Export saves
  `user://tweaks/tweaks-<date>.json`; `node tools/balance.mjs --apply <file>` writes it into balance.md (a number edited
  there since is skipped and reported). A run from the repo applies it straight away.

A run with changed numbers is marked TUNED: it's never saved and earns no medals or RP.

### Checks

The commands below assume the console build is on PATH as `godot_console` (winget adds this alias; open a new shell after installing).

1. **Test suite** (about 10,000 checks, headless, about 2.5 min, exits 0 on success). It checks:
   - rules and combat math
   - economy and placement
   - save round-trips, including deterministic replay after loading
   - corrupted/newer/invalid save handling
   - abilities; the five modes (rounds, shields, standard credits, the research shield bonus), round
     HP and speed scaling, and the medal handing straight over to endless mode
   - the round generator: determinism, unlocks, the spawn cap, introductions, the boss schedule and
     each mode's finale
   - every tower specialization, the laser, missiles and pylon boosts
   - Research Lab data, RP from medals, milestones and endless, legacy RP from old profiles, buying,
     reset and refunds
   - every research effect, and tier-4 locking and pricing
   - each mastery mechanic (multishot, stun blasts, execute, wide rail, 7-missile salvos)
   - every sector's layout: lane tiles match the routes, rounded routes stay on their lanes, forks
     share their route up to the gate and diverge after it
   - high ground, power nodes, rubble clearing, sludge, shock strips and switch gates (including
     rerouting before the fork only, the cooldown, and saving gate state)
   - saves from before the tower rework are rejected with a clear message
   - cloaking and Radar reveal, barriers (including the Tesla bonus and recharge), splitting and EMP
   - every one of the twenty towers: its Retrofits, paths, masteries and what it does to enemies
   - every v3 enemy: burrowing, blinking (and its reset), regeneration, the rally aura, Bulwark
     barriers, Rampart immunities, Leviathan launches, Colossus phases, and the new flyers
   - v1 through v4 save migration, and rejection of tier-4 towers without research
   - generated music (length, level, clipping, seamless loop)
   - full bot playthroughs of Easy (40 rounds) on every map into endless mode, and a full-research
     Medium run, the bot playing the reworked towers (these fail on the 4.0.0 line until the new roster's
     balance lands; see Current tuning below)

   ```
   godot_console --headless --path . res://tests/TestRunner.tscn
   godot_console --headless --path . res://tests/TestRunner.tscn -- --only=save   # subset
   ```

2. **Screenshot tour** (opens a window, about 60 s). It sends real input events through Godot (hotkeys,
   clicks to build, U/I upgrades and specializations, abilities, HUD buttons, pause, buying research
   in the Research Lab, buying a mastery) and asserts the results, then writes a PNG of every screen to
   `screenshots/`. It uses a sandboxed save folder and mutes audio.

   ```
   godot_console --path . -- --screenshot-tour
   ```

3. **Balance probe**. It replays the heuristic bot (`scripts/core/Bot.gd`) on every map at several
   enemy-HP multipliers and reports shields and tower counts every 10 rounds, whether it earned the
   medal, and how far endless mode got. The bot plays the reworked towers: it buys a Retrofit and two
   paths per tower within the path rules, aims Artillery Cannons and CAS Gunships at the busiest choke,
   flies each Drone Bay's newest loadout, and places Radars where the most air-hitting towers would see
   what they reveal.

   ```
   godot_console --headless --path . res://tools/BalanceProbe.tscn -- --factors=1.0 --difficulty=easy
   godot_console --headless --path . res://tools/BalanceProbe.tscn -- --factors=1.0 --difficulty=hard --research=all --maps=delta,foundry
   godot_console --headless --path . res://tools/BalanceProbe.tscn -- --difficulty=cataclysm --research=all --lives=1000 --endless=0
   godot_console --headless --path . res://tools/BalanceProbe.tscn -- --difficulty=nightmare --research=all --maps=meadow --detail --price=1.5 --bounty=0.3
   ```

   Other flags: `--endless=N` (endless rounds to play past a medal, default 20), `--lives=N` (override
   the shields, e.g. to measure Cataclysm by rounds survived), `--growth=F` (late HP compounding rate),
   `--seeds=`, `--no-abilities`, `--mods=none` (no elites) or `--mods=hasty,plated` (elites carry only those
   modifiers). A round that runs past 600 s of game time ends the sector as `STALLED rN`, naming the
   enemies left (enemies no tower can kill, held in place by stuns, would otherwise keep it running
   for hours).

   `--research=` takes `all`, node ids, tree names (`command`, `gun_turret`, ...), `towers` or
   `nomastery`. Any missing prerequisites are added automatically.

   **The 4.0.0 line (in progress, #68),** the generated rounds with the twelve new enemies, the bot
   playing the reworked towers:
   - Easy, no research: medal on Meadow (51 of 200 left) and Canyon (94); lost on Delta (round 19),
     Crossroads (35), Foundry and Singularity (40).
   - Medium, no research: lost on every sector, between rounds 15 and 40.
   - Hard, full research: lost on every sector, between rounds 14 and 53.
   - The old roster's bot on the same rounds: Medium medal on Meadow, Delta and Crossroads with 100 of
     100 shields until round 50, then down to 13 by round 60 as the Wraiths arrive (no old tower deals
     energy damage).
   - What leaks: Phantoms most (40 to 100 a run from round 13; the Radar reveals for 1 s in every 3),
     early crowds on Delta (Shamans, Locusts, Brutes by round 15), and the boss rounds' shield costs.
     The new roster's best damage per credit is the Mortar's and the Rocket Salvo's, about 45-50,
     against 70-80 for the old Sniper and Drones.

   Current tuning (v3.0), with the bot using abilities, specializations and all 11 towers:
   - Easy, no research: it earns the medal on all six sectors (194-200 of 200 shields left).
   - Medium, no research: medal on all six (94-100 of 100 left).
   - Hard, full research: medal on all six (30-55 of 55 left).
   - Nightmare, full research: it reaches round 92-100 on every sector but doesn't win one; Red Rift
     and Cryo Delta fall on the round-100 finale itself. This is where the compounding late HP
     catches up with a map of maxed towers. v3.1's deeper upgrade trees will be re-tuned against it.
   - Cataclysm, full research, probed with 1,000 shields to measure how far it lasts: Outpost Theta
     reaches round 120 having lost 232 shields, most of them after round 90. With the real single
     shield it's a human challenge: the bot's first stray leak ends it early.
   - How v3.0 got here: with the round curve alone (no late compounding) the bot filled the map
     (400+ towers) and never leaked, even at round 220, on full research. HP now compounds 4% per
     round from round 40; 3% left Nightmare trivial and 6% broke full-research runs around round 80.
   - Crowd control has limits (1 s stun immunity after a stun, a 320 px lifetime shove budget). Before
     that, chained stuns and shoves could pin enemies near a warp gate forever, so a round never
     ended.
   - The bot's build order matters. Buying the Sensor Array or Flak Battery before its damage
     towers let the round-5 Dreadnought through, so support comes after the core damage towers.
   - Before its first round, the bot points every switch gate at the branch where enemies spend
     longest in the field, counting hazard tiles as extra time. Without that, forks split its
     kill zone.
   - Research was first worth about 50% extra enemy HP, which trivialized the hardest mode of the
     time; the tower stat nodes (range especially) did most of that, so they were roughly halved.


   Before this tuning, a damage-per-credit breakdown showed Missile Battery specializations doing 2 to 3
   times the damage of anything else. They were nerfed, and the late-game enemy HP curve was raised.
4. **Sprite sheet** (opens a window for a moment). Renders every tower at tier 1, tier 2, both
   specializations and both masteries, plus every enemy, to `screenshots/sprite_sheet.png`.
   Add `--anim` to keep it open and animated.

   ```
   godot_console --path . -- --sprite-sheet
   ```

   The art is procedural (`scripts/view/Draw.gd`) and each design follows its name. Tower tiers
   and paths add visible hardware, and masteries get gold trim:

   Each tower's look is its confirmed art (`scripts/view/towers/<Tower>Art.gd`, the design in `design/tower_art.md`):
   every Retrofit and path step adds visible hardware, and masteries turn gold.

   Enemies:
   - Drone: a hover drone with one red optic.
   - Skitter: a six-legged spider.
   - Siege Mech: a stomping biped with shoulder cannons.
   - Nanite: an orbiting speck swarm.
   - Strike Drone: a quad-rotor with spinning rotors, a camera, weapon pods and navigation lights.
   - Repair Bot: welding arms.
   - Phantom: a sleek stealth craft that shows only a faint heat-shimmer outline while cloaked.
   - Aegis Walker: a shield plate.
   - Hydra Frame: three swaying heads.
   - Jammer: a tracked electronic-warfare rig with a spinning dish, a mast and EMP rings.
   - Locust: a tiny winged micro-drone with flickering wings.
   - Rally Beacon: a wheeled signal mast with a rotating siren and pulsing overdrive rings.
   - Burrower: a drill-nosed mole bot on treads; underground, a moving mound of earth.
   - Gunship: an armored flyer with twin ducted fans and a chin turret.
   - Blink Stalker: a lean biped with a blade head and a teleport afterimage.
   - Mender Hulk: a hulking frame whose green repair seams pulse.
   - Bulwark: a squat projector spinning hexagonal barrier shards.
   - Rampart: a crenellated siege fortress on treads with a battering ram.
   - Dreadnought: twin cannons.
   - Overmind: a glowing brain.
   - Leviathan: a colossal flying carrier with launch bays and an engine bank.
   - Colossus: a four-legged walking fortress with a molten core and shoulder cannons.
5. **Performance probe** (opens a window for about a minute). It works with the built game too.
   - The bot plays a sector to the given round with no rendering. Then the game renders live, and the probe prints its frame rate:
     - with everything shown;
     - with each visual layer hidden in turn;
     - at 3× speed.
   - It also prints how long towers and enemies take to draw.

   ```
   godot_console --path . -- --perf=canyon,hard,70
   BastionLine.exe -- --perf=meadow,medium,40
   ```

   `--perf-compare` draws every tower in full and through the sprite caches side by side, into `screenshots/turret_compare.png`; each pair should look identical.

   In the Compatibility renderer, `draw_circle`, `draw_arc`, `draw_colored_polygon` and `draw_polyline` each allocate GPU buffers as they are recorded, costing 12–30 µs per call. Rectangles, lines and textures cost about 0.4 µs. Code that draws every frame uses these instead (all in `Draw.gd`):
   - **Cheap shapes:** `Draw.disc`, `ring`, `arc`, `poly` and `polyline` draw the same shapes from cached textures and quads.
   - **Static parts of turrets:** these are baked into textures once per look and drawn rotated to the aim. Live parts sit between `dyn(true)` and `dyn(false)`.
   - **Other cached art:** the terrain (`TerrainCache`), tower base plates, mastery rings and spinning parts (`Draw.spinning`) are cached too.

### Claude Code / MCP

The `godot` MCP server ([Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp)) is registered
at user scope. It can run this project, capture debug output, and inspect or create scenes. It is built
from source at `Documents\godot-mcp`, pinned to commit `1209744`, because the npm release (0.1.1) predates
an RCE fix in that commit.
