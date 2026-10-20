// Generates data/rework_trees.gd (the reworked towers' trees as game data) from design/tower_stats.md (the numbers) and
// design/upgrade_trees_rework.md (names, prices, blurbs). Run: node tools/tree_rework_data.mjs   (from the project folder).
// Add --check to exit non-zero if the generated file on disk is stale (tools/dev.sh check does).
// Only towers that have a table in tower_stats.md are written, so the roster grows batch by batch.
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const out = join(root, "data", "rework_trees.gd");
const stats = readFileSync(join(root, "design", "tower_stats.md"), "utf8").replace(/\r\n/g, "\n");
const trees = readFileSync(join(root, "design", "upgrade_trees_rework.md"), "utf8").replace(/\r\n/g, "\n");

// The stat keys the game understands. A new mechanic adds its key here (and its handler in the game) in its batch.
const KEYS = new Set([
  "damage", "range", "rate", "proj_speed", "armor_flat", "armor_pct", "crit", "tracers", "stun_chance", "stun_time",
  "ignite_dps", "ignite_time", "swivel", "side_gun", "multishot", "weakest_extra",
  "splash", "tubes", "burrow_sight", "smoke_every", "smoke_slow", "smoke_time", "bomblets", "bomblet_damage", "bomblet_splash", "bomblet_spread",
  "missiles", "air_mult", "ground_burn", "ground_burn_time", "homing", "retarget", "never_miss", "ripple",
  "ramp", "ramp_time", "melt", "beams", "beam_power", "ramp_keep", "burst", "barrels", "turn_fast",
]);
const FLAGS = new Set(["tracers", "swivel", "weakest_extra", "homing", "retarget", "never_miss", "ripple", "turn_fast"]);

const errors = [];
const fail = (m) => errors.push(m);

