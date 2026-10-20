// ---- Tower art second pass: Gun Turret (tower 1), round 2 -------------------------------------------------------
// Base: look C Rotary Gun, animation C Rapid Stream. The owner picked every step in round 1; round 2 draws those picks
// as one parametric model so details from different paths work together (owner's notes, 2026-10-17):
// - Range 1 swaps the barrels for longer ones (not an overlay); every gun on the mount gets them, and Range 3's fluting.
// - Power 2's marked shroud sits on the front shroud ring, over the barrels, wherever the muzzle is; Power's mastery
//   and Multi-Target's mastery turn it gold instead of adding a new shroud.
// - Range 2 turns the drum's ring red instead of adding a red circle.
// - Extra guns (Multi-Target) sit on their own swivel mounts with bodies bigger than their barrels, aim at their own
//   targets, and get Power's shielding (from Power 1) and marked shroud, Range's barrels, and the Retrofit's jacket,
//   coils or fuel line.
// - The Water Jacket and Coil Wraps grow with the longer Range barrels.
const PAGE = { title: "Gun Turret: paths and Retrofits (second pass)", store: "bl-tower-art-p2-gun-r7" };
const GOLD = [1, 0.78, 0.3, 1], RED_TIP = [1, 0.3, 0.25, 1], STEEL = [0.42, 0.45, 0.5, 1];
const SHOCK = [0.6, 0.85, 1, 1], FIRE = [1, 0.55, 0.2, 1], WATER = [0.3, 0.42, 0.5, 1];
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const spinOf = (fx, t) => t * (fx.recoil > 0 || fx.flash > 0 ? 30 : 3);
function longTracer(f, to, u, col, w) { const a = lerp(f, to, Math.max(0, u - 0.6)), b = lerp(f, to, u); line(a, b, A(col, 0.35), w * 2.4); line(a, b, A(col, 0.95), w); line(a, b, [1, 1, 1, 0.8], w * 0.35); }
function stunArcs(to, v, s, info) { if (!info || !info.sh || info.sh.m % 20 !== 0 || v >= 1) return; for (let i = 0; i < 4; i++) { const a = rnd2(i + Math.floor(v * 12)) * TAU; line(to, add(to, mul(fa(a), s * 0.16)), A(SHOCK, 1 - v), 1.4); } glowDot(to, s * 0.06 * (1 - v), SHOCK); }
function flames(to, v, s) { if (v >= 1) return; for (let i = 0; i < 3; i++) { const q = fmod(v * 2 + i / 3, 1); disc(add(to, [(i - 1) * s * 0.05, -q * s * 0.18]), s * 0.035 * (1 - q), A(i % 2 ? FIRE : [1, 0.85, 0.3, 1], 1 - q)); } }
function gear(p, r, k, t, n, col) { const pts = []; for (let i = 0; i < n * 2; i++) pts.push(mul(fa(t + i * Math.PI / n), i % 2 ? r * 0.78 : r)); solid(p, pts, col || METAL_L, 0, k, 0.8); disc(p, r * 0.35 * k, METAL_D); }
// The rounds harden with each Power step (owner, 2026-10-17): 1 a thicker tracer with a heavier head; 2 a dark steel
// tip; 3 a dark core with a yellow AP band; 4 a white-hot tungsten core; M a slim sabot dart that sheds its petals at
// the muzzle, with a gold streak.
function powerRound(f, to, u, s, col, Pl) { if (Pl < 1) return; const k = G(s), d = norm(sub(to, f)), o = orth(d), p = lerp(f, to, u), a = Math.atan2(d[1], d[0]);
  // Slim bullets (owner: "They should still look like bullets"): a pointed round about 4 x 1.2 game px.
  const BODY = [[2.2, 0], [1.3, 0.6], [-1.8, 0.6], [-1.8, -0.6], [1.3, -0.6]], NOSE = [[2.2, 0], [1.1, 0.6], [1.1, -0.6]];
  if (Pl >= 5) { solid(p, [[3, 0], [-2.6, 0.35], [-2.6, -0.35]], [0.88, 0.89, 0.92, 1], a, k, 0.6); for (const sg of [-1, 1]) fill(p, [[-1.6, sg * 0.3], [-2.6, sg * 0.9], [-2.6, sg * 0.3]], [0.62, 0.64, 0.68, 1], a, k);
    line(add(p, mul(d, -2.6 * k)), add(p, mul(d, -1.4 * k)), GOLD, 0.8 * k);
    if (u < 0.25) for (const sg of [-1, 1]) { const q = add(add(f, mul(d, u * s * 0.9)), mul(o, sg * u * s * 0.5)); fill(q, [[1, 0], [-0.7, 0.5], [-0.7, -0.5]], [0.62, 0.64, 0.68, 1 - u * 4], a + sg * u * 8, k); }
    return; }
  const body = Pl >= 3 ? [0.16, 0.15, 0.15, 1] : [0.86, 0.68, 0.32, 1]; // brass, then a dark AP round
  solid(p, BODY, body, a, k, 0.6);
  if (Pl >= 2) fill(p, NOSE, [0.66, 0.69, 0.74, 1], a, k); // steel tip
  if (Pl >= 3) line(add(add(p, mul(d, -0.9 * k)), mul(o, 0.6 * k)), add(add(p, mul(d, -0.9 * k)), mul(o, -0.6 * k)), [1, 0.85, 0.2, 1], 0.6 * k); // AP band
  if (Pl >= 4) glowDot(add(p, mul(d, -1.8 * k)), 0.45 * k, [1, 0.95, 0.85, 1]); } // white-hot tungsten core showing at the base
