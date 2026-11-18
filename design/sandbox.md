# Bastion Line Sandbox (design)

A test bench for trying every tower and enemy without the economy, shields or progression getting in
the way. Confirmed with the owner in the design question rounds.

## Rules

- **Entry:** a Sandbox toggle on Map Select, beside the difficulty row. The difficulty still sets
  enemy HP and speed factors and the round count.
- **Resources:** credits and core shields are infinite and show as ∞. Leaks never end the run.
  Selling refunds 100%.
- **Placement and upgrades:** the normal rules apply (tiles, terrain sites, two branches at most, the
  secondary cap, mastery needing research), but upgrades are free. Each buyable branch card in the
  tower panel has a Max button that buys the branch as far as the rules allow.
- **Abilities:** Orbital Strike and Chrono Field have no cooldown.
- **Research:** an All / Mine / None switch in the Spawner applies at once and never touches the save. The Research
  Lab (R, beside the Spawner button) opens too and is the real Lab (owner, 2026-10-24, #87): buying or resetting spends
  and saves real research points, and switches the run to Mine.
- **Spawner** (key S, top-bar button; doesn't pause):
  - a grid of every enemy by role (rows) and tier (columns T1-T4), with the Specials and bosses in rows
    of their own; clicking one spawns it at base strength (round-1 scaling times the difficulty factor);
  - nine elite modifier toggles (enemy rework, issue #68): with any on, each spawn arrives as an elite
    carrying the toggled modifiers it can take; the ones it can't are named in a toast;
  - a count stepper (1 / 5 / 10 / 25); lanes alternate as in normal waves;
  - Call round N: sends that round's real composition and scaling, without changing the round
    counter;
  - Clear field: removes every enemy and pending spawn, with no bounty and no leak;
  - spawns and calls stack with whatever is on the field.
- **Wave builder** (#118; key V or the Spawner's header button; opens beside the Spawner and closes with it):
  - a wave is a list of up to 30 groups, in a scrolling list; each group is one enemy, a count (1-100), a gap between its
    enemies (0.1-5 s), a delay before the next group (0-30 s) and elite modifiers;
  - while it's open, clicking a Spawner card adds a group at the bottom (the Spawner's count; its toggled modifiers the
    enemy can take, shown as chips you click to drop) instead of spawning; a new group's gap is 0.4 s, its delay 1.0 s;
  - each row: up/down to reorder, the enemy's still icon, name and tier, -/+ steppers for count, gap and delay (Shift steps
    5x), copy and remove;
  - group i+1 starts when group i's last enemy has spawned, plus group i's delay; counts are single enemies (packs aren't
    multiplied); round-1 strength like the cards; lanes alternate;
  - the foot: the wave's groups, enemies and length (while a copy spawns, "Group 3 of 5, 14 to come"), then Send wave (stacks
    with the field; again while one spawns sends another copy), Loop (sends again once the last copy's enemies are all
    gone; with nothing running it sends at once; keeps going with the panels closed, a gold dot on the Spawner button),
    Stop wave (cancels the built copies' spawns still to come and turns Loop off) and Clear (empties the list);
  - Clear field also stops built waves and turns Loop off; the top bar's NEXT strip is unchanged;
  - the wave is saved to the profile on every edit and comes back in any Sandbox run (Loop starts off); groups whose enemy
    no longer exists are dropped. Only the last wave, no library.
- **Launch button:** next round works as normal. After the mode's final round, the run carries on
  with endless rules and no medal.
- **DPS meter:** the tower panel shows live DPS (last 5 s), total damage and kills. Sandbox only.
- **Progress:** none. No medals, records, research points, autosave or Continue save; a Sandbox run
  never overwrites an existing Continue save. The pause menu has no Save.
- **Label:** the top bar reads "<MAP> · SANDBOX".

## Out of scope

A Codex entry, the bot, the design pages, and the DPS meter in normal games.

## Open questions

None.
