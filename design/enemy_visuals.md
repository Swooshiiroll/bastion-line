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
- **Full restyle, theme chosen per enemy, within sci-fi** (owner, round 3: "keep the sci-fi theme"). Every
  option is a machine, energy form or alien tech: force fields, anodized metal, ceramic, ferrofluid, plasma,
  cryo-crystal, hologram and so on. Organic, botanical and folk-object themes are out.
- **Contrast with the towers on purpose.** The towers stay as they are.
- **Movement can change (round 2):** both the **animation** (how the body moves: roll, hop, flutter...) and the
  **path pattern** on the lane (weave, bursts, surges, loops...), at the **same average speed**. **Flyers stay
  flyers and ground stays ground**, so anti-air and mortar counters still work.
- **Sizes are free.** Radius is also the hit size for splash and chains, so every change is listed per enemy
  for balance.
- **Shape first, colour second:** each enemy must be recognisable in greyscale. Colours are then chosen to be
  distinct and to avoid red/green-only differences.
- **Process (round 2):** for each enemy the owner picks **look, animation and movement separately**, each from
  **six options: today plus A to E**, and each has a **notes box** for extra input. Batches by role. Shown in
  place; movement is shown as a lane diagram.

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
5. A new animation and path pattern at the same average speed; flyer or ground unchanged; radius change listed;
   gameplay note if the path pattern affects targeting.
6. **Sci-fi check:** the option is a machine, energy form or alien tech, so the "they're all machines" lore
   still holds. Energy forms may need Codex wording.

## Batches

| # | Role | Enemies | State |
|---|---|---|---|
| 1 | Swarm | Nanite, Locust, Drone, Shrike | **Round 3 options ready for picks** (sci-fi looks; rounds 1 and 2 looks dropped) |
| 2 | Rusher | Skitter, Needle, Strike Drone, Fury Drone | To do |
| 3 | Tank | Siege Mech, Rampart, Gunship, Titan | To do |
| 4 | Support | Repair Bot, Rally Beacon, Bulwark, Mender Hulk | To do |
| 5 | Disruptor | Jammer, Siphon, Blackout Rig, Capacitor | To do |
| 6 | Evader | Blink Stalker, Burrower, Shifter, Wraith | To do |
| 7 | Special | Phantom, Aegis Walker, Hydra Frame, Masquerade, Decoy Beacon, Mirage | To do |
| 8 | Boss | Dreadnought, Overmind, Leviathan, Colossus | To do |

Each later batch is checked against the picks already made, so a new concept can't repeat an earlier enemy's
silhouette, material or colours.

## Batch 1: Swarm (decision records, round 3)

Round 1's concepts were dropped, and round 2's looks were re-themed as sci-fi in round 3. Each keeps its round 2
silhouette and movement idea where possible. In the mockup,
each enemy has a **Your combination** preview, then **Look**, **Animation** and **Movement** pickers (today plus A
to E), each with a notes box. **Animations** are a locomotion layer that the page applies to whichever look is
selected, so any look can be tried with any animation. **Movements** are path-pattern diagrams: dots at equal
time steps bunch up where the enemy is slow and spread out where it's fast. Picks and notes stay in the
browser and are copied back from the bottom of the batch.

**Animation options** (the same set within ground and within flyers):
- **Ground** (Nanite, Drone): A Roll, B Hop (squash on landing), C Ooze (pulsing stretch), D Wobble (sway), E
  Jitter.
- **Flyers** (Locust, Shrike): A Flutter (erratic), B Swoop (bank and altitude), C Hover-bob, D Glide-spin, E
  Undulate.

### Nanite (T1, ground; today: orbiting cloud, steady, radius 6)

| Look | Theme | Palette | Radius | Lore impact |
|---|---|---|---|---|
| A Force-bubble nanites | Containment fields | iridescent force-field rims, white-hot cores | 7 (+1) | none |
| B Spike-mine swarm | Proximity mines | hazard-amber shells, steel spikes, white LEDs | 7 (+1) | none |
| C Microturbines | Anodized rotors | anodized copper blades, cyan hub lights | 7 (+1) | none |
| D Ferrofluid nanobots | Liquid-metal nanotech | black ferrofluid, violet sheen | 7 (+1) | none |
| E Corrupted hologram | Digital glitch | magenta and cyan pixels | 7 (+1) | Codex wording |

