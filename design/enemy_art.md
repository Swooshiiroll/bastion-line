# Bastion Line Enemy Art Direction (design)

A fresh visual design for every enemy, started from the enemy **names** after all earlier visual concepts were
cleared (2026-10-07). It covers all 34 enemies: the existing roster, the 12 new enemies in
`design/new_enemies.md`, and the bosses. Designed with the owner in question rounds. **Draft: no game code
changes until the owner confirms** (repo CLAUDE.md, "Designing a feature first").

## Direction (owner, 2026-10-07)

- **World:** a **machine army**: robots and war machines built by one enemy faction.
- **Names inspire, not dictate:** each name suggests a trait (speed, swarming, bulk, trickery) and the look
  expresses that trait. It is not a literal picture of the word.
- **Tone:** a mix of **gritty military** (worn metal, hazard markings, functional shapes) and **sleek sci-fi**
  (smooth panels, glowing lines, precise shapes).
- **Families:**
  - **By role:** the enemies in a role share family traits, and each is still distinct.
  - **Tiers evolve:** within a role, higher tiers are upgraded versions of the lower ones. They are
    **bigger**, carry **more armour and parts**, and are **sleeker and more advanced**. Low tiers lean
    gritty; high tiers lean sleek.
- **Colour:** chosen **per enemy**.
- **Scope:** **look, animation and movement**. Movement is the path pattern on the lane, at the same average
  speed. Flyer or ground status is unchanged unless the owner says otherwise.
- **Format:** **two or three proposals per enemy**; the owner picks or mixes.

## Process

1. One role at a time. Each role gets a short family description (what its members share), then 2 or 3
   proposals per enemy that follow it, with tiers shown evolving.
2. The owner picks and marks up each role before the next.
3. After every role is confirmed, the drawings go into `scripts/view/Draw.gd`, and the movement patterns into
   `Enemy.step` (`scripts/entities/Enemy.gd`), as their own PR with tour screenshots, the perf check and a
   balance-probe run.

## Roles

| Role | Enemies (by tier) |
|---|---|
| Swarm | Nanite, Locust, Drone, Shrike |
| Rusher | Skitter, Needle, Strike Drone, Fury Drone |
| Tank | Siege Mech, Rampart, Gunship, Titan |
| Support | Repair Bot, Rally Beacon, Bulwark, Mender Hulk |
| Disruptor | Jammer, Siphon, Blackout Rig, Capacitor |
| Evader | Blink Stalker, Burrower, Shifter, Wraith |
| Special | Phantom, Aegis Walker, Hydra Frame, Masquerade, Decoy Beacon, Mirage |
| Boss | Dreadnought, Overmind, Leviathan, Colossus |

## Swarm (role 1)

Mockup: `design/enemy_art_swarm.html` (open in a browser). It has a family sheet, then for each enemy **Look**,
**Animation** and **Movement** pickers with three proposals each (A to C) and a notes box apiece. Any look mixes
with any animation and movement. There is no "today" option. Picks and notes are copied from the bottom of the page.

**Swarm family (draft):** mass-produced units of the machine army: stamped-metal hulls, one round sensor eye,
a hive-link antenna fin with a blinking tip, and stencilled unit numbers. **Tiers evolve:** T1 Nanite is a bare,
gritty frame; T2 Locust adds panels; T3 Drone is bigger and armoured; T4 Shrike is sleek, with glowing seams.
**Colour per enemy:** Nanite rusted bare metal, Locust olive, Drone gunmetal blue, Shrike pearl white.

