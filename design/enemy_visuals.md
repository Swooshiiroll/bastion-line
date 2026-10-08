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
  cryo-crystal, hologram and so on. Organic, botanical and folk-object themes are out. *(Narrowed by the
  round 4 and round 5 rules below: built, mechanized machines only.)*
- **Built tech only** (owner, round 4: "sci-fi and tech"): every option must read as a **built machine**
  (drone, robot, vehicle, pod) with a visible machine body. Energy effects such as plasma, holograms, shields
  and frost appear only as part of a machine, never as the whole enemy.
- **Mechanized tech, nothing biological; flyers are drones** (owner, round 5). Every option is a machine with
  working mechanical parts (tracks, wheels, jointed legs, skids, screws, pistons, rotors, props). Flying enemies
  are unmanned aircraft. No biological shapes or names. **No concept reuse:** rounds 1 to 4 had re-skinned the
  same ideas, so round 5 is all-new concepts and none of the earlier looks may return.
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
6. **Mechanized check:** a machine with working parts and no biological shape or name; flyers are unmanned
   aircraft that don't copy another enemy's airframe (Strike Drone is a quad-rotor, Gunship has ducted fans).
7. **New-concept check:** not a re-skin of any earlier option or today's look.

## Batches

| # | Role | Enemies | State |
|---|---|---|---|
| 1 | Swarm | Nanite, Locust, Drone, Shrike | **Picked** (Drone movement pending) |
| 2 | Rusher | Skitter, Needle, Strike Drone, Fury Drone | **Options ready for picks** (`design/enemy_redesign_batch2.html`) |
| 3 | Tank | Siege Mech, Rampart, Gunship, Titan | To do |
| 4 | Support | Repair Bot, Rally Beacon, Bulwark, Mender Hulk | To do |
| 5 | Disruptor | Jammer, Siphon, Blackout Rig, Capacitor | To do |
| 6 | Evader | Blink Stalker, Burrower, Shifter, Wraith | To do |
| 7 | Special | Phantom, Aegis Walker, Hydra Frame, Masquerade, Decoy Beacon, Mirage | To do |
| 8 | Boss | Dreadnought, Overmind, Leviathan, Colossus | To do |

Each later batch is checked against the picks already made, so a new concept can't repeat an earlier enemy's
silhouette, material or colours.

## Batch 1: Swarm (decision records, round 5)

Rounds 1 to 4 were dropped: the owner found they re-skinned the same concepts. Round 5 is all-new
**mechanized** concepts, and the flyers are **drones**. In the mockup, each enemy has a **Your combination**
preview, then **Look**, **Animation** and **Movement** pickers (today plus A to E), each with a notes box.
Animations are a layer that works on any look. Movements are path-pattern diagrams in which dots at equal time
steps bunch up where the enemy is slow. Picks and notes stay in the browser and are copied back from the
bottom of the batch.

**Animation options:** ground (Nanite, Drone): A Roll, B Hop, C Ooze, D Wobble, E Jitter. Flyers (Locust,
Shrike): A Flutter, B Swoop, C Hover-bob, D Glide-spin, E Undulate.

### Nanite (T1, ground; today: orbiting cloud, steady, radius 6)

| Look | Machine | Palette | Radius |
|---|---|---|---|
| A Micro-crawler tanks | three tiny tracked tanks with turrets | khaki hulls, dark tracks, white headlights | 8 (+2) |
| B Six-leg micro-walkers | three hexapod micro-robots | teal-anodized bodies, white sensor eyes | 8 (+2) |
| C Micro-rovers | three four-wheel survey rovers with dishes | sand-yellow bodies, black wheels, white dishes | 8 (+2) |
| D Hover-skid sleds | three skid sleds with rear thrusters | cobalt hulls, silver skids, cyan thrusters | 8 (+2) |
| E Piston pogo-bots | three hopping piston cylinders | brushed steel, lime status rings | 8 (+2) |

**Movement:** A Weave, B Stop-go hops, C Rhythmic surges, D S-slither, E Micro-blinks.
**Picks (owner):** look **Today**, animation **Today**, movement **Today**. Nanite keeps its current look and motion.

