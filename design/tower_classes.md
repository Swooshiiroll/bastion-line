# Bastion Line Tower Classes (reference sheet)

A reusable reference for sorting the towers. Every tower has one **class**: **Assault, Support, Defense or Utility**
(owner, 2026-10-10). Each tower also carries a **weapon type** (Ballistic, Energy, Explosive...) as a descriptive
sub-tag. The owner's class names and meanings are fixed; the wording, the weapon types and the edge cases are a
**draft by Claude for the owner to edit**. The tower rework spec is `design/towers.md` (issue #55).

History: roles (2026-10-08) were replaced by weapon classes (2026-10-09), which were replaced by these four classes
(2026-10-10). The weapon classes live on below as the weapon-type sub-tag.

## Rules

**Decided (owner, 2026-10-10):**
- **Four classes:** Assault (damage), Support (boosts other towers), Defense (control: slow, stun, push, block),
  Utility (tools: reveal, strip defences, economy).
- Every tower has **exactly one** class.
- The class **groups the shop** (and the Codex).
- **Economy towers are Utility.**
- **Weapon type stays as a sub-tag:** Ballistic, Energy, Explosive and the rest describe how a tower attacks. They
  group nothing and carry no rules for now.

**To be decided (TBD):**
- What else a class does in play. The candidates are listed under Parked; none is adopted.
- How the weapon types relate to the enemy spec's physical/energy damage split, which the Wraith depends on (decide
  later).

**How to classify:** pick the class by the tower's **main job** with its stock setup. Upgrade paths don't change the
class: a tower has exactly one. If a tower does two jobs, the one it's built and bought for wins (see Edge cases).

**How to edit:** each class is a `## Name` section with the same bullets. "Strengths" and "Weak spots" are design
reference only, with no rules attached. "Look cues" are a starting point for the art phase. "Today's towers" is a
reference; the new roster comes from the owner.

## Assault

- **Job:** deals the damage. The towers that kill enemies.
- **Counts as Assault:** a tower whose main job is damage, single-target or area, ground, air or both.
- **Strengths:** the backbone of every defence; the only class that wins on its own.
- **Weak spots:** loses to what it can't answer (armour, flyers, cloak, crowds) without the other classes.
- **Look cues:** weapons up front: barrels, emitters, launchers, coils; aggressive silhouettes.
- **Today's towers:** Pulse Turret, Plasma Mortar, Railgun, Arc Coil, Laser Lance, Missile Battery, Flak Battery,
  Nova Reactor, Drone Bay.

## Support

- **Job:** boosts other towers: damage, range, fire rate and similar.
- **Counts as Support:** a tower whose main job is making other towers better.
- **Strengths:** multiplies a cluster of Assault towers; scales with how many towers it covers.
- **Weak spots:** worthless alone; competes for space next to the towers it boosts.
- **Look cues:** pylons, relay masts and amplifier rings; beams or glows linking it to nearby towers.
- **Today's towers:** Amplifier Pylon.

## Defense

- **Job:** holds the line. It controls enemies: slows, stuns, pushes back and blocks.
- **Counts as Defense:** a tower whose main job is changing how enemies move, not killing them. Light damage on the
  side doesn't change that.
- **Strengths:** buys time for Assault towers; answers Rushers, Evaders and bosses.
- **Weak spots:** kills little by itself; some enemies resist control (Rampart, boss slow resist).
- **Look cues:** heavy, planted bases; emitter plates, domes and field rings; cold, gravity or force-field glows.
- **Today's towers:** Cryo Emitter, Graviton Projector.

## Utility

- **Job:** the tools: reveal hidden enemies, strip enemy defences, and the economy.
- **Counts as Utility:** a tower whose main job is information (reveal, marks), removing enemy defences (barriers,
  armour, immunities), or credits (income, discounts, refunds).
- **Strengths:** answers the tricks (cloak, decoys, disguise, barriers) and pays for the rest of the defence.
- **Weak spots:** no real damage; easy to over-build.
- **Look cues:** dishes, antennas, scanners and projectors; for economy, cranes, hoppers and a warm credit glow.
- **Today's towers:** Sensor Array, Nullifier, Scrapyard.

## Weapon types (sub-tag)

Descriptive only: how a tower delivers its effect. Each tower gets one. Non-attacking towers are **None**. These are the
earlier weapon classes, kept as tags (owner, 2026-10-10).

| Weapon type | What it is | Today's towers |
|---|---|---|
| Ballistic | Physical projectiles at a target: slugs, bolts, rounds, flechettes, rails | Pulse Turret, Railgun |
| Energy | Beams, lasers and lightning, no flight time; chains jump between targets | Laser Lance, Arc Coil |
| Explosive | Shells, missiles and bombs that burst where they land, and what the blast leaves behind | Plasma Mortar, Missile Battery, Flak Battery |
| Field (proposed) | Pulses, auras and shockwaves centred on the tower, covering its radius | Cryo Emitter, Graviton Projector, Nova Reactor, Nullifier |
| Deployable (proposed) | Launched units (drones) that act on their own away from the tower | Drone Bay |
| None | Doesn't attack | Amplifier Pylon, Sensor Array, Scrapyard |

Field and Deployable are proposals. If they're dropped, the field towers become Energy and the Drone Bay needs a call
(Ballistic or Explosive).

## Edge cases (owner's calls)

Claude's suggestion comes first; the owner decides.

| Case | Suggested class | Why | Alternative |
|---|---|---|---|
| Sensor Array: reveals cloaked enemies **and** marks enemies to take extra damage | Utility | Reveal is the job only it can do | Support (the marks raise every tower's damage) |
| Nullifier: strips barriers, armour and immunities, with light damage | Utility | Removing defences is its job | Defense |
| Nova Reactor: shockwave around itself | Assault | Its job is damage | |
| Cryo Emitter: slows plus light damage (the Shatter path makes chilled enemies take more damage) | Defense | The slow is its job | |
| Flak Battery: air-only damage | Assault | Damage, just only against flyers | |
| Drone Bay | Assault | Its drones do damage | |
| A path that shifts a tower's job (e.g. a damage path on a Defense tower) | Keep the stock class | Exactly one class per tower | |

## Parked (TBD): what a class could do in play

Not adopted. These are listed so later rounds can pick from them.

- **Class-wide boosts:** buffs, upgrades or research that target a class (e.g. Support towers that boost only Assault).
- **Enemy counters by class:** enemy abilities that hit a class (e.g. EMP knocks out Assault towers longer).
- **Build limits or costs by class.**
- **Weapon types vs enemy defences** (the physical/energy link, decide later): the enemy spec calls every
  non-projectile tower, plus burn, damage over time and Arc Coils, "energy" (`design/new_enemies.md`, Wraith, on
  `design/enemy-rework`). The weapon types could replace that split, map onto it, or sit beside it.