| Enemy (trait from the name) | Look A | Look B | Look C |
|---|---|---|---|
| Nanite, T1 ground (tiny, countless, self-replicating) | Assembly hub: a mother unit whose bots orbit and dock | Grain carpet: rice-sized bots with a leader | Replicator triad: three bots that clip into a triangle and split |
| Locust, T2 flyer (a devouring swarm) | Strip-miner drone with grinding cutter heads | Harvester rotor-drone with an intake funnel | Shredder dart with chewing nose rollers |
| Drone, T3 ground (the army's standard soldier) | Infantry bot: armoured biped with a rifle | Sentry walker: four legs and a turret | Hover-trooper: hover sled with a front shield |
| Shrike, T4 flyer x5 (an impaling hunter) | Impaler jets: needle-spike jets | Hook-wing hunters: hooked blade wingtips | Lancer squadron: forward-swept lance drones |

| Enemy | Animation A / B / C | Movement A / B / C |
|---|---|---|
| Nanite | Churn / Dock-and-split / Ripple | Carpet creep / Split and merge / Trickle |
| Locust | Hover-chew / Dive-bite / Flock-jitter | Feeding swoops / Zigzag / Cloud drift |
| Drone | March / Brace-and-step / Hover-drift | Advance and halt / Steady march / Flanking weave |
| Shrike | Stoop / Bank / Glide | Dive strikes / Formation sweep / Hunting circles |

**Picks (owner, 2026-10-07):**
- **Nanite:** look A Assembly hub, animation B Dock-and-split, movement B Split and merge.
- **Locust:** look **open** (none of A to C was picked; round 2 offers three new looks), animation A Hover-chew,
  movement C Cloud drift.
- **Drone:** look B Sentry walker, animation A March, movement B Steady march.
- **Shrike:** look C Lancer squadron, animation C Glide, movement **D Smooth and straight**: constant speed, nearly
  straight, only a slight drift. This was added from the owner's note "smooth flight path".

**Locust look, round 2** (on the same page, with the picks above preselected):
- **D Maw drone:** a round drone with a wide grinding maw ring and two small rotors.
- **E Saw-rim disc:** a disc drone whose rim is a spinning saw blade.
- **F Cutter-wing flyer:** wings with serrated cutter edges and a tail rotor.

## Rusher (role 2)

Mockup: `design/enemy_art_rusher.html`, the same format as Swarm (three proposals each for look, animation and
movement, notes boxes, no "today").

**Rusher family (draft):** built for speed: a low-slung chassis with a forward-raked prow, swept fins, exposed
thrusters, and a speed-stripe ID along the spine. **Tiers evolve:** T1 Skitter is a bare, light frame; T2 Needle
adds sharp panels; T3 Strike Drone is armoured; T4 Fury Drone is sleek, with glowing seams. **Colour per enemy:**
Skitter sand with a red stripe, Needle ice white with cobalt, Strike Drone matte teal with orange, Fury Drone
black-red with magenta glow.

| Enemy (trait from the name) | Look A | Look B | Look C |
|---|---|---|---|
| Skitter, T1 ground (darting, skittish) | Six-leg scuttler | Spring-foot hopper | Caster-wheel skimmer |
| Needle, T2 ground, pair (thin, piercing, fast) | Needle racer | Lance sprinter | Rail-skimmer |
| Strike Drone, T3 flyer (a fast attack drone) | Delta strike jet | Twin-rotor attack drone | Winged missile drone |
| Fury Drone, T4 ground (berserk rage) | Berserker biped | Blade-prow ram buggy | One-wheel spike bike |

| Enemy | Animation A / B / C | Movement A / B / C |
|---|---|---|
| Skitter | Twitch / Hop / Scuttle sway | Darting zigzag / Hop bursts / Skittish swerves |
| Needle | Lean-in / Stride / Hover-hum | Tandem line / Twin weave / Parallel lances (pair) |
| Strike Drone | Bank / Strafe-roll / Nose-dip | Strafing runs / Dive passes / Straight intercept |
| Fury Drone | Lunge / Rage-shake / Lean | Charge bursts / Berserk swerve / Relentless chase |

**Picks:** Skitter _, Needle _, Strike Drone _, Fury Drone _ (look, animation, movement; notes)

## Open questions

1. **Locust look:** pick one of D to F on the Swarm page.
2. **Rusher picks**, and any change to the Rusher family traits.
3. **Next role** after Rusher.
