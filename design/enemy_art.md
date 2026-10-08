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

**Picks (owner, 2026-10-08, fifth pass):**
- **Blink Stalker:** look **L Mag-lev orb** (from round 5), animation **E Phase shimmer**, movement **F Feint and
  blink**. **Confirmed.** It stays a ground unit.
- **Burrower:** look **G Drill pod**, animation C Rumble, movement C Dive and surface. **Confirmed.** It vanishes
  underground, and a doppler ping shows it inside a Sensor Array's range; the gameplay side is in `design/enemies.md`.
- **Shifter:** look B Prism hover, animation A Glide, movement B Side-shift. **Confirmed.**
- **Wraith:** look **open**, with the owner's notes "Build more ghost / phantasmic ideas" (round 6), "Build ghosty /
  phantasmal plane/jet-like" (round 7) and "Create more similar to S, T, and U, but add more of ghost-like affects to
  them" (round 8); animation **open** (left blank; the owner then asked for more animations), movement **B Unseen
  line**. A real flyer since round 5.

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

## Open questions

1. **Wraith look and animation:** look any of A to X (V to X are the ghostlier aircraft, S to U the first planes and
   jets), animation any of A to F (D to F are new).
2. **Next role** after Evader (remaining: Special, Boss).
