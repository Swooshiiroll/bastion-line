// ---- Tower art second pass: Artillery Cannon (tower 6), round 1 ------------------------------------------------
// Base: look F Rammer Howitzer, animation A Shell on the Mark. One parametric model, with the lessons so far (owner,
// 2026-10-17): options swap parts rather than lay overlays over them; the deck kit is static, only the barrel turns;
// each Power step changes the shell; masteries get gold; mouths no bigger than their barrel; shadows and hubs under.
// Geometry (game px, x along the aim, y to the side): barrel x 0 to 25, 3.8 wide; cradle x -16 to 10, 8.4 wide; rammer
// rod x -15 to -6 behind the breech; octagonal turret hub r 6 on top.
// The Retrofits replaced on 2026-10-17: Shell Magazine (for the Ammo Hoist) and Stabilised Mount (for the Heavy Recoil
// Mount). Stock scatter is drawn as 30 px, so the Stabilised Mount's 15 px is visible; that stock scatter is Claude's
// assumption, flagged to the owner.
const PAGE = { title: "Artillery Cannon: paths and Retrofits (second pass)", store: "bl-tower-art-p2-artillery-r2" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], RED = [0.85, 0.2, 0.18, 1], ORANGE = [1, 0.55, 0.2, 1];
const YEL = [1, 0.85, 0.2, 1], DARKSHELL = [0.2, 0.2, 0.22, 1], FIRE = [1, 0.45, 0.12, 1], CONC = [0.55, 0.85, 1, 1];
const SHRAP = [0.82, 0.8, 0.72, 1], BAG = [0.55, 0.47, 0.3, 1], TANK = [0.6, 0.18, 0.15, 1];
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null); // the option used at path pi, step k (or null)

// ---- Shell types: HE always; the Special Effects path unlocks the rest, and you switch between them -----------------
const typesOf = (B) => ["he", ...["inc", "shr", "con"].slice(0, Math.min(3, B.lv[2])), ...(B.lv[2] >= 5 ? ["all"] : [])];
const TCOL = { he: null, inc: FIRE, shr: SHRAP, con: CONC, all: GOLD };
const perBarrage = (B) => (B.lv[1] >= 5 ? 3 : 1);
const typeAt = (B, m) => { const T = typesOf(B); return T[Math.floor(m / perBarrage(B)) % T.length]; };
const bodyCol = (B) => (B.lv[0] >= 5 ? GOLD : B.lv[0] >= 3 ? DARKSHELL : METAL_L);
const bandCol = (B) => (Kp(B, 0, 0) === "B" ? RED : Kp(B, 0, 2) === "A" ? YEL : null);
// How much bigger the shell is drawn: Heavy Shells (A), the Wide Bursting Charge's fat shells (C), Wide Charge (R).
const sizeOf = (B, heavy) => (Kp(B, 0, 0) === "A" ? 1.2 : 1) * (Kp(B, 0, 1) === "C" ? 1.15 : 1) * (B.r === 2 ? 1.25 : 1) * (heavy ? 1.35 : 1);
const isHeavy = (B, m) => B.r === 0 && m % 3 === 2; // the Shell Magazine: every third shell is a heavy round

// One shell: a round body with the marks of every Power step, and the marks of its type (incendiary flame, shrapnel
// studs, concussion rings, the combined three bands).
function shellMarks(p, r, k, B, ty, dir, big) {
  const d = fa(dir), body = bodyCol(B), P4 = Kp(B, 0, 3), band = bandCol(B);
  if (P4 === "B") for (const sg of [-1, 1]) fill(p, [[-0.6, sg * 0.8], [-1.9, sg * 1.9], [-1.9, sg * 0.8]].map((q) => mul(q, r / (2.6 * k))), STEEL, dir, k);
  if (P4 === "A") fill(add(p, mul(d, r * 0.8)), [[1.7, 0], [0, 1], [0, -1]].map((q) => mul(q, r / (2.6 * k))), STEEL, dir, k);
  if (P4 === "C") { // Long Penetrators change the round's shape (owner's note): a long slim body with a steel tip
    bar(add(p, mul(d, -r * 1.9)), add(p, mul(d, r * 0.9)), r * 1.05, body);
    fill(add(p, mul(d, r * 0.9)), [[1.5, 0], [0, 0.55], [0, -0.55]].map((q) => mul(q, r / (2.6 * k))), STEEL, dir, k);
  } else orb(p, r, body);
  if (Kp(B, 0, 4)) ring(p, r * 0.55, GOLD, 0.8 * k);
  if (band) line(add(p, mul(orth(d), r * 0.9)), add(p, mul(orth(d), -r * 0.9)), band, 1 * k);
  if (Kp(B, 0, 1) === "A") for (const sg of [-1, 1]) line(add(p, mul(orth(d), sg * r * 0.55 - d[0] * 0)), add(p, add(mul(orth(d), sg * r * 0.55), mul(d, r * 0.6))), ORANGE, 0.8 * k);
  if (Kp(B, 0, 1) === "B") for (let i = 0; i < 3; i++) line(add(p, mul(fa(i * 1.05 + 0.5), r * 0.3)), add(p, mul(fa(i * 1.05 + 0.5), r * 0.95)), [0, 0, 0, 0.45], 0.6 * k);
  if (big) ring(p, r * 1.05, RED, 1.1 * k); // a heavy round from the Shell Magazine
  const imp = B.lv[2] >= 4 ? 1.5 : 1; // Improved Payloads: every type stronger
  if (ty === "inc") { ring(p, r * 0.8, FIRE, 0.9 * k * imp); disc(add(p, mul(d, -r * 1.1)), r * 0.5, A(FIRE, 0.7)); }
  if (ty === "shr") for (let i = 0; i < 6; i++) line(add(p, mul(fa(i * TAU / 6 + 0.3), r * 0.95)), add(p, mul(fa(i * TAU / 6 + 0.3), r * (1.3 + 0.2 * (imp - 1)))), SHRAP, 0.8 * k);
  if (ty === "con") { ring(p, r * 1.15, A(CONC, 0.8), 0.8 * k * imp); ring(p, r * 1.5, A(CONC, 0.4), 0.7 * k); }
  if (ty === "all") for (const [j, cc] of [[0.45, FIRE], [0.75, SHRAP], [1.05, CONC]].entries()) ring(p, r * cc[0], cc[1], 0.8 * k);
}
const ARC = 0.85;
const offOf = (B, info, s) => { const m = info && info.sh ? info.sh.m : 0, kb = info && info.sh ? info.sh.k : 1, k = G(s), sc = (B.r === 1 ? 15 : 30) * k;
  const a = rnd2(m * 3.7 + 0.2) * TAU, d = Math.sqrt(rnd2(m * 7.1 + 1.3)) * sc;
  return add(mul(fa(a), d), [perBarrage(B) > 1 ? (kb - 1) * s * 0.45 : 0, 0]); };
