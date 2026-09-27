# Bastion Line Super Structures (design draft)

Four specific towers standing in a 2×2 block, each with its primary locked in, can merge into a
Super Structure: a single 2×2 building with its own two-branch upgrade tree. Six recipes, drafted
for review. Nothing here is in the game yet, and every number is a first pass.

How to edit:
- Each structure is a `## Name` section: a metadata line, a one-line role, then one table.
- Metadata: `id`, the `recipe` (four tower ids, in reading order for the layout), and the `layout`:
  `pairs` (each pair of the same tower side by side, top and bottom rows), `diagonal` (same towers on
  the diagonals) or `any` (any arrangement of the four).
- `Tier`: `1` is the structure itself (its cost is the merge price). In a branch, `2` to `4` are its
  three upgrades and `M` its mastery. `Path` is `base`, `A` or `B`.
- Separate stats with ` · `. Branch upgrades list what they add; the base and the masteries list full
  stats. Every row needs a description in `Effect`.

## Rules

- A recipe is four specific towers in a 2×2 block, in the layout it asks for. Every one of the four
  must have its primary locked in (a branch at T3 or beyond); which branches doesn't matter.
- When a block matches, selecting any of its towers shows "Merge into <Structure>" in the bottom bar,
  with the merge price. Merging replaces the four towers with the structure, which takes their 2×2
  block. Everything spent on the four towers and the merge counts toward its sell value.
- A structure has two branches (A and B) of three upgrades and a mastery. It commits to one branch:
  there's no secondary.
- Only one of each structure can stand on the field at a time.
- Structures keep the site bonus rule of other 2×2 towers: a power node or high ground under any of
  their four tiles counts.
- Merging is unlocked by a Super Structures node in the Command research tree; each structure's
  mastery needs its own research, like tower masteries.
- A structure can't be split back into its towers. Selling refunds it like any tower.

## Open questions

- Should a structure inherit anything from the four towers' primaries (for example a Shredder
  primary adding shred), or always be the same regardless of how they were upgraded? Drafted as
  always the same, which is simpler to read and balance.
- Merge prices are drafted at 1,500 to 1,700 credits on top of the four towers. Is merging meant to
  be a late-game sink (higher) or a mid-game spike (lower)?
- Six recipes cover twelve of the fifteen towers. The Scrapyard and Drone Bay are already 2×2, so they
  can't sit in a block; the Missile Battery and Plasma Mortar appear twice. More recipes later?
- Research cost for the Super Structures node and the six structure masteries, which also feeds the
  RP question in the upgrade-trees draft.

## Railstorm Citadel
id: railstorm · recipe: sniper, tesla, tesla, sniper · layout: diagonal
Railguns charged by arc coils: slugs that tear down a line and shed lightning off everything they pierce.

| Tier | Path | Name | Cost | Stats | Effect |
|---|---|---|---|---|---|
| 1 | base | Railstorm Citadel | 1600 | 420 dmg · 480 range · 0.6/s · 30 px line · each hit arcs to 4 enemies for 40% | Fires a charged slug down a line; everything it pierces sheds lightning to the enemies around it. |
| 2 | A | Capacitor Banks | 900 | +80 dmg | Deeper capacitor banks put more energy into every slug. |
| 3 | A | Twin Rails | 1100 | +0.2/s | A second rail alternates with the first. |
| 4 | A | Magnetic Lens | 1300 | +60 range · +10 px line | A longer, wider line. |
| M | A | Railstorm | 2600 | 600 dmg · 560 range · 0.8/s · 45 px line · arcs to 6 enemies for 50% · arcs stun 0.4 s | Every slug is a storm: its arcs stun everything they touch. |
| 2 | B | Ion Trail | 900 | leaves a storm along its line for 3 s (30 dmg per tick) | The slug's path keeps crackling after it passes. |
| 3 | B | Grounding Rods | 1100 | +2 arcs | More enemies share each discharge. |
| 4 | B | Static Field | 1300 | enemies hit take +15% damage for 3 s | Charged hulls conduct every other tower's damage better. |
| M | B | Thunder Rail | 2600 | 450 dmg · 500 range · 0.7/s · storm lines for 5 s (60 dmg per tick) · arcs to 8 enemies | Paints the lane with lingering storms. |

