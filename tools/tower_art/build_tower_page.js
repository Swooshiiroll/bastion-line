// usage: node build_tower_page.js <data.js> <out.html> <eyebrow> <h1>
const fs = require("fs");
const [data, out, eyebrow, h1] = process.argv.slice(2);
const prims = fs.readFileSync(__dirname + "/prims_block.js", "utf8");
const code = prims + "\n" + fs.readFileSync(data, "utf8") + "\n" + fs.readFileSync(__dirname + "/tower_engine.js", "utf8");
if (/<\/script/i.test(code)) throw new Error("script contains </script");
let t = fs.readFileSync(__dirname + "/tower_template.html", "utf8");
t = t.replace("__TITLE__", "Tower Art: " + h1.replace(/^Tower art: /, "")).replace("__EYEBROW__", eyebrow).replace("__H1__", h1).replace("/*__CODE__*/", () => code);
fs.writeFileSync(out, t);
console.log("written", out, t.length);
