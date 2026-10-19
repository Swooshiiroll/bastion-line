// ---- Tower art second pass: Cryo Tower (tower 15), round 1 ------------------------------------------------------
// Base: look B Compressor Block, animation C Creeping Mist. One parametric model built on the lessons so far: every step REBUILDS a part
// (the new design replaces the old one, it does not pile extras on), the options swap that part's style, masteries turn gold, and the agent
// runs the real rules (wave rate, range, slow strength, permanent chill, the 4th-wave freeze, frostbite) so the preview shows what a step does.
// Layout (game px, top-down): a square compressor housing with a big fan in the middle (path 3, Speed: the fan and its vents), a station in each
// corner (path 1, Slowing: coolant tanks, vaults or crystals that grow colder) and a frost rim on the middle of each edge (path 2, Power/Range:
// jagged frost). The Retrofits add a coolant tank on the left, a compressor on the right and frost-white vents at the bottom.
// Overlaps kept and stacking (the carpet rule): Compressor's wave every 1.7 s with the path-3 wave rate, Deep Cold's +5% slow with the path-1 slows,
// Coolant Tank's longer slow with the permanent chill.
const PAGE = { title: "Cryo Tower: paths and Retrofits (second pass)", store: "bl-tower-art-p2-cryo-r6" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], ICE = [0.75, 0.92, 1, 1], DEEP = [0.35, 0.6, 0.85, 1];
const rnd = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null);
const PER = [2, 1.75, 1.5, 1.2, 1, 1], SLOW = [20, 28, 35, 35, 45, 50], RADP = [110, 120, 130, 145, 145, 165];
const periodOf = (B) => PER[B.lv[2]] * (B.r === 1 ? 0.85 : 1);
const radiusPx = (B) => RADP[B.lv[1]];
const slowOf = (B) => SLOW[B.lv[0]] + (B.r === 2 ? 5 : 0);
const chillFor = (B) => 1.5 + (B.r === 0 ? 0.7 : 0);

// ---- Marks on enemies ----------------------------------------------------------------------------------------------------------------------------
function chillMark(p, s, a, gold) { const r = Math.max(4, Math.min(11, s * 0.12)), c1 = gold ? GOLD : ICE; disc(p, r + 1, A([0.6, 0.85, 1, 1], 0.6 * a)); ring(p, r + 2, A(c1, 0.9 * a), 1.4);
  for (let i = 0; i < 3; i++) { const d = fa(i * Math.PI / 3); line(sub(p, mul(d, r * 0.7)), add(p, mul(d, r * 0.7)), [1, 1, 1, 0.75 * a], 1); } }
function iceBlock(p, s, a, gold) { const r = Math.max(4, Math.min(11, s * 0.12)) + 3; poly([[p[0] - r, p[1] - r], [p[0] + r, p[1] - r], [p[0] + r, p[1] + r], [p[0] - r, p[1] + r]], A([0.7, 0.9, 1, 1], 0.78 * a));
  polyline([[p[0] - r, p[1] - r], [p[0] + r, p[1] - r], [p[0] + r, p[1] + r], [p[0] - r, p[1] + r], [p[0] - r, p[1] - r]], A(gold ? GOLD : [1, 1, 1, 1], a), 1.6); line([p[0] - r * 0.6, p[1] - r * 0.2], [p[0] - r * 0.2, p[1] - r * 0.6], [1, 1, 1, 0.9 * a], 1.2); }
function frostShards(p, s, t0, t, n) { const age = t - t0; if (age < 0 || age > 0.7) return; const a = 1 - age / 0.7, r = Math.max(4, Math.min(11, s * 0.12));
  for (let j = 0; j < n; j++) { const x = (j - (n - 1) / 2) * 3.2, y = -r - 3 + age * 12; fill([p[0] + x, p[1] + y], [[0, 2.4], [1.3, -1], [-1.3, -1]], A([0.85, 0.96, 1, 1], a), 0, 1); } }

