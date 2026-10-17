// ---- Tower art second pass: Mortar Tower (tower 2), round 1 ------------------------------------------------------
// Base: look C Braced Siege Mortar, animation A High Lob. Built as one parametric model from the start, with the Gun
// Turret's lessons (owner, 2026-10-17): options swap parts rather than lay overlays over them; every tube on the mount
// carries the other paths' details and the Retrofit's; each Power step changes the shells.
// Geometry (game px, x along the aim, y to the side): tube from x -1 to its bore at x 9, 11 wide; bore r 6.8; four
// braced legs on the diagonals (r 15); recoil spade at x -10; octagonal mount r 8.5.
const PAGE = { title: "Mortar Tower: paths and Retrofits (second pass)", store: "bl-tower-art-p2-mortar-r1c" };
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
  const body = smoky ? SMOKE : P3 ? DARKSHELL : METAL_L;
  if (P4 === "B" || PM) for (const sg of [-1, 1]) fill(p, [[-0.6, sg * 0.8], [-1.8, sg * 1.8], [-1.8, sg * 0.8]].map((q) => mul(q, z)), STEEL, dir, k);
  if (P2s === "A" || PM === "A") fill(add(p, mul(d, r * 0.7)), [[1.6, 0], [0, 1], [0, -1]].map((q) => mul(q, z)), PM === "A" ? GOLD : STEEL, dir, k);
  orb(p, r, body);
  if (P1 === "A") ring(p, r * 0.75, RED, 0.9 * k);
  if (P2s === "B") ring(p, r * 0.95, COPPER, 0.8 * k);
  if (P3) line(add(p, mul(orth(d), r * 0.9)), add(p, mul(orth(d), -r * 0.9)), smoky ? [0.4, 0.4, 0.4, 1] : YEL, 0.9 * k);
  if (PM) ring(p, r * 0.55, GOLD, 0.8 * k);
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
function rack(c, aim, k, x, y, n, shellCol, band, vertical) { plate(P(c, aim, k, x, y), rectPts(vertical ? 1.8 : n * 1.6 + 0.6, vertical ? n * 1.6 + 0.6 : 1.8), METAL_D, aim, k, 0.9);
  for (let i = 0; i < n; i++) { const q = vertical ? P(c, aim, k, x, y + (i - (n - 1) / 2) * 3) : P(c, aim, k, x + (i - (n - 1) / 2) * 3, y); orb(q, 1.3 * k, shellCol); if (band) disc(q, 0.5 * k, band); } }
// The mouth of an angled tube seen from above: an ellipse squashed along the aim (the opening faces up and forward).
function ell(p, rx, ry, a, col, w) { X.strokeStyle = css(col); X.lineWidth = w; X.beginPath(); X.ellipse(p[0], p[1], Math.max(0.1, rx), Math.max(0.1, ry), a, 0, TAU); X.stroke(); }
const MOUTH = 0.84; // mouth size relative to the old round bore, so the rim sits just outside the tube's sides
function bore(p, k, f0, col, fx, B, flash, aim) { const f = f0 * MOUTH; const PM = Kp(B, 0, 4), X1 = Kp(B, 2, 0), P2s = Kp(B, 0, 1), S2 = Kp(B, 1, 1), sq = 0.58;
  oval(p, 3.9 * k * f, 6.9 * k * f, aim, METAL_L, 1.2); oval(add(p, mul(LIGHT, 0.4 * k)), 3.5 * k * f, 6.2 * k * f, aim, lt(METAL_L, 0.12));
  if (X1 === "A") ell(p, 3.6 * k * f, 6.4 * k * f, aim, STEEL, 1.6 * k);
  if (S2 === "C") for (let i = 0; i < 8; i++) { const an = i * TAU / 8, q0 = add(p, rot([Math.cos(an) * 2.7 * k * f, Math.sin(an) * 4.6 * k * f], aim)), q1 = add(p, rot([Math.cos(an) * 3.6 * k * f, Math.sin(an) * 6.3 * k * f], aim)); line(q0, q1, [0, 0, 0, 0.5], 1 * k); }
  if (PM === "B") ell(p, 3.5 * k * f, 6.1 * k * f, aim, GOLD, 1.2 * k);
  oval(p, 2.6 * k * f, 4.5 * k * f, aim, BORE); if (P2s === "B") ell(p, 2.3 * k * f, 3.9 * k * f, aim, COPPER, 0.9 * k);
  oval(p, 1.9 * k * f, 3.3 * k * f, aim, A(col, 0.25 + 0.75 * flash)); if (flash > 0) glowDot(p, 3.2 * k * f * flash, col); }
