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
- **Research:** an All / Mine / None switch in the Spawner applies at once. The save is never touched,
  and the Research Lab button is disabled.
- **Spawner** (key S, top-bar button; doesn't pause):
  - a grid of every enemy, bosses grouped; clicking one spawns it at base strength (round-1 scaling
    times the difficulty factor);
  - a count stepper (1 / 5 / 10 / 25); lanes alternate as in normal waves;
  - Call round N: sends that round's real composition and scaling, without changing the round
    counter;
  - Clear field: removes every enemy and pending spawn, with no bounty and no leak;
  - spawns and calls stack with whatever is on the field.
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