**Movement:** A Weave, B Stop-go hops, C Rhythmic surges, D S-slither, E Micro-blinks.
**Picks:** look _, animation _, movement _; notes _

### Locust (T2, flyer; today: flapping wings, steady, radius 5)

| Look | Theme | Palette | Radius | Lore impact |
|---|---|---|---|---|
| A Solar moth drone | Photovoltaic flyer | deep blue solar cells, silver frames | 6 (+1) | none |
| B Bat-wing UAV | Stealth flying wing | violet carbon skin, amber wingtip lights | 7 (+2) | none |
| C Beacon mite | Micro-rotor drone | olive drab hull, gold blinking beacon | 6 (+1) | none |
| D Flechette dart | Ceramic kinetic dart | white ceramic, indigo tip, blue engine glow | 7 (+2) | none |
| E Plasma serpent | Linked energy segments | teal-to-coral plasma beads | 7 (+2) | Codex wording |

**Movement:** A Jittery zigzag, B Wide swoops, C Pause-and-dart, D Glide and sway, E Sine undulation.
**Picks:** look _, animation _, movement _; notes _

### Drone (T3, ground; today: hover disc, steady, radius 11)

| Look | Theme | Palette | Radius | Lore impact |
|---|---|---|---|---|
| A Gyro-cage | Orbital rings | cobalt rings, white-hot core | 11 | none |
| B Roller bot | Segmented armour robot | slate-blue plates, rivets, cyan sensor | 11 | none |
| C Unicycle bot | Balancing robot | cream body, mint stripe, black tyre | 10 (-1) | none |
| D Monolith stack | Alien obsidian tech | obsidian hex blocks, emerald glyphs | 12 (+1) | Codex wording |
| E Saucer | Hover saucer | pearl hull, glass dome, chasing amber lights | 11 | none |

**Movement:** A Bouncy surges, B Walk then roll, C Wobbling weave, D Heavy hops, E Precessing loops.
**Picks:** look _, animation _, movement _; notes _

### Shrike (T4, flyer, cluster of 5; today: flapping blade-wings, steady, radius 7)

| Look | Theme | Palette | Radius | Lore impact |
|---|---|---|---|---|
| A Cryo shards | Cryo-tech crystal darts | pale blue-white ice, frost thruster | 7 | none |
| B Wingbot jets | Micro-jet flock | gloss purple-black, iridescent edges, orange burners | 6 (-1) | none |
| C Scrap storm | Salvage debris | rust-orange and steel scrap plates | 7 | none |
| D Jet-squid drones | Cable-tentacle drone | anodized coral pod, steel cables, blue thrust | 7 | none |
| E Plasma comets | Plasma bolts | white-gold head, pale blue tail | 6 (-1) | Codex wording |

**Movement:** A Tight V that regroups, B Murmuration swirl, C Gust surges, D Pulse-jets, E Streaking surges.
**Picks:** look _, animation _, movement _; notes _

## Implementation (after every batch is confirmed)

One PR that replaces the enemy drawings in `scripts/view/Draw.gd` (`Draw.enemy`, `ENEMY_BODY`, `ENEMY_COLOR`)
with the picked designs, using the same primitives as the mockup. It runs `tools/dev.sh tour` for screenshots
and the perf check (`check`, `compare`, `perf`), and updates radii in `data/enemies.gd` with balance-probe
runs. Picked **animations** go into the drawings; picked **path patterns** need movement code in `Enemy.step`
(`scripts/entities/Enemy.gd`) that keeps each enemy's average speed, with unit tests for that. Name and Codex changes flagged above go in with it, or in their own PR.

## Open questions

1. **Batch 1 picks:** look, animation and movement for each Swarm enemy, plus any notes (copied from the mockup).
2. **Lore direction (decided, round 3):** sci-fi throughout, so the "machines" lore stays. Energy forms (corrupted
   hologram, plasma serpent, plasma comets) and the alien monolith need Codex wording only.
3. **Path patterns change gameplay.** Bursts and weaving make projectile towers miss more (they lead the
   target); hops and pauses change how long an enemy stays in range. The balance probe checks the picked
   patterns before they ship.