function artShell(f, to0, u, s, col, B, info) { const k = G(s), m = info && info.sh ? info.sh.m : 0, heavy = isHeavy(B, m), z = sizeOf(B, heavy), r = 2.6 * k * z, ty = typeAt(B, m);
  const to = add(to0, offOf(B, info, s)), arcH = (h) => Math.sin(Math.PI * h) * s * ARC, p0 = lerp(f, to, u), p = add(p0, [0, -arcH(u)]);
  const pb = add(lerp(f, to, Math.max(0, u - 0.03)), [0, -arcH(Math.max(0, u - 0.03))]), dir = Math.atan2(p[1] - pb[1], p[0] - pb[0]);
  ellipse(p0, 3 * k * z, 1.5 * k * z, [0, 0, 0, 0.3]);
  const tc = TCOL[ty] || (Kp(B, 0, 0) === "C" ? ORANGE : col);
  for (let i = 4; i >= 1; i--) { const v = Math.max(0, u - i * 0.035); if (ty === "inc" || ty === "all" || Kp(B, 0, 0) === "C" || B.lv[0] >= 5) disc(add(lerp(f, to, v), [0, -arcH(v)]), (0.9 + i * 0.4) * k * z, A(tc, 0.34 - 0.06 * i)); }
  shellMarks(p, r, k, B, ty, dir, heavy); glowDot(p, 1.1 * k, tc); }
function artImpact(to0, v, s, col, info, B) { const k = G(s), to = add(to0, offOf(B, info, s)), m = info && info.sh ? info.sh.m : 0, ty = typeAt(B, m);
  const px = [70, 70, 85, 85, 85, 90][B.lv[0]] + (B.r === 2 ? 15 : 0), size = 0.55 * px / 70, imp = B.lv[2] >= 4;
  if (B.lv[0] >= 4) disc(to, s * 0.1, [0.12, 0.1, 0.08, 0.5 * (1 - v)]); // a deeper crater for the penetrators
  blast(to, v, s, col, size);
  if (B.lv[0] >= 5) { ring(to, s * (0.4 + v * 1.4) * size / 0.55, A(GOLD, 0.55 * (1 - v)), 1.6); ring(to, s * (0.2 + v) * size / 0.55, A(GOLD, 0.5 * (1 - v)), 1); }
  if (ty === "inc" || ty === "all") for (let i = 0; i < 7; i++) { const q = add(to, mul(fa(i * 0.9 + 1), s * size * 0.55 * (0.4 + 0.6 * rnd2(i)))), fl = 0.6 + 0.4 * Math.sin(v * 40 + i * 2); disc(add(q, [0, -fl * k * 2]), (1.4 + (imp ? 0.7 : 0)) * k * fl, A(i % 2 ? FIRE : YEL, 0.85 * (1 - v * 0.5))); }
  if (ty === "shr" || ty === "all") { const w = Math.min(1, v * 2.2); for (let i = 0; i < 10; i++) { const a = i * TAU / 10 + 0.2, e = add(to, mul(fa(a), s * (0.5 + (imp ? 0.1 : 0)) * w * (0.8 + 0.4 * rnd2(i)))); line(lerp(to, e, 0.7), e, A(SHRAP, 1 - v), 1.1); } }
  if (ty === "con" || ty === "all") for (let i = 0; i < 2; i++) { const w = (v - i * 0.15); if (w > 0 && w < 1) ring(to, s * size / 0.55 * (0.3 + w * 0.9), A(CONC, 0.8 * (1 - w)), (imp ? 2.6 : 1.8)); } }

