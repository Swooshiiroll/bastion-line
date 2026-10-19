// ---- Tower art second pass: Mine Layer (tower 11), round 1 ------------------------------------------------------
// Base: look F Rail Launcher, animation C Confetti Charge. One parametric model with the lessons so far: options swap
// parts rather than lay overlays over them; the mine itself changes at every Power step (it is the projectile); masteries
// are gold; the timing comes from the agent's own clock. All three Retrofits overlap a path step and are kept, their stats
// stacking (the carpet rule): Shaped Charges adds to Heavier Charge and Long Arm to Longer Arm (the Conveyor Feed was replaced by Adhesive Mines).
// Geometry (game px): a round mount r 10 with a magazine of canisters behind it and two rails ahead (x -2 to 15); a mine
// is a squat canister (r 3.6) with a glowing band that blinks while it waits on the track.
const PAGE = { title: "Mine Layer: paths and Retrofits (second pass)", store: "bl-tower-art-p2-mines-r8" };
const GEL = [0.65, 0.9, 0.2, 1], TANKG = [0.3, 0.45, 0.15, 1], GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], RED = [0.85, 0.2, 0.18, 1], YEL = [1, 0.85, 0.2, 1], ORANGE = [1, 0.55, 0.2, 1];
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null);
const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);

// ---- Stats the look follows: toss gap, cap shown, blast, range -----------------------------------------------------------
const GAP = [1.5, 1.33, 1.2, 0.95, 0.85, 0.7];                                      // seconds per mine by Production level
const gapOf = (B) => GAP[B.lv[1]];
const capOf = (B) => [6, 7, 8, 9, 10, 12][B.lv[1]];                               // the preview's cap (the game's is 20 to 45)
const BLAST = [40, 40, 50, 50, 60, 65];                                            // blast px by Power level
const RANGE = [120, 140, 160, 190, 220, 260];
const railExt = (B) => [0, 1.5, 3, 4.5, 6, 8][B.lv[2]] + (B.r === 2 ? 1.5 : 0); // the rails simply get longer, in small steps (owner: the end length was too long)

