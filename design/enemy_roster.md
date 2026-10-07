# Bastion Line Enemy Roster (draft)

Every current and proposed enemy with its stats, for the owner to mark up. It supports
`design/enemies.md` (the rework spec); that spec holds the rules, this file holds the numbers.
**Nothing here is confirmed.** Current stats come from `data/enemies.gd`. Proposed stats are my drafts,
built so each role's tiers rise in strength and bosses sit on top. No game code or data changes.

## How to read it

- **HP, Speed, Armor** are round-1 base values. Round scaling and difficulty modes change them in play.
- **Str** (strength) = spd² (arm x hp), with spd = speed / 100 and armor 0 counted as 1. Rank 1 is the
  weakest. **Bosses rank above every non-boss**, whatever their score.
- **Leak** is the core shields a leak costs. For current enemies it is today's value. For proposed ones
  it is a draft; the leak-cost bands (section 5 of the spec) are not defined yet.
- **Bounty** is the gold per kill. Proposed values are drafts.
- **Fly** is Yes for flyers. **Special** and **Boss** have no tiers.

## Role and tier grid (four tiers per regular role)

| Role | T1 | T2 | T3 | T4 |
|---|---|---|---|---|
| Swarm | Nanite | Drone | Locust | Razor Swarm (new) |
| Rusher | Strike Drone | Skitter | Dart (new) | Interceptor (new) |
| Tank | Siege Mech | Gunship | Rampart | Titan (new) |
| Support | Repair Bot | Rally Beacon | Bulwark | Mender Hulk |
| Disruptor | Jammer | Siphon (new) | Blackout Rig (new) | Surge Core (new) |
| Evader | Blink Stalker | Burrower | Slipstream (new) | Wraith (new) |

**Special (no tiers):** Phantom, Aegis Walker, Hydra Frame, Mimic (new), Decoy Beacon (new), Echo (new).
**Boss (no tiers):** Dreadnought, Overmind, Leviathan, Colossus.
**Cut:** Nexus (draft Support T5). Support already has four tiers, so it is cut or folded into T4.

## Full roster, weakest to strongest

