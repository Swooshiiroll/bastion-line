// ---- Tower art second pass: Mine Layer (tower 11), round 1 ------------------------------------------------------
// Base: look F Rail Launcher, animation C Confetti Charge. One parametric model with the lessons so far: options swap
// parts rather than lay overlays over them; the mine itself changes at every Power step (it is the projectile); masteries
// are gold; the timing comes from the agent's own clock. All three Retrofits overlap a path step and are kept, their stats
// stacking (the carpet rule): Conveyor Feed adds to Quick Assembly, Shaped Charges to Heavier Charge, Long Arm to Longer Arm.
// Geometry (game px): a round mount r 10 with a magazine of canisters behind it and two rails ahead (x -2 to 15); a mine
// is a squat canister (r 3.6) with a glowing band that blinks while it waits on the track.
const PAGE = { title: "Mine Layer: paths and Retrofits (second pass)", store: "bl-tower-art-p2-mines-r1" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], RED = [0.85, 0.2, 0.18, 1], YEL = [1, 0.85, 0.2, 1], ORANGE = [1, 0.55, 0.2, 1];
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null);
const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);

// ---- Stats the look follows: toss gap, cap shown, blast, range -----------------------------------------------------------
const GAP = [1.5, 1.33, 1.2, 0.95, 0.85, 0.7];                                      // seconds per mine by Production level
const gapOf = (B) => Math.max(0.4, GAP[B.lv[1]] - (B.r === 0 ? 0.17 : 0));         // Conveyor Feed stacks
const capOf = (B) => [6, 7, 8, 9, 10, 12][B.lv[1]] + (B.r === 0 ? 1 : 0);          // the preview's cap (the game's is 20 to 45)
const BLAST = [40, 40, 50, 50, 60, 65];                                            // blast px by Power level
const RANGE = [120, 140, 160, 190, 220, 260];
const railExt = (B) => [0, 2, 4, 7, 10, 14][B.lv[2]] + (B.r === 2 ? 3 : 0);

// ---- The mine: a canister whose look follows the Power steps and the Shaped Charges Retrofit -----------------------------
function drawMine(B, p, k, t, col, blink, mini) {
  const P1 = Kp(B, 0, 0), P3 = Kp(B, 0, 2), P4 = Kp(B, 0, 3), PM = Kp(B, 0, 4), z = (P1 ? 1.12 : 1) * (PM ? 1.25 : 1) * (mini ? 0.55 : 1), r = 3.6 * k * z;
  ellipse(add(p, [k * 0.8, k * 1.6]), 4 * k * z, 1.8 * k * z, [0, 0, 0, 0.3]);
  disc(p, r, OUTLINE); disc(p, r * 0.86, P3 ? [0.2, 0.2, 0.22, 1] : METAL_L);
  if (PM) { ring(p, r * 0.95, GOLD, 1 * k); ring(p, r * 0.55, GOLD, 0.7 * k); }
  if (P3) ring(p, r * 0.62, YEL, 0.9 * k * z);
  if (P4) for (let i = 0; i < 6; i++) line(add(p, mul(fa(i * TAU / 6), r * 0.25)), add(p, mul(fa(i * TAU / 6), r * 0.85)), [0, 0, 0, 0.5], 0.5 * k);
  if (B.r === 1) { const ky = B.key("r1"); if (ky === "A") plate(add(p, [r * 0.15, -r * 0.1]), rectPts(0.9, 1.3), STEEL, 0, k * z, 0.7); if (ky === "C") fill(add(p, [0, -r * 0.1]), [[1.4, 0], [-0.8, 1.1], [-0.8, -1.1]], STEEL, -Math.PI / 2, k * z); if (ky === "B") ring(p, r * 0.35, STEEL, 0.8 * k); }
  ring(p, r * 0.6, A(PM ? GOLD : col, blink ? 1 : 0.5), 0.9 * k * z); disc(p, r * 0.3, METAL);
  if (blink) glowDot(p, 1.2 * k * z, A(PM ? GOLD : col, 1)); }

