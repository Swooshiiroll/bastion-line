// ---- Tower art second pass: Mortar Tower (tower 2), round 1 ------------------------------------------------------
// Base: look C Braced Siege Mortar, animation A High Lob. Built as one parametric model from the start, with the Gun
// Turret's lessons (owner, 2026-10-17): options swap parts rather than lay overlays over them; every tube on the mount
// carries the other paths' details and the Retrofit's; each Power step changes the shells.
// Geometry (game px, x along the aim, y to the side): tube from x -1 to its bore at x 9, 11 wide; bore r 6.8; four
// braced legs on the diagonals (r 15); recoil spade at x -10; octagonal mount r 8.5.
const PAGE = { title: "Mortar Tower: paths and Retrofits (second pass)", store: "bl-tower-art-p2-mortar-r2" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], COPPER = [0.78, 0.5, 0.28, 1], RED = [0.85, 0.2, 0.18, 1];
const DARKSHELL = [0.2, 0.2, 0.22, 1], YEL = [1, 0.85, 0.2, 1], SMOKE = [0.6, 0.62, 0.64, 1], SAND = [0.62, 0.55, 0.4, 1];
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null); // the option used at path pi, step k (or null)

// ---- Tubes: count and layout from Speed/Range (path 2); length from its steps 2 and 4 ---------------------------
function tubesOf(B) { const S = B.lv[1];
  if (S >= 5) { const st = Kp(B, 1, 4); if (st === "B") return { w: 7, pos: [[3, 0], [-3, -6.5], [-3, 6.5]] };
    if (st === "C") return { w: 7, pos: [0, 1, 2].map((i) => [Math.cos(i * TAU / 3) * 5.5, Math.sin(i * TAU / 3) * 5.5]), revolver: true };
    return { w: 7, pos: [[0, -8.5], [0, 0], [0, 8.5]] }; }
  if (S >= 3) { const st = Kp(B, 1, 2); if (st === "B") return { w: 8.6, pos: [[2, -4], [-3, 4]] }; return { w: 8.6, pos: [[0, -5.5], [0, 5.5]], cradle: st === "C" }; }
  return { w: 11, pos: [[0, 0]] }; }
const tubeLen = (B) => 9 + (B.lv[1] >= 2 ? ({ A: 3, B: 2.5, C: 1.5 }[Kp(B, 1, 1)] || 0) : 0) + (B.lv[1] >= 4 ? 2.5 : 0);
// The revolver battery turns a third of a turn per shot (shots = how many it has fired).
function tubeAt(T, i, shots) { let [x, y] = T.pos[i]; if (T.revolver) { const q = rot([x, y], (shots || 0) * TAU / 3); x = q[0]; y = q[1]; } return [x, y]; }

