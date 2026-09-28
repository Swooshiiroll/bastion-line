// ---- Upgrade trees page: renders every tower's tree from DATA (built from design/upgrade_trees.md).
var DATA = typeof PAGE_DATA !== "undefined" ? PAGE_DATA : JSON.parse(document.getElementById("page-data").textContent);
var PATHS = { a: "A", b: "B", c: "C" };

// A stat like "160 range" or "5.0/s" is a number plus a unit; "+10 range" is a bonus to that unit.
function num(s) {
  var m = s.match(/^([+−-]?)(\d+(?:\.\d+)?)\s*(.*)$/);
  if (!m) return null;
  return { v: parseFloat(m[2]) * (m[1] === "−" || m[1] === "-" ? -1 : 1), unit: m[3].trim(), signed: m[1] !== "" };
}
function fmt(v) { return String(Math.round(v * 100) / 100); }
function plusUnit(u) { return /^[\/%×°]/.test(u) ? u : " " + u; }

// What a specialization changes on top of the Retrofit when it's the secondary: shared stats change
// by their full difference, stats the Retrofit doesn't have are added as written.
function secondaryAdds(spec, t2) {
  var base = {};
  t2.stats.forEach(function (s) { var p = num(s); if (p && p.unit) base[p.unit] = p.v; });
  var out = [];
  spec.stats.forEach(function (s) {
    var p = num(s);
    if (p && p.unit && Object.prototype.hasOwnProperty.call(base, p.unit)) {
      var d = p.v - base[p.unit];
      if (Math.abs(d) > 1e-9) out.push((d > 0 ? "+" : "−") + fmt(Math.abs(d)) + plusUnit(p.unit));
    } else out.push(s);
  });
  return out;
}

function card(D, o, t, ti, n, color, adds) {
  if (!n) return '<div class="card missing">Not defined yet</div>';
  var ni = t.nodes.indexOf(n), P = "towers." + ti + ".nodes." + ni + ".";
  var isNew = n.status === "new" || n.status === "changed";
  var label = n.tier <= 2 ? (n.tier === 1 ? "Stock" : "Retrofit") : n.tier === 3 ? PATHS[n.path] + " · T1 · specialization" :
    n.tier === 8 ? PATHS[n.path] + " · mastery" : n.tier === 10 ? PATHS[n.path] + " · prestige" : PATHS[n.path] + " · T" + (n.tier - 2);
  var kind = n.tier === 10 ? "prestige" : n.tier === 8 ? "mastery" : n.tier === 3 ? "spec" : n.tier > 3 ? "step" : "trunk";
  var sec = "";
  if (adds === "attack") sec = '<div class="sec"><span class="sec-tag">As a secondary</span><p class="fx">Adds its attack alongside the primary\'s (see Combinations).</p></div>';
  else if (adds) sec = '<div class="sec"><span class="sec-tag">As a secondary</span><ul class="stats">' +
    (adds.length ? adds.map(function (s) { return '<li class="' + (s.charAt(0) === "−" ? "down" : "") + '">' + inline(s) + "</li>"; }).join("") : "<li>its effect only</li>") + "</ul></div>";
  return '<article class="card ' + kind + " " + (isNew ? "is-new" : "is-old") + " path-" + n.path + '" style="--tw:' + color + '">' +
    '<header><span class="tag">' + label + "</span>" + (isNew ? '<span class="new">' + esc(n.status) + "</span>" : "") +
    '<span class="cost"><span' + ed(D, P + "cost", "int") + ">" + n.cost + "</span> cr</span></header>" +
    field(D, o, "h4", "", P + "name", "text", n.name) +
    statList(D, o, P + "stats", n.stats) +
    (n.effect || o.editing ? field(D, o, "p", "fx", P + "effect", "text", n.effect) : "") +
    sec + (n.tier === 4 ? '<span class="cap">Secondary stops here</span>' : "") + "</article>";
}

function slug(s) { return String(s).toLowerCase().replace(/[^a-z0-9]+/g, "-"); }
function attackStyle(t) { return (t.meta.attack || "").toLowerCase().split(/[^a-c]+/).filter(Boolean); }
function pathTotal(t, p) { return t.nodes.filter(function (n) { return n.tier !== 10 && (n.path === "base" || n.path === p); }).reduce(function (a, n) { return a + n.cost; }, 0); }

