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

**Picks:** Nanite _, Locust _, Drone _, Shrike _ (look, animation, movement; notes)

## Open questions

1. **Swarm picks**, and any change to the Swarm family traits.
2. **Next role** after Swarm.