// ---- The agent: waves of creeping mist; every enemy it reaches is chilled; permanent chill, the 4th-wave freeze and frostbite follow the paths -------
function coldAgent(B) { return (m, t, info, s, col) => { if (!m.cold) { m.cold = {}; m.perm = {}; m.fz = {}; m.hit = {}; m.wave = -9; m.n = 0; }
  const L1 = B.lv[0], L2 = B.lv[1], L3 = B.lv[2], constant = L3 >= 5, per = constant ? 1.2 : periodOf(B), c = info.c, gold = L1 >= 5 || L2 >= 5;
  if (t - m.wave >= per) { m.wave = t; m.n++; }
  const R = s * 2.3 * radiusPx(B) / 110, travel = constant ? 1 : 1.8, raw = (t - m.wave) / travel, u = Math.min(1, raw), a = 0.55 + 0.45 * (1 - Math.min(1, raw / 2)), mist = ICE;
  ring(c, R, A(mist, 0.14), 1); for (let i = 0; i < 24; i += 2) line(add(c, mul(fa(i * TAU / 24 + t * 0.04), R)), add(c, mul(fa((i + 1) * TAU / 24 + t * 0.04), R)), A(mist, 0.28), 1.2);
  if (constant) { disc(c, R, A(ICE, 0.08)); }
  for (let i = 0; i < 22; i++) { const ang = rnd(i) * TAU + t * 0.1 * (i % 2 ? 1 : -1), rr = R * Math.min(constant ? 1 : u, rnd(i + 9)), p = add(c, mul(fa(ang), rr)); disc(p, s * (0.12 + 0.04 * Math.sin(t * 1.5 + i)), A(mist, 0.16 * a)); }
  const front = R * u; if (!constant && raw < 1.2) ring(c, front, A(ICE, 0.35 * (1 - raw / 1.2)), 2);
  for (const e of info.ens) { const d = dist(e.p, c), reached = constant ? d < R : raw <= 1.2 && d < front;
    if (reached) { if (!((m.cold[e.i] || 0) > t + 0.3) && L2 > 0) m.hit[e.i] = t; m.cold[e.i] = t + chillFor(B); if (L1 >= 3) m.perm[e.i] = true; if (L1 >= 5 && m.n % 4 === 0 && !(m.fz[e.i] > t)) m.fz[e.i] = t + 1; }
    const left = (m.cold[e.i] || 0) - t;
    if (m.fz[e.i] > t) iceBlock(e.p, s, Math.min(1, (m.fz[e.i] - t) * 3), gold);
    else if (left > 0) chillMark(e.p, s, Math.min(1, left * 1.5) * (0.5 + 0.5 * slowOf(B) / 55), L1 >= 5);
    else if (m.perm[e.i]) { const r = Math.max(4, Math.min(11, s * 0.12)); ring(e.p, r + 2, A(ICE, 0.35), 1); }              // the permanent chill: a faint frost ring outside the range
    if (L2 > 0 && m.hit[e.i] !== undefined) frostShards(e.p, s, m.hit[e.i], t, Math.min(4, 1 + L2)); } }; }