// ---- Shells: one look per Power step (and the Blast path's fat or fragmentation shells) --------------------------
function mortarShell(f, to, u, s, col, B, info) { const k = G(s), arcH = (h) => Math.sin(Math.PI * h) * s * 0.85, p0 = lerp(f, to, u), p = add(p0, [0, -arcH(u)]);
  const pb = add(lerp(f, to, Math.max(0, u - 0.03)), [0, -arcH(Math.max(0, u - 0.03))]), dir = Math.atan2(p[1] - pb[1], p[0] - pb[0]), d = fa(dir);
  const P1 = Kp(B, 0, 0), P2s = Kp(B, 0, 1), P3 = Kp(B, 0, 2), P4 = Kp(B, 0, 3), PM = Kp(B, 0, 4), X1 = Kp(B, 2, 0), X2 = Kp(B, 2, 1), X3 = Kp(B, 2, 2);
  const smoky = B.r === 2 && info && info.sh && info.sh.m % 4 === 0;
  const z = (P1 === "B" ? 1.2 : 1) * (X1 === "B" ? 1.2 : 1), r = 2.6 * k * z;
  ellipse(p0, 3 * k * z, 1.5 * k * z, [0, 0, 0, 0.3]);
  if (P2s === "C") for (let i = 4; i >= 1; i--) { const v = Math.max(0, u - i * 0.03); disc(add(lerp(f, to, v), [0, -arcH(v)]), (0.8 + i * 0.3) * k, A(RED, 0.4 - 0.08 * i)); }
  const body = B.lv[2] >= 5 ? GOLD : smoky ? SMOKE : P3 ? DARKSHELL : METAL_L;
  if (P4 === "B" || PM) for (const sg of [-1, 1]) fill(p, [[-0.6, sg * 0.8], [-1.8, sg * 1.8], [-1.8, sg * 0.8]].map((q) => mul(q, z)), STEEL, dir, k);
  if (P2s === "A" || PM === "A") fill(add(p, mul(d, r * 0.7)), [[1.6, 0], [0, 1], [0, -1]].map((q) => mul(q, z)), PM === "A" ? GOLD : STEEL, dir, k);
  orb(p, r, body);
  if (P1 === "A") ring(p, r * 0.75, RED, 0.9 * k);
  if (P2s === "B") ring(p, r * 0.95, COPPER, 0.8 * k);
  if (P3) line(add(p, mul(orth(d), r * 0.9)), add(p, mul(orth(d), -r * 0.9)), smoky ? [0.4, 0.4, 0.4, 1] : YEL, 0.9 * k);
  if (PM) ring(p, r * 0.55, GOLD, 0.8 * k);
  if (B.r === 2) ring(p, r * 0.85, [0.42, 0.42, 0.44, 1], 0.9 * k); // the smoke-shell band on every shell
  if (X2 === "B") for (let i = 0; i < 3; i++) line(add(p, mul(fa(i * 1.05 + 0.5), r * 0.3)), add(p, mul(fa(i * 1.05 + 0.5), r * 0.95)), [0, 0, 0, 0.45], 0.6 * k);
  if (X3 === "A") line(add(p, mul(d, -r)), add(p, mul(d, r)), [0, 0, 0, 0.5], 0.7 * k);
  const blink = P4 === "A" || P4 === "C" ? fmod(u * 8, 1) < 0.5 : true;
  glowDot(p, (P1 === "C" ? 1.6 : 1.1) * k, blink ? (P1 === "C" ? [1, 0.6, 0.25, 1] : col) : A(col, 0.3));
  // The Blast path's dispenser nose / airburst: the shell opens at the top of its arc and drops its bomblets.
  if ((X3 === "C" || Kp(B, 2, 4) === "C") && u > 0.5) { const n = bombletsOf(B), w = (u - 0.5) / 0.5;
    for (let i = 0; i < n; i++) { const off = bombletOff(i, n, s, B), q = lerp(add(p, [0, 0]), add(to, off), w); disc(q, 1.1 * k, OUTLINE); disc(q, 0.8 * k, METAL_L); } } }

// ---- Impacts: blast size from the Blast path, bomblets, delayed fuses, the Bunker Buster, smoke ------------------
const BLAST_PX = [60, 70, 80, 80, 85, 90];
const bombletsOf = (B) => [0, 0, 0, 4, 6, 8][B.lv[2]];
const bombletOff = (i, n, s, B) => mul(fa(i * TAU / n + 0.4), s * (B.lv[2] >= 5 ? 0.62 : 0.45));
function mortarImpact(to, v, s, col, info, B) { const k = G(s), size = 0.45 * BLAST_PX[B.lv[2]] / 60, P4 = Kp(B, 0, 3), PM = Kp(B, 0, 4);
  let w = v; if (P4 === "A" || P4 === "C") { if (v < 0.2) { disc(to, s * 0.08, [0.35, 0.3, 0.25, 0.8]); glowDot(to, s * 0.03, fmod(v * 20, 1) < 0.5 ? [1, 0.3, 0.2, 1] : A(col, 0.3)); return; } w = (v - 0.2) / 0.8; }
  if (PM === "A") { if (w < 0.25) { ring(to, s * 0.12, [0.45, 0.38, 0.3, 1 - w * 4], 2); for (let i = 0; i < 6; i++) disc(add(to, mul(fa(i), s * 0.1)), 1.4, [0.45, 0.38, 0.3, 1]); return; } w = (w - 0.25) / 0.75; }
  blast(to, w, s, col, size);
  if (PM === "B" && w < 1) { ring(to, s * (0.4 + w * 1.4), A(GOLD, 0.5 * (1 - w)), 1.6); ring(to, s * (0.2 + w * 1.0), A(GOLD, 0.5 * (1 - w)), 1); }
  if (PM === "C" && w < 1) for (let i = 0; i < 6; i++) { const a = i * TAU / 6 + 0.3; polyline([to, add(to, mul(fa(a), s * 0.3 * Math.min(1, w * 3))), add(to, mul(fa(a + 0.3), s * 0.45 * Math.min(1, w * 3)))], [0.15, 0.12, 0.1, 1 - w], 1.2); }
  const n = bombletsOf(B); if (n) for (let i = 0; i < n; i++) { const q = add(to, bombletOff(i, n, s, B)), bw = (w - 0.12 - i * 0.02) / 0.6; if (bw > 0 && bw < 1) blast(q, bw, s, col, B.lv[2] >= 5 ? 0.24 : 0.2); else if (bw <= 0 && Kp(B, 2, 2) !== "C") disc(lerp(to, q, Math.max(0, w * 4)), 1.3, METAL_L); }
  if (B.r === 2 && info && info.sh && info.sh.m % 4 === 0) for (let i = 0; i < 5; i++) disc(add(to, mul(fa(i * 1.3), s * 0.18 * Math.min(1, v * 3))), s * (0.14 + 0.06 * Math.sin(i)), A(SMOKE, 0.45 * (1 - v * 0.6))); }

