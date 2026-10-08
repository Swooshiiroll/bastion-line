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

## Open questions

1. **Which role first?**
2. **Presentation:** a drawn mockup page, as before, or written proposals first and drawings only for the
   picks?