// ---- Path 1 stations: stage x option picks the design (all rebuilt from scratch each step) --------------------------------------------------------------
function station(p, L, key, k, t, i, puff, sz, tr, g, out) { const ix = "ABC".indexOf(key), oa = Math.atan2(out[1], out[0]), W = [1, 1, 1, 1];
  if (L === 1 && ix === 0) { disc(p, sz * k + 1 * k, OUTLINE); disc(p, sz * k, METAL_D); const pts = []; for (let j = 0; j <= 20; j++) pts.push(add(p, mul(fa(j * 0.9 + t * 0.6), (sz * 0.25 + j * sz * 0.034) * k))); polyline(pts, A(ICE, 0.95), 1.4 * k); glowDot(p, 0.45 * k, tr); }                               // a cooling coil
  if (L === 1 && ix === 1) { plate(p, rectPts(sz * 0.8, sz * 0.8), METAL_L, 0, k, 1.1); const e = add(p, mul(out, sz * 1.7 * k)); bar(p, e, 1.7 * k, METAL); fill(e, [[0, -1.1], [sz * 0.7, -sz * 0.5], [sz * 0.7, sz * 0.5], [0, 1.1]], METAL_L, oa, k);
    for (let j = 0; j < 4; j++) disc(add(e, mul(out, (sz * 0.9 + j * 1.4 + puff * 2) * k)), (0.5 + j * 0.3) * k, A(W, 0.45 - j * 0.09)); }                                                              // a snow gun
  if (L === 1 && ix === 2) { fill(p, [[-0.5, -sz], [0.5, -sz], [0.5, -sz * 0.35], [sz * 0.9, sz * 0.9], [-sz * 0.9, sz * 0.9], [-0.5, -sz * 0.35]], A(ICE, 0.55), 0, k); fill(p, [[-sz * 0.62, sz * 0.25], [sz * 0.62, sz * 0.25], [sz * 0.9, sz * 0.9], [-sz * 0.9, sz * 0.9]], A(DEEP, 0.95), 0, k);
    outline(p, [[-0.5, -sz], [0.5, -sz], [0.5, -sz * 0.35], [sz * 0.9, sz * 0.9], [-sz * 0.9, sz * 0.9], [-0.5, -sz * 0.35]], METAL_L, 1.1 * k, 0, k); }                                                                // a frost flask
  if (L === 2 && ix === 0) { plate(p, rectPts(sz * 1.2, sz * 0.7), METAL_L, oa, k, 1.2); const ph = Math.sin(t * 6 + i) * 0.8; bar(add(p, mul(out, -sz * k)), add(p, mul(out, (sz * 1.5 + ph) * k)), 1.2 * k, STEEL); disc(add(p, mul(out, (sz * 1.5 + ph) * k)), 1 * k, METAL_L); disc(add(p, mul(out, -sz * 0.9 * k)), sz * 0.55 * k, A(ICE, 0.85)); }  // a cryo pump
  if (L === 2 && ix === 1) { plate(p, rectPts(sz * 0.62, sz * 1.25), METAL_L, 0, k, 1.2); disc(add(p, [0, -sz * 1.25 * k]), sz * 0.62 * k, METAL_L); disc(add(p, [0, sz * 1.25 * k]), sz * 0.62 * k, METAL_L); ring(add(p, [0, sz * 0.1 * k]), sz * 0.62 * k, A(ICE, 0.9), 1 * k); for (let j = 0; j < 3; j++) disc(add(p, [(j - 1) * 0.7 * k, (-sz * 1.6 - puff * (1 + j)) * k]), (0.5 + j * 0.15) * k, A(W, 0.5 - j * 0.1)); }   // a liquid-nitrogen dewar
  if (L === 2 && ix === 2) { plate(p, rectPts(sz, sz), METAL_D, 0, k, 1.1); for (let j = 0; j < 8; j++) line(add(p, [(-sz + 0.7 + j * (sz * 2 - 1.4) / 7) * k, -sz * 0.85 * k]), add(p, [(-sz + 0.7 + j * (sz * 2 - 1.4) / 7) * k, sz * 0.85 * k]), A(ICE, 0.9), 0.9 * k); bar(add(p, [-sz * k, -sz * 0.4 * k]), add(p, [-sz * 1.4 * k, -sz * 0.4 * k]), 1 * k, DEEP); }   // a heat exchanger
  if (L === 3 && ix === 0) { for (let j = 0; j < 6; j++) { const a = j * TAU / 6; fill(add(p, mul(fa(a), sz * 0.9 * k)), [[0, -0.6], [1.9, 0], [0, 0.6]], A(ICE, 0.9), a, k); } fill(p, [[0, -sz * 1.5], [sz * 0.55, sz * 0.5], [-sz * 0.55, sz * 0.5]], METAL_L, 0, k); glowDot(add(p, [0, -sz * 0.2 * k]), 0.65 * k, tr); }   // an ice-core pylon
  if (L === 3 && ix === 1) { disc(p, sz * k + 1 * k, OUTLINE); orb(p, sz * k, mix(ICE, [0.6, 0.8, 1, 1], 0.3)); for (let j = 0; j < 4; j++) { const a = j * 1.7 + i; line(p, add(p, mul(fa(a), sz * 0.9 * k)), A(W, 0.8), 0.8 * k); } ring(p, sz * k, tr, 0.9 * k); }   // a frozen dome with cracks
  if (L === 3 && ix === 2) { disc(p, sz * k + 1 * k, OUTLINE); ring(p, sz * 0.95 * k, A(ICE, 0.9), 1.6 * k); for (let j = 0; j < 5; j++) { const a = t * 4 + j * TAU / 5; fill(p, [[0.4, 0], [sz * 0.95, 0.5], [sz * 0.55, -0.7]], METAL_L, a, k); } glowDot(p, 0.5 * k, tr); }   // a permafrost drill bit
  if (L === 4 && ix === 0) { plate(p, ngon(6, 1), METAL_L, Math.PI / 6, sz * k, 1.2); plate(p, ngon(6, 1), METAL_D, Math.PI / 6, sz * 0.7 * k, 0.9); arcSegments(p, sz * 0.9 * k, 3, 0.7, t * 1.5 + i, A(tr, 0.95), 1.2 * k); glowDot(p, 0.7 * k * (1 + 0.3 * Math.sin(t * 4 + i)), tr); }   // a cryo reactor
  if (L === 4 && ix === 1) { disc(p, sz * 0.7 * k + 1 * k, OUTLINE); disc(p, sz * 0.7 * k, METAL_L); glowDot(p, 0.6 * k, tr); for (let j = 0; j < 2; j++) { const u = fmod(t * 0.9 + j * 0.5 + i * 0.2, 1); ring(p, (sz * 0.7 + u * sz * 1.1) * k, A(tr, 0.6 * (1 - u)), 1.1 * k); } }   // a cold beacon
  if (L === 4 && ix === 2) { for (let j = 0; j < 3; j++) { const h = sz * (1 - j * 0.25); plate(p, rectPts(h, h), j % 2 ? METAL_D : METAL_L, j * 0.38 + i, k, 1); } for (let j = 0; j < 4; j++) disc(add(p, mul(fa(j * Math.PI / 2 + t), sz * 0.55 * k)), 0.4 * k, A(ICE, 0.9)); glowDot(p, 0.45 * k, tr); }   // a rime generator
  if (L === 5 && ix === 0) { const z = sz * 0.68; plate(p, ngon(6, 1), METAL_L, Math.PI / 6, z * k, 1.2); plate(p, ngon(6, 1), dk(GOLD, 0.5), Math.PI / 6, z * 0.7 * k, 0.9); arcSegments(p, z * 0.9 * k, 3, 0.7, t * 1.5 + i, A(GOLD, 0.95), 1.2 * k); ring(p, z * k + 1 * k, A(GOLD, 0.7), 0.8 * k); glowDot(p, 0.6 * k * (1 + 0.3 * Math.sin(t * 4 + i)), GOLD); }   // a gold-core reactor
  if (L === 5 && ix === 1) { disc(p, sz * 0.7 * k + 1 * k, OUTLINE); disc(p, sz * 0.7 * k, METAL_L); ring(p, sz * 0.7 * k, GOLD, 1.3 * k); glowDot(p, 0.7 * k, GOLD); for (let j = 0; j < 2; j++) { const u = fmod(t * 0.9 + j * 0.5 + i * 0.2, 1); ring(p, (sz * 0.7 + u * sz * 1.1) * k, A(GOLD, 0.7 * (1 - u)), 1.2 * k); } }   // a gold-ringed beacon
  if (L === 5 && ix === 2) { const ob = [[0, -sz * 1.4], [sz * 0.6, sz * 0.9], [-sz * 0.6, sz * 0.9]]; fill(p, ob, A(ICE, 0.95), 0, k); fill(p, [[0, -sz * 1.4], [sz * 0.6, sz * 0.9], [0, sz * 0.9]], A(DEEP, 0.9), 0, k); outline(p, ob, GOLD, 1.4 * k, 0, k); fill(add(p, [0, -sz * 1.15 * k]), [[0, -0.8], [0.7, 0.4], [-0.7, 0.4]], GOLD, 0, k); glowDot(p, 0.45 * k, GOLD); } }   // a gold-edged frozen obelisk