function treeHtml(D, o, t, ti) {
  var color = D.accent[t.meta.id] || "#4de1ff";
  function find(tier, path) { return t.nodes.filter(function (n) { return n.tier === tier && n.path === path; })[0]; }
  var rows = ["a", "b", "c"].map(function (p, i) {
    return '<div class="fork r' + (i + 1) + '" aria-hidden="true"></div><div class="branch r' + (i + 1) + '">' +
      [3, 4, 5, 6, 8, 10].map(function (tier) {
        var adds = tier !== 3 || !find(3, p) || !find(2, "base") ? null : attackStyle(t).indexOf(p) >= 0 ? "attack" : secondaryAdds(find(3, p), find(2, "base"));
        return card(D, o, t, ti, find(tier, p), color, adds);
      }).join("") + "</div>";
  }).join("");
  var own = t.nodes.filter(function (n) { return n.tier !== 9; });
  var newCount = own.filter(function (n) { return n.status !== "existing"; }).length;
  return '<section class="tower" id="' + slug(t.meta.id || t.name) + '" style="--tw:' + color + '">' +
    '<header class="tower-head"><div class="tower-name"><span class="swatch"></span><h3>' + inline(t.name) + "</h3>" +
    ((t.meta.status || "") === "new" ? '<span class="new big">new tower</span>' : "") + "</div>" +
    field(D, o, "p", "role", "towers." + ti + ".role", "text", t.role) +
    '<dl class="meta">' + (t.meta.key ? "<div><dt>Key</dt><dd><kbd>" + esc(t.meta.key) + "</kbd></dd></div>" : "") +
    (t.meta.hits ? "<div><dt>Hits</dt><dd>" + esc(t.meta.hits) + "</dd></div>" : "") +
    "<div><dt>Maxed</dt><dd>" + ["a", "b", "c"].map(function (p) { return PATHS[p] + " " + pathTotal(t, p); }).join(" · ") + " cr</dd></div>" +
    "<div><dt>New nodes</dt><dd>" + newCount + " of " + own.length + "</dd></div></dl></header>" +
    '<div class="tree-scroll"><div class="tree"><div class="cell t1">' + card(D, o, t, ti, find(1, "base"), color) + '</div><div class="link base1" aria-hidden="true"></div>' +
    '<div class="cell t2">' + card(D, o, t, ti, find(2, "base"), color) + '</div><div class="link base2" aria-hidden="true"></div>' + rows + "</div></div></section>";
}

function panelHtml(D, o, p, pi) {
  var asks = /question/i.test(p.name);
  return '<div class="questions panel-' + slug(p.name).replace(/[^a-z-]/g, "") + '"><h2>' + inline(p.name) + "</h2><ul>" +
    p.bullets.map(function (b, bi) {
      return "<li>" + field(D, o, "span", "", "panels." + pi + ".bullets." + bi, "text", b) + (asks ? answerBox(D, o, "panels." + pi + ".answers." + bi) : "") + "</li>";
    }).join("") + "</ul></div>";
}

function renderPage(D, o) {
  o = o || {};
  var nodes = [];
  D.towers.forEach(function (t) { t.nodes.forEach(function (n) { if (n.tier !== 9) nodes.push(n); }); });
  var newNodes = nodes.filter(function (n) { return n.status === "new"; }).length;
  var changedNodes = nodes.filter(function (n) { return n.status === "changed"; }).length;
  var newTowers = D.towers.filter(function (t) { return t.meta.status === "new"; }).length;
  return '<div class="wrap"><div class="top"><span class="eyebrow">Bastion Line · design draft</span>' +
    "<h1>" + inline(D.title) + "</h1>" +
    '<p class="lede">Every tower\'s upgrade tree: a two-tier trunk, then three branches (A, B and the new C). Each branch is four upgrades, starting with the specialization you pick, and ends in a mastery and a prestige. A tower can also take the first two upgrades of one other branch as a secondary, with their full effects. Green marks new content. Built from <code>design/upgrade_trees.md</code>; use Edit (bottom right) to change names, costs, stats, descriptions and rules, and to answer the open questions.</p>' +
    '<div class="counts"><span><b>' + D.towers.length + "</b> towers</span><span><b>" + newTowers + "</b> new towers</span><span><b>" + D.towers.length * 3 + "</b> branches</span><span><b>" + nodes.length + "</b> upgrade nodes</span><span><b>" + newNodes + "</b> new nodes</span><span><b>" + changedNodes + "</b> changed</span></div>" +
    '<div class="legend"><span><i class="dot" style="background:var(--pa)"></i>Path A</span><span><i class="dot" style="background:var(--pb)"></i>Path B</span><span><i class="dot" style="background:var(--pc)"></i>Path C</span><span><i class="dot" style="background:var(--gold)"></i>Mastery (needs research)</span><span><i class="dot" style="background:#d98cff"></i>Prestige (draft)</span><span><span class="new">new</span>New node</span></div>' +
    (D.panels.length ? '<div class="panels">' + D.panels.map(function (p, pi) { return panelHtml(D, o, p, pi); }).join("") + "</div>" : "") + "</div>" +
    '<nav class="bar" aria-label="Towers">' + D.towers.map(function (t) { return '<a class="chip" href="#' + slug(t.meta.id || t.name) + '" style="--tw:' + (D.accent[t.meta.id] || "#4de1ff") + '"><i></i>' + esc(t.name) + "</a>"; }).join("") +
    '<button class="toggle" id="focus-new" type="button" aria-pressed="false">Highlight new</button></nav>' +
    D.towers.map(function (t, ti) { return treeHtml(D, o, t, ti); }).join("") +
    '<footer>Costs are per upgrade; "Maxed" is the total from Tier 1 to each branch\'s mastery (prestige not included). Upgrades after the specialization list what they add. New-node numbers are first-pass values for the balance probe.</footer></div>';
}

function pageBoot() {
  var on = false;
  try { on = localStorage.getItem("trees-focus-new") === "1"; } catch (e) {}
  function apply() {
    document.body.classList.toggle("focus-new", on);
    var btn = document.getElementById("focus-new");
    if (btn) btn.setAttribute("aria-pressed", on ? "true" : "false");
  }
  document.addEventListener("click", function (e) {
    if (!e.target.closest || !e.target.closest("#focus-new")) return;
    on = !on; apply();
    try { localStorage.setItem("trees-focus-new", on ? "1" : "0"); } catch (err) {}
  });
  new MutationObserver(apply).observe(document.getElementById("app"), { childList: true });
  apply();
}
