// Builds design/upgrade_trees_rework.html (the editable trees page for the tower rework) from
// design/upgrade_trees_rework.md. Run: node tools/tree_rework_page.mjs   (from the project folder)
// Today's trees page (tools/tree_page.mjs, design/upgrade_trees.md) and the game's data are untouched.
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { buildPage } from "./pages/build.mjs";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const src = readFileSync(join(root, "design", "upgrade_trees_rework.md"), "utf8").replace(/\r\n/g, "\n");
const ACCENT = ["#4de6ff", "#ff8c33", "#ff4d59", "#ffd94d", "#d9ff73", "#73ff8c", "#ffb86b", "#bf80ff", "#9fe870", "#f2d06b",
  "#ff6b9a", "#a3e635", "#ff66d9", "#59ffd9", "#8cd9ff", "#ffb347", "#f2b86b", "#c8b6ff", "#5eead4", "#e879f9"];

const lines = src.split("\n");
const title = (lines.find((l) => l.startsWith("# ")) || "# Upgrade trees").slice(2).trim();
const sections = [];
let section = null;
for (const line of lines) {
  if (line.startsWith("## ")) { section = { name: line.slice(3).trim(), meta: {}, role: "", nodes: [], bullets: [] }; sections.push(section); continue; }
  if (!section) continue;
  if (line.startsWith("- ")) { section.bullets.push(line.slice(2).trim()); continue; }
  if (line.startsWith("|")) {
    const cells = line.split("|").slice(1, -1).map((c) => c.trim());
    if (cells.length < 7 || cells[0] === "Tier" || /^-+$/.test(cells[0])) continue;
    const [tier, path, name, cost, stats, effect, status] = cells;
    section.nodes.push({ code: tier.toUpperCase(), tier: /^m/i.test(tier) ? 8 : parseInt(tier, 10), path: path.toLowerCase(), name,
      cost: parseInt(cost, 10) || 0, stats: stats.split("·").map((s) => s.trim()).filter(Boolean), effect, status: (status || "new").toLowerCase() });
  } else if (/^[a-z]+:/.test(line) && line.includes("·")) {
    for (const part of line.split("·")) { const m = part.trim().match(/^([a-z]+):\s*(.+)$/); if (m) section.meta[m[1]] = m[2].trim(); }
  } else if (line.trim() && !section.role) section.role = line.trim();
}
const towers = sections.filter((s) => s.nodes.length);
const panels = sections.filter((s) => !s.nodes.length && s.bullets.length);
for (const t of towers) if (/CAS Gunship/i.test(t.name)) t.meta.uncapped = "yes";
const data = {
  kind: "trees_rework", pageTitle: "Tower Rework Trees", title, accent: ACCENT, changed: {},
  panels: panels.map((p) => ({ name: p.name, bullets: p.bullets, answers: p.bullets.map(() => "") })),
  towers: towers.map((t) => ({ name: t.name, meta: t.meta, role: t.role, nodes: t.nodes })),
};
writeFileSync(join(root, "design", "upgrade_trees_rework.html"), buildPage("trees_rework", data));
const nodes = towers.reduce((a, t) => a + t.nodes.length, 0);
console.log(`Wrote design/upgrade_trees_rework.html: ${towers.length} towers, ${nodes} nodes.`);
for (const t of towers) {
  const miss = [];
  if (!t.nodes.some((n) => n.tier === 1)) miss.push("stock");
  if (!t.nodes.some((n) => n.tier === 2)) miss.push("retrofit");
  for (const p of ["a", "b", "c"]) for (const tier of [3, 4, 5, 6, 8]) if (!t.nodes.some((n) => n.tier === tier && n.path === p)) miss.push(`${p} ${tier === 8 ? "M" : tier - 2}`);
  if (miss.length) console.log(`  ${t.name}: missing ${miss.join(", ")}`);
}
