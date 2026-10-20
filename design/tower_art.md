# Bastion Line Tower Art Direction (design)

The models for the 20 reworked towers (`design/tower_roster.md`), designed with the owner on drawn mockup pages, the way
the enemy art was (`design/enemy_art.md`). **Draft: no game code changes until the owner confirms** (repo CLAUDE.md,
"Designing a feature first"). Issue #55.

## Direction (owner, 2026-10-16)

- **Format:** like the enemy art: drawn mockup pages (canvas, in the game's drawing style), **three options** per tower
  for its **look** and for its **firing animation**, notes boxes, and **Copy picks and notes**. The owner picks; Claude
  iterates.
- **Pages:** **roster order, about 5 towers per page**: towers 1-5, 6-10, 11-15, 16-20.
- **Scope:** the **base look**, the **firing animation**, the **per-path looks** (#6) and the **Retrofit looks**.
- **Order:** **base look and firing animation first**; once those are picked, a second pass adds the per-path looks and
  the Retrofit looks on top of the chosen design.
- **Style (changed again 2026-10-16): like today's in-game towers.** The owner said "Make the coloring and underlying
  design philosophy similar to what has already been made and start from scratch again", and chose **today's in-game
  towers** (`scripts/view/Draw.gd`) as the reference: dark gunmetal armour lit from the upper left (bevelled plates,
  rivets, shaded barrels and domes), the hex deck every tower stands on, and glowing accents in the tower's colour.
  **Weapons stay as named** (bullets, shells, rockets, beams).
- **History:** the owner first chose "modern military with sci-fi touches" (four rounds on page 1), then "sleek
  high-tech sci-fi" (one round, picks made, round 2 never shipped); both were scrapped along with **every pick** (owner:
  "Drop everything"). They're in git history.
- **Kept rules (owner):** the **laser locks on before firing**, and **shots leave the barrel that fired them**. The
  Rocket Salvo's launchers stay **horizontal** (the owner's last Rocket Salvo direction).
- **No tier styling:** upgrade steps don't shift the style balance (owner: "No"; the enemy art's gritty-to-sleek tiers
  don't carry over).
- **Colour:** **per tower**: each tower has its own accent colour. Round 1 uses today's colour of its nearest in-game
  tower: Gun Turret cyan (Pulse Turret), Mortar orange (Plasma Mortar), Laser red (Laser Lance), Rocket Salvo yellow
  (Missile Battery), Anti-Aircraft lime (Flak Battery).
- **No shared family look:** each tower is designed on its own (unlike the enemies' role families); the hex deck is
  the game's common tower base, not a family look.
- **Top-down**, like the game: a static base, and a turret that rotates to aim. (In the game, the animated parts go
  between `Draw.dyn(true)` and `dyn(false)`, and the rest is cached; see CLAUDE.md.)

## Mockup pages

Every preview runs live. The turret tracks the nearest enemy it can hit and fires on its animation's rhythm, at ground
enemies on the lane and flyers overhead (air-only towers ignore the ground, and ground-only towers ignore flyers).

| Page | Towers | File | Status |
|---|---|---|---|
| 1 | Gun Turret, Mortar Tower, Laser Tower, Rocket Salvo, Anti-Aircraft Turret | `design/tower_art_1.html` | **Confirmed** (round 2) |
| 2 | Artillery Cannon, Railgun, Tesla Tower, Drone Bay, CAS Gunship | `design/tower_art_2.html` | **Confirmed** (round 3) |
| 3 | Mine Layer, Chemical Plant, Boost Tower, Radar Tower, Cryo Tower | `design/tower_art_3.html` | **Confirmed** (round 3) |
| 4 | Shockwave Generator, Scrapyard, Magneto Tower, Tractor Tower, Augmentation Tower | `design/tower_art_4.html` | **Confirmed** (round 2) |

## Page 1, in-game style round 1 (towers 1-5)

| Tower | Look A | Look B | Look C |
|---|---|---|---|
| Gun Turret | Shielded Gun Mount | Twin Gun Nest | Rotary Gun |
| Mortar Tower | Turntable Mortar | Twin-Tube Mortar | Braced Siege Mortar |
| Laser Tower | Lance Emitter | Twin-Prong Emitter | Focus Lens |
| Rocket Salvo | Box Pod Launcher | Twin Side Pods | Quad Rail Pods |
| Anti-Aircraft Turret | Twin Autocannon | Quad Flak Mount | Heavy Flak Cannon |

| Tower | Animation A | Animation B | Animation C |
|---|---|---|---|
| Gun Turret | Single Shots | Three-Round Burst | Rapid Stream |
| Mortar Tower | High Lob | Double Tap | Heavy Shell |
| Laser Tower | Steady Beam | Pulse Beam | Ramp Burn (all lock on first) |
| Rocket Salvo | Ripple Salvo | Full Volley | Heavy Rockets |
| Anti-Aircraft Turret | Alternating Barrels | Flak Bursts | Lead Stream |

Rockets are drawn like the game's loaded missiles (pale body, red nose) with smoke trails, and the loaded noses show in
the tube mouths until a salvo leaves.

**Picks (owner, round 1):**

| Tower | Look | Animation | Status |
|---|---|---|---|
| Gun Turret | C Rotary Gun | C Rapid Stream | Picked |
| Mortar Tower | C Braced Siege Mortar | A High Lob | Picked |
| Laser Tower | A Lance Emitter | A Steady Beam | Picked |
| Rocket Salvo | C Quad Rail Pods | A Ripple Salvo | Owner note: "Change this to 3 barrels" |
| Anti-Aircraft Turret | C Heavy Flak Cannon | A Alternating Barrels | Picked |

## Page 1, round 2

- **Rocket Salvo look C** is now **Triple Rail Pods**: three round launch pods (was four), each a little wider.
- **Ripple Salvo** now fires **three** rockets per salvo, one per pod, so no pod fires twice. Claude made this change to
  fit the three pods; it's for the owner to confirm.
- Everything else is preselected as picked.

**Page 1 confirmed (owner, round 2):** Gun Turret C Rotary Gun / C Rapid Stream; Mortar Tower C Braced Siege Mortar /
A High Lob; Laser Tower A Lance Emitter / A Steady Beam; Rocket Salvo C Triple Rail Pods / A Ripple Salvo (three
rockets); Anti-Aircraft Turret C Heavy Flak Cannon / A Alternating Barrels.

## Page 2, round 1 (towers 6-10)

Colours: Railgun green, Tesla purple and Drone Bay green are today's colours for those towers; the **Artillery Cannon
(blue)** and **CAS Gunship (pink)** have no in-game counterpart, so their colours are Claude's proposals. The Drone Bay's
green sits close to the AA Turret's lime.

The previews show each tower's own mechanic:
- **Artillery Cannon:** it shells a marked spot and never tracks enemies.
- **Railgun:** the slug pierces the line, and the hit flashes shrink with the damage falloff.
- **Tesla Tower:** arcs jump from the target to 3 nearby enemies; the tower doesn't turn.
- **Drone Bay:** one drone flies out, fights and comes home. The look sets the bay and the drone; the animation sets
  how it fights.
- **CAS Gunship:** the plane circles a designated point, drawn smaller than the real 90 px orbit, and side-fires its
  gatling. The look sets the ground station and the plane.

| Tower | Look A | Look B | Look C |
|---|---|---|---|
| Artillery Cannon | Field Gun | Casemate Howitzer | Long Tom |
| Railgun | Twin-Rail Turret | Sealed Accelerator | Split Rails |
| Tesla Tower | Disk Coil | Twin Toroid | Lattice Mast |
| Drone Bay | Rotor Pad Hangar (quadcopter) | Jet Silo (delta jet) | Tilt-Rotor Hangar (tilt-rotor) |
| CAS Gunship | Airfield Beacon + Four-Engine Gunship | Control Tower + Twin-Boom Gunship | Uplink Dish + Tilt-Wing Lifter |

| Tower | Animation A | Animation B | Animation C |
|---|---|---|---|
| Artillery Cannon | Shell on the Mark | Muzzle Blast | Plunging Shell |
| Railgun | Snap Shot | Hypersonic Slug | Ion Trail |
| Tesla Tower | Chain Arc | Jumping Arc | Corona Burst |
| Drone Bay | Hunt and Circle | Strafing Dives | Stand-off Hover |
| CAS Gunship | Gatling Stream | Burst Sweeps | Brass Rain |

**Picks and notes (owner, round 1):**

| Tower | Look | Animation | Notes |
|---|---|---|---|
| Artillery Cannon | - | - | Look: "More ideas". Animation: "More ideas" |
| Railgun | B Sealed Accelerator | A Snap Shot | Animation: "Make sure the trail doesn't turn with the gun" |
| Tesla Tower | - | C Corona Burst | Look: "More designs" |
| Drone Bay | A Rotor Pad Hangar | - | Animation: "More ideas. Also, the drone should Idle if no enemies are around instead of heading back to the drone bay" |
| CAS Gunship | - | A Gatling Stream | Look: "The ship should be way larger, as if it were at high altitude. More ideas" |

**Decided (owner):** once launched, the **drone stays out**. It idles when no enemies are around and doesn't return to
the bay.

## Page 2, round 2

- **Railgun:** the line now stays where the shot went instead of turning with the gun. Picks preselected (B / A).
- **Artillery Cannon:**
  - New looks: **D Self-Propelled Gun**, **E Twin-Barrel Battery** and **F Rammer Howitzer**.
  - New animations: **D Walking Barrage**, **E Air Burst** and **F Spotter and Strike**.
- **Tesla Tower:** new looks **D Mushroom Cap**, **E Triple Spire** and **F Spark Gap**. Corona Burst is preselected.
- **Drone Bay:**
  - Every animation now keeps the drone out, with its own idle:

    | Animation | Fight | Idle |
    |---|---|---|
    | A Hunt and Circle | circles its prey, firing short bursts | hovers |
    | B Strafing Dives | fast passes over its prey | flies a figure-eight |
    | C Stand-off Hover | fires single shots from a distance | drifts in a slow circle |
    | D Weave Run (new) | weaves in, firing a stream | patrols along the track |
    | E Pounce (new) | waits high, then swoops in | climbs and circles high |
    | F Overwatch Orbit (new) | circles at long range | scans with a searchlight |

  - The preview clears the lane every few seconds to show the idle.
- **CAS Gunship:**
  - Every plane is now drawn **twice as large**, with a faint shadow far below, as if at high altitude.
  - New designs: **D Hardened Bunker + Flying Wing**, **E Radar Mast + Six-Engine Heavy** and **F Command Post + Jet
    Gunship**.
  - Gatling Stream is preselected.

**Picks (owner, round 2):**

| Tower | Look | Animation | Notes |
|---|---|---|---|
| Artillery Cannon | F Rammer Howitzer | (none picked) | |
| Railgun | B Sealed Accelerator | A Snap Shot | |
| Tesla Tower | B Twin Toroid | C Corona Burst | |
| Drone Bay | A Rotor Pad Hangar | A Hunt and Circle | |
| CAS Gunship | A Airfield Beacon + Four-Engine Gunship | A Gatling Stream | Look: "The guns shouldn't be visible on the top" |

## Page 2, round 3

- **CAS Gunship:** the gatling sits inside the fuselage. From above, only its muzzle flash shows at the side door; no
  gun is drawn on top. This applies to every CAS look.
- **Artillery Cannon:** no animation picked yet, and none of its six (A-F) carries a note.
- Everything else is preselected as picked.

**Page 2 confirmed (owner, round 3):**
- Artillery Cannon: F Rammer Howitzer / A Shell on the Mark.
- Railgun: B Sealed Accelerator / A Snap Shot (the line stays where the shot went).
- Tesla Tower: B Twin Toroid / C Corona Burst.
- Drone Bay: A Rotor Pad Hangar / A Hunt and Circle (the drone stays out and idles).
- CAS Gunship: A Airfield Beacon + Four-Engine Gunship, guns hidden, / A Gatling Stream.

The Artillery blue and CAS pink weren't changed, so they stand.

## Page 3, round 1 (towers 11-15)

None of these five fires ordinary shots, so each preview runs the tower's own mechanic:
- **Mine Layer:** mines are tossed onto the track and wait there until a ground enemy rolls over them; the preview caps
  at 6 mines (the real cap is 20). The look sets the fabricator and its mine; the animation sets the toss and the blast.
- **Chemical Plant:** it sprays one enemy at a time. Soaked enemies drip and fizz for 4 s and are skipped until they dry.
- **Boost Tower:** it attacks nothing. The preview puts three stand-in towers around it and shows them boosted with
  chevrons; its real reach is 3 tiles.
- **Radar Tower:** every other enemy is cloaked (a faint shimmer) until a ping reveals it for 1 s, marked with brackets.
- **Cryo Tower:** a cold wave every 2 s frosts every enemy it reaches. The preview doesn't actually slow them.

**Colours:**
- Today's colours: Chemical Plant acid green (Plasma Burn), Boost Tower magenta (Amplifier Pylon), Radar teal (Sensor
  Array) and Cryo ice blue (Cryo Emitter).
- The **Mine Layer's red-orange** is Claude's proposal (no in-game counterpart).
- Close pairs: the Boost magenta sits near the CAS pink, and the Chemical green near the Railgun's.

| Tower | Look A | Look B | Look C |
|---|---|---|---|
| Mine Layer | Arm Fabricator (disc mine) | Mine Mortar (pancake mine) | Conveyor Catapult (hex prong mine) |
| Chemical Plant | Tank Farm Sprayer | Vat Works | Pressure Sphere |
| Boost Tower | Beacon Mast | Emitter Array | Broadcast Antenna |
| Radar Tower | Dish Mast | Phased Array Block | Twin Dish Rotor |
| Cryo Tower | Vent Tank | Compressor Block | Cryo Spire |

| Tower | Animation A | Animation B | Animation C |
|---|---|---|---|
| Mine Layer | Lob and Blink | Skip Toss | Confetti Charge |
| Chemical Plant | Acid Stream | Mist Puff | Gel Glob |
| Boost Tower | Pulse Rings | Link Beams | Aura Field |
| Radar Tower | Ping Ring | Sweep Beam | Pulse Burst |
| Cryo Tower | Gas Wave | Frost Burst | Creeping Mist |

**Picks and notes (owner, round 1):**