// ---- The model ---------------------------------------------------------------------------------------------------
function rack(c, aim, k, x, y, n, shellCol, band, vertical, nose) { plate(P(c, aim, k, x, y), rectPts(vertical ? 1.8 : n * 1.6 + 0.6, vertical ? n * 1.6 + 0.6 : 1.8), METAL_D, aim, k, 0.9);
  for (let i = 0; i < n; i++) { const q = vertical ? P(c, aim, k, x, y + (i - (n - 1) / 2) * 3) : P(c, aim, k, x + (i - (n - 1) / 2) * 3, y); orb(q, 1.3 * k, shellCol); if (band) ring(q, 0.8 * k, band, 0.7 * k); if (nose) disc(add(q, [0.5 * k, -0.5 * k]), 0.55 * k, [0.66, 0.69, 0.74, 1]); } }
// The mouth of an angled tube seen from above: an ellipse squashed along the aim (the opening faces up and forward).
function ell(p, rx, ry, a, col, w) { X.strokeStyle = css(col); X.lineWidth = w; X.beginPath(); X.ellipse(p[0], p[1], Math.max(0.1, rx), Math.max(0.1, ry), a, 0, TAU); X.stroke(); }
const MOUTH = 0.85, RX = 1.4; // RX widens the mouth along the aim, near round like the original // mouth size relative to the old round bore, so the rim sits just outside the tube's sides
function bore(p, k, f0, col, fx, B, flash, aim) { const f = f0 * MOUTH; const PM = Kp(B, 0, 4), X1 = Kp(B, 2, 0), P2s = Kp(B, 0, 1), S2 = Kp(B, 1, 1), sq = 0.58;
  oval(p, 3.9 * RX * k * f, 6.9 * k * f, aim, METAL_L, 1.2); oval(add(p, mul(LIGHT, 0.4 * k)), 3.5 * k * f, 6.2 * k * f, aim, lt(METAL_L, 0.12));
  if (X1 === "A") ell(p, 3.6 * RX * k * f, 6.4 * k * f, aim, STEEL, 1.6 * k);
  if (S2 === "C") for (let i = 0; i < 8; i++) { const an = i * TAU / 8, q0 = add(p, rot([Math.cos(an) * 2.7 * RX * k * f, Math.sin(an) * 4.6 * k * f], aim)), q1 = add(p, rot([Math.cos(an) * 3.6 * RX * k * f, Math.sin(an) * 6.3 * k * f], aim)); line(q0, q1, [0, 0, 0, 0.5], 1 * k); }
  if (PM === "B" || B.lv[1] >= 5) ell(p, 3.5 * RX * k * f, 6.1 * k * f, aim, GOLD, 1.2 * k);
  oval(p, 2.6 * RX * k * f, 4.5 * k * f, aim, BORE); if (P2s === "B") ell(p, 2.3 * RX * k * f, 3.9 * k * f, aim, COPPER, 0.9 * k);
  oval(p, 1.9 * RX * k * f, 3.3 * k * f, aim, A(col, 0.25 + 0.75 * flash)); if (flash > 0) glowDot(p, 3.2 * k * f * flash, col); }
