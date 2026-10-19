// ---- Tower art second pass: Chemical Plant (tower 12), round 1 ----------------------------------------------------
// Base: look F Distillery Columns, animation A Acid Stream. One parametric model with the lessons so far: options swap parts
// rather than lay overlays over them; the projectile (the spray) changes with every Acid step; masteries are gold; the plant's
// own clock drives the timing. All three Retrofits overlap a path step and are kept, their stats stacking (the carpet rule):
// Pressure Pump adds to the Speed path's spray rate, Mist Nozzle to Twin Nozzles, Bigger Tanks to the soak length.
// Geometry (game px): three columns at radius 10 round a central still (r 5) with a gooseneck nozzle that turns to spray; the
// plant sprays one unsoaked enemy at a time; a soaked enemy drips and fizzes until the soak wears off.
const PAGE = { title: "Chemical Plant: paths and Retrofits (second pass)", store: "bl-tower-art-p2-chem-r1" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], RED = [0.85, 0.2, 0.18, 1], GELC = [0.8, 1, 0.45, 1], YEL = [1, 0.85, 0.2, 1];
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null);
const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);

// ---- Stats the look follows: spray gap, soak length, acid and gel strength ------------------------------------------------
const GAP = [1.5, 1.25, 1.25, 1.0, 0.83, 0.62];
const gapOf = (B) => Math.max(0.35, GAP[B.lv[1]] - (B.r === 0 ? 0.17 : 0));                  // Pressure Pump stacks
const soakOf = (B) => [4, 4, 5, 6, 6, 7][B.lv[1]] + (B.r === 2 ? 1 : 0);                      // Bigger Tanks stacks
const acidCol = (B, col) => (B.lv[0] >= 5 ? GOLD : B.lv[0] >= 4 ? [0.3, 0.8, 0.2, 1] : B.lv[0] >= 2 ? [0.7, 1, 0.25, 1] : col);