// --- tower_stats.md: { slug: { meta: {...}, nodes: { id: {set, add} } } }
const statTowers = {};
for (const sec of stats.split(/\n## /).slice(1)) {
  const slug = sec.split("\n")[0].trim();
  const meta = {};
  const mm = sec.match(/^(air: .*)$/m);
  if (!mm) { fail(`${slug}: no meta line (air · ground · size · damage_kind)`); continue; }
  for (const part of mm[1].split(" · ")) { const [k, v] = part.split(": "); meta[k.trim()] = v.trim(); }
  const nodes = {};
  for (const line of sec.split("\n")) {
    const m = line.match(/^\| ((?:base|r[1-3]|[abc][1-4]|[abc]m)) \| (.+) \|$/);
    if (!m) continue;
    const set = {}, add = {};
    for (const tok of m[2].split(" · ")) {
      const t = tok.trim().match(/^([a-z_]+)(?: ([+-]?\d+(?:\.\d+)?))?$/);
      if (!t) { fail(`${slug} ${m[1]}: can't read "${tok}"`); continue; }
      const [, key, val] = t;
      if (!KEYS.has(key)) { fail(`${slug} ${m[1]}: unknown key "${key}"`); continue; }
      if (val === undefined) { if (!FLAGS.has(key)) fail(`${slug} ${m[1]}: "${key}" needs a value`); set[key] = true; continue; }
      if (FLAGS.has(key)) { fail(`${slug} ${m[1]}: "${key}" is a flag`); continue; }
      if (/^[+-]/.test(val)) add[key] = parseFloat(val); else set[key] = parseFloat(val);
    }
    nodes[m[1]] = { set, add };
  }
  statTowers[slug] = { meta, nodes };
}

// --- upgrade_trees_rework.md: { slug: { name, cls, weapon, build, branches: [names], rows: [{tier,path,name,cost,effect}] } }
const designTowers = {};
for (const sec of trees.split(/\n## /).slice(1)) {
  const name = sec.split("\n")[0].trim();
  const head = sec.split("\n")[1] || "";
  const h = {};
  for (const part of head.split(" · ")) { const i = part.indexOf(": "); if (i > 0) h[part.slice(0, i)] = part.slice(i + 2); }
  const slug = h.id;
  if (!slug) continue;
  const branches = (h.branches || "").split(/, (?![^(]*\))/).map((b) => b.replace(/\s*\(.*\)$/, "").trim());
  const blurb = (sec.split("\n")[2] || "").trim();
  const rows = [];
  for (const line of sec.split("\n")) {
    const c = line.split("|").slice(1, -1).map((x) => x.trim());
    if (c.length === 7 && /^(\d|M)$/.test(c[0])) rows.push({ tier: c[0], path: c[1], name: c[2], cost: parseInt(c[3].replace(/[^\d]/g, ""), 10), effect: c[5] });
  }
  designTowers[slug] = { name, cls: h.class, weapon: h.weapon, build: parseInt(h.build, 10), branches, blurb, rows };
}

// --- emit
const q = (s) => JSON.stringify(String(s));
const num = (v) => (Number.isInteger(v) ? v.toFixed(1) : String(v));
const val = (v) => (v === true ? "true" : num(v));
const dict = (o, ind) => {
  const keys = Object.keys(o);
  if (!keys.length) return "{}";
  return "{\n" + keys.map((k) => `${ind}\t${q(k)}: ${val(o[k])},`).join("\n") + `\n${ind}}`;
};
const node = (r, st, ind) => {
  const n = st.nodes[r.id] || { set: {}, add: {} };
  return `{\n${ind}\t"name": ${q(r.name)},\n${ind}\t"cost": ${r.cost},\n${ind}\t"blurb": ${q(r.effect)},\n${ind}\t"set": ${dict(n.set, ind + "\t")},\n${ind}\t"add": ${dict(n.add, ind + "\t")},\n${ind}}`;
};
let body = "";
const order = [];
for (const slug of Object.keys(statTowers)) {
  const st = statTowers[slug], d = designTowers[slug];
  if (!d) { fail(`${slug}: not in upgrade_trees_rework.md`); continue; }
  order.push(slug);
  const rows = d.rows.map((r) => ({ ...r, id: r.path === "base" ? "base" : /^r\d$/.test(r.path) ? r.path : r.path + (r.tier === "M" ? "m" : String(parseInt(r.tier, 10) - 2)) }));
  const byId = Object.fromEntries(rows.map((r) => [r.id, r]));
  for (const id of Object.keys(st.nodes)) if (!byId[id]) fail(`${slug}: node ${id} isn't in the design`);
  for (const r of rows) if (!st.nodes[r.id]) fail(`${slug}: node ${r.id} (${r.name}) has no stats`);
  const retro = rows.filter((r) => /^r\d$/.test(r.id));
  const ind = "\t\t";
  body += `\t${q(slug)}: {\n\t\t"name": ${q(d.name)},\n\t\t"class": ${q(d.cls)},\n\t\t"weapon": ${q(d.weapon)},\n\t\t"blurb": ${q(d.blurb)},\n`;
  body += `\t\t"air": ${st.meta.air === "yes"},\n\t\t"ground": ${st.meta.ground === "yes"},\n\t\t"size": ${parseInt(st.meta.size, 10)},\n\t\t"damage_kind": ${q(st.meta.damage_kind || "physical")},\n`;
  body += `\t\t"cost": ${d.build},\n\t\t"base": ${node(byId.base, st, ind)},\n\t\t"retrofits": [\n${retro.map((r) => `\t\t\t${node(r, st, "\t\t\t")},`).join("\n")}\n\t\t],\n\t\t"paths": [\n`;
  "abc".split("").forEach((k, i) => {
    body += `\t\t\t{\n\t\t\t\t"key": ${q(k)},\n\t\t\t\t"name": ${q(d.branches[i])},\n\t\t\t\t"nodes": [\n`;
    for (let s = 1; s <= 4; s++) body += `\t\t\t\t\t${node(byId[k + s], st, "\t\t\t\t\t")},\n`;
    body += `\t\t\t\t],\n\t\t\t\t"mastery": ${node(byId[k + "m"], st, "\t\t\t\t")},\n\t\t\t},\n`;
  });
  body += "\t\t],\n\t},\n";
}
const text = `extends RefCounted
## GENERATED by tools/tree_rework_data.mjs from design/tower_stats.md and design/upgrade_trees_rework.md. Edit those and
## re-run the generator; don't edit this file by hand.
##
## The reworked towers (issue #59). Per tower: \`base\`, \`retrofits\` (the player picks one of up to three), and \`paths\`
## (a, b, c), each with four \`nodes\` and a \`mastery\`. A node's \`set\` values replace the stat and its \`add\` values add to it;
## nodes apply in order on top of the base (the Retrofit, then each path's steps).

const ORDER := [${order.map(q).join(", ")}]

const TREES := {
${body}}
`;
if (errors.length) { console.error(errors.join("\n")); process.exit(1); }
if (process.argv.includes("--check")) {
  const cur = existsSync(out) ? readFileSync(out, "utf8").replace(/\r\n/g, "\n") : "";
  if (cur !== text) { console.error("data/rework_trees.gd is stale: run node tools/tree_rework_data.mjs"); process.exit(1); }
  console.log("rework_trees.gd is current");
} else {
  writeFileSync(out, text);
  console.log(`wrote data/rework_trees.gd (${order.length} tower${order.length === 1 ? "" : "s"})`);
}