// The tube, as the original draws it: one shaded barrel with a rounded back end (bar), plus trunnion pins and a slight
// flare band near the mouth. Its shadow is drawn separately, on the deck under the mount (tubeShadow).
function tubeShadow(c, aim, k, x, y, L, w) { const x0 = x - 1, x1 = x + L;
  line(add(P(c, aim, k, x0, y), [k, 2 * k]), add(P(c, aim, k, x1, y), [3 * k, 5 * k]), [0, 0, 0, 0.22], w * k); }
function angledTube(c, aim, k, x, y, L, w, r) { const x0 = x - 1 - r, x1 = x + L - r;
  bar(P(c, aim, k, x0, y), P(c, aim, k, x1, y), w * k, METAL_L);
  bar(P(c, aim, k, x1 - 2.2, y - w * 0.56), P(c, aim, k, x1 - 2.2, y + w * 0.56), 1.6 * k, lt(METAL_L, 0.08)); // flare band
  for (const sg of [-1, 1]) { const tp = P(c, aim, k, x0 + (L + 1) * 0.3, y + sg * (w * 0.5 + 0.9)); disc(tp, 1.6 * k, OUTLINE); disc(tp, 1.2 * k, STEEL); } } // trunnion pins

const P2 = {
  tower: "mortar", look: "C", anim: "A",
  intro: "Round 1: three options for every step and Retrofit, drawn as one model so the paths combine (the Gun Turret's lessons): extra tubes carry every detail, options swap parts instead of covering them, and each Power step changes the shells. Unpicked steps show option A.",
  mods(B) { const T = tubesOf(B), n = T.pos.length, rate = [0.6, 0.7, 0.7, 1.2, 1.3, 1.7][B.lv[1]], period = Math.max(0.9, 2.2 * 0.6 / rate * n);
    return { period, burst: n, gap: n > 1 ? period / n * 0.6 : undefined, multi: false,
      shot: (f, to, u, s, col, kk, t, info) => { if (u < 0.35) smokePuff(f, u / 0.35, s, 0.5); mortarShell(f, to, u, s, col, B, info); },
      impact: (to, v, s, col, info) => mortarImpact(to, v, s, col, info, B) }; },
  muzzleAt(B, m, kk, c, aim, s, info) { const T = tubesOf(B), k = G(s), i = kk % T.pos.length, L = tubeLen(B), [x, y] = tubeAt(T, i, m + 1); return P(c, aim, k, x + L, y); },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), T = tubesOf(B), n = T.pos.length, L = tubeLen(B), f = T.w / 11, last = ((fx.shots || 1) - 1) % n;
    deck(c, k, col, t);
    // Only the barrel turns (owner, round 2): no legs, mount plate or recoil spade; the kit sits in fixed spots.
    for (let i = 0; i < n; i++) { const [x, y] = tubeAt(T, i, fx.shots); tubeShadow(c, aim, k, x, y, L, 11 * f); }
    const S = (x, y) => P(c, 0, k, x, y); // a fixed deck position
    // Racks show the current shells: Power restyles the shells in any rack on the tower instead of adding its own
    // racks (owner: x/1/0); Power's own rack appears only when there's no other rack.
    const shellRack = B.lv[2] >= 5 ? GOLD : B.lv[0] >= 3 ? DARKSHELL : METAL_L, band = B.r === 2 ? [0.42, 0.42, 0.44, 1] : B.lv[0] >= 3 ? YEL : null, nose = B.lv[0] >= 2;
    const ready = B.lv[1] >= 1, field = B.r === 0;
    if (ready) rack(c, 0, k, -12.5, 4.5, 3, shellRack, band, true, nose);
    if (field) { plate(S(0, -12.5), rectPts(5.4, 2.4), [0.5, 0.42, 0.28, 1], 0, k, 1); rack(c, 0, k, 0, -12.5, 3, shellRack, band, false, nose); }
    if (!ready && !field && B.lv[0] >= 2) rack(c, 0, k, -12.5, -4.5, B.lv[0] >= 3 ? 3 : 2, shellRack, band, true, nose);
    if (B.lv[2] >= 3) { const bc = B.lv[2] >= 5 ? GOLD : [0.5, 0.52, 0.48, 1]; rack(c, 0, k, 12.5, -4.5, 3, bc, null, true); if (B.lv[2] >= 4) rack(c, 0, k, 12.5, 4.5, 3, bc, null, true); }
    if (B.r === 1) { const q = S(10, -11); bar(q, S(10, -7.5), 1 * k, METAL_L); glowDot(q, (fmod(t * 1.2, 1) < 0.3 ? 1 : 0.5) * k, [0.4, 1, 0.5, 1]); ring(q, fmod(t, 1) * 5 * k, A([0.4, 1, 0.5, 1], 0.5 * (1 - fmod(t, 1))), 1); }
    if (T.cradle) plate(c, rectPts(4, 9.5), METAL_L, aim, k, 1); // the twin cradle turns with the tubes
    // The tubes, each with the same kit; the one that fired last recoils.
    for (let i = 0; i < n; i++) { const [x, y] = tubeAt(T, i, fx.shots), r = (i === last ? decay(fx.barrelSince ?? 9, 0.3) : 0) * 2.5, w = 11 * f;
      angledTube(c, aim, k, x, y, L, w, r);
      const tb = (fr) => P(c, aim, k, x - 1 + (L + 1) * fr - r, y);
      const em = (an, rr) => add(tb(1), rot([Math.cos(an) * rr * 0.58 * RX * MOUTH, Math.sin(an) * rr * MOUTH], aim)); // a point on the mouth's ellipse
      if (Kp(B, 0, 0) === "A") for (const fr of [0.35, 0.6]) line(add(tb(fr), mul(orth(fa(aim)), w * 0.5 * k)), add(tb(fr), mul(orth(fa(aim)), -w * 0.5 * k)), RED, 1.1 * k);
      if (Kp(B, 0, 2) === "A") line(add(tb(0.45), mul(orth(fa(aim)), w * 0.5 * k)), add(tb(0.45), mul(orth(fa(aim)), -w * 0.5 * k)), YEL, 1.2 * k);
      if (Kp(B, 0, 2) === "B") plate(tb(0.08), rectPts(1.6, w * 0.55), STEEL, aim, k, 1);
      if (Kp(B, 0, 3) === "A") { plate(add(tb(0.4), mul(orth(fa(aim)), -w * 0.62 * k)), rectPts(1.4, 1), METAL_D, aim, k, 0.8); glowDot(add(tb(0.4), mul(orth(fa(aim)), -w * 0.62 * k)), 0.5 * k, fmod(t * 2, 1) < 0.5 ? RED : A(RED, 0.3)); }
      if (Kp(B, 0, 3) === "C") line(P(c, aim, k, -6, -9), tb(0.3), [0.12, 0.12, 0.14, 1], 0.6 * k);
      if (Kp(B, 0, 4) === "A") line(add(tb(0.25), mul(orth(fa(aim)), w * 0.5 * k)), add(tb(0.25), mul(orth(fa(aim)), -w * 0.5 * k)), GOLD, 1.2 * k);
      if (Kp(B, 1, 1) === "B") for (const fr of [0.72, 0.84]) line(add(tb(fr), mul(orth(fa(aim)), w * 0.5 * k)), add(tb(fr), mul(orth(fa(aim)), -w * 0.5 * k)), METAL_D, 1 * k);
      if (Kp(B, 1, 3) === "B") for (const fr of [0.5, 0.62]) line(add(tb(fr), mul(orth(fa(aim)), w * 0.56 * k)), add(tb(fr), mul(orth(fa(aim)), -w * 0.56 * k)), STEEL, 1.4 * k);
      if (Kp(B, 2, 1) === "B") for (let j = 1; j < 4; j++) line(tb(j * 0.22), tb(j * 0.22 + 0.08), [0, 0, 0, 0.35], w * 0.9 * k);
      if (Kp(B, 2, 1) === "C") hazard(c, aim, k, x - r + 1, x - r + 4, y + w * 0.5, [1, 0.55, 0.2, 1], 0.9);
      if (B.lv[2] >= 5 && Kp(B, 2, 4) === "B") for (const fr of [0.3, 0.55]) line(add(tb(fr), mul(orth(fa(aim)), w * 0.5 * k)), add(tb(fr), mul(orth(fa(aim)), -w * 0.5 * k)), GOLD, 1 * k);
      if (Kp(B, 0, 1) === "C") glowDot(add(tb(1), mul(orth(fa(aim)), w * 0.55 * k)), 0.6 * k, RED);
      if (Kp(B, 2, 3) === "C") for (let j = 0; j < 4; j++) { const a = Math.PI / 4 + j * Math.PI / 2; line(em(a, 5.6 * k * f), em(a, 8.2 * k * f), METAL_L, 1 * k); }
      if (Kp(B, 2, 2) === "C") for (let j = 0; j < 3; j++) disc(em(j * TAU / 3 + 0.5, 6.6 * k * f), 1 * k, METAL_D);
      if (Kp(B, 1, 3) === "C") for (const sg of [-1, 1]) bar(tb(0.7), add(tb(0.4), mul(orth(fa(aim)), sg * w * 0.8 * k)), 0.9 * k, STEEL);
      if (B.r === 0 && i === 0) bar(add(tb(0.3), mul(orth(fa(aim)), -w * 0.55 * k)), add(tb(0.75), mul(orth(fa(aim)), -w * 0.55 * k)), 1.1 * k, METAL_D);
      if (Kp(B, 0, 0) === "B") ell(tb(1), 4.1 * RX * k * f * MOUTH, 7.1 * k * f * MOUTH, aim, STEEL, 1.8 * k);
      if (Kp(B, 0, 3) === "B") for (let j = 0; j < 4; j++) { const a = j * Math.PI / 2; line(em(a, 4.6 * k * f), em(a, 6.4 * k * f), [0, 0, 0, 0.5], 0.8 * k); }
      bore(tb(1), k, f, col, fx, B, i === last ? fx.flash : 0, aim); }
    // The Loader Arm swings to the bore after each shot; the Bunker Sight's periscope; the twin cradle's sight.
    if (Kp(B, 1, 0) === "B") { const sw = decay(fx.barrelSince ?? 9, 0.6), a = aim + Math.PI * 0.75 - sw * 1.2, base = P(c, aim, k, -4, 8); orb(base, 1.6 * k, METAL); bar(base, add(base, mul(fa(a), 9 * k)), 1.4 * k, METAL_L); }
    if (T.cradle) { orb(P(c, aim, k, -4, 0), 1.6 * k, METAL); glowDot(P(c, aim, k, -3.4, 0), 0.6 * k, col); }
  },
  paths: [
    { name: "Power/Penetration", theme: "harder-hitting, armour-piercing shells; each step changes the shells", steps: [
      { name: "HE Charge", cost: 80, effect: "+8 damage", options: [
        { key: "A", name: "Red HE Bands", desc: "Red bands round each tube; shells carry a red HE band." },
        { key: "B", name: "Reinforced Collar", desc: "A thick steel collar round each bore; shells are a size bigger." },
        { key: "C", name: "Charge Bags", desc: "Propellant bags stacked by the mount; shells glow hotter orange." } ] },
      { name: "Shaped Charge", cost: 95, effect: "Shells ignore 25% of armour", options: [
        { key: "A", name: "Pointed Shells", desc: "A rack of steel-nosed shells by the mount; shells fly with a pointed nose." },
        { key: "B", name: "Copper Liner", desc: "A copper liner ring inside each bore; shells get a copper rim." },
        { key: "C", name: "Tracer Tail", desc: "A red tracer lamp on each tube mouth; shells trail red." } ] },
      { name: "AP Shells", cost: 685, effect: "Ignore 50% of armour; +10 damage (primary)", options: [
        { key: "A", name: "Hardened Shells", desc: "A yellow AP band painted on each tube; shells turn dark with a yellow band." },
        { key: "B", name: "Armoured Breech", desc: "An armour block at the base of each tube; dark yellow-banded shells." },
        { key: "C", name: "AP Rack", desc: "A rack of dark yellow-banded AP shells by the mount; the same shells fly." } ] },
      { name: "Delayed Fuse", cost: 1350, effect: "Ignore 75% of armour; +8 damage", options: [
        { key: "A", name: "Fuse Timer", desc: "A blinking timer box on each tube; shells blink and burst a beat after landing." },
        { key: "B", name: "Tail Fins", desc: "Fin-guide slots at each mouth; shells fly with tail fins." },
        { key: "C", name: "Fuse Wires", desc: "A fuse box wired to every tube; shells blink and burst a beat after landing." } ] },
      { name: "Bunker Buster", cost: 3140, effect: "64 damage; ignores 75% of armour; hits burrowed enemies (mastery)", options: [
        { key: "A", name: "Drill Shells", desc: "Gold bands on the tubes; gold drill-tipped shells dig in, throw up dirt, then erupt." },
        { key: "B", name: "Gold Bore Rings", desc: "Gold rims on every bore; finned shells hit with a gold seismic ring." },
        { key: "C", name: "Bunker Ram", desc: "A gold-trimmed ram plate on the back; finned shells crack the ground on impact." } ] },
    ] },
    { name: "Speed/Range", theme: "more tubes, more reach", steps: [
      { name: "Quick Reload", cost: 50, effect: "0.6 to 0.7 shells/s", options: [
        { key: "A", name: "Shell Hopper", desc: "An ammo hopper of ready shells at the back left." },
        { key: "B", name: "Loader Arm", desc: "A loader arm that swings to the bore after each shot." },
        { key: "C", name: "Ready Rack", desc: "A rack of three shells on the recoil spade." } ] },
      { name: "Extended Tube", cost: 125, effect: "+20 range (130)", options: [
        { key: "A", name: "Longer Tubes", desc: "The tubes are swapped for longer ones (the bores move forward)." },
        { key: "B", name: "Tube Sleeves", desc: "A banded extension sleeve on each tube." },
        { key: "C", name: "Muzzle Brakes", desc: "A slotted muzzle-brake ring round each bore." } ] },
      { name: "Twin Tubes", cost: 1170, effect: "A second tube firing in succession: 1.2 shells/s (primary)", options: [
        { key: "A", name: "Side by Side", desc: "Two tubes side by side, firing one after the other." },
        { key: "B", name: "Staggered Pair", desc: "Two tubes staggered, one forward and one back." },
        { key: "C", name: "Twin Cradle", desc: "Two tubes on a shared cradle with a sight between them." } ] },
      { name: "Long Tubes", cost: 1405, effect: "+20 range (150); 1.3 shells/s", options: [
        { key: "A", name: "Even Longer", desc: "Longer tubes again." },
        { key: "B", name: "Cooling Rings", desc: "Longer tubes with heavy cooling rings." },
        { key: "C", name: "Brace Struts", desc: "Longer tubes braced by struts to the legs." } ] },
      { name: "Barrage Battery", cost: 6165, effect: "Three tubes firing in succession: 1.7 shells/s, 165 range (mastery)", options: [
        { key: "A", name: "Triple Row", desc: "Three tubes in a row." },
        { key: "B", name: "Triangle Cluster", desc: "Three tubes in a triangle." },
        { key: "C", name: "Revolver Battery", desc: "Three tubes on a gold-ringed carousel that turns a third of a turn per shot." } ] },
    ] },
    { name: "Blast Radius/Multi-Target", theme: "bigger blasts, then cluster shells", steps: [
      { name: "Bigger Charge", cost: 30, effect: "Blast 60 to 70 px", options: [
        { key: "A", name: "Wide Bore Rims", desc: "Thicker steel rims round each bore; bigger blasts." },
        { key: "B", name: "Fat Shells", desc: "Fatter shells; bigger blasts." },
        { key: "C", name: "Blast Plates", desc: "Blast deflector plates on both sides of the mount; bigger blasts." } ] },
      { name: "Wide Burst", cost: 60, effect: "Blast 80 px", options: [
        { key: "A", name: "Burst Charge Box", desc: "An orange-striped charge box by the mount." },
        { key: "B", name: "Fragmentation Sleeves", desc: "Segmented sleeves on the tubes; shells show a fragmentation pattern." },
        { key: "C", name: "Orange Bands", desc: "Orange hazard bands on each tube." } ] },
      { name: "Cluster Shells", cost: 1110, effect: "4 bomblets around each impact (primary)", options: [
        { key: "A", name: "Cluster Canisters", desc: "A rack of seamed canister shells; on impact 4 bomblets scatter out and burst." },
        { key: "B", name: "Bomblet Rack", desc: "A rack of bomblets by the mount; 4 bomblets scatter and burst." },
        { key: "C", name: "Dispenser Nose", desc: "Clamps round each bore; shells open at the top of the arc and drop 4 bomblets." } ] },
      { name: "Dense Cluster", cost: 1230, effect: "6 bomblets; blast 85 px", options: [
        { key: "A", name: "Bigger Canisters", desc: "A bigger canister rack; 6 bomblets." },
        { key: "B", name: "Second Rack", desc: "A second bomblet rack; 6 bomblets." },
        { key: "C", name: "Spread Vanes", desc: "Spreader vanes at each bore; 6 bomblets." } ] },
      { name: "Carpet Shells", cost: 5000, effect: "8 bomblets of 12 damage, spread wider; blast 90 px (mastery)", options: [
        { key: "A", name: "Gold Canisters", desc: "Gold canister shells; 8 bomblets carpet a wider ring." },
        { key: "B", name: "Gold-Banded Tubes", desc: "Gold bands on every tube; 8 bomblets, spread wider." },
        { key: "C", name: "Airburst Dispenser", desc: "Shells burst high over the target and rain 8 bomblets across a wide ring." } ] },
    ] },
  ],
  retrofits: [
    { name: "Field Kit", cost: 120, effect: "+4 damage, +10 range, +0.05 shells/s, +5 px blast", options: [
      { key: "A", name: "Sandbag Ring", desc: "A ring of sandbags round the deck, a sight on the tube and a rack of ready shells." },
      { key: "B", name: "Steel Baseplate", desc: "A heavy steel baseplate under the mount, a sight and a shell rack." },
      { key: "C", name: "Field Crate", desc: "A field crate with a shell rack, and a sight on the tube." } ] },
    { name: "Bunker Sight", cost: 15, effect: "Targets burrowed enemies inside Radar range, at half damage", options: [
      { key: "A", name: "Periscope", desc: "A periscope sight on the mount." },
      { key: "B", name: "Seismic Probe", desc: "A probe spike that pulses green rings into the ground." },
      { key: "C", name: "Sensor Dish", desc: "A small turning sensor dish." } ] },
    { name: "Smoke Shells", cost: 15, effect: "Every 4th shell leaves a smoke cloud (3 s, 15% slow)", options: [
      { key: "A", name: "Grey-Banded Shells", desc: "Grey smoke shells in a rack; every 4th shell flies grey and leaves a smoke cloud." },
      { key: "B", name: "Smoke Canisters", desc: "Smoke canisters strapped to the mount; every 4th shell leaves a smoke cloud." },
      { key: "C", name: "Launcher Cups", desc: "Two smoke launcher cups on the mount; every 4th shell leaves a smoke cloud." } ] },
  ],
};

