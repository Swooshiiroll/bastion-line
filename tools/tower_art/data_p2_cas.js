// ---- Tower art second pass: CAS Gunship (tower 10), round 1 --------------------------------------------------------
// Base: look A Airfield Beacon + Four-Engine Gunship, animation A Gatling Stream. This tower has its own upgrade system
// (owner): each path upgrades ONE gun and every path is uncapped, so a full build has all three guns maxed:
//   path 1 the light gun (a gatling, built in), path 2 the medium gun (an autocannon, unlocked at step 1),
//   path 3 the heavy gun (guided missiles, unlocked at step 1).
// Lessons carried: options swap parts rather than lay overlays over them; masteries are gold; the guns fire from the plane's
// inner side and are never drawn on top of the plane (owner, round 3 of the base pass); the plane flies high so it is drawn
// at twice the ground scale with its shadow far below. The ground station is fixed.
// The Retrofit overlaps (kept, stacking: the carpet rule): Extra Ammo's +10% fire rate adds to every gun's fire-rate steps.
// Geometry (game px, plane frame: x forward, y to the inner side where the guns fire): fuselage x -12 to 13 (5 wide),
// tail at -11, wing at x 2 (36 across), four engines at y +-6 and +-12, the side door at (1, 3.2).
const PAGE = { title: "CAS Gunship: paths and Retrofits (second pass)", store: "bl-tower-art-p2-cas-r1" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], RED = [0.85, 0.2, 0.18, 1], ORANGE = [1, 0.55, 0.2, 1], YEL = [1, 0.85, 0.2, 1], CYAN = [0.4, 0.9, 1, 1];
const ZP = 2.0; // the plane is drawn this much bigger than the ground
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null);
const rotorC = (p, r, t, k) => { disc(p, r, [0.8, 0.85, 0.95, 0.12]); ring(p, r, [0.8, 0.86, 0.95, 0.35], 0.8); for (let q = 0; q < 2; q++) line(p, add(p, mul(fa(t * 40 + q * Math.PI), r * 0.95)), [0.85, 0.9, 1, 0.55], 1.1 * k); };
function shadowC(p, heading, k, span, len) { const q = add(p, [k * 10, k * 16]); fill(q, rectPts(len * 0.5, 2.6), [0, 0, 0, 0.14], heading, k); fill(q, rectPts(2.4, span * 0.5), [0, 0, 0, 0.14], heading, k); }

// ---- Fire rates (shots per second / seconds per volley) from each gun's path, Extra Ammo stacking +10% ------------------
const extraOf = (B) => (B.r === 1 ? 1.1 : 1);
const gatRate = (B) => [5, 5, 6, 6, 7.5, 9][B.lv[0]] * extraOf(B);
const canRate = (B) => [0, 1.5, 1.8, 1.8, 2.2, 2.2][B.lv[1]] * extraOf(B);
const misGap = (B) => [0, 3, 2.5, 2.5, 2, 2][B.lv[2]] / extraOf(B);
const orbitMul = (B) => (B.r === 2 ? 115 / 90 : 1);

