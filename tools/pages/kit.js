// ---- Page kit (shared by the design pages): in-place editing and saving. -----------------------
// Runs inside the page's script after the page's own render code, so `DATA`, `renderPage` and
// `pageBoot` are in scope. The generator also runs this file in Node to build the same document a
// save produces, which is why nothing here touches `document` until boot().
var FONTS = '<link rel="preconnect" href="https://fonts.googleapis.com">\n' +
  '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Chakra+Petch:wght@500;600;700&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap">';

function esc(s) { return String(s == null ? "" : s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;"); }
function inline(s) { return esc(s).replace(/`([^`]+)`/g, "<code>$1</code>"); }
function getPath(o, p) { return p.split(".").reduce(function (a, k) { return a == null ? a : a[k]; }, o); }
function setPath(o, p, v) { var ks = p.split("."), last = ks.pop(); var t = ks.reduce(function (a, k) { return a[k]; }, o); t[last] = v; }
function same(a, b) { return JSON.stringify(a) === JSON.stringify(b); }
function shown(kind, v) { return kind === "list" ? (v || []).join(" · ") : v == null ? "" : String(v); }

// Attributes for an editable element: its data path, how to read it, and the was-marker if edited.
function ed(D, path, kind) {
  var was = D.changed && Object.prototype.hasOwnProperty.call(D.changed, path) ? D.changed[path] : undefined;
  return ' data-edit="' + esc(path) + '" data-kind="' + (kind || "text") + '"' +
    (was !== undefined ? ' data-was="' + esc(shown(kind, was)) + '" title="Was: ' + esc(shown(kind, was)) + '"' : "");
}
// Text that shows inline markup when viewing and its raw source while editing.
function field(D, o, tag, cls, path, kind, value) {
  return "<" + tag + (cls ? ' class="' + cls + '"' : "") + ed(D, path, kind) + ">" + (o.editing ? esc(shown(kind, value)) : inline(shown(kind, value))) + "</" + tag + ">";
}
// A stat list: chips when viewing, one " · " separated line while editing.
function statList(D, o, path, stats, liClass) {
  if (o.editing) return '<p class="stats-edit"' + ed(D, path, "list") + ">" + esc(stats.join(" · ")) + "</p>";
  return '<ul class="stats"' + ed(D, path, "list") + ">" + stats.map(function (s) { return '<li class="' + (liClass ? liClass(s) : "") + '">' + inline(s) + "</li>"; }).join("") + "</ul>";
}
// An open question's answer box (not part of the markdown; read back by Claude).
function answerBox(D, o, path) {
  var v = getPath(D, path) || "";
  if (o.editing) return '<textarea class="answer-in" rows="2" placeholder="Your answer" data-edit="' + esc(path) + '" data-kind="multiline" data-track="0">' + esc(v) + "</textarea>";
  return v ? '<p class="answer"><b>Answer</b>' + esc(v).replace(/\n/g, "<br>") + "</p>" : "";
}

function buildDoc(data, css, js) {
  return "<!doctype html>\n<html lang=\"en\">\n<head>\n<meta charset=\"utf-8\">\n" +
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, viewport-fit=cover\">\n" +
    "<title>" + esc(data.pageTitle) + "</title>\n" + FONTS + "\n<style id=\"page-css\">" + css + "</style>\n</head>\n<body>\n" +
    "<div id=\"app\">" + renderPage(data, {}) + "</div>\n" +
    "<script type=\"application/json\" id=\"page-data\">" + JSON.stringify(data).replace(/</g, "\\u003c") + "<\/script>\n" +
    "<script id=\"page-js\">" + js + "<\/script>\n</body>\n</html>\n";
}

function parseField(kind, raw) {
  if (kind === "multiline") return raw.replace(/\r/g, "").replace(/[ \t]+\n/g, "\n").trim();
  var t = raw.replace(/ /g, " ").replace(/\s+/g, " ").trim().replace(/\|/g, "/");
  if (kind === "int") { var n = t.replace(/[, ]|cr$/gi, ""); return /^\d+$/.test(n) ? parseInt(n, 10) : undefined; }
  if (kind === "list") return t.split(/\s*·\s*/).filter(Boolean);
  return t;
}

function boot() {
  var app = document.getElementById("app");
  var st = { editing: false, dirty: false, saving: false, readOnly: false, retried: false, msg: "", art: null };
  if (!DATA.changed) DATA.changed = {};
  var bar = document.createElement("div");
  bar.className = "kit-bar";
  bar.hidden = true;
  bar.setAttribute("role", "toolbar");
  bar.setAttribute("aria-label", "Edit this page");
  document.body.appendChild(bar);

  function count() { return Object.keys(DATA.changed).length; }
  function draw() {
    var y = window.scrollY;
    app.innerHTML = renderPage(DATA, { editing: st.editing });
    var editable = st.editing ? ("plaintext-only" in document.body ? "plaintext-only" : "true") : null;
    app.querySelectorAll("[data-edit]").forEach(function (el) {
      if (el.tagName === "SELECT" || el.tagName === "TEXTAREA") return;
      if (editable) { el.contentEditable = editable; el.spellcheck = true; } else el.removeAttribute("contenteditable");
    });
    document.body.classList.toggle("editing", st.editing);
    window.scrollTo(0, y);
  }
  function ui() {
    var n = count();
    bar.innerHTML =
      (n ? '<button type="button" data-act="next" title="Jump to the next edited field">' + n + (n === 1 ? " edit" : " edits") + "</button>" : "") +
      (st.msg ? '<span class="kit-msg" role="status">' + esc(st.msg) + "</span>" : st.dirty ? '<span class="kit-msg" role="status">Unsaved changes</span>' : "") +
      (st.readOnly ? "" : '<button type="button" data-act="toggle" aria-pressed="' + st.editing + '">' + (st.editing ? "Done" : "Edit") + "</button>") +
      (st.dirty && !st.readOnly ? '<button type="button" class="primary" data-act="save"' + (st.saving ? " disabled" : "") + ">" + (st.saving ? "Saving…" : "Save") + "</button>" : "");
  }

  app.addEventListener("input", function (e) {
    var el = e.target.closest ? e.target.closest("[data-edit]") : null;
    if (!el || !st.editing) return;
    var kind = el.dataset.kind || "text";
    var raw = el.tagName === "SELECT" || el.tagName === "TEXTAREA" ? el.value : el.innerText;
    var v = parseField(kind, raw);
    if (v === undefined) { el.classList.add("bad"); return; }
    el.classList.remove("bad");
    var path = el.dataset.edit, old = getPath(DATA, path);
    if (same(old, v)) return;
    if (el.dataset.track !== "0") {
      if (!Object.prototype.hasOwnProperty.call(DATA.changed, path)) DATA.changed[path] = old;
      if (same(DATA.changed[path], v)) delete DATA.changed[path];
      var was = DATA.changed[path];
      if (was === undefined) { el.removeAttribute("data-was"); el.removeAttribute("title"); }
      else { el.setAttribute("data-was", shown(kind, was)); el.title = "Was: " + shown(kind, was); }
    }
    setPath(DATA, path, v);
    st.dirty = true; st.msg = "";
    ui();
  });
  app.addEventListener("keydown", function (e) {
    var el = e.target.closest ? e.target.closest("[data-edit]") : null;
    if (el && e.key === "Enter" && el.dataset.kind !== "multiline" && el.tagName !== "SELECT") { e.preventDefault(); el.blur(); }
    if (el && e.key === "Escape") el.blur();
  });
  // Selects fire "change" on some browsers only; route both through the input handler.
  app.addEventListener("change", function (e) {
    if (e.target.tagName !== "SELECT") return;
    var ev = new Event("input", { bubbles: true });
    e.target.dispatchEvent(ev);
  });

  var nextIdx = 0;
  bar.addEventListener("click", function (e) {
    var b = e.target.closest("button");
    if (!b) return;
    var act = b.dataset.act;
    if (act === "toggle") { st.editing = !st.editing; st.msg = ""; draw(); ui(); }
    else if (act === "save") save();
    else if (act === "next") {
      var els = app.querySelectorAll("[data-was]");
      if (!els.length) return;
      var el = els[nextIdx++ % els.length];
      el.scrollIntoView({ block: "center", behavior: "smooth" });
      el.classList.remove("flash"); void el.offsetWidth; el.classList.add("flash");
    }
  });
  window.addEventListener("beforeunload", function (e) { if (st.dirty && !st.saving) { e.preventDefault(); e.returnValue = ""; } });

  function save() {
    if (!st.art || st.saving) return;
    st.saving = true; st.msg = ""; ui();
    var css = document.getElementById("page-css").textContent;
    var js = document.getElementById("page-js").textContent;
    st.art.publish(buildDoc(DATA, css, js)).then(function () {
      st.saving = false; st.dirty = false; st.msg = "Saved. Reloading…"; ui();
    }, function (err) {
      var c = err && err.code;
      st.saving = false;
      if (c === "conflict") st.msg = "A newer version was saved elsewhere; the page is reloading to it, so these edits are lost.";
      else if (["not_writer", "not_granted", "not_declared", "capability_disabled", "capability_removed", "consent_required"].indexOf(c) >= 0) {
        st.readOnly = true; st.msg = "This view is read-only, so edits can't be saved here.";
      } else if (c === "rate_limited") st.msg = "Saving too often. Wait a moment, then Save again.";
      else if (c === "too_large") st.msg = "The page is too large to save.";
      else if (!st.retried) { st.retried = true; setTimeout(save, 800 + Math.random() * 1200); st.msg = "Retrying the save…"; }
      else st.msg = "Couldn't save (" + (c || "error") + "). Your edits are still here; try Save again.";
      ui();
    });
  }

  if (typeof pageBoot === "function") pageBoot();
  if (window.claude && typeof window.claude.use === "function") {
    window.claude.use("artifact").then(function (art) {
      if (!art) return;
      st.art = art;
      bar.hidden = false;
      ui();
    }, function () {});
  }
}
if (typeof document !== "undefined") boot();
return { renderPage: renderPage, buildDoc: buildDoc };
