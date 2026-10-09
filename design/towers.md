# Bastion Line Tower Rework (design)

A general overhaul of the towers: **weapon classes**, a **new roster** the owner writes, a reworked **upgrade
structure**, **counters** to the reworked enemies, then **new looks and animations**. This is a **draft for the owner
to mark up**. Nothing here is confirmed beyond the owner direction below, and no game code changes until the owner
confirms the spec (repo CLAUDE.md, "Designing a feature first"). Issue #55.

## Why

- A general overhaul (owner).
- The reworked enemies need counters (owner): burrowing, flyers, cloak, disguise, decoys and disruptors (issue #53,
  PR #54, `design/enemies.md` on `design/enemy-rework`).

## Owner direction (2026-10-08)

- **Scope:** classes and stats (roles at first; replaced by weapon classes, 2026-10-09); the roster and upgrade
  trees; per-path looks (#6); new looks and animations, **based on names and descriptions the owner writes**.
- **Order:** gameplay first, then art.
- **Roster:** the **owner writes the tower list** (names and descriptions) on an editable page. Claude proposes each
  tower's stats and tree around it, in question rounds.
- **Roles scrapped; weapon classes instead (2026-10-09).** The owner first chose role families, then said "Lets scrap
  the tower roles and sort them by class instead". Answers:
  - **Class means weapon class:** how the tower attacks (for example Ballistic, Energy, Explosive), plus the
    non-attacking Utility and Economy.
  - **Exactly one class per tower.**
  - **What a class does:** it groups the shop (decided); other gameplay rules are TBD.
  - **The enemy spec's physical/energy split** (the Wraith): how it relates to the classes is decided later.
  - **The class set** lives in a reusable markdown reference sheet, `design/tower_classes.md`: Claude drafts it, the
    owner edits it.
- **Counters** to the new enemy mechanics come **only through branch upgrades**. No tower exists just to counter.
- **Upgrade structure:**
  - **3 paths** per tower.
  - **Each path has a purpose**, determined per tower. The owner's examples: "Power, range, speed, effect, buff, etc."
  - **Primary/secondary stays:** climb two paths until one gets its 3rd upgrade; that one is the primary, and the
    other is capped where it is.
  - **Depth and trunk (owner's pick, 2026-10-08):** trunk **C Optional Retrofit**, depth **B 4 upgrades + mastery**
    (`design/tower_upgrade_structure.html`). See "Upgrade structure" below.
- **Later, separately:** the Research lab, Prestige (#2, #3) and Super Structures (#4, #5) get their own passes once
  the roster is settled.
- **Tracking:** its own issue (#55), branch (`design/tower-rework`), spec and draft PR, apart from the enemy rework.

## What exists today

- **15 towers** (`data/towers.gd`). Internal ids predate the display names and are kept for old saves.

| Tower | id | Key | Hits | Job today | Branches A / B / C |
|---|---|---|---|---|---|
| Pulse Turret | arrow | 1 | air + ground | Rapid single-target bolts | Gatling Pulse / Shredder / Flechette |
| Plasma Mortar | cannon | 2 | ground | Splash damage | Siege Mortar / Plasma Burn / Bunker Buster |
| Cryo Emitter | frost | 3 | air + ground | Area slow plus light damage | Stasis Field / Shatter Field / Cryo Lock |
| Railgun | sniper | 4 | air + ground | Huge range, ignores armour | Deadeye / Piercing Rail / Null Slug |
| Arc Coil | tesla | 5 | air + ground | Chain lightning, double damage to barriers | Storm Coil / Overload / Ion Storm |
| Laser Lance | laser | 6 | air + ground | Ramping beam, ignores armour | Prism Array / Focus Lens / Sweeper |
| Missile Battery | missile | 7 | air + ground | Homing salvos, double damage to flyers | Swarm Pods / Hellfire / Cluster Munitions |
| Amplifier Pylon | amp | 8 | support | Boosts nearby towers' damage | Overclock Pylon / Targeting Array / Suppression Pylon |
| Flak Battery | flak | 9 | air | Airbursts that hit every flyer in the blast | Sky Shredder / Proximity Burst / Dual Purpose |
| Sensor Array | sensor | 0 | support | Reveals cloaked enemies, marks targets | Deep Scan / Target Painter / Disruptor |
| Graviton Projector | gravity | - | ground | Gravity pulses that move enemies along the lane | Repulsor / Crush Field / Gravity Well |
| Nullifier | nullifier | = | air + ground | Strips barriers, armour and immunities | Purge Emitter / Dampener / Feedback Loop |
| Nova Reactor | nova | [ | air + ground | 360° shockwave | Supernova / Pulse Reactor / Solar Flare |
| Drone Bay | drones | ] | air + ground | Hunter drones that chase enemies anywhere | Interceptor Wing / Bomber Wing / Hunter-Killer |
| Scrapyard | scrap | \ | none | Economy: credits from wreckage | Credit Mint / Scrap Collector / Supply Depot |

- **Upgrade structure** (`design/upgrade_trees.md`, Rules): a two-tier trunk (Stock, Retrofit), then three branches
  (A, B, C) of four upgrades and a mastery, bought with U, I and O. A tower climbs up to two branches, up to two
  upgrades each; the third upgrade on either makes it the primary (on to its mastery), and the other is capped at one
  or two. A secondary keeps its full effects; attack-changing specializations add their attack alongside the primary's.
  Masteries need the tower's Mastery research. Selling refunds the whole tower; no respec.
- **Data flow:** `design/upgrade_trees.md` is the source. `node tools/tree_data.mjs` writes `data/tower_trees.gd`, and
  `tools/tree_page.mjs` writes `design/upgrade_trees.html`. `tools/dev.sh check` fails if they're stale.
- **Research:** each tower has a Research Lab tree; its Mastery node unlocks the tower's three masteries.
- **Also built on today's towers:** saves (tower ids, paths), the Codex (`Lore.gd`, `data/glossary.gd`), the bot's
  build order (`BalanceProbe`), the tests, the tour, and the turret drawing cache (`Draw.dyn`, see CLAUDE.md).

## Upgrade structure (decided)

Picked by the owner on 2026-10-08 from `design/tower_upgrade_structure.html`: trunk **C Optional Retrofit**, depth
**B 4 upgrades + mastery**.

- **No gating trunk:** the three paths open straight from the stock tower.
- **Each path:** four upgrades, then its mastery. Masteries still need the tower's Mastery research (the research
  rework is a separate pass).
- **Mixing (kept):** climb up to two paths, up to two upgrades each. The 3rd upgrade on either makes it the primary,
  which goes on to its mastery; the other is the secondary, capped at 2 with its full effects. The third path is locked.
- **The Optional Retrofit:** an all-round upgrade off to the side. It can be bought any time, before or after the paths,
  and unlocks nothing.
  - **What it gives:** a **tower-specific** boost, designed for each tower in the per-tower rounds (owner).
  - **Buying it:** a **fourth card** in the tower panel beside the three path cards, with **its own hotkey** (owner).
    Y is suggested (free today, next to U/I/O); the key is confirmed in the UI round.
  - **Look:** it **visibly changes the tower** (owner), designed in the art phase with the per-path looks.
- **Counts:** a full build is 8 upgrades with the Retrofit (Retrofit, 4 primary, the mastery, 2 secondary); the primary
  locks in on the 3rd path upgrade; each tower has 16 upgrade nodes to design (the Retrofit and 3 paths of 4 plus a
  mastery), as today.

## Process

1. **Class set:** Claude's draft in `design/tower_classes.md`; the owner edits it.
2. **Roster:** the owner writes the tower list on `design/tower_roster.html`: names, classes and descriptions, and
   optionally each tower's three path purposes.
3. **Upgrade structure:** decided (trunk C Optional Retrofit, depth B 4 + mastery; see above).
4. **Per tower, in question rounds:** its three path purposes, its stats, its upgrades, and which upgrades counter
   which enemy mechanics. Then balance targets and how the bot probe checks them.
5. **Art** (after gameplay): looks and animations from the owner's names and descriptions, then per-path looks (#6),
   on mockup pages like the enemy art (`design/enemy_art.md`), within the turret cache rules.
6. **Implementation** waits on the owner's confirmation of the whole spec, and ships as its own PRs.

## Weapon classes (draft)

The full reference is `design/tower_classes.md`, for the owner to edit. Each tower has exactly one class, set by how
its stock attack reaches the enemy; the class groups the shop.

| Class | What it is | Today's towers that would fit |
|---|---|---|
| Ballistic | Physical projectiles at a target | Pulse Turret, Railgun |
| Energy | Beams, lasers and lightning, no flight time | Laser Lance, Arc Coil |
| Explosive | Shells, missiles and bombs that burst where they land | Plasma Mortar, Missile Battery, Flak Battery |
| Utility | Doesn't attack: boosts, reveals, marks, strips defences | Amplifier Pylon, Sensor Array |
| Economy | Doesn't fight: makes or saves credits | Scrapyard |
| Field (proposed) | Pulses and shockwaves centred on the tower | Cryo Emitter, Graviton Projector, Nova Reactor, Nullifier |
| Deployable (proposed) | Launched units acting away from the tower | Drone Bay |

The sheet also lists the edge cases (towers between two classes) and the parked ideas for what a class could do in play
beyond the shop.

## Counters to answer (through branch upgrades)

From the enemy rework (`design/enemies.md`, `design/enemy_roster.md` on `design/enemy-rework`):

- **Burrowing:** the Burrower is hidden underground; specific towers or upgrades can hit it there, inside Sensor Array
  range (enemy spec, Still open item 3). Today the Plasma Mortar's C branch and the Drone Bay's Strike Wing (the Bomber Wing
  mastery) have `hits_burrowed`, and the Sensor Array's Disruptor upgrade stops burrowing.
- **Flyers:** Locust, Shrike, Strike Drone, Gunship, Phantom, Wraith and the Leviathan. The Wraith and Phantom now fly
  (enemy spec, Still open items 4 and 5).
- **Cloak:** Phantom and Wraith (revealed by a Sensor Array field or briefly after area damage).
- **Physical-damage immunity:** the Wraith takes only energy damage (parked until the damage-type PR).
- **Disguise:** the Masquerade passes as a Drone until it drops below 50% health or a Sensor Array upgrade reveals it.
- **Decoys:** the Decoy Beacon fakes a top rank; the Mirage projects 1-HP holograms that soak shots.
- **Disruptors:** EMPs (Jammer, Blackout Rig, Capacitor's charge, which silence or stun can cancel) and the Siphon's
  slow-fire aura.
- **Barriers, healing, splitting and immunities:** Aegis Walker and Bulwark barriers, Repair Bot and Mender Hulk
  healing, the Hydra Frame's split, the Rampart's crowd-control immunity, boss slow resist.

## Out of scope

- The Research lab, Prestige (#2, #3) and Super Structures (#4, #5): their own passes after the roster.
- Enemy changes: they belong to #53 / PR #54.

## Open questions

### Decided

- **Weapon classes, not roles** (2026-10-09): exactly one per tower; groups the shop; reference sheet
  `design/tower_classes.md`.
- **Upgrade structure** (2026-10-08): Optional Retrofit, 4 upgrades + mastery per path; the Retrofit is tower-specific,
  bought from a fourth card with its own hotkey, and visibly changes the tower.

### Still open

1. **Class set:** the owner's edits to `design/tower_classes.md`: accept or drop Field and Deployable, and decide the
   edge cases.
2. **Roster:** the owner's tower list: names, classes, descriptions (the roster page).
3. **The Retrofit's hotkey:** Y suggested; confirmed in the UI round.
4. **Per tower:** path purposes, the Retrofit's boost, stats, upgrades, counter upgrades (rounds after 1 and 2).
5. **Old saves and ids:** what happens to towers in old saves when the roster changes (save format bump, refunds).
6. **The bot, Codex, tests and tour:** how they follow the new roster.
7. **What a class does beyond the shop** (TBD): candidates are parked in the class sheet.
8. **Classes and the physical/energy split** the Wraith needs: decide later.
9. **Folding in #6 and #8:** per-path looks come in the art phase; the #8 playtest tree tweaks are rewritten into the
   new trees.
