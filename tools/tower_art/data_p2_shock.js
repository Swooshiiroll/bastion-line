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
const PAGE = { title: "Shockwave Generator: paths and Retrofits (second pass)", store: "bl-tower-art-p2-shock-r2" };
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
  const R = s * radOf(B) / 48, raw = (t - m.wave) / 0.6, u = Math.min(1, raw), a = Math.max(0, 1 - raw / 1.8), wc = gold1 ? HOT : col, pw = 1 + 0.25 * L1 + (B.r === 1 ? 0.25 : 0);
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
function core(c, k, t, L, ix, fl) { const g = false, br = L >= 5, rc = [0, 3.4, 3.9, 4.4, 4.9, 5.3][L], hc = br ? HOT : mix(AMB, HOT, 0.12 * L), bl = br ? 1.6 : 1;
  disc(c, 5.8 * k, [0.08, 0.06, 0.04, 1]); if (br) { disc(c, rc * 1.3 * k, A(HOT, 0.16)); disc(c, rc * 1.05 * k, A(HOT, 0.2)); }
  if (ix === 0) { const n = [0, 3, 6, 9, 12, 12][L]; for (let j = 0; j < n; j++) { const a = j * TAU / n + 0.3, q = add(c, mul(fa(a), rc * 0.72 * k)); disc(q, 1.1 * k, OUTLINE); disc(q, 0.85 * k, hc); glowDot(q, 0.35 * k * (1 + fl), g ? GOLD : lt(AMB, 0.4)); } glowDot(c, (1.4 + L * 0.3 + 2 * fl) * bl * k, g ? GOLD : lt(AMB, 0.3)); }                       // fuel rods
  if (ix === 1) { orb(c, rc * k, hc); disc(c, rc * 0.45 * k, A(HOT, 0.9)); const rays = 4 + 2 * L; if (L >= 3) for (let j = 0; j < rays; j++) { const a = j * TAU / rays + t * 0.5; line(add(c, mul(fa(a), rc * 0.9 * k)), add(c, mul(fa(a), (rc * 1.12 + fl) * k)), A(hc, 0.8), 1 * k); } glowDot(c, (1 + 2.5 * fl) * bl * k, HOT); }   // a plasma sphere (with a corona from step 3)
  if (ix === 2) { const nr = Math.min(L + 1, 5); for (let j = 0; j < nr; j++) arcSegments(c, rc * (0.3 + 0.7 * (j + 1) / nr) * k, 3, 0.8, t * (1 + j * 0.6) * (j % 2 ? -1 : 1), A(hc, 0.95), 1.3 * k); glowDot(c, (1.2 + 2 * fl) * bl * k, br ? HOT : lt(AMB, 0.3)); } }   // spinning core rings

