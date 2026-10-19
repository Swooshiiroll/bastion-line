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
| 19 | Tractor Tower | cyan | C Claw Emitter | C Spiral Lock |
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
| 12 | Chemical Plant | `design/tower_art_p2_12_chem.html` | Round 1: three options per stage; awaiting picks |

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

## Open questions

1. **Second pass, Chemical Plant** (tower 12, round 1): pick one option per stage and Retrofit. Then towers 13-20 (next: Boost Tower).