// ---- The plane --------------------------------------------------------------------------------------------------------
function drawPlane(B, p, h, s, fx, t, col) {
  const k = G(s) * ZP, D = (x, y) => P(p, h, k, x, y), g = (fx.mem && fx.mem.g) || null, since = (key) => (g ? Math.max(0, fx.mem.t - g[key].fl) : 9);
  const P1 = Kp(B, 0, 0), P2 = Kp(B, 0, 1), P3 = Kp(B, 0, 2), P4 = Kp(B, 0, 3), PM = Kp(B, 0, 4), C1 = Kp(B, 1, 0), C2 = Kp(B, 1, 1), C3 = Kp(B, 1, 2), C4 = Kp(B, 1, 3), CM = Kp(B, 1, 4);
  const M1 = Kp(B, 2, 0), M2 = Kp(B, 2, 1), M3 = Kp(B, 2, 2), M4 = Kp(B, 2, 3), MM = Kp(B, 2, 4), R = B.r >= 0 ? B.key("r" + B.r) : null;
  const W = 18 + (B.r === 2 ? 4 : 0), gold = (flag, c) => (flag ? GOLD : c);
  shadowC(p, h, k, 2 * W, 26);
  // fuselage, tail, wing, engines (the base airframe), then every detail is a swap or an addition on it
  bar(D(-12, 0), D(13, 0), 5 * k, METAL_L); plate(D(-11, 0), rectPts(1.6, 6.5), METAL, h, k, 0.9);
  plate(D(2, 0), rectPts(2.4, W), METAL_L, h, k, 1);
  if (B.r === 2) { const R2k = B.key("r2"); if (R2k === "B") for (const sg of [-1, 1]) plate(D(2, sg * (W + 0.4)), [[2.4, 0], [1, sg * 2.2], [-1.6, sg * 2.2], [-2.4, 0]], METAL, h, k, 0.9);
    if (R2k === "C") for (const sg of [-1, 1]) line(D(2, sg * 6), D(2, sg * (W - 1)), STEEL, 0.9 * k); if (R2k === "A") for (const sg of [-1, 1]) { bar(D(2.4, sg * W), D(-1, sg * W), 1.4 * k, STEEL); } }
  // Propellers face forward (owner): each engine is a nacelle on the wing with its propeller disc in front, seen edge-on from above
  for (const y of [-12, -6, 6, 12]) { bar(D(-0.5, y), D(5, y), 2.2 * k, METAL); orb(D(5.4, y), 0.9 * k, METAL_L); const L = 2.7; line(D(6.4, y - L), D(6.4, y + L), [0.85, 0.9, 1, 0.18], 1.3 * k); line(D(6.4, y - L), D(6.4, y + L), [0.9, 0.93, 1, 0.7], 0.5 * k); }
  glowDot(D(12, 0), 0.8 * k, col); glowDot(D(2, -W), 0.7 * k, [1, 0.25, 0.25, 1]); glowDot(D(2, W), 0.7 * k, [0.3, 1, 0.45, 1]);
  // -- The guns are INSIDE the fuselage (owner): each shows only a port in the hull's inner edge, a hatch that slides open as it fires --
  // (flash and projectile leave the opening); the options are the hatch frames, panels and fairings, never a barrel or rack outside.
  const HY = 1.2; // the hatches sit inside the fuselage outline, a little in from its inner edge (the hull is 2.5 px each side of the centreline)
  // A hatch stays open while its gun keeps firing and eases shut afterwards, so a fast gun doesn't make the door flicker.
  const HOLD = { gat: 0.5, can: 0.4, can2: 0.4, mis: 0.7 };
  const openAmt = (key) => { const sn = since(key), hold = HOLD[key] || 0.4; return sn < hold ? 1 : Math.max(0, 1 - (sn - hold) / 0.25); };
  const hatch = (x, key, w, hh, doorCol, frameCol) => { const op = openAmt(key), fr = frameCol || STEEL;
    plate(D(x, HY), rectPts(w + 0.35, hh + 0.3), fr, h, k, 0.8); plate(D(x, HY), rectPts(w, hh), BORE, h, k, 0.8);
    plate(D(x + op * (w * 1.7), HY), rectPts(w * 0.94, hh * 0.9), doorCol || METAL_D, h, k, 0.8); if (op > 0) glowDot(D(x - w * 0.3, HY + 0.2), 0.7 * k * op, A(ORANGE, op)); return op; };
  const panel = (x, y, w, hh, c) => plate(D(x, y), rectPts(w, hh), c || METAL_D, h, k, 0.7);
  // Light gun (gatling): the side door and the hull details round it
  const gx = 1, gcol = PM ? GOLD : null;
  hatch(gx, "gat", 1.5, 0.8, gcol ? lt(GOLD, 0.05) : METAL_D, P1 === "B" ? STEEL : P3 === "A" ? [0.12, 0.12, 0.15, 1] : STEEL);
  if (PM) hatch(5.5, "gat", 1.5, 0.8, lt(GOLD, 0.05), PM === "B" ? GOLD : STEEL);
  if (PM === "B") ring(D(gx, HY), 1.9 * k, GOLD, 0.8 * k);
  if (PM === "C") orb(D(-1.6, 1.9), 0.9 * k, GOLD);
  if (P1 === "A") polyline([D(-3.4, 1.5), D(-2.6, 1.9), D(-1.8, 1.5), D(-1, 1.9), D(-0.2, 1.5)], YEL, 0.5 * k);
  if (P1 === "C") orb(D(-1.6, 1.9), 0.9 * k, METAL_D);
  if (P2 === "A" && openAmt("gat") > 0.6) for (let i = 0; i < 3; i++) line(D(gx - 0.6 + i * 0.6, HY - 0.3), D(gx - 0.2 + i * 0.6, HY + 0.3), A(WHITE, 0.6), 0.4 * k);
  if (P2 === "B") for (let i = 0; i < 3; i++) line(D(-5 + i * 1.1, 1.2), D(-5 + i * 1.1, 2.2), [0, 0, 0, 0.6], 0.5 * k);
  if (P2 === "C") panel(-3.6, 1.7, 1.2, 0.7, METAL);
  if (P3 === "B") panel(-5, 1.6, 1, 0.7, AMMO);
  if (P3 === "C") for (let i = 0; i < 3; i++) glowDot(D(3.4 + i * 0.7, 1.6), 0.3 * k, A([0.5, 1, 0.5, 1], 0.8));
  if (P4 === "A") { panel(-2, 1.5, 1.4, 0.5, METAL_D); glowDot(D(-2.8, 1.5), 0.3 * k, ORANGE); }
  if (P4 === "B") { bar(D(-3, 1.2), D(-3, 2.2), 0.9 * k, STEEL); disc(add(D(-3, 2.2), [0, -k * ((t * 0.9) % 1) * 2]), 0.7 * k, [0.8, 0.82, 0.84, 0.4]); }
  if (P4 === "C") for (let i = 0; i < 3; i++) line(D(-2.4 + i * 0.7, 0.9), D(-2.4 + i * 0.7, 2), A(ORANGE, 0.9), 0.5 * k);
  // Medium gun (autocannon): a port aft of the door from its first step
  if (B.lv[1] >= 1) { const cx = -6.5, cg = CM ? GOLD : null;
    hatch(cx, "can", 1.4, 0.8, cg ? lt(GOLD, 0.05) : METAL_D, C3 === "B" ? RED : C3 === "A" ? RED : STEEL);
    if (CM === "A") hatch(-10, "can2", 1.4, 0.8, lt(GOLD, 0.05), GOLD);
    if (CM === "B") ring(D(cx, HY), 1.8 * k, GOLD, 0.8 * k);
    if (CM === "C") plate(D(cx, 1.6), rectPts(1.9, 0.7), A(GOLD, 0.85), h, k, 0.7);
    if (C1 === "A") ring(D(cx, HY), 1.6 * k, STEEL, 0.9 * k);
    if (C1 === "B") orb(D(cx, 1.9), 1 * k, METAL_D);
    if (C1 === "C") plate(D(cx, 2), rectPts(0.4, 0.5), STEEL, h, k, 0.8);
    if (C2 === "A") for (const x of [-9, -8.4]) line(D(x, 0.6), D(x, 1.8), [0, 0, 0, 0.55], 0.5 * k);
    if (C2 === "B") panel(-8.8, 1.6, 1.1, 0.7, AMMO);
    if (C2 === "C") orb(D(-8.8, 1.6), 0.8 * k, METAL);
    if (C3 === "C") line(D(cx - 1, HY), D(cx + 1, HY), RED, 0.9 * k);
    if (C4 === "A") for (const x of [-4.6, -4]) line(D(x, 1.2), D(x, 2.2), [0, 0, 0, 0.55], 0.5 * k);
    if (C4 === "B") panel(-4.2, 1.6, 0.9, 0.7, METAL_D);
    if (C4 === "C") for (const x of [-4.6, -3.8]) { disc(D(x, 1.7), 0.5 * k, OUTLINE); disc(D(x, 1.7), 0.35 * k, STEEL); } }
  // Heavy gun (missiles): a bay in the flank by the wing root from its first step; its doors drop open to launch
  if (B.lv[2] >= 1) { const mx = M1 === "B" ? 9.5 : 7.5, mg = MM ? GOLD : null, w = M3 === "A" ? 3 : 2.4;
    hatch(mx, "mis", w, 1.0, mg ? lt(GOLD, 0.05) : METAL_D, M3 === "C" ? STEEL : MM === "A" ? GOLD : STEEL);
    if (M1 === "C") hatch(5, "mis", 1.6, 1.0, METAL_D, STEEL);
    for (let i = -1; i <= 1; i++) line(D(mx + i * 1.2, HY - 0.5), D(mx + i * 1.2, HY + 0.5), [0.15, 0.15, 0.18, 0.7], 0.5 * k);
    if (M2 === "A") { line(D(mx - w, HY - 0.9), D(mx + w, HY - 0.9), STEEL, 0.5 * k); line(D(mx - w, HY + 0.9), D(mx + w, HY + 0.9), STEEL, 0.5 * k); }
    if (M2 === "B") bar(D(mx - w - 0.2, 1.4), D(mx - w + 0.8, 2.4), 0.6 * k, METAL_D);
    if (M2 === "C") for (let i = 0; i < 3; i++) glowDot(D(mx - 2 + i * 0.7, 1.2), 0.3 * k, A([0.5, 1, 0.5, 1], 0.8));
    if (M3 === "B") { line(D(mx - w * 0.5, HY - 0.7), D(mx - w * 0.5, HY + 0.7), YEL, 0.7 * k); line(D(mx + w * 0.5, HY - 0.7), D(mx + w * 0.5, HY + 0.7), YEL, 0.7 * k); }
    if (M4 === "A") for (let i = 0; i < 3; i++) glowDot(D(mx - 1.4 + i * 1.4, 1.2), 0.3 * k, A(ORANGE, 0.9));
    if (M4 === "B") hatch(mx + 4, "mis", 1.4, 0.9, METAL_D, STEEL);
    if (M4 === "C") for (const y of [1.4, 1.9]) line(D(mx - w, y), D(mx + w, y), METAL_L, 0.4 * k);
    if (MM === "B") plate(D(mx, HY), rectPts(w * 0.94, 0.9), A(GOLD, 0.4), h, k, 0.7);
    if (MM === "C") for (const sx of [-1, 1]) disc(D(mx + sx * w, HY - 0.9), 0.4 * k, GOLD); }
  // -- Retrofits ------------------------------------------------------------------------------------------------------------------------
  if (B.r === 0) { const ky = B.key("r0"), sw = t * 3;
    if (ky === "A") { disc(D(-2, 0), 2.6 * k, OUTLINE); disc(D(-2, 0), 2.1 * k, [0.7, 0.75, 0.8, 0.9]); line(D(-2, 0), add(D(-2, 0), mul(fa(sw), 2 * k)), A(col, 0.9), 0.8 * k); }
    if (ky === "B") { plate(D(10, 0), rectPts(1.7, 1.4), METAL_D, h, k, 0.9); glowDot(D(10.4, 0), 0.5 * k, A(col, 0.5 + 0.5 * Math.sin(sw))); }
    if (ky === "C") { disc(D(-9, 0), 2.4 * k, OUTLINE); disc(D(-9, 0), 2 * k, METAL_D); line(D(-9, 0), add(D(-9, 0), mul(fa(sw), 2.2 * k)), A(col, 0.9), 0.8 * k); } }
  if (B.r === 1) { const ky = B.key("r1");
    if (ky === "A") { plate(D(-4, -2.6), rectPts(2.4, 1.4), AMMO, h, k, 0.9); }
    if (ky === "B") { orb(D(-4, -2.4), 1.7 * k, METAL_D); orb(D(-1, -2.4), 1.3 * k, METAL_D); }
    if (ky === "C") for (let i = 0; i < 3; i++) plate(D(-5 + i * 2.2, -2.5), rectPts(0.9, 1.1), AMMO, h, k, 0.8); }
}