// ---- The model ---------------------------------------------------------------------------------------------------
const lenFor = () => 25;
function shellRow(S, k, x, y, n, B, vertical, ty) { const body = bodyCol(B), band = bandCol(B);
  for (let i = 0; i < n; i++) { const q = vertical ? S(x, y + (i - (n - 1) / 2) * 3) : S(x + (i - (n - 1) / 2) * 3, y), r = 1.4 * k * (Kp(B, 0, 0) === "A" ? 1.15 : 1) * (B.r === 2 ? 1.2 : 1);
    if (Kp(B, 0, 3) === "C") { bar(add(q, [0, 1.6 * k]), add(q, [0, -1 * k]), r * 0.95, body); fill(add(q, [0, -1 * k]), [[0, -1.5], [0.55, 0], [-0.55, 0]].map((v) => mul(v, r / (2.6 * k))), STEEL, 0, k); if (band) line(add(q, [-r * 0.5, 0.3 * k]), add(q, [r * 0.5, 0.3 * k]), band, 0.6 * k); }
    else { orb(q, r, body); if (band) ring(q, r * 0.7, band, 0.6 * k); if (Kp(B, 0, 3) === "A") disc(add(q, [r * 0.55, -r * 0.4]), 0.5 * k, [0.66, 0.69, 0.74, 1]); }
    if (B.lv[0] >= 5) ring(q, r * 0.5, GOLD, 0.6 * k); if (ty) ring(q, r * 1.2, A(ty, 0.8), 0.6 * k); } }
