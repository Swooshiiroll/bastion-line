# Bastion Line upgrade trees (v3.1 design)

The full tower roster and every upgrade path: the 11 current towers with a new third branch each,
plus 3 new towers. Every tower has a two-tier trunk, then three branches (A, B, C) of four upgrades
and a mastery, and can take a secondary branch. Numbers on new nodes are first-pass values; the
balance probe tunes them once they're in the game.

How to edit:
- Each tower is a `## Name` section: a metadata line, a one-line role, then one table.
- Keep the table's seven columns. `Cost` is in credits. `Status` is `existing`, `new` or `changed`.
- `Tier`: `1` and `2` are the trunk (`Path` = `base`). In a branch, `3` to `6` are its four upgrades
  (3 is the specialization you pick), `M` is its mastery and `P` its prestige.
- `Path` is `base`, `A`, `B` or `C`. Separate stats with ` · `. Branch upgrades 4-6 list what they
  add; the specialization and the mastery list full stats.
- Every row needs a description in `Effect`: one plain sentence saying what the upgrade is and does.
  It becomes the in-game tooltip.
- A `## Heading` with bullets and no table (like Rules) shows on the page as a panel. Anything else
  outside those sections (like this list) is ignored.

## Rules

- After the Retrofit a tower can climb up to two branches, in any order and switching between them
  freely, up to two upgrades on each. Once two branches are started, the third is locked.
- Buying the third upgrade on either branch makes it the primary: it can go on to its mastery, and
  the other branch (the secondary) is blocked where it is, at one or two upgrades.
- A secondary branch works exactly as it would as a primary: its specialization and the step after
  it give their full effects. The branch is just capped at two upgrades.
- So that two branches stack, the game applies every upgrade as its difference from the node before
  it (a specialization as its difference from the Retrofit). The tower's stats are the Retrofit plus every
  upgrade it owns. Each specialization card on the page shows what it adds this way.
- A secondary's stat changes apply in full, downsides included: Supernova as a secondary adds
  +70 damage but also slows the waves by 0.15/s.
- Specializations that change how the tower attacks (marked `attack:` in a tower's metadata)
  don't bring their stat line as a secondary. They add their attack alongside the primary's
  instead (see Combinations).
- All three branches are open from the start. Masteries still need research: one node per tower
  unlocks all three of its masteries.
- Keys: `U`, `I` and `O` buy the next upgrade on branches A, B and C. The new towers are built with
  `=`, `[` and `]`.
- A mastery costs 1.35× its v3.0 price, and never less than 12% above the upgrade before it.
- Selling refunds the whole tower as today; there's no respec.

## Combinations

- Some specializations change how a tower attacks. When one of those is the secondary, the primary
  keeps its attack and the secondary's attack is added alongside it:
- Pulse Turret: a Flechette secondary fires a flechette cone every third volley.
- Arc Coil: an Ion Storm secondary leaves a storm field where each discharge lands; with an Ion Storm
  primary, Overload makes the storm's ticks stun and Storm Coil makes it arc to 2 nearby enemies.
- Laser Lance: a Sweeper secondary makes a locked beam sweep 25° around its target; with a Sweeper
  primary, Focus Lens ramps damage on enemies the beam crosses repeatedly, and Prism Array adds beams.
- Graviton Projector: a Gravity Well secondary makes every second pulse pull instead of shove; with a
  Gravity Well primary, Repulsor adds a shove on the pulse that releases, and Crush Field adds its stun.
- Nova Reactor: branches stack as numbers, since every branch keeps the shockwave.
- Drone Bay: secondaries add their drones to the primary's wing (a Bomber Wing secondary adds 2 bombers).
- Other specializations stack as numbers (Cluster Munitions adds its bomblets, Dual Purpose its
  ground hits).

## Research

- The three new towers each get a Research Lab tree in the same shape as the others (8 RP): a root
  node, a range branch, a signature branch and the Mastery.
- Nullifier: Null Coils (+6% barrier strip) → Wide Emitters (+10% field) and Rapid Discharge (−10%
  pulse interval) → Nullifier Mastery.
- Nova Reactor: Reactor Tuning (+6% damage) → Shock Lensing (+8% radius) and Fusion Stability (+10%
  wave rate) → Nova Mastery.
- Drone Bay: Drone Firmware (+6% damage) → Long-Range Uplink (+10% drone speed) and Spare Airframes
  (+1 drone) → Drone Bay Mastery.
- With the Scrapyard's tree the lab costs 130 RP, and the records pay up to 150. A tower's Mastery needs
  every other node in its tree (since v3.4).

## Prestige (design draft, not in the game yet)

- Every branch gets a sixth step after its mastery: the prestige. It lists full stats (like the
  mastery) and adds one signature mechanic of its own. Its row is `P`.
- A prestige stays hidden in the upgrade tree (a sealed node) until that branch's mastery is bought.
- Only one tower of each type can hold each branch's prestige at a time: one Tempest Array, one
  Unmaker and one Flechette Storm on the field, but never two Tempest Arrays. The node explains why
  it's blocked ("Another Pulse Turret holds Tempest Array"). Selling that tower frees it.
- Prestiges cost roughly 2.2× their mastery. They aren't part of the secondary rules: only the
  primary can reach its prestige.
- Prestige research: each tower tree gains two nodes after its Mastery, and a Prestige node that
  needs both (and so the whole tree before it). The Prestige node unlocks all three of the tower's
  prestiges. The two new nodes give that tower's usual kind of bonus again (damage, range or its
  signature stat) so the tree still pays off before the Prestige.
- Proposed prices: 1 + 1 + 3 RP per tower, 75 RP for all 15 towers, taking the whole lab from 130
  to 205 RP.

## Open questions

- All numbers on new nodes are placeholders until the balance probe has run with them in the game.
- Prestige research needs more RP than the records can pay (150 today). A proposal: endless pays
  up to 10 RP per sector (was 5; +30), rounds 110 and 120 become milestones (+12), and Nightmare and
  Cataclysm medals pay 5 and 7 RP (were 4 and 5; +18), for 210 in all. Or cheaper prestige research.
- Should a prestige also be able to go on a secondary branch? (Drafted as primary only.)
- Pairs with opposite trade-offs are the strongest combinations (Pulse Reactor with Supernova, Sky
  Shredder with Proximity Burst, Gatling Pulse with Shredder). Watch them first when probing.