// ---- The agent: tosses mines onto random spots along the track in range; they arm, blink and go off under a ground enemy ----
function mineAgent(B) { return (m, t, info, s, col) => { const k = G(s), laneY = info.H * 0.8, cap = capOf(B), gap = gapOf(B), PM = Kp(B, 0, 4), P2 = Kp(B, 0, 1), P4 = Kp(B, 0, 3), blastPx = BLAST[B.lv[0]];
  if (!m.mines) { m.mines = []; m.lastToss = t - 1; m.n = 0; }
  const R = (RANGE[B.lv[2]] + (B.r === 2 ? 20 : 0)) / 48 * s * 0.55;
  const pick = () => { const x = Math.max(s * 0.25, Math.min(info.W - s * 0.25, info.c[0] + (rnd2(m.n * 3.7 + 1.1) * 2 - 1) * R + R * 0.4)); return [x, laneY + (rnd2(m.n * 5.3 + 2.7) - 0.5) * s * 0.3]; };
  if (!m.next) m.next = pick(); m.aimAt = m.next;
  if (t - m.lastToss >= gap && m.mines.filter((q) => !q.boom).length < cap) { m.n++; m.mines.push({ to: m.next, t0: t, from: add(info.c, mul(fa(info.aim), s * 0.3)), n: m.n }); m.lastToss = t; m.next = pick(); }
  for (const q of m.mines) { const age = t - q.t0;
    if (q.boom) { const v = (t - q.boom) / 0.6, size = 0.3 * blastPx / 40;
      blast(q.to, v, s, PM ? GOLD : col, size); if (P2) ring(q.to, s * size * (0.8 + v), A(PM ? GOLD : col, 0.5 * (1 - v)), 1);
      const cs = PM ? [GOLD, [1, 0.9, 0.5, 1], [1, 0.7, 0.2, 1]] : [[1, 0.3, 0.35, 1], [0.3, 0.9, 1, 1], [1, 0.85, 0.3, 1], [0.6, 1, 0.4, 1], [1, 0.45, 0.85, 1]];
      for (let i = 0; i < 16 + (P4 ? 8 : 0); i++) { const d = fa(rnd2(q.n * 13 + i) * TAU), c0 = cs[i % cs.length], p2 = add(add(q.to, mul(d, s * (0.2 + 0.9 * rnd2(i + q.n)) * v * blastPx / 40)), [0, v * v * s * 0.3]); fill(p2, rectPts(1.6, 0.8), A(c0, 1 - v), v * 12 + i, 1); }
      continue; }
    if (age < 0.6) { const u = age / 0.6; drawMine(B, add(lerp(q.from, q.to, u), [0, -Math.sin(Math.PI * u) * s * 0.6]), k * 0.85, t, col, false); continue; }
    if (age < 0.9) ring(q.to, s * 0.2 * ((age - 0.6) / 0.3), [1, 1, 1, 0.5 * (1 - (age - 0.6) / 0.3)], 1);
    drawMine(B, q.to, k, t, col, fmod(t * 1.6 + q.n * 0.37, 1) < 0.25);
    for (const e of info.ens) if (dist(e.p, q.to) < s * 0.15) { q.boom = t; break; } }
  m.mines = m.mines.filter((q) => !q.boom || t - q.boom < 0.6); }; }

