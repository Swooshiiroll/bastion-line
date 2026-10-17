// ---- Tower art second pass: Rocket Salvo (tower 4), round 1 ------------------------------------------------------
// Base: look C Triple Rail Pods, animation A Ripple Salvo. One parametric model with the lessons so far: options swap
// parts; every pod carries the other paths' details; each Power step changes the rockets; deck kit stays put while the
// launcher turns; rockets leave their own tube. The Retrofits are the owner's replacements (2026-10-17): Proximity
// Fuses, Smoke Trails, Incendiary Warheads.
// Geometry (game px, x along the aim): pods from x -8 to their mouths at x 11.5; cross-frame bars at x -4 and 6;
// a hazard-striped blast deflector at x -11.
const PAGE = { title: "Rocket Salvo: paths and Retrofits (second pass)", store: "bl-tower-art-p2-rocket-r3c" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], RED = [0.9, 0.22, 0.2, 1], YEL = [1, 0.85, 0.2, 1], ORANGE = [1, 0.55, 0.2, 1];
const SEEK = [0.35, 0.75, 1, 1], DARKR = [0.22, 0.22, 0.24, 1], PALE = [0.86, 0.88, 0.92, 1], SMOKEC = [0.55, 0.57, 0.6, 1];
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null);
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };

// ---- Numbers --------------------------------------------------------------------------------------------------------
const rocketsOf = (B) => [3, 4, 4, 6, 6, 8][B.lv[2]];
const reloadOf = (B) => [2.5, 2.5, 2, 2, 1.7, 1.7][B.lv[2]];
const blastPx = (B) => [25, 25, 35, 40, 40, 50][B.lv[0]];
const homing = (B) => B.lv[1] >= 2;

// ---- Launch tubes: layout from the Payload path; each entry is a mouth [x, y, r] plus the pod bodies -----------------
function layoutOf(B, t) { const P3 = B.lv[2];
  if (P3 >= 5) { const st = Kp(B, 2, 4);
    if (st === "B") return { pods: [[-7.4, 11], [7.4, 11]], tall: true, mouths: [-1, 1].flatMap((sg) => [[11.5, sg * 5, 1.4, 1], [11.5, sg * 9.8, 1.4, 1], [11.5, sg * 5, 1.4, 0], [11.5, sg * 9.8, 1.4, 0]]), gold: true }; // 2 x 2 per side: [x, y, r, upper?]
    if (st === "C") { const sp = t * 2; return { drum: true, pods: [[0, 12]], mouths: [0, 1, 2, 3, 4, 5, 6, 7].map((i) => [11.5, Math.sin(sp + i * TAU / 8) * 4.8, 1.2]), gold: true }; }
    return { pods: [[0, 23]], mouths: [-10.5, -7.5, -4.5, -1.5, 1.5, 4.5, 7.5, 10.5].map((y, i) => [i % 2 ? 9 : 11, y, 1.3]), gold: true }; }
  if (P3 >= 3) { const st = Kp(B, 2, 2);
    if (st === "B") return { pods: [[-7.2, 11], [7.2, 11]], mouths: [-10.4, -7.2, -4, 4, 7.2, 10.4].map((y) => [11, y, 1.3]) };
    if (st === "C") return { pods: [[0, 12]], mouths: [[11, -6, 1.5], [11, 0, 1.5], [11, 6, 1.5], [8.4, -3, 1.5], [8.4, 3, 1.5], [5.8, 0, 1.5]] };
    return { pods: [[0, 23]], mouths: [-10, -6, -2, 2, 6, 10].map((y) => [11, y, 1.5]) }; }
  if (P3 >= 1) { const st = Kp(B, 2, 0);
    if (st === "B") return { pods: [[-6.5, 5.2], [0, 5.2], [6.5, 5.2]], top: true, mouths: [[11.5, -6.5, 2.1], [11.5, 0, 2.1], [11.5, 6.5, 2.1], [9, 0, 1.3]] };
    if (st === "C") return { pods: [[-6.5, 5.2], [0, 5.2], [6.5, 5.2]], side: true, mouths: [[11.5, -6.5, 2.1], [11.5, 0, 2.1], [11.5, 6.5, 2.1], [8, 11.5, 1.3]] };
    return { pods: [[-8, 5.4], [-2.7, 5.4], [2.7, 5.4], [8, 5.4]], mouths: [-8, -2.7, 2.7, 8].map((y) => [11.5, y, 1.6]) }; }
  return { pods: [[-6.5, 5.2], [0, 5.2], [6.5, 5.2]], mouths: [[11.5, -6.5, 2.1], [11.5, 0, 2.1], [11.5, 6.5, 2.1]] }; }

