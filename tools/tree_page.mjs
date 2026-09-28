// Builds design/upgrade_trees.html (a visual layout of every tower's upgrade tree) from
// design/upgrade_trees.md. Run: node tools/tree_page.mjs   (from the project folder)
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { buildPage } from "./pages/build.mjs";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const src = readFileSync(join(root, "design", "upgrade_trees.md"), "utf8").replace(/\r\n/g, "\n");

// In-game accent colours (scripts/view/Draw.gd ACCENT); new towers get their own.
const ACCENT = {
  arrow: "#4de6ff", cannon: "#ff8c33", frost: "#8cd9ff", sniper: "#73ff8c", tesla: "#bf80ff",
  laser: "#ff4d59", missile: "#ffd94d", amp: "#ff66d9", flak: "#d9ff73", sensor: "#59ffd9",
  gravity: "#9973ff", nullifier: "#c8b6ff", nova: "#ffb347", drones: "#9fe870", scrap: "#f2b86b",
};


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
      code: tier.toUpperCase(), tier: /^m/i.test(tier) ? 8 : /^p/i.test(tier) ? 10 : /^s/i.test(tier) ? 9 : parseInt(tier, 10), path: path.toLowerCase(), name, cost: parseInt(cost, 10) || 0,
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

const PATHS = { a: "A", b: "B", c: "C" };

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

// --- Page ---------------------------------------------------------------------------------------
// The page renders itself from this data (tools/pages/trees.js) and can be edited in place; a Save
// republishes it with the edits in `changed`, which tools/design_pull.mjs writes back to the md.
const nodes = towers.flatMap((t) => t.nodes.filter((n) => n.tier !== 9));
const newNodes = nodes.filter((n) => n.status === "new").length;
const changedNodes = nodes.filter((n) => n.status === "changed").length;
const data = {
  kind: "trees", pageTitle: "Bastion Line Upgrade Trees", title: title.replace(/s*(.*)s*$/, ""), accent: ACCENT, changed: {},
  panels: panels.map((p) => ({ name: p.name, bullets: p.bullets, answers: p.bullets.map(() => "") })),
  towers: towers.map((t) => ({ name: t.name, meta: t.meta, role: t.role, nodes: t.nodes })),
};
const html = buildPage("trees", data);
writeFileSync(join(root, "design", "upgrade_trees.html"), html);
console.log(`Wrote design/upgrade_trees.html: ${towers.length} towers, ${nodes.length} nodes (${newNodes} new, ${changedNodes} changed).`);
for (const t of towers) {
  const problems = [];
  const want = [[1, "base"], [2, "base"]];
  for (const p of ["a", "b", "c"]) for (const tier of [3, 4, 5, 6, 8, 10]) want.push([tier, p]);
  for (const [tier, path] of want)
    if (!t.nodes.some((n) => n.tier === tier && n.path === path)) problems.push(`missing ${path} ${tier === 8 ? "M" : tier === 10 ? "P" : tier}`);
  for (const n of t.nodes) if (!n.effect) problems.push(`no description on ${n.name}`);
  problems.push(...progressionWarnings(t));
  if (problems.length) console.log(`  ${t.name}: ${problems.join(", ")}`);
}