| Tower | Look | Animation | Notes |
|---|---|---|---|
| Mine Layer | - | C Confetti Charge | Look: "More ideas" |
| Chemical Plant | - | A Acid Stream | Look: "more designs" |
| Boost Tower | - | - | Look: "more ideas". Animation: "more ideas" |
| Radar Tower | A Dish Mast | B Sweep Beam | Animation: "The beam should follow the radar dish" |
| Cryo Tower | B Compressor Block | - | Animation: "more ideas" |

## Page 3, round 2

- **Radar Tower:** the sweep now follows the dish, turning with it once every 3 s. The Twin Dish Rotor's sweep follows its
  dish too. Picks preselected (A / B).
- **Mine Layer:** new looks **D Drum Dispenser** (prong-sphere mine), **E Twin Press Factory** (box mine) and **F Rail
  Launcher** (canister mine). Confetti Charge is preselected.
- **Chemical Plant:** new looks **D Cooling Tower Works**, **E Barrel Yard Sprayer** and **F Distillery Columns**. Acid
  Stream is preselected.
- **Boost Tower:**
  - New looks: **D Holo Projector**, **E Capacitor Obelisk** and **F Signal Drum**.
  - New animations: **D Chevron Rain**, **E Power Cables** and **F Overcharge Sparks**.
- **Cryo Tower:** new animations **D Snow Squall**, **E Ice Spike Ring** and **F Fog Jets**. Compressor Block is
  preselected.

**Picks (owner, round 2):**

| Tower | Look | Animation | Notes |
|---|---|---|---|
| Mine Layer | F Rail Launcher | C Confetti Charge | Animation: "Lay the mines in random positions on the track" |
| Chemical Plant | F Distillery Columns | A Acid Stream | |
| Boost Tower | F Signal Drum | F Overcharge Sparks | |
| Radar Tower | A Dish Mast | B Sweep Beam | |
| Cryo Tower | B Compressor Block | C Creeping Mist | |

## Page 3, round 3

- **Mine Layer:** mines now land at random spots anywhere along the track in reach, and across its width, instead of near
  the tower.
- Everything else is preselected as picked.

**Page 3 confirmed (owner, "NEXT"):**
- Mine Layer: F Rail Launcher / C Confetti Charge (random mine spots).
- Chemical Plant: F Distillery Columns / A Acid Stream.
- Boost Tower: F Signal Drum / F Overcharge Sparks.
- Radar Tower: A Dish Mast / B Sweep Beam (the sweep follows the dish).
- Cryo Tower: B Compressor Block / C Creeping Mist.

The Mine Layer red-orange wasn't changed, so it stands.

## Page 4, round 1 (towers 16-20)

Each preview runs the tower's own mechanic:
- **Shockwave Generator:** a wave every 1.75 s; enemies flash as it passes them.
- **Scrapyard:** a 2×2 yard drawn at its real size. It attacks nothing and pays +100 at each round's clear (the preview
  pays every 4 s).
- **Magneto Tower:** a constant field; enemies inside show a pull arrow toward the magnet.
- **Tractor Tower:** grabs one enemy, drags it back for 1.5 s and lets go. The real recharge is 6 s; the preview
  shortens it. The preview redraws the held enemy where the beam drags it, since it can't move the real one.
- **Augmentation Tower:** links to three stand-in towers. Every third stand-in shot crits, so the 5% crit shows.

**Colours:**
- Today's colours: Shockwave amber (Nova Reactor), Scrapyard copper (Scrapyard) and Magneto violet (Gravity Well).
- **Proposals** (no in-game counterpart): the **Tractor's cyan** (the roster's look) and the **Augmentation lavender**.
- Close pairs: the Magneto violet sits near the Tesla's purple, and the Tractor cyan near the Gun Turret's.

| Tower | Look A | Look B | Look C |
|---|---|---|---|
| Shockwave Generator | Caged Reactor | Ring Reactor | Piston Thumper |
| Scrapyard | Crusher Yard | Compactor Plant | Magnet Yard |
| Magneto Tower | Horseshoe Magnet | Coil Drum | Twin Pole Pylons |
| Tractor Tower | Dish Emitter | Gimbal Projector | Claw Emitter |
| Augmentation Tower | Crystal Emitter | Orbiting Shards | Caged Prism |

| Tower | Animation A | Animation B | Animation C |
|---|---|---|---|
| Shockwave Generator | Blast Ring | Mushroom Pulse | Double Shock |
| Scrapyard | Round Payout | Sparks and Sale | Wreck Collector (shows the kill bonus too) |
| Magneto Tower | Field Lines | Pulse Pull | Iron Filings |
| Tractor Tower | Beam Cone | Grapple Beam | Spiral Lock |
| Augmentation Tower | Crit Links | Augment Glow | Shard Stream |

**Picks and notes (owner, round 1):**

| Tower | Look | Animation | Notes |
|---|---|---|---|
| Shockwave Generator | B Ring Reactor | B Mushroom Pulse | |
| Scrapyard | C Magnet Yard | B Sparks and Sale | |
| Magneto Tower | - | - | Look: "More ideas". Animation: "More ideas" |
| Tractor Tower | C Claw Emitter | (none picked) | |
| Augmentation Tower | - | - | Look: "More ideas". Animation: "More ideas" |

## Page 4, round 2

- **Magneto Tower:**
  - New looks: **D Ring Electromagnet**, **E Lifting Magnet Crane** and **F Stacked Coil Tower**.
  - New animations: **D Spark Arcs**, **E Gravity Ripple** and **F Drag Trails**.
- **Augmentation Tower:**
  - New looks: **D Tuning Fork Spire**, **E Glyph Ring** and **F Nanite Hive**.
  - New animations: **D Nanite Swarm**, **E Heartbeat Tethers** and **F Overdrive Halo**.
- **Tractor Tower:** its animation is still open. A-C are unchanged, since there was no note.
- The Shockwave, Scrapyard and Tractor look picks are preselected.

**Page 4 confirmed (owner, round 2):**
- Shockwave Generator: B Ring Reactor / B Mushroom Pulse.
- Scrapyard: C Magnet Yard / B Sparks and Sale.
- Magneto Tower: F Stacked Coil Tower / F Drag Trails.
- Tractor Tower: C Claw Emitter / C Spiral Lock.
- Augmentation Tower: F Nanite Hive / D Nanite Swarm.

The Tractor cyan and Augmentation lavender weren't changed, so they stand.

## All base looks and firing animations (confirmed 2026-10-16)

| # | Tower | Colour | Look | Animation |
|---|---|---|---|---|
| 1 | Gun Turret | cyan | C Rotary Gun | C Rapid Stream |
| 2 | Mortar Tower | orange | C Braced Siege Mortar | A High Lob |
| 3 | Laser Tower | red | A Lance Emitter | A Steady Beam (locks on first) |
| 4 | Rocket Salvo | yellow | C Triple Rail Pods | A Ripple Salvo (three rockets) |
| 5 | Anti-Aircraft Turret | lime | C Heavy Flak Cannon | A Alternating Barrels |
| 6 | Artillery Cannon | blue | F Rammer Howitzer | A Shell on the Mark |
| 7 | Railgun | green | B Sealed Accelerator | A Snap Shot (the line stays where it fired) |
| 8 | Tesla Tower | purple | B Twin Toroid | C Corona Burst |
| 9 | Drone Bay | green | A Rotor Pad Hangar | A Hunt and Circle (stays out and idles) |
| 10 | CAS Gunship | pink | A Airfield Beacon + Four-Engine Gunship (guns hidden, high altitude) | A Gatling Stream |
| 11 | Mine Layer | red-orange | F Rail Launcher | C Confetti Charge (random spots) |
| 12 | Chemical Plant | acid green | F Distillery Columns | A Acid Stream |
| 13 | Boost Tower | magenta | F Signal Drum | F Overcharge Sparks |
| 14 | Radar Tower | teal | A Dish Mast | B Sweep Beam (follows the dish) |
| 15 | Cryo Tower | ice blue | B Compressor Block | C Creeping Mist |
| 16 | Shockwave Generator | amber | B Ring Reactor | B Mushroom Pulse |
| 17 | Scrapyard | copper | C Magnet Yard | B Sparks and Sale |
| 18 | Magneto Tower | violet | F Stacked Coil Tower | F Drag Trails |
| 19 | Tractor Tower | `design/tower_art_p19_tractor.html` | **Redesign** (owner, 2026-10-19): base round 2: picks B Armoured Dish, B Focus Beam; waiting for "Tractor Tower base finished" |
| 20 | Augmentation Tower | lavender | F Nanite Hive | D Nanite Swarm |

## Second pass: per-path and Retrofit looks (owner, 2026-10-16)

**Decided:**
- **Every step and the mastery** of every path changes the look. Each upgrade **adds or changes a detail**.
- **Overlapping Retrofits stack (owner, 2026-10-17, "the carpet rule"):** from the Railgun (tower 7) on, a Retrofit that
  overlaps a path step is kept as written and its stats stack on the path's. No replacement is asked for. Towers 1 to 6
  are settled as they are.