// ---- The agent: three guns on the plane's inner side, each firing at its own rate, aimed at different enemies -------------
function casAgent(B) { return (m, t, info, s, col) => { const O = info.orbit; if (!O) return; const k = G(s), kz = k * ZP, or = TW.orbit.r * orbitMul(B), a = t * (TW.orbit.w || 0.5), pp = add(O, mul(fa(a), or * s)), h = a + Math.PI / 2;
  const D = (x, y) => P(pp, h, kz, x, y);
  if (!m.g) { m.g = { gat: { last: -9, fl: -9, n: 0 }, can: { last: -9, fl: -9, n: 0 }, can2: { fl: -9 }, mis: { last: -9, fl: -9, n: 0 } }; m.shots = []; }
  m.t = t; const g = m.g, ens = info.ens.slice().sort((x, y) => Math.hypot(x.p[0] - pp[0], x.p[1] - pp[1]) - Math.hypot(y.p[0] - pp[0], y.p[1] - pp[1]));
  const P1 = Kp(B, 0, 0), P3 = Kp(B, 0, 2), P4 = Kp(B, 0, 3), PM = Kp(B, 0, 4), C3 = Kp(B, 1, 2), CM = Kp(B, 1, 4), M3 = Kp(B, 2, 2), MM = Kp(B, 2, 4);
  if (ens.length) {
    if (t - g.gat.last >= 1 / gatRate(B)) { g.gat.last = t; g.gat.fl = t; const tgt = ens[0], twin = B.lv[0] >= 5, from = twin ? D(g.gat.n % 2 ? 5.5 : 1, 1.5) : D(1, 1.5); g.gat.n++; m.shots.push({ type: "gat", t0: t, from, id: tgt.i, to0: tgt.p.slice() }); }
    if (B.lv[1] >= 1 && t - g.can.last >= 1 / canRate(B)) { g.can.last = t; const tgt = ens[Math.min(1, ens.length - 1)], two = B.lv[1] >= 5 && g.can.n % 2; g.can.n++; if (two) g.can2.fl = t; else g.can.fl = t; m.shots.push({ type: "can", t0: t, from: D(two ? -10 : -6.5, 1.5), id: tgt.i, to0: tgt.p.slice() }); }
    if (B.lv[2] >= 1 && t - g.mis.last >= misGap(B)) { g.mis.last = t; g.mis.fl = t; g.mis.n++; const tgt = ens[ens.length - 1], dbl = MM && g.mis.n % 3 === 0;
      for (let j = 0; j < (dbl ? 2 : 1); j++) m.shots.push({ type: "mis", t0: t + j * 0.18, from: D(Kp(B, 2, 0) === "B" ? 9.5 : (Kp(B, 2, 0) === "C" && g.mis.n % 2 ? 5 : 7.5), 1.5), id: ens[Math.max(0, ens.length - 1 - j)].i, to0: ens[Math.max(0, ens.length - 1 - j)].p.slice(), j }); } }
  m.shots = m.shots.filter((q) => t - q.t0 < 1.4);
  const gc = PM ? GOLD : col, gw = 1.5 + (P1 ? 0.3 : 0) + (P3 ? 0.2 : 0), cc = CM ? GOLD : [1, 0.9, 0.6, 1], mc = MM ? GOLD : [0.95, 0.95, 0.98, 1];
  for (const q of m.shots) { const e = info.ens.find((x) => x.i === q.id), to = e ? e.p : q.to0, el = t - q.t0; if (el < 0) continue;
    if (q.type === "gat") { const u = el / 0.18; if (u < 1) { tracer(q.from, to, u, gc, gw, 0.3); if (P3 || PM) tracer(q.from, to, u, [1, 1, 1, 1], gw * 0.4, 0.3); if (P4) tracer(add(q.from, [0, 2]), add(to, [0, 2]), u, A(gc, 0.7), gw * 0.6, 0.25); } else if (u < 2) spark(to, (u - 1) * 0.6, s * 0.7, gc); }
    else if (q.type === "can") { const u = el / 0.35; if (u < 1) { const hp = lerp(q.from, to, u); for (let j = 3; j >= 1; j--) disc(lerp(q.from, to, Math.max(0, u - j * 0.06)), (1 + j * 0.3) * kz * 0.7, A(cc, 0.35 - 0.08 * j)); orb(hp, 1.4 * kz * 0.7 * (C3 ? 1.15 : 1), cc); glowDot(hp, 0.7 * kz * 0.7, CM ? GOLD : ORANGE); }
      else blast(to, Math.min(0.99, (u - 1) * 1.6), s, CM ? GOLD : col, (CM ? 0.24 : 0.2) * (C3 ? 1.15 : 1)); }
    else if (q.type === "mis") { const u = el / 0.85, perp = orth(norm(sub(to, q.from))); if (u < 1) { const pos = (v) => add(lerp(q.from, to, v), mul(perp, Math.sin(Math.PI * v) * s * 0.18 * (q.j ? -1 : 1))), hp = pos(u), pb = pos(Math.max(0, u - 0.03));
        for (let j = 6; j >= 1; j--) disc(pos(Math.max(0, u - j * 0.045)), (0.9 + j * 0.28) * k * (M3 ? 1.25 : 1) * 1.4, [0.7, 0.72, 0.75, 0.3 - 0.04 * j]);
        plate(hp, rectPts(1.7, 0.6), [0.9, 0.9, 0.93, 1], Math.atan2(hp[1] - pb[1], hp[0] - pb[0]), kz * 0.8 * (M3 ? 1.25 : 1), 0.7); glowDot(hp, 0.8 * k, MM ? GOLD : ORANGE); }
      else blast(to, Math.min(0.99, (u - 1) * 1.1), s, MM ? GOLD : col, (MM ? 0.4 : 0.35) * (M3 ? 1.2 : 1)); } } }; }

