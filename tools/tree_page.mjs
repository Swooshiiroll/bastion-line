// Builds design/upgrade_trees.html (a visual layout of every tower's upgrade tree) from
// design/upgrade_trees.md. Run: node tools/tree_page.mjs   (from the project folder)
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const src = readFileSync(join(root, "design", "upgrade_trees.md"), "utf8").replace(/\r\n/g, "\n");

// In-game accent colours (scripts/view/Draw.gd ACCENT); new towers get their own.
const ACCENT = {
  arrow: "#4de6ff", cannon: "#ff8c33", frost: "#8cd9ff", sniper: "#73ff8c", tesla: "#bf80ff",
  laser: "#ff4d59", missile: "#ffd94d", amp: "#ff66d9", flak: "#d9ff73", sensor: "#59ffd9",
  gravity: "#9973ff", nullifier: "#c8b6ff", nova: "#ffb347", drones: "#9fe870", scrap: "#f2b86b",
};

const esc = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
const inline = (s) => esc(s).replace(/`([^`]+)`/g, "<code>$1</code>");

// --- Parse ------------------------------------------------------------------------------------
const lines = src.split("\n");
const title = (lines.find((l) => l.startsWith("# ")) || "# Upgrade trees").slice(2).trim();
// Every `## Heading` is a section. Sections with a table are towers; sections with only bullets
// (Rules, Combinations, Research, Open questions...) become info panels.
const sections = [];
let section = null;
for (let i = 0; i < lines.length; i++) {
  const line = lines[i];
  if (line.startsWith("## ")) {
    section = { name: line.slice(3).trim(), meta: {}, role: "", nodes: [], bullets: [] };
    sections.push(section);
    continue;
  }
  if (!section) continue;
  if (line.startsWith("- ")) {
    section.bullets.push(line.slice(2).trim());
    continue;
  }
  if (/^\s{2,}\S/.test(line) && section.bullets.length && !line.trim().startsWith("|")) {
    section.bullets[section.bullets.length - 1] += " " + line.trim();
    continue;
  }
  if (line.startsWith("|")) {
    const cells = line.split("|").slice(1, -1).map((c) => c.trim());
    if (cells.length < 7 || cells[0] === "Tier" || /^-+$/.test(cells[0])) continue;
    const [tier, path, name, cost, stats, effect, status] = cells;
    section.nodes.push({
      tier: /^m/i.test(tier) ? 8 : /^s/i.test(tier) ? 9 : parseInt(tier, 10), path: path.toLowerCase(), name, cost: parseInt(cost, 10) || 0,
      stats: stats.split("·").map((s) => s.trim()).filter(Boolean), effect, status: (status || "existing").toLowerCase(),
    });
  } else if (/^[a-z]+:/.test(line) && line.includes("·")) {
    for (const part of line.split("·")) {
      const m = part.trim().match(/^([a-z]+):\s*(.+)$/);
      if (m) section.meta[m[1]] = m[2].trim();
    }
  } else if (line.trim() && !section.role) {
    section.role = line.trim();
  }
}
const towers = sections.filter((s) => s.nodes.length);
const panels = sections.filter((s) => !s.nodes.length && s.bullets.length);

// --- Stat arithmetic --------------------------------------------------------------------------
// A stat like "160 range" or "5.0/s" is a number plus a unit; "+10 range" is a bonus to that unit.
const num = (s) => {
  const m = s.match(/^([+−-]?)(\d+(?:\.\d+)?)\s*(.*)$/);
  if (!m) return null;
  const v = parseFloat(m[2]) * (m[1] === "−" || m[1] === "-" ? -1 : 1);
  return { v, unit: m[3].trim(), signed: m[1] !== "" };
};
const fmt = (v) => String(Math.round(v * 100) / 100);
const plusUnit = (u) => (u.startsWith("/") || u.startsWith("%") || u.startsWith("×") || u.startsWith("°") ? u : " " + u);

// What a specialization changes on top of Tier 2 when it's the secondary: shared stats change by
// their full difference (up or down), stats Tier 2 doesn't have are added as written.
function secondaryAdds(spec, t2) {
  const base = new Map();
  for (const s of t2.stats) { const p = num(s); if (p && p.unit) base.set(p.unit, p.v); }
  const out = [];
  for (const s of spec.stats) {
    const p = num(s);
    if (p && p.unit && base.has(p.unit)) {
      const d = p.v - base.get(p.unit);
      if (Math.abs(d) > 1e-9) out.push(`${d > 0 ? "+" : "−"}${fmt(Math.abs(d))}${plusUnit(p.unit)}`);
    } else {
      out.push(s);
    }
  }
  return out;
}