## Pulse Turret
id: arrow · key: 1 · hits: air + ground · status: existing · attack: C · branches: gatling, shredder, flechette
Rapid single-target bolts.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Pulse Turret | 50 | 9 dmg · 140 range · 2.0/s | A compact turret that fires rapid energy bolts at one target, air or ground. | existing |
| 2 | base | Retrofit | 70 | 15 dmg · 152 range · 2.4/s | Twin emitters: harder-hitting bolts, fired faster and a little further. | existing |
| 3 | A | Gatling Pulse | 140 | 16 dmg · 160 range · 5.0/s | Four spinning barrels: double the rate of fire. | existing |
| 4 | A | Cooled Barrels | 170 | +0.4/s | Liquid cooling keeps the barrels spinning. | new |
| 5 | A | Hardened Bolts | 200 | +3 dmg | Denser bolt casings that hit harder on every one of the many shots. | new |
| 6 | A | Belt Feed | 300 | +10 range · +0.6/s · +2 dmg | A continuous ammo belt and a raised mount: faster fire, more damage and longer reach. | new |
| M | A | Storm Gatling | 410 | 24 dmg · 175 range · 7.0/s · 2 targets | Twin ammo feeds: every volley also fires at a second target. | changed |
| P | A | Tempest Array | 900 | 30 dmg · 185 range · 8.5/s · 3 targets · every 10th volley hits everything in range | Three ammo feeds, and every tenth volley sprays every enemy in range at once. | new |
| 3 | B | Shredder | 140 | 28 dmg · 165 range · 3.0/s · shred 1 (max 8) | Each hit permanently strips 1 armor. | existing |
| 4 | B | Serrated Rounds | 170 | +4 dmg | Saw-toothed rounds that bite deeper into the plating they've already stripped. | new |
| 5 | B | Tungsten Core | 200 | shred max +2 | Strips up to 10 armor. | new |
| 6 | B | Fracture Rounds | 300 | +0.3/s · +6 dmg · +10 range | Rounds that shatter on impact: more damage, faster cycling and a longer reach. | new |
| M | B | Disintegrator | 410 | 52 dmg · 180 range · 3.6/s · shred 2 (max 14) | Each hit strips 2 armor. Dreadnoughts come apart. | changed |
| P | B | Unmaker | 900 | 64 dmg · 190 range · 4.0/s · shred 3 (max 20) · +20% damage to enemies stripped to 0 armor | Strips armor three at a time, and anything stripped bare takes 20% more damage from every tower. | new |
| 3 | C | Flechette | 140 | 11 dmg × 6 · 130 range · 1.6/s · 45° cone | Fires a cone of flechettes that hits every enemy in the arc, air and ground. | new |
| 4 | C | Wider Choke | 170 | +5° cone | A wider choke spreads the flechettes over a broader arc. | new |
| 5 | C | Dense Pack | 200 | +1 flechette | Packs one more flechette into every shell. | new |
| 6 | C | Rapid Pump | 300 | +3 dmg · +0.3/s | A pump-action loader and heavier darts: faster volleys that hit harder. | new |
| M | C | Hailstorm | 410 | 16 dmg × 9 · 145 range · 2.0/s · 60° cone · bypasses barriers | A wider cone, and flechettes slip past barriers to hit the hull directly. | new |
| P | C | Flechette Storm | 900 | 18 dmg × 12 · 160 range · 2.2/s · 90° cone · bypasses barriers · flechettes pass through to a second enemy | A quarter-circle of flechettes, each punching through its first target into the one behind. | new |

## Plasma Mortar
id: cannon · key: 2 · hits: ground · status: existing · branches: siege, napalm, buster
Splash damage, ground only.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Plasma Mortar | 90 | 22 dmg · 130 range · 0.7/s · 55 blast | Lobs plasma shells that burst over an area, hitting every ground enemy in the blast. | existing |
| 2 | base | Retrofit | 120 | 40 dmg · 140 range · 0.75/s · 65 blast | Bigger shells: more damage, a wider blast and a little more range. | existing |
| 3 | A | Siege Mortar | 210 | 80 dmg · 165 range · 0.8/s · 90 blast | Heavier shells, a much bigger blast and longer range. | existing |
| 4 | A | Long Barrel | 250 | +10 range | A longer barrel reaches further down the lane. | new |
| 5 | A | Heavy Payload | 300 | +20 dmg | Heavier shells for much bigger hits. | new |
| 6 | A | Auto-Loader | 450 | +8 blast · +0.1/s | An automatic loader and wider-dispersal shells: faster fire and a bigger blast. | new |
| M | A | Earthshaker | 510 | 150 dmg · 190 range · 0.95/s · 110 blast · 0.4 s stun | Shockwave shells stun everything in the blast (bosses 0.12 s). | changed |
| P | A | Worldbreaker | 1100 | 190 dmg · 200 range · 1.0/s · 130 blast · 0.5 s stun · every 4th shell sends an aftershock that stuns again | Every fourth shell rolls an aftershock ring through the blast, stunning everything a second time. | new |
| 3 | B | Plasma Burn | 210 | 55 dmg · 150 range · 70 blast · 32 burn/s for 3 s | Leaves a plasma pool that burns ground enemies, ignoring armor. | existing |
| 4 | B | Hotter Plasma | 250 | +8 burn/s | Hotter plasma: the pools burn harder. | new |
| 5 | B | Sticky Gel | 300 | +1 s burn | A sticky gel binder keeps the pools burning for an extra second. | new |
| 6 | B | Pressurized Tanks | 450 | +6 blast · +15 dmg · +8 burn/s | Pressurized tanks: bigger shells, wider pools and hotter burns. | new |
| M | B | Inferno Mortar | 510 | 90 dmg · 165 range · 85 blast · 65 burn/s for 5 s | White-hot pools that burn longer and hotter. | changed |
| P | B | Sunfall | 1100 | 110 dmg · 175 range · 95 blast · 90 burn/s for 6 s · pools spread 20 px per second while enemies stand in them | Pools that feed on their victims, spreading outward while anything is burning in them. | new |
| 3 | C | Bunker Buster | 210 | 70 dmg · 150 range · 0.7/s · 60 blast · −3 armor for 4 s · hits burrowed | Delayed-fuse shells detonate underground: they hit burrowed enemies and strip armor from everything in the blast. | new |
| 4 | C | Deep Fuse | 250 | +10 dmg | A deeper fuse drives the shell further before it goes off, for more damage. | new |
| 5 | C | Penetrator Tip | 300 | −1 more armor | Penetrator tips strip one more point of armor from everything in the blast. | new |
| 6 | C | Twin Charges | 450 | +8 blast · +0.1/s | Two charges per shell: faster fire and a wider shockwave underground. | new |
| M | C | Seismic Charge | 510 | 130 dmg · 165 range · 0.85/s · 80 blast · −6 armor for 5 s · hits burrowed · unearths for 4 s | Collapses tunnels: burrowed enemies in the blast are forced up and can't dig again for 4 s. | new |
| P | C | Tectonic Lance | 1100 | 160 dmg · 175 range · 0.9/s · 90 blast · −9 armor for 6 s · hits burrowed · unearths for 6 s · each shell erupts along 160 px of lane | Shells dive into the lane and erupt along it, breaking armor on everything in the fault line. | new |

