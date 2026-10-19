// ---- Tower art second pass: Boost Tower (tower 13), round 1 ------------------------------------------------------
// Base: look F Signal Drum, animation F Overcharge Sparks. One parametric model. Following the owner's note on the Chemical Plant
// ("change the structure more than add little things"), the upgrades REBUILD the tower rather than decorate it: each path owns one
// emitter module on the drum's top (damage at 90 degrees, speed at 210, range at 330), and every step builds another tier onto that
// module (the option sets the tier's shape: round, square or triangular), so the modules grow wider and taller and turn gold at the mastery.
// The Retrofits rebuild the centre and the rim (an antenna mast, a gold crown, a lattice frame) and widen the boost radius.
// The Signal Booster Retrofit's extra +5% to every boost overlaps the paths' boost steps and is kept, stacking (the carpet rule).
// Geometry (game px): a round drum r 11 (membrane rings ripple on each beat) braced by three struts; modules at r 6.2 on the drum top.
const PAGE = { title: "Boost Tower: paths and Retrofits (second pass)", store: "bl-tower-art-p2-boost-r1" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1];
const SCOL = [[1, 0.5, 0.2, 1], [0.4, 0.9, 1, 1], [0.7, 1, 0.3, 1]]; // damage, speed, range
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null);
const chevN = (lv) => (lv === 0 ? 1 : lv <= 2 ? 2 : lv <= 4 ? 3 : 4);                 // how many chevrons a stat shows on a boosted tower
const radiusMul = (B) => 1 + (B.r === 0 ? 0.167 : B.r === 2 ? 0.333 : 0);                // Signal Booster 168 px, Wide Mast 192 px (stock 144 px)

// ---- The agent: sparks jump from the tower to each boosted tower in turn; each shows a stack of chevrons for every stat it is boosted in ----
function boostAgent(B) { return (m, t, info, s, col) => { const mates = matesOf(info), cur = Math.floor(t * 1.5) % mates.length, u = fmod(t * 1.5, 1), k = G(s), Rb = s * 1.6 * radiusMul(B), crit = B.r === 1;
  ring(info.c, Rb, A(col, 0.12), 1); for (let i = 0; i < 24; i++) { const a = i * TAU / 24 + t * 0.1; if (i % 2) continue; line(add(info.c, mul(fa(a), Rb)), add(info.c, mul(fa(a + 0.12), Rb)), A(col, 0.3), 1.2); } // the boost radius, faintly
  mates.forEach((mt, i) => { const on = i === cur, al = on ? 1 : 0.5;
    mateTower(mt.p, k, mt.col, t, 0, col);
    for (let st = 0; st < 3; st++) { const n = chevN(B.lv[st]), c1 = B.lv[st] >= 5 ? GOLD : SCOL[st];
      for (let j = 0; j < n; j++) { const q = add(mt.p, [(st - 1) * 3.6 * k * 0.9, -(15.5 + j * 2.6) * k * 0.75]); polyline([add(q, [-1.8 * k, 1.1 * k]), q, add(q, [1.8 * k, 1.1 * k])], A(c1, al), 1.3 * k); } }
    if (crit) { const q = add(mt.p, [5.6 * k, -12 * k * 0.75]); glowDot(q, 0.7 * k * (on ? 1.3 : 0.8), A(GOLD, al)); }                    // Crit Link: a gold crit spark by each boosted tower
    if (on && u < 0.35) { const pts = [info.c]; for (let j = 1; j < 6; j++) pts.push(add(lerp(info.c, mt.p, j / 6), mul(orth(norm(sub(mt.p, info.c))), (rnd2(Math.floor(t * 30) + j) - 0.5) * s * 0.25))); pts.push(mt.p);
      polyline(pts, A(col, 0.3), 4); polyline(pts, col, 1.6); polyline(pts, [1, 1, 1, 0.8], 0.6); }
    if (on) for (let st = 0; st < 3; st++) glowDot(add(mt.p, [s * (0.1 + 0.05 * st), -s * 0.08]), s * 0.03 * (1 - u), B.lv[st] >= 5 ? GOLD : SCOL[st]); }); }; }

