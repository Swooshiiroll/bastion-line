// ---- Tower art page 4: towers 16-20, in the style of today's in-game towers (owner, 2026-10-16) ----------
// Shared style helpers (and the stand-in neighbour towers) come from game_style.js.
const PAGE = { title: "Tower art page 4 (towers 16-20)", store: "bl-tower-art-4-game-v2" };

const rnd = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const distTo = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const nearestTo = (p, list) => { let best = null, bd = 1e9; for (const e of list) { const d = distTo(e.p, p); if (d < bd) { bd = d; best = e; } } return best; };
const enemyR = (s) => Math.max(4, Math.min(11, s * 0.12));
function txt(p, str, col, px) { X.save(); X.font = "bold " + Math.round(px) + "px sans-serif"; X.textAlign = "center"; X.fillStyle = css(OUTLINE); X.fillText(str, p[0] + 1, p[1] + 1); X.fillStyle = css(col); X.fillText(str, p[0], p[1]); X.restore(); }
const GOLDC = [1, 0.78, 0.3, 1], COPPER = [0.78, 0.5, 0.28, 1], RUST = [0.45, 0.3, 0.2, 1];

// ---- Shockwave Generator: a wave every 1.75 s hits every enemy within 100 px ------------------------------------
function shockAgent(cfg) { return (m, t, info, s, col) => { if (!m.hit) { m.hit = {}; m.wave = t; }
  if (t - m.wave >= 1.75) m.wave = t;
  const R = s * 100 / 48, raw = (t - m.wave) / cfg.travel; cfg.draw(info.c, Math.min(1, raw), R, s, col, t, raw);
  for (const e of info.ens) { if (raw <= 1 && Math.abs(distTo(e.p, info.c) - R * raw) < s * 0.2 && !(m.hit[e.i] > m.wave)) m.hit[e.i] = t;
    const h = t - (m.hit[e.i] ?? -9); if (h < 0.3) { glowDot(e.p, enemyR(s) * (1 - h / 0.3), [1, 1, 0.9, 1]); ring(e.p, enemyR(s) + h * 20, A(col, 1 - h / 0.3), 1.5); } } }; }

// ---- Magneto Tower: a constant field that slows everything in it; enemies lean toward the magnet --------------------
function magnetAgent(cfg) { return (m, t, info, s, col) => { const R = s * 120 / 48; cfg.draw(info.c, R, s, col, t);
  for (const e of info.ens) { const d = distTo(e.p, info.c); if (d > R) continue; const dir = norm(sub(info.c, e.p)), q = add(e.p, mul(dir, enemyR(s) + 3));
    line(q, add(q, mul(dir, s * 0.12)), A(col, 0.85), 1.6); fill(add(q, mul(dir, s * 0.12)), [[3, 0], [-1, 2.2], [-1, -2.2]], A(col, 0.85), Math.atan2(dir[1], dir[0]), 1);
    if (cfg.mark) cfg.mark(e, s, col, t, d / R, info.c); } }; }

// ---- Tractor Tower: grabs one enemy, hauls it 80 px back along the track for 1.5 s, lets go, recharges ------------
// The preview can't move the real enemy, so it hides it and draws the held one where the beam drags it.
const CYCLE = 4; // the real recharge is 6 s; the preview shortens it
function tractorAgent(cfg) { return (m, t, info, s, col) => { const back = s * 80 / 48;
  if (!m.state) { m.state = "ready"; m.t0 = t; }
  if (m.state === "ready") { const e = nearestTo(info.c, info.ens.filter((x) => distTo(x.p, info.c) < s * 3.3 && x.p[0] > s * 0.6)); if (e) { m.state = "hold"; m.t0 = t; m.id = e.i; m.p0 = e.p.slice(); m.air = e.air; } }
  if (m.state === "hold" || m.state === "drop") { const e = info.all.find((x) => x.i === m.id), u = Math.min(1, (t - m.t0) / 1.5);
    if (!e) { m.state = "cool"; m.t0 = t; return; }
    const held = add(m.p0, [-back * ease(u), m.air ? Math.sin(t * 6) * 2 : 0]);
    if (m.state === "hold") { m.aimAt = held; disc(e.p, enemyR(s) + 2, e.air ? [0.072, 0.093, 0.08, 0.92] : [0.16, 0.15, 0.13, 0.92]);
      cfg.beam(info.muzzleAt(0, info.aim), held, u, s, col, t); for (let i = 1; i <= 2; i++) { X.save(); X.globalAlpha = 0.25 / i; drawEnemy({ ...e, p: add(held, [i * 5, 0]) }, s); X.restore(); }
      drawEnemy({ ...e, p: held }, s); if (cfg.held) cfg.held(held, s, col, t); if (u >= 1) { m.state = "drop"; m.t0 = t; m.final = held; } }
    else { const v = (t - m.t0) / 0.4; X.save(); X.globalAlpha = Math.max(0, 1 - v); drawEnemy({ ...e, p: m.final }, s); X.restore(); disc(e.p, enemyR(s) + 2, A(e.air ? [0.072, 0.093, 0.08, 1] : [0.16, 0.15, 0.13, 1], 0.92 * Math.max(0, 1 - v))); if (v >= 1) { m.state = "cool"; m.t0 = t; } } }
  if (m.state === "cool") { m.aimAt = null; if (t - m.t0 > CYCLE - 1.9) m.state = "ready"; }
  m.charge = m.state === "cool" ? Math.min(1, (t - m.t0) / (CYCLE - 1.9)) : m.state === "ready" ? 1 : 0; }; }

// ---- Augmentation Tower: links to neighbour towers; at stock they get a 5% crit chance -------------------------
function augmentAgent(cfg) { return (m, t, info, s, col) => { if (!m.shots) { m.shots = []; m.n = 0; }
  matesOf(info).forEach((mt, i) => { const foe = nearestTo(mt.p, info.ens), aim = foe ? Math.atan2(foe.p[1] - mt.p[1], foe.p[0] - mt.p[0]) : undefined;
    cfg.link(info.c, mt.p, s, col, t, i); mateTower(mt.p, G(s), mt.col, t, 0, col, aim);
    if (foe && fmod(t * 1.2 + i * 0.33, 1) < 0.02 && t - (m.last?.[i] ?? -9) > 0.5) { (m.last ||= {})[i] = t; m.n++; m.shots.push({ t0: t, from: P(mt.p, aim, G(s) * 0.75, 15, 0), id: foe.i, crit: m.n % 3 === 0 }); } });
  m.shots = m.shots.filter((q) => t - q.t0 < 0.8);
  for (const q of m.shots) { const e = info.ens.find((x) => x.i === q.id); if (!e) continue; const u = (t - q.t0) / 0.18;
    if (u < 1) tracer(q.from, e.p, u, q.crit ? GOLDC : [1, 0.9, 0.7, 1], q.crit ? 2.2 : 1.4, 0.3); else if (q.crit) cfg.crit(e.p, (u - 1) * 0.18 / 0.6, s, col); else spark(e.p, (u - 1) * 0.18 / 0.6, s * 0.6, [1, 0.9, 0.7, 1]); } }; }
