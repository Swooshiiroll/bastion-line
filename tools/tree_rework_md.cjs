// Run: node tools/tree_rework_md.cjs .   (regenerates design/upgrade_trees_rework.md from design/tower_roster.md)
// Builds design/upgrade_trees_rework.md (the editable trees page's source) from design/tower_roster.md.
// Rows: Tier | Path | Name | Cost | Stats | Effect | Status. Tier 1 base = stock; tier 2 r1-r3 = Retrofit options;
// tiers 3-6 = steps 1-4 of paths A-C; M = mastery.
const fs = require("fs"); const root = process.argv[2];
const s = fs.readFileSync(root + "/design/tower_roster.md", "utf8").replace(/\r\n/g, "\n");
const costs = { 1: 75, 2: 150, 3: 250, 4: 200, 5: 150, 6: 300, 7: 500, 8: 250, 9: 300, 10: 650, 11: 450, 12: 250, 13: 400, 14: 575, 15: 150, 16: 450, 17: 875, 18: 525, 19: 575, 20: 650 };
const clean = (x) => x.replace(/\*\*/g, "").replace(/\s*\n\s*/g, " ").replace(/\|/g, "/").replace(/\s+/g, " ").trim();
const num = (x) => parseInt(String(x).replace(/[^\d]/g, ""), 10) || 0;
let out = `# Bastion Line Upgrade Trees: tower rework

The 20 reworked towers' upgrade trees, built from \`design/tower_roster.md\` (issue #55) for the editable trees page.
Not game data: today's trees stay in \`design/upgrade_trees.md\` until the rework is implemented. Edits made on the page
come back here with \`tools/design_pull.mjs\`; carry them into \`design/tower_roster.md\` too.

## Rules

- Each tower has three paths of four upgrades and a mastery. Climb up to two paths, up to two upgrades each; the 3rd upgrade on either makes it the primary, which goes on to its mastery, and the other is capped at 2 with its full effects. The third path is locked. Masteries need the tower's Mastery research.
- The CAS Gunship is the exception: each path is one gun (its step 1 unlocks it; the light gun is built in), and all three paths are uncapped to their masteries.
- The Retrofit is an optional upgrade off to the side: the player picks one of three options when buying it, and the choice is locked. The Drone Bay has a single Retrofit.
- Prices come from the value formula in \`design/towers.md\` (Pricing), rounded to 5s and 0s, with the owner's overrides. Every number is a first pass for the balance probe.
`;
for (let n = 1; n <= 20; n++) {
  const a = s.indexOf(`\n## ${n}. `), b = s.indexOf("\n## ", a + 5);
  const g = s.slice(a + 1, b);
  const name = g.match(/^## \d+\. (.+)$/m)[1].replace(/ \(was .*\)$/, "").trim();
  const cls = g.match(/\*\*Class:\*\* ([^.]+)\./)[1].trim();
  const wpn = g.match(/\*\*Weapon type:\*\* ([^.]+)\./)[1].trim();
  const desc = clean((g.match(/\*\*Description[^:]*:\*\* ([\s\S]*?)\n- \*\*Paths/) || [, ""])[1]);
  const stock = clean((g.match(/\*\*Stock[^:]*:\*\* ([\s\S]*?)\n\n/) || [, ""])[1]);
  const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_|_$/g, "");
  // Path names and tables, in order.
  const pathHeads = [...g.matchAll(/^\*\*Path (\d), ([^*]+?):\*\*\n\n((?:\|.*\n?)+)/gm)];
  if (pathHeads.length !== 3) throw new Error(name + ": paths " + pathHeads.length);
  const branches = pathHeads.map((m) => m[2].trim()).join(", ");
  out += `\n## ${name}\nid: ${slug} · class: ${cls} · weapon: ${wpn} · build: ${costs[n]} cr · status: new · branches: ${branches}\n${desc}\n\n`;
  out += "| Tier | Path | Name | Cost | Stats | Effect | Status |\n|---|---|---|---|---|---|---|\n";
  out += `| 1 | base | ${name} | ${costs[n]} |  | ${stock} | new |\n`;
  // Retrofit options.
  const ri = g.indexOf("\n**Retrofit"), rj = g.indexOf("\n\n", ri + 2), rb = g.slice(ri, rj);
  const noLook = (x) => x.replace(/\s*Look:[\s\S]*$/, "");
  const opts = [...rb.matchAll(/^- \*\*([^,*]+), ([\d,]+)[^*]*:\*\* ([\s\S]*?)(?=\n- \*\*|(?![\s\S]))/gm)];
  if (opts.length) opts.forEach((m, i) => { out += `| 2 | r${i + 1} | ${m[1].trim()} | ${num(m[2])} |  | ${clean(noLook(m[3]))} | new |\n`; });
  else { const m = rb.match(/\*\*Retrofit, ([^,]+), ([\d,]+)[^*]*\*\* ([\s\S]*)/); out += `| 2 | r1 | ${m[1].trim()} | ${num(m[2])} |  | ${clean(noLook(m[3]))} | new |\n`; }
  pathHeads.forEach((m, pi) => {
    const p = "abc"[pi];
    const rows = m[3].trim().split("\n").filter((l) => /^\| (\d|Mastery|3 \(primary\))/.test(l));
    rows.forEach((l) => {
      const c = l.split("|").slice(1, -1).map((x) => x.trim());
      const step = c[0].startsWith("Mastery") ? "M" : String(parseInt(c[0], 10) + 2);
      out += `| ${step} | ${p} | ${c[1]} | ${num(c[2])} |  | ${clean(c[3])} | new |\n`;
    });
  });
}
out = out.replace(/(\| {2}\| )([a-z])/g, (m, a, b) => a + b.toUpperCase());
fs.writeFileSync(root + "/design/upgrade_trees_rework.md", out);
console.log("ok");