## Aegis Bastion
id: aegis_bastion · recipe: frost, gravity, gravity, frost · layout: diagonal
A crowd-control fortress: a huge cryo field that periodically locks everything solid and hurls it back.

| Tier | Path | Name | Cost | Stats | Effect |
|---|---|---|---|---|---|
| 1 | base | Aegis Bastion | 1500 | 40 dmg · 200 field · 60% slow · every 6 s: 1 s freeze and 90 px shove | A cold field that freezes everything inside every six seconds and throws it back down the lane (bosses 30% freeze, 25% shove). |
| 2 | A | Deep Cold | 800 | +20 field | The field reaches further. |
| 3 | A | Brittle Ice | 1000 | +20% damage taken | Frozen enemies crack under every tower's fire. |
| 4 | A | Cold Snap | 1200 | freezes every 5 s | The field locks solid more often. |
| M | A | Absolute Bastion | 2400 | 60 dmg · 240 field · 70% slow · +30% damage taken · every 4 s: 1.5 s freeze | A near-permanent freeze zone. |
| 2 | B | Compression | 800 | +30 px shove | Harder throws. |
| 3 | B | Crush Plates | 1000 | +60 dmg | Every pulse crushes as it throws. |
| 4 | B | Event Rim | 1200 | shoves flyers too | Gravity reaches the air lane. |
| M | B | Orbital Vise | 2400 | 140 dmg · 220 field · 50% slow · every 5 s: 150 px shove and 0.8 s stun · shoves flyers | Throws everything, flyers included, and stuns it where it lands. |

## Sunforge
id: sunforge · recipe: laser, nova, cannon, cannon · layout: any
A solar furnace: a lance from the sky that scorches a stretch of lane and leaves it burning.

| Tier | Path | Name | Cost | Stats | Effect |
|---|---|---|---|---|---|
| 1 | base | Sunforge | 1700 | 180 dps · 260 range · ramps to 3× · the beam burns a 40 px strip of lane (60 burn/s for 4 s) | A focused solar beam that sets the lane under its target on fire. |
| 2 | A | Focusing Array | 1000 | ramps to 4× | A tighter focus. |
| 3 | A | Corona Lens | 1200 | +60 dps | Hotter at the core. |
| 4 | A | Heliostat | 1400 | +60 range | Tracking mirrors reach further. |
| M | A | Star Lance | 2800 | 320 dps · 330 range · ramps to 6× · the strip burns 100/s for 5 s | A beam that melts bosses and the lane beneath them. |
| 2 | B | Fuel Injection | 1000 | +30 burn/s | The fires burn hotter. |
| 3 | B | Wide Burn | 1200 | +20 px strip | A wider band of fire. |
| 4 | B | Firewall | 1400 | burning enemies are slowed 20% | The flames drag at everything crossing them. |
| M | B | Inferno Crown | 2800 | 220 dps · 280 range · burns a 70 px strip (140 burn/s for 6 s) · burning enemies take +20% damage | Turns a whole stretch of lane into a furnace. |

## Sky Fortress
id: sky_fortress · recipe: flak, flak, missile, missile · layout: pairs
An air-defence citadel: a flak curtain on the top row, a homing swarm launcher on the bottom.