function vapourAt(p, fx, s) { if (fx.flash > 0.6) smokePuff(add(p, [0, -s * 0.05]), 1 - fx.flash, s * 0.5, 0.35); }

// The build: levels P (Power), R (Range/Visibility), M (Multi-Target), and the Retrofit r (0 water, 1 shock, 2 incendiary).
const lvOf = (B) => ({ P: B.lv[0], R: B.lv[1], M: B.lv[2], r: B.r });
const mainLen = (R) => (R >= 1 ? 24 : 19); // barrel end (game px along the aim); the muzzle is 1 further
const extraLen = (R) => (R >= 1 ? 15 : 11);
const gunsOf = (M) => (M >= 5 ? 3 : M >= 2 ? 2 : 1);
const mountOf = (i) => [1, i === 1 ? -10.5 : 10.5]; // extra gun mounts, on the main turret's flanks

// Extra guns swivel on their own: each aims at the target its shots go to (info.order[i]), turning at 7 rad/s.
function extraAims(info, c, aim, k, n) {
  const v = info.view; v.ex ||= {}; const dt = Math.min(0.25, Math.max(0, info.t - (v.ex.t ?? info.t))); v.ex.t = info.t; const out = [];
  for (let i = 1; i < n; i++) { const mp = P(c, aim, k, ...mountOf(i)), o = info.order || [], tg = (o[i] || o[0] || {}).p;
    const want = tg ? Math.atan2(tg[1] - mp[1], tg[0] - mp[0]) : aim; let a = v.ex[i] ?? aim; const d = fmod(want - a + Math.PI, TAU) - Math.PI;
    a += Math.max(-7 * dt, Math.min(7 * dt, d)); v.ex[i] = a; out[i] = a; }
  return out; }

// A rotary cluster at c0 aimed along a: n barrels from x0 to x1 at radius rad; fluted at Range 3.
function cluster(c0, a, k, fx, t, x0, x1, rad, w, n, ringCol, R) { const sp = spinOf(fx, t), rc = fx.recoil * 1.5;
  const bs = []; for (let i = 0; i < n; i++) bs.push({ y: Math.sin(sp + i * TAU / n) * rad, z: Math.cos(sp + i * TAU / n) }); bs.sort((p, q) => p.z - q.z);
  for (const b of bs) { bar(P(c0, a, k, x0 - rc, b.y), P(c0, a, k, x1 - rc, b.y), w * k, mix(METAL_D, METAL_L, 0.5 + 0.5 * b.z));
    if (R >= 3 && b.z > 0) for (let x = x0 + 4; x <= x1 - 2; x += 1.8) line(P(c0, a, k, x - rc, b.y - w * 0.3), P(c0, a, k, x + 0.9 - rc, b.y + w * 0.3), lt(METAL_L, 0.35), 0.6 * k); }
  for (const x of [x0 + 3, x1 - 1]) bar(P(c0, a, k, x - rc, -rad - 1.4), P(c0, a, k, x - rc, rad + 1.4), 1.5 * k, ringCol || METAL_L);
  for (const b of bs) disc(P(c0, a, k, x1 - rc, b.y), w * 0.32 * k, A(BORE, 0.55 + 0.45 * Math.max(0, b.z)));
  flashTip(P(c0, a, k, x1 - rc, bs[bs.length - 1].y), k, w, fx); }
