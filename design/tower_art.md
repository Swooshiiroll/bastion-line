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
| 2 | Artillery Cannon, Railgun, Tesla Tower, Drone Bay, CAS Gunship | `design/tower_art_2.html` | Round 1: picks open |
| 3 | Mine Layer, Chemical Plant, Boost Tower, Radar Tower, Cryo Tower | `design/tower_art_3.html` | Not started |
| 4 | Shockwave Generator, Scrapyard, Magneto Tower, Tractor Tower, Augmentation Tower | `design/tower_art_4.html` | Not started |

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

**Picks:** to come.

## Open questions

1. **Page 2 picks** (round 1), including whether the proposed Artillery blue and CAS pink stand.
2. Pages 3 and 4, then the second pass (per-path looks and Retrofit looks).
