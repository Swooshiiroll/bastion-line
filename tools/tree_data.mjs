// Generates data/tower_trees.gd (every tower's upgrade tree as game data) from design/upgrade_trees.md.
// Run: node tools/tree_data.mjs   (from the project folder). Exits non-zero if a stat can't be read.
//
// Stat tokens are separated by " · ". On a specialization or mastery row every token sets a value.
// On branch upgrades 2-4, a token that starts with + or − adds to the value; one without a sign sets it.
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const src = readFileSync(join(root, "design", "upgrade_trees.md"), "utf8").replace(/\r\n/g, "\n");

const N = "(\\d+(?:\\.\\d+)?)";
const S = "([+−-]?)";
// [regex, handler(match, sign, out)] — handler writes key/value pairs via out(key, value, mode)
// where mode is "num" (add when signed on an upgrade), "abs" (always set) or "flag".
const PATTERNS = [
  [`^${S}${N} dmg × ${N}$`, (m, o) => { o("damage", +m[2], m[1]); o("pellets", +m[3], m[1]); }],
  [`^${S}${N} dmg per tick$`, (m, o) => o("damage", +m[2], m[1])],
  [`^${S}${N} (dmg bombs|bomb dmg)$`, (m, o) => o("bomb_damage", +m[2], m[1])],
  [`^${S}${N} (dmg|dps)$`, (m, o) => o("damage", +m[2], m[1])],
  [`^${S}${N} (range|field|radius)$`, (m, o) => o("range", +m[2], m[1])],
  [`^${S}${N}/s pulses$`, (m, o) => o("rate", +m[2], m[1])],
  [`^${S}${N} (shots|ticks)/s$`, (m, o) => o("rate", +m[2], m[1])],
  [`^${S}${N}/s$`, (m, o) => o("rate", +m[2], m[1])],
  [`^pulse every ${N} s$`, (m, o) => o("rate", 1 / +m[1], "=")],
  [`^${S}${N} (blast|burst)$`, (m, o) => o("splash", +m[2], m[1])],
  [`^${S}${N} bomblet blast$`, (m, o) => o("bomblet_splash", +m[2], m[1])],
  [`^${S}${N} bomblets \\(${N} blast\\)$`, (m, o) => { o("bomblets", +m[2], m[1]); o("bomblet_splash", +m[3], m[1]); }],
  [`^${S}${N} bomblets?$`, (m, o) => o("bomblets", +m[2], m[1])],
  [`^${S}${N}% slow$`, (m, o) => o("slow", +m[2] / 100, m[1])],
  [`^${S}${N} s slow duration$`, (m, o) => o("slow_time", +m[2], m[1])],
  [`^${S}${N} px shove$`, (m, o) => o("push", +m[2], m[1])],
  [`^${S}${N} px pull$`, (m, o) => o("pull", +m[2], m[1])],
  [`^${S}${N} chain range$`, (m, o) => o("chain_range", +m[2], m[1])],
  [`^${S}${N} chains?$`, (m, o) => o("chains", +m[2], m[1])],
  [`^${S}${N} missiles?$`, (m, o) => o("missiles", +m[2], m[1])],
  [`^${S}${N} beams?$`, (m, o) => o("beams", +m[2], m[1])],
  [`^${S}${N} flechettes?$`, (m, o) => o("pellets", +m[2], m[1])],
  [`^${S}${N} targets$`, (m, o) => o("multishot", +m[2], m[1])],
  [`^ramps to ${N}×$`, (m, o) => o("ramp", +m[1], "=")],
  [`^${S}${N} s ramp time$`, (m, o) => o("ramp_time", +m[2] * (m[1] === "−" || m[1] === "-" ? -1 : 1), "+")],
  [`^no ramp$`, (m, o) => o("ramp", 1.0, "=")],
  [`^${N}× vs bosses$`, (m, o) => o("boss_mult", +m[1], "=")],
  [`^${N}× vs flyers$`, (m, o) => o("air_mult", +m[1], "=")],
  [`^${N}× vs barriers$`, (m, o) => o("shield_mult", +m[1], "=")],
  [`^${S}${N} s stun$`, (m, o) => o("stun", +m[2], m[1])],
  [`^shred ${N} \\(max ${N}\\)$`, (m, o) => { o("shred", +m[1], "="); o("shred_max", +m[2], "="); }],
  [`^shred ${N}$`, (m, o) => { o("shred", +m[1], "="); o("shred_max", +m[1] * 6, "="); }],
  [`^shred max \\+${N}$`, (m, o) => o("shred_max", +m[1], "+")],
  [`^${S}${N} cr per round$`, (m, o) => o("income", +m[2], m[1])],
  [`^${N}% interest \\(max ${N}\\)$`, (m, o) => { o("interest", +m[1] / 100, "="); o("interest_cap", +m[2], "="); }],
  [`^${S}${N}% kill credits$`, (m, o) => o("bounty_bonus", +m[2] / 100, m[1])],
  [`^bosses pay double$`, (m, o) => o("boss_bounty", 2.0, "=")],
  [`^${S}${N}% off upgrades$`, (m, o) => o("discount", +m[2] / 100, m[1])],
  [`^${N}% sell refund$`, (m, o) => o("sell_field", +m[1] / 100, "=")],
  [`^${S}${N}% damage after ${N} s inside$`, (m, o) => o("static_vuln", +m[2] / 100, m[1])],
  [`^${S}${N}% damage taken$`, (m, o) => o("vuln", +m[2] / 100, m[1])],
  [`^${S}${N}% damage$`, (m, o) => o("buff_dmg", +m[2] / 100, m[1])],
  [`^${S}${N}% speed$`, (m, o) => o("buff_rate", +m[2] / 100, m[1])],
  [`^${S}${N}% range$`, (m, o) => o("buff_range", +m[2] / 100, m[1])],
  [`^${S}${N}% mark$`, (m, o) => o("mark", +m[2] / 100, m[1])],
  [`^marks \\+${N}%$`, (m, o) => o("mark", +m[1] / 100, "=")],
  [`^${N}% vs ground$`, (m, o) => o("ground_mult", +m[1] / 100, "=")],
  [`^${S}${N} drones?$`, (m, o) => o("drones", +m[2], m[1])],
  [`^${S}${N} bombers?$`, (m, o) => o("bombers", +m[2], m[1])],
  [`^${S}${N} speed$`, (m, o) => o("drone_speed", +m[2], m[1])],
  [`^${S}${N} burn/s for ${N} s$`, (m, o) => { o("burn_dps", +m[2], m[1]); o("burn_time", +m[3], m[1]); }],
  [`^${S}${N} burn/s aura$`, (m, o) => o("aura_dps", +m[2], m[1])],
  [`^${S}${N} burn/s$`, (m, o) => o("burn_dps", +m[2], m[1])],
  [`^${S}${N} s burn$`, (m, o) => o("burn_time", +m[2], m[1])],
  [`^crossed enemies burn ${N} dps for ${N} s$`, (m, o) => { o("burn_dps", +m[1], "="); o("burn_time", +m[2], "="); }],
  [`^${S}${N}° cone$`, (m, o) => o("cone", +m[2], m[1])],
  [`^${S}${N}° (sweep|arc)$`, (m, o) => o("sweep", +m[2], m[1])],
  [`^sweeps ${N}% faster$`, (m, o) => o("sweep_speed", +m[1] / 100, "+")],
  [`^extra beams at ${N}%$`, (m, o) => o("secondary_beam", +m[1] / 100, "=")],
  [`^${N} px line$`, (m, o) => o("rail_width", +m[1], "=")],
  [`^[−-]${N} armor for ${N} s$`, (m, o) => { o("armor_break", +m[1], "="); o("armor_break_time", +m[2], "="); }],
  [`^[−-]${N} more armor$`, (m, o) => o("armor_break", +m[1], "+")],
  [`^[−-]${N} armor inside$`, (m, o) => o("armor_field", +m[1], "=")],
  [`^${S}${N} s suppression$`, (m, o) => o("suppress", +m[2], m[1])],
  [`^${N} px spread$`, (m, o) => o("suppress_spread", +m[1], "=")],
  [`^suppression splashes ${N} px$`, (m, o) => o("suppress_spread", +m[1], "=")],
  [`^suppression lingers ${N} s$`, (m, o) => o("linger", +m[1], "=")],
  [`^(?:lock lasts|cloaks stay revealed|marks last) ${N} s after leaving$`, (m, o) => o("linger", +m[1], "=")],
  [`^strips ${N}% of barriers$`, (m, o) => o("strip", +m[1] / 100, "=")],
  [`^strips barrier$`, (m, o) => o("strip", 1.0, "=")],
  [`^returns ${N}% of the stripped barrier$`, (m, o) => o("feedback", +m[1] / 100, "=")],
  [`^cascades ${N}% in ${N} px$`, (m, o) => { o("cascade", +m[1] / 100, "="); o("cascade_radius", +m[2], "="); }],
  [`^${N} px mini-novas$`, (m, o) => o("mini_nova", +m[1], "=")],
  [`^implodes every ${N}(?:st|nd|rd|th) pulse for ${N}% max HP$`, (m, o) => { o("implode_every", +m[1], "="); o("implode_pct", +m[2] / 100, "="); }],
  [`^enemies inside move ${N}% slower$`, (m, o) => o("field_slow", +m[1] / 100, "=")],
  [`^drops ${N}% more often$`, (m, o) => o("rate_pct", +m[1] / 100, "+")],
  [`^unearths for ${N} s$`, (m, o) => o("unearth", +m[1], "=")],
  [`^suppresses bosses at half$`, (m, o) => o("suppress_boss", 0.5, "=")],
  [`^jams support$`, (m, o) => o("jam", 1, "=")],
  [`^jams everything$`, (m, o) => o("jam", 2, "=")],
  ...[
    ["hits burrowed", "hits_burrowed"], ["blocks repair", "block_repair"], ["blocks barrier recharge", "block_barrier"],
    ["blocks barrier grants", "block_grants"], ["exposes", "expose"], ["pierces armor", "pierce"],
    ["bypasses barriers", "bypass_shield"], ["disrupts", "disrupt"], ["suppresses abilities inside", "dampen"],
    ["also hunts Phantoms and Gunships first", "hunt_extra"], ["ground only", "ground_only"],
    ["hunts specialists", "hunt"], ["suppresses target", "suppress_hit"],
  ].map(([phrase, key]) => [`^${phrase}$`, (m, o) => o(key, true, "flag")]),
].map(([re, fn]) => [new RegExp(re), fn]);

