// ---- Super Structures page: renders every recipe and its tree from DATA (design/super_structures.md).
var DATA = typeof PAGE_DATA !== "undefined" ? PAGE_DATA : JSON.parse(document.getElementById("page-data").textContent);
var LAYOUT_TEXT = { pairs: "Pairs side by side", diagonal: "Matching towers on the diagonals", any: "Any arrangement" };

function towerColor(D, id) { return (D.towers[id] && D.towers[id].color) || "#888"; }
function towerName(D, id) { return (D.towers[id] && D.towers[id].name) || id; }

function recipeGrid(D, o, s, si) {
  var P = "structures." + si + ".";
  var tiles = s.recipe.map(function (id, k) {
    var label = o.editing
      ? '<select class="kit-select"' + ed(D, P + "recipe." + k, "text") + ' aria-label="Recipe tower ' + (k + 1) + '">' +
        Object.keys(D.towers).filter(function (t) { return D.towers[t].size !== 2; }).map(function (t) {
          return '<option value="' + esc(t) + '"' + (t === id ? " selected" : "") + ">" + esc(D.towers[t].name) + "</option>";
        }).join("") + "</select>"
      : "<span" + ed(D, P + "recipe." + k, "text") + ">" + esc(towerName(D, id)) + "</span>";
    return '<div class="tile" style="--tw:' + towerColor(D, id) + '"><i></i>' + label + "</div>";
  }).join("");
  var layout = o.editing
    ? '<select class="kit-select"' + ed(D, P + "layout", "text") + ' aria-label="Layout">' + Object.keys(LAYOUT_TEXT).map(function (k) {
        return '<option value="' + k + '"' + (k === s.layout ? " selected" : "") + ">" + LAYOUT_TEXT[k] + "</option>";
      }).join("") + "</select>"
    : "<span" + ed(D, P + "layout", "text") + ">" + esc(LAYOUT_TEXT[s.layout] || s.layout) + "</span>";
  return '<figure class="recipe"><div class="grid2">' + tiles + "</div><figcaption>" + layout + " · each tower at T3+</figcaption></figure>";
}

function card(D, o, s, si, r, kind, label) {
  var P = "structures." + si + ".rows." + s.rows.indexOf(r) + ".";
  return '<article class="card ' + kind + '"><header><span class="tag">' + label + '</span><span class="cost"><span' + ed(D, P + "cost", "int") + ">" +
    r.cost.toLocaleString("en-US") + "</span> cr</span></header>" +
    field(D, o, "h4", "", P + "name", "text", r.name) + statList(D, o, P + "stats", r.stats) + field(D, o, "p", "fx", P + "effect", "text", r.effect) + "</article>";
}

function branchRow(D, o, s, si, p) {
  var rows = s.rows.filter(function (r) { return r.path === p; });
  var total = rows.reduce(function (a, r) { return a + r.cost; }, 0);
  var cards = ["2", "3", "4", "M"].map(function (t, i) {
    var r = rows.filter(function (x) { return x.tier === t; })[0];
    if (!r) return '<div class="card missing">Not drafted</div>';
    return card(D, o, s, si, r, t === "M" ? "mastery" : "step", t === "M" ? p.toUpperCase() + " · mastery" : p.toUpperCase() + " · T" + (i + 1));
  }).join("");
  return '<div class="branch"><div class="branch-head"><b>Branch ' + p.toUpperCase() + "</b><span>" + total.toLocaleString("en-US") +
    ' cr for the whole branch</span></div><div class="cards">' + cards + "</div></div>";
}

function structureHtml(D, o, s, si) {
  var c1 = towerColor(D, s.recipe[0]);
  var c2 = towerColor(D, s.recipe.filter(function (x) { return x !== s.recipe[0]; })[0] || s.recipe[0]);
  var base = s.rows.filter(function (r) { return r.tier === "1"; })[0];
  return '<section class="structure" id="' + esc(s.id) + '" style="--c1:' + c1 + ";--c2:" + c2 + '">' +
    '<header class="s-head"><span class="swatch"></span><div>' + field(D, o, "h3", "", "structures." + si + ".title", "text", s.title) +
    field(D, o, "p", "role", "structures." + si + ".role", "text", s.role) + "</div></header>" +
    '<div class="s-body"><div class="left">' + recipeGrid(D, o, s, si) + (base ? card(D, o, s, si, base, "base", "Merge price") : "") + "</div>" +
    '<div class="right">' + branchRow(D, o, s, si, "a") + branchRow(D, o, s, si, "b") + "</div></div></section>";
}

function renderPage(D, o) {
  o = o || {};
  var used = {};
  D.structures.forEach(function (s) { s.recipe.forEach(function (id) { used[id] = 1; }); });
  var nodes = D.structures.reduce(function (a, s) { return a + s.rows.length; }, 0);
  return '<div class="wrap"><header class="top"><span class="eyebrow">Bastion Line · design draft</span><h1>Super Structures</h1>' +
    '<p class="lede">Four specific towers in a 2×2 block, each with its primary locked in, merge into one Super Structure with its own two-branch tree. Six recipes for review. Built from <code>design/super_structures.md</code>; use Edit (bottom right) to change recipes, names, costs, stats and rules, and to answer the open questions.</p>' +
    '<div class="counts"><span><b>' + D.structures.length + "</b> structures</span><span><b>" + nodes + "</b> nodes</span><span><b>" + Object.keys(used).length + "</b> of " + Object.keys(D.towers).length + " towers used</span></div></header>" +
    '<nav class="bar" aria-label="Structures">' + D.structures.map(function (s) {
      return '<a class="chip" href="#' + esc(s.id) + '" style="--c1:' + towerColor(D, s.recipe[0]) + '"><i></i>' + esc(s.title) + "</a>";
    }).join("") + "</nav>" +
    '<div class="panels">' + D.panels.map(function (p, pi) {
      var asks = /question/i.test(p.name);
      return '<div class="panel"><h2>' + inline(p.name) + "</h2><ul>" + p.bullets.map(function (b, bi) {
        return "<li>" + field(D, o, "span", "", "panels." + pi + ".bullets." + bi, "text", b) + (asks ? answerBox(D, o, "panels." + pi + ".answers." + bi) : "") + "</li>";
      }).join("") + "</ul></div>";
    }).join("") + "</div>" +
    D.structures.map(function (s, si) { return structureHtml(D, o, s, si); }).join("") + "</div>";
}
