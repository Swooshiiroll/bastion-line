# Bastion Line Air-Strike Abilities (design)

Two new player abilities, the **Strafing Run** (a fighter jet) and the **Carpet Bomb** (a bomber), joining today's
Orbital Strike and Chrono Field. This is a **draft for the owner to mark up**. The owner's decisions are listed as
such; every number and every point marked "proposed" is Claude's draft. No game code changes until the owner confirms
the spec (repo CLAUDE.md, "Designing a feature first"). Issue #57.

## Owner direction (2026-10-14)

- **Join, not replace:** four abilities in all: Orbital Strike, Chrono Field, Strafing Run, Carpet Bomb.
- **Aiming, both strikes:** **click the start, drag the direction.** The aircraft flies that line.
- **What they hit:** the **jet hits air and ground**; the **bombs hit ground only** (flyers fly over the blasts).
- **Jobs:** the **Strafing Run is a precise line**: a narrow line of rapid hits, good against a column of enemies or fast
  ones. The **Carpet Bomb is a wide area**: a long, wide strip of heavy blasts, good against packed waves. The Orbital
  Strike stays the single-spot burst.
- **Unlock:** **by research** (Research Lab nodes).
- **Keys:** decided in a later UI round.
- **Tracking:** its own issue (#57) and spec, separate from the tower rework (#55).

## What exists today

- `data/abilities.gd`: `ORDER := ["meteor", "warp"]`.
  - **Orbital Strike (`meteor`):** `Q` then click; 110 damage that ignores armour and hits flyers, 85 px radius, after
    0.9 s, every 45 s. The damage scales with `Waves.hp_scale(wave)`, so it stays useful late.
  - **Chrono Field (`warp`):** `W`; slows every enemy 60% for 5 s (bosses resist half), every 70 s.
- **Casting and cooldowns:** abilities recharge and can be cast only while a round is running.
  - `Game.cast_meteor` and `cast_warp`; cooldowns in `Game.ability_cd`, ticked in `_update_abilities`.
  - `ability_block_reason` explains why one can't be cast.
- **Research:** the Command tree's **Orbital Uplink** makes abilities recharge 20% faster (`ability_cd` run mod).
- **Elsewhere:**
  - **HUD:** buttons at the bottom-left, one per entry in `ORDER` (`BottomBar`).
  - **Targeting:** a hint and a guide beam (`BottomBar`, `FxLayer`).
  - **Bot:** casts both (`Bot.gd`).
  - **Saves:** store `ability_cd`.
  - **Codex:** an entry (`glossary.gd`, `Lore.gd`).
  - **Sandbox:** no cooldowns.
  - **Tests:** `test_abilities`.

## The two abilities (draft)

### Strafing Run (fighter jet)

- **Cast:** press its key, then **click the start point and drag** to set the heading (the press, then the release).
  - **Preview:** while dragging, the strafe line shows on the map, with its full length and width.
  - **Cancel:** right-click or Esc.
- **Line (proposed):** a fixed **560 px long, 28 px wide** strip starting at the click, in the dragged direction. The drag
  sets only the direction, not the length.
- **The run (proposed):**
  - The jet streaks in from off-screen along the line, 0.6 s after casting.
  - It fires a stream of rounds down the line over about 1 s, sweeping start to end.
  - Every enemy under the line when the sweep passes takes **6 hits of 22 damage (132 total)**.
- **Hits:** air and ground (owner).
- **Armour (proposed):** **applies to each hit** (machine-gun rounds), unlike the Orbital Strike. Many small hits make it
  weaker against Tanks, which keeps it the "fast enemies and columns" tool.
- **Scaling:** damage × `Waves.hp_scale(wave)`, like the Orbital Strike.
- **Cooldown (proposed):** **30 s**, the shortest of the four.
- **Look:** a sleek delta-wing fighter silhouette with a shadow and a muzzle flash. Tracer lines and impact sparks walk
  along the strip, and the jet roars past.

### Carpet Bomb (bomber)

- **Cast:** the same click-and-drag as the Strafing Run, with a wider preview strip.
- **Line (proposed):** a fixed **640 px long** line; bombs land along it.
- **The run (proposed):**
  - The bomber flies in along the line, 1.5 s after casting (it's slower).
  - It drops **10 bombs**, evenly spaced, landing one after another along the line.
  - Each bomb blasts **70 px** for **100 damage**, so the strip covered is about 140 px wide.
- **Hits:** ground only (owner). Flyers are untouched.
- **Armour (proposed):** **applies**, but each blast is one big hit, so armour matters less than for the jet.
- **Scaling:** × `Waves.hp_scale(wave)`.
- **Cooldown (proposed):** **90 s**, the longest of the four.
- **Look:** a heavy four-engine bomber, slower, with a big shadow. Bomb-bay doors open, and the bombs drop and burst in
  sequence (the ground shakes if screen shake is on).

### How the four compare (proposed)

| Ability | Shape | Hits | Damage | Armour | Delay | Cooldown |
|---|---|---|---|---|---|---|
| Orbital Strike | One spot, 85 px radius | Air + ground | 110, one hit | Ignored | 0.9 s | 45 s |
| Chrono Field | Whole map | Air + ground | Slow 60% for 5 s | n/a | Instant | 70 s |
| Strafing Run | Line 560 × 28 px | Air + ground | 6 × 22 | Per hit | 0.6 s | 30 s |
| Carpet Bomb | Line 640 px, 10 × 70 px blasts | Ground | 100 per blast | Per blast | 1.5 s | 90 s |

All damage scales with the round, like today's Orbital Strike.

## Interactions (proposed unless marked)

- **Research (owner: unlocked by research):** two new nodes, **Air Support: Strafing Run** and **Air Support: Carpet
  Bomb**, probably in the Command tree near Orbital Uplink. The Research Lab is due to be reworked separately (after the
  tower roster), so where exactly they go, and their RP cost, are open.
  - **Proposed:** Orbital Uplink's −20% cooldown applies to all four.
- **Before they're researched,** their HUD buttons show locked, with "Research Air Support in the lab".
- **Cloaked and burrowed enemies:**
  - Under the enemy spec's rule, area damage briefly reveals Phantoms and Wraiths. Proposed: the jet's line and the
    bombs count as area damage.
  - Burrowed Burrowers are untouched.
- **The Wraith** (immune to physical damage, in the enemy spec): both strikes are physical (bullets, bombs), so it takes
  nothing. This ties to the open physical/energy question.
- **Bosses:** full damage, no special rule.
- **Sandbox:** no cooldowns, like today.
- **The bot:** casts the Strafing Run along the lane segment with the most enemies, and the Carpet Bomb on the densest
  ground pack. The balance probe should run with and without them.
- **Saves:** `ability_cd` gains two keys. Old saves load them as 0 (ready), since the loader already defaults missing
  keys, so no format bump is needed. Unlocks come from the run's research snapshot, as today.
- **Codex:** the abilities entry grows to cover all four.

## UI and controls (open; owner: keys decided later)

- **Keys:** to decide. Options: Q W E R for the four (moving the tree off E and research off R); or new free keys; or
  number keys.
- **HUD:** four ability buttons at the bottom-left instead of two, with locked states.
- **Aiming feedback:** the strip preview while dragging. The bottom bar hint reads "Click the start, drag the direction.
  Right-click or Esc cancels."

## Edge cases

- A drag shorter than a few pixels uses a default direction (along the track at that point, proposed), or cancels.
- Lines that run off the map: only the part over the field matters.
- Lines that cross several lanes: they hit every lane under them. That's a reward for good aim.
- Casting between rounds is blocked, as today.
- The strike in flight when the round ends: it still resolves.

## Balance targets (open)

- The Strafing Run should clear a column of light Rushers or a Swarm stream, but not dent a Tank.
- The Carpet Bomb should break a packed ground wave, and be the biggest burst in the game when it lands well.
- Check with the bot probe: win rates and round lengths with all four abilities against the current two.

## Scope

- **In:** the two abilities, their research unlock, their HUD, aiming, visuals, bot use, Codex and tests.
- **Out:** reworking the Orbital Strike and Chrono Field; the Research Lab rework (separate); the keys (a later UI
  round).

## Open questions

1. **Numbers:** line lengths and widths, damage, delays and cooldowns (all proposed above).
2. **Armour:** per hit (proposed), or ignored like the Orbital Strike?
3. **Drag:** does it set only the direction (proposed), or the length too, up to a maximum?
4. **Research:** which tree and nodes, what RP cost, and should Orbital Uplink cover all four?
5. **Keys** (later UI round).
6. **The Wraith:** both strikes are physical, so it's immune to them. OK, or should one of them count as energy?
7. **Do the strikes reveal cloaked enemies** as area damage (proposed: yes)?
8. **Look:** jet and bomber designs, in the enemy-art style of mockup pages with options?