// ---- The model: a round mount, the magazine behind it, the rails ahead; every option is a swap on those -----------------
const P2 = {
  tower: "mines", look: "F", anim: "C",
  intro: "Round 1: three options for every step and the Retrofit, drawn as one model so the paths combine. Power changes the mine itself (a bigger canister, a wider blast, a dark yellow-banded HE mine, a segmented casing, a gold anti-tank mine) as well as the parts on the launcher; Production grows the magazine and adds presses and belts, so mines come faster and more stay out; Range lengthens the rails and adds launch gear. The three Retrofits overlap a path step and are kept (the carpet rule), their stats stacking. Unpicked steps show option A.",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: mineAgent(B) }; },
  muzzleAt(B, m, kk, c) { return c; },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), mm = fx.mem || {}, since = t - (mm.lastToss ?? -9), fl = decay(since, 0.2), L = 15 + railExt(B), D = (x, y) => P(c, aim, k, x, y);
    const P1 = Kp(B, 0, 0), P2s = Kp(B, 0, 1), P3 = Kp(B, 0, 2), P4 = Kp(B, 0, 3), PM = Kp(B, 0, 4), S1 = Kp(B, 1, 0), S2 = Kp(B, 1, 1), S3 = Kp(B, 1, 2), S4 = Kp(B, 1, 3), SM = Kp(B, 1, 4);
    const R1 = Kp(B, 2, 0), R2 = Kp(B, 2, 1), R3 = Kp(B, 2, 2), R4 = Kp(B, 2, 3), RM = Kp(B, 2, 4), RT = B.r >= 0 ? B.key("r" + B.r) : null;
    deck(c, k, col, t);
    const S = (x, y) => add(c, [x * k, y * k]); // fixed deck positions (belts and presses don't turn)
    // -- Fixed kit: Production's belts, presses and chutes -----------------------------------------------------------------
    if (S1 === "A") { plate(S(-11, 8), rectPts(2.6, 2.2), METAL_D, 0, k, 1); const dn = fmod(t * 1.2, 1) < 0.2; plate(S(-11, dn ? 8.6 : 7.6), rectPts(1.6, 1), dn ? METAL : METAL_L, 0, k, 0.9); }
    if (S1 === "B") { bar(S(-12, 7), S(-8, 4), 2 * k, METAL); plate(S(-12.6, 7.4), rectPts(1.6, 1.4), METAL_D, 0, k, 0.9); }
    if (S1 === "C") for (let i = 0; i < 3; i++) glowDot(S(-12 + i * 2.2, 9.4), 0.5 * k, fmod(t * 2 + i * 0.3, 1) < 0.5 ? [0.4, 1, 0.5, 1] : [0.2, 0.4, 0.28, 1]);
    if (S2 === "A") for (const x of [-11, -6]) { const dn = fmod(t * 0.9 + x * 0.05, 1) < 0.25; plate(S(x, -9), rectPts(2, 1.6), dn ? METAL : METAL_L, 0, k, 1); }
    if (S2 === "B") for (const y of [-9.4, -7.2]) bar(S(-13, y), S(-9, y + 1.2), 1.4 * k, METAL);
    if (S2 === "C") for (const x of [-11, -7]) { bar(S(x, -10), S(x, -7.4 - (fmod(t * 1.1, 1) < 0.3 ? 0.8 : 0)), 1 * k, STEEL); disc(S(x, -10.4), 0.9 * k, METAL_D); }
    if (S3 === "A" || SM === "A") { const bc = SM === "A" ? GOLD : METAL_D; plate(S(-4, 11.6), rectPts(11, 1.8), bc, 0, k, 1); for (let i = 0; i < 4; i++) drawMine(B, S(-12 + fmod(t * 4, 5) + i * 5, 11.6), k * 0.5, t, col, false, true); }
    if (S3 === "B") { plate(S(-4, 11.6), rectPts(9, 1.4), METAL_D, 0, k, 1); for (const x of [-9, -3, 3]) bar(S(x, 9.4), S(x, 13.8), 1.2 * k, METAL_L); }
    if (S3 === "C") { plate(S(-4, 11.6), rectPts(9, 1.6), METAL_D, 0, k, 1); for (let i = 0; i < 5; i++) disc(S(-10 + i * 3, 11.6), 0.9 * k, STEEL); }
    if (S4 === "A") { for (const x of [-12, 4]) { plate(S(x, 14.2), rectPts(1.4, 0.9), METAL_D, 0, k, 0.9); glowDot(S(x, 14.2), 0.4 * k, ORANGE); } }
    if (S4 === "B") plate(S(-4, 14.6), rectPts(9, 1), METAL_D, 0, k, 1);
    if (S4 === "C") for (let i = 0; i < 4; i++) glowDot(S(-10 + i * 3.6, 14.4), 0.4 * k, A(ORANGE, 0.4 + 0.5 * Math.sin(t * 6 + i)));
    if (SM === "B") for (const x of [-11, -6]) plate(S(x, -9), rectPts(2.2, 1.8), GOLD, 0, k, 1);
    if (SM === "C") { plate(S(-13, 6), rectPts(2.4, 2.4), GOLD, 0, k, 1); }
    if (B.r === 0) { const ky = B.key("r0"); if (ky === "A") { plate(S(-4, -11.4), rectPts(11, 1.5), METAL_D, 0, k, 1); for (let i = 0; i < 4; i++) drawMine(B, S(-12 + fmod(t * 5, 5) + i * 5, -11.4), k * 0.5, t, col, false, true); }
      if (ky === "B") { plate(S(-12, -11), rectPts(3, 2.4), METAL_D, 0, k, 1); bar(S(-10, -9.6), S(-7, -7), 1.6 * k, METAL); }
      if (ky === "C") { ring(S(-4, -11), 5 * k, METAL_L, 1.4 * k); for (let i = 0; i < 4; i++) drawMine(B, add(S(-4, -11), mul(fa(t * 1.4 + i * TAU / 4), 5 * k)), k * 0.45, t, col, false, true); } }
    // -- The mount and the magazine (a stack of canisters behind it; one more column with each Production step) ---------------
    disc(c, 10 * k, OUTLINE); disc(c, 9.2 * k, PM === "C" ? mix(METAL, GOLD, 0.3) : METAL); if (P1 === "A") for (const rr of [9.6, 7.6]) ring(c, rr * k, METAL_L, 0.9 * k); if (PM === "C") ring(c, 9.4 * k, GOLD, 1.2 * k);
    const cols = 1 + (B.lv[1] >= 3 ? 1 : 0) + (B.lv[1] >= 5 ? 1 : 0);
    for (let cl = 0; cl < cols; cl++) for (let i = 0; i < 3; i++) { const q = D(-6 - cl * 3, (i - 1) * 4.2), mine = { lv: B.lv, r: B.r, key: B.key }; drawMine(B, q, k * 0.55, t, col, false, true);
      if (P3 === "A") ring(q, 1.5 * k, YEL, 0.6 * k); if (P4 === "A") for (let j = 0; j < 3; j++) line(add(q, mul(fa(j * 2.1), 0.5 * k)), add(q, mul(fa(j * 2.1), 1.9 * k)), [0, 0, 0, 0.5], 0.4 * k); if (PM === "A") ring(q, 1.8 * k, GOLD, 0.6 * k); }
    if (P1 === "C") plate(D(-13, 0), rectPts(2, 5), AMMO, aim, k, 0.9);
    if (P3 === "B") { plate(D(-11, -8.4), rectPts(1.8, 1.2), METAL_D, aim, k, 0.9); glowDot(D(-11, -8.4), 0.5 * k, RED); }
    if (P3 === "C") { plate(D(-12, 7.6), rectPts(2.4, 1.3), AMMO, aim, k, 0.9); for (let i = 0; i < 3; i++) ring(D(-13 + i * 1.6, 7.6), 0.55 * k, YEL, 0.5 * k); }
    if (P4 === "C") plate(D(-12, -7.6), rectPts(2.2, 1.4), AMMO, aim, k, 0.9);
    // -- The rails: longer with Range, with the launch gear of each Range step ---------------------------------------------------
    for (const y of [-2.6, 2.6]) bar(D(-2, y), D(L, y), 1.8 * k, RM ? mix(METAL_L, GOLD, 0.5) : METAL_L);
    for (const x of [3, 9]) bar(D(x, -4), D(x, 4), 1.4 * k, dk(col, 0.2));
    strip(D(0, 0), D(L, 0), 0.6 * k, A(col, 0.3 + 0.7 * fl));
    if (R1 === "A") for (const y of [-2.6, 2.6]) bar(D(15, y), D(L, y), 2.2 * k, METAL);
    if (R1 === "B") for (const y of [-2.6, 2.6]) { bar(D(L - 5, y), D(L - 2, y), 2.8 * k, METAL); }
    if (R1 === "C") for (let i = 0; i < 3; i++) { ring(D(4 + i * 4, 0), 3.4 * k, A(col, 0.5), 0.9 * k); }
    if (R2 === "A") for (const y of [-2.6, 2.6]) for (let i = 0; i < 4; i++) line(D(1 + i * 3, y - 1), D(2.4 + i * 3, y + 1), STEEL, 1 * k);
    if (R2 === "B") { bar(D(-4, 0), D(-1, 0), 2.6 * k, METAL_D); orb(D(-4.6, 0), 1.5 * k, METAL); }
    if (R2 === "C") for (const y of [-4, 4]) plate(D(4, y), rectPts(2, 0.8), METAL_D, aim, k, 0.9);
    if (R3 === "A") { bar(D(2, 0), D(L - 2, 0), 5 * k, METAL); strip(D(3, 0), D(L - 3, 0), 0.5 * k, A(col, 0.3 + 0.7 * fl)); }
    if (R3 === "B") plate(D(0, 0), rectPts(2.6, 5), METAL_D, aim, k, 1);
    if (R3 === "C") for (let i = 0; i < 3; i++) { disc(D(-3, -3 + i * 3), 0.8 * k, OUTLINE); glowDot(D(-3, -3 + i * 3), 0.45 * k, A(col, 0.4 + 0.6 * fl)); }
    if (R4 === "A") bar(D(L - 4, 0), D(L + 1.5, 0), 5 * k, METAL_L);
    if (R4 === "B") for (let i = 0; i < 3; i++) bar(D(L - 8 + i * 2.4, -3.2), D(L - 8 + i * 2.4, 3.2), 1.4 * k, STEEL);
    if (R4 === "C") for (const y of [-4.6, 4.6]) bar(D(2, y), D(L - 3, y), 0.9 * k, STEEL);
    if (RM === "A") { bar(D(L - 3, 0), D(L + 1, 0), 5.6 * k, GOLD); }
    if (RM === "B") for (const x of [L - 10, L - 7, L - 4]) bar(D(x, -3.2), D(x, 3.2), 1.2 * k, GOLD);
    if (RM === "C") for (const y of [-4.6, 4.6]) bar(D(2, y), D(L - 3, y), 1 * k, GOLD);
    if (P1 === "B") for (const y of [-2.6, 2.6]) bar(D(6, y), D(7.6, y), 2.8 * k, METAL_D);
    if (P4 === "B") for (const y of [-2.6, 2.6]) for (let i = 0; i < 3; i++) line(D(10 + i * 1.5, y - 1.2), D(10 + i * 1.5, y + 1.2), [0, 0, 0, 0.55], 0.7 * k);
    if (P2s === "A") for (const sg of [-1, 1]) fill(D(L - 1, sg * 3), [[1.6, 0], [-1, sg * 1.4], [-1, 0]], METAL_L, aim, k);
    if (P2s === "B") bar(D(L - 2, -3.4), D(L - 2, 3.4), 1.8 * k, METAL_L);
    if (P2s === "C") for (const sg of [-1, 1]) plate(D(L - 3, sg * 3.6), rectPts(2, 0.7), METAL_D, aim, k, 0.9);
    if (PM === "B") for (const y of [-2.6, 2.6]) bar(D(L - 1.5, y), D(L, y), 2.2 * k, GOLD);
    if (B.r === 2) { const ky = B.key("r2"); if (ky === "A") for (const y of [-2.6, 2.6]) bar(D(L - 3, y), D(L, y), 2.4 * k, METAL); if (ky === "B") { bar(D(4, -4.4), D(L - 2, -2.8), 0.9 * k, STEEL); bar(D(4, 4.4), D(L - 2, 2.8), 0.9 * k, STEEL); } if (ky === "C") for (const y of [-2.6, 2.6]) bar(D(L - 6, y), D(L, y), 1.2 * k, STEEL); }
    if (B.r === 1) { const ky = B.key("r1"); if (ky === "B") { plate(S(10, 8), rectPts(3.4, 2), AMMO, 0, k, 1); for (let i = 0; i < 3; i++) drawMine(B, S(8 + i * 2.4, 8), k * 0.4, t, col, false, true); } }
    // -- The mine ready on the rails, and the hub ----------------------------------------------------------------------------------
    if (since > 0.5) drawMine(B, D(6, 0), k * 0.7, t, col, false); orb(c, 2.6 * k, METAL); glowDot(c, 1 * k, PM ? GOLD : col);
  },
  paths: [
    { name: "Power/Damage", theme: "the mine itself and its blast change at every step", steps: [
      { name: "Heavier Charge", cost: 160, effect: "100 damage", options: [
        { key: "A", name: "Charge Rings", desc: "Extra rings round the mount; the mines are a size bigger." },
        { key: "B", name: "Heavy Rail Clamps", desc: "Thick clamps on both rails; the mines are a size bigger." },
        { key: "C", name: "Charge Hopper", desc: "A charge hopper behind the magazine; the mines are a size bigger." } ] },
      { name: "Wider Charge", cost: 265, effect: "50 px blast", options: [
        { key: "A", name: "Blast Fins", desc: "Fins at the end of the rails; the blast is wider, with a shock ring." },
        { key: "B", name: "Wide Muzzle Bar", desc: "A wide bar across the rail mouth; a wider blast with a shock ring." },
        { key: "C", name: "Spread Plates", desc: "Spread plates beside the rail mouth; a wider blast with a shock ring." } ] },
      { name: "HE Mines", cost: 1190, effect: "125 damage (primary)", options: [
        { key: "A", name: "HE-Banded Canisters", desc: "Yellow bands on the magazine canisters; dark mines with a yellow band." },
        { key: "B", name: "Red Fuse Box", desc: "A fuse box with a red lamp; dark yellow-banded mines." },
        { key: "C", name: "HE Rack", desc: "A rack of yellow-banded HE mines; dark yellow-banded mines." } ] },
      { name: "Fragmentation Casing", cost: 1325, effect: "60 px blast", options: [
        { key: "A", name: "Segmented Canisters", desc: "Segment lines on the magazine; segmented mines that throw extra fragments." },
        { key: "B", name: "Segmented Rails", desc: "Segment grooves cut across both rails; segmented mines with extra fragments." },
        { key: "C", name: "Shrapnel Crate", desc: "A shrapnel crate by the magazine; segmented mines with extra fragments." } ] },
      { name: "Anti-Tank Mines", cost: 6880, effect: "150 damage, 65 px blast (mastery)", options: [
        { key: "A", name: "Gold Canisters", desc: "Gold rings on every canister; big gold-rimmed pancake mines with gold blasts." },
        { key: "B", name: "Gold Rail Caps", desc: "Gold caps on the rails; big gold-rimmed mines, gold blasts." },
        { key: "C", name: "Gold Mount Ring", desc: "A gold ring round the mount; big gold-rimmed mines, gold blasts." } ] },
    ] },
    { name: "Production Speed", theme: "faster laying and a bigger cap: the magazine grows, then presses and belts", steps: [
      { name: "Quick Assembly", cost: 110, effect: "A mine every 1.33 s; cap 24", options: [
        { key: "A", name: "Press Plate", desc: "A small press thumping down beside the mount." },
        { key: "B", name: "Feed Chute", desc: "A feed chute into the mount." },
        { key: "C", name: "Counter Lamps", desc: "Three blinking green counter lamps." } ] },
      { name: "Twin Press", cost: 270, effect: "Every 1.2 s; cap 28", options: [
        { key: "A", name: "Twin Presses", desc: "Two presses on the other side that thump in turn." },
        { key: "B", name: "Dual Chutes", desc: "Two feed chutes." },
        { key: "C", name: "Press Pistons", desc: "Two press pistons that pump." } ] },
      { name: "Assembly Line", cost: 1080, effect: "Every 0.95 s; cap 32 (primary)", options: [
        { key: "A", name: "Conveyor Belt", desc: "A conveyor belt along the deck with mines riding it; a second magazine column." },
        { key: "B", name: "Belt Gantry", desc: "A belt gantry with uprights; a second magazine column." },
        { key: "C", name: "Roller Line", desc: "A roller line along the deck; a second magazine column." } ] },
      { name: "Rapid Line", cost: 1620, effect: "Every 0.85 s; cap 36", options: [
        { key: "A", name: "Servo Motors", desc: "Servo motors with orange lamps at the ends of the line." },
        { key: "B", name: "Second Belt", desc: "A second belt plate." },
        { key: "C", name: "Speed Lamps", desc: "A row of pulsing orange speed lamps." } ] },
      { name: "Mine Factory", cost: 5395, effect: "Every 0.7 s; cap 45 (mastery)", options: [
        { key: "A", name: "Gold Belt", desc: "The belt turns gold; a third magazine column." },
        { key: "B", name: "Gold Presses", desc: "The presses turn gold; a third magazine column." },
        { key: "C", name: "Gold Hopper", desc: "A gold hopper; a third magazine column." } ] },
    ] },
    { name: "Range", theme: "how far it tosses: the rails lengthen and gain launch gear", steps: [
      { name: "Longer Arm", cost: 150, effect: "140 px", options: [
        { key: "A", name: "Extension Rails", desc: "The rails are extended with thicker end sections." },
        { key: "B", name: "Rail Sleeves", desc: "Heavy sleeves on the ends of the rails." },
        { key: "C", name: "Boost Coils", desc: "Three glowing boost coils round the rails." } ] },
      { name: "Spring Launcher", cost: 300, effect: "160 px", options: [
        { key: "A", name: "Coil Springs", desc: "Coil springs along both rails." },
        { key: "B", name: "Piston Kick", desc: "A kick piston behind the rails." },
        { key: "C", name: "Spring Pads", desc: "Spring pads either side of the rails." } ] },
      { name: "Mine Mortar", cost: 900, effect: "190 px (primary)", options: [
        { key: "A", name: "Mortar Tube", desc: "A short mortar tube over the rails." },
        { key: "B", name: "Breech Block", desc: "A breech block at the rear of the rails." },
        { key: "C", name: "Charge Cells", desc: "Three charge cells behind the rails that glow as it fires." } ] },
      { name: "Long Mortar", cost: 1800, effect: "220 px", options: [
        { key: "A", name: "Longer Tube", desc: "A longer mortar tube end." },
        { key: "B", name: "Cooling Rings", desc: "Cooling rings along the rails." },
        { key: "C", name: "Brace Struts", desc: "Brace struts along both sides." } ] },
      { name: "Minefield Launcher", cost: 4795, effect: "260 px: covers a long stretch of track (mastery)", options: [
        { key: "A", name: "Gold Muzzle", desc: "A gold muzzle on the rails; gold-tinted rails." },
        { key: "B", name: "Gold Rings", desc: "Gold rings along the rails." },
        { key: "C", name: "Gold Braces", desc: "Gold braces along both sides." } ] },
    ] },
  ],
  retrofits: [
    { name: "Conveyor Feed", cost: 110, effect: "A mine every 1.33 s, a 25-mine cap (stacks with Quick Assembly)", options: [
      { key: "A", name: "Side Belt", desc: "A conveyor belt of ready mines along the deck's side." },
      { key: "B", name: "Hopper Chute", desc: "A hopper with a chute into the mount." },
      { key: "C", name: "Belt Loop", desc: "A looping carousel of ready mines." } ] },
    { name: "Shaped Charges", cost: 160, effect: "+15 damage per mine (100) (stacks with Heavier Charge)", options: [
      { key: "A", name: "Plated Mines", desc: "Every mine carries a directional charge plate on top." },
      { key: "B", name: "Charge Rack", desc: "A rack of ready mines on the deck, each with a charge ring." },
      { key: "C", name: "Cone Charges", desc: "Every mine carries a shaped-charge cone on top." } ] },
    { name: "Long Arm", cost: 150, effect: "+20 toss range (140) (stacks with Longer Arm)", options: [
      { key: "A", name: "Long Arm Rails", desc: "The rails are lengthened and capped." },
      { key: "B", name: "Arm Braces", desc: "The rails are lengthened with braces." },
      { key: "C", name: "Telescoping Rails", desc: "The rails are lengthened with telescoping end sections." } ] },
  ],
};
P2.picks = {};