function parseStats(text, isStep, where, errors) {
  const set = {};
  const add = {};
  for (const tok of text.split("·").map((s) => s.trim()).filter(Boolean)) {
    let hit = false;
    for (const [re, fn] of PATTERNS) {
      const m = tok.match(re);
      if (!m) continue;
      hit = true;
      fn(m, (key, value, mode) => {
        const signed = mode === "+" || mode === "−" || mode === "-";
        if (mode === "flag" || mode === "=" || !isStep || !signed) {
          set[key] = value;
        } else {
          add[key] = (add[key] || 0) + (mode === "+" ? value : -value);
        }
      });
      break;
    }
    if (!hit) errors.push(`${where}: can't read "${tok}"`);
  }
  return { set, add };
}

// --- Read the design file ---------------------------------------------------------------------
const towers = [];
let cur = null;
for (const line of src.split("\n")) {
  if (line.startsWith("## ")) { cur = { name: line.slice(3).trim(), meta: {}, rows: [] }; towers.push(cur); continue; }
  if (!cur) continue;
  if (/^[a-z]+:/.test(line) && line.includes("·")) {
    for (const part of line.split("·")) {
      const m = part.trim().match(/^([a-z]+):\s*(.+)$/);
      if (m) cur.meta[m[1]] = m[2].trim();
    }
  } else if (line.startsWith("|")) {
    const c = line.split("|").slice(1, -1).map((s) => s.trim());
    if (c.length < 7 || c[0] === "Tier" || /^-+$/.test(c[0])) continue;
    cur.rows.push({ tier: c[0].toUpperCase(), path: c[1].toLowerCase(), name: c[2], cost: parseInt(c[3], 10) || 0, stats: c[4], blurb: c[5] });
  }
}