const CORN = [[-10, -10], [10, -10], [10, 10], [-10, 10]], EDGE = [[0, -12.2, -Math.PI / 2], [0, 12.2, Math.PI / 2], [-12.2, 0, Math.PI], [12.2, 0, 0]];
const P2 = {
  tower: "cryo", look: "B", anim: "C",
  intro: "Final (round 6): every stage is picked and drawn as one model, nothing left to choose. Round 5: at the Path 3 mastery the central light is gold too, and Deep Cold shows all-new ideas (your notes): a white rime coat on the housing rim, two vapour stacks, or a frost collar round the fan. Round 4: your notes: with the Coolant Tank the ice spines now sit round the circular housing instead of floating, and the Coolant Tank has no external tank (the round housing is the Retrofit); at the Path 3 mastery only the fan blades are gold (the ring, hub, light and the mist stay ice-coloured). Round 3: every stage is picked and drawn as one model, nothing left to choose (Path 1: Cooling Coils, Cryo Pumps, Permafrost Drills, Cryo Reactors, Gold-Core Reactors; the gold-core reactors are smaller, your note). Use the build preview to check combinations. Round 2: your Path 2 (all C, Ice Crystals) and Path 3 (all A, Swept Fan) picks are drawn, Deep Cold is the Vent Row, and the Coolant Tank (spherical) makes the central box circular. Path 1 (Slowing) and the Compressor show all-new ideas (your notes): Path 1 rebuilds the corner stations as coils, snow guns and flasks, then pumps, dewars and exchangers, then pylons, domes and drills, then reactors, beacons and rime generators, then gold versions. Round 1: every step rebuilds a part, in all four places at once. Path 1 (Slowing) rebuilds the four corner stations (tanks, vaults or crystals that grow bigger and colder; the mastery adds gold). Path 2 (Power/Range) rebuilds the frost rim on the middle of each edge (jagged frost that grows into a gold-tipped crown) and widens the range. Path 3 (Speed) rebuilds the big fan in the middle and speeds the waves up; the mastery makes a constant gold field. Permafrost keeps a faint frost ring on enemies outside the range, Deep Freeze freezes them solid on every 4th wave, and frostbite shows ice shards falling on each hit enemy. The Retrofits add a coolant tank, a compressor or frost-white vents. Overlapping Retrofits are kept and stack (the carpet rule). Unpicked steps show option A.",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: coldAgent(B) }; },
  muzzleAt(B, m, kk, c) { return c; },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), mm = fx.mem || {}, puff = decay(t - (mm.wave ?? -9), 0.8), L1 = B.lv[0], L2 = B.lv[1], L3 = B.lv[2], S = (x, y) => add(c, [x * k, y * k]), R = B.r >= 0 ? B.key("r" + B.r) : null;
    const g1 = L1 >= 5, g2 = L2 >= 5, g3 = L3 >= 5, dt = Math.min(0.1, Math.max(0, t - (mm.fT ?? t))); mm.fT = t; mm.fan = (mm.fan || 0) + dt * (4 + 3 * L3 + 12 * puff) * (g3 ? 1.3 : 1);
    deck(c, k, col, t); const rnd0 = B.r === 0 && R === "C";                                           // the Coolant Tank (spherical option) makes the central box circular
    if (rnd0) { disc(c, 11.9 * k, OUTLINE); disc(c, 11.4 * k, METAL_L); disc(c, 10.2 * k, METAL_D); } else { plate(c, rectPts(11.5, 11.5), METAL_L, 0, k, 1.3); plate(c, rectPts(10.2, 10.2), METAL_D, 0, k, 0.9); }
    // ---- Path 2: the frost rim on the middle of each edge (rebuilt each step; the new design replaces the old) -------------------------------------------
    if (L2 > 0) { const key = B.key("p1s" + (L2 - 1)), len = [0, 2.4, 3.2, 4.2, 5.2, 6][L2], n = L2 + 2;
      EDGE.forEach(([x, y, a]) => { const p = S(x, y), d = fa(a), o = orth(d), tip = (f) => (g2 ? GOLD : ICE);
        if (key === "A") for (let j = -n; j <= n; j++) { const aj = a + j * 1.5 / 11.6, q = rnd0 ? add(c, mul(fa(aj), 11.2 * k)) : add(p, mul(o, j * 1.5 * k)), ra = rnd0 ? aj : a, dd = fa(ra), h = len * (1 - Math.abs(j) / (n + 2) * 0.45); fill(q, [[0, -0.7], [h, 0], [0, 0.7]], ICE, ra, k); if (g2) fill(add(q, mul(dd, h * 0.62 * k)), [[0, -0.3], [h * 0.38, 0], [0, 0.3]], GOLD, ra, k); }   // a row of ice spikes
        if (key === "B") for (let j = -n; j <= n; j++) { const aa = a + j * (0.45 / (n + 1)) * 2, q = add(p, mul(d, -1 * k)); fill(q, [[0, -0.5], [len + 1.2, 0], [0, 0.5]], j % 2 ? DEEP : ICE, aa, k); if (g2) disc(add(q, mul(fa(aa), (len + 1.2) * k)), 0.6 * k, GOLD); }   // a fan of spikes
        if (key === "C") for (let j = -Math.ceil(n / 2); j <= Math.ceil(n / 2); j++) { const aj = a + j * 2.3 / 11.6, q = rnd0 ? add(c, mul(fa(aj), 11.2 * k)) : add(p, mul(o, j * 2.3 * k)), ra = rnd0 ? aj : a, dd = fa(ra), h = len * (1 - Math.abs(j) * 0.18); fill(q, [[0, -1], [h * 0.5, -1.2], [h, 0], [h * 0.5, 1.2], [0, 1]], mix(ICE, DEEP, 0.2), ra, k); line(q, add(q, mul(dd, h * k)), [1, 1, 1, 0.7], 0.7 * k); if (g2) glowDot(add(q, mul(dd, h * k)), 0.5 * k, GOLD); }   // chunky ice crystals
      }); }
    // ---- Path 1: a station in each corner, rebuilt each step (round 2: all new designs) -----------------------------------------------------------------------
    if (L1 > 0) { const key = B.key("p0s" + (L1 - 1)), sz = [0, 2.4, 2.9, 3.3, 3.7, 4.1][L1], tr = g1 ? GOLD : ICE;
      CORN.forEach(([x, y], i) => station(S(x, y), L1, key, k, t, i, puff, sz, tr, g1, norm([x, y]))); }
    // ---- Path 3: the big fan in the middle, rebuilt each step (more blades, tighter housing, vents); gold and constant at the mastery -----------------------
    { const key = L3 > 0 ? B.key("p2s" + (L3 - 1)) : "A", nb = 5 + Math.min(L3, 4), fc = g3 ? GOLD : METAL_L;
      disc(c, 8.6 * k, OUTLINE); disc(c, 8 * k, METAL_D);
      if (key === "B" && L3 > 0) { ring(c, 8.2 * k, METAL_L, 1.6 * k); for (let j = 0; j < 8; j++) disc(add(c, mul(fa(j * TAU / 8 + 0.2), 8.2 * k)), 0.55 * k, STEEL); }   // a ducted shroud
      if (key === "C" && L3 > 0) for (let j = 0; j < 6 + L3; j++) { const a = j * TAU / (6 + L3); fill(add(c, mul(fa(a), 8.6 * k)), [[0, -1], [1.8, 0], [0, 1]], ICE, a, k); }   // a ring of vent nozzles
      for (let j = 0; j < nb; j++) { const a = mm.fan + j * TAU / nb;
        if (key === "A" && L3 > 0) { const pts = []; for (let q = 0; q <= 5; q++) pts.push(add(c, mul(fa(a + q * 0.13), (1.4 + q * 1.15) * k))); polyline(pts, OUTLINE, 3 * k); polyline(pts, fc, 1.8 * k); }   // swept turbine blades
        else fill(c, [[1.4, 0], [7, 1.8], [7, -1.4]], fc, a, k); }
      ring(c, 8 * k, METAL, 1.2 * k); orb(c, 1.9 * k, METAL); glowDot(c, (1 + puff) * k, g3 ? GOLD : col); }                  // the blades and the central light turn gold at the mastery
    // ---- The Retrofits: a coolant tank (left), a compressor (right) or frost-white vents (bottom) -------------------------------------------------------------
    if (B.r === 0) { const p = S(-15.4, 0);
      if (R === "A") { plate(p, rectPts(2.6, 5.4), METAL_L, 0, k, 1.2); for (let j = -1; j <= 1; j++) line(add(p, [-2.6 * k, j * 2.4 * k]), add(p, [2.6 * k, j * 2.4 * k]), STEEL, 0.9 * k); fill(add(p, [0, -5.4 * k]), [[-2.6, 0], [2.6, 0], [0, -1.6]], A(ICE, 0.9), 0, k); }                           // a frosted side tank
      if (R === "B") for (const y of [-3, 3]) { const q = add(p, [0, y * k]); disc(q, 2.5 * k, OUTLINE); disc(q, 2.1 * k, METAL_L); disc(q, 1.1 * k, A(ICE, 0.9)); ring(q, 1.7 * k, STEEL, 0.8 * k); }                                          // twin tanks
      /* option C: no external tank; the round housing is the whole Retrofit */ }                                         // a spherical tank
    if (B.r === 1) { const p = S(15.4, 0), hum = Math.sin(t * 40) * 0.2;
      if (R === "A") { disc(add(p, [hum * k, 0]), 3.6 * k, OUTLINE); plate(add(p, [hum * k, 0]), rectPts(3.2, 4.4), METAL_L, 0, k, 1.2); for (let j = 0; j < 3; j++) ring(add(p, [hum * k, (-2.6 + j * 2.6) * k]), 2.6 * k, STEEL, 0.9 * k); disc(add(p, [(3.2 + hum) * k, 0]), 1 * k, METAL_D); glowDot(add(p, [hum * k, 0]), 0.45 * k, col); }                                          // a humming compressor drum with rings
      if (R === "B") { const a = S(14.2, -3.2), b = S(14.2, 3.2), ph = t * 5; disc(a, 2 * k, OUTLINE); disc(a, 1.6 * k, METAL_L); disc(b, 2.6 * k, OUTLINE); disc(b, 2.2 * k, METAL_L); bar(add(a, [0, -2 * k]), add(b, [0, -2.6 * k]), 0.8 * k, [0.1, 0.1, 0.12, 1]);
        for (const [q, rr] of [[a, 1.6], [b, 2.2]]) for (let j = 0; j < 3; j++) line(q, add(q, mul(fa(ph + j * TAU / 3), rr * 0.9 * k)), STEEL, 0.8 * k); }                                                                             // a belt-driven compressor: two pulleys and a belt
      if (R === "C") { const q = S(14.6, 0); fill(q, [[-3, -2.8], [1.5, -3.6], [4.2, -1], [4.4, 1.4], [1.8, 3.6], [-3, 3]], METAL_L, 0, k); disc(q, 2.3 * k, OUTLINE); disc(q, 2 * k, METAL_D); for (let j = 0; j < 7; j++) fill(q, [[0.3, 0], [2, 0.7], [1.8, -0.5]], ICE, t * 14 + j * TAU / 7, k); bar(add(q, [3.8 * k, 0]), add(q, [6 * k, 0]), 1.2 * k, STEEL); } }  // a radial compressor: an impeller in a snail casing
    if (B.r === 2) { const W = [0.94, 0.98, 1, 1];
      if (R === "A") { if (rnd0) ring(c, 11.1 * k, A(W, 0.9), 2.2 * k); else outline(c, rectPts(11.1, 11.1), A(W, 0.9), 2.2 * k, 0, k);
        for (let q = 0; q < 10; q++) { const a = q * TAU / 10 + 0.3, r0 = rnd0 ? 10.4 : 10.8; disc(add(c, mul(fa(a), r0 * k)), (0.8 + 0.7 * rnd(q + 3)) * k, A(W, 0.92)); } }                              // a white rime coat on the housing rim
      if (R === "B") for (const sx of [-1, 1]) { const p = S(sx * 7, 15.2); disc(p, 1.9 * k, OUTLINE); disc(p, 1.5 * k, METAL_L); disc(p, 1 * k, W);
        for (let q = 0; q < 3; q++) { const u = fmod(t * 0.5 + q / 3 + (sx > 0 ? 0.15 : 0), 1); disc(add(p, [sx * u * 2 * k, -u * 7 * k]), (0.8 + u * 1.5) * k, A(W, 0.55 * (1 - u))); } }                     // two vapour stacks
      if (R === "C") { ring(c, 8.5 * k, A(W, 0.95), 2.4 * k); for (let q = 0; q < 12; q++) { const a = q * TAU / 12; fill(add(c, mul(fa(a), 8.5 * k)), [[0, -0.7], [-2.2, 0], [0, 0.7]], W, a, k); } } }       // a frost collar round the fan
  },
  paths: [], retrofits: [],
};

