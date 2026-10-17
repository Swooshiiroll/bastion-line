// ---- Tower art second pass: Anti-Aircraft Turret (tower 5), round 1 ---------------------------------------------
// Base: look C Heavy Flak Cannon, animation A Alternating Barrels. One parametric model with the lessons so far:
// options swap parts; every barrel carries the other paths' details; each Power step changes the rounds; deck kit stays
// put while the turret turns; shots leave their own barrel. The Retrofits are kept as they are (owner, 2026-10-17).
// Geometry (game px, x along the aim): cannon from x 2 to its muzzle brake at 21.5 and muzzle at 23; recoil-spring rings
// at x 6 and 8; octagonal body r 7.5; rangefinder bar across the back at x -7 (y +-12); ammo crate at (-1, 9.5).
const PAGE = { title: "Anti-Aircraft Turret: paths and Retrofits (second pass)", store: "bl-tower-art-p2-aa-r3" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], BRASS = [0.86, 0.68, 0.32, 1], DARKR = [0.2, 0.2, 0.22, 1], SAND = [0.62, 0.55, 0.4, 1];
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null);
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };

// ---- Numbers ----------------------------------------------------------------------------------------------------------
const rateOf = (B) => [2.5, 2.8, 3.2, 4.5, 5.2, 7][B.lv[2]] * (B.r === 1 ? 1.1 : 1);
const burstPx = (B) => [0, 0, 20, 30, 40, 50][B.lv[1]];
const barrelLen = (B) => 21 + (B.lv[0] >= 1 ? 4 : 0) + (B.lv[0] >= 4 ? 4 : 0) + (B.lv[0] >= 5 ? 2 : 0);
function barrelsOf(B, t, fx) { const S = B.lv[2];
  if (S >= 5) { const st = Kp(B, 2, 4);
    if (st === "B") return { list: [[0, -8.6], [0, -5.4], [0, 5.4], [0, 8.6]], w: 2.4, arms: true };
    if (st === "C") { const sp = t * (fx.flash > 0 ? 16 : 2); return { list: [0, 1, 2, 3].map((i) => [0, Math.sin(sp + i * TAU / 4) * 3.2, Math.cos(sp + i * TAU / 4)]), w: 2.2, rotary: true }; }
    return { list: [[0, -6], [0, -2], [0, 2], [0, 6]], w: 2.4 }; }
  if (S >= 3) { const st = Kp(B, 2, 2);
    if (st === "B") return { list: [[2, -3], [-1, 3]], w: 3.2 };
    return { list: [[0, -3.2], [0, 3.2]], w: 3.2, shroud: st === "C" }; }
  return { list: [[0, 0]], w: 3.6 }; }

// ---- Rounds and flak ---------------------------------------------------------------------------------------------------
function aaRound(f, to, u, s, col, B) { const k = G(s), d = norm(sub(to, f)), o = orth(d), p = lerp(f, to, u), a = Math.atan2(d[1], d[0]);
  tracer(f, to, u, col, B.lv[0] >= 4 && Kp(B, 0, 3) === "A" ? 1.4 : 1.8, B.lv[0] >= 4 ? 0.32 : 0.22);
  const P1 = Kp(B, 0, 0), F = B.lv[1], gold = F >= 5 && Kp(B, 1, 4) === "A";
  if (F >= 2) { const r = (F >= 3 && Kp(B, 1, 2) === "A" ? 1.6 : 1.25) * k; disc(p, r + 0.4 * k, OUTLINE); disc(p, r, gold ? GOLD : DARKR); ring(p, r * 0.7, Kp(B, 1, 1) === "A" ? [1, 0.55, 0.2, 1] : METAL_L, 0.5 * k); }
  else if (P1 === "A") solid(p, [[2.2, 0], [1.3, 0.6], [-1.8, 0.6], [-1.8, -0.6], [1.3, -0.6]], BRASS, a, k, 0.6); }