## Cryo Emitter
id: frost · key: 3 · hits: air + ground · status: existing · branches: stasis, shatter, cryolock
Area slow plus light damage.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Cryo Emitter | 70 | 3 dmg · 105 range · 35% slow | Pulses a freezing field that slows every enemy in range and deals light damage. | existing |
| 2 | base | Retrofit | 90 | 6 dmg · 118 range · 45% slow | A stronger coolant loop: a deeper slow over a wider field. | existing |
| 3 | A | Stasis Field | 150 | 10 dmg · 145 range · 65% slow | Near-freezing slow over a wide area. | existing |
| 4 | A | Wider Coils | 180 | +10 range | Wider emitter coils stretch the stasis field. | new |
| 5 | A | Deep Chill | 220 | +0.3 s slow duration | A deeper chill: enemies stay slowed 0.3 s longer after each pulse. | new |
| 6 | A | Cryo Pumps | 320 | +4 dmg · +15 range | Upgraded cryo pumps: a much wider field and ice spikes that hurt a little more. | new |
| M | A | Absolute Zero | 380 | 22 dmg · 185 range · 70% slow | The maximum slow over the widest field in the arsenal. | changed |
| P | A | Stasis Singularity | 850 | 26 dmg · 200 range · 70% slow · every 8 s freezes everything in the field for 1 s (bosses 0.3 s) | The field periodically locks solid, freezing every enemy inside in place. | new |
| 3 | B | Shatter Field | 150 | 12 dmg · 132 range · 50% slow · +25% damage taken | Chilled enemies take more damage from every source. | existing |
| 4 | B | Brittle Frost | 180 | +5% damage taken | Brittle frost makes chilled enemies take 5% more damage from everything. | new |
| 5 | B | Fast Freeze | 220 | +0.15/s pulses | Faster freezing cycles: the field pulses more often. | new |
| 6 | B | Crystal Lattice | 320 | +8 range · +5% damage taken · +3 dmg | A crystal lattice: wider reach, harder hits and even more damage taken. | new |
| M | B | Cryo Fracture | 380 | 24 dmg · 150 range · 55% slow · +45% damage taken | Chilled enemies take far more damage from every source. | changed |
| P | B | Shatterpoint | 850 | 28 dmg · 160 range · 55% slow · +55% damage taken · chilled enemies that die shatter for 10% of their max health in 60 px | Frozen hulls shatter when destroyed, shrapnel tearing into everything around them. | new |
| 3 | C | Cryo Lock | 150 | 8 dmg · 130 range · 45% slow · blocks repair | Freezes repair systems: enemies in the field can't regenerate or be healed. | new |
| 4 | C | Circuit Frost | 180 | +10 range | Frost creeps into circuits further out: a wider lock field. | new |
| 5 | C | Lingering Lock | 220 | lock lasts 1 s after leaving | The lock lingers: repairs stay frozen for 1 s after an enemy leaves the field. | new |
| 6 | C | Iced Relays | 320 | +5% slow · +10 range · +4 dmg | Iced relays: a deeper slow, a wider field and harder frost. | new |
| M | C | Permafrost | 380 | 16 dmg · 160 range · 55% slow · +15% damage taken · blocks repair · blocks barrier recharge | Barriers stop recharging too, and locked enemies take extra damage. | new |
| P | C | Glacial Prison | 850 | 20 dmg · 175 range · 60% slow · +20% damage taken · blocks repair · blocks barrier recharge · barriers in the field take 3× damage | Barriers freeze brittle inside the field and crack under three times the damage. | new |

## Railgun
id: sniper · key: 4 · hits: air + ground · status: existing · branches: deadeye, lance, nullslug
Huge range, ignores armor.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Railgun | 120 | 55 dmg · 290 range · 0.45/s | Fires a magnetic slug at extreme range that ignores armor. | existing |
| 2 | base | Retrofit | 150 | 105 dmg · 330 range · 0.5/s | Longer rails: much heavier slugs with even more range. | existing |
| 3 | A | Deadeye | 260 | 170 dmg · 420 range · 0.6/s · 2× vs bosses | Longest range in the arsenal. | existing |
| 4 | A | Match Slugs | 310 | +25 dmg | Precision-machined slugs for bigger hits. | new |
| 5 | A | Stabilized Rails | 380 | +20 range | Stabilized rails hold their aim at even longer range. | new |
| 6 | A | Weak-Point Scan | 560 | +0.05/s · 2.3× vs bosses | A weak-point scanner and faster capacitors: bosses take 2.3× damage and shots come quicker. | new |
| M | A | Executioner | 630 | 280 dmg · 470 range · 0.7/s · 2.5× vs bosses | Destroys any non-boss target left under 20% health. | changed |
| P | A | Kingslayer | 1400 | 340 dmg · 520 range · 0.75/s · 3.5× vs bosses · executes non-bosses below 25% · every 5th shot at a boss adds 5% of its max health | Built for one job: every fifth slug into a boss tears away a slice of its total health. | new |
| 3 | B | Piercing Rail | 260 | 130 dmg · 380 range · 0.6/s | The slug punches through every enemy in a straight line. | existing |
| 4 | B | Denser Slug | 310 | +20 dmg | A denser slug keeps more of its punch as it tears through the line. | new |
| 5 | B | Longer Rails | 380 | +20 range | Longer rails extend the line of fire. | new |
| 6 | B | Wide Bore | 560 | +0.05/s · 14 px line | A wider bore and quicker charging: the line hits everything within 14 px and fires faster. | new |
| M | B | Ion Lance | 630 | 220 dmg · 430 range · 0.75/s · 22 px line | The line hits everything within 22 px of it. | changed |
| P | B | Horizon Lance | 1400 | 260 dmg · 470 range · 0.8/s · 30 px line · the line runs to the edge of the map at full damage | The beam carries across the whole sector, hitting everything along it at full strength. | new |
| 3 | C | Null Slug | 260 | 150 dmg · 360 range · 0.55/s · 4 s suppression · strips barrier | Deletes the target's barrier and shuts off its abilities: healing, EMP, auras, spawns, blinking, burrowing and regeneration. | new |
| 4 | C | Longer Jam | 310 | +1 s suppression | The jamming charge lasts a second longer. | new |
| 5 | C | Hardened Slug | 380 | +25 dmg | A hardened core for more damage per slug. | new |
| 6 | C | Wide Jam | 560 | +0.05/s · suppression splashes 30 px | The jam bursts on impact, suppressing enemies within 30 px too, and the rails recharge faster. | new |
| M | C | Void Round | 630 | 240 dmg · 400 range · 0.65/s · 8 s suppression · 60 px spread · strips barrier · exposes | Suppression lasts longer, spreads to nearby enemies, and strips crowd-control immunity. | new |
| P | C | Null Horizon | 1400 | 280 dmg · 440 range · 0.7/s · 12 s suppression · 90 px spread · strips barrier · exposes · suppressed enemies take +25% damage | Silenced enemies are left defenceless, taking a quarter more damage from everything. | new |

