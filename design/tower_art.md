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
| 4 | Rocket Salvo | `design/tower_art_p2_04_rocket.html` | Round 3: taller 8-tube banks; to confirm |

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

## Open questions

1. **Second pass, Rocket Salvo** (round 3): confirm; then towers 5-20.
