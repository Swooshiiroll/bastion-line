// ---- Tower art second pass: Shockwave Generator (tower 16), round 1 ----------------------------------------------
// Base: look B Ring Reactor, animation B Mushroom Pulse. One parametric model built on the lessons so far: every step REBUILDS a part (the new
// design replaces the old one), the options swap that part's style, masteries are gold, overlapping Retrofits are kept and stack (the carpet rule),
// and the agent runs the real rules (wave rate, radius, damage, barrier shatter) so the preview shows what a step does.
// Layout (game px, top-down): a thick containment ring (r 10) held by three clamps round a core (r 5.5).
//  - Path 1 (Power/Range) rebuilds the CORE inside the ring (hotter, denser, whiter; gold at the mastery).
//  - Path 2 (Speed) builds pulsing emitters round the OUTSIDE of the ring (two, four, six, eight, then twelve gold ones).
//  - Path 3 (Effect) rebuilds the three violet resonance stations on the ring between the clamps (gold at the mastery).
// Overlaps kept and stacking: Wave Focus's +15 px with the path-1 radius, Containment Coils' +10 damage with the path-1 damage,
// Reactor Venting's 1.5 s wave with the path-2 wave rate.
const PAGE = { title: "Shockwave Generator: paths and Retrofits (second pass)", store: "bl-tower-art-p2-shock-r1" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], AMB = [1, 0.7, 0.28, 1], VIOLET = [0.72, 0.48, 1, 1], HOT = [1, 0.95, 0.8, 1];
const rnd = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const enemyR = (s) => Math.max(4, Math.min(11, s * 0.12));
const RADS = [100, 105, 110, 120, 125, 132], DMG = [75, 85, 95, 110, 125, 135], PERS = [1.75, 1.55, 1.4, 1.15, 1, 0.8], BMUL = [1, 1.5, 2, 2.5, 3, 3];
const radOf = (B) => RADS[B.lv[0]] + (B.r === 0 ? 15 : 0);
const dmgOf = (B) => DMG[B.lv[0]] + (B.r === 1 ? 10 : 0);
const perOf = (B) => PERS[B.lv[1]] * (B.r === 2 ? 1.5 / 1.75 : 1);

// ---- The agent: a wave rolls out every period; enemies it crosses flash; barrier enemies (every third) lose their barrier faster with the Effect path -------
function shockAgent(B) { return (m, t, info, s, col) => { if (!m.hit) { m.hit = {}; m.bar = {}; m.noRegen = {}; m.wave = t; m.tt = t; }
  const dt = Math.min(0.1, Math.max(0, t - m.tt)); m.tt = t; const L1 = B.lv[0], L3 = B.lv[2], gold1 = L1 >= 5, per = perOf(B), c = info.c;
  if (t - m.wave >= per) m.wave = t;
  const R = s * radOf(B) / 48, raw = (t - m.wave) / 0.6, u = Math.min(1, raw), a = Math.max(0, 1 - raw / 1.8), wc = gold1 ? GOLD : col, pw = 1 + 0.25 * L1 + (B.r === 1 ? 0.25 : 0);
  ring(c, R, A(wc, 0.12), 1);
  if (raw <= 1.8) { for (let j = 0; j < 2; j++) { const q = u - j * 0.2; if (q > 0) ring(c, R * q, A(wc, 0.7 * a * (1 - j * 0.4)), (2.5 + pw) - j); }
    const up = Math.min(1, raw) * s * 0.5; disc(add(c, [0, -up * 0.5]), s * 0.06 * pw, A([0.4, 0.35, 0.3, 1], 0.7 * a)); disc(add(c, [0, -up]), s * (0.12 + 0.1 * Math.min(1, raw)) * (0.8 + 0.2 * pw), A(mix(wc, [0.4, 0.35, 0.3, 1], Math.min(1, raw)), 0.75 * a)); }
  for (const e of info.ens) { const d = dist(e.p, c), r0 = enemyR(s), carries = e.i % 3 === 0;
    if (raw <= 1 && Math.abs(d - R * raw) < s * 0.2 && !(m.hit[e.i] > m.wave)) { m.hit[e.i] = t;
      if (carries && d < R) { let f = m.bar[e.i] ?? 1; f -= 0.1 * BMUL[L3]; if (L3 >= 5) { f *= 0.5; m.noRegen[e.i] = t + 5; } m.bar[e.i] = Math.max(0, f); m.brk = m.brk || {}; if (f <= 0.02) m.brk[e.i] = t; } }
    if (carries) { let f = m.bar[e.i] ?? 1; if (!(m.noRegen[e.i] > t)) f = Math.min(1, f + dt * 0.06); m.bar[e.i] = f;
      if (f > 0.03) arc(e.p, r0 + 4, -Math.PI / 2, -Math.PI / 2 + TAU * f, A([0.55, 0.85, 1, 1], 0.9), 2); else if (m.brk && t - (m.brk[e.i] ?? -9) < 0.5) { const h = (t - m.brk[e.i]) / 0.5; for (let j = 0; j < 5; j++) { const dd = fa(j * TAU / 5 + 0.4); line(add(e.p, mul(dd, r0 + 4 + h * 8)), add(e.p, mul(dd, r0 + 7 + h * 8)), A(L3 >= 5 ? GOLD : [0.55, 0.85, 1, 1], 1 - h), 1.5); } } }
    const h = t - (m.hit[e.i] ?? -9); if (h < 0.3) { glowDot(e.p, r0 * (1 - h / 0.3) * (0.9 + 0.2 * pw), HOT); ring(e.p, r0 + h * 20, A(wc, 1 - h / 0.3), 1.5); } } }; }

