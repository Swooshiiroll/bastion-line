// Renders design/super_structures.md as design/super_structures.html (the page published for review).
// Each structure shows its 2x2 recipe in the layout it needs, its base, and its two branches.
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { buildPage } from "./pages/build.mjs";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const src = readFileSync(join(root, "design", "super_structures.md"), "utf8").replace(/\r\n/g, "\n");
const trees = readFileSync(join(root, "design", "upgrade_trees.md"), "utf8").replace(/\r\n/g, "\n");

const ACCENT = {
  arrow: "#4de6ff", cannon: "#ff8c33", frost: "#8cd9ff", sniper: "#73ff8c", tesla: "#bf80ff",
  laser: "#ff4d59", missile: "#ffd94d", amp: "#ff66d9", flak: "#d9ff73", sensor: "#59ffd9",
  gravity: "#9973ff", nullifier: "#c8b6ff", nova: "#ffb347", drones: "#9fe870", scrap: "#f2b86b",
};

// Tower display names from the upgrade-trees design file.
const TOWER_NAME = {};
{
  let name = null;
  for (const line of trees.split("\n")) {
    if (line.startsWith("## ")) name = line.slice(3).trim();
    const m = line.match(/^id: ([a-z_]+)/);
    if (m && name) TOWER_NAME[m[1]] = name;
  }
}

// --- Parse ---------------------------------------------------------------------------------------
const sections = [];
let cur = null;
for (const line of src.split("\n")) {
  if (line.startsWith("## ")) { cur = { title: line.slice(3).trim(), meta: {}, role: "", rows: [], bullets: [] }; sections.push(cur); continue; }
  if (!cur) continue;
  if (line.startsWith("- ")) { cur.bullets.push(line.slice(2)); continue; }
  if (/^\s{2,}\S/.test(line) && cur.bullets.length) { cur.bullets[cur.bullets.length - 1] += " " + line.trim(); continue; }
  if (line.startsWith("|")) {
    const c = line.split("|").slice(1, -1).map((s) => s.trim());
    if (c.length < 6 || c[0] === "Tier" || /^-+$/.test(c[0])) continue;
    cur.rows.push({ tier: c[0].toUpperCase(), path: c[1].toLowerCase(), name: c[2], cost: parseInt(c[3], 10) || 0,
      stats: c[4].split("·").map((s) => s.trim()).filter(Boolean), effect: c[5] });
  } else if (/^[a-z]+:/.test(line) && line.includes("·")) {
    for (const part of line.split("·")) {
      const m = part.trim().match(/^([a-z]+):\s*(.+)$/);
      if (m) cur.meta[m[1]] = m[2].trim();
    }
  } else if (line.trim() && !cur.role && Object.keys(cur.meta).length) {
    cur.role = line.trim();
  }
}
const structures = sections.filter((s) => s.rows.length);
const panels = sections.filter((s) => !s.rows.length && s.bullets.length);

// --- Page ---------------------------------------------------------------------------------------
// The page renders itself from this data (tools/pages/super.js) and can be edited in place; a Save
// republishes it with the edits in `changed`, which tools/design_pull.mjs writes back to the md.
const TWO_BY_TWO = ["scrap", "drones"]; // already 2x2 (data/towers.gd "size": 2), so never in a recipe
const data = {
  kind: "super", pageTitle: "Bastion Line Super Structures", changed: {},
  towers: Object.fromEntries(Object.entries(TOWER_NAME).map(([id, name]) => [id, { name, color: ACCENT[id] || "#888", size: TWO_BY_TWO.includes(id) ? 2 : 1 }])),
  panels: panels.map((p) => ({ name: p.title, bullets: p.bullets, answers: p.bullets.map(() => "") })),
  structures: structures.map((s) => ({
    id: s.meta.id || s.title, title: s.title, role: s.role, layout: s.meta.layout || "any",
    recipe: (s.meta.recipe || "").split(",").map((x) => x.trim()).filter(Boolean),
    rows: s.rows.map((r) => ({ tier: r.tier, path: r.path, name: r.name, cost: r.cost, stats: r.stats, effect: r.effect })),
  })),
};
const nodes = structures.reduce((a, s) => a + s.rows.length, 0);
const html = buildPage("super", data);
writeFileSync(join(root, "design", "super_structures.html"), html);
console.log(`Wrote design/super_structures.html: ${structures.length} structures, ${nodes} nodes.`);
for (const s of structures) {
  const problems = [];
  if ((s.meta.recipe || "").split(",").length !== 4) problems.push("recipe needs four towers");
  for (const id of (s.meta.recipe || "").split(",").map((x) => x.trim())) if (!TOWER_NAME[id]) problems.push(`unknown tower ${id}`);
  for (const [t, p] of [["1", "base"], ...["a", "b"].flatMap((p) => ["2", "3", "4", "M"].map((t) => [t, p]))])
    if (!s.rows.some((r) => r.tier === t && r.path === p)) problems.push(`missing ${p} ${t}`);
  for (const r of s.rows) if (!r.effect) problems.push(`no description on ${r.name}`);
  if (problems.length) console.log(`  ${s.title}: ${problems.join(", ")}`);
}