// ---- The rocket: Power changes the warhead each step; Range adds boosters and seekers; the Retrofit marks it --------
function rocketBody(p, dir, k, col, B, u) { const P1 = Kp(B, 0, 0), P2s = Kp(B, 0, 1), P3 = Kp(B, 0, 2), P4 = Kp(B, 0, 3), PM = Kp(B, 0, 4), R1 = Kp(B, 1, 0), R2 = Kp(B, 1, 1), RM = Kp(B, 1, 4);
  const z = P3 === "A" ? 1.2 : 1, d = fa(dir), o = orth(d), K = k * z;
  const body = P4 === "A" ? DARKR : PALE;
  if (R1 === "A" && u < 0.45) solid(add(p, mul(d, -6 * K)), [[1.6, 1.1], [-2.4, 1.1], [-2.4, -1.1], [1.6, -1.1]], STEEL, dir, K, 0.6); // the booster stage, shed mid-flight
  for (const sg of [-1, 1]) fill(p, [[-1.5, sg * 1.1], [-4.2, sg * 2.8], [-4.6, sg * 2.8], [-4.2, sg * 1.1]], P2s === "B" ? STEEL : METAL_L, dir, K);
  solid(p, [[4.6, 0], [2.7, 1.35], [-4.2, 1.35], [-4.2, -1.35], [2.7, -1.35]], body, dir, K, 0.8);
  const nose = B.lv[1] >= 2 && R2 === "A" ? SEEK : PM === "A" || RM === "A" ? GOLD : P2s === "A" ? ORANGE : RED;
  fill(p, [[P1 === "B" ? 5.6 : 4.6, 0], [2.9, 1.35], [2.9, -1.35]], nose, dir, K);
  if (P1 === "A") line(add(p, mul(o, 1.35 * K)), add(p, mul(o, -1.35 * K)), RED, 0.8 * K);
  if (P4 === "A") line(add(add(p, mul(d, -1.2 * K)), mul(o, 1.35 * K)), add(add(p, mul(d, -1.2 * K)), mul(o, -1.35 * K)), YEL, 0.7 * K);
  if (P2s === "B") for (let i = 0; i < 3; i++) line(add(add(p, mul(d, (-2.6 + i * 1.6) * K)), mul(o, 1.35 * K)), add(add(p, mul(d, (-2.6 + i * 1.6) * K)), mul(o, -1.35 * K)), [0, 0, 0, 0.4], 0.5 * K);
  if (B.r === 2) line(add(add(p, mul(d, 0.6 * K)), mul(o, 1.35 * K)), add(add(p, mul(d, 0.6 * K)), mul(o, -1.35 * K)), ORANGE, 0.8 * K);
  if (B.r === 0) line(add(p, mul(d, 4.6 * K)), add(p, mul(d, 6.4 * K)), STEEL, 0.5 * K);
  glowDot(add(p, mul(d, -5 * K)), (P1 === "C" ? 1.7 : 1.2) * K, P1 === "C" ? [1, 0.6, 0.3, 1] : col); }
function rocketFlight(f, to, u, s, col, idx, B) { const k = G(s), bend = (homing(B) ? 0.45 : 0.28 + 0.1 * (idx % 3)) * (idx % 2 ? 1 : -1) * s;
  const mid = add(lerp(f, to, 0.5), mul(orth(norm(sub(to, f))), bend)), q = (x) => lerp(lerp(f, mid, x), lerp(mid, to, x), x);
  const trail = B.lv[1] >= 4 && Kp(B, 1, 3) === "A" ? 10 : 6, smoky = B.r === 1;
  for (let i = trail; i >= 1; i--) disc(q(Math.max(0, u - i * 0.035)), (1.2 + i * 0.55) * k * (smoky ? 1.4 : 1), smoky ? [0.42, 0.43, 0.45, 0.5 - i * 0.04] : [0.62, 0.64, 0.66, 0.34 - i * 0.045]);
  const p = q(u), pb = q(Math.max(0, u - 0.04)); rocketBody(p, Math.atan2(p[1] - pb[1], p[0] - pb[0]), k, col, B, u); }
