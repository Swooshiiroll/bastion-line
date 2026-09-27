// Builds the printable Bastion Line codex: every enemy, every tower and every upgrade tree.
//   1. godot --path . -- --codex=<project>\design\codex     (data + sprites from the game)
//   2. node tools/codex.mjs                                 (writes design/codex/codex.html)
//   3. msedge --headless --print-to-pdf=... design/codex/codex.html
// Tower trees come from design/upgrade_trees.md (the source the game data is generated from);
// enemy stats and round scaling come from the game via codex.json.
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const outDir = join(root, "design", "codex");
const data = JSON.parse(readFileSync(join(outDir, "codex.json"), "utf8"));
const md = readFileSync(join(root, "design", "upgrade_trees.md"), "utf8").replace(/\r\n/g, "\n");

const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
const code = (s) => esc(s).replace(/`([^`]+)`/g, "<code>$1</code>");
const num = (n) => Number(n).toLocaleString("en-US");

// --- Parse the tower sections of the design file ------------------------------------------------
const sections = md.split(/^## /m).slice(1).map((s) => {
  const lines = s.split("\n");
  return { title: lines[0].trim(), lines: lines.slice(1) };
});
const trees = {};
for (const sec of sections) {
  const metaLine = sec.lines.find((l) => l.startsWith("id: "));
  if (!metaLine) continue;
  const meta = Object.fromEntries(metaLine.split(" · ").map((p) => {
    const i = p.indexOf(": ");
    return [p.slice(0, i), p.slice(i + 2)];
  }));
  const role = sec.lines.find((l, i) => i > sec.lines.indexOf(metaLine) && l.trim() && !l.startsWith("|")) || "";
  const rows = sec.lines.filter((l) => /^\| *(1|2|3|4|5|6|M) *\|/.test(l)).map((l) => {
    const c = l.split("|").slice(1, -1).map((x) => x.trim());
    return { tier: c[0], path: c[1], name: c[2], cost: +c[3], stats: c[4], effect: c[5] };
  });
  trees[meta.id] = { name: sec.title, meta, role: role.trim(), rows };
}

// Combination notes keyed by tower name (continuation lines are folded into the bullet before).
const comboText = {};
{
  const raw = sections.find((s) => s.title === "Combinations")?.lines || [];
  const bullets = [];
  for (const l of raw) {
    if (l.startsWith("- ")) bullets.push(l.slice(2));
    else if (/^\s{2,}\S/.test(l) && bullets.length) bullets[bullets.length - 1] += " " + l.trim();
  }
  for (const b of bullets) {
    const m = b.match(/^([^:]+): (.*)$/);
    if (m && Object.values(trees).some((t) => t.name === m[1])) comboText[m[1]] = m[2];
  }
}

// --- Enemy details -------------------------------------------------------------------------------
const enemyName = Object.fromEntries(data.enemies.map((e) => [e.id, e.name]));
const plural = (n, s) => `${n} ${s}${n === 1 ? "" : "s"}`;
function abilities(e) {
  const out = [];
  const pct = (v) => `${Math.round(v * 100)}%`;
  if (e.flying) out.push("Flies straight at the core on the air lane, ignoring the ground route. Only towers that hit air can hit it.");
  if (e.cloaked) out.push("Cloaked: towers can only target it inside a Sensor Array field, or briefly after area damage reveals it.");
  if (e.shield) out.push(`Energy barrier of ${e.shield} that absorbs damage before the hull (armor doesn't apply to it) and recharges after ${e.shield_delay} s without damage.`);
  if (e.heal_pct) out.push(`Repairs ${pct(e.heal_pct)} of max health to non-boss enemies within ${e.heal_radius} px every ${e.heal_interval} s.`);
  if (e.split_type) out.push(`Splits into ${e.split_count} ${enemyName[e.split_type]}s when destroyed.`);
  if (e.emp_radius) out.push(`EMP burst every ${e.emp_interval} s knocks towers within ${e.emp_radius} px offline for ${e.emp_duration} s.`);
  if (e.burrow_interval) out.push(`Burrows for ${e.burrow_time} s every ${e.burrow_interval} s: can't be targeted or hurt, and lane hazards don't touch it.`);
  if (e.blink_interval) out.push(`Teleports ${e.blink_distance} px down the lane every ${e.blink_interval} s. A slow or stun resets the charge.`);
  if (e.regen_pct) out.push(`Regenerates ${pct(e.regen_pct)} of max health per second after ${e.regen_delay} s without taking damage.`);
  if (e.aura_radius) out.push(`Other non-boss enemies within ${e.aura_radius} px move ${pct(e.aura_haste)} faster.`);
  if (e.grant_interval) out.push(`Every ${e.grant_interval} s gives enemies within ${e.grant_radius} px (not itself) a barrier worth ${pct(e.grant_pct)} of their max health.`);
  if (e.spawn_type) out.push(`${e.flying ? "Launches" : "Spawns"} ${plural(e.spawn_count, enemyName[e.spawn_type])} every ${e.spawn_interval} s.`);
  if (e.phases) out.push(`At ${e.phases.map(pct).join(" and ")} health it sheds ${e.phase_armor} armor, speeds up ×${e.phase_speed} and drops ${e.phase_spawn_count} ${enemyName[e.phase_spawn]}s.`);
  if (e.cc_immune) out.push("Immune to slows, stuns and shoves.");
  if (e.stun_immune) out.push("Can't be stunned.");
  if (e.slow_resist) out.push(`Resists ${pct(e.slow_resist)} of every slow.`);
  if (e.boss) out.push("Boss: crowd control is weaker against it (stuns last about a third as long, shoves a quarter as far).");
  return out;
}
const hitters = (flying) => data.towers.filter((t) => !t.support && (flying ? t.air : t.ground)).map((t) => t.name);

