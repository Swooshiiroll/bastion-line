// Writes the edits saved in an editable design page back into its markdown source.
// usage: node tools/design_pull.mjs <saved page.html> [--dry]
// The page records every edited field in `changed` (path -> value before the edit); each one is
// checked against the markdown first, so a field that changed there since is reported, not clobbered.
// Answers to open questions aren't part of the markdown: they're printed for Claude to act on.
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const [file, ...flags] = process.argv.slice(2);
const dry = flags.includes("--dry");
const html = readFileSync(file, "utf8");
const m = html.match(/<script type="application\/json" id="page-data">([\s\S]*?)<\/script>/);
if (!m) throw new Error("No page data in " + file);
const data = JSON.parse(m[1]);
const mdFile = join(root, "design", data.kind === "trees" ? "upgrade_trees.md" : "super_structures.md");
const raw = readFileSync(mdFile, "utf8");
const eol = raw.includes("\r\n") ? "\r\n" : "\n";
const lines = raw.replace(/\r\n/g, "\n").split("\n");
const changed = data.changed || {};
const log = [], skipped = [];
const get = (p) => p.split(".").reduce((a, k) => (a == null ? a : a[k]), data);
const shown = (v) => (Array.isArray(v) ? v.join(" · ") : String(v));

function section(heading) {
  const start = lines.findIndex((l) => l === "## " + heading);
  if (start < 0) return null;
  let end = lines.findIndex((l, i) => i > start && l.startsWith("## "));
  return [start, end < 0 ? lines.length : end];
}
const cellsOf = (l) => l.split("|").slice(1, -1).map((c) => c.trim());
const rowLine = (cells) => "| " + cells.join(" | ") + " |";
function findRow(sec, tier, path) {
  for (let i = sec[0]; i < sec[1]; i++) {
    if (!lines[i].startsWith("|")) continue;
    const c = cellsOf(lines[i]);
    if (c[0].toUpperCase() === String(tier).toUpperCase() && c[1].toLowerCase() === path.toLowerCase()) return i;
  }
  return -1;
}
function wrap(text, first, cont, width = 100) {
  const out = [];
  let line = first;
  for (const w of text.split(/\s+/)) {
    if (line.length + w.length + 1 > width && line.trim() !== first.trim()) { out.push(line.trimEnd()); line = cont; }
    line += (line === first || line === cont ? "" : " ") + w;
  }
  out.push(line.trimEnd());
  return out;
}

const COL = { name: 2, cost: 3, stats: 4, effect: 5 };
const heading = (i) => changed[`structures.${i}.title`] ?? data.structures[i].title;

