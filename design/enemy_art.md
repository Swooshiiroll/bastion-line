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

**Swarm confirmed (owner, 2026-10-07).** Final picks:
- **Nanite:** look A Assembly hub, animation B Dock-and-split, movement B Split and merge.
- **Locust:** look **F Cutter-wing flyer** (from round 2), animation A Hover-chew, movement C Cloud drift.
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

**Rusher confirmed (owner, 2026-10-07).** Final picks:
- **Skitter:** look A Six-leg scuttler, animation C Scuttle sway, movement C Skittish swerves.
- **Needle:** look A Needle racer, animation C Hover-hum, movement B Twin weave.
- **Strike Drone:** look B Twin-rotor attack drone, animation C Nose-dip, movement C Straight intercept.
- **Fury Drone:** look C One-wheel spike bike, animation B Rage-shake, movement B Berserk swerve.

## Tank (role 3)

Mockup: `design/enemy_art_tank.html`, the same format as Swarm and Rusher (three proposals each for look, animation
and movement, notes boxes, no "today").

**Tank family (draft):** built to take hits: riveted slab armour, a hazard-striped or plated front, a visor slit,
exhaust stacks trailing smoke, and heavy running gear (stomping legs or treads). **Tiers evolve:** T1 Siege Mech is
bare riveted plate; T2 Rampart is a moving wall; T3 Gunship is armoured and airborne; T4 Titan is sleek, with layered
plates over a glowing frame. **Colour per enemy:** Siege Mech hazard yellow with black stripes, Rampart concrete grey
with amber lamps, Gunship slate navy with red running lights, Titan bronze plates over a dark frame with cyan glow.

**Titan plate shed:** every Titan look has its plates fall away at half health (armor 9 to 5, design/new_enemies.md),
leaving the glowing frame. The previews loop it: plated for 5 s, the plates fall over 1 s, bare for 2 s.

