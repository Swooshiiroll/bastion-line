// ---- Tower art second pass: per-step path looks and Retrofit looks on top of a confirmed base design --------
// Data (defined before this): PAGE {title, store}, P2 {tower, look, anim, intro, paths: [{name, theme, steps: [{name, cost,
// effect, options: [layer x3]}] x5}], retrofits: [{name, cost, effect, options: [layer x3]}], uncapped?}.
// A layer: {key, name, desc, under?(c, aim, s, fx, t, col, info), over?(...), muzzles?, targets?, crit?, shot?, shotFx?, impactFx?}.
//   under/over draw before/after the base model; muzzles replace the firing points (the last layer that sets them wins);
//   targets = enemies it fires at at once; crit = crit chance shown as a gold burst; shot replaces the base shot (last wins);
//   shotFx/impactFx draw on top of every shot/impact.

const TW = BASE.TOWERS.find((x) => x.id === P2.tower);
const BASE_LOOK = TW.looks.find((l) => l.key === P2.look), BASE_ANIM = TW.anims.find((a) => a.key === P2.anim);
let S2 = {};
try { S2 = JSON.parse(localStorage.getItem(PAGE.store) || "{}") || {}; } catch (e) { S2 = {}; }
S2.picks ||= { ...(P2.picks || {}) }; S2.notes ||= {}; S2.build ||= { lv: [0, 0, 0], r: -1 };
function save2() { try { localStorage.setItem(PAGE.store, JSON.stringify(S2)); } catch (e) { /* storage unavailable */ } }
const STAGE = ["1", "2", "3", "4", "M"];
const optOf = (list, id) => list.find((o) => o.key === S2.picks[id]) || list[0];

// The layers for path levels lv[] and Retrofit r (-1 none); `over` swaps one stage for a candidate option.
function layersFor(lv, r, swap) {
  const out = []; out.build = { lv: lv.slice(), r };
  P2.paths.forEach((pa, pi) => { for (let k = 0; k < lv[pi]; k++) { const id = "p" + pi + "s" + k; out.push(swap && swap.id === id ? swap.opt : optOf(pa.steps[k].options, id)); } });
  if (r >= 0) { const id = "r" + r; out.push(swap && swap.id === id ? swap.opt : optOf(P2.retrofits[r].options, id)); }
  return out;
}
const GOLD_C = [1, 0.78, 0.3, 1];
function critMark(p, v, s) { if (v >= 1) return; glowDot(p, s * 0.1 * (1 - v), GOLD_C); for (let i = 0; i < 6; i++) { const d = fa(i * TAU / 6 + 0.3); line(add(p, mul(d, s * (0.06 + 0.2 * v))), add(p, mul(d, s * (0.12 + 0.24 * v))), A(GOLD_C, 1 - v), 1.4); } }
function compose(layers) {
  let muzzles = BASE_LOOK.muzzles, targets = 1, crit = 0, shot = null;
  for (const L of layers) { if (L.muzzles) muzzles = L.muzzles; if (L.targets) targets = Math.max(targets, L.targets); if (L.crit) crit = Math.max(crit, L.crit); if (L.shot) shot = L.shot; }
  const B = layers.build || { lv: [0, 0, 0], r: -1 };
  const md = P2.mods ? P2.mods(B) : null;
  if (md) { if (md.targets) targets = md.targets; if (md.crit != null) crit = md.crit; if (md.shot) shot = md.shot; }
  const look = { ...BASE_LOOK, muzzles, key: BASE_LOOK.key + layers.map((L) => L.key).join(""),
    draw(c, aim, s, fx, t, col, info) { if (P2.model) return P2.model(c, aim, s, fx, t, col, info, B);
      for (const L of layers) if (L.under) L.under(c, aim, s, fx, t, col, info);
      BASE_LOOK.draw.call(this, c, aim, s, fx, t, col, info); for (const L of layers) if (L.over) L.over(c, aim, s, fx, t, col, info); } };
  if (P2.muzzleAt) look.muzzleAt = (m, k, c, aim, s, info) => P2.muzzleAt(B, m, k, c, aim, s, info);
  const b = BASE_ANIM, every = crit > 0 ? Math.max(2, Math.round(1 / crit)) : 0;
  const anim = { ...b, key: b.key + targets, burst: (b.burst || 1) * targets, multi: targets > 1 || b.multi, gap: targets > 1 ? 0.02 : b.gap,
    shot: (f, to, u, s, col, k, t, info) => { (shot || b.shot)(f, to, u, s, col, k, t, info); for (const L of layers) if (L.shotFx) L.shotFx(f, to, u, s, col, k, t, info); if (md && md.shotFx) md.shotFx(f, to, u, s, col, k, t, info); },
    impact: (to, v, s, col, info) => { if (b.impact) b.impact(to, v, s, col, info); for (const L of layers) if (L.impactFx) L.impactFx(to, v, s, col, info);
      if (md && md.impactFx) md.impactFx(to, v, s, col, info);
      if (every && info && info.sh && info.sh.m % every === 0) critMark(to, v, s); } };
  return { look, anim };
}
function clampBuild(lv, changed) { // two paths at most; once one reaches 3, the other stops at 2
  if (P2.uncapped) return;
  const others = [0, 1, 2].filter((i) => i !== changed);
  if (others.filter((i) => lv[i] > 0).length >= 2) lv[changed] = 0;
  else if (others.some((i) => lv[i] >= 3)) lv[changed] = Math.min(lv[changed], 2);
}