// ---- Path 1: the core, rebuilt each step (rods, sphere or rings; bigger, denser, whiter; gold at the mastery) -----------------------------------------------
function core(c, k, t, L, ix, fl) { const g = L >= 5, rc = [0, 3.4, 3.9, 4.4, 4.9, 5.3][L], hc = g ? GOLD : mix(AMB, HOT, 0.12 * L);
  disc(c, 5.8 * k, [0.08, 0.06, 0.04, 1]);
  if (ix === 0) { const n = [0, 3, 6, 9, 12, 12][L]; for (let j = 0; j < n; j++) { const a = j * TAU / n + 0.3, q = add(c, mul(fa(a), rc * 0.72 * k)); disc(q, 1.1 * k, OUTLINE); disc(q, 0.85 * k, hc); glowDot(q, 0.35 * k * (1 + fl), g ? GOLD : lt(AMB, 0.4)); } glowDot(c, (1.4 + L * 0.3 + 2 * fl) * k, g ? GOLD : lt(AMB, 0.3)); }                       // fuel rods
  if (ix === 1) { orb(c, rc * k, hc); disc(c, rc * 0.45 * k, A(HOT, 0.9)); const rays = 4 + 2 * L; if (L >= 3) for (let j = 0; j < rays; j++) { const a = j * TAU / rays + t * 0.5; line(add(c, mul(fa(a), rc * 0.9 * k)), add(c, mul(fa(a), (rc * 1.12 + fl) * k)), A(hc, 0.8), 1 * k); } glowDot(c, (1 + 2.5 * fl) * k, HOT); }   // a plasma sphere (with a corona from step 3)
  if (ix === 2) { const nr = Math.min(L + 1, 5); for (let j = 0; j < nr; j++) arcSegments(c, rc * (0.3 + 0.7 * (j + 1) / nr) * k, 3, 0.8, t * (1 + j * 0.6) * (j % 2 ? -1 : 1), A(hc, 0.95), 1.3 * k); glowDot(c, (1.2 + 2 * fl) * k, g ? GOLD : lt(AMB, 0.3)); } }   // spinning core rings

