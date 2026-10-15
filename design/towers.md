# Bastion Line Tower Rework (design)

A general overhaul of the towers: **four classes**, a **new roster** the owner writes, a reworked **upgrade
structure**, **counters** to the reworked enemies, then **new looks and animations**. This is a **draft for the owner
to mark up**. Nothing here is confirmed beyond the owner direction below, and no game code changes until the owner
confirms the spec (repo CLAUDE.md, "Designing a feature first"). Issue #55.

## Why

- A general overhaul (owner).
- The reworked enemies need counters (owner): burrowing, flyers, cloak, disguise, decoys and disruptors (issue #53,
  PR #54, `design/enemies.md` on `design/enemy-rework`).

## Owner direction (2026-10-08)

- **Scope:** classes and stats (roles at first, then weapon classes, then four classes, 2026-10-10); the roster
  and upgrade trees; per-path looks (#6); new looks and animations, **based on names and descriptions the owner writes**.
- **Order:** gameplay first, then art.
- **Roster:** the **owner writes the tower list** (names and descriptions) on an editable page. Claude proposes each
  tower's stats and tree around it, in question rounds.
- **Classes (2026-10-10):** the towers are grouped into **four classes: Assault, Support, Defense, Utility** (owner).
  This replaced role families (2026-10-08) and then weapon classes (2026-10-09). Answers:
  - **Meanings:** Assault deals the damage; Support boosts other towers (damage, range, fire rate); Defense holds the
    line by controlling enemies (slow, stun, push, block); Utility is the tools (reveal, strip enemy defences) and
    the economy.
  - **Economy towers are Utility.**
  - **Exactly one class per tower**, and the class **groups the shop** (other gameplay rules TBD).
  - **Weapon type stays as a sub-tag:** Ballistic, Energy, Explosive (plus the proposed Field and Deployable, and None)
    describe how a tower attacks. Descriptive only for now.
  - **The enemy spec's physical/energy split** (the Wraith): how it relates to the weapon types is decided later.
  - **Reference sheet:** `design/tower_classes.md` (Claude drafts the wording, the owner edits).
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

## Pricing (decided)

Accepted by the owner on 2026-10-15: **every upgrade costs in proportion to what it adds**, by one value formula for all
towers, with prices **rounded to 5s and 0s**.

- **Value of a tower's state:** V = damage × shots per second × targets × area × (range ÷ 130) × effect multipliers.
  - **Area:** 1 + blast radius ÷ 40 for splash attacks; 1 otherwise.
  - **Effect multipliers so far:** armour ignored ×(1 + half the % ignored); a flat armour ignore of 2 ×1.1; critical
    chance (double damage) ×(1 + chance); no-overkill targeting ×1.1; hits burrowed
    enemies ×1.1 (Mortar); a ramping beam as an average of 1 + (max − 1) × 0.5 × (3 s ÷ ramp time)^0.3, and armour melt
    ×1.1 (Laser); homing ×1.15 to ×1.3, and guidance fins ×1.1 (Rocket Salvo); cluster bomblets as extra splash hits
    (Mortar); **hits only flyers ×0.5** (Anti-Aircraft Turret), since flyers are a minority of enemies. New effects (slow, stun, burn, pull, buffs,
    income) get their multiplier or damage equivalent when their tower is designed, and are listed here.
- **Upgrade price:** (V after − V before) × **3.9 credits per value point** × the **step multiplier**, rounded to 5.
  - **3.9** is calibrated on the Gun Turret: 75 credits for its stock value (16 damage × 1.2 shots/s).
  - **Step multiplier:** ×2, ×4, ×8, ×16 for steps 1 to 4, ×32 for the mastery (each step doubles).
  - **The Retrofit** is priced as a step 1 (×2) from the stock tower.
- **Stock build costs** are the owner's; the formula prices the upgrades. The balance probe tunes the effects (not the
  rule) afterwards.
- **Why:** small upgrades stay cheap and big ones expensive, so prices read consistently across towers.

## Process

1. **Class set:** Claude's draft in `design/tower_classes.md`; the owner edits it.
2. **Roster:** done: 19 towers (see Roster below), written by the owner on `design/tower_roster.html`.
3. **Upgrade structure:** decided (trunk C Optional Retrofit, depth B 4 + mastery; see above).
4. **Per tower, in question rounds** (in progress, in roster order, questions first; answers go in
   `design/tower_roster.md`): its three path purposes, its stats, its upgrades, and which upgrades counter
   which enemy mechanics. Then balance targets and how the bot probe checks them.
5. **Art** (after gameplay): looks and animations from the owner's names and descriptions, then per-path looks (#6),
   on mockup pages like the enemy art (`design/enemy_art.md`), within the turret cache rules.
6. **Implementation** waits on the owner's confirmation of the whole spec, and ships as its own PRs.

## Roster (owner, 2026-10-14)

The working roster is **19 towers**; each one's text and design live in `design/tower_roster.md`. Towers 1 to 17 are
the owner's; the Magneto Tower and Tractor Tower are Claude's proposals, added at the owner's request.

| # | Tower | Class | Weapon type |
|---|---|---|---|
| 1 | Gun Turret | Assault | Ballistic |
| 2 | Mortar Tower | Assault | Explosive |
| 3 | Laser Tower | Assault | Energy |
| 4 | Rocket Salvo | Assault | Explosive |
| 5 | Anti-Aircraft Turret | Assault | Ballistic |
| 6 | Artillery Cannon | Assault | Explosive |
| 7 | Railgun | Assault | Ballistic |
| 8 | Tesla Tower | Assault | Energy |
| 9 | Drone Bay | Assault | Deployable |
| 10 | CAS Gunship | Assault | Deployable |
| 11 | Mine Layer | Defense | Explosive |
| 12 | Chemical Plant | Support | Chemical (in notes) |
| 13 | Rally Beacon | Support | None |
| 14 | Radar Tower | Utility | Energy |
| 15 | Cryo Tower | Support | Field |
| 16 | Shockwave Generator | Assault | Field |
| 17 | Scrapyard | Utility | None |
| 18 | Magneto Tower (Claude's proposal) | Defense | Field |
| 19 | Tractor Tower (Claude's proposal) | Defense | Energy |

**Decided (owner, 2026-10-14):** this is the working roster; design it **tower by tower in roster order** (Gun Turret
first), **questions first**, before any drafting. No game code until the whole spec is confirmed. The gap review and
other Defense ideas from the roster work are at the end of `design/tower_roster.md`.

## Classes

Decided by the owner (2026-10-10); the full reference, with edge cases, is `design/tower_classes.md`. Each tower has
exactly one class, by its main job; the class groups the shop.

| Class | Job | Today's towers that would fit |
|---|---|---|
| Assault | Deals the damage | Pulse Turret, Plasma Mortar, Railgun, Arc Coil, Laser Lance, Missile Battery, Flak Battery, Nova Reactor, Drone Bay |
| Support | Boosts other towers: damage, range, fire rate | Amplifier Pylon |
| Defense | Holds the line: slow, stun, push, block | Cryo Emitter, Graviton Projector |
| Utility | Tools: reveal, strip enemy defences, economy | Sensor Array, Nullifier, Scrapyard |

**Weapon type (sub-tag, descriptive):** Ballistic, Energy, Explosive, Field (proposed), Deployable (proposed), None.

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

- **Four classes** (2026-10-10): Assault, Support, Defense, Utility; exactly one per tower; groups the shop;
  economy is Utility; weapon type kept as a descriptive sub-tag. Reference sheet `design/tower_classes.md`.
- **Pricing** (2026-10-15): value-based formula for all towers, rounded to 5s and 0s (see Pricing).
- **Working roster** (2026-10-14): 19 towers (`design/tower_roster.md`); designed tower by tower in roster order,
  questions first.
- **Upgrade structure** (2026-10-08): Optional Retrofit, 4 upgrades + mastery per path; the Retrofit is tower-specific,
  bought from a fourth card with its own hotkey, and visibly changes the tower.

### Still open

1. **Class sheet:** the owner's edits to `design/tower_classes.md`: the edge cases (Sensor Array, Nullifier), and
   accept or drop the Field and Deployable weapon types.
2. **Air or ground per tower,** and whether the roster covers flyers, the Wraith (energy only) and the Burrower well
   enough (asked tower by tower, then checked across the roster).
3. **The Retrofit's hotkey:** Y suggested; confirmed in the UI round.
4. **Per tower** (in progress): stats, the 4 upgrades and mastery on each path, the Retrofit, counter upgrades.
5. **Old saves and ids:** what happens to towers in old saves when the roster changes (save format bump, refunds).
6. **The bot, Codex, tests and tour:** how they follow the new roster.
7. **What a class does beyond the shop** (TBD): candidates are parked in the class sheet.
8. **Weapon types and the physical/energy split** the Wraith needs: decide later.
9. **Build hotkeys:** 19 towers need more keys than today's 15.
10. **A Wraith counter tower** (owner, 2026-10-15): the AA gun can't hurt the Wraith (physical damage); the owner wants
    a new tower idea for it, after the 19 towers are designed.
11. **Weapon type "Chemical":** the Chemical Plant's notes say Chemical; add it to the list?
12. **Folding in #6 and #8:** per-path looks come in the art phase; the #8 playtest tree tweaks are rewritten into the
   new trees.