// An angled tube: it widens toward the raised mouth, with a rounded breech, cylinder shading and a long shadow.
function angledTube(c, aim, k, x, y, L, w, r) { const half = (fr) => w * (0.34 + 0.18 * fr), x0 = x - 6 - r, x1 = x + L - r; // breech low at the back, mouth raised at the front
  const sh = [[x0, -half(0)], [x1, -half(1)], [x1, half(1)], [x0, half(0)]].map(([px, py]) => add(P(c, aim, k, px, py), [k * (1 + 4 * (px - x0) / (L + 6)), k * (2 + 7 * (px - x0) / (L + 6))]));
  poly(sh, [0, 0, 0, 0.28]);
  const body = [[x0, -half(0)], [x1, -half(1)], [x1, half(1)], [x0, half(0)]].map(([px, py]) => P(c, aim, k, px, py)); poly(body, OUTLINE);
  const inset = [[x0 + 0.3, -half(0) + 0.6], [x1, -half(1) + 0.6], [x1, half(1) - 0.6], [x0 + 0.3, half(0) - 0.6]].map(([px, py]) => P(c, aim, k, px, py)); poly(inset, METAL_L);
  const lit = Math.sign(dot(orth(fa(aim)), LIGHT)) || 1; // the side facing the light
  line(P(c, aim, k, x0 + 1, -lit * half(0) * 0.45), P(c, aim, k, x1 - 0.5, -lit * half(1) * 0.45), lt(METAL_L, 0.35), w * 0.18 * k);
  line(P(c, aim, k, x0 + 1, lit * half(0) * 0.6), P(c, aim, k, x1 - 0.5, lit * half(1) * 0.6), dk(METAL_L, 0.3), w * 0.16 * k);
  orb(P(c, aim, k, x0, 0), half(0) * k, dk(METAL_L, 0.05)); // the rounded breech cap
  for (const sg of [-1, 1]) { const tp = P(c, aim, k, x0 + (L + 6) * 0.3, sg * (half(0.3) + 1)); disc(tp, 1.6 * k, OUTLINE); disc(tp, 1.2 * k, STEEL); } } // trunnion pins

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
    // Field Kit: a sandbag ring or a steel baseplate under the mount.
    if (B.r === 0 && B.key("r0") === "A") for (let i = 0; i < 14; i++) { const q = add(c, mul(fa(i * TAU / 14), 17 * k)); shadedOval(q, 2.8 * k, 1.7 * k, i * TAU / 14 + Math.PI / 2, SAND); }
    if (B.r === 0 && B.key("r0") === "B") plate(c, rectPts(15, 15), STEEL, aim, k, 1.2);
    // Legs, foot pads and the recoil spade (with the Ready Rack on it).
    for (let i = 0; i < 4; i++) { const a = Math.PI / 4 + i * Math.PI / 2, ft = P(c, aim, k, Math.cos(a) * 15, Math.sin(a) * 15);
      bar(P(c, aim, k, Math.cos(a) * 6, Math.sin(a) * 6), ft, 3 * k, lt(METAL_D, 0.12)); bar(P(c, aim, k, Math.cos(a) * 7, Math.sin(a) * 7), P(c, aim, k, Math.cos(a) * 11, Math.sin(a) * 11), 1.3 * k, METAL_L);
      plate(ft, rectPts(2, 2), METAL_L, aim, k, 0.9);
      if (Kp(B, 1, 3) === "C") for (const tp of T.pos) bar(P(c, aim, k, tp[0] + 4, tp[1]), P(c, aim, k, Math.cos(a) * 9, Math.sin(a) * 9), 0.9 * k, STEEL); }
    plate(P(c, aim, k, -10, 0), [[1.5, -5], [1.5, 5], [-1.5, 4], [-1.5, -4]], METAL_L, aim, k, 1); hazard(c, aim, k, -11, -9, 0, col, 1);
    if (Kp(B, 1, 0) === "C") rack(c, aim, k, -10, 0, 3, METAL_L, null, true);
    // Power at the back: the Armoured Breech and the Bunker Ram.
    if (Kp(B, 0, 4) === "C") { plate(P(c, aim, k, -13.5, 0), rectPts(1.6, 6.5), STEEL, aim, k, 1.1); outline(P(c, aim, k, -13.5, 0), rectPts(1.3, 5.6), GOLD, 1 * k, aim, k); }
    plate(c, ngon(8, 1, Math.PI / 8), METAL, aim, 8.5 * k, 1.2);
    if (T.cradle) plate(c, rectPts(4, 9.5), METAL_L, aim, k, 1);
    if (T.revolver) { disc(c, 10.5 * k, OUTLINE); disc(c, 9.8 * k, METAL); ring(c, 9.8 * k, GOLD, 1.2 * k); }
    // Mount-side kit: racks, boxes, plates (Power on the left, Blast on the right, Speed and Retrofits at the back).
    if (Kp(B, 0, 0) === "C") for (const x of [4, 8]) { const q = P(c, aim, k, x, -12.5); shadedOval(q, 1.8 * k, 1.4 * k, aim, [0.55, 0.5, 0.36, 1]); }
    if (Kp(B, 0, 1) === "A") rack(c, aim, k, -1, -12.5, 2, STEEL);
    if (Kp(B, 0, 2) === "C") rack(c, aim, k, -1, -12.5, 3, DARKSHELL, YEL);
    if (Kp(B, 0, 3) === "C") { plate(P(c, aim, k, -6, -9), rectPts(1.8, 1.8), METAL_D, aim, k, 0.9); glowDot(P(c, aim, k, -6, -9), 0.6 * k, RED); }
    if (Kp(B, 2, 0) === "C") for (const sg of [-1, 1]) plate(P(c, aim, k, 2, sg * 12.5), [[3, -0.8], [3, 0.8], [-3, 1.2], [-3, -1.2]], STEEL, aim, k, 1);
    if (Kp(B, 2, 1) === "A") { plate(P(c, aim, k, -4, 12), rectPts(2.4, 2), AMMO, aim, k, 1); hazard(c, aim, k, -6, -2, 14.2, [1, 0.55, 0.2, 1], 0.9); }
    if (B.lv[2] >= 3) { const st = Kp(B, 2, 2), gold = B.lv[2] >= 5 && Kp(B, 2, 4) === "A";
      if (st === "A") rack(c, aim, k, 4, 12, B.lv[2] >= 4 && Kp(B, 2, 3) === "A" ? 3 : 2, gold ? GOLD : METAL_L, [0, 0, 0, 0.6]);
      if (st === "B") { rack(c, aim, k, 4, 12, 3, [0.5, 0.52, 0.48, 1]); if (Kp(B, 2, 3) === "B") rack(c, aim, k, 4, 15.4, 3, [0.5, 0.52, 0.48, 1]); } }
    if (Kp(B, 1, 0) === "A") { plate(P(c, aim, k, -6, -10), rectPts(2.6, 2.6), AMMO, aim, k, 1); for (const q of [[-7, -10], [-5, -10]]) orb(P(c, aim, k, ...q), 0.9 * k, METAL_L); }
    if (B.r === 0) { if (B.key("r0") === "C") { plate(P(c, aim, k, -6, 10), rectPts(3, 2.4), [0.5, 0.42, 0.28, 1], aim, k, 1); } rack(c, aim, k, -6, B.key("r0") === "C" ? 13.2 : 10, 3, METAL_L); }
    if (B.r === 1) { const q = P(c, aim, k, -5, 9); const st = B.key("r1");
      if (st === "A") { orb(q, 1.8 * k, METAL); bar(q, P(c, aim, k, -2, 9), 1.2 * k, METAL); glowDot(P(c, aim, k, -1.6, 9), 0.6 * k, col); }
      if (st === "B") { bar(q, P(c, aim, k, -5, 13), 1 * k, METAL_L); glowDot(P(c, aim, k, -5, 13), (fmod(t * 1.2, 1) < 0.3 ? 1 : 0.5) * k, [0.4, 1, 0.5, 1]); for (let i = 1; i <= 2; i++) ring(P(c, aim, k, -5, 13), fmod(t, 1) * 5 * k, A([0.4, 1, 0.5, 1], 0.5 * (1 - fmod(t, 1))), 1); }
      if (st === "C") { const a = t * 2; arc(q, 2.6 * k, a - 1, a + 1, OUTLINE, 2.2 * k); arc(q, 2.6 * k, a - 1, a + 1, METAL_L, 1.3 * k); glowDot(q, 0.6 * k, col); } }
    if (B.r === 2) { const st = B.key("r2");
      if (st === "A") rack(c, aim, k, -6, 10, 3, SMOKE, [0.4, 0.4, 0.4, 1]);
      if (st === "B") for (const y of [8.5, 11.5]) { bar(P(c, aim, k, -8, y), P(c, aim, k, -4, y), 2.4 * k, SMOKE); }
      if (st === "C") for (const y of [8.5, 11.5]) { disc(P(c, aim, k, -6, y), 1.6 * k, OUTLINE); disc(P(c, aim, k, -6, y), 1.2 * k, BORE); } }
    // The tubes, each with the same kit; the one that fired last recoils.
    for (let i = 0; i < n; i++) { const [x, y] = tubeAt(T, i, fx.shots), r = (i === last ? decay(fx.barrelSince ?? 9, 0.3) : 0) * 2.5, w = 11 * f;
      angledTube(c, aim, k, x, y, L, w, r);
      const tb = (fr) => P(c, aim, k, x - 1 + (L + 1) * fr - r, y);
      const em = (an, rr) => add(tb(1), rot([Math.cos(an) * rr * 0.58 * MOUTH, Math.sin(an) * rr * MOUTH], aim)); // a point on the mouth's ellipse
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
      if (Kp(B, 0, 0) === "B") ell(tb(1), 4.1 * k * f * MOUTH, 7.1 * k * f * MOUTH, aim, STEEL, 1.8 * k);
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