// ---- The model -----------------------------------------------------------------------------------------------------------------------------------------------
const P2 = {
  tower: "shock", look: "B", anim: "B",
  intro: "Round 2: your Path 1 picks are drawn, brighter instead of gold at the mastery (your note); Path 2 and Path 3 are redesigned as big visual changes instead of little additions: Speed rebuilds the containment ring itself (turning segments, a flywheel or a turbine that spins faster at each step), and Effect rebuilds the three clamps as big violet resonators (forks, ripple drums or crystals); Reactor Venting merges the stacks with the blast vents and smoke billows out with every burst. Wave Focus and Containment Coils show their options again. Round 1: every step rebuilds a part. Path 1 (Power/Range) rebuilds the core inside the containment ring: rods, a plasma sphere or spinning rings that get bigger, denser and whiter, and turn gold at the Megaton Wave. Path 2 (Speed) builds pulsing emitters round the outside of the ring (two, four, six, eight, then twelve gold ones) and the wave comes faster. Path 3 (Effect) rebuilds the three violet resonance stations on the ring between the clamps; barrier enemies (every third one) show a blue barrier that the waves chew through faster at each step, and at the mastery each wave shatters half of it and it cannot grow back for 5 s. The Retrofits add a focusing ring, containment coils or exhaust vents. Overlapping Retrofits are kept and stack (the carpet rule). Unpicked steps show option A.",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: shockAgent(B) }; },
  muzzleAt(B, m, kk, c) { return c; },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), mm = fx.mem || {}, fl = decay(t - (mm.wave ?? -9), 0.4), L1 = B.lv[0], L2 = B.lv[1], L3 = B.lv[2], S = (x, y) => add(c, [x * k, y * k]), R = B.r >= 0 ? B.key("r" + B.r) : null, g1 = L1 >= 5, g2 = L2 >= 5, g3 = L3 >= 5;
    deck(c, k, col, t);
    // ---- Path 2: the containment ring itself is rebuilt at every step (segments, a flywheel or a turbine) and spins faster, so the waves come faster -------------------
    { const mm2 = mm; const dt2 = Math.min(0.1, Math.max(0, t - (mm2.rT ?? t))); mm2.rT = t; mm2.ra = (mm2.ra || 0) + dt2 * [0, 0.8, 1.2, 1.7, 2.4, 3.4][L2] * (fl > 0.3 ? 1.6 : 1);
      const key = L2 > 0 ? B.key("p1s" + (L2 - 1)) : "-", ra = mm2.ra, rc2 = g2 ? GOLD : A(g1 ? HOT : col, 1), gl = A(g1 ? HOT : col, 0.2 + 0.7 * fl);
      ring(c, 10 * k, OUTLINE, 6.4 * k);
      if (key === "-") { ring(c, 10 * k, METAL_L, 5 * k); arc(c, 10 * k, Math.PI * 1.05, Math.PI * 1.6, lt(METAL_L, 0.4), 1.4 * k); ring(c, 10 * k, gl, 1.4 * k); }
      if (key === "A") { const n = 4 + L2; for (let j = 0; j < n; j++) { const a0 = ra + j * TAU / n, span = TAU / n * 0.72; arc(c, 10 * k, a0, a0 + span, METAL_L, 5 * k); arc(c, 12.2 * k, a0, a0 + span, g2 ? GOLD : A(g1 ? HOT : col, 0.35 + 0.6 * fl), 1.1 * k); arc(c, 7.8 * k, a0, a0 + span, g2 ? GOLD : A(g1 ? HOT : col, 0.35 + 0.6 * fl), 1.1 * k); } }      // a segmented, turning ring
      if (key === "B") { ring(c, 10 * k, METAL_L, 5 * k); ring(c, 10 * k, gl, 1.2 * k); const n = 3 + L2; for (let j = 0; j < n; j++) { const a = ra + j * TAU / n; bar(add(c, mul(fa(a), 5.6 * k)), add(c, mul(fa(a), 9.4 * k)), 1.8 * k, METAL); disc(add(c, mul(fa(a), 9.6 * k)), 1 * k, g2 ? GOLD : A(g1 ? HOT : col, 0.9)); } }          // a flywheel: spokes from the core to the ring
      if (key === "C") { ring(c, 10 * k, METAL_L, 5 * k); ring(c, 10 * k, gl, 1.2 * k); const n = 8 + 2 * L2; for (let j = 0; j < n; j++) { const a = ra + j * TAU / n; fill(add(c, mul(fa(a), 12 * k)), [[0, -1], [1.6, 0.3], [-0.5, 1.2]], g2 ? GOLD : METAL, a, k); fill(add(c, mul(fa(a), 8 * k)), [[0, -1], [-1.6, 0.3], [0.5, 1.2]], g2 ? GOLD : METAL, a, k); } } }    // a turbine ring: blades on both edges
    // the three clamps that hold the ring (replaced by big resonators once Path 3 is bought)
    if (L3 === 0) for (let i = 0; i < 3; i++) plate(add(c, mul(fa(-Math.PI / 2 + i * TAU / 3), 10 * k)), rectPts(2, 3.6), METAL_D, -Math.PI / 2 + i * TAU / 3, k, 1);
    // ---- Path 3: the three clamps are REBUILT at every step as big violet resonators (forks, ripple drums or crystals); gold at the mastery --------------------------------
    if (L3 > 0) { const ix = "ABC".indexOf(B.key("p2s" + (L3 - 1))), vc = g3 ? GOLD : VIOLET, sz = [0, 3, 3.6, 4.2, 4.8, 5.4][L3], body = g3 ? dk(GOLD, 0.45) : METAL_L;
      for (let i = 0; i < 3; i++) { const a = -Math.PI / 2 + i * TAU / 3, out = fa(a), o = orth(out), p = add(c, mul(out, 10 * k));
        if (ix === 0) { plate(p, rectPts(sz * 0.9, sz * 0.7), g3 ? dk(GOLD, 0.45) : METAL_D, a, k, 1.2); const nf = L3 >= 4 ? 3 : 2; for (let q = 0; q < nf; q++) { const off = (q - (nf - 1) / 2) * sz * 0.95 * k, b0 = add(p, mul(o, off)), b1 = add(b0, mul(out, sz * 1.7 * k)); bar(b0, b1, 1.6 * k, body); glowDot(b1, 0.55 * k * (1 + 0.5 * fl), vc); }
          for (let q = 0; q < nf - 1; q++) { const off = (q - (nf - 2) / 2) * sz * 0.95 * k; line(add(add(p, mul(o, off - sz * 0.47 * k)), mul(out, sz * 1.7 * k)), add(add(p, mul(o, off + sz * 0.47 * k)), mul(out, sz * 1.7 * k)), A(vc, 0.5 + 0.4 * fl), 1.2 * k); } }   // big tuning forks
        if (ix === 1) { disc(p, sz * k + 1.2 * k, OUTLINE); disc(p, sz * k, g3 ? dk(GOLD, 0.45) : METAL_D); ring(p, sz * 0.62 * k, vc, 1.2 * k); glowDot(p, 0.6 * k, vc); for (let q = 0; q < (L3 >= 3 ? 3 : 2); q++) { const u = fmod(t * 0.9 + q / 3 + i / 3, 1); ring(p, (sz + u * sz * 1.4) * k, A(vc, 0.8 * (1 - u)), 1.4 * k); } }   // ripple drums
        if (ix === 2) { fill(p, ngon(6, 1), A(g3 ? dk(GOLD, 0.45) : [0.35, 0.22, 0.55, 1], 1), a, sz * 1.15 * k); fill(p, ngon(6, 1), A(vc, 0.8), a + 0.2, sz * 0.85 * k); for (let q = 0; q < 3; q++) line(p, add(p, mul(fa(a + q * TAU / 3 + 0.3), sz * 0.85 * k)), [1, 1, 1, 0.6], 0.8 * k); if (L3 >= 3) fill(add(p, mul(out, sz * 1.2 * k)), ngon(6, 1), A(vc, 0.9), a, sz * 0.5 * k); glowDot(p, 0.5 * k, HOT); }   // violet crystals
        if (g3) ring(p, (sz + 1.8) * k, A(GOLD, 0.6), 0.9 * k); } }
    // ---- Path 1: the core, rebuilt each step ------------------------------------------------------------------------------------------------------------------------------
    if (L1 > 0) core(c, k, t, L1, "ABC".indexOf(B.key("p0s" + (L1 - 1))), fl); else { disc(c, 5.5 * k, [0.08, 0.06, 0.04, 1]); glowDot(c, (2.4 + 3 * fl) * k, lt(col, 0.2 + 0.4 * fl)); }
    // ---- The Retrofits: a focusing ring round the core, containment coils round the core, or exhaust vents at the corners -------------------------------------------------------
    if (B.r === 0) { if (R === "A") { ring(c, 6.3 * k, OUTLINE, 2.2 * k); ring(c, 6.3 * k, METAL_L, 1.4 * k); for (let q = 0; q < 8; q++) disc(add(c, mul(fa(q * TAU / 8 + 0.2), 6.3 * k)), 0.5 * k, A(HOT, 0.9)); }
      if (R === "B") for (let q = 0; q < 4; q++) { const p = add(c, mul(fa(q * Math.PI / 2 + Math.PI / 4), 6.3 * k)); disc(p, 1.3 * k, OUTLINE); disc(p, 1 * k, A([0.8, 0.95, 1, 1], 0.9)); ring(p, 0.8 * k, METAL_L, 0.5 * k); }
      if (R === "C") { for (let q = 0; q < 12; q++) { const a = q * TAU / 12; fill(add(c, mul(fa(a), 6.4 * k)), [[0, -0.9], [-2, 0], [0, 0.9]], METAL_L, a, k); } ring(c, 6.4 * k, METAL, 0.9 * k); } }
    if (B.r === 1) { if (R === "A") for (let q = 0; q < 2; q++) { const pts = []; for (let j = 0; j <= 36; j++) pts.push(add(c, mul(fa(j * 0.55 + q * Math.PI), (4.6 + 0.04 * j) * k))); polyline(pts, OUTLINE, 2.4 * k); polyline(pts, A(AMB, 0.95), 1.3 * k); }
      if (R === "B") for (let q = 0; q < 6; q++) { const a = q * TAU / 6 + 0.2; bar(add(c, mul(fa(a), 3.4 * k)), add(c, mul(fa(a), 6 * k)), 1.8 * k, METAL); glowDot(add(c, mul(fa(a), 6 * k)), 0.45 * k, AMB); }
      if (R === "C") for (let q = 0; q < 2; q++) { ring(c, (4.2 + q * 1.5) * k, OUTLINE, 2.4 * k); ring(c, (4.2 + q * 1.5) * k, A(AMB, 0.9), 1.2 * k); } }
    if (B.r === 2) for (const [sx, sy] of [[-1, -1], [1, -1], [1, 1], [-1, 1]]) { const p = S(sx * 10.8, sy * 10.8), da = Math.atan2(sy, sx), dd = fa(da), age = t - (mm.wave ?? -9);
      if (R === "A") { disc(p, 1.7 * k, OUTLINE); disc(p, 1.3 * k, METAL_L); for (let q = 0; q < 3; q++) { const u = fmod(t * 0.7 + q / 3 + (sx + sy) * 0.1, 1); disc(add(p, [sx * u * 4 * k, sy * u * 4 * k]), (0.5 + u) * k, A([0.8, 0.8, 0.8, 1], 0.5 * (1 - u))); } }
      if (R === "B") { plate(p, rectPts(2.2, 1.4), METAL_L, da, k, 1); for (let q = -1; q <= 1; q++) line(add(p, mul(orth(dd), q * 0.7 * k)), add(add(p, mul(orth(dd), q * 0.7 * k)), mul(dd, 2.2 * k)), A(AMB, 0.9), 0.8 * k); }
      if (R === "C") { disc(p, 2.1 * k, OUTLINE); disc(p, 1.7 * k, METAL_L); ring(p, 1.2 * k, STEEL, 0.8 * k); fill(add(p, mul(dd, 1.2 * k)), [[0, -1.3], [2.6, -0.8], [2.6, 0.8], [0, 1.3]], METAL, da, k); if (fl > 0.05) glowDot(add(p, mul(dd, 3.4 * k)), 0.9 * k * fl, AMB);   // a stack with a blast vent; smoke billows out with each burst
        if (age >= 0 && age < 1.8) { const u = age / 1.8; for (let q = 0; q < 6; q++) { const sp = (0.5 + q * 0.35) * u * 9, off = (q % 2 ? 1 : -1) * (0.4 + q * 0.2) * u * 3; disc(add(add(p, mul(dd, (2 + sp) * k)), mul(orth(dd), off * k)), (1 + u * 3 + q * 0.5) * k, A([0.62, 0.6, 0.58, 1], 0.55 * (1 - u))); } } } }
  },
  paths: [], retrofits: [],
};

