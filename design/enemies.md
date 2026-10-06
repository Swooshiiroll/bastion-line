# Bastion Line Enemy Rework (design)

A rework of the whole enemy system around **roles, tiers and modifiers**. This is a **draft for the
owner to mark up**. Nothing here is confirmed, and no game code changes until the owner confirms the
spec (repo CLAUDE.md, "Designing a feature first").

## Why

- Enemies feel samey.
- Late rounds only add HP and speed.
- Leaks cost the wrong number of shields (#7).
- The owner wants new mechanics and more enemies.

## Owner direction (the framework)

- **Roles** stay (Swarm, Rusher, Tank, Support, Disruptor, Evader, Special, Boss).
- **Each role has tiers.** A higher tier has more health and/or more speed than the one below it.
- **No enemy has a modifier by default.** The possible exception is the Phantom's cloak (open
  question 5).
- **Modifiers can apply to any enemy** and are what raises **wave difficulty**.
- **Tiers drive "Strongest" targeting.** Each role's tiers sit in one overall ranked list, which
  decides the Strongest order across roles.
- **More enemies are wanted:** tiers for thin roles, enemies that trick targeting, and higher tiers
  so difficulty can come from the tier mix.

## What exists today

- 22 enemy types (`data/enemies.gd`) and no modifiers.
- Only round scaling changes an enemy: HP `1 + 0.06w + 0.0025w²` (+4% per round after 40), speed
  +0.45% per round, capped at +50% (bosses get half).
- **Strongest** targeting scores by `e.hp` (current HP) in `Game._score` (`Game.gd`;
  `Tower.MODE_NAMES` = First / Last / Strongest / Closest). It ignores enemy type.
- Difficulty changes only the round count, shields, prices and medal RP.
- A leak costs a fixed number of shields per type (1 to 3; bosses 6, 15, 20, 25).
- Heal, spawn, EMP and shield-grant share one timer, so an enemy can have only one of them.
- Tests pin many numbers (waves, scaling, the "22 enemy types", Codex ability text). The Easy and
  Medium bot playthroughs must still earn medals.

## Rules

### 1. Roles with tiers

Every enemy is a **role + tier**. Tier 1 is the basic version. Each higher tier has more HP and/or
speed than the one before and keeps the role's job and counter. The placements below are a **draft
for the owner to correct**.

| Role | Job | Counter | Today's enemies (draft tiers) |
|---|---|---|---|
| Swarm | Overwhelm single-target towers | Splash, chain | T1 Nanite, T2 Locust, T3 Drone |
| Rusher | Get past before damage lands | Slows, burst | T1 Skitter, T2 Strike Drone |
| Tank | Soak damage | Armor shred, % damage | T1 Siege Mech, T2 Gunship, T3 Rampart |
| Support | Make others harder | Focus first | T1 Repair Bot, T2 Rally Beacon, T3 Bulwark, T4 Mender Hulk |
| Disruptor | Switch off towers | Range, reveal, burst | T1 Jammer |
| Evader | Dodge targeting | Sensors, area | T1 Burrower, T2 Phantom, T3 Blink Stalker |
| Special | Break a rule | Barrier strip, area | Aegis Walker (barrier), Hydra Frame (split) |
| Boss | Set-piece | Mixed defence | Dreadnought, Overmind, Leviathan, Colossus |

Note: Drone (`grunt`) is the basic enemy, and Strike Drone (`bat`) is a flyer that ignores the lane,
so neither fits its draft slot well (open question 17).

### 2. Strength rank and Strongest targeting

- One **global strength rank** that every role-tier slots into. Roles interleave, so "T2 Tank" can
  outrank "T3 Swarm". Bosses sit at the top.
- **Strongest** becomes: highest strength rank first, then current HP, then path progress. This
  replaces `e.hp` in `Game._score`. (Tie-break order is open question 4.)
- A modifier does not change the rank by default (open question 7).
- The rank is stored in one data table, so it can be rebalanced without code changes. It is shown in
  the Codex and Intel.

### 3. Traits as data-driven building blocks

- An enemy is a **body** (HP, speed, size, leak cost, role, tier) plus **traits** from one registry:
  armor, barrier, regen, haste aura, cloak, burrow, blink, split, jam, summon, heal, grant.
- Each trait has **its own timer**, removing the one-ability-per-enemy limit.
- Phase 1 changes no behaviour: a refactor pinned by the current tests.

### 4. Modifiers, on any enemy, driving wave difficulty

- **No modifiers by default.** A modifier is a reusable trait or stat change that can apply to any
  enemy of any role and tier.
- **Wave difficulty:** the wave generator uses modifiers, alongside tier mix and count, as a
  difficulty knob. Each modifier has a threat cost in the wave budget, as enemy types do now.
- **Announced** on the Intel panel and the NEXT strip. Elites get a ring and a label.
- **First catalogue (about 10):** Hasty, Plated, Shielded, Regenerating, Cloaked, Splitting, Jamming,
  Swarming (double count, half HP), Volatile (explodes on death, hurting towers), Resolute (resists
  slow and stun), Commanding (aura). Each names its counter in the Codex.