function flakImpact(to, v, s, col, info, B) { const px = burstPx(B), k = G(s);
  if (!px) { if (v < 0.35) glowDot(to, s * 0.07 * (1 - v / 0.35), col); return; }
  const r = s * px / 48, p = add(to, [s * 0.06, -s * 0.05]), gold = B.lv[1] >= 5 && Kp(B, 1, 4) !== "B";
  if (v < 0.2) glowDot(p, r * 0.25 * (1 - v * 5), [1, 0.75, 0.35, 1]);
  disc(add(p, [0, -v * s * 0.08]), r * (0.18 + 0.22 * v), [0.2, 0.2, 0.22, 0.65 * (1 - v)]); // the flak puff
  if (v < 0.5) ring(p, r * (0.5 + v), A(gold ? GOLD : [1, 0.65, 0.3, 1], 0.45 * (1 - v / 0.5)), 1.2); // the burst's reach
  if (B.lv[1] >= 4 && Kp(B, 1, 3) === "B" && v < 0.5) for (let i = 0; i < 8; i++) line(add(p, mul(fa(i * 0.8), r * 0.3)), add(p, mul(fa(i * 0.8), r * (0.5 + v))), [0.9, 0.8, 0.6, 1 - v * 2], 1);
  if (info && info.ens) for (const e of info.ens) if (e.air && Math.hypot(e.p[0] - p[0], e.p[1] - p[1]) < r * 1.2 && v < 0.25) glowDot(e.p, s * 0.05, [1, 1, 0.9, 1]); }

// ---- The model ---------------------------------------------------------------------------------------------------------
function gunBarrel(c, aim, k, x, y, L, w, r, col, flash, B, gold, z) { const P0 = P(c, aim, k, x + 2 - r, y), P1 = P(c, aim, k, x + L - r, y);
  bar(P0, P1, w * k, z != null ? mix(METAL_D, METAL_L, 0.5 + 0.5 * z) : METAL_L);
  const at = (xx, yy = 0) => P(c, aim, k, x + xx - r, y + yy);
  for (const xx of [6, 8]) ring(at(xx + r * 0.5), w * 0.72 * k, Kp(B, 2, 0) === "A" ? lt(METAL_L, 0.1) : METAL_L, 1 * k);
  if (Kp(B, 2, 0) === "A") ring(at(10), w * 0.72 * k, METAL_L, 1 * k);
  if (Kp(B, 1, 1) === "C") line(at(12, -w * 0.55), at(12, w * 0.55), [1, 0.55, 0.2, 1], 1 * k);
  if (Kp(B, 1, 3) === "B") for (let xx = 9; xx < L - 4; xx += 2) line(at(xx, -w * 0.5), at(xx + 1, w * 0.5), [0, 0, 0, 0.35], 0.7 * k);
  if (gold) for (const xx of [10, L - 4]) line(at(xx, -w * 0.55), at(xx, w * 0.55), GOLD, 1.1 * k);
  if (Kp(B, 0, 0) === "B") bar(at(L - 7), at(L - 3), (w + 1.4) * k, METAL);
  if (Kp(B, 0, 3) === "C") for (let xx = 10; xx < L - 4; xx += 1.4) line(at(xx, -w * 0.5), at(xx + 0.7, w * 0.5), [0.78, 0.5, 0.28, 1], 0.6 * k);
  const brakeL = Kp(B, 0, 0) === "C" ? 3 : 1.6;
  plate(at(L + 0.5), rectPts(brakeL, w * 0.78), Kp(B, 0, 3) === "B" ? STEEL : METAL, aim, k, 1); line(at(L + 0.5, -w * 0.78), at(L + 0.5, w * 0.78), [0, 0, 0, 0.5], 0.8 * k);
  muzzleEnd(at(L + 0.5 + brakeL), k, w * 0.72, col, flash); }