function critBurst(p, v, s) { if (v >= 1) return; glowDot(p, s * 0.1 * (1 - v), GOLDC); for (let i = 0; i < 6; i++) { const d = fa(i * TAU / 6 + 0.3); line(add(p, mul(d, s * (0.06 + 0.2 * v))), add(p, mul(d, s * (0.12 + 0.24 * v))), A(GOLDC, 1 - v), 1.4); } txt(add(p, [0, -s * 0.22 - v * s * 0.2]), "CRIT", A(GOLDC, 1 - v), Math.max(9, s * 0.15)); }

// ---- Scrapyard: a 2x2 yard that pays at each round's clear (the preview pays every 4 s) ----------------------------
function scrapPile(p, r, k, seed) { const pts = []; for (let i = 0; i < 9; i++) { const a = i * TAU / 9; pts.push([Math.cos(a) * r * (0.65 + 0.35 * rnd(seed + i)), Math.sin(a) * r * (0.65 + 0.35 * rnd(seed + i + 20))]); }
  ellipse(add(p, [k * 1.5, k * 2.5]), r * k, r * k * 0.5, [0, 0, 0, 0.3]); solid(p, pts, mix(RUST, METAL, 0.4), 0, k, 1);
  for (let i = 0; i < 5; i++) { const q = add(p, [(rnd(seed + i * 3) - 0.5) * r * k * 1.1, (rnd(seed + i * 5) - 0.5) * r * k * 0.9]); line(q, add(q, mul(fa(rnd(seed + i) * TAU), r * k * 0.35)), i % 2 ? METAL_L : RUST, 1.4 * k); } }
function yardBase(c, k, col, t) { const h = 46; ellipse(add(c, [0, 8 * k]), 44 * k, 16 * k, [0, 0, 0, 0.3]); plate(c, rectPts(h, h), lt(METAL_D, 0.04), 0, k, 1.3); fill(c, rectPts(h - 4, h - 4), [0.2, 0.19, 0.17, 1], 0, k);
  outline(c, rectPts(h - 2, h - 2), A(col, 0.5 + 0.2 * Math.sin(t * 2.2)), 1.4 * k, 0, k); for (let i = -4; i <= 4; i++) for (const sg of [-1, 1]) { disc(add(c, [i * 10 * k, sg * (h - 2) * k]), 1.1 * k, METAL_L); disc(add(c, [sg * (h - 2) * k, i * 10 * k]), 1.1 * k, METAL_L); } }
function scrapAgent(cfg) { return (m, t, info, s, col) => { if (!m.pays) { m.pays = []; m.last = t; }
  if (t - m.last >= 4) { m.last = t; m.pays.push(t); } m.pays = m.pays.filter((q) => t - q < 1.6);
  if (cfg.extra) cfg.extra(m, t, info, s, col);
  for (const q of m.pays) { const v = (t - q) / 1.6; cfg.pay(info.c, v, s, col, t); } }; }
function coinPop(c, v, s, col) { for (let i = 0; i < 6; i++) { const d = fa(-Math.PI / 2 + (i - 2.5) * 0.35), p = add(add(c, mul(d, s * 0.5 * Math.min(1, v * 2))), [0, v * v * s * 0.4]); disc(p, s * 0.045 + 1, A(OUTLINE, 0.95 * (1 - v))); disc(p, s * 0.045, A(GOLDC, 1 - v)); }
  txt(add(c, [0, -s * 0.4 - v * s * 0.5]), "+100", A(GOLDC, Math.min(1, 2 - v * 2)), Math.max(11, s * 0.2)); }

