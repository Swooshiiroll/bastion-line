// Shared readers for design/balance.md (the balance master, issue #75) and design/upgrade_trees_rework.md (tower names
// and blurbs). Used by tools/balance.mjs (derived columns, price mirror) and tools/tree_rework_data.mjs (game data).
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

export const root = join(dirname(fileURLToPath(import.meta.url)), "..");
export const BALANCE = join(root, "design", "balance.md");
export const TREES = join(root, "design", "upgrade_trees_rework.md");
export const read = (f) => readFileSync(f, "utf8").replace(/\r\n/g, "\n");

// The tower stat keys the game understands. A new mechanic adds its key here (and its handler in the game).
export const KEYS = new Set([
  "damage", "range", "rate", "proj_speed", "armor_flat", "armor_pct", "crit", "tracers", "stun_chance", "stun_time",
  "ignite_dps", "ignite_time", "swivel", "side_gun", "multishot", "weakest_extra",
  "splash", "tubes", "burrow_sight", "smoke_every", "smoke_slow", "smoke_time", "bomblets", "bomblet_damage", "bomblet_splash", "bomblet_spread",
  "missiles", "air_mult", "ground_burn", "ground_burn_time", "homing", "retarget", "never_miss", "ripple",
  "ramp", "ramp_time", "melt", "beams", "beam_power", "ramp_keep", "burst", "barrels", "turn_fast",
  "flight", "scatter", "heavy_every", "incendiary", "shrapnel", "concussion", "combined", "burn_dps", "burn_time", "shrap_radius", "shrap_mult", "barrage",
  "falloff", "boss_mult", "rails", "shatter", "trail_dps", "trail_time", "jumps", "jump_range", "overload", "storm_radius", "storm_dps", "storm_time",
  "lo_missiles", "lo_bombs", "lo_laser", "lo_full", "loadout_mult", "drones", "orbit", "radar", "rate_mult", "ac_damage", "ac_rate", "ac_splash", "ms_damage", "ms_rate", "ms_splash", "ms_volley", "cap", "gel_slow", "gel_time", "soak_time", "armor_strip", "constant_spray", "mist", "acid_perm", "acid_dps", "slow", "slow_time", "perm_slow", "freeze_every", "freeze_time", "cold_front", "buff_dmg", "buff_rate", "buff_range", "buff_extra", "crit_link", "ping_every", "reveal_time", "early_warning", "rad_dps", "rad_range", "constant", "unmask_decoy", "unmask_mask", "unmask_mirage", "exposure", "shield_mult", "shatter_half", "regen_block", "income", "sell_field", "interest", "interest_cap", "bounty_bonus", "boss_bounty", "discount", "build_discount", "pole_shoes", "grip_relief", "armor_pull", "pull_perm", "flip_every", "flip_damage", "hold", "pull", "recharge", "beam_slow", "rewind", "undo", "grip_dps", "slam_radius", "slam_stun", "grip_lock", "slam_shatter", "aug_crit", "crit_mult", "remote_link", "energy_conv", "energy_bonus", "ricochet", "ricochet_str", "bounce_again",
]);
export const FLAGS = new Set(["tracers", "swivel", "weakest_extra", "homing", "retarget", "never_miss", "ripple", "turn_fast", "incendiary", "shrapnel", "concussion", "combined", "overload", "lo_missiles", "lo_bombs", "lo_laser", "lo_full", "radar", "constant_spray", "mist", "acid_perm", "cold_front", "early_warning", "constant", "unmask_decoy", "unmask_mask", "unmask_mirage", "shatter_half", "pull_perm", "undo", "grip_lock", "slam_shatter", "remote_link", "bounce_again"]);
// Every tower's node ids, in table order.
export const NODE_IDS = ["base", "r1", "r2", "r3", ..."abc".split("").flatMap((k) => [k + "1", k + "2", k + "3", k + "4", k + "m"])];

export const cells = (line) => line.split("|").slice(1, -1).map((c) => c.trim());
export const rowLine = (c) => "| " + c.join(" | ") + " |";

