// The balance master's tool (issue #75, design/balance_master.md). Run from the project folder after editing
// design/balance.md:   node tools/balance.mjs          then node tools/tree_rework_data.mjs (the tower data)
// It writes every number design/balance.md owns into the game's scripts (each in place, so their text stays as it is),
// rewrites balance.md's generated (=) columns and tables, and copies the tower prices into design/upgrade_trees_rework.md
// (the trees page shows them). --check changes nothing and exits non-zero if anything is out of date (tools/dev.sh check).
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { root, BALANCE, TREES, read, parseTowers, parseTrees, cells, rowLine, nodeId, applyNode, NODE_IDS,
  gdSpan, gdRead, gdWrite, gdString, gdNumberPaths, gdDictKeys } from "./balance_lib.mjs";

const errors = [];
const CHECK = process.argv.includes("--check");
const balance = read(BALANCE);
const trees = read(TREES);

// The scripts balance.md writes into, by the short name a Rules row uses (`Game.SELL_REFUND`).
const FILES = {
  Game: "scripts/core/Game.gd", Enemy: "scripts/entities/Enemy.gd", Tower: "scripts/entities/Tower.gd",
  Enemies: "data/enemies.gd", Waves: "data/waves.gd", Modifiers: "data/modifiers.gd", Research: "data/research.gd",
  Difficulty: "data/difficulty.gd", Abilities: "data/abilities.gd",
};
const orig = {}, gd = {};
for (const k in FILES) orig[k] = gd[k] = read(join(root, FILES[k]));
// Write a file back with its own line endings (Windows checkouts have CRLF; the repo and CI have LF).
const save = (file, text) => writeFileSync(file, readFileSync(file, "utf8").includes("\r\n") ? text.replace(/\n/g, "\r\n") : text);
const set = (file, path, raw, where) => {
  if (!gdSpan(gd[file], path)) { errors.push(`${where}: ${FILES[file]} has no number at ${path} (add a new key there first)`); return; }
  gd[file] = gdWrite(gd[file], path, raw);
};
const isNum = (s) => /^-?\d+(?:\.\d+)?$/.test(s);

// --- Bound tables: a `<!-- table: name -->` line, then a Markdown table whose numbers go into a script. -------------
// rows:   one row per entry of a dictionary (`Id` column); named columns and a tokens column (`key value · ...`).
// dicts:  one row per id; each named column is its own flat dictionary in the file (a blank cell: not in it).
// bosses: one row per boss round; the line-up's counts.
// consts: `Constant` (File.NAME, or File.NAME.0 for an array element) and `Value`.
const TABLES = {
  enemies: { kind: "rows", file: "Enemies", dict: "ENEMIES", cols: { HP: "hp", Speed: "speed", Armor: "armor", Bounty: "bounty", Radius: "radius" }, tokens: "Abilities", skip: ["tier", "lives"] },
  modifiers: { kind: "rows", file: "Modifiers", dict: "MODIFIERS", cols: { Intro: "intro", Cost: "cost" }, tokens: "Numbers", skip: [] },
  round_makeup: { kind: "dicts", file: "Waves", cols: { Intro: "INTRO", Threat: "COST", Spacing: "SPACING", Max: "MAX_COUNT" } },
  boss_rounds: { kind: "bosses", file: "Waves" },
  difficulty: { kind: "rows", file: "Difficulty", dict: "DIFFICULTIES", cols: { Rounds: "rounds", Shields: "lives", "Medal RP": "medal_rp", Price: "price" }, skip: [] },
  research: { kind: "rows", file: "Research", dict: "NODES", cols: { RP: "cost" }, tokens: "Effects", prefix: "effects.", skip: [] },
  abilities: { kind: "rows", file: "Abilities", dict: "ABILITIES", tokens: "Numbers", skip: [] },
  rules: { kind: "consts" }, wave_rules: { kind: "consts" }, economy: { kind: "consts" }, enemy_rules: { kind: "consts" },
};

