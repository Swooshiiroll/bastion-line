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
| 2 | Mortar Tower | Assault | Explosive | Power/Penetration / Speed/Range / Blast Radius/Multi-Target | Roster only |
| 3 | Laser Tower | Assault | Energy | Power / Multi-Target / Range/Targeting | Roster only |
| 4 | Rocket Salvo | Assault | Explosive | Power / Range/Target Acquisition / Reload/Payload | Roster only |
| 5 | Anti-Aircraft Turret | Assault | Ballistic | Range / Power/Blast Radius / Speed | Roster only |
| 6 | Artillery Cannon | Assault | Explosive | Power / Speed / Special Effects | Roster only |
| 7 | Railgun | Assault | Ballistic | Power / Range/Speed / Special Effects | Roster only |
| 8 | Tesla Tower | Assault | Energy | Power (Damage) / Range/Chaining / Speed | Roster only |
| 9 | Drone Bay | Assault | Deployable | Power (overall) / Weaponry (upgrades/additions) / Speed | Roster only |
| 10 | CAS Gunship | Assault | Deployable | Speed (Attack) / Power / Weaponry Upgrades | Roster only |
| 11 | Mine Layer | Defense | Explosive | Power/Damage / Production Speed / Range | Roster only |
| 12 | Chemical Plant | Support | Chemical (in notes; not yet a listed type) | Damage/Armor stripping / Speed / Slowing | Roster only |
| 13 | Rally Beacon | Support | None | Damage boost / Speed boost / Range Boost | Roster only |
| 14 | Radar Tower | Utility | Energy | Power/Range / Speed/Frequency / Special Targeting | Roster only |
| 15 | Cryo Tower | Support | Field | Slowing / Power/Range / Speed | Roster only |
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

**Status: designed, confirmed by the owner (2026-10-15).** The choices under Decided, the stock stats and the costs are
the owner's. The upgrade effects are Claude's proposals, confirmed as the design; their numbers are tuned by the
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

**Retrofit, Water-Cooled Barrel:** **150 credits** (owner); fire rate 1.2 to 1.5/s (proposed). Look: a thick cooling
jacket around the barrel, with a small vapour wisp when it fires.

**Path 1, Power (armour-piercing):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Heavier Rounds | 100 | +6 damage |
| 2 | Hardened Tips | 250 | Its hits ignore 2 points of armour |
| 3 (primary) | AP Rounds | 600 | Ignores 50% of armour; +6 damage |
| 4 | Tungsten Core | 1,200 | Ignores 75% of armour; +8 damage |
| Mastery | Sabot Rounds | 2,500 | **Ignores armour fully**; 44 damage per hit |

**Path 2, Range/Visibility (precision):**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Long Barrel | 100 | +20 range |
| 2 | Tracer Rounds | 250 | +10 range; 10% chance of a critical hit (double damage); visible tracer lines |
| 3 (primary) | Scope | 600 | +25 range; crit chance 15% |
| 4 | Rangefinder | 1,200 | +20 range; crit chance 20% |
| Mastery | Precision Optics | 2,500 | 230 range in all (+25); crit chance 30% |

**Path 3, Multi-Target:**

| Step | Name | Cost | Effect (proposed) |
|---|---|---|---|
| 1 | Swivel Mount | 100 | Switches to a new target instantly after a kill, and doesn't fire at enemies already about to die (no wasted rounds on swarms and holograms) |
| 2 | Side Gun | 250 | A small side gun fires at a second target at 50% damage |
| 3 (primary) | Twin Mount | 600 | **2 targets** at full damage |
| 4 | Belt Feed | 1,200 | +0.3 shots/s on every barrel |
| Mastery | Triple Mount | 2,500 | **3 targets**; the extra barrels go for the weakest enemies in range (swarms, holograms) |

**Combinations (primary + secondary capped at 2):**
- **Power + 2 Multi:** an AP main gun with a side gun for the small stuff.
- **Range + 2 Power:** a long-range critical-hit gun that bites through light armour.
- **Multi + 2 Power:** three barrels of heavier rounds that partly ignore armour: a swarm clearer that doesn't stall on
  light armour.

**Upgrade costs (owner, 2026-10-15): a very steep curve.** Steps **100 / 250 / 600 / 1,200**, mastery **2,500** on every
path. A full build (75 + Retrofit 150 + primary 4,650 + secondary 350) is about **5,225 credits**, against about 1,650
for today's Pulse Turret: cheap to start, a long-run credit sink at the top. Effects stay proposals for the balance
probe.

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

Not started. Rounds go in roster order.

## 3. Laser Tower

- **Class:** Assault. **Weapon type:** Energy.
- **Description (owner):** A High-Energy Laser Emitter affixed to a rotating turret. "It does more than just blind the enemy, that's for sure."
- **Paths:** 1. Power; 2. Multi-Target; 3. Range/Targeting.

### Design

Not started. Rounds go in roster order.

## 4. Rocket Salvo

- **Class:** Assault. **Weapon type:** Explosive.
- **Description (owner):** Launches a volley of rockets at oncoming enemies. "Instead of shooting bullets, it shoots very angry telephone poles that hate absolutely everything."
- **Paths:** 1. Power; 2. Range/Target Acquisition; 3. Reload/Payload.

