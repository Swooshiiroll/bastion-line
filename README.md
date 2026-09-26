# Bastion Line

A sci-fi tower defense game built in Godot 4.7 (GDScript).

- **Towers:** 15 (including the Scrapyard, an economy tower), each with a two-tier trunk and three upgrade branches of four upgrades plus a
  mastery. You climb one branch as the primary and can take up to two upgrades on a secondary.
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
ships no asset files. The glow comes from additive blending, and UI text uses Windows' Bahnschrift font.

## Playing

- **Standalone:** `build\BastionLine.exe` (about 110 MB, game data embedded). It doesn't need Godot installed,
  so you can copy it to any 64-bit Windows PC.
- **From source:** double-click `Play.cmd`, or run `godot --path "C:\Users\anode admin\Documents\TowerDefense"`.
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
- **Title screen:** a drawn scene rather than a live game. It shows the Bastion core on a planet's
  horizon, a ridge of mastered towers firing up at a Leviathan and its escorts, and the menu.

### Rebuilding the exe

The Windows export templates for 4.7.2 are installed in `%APPDATA%\Godot\export_templates\4.7.2.stable`.
They were extracted from the official release archive after checking it against the release's SHA512-SUMS.
The preset lives in `export_presets.cfg` and leaves out `screenshots/` and `tests/`.

```
godot_console --headless --path . --export-release "Windows Desktop" build/BastionLine.exe
```

### Controls