// ---- The model -----------------------------------------------------------------------------------------------------------------------------------------------
const P2 = {
  tower: "shock", look: "B", anim: "B",
  intro: "Round 1: every step rebuilds a part. Path 1 (Power/Range) rebuilds the core inside the containment ring: rods, a plasma sphere or spinning rings that get bigger, denser and whiter, and turn gold at the Megaton Wave. Path 2 (Speed) builds pulsing emitters round the outside of the ring (two, four, six, eight, then twelve gold ones) and the wave comes faster. Path 3 (Effect) rebuilds the three violet resonance stations on the ring between the clamps; barrier enemies (every third one) show a blue barrier that the waves chew through faster at each step, and at the mastery each wave shatters half of it and it cannot grow back for 5 s. The Retrofits add a focusing ring, containment coils or exhaust vents. Overlapping Retrofits are kept and stack (the carpet rule). Unpicked steps show option A.",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: shockAgent(B) }; },
  muzzleAt(B, m, kk, c) { return c; },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), mm = fx.mem || {}, fl = decay(t - (mm.wave ?? -9), 0.4), L1 = B.lv[0], L2 = B.lv[1], L3 = B.lv[2], S = (x, y) => add(c, [x * k, y * k]), R = B.r >= 0 ? B.key("r" + B.r) : null, g1 = L1 >= 5, g2 = L2 >= 5, g3 = L3 >= 5;
    deck(c, k, col, t);
    ring(c, 10 * k, OUTLINE, 6.4 * k); ring(c, 10 * k, METAL_L, 5 * k); arc(c, 10 * k, Math.PI * 1.05, Math.PI * 1.6, lt(METAL_L, 0.4), 1.4 * k); ring(c, 10 * k, A(g1 ? GOLD : col, 0.2 + 0.7 * fl), 1.4 * k);
    for (let i = 0; i < 3; i++) plate(add(c, mul(fa(-Math.PI / 2 + i * TAU / 3), 10 * k)), rectPts(2, 3.6), METAL_D, -Math.PI / 2 + i * TAU / 3, k, 1);
    // ---- Path 2: pulsing emitters round the outside of the ring ---------------------------------------------------------------------------------------------
    if (L2 > 0) { const key = B.key("p1s" + (L2 - 1)), N = [0, 2, 4, 6, 8, 12][L2], lc = g2 ? GOLD : col, rate = 1 / perOf(B);
      for (let j = 0; j < N; j++) { const a = j * TAU / N + Math.PI / 6, d = fa(a), o = orth(d), p0 = add(c, mul(d, 12.9 * k)), lit = fmod(t * rate - j / N * 0.9, 1) < 0.3 || fl > 0.3;
        if (key === "A") { bar(p0, add(p0, mul(d, 2.6 * k)), 1.8 * k, METAL); for (let q = 0; q < 2; q++) line(add(add(p0, mul(d, (0.7 + q * 1.2) * k)), mul(o, -1.1 * k)), add(add(p0, mul(d, (0.7 + q * 1.2) * k)), mul(o, 1.1 * k)), g2 ? GOLD : STEEL, 0.8 * k); if (lit) glowDot(add(p0, mul(d, 3 * k)), 0.7 * k, lc); else disc(add(p0, mul(d, 3 * k)), 0.5 * k, dk(lc, 0.5)); }   // coil emitters
        if (key === "B") { bar(p0, add(p0, mul(d, 1.6 * k)), 1.2 * k, METAL); const q = add(p0, mul(d, 2 * k)), da = Math.atan2(d[1], d[0]); arc(q, 1.9 * k, da - 1.1, da + 1.1, OUTLINE, 2 * k); arc(q, 1.9 * k, da - 1.1, da + 1.1, g2 ? GOLD : METAL_L, 1.1 * k); if (lit) glowDot(add(q, mul(d, -0.2 * k)), 0.55 * k, lc); }   // dish emitters
        if (key === "C") { bar(p0, add(p0, mul(d, 3 * k)), 1 * k, METAL_L); disc(add(p0, mul(d, 3.3 * k)), 1.1 * k, OUTLINE); disc(add(p0, mul(d, 3.3 * k)), 0.85 * k, lit ? lc : dk(lc, 0.4)); if (lit) glowDot(add(p0, mul(d, 3.3 * k)), 0.5 * k, HOT); } } }   // spike-and-ball emitters
    // ---- Path 3: three violet resonance stations on the ring, between the clamps (rebuilt each step) --------------------------------------------------------------
    if (L3 > 0) { const ix = "ABC".indexOf(B.key("p2s" + (L3 - 1))), vc = g3 ? GOLD : VIOLET, sz = [0, 2.2, 2.5, 2.8, 3.1, 3.4][L3];
      for (let i = 0; i < 3; i++) { const a = -Math.PI / 6 + i * TAU / 3 + Math.PI, d = fa(a), o = orth(d), p = add(c, mul(d, 10 * k)), pr = fmod(t * 0.8 + i / 3, 1);
        plate(p, rectPts(sz * 0.75, sz * 0.75), g3 ? dk(GOLD, 0.5) : METAL_D, a, k, 1);
        if (ix === 0) { const n = Math.min(2 + (L3 >= 3 ? 1 : 0) + (L3 >= 4 ? 1 : 0) + (L3 >= 5 ? 1 : 0), 5); for (let q = 0; q < n; q++) { const off = (q - (n - 1) / 2) * 1.1 * k, e = add(add(p, mul(o, off)), mul(d, (sz * 1.1) * k)); bar(add(p, mul(o, off)), e, 0.8 * k, g3 ? GOLD : METAL_L); glowDot(e, 0.35 * k, vc); } }   // tuning forks
        if (ix === 1) { for (let q = 0; q < (L3 >= 3 ? 2 : 1); q++) { const u = fmod(pr + q * 0.5, 1); ring(p, (sz * 0.8 + u * sz * 1.4) * k, A(vc, 0.8 * (1 - u)), 1.2 * k); } line(add(p, mul(o, -sz * 0.6 * k)), add(p, mul(o, sz * 0.6 * k)), vc, 1 * k); glowDot(p, 0.45 * k, vc); }   // resonance plates with ripple rings
        if (ix === 2) { for (let q = 0; q < (L3 >= 4 ? 2 : 1); q++) { const off = (q - (L3 >= 4 ? 0.5 : 0)) * 2 * k, b = add(p, mul(o, off)); fill(b, [[0, -sz * 1.4], [sz * 0.5, sz * 0.3], [-sz * 0.5, sz * 0.3]], g3 ? GOLD : mix(VIOLET, METAL_L, 0.3), a + Math.PI / 2, k); line(b, add(b, mul(d, sz * 1.1 * k)), A(vc, 0.9), 0.8 * k); glowDot(add(b, mul(d, sz * 1.3 * k)), 0.3 * k, vc); } }   // violet spires
        if (g3) ring(p, (sz + 1) * k, A(GOLD, 0.7), 0.9 * k); } }
    // ---- Path 1: the core, rebuilt each step ------------------------------------------------------------------------------------------------------------------------------
    if (L1 > 0) core(c, k, t, L1, "ABC".indexOf(B.key("p0s" + (L1 - 1))), fl); else { disc(c, 5.5 * k, [0.08, 0.06, 0.04, 1]); glowDot(c, (2.4 + 3 * fl) * k, lt(col, 0.2 + 0.4 * fl)); }
    // ---- The Retrofits: a focusing ring round the core, containment coils round the core, or exhaust vents at the corners -------------------------------------------------------
    if (B.r === 0) { if (R === "A") { ring(c, 6.3 * k, OUTLINE, 2.2 * k); ring(c, 6.3 * k, METAL_L, 1.4 * k); for (let q = 0; q < 8; q++) disc(add(c, mul(fa(q * TAU / 8 + 0.2), 6.3 * k)), 0.5 * k, A(HOT, 0.9)); }
      if (R === "B") for (let q = 0; q < 4; q++) { const p = add(c, mul(fa(q * Math.PI / 2 + Math.PI / 4), 6.3 * k)); disc(p, 1.3 * k, OUTLINE); disc(p, 1 * k, A([0.8, 0.95, 1, 1], 0.9)); ring(p, 0.8 * k, METAL_L, 0.5 * k); }
      if (R === "C") { for (let q = 0; q < 12; q++) { const a = q * TAU / 12; fill(add(c, mul(fa(a), 6.4 * k)), [[0, -0.9], [-2, 0], [0, 0.9]], METAL_L, a, k); } ring(c, 6.4 * k, METAL, 0.9 * k); } }
    if (B.r === 1) { if (R === "A") for (let q = 0; q < 2; q++) { const pts = []; for (let j = 0; j <= 36; j++) pts.push(add(c, mul(fa(j * 0.55 + q * Math.PI), (4.6 + 0.04 * j) * k))); polyline(pts, OUTLINE, 2.4 * k); polyline(pts, A(AMB, 0.95), 1.3 * k); }
      if (R === "B") for (let q = 0; q < 6; q++) { const a = q * TAU / 6 + 0.2; bar(add(c, mul(fa(a), 3.4 * k)), add(c, mul(fa(a), 6 * k)), 1.8 * k, METAL); glowDot(add(c, mul(fa(a), 6 * k)), 0.45 * k, AMB); }
      if (R === "C") for (let q = 0; q < 2; q++) { ring(c, (4.2 + q * 1.5) * k, OUTLINE, 2.4 * k); ring(c, (4.2 + q * 1.5) * k, A(AMB, 0.9), 1.2 * k); } }
    if (B.r === 2) for (const [sx, sy] of [[-1, -1], [1, -1], [1, 1], [-1, 1]]) { const p = S(sx * 10.8, sy * 10.8), da = Math.atan2(sy, sx);
      if (R === "A") { disc(p, 1.7 * k, OUTLINE); disc(p, 1.3 * k, METAL_L); for (let q = 0; q < 3; q++) { const u = fmod(t * 0.7 + q / 3 + (sx + sy) * 0.1, 1); disc(add(p, [sx * u * 4 * k, sy * u * 4 * k]), (0.5 + u) * k, A([0.8, 0.8, 0.8, 1], 0.5 * (1 - u))); } }
      if (R === "B") { plate(p, rectPts(2.2, 1.4), METAL_L, da, k, 1); for (let q = -1; q <= 1; q++) line(add(p, mul(orth(fa(da)), q * 0.7 * k)), add(add(p, mul(orth(fa(da)), q * 0.7 * k)), mul(fa(da), 2.2 * k)), A(AMB, 0.9), 0.8 * k); }
      if (R === "C") { fill(p, [[-1.6, -1.6], [1.6, -1.6], [1, 1.6], [-1, 1.6]], METAL_L, da, k); disc(p, 1.1 * k, [0.1, 0.1, 0.1, 1]); if (fl > 0.1) glowDot(p, 0.8 * k * fl, AMB); } }
  },
  paths: [], retrofits: [],
};