// ---- Option tables ---------------------------------------------------------------------------------------------------------------------------------------
const T = (a, b, c) => [["A", ...a], ["B", ...b], ["C", ...c]].map(([key, name, desc]) => ({ key, name, desc }));
P2.paths = [
  { name: "Power / Range", theme: "the core inside the ring: rebuilt at every step, bigger, denser and whiter, and white-hot (not gold) at the mastery", steps: [
    { name: "Hotter Core", cost: 210, effect: "85 damage; 105 px", options: T(["Fuel Rods", "The core is rebuilt as three glowing fuel rods."], ["Plasma Sphere", "The core is rebuilt as a hot plasma sphere."], ["Core Rings", "The core is rebuilt as two spinning rings round a bright centre."]) },
    { name: "Dense Core", cost: 470, effect: "95 damage; 110 px", options: T(["Rod Bundle", "The core is rebuilt as a bundle of six rods."], ["Dense Sphere", "The core is rebuilt as a bigger, denser plasma sphere."], ["Triple Rings", "The core is rebuilt with three spinning rings."]) },
    { name: "Critical Mass", cost: 1870, effect: "110 damage; 120 px (primary)", options: T(["Critical Stack", "The core is rebuilt as nine rods, whiter and brighter."], ["Corona Sphere", "The core is rebuilt as a white-hot sphere with a corona of rays."], ["Orbit Rings", "The core is rebuilt with four spinning rings, whiter."]) },
    { name: "Overpressure", cost: 3200, effect: "125 damage; 125 px", options: T(["Pressure Rods", "The core is rebuilt as twelve rods in a tight pressure ring."], ["Overpressure Sphere", "The core is rebuilt as a bigger sphere with a longer corona."], ["Gyro Rings", "The core is rebuilt with five spinning gyro rings."]) },
    { name: "Megaton Wave", cost: 6690, effect: "135 damage; 132 px (mastery)", options: T(["White-Hot Rods", "The twelve rods turn white-hot with a bloom; the waves and the ring glow white-hot."], ["White-Hot Sphere", "The sphere and its corona turn white-hot with a bloom; the waves and the ring glow white-hot."], ["White-Hot Gyro Rings", "The gyro rings turn white-hot with a bloom; the waves and the ring glow white-hot."]) },
  ] },
  { name: "Speed", theme: "the ring itself: rebuilt at every step as a bigger, faster-spinning ring (segments, a flywheel or a turbine)", steps: [
    { name: "Quick Cycle", cost: 115, effect: "A wave every 1.55 s", options: T(["Segmented Ring", "The ring is rebuilt as five turning segments with glowing rims."], ["Flywheel", "The ring is rebuilt as a flywheel with four spokes to the core."], ["Turbine Ring", "The ring is rebuilt as a turbine ring with blades on both edges."]) },
    { name: "Fast Cycle", cost: 220, effect: "Every 1.4 s", options: T(["Segmented Ring", "The ring is rebuilt as six turning segments, spinning faster."], ["Flywheel", "The ring is rebuilt as a flywheel with five spokes, spinning faster."], ["Turbine Ring", "The ring is rebuilt with more turbine blades, spinning faster."]) },
    { name: "Pulse Core", cost: 980, effect: "Every 1.15 s (primary)", options: T(["Segmented Ring", "The ring is rebuilt as seven turning segments, spinning faster."], ["Flywheel", "The ring is rebuilt as a flywheel with six spokes, spinning faster."], ["Turbine Ring", "The ring is rebuilt with more turbine blades, spinning faster."]) },
    { name: "Rapid Core", cost: 1645, effect: "Every second", options: T(["Segmented Ring", "The ring is rebuilt as eight turning segments, spinning faster."], ["Flywheel", "The ring is rebuilt as a flywheel with seven spokes, spinning faster."], ["Turbine Ring", "The ring is rebuilt with more turbine blades, spinning faster."]) },
    { name: "Chain Pulse", cost: 6310, effect: "Every 0.8 s (mastery)", options: T(["Gold Segmented Ring", "The nine ring segments get gold rims and spin fast; the waves chain."], ["Gold Flywheel", "The eight flywheel spokes turn gold and spin fast; the waves chain."], ["Gold Turbine Ring", "The turbine blades turn gold and spin fast; the waves chain."]) },
  ] },
  { name: "Effect", theme: "the clamps: the three clamps are rebuilt at every step as bigger violet resonators; barrier enemies show a barrier that the waves chew through", steps: [
    { name: "Disruptor Wave", cost: 45, effect: "x1.5 damage to barriers", options: T(["Tuning Forks", "The three clamps are replaced by big violet tuning forks; barriers take 1.5x."], ["Ripple Drums", "The three clamps are replaced by violet drums that send out ripples; barriers take 1.5x."], ["Violet Crystals", "The three clamps are replaced by violet crystals; barriers take 1.5x."]) },
    { name: "Harmonic Wave", cost: 55, effect: "x2 to barriers", options: T(["Tuning Forks", "The resonators are rebuilt larger; barriers take 2x."], ["Ripple Drums", "The resonators are rebuilt larger; barriers take 2x."], ["Violet Crystals", "The resonators are rebuilt larger; barriers take 2x."]) },
    { name: "Resonance", cost: 145, effect: "x2.5 to barriers (primary)", options: T(["Triple Forks", "The resonators are rebuilt with a crossbar between the forks; barriers take 2.5x."], ["Triple-Ripple Drums", "The resonators are rebuilt and send out three ripples; barriers take 2.5x."], ["Twin Crystals", "The resonators are rebuilt with a second crystal on the outer edge; barriers take 2.5x."]) },
    { name: "Breaker Wave", cost: 290, effect: "x3 to barriers", options: T(["Breaker Forks", "The resonators are rebuilt larger, with three forks each; barriers take 3x."], ["Breaker Drums", "The resonators are rebuilt larger; barriers take 3x."], ["Breaker Crystals", "The resonators are rebuilt larger; barriers take 3x."]) },
    { name: "Shatter Shock", cost: 1300, effect: "Each wave shatters half of every barrier it hits; they can't regenerate for 5 s (mastery)", options: T(["Gold Forks", "The forks turn gold; each wave shatters half of each barrier, in gold shards, and it cannot grow back for 5 s."], ["Gold Drums", "The drums turn gold; each wave shatters half of each barrier, in gold shards, and it cannot grow back for 5 s."], ["Gold Crystals", "The crystals turn gold; each wave shatters half of each barrier, in gold shards, and it cannot grow back for 5 s."]) },
  ] },
];
P2.retrofits = [
  { name: "Wave Focus", cost: 245, effect: "+15 px radius (stacks with the path-1 radius)", options: T(["Focus Ring", "A metal focusing ring with bright lenses round the core."], ["Lens Array", "Four glass focusing lenses round the core."], ["Focus Collar", "A finned focusing collar round the core."]) },
  { name: "Containment Coils", cost: 120, effect: "+10 damage (stacks with the path-1 damage)", options: T(["Glowing Coils", "Two glowing helical coils wind round the core."], ["Coil Cage", "Six glowing coil posts cage the core."], ["Toroid Coils", "Two glowing toroid coils ring the core."]) },
  { name: "Reactor Venting", cost: 150, effect: "A wave every 1.5 s (stacks with the Speed path)", options: T(["Vent Stacks", "Four exhaust stacks at the corners vent grey steam."], ["Louvre Vents", "Four louvre vents at the corners glow amber."], ["Stack and Blast Vents", "Four exhaust stacks with blast vents at the corners; a blast flares and smoke billows out of each with every burst."]) },
];

// ---- Round 2 (owner's picks, 2026-10-19). Path 2, Path 3, Wave Focus and Containment Coils are unpicked: they show their options again.
P2.picks = { p0s0: "A", p0s1: "B", p0s2: "B", p0s3: "C", p0s4: "C", r2: "C" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { const pk = P2.picks["p" + pi + "s" + k]; if (pk) st.options = st.options.filter((o) => o.key === pk); }));
P2.retrofits.forEach((rf, ri) => { const pk = P2.picks["r" + ri]; if (pk) rf.options = rf.options.filter((o) => o.key === pk); });
