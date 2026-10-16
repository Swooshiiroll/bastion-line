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
- **Style:** **modern military with sci-fi touches**: recognisable real-world hardware, with sci-fi where the weapon is
  (lasers, Tesla coils, tractor beams).
- **Colour:** **per tower**: each tower has its own accent colour.
- **No shared family look:** each tower is designed on its own (unlike the enemies' role families).
- **Top-down**, like the game: a static base, and a turret that rotates to aim. (In the game, the animated parts go
  between `Draw.dyn(true)` and `dyn(false)`, and the rest is cached; see CLAUDE.md.)

## Mockup pages

Every preview runs live. The turret tracks the nearest enemy it can hit and fires on its animation's rhythm, at ground
enemies on the lane and flyers overhead (air-only towers ignore the ground, and ground-only towers ignore flyers).

| Page | Towers | File | Status |
|---|---|---|---|
| 1 | Gun Turret, Mortar Tower, Laser Tower, Rocket Salvo, Anti-Aircraft Turret | `design/tower_art_1.html` | Round 4: only the Rocket Salvo open |
| 2 | Artillery Cannon, Railgun, Tesla Tower, Drone Bay, CAS Gunship | `design/tower_art_2.html` | Not started |
| 3 | Mine Layer, Chemical Plant, Boost Tower, Radar Tower, Cryo Tower | `design/tower_art_3.html` | Not started |
| 4 | Shockwave Generator, Scrapyard, Magneto Tower, Tractor Tower, Augmentation Tower | `design/tower_art_4.html` | Not started |

## Page 1, round 1 (towers 1-5)

| Tower | Look A | Look B | Look C |
|---|---|---|---|
| Gun Turret | Sandbag MG Nest | Armoured Turret | Remote Weapon Station |
| Mortar Tower | Mortar Pit | Armoured Mortar Carrier | Turret Mortar |
| Laser Tower | Lens Turret | Emitter Spire | Mirror Dish |
| Rocket Salvo | Box Launcher | Rail Launcher | Pod Turret |
| Anti-Aircraft Turret | Twin Autocannon | Quad Mount | Radar Gun |

| Tower | Animation A | Animation B | Animation C |
|---|---|---|---|
| Gun Turret | Recoil Kick | Burst Rattle | Tracer Line |
| Mortar Tower | Tube Drop | Hard Thump | Flash and Smoke |
| Laser Tower | Ramp Glow | Pulse Hum | Heat Shimmer |
| Rocket Salvo | Ripple Fire | Salvo Blast | Elevate and Fire |
| Anti-Aircraft Turret | Skyward Bursts | Hosepipe | Track and Fire |

**Picks, round 1 (owner, 2026-10-16):**
- **Gun Turret:** look **A Sandbag MG Nest**, animation **A Recoil Kick**. **Confirmed.**
- **Mortar Tower:** animation **C Flash and Smoke**; look open, the owner asked for more designs.
- **Laser Tower:** animation **A Ramp Glow**; look open, more designs. Owner: **the laser doesn't fire until the target
  is locked on.** Every laser animation now locks on first: a reticle closes on the target over 0.6 s, then the beam
  fires.
- **Rocket Salvo:** look and animation open, more designs for both.
- **Anti-Aircraft Turret:** look **A Twin Autocannon**; animation open, more designs. Owner: **bullets should come from
  the barrel that fired them.** On every multi-barrel tower, each round now leaves its own barrel, and that barrel
  flashes and kicks back.

**Round 2** (on the same page, with the picks above preselected):
- **Mortar looks:** D Twin-Tube Mortar (two tubes on a turntable, firing in turn), E Bunker Mortar (a concrete bunker
  under a camouflage net, firing through the roof), F Heavy Siege Mortar (one fat-bored mortar behind a curved shield).
- **Laser looks:** D Twin Emitters (two converging beams), E Crystal Core (a caged glowing crystal), F Military Laser Pod
  (a boxy naval-style laser system with a sensor dome).
- **Rocket looks:** D Truck Rack (a launcher truck's eight-tube rack), E Drum Launcher (a revolving drum behind one
  barrel), F Vertical Launch Block (four cells that pop rockets straight up; doesn't rotate). **Animations:** D Rapid
  Ripple, E Twin Volley, F Pop-up Launch.
- **AA animations:** D Alternating Barrels, E Flak Barrage, F Lead the Target.

**Picks, round 2 (owner, 2026-10-16):**
- **Mortar Tower:** look **F Heavy Siege Mortar**, animation **C Flash and Smoke**. **Confirmed.**
- **Laser Tower:** look **E Crystal Core**, animation **A Ramp Glow** (locks on first). **Confirmed.**
- **Anti-Aircraft Turret:** look **A Twin Autocannon**, animation **D Alternating Barrels**. **Confirmed.**
- **Rocket Salvo:** open. Owner: "Make some vertical rocket pod ideas".

**Round 3:** Rocket Salvo looks G Raised Pod Turret (a turret that raises a square four-tube pod upright), H Twin Vertical
Pods (two upright cylindrical pods of three tubes, firing alternately), I Ring Silo (eight vertical cells in a ring
around a sensor mast; doesn't rotate). They pair naturally with animation F Pop-up Launch.

**Round 4** (owner: "Make more horizontal rocket pod designs"): Rocket Salvo looks J Quad Pod Cluster (four stubby
honeycomb pods 2x2, like helicopter rocket pods), K Side-Pod Turret (a central turret with a long pod on each side arm,
firing alternately), L Triple Stack Rack (three long pods side by side on a heavy tilting cradle).

## Open questions

1. **Page 1 picks:** the Rocket Salvo's look (A to L) and animation (A to F).
2. Pages 2 to 4, then the second pass (per-path looks and Retrofit looks).