const P2 = {
  tower: "artillery", look: "F", anim: "A",
  intro: "Round 1: three options for every step and Retrofit, drawn as one model so the paths combine (the lessons from the first four towers): options swap parts instead of covering them, the deck kit is fixed and only the barrel turns, every Power step changes the shell, masteries are gold. The Special Effects path unlocks shell types (incendiary, shrapnel, concussion, combined) that the cannon cycles through in the build preview. Shells land with a 30 px scatter, which the Stabilised Mount halves (my assumption, tell me if the stock cannon should be exact). Unpicked steps show option A.",
  mods(B) { const per = [4, 3.3, 2.9, 2, 1.7, 4.2][B.lv[1]], n = perBarrage(B);
    return { period: per, burst: n, gap: n > 1 ? 0.35 : undefined, multi: false,
      shot: (f, to, u, s, col, kk, t, info) => { if (u < 0.3) smokePuff(f, u / 0.3, s * 1.2, 0.5); artShell(f, to, u, s, col, B, info); },
      impact: (to, v, s, col, info) => artImpact(to, v, s, col, info, B) }; },
  muzzleAt(B, m, kk, c, aim, s, info) { return P(c, aim, G(s), lenFor(B), 0); },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), since = fx.barrelSince ?? 9, rc = decay(since, 0.4), fl = decay(since, 0.18), r = rc * 3.5, S = (x, y) => P(c, 0, k, x, y);
    const body = bodyCol(B), shots = fx.shots || 0, ty = typesOf(B)[Math.floor(Math.max(0, shots - 1) / perBarrage(B)) % typesOf(B).length];
    deck(c, k, col, t);
    // -- Fixed deck kit (never turns) ------------------------------------------------------------------------------
    const heavyNext = B.r === 0 && shots % 3 === 2;
    // The shell tray: always there (the base look); Power restyles its shells; some Speed options replace it.
    const S3 = Kp(B, 1, 2), SM = Kp(B, 1, 4);
    if (S3 !== "A" && SM !== "C") { plate(S(-6, -9), rectPts(5.4, 2.4), AMMO, 0, k, 0.9);
      shellRow(S, k, -6, -9, Kp(B, 0, 2) === "C" ? 3 : 3, B, false, null);
      if (Kp(B, 0, 2) === "C") { plate(S(-6, -12.4), rectPts(5.4, 1.6), AMMO, 0, k, 0.9); shellRow(S, k, -6, -12.4, 3, B, false, null); } }
    // Power kit
    if (Kp(B, 0, 0) === "C") for (let i = 0; i < 3; i++) plate(S(-12.5 + (i % 2) * 1.2, 9.4 - i * 1.7), rectPts(2.6, 1.3), BAG, 0, k, 0.9);
    if (Kp(B, 0, 1) === "A") { plate(S(10, -11), rectPts(3.4, 2.6), METAL_D, 0, k, 1); hazard(c, 0, k, 7, 13, -12.4, ORANGE, 0.9); hazard(c, 0, k, 7, 13, -9.6, ORANGE, 0.9); }
    if (Kp(B, 0, 4) === "C") plate(S(-16, 0), rectPts(1.2, 5.6), GOLD, 0, k, 1);
    // Speed kit
    if (Kp(B, 1, 0) === "A") { const base = S(-8, 10), sw = decay(since, 0.6), a = -Math.PI * 0.75 + (1 - sw) * 0.0 + sw * 1.1 + aim * 0; orb(base, 1.6 * k, METAL); bar(base, add(base, mul(fa(Math.PI * 1.25 + sw * 1.1), 8 * k)), 1.4 * k, METAL_L); }
    if (Kp(B, 1, 0) === "B") { plate(S(-12, 10.5), [[-3, -2.2], [3, -2.2], [2, 2.2], [-2, 2.2]], METAL_D, 0, k, 1); bar(S(-10, 8.5), S(-7, 5), 1.6 * k, METAL); orb(S(-12, 10.5), 1 * k, body); }
    if (Kp(B, 1, 0) === "C") for (let i = 0; i < 3; i++) glowDot(S(-14 + i * 2.6, 11.5), 0.7 * k, fmod(t * 2 + i * 0.4, 1) < 0.5 ? [0.4, 1, 0.5, 1] : [0.25, 0.4, 0.28, 1]);
    if (S3 === "A") { const q = S(-6, -9); disc(q, 5 * k, OUTLINE); disc(q, 4.4 * k, METAL_D); for (let i = 0; i < 6; i++) { const a = i * TAU / 6 + t * 0.6; orb(add(q, mul(fa(a), 3 * k)), 1.2 * k, body); } disc(q, 1.2 * k, METAL_L); }
    if (S3 === "B") { for (let i = 0; i < 6; i++) { const q = lerp(S(-14, -12), S(-7, -3), ((i / 6 + t * 0.4) % 1)); orb(q, 1.1 * k, body); } plate(S(-15, -12.5), rectPts(2.2, 2), METAL_D, 0, k, 1); }
    if (SM === "A") for (const y of [-3.2, 0, 3.2]) { bar(S(-15, y), S(-6 - 4 * rc, y), 1 * k, GOLD); }
    if (SM === "B") for (const sg of [-1, 1]) bar(S(-14, sg * 10), S(-7, sg * 4), 1.6 * k, GOLD);
    if (SM === "C") { plate(S(-6, -9.5), rectPts(5.4, 3.6), AMMO, 0, k, 0.9); for (const y of [-11.2, -9.5, -7.8]) shellRow(S, k, -6, y, 3, { ...B, lv: [B.lv[0], B.lv[1], 0], key: B.key }, false, null); }
    if (B.lv[1] >= 5) for (let i = 0; i < 3; i++) glowDot(S(-14 + i * 2.6, 12.2), 0.7 * k, GOLD);
    // Special kit: the shell selector (from the first type), then the options' own parts
    if (B.lv[2] >= 1) { const q = S(12, 10), T = typesOf(B), cur = T.indexOf(ty), big = B.lv[2] >= 5 ? 5.6 : Kp(B, 2, 3) === "A" ? 5.2 : 4.2;
      disc(q, big * k, OUTLINE); disc(q, (big - 0.6) * k, METAL_D); T.forEach((tt, i) => { const a = -Math.PI / 2 + i * TAU / T.length, dq = add(q, mul(fa(a), (big - 1.6) * k)); glowDot(dq, 0.8 * k, TCOL[tt] || [0.8, 0.8, 0.8, 1]); });
      line(q, add(q, mul(fa(-Math.PI / 2 + Math.max(0, cur) * TAU / T.length), (big - 1.2) * k)), WHITE, 1 * k); if (B.lv[2] >= 5) ring(q, big * k, GOLD, 1.2 * k); }
    if (Kp(B, 2, 0) === "A") { plate(S(-13, 3), rectPts(2.4, 3), TANK, 0, k, 1); line(S(-11, 3), S(-8, 1), [0.15, 0.15, 0.15, 1], 1.1 * k); }
    if (Kp(B, 2, 1) === "A") { plate(S(14, -6), rectPts(2.6, 2.6), BAG, 0, k, 1); for (let i = 0; i < 3; i++) disc(S(13 + i, -6.6 + i * 0.5), 0.5 * k, SHRAP); }
    if (Kp(B, 2, 2) === "B") { plate(S(-14, 6.5), rectPts(2.6, 1.8), CONC, 0, k, 1); plate(S(-14, 6.5), rectPts(1.6, 0.8), WHITE, 0, k, 0.8); }
    if (Kp(B, 2, 3) === "C") { plate(S(14, 3), rectPts(2.6, 2), METAL_D, 0, k, 1); for (let i = 0; i < 3; i++) line(S(12.8, 2.2 + i * 0.8), S(15.2, 2.2 + i * 0.8), [0.4, 1, 0.5, 0.8], 0.6 * k); }
    if (Kp(B, 2, 4) === "C") { const q = S(14, -1); disc(q, 3.4 * k, OUTLINE); disc(q, 2.8 * k, GOLD); for (let i = 0; i < 5; i++) disc(add(q, mul(fa(i * TAU / 5 + t * 0.7), 1.7 * k)), 0.7 * k, METAL_D); }
    // Retrofit kit
    if (B.r === 0) { const q = S(-13, -3), a = Kp(B, 2, 4) ? 0 : 0;
      if (true) { const ky = B.key("r0"); if (ky === "A") { disc(q, 3.6 * k, OUTLINE); disc(q, 3 * k, METAL_D); for (let i = 0; i < 5; i++) orb(add(q, mul(fa(i * TAU / 5 + t * 0.4), 1.9 * k)), 0.9 * k, body); }
        if (ky === "B") { plate(q, rectPts(2.8, 3.4), METAL_D, 0, k, 1); for (let i = 0; i < 3; i++) orb(add(q, [0, (i - 1) * 2.2 * k]), 0.9 * k, body); }
        if (ky === "C") { disc(q, 3.4 * k, OUTLINE); disc(q, 2.8 * k, METAL_D); for (let i = 0; i < 3; i++) orb(add(q, mul(fa(i * TAU / 3 + t * 0.5), 1.7 * k)), 1.1 * k, body); }
        for (let i = 0; i < 3; i++) glowDot(add(q, [4.4 * k, (i - 1) * 1.8 * k]), 0.5 * k, i === shots % 3 ? RED : [0.35, 0.18, 0.18, 1]); } }
    if (B.r === 1) { const ky = B.key("r1");
      if (ky === "A") for (const [x, y] of [[-14, -12], [14, -12], [-14, 12], [14, 12]]) { bar(S(x * 0.6, y * 0.6), S(x, y), 1.6 * k, METAL); plate(S(x, y), rectPts(2, 2), METAL_L, 0, k, 1); }
      if (ky === "B") { const q = S(12, -10); disc(q, 3.2 * k, OUTLINE); disc(q, 2.6 * k, METAL_D); for (let i = 0; i < 4; i++) line(q, add(q, mul(fa(i * TAU / 4 + t * 4), 2.4 * k)), STEEL, 1 * k); orb(q, 1 * k, METAL_L); }
      if (ky === "C") for (const sg of [-1, 1]) { bar(S(-14, sg * 7), S(-6 + 0, sg * 6), 1.8 * k, METAL_L); bar(S(-14, sg * 7), S(-10 - rc * 2, sg * 6.7), 2.8 * k, METAL); } }
    if (B.r === 2) { const ky = B.key("r2");
      if (ky === "B") for (const y of [-12, 12]) { plate(S(2, y), rectPts(4.2, 2), METAL_D, 0, k, 1); hazard(c, 0, k, -1, 5, y - 1.2, YEL, 0.8); }
      if (ky === "A") { plate(S(14, -9), rectPts(3, 2.4), METAL_D, 0, k, 1); orb(S(13, -9), 1.6 * k, body); orb(S(15.4, -9), 1.6 * k, body); } }
    // -- Turning parts: rammer, cradle, barrel, hub ---------------------------------------------------------------------
    const rr = 6 * decay(since, 0.3), rodY = Kp(B, 1, 2) === "C" ? [-2, 2] : [0];
    for (const y of rodY) { bar(P(c, aim, k, -15, y), P(c, aim, k, -6 - 6 * rr / 6 * 0 - rr * 0.5, y), 1.6 * k, METAL_L); }
    plate(P(c, aim, k, -15, 0), rectPts(1.6, Kp(B, 1, 2) === "C" ? 4.6 : 3), METAL_D, aim, k, 0.9);
    if (Kp(B, 0, 4) === "C") plate(P(c, aim, k, -15.6, 0), rectPts(0.8, 4.6), GOLD, aim, k, 0.9);
    if (Kp(B, 1, 3) === "C") for (const y of rodY) { for (let i = 0; i < 4; i++) line(P(c, aim, k, -14 + i * 2, y - 1.4), P(c, aim, k, -13 + i * 2, y + 1.4), STEEL, 0.9 * k); }
    // The cradle (A: base; Armoured Cradle swaps it), with the Speed breech parts.
    const arm = Kp(B, 0, 2) === "B"; plate(P(c, aim, k, -3, 0), rectPts(13, arm ? 5.4 : 4.2), arm ? METAL_D : METAL, aim, k, 1.1);
    if (arm) rivets(P(c, aim, k, -3, 0), rectPts(13, 5.4), aim, k, 0.9, 0.6 * k);
    if (Kp(B, 0, 0) === "A") plate(P(c, aim, k, -12, 0), rectPts(2.6, 5.2), METAL_D, aim, k, 1.1); // heavy breech block
    if (Kp(B, 1, 1) === "A") for (const sg of [-1, 1]) { bar(P(c, aim, k, -14, sg * 5), P(c, aim, k, -8 - rc * 2, sg * 5), 1.6 * k, STEEL); orb(P(c, aim, k, -14, sg * 5), 1 * k, METAL); }
    if (Kp(B, 1, 1) === "B") { const q = P(c, aim, k, -9, 0); disc(q, 2.4 * k, OUTLINE); disc(q, 1.9 * k, STEEL); for (let i = 0; i < 6; i++) { const a = i * TAU / 6 + shots * 0.5; line(add(q, mul(fa(a), 1.6 * k)), add(q, mul(fa(a), 2.6 * k)), METAL_L, 0.9 * k); } }
    if (Kp(B, 1, 1) === "C") for (let i = 0; i < 4; i++) line(P(c, aim, k, -14 + i * 1.6, -4.4), P(c, aim, k, -14 + i * 1.6, 4.4), [0, 0, 0, 0.45], 0.9 * k);
    if (Kp(B, 1, 3) === "A") { plate(P(c, aim, k, -4, 5.4), rectPts(2.6, 1.4), METAL_D, aim, k, 1); glowDot(P(c, aim, k, -3, 5.4), 0.5 * k, [0.4, 1, 0.5, 1]); }
    if (Kp(B, 1, 3) === "B") for (const sg of [-1, 1]) bar(P(c, aim, k, -10, sg * 3), P(c, aim, k, -3, sg * 6.4), 1.3 * k, METAL_L);
    if (Kp(B, 1, 4) === "B") plate(P(c, aim, k, -9, 0), rectPts(2, 3), GOLD, aim, k, 1);
    if (Kp(B, 1, 4) === "A") for (const y of [-3.2, 0, 3.2]) { /* the three gold rammers sit in the fixed kit */ }
    // The barrel, its bands and muzzle (bore no bigger than the barrel)
    const X0 = -r, X1 = 25 - r, bw = 3.8 * k;
    bar(P(c, aim, k, X0, 0), P(c, aim, k, X1, 0), bw, METAL_L); bar(P(c, aim, k, X0, 0), P(c, aim, k, 10 - r, 0), 5.2 * k, METAL);
    const cross = (x, w, col, lw) => line(add(P(c, aim, k, x - r, 0), mul(orth(fa(aim)), w * k)), add(P(c, aim, k, x - r, 0), mul(orth(fa(aim)), -w * k)), col, lw * k);
    for (const x of [8, 14]) if (Kp(B, 1, 3) !== "C") cross(x, 1.9, lt(METAL_D, 0.15), 1.4);
    if (Kp(B, 0, 0) === "B") { cross(5, 2.7, RED, 1.4); cross(18, 2, RED, 1.2); }
    if (Kp(B, 0, 2) === "A") cross(11, 2.1, YEL, 1.3);
    if (Kp(B, 0, 1) === "B") plate(P(c, aim, k, 16 - r, 0), rectPts(4, 2.4), DARKSHELL, aim, k, 1);
    if (Kp(B, 0, 1) === "B") for (let i = 0; i < 3; i++) cross(13 + i * 3, 2.3, [0, 0, 0, 0.5], 0.8);
    if (Kp(B, 0, 3) === "A") plate(P(c, aim, k, 21.5 - r, 0), rectPts(1.1, 2.7), STEEL, aim, k, 1);
    if (Kp(B, 0, 3) === "B") for (let i = 0; i < 4; i++) { const a = aim + Math.PI / 4 + i * Math.PI / 2; line(add(P(c, aim, k, 23 - r, 0), mul(fa(a), 1.2 * k)), add(P(c, aim, k, 23 - r, 0), mul(fa(a), 2.8 * k)), METAL_L, 0.9 * k); }
    if (Kp(B, 0, 3) === "C") plate(P(c, aim, k, 4 - r, 0), rectPts(1.6, 3.1), STEEL, aim, k, 1);
    if (Kp(B, 0, 4) === "A") for (const x of [4, 9, 16, 21]) cross(x, 2.1, GOLD, 1.2);
    if (Kp(B, 2, 0) === "B") for (let i = 0; i < 4; i++) { const q = P(c, aim, k, 15 + i * 1.6 - r, 0); line(add(q, mul(orth(fa(aim)), 2 * k * (i % 2 ? 1 : -1))), add(q, mul(orth(fa(aim)), 2 * k * (i % 2 ? -1 : 1) + 0)), ORANGE, 0.9 * k); }
    if (Kp(B, 2, 1) === "C") for (let i = 0; i < 6; i++) { const a = aim + i * TAU / 6; line(add(P(c, aim, k, 12 - r, 0), mul(fa(a), 2 * k)), add(P(c, aim, k, 12 - r, 0), mul(fa(a), 3.2 * k)), SHRAP, 0.9 * k); }
    if (Kp(B, 2, 2) === "A") for (const x of [15, 17.2, 19.4]) cross(x, 2.2, CONC, 1.2);
    if (Kp(B, 2, 4) === "B") for (const [x, cc] of [[6, FIRE], [11, SHRAP], [16, CONC]]) cross(x, 2.2, cc, 1.3);
    if (Kp(B, 0, 4) === "B" || B.lv[1] >= 5) plate(P(c, aim, k, 23.5 - r, 0), rectPts(1.3, 3.3), GOLD, aim, k, 1);
    if (B.r === 2 && B.key("r2") === "C") plate(P(c, aim, k, 19 - r, 0), rectPts(1.8, 3.7), METAL, aim, k, 1);
    // Wide Muzzle Brake: swaps the plain muzzle for a baffled brake
    if (Kp(B, 0, 1) === "C") { plate(P(c, aim, k, 22 - r, 0), rectPts(2.3, 3.8), METAL, aim, k, 1); for (const x of [20.6, 22]) cross(x, 3.7, [0, 0, 0, 0.5], 0.9); }
    else plate(P(c, aim, k, 25.5 - r, 0), rectPts(1.8, 3), METAL, aim, k, 1);
    muzzleEnd(P(c, aim, k, 27 - r, 0), k, 2.8, TCOL[ty] || col, fl);
    // Wide Charge and Stabilised kit on the barrel
    if (B.r === 1 && B.key("r1") === "B") { /* the gyro sits in the fixed kit */ }
    // The turret hub on top of the cradle and barrel
    plate(c, ngon(8, 1, Math.PI / 8), METAL_L, aim, 6 * k, 1.1); orb(c, 3 * k, METAL); glowDot(c, 1 * k, col);
    if (heavyNext) ring(c, 4.2 * k, RED, 1 * k);
  },
  paths: [
    { name: "Power", theme: "harder-hitting shells, then armour piercing; each step changes the shell", steps: [
      { name: "Heavy Shells", cost: 120, effect: "+15 damage (90)", options: [
        { key: "A", name: "Heavy Breech Block", desc: "A thick breech block on the cradle; the shells are a size bigger." },
        { key: "B", name: "Red HE Bands", desc: "Red HE bands round the barrel; every shell carries a red band." },
        { key: "C", name: "Charge Bags", desc: "Stacked propellant bags on the deck; shells glow hotter orange with an orange trail." } ] },
      { name: "Wide Bursting Charge", cost: 200, effect: "Blast 70 to 85 px", options: [
        { key: "A", name: "Burst Charge Box", desc: "An orange-striped charge box on the deck; shells carry orange side stripes." },
        { key: "B", name: "Fragmentation Sleeve", desc: "A segmented sleeve on the barrel; shells show a fragmentation pattern." },
        { key: "C", name: "Wide Muzzle Brake", desc: "A baffled brake swaps the plain muzzle; the shells are fatter." } ] },
      { name: "HE Shells", cost: 730, effect: "110 damage (primary)", options: [
        { key: "A", name: "Dark HE Shells", desc: "Dark shells with a yellow band, in flight and in the tray; a yellow band on the barrel." },
        { key: "B", name: "Armoured Cradle", desc: "A thicker riveted cradle swaps the old one; dark yellow-banded shells." },
        { key: "C", name: "Double Rack", desc: "The tray becomes a double rack of dark shells; the same shells fly." } ] },
      { name: "Penetrator Shells", cost: 2930, effect: "120 damage; ignores 50% of armour", options: [
        { key: "A", name: "Hard Nose", desc: "A steel collar on the barrel; shells fly with a pointed steel nose, in the tray too." },
        { key: "B", name: "Tail Fins", desc: "Fin guides round the muzzle; shells fly with tail fins." },
        { key: "C", name: "Long Penetrators", desc: "A heavy collar at the breech; shells are long and slim, in the tray too." } ] },
      { name: "Siege Shells", cost: 7355, effect: "140 damage, 90 px blast, ignores 75% of armour (mastery)", options: [
        { key: "A", name: "Gold Siege Bands", desc: "Gold bands along the barrel; gold shells with a gold ring, gold seismic rings on impact." },
        { key: "B", name: "Gold Muzzle Brake", desc: "A gold-rimmed muzzle brake; gold shells." },
        { key: "C", name: "Siege Ram", desc: "A gold siege ram plate at the back of the rammer; gold shells." } ] },
    ] },
    { name: "Speed", theme: "faster reloading, then barrages", steps: [
      { name: "Drilled Crew", cost: 120, effect: "A shell every 3.3 s", options: [
        { key: "A", name: "Loader Arm", desc: "A loader arm on the deck that swings to the breech after each shot." },
        { key: "B", name: "Shell Hopper", desc: "A hopper of ready shells with a chute to the breech." },
        { key: "C", name: "Ready Lamps", desc: "A row of ready lamps that blink green as the crew reloads." } ] },
      { name: "Quick Breech", cost: 240, effect: "A shell every 2.9 s", options: [
        { key: "A", name: "Hydraulic Breech", desc: "Hydraulic pistons either side of the rammer that push in after each shot." },
        { key: "B", name: "Ratchet Wheel", desc: "A toothed ratchet wheel on the breech that clicks round once per shot." },
        { key: "C", name: "Cooling Fins", desc: "Cooling fins across the back of the cradle." } ] },
      { name: "Autoloader", cost: 1450, effect: "A shell every 2 s (primary)", options: [
        { key: "A", name: "Autoloader Drum", desc: "A turning drum of shells swaps the tray." },
        { key: "B", name: "Belt Feed", desc: "A shell belt runs from a crate to the breech; the tray goes." },
        { key: "C", name: "Twin Rammers", desc: "Two rammer rods side by side on a wider plate." } ] },
      { name: "Rapid Breech", cost: 1935, effect: "A shell every 1.7 s", options: [
        { key: "A", name: "Servo Motor", desc: "A servo motor box with a green lamp beside the breech." },
        { key: "B", name: "Dual Hoist", desc: "Two hoist arms either side of the breech." },
        { key: "C", name: "Recoil Springs", desc: "Springs coiled on the rammer rods; the barrel bands go." } ] },
      { name: "Rolling Barrage", cost: 3865, effect: "3-shell barrages that walk across the aimed spot; one shell per 1.4 s on average (mastery)", options: [
        { key: "A", name: "Triple Rammer", desc: "Three gold rammer rods; three shells walk across the spot, then a rest." },
        { key: "B", name: "Gold Feed Plate", desc: "A gold plate on the breech and a gold muzzle brake; three shells walk across." },
        { key: "C", name: "Triple Stack Tray", desc: "A three-row tray replaces the tray; three shells walk across." } ] },
    ] },
    { name: "Special Effects", theme: "shell types you switch between (the cannon cycles them in the preview)", steps: [
      { name: "Incendiary Shells", cost: 365, effect: "Unlocks incendiary: burning ground, 15 damage/s for 3 s", options: [
        { key: "A", name: "Fuel Tank", desc: "A red fuel tank with a hose to the breech; incendiary shells fly with a flame trail and leave burning ground." },
        { key: "B", name: "Igniter Coil", desc: "An orange igniter coil on the barrel." },
        { key: "C", name: "Flame Rack", desc: "Orange-tipped incendiary shells in the tray rack." } ] },
      { name: "Shrapnel Shells", cost: 195, effect: "Unlocks shrapnel: a 40 px wider blast at 70% damage", options: [
        { key: "A", name: "Shrapnel Crate", desc: "A crate of fragments by the deck; shrapnel shells are studded and burst in fragments." },
        { key: "B", name: "Fan Vanes", desc: "Fan vanes round the muzzle." },
        { key: "C", name: "Frag Collar", desc: "A spiked fragmentation collar on the barrel." } ] },
      { name: "Concussion Shells", cost: 1085, effect: "Unlocks concussion: everything in the blast stunned 0.5 s (primary)", options: [
        { key: "A", name: "Shock Coils", desc: "Three blue shock coils on the barrel; concussion shells ring blue and hit with shock rings." },
        { key: "B", name: "Pressure Tank", desc: "A blue pressure tank by the deck." },
        { key: "C", name: "Damper Pads", desc: "Blue damper pads on the deck with status lines." } ] },
      { name: "Improved Payloads", cost: 3505, effect: "Every shell type stronger: burn 22/s, shrapnel 85%, stun 0.7 s", options: [
        { key: "A", name: "Selector Dial", desc: "The shell selector grows into a bigger dial; every special mark is stronger." },
        { key: "B", name: "Colour-Coded Rack", desc: "The tray shells carry type colours." },
        { key: "C", name: "Fuse Computer", desc: "A fuse computer with a readout beside the selector." } ] },
      { name: "Combined Payload", cost: 5725, effect: "A fourth type that does all three at once (mastery)", options: [
        { key: "A", name: "Gold Selector", desc: "A gold-ringed selector with a fourth, gold type; the combined shell has three bands." },
        { key: "B", name: "Triple-Banded Barrel", desc: "Three type-coloured bands on the barrel; gold combined shells." },
        { key: "C", name: "Payload Magazine", desc: "A gold payload magazine on the deck; gold combined shells." } ] },
    ] },
  ],
  retrofits: [
    { name: "Shell Magazine", cost: 120, effect: "Every third shell is a heavy round for +50% damage", options: [
      { key: "A", name: "Drum Magazine", desc: "A drum magazine of shells on the deck with a three-lamp counter; every third shell flies large with a red ring." },
      { key: "B", name: "Box Magazine", desc: "A box magazine with a stack of shells and a counter." },
      { key: "C", name: "Rotary Rack", desc: "A turning three-shell rack with a counter." } ] },
    { name: "Stabilised Mount", cost: 120, effect: "Shells land within 15 px of the aimed spot instead of 30", options: [
      { key: "A", name: "Outrigger Stabilisers", desc: "Four stabiliser legs with feet in the corners of the deck." },
      { key: "B", name: "Gyro Housing", desc: "A spinning gyro in a housing on the deck." },
      { key: "C", name: "Hydraulic Dampers", desc: "Two damper cylinders either side of the cradle that squeeze in on each shot." } ] },
    { name: "Wide Charge", cost: 80, effect: "+15 px blast (85)", options: [
      { key: "A", name: "Fat Shells", desc: "A box of fat, wide-bodied shells on the deck; the shells fly wider." },
      { key: "B", name: "Wide Charge Boxes", desc: "Two striped charge boxes either side of the cradle; the shells fly wider." },
      { key: "C", name: "Flared Rim", desc: "A broad flared rim on the barrel; the shells fly wider." } ] },
  ],
};
// Round 1 shows all three options per stage, unpicked.
P2.picks = {};

// ---- Round 2 (owner's picks and notes, 2026-10-17): each stage shows only the pick, re-described where a note changed it.
P2.intro = "Round 2: your picks drawn as one model, with your note applied: the Long Penetrators now change the shape of the round itself, a long slim shell with a steel tip, in flight and in the tray. Use the build preview to check combinations.";
P2.picks = { p0s0: "A", p0s1: "B", p0s2: "A", p0s3: "C", p0s4: "B", p1s0: "A", p1s1: "A", p1s2: "A", p1s3: "C", p1s4: "A", p2s0: "B", p2s1: "B", p2s2: "C", p2s3: "C", p2s4: "A", r0: "A", r1: "A", r2: "A" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { st.options = st.options.filter((o) => o.key === P2.picks["p" + pi + "s" + k]); }));
P2.retrofits.forEach((rf, ri) => { rf.options = rf.options.filter((o) => o.key === P2.picks["r" + ri]); });
P2.paths[0].steps[3].options[0].desc = "From your note: the round itself changes shape. Shells are long and slim with a steel tip, in flight and in the tray; a heavy collar at the breech.";