// Every bound table in balance.md: { name: { start, head (column index), rows: [{ line, cells }] } }.
function findTables(text) {
  const lines = text.split("\n");
  const out = {};
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].match(/^<!-- table: ([a-z_]+) -->$/);
    if (!m) continue;
    let j = i + 1;
    while (j < lines.length && !lines[j].startsWith("|")) j++;
    const head = Object.fromEntries(cells(lines[j]).map((h, k) => [h, k]));
    const rows = [];
    for (let k = j + 2; k < lines.length && lines[k].startsWith("|"); k++) rows.push({ line: k, cells: cells(lines[k]) });
    out[m[1]] = { head, rows };
  }
  return out;
}
const tables = findTables(balance);
for (const name in tables) if (!TABLES[name]) errors.push(`balance.md: unknown table "${name}"`);

const tokens = (text, where) => {
  const out = [];
  if (!text || text === "-") return out;
  for (const tok of text.split(" · ")) {
    const t = tok.trim().match(/^([a-z_][a-z0-9_.]*) (-?\d+(?:\.\d+)?)$/);
    if (!t) errors.push(`${where}: can't read "${tok}"`);
    else out.push([t[1], t[2]]);
  }
  return out;
};

// Apply every bound table's inputs.
for (const [name, tb] of Object.entries(tables)) {
  const spec = TABLES[name];
  if (!spec) continue;
  if (spec.kind === "rows") {
    const bound = {};
    for (const r of tb.rows) {
      const id = r.cells[tb.head.Id];
      bound[id] = new Set(spec.skip);
      for (const [h, key] of Object.entries(spec.cols || {})) {
        const v = r.cells[tb.head[h]];
        if (!isNum(v)) { errors.push(`${name} ${id}: ${h} "${v}" isn't a number`); continue; }
        set(spec.file, `${spec.dict}.${id}.${key}`, v, `${name} ${id}`);
        bound[id].add(key);
      }
      if (spec.tokens) for (const [k, v] of tokens(r.cells[tb.head[spec.tokens]], `${name} ${id}`)) {
        const key = (spec.prefix || "") + k;
        set(spec.file, `${spec.dict}.${id}.${key}`, v, `${name} ${id}`);
        bound[id].add(key);
      }
    }
    // Everything numeric in the dictionary must be in the table, and every table row in the dictionary.
    const ids = gdDictKeys(gd[spec.file], spec.dict);
    for (const id of ids) {
      if (!bound[id]) { errors.push(`${name}: ${FILES[spec.file]} has ${id}, which isn't in balance.md`); continue; }
      for (const p of gdNumberPaths(gd[spec.file], `${spec.dict}.${id}`)) if (!bound[id].has(p)) errors.push(`${name} ${id}: ${p} isn't in balance.md`);
    }
    for (const id in bound) if (!ids.includes(id)) errors.push(`${name}: ${id} isn't in ${FILES[spec.file]}`);
  } else if (spec.kind === "dicts") {
    for (const r of tb.rows) {
      const id = r.cells[tb.head.Id];
      for (const [h, dict] of Object.entries(spec.cols)) {
        const v = r.cells[tb.head[h]];
        const has = gdSpan(gd[spec.file], `${dict}.${id}`) !== null;
        if (v === "" || v === "-") { if (has) errors.push(`${name} ${id}: ${h} is blank but ${dict} has it`); continue; }
        if (!isNum(v)) { errors.push(`${name} ${id}: ${h} "${v}" isn't a number`); continue; }
        if (!has) { errors.push(`${name} ${id}: ${dict} has no entry for it (add it in ${FILES[spec.file]} first)`); continue; }
        set(spec.file, `${dict}.${id}`, v, `${name} ${id}`);
      }
    }
    for (const dict of Object.values(spec.cols)) for (const id of gdDictKeys(gd[spec.file], dict)) {
      if (!tb.rows.some((r) => r.cells[tb.head.Id] === id)) errors.push(`${name}: ${dict}.${id} isn't in balance.md`);
    }
  } else if (spec.kind === "bosses") {
    const lineups = bossRounds(gd.Waves);
    for (const r of tb.rows) {
      const round = r.cells[tb.head.Round];
      const want = lineups[round];
      const got = tokens(r.cells[tb.head["Line-up"]], `${name} ${round}`);
      if (!want) { errors.push(`${name}: round ${round} isn't a boss round in data/waves.gd`); continue; }
      if (got.map((g) => g[0]).join(",") !== want.map((w) => w[0]).join(",")) { errors.push(`${name} ${round}: the line-up must list ${want.map((w) => w[0]).join(", ")} in order (change which bosses in data/waves.gd)`); continue; }
      got.forEach(([, v], i) => set("Waves", `BOSS_ROUNDS.${round}.${i}.1`, v, `${name} ${round}`));
    }
  } else if (spec.kind === "consts") {
    for (const r of tb.rows) {
      const c = r.cells[tb.head.Constant].replace(/`/g, "");
      const v = r.cells[tb.head.Value];
      const [file, ...rest] = c.split(".");
      if (!FILES[file]) { errors.push(`${name}: ${c}: unknown script "${file}"`); continue; }
      if (!isNum(v)) { errors.push(`${name} ${c}: "${v}" isn't a number`); continue; }
      set(file, rest.join("."), v, `${name} ${c}`);
    }
  }
}

// BOSS_ROUNDS as { "20": [["juggernaut", 1]], ... } from the script's text.
function bossRounds(src) {
  const out = {};
  const block = src.slice(src.indexOf("const BOSS_ROUNDS"), src.indexOf("\n}", src.indexOf("const BOSS_ROUNDS")));
  for (const m of block.matchAll(/^\t(\d+): \[(.*)\],?$/gm)) out[m[1]] = [...m[2].matchAll(/\["(\w+)", (\d+)\]/g)].map((x) => [x[1], +x[2]]);
  return out;
}

// --- The game's formulas, in JS, on the numbers as written above (balance.md, Formulas). -----------------------------
const W = (k) => gdRead(gd.Waves, k);
const hpScale = (r) => { const w = Math.max(r, 1) - 1; return (1 + W("HP_LINEAR") * w + W("HP_QUAD") * w * w) * Math.pow(1 + W("late_growth"), Math.max(0, r - W("LATE_START"))); };
const speedScale = (r, boss) => 1 + Math.min(W("SPEED_CAP"), W("SPEED_PER_ROUND") * (Math.max(r, 1) - 1)) * (boss ? W("BOSS_SPEED_SHARE") : 1);
const budget = (r) => { const w = Math.max(r, 1) - 1; return W("BUDGET_BASE") + W("BUDGET_LINEAR") * w + W("BUDGET_QUAD") * w * w; };
const eliteShare = (r) => (r < W("ELITE_FROM") ? 0 : W("ELITE_START") + W("ELITE_RISE") * Math.min(1, Math.max(0, (r - W("ELITE_FROM")) / (W("ELITE_FULL_AT") - W("ELITE_FROM")))));
const bountyScale = (r) => Math.pow(hpScale(r), W("bounty_exp"));
const E = (id, k) => gdRead(gd.Enemies, `ENEMIES.${id}.${k}`);
const strength = (id) => Math.pow(E(id, "speed") / 100, 2) * Math.max(1, E(id, "armor") || 0) * E(id, "hp");
function bossRound(id) {
  const br = bossRounds(gd.Waves);
  for (const r of Object.keys(br).map(Number).sort((a, b) => a - b)) if (br[r].some((x) => x[0] === id)) return r;
  return 0;
}
function leak(id) {
  if (bossRound(id) > 0) return bossRound(id);
  let n = 1;
  for (let i = 0; i < 3; i++) if (strength(id) >= gdRead(gd.Enemies, `LEAK_BANDS.${i}`)) n++;
  return n;
}
// Each enemy's leak cost is derived (its strength band; a boss its first boss round) and written into the script.
for (const id of gdDictKeys(gd.Enemies, "ENEMIES")) set("Enemies", `ENEMIES.${id}.lives`, String(leak(id)), `enemy ${id}`);

// --- Rewrite balance.md: derived cells, then generated blocks. --------------------------------------------------------
const f0 = (v) => String(Math.round(v));
const f1 = (v) => (v === null || v === undefined ? "-" : v.toFixed(1));
const f2 = (v) => (v === null || v === undefined ? "-" : v.toFixed(2));
const lines = balance.split("\n");
for (const [name, tb] of Object.entries(tables)) {
  const spec = TABLES[name];
  if (!spec) continue;
  for (const r of tb.rows) {
    const c = r.cells;
    const id = c[tb.head.Id];
    if (tb.head["=Name"] !== undefined) {
      const nm = spec.dict ? gdString(gd[spec.file], `${spec.dict}.${id}.name`) : name === "round_makeup" ? gdString(gd.Enemies, `ENEMIES.${id}.name`) : undefined;
      c[tb.head["=Name"]] = nm ?? "?";
    }
    if (name === "enemies") {
      if (tb.head["=Strength"] !== undefined) c[tb.head["=Strength"]] = f1(strength(id));
      if (tb.head["=Leak"] !== undefined) c[tb.head["=Leak"]] = String(leak(id));
    }
    lines[r.line] = rowLine(c);
  }
}
let out = lines.join("\n");

// Towers (phase 1): the tower tables' derived cells and the tower summary.
const towers = parseTowers(out, errors);
const names = parseTrees(trees);
function paperDps(s) {
  if (s.orbit !== undefined) {
    let d = (s.damage || 0) * (s.rate || 0);
    if (s.ac_damage) d += s.ac_damage * (s.ac_rate || 0);
    if (s.ms_damage) d += s.ms_damage * (s.ms_rate || 0) * ((s.ms_volley || 1) + 2) / 3;
    return d;
  }
  if (!s.damage) return null;
  if (s.ramp !== undefined) return s.damage * s.ramp * (1 + (s.beam_power ?? 0.4) * ((s.beams || 1) - 1));
  if (!s.rate) return null;
  let shots = 1;
  if (s.jumps !== undefined) { const keep = 1 - (s.falloff ?? 0.15); shots = 0; for (let k = 0; k <= s.jumps; k++) shots += Math.pow(keep, k); }
  else if (s.missiles) shots = s.missiles;
  else if ((s.multishot || 1) > 1) shots = s.multishot;
  else if (s.side_gun) shots = 1 + s.side_gun;
  else if (s.drones) shots = s.drones;
  return s.damage * s.rate * shots;
}
function derive(slug, t) {
  const o = {};
  const nm = Object.fromEntries((names[slug]?.rows || []).map((r) => [r.id, r.name]));
  const base = applyNode({}, t.nodes.base);
  o.base = { name: nm.base, dps: paperDps(base), spent: t.nodes.base.cost };
  for (const id of ["r1", "r2", "r3"]) if (t.nodes[id]) o[id] = { name: nm[id], dps: paperDps(applyNode(base, t.nodes[id])), spent: t.nodes.base.cost + t.nodes[id].cost };
  for (const k of "abc") {
    let s = base, spent = t.nodes.base.cost;
    for (const id of [k + "1", k + "2", k + "3", k + "4", k + "m"]) { s = applyNode(s, t.nodes[id]); spent += t.nodes[id].cost; o[id] = { name: nm[id], dps: paperDps(s), spent }; }
  }
  return o;
}
const derived = {};
for (const slug in towers) { if (!names[slug]) errors.push(`${slug}: not in upgrade_trees_rework.md`); derived[slug] = derive(slug, towers[slug]); }
{
  let cur = "", inTowers = false, col = null;
  out = out.split("\n").map((line) => {
    if (line.startsWith("## ")) inTowers = line === "## Towers";
    if (inTowers && line.startsWith("### ")) cur = line.slice(4).trim().split(/\s/)[0];
    if (inTowers && /^\| Node \|/.test(line)) col = Object.fromEntries(cells(line).map((h, i) => [h, i]));
    const c = cells(line);
    if (!(inTowers && col && line.startsWith("|") && NODE_IDS.includes(c[col.Node]) && derived[cur]?.[c[col.Node]])) return line;
    const d = derived[cur][c[col.Node]];
    if (col["=Name"] !== undefined) c[col["=Name"]] = d.name || "?";
    if (col["=DPS"] !== undefined) c[col["=DPS"]] = f1(d.dps);
    if (col["=Spent"] !== undefined) c[col["=Spent"]] = String(d.spent);
    if (col["=DPS/100cr"] !== undefined) c[col["=DPS/100cr"]] = d.dps === null ? "-" : f2((d.dps / d.spent) * 100);
    return rowLine(c);
  }).join("\n");
}

// Generated blocks: <!-- generated: name --> ... <!-- /generated: name -->, filled only where balance.md has the markers.
const ROUNDS = [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 140, 160];
const HP_ROUNDS = [20, 40, 60, 80, 100, 120];
const enemyIds = gdDictKeys(gd.Enemies, "ENEMIES");
const ename = (id) => gdString(gd.Enemies, `ENEMIES.${id}.name`);
const tname = (slug) => names[slug]?.name || slug;
const BLOCKS = {
  tower_summary: () => ["| Tower | Stock cr | Stock =DPS | A mastery: cr / =DPS | B mastery: cr / =DPS | C mastery: cr / =DPS |", "|---|---|---|---|---|---|",
    ...Object.keys(derived).map((s) => rowLine([tname(s), String(derived[s].base.spent), f1(derived[s].base.dps), ...["am", "bm", "cm"].map((m) => `${derived[s][m].spent} / ${f1(derived[s][m].dps)}`)]))],
  enemy_scaling: () => [`| Enemy | ${HP_ROUNDS.map((r) => `=HP r${r}`).join(" | ")} | ${[20, 60, 100].map((r) => `=Credits r${r}`).join(" | ")} |`, `|---|${HP_ROUNDS.map(() => "---|").join("")}---|---|---|`,
    ...enemyIds.map((id) => rowLine([ename(id), ...HP_ROUNDS.map((r) => f0(E(id, "hp") * hpScale(r))), ...[20, 60, 100].map((r) => f1(E(id, "bounty") * bountyScale(r)))]))],
  round_table: () => ["| Round | =HP × | =Speed × | =Boss speed × | =Budget | =Elite share | =Bounty × | =Clear bonus | =Early-call bonus |", "|---|---|---|---|---|---|---|---|---|",
    ...ROUNDS.map((r) => rowLine([String(r), f2(hpScale(r)), f2(speedScale(r, false)), f2(speedScale(r, true)), f1(budget(r)), `${Math.round(eliteShare(r) * 100)}%`, f2(bountyScale(r)),
      String(W("CLEAR_BASE") + W("CLEAR_PER_ROUND") * r), String(W("CALL_BASE") + W("CALL_PER_ROUND") * r)]))],
  mode_prices: () => {
    const modes = gdDictKeys(gd.Difficulty, "DIFFICULTIES");
    return [`| Tower | ${modes.map((m) => `=${gdString(gd.Difficulty, `DIFFICULTIES.${m}.name`)}`).join(" | ")} |`, `|---|${modes.map(() => "---|").join("")}`,
      ...Object.keys(towers).map((s) => rowLine([tname(s), ...modes.map((m) => String(Math.round(towers[s].nodes.base.cost * gdRead(gd.Difficulty, `DIFFICULTIES.${m}.price`))))]))];
  },
};
for (const [name, fn] of Object.entries(BLOCKS)) {
  const a = `<!-- generated: ${name} -->`, b = `<!-- /generated: ${name} -->`;
  const i = out.indexOf(a), j = out.indexOf(b);
  if (i < 0 && j < 0) continue;
  if (i < 0 || j < i) { errors.push(`balance.md: the ${name} markers are broken`); continue; }
  out = out.slice(0, i) + [a, "", ...fn(), "", b].join("\n") + out.slice(j + b.length);
}

// Mirror the tower prices into upgrade_trees_rework.md.
let slug = null;
const newTrees = trees.split("\n").map((line) => {
  const idm = line.match(/(?:^| )id: ([a-z_]+)(?: ·|$)/);
  if (idm && !line.startsWith("|")) { slug = idm[1]; const t = towers[slug]; return t ? line.replace(/build: \d+ cr/, `build: ${t.nodes.base.cost} cr`) : line; }
  const c = cells(line);
  if (slug && towers[slug] && c.length === 7 && /^(\d|M)$/.test(c[0])) {
    const n = towers[slug].nodes[nodeId(c[0], c[1])];
    if (!n) { errors.push(`${slug}: trees row ${c[0]} ${c[1]} has no node in balance.md`); return line; }
    c[3] = String(n.cost);
    return rowLine(c);
  }
  return line;
}).join("\n");

if (errors.length) { console.error(errors.join("\n")); process.exit(1); }
const changed = [];
if (out !== balance) changed.push(["design/balance.md", BALANCE, out]);
if (newTrees !== trees) changed.push(["design/upgrade_trees_rework.md", TREES, newTrees]);
for (const k in FILES) if (gd[k] !== orig[k]) changed.push([FILES[k], join(root, FILES[k]), gd[k]]);
if (CHECK) {
  if (changed.length) { console.error(`stale: ${changed.map((c) => c[0]).join(", ")}: run node tools/balance.mjs`); process.exit(1); }
  console.log("balance.md and the game's numbers agree");
} else {
  for (const [, file, text] of changed) save(file, text);
  console.log(changed.length ? `updated: ${changed.map((c) => c[0]).join(", ")}` : "everything was already current");
}
