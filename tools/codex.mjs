// Builds the printable Bastion Line codex: every enemy, every tower and its whole upgrade tree.
//   1. godot --path . -- --codex=<project>\design\codex     (data + sprites from the game: tools/Codex.gd)
//   2. node tools/codex.mjs                                 (writes design/codex/codex.html)
//   3. msedge --headless --print-to-pdf=... design/codex/codex.html
// Everything comes from the game via codex.json: enemy stats, roles, abilities and modifiers (the in-game Codex's own
// lines), and each tower's tree exactly as the Codex shows it.
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const outDir = join(root, "design", "codex");
const data = JSON.parse(readFileSync(join(outDir, "codex.json"), "utf8"));

const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
const num = (n) => Number(n).toLocaleString("en-US");
const plural = (n, s) => `${n} ${s}${n === 1 ? "" : "s"}`;
const cls = (e) => (e.boss ? (e.flying ? "Flying boss" : "Boss") : e.flying ? "Flyer" : "Ground");

// --- Enemies -------------------------------------------------------------------------------------
function enemyCard(e) {
  const rounds = data.sample_rounds.filter((r) => r !== 1);
  return `
  <div class="ecard" style="--acc:#${e.color}">
    <div class="ehead">
      <img src="icons/e_${e.id}.png">
      <div>
        <div class="ename">${esc(e.name)}</div>
        <div class="etag">${esc(e.role_label)} · strength ${num(e.strength)} · ${cls(e)} · first seen round ${e.first_round}</div>
        <p class="eblurb">${esc(e.blurb)}</p>
      </div>
    </div>
    <table class="kv">
      <tr><th>Health</th><td>${num(e.hp)}</td><th>Speed</th><td>${e.speed} px/s</td><th>Armor</th><td>${e.armor}</td></tr>
      <tr><th>Credits</th><td>${e.bounty}</td><th>Leak cost</th><td>${plural(e.lives, "shield")}</td><th>Size</th><td>${e.radius} px</td></tr>
    </table>
    ${e.abilities.length ? `<ul class="ab">${e.abilities.map((a) => `<li>${esc(a)}</li>`).join("")}</ul>` : ""}
    <p class="mods"><b>As an elite:</b> ${e.mods.length ? e.mods.map(esc).join(" · ") : "never"}</p>
    <table class="scale">
      <tr><th>Round</th>${rounds.map((r) => `<td>${r}</td>`).join("")}</tr>
      <tr><th>Health</th>${rounds.map((r) => `<td>${num(e.hp_by_round[r])}</td>`).join("")}</tr>
      <tr><th>Credits</th>${rounds.map((r) => `<td>${e.bounty_by_round[r]}</td>`).join("")}</tr>
    </table>
  </div>`;
}

// --- Towers --------------------------------------------------------------------------------------
const row = (r, extra = "") => `<tr class="${extra}"><td class="st">${esc(r.label)}</td><td class="nm">${esc(r.name)}</td><td class="cs">${num(r.cost)}</td><td class="sx">${esc(r.stats)}</td><td class="fx">${esc(r.blurb)}</td></tr>`;
function towerPage(t) {
  const stock = t.rows.filter((r) => r.label === "Stock");
  const retro = t.rows.filter((r) => r.label === "Retrofit");
  const paths = t.branches.map((br) => {
    const rows = t.rows.filter((r) => r.branch === br.id);
    const steps = rows.filter((r) => !r.label.endsWith("Mastery"));
    const total = rows.reduce((a, r) => a + r.cost, 0);
    const toSecondary = steps.slice(0, data.secondary_cap).reduce((a, r) => a + r.cost, 0);
    return `
    <div class="branch" style="--bc:#${br.color}">
      <div class="bhead">
        <img src="icons/t_${t.id}_${br.id}.png"><img src="icons/t_${t.id}_${br.id}_m.png">
        <div>
          <div class="bname"><span class="bl">${br.id.toUpperCase()}</span>${esc(br.name)}</div>
          <div class="bmeta">Key <code>${{ a: "U", b: "I", c: "O" }[br.id]}</code> · whole path ${num(total)} cr${t.uncapped ? "" : ` · as a secondary (${data.secondary_cap} steps) ${num(toSecondary)} cr`}</div>
        </div>
      </div>
      <table class="nodes">${rows.map((r) => row(r, r.label.endsWith("Mastery") ? "mast" : "")).join("")}</table>
    </div>`;
  }).join("");
  return `
  <section class="tower" style="--acc:#${t.color}">
    <div class="thead">
      <img src="icons/t_${t.id}_1.png"><img src="icons/t_${t.id}_2.png">
      <div>
        <h2>${esc(t.name)}</h2>
        <div class="tmeta">${esc(t.class)} · ${num(t.cost)} cr · ${esc(t.reach)}${t.size > 1 ? " · takes 2×2 tiles" : ""}${t.uncapped ? " · every path can go all the way" : ""}</div>
        <p class="role">${esc(t.blurb)}</p>
      </div>
    </div>
    <table class="nodes trunk">${stock.map((r) => row(r)).join("")}${retro.map((r) => row(r, "retro")).join("")}</table>
    ${paths}
  </section>`;
}