// ---- Option tables ---------------------------------------------------------------------------------------------------------------------------------------
const T = (a, b, c) => [["A", ...a], ["B", ...b], ["C", ...c]].map(([key, name, desc]) => ({ key, name, desc }));
P2.paths = [
  { name: "Power / Range", theme: "the core inside the ring: rebuilt at every step, bigger, denser and whiter; gold at the mastery", steps: [
    { name: "Hotter Core", cost: 210, effect: "85 damage; 105 px", options: T(["Fuel Rods", "The core is rebuilt as three glowing fuel rods."], ["Plasma Sphere", "The core is rebuilt as a hot plasma sphere."], ["Core Rings", "The core is rebuilt as two spinning rings round a bright centre."]) },
    { name: "Dense Core", cost: 470, effect: "95 damage; 110 px", options: T(["Rod Bundle", "The core is rebuilt as a bundle of six rods."], ["Dense Sphere", "The core is rebuilt as a bigger, denser plasma sphere."], ["Triple Rings", "The core is rebuilt with three spinning rings."]) },
    { name: "Critical Mass", cost: 1870, effect: "110 damage; 120 px (primary)", options: T(["Critical Stack", "The core is rebuilt as nine rods, whiter and brighter."], ["Corona Sphere", "The core is rebuilt as a white-hot sphere with a corona of rays."], ["Orbit Rings", "The core is rebuilt with four spinning rings, whiter."]) },
    { name: "Overpressure", cost: 3200, effect: "125 damage; 125 px", options: T(["Pressure Rods", "The core is rebuilt as twelve rods in a tight pressure ring."], ["Overpressure Sphere", "The core is rebuilt as a bigger sphere with a longer corona."], ["Gyro Rings", "The core is rebuilt with five spinning gyro rings."]) },
    { name: "Megaton Wave", cost: 6690, effect: "135 damage; 132 px (mastery)", options: T(["Gold Rods", "The twelve rods turn gold; the waves and the ring turn gold."], ["Gold Sphere", "The sphere and its corona turn gold; the waves and the ring turn gold."], ["Gold Gyro Rings", "The gyro rings turn gold; the waves and the ring turn gold."]) },
  ] },
  { name: "Speed", theme: "the outside of the ring: pulsing emitters, two, four, six, eight, then twelve gold ones", steps: [
    { name: "Quick Cycle", cost: 115, effect: "A wave every 1.55 s", options: T(["Coil Emitters", "Two coil emitters pulse on the outside of the ring."], ["Dish Emitters", "Two dish emitters pulse on the outside of the ring."], ["Spike Emitters", "Two spike-and-ball emitters pulse on the outside of the ring."]) },
    { name: "Fast Cycle", cost: 220, effect: "Every 1.4 s", options: T(["Coil Emitters", "Four coil emitters pulse round the ring."], ["Dish Emitters", "Four dish emitters pulse round the ring."], ["Spike Emitters", "Four spike-and-ball emitters pulse round the ring."]) },
    { name: "Pulse Core", cost: 980, effect: "Every 1.15 s (primary)", options: T(["Coil Emitters", "Six coil emitters pulse round the ring."], ["Dish Emitters", "Six dish emitters pulse round the ring."], ["Spike Emitters", "Six spike-and-ball emitters pulse round the ring."]) },
    { name: "Rapid Core", cost: 1645, effect: "Every second", options: T(["Coil Emitters", "Eight coil emitters pulse round the ring."], ["Dish Emitters", "Eight dish emitters pulse round the ring."], ["Spike Emitters", "Eight spike-and-ball emitters pulse round the ring."]) },
    { name: "Chain Pulse", cost: 6310, effect: "Every 0.8 s (mastery)", options: T(["Gold Coil Emitters", "Twelve gold coil emitters pulse round the ring in a chain."], ["Gold Dish Emitters", "Twelve gold dish emitters pulse round the ring in a chain."], ["Gold Spike Emitters", "Twelve gold spike-and-ball emitters pulse round the ring in a chain."]) },
  ] },
  { name: "Effect", theme: "the ring: three violet resonance stations rebuilt at every step; barrier enemies show a barrier that the waves chew through", steps: [
    { name: "Disruptor Wave", cost: 45, effect: "x1.5 damage to barriers", options: T(["Tuning Forks", "Three stations with a pair of violet tuning forks; barriers take 1.5x."], ["Ripple Plates", "Three stations with a resonance plate that sends out ripples; barriers take 1.5x."], ["Violet Spires", "Three stations with a violet spire; barriers take 1.5x."]) },
    { name: "Harmonic Wave", cost: 55, effect: "x2 to barriers", options: T(["Fork Pairs", "The stations are rebuilt with a pair of larger forks; barriers take 2x."], ["Ripple Plates", "The stations are rebuilt with larger plates; barriers take 2x."], ["Tall Spires", "The stations are rebuilt with taller spires; barriers take 2x."]) },
    { name: "Resonance", cost: 145, effect: "x2.5 to barriers (primary)", options: T(["Fork Triples", "The stations are rebuilt with three forks each; barriers take 2.5x."], ["Double Ripple Plates", "The stations are rebuilt with plates that send out two ripples; barriers take 2.5x."], ["Spire Cores", "The stations are rebuilt with bigger spires; barriers take 2.5x."]) },
    { name: "Breaker Wave", cost: 290, effect: "x3 to barriers", options: T(["Breaker Forks", "The stations are rebuilt with four forks each; barriers take 3x."], ["Breaker Plates", "The stations are rebuilt with big plates and double ripples; barriers take 3x."], ["Twin Spires", "The stations are rebuilt with twin spires; barriers take 3x."]) },
    { name: "Shatter Shock", cost: 1300, effect: "Each wave shatters half of every barrier it hits; they can't regenerate for 5 s (mastery)", options: T(["Gold Forks", "The forks turn gold; each wave shatters half of each barrier, in gold shards, and it cannot grow back for 5 s."], ["Gold Plates", "The plates turn gold; each wave shatters half of each barrier, in gold shards, and it cannot grow back for 5 s."], ["Gold Spires", "The spires turn gold; each wave shatters half of each barrier, in gold shards, and it cannot grow back for 5 s."]) },
  ] },
];
P2.retrofits = [
  { name: "Wave Focus", cost: 245, effect: "+15 px radius (stacks with the path-1 radius)", options: T(["Focus Ring", "A metal focusing ring with bright lenses round the core."], ["Lens Array", "Four glass focusing lenses round the core."], ["Focus Collar", "A finned focusing collar round the core."]) },
  { name: "Containment Coils", cost: 120, effect: "+10 damage (stacks with the path-1 damage)", options: T(["Glowing Coils", "Two glowing helical coils wind round the core."], ["Coil Cage", "Six glowing coil posts cage the core."], ["Toroid Coils", "Two glowing toroid coils ring the core."]) },
  { name: "Reactor Venting", cost: 150, effect: "A wave every 1.5 s (stacks with the Speed path)", options: T(["Vent Stacks", "Four exhaust stacks at the corners vent grey steam."], ["Louvre Vents", "Four louvre vents at the corners glow amber."], ["Blast Vents", "Four blast vents at the corners flare with each wave."]) },
];