// ---- The mine: a canister whose look follows the Power steps and the Shaped Charges Retrofit -----------------------------
// Every Power effect lives on the mine canister itself, inside its outline (owner): nothing sticks out round it and nothing is on the launcher.
function drawMine(B, p, k, t, col, blink, mini, onLauncher) {
  const P1 = Kp(B, 0, 0), P2m = Kp(B, 0, 1), P3 = Kp(B, 0, 2), P4 = Kp(B, 0, 3), PM = Kp(B, 0, 4), z = (P1 ? 1.12 : 1) * (PM ? 1.25 : 1) * (mini ? 0.55 : 1), r = 3.6 * k * z;
  ellipse(add(p, [k * 0.8, k * 1.6]), 4 * k * z, 1.8 * k * z, [0, 0, 0, 0.3]);
  const flange = !mini && !onLauncher ? P2m : null; // the Wider Charge flange belongs to the thrown mine only (owner)
  if (flange === "A") { disc(p, r * 1.32, OUTLINE); disc(p, r * 1.24, METAL_D); }                                        // a flared skirt
  if (flange === "B") { disc(p, r * 1.3, OUTLINE); disc(p, r * 1.22, STEEL); for (let i = 0; i < 8; i++) disc(add(p, mul(fa(i * TAU / 8 + 0.2), r * 1.22)), 0.45 * k * z, METAL_L); }  // a wide flange with tabs
  if (flange === "C") { disc(p, r * 1.2, OUTLINE); disc(p, r * 1.13, dk(METAL, 0.2)); for (let i = 0; i < 4; i++) disc(add(p, mul(fa(i * Math.PI / 2 + 0.4), r * 1.13)), 0.5 * k * z, METAL_L); } // a blast collar with bolts
  disc(p, r, OUTLINE); disc(p, r * 0.86, P3 ? [0.2, 0.2, 0.22, 1] : METAL_L);
  if (P1 === "A") ring(p, r * 0.9, [0.1, 0.1, 0.12, 1], 1.5 * k * z);                                                                         // a thick dark rim
  if (P1 === "B") for (const sg of [-1, 1]) plate(add(p, [0, sg * r * 0.45]), rectPts(r * 0.55, r * 0.14), STEEL, 0, 1, 0.6);                    // two steel weight plates
  if (P1 === "C") { disc(p, r * 0.42, [0.12, 0.12, 0.14, 1]); ring(p, r * 0.42, WHITE, 0.5 * k * z); }                                           // a dark charge core
  if (PM) { ring(p, r * 0.95, GOLD, 1 * k); ring(p, r * 0.55, GOLD, 0.7 * k); }
  if (P3) ring(p, r * 0.62, YEL, 0.9 * k * z);
  if (P4) for (let i = 0; i < 6; i++) line(add(p, mul(fa(i * TAU / 6), r * 0.25)), add(p, mul(fa(i * TAU / 6), r * 0.85)), [0, 0, 0, 0.5], 0.5 * k);
  if (B.r === 0 && B.key("r0") === "A") { disc(p, r * 1.05, A(GEL, 0.55)); for (let i = 0; i < 5; i++) disc(add(p, mul(fa(i * TAU / 5 + 0.4), r * 1.05)), 0.5 * k * z, GEL); disc(add(p, [r * 0.4, r * 1.05]), 0.55 * k * z, A(GEL, 0.9)); }  // a glossy gel coat with drips
  if (B.r === 1) { const ky = B.key("r1"); if (ky === "A") plate(add(p, [r * 0.15, -r * 0.1]), rectPts(0.9, 1.3), STEEL, 0, k * z, 0.7); if (ky === "C") fill(add(p, [0, -r * 0.1]), [[1.4, 0], [-0.8, 1.1], [-0.8, -1.1]], STEEL, -Math.PI / 2, k * z); if (ky === "B") ring(p, r * 0.35, STEEL, 0.8 * k); }
  ring(p, r * 0.6, A(PM ? GOLD : col, blink ? 1 : 0.5), 0.9 * k * z); disc(p, r * 0.3, METAL);
  if (blink) glowDot(p, 1.2 * k * z, A(PM ? GOLD : col, 1)); }

// ---- The agent: tosses mines onto random spots along the track in range; they arm, blink and go off under a ground enemy ----
// The launcher a mine leaves from: with Twin Press A two identical launchers either side of the centre take turns (m.n is the mine being thrown).
function tossFrom(B, m, info, s) { const o = Kp(B, 1, 1), kk = G(s);
  if (o === "A") { const yc = m.n % 2 ? -4.5 : 4.5; m.lastYc = yc; return add(info.c, rot([s * 0.3, yc * kk], info.aim)); }
  m.lastYc = 0;
  if (B.lv[1] >= 2 && m.n % 2) return o === "B" ? add(info.c, mul(fa(info.aim + 0.45), s * 0.3)) : add(info.c, rot([s * 0.3, -6.4 * kk], info.aim));
  return add(info.c, mul(fa(info.aim), s * 0.3)); }