function enemyCard(e) {
  const cls = e.boss ? (e.flying ? "Flying boss" : "Boss") : e.flying ? "Flyer" : "Ground";
  const ab = abilities(e);
  const rounds = data.sample_rounds.filter((r) => r !== 1);
  return `
  <div class="ecard" style="--acc:#${e.color}">
    <div class="ehead">
      <img src="icons/e_${e.id}.png">
      <div>
        <div class="ename">${esc(e.name)}</div>
        <div class="etag">${cls} · first seen round ${e.first_round}</div>
        <p class="eblurb">${esc(e.blurb)}</p>
      </div>
    </div>
    <table class="kv">
      <tr><th>Health</th><td>${num(e.hp)}</td><th>Speed</th><td>${e.speed} px/s</td><th>Armor</th><td>${e.armor}</td></tr>
      <tr><th>Credits</th><td>${e.bounty}</td><th>Leak cost</th><td>${plural(e.lives, "shield")}</td><th>Size</th><td>${e.radius} px</td></tr>
    </table>
    ${ab.length ? `<ul class="ab">${ab.map((a) => `<li>${esc(a)}</li>`).join("")}</ul>` : ""}
    <table class="scale">
      <tr><th>Round</th>${rounds.map((r) => `<td>${r}</td>`).join("")}</tr>
      <tr><th>Health</th>${rounds.map((r) => `<td>${num(e.hp_by_round[r])}</td>`).join("")}</tr>
      <tr><th>Credits</th>${rounds.map((r) => `<td>${e.bounty_by_round[r]}</td>`).join("")}</tr>
    </table>
  </div>`;
}