// ---- The agent: sprays one unsoaked enemy at a time (two at the Twin Nozzles mastery; the Mist Nozzle soaks a neighbour too) ----
function soakAgent(B) { return (m, t, info, s, col) => { const k = G(s), gap = gapOf(B), twin = B.lv[1] >= 5, mist = B.r === 1, ac = acidCol(B, col), A1 = B.lv[0], G1 = B.lv[2];
  if (!m.soak) { m.soak = {}; m.last = -9; m.shots = []; m.n = 0; }
  const free = info.ens.filter((e) => !(m.soak[e.i] > t)).sort((a, b) => dist(a.p, info.c) - dist(b.p, info.c));
  if (free[0]) m.aimAt = free[0].p.slice();
  if (free.length && t - m.last >= gap) { m.last = t; m.n++;
    const mk = (e, side) => m.shots.push({ t0: t, id: e.i, to0: e.p.slice(), side, flight: 0.5 });
    mk(free[0], 0); if (twin && free[1]) mk(free[1], 1);
    if (mist) { const near = free.find((e) => e !== free[0] && (!twin || e !== free[1]) && dist(e.p, free[0].p) < s * 0.6); if (near) m.shots.push({ t0: t, id: near.i, to0: near.p.slice(), side: 2, flight: 0.5, mist: true }); } }
  for (const q of m.shots) { const age = t - q.t0, e = info.ens.find((x) => x.i === q.id), to = e ? e.p : q.to0;
    if (age >= q.flight) { if (!q.done) { q.done = true; if (e) m.soak[e.i] = t + soakOf(B); } continue; }
    const u = age / q.flight, nz = (info.muzzleAt ? info.muzzleAt(0, info.aim) : info.c), f = q.side === 1 ? add(nz, mul(orth(norm(sub(to, nz))), 3 * k)) : q.side === 2 ? add(nz, mul(orth(norm(sub(to, nz))), -3 * k)) : nz;
    if (q.mist) { const p = lerp(f, to, u); for (let i = 0; i < 4; i++) disc(add(p, mul(fa(i * 1.7 + u * 7), s * 0.04)), s * (0.05 + u * 0.05), A(ac, 0.3)); continue; }
    for (let i = 0; i < 9; i++) { const qq = Math.min(u * 1.6, 1) - i * 0.06; if (qq < 0) continue; const p = add(lerp(f, to, qq), [0, -Math.sin(Math.PI * qq) * s * 0.25]), r = (1.4 + 0.3 * (i % 2)) * (1 + 0.14 * A1) * (G1 ? 1.15 : 1);
      disc(p, r, A(ac, 0.9 - i * 0.06)); if (G1) disc(add(p, [-0.4, -0.4]), r * 0.35, [1, 1, 1, 0.55 * (1 - i * 0.08)]); if (A1 >= 4 && i % 3 === 0) ring(add(p, [0, -2]), 1.3, A(lt(ac, 0.4), 0.5), 0.6); } }
  m.shots = m.shots.filter((q) => t - q.t0 < q.flight + 0.1);
  for (const e of info.ens) { const left = m.soak[e.i] - t; if (!(left > 0)) continue; const p = e.p, a = Math.min(1, left * 3), n = e.i, r = Math.max(4, Math.min(11, s * 0.12));
    disc(p, s * 0.14, A(ac, 0.3 * a));
    for (let i = 0; i < 2; i++) { const d = fmod(t * 1.5 + i * 0.5 + n * 0.3, 1); disc(add(p, [(i - 0.5) * s * 0.1, d * s * 0.18]), 1.2, A(ac, (1 - d) * a)); }
    for (let i = 0; i < 3 + (A1 >= 2 ? 2 : 0); i++) { const b = fmod(t * 2 + i * 0.33 + n, 1); ring(add(p, [(rnd2(i + n) - 0.5) * s * 0.18, -b * s * 0.15]), 1 + b * 1.5, A(lt(ac, 0.4), (1 - b) * a), 0.8); }
    if (A1 >= 1) for (let i = 0; i < 3; i++) { const d = fmod(t * 0.9 + i * 0.37 + n * 0.2, 1); fill(add(p, [(i - 1) * r * 0.7, -r * 0.2 + d * s * 0.2]), rectPts(1.1, 0.7), A([0.5, 0.52, 0.55, 1], (1 - d) * a), d * 4 + i, 1); } // stripped armour flakes falling off
    if (G1) { arc(p, r + 1, Math.PI * 1.1, Math.PI * 1.9, A(GELC, (0.5 + 0.1 * G1) * a), 2 + G1 * 0.8); for (let i = 0; i < 3; i++) { const d = fmod(t * 0.9 + i * 0.33 + n * 0.2, 1); line(add(p, [(i - 1) * r * 0.6, -r * 0.6]), add(p, [(i - 1) * r * 0.6, -r * 0.6 + d * s * 0.2 * (0.6 + 0.1 * G1)]), A(GELC, a * (1 - d)), 1.4 + 0.2 * G1); } } } }; }