### Locust (T2, flyer drone; today: flapping wings, steady, radius 5)

| Look | Drone | Palette | Radius |
|---|---|---|---|
| A Tricopter | Y-frame, three rotors | matte white frame, lime LEDs | 6 (+1) |
| B Coaxial rotor pod | round pod, stacked counter-rotating rotors | plum pod, white blades | 6 (+1) |
| C Pusher-prop micro-plane | fixed wing, V-tail, rear prop | safety-yellow airframe, black prop | 7 (+2) |
| D Tilt-rotor | two wingtip rotors | sky-blue fuselage, white stripes | 7 (+2) |
| E Rotor-ring | ring airframe, eight micro-rotors | bronze ring, cyan rotor tips | 7 (+2) |

**Movement:** A Jittery zigzag, B Wide swoops, C Pause-and-dart, D Glide and sway, E Sine undulation.
**Picks (owner):** look **A Tricopter** (radius 6), animation **E Undulate**, movement **D Glide and sway**.

### Drone (T3, ground; today: hover disc, steady, radius 11)

| Look | Machine | Palette | Radius |
|---|---|---|---|
| A Hovercraft | air-cushion skirt, caged rear fan | mint deck, black rubber skirt | 11 |
| B Chicken-walker | reverse-knee biped mech | desert-tan armour, red sensor slit | 11 |
| C Splayed rover | rocker-bogie, six wheels on long arms | white body, gold-foil core | 12 (+1) |
| D Road-train | articulated cab with two linked cargo pods | rust-red cab, steel pods | 12 (+1) |
| E Screw-drive crawler | twin Archimedean screws | steel-blue body, brass screws | 11 |

**Movement:** A Bouncy surges, B Walk then roll, C Wobbling weave, D Heavy hops, E Precessing loops.
**Picks (owner):** look **Today**, animation **Today**, movement **pending** (not picked yet).

### Shrike (T4, flyer drones, cluster of 5; today: flapping blade-wings, steady, radius 7)

| Look | Drone | Palette | Radius |
|---|---|---|---|
| A Mini-helicopters | main rotor and tail rotor | crimson body, white main rotor | 7 |
| B Ring-wing drones | annular wing, nose prop | white ring wing, blue band | 7 |
| C Blimp drones | mini airship with fins and side props | pale-yellow envelope, red fins | 8 (+1) |
| D Tandem-rotor drones | front and rear rotors | olive-tan fuselage, white rotors | 7 |
| E Paraglider drones | parafoil canopy over a motor pod | orange-and-white canopy, black pod | 8 (+1) |

**Movement:** A Tight V that regroups, B Murmuration swirl, C Gust surges, D Pulse-jets, E Streaking surges.
**Picks (owner):** look **Today** (the drafted blade-wing drone), animation **C Hover-bob**, movement **Today**.

**Batch 1 note:** Locust's Tricopter and today's Strike Drone (a quad-rotor) are both multi-rotor drones, so batch 2
offers no multi-rotor for Strike Drone.

## Batch 2: Rusher (decision records)

Mockup: `design/enemy_redesign_batch2.html`, the same format as batch 1 (today plus A to E for look, animation and
movement, with notes boxes). The rules are the same: mechanized, nothing biological, flyers are drones, and no
look offered in batch 1 (any round) or any enemy's today look returns. Rushers get **speed-focused animations**:
ground: A Lean, B Wheelie bounce, C Sprint stretch, D Drift skid, E Engine rumble. Strike Drone: A Bank-roll,
B Pitch-dive, C Strafe slide, D Barrel-roll, E Yaw-hunt. Needle always spawns as a pair, so its looks show two
units and its movements describe how the pair moves together.

### Skitter (T1, ground; today: six-leg scuttle, radius 10)

