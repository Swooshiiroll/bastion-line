// Assembles an editable design page: the page's render code plus the shared kit become one script,
// and the document is built by the kit's own buildDoc, the same function a Save in the page runs.
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const read = (f) => readFileSync(join(here, f), "utf8").replace(/\r\n/g, "\n");

export function buildPage(name, data) {
  const css = "\n" + read(`${name}.css`) + read("kit.css");
  const js = "\n(function () {\n" + read(`${name}.js`) + "\n" + read("kit.js") + "})();\n";
  if (/<\/script|<!--/i.test(js)) throw new Error(`${name}: the page script must not contain </script or <!--`);
  const page = new Function("PAGE_DATA", "return " + js.trim())(data);
  return page.buildDoc(data, css, js);
}