- How many stack, and from which round, is open (question 8).

### 5. Leak costs (closes #7)

Leak cost follows **tier**: a base cost per role-tier, +1 for elites, and bosses a fixed share of the
mode's shields (so Cataclysm's single shield still works). Checked with the balance probe on every
difficulty.

### 6. Bosses

Keep the four bosses. Give each a clearer kit built from the same traits, at the top of the ranked
list.

### 7. New enemies (draft roster)

The owner asked for three kinds: tiers for thin roles, enemies that trick targeting, and higher
tiers so difficulty comes from the tier mix and not only from HP scaling. **Names are placeholders.**
Role, tier, job and counter are a draft with no numbers yet. Each is built from the trait registry
and has no modifiers by default.

| Placeholder | Role / tier | Gap it fills | Job | Counter |
|---|---|---|---|---|
| Dart | Rusher T3 | Thin role | Very fast, light hull; arrives in pairs | Slows, fast-firing towers |
| Interceptor | Rusher T4 | Higher tier | Fast with light armor; speeds up when damaged | Burst, armor shred |
| Siphon | Disruptor T2 | Thin role | Aura lowers the fire rate of nearby towers instead of switching them off | Range, focus fire |
| Blackout Rig | Disruptor T3 | Thin role / higher tier | Armored Jammer with a larger EMP radius and a shorter cycle | Long range, burst |
| Razor Swarm | Swarm T4 | Higher tier | Dense swarm of tougher small units | Splash and chain upgrades |
| Titan | Tank T4 | Higher tier | Heaviest non-boss hull, between Rampart and the bosses | % damage, armor shred |
| Nexus | Support T5 | Higher tier | Repairs and hastes in one aura; the "kill it first" priority late on | Focus first, range |
| Wraith | Evader T4 | Higher tier | Cloaked; visible for a moment after each blink | Sensors, area |
| Mimic | Evader or Special | Targeting trick | Shows a low rank (looks like T1) until first hit or below a set HP, then shows its real higher rank | Area damage reveals it early; First targeting |
| Decoy Beacon | Support | Targeting trick | Shows a false high strength rank so Strongest towers aim at it while others get past; armored, does nothing else | Switch towers to First, splash |
| Echo | Special | Targeting trick | Puts out hologram copies with the same rank and 1 HP that use up shots | Area and chain, sensors |

The "22 enemy types" test count changes when these land (phase 4).

### 8. Presentation and tools

- Intel, the NEXT strip and the Codex show role, tier and modifiers. The Codex PDF is regenerated.
- **Sandbox Spawner:** pick a role-tier and any modifier, so every combination can be tested.
- **Balance probe:** switches for modifiers and the tier table.

## Phasing

Separate PRs, each confirmed by the owner:

1. Role, tier and strength-rank data, plus the trait registry and per-trait timers. No gameplay change.
2. Strongest targeting by strength rank (with its tests and Codex text).
3. Modifier engine, wave generation and the Intel UI.
4. Roster changes and rebalance: tiers, new enemies, leak costs, boss kits.
5. Codex, Sandbox picker and probe support.

## Out of scope

Game code in this PR. Only this doc changes.

## Open questions

1. **Tiers:** how many per role? Are the draft placements right (e.g. is Drone really Swarm T3)? Does
   every role need the same number of tiers?
2. **Tier scaling:** does each tier add a flat step in HP and speed, a multiplier, or does it vary by
   role (Tanks gain HP, Rushers gain speed)?
3. **Ranked list:** one number (1 to 10) or named bands (Fodder / Standard / Heavy / Elite / Boss)?
   Where does each role-tier land?
4. **Strongest ties:** if two enemies share a rank, current HP or path progress first?
5. **Phantom:** keep its built-in cloak, or make cloak a modifier that can apply to any enemy?
6. **Special enemies** (Aegis barrier, Hydra split): roles with tiers, or one-offs that also become
   modifiers (Shielded, Splitting)?
7. **Modifiers and rank:** does a modifier raise the strength rank never, always, or only the heavy
   ones?
8. **Stacking:** how many modifiers per enemy and per wave, from which round, and is Easy
   modifier-free?
9. **Wave and elite:** modifiers on whole waves, on single elites, or both?
10. **Tower and research changes** allowed where a modifier needs a counter?
11. **Saves:** modifiers stored in mid-run saves need a version bump. Acceptable?
12. **Other enemies or mechanics** you want that aren't here (ranged, tower killers, lane blockers,
    enemies on other routes)?
13. **New roster:** keep, cut or change which draft enemies? What should they be called?
14. **Higher tiers and HP scaling:** once the top tiers exist, should per-round HP scaling be lowered
    (or lowered after round 40) so late difficulty comes from the tier mix?
15. **First appearance:** from which round (and on which difficulty) does each new tier start?
16. **Targeting tricks:** how strong should they be? Should the Codex and Intel show a Mimic's or
    Decoy's real rank, or keep it hidden until the trick is revealed?
17. **Drone and Strike Drone:** Drone is the basic enemy and Strike Drone is a flyer that ignores the
    lane. Do they need a role of their own, e.g. Line and Flyer?
