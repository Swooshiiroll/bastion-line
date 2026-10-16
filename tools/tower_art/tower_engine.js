// ---- Tower art engine: previews towers aiming and firing at enemies on a lane --------------------------
// Data (defined before this): PAGE {title, key, store}, TOWERS [...], DEFAULTS {id: {look, anim}}.
// A look: {key, name, theme, muzzle (tile units along the aim), draw(c, aim, s, fx, t, col)} where s = px per tile.
// An animation: {key, name, desc, period, burst?, gap?, multi?, flight, beam?, fx(since, period) -> {recoil, flash, glow, spin},
//   shot(from, to, u, s, col, k, t, info), impact(to, v, s, col, info)}. info = {ens (hittable enemies in reach), c, W, H, s, t, look, spot, orbit}.
// A tower can set spot {x, y} (player-aimed at a fixed point, fractions of the view) or orbit {x, y, r (tiles), w (rad/s)}
//   (an aircraft circling a point; the look draws it with plane(p, heading, s, fx, t, col, centre) and fires from its door).

const STORE = PAGE.store;
let state = {};
try { state = JSON.parse(localStorage.getItem(STORE) || "{}") || {}; } catch (e) { state = {}; }
function save() { try { localStorage.setItem(STORE, JSON.stringify(state)); } catch (e) { /* storage unavailable */ } }
const DEF = typeof DEFAULTS === "undefined" ? {} : DEFAULTS;
function st(id) { if (!state[id]) { const d = DEF[id] || {}; state[id] = { look: d.look || null, anim: d.anim || null, notes: { look: "", anim: "" } }; } return state[id]; }
const lookOf = (tw) => tw.looks.find((l) => l.key === st(tw.id).look) || tw.looks[0];
const animOf = (tw) => tw.anims.find((a) => a.key === st(tw.id).anim) || tw.anims[0];

// ---- Scene: a lane of ground enemies and a few flyers -------------------------------------------------
const ENEMY_RED = [0.86, 0.24, 0.22, 1];
function enemiesAt(t, W, H, sc) {
  const out = [], laneY = H * 0.8, span = W + 80;
  for (let i = 0; i < 4; i++) out.push({ air: false, p: [fmod(t * 34 + i * span / 4, span) - 40, laneY + Math.sin(t * 2 + i) * 2], i });
  for (let i = 0; i < 2; i++) { const u = fmod(t * 26 + i * span / 2, span) - 40; out.push({ air: true, p: [u, H * 0.1 + Math.sin(t * 1.5 + i * 2) * 5], i: 10 + i }); }
  return out;
}
function drawEnemy(e, sc) {
  const r = Math.max(4, Math.min(11, sc * 0.12));
  if (e.air) {
    ellipse(add(e.p, [r * 0.6, r * 1.4]), r * 0.9, r * 0.4, [0, 0, 0, 0.25]);
    fill(e.p, [[1.1, 0], [-0.7, 0.8], [-0.35, 0], [-0.7, -0.8]], ENEMY_RED, 0, r); outline(e.p, [[1.1, 0], [-0.7, 0.8], [-0.35, 0], [-0.7, -0.8]], OUTLINE, 1, 0, r);
  } else {
    ellipse(add(e.p, [0, r * 0.7]), r * 1.1, r * 0.45, [0, 0, 0, 0.25]);
    disc(e.p, r + 1, OUTLINE); disc(e.p, r, ENEMY_RED); disc(add(e.p, [r * 0.35, -r * 0.2]), r * 0.35, [1, 0.85, 0.6, 1]);
  }
}
function drawGround(W, H) {
  rect(0, 0, W, H, [0.07, 0.09, 0.08, 1]);
  for (let x = 0; x < W; x += 24) for (let y = 0; y < H; y += 24) if (((x + y) / 24) % 2 === 0) rect(x, y, 24, 24, [0.075, 0.098, 0.085, 1]);
  rect(0, H * 0.8 - 14, W, 28, [0.16, 0.15, 0.13, 1]); line([0, H * 0.8 - 14], [W, H * 0.8 - 14], [0.24, 0.22, 0.18, 1], 1); line([0, H * 0.8 + 14], [W, H * 0.8 + 14], [0.24, 0.22, 0.18, 1], 1);
}
function pad(c, s) {
  const h = s * 0.5;
  rect(c[0] - h, c[1] - h, s, s, [0.2, 0.21, 0.22, 1]); rect(c[0] - h + 2, c[1] - h + 2, s - 4, s - 4, [0.25, 0.26, 0.27, 1]);
  for (const q of [[-1, -1], [1, -1], [1, 1], [-1, 1]]) disc(add(c, [q[0] * (h - 5), q[1] * (h - 5)]), 1.6, [0.15, 0.16, 0.17, 1]);
}