// The "## Towers" section of balance.md: { slug: { meta, nodes: { id: { cost, tokens, set, add } } } }. A table's columns are
// found by its header row, so derived (=) columns can sit anywhere.
export function parseTowers(text, errors) {
  const towers = {};
  const sec = section(text, "Towers");
  if (sec === null) { errors.push("balance.md: no ## Towers section"); return towers; }
  for (const part of sec.split(/\n### /).slice(1)) {
    const lines = part.split("\n");
    const slug = lines[0].trim().split(/\s/)[0];
    const meta = {};
    const ml = lines.find((l) => /^air: /.test(l));
    if (!ml) { errors.push(`${slug}: no meta line (air · ground · size · damage_kind)`); continue; }
    for (const p of ml.split(" · ")) { const [k, v] = p.split(": "); meta[k.trim()] = v.trim(); }
    const head = lines.find((l) => /^\| Node \|/.test(l));
    if (!head) { errors.push(`${slug}: no node table`); continue; }
    const col = Object.fromEntries(cells(head).map((h, i) => [h, i]));
    const nodes = {};
    for (const line of lines) {
      const c = cells(line);
      if (!line.startsWith("|") || !NODE_IDS.includes(c[col.Node])) continue;
      const id = c[col.Node];
      const cost = parseInt(c[col.Cost], 10);
      if (!(cost >= 0)) errors.push(`${slug} ${id}: cost "${c[col.Cost]}" isn't a number`);
      const set = {}, add = {};
      for (const tok of c[col.Tokens].split(" · ")) {
        const t = tok.trim().match(/^([a-z_]+)(?: ([+-]?\d+(?:\.\d+)?))?$/);
        if (!t) { errors.push(`${slug} ${id}: can't read "${tok}"`); continue; }
        const [, key, val] = t;
        if (!KEYS.has(key)) { errors.push(`${slug} ${id}: unknown key "${key}"`); continue; }
        if (val === undefined) { if (!FLAGS.has(key)) errors.push(`${slug} ${id}: "${key}" needs a value`); set[key] = true; continue; }
        if (FLAGS.has(key)) { errors.push(`${slug} ${id}: "${key}" is a flag`); continue; }
        // Upgrades add (#85): only the stock row sets a number.
        if (id !== "base" && !/^[+-]/.test(val)) { errors.push(`${slug} ${id}: "${key} ${val}" needs a sign: upgrades add (+${val} or -${val})`); continue; }
        if (/^[+-]/.test(val)) add[key] = parseFloat(val); else set[key] = parseFloat(val);
      }
      nodes[id] = { cost, tokens: c[col.Tokens], set, add };
    }
    for (const id of NODE_IDS) if (!nodes[id] && !/^r[23]$/.test(id)) errors.push(`${slug}: node ${id} is missing`);
    towers[slug] = { meta, nodes };
  }
  return towers;
}

// A "## Title" section's text (to the next "## "), or null.
export function section(text, title) {
  const i = text.indexOf(`\n## ${title}\n`);
  if (i < 0) return null;
  const j = text.indexOf("\n## ", i + 4);
  return text.slice(i, j < 0 ? text.length : j);
}

// upgrade_trees_rework.md: { slug: { name, cls, weapon, branches: [names], blurb, rows: [{ id, tier, path, name, effect }] } }.
export function parseTrees(text) {
  const out = {};
  for (const sec of text.split(/\n## /).slice(1)) {
    const lines = sec.split("\n");
    const h = {};
    for (const part of (lines[1] || "").split(" · ")) { const i = part.indexOf(": "); if (i > 0) h[part.slice(0, i)] = part.slice(i + 2); }
    if (!h.id) continue;
    const branches = (h.branches || "").split(/, (?![^(]*\))/).map((b) => b.replace(/\s*\(.*\)$/, "").trim());
    const rows = [];
    for (const line of lines) {
      const c = cells(line);
      if (c.length === 7 && /^(\d|M)$/.test(c[0])) rows.push({ id: nodeId(c[0], c[1]), tier: c[0], path: c[1], name: c[2], effect: c[5] });
    }
    out[h.id] = { name: lines[0].trim(), cls: h.class, weapon: h.weapon, branches, blurb: (lines[2] || "").trim(), rows };
  }
  return out;
}

// A trees-doc row's node id: base, r1-r3, a1-a4 (tiers 3-6), am (M).
export function nodeId(tier, path) {
  if (path === "base") return "base";
  if (/^r\d$/.test(path)) return path;
  return path + (tier === "M" ? "m" : String(parseInt(tier, 10) - 2));
}

// A node applied on top of stats: add, then set (as Tower._apply_node).
export function applyNode(stats, n) {
  const out = { ...stats };
  for (const k in n.add) out[k] = (out[k] || 0) + n.add[k];
  for (const k in n.set) out[k] = n.set[k];
  return out;
}

// --- GDScript number literals owned by balance.md -------------------------------------------------------------------
// A path names a literal in a .gd source: "NAME" is `const NAME := 5` or `static var NAME := 0.3`; "NAME.a.b" walks into
// `const NAME := {...}` by keys ("a": or 20:) and array indices (0, 1...), ending on a number literal.
const NUM = /^-?\d+(?:\.\d+)?(?:e[-+]?\d+)?/;

// Skips a string or a comment starting at i; returns the index after it (or i if neither).
function skip(src, i) {
  const ch = src[i];
  if (ch === '"') { i++; while (i < src.length && src[i] !== '"') i += src[i] === "\\" ? 2 : 1; return i + 1; }
  if (ch === "#") { while (i < src.length && src[i] !== "\n") i++; return i; }
  return i;
}
function closing(src, open) {
  let d = 0;
  for (let i = open; i < src.length; ) {
    const j = skip(src, i);
    if (j !== i) { i = j; continue; }
    const ch = src[i];
    if ("{[(".includes(ch)) d++;
    else if ("}])".includes(ch) && --d === 0) return i;
    i++;
  }
  return -1;
}
// Within the container opening at `open`, the index where the value of key `key` (or array element `key`) starts.
function member(src, open, key) {
  const close = closing(src, open);
  const isArr = src[open] === "[";
  let d = 0, idx = 0, atItem = true;
  const lit = /^\d+$/.test(key) ? `${key}:` : `"${key}":`;
  for (let i = open + 1; i < close; ) {
    if (d === 0 && !isArr && src.startsWith(lit, i) && (lit[0] === '"' || /[\s{,]/.test(src[i - 1]))) {
      let k = i + lit.length;
      while (/\s/.test(src[k])) k++;
      return k;
    }
    const ch = src[i];
    if (d === 0 && isArr && atItem && !/\s/.test(ch) && ch !== "#") { if (String(idx) === key) return i; atItem = false; }
    const j = skip(src, i);
    if (j !== i) { i = j; continue; }
    if ("{[(".includes(ch)) d++;
    else if ("}])".includes(ch)) d--;
    else if (ch === "," && d === 0) { idx++; atItem = true; }
    i++;
  }
  return -1;
}
// The [start, end) span of the literal at `path`, or null.
export function gdSpan(src, path) {
  const segs = String(path).split(".");
  const top = new RegExp(`^(?:const|static var) ${segs[0]}(?:\\s*:\\s*\\w+)?\\s*:?=\\s*`, "m").exec(src);
  if (!top) return null;
  let at = top.index + top[0].length;
  for (const s of segs.slice(1)) {
    if (!"{[".includes(src[at])) return null;
    at = member(src, at, s);
    if (at < 0) return null;
  }
  const m = NUM.exec(src.slice(at));
  return m ? [at, at + m[0].length] : null;
}
// The string literal at `path` (e.g. "ENEMIES.grunt.name"), or undefined.
export function gdString(src, path) {
  const segs = String(path).split(".");
  const top = new RegExp(`^(?:const|static var) ${segs[0]}(?:\\s*:\\s*\\w+)?\\s*:?=\\s*`, "m").exec(src);
  if (!top) return undefined;
  let at = top.index + top[0].length;
  for (const s of segs.slice(1)) { if (!"{[".includes(src[at])) return undefined; at = member(src, at, s); if (at < 0) return undefined; }
  if (src[at] !== '"') return undefined;
  return JSON.parse(src.slice(at, skip(src, at)));
}
export function gdRead(src, path) {
  const sp = gdSpan(src, path);
  return sp ? parseFloat(src.slice(sp[0], sp[1])) : undefined;
}
// `src` with the literal at `path` set to `raw` (a number as typed in balance.md), keeping a float literal a float.
export function gdWrite(src, path, raw) {
  const sp = gdSpan(src, path);
  if (!sp) throw new Error(`no number at ${path}`);
  const old = src.slice(sp[0], sp[1]);
  if (Math.abs(parseFloat(old) - parseFloat(raw)) < 1e-12) return src;
  let lit = String(raw);
  if (/[.e]/.test(old) && !/[.e]/.test(lit)) lit += ".0";
  return src.slice(0, sp[0]) + lit + src.slice(sp[1]);
}
// The keys of the dictionary at `path` whose values are number literals (one level deep).
export function gdNumberKeys(src, path) {
  const segs = String(path).split(".");
  const top = new RegExp(`^(?:const|static var) ${segs[0]}(?:\\s*:\\s*\\w+)?\\s*:?=\\s*`, "m").exec(src);
  if (!top) return [];
  let at = top.index + top[0].length;
  for (const s of segs.slice(1)) { at = member(src, at, s); if (at < 0) return []; }
  if (src[at] !== "{") return [];
  const out = [];
  const close = closing(src, at);
  let d = 0;
  for (let i = at + 1; i < close; ) {
    const j = skip(src, i);
    if (j !== i) {
      if (d === 0 && src[i] === '"') {
        const k = src.slice(i + 1, j - 1);
        let v = j;
        if (src[v] === ":") { v++; while (/\s/.test(src[v])) v++; if (NUM.test(src.slice(v, v + 30))) out.push(k); }
      }
      i = j; continue;
    }
    if ("{[(".includes(src[i])) d++;
    else if ("}])".includes(src[i])) d--;
    i++;
  }
  return out;
}
// Every number literal inside the dictionary at `path`, as dotted sub-paths ("hp", "keys.shield_regen"), recursing into
// nested dictionaries (not arrays).
export function gdNumberPaths(src, path) {
  const out = [];
  for (const k of gdNumberKeys(src, path)) out.push(k);
  for (const k of gdDictChildren(src, path)) for (const sub of gdNumberPaths(src, `${path}.${k}`)) out.push(`${k}.${sub}`);
  return out;
}
// The keys of the dictionary at `path` whose values are themselves dictionaries.
function gdDictChildren(src, path) {
  const segs = String(path).split(".");
  const top = new RegExp(`^(?:const|static var) ${segs[0]}(?:\\s*:\\s*\\w+)?\\s*:?=\\s*`, "m").exec(src);
  if (!top) return [];
  let at = top.index + top[0].length;
  for (const s of segs.slice(1)) { at = member(src, at, s); if (at < 0) return []; }
  if (src[at] !== "{") return [];
  const out = [];
  const close = closing(src, at);
  let d = 0;
  for (let i = at + 1; i < close; ) {
    const j = skip(src, i);
    if (j !== i) {
      if (d === 0 && src[i] === '"' && src[j] === ":") {
        let v = j + 1;
        while (/\s/.test(src[v])) v++;
        if (src[v] === "{") out.push(src.slice(i + 1, j - 1));
      }
      i = j; continue;
    }
    if ("{[(".includes(src[i])) d++;
    else if ("}])".includes(src[i])) d--;
    i++;
  }
  return out;
}

// The top-level keys of the dictionary const `name`.
export function gdDictKeys(src, name) {
  const top = new RegExp(`^(?:const|static var) ${name}(?:\\s*:\\s*\\w+)?\\s*:?=\\s*\\{`, "m").exec(src);
  if (!top) return [];
  const open = top.index + top[0].length - 1, close = closing(src, open);
  const out = [];
  let d = 0;
  for (let i = open + 1; i < close; ) {
    const j = skip(src, i);
    if (j !== i) { if (d === 0 && src[i] === '"' && src[j] === ":") out.push(src.slice(i + 1, j - 1)); i = j; continue; }
    if ("{[(".includes(src[i])) d++;
    else if ("}])".includes(src[i])) d--;
    i++;
  }
  return out;
}