// ---- Option tables ---------------------------------------------------------------------------------------------------------------------------------------
const T = (a, b, c) => [["A", ...a], ["B", ...b], ["C", ...c]].map(([key, name, desc]) => ({ key, name, desc }));
P2.paths = [
  { name: "Slowing", theme: "the corners: four stations, each rebuilt from scratch at every step; the mastery adds gold", steps: [
    { name: "Colder Gas", cost: 120, effect: "Slow 28%", options: T(["Cooling Coils", "Each corner gets a spinning cooling coil on a dark base."], ["Snow Guns", "Each corner gets a short snow gun that puffs frost outward."], ["Frost Flasks", "Each corner gets a conical flask of blue coolant."]) },
    { name: "Sub-Zero Gas", cost: 210, effect: "Slow 35%", options: T(["Cryo Pumps", "The corner stations are replaced by cryo pumps with a working piston."], ["Nitrogen Dewars", "The corner stations are replaced by tall liquid-nitrogen dewars that vent a puff."], ["Heat Exchangers", "The corner stations are replaced by finned heat exchangers with a coolant pipe."]) },
    { name: "Permafrost", cost: 1705, effect: "Chilled enemies keep a permanent 10% slow (primary)", options: T(["Ice-Core Pylons", "The corner stations are replaced by pylons with a glowing ice core and a ring of ice spikes; chilled enemies keep a faint frost ring outside the range."], ["Frozen Domes", "The corner stations are replaced by cracked frozen domes; chilled enemies keep a faint frost ring outside the range."], ["Permafrost Drills", "The corner stations are replaced by spinning drill bits in an ice collar; chilled enemies keep a faint frost ring outside the range."]) },
    { name: "Deep Chill", cost: 2905, effect: "Slow 45%; permanent 15%", options: T(["Cryo Reactors", "The corner stations are replaced by hexagonal cryo reactors with a turning ring."], ["Cold Beacons", "The corner stations are replaced by cold beacons that pulse rings of cold."], ["Rime Generators", "The corner stations are replaced by stacked, turning rime generators."]) },
    { name: "Deep Freeze", cost: 8460, effect: "Slow 50%; permanent 20%; every 4th wave freezes enemies solid for 1 s (mastery)", options: T(["Gold-Core Reactors", "The corner reactors get a gold core and a gold ring; every 4th wave freezes enemies in an ice block."], ["Gold-Ringed Beacons", "The corner beacons get a gold ring and gold pulses; every 4th wave freezes enemies in an ice block."], ["Gold-Edged Obelisks", "The corner stations are replaced by gold-edged frozen obelisks; every 4th wave freezes enemies in an ice block."]) },
  ] },
  { name: "Power / Range", theme: "the edges: a frost rim rebuilt at every step, from rime teeth to a gold-tipped crown", steps: [
    { name: "Frostbite", cost: 105, effect: "5 damage per wave; 120 px radius", options: T(["Rime Teeth", "A row of short ice spikes on the middle of each edge; hit enemies shed an ice shard."], ["Frost Fans", "A short fan of ice spikes on each edge; hit enemies shed an ice shard."], ["Ice Nubs", "Short chunky ice crystals on each edge; hit enemies shed an ice shard."]) },
    { name: "Hard Frost", cost: 230, effect: "10 damage; 130 px", options: T(["Spike Rows", "The edge teeth are replaced by a longer row of spikes."], ["Spike Fans", "The edge fans are replaced by longer fans."], ["Ice Crystals", "The edge nubs are replaced by taller crystals."]) },
    { name: "Ice Storm", cost: 790, effect: "18 damage; 145 px (primary)", options: T(["Spike Banks", "The edge rows are replaced by tall banks of jagged spikes."], ["Spike Sprays", "The edge fans are replaced by tall, wide sprays of spikes."], ["Crystal Banks", "The edge crystals are replaced by tall banks of crystals."]) },
    { name: "Biting Cold", cost: 695, effect: "26 damage", options: T(["Barbed Banks", "The spike banks are replaced by longer, denser spikes."], ["Barbed Sprays", "The spike sprays are replaced by longer, denser sprays."], ["Crystal Crowns", "The crystal banks are replaced by longer, denser crowns."]) },
    { name: "Blizzard", cost: 4870, effect: "36 damage; 165 px (mastery)", options: T(["Gold-Tipped Spikes", "The longest spike rows are tipped with gold."], ["Gold-Tipped Sprays", "The longest spike sprays are tipped with gold."], ["Gold-Studded Crowns", "The longest crystal crowns are studded with gold."]) },
  ] },
  { name: "Speed", theme: "the middle: the big fan is rebuilt at every step, faster and tighter; the mastery is a constant gold field", steps: [
    { name: "Faster Vents", cost: 25, effect: "A wave every 1.75 s; the gas spreads faster", options: T(["Swept Fan", "The fan is rebuilt with six swept turbine blades."], ["Ducted Fan", "The fan is rebuilt with six blades inside a bolted shroud ring."], ["Nozzle Fan", "The fan is rebuilt with six blades and a ring of vent nozzles."]) },
    { name: "Pressurised Gas", cost: 65, effect: "Every 1.5 s", options: T(["Swept Fan", "The fan is rebuilt with seven swept blades."], ["Ducted Fan", "The fan is rebuilt with seven blades in the shroud."], ["Nozzle Fan", "The fan is rebuilt with seven blades and more nozzles."]) },
    { name: "Rapid Vents", cost: 185, effect: "Every 1.2 s (primary)", options: T(["Swept Fan", "The fan is rebuilt with eight swept blades."], ["Ducted Fan", "The fan is rebuilt with eight blades in the shroud."], ["Nozzle Fan", "The fan is rebuilt with eight blades and more nozzles."]) },
    { name: "Turbo Vents", cost: 290, effect: "Every second", options: T(["Swept Fan", "The fan is rebuilt with nine swept blades."], ["Ducted Fan", "The fan is rebuilt with nine blades in the shroud."], ["Nozzle Fan", "The fan is rebuilt with nine blades and more nozzles."]) },
    { name: "Cold Front", cost: 1575, effect: "A constant cold field: everything inside stays slowed (mastery)", options: T(["Gold Turbine", "The fan turns gold and the mist becomes a steady gold-white field; the waves no longer pulse."], ["Gold Ducted Fan", "The fan and its shroud turn gold and the mist becomes a steady gold-white field."], ["Gold Nozzle Fan", "The fan and its nozzles turn gold and the mist becomes a steady gold-white field."]) },
  ] },
];
P2.retrofits = [
  { name: "Coolant Tank", cost: 80, effect: "The slow lasts 2.2 s (stacks with the permanent chill)", options: T(["Side Tank", "A frosted tank with bands on the left side."], ["Twin Tanks", "Two small frosted tanks on the left side."], ["Round Housing", "The central box becomes a circular housing, with the ice spines round its rim; no external tank."]) },
  { name: "Compressor", cost: 35, effect: "A wave every 1.7 s (stacks with the Speed path)", options: T(["Compressor Drum", "A humming compressor drum with rings on the right side."], ["Belt Drive", "Two belt-driven pulleys on the right side."], ["Radial Compressor", "A spinning impeller in a snail casing on the right side."]) },
  { name: "Deep Cold", cost: 75, effect: "Slow +5% (stacks with the Slowing path)", options: T(["Rime Coat", "A white rime coat grows on the housing's rim."], ["Vapour Stacks", "Two white vapour stacks on the bottom edge breathe cold vapour."], ["Frost Collar", "A frost-white collar with inward fins rings the fan."]) },
];

// ---- Round 2 (owner's picks, 2026-10-19). Path 1 and the Compressor are unpicked: they show their options again.
P2.picks = { p0s0: "A", p0s1: "A", p0s2: "C", p0s3: "A", p0s4: "A", p1s0: "C", p1s1: "C", p1s2: "C", p1s3: "C", p1s4: "C", p2s0: "A", p2s1: "A", p2s2: "A", p2s3: "A", p2s4: "A", r0: "C", r1: "C", r2: "C" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { const pk = P2.picks["p" + pi + "s" + k]; if (pk) st.options = st.options.filter((o) => o.key === pk); }));
P2.retrofits.forEach((rf, ri) => { const pk = P2.picks["r" + ri]; if (pk) rf.options = rf.options.filter((o) => o.key === pk); });
