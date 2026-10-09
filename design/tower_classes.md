# Bastion Line Tower Weapon Classes (reference sheet)

A reusable reference for sorting towers by **weapon class**: how a tower delivers its effect. It replaces the tower
roles (owner, 2026-10-09). **Draft by Claude for the owner to edit**: rename, merge, split, add or delete classes,
and rewrite any line. The tower rework spec is `design/towers.md` (issue #55).

## Rules

**Decided (owner, 2026-10-09):**
- Every tower has **exactly one** weapon class.
- The class **groups the shop** (and the Codex).
- The class is a **weapon class**: it is about how the tower attacks (or, for towers that don't attack, what it does
  instead), not its size or its technology.

**To be decided (TBD):**
- What else a class does in play. Candidates are listed under Parked at the end; none is adopted.
- How the classes relate to the enemy spec's physical/energy damage split, which the Wraith depends on (decide later).

**How to classify:** use the tower's **primary delivery**, meaning how its stock attack reaches the enemy. Upgrade
paths don't change the class, because a tower has exactly one.

**How to edit:** each class is a `## Name` section with the same bullets. "Strengths" and "Weak spots" are design
reference only, with no rules attached. "Look cues" are a starting point for the art phase. "Today's towers" is a
reference; the new roster comes from the owner.

## Ballistic

- **What it is:** fires physical projectiles at a target: slugs, bolts, rounds, flechettes, rails.
- **Counts as Ballistic:** a projectile (or a burst of them) that flies to a target and hits what it strikes, with no
  blast on impact. Piercing rounds stay Ballistic.
- **Strengths:** precise, reliable and fast to land; easy to read; good at finishing single targets.
- **Weak spots:** one target at a time; many small hits are where armour bites hardest.
- **Look cues:** barrels, breeches, ammo feeds and belts, muzzle flashes, recoil; gunmetal and brass.
- **Today's towers:** Pulse Turret (its "energy bolts" fly as projectiles), Railgun.

## Energy

- **What it is:** directed energy: beams, lasers and lightning that reach the target with no flight time.
- **Counts as Energy:** a beam or arc that connects tower and target directly, or a chain that jumps between targets.
- **Strengths:** instant hits; often ignores armour or ramps up on a target; chains handle crowds.
- **Weak spots:** short range or a ramp-up time; loses power over jumps or distance.
- **Look cues:** emitters, lenses, coils and capacitors; glowing lines and a steady charge glow.
- **Today's towers:** Laser Lance, Arc Coil. If Field (below) is dropped, the field towers come here too.

## Explosive

- **What it is:** shells, missiles and bombs that burst where they land.
- **Counts as Explosive:** anything that does area damage at an impact point, including what the blast leaves behind
  (burning pools, shrapnel, airbursts).
- **Strengths:** hits groups; good against swarms and packs.
- **Weak spots:** flight time and blast spread; some can't hit flyers, others only hit flyers.
- **Look cues:** launch tubes and mortar barrels, missile racks, warhead tips, hazard markings; smoke on firing.
- **Today's towers:** Plasma Mortar, Missile Battery, Flak Battery.

## Utility

- **What it is:** doesn't attack. It changes the fight: boosts towers, reveals and marks enemies, strips defences.
- **Counts as Utility:** a tower whose main job is an effect on towers or enemies rather than damage. A little damage
  on the side doesn't change that.
- **Strengths:** multiplies the towers around it; answers tricks (cloak, decoys, disguise) and defences.
- **Weak spots:** worthless alone; competes for space with damage towers.
- **Look cues:** dishes, antennas, pylons, projectors, rotating scanners; soft ring fields.
- **Today's towers:** Amplifier Pylon, Sensor Array.

## Economy

- **What it is:** doesn't fight. It makes or saves credits.
- **Counts as Economy:** income, kill-credit bonuses, discounts and refunds.
- **Strengths:** pays for the rest of the defence over a run.
- **Weak spots:** no defence of its own; slow to pay back.
- **Look cues:** cranes, hoppers, conveyors and scrap piles, with a warm credit glow; industrial.
- **Today's towers:** Scrapyard.

## Field (proposed: accept or drop)

A split out of Energy, for towers that affect **everything in an area around themselves** instead of aiming at a
target.

- **What it is:** pulses, auras and shockwaves centred on the tower: cold, gravity, dampening, plasma.
- **Counts as Field:** the effect starts at the tower and covers its whole radius, with no projectile and no aimed
  beam.
- **Strengths:** never misses anything in range; hits air and ground alike; good at control (slow, shove, strip).
- **Weak spots:** only its own radius; usually light damage per enemy.
- **Look cues:** domes, rings and pulse plates; expanding rings on each pulse.
- **Today's towers:** Cryo Emitter, Graviton Projector, Nova Reactor, Nullifier. **If dropped,** they go under Energy
  (Nullifier possibly under Utility; see Edge cases).

## Deployable (proposed: accept or drop)

For towers whose attack is **launched units that act on their own**.

- **What it is:** a bay or hangar that sends out drones (or other units) that hunt, bomb or intercept away from the
  tower.
- **Counts as Deployable:** the damage is dealt by units that leave the tower and move by themselves.
- **Strengths:** reaches anywhere on the map; units can chase flyers and leakers.
- **Weak spots:** units take time to arrive; spread thin over a big map.
- **Look cues:** hangar bays, launch rails, docking cradles and landing lights.
- **Today's towers:** Drone Bay. **If dropped,** it needs a call: Ballistic (its drones shoot) or Explosive (the
  bomber path).

## Edge cases (owner's calls)

With exactly one class per tower, a few towers sit between classes. Claude's suggestion is first; the owner decides.

| Case | Suggested class | Why | Alternative |
|---|---|---|---|
| Pulse Turret: "energy bolts" | Ballistic | They fly to the target as projectiles | Energy, if the name should rule |
| Flak Battery: airburst shells | Explosive | Area burst at the impact point | Ballistic (it's a cannon) |
| Plasma Mortar's burning pools | Explosive | Left behind by an Explosive shell | |
| Missile Battery | Explosive | Each missile bursts on impact | |
| Railgun's piercing line | Ballistic | Still a projectile, it just keeps going | Energy (rail as an energy weapon) |
| Arc Coil: chain lightning | Energy | An arc, no flight time | Field, if accepted |
| Nova Reactor: shockwave | Field (Energy if Field is dropped) | Centred on the tower, covers its radius | |
| Nullifier: dampening pulse with light damage | Field (Utility if Field is dropped) | Its main job is stripping defences | Utility either way |
| Drone Bay | Deployable (see above if dropped) | Units deal the damage away from the tower | Ballistic or Explosive |
| A tower whose path changes its attack (e.g. a cone, a storm field) | Keep the stock class | Exactly one class per tower | |

## Parked (TBD): what a class could do in play

Not adopted. These are listed so later rounds can pick from them (owner, 2026-10-09: "TBD").

- **Damage vs enemy defences:** enemies resist or are immune to some classes (the Wraith's energy-only rule; armour
  vs Ballistic; barriers vs Energy).
- **Class-wide boosts:** buffs, upgrades or research that target a class (e.g. a Utility tower that boosts only
  Energy towers).
- **Enemy counters:** enemy abilities that hit a class harder (e.g. EMP knocks out Energy towers longer).
- **The physical/energy link** (decide later): the enemy spec calls every non-projectile tower, plus burn, damage over
  time and Arc Coils, "energy" (`design/new_enemies.md`, Wraith, on `design/enemy-rework`). The classes could replace
  that split, map onto it, or sit beside it.