// ---- One animated preview -------------------------------------------------------------------------------
function makeView(canvas, tw, getLook, getAnim, scale) {
  const ctx = canvas.getContext("2d"), W = canvas.width, H = canvas.height, s = scale;
  const c = [W * 0.34, H * 0.44];
  const v = { aim: -0.6, last: -9, shots: [], lockT: 0, lockId: -1, visible: true };
  v.frame = (t) => {
    X = ctx; X.save(); X.globalAlpha = 1; X.lineCap = "round"; X.lineJoin = "round";
    const look = getLook(), an = getAnim();
    drawGround(W, H);
    const ens = enemiesAt(t, W, H, s).filter((e) => (tw.hits === "air" ? e.air : tw.hits === "ground" ? !e.air : true));
    const others = enemiesAt(t, W, H, s).filter((e) => !ens.includes(e));
    const inView = ens.filter((e) => e.p[0] > 10 && e.p[0] < W - 10);
    // tw.spot: the player aims it at a fixed point (it ignores enemies). tw.orbit: an aircraft circles a designated
    // point and fires at enemies near it.
    const O = tw.orbit ? [W * tw.orbit.x, H * tw.orbit.y] : null;
    const cands = O ? inView.filter((e) => Math.hypot(e.p[0] - O[0], e.p[1] - O[1]) < tw.orbit.r * s * 1.6) : inView;
    let tgt = null, best = 1e9;
    if (tw.spot) tgt = { p: [W * tw.spot.x, H * tw.spot.y], i: -5 };
    else for (const e of cands) { const ref = O || c, d = Math.hypot(e.p[0] - ref[0], e.p[1] - ref[1]); if (d < best) { best = d; tgt = e; } }
    let pl = null;
    if (O) { const a = t * (tw.orbit.w || 0.5), p = add(O, mul(fa(a), tw.orbit.r * s)); pl = { p, heading: a + Math.PI / 2, door: add(p, mul(norm(sub(O, p)), s * 0.14)) }; }
    if (tgt) {
      const want = Math.atan2(tgt.p[1] - c[1], tgt.p[0] - c[0]);
      let d = fmod(want - v.aim + Math.PI, TAU) - Math.PI; const dt = Math.min(0.25, Math.max(0, t - (v.prevT || t))); const turn = 7 * dt; v.aim += Math.max(-turn, Math.min(turn, d));
      if (tgt.i !== v.lockId) { v.lockId = tgt.i; v.lockT = t; }
    }
    v.prevT = t;
    const since = t - v.last;
    const muzzles = look.muzzles || [[look.muzzle || 0.45, 0]];
    const muzzleAt = (m, ang) => pl ? pl.door : add(c, rot([muzzles[m % muzzles.length][0] * s, muzzles[m % muzzles.length][1] * s], look.fixed ? 0 : ang));
    const info = { ens: cands, c, W, H, s, t, look, spot: tgt && tgt.i === -5 ? tgt.p : null, orbit: O };
    const aligned = tgt && (pl || Math.abs(fmod(Math.atan2(tgt.p[1] - c[1], tgt.p[0] - c[0]) - v.aim + Math.PI, TAU) - Math.PI) < (an.beam ? 0.15 : 0.35));
    if (tgt && !an.beam && since >= an.period && aligned) {
      v.last = t; const n = an.burst || 1;
      for (let k = 0; k < n; k++) {
        const target = an.multi ? (cands[k % cands.length] || tgt) : tgt;
        v.shots.push({ t0: t + k * (an.gap || 0), tid: target.i, to0: target.p.slice(), k, m: (v.n = (v.n || 0) + 1) - 1 });
      }
    }
    pad(c, s);
    for (const e of others) drawEnemy(e, s);
    for (const e of ens) drawEnemy(e, s);
    if (info.spot) { const q = info.spot, pu = 0.5 + 0.5 * Math.sin(t * 4); ring(q, s * (0.28 + 0.04 * pu), A(tw.color, 0.55 + 0.3 * pu), 1.5);
      for (let i = 0; i < 4; i++) { const d = fa(i * Math.PI / 2); line(add(q, mul(d, s * 0.16)), add(q, mul(d, s * 0.36)), A(tw.color, 0.8), 1.2); } }
    // Beams lock on first: a short acquisition (reticle on the target), then the beam fires.
    const lockDelay = an.lock || 0, held = tgt ? t - v.lockT : 0, beamOn = an.beam && tgt && aligned && held >= lockDelay;
    let fx;
    if (an.beam) fx = an.fx(beamOn ? held - lockDelay : 0, an.period, !!beamOn);
    else {
      fx = an.fx(t - v.last, an.period, !!tgt);
      const fired = v.shots.filter((sh) => t >= sh.t0); const lastShot = fired[fired.length - 1];
      fx.barrel = lastShot ? lastShot.m % muzzles.length : -1; fx.barrelSince = lastShot ? t - lastShot.t0 : 9; fx.shots = lastShot ? lastShot.m + 1 : 0;
    }
    look.draw(c, v.aim, s, fx, t, tw.color, info);
    if (an.beam && tgt) {
      if (beamOn) an.shot(muzzleAt(0, v.aim), tgt.p, held - lockDelay, s, tw.color, 0, t);
      else { const q = Math.min(1, held / Math.max(0.01, lockDelay)), r0 = s * (0.35 - 0.18 * q), sp = t * 4;
        line(muzzleAt(0, v.aim), tgt.p, A(tw.color, 0.25), 1);
        for (let i = 0; i < 4; i++) { const a0 = sp + i * Math.PI / 2; arc(tgt.p, r0, a0, a0 + 0.7, A(tw.color, 0.5 + 0.5 * q), 2); } }
    }
    v.shots = v.shots.filter((sh) => t - sh.t0 < an.flight + 0.6);
    for (const sh of v.shots) {
      const age = t - sh.t0; if (age < 0) continue;
      if (!sh.from) sh.from = muzzleAt(sh.m, v.aim);
      const live = ens.find((e) => e.i === sh.tid); const to = live ? live.p : sh.to0;
      if (age < an.flight) an.shot(sh.from, to, age / an.flight, s, tw.color, sh.k, t, info);
      else if (an.impact) an.impact(to, (age - an.flight) / 0.6, s, tw.color, info);
    }
    if (pl && look.plane) look.plane(pl.p, pl.heading, s, fx, t, tw.color, O);
    X.restore();
  };
  return v;
}