function mineAgent(B) { return (m, t, info, s, col) => { const k = G(s), laneY = info.H * 0.8, cap = capOf(B), gap = gapOf(B), PM = Kp(B, 0, 4), P2 = Kp(B, 0, 1), P4 = Kp(B, 0, 3), blastPx = BLAST[B.lv[0]];
  if (!m.mines) { m.mines = []; m.lastToss = t - 1; m.n = 0; }
  const R = (RANGE[B.lv[2]] + (B.r === 2 ? 20 : 0)) / 48 * s * 0.55;
  const pick = () => { const x = Math.max(s * 0.25, Math.min(info.W - s * 0.25, info.c[0] + (rnd2(m.n * 3.7 + 1.1) * 2 - 1) * R + R * 0.4)); return [x, laneY + (rnd2(m.n * 5.3 + 2.7) - 0.5) * s * 0.3]; };
  if (!m.next) m.next = pick(); m.aimAt = m.next;
  if (t - m.lastToss >= gap && m.mines.filter((q) => !q.boom).length < cap) { m.n++; m.mines.push({ to: m.next, t0: t, from: tossFrom(B, m, info, s), n: m.n }); m.lastToss = t; m.next = pick(); }
  for (const q of m.mines) { const age = t - q.t0;
    if (q.boom) { const v = (t - q.boom) / 0.6, size = 0.3 * blastPx / 40, ag = t - q.boom;
      if (B.r === 0 && ag > 0.15 && ag < 2.6) { const gv = Math.min(1, (ag - 0.15) / 0.4), fade = ag > 2 ? 1 - (ag - 2) / 0.6 : 1; for (let j = 0; j < 4; j++) ellipse(add(q.to, [Math.cos(j * 1.7) * s * 0.07 * gv, Math.sin(j * 1.7) * s * 0.025 * gv]), s * (0.14 + 0.03 * j) * gv, s * (0.05 + 0.01 * j) * gv, A(GEL, 0.32 * fade)); }  // the sticky gel the blast leaves, slowing enemies
      if (v >= 1) continue;
      blast(q.to, v, s, PM ? GOLD : col, size); if (P2) ring(q.to, s * size * (0.8 + v), A(PM ? GOLD : col, 0.5 * (1 - v)), 1);
      const cs = PM ? [GOLD, [1, 0.9, 0.5, 1], [1, 0.7, 0.2, 1]] : [[1, 0.3, 0.35, 1], [0.3, 0.9, 1, 1], [1, 0.85, 0.3, 1], [0.6, 1, 0.4, 1], [1, 0.45, 0.85, 1]];
      for (let i = 0; i < 16 + (P4 ? 8 : 0); i++) { const d = fa(rnd2(q.n * 13 + i) * TAU), c0 = cs[i % cs.length], p2 = add(add(q.to, mul(d, s * (0.2 + 0.9 * rnd2(i + q.n)) * v * blastPx / 40)), [0, v * v * s * 0.3]); fill(p2, rectPts(1.6, 0.8), A(c0, 1 - v), v * 12 + i, 1); }
      continue; }
    if (age < 0.6) { const u = age / 0.6; drawMine(B, add(lerp(q.from, q.to, u), [0, -Math.sin(Math.PI * u) * s * 0.6]), k * 0.85, t, col, false); continue; }
    if (age < 0.9) ring(q.to, s * 0.2 * ((age - 0.6) / 0.3), [1, 1, 1, 0.5 * (1 - (age - 0.6) / 0.3)], 1);
    drawMine(B, q.to, k, t, col, fmod(t * 1.6 + q.n * 0.37, 1) < 0.25);
    for (const e of info.ens) if (dist(e.p, q.to) < s * 0.15) { q.boom = t; break; } }
  m.mines = m.mines.filter((q) => !q.boom || t - q.boom < (B.r === 0 ? 2.6 : 0.6)); }; }

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
    if (B.r === 0) { const ky = B.key("r0");   // Adhesive Mines: a glue tank, or a rack of gel cartridges; the gel itself shows on the mines and the track
      if (ky === "B") { plate(S(-12, -10), rectPts(3, 3.4), TANKG, 0, k, 1); ring(S(-12, -10), 1.6 * k, [0.95, 1, 0.7, 0.8], 0.8 * k); bar(S(-10, -9), S(-8, -5), 1.4 * k, [0.55, 0.7, 0.2, 1]); disc(S(-7.6, -4.6), 0.9 * k, [0.65, 0.9, 0.25, 1]); }
      if (ky === "C") { plate(S(-10, -10.5), rectPts(5, 2), METAL_D, 0, k, 1); for (let i = 0; i < 4; i++) { bar(S(-13 + i * 2, -10.5), S(-13 + i * 2, -9), 1.3 * k, [0.6, 0.85, 0.2, 1]); disc(S(-13 + i * 2, -11.6), 0.7 * k, METAL_L); } } }
    // Quick Assembly (round 2 ideas): a hopper of ready mines, a charge gauge, a loader arm
    if (S1 === "A") { plate(S(-12, 8), rectPts(3, 2.6), METAL_D, 0, k, 1); for (let i = 0; i < 2; i++) drawMine(B, S(-13 + i * 2.6, 8), k * 0.5, t, col, false, true); }
    if (S1 === "B") { const q = S(-12, 8); disc(q, 3.2 * k, OUTLINE); disc(q, 2.7 * k, METAL_D); line(q, add(q, mul(fa(-Math.PI * 0.85 + Math.min(1, since / (gapOf(B) * 0.95)) * Math.PI * 0.7), 2.3 * k)), WHITE, 1 * k); }
    if (S1 === "C") { const q = S(-12, 8), a = Math.PI * 1.25 + decay(since, 0.4) * 1.2; orb(q, 1.5 * k, METAL); bar(q, add(q, mul(fa(a), 5 * k)), 1.3 * k, METAL_L); disc(add(q, mul(fa(a), 5.4 * k)), 0.9 * k, STEEL); }
    // The Assembly Line and its relatives feed straight into the centre of the mount (owner): a belt runs in from the deck edge to the hub
    const beltIn = (from, bc, kind) => { bar(from, c, 2.8 * k, bc); line(from, c, [0, 0, 0, 0.4], 0.6 * k);
      if (kind === "gantry") for (let i = 1; i < 4; i++) { const q = lerp(from, c, i / 4.4), o = orth(norm(sub(c, from))); line(add(q, mul(o, 2.4 * k)), add(q, mul(o, -2.4 * k)), METAL_L, 1.1 * k); }
      if (kind === "roller") for (let i = 1; i < 8; i++) disc(lerp(from, c, i / 8.6), 1 * k, STEEL);
      for (let i = 0; i < 4; i++) { const u = fmod(t * 0.45 + i / 4, 1); if (u < 0.82) drawMine(B, lerp(from, c, u), k * 0.5, t, col, false, true); } };
    if (S4 === "C") for (let i = 0; i < 6; i++) { const a = Math.PI * 0.55 + i * 0.32; glowDot(add(c, mul(fa(a), 10.6 * k)), 0.4 * k, A(ORANGE, 0.4 + 0.5 * Math.sin(t * 6 + i))); }
    if (SM === "B") for (const x of [-11, -6]) plate(S(x, -9), rectPts(2.2, 1.8), GOLD, 0, k, 1);
    if (SM === "C") plate(S(-13, 6), rectPts(2.4, 2.4), GOLD, 0, k, 1);
    // -- The mount and the magazine (a stack of canisters behind it; one more column with each Production step) ---------------
    disc(c, 10 * k, OUTLINE); disc(c, 9.2 * k, PM === "C" ? mix(METAL, GOLD, 0.3) : METAL);  if (PM === "C") ring(c, 9.4 * k, GOLD, 1.2 * k);
    // The belts run in over the mount and end at the launcher in the centre (owner)
    if (S3) beltIn(S(-15, 10), SM === "A" ? GOLD : METAL_D, S3 === "B" ? "gantry" : S3 === "C" ? "roller" : "belt");
    else if (SM === "A") beltIn(S(-15, 10), GOLD, "belt");
    if (S4 === "B") beltIn(S(-15, -10), METAL_D, "belt");

    if (B.lv[1] >= 4) { const w = 0.8 + 0.5 * (B.lv[1] - 3) + (S4 === "A" ? 2.2 : 0); for (let i = 0; i < 16; i++) { const a = i * TAU / 16 + t * w; line(add(c, mul(fa(a), 8.3 * k)), add(c, mul(fa(a), 9.3 * k)), A(PM ? GOLD : METAL_L, 0.85), 0.8 * k); } }
    if (S4 === "A") for (const a of [Math.PI * 0.62, Math.PI * 1.38]) { const q = add(c, mul(fa(a), 10.4 * k)); plate(q, rectPts(1.8, 1.3), METAL_D, a, k, 0.9); glowDot(add(q, mul(fa(a), 0.2 * k)), 0.45 * k, fmod(t * 5, 1) < 0.5 ? ORANGE : A(ORANGE, 0.3)); }
    const cols = 1; // only the three original canisters sit behind the tower (owner)
    for (let cl = 0; cl < cols; cl++) for (let i = 0; i < 3; i++) { const q = D(-6 - cl * 3, (i - 1) * 4.2), mine = { lv: B.lv, r: B.r, key: B.key }; drawMine(B, q, k * 0.55, t, col, false, true);
      if (P3 === "A") ring(q, 1.5 * k, YEL, 0.6 * k); if (P4 === "A") for (let j = 0; j < 3; j++) line(add(q, mul(fa(j * 2.1), 0.5 * k)), add(q, mul(fa(j * 2.1), 1.9 * k)), [0, 0, 0, 0.5], 0.4 * k); if (PM === "A") ring(q, 1.8 * k, GOLD, 0.6 * k); }
    if (P3 === "B") { plate(D(-11, -8.4), rectPts(1.8, 1.2), METAL_D, aim, k, 0.9); glowDot(D(-11, -8.4), 0.5 * k, RED); }
    if (P3 === "C") { plate(D(-12, 7.6), rectPts(2.4, 1.3), AMMO, aim, k, 0.9); for (let i = 0; i < 3; i++) ring(D(-13 + i * 1.6, 7.6), 0.55 * k, YEL, 0.5 * k); }
    if (P4 === "C") plate(D(-12, -7.6), rectPts(2.2, 1.4), AMMO, aim, k, 0.9);
    // -- The launchers: one pair of rails centred on the circle, or (Twin Press, side by side) two IDENTICAL pairs set symmetrically either
    // side of the centre; the mines alternate between them and the one that fired glows. Longer with Range, with the gear of each step.
    const twinA = S2 === "A", LA = twinA ? [4.5, -4.5] : [0], hf = 2.6; // every launcher keeps the single launcher's rail size and spacing (owner)
    LA.forEach((yc) => { const act = twinA ? (mm.lastYc === yc ? fl : 0) : fl, ry = [yc - hf, yc + hf];
      for (const y of ry) bar(D(-2, y), D(L, y), 1.8 * k, RM ? mix(METAL_L, GOLD, 0.5) : METAL_L);
      for (let x = 3; x < L - 2; x += 6) bar(D(x, yc - hf - 1.4), D(x, yc + hf + 1.4), 1.4 * k, dk(col, 0.2)); // a band every 6 px, so a longer launcher carries more bands
      strip(D(0, yc), D(L, yc), 0.6 * k, A(col, 0.3 + 0.7 * act));
      if (R1 === "B") for (const y of ry) bar(D(L - 5, y), D(L - 2, y), 2.8 * k, METAL);
      if (R1 === "C") for (let i = 0; i < 3; i++) ring(D(4 + i * 4, yc), (hf + 0.8) * k, A(col, 0.5), 0.9 * k);
      if (R2 === "A") for (const y of ry) for (let i = 0; i < 4; i++) line(D(1 + i * 3, y - 1), D(2.4 + i * 3, y + 1), STEEL, 1 * k);
      if (R2 === "B") { bar(D(-4, yc), D(-1, yc), 2.6 * k, METAL_D); orb(D(-4.6, yc), 1.5 * k, METAL); }
      if (R2 === "C") for (const y of [yc - hf - 1.4, yc + hf + 1.4]) plate(D(4, y), rectPts(2, 0.8), METAL_D, aim, k, 0.9);
      if (R3 === "B") plate(D(0, yc), rectPts(2.6, hf + 2.4), METAL_D, aim, k, 1);
      if (R3 === "C") for (let i = 0; i < 3; i++) { disc(D(-3, yc - 3 + i * 3), 0.8 * k, OUTLINE); glowDot(D(-3, yc - 3 + i * 3), 0.45 * k, A(col, 0.4 + 0.6 * act)); }
      if (R4 === "B") for (let i = 0; i < 3; i++) bar(D(L - 8 + i * 2.4, yc - hf - 0.6), D(L - 8 + i * 2.4, yc + hf + 0.6), 1.4 * k, STEEL);
      if (R4 === "C") for (const y of [yc - hf - 2, yc + hf + 2]) bar(D(2, y), D(L - 3, y), 0.9 * k, STEEL);
      if (RM === "A") bar(D(L - 3, yc), D(L + 1, yc), (hf * 2 + 0.4) * k, GOLD);
      if (RM === "B") for (const x of [L - 10, L - 7, L - 4]) bar(D(x, yc - hf - 0.6), D(x, yc + hf + 0.6), 1.2 * k, GOLD);
      if (RM === "C") for (const y of [yc - hf - 2, yc + hf + 2]) bar(D(2, y), D(L - 3, y), 1 * k, GOLD);
      if (P4 === "B") for (const y of ry) for (let i = 0; i < 3; i++) line(D(10 + i * 1.5, y - 1.2), D(10 + i * 1.5, y + 1.2), [0, 0, 0, 0.55], 0.7 * k);
      if (PM === "B") for (const y of ry) bar(D(L - 1.5, y), D(L, y), 2.2 * k, GOLD); });
    if (B.r === 1) { const ky = B.key("r1"); if (ky === "B") { plate(S(10, 8), rectPts(3.4, 2), AMMO, 0, k, 1); for (let i = 0; i < 3; i++) drawMine(B, S(8 + i * 2.4, 8), k * 0.4, t, col, false, true); } }
    if (S2 === "B") { const D2 = (x, y) => P(c, aim + 0.45, k, x, y); for (const y of [-2.6, 2.6]) bar(D2(-2, y), D2(L * 0.92, y), 1.6 * k, METAL_L); strip(D2(0, 0), D2(L * 0.92, 0), 0.5 * k, A(col, 0.2 + 0.6 * fl)); }
    if (S2 === "C") { bar(D(-2, -6.4), D(L, -6.4), 2.4 * k, METAL_L); strip(D(0, -6.4), D(L, -6.4), 0.5 * k, A(col, 0.2 + 0.6 * fl)); bar(D(2, -6.4), D(2, -2.6), 1.1 * k, STEEL); }
    // -- The mine ready on the rails, and the hub ----------------------------------------------------------------------------------
    const nextYc = twinA ? (((mm.n || 0) + 1) % 2 ? -4.5 : 4.5) : 0;
    if (since > 0.5) drawMine(B, D(6, nextYc), k * 0.7, t, col, false, false, true);
    orb(c, 3.8 * k, METAL); ring(c, 3.8 * k, OUTLINE, 1 * k); glowDot(c, 1.8 * k, PM ? GOLD : col); // the central eye
  },
  paths: [
    { name: "Power/Damage", theme: "the mine itself and its blast change at every step", steps: [
      { name: "Heavier Charge", cost: 160, effect: "100 damage", options: [
        { key: "A", name: "Thick Rim", desc: "A thick dark rim round each mine canister; the mines are a size bigger." },
        { key: "B", name: "Weight Plates", desc: "Two steel weight plates across each mine canister; the mines are a size bigger." },
        { key: "C", name: "Charge Core", desc: "A dark charge core with a white rim on each mine canister; the mines are a size bigger." } ] },
      { name: "Wider Charge", cost: 265, effect: "50 px blast", options: [
        { key: "A", name: "Flared Skirt", desc: "A flared skirt round each thrown mine; the blast is wider, with a shock ring." },
        { key: "B", name: "Wide Flange", desc: "A wide steel flange with tabs round each thrown mine (never on the launcher); a wider blast with a shock ring." },
        { key: "C", name: "Blast Collar", desc: "A bolted blast collar round each thrown mine; a wider blast with a shock ring." } ] },
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
        { key: "A", name: "Mine Hopper", desc: "A hopper of ready mines beside the mount." },
        { key: "B", name: "Charge Gauge", desc: "A dial beside the mount whose needle swings as the next mine is made." },
        { key: "C", name: "Loader Arm", desc: "A loader arm beside the mount that swings with each mine." } ] },
      { name: "Twin Press", cost: 270, effect: "Every 1.2 s; cap 28", options: [
        { key: "A", name: "Side-by-Side Launchers", desc: "Two identical launchers set symmetrically either side of the centre of the circle; the mines alternate between them, and the one that fired glows." },
        { key: "B", name: "Angled Rail", desc: "A second pair of rails fanned out at an angle; mines alternate between the rails." },
        { key: "C", name: "Underslung Rail", desc: "A second, single rail slung under the mount; mines alternate between the rails." } ] },
      { name: "Assembly Line", cost: 1080, effect: "Every 0.95 s; cap 32 (primary)", options: [
        { key: "A", name: "Conveyor Belt", desc: "A conveyor belt that runs straight into the centre of the mount, carrying mines in." },
        { key: "B", name: "Belt Gantry", desc: "A gantry belt with uprights that feeds straight into the centre." },
        { key: "C", name: "Roller Line", desc: "A roller line that feeds straight into the centre." } ] },
      { name: "Rapid Line", cost: 1620, effect: "Every 0.85 s; cap 36", options: [
        { key: "A", name: "Servo Motors", desc: "Servo motors on the mount's rim that speed the rotunda up: its ring of ticks spins much faster." },
        { key: "B", name: "Second Belt", desc: "A second belt that also feeds into the centre from the other side." },
        { key: "C", name: "Speed Lamps", desc: "A row of pulsing orange speed lamps round the mount." } ] },
      { name: "Mine Factory", cost: 5395, effect: "Every 0.7 s; cap 45 (mastery)", options: [
        { key: "A", name: "Gold Belt", desc: "The belt turns gold; a third magazine column." },
        { key: "B", name: "Gold Presses", desc: "The presses turn gold; a third magazine column." },
        { key: "C", name: "Gold Hopper", desc: "A gold hopper; a third magazine column." } ] },
    ] },
    { name: "Range", theme: "how far it tosses: the rails lengthen and gain launch gear", steps: [
      { name: "Longer Arm", cost: 150, effect: "140 px", options: [
        { key: "A", name: "Longer Rails", desc: "The rails are simply made longer, with no thickened parts." },
        { key: "B", name: "Rail Sleeves", desc: "Heavy sleeves on the ends of the rails." },
        { key: "C", name: "Boost Coils", desc: "Three glowing boost coils round the rails." } ] },
      { name: "Spring Launcher", cost: 300, effect: "160 px", options: [
        { key: "A", name: "Coil Springs", desc: "Coil springs along both rails." },
        { key: "B", name: "Piston Kick", desc: "A kick piston behind the rails." },
        { key: "C", name: "Spring Pads", desc: "Spring pads either side of the rails." } ] },
      { name: "Mine Mortar", cost: 900, effect: "190 px (primary)", options: [
        { key: "A", name: "Stretched Rails", desc: "The original rails stretch out longer into a mortar launcher (no added pieces)." },
        { key: "B", name: "Breech Block", desc: "A breech block at the rear; the original rails stretch longer." },
        { key: "C", name: "Charge Cells", desc: "Three charge cells behind the rails that glow as it fires; the original rails stretch longer." } ] },
      { name: "Long Mortar", cost: 1800, effect: "220 px", options: [
        { key: "A", name: "Longer Rails", desc: "The original rails stretch longer again, no extension pieces." },
        { key: "B", name: "Cooling Rings", desc: "Cooling rings along the rails, which stretch longer." },
        { key: "C", name: "Brace Struts", desc: "Brace struts along both sides, and the rails stretch longer." } ] },
      { name: "Minefield Launcher", cost: 4795, effect: "260 px: covers a long stretch of track (mastery)", options: [
        { key: "A", name: "Gold Muzzle", desc: "A gold muzzle on the rails; gold-tinted rails." },
        { key: "B", name: "Gold Rings", desc: "Gold rings along the rails." },
        { key: "C", name: "Gold Braces", desc: "Gold braces along both sides." } ] },
    ] },
  ],
  retrofits: [
    { name: "Adhesive Mines", cost: 40, effect: "Each mine's blast leaves sticky gel that slows enemies 20% for 2 s", options: [
      { key: "A", name: "Gel Coating", desc: "Every mine wears a glossy gel coat with drips, and its blast leaves a sticky gel puddle on the track." },
      { key: "B", name: "Glue Tank", desc: "A gel tank with a hose on the deck; the blasts leave sticky gel puddles on the track." },
      { key: "C", name: "Gel Cartridges", desc: "A rack of gel cartridges beside the mount; the blasts leave sticky gel puddles on the track." } ] },
    { name: "Shaped Charges", cost: 160, effect: "+15 damage per mine (100) (stacks with Heavier Charge)", options: [
      { key: "A", name: "Plated Mines", desc: "Every mine carries a directional charge plate on top." },
      { key: "B", name: "Charge Rack", desc: "A rack of ready mines on the deck, each with a charge ring." },
      { key: "C", name: "Cone Charges", desc: "Every mine carries a shaped-charge cone on top." } ] },
    { name: "Long Arm", cost: 150, effect: "+20 toss range (140) (stacks with Longer Arm)", options: [
        { key: "A", name: "Longer Rails", desc: "The rails are replaced with longer rails." },
        { key: "B", name: "Longer Rails and Braces", desc: "The rails are replaced with longer rails, braced along the sides." },
        { key: "C", name: "Longer Telescoping Rails", desc: "The rails are replaced with longer rails with telescoping ends." } ] },
  ],
};
P2.picks = {};

