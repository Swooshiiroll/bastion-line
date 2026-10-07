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
  enemies, and only between rounds. Rounds 1 to 25 are hand-authored (`data/waves.gd`); from round 26,
  and in Endless, a generator builds each round from `seed_value * 1000 + round`. The run's seed is
  random, so those later rounds differ between playthroughs.
- Tests pin many numbers (waves, scaling, the "22 enemy types", Codex ability text). The Easy and
  Medium bot playthroughs must still earn medals.

## Rules

### 1. Roles with tiers

Every enemy is a **role + tier**. Tier 1 is the basic version. Each higher tier has more HP and/or
speed than the one before and keeps the role's job and counter. The placements below are a **draft
for the owner to correct**; the full grid with the proposed new enemies and all stats is in
`design/enemy_roster.md`. The owner adjusted the grid on 2026-10-07. A tier is a label (each has more HP
and/or speed than the one below); Strongest targeting uses the strength score (section 2), so tier order
and score can differ.

| Role | Job | Counter | Today's enemies (draft tiers) |
|---|---|---|---|
| Swarm | Overwhelm single-target towers | Splash, chain | T1 Nanite, T2 Locust, T3 Drone |
| Rusher | Get past before damage lands | Slows, burst | T1 Skitter, T3 Strike Drone (T2 is a new enemy) |
| Tank | Soak damage | Armor shred, % damage | T1 Siege Mech, T2 Rampart, T3 Gunship |
| Support | Make others harder | Focus first | T1 Repair Bot, T2 Rally Beacon, T3 Bulwark, T4 Mender Hulk |
| Disruptor | Switch off towers | Range, reveal, burst | T1 Jammer |
| Evader | Dodge targeting | Sensors, area | T1 Blink Stalker, T2 Burrower |
| Special | Break a rule | Barrier strip, area | Aegis Walker (barrier), Hydra Frame (split), Phantom (built-in cloak) |
| Boss | Set-piece | Mixed defence | Dreadnought, Overmind, Leviathan, Colossus |

Note: Drone (`grunt`) is the basic enemy, and Strike Drone (`bat`) is a flyer that ignores the lane,
so neither fits its draft slot well (deferred, see Deferred below).

**Decided (owner):**
- **Four tiers for every regular role** (approved), with Special and Boss as named exceptions. The draft
  Nexus (Support T5) is cut or folded into T4.
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
- **Rank comes from a formula (owner direction):** it is worked out from each enemy's base health, armor and
  speed, not ordered by hand. The formula is spd² (arm x hp) (see "Strength rank" below),
  awaiting confirmation. Stronger enemies also **drain more shields** when they leak (section 5).
- **Support and Special enemies get their own target priority (decided).** Strongest alone rarely picks
  them (Repair Bot scores low), so towers get a new priority choice that targets Support and Special
  enemies first, instead of a score bonus. Towers already have two choices: a mode (First, Last,
  Strongest, Closest, `Tower.MODE_NAMES`) and a priority (Any, Air, Ground, `Tower.PRIORITY_NAMES`).
- The rank is computed from the stats in the data table, so rebalancing stats rebalances the rank without
  code changes. It is shown in the Codex and Intel.

#### Strength rank (owner formula)

**Str = spd² (arm x hp)**, where spd is speed / 100 (so spd² is the speed as a decimal, squared).
It uses round-1 values from `data/enemies.gd`. Example from the owner: armor 50, HP 100, speed 45 gives
0.45² x (50 x 100) = 0.2025 x 5000 = 1012.5.

**Armor of 0 counts as 1 (decided).** A 0 would zero the score, and 1 is the multiplier for "no armor", so
armor 0 and armor 1 both multiply by 1. This changes only the score: those enemies still take full damage
from every hit, and the armor stat is unchanged.

**Bosses rank above every non-boss (decided)**, whatever their score (Rampart scores higher than the
Dreadnought below).