const errors = [];
const out = [];
for (const t of towers.filter((t) => t.rows.length)) {
  const id = t.meta.id;
  const ids = (t.meta.branches || "").split(",").map((s) => s.trim());
  const attack = (t.meta.attack || "").toLowerCase().split(/[^a-c]+/).filter(Boolean);
  const row = (tier, path) => t.rows.find((r) => r.tier === tier && r.path === path);
  const node = (r, isStep) => {
    if (!r) return null;
    const { set, add } = parseStats(r.stats, isStep, `${t.name} ${r.path} ${r.tier}`, errors);
    return { name: r.name, cost: r.cost, blurb: r.blurb, set, add };
  };
  const tiers = [node(row("1", "base"), false), node(row("2", "base"), false)];
  const branches = ["a", "b", "c"].map((p, i) => ({
    key: p, id: ids[i] || `${id}_${p}`, attack: attack.includes(p),
    nodes: ["3", "4", "5", "6"].map((tier, k) => node(row(tier, p), k > 0)),
    mastery: node(row("M", p), false),
  }));
  for (const b of branches) {
    if (b.nodes.some((n) => !n) || !b.mastery) errors.push(`${t.name}: branch ${b.key} is incomplete`);
  }
  if (tiers.some((n) => !n)) errors.push(`${t.name}: trunk is incomplete`);
  out.push({ id, key: t.meta.key || "", name: t.name, tiers, branches });
}

