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
- **No enemy has a modifier by default.** The one exception is the Phantom's built-in cloak
  (decided).
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
- Saves (`Game.to_save`, `SAVE_VERSION` 9) store the wave, towers, research, seed and spawn counter, not
  enemies, and only between rounds. Each round's waves are generated from the seed.
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
| Evader | Dodge targeting | Sensors, area | T1 Burrower, T2 Blink Stalker |
| Special | Break a rule | Barrier strip, area | Aegis Walker (barrier), Hydra Frame (split), Phantom (built-in cloak) |
| Boss | Set-piece | Mixed defence | Dreadnought, Overmind, Leviathan, Colossus |

Note: Drone (`grunt`) is the basic enemy, and Strike Drone (`bat`) is a flyer that ignores the lane,
so neither fits its draft slot well (deferred, see Deferred below).

**Decided (owner):**
- **Same tier count for every role.** The number itself is open (see Still open, "Tier count").
- **Flat tier stats.** Each tier has its own flat HP and speed stat, not a multiplier on the tier
  below.
- **Phantom is a Special.** It keeps its built-in cloak as a specialized enemy. Cloaked is also a
  modifier that any enemy can take (section 4).
- **Special enemies stay specials** (Aegis, Hydra, Phantom). Splitting may also become a modifier.

### 2. Strength rank and Strongest targeting

- One **global strength rank** that every role-tier slots into. Roles interleave, so "T2 Tank" can
  outrank "T3 Swarm". Bosses sit at the top.
- **Strongest** becomes: highest strength rank first, then current HP, then path progress. This
  replaces `e.hp` in `Game._score`. The tie-break order is awaiting confirmation (see Still open,
  "Strongest ties").
- Whether a modifier changes the rank **depends on the modifier**: each modifier's entry states its
  effect on rank.
- The ranked list itself is deferred (see Deferred below).
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
- **Single elites only (decided).** A modifier goes on an individual elite enemy, never on a whole
  wave.
- **Wave difficulty:** the wave generator uses elites with modifiers, alongside tier mix and count, as
  a difficulty knob. Each modifier has a threat cost in the wave budget, as enemy types do now.
- **Announced** on the Intel panel and the NEXT strip. Elites get a ring and a label.
- **First catalogue (about 10):** Hasty, Plated, Shielded, Regenerating, Cloaked, Splitting, Jamming,
  Swarming (double count, half HP), Volatile (explodes on death, hurting towers), Resolute (resists
  slow and stun), Commanding (aura). Each names its counter in the Codex.
- **Cloaked** is a modifier for any enemy, alongside the Phantom's built-in cloak. **Splitting** may
  become a modifier too.
- **Stacking and start round (decided):** set by balancing checks. The aim is a healthy mix of
  modifiers in the later rounds. Whether Easy has none is left to the same checks.
- Note: **Swarming** (double count, half HP) acts on a group, so it doesn't fit "single elites only".
  It needs a ruling (see Still open).

### Round scaling (decided)

Per-round HP scaling is **lowered**, so late difficulty comes from the tier mix and from elites. The
exact curve is set with the balance probe.

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

Answered by the owner on 2026-10-07. Numbers match the first draft's question numbers.

### Decided

- **Q2 Tier scaling:** each tier has a flat HP and speed stat.
- **Q5 Phantom:** keeps its built-in cloak as a specialized enemy; Cloaked is also a modifier for any
  enemy.
- **Q6 Specials:** they stay specials. Splitting may become a modifier.
- **Q7 Modifiers and rank:** depends on the modifier.
- **Q8 Stacking:** set by balancing checks. Later rounds should have a healthy mix of modifiers.
- **Q9 Where modifiers go:** single elites.
- **Q14 HP scaling:** lowered.

### Still open

Each item has a recommendation. Reply with a letter or a change.