## Arc Coil
id: tesla · key: 5 · hits: air + ground · status: existing · attack: C · branches: storm, overload, ionstorm
Chain lightning; double damage to barriers.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Arc Coil | 130 | 16 dmg · 118 range · 3 chains | Discharges lightning that leaps between nearby enemies. Barriers take double damage. | existing |
| 2 | base | Retrofit | 160 | 26 dmg · 128 range · 4 chains | A stronger coil: harder arcs that jump to one more target. | existing |
| 3 | A | Storm Coil | 280 | 36 dmg · 145 range · 9 chains | Arcs leap further and lose less power per jump. | existing |
| 4 | A | Extra Toroid | 340 | +1 chain | An extra toroid ring lets each arc jump to one more enemy. | new |
| 5 | A | Conductive Air | 410 | +10 chain range | Ionized air: arcs can leap 10 px further between targets. | new |
| 6 | A | Twin Spires | 590 | +5 dmg · +2 chains | Twin spires: arcs hit harder and chain to two more enemies. | new |
| M | A | Tempest Coil | 660 | 55 dmg · 160 range · 15 chains | Arcs barely weaken between jumps. | changed |
| P | A | Thunder God | 1450 | 66 dmg · 175 range · 20 chains · arcs can strike the same enemy twice and jump 120 px | Lightning that doubles back, leaping further and striking its victims again. | new |
| 3 | B | Overload | 280 | 42 dmg · 140 range · 5 chains · 0.5 s stun | Every arc stuns its targets (bosses 0.15 s). | existing |
| 4 | B | Capacitor Bank | 340 | +6 dmg | A larger capacitor bank puts more power behind every arc. | new |
| 5 | B | Stun Tuning | 410 | +0.1 s stun | Tuned discharges keep their targets stunned 0.1 s longer. | new |
| 6 | B | Faster Discharge | 590 | +1 chain · +0.1/s | Faster discharge cycles and one more jump per arc. | new |
| M | B | Supercharger | 660 | 64 dmg · 155 range · 7 chains · 0.8 s stun | Longer stuns and harder hits. | changed |
| P | B | Overlord Coil | 1450 | 78 dmg · 165 range · 8 chains · 1.0 s stun · stunned enemies arc to one more enemy each second | Stunned enemies become conductors, passing the charge on to their neighbours. | new |
| 3 | C | Ion Storm | 280 | 24 dmg per tick · 130 field · 2 ticks/s | Instead of chaining, charges a storm field that damages everything inside, air and ground. Double damage to barriers. | new |
| 4 | C | Denser Ions | 340 | +4 dmg per tick | Denser ions: the storm hits harder with every tick. | new |
| 5 | C | Wider Front | 410 | +8 field | A wider storm front covers more of the lane. | new |
| 6 | C | Storm Front | 590 | +15% damage after 2 s inside · +4 dmg per tick · +6 field | Static builds up: a wider, stronger storm, and enemies that stay 2 s take 15% more damage. | new |
| M | C | Maelstrom | 660 | 42 dmg per tick · 160 field · 2 ticks/s · blocks barrier grants | A wider, stronger storm. Enemies inside can't receive Bulwark barriers. | new |
| P | C | Eye of the Storm | 1450 | 50 dmg per tick · 180 field · 2.5 ticks/s · blocks barrier grants · a second storm follows the leading enemy down the lane | A second storm cell breaks away and hunts the enemy furthest along the lane. | new |

## Laser Lance
id: laser · key: 6 · hits: air + ground · status: existing · attack: C · branches: prism, focus, sweeper
Continuous beam that ignores armor and ramps up on one target.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Laser Lance | 140 | 22 dps · 125 range · ramps to 2× | A continuous beam that ignores armor and grows stronger the longer it holds one target. | existing |
| 2 | base | Retrofit | 150 | 36 dps · 135 range · ramps to 2.5× | A brighter emitter: more damage, more range and a higher ramp. | existing |
| 3 | A | Prism Array | 300 | 38 dps · 145 range · 3 beams | Splits into three beams (extra beams at 60% power). | existing |
| 4 | A | Focusing Optics | 360 | +5 dps | Focusing optics make every beam burn hotter. | new |
| 5 | A | Fourth Facet | 440 | +1 beam | A fourth facet splits off another beam. | new |
| 6 | A | Brighter Split | 640 | −0.5 s ramp time · extra beams at 70% | Brighter splits: the extra beams reach 70% power and ramp up faster. | new |
| M | A | Refraction Grid | 720 | 56 dps · 160 range · 6 beams | Six beams on six targets. | changed |
| P | A | Prismatic Lattice | 1550 | 64 dps · 175 range · 8 beams · beams on the same target fuse into one at 150% of their total | Beams that meet on one target fuse into a single, far hotter lance. | new |
| 3 | B | Focus Lens | 300 | 50 dps · 150 range · ramps to 4× | Boss killer. | existing |
| 4 | B | Cooled Lens | 360 | +6 dps | A cooled lens takes a hotter beam. | new |
| 5 | B | Quick Lock | 440 | −0.5 s ramp time | Quicker lock-on: the beam reaches full power half a second sooner. | new |
| 6 | B | Overdrive Lens | 640 | +10 range · ramps to 5× | An overdrive lens ramps up to 5× on a single target and reaches further. | new |
| M | B | Singularity Lens | 720 | 72 dps · 170 range · ramps to 7× | Nothing survives a long lock. | changed |
| P | B | Stellar Core | 1550 | 84 dps · 185 range · ramps to 10× · keeps its ramp when it switches target | The lens never cools: the ramp carries over from one target to the next. | new |
| 3 | C | Sweeper | 300 | 30 dps · 140 range · 70° sweep · no ramp | The beam sweeps back and forth across an arc, burning every enemy it crosses. | new |
| 4 | C | Wider Sweep | 360 | +15° arc | The sweep covers 15° more of the lane. | new |
| 5 | C | Hotter Beam | 440 | +6 dps | A hotter beam burns harder as it sweeps. | new |
| 6 | C | Lingering Burn | 640 | sweeps 30% faster · crossed enemies burn 10 dps for 1 s | Faster sweeps, and every enemy the beam crosses keeps burning for a second. | new |
| M | C | Scythe Array | 720 | 48 dps · 155 range · 2 beams · 120° sweep · 2× vs barriers | Two counter-sweeping beams that burn through barriers at double rate. | new |
| P | C | Reaper Halo | 1550 | 54 dps · 170 range · 3 beams · 360° sweep · 2× vs barriers · the beams spin full circles through everything in range | Three beams wheel around the tower in full circles, burning everything they cross. | new |