### Design

Not started. Rounds go in roster order.

## 5. Anti-Aircraft Turret

- **Class:** Assault. **Weapon type:** Ballistic.
- **Description (owner):** A fully automatic anti-aircraft gun. "We don't need a gun, or a nug!"
- **Paths:** 1. Range; 2. Power/Blast Radius; 3. Speed.

### Design

Not started. Rounds go in roster order.

## 6. Artillery Cannon

- **Class:** Assault. **Weapon type:** Explosive.
- **Description (owner):** A large-bore cannon that fires high-explosive shells very long distances. "It's not DiGiorno..."
- **Paths:** 1. Power; 2. Speed; 3. Special Effects.
- **Notes (owner):** User selects where the cannon should aim along the track - Does not target enemies.

### Design

Not started. Rounds go in roster order.

## 7. Railgun

- **Class:** Assault. **Weapon type:** Ballistic.
- **Description (owner):** A large cannon with magnetically polarized rails that launch a large projectile extremely far, extremely fast. "Known to cause cancer in the state of California."
- **Paths:** 1. Power; 2. Range/Speed; 3. Special Effects.

### Design

Not started. Rounds go in roster order.

## 8. Tesla Tower

- **Class:** Assault. **Weapon type:** Energy.
- **Description (owner):** A large metal disk mounted atop of a large tower that generates high-voltage electrical arcs that damage incoming enemies. "It was built in a cave with a box of scraps."
- **Paths:** 1. Power (Damage); 2. Range/Chaining; 3. Speed.

### Design

Not started. Rounds go in roster order.

## 9. Drone Bay

- **Class:** Assault. **Weapon type:** Deployable.
- **Description (owner):** Houses combat drones that hunt after enemies. "The military really took the idea of same-day delivery and ran with it."
- **Paths:** 1. Power (overall); 2. Weaponry (upgrades/additions); 3. Speed.
- **Notes (owner):** Max 2 drones

### Design

Not started. Rounds go in roster order.

## 10. CAS Gunship

- **Class:** Assault. **Weapon type:** Deployable.
- **Description (owner):** A large slow-flying cargo plane capable of being with with a wide range of weaponry. "You know that feeling you get when its raining outside, but then the rain suddenly goes from being water to large metal bullets being shot at you from that giant plane above you? Yeah, I hate that feeling."
- **Paths:** 1. Speed (Attack); 2. Power; 3. Weaponry Upgrades.
- **Notes (owner):** While its tower can be placed anywhere, the gunship itself circles around a pin-point location of the user's designation.

### Design

Not started. Rounds go in roster order.

## 11. Mine Layer

- **Class:** Defense. **Weapon type:** Explosive.
- **Description (owner):** Manufactures and tosses explosive mines onto the track that explode when an enemy passes over them. "You know it's a party when the high-speed confetti start flying in every direction."
- **Paths:** 1. Power/Damage; 2. Production Speed; 3. Range.

### Design

Not started. Rounds go in roster order.

## 12. Chemical Plant

- **Class:** Support. **Weapon type:** Chemical (in notes; not yet a listed type).
- **Description (owner):** A chemical manufacturing facility that produces and sprays chemicals on nearby enemies. "Known to cause cancer in the state of California."
- **Paths:** 1. Damage/Armor stripping; 2. Speed; 3. Slowing.
- **Notes (owner):** Weapon type: Chemical. Attacks one enemy at a time. Already soaked enemies are ignored by the tower until the chemical wears off.

### Design

Not started. Rounds go in roster order.

## 13. Rally Beacon

- **Class:** Support. **Weapon type:** None.
- **Description (owner):** Towers in range of the Rally Beacon are amped up and given stat boosts. "Are you feeling it now Mr. Krabs?"
- **Paths:** 1. Damage boost; 2. Speed boost; 3. Range Boost.
- **Notes (owner):** Retrofit boosts towers reach and grants mild boost for all stats for all towers in range

### Design

Not started. Rounds go in roster order.

## 14. Radar Tower

- **Class:** Utility. **Weapon type:** Energy.
- **Description (owner):** Radar is able to detect and alert nearby towers of stealthy or otherwise hidden enemies. "I've lost the bleeps, I've lost the sweeps, and I've lost the creeps."
- **Paths:** 1. Power/Range; 2. Speed/Frequency; 3. Special Targeting.
- **Notes (owner):** Enemies in range are pinged for a brief moment, allowing nearby towers to target them. ping-rate increased through upgrades Upon reaching a certain upgrade, enemies withing a small secondary circle are dealt energy damage for as long as they're in that range. (High-Energy Non-Ionizing Radiation damage)

### Design

Not started. Rounds go in roster order.

## 15. Cryo Tower

- **Class:** Support. **Weapon type:** Field.
- **Description (owner):** Produces a wave of sub-zero temperature gasses that stunt the mobility of enemies within range. "The military had to put restrictions on these machines after a group of soldiers got caught having a snowball fight in the middle of a heatwave."
- **Paths:** 1. Slowing; 2. Power/Range; 3. Speed.

### Design

Not started. Rounds go in roster order.

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