const TOWERS = [
  // 16. Shockwave Generator -----------------------------------------------------------------------------
  { id: "shock", num: 16, name: "Shockwave Generator", cls: "Assault", weapon: "Field", hits: "both", color: [1.00, 0.70, 0.28, 1],
    desc: "Generates powerful shockwaves by creating small nuclear explosions. \"Radioactive fallout? What radioactive fallout?\" A wave every 1.75 s hits every enemy within 100 px (cloaked ones too); no aiming. Enemies flash as the wave passes them. (Colour: today's Nova Reactor amber.)",
    looks: [
      { key: "A", name: "Caged Reactor", muzzle: 0, fixed: true, theme: "A squat reactor in a heavy containment cage: corner posts and bars round a glowing core seen through its vents.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, fl = decay(t - (mm.wave ?? -9), 0.4); deck(c, k, col, t);
          orb(c, 8 * k, METAL); for (let i = 0; i < 8; i++) { const a = i * TAU / 8; line(add(c, mul(fa(a), 3 * k)), add(c, mul(fa(a), 6.5 * k)), A(col, 0.4 + 0.5 * fl), 1.3 * k); } glowDot(c, (2 + 3 * fl) * k, lt(col, 0.3 * fl));
          const sq = [[-11, -11], [11, -11], [11, 11], [-11, 11]].map((q) => add(c, mul(q, k))); for (let i = 0; i < 4; i++) { bar(sq[i], sq[(i + 1) % 4], 2.2 * k, METAL_L); plate(sq[i], rectPts(2.4, 2.4), METAL_D, 0, k, 1); }
          for (const x of [-5.5, 0, 5.5]) { bar(add(c, [x * k, -11 * k]), add(c, [x * k, -8.4 * k]), 1.4 * k, METAL_L); bar(add(c, [x * k, 11 * k]), add(c, [x * k, 8.4 * k]), 1.4 * k, METAL_L); } } },
      { key: "B", name: "Ring Reactor", muzzle: 0, fixed: true, theme: "A thick toroidal containment ring held by three clamps round a blinding core; the ring glows when it fires.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, fl = decay(t - (mm.wave ?? -9), 0.4); deck(c, k, col, t);
          ring(c, 10 * k, OUTLINE, 6.4 * k); ring(c, 10 * k, METAL_L, 5 * k); arc(c, 10 * k, Math.PI * 1.05, Math.PI * 1.6, lt(METAL_L, 0.4), 1.4 * k); ring(c, 10 * k, A(col, 0.2 + 0.7 * fl), 1.4 * k);
          for (let i = 0; i < 3; i++) plate(add(c, mul(fa(-Math.PI / 2 + i * TAU / 3), 10 * k)), rectPts(2, 3.6), METAL_D, -Math.PI / 2 + i * TAU / 3, k, 1);
          disc(c, 5.5 * k, [0.08, 0.06, 0.04, 1]); glowDot(c, (2.4 + 3 * fl) * k, lt(col, 0.2 + 0.4 * fl)); } },
      { key: "C", name: "Piston Thumper", muzzle: 0, fixed: true, theme: "A reactor drum ringed by four heavy pistons that punch outward on every wave, the core flaring in the middle.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, fl = decay(t - (mm.wave ?? -9), 0.35); deck(c, k, col, t);
          for (let i = 0; i < 4; i++) { const a = Math.PI / 4 + i * Math.PI / 2, d = fa(a), ext = 11 + 3.5 * fl; bar(add(c, mul(d, 5 * k)), add(c, mul(d, ext * k)), 3.4 * k, METAL); plate(add(c, mul(d, ext * k)), rectPts(1.6, 3.6), METAL_L, a, k, 1); }
          plate(c, ngon(8, 1, Math.PI / 8), METAL_L, 0, 8 * k, 1.3); rivets(c, ngon(8, 1, Math.PI / 8), 0, 8 * k, 0.82, 0.7 * k); disc(c, 4 * k, [0.08, 0.06, 0.04, 1]); glowDot(c, (1.6 + 3 * fl) * k, col); } },
    ],
    anims: [
      { key: "A", name: "Blast Ring", desc: "The core flashes and a bright ring of force bursts out to the edge of range; every enemy it crosses flashes white.", period: 1, flight: 1, fx: () => ({}),
        persist: shockAgent({ travel: 0.4, draw: (c, u, R, s, col, t, raw) => { if (raw > 1.4) return; const a = Math.max(0, 1 - raw / 1.4);
          if (raw < 0.15) glowDot(c, s * 0.3 * (1 - raw / 0.15), [1, 0.95, 0.8, 1]); disc(c, R * u, A(col, 0.08 * a)); ring(c, R * u, A([1, 0.95, 0.8, 1], 0.8 * a), 3); ring(c, R * u, A(col, 0.6 * a), 6); } }) },
      { key: "B", name: "Mushroom Pulse", desc: "The core flares into a tiny mushroom cloud: a rising fireball with rings rolling out along the ground under it.", period: 1, flight: 1, fx: () => ({}),
        persist: shockAgent({ travel: 0.6, draw: (c, u, R, s, col, t, raw) => { if (raw > 1.8) return; const a = Math.max(0, 1 - raw / 1.8);
          for (let j = 0; j < 2; j++) { const q = u - j * 0.2; if (q > 0) ring(c, R * q, A(col, 0.7 * a * (1 - j * 0.4)), 2.5 - j); }
          const up = Math.min(1, raw) * s * 0.5; disc(add(c, [0, -up * 0.5]), s * 0.06, A([0.4, 0.35, 0.3, 1], 0.7 * a)); disc(add(c, [0, -up]), s * (0.12 + 0.1 * Math.min(1, raw)), A(mix(col, [0.4, 0.35, 0.3, 1], Math.min(1, raw)), 0.75 * a)); } }) },
      { key: "C", name: "Double Shock", desc: "A fast thin ring snaps out, then a slower, heavier ring follows it, kicking up dust along its edge.", period: 1, flight: 1, fx: () => ({}),
        persist: shockAgent({ travel: 0.6, draw: (c, u, R, s, col, t, raw) => { if (raw > 1.5) return; const a = Math.max(0, 1 - raw / 1.5);
          const fast = Math.min(1, raw * 2.2); if (fast < 1) ring(c, R * fast, A([1, 0.95, 0.85, 1], 0.8 * (1 - fast)), 1.5);
          ring(c, R * u, A(col, 0.85 * a), 4); for (let i = 0; i < 14; i++) disc(add(c, mul(fa(i * TAU / 14 + 0.2), R * u)), s * 0.06 * a, [0.55, 0.5, 0.42, 0.5 * a]); } }) },
    ] },

  // 17. Scrapyard ---------------------------------------------------------------------------------------
  { id: "scrap", num: 17, name: "Scrapyard", cls: "Utility", weapon: "None", hits: "none", size: 2, center: [0.3, 0.4], color: [0.95, 0.72, 0.42, 1],
    desc: "Various collections of scrap metal sold at a profit. \"One mans toxic waste is another mans potpourri\" A 2×2 yard; it attacks nothing and pays 100 credits at each round's clear (the preview pays every 4 s). (Colour: today's Scrapyard copper.)",
    looks: [
      { key: "A", name: "Crusher Yard", muzzle: 0, fixed: true, theme: "A fenced yard of rusting scrap heaps with a hydraulic crusher block in one corner and a swinging crane in the other.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, thump = decay(t - (mm.last ?? -9), 0.3); yardBase(c, k, col, t);
          scrapPile(add(c, [-18 * k, 14 * k]), 14, k, 1); scrapPile(add(c, [14 * k, 20 * k]), 11, k, 7); scrapPile(add(c, [-20 * k, -16 * k]), 9, k, 13);
          const cr = add(c, [20 * k, -20 * k]); plate(cr, rectPts(10, 10), METAL_L, 0, k, 1.3); plate(cr, rectPts(6.5 - 2 * thump, 6.5 - 2 * thump), METAL, 0, k, 1); hazard(cr, 0, k, -8, 8, 11, col, 1.4); glowDot(add(cr, [7 * k, -7 * k]), 1 * k, col);
          const base = add(c, [-4 * k, 0]), a = Math.sin(t * 0.6) * 1.2 - 0.6, tip = add(base, mul(fa(a), 26 * k)); orb(base, 3.4 * k, METAL); bar(base, tip, 2.4 * k, [0.85, 0.65, 0.2, 1]); line(tip, add(tip, [0, 5 * k]), METAL_D, 0.8 * k); disc(add(tip, [0, 5 * k]), 2 * k, METAL_L); } },
      { key: "B", name: "Compactor Plant", muzzle: 0, fixed: true, theme: "A corrugated compactor shed with a conveyor carrying scrap in and neat stacked bales of crushed metal coming out.",
        draw(c, aim, s, fx, t, col) { const k = G(s); yardBase(c, k, col, t); const sh = add(c, [-12 * k, -12 * k]); plate(sh, rectPts(18, 14), METAL_L, 0, k, 1.3); for (let i = -3; i <= 3; i++) line(add(sh, [i * 5 * k, -13 * k]), add(sh, [i * 5 * k, 13 * k]), [0, 0, 0, 0.3], 1);
          plate(add(c, [12 * k, -12 * k]), rectPts(14, 3.4), METAL_D, 0, k, 1); for (let i = 0; i < 4; i++) { const x = 1 + fmod(t * 6 + i * 7, 26); scrapPile(add(c, [(26 - x) * k, -12 * k]), 2.4, k, i * 3); }
          for (let i = 0; i < 3; i++) for (let j = 0; j < 2; j++) plate(add(c, [(-18 + i * 9) * k, (14 + j * 9) * k]), rectPts(4, 4), mix(RUST, METAL_L, 0.3 + 0.2 * ((i + j) % 2)), 0, k, 1);
          scrapPile(add(c, [22 * k, 20 * k]), 11, k, 21); glowDot(add(sh, [14 * k, 10 * k]), 1 * k, col); } },
      { key: "C", name: "Magnet Yard", muzzle: 0, fixed: true, theme: "Scrap heaps under a big crane boom with an electromagnet disc that lifts wreckage and drops it in a hopper.",
        draw(c, aim, s, fx, t, col) { const k = G(s); yardBase(c, k, col, t); scrapPile(add(c, [-18 * k, 16 * k]), 15, k, 3); scrapPile(add(c, [18 * k, 18 * k]), 12, k, 9); scrapPile(add(c, [-20 * k, -18 * k]), 10, k, 17);
          plate(add(c, [20 * k, -20 * k]), rectPts(8, 8), METAL_D, 0, k, 1.2); fill(add(c, [20 * k, -20 * k]), rectPts(5, 5), BORE, 0, k);
          const a = -0.4 + Math.sin(t * 0.5) * 1.6, tip = add(c, mul(fa(a), 30 * k)); plate(c, ngon(6, 1, 0), METAL_L, a, 6 * k, 1.2); bar(c, tip, 3 * k, [0.85, 0.65, 0.2, 1]);
          disc(tip, 5 * k, OUTLINE); disc(tip, 4.4 * k, METAL); ring(tip, 3 * k, A(col, 0.7), 1 * k); if (Math.sin(t * 0.5) < 0) scrapPile(add(tip, [0, 5 * k]), 3, k, 5); } },
    ],
    anims: [
      { key: "A", name: "Round Payout", desc: "At each round's clear a spray of credit coins pops out of the yard with a floating +100, and the crusher thumps.", period: 1, flight: 1, fx: () => ({}),
        persist: scrapAgent({ pay: (c, v, s, col) => coinPop(c, v, s, col) }) },
      { key: "B", name: "Sparks and Sale", desc: "Cutting sparks fly from the heaps all the time; at the payout a stack of credits flashes on the yard and the +100 rises from it.", period: 1, flight: 1, fx: () => ({}),
        persist: scrapAgent({ extra: (m, t, info, s) => { for (let i = 0; i < 6; i++) { const q = fmod(t * 2.2 + i / 6, 1), o = add(info.c, [(rnd(Math.floor(t * 2.2 + i / 6) + i) - 0.5) * s * 1.2, (rnd(i + 3) - 0.5) * s]); disc(add(o, mul(fa(-1.2 - i * 0.3), q * s * 0.2)), 1.2, [1, 0.8, 0.4, 1 - q]); } },
          pay: (c, v, s, col) => { if (v < 0.3) glowDot(c, s * 0.3 * (1 - v / 0.3), GOLDC); for (let j = 0; j < 4; j++) { const p = add(c, [0, -j * s * 0.05]); ellipse(p, s * 0.12, s * 0.05, A(dk(GOLDC, 0.2), 1 - v)); } txt(add(c, [0, -s * 0.45 - v * s * 0.5]), "+100", A(GOLDC, Math.min(1, 2 - v * 2)), Math.max(11, s * 0.2)); } }) },
      { key: "C", name: "Wreck Collector", desc: "Shows the kill bonus too: an enemy wrecked near the yard bursts and its scrap flies into the yard as a coin; the round payout pops +100.", period: 1, flight: 1, fx: () => ({}),
        persist: scrapAgent({ extra: (m, t, info, s, col) => { const near = info.all.filter((e) => !e.air && distTo(e.p, info.c) < s * 3.1);
            if (near.length && (!m.kill || t - m.kill.t0 > 1.5)) { const e = near[Math.floor(rnd(Math.floor(t)) * near.length)]; m.kill = { t0: t, p: e.p.slice() }; }
            if (m.kill) { const v = (t - m.kill.t0) / 1.0; if (v < 0.3) blast(m.kill.p, v / 0.3, s, col, 0.25); if (v < 1) { const p = add(lerp(m.kill.p, info.c, v), [0, -Math.sin(Math.PI * v) * s * 0.5]); disc(p, s * 0.05 + 1, OUTLINE); disc(p, s * 0.05, GOLDC); if (v < 0.5) txt(add(m.kill.p, [0, -s * 0.25 - v * s * 0.3]), "+5", A(GOLDC, 1 - v * 2), Math.max(9, s * 0.15)); } } },
          pay: (c, v, s, col) => coinPop(c, v, s, col) }) },
    ] },

  // 18. Magneto Tower -----------------------------------------------------------------------------------
  { id: "magneto", num: 18, name: "Magneto Tower", cls: "Defense", weapon: "Field", hits: "both", color: [0.60, 0.45, 1.00, 1],
    desc: "A massive electromagnet that magnetically pulls against enemies in range, slowing them down and pulling off armor. \"Yeah, science!\" A constant 120 px field slows every enemy in it (heavier roles resist); enemies inside show a pull arrow toward the magnet. (Colour: today's Gravity Well violet, close to the Tesla's purple.)",
    looks: [
      { key: "A", name: "Horseshoe Magnet", muzzle: 0, fixed: true, theme: "A giant horseshoe magnet seen from above, red and grey pole tips facing the track, its base wound with copper coil.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); arc(c, 9 * k, Math.PI * 0.85, Math.PI * 2.15, OUTLINE, 7.4 * k); arc(c, 9 * k, Math.PI * 0.85, Math.PI * 2.15, METAL_L, 6 * k);
          for (let i = 0; i < 9; i++) { const a = Math.PI * 0.95 + i * 0.13; line(add(c, mul(fa(a), 6.4 * k)), add(c, mul(fa(a), 11.6 * k)), COPPER, 1 * k); }
          plate(add(c, [-8 * k, 6 * k]), rectPts(3.4, 3), [0.85, 0.2, 0.2, 1], 0, k, 1); plate(add(c, [8 * k, 6 * k]), rectPts(3.4, 3), [0.6, 0.62, 0.66, 1], 0, k, 1); glowDot(add(c, [0, 6 * k]), 1.2 * k, col); } },
      { key: "B", name: "Coil Drum", muzzle: 0, fixed: true, theme: "A massive round electromagnet drum wound in copper bands under a heavy pole cap, humming with a violet glow at its edge.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); disc(c, 13 * k, OUTLINE); disc(c, 12.3 * k, COPPER); for (let i = 0; i < 5; i++) ring(c, (8.6 + i * 0.8) * k, dk(COPPER, 0.25 * (i % 2)), 0.7 * k);
          orb(c, 8 * k, METAL_L); fill(c, rectPts(4, 4), [0.85, 0.2, 0.2, 1], Math.PI / 4, k); ring(c, 12.6 * k, A(col, 0.4 + 0.3 * Math.sin(t * 6)), 1 * k); } },
      { key: "C", name: "Twin Pole Pylons", muzzle: 0, fixed: true, theme: "Two squat pole pylons, one red and one grey, joined by a coil bridge; field lines arc between them.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); bar(add(c, [-8 * k, 0]), add(c, [8 * k, 0]), 5 * k, METAL); for (let i = -4; i <= 4; i++) line(add(c, [i * 1.4 * k, -2.4 * k]), add(c, [i * 1.4 * k, 2.4 * k]), COPPER, 0.9 * k);
          for (const [x, cc] of [[-9, [0.85, 0.2, 0.2, 1]], [9, [0.6, 0.62, 0.66, 1]]]) { disc(add(c, [x * k, 0]), 5.4 * k, OUTLINE); orb(add(c, [x * k, 0]), 4.8 * k, cc); }
          for (let i = 0; i < 3; i++) { const h = (3 + i * 2.6) * k; X.strokeStyle = css(A(col, 0.5 - i * 0.12)); X.lineWidth = 1; X.beginPath(); X.moveTo(c[0] - 9 * k, c[1]); X.quadraticCurveTo(c[0], c[1] - h * 2.2, c[0] + 9 * k, c[1]); X.stroke(); } } },
      { key: "D", name: "Ring Electromagnet", muzzle: 0, fixed: true, theme: "A big flat ring magnet lying on the deck, its rim split into alternating red and grey pole segments with copper windings between.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); ring(c, 10.5 * k, OUTLINE, 7.4 * k);
          for (let i = 0; i < 8; i++) { const a0 = i * TAU / 8 + 0.06, a1 = (i + 1) * TAU / 8 - 0.06; arc(c, 10.5 * k, a0, a1, i % 2 ? [0.6, 0.62, 0.66, 1] : [0.85, 0.2, 0.2, 1], 6 * k); line(add(c, mul(fa(a1 + 0.06), 7.6 * k)), add(c, mul(fa(a1 + 0.06), 13.4 * k)), COPPER, 1.2 * k); }
          orb(c, 5 * k, METAL); glowDot(c, 1.3 * k, col); ring(c, 13.6 * k, A(col, 0.3 + 0.3 * Math.sin(t * 5)), 1 * k); } },
      { key: "E", name: "Lifting Magnet Crane", muzzle: 0, fixed: true, theme: "A short crane boom on a turntable carrying a huge round lifting magnet that sweeps slowly back and forth over the field.",
        draw(c, aim, s, fx, t, col) { const k = G(s), a = -0.4 + Math.sin(t * 0.4) * 0.9, tip = add(c, mul(fa(a), 13 * k)); deck(c, k, col, t); plate(c, ngon(8, 1, Math.PI / 8), METAL_L, a, 7 * k, 1.2);
          bar(c, tip, 3 * k, [0.85, 0.65, 0.2, 1]); disc(tip, 7 * k, OUTLINE); disc(tip, 6.3 * k, METAL); ring(tip, 4.6 * k, COPPER, 1.4 * k); disc(tip, 2.4 * k, [0.85, 0.2, 0.2, 1]); ring(tip, 7.6 * k, A(col, 0.4 + 0.3 * Math.sin(t * 6)), 1 * k); orb(c, 2.6 * k, METAL); } },
      { key: "F", name: "Stacked Coil Tower", muzzle: 0, fixed: true, theme: "Three coil rings stacked into a stepped tower, each smaller than the one below, topped with a red pole cap that glows as the field hums.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t);
          for (const [r, w] of [[12, 3.2], [8.6, 2.8], [5.4, 2.4]]) { ring(c, r * k, OUTLINE, (w + 1.4) * k); ring(c, r * k, COPPER, w * k); arc(c, r * k, Math.PI * 1.05, Math.PI * 1.6, lt(COPPER, 0.4), w * 0.35 * k); }
          orb(c, 3 * k, [0.85, 0.2, 0.2, 1]); glowDot(c, (1 + 0.5 * Math.sin(t * 5)) * k, col); } },
    ],
    anims: [
      { key: "A", name: "Field Lines", desc: "Shimmering field lines loop out from the magnet's poles across the field; enemies inside lean toward the magnet.", period: 1, flight: 1, fx: () => ({}),
        persist: magnetAgent({ draw: (c, R, s, col, t) => { ring(c, R, A(col, 0.25), 1); for (let i = 0; i < 6; i++) { const a = i * TAU / 6 + t * 0.15, w = R * (0.5 + 0.08 * Math.sin(t * 3 + i));
            X.strokeStyle = css(A(col, 0.25 + 0.15 * Math.sin(t * 4 + i))); X.lineWidth = 1.2; X.beginPath(); X.ellipse(c[0] + Math.cos(a) * w, c[1] + Math.sin(a) * w, w, w * 0.4, a, 0, TAU); X.stroke(); } } }) },
      { key: "B", name: "Pulse Pull", desc: "Rings of force keep contracting in toward the magnet, as if reeling the field in; pulled enemies jitter toward it.", period: 1, flight: 1, fx: () => ({}),
        persist: magnetAgent({ draw: (c, R, s, col, t) => { ring(c, R, A(col, 0.3), 1.2); for (let i = 0; i < 3; i++) { const q = 1 - fmod(t * 0.6 + i / 3, 1); ring(c, R * q, A(col, 0.55 * (1 - q) + 0.1), 2); } },
          mark: (e, s, col, t) => ring(add(e.p, [Math.sin(t * 30 + e.i) * 1.2, 0]), enemyR(s) + 2, A(col, 0.5), 1) }) },
      { key: "C", name: "Iron Filings", desc: "Glinting metal filings drift round the field along its lines, and sparks snap off the enemies being pulled.", period: 1, flight: 1, fx: () => ({}),
        persist: magnetAgent({ draw: (c, R, s, col, t) => { disc(c, R, A(col, 0.05)); for (let i = 0; i < 40; i++) { const r = R * (0.2 + 0.8 * rnd(i)), a = rnd(i + 40) * TAU + t * (0.3 + 0.6 * (1 - r / R)), p = add(c, mul(fa(a), r));
            line(p, add(p, mul(fa(a + Math.PI / 2), 3)), [0.75, 0.75, 0.8, 0.6], 1); } },
          mark: (e, s, col, t) => { if (fmod(t * 3 + e.i * 0.3, 1) < 0.25) for (let i = 0; i < 3; i++) line(e.p, add(e.p, mul(fa(rnd(Math.floor(t * 12) + i + e.i) * TAU), enemyR(s) + 4)), A(lt(col, 0.4), 0.9), 1); } }) },
      { key: "D", name: "Spark Arcs", desc: "Violet arcs crackle from the magnet out to every enemy in its field, flickering as they're dragged against the pull.", period: 1, flight: 1, fx: () => ({}),
        persist: magnetAgent({ draw: (c, R, s, col, t) => { disc(c, R, A(col, 0.05)); ring(c, R, A(col, 0.3), 1); },
          mark: (e, s, col, t, fr, c) => { if (fmod(t * 4 + e.i * 0.37, 1) > 0.6) return; const pts = [c]; for (let j = 1; j < 6; j++) pts.push(add(lerp(c, e.p, j / 6), mul(orth(norm(sub(e.p, c))), (rnd(Math.floor(t * 20) + j + e.i) - 0.5) * s * 0.2))); pts.push(e.p);
            polyline(pts, A(col, 0.3), 3); polyline(pts, A(lt(col, 0.3), 0.9), 1); } }) },
      { key: "E", name: "Gravity Ripple", desc: "The ground inside the field darkens and ripples inward in rings toward the magnet, like a well; enemies inside dip and slow.", period: 1, flight: 1, fx: () => ({}),
        persist: magnetAgent({ draw: (c, R, s, col, t) => { disc(c, R, [0, 0, 0, 0.18]); disc(c, R * 0.6, [0, 0, 0, 0.12]); for (let i = 0; i < 5; i++) { const q = 1 - fmod(t * 0.4 + i / 5, 1); ring(c, R * q, A(col, 0.12 + 0.3 * q * (1 - q) * 4 * 0.5), 1.5); } },
          mark: (e, s, col, t) => ellipse(add(e.p, [0, enemyR(s) * 0.8]), enemyR(s) * 1.2, enemyR(s) * 0.45, A(col, 0.35)) }) },
      { key: "F", name: "Drag Trails", desc: "Enemies in the field smear behind themselves as they're held back, leaving violet drag trails, and the field's edge glows where they cross it.", period: 1, flight: 1, fx: () => ({}),
        persist: magnetAgent({ draw: (c, R, s, col, t) => { ring(c, R, A(col, 0.45), 2); ring(c, R - 3, A(col, 0.15), 3); },
          mark: (e, s, col, t) => { for (let i = 1; i <= 4; i++) disc(sub(e.p, [i * enemyR(s) * 0.6, 0]), enemyR(s) * (1 - i * 0.15), A(col, 0.25 - i * 0.05)); } }) },
    ] },

  // 19. Tractor Tower -----------------------------------------------------------------------------------
  { id: "tractor", num: 19, name: "Tractor Tower", cls: "Defense", weapon: "Energy", hits: "both", color: [0.40, 0.95, 1.00, 1],
    desc: "A dish-mounted emitter that locks a tractor beam onto a single enemy and hauls it back down the track before letting go. \"You're my friend now.\" It grabs one enemy, holds it 1.5 s while dragging it back 80 px, lets go, then recharges (6 s; the preview shortens it). The preview can't really move enemies, so the held one is redrawn where the beam drags it. (Colour: cyan, as the roster's look; close to the Gun Turret's.)",
    looks: [
      { key: "A", name: "Dish Emitter", muzzle: 13 / 48, theme: "A wide dish on a slim mast block with an emitter spike at its centre; a charge ring fills while it recharges.",
        draw(c, aim, s, fx, t, col) { const k = G(s), ch = fx.mem?.charge ?? 1; deck(c, k, col, t); plate(c, rectPts(5, 5), METAL, 0, k, 1.1);
          arc(c, 10 * k, aim - 1.2 + Math.PI, aim + 1.2 + Math.PI, OUTLINE, 4 * k); disc(P(c, aim, k, 2, 0), 9 * k, OUTLINE); disc(P(c, aim, k, 2, 0), 8.3 * k, METAL_L); disc(P(c, aim, k, 3, 0), 6.4 * k, METAL); bar(P(c, aim, k, 3, 0), P(c, aim, k, 13, 0), 1.6 * k, METAL_L);
          arc(c, 11.5 * k, -Math.PI / 2, -Math.PI / 2 + TAU * ch, A(col, 0.8), 1.2 * k); glowDot(P(c, aim, k, 13, 0), (0.8 + ch) * k, col); } },
      { key: "B", name: "Gimbal Projector", muzzle: 12 / 48, theme: "Two gimbal rings turning round a lens projector; the rings spin up as it grabs and slow while it recharges.",
        draw(c, aim, s, fx, t, col) { const k = G(s), ch = fx.mem?.charge ?? 1, sp = fx.mem?.state === "hold" ? 6 : 1; deck(c, k, col, t);
          for (const [r, ph] of [[10, 0], [7, 1]]) { const a = t * sp * (ph ? -1 : 1); X.strokeStyle = css(OUTLINE); X.lineWidth = 3.4 * k; X.beginPath(); X.ellipse(c[0], c[1], r * k, r * k * Math.abs(Math.cos(a)) + 1, aim + ph, 0, TAU); X.stroke();
            X.strokeStyle = css(METAL_L); X.lineWidth = 2 * k; X.stroke(); }
          orb(c, 4 * k, METAL); bar(c, P(c, aim, k, 12, 0), 2 * k, METAL); glowDot(P(c, aim, k, 12, 0), (0.8 + ch) * k, col); } },
      { key: "C", name: "Claw Emitter", muzzle: 15 / 48, theme: "A stubby emitter barrel ending in three clamp claws that close when it grabs, on a riveted turret.",
        draw(c, aim, s, fx, t, col) { const k = G(s), held = fx.mem?.state === "hold" ? 1 : 0; deck(c, k, col, t); plate(c, ngon(8, 1, Math.PI / 8), METAL_L, aim, 8 * k, 1.2); rivets(c, ngon(8, 1, Math.PI / 8), aim, 8 * k, 0.82, 0.7 * k);
          bar(c, P(c, aim, k, 12, 0), 4 * k, METAL); for (const sg of [-1, 0, 1]) { const base = P(c, aim, k, 11, sg * 2.6), tip = P(c, aim + sg * (0.5 - 0.35 * held), k, 17, sg * (3.6 - 2.4 * held)); bar(base, tip, 1.3 * k, METAL_L); }
          glowDot(P(c, aim, k, 13, 0), 1.2 * k, col); orb(c, 3 * k, METAL); } },
    ],
    anims: [
      { key: "A", name: "Beam Cone", desc: "A cyan cone of light widens from the emitter onto the enemy, which hovers with fading afterimages as it glides back down the track.", period: 1, flight: 1, fx: () => ({}),
        persist: tractorAgent({ beam: (f, to, u, s, col) => { const d = norm(sub(to, f)), o = orth(d), w = enemyR(s) + 4; poly([f, add(to, mul(o, w)), sub(to, mul(o, w))], A(col, 0.18)); line(f, add(to, mul(o, w)), A(col, 0.5), 1); line(f, sub(to, mul(o, w)), A(col, 0.5), 1); } }) },
      { key: "B", name: "Grapple Beam", desc: "A straight beam shoots out with rings sliding down it to the enemy, then the rings reel back in as it's hauled; the enemy shakes in the grip.", period: 1, flight: 1, fx: () => ({}),
        persist: tractorAgent({ beam: (f, to, u, s, col, t) => { beam(f, to, 1.8, col, 0.8); const d = norm(sub(to, f)), L = distTo(f, to);
            for (let i = 0; i < 4; i++) { const q = fmod(-t * 0.8 + i / 4, 1), p = add(f, mul(d, L * q)); X.strokeStyle = css(A(col, 0.8)); X.lineWidth = 1.4; X.beginPath(); X.ellipse(p[0], p[1], 2.5, 6, Math.atan2(d[1], d[0]), 0, TAU); X.stroke(); } },
          held: (p, s, col, t) => ring(add(p, [Math.sin(t * 40), 0]), enemyR(s) + 3, A(col, 0.7), 1.2) }) },
      { key: "C", name: "Spiral Lock", desc: "A twisting double-helix beam locks on and wraps the enemy in a glowing bubble that drifts back with it.", period: 1, flight: 1, fx: () => ({}),
        persist: tractorAgent({ beam: (f, to, u, s, col, t) => { const d = norm(sub(to, f)), o = orth(d), L = distTo(f, to); for (const ph of [0, Math.PI]) { const pts = []; for (let i = 0; i <= 24; i++) { const q = i / 24; pts.push(add(add(f, mul(d, L * q)), mul(o, Math.sin(q * 14 - t * 10 + ph) * s * 0.06))); } polyline(pts, A(col, 0.75), 1.3); }
            line(f, to, A(col, 0.25), 3); },
          held: (p, s, col, t) => { disc(p, enemyR(s) + 6, A(col, 0.12)); ring(p, enemyR(s) + 6, A(col, 0.6 + 0.2 * Math.sin(t * 8)), 1.4); arc(p, enemyR(s) + 4, Math.PI * 1.1, Math.PI * 1.5, [1, 1, 1, 0.6], 1); } }) },
    ] },

  // 20. Augmentation Tower ------------------------------------------------------------------------------
  { id: "augment", num: 20, name: "Augmentation Tower", cls: "Support", weapon: "None", hits: "none", color: [0.78, 0.71, 1.00, 1],
    desc: "Neighboring towers are given special augmentations to their weaponry through mysterious means. \"So my 12-guage shotgun shoots thermonuclear explosives now apparently.\" It attacks nothing; at stock, towers within 2 tiles get a 5% crit chance (every third stand-in shot crits here, so it shows). Links run in the effect colours: gold for crits, cyan for energy, green for ricochet. (Colour: a new lavender; no in-game counterpart.)",
    looks: [
      { key: "A", name: "Crystal Emitter", muzzle: 0, fixed: true, theme: "A hexagonal plinth crowned with one big faceted crystal that glows from inside, slowly pulsing.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); plate(c, ngon(6, 1, Math.PI / 6), METAL_L, 0, 9.5 * k, 1.2);
          const pu = 0.6 + 0.4 * Math.sin(t * 2); solid(c, [[0, -9], [5.5, -3], [4, 6], [0, 8.5], [-4, 6], [-5.5, -3]], A(mix(col, [1, 1, 1, 1], 0.2), 0.9), 0, k, 1);
          for (const q of [[0, -9], [5.5, -3], [4, 6], [-4, 6], [-5.5, -3]]) line(c, add(c, mul(q, k)), [1, 1, 1, 0.35], 0.8); glowDot(c, (1.4 + pu) * k, col); } },
      { key: "B", name: "Orbiting Shards", muzzle: 0, fixed: true, theme: "A low pedestal with three crystal shards circling above it on a slow orbit, trailing faint light.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); disc(c, 7 * k, OUTLINE); disc(c, 6.3 * k, METAL); ring(c, 4.5 * k, A(col, 0.6), 1 * k); glowDot(c, 1.4 * k, col);
          for (let i = 0; i < 3; i++) { const a = t * 1.2 + i * TAU / 3, p = add(c, mul(fa(a), 11 * k)); arc(c, 11 * k, a - 0.6, a, A(col, 0.3), 1.2 * k); solid(p, [[0, -3.6], [2, 0], [0, 3.6], [-2, 0]], A(lt(col, 0.2), 0.95), a, k, 0.8); } } },
      { key: "C", name: "Caged Prism", muzzle: 0, fixed: true, theme: "A triangular prism turning slowly inside a ring cage on four posts, splitting its light into the three effect colours.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); ring(c, 11 * k, OUTLINE, 3 * k); ring(c, 11 * k, METAL_L, 1.8 * k); for (let i = 0; i < 4; i++) orb(add(c, mul(fa(Math.PI / 4 + i * Math.PI / 2), 11 * k)), 1.8 * k, METAL);
          solid(c, ngon(3, 1, t * 0.5), A(mix(col, [1, 1, 1, 1], 0.3), 0.85), 0, 7.5 * k, 1);
          [GOLDC, [0.3, 0.9, 1, 1], [0.4, 1, 0.5, 1]].forEach((cc, i) => { const a = t * 0.5 + i * TAU / 3; line(c, add(c, mul(fa(a + Math.PI / 3), 10 * k)), A(cc, 0.6), 1 * k); }); glowDot(c, 1.2 * k, col); } },
      { key: "D", name: "Tuning Fork Spire", muzzle: 0, fixed: true, theme: "A two-pronged tuning-fork emitter on a round base, its prongs humming so that faint rings shiver off it.",
        draw(c, aim, s, fx, t, col) { const k = G(s), hum = Math.sin(t * 40) * 0.4; deck(c, k, col, t); disc(c, 8 * k, OUTLINE); disc(c, 7.3 * k, METAL);
          for (const sg of [-1, 1]) { bar(add(c, [sg * (3.4 + hum) * k, 4 * k]), add(c, [sg * (3.4 + hum) * k, -10 * k]), 2.2 * k, METAL_L); glowDot(add(c, [sg * (3.4 + hum) * k, -10 * k]), 0.9 * k, col); }
          bar(add(c, [-3.4 * k, 4 * k]), add(c, [3.4 * k, 4 * k]), 2.2 * k, METAL_L); for (let i = 0; i < 2; i++) { const q = fmod(t * 1.5 + i / 2, 1); ring(add(c, [0, -6 * k]), (2 + q * 9) * k, A(col, 0.5 * (1 - q)), 1); } } },
      { key: "E", name: "Glyph Ring", muzzle: 0, fixed: true, theme: "A ring of small glowing glyph plates floating round a central orb, turning slowly, each plate lighting in turn.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); orb(c, 4.6 * k, METAL_L); glowDot(c, 1.6 * k, col);
          for (let i = 0; i < 6; i++) { const a = t * 0.6 + i * TAU / 6, p = add(c, mul(fa(a), 11 * k)), on = fmod(t * 2 - i, 6) < 1;
            plate(p, rectPts(2.4, 1.8), METAL, a, k, 0.8); line(add(p, mul(fa(a + 1.2), 1.2 * k)), add(p, mul(fa(a - 1.2), 1.2 * k)), A(col, on ? 1 : 0.4), 0.9 * k); if (on) glowDot(p, 1 * k, col); } } },
      { key: "F", name: "Nanite Hive", muzzle: 0, fixed: true, theme: "A low dome of hexagonal cells that light up one after another as nanite swarms drift in and out of them.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); orb(c, 12 * k, METAL_L);
          for (let q = -2; q <= 2; q++) for (let r = -2; r <= 2; r++) { const x = (q + r * 0.5) * 4.4, y = r * 3.8; if (x * x + y * y > 95) continue; const on = rnd(q * 7 + r * 13 + Math.floor(t * 3)) > 0.75;
            outline(add(c, [x * k, y * k]), ngon(6, 1, Math.PI / 6), A(on ? col : METAL, on ? 0.95 : 0.7), 0.8 * k, 0, 2.2 * k); }
          for (let i = 0; i < 6; i++) glowDot(add(c, mul(fa(t * 1.5 + i), (6 + 6 * fmod(t * 0.5 + i / 6, 1)) * k)), 0.5 * k, col); } },
    ],
    anims: [
      { key: "A", name: "Crit Links", desc: "Gold links run from the tower to each tower in range; their shots fly as usual, and a crit lands as a gold burst marked CRIT.", period: 1, flight: 1, fx: () => ({}),
        persist: augmentAgent({ link: (c, p, s, col, t, i) => { line(c, p, A(GOLDC, 0.25), 3); line(c, p, A(GOLDC, 0.7), 1); glowDot(lerp(c, p, fmod(t * 0.7 + i * 0.3, 1)), s * 0.025, GOLDC); }, crit: (p, v, s) => critBurst(p, v, s) }) },
      { key: "B", name: "Augment Glow", desc: "Each boosted tower's base takes on a gold glow and a faint aura joins it to the tower; crit shots fly as thick gold tracers and burst.", period: 1, flight: 1, fx: () => ({}),
        persist: augmentAgent({ link: (c, p, s, col, t) => { ring(p, s * 0.34, A(GOLDC, 0.35 + 0.2 * Math.sin(t * 3)), 2); disc(p, s * 0.34, A(GOLDC, 0.06)); line(c, p, A(col, 0.18), 6); }, crit: (p, v, s) => critBurst(p, v, s) }) },
      { key: "C", name: "Shard Stream", desc: "Tiny crystal shards stream from the tower into each boosted tower; a crit shot shatters into gold splinters on the target.", period: 1, flight: 1, fx: () => ({}),
        persist: augmentAgent({ link: (c, p, s, col, t, i) => { for (let j = 0; j < 3; j++) { const q = fmod(t * 0.9 + j / 3 + i * 0.17, 1), pp = add(lerp(c, p, q), mul(orth(norm(sub(p, c))), Math.sin(q * Math.PI * 2) * s * 0.06)); fill(pp, [[0, -2.4], [1.3, 0], [0, 2.4], [-1.3, 0]], A(lt(col, 0.2), 0.9), t * 3 + j, 1); } },
          crit: (p, v, s) => { critBurst(p, v, s); for (let i = 0; i < 8; i++) { const d = fa(i * TAU / 8); fill(add(p, mul(d, s * 0.35 * v)), [[0, -2], [1, 0], [0, 2], [-1, 0]], A(GOLDC, 1 - v), i, 1); } } }) },
      { key: "D", name: "Nanite Swarm", desc: "Clouds of nanite specks drift from the tower to each tower in range and cling round its barrel; a crit bursts into a cloud of glittering specks.", period: 1, flight: 1, fx: () => ({}),
        persist: augmentAgent({ link: (c, p, s, col, t, i) => { for (let j = 0; j < 6; j++) { const q = fmod(t * 0.5 + j / 6 + i * 0.13, 1), pp = add(lerp(c, p, q), mul(fa(t * 3 + j * 2), s * 0.05)); disc(pp, 1.1, A(col, 0.8)); }
            for (let j = 0; j < 5; j++) disc(add(p, mul(fa(t * 2.4 + j * 1.3 + i), s * 0.2)), 1, A(col, 0.85)); },
          crit: (p, v, s, col) => { critBurst(p, v, s); for (let i = 0; i < 12; i++) disc(add(p, mul(fa(i * 0.52 + 0.2), s * 0.4 * v * (0.5 + rnd(i)))), 1.2, A(col, 1 - v)); } }) },
      { key: "E", name: "Heartbeat Tethers", desc: "Tethers run to each tower in range and pulse like a heartbeat, a ring travelling down each on the beat; a crit strikes the target with a gold bolt.", period: 1, flight: 1, fx: () => ({}),
        persist: augmentAgent({ link: (c, p, s, col, t) => { const b = fmod(t * 1.1, 1); line(c, p, A(col, 0.35 + 0.4 * Math.max(0, 1 - b * 5)), 1.6); const q = lerp(c, p, b); ring(q, s * 0.06, A(col, 1 - b), 1.4); },
          crit: (p, v, s) => { critBurst(p, v, s); if (v < 0.4) { const top = add(p, [0, -s * 0.8]), pts = [top]; for (let j = 1; j < 5; j++) pts.push(add(lerp(top, p, j / 5), [(rnd(j + Math.floor(v * 30)) - 0.5) * s * 0.2, 0])); pts.push(p); polyline(pts, A(GOLDC, 1 - v * 2.5), 2); } } }) },
      { key: "F", name: "Overdrive Halo", desc: "Each tower in range wears a turning halo above it; crit shots leave a gold afterimage trail and a starburst on the target.", period: 1, flight: 1, fx: () => ({}),
        persist: augmentAgent({ link: (c, p, s, col, t, i) => { const h = add(p, [0, -s * 0.38]); X.strokeStyle = css(A(col, 0.85)); X.lineWidth = 1.6; X.beginPath(); X.ellipse(h[0], h[1], s * 0.16, s * 0.05, 0, 0, TAU); X.stroke();
            glowDot(add(h, [Math.cos(t * 3 + i) * s * 0.16, Math.sin(t * 3 + i) * s * 0.05]), s * 0.02, col); },
          crit: (p, v, s) => { critBurst(p, v, s); for (let i = 0; i < 8; i++) { const d = fa(i * TAU / 8); line(add(p, mul(d, s * 0.05)), add(p, mul(d, s * (0.15 + 0.3 * v))), A(GOLDC, 1 - v), 1.2); } } }) },
    ] },
];
const DEFAULTS = { shock: { look: "B", anim: "B" }, scrap: { look: "C", anim: "B" }, tractor: { look: "C" } };