1. **Tier count (from Q1).** Every role gets the same number of tiers, but today's counts are Swarm 3,
   Rusher 2, Tank 3, Support 4, Disruptor 1 and Evader 2 (Phantom moves to Special).
   - **3 tiers:** Support loses a tier and Disruptor needs two new enemies.
   - **4 tiers:** most roles gain new enemies, which fits the wish for higher tiers.
   - **Recommendation: 4** for the regular roles, with Special and Boss as named exceptions. The draft
     Nexus (Support T5) is then cut or folded into T4.
2. **Strongest ties (Q4).** Strongest sorts by strength rank first. A tie means two enemies of the same
   role and tier on the field, e.g. a wave of Gunships.
   - **A:** highest current HP first, then path progress. Within a tier, Strongest still means "the
     beefiest", as it does today. A fresh enemy at the back outranks a nearly dead one at the exit.
   - **B:** path progress first. This stops leaks, but Strongest then behaves like First within a tier.
   - **Recommendation: A.** First and Last already cover position.
3. **Tower and research counters (Q10).** Some modifiers have no clean counter today:
   - **Cloaked** needs Sensor Array coverage, so a cloaked elite in an uncovered lane is effectively
     untouchable.
   - **Volatile** hurts towers and needs range or burst to pop it early.
   - **Resolute** shrugs off slows and stuns (Rampart and Colossus already show how awkward that is).

   May I add or change tower upgrades and research nodes to counter them, or must modifiers work with
   the current towers? Without counters, the catalogue shrinks to what current towers can answer.
   **Recommendation:** allow small counters, each in its own PR you approve.
4. **Saves (Q11).** Corrected after reading the save code:
   - A save stores the wave, gold, lives, towers, research, the seed and the spawn counter
     (`Game.to_save`, `SAVE_VERSION` 9). **It stores no enemies**, and saving only works between
     rounds (`can_save`). Each round's waves come from `seed_value * 1000 + round`.
   - If elites and their modifiers are picked from that same seed, **modifiers need no new save field
     and no version bump.**
   - What does change: the same seed produces different future waves after the update, so an old save's
     remaining rounds differ. That is a balance change, not corruption.
   - Old saves already load and re-save at the current version (tests cover v1 to v8). Dropping them
     would break that pattern.
   - **Recommendation:** no bump for modifiers. Bump `SAVE_VERSION` only if the tier or roster data
     changes what a saved value means, and then migrate as the existing tests do.
5. **New roster (Q13).** The 11 draft enemies are Dart, Interceptor, Siphon, Blackout Rig, Razor Swarm,
   Titan, Nexus, Wraith, Mimic, Decoy Beacon and Echo. Which to keep, cut or rename depends on item 1.
   Nexus (Support T5) and Wraith (Evader T4) only exist if those roles reach that tier. With cloak now
   a modifier, check whether Wraith is still needed. A rough keep/drop list is enough; names can wait.
6. **Mimic and Decoy rank (Q16).** The field label hides the true rank until revealed (decided).
   The open part is the Codex. **Recommendation:** the Codex states each trick plainly, as the Phantom's
   entry does, but a player who has not met the enemy yet should not be spoiled. Check whether the
   Codex tracks seen enemies; if not, state the trick plainly anyway.
7. **Swarming.** It doubles the count at half HP, which acts on a group, not a single elite.
   - **1:** drop it.
   - **2:** rework it into an elite that spawns a pair of weaker copies on death (this overlaps
     Splitting).
   - **3:** keep it as a wave-level exception.
   - **Recommendation: 1.** Splitting covers the idea.

### Deferred

To be settled later or during implementation, as the owner said:

- **Q3** Global ranked list: numbers or named bands, and where each role-tier lands.
- **Q12** Other enemies or mechanics (ranged, tower killers, lane blockers, other routes).
- **Q15** First appearance round and difficulty for each new tier.
- **Q17** Whether Drone and Strike Drone need roles of their own, such as Line and Flyer.