| Enemy | HP | Speed | Armor | Str |
|---|---|---|---|---|
| Nanite | 22 | 78 | 0 | 13.38 |
| Drone | 70 | 55 | 0 | 21.18 |
| Locust | 18 | 115 | 0 | 23.80 |
| Repair Bot | 125 | 50 | 1 | 31.25 |
| Jammer | 150 | 50 | 1 | 37.50 |
| Strike Drone | 64 | 82 | 0 | 43.03 |
| Phantom | 85 | 72 | 0 | 44.06 |
| Skitter | 45 | 105 | 0 | 49.61 |
| Blink Stalker | 110 | 70 | 1 | 53.90 |
| Aegis Walker | 150 | 44 | 2 | 58.08 |
| Rally Beacon | 170 | 48 | 2 | 78.34 |
| Bulwark | 200 | 42 | 3 | 105.84 |
| Hydra Frame | 190 | 46 | 3 | 120.61 |
| Burrower | 160 | 62 | 2 | 123.01 |
| Mender Hulk | 380 | 38 | 3 | 164.62 |
| Siege Mech | 265 | 40 | 6 | 254.40 |
| Gunship | 420 | 42 | 5 | 370.44 |
| Dreadnought (boss) | 800 | 32 | 5 | 409.60 |
| Rampart | 520 | 34 | 8 | 480.90 |
| Overmind (boss) | 1,900 | 20 | 10 | 760.00 |
| Leviathan (boss) | 2,600 | 24 | 6 | 898.56 |
| Colossus (boss) | 4,200 | 18 | 14 | 1,905.12 |

What it shows:
- Squaring speed rewards fast units: Locust (flyer, 23.80) now outranks the basic Drone (21.18), and
  Skitter (49.61) outranks Strike Drone (43.03).
- Support units rank low: Repair Bot (31.25) sits below Skitter. The score ignores abilities, so a
  Support unit never ranks high under Strongest, which was one of the original complaints.
- Rampart (480.90) outscores the Dreadnought boss (409.60), hence the boss rule.
- Armor is flat damage removed per hit, and today's values run 0 to 14, so the score is a proxy. A
  different armor scale (the example uses 50) would change every rank.

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
  Swarming (double count, half HP), Resolute (resists slow and stun), Commanding (aura). Each names its
  counter in the Codex. **Volatile is shelved** (below).
- **Cloaked** is a modifier for any enemy, alongside the Phantom's built-in cloak. **Splitting** may
  become a modifier too.
- **Stacking and start round (decided):** set by balancing checks. The aim is a healthy mix of
  modifiers in the later rounds. Whether Easy has none is left to the same checks.
- **Resolute has no counter, by design (decided):** it is a balancing tool.
- **Volatile is shelved (decided).** For now towers are never destroyed or disabled by a modifier. It may
  return later, or become its own game mode.
- **Swarming** (double count, half HP) acts on a group, so it doesn't fit "single elites only". Its
  ruling is deferred.

### Round scaling (decided)

Per-round HP scaling is **lowered**, so late difficulty comes from the tier mix and from elites. The
exact curve is set with the balance probe.

### Waves (decided)

- **One generator makes every round** (owner direction). It replaces the hand-authored rounds 1 to 25 in
  `data/waves.gd` as well as rounds 26 and up, and it keeps going for Endless. It **starts fresh**: it
  does not reproduce today's rounds.
- **Boss rounds are every 20 rounds** (20, 40, 60, 80, 100, 120). Each mode's last round (40, 60, 80, 100,
  and Cataclysm's 120) already falls on one. Today's Dreadnought every 5th round and the other recurring
  bosses are replaced by this cadence.
- **Identical on every playthrough:** it is seeded by the round number alone, not the run's random seed.
- **Introduction rounds are baked in as data** for each new tier, each elite kind and each modifier, so a
  new threat always appears on a known round. Today's `INTRO` table (e.g. Rampart at round 40) is the
  model. Modifiers and elites get their own entries.
- Because rounds 1 to 25 change, the wave tests and the Easy and Medium bot playthroughs are re-pinned,
  and the balance probe checks every mode.

### 5. Leak costs (closes #7)

Leak cost follows **strength** (owner: stronger enemies drain more shields): a base cost per strength
band, derived from the rank formula, +1 for elites, and bosses a fixed share of the
mode's shields (so Cataclysm's single shield still works). Checked with the balance probe on every
difficulty.