// --- Tower pages ---------------------------------------------------------------------------------
const STEP = { 3: "T1 · Specialization", 4: "T2", 5: "T3", 6: "T4", M: "Mastery" };
const TRUNK = { 1: "Stock", 2: "Retrofit" };
function towerPage(t) {
  const tr = trees[t.id];
  const trunk = tr.rows.filter((r) => r.path === "base");
  const trunkCost = trunk.reduce((a, r) => a + r.cost, 0);
  const attack = (tr.meta.attack || "").split(",").map((s) => s.trim());
  const reach = t.economy ? "Economy (never attacks)" : t.support ? "Support" : !t.ground ? "Air only" : t.air ? "Air and ground" : "Ground only";
  const branches = ["A", "B", "C"].map((letter, i) => {
    const rows = tr.rows.filter((r) => r.path === letter);
    const spec = rows[0];
    const br = t.branches[i];
    const total = rows.reduce((a, r) => a + r.cost, 0);
    const toSecondary = rows.slice(0, 2).reduce((a, r) => a + r.cost, 0);
    return `
    <div class="branch" style="--bc:#${br.color}">
      <div class="bhead">
        <img src="icons/t_${t.id}_${br.id}.png"><img src="icons/t_${t.id}_${br.id}_m.png">
        <div>
          <div class="bname"><span class="bl">${letter}</span>${esc(spec.name)} → ${esc(rows[rows.length - 1].name)}</div>
          <div class="bmeta">Key <code>${["U", "I", "O"][i]}</code> · whole branch ${num(total)} cr (${num(total + trunkCost)} cr from a new tower) · as a secondary (2 upgrades) ${num(toSecondary)} cr${attack.includes(letter) ? " · <b>changes the attack</b>: as a secondary it adds its attack alongside the primary's" : ""}</div>
        </div>
      </div>
      <table class="nodes">
        ${rows.map((r) => `<tr class="${r.tier === "M" ? "mast" : r.tier === "3" ? "spec" : ""}"><td class="st">${STEP[r.tier]}</td><td class="nm">${esc(r.name)}</td><td class="cs">${num(r.cost)}</td><td class="sx">${esc(r.stats)}</td><td class="fx">${esc(r.effect)}</td></tr>`).join("")}
      </table>
    </div>`;
  }).join("");
  return `
  <section class="tower" style="--acc:#${t.color}">
    <div class="thead">
      <img src="icons/t_${t.id}_1.png"><img src="icons/t_${t.id}_2.png">
      <div>
        <h2>${esc(t.name)}</h2>
        <div class="tmeta">Build key <code>${esc(t.key)}</code> · ${num(trunk[0].cost)} cr · ${reach}${t.size > 1 ? " · takes 2×2 tiles" : ""}</div>
        <p class="role">${esc(tr.role)}</p>
      </div>
    </div>
    <table class="nodes trunk">
      ${trunk.map((r) => `<tr><td class="st">${TRUNK[r.tier]}</td><td class="nm">${esc(r.name)}</td><td class="cs">${num(r.cost)}</td><td class="sx">${esc(r.stats)}</td><td class="fx">${esc(r.effect)}</td></tr>`).join("")}
    </table>
    ${branches}
    ${comboText[t.name] ? `<p class="combo"><b>Combinations:</b> ${esc(comboText[t.name])}</p>` : ""}
  </section>`;
}

// --- Document ------------------------------------------------------------------------------------
const regulars = data.enemies.filter((e) => !e.boss);
const bosses = data.enemies.filter((e) => e.boss);
const modeRows = data.modes.map((m) => `<tr><td><span class="dot" style="background:#${m.color}"></span>${m.name}</td><td>${m.rounds}</td><td>${m.lives}</td><td>×${m.price.toFixed(1)}</td><td>${m.medal_rp}</td></tr>`).join("");
const towerIndex = data.towers.map((t) => {
  const tr = trees[t.id];
  const specs = ["A", "B", "C"].map((l) => tr.rows.find((r) => r.path === l && r.tier === "3").name);
  return `<tr><td><img class="mini" src="icons/t_${t.id}_1.png">${esc(t.name)}</td><td><code>${esc(t.key)}</code></td><td>${tr.rows[0].cost}</td><td>${t.economy ? "Economy" : t.support ? "Support" : !t.ground ? "Air" : t.air ? "Air + ground" : "Ground"}</td><td>${specs.map(esc).join(" · ")}</td></tr>`;
}).join("");
const enemyIndex = data.enemies.map((e) => `<tr><td><img class="mini" src="icons/e_${e.id}.png">${esc(e.name)}</td><td>${e.boss ? "Boss" : e.flying ? "Flyer" : "Ground"}</td><td>${e.first_round}</td><td>${num(e.hp)}</td><td>${e.speed}</td><td>${e.armor}</td><td>${e.lives}</td></tr>`).join("");
const today = new Date().toISOString().slice(0, 10);