## Missile Battery
id: missile · key: 7 · hits: air + ground · status: existing · branches: swarm, hellfire, cluster
Homing salvos with a small blast; double damage to flyers.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Missile Battery | 110 | 18 dmg · 190 range · 2 missiles | Fires homing missiles with a small blast. Flyers take double damage. | existing |
| 2 | base | Retrofit | 140 | 26 dmg · 200 range · 3 missiles | A third launch tube and stronger warheads. | existing |
| 3 | A | Swarm Pods | 260 | 24 dmg · 210 range · 5 missiles | Salvos spread across targets. | existing |
| 4 | A | Sixth Tube | 310 | +1 missile | A sixth tube adds another missile to every salvo. | new |
| 5 | A | Better Seekers | 380 | +10 range | Better seekers lock on from further away. | new |
| 6 | A | Quick Reload | 560 | +3 dmg · +0.1/s | Quicker reloads and shaped charges: faster salvos that hit harder. | new |
| M | A | Locust Swarm | 630 | 30 dmg · 230 range · 8 missiles | Eight missiles per salvo. | changed |
| P | A | Hivemind Salvo | 1400 | 34 dmg · 245 range · 12 missiles · missiles that lose their target find a new one | A networked swarm: no missile is wasted on a target that's already gone. | new |
| 3 | B | Hellfire | 260 | 65 dmg · 215 range · 2 missiles · 50 blast · 3× vs flyers | Heavy warheads with a big blast. | existing |
| 4 | B | Bigger Warheads | 310 | +12 dmg | Bigger warheads for much heavier hits. | new |
| 5 | B | Wide Blast | 380 | +5 blast | A wider blast radius on every warhead. | new |
| 6 | B | Proximity Fuses | 560 | +1 missile · +5 blast | Proximity fuses and a third tube: one more missile per salvo and a wider blast. | new |
| M | B | Doomsday Warheads | 630 | 115 dmg · 235 range · 3 missiles · 70 blast · 3× vs flyers | Colossal warheads. | changed |
| P | B | Armageddon | 1400 | 140 dmg · 250 range · 3 missiles · 85 blast · 3× vs flyers · every 6th salvo is a single 600 dmg warhead with a 160 px blast | Every sixth salvo is one enormous warhead that flattens everything nearby. | new |
| 3 | C | Cluster Munitions | 260 | 20 dmg · 205 range · 3 missiles · 4 bomblets (26 blast) | Each missile bursts into bomblets that carpet the target area. | new |
| 4 | C | Fifth Bomblet | 310 | +1 bomblet | Each missile carries one more bomblet. | new |
| 5 | C | Wider Scatter | 380 | +4 bomblet blast | Bomblets scatter wider and burst bigger. | new |
| 6 | C | Hot Bomblets | 560 | +1 missile · +3 dmg | Hot bomblets and a fourth tube: one more missile per salvo, hitting harder. | new |
| M | C | Carpet Bomber | 630 | 26 dmg · 225 range · 4 missiles · 7 bomblets (32 blast) · pierces armor | More bomblets, and they ignore armor. | new |
| P | C | Firestorm Doctrine | 1400 | 30 dmg · 240 range · 4 missiles · 10 bomblets (36 blast) · pierces armor · bomblets leave fires (20 burn/s for 2 s) | Bomblets set the ground alight wherever they land. | new |