// Warn when a mastery ends up weaker than the specialization plus the three upgrades before it.
function progressionWarnings(t) {
  const warn = [];
  for (const p of ["a", "b", "c"]) {
    const spec = t.nodes.find((n) => n.tier === 3 && n.path === p);
    const mast = t.nodes.find((n) => n.tier === 8 && n.path === p);
    if (!spec || !mast) continue;
    const acc = new Map();
    for (const s of spec.stats) { const q = num(s); if (q && q.unit && !q.signed) acc.set(q.unit, q.v); }
    for (const tier of [4, 5, 6]) {
      const n = t.nodes.find((x) => x.tier === tier && x.path === p);
      for (const s of n ? n.stats : []) { const q = num(s); if (q && q.signed && acc.has(q.unit)) acc.set(q.unit, acc.get(q.unit) + q.v); }
    }
    for (const s of mast.stats) {
      const q = num(s);
      if (q && !q.signed && acc.has(q.unit) && q.v + 1e-9 < acc.get(q.unit)) warn.push(`${PATHS[p]} mastery ${fmt(q.v)}${plusUnit(q.unit)} < ${fmt(acc.get(q.unit))} before it`);
    }
  }
  return warn;
}

// --- Render -----------------------------------------------------------------------------------
const PATHS = { a: "A", b: "B", c: "C" };
const card = (n, color, adds = null) => {
  if (!n) return `<div class="card missing">Not defined yet</div>`;
  const isNew = n.status === "new" || n.status === "changed";
  const label = n.tier <= 2 ? `Tier ${n.tier}` : n.tier === 3 ? `${PATHS[n.path]}1 · specialization` : n.tier === 8 ? `${PATHS[n.path]} · mastery` : `${PATHS[n.path]}${n.tier - 2}`;
  const kind = n.tier === 8 ? "mastery" : n.tier === 3 ? "spec" : n.tier > 3 ? "step" : "trunk";
  return `<article class="card ${kind} ${isNew ? "is-new" : "is-old"} path-${n.path}" style="--tw:${color}">
    <header><span class="tag">${label}</span>${isNew ? `<span class="new">${n.status}</span>` : ""}<span class="cost">${n.cost} cr</span></header>
    <h4>${inline(n.name)}</h4>
    <ul class="stats">${n.stats.map((s) => `<li>${inline(s)}</li>`).join("")}</ul>
    ${n.effect ? `<p class="fx">${inline(n.effect)}</p>` : ""}
    ${adds === "attack" ? `<div class="sec"><span class="sec-tag">As a secondary</span><p class="fx">Adds its attack alongside the primary's (see Combinations).</p></div>` : adds ? `<div class="sec"><span class="sec-tag">As a secondary</span><ul class="stats">${adds.length ? adds.map((s) => `<li class="${s.startsWith("−") ? "down" : ""}">${inline(s)}</li>`).join("") : "<li>its effect only</li>"}</ul></div>` : ""}
    ${n.tier === 4 ? `<span class="cap">Secondary stops here</span>` : ""}
  </article>`;
};

const attackStyle = (t) => (t.meta.attack || "").toLowerCase().split(/[^a-c]+/).filter(Boolean);

const pathTotal = (t, p) => t.nodes.filter((n) => n.path === "base" || n.path === p).reduce((a, n) => a + n.cost, 0);

const treeHtml = (t) => {
  const color = ACCENT[t.meta.id] || "#4de1ff";
  const find = (tier, path) => t.nodes.find((n) => n.tier === tier && n.path === path);
  const rows = ["a", "b", "c"].map((p, i) => `
      <div class="fork r${i + 1}" aria-hidden="true"></div>
      <div class="branch r${i + 1}">${[3, 4, 5, 6, 8].map((tier) => card(find(tier, p), color, tier !== 3 || !find(3, p) || !find(2, "base") ? null : attackStyle(t).includes(p) ? "attack" : secondaryAdds(find(3, p), find(2, "base")))).join("")}</div>`).join("");
  const isNewTower = (t.meta.status || "") === "new";
  const own = t.nodes.filter((n) => n.tier !== 9);
  const newCount = own.filter((n) => n.status !== "existing").length;
  const id = (t.meta.id || t.name).toLowerCase().replace(/[^a-z0-9]+/g, "-");
  return `<section class="tower" id="${id}" style="--tw:${color}">
    <header class="tower-head">
      <div class="tower-name"><span class="swatch"></span><h3>${inline(t.name)}</h3>${isNewTower ? `<span class="new big">new tower</span>` : ""}</div>
      <p class="role">${inline(t.role)}</p>
      <dl class="meta">
        ${t.meta.key ? `<div><dt>Key</dt><dd><kbd>${esc(t.meta.key)}</kbd></dd></div>` : ""}
        ${t.meta.hits ? `<div><dt>Hits</dt><dd>${esc(t.meta.hits)}</dd></div>` : ""}
        <div><dt>Maxed</dt><dd>${["a", "b", "c"].map((p) => `${PATHS[p]} ${pathTotal(t, p)}`).join(" · ")} cr</dd></div>
        <div><dt>New nodes</dt><dd>${newCount} of ${own.length}</dd></div>
      </dl>
    </header>
    <div class="tree-scroll"><div class="tree">
      <div class="cell t1">${card(find(1, "base"), color)}</div>
      <div class="link base1" aria-hidden="true"></div>
      <div class="cell t2">${card(find(2, "base"), color)}</div>
      <div class="link base2" aria-hidden="true"></div>${rows}
    </div></div>
  </section>`;
};

const nodes = towers.flatMap((t) => t.nodes.filter((n) => n.tier !== 9));
const newNodes = nodes.filter((n) => n.status === "new").length;
const changedNodes = nodes.filter((n) => n.status === "changed").length;
const newTowers = towers.filter((t) => t.meta.status === "new").length;

const html = `<title>Bastion Line Upgrade Trees</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Chakra+Petch:wght@500;600;700&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>
  :root {
    color-scheme: dark;
    --ground: #070b10; --panel: #0d1620; --panel-2: #111e2a; --rule: #1d3a4b; --wire: #2a5a70;
    --text: #dcedf7; --dim: #86a0b1; --faint: #4f6a7b; --accent: #4de1ff; --gold: #ffc85a; --new: #6dffa0;
    --pa: #6fb8ff; --pb: #ff9e5e; --pc: #7dffb0;
    --display: "Chakra Petch", "Bahnschrift", "Segoe UI", sans-serif;
    --body: "IBM Plex Sans", "Segoe UI", system-ui, sans-serif;
    --mono: "IBM Plex Mono", "Consolas", monospace;
  }
  * { box-sizing: border-box; }
  body { color: var(--text); font: 14px/1.5 var(--body); padding-inline: 16px; padding-block: 0 48px;
    background: var(--ground) radial-gradient(circle at 1px 1px, #10202b 1px, transparent 1.5px) 0 0 / 24px 24px; }
  .wrap { max-width: 1640px; margin: 0 auto; }
  code, kbd { font-family: var(--mono); font-size: .92em; }
  kbd { border: 1px solid var(--wire); border-bottom-width: 2px; padding: 0 .4em; border-radius: 3px; color: var(--text); background: var(--panel-2); }
  .top { padding-block: 40px 20px; display: grid; gap: 14px; }
  .eyebrow { font: 600 12px/1 var(--display); letter-spacing: .18em; text-transform: uppercase; color: var(--accent); }
  h1 { font: 700 clamp(28px, 4.2vw, 44px)/1.05 var(--display); margin: 0; text-wrap: balance; letter-spacing: .01em; }
  .lede { color: var(--dim); max-width: 68ch; margin: 0; }
  .counts { display: flex; flex-wrap: wrap; gap: 8px 22px; font: 500 13px var(--mono); color: var(--dim); font-variant-numeric: tabular-nums; }
  .counts b { color: var(--text); font-weight: 500; }
  .legend { display: flex; flex-wrap: wrap; gap: 8px 18px; align-items: center; font-size: 12.5px; color: var(--dim); }
  .legend span { display: inline-flex; align-items: center; gap: 7px; }
  .dot { width: 10px; height: 10px; border-radius: 2px; display: inline-block; }
  .bar { position: sticky; top: env(safe-area-inset-top, 0px); z-index: 5; background: color-mix(in srgb, var(--ground) 92%, transparent);
    backdrop-filter: blur(6px); border-bottom: 1px solid var(--rule); padding-block: 10px; display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
  .chip { font: 600 12px var(--display); letter-spacing: .04em; color: var(--text); text-decoration: none; padding: 5px 10px; border: 1px solid var(--rule);
    border-radius: 3px; display: inline-flex; gap: 7px; align-items: center; background: var(--panel); }
  .chip i { width: 8px; height: 8px; border-radius: 1px; background: var(--tw); }
  .chip:hover, .chip:focus-visible { border-color: var(--tw); outline: none; }
  .toggle { margin-left: auto; font: 600 12px var(--display); letter-spacing: .04em; color: var(--new); background: transparent; border: 1px solid color-mix(in srgb, var(--new) 45%, transparent);
    padding: 5px 12px; border-radius: 3px; cursor: pointer; }
  .toggle[aria-pressed="true"] { background: color-mix(in srgb, var(--new) 16%, transparent); }
  .toggle:focus-visible { outline: 2px solid var(--new); outline-offset: 2px; }
  .panels { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 560px), 1fr)); gap: 12px; margin-top: 18px; align-items: start; }
  .questions { border: 1px solid var(--rule); border-left: 3px solid var(--gold); background: var(--panel); padding: 12px 16px; border-radius: 2px; }
  .questions h2 { font: 600 13px var(--display); letter-spacing: .12em; text-transform: uppercase; color: var(--gold); margin: 0 0 6px; }
  .questions ul { margin: 0; padding-left: 18px; color: var(--dim); display: grid; gap: 3px; }
  .tower { margin-top: 34px; scroll-margin-top: 64px; }
  .tower-head { display: grid; grid-template-columns: 1fr auto; gap: 4px 24px; align-items: end; border-bottom: 1px solid var(--rule); padding-bottom: 10px; margin-bottom: 14px; }
  .tower-name { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
  .swatch { width: 14px; height: 14px; background: var(--tw); clip-path: polygon(25% 0, 75% 0, 100% 50%, 75% 100%, 25% 100%, 0 50%); box-shadow: 0 0 12px var(--tw); }
  h3 { font: 700 22px/1.1 var(--display); margin: 0; color: var(--tw); letter-spacing: .02em; }
  .role { grid-column: 1; margin: 0; color: var(--dim); }
  .meta { grid-column: 2; grid-row: 1 / 3; display: flex; flex-wrap: wrap; gap: 4px 18px; margin: 0; font-size: 12px; justify-content: flex-end; }
  .meta div { display: grid; gap: 1px; }
  .meta dt { color: var(--faint); font: 600 10.5px var(--display); letter-spacing: .12em; text-transform: uppercase; }
  .meta dd { margin: 0; font-family: var(--mono); font-variant-numeric: tabular-nums; color: var(--text); }
  .new { font: 600 10.5px/1 var(--display); letter-spacing: .12em; text-transform: uppercase; color: var(--ground); background: var(--new); padding: 3px 6px; border-radius: 2px; }
  .new.big { font-size: 11px; padding: 4px 8px; }
  .tree-scroll { overflow-x: auto; padding-bottom: 4px; }
  .tree { display: grid; min-width: 1320px; grid-template-columns: 150px 20px 150px 28px 1fr; grid-template-rows: auto auto auto; }
  .cell { display: flex; align-items: center; padding-block: 6px; }
  .cell > .card { width: 100%; }
  .t1 { grid-column: 1; grid-row: 1 / 4; }
  .t2 { grid-column: 3; grid-row: 1 / 4; }
  .base1 { grid-column: 2; grid-row: 1 / 4; }
  .base2 { grid-column: 4; grid-row: 1 / 4; }
  .fork { grid-column: 4; }
  .branch { grid-column: 5; display: grid; grid-template-columns: 1.3fr repeat(3, 1fr) 1.35fr; gap: 0 18px; padding-block: 6px; align-items: stretch; }
  .r1 { grid-row: 1; } .r2 { grid-row: 2; } .r3 { grid-row: 3; }
  .link, .fork { position: relative; }
  .link::before, .fork::before, .fork::after { content: ""; position: absolute; background: var(--wire); }
  .link::before { left: 0; right: 0; top: 50%; height: 2px; margin-top: -1px; }
  .base2::before { right: 50%; }
  .fork::before { left: 50%; right: 0; top: 50%; height: 2px; margin-top: -1px; }
  .fork::after { left: 50%; width: 2px; margin-left: -1px; top: 0; bottom: 0; }
  .fork.r1::after { top: 50%; } .fork.r3::after { bottom: 50%; }
  .branch > .card:not(:last-child)::after { content: ""; position: absolute; top: 50%; right: -19px; width: 18px; height: 2px; margin-top: -1px; background: var(--wire); }
  .fork.r3::before, .branch.r3 > .card:not(:last-child)::after { background: color-mix(in srgb, var(--pc) 55%, var(--wire)); }
  .card.step { padding: 8px 10px 9px; gap: 4px; }
  .card.step h4 { font-size: 14px; }
  .card.step .fx { font-size: 12px; }
  .card.spec h4, .card.mastery h4 { font-size: 16.5px; }
  .card { background: var(--panel); border: 1px solid var(--rule); border-radius: 3px; padding: 10px 12px 11px; display: grid; gap: 5px; position: relative; transition: opacity .2s; }
  .card::before { content: ""; position: absolute; left: -1px; top: -1px; bottom: -1px; width: 3px; background: var(--edge, var(--tw)); border-radius: 3px 0 0 3px; }
  .card.path-a { --edge: var(--pa); } .card.path-b { --edge: var(--pb); } .card.path-c { --edge: var(--pc); }
  .card.spec { border-color: color-mix(in srgb, var(--edge) 35%, var(--rule)); }
  .card.mastery { background: linear-gradient(180deg, color-mix(in srgb, var(--gold) 7%, var(--panel)), var(--panel)); border-color: color-mix(in srgb, var(--gold) 40%, var(--rule)); }
  .card.is-new { border-color: color-mix(in srgb, var(--new) 45%, var(--rule)); }
  .card header { display: flex; align-items: center; gap: 8px; }
  .tag { font: 600 10.5px var(--display); letter-spacing: .12em; text-transform: uppercase; color: var(--faint); }
  .mastery .tag { color: var(--gold); }
  .cost { margin-left: auto; font: 500 12px var(--mono); color: var(--gold); font-variant-numeric: tabular-nums; white-space: nowrap; }
  .card h4 { margin: 0; font: 600 16px/1.2 var(--display); letter-spacing: .01em; }
  .stats { list-style: none; margin: 0; padding: 0; display: flex; flex-wrap: wrap; gap: 3px 5px; }
  .stats li { font: 400 11.5px/1.35 var(--mono); color: var(--text); background: var(--panel-2); border: 1px solid var(--rule); padding: 1px 5px; border-radius: 2px; }
  .fx { margin: 0; color: var(--dim); font-size: 12.5px; line-height: 1.45; }
  .missing { color: var(--faint); font-style: italic; }
  .sec { margin-top: 3px; padding: 6px 8px 7px; border: 1px dashed var(--wire); border-radius: 2px; display: grid; gap: 4px; background: color-mix(in srgb, var(--edge) 5%, transparent); }
  .stats li.down { color: var(--pb); border-color: color-mix(in srgb, var(--pb) 35%, var(--rule)); }
  .sec-tag { font: 600 10px var(--display); letter-spacing: .12em; text-transform: uppercase; color: var(--edge); }
  .cap { justify-self: start; font: 600 10px var(--display); letter-spacing: .1em; text-transform: uppercase; color: var(--dim); border: 1px dashed var(--wire); padding: 2px 6px; border-radius: 2px; }
  .panel-rules { border-left-color: var(--accent); } .panel-rules h2 { color: var(--accent); }
  .panel-combinations { border-left-color: var(--pb); } .panel-combinations h2 { color: var(--pb); }
  .panel-research { border-left-color: var(--new); } .panel-research h2 { color: var(--new); }
  .panel-open-questions { border-left-color: var(--faint); } .panel-open-questions h2 { color: var(--dim); }
  body.focus-new .card.is-old { opacity: .32; }
  footer { margin-top: 44px; color: var(--faint); font-size: 12px; border-top: 1px solid var(--rule); padding-top: 12px; }
  @media (max-width: 760px) {
    .tower-head { grid-template-columns: 1fr; } .meta { grid-column: 1; grid-row: auto; justify-content: flex-start; }
    .tree { display: flex; flex-direction: column; gap: 8px; min-width: 0; }
    .link, .fork { display: none; }
    .cell { padding: 0; }
    .branch { display: flex; flex-direction: column; gap: 6px; padding: 0 0 0 14px; border-left: 2px solid var(--wire); }
    .branch > .card::after { display: none; }
    .toggle { margin-left: 0; }
  }
  @media (prefers-reduced-motion: reduce) { .card { transition: none; } }
</style>
<div class="wrap">
  <div class="top">
    <span class="eyebrow">Bastion Line · design draft</span>
    <h1>${inline(title.replace(/\s*\(.*\)\s*$/, ""))}</h1>
    <p class="lede">Every tower's upgrade tree: a two-tier trunk, then three branches (A, B and the new C). Each branch is four upgrades, starting with the specialization you pick, and ends in a mastery. A tower can also take the first two upgrades of one other branch as a secondary, with their full effects. Green marks new content. The page is built from <code>design/upgrade_trees.md</code>.</p>
    <div class="counts"><span><b>${towers.length}</b> towers</span><span><b>${newTowers}</b> new towers</span><span><b>${towers.length * 3}</b> branches</span><span><b>${nodes.length}</b> upgrade nodes</span><span><b>${newNodes}</b> new nodes</span><span><b>${changedNodes}</b> changed</span></div>
    <div class="legend">
      <span><i class="dot" style="background:var(--pa)"></i>Path A</span>
      <span><i class="dot" style="background:var(--pb)"></i>Path B</span>
      <span><i class="dot" style="background:var(--pc)"></i>Path C</span>
      <span><i class="dot" style="background:var(--gold)"></i>Mastery (needs research)</span>
      <span><span class="new">new</span>New node</span>
    </div>
    ${panels.length ? `<div class="panels">${panels.map((p) => `<div class="questions panel-${p.name.toLowerCase().replace(/[^a-z]+/g, "-")}"><h2>${inline(p.name)}</h2><ul>${p.bullets.map((q) => `<li>${inline(q)}</li>`).join("")}</ul></div>`).join("")}</div>` : ""}
  </div>
  <nav class="bar" aria-label="Towers">
    ${towers.map((t) => `<a class="chip" href="#${(t.meta.id || t.name).toLowerCase().replace(/[^a-z0-9]+/g, "-")}" style="--tw:${ACCENT[t.meta.id] || "#4de1ff"}"><i></i>${esc(t.name)}</a>`).join("")}
    <button class="toggle" id="focus-new" type="button" aria-pressed="false">Highlight new</button>
  </nav>
  ${towers.map(treeHtml).join("")}
  <footer>Costs are per upgrade; "Maxed" is the total from Tier 1 to each branch's mastery. Upgrades after the specialization list what they add. New-node numbers are first-pass values for the balance probe.</footer>
</div>
<script>
  (function () {
    var btn = document.getElementById("focus-new");
    var on = false;
    try { on = localStorage.getItem("trees-focus-new") === "1"; } catch (e) {}
    function apply() { document.body.classList.toggle("focus-new", on); btn.setAttribute("aria-pressed", on ? "true" : "false"); }
    btn.addEventListener("click", function () { on = !on; apply(); try { localStorage.setItem("trees-focus-new", on ? "1" : "0"); } catch (e) {} });
    apply();
  })();
</script>
`;
writeFileSync(join(root, "design", "upgrade_trees.html"), html);
console.log(`Wrote design/upgrade_trees.html: ${towers.length} towers, ${nodes.length} nodes (${newNodes} new, ${changedNodes} changed).`);
for (const t of towers) {
  const problems = [];
  const want = [[1, "base"], [2, "base"]];
  for (const p of ["a", "b", "c"]) for (const tier of [3, 4, 5, 6, 8]) want.push([tier, p]);
  for (const [tier, path] of want)
    if (!t.nodes.some((n) => n.tier === tier && n.path === path)) problems.push(`missing ${path} ${tier === 8 ? "M" : tier}`);
  for (const n of t.nodes) if (!n.effect) problems.push(`no description on ${n.name}`);
  problems.push(...progressionWarnings(t));
  if (problems.length) console.log(`  ${t.name}: ${problems.join(", ")}`);
}