### 6. Bosses

Keep the four bosses. Give each a clearer kit built from the same traits, at the top of the ranked
list.

### 7. New enemies (draft roster)

The owner asked for three kinds: tiers for thin roles, enemies that trick targeting, and higher
tiers so difficulty comes from the tier mix and not only from HP scaling. **Names are placeholders.**
Role, tier, job and counter are a draft. **Stats for every current and proposed enemy are in
`design/enemy_roster.md`.** Each is built from the trait registry and has no modifiers by default.

| Placeholder | Role / tier | Gap it fills | Job | Counter |
|---|---|---|---|---|
| Dart | Rusher T3 | Thin role | Very fast, light hull; arrives in pairs | Slows, fast-firing towers |
| Interceptor | Rusher T4 | Higher tier | Fast with light armor; speeds up when damaged | Burst, armor shred |
| Siphon | Disruptor T2 | Thin role | Aura lowers the fire rate of nearby towers instead of switching them off | Range, focus fire |
| Blackout Rig | Disruptor T3 | Thin role / higher tier | Armored Jammer with a larger EMP radius and a shorter cycle | Long range, burst |
| Razor Swarm | Swarm T4 | Higher tier | Dense swarm of tougher small units | Splash and chain upgrades |
| Titan | Tank T4 | Higher tier | Heaviest non-boss hull, between Rampart and the bosses | % damage, armor shred |
| Surge Core | Disruptor T4 | Higher tier | Largest EMP radius and longest disable of the Disruptors | Long range, burst |
| Slipstream | Evader T3 | Higher tier | Burrows and blinks in one body | Sensors, area |
| Wraith | Evader T4 | Higher tier | Cloaked; visible for a moment after each blink | Sensors, area |
| Mimic | Evader or Special | Targeting trick | Shows a low rank (looks like T1) until first hit or below a set HP, then shows its real higher rank | Area damage reveals it early; First targeting |
| Decoy Beacon | Special | Targeting trick | Shows a false high strength rank so Strongest towers aim at it while others get past; armored, does nothing else | Switch towers to First, splash |
| Echo | Special | Targeting trick | Puts out hologram copies with the same rank and 1 HP that use up shots | Area and chain, sensors |

Nexus (Support T5) is cut: Support already has four tiers. The "22 enemy types" test count changes when
these land (phase 4).

### 8. Presentation and tools

- Intel, the NEXT strip and the Codex show role, tier and modifiers. The Codex PDF is regenerated.
- **Sandbox Spawner:** pick a role-tier and any modifier, so every combination can be tested.
- **Balance probe:** switches for modifiers and the tier table.

## Phasing

Separate PRs, each confirmed by the owner:

1. Role, tier and strength-rank data, plus the trait registry and per-trait timers. No gameplay change.
2. Strongest targeting by strength rank, plus the Support/Special priority (with tests and Codex text).
3. Modifier engine, wave generation (rounds identical on every playthrough, see Open questions) and
   the Intel UI.
4. Roster changes and rebalance: tiers, new enemies, leak costs, boss kits.
5. Codex, Sandbox picker and probe support.

## Out of scope

Game code in this PR. Only this doc changes.


## Open questions

Reviewed by the owner on 2026-10-07 (two rounds). Numbers match the first draft's question numbers where
they exist.

### Decided

- **Q1 Tier count:** four tiers for every regular role; Special and Boss are named exceptions; the draft
  Nexus (Support T5) is cut or folded into T4.
- **Q2 Tier scaling:** each tier has a flat HP and speed stat.
- **Q4 Strongest ties:** rank comes from a formula over base HP, armor and speed, with armor 0 counted as 1,
  so ties are rare. Stronger
  enemies also drain more shields. The formula itself is under Still open.
- **Q5 Phantom:** keeps its built-in cloak as a specialized enemy; Cloaked is also a modifier for any
  enemy.
- **Q6 Specials:** they stay specials. Splitting may become a modifier.
- **Q7 Modifiers and rank:** depends on the modifier.
- **Q8 Stacking:** set by balancing checks. Later rounds should have a healthy mix of modifiers.
- **Q9 Where modifiers go:** single elites.
- **Q10 Counters:** Resolute gets no counter, as a balancing tool. Small tower or research counters are
  allowed where a modifier needs one (Cloaked), each in its own PR the owner approves.
