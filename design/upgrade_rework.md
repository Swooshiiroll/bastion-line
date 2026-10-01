# Upgrade rework: tower panel, view-only tree, upgrade preview (v3.6)

Issue #1. Spec from the design questions on 2026-10-01. It replaces the original "preview pop-out"
idea with a wider rework of how upgrades are bought and browsed.

## What changes, in one line each

- **Buying moves to a tower panel.** Clicking a tower opens a side panel in the shop's slot on the
  right, with the tower's combat stats and the next upgrade on each branch as cards to buy.
- **The upgrade tree is view-only.** It's for reading and planning: hover a node for details, click
  one to watch a live preview of it. Nothing is bought there.
- **The bottom bar loses its upgrade buttons.** Everything else on it stays.

## 1. Tower panel (new; replaces the shop's slot)

**Opening and closing**
- **Opens** when a tower is selected: by click, or by anything else that selects it.
- **Replaces the shop** if the shop is open.
- **Follows the selection:** clicking another tower switches the panel to it.
- **Stays open after buying**, showing the next cards, so several upgrades can be bought in a row.
- **Closes** when the tower is deselected: click empty ground, right-click or Esc. Selling closes it
  too, since the tower is gone.
- **B (shop) while it's open** deselects the tower and opens the shop in the same slot.
- **Same frame as the shop:** a 302×760 holo panel at (1290, 44) that slides in from the right.

**Contents, top to bottom**
1. **Header:** the tower's name and colour, which stay stock until its primary locks in, as now; its
   level in the trunk/branch scheme (Stock, Retrofit, A · T2...).
2. **Current combat stats:** the same rows the tower card uses (`TowerInfo.rows_for`). These are
   damage, range, fire rate and the tower's special stats: slow, shred, chain, burn and so on.
3. **Upgrade cards:** the next step on each branch the tower can take, in branch order A, B, C.
   - **Before the Retrofit**, there's one card: the Retrofit.
   - **Each card shows:**
     - the branch colour bar;
     - the upgrade's name and cost;
     - the hotkey (U, I or O);
     - the stat changes before → after (`TowerInfo.stats_grid`);
     - the one-sentence description.
   - **Buying:** click the card or press its key. The card shows how the price was arrived at
     (difficulty price, research discount, Supply Depot) the way the buttons do today.
   - **Cards that can't be bought** stay visible but dimmed, with the reason:
     - "Need N more credits";
     - "Needs <Tower> Mastery research";
     - "Secondary capped at 2 upgrades";
     - "Branch locked (two branches started)".

     A branch that's finished (mastery owned) shows a "Mastered" card.
   - Hovering a card highlights the matching node if the tree is open.
4. **"View upgrade tree [E]" button**, at the bottom.

Not in the panel: targeting (T), air/ground priority (G), sell (X) and boosts. They stay on the
bottom bar.

## 2. Bottom bar

When a tower is selected, the bar shows the same card as today **minus the upgrade buttons**:
identity, path strip, stats, boosts as percentages, and the Tree, Target, Priority and Sell
controls. The U, I and O keys still buy. The cards in the tower panel show those keys, so it's
clear what they do.

## 3. Upgrade tree (view-only)

**Opening:** E (unchanged), the panel's "View upgrade tree" button, or double-clicking the tower (unchanged). Esc
closes it, as today. **The battle keeps running** while it's open.

**Layout:** the window grows (from 1100×580 now) to fit the tree across the top and a full-width
strip underneath:
- **Preview (left of the strip):** the selected node's live preview, a wide scene.
- **Details (right of the strip):** the node's name, branch and tier, cost, description, and stat
  changes before → after.

*The owner wants to be able to revisit this layout. The alternatives considered were:*
- *today's window, with the tree on top and preview + details below;*
- *the tree on the left two-thirds, with a tall preview + details column on the right.*

**Nodes:**
- **Hover** a node: the details strip shows it, as today, with no buy button.
- **Click** a node: it's selected (outlined), its preview plays, and the details stay on it until
  another node is clicked. Selecting starts on the tower's next upgrade on its primary, or on the
  Retrofit.