| Rank | Enemy | Role | Tier | HP | Speed | Armor | Str | Leak | Bounty | Fly | Traits | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Nanite | Swarm | T1 | 22 | 78 | 0 | 13.38 | 1 | 2 |  | Tiny self-replicating machines that come in swarms | Current |
| 2 | Drone | Swarm | T2 | 70 | 55 | 0 | 21.18 | 1 | 4 |  | Basic combat drone | Current |
| 3 | Locust | Swarm | T3 | 18 | 115 | 0 | 23.80 | 1 | 1 | Yes | Flies straight at the core in dense swarms | Current |
| 4 | Repair Bot | Support | T1 | 125 | 50 | 1 | 31.25 | 2 | 11 |  | Heals nearby enemies 8% every 2 s, radius 90 (not bosses) | Current |
| 5 | Jammer | Disruptor | T1 | 150 | 50 | 1 | 37.50 | 2 | 12 |  | EMP radius 95: towers offline 2 s every 5 s | Current |
| 6 | Echo | Special | - | 140 | 55 | 1 | 42.35 | 2 | 12 |  | Every 6 s drops 2 hologram copies (1 HP, same displayed rank) that use up shots | Proposed (draft) |
| 7 | Strike Drone | Rusher | T1 | 64 | 82 | 0 | 43.03 | 1 | 5 | Yes | Flies straight at the core, ignoring the lane (mortars can't hit it) | Current |
| 8 | Phantom | Special | - | 85 | 72 | 0 | 44.06 | 1 | 7 |  | Built-in cloak: targetable only inside a Sensor Array field or briefly after area damage | Current |
| 9 | Razor Swarm | Swarm | T4 | 55 | 90 | 0 | 44.55 | 2 | 3 |  | Dense swarm of tougher small units | Proposed (draft) |
| 10 | Skitter | Rusher | T2 | 45 | 105 | 0 | 49.61 | 1 | 4 |  | Fast, fragile crawler | Current |
| 11 | Blink Stalker | Evader | T1 | 110 | 70 | 1 | 53.90 | 1 | 8 |  | Blinks 80 px down the lane every 4 s; slow or stun resets the charge | Current |
| 12 | Aegis Walker | Special | - | 150 | 44 | 2 | 58.08 | 2 | 12 |  | Barrier 130, regenerates 0.25/s after 2.5 s; Arc Coils deal double to barriers | Current |
| 13 | Rally Beacon | Support | T2 | 170 | 48 | 2 | 78.34 | 2 | 12 |  | Aura radius 100: other non-boss enemies move 25% faster | Current |
| 14 | Dart | Rusher | T3 | 40 | 140 | 0 | 78.40 | 1 | 5 |  | Very fast, light hull; spawns in pairs | Proposed (draft) |
| 15 | Siphon | Disruptor | T2 | 190 | 52 | 2 | 102.75 | 2 | 12 |  | Aura radius 100: nearby towers fire 20% slower | Proposed (draft) |
| 16 | Bulwark | Support | T3 | 200 | 42 | 3 | 105.84 | 2 | 13 |  | Every 6 s gives enemies within 100 px a barrier worth 25% of their health | Current |
| 17 | Hydra Frame | Special | - | 190 | 46 | 3 | 120.61 | 2 | 8 |  | Splits into 3 Skitters when destroyed | Current |
| 18 | Burrower | Evader | T2 | 160 | 62 | 2 | 123.01 | 2 | 9 |  | Burrows for 2.5 s every 5 s: can't be targeted or hurt | Current |
| 19 | Interceptor | Rusher | T4 | 85 | 125 | 1 | 132.81 | 2 | 9 |  | Speeds up when damaged (+30% below half health) | Proposed (draft) |
| 20 | Mender Hulk | Support | T4 | 380 | 38 | 3 | 164.62 | 2 | 14 |  | Regenerates 4% of its health per second after 1.5 s without damage | Current |
| 21 | Blackout Rig | Disruptor | T3 | 260 | 48 | 3 | 179.71 | 3 | 15 |  | EMP radius 130: towers offline 2.5 s every 4 s | Proposed (draft) |
| 22 | Slipstream | Evader | T3 | 200 | 68 | 2 | 184.96 | 2 | 13 |  | Burrows 2 s every 6 s and blinks 60 px every 5 s | Proposed (draft) |
| 23 | Siege Mech | Tank | T1 | 265 | 40 | 6 | 254.40 | 2 | 10 |  | Armor plating | Current |
| 24 | Wraith | Evader | T4 | 260 | 74 | 2 | 284.75 | 3 | 18 |  | Cloaked; visible 1 s after each blink; blinks 80 px every 5 s; only energy attacks hurt it (needs the damage-type PR) | Proposed (draft) |
| 25 | Decoy Beacon | Special | - | 400 | 36 | 6 | 311.04 | 1 | 10 |  | Shows a false top rank so Strongest towers aim at it; does nothing else | Proposed (draft) |
| 26 | Surge Core | Disruptor | T4 | 420 | 44 | 4 | 325.25 | 3 | 20 |  | EMP radius 160: towers offline 3 s every 6 s | Proposed (draft) |
| 27 | Mimic | Special | - | 320 | 60 | 3 | 345.60 | 2 | 14 |  | Shows as a T1 until first hit or below half health, then shows its real rank | Proposed (draft) |
| 28 | Gunship | Tank | T2 | 420 | 42 | 5 | 370.44 | 3 | 18 | Yes | Armored heavy flyer | Current |
| 29 | Rampart | Tank | T3 | 520 | 34 | 8 | 480.90 | 3 | 18 |  | Immune to slows, stuns and shoves | Current |
| 30 | Titan | Tank | T4 | 800 | 30 | 9 | 648.00 | 4 | 24 |  | Heaviest non-boss hull; slow resist 50% | Proposed (draft) |
| 31 | Dreadnought | Boss | - | 800 | 32 | 5 | 409.60 | 6 | 120 |  | Boss. Slow resist 50% | Current |
| 32 | Overmind | Boss | - | 1,900 | 20 | 10 | 760.00 | 20 | 500 |  | Boss. Slow resist 60%; spawns 3 Nanites every 5 s | Current |
| 33 | Leviathan | Boss | - | 2,600 | 24 | 6 | 898.56 | 15 | 400 | Yes | Boss. Slow resist 50%; launches 6 Locusts every 6 s | Current |
| 34 | Colossus | Boss | - | 4,200 | 18 | 14 | 1,905.12 | 25 | 700 |  | Boss. Slow resist 60%, can't be stunned; at 66% and 33% health sheds 5 armor, speeds up 20% and drops 2 Siege Mechs | Current |

## What the formula changed in the draft tiers

- **Drone and Locust swap.** The first draft had Locust at Swarm T2 and Drone at T3, but Drone scores
  21.18 and Locust 23.80, so a tier that rises in strength puts Drone at T2 and Locust at T3.
- **Strike Drone and Skitter swap.** Strike Drone scores 43.03 and Skitter 49.61, so Strike Drone is
  Rusher T1 and Skitter T2. That puts a flyer at T1 of a role that is otherwise ground rushers.
- **Evader order.** Blink Stalker (53.90) is T1 and Burrower (123.01) T2.
- **Support is already in order** (Repair Bot, Rally Beacon, Bulwark, Mender Hulk).
- **Slots to fill:** four tiers per role needs new Swarm T4, Rusher T3 and T4, Tank T4, Disruptor T2 to
  T4, and Evader T3 and T4. Surge Core and Slipstream are new placeholders for Disruptor T4 and Evader
  T3; they were not in the spec's first roster.
- **Wraith** waits for the damage-type PR, so Evader T4 may stay empty until then.

## Notes

- The proposed enemies keep the targeting tricks from the spec: Mimic hides its rank, Decoy Beacon fakes
  a high one, and Echo spends shots on holograms. Their score is the real stat score.
- Armor 1 and armor 0 multiply by 1, so Repair Bot, Jammer and Blink Stalker score as unarmored.
- Questions on this roster go in the Open questions of `design/enemies.md`.