function rocketImpact(to, v, s, col, info, B) { const size = 0.014 * blastPx(B), air = info && info.sh && info.ens && (info.ens.find((e) => e.i === info.sh.tid) || {}).air;
  let p = to; if (B.r === 0 && air) { p = add(to, [s * 0.12, -s * 0.06]); if (v < 0.3) for (let i = 0; i < 6; i++) disc(add(p, mul(fa(i + 0.4), s * 0.18 * v * 3)), 1.2, [0.3, 0.3, 0.32, 1 - v * 3]); }
  if (B.lv[0] >= 5) { if (v < 0.25) disc(p, s * size * (0.6 + v * 1.6), [1, 0.85, 0.6, 0.3]); blast(p, Math.max(0, v - 0.1) / 0.9, s, col, size); if (v < 0.7) ring(p, s * size * (0.6 + v * 2), A([1, 0.95, 0.8, 1], 0.6 * (1 - v / 0.7)), 1.6); }
  else blast(p, v, s, col, size);
  if (B.r === 2 && !air) for (let i = 0; i < 4; i++) { const q = add(to, [(rnd2(i + 3) - 0.5) * s * size * 2, (rnd2(i + 7) - 0.5) * s * size]), w = fmod(v * 2 + i / 4, 1); disc(add(q, [0, -w * s * 0.12]), s * 0.03 * (1 - w), A(i % 2 ? ORANGE : YEL, 1 - w)); } }

// ---- The model ---------------------------------------------------------------------------------------------------------
const TALL_H = 7; // how high the mastery's banks stand (game px, drawn as a screen-down offset)
function tallBox(c, aim, k, x0, x1, y, w, col, gold) { const up = [0, -TALL_H * k], q = [[x0, y - w / 2], [x1, y - w / 2], [x1, y + w / 2], [x0, y + w / 2]].map(([x, yy]) => P(c, aim, k, x, yy));
  poly(q.map((p) => add(p, [4 * k, 6 * k])), [0, 0, 0, 0.25]); // long shadow
  for (let i = 0; i < 4; i++) { const a = q[i], b = q[(i + 1) % 4], m = mul(add(a, b), 0.5), ctr = mul(q.reduce((s2, p) => add(s2, p), [0, 0]), 0.25);
    if (m[1] - ctr[1] > 0.01) { const face = [a, b, add(b, up), add(a, up)]; poly(face, OUTLINE); poly(face.map((p) => add(mul(sub(p, mul(add(face[0], face[2]), 0.5)), 0.9), mul(add(face[0], face[2]), 0.5))), dk(col, i === 1 ? 0.25 : 0.4)); } }
  const top = q.map((p) => add(p, up)); poly(top, OUTLINE); const ctr = mul(top.reduce((s2, p) => add(s2, p), [0, 0]), 0.25); poly(top.map((p) => add(ctr, mul(sub(p, ctr), 0.92))), col);
  // Gold bands wrap all the way round (owner): across the top, and down every side face that faces the viewer.
  const ctr0 = mul(q.reduce((s2, p) => add(s2, p), [0, 0]), 0.25);
  for (const fr of [0.2, 0.85]) { const bc = gold ? GOLD : [0, 0, 0, 0.3]; line(lerp(top[0], top[1], fr), lerp(top[3], top[2], fr), bc, 1.1 * k);
    for (const [ea, eb] of [[0, 1], [3, 2]]) { const m = mul(add(q[ea], q[eb]), 0.5); if (m[1] - ctr0[1] > 0.01) { const p = lerp(q[ea], q[eb], fr); line(p, add(p, up), bc, 1.1 * k); } } }
  return up; }
function deckRack(c, k, x, y, n, col2, band) { const S = (dx, dy) => P(c, 0, k, x + dx, y + dy); plate(S(0, 0), rectPts(1.8, n * 1.6 + 0.6), METAL_D, 0, k, 0.9);
  for (let i = 0; i < n; i++) { const q = S(0, (i - (n - 1) / 2) * 3); orb(q, 1.2 * k, col2); if (band) ring(q, 0.7 * k, band, 0.6 * k); } }