const P2 = {
  tower: "aa", look: "C", anim: "A",
  intro: "Round 1: three options for every step and Retrofit (the Retrofits kept as they are), drawn as one model. Range swaps in longer barrels and raises the mount; Power/Blast changes the rounds each step, turning them into flak shells with growing airbursts; Speed adds barrels (2, then 4), each firing in turn from its own muzzle. Deck kit stays put. Unpicked steps show option A.",
  mods(B) { const nb = barrelsOf(B, 0, { flash: 0 }).list.length;
    return { period: 1 / rateOf(B), shot: (f, to, u, s, col) => aaRound(f, to, u, s, col, B), impact: (to, v, s, col, info) => flakImpact(to, v, s, col, info, B) }; },
  muzzleAt(B, m, kk, c, aim, s, info) { const Bl = barrelsOf(B, info.t, { flash: 1 }), b = Bl.list[m % Bl.list.length], brake = Kp(B, 0, 0) === "C" ? 3 : 1.6; return P(c, aim, G(s), b[0] + barrelLen(B) + 0.5 + brake, b[1]); },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), L = barrelLen(B), Bl = barrelsOf(B, t, fx), n = Bl.list.length, S = (x, y) => P(c, 0, k, x, y), kp = (pi, kk) => Kp(B, pi, kk);
    const fired = ((fx.shots || 1) - 1) % n, goldR = B.lv[0] >= 5, goldF = B.lv[1] >= 5, goldS = B.lv[2] >= 5;
    deck(c, k, col, t);
    // Deck kit (fixed): shell racks and crates, sky dish, deck radar, deck drum feed, sandbags.
    if (B.r === 2 && B.key("r2") === "C") for (let i = 0; i < 14; i++) { const q = add(c, mul(fa(i * TAU / 14), 17 * k)); shadedOval(q, 2.8 * k, 1.7 * k, i * TAU / 14 + Math.PI / 2, SAND); }
    if (kp(0, 2) === "C") { const q = S(12, -10); arc(q, 3 * k, t * 1.2 - 1, t * 1.2 + 1, OUTLINE, 2.4 * k); arc(q, 3 * k, t * 1.2 - 1, t * 1.2 + 1, METAL_L, 1.4 * k); glowDot(q, 0.6 * k, col); }
    if (goldR && kp(0, 4) === "C") { const q = S(-12, -10); bar(q, S(-12, -14), 1 * k, METAL_L); const pu = fmod(t, 1); glowDot(S(-12, -14), 1 * k, GOLD); ring(S(-12, -14), pu * 6 * k, A(GOLD, 0.6 * (1 - pu)), 1); }
    if (kp(1, 0) === "C") { plate(S(12.5, 4), rectPts(1.8, 4), METAL_D, 0, k, 0.9); for (let i = 0; i < 3; i++) orb(S(12.5, 1.5 + i * 2.5), 0.9 * k, B.lv[1] >= 2 ? DARKR : BRASS); }
    if (kp(1, 2) === "C") plate(S(-12.5, 4), rectPts(2.4, 2), AMMO, 0, k, 1);
    if (goldF && kp(1, 4) === "C") for (const y of [8, 11]) { plate(S(-12.5, y), rectPts(2.4, 1.3), AMMO, 0, k, 0.9); line(S(-14.5, y), S(-10.5, y), GOLD, 0.8 * k); }
    if (B.r === 0 && B.key("r0") === "C") { const q = S(12, 10); orb(q, 2 * k, METAL); line(q, add(q, mul(fa(t * 3), 3.4 * k)), METAL_L, 1.4 * k); glowDot(add(q, mul(fa(t * 3), 3.4 * k)), 0.6 * k, col); }
    // The mount: raised by the Range path (a pedestal shadow, rams or a mast) under the body.
    if (kp(0, 1) === "A") { ellipse(add(c, [3 * k, 5 * k]), 12 * k, 6 * k, [0, 0, 0, 0.25]); disc(c, 10 * k, OUTLINE); disc(c, 9.3 * k, METAL_D); ring(c, 8 * k, METAL, 1.2 * k); }
    if (kp(0, 1) === "C") for (let i = 0; i < 3; i++) { const a = -Math.PI / 2 + i * TAU / 3; bar(add(c, mul(fa(a), 4 * k)), add(c, mul(fa(a), 13 * k)), 2 * k, lt(METAL_D, 0.12)); }
    if (B.r === 1 && B.key("r1") === "C") { const q = P(c, aim, k, -2, -10); bar(q, P(c, aim, k, -2, -6), 1.2 * k, [0.5, 0.42, 0.28, 1]); disc(q, 3 * k, OUTLINE); disc(q, 2.6 * k, METAL); }
    // The traverse ring sits on the baseplate under the turret (owner, round 2).
    if (kp(2, 1) === "A") { ring(c, 9 * k, OUTLINE, 2.4 * k); for (let i = 0; i < 16; i++) { const d2 = fa(i * TAU / 16 + aim); line(add(c, mul(d2, 8.4 * k)), add(c, mul(d2, 10 * k)), METAL_L, 1 * k); } }
    // The turret: rangefinder bar, (twin-arm frame), barrels, body, crate.
    bar(P(c, aim, k, -7, -12), P(c, aim, k, -7, 12), 2.2 * k, METAL); for (const y of [-12, 12]) { orb(P(c, aim, k, -7, y), 1.9 * k, goldR && kp(0, 4) === "B" ? GOLD : METAL_L); glowDot(P(c, aim, k, -6.2, y), 0.8 * k, col); }
    if (kp(0, 1) === "B") for (const sg of [-1, 1]) bar(P(c, aim, k, -4, sg * 5), P(c, aim, k, 4, sg * 4), 1.6 * k, STEEL);
    if (Bl.arms) for (const sg of [-1, 1]) { bar(c, P(c, aim, k, 0, sg * 7), 2.4 * k, METAL); plate(P(c, aim, k, 3, sg * 7), rectPts(3, 3), METAL_L, aim, k, 1); }
    if (Bl.shroud) plate(P(c, aim, k, 9, 0), rectPts(5, 5.4), METAL, aim, k, 1);
    const order = Bl.rotary ? Bl.list.map((b, i) => [b, i]).sort((a, b2) => a[0][2] - b2[0][2]) : Bl.list.map((b, i) => [b, i]);
    for (const [b, i] of order) { const rr = (Bl.rotary ? fx.recoil : i === fired ? decay(fx.barrelSince ?? 9, 0.15) : 0) * 3; gunBarrel(c, aim, k, b[0], b[1], L, Bl.w, rr, col, i === fired || Bl.rotary ? fx.flash : 0, B, goldS && kp(2, 4) !== "C" || goldF && kp(1, 4) === "B", Bl.rotary ? b[2] : null); }
    if (Bl.rotary) ring(P(c, aim, k, L - 2, 0), 4.6 * k, GOLD, 1.2 * k);
    if (kp(0, 3) === "B") ring(P(c, aim, k, L + 3, 0), 3 * k, A(col, 0.7), 1 * k);
    if (kp(2, 3) === "A") for (const [b] of Bl.list.map((b, i) => [b, i])) line(P(c, aim, k, -1, 8), P(c, aim, k, b[0] + 3, b[1]), [0.55, 0.45, 0.25, 1], 1.4 * k);
    plate(c, ngon(8, 1, Math.PI / 8), METAL_L, aim, 7.5 * k, 1.2); rivets(c, ngon(8, 1, Math.PI / 8), aim, 7.5 * k, 0.82, 0.6 * k);
    const drumMag = B.r === 1 && B.key("r1") === "A";
    if (drumMag) { orb(P(c, aim, k, -1, 9.5), 3.6 * k, METAL); ring(P(c, aim, k, -1, 9.5), 2.4 * k, A(col, 0.6), 1 * k); disc(P(c, aim, k, -1, 9.5), 0.9 * k, METAL_D); }
    else plate(P(c, aim, k, -1, 9.5), rectPts(4, 2.6), AMMO, aim, k, 1); // the drum magazine takes the crate's place (owner)
    // Turret-top kit: radars, directors, fuse box, gears, motors, belts, drums, shields.
    if (kp(0, 2) === "A" || goldR && kp(0, 4) === "A") { const q = P(c, aim, k, -3, -5), a = t * 2, R0 = goldR && kp(0, 4) === "A" ? 4.4 : 3.2; arc(q, R0 * k, a - 1, a + 1, OUTLINE, 2.4 * k); arc(q, R0 * k, a - 1, a + 1, goldR && kp(0, 4) === "A" ? GOLD : METAL_L, 1.4 * k); glowDot(q, 0.6 * k, col); }
    if (kp(0, 2) === "B" || goldR && kp(0, 4) === "B") { const q = P(c, aim, k, -1, -5.5); plate(q, rectPts(2, 2.6), METAL, aim, k, 1); for (const y of [-1.2, 1.2]) glowDot(P(c, aim, k, 1.2, -5.5 + y), 0.6 * k, goldR && kp(0, 4) === "B" ? GOLD : col); }
    if (kp(1, 1) === "B") { plate(P(c, aim, k, -3, 5), rectPts(1.6, 1.2), METAL_D, aim, k, 0.8); glowDot(P(c, aim, k, -3, 5), 0.5 * k, [1, 0.55, 0.2, 1]); }
    if (kp(1, 2) === "B") plate(P(c, aim, k, 6, 0), [[1.4, -6], [1.4, 6], [-1.2, 5], [-1.2, -5]], STEEL, aim, k, 1);
    if (kp(2, 0) === "B") { const q = P(c, aim, k, -4, 4); disc(q, 1.8 * k, OUTLINE); for (let i = 0; i < 6; i++) line(q, add(q, mul(fa(t * 8 + i), 1.6 * k)), METAL_L, 0.8 * k); }
    if (kp(2, 0) === "C") for (let i = 0; i < 3; i++) line(P(c, aim, k, -3 + i * 1.4, -4), P(c, aim, k, -3 + i * 1.4, 4), [0, 0, 0, 0.45], 0.8 * k);
    if (kp(2, 1) === "B") plate(P(c, aim, k, -4.5, -4), rectPts(1.6, 1.6), METAL_D, aim, k, 0.9);
    if (kp(2, 1) === "C") for (const sg of [-1, 1]) { const q = P(c, aim, k, 0, sg * 8.6); ring(q, 1.6 * k, METAL_L, 0.8 * k); line(q, add(q, mul(fa(t * 2), 1.6 * k)), METAL_L, 0.6 * k); }
    if (kp(2, 3) === "B") for (const y of [-4.5, 4.5]) { const q = P(c, aim, k, -4, y); disc(q, 1.6 * k, OUTLINE); for (let i = 0; i < 6; i++) line(q, add(q, mul(fa(t * 9 * Math.sign(y) + i), 1.4 * k)), METAL_L, 0.7 * k); }
    if (kp(2, 3) === "C") { orb(P(c, aim, k, -1, -9.5), 3 * k, METAL); ring(P(c, aim, k, -1, -9.5), 2 * k, A(col, 0.6), 0.9 * k); }
    if (B.r === 0 && B.key("r0") === "A") { const q = P(c, aim, k, -4, 6), a = t * 3; arc(q, 2.6 * k, a - 1.2, a + 1.2, OUTLINE, 2 * k); arc(q, 2.6 * k, a - 1.2, a + 1.2, A(col, 0.9), 1.2 * k); }
    if (B.r === 0 && B.key("r0") === "B") { plate(P(c, aim, k, -4, 6), rectPts(1.4, 2.4), [0.15, 0.2, 0.2, 1], aim, k, 0.9); for (let i = 0; i < 3; i++) glowDot(P(c, aim, k, -4, 4.8 + i * 1.2), 0.35 * k, fmod(t * 3 - i, 3) < 1 ? col : A(col, 0.3)); }
    if (B.r === 1 && B.key("r1") === "B") for (const x of [-5, -1]) { orb(P(c, aim, k, x, -9.5), 2.2 * k, METAL); ring(P(c, aim, k, x, -9.5), 1.4 * k, A(col, 0.6), 0.8 * k); }
    if (B.r === 2 && B.key("r2") === "A") plate(P(c, aim, k, 8.5, 0), [[1.4, -6.5], [1.4, 6.5], [-1.2, 5.5], [-1.2, -5.5]], STEEL, aim, k, 1.1);
    if (B.r === 2 && B.key("r2") === "B") plate(c, ngon(8, 1, Math.PI / 8), STEEL, aim, 6 * k, 1);
    orb(c, 3.6 * k, METAL); glowDot(P(c, aim, k, 1.2, 0), 1.2 * k, col);
  },
  paths: [
    { name: "Range", theme: "area denial: longer barrels and a higher mount", steps: [
      { name: "Long Barrel", cost: 40, effect: "+20 range (180)", options: [
        { key: "A", name: "Longer Barrel", desc: "The barrel is swapped for a longer one (every barrel, when there are more)." },
        { key: "B", name: "Barrel Sleeve", desc: "A longer barrel with a heavy sleeve near the muzzle." },
        { key: "C", name: "Long Brake", desc: "A longer barrel with an extended muzzle brake." } ] },
      { name: "Higher Mount", cost: 75, effect: "+20 range (200)", options: [
        { key: "A", name: "Raised Pedestal", desc: "The turret stands on a raised pedestal with a longer shadow." },
        { key: "B", name: "Elevation Rams", desc: "Hydraulic elevation rams either side of the guns." },
        { key: "C", name: "Tripod Mast", desc: "A braced tripod mast under the turret." } ] },
      { name: "Sky Watch", cost: 300, effect: "+40 range (240) (primary)", options: [
        { key: "A", name: "Search Radar", desc: "A turning search radar on the turret." },
        { key: "B", name: "Optical Director", desc: "A twin-lens optical director on the turret." },
        { key: "C", name: "Sky Dish", desc: "A turning sky-search dish on the deck." } ] },
      { name: "High-Velocity Rounds", cost: 600, effect: "+40 range (280)", options: [
        { key: "A", name: "HV Barrel", desc: "A longer barrel; rounds fly as thinner, faster tracers." },
        { key: "B", name: "Muzzle Booster", desc: "A longer barrel with a steel booster on the muzzle brake and a glowing ring ahead." },
        { key: "C", name: "Rifling Coils", desc: "A longer barrel wound with copper coils." } ] },
      { name: "Sky Wall", cost: 1500, effect: "330 range: a big circle of sky (mastery)", options: [
        { key: "A", name: "Gold Sky Radar", desc: "A big gold search radar on the turret." },
        { key: "B", name: "Gold Director", desc: "A gold optical director and gold rangefinder lenses." },
        { key: "C", name: "Sky Wall Beacon", desc: "A gold beacon on the deck pulsing a ring into the sky." } ] },
    ] },
    { name: "Power/Blast Radius", theme: "flak shells: each step changes the rounds; airbursts grow", steps: [
      { name: "Heavier Rounds", cost: 70, effect: "+6 damage (31)", options: [
        { key: "A", name: "Brass Rounds", desc: "Brass bullets on the tracers." },
        { key: "B", name: "Heavy Breech", desc: "A heavy breech collar on every barrel." },
        { key: "C", name: "Shell Rack", desc: "A rack of ready rounds on the deck." } ] },
      { name: "Flak Rounds", cost: 375, effect: "Rounds burst near their target: a 20 px airburst", options: [
        { key: "A", name: "Flak Fuzes", desc: "Dark flak shells with an orange fuze ring; they burst beside the flyer in a dark puff." },
        { key: "B", name: "Fuze-Setter Box", desc: "A fuze-setter box on the turret; dark flak shells burst beside the flyer." },
        { key: "C", name: "Flak Bands", desc: "Orange flak bands on every barrel; dark flak shells burst beside the flyer." } ] },
      { name: "Flak Shells", cost: 795, effect: "36 damage; 30 px airburst (primary)", options: [
        { key: "A", name: "Heavy Flak", desc: "Fatter flak shells; bigger bursts." },
        { key: "B", name: "Gun Shield", desc: "An armoured gun shield across the barrels; bigger bursts." },
        { key: "C", name: "Second Crate", desc: "A second ammo crate on the deck; bigger bursts." } ] },
      { name: "Wide Burst", cost: 865, effect: "40 px airburst", options: [
        { key: "A", name: "Burst Charges", desc: "Bigger bursts (no new part)." },
        { key: "B", name: "Frag Sleeves", desc: "Segmented sleeves on the barrels; bursts throw fragment streaks." },
        { key: "C", name: "Wide Fuze", desc: "Bigger bursts (no new part)." } ] },
      { name: "Flak Curtain", cost: 4325, effect: "42 damage; 50 px airburst (mastery)", options: [
        { key: "A", name: "Gold Flak", desc: "Gold flak shells; gold-ringed curtains of bursts." },
        { key: "B", name: "Curtain Battery", desc: "Gold bands on every barrel; wide bursts." },
        { key: "C", name: "Gold Crates", desc: "Gold-striped ammo crates on the deck; gold-ringed bursts." } ] },
    ] },
    { name: "Speed", theme: "rate of fire, then more barrels firing in turn", steps: [
      { name: "Quick Cycle", cost: 35, effect: "2.8 rounds/s", options: [
        { key: "A", name: "Extra Springs", desc: "A third recoil-spring ring on every barrel." },
        { key: "B", name: "Cycling Gear", desc: "A spinning cycling gear on the turret." },
        { key: "C", name: "Cooling Vents", desc: "Vent slots across the turret's back." } ] },
      { name: "Fast Traverse", cost: 95, effect: "3.2 rounds/s; turns faster onto new flyers", options: [
        { key: "A", name: "Traverse Ring", desc: "A toothed traverse ring under the turret." },
        { key: "B", name: "Traverse Motor", desc: "A traverse motor box on the turret." },
        { key: "C", name: "Handwheels", desc: "Two turning handwheels on the flanks." } ] },
      { name: "Twin Barrels", cost: 625, effect: "4.5 rounds/s (primary)", options: [
        { key: "A", name: "Twin Cannons", desc: "Two cannons side by side, firing in turn." },
        { key: "B", name: "Staggered Pair", desc: "Two cannons staggered, firing in turn." },
        { key: "C", name: "Shrouded Twins", desc: "Two cannons in a shared shroud, firing in turn." } ] },
      { name: "Belt Feed", cost: 675, effect: "5.2 rounds/s", options: [
        { key: "A", name: "Belt Feeds", desc: "Ammo belts from the crate to every barrel." },
        { key: "B", name: "Feed Gears", desc: "Spinning feed gears either side." },
        { key: "C", name: "Drum Feed", desc: "A big drum magazine on the turret." } ] },
      { name: "Quad Mount", cost: 3460, effect: "7 rounds/s from four barrels (mastery)", options: [
        { key: "A", name: "Quad Cannons", desc: "Four gold-banded cannons in a row, firing in turn." },
        { key: "B", name: "Twin-Twin Arms", desc: "Two gold-banded pairs on side arms." },
        { key: "C", name: "Rotary Quad", desc: "Four barrels spinning in a gold-ringed rotary cluster." } ] },
    ] },
  ],
  retrofits: [
    { name: "Fire-Control Radar", cost: 45, effect: "+15 range and steadier aim", options: [
      { key: "A", name: "Rotating Dish", desc: "A small rotating radar dish beside the guns." },
      { key: "B", name: "Phased Panel", desc: "A phased-array panel whose lights sweep." },
      { key: "C", name: "Deck Radar", desc: "A turning radar on the deck." } ] },
    { name: "Ammo Drum", cost: 30, effect: "+10% fire rate (2.75 rounds/s)", options: [
      { key: "A", name: "Big Drum", desc: "A big drum magazine on the turret." },
      { key: "B", name: "Twin Drums", desc: "Two drum magazines." },
      { key: "C", name: "Deck Drum Feed", desc: "A drum on the deck feeding the turret." } ] },
    { name: "Armoured Mount", cost: 50, effect: "+4 damage (29)", options: [
      { key: "A", name: "Gun Shield", desc: "An armoured gun shield across the barrels." },
      { key: "B", name: "Armour Cowl", desc: "An armoured cowl over the turret body." },
      { key: "C", name: "Sandbag Ring", desc: "A ring of sandbags round the deck." } ] },
  ],
};

// ---- Round 2 (owner's picks and notes, 2026-10-17) ----------------------------------------------------------------
P2.intro = "Round 3: the Ammo Drum replaces the ammo crate (your note). Round 2: your picks as one model. The traverse ring now sits on the baseplate under the turret (your note). Range step 3 (Sky Watch) had no pick: its three options are still open below.";
P2.picks = { p0s0: "A", p0s1: "A", p0s3: "A", p0s4: "A", p1s0: "B", p1s1: "A", p1s2: "A", p1s3: "B", p1s4: "B", p2s0: "A", p2s1: "A", p2s2: "A", p2s3: "B", p2s4: "A", r0: "A", r1: "A", r2: "B" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { const pk = P2.picks["p" + pi + "s" + k]; if (pk) st.options = st.options.filter((o) => o.key === pk); }));
P2.retrofits.forEach((rf, ri) => { rf.options = rf.options.filter((o) => o.key === P2.picks["r" + ri]); });
P2.paths[2].steps[1].options[0].desc = "A toothed traverse ring on the baseplate, under the turret (your note).";
P2.retrofits[1].options[0].desc = "A big drum magazine that replaces the ammo crate (your note).";