// The firing barrel is the one on top of the spinning cluster: its lateral offset at time t.
const topBarrelY = (t, fx, rad, n) => { const sp = spinOf(fx, t); let best = -2, y = 0; for (let i = 0; i < n; i++) { const z = Math.cos(sp + i * TAU / n); if (z > best) { best = z; y = Math.sin(sp + i * TAU / n) * rad; } } return y; };
function flashTip(p, k, w, fx) { const f = Math.max(0, (fx.flash - 0.35) / 0.65); if (f > 0) { disc(p, w * 0.45 * k, [1, 0.92, 0.7, f]); disc(p, w * 1.2 * k * f, [1, 0.95, 0.8, 0.3 * f]); } }

// What's on every gun's barrels: the Retrofit sleeve, then Power's marked shroud on the front ring.
function barrelKit(c0, a, k, fx, t, x0, x1, half, Lv, gold, col) { const rc = fx.recoil * 1.5;
  if (Lv.r === 0) plate(P(c0, a, k, (x0 + x1) / 2 - rc, 0), rectPts((x1 - x0) / 2, half + 0.8), WATER, a, k, 1);
  if (Lv.r === 1) { for (let x = x0; x <= x1; x += 1.5) line(P(c0, a, k, x - rc, -half - 1), P(c0, a, k, x + 0.7 - rc, half + 1), [0.35, 0.45, 0.6, 1], 1 * k); glowDot(P(c0, a, k, (x0 + x1) / 2 - rc, 0), 0.7 * k, A(SHOCK, 0.5 + 0.5 * Math.sin(t * 9))); }
  if (Lv.P >= 2) { const mc = gold ? GOLD : col; for (const dx of [0, 1.4]) line(P(c0, a, k, x1 + 2 - dx - rc, -half - 1.4), P(c0, a, k, x1 + 2 - dx - rc, half + 1.4), A(mc, 0.95), 1 * k); } }