// --- Document ------------------------------------------------------------------------------------
const regulars = data.enemies.filter((e) => !e.boss);
const bosses = data.enemies.filter((e) => e.boss);
const modeRows = data.modes.map((m) => `<tr><td><span class="dot" style="background:#${m.color}"></span>${m.name}</td><td>${m.rounds}</td><td>${m.lives}</td><td>×${m.price.toFixed(1)}</td><td>${m.medal_rp}</td></tr>`).join("");
const towerIndex = data.towers.map((t) => `<tr><td><img class="mini" src="icons/t_${t.id}_1.png">${esc(t.name)}</td><td>${esc(t.class)}</td><td>${t.cost}</td><td>${esc(t.reach)}</td><td>${t.branches.map((b) => esc(b.name)).join(" · ")}</td></tr>`).join("");
const enemyIndex = data.enemies.map((e) => `<tr><td><img class="mini" src="icons/e_${e.id}.png">${esc(e.name)}</td><td>${esc(e.role_label)}</td><td>${cls(e)}</td><td>${e.first_round}</td><td>${num(e.hp)}</td><td>${e.speed}</td><td>${e.armor}</td><td>${num(e.strength)}</td><td>${e.lives}</td></tr>`).join("");
const roleRows = data.roles.map((r) => `<tr><td><b>${esc(r.role)}</b></td>${r.tiers.map((c) => `<td>${c.length ? c.map(esc).join(", ") : "-"}</td>`).join("")}<td>${r.other.length ? r.other.map(esc).join(", ") : "-"}</td></tr>`).join("");
const modRows = data.modifiers.map((m) => `<tr><td><b>${esc(m.name)}</b></td><td>${m.intro}</td><td>${esc(m.blurb)}</td></tr>`).join("");
const bossRows = data.boss_rounds.map((b) => `<tr><td>${b.round}</td><td>${b.line.map(esc).join(", ")}</td></tr>`).join("");
const hp = data.hp_curve;
const [b1, b2, b3] = data.leak_bands;
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
.mods { font-size: 7.9pt; color: #6b5200; }
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
.nodes .st { width: 11%; color: #5b6878; font-size: 7.8pt; }
.nodes .nm { width: 16%; font-weight: 600; }
.nodes .cs { width: 6%; text-align: right; padding-right: 8px; white-space: nowrap; }
.nodes .sx { width: 30%; font-family: Consolas, monospace; font-size: 7.4pt; color: #26303c; }
.nodes .fx { color: #333d4a; }
.nodes tr.retro td { background: #f3f7fb; }
.nodes tr.mast td { background: #fbf6e8; }
.nodes tr.mast .st { color: #9a6c00; font-weight: 600; }
.trunk { margin-bottom: 6px; }
.branch { border: 1px solid #d3d9e1; border-top: 3px solid var(--bc); border-radius: 6px; padding: 5px 6px 3px; margin: 7px 0; break-inside: avoid; }
.bhead { display: flex; gap: 6px; align-items: center; margin-bottom: 3px; }
.bhead img { width: 46px; height: 46px; border-radius: 5px; }
.bname { font-size: 11.5pt; font-weight: 600; }
.bl { display: inline-block; background: var(--bc); color: #0b0f15; border-radius: 4px; padding: 0 6px; margin-right: 7px; font-size: 10pt; }
.bmeta { color: #5b6878; font-size: 7.8pt; }
.note { color: #5b6878; font-size: 8pt; }
</style></head><body>

<div class="cover">
  <div class="cover-title">BASTION LINE</div>
  <div class="cover-sub">Field Codex · enemies, towers and upgrade paths</div>
  <div class="cover-strip">${["gun_turret", "tesla_tower", "laser_tower", "railgun", "cas_gunship", "drone_bay"].map((id) => `<img src="icons/t_${id}_c_m.png">`).join("")}</div>
  <div class="cover-strip">${["grunt", "phantom", "aegis", "titan", "wraith", "colossus"].map((id) => `<img src="icons/e_${id}.png">`).join("")}</div>
  <div class="cover-meta">Game v${esc(data.version)} · ${data.towers.length} towers · ${data.enemies.length} enemies · generated ${today} from the game's own data</div>
</div>

<h1>How to read this codex</h1>
<div class="two">
<div>
<h3>Towers and upgrades</h3>
<ul>
<li><b>Stock:</b> every tower is built as its stock model. Its <b>Retrofit</b> is a choice of three (<code>Y</code>, then <code>1</code>-<code>3</code>); once fitted it can't be changed.</li>
<li><b>Three paths (A, B, C)</b> are open from the start, each four steps and a <b>mastery</b>. <code>U</code>, <code>I</code> and <code>O</code> buy the next step on A, B and C.</li>
<li><b>Primary and secondary:</b> the first path to reach step 3 becomes the primary and can go on to its mastery; a second path stops at step ${data.secondary_cap}, and the third locks. The CAS Gunship is the exception: every path goes all the way.</li>
<li><b>Masteries</b> need that tower's Mastery research in the Research Lab.</li>
<li>Each path's two icons show it at step 4 and at its mastery. Stat columns: the stock row lists the full stats, every other row what that step changes.</li>
<li><b>Costs</b> are base prices in credits; harder modes multiply every build and upgrade price (table on the right).</li>
</ul>
<h3>Enemies</h3>
<ul>
<li><b>Roles and tiers:</b> each enemy has a role (the job it does) and, within its role, a tier from T1 to T4; higher tiers are tougher versions. Specials are one-of-a-kind tricks.</li>
<li><b>Strength</b> (speed² × armor × health) sets the Strongest targeting order, every boss above the rest, and the <b>leak cost</b>: below ${b1} strength 1 shield, below ${b2} 2, below ${b3} 3, else 4. A boss costs the round it was introduced.</li>
<li><b>Elites</b> from round 10 carry modifiers (one, two from round 40, three from round 80), pay double and cost a shield more.</li>
</ul>
</div>
<div>
<h3>Difficulty modes</h3>
<table class="grid"><tr><th>Mode</th><th>Rounds</th><th>Shields</th><th>Tower prices</th><th>Medal RP</th></tr>${modeRows}</table>
<p class="note">Every run starts with ${data.start_gold} credits. Clearing a mode's last round earns the sector's medal for that mode, and endless mode begins straight away.</p>
<h3>Enemy scaling</h3>
<ul>
<li><b>Health</b> grows every round: ×${hp["20"]} at round 20, ×${hp["40"]} at 40, ×${hp["60"]} at 60, ×${hp["80"]} at 80, ×${hp["100"]} at 100 and ×${hp["120"]} at 120. Each enemy card lists its health at sample rounds.</li>
<li><b>Credits per kill</b> grow with health: base × (round health multiplier)^${data.bounty_exp}.</li>
<li><b>Armor</b> removes that much damage from every hit. Barriers absorb damage before the hull and ignore armor.</li>
<li>Every round is the same on every playthrough, sector and mode; a new enemy leads every other round.</li>
</ul>
</div>
</div>

<h3>Tower roster</h3>
<table class="grid"><tr><th>Tower</th><th>Class</th><th>Cost</th><th>Hits</th><th>Paths (A · B · C)</th></tr>${towerIndex}</table>

<section class="chapter">
<h1>Enemies</h1>
<table class="grid"><tr><th>Enemy</th><th>Role</th><th>Class</th><th>First round</th><th>Health (round 1)</th><th>Speed</th><th>Armor</th><th>Strength</th><th>Leak</th></tr>${enemyIndex}</table>
<h3>Roles and tiers</h3>
<table class="grid"><tr><th>Role</th><th>T1</th><th>T2</th><th>T3</th><th>T4</th><th>Others</th></tr>${roleRows}</table>
<h3>Elite modifiers</h3>
<table class="grid"><tr><th>Modifier</th><th>From round</th><th>What it does</th></tr>${modRows}</table>
</section>

<section class="chapter">
<h1>Regular enemies</h1>
<div class="ecards">${regulars.map(enemyCard).join("")}</div>
</section>

<section class="chapter">
<h1>Bosses</h1>
<p>A boss round comes every 20 rounds, on top of the regular wave; each mode's last round is a finale with a boss line-up. A boss met once can turn up again in later rounds.</p>
<table class="grid"><tr><th>Round</th><th>Bosses</th></tr>${bossRows}</table>
<div class="ecards" style="margin-top:8px">${bosses.map(enemyCard).join("")}</div>
</section>

<section class="chapter" style="page-break-after: avoid">
<h1>Towers and upgrade paths</h1>
<p>One page per tower: its stock model and its three Retrofits, then each path's four steps and its mastery with every step's cost, stat changes and effect.</p>
</section>
${data.towers.map(towerPage).join("")}
</body></html>`;

writeFileSync(join(outDir, "codex.html"), html);
console.log(`Wrote design/codex/codex.html: ${data.towers.length} towers, ${data.enemies.length} enemies.`);