- **Reachable nodes only** get a preview. These are nodes this tower could still get on its
  current path, including masteries whose research isn't done yet.
- **Blocked nodes** show their details and a note instead of the preview. These are the third
  branch once two are started, and secondary steps beyond the cap of 2.
- Node states (owned, next, blocked, locked) look the same as today.

## 4. The preview

A small simulation of the selected upgrade, **with the upgrade only** (no before/after split).

**The scene**
- A short straight lane in the **current sector's look**: its floor, lane edge colours and props.
- The tower stands beside the lane at that node's state. That means everything the tower would own
  on the way to it on this path, with the same composed stats the game uses (`Tower.lines`).
- The scene runs a real sandbox `Game` on its own, separate from the battle, and is drawn by the
  same World view. Rendered through a SubViewport, so it needs no new art.

**The loop**
- A **short looping wave**: a small group of about 6-8 s walks the lane and gets shot, then the
  wave restarts. The tower keeps its state: aim, charge, drones.
- **Effects:** the game's normal damage numbers and effects only, with no extra readout.

**The enemies** are picked automatically from the upgrade's effects, so each preview shows what the
upgrade is for:

| The upgrade has | Preview enemies |
|---|---|
| shred, armor break, armor piercing | armored ground (Siege Mech, Rampart) |
| anti-air, flyer bonus | flyers (Strike Drone, Gunship) |
| splash, chain, cone, pierce, burn pools | a clump of small ground units (Skitter, Nanite) |
| slow, stun, shove, pull | fast runners (Drone, Skitter) |
| execute, boss bonus | one tough boss-class unit with an HP bar |
| reveal, mark, disrupt | cloaked Phantoms (or Burrowers for disrupt) |
| barrier bonus, barrier strip | barrier units (Aegis Walker) |
| support (pylons, Scrapyard) | the tower boosts a plain Pulse Turret next to it, against a standard group |
| anything else | a standard mixed group: Drones and a Skitter, plus a flyer if the tower hits air |

When an upgrade has several effects, the first matching row wins, in table order. The rules live
in code next to the other upgrade data, with a test that every reachable node of every tower gets
a non-empty enemy set.

## 5. Keys and controls

| Input | Action |
|---|---|
| Click a tower | Select it and open its tower panel |
| U / I / O | Buy the next upgrade on branch A / B / C (unchanged) |
| E / double-click a tower | Open or close the upgrade tree for the selected tower (unchanged) |
| B | Open the shop; with a tower selected, deselect it first |
| Esc / right-click / click ground | Close the tree if open, else deselect (which closes the panel) |
| Click a tree node | Select it and play its preview |

## 6. Acceptance (what the tests and the tour check)

**Tests (`tests/TestRunner.gd`)**
- **Cards:**
  - the panel's cards match `Tower` buy rules for every state: trunk, before primary, after
    primary, capped secondary, locked branch, mastery without research, mastered;
  - every unavailable reason appears where it should.
- **Previewable nodes:** the "reachable" set is right for each of those states.
- **Preview enemies:** every reachable node of every tower gets a non-empty enemy set.
- **Preview sandbox:**
  - it builds the tower at a node's state with the same stats as buying up to it in a real game;
  - it is separate: previewing doesn't change the real game state, credits or the RNG (the save
    round-trip and determinism tests still pass).

**Screenshot tour (`tools/ScreenshotTour.gd`), via real input**
- Clicking a tower opens its panel. Clicking a card buys it, and the panel updates.
- B swaps to the shop. Esc and deselecting close the panel.
- E opens the tree. A node click plays its preview.
- Shots: the panel, a dimmed card with its reason, the tree with a preview playing.

**Performance:** the perf budget still passes. The preview's scene isn't part of the battlefield
and only renders while the tree is open.

## Open questions

- None blocking. Double-click still opens the tree (decided 2026-10-01).
- **Tree layout:** the bigger window with a full-width preview strip, for now (see §3).