- **Both the primary and the secondary show**, and their details overlap (owner: "Each upgrades adds or changes a
  detail to the tower, so they overlap").
- **Three options per stage:** every step and mastery is picked separately (A/B/C) and can be mixed freely. Each
  Retrofit also gets three options.
- **One tower per page:** `design/tower_art_p2_NN_<tower>.html`, in roster order.
- **A build preview with level sliders:** set each path's level (M is the mastery) and a Retrofit, and watch the
  combined model fire. It enforces the primary/secondary rule: two paths at most, and once one reaches 3 the other stops
  at 2. Unpicked steps show option A.

**Conventions (Claude):**
- Masteries get gold trim, as today's tier-4 towers do.
- Paths that add guns move the firing points, so shots still leave their own barrel.
- Paths that add crits show a gold burst at the crit rate.

| # | Tower | File | Status |
|---|---|---|---|
| 1 | Gun Turret | `design/tower_art_p2_01_gun.html` | **Confirmed** (owner, 2026-10-17: "Gun turret finished") |
| 2 | Mortar Tower | `design/tower_art_p2_02_mortar.html` | **Confirmed** (owner, 2026-10-17: "Mortar finished"; its bore glow stays) |
| 3 | Laser Tower | `design/tower_art_p2_03_laser.html` | **Confirmed** (owner, 2026-10-17: "Laser finished") |
| 4 | Rocket Salvo | `design/tower_art_p2_04_rocket.html` | **Confirmed** (owner, 2026-10-17: "Rocket Salvo is done") |
| 5 | Anti-Aircraft Turret | `design/tower_art_p2_05_aa.html` | **Confirmed** (owner, 2026-10-17: "AA Finished"; Range 3 is the Optical Director) |
| 6 | Artillery Cannon | `design/tower_art_p2_06_artillery.html` | **Confirmed** (owner, 2026-10-17: "Artillery finished"; stock scatter kept as drawn, 30 px) |
| 7 | Railgun | `design/tower_art_p2_07_railgun.html` | **Confirmed** (owner, 2026-10-18: "Railgun finished"; the larger drum is for the twin build only) |
| 8 | Tesla Tower | `design/tower_art_p2_08_tesla.html` | **Confirmed** (owner, 2026-10-18: "Finished") |
| 9 | Drone Bay | `design/tower_art_p2_09_drones.html` | **Confirmed** (owner, 2026-10-18: "Finished") |
| 10 | CAS Gunship | `design/tower_art_p2_10_cas.html` | **Confirmed** (owner, 2026-10-18: "Finished") |
| 11 | Mine Layer | `design/tower_art_p2_11_mines.html` | **Confirmed** (owner, 2026-10-18: "Finished") |
| 12 | Chemical Plant | `design/tower_art_p2_12_chem.html` | **Confirmed** (owner, 2026-10-19: "finished") |
| 13 | Boost Tower | `design/tower_art_p2_13_boost.html` | **Confirmed** (owner, 2026-10-19: "finished") |
| 14 | Radar Tower | `design/tower_art_p2_14_radar.html` | **Confirmed** (owner, 2026-10-19: "finished") |
| 15 | Cryo Tower | `design/tower_art_p2_15_cryo.html` | **Confirmed** (owner, 2026-10-19: "Finished"; Deep Cold C Frost Collar) |
| 16 | Shockwave Generator | `design/tower_art_p2_16_shock.html` | **Confirmed** (owner, 2026-10-19: "Finished") |
| 17 | Scrapyard | `design/tower_art_p2_17_scrap.html` | Base **confirmed** (owner, 2026-10-19: B Production Line, B Melt and Pour; base page `design/tower_art_p17_scrapyard.html`). New upgrade names confirmed. Second pass **confirmed** (owner, 2026-10-19, "Finished"; round 5) |
| 18 | Magneto Tower | `design/tower_art_p2_18_magneto.html` | Second pass **confirmed** (owner, 2026-10-19, "finished"; round 3) |
| 19 | Tractor Tower | `design/tower_art_p2_19_tractor.html` | Second pass round 2: Recharge and two Retrofits picked; pick Pull Distance (new ideas), Grip (now the effect's strength) and the replacement for Twin Emitter |

### Gun Turret (second pass)

**Picks (owner, round 1):**
- **Power:** 1 C Reinforced Breech, 2 C Marked Shroud, 3 C Armour Cheeks, 4 B Counterweight, M B Gold-Banded Gun.
- **Range/Visibility:** 1 A Barrel Extensions, 2 B Tracer Drum, 3 A Fluted Barrels, 4 B Laser Rangefinder, M C Hex
  Lens Crown.
- **Multi-Target:** 1 B Bearing Rollers, 2 A Flank Gun, 3 A Twin Rotary, 4 B Ammo Hopper, M A Triple Rotary.
- **Retrofits:** Water-Cooled Barrel A Water Jacket, Shock Rounds A Coil Wraps, Incendiary Rounds A Fuel Canister.

**Round 2 (Claude, from the owner's notes):** the picks are drawn as one parametric model, so details from different
paths work together.
- **Range 1** swaps the barrels for longer ones instead of laying an extension over them. Every gun on the mount gets
  the longer barrels, and Range 3's fluting.
- **Power 2's marked shroud** sits on the front ring, over the barrels, wherever the muzzle is. Power's mastery and
  Multi-Target's mastery turn it gold instead of adding a new shroud.
- **Range 2** turns the drum's ring red instead of adding a circle.
- **Extra guns** sit on their own swivel mounts, with bodies bigger than their barrels, and aim at their own targets. The
  engine now sends the main gun's shots to the enemy it's aimed at.
- **Extra guns get the same kit:**
  - a gun shield from Power 1. The owner's "shielding" at pathing 1/0/x is read as a gun shield; to confirm.
  - the marked shroud.
  - the longer and fluted barrels.
  - the Retrofit's jacket, coils or fuel line.
- **The water jacket and coils** grow with the longer barrels.
- **Small placement calls (Claude):**
  - the Laser Rangefinder moves to the right side when a flank gun is fitted.
  - the drum moves back at Multi-Target's mastery to make room for the third gun.

**Round 3 (owner, 2026-10-17):**
- Multi-Target 1 is now **A Geared Swivel Ring** (was Bearing Rollers).
- Multi-Target 4 is now **C Feed Gears** (was Ammo Hopper): spinning gears on the body and on every extra gun's mount.
- The Water Jacket loses its tank and hose.
- No blue muzzle glow. The single bore floating in front of the cluster is gone (owner): each barrel has its own bore
  at its tip, and a short pale flash shows at the firing barrel. Shots leave that barrel.
- The dark arm connecting each extra gun to the turret centre is removed (owner); the mounts stand on their own.
- **The rounds change at every Power step** (owner: "Heavier and harder"; then "They should still look like bullets,
  they're too thick"). Each step is a slim pointed bullet on the same thin tracer:
  1. a brass bullet.
  2. a steel tip.
  3. a dark AP bullet with a yellow band.
  4. a white-hot tungsten core glowing at its base.
  5. Mastery: a slim finned sabot dart that sheds its petals at the muzzle, with a gold streak.

  Every gun on the mount fires them. The Range path's long tracer lines and Incendiary's orange still apply to the
  trail.

### Mortar Tower (second pass)

**Round 1 (Claude):** drawn as one parametric model from the start, applying the Gun Turret's lessons:
- **Options swap parts** instead of laying overlays over them. Longer tubes move the bores forward; Twin Tubes and the
  Barrage Battery re-lay the mount with two or three narrower tubes.
- **Every tube carries every detail:** Power's bands, breech and fuses, the Blast path's sleeves, bands and vanes,
  Speed's sleeves and rings, and the Retrofit's sight.
- **Each Power step changes the shells:**
  - 1: a red band, a bigger shell or a hotter glow.
  - 2: a steel nose, a copper rim or a red trail.
  - 3: a dark AP shell with a yellow band.
  - 4: fins, or a blinking delayed fuse.
  - Mastery: gold drill tips, seismic rings or ground cracks.
- **The Blast path grows the blast** (60 to 90 px). Cluster Shells add 4, 6, then 8 bomblets, or a mid-air dispenser.
- **Smoke Shells:** every 4th shell flies grey and leaves smoke.
- **Kit placement:** Power kit by the mount's left side, Blast kit on the right, Speed and Retrofit kit at the back.
- **Muzzles:** the base Mortar's bore glow is kept, since only the Gun Turret's was removed. To confirm for the Mortar.
- **An angled tube** (owner: "The mortar looks more like a flat body with a circle, can you make it look more like an
  angled tube?"). Every tube is now drawn as a cylinder rising from a rounded breech low at the back to a raised mouth
  at the front:
  - it widens toward the mouth, with a lit side and a shaded side.
  - trunnion pins hold it on its yoke.
  - its shadow lengthens toward the mouth.
  - the mouth is an ellipse squashed along the aim, since the opening faces up and forward. The collar, fin slots,
    vanes and clamps follow that ellipse.
  - the mouth is sized to the tube, its rim just outside the tube's sides (owner: "The barrel end is too thick for the
    barrel").
  - then pulled back toward the confirmed original (owner: "Make it look closer to the original"). It keeps the
    original's short, thick tube and near-round bore, with only a hint of the angle: a slight flare to the mouth, the
    breech cap, trunnion pins and a soft shadow.
  - Layering fixed (owner: "The layering is incorrect and still looks rather odd"):
    - each tube's shadow sits on the deck, under the legs and mount.
    - the tube is one shaded barrel with a rounded back end, as the original draws it, instead of a ball on top.
    - trunnion pins and a slight flare band near the mouth.
  - the mouth shrinks again so its rim lines up with the tube's sides (owner: "the muzzle is still slightly oversized").
  - the owner briefly reverted to the original tube, then undid that ("nevermind"): this angled version stands.

**Picks (owner, round 1):**
- **Power:** 1 B Reinforced Collar, 2 A Pointed Shells, 3 C AP Rack, 4 A Fuse Timer, M B Gold Bore Rings.
- **Speed/Range:** 1 C Ready Rack, 2 A Longer Tubes, 3 C Twin Cradle, 4 A Even Longer, M B Triangle Cluster.
- **Blast:** 1 B Fat Shells, 2 B Fragmentation Sleeves, 3 B Bomblet Rack, 4 B Second Rack, M A Gold Canisters.
- **Retrofits:** Field Kit C Field Crate, Bunker Sight B Seismic Probe, Smoke Shells (none picked; see the note).

**Round 2 (Claude, from the owner's notes):**
- **Only the barrel turns.** The legs, the mount plate and the recoil spade are gone. Every rack, the crate and the probe
  sit in fixed spots on the deck. The twin cradle and the tube kit turn with the tubes. The spade's removal is Claude's
  reading of "the only thing that should move is the mortar barrel".
- **Racks show the current shells.** Power restyles the shells in any rack on the tower (the Ready Rack, the Field Kit's
  crate) instead of adding racks (x/1/0). Power's own rack appears only when there's no other.
- **Speed's mastery gets gold muzzle rims**, as Power's mastery does.
- **Blast's mastery turns the shells gold**, in flight and in the racks.
- **Smoke Shells:** from the note, every shell (in flight and in the racks) carries the grey smoke band; every 4th
  leaves a cloud.
- **Round 3 (owner):**
  - a **stationary baseplate** under the barrel (fixed, not turning; the tube's shadow falls on it).
  - **Smoke Shells A** (the smoke band on every shell) picked.
  - **the bomblet rack stacks** 1 x 3 at step 3, 2 x 3 at step 4 and 2 x 4 at the mastery (gold).

### Laser Tower (second pass)

**Round 1 (Claude):** one parametric model, with the lessons so far:
- **Options swap parts:** the Range path swaps in longer lances, with the focusing rings spread along them.
- **Side emitters carry the main lance's details.**
- **Deck kit stays put;** only the turret turns.
- **The beam changes along the Power path:**
  - it ramps wider and hotter over the ramp time.
  - it whitens from Overdrive on.
  - it's wrapped in gold at full ramp at the mastery.
- **Multi-Target adds beams:**
  - 2, then 3, then 4 beams, from a tip prism or from flank emitters.
  - each extra beam locks on its own target with its own reticle.
  - at the mastery each beam ramps on its own.

**Picks (owner, round 1):**
- **Power:** 1 C Heat Vents, 2 C Fast Focus, 3 A Overdrive Core, 4 B Big Heat Sinks, M C Gold Heat Sinks.
- **Multi-Target:** 1 A Splitter Prism, 2 B Thicker Beam, 3 C Prism Cluster, 4 B Brighter Beams, M C Prism Halo.
- **Range/Targeting:** 1 A Longer Lance, 2 A Collimator Rings, 3 C Rail Lance, 4 A Even Longer, M A Gold Rings.
- **Retrofits:** Capacitor Bank C Capacitor Ring, Heat Sinks B Radiator Blocks.

**Round 2 (owner's notes and answers):**
- **The Focusing Lens Retrofit was redundant** with Power step 2, so it's replaced by **Ramp Memory**: switching targets
  keeps half the ramp. Its price is 55 (a formula estimate, proposed).
- **The Heat Sinks' overlap** with Power step 1 (both ramp ceiling ×3.5) stays (owner: "Keep it as is").
- **The Radiator Blocks replace all the heat-sink fins.** Power's Big Heat Sinks and Gold Heat Sinks then grow and gild
  the blocks instead.
- **Ramp Memory's look** has three options: Charge Reservoir, Memory Coil, Afterglow Crystal. The owner picked **C,
  the Afterglow Crystal** (round 3).

### Rocket Salvo (second pass)

**Retrofits replaced first** (owner, 2026-10-17). Claude checked for overlaps before drawing; all three overlapped a
path:

| Was | Overlapped | Now |
|---|---|---|
| Guidance Fins | Range step 2's homing (partly) | **Proximity Fuses** |
| Autoloader | the Payload path's reloads (Quick Loader, Auto-Loader) | **Smoke Trails** |
| Long Booster | Range step 1 (Booster Stage) | **Incendiary Warheads** |

Their prices are formula estimates (proposed), in `design/tower_roster.md`.

**Round 1 (Claude):** one parametric model.
- **Each Power step changes the rockets:**
  - 1: a red band, a longer nose or a hotter exhaust.
  - 2: an orange burst nose or fragmentation rings.
  - 3: fatter rockets.
  - 4: dark rockets with a yellow band.
  - Mastery: gold noses and fuel-air blasts.
- **Range:** a booster stage that falls away mid-flight, longer pods or a rail. From step 2 rockets home onto moving
  targets; before it they fly at where the target was.
- **Payload:** re-lays the launcher with 4, 6, then 8 tubes, each rocket leaving its own tube. Wide blocks are riveted
  plates.
- **Deck kit stays put.**

**Picks (owner, round 1):**
- **Power:** 1 B Long Noses, 2 B Frag Sleeves, 3 A Heavy Rockets, 4 A Dense Cores, M A Gold Warheads.
- **Range:** 1 A Booster Stages, 2 A Seeker Domes, 3 A Seeker Lights, 4 A Long-Burn Motors, M C Hunter Eye.
- **Payload:** 1 A Fourth Pod, 2 A Loader Arm, 3 B Twin Banks, 4 C Conveyor, M B Twin Four-Banks.
- **Retrofits:** Proximity Fuses A, Smoke Trails A, Incendiary Warheads A.

**Round 2 (owner's notes):**
- **5/2/0:** the Seeker Heads' blue nose wins over the Power mastery's gold, in flight and in the tubes.
- **The pods and banks are bigger than their mouths.**
- **The Ripple Salvo stacks its tubes 2 x 2** in each side bank.
- **The 8-tube banks stand tall** (owner, round 3: "It still looks flat"):
  - each bank is a raised box: its top face lifted, the side and front faces facing the viewer shaded, a long shadow.
  - the 2 x 2 tubes really stack: the upper pair on the top's front edge, the lower pair on the front face.
  - rockets leave their own row.
  - the mouths show only when the bank's front faces the viewer (owner: "The holes are visible from the opposite end").
  - the gold bands wrap all the way round: across the top and down every visible side (owner).
  - the central hub sits down between the banks, drawn under them (owner: "That central ball is also visible through
    the silos").

### Anti-Aircraft Turret (second pass)

**Retrofits kept** (owner, 2026-10-17). Claude flagged that all three overlap a path:
- Fire-Control Radar (+15 range) overlaps Range.
- Ammo Drum (+10% fire rate) overlaps Speed.
- Armoured Mount (+4 damage) overlaps Power step 1.

The owner kept all three as they are.

**Round 1 (Claude):** one parametric model.
- **Range** swaps in longer barrels and raises the mount (a pedestal, rams or a mast).
- **Power/Blast changes the rounds each step:** brass bullets, then dark flak shells that burst beside the flyer. The
  bursts grow (20 to 50 px) and are shown as a flak puff with a faint ring for their reach; flyers caught in one flash.
- **Speed adds barrels:** 2, then 4, each firing in turn from its own muzzle.
- **Deck kit stays put.**

**Picks (owner, round 1):**
- **Range:** 1 A Longer Barrel, 2 A Raised Pedestal, 3 (none picked), 4 A HV Barrel, M A Gold Sky Radar.
- **Power/Blast:** 1 B Heavy Breech, 2 A Flak Fuzes, 3 A Heavy Flak, 4 B Frag Sleeves, M B Curtain Battery.
- **Speed:** 1 A Extra Springs, 2 A Traverse Ring, 3 A Twin Cannons, 4 B Feed Gears, M A Quad Cannons.
- **Retrofits:** Fire-Control Radar A, Ammo Drum A, Armoured Mount B.

**Round 2:** the traverse ring sits on the baseplate under the turret (owner). Range step 3 (Sky Watch) keeps its three
options until it's picked.

**Round 3:** the Ammo Drum replaces the ammo crate (owner: "Drum mag should replace the existing magazine").

**Round 4:** Range step 3 (Sky Watch) is B, the Optical Director (owner: "I meant optical director"). With the
director fitted, the mastery's gold radar moves to the other side of the deck so the two don't overlap.

### Artillery Cannon (second pass)

**Retrofits** (owner, 2026-10-17). Claude flagged that all three duplicated a path step exactly:
- Ammo Hoist (a shell every 3.3 s) = Speed step 1. **Replaced by the Shell Magazine** (owner's pick): every third shell
  is a heavy round for +50% damage.
- Heavy Recoil Mount (+15 damage, 90) = Power step 1. **Replaced by the Stabilised Mount** (owner's pick): shells land
  within 15 px of the aimed spot instead of scattering up to 30 px.
- Wide Charge (+15 px blast, 85) = Power step 2. **Kept** by the owner.

**Round 1 (Claude):** one parametric model (base look F Rammer Howitzer, animation A Shell on the Mark).
- **Power** changes the shell at every step (bigger, red band, orange stripes, dark yellow-banded, pointed or finned,
  gold at the mastery); the barrel, cradle and tray carry the same marks.
- **Speed** swaps the reloading kit (loader arm, hydraulic breech, autoloader drum, servo motor); the mastery fires
  3-shell barrages that walk across the aimed spot.
- **Special Effects** unlocks shell types (incendiary, shrapnel, concussion, combined); the cannon cycles through the
  unlocked types in the build preview, and a small selector dial on the deck shows which is loaded.
- **Deck kit is static;** only the rammer, cradle, barrel and hub turn.
- **Assumption to confirm:** the stock cannon scatters its shells up to 30 px around the aimed spot (it isn't in the
  confirmed stock stats), so the Stabilised Mount's 15 px shows. Say if the stock should be exact instead.

**Picks (owner, round 1):**
- **Power:** 1 A Heavy Breech Block, 2 B Fragmentation Sleeve, 3 A Dark HE Shells, 4 C Long Penetrators, M B Gold Muzzle Brake.
- **Speed:** 1 A Loader Arm, 2 A Hydraulic Breech, 3 A Autoloader Drum, 4 C Recoil Springs, M A Triple Rammer.
- **Special Effects:** 1 B Igniter Coil, 2 B Fan Vanes, 3 C Damper Pads, 4 C Fuse Computer, M A Gold Selector.
- **Retrofits:** Shell Magazine A, Stabilised Mount A, Wide Charge A.
- **Note:** Long Penetrators should change the shape of the round.

**Round 2:** the Long Penetrators now change the round itself: a long slim shell with a steel tip, in flight and in the
tray (it was a round shell with a tail). The page shows only the picks.

**Round 3 (owner's note):** "Move the crane to where it can move scrap to the conveyer belt where it can be fall off the conveyer belt into the furnace". The crane now stands between the big heap and the foot of the belt, in a 3.2 s cycle: it grabs a piece of scrap from the heap, swings it over and drops it on the belt; the piece rides up the belt and falls off the top end into the furnace mouth, glowing as it drops, with a flare. The belt now runs straight at the stack and is drawn over its rim; the tank hulk moved to the bottom-left corner, clear of the belt. The pieces are drawn from the time alone, so the crane and the belt always agree.

### Railgun (second pass)

**Retrofits kept, stats stacking (owner, 2026-10-17, the carpet rule).** Claude flagged that all three overlap a path:
- Capacitor Coils (recharge 2.5 to 2.2 s) = Speed step 1, Fast Capacitors (2.2 s). It takes a further 0.3 s off.
- Longer Rails (+15 damage, +30 range) overlaps Power step 1 (damage) and Speed step 2, Extended Rails (range, and the
  same look). Both lengthen the housing.
- Penetrator Tips (falloff 40% to 30%) overlaps Special step 2, Penetrator Core (40% to 25%). It takes a further 10%
  off the falloff.

**Round 1 (Claude):** one parametric model (base look B Sealed Accelerator, animation A Snap Shot).
- **Power** thickens and tints the shot at each step (red edges for Boss Rounds, a white core for Kill Charge, gold
  at Kingslayer); the housing, collars and drum carry the matching parts.
- **Range/Speed** swaps the capacitor and housing parts; the mastery splits the housing into two rails that fire in
  turn, each with every detail.
- **Special Effects:** hits crack from Shatter; the hit flashes shrink by the falloff (none at the mastery); the
  Ionised Trail lingers and crackles along the line.
- **The slug head** runs ahead of the line: dark and pointed with Penetrator Tips.
- **Deck kit is static;** only the housing turns.

**Round 1 fix (owner: "looks more like a long bar with a circle on the end"):** the housing is now a flat-ended tube shaded
like a cylinder, with wrap-around collar bands and an open mouth (a lip ring, dark bore and charge glow) instead of a
rounded bar end with a disc.

**Round 1b (owner: "new ideas for Path 1 t3, and tighten up the red rings for Boss marker"):**
- Power step 3 (Overcharge) has three new options: **Pressure Tanks** (two deck tanks with gauge rings), **Spiral Coil** (a
  copper helix round the back of the housing that lights turn by turn) and **Arc Pylons** (two pylons throwing sparks to
  the drum). They replace the bigger drum, the muzzle halo and the cell row.
- Power step 2, **Boss Marker Ring**: two thin red rings hugging the housing, instead of wide, thick ones.

**Round 1c (owner: "more ideas for P2T1"):** Range/Speed step 1 (Fast Capacitors) has three new options: **Charge Relay**
(a relay box with a cable to the drum, a pulse running along it), **Flywheel** (spins faster as it charges) and **Ready
Beacon** (dim while charging, a bright green pulse when ready). They replace the cell bank, the dial and the spare cells.

**Round 1d (owner: "more ideas for P2T2"):** Range/Speed step 2 (Extended Rails) has three new options: **Telescoping
Barrel** (a narrower inner tube slides out of the housing, the mouth on the narrower tube), **Rangefinder** (a twin-lens
box with scale ticks on the housing's side) and **Guide Rails** (slim rails with cross-struts alongside, running a little
past the mouth). They replace the longer housing, the sleeve and the braces.

**Picks (owner, round 1, with the new-idea rounds 1b to 1d):**
- **Power:** 1 C Tungsten Collars, 2 B Boss Marker Ring, 3 C Arc Pylons, 4 B Dual Charge Ring, M B Gold Drum Ring.
- **Range/Speed:** 1 C Ready Beacon, 2 A Telescoping Barrel, 3 C Capacitor Stack, 4 A Copper Windings, M A Parallel Rails.
- **Special Effects:** 1 C Crack Lamp, 2 C Piercing Cage, 3 A Ion Rings, 4 B Heat Vents, M none.
- **Retrofits:** Capacitor Coils A, Longer Rails none, Penetrator Tips A.
- **Notes:** Kingslayer: "Have the chargeup and the green centerline gold instead of the whole drum". Twin Rails: "Have the
  parallel rails run side by side". "More ideas" for Fast Capacitors, Rapid Capacitors, Supercapacitors, and every Special
  Effects tier.

**Round 2 (Claude):**
- **Kingslayer B:** only the charge-up arc and the green centreline go gold now; the gold ring round the whole drum is gone.
- **Twin Rails A:** the two housings now run directly side by side (touching, centres 7 px apart) and are joined by
  clamps at the collars. I read "side by side" as close together; if you meant something else (say, firing together),
  tell me.
- **New ideas:** Fast Capacitors (Coolant Loop, Spark Gap, Cable Reel); Rapid Capacitors (Drum Cage, Capacitor Spine,
  Charge Reservoir); Supercapacitors (Field Rings, Bus Bars, Cryo Jacket); Shatter Rounds (Resonator Fork, Etching Tank,
  Impact Studs); Penetrator Core (Drill Tip, Core Magazine, Lance Prongs); Ionised Trail (Ion Fins, Plasma Tube, Ion
  Grid); Hot Rail (Glowing Rail Edges, Steam Vents, Heat-Fin Block); Ion Cannon (Gold Lens Ring, Gold Spine, Gold Emitter
  Funnel).
- Picked stages show only the pick; the Longer Rails Retrofit keeps its three options.

**Picks (owner, round 2):**
- **Power:** 1 C Tungsten Collars, 2 B Boss Marker Ring, 3 C Arc Pylons, 4 B Dual Charge Ring, M B Gold Drum Ring.
- **Range/Speed:** 1 C Cable Reel, 2 A Telescoping Barrel, 3 B Capacitor Spine, 4 A Field Rings, M A Parallel Rails.
- **Special Effects:** 1 none, 2 none, 3 B Plasma Tube, 4 A Glowing Rail Edges, M none.
- **Retrofits:** Capacitor Coils A, Longer Rails B (Heavy Housing), Penetrator Tips A.
- **Notes:** "Larger drum, both barrels reciprocate together, move the inside capacitor spine to the outside (So both
  are external)". "Need new ideas for the shatter rounds and the penetrator core".

**Round 3 (Claude):**
- **Twin Rails:** both housings recoil together on every shot (the flash and the charge still alternate between them);
  the drum is larger (r 9, was 6.5) so it spans both rails. I applied the larger drum to the twin build only, since
  the notes sat with the twin-rail ones; if you meant every build, say so.
- **Capacitor Spine:** it sits on the outside of each rail, so on the twin build both spines are external. The Plasma
  Tube is outside too.
- **New ideas:** Shatter Rounds (Hammer Ring, Shard Array, Fracture Lattice); Penetrator Core (Sabot Petals, Core Feed
  Port, Rifling Bands). Ion Cannon is still unpicked and keeps its three options.

**Picks (owner, round 3):** Special Effects 1 C Fracture Lattice, 2 B Core Feed Port, 3 B Plasma Tube, 4 A Glowing Rail Edges,
M C Gold Emitter Funnel; the other picks are unchanged. No notes.

**Round 4:** every stage is picked; the page shows only the picks.

**Charge sync fix (owner: "make sure the charge circle fills in sync with the fire rate"):** the charge arc (and everything
else that charges) used the engine's `fx.barrelSince`, which drops back to "never fired" once a shot's flight is over
(flight + 0.6 s), so on slow recharges the arc jumped to full early and sat there. The model now reads the engine's own
fire clock, so the arc starts empty at each shot and is full exactly when the next shot fires (checked at five recharge
rates, from 1.2 s to 2.7 s, with no drops). The same stale shot count affected the Artillery Cannon's Shell Magazine
counter lamps; that is fixed too.

**Floating capacitors fix (owner: "the side capacitors are floating"):** the Capacitor Spine's discs sat a few pixels off the
housing with nothing joining them. They now hang on a backing bar along the housing's outer edge, each with its own
bracket, on single and twin builds alike.

### Tesla Tower (second pass)

**Retrofits kept, stats stacking (the carpet rule).** All three overlap a path step; Claude flagged them and kept them:
- Bigger Disk (+4 damage, +15 range) adds to High Voltage (+8 damage) and Taller Coil (+20 range).
- Grounding Rods (+1 jump) adds to Extra Jump (4 jumps).
- Insulated Coils (an arc every 1.1 s) adds to the Speed path; the model takes 0.15 s off the recharge on top of it.

**Round 1 (Claude):** one parametric model (base look B Twin Toroid, animation C Corona Burst). The tower never turns.
- **Power/Damage:** each step changes the arc (thicker; yellow EMP crackles at the hit; a stun halo; only a little
  falloff per jump; gold at Lightning Rod).
- **Range/Chaining:** more jumps (3 up to 7, plus one from Grounding Rods); from Storm Field every landing leaves a
  crackling storm that fades over 2 s (25 px, 30 px and gold at the mastery).
- **Speed:** the recharge goes from 1.25 s to 0.48 s (2.1 arcs/s); at the mastery sparks crawl across the toroids all the
  time. The charge indicators fill in exactly one recharge, from the engine's own fire clock (the Railgun lesson).
- **Deck kit is static;** all parts sit inside the hex.

**Picks (owner, round 1):**
- **Power/Damage:** 1 A Fat Nodes, 2 B Circuit Traces, 3 A Stun Rods, 4 C Ground Straps, M C Gold Nodes.
- **Range/Chaining:** 1 A Extra Windings, 2 A Jump Relays, 3 A Storm Rim, 4 A Wide Rim Ring, M B Gold Pylons.
- **Speed:** 1 A Charge Cells, 2 B Cooling Fins, 3 B Discharge Spokes, 4 C Second Inner Ring, M B Gold Spokes.
- **Retrofits:** Bigger Disk A (Corona Disk), Grounding Rods C (Stakes and Wire), Insulated Coils A (Ceramic Blocks).
- No notes.

**Round 2:** every stage is picked; the page shows only the picks.

### Drone Bay (second pass)

**Retrofit:** the Drone Bay has the one Retrofit, the Second Hangar (3,200), which launches the second drone (max 2).
It overlaps no path step. It gets three looks like every other Retrofit: twin pads, divided pads, or a bunker hatch.

**Round 1 (Claude):** one parametric model (base look A Rotor Pad Hangar, animation A Hunt and Circle). The bay is fixed and
only the drones move, so the paths change the DRONE:
- **Power:** the guns and tracer rounds change at each step (thicker, hot orange, a white core, a second line, gold at
  Elite Drones).
- **Weaponry:** each step unlocks a loadout (missiles, bombs, laser, the combined kit). The drone cycles through the
  unlocked loadouts every four seconds in the preview, and a selector dial on the bay's panel shows which is loaded.
- **Speed:** the rate of fire (3 up to 7 shots/s); the primary step turns the chin gun into a rotary that spins as it
  fires.
- **Two drones:** with the Retrofit a second drone launches from the second pad and takes a different target.
- Drones launch on the first enemy and never go home; with the lane clear they hover.

**Picks (owner, round 1):**
- **Power:** 1 A Heavy Chin Gun, 2 A Hot Barrel Shroud, 3 B Firmware Lamp, 4 A Frame Rails, M A Gold Frame.
- **Weaponry:** 1 A Wing Pods, 2 A Belly Bomb Rack, 3 A Laser Emitter, 4 B Reinforced Pylons, M C Gold Pylon Wings.
- **Speed:** 1 C Ready Lamp, 2 A Twin Belts, 3 A Three-Barrel Rotary, 4 A Overclock Chip, M A Gold Barrels.
- **Retrofit:** Second Hangar A (Twin Pads). No notes.

**Round 2:** every stage is picked; the page shows only the picks.

**Fix (owner: "the hot barrel shroud is a little oversized"):** the Hot Barrel Shroud is now the same width as the barrel it
wraps and a little shorter (it was about a third wider).

**Fix (owner: "the body of the drone is also on top of the propellers"):** the four rotors are now drawn last, above the arms,
body, gun and pods, instead of under the body.

**Fix (owner: "make the propeller blades thinner; they also protrude too far out"):** the blades are about half as thick, the
rotors are smaller (radius 2.05 px, was 2.6) and sit closer in on shorter arms (4.1 px, was 4.6).

### CAS Gunship (second pass)

**Its own upgrade system (owner):** every path is uncapped and upgrades one gun, so all three can be maxed: path 1 the light
gatling (built in), path 2 the medium autocannon (step 1 unlocks it), path 3 the heavy guided missiles (step 1 unlocks it).

**Retrofits:** Radar and Wide Orbit overlap no path step. **Extra Ammo** (+10% fire rate on every gun) overlaps the
fire-rate steps of all three paths; per the carpet rule it is kept and stacks.

**Round 1 (Claude):** one parametric model (base look A Airfield Beacon + Four-Engine Gunship, animation A Gatling Stream).
- **The plane carries the upgrades** (superseded by the notch rule below). All three guns are inside the fuselage.
- **Each gun fires at its own rate at its own enemy** under the orbit: gatling tracers (thicker, white-cored, a second line,
  gold), autocannon shells that burst on the target (25 px, 30 px at the battery), guided missiles that curve in with a
  smoke trail and burst (45 px; Hellfire fires two every third volley).
- **Wide Orbit** widens the orbit (115 px) as well as the wings; **Extra Ammo** speeds every gun by 10% on top of its path.
- **Ground station:** fixed, as in the base.

**Fix (owner: "the gunship propellers should be facing forward"):** each engine is now a nacelle on the wing with its propeller disc
in front of it, seen edge-on from above, instead of a rotor disc lying flat over the wing.

**Fix (owner: "make the propellers thinner"):** the propeller discs are about half as thick (a hairline core with a faint blur).

**Fix (owner: "make it look like the guns are inside the plane"):** the autocannon barrel and the missile racks no longer stick
out of the plane. Each gun now has only a port in the hull's inner edge, a hatch that slides open as it fires (the flash and
the shot leave the opening): the gatling's side door, an autocannon port aft of it and a missile bay by the wing root. The
upgrade options are the frames, panels and fairings round those ports (the red bezel for HE rounds, door rails for the quick
rack, gold frames for the masteries); the second autocannon and the Twin Gatlings add a second port.

**Fix (owner: "something is flickering on the plane"):** the gun hatches slid open and shut on every single shot, so the fast gatling
(5 to 9 rounds/s) made its door and port glow flicker. A hatch now stays open while its gun keeps firing and eases shut a
moment after the last shot (gatling 0.5 s, autocannon 0.4 s, missiles 0.7 s). The propeller blur also no longer changes
length from frame to frame.

**Fix (owner: "guns should be in the fuselage"):** the gun ports, hatches, panels and fairings were centred on the hull's edge, so
they hung half off the side. They now all sit inside the fuselage outline (the hatches a little in from the inner edge), and
the shots start inside the hull and emerge from under it.

**Tally rule (owner: "Upgrades are marked as notches on the plane. Path 1 is green notches, path 2 is red, path 3 is green.
Mastery changes them to gold", then "I mean just add a tally mark on the side of the fuselage"):** each CAS upgrade adds one
tally stroke, like a kill tally (now on the outer wing's midpoint, see the fix below). Path 1's strokes are green, path 2's red, path 3's green; a stroke only appears once its step is bought (no empty sockets). The mastery strikes
the four strokes through with a slash and turns all of that path's marks gold. The three options per stage are three stroke
styles (plain, bold, double). The old frame, panel and fairing details are gone. The guns stay inside the fuselage behind plain
hatches, with the autocannon port and the missile bay appearing at their first step; the masteries add a second gatling
door and a second autocannon port. Paths 1 and 3 are both green as written; they are told apart by their places on the
fuselage. If path 3 should be a different colour (blue, say), say so. The Retrofit parts moved so they don't cover the tallies.

**Fix (owner: "move the second autocannon to the other side of the plane"):** the Autocannon Battery's second port is now on the other
(outer) side of the fuselage, just aft of the wing, instead of beside the first; its shells leave from there.

**Fix (owner: "keep the gun-wells open with no slide. Missiles launch from under the wings. Also the light gun is sitting over the
wing"):**
- The gun wells are always open: a framed dark opening with no sliding door; it just glows while its gun is firing.
- The missiles launch from under the wing: two wells on the inner wing (gold-framed at Hellfire Volley), and the shots start
  under the wing, so the missiles emerge from beneath it. The fuselage missile bay is gone.
- The light gun's well moved forward of the wing, onto the nose (Twin Gatlings' second well is further forward still).

**Fix (owner: "shrink the gun wells, they're too big"):** all the gun wells are about half their old size (gatling 0.85 x 0.5 px, autocannon
0.8 x 0.5, missile wells 0.7 x 0.45 half-extents), with a thinner frame and a smaller firing glow.

**Fix (owner: "make all of the notches smaller"):** the tally strokes are about half as long (1 px), thinner, and set closer together (0.6 px
apart); the gold slash is smaller to match.

**Fix (owner: "put the tally marks on the midpoint of the wing; also the propellers look like they're not spinning"):**
- The tally marks now sit on the midpoint of the outer wing (half way from the fuselage to the tip, between the engines): one row
  per path across the wing's depth (path 1 at the leading edge, then path 2, then path 3), with the same colours, the gold slash
  and the three stroke styles. The Retrofit parts no longer need to dodge them.
- The propellers now visibly spin: each is a thin translucent disc seen nearly edge-on with two bright blade tips orbiting it,
  swinging fore and aft across the disc (a steady, smooth motion; the earlier random flicker stays out).

**Fix (owner: "remove the balls at the end of the propellers, and make them spin faster"):** the white dots on the blade tips are gone (the blades
and their trails remain) and the propellers spin about two and a half times faster.

**Picks (owner):** every path stage A (plain strokes); Retrofits Radar C (Rotodome), Extra Ammo A (Ammo Bay Box), Wide Orbit B
(Winglets). No notes.

**Round 2:** every stage is picked; the page shows only the picks.

**Fix (owner: "all weapons should mirror on both sides when fully upgraded; missiles shouldn't be visible over the wings; the tally marks
should go in the middle of the wing over the fuselage"):**
- **Mirrored weapons:** at each gun's mastery its well is mirrored on the other side of the plane, at the same place: the
  gatling's pair of wells forward of the wing (Twin Gatlings), the autocannon's pair aft of it (Autocannon Battery), and the
  missiles fly from both wings (Hellfire Volley). Shots alternate sides, and only the well that fires glows. This replaces the
  earlier second door and the second port beside the first.
- **Missiles:** the launchers are under the wings, so nothing is drawn on top of the wing any more (the two wing wells are gone);
  the missiles emerge from beneath the wing, because the plane is drawn over the shots.
- **Tally marks:** they sit in the middle of the wing where it crosses over the fuselage: one row per path across the wing's
  depth (path 1 at the leading edge, then 2, then 3).

**Fix (owner: "make the autocannon shells look like heavy bullets"):** the autocannon's shot is now a heavy bullet instead of a round ball: a fat
brass-cased body with a darker band, a pointed steel nose and a short hot streak behind it, turned along its flight (gold-cased at the
battery, with a red band from HE rounds).

**Fix (owner: "make them a little smaller, and make the missiles more missile shaped"):** the autocannon bullets are about a quarter smaller. The
missiles are now proper missiles: a white cylindrical body with a band, a pointed red nose cone (gold at Hellfire Volley), small
tail fins and an exhaust flame, turning along their curved path, with a thinner smoke trail so the missile reads clearly.

**Note (owner, round 2 paste):** "Don't make any visual changes for Extra ammo". The Extra Ammo Retrofit now draws nothing on the plane; its
+10% fire rate shows only in how fast every gun fires. (The ammo-box fairing is gone.)

**Notes (owner, round 3 paste):** "Heavy gun should be blue tallys"; "Make the radar scan line thinner. it also protrudes past the dish itself".
- Path 3 (the heavy gun's missiles) now uses **blue** tally marks (gold at its mastery, as before). Paths 1 and 2 stay green and red,
  so the three paths are now three different colours.
- The Radar's scan line is half as thick and no longer reaches past the edge of the dish.

**Fix (owner: "make the missiles a bit smaller"):** the missiles are about a quarter smaller, with their smoke trail scaled down to match.

### Mine Layer (second pass)

**Retrofits kept, stats stacking (the carpet rule).** All three overlap a path step; Claude flagged them and kept them:
- (Conveyor Feed was replaced on 2026-10-18, see below.) It was a mine every 1.33 s with a 25-mine cap, the same as Production step 1, Quick Assembly. The look took a further
  0.17 s off the toss gap and adds one to the cap on top of the path.
- Shaped Charges (+15 damage, 100) = Power step 1, Heavier Charge (100 damage). Every mine gets a directional plate or cone.
- Long Arm (+20 toss range, 140) = Range step 1, Longer Arm (140 px). The rails are lengthened by a further 3 px.

**Round 1 (Claude):** one parametric model (base look F Rail Launcher, animation C Confetti Charge).
- **Power changes the mine itself** (bigger canister, a shock ring on the blast, a dark yellow-banded HE mine, segmented
  casing and extra fragments, a big gold-rimmed anti-tank mine and gold confetti), as well as parts on the launcher.
- **Production** grows the magazine (a second column at Assembly Line, a third at Mine Factory) and adds presses, chutes,
  belts and lamps, with a faster toss and a bigger cap (the preview's cap is 6 growing to 12; the game's is 20 to 45).
- **Range** lengthens the rails and adds launch gear (springs, a mortar tube, rings, braces) and widens where mines land.
- Mines land at random spots along and across the track within range, blink while they wait, and go off under a ground enemy
  in a burst of confetti (gold at the mastery).

**Picks (owner, round 1):**
- **Power/Damage:** 1 B Heavy Rail Clamps, 2 B Wide Muzzle Bar, 3 A HE-Banded Canisters, 4 A Segmented Canisters, M A Gold Canisters.
- **Production Speed:** 1 C Counter Lamps, 2 none, 3 A Conveyor Belt, 4 A Servo Motors, M A Gold Belt.
- **Range:** 1 A Extension Rails, 2 A Coil Springs, 3 B Breech Block, 4 A Longer Tube, M C Gold Braces.
- **Retrofits:** Conveyor Feed B (Hopper Chute), Shaped Charges A (Plated Mines), Long Arm A (Long Arm Rails).
- **Notes:** "Wide blast should affect the mine, not the thrower." "Give different ideas for Quick Assembly. Twin Press should
  introduce a second rail. Assembly line should feed directly into the center. Servo Motors go on and speed up the rotunda."
  "Mine Mortar and Long Mortar should elongate to original tubes, not add extensions." "Rails are replaced with longer rails."
  And: "Don't add more mines behind the tower, only leave the 3 original."

**Round 2 (Claude):**
- **Magazine:** only the three original canisters sit behind the tower now (no extra columns).
- **Wider Charge** now changes the mine, not the thrower: a flange round each mine (the picked Wide Flange has tabs) and a shock
  ring on the blast; the thrower-side bar is gone.
- **Quick Assembly:** three new ideas (Mine Hopper, Charge Gauge, Loader Arm). **Twin Press** now adds a second rail (Side-by-Side,
  Angled or Underslung), and the tosses alternate between the rails.
- **Assembly Line** (and the other belts) now run in from the deck edge straight to the centre of the mount. **Servo Motors**
  sit on the mount's rim and spin its ring of ticks (the rotunda) much faster; the ring appears from the first Production
  step and speeds up with each.
- **Mine Mortar and Long Mortar** stretch the original rails instead of adding pieces; the **Long Arm** replaces the rails with
  longer ones (no cap piece).

**Picks (owner, round 2):** Quick Assembly C (Loader Arm) and Twin Press A (Side-by-Side Rail); the other picks are unchanged. No notes.

**Round 3:** every stage is picked; the page shows only the picks.

**Notes (owner, round 3 paste):** "The mines should alternate being thrown from each launcher. The launchers should be centered on the circle and
should be identical to each other. Make sure the central eye is large enough. The conveyer belt should feed directly to the launcher
in the center. The notching on the rotunda shouldn't appear until Rapid Line." "Remove the thickening part of the rails. Make them longer."
- **Launchers:** with Twin Press (Side-by-Side) there are now two identical launchers set symmetrically either side of the centre of
  the circle; the mines alternate between them and the one that fired glows. A single launcher is centred on the circle as before.
- **Central eye:** bigger (a 3.8 px hub with a larger glow, drawn above the rails).
- **Belt:** it now runs on over the mount and ends at the launcher in the centre (it used to vanish under the mount's edge).
- **Rotunda:** the notched ring of ticks only appears from Rapid Line (Production step 4) and spins faster with Servo Motors.
- **Rails:** the thickened end sections are gone and every Range step simply makes the rails longer (a further 5 px each time).

**Notes (owner, round 4 paste):** "The ending length is too long. Decrease the increments of length increase. Also make sure to add more bands to the
launcher as it gets longer."
- The rails now grow in small steps (1.5 px per Range step, 8 px at the mastery, 1.5 px more with the Long Arm), so the longest launcher
  is about 23 px, down from 37 px.
- The launcher carries a band every 6 px, so it gains a band as it lengthens (two bands at stock, four at the mastery).

**Notes (owner, round 4 paste):** "Remove the wide flange from the launcher. The visual effects should only be on the mine canister itself." Long Arm was
left unpicked (the length note repeated, and was already applied last round).
- The Wider Charge flange is now drawn only on the thrown mine (in flight and on the track). It no longer appears on the magazine canisters or on
  the mine waiting on the rails.
- Long Arm shows its three options again for a pick.

**Fix (owner: "keep the spacing and size of the rails for each launcher the same with the twin press"):** with the Side-by-Side Twin Press each launcher
now has exactly the single launcher's rails (the same size, the same 5.2 px spacing, the same bands); the two launchers sit 9 px apart,
symmetric about the centre, instead of the narrower pairs I used before.

**Retrofit replaced (owner, 2026-10-18: "we need to change conveyer feed to something else"; chose Adhesive Mines):** the Conveyor Feed did the Production
path's job and its belt now belongs to Assembly Line. The Mine Layer's first Retrofit is now **Adhesive Mines** (40): each mine's
blast leaves sticky gel on the track that slows enemies 20% for 2 s. It is in `tower_roster.md` and the regenerated trees. Its three looks:
a glossy gel coat with drips on every mine (A), a gel tank with a hose on the deck (B), a rack of gel cartridges (C); all three leave a green gel
puddle on the track after each blast (it lingers 2 s and fades). The Production path no longer gets a Retrofit bonus to its toss gap or cap.
Shaped Charges (A) and Long Arm (A) are picked.

**Note (owner, round 6 paste):** "Remove the wide flange. Let's change this upgrade." Wider Charge (Power step 2) now has three new looks, all on the mine
canister itself and inside its outline (nothing sticks out round it): a raised charge dome (A), a ring of steel charge studs (B) and two red
blast bands (C). The blast keeps its shock ring. The flange is gone everywhere. Adhesive Mines is picked (Gel Coating); Shaped Charges and
Long Arm are picked.

**Correction (owner, round 7): "Oh it's the thin clamps. Let's change that one instead."** The thing to change was **Heavier Charge** (Power step 1, the Heavy Rail Clamps), not
Wider Charge. So: the clamps (and the other step-1 parts on the launcher and mount) are gone; Heavier Charge has three new looks, all on the mine
canister itself and inside its outline: a thick dark rim (A), two steel weight plates (B) and a dark charge core (C); the mines are still a
size bigger. Wider Charge is back to your wide flange (B), shown only on the thrown mine, never on the launcher.

**Picks (owner, round 8):** Heavier Charge A (Thick Rim); the rest as before (Power 2 B Wide Flange, 3 A, 4 A, M A; Production C, A, A, A, A; Range A, A, B, A, C;
Retrofits Adhesive Mines A, Shaped Charges A, Long Arm A). No notes. **Round 9:** every stage is picked; the page shows only the picks.

### Chemical Plant (second pass)

**Retrofits kept, stats stacking (the carpet rule).** All three overlap a path step; Claude flagged them and kept them:
- Pressure Pump (a spray every 1.33 s, +20 range) overlaps the Speed path's spray rate (Quick Valve 1.25 s onward); the look takes a further 0.17 s off the gap.
- Mist Nozzle (each spray also soaks one more enemy beside the target) overlaps the Twin Nozzles mastery (two enemies at once); the extra enemy is misted too.
- Bigger Tanks (soaks last 5 s) = Speed step 2, Long-Lasting Mix (5 s); the look adds one second on top.

**Round 1 (Claude):** one parametric model (base look F Distillery Columns, animation A Acid Stream).
- **Damage/Armor stripping:** the spray itself changes at every step (bigger drops, a yellower mix, a brighter mix, a dark bubbling mix, gold at the
  Dissolver) and a soaked enemy sheds flakes of armour and fizzes more; the columns and the deck gain the matching parts.
- **Speed:** valves, pumps and gauges on the still and nozzle pipe; the Twin Nozzles mastery adds a second gold nozzle that sprays two enemies at once
  (three ways: parallel, fanned or forked).
- **Slowing:** a gel coat on soaked enemies that gets thicker and drippier with each step; gel pipes, pumps, tanks and, at the mastery, gold foam gear.
- The plant sprays one unsoaked enemy at a time and the soak lasts 4 s growing to 8 s with the Speed path and Bigger Tanks.

**Picks (owner, round 1):** Damage/Armor stripping 1 B (Scrap Bin), 2 C (Etch Rings), 3 C (Reaction Lamps), 4 A (Concentrate Press), M C (Gold Core). Speed,
Slowing and the Retrofits were unpicked. **Notes:** "Remove that gold dot" (the gold disc beside the columns at the Dissolver). And: "Change the upgrade
designs to change the structure more than add little things here and there."

**Round 2 (Claude):**
- The gold dot is gone (the Dissolver's Gold Core is now only the gold ring on the still).
- **A new design rule for the Chemical Plant: upgrades rebuild the structure.** Speed, Slowing and the three Retrofits were redrawn that way (the Acid picks
  keep their parts, as you picked them): a bigger still, thick direct feed pipes or a short wide neck (Quick Valve); taller columns, a fourth column or a ring
  main (Long-Lasting Mix); a split feed pipe, twin stills or a valve manifold ring (Twin Valves); a pump hall, a double ring main or a pipe network
  (High-Flow Pump); gel columns, a gel ring main or annex (Sticky Gel, Thick Gel); a glue cauldron hall, tower or stack replacing a column (Glue); a curing hood,
  cooling tower or cooling coil (Setting Glue); a gold foam dome, cannon or silo (Quick-Set Foam). The Retrofits likewise: a pump house, tower or skid; a fan
  head, mist manifold or ring head; larger, extra or double-height columns.

**Picks (owner, round 2):** Speed 1 B (Direct Feed), 2 C (Ring Main), 3 B (Twin Stills), 4 none, M B; Slowing 1 B (Gel Ring Main), 2 A, 3 B, 4 C (Cooling Coil), M A (Gold Foam Dome);
Retrofits Pressure Pump A, Mist Nozzle A (Fan Head), Bigger Tanks A (Larger Columns). **Notes:** "Twin Nozzles should have two independent sprayers." "Make any column
changes apply to all columns." "Change the pump house design."

**Round 3 (Claude):**
- **Twin Nozzles are two independent sprayers:** each has its own pipe and head (and its own hub in the Twin Turrets look) and turns to its own enemy, so two
  different enemies are sprayed at the same time. The second sprayer follows the first when only one enemy is in reach.
- **Column changes apply to all columns:** the gel columns (Sticky Gel, Thick Gel's gel coat), the glue halls, towers and stacks (Glue) and the gold foam silos
  (Quick-Set Foam) are now on every column, not just one. (Sticky Gel A is now "Gel Columns" and Thick Gel A "Gel-Coated Columns".)
- **A new Pump House:** a roofed building on the deck beside the plant, with a flywheel that spins up as it sprays and a chimney that puffs, piped
  into the still (it was a box beside the still).
- **High-Flow Pump** (Speed step 4) was left unpicked, so its three options show again.

**Notes (owner, round 3 paste):** "The Twin turret looks strange with the twin valves." High-Flow Pump A (the Pump Hall) is now picked.
- With Twin Valves B (twin stills) the two independent sprayers grow from the two stills, one each (a gold ring marks each), instead of from hubs between them, so
  nothing fights the stills. The Pump Hall (High-Flow Pump A) becomes the base plate under both stills with a piston for each.

**Notes (owner, round 4 paste):** "No change is visible on T2. Each nozzle for the Twin Nozzles should sit on a stationary still." "Change or reduce the effect of T2. Cooling ring should
sit under the nozzle and silos." "The mist nozzle design is too crude."
- **Speed T2 (Long-Lasting Mix, Ring Main):** the ring main was hidden behind the columns; it is now a visible ring just outside them with a spoke from every column and
  bolts (the gel ring main sits just inside it).
- **Twin Nozzles:** each sprayer sits on a stationary still; the twin stills (and the Pump Hall under them) no longer turn with the aim, only the sprayers turn on top.
- **Slowing T2 (Thick Gel):** reduced to a thin, pale gel coat on the columns (it was a thick bright ring).
- **Slowing T4 (Cooling Coil):** drawn under the columns and silos and under the nozzle, not over them.
- **Mist Nozzle (Fan Head):** redesigned as a flared, ribbed metal head with a perforated face and a fine mist plume when it sprays (it was a flat triangle).

**Note (owner, round 5 paste):** "drop the ring pipe below the tower frame." I read this as layering: the ring pipes (the Speed ring main, the gel ring main) were
lying over the deck's armoured frame at the flats, so the frame (its band, trim and corner bolts) is now drawn over them and the pipes run under it. If you meant
something else by "tower frame" (the columns, say), tell me.

**Notes (owner):** "The mist nozzle does not sit properly on the ends of the sprayers. Also the stills are too blocky for the mastery."
- The Mist Nozzle's ribbed head now sits on the end of every sprayer (both sprayers at the Twin Nozzles mastery), pointing the way each one points, instead of
  floating off the first nozzle.
- The stills are rounder: the twin stills stand on a capsule-shaped base (it was a square plate), and a single pump hall is an octagon.

### Boost Tower (second pass)

**Retrofits kept, stats stacking (the carpet rule).** Signal Booster (radius 168 px and +5% to all three boosts) overlaps the paths' boost steps; it is kept and the +5% stacks on top.
Crit Link and Wide Mast overlap no path step (Wide Mast widens the radius only; no path does).

**Round 1 (Claude):** one parametric model (base look F Signal Drum, animation F Overcharge Sparks), built with the owner's Chemical Plant note in mind (upgrades change structure).
- **Each path owns a disc-shaped emitter module on the drum's top** (damage orange at 90 degrees, speed cyan at 210, range lime at 330). *Round 1b (owner: "have the circles fade more and more into gold with each
  upgrade rather than change size/add more rings"):* the disc keeps its size and gains no rings; every step fades its colour a step further toward gold (pure gold at the mastery), and the last step's
  option is the disc's style (glossy, ringed or six-petalled). The first version built tiers onto the module and grew it; that is gone.
- **Boosted towers** show a stack of chevrons for each stat (orange, cyan, lime): one each at stock, more with each path level, gold at the mastery.
- **Retrofits rebuild the tower:** Signal Booster an antenna mast, a loop antenna or a spire at the centre (and a wider faint radius ring); Crit Link a gold ring, collar or crown (and a gold crit spark
  by each boosted tower); Wide Mast a lattice frame, braced truss legs or a spoked ring (the widest radius ring).
- The faint boost radius ring and the sparks that jump to each boosted tower in turn are in the preview.

**Picks (owner):** every path stage B (Ringed Disc); Retrofits Signal Booster C (Spire), Crit Link C (Gold Crown), Wide Mast C (Spoked Ring). No notes. **Round 2:** every stage is picked; the page shows only the picks.

### Radar Tower (second pass)

Base: look A Dish Mast, animation B Sweep Beam (the sweep follows the dish). Every step rebuilds a part of the station; the agent runs the real rules, so the preview shows the ping rate, reveal time, range and the radiation circle.
- **Path 1, Power/Range (the centre):** 1 a bigger dish (solid, ribbed or mesh), 2 a mast under it (guyed lattice, tripod, tiered tower), 3 a radiation emitter at the focus with a faint red inner circle, 4 heat sinks, capacitors or arc pylons with a wider circle, M a gold dish plus a horn ring, twin gold dish or gold lattice array, with a gold circle.
- **Path 2, Speed/Frequency (the edges):** a phased-array panel on the south, north, east, west edge (tile, curved or louvre), and the dish turns at the ping rate; M turns them gold with a steady gold field (constant reveal).
- **Path 3, Unmasking (the corners):** a cabinet in the NW, NE, SE, SW corner (each a different gadget). The marks on revealed enemies grow: rank tag, unmask diamond, track-lock tether, fake-check badge, gold lock that lingers 5 s.
- **Retrofits:** Bigger Dish (rim, flared ends or sub-reflector), Signal Processor (chip ring, fan box or chip stack), Early Warning (beacon mast, lookout tower or strobe pylons).
- **Carpet-rule overlaps (kept, stacking):** Bigger Dish's +20 px stacks with the path-1 range steps; the Signal Processor's 1.5 s reveal stacks with the path-2 and path-3 reveal steps.
- The radiation circle only hurts revealed enemies (owner); in the preview a revealed or uncloaked enemy inside it glows red.

**Picks (owner, round 1):** Path 1: 1 A Solid Dish, 2 C Tiered Tower, 3 C Twin Prong Emitter, 4 B Capacitor Bank, M B Twin Gold Dish. Path 2: 1-4 B Curved Array, M A Gold Cable Ring. Path 3: none picked. Retrofits: Bigger Dish C Sub-Reflector, Signal Processor none, Early Warning B Lookout Tower.
**Note (owner):** "Give some more redesign ideas rather than trickle additions" (Path 3).
**Round 2:** Path 3 is redesigned: instead of a new cabinet per step, all four corner stations are rebuilt to a new design at every step (racks/consoles/posts, then decoder towers/dish pods/yagi masts, then tracking turrets/radar domes/eye pylons, then prism arrays/lens rings/filter gates, then gold citadels/lighthouses/obelisks). The mark on a revealed enemy now changes style per step (brackets and rank tag, diamond, lock ring and tether, hex frame and check badge, gold lock rings) rather than gaining extras. The Signal Processor shows its three options again.

**Picks (owner, round 2):** Path 3: 1 B Scope Consoles, 2 A Decoder Towers, 3 A Tracking Turrets, 4 B Lens Rings, M none. Retrofits: Signal Processor A Chip Ring. **Note:** "keep the tracking turret idea for T4 > M".
**Round 3:** the tracking turret (it turns to follow revealed enemies) stays from Track Lock through the mastery. Illusion Filter builds a lens ring round it; Total Exposure shows three gold turret builds (gold citadel and wall, lighthouse lamp, obelisk base with a twin barrel), still to pick.

**Round 4 (owner notes):** "Shrink the turrets down a bit and remove the squares from underneath them. Only change the blue on them to gold for the mastery". The tracking turrets are smaller, nothing sits under them (no citadel plate, base disc or obelisk), and at the mastery only the blue accents (glow, tether, lens ring) turn gold; the body stays metal. The three mastery options are now a gold wall joining the four turrets, a sweeping gold lamp, or a twin barrel.

**Round 5 (owner notes):** "Shrink them a bit more so they fit cleanly on the tower, and make the radar dish thinner". The turrets (and lens rings, shields, barrels) are smaller and the corner slots are pulled in so they sit inside the deck; every dish stroke is thinner (outline and body).

**Round 6 (owner notes):** "Make it look like the dishes are connected to the center mast. Make the emitter prongs look like one solid V rather than two struts laying overtop of each other. Move the double radar idea for the Mastery for Path 2". Three struts now join each dish to the centre mast; the Twin Prong Emitter is one solid V; the double radar (a second gold dish opposite the first, on its own struts) is now part of the Path 2 mastery, Constant Track (picked A, Gold Cable Ring). So Path 1's mastery shows its three options again (A Horn Ring, B Gold Feed Tripod replacing the twin dish, C Gold Lattice Array).

**Picks (owner, round 6):** Path 1 mastery A Horn Ring; Path 3 mastery B Gold Lamp (all other picks unchanged).
**Round 7 (owner notes):** Path 2 mastery: the ring is grey; both dishes and the emitter are gold; both dishes have a scan line; the array bodies are grey with gold lights. Path 3: "remove the light cones from the trackers": the turret-to-enemy lines and the lamp beam are gone, and the Gold Lamp is now a pulsing gold lamp on each turret. Every stage is picked; the page shows only the picks.

**Round 8 (owner notes):** "Keep the spars holding the dishes, and the antennae grey. The bodies for the curved arrays are still gold. The second antenna light is not gold". The spars and the antenna (feed) arms are grey on both dishes (only the dishes are gold); the curved arrays now show small gold lamps on a grey body (the big lamp halos read as a gold body); the second dish's light is drawn on top of everything, in gold.

**Round 9 (owner notes):** "The second light is still not gold. Also, make the scan lines come from the antenna light instead of the center of the tower". With Constant Track, both antenna lights are gold (the first dish's light stayed teal when no emitter was fitted, which is what showed as not gold), and each dish's scan line starts at its antenna light and runs out to the range.

**Round 10 (owner notes):** "I mean all scan lines in general. The scan lines are also not centered". Every scan line (the normal sweep as well as Constant Track's) now starts at the antenna light. The sweep beam used to trail behind its line (the line sat on the beam's edge); it is now a beam centred on the line, brightest in the middle, and an enemy is revealed as the line passes over its middle.

**Round 11 (owner notes):** "I mean the bright laser line is not centered evenly. Revert the changes with the scanlines". The scan-line changes of rounds 9 and 10 are reverted: the scan lines and the sweep beam start at the centre of the tower again, with the beam trailing behind its line, as in round 8. The gold antenna lights from round 9 stay.

**Round 12 (owner screenshot):** the bright laser line sat off to one side of the dish's middle strut. Cause: the engine draws the tower model first and the scan-line agent after it in the same frame, and the agent advanced the dish angle before drawing, so the line was drawn one frame ahead of the dish (a few degrees at full speed, a lot more when the page runs slowly, such as over Remote Desktop). The agent now draws the line and beam at the angle the dish was drawn at, so the line runs down the dish's middle strut.

**Round 13 (owner screenshot and note):** "The tracking lines from the tracker turrets should come from the tracker antennae". The tether lines that ran from the centre of the tower to revealed enemies (lock-ring marks, steps 3 to mastery) are gone. Each revealed enemy is now tracked by one turret (the nearest one) and a thin tracking line runs from that turret's antenna tip to the enemy (so there are no converging cones, which was the round 7 note). The line is gold at the mastery.

**Round 14 (owner note):** "Make the tracker turrets not rotate but track enemies freely". The tracker turrets no longer spin while idle: they rest pointing outward from their corner, and swing freely (through any angle, smoothly) to the revealed enemy they follow, then return to rest when nothing is revealed.

**Round 15 (owner note):** "They can rotate, but they dont spin like the main dish. They're free moving. They dont reset position after a target lock is lost, they sit until another enemy comes in range". The tracker turrets turn freely to follow a revealed enemy (no spinning, no idle sweep), and when the lock is lost they stay at their last aim until another enemy is revealed in range. They start pointing outward from their corner.

### Cryo Tower (second pass)

Base: look B Compressor Block, animation C Creeping Mist. Every step rebuilds a part (the new design replaces the old one in all four places at once); the agent runs the real rules (wave rate, range, slow strength, permanent chill, the 4th-wave freeze, frostbite).
- **Path 1, Slowing (the corners):** four stations (banded tanks, frosted vaults or crystal clusters) rebuilt bigger and colder at each step; Permafrost keeps a faint frost ring on chilled enemies outside the range; Deep Freeze (mastery) adds gold and freezes enemies in an ice block on every 4th wave.
- **Path 2, Power/Range (the edges):** a frost rim on the middle of each edge (spike rows, fans or ice crystals) rebuilt longer and denser each step, gold-tipped at Blizzard; the range ring widens; hit enemies shed ice shards (frostbite).
- **Path 3, Speed (the middle):** the big fan is rebuilt (swept turbine, ducted shroud or nozzle ring) with more blades and a faster wave; Cold Front (mastery) is gold with a constant gold-white field.
- **Retrofits:** Coolant Tank (side tank, twin tanks or sphere, left), Compressor (box, pistons or scroll, right), Deep Cold (white vents, domes or louvres, bottom).
- **Carpet-rule overlaps (kept, stacking):** the Compressor's 1.7 s wave stacks with the path-3 wave rate; Deep Cold's +5% slow stacks with the path-1 slows; the Coolant Tank's longer slow stacks with the permanent chill.
- **Lessons carried from the Radar Tower:** the new design replaces the old one rather than adding extras; masteries are gold on trim and lights; per-frame draw order (the model runs before the agent) is not relied on.

**Picks (owner, round 1):** Path 1: none (needs more ideas). Path 2: every step and the mastery C (Ice Crystals line: Ice Nubs, Ice Crystals, Crystal Banks, Crystal Crowns, Gold-Studded Crowns). Path 3: every step and the mastery A (Swept Fan, Gold Turbine). Retrofits: Coolant Tank C Spherical Tank, Compressor none (needs more ideas), Deep Cold A Vent Row. **Notes:** "I need some more ideas for these" (Path 1); "For Coolant tank, the central box becomes circular. More ideas for Compressor".
**Round 2:** Path 1 shows all-new corner stations: coils, snow guns and flasks (step 1); pumps, nitrogen dewars and heat exchangers (2); ice-core pylons, frozen domes and drills (3); cryo reactors, cold beacons and rime generators (4); gold-core reactors, gold-ringed beacons and gold-edged obelisks (mastery). The Coolant Tank (spherical) now makes the central housing circular. The Compressor shows new ideas: a humming drum with rings, a belt drive and a radial compressor (impeller in a snail casing).

**Picks (owner, round 2):** Path 1: 1 A Cooling Coils, 2 A Cryo Pumps, 3 C Permafrost Drills, 4 A Cryo Reactors, M A Gold-Core Reactors. Path 2: all C. Path 3: all A. Retrofits: Coolant Tank C, Compressor C Radial Compressor, Deep Cold A. **Note:** "Shrink the gold core reactors".
**Round 3:** every stage is picked; the page shows only the picks. The gold-core reactors are about a third smaller (smaller than the step 4 reactors).

**Round 4 (owner notes):** "With the Coolant Tank retrofit, make sure the ice spines sit around the circular tank instead of floating"; "Keep only the fan blades gold for the mastery"; "Remove the external tank from Coolant Tank". The Coolant Tank (option C, now called Round Housing) is only the circular central housing, with no external tank; the Path 2 ice spines sit on the housing's circular rim, pointing radially, instead of on a straight edge. At the Path 3 mastery only the fan blades are gold; the fan ring, hub, light and the mist stay ice-coloured.

**Round 5 (owner notes):** "Make the central light gold too" (Path 3 mastery: the blades and the central light are gold); "Lets look for different ideas for Deep Cold". Deep Cold now shows three new ideas: a white rime coat on the housing rim, two vapour stacks on the bottom edge, or a frost collar with inward fins round the fan. Everything else stays as picked.

### Shockwave Generator (second pass)

Base: look B Ring Reactor, animation B Mushroom Pulse. Every step rebuilds a part (the new design replaces the old one); the agent runs the real rules (wave rate, radius, damage, barrier shatter).
- **Path 1, Power/Range (the core inside the ring):** rods, a plasma sphere or spinning rings, rebuilt bigger, denser and whiter at each step; the Megaton Wave (mastery) turns the core, the waves and the ring gold.
- **Path 2, Speed (outside the ring):** pulsing emitters (coils, dishes or spike-and-ball), two, four, six, eight, then twelve gold ones; the wave comes faster.
- **Path 3, Effect (on the ring):** three violet resonance stations between the clamps (forks, ripple plates or spires) rebuilt at each step; barrier enemies (every third preview enemy) show a blue barrier that the waves chew through faster per step, and Shatter Shock (gold) halves it on every hit and stops it regrowing for 5 s.
- **Retrofits:** Wave Focus (focus ring, lens array or focus collar round the core), Containment Coils (glowing coils, coil cage or toroids round the core), Reactor Venting (stacks, louvres or blast vents at the corners).
- **Carpet-rule overlaps (kept, stacking):** Wave Focus's +15 px with the path-1 radius; Containment Coils' +10 damage with the path-1 damage; Reactor Venting's 1.5 s wave with the path-2 wave rate.

**Picks (owner, round 1):** Path 1: 1 A Fuel Rods, 2 B Dense Sphere, 3 B Corona Sphere, 4 C Gyro Rings, M C Gyro Rings (white-hot). Path 2 and 3: none ("Change the idea for these. Visual changes rather than adding little things"). Retrofits: Wave Focus none, Containment Coils none, Reactor Venting C. **Notes:** "Dont make these ones gold, make them brigter" (Path 1); "For Reactor Venting, merge option A and C. Have smoke bellow out each burst".
**Round 2:** Path 1 is white-hot (a bloom) at the mastery instead of gold, as are the waves and the ring glow. Path 2 (Speed) now rebuilds the containment ring itself: turning segments, a flywheel or a turbine that spins faster at each step (gold at the mastery). Path 3 (Effect) now rebuilds the three clamps as big violet resonators (tuning forks, ripple drums or crystals) that grow at each step (gold at the mastery). Reactor Venting C merges the stacks and the blast vents, and grey smoke billows out of each corner with every burst. Wave Focus and Containment Coils show their three options again. The owner's "not gold" note was for Path 1 only; the other masteries stay gold.

**Picks (owner, round 2):** Path 1: 1 A, 2 B, 3 B, 4 C, M C. Path 2: every step and the mastery C (Turbine Ring). Path 3: none. Retrofits: Wave Focus C Focus Collar, Containment Coils C Toroid Coils, Reactor Venting C. **Notes:** "Move all paths the gyro rings" (Path 1); "Move a completely different design direction. modify the tower" (Path 3); "Increase the force of the smoke releasing and give the particles a lifetime, rather than tying them to the animation cycle".
**Round 3:** Path 1 uses the gyro rings at every step (my reading of the unclear Path 1 note; to be confirmed by the owner). Path 2 is the Turbine Ring throughout. Path 3 is a new direction that modifies the tower itself: a violet cage (posts and bars, then bracing, humming strings and corner breaker wedges), a shield dome (ribs, a pulsing ring, fracture lines) or a halo of prism spikes (more and longer at each step), built round the ring; gold at the mastery. The Reactor Venting smoke is a real particle system in the agent: 9 puffs per corner per burst, thrown out hard and slowing with drag, each living 2.4 to 3.6 s on its own clock.

**Picks (owner, round 3):** Path 1 all C (gyro rings; confirms the round 3 reading), Path 2 all C, Path 3 none, Retrofits all C. **Notes:** "Make each upgrade make a bigger cloud bellow. Give it lifetime instead of tying it to the animation" (Path 1); "Nope, different ideas. Give me more selections to choose from as well" (Path 3); "Make the smoke puff out farther" (Reactor Venting).
**Round 4:** the mushroom cloud is now a particle system with its own lifetimes (2.4 to 3.6 s per puff, a hot start fading to smoke grey) and it grows with every Power step (8 + 4 per step puffs, 28% bigger per step). The Reactor Venting smoke is thrown about twice as far. Path 3 shows five all-new directions (five options per step instead of three): heavy hammers on arms that strike the ring, sonic horns that push out sound arcs, a fractured ring with glowing cracks, a starburst of tuning rods, and a turning prism lens over the core. Each grows at every step and is gold at the mastery.

**Picks (owner, round 4):** Path 1 all C, Path 2 all C, Path 3 none, Retrofits all C. **Notes:** "Make larger bursts at one time, not a longer generation period" (Path 1); "Scrap these designs. start fresh. Design something that would make the tower itself cause resonance without adding things to it" (Path 3).
**Round 5:** the Power cloud leaves in one larger burst: every puff starts at the same moment (it used to be spread over 0.3 s) and only the count and the size grow. Path 3 starts fresh with nothing added to the tower: the tower's own parts resonate. Five ways, each harder at every step and gold at the mastery: the ring's edges ripple in a standing wave (3 to 6 lobes), the deck hums with ripples rolling across it, the ring sings with bright lobes travelling round it, the whole tower shakes (with echoes of the ring), or the ring turns to violet glass with light running round it.

**Picks (owner, round 5):** Path 1, Path 2 and the Retrofits all C; Path 3 every step and the mastery A (the rippling ring). **Notes:** "Add a nuclear explosion effect to the bellowing for Megaton Wave" (Path 1); Path 3 spec: one white band: T1 faint with a subtle ripple, bursts bend it a little; T2 slightly brighter, slightly stronger ripple, bursts bend and stretch it more; T3 brighter, stronger ripple, bursts bend and stretch it more; T4 bright, a slightly sporadic ripple, bursts bend and stretch it a lot more; M gold, strong and sporadic ripple, bursts stretch and bend it massively.
**Round 6:** every stage is picked; the page shows only the picks. Path 3 now follows the spec to the letter: one band (white, gold at the mastery) whose brightness, ripple and burst response grow per step, with a sporadic ripple from T4. The Megaton Wave burst adds a nuclear explosion to the billow: a white flash, an incandescent fireball that cools to smoke, a stem and a rolling mushroom cap.

**Round 7 (owner notes):** "Keep the band a thin line. ripple effects should stay gentle and smooth. Sporadic should introduce chaos into the ripple effect. Make the stretch effect stronger and more elastic". The Path 3 band is a thin line (about 1 px, with only a faint halo); the ripple is two gentle, smooth sine lobes; the sporadic steps (T4 slightly, the mastery strongly) add chaos by mixing five harmonics that drift independently; and every burst stretches and bends the band harder (about 1.5 times the old strength), elastically: it overshoots and rings back like a spring over about a second.

**Round 8 (owner note):** "The bands should expand on a blast". On every blast the Path 3 band expands outward with the wave (quickly, over about 0.3 s, by 2.5 px at the first step up to 12 px at the mastery), then springs back and rings, overshooting; the bend and stretch distortions from round 7 stay.

**Round 9 (owner note):** "Make the elasticity stronger, so the bands reciprocate faster". The Path 3 band now opens in under 0.2 s and then swings in and out about 2.3 times faster (a spring of about 3.3 swings a second instead of 1.4) with less than half the damping, so it reciprocates several times before settling; the expansion (3 to 14 px) and the bend are stronger too.

### Scrapyard (third restart: a tower of three parts)

**History.** Three Scrapyard designs have been rejected: (1) the Magnet Yard base with its first upgrade designs; (2) a from-scratch Smelting Works ("didn't like the overall design"); (3) the Armoured Vault Depot, whose base look was confirmed (with the Sparks and Sale animation) before its second-pass round 1, after which the owner said "Scrap the scrapyard design and start all over again". Its files (`data_scrap_looks.js`, `data_p2_scrap.js`, the p2 page) are deleted; git keeps them. The `sBuild`/`sCard` preview-scale hook in `pass2_engine.js` stays for the 2x2 second pass.

**What went wrong (owner):** the upgrades were too subtle, and the upgrade names mix themes (banking words such as Vault Doors, Treasury Link and Reserve Bank next to machinery such as Smelter and Freight Rail).

**The new brief (owner, 2026-10-19):**
- **Everything restarts, base look included;** the 2x2 footprint stays.
- **The tower is three parts:** a recycler/smelter, a junkyard and a warehouse.
- **Each path builds up one part:** Passive Income the smelter (it melts scrap into ingots sold each round), Kill Income the junkyard (it hauls in wrecks from kills), Discounts the warehouse (it sells salvaged parts cheap to nearby towers). Every step rebuilds its own part, visibly.
- **The smelter is a tall furnace stack** seen from above: the tallest part and the focal point, with a glowing core and intake chutes.
- **The three base looks** are the same three parts in three layouts; three animations are offered separately.
- **Order:** the base look first. Then Claude proposes one scrap-business vocabulary for all 15 upgrade names and the 3 Retrofits (each naming the part its step rebuilds; the effects and numbers stay as confirmed) for the owner to confirm in `design/upgrade_trees_rework.md` and `design/tower_roster.md`; then the second pass.

**The page** (`design/tower_art_p17_scrapyard.html`, from `tools/tower_art/data_scrap_parts.js`):
- **A. Central Stack:** the furnace stack in the middle, fed by two chutes from the junkyard that wraps the left and bottom edges (heaps, a tank hulk, a grab crane); a long warehouse down the right side, its roll-up doors facing the stack.
- **B. Production Line:** left to right, the junkyard feeds a conveyor up into the stack, and a short ingot belt runs from the stack into a tall warehouse on the right.
- **C. Yard Corner:** the warehouse along the top edge, doors facing down; the stack in the top-left corner, fed by chutes from the open junkyard that fills the bottom-right (a big grab crane).
- **Animations (pick one):** Scrap Flow (scrap arcs from the junkyard into the stack and ingots slide to the warehouse; at the payout the doors roll up and a crate ships out with +100), Melt and Pour (embers rise from the stack; at the payout its core flares and a fountain of coins vents with +100), Wreck to Coin (also shows the kill bonus: a wrecked enemy's hulk flies into the junkyard and a +5 coin jumps out of the stack; +100 over the warehouse at the payout).
- In every look the stack flares and the warehouse doors roll up at each payout.

**Round 2 (owner's picks, 2026-10-19):** look **B Production Line**, animation **B Melt and Pour**. Note: "Make sure the crane bar is over top of the smelter": the grab crane is now drawn after the stack, so its arm and claw pass over the smelter when it swings across. The page shows only the picks.

**Round 3 (owner's note):** "Move the crane to where it can move scrap to the conveyer belt where it can be fall off the conveyer belt into the furnace". The crane now stands between the big heap and the foot of the belt, in a 3.2 s cycle: it grabs a piece of scrap from the heap, swings it over and drops it on the belt; the piece rides up the belt and falls off the top end into the furnace mouth, glowing as it drops, with a flare. The belt now runs straight at the stack and is drawn over its rim; the tank hulk moved to the bottom-left corner, clear of the belt. The pieces are drawn from the time alone, so the crane and the belt always agree.

**Confirmed (owner, 2026-10-19, "Finished"):** look B Production Line (with the round 3 crane, belt and furnace feed), animation B Melt and Pour.

### Scrapyard (second pass on the Production Line)

**New names (owner, 2026-10-19).** The owner picked one machine vocabulary: each step names the machine built into its part. The Salvage Crane Retrofit is renamed the **Weighbridge**. Effects and prices are unchanged. The names are in `design/tower_roster.md`, and the rework trees are regenerated.

| Path (part) | 1 | 2 | 3 (primary) | 4 | Mastery |
|---|---|---|---|---|---|
| Passive Income (furnace stack) | Firebrick Lining | Forced Bellows | Blast Furnace | Arc Furnace | Gold Foundry |
| Kill Income (junkyard) | Tow Hook | Magnet Crane | Laser Cutter (round 3; was Sorting Line, before that Hydraulic Shear) | Car Crusher | Breaker's Yard |
| Discounts (warehouse) | Parts Shelves | Pallet Racks | Forklift Bay | Loading Dock | Parts Exchange |

**The page** (`design/tower_art_p2_17_scrap.html`, data `tools/tower_art/data_p2_scrap.js` on the base `data_scrap_parts.js`). Each path rebuilds one part around the machine its step names. Earlier picks carry as details, and masteries are gold. The agent runs the real rules: the payout with the real income, the kill ring, and the discount ring with the percentage off.
- **Furnace stack (Passive Income).** The stack grows a little each step.
  - Firebrick Lining: a glowing firebrick shell, hex refractory tiles, or a double wall with glowing slits.
  - Forced Bellows: twin bellows, a side blower, or a bustle-pipe ring.
  - Blast Furnace: rebuilt taller, with hot-blast stoves, a skip hoist and charging bell, or a steel frame and downcomer.
  - Arc Furnace: the top is rebuilt as a domed electrode lid (the scrap drops in through a charging hole), a tilting vessel under electrode arms, or a plasma ring.
  - Gold Foundry: the stack turns gold, and the ingots on the ingot belt turn gold. The options add glints round the rim, a gold casting wheel, or a gold ladle. Each payout adds a +3% tag.
- **Junkyard (Kill Income).**
  - Tow Hook: a tow truck, a winch post, or a chain gantry hauls in the wreck.
  - Magnet Crane: the grab crane is rebuilt with an electromagnet, as a twin-boom magnet crane, or as an overhead bridge magnet.
  - Hydraulic Shear: an alligator shear, a guillotine shear, or shear jaws on the crane.
  - Car Crusher: a flat press over the wreck, a baler that packs the scrap into cubes, or crushing rollers across the belt.
  - Breaker's Yard: the machines turn gold and a gold x2 sign marks the bosses. The options add a glowing magnet, gold heaps, or a gold fence. The field coins turn gold.
- **Warehouse (Discounts).** From step 1 the warehouse is rebuilt shorter, with a yard at its end.
  - Parts Shelves: half the roof off over the shelves, a shelf lean-to, or a parts cage.
  - Pallet Racks: high-bay racks under an open roof, pallet stacks outside, or a stacker crane.
  - Forklift Bay: a forklift run, a charging bay, or automated carts.
  - Loading Dock: a truck dock, a rail siding, or twin ramps.
  - Parts Exchange: the frame turns gold. The options add a gold roof, gold stock, or a gold fleet.
- **Retrofits:**
  - Second Crusher: a jaw crusher, a roller crusher or a hammer mill, with a chute onto the belt.
  - Bigger Yard: a chain-link fence, a concrete wall, or scrap ground round the slab.
  - Weighbridge: a truck scale with a readout, a dial scale, or a weigh hut with a barrier arm, below the yard.
- **Carpet-rule overlaps (kept, stacking):** the Second Crusher's +30 income stacks with the Passive Income steps, and the Bigger Yard's +30 px stacks with both field radii.

**Round 2 (owner's picks and notes, 2026-10-19):**
- **Picks:** Passive Income 1 A, 2 B, 3 A, 4 C, M A (glowing firebrick, side blower, hot-blast stoves, plasma ring, gold shell); Kill Income 1 A, 2 C, 4 A, M A (tow truck, bridge magnet, flat press, gold crane); Discounts 1 A, 2 C, 3 A, 4 C, M C (open-roof shelves, stacker crane, forklift run, twin ramps, gold fleet); Retrofit Hammer Mill.
- **Renames (owner's notes; effects unchanged, in `design/tower_roster.md` and the regenerated trees):**
  - Kill Income step 3: Hydraulic Shear becomes **Sorting Line** (the owner chose it from three names).
  - Second Crusher becomes **Hammer Mill** (+30 income).
  - Bigger Yard becomes **Faster Loading** (+30 px to both fields). It now shows a second conveyor and a second crane, which feed the furnace from the top heap, taking turns with the main line.
  - Weighbridge becomes **Surplus** (towers sold in its field refund 15% more). It now shows two extra crates.
- **Open again, with new ideas:**
  - Sorting Line: on the main belt, sorting scrap into three bins beside it. The options are a picking gantry with an arm, a turning drum magnet, or a shaking sorting screen.
  - Faster Loading: the second line's crane is a grab crane, a magnet crane, or an overhead bridge magnet.
  - Surplus: the two extra crates are a bigger stack, a pallet of crates, or crates tagged for sale.
- **Carpet rule (the renamed Retrofits):** the Hammer Mill's +30 stacks with Passive Income, and Faster Loading's +30 px stacks with both field radii.

**Round 3 (owner's picks and notes, 2026-10-19):**
- **Picks:** the Retrofits Hammer Mill and Faster Loading A (a second grab crane). The paths are as in round 2.
- **"Lets try a laser cutter instead of a sorting line":** Kill Income step 3 is renamed **Laser Cutter**, with the effect unchanged (in `design/tower_roster.md` and the regenerated trees). It has three new ideas on the main belt:
  - a laser gantry whose head sweeps across, with a glowing cut line and sparks;
  - a laser cutting table beside the belt, where a head traces a glowing cut through a plate;
  - a laser turret on a post, tracking the scrap riding up with a red beam.
- **Round 4 (owner's paste, no notes):** the Laser Cutter is the **Laser Gantry** (A). Every stage is now picked.
- **Confirmed (owner, 2026-10-19, "Finished"):** the round 5 page is final. Passive Income: Glowing Firebrick, Side Blower, Hot-Blast Stoves, Plasma Ring, Gold Shell. Kill Income: Tow Truck, Bridge Magnet, Laser Gantry, Flat Press, Gold Crane. Discounts: Open-Roof Shelves, Stacker Crane, Forklift Run, Twin Ramps, Gold Fleet. Retrofits: Hammer Mill, Faster Loading (second grab crane), Surplus (crates to the left).
- **Round 5 (owner's note, "Make sure the hammer mill is underneath the gantry"; the owner chose "rail clearly over it"):** the bridge magnet's rails now run on past the Hammer Mill to y 35, with end stops, so the rail plainly passes over the mill instead of ending on it.
- **"Move the additional crates to the left of the preexisting boxes":** Surplus's two crates now stand to the left of the crate stack (one design, preselected). The tow truck moved down 2 units to clear them.

### Magneto Tower (second pass on the Stacked Coil Tower)

**Owner's choices (2026-10-19):** the names stay as they are. Each path rebuilds one part: Pull Strength the **coil stack**, Field Size the **base** (rebuilt into field emitters), Polarity the **pole cap**.

**The page** (`design/tower_art_p2_18_magneto.html`, data `tools/tower_art/data_p2_magneto.js` on the base `data_towers4.js`, look F, animation F). Each step rebuilds its part in the style picked for that step, and the new design replaces the old one. Masteries are gold.
- **Pull Strength (coil stack, bigger each step):**
  - **Thick windings:** striped, then clamped by four straps, then double-banded.
  - **Tiered stack:** four, then five, then six coils, held in a three-legged brace.
  - **Iron yoke:** each coil gets an iron core band on a laminated yoke with grip teeth.
  - **Dense Field:** current runs visibly round the windings, or flux glows between the coils over the yoke.
  - **Absolute Pull:** all gold.
- **Field Size (the base as field emitters):**
  - **Emitter rings:** one, two, then three rings of glowing nodes, on struts from Broad Field.
  - **Pylons:** three, four, six, then eight, linked by arcs from Broad Field, with dishes from Great Field.
  - **Fold-out field plates:** six plates, longer each step, layered from Great Field.
  - **Magnetosphere:** gold under a gold aurora.
- **Polarity (the pole cap, bigger each step):**
  - **Split pole:** a red/blue split pole, ringed, then turning.
  - **Claws:** three to six hooked claws round a red core.
  - **Spikes:** a crown of five to nine red and blue spikes.
  - **Torn Plates onward:** the stripped armour plates cling round the cap.
  - **Reverse Polarity:** gold, and the pole's red and blue swap at each repel.
- **The agent (Drag Trails plus the real rules):**
  - The field ring grows, and a slow tag shows the real slow.
  - Armour plates fly from enemies in the field to the cap, with -2, -4 or -5.
  - From Torn Plates, stripped enemies stay cracked after they leave.
  - At Reverse Polarity, every 4 s the field flips to repel: a ring flash in the new pole colour, and enemies are flung out and stunned.
- **Retrofits:**
  - **Superconducting Coil:** frost rime, a cryo jacket, or cold vapour.
  - **Field Stabiliser:** a gyro ring, ballast blocks, or a floating ferrite halo.
  - **Pole Shoes:** iron shoes, a shoe ring, or shoe plates by the cap.
- **Carpet-rule overlaps (kept, stacking):**
  - The Superconducting Coil's +5% slow with Pull Strength.
  - The Field Stabiliser's +15 px with Field Size.
  - The Pole Shoes' 30% less resistance with Heavy Grip and Mass Lock.

**Round 2 (owner's picks, no notes, 2026-10-19):** every step A (thick windings, emitter rings, the split pole); Retrofits Superconducting Coil A (Frost Rime), Field Stabiliser C (Ferrite Halo), Pole Shoes B (Shoe Ring). The page shows only the picks.

**Round 3 (owner's note, "Make sure the innermost field is always visible when the coil expands"):** the emitter rings now start just outside the coil stack's current edge (straps and teeth included), between 17 and 19.5 units, 2.4 apart. They are drawn over the coils, so the innermost one is always visible as Pull Strength grows the coils. The Ferrite Halo now floats over the outer coil, inside the rings.

**Confirmed (owner, 2026-10-19, "finished"):** the round 3 page is final.

### Tractor Tower (redesign: base look first)

**History.** The second pass on the confirmed Claw Emitter ran two rounds. In round 1 the owner picked Recharge B, Longer Hold B and Faster Recharge C, and noted that Grip is "in relation to how strong the effect is. Not a physical claw or clamp". They asked for more Pull Distance ideas and for Twin Emitter to be replaced. In round 2 the owner said "I want to completely redesign the tractor tower from scratch". `data_p2_tractor.js` and its page are deleted; git keeps them.

**Scope and direction (owner's answers, 2026-10-19):**
- **Scope:** the art and the upgrade art start over. The mechanic, the three paths, their effects and their names stay.
- **Problem:** the owner didn't like the design or the upgrade designs.
- **Direction:** a dish on a mast, as two dish looks plus one wildcard. Three new animations to pick.
- **Twin Emitter:** its replacement (Stasis Wake, Beam Sweep or Shock Field were offered) is picked later, on the upgrade page.
- **Grip carries forward:** it shows the effect's strength, not a physical part.

**The page** (`design/tower_art_p19_tractor.html`, from `tools/tower_art/data_tractor_looks.js`):
- **A. Radio Telescope:** a white mesh dish on a lattice mast, tilting to face its target. Three struts hold a feed horn at its focus, where the beam leaves, with a counterweight behind.
- **B. Armoured Dish:** a riveted steel dish on twin hydraulic rams over a heavy round base. A long emitter spike sits at its centre, and its rim glows cyan on a lock.
- **C. Gravity Ring Projector (wildcard):** no dish. Three nested gimbal rings float and turn round a glowing emitter crystal that points at the target.
- **Animations (pick one):**
  - **Light Cone:** a soft cyan cone from the dish, with scan lines running back up it.
  - **Focus Beam:** a tight bright beam with rings sliding down it toward the tower; the enemy shakes.
  - **Tractor Waves:** wave fronts ripple out to the enemy, chevrons run back along the beam, and the enemy sits in rippling rings.

**Round 2 (owner's picks, no notes, 2026-10-19):** look **B Armoured Dish**, animation **B Focus Beam**. The page shows only the picks.

## Open questions

1. **Tractor Tower base look, redesign** (tower 19, round 2: B Armoured Dish, B Focus Beam): confirm, then say "Tractor Tower base finished". Then the second pass (with the Twin Emitter replacement), then the Augmentation Tower.