const P2 = {
  tower: "rocket", look: "C", anim: "A",
  intro: "Round 1: three options for every step and for the three new Retrofits (your replacements: Proximity Fuses, Smoke Trails, Incendiary Warheads), drawn as one model. Each Power step changes the rockets; Range adds boosters and homing (rockets curve onto their target); Payload re-lays the launcher with 4, 6, then 8 tubes, each rocket leaving its own tube. Deck kit stays put. Unpicked steps show option A.",
  mods(B) { const n = rocketsOf(B), period = reloadOf(B);
    return { period, burst: n, gap: B.lv[2] >= 5 ? 0.09 : 0.14, multi: true,
      shot: (f, to, u, s, col, kk, t, info) => { const dest = homing(B) || !info || !info.sh ? to : info.sh.to0; rocketFlight(f, dest, u, s, col, kk, B); },
      impact: (to, v, s, col, info) => rocketImpact(homing(B) || !info || !info.sh ? to : info.sh.to0, v, s, col, info, B) }; },
  muzzleAt(B, m, kk, c, aim, s, info) { const L = layoutOf(B, info.t), mo = L.mouths[kk % L.mouths.length], k = G(s); return add(P(c, aim, k, mo[0] + 0.5, mo[1]), L.tall ? [0, (mo[3] ? -TALL_H * 0.78 : -TALL_H * 0.28) * k] : [0, 0]); },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), L = layoutOf(B, t), S = (x, y) => P(c, 0, k, x, y), kp = (pi, kk) => Kp(B, pi, kk), gold = B.lv[0] >= 5, ready = fx.ready ?? 1;
    deck(c, k, col, t);
    // Deck kit (fixed): warhead crates and racks, reload crate, smoke generator, napalm tanks.
    if (kp(0, 0) === "C") { plate(S(-12.5, -5), rectPts(2.4, 2), AMMO, 0, k, 1); hazard(c, 0, k, -14.5, -10.5, -2.6, [1, 0.32, 0.25, 1], 0.9); }
    if (kp(0, 2) === "C") deckRack(c, k, 12.5, -4.5, 3, B.lv[0] >= 4 && kp(0, 3) === "A" ? DARKR : PALE, gold ? GOLD : RED);
    if (kp(2, 1) === "C") { plate(S(-12.5, 5), rectPts(2.4, 2.4), [0.5, 0.42, 0.28, 1], 0, k, 1); for (const y of [4, 6]) orb(S(-12.5, y), 0.9 * k, PALE); }
    if (B.r === 1 && B.key("r1") === "B") { plate(S(12.5, 5), rectPts(2.4, 2.6), SMOKEC, 0, k, 1); for (let i = 0; i < 2; i++) { const w = fmod(t * 0.6 + i / 2, 1); disc(add(S(12.5, 3), [0, -w * 8 * k]), (1 + w * 2.5) * k, [0.6, 0.62, 0.64, 0.35 * (1 - w)]); } }
    if (B.r === 2 && B.key("r2") === "B") for (const y of [-3, 3]) { orb(S(12.5, y + 5), 1.8 * k, [0.75, 0.38, 0.12, 1]); }
    // The launcher (it all turns): deflector, cross frame, pods (or the rotary drum), mouths, loaded noses.
    if (kp(1, 2) === "C") { bar(P(c, aim, k, -9, -9), P(c, aim, k, -9, -13), 1 * k, METAL_L); glowDot(P(c, aim, k, -9, -13), (fmod(t, 1) < 0.3 ? 1 : 0.4) * k, SEEK); }
    plate(P(c, aim, k, -11, 0), rectPts(1.6, 11), METAL_L, aim, k, 1); hazard(c, aim, k, -12, -10, 0, col, 1.2);
    for (const x of [-4, 6]) bar(P(c, aim, k, x, -11.5), P(c, aim, k, x, 11.5), 2.4 * k, kp(0, 3) === "C" ? STEEL : lt(METAL_D, 0.15));
    if (kp(2, 3) === "B") { const dr = P(c, aim, k, -6.5, 0); disc(dr, 4 * k, OUTLINE); disc(dr, 3.4 * k, METAL); ring(dr, 2.2 * k, A(col, 0.7), 0.9 * k); }
    if (kp(2, 1) === "B") line(P(c, aim, k, -9, 9), P(c, aim, k, -6, 5), [0.55, 0.45, 0.25, 1], 2 * k);
    if (kp(2, 1) === "A") { const a = aim + Math.PI * 0.8 - decay(fx.barrelSince ?? 9, 0.5) * 0.8, b0 = P(c, aim, k, -7, 9); orb(b0, 1.5 * k, METAL); bar(b0, add(b0, mul(fa(a), 7 * k)), 1.2 * k, METAL_L); }
    if (kp(2, 3) === "C") bar(P(c, aim, k, -9, 12), P(c, aim, k, -9, -12), 1.6 * k, [0.3, 0.3, 0.32, 1]);
    const podLen = 11.5 + (kp(1, 0) === "B" ? 2 : 0), podCol = kp(0, 2) === "B" ? STEEL : METAL_L;
    if (L.drum) { bar(P(c, aim, k, -8, 0), P(c, aim, k, podLen, 0), 12 * k, METAL); for (const m of L.mouths) line(P(c, aim, k, -6, m[1]), P(c, aim, k, podLen - 0.5, m[1]), [0, 0, 0, 0.35], 1.2 * k); for (const x of [-6, podLen - 1]) line(P(c, aim, k, x, -6), P(c, aim, k, x, 6), GOLD, 1.2 * k); }
    else if (L.tall) for (const [y, w] of L.pods) tallBox(c, aim, k, -8, podLen, y, w, podCol, true);
    else for (const [y, w] of L.pods) { if (w > 8) { const cx = (podLen - 8) / 2; plate(P(c, aim, k, cx, y), rectPts((podLen + 8) / 2, w / 2), podCol, aim, k, 1.2); rivets(P(c, aim, k, cx, y), rectPts((podLen + 8) / 2, w / 2), aim, k, 0.9, 0.7 * k); }
      else bar(P(c, aim, k, -8, y), P(c, aim, k, podLen, y), w * k, podCol); } // wide blocks are flat plates, pods are round
    if (L.top) bar(P(c, aim, k, -4, 0), P(c, aim, k, 9, 0), 3 * k, lt(METAL_L, 0.1));
    if (L.side) bar(P(c, aim, k, -2, 11.5), P(c, aim, k, 8, 11.5), 2.6 * k, METAL_L);
    // Pod bands and kit (on every pod): Power, Range, gold at the masteries, the Retrofit.
    const half = (w) => w * 0.5;
    for (const [y, w] of L.drum ? [[0, 12]] : L.tall ? [] : L.pods) { const band = (x, c2, lw) => line(P(c, aim, k, x, y - half(w)), P(c, aim, k, x, y + half(w)), c2, lw * k);
      if (kp(0, 0) === "A") band(4, RED, 1.1);
      if (kp(0, 1) === "C") for (const x of [0, 2]) band(x, [0, 0, 0, 0.45], 0.8);
      if (kp(0, 2) === "B") for (const x of [-6, 9]) band(x, STEEL, 1.6);
      if (gold && kp(0, 4) === "B" || L.gold && kp(2, 4) !== "C") for (const x of [-2, 9.5]) band(x, GOLD, 1.1);
      if (kp(1, 2) === "A") glowDot(P(c, aim, k, -6, y), 0.6 * k, fmod(t * 2 + y, 1) < 0.5 ? SEEK : A(SEEK, 0.3));
      if (kp(1, 3) === "B") for (const sg of [-1, 1]) fill(P(c, aim, k, -7, y + sg * half(w)), [[2, 0], [-1, sg * 1.6], [-1, 0]], STEEL, aim, k);
      if (B.r === 0 && B.key("r0") === "C") band(10.5, A(col, 0.85), 0.8);
      if (B.r === 1 && B.key("r1") === "C") for (const sg of [-1, 1]) disc(P(c, aim, k, -8.5, y + sg * half(w) * 0.5), 0.8 * k, BORE);
      if (B.r === 1 && B.key("r1") === "A") bar(P(c, aim, k, -6, y + half(w) * 0.7), P(c, aim, k, -1, y + half(w) * 0.7), 1.2 * k, SMOKEC); }
    if (kp(1, 0) === "C") bar(P(c, aim, k, -8, -half(L.pods[0][1]) + L.pods[0][0] - 1.4), P(c, aim, k, podLen - 1, -half(L.pods[0][1]) + L.pods[0][0] - 1.4), 1 * k, STEEL);
    if (gold && kp(0, 4) === "C") for (const y of [-12.5, 12.5]) { bar(P(c, aim, k, -6, y), P(c, aim, k, 4, y), 2.6 * k, [0.75, 0.38, 0.12, 1]); ring(P(c, aim, k, -1, y), 1.4 * k, GOLD, 0.9 * k); }
    const frontShows = !L.tall || Math.sin(aim) > 0.08; // a tall bank's mouths are on its front face: hidden when it faces away
    for (const [i, m] of L.mouths.entries()) { if (!frontShows) break; const q = add(P(c, aim, k, m[0] + (L.drum ? 0 : podLen - 11.5), m[1]), L.tall ? [0, (m[3] ? -TALL_H * 0.78 : -TALL_H * 0.28) * k] : [0, 0]); disc(q, (m[2] + 0.4) * k, OUTLINE); disc(q, m[2] * k, BORE);
      const f2 = fx.barrel === i && (fx.barrelSince ?? 9) < 0.25 ? 1 - fx.barrelSince / 0.25 : 0; if (f2 > 0) glowDot(q, m[2] * k * f2, col);
      if (B.r === 2 && B.key("r2") === "C") ring(q, (m[2] + 0.2) * k, A(ORANGE, 0.8), 0.7 * k);
      if (B.r === 0 && B.key("r0") === "A") line(q, add(q, mul(fa(aim), 1.8 * k)), STEEL, 0.5 * k);
      if (ready > 0.05) { orb(q, m[2] * 0.8 * k * ready, B.lv[0] >= 4 && kp(0, 3) === "A" ? DARKR : PALE); disc(add(q, mul(fa(aim), 0.4 * k)), m[2] * 0.36 * k * ready, B.lv[1] >= 2 && kp(1, 1) === "A" ? SEEK : gold && kp(0, 4) === "A" ? GOLD : RED); } }
    // Launcher top kit: seeker radar, tracking dish, hunter array / eye, fuse setter.
    if (kp(1, 1) === "B") { const q = P(c, aim, k, -1, 0); disc(q, 2 * k, OUTLINE); disc(q, 1.6 * k, METAL); line(q, add(q, mul(fa(t * 3), 2.6 * k)), METAL_L, 1 * k); }
    if (kp(1, 1) === "C") { bar(P(c, aim, k, -2, -3), P(c, aim, k, -2, -9), 0.7 * k, METAL_L); glowDot(P(c, aim, k, -2, -9), 0.6 * k, SEEK); }
    if (kp(1, 2) === "B") { const q = P(c, aim, k, -1, 0), a = t * 1.5; arc(q, 3 * k, a - 1, a + 1, OUTLINE, 2.4 * k); arc(q, 3 * k, a - 1, a + 1, METAL_L, 1.4 * k); }
    if (B.lv[1] >= 5) { const st = kp(1, 4), q = P(c, aim, k, -1, 0); if (st === "B") for (let i = 0; i < 3; i++) { const a = t * 1.2 + i * TAU / 3; arc(q, 3.6 * k, a - 0.5, a + 0.5, GOLD, 1.4 * k); } if (st === "C") { orb(q, 2.4 * k, METAL); ring(q, 2.6 * k, GOLD, 1 * k); glowDot(q, 1 * k, SEEK); } if (st === "A") ring(q, 2.2 * k, GOLD, 1 * k); }
    if (B.r === 0 && B.key("r0") === "B") { plate(P(c, aim, k, -8, -9.5), rectPts(1.8, 1.4), METAL_D, aim, k, 0.9); glowDot(P(c, aim, k, -8, -9.5), 0.6 * k, ORANGE); }
    if (kp(2, 3) === "A") for (const y of [-12.5, 12.5]) { const q = P(c, aim, k, -6.5, y); disc(q, 1.8 * k, OUTLINE); for (let i = 0; i < 6; i++) line(q, add(q, mul(fa(t * 6 * Math.sign(y) + i * Math.PI / 3), 1.6 * k)), METAL_L, 0.8 * k); }
    if (kp(1, 3) === "C") for (const y of [-12.5, 12.5]) { bar(P(c, aim, k, -9, y), P(c, aim, k, -3, y), 2.4 * k, [0.5, 0.55, 0.45, 1]); line(P(c, aim, k, -6, y - 1), P(c, aim, k, -6, y + 1), [0, 0, 0, 0.4], 0.8 * k); }
    orb(P(c, aim, k, -4, 0), 2.4 * k, METAL); glowDot(P(c, aim, k, -4, 0), 1 * k, col);
  },
  paths: [
    { name: "Power", theme: "heavier warheads; each step changes the rockets", steps: [
      { name: "HE Warheads", cost: 105, effect: "+5 damage per rocket (24)", options: [
        { key: "A", name: "Red Warhead Bands", desc: "Red bands on every pod; rockets carry a red HE band." },
        { key: "B", name: "Long Noses", desc: "Rockets with longer red noses." },
        { key: "C", name: "Warhead Crate", desc: "A warhead crate on the deck; rockets burn with a hotter orange exhaust." } ] },
      { name: "Wider Burst", cost: 155, effect: "Blast 25 to 35 px", options: [
        { key: "A", name: "Burst Charges", desc: "Orange burst-charge noses; bigger blasts." },
        { key: "B", name: "Frag Sleeves", desc: "Rockets with fragmentation rings and steel fins; bigger blasts." },
        { key: "C", name: "Blast Vents", desc: "Vent slots on every pod; bigger blasts." } ] },
      { name: "Heavy Warheads", cost: 985, effect: "32 damage, 40 px blast (primary)", options: [
        { key: "A", name: "Heavy Rockets", desc: "Fatter, heavier rockets." },
        { key: "B", name: "Armoured Pods", desc: "Steel armour bands on the pods." },
        { key: "C", name: "Warhead Rack", desc: "A rack of heavy warheads on the deck." } ] },
      { name: "Dense Payload", cost: 1245, effect: "38 damage", options: [
        { key: "A", name: "Dense Cores", desc: "Dark rockets with a yellow band (in the tubes too)." },
        { key: "B", name: "Payload Drum", desc: "A payload drum at the back of the launcher." },
        { key: "C", name: "Steel Frame", desc: "The cross frame is rebuilt in heavy steel." } ] },
      { name: "Thermobaric Rockets", cost: 5710, effect: "46 damage, 50 px blast (mastery)", options: [
        { key: "A", name: "Gold Warheads", desc: "Gold-nosed rockets; fuel-air blasts flash, then burst." },
        { key: "B", name: "Gold Pods", desc: "Gold bands on every pod; fuel-air blasts." },
        { key: "C", name: "Fuel-Air Tanks", desc: "Gold-ringed fuel tanks on the launcher's flanks; fuel-air blasts." } ] },
    ] },
    { name: "Range/Target Acquisition", theme: "range, then homing rockets", steps: [
      { name: "Booster Stage", cost: 45, effect: "+20 range (200)", options: [
        { key: "A", name: "Booster Stages", desc: "Rockets fly with a booster stage that falls away mid-flight." },
        { key: "B", name: "Longer Pods", desc: "The pods are swapped for longer ones." },
        { key: "C", name: "Booster Rail", desc: "A booster rail along the launcher." } ] },
      { name: "Seeker Heads", cost: 135, effect: "Homing: rockets curve onto their target", options: [
        { key: "A", name: "Seeker Domes", desc: "Blue seeker noses (in the tubes too); rockets home onto their targets." },
        { key: "B", name: "Seeker Radar", desc: "A small turning radar on the launcher; rockets home." },
        { key: "C", name: "Guidance Antenna", desc: "A guidance antenna on the launcher; rockets home." } ] },
      { name: "Smart Seekers", cost: 510, effect: "Re-target if their target dies; +30 range (230) (primary)", options: [
        { key: "A", name: "Seeker Lights", desc: "Blinking seeker lights on every pod." },
        { key: "B", name: "Tracking Dish", desc: "A turning tracking dish on the launcher." },
        { key: "C", name: "Datalink Mast", desc: "A blinking datalink mast on the launcher." } ] },
      { name: "Long Burn", cost: 670, effect: "+30 range (260)", options: [
        { key: "A", name: "Long-Burn Motors", desc: "Rockets trail longer exhaust." },
        { key: "B", name: "Sustainer Fins", desc: "Fins at the back of every pod." },
        { key: "C", name: "Fuel Pods", desc: "Fuel pods on both flanks of the launcher." } ] },
      { name: "Hunter Seekers", cost: 2315, effect: "300 range; seekers never miss (mastery)", options: [
        { key: "A", name: "Gold Seekers", desc: "Gold seeker noses and a gold sensor ring on the launcher." },
        { key: "B", name: "Hunter Array", desc: "A turning gold sensor array on the launcher." },
        { key: "C", name: "Hunter Eye", desc: "A big gold-ringed hunter eye on the launcher." } ] },
    ] },
    { name: "Reload/Payload", theme: "more rockets and faster reloads; each rocket leaves its own tube", steps: [
      { name: "Extra Tube", cost: 135, effect: "4 rockets per salvo", options: [
        { key: "A", name: "Fourth Pod", desc: "The launcher is re-laid with four narrower pods." },
        { key: "B", name: "Top Pod", desc: "A small fourth pod on top of the middle one." },
        { key: "C", name: "Side Tube", desc: "A single extra tube on the flank." } ] },
      { name: "Quick Loader", cost: 265, effect: "A salvo every 2 s", options: [
        { key: "A", name: "Loader Arm", desc: "A loader arm that swings in after each salvo." },
        { key: "B", name: "Ammo Belt", desc: "An ammo belt feeding the launcher." },
        { key: "C", name: "Reload Crate", desc: "A crate of ready rockets on the deck." } ] },
      { name: "Six-Pack", cost: 1335, effect: "6 rockets per salvo (primary)", options: [
        { key: "A", name: "Six-Tube Block", desc: "One wide block with six tubes in a row." },
        { key: "B", name: "Twin Banks", desc: "Two banks of three tubes." },
        { key: "C", name: "Honeycomb", desc: "Six tubes in a staggered honeycomb." } ] },
      { name: "Auto-Loader", cost: 1605, effect: "A salvo every 1.7 s", options: [
        { key: "A", name: "Feed Gears", desc: "Spinning feed gears on both flanks." },
        { key: "B", name: "Magazine Drum", desc: "A magazine drum behind the tubes." },
        { key: "C", name: "Conveyor", desc: "A conveyor across the back of the launcher." } ] },
      { name: "Ripple Salvo", cost: 6415, effect: "8 rockets per salvo, rippling out one after another (mastery)", options: [
        { key: "A", name: "Eight-Tube Grid", desc: "A gold-banded block with eight staggered tubes." },
        { key: "B", name: "Twin Four-Banks", desc: "Two gold-banded banks of four." },
        { key: "C", name: "Rotary Launcher", desc: "Eight tubes on a turning drum." } ] },
    ] },
  ],
  retrofits: [
    { name: "Proximity Fuses", cost: 40, effect: "Rockets burst beside flyers: +40% damage against air (replaces Guidance Fins; formula estimate)", options: [
      { key: "A", name: "Proximity Noses", desc: "A fuse antenna on every rocket; they burst beside flyers with a flak puff." },
      { key: "B", name: "Fuse Setter", desc: "A fuse-setting box on the launcher; rockets burst beside flyers." },
      { key: "C", name: "Sensor Bands", desc: "Sensor bands round the pod mouths; rockets burst beside flyers." } ] },
    { name: "Smoke Trails", cost: 20, effect: "Rockets leave smoke that slows enemies 10% for 2 s (replaces the Autoloader; formula estimate)", options: [
      { key: "A", name: "Smoke Canisters", desc: "Smoke canisters on every pod; rockets leave thick grey trails." },
      { key: "B", name: "Smoke Generator", desc: "A smoking generator on the deck; thick grey trails." },
      { key: "C", name: "Trail Nozzles", desc: "Smoke nozzles at the back of every pod; thick grey trails." } ] },
    { name: "Incendiary Warheads", cost: 125, effect: "Blasts leave burning ground, 3 damage/s for 2 s (replaces the Long Booster; formula estimate)", options: [
      { key: "A", name: "Fuel Warheads", desc: "Orange-banded rockets; their blasts leave flames." },
      { key: "B", name: "Napalm Tanks", desc: "Napalm tanks on the deck; blasts leave flames." },
      { key: "C", name: "Igniter Mouths", desc: "Glowing igniter rings round the tube mouths; blasts leave flames." } ] },
  ],
};

