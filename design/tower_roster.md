# Bastion Line Tower Roster (working roster)

The tower rework's working roster: **19 towers** (owner, 2026-10-14). Towers 1 to 17 are the owner's; the **Magneto
Tower** (18) and **Tractor Tower** (19) are Claude's proposals, added at the owner's request. It supports
`design/towers.md` (the rework spec); that spec holds the rules, this file holds the towers. Issue #55.

## How to read it

- **Class:** Assault, Support, Defense or Utility; **weapon type** is the descriptive sub-tag
  (`design/tower_classes.md`).
- **Paths:** the owner's three path purposes, in path order. Every tower has 3 paths of 4 upgrades and a mastery, and an
  optional tower-specific Retrofit (`design/towers.md`, Upgrade structure).
- **Owner's text** (description, quote, paths, notes) is verbatim from the roster page.
- **Design:** filled in tower by tower, in roster order, from question rounds with the owner (questions first). Until
  then it reads "not started".
- **Status:** roster only, in rounds, or designed (owner-confirmed).

## Summary

| # | Tower | Class | Weapon type | Paths | Status |
|---|---|---|---|---|---|
| 1 | Gun Turret | Assault | Ballistic | Power / Range/Visibility / Multi-Target | Designed (2026-10-15) |
| 2 | Mortar Tower | Assault | Explosive | Power/Penetration / Speed/Range / Blast Radius/Multi-Target | Draft, awaiting confirmation |
| 3 | Laser Tower | Assault | Energy | Power / Multi-Target / Range/Targeting | Designed (2026-10-15) |
| 4 | Rocket Salvo | Assault | Explosive | Power / Range/Target Acquisition / Reload/Payload | Designed (2026-10-15) |
| 5 | Anti-Aircraft Turret | Assault | Ballistic | Range / Power/Blast Radius / Speed | Designed (2026-10-15) |
| 6 | Artillery Cannon | Assault | Explosive | Power / Speed / Special Effects | Designed (2026-10-15) |
| 7 | Railgun | Assault | Ballistic | Power / Range/Speed / Special Effects | Designed (2026-10-15) |
| 8 | Tesla Tower | Assault | Energy | Power (Damage) / Range/Chaining / Speed | Designed (2026-10-15) |
| 9 | Drone Bay | Assault | Deployable | Power (overall) / Weaponry (upgrades/additions) / Speed | Designed (2026-10-15) |
| 10 | CAS Gunship | Assault | Deployable | Light gun / Medium gun / Heavy gun (owner, replacing Speed (Attack) / Power / Weaponry Upgrades) | Designed (2026-10-15) |
| 11 | Mine Layer | Defense | Explosive | Power/Damage / Production Speed / Range | Designed (2026-10-15) |
| 12 | Chemical Plant | Support | Chemical | Damage/Armor stripping / Speed / Slowing | Designed (2026-10-15) |
| 13 | Boost Tower (was Rally Beacon) | Support | None | Damage boost / Speed boost / Range Boost | Designed (2026-10-15) |
| 14 | Radar Tower | Utility | Energy | Power/Range / Speed/Frequency / Special Targeting | Designed (2026-10-15) |
| 15 | Cryo Tower | Support | Field | Slowing / Power/Range / Speed | Designed (2026-10-15) |
| 16 | Shockwave Generator | Assault | Field | Power/Range / Speed / Effect | Roster only |
| 17 | Scrapyard | Utility | None | Passive Income / Kill Income / Discounts | Roster only |
| 18 | Magneto Tower (Claude's proposal) | Defense | Field | Pull Strength / Field Size / Polarity | Roster only |
| 19 | Tractor Tower (Claude's proposal) | Defense | Energy | Pull Distance / Recharge / Grip | Roster only |

**By class:** Assault 11, Defense 3, Support 3, Utility 2.

## 1. Gun Turret

- **Class:** Assault. **Weapon type:** Ballistic.
- **Description (owner):** A basic rotating machine gun turret. "It's a machine gun, Private!"
- **Paths:** 1. Power; 2. Range/Visibility; 3. Multi-Target.

### Design

**Status: designed, confirmed by the owner (2026-10-15).** The choices under Decided and the stock stats are the
owner's; the costs come from the owner-accepted pricing formula. The upgrade effects are Claude's proposals, confirmed as the design; their numbers are tuned by the
balance probe.

**Decided (owner, 2026-10-14):**
- Hits **air and ground**; the all-rounder (the Anti-Aircraft Turret is the air specialist).
- The **cheap starter** tower.
- Fires **steady medium rounds:** fewer, harder hits than a classic machine gun, less hurt by armour.
- **Path 1 (Power)** leads to **armour-piercing rounds**; the mastery **ignores armour fully**.
- **Path 2 (Range/Visibility):** Visibility means **seeing further and tracers**, with no cloak rules; the mastery is
  **Precision Optics** (more range and critical hits).
- **Path 3 (Multi-Target):** more barrels on more targets, **3 targets** at the top.
- **Retrofit:** a **water-cooled barrel** (more fire rate).
- **Counters through its paths:** **armour (Tanks)** and **swarms and decoys**.

**Stock (owner, 2026-10-15):** **75 credits**; **16 damage, 130 range, 1.2 shots/s** (about 19 damage per second, close
to the Pulse Turret's 18, in fewer, harder hits). Air and ground.

**Retrofit, Water-Cooled Barrel:** **40 credits** (by the pricing formula; repriced from 150); fire rate 1.2 to 1.5/s.
Look: a thick cooling jacket around the barrel, with a small vapour wisp when it fires.

**Path 1, Power (armour-piercing):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Heavier Rounds | 55 | +6 damage |
| 2 | Hardened Tips | 40 | Its hits ignore 2 points of armour |
| 3 (primary) | AP Rounds | 405 | Ignores 50% of armour; +6 damage |
| 4 | Tungsten Core | 1,085 | Ignores 75% of armour; +8 damage |
| Mastery | Sabot Rounds | 2,475 | **Ignores armour fully**; 44 damage per hit |

**Path 2, Range/Visibility (precision):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Long Barrel | 25 | +20 range |
| 2 | Tracer Rounds | 60 | +10 range; 10% chance of a critical hit (double damage); visible tracer lines |
| 3 (primary) | Scope | 170 | +25 range; crit chance 15% |
| 4 | Rangefinder | 305 | +20 range; crit chance 20% |
| Mastery | Precision Optics | 980 | 230 range in all (+25); crit chance 30% |

**Path 3, Multi-Target:**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Swivel Mount | 15 | Switches to a new target instantly after a kill, and doesn't fire at enemies already about to die (no wasted rounds on swarms and holograms) |
| 2 | Side Gun | 165 | A small side gun fires at a second target at 50% damage |
| 3 (primary) | Twin Mount | 330 | **2 targets** at full damage |
| 4 | Belt Feed | 660 | +0.3 shots/s on every barrel |
| Mastery | Triple Mount | 3,300 | **3 targets**; the extra barrels go for the weakest enemies in range (swarms, holograms) |

**Combinations (primary + secondary capped at 2):**
- **Power + 2 Multi:** an AP main gun with a side gun for the small stuff.
- **Range + 2 Power:** a long-range critical-hit gun that bites through light armour.
- **Multi + 2 Power:** three barrels of heavier rounds that partly ignore armour: a swarm clearer that doesn't stall on
  light armour.

**Upgrade costs (owner, 2026-10-15): by the value-based pricing formula** (`design/towers.md`, Pricing), rounded to
5s and 0s. This replaced the owner's first fixed curve (100 / 250 / 600 / 1,200, mastery 2,500), so small upgrades are
cheap and the masteries are the big buys:
- Power: 55 / 40 / 405 / 1,085, mastery 2,475 (total 4,060).
- Range/Visibility: 25 / 60 / 170 / 305, mastery 980 (total 1,540).
- Multi-Target: 15 / 165 / 330 / 660, mastery 3,300 (total 4,470).
- A full build (75 + Retrofit 40 + a primary + 2 secondary steps) runs about 1,700 to 4,700 credits, depending on the
  paths.

**Counters:**
- **Armour (Tanks):** the Power path; Sabot Rounds hit Siege Mechs, Titans and armoured bosses at full damage.
- **Swarms and decoys:** the Multi-Target path. Swivel Mount stops overkill; Triple Mount's extra barrels go for the
  weakest enemies, so swarms and Mirage holograms (1 HP) pop without pulling the main gun off the real target.

**Edge cases:**
- **Flyers:** hits them at stock.
- **Cloaked enemies:** needs a reveal (the Radar Tower); Visibility doesn't see through cloak (owner).
- **The Wraith:** immune, since the Gun Turret is Ballistic (physical) under the enemy spec's parked energy-only rule.
- **Bosses:** no special rule; the Power path is its boss tool.
- **Critical hits** are new to the game (today no tower crits); they need a Codex line and a visual (a bigger hit
  spark).

**Look (for the art phase):** a compact rotating machine-gun turret with a single barrel, an ammo feed and a riveted
base. The Retrofit adds the cooling jacket. Per path:
- **Power:** a thicker barrel with an AP-shell feed.
- **Range:** a long barrel and a scope.
- **Multi-Target:** a side gun, then twin barrels, then a triple mount.

## 2. Mortar Tower

- **Class:** Assault. **Weapon type:** Explosive.
- **Description (owner):** Lobs high-explosive shells at nearby enemies. "Toob."
- **Paths:** 1. Power/Penetration; 2. Speed/Range; 3. Blast Radius/Multi-Target.

### Design

**Status: designed, confirmed by the owner (2026-10-15).** The choices under Decided are the owner's. The stock
stats and upgrade effects are Claude's proposals, confirmed as the design; the balance probe tunes their numbers. Prices come from the pricing formula
(`design/towers.md`, Pricing); the stock is tuned so its value matches the owner's 150-credit build cost.

**Decided (owner, 2026-10-15):**
- **Ground only.**
- **Short-range heavy splash:** close-in, big blasts on packed ground waves. The Rocket Salvo is the long-range
  multi-target tower, and the Artillery Cannon the huge-range aimed one.
- **150 credits** to build.
- **Path 1 (Power/Penetration):** both meanings. The steps crack armour; the top **digs in and hits burrowed enemies**.
- **Path 2 (Speed/Range):** **multiple barrels firing in succession, and further range.**
- **Path 3 (Blast Radius/Multi-Target):** **cluster shells.**
- **Retrofit:** all of them at once: reinforced baseplate, ranging sight and ammo rack.
- **Prices:** by the value formula, which the owner chose to apply to all towers.

**Stock (proposed):** 150 credits; 30 damage per shell, a 60 px blast, 110 range, 0.6 shells/s; ground only. Its value
matches the Gun Turret's credits per point: the Mortar does a little less single-target damage but hits a whole pack.

**Retrofit, Field Kit (proposed), 120:** a reinforced baseplate (+4 damage), a ranging sight (+10 range) and an ammo
rack (+0.05 shells/s, +5 px blast). Look: a heavy steel baseplate with sandbags, a sight on the tube, and a rack of
ready shells.

**Path 1, Power/Penetration:**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | HE Charge | 80 | +8 damage |
| 2 | Shaped Charge | 95 | Shells ignore 25% of armour |
| 3 (primary) | AP Shells | 685 | Ignore 50% of armour; +10 damage |
| 4 | Delayed Fuse | 1,350 | Ignore 75% of armour; +8 damage |
| Mastery | Bunker Buster | 3,140 | 64 damage; ignores 75% of armour; **shells dig in and hit burrowed enemies** inside Radar Tower range |

**Path 2, Speed/Range (more tubes, more reach):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Quick Reload | 50 | 0.6 to 0.7 shells/s |
| 2 | Extended Tube | 125 | +20 range (130) |
| 3 (primary) | Twin Tubes | 1,170 | A second tube firing in succession: 1.2 shells/s |
| 4 | Long Tubes | 1,405 | +20 range (150); 1.3 shells/s |
| Mastery | Barrage Battery | 6,165 | Three tubes firing in succession: 1.7 shells/s, 165 range |

**Path 3, Blast Radius/Multi-Target (cluster shells):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Bigger Charge | 30 | Blast 60 to 70 px |
| 2 | Wide Burst | 60 | Blast 80 px |
| 3 (primary) | Cluster Shells | 1,110 | Each shell also scatters 4 bomblets around the impact (10 damage, 30 px each) |
| 4 | Dense Cluster | 1,230 | 6 bomblets; blast 85 px |
| Mastery | Carpet Shells | 5,000 | 8 bomblets of 12 damage, 35 px each, spread wider; blast 90 px |

**Combinations (primary + secondary capped at 2):**
- **Power + 2 Speed:** heavy armour-cracking shells, a bit faster and further.
- **Speed + 2 Blast:** a rapid barrage of wide blasts. The anti-swarm build.
- **Blast + 2 Power:** cluster shells with armour-cracking main charges. Good against mixed packs.

**Counters:**
- **Armour:** the Power path.
- **Burrowers:** the Bunker Buster mastery hits them underground inside Radar Tower range (the enemy spec's rule).
- **Swarms, packs and the Hydra Frame's split:** the Blast path's cluster shells catch the Skitters as they burst out.

**Edge cases:**
- **Flyers:** never hits them (ground only).
- **Short range:** it has to sit close to the track; the Speed path's range helps.
- **Bosses:** no special rule.
- **The Wraith:** a flyer and Explosive (physical), so it can't touch it.

**Look (for the art phase):** a stubby, wide mortar tube on a turntable with a blast shield. The Retrofit adds the
baseplate, sight and shell rack. Per path:
- **Power:** a thicker, reinforced tube.
- **Speed:** two, then three tubes side by side.
- **Blast:** a fat shell with cluster fins.

## 3. Laser Tower

- **Class:** Assault. **Weapon type:** Energy.
- **Description (owner):** A High-Energy Laser Emitter affixed to a rotating turret. "It does more than just blind the enemy, that's for sure."
- **Paths:** 1. Power; 2. Multi-Target; 3. Range/Targeting.

### Design

**Status: designed, confirmed by the owner with changes (2026-10-15).** The choices under Decided are the owner's. The
stock stats and upgrade effects are Claude's proposals, confirmed as the design; the balance probe tunes their numbers. Prices come from the pricing formula, with the
stock tuned to the owner's 250-credit build cost.

**Decided (owner, 2026-10-15):**
- Hits **air and ground**.
- A **continuous beam that ramps up**: it locks on, and damage builds the longer it holds a target.
- **Melts armour:** the sustained beam strips armour over time while locked.
- **250 credits**, a premium specialist.
- **Path 1 (Power):** a **faster, higher ramp**; the mastery is the boss killer.
- **Path 2 (Multi-Target):** **prism split** into more beams.
- **Path 3 (Range/Targeting):** a **long-range lance**.
- **Retrofit:** a **capacitor bank** (+base damage), with a **bigger boost** than first drafted (owner's change).
- **Range path:** **shorter reach** than first drafted, keeping it a mid-range tower (owner's change).

**Stock (proposed):** 250 credits; 25 damage per second, ramping up to ×3 over 3 s on the same target; 150 range; air
and ground. **Armour melt:** the locked target loses 1 armour per second, down to 0. The armour stays gone, so other
towers benefit. Switching targets resets the ramp but not the melted armour.

**Pricing value for ramping beams:** the formula counts a ramp as an average multiplier of 1 + (max − 1) × 0.5 ×
(3 s ÷ ramp time)^0.3, and armour melt as ×1.1. These are added to the Pricing effect list.

**Retrofit, Capacitor Bank, 160:** +8 damage per second (25 to 33). Look: glowing capacitor drums on the base
that pulse as the beam ramps.

**Path 1, Power (faster, higher ramp):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Hotter Emitter | 60 | Ramp ceiling ×3.5 |
| 2 | Quick Focus | 60 | Ramp time 3 to 2.2 s |
| 3 (primary) | Overdrive | 815 | Ramp ceiling ×5 |
| 4 | Thermal Lock | 1,425 | Ceiling ×6; ramp time 1.8 s |
| Mastery | Annihilator | 5,535 | Ceiling **×8** in 1.5 s: the boss killer |

**Path 2, Multi-Target (prism split):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Beam Splitter | 200 | A second beam on another target at 40% power |
| 2 | Tuned Splitter | 200 | The second beam at 60% |
| 3 (primary) | Prism | 1,190 | **3 beams** (extras at 60%) |
| 4 | Clear Prism | 1,190 | Extra beams at 75% |
| Mastery | Prism Array | 5,950 | **4 beams** (extras at 75%); each beam ramps on its own target |

**Path 3, Range/Targeting (long-range lance, shortened by the owner):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Extended Optics | 50 | +15 range (165) |
| 2 | Collimator | 100 | +15 range (180) |
| 3 (primary) | Lance | 395 | +30 range (210) |
| 4 | Long Lance | 795 | +30 range (240) |
| Mastery | Deep Lance | 2,115 | **280 range**: still a mid-range tower, but with a long reach |

**Combinations (primary + secondary capped at 2):**
- **Power + 2 Range:** a faster-ramping boss killer that reaches further.
- **Multi + 2 Power:** several beams that ramp sooner and higher. The anti-elite build.
- **Range + 2 Multi:** a long lance with a second beam.

**Counters:**
- **Armour:** the melt at stock.
- **Bosses and Tanks:** the Power path's ramp.
- **Flyers:** hits them.
- **The Wraith:** an Energy tower that hits air, so it's one of its counters (the Wraith also needs a Radar reveal).

**Edge cases:**
- **Decoys and swarms:** the ramp is wasted on small targets. The Multi path's extra beams handle that, and holograms
  (1 HP) pop at once.
- **The Rampart and bosses:** no immunity to the melt (to confirm).
- **Target switching:** the ramp resets when its target dies or leaves range.

**Look (for the art phase):** a sleek emitter turret with a glowing lens on a rotating mount; the beam brightens as it
ramps. The Retrofit adds capacitor drums. Per path:
- **Power:** a hotter, whiter beam with heat vents.
- **Multi:** a prism crystal on the emitter, splitting the beam.
- **Range:** a long collimator barrel.

## 4. Rocket Salvo

- **Class:** Assault. **Weapon type:** Explosive.
- **Description (owner):** Launches a volley of rockets at oncoming enemies. "Instead of shooting bullets, it shoots very angry telephone poles that hate absolutely everything."
- **Paths:** 1. Power; 2. Range/Target Acquisition; 3. Reload/Payload.

### Design

**Status: designed, confirmed by the owner (2026-10-15).** The choices under Decided are the owner's. The stock
stats and upgrade effects are Claude's proposals, confirmed as the design; the balance probe tunes their numbers. Prices come from the pricing formula, with the
stock tuned to the owner's 200-credit build cost.

**Decided (owner, 2026-10-15):**
- Hits **air and ground**.
- **Spread salvos:** each volley fires several rockets, each at a different enemy, each with a small blast. It's the
  long-range multi-target Explosive tower; the Mortar is the short-range heavy splash.
- **3 rockets at stock; armour applies.**
- **200 credits.**
- **Path 1 (Power):** **heavier warheads**: more damage and bigger blasts.
- **Path 2 (Range/Target Acquisition):** range, and **homing** (rockets curve onto targets and re-target if theirs
  dies).
- **Path 3 (Reload/Payload):** **both**: steps alternate between more rockets and faster reloads.
- **Retrofit:** **guidance fins**: rockets fly faster and miss less.

**Stock (proposed):** 200 credits; a salvo of 3 rockets every 2.5 s, each on a different enemy, 19 damage with a 25 px
blast; 180 range; air and ground. Without homing, rockets fly at where the target was, so very fast or blinking enemies
can dodge them.

**Pricing values:** homing counts as ×1.15 to ×1.3 (fewer misses), and guidance fins as ×1.1. They join the Pricing
effect list.

**Retrofit, Guidance Fins (proposed), 40:** faster rockets that lead their target, so fewer misses. Look: tail fins and
a small sensor dome on each pod.

**Path 1, Power (heavier warheads):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | HE Warheads | 105 | +5 damage per rocket (24) |
| 2 | Wider Burst | 155 | Blast 25 to 35 px |
| 3 (primary) | Heavy Warheads | 985 | 32 damage, 40 px blast |
| 4 | Dense Payload | 1,245 | 38 damage |
| Mastery | Thermobaric Rockets | 5,710 | 46 damage, 50 px blast |

**Path 2, Range/Target Acquisition (homing):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Booster Stage | 45 | +20 range (200) |
| 2 | Seeker Heads | 135 | **Homing:** rockets curve onto their target |
| 3 (primary) | Smart Seekers | 510 | Rockets re-target if their target dies; +30 range (230) |
| 4 | Long Burn | 670 | +30 range (260) |
| Mastery | Hunter Seekers | 2,315 | 300 range; seekers never miss, catching fast and blinking enemies |

**Path 3, Reload/Payload (more rockets, faster reloads):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Extra Tube | 135 | 4 rockets per salvo |
| 2 | Quick Loader | 265 | A salvo every 2 s |
| 3 (primary) | Six-Pack | 1,335 | 6 rockets per salvo |
| 4 | Auto-Loader | 1,605 | A salvo every 1.7 s |
| Mastery | Ripple Salvo | 6,415 | 8 rockets per salvo, rippling out one after another |

**Combinations (primary + secondary capped at 2):**
- **Power + 2 Reload:** heavy rockets, a few more per salvo, slightly faster.
- **Reload + 2 Range:** a big homing salvo over a long range. The anti-swarm and anti-flyer build.
- **Range + 2 Power:** long-range homing rockets that hit harder.

**Counters:**
- **Swarms and packs:** the spread salvo puts one rocket on each of several enemies (the Reload path adds more).
- **Flyers:** hits them.
- **Fast and blinking enemies:** homing re-targets onto them (Range path).
- **Decoys:** the spread wastes a single rocket per hologram, not the whole salvo.

**Edge cases:**
- **Armour:** applies to every rocket, so Tanks aren't its job.
- **The Wraith:** Explosive (physical), so immune.
- **Bosses:** no special rule.
- **Fewer enemies than rockets:** the spare rockets go to the strongest target.

**Look (for the art phase):** a box launcher of rocket tubes on a rotating mount. Rockets leave smoke trails and fan
out to their targets. The Retrofit adds fins and a sensor dome. Per path:
- **Power:** fat warheads.
- **Range:** long seeker-nosed rockets.
- **Reload:** bigger racks of tubes and an auto-loader.

## 5. Anti-Aircraft Turret

- **Class:** Assault. **Weapon type:** Ballistic.
- **Description (owner):** A fully automatic anti-aircraft gun. "We don't need a gun, or a nug!"
- **Paths:** 1. Range; 2. Power/Blast Radius; 3. Speed.

### Design

**Status: designed, confirmed by the owner (2026-10-15).** The choices under Decided are the owner's. The stock
stats and upgrade effects are Claude's proposals, confirmed as the design; the balance probe tunes their numbers. Prices come from the pricing formula, with the
stock tuned to the owner's 150-credit build cost.

**Decided (owner, 2026-10-15):**
- **Air only:** the pure air specialist.
- A **direct-hit autocannon:** fast single-target rounds; blasts only come from a path.
- **150 credits.**
- **Path 1 (Range):** the mastery is **area denial**: a very long reach covering a big circle of sky.
- **Path 2 (Power/Blast Radius):** **flak shells**: damage, then an airburst that grows, until it shreds whole flocks.
- **Path 3 (Speed):** **more barrels and rate of fire.**
- **Retrofit:** **fire-control radar** (more range and accuracy).
- **The Wraith:** the AA gun doesn't counter it. The owner wants a **new tower idea** for the Wraith, **later**, after the
  19 towers (logged in `design/towers.md`, Open questions).

**Pricing value for air-only towers (accepted with the design):** a tower that can only hit flyers counts at **×0.5**, since flyers are
a minority of enemies. That lets it hit far harder than its price suggests. This joins the Pricing effect list.

**Stock (proposed):** 150 credits; 25 damage per round, 2.5 rounds/s, 160 range; flyers only. That's about 62 damage
per second against air: it shreds Locusts and Strike Drones and wears down Gunships.

**Retrofit, Fire-Control Radar (proposed), 45:** +15 range and steadier aim (×1.05). Look: a small rotating radar dish
beside the guns.

**Path 1, Range (area denial):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Long Barrel | 40 | +20 range (180) |
| 2 | Higher Mount | 75 | +20 range (200) |
| 3 (primary) | Sky Watch | 300 | +40 range (240) |
| 4 | High-Velocity Rounds | 600 | +40 range (280) |
| Mastery | Sky Wall | 1,500 | **330 range**: covers a big circle of sky |

**Path 2, Power/Blast Radius (flak shells):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Heavier Rounds | 70 | +6 damage (31) |
| 2 | Flak Rounds | 375 | Rounds burst near their target: a 20 px airburst on every flyer nearby |
| 3 (primary) | Flak Shells | 795 | 36 damage; 30 px airburst |
| 4 | Wide Burst | 865 | 40 px airburst |
| Mastery | Flak Curtain | 4,325 | 42 damage; 50 px airburst: whole flocks of Locusts and Shrikes go down together |

**Path 3, Speed (barrels and rate of fire):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Quick Cycle | 35 | 2.8 rounds/s |
| 2 | Fast Traverse | 95 | 3.2 rounds/s; turns faster onto new flyers |
| 3 (primary) | Twin Barrels | 625 | 4.5 rounds/s |
| 4 | Belt Feed | 675 | 5.2 rounds/s |
| Mastery | Quad Mount | 3,460 | **7 rounds/s** from four barrels: a wall of fire |

**Combinations (primary + secondary capped at 2):**
- **Power + 2 Speed:** flak bursts fired faster. The anti-flock build.
- **Speed + 2 Range:** a quad-mount stream over a wide sky.
- **Range + 2 Power:** long-range flak with an early airburst.

**Counters:**
- **Flyers:** its whole job. It covers the Locust and Shrike swarms (flak), Strike Drones and Fury Drones (rate of
  fire), and Gunships and the Leviathan (sustained damage).
- **Cloaked flyers** (the Phantom) need a Radar Tower reveal first.
- **The Wraith** is out of reach (physical damage); it gets a separate tower later.

**Edge cases:**
- **Ground enemies:** it ignores them entirely.
- **Flyers grounded by the Magneto Tower:** if grounded flyers count as ground, the AA gun loses them while they're down
  (the Magneto's open question).
- **Bosses:** the Leviathan is its boss; no special rule.

**Look (for the art phase):** a twin-handled autocannon on a raised swivel with a high elevation angle and spent
casings. The Retrofit adds a small radar dish. Per path:
- **Range:** a long barrel on a taller mount.
- **Power:** fat flak shells and puffs of black smoke in the sky.
- **Speed:** twin, then quad barrels.

## 6. Artillery Cannon

- **Class:** Assault. **Weapon type:** Explosive.
- **Description (owner):** A large-bore cannon that fires high-explosive shells very long distances. "It's not DiGiorno..."
- **Paths:** 1. Power; 2. Speed; 3. Special Effects.
- **Notes (owner):** User selects where the cannon should aim along the track - Does not target enemies.

### Design

**Status: designed, confirmed by the owner (2026-10-15).** The choices under Decided are the owner's. The stock
stats and upgrade effects are Claude's proposals, confirmed as the design; the balance probe tunes their numbers. Prices come from the pricing formula, with the
stock tuned to the owner's 300-credit build cost.

**Decided (owner, 2026-10-15):**
- **Aimed by the player, not at enemies:** select the cannon, click a spot on the track, and it shells that spot on a
  loop until you move it. Re-aiming is free, any time.
- **Reaches the whole map.**
- **Ground only.**
- **300 credits.**
- **Path 1 (Power):** **both:** damage and blast first, armour piercing at the top.
- **Path 2 (Speed):** **faster reload**; the mastery fires a rapid barrage.
- **Path 3 (Special Effects):** **shell types** you switch between, and the mastery combines them.
- **Retrofit:** an **ammo hoist** (+fire rate).

**Stock (proposed):** 300 credits; a heavy shell every 4 s onto the aimed spot, 75 damage, a 70 px blast, 1.5 s flight
time; ground only. A new cannon aims at the track point nearest to itself until you set it.

**Pricing value for the aimed, whole-map gun (accepted with the design):** its reach counts as ×1.5 (range ÷ 130 doesn't fit a fixed
aim point). Burning ground counts as its damage over 3 s on everything in the blast. Each extra selectable shell type
adds ×0.1 (flexibility), and a stun ×1.15 to ×1.25. These join the Pricing effect list.

**Retrofit, Ammo Hoist (proposed), 120:** a shell every 3.3 s (0.25 to 0.3/s). Look: an ammo lift beside the gun.

**Path 1, Power (damage and blast, then armour piercing):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Heavy Shells | 120 | +15 damage (90) |
| 2 | Wide Bursting Charge | 200 | Blast 70 to 85 px |
| 3 (primary) | HE Shells | 730 | 110 damage |
| 4 | Penetrator Shells | 2,930 | 120 damage; ignores 50% of armour |
| Mastery | Siege Shells | 7,355 | 140 damage, 90 px blast, ignores 75% of armour |

**Path 2, Speed (faster reload):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Drilled Crew | 120 | A shell every 3.3 s |
| 2 | Quick Breech | 240 | Every 2.9 s |
| 3 (primary) | Autoloader | 1,450 | Every 2 s |
| 4 | Rapid Breech | 1,935 | Every 1.7 s |
| Mastery | Rolling Barrage | 3,865 | Fires in 3-shell barrages that walk across the aimed spot: an average of one shell every 1.4 s |

**Path 3, Special Effects (shell types):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Incendiary Shells | 365 | Unlocks **incendiary**: the blast leaves burning ground (15 damage/s for 3 s) |
| 2 | Shrapnel Shells | 195 | Unlocks **shrapnel**: a 40 px wider blast at 70% damage |
| 3 (primary) | Concussion Shells | 1,085 | Unlocks **concussion**: everything in the blast is stunned for 0.5 s (bosses 0.15 s) |
| 4 | Improved Payloads | 3,505 | Every shell type stronger: burn 22/s, shrapnel at 85%, stun 0.7 s |
| Mastery | Combined Payload | 5,725 | A fourth type that does all three at once |

**Switching shell types:** pick the type on the cannon's panel (a small shell selector). Proposed: it takes effect from
the next shell. A secondary capped at 2 gets incendiary and shrapnel.

**Combinations (primary + secondary capped at 2):**
- **Power + 2 Special:** heavy, armour-piercing shells with incendiary or shrapnel.
- **Speed + 2 Power:** fast, heavier shells. The choke-point grinder.
- **Special + 2 Speed:** stun or combined shells, reloaded faster.

**Counters:**
- **Packs and choke points:** you pick the spot.
- **Armour:** the Power path.
- **Rushers and bosses at a chosen spot:** concussion stuns them; it also cancels the Capacitor's charge if it lands
  during one.

**Edge cases:**
- **Flyers:** never hit.
- **Wasted shells:** if the spot is empty, shells land anyway (owner: it shells the spot on a loop).
- **The bot:** aims at the track point where enemies bunch most (the busiest choke). That needs a bot rule.
- **Saves:** store each cannon's aim point.
- **Map changes:** if switch gates re-route enemies away from the spot, the cannon keeps firing there until re-aimed.
- **The Wraith:** a flyer, and Explosive, so out of reach.

**Look (for the art phase):** a long-barrelled field gun on a heavy turntable with stabiliser legs. It recoils, and a
target marker shows on the aimed spot. The Retrofit adds the ammo hoist. Per path:
- **Power:** a bigger bore and muzzle brake.
- **Speed:** an autoloader drum, then twin rails.
- **Special:** colour-coded shell racks.

## 7. Railgun

- **Class:** Assault. **Weapon type:** Ballistic.
- **Description (owner):** A large cannon with magnetically polarized rails that launch a large projectile extremely far, extremely fast. "Known to cause cancer in the state of California."
- **Paths:** 1. Power; 2. Range/Speed; 3. Special Effects.

### Design

**Status: designed, confirmed by the owner (2026-10-15), after reopening for the ion-trail change.** The choices under
Decided are the owner's. The stock stats and upgrade effects are Claude's proposals, confirmed as the design; the
balance probe tunes their numbers. Prices come from the pricing formula,
with the stock tuned to the owner's 500-credit build cost.

**Decided (owner, 2026-10-15):**
- Hits **air and ground**.
- **Armour applies:** its huge per-shot damage already shrugs most of it off.
- **Piercing with falloff** (owner's change, replacing "piercing from a path"): every slug passes through the enemies on
  its line, **losing damage with each enemy it passes**; upgrades reduce the falloff.
- **500 credits**: the priciest tower so far.
- **Path 1 (Power):** **Boss Slayer and Overcharge** combined: bigger charged shots and bonus damage against bosses.
- **Path 2 (Range/Speed):** **mostly recharge**. It already reaches far; the steps cut the recharge.
- **Path 3 (Special Effects):** **armour shatter, less penetration falloff, and an ionised trail.**
- **The ion trail is area damage** (owner, 2026-10-15): it hurts **every enemy on the line, targeted or not**, cloaked
  enemies included.
- **Retrofit:** **capacitor coils** (faster recharge).

**Stock (proposed):** 500 credits; a 90-damage slug every 2.5 s, 380 range; air and ground; armour applies (a Titan's
9 armour costs it only 10%). **Penetration:** the slug pierces every enemy on its line, losing 40% of its damage with each
enemy it passes through (90, 54, 32...).

**Pricing values:** boss bonus damage counts as ×1.1 to ×1.3; armour shatter +3% per armour stripped; piercing with falloff
as ×1.25 (40% falloff) up to ×1.75 (no falloff); an ionised trail as its burn on the line. These join the Pricing
effect list.

**Retrofit, Capacitor Coils (proposed), 140:** recharge 2.5 to 2.2 s. Look: glowing coils along the rails that charge
up before each shot.

**Path 1, Power (boss slayer and overcharge):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Dense Slugs | 345 | +30 damage (120) |
| 2 | Boss Rounds | 275 | ×1.5 damage to bosses |
| 3 (primary) | Overcharge | 2,260 | It charges each shot longer: 200 damage, a 3 s recharge |
| 4 | Kill Charge | 5,125 | 240 damage; ×2 to bosses |
| Mastery | Kingslayer | 6,465 | 280 damage per charged shot (3.3 s); **×2.5 to bosses** |

**Path 2, Range/Speed (mostly recharge):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Fast Capacitors | 140 | Recharge 2.2 s |
| 2 | Extended Rails | 245 | +40 range (420) |
| 3 (primary) | Rapid Capacitors | 1,930 | Recharge 1.6 s |
| 4 | Supercapacitors | 2,610 | Recharge 1.35 s |
| Mastery | Twin Rails | 5,000 | Two rails firing in turn: a slug every 1.2 s, twice the stock rate |

**Path 3, Special Effects (shatter, penetration, ion trail):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Shatter Rounds | 60 | Each hit strips 2 armour permanently, so every tower benefits |
| 2 | Penetrator Core | 260 | Falloff per enemy 40% to 25% |
| 3 (primary) | Ionised Trail | 1,535 | The line burns for 2 s: 30 energy damage/s to every enemy on it, targeted or not (cloaked ones too) |
| 4 | Hot Rail | 3,685 | Shatter 4 armour; trail 45/s; falloff 15% |
| Mastery | Ion Lance | 6,920 | Shatter 6; trail 50/s; **no falloff**: full damage to everything on the line |

**Combinations (primary + secondary capped at 2):**
- **Power + 2 Special:** a boss-killing charged shot that also shatters armour and loses less damage as it pierces.
- **Speed + 2 Power:** fast slugs with boss rounds.
- **Special + 2 Speed:** a burning, piercing ion line fired faster. Good against lined-up waves.

**Counters:**
- **Bosses:** the Power path (×2.5 at the mastery).
- **Armour:** shatter strips it for everyone.
- **Lined-up columns:** penetration at stock, full-strength at the Ion Lance.
- **Flyers:** hits them.
- **The Wraith:** the slug is Ballistic, but the **ionised trail is area energy damage**: it burns a Wraith that crosses
  or sits on the line **even while cloaked and untargeted** (owner). Like other area damage, it also reveals it briefly
  (the enemy spec's rule).

**Edge cases:**
- **Overkill:** small targets waste a 90-damage slug; it's a heavy-target tower.
- **Decoys:** holograms in front only cost the slug some falloff; it carries on to the real target.
- **Armour applies to the slug, not the trail** (energy damage over time follows the burn rules: it ignores armour, as
  today's burns do).

**Look (for the art phase):** two long parallel rails on a heavy turret with a capacitor bank; a blue flash and a
straight tracer line on each shot. The Retrofit adds glowing coils. Per path:
- **Power:** a bulked-up breech and charge glow.
- **Speed:** twin rails.
- **Special:** an ion-blue trail that lingers.

## 8. Tesla Tower

- **Class:** Assault. **Weapon type:** Energy.
- **Description (owner):** A large metal disk mounted atop of a large tower that generates high-voltage electrical arcs that damage incoming enemies. "It was built in a cave with a box of scraps."
- **Paths:** 1. Power (Damage); 2. Range/Chaining; 3. Speed.

### Design

**Status: designed, confirmed by the owner (2026-10-15).** The choices under Decided are the owner's. The stock
stats and upgrade effects are Claude's proposals, confirmed as the design; the balance probe tunes their numbers. Prices come from the pricing formula, with the
stock tuned to the owner's 250-credit build cost.

**Decided (owner, 2026-10-15):**
- Hits **air and ground**.
- **Chain lightning:** it hits one enemy and jumps to a few nearby ones, losing some power per jump.
- **250 credits.**
- **Path 1 (Power/Damage):** **raw voltage**: pure damage, and the arcs barely weaken per jump at the top. This path
  also carries the **stun** and the **EMP-enemy overload** (owner).
- **Path 2 (Range/Chaining):** **storm field**: range and jumps, and arcs leave a crackling storm where they land.
- **Path 3 (Speed):** **faster discharges**, continuous at the top.
- **Retrofit:** a **bigger disk** (+damage, +range).

**Stock (proposed):** 250 credits; an arc every 1.25 s (0.8/s), 32 damage, jumping to 3 more enemies within 70 px and
losing 15% per jump; 140 range; air and ground. It's Energy, so it ignores armour like other energy damage
(to confirm), and it's a Wraith counter once the Wraith is revealed.

**Pricing values:** a chain counts as 1 + 0.6 × the falloff-weighted jumps (enemies aren't always in reach); the storm as
its damage over 2 s in its radius; the overload ×1.08; stuns ×1.15 to ×1.2. These join the Pricing effect list.

**Retrofit, Bigger Disk (proposed), 120:** +4 damage (36), +15 range (155). Look: a larger crowning disk with a corona
glow.

**Path 1, Power/Damage (raw voltage, stun, overload):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | High Voltage | 125 | +8 damage (40) |
| 2 | Overload Circuits | 100 | **EMP-enemy overload:** ×2 damage to Disruptors (Jammer, Siphon, Blackout Rig, Capacitor); a hit **cancels a Capacitor's charge** |
| 3 (primary) | Arc Stun | 1,020 | 48 damage; arcs **stun** for 0.3 s (bosses 0.1 s) |
| 4 | Clean Conduction | 1,705 | 54 damage; only 8% lost per jump |
| Mastery | Lightning Rod | 4,310 | 60 damage; 3% lost per jump; stun 0.5 s |

**Path 2, Range/Chaining (storm field):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Taller Coil | 70 | +20 range (160) |
| 2 | Extra Jump | 155 | 4 jumps |
| 3 (primary) | Storm Field | 2,260 | 5 jumps; each arc leaves a 25 px storm for 2 s (10 energy damage/s to every enemy in it) |
| 4 | Wide Storm | 2,390 | +20 range (180); 6 jumps |
| Mastery | Tempest | 8,140 | 7 jumps; storms of 14/s, 30 px |

**Path 3, Speed (faster discharges):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Quick Recharge | 60 | 0.9 arcs/s |
| 2 | Fast Capacitor | 125 | 1.0 arcs/s |
| 3 (primary) | Rapid Discharge | 995 | 1.4 arcs/s |
| 4 | Overclocked Coil | 995 | 1.6 arcs/s |
| Mastery | Continuous Discharge | 4,980 | 2.1 arcs/s: near-constant lightning |

**Combinations (primary + secondary capped at 2):**
- **Power + 2 Speed:** stunning, overloading arcs fired faster. The anti-Disruptor and crowd-control build.
- **Chain + 2 Power:** storms through a wave, plus the overload.
- **Speed + 2 Chain:** constant arcs with an extra jump and range.

**Counters:**
- **Crowds and swarms:** the chain.
- **Disruptors:** the overload, which also cancels the Capacitor's charge.
- **Rushers and Blink Stalkers:** the stun (it resets a blink charge).
- **Flyers:** hits them.
- **The Wraith:** Energy, and the storm is area energy damage, so a storm hurts a cloaked Wraith inside it
  (consistent with the owner's ion-trail ruling on the Railgun). The arc itself needs a revealed target.

**Edge cases:**
- **Bosses:** stuns at a third of the duration, as today.
- **The Rampart:** immune to the stun; it still takes damage.
- **Isolated enemies:** no jumps, so the chain wastes value on lone targets.
- **Barriers:** no special bonus (the owner didn't pick it).

**Look (for the art phase):** a tall coil tower topped with a metal disk; arcs leap from the disk and chain between
enemies. The Retrofit enlarges the disk. Per path:
- **Power:** thicker, whiter arcs.
- **Chain:** extra coil rings and a crackling storm on the ground.
- **Speed:** a humming, flickering coil.

## 9. Drone Bay

- **Class:** Assault. **Weapon type:** Deployable.
- **Description (owner):** Houses combat drones that hunt after enemies. "The military really took the idea of same-day delivery and ran with it."
- **Paths:** 1. Power (overall); 2. Weaponry (upgrades/additions); 3. Speed.
- **Notes (owner):** Max 2 drones

### Design

**Status: designed, confirmed by the owner with one change (2026-10-15).** The choices under Decided are the owner's.
The stock stats and upgrade effects are Claude's proposals, confirmed as the design; the balance probe tunes their
numbers. Prices come from the pricing formula, with the
stock tuned to the owner's 300-credit build cost.

**Decided (owner, 2026-10-15):**
- The drones **hunt anywhere on the map**.
- They hit **air and ground**.
- **1 drone at stock; the Retrofit launches the second** (the owner's "max 2 drones"). Nothing goes beyond 2.
- **300 credits.**
- **Path 1 (Power):** **damage.**
- **Path 2 (Weaponry):** **choose a loadout**: each step unlocks a loadout you can switch between.
- **Path 3 (Speed):** **rate of fire.**
- **The Retrofit costs 3,200** (owner's override of the formula's 600): the second drone essentially doubles the bay's
  firepower.
- **Enemies can't hurt drones, except EMPs:** a Disruptor's EMP (Jammer, Blackout Rig, Capacitor) knocks drones out of
  the air for its duration.

**Stock (proposed):** 300 credits; 1 combat drone with a gun: 16 damage, 3 shots/s, hunting the nearest enemy to the
core, anywhere on the map; air and ground. The drone flies to its target, so far-off enemies take a moment to reach.

**Pricing value for drones (proposed):** whole-map hunting counts as ×1.5 (×1.6 less a little for flight time); each
unlocked loadout adds flexibility, and a stronger loadout more. These join the Pricing effect list.

**Retrofit, Second Hangar, 3,200 (owner):** launches the **second drone**, doubling the bay's firepower. The formula
said 600; the owner set 3,200, since doubling the firepower is worth more than a step 1. Look: a second hangar door and landing pad.

**Path 1, Power (damage):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Heavier Guns | 150 | 20 damage |
| 2 | Hot Loads | 300 | 24 damage |
| 3 (primary) | Combat Firmware | 900 | 30 damage |
| 4 | Assault Frames | 1,800 | 36 damage |
| Mastery | Elite Drones | 3,600 | 42 damage |

**Path 2, Weaponry (loadouts, switchable on the bay's panel):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Micro-Missiles | 60 | Unlocks **missiles**: slower shots with a 25 px blast |
| 2 | Bomb Racks | 120 | Unlocks **bombs**: heavy ground-only drops with a 40 px blast |
| 3 (primary) | Drone Laser | 290 | Unlocks **laser**: energy damage that ignores armour (a Wraith counter once it's revealed) |
| 4 | Upgraded Loadouts | 865 | Every loadout 25% stronger |
| Mastery | Full Kit | 3,360 | A combined loadout: guns, missiles and laser together |

**Path 3, Speed (rate of fire):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Fast Cycling | 100 | 3.5 shots/s |
| 2 | Twin Feed | 200 | 4 shots/s |
| 3 (primary) | Rotary Guns | 800 | 5 shots/s |
| 4 | Overclocked Feed | 1,280 | 5.8 shots/s |
| Mastery | Storm Drones | 3,840 | 7 shots/s |

**Combinations (primary + secondary capped at 2):**
- **Power + 2 Speed:** hard-hitting, faster-firing hunters.
- **Weaponry + 2 Power:** the loadout of your choice, hitting harder.
- **Speed + 2 Weaponry:** rapid fire with missiles or bombs.

**Counters:**
- **Leakers:** whole-map hunting catches whatever slips through.
- **Flyers:** it hits them.
- **Swarms:** missiles and bombs.
- **Armour and the Wraith:** the laser loadout.

**Edge cases:**
- **EMPs:** drones caught in an EMP drop for its duration, then relaunch.
- **Targeting:** the drones use the bay's targeting mode (First, Strongest...); with 2 drones they take different
  targets.
- **The loadout switch:** it takes effect on the next shot.
- **Today's Drone Bay** (2 to 6 drones) becomes this 1-to-2 drone version (owner's cap).

**Look (for the art phase):** a squat hangar with a launch pad, and small rotor or jet drones with tiny guns. The
Retrofit adds a second hangar door. Per path:
- **Power:** armoured drones.
- **Weaponry:** missile pods, bomb racks or a laser pod.
- **Speed:** rotary guns.

## 10. CAS Gunship

- **Class:** Assault. **Weapon type:** Deployable.
- **Description (owner):** A large slow-flying cargo plane capable of being with with a wide range of weaponry. "You know that feeling you get when its raining outside, but then the rain suddenly goes from being water to large metal bullets being shot at you from that giant plane above you? Yeah, I hate that feeling."
- **Paths:** 1. Speed (Attack); 2. Power; 3. Weaponry Upgrades.
- **Notes (owner):** While its tower can be placed anywhere, the gunship itself circles around a pin-point location of the user's designation.

### Design

**Status: designed, confirmed by the owner (2026-10-15).** The choices under Decided are the owner's. The stock stats
and upgrade effects are Claude's proposals, confirmed as the design; the balance probe tunes their numbers. Prices come from the pricing formula.

**Decided (owner, 2026-10-15):**
- **Its own upgrade system** (an exception to the tower rules). **Each path upgrades one gun:** path 1 the **light** gun,
  path 2 the **medium**, path 3 the **heavy**. A path's step 1 unlocks its gun (the light gun is built in).
- **All paths uncapped:** no primary/secondary rule. Every gun can take all 4 upgrades **and its mastery**, so a fully
  upgraded gunship has all three guns maxed.
- **Every gun path follows the same pattern:** damage, fire rate, damage, fire rate, then the mastery.
- **Stock weapons:** **gatling** (light, built in), **autocannon** (medium), **missiles** (heavy). Research unlocks
  more weapons per class later (the Research Lab rework).
- **Attack:** the tower can be placed anywhere; the gunship **orbits a point you designate and side-fires** on enemies
  inside its orbit. **Re-designating is free, any time.**
- **Targets:** ground and air by default, chosen by the targeting option (the Any/Air/Ground priority).
- **EMPs** under its orbit silence its guns, like the Drone Bay's drones.
- **Retrofit:** **Radar**: it can detect cloaked enemies.
- **650 credits** to build.
- **The masteries need research**, as other towers' do (owner).
- **The Radar reveals cloaked enemies to other towers too** (owner).

**Stock (proposed):** 650 credits; the gunship orbits its point at a 90 px radius. Its **gatling** fires at enemies
inside the orbit: 12 damage, 5 rounds/s. By the formula the armed stock is worth about 350; the rest of the 650 pays for
the airframe that carries two more guns.

**Retrofit, Radar, 35:** cloaked enemies inside the gunship's orbit (Phantom, Wraith) are **revealed to every tower**,
not just the gunship (owner). That makes it a mobile Radar Tower. The formula values it at 35, since it only counts the
gunship's own damage; the owner may set an override. Look: a radar dome under the fuselage.

**Pricing:** a player-aimed, place-anywhere gun counts its reach as ×1.5, like the Artillery Cannon.

**Path 1, Light gun (gatling), built in:**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Heavier Rounds | 175 | Damage 12 to 15 |
| 2 | Faster Spin | 350 | 6 rounds/s |
| 3 | Hardened Rounds | 1,125 | 19 damage |
| 4 | Overdrive Motor | 2,670 | 7.5 rounds/s |
| Mastery | Twin Gatlings | 5,345 | 9 rounds/s |

**Path 2, Medium gun (autocannon):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Autocannon | 1,145 | **Unlocks the autocannon:** 40 damage, 1.5 shots/s, 25 px blast |
| 2 | Faster Feed | 455 | 1.8 shots/s |
| 3 | HE Rounds | 1,645 | 52 damage |
| 4 | Twin Feed | 3,170 | 2.2 shots/s |
| Mastery | Autocannon Battery | 7,015 | 58 damage; 30 px blast |

**Path 3, Heavy gun (missiles):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Missile Rack | 1,235 | **Unlocks guided missiles:** 150 damage, one every 3 s, 45 px blast |
| 2 | Quick Rack | 525 | One every 2.5 s |
| 3 | Heavy Warheads | 1,595 | 190 damage |
| 4 | Auto-Rack | 3,785 | One every 2 s |
| Mastery | Hellfire Volley | 13,250 | Every third volley fires two missiles |

**Full build:** about 44,000 credits with every gun maxed. It's the game's biggest credit sink by design, since every
path is uncapped.

**Counters:**
- **Packs at a point you choose:** the orbit.
- **Flyers:** the targeting option.
- **Cloaked enemies:** the Radar Retrofit reveals them in the orbit for every tower.
- **Armour and Tanks:** the heavy missiles.

**Edge cases:**
- **EMP:** guns go silent while an EMP covers the orbit point.
- **The bot:** points the orbit at the busiest choke (like the Artillery).
- **Saves:** store the orbit point.
- **The Wraith:** all three stock weapons are physical, so it's immune even when the radar sees it.

**Look (for the art phase):** a large, slow cargo plane circling with side guns, its shadow sweeping over the track.
Each unlocked gun appears on its flank (gatling, autocannon, missile rack), and the Retrofit adds a radar dome.

## 11. Mine Layer

- **Class:** Defense. **Weapon type:** Explosive.
- **Description (owner):** Manufactures and tosses explosive mines onto the track that explode when an enemy passes over them. "You know it's a party when the high-speed confetti start flying in every direction."
- **Paths:** 1. Power/Damage; 2. Production Speed; 3. Range.

### Design

**Status: designed, confirmed by the owner with one change (2026-10-15).** The choices under Decided are the owner's.
The stock stats and upgrade effects are Claude's proposals, confirmed as the design; the balance probe tunes their
numbers. Prices come from the pricing formula, with the
stock tuned to the owner's 450-credit build cost.

**Decided (owner, 2026-10-15):**
- **Defense by area denial:** its job is holding a stretch of track; enemies pay to cross the minefield.
- **Up to 20 mines** on the track at once. **Mines despawn when the round ends**, but **persist if you start the next
  round early** (owner: "persistent on early start").
- **Mines are triggered by ground and burrowed enemies:** they're buried, so Burrowers set them off too. Flyers pass
  over. **Mirage holograms don't trigger mines:** they're projections, not physical copies (owner).
- **450 credits.**
- **Path 1 (Power/Damage):** **damage and larger blasts.**
- **Path 2 (Production Speed):** **faster laying and a bigger cap.**
- **Path 3 (Range):** **how far it tosses** mines.
- **Retrofit:** **faster production and a higher cap.**

**Stock (proposed):** 450 credits; tosses a mine onto the track within 120 px every 1.5 s, up to 20 at once. Each mine
blasts 85 damage in 40 px when a ground or burrowed enemy passes over. Mines spread along the track in range, nearest
the entrance end first.

**Pricing value:** mines count like blasts (production rate × damage × area), plus ×1.1 for hitting burrowed enemies.
The cap isn't priced.

**Retrofit, Conveyor Feed (proposed), 110:** a mine every 1.33 s, and a 25-mine cap. Look: a conveyor belt and a
hopper of ready mines.

**Path 1, Power/Damage:**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Heavier Charge | 160 | 100 damage |
| 2 | Wider Charge | 265 | 50 px blast |
| 3 (primary) | HE Mines | 1,190 | 125 damage |
| 4 | Fragmentation Casing | 1,325 | 60 px blast |
| Mastery | Anti-Tank Mines | 6,880 | 150 damage, 65 px blast |

**Path 2, Production Speed (faster laying, bigger cap):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Quick Assembly | 110 | A mine every 1.33 s; cap 24 |
| 2 | Twin Press | 270 | Every 1.2 s; cap 28 |
| 3 (primary) | Assembly Line | 1,080 | Every 0.95 s; cap 32 |
| 4 | Automated Line | 1,620 | Every 0.85 s; cap 36 |
| Mastery | Mine Factory | 5,395 | Every 0.7 s; cap 45 |

**Path 3, Range (toss distance):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Longer Arm | 150 | 140 px |
| 2 | Spring Launcher | 300 | 160 px |
| 3 (primary) | Mine Mortar | 900 | 190 px |
| 4 | Long Mortar | 1,800 | 220 px |
| Mastery | Minefield Launcher | 4,795 | 260 px: covers a long stretch of track |

**Combinations (primary + secondary capped at 2):**
- **Power + 2 Production:** heavy mines, laid faster. The choke-point killer.
- **Production + 2 Range:** a dense minefield along a long stretch.
- **Range + 2 Power:** long-reach heavy mines.

**Counters:**
- **Burrowers:** buried mines trigger on them underground. It's a natural Burrower counter, no Radar needed (the owner's
  call).
- **Rushers:** they run straight over the field.
- **Packs:** the blasts.
- **Hydra Frame splits:** the leftover mines catch the Skitters.

**Edge cases:**
- **Flyers:** never trigger mines.
- **Grounded flyers** (from the Magneto Tower): if grounded counts as ground, they'd set mines off (the Magneto's open
  question).
- **Early start:** if the next round starts before this one ends, mines on the track stay. Otherwise they despawn at the
  round's end.
- **Decoys:** Mirage holograms pass over mines without setting them off, since they're illusions (owner). The minefield
  ignores them entirely.
- **The Rampart:** immune to slows and shoves, not to mines.
- **The Wraith:** a flyer, so it never triggers them.

**Look (for the art phase):** a squat fabricator with a throwing arm, lobbing disc mines that blink on the track. The
Retrofit adds a conveyor and hopper. Per path:
- **Power:** chunkier anti-tank mines.
- **Production:** twin presses, then an assembly line.
- **Range:** a mine mortar tube.

## 12. Chemical Plant

- **Class:** Support. **Weapon type:** Chemical.
- **Description (owner):** A chemical manufacturing facility that produces and sprays chemicals on nearby enemies. "Known to cause cancer in the state of California."
- **Paths:** 1. Damage/Armor stripping; 2. Speed; 3. Slowing.
- **Notes (owner):** Weapon type: Chemical. Attacks one enemy at a time. Already soaked enemies are ignored by the tower until the chemical wears off.

### Design

**Status: designed, confirmed by the owner (2026-10-15).** The choices under Decided are the owner's. The stock stats
and upgrade effects are Claude's proposals, confirmed as the design; the balance probe tunes their numbers. Prices come from the pricing formula.

**Decided (owner, 2026-10-15):**
- **Class: Support** (kept): its soak sets enemies up for the other towers.
- **Weapon type: Chemical**, now an official weapon type (added to the class sheet and the roster page).
- Sprays **air and ground**, **one enemy at a time**; enemies already soaked are ignored until the soak wears off
  (owner's roster note).
- **At stock, a soak strips armour.**
- **Path 1 (Damage/Armor stripping):** **the acid permanently removes armour**; higher tiers add damage over time and
  strip faster.
- **Path 2 (Speed):** **spray rate, and a longer soak.**
- **Path 3 (Slowing):** a **gel slow** that grows each step and nearly freezes enemies at the mastery.
- **250 credits**; **Retrofit: pressure pump** (faster spray, more range).
- **Holograms:** the plant **can target Mirage holograms, but the spray has no effect** on them (owner). A hologram
  wastes a spray.

**Stock (proposed):** 250 credits; sprays one enemy every 1.5 s within 130 px, air and ground. The soak lasts 4 s, and
the enemy loses 3 armour while soaked (it comes back when the soak ends). The plant always picks an unsoaked enemy.

**Pricing value for support effects (accepted with the design; a new general rule):** a tower whose stock effect isn't direct damage gets
its stock value set to its build cost. Each upgrade is then priced by how much it raises that effect (spray rate, soak
length, armour stripped, damage over time, slow), using the same step multipliers. This joins the Pricing section.

**Retrofit, Pressure Pump (proposed), 150:** a spray every 1.33 s, and +20 range (150). Look: a pump with pressure gauges
on the spray head.

**Path 1, Damage/Armor stripping (acid):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Corrosive Acid | 250 | Stripped armour stays gone **permanently**, so every tower benefits for the rest of the enemy's life |
| 2 | Etching Acid | 665 | 4 armour per soak; acid burns 5 damage/s |
| 3 (primary) | Fast-Acting Acid | 1,335 | 5 armour, stripped faster; 10 damage/s |
| 4 | Concentrated Acid | 2,665 | 6 armour; 15 damage/s |
| Mastery | Dissolver | 5,335 | 7 armour per soak; 20 damage/s |

**Path 2, Speed (spray rate and soak length):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Quick Valve | 100 | A spray every 1.25 s |
| 2 | Long-Lasting Mix | 140 | The soak lasts 5 s |
| 3 (primary) | Twin Valves | 990 | A spray every second; the soak lasts 6 s |
| 4 | High-Flow Pump | 1,470 | A spray every 0.83 s |
| Mastery | Twin Nozzles | 7,760 | Sprays two enemies at once (about 1.6 a second); the soak lasts 7 s |

**Path 3, Slowing (gel):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Sticky Gel | 250 | Soaked enemies are slowed 15% |
| 2 | Thick Gel | 335 | 25% |
| 3 (primary) | Glue | 665 | 35% |
| 4 | Setting Glue | 1,335 | 45% |
| Mastery | Quick-Set Foam | 2,665 | **55%**: nearly frozen |

**Slows:** the strongest slow applies (they don't stack), as today, so a Cryo Tower's slow and the gel don't add up.

**Combinations (primary + secondary capped at 2):**
- **Acid + 2 Speed:** permanent armour stripping on more enemies, faster.
- **Speed + 2 Slow:** soak-and-slow everything that passes.
- **Slow + 2 Acid:** near-frozen enemies that lose armour for good.

**Counters:**
- **Armour** (Tanks, the Titan, armoured bosses): the acid, permanent from path 1's first step.
- **Rushers:** the gel slow.
- **Flyers:** it sprays them.
- **The Wraith:** the acid's damage over time is energy-like (burn rules), so it can hurt the Wraith once it's revealed
  (to confirm, under the parked physical/energy decision).

**Edge cases:**
- **The Rampart:** immune to the slow, but not to armour stripping.
- **Bosses:** take the full armour strip; slows are halved, as today.
- **One target at a time:** the plant can't keep up with big swarms; the Speed path helps.
- **Decoys:** the plant can spray Mirage holograms, but nothing happens (owner). The spray is wasted, so the decoys still
  soak its time.

**Look (for the art phase):** a small chemical works (tanks, pipes and a spray turret) misting green acid; soaked
enemies drip and fizz. The Retrofit adds a pump with gauges. Per path:
- **Acid:** a hazard-yellow acid tank.
- **Speed:** twin nozzles.
- **Slow:** a foam-gel hopper.

## 13. Boost Tower (was Rally Beacon)

- **Class:** Support. **Weapon type:** None.
- **Description (owner):** Towers in range of the Rally Beacon are amped up and given stat boosts. "Are you feeling it now Mr. Krabs?"
- **Paths:** 1. Damage boost; 2. Speed boost; 3. Range Boost.
- **Notes (owner):** Retrofit boosts towers reach and grants mild boost for all stats for all towers in range

### Design

**Status: designed, confirmed by the owner (2026-10-15).** The choices under Decided are the owner's. The stock stats
and upgrade effects are Claude's proposals, confirmed as the design; the balance probe tunes their numbers. Prices come from the pricing formula (the
non-damage rule: stock value = build cost).

**Decided (owner, 2026-10-15):**
- **Renamed: Boost Tower** (was Rally Beacon). The enemy roster already has a Rally Beacon (Support T2), so the tower
  gets a new name.
- **Overlapping Boost Towers don't stack:** the strongest boost of each kind applies, as today's Amplifier Pylon.
- **Its paths decide what it boosts:** damage, fire rate and range, each grown by its own path (the secondary capped like
  any tower).
- **A mild all-round boost at stock**, and the **Retrofit's all-stats boost stacks on top** (owner: "Mid all-round.
  Retrofit stacks").
- **+50% at each path's mastery.**
- **A medium boost radius** (about 3 tiles).
- **400 credits.**

**Stock (proposed):** 400 credits; towers within 144 px (3 tiles) get **+5% damage, +5% fire rate and +5% range**
(confirmed by the owner). Doesn't attack.

**Retrofit, Signal Booster (proposed), 1,380:** the radius grows to 168 px, and +5% to all three boosts, stacking on top
(+10% each). The formula prices it high because it raises three boosts over a bigger area; the owner may override.
Look: a taller antenna mast.

**Path 1, Damage boost:**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Amplifier | 615 | Damage boost +15% |
| 2 | Power Relay | 860 | +22% |
| 3 (primary) | Overcharge Link | 2,460 | +32% |
| 4 | Surge Link | 3,940 | +40% |
| Mastery | Battle Network | 9,845 | **+50% damage** |

**Path 2, Speed boost (fire rate):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Clock Sync | 615 | Fire-rate boost +15% |
| 2 | Fast Sync | 860 | +22% |
| 3 (primary) | Overclock Link | 2,460 | +32% |
| 4 | Turbo Link | 3,940 | +40% |
| Mastery | Rapid Network | 9,845 | **+50% fire rate** |

**Path 3, Range boost:**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Spotting Relay | 370 | Range boost +15% |
| 2 | Wide Relay | 515 | +22% |
| 3 (primary) | Targeting Link | 1,475 | +32% |
| 4 | Long Link | 2,365 | +40% |
| Mastery | Overwatch Network | 5,910 | **+50% range** |

**Pricing value:** a range boost counts at 0.6 of a damage or fire-rate boost (it helps less), and the radius counts by
the area it covers.

**Boost maths:** a path's boost replaces the stock 5% for that stat (it doesn't add to it). The Retrofit's extra +5%
stacks on whatever the tower gives. Example: Damage path mastery + Retrofit = +55% damage, +10% fire rate, +10% range
(+ the secondary's two steps).

**Combinations (primary + secondary capped at 2):**
- **Damage + 2 Speed:** +50% damage and +22% fire rate. The DPS amplifier.
- **Speed + 2 Range:** +50% fire rate, +22% range.
- **Range + 2 Damage:** +50% range, +22% damage. For long-range clusters.

**Counters:** none directly; it multiplies the towers around it.

**Edge cases:**
- **Which towers it boosts:** every tower in its radius except other Boost Towers. Do Utility towers' effects count (a
  Radar's ping radius, the Scrapyard's income)? Confirmed: only damage, fire rate and range stats, so the Radar's range
  grows, but income doesn't.
- **Disruptors:** an EMP that knocks the Boost Tower offline switches its boosts off.
- **The Siphon enemy's aura:** it applies after the boost.

**Look (for the art phase):** a mast with a glowing beacon ring and pulses of light to nearby towers; boosted towers
show a small chevron. The Retrofit adds a taller antenna. Per path:
- **Damage:** a red ring.
- **Speed:** a yellow ring.
- **Range:** a blue ring.

## 14. Radar Tower

- **Class:** Utility. **Weapon type:** Energy.
- **Description (owner):** Radar is able to detect and alert nearby towers of stealthy or otherwise hidden enemies. "I've lost the bleeps, I've lost the sweeps, and I've lost the creeps."
- **Paths:** 1. Power/Range; 2. Speed/Frequency; 3. Special Targeting.
- **Notes (owner):** Enemies in range are pinged for a brief moment, allowing nearby towers to target them. ping-rate increased through upgrades Upon reaching a certain upgrade, enemies withing a small secondary circle are dealt energy damage for as long as they're in that range. (High-Energy Non-Ionizing Radiation damage)

### Design

**Status: designed, confirmed by the owner with changes (2026-10-15).** The choices under Decided are the owner's. The
stock stats and upgrade effects are Claude's proposals, confirmed as the design; the balance probe tunes their numbers. Prices come from the pricing formula (the
non-damage rule: stock value = build cost).

**Decided (owner, 2026-10-15):**
- **The ping reveals cloaked enemies (Phantom, Wraith) and burrowed ones (Burrower; the enemy spec's doppler ping).**
- **Only towers within the radar's range** can use a ping (the owner's "nearby towers").
- **Stock ping: every 3 s, revealing for 1 s.**
- **Path 1 (Power/Range):** range, and **the radiation circle turns on at step 3**: enemies inside a small inner circle
  take energy damage for as long as they're in it (owner's note: "high-energy non-ionizing radiation").
- **Path 2 (Speed/Frequency):** **pings more often, and each lasts longer; the mastery is constant.**
- **Path 3 (Special Targeting):** **unmasking**: the advanced reveals.
- **575 credits**; **Retrofit: a bigger dish** (+range). The owner changed it from a second antenna.
- **The radiation circle needs a ping:** it only hurts enemies that are revealed (owner). Cloaked enemies inside take
  nothing until a ping lands.

**Stock (proposed):** 575 credits; a 160 px radius. Every 3 s it pings: for 1 s, cloaked enemies inside are targetable,
and burrowed enemies show, so towers that can hit underground (the Mortar's Bunker Buster, the Mine Layer) can target
them. Only towers within the radar's 160 px benefit. Doesn't attack.

**Pricing value:** reveal coverage (the share of time revealed) × the area covered × the kinds of enemy it reveals; the
radiation circle priced as damage. This joins the Pricing section under the non-damage rule.

**Retrofit, Bigger Dish, 305:** +20 radius (180 px), so more area and more towers inside it. Look: a larger dish.

**Path 1, Power/Range (range, then radiation):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Bigger Array | 305 | 180 px radius |
| 2 | Tall Mast | 685 | 200 px |
| 3 (primary) | Radiation Emitter | 585 | **Radiation circle:** enemies within 60 px take 15 energy damage/s while inside |
| 4 | High-Power Emitter | 3,995 | 220 px radius; radiation 25/s within 70 px |
| Mastery | Microwave Array | 6,440 | 230 px radius; radiation 40/s within 80 px |

**Path 2, Speed/Frequency:**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Faster Sweep | 255 | A ping every 2.7 s, revealing for 1.1 s |
| 2 | Pulse Compression | 640 | Every 2.4 s, for 1.2 s |
| 3 (primary) | Rapid Sweep | 2,070 | Every 2 s, for 1.3 s |
| 4 | Phased Array | 4,485 | Every 1.6 s, for 1.3 s |
| Mastery | Constant Track | 10,350 | **Constant:** everything hidden in range stays revealed |

**Path 3, Special Targeting (unmasking):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Signal Analysis | 230 | Pings expose the **Decoy Beacon's** fake rank: towers in range rank it correctly |
| 2 | Disguise Breaker | 460 | Pings **unmask the Masquerade** early |
| 3 (primary) | Track Lock | 1,930 | Reveals last 1.3 s |
| 4 | Illusion Filter | 2,390 | Pings mark **Mirage holograms** as fakes: towers in range stop shooting them |
| Mastery | Total Exposure | 3,590 | Revealed enemies can't re-cloak, re-disguise or re-burrow for 5 s after leaving the radar's range |

**Combinations (primary + secondary capped at 2):**
- **Frequency + 2 Power:** near-constant reveals over a bigger area.
- **Power + 2 Frequency:** a radiation field with faster pings.
- **Unmasking + 2 Frequency:** every trick exposed, more often.

**Counters:**
- **Cloak** (Phantom, Wraith) and **burrowing**: at stock.
- **Disguise** (Masquerade), **decoys** (Decoy Beacon, Mirage): the unmasking path.
- **The Wraith:** the radiation is energy damage, but it **needs a ping** (owner): a cloaked Wraith only takes it while
  revealed. Unlike the Railgun's ion trail, which hits cloaked enemies.

**Edge cases:**
- **Several radars:** overlapping pings don't stack; each tower uses any radar it's inside.
- **The CAS Gunship's Radar Retrofit:** a mobile reveal, the same rules within its orbit.
- **EMPs:** an EMP that knocks the radar offline stops its pings.
- **Bosses:** no special rule.
- **The Enemy spec:** "a Sensor Array upgrade reveals it" (Decoy Beacon, Masquerade) now points to this tower's
  unmasking path.

**Look (for the art phase):** a mast with a rotating radar dish and a green sweep line, and a ping ring that expands on
each pulse. The Retrofit adds a second antenna. Per path:
- **Power:** a microwave emitter horn and a faint red inner circle.
- **Frequency:** a phased-array panel.
- **Unmasking:** an analysis cabinet with blinking lights.

## 15. Cryo Tower

- **Class:** Support. **Weapon type:** Field.
- **Description (owner):** Produces a wave of sub-zero temperature gasses that stunt the mobility of enemies within range. "The military had to put restrictions on these machines after a group of soldiers got caught having a snowball fight in the middle of a heatwave."
- **Paths:** 1. Slowing; 2. Power/Range; 3. Speed.

### Design

**Status: designed, confirmed by the owner (2026-10-15).** The choices under Decided are the owner's. The stock stats
and upgrade effects are Claude's proposals, confirmed as the design; the balance probe tunes their numbers. Prices come from the pricing formula (the
non-damage rule: stock value = build cost).

**Decided (owner, 2026-10-15):**
- **Class: Support** (kept): it holds enemies in the damage towers' range.
- Hits **air and ground**.
- **No damage at stock:** it only slows.
- **Stock slow 20%.**
- **150 credits.**
- **Path 1 (Slowing):** **a deeper slow, then permanent slowing; the mastery freezes.**
- **Path 2 (Power/Range):** **frostbite damage and range.**
- **Path 3 (Speed):** **faster waves and faster travel** (the gas spreads faster).
- **Retrofit: a coolant tank** (a longer slow).

**Stock (proposed):** 150 credits; a wave of cold gas every 2 s fills a 110 px radius. Every enemy in it, air and
ground, is slowed 20% for 1.5 s. The strongest slow applies (slows don't stack), as today; bosses take half.

**Pricing value:** a slow counts as its strength × its uptime (1 − e^(−duration ÷ interval)) × the area covered; a
permanent slow counts 1.5× its strength; frostbite damage is priced as damage. This joins the Pricing section under the
non-damage rule.

**Retrofit, Coolant Tank (proposed), 80:** the slow lasts 2.2 s. Look: a frosted coolant tank on the side.

**Path 1, Slowing (deeper, permanent, freeze):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Colder Gas | 120 | Slow 28% |
| 2 | Sub-Zero Gas | 210 | Slow 35% |
| 3 (primary) | Permafrost | 1,705 | Enemies chilled by it keep a **permanent 10% slow** for the rest of their life, even outside its range |
| 4 | Deep Chill | 2,905 | Slow 45%; permanent 15% |
| Mastery | Deep Freeze | 8,460 | Slow 50%; permanent 20%; **every 4th wave freezes** enemies solid for 1 s (bosses 0.3 s) |

**Path 2, Power/Range (frostbite and range):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Frostbite | 105 | Each wave does 5 damage; 120 px radius |
| 2 | Hard Frost | 230 | 10 damage; 130 px |
| 3 (primary) | Ice Storm | 790 | 18 damage; 145 px |
| 4 | Biting Cold | 695 | 26 damage |
| Mastery | Blizzard | 4,870 | 36 damage; 165 px |

**Path 3, Speed (faster waves and travel):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Faster Vents | 25 | A wave every 1.75 s; the gas spreads faster |
| 2 | Pressurised Gas | 65 | Every 1.5 s |
| 3 (primary) | Rapid Vents | 185 | Every 1.2 s |
| 4 | Turbo Vents | 290 | Every second |
| Mastery | Cold Front | 1,575 | A constant cold field: everything inside stays slowed |

The Speed path is cheap by the formula because it only raises the slow's uptime; with Power/Range as the secondary it
also raises frostbite damage per second.

**Combinations (primary + secondary capped at 2):**
- **Slowing + 2 Speed:** a deep, near-constant slow, with permanent chill.
- **Power + 2 Slowing:** a frostbite field that slows 35%.
- **Speed + 2 Power:** constant waves of light frostbite.

**Counters:**
- **Rushers and Fury Drones:** the slow and the permanent chill.
- **Blink Stalkers:** a slow resets their blink charge (the enemy spec).
- **Flyers:** it hits them.
- **The Capacitor's charge:** the freeze (mastery) cancels it, like a stun.

**Edge cases:**
- **The Rampart:** immune to slows and freezes.
- **Bosses:** half slow, a 0.3 s freeze.
- **Permanent slows:** the strongest slow applies, so a permanent 20% matters only once the enemy leaves stronger slows.
- **The Wraith:** is frostbite energy damage? It's a Field effect, so it depends on the parked physical/energy decision.

**Look (for the art phase):** a squat tank with frosted vents breathing white gas in pulses; chilled enemies get a frost
tint. The Retrofit adds a coolant tank. Per path:
- **Slowing:** blue-white ice crystals.
- **Power:** jagged frost spikes.
- **Speed:** extra vents.

## 16. Shockwave Generator

- **Class:** Assault. **Weapon type:** Field.
- **Description (owner):** Generates powerful shockwaves by creating small nuclear explosion. "Radioactive fallout? What radioactive fallout?"
- **Paths:** 1. Power/Range; 2. Speed; 3. Effect.

### Design

Not started. Rounds go in roster order.

## 17. Scrapyard

- **Class:** Utility. **Weapon type:** None.
- **Description (owner):** Various collections of scrap metal sold at a profit. "One mans toxic waste is another mans potpourri"
- **Paths:** 1. Passive Income; 2. Kill Income; 3. Discounts.

### Design

Not started. Rounds go in roster order.

## 18. Magneto Tower

*Claude's proposal (2026-10-14), added to the roster at the owner's request.*

- **Class:** Defense. **Weapon type:** Field.
- **Description:** A massive electromagnet on a rotating pylon that grabs the machine army by its own metal, dragging every enemy in range back down the track. "Opposites attract. Unfortunately for them, so does everything else."
- **Paths:** 1. Pull Strength; 2. Field Size; 3. Polarity.

### Claude's writeup (proposal, for the owner to mark up)

Numbers are placeholders for the balance probe.

**What it does (stock):** every 3 s it pulses a magnetic field around itself. Every enemy inside is **dragged back
along the track** (about 25 px) and stays **slowed** for a moment after (about 20% for 1 s) as it "unsticks".
- **Weight matters:** the pull scales down with the enemy's weight. Swarm units get yanked; Tanks barely budge. Weight
  can come from the enemy's armour (the roster already has it), so no new stat is needed.
- **Bosses** take a quarter of the pull, like today's Graviton Projector.
- **The Rampart** is immune to slows, stuns and shoves, so it ignores the Magneto completely (the enemy spec's rule).
- **Flyers:** no effect until the Field path's top upgrades (grounding, below).
- **Damage:** none at stock. It's a Defense tower; damage only comes from the Polarity path.

**Optional Retrofit, "Superconducting Coil":** pulses come about 15% faster and the slow lasts a little longer. Look:
the coil frosts over, with a thin ring of cold vapour around it.

**Paths:**

| Step | Pull Strength (Power) | Field Size (Range) | Polarity (Effect) |
|---|---|---|---|
| 1 | Stronger Pull: longer drag | Wider Field: bigger radius | Plate Ripper: each pulse tears off 1 armour (up to a cap) |
| 2 | Heavy Lift: heavy enemies resist less | Lingering Charge: the slow lasts longer | Scrap Shrapnel: torn plates fly off and hit nearby enemies |
| 3 (primary) | **Lockdown:** a strong pulse every 3rd cycle **stuns** for 0.5 s (cancels the Capacitor's charge, resets the Blink Stalker's) | **Grounding Field:** flyers in the field are **pulled down to the track** for 2 s, where ground-only towers can hit them | **Reverse Polarity:** every other pulse **repels** instead, flinging enemies into each other for impact damage |
| 4 | Faster Pulses | Field Persistence: grounded flyers stay down longer | Magnetized: enemies hit by Polarity take +10% damage from Ballistic towers (metal sticks to metal) |
| Mastery | **Event Horizon:** pulls hard enough to **hold** enemies still for 1 s every 3rd pulse | **Magnetosphere:** a huge field; all flyers inside are grounded while they stay in it | **Scrapstorm:** destroyed enemies' scrap is flung at the next enemies, damage growing with how much is dying nearby |

**Combinations (primary + secondary 2):**
- **Pull + 2 Field:** a wide, strong undertow that slows longer. The crowd-control build.
- **Field + 2 Polarity:** grounds flyers and strips their armour, for the ground towers to finish. The anti-air
  support build.
- **Polarity + 2 Pull:** a strong repel/pull rhythm that shreds armour. The anti-Tank build.

**Counters it carries** (all through paths, per the rules):
- **Flyers** (Wraith, Phantom, Locust, Shrike, Gunship, Leviathan): Grounding Field and Magnetosphere. Bosses are
  grounded for a quarter of the time.
- **The Capacitor's EMP charge:** Lockdown's stun cancels it.
- **Blink Stalker and Shifter:** the stun resets their blink charge.
- **Armour** (Siege Mech, Titan, Rampart's armour): Plate Ripper. It still strips armour on the Rampart: the Rampart is
  immune to the pull but not to losing plates (to confirm).
- **Burrower:** not a counter. Magnets don't reach underground (to confirm).

**Look and animation:**
- **Base:** a heavy pivot base with a horseshoe or ring electromagnet, red and grey poles, and cables.
- **Pulse:** field lines arc outward, nearby enemies visibly tilt towards the tower, and loose bolts fly off them.
- **Per path:**
  - **Pull Strength:** a thicker, darker coil.
  - **Field Size:** extra ring emitters around the base.
  - **Polarity:** a split blue and red pole that flips on each repel.
- **Performance:** keep the animated parts (field lines, pole glow) between `Draw.dyn(true)` and `dyn(false)`.

**Open questions:**
1. Does the pull use the enemy's armour as its weight, or should the roster get a separate weight stat?
2. Should grounded flyers count as ground for **all** towers, including the Mine Layer's mines?
3. Is the Magneto the replacement for today's Graviton Projector? Its shove and pull job moves here.
4. Can a Rampart lose armour to Plate Ripper while ignoring the pull?

### Design

Not started. Rounds go in roster order.

## 19. Tractor Tower

*Claude's proposal (2026-10-14), added to the roster at the owner's request.*

- **Class:** Defense. **Weapon type:** Energy.
- **Description:** A dish-mounted emitter that locks a tractor beam onto a single enemy and hauls it back down the track before letting go. "You're going the wrong way. Let me help."
- **Paths:** 1. Pull Distance; 2. Recharge; 3. Grip.

### Claude's writeup (proposal, for the owner to mark up)

Numbers are placeholders for the balance probe.

**What it does (stock):** it locks onto one enemy in range (by targeting mode: First, Strongest and so on), holds it
in a beam for 1.5 s, and **drags it back along the track** (about 80 px) before releasing. Then it recharges (about
6 s).
- **Air and ground:** a tractor beam doesn't care about the ground, so it can pull flyers back along their flight
  path. That's its signature.
- **While held,** the enemy can't move forward, blink or use abilities; the hold works like a stun for those rules.
- **Bosses:** a much shorter pull and a shorter hold.
- **The Rampart** is immune (shoves).
- **Damage:** none at stock.

**Optional Retrofit, "Twin Emitter":** a second, weaker beam that pulls a second enemy half as far. Look: the dish
grows a second, smaller emitter.

**Paths:**

| Step | Pull Distance (Power) | Recharge (Speed) | Grip (Effect) |
|---|---|---|---|
| 1 | Longer Haul: pulls further | Quick Release: shorter recharge | Firm Grip: heavier enemies (Tanks, elites) are pulled further |
| 2 | Stronger Beam: holds longer | Capacitor Bank: stores a second charge | Crushing Grip: the held enemy takes damage over time (energy) |
| 3 (primary) | **Rewind:** the pull sends the enemy back to where it was a few seconds ago (a big pull, track-aware) | **Rapid Lock:** short pulls in quick succession on several enemies | **Lift and Drop:** ground enemies are lifted, then **slammed** down, stunning nearby enemies |
| 4 | Longer Rewind | Overclocked Emitter: even faster recharge | Grip Lock: the held enemy's barrier and abilities are switched off while held |
| Mastery | **Undo:** once per round, sends one non-boss enemy **all the way back to its entrance** | **Tractor Array:** three beams at once, on three enemies | **Gravity Hammer:** the slam stuns everything in a wide area and shatters barriers |

**Combinations:**
- **Pull Distance + 2 Recharge:** fewer, very long rewinds, a little more often. The anti-leak build.
- **Recharge + 2 Grip:** constant short holds that drain barriers and abilities. The anti-elite build.
- **Grip + 2 Pull Distance:** big lifts and slams that also push enemies back. The crowd-stun build.

**Counters it carries:**
- **Leakers and Rushers** (Fury Drone, Needle, Strike Drone): Rewind and Undo send the fastest threats back.
- **Flyers:** pulls them back by default. It's a strong answer to the Wraith, which is cloaked: the beam needs the
  Radar Tower to reveal it first.
- **Aegis Walker and Bulwark barriers:** Grip Lock and Gravity Hammer.
- **Healers and haste auras** (Repair Bot, Mender Hulk, Rally Beacon enemy): Grip Lock switches their abilities off
  while they're held.
- **The Capacitor:** a hold cancels its charge, like a stun.
- **Masquerade and Decoy Beacon:** no special effect; it pulls whatever its targeting mode picks.

**Look and animation:**
- **Base:** a dish emitter on a slim mast, with a cyan beam that shows a rippling cone towards the target.
- **The pull:** the held enemy hovers slightly, trails afterimages and glides backwards.
- **Per path:**
  - **Pull Distance:** a longer barrel on the dish.
  - **Recharge:** capacitor drums on the base that glow as they fill.
  - **Grip:** clamp arms on the dish rim.
- **Performance:** only the beam and the capacitor glow are animated.

**Open questions:**
1. Should **Rewind** go back in distance (pixels) or in time (where the enemy was N seconds ago)? Time feels better
   with fast enemies; distance is simpler to balance.
2. Is **Undo** (back to the entrance) too strong, even at once per round and non-boss only? Alternative: back to the
   start of its current lane segment.
3. Does a pulled enemy's progress reset for **First** targeting (it's now further back), or keep its old place?
4. Can the beam hold a flyer that's mid-cloak, or does it drop it when the cloak returns?

#### Magneto and Tractor: shared questions

- **Wave pacing:** pulling enemies back makes rounds longer. The bot probe should check round length and the
  end-of-round "stragglers" feel.
- **Stacking:** the Magneto's pull and the Tractor's pull on the same enemy: add up, or the strongest applies? (Today
  slows don't stack; the strongest applies.)
- **The Graviton Projector:** both replace its job; it isn't on the WIP roster.
- **The Defense class** would go from 1 tower (Mine Layer) to 3, or 4 with the Cryo Tower moved from Support.

### Design

Not started. Rounds go in roster order.

## Gap review (Claude, 2026-10-14, for the 17-tower list)

- **Defense was nearly empty:** only the Mine Layer. Nothing pushed or pulled, stunned or blocked. The Cryo Tower slows
  but is filed under Support; by the class definitions it reads as Defense. (The Magneto and Tractor fill push, pull
  and stun.)
- **Nothing removes enemy defences except armour:** no barrier stripping (Aegis Walker, Bulwark), no immunity removal
  (Rampart, boss slow resist), no ability silencing (Repair Bot and Mender Hulk healing, the Rally Beacon enemy's
  haste). Suggested: a Utility **EMP Emitter** that strips barriers, switches off immunities and silences abilities.
- **Nothing protects towers from the Disruptors** (Jammer, Blackout Rig and Capacitor EMPs; the Siphon's slow-fire
  aura). Suggested: an EMP-shielding path on the Rally Beacon, or part of the EMP Emitter.
- **Healing enemies:** suggested a Chemical Plant upgrade, **Corrosion**: soaked enemies can't be repaired.
- **To pin down in the list:**
  - **Air or ground** per tower (seven flying enemies).
  - **Wraith counters** (energy that hits air): Laser, Tesla, Radar (late), maybe the Shockwave Generator and Chemical
    damage over time.
  - **Burrower counters:** Mine Layer, the Mortar's Penetration path, the Artillery's Special Effects.
- **Overlaps:** Assault is 11 of 17. The Mortar Tower and Rocket Salvo need clearly different jobs (the Artillery Cannon
  is distinct because it's aimed). Gun Turret vs Anti-Aircraft Turret is fine if the AA gun is clearly air-first.
- **Small things:** 17+ towers need more build hotkeys than today's 15; the Railgun and Chemical Plant share a quote; the
  CAS Gunship has "being with with"; "Chemical" isn't a weapon type on the page yet.

## Other Defense ideas (Claude, 2026-10-14, not on the list)

| Idea | Covers | Weapon | Paths | Answers | Quote |
|---|---|---|---|---|---|
| Barricade Deployer | Block: temporary wall sections with HP on the track | Deployable | Wall HP / Rebuild Speed / Spikes | Rushers, Swarms (Tanks smash through; flyers ignore it) | "Hold the line! No, literally, it's a line. Of concrete." |
| Hardlight Gate | Block: an energy gate that opens and closes on a cycle | Energy | Hold Time / Cycle Speed / Overload | Rushers, Blink Stalkers | "Please wait. Your call is important to us." |
| Concussion Mortar | Stun: flash-bang shells, little damage | Explosive | Stun Duration / Blast Radius / Fire Rate | Capacitor charge, crowds | "It's not loud, it's just very, very persuasive." |
| Taser Post | Stun: barbed darts that stun one enemy and pass the shock on | Energy | Stun Duration / Chaining / Reload | Bosses (small stuns), elites | "Don't tase me, bro. Actually, never mind, you're a robot." |
| Tar Sprayer (Foam Cannon) | Slow: sticky foam on the track | Chemical | Slow Strength / Puddle Size / Duration | Choke points, Rushers | "Riot control, but for robots that don't have rights." |
| Gravity Anchor | Slow: clamps the heaviest enemy in range | Field | Anchor Strength / Number of Anchors / Range | Tanks, bosses | "Heavy is good. Heavy is reliable. Heavy is now very, very slow." |
| Air Cannon (Repulsor) | Push: blasts enemies back with compressed air | Field or Ballistic | Knockback Distance / Fire Rate / Blast Width | Early-game crowds | "Nature's leaf blower, now with 40% more aggression." |
| Decoy Projector | Lure: a fake core enemies divert towards for a few seconds | Energy | Decoy Time / Decoys / Lure Range | Everything (turns the Mirage's trick around) | "Look, a distraction!" |
| Time Dilator | Slow: a field where time and enemy abilities slow down | Field | Dilation Strength / Field Size / Ability Drain | Blinks, healing, EMP charge-ups | "Five more minutes." |