// ---- The model: the fixed ground station; the plane and its guns are the build's real look ------------------------------------
const P2 = {
  tower: "cas", look: "A", anim: "A", uncapped: true,
  intro: "Round 1: three options for every step and the Retrofits, drawn as one model. This tower has its own upgrade system: every path is uncapped and upgrades one gun, so you can max all three. Path 1 is the light gatling (built in, inside the side door), path 2 the medium autocannon, path 3 the heavy guided missiles; step 1 of paths 2 and 3 adds the gun to the plane's flank. Each gun fires at its own rate at its own enemy under the orbit. The plane stays high with its shadow far below, and no gun shows on top. Extra Ammo's +10% fire rate stacks with the fire-rate steps (the carpet rule); Wide Orbit widens the orbit as well as the wings. Unpicked steps show option A.",
  mods(B) { return { period: 0.2, flight: 0.2, multi: false, persist: casAgent(B) }; },
  orbitR(B, r) { return r * orbitMul(B); },
  door(B, p, h, s) { return P(p, h, G(s) * ZP, 1, 3.2); },
  plane(B, p, h, s, fx, t, col) { drawPlane(B, p, h, s, fx, t, col); },
  muzzleAt(B, m, kk, c) { return c; },
  model(c, aim, s, fx, t, col, info, B) { const k = G(s); deck(c, k, col, t); plate(c, rectPts(12, 12), METAL_D, 0, k, 1.2);
    for (let i = 0; i < 4; i++) rect(c[0] - 1 * k, c[1] + (-10 + i * 5) * k, 2 * k, 2.6 * k, [0.85, 0.85, 0.8, 0.8]);
    bar(add(c, [7 * k, 7 * k]), add(c, [7 * k, -2 * k]), 1.2 * k, METAL_L); const pu = fmod(t * 1.2, 1); glowDot(add(c, [7 * k, -2.8 * k]), (0.9 + 0.6 * (1 - pu)) * k, col); ring(add(c, [7 * k, -2.8 * k]), (1.5 + 5 * pu) * k, A(col, 0.6 * (1 - pu)), 1); },
  paths: [
    { name: "Light gun (gatling)", theme: "the built-in gatling in the side door: damage, rate, damage, rate, then Twin Gatlings", steps: [
      { name: "Heavier Rounds", cost: 175, effect: "Damage 12 to 15", options: [
        { key: "A", name: "Ammo Belt Feed", desc: "A yellow ammo belt snaking into the side door; the tracers are thicker." },
        { key: "B", name: "Heavy Door Frame", desc: "A heavier steel frame round the gatling's door; the tracers are thicker." },
        { key: "C", name: "Ammo Blister", desc: "An ammo drum blister on the fuselage side; the tracers are thicker." } ] },
      { name: "Faster Spin", cost: 350, effect: "6 rounds/s", options: [
        { key: "A", name: "Spin Blur", desc: "The spinning barrels show in the doorway and flash white as it fires; it fires faster." },
        { key: "B", name: "Cooling Vents", desc: "Dark cooling vent slits behind the door; it fires faster." },
        { key: "C", name: "Motor Housing", desc: "A motor housing bump behind the door; it fires faster." } ] },
      { name: "Hardened Rounds", cost: 1125, effect: "19 damage", options: [
        { key: "A", name: "Hardened Door Plate", desc: "A dark armoured plate over the door; the tracers get a white core." },
        { key: "B", name: "Dark Ammo Box", desc: "A dark ammo box on the flank; white-cored tracers." },
        { key: "C", name: "Round Counter", desc: "Three green round-counter lamps beside the door; white-cored tracers." } ] },
      { name: "Overdrive Motor", cost: 2670, effect: "7.5 rounds/s", options: [
        { key: "A", name: "Overdrive Pod", desc: "A small motor pod with an orange lamp beside the door; a second tracer line." },
        { key: "B", name: "Exhaust Stack", desc: "A short exhaust stack puffing smoke; a second tracer line." },
        { key: "C", name: "Heat Fins", desc: "Glowing orange fins on the flank; a second tracer line." } ] },
      { name: "Twin Gatlings", cost: 5345, effect: "9 rounds/s (mastery)", options: [
        { key: "A", name: "Second Door", desc: "A second gold-framed door beside the first; both gatlings fire in turn, gold tracers." },
        { key: "B", name: "Gold Door Rings", desc: "A second door with gold rings round both; gold tracers." },
        { key: "C", name: "Gold Blister", desc: "A second door and a gold ammo blister; gold tracers." } ] },
    ] },
    { name: "Medium gun (autocannon)", theme: "the autocannon on the flank: unlock, feed, rounds, feed, then the battery", steps: [
      { name: "Autocannon", cost: 1145, effect: "Unlocks the autocannon: 40 damage, 1.5 shots/s, 25 px blast", options: [
        { key: "A", name: "Side Barbette", desc: "A round gun housing on the flank with a barrel poking out; it fires shells that burst on the target." },
        { key: "B", name: "Sponson Gun", desc: "A boxy sponson on the fuselage side with a barrel; shells that burst." },
        { key: "C", name: "Shielded Port", desc: "A gun port with a splinter shield on the flank; shells that burst." } ] },
      { name: "Faster Feed", cost: 455, effect: "1.8 shots/s", options: [
        { key: "A", name: "Feed Chute", desc: "A feed chute running into the autocannon." },
        { key: "B", name: "Ammo Box", desc: "An ammo box behind the autocannon." },
        { key: "C", name: "Autoloader Drum", desc: "A small drum behind the autocannon." } ] },
      { name: "HE Rounds", cost: 1645, effect: "52 damage", options: [
        { key: "A", name: "HE Bands", desc: "Red HE bands on the barrel; bigger bursts." },
        { key: "B", name: "HE Ring", desc: "A red ring at the muzzle; bigger bursts." },
        { key: "C", name: "Red Blast Shield", desc: "A red blast shield by the muzzle; bigger bursts." } ] },
      { name: "Twin Feed", cost: 3170, effect: "2.2 shots/s", options: [
        { key: "A", name: "Twin Chutes", desc: "Two feed chutes into the autocannon." },
        { key: "B", name: "Dual Magazine", desc: "A dual magazine block behind the autocannon." },
        { key: "C", name: "Feed Gears", desc: "Two feed gears behind the autocannon." } ] },
      { name: "Autocannon Battery", cost: 7015, effect: "58 damage; 30 px blast (mastery)", options: [
        { key: "A", name: "Twin Barrels", desc: "A second gold barrel; the cannons fire in turn, gold shells with 30 px bursts." },
        { key: "B", name: "Gold Shroud Ring", desc: "A gold ring on the barrel; gold shells with bigger bursts." },
        { key: "C", name: "Gold Housing", desc: "A gold gun housing; gold shells with bigger bursts." } ] },
    ] },
    { name: "Heavy gun (missiles)", theme: "the missile rack: unlock, rack speed, warheads, auto-rack, then Hellfire", steps: [
      { name: "Missile Rack", cost: 1235, effect: "Unlocks guided missiles: 150 damage, one every 3 s, 45 px blast", options: [
        { key: "A", name: "Wing Pylon Rack", desc: "A rack of three missiles on a pylon plate under the wing; guided missiles curve in with a smoke trail." },
        { key: "B", name: "Fuselage Rack", desc: "A rack of three missiles on the forward flank; guided missiles with a smoke trail." },
        { key: "C", name: "Wing Pods", desc: "Two missile pods under the wing; guided missiles with a smoke trail." } ] },
      { name: "Quick Rack", cost: 525, effect: "One every 2.5 s", options: [
        { key: "A", name: "Rack Rails", desc: "Steel rails along the rack." },
        { key: "B", name: "Loader Arm", desc: "A short loader arm by the rack." },
        { key: "C", name: "Ready Lamps", desc: "Three green ready lamps by the rack." } ] },
      { name: "Heavy Warheads", cost: 1595, effect: "190 damage", options: [
        { key: "A", name: "Fat Warheads", desc: "Fatter red missile noses; bigger missiles and bursts." },
        { key: "B", name: "Warhead Bands", desc: "Yellow bands on each missile; bigger missiles and bursts." },
        { key: "C", name: "Armoured Rack", desc: "A steel armour bar along the rack; bigger missiles and bursts." } ] },
      { name: "Auto-Rack", cost: 3785, effect: "One every 2 s", options: [
        { key: "A", name: "Auto-Loader Drum", desc: "A turning drum behind the rack." },
        { key: "B", name: "Second Rack Row", desc: "A second row plate on the rack." },
        { key: "C", name: "Feed Rails", desc: "Two feed rails along the rack." } ] },
      { name: "Hellfire Volley", cost: 13250, effect: "Every third volley fires two missiles (mastery)", options: [
        { key: "A", name: "Gold Rack Frame", desc: "A gold frame on the rack and a fourth gold missile; every third volley fires two gold missiles." },
        { key: "B", name: "Gold Warheads", desc: "Gold warheads and a fourth missile; every third volley fires two." },
        { key: "C", name: "Gold Fins", desc: "Gold fins on the rack and a fourth missile; every third volley fires two." } ] },
    ] },
  ],
  retrofits: [
    { name: "Radar", cost: 35, effect: "Reveals cloaked enemies inside the orbit to every tower", options: [
      { key: "A", name: "Belly Dome", desc: "A radar dome under the fuselage with a sweeping line." },
      { key: "B", name: "Nose Blister", desc: "A radar blister at the nose with a pulsing lamp." },
      { key: "C", name: "Rotodome", desc: "A rotating radar disk behind the wing with a sweeping line." } ] },
    { name: "Extra Ammo", cost: 70, effect: "+10% fire rate on every gun (stacks with the fire-rate steps)", options: [
      { key: "A", name: "Ammo Bay Box", desc: "A bigger ammo bay box on the fuselage's outer side." },
      { key: "B", name: "Ammo Hopper Bulge", desc: "Two ammo hopper bulges on the outer side." },
      { key: "C", name: "Belt Crates", desc: "Three ammo belt crates on the outer side." } ] },
    { name: "Wide Orbit", cost: 195, effect: "+25 px orbit radius (115)", options: [
      { key: "A", name: "Long Wings", desc: "Longer wings with wing-end spars; the plane circles a wider orbit." },
      { key: "B", name: "Winglets", desc: "Longer wings with raked winglets; a wider orbit." },
      { key: "C", name: "Wing Struts", desc: "Longer wings with strut lines; a wider orbit." } ] },
  ],
};
P2.picks = {};
