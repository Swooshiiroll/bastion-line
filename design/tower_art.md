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
| 1 | Gun Turret, Mortar Tower, Laser Tower, Rocket Salvo, Anti-Aircraft Turret | `design/tower_art_1.html` | Round 1: picks open |
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

**Picks:** to come (look, animation; notes).

## Open questions

1. **Page 1 picks.**
2. Pages 2 to 4, then the second pass (per-path looks and Retrofit looks).