const P2 = {
  tower: "gun", look: "C", anim: "C",
  picks: { p0s0: "C", p0s1: "C", p0s2: "C", p0s3: "B", p0s4: "B", p1s0: "A", p1s1: "B", p1s2: "A", p1s3: "B", p1s4: "C", p2s0: "A", p2s1: "A", p2s2: "A", p2s3: "C", p2s4: "A", r0: "A", r1: "A", r2: "A" },
  intro: "Round 2: your round-1 picks drawn as one model, so the paths work together (your notes). Each stage shows only your pick; use the build preview to check combinations, and note anything to change.",
  mods(B) { const L = lvOf(B), n = gunsOf(L.M);
    return { targets: n, crit: [0, 0, 0.1, 0.15, 0.2, 0.3][L.R],
      shot: (f, to, u, s, col) => { const c2 = L.r === 2 ? FIRE : col, w = 1.4;
        if (L.P >= 5) line(lerp(f, to, Math.max(0, u - 0.3)), lerp(f, to, u), A(GOLD, 0.8), w * 0.8);
        if (L.R >= 2) longTracer(f, to, u, c2, w); else tracer(f, to, u, c2, w, 0.2); powerRound(f, to, u, s, c2, L.P); },
      impactFx: (to, v, s, col, info) => { if (L.r === 1) stunArcs(to, v, s, info); if (L.r === 2) flames(to, v, s); } }; },
  muzzleAt(B, m, kk, c, aim, s, info) { const L = lvOf(B), k = G(s), n = gunsOf(L.M), i = kk % n;
    const fxF = { recoil: 1, flash: 1 }; // firing: the cluster spins fast
    if (i === 0) return P(c, aim, k, mainLen(L.R), topBarrelY(info.t, fxF, 3.4, 4));
    const a = (info.view.ex && info.view.ex[i]) ?? aim; return P(P(c, aim, k, ...mountOf(i)), a, k, extraLen(L.R), L.M >= 3 ? topBarrelY(info.t, fxF, 2.4, 4) : 0); },
  model(c, aim, s, fx, t, col, info, B) {
    const L = lvOf(B), k = G(s), rc = fx.recoil * 1.5, len = mainLen(L.R), n = gunsOf(L.M), gold = L.P >= 5 || L.M >= 5;
    const ex = extraAims(info, c, aim, k, n), drum = L.M >= 5 ? P(c, aim, k, -7, 6) : P(c, aim, k, -1, 8.5);
    deck(c, k, col, t);
    // Under the turret: Multi 1's bearing rollers.
    if (L.M >= 1) { ring(c, 9.5 * k, OUTLINE, 2.6 * k); ring(c, 9.5 * k, METAL_L, 1.6 * k); for (let i = 0; i < 16; i++) { const d2 = fa(i * TAU / 16 + aim); line(add(c, mul(d2, 9.5 * k)), add(c, mul(d2, 11 * k)), METAL_L, 1 * k); } }
    // The back: vent block, Power 4's counterweight or Multi 4's hopper.
    plate(P(c, aim, k, -8, 0), rectPts(3, 5.5), lt(METAL_D, 0.1), aim, k, 1); for (let i = 0; i < 3; i++) line(P(c, aim, k, -9.5 + i * 1.5, -4), P(c, aim, k, -9.5 + i * 1.5, 4), A(col, 0.5 + 0.4 * (i === 2)), 0.9 * k);
    if (L.P >= 4) { plate(P(c, aim, k, -11.5, 0), rectPts(2.4, 6.4), STEEL, aim, k, 1.1); hazard(c, aim, k, -13, -10, 6.8, col, 1.2); hazard(c, aim, k, -13, -10, -6.8, col, 1.2); }

    // The main gun: barrels swapped longer at Range 1, fluted at Range 3; the Retrofit sleeve; the marked shroud.
    cluster(c, aim, k, fx, t, 5, len, 3.4, 1.8, 4, L.M >= 5 ? GOLD : METAL_L, L.R);
    barrelKit(c, aim, k, fx, t, 9, len - 3, 3.4, L, gold, col);
    if (L.r === 0) vapourAt(P(c, aim, k, len + 1, 0), fx, s);
    if (L.P >= 1) { plate(P(c, aim, k, 4.5 - rc, 0), rectPts(2.2, 5.4), STEEL, aim, k, 1); rivets(P(c, aim, k, 4.5 - rc, 0), rectPts(2.2, 5.4), aim, k, 0.7, 0.6 * k); }
    // The drum (red ring from Range 2's tracers), the body, its cheeks, the lens crown and the gold mastery ring.
    orb(drum, 4.2 * k, METAL); ring(drum, 2.8 * k, L.R >= 2 ? RED_TIP : A(col, 0.7), 1.2 * k);
    plate(c, ngon(6, 1, 0), METAL_L, aim, 6.8 * k, 1.2); orb(c, 3.6 * k, METAL); glowDot(P(c, aim, k, 1.2, 0), 1.2 * k, col);
    if (L.P >= 3) for (const sg of [-1, 1]) plate(P(c, aim, k, 0, sg * 6.4), [[5, -sg * 1.2], [5, sg * 1.6], [-5, sg * 2.2], [-6, -sg * 1]], STEEL, aim, k, 1);
    if (L.R >= 5) { plate(c, ngon(6, 1, 0), METAL_L, aim, 5.6 * k, 1); outline(c, ngon(6, 1, 0), GOLD, 1.2 * k, aim, 5.6 * k); disc(c, 3.4 * k, A(col, 0.55)); disc(add(c, mul(LIGHT, 1.2 * k)), 1.2 * k, [1, 1, 1, 0.6]); }
    if (L.P >= 5) { ring(c, 7.6 * k, GOLD, 1.2 * k); glowDot(c, 1.8 * k, [1, 0.6, 0.3, 1]); }
    if (L.R >= 4) { const e = P(c, aim, k, 5, n > 1 ? 5.5 : -5.5); plate(e, rectPts(1.6, 1.2), METAL, aim, k, 0.8); line(e, add(e, mul(fa(aim), s * 1.4)), [1, 0.25, 0.25, 0.25], 0.8); glowDot(e, 0.6 * k, [1, 0.3, 0.3, 1]); }
    // Extra guns on swivel mounts (bodies bigger than their barrels), each with the same kit as the main gun.
    for (let i = 1; i < n; i++) { const mp = P(c, aim, k, ...mountOf(i)), a = ex[i], el = extraLen(L.R);
      if (L.M >= 3) cluster(mp, a, k, fx, t, 1, el, 2.4, 1.4, 4, L.M >= 5 ? GOLD : METAL_L, L.R);
      else { bar(P(mp, a, k, 1 - rc, 0), P(mp, a, k, el - rc, 0), 1.8 * k, METAL_L); if (L.R >= 3) for (let x = 4; x <= el - 2; x += 1.8) line(P(mp, a, k, x - rc, -0.6), P(mp, a, k, x + 0.9 - rc, 0.6), lt(METAL_L, 0.35), 0.5 * k); }
      barrelKit(mp, a, k, fx, t, 4, el - 2, L.M >= 3 ? 2.4 : 1, L, gold, col);
      if (L.M < 3) { disc(P(mp, a, k, el - rc, 0), 0.6 * k, BORE); flashTip(P(mp, a, k, el - rc, 0), k, 1.8, fx); }
      plate(mp, ngon(6, 1, 0), METAL_L, a, 5 * k, 1.1); orb(mp, 2.6 * k, METAL); glowDot(P(mp, a, k, 1, 0), 0.8 * k, col);
      if (L.P >= 1) plate(P(mp, a, k, 3, 0), [[0.8, -3.6], [0.8, 3.6], [-0.8, 3], [-0.8, -3]], STEEL, a, k, 0.9);
      if (L.r === 0) vapourAt(P(mp, a, k, el + 1, 0), fx, s);
      if (L.r === 2) line(P(c, aim, k, -4.5, -6), mp, [0.5, 0.2, 0.12, 1], 1.1 * k); }
    if (L.M >= 4) { for (const y of [-5, 5]) gear(P(c, aim, k, -5, y), 2.2, k, t * 6 * (y > 0 ? 1 : -1), 8); for (let i = 1; i < n; i++) gear(P(P(c, aim, k, ...mountOf(i)), ex[i], k, -3.4, 0), 1.6, k, t * 7, 6); }
    // Retrofits on the body: the fuel canister and line (the water tank is gone; owner, 2026-10-17).
    if (L.r === 2) { bar(P(c, aim, k, -7, -6), P(c, aim, k, -2, -6), 3 * k, [0.7, 0.18, 0.12, 1]); line(P(c, aim, k, -2, -6), P(c, aim, k, 4, -2), [0.5, 0.2, 0.12, 1], 1.2 * k); }
  },
  paths: [
    { name: "Power", theme: "armour-piercing", steps: [
      { name: "Heavier Rounds", cost: 55, effect: "+6 damage", options: [{ key: "C", name: "Reinforced Breech", desc: "A heavy breech block behind the barrels; extra guns get a gun shield. Rounds: a brass bullet on the tracer." }] },
      { name: "Hardened Tips", cost: 40, effect: "Ignores 2 armour", options: [{ key: "C", name: "Marked Shroud", desc: "Two accent bands on the front shroud ring, over the barrels and at the muzzle wherever it is; on extra guns too. Rounds: a dark steel tip." }] },
      { name: "AP Rounds", cost: 405, effect: "Ignores 50% of armour; +6 damage (primary)", options: [{ key: "C", name: "Armour Cheeks", desc: "Angled armour plates on both cheeks of the body. Rounds: dark AP bullets with a yellow band." }] },
      { name: "Tungsten Core", cost: 1085, effect: "Ignores 75% of armour; +8 damage", options: [{ key: "B", name: "Counterweight", desc: "A heavy hazard-striped counterweight on the back. Rounds: a white-hot tungsten core glowing at the base." }] },
      { name: "Sabot Rounds", cost: 2475, effect: "Ignores armour fully; 44 damage per hit (mastery)", options: [{ key: "B", name: "Gold-Banded Gun", desc: "The marked shroud bands turn gold instead of a new shroud being drawn (your note), with a gold ring round the body and a hot core. Rounds: a slim sabot dart that sheds its petals at the muzzle, with a gold streak." }] },
    ] },
    { name: "Range/Visibility", theme: "precision", steps: [
      { name: "Long Barrel", cost: 25, effect: "+20 range", options: [{ key: "A", name: "Longer Barrels", desc: "The barrels are swapped for longer ones instead of an extension laid over them (your note), on extra guns too." }] },
      { name: "Tracer Rounds", cost: 60, effect: "+10 range; 10% crits; visible tracer lines", options: [{ key: "B", name: "Tracer Drum", desc: "The drum's ring turns red instead of a new red circle (your note); long tracer lines; gold crit bursts." }] },
      { name: "Rifled Barrels", cost: 170, effect: "+25 range; 15% crits (primary)", options: [{ key: "A", name: "Fluted Barrels", desc: "Fluted barrels, on the extra gun too (your note)." }] },
      { name: "Rangefinder", cost: 305, effect: "+20 range; 20% crits", options: [{ key: "B", name: "Laser Rangefinder", desc: "An emitter beside the gun paints a faint red ranging line (it moves to the right side when a flank gun is fitted)." }] },
      { name: "Targeting Computer", cost: 980, effect: "230 range in all; 30% crits (mastery)", options: [{ key: "C", name: "Hex Lens Crown", desc: "A big faceted lens crowns the body in a gold hex frame." }] },
    ] },
    { name: "Multi-Target", theme: "more guns on more targets", steps: [
      { name: "Swivel Mount", cost: 15, effect: "Switches target instantly; no wasted rounds", options: [{ key: "A", name: "Geared Swivel Ring", desc: "A toothed swivel ring round the base of the turret (owner's change from the Bearing Rollers)." }] },
      { name: "Side Gun", cost: 165, effect: "A side gun fires at a second target at 50% damage", options: [{ key: "A", name: "Flank Gun", desc: "A single-barrel gun on its own swivel mount on the left flank, aiming at its own target; its body is bigger than its barrel (your notes)." }] },
      { name: "Twin Mount", cost: 330, effect: "2 targets at full damage (primary)", options: [{ key: "A", name: "Twin Rotary", desc: "The flank gun becomes a rotary cluster on its larger swivel mount (your notes)." }] },
      { name: "Belt Feed", cost: 660, effect: "+0.3 shots/s on every barrel", options: [{ key: "C", name: "Feed Gears", desc: "Spinning feed gears drive the belts, on the body and on every extra gun's mount (owner's change from the Ammo Hopper)." }] },
      { name: "Triple Mount", cost: 3300, effect: "3 targets; the extra barrels go for the weakest (mastery)", options: [{ key: "A", name: "Triple Rotary", desc: "A third swivelling rotary on the right flank (the drum moves back); gold rings on every gun, and a marked shroud turns gold (your note)." }] },
    ] },
  ],
  retrofits: [
    { name: "Water-Cooled Barrel", cost: 40, effect: "Fire rate 1.2 to 1.5/s", options: [{ key: "A", name: "Water Jacket", desc: "A water jacket on every gun, longer with the Range barrels; vapour at each muzzle. No tank (owner, 2026-10-17)." }] },
    { name: "Shock Rounds", cost: 5, effect: "Every hit has a 5% chance to stun for 0.3 s", options: [{ key: "A", name: "Coil Wraps", desc: "Shock coils on every gun (your note), longer with the Range barrels; stunning hits crackle." }] },
    { name: "Incendiary Rounds", cost: 25, effect: "Hits burn the target for 3 damage/s for 2 s (refreshes, proposed)", options: [{ key: "A", name: "Fuel Canister", desc: "A fuel canister with fuel lines to every gun (your note); orange tracers; burning targets." }] },
  ],
};
