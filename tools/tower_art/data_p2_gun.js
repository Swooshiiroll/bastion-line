// ---- Tower art second pass: Gun Turret (tower 1), on the confirmed base: look C Rotary Gun, animation C Rapid Stream --
// Rotary Gun geometry (game px, x along the aim, y to the side): four barrels x 5..19 spinning at y ±3.4, shroud rings at
// x 8 and 18, muzzle at x 20, drum magazine at (-1, 8.5) r 4.2, vent block at (-8, 0), hexagonal body r 6.8.
const PAGE = { title: "Gun Turret: paths and Retrofits (second pass)", store: "bl-tower-art-p2-gun-v2" };
const GOLD = [1, 0.78, 0.3, 1], RED_TIP = [1, 0.3, 0.25, 1], STEEL = [0.42, 0.45, 0.5, 1], COPPER = [0.78, 0.5, 0.28, 1];
const RC = (fx) => fx.recoil * 1.5; // the cluster's recoil, as the base draws it
const spinOf = (fx, t) => t * (fx.recoil > 0 || fx.flash > 0 ? 30 : 3);
// A small rotary cluster (n barrels) at lateral y0, from x0 to x1.
function cluster(c, aim, k, fx, t, y0, x0, x1, rad, w, n, col, goldRing) { const sp = spinOf(fx, t), r = RC(fx);
  const bs = []; for (let i = 0; i < n; i++) bs.push({ y: y0 + Math.sin(sp + i * TAU / n) * rad, z: Math.cos(sp + i * TAU / n) }); bs.sort((a, b) => a.z - b.z);
  for (const b of bs) bar(P(c, aim, k, x0 - r, b.y), P(c, aim, k, x1 - r, b.y), w * k, mix(METAL_D, METAL_L, 0.5 + 0.5 * b.z));
  for (const x of [x0 + 2, x1 - 1]) bar(P(c, aim, k, x - r, y0 - rad - 1.2), P(c, aim, k, x - r, y0 + rad + 1.2), 1.3 * k, goldRing ? GOLD : METAL_L);
  muzzleEnd(P(c, aim, k, x1 + 1 - r, y0), k, rad * 0.9, col, fx.flash); }
function beltLine(a, b, k, n, tipCol, t) { line(a, b, OUTLINE, 3.2 * k); line(a, b, [0.55, 0.45, 0.25, 1], 2.2 * k);
  for (let i = 0; i < n; i++) { const q = lerp(a, b, fmod(i / n + t * 0.8, 1)); disc(q, 1 * k, [0.85, 0.7, 0.35, 1]); if (tipCol) disc(q, 0.55 * k, tipCol); } }
function longTracer(f, to, u, col, w) { const a = lerp(f, to, Math.max(0, u - 0.6)), b = lerp(f, to, u); line(a, b, A(col, 0.35), w * 2.4); line(a, b, A(col, 0.95), w); line(a, b, [1, 1, 1, 0.8], w * 0.35); }
function vapour(p, fx, s) { if (fx.flash > 0.6) smokePuff(add(p, [0, -s * 0.05]), 1 - fx.flash, s * 0.5, 0.35); }