// ---- Round 2 (owner's picks and notes, 2026-10-17) ----------------------------------------------------------------
P2.intro = "Round 2: your picks as one model, with your notes: seeker blue noses win over the Power mastery's gold (5/2/0); the pods are bigger than their mouths; the Ripple Salvo stacks its tubes 2 x 2 in each side bank.";
P2.picks = { p0s0: "B", p0s1: "B", p0s2: "A", p0s3: "A", p0s4: "A", p1s0: "A", p1s1: "A", p1s2: "A", p1s3: "A", p1s4: "C", p2s0: "A", p2s1: "A", p2s2: "B", p2s3: "C", p2s4: "B", r0: "A", r1: "A", r2: "A" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { st.options = st.options.filter((o) => o.key === P2.picks["p" + pi + "s" + k]); }));
P2.retrofits.forEach((rf, ri) => { rf.options = rf.options.filter((o) => o.key === P2.picks["r" + ri]); });
P2.paths[0].steps[4].options[0].desc = "Gold-nosed rockets with fuel-air blasts; with Seeker Heads fitted the noses stay seeker blue (your note).";
P2.paths[2].steps[0].options[0].desc = "Four pods, each wider than its mouth (your note).";
P2.paths[2].steps[2].options[0].desc = "Two banks of three tubes, each bank bigger than its mouths (your note).";
P2.paths[2].steps[4].options[0].desc = "Two gold-banded banks, their tubes stacked 2 x 2 on each side (your note).";
