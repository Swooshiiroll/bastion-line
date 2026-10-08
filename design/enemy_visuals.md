# Bastion Line Enemy Visual Redesign (design)

A visual redesign of **all 34 enemies** (the 18 existing regulars, the 12 new enemies from
`design/new_enemies.md` and the 4 bosses) so that **no two look alike**. It is designed with the owner in
batches. **Draft: no game code or data changes until the owner confirms** (repo CLAUDE.md, "Designing a
feature first"). The mockup is `design/enemy_redesign_mockup.html`; open it in a browser.

## Why

Today many enemies read as the same thing (owner-confirmed look-alike groups):

- **Tracked boxes:** Jammer, Burrower, Repair Bot, Rampart, Dreadnought, Blackout Rig, Capacitor, Decoy Beacon.
- **Orb-core bodies:** Drone, Mender Hulk, Bulwark, Siphon, Mirage, Repair Bot.
- **Wedges and blades:** Phantom, Wraith, Blink Stalker, Shifter, Fury Drone, Needle.
- **Same colours:** eight orange glows (Siege Mech, Hydra Frame, Burrower, Rally Beacon, Gunship, Rampart,
  Colossus, Titan), three red (Drone, Strike Drone, Dreadnought), five acid yellow-green (Jammer, Locust,
  Siphon, Blackout Rig, Capacitor), and near-identical dark-grey hulls (`ENEMY_BODY` in `Draw.gd`, brightness
  0.2 to 0.4), so the small glow dot does most of the identifying.

## Decisions (owner)

- **Every enemy unique:** no shared silhouette or colour families, not even within a role.
- **Full restyle, theme chosen per enemy** (glass, chitin, paper, plasma, lacquer, clockwork and so on).
- **Contrast with the towers on purpose.** The towers stay as they are.
- **Movement unchanged:** each enemy keeps its locomotion (orbiting cloud, flapping flight, hover, legs,
  treads, burrowing, blinking).
- **Sizes are free.** Radius is also the hit size for splash and chains, so every change is listed per enemy
  for balance.
- **Shape first, colour second:** each enemy must be recognisable in greyscale. Colours are then chosen to be
  distinct and to avoid red/green-only differences.
- **Process:** 2 or 3 concepts per enemy; the owner picks one (or mixes); batches by role.

## Contrast rule (towers vs enemies)

Tower accents already cover almost the whole hue wheel (`Draw.ACCENT` and `Draw.SPEC_ALT`: cyan, orange, green,
violet, red, gold, magenta, mint and more), so "avoid tower colours" cannot work as a hue rule. The contrast is
**material**:

- **Towers own** grey metal hulls, neon accent lights, and hex pads.
- **Enemies carry their identity in a coloured body and a distinct material.** Glow accents are allowed but
  secondary; the body colour and silhouette are the identity.

## Distinctness checklist (every concept)

1. A silhouette no other enemy uses, readable in **greyscale** at 1x (the mockup's Greyscale toggle).
2. Its own theme or material.
3. A body colour and glow pair that no other enemy uses.
4. No grey-metal-with-neon look (that belongs to the towers).
5. Movement unchanged; radius change listed.
6. **Lore check:** if the theme changes what the enemy *is* (for example organic instead of machine), its name,
   Codex text and lore need a follow-up.

## Batches

| # | Role | Enemies | State |
|---|---|---|---|
| 1 | Swarm | Nanite, Locust, Drone, Shrike | **Concepts ready for picks** |
| 2 | Rusher | Skitter, Needle, Strike Drone, Fury Drone | To do |
| 3 | Tank | Siege Mech, Rampart, Gunship, Titan | To do |
| 4 | Support | Repair Bot, Rally Beacon, Bulwark, Mender Hulk | To do |
| 5 | Disruptor | Jammer, Siphon, Blackout Rig, Capacitor | To do |
| 6 | Evader | Blink Stalker, Burrower, Shifter, Wraith | To do |
| 7 | Special | Phantom, Aegis Walker, Hydra Frame, Masquerade, Decoy Beacon, Mirage | To do |
| 8 | Boss | Dreadnought, Overmind, Leviathan, Colossus | To do |

Each later batch is checked against the picks already made, so a new concept can't repeat an earlier enemy's
silhouette, material or colours.

## Batch 1: Swarm (decision records)

The mockup shows each enemy's **today** look next to concepts **A, B and C** at 1x and 3x, plus a lineup of the
batch on the lane. Pick buttons collect a copyable summary at the bottom of the batch.

### Nanite (T1, orbiting cloud; today radius 6)

| | Concept | Theme | Palette | Radius | Lore impact |
|---|---|---|---|---|---|
| A | Glass-bead motes: faceted glass shards orbiting a hollow ring | Crystal / glass | pale aqua glass, white glints | 7 (+1) | none (still machines) |
| B | Chitin mite cluster: three mites circling each other | Biomech insect | glossy rust-brown chitin, pale yellow eyes | 7 (+1) | "Nanite" becomes organic: rename and Codex |
| C | Sulphur spark wisps: three spark heads with soot trails | Plasma / elemental | sulphur-white sparks, soot-black trails | 7 (+1) | "self-replicating machines" becomes energy: Codex |

**Pick:** _pending_

### Locust (T2, flapping flyer; today radius 5)

| | Concept | Theme | Palette | Radius | Lore impact |
|---|---|---|---|---|---|
| A | Origami flyer: folded paper wings and body, red ink stamp | Folded paper | cream paper, red ink | 6 (+1) | none |
| B | Iridescent dragonfly: four membrane wings, segmented abdomen | Biomech insect | teal metallic body, rainbow wings | 6 (+1) | organic: Codex |
| C | Rotor seed (samara): one spinning blade around a seed pod | Botanical machine | sandy tan blade, brown pod | 6 (+1) | Codex wording |

**Pick:** _pending_

### Drone (T3, hover disc; today radius 11)

| | Concept | Theme | Palette | Radius | Lore impact |
|---|---|---|---|---|---|
| A | Hazard sentry ball: hazard-striped sphere, side thrusters, one eye | Industrial / hazard paint | yellow and black stripes, red eye | 10 (-1) | none |
| B | Jellyfish bell: pulsing translucent bell, trailing filaments | Bioluminescent | translucent orchid, glowing core | 12 (+1) | organic: rename and Codex |
| C | Lantern-eye sphere: bronze sphere, rotating fin ring, lantern eye | Bronze clockwork | dark bronze, pale mint lantern | 11 | none |

**Pick:** _pending_

### Shrike (T4, flying cluster of 5; drafted radius 7)

| | Concept | Theme | Palette | Radius | Lore impact |
|---|---|---|---|---|---|
| A | Boomerang blades: spinning two-armed blades | Thrown steel | blued steel, white edge | 7 | none |
| B | Manta-ray biomech: undulating ray with a whip tail | Deep-sea biomech | indigo skin, pale lime photophores | 8 (+1) | organic: Codex |
| C | Mechanical swifts: swept wings, forked tail | Bird / lacquer | gloss black, white throat | 7 | fits the name "Shrike" |

**Pick:** _pending_

## Implementation (after every batch is confirmed)

One PR that replaces the enemy drawings in `scripts/view/Draw.gd` (`Draw.enemy`, `ENEMY_BODY`, `ENEMY_COLOR`)
with the picked designs, using the same primitives as the mockup. It runs `tools/dev.sh tour` for screenshots
and the perf check (`check`, `compare`, `perf`), and updates radii in `data/enemies.gd` with balance-probe
runs. Name and Codex changes flagged above go in with it, or in their own PR.

## Open questions

1. **Batch 1 picks:** one concept per Swarm enemy (or a mix, e.g. "A's body with B's colours").
2. **Lore direction:** themes like chitin, jellyfish or manta make some enemies organic. Is a mixed roster
   (machines next to creatures) fine, or should picks keep the "machines" lore?