// ---- Round 2 (owner's picks and notes, 2026-10-18): picked stages show only the pick (re-described where a note changed it);
// Quick Assembly and Twin Press show new ideas.
P2.intro = "Round 8: it was the thin clamps (Heavier Charge) you meant, so those are gone from the launcher and Heavier Charge has three new looks on the mine canister; Wider Charge is back to your wide flange on the thrown mine. Round 7: the wide flange is gone and Wider Charge has three new looks, all on the mine canister itself (a raised dome, a ring of studs, or red bands); Adhesive Mines is picked (Gel Coating). Round 6: the Conveyor Feed Retrofit is replaced by Adhesive Mines (your pick): gel-coated mines or a gel tank, and each blast leaves a sticky gel puddle that slows enemies. Long Arm is picked (Long Arm Rails). Round 5: the wide flange is only on the thrown mine, never on the launcher; Long Arm shows its three options again. Round 4: all your picks drawn with your latest notes: the two launchers are identical and centred on the circle and the mines alternate between them, the central eye is bigger, the belt runs on over the mount to the launcher in the centre, the notched rotunda only appears from Rapid Line, and the rails are simply longer (no thickened parts). Round 2's notes still apply: only the three original canisters sit behind the tower; Wider Charge changes the mine (a flange round it) rather than the thrower; the Assembly Line feeds straight into the centre; the Servo Motors sit on the mount and speed its ring of ticks up (the rotunda); the Mine Mortar and Long Mortar stretch the original rails instead of adding pieces; the Long Arm replaces the rails with longer ones. Use the build preview to check combinations.";
P2.picks = { p0s0: undefined, p0s1: "B", p0s2: "A", p0s3: "A", p0s4: "A", p1s0: "C", p1s1: "A", p1s2: "A", p1s3: "A", p1s4: "A", p2s0: "A", p2s1: "A", p2s2: "B", p2s3: "A", p2s4: "C", r0: "A", r1: "A", r2: "A" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { const pk = P2.picks["p" + pi + "s" + k]; if (pk) st.options = st.options.filter((o) => o.key === pk); }));
P2.retrofits.forEach((rf, ri) => { const pk = P2.picks["r" + ri]; if (pk) rf.options = rf.options.filter((o) => o.key === pk); });