function card(id, opt, lv, r, root) {
  const p = el("div", "panel"), cv = cardCanvas(260, 180);
  const comp = () => compose(layersFor(lv, r, { id, opt }));
  register(cv, TW, () => comp().look, () => comp().anim, 120);
  p.appendChild(cv); p.appendChild(el("div", "meta", `<span class="key">${opt.key}</span><b>${opt.name}</b>`)); p.appendChild(el("div", "desc", opt.desc));
  const b = el("button", "pick"); const sync = () => { const on = S2.picks[id] === opt.key; b.classList.toggle("on", on); b.textContent = (on ? "Picked " : "Pick ") + opt.key; };
  b.onclick = () => { S2.picks[id] = S2.picks[id] === opt.key ? null : opt.key; save2(); refresh2(); }; b._sync = sync; sync(); p.appendChild(b); root.appendChild(p);
}
function notesBox(key, label, root) { const lab = el("label", "notes", label); const ta = document.createElement("textarea"); ta.value = S2.notes[key] || "";
  ta.oninput = () => { S2.notes[key] = ta.value; save2(); summary2(); }; lab.appendChild(ta); root.appendChild(lab); }

function buildPreview(root) {
  const box = el("section", "build"), cv = cardCanvas(560, 360), ctrls = el("div", "ctrls");
  register(cv, TW, () => compose(layersFor(S2.build.lv, S2.build.r)).look, () => compose(layersFor(S2.build.lv, S2.build.r)).anim, 210);
  box.appendChild(cv); box.appendChild(ctrls);
  ctrls.appendChild(el("div", "combo-head", "Build preview"));
  const roles = [];
  P2.paths.forEach((pa, pi) => { const c = el("div", "ctrl"), lab = el("label", "", ""), inp = document.createElement("input"), role = el("span", "role", "");
    inp.type = "range"; inp.min = 0; inp.max = 5; inp.step = 1; inp.value = S2.build.lv[pi];
    const show = () => { const v = S2.build.lv[pi]; lab.textContent = `Path ${pi + 1}: ${pa.name}: ${v === 0 ? "none" : v === 5 ? "mastery" : "step " + v}`; inp.value = v; };
    inp.oninput = () => { S2.build.lv[pi] = +inp.value; clampBuild(S2.build.lv, pi); save2(); roles.forEach((f) => f()); };
    roles.push(() => { show(); const lv = S2.build.lv; role.textContent = P2.uncapped ? "" : lv[pi] >= 3 ? "primary" : lv[pi] > 0 && lv.some((x, i) => i !== pi && x >= 3) ? "secondary (max 2)" : ""; });
    c.appendChild(lab); c.appendChild(inp); c.appendChild(role); ctrls.appendChild(c); });
  const rc = el("div", "ctrl"), sel = document.createElement("select"); rc.appendChild(el("label", "", "Retrofit"));
  [["-1", "None"], ...P2.retrofits.map((rf, i) => [String(i), rf.name])].forEach(([v, n]) => { const o = document.createElement("option"); o.value = v; o.textContent = n; sel.appendChild(o); });
  sel.value = String(S2.build.r); sel.onchange = () => { S2.build.r = +sel.value; save2(); }; rc.appendChild(sel); ctrls.appendChild(rc);
  ctrls.appendChild(el("div", "desc", "Unpicked steps show option A."));
  roles.forEach((f) => f()); root.appendChild(box);
}