| Look | Machine | Palette | Radius |
|---|---|---|---|
| A Dirt-bike bot | two-wheel robot bike | lime-green frame, black tyres | 10 |
| B Tadpole trike | two wheels front, one rear | electric-blue body, white stripes | 10 |
| C Wheg runner | four rotating wheel-legs on a plated hull | copper-red hull, black whegs | 10 |
| D Go-kart bot | open-frame kart with a checkered spoiler | racing yellow, black tyres | 10 |
| E Land-yacht bot | wind-sail wheeled racer | navy hull, white sail | 11 (+1) |

**Movement:** A Slalom, B Burst and coast, C Edge-hugger, D Drift slides, E Stutter-step.
**Picks:** look _, animation _, movement _; notes _

### Needle (T2, ground, pair; today: light-leg sprint, radius 8)

| Look | Machine | Palette | Radius |
|---|---|---|---|
| A Dragster | needle-nose drag racer, big rear slicks | pearl white, violet stripes | 8 |
| B Inline skater bot | humanoid skating robot | teal shell, white skates | 8 |
| C Hover-lance | spike-nosed hover racer | matte black, cyan seams and underglow | 8 |
| D Ground-effect arrow | delta skimmer | coral-red delta, white fin | 8 |
| E Outrigger jet-car | jet car on two outrigger wheels | lemon yellow, black outriggers | 8 |

**Movement (pair):** A Drafting, B Braided weave, C Leapfrog, D Side by side, E Split and rejoin.
**Picks:** look _, animation _, movement _; notes _

### Strike Drone (T3, flyer drone; today: quad-rotor, radius 9)

| Look | Drone | Palette | Radius |
|---|---|---|---|
| A Canard jet drone | canard delta jet | slate-teal, hazard-yellow nose | 9 |
| B Autogyro drone | free-spinning rotor, pusher prop | sunset-orange pod, white rotor | 9 |
| C Twin-boom recon drone | high wing, twin booms, pusher prop | desert sand, black sensor ball | 9 |
| D Cyclocopter | two barrel rotors | violet body, silver drums | 9 |
| E X-wing strike drone | four-wing jet | white wings, red stripes, blue engines | 9 |

**Movement:** A Strafing sweeps, B Dive and climb, C Figure-eight, D Hover and dash, E Corkscrew.
**Picks:** look _, animation _, movement _; notes _

### Fury Drone (T4, ground; today: hunter stride, radius 10)

| Look | Machine | Palette | Radius |
|---|---|---|---|
| A Assault buggy | roll-cage combat buggy with a roof gun | desert tan, red roll bars | 11 (+1) |
| B Wedge hover-tank | faceted hover tank, twin barrels | deep magenta armour, violet hover glow | 11 (+1) |
| C Drum crusher | spiked roller drum on arms | hazard-striped drum, steel arms | 11 (+1) |
| D Jump-jet mech | stocky biped with jump jets | navy armour, orange jets | 11 (+1) |
| E Spiked ram-car | plough-fronted ram car | rust hull, chrome spikes | 11 (+1) |

**Movement:** A Ram charges, B Swerving pursuit, C Rumbling surge, D Juke steps, E Wall-bounce.
**Picks:** look _, animation _, movement _; notes _

## Implementation (after every batch is confirmed)

One PR that replaces the enemy drawings in `scripts/view/Draw.gd` (`Draw.enemy`, `ENEMY_BODY`, `ENEMY_COLOR`)
with the picked designs, using the same primitives as the mockup. It runs `tools/dev.sh tour` for screenshots
and the perf check (`check`, `compare`, `perf`), and updates radii in `data/enemies.gd` with balance-probe
runs. Picked **animations** go into the drawings; picked **path patterns** need movement code in `Enemy.step`
(`scripts/entities/Enemy.gd`) that keeps each enemy's average speed, with unit tests for that. Name and Codex changes flagged above go in with it, or in their own PR.

## Open questions

1. **Batch 1:** Drone's movement is still to pick. **Batch 2 picks:** look, animation and movement for each Rusher.
2. **Lore direction (decided, rounds 3 to 5):** mechanized tech, so the "machines" lore stays as it is.
3. **Path patterns change gameplay.** Bursts and weaving make projectile towers miss more (they lead the
   target); hops and pauses change how long an enemy stays in range. The balance probe checks the picked
   patterns before they ship.