// ---- Round 2 (owner's picks and notes, 2026-10-17): each stage shows only the pick, re-described where a note changed it.
P2.intro = "Round 2: your picks drawn as one model with your notes applied. Only the barrel turns now (no legs, mount plate or spade); racks show the current shells; Speed's mastery gets gold muzzles; Blast's mastery gold shells; Smoke Shells band every shell. Use the build preview to check combinations.";
P2.picks = { p0s0: "B", p0s1: "A", p0s2: "C", p0s3: "A", p0s4: "B", p1s0: "C", p1s1: "A", p1s2: "C", p1s3: "A", p1s4: "B", p2s0: "B", p2s1: "B", p2s2: "B", p2s3: "B", p2s4: "A", r0: "C", r1: "B" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { st.options = st.options.filter((o) => o.key === P2.picks["p" + pi + "s" + k]); }));
P2.retrofits.forEach((rf, ri) => { if (P2.picks["r" + ri]) rf.options = rf.options.filter((o) => o.key === P2.picks["r" + ri]); });
const RE = (pi, k, desc) => { P2.paths[pi].steps[k].options[0].desc = desc; };
RE(0, 1, "Pointed steel-nosed shells. They restyle the shells in any rack on the tower (the Ready Rack, the Field Kit's) instead of adding a rack (your note); a rack of their own only when there's none.");
RE(0, 2, "Dark yellow-banded AP shells, in flight and in every rack (no extra rack when one is fitted).");
RE(1, 0, "A rack of three ready shells in a fixed spot on the deck (the spade is gone); it shows the current shells.");
RE(1, 4, "Three tubes in a triangle, with gold muzzle rims as at Power's mastery (your note).");
RE(2, 2, "A rack of bomblets in a fixed spot on the deck; 4 bomblets scatter and burst.");
RE(2, 3, "A second bomblet rack beside the first; 6 bomblets.");
RE(2, 4, "Gold shells in flight (your note) and gold canisters in the racks; 8 bomblets carpet a wider ring.");
P2.retrofits[0].options[0].desc = "A field crate with a shell rack in a fixed spot on the deck, and a sight on the tube.";
P2.retrofits[1].options[0].desc = "A probe spike in a fixed spot on the deck, pulsing green rings into the ground.";
P2.retrofits[2].options = [{ key: "A", name: "Smoke-Banded Shells", desc: "From your note: every shell, in flight and in the racks, carries the grey smoke band; every 4th leaves a smoke cloud." }];