| Input | Action |
|---|---|
| `B` or the Shop button | Open the tower shop. Picking a tower closes it while you place it; it reopens once the tower is placed |
| `1`-`9`, `0`, `-`, `=`, `[`, `]`, `\` | Pick a tower to deploy directly (the shop stays closed) |
| Left-click a tile | Build (Shift+click to keep building) |
| Left-click rubble / a switch gate | Clear the rubble (40 cr) / switch which branch arriving enemies take |
| Left-click a tower | Select it: the bottom bar shows its tier, kills, upgrade path and actions. Double-click opens its upgrade tree |
| Right-click | Cancel build mode, targeting or selection |
| `U` | Upgrade the selected tower to tier 2, then buy the next upgrade on branch A (the mastery after its 4th upgrade) |
| `I` / `O` | Buy the next upgrade on branch B / branch C |
| `X` | Sell the selected tower (refunds 70% of everything spent on it) |
| `T` | Cycle the selected tower's targeting: First, Last, Strongest, Closest |
| `E` | Upgrade tree for the selected tower: the trunk, all three branches and their masteries, with before/after stats; click a lit node to buy it |
| `R` | Research Lab in battle (pauses; purchases apply from your next run) |
| `N` or click NEXT | Intel on the next round: enemies, counts, traits, HP and speed scale, bonuses |
| `Space` | Launch the next round, or call it early for bonus credits once the current round has finished spawning |
| `Q` then click | Orbital Strike: armor-piercing blast at the clicked spot after 0.9 s (45 s cooldown) |
| `W` | Chrono Field: slows every enemy 60% for 5 s; bosses resist half (70 s cooldown) |
| `F` | Game speed 1x / 2x / 3x |
| `A` | Auto-launch the next round 5 s after each clear |
| `Esc` | Closes every open menu at once; with nothing open it cancels build/selection, then opens the pause menu |
| `P` | Pause menu (resume, save, settings, quit) |

### Towers and upgrade trees

Every tower has the same tree shape (the full design, with every node's stats and description,
lives in `design/upgrade_trees.md` and its rendered view `design/upgrade_trees.html`):

- **Trunk:** tier 1 (the build) and tier 2.
- **Three branches (A, B, C)** from tier 2, each four upgrades plus a mastery. A branch's first
  upgrade is its **specialization**, which changes how the tower works; the mastery needs that
  tower's Mastery research.
- **A primary and a secondary.** You can climb two branches freely until one of them gets its
  **3rd** upgrade. That branch becomes the primary; the other is capped where it is (at most 2),
  and the third branch is locked as soon as two are started.
- **A secondary keeps its effects.** Its upgrades add on top of the primary (downsides included).
  An attack-style secondary (Flechette, Ion Storm, Sweeper, Gravity Well, Bomber Wing) adds its
  attack alongside the primary's instead of replacing it.

| Key | Tower | Cost | Role | Branch A | Branch B | Branch C |
|---|---|---|---|---|---|---|
| 1 | Pulse Turret | 50 | Rapid single-target bolts; hits flyers | Gatling Pulse → Storm Gatling | Shredder → Disintegrator | Flechette → Hailstorm |
| 2 | Plasma Mortar | 90 | Splash, ground only | Siege Mortar → Earthshaker | Plasma Burn → Inferno Mortar | Bunker Buster → Seismic Charge |
| 3 | Cryo Emitter | 70 | Area slow plus light damage | Stasis Field → Absolute Zero | Shatter Field → Cryo Fracture | Cryo Lock → Permafrost |
| 4 | Railgun | 120 | Huge range, ignores armor | Deadeye → Executioner | Piercing Rail → Ion Lance | Null Slug → Void Round |
| 5 | Arc Coil | 130 | Chain lightning | Storm Coil → Tempest Coil | Overload → Supercharger | Ion Storm → Maelstrom |
| 6 | Laser Lance | 140 | Continuous ramping beam, ignores armor | Prism Array → Refraction Grid | Focus Lens → Singularity Lens | Sweeper → Scythe Array |
| 7 | Missile Battery | 110 | Homing salvos, double damage to flyers | Swarm Pods → Locust Swarm | Hellfire → Doomsday Warheads | Cluster Munitions → Carpet Bomber |
| 8 | Amplifier Pylon | 100 | Support: boosts towers in its field | Overclock Pylon → Hypercore Pylon | Targeting Array → Command Array | Suppression Pylon → Silence Pylon |
| 9 | Flak Battery | 80 | Anti-air airbursts | Sky Shredder → Aerial Denial | Proximity Burst → Thunderhead | Dual Purpose → Flak Curtain |
| 0 | Sensor Array | 75 | Support: reveals cloaked enemies, marks them | Deep Scan → Omniscient Grid | Target Painter → Kill Beacon | Disruptor → Blackout Grid |
| - | Graviton Projector | 150 | Gravity pulses shove the lane back | Repulsor → Singularity Engine | Crush Field → Event Horizon | Gravity Well → Collapse Point |
| = | Nullifier | 120 | Dampening pulses strip barriers and immunities | Purge Emitter → Absolute Null | Dampener → Silence Engine | Feedback Loop → Overload Cascade |
| [ | Nova Reactor | 160 | Radial energy waves around itself | Supernova → Hypernova | Pulse Reactor → Chain Reactor | Solar Flare → Corona |
| ] | Drone Bay | 180 | Drones that fly anywhere on the map | Interceptor Wing → Swarm Carrier | Bomber Wing → Strike Wing | Hunter-Killer → Assassin Protocol |
| \ | Scrapyard | 150 | Economy: pays credits at every round clear, never attacks | Credit Mint → Reserve Bank | Scrap Collector → Reclamation Plant | Supply Depot → Forward Command |
|  | Scrapyard | 150 | Economy: pays credits at every round clear, never attacks | Credit Mint → Reserve Bank | Scrap Collector → Reclamation Plant | Supply Depot → Forward Command |

The C branches are counters to the v3 roster:
- **Pulse Turret, Flechette:** a cone that hits a whole group.
- **Plasma Mortar, Bunker Buster:** breaks armor and hits (and unearths) Burrowers.
- **Cryo Emitter, Cryo Lock:** stops Mender repair and barrier recharge.
- **Railgun, Null Slug:** suppresses the target's abilities.
- **Arc Coil, Ion Storm:** leaves lingering storm zones.
- **Laser Lance, Sweeper:** sweeping beams that burn barriers.
- **Missile Battery, Cluster Munitions:** bomblets.
- **Amplifier Pylon, Suppression Pylon:** jams enemy support in its field.
- **Flak Battery, Dual Purpose:** also hits ground targets.
- **Sensor Array, Disruptor:** stops burrowing and blinking, and exposes Ramparts.
- **Graviton Projector, Gravity Well:** pulls enemies together and implodes them.

**The Scrapyard** is the only tower that doesn't fight. Every Scrapyard pays its credits per round
when a round is cleared, scaled the same way as kill credits (so one built early still matters late).
Its branches:
- **A, Credit Mint:** the most income. The Reserve Bank mastery also pays 3% interest on banked credits
  at each round clear, up to 300. Only the best bank's interest counts.
- **B, Scrap Collector:** enemies destroyed in its field pay +25% credits (up to +60%, and double for
  bosses on the Reclamation Plant).
- **C, Supply Depot:** towers in its field upgrade for 10% less (up to 25%). On Forward Command they also
  sell back for everything spent on them.

Collector and depot bonuses don't stack: the best Scrapyard in range applies. Depots don't discount
other Scrapyards. Scrapyards cost more on the harder modes like every tower, so an economy is a
bigger bet on Nightmare and Cataclysm.

A mastered tower has a gold ring around its pad.

### Research Lab

Open it from the main menu (or the end-of-run screen). Every tree is a small diamond: a root
node, two branch nodes, and a capstone that needs either branch. Research is bought with research
points (RP) and applies to every run you start afterwards. A saved run keeps the research it
started with. Reset Research refunds everything for free.

- **Earning RP.** RP is worked out from your records, so it can't be farmed or lost:
  - each medal pays its mode's RP (Easy 1, Medium 2, Hard 3, Nightmare 4, Cataclysm 5)
  - 1 RP per sector for each of rounds 20, 40, 60, 80 and 100 reached (on any mode)
  - 1 RP per 10 endless rounds past a mode's last round, up to 5 per sector

  That's 150 RP across the 6 sectors. The whole lab costs 130, so you can max it without every medal.
  Profiles from before v3.0 keep the RP their old records earned as **legacy RP** (shown in the lab);
  the old records themselves are cleared, since they were 25-wave runs under different rules.
- **Command tree** (10 RP):
  - Reserve Funds: +10% starting credits
  - Salvage Protocols: sell refund 85%
  - Reinforced Core: +10% shields, rounded down (Cataclysm stays at 1)
  - Bounty Contracts: +8% kill credits
  - Orbital Uplink: abilities recharge 20% faster
- **Tower trees** (8 RP each, 15 trees). Each has a root bonus (+6% damage, or field size for Cryo and
  Amplifier), a range branch and a signature branch, then the Mastery. The signature branches:
  - Pulse Turret: fire rate
  - Plasma Mortar: blast radius
  - Cryo Emitter: stronger, longer slow
  - Railgun: recharge
  - Arc Coil: +1 chain target
  - Laser Lance: faster ramp
  - Missile Battery: blast radius
  - Amplifier Pylon: 20% cheaper pylons
  - Flak Battery: burst radius
  - Sensor Array: 20% cheaper sensors (its branch adds +3% mark)
  - Graviton Projector: 12% longer shove
  - Nullifier: +10% pulse rate (its root adds +6% barrier strip)
  - Nova Reactor: +10% pulse rate
  - Drone Bay: +1 drone (its range branch is +10% drone speed)
  - Scrapyard: Scrapyards and their upgrades cost 20% less (its root adds +10% income, its range branch +10% field)

  A tower's Mastery research unlocks all three of its masteries.

### Enemies

Every enemy's health and speed scale with the round number, the same on every sector and mode (see
[Rounds and scaling](#rounds-and-scaling)). "From" is the first round it can appear.

| Enemy | From | Traits |
|---|---|---|
| Drone | 1 | Basic |
| Skitter | 3 | Fast, fragile |
| Nanite | 6 | Tiny, comes in swarms |
| Siege Mech | 7 | 6 flat armor per hit (minimum 20% of damage gets through) |
| Strike Drone | 8 | Quad-rotor flyer; flies straight from the warp gate to the core, ignoring the lane |
| Phantom | 8 | Cloaked. Towers can only target it inside a Sensor Array field, or for 0.5 s after a blast, field or arc hits it while hidden |
| Repair Bot | 9 | Heals nearby non-boss enemies |
| Aegis Walker | 9 | Energy barrier (scales with HP) soaks damage before armor applies and recharges after 2.5 s untouched. Arc Coils hit barriers twice as hard |
| Hydra Frame | 11 | Armored walker that splits into three Skitters when destroyed |
| Jammer | 13 | EMP every 5 s knocks towers within 95 px offline for 2 s |
| Locust | 26 | Tiny, fast flyer in dense swarms. Flak's favourite target |
| Rally Beacon | 28 | Other non-boss enemies within 100 px move 25% faster (doesn't stack). Kill it first |
| Burrower | 30 | Tunnels under the lane for 2.5 s every 5 s: untargetable, unhurt and immune to lane hazards while under |
| Gunship | 32 | Armored heavy flyer (5 armor) |
| Blink Stalker | 34 | Teleports 80 px down the lane every 4 s. A slow or stun resets the charge |
| Mender Hulk | 36 | Regenerates 4% of its health per second after 1.5 s without taking damage |
| Bulwark | 38 | Every 6 s gives nearby non-boss enemies (not itself) a barrier worth 25% of their health |
| Rampart | 40 | Immune to slows, stuns and shoves; 8 armor |
| **Dreadnought** (boss) | 5 | Every 5th round, more of them later. Armored, half-immune to slows, costs 6 shields if it leaks |
| **Leviathan** (boss) | 35 | Flying carrier that launches 6 Locusts every 6 s. From round 35, then every 20. Costs 15 shields |
| **Overmind** (boss) | 40 / 50 | Spawns Nanites as it advances. Rounds 50, 75 and 100, plus the finales. Costs 20 shields |
| **Colossus** (boss) | 60 | Can't be stunned. At 66% and 33% health it sheds 5 armor, speeds up 20% and drops two Siege Mechs. From round 60, then every 20. Costs 25 shields |

Bosses get half the round speed bonus and resist slows and shoves. After a stun wears off, an enemy
can't be stunned again for 1 s, and Graviton shoves can push any one enemy back at most 320 px in
total, so nothing can be pinned in place forever.


### Abilities

Abilities recharge only while a round is running and can only be cast then. Orbital Strike damage grows
with the round number, so it stays useful late. The HUD's bottom-left buttons show the cooldown.

### Sectors, modes and medals

Sectors are pure maps: every run starts with 300 credits, and enemy strength depends only on the
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
| Easy | 40 | 200 | ×1.0 | 1 |
| Medium | 60 | 100 | ×1.0 | 2 |
| Hard | 80 | 50 | ×1.1 | 3 |
| Nightmare | 100 | 25 | ×1.5 | 4 |
| Cataclysm | 120 | 1 | ×2.0 | 5 |

- Clearing a mode's last round earns that sector's **medal** for the mode (a banner announces it and
  it's recorded at once), and **endless mode** begins straight away: the rounds keep coming until the
  core falls. There are 30 medals in all; each sector card shows its row of five.
- The last round of each mode is a **finale** with a boss line-up (Easy: Overmind and Leviathan;
  Cataclysm: two of every boss and four Dreadnoughts).
- On Cataclysm a single leak ends the run.

### Rounds and scaling

- **Rounds 1-25** are hand-authored. From round 26 a seeded generator spends a threat budget that
  grows every round on the enemies unlocked so far, favouring recent ones. Rounds 26-40 each introduce
  one of the eight newer enemies.
- **Bosses** follow a schedule on top: Dreadnoughts every 5 rounds, Leviathans from 35 (every 20),
  the Overmind at 50/75/100, Colossi from 60 (every 20).
- **HP** grows every round (about 7× base by round 40), and from round 40 it also compounds by 4%
  per round, so a map full of maxed towers eventually breaks.
- **Speed** grows 0.45% per round up to +50% (bosses +25%).
- **Kill credits** grow with enemy HP: a kill pays its base bounty × (the round's HP multiplier)^0.3,
  about ×1.8 at round 40, ×2.7 at round 60 and ×5.2 at round 95. Without this, income fell so far
  behind late HP that a full map of towers could only afford to master about one in six.
- A round never spawns more than 250 regular enemies; past that, it gets tougher through HP and speed.


### The battlefield

The game renders natively at 1600 × 900 (other 16:9 window sizes scale evenly). The battlefield
fills the screen: the deck, props and lanes continue
past the playable grid to the screen edges, dimmed slightly, with corner brackets marking the
build zone. Warp gates stand where enemies appear, just outside the grid.

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
  Saves migrate forward automatically:
  - v2 added difficulty and ability cooldowns (v1 saves load as Normal).
  - v3 added tier-3 specializations (a v2 tier-3 tower becomes its first specialization).
  - v4 added the run's research snapshot and tier-4 towers (older runs load with no research).
  - v5 added cleared rubble, switch-gate states and route counters. A v4 tower that now stands on
    rubble clears it; one on a new wall is refunded.
  - v6 grew every sector to 32 × 16 and rerouted the lanes. A tower that now stands on a lane or
    wall is refunded, and cleared rubble that no longer exists is dropped.
  - v7 (game v3.0) replaced Casual/Normal/Veteran with the five modes: Casual becomes Easy, Normal
    Medium, Veteran Hard, and the run keeps its share of shields rescaled to the new mode's total.
  - v8 (game v3.1) stores each tower's upgrade state as trunk, per-branch depth, the order the branches
    were started, and whether it's mastered. A v7 tier-3 tower becomes the first upgrade of its branch;
    a tier-4 tower is mastered at the end of that branch.
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

### Printable codex

`design/BastionLine-Codex.pdf` lists every enemy, tower and upgrade tree with its stats. Rebuild it after
changing enemies or `design/upgrade_trees.md`:

```
godot_console --path . -- --codex="%CD%\design\codex"
node tools/codex.mjs
msedge --headless=new --no-pdf-header-footer --print-to-pdf="%CD%\design\BastionLine-Codex.pdf" design/codex/codex.html
```

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
   - v4 to v5, v5 to v6 and v6 to v7 save migration (reworked layouts, then the new modes)
   - cloaking and reveal, barriers (including the Arc Coil bonus and recharge), splitting, EMP,
     flak air-only bursts, and graviton shoves (including boss resistance and Crush stuns)
   - every v3 enemy: burrowing, blinking (and its reset), regeneration, the rally aura, Bulwark
     barriers, Rampart immunities, Leviathan launches, Colossus phases, and the new flyers
   - v1 through v4 save migration, and rejection of tier-4 towers without research
   - generated music (length, level, clipping, seamless loop)
   - full bot playthroughs of Easy (40 rounds) on every map into endless mode, and a full-research
     Medium run

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
   medal, and how far endless mode got.

   ```
   godot_console --headless --path . res://tools/BalanceProbe.tscn -- --factors=1.0 --difficulty=easy
   godot_console --headless --path . res://tools/BalanceProbe.tscn -- --factors=1.0 --difficulty=hard --research=all --maps=delta,foundry
   godot_console --headless --path . res://tools/BalanceProbe.tscn -- --difficulty=cataclysm --research=all --lives=1000 --endless=0
   godot_console --headless --path . res://tools/BalanceProbe.tscn -- --difficulty=nightmare --research=all --maps=meadow --detail --price=1.5 --bounty=0.3
   ```

   Other flags: `--endless=N` (endless rounds to play past a medal, default 20), `--lives=N` (override
   the shields, e.g. to measure Cataclysm by rounds survived), `--growth=F` (late HP compounding rate),
   `--seeds=`, `--no-abilities`.

   `--research=` takes `all`, node ids, tree names (`command`, `arrow`, ...), `towers` or
   `nomastery`. Any missing prerequisites are added automatically.

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

   | Tower | Look |
   |---|---|
   | Pulse Turret | Round turret head with coil-ringed emitters (two from tier 2); Gatling spins a barrel cluster, Shredder fires saw discs |
   | Plasma Mortar | A tube pointing skyward with a glowing plasma mouth and side canisters; Siege braces on four legs, Burn carries green tanks |
   | Cryo Emitter | A rotating snowflake crystal over a coolant core with frost vents; Stasis adds a halo, Shatter ice shards |
   | Railgun | Twin rails wrapped in magnetic coils, fed by capacitors; Deadeye adds a scope |
   | Arc Coil | A Tesla coil: toroid rings around a charged spire; Storm adds satellite coils |
   | Laser Lance | A long lance with focusing rings and a crystal tip; Prism splits, Focus has one big lens |
   | Missile Battery | A launcher box whose tubes show their warheads; Hellfire carries two finned heavies |
   | Amplifier Pylon | A tripod mast broadcasting waves; Overclock spins a gear, Targeting Array a dish |
   | Flak Battery | An anti-air mount with shrouded autocannons fed by an ammo box, plus a tracking radar; Sky Shredder adds barrels, Proximity Burst mounts one heavy gun |
   | Sensor Array | A turning radar dish on a braced mast sweeping a scan wedge; Deep Scan fits a bigger dish, Target Painter adds laser designators |
   | Graviton Projector | A containment ring of emitters around a pinned singularity with space spiralling in; Repulsor pushes chevrons outward, Crush Field bristles with inward spikes |

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

### Claude Code / MCP

The `godot` MCP server ([Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp)) is registered
at user scope. It can run this project, capture debug output, and inspect or create scenes. It is built
from source at `Documents\godot-mcp`, pinned to commit `1209744`, because the npm release (0.1.1) predates
an RCE fix in that commit.