// ---- The model ---------------------------------------------------------------------------------------------------------
const P2 = {
  tower: "chem", look: "F", anim: "A",
  intro: "Round 1: three options for every step and Retrofit, drawn as one model so the paths combine. The spray itself changes at every Acid step (bigger drops, a yellower mix, a bubbling dark mix, gold at the Dissolver), a soaked enemy sheds armour flakes and burns, and the Slowing path coats it in thicker and thicker gel. Speed adds valves, pumps and, at the mastery, a second nozzle that sprays two enemies. All three Retrofits overlap a path step and are kept (the carpet rule), their stats stacking. Unpicked steps show option A.",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: soakAgent(B) }; },
  muzzleAt(B, m, kk, c, aim, s) { return P(c, aim, G(s), 13.5, 0); },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), D = (x, y) => P(c, aim, k, x, y), S = (x, y) => add(c, [x * k, y * k]), mm = fx.mem || {}, since = t - (mm.last ?? -9), fl = decay(since, 0.25), ac = acidCol(B, col);
    const A1 = Kp(B, 0, 0), A2 = Kp(B, 0, 1), A3 = Kp(B, 0, 2), A4 = Kp(B, 0, 3), AM = Kp(B, 0, 4), V1 = Kp(B, 1, 0), V2 = Kp(B, 1, 1), V3 = Kp(B, 1, 2), V4 = Kp(B, 1, 3), VM = Kp(B, 1, 4);
    const G1 = Kp(B, 2, 0), G2 = Kp(B, 2, 1), G3 = Kp(B, 2, 2), G4 = Kp(B, 2, 3), GM = Kp(B, 2, 4), R = B.r >= 0 ? B.key("r" + B.r) : null, gold = (c0) => (B.lv[0] >= 5 ? GOLD : c0);
    deck(c, k, col, t);
    // -- The three columns, bigger with Bigger Tanks (option A), with the Acid/Speed/Slowing parts on them ----------------------
    const colR = (B.r === 2 && R === "A" ? 4.8 : 4);
    for (let i = 0; i < 3; i++) { const a = -Math.PI / 2 + i * TAU / 3, q = add(c, mul(fa(a), 10 * k)); bar(c, q, 1.4 * k, METAL); orb(q, colR * k, METAL_L); ring(q, (colR - 1.2) * k, METAL, 0.8 * k); glowDot(q, 0.9 * k, A(ac, 0.5 + 0.5 * Math.sin(t * 2 + i)));
      if (A1 === "A") ring(q, (colR - 0.2) * k, YEL, 0.8 * k);
      if (A1 === "B" && i === 0) plate(add(q, [0, -colR * k - 1.6 * k]), rectPts(2.6, 1.2), METAL_D, 0, k, 0.9);
      if (A2 === "A") for (let j = 0; j < 3; j++) line(add(q, mul(fa(j * 2.1 + 0.5), (colR - 1.8) * k)), add(q, mul(fa(j * 2.1 + 0.5), (colR - 0.3) * k)), [0, 0, 0, 0.5], 0.6 * k);
      if (A2 === "C") ring(q, (colR - 2.2) * k, A(ac, 0.7), 1.2 * k);
      if (V3 === "A") orb(add(q, mul(fa(a + 0.7), (colR - 0.6) * k)), 0.8 * k, METAL);
      if (G1 === "A" && i === 1) disc(add(q, [colR * 0.4 * k, colR * 0.7 * k]), 1.3 * k, GELC);
      if (R === "C" && B.r === 2) ring(q, (colR + 0.3) * k, STEEL, 0.9 * k);
      if (AM === "A") ring(q, colR * k, GOLD, 1 * k); }
    // -- Fixed kit between the columns ------------------------------------------------------------------------------------------------
    if (A1 === "C") { const q = S(12.5, -3.5); disc(q, 2.2 * k, OUTLINE); disc(q, 1.8 * k, [0.9, 0.9, 0.85, 1]); line(q, add(q, mul(fa(-2 + Math.sin(t * 2) * 0.4), 1.4 * k)), RED, 0.6 * k); }
    if (A2 === "B") { plate(S(-12.5, -3.5), rectPts(2.4, 1.8), AMMO, 0, k, 0.9); for (let i = 0; i < 3; i++) fill(S(-13.6 + i * 1.1, -3.5), rectPts(0.5, 0.5), [0.5, 0.52, 0.55, 1], i, k); }
    if (A3 === "A") { plate(S(5, 13), rectPts(2.6, 1.5), METAL_D, 0, k, 1); glowDot(S(5, 13), 0.6 * k, ac); }
    if (A3 === "B") { disc(S(5, 13), 2.2 * k, OUTLINE); disc(S(5, 13), 1.8 * k, dk(ac, 0.45)); }
    if (A3 === "C") for (let i = 0; i < 3; i++) glowDot(S(3 + i * 2, 13), 0.5 * k, A(ac, 0.4 + 0.5 * Math.sin(t * 4 + i)));
    if (A4 === "A") { bar(S(-5, 12.5), S(-1, 12.5), 1.6 * k, METAL); orb(S(-5.8, 12.5), 1.4 * k, METAL_L); }
    if (A4 === "B") for (let i = 0; i < 3; i++) ring(S(-3, 12.5), (1 + i * 0.9) * k, A(ac, 0.5 - i * 0.12), 0.8 * k);
    if (A4 === "C") plate(S(-3, 12.5), rectPts(2.8, 1.2), METAL_D, 0, k, 0.9);
    if (AM === "B") plate(S(12.5, 5), rectPts(2.4, 2.4), GOLD, 0, k, 1);
    if (AM === "C") { disc(S(-12.5, 5), 2.4 * k, OUTLINE); disc(S(-12.5, 5), 2 * k, GOLD); }
    if (G2 === "A") for (const x of [-12.8, -10.6]) bar(S(x, 8), S(x, 11), 1.4 * k, GELC);
    if (G2 === "B") { plate(S(-12, 9.5), rectPts(2.4, 1.6), METAL_D, 0, k, 1); glowDot(S(-12, 9.5), 0.5 * k, GELC); }
    if (G2 === "C") { disc(S(-12, 9.5), 2.2 * k, OUTLINE); disc(S(-12, 9.5), 1.8 * k, dk(GELC, 0.45)); }
    if (G3 === "A") { disc(S(12.5, 9.5), 2.6 * k, OUTLINE); disc(S(12.5, 9.5), 2.1 * k, [0.45, 0.4, 0.25, 1]); glowDot(S(12.5, 9.5), 0.6 * k, GELC); }
    if (G3 === "B") { plate(S(12.5, 9.5), rectPts(1.8, 2.2), METAL_L, 0, k, 1); ring(S(12.5, 8.4), 1.4 * k, GELC, 0.7 * k); }
    if (G3 === "C") { bar(S(10.5, 10), S(14.5, 8.5), 1.4 * k, METAL); orb(S(14.8, 8.4), 0.9 * k, GELC); }
    if (G4 === "A") { bar(S(7.5, 12.5), S(7.5, 14.5), 1.2 * k, STEEL); glowDot(S(7.5, 14.8), 0.6 * k, [0.5, 0.8, 1, 1]); }
    if (G4 === "B") { plate(S(8, 13.4), rectPts(2, 0.9), METAL_D, 0, k, 0.9); glowDot(S(8, 13.4), 0.5 * k, [0.5, 0.8, 1, 1]); }
    if (G4 === "C") { const fa2 = t * 9; for (let i = 0; i < 3; i++) line(S(8, 13.4), add(S(8, 13.4), mul(fa(fa2 + i * TAU / 3), 2.2 * k)), STEEL, 1 * k); }
    if (GM === "A") { fill(S(-4, 13.4), [[0, -1.2], [3, 0], [0, 1.2]], GOLD, 0, k); }
    if (GM === "B") { plate(S(-4, 13.4), rectPts(2.2, 1.6), GOLD, 0, k, 1); }
    if (GM === "C") { disc(S(-4, 13.4), 2 * k, OUTLINE); disc(S(-4, 13.4), 1.6 * k, GOLD); }
    if (B.r === 2 && R === "B") plate(S(0, -13.6), rectPts(3, 1.8), TANKC, 0, k, 1);
    // -- The still, the Retrofit gauges, and the gooseneck nozzle(s) (these turn to the target) ---------------------------------------
    orb(c, 5 * k, mix(METAL_L, ac, 0.15));
    if (V1 === "A") { const w = D(-3, -3.4); disc(w, 1.4 * k, OUTLINE); ring(w, 1.1 * k, RED, 0.9 * k); line(w, add(w, mul(fa(t * (since < 0.4 ? 8 : 1)), 1.1 * k)), RED, 0.6 * k); }
    if (V1 === "B") { const w = D(-3, -3.4); disc(w, 1.4 * k, OUTLINE); disc(w, 1.1 * k, [0.9, 0.9, 0.85, 1]); line(w, add(w, mul(fa(-2 + (1 - fl) * 1.2), 1 * k)), RED, 0.5 * k); }
    if (V1 === "C") { ring(D(-3, -3.4), 1.8 * k, METAL_D, 1.6 * k); ring(D(-3, -3.4), 1 * k, METAL_D, 1.2 * k); }
    if (V2 === "A") { const w = D(-3.4, 3.4); disc(w, 1.6 * k, OUTLINE); for (let i = 0; i < 3; i++) line(w, add(w, mul(fa(t * 3 + i * TAU / 3), 1.4 * k)), METAL_L, 0.9 * k); }
    if (V2 === "B") { plate(D(-3.4, 3.4), rectPts(1.6, 1.4), METAL_D, aim, k, 0.9); glowDot(D(-3.4, 3.4), 0.5 * k, ac); }
    if (V2 === "C") for (let i = 0; i < 3; i++) ring(D(-3.4, 3.4), (0.8 + i * 0.5) * k, A(ac, 0.6 - i * 0.15), 0.7 * k);
    if (V3 === "B") plate(D(2, 0), rectPts(0.8, 3.4), METAL_D, aim, k, 0.9);
    if (V3 === "C") for (const y of [-2.4, 2.4]) bar(D(2, y), D(7, y), 0.9 * k, STEEL);
    if (V4 === "A") { plate(D(0.5, 3.8), rectPts(1.6, 1), METAL_D, aim, k, 0.9); bar(D(0.5 + (fl > 0.2 ? -0.6 : 0.4), 3.8), D(2, 3.8), 0.7 * k, METAL_L); }
    if (V4 === "B") { bar(D(1, -3), D(6, -3), 1.4 * k, METAL); }
    if (V4 === "C") { const w = D(0.5, -3.6); disc(w, 1.3 * k, OUTLINE); disc(w, 1 * k, [0.9, 0.9, 0.85, 1]); line(w, add(w, mul(fa(aim + 1 - fl * 0.8), 0.9 * k)), RED, 0.5 * k); }
    bar(c, D(6, 0), 2.4 * k, METAL);
    const nozzle = (y, gc) => { bar(D(6, y), D(13, y), 1.6 * k, gc ? GOLD : METAL); glowDot(D(13.4, y), (0.7 + 1.4 * fl) * k, A(ac, 0.5 + 0.5 * fl)); };
    if (VM === "A") { nozzle(-1.8, true); nozzle(1.8, true); }
    else if (VM === "B") { for (const sg of [-1, 1]) { const dd = (x, y) => P(c, aim + sg * 0.22, k, x, y); bar(dd(6, 0), dd(13, 0), 1.5 * k, GOLD); glowDot(dd(13.4, 0), (0.7 + 1.4 * fl) * k, A(ac, 0.5 + 0.5 * fl)); } }
    else if (VM === "C") { bar(D(6, 0), D(9, 0), 2 * k, GOLD); for (const sg of [-1, 1]) { bar(D(9, 0), D(13, sg * 2.6), 1.4 * k, GOLD); glowDot(D(13.4, sg * 2.8), (0.7 + 1.4 * fl) * k, A(ac, 0.5 + 0.5 * fl)); } }
    else nozzle(0, false);
    if (R === "A" && B.r === 0) { for (const sg of [-1, 1]) { const w = D(9, sg * 2.4); disc(w, 1.1 * k, OUTLINE); disc(w, 0.85 * k, [0.9, 0.9, 0.85, 1]); line(w, add(w, mul(fa(aim + 0.5 + sg * fl), 0.8 * k)), RED, 0.5 * k); } }
    if (R === "B" && B.r === 0) { plate(D(10, 0), rectPts(1.2, 3), METAL_D, aim, k, 0.9); for (let i = -1; i <= 1; i++) glowDot(D(10, i * 1.8), 0.4 * k, A(ac, 0.4 + 0.5 * fl)); }
    if (R === "C" && B.r === 0) for (let i = 0; i < 4; i++) ring(D(8 + i * 1.6, 0), 1.7 * k, A(STEEL, 0.9), 0.9 * k);
    if (R === "A" && B.r === 1) for (const sg of [-1, 1]) { const dd = (x, y) => P(c, aim + sg * 0.35, k, x, y); bar(dd(8, 0), dd(13, 0), 1.4 * k, METAL_L); }
    if (R === "B" && B.r === 1) { fill(D(13, 0), [[0, 0], [3, -2.6], [3, 2.6]], A(METAL_L, 0.9), aim, k); }
    if (R === "C" && B.r === 1) ring(D(12, 0), 2 * k, METAL_L, 1.4 * k);
    glowDot(c, 1.1 * k, ac);
    if (AM === "C" || AM === "A") ring(c, 5 * k, GOLD, 1 * k);
  },
  paths: [
    { name: "Damage/Armor stripping", theme: "acid that strips armour for good: the spray gets stronger and the soaked enemy burns", steps: [
      { name: "Corrosive Acid", cost: 250, effect: "Stripped armour stays gone permanently", options: [
        { key: "A", name: "Hazard Rings", desc: "Yellow hazard rings round the columns; the spray is made of bigger drops, and soaked enemies shed flakes of armour." },
        { key: "B", name: "Scrap Bin", desc: "A scrap bin on top of a column for the stripped armour; bigger drops and shedding armour." },
        { key: "C", name: "Corrosion Gauge", desc: "A gauge by the columns with a red needle; bigger drops and shedding armour." } ] },
      { name: "Etching Acid", cost: 665, effect: "4 armour per soak; acid burns 5 damage/s", options: [
        { key: "A", name: "Etched Columns", desc: "Etched marks on the columns; a yellower mix, and soaked enemies fizz more." },
        { key: "B", name: "Acid Drums", desc: "A little rack of drums with armour scraps; a yellower mix and more fizz." },
        { key: "C", name: "Etch Rings", desc: "A glowing ring in each column; a yellower mix and more fizz." } ] },
      { name: "Fast-Acting Acid", cost: 1335, effect: "5 armour, stripped faster; 10 damage/s (primary)", options: [
        { key: "A", name: "Reaction Block", desc: "A small reaction block with a glowing core; a brighter mix." },
        { key: "B", name: "Reaction Vat", desc: "A dark vat with a glowing top; a brighter mix." },
        { key: "C", name: "Reaction Lamps", desc: "Three pulsing lamps; a brighter mix." } ] },
      { name: "Concentrated Acid", cost: 2665, effect: "6 armour; 15 damage/s", options: [
        { key: "A", name: "Concentrate Press", desc: "A press and a pipe; a dark, bubbling concentrated mix." },
        { key: "B", name: "Concentrate Rings", desc: "Concentric rings of glowing acid; a dark bubbling mix." },
        { key: "C", name: "Concentrate Block", desc: "A heavy block by the columns; a dark bubbling mix." } ] },
      { name: "Dissolver", cost: 5335, effect: "7 armour per soak; 20 damage/s (mastery)", options: [
        { key: "A", name: "Gold Column Rings", desc: "Gold rings on every column and the still; a gold dissolving mix." },
        { key: "B", name: "Gold Plate", desc: "A gold plate by the columns; a gold mix." },
        { key: "C", name: "Gold Core", desc: "A gold core ring on the still and a gold disc; a gold mix." } ] },
    ] },
    { name: "Speed", theme: "valves, pumps and finally a second nozzle: a faster spray and a longer soak", steps: [
      { name: "Quick Valve", cost: 100, effect: "A spray every 1.25 s", options: [
        { key: "A", name: "Valve Wheel", desc: "A red valve wheel on the still that spins when it sprays." },
        { key: "B", name: "Pressure Gauge", desc: "A pressure gauge on the still whose needle drops as it sprays." },
        { key: "C", name: "Hose Coil", desc: "A hose coil round the still." } ] },
      { name: "Long-Lasting Mix", cost: 140, effect: "The soak lasts 5 s", options: [
        { key: "A", name: "Mixing Drum", desc: "A mixing drum on the still with stirring blades." },
        { key: "B", name: "Reserve Block", desc: "A reserve block with a glowing lamp on the still." },
        { key: "C", name: "Stabiliser Rings", desc: "Stabiliser rings round the still." } ] },
      { name: "Twin Valves", cost: 990, effect: "A spray every second; the soak lasts 6 s (primary)", options: [
        { key: "A", name: "Valve Studs", desc: "A valve stud on every column." },
        { key: "B", name: "Manifold", desc: "A manifold bar across the nozzle pipe." },
        { key: "C", name: "Booster Pipes", desc: "Two booster pipes alongside the nozzle pipe." } ] },
      { name: "High-Flow Pump", cost: 1470, effect: "A spray every 0.83 s", options: [
        { key: "A", name: "Pump Housing", desc: "A pump housing with a piston that thumps with each spray." },
        { key: "B", name: "Big Pipe", desc: "A fat feed pipe beside the nozzle." },
        { key: "C", name: "Flow Meter", desc: "A flow meter whose needle moves with each spray." } ] },
      { name: "Twin Nozzles", cost: 7760, effect: "Sprays two enemies at once; the soak lasts 7 s (mastery)", options: [
        { key: "A", name: "Parallel Nozzles", desc: "Two gold gooseneck nozzles side by side; they spray two enemies at once." },
        { key: "B", name: "Fanned Nozzles", desc: "Two gold nozzles fanned apart; two enemies at once." },
        { key: "C", name: "Forked Nozzle", desc: "One gold pipe that forks into two nozzles; two enemies at once." } ] },
    ] },
    { name: "Slowing", theme: "gel that coats soaked enemies thicker and thicker", steps: [
      { name: "Sticky Gel", cost: 250, effect: "Soaked enemies are slowed 15%", options: [
        { key: "A", name: "Gel Blob", desc: "A gel blob on a column; soaked enemies get a thin coat of gel." },
        { key: "B", name: "Gel Hose", desc: "A pale gel hose; soaked enemies get a thin gel coat." },
        { key: "C", name: "Gel Cartridges", desc: "A rack of gel cartridges; a thin gel coat on soaked enemies." } ] },
      { name: "Thick Gel", cost: 335, effect: "25%", options: [
        { key: "A", name: "Gel Pipes", desc: "Two thicker gel pipes; a thicker coat." },
        { key: "B", name: "Gel Pump", desc: "A gel pump with a glowing lamp; a thicker coat." },
        { key: "C", name: "Gel Tank", desc: "A gel tank; a thicker coat." } ] },
      { name: "Glue", cost: 665, effect: "35% (primary)", options: [
        { key: "A", name: "Glue Cauldron", desc: "A glue cauldron; a still thicker coat that drips slowly." },
        { key: "B", name: "Glue Drum", desc: "A glue drum with a spout ring; a thick drippy coat." },
        { key: "C", name: "Glue Spout", desc: "A glue spout; a thick drippy coat." } ] },
      { name: "Setting Glue", cost: 1335, effect: "45%", options: [
        { key: "A", name: "Curing Lamp", desc: "A cool blue curing lamp on a stalk; the coat is thicker and sets." },
        { key: "B", name: "Curing Rack", desc: "A rack with a blue curing lamp; a thicker, setting coat." },
        { key: "C", name: "Cooling Fan", desc: "A spinning cooling fan; a thicker, setting coat." } ] },
      { name: "Quick-Set Foam", cost: 2665, effect: "55%: nearly frozen (mastery)", options: [
        { key: "A", name: "Gold Foam Cone", desc: "A gold foam cone; the thickest, nearly frozen coat." },
        { key: "B", name: "Gold Foam Tank", desc: "A gold foam tank; the thickest coat." },
        { key: "C", name: "Gold Foam Generator", desc: "A gold foam generator disc; the thickest coat." } ] },
    ] },
  ],
  retrofits: [
    { name: "Pressure Pump", cost: 150, effect: "A spray every 1.33 s, and +20 range (150) (stacks with the Speed path)", options: [
      { key: "A", name: "Gauge Heads", desc: "Two pressure gauges on the spray head." },
      { key: "B", name: "Pump Block", desc: "A pump block with three glowing ports on the spray pipe." },
      { key: "C", name: "Pressure Coil", desc: "Four steel pressure coils round the spray pipe." } ] },
    { name: "Mist Nozzle", cost: 300, effect: "Each spray also soaks one more enemy next to the target (stacks with Twin Nozzles)", options: [
      { key: "A", name: "Side Mist Nozzles", desc: "Two small mist nozzles beside the spray pipe; each spray also mists a neighbour." },
      { key: "B", name: "Wide Mist Head", desc: "A wide misting fan on the nozzle; each spray also mists a neighbour." },
      { key: "C", name: "Mist Ring", desc: "A ring on the nozzle tip; each spray also mists a neighbour." } ] },
    { name: "Bigger Tanks", cost: 60, effect: "Soaks last 5 s (stacks with Long-Lasting Mix)", options: [
      { key: "A", name: "Larger Columns", desc: "Bigger columns." },
      { key: "B", name: "Extra Tank", desc: "An extra tank on the deck." },
      { key: "C", name: "Tank Bands", desc: "Steel bands round the columns." } ] },
  ],
};
const TANKC = [0.3, 0.5, 0.2, 1];
P2.picks = {};