| Enemy (trait from the name) | Look A | Look B | Look C |
|---|---|---|---|
| Siege Mech, T1 ground (a walking siege engine: armoured, breaching) | Ram walker: boxy biped with a battering ram | Mortar strider: four legs and a siege mortar | Breacher crab: six legs behind a striped siege shield |
| Rampart, T2 ground (a moving wall that can't be slowed, stunned or shoved) | Rolling wall: crenellated slab on treads, ram teeth | Bastion crawler: hexagonal fort with corner turrets | Shield-bearer: heavy walker behind a tower shield |
| Gunship, T3 flyer (a flying gun platform: armoured, heavy) | Armoured quad-rotor with side gun pods | Hover barge on four lift thrusters, top turret | Tiltrotor gunship: wingtip rotors, chin cannon |
| Titan, T4 ground (a giant; its plates shed at half health) | Colossus walker: biped with pauldrons, chest and back plates | Fortress tank: tracks, armour skirts, twin cannons | Quad-leg citadel: domed core ringed with plates |

| Enemy | Animation A / B / C | Movement A / B / C |
|---|---|---|
| Siege Mech | Stomp / Recoil / Grind | Steady trudge / Stop and plant / Lumbering sway |
| Rampart | Grind forward / Shudder / Brace | Unstoppable line / Grinding push / Lane-filling drift |
| Gunship | Heavy hover / Yaw scan / Sag and lift | Patrol sweep / Hover and advance / Steady cruise |
| Titan | Earth-shaker stride / Sway / Core pulse | Inexorable march / Heavy stride / Swaying march |

**Tank confirmed (owner, 2026-10-07).** Final picks:
- **Siege Mech:** look **H Cannon-shoulder mech** (from round 3), animation A Stomp, movement A Steady trudge.
- **Rampart:** look B Bastion crawler, animation B Shudder, movement A Unstoppable line.
- **Gunship:** look A Armoured quad-rotor, animation A Heavy hover, movement C Steady cruise.
- **Titan:** look A Colossus walker, animation A Earth-shaker stride, movement A Inexorable march.

**Siege Mech look, round 2** (on the same page, with the picks above preselected):
- **D Drill sapper:** a squat tracked sapper driving a huge spinning breaching drill.
- **E Siege-tower walker:** a narrow stacked siege tower on four stubby legs, with a drop ramp at the front.
- **F Wrecking-ball crawler:** a four-legged crawler with a crane boom swinging a wrecking ball.

**Siege Mech look, round 3** (owner asked for three more). These lean into the "mech" in the name: walking war
mechs, gritty early versions of the Titan's Colossus walker.
- **G Chicken walker:** a cockpit pod on two backward-bending legs, with twin chin guns.
- **H Cannon-shoulder mech:** a broad-shouldered mech with a siege cannon on one shoulder and a hydraulic claw arm.
- **I Demolition loader:** a stocky loader mech hauling a huge demolition charge to the wall.

## Support (role 4)

Mockup: `design/enemy_art_support.html`, the same format as the other roles (three proposals each for look, animation
and movement, notes boxes, no "today").

**Support family (draft):** the army's field crews: a ringed emitter node with a blinking tip, white service
chevrons, a scanning status light bar, and a visible effect drawn on the game's real timing. **Tiers evolve:** T1
Repair Bot is a small bare service bot; T2 Rally Beacon adds a mast and panels; T3 Bulwark is armoured; T4 Mender Hulk
is big and sleek, with gold trim and glowing seams. **Colour per enemy:** Repair Bot mint green and white, Rally Beacon
violet with gold light, Bulwark ivory with a sky-blue barrier, Mender Hulk dark emerald with gold trim.

**Effects in the previews:** Repair Bot sends a green repair pulse every 2 s; Rally Beacon has a turning gold speed
aura; Bulwark charges, then throws a sky-blue barrier every 6 s; Mender Hulk's self-repair kicks in after 1.5 s unhurt
(looped: 1.5 s hurt, then repair). The rings are drawn small to fit the cards; in game they follow the real radii.

| Enemy (trait from the name) | Look A | Look B | Look C |
|---|---|---|---|
| Repair Bot, T1 ground (fixes the units around it) | Welder crawler: treads, two sparking welding arms | Nano-sprayer walker: backpack tank, repair mist | Dish rover: four wheels, turning repair dish |
| Rally Beacon, T2 ground (rallies the units around it) | Banner walker: four legs, holo-banner on a mast | Siren crawler: treads, rotating siren beam | Drum-signal hexapod: six legs, pumping speaker cone |
| Bulwark, T3 ground (shields the units around it) | Pylon walker: three shield pylons, hex barrier | Dome generator: treads, charging dome, barrier bubble | Shield-wing bot: biped, energy wings open to fire |
| Mender Hulk, T4 ground (a big unit that repairs itself) | Nanoforge hulk: hunched, forge core, big fists | Repair-arm crawler: six legs, arms welding its hull | Cocoon tank: segmented shell, two mender drones |

| Enemy | Animation A / B / C | Movement A / B / C |
|---|---|---|
| Repair Bot | Tinker / Bob / Scan sweep | Follow the pack / Weave between units / Stop to repair |
| Rally Beacon | Pulse beat / Wave / Strut | Lead the charge / Rally sweeps / Marching beat |
| Bulwark | Brace / Hum / Guard sway | Steady guard / Shield-wall drift / Brace and advance |
| Mender Hulk | Heavy plod / Breathing / Hunched lurch | Relentless plod / Lumber / Rest and repair |

**Support confirmed (owner, 2026-10-08).** Final picks:
- **Repair Bot:** look B Nano-sprayer walker, animation A Tinker, movement B Weave between units.
- **Rally Beacon:** look A Banner walker, animation C Strut, movement A Lead the charge.
- **Bulwark:** look C Shield-wing bot, animation B Hum, movement C Brace and advance.
- **Mender Hulk:** look B Repair-arm crawler, animation C Hunched lurch, movement A Relentless plod.

## Disruptor (role 5)

Mockup: `design/enemy_art_disruptor.html`, the same format as the other roles (three proposals each for look,
animation and movement, notes boxes, no "today").

**Disruptor family (draft):** the army's electronic-warfare rigs: antenna arrays and dishes, exposed coils,
crackling arcs, blinking warning LEDs, and a visible effect on the spec timing. **Tiers evolve:** T1 Jammer is a small
bare rig; T2 Siphon adds panels and intakes; T3 Blackout Rig is a big armoured hauler; T4 Capacitor is sleek, with
glowing coils. **Colour per enemy:** Jammer matte black with electric blue, Siphon deep indigo with acid lime,
Blackout Rig storm grey with ultraviolet, Capacitor ceramic white with copper coils and white-hot arcs.

**Effects in the previews:** Jammer fires a crackling EMP ring every 5 s; Siphon has a drain aura pulling energy
motes in; Blackout Rig throws a darkening ultraviolet pulse every 4 s; Capacitor charges for 2 s (a dashed warning
ring closes in, arcs build), then fires a huge EMP, every 8 s. Rings are drawn small to fit the cards.

**Sizes (owner, 2026-10-08):** Siphon 13 px, Blackout Rig 15 px, Capacitor 16 px (Jammer is 12 today), so the tiers
step up.

| Enemy (trait from the name) | Look A | Look B | Look C |
|---|---|---|---|
| Jammer, T1 ground (jams towers) | Antenna walker: four legs, crackling whip antennas | Dish crawler: treads, scanning jammer dish | Mast roller: two big wheels, spinning mast |
| Siphon, T2 ground (drains towers) | Cable leech: crawler trailing plug cables | Funnel walker: swirling intake funnel | Drain-spire tank: forward spire, sloshing glass tank |
| Blackout Rig, T3 ground (a big Jammer) | Generator truck: six wheels, finned EMP drum | Transformer walker: ribbed box, arcing insulators | Twin-dish crawler: back-to-back turning dishes |
| Capacitor, T4 ground (charges, then releases) | Tesla walker: copper coil, electrode prongs | Coil-bank crawler: cells light up during the charge | Ring-reactor tank: ring spins up during the charge |

| Enemy | Animation A / B / C | Movement A / B / C |
|---|---|---|
| Jammer | Static jitter / Scan / Bob | Steady advance / Signal zigzag / Pause to jam |
| Siphon | Gulp / Sway / Shiver | Steady drift / Lane weave / Drain and lurch |
| Blackout Rig | Heavy rumble / Pulse recoil / Sway | Steady haul / Heavy sway / Stop and pulse |
| Capacitor | Charge shake / Hum / Stride | Inexorable advance / Charge halt / Slow sway |

**Disruptor confirmed (owner, 2026-10-08).** Final picks:
- **Jammer:** look A Antenna walker, animation A Static jitter, movement A Steady advance.
- **Siphon:** look **H Tether sapper** (from round 3), animation A Gulp, movement A Steady drift.
- **Blackout Rig:** look **H Spider rig** (from round 3), animation **E Rock** (from round 2), movement C Stop and pulse.
- **Capacitor:** look C Ring-reactor tank, animation B Hum, movement A Inexorable advance.

**Round 2** (on the same page, with the picks above preselected):
- **Siphon looks:** **D Probe stilt-walker** (four tall stilt legs, a long drain probe forward, an energy bulb
  behind), **E Battery hauler** (four wheels; battery cells fill one by one, fed by a front collector),
  **F Magnet crawler** (treads; a horseshoe electromagnet whose field drags energy in).
- **Siphon animations:** D Pump, E Rocking roll, F Stutter step.
- **Blackout Rig looks:** **D Derrick walker** (a braced lattice rig on four legs, the core at its heart),
  **E Smoke-stack crawler** (treads; stacks belch black smoke that spreads behind it), **F Eclipse orb walker**
  (a black orb on three legs; its ultraviolet corona flares on each pulse).
- **Blackout Rig animations:** D Lumber, E Rock, F Power sag.

**Round 3** (owner asked for three new designs each). These evolve from the Jammer pick (a four-legged antenna walker)
toward the Capacitor pick (a ring tank on treads), so the tiers read as one line:
- **Siphon looks:** **G Hose walker** (the Jammer's four-legged frame, grown, with two ribbed siphon hoses reaching
  forward and energy flowing back up them), **H Tether sapper** (a six-legged crawler whose three masts throw lime
  drain tethers out to the towers around it), **I Vacuum sled** (a low skid sled with a wide intake mouth and a
  glass cyclone canister).
- **Blackout Rig looks:** **G Blackout tank** (a heavy tank with a stubby EMP cannon on its turret and the Jammer's
  whip antennas trailing behind), **H Spider rig** (the Jammer grown huge: a six-legged armoured spider with a full
  crown of crackling antennas), **I Shroud crawler** (six black shroud panels open like a flower just before each
  pulse and fold shut after).

## Evader (role 6)

Mockup: `design/enemy_art_evader.html`, the same format as the other roles (three proposals each for look, animation
and movement, notes boxes, no "today").

**Evader family (draft):** the army's infiltrators: slim, angular stealth hulls, a single slit visor, phase fins or
emitters, and a visible evasion effect on the spec timing. **Tiers evolve:** T1 Blink Stalker is a lean bare frame; T2
Burrower is armoured for digging; T3 Shifter is sleek with phase gear; T4 Wraith is the sleekest and nearly invisible.
**Colour per enemy:** Blink Stalker graphite with neon orange, Burrower earth brown with a steel drill, Shifter chrome
silver with aqua, Wraith smoked glass with a pale ghost-white shimmer.

**Effects in the previews:** Blink Stalker charges, then blinks 80 px every 4 s, leaving an afterimage; Burrower digs
in and **vanishes** underground 2.5 s of every 5 (no mound, no shadow; owner, 2026-10-08), and inside a Sensor Array's
range a doppler ping shows where it is (the previews show the ping for the second half of each dive); Shifter blinks every 5 s and its landing throws a speed
wake (chevron ring); Wraith (now a flyer) is cloaked (a faint, shimmering double image) and the previews reveal it 2 s of every 6,
with a sensor reticle, as if inside a Sensor Array.

**Sizes (owner, 2026-10-08):** Shifter 12 px, Wraith 13 px (Blink Stalker is 10 and Burrower 11 today), so the tiers
step up.

| Enemy (trait from the name) | Look A | Look B | Look C |
|---|---|---|---|
| Blink Stalker, T1 ground (a hunter that blinks ahead) | Stalker biped: lean hunter, long sensor head | Blink hound: four-legged, blink coil on its back | Phase skiff: blade-thin hover, blink ring at the tail |
| Burrower, T2 ground (tunnels under the lane) | Drill worm: segmented, drill head | Mole digger: shovel claws, nose drill | Tunnel borer: short treads, toothed cutter face |
| Shifter, T3 ground (blinks; its wake speeds others up) | Phase walker: biped, three phase fins | Prism hover: flashing triangular prism | Twin-pod shifter: two pods on a phase beam |
| Wraith, T4 flyer since 2026-10-08 (cloaked; only energy hurts it) | Spectre frame: tall skeletal walker | Shroud drifter: hooded hover, trailing panels | Mirage blade: stealth wedge, light-bending edges |

| Enemy | Animation A / B / C | Movement A / B / C |
|---|---|---|
| Blink Stalker | Prowl / Crouch and spring / Lope | Blink hops / Prowl weave / Stalk and surge |
| Burrower | Dig-in bob / Wriggle / Rumble | Steady tunnel / Snake / Dive and surface |
| Shifter | Glide / Flicker / Stride | Phase steps / Side-shift / Smooth glide |
| Wraith | Drift / Waver / Lurk | Ghost drift / Unseen line / Haunting weave |

**Evader confirmed (owner, 2026-10-08).** Final picks:
- **Blink Stalker:** look **L Mag-lev orb** (round 5), animation **E Phase shimmer** (round 2), movement **F Feint and
  blink** (round 2). A ground unit.
- **Burrower:** look **G Drill pod** (round 3, from the owner's drilling-pod note), animation C Rumble, movement C Dive
  and surface. It **vanishes underground** (no mound, no shadow), and a doppler ping shows it inside a Sensor Array's
  range; specific towers or upgrades can hit it there (which ones is open in `design/enemies.md`).
- **Shifter:** look **B Prism hover**, animation A Glide, movement B Side-shift.
- **Wraith:** look **W Spectre wing** (round 8), animation A Drift, movement **C Haunting weave**. It is a **flyer**
  (owner, round 5) and ghosts while undetected: a soft spectral tail, faint trailing copies and a cold glow (round 9).

The owner's notes over the rounds, in order: Burrower "should disappear when underground" and "something like a
drilling pod"; Blink Stalker "a drone or a droid", then "more hover / flying options"; Wraith "ghostly but
mechanical/robotic", "hovering or flying", "more ghost / phantasmic ideas", "plane/jet-like", "more ghost-like
effects", then "more of a ghosting effect when undetected", "a ghost tail", and "the flat front of the tail is too
noticeable".

**Round 2** (on the same page, with the picks above preselected):
- **Blink Stalker animations:** D Head-snap, E Phase shimmer, F Slink. **Movements:** D Blink zigzag (blinks across
  to the other side of the lane), E Edge hugger, F Feint and blink (steps back, then blinks forward).
- **Burrower looks:** **D Auger crab** (driven by two spinning auger screws), **E Pile-driver quad** (four anchor legs
  around a big downward drill), **F Plough skimmer** (a flat delta with V plough blades throwing up earth).
- **Shifter looks:** **D Rift runner** (a long-legged runner with a rift ring that tears open), **E Phase cube walker**
  (a cube on four legs that turns a quarter-turn each blink), **F Sail skimmer** (a hover skimmer with two rippling
  phase sails).
- **Wraith looks:** **D Hollow frame** (floating armour plates around an empty glowing core), **E Halo walker** (a thin
  biped under a cloak-emitter halo), **F Stealth hover-tank** (a smooth hover tank with a dark glass canopy).

**Round 3** (on the same page, with the picks above preselected):
- **Blink Stalker looks:** **D Shard stalker** (a faceted shard of a body on three thin legs), **E Blink tripod** (a
  light tripod slung around a glowing blink sphere that charges before each jump), **F Lens stalker** (a round, low
  body on four thin legs, watching through one big lens that glints before it blinks).
- **Burrower drilling pods** (from the owner's note): **G Drill pod** (a smooth capsule behind a big spinning cone
  drill, pushed by two rear thrusters), **H Borer pod** (the Tunnel borer's toothed cutter face on a rounded pod with
  side skids), **I Twin-drill pod** (a wide pod with two counter-rotating cone drills).
- **Wraith looks**, grown from the Shifter's prism so the T3 and T4 tiers read as one line: **G Crystal prism** (a
  hovering hexagonal crystal whose facets flicker clear), **H Bipyramid glider** (a long double-pointed crystal
  gliding nose first), **I Prism stilt-walker** (a dark triangular prism on four tall, slow stilt legs).

**Round 4** (from the owner's notes, on the same page with the picks above preselected):
- **Blink Stalker, drones and droids** (they hover low but stay ground units): **G Ball droid** (a rolling ball with
  a dome head riding on top and a whip antenna), **H Hover-eye droid** (a disc droid skimming on its underglow, one
  big eye and two small grabber arms), **I Duct-fan drone** (a sleek pod on two ducted fans with a chin sensor).
- **Wraith, ghostly but mechanical:** **J Phantom droid** (a robot torso with grasping arms and two pale eyes, no
  legs, trailing off into a fading ion tail), **K Ribcage drifter** (a floating mechanical spine and ribcage with a
  sensor skull and a pale core caged inside), **L Echo walker** (a sleek robot walker leaving fading echoes of itself
  behind).

**Round 5** (from the owner's notes, on the same page with the picks above preselected):
- **Blink Stalker, hover looks** (still a ground unit): **J Hover-blade drone** (a sleek arrowhead floating on a
  glowing thruster ring, with two stabiliser fins), **K Twin-rotor scout** (a small body slung between two rotors on
  outriggers), **L Mag-lev orb** (a floating sensor orb held up by three small orbiting pods).
- **Wraith, flying looks** (the Wraith is now a flyer; every Wraith look gets a close air shadow that fades while
  cloaked): **M Skeletal wing drone** (bare wing struts strung with faint, tattered energy panels and a sensor-skull
  nose), **N Ghost rotorcraft** (a sleek rotor drone whose four rotor discs shimmer like mist), **O Lantern drone** (a
  pale core in a ribbed cage, held up by four thin rotor arms and trailing ion wisps).

**Round 6** (from the owner's note "Build more ghost / phantasmic ideas"; all fly and stay mechanical):
- **P Banshee mask:** a floating machine faceplate with hollow, pale-lit eye sockets, trailing a long, rippling
  spectral veil that ends in tatters; now and then it wails (rings from the mask).
- **Q Wisp cluster:** a caged core of cold, pale flame with three little wisp drones circling it on fading trails,
  each flickering in and out.
- **R Glitch spectre:** a robot that is only a flickering hologram (a pale wireframe torso, arms and head in
  scanlines) that tears sideways in glitches.

**Round 7** (from the owner's note "Build ghosty / phantasmal plane/jet-like"; all fly):
- **S Ghost fighter:** a sleek twin-tailed fighter jet whose wingtips dissolve into mist, its cold pale engines
  leaving fading contrails.
- **T Phantom flying wing:** a tailless flying wing, half see-through, its ribs showing through the skin and its
  sawtooth trailing edge fraying into wisps.
- **U Spectral interceptor:** a needle-nosed interceptor with forward-swept wings and canards, trailed by two fading
  echoes of itself as it phases.

**Round 8** (from the owner's note "Create more similar to S, T, and U, but add more of ghost-like affects to them",
and "Offer more animations as well"):
- **V Wraith fighter** (S, ghostlier): a fade wave sweeps the airframe nose to tail so parts vanish and return; long
  ectoplasm contrails, mist peeling off the wingtips, cold spectral engine flames.
- **W Spectre wing** (T, ghostlier): a see-through skin over a glowing skeleton (spar and ribs), a trailing double
  image, and edges constantly peeling into drifting motes around a pulsing core.
- **X Phantom interceptor** (U, ghostlier): four phasing echoes stream behind it, its wings flicker in and out, a
  spectral flame burns at the tail and the air ripples around it.
- **Wraith animations:** D Phase flicker (glides, then skips out of phase for a split second), E Banking glide (long,
  slow banks like a glider), F Spectral lunge (lunges forward stretching thin, then drifts back).

**Round 9** (from the owner's notes):
- **Stronger ghosting while undetected, on every Wraith look:** a long, soft spectral ghost tail streams and ripples
  behind it with drifting wisps (soft glow puffs that grow out from under the hull, with no hard edge; reworked after
  the owner found the flat front of the first tail too noticeable), two faint copies trail it, a cold glow pass flickers over it, and the body itself
  is fainter. A faint tail stays when it is revealed.
- **Y Comet wraith:** a small mechanical sensor head whose body streams back into a long, luminous ghost tail.
- **Z Revenant glider:** a long-winged glider drone trailing three rippling spectral streamers, from each wingtip and
  its tail.
- **Wraith animations for its design goal (hard to see, hard to track):** G Fade pulse (fades almost out of sight
  and back), H Dodge slip (sudden sideways dodges, smearing as it moves), I Vanishing sway (wide sways that fade at
  each edge). The mockup's animation system gained a transparency channel for these.

## Special (role 7)

Mockup: `design/enemy_art_special.html`, the same format as the other roles (three proposals each for look, animation
and movement, notes boxes, no "today"), with six enemies.

**Special family (draft):** one-off prototypes, each breaking one rule. They share a violet-white **X prototype mark**
(on the disguised units it is the **tell**), an exposed core cell, and a **looped effect** showing the rule each one
breaks. **No tiers:** every Special is its own thing. **Colour per enemy:** Phantom teal-grey camo, Aegis Walker
white-gold with an amber barrier, Hydra Frame oxide red with sand Skitters, Masquerade a rust Nanite shell over plum,
Decoy Beacon a gunmetal fake hull on a tan frame with a magenta beacon, Mirage mirror chrome with cyan holograms.

**Effects in the previews (looped):**
- **Phantom:** active camouflage (a faint double image; its sweeping scan line was removed at the owner's request); a blast flashes on it
  and reveals it for a moment, with the sensor reticle.
- **Aegis Walker:** an amber hex barrier that cracks under fire, shatters, stays down, then rebuilds.
- **Hydra Frame:** visibly carries three of the confirmed Skitters (Rusher A, Six-leg scuttler); destroyed, it bursts
  and the three scatter.
- **Masquerade:** wears the confirmed Nanite's look (Swarm A, Assembly hub) until it drops below half health, then the
  shell shatters to show its true form. Its **shadow is always its true size**, too big for a Nanite: a tell on every
  look.
- **Decoy Beacon:** draws as a heavy hull with a pulsing **rank badge** (three chevrons) for its fake high rank; each
  look has its own tell.
- **Mirage:** every 6 s throws two translucent, scanlined hologram copies of itself that walk ahead and fade.

**The tells** (`design/new_enemies.md`: "what it looks like is decided with the visual redesign"): proposed here as
part of each look; once picked they go into `design/new_enemies.md`.

**Sizes (owner, 2026-10-08):** Masquerade 12 px, Decoy Beacon 15 px, Mirage 12 px. Phantom 10, Aegis Walker 13 and
Hydra Frame 14 are today's.

| Enemy (rule it breaks) | Look A | Look B | Look C |
|---|---|---|---|
| Phantom (cloaked) | Camo stalker: slim biped in active camo | Cloak sled: skid sled under a cloak emitter | Mirror quad: four-legged mirror diamond |
| Aegis Walker (barrier) | Aegis strider: biped, emitter on its back | Emitter tripod: tripod under a dome emitter | Shield-arm walker: barrier from two forward arms |
| Hydra Frame (splits into 3 Skitters) | Carrier frame: Skitters clamped to three arms | Stack walker: three Skitters nose to tail in a cage | Hive pod: a Skitter peeking from each of three bays |
| Masquerade (disguised as a Nanite) | Hollow hub: tell is a prototype X glint; true form a bladed infiltrator | Mask shell: tell is a glitch that flashes its true outline; true form a four-legged hunter | Wrong-eye hub: tell is a violet eye and lockstep bots; true form a finned hover wedge |
| Decoy Beacon (fake high rank) | Inflatable heavy: hull breathes, barrel droops, treads never turn | Hologram heavy: a small projector shows through a flickering tank hologram | Hung-plate frame: armour plates swing on chains, with gaps |
| Mirage (hologram copies) | Projector walker: three-lens head | Prism rover: turning, sparkling prism | Mirror-fan hover: five angled mirror panels |

| Enemy | Animation A / B / C | Movement A / B / C |
|---|---|---|
| Phantom | Sneak / Freeze and dart / Shimmer | Infiltrate line / Shadow weave / Dart and freeze |
| Aegis Walker | Steady march / Brace for hits / Hum | Steady advance / Shield-wall drift / Escort weave |
| Hydra Frame | Clatter / Lumber / Strain | Trundle / Scuttle sway / Lurch |
| Masquerade | Copycat bob / Odd twitch / Glide | Mimic trickle / Blend-in weave / Straight |
| Decoy Beacon | Wobble / Trundle / Sway | Lumbering line / Slow sway / Stop and go |
| Mirage | Shimmer / Glide / Flicker step | Glide / Weave / Side-step |

**Special confirmed (owner, 2026-10-08).** Final picks:
- **Phantom:** look **E Camo glider**, animation **F Camo flicker** (made faster), movement **D Infiltration flight**.
  A **flyer** (owner); active camouflage as a faint double image (no scan line), revealed by a blast or a Sensor
  Array field.
- **Aegis Walker:** look **E Siege hexapod**, animation **B Brace for hits**, movement **A Steady advance**; the amber
  hex barrier cracks, shatters and rebuilds.
- **Hydra Frame:** look **H Cluster pod**, animation **A Clatter**, movement **A Trundle**; destroyed, the hatches
  blow and three of the confirmed Skitters burst out.
- **Masquerade:** look **J Unfolding stilt-walker**, animation **D Nervous jitter**, movement **I Scramble and dash**.
  Until uncovered it is the confirmed Drone with a purple eye, marching and moving like it, **at the Drone's speed
  (55)**; uncovered, it **moves faster** (owner; how much is open in `design/enemies.md`).
- **Decoy Beacon:** look **B Hologram heavy**, animation **F Track rumble**, movement **A Lumbering line**; a small
  projector shows through its flickering tank hologram, under a pulsing rank badge.
- **Mirage:** look **C Mirror-fan hover**, animation **B Glide**, movement **C Side-step**; every 6 s two copies appear,
  one in front and one behind, in step, shimmering like the Phantom's camouflage (faint doubles with a rapid flicker).

**Sizes (owner, 2026-10-08):** Masquerade 12 px, Decoy Beacon 15 px, Mirage 12 px.

**Picks (owner, 2026-10-08, sixth pass):** Phantom E/F/D, Aegis Walker E/B/A, **Hydra Frame H Cluster pod / A Clatter /
A Trundle**, Masquerade J/D/I and Decoy Beacon B/F/A are **confirmed**. Mirage: C Mirror-fan hover / C Side-step, animation
open; asked, the owner wanted more ideas, so **round 9** adds G Projection flare (swells and brightens each time it
throws its copies), H Echo stutter (quick back-and-forth bursts, as if its image repeats) and I Mirror sweep (slow
sweeps that fan its mirrors across the lane).

**Earlier picks (owner, 2026-10-08, fifth pass):**
- **Confirmed:** Phantom E/F/D, Aegis Walker E/B/A, Masquerade J/D/I, Decoy Beacon B/F/A.
- **Hydra Frame: reopened.** Look open with the owner's note "Make 6 more ideas"; animation A Clatter and movement
  A Trundle stay picked, with notes asking for more ideas for both. Round 8 adds six looks, three animations and three
  movements.
- **Mirage:** look **C Mirror-fan hover** (changed from O), movement C Side-step; animation open.

**Round 8** (on the same page, with the picks above preselected):
- **Hydra Frame looks** (all burst into the confirmed Skitters when destroyed): D Three-headed crawler (a true hydra:
  three long necks, a Skitter for each head), E Skitter shell (a giant Skitter-shaped shell with three hidden inside),
  F Skitter train (three Skitters coupled nose to tail on a spine), G Carousel carrier (three Skitters ride a turning
  carousel), H Cluster pod (an armoured egg with three hatch seams, cargo hidden), I Mother scuttler (a huge scuttler
  carrying three small Skitters on its back). **Animations:** D Heave, E Scuttle shimmy, F Restless rock.
  **Movements:** D Skitter rush, E Weaving column, F Stutter crawl.

**Earlier picks (owner, 2026-10-08, fourth pass):**
- **Confirmed:** Phantom E Camo glider / F Camo flicker / D Infiltration flight; Aegis Walker E Siege hexapod /
  B Brace for hits / A Steady advance; Hydra Frame C Hive pod / A Clatter / A Trundle; **Masquerade J Unfolding
  stilt-walker / D Nervous jitter / I Scramble and dash** (the Drone's look, March and Steady march until uncovered);
  Decoy Beacon B Hologram heavy / F Track rumble / A Lumbering line.
- **Mirage:** look **O Shard halo**, movement **C Side-step**; animation open. Owner's note: "The projection/hologram
  effect could be improved". Round 5 reworks the projection on every Mirage look: light beams run from the Mirage to
  each copy; each copy materialises behind a sweeping scan line; the copies are tinted cyan with a slight colour
  split, moving scanlines, flicker and glitch tears; and they break up into glitching slices as they fade. They stay
  in step, one in front and one behind.
  **Round 6 (owner: "Make the effect for mirage similar to the visual effect of the phantom"):** the hologram look
  above is replaced. The copies now shimmer like the Phantom's active camouflage: a faint doubled image and the
  Phantom's rapid flicker (owner: the sweeping scan line removed from both), shimmering in and out every 6 s (no beams, tint or scanlines).

**Earlier picks (owner, 2026-10-08, third pass):**
- **Phantom:** E Camo glider / F Camo flicker / D Infiltration flight. **Confirmed.** Owner's note: "Give a more rapid
  flickering", so Camo flicker now flickers much faster.
- **Aegis Walker** (E/B/A), **Hydra Frame** (C/A/A) and **Decoy Beacon** (B/F/A): **confirmed** as before.
- **Masquerade:** look **J Unfolding stilt-walker**, animation **D Nervous jitter** (both confirmed; Drone disguise and
  Drone march and movement until uncovered). Movement: A Mimic trickle picked, with the owner's note "Make a movement
  like it's trying to flee frantically"; round 4 adds three flee movements (G to I) to pick from.
- **Mirage:** open. Owner: "The projections are drifting. They should stay in-step with the main enemy. Make more
  designs that are more mysterious", and more animation ideas. The copies now hold a fixed spacing in front and behind
  and move in step with it.

**Earlier picks (owner, 2026-10-08, second pass):**
- **Phantom:** look **E Camo glider**, animation **F Camo flicker**, movement **D Infiltration flight**. **Confirmed.** A flyer.
- **Aegis Walker:** look **E Siege hexapod**, animation **B Brace for hits**, movement **A Steady advance**. **Confirmed.**
- **Hydra Frame:** look C Hive pod, animation A Clatter, movement A Trundle. **Confirmed.**
- **Masquerade:** look open; animation **D Nervous jitter** and movement **A Mimic trickle**, used once it is
  uncovered. Owner: "when disguised, it looks and animates just like the Drone, but keep the purple eye. Make some more
  designs"; animation and movement "should move just like the drone until uncovered". So on every look it now wears
  the confirmed Drone (Sentry walker) with a purple eye, marches like it and moves like it (Steady march) until
  uncovered (recorded in `design/new_enemies.md` and `design/enemies.md`). Looks A to I are renamed for their true
  forms (the shared disguise replaced their old ones); round 3 adds J to L.
- **Decoy Beacon:** look **B Hologram heavy**, animation **F Track rumble**, movement **A Lumbering line**. **Confirmed.**
- **Mirage:** open. Owner: "Make the projections in front and in back. Make more design ideas". The copies now appear
  one in front and one behind on every look; round 3 adds J to L.

**Earlier picks (owner, 2026-10-08, first pass):**
- **Phantom:** open. Owner: "Phantom should be a flyer", so it is now a **flyer** (gameplay change, recorded in
  `design/enemies.md` and `design/enemy_roster.md`). Round 2 offers three flying looks plus flyer animations and
  movements.
- **Aegis Walker:** open. Owner: "Build more bulky / heavy duty walker". Round 2 offers three.
- **Hydra Frame:** look **C Hive pod**, animation **A Clatter**, movement **A Trundle**. **Confirmed.**
- **Masquerade:** open. Owner: six more look ideas, more animation ideas, more movement ideas.
- **Decoy Beacon:** look **B Hologram heavy** (tell: the small projector shows through the flickering hologram),
  movement **A Lumbering line**; animation open. Owner: "Give more options that a tank would have".
- **Mirage:** open. Owner: six more look ideas, more movement ideas.

**Round 2** (on the same page, with the picks above preselected):
- **Phantom (now flies), looks:** D Stealth drone (a flat diamond with its fans inside), E Camo glider (long swept
  wings with rippling camo), F Chameleon rotor (a small rotor scout with a tail boom). **Animations:** D Hover bob,
  E Bank, F Camo flicker. **Movements:** D Infiltration flight, E Slipstream weave, F Hover and dash. Every Phantom
  look now has a close air shadow that fades while cloaked.
- **Aegis Walker, bulky looks:** D Bulwark mech (massive biped, huge gold-trimmed pauldrons, chest emitter), E Siege
  hexapod (six thick armoured legs, barrier dome on its back), F Rhino walker (low, stumpy-legged, gold ram plate and
  two barrier horns).
- **Masquerade, six more looks** (each a disguise, a tell and a true form; the oversized shadow is a tell on all):
  D Swarm cloak (fake Nanite bots in a too-perfect ring; a blade assassin), E Skitter skin (wears the confirmed
  Skitter, legs far too slow; a heavy brute), F Jammer copy (wears the confirmed Jammer, antennas never crackle, EMP
  never fires; a pincered mauler), G Folding shell (hinged panels with seams; they fold open into armour wings),
  H Puppet frame (a drone working a Nanite puppet on faint wires; the puppeteer itself), I Split shell (a violet seam
  across the hub; the halves push apart to show a lancer). **Animations:** D Nervous jitter, E Shell rattle,
  F Predator crouch. **Movements:** D Herd follower, E Stalk and slip, F Edge creep.
- **Decoy Beacon, tank animations:** D Pivot steer, E Cannon recoil, F Track rumble.
- **Mirage, six more looks:** D Holo-drone carrier (two projector drones circle it), E Kaleidoscope orb (turning,
  flashing mirror facets), F Twin-lens tank (two big projector lenses), G Light-sail walker (a flickering sail on its
  back), H Crystal spider (a crystal abdomen that splits light), I Strobe sentinel (a spinning strobe; copies appear
  in its flashes). **Movements:** D Split weave, E Jink, F Stop and project.

**Round 3** (on the same page, with the picks above preselected):
- **Masquerade true forms** (all disguised as the Drone with a purple eye): J Unfolding stilt-walker (its short legs
  unfold into tall stilts), K Uncoiling serpent (a segmented serpent uncoils out of the shell), L Shield knight (a
  heavy knight-mech behind a tall shield, with a long blade).
- **Mirage looks** (copies in front and behind): J Hologram drum (a spinning lens ring on short legs), K Two-way
  lantern (one lens forward, one back), L Bow-and-stern projector (a dish at each end).

**Round 4** (on the same page, with the picks above preselected):
- **Masquerade, flee movements** (used once it is uncovered; it marches like the Drone before): G Frantic flee (jagged,
  panicked surges), H Panic zigzag (wide, sharp zigzags), I Scramble and dash.
- **Mirage, more mysterious looks:** M Veiled monolith (a floating slab of black glass with faint crawling glyphs),
  N Hooded lens (a cowled machine with one cold lens under the hood), O Shard halo (no visible body: mirror shards
  turning around a point of light). **Animations:** D Phase shimmer, E Silent float, F Space fold.

## Boss (role 8)

Mockup: `design/enemy_art_boss.html`, the same format as the other roles (three proposals each for look, animation and
movement, notes boxes, no "today"), with bigger preview cards because the bosses are 22 to 32 px.

**Boss family (draft):** the army's command-class war machines: massive riveted armour, a crimson-and-gold **command
crest** (the boss sigil), heavy weapons, and each boss's **signature mechanic on a loop**. Each boss wears the colours of
what it spawns. **Colour per boss:** Dreadnought dark iron with crimson lights, Overmind rust-bronze with an amber core
(the Nanites' colours), Leviathan deep olive with yellow lights (the Locusts'), Colossus hazard yellow and bronze (the
Siege Mech's and Titan's).

**Mechanics in the previews (looped):**
- **Dreadnought** (22 px, 50% slow resist): a frost ring forms and cracks away every 3 s (slows slide off it), and its
  footfalls send out shock rings.
- **Overmind** (26 px, 60% slow resist): prints three of the confirmed **Nanites** every 5 s from its bays.
- **Leviathan** (30 px, flyer, 50% slow resist): launches six of the confirmed **Locusts** every 6 s from its bays.
- **Colossus** (32 px, 60% slow resist, can't be stunned): at 66% and then 33% health a layer of armour falls away and
  two of the confirmed **Siege Mechs** drop out (a 12 s loop: armoured, first shed, second shed).

| Boss | Look A | Look B | Look C |
|---|---|---|---|
| Dreadnought | Dread walker: biped with twin shoulder cannons | Dread tank: land battleship on four tread units, three turrets | Dread hexapod: six-legged fortress, command tower, side cannons |
| Overmind | Brain hive: neural core in a hex shell, three printer bays | Spider command: eight-legged walker with a brain dome | Lattice crawler: tracked, carrying a glowing brain lattice |
| Leviathan | Sky carrier: launch deck on four rotor pods | Whale airship: vast hull, tail fins, engine pods | Manta mothership: manta-shaped flying wing, launch bays |
| Colossus | Colossus mech: giant humanoid in layered plates | Siege citadel: walking fortress on eight legs, two wall rings | Crawler factory: tracked factory, skirts, roof plates, hangar |

| Boss | Animation A / B / C | Movement A / B / C |
|---|---|---|
| Dreadnought | Heavy stride / Command sway / Recoil volley | Relentless advance / Command sweep / Stomp and stop |
| Overmind | Thought pulse / Lumber / Print shudder | Slow creep / Pulsing advance / Hive drift |
| Leviathan | Slow bank / Cruise bob / Launch lurch | Straight cruise / Wide patrol / Hover and launch |
| Colossus | Earthquake stride / Grind / Shed shudder | Inexorable / Earthshaker / Titan sway |

**Picks (owner, 2026-10-08, second pass):**
- **Confirmed:** Dreadnought **B Dread tank** / A Heavy stride / A Relentless advance (look changed from A); Overmind
  A Brain hive (arachnid legs) / C Print shudder / A Slow creep; Colossus **A Colossus mech** / **E Lumbering sway** /
  A Inexorable.
- **Leviathan:** animation **I Dive and climb**, movement **A Straight cruise**; look open. Owner's note: "Make more of a
  mothership/jet/plane design". Round 4 adds J Flying-wing mothership (a vast tailless wing with buried engines and a
  sawtooth trailing edge), K Jet carrier (an airliner-like carrier with four jet pods and a high tail) and L Delta
  mothership (a huge delta with a command ridge and a bank of exhausts).

**Earlier picks (owner, 2026-10-08, first pass):**
- **Dreadnought:** look **A Dread walker**, animation **A Heavy stride**, movement **A Relentless advance**. **Confirmed.**
- **Overmind:** look **A Brain hive**, animation **C Print shudder**, movement **A Slow creep**. Owner's note: "Make the
  legs more arachnid like", so the Brain hive now walks on eight long, jointed spider legs.
- **Leviathan:** open. Owner: more look ideas, more animation ideas.
- **Colossus:** look and animation open, movement A Inexorable picked. Owner: more ideas for look, animation and
  movement.

**Round 2** (on the same page, with the picks above preselected):
- **Leviathan looks:** D Hive dreadship (a hexagonal hive-ship whose honeycomb cells launch the Locusts, rotor arrays
  around it), E Sky serpent (a long segmented sky-ship rippling like a serpent, fin rotors along its body), F Rotor
  fortress (a round flying fortress ringed by ten rotors, launch rails to the rim). **Animations:** D Undulate, E Rotor
  thrum, F Majestic glide.
- **Colossus looks:** D Titan-king (the Titan's colossus grown into a crowned giant, armour skirts like a cape),
  E Walking foundry (four legs, a molten furnace core, a crane on its back; the Siege Mechs climb down), F Centaur
  tank-mech (a tracked hull carrying a giant mech torso with a cannon arm and a crusher claw). **Animations:**
  D Furnace pulse, E Lumbering sway, F Ground slam. **Movements:** D Shed surge (slow at first, faster after each shed,
  as in the game), E Wide stomp, F Halt and drop.

**Round 3** (owner: "Create new ideas for Leviathan and Colossus"):
- **Leviathan looks:** G Kraken carrier (an armoured hull trailing six mechanical tentacle-cranes whose claws release
  the Locusts), H Swarm-cloud mothership (a command core hidden inside a slowly turning cloud of its own Locusts),
  I Anvil battlecruiser (a wedge-hulled capital ship with a flight deck, three turrets and glowing engines).
  **Animations:** G Heavy yaw, H Swarm churn, I Dive and climb.
- **Colossus looks:** G Skyscraper walker (a tower block on four legs; tiers fall away), H Bucket-wheel excavator (a
  tracked excavator with a turning bucket wheel on a long boom), I Gun-fortress walker (a six-legged platform under a
  massive double-barrelled turret). **Animations:** G Tower lean, H Hydraulic hiss, I Crushing step.

## Open questions

1. **Boss picks:** the Leviathan's look (A to L; J to L are the mothership, jet and plane designs).
2. After Boss: the art direction is complete; implementation waits on the owner's confirmation of the full spec
   (`design/enemies.md` has its own open questions).
