# Bastion Line New Enemies (design)

Design sheets for the new enemies in the enemy rework (`design/enemies.md`, issue #53). Stats for every
enemy, current and proposed, are in `design/enemy_roster.md`; this file holds how the new ones **behave and
look**. Designed with the owner in question rounds. **Draft: nothing here is built, and no game code or data
changes until the owner confirms the spec.**

## Status

| Round | Enemies | State |
|---|---|---|
| 1 | Needle, Fury Drone, Shrike, Titan (the stat enemies) | Designed below |
| 2 | Siphon, Blackout Rig, Capacitor (Disruptors) | Designed below |
| 3 | Shifter, Wraith (Evaders) | Designed below (Wraith parked until the damage-type PR) |
| 4 | Masquerade, Decoy Beacon, Mirage (targeting tricks) | Designed below |
| Look | All twelve | Visual mockup: `design/new_enemies_mockup.html` |

**Visual mockup.** `design/new_enemies_mockup.html` draws every new enemy with a canvas port of the game's own
drawing helpers (`Draw.gd`), next to its role's existing enemies, at game scale (1x on a 48 px tile) and 3x.
Each card plays its key moment, and Print view lays out key frames. It also shows the tower feedback, the trick
tells, the evasion states and the elite ring. Open it in a browser. **Draft radii** (px) are set there:
Needle 8, Fury Drone 10, Shrike 7, Titan 18, Siphon 12, Blackout Rig 14, Capacitor 15, Shifter 11, Wraith 12,
Masquerade 13, Decoy Beacon 15, Mirage 11.

## Rules shared by all new enemies

- **Strength:** Str = spd² (arm x hp), spd = speed / 100, armor 0 counted as 1. It sets Strongest targeting
  and, by band, the leak cost.
- **No modifier by default.** Modifiers go on single elites only.
- **Round scaling:** base stats scale like every enemy (lowered HP scaling, speed capped at +50%).
- **Leak cost** follows strength bands per unit, even for clusters. The bands are not defined yet.
- **Introduction rounds** are set in the wave-generator PR; the mechanism is decided, the numbers are tuned
  there.
- **Disable guard (Disruptors):** after a tower comes back online it can't be disabled again for **1 s**, so
  overlapping EMPs (Jammer, Blackout Rig, Capacitor) can't lock a tower out. It applies to the existing
  Jammer too, like the stun guard on enemies.
- **Tower feedback:** a tower that is debuffed or disabled gets a violet tint and a small icon (range-down and
  rate-down arrows for Siphon, a bolt for disabled), and the enemy's aura ring shows on the field. It is
  drawn only while affected, so it costs nothing otherwise.
- **Not built from scratch:** each is a body (HP, speed, size) plus traits from the registry in the spec
  (section 3). Needle and Shrike have no traits; Fury Drone and Titan each add one.

## Round 1: the stat enemies

### Needle (Rusher T2)

*Placeholder name: Dart.*

| HP | Speed | Armor | Fly | Str | Leak | Bounty |
|---|---|---|---|---|---|---|
| 30 | 140 | 0 | No | 58.80 | 1 | 5 |

- **Behaviour:** each spawn event sends **two Needles 0.25 s apart on the same lane**. No ability.
- **Job:** slip past before single-target towers land a shot. A pair doubles the problem.
- **Counters:** slows, splash and chain, rapid-fire towers.
- **Look:** a slim chevron, chalk-white accent on a dark cool hull (Skitter's accent is amber and Phantom's
  cyan, so they read apart). The pair keeps a tight formation. One short high-pitched whine per spawn.
- **Codex text (draft):** "Hair-thin sprinter that always arrives in pairs. Single-target towers can't keep
  up. Slows, splash and rapid fire can."
- **Edge cases:** lanes alternate by spawn group as in normal waves, and the pair shares a lane. Rally Beacon
  haste applies as to any non-boss. Not a flyer, so mortars and ground-only towers hit it.

### Fury Drone (Rusher T4)

*Placeholder name: Interceptor.*

| HP | Speed | Armor | Fly | Str | Leak | Bounty |
|---|---|---|---|---|---|---|
| 85 | 125 | 1 | No | 132.81 | 2 | 9 |

- **Behaviour (adrenaline):** below **50% health** it moves **30% faster**. One clear threshold, no stacking.
- **Speed stacking:** adrenaline and Rally Beacon's +25% haste **multiply**. A Fury Drone under a Beacon is
  1.30 x 1.25 = **+62.5%**, which makes "Beacon plus Fury Drone" a deliberate kill-first pair. In code the
  movement is `speed x (1 - slow) x (1 + haste)`, and the Beacon's haste is a single value (`Enemy.haste`);
  adrenaline is a **separate multiplier** so the two compound.
- **Job:** punish chip damage. Burst kills it before it matters; many weak hits make it faster.
- **Counters:** burst and armor shred. Slows still apply on top of the boosts.
- **Look:** an angular hunter drone, hot magenta accent (Strike Drone is red, Blink Stalker violet, Skitter amber). Below half health the
  engine glow turns white-hot and a short speed trail appears (an animated part, so inside `Draw.dyn`). A
  rising rev sound plays once when adrenaline starts.
- **Codex text (draft):** "Hunter drone that overclocks when hurt: below half health it runs 30% faster.
  Kill it in one burst, and watch for Rally Beacons, because the boosts multiply."
- **Edge cases:** adrenaline starts once and can't be undone by healing above 50% (Repair Bot, Mender Hulk).
  Not a boss, so Rally Beacon haste applies.

### Shrike (Swarm T4)

*Placeholder name: Razor Swarm.*

| HP | Speed | Armor | Fly | Str | Leak | Bounty |
|---|---|---|---|---|---|---|
| 55 | 90 | 0 | **Yes** | 44.55 | 2 | 3 |

- **Behaviour:** a **flying cluster**: **5 units per spawn event, 0.15 s apart**. No ability. They fly
  straight at the core like Locust and Strike Drone, ignoring the lane.
- **Job:** a stronger Locust. Locust is 15 HP, Shrike 55 HP, so it takes more than one flak burst.
- **Counters:** flak and chain towers pay off most; only anti-air can touch it, and **mortars can't hit it**.
- **Look:** winged blade silhouettes in steel grey with a teal accent edge, flapping as a tight cluster (an
  animated part, inside `Draw.dyn`). A faint buzz for the cluster, not per unit.
- **Codex text (draft):** "Winged blade clusters, five at a time, flying straight at the core. Mortars can't
  hit them. Flak and chain towers shred them."
- **Edge cases:** leak cost is **per unit by strength band**, as the spec says. At the draft band of 2, one
  leaking cluster costs 10 shields (a Shrike cluster is harsh on Hard, Nightmare and Cataclysm). This is
  flagged for balancing; the bands are not defined yet. Flyers ignore ground-only towers.

### Titan (Tank T4)

| HP | Speed | Armor | Fly | Str | Leak | Bounty |
|---|---|---|---|---|---|---|
| 700 | 30 | 9 | No | 567.00 | 4 | 24 |

- **Behaviour:** 50% slow resist. At **50% health its plates shed**: **armor 9 to 5** and **speed +20%**.
  The shed happens once.
- **Why 700 HP:** the first boss, Dreadnought, has 800 HP at armor 5. The Titan stays tougher than Rampart
  and Gunship but below the bosses.
- **Job:** soak damage, then turn into a faster, easier-to-hurt target.
- **Counters:** armor shred, big hitters and beams before the shed; burst and slows after it.
- **Look:** a broad gunmetal walker with visible plates and molten orange vents. At half health 2 or 3 plate
  polygons fall away (a one-shot effect) and the vents flare. A heavy thud on the shed.
- **Codex text (draft):** "Walking fortress with 9 armor and half resistance to slows. At half health its plates
  shed: armor drops to 5, but it speeds up 20%. Bring armor shredders and big hitters."
- **Edge cases:** healing above 50% doesn't restore plates. The speed bump is a plain speed change, so slows
  and Rally Beacon haste combine with it as normal. Not a boss.

## Round 2: the Disruptors

The Jammer today (`data/enemies.gd`): 150 HP, speed 50, armor 1, EMP radius 95, towers offline 2 s every 5 s
(a 40% duty cycle). Its EMP sets `t.disabled` on every tower in radius (`Game._update_enemy`) and doesn't
run while the enemy is silenced (`silenced(2)`). The new Disruptors follow it up in tier order: Siphon (T2),
Blackout Rig (T3), Capacitor (T4).

### Siphon (Disruptor T2)

| HP | Speed | Armor | Fly | Str | Leak | Bounty |
|---|---|---|---|---|---|---|
| 190 | 52 | 2 | No | 102.75 | 2 | 12 |

- **Behaviour:** an aura of **radius 100**. Towers inside it **fire 20% slower** and have **15% less range**
  for as long as the Siphon is alive and not silenced. **Two Siphons don't add: the strongest applies**, the
  way Rally Beacon and Nova auras use the larger value.
- **Job:** weaken a defence without switching it off, so it is quieter than the Jammer but wears down every
  tower it walks past.
- **Counters:** range (kill it before it comes within 100 px of your towers), burst, focus first. A Nullifier
  silences the aura.
- **Implementation:** towers already have `buff_rate` and `buff_range`, reset each tick and read in
  `Tower.eff_rate()` and `Tower.get_range()`. The debuff adds two small fields (`debuff_rate`,
  `debuff_range`), reset each tick the same way, set by an aura pass like `Game._update_auras`, and applied
  after the buffs.
- **Look:** a hovering drone with a coil dish, in the Disruptor palette (the Jammer's acid yellow-green).
  Thin siphon arcs to affected towers are an animated part (inside `Draw.dyn`). A low hum while any tower is
  affected.
- **Codex text (draft):** "Drains nearby towers: inside its 100 px aura they fire 20% slower and reach 15%
  less far. Two Siphons don't stack. Kill it from range."
- **Edge cases:** reduced range can drop a target out of reach. Flying enemies and bosses aren't affected as
  enemies (the aura only touches towers). Towers with no range stat are unaffected.

### Blackout Rig (Disruptor T3)

| HP | Speed | Armor | Fly | Str | Leak | Bounty |
|---|---|---|---|---|---|---|
| 260 | 48 | 3 | No | 179.71 | 3 | 15 |

- **Behaviour:** a **bigger Jammer**: EMP **radius 130**, towers offline **2.5 s every 4 s** (a 62.5% duty
  cycle). The same code path as the Jammer with new numbers, so it is data only.
- **Job:** switch off a cluster of towers for most of its walk. The heaviest of the three Disruptors.
- **Counters:** long range, burst; a Nullifier silences the pulse. The 1 s disable guard stops it locking a
  tower out together with a Jammer.
- **Look:** a Jammer-family chassis, bulkier, with exposed pylons and brighter arcs (the same acid
  yellow-green). The existing EMP ring effect, scaled to radius 130.
- **Codex text (draft):** "A hulking Jammer. Its EMP reaches 130 px and knocks towers offline for 2.5 s every
  4 s. Kill it from range."
- **Edge cases:** it is not a boss, so Rally Beacon haste applies. A 62.5% duty cycle is flagged for
  balancing.

### Capacitor (Disruptor T4)

*Placeholder name: Surge Core.*

| HP | Speed | Armor | Fly | Str | Leak | Bounty |
|---|---|---|---|---|---|---|
| 420 | 44 | 4 | No | 325.25 | 3 | 20 |

- **Behaviour (charge and release):** it shows a **2 s charge ring**, then pulses **radius 160**, taking
  towers offline for **3 s**, once every **8 s**. **Silencing, stunning or killing it during the charge
  cancels the pulse.**
- **Job:** a big, telegraphed blackout the player can answer in time.
- **Counters:** a stun or a Nullifier silence during the charge; burst; long range.
- **Implementation:** a charge state (timer plus telegraph ring) and a cancel check on silence, stun and
  death, next to the existing EMP code.
- **Duty cycle:** 3 s of every 8 is **37.5%**, lower than the Blackout Rig's 62.5%, on purpose: the pulse is
  bigger and telegraphed. Flagged for balancing.
- **Look:** a squat core with a ring that fills during the charge in the Disruptor palette and flashes white
  on release. A rising whine while it charges and a heavy discharge sound.
- **Codex text (draft):** "Charges for 2 s, then blacks out every tower within 160 px for 3 s. Stun or silence
  it during the charge to cancel the pulse."
- **Edge cases:** if two Capacitors charge together, each pulses on its own timer, and the 1 s disable guard
  applies to the second. It is not a boss.

## Round 3: the Evaders

Today's Evaders (`data/enemies.gd`): Blink Stalker (T1, blinks 80 px every 4 s; a slow or stun resets the
charge) and Burrower (T2, burrowed 2.5 s every 5 s: untargetable, hazard-proof, can't be shoved; a Sensor
Array "disrupt" or a silence forces it up). Cloaked enemies (the Phantom) are hidden until a Sensor Array
reveals them (`Enemy.is_hidden()`). The two new Evaders extend the role in tier order: Shifter (T3), Wraith (T4).

### Shifter (Evader T3)

*Placeholder name: Slipstream.*

| HP | Speed | Armor | Fly | Str | Leak | Bounty |
|---|---|---|---|---|---|---|
| 200 | 68 | 2 | No | 184.96 | 2 | 13 |

- **Behaviour:** blinks **60 px** down the lane **every 5 s**. Each blink releases a **wake burst of radius
  80 px at the landing point**: non-boss enemies inside get **+20% speed for 2 s**. The Shifter itself is
  not boosted.
- **Stacking:** the wake multiplies with other speed boosts (Rally Beacon, Fury Drone's adrenaline), as
  decided for adrenaline. A second wake refreshes the 2 s and doesn't add; several Shifters don't stack.
- **Job:** a Support-adjacent Evader: it dodges single-target fire and speeds the group up behind it.
- **Counters:** slows and stuns reset its blink charge (the existing Blink Stalker rule, `_reset_blink`),
  silence stops the blink, and killing it before it blinks removes the boost.
- **Look:** a lean angular walker with a faint afterimage, in a white-gold accent (the Evaders already use
  cyan, violet and orange). The wake burst is a one-shot expanding ring at the landing point. A soft
  whoosh on each blink.
- **Codex text (draft):** "Blinks 60 px every 5 s and speeds up nearby enemies by 20% for 2 s where it
  lands. Slow or stun it to reset its charge."
- **Edge cases:** bosses aren't boosted (as with Rally Beacon). The burst ignores flying status of the
  enemies it boosts. It is a ground enemy and can be hit while it walks. Not a boss.

### Wraith (Evader T4)

| HP | Speed | Armor | Fly | Str | Leak | Bounty |
|---|---|---|---|---|---|---|
| 260 | 74 | 2 | No | 284.75 | 3 | 18 |

**Parked:** the Wraith needs damage types, which are a separate PR after the core rework. It is designed here
and not built first; until then **Evader T4 stays empty**. The other three Tier 4 enemies ship without it.

- **Behaviour:** two evasions, **no blink**:
  - **Cloaked** (the Phantom's rule): towers can target it only inside a Sensor Array field, or for a moment
    after it takes damage.
  - **Energy only:** it is **immune to physical damage** (takes 0) and is hurt only by energy damage.
- **What counts as energy (decided):** every **non-projectile tower** (beam, chain and field towers), plus
  **burn and damage-over-time** effects and **Arc Coils**, which always bypass the immunity. Projectile and
  blast towers (for example Pulse Turret, Plasma Mortar, Railgun) are physical. The tower-by-tower list,
  including edge cases such as drones, is settled in the damage-type PR.
- **Job:** force a defence to carry energy towers. A defence of only projectile and blast towers can't kill it
  (the owner's intent: "build energy towers").
- **Counters:** Arc Coils, beam and field towers, burn and damage-over-time, and a Sensor Array to see it.
  Slows from field towers still apply.
- **Look:** a dark indigo hull that is nearly invisible until revealed, then a ghostly white outline, using
  the Phantom's cloak shimmer. A faint hiss while visible.
- **Codex text (draft):** "Cloaked and immune to physical damage. Only energy hurts it: beams, chains, fields,
  burning and Arc Coils. Bring a Sensor Array to see it."
- **Edge cases:** physical hits do 0 damage and don't reveal it (the reveal-on-damage rule fires only for
  damage it actually takes). Introduce it only after players can reasonably own an energy tower.
  Armor is irrelevant to the immunity. Not a boss.
- **Dependency:** a damage-type tag on every damage event and tower, and an `energy_only` trait. That is a
  separate PR with its own design.

## Round 4: the targeting tricks

These three are **Specials** (no tiers) that play with what a tower believes about an enemy. Strongest
targeting reads an enemy's strength in one place, `Game._score` (`e.hp` today, strength rank in the
rework), and `Game.pick_target` already filters by the tower's priority (Any, Air, Ground). The tricks add a
**displayed strength** and a **displayed role** that those two read instead of the true values, until the
trick is revealed.

### Shared rules for the tricks

- **Displayed vs true:** Strongest targeting and the new **Support priority both go by the displayed
  identity** (decided), so a disguise works until it is revealed. First, Last and Closest don't read rank,
  so they are never fooled.
- **A subtle tell:** a disguised enemy (Masquerade, Decoy Beacon) carries a thin **dotted ring**; the shape
  is the tell, so the colour follows the hull. The Codex states each trick plainly (decided earlier), and a
  player who has met one can spot it.
- **Revealing early:** a **specific new Sensor Array upgrade** reveals the true rank and identity of tricks
  inside its field and marks holograms as fake. It is **not** part of the base Sensor Array. Its name, tree
  position and cost are for its own PR (the upgrade trees are generated from `design/upgrade_trees.md`).
- **Intel and Codex:** the field label shows the displayed identity until revealed.

### Masquerade (Special)

*Placeholder name: Mimic.*

| HP | Speed | Armor | Fly | True Str | Shown as | Leak | Bounty |
|---|---|---|---|---|---|---|---|
| 320 | 60 | 3 | No | 345.60 | A T1 (Nanite-class, about 13) | 2 | 14 |

- **Behaviour:** it shows a **low, T1-class strength** and a T1-class role, so Strongest and the
  Support priority ignore it. It keeps the disguise **until it drops below 50% health**, then shows its
  real rank and role (a short flash and a label change).
- **Job:** soak real damage while looking harmless; it punishes defences that rely on Strongest.
- **Counters:** First, Last or Closest targeting, area damage that happens to hit it, and the Sensor Array
  upgrade. Once below half health it is an ordinary Special.
- **Look:** drawn with a Nanite-style hull on its own (larger) body, so its size is a second tell, plus the
  dotted ring. When revealed the disguise peels away to its true hull (a one-shot effect). A glassy crack on
  reveal.
- **Codex text (draft):** "Looks like a basic unit and ranks like one, so Strongest targeting ignores it.
  Below half health it drops the disguise. Use First or Closest targeting, or a Sensor Array upgrade, to see
  it."
- **Edge cases:** the 50% threshold is a one-way change (healing above it doesn't re-disguise it). Rally
  Beacon haste applies. Not a boss. Strongest ties: it uses its displayed strength until revealed.

### Decoy Beacon (Special)

| HP | Speed | Armor | Fly | True Str | Shown as | Leak | Bounty |
|---|---|---|---|---|---|---|---|
| 400 | 36 | 6 | No | 311.04 | Above every non-boss, below bosses | 1 | 10 |

- **Behaviour:** it **fakes a high strength**, above every non-boss and below the bosses, and **never stops**
  until it dies or the Sensor upgrade reveals it. It does nothing else. It draws as a heavy hull and shows
  as a Tank-class role.
- **Job:** bait: Strongest towers waste fire on it while the real threats walk past.
- **Counters:** switch the tower to First, Last or Closest, kill it (it has real HP and armor 6), or the
  Sensor Array upgrade.
- **Look:** a heavy, slow gunmetal hull with a beacon mast and the dotted ring. A low ping every few seconds
  (the "beacon").
- **Codex text (draft):** "Ranks as a heavy unit so Strongest towers aim at it, but it does nothing else.
  Switch tower targeting, or kill it, to stop wasting fire."
- **Edge cases:** because it displays below the bosses, real bosses keep their priority. It leaks for 1
  shield (it is harmless). Not a boss.

### Mirage (Special)

*Placeholder name: Echo.*

| HP | Speed | Armor | Fly | Str | Leak | Bounty |
|---|---|---|---|---|---|---|
| 140 | 55 | 1 | No | 42.35 | 2 | 12 |

- **Behaviour:** every **6 s** it projects **2 holograms**: translucent copies (**1 HP**) that **walk to the
  core and vanish there**. They **never leak**, cost no shields and give no bounty. They show the Mirage's own
  displayed rank. Any hit kills one, so splash and chain clear several at once.
- **Job:** a shot sink: towers waste shots on 1-HP copies.
- **Counters:** area and chain towers, and the Sensor Array upgrade, which marks holograms as fake.
- **Look:** a projector dish; the holograms are a translucent copy of the Mirage with a scanline (an alpha
  plus a line, cheap to draw). A soft chime per pair.
- **Codex text (draft):** "Projects two translucent copies every 6 s that soak shots and walk to the core. A
  single hit kills one. Splash and chain towers clear them."
- **Edge cases:** holograms are live enemies until they vanish at the core, so a round does not end while any
  are walking. They are ground units and can take hazards. Because the Mirage is a Special, the
  Support priority (Support role only) ignores it and its holograms.

## Implementation notes (for when the spec is confirmed)

- **Registry:** all four go in `data/enemies.gd` (`ORDER` and `ENEMIES`). The "22 enemy types" test count
  becomes 26 with the round-1 four, 29 after round 2 and 30 with Shifter, 33 with the three tricks (and 34 if a hologram is its own type; 31 or more when the parked Wraith lands), plus per-trait tests (pair spawn, adrenaline, plate shed,
  flying cluster, Siphon aura debuff and strongest-wins, Capacitor charge cancel, disable guard).
- **Drawing:** follow the performance rules (`Draw.disc`, `ring`, `poly`, `polyline`; animated parts in
  `Draw.dyn`). Screenshots go to the owner for review.
- **Tricks:** the enemy gets `shown_str` and `shown_role` read by `Game._score` (Strongest) and the
  Support priority in `pick_target`; a hologram is a lightweight enemy (no leak, no bounty, dies to any
  damage). Tests: Strongest ignores a Masquerade until half health; a Decoy outranks non-bosses but not bosses;
  a hologram never leaks or pays; the round waits for holograms; the Sensor upgrade reveals tricks; the
  priority uses displayed identity.
- **Sandbox Spawner:** new enemies appear in its grid once registered.
- **Saves:** enemies aren't saved, so there is no save bump.
- **Codex:** entries and the Codex PDF are regenerated in phase 5.

## Open questions

1. **Shrike cluster leak.** At the draft band of 2 shields per unit a cluster that leaks costs 10. Keep it,
   or raise it at the leak-band mapping (phase 4)?
2. **Threat costs.** What each enemy costs the wave generator is set with the balance probe in the
   generator PR.
3. **Introduction rounds.** The first round for Needle, Fury Drone, Shrike and Titan (Titan likely not
   before the 20th-round boss cadence matters).
4. **Disruptor numbers.** Siphon's -20% fire rate and -15% range, the Blackout Rig's 62.5% duty cycle and the
   Capacitor's 37.5% are tuned with the balance probe.
5. **Jamming modifier.** Does the Jamming modifier (any elite) reuse the Jammer's EMP, a Siphon aura, or let
   the wave generator choose?
6. **Energy classification.** The tower-by-tower energy list, including edge towers (drones, scrap, Nova) and
   Pulse Turret (its blurb says "energy bolts" but it is a projectile), is the damage-type PR's job.
7. **Wraith introduction.** The first round it appears, after players can own an energy tower, set in the
   generator PR.
8. **Hologram displayed rank.** Draft: a hologram copies the Mirage's own (low) displayed rank, so it baits
   First and Closest more than Strongest. Or give holograms a high fake rank so they bait Strongest too?
9. **Holograms and their Mirage.** Draft: existing holograms vanish if their Mirage dies (they are
   projections). Or they keep walking?
10. **NEXT strip and Intel.** Do they list a trick enemy truthfully ("Masquerade") or as its disguise until
    revealed? The Codex states the tricks plainly either way.
11. **The Sensor Array upgrade.** Its name, position in the tree, cost and exact effect are for its own PR and
    your approval; the upgrade data is generated from `design/upgrade_trees.md`.
12. **Decoy and the Support priority (resolved).** The Support priority covers the Support role only, so it
    ignores every Special (Masquerade, Decoy Beacon, Mirage and its holograms). The tricks only fool Strongest.
13. **Trick tell vs Exposed.** The existing Exposed status is a dashed white ring that rotates around the enemy,
    so a dotted-ring tell for disguised enemies could be mistaken for it. The mockup shows both next to an
    alternative "glitch outline" tell (a split red/cyan double outline). Which tell should Masquerade and Decoy
    Beacon use?
14. **Mockup review.** Silhouettes, palettes, radii and key moments in `design/new_enemies_mockup.html` are
    drafts. Note: cloaked, the Wraith and the Phantom read alike (both are a faint wedge outline); the Wraith's
    tattered tail and white outline only show once revealed.
