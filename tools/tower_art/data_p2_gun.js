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
const PAGE = { title: "Gun Turret: paths and Retrofits (second pass)", store: "bl-tower-art-p2-gun-r2" };
const GOLD = [1, 0.78, 0.3, 1], RED_TIP = [1, 0.3, 0.25, 1], STEEL = [0.42, 0.45, 0.5, 1];
const SHOCK = [0.6, 0.85, 1, 1], FIRE = [1, 0.55, 0.2, 1], WATER = [0.3, 0.42, 0.5, 1];
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const spinOf = (fx, t) => t * (fx.recoil > 0 || fx.flash > 0 ? 30 : 3);
function longTracer(f, to, u, col, w) { const a = lerp(f, to, Math.max(0, u - 0.6)), b = lerp(f, to, u); line(a, b, A(col, 0.35), w * 2.4); line(a, b, A(col, 0.95), w); line(a, b, [1, 1, 1, 0.8], w * 0.35); }
function stunArcs(to, v, s, info) { if (!info || !info.sh || info.sh.m % 20 !== 0 || v >= 1) return; for (let i = 0; i < 4; i++) { const a = rnd2(i + Math.floor(v * 12)) * TAU; line(to, add(to, mul(fa(a), s * 0.16)), A(SHOCK, 1 - v), 1.4); } glowDot(to, s * 0.06 * (1 - v), SHOCK); }
function flames(to, v, s) { if (v >= 1) return; for (let i = 0; i < 3; i++) { const q = fmod(v * 2 + i / 3, 1); disc(add(to, [(i - 1) * s * 0.05, -q * s * 0.18]), s * 0.035 * (1 - q), A(i % 2 ? FIRE : [1, 0.85, 0.3, 1], 1 - q)); } }
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
  for (const x of [x0 + 3, x1 - 1]) bar(P(c0, a, k, x - rc, -rad - 1.4), P(c0, a, k, x - rc, rad + 1.4), 1.5 * k, ringCol || METAL_L); }

// What's on every gun's barrels: the Retrofit sleeve, then Power's marked shroud on the front ring.
function barrelKit(c0, a, k, fx, t, x0, x1, half, Lv, gold, col) { const rc = fx.recoil * 1.5;
  if (Lv.r === 0) plate(P(c0, a, k, (x0 + x1) / 2 - rc, 0), rectPts((x1 - x0) / 2, half + 0.8), WATER, a, k, 1);
  if (Lv.r === 1) { for (let x = x0; x <= x1; x += 1.5) line(P(c0, a, k, x - rc, -half - 1), P(c0, a, k, x + 0.7 - rc, half + 1), [0.35, 0.45, 0.6, 1], 1 * k); glowDot(P(c0, a, k, (x0 + x1) / 2 - rc, 0), 0.7 * k, A(SHOCK, 0.5 + 0.5 * Math.sin(t * 9))); }
  if (Lv.P >= 2) { const mc = gold ? GOLD : col; for (const dx of [0, 1.4]) line(P(c0, a, k, x1 + 2 - dx - rc, -half - 1.4), P(c0, a, k, x1 + 2 - dx - rc, half + 1.4), A(mc, 0.95), 1 * k); } }