if (errors.length) {
  console.error(errors.join("\n"));
  process.exit(1);
}

// --- Write GDScript ---------------------------------------------------------------------------
const gd = (v, ind = "") => {
  if (v === null || v === undefined) return "null";
  if (typeof v === "boolean") return v ? "true" : "false";
  if (typeof v === "number") return Number.isInteger(v) ? `${v}.0` : String(Math.round(v * 10000) / 10000);
  if (typeof v === "string") return JSON.stringify(v);
  if (Array.isArray(v)) return `[\n${v.map((x) => `${ind}\t${gd(x, ind + "\t")},`).join("\n")}\n${ind}]`;
  const keys = Object.keys(v);
  if (!keys.length) return "{}";
  return `{\n${keys.map((k) => `${ind}\t${JSON.stringify(k)}: ${k === "cost" ? String(v[k]) : gd(v[k], ind + "\t")},`).join("\n")}\n${ind}}`;
};
const body = {};
for (const t of out) body[t.id] = { name: t.name, key: t.key, tiers: t.tiers, branches: t.branches };
const text = `extends RefCounted
## GENERATED by tools/tree_data.mjs from design/upgrade_trees.md. Edit the design file and re-run
## the generator; don't edit this file by hand.
##
## Per tower: \`tiers\` (the trunk) and three \`branches\` (a, b, c). Each branch has four \`nodes\`
## (the first is the specialization) and a \`mastery\`. A node's \`set\` values replace the stat and
## its \`add\` values add to it. The specialization and mastery only use \`set\`.

const ORDER := ${JSON.stringify(out.map((t) => t.id)).replace(/,/g, ", ")}

const TREES := ${gd(body)}
`;
writeFileSync(join(root, "data", "tower_trees.gd"), text);
console.log(`Wrote data/tower_trees.gd: ${out.length} towers, ${out.length * 17} nodes.`);