const P2 = {
  tower: "gun", look: "C", anim: "C",
  intro: "The cheap all-rounder: 16 damage, 130 range, 1.2 shots/s, air and ground. Power leads to armour-piercing rounds, Range/Visibility to long-range crits, Multi-Target to a triple mount. Every step adds or changes a detail on the Rotary Gun.",
  paths: [
    { name: "Power", theme: "armour-piercing: a heavier gun with an AP-shell feed",
      steps: [
        { name: "Heavier Rounds", cost: 55, effect: "+6 damage", options: [
          { key: "A", name: "Heavy Shroud Rings", desc: "The two shroud rings round the barrels become thick armoured collars.",
            over: (c, aim, s, fx) => { const k = G(s), r = RC(fx); for (const x of [8, 18]) bar(P(c, aim, k, x - r, -5.6), P(c, aim, k, x - r, 5.6), 2.6 * k, STEEL); } },
          { key: "B", name: "Bigger Drum", desc: "A larger drum magazine with reinforcing bands replaces the stock drum.",
            over: (c, aim, s) => { const k = G(s), d = P(c, aim, k, -1, 9); orb(d, 5.4 * k, METAL); ring(d, 4 * k, METAL_L, 1.2 * k); ring(d, 2.4 * k, METAL_D, 1 * k); } },
          { key: "C", name: "Reinforced Breech", desc: "A heavy breech block behind the barrels, bolted to the body.",
            over: (c, aim, s, fx) => { const k = G(s); plate(P(c, aim, k, 4.5 - RC(fx), 0), rectPts(2.2, 5.4), STEEL, aim, k, 1); rivets(P(c, aim, k, 4.5 - RC(fx), 0), rectPts(2.2, 5.4), aim, k, 0.7, 0.6 * k); } },
        ] },
        { name: "Hardened Tips", cost: 40, effect: "Ignores 2 armour", options: [
          { key: "A", name: "Black-Tip Belt", desc: "A belt of dark hardened-tip rounds runs from the drum into the breech.",
            over: (c, aim, s, fx, t) => { const k = G(s); beltLine(P(c, aim, k, -1, 5), P(c, aim, k, 4, 2), k, 4, [0.1, 0.1, 0.12, 1], t); } },
          { key: "B", name: "Steel Muzzle Collar", desc: "A hardened steel collar round the muzzle, edged in the accent colour.",
            over: (c, aim, s, fx, t, col) => { const k = G(s), p = P(c, aim, k, 19.5 - RC(fx), 0); ring(p, 4.4 * k, OUTLINE, 2.6 * k); ring(p, 4.4 * k, STEEL, 1.6 * k); ring(p, 5.2 * k, A(col, 0.7), 0.8 * k); } },
          { key: "C", name: "Marked Shroud", desc: "A painted warning band in the accent colour round the front shroud ring.",
            over: (c, aim, s, fx, t, col) => { const k = G(s), r = RC(fx); line(P(c, aim, k, 18 - r, -5), P(c, aim, k, 18 - r, 5), A(col, 0.9), 1 * k); line(P(c, aim, k, 16.6 - r, -5), P(c, aim, k, 16.6 - r, 5), A(col, 0.9), 1 * k); } },
        ] },
        { name: "AP Rounds", cost: 405, effect: "Ignores 50% of armour; +6 damage (primary)", options: [
          { key: "A", name: "AP Shell Feed", desc: "A second ammo box of yellow-banded AP shells on the left flank, chuted into the breech. Rounds fly as heavier dark-cored tracers.",
            over: (c, aim, s, fx, t) => { const k = G(s), bx = P(c, aim, k, -2, -9); plate(bx, rectPts(3.6, 2.8), AMMO, aim, k, 1); hazard(c, aim, k, -5, 1, -11.6, [1, 0.85, 0.2, 1], 1); beltLine(P(c, aim, k, 0, -7), P(c, aim, k, 4, -2), k, 3, [1, 0.85, 0.2, 1], t); },
            shotFx: (f, to, u, s) => { const p = lerp(f, to, u); disc(p, 1.6, [0.15, 0.12, 0.1, 1]); } },
          { key: "B", name: "Heavy Barrel Sleeve", desc: "A solid armoured sleeve encloses the barrel cluster, so the gun reads as one thick cannon. Dark-cored tracers.",
            over: (c, aim, s, fx) => { const k = G(s), r = RC(fx); plate(P(c, aim, k, 11.5 - r, 0), rectPts(6, 5), STEEL, aim, k, 1.1); for (const x of [8, 11.5, 15]) line(P(c, aim, k, x - r, -4), P(c, aim, k, x - r, 4), [0, 0, 0, 0.4], 1); },
            shotFx: (f, to, u, s) => disc(lerp(f, to, u), 1.6, [0.15, 0.12, 0.1, 1]) },
          { key: "C", name: "Armour Cheeks", desc: "Angled armour plates bolted to both cheeks of the turret body. Dark-cored tracers.",
            over: (c, aim, s) => { const k = G(s); for (const sg of [-1, 1]) plate(P(c, aim, k, 0, sg * 6.4), [[5, -sg * 1.2], [5, sg * 1.6], [-5, sg * 2.2], [-6, -sg * 1]], STEEL, aim, k, 1); },
            shotFx: (f, to, u, s) => disc(lerp(f, to, u), 1.6, [0.15, 0.12, 0.1, 1]) },
        ] },
        { name: "Tungsten Core", cost: 1085, effect: "Ignores 75% of armour; +8 damage", options: [
          { key: "A", name: "Cooling Fins", desc: "Rows of radiator fins stand off the shroud between the rings.",
            over: (c, aim, s, fx) => { const k = G(s), r = RC(fx); for (let x = 10; x <= 16; x += 2) for (const sg of [-1, 1]) line(P(c, aim, k, x - r, sg * 4.6), P(c, aim, k, x - r, sg * 6.6), METAL_L, 1.1 * k); } },
          { key: "B", name: "Counterweight", desc: "A heavy hazard-striped counterweight block on the back of the turret.",
            over: (c, aim, s, fx, t, col) => { const k = G(s); plate(P(c, aim, k, -11.5, 0), rectPts(2.4, 6.4), STEEL, aim, k, 1.1); hazard(c, aim, k, -13, -10, 6.8, col, 1.2); hazard(c, aim, k, -13, -10, -6.8, col, 1.2); } },
          { key: "C", name: "Twin Feed Chutes", desc: "Two armoured feed chutes curve from the magazines into the breech.",
            over: (c, aim, s) => { const k = G(s); for (const [a, b] of [[[-1, 5], [4, 2]], [[-1, -5], [4, -2]]]) { bar(P(c, aim, k, a[0], a[1]), P(c, aim, k, b[0], b[1]), 2.4 * k, STEEL); } } },
        ] },
        { name: "Sabot Rounds", cost: 2475, effect: "Ignores armour fully; 44 damage per hit (mastery)", options: [
          { key: "A", name: "Sabot Muzzle Brake", desc: "A big gold-ringed muzzle brake; on each shot the sabot petals peel off in front of it.",
            muzzles: [[24 / 48, 0]],
            over: (c, aim, s, fx, t, col) => { const k = G(s), r = RC(fx); bar(P(c, aim, k, 18 - r, 0), P(c, aim, k, 23 - r, 0), 6 * k, STEEL); for (const x of [19.5, 22]) line(P(c, aim, k, x - r, -3), P(c, aim, k, x - r, 3), [0, 0, 0, 0.5], 1); ring(P(c, aim, k, 23.5 - r, 0), 3.4 * k, GOLD, 1.2 * k); muzzleEnd(P(c, aim, k, 24 - r, 0), k, 3, col, fx.flash); },
            shotFx: (f, to, u, s) => { if (u < 0.3) { const d = norm(sub(to, f)); for (const sg of [-1, 1]) disc(add(add(f, mul(d, u * s * 0.8)), mul(orth(d), sg * u * s * 0.4)), 1.5, [0.6, 0.6, 0.62, 1 - u * 3]); } } },
          { key: "B", name: "Gold-Banded Gun", desc: "Gold bands on the shroud rings, a gold ring round the body (as today's tier-4 towers) and a hot core glow.",
            over: (c, aim, s, fx, t, col) => { const k = G(s), r = RC(fx); for (const x of [8, 18]) bar(P(c, aim, k, x - r, -5.2), P(c, aim, k, x - r, 5.2), 1.8 * k, GOLD); ring(c, 7.6 * k, GOLD, 1.2 * k); glowDot(c, 1.8 * k, [1, 0.6, 0.3, 1]); } },
          { key: "C", name: "Armoured Gun House", desc: "A full armoured house over the body and breech, gold-trimmed, with only the barrels showing.",
            over: (c, aim, s) => { const k = G(s), hs = [[7, -6.5], [7, 6.5], [-6, 8], [-10, 4], [-10, -4], [-6, -8]]; plate(c, hs, STEEL, aim, k, 1.3); outline(c, hs.map((q) => mul(q, 0.86)), GOLD, 1 * k, aim, k); rivets(c, hs, aim, k, 0.72, 0.7 * k); } },
        ] },
      ] },
    { name: "Range/Visibility", theme: "precision: a long barrel, tracers, a scope and critical hits",
      steps: [
        { name: "Long Barrel", cost: 25, effect: "+20 range", options: [
          { key: "A", name: "Barrel Extensions", desc: "The four barrels run on past the front ring to a new muzzle further out.", muzzles: [[25 / 48, 0]],
            over: (c, aim, s, fx, t, col) => cluster(c, aim, k0(s), fx, t, 0, 17, 24, 3.4, 1.6, 4, col) },
          { key: "B", name: "Long Shroud Tube", desc: "One long ventilated shroud tube carries the muzzle well forward.", muzzles: [[25 / 48, 0]],
            over: (c, aim, s, fx, t, col) => { const k = G(s), r = RC(fx); bar(P(c, aim, k, 17 - r, 0), P(c, aim, k, 24 - r, 0), 5.4 * k, METAL_L); for (let x = 19; x <= 23; x += 2) disc(P(c, aim, k, x - r, 0), 0.8 * k, OUTLINE); muzzleEnd(P(c, aim, k, 25 - r, 0), k, 3, col, fx.flash); } },
          { key: "C", name: "Guide Rails", desc: "Two slim rails run forward from the shroud to a ringed muzzle guide.", muzzles: [[25 / 48, 0]],
            over: (c, aim, s, fx, t, col) => { const k = G(s), r = RC(fx); for (const y of [-4, 4]) bar(P(c, aim, k, 16 - r, y), P(c, aim, k, 24 - r, y * 0.6), 1.3 * k, METAL_L); ring(P(c, aim, k, 24 - r, 0), 2.8 * k, METAL_L, 1.2 * k); muzzleEnd(P(c, aim, k, 25 - r, 0), k, 2.6, col, fx.flash); } },
        ] },
        { name: "Tracer Rounds", cost: 60, effect: "+10 range; 10% crits; visible tracer lines", options: [
          { key: "A", name: "Red Tracer Belt", desc: "A belt of red-tipped tracers feeds the gun; every shot draws a long red tracer line; crits flash gold.", crit: 0.1,
            over: (c, aim, s, fx, t) => { const k = G(s); beltLine(P(c, aim, k, -1, 5), P(c, aim, k, 4, 2), k, 4, RED_TIP, t); }, shot: (f, to, u, s, col) => longTracer(f, to, u, RED_TIP, 1.6) },
          { key: "B", name: "Tracer Drum", desc: "The drum gets a red tracer band; shots draw long tracer lines in the tower's cyan; crits flash gold.", crit: 0.1,
            over: (c, aim, s) => { const k = G(s); ring(P(c, aim, k, -1, 8.5), 3.4 * k, RED_TIP, 1.4 * k); }, shot: (f, to, u, s, col) => longTracer(f, to, u, col, 1.5) },
          { key: "C", name: "Feed Lamp", desc: "A small lamp on the breech glows with each round; long white-hot tracer lines; crits flash gold.", crit: 0.1,
            over: (c, aim, s, fx) => { const k = G(s); glowDot(P(c, aim, k, 3, -4.5), (0.8 + fx.flash) * k, [1, 0.9, 0.6, 1]); }, shot: (f, to, u) => longTracer(f, to, u, [1, 0.92, 0.7, 1], 1.4) },
        ] },
        { name: "Rifled Barrels", cost: 170, effect: "+25 range; 15% crits (primary)", options: [
          { key: "A", name: "Fluted Barrels", desc: "The four barrels are swapped for longer fluted barrels, their grooves catching the light as they spin.", crit: 0.15,
            over: (c, aim, s, fx, t) => { const k = G(s), r = RC(fx), sp = spinOf(fx, t); for (let i = 0; i < 4; i++) { const y = Math.sin(sp + i * TAU / 4) * 3.4; if (Math.cos(sp + i * TAU / 4) < 0) continue; for (let x = 9; x <= 16; x += 1.8) line(P(c, aim, k, x - r, y - 0.5), P(c, aim, k, x + 0.9 - r, y + 0.5), lt(METAL_L, 0.35), 0.6 * k); } } },
          { key: "B", name: "Rifling Glow", desc: "A spiral of accent light runs down the cluster as the rifled barrels spin, brightest while firing.", crit: 0.15,
            over: (c, aim, s, fx, t, col) => { const k = G(s), r = RC(fx), sp = spinOf(fx, t); for (let x = 9; x <= 17; x += 1) { const y = Math.sin(sp * 0.5 + x * 0.9) * 3.6; disc(P(c, aim, k, x - r, y), 0.5 * k, A(col, 0.4 + 0.5 * fx.flash)); } } },
          { key: "C", name: "Rifled Bore Caps", desc: "Each barrel ends in a ribbed rifled cap, and a gauge on the body reads the spin.", crit: 0.15,
            over: (c, aim, s, fx, t, col) => { const k = G(s), r = RC(fx); bar(P(c, aim, k, 18.5 - r, -4.6), P(c, aim, k, 18.5 - r, 4.6), 2.4 * k, STEEL); for (let y = -3.6; y <= 3.6; y += 1.2) line(P(c, aim, k, 17.4 - r, y), P(c, aim, k, 19.6 - r, y), [0, 0, 0, 0.45], 0.6 * k);
              const g = P(c, aim, k, -4, -4.5); disc(g, 1.8 * k, OUTLINE); disc(g, 1.4 * k, [0.9, 0.9, 0.85, 1]); line(g, add(g, mul(fa(t * 4), 1.1 * k)), A(col, 1), 0.6 * k); } },
        ] },
        { name: "Rangefinder", cost: 305, effect: "+20 range; 20% crits", options: [
          { key: "A", name: "Stereo Rangefinder", desc: "A long rangefinder bar across the back with a lens at each end.", crit: 0.2,
            over: (c, aim, s, fx, t, col) => { const k = G(s); bar(P(c, aim, k, -10, -10), P(c, aim, k, -10, 10), 2 * k, METAL); for (const y of [-10, 10]) { orb(P(c, aim, k, -10, y), 1.6 * k, METAL_L); glowDot(P(c, aim, k, -9.2, y), 0.6 * k, col); } } },
          { key: "B", name: "Laser Rangefinder", desc: "A small emitter beside the gun paints a faint red ranging line ahead of it.", crit: 0.2,
            over: (c, aim, s) => { const k = G(s), e = P(c, aim, k, 5, -5.5); plate(e, rectPts(1.6, 1.2), METAL, aim, k, 0.8); line(e, P(c, aim, k, 60, -5.5), [1, 0.25, 0.25, 0.25], 0.8); glowDot(e, 0.6 * k, [1, 0.3, 0.3, 1]); } },
          { key: "C", name: "Sensor Mast", desc: "A thin mast on the back with a small sensor head turning on top.", crit: 0.2,
            over: (c, aim, s, fx, t, col) => { const k = G(s), m = P(c, aim, k, -6, -5); orb(m, 1.6 * k, METAL); line(m, add(m, mul(fa(t * 3), 3.4 * k)), METAL_L, 1.2 * k); glowDot(add(m, mul(fa(t * 3), 3.4 * k)), 0.7 * k, col); } },
        ] },
        { name: "Targeting Computer", cost: 980, effect: "230 range in all; 30% crits (mastery)", options: [
          { key: "A", name: "Sniper Optic", desc: "A long gold-ringed sniper optic runs the length of the gun; crits burst gold.", crit: 0.3,
            over: (c, aim, s) => { const k = G(s), a = P(c, aim, k, -8, -7.5), b = P(c, aim, k, 12, -7.5); bar(a, b, 3.2 * k, METAL); for (const x of [-4, 6]) ring(P(c, aim, k, x, -7.5), 2 * k, GOLD, 1 * k); disc(b, 1.8 * k, OUTLINE); glowDot(b, 1.1 * k, [1, 0.3, 0.3, 1]); } },
          { key: "B", name: "Targeting Array", desc: "Three gold-framed lenses in a row on the body; a gold reticle closes on each target as it fires.", crit: 0.3,
            over: (c, aim, s, fx, t, col) => { const k = G(s); for (const y of [-3, 0, 3]) { const p = P(c, aim, k, -3, y - 6.5); disc(p, 1.6 * k, GOLD); glowDot(p, 0.8 * k, col); } },
            shotFx: (f, to, u, s) => { if (u > 0.7) { const r = s * 0.25 * (1.6 - u); for (let i = 0; i < 4; i++) arc(to, r, i * Math.PI / 2 + 0.3, i * Math.PI / 2 + 1.1, GOLD, 1.4); } } },
          { key: "C", name: "Hex Lens Crown", desc: "A big faceted lens crowns the turret body in a gold hex frame.", crit: 0.3,
            over: (c, aim, s, fx, t, col) => { const k = G(s); plate(c, ngon(6, 1, 0), METAL_L, aim, 5.6 * k, 1); outline(c, ngon(6, 1, 0), GOLD, 1.2 * k, aim, 5.6 * k); disc(c, 3.4 * k, A(col, 0.55)); disc(add(c, mul(LIGHT, 1.2 * k)), 1.2 * k, [1, 1, 1, 0.6]); } },
        ] },
      ] },
    { name: "Multi-Target", theme: "more barrels on more targets: a side gun, then a twin and a triple mount",
      steps: [
        { name: "Swivel Mount", cost: 15, effect: "Switches target instantly; no wasted rounds", options: [
          { key: "A", name: "Geared Swivel Ring", desc: "A toothed swivel ring shows round the base of the turret.",
            under: (c, aim, s) => { const k = G(s); ring(c, 9.5 * k, OUTLINE, 2.6 * k); ring(c, 9.5 * k, METAL_L, 1.6 * k); for (let i = 0; i < 16; i++) { const d = fa(i * TAU / 16 + aim); line(add(c, mul(d, 9.5 * k)), add(c, mul(d, 11 * k)), METAL_L, 1 * k); } } },
          { key: "B", name: "Bearing Rollers", desc: "Six roller bearings round the turret base that spin as it turns.",
            under: (c, aim, s) => { const k = G(s); for (let i = 0; i < 6; i++) { const p = add(c, mul(fa(i * TAU / 6), 9.6 * k)); orb(p, 1.6 * k, METAL_L); line(p, add(p, mul(fa(aim * 3 + i), 1.4 * k)), METAL_D, 0.8 * k); } } },
          { key: "C", name: "Target Lamp", desc: "A lamp on the body blinks each time the gun snaps to a new target.",
            over: (c, aim, s, fx, t, col) => { const k = G(s); glowDot(P(c, aim, k, -4, 4.5), (fmod(t * 2, 1) < 0.2 ? 1.4 : 0.6) * k, col); } },
        ] },
        { name: "Side Gun", cost: 165, effect: "A side gun fires at a second target at 50% damage", options: [
          { key: "A", name: "Flank Gun", desc: "A small single-barrel gun on the left flank fires at a second target.", targets: 2, muzzles: [[20 / 48, 0], [15 / 48, -8 / 48]],
            over: (c, aim, s, fx, t, col) => { const k = G(s); plate(P(c, aim, k, 2, -8), rectPts(2.6, 2), METAL_L, aim, k, 1); bar(P(c, aim, k, 2, -8), P(c, aim, k, 14, -8), 1.6 * k, METAL_L); muzzleEnd(P(c, aim, k, 15, -8), k, 1.6, col, fx.barrel === 1 ? 1 - fx.barrelSince * 8 : 0); } },
          { key: "B", name: "Pintle Gun", desc: "A pintle-mounted light gun on top of the body fires at a second target.", targets: 2, muzzles: [[20 / 48, 0], [13 / 48, -3.5 / 48]],
            over: (c, aim, s, fx, t, col) => { const k = G(s); orb(P(c, aim, k, -3, -3.5), 1.6 * k, METAL); bar(P(c, aim, k, -3, -3.5), P(c, aim, k, 12, -3.5), 1.3 * k, METAL_L); muzzleEnd(P(c, aim, k, 13, -3.5), k, 1.3, col, fx.barrel === 1 ? 1 - fx.barrelSince * 8 : 0); } },
          { key: "C", name: "Coax Gun", desc: "A coaxial gun tucked under the left side of the cluster fires at a second target.", targets: 2, muzzles: [[20 / 48, 0], [17 / 48, -5.5 / 48]],
            under: (c, aim, s, fx, t, col) => { const k = G(s); bar(P(c, aim, k, 2, -5.5), P(c, aim, k, 16, -5.5), 1.5 * k, METAL); muzzleEnd(P(c, aim, k, 17, -5.5), k, 1.5, col, fx.barrel === 1 ? 1 - fx.barrelSince * 8 : 0); } },
        ] },
        { name: "Twin Mount", cost: 330, effect: "2 targets at full damage (primary)", options: [
          { key: "A", name: "Twin Rotary", desc: "A second, smaller rotary cluster on the left flank, both firing at full rate.", targets: 2, muzzles: [[20 / 48, 0], [18 / 48, -9 / 48]],
            over: (c, aim, s, fx, t, col) => { const k = G(s); plate(P(c, aim, k, 1, -9), rectPts(3, 2.6), METAL_L, aim, k, 1); cluster(c, aim, k, fx, t, -9, 4, 17, 2.6, 1.5, 4, col); } },
          { key: "B", name: "Gun Pods", desc: "Two rotary gun pods on short arms either side; the main gun and the left pod share targets.", targets: 2, muzzles: [[20 / 48, 0], [17 / 48, -10 / 48]],
            over: (c, aim, s, fx, t, col) => { const k = G(s); for (const y of [-10, 10]) { bar(c, P(c, aim, k, 0, y), 2 * k, METAL_L); plate(P(c, aim, k, 2, y), rectPts(4, 2.6), METAL, aim, k, 1); cluster(c, aim, k, fx, t, y, 5, 16, 2.2, 1.3, 3, col); } } },
          { key: "C", name: "Stacked Gun", desc: "A second gun mounted high on the body over the first, offset left.", targets: 2, muzzles: [[20 / 48, 0], [17 / 48, -4.5 / 48]],
            over: (c, aim, s, fx, t, col) => { const k = G(s); plate(P(c, aim, k, -1, -4.5), rectPts(4, 3), METAL_L, aim, k, 1.1); cluster(c, aim, k, fx, t, -4.5, 3, 16, 2.4, 1.4, 4, col); } },
        ] },
        { name: "Belt Feed", cost: 660, effect: "+0.3 shots/s on every barrel", options: [
          { key: "A", name: "Belt Feeds", desc: "Ammo belts run from the drum to every gun on the mount.",
            over: (c, aim, s, fx, t) => { const k = G(s); beltLine(P(c, aim, k, -1, 5), P(c, aim, k, 4, 2), k, 4, null, t); beltLine(P(c, aim, k, -1, 5), P(c, aim, k, 2, -6), k, 5, null, t); } },
          { key: "B", name: "Ammo Hopper", desc: "A big ammo hopper on the back of the turret, hazard-striped.",
            over: (c, aim, s, fx, t, col) => { const k = G(s); plate(P(c, aim, k, -11, 0), rectPts(3, 7), AMMO, aim, k, 1.1); hazard(c, aim, k, -13.5, -8.5, -7.6, col, 1.1); } },
          { key: "C", name: "Feed Motors", desc: "Small feed motors with spinning gears drive the belts.",
            over: (c, aim, s, fx, t) => { const k = G(s); for (const y of [-5, 5]) { const p = P(c, aim, k, -5, y); disc(p, 2 * k, OUTLINE); disc(p, 1.6 * k, METAL); for (let i = 0; i < 4; i++) line(p, add(p, mul(fa(t * 8 + i * Math.PI / 2), 1.6 * k)), METAL_L, 0.7 * k); } } },
        ] },
        { name: "Triple Mount", cost: 3300, effect: "3 targets; the extra barrels go for the weakest (mastery)", options: [
          { key: "A", name: "Triple Rotary", desc: "A third rotary cluster on the right flank, over the drum; all three gold-ringed.", targets: 3, muzzles: [[20 / 48, 0], [18 / 48, -9 / 48], [18 / 48, 9 / 48]],
            over: (c, aim, s, fx, t, col) => { const k = G(s); for (const y of [-9, 9]) { plate(P(c, aim, k, 1, y), rectPts(3, 2.6), METAL_L, aim, k, 1); cluster(c, aim, k, fx, t, y, 4, 17, 2.6, 1.5, 4, col, true); } ring(c, 7.4 * k, GOLD, 1 * k); } },
          { key: "B", name: "Gun Crown", desc: "A gold crown ring carries three guns fanned out round the body.", targets: 3, muzzles: [[20 / 48, 0], [15 / 48, -9 / 48], [15 / 48, 9 / 48]],
            over: (c, aim, s, fx, t, col) => { const k = G(s); ring(c, 8.6 * k, OUTLINE, 3 * k); ring(c, 8.6 * k, GOLD, 1.8 * k); for (const y of [-9, 9]) { orb(P(c, aim, k, 2, y), 1.8 * k, METAL); bar(P(c, aim, k, 2, y), P(c, aim, k, 14, y), 1.5 * k, METAL_L); muzzleEnd(P(c, aim, k, 15, y), k, 1.5, col, fx.flash * 0.6); } } },
          { key: "C", name: "Weapon Wing", desc: "A wide armoured wing across the turret, gold-edged, carrying a gun at each tip.", targets: 3, muzzles: [[20 / 48, 0], [16 / 48, -13 / 48], [16 / 48, 13 / 48]],
            under: (c, aim, s) => { const k = G(s), w = [[3, -15], [3, 15], [-4, 15], [-6, 0], [-4, -15]]; plate(c, w, METAL_L, aim, k, 1.2); outline(c, w.map((q) => mul(q, 0.9)), GOLD, 1 * k, aim, k); },
            over: (c, aim, s, fx, t, col) => { const k = G(s); for (const y of [-13, 13]) { bar(P(c, aim, k, 0, y), P(c, aim, k, 15, y), 1.6 * k, METAL_L); muzzleEnd(P(c, aim, k, 16, y), k, 1.6, col, fx.flash * 0.6); } } },
        ] },
      ] },
  ],
  retrofits: [
    { name: "Water-Cooled Barrel", cost: 40, effect: "Fire rate 1.2 to 1.5/s", options: [
      { key: "A", name: "Water Jacket", desc: "A thick water jacket sleeves the barrels, piped to a small tank; a vapour wisp at the muzzle when it fires.",
        over: (c, aim, s, fx) => { const k = G(s), r = RC(fx); plate(P(c, aim, k, 12.5 - r, 0), rectPts(4.5, 5.2), [0.3, 0.42, 0.5, 1], aim, k, 1); orb(P(c, aim, k, -6, -6), 2.2 * k, [0.3, 0.42, 0.5, 1]); line(P(c, aim, k, -6, -6), P(c, aim, k, 8, -4), [0.2, 0.3, 0.36, 1], 1.2 * k); vapour(P(c, aim, k, 20, 0), fx, s); } },
      { key: "B", name: "Coolant Coils", desc: "Copper coolant coils wrap the barrel cluster; steam wisps from the vent block.",
        over: (c, aim, s, fx) => { const k = G(s), r = RC(fx); for (let x = 9; x <= 16; x += 1.4) line(P(c, aim, k, x - r, -4.6), P(c, aim, k, x + 0.7 - r, 4.6), COPPER, 0.9 * k); vapour(P(c, aim, k, -8, 0), fx, s); } },
      { key: "C", name: "Radiator Shroud", desc: "A finned radiator plate over the cluster with blue coolant lines glowing through it.",
        over: (c, aim, s, fx) => { const k = G(s), r = RC(fx); plate(P(c, aim, k, 12 - r, 0), rectPts(4, 4.4), METAL_L, aim, k, 1); for (let x = 9; x <= 15; x += 1.5) line(P(c, aim, k, x - r, -3.6), P(c, aim, k, x - r, 3.6), [0.4, 0.75, 1, 0.8], 0.8 * k); vapour(P(c, aim, k, 20, 0), fx, s); } },
    ] },
    { name: "AP Belt", cost: 15, effect: "Rounds ignore 2 armour", options: [
      { key: "A", name: "Striped Belt", desc: "A belt of yellow-and-black striped AP rounds runs from the drum into the breech.",
        over: (c, aim, s, fx, t) => { const k = G(s); beltLine(P(c, aim, k, -1, 5), P(c, aim, k, 4, 2), k, 4, [1, 0.85, 0.2, 1], t); } },
      { key: "B", name: "Striped Drum", desc: "The drum is repainted with yellow-and-black AP hazard stripes.",
        over: (c, aim, s) => { const k = G(s), d = P(c, aim, k, -1, 8.5); for (let i = 0; i < 8; i++) arc(d, 3.4 * k, i * TAU / 8, i * TAU / 8 + TAU / 16, i % 2 ? [0.08, 0.08, 0.08, 1] : [1, 0.85, 0.2, 1], 1.6 * k); } },
      { key: "C", name: "AP Box", desc: "A second, striped AP ammo box clipped to the back of the drum.",
        over: (c, aim, s) => { const k = G(s); plate(P(c, aim, k, -6, 8.5), rectPts(2.4, 2.6), AMMO, aim, k, 1); hazard(c, aim, k, -8, -4, 11.4, [1, 0.85, 0.2, 1], 1); } },
    ] },
    { name: "Tracer Feed", cost: 20, effect: "+10 range; every 5th round is a tracer that briefly reveals a cloaked enemy it hits", options: [
      { key: "A", name: "Red-Tip Belt", desc: "Red-tipped rounds in the feed; every 5th shot is a long red tracer.",
        over: (c, aim, s, fx, t) => { const k = G(s); beltLine(P(c, aim, k, -1, 5), P(c, aim, k, 4, 2), k, 4, RED_TIP, t); },
        shotFx: (f, to, u, s, col, k, t, info) => { if (info && info.sh && info.sh.m % 5 === 0) longTracer(f, to, u, RED_TIP, 1.6); } },
      { key: "B", name: "Tracer Canister", desc: "A small red tracer canister clipped to the body; every 5th shot is a long red tracer.",
        over: (c, aim, s) => { const k = G(s); bar(P(c, aim, k, -6, -5), P(c, aim, k, -2, -5), 2.6 * k, [0.7, 0.2, 0.18, 1]); },
        shotFx: (f, to, u, s, col, k, t, info) => { if (info && info.sh && info.sh.m % 5 === 0) longTracer(f, to, u, RED_TIP, 1.6); } },
      { key: "C", name: "Glowing Feed", desc: "The feed chute glows red as tracers pass; every 5th shot is a long red tracer.",
        over: (c, aim, s, fx, t) => { const k = G(s); line(P(c, aim, k, -1, 5), P(c, aim, k, 4, 2), [1, 0.3, 0.25, 0.5 + 0.5 * Math.sin(t * 10)], 1.6 * k); },
        shotFx: (f, to, u, s, col, k, t, info) => { if (info && info.sh && info.sh.m % 5 === 0) longTracer(f, to, u, RED_TIP, 1.6); } },
    ] },
  ],
};
function k0(s) { return G(s); }