// Titles last, so rows are still found under the old heading.
const paths = Object.keys(changed).sort((a, b) => /\.title$/.test(a) - /\.title$/.test(b));
for (const p of paths) {
  const was = changed[p], now = get(p);
  const k = p.split(".");
  let mm;
  if ((mm = p.match(/^towers\.(\d+)\.nodes\.(\d+)\.(\w+)$/)) || (mm = p.match(/^structures\.(\d+)\.rows\.(\d+)\.(\w+)$/))) {
    const trees = k[0] === "towers";
    const owner = trees ? data.towers[+mm[1]] : data.structures[+mm[1]];
    const node = trees ? owner.nodes[+mm[2]] : owner.rows[+mm[2]];
    const sec = section(trees ? owner.name : heading(+mm[1]));
    const at = sec ? findRow(sec, trees ? node.code : node.tier, node.path) : -1;
    if (at < 0) { skipped.push(`${p}: row not found`); continue; }
    const c = cellsOf(lines[at]);
    const col = COL[mm[3]];
    const cur = mm[3] === "stats" ? c[col].split("·").map((s) => s.trim()).filter(Boolean).join(" · ") : c[col];
    if (cur !== shown(was) && !(mm[3] === "cost" && parseInt(cur, 10) === was)) { skipped.push(`${p}: the markdown now says "${cur}", not "${shown(was)}"`); continue; }
    c[col] = shown(now);
    if (trees && c[6] === "existing") c[6] = "changed";
    lines[at] = rowLine(c);
    log.push(`${trees ? owner.name : heading(+mm[1])} · ${node.name}: ${mm[3]} "${shown(was)}" → "${shown(now)}"`);
  } else if ((mm = p.match(/^(towers|structures)\.(\d+)\.role$/))) {
    const sec = section(mm[1] === "towers" ? data.towers[+mm[2]].name : heading(+mm[2]));
    const at = sec ? lines.findIndex((l, i) => i > sec[0] && i < sec[1] && l.trim() === was) : -1;
    if (at < 0) { skipped.push(`${p}: role line not found`); continue; }
    lines[at] = now;
    log.push(`${mm[1] === "towers" ? data.towers[+mm[2]].name : heading(+mm[2])}: role → "${now}"`);
  } else if ((mm = p.match(/^structures\.(\d+)\.(recipe\.\d+|layout)$/))) {
    const s = data.structures[+mm[1]];
    const sec = section(heading(+mm[1]));
    const at = sec ? lines.findIndex((l, i) => i > sec[0] && i < sec[1] && /^id:/.test(l)) : -1;
    if (at < 0) { skipped.push(`${p}: metadata line not found`); continue; }
    lines[at] = `id: ${s.id} · recipe: ${s.recipe.join(", ")} · layout: ${s.layout}`;
    log.push(`${heading(+mm[1])}: ${mm[2].startsWith("recipe") ? "recipe" : "layout"} "${was}" → "${now}"`);
  } else if ((mm = p.match(/^structures\.(\d+)\.title$/))) {
    const sec = section(was);
    if (!sec) { skipped.push(`${p}: heading "${was}" not found`); continue; }
    lines[sec[0]] = "## " + now;
    const base = findRow(sec, "1", "base");
    if (base >= 0) { const c = cellsOf(lines[base]); if (c[2] === was) { c[2] = now; lines[base] = rowLine(c); } }
    log.push(`Structure "${was}" renamed "${now}"`);
  } else if ((mm = p.match(/^panels\.(\d+)\.bullets\.(\d+)$/))) {
    const panel = data.panels[+mm[1]];
    const sec = section(panel.name);
    if (!sec) { skipped.push(`${p}: section "${panel.name}" not found`); continue; }
    let n = -1, at = -1;
    for (let i = sec[0]; i < sec[1]; i++) if (lines[i].startsWith("- ") && ++n === +mm[2]) { at = i; break; }
    if (at < 0) { skipped.push(`${p}: bullet not found`); continue; }
    let end = at + 1;
    while (end < sec[1] && /^\s{2,}\S/.test(lines[end]) && !lines[end].trim().startsWith("|")) end++;
    const cur = [lines[at].slice(2), ...lines.slice(at + 1, end).map((l) => l.trim())].join(" ").trim();
    if (cur !== was) { skipped.push(`${p}: the markdown bullet changed since the page was built`); continue; }
    lines.splice(at, end - at, ...wrap(now, "- ", "  "));
    log.push(`${panel.name}: bullet ${+mm[2] + 1} rewritten`);
  } else skipped.push(`${p}: not a field the markdown holds`);
}

console.log(`${log.length} edit(s) ${dry ? "would be applied" : "applied"} to ${mdFile.replace(root + "\\", "").replace(root + "/", "")}`);
for (const l of log) console.log("  " + l);
if (skipped.length) { console.log(`${skipped.length} skipped:`); for (const s of skipped) console.log("  " + s); }
const answers = [];
data.panels.forEach((p) => (p.answers || []).forEach((a, i) => { if (a && a.trim()) answers.push(`Q: ${p.bullets[i]}\n  A: ${a.trim().replace(/\n/g, "\n     ")}`); }));
if (answers.length) console.log(`\n${answers.length} answer(s):\n` + answers.join("\n"));
if (!dry && log.length) writeFileSync(mdFile, lines.join(eol));