| Tier | Path | Name | Cost | Stats | Effect |
|---|---|---|---|---|---|
| 1 | base | Sky Fortress | 1500 | 70 dmg · 300 range · 4.0/s · 80 burst · 6 missiles every 2 s (60 dmg, 3× vs flyers) · air only | Flak and missiles together: nothing crosses its sky for long. |
| 2 | A | Autoloaders | 800 | +1.0/s | Faster flak. |
| 3 | A | Wide Fuses | 1000 | +20 burst | Bigger airbursts. |
| 4 | A | Shrapnel Veil | 1200 | flyers hit are slowed 30% | Damaged flyers struggle to stay on course. |
| M | A | Iron Heaven | 2500 | 100 dmg · 340 range · 6.0/s · 110 burst · flyers hit take +25% damage | A curtain of flak that leaves flyers crippled. |
| 2 | B | Deep Racks | 800 | +3 missiles | Bigger salvos. |
| 3 | B | Seeker Heads | 1000 | missiles retarget | No missile wasted. |
| 4 | B | Ground Mode | 1200 | missiles hit ground enemies at 50% | The swarm also strikes the lane. |
| M | B | Starfall Battery | 2500 | 80 dmg · 320 range · 4.0/s · 14 missiles every 2 s (90 dmg, 3× vs flyers) · hits ground at 50% | A missile storm for sky and lane alike. |

## Null Spire
id: null_spire · recipe: nullifier, nullifier, sensor, amp · layout: any
A support spire that tears away every defence in a huge field and drives the towers around it harder.

| Tier | Path | Name | Cost | Stats | Effect |
|---|---|---|---|---|---|
| 1 | base | Null Spire | 1600 | 260 field · strips 60% of barriers every 2 s · exposes · reveals cloaked · +25% mark · towers within 180 px deal +25% damage | Strips, reveals and marks everything in a huge field, and boosts the towers around it. |
| 2 | A | Silence Coils | 900 | jams everything | Support enemies go quiet inside the field. |
| 3 | A | Dead Air | 1100 | suppresses non-bosses for 1 s every pulse | Enemy abilities cut out with every pulse. |
| 4 | A | Wide Null | 1300 | +40 field | A bigger dead zone. |
| M | A | Absolute Silence | 2500 | 320 field · strips all barriers · exposes · jams everything · suppresses everything (bosses at half) · +30% mark | Nothing uses an ability or keeps a barrier inside the field. |
| 2 | B | Fire Control | 900 | +10% tower damage | A stronger boost. |
| 3 | B | Rangefinders | 1100 | towers in range get +15% range | Boosted towers reach further. |
| 4 | B | Overclock Link | 1300 | towers in range get +15% speed | Boosted towers fire faster. |
| M | B | Command Spire | 2500 | 280 field · strips 60% of barriers · exposes · +30% mark · towers within 220 px get +40% damage, +25% range, +25% speed | The strongest support in the game. |

## Sentinel Spire
id: sentinel · recipe: arrow, arrow, sniper, sniper · layout: pairs
A precision hub: a rotary cannon that shreds armor, with a marksman rail on the bottom row.

| Tier | Path | Name | Cost | Stats | Effect |
|---|---|---|---|---|---|
| 1 | base | Sentinel Spire | 1500 | 40 dmg · 260 range · 6.0/s · shred 2 (max 16) · every 8th shot is a 300 dmg armor-piercing rail | Shreds armor fast, then finishes targets with a heavy rail. |
| 2 | A | Spin-Up | 800 | +2.0/s | Faster barrels. |
| 3 | A | Split Feed | 1000 | +1 target | Fires at two targets at once. |
| 4 | A | Heavy Rounds | 1200 | +10 dmg | Harder-hitting rounds. |
| M | A | Bullet Storm | 2400 | 60 dmg · 280 range · 10/s · 3 targets · shred 3 (max 24) | A wall of shredding fire across three targets. |
| 2 | B | Rail Rhythm | 800 | a rail every 6th shot | More rails. |
| 3 | B | Heavy Slugs | 1000 | +200 rail dmg | Much heavier rails. |
| 4 | B | Finisher | 1200 | rails execute non-bosses below 20% | A rail into a weakened enemy destroys it. |
| M | B | Judgement | 2400 | 50 dmg · 320 range · 6.0/s · every 4th shot is a 700 dmg rail · executes non-bosses below 25% · 3× vs bosses | A marksman hub that hunts bosses. |