## Amplifier Pylon
id: amp · key: 8 · hits: support · status: existing · branches: overclock, array, suppression
Boosts the damage of nearby towers (the best pylon applies; they don't stack).

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Amplifier Pylon | 100 | 100 field · +15% damage | Broadcasts a power field that boosts the damage of towers inside it. | existing |
| 2 | base | Retrofit | 120 | 115 field · +25% damage | A stronger broadcast over a wider field. | existing |
| 3 | A | Overclock Pylon | 220 | 125 field · +30% damage · +25% speed | Nearby towers hit harder and faster. | existing |
| 4 | A | Tuned Relays | 260 | +5% speed | Tuned relays make boosted towers fire 5% faster. | new |
| 5 | A | Wider Broadcast | 320 | +5 field | A wider broadcast reaches more towers. | new |
| 6 | A | Heat Sinks | 470 | +5% damage · +5% speed | Heat sinks let boosted towers run hotter: +5% damage and +5% speed. | new |
| M | A | Hypercore Pylon | 530 | 140 field · +45% damage · +40% speed | A hypercore overdrives every tower in the field: the biggest damage and speed boost in the arsenal. | changed |
| P | A | Overdrive Nexus | 1150 | 150 field · +50% damage · +50% speed · stacks with one other pylon's boost at half strength | The only pylon whose boost adds to another's: towers in both fields get this plus half the other. | new |
| 3 | B | Targeting Array | 220 | 125 field · +25% damage · +25% range | Nearby towers hit harder and reach further. | existing |
| 4 | B | Better Optics | 260 | +5% range | Better optics give boosted towers 5% more range. | new |
| 5 | B | Wider Broadcast | 320 | +5 field | A wider broadcast reaches more towers. | new |
| 6 | B | Range Finders | 470 | +5% damage · +5% range | Range finders sharpen the fire control: +5% damage and +5% range. | new |
| M | B | Command Array | 530 | 145 field · +40% damage · +40% range | A full command array: towers in the field hit far harder and reach far further. | changed |
| P | B | Strategic Uplink | 1150 | 150 field · +45% damage · +45% range · towers in the field fire at one extra target | A shared targeting network: every tower in the field splits its fire across an extra target. | new |
| 3 | C | Suppression Pylon | 220 | 125 field · +25% damage · jams support | Jams enemy support inside its field: Rally haste, Bulwark barriers and Repair Bot heals don't work there. | new |
| 4 | C | Stronger Jam | 260 | +5 field | A stronger jammer covers a wider field. | new |
| 5 | C | Signal Noise | 320 | enemies inside move 10% slower | Signal noise scrambles enemy drives: enemies in the field move 10% slower. | new |
| 6 | C | Wide Jam | 470 | +5% damage · +10 field | A wider jamming field, and boosted towers hit 5% harder. | new |
| M | C | Silence Pylon | 530 | 150 field · +35% damage · jams everything | Also shuts down Jammer EMPs and Overmind or Leviathan launches inside the field. | new |
| P | C | Void Bastion | 1150 | 165 field · +40% damage · jams everything · exposes enemies in the field | Nothing keeps its tricks inside the field: support is jammed and immunities fail. | new |

## Flak Battery
id: flak · key: 9 · hits: air · status: existing · branches: skyshred, burst, dualpurpose
Anti-air airbursts that hit every flyer in the blast.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Flak Battery | 80 | 16 dmg · 175 range · 1.4/s · 38 burst | Anti-air cannon whose airbursts hit every flyer in the blast. | existing |
| 2 | base | Retrofit | 100 | 28 dmg · 190 range · 1.5/s · 42 burst | Heavier shells, faster fire and a wider burst. | existing |
| 3 | A | Sky Shredder | 190 | 30 dmg · 200 range · 3.2/s | Twin autocannons: more than double the rate of fire. | existing |
| 4 | A | Faster Feed | 230 | +0.3/s | A faster ammo feed keeps the cannons firing. | new |
| 5 | A | Better Fuses | 280 | +4 burst | Better fuses widen each airburst. | new |
| 6 | A | Third Cannon | 400 | +10 range · +0.5/s | A third cannon and a tracking radar: much faster fire at longer range. | new |
| M | A | Aerial Denial | 450 | 40 dmg · 225 range · 4.6/s | Four autocannons saturate the sky. | changed |
| P | A | Iron Sky | 1000 | 46 dmg · 240 range · 5.5/s · flyers hit take +25% damage from all towers for 2 s | Relentless fire that leaves flyers crippled for the rest of the defence. | new |
| 3 | B | Proximity Burst | 190 | 80 dmg · 210 range · 1.2/s · 70 burst | Heavy shells with a huge airburst. | existing |
| 4 | B | Heavier Shells | 230 | +15 dmg | Heavier shells for bigger airbursts. | new |
| 5 | B | Wider Burst | 280 | +5 burst | Wider bursts catch more of a swarm. | new |
| 6 | B | Auto-Loader | 400 | +10 range · +0.1/s | An auto-loader and a tracking radar: faster fire at longer range. | new |
| M | B | Thunderhead | 450 | 150 dmg · 240 range · 1.4/s · 90 burst · 0.5 s stun | Massive airbursts that also stun flyers. | changed |
| P | B | Skyfall | 1000 | 180 dmg · 255 range · 1.4/s · 110 burst · 0.6 s stun · destroyed flyers crash for 50% of their max health in 60 px | Flyers brought down crash onto the lane below, crushing whatever is under them. | new |
| 3 | C | Dual Purpose | 190 | 34 dmg · 195 range · 1.3/s · 45 burst · 60% vs ground | Timed fuses: airbursts also hit ground enemies at reduced damage. | new |
| 4 | C | Ground Fuses | 230 | 70% vs ground | Better ground fuses: airbursts hit ground enemies at 70%. | new |
| 5 | C | Bigger Shells | 280 | +6 dmg | Bigger shells hit harder in the air and on the ground. | new |
| 6 | C | Rapid Feed | 400 | +6 burst · +0.2/s · 80% vs ground | A rapid feed and wider bursts: faster fire, and ground enemies take 80%. | new |
| M | C | Flak Curtain | 450 | 54 dmg · 215 range · 1.6/s · 64 burst · shred 2 · 100% vs ground | Full damage to ground targets, and every burst shreds 2 armor. | new |
| P | C | Steel Rain | 1000 | 62 dmg · 230 range · 1.8/s · 72 burst · shred 3 · 100% vs ground · every shell bursts twice | Double-burst shells: a second detonation 0.4 s after the first. | new |

## Sensor Array
id: sensor · key: 0 · hits: support · status: existing · branches: deepscan, painter, disruptor
Reveals cloaked enemies and marks targets to take extra damage.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Sensor Array | 75 | 130 field · +8% mark | A radar dish that reveals cloaked enemies in its field and marks them to take extra damage. | existing |
| 2 | base | Retrofit | 90 | 150 field · +12% mark | A bigger dish: a wider field and a stronger mark. | existing |
| 3 | A | Deep Scan | 160 | 210 field · +14% mark | The widest reveal field. | existing |
| 4 | A | Bigger Dish | 190 | +15 field | A bigger dish scans a wider field. | new |
| 5 | A | Signal Boost | 230 | +1% mark | A signal booster strengthens the mark. | new |
| 6 | A | Dual Dish | 340 | +15 field · +2% mark | A second dish: a much wider field and a stronger mark. | new |
| M | A | Omniscient Grid | 380 | 280 field · +20% mark | Sees nearly half the sector at once. | changed |
| P | A | Panopticon | 850 | 320 field · +22% mark · reveals cloaked enemies everywhere on the map | Sees the whole sector: no cloak works anywhere while it stands. | new |
| 3 | B | Target Painter | 160 | 160 field · +25% mark | Laser designators: marked enemies take more damage. | existing |
| 4 | B | Brighter Lasers | 190 | +3% mark | Brighter lasers make marked enemies take 3% more damage. | new |
| 5 | B | Wider Beam | 230 | +5 field | A wider painting beam covers more of the lane. | new |
| 6 | B | Twin Designators | 340 | marks last 1 s after leaving · +4% mark | Twin designators: a stronger mark that stays on for 1 s after an enemy leaves the field. | new |
| M | B | Kill Beacon | 380 | 175 field · +40% mark | Marked enemies take far more damage from everything. | changed |
| P | B | Death Mark | 850 | 185 field · +50% mark · marked enemies pay +25% kill credits | Marked enemies are worth more when they fall. | new |
| 3 | C | Disruptor | 160 | 150 field · +12% mark · disrupts | Jams movement tricks in its field: no burrowing, no blinking, and cloaks fail. | new |
| 4 | C | Wider Jam | 190 | +10 field | The jamming field reaches further. | new |
| 5 | C | Echo Scan | 230 | cloaks stay revealed 1 s after leaving | Echo scans keep cloaked enemies revealed for 1 s after they leave the field. | new |
| 6 | C | Long Jam | 340 | +3% mark · +15 field | A long-range jammer: a much wider field and a stronger mark. | new |
| M | C | Blackout Grid | 380 | 200 field · +18% mark · disrupts · exposes | Also strips crowd-control immunity (Rampart, Colossus) inside the field. | new |
| P | C | Total Blackout | 850 | 220 field · +20% mark · disrupts · exposes · jams everything | A complete blackout: no cloaks, no immunities, no support inside the field. | new |

## Graviton Projector
id: gravity · key: - · hits: ground · status: existing · attack: C · branches: repulsor, crush, well
Gravity pulses that move ground enemies along the lane (bosses 25%).

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Graviton Projector | 150 | 12 dmg · 105 range · 40 px shove | Gravity pulses shove ground enemies back down the lane and crush them. | existing |
| 2 | base | Retrofit | 160 | 22 dmg · 115 range · 52 px shove | A stronger core: bigger shoves and harder pulses. | existing |
| 3 | A | Repulsor | 290 | 30 dmg · 125 range · 85 px shove | Violent pulses hurl enemies back down the lane. | existing |
| 4 | A | Denser Core | 350 | +10 px shove | A denser core throws enemies 10 px further. | new |
| 5 | A | Wider Field | 420 | +5 range | A wider field catches more of the lane. | new |
| 6 | A | Faster Pulses | 620 | +8 dmg · +0.03/s | Faster pulses that also crush harder. | new |
| M | A | Singularity Engine | 690 | 55 dmg · 140 range · 0.36/s · 130 px shove | Throws whole columns of enemies back. | changed |
| P | A | Event Engine | 1500 | 65 dmg · 150 range · 0.4/s · 150 px shove · shoves flyers too | Gravity strong enough to throw flyers back along their route too. | new |
| 3 | B | Crush Field | 290 | 75 dmg · 120 range · 30 px shove · 0.6 s stun | Crushing gravity: heavy damage and a stun. | existing |
| 4 | B | Heavier Field | 350 | +12 dmg | A heavier field crushes harder. | new |
| 5 | B | Lasting Pin | 420 | +0.1 s stun | A lasting pin keeps enemies stunned 0.1 s longer. | new |
| 6 | B | Faster Pulses | 620 | +5 range · +0.03/s | Faster pulses over a wider field. | new |
| M | B | Event Horizon | 690 | 135 dmg · 135 range · 0.5/s · 1 s stun | Pins everything in the field and crushes it. | changed |
| P | B | Black Hole | 1500 | 160 dmg · 145 range · 0.5/s · 1.2 s stun · every 10 s crushes non-boss enemies in the field below 15% health | Periodically collapses, crushing anything in the field that's already failing. | new |
| 3 | C | Gravity Well | 290 | 25 dmg · 125 range · 50 px pull · 20% slow | Pulls enemies toward one point on the lane, bunching them up for splash towers. | new |
| 4 | C | Deeper Well | 350 | +10 px pull | A deeper well pulls enemies 10 px further. | new |
| 5 | C | Heavier Hold | 420 | +5% slow | A heavier hold slows held enemies 5% more. | new |
| 6 | C | Crushing Grip | 620 | +5 range · +10 dmg | A crushing grip over a wider well: held enemies take more damage. | new |
| M | C | Collapse Point | 690 | 45 dmg · 140 range · 75 px pull · implodes every 3rd pulse for 6% max HP | Every third pulse implodes for 6% of max HP on everything held (bosses 1.5%). | new |
| P | C | Gravity Well Prime | 1500 | 52 dmg · 155 range · 90 px pull · implodes every 2nd pulse for 7% max HP | Implodes twice as often, each time tearing a slice off everything held. | new |

## Nullifier
id: nullifier · key: = · hits: air + ground · status: new · branches: purge, dampener, feedback
A dampening pulse that strips enemy defences: barriers, armor and immunities.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Nullifier | 120 | 5 dmg · 110 field · pulse every 2 s · strips 40% of barriers | Pulses a dampening field that strips away part of every enemy barrier inside it. | new |
| 2 | base | Retrofit | 130 | 8 dmg · 120 field · pulse every 1.7 s · strips 60% of barriers · exposes | Enemies in the field lose crowd-control immunity. | new |
| 3 | A | Purge Emitter | 240 | 10 dmg · 130 field · strips 100% of barriers · −3 armor inside · exposes | Wipes barriers clean and weakens armor while enemies stay in the field. | new |
| 4 | A | Wider Emitter | 290 | +8 field | A wider emitter covers more of the lane. | new |
| 5 | A | Deep Purge | 350 | −1 more armor | A deeper purge strips one more point of armor inside the field. | new |
| 6 | A | Long Emitter | 510 | pulse every 1.4 s · +8 field | A faster cycle and a longer emitter: pulses every 1.4 s over a wider field. | new |
| M | A | Absolute Null | 570 | 16 dmg · 155 field · −7 armor inside · exposes · blocks barrier recharge | Barriers can't re-form inside the field at all. | new |
| P | A | Nullspace | 1250 | 18 dmg · 170 field · −10 armor inside · exposes · blocks barrier recharge · enemies inside take +15% damage | A dead zone where armor, barriers and immunities all fail. | new |
| 3 | B | Dampener | 240 | 8 dmg · 130 field · suppresses abilities inside · exposes | Shuts off every enemy ability in the field: healing, auras, EMP, spawns, blinking, burrowing, regeneration. | new |
| 4 | B | Wider Dampening | 290 | +8 field | A wider dampening field silences more enemies. | new |
| 5 | B | Lingering Silence | 350 | suppression lingers 1 s | Silence lingers on enemies for 1 s after they leave the field. | new |
| 6 | B | Long Dampening | 510 | pulse every 1.4 s · +8 field | A faster cycle and a longer reach: pulses every 1.4 s over a wider field. | new |
| M | B | Silence Engine | 570 | 14 dmg · 155 field · suppression lingers 3 s · exposes · suppresses bosses at half | Suppression follows enemies out of the field, and works on bosses at half strength. | new |
| P | B | Dead Zone | 1250 | 16 dmg · 170 field · suppression lingers 5 s · exposes · suppresses bosses fully | Even bosses are fully silenced inside the field. | new |
| 3 | C | Feedback Loop | 240 | 8 dmg · 125 field · strips 60% of barriers · exposes · returns 100% of the stripped barrier | Barrier it strips is dealt back to the enemy's hull as damage. | new |
| 4 | C | Stronger Pull | 290 | strips 70% of barriers | A stronger pull strips 70% of each barrier. | new |
| 5 | C | Amplified Return | 350 | returns 125% of the stripped barrier | Amplified feedback returns 125% of each stripped barrier as damage. | new |
| 6 | C | Wider Loop | 510 | pulse every 1.4 s · +10 field | A faster, wider loop: pulses every 1.4 s over a bigger field. | new |
| M | C | Overload Cascade | 570 | 14 dmg · 145 field · strips 85% of barriers · exposes · returns 125% of the stripped barrier · cascades 50% in 60 px | Stripped barriers also detonate for 50% as splash (60 px). | new |
| P | C | Feedback Storm | 1250 | 16 dmg · 160 field · strips all barriers · exposes · returns 150% of the stripped barrier · cascades 75% in 80 px | Every barrier in the field is torn away and hurled back as a wider, harder blast. | new |

## Nova Reactor
id: nova · key: [ · hits: air + ground · status: new · branches: supernova, pulsereactor, solarflare
A 360° shockwave that hits everything around it, air and ground.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Nova Reactor | 160 | 30 dmg · 100 radius · 0.5/s | A reactor that releases a shockwave all around it, hitting every enemy in range, air and ground. | new |
| 2 | base | Retrofit | 170 | 50 dmg · 110 radius · 0.55/s | A hotter core: stronger, wider and slightly faster waves. | new |
| 3 | A | Supernova | 300 | 120 dmg · 125 radius · 0.4/s | Slow, devastating shockwaves. | new |
| 4 | A | Denser Core | 360 | +20 dmg | A denser core puts more power into each wave. | new |
| 5 | A | Wider Wave | 440 | +8 radius | Each wave reaches further. | new |
| 6 | A | Overcharged Core | 640 | +0.05/s · +30 dmg | An overcharged core: much stronger waves, released a little faster. | new |
| M | A | Hypernova | 720 | 220 dmg · 150 radius · 0.45/s · strips 50% of barriers | Each wave also shatters half of every barrier it hits. | new |
| P | A | Quasar | 1550 | 270 dmg · 165 radius · 0.45/s · strips 75% of barriers · every 4th wave adds a 240 px ring at half damage | Every fourth wave is followed by a second, far wider ring. | new |
| 3 | B | Pulse Reactor | 300 | 34 dmg · 110 radius · 1.2/s | Rapid low-power rings that shred swarms. | new |
| 4 | B | Faster Cycling | 360 | +0.15/s | Faster cycling releases more rings per second. | new |
| 5 | B | Stronger Rings | 440 | +5 dmg | Each ring hits harder. | new |
| 6 | B | Overclocked Cycling | 640 | +6 radius · +0.15/s | Overclocked cycling: faster rings that reach further. | new |
| M | B | Chain Reactor | 720 | 48 dmg · 120 radius · 1.7/s · 40 px mini-novas | Every kill sets off a 40 px mini-nova. | new |
| P | B | Fusion Cascade | 1550 | 56 dmg · 130 radius · 1.9/s · 60 px mini-novas · mini-novas can chain one step further | Chain reactions that set off chain reactions. | new |
| 3 | C | Solar Flare | 300 | 50 dmg · 115 radius · 0.55/s · 20 burn/s for 2 s | Waves leave the ground burning, ignoring armor. | new |
| 4 | C | Hotter Flares | 360 | +6 burn/s | Hotter flares make the burning ground hurt more. | new |
| 5 | C | Longer Burn | 440 | +1 s burn | The ground keeps burning for an extra second. | new |
| 6 | C | Plasma Core | 640 | +6 radius · +10 dmg · +6 burn/s | A plasma core: stronger, wider waves and hotter flames. | new |
| M | C | Corona | 720 | 65 dmg · 130 radius · 0.55/s · 45 burn/s aura | A constant burning aura around the reactor, on top of its waves. | new |
| P | C | Star Heart | 1550 | 75 dmg · 145 radius · 0.6/s · 70 burn/s aura · enemies burning in the aura take +15% damage | A miniature star: anything in its glow burns and takes more damage from every tower. | new |

## Drone Bay
id: drones · key: ] · hits: air + ground · status: new · attack: B · branches: interceptors, bombers, hunters
Launches hunter drones that chase enemies anywhere on the map.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Drone Bay | 180 | 2 drones · 12 dmg · 3 shots/s · 160 speed | Launches combat drones that hunt enemies anywhere on the map. | new |
| 2 | base | Retrofit | 170 | 3 drones · 16 dmg · 3 shots/s · 170 speed | A bigger hangar: one more drone, and all of them hit harder. | new |
| 3 | A | Interceptor Wing | 300 | 5 drones · 16 dmg · 4 shots/s · 220 speed · 2× vs flyers | Fast interceptors that hunt flyers first. | new |
| 4 | A | Sixth Drone | 360 | +1 drone | A sixth interceptor joins the wing. | new |
| 5 | A | Afterburners | 440 | +30 speed | Afterburners get the interceptors to their targets faster. | new |
| 6 | A | Seventh Drone | 640 | +3 dmg · +1 drone | A seventh interceptor, and better guns for the whole wing. | new |
| M | A | Swarm Carrier | 720 | 9 drones · 20 dmg · 4.5 shots/s · 250 speed · 2× vs flyers | A full carrier deck: nine interceptors that shred flyers anywhere on the map. | new |
| P | A | Armada | 1550 | 12 drones · 24 dmg · 5 shots/s · 280 speed · 2× vs flyers · idle drones hunt the nearest flyer anywhere | A full armada that sweeps the whole sky between targets. | new |
| 3 | B | Bomber Wing | 300 | 2 bombers · 60 dmg bombs · 40 blast · ground only | Heavy drones that carpet ground enemies. | new |
| 4 | B | Bigger Bombs | 360 | +15 bomb dmg | Bigger bombs for heavier hits. | new |
| 5 | B | Wider Blast | 440 | +5 blast | A wider blast from every bomb. | new |
| 6 | B | Faster Rearm | 640 | +1 bomber · drops 25% more often | A third bomber, and faster rearming for the whole wing. | new |
| M | B | Strike Wing | 720 | 4 bombers · 100 dmg bombs · 52 blast · hits burrowed | Bombs also hit burrowed enemies. | new |
| P | B | Carpet Wing | 1550 | 6 bombers · 120 bomb dmg · 60 blast · hits burrowed · each run drops a line of 3 bombs | Every bombing run lays a line of three bombs along the lane. | new |
| 3 | C | Hunter-Killer | 300 | 3 drones · 20 dmg · marks +20% · hunts specialists | Hunts specialists first (Stalker, Rally Beacon, Bulwark, Mender, Jammer, Repair Bot) and marks them. | new |
| 4 | C | Fourth Drone | 360 | +1 drone | A fourth hunter-killer joins the pack. | new |
| 5 | C | Target Database | 440 | also hunts Phantoms and Gunships first | An updated target database: the drones also go for Phantoms and Gunships first. | new |
| 6 | C | Stronger Marks | 640 | +4 dmg · marks +25% | Stronger marks and better guns: marked enemies take 25% more damage. | new |
| M | C | Assassin Protocol | 720 | 5 drones · 30 dmg · marks +30% · hunts specialists · suppresses target | A drone locked on a target also suppresses its abilities. | new |
| P | C | Black Ops | 1550 | 6 drones · 40 dmg · marks +35% · hunts specialists · suppresses target · after a kill, the next specialist takes a double-damage first shot | Kill, retarget, strike: each kill sets up a double-damage opening shot on the next specialist. | new |

## Scrapyard
id: scrap · key: \ · hits: none (economy) · status: new · branches: mint, collector, depot
Economy: turns wreckage into credits instead of fighting.

| Tier | Path | Name | Cost | Stats | Effect | Status |
|---|---|---|---|---|---|---|
| 1 | base | Scrapyard | 150 | 25 cr per round | A salvage yard that strips wrecks for parts and pays out credits every time a round is cleared. | new |
| 2 | base | Retrofit | 175 | 55 cr per round | A second crusher line more than doubles the payout. | new |
| 3 | A | Credit Mint | 300 | 110 cr per round | Presses salvage straight into credits: the biggest steady income. | new |
| 4 | A | Stamping Press | 320 | +25 cr per round | A faster press turns out more credits each round. | new |
| 5 | A | Vault Doors | 380 | +30 cr per round | Secure storage lets the mint run larger batches. | new |
| 6 | A | Treasury Link | 480 | +40 cr per round | A direct line to command's treasury raises every payout. | new |
| M | A | Reserve Bank | 900 | 250 cr per round · 3% interest (max 300) | Also pays 3% interest on your banked credits at each round clear, up to 300. | new |
| P | A | Central Treasury | 1900 | 320 cr per round · 5% interest (max 600) · 1 cr per enemy destroyed anywhere | The whole sector feeds the treasury: every kill anywhere pays a credit. | new |
| 3 | B | Scrap Collector | 280 | 150 field · +25% kill credits | Magnet cranes sweep the lane: enemies destroyed in its field pay 25% more credits. | new |
| 4 | B | Magnet Cranes | 300 | +25 field | Longer crane arms reach further down the lane. | new |
| 5 | B | Sorting Line | 320 | +10% kill credits | Sorts the wreckage for the valuable parts. | new |
| 6 | B | Smelter | 460 | +10% kill credits · +25 field | Melts scrap down on site: more credits from a wider field. | new |
| M | B | Reclamation Plant | 850 | 200 field · +60% kill credits · bosses pay double | Enemies destroyed in its field pay 60% more, and bosses pay double. | new |
| P | B | Salvage Empire | 1800 | 230 field · +80% kill credits · bosses pay triple · leaked enemies refund 25% of their credits | Nothing goes to waste: even leaks pay a salvage fee. | new |
| 3 | C | Supply Depot | 280 | 140 field · 10% off upgrades | Stockpiled parts: towers in its field upgrade for 10% less. | new |
| 4 | C | Bulk Orders | 300 | +5% off upgrades | Buying in bulk cuts upgrade prices further. | new |
| 5 | C | Freight Rail | 320 | +30 field | A rail spur delivers parts to more of the line. | new |
| 6 | C | Procurement Office | 460 | +5% off upgrades · +20 field | Better contracts and a wider delivery area. | new |
| M | C | Forward Command | 850 | 200 field · 25% off upgrades · 100% sell refund | Towers in its field upgrade for 25% less and sell back for everything spent on them. | new |
| P | C | Supreme Command | 1800 | 230 field · 35% off upgrades · 100% sell refund · towers built in the field cost 15% less | Cheaper upgrades, cheaper builds and full refunds across its whole field. | new |