function boot2() {
  const root = document.getElementById("towers");
  const head = el("section", "enemy");
  head.appendChild(el("div", "enemy-head", `<span class="num">${TW.num}</span><h2>${TW.name}</h2><span class="tags">${TW.cls} · ${TW.weapon} · base look ${BASE_LOOK.key} ${BASE_LOOK.name}, animation ${BASE_ANIM.key} ${BASE_ANIM.name}</span>`));
  head.appendChild(el("p", "desc", P2.intro)); root.appendChild(head);
  buildPreview(root);
  P2.paths.forEach((pa, pi) => { const sec = el("section", "enemy");
    sec.appendChild(el("div", "enemy-head", `<h2>Path ${pi + 1}: ${pa.name}</h2><span class="tags">${pa.theme}</span>`));
    pa.steps.forEach((st, k) => { const row = el("div", "stage"), lv = [0, 0, 0]; lv[pi] = k + 1;
      row.appendChild(el("div", "stage-head", `<span class="lvl">${STAGE[k]}</span><b>${st.name}</b><span class="cost">${st.cost}</span><span class="eff">${st.effect}</span>`));
      const g = el("div", "grid3"); st.options.forEach((o) => card("p" + pi + "s" + k, o, lv, -1, g)); row.appendChild(g); sec.appendChild(row); });
    notesBox("p" + pi, `Path ${pi + 1} notes`, sec); root.appendChild(sec); });
  const rs = el("section", "enemy"); rs.appendChild(el("div", "enemy-head", `<h2>Retrofit</h2><span class="tags">the player picks one of three</span>`));
  P2.retrofits.forEach((rf, ri) => { const row = el("div", "stage");
    row.appendChild(el("div", "stage-head", `<span class="lvl">R</span><b>${rf.name}</b><span class="cost">${rf.cost}</span><span class="eff">${rf.effect}</span>`));
    const g = el("div", "grid3"); rf.options.forEach((o) => card("r" + ri, o, [0, 0, 0], ri, g)); row.appendChild(g); rs.appendChild(row); });
  notesBox("r", "Retrofit notes", rs); root.appendChild(rs);
  refresh2();
  document.getElementById("copy").onclick = () => { const ta = document.getElementById("summary"), b = document.getElementById("copy");
    const done = () => { b.textContent = "Copied"; setTimeout(() => { b.textContent = "Copy picks and notes"; }, 1500); };
    try { navigator.clipboard.writeText(ta.value).then(done, () => ta.select()); } catch (e) { ta.select(); } };
  document.getElementById("clear").onclick = () => { if (!confirm("Clear this page's picks and notes?")) return; S2 = { picks: {}, notes: {}, build: { lv: [0, 0, 0], r: -1 } }; save2(); location.reload(); };
  const t0 = performance.now();
  const tick = () => { const t = (performance.now() - t0) / 1000; for (const v of views) if (v.visible) v.frame(t); requestAnimationFrame(tick); };
  requestAnimationFrame(tick);
}
function refresh2() { document.querySelectorAll("button.pick").forEach((b) => b._sync && b._sync()); summary2(); }
function summary2() {
  const out = [PAGE.title], nt = (k) => (S2.notes[k] || "").trim().replace(/\s+/g, " ");
  P2.paths.forEach((pa, pi) => { let l = `Path ${pi + 1} ${pa.name}: ` + pa.steps.map((st, k) => `${STAGE[k]} ${S2.picks["p" + pi + "s" + k] || "-"}`).join(", ");
    if (nt("p" + pi)) l += "; notes: " + nt("p" + pi); out.push(l); });
  let r = "Retrofits: " + P2.retrofits.map((rf, i) => `${rf.name} ${S2.picks["r" + i] || "-"}`).join(", "); if (nt("r")) r += "; notes: " + nt("r"); out.push(r);
  const ta = document.getElementById("summary"); if (ta) { ta.value = out.join("\n"); ta.rows = out.length + 1; }
}
if (typeof document !== "undefined") boot2();