const P2 = {
  tower: "gun", look: "C", anim: "C",
  picks: { p0s0: "C", p0s1: "C", p0s2: "C", p0s3: "B", p0s4: "B", p1s0: "A", p1s1: "B", p1s2: "A", p1s3: "B", p1s4: "C", p2s0: "B", p2s1: "A", p2s2: "A", p2s3: "B", p2s4: "A", r0: "A", r1: "A", r2: "A" },
  intro: "Round 2: your round-1 picks drawn as one model, so the paths work together (your notes). Each stage shows only your pick; use the build preview to check combinations, and note anything to change.",
  mods(B) { const L = lvOf(B), n = gunsOf(L.M);
    return { targets: n, crit: [0, 0, 0.1, 0.15, 0.2, 0.3][L.R],
      shot: (f, to, u, s, col) => { const c2 = L.r === 2 ? FIRE : col; if (L.R >= 2) longTracer(f, to, u, c2, 1.5); else tracer(f, to, u, c2, 1.4, 0.2); if (L.P >= 3) disc(lerp(f, to, u), 1.6, [0.15, 0.12, 0.1, 1]); },
      impactFx: (to, v, s, col, info) => { if (L.r === 1) stunArcs(to, v, s, info); if (L.r === 2) flames(to, v, s); } }; },
  muzzleAt(B, m, kk, c, aim, s, info) { const L = lvOf(B), k = G(s), n = gunsOf(L.M), i = kk % n;
    if (i === 0) return P(c, aim, k, mainLen(L.R) + 1, 0);
    const a = (info.view.ex && info.view.ex[i]) ?? aim; return P(P(c, aim, k, ...mountOf(i)), a, k, extraLen(L.R) + 1, 0); },
  model(c, aim, s, fx, t, col, info, B) {
    const L = lvOf(B), k = G(s), rc = fx.recoil * 1.5, len = mainLen(L.R), n = gunsOf(L.M), gold = L.P >= 5 || L.M >= 5;
    const ex = extraAims(info, c, aim, k, n), drum = L.M >= 5 ? P(c, aim, k, -7, 6) : P(c, aim, k, -1, 8.5);
    deck(c, k, col, t);
    // Under the turret: Multi 1's bearing rollers.
    if (L.M >= 1) for (let i = 0; i < 6; i++) { const p = add(c, mul(fa(i * TAU / 6), 9.6 * k)); orb(p, 1.6 * k, METAL_L); line(p, add(p, mul(fa(aim * 3 + i), 1.4 * k)), METAL_D, 0.8 * k); }
    // The back: vent block, Power 4's counterweight or Multi 4's hopper.
    plate(P(c, aim, k, -8, 0), rectPts(3, 5.5), lt(METAL_D, 0.1), aim, k, 1); for (let i = 0; i < 3; i++) line(P(c, aim, k, -9.5 + i * 1.5, -4), P(c, aim, k, -9.5 + i * 1.5, 4), A(col, 0.5 + 0.4 * (i === 2)), 0.9 * k);
    if (L.P >= 4) { plate(P(c, aim, k, -11.5, 0), rectPts(2.4, 6.4), STEEL, aim, k, 1.1); hazard(c, aim, k, -13, -10, 6.8, col, 1.2); hazard(c, aim, k, -13, -10, -6.8, col, 1.2); }
    if (L.M >= 4) { plate(P(c, aim, k, -11, 0), rectPts(3, 7), AMMO, aim, k, 1.1); hazard(c, aim, k, -13.5, -8.5, -7.6, col, 1.1); }
    // The main gun: barrels swapped longer at Range 1, fluted at Range 3; the Retrofit sleeve; the marked shroud.
    cluster(c, aim, k, fx, t, 5, len, 3.4, 1.8, 4, L.M >= 5 ? GOLD : METAL_L, L.R);
    barrelKit(c, aim, k, fx, t, 9, len - 3, 3.4, L, gold, col);
    muzzleEnd(P(c, aim, k, len + 1 - rc, 0), k, 3, col, fx.flash);
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
      bar(c, mp, 2.4 * k, METAL);
      if (L.M >= 3) cluster(mp, a, k, fx, t, 1, el, 2.4, 1.4, 4, L.M >= 5 ? GOLD : METAL_L, L.R);
      else { bar(P(mp, a, k, 1 - rc, 0), P(mp, a, k, el - rc, 0), 1.8 * k, METAL_L); if (L.R >= 3) for (let x = 4; x <= el - 2; x += 1.8) line(P(mp, a, k, x - rc, -0.6), P(mp, a, k, x + 0.9 - rc, 0.6), lt(METAL_L, 0.35), 0.5 * k); }
      barrelKit(mp, a, k, fx, t, 4, el - 2, L.M >= 3 ? 2.4 : 1, L, gold, col);
      muzzleEnd(P(mp, a, k, el + 1 - rc, 0), k, L.M >= 3 ? 2.2 : 1.6, col, fx.flash);
      plate(mp, ngon(6, 1, 0), METAL_L, a, 5 * k, 1.1); orb(mp, 2.6 * k, METAL); glowDot(P(mp, a, k, 1, 0), 0.8 * k, col);
      if (L.P >= 1) plate(P(mp, a, k, 3, 0), [[0.8, -3.6], [0.8, 3.6], [-0.8, 3], [-0.8, -3]], STEEL, a, k, 0.9);
      if (L.r === 0) vapourAt(P(mp, a, k, el + 1, 0), fx, s);
      if (L.r === 2) line(P(c, aim, k, -4.5, -6), mp, [0.5, 0.2, 0.12, 1], 1.1 * k); }
    // Retrofits on the body: the water tank and hose, the fuel canister and line.
    if (L.r === 0) { orb(P(c, aim, k, -6, -6), 2.2 * k, WATER); line(P(c, aim, k, -6, -6), P(c, aim, k, 8, -4), [0.2, 0.3, 0.36, 1], 1.2 * k); }
    if (L.r === 2) { bar(P(c, aim, k, -7, -6), P(c, aim, k, -2, -6), 3 * k, [0.7, 0.18, 0.12, 1]); line(P(c, aim, k, -2, -6), P(c, aim, k, 4, -2), [0.5, 0.2, 0.12, 1], 1.2 * k); }
  },
  paths: [
    { name: "Power", theme: "armour-piercing", steps: [
      { name: "Heavier Rounds", cost: 55, effect: "+6 damage", options: [{ key: "C", name: "Reinforced Breech", desc: "A heavy breech block behind the barrels. Extra guns get a gun shield (your note)." }] },
      { name: "Hardened Tips", cost: 40, effect: "Ignores 2 armour", options: [{ key: "C", name: "Marked Shroud", desc: "Two accent bands on the front shroud ring, over the barrels and at the muzzle wherever it is (your note); on extra guns too." }] },
      { name: "AP Rounds", cost: 405, effect: "Ignores 50% of armour; +6 damage (primary)", options: [{ key: "C", name: "Armour Cheeks", desc: "Angled armour plates on both cheeks of the body; dark-cored rounds." }] },
      { name: "Tungsten Core", cost: 1085, effect: "Ignores 75% of armour; +8 damage", options: [{ key: "B", name: "Counterweight", desc: "A heavy hazard-striped counterweight on the back." }] },
      { name: "Sabot Rounds", cost: 2475, effect: "Ignores armour fully; 44 damage per hit (mastery)", options: [{ key: "B", name: "Gold-Banded Gun", desc: "The marked shroud bands turn gold instead of a new shroud being drawn (your note), with a gold ring round the body and a hot core." }] },
    ] },
    { name: "Range/Visibility", theme: "precision", steps: [
      { name: "Long Barrel", cost: 25, effect: "+20 range", options: [{ key: "A", name: "Longer Barrels", desc: "The barrels are swapped for longer ones instead of an extension laid over them (your note), on extra guns too." }] },
      { name: "Tracer Rounds", cost: 60, effect: "+10 range; 10% crits; visible tracer lines", options: [{ key: "B", name: "Tracer Drum", desc: "The drum's ring turns red instead of a new red circle (your note); long tracer lines; gold crit bursts." }] },
      { name: "Rifled Barrels", cost: 170, effect: "+25 range; 15% crits (primary)", options: [{ key: "A", name: "Fluted Barrels", desc: "Fluted barrels, on the extra gun too (your note)." }] },
      { name: "Rangefinder", cost: 305, effect: "+20 range; 20% crits", options: [{ key: "B", name: "Laser Rangefinder", desc: "An emitter beside the gun paints a faint red ranging line (it moves to the right side when a flank gun is fitted)." }] },
      { name: "Targeting Computer", cost: 980, effect: "230 range in all; 30% crits (mastery)", options: [{ key: "C", name: "Hex Lens Crown", desc: "A big faceted lens crowns the body in a gold hex frame." }] },
    ] },
    { name: "Multi-Target", theme: "more guns on more targets", steps: [
      { name: "Swivel Mount", cost: 15, effect: "Switches target instantly; no wasted rounds", options: [{ key: "B", name: "Bearing Rollers", desc: "Roller bearings round the turret base." }] },
      { name: "Side Gun", cost: 165, effect: "A side gun fires at a second target at 50% damage", options: [{ key: "A", name: "Flank Gun", desc: "A single-barrel gun on its own swivel mount on the left flank, aiming at its own target; its body is bigger than its barrel (your notes)." }] },
      { name: "Twin Mount", cost: 330, effect: "2 targets at full damage (primary)", options: [{ key: "A", name: "Twin Rotary", desc: "The flank gun becomes a rotary cluster on its larger swivel mount (your notes)." }] },
      { name: "Belt Feed", cost: 660, effect: "+0.3 shots/s on every barrel", options: [{ key: "B", name: "Ammo Hopper", desc: "A big hazard-striped ammo hopper on the back." }] },
      { name: "Triple Mount", cost: 3300, effect: "3 targets; the extra barrels go for the weakest (mastery)", options: [{ key: "A", name: "Triple Rotary", desc: "A third swivelling rotary on the right flank (the drum moves back); gold rings on every gun, and a marked shroud turns gold (your note)." }] },
    ] },
  ],
  retrofits: [
    { name: "Water-Cooled Barrel", cost: 40, effect: "Fire rate 1.2 to 1.5/s", options: [{ key: "A", name: "Water Jacket", desc: "A water jacket on every gun (your note), longer with the Range barrels; a tank and hose; vapour at each muzzle." }] },
    { name: "Shock Rounds", cost: 5, effect: "Every hit has a 5% chance to stun for 0.3 s", options: [{ key: "A", name: "Coil Wraps", desc: "Shock coils on every gun (your note), longer with the Range barrels; stunning hits crackle." }] },
    { name: "Incendiary Rounds", cost: 25, effect: "Hits burn the target for 3 damage/s for 2 s (refreshes, proposed)", options: [{ key: "A", name: "Fuel Canister", desc: "A fuel canister with fuel lines to every gun (your note); orange tracers; burning targets." }] },
  ],
};