// ---- Page ------------------------------------------------------------------------------------------------
const views = [];
function cardCanvas(w, h) { const cv = document.createElement("canvas"); cv.width = w; cv.height = h; return cv; }
function el(tag, cls, html) { const n = document.createElement(tag); if (cls) n.className = cls; if (html != null) n.innerHTML = html; return n; }
function register(cv, tw, gl, ga, s) { const v = makeView(cv, tw, gl, ga, s); v.cv = cv; views.push(v); io && io.observe(cv); return v; }
const io = typeof IntersectionObserver !== "undefined" ? new IntersectionObserver((es) => { for (const e of es) { const v = views.find((x) => x.cv === e.target); if (v) v.visible = e.isIntersecting; } }) : null;

function buildTower(tw, root) {
  const sec = el("section", "enemy");
  sec.appendChild(el("div", "enemy-head", `<span class="num">${tw.num}</span><h2>${tw.name}</h2><span class="tags">${tw.cls} · ${tw.weapon} · hits ${tw.hits === "both" ? "air and ground" : tw.hits}</span>`));
  sec.appendChild(el("p", "desc", tw.desc));
  for (const kind of ["look", "anim"]) {
    const list = kind === "look" ? tw.looks : tw.anims;
    const grid = el("div", "grid");
    sec.appendChild(el("h3", "", kind === "look" ? "Look" : "Firing animation"));
    for (const o of list) {
      const p = el("div", "panel");
      const cv = cardCanvas(260, 180);
      register(cv, tw, kind === "look" ? () => o : () => lookOf(tw), kind === "anim" ? () => o : () => animOf(tw), 70);
      p.appendChild(cv);
      p.appendChild(el("div", "meta", `<span class="key">${o.key}</span><b>${o.name}</b>`));
      p.appendChild(el("div", "desc", kind === "look" ? o.theme : o.desc));
      const b = el("button", "pick", "Pick " + o.key);
      const sync = () => { const on = st(tw.id)[kind] === o.key; b.classList.toggle("on", on); b.textContent = on ? "Picked " + o.key : "Pick " + o.key; };
      b.onclick = () => { st(tw.id)[kind] = st(tw.id)[kind] === o.key ? null : o.key; save(); refresh(); };
      b._sync = sync; sync(); p.appendChild(b);
      grid.appendChild(p);
    }
    sec.appendChild(grid);
    const lab = el("label", "notes", (kind === "look" ? "Look" : "Animation") + " notes");
    const ta = document.createElement("textarea"); ta.value = st(tw.id).notes[kind] || "";
    ta.oninput = () => { st(tw.id).notes[kind] = ta.value; save(); summary(); };
    lab.appendChild(ta); sec.appendChild(lab);
  }
  const combo = el("div", "combo");
  combo.appendChild(el("div", "combo-head", "Your combination"));
  const cv = cardCanvas(480, 300); register(cv, tw, () => lookOf(tw), () => animOf(tw), 110); combo.appendChild(cv);
  const cap = el("div", "desc combo-cap"); combo.appendChild(cap); combo._cap = cap; combo._tw = tw;
  sec.appendChild(combo); combos.push(combo);
  root.appendChild(sec);
}
const combos = [];
function refresh() {
  document.querySelectorAll("button.pick").forEach((b) => b._sync && b._sync());
  for (const c of combos) { const tw = c._tw, l = lookOf(tw), a = animOf(tw); c._cap.textContent = `Look ${l.key} ${l.name} · animation ${a.key} ${a.name}` + (st(tw.id).look ? "" : " (option A until you pick)"); }
  summary();
}
function summary() {
  const out = [PAGE.title];
  for (const tw of TOWERS) {
    const s0 = st(tw.id), l = tw.looks.find((x) => x.key === s0.look), a = tw.anims.find((x) => x.key === s0.anim);
    let line = `${tw.name}: look ${l ? l.key + " " + l.name : "-"}, animation ${a ? a.key + " " + a.name : "-"}`;
    const n = [];
    if ((s0.notes.look || "").trim()) n.push("look: " + s0.notes.look.trim().replace(/\s+/g, " "));
    if ((s0.notes.anim || "").trim()) n.push("animation: " + s0.notes.anim.trim().replace(/\s+/g, " "));
    if (n.length) line += "; notes: " + n.join(" | ");
    out.push(line);
  }
  const ta = document.getElementById("summary"); if (ta) { ta.value = out.join("\n"); ta.rows = out.length + 1; }
}
function boot() {
  const root = document.getElementById("towers");
  for (const tw of TOWERS) buildTower(tw, root);
  refresh();
  document.getElementById("copy").onclick = () => { const ta = document.getElementById("summary"), b = document.getElementById("copy");
    const done = () => { b.textContent = "Copied"; setTimeout(() => { b.textContent = "Copy picks and notes"; }, 1500); };
    try { navigator.clipboard.writeText(ta.value).then(done, () => ta.select()); } catch (e) { ta.select(); } };
  document.getElementById("clear").onclick = () => { if (!confirm("Clear this page's picks and notes?")) return; state = {}; save(); location.reload(); };
  const t0 = performance.now();
  const tick = () => { const t = (performance.now() - t0) / 1000; for (const v of views) if (v.visible) v.frame(t); requestAnimationFrame(tick); };
  requestAnimationFrame(tick);
}
if (typeof document !== "undefined") boot();