- **Boss above all:** bosses rank above every non-boss, whatever their score.
- **Volatile:** shelved. Towers are not destroyed or disabled for now; it may return later or become its
  own game mode.
- **Support and Special priority:** a new target priority for Support and Special enemies, not a score
  bonus.
- **Rounds 1 to 25:** the generator starts fresh and does not reproduce today's rounds.
- **Boss rounds:** every 20 rounds.
- **Old saves:** an old save's remaining rounds change once at the update. Accepted.
- **Roster placements and draft stats:** acceptable for now. The order is subject to change with
  balancing tweaks and stat changes. The owner's adjusted tier grid (Locust Swarm T2, Drone T3; Skitter
  Rusher T1, Strike Drone T3; Rampart Tank T2, Gunship T3) is in `design/enemy_roster.md`.
- **Q13 Roster file:** the current and proposed enemies live in `design/enemy_roster.md`, with stats.
- **Q11 Saves and waves:** one generator makes every round, identical on every playthrough, seeded by
  the round number alone, with introduction rounds baked in for new tiers, elites and modifiers. It goes
  on forever for Endless. Modifiers need no new save field and no version bump. See "Waves" in section 4.
- **Q14 HP scaling:** lowered.
- **Q16 Mimic and Decoy:** the field label hides the true rank until revealed, and the Codex states each
  trick plainly. The Codex "seen enemies" tracking is unchecked.
- **Wraith (energy-only damage):** needs a physical/energy tag on every tower, a new system. It becomes
  a separate PR after the core rework; until then Wraith is a draft idea.
- **Swarming:** ruling deferred.

### Still open

1. **Support and Special priority: details.** The game already has a per-tower priority (Any, Air,
   Ground). **Recommendation:** add a fourth entry (e.g. "Support") to `Tower.PRIORITY_NAMES`, so it
   uses the existing cycle button and needs no save version bump (old saves load with their stored
   value). Questions: does "Special" include Phantom, Aegis Walker, Hydra Frame and the new Mimic, Decoy
   Beacon and Echo? **Recommendation:** yes, and it goes by the enemy's *displayed* identity, so Mimic and
   Decoy tricks still work until revealed. Which mode (First, Strongest...) orders targets inside the
   priority? **Recommendation:** the tower's current mode.
2. **Boss rounds: details.** Every 20 rounds. Which boss comes on which boss round (20, 40, 60, 80, 100,
   120)? Does the Dreadnought stop appearing every 5th round? Do the existing finales (e.g. round 40:
   two Dreadnoughts, a Leviathan, an Overmind) stay as the 40th-round boss wave?
   **Recommendation:** Dreadnought at 20, then the finales as they are, adding Colossus and Overmind
   appearances so each boss round is bigger than the last.
3. **Generator acceptance.** Starting fresh means no old rounds to compare against. **Recommendation:**
   accept it when (a) the Easy and Medium bot playthroughs still earn medals, (b) the balance probe shows
   a smooth difficulty curve on every mode, and (c) a fixed seed-free check shows identical rounds each
   run.
4. **Leak-cost bands.** The strength score sets leak cost, so its bands need a mapping (e.g. score bands to
   1, 2, 3 shields, bosses a fixed share). Proposed with the balance probe in phase 4.

### Deferred

To be settled later or during implementation, as the owner said:

- **Q3** Global ranked list as a hand-ordered table (replaced by the formula; its bands and the mapping
  stay open).
- **Q12** Other enemies or mechanics (ranged, tower killers, lane blockers, other routes).
- **Q15** The exact introduction round for each new tier, elite kind and modifier (the mechanism is decided,
  the numbers are tuned during implementation).
- **Q17** Whether Drone and Strike Drone need roles of their own, such as Line and Flyer.
- **Swarming** ruling.
- **Volatile**, if it returns, and any mode where towers can be destroyed.
- **Damage types** (physical vs energy) and the Wraith that depends on them.
