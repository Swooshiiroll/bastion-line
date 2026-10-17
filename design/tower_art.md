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
| 4 | Shockwave Generator, Scrapyard, Magneto Tower, Tractor Tower, Augmentation Tower | `design/tower_art_4.html` | Round 2: picks open |

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

**Picks:** to come.

## Open questions

1. **Page 4 picks** (round 2), and whether the proposed Tractor cyan and Augmentation lavender stand.
2. Then the second pass (per-path looks and Retrofit looks).
