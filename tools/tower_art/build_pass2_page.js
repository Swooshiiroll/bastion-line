// usage: node build_pass2_page.js <base data.js> <pass2 data.js> <out.html> <eyebrow> <h1>
// The confirmed base design's data is wrapped in its own scope (BASE) so its PAGE/TOWERS don't clash with this page's.
const fs = require("fs");
const [base, data, out, eyebrow, h1] = process.argv.slice(2);
const rd = (f) => fs.readFileSync(f, "utf8");
const code = [
  rd(__dirname + "/prims_block.js"),
  rd(__dirname + "/game_style.js"),
  "const BASE = (() => {\n" + rd(base) + "\nreturn { TOWERS };\n})();",
  "const NO_BOOT = true;",
  rd(data),
  rd(__dirname + "/tower_engine.js"),
  rd(__dirname + "/pass2_engine.js"),
].join("\n");
if (/<\/script/i.test(code)) throw new Error("script contains </script");
let t = rd(__dirname + "/pass2_template.html");
t = t.replace("__TITLE__", "Tower Art: " + h1.replace(/^Tower art: /, "")).replace("__EYEBROW__", eyebrow).replace("__H1__", h1).replace("/*__CODE__*/", () => code);
fs.writeFileSync(out, t);
console.log("written", out, t.length);
