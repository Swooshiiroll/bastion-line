// Checks a --perf-ci result against tests/perf_budget.json and prints a Markdown report.
// usage: node tools/perf_check.mjs <result.json> [--update]
//   Exits 1 if any gated count (draw calls, primitives, slow calls) is over its budget by more
//   than the tolerance. Timings (fps, ms) are machine-dependent: shown, never gated.
//   --update writes the result into the budget instead (after a deliberate change; commit it).
// Counts depend on the window size, so the budget records the viewport it was measured at; a
// result from a different viewport is reported but not gated (CI always uses the same one).
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const budgetPath = join(root, "tests", "perf_budget.json");
const [file, ...flags] = process.argv.slice(2);
const result = JSON.parse(readFileSync(file, "utf8"));
const GATED = ["draw_calls", "primitives", "slow_calls"];

if (flags.includes("--update")) {
  const budget = { tolerance: 0.1, slack: { slow_calls: 2 }, viewport: result.viewport, scenarios: {} };
  for (const s of result.scenarios) budget.scenarios[s.scenario] = Object.fromEntries(GATED.map((k) => [k, s[k]]));
  writeFileSync(budgetPath, JSON.stringify(budget, null, 2) + "\n");
  console.log(`Budget updated from ${file} (viewport ${result.viewport.join("x")}).`);
  process.exit(0);
}

const budget = existsSync(budgetPath) ? JSON.parse(readFileSync(budgetPath, "utf8")) : null;
const sameView = budget && JSON.stringify(budget.viewport) === JSON.stringify(result.viewport);
const lines = ["### Performance", "", `Viewport ${result.viewport.join("×")}, ${result.renderer}.` + (budget && !sameView ? ` **Budget was measured at ${budget.viewport.join("×")}: not gated.**` : ""), "",
  "| Scenario | Towers / enemies | Draw calls | Primitives | Slow calls | FPS | Towers ms | Enemies ms | Tick ms |", "|---|---|---|---|---|---|---|---|---|"];
let over = [];
for (const s of result.scenarios) {
  const b = budget?.scenarios?.[s.scenario];
  const cell = (k) => {
    if (!b) return `${s[k]}`;
    const limit = b[k] * (1 + budget.tolerance) + (budget.slack?.[k] ?? 0);
    const pct = b[k] ? Math.round((s[k] / b[k] - 1) * 100) : 0;
    const bad = s[k] > limit;
    if (bad && sameView) over.push(`${s.scenario}: ${k} ${s[k]} > ${Math.floor(limit)} (budget ${b[k]})`);
    return `${s[k]} (${pct >= 0 ? "+" : ""}${pct}%)${bad ? " ❌" : ""}`;
  };
  lines.push(`| ${s.scenario} | ${s.towers} / ${s.enemies} | ${cell("draw_calls")} | ${cell("primitives")} | ${cell("slow_calls")} | ${s.fps} | ${s.towers_ms} | ${s.enemies_ms} | ${s.tick_ms} |`);
}
lines.push("", budget ? `Gated: draw calls, primitives and slow calls may grow ${Math.round(budget.tolerance * 100)}% over \`tests/perf_budget.json\`. Timings depend on the machine and aren't gated.` : "No budget yet: run with --update to create one.");
if (over.length) lines.push("", "**Over budget:**", ...over.map((o) => `- ${o}`), "", "If the increase is intended, update the budget: `node tools/perf_check.mjs <result.json> --update` and commit it.");
console.log(lines.join("\n"));
process.exit(over.length ? 1 : 0);
