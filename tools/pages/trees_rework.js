// ---- Reworked upgrade trees page: renders the tower rework's trees from DATA (built from
// design/upgrade_trees_rework.md). Stock, then three Retrofit options to pick from, then three paths of four
// steps and a mastery. No trunk and no prestige, unlike today's trees page (trees.js).
var DATA = typeof PAGE_DATA !== "undefined" ? PAGE_DATA : JSON.parse(document.getElementById("page-data").textContent);
var PATHS = { a: "A", b: "B", c: "C" };

function card(D, o, t, ti, n, color) {
  if (!n) return '<div class="card missing">Not defined yet</div>';
  var ni = t.nodes.indexOf(n), P = "towers." + ti + ".nodes." + ni + ".";
  var label = n.tier === 1 ? "Stock" : n.tier === 2 ? "Retrofit option " + n.path.replace(/\D/g, "") :
    n.tier === 8 ? PATHS[n.path] + " · mastery" : PATHS[n.path] + " · step " + (n.tier - 2) + (n.tier === 5 ? " · primary" : "");
  var kind = n.tier === 8 ? "mastery" : n.tier === 3 ? "spec" : n.tier > 3 ? "step" : "trunk";
  return '<article class="card ' + kind + " is-old path-" + n.path + '" style="--tw:' + color + '">' +
    '<header><span class="tag">' + label + "</span>" +
    '<span class="cost"><span' + ed(D, P + "cost", "int") + ">" + n.cost + "</span> cr</span></header>" +
    field(D, o, "h4", "", P + "name", "text", n.name) +
    (n.stats.length || o.editing ? statList(D, o, P + "stats", n.stats) : "") +
    (n.effect || o.editing ? field(D, o, "p", "fx", P + "effect", "text", n.effect) : "") +
    (n.tier === 4 && !t.meta.uncapped ? '<span class="cap">Secondary stops here</span>' : "") + "</article>";
}

function slug(s) { return String(s).toLowerCase().replace(/[^a-z0-9]+/g, "-"); }
function pathTotal(t, p) { return t.nodes.filter(function (n) { return n.tier === 1 || n.path === p; }).reduce(function (a, n) { return a + n.cost; }, 0); }
function colorOf(D, t, ti) { return D.accent[ti % D.accent.length]; }

function treeHtml(D, o, t, ti) {
  var color = colorOf(D, t, ti);
  function find(tier, path) { return t.nodes.filter(function (n) { return n.tier === tier && n.path === path; })[0]; }
  var retro = t.nodes.filter(function (n) { return n.tier === 2; });
  var rows = ["a", "b", "c"].map(function (p, i) {
    return '<div class="fork r' + (i + 1) + '" aria-hidden="true"></div><div class="branch r' + (i + 1) + '">' +
      [3, 4, 5, 6, 8].map(function (tier) { return card(D, o, t, ti, find(tier, p), color); }).join("") + "</div>";
  }).join("");
  return '<section class="tower" id="' + slug(t.meta.id || t.name) + '" style="--tw:' + color + '">' +
    '<header class="tower-head"><div class="tower-name"><span class="swatch"></span><h3>' + inline(t.name) + "</h3></div>" +
    field(D, o, "p", "role", "towers." + ti + ".role", "text", t.role) +
    '<dl class="meta">' + (t.meta.class ? "<div><dt>Class</dt><dd>" + esc(t.meta.class) + "</dd></div>" : "") +
    (t.meta.weapon ? "<div><dt>Weapon</dt><dd>" + esc(t.meta.weapon) + "</dd></div>" : "") +
    "<div><dt>Maxed</dt><dd>" + ["a", "b", "c"].map(function (p) { return PATHS[p] + " " + pathTotal(t, p); }).join(" · ") + " cr</dd></div></dl></header>" +
    '<div class="tree-scroll"><div class="tree"><div class="cell t1">' + card(D, o, t, ti, find(1, "base"), color) + '</div><div class="link base1" aria-hidden="true"></div>' +
    '<div class="cell t2"><span class="pick">' + (retro.length > 1 ? "Retrofit: pick one" : "Retrofit") + "</span>" +
    retro.map(function (n) { return card(D, o, t, ti, n, color); }).join("") + '</div><div class="link base2" aria-hidden="true"></div>' + rows + "</div></div></section>";
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
  var nodes = 0;
  D.towers.forEach(function (t) { nodes += t.nodes.length; });
  return '<div class="wrap"><div class="top"><span class="eyebrow">Bastion Line · tower rework · design draft</span>' +
    "<h1>" + inline(D.title) + "</h1>" +
    '<p class="lede">The 20 reworked towers\' upgrade trees. Each tower: its stock build, a Retrofit off to the side (pick one of three), then three paths of four steps and a mastery. The 3rd step on a path makes it the primary; the other started path stops at step 2. Built from <code>design/upgrade_trees_rework.md</code> (from <code>design/tower_roster.md</code>); use Edit (bottom right) to change names, costs, stats, descriptions and rules.</p>' +
    '<div class="counts"><span><b>' + D.towers.length + "</b> towers</span><span><b>" + D.towers.length * 3 + "</b> paths</span><span><b>" + nodes + "</b> nodes</span></div>" +
    '<div class="legend"><span><i class="dot" style="background:var(--pa)"></i>Path A</span><span><i class="dot" style="background:var(--pb)"></i>Path B</span><span><i class="dot" style="background:var(--pc)"></i>Path C</span><span><i class="dot" style="background:var(--gold)"></i>Mastery (needs research)</span></div>' +
    (D.panels.length ? '<div class="panels">' + D.panels.map(function (p, pi) { return panelHtml(D, o, p, pi); }).join("") + "</div>" : "") + "</div>" +
    '<nav class="bar" aria-label="Towers">' + D.towers.map(function (t, ti) { return '<a class="chip" href="#' + slug(t.meta.id || t.name) + '" style="--tw:' + colorOf(D, t, ti) + '"><i></i>' + esc(t.name) + "</a>"; }).join("") + "</nav>" +
    D.towers.map(function (t, ti) { return treeHtml(D, o, t, ti); }).join("") +
    '<footer>Costs are per upgrade; "Maxed" is the stock build plus a whole path to its mastery (Retrofit not included). Prices come from the value formula with the owner\'s overrides; every number is a first pass for the balance probe.</footer></div>';
}

function pageBoot() {}