// ---- The model: the drum, its struts and three emitter modules that grow tier by tier ----------------------------------------------
const P2 = {
  tower: "boost", look: "F", anim: "F",
  intro: "Round 1b: each path owns a disc-shaped emitter module on the drum's top (damage orange, speed cyan, range lime). The disc keeps its size and fades further toward gold with every step (pure gold at the mastery); the last step's option is its style (glossy, ringed or petalled). Before that, Round 1: The boosted towers show a chevron stack for each stat. The Retrofits rebuild the centre (an antenna mast), the rim (a gold crown) or add a lattice frame, and widen the faint boost radius. The Signal Booster's extra +5% overlaps the boost steps and is kept, stacking (the carpet rule). Unpicked steps show option A.",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: boostAgent(B) }; },
  muzzleAt(B, m, kk, c) { return c; },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), beat = fmod(t * 1.2, 1), R = B.r >= 0 ? B.key("r" + B.r) : null, S = (x, y) => add(c, [x * k, y * k]);
    deck(c, k, col, t);
    // ---- The drum and its three struts ------------------------------------------------------------------------------------------------
    const crown = B.r === 1, wide = B.r === 2;
    for (let i = 0; i < 3; i++) { const d = fa(Math.PI / 2 + i * TAU / 3), e = wide && R === "B" ? 16 : 14; bar(add(c, mul(d, 9 * k)), add(c, mul(d, e * k)), 2 * k, METAL); if (wide && R === "B") { line(add(c, mul(d, 12 * k)), add(c, mul(fa(Math.PI / 2 + i * TAU / 3 + 0.35), 15 * k)), METAL_L, 1 * k); line(add(c, mul(d, 12 * k)), add(c, mul(fa(Math.PI / 2 + i * TAU / 3 - 0.35), 15 * k)), METAL_L, 1 * k); } }
    disc(c, 11 * k, OUTLINE); disc(c, 10.3 * k, METAL_L); disc(c, 8.6 * k, METAL_D);
    for (let i = 0; i < 3; i++) { const r = fmod(beat + i / 3, 1); ring(c, (2 + 6.4 * r) * k, A(col, 0.6 * (1 - r)), 1.1 * k); }
    // ---- The three modules: one disc per path that FADES toward gold with every step (it never grows or gains rings); the last step's option is its style ----
    for (let st = 0; st < 3; st++) { const lv = B.lv[st], a = Math.PI / 2 + st * TAU / 3, q = add(c, mul(fa(a), 6.2 * k)), fade = lv / 5, mc = mix(SCOL[st], GOLD, fade), key = lv > 0 ? B.key("p" + st + "s" + (lv - 1)) : "A", r = 3.2 * k;
      disc(q, r + 0.6 * k, OUTLINE); disc(q, r, dk(mc, 0.45));
      if (lv === 0) { ring(q, r * 0.6, A(SCOL[st], 0.5), 0.9 * k); glowDot(q, 0.5 * k, A(SCOL[st], 0.6)); continue; }
      if (key === "A") { orb(q, r * 0.88, mix(METAL_L, mc, 0.8 + 0.2 * fade)); }                                                      // a glossy disc
      else if (key === "B") { disc(q, r * 0.88, mix(METAL_L, mc, 0.8 + 0.2 * fade)); ring(q, r * 0.58, A(dk(mc, 0.3), 0.9), 1 * k); disc(q, r * 0.3, mc); }  // a disc with an inner ring and core
      else { for (let i = 0; i < 6; i++) { const aa = i * TAU / 6 + 0.2; fill(q, [[0, 0], [Math.cos(aa) * r * 0.92 / k, Math.sin(aa) * r * 0.92 / k], [Math.cos(aa + TAU / 6) * r * 0.92 / k, Math.sin(aa + TAU / 6) * r * 0.92 / k]], i % 2 ? mix(METAL_L, mc, 0.75 + 0.25 * fade) : mc, 0, k); } }  // a six-petal disc
      glowDot(q, 0.55 * k * (1 + 0.35 * Math.sin(t * 5 + st)), mc); }
    // ---- The Retrofits rebuild the centre, the rim, or add a frame -----------------------------------------------------------------------------------------
    if (B.r === 0) { if (R === "A") { for (let st = 0; st < 3; st++) { const a = Math.PI / 2 + st * TAU / 3; line(c, add(c, mul(fa(a), 6.2 * k)), A(STEEL, 0.9), 0.8 * k); } disc(c, 2.4 * k, OUTLINE); disc(c, 1.9 * k, METAL); line(c, add(c, [0, -6 * k]), METAL_L, 1.2 * k); glowDot(add(c, [0, -6.4 * k]), 0.7 * k, [1, 0.3, 0.3, 1]); }  // an antenna mast with guy wires
      if (R === "B") { ring(c, 3.4 * k, METAL_L, 1.6 * k); for (let i = 0; i < 3; i++) line(add(c, mul(fa(i * TAU / 3 + 0.5), 3.4 * k)), add(c, mul(fa(i * TAU / 3 + 0.5), 5.4 * k)), METAL_L, 1.2 * k); glowDot(c, 1.2 * k, col); }       // a loop antenna
      if (R === "C") { fill(c, [[0, -5.4], [1.8, 1.8], [-1.8, 1.8]], METAL_L, 0, k); ring(c, 2.4 * k, METAL, 1 * k); glowDot(add(c, [0, -5.6 * k]), 0.7 * k, [1, 0.3, 0.3, 1]); } }                                             // a spire
    if (crown) { if (R === "A") { ring(c, 11.4 * k, GOLD, 1.6 * k); for (let i = 0; i < 3; i++) disc(add(c, mul(fa(Math.PI / 2 + i * TAU / 3 + 0.5), 11.4 * k)), 1 * k, GOLD); }
      if (R === "B") { disc(c, 11 * k, A(GOLD, 0.2)); ring(c, 10.4 * k, GOLD, 1.2 * k); ring(c, 9 * k, A(GOLD, 0.6), 0.8 * k); }
      if (R === "C") for (let i = 0; i < 12; i++) { const a = i * TAU / 12; fill(add(c, mul(fa(a), 11.2 * k)), [[0, -0.9], [2.2, 0], [0, 0.9]], GOLD, a, k); } }
    if (wide && R === "A") { const sq = [[-9, -9], [9, -9], [9, 9], [-9, 9]].map((q) => add(c, mul(q, k))); for (let i = 0; i < 4; i++) bar(sq[i], sq[(i + 1) % 4], 1.4 * k, METAL_L); bar(sq[0], sq[2], 0.9 * k, METAL); bar(sq[1], sq[3], 0.9 * k, METAL); }
    if (wide && R === "C") { ring(c, 13 * k, METAL_L, 1.6 * k); for (let i = 0; i < 6; i++) line(add(c, mul(fa(i * TAU / 6), 11 * k)), add(c, mul(fa(i * TAU / 6), 13 * k)), METAL_L, 1.2 * k); }
    glowDot(c, (1.2 + 0.8 * (1 - beat)) * k, col);
  },
  paths: [
    { name: "Damage boost", theme: "the orange module: each step builds another tier on it", steps: [
      { name: "Amplifier", cost: 615, effect: "Damage boost +15%", options: [
        { key: "A", name: "Glossy Disc", desc: "The damage module is a glossy disc; it fades a step further from orange toward gold." },
        { key: "B", name: "Ringed Disc", desc: "The damage module is a disc with an inner ring and a core; it fades a step further from orange toward gold." },
        { key: "C", name: "Petal Disc", desc: "The damage module is a six-petal disc; it fades a step further from orange toward gold." } ] },
      { name: "Power Relay", cost: 860, effect: "+22%", options: [
        { key: "A", name: "Glossy Disc", desc: "The damage module is a glossy disc; it fades a step further from orange toward gold." },
        { key: "B", name: "Ringed Disc", desc: "The damage module is a disc with an inner ring and a core; it fades a step further from orange toward gold." },
        { key: "C", name: "Petal Disc", desc: "The damage module is a six-petal disc; it fades a step further from orange toward gold." } ] },
      { name: "Overcharge Link", cost: 2460, effect: "+32% (primary)", options: [
        { key: "A", name: "Glossy Disc", desc: "The damage module is a glossy disc; it fades a step further from orange toward gold." },
        { key: "B", name: "Ringed Disc", desc: "The damage module is a disc with an inner ring and a core; it fades a step further from orange toward gold." },
        { key: "C", name: "Petal Disc", desc: "The damage module is a six-petal disc; it fades a step further from orange toward gold." } ] },
      { name: "Surge Link", cost: 3940, effect: "+40%", options: [
        { key: "A", name: "Glossy Disc", desc: "The damage module is a glossy disc; it fades a step further from orange toward gold." },
        { key: "B", name: "Ringed Disc", desc: "The damage module is a disc with an inner ring and a core; it fades a step further from orange toward gold." },
        { key: "C", name: "Petal Disc", desc: "The damage module is a six-petal disc; it fades a step further from orange toward gold." } ] },
      { name: "Battle Network", cost: 9845, effect: "+50% damage (mastery)", options: [
        { key: "A", name: "Glossy Disc", desc: "The damage module is a glossy disc; it is pure gold, and so are the chevrons." },
        { key: "B", name: "Ringed Disc", desc: "The damage module is a disc with an inner ring and a core; it is pure gold, and so are the chevrons." },
        { key: "C", name: "Petal Disc", desc: "The damage module is a six-petal disc; it is pure gold, and so are the chevrons." } ] },
    ] },
    { name: "Speed boost", theme: "the cyan module: each step builds another tier on it", steps: [
      { name: "Clock Sync", cost: 615, effect: "Fire-rate boost +15%", options: [
        { key: "A", name: "Glossy Disc", desc: "The speed module is a glossy disc; it fades a step further from cyan toward gold." },
        { key: "B", name: "Ringed Disc", desc: "The speed module is a disc with an inner ring and a core; it fades a step further from cyan toward gold." },
        { key: "C", name: "Petal Disc", desc: "The speed module is a six-petal disc; it fades a step further from cyan toward gold." } ] },
      { name: "Fast Sync", cost: 860, effect: "+22%", options: [
        { key: "A", name: "Glossy Disc", desc: "The speed module is a glossy disc; it fades a step further from cyan toward gold." },
        { key: "B", name: "Ringed Disc", desc: "The speed module is a disc with an inner ring and a core; it fades a step further from cyan toward gold." },
        { key: "C", name: "Petal Disc", desc: "The speed module is a six-petal disc; it fades a step further from cyan toward gold." } ] },
      { name: "Overclock Link", cost: 2460, effect: "+32% (primary)", options: [
        { key: "A", name: "Glossy Disc", desc: "The speed module is a glossy disc; it fades a step further from cyan toward gold." },
        { key: "B", name: "Ringed Disc", desc: "The speed module is a disc with an inner ring and a core; it fades a step further from cyan toward gold." },
        { key: "C", name: "Petal Disc", desc: "The speed module is a six-petal disc; it fades a step further from cyan toward gold." } ] },
      { name: "Turbo Link", cost: 3940, effect: "+40%", options: [
        { key: "A", name: "Glossy Disc", desc: "The speed module is a glossy disc; it fades a step further from cyan toward gold." },
        { key: "B", name: "Ringed Disc", desc: "The speed module is a disc with an inner ring and a core; it fades a step further from cyan toward gold." },
        { key: "C", name: "Petal Disc", desc: "The speed module is a six-petal disc; it fades a step further from cyan toward gold." } ] },
      { name: "Rapid Network", cost: 9845, effect: "+50% fire rate (mastery)", options: [
        { key: "A", name: "Glossy Disc", desc: "The speed module is a glossy disc; it is pure gold, and so are the chevrons." },
        { key: "B", name: "Ringed Disc", desc: "The speed module is a disc with an inner ring and a core; it is pure gold, and so are the chevrons." },
        { key: "C", name: "Petal Disc", desc: "The speed module is a six-petal disc; it is pure gold, and so are the chevrons." } ] },
    ] },
    { name: "Range boost", theme: "the lime module: each step builds another tier on it", steps: [
      { name: "Spotting Relay", cost: 370, effect: "Range boost +15%", options: [
        { key: "A", name: "Glossy Disc", desc: "The range module is a glossy disc; it fades a step further from lime toward gold." },
        { key: "B", name: "Ringed Disc", desc: "The range module is a disc with an inner ring and a core; it fades a step further from lime toward gold." },
        { key: "C", name: "Petal Disc", desc: "The range module is a six-petal disc; it fades a step further from lime toward gold." } ] },
      { name: "Wide Relay", cost: 515, effect: "+22%", options: [
        { key: "A", name: "Glossy Disc", desc: "The range module is a glossy disc; it fades a step further from lime toward gold." },
        { key: "B", name: "Ringed Disc", desc: "The range module is a disc with an inner ring and a core; it fades a step further from lime toward gold." },
        { key: "C", name: "Petal Disc", desc: "The range module is a six-petal disc; it fades a step further from lime toward gold." } ] },
      { name: "Targeting Link", cost: 1475, effect: "+32% (primary)", options: [
        { key: "A", name: "Glossy Disc", desc: "The range module is a glossy disc; it fades a step further from lime toward gold." },
        { key: "B", name: "Ringed Disc", desc: "The range module is a disc with an inner ring and a core; it fades a step further from lime toward gold." },
        { key: "C", name: "Petal Disc", desc: "The range module is a six-petal disc; it fades a step further from lime toward gold." } ] },
      { name: "Long Link", cost: 2365, effect: "+40%", options: [
        { key: "A", name: "Glossy Disc", desc: "The range module is a glossy disc; it fades a step further from lime toward gold." },
        { key: "B", name: "Ringed Disc", desc: "The range module is a disc with an inner ring and a core; it fades a step further from lime toward gold." },
        { key: "C", name: "Petal Disc", desc: "The range module is a six-petal disc; it fades a step further from lime toward gold." } ] },
      { name: "Overwatch Network", cost: 5910, effect: "+50% range (mastery)", options: [
        { key: "A", name: "Glossy Disc", desc: "The range module is a glossy disc; it is pure gold, and so are the chevrons." },
        { key: "B", name: "Ringed Disc", desc: "The range module is a disc with an inner ring and a core; it is pure gold, and so are the chevrons." },
        { key: "C", name: "Petal Disc", desc: "The range module is a six-petal disc; it is pure gold, and so are the chevrons." } ] },
    ] },
  ],
  retrofits: [
    { name: "Signal Booster", cost: 1380, effect: "Radius 168 px and +5% to all three boosts (stacks with the path boosts)", options: [
      { key: "A", name: "Antenna Mast", desc: "A mast rises from the centre of the drum on guy wires to the three modules; the boost radius ring widens." },
      { key: "B", name: "Loop Antenna", desc: "A loop antenna with three arms at the centre of the drum; a wider radius ring." },
      { key: "C", name: "Spire", desc: "A tall spire at the centre of the drum; a wider radius ring." } ] },
    { name: "Crit Link", cost: 185, effect: "Boosted towers gain a 3% crit chance", options: [
      { key: "A", name: "Gold Ring", desc: "A gold ring with three gold nodes round the drum; boosted towers get a gold crit spark." },
      { key: "B", name: "Gold Collar", desc: "A gold collar over the drum's rim; boosted towers get a gold crit spark." },
      { key: "C", name: "Gold Crown", desc: "A crown of twelve gold prongs round the drum; boosted towers get a gold crit spark." } ] },
    { name: "Wide Mast", cost: 625, effect: "Radius 192 px (a 4-tile aura)", options: [
      { key: "A", name: "Lattice Frame", desc: "A square lattice frame is built over the drum; the boost radius ring widens most." },
      { key: "B", name: "Truss Legs", desc: "The three struts are rebuilt as long braced truss legs; a wider radius ring." },
      { key: "C", name: "Spoked Ring", desc: "A wide spoked ring is built round the drum; a wider radius ring." } ] },
  ],
};
P2.picks = {};