const html = `<!doctype html>
<html><head><meta charset="utf-8"><title>Bastion Line Codex</title>
<style>
@page { size: Letter; margin: 0.45in 0.45in 0.5in; }
* { box-sizing: border-box; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
body { font-family: "Segoe UI", sans-serif; font-size: 8.6pt; color: #1b2330; margin: 0; line-height: 1.35; }
h1, h2, h3, .ename, .bname, .cover-title { font-family: Bahnschrift, "Segoe UI", sans-serif; }
code { font-family: Consolas, monospace; background: #eef1f5; padding: 0 3px; border-radius: 3px; font-size: 0.95em; }
.cover { height: 9.9in; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center;
  background: #0b0f15; color: #dfe8f2; border-radius: 10px; page-break-after: always; }
.cover-title { font-size: 44pt; letter-spacing: 0.08em; color: #5fd3f3; }
.cover-sub { font-size: 14pt; margin-top: 6px; color: #9fb3c8; }
.cover-strip { display: flex; gap: 8px; margin: 34px 0 20px; }
.cover-strip img { width: 70px; height: 70px; border-radius: 8px; }
.cover-meta { font-size: 10pt; color: #7f93a8; }
h1 { font-size: 20pt; margin: 0 0 8px; color: #0e5f78; border-bottom: 2px solid #0e5f78; padding-bottom: 3px; page-break-after: avoid; }
h3 { font-size: 11.5pt; margin: 12px 0 4px; color: #0e5f78; }
.chapter { page-break-before: always; }
p { margin: 4px 0; }
ul { margin: 4px 0; padding-left: 16px; }
table { border-collapse: collapse; width: 100%; }
.grid th, .grid td { border-bottom: 1px solid #d9dee5; padding: 3px 5px; text-align: left; vertical-align: middle; }
.grid th { background: #e8edf3; font-weight: 600; }
.mini { width: 20px; height: 20px; border-radius: 3px; vertical-align: middle; margin-right: 6px; }
.dot { display: inline-block; width: 9px; height: 9px; border-radius: 50%; margin-right: 6px; }
.two { columns: 2; column-gap: 18px; }
.two > * { break-inside: avoid; }
.ecards { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.ecard { border: 1px solid #cfd6df; border-left: 4px solid var(--acc); border-radius: 6px; padding: 7px 8px; break-inside: avoid; }
.ehead { display: flex; gap: 8px; }
.ehead img { width: 78px; height: 78px; border-radius: 6px; flex: none; }
.ename { font-size: 13pt; font-weight: 600; }
.etag { color: #5b6878; font-size: 8pt; }
.eblurb { font-style: italic; color: #333d4a; }
.kv { margin: 5px 0 3px; }
.kv th { text-align: left; color: #5b6878; font-weight: 600; padding: 1px 4px 1px 0; width: 14%; }
.kv td { padding: 1px 8px 1px 0; }
.ab { font-size: 8.1pt; }
.scale { font-size: 7.6pt; margin-top: 4px; }
.scale th { text-align: left; color: #5b6878; padding: 1px 4px 1px 0; font-weight: 600; }
.scale td { text-align: right; padding: 1px 3px; border-left: 1px solid #e3e7ec; }
.tower { page-break-before: always; }
.thead { display: flex; gap: 8px; align-items: center; border-bottom: 3px solid var(--acc); padding-bottom: 6px; margin-bottom: 6px; }
.thead img { width: 84px; height: 84px; border-radius: 8px; }
.thead h2 { margin: 0; font-size: 20pt; }
.tmeta { color: #5b6878; font-size: 9pt; }
.role { margin: 3px 0 0; }
.nodes td { border-bottom: 1px solid #e1e5ea; padding: 2.5px 4px; vertical-align: top; }
.nodes .st { width: 13%; color: #5b6878; font-size: 7.8pt; }
.nodes .nm { width: 15%; font-weight: 600; }
.nodes .cs { width: 6%; text-align: right; padding-right: 8px; white-space: nowrap; }
.nodes .sx { width: 29%; font-family: Consolas, monospace; font-size: 7.6pt; color: #26303c; }
.nodes .fx { color: #333d4a; }
.nodes tr.spec td { background: #f3f7fb; }
.nodes tr.mast td { background: #fbf6e8; }
.nodes tr.mast .st { color: #9a6c00; font-weight: 600; }
.trunk { margin-bottom: 6px; }
.branch { border: 1px solid #d3d9e1; border-top: 3px solid var(--bc); border-radius: 6px; padding: 5px 6px 3px; margin: 7px 0; break-inside: avoid; }
.bhead { display: flex; gap: 6px; align-items: center; margin-bottom: 3px; }
.bhead img { width: 46px; height: 46px; border-radius: 5px; }
.bname { font-size: 11.5pt; font-weight: 600; }
.bl { display: inline-block; background: var(--bc); color: #0b0f15; border-radius: 4px; padding: 0 6px; margin-right: 7px; font-size: 10pt; }
.bmeta { color: #5b6878; font-size: 7.8pt; }
.combo { background: #eef4f8; border-radius: 5px; padding: 5px 8px; margin-top: 6px; }
.note { color: #5b6878; font-size: 8pt; }
</style></head><body>

<div class="cover">
  <div class="cover-title">BASTION LINE</div>
  <div class="cover-sub">Field Codex · enemies, towers and upgrade trees</div>
  <div class="cover-strip">${["arrow", "tesla", "laser", "nullifier", "nova", "drones"].map((id) => `<img src="icons/t_${id}_2.png">`).join("")}</div>
  <div class="cover-strip">${["grunt", "phantom", "aegis", "rampart", "leviathan", "colossus"].map((id) => `<img src="icons/e_${id}.png">`).join("")}</div>
  <div class="cover-meta">Game v3.1 · ${data.towers.length} towers · ${data.enemies.length} enemies · generated ${today} from the game's own data</div>
</div>

<h1>How to read this codex</h1>
<div class="two">
<div>
<h3>Upgrade trees</h3>
<ul>
<li><b>Trunk:</b> every tower is built as its <b>Stock</b> model and upgraded once to its <b>Retrofit</b>.</li>
<li><b>Three branches (A, B, C)</b> open at the Retrofit. Each runs <b>T1 to T4</b>: T1 is the <b>specialization</b> (it changes how the tower works), three more upgrades, then a <b>mastery</b>. <code>U</code>, <code>I</code> and <code>O</code> buy the next upgrade on A, B and C; <code>E</code> opens the tree.</li>
<li><b>Primary and secondary:</b> you can climb two branches freely, up to two upgrades on each. The first to get its <b>third</b> upgrade becomes the primary and can go on to its mastery; the other is capped where it is. The third branch locks as soon as two are started.</li>
<li><b>A secondary keeps its full effects,</b> downsides included: its upgrades add their differences on top of the primary. A branch marked <b>changes the attack</b> adds its attack alongside the primary's instead (see each tower's Combinations note).</li>
<li><b>Masteries</b> need that tower's Mastery research in the Research Lab, which needs the rest of its tree first; one node unlocks all three.</li>
<li>A tower keeps its stock name and colour until its primary locks in at T3. Towers that hit air and ground can be set to prefer one (<code>G</code>). The Scrapyard and Drone Bay take 2×2 tiles.</li>
</ul>
<h3>Reading the upgrade tables</h3>
<ul>
<li>The <b>specialization</b> and <b>mastery</b> rows list the tower's full stats at that point.</li>
<li>Upgrades 2-4 list what they add or change (<code>+3 dmg</code>, <code>+0.4/s</code>).</li>
<li><b>Costs</b> are base prices in credits. Harder modes multiply every build and upgrade price (table on the right).</li>
<li><b>Scrapyard</b> stats: <code>cr per round</code> is paid at each round clear and grows with the round like kill credits; <code>kill credits</code> and <code>off upgrades</code> apply inside its field and don't stack between Scrapyards.</li>
<li>Stat terms: <code>dmg</code> per hit (per flechette with <code>× n</code>), <code>dps</code> damage per second for beams, <code>/s</code> attacks per second, <code>range</code>/<code>field</code>/<code>radius</code> in pixels (a tile is 48 px).</li>
</ul>
</div>
<div>
<h3>Difficulty modes</h3>
<table class="grid"><tr><th>Mode</th><th>Rounds</th><th>Shields</th><th>Tower prices</th><th>Medal RP</th></tr>${modeRows}</table>
<p class="note">Every run starts with 300 credits. Clearing a mode's last round earns the sector's medal for that mode, and endless mode begins straight away.</p>
<h3>Enemy scaling</h3>
<ul>
<li><b>Health</b> grows every round (about ×7 by round 40), then also compounds ${Math.round(data.late_growth * 100)}% per round from round ${data.late_start}. Each enemy card lists its health at sample rounds.</li>
<li><b>Speed</b> grows 0.45% per round, up to +50% (bosses up to +25%).</li>
<li><b>Credits per kill</b> grow with health: base × (round health multiplier)^${data.bounty_exp}.</li>
<li><b>Armor</b> removes that much damage from every hit. Barriers absorb damage before the hull and ignore armor.</li>
<li><b>Leak cost</b> is how many core shields an enemy takes if it reaches the core.</li>
</ul>
</div>
</div>

<h3>Tower roster</h3>
<table class="grid"><tr><th>Tower</th><th>Key</th><th>Cost</th><th>Hits</th><th>Specializations (A · B · C)</th></tr>${towerIndex}</table>

<section class="chapter">
<h1>Enemies</h1>
<table class="grid"><tr><th>Enemy</th><th>Class</th><th>First round</th><th>Health (round 1)</th><th>Speed</th><th>Armor</th><th>Leak</th></tr>${enemyIndex}</table>
<p class="note">Towers that hit air: ${hitters(true).join(", ")}. Towers that hit ground: ${hitters(false).join(", ")}. Support towers (Amplifier Pylon, Sensor Array) and the Scrapyard (economy) don't attack.</p>
</section>

<section class="chapter">
<h1>Regular enemies</h1>
<div class="ecards">${regulars.map(enemyCard).join("")}</div>
</section>

<section class="chapter">
<h1>Bosses</h1>
<p>Bosses follow a fixed schedule on top of the regular rounds. Dreadnoughts come every 5 rounds, Leviathans from round 35 (every 20), the Overmind at 50, 75 and 100, and Colossi from round 60 (every 20). Each mode's last round is a finale with a boss line-up.</p>
<div class="ecards">${bosses.map(enemyCard).join("")}</div>
</section>

<section class="chapter" style="page-break-after: avoid">
<h1>Towers and upgrade trees</h1>
<p>One page per tower: its trunk, then each branch from specialization to mastery with every upgrade's cost, stats and effect. The two icons on each branch show the specialization and the mastery.</p>
</section>
${data.towers.map(towerPage).join("")}
</body></html>`;

writeFileSync(join(outDir, "codex.html"), html);
console.log(`Wrote design/codex/codex.html: ${data.towers.length} towers, ${data.enemies.length} enemies.`);
