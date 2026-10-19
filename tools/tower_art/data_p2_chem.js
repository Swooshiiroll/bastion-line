// ---- Tower art second pass: Chemical Plant (tower 12), round 1 ----------------------------------------------------
// Base: look F Distillery Columns, animation A Acid Stream. One parametric model with the lessons so far: options swap parts
// rather than lay overlays over them; the projectile (the spray) changes with every Acid step; masteries are gold; the plant's
// own clock drives the timing. All three Retrofits overlap a path step and are kept, their stats stacking (the carpet rule):
// Pressure Pump adds to the Speed path's spray rate, Mist Nozzle to Twin Nozzles, Bigger Tanks to the soak length.
// Geometry (game px): three columns at radius 10 round a central still (r 5) with a gooseneck nozzle that turns to spray; the
// plant sprays one unsoaked enemy at a time; a soaked enemy drips and fizzes until the soak wears off.
const PAGE = { title: "Chemical Plant: paths and Retrofits (second pass)", store: "bl-tower-art-p2-chem-r2" };
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
    const G1 = Kp(B, 2, 0), G2 = Kp(B, 2, 1), G3 = Kp(B, 2, 2), G4 = Kp(B, 2, 3), GM = Kp(B, 2, 4), R = B.r >= 0 ? B.key("r" + B.r) : null;
    deck(c, k, col, t);
    // ---- Structure first: the columns, the pipes, the still (the upgrades rebuild these rather than add little parts) ----------------------
    const bigCol = V2 === "A" || (B.r === 2 && R === "A") || (B.r === 2 && R === "C");
    const colR = bigCol ? 4.9 : 4, angs = [-Math.PI / 2, Math.PI / 6, 5 * Math.PI / 6];
    if (V2 === "B" || (B.r === 2 && R === "B")) angs.push(Math.PI / 2);                               // a fourth column
    const pw = V1 === "B" ? 2.8 : V4 === "C" ? 3 : 1.4;                                                  // feed pipe thickness
    const gelA = G1 === "A" ? [1] : [], gelB = G2 === "A" ? [2] : [], gelCols = [...gelA, ...gelB];
    const gelMain = G1 === "B" || G2 === "C";
    if (V2 === "C" || V4 === "B") ring(c, 10 * k, METAL, 1.8 * k);                                       // a ring main round the columns
    if (V4 === "B") ring(c, 12.6 * k, METAL, 1.6 * k);                                                    // and a second, outer one
    if (gelMain) { ring(c, 12.6 * k, GELC, (G2 === "C" ? 2.6 : 1.6) * k); for (let i = 0; i < 3; i++) line(add(c, mul(fa(i * TAU / 3 + 0.5), 10 * k)), add(c, mul(fa(i * TAU / 3 + 0.5), 12.6 * k)), GELC, 1.2 * k); }
    if (V3 === "C") { ring(c, 7.4 * k, METAL_L, 1.6 * k); for (const a of angs) line(add(c, mul(fa(a), 7.4 * k)), add(c, mul(fa(a), 10 * k)), METAL_L, 1.4 * k); }  // a valve manifold ring with a spoke to each column
    if (V4 === "C") for (let i = 0; i < angs.length; i++) line(add(c, mul(fa(angs[i]), 10 * k)), add(c, mul(fa(angs[(i + 1) % angs.length]), 10 * k)), METAL, pw * k); // a pipe network linking the columns
    angs.forEach((a, i) => { const q = add(c, mul(fa(a), 10 * k)), isGel = gelCols.includes(i), body = isGel ? mix(METAL_L, GELC, 0.35) : METAL_L, glow = isGel ? GELC : ac;
      bar(c, q, pw * k, METAL); orb(q, colR * k, body); ring(q, (colR - 1.2) * k, METAL, 0.8 * k); glowDot(q, 0.9 * k, A(glow, 0.5 + 0.5 * Math.sin(t * 2 + i)));
      if (B.r === 2 && R === "C") { orb(add(q, [0, -1.6 * k]), (colR - 0.8) * k, body); ring(add(q, [0, -1.6 * k]), (colR - 2) * k, METAL, 0.8 * k); }      // double-height columns
      if (V2 === "A") ring(q, (colR - 0.3) * k, STEEL, 1 * k);
      if (isGel && G1 === "A") arc(q, (colR - 0.6) * k, Math.PI * 1.1, Math.PI * 1.9, A(GELC, 0.9), 1.4 * k);
      if (A1 === "B" && i === 0) plate(add(q, [0, -colR * k - 1.6 * k]), rectPts(2.6, 1.2), METAL_D, 0, k, 0.9);
      if (A2 === "C") ring(q, (colR - 2.2) * k, A(ac, 0.7), 1.2 * k);
      if (AM === "A") ring(q, colR * k, GOLD, 1 * k); });
    // Slowing: the glue structures replace the third column's look
    const q3 = add(c, mul(fa(5 * Math.PI / 6), 10 * k));
    if (G3 === "A") { disc(q3, 6.2 * k, OUTLINE); disc(q3, 5.6 * k, [0.4, 0.34, 0.2, 1]); disc(q3, 3.4 * k, A(GELC, 0.6)); glowDot(q3, 1 * k, GELC); }
    if (G3 === "B") { orb(q3, 5.4 * k, [0.45, 0.4, 0.22, 1]); for (const rr of [4.2, 2.8]) ring(q3, rr * k, METAL, 0.9 * k); glowDot(q3, 1 * k, GELC); }
    if (G3 === "C") { disc(add(q3, [0, 2 * k]), 4.2 * k, OUTLINE); disc(add(q3, [0, 2 * k]), 3.7 * k, dk(GELC, 0.4)); orb(add(q3, [0, -1.4 * k]), 3.8 * k, [0.45, 0.4, 0.22, 1]); }
    if (G4 === "B") { const ct = S(0, 12.6); disc(ct, 5.6 * k, OUTLINE); disc(ct, 5 * k, lt(METAL_L, 0.1)); disc(ct, 3.2 * k, dk([0.5, 0.8, 1, 1], 0.5)); for (let i = 0; i < 3; i++) { const v = fmod(t * 0.5 + i / 3, 1); disc(add(ct, [v * 2 * k, -v * 6 * k]), (1.6 + v * 2.4) * k, A([0.85, 0.95, 1, 1], 0.25 * (1 - v))); } }
    // ---- The still: bigger (Quick Valve A), twin stills (Twin Valves B), a pump hall (High-Flow A), or the Pressure Pump's skid ----------------------
    if (B.r === 0 && R === "C") { plate(c, rectPts(7, 5), METAL_D, aim, k, 1); for (const y of [-3, 3]) bar(D(-3, y), D(3, y), 2.4 * k, METAL_L); }
    if (V3 === "B") { for (const y of [-3.4, 3.4]) { orb(D(0, y), 4 * k, mix(METAL_L, ac, 0.15)); ring(D(0, y), 2.6 * k, METAL, 0.8 * k); } bar(D(0, -3.4), D(0, 3.4), 1.6 * k, METAL); }
    else if (V4 === "A") { plate(c, rectPts(6.4, 6.4), METAL_L, aim, k, 1.2); rivets(c, rectPts(6.4, 6.4), aim, k, 0.8, 0.7 * k); const pr = fl > 0.2 ? -0.8 : 0.6; bar(D(2 + pr, 0), D(7, 0), 1.6 * k, STEEL); plate(D(2 + pr, 0), rectPts(0.8, 2.4), METAL_D, aim, k, 0.9); }
    else { const rs = V1 === "A" ? 6.2 : 5; orb(c, rs * k, mix(METAL_L, ac, 0.15)); if (V1 === "A") ring(c, 5 * k, METAL, 1.2 * k); }
    if (B.r === 0 && R === "B") { orb(c, 3.8 * k, METAL_L); ring(c, 3.8 * k, OUTLINE, 1 * k); ring(c, 2.4 * k, METAL, 0.9 * k); }                          // a raised pump tower
    if (B.r === 0 && R === "A") { plate(D(0, 7.8), rectPts(4.4, 2.6), METAL_L, aim, k, 1.1); bar(D(0, 5.2), D(0, 7.8), 1.4 * k, METAL); plate(D(-1.4 + (fl > 0.2 ? 0.8 : 0), 7.8), rectPts(0.7, 1.8), METAL_D, aim, k, 0.9); } // a pump house beside the still
    // ---- Fixed kit that the picked Acid options keep ------------------------------------------------------------------------------------
    if (A3 === "C") for (let i = 0; i < 3; i++) glowDot(S(3 + i * 2, 13), 0.5 * k, A(ac, 0.4 + 0.5 * Math.sin(t * 4 + i)));
    if (A4 === "A") { bar(S(-5, 12.5), S(-1, 12.5), 1.6 * k, METAL); orb(S(-5.8, 12.5), 1.4 * k, METAL_L); }
    if (AM === "B") plate(S(12.5, 5), rectPts(2.4, 2.4), GOLD, 0, k, 1);
    // ---- The nozzle (it turns to the target) ------------------------------------------------------------------------------------------
    const neck = V1 === "C" ? 3.6 : 2.4;
    if (V3 === "A") { for (const y of [-1.6, 1.6]) bar(D(2, y), D(9, y), 1.4 * k, METAL); bar(D(9, -1.6), D(11, 0), 1.4 * k, METAL); bar(D(9, 1.6), D(11, 0), 1.4 * k, METAL); bar(D(11, 0), D(13, 0), 1.8 * k, METAL); }
    else bar(c, D(6, 0), neck * k, METAL);
    const nozzle = (y, gc, w) => { bar(D(6, y), D(13, y), (w || 1.6) * k, gc ? GOLD : METAL); glowDot(D(13.4, y), (0.7 + 1.4 * fl) * k, A(ac, 0.5 + 0.5 * fl)); };
    if (VM === "A") { nozzle(-1.8, true); nozzle(1.8, true); }
    else if (VM === "B") { for (const sg of [-1, 1]) { const dd = (x, y) => P(c, aim + sg * 0.22, k, x, y); bar(dd(6, 0), dd(13, 0), 1.5 * k, GOLD); glowDot(dd(13.4, 0), (0.7 + 1.4 * fl) * k, A(ac, 0.5 + 0.5 * fl)); } }
    else if (VM === "C") { bar(D(6, 0), D(9, 0), 2 * k, GOLD); for (const sg of [-1, 1]) { bar(D(9, 0), D(13, sg * 2.6), 1.4 * k, GOLD); glowDot(D(13.4, sg * 2.8), (0.7 + 1.4 * fl) * k, A(ac, 0.5 + 0.5 * fl)); } }
    else if (GM === "B") { bar(D(6, 0), D(10, 0), 2 * k, GOLD); fill(D(10, 0), [[0, -1], [4, -3.2], [4, 3.2], [0, 1]], GOLD, aim, k); glowDot(D(14, 0), (0.7 + 1.4 * fl) * k, A(ac, 0.5 + 0.5 * fl)); }
    else if (B.r === 1 && R === "B") { bar(D(6, 0), D(10, 0), 1.8 * k, METAL); for (const sg of [-1, 0, 1]) { bar(D(10, 0), D(13, sg * 2.4), 1.2 * k, METAL); glowDot(D(13.4, sg * 2.6), (0.5 + 1 * fl) * k, A(ac, 0.5 + 0.5 * fl)); } }
    else nozzle(0, false);
    if (B.r === 1 && R === "A") fill(D(13, 0), [[0, 0], [3.4, -3.4], [3.4, 3.4]], A(METAL_L, 0.9), aim, k);                                   // the nozzle opens into a wide fan head
    if (B.r === 1 && R === "C") { ring(D(13, 0), 2.4 * k, METAL_L, 1.6 * k); ring(D(13, 0), 1.2 * k, METAL, 1 * k); }                         // a big ring head
    // ---- Slowing structures over the plant ------------------------------------------------------------------------------------------------
    if (G2 === "B") { disc(c, 7.2 * k, A(GELC, 0.16)); ring(c, 7.2 * k, A(GELC, 0.8), 1.2 * k); }                                                 // a gel dome over the still
    if (G4 === "A") { arc(D(6, 0), 4.6 * k, aim - 1.3, aim + 1.3, METAL_L, 2.2 * k); glowDot(D(6, -4), 0.6 * k, [0.5, 0.8, 1, 1]); glowDot(D(6, 4), 0.6 * k, [0.5, 0.8, 1, 1]); } // a curing hood over the nozzle
    if (G4 === "C") { ring(c, 7.4 * k, [0.5, 0.8, 1, 1], 2 * k); for (let i = 0; i < 12; i++) { const a = i * TAU / 12 + t * 0.3; line(add(c, mul(fa(a), 6.6 * k)), add(c, mul(fa(a), 8.2 * k)), A([0.85, 0.95, 1, 1], 0.7), 0.7 * k); } } // a cooling coil round the still
    if (GM === "A") { disc(c, 7.6 * k, A(GOLD, 0.14)); ring(c, 7.6 * k, GOLD, 1.4 * k); ring(c, 6.2 * k, A(GOLD, 0.6), 0.8 * k); }                      // a gold foam dome
    if (GM === "C") { orb(q3, 5.4 * k, GOLD); ring(q3, 4 * k, METAL, 0.9 * k); }                                                                   // a gold foam silo
    glowDot(c, 1.1 * k, ac);
    if (AM === "A" || AM === "C") ring(c, 5 * k, GOLD, 1 * k);
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
        { key: "C", name: "Gold Core", desc: "A gold core ring on the still; a gold mix." } ] },
    ] },
    { name: "Speed", theme: "valves, pumps and finally a second nozzle: a faster spray and a longer soak", steps: [
      { name: "Quick Valve", cost: 100, effect: "A spray every 1.25 s", options: [
        { key: "A", name: "Big Still", desc: "The central still is rebuilt bigger, with a thick pressure rim." },
        { key: "B", name: "Direct Feed", desc: "The pipes from the columns are rebuilt thick and straight into the still." },
        { key: "C", name: "Wide Neck", desc: "The nozzle pipe is rebuilt as a short, wide neck." } ] },
      { name: "Long-Lasting Mix", cost: 140, effect: "The soak lasts 5 s", options: [
        { key: "A", name: "Taller Columns", desc: "All the columns are rebuilt bigger and banded." },
        { key: "B", name: "Fourth Column", desc: "A fourth column is built onto the plant." },
        { key: "C", name: "Ring Main", desc: "A ring pipe is built round all the columns." } ] },
      { name: "Twin Valves", cost: 990, effect: "A spray every second; the soak lasts 6 s (primary)", options: [
        { key: "A", name: "Split Feed", desc: "The nozzle pipe is rebuilt as a twin pipe that joins into the nozzle head." },
        { key: "B", name: "Twin Stills", desc: "The single still is rebuilt as two linked stills." },
        { key: "C", name: "Valve Manifold", desc: "A manifold ring with a spoke to every column is built round the still." } ] },
      { name: "High-Flow Pump", cost: 1470, effect: "A spray every 0.83 s", options: [
        { key: "A", name: "Pump Hall", desc: "The still is replaced by a big square pump hall with a piston that thumps with each spray." },
        { key: "B", name: "Double Ring Main", desc: "A second, outer ring main is built round the plant." },
        { key: "C", name: "Pipe Network", desc: "Thick pipes are built linking every column to the next." } ] },
      { name: "Twin Nozzles", cost: 7760, effect: "Sprays two enemies at once; the soak lasts 7 s (mastery)", options: [
        { key: "A", name: "Parallel Nozzles", desc: "Two gold gooseneck nozzles side by side; they spray two enemies at once." },
        { key: "B", name: "Fanned Nozzles", desc: "Two gold nozzles fanned apart; two enemies at once." },
        { key: "C", name: "Forked Nozzle", desc: "One gold pipe that forks into two nozzles; two enemies at once." } ] },
    ] },
    { name: "Slowing", theme: "gel that coats soaked enemies thicker and thicker", steps: [
      { name: "Sticky Gel", cost: 250, effect: "Soaked enemies are slowed 15%", options: [
        { key: "A", name: "Gel Column", desc: "One column is rebuilt as a gel column: tinted, with a gel cap." },
        { key: "B", name: "Gel Ring Main", desc: "A gel ring main is built round the plant with feeds to the columns." },
        { key: "C", name: "Gel Annex", desc: "A gel annex is built on." } ] },
      { name: "Thick Gel", cost: 335, effect: "25%", options: [
        { key: "A", name: "Second Gel Column", desc: "A second column is rebuilt as a gel column." },
        { key: "B", name: "Gel Dome", desc: "A gel dome is built over the still." },
        { key: "C", name: "Wide Gel Main", desc: "The gel ring main is rebuilt as a wide main." } ] },
      { name: "Glue", cost: 665, effect: "35% (primary)", options: [
        { key: "A", name: "Glue Cauldron Hall", desc: "One column is replaced by a big glue cauldron hall." },
        { key: "B", name: "Glue Tower", desc: "One column is replaced by a taller banded glue tower." },
        { key: "C", name: "Glue Stack", desc: "One column is replaced by a stack of a glue tank and a tower." } ] },
      { name: "Setting Glue", cost: 1335, effect: "45%", options: [
        { key: "A", name: "Curing Hood", desc: "A curing hood is built over the nozzle." },
        { key: "B", name: "Cooling Tower", desc: "A cooling tower is built onto the deck." },
        { key: "C", name: "Cooling Coil", desc: "A cooling coil is built round the still." } ] },
      { name: "Quick-Set Foam", cost: 2665, effect: "55%: nearly frozen (mastery)", options: [
        { key: "A", name: "Gold Foam Dome", desc: "A gold foam dome is built over the still." },
        { key: "B", name: "Gold Foam Cannon", desc: "The nozzle is rebuilt as a wide gold foam cannon." },
        { key: "C", name: "Gold Foam Silo", desc: "One column is replaced by a gold foam silo." } ] },
    ] },
  ],
  retrofits: [
    { name: "Pressure Pump", cost: 150, effect: "A spray every 1.33 s, and +20 range (150) (stacks with the Speed path)", options: [
        { key: "A", name: "Pump House", desc: "A pump house is built beside the still." },
        { key: "B", name: "Pump Tower", desc: "A raised pump tower is built on the still." },
        { key: "C", name: "Pump Skid", desc: "The still is rebuilt on a pump skid with two cylinders." } ] },
    { name: "Mist Nozzle", cost: 300, effect: "Each spray also soaks one more enemy next to the target (stacks with Twin Nozzles)", options: [
        { key: "A", name: "Fan Head", desc: "The nozzle opens into a wide fan head." },
        { key: "B", name: "Mist Manifold", desc: "The nozzle is rebuilt as a three-spout mist manifold." },
        { key: "C", name: "Mist Ring Head", desc: "The nozzle tip is rebuilt as a big ring head." } ] },
    { name: "Bigger Tanks", cost: 60, effect: "Soaks last 5 s (stacks with Long-Lasting Mix)", options: [
        { key: "A", name: "Larger Columns", desc: "All the columns are rebuilt bigger." },
        { key: "B", name: "Fourth Tank", desc: "A fourth column is built onto the plant." },
        { key: "C", name: "Double-Height Columns", desc: "Every column is rebuilt double height." } ] },
  ],
};
const TANKC = [0.3, 0.5, 0.2, 1];
// ---- Round 2 (owner's picks and notes, 2026-10-19): picked Acid stages show only the pick; Speed, Slowing and the Retrofits are redesigned
// so they rebuild the plant's structure rather than add small parts.
P2.intro = "Round 2: your Acid picks drawn (the gold dot beside the columns is gone), and Speed, Slowing and the three Retrofits redesigned: they now rebuild the plant's structure (bigger stills and columns, a fourth column, ring mains, twin stills, a pump hall, glue towers, domes and cooling towers) instead of adding small parts here and there. Use the build preview to check combinations.";
P2.picks = { p0s0: "B", p0s1: "C", p0s2: "C", p0s3: "A", p0s4: "C" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { const pk = P2.picks["p" + pi + "s" + k]; if (pk) st.options = st.options.filter((o) => o.key === pk); }));
