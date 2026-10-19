// ---- Tower art second pass: Cryo Tower (tower 15), round 1 ------------------------------------------------------
// Base: look B Compressor Block, animation C Creeping Mist. One parametric model built on the lessons so far: every step REBUILDS a part
// (the new design replaces the old one, it does not pile extras on), the options swap that part's style, masteries turn gold, and the agent
// runs the real rules (wave rate, range, slow strength, permanent chill, the 4th-wave freeze, frostbite) so the preview shows what a step does.
// Layout (game px, top-down): a square compressor housing with a big fan in the middle (path 3, Speed: the fan and its vents), a station in each
// corner (path 1, Slowing: coolant tanks, vaults or crystals that grow colder) and a frost rim on the middle of each edge (path 2, Power/Range:
// jagged frost). The Retrofits add a coolant tank on the left, a compressor on the right and frost-white vents at the bottom.
// Overlaps kept and stacking (the carpet rule): Compressor's wave every 1.7 s with the path-3 wave rate, Deep Cold's +5% slow with the path-1 slows,
// Coolant Tank's longer slow with the permanent chill.
const PAGE = { title: "Cryo Tower: paths and Retrofits (second pass)", store: "bl-tower-art-p2-cryo-r1" };
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
  const L1 = B.lv[0], L2 = B.lv[1], L3 = B.lv[2], constant = L3 >= 5, per = constant ? 1.2 : periodOf(B), c = info.c, gold = L1 >= 5 || L2 >= 5 || constant;
  if (t - m.wave >= per) { m.wave = t; m.n++; }
  const R = s * 2.3 * radiusPx(B) / 110, travel = constant ? 1 : 1.8, raw = (t - m.wave) / travel, u = Math.min(1, raw), a = 0.55 + 0.45 * (1 - Math.min(1, raw / 2)), mist = constant ? GOLD : ICE;
  ring(c, R, A(mist, 0.14), 1); for (let i = 0; i < 24; i += 2) line(add(c, mul(fa(i * TAU / 24 + t * 0.04), R)), add(c, mul(fa((i + 1) * TAU / 24 + t * 0.04), R)), A(mist, 0.28), 1.2);
  if (constant) { disc(c, R, A(GOLD, 0.05)); disc(c, R, A(ICE, 0.05)); }
  for (let i = 0; i < 22; i++) { const ang = rnd(i) * TAU + t * 0.1 * (i % 2 ? 1 : -1), rr = R * Math.min(constant ? 1 : u, rnd(i + 9)), p = add(c, mul(fa(ang), rr)); disc(p, s * (0.12 + 0.04 * Math.sin(t * 1.5 + i)), A(mist, 0.16 * a)); }
  const front = R * u; if (!constant && raw < 1.2) ring(c, front, A(ICE, 0.35 * (1 - raw / 1.2)), 2);
  for (const e of info.ens) { const d = dist(e.p, c), reached = constant ? d < R : raw <= 1.2 && d < front;
    if (reached) { if (!((m.cold[e.i] || 0) > t + 0.3) && L2 > 0) m.hit[e.i] = t; m.cold[e.i] = t + chillFor(B); if (L1 >= 3) m.perm[e.i] = true; if (L1 >= 5 && m.n % 4 === 0 && !(m.fz[e.i] > t)) m.fz[e.i] = t + 1; }
    const left = (m.cold[e.i] || 0) - t;
    if (m.fz[e.i] > t) iceBlock(e.p, s, Math.min(1, (m.fz[e.i] - t) * 3), gold);
    else if (left > 0) chillMark(e.p, s, Math.min(1, left * 1.5) * (0.5 + 0.5 * slowOf(B) / 55), L1 >= 5);
    else if (m.perm[e.i]) { const r = Math.max(4, Math.min(11, s * 0.12)); ring(e.p, r + 2, A(ICE, 0.35), 1); }              // the permanent chill: a faint frost ring outside the range
    if (L2 > 0 && m.hit[e.i] !== undefined) frostShards(e.p, s, m.hit[e.i], t, Math.min(4, 1 + L2)); } }; }

// ---- The model ---------------------------------------------------------------------------------------------------------------------------------------
const CORN = [[-10, -10], [10, -10], [10, 10], [-10, 10]], EDGE = [[0, -12.2, -Math.PI / 2], [0, 12.2, Math.PI / 2], [-12.2, 0, Math.PI], [12.2, 0, 0]];
const P2 = {
  tower: "cryo", look: "B", anim: "C",
  intro: "Round 1: every step rebuilds a part, in all four places at once. Path 1 (Slowing) rebuilds the four corner stations (tanks, vaults or crystals that grow bigger and colder; the mastery adds gold). Path 2 (Power/Range) rebuilds the frost rim on the middle of each edge (jagged frost that grows into a gold-tipped crown) and widens the range. Path 3 (Speed) rebuilds the big fan in the middle and speeds the waves up; the mastery makes a constant gold field. Permafrost keeps a faint frost ring on enemies outside the range, Deep Freeze freezes them solid on every 4th wave, and frostbite shows ice shards falling on each hit enemy. The Retrofits add a coolant tank, a compressor or frost-white vents. Overlapping Retrofits are kept and stack (the carpet rule). Unpicked steps show option A.",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: coldAgent(B) }; },
  muzzleAt(B, m, kk, c) { return c; },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), mm = fx.mem || {}, puff = decay(t - (mm.wave ?? -9), 0.8), L1 = B.lv[0], L2 = B.lv[1], L3 = B.lv[2], S = (x, y) => add(c, [x * k, y * k]), R = B.r >= 0 ? B.key("r" + B.r) : null;
    const g1 = L1 >= 5, g2 = L2 >= 5, g3 = L3 >= 5, dt = Math.min(0.1, Math.max(0, t - (mm.fT ?? t))); mm.fT = t; mm.fan = (mm.fan || 0) + dt * (4 + 3 * L3 + 12 * puff) * (g3 ? 1.3 : 1);
    deck(c, k, col, t); plate(c, rectPts(11.5, 11.5), METAL_L, 0, k, 1.3); plate(c, rectPts(10.2, 10.2), METAL_D, 0, k, 0.9);
    // ---- Path 2: the frost rim on the middle of each edge (rebuilt each step; the new design replaces the old) -------------------------------------------
    if (L2 > 0) { const key = B.key("p1s" + (L2 - 1)), len = [0, 2.4, 3.2, 4.2, 5.2, 6][L2], n = L2 + 2;
      EDGE.forEach(([x, y, a]) => { const p = S(x, y), d = fa(a), o = orth(d), tip = (f) => (g2 ? GOLD : ICE);
        if (key === "A") for (let j = -n; j <= n; j++) { const q = add(p, mul(o, j * 1.5 * k)), h = len * (1 - Math.abs(j) / (n + 2) * 0.45); fill(q, [[0, -0.7], [h, 0], [0, 0.7]], ICE, a, k); if (g2) fill(add(q, mul(d, h * 0.62 * k)), [[0, -0.3], [h * 0.38, 0], [0, 0.3]], GOLD, a, k); }   // a row of ice spikes
        if (key === "B") for (let j = -n; j <= n; j++) { const aa = a + j * (0.45 / (n + 1)) * 2, q = add(p, mul(d, -1 * k)); fill(q, [[0, -0.5], [len + 1.2, 0], [0, 0.5]], j % 2 ? DEEP : ICE, aa, k); if (g2) disc(add(q, mul(fa(aa), (len + 1.2) * k)), 0.6 * k, GOLD); }   // a fan of spikes
        if (key === "C") for (let j = -Math.ceil(n / 2); j <= Math.ceil(n / 2); j++) { const q = add(p, mul(o, j * 2.3 * k)), h = len * (1 - Math.abs(j) * 0.18); fill(q, [[0, -1], [h * 0.5, -1.2], [h, 0], [h * 0.5, 1.2], [0, 1]], mix(ICE, DEEP, 0.2), a, k); line(q, add(q, mul(d, h * k)), [1, 1, 1, 0.7], 0.7 * k); if (g2) glowDot(add(q, mul(d, h * k)), 0.5 * k, GOLD); }   // chunky ice crystals
      }); }
    // ---- Path 1: a station in each corner, rebuilt each step: tank, vault or crystals, bigger and colder ---------------------------------------------------
    if (L1 > 0) { const key = B.key("p0s" + (L1 - 1)), sz = [0, 2.4, 2.9, 3.3, 3.7, 4.1][L1], tr = g1 ? GOLD : ICE;
      CORN.forEach(([x, y], i) => { const p = S(x, y);
        if (key === "A") { disc(p, sz * k + 1.1 * k, OUTLINE); disc(p, sz * k, METAL_L); for (let j = 1; j <= Math.min(L1, 3); j++) ring(p, sz * (0.9 - j * 0.2) * k, g1 ? GOLD : STEEL, 0.8 * k); disc(p, sz * 0.5 * k, ICE); if (L1 >= 3) fill(p, [[0, -sz * 1.5], [sz * 0.5, 0], [0, sz * 0.5], [-sz * 0.5, 0]], A([1, 1, 1, 1], 0.85), 0, k); glowDot(p, 0.4 * k, tr); }   // a banded tank (a spire from Permafrost)
        if (key === "B") { plate(p, rectPts(sz, sz), METAL_L, 0, k, 1.2); plate(p, rectPts(sz * 0.74, sz * 0.74), METAL_D, 0, k, 0.9); for (let j = 0; j < 3; j++) { const a = j * Math.PI / 3; line(add(p, mul(fa(a), sz * 0.6 * k)), add(p, mul(fa(a + Math.PI), sz * 0.6 * k)), tr, 0.9 * k); }
          if (L1 >= 4) outline(p, rectPts(sz * 1.05, sz * 1.05), tr, 1 * k); fill(add(p, [-sz * k * 0.62, -sz * k * 0.62]), [[0, 0], [sz * 0.6, 0], [0, sz * 0.6]], A([1, 1, 1, 1], 0.8), 0, k); }   // a frosted vault
        if (key === "C") { const cn = Math.min(1 + L1, 5); for (let j = 0; j < cn; j++) { const a = j * TAU / cn + i, rr = j === 0 ? 0 : sz * 0.55, q = add(p, mul(fa(a), rr * k)), h = sz * (j === 0 ? 1.15 : 0.7);
            fill(q, [[0, -h], [h * 0.45, -h * 0.2], [h * 0.4, h * 0.6], [0, h * 0.9], [-h * 0.4, h * 0.6], [-h * 0.45, -h * 0.2]], j === 0 ? mix(ICE, tr, g1 ? 0.7 : 0.15) : DEEP, 0, k); line(add(q, [0, -h * k * 0.9]), add(q, [0, h * k * 0.7]), [1, 1, 1, 0.55], 0.7 * k); } glowDot(p, 0.4 * k, tr); }   // a crystal cluster
        if (g1) ring(p, sz * k + 1.4 * k, A(GOLD, 0.7), 0.9 * k); }); }
    // ---- Path 3: the big fan in the middle, rebuilt each step (more blades, tighter housing, vents); gold and constant at the mastery -----------------------
    { const key = L3 > 0 ? B.key("p2s" + (L3 - 1)) : "A", nb = 5 + Math.min(L3, 4), fc = g3 ? GOLD : METAL_L;
      disc(c, 8.6 * k, OUTLINE); disc(c, 8 * k, METAL_D);
      if (key === "B" && L3 > 0) { ring(c, 8.2 * k, g3 ? GOLD : METAL_L, 1.6 * k); for (let j = 0; j < 8; j++) disc(add(c, mul(fa(j * TAU / 8 + 0.2), 8.2 * k)), 0.55 * k, g3 ? GOLD : STEEL); }   // a ducted shroud
      if (key === "C" && L3 > 0) for (let j = 0; j < 6 + L3; j++) { const a = j * TAU / (6 + L3); fill(add(c, mul(fa(a), 8.6 * k)), [[0, -1], [1.8, 0], [0, 1]], g3 ? GOLD : ICE, a, k); }   // a ring of vent nozzles
      for (let j = 0; j < nb; j++) { const a = mm.fan + j * TAU / nb;
        if (key === "A" && L3 > 0) { const pts = []; for (let q = 0; q <= 5; q++) pts.push(add(c, mul(fa(a + q * 0.13), (1.4 + q * 1.15) * k))); polyline(pts, OUTLINE, 3 * k); polyline(pts, fc, 1.8 * k); }   // swept turbine blades
        else fill(c, [[1.4, 0], [7, 1.8], [7, -1.4]], fc, a, k); }
      ring(c, 8 * k, g3 ? GOLD : METAL, 1.2 * k); orb(c, 1.9 * k, g3 ? GOLD : METAL); glowDot(c, (1 + puff + (g3 ? 0.5 : 0)) * k, g3 ? GOLD : col); }
    // ---- The Retrofits: a coolant tank (left), a compressor (right) or frost-white vents (bottom) -------------------------------------------------------------
    if (B.r === 0) { const p = S(-15.4, 0);
      if (R === "A") { plate(p, rectPts(2.6, 5.4), METAL_L, 0, k, 1.2); for (let j = -1; j <= 1; j++) line(add(p, [-2.6 * k, j * 2.4 * k]), add(p, [2.6 * k, j * 2.4 * k]), STEEL, 0.9 * k); fill(add(p, [0, -5.4 * k]), [[-2.6, 0], [2.6, 0], [0, -1.6]], A(ICE, 0.9), 0, k); }                           // a frosted side tank
      if (R === "B") for (const y of [-3, 3]) { const q = add(p, [0, y * k]); disc(q, 2.5 * k, OUTLINE); disc(q, 2.1 * k, METAL_L); disc(q, 1.1 * k, A(ICE, 0.9)); ring(q, 1.7 * k, STEEL, 0.8 * k); }                                          // twin tanks
      if (R === "C") { disc(p, 4 * k, OUTLINE); orb(p, 3.6 * k, mix(METAL_L, ICE, 0.3)); ring(p, 3.6 * k, A(ICE, 0.7), 1 * k); line(add(p, [-3.6 * k, 0]), add(p, [3.6 * k, 0]), STEEL, 0.9 * k); } }                                         // a spherical tank
    if (B.r === 1) { const p = S(15.4, 0), hum = Math.sin(t * 40) * 0.25;
      if (R === "A") { plate(add(p, [hum * k, 0]), rectPts(2.8, 4), METAL_L, 0, k, 1.2); for (let j = 0; j < 3; j++) line(add(p, [(-2 + hum) * k, (-2 + j * 2) * k]), add(p, [(2 + hum) * k, (-2 + j * 2) * k]), STEEL, 0.9 * k); glowDot(add(p, [1.8 * k, 3 * k]), 0.35 * k, col); }                       // a humming compressor box
      if (R === "B") for (let j = 0; j < 2; j++) { const ph = Math.sin(t * 18 + j * Math.PI) * 1.2; bar(add(p, [(-2.6 + ph) * k, (-2.4 + j * 4.8) * k]), add(p, [(2.4 + ph) * k, (-2.4 + j * 4.8) * k]), 1.6 * k, METAL_L); disc(add(p, [(2.6 + ph) * k, (-2.4 + j * 4.8) * k]), 1.2 * k, STEEL); }   // two pistons
      if (R === "C") { disc(p, 3.8 * k, OUTLINE); disc(p, 3.3 * k, METAL_D); for (let j = 0; j < 14; j++) { const a = t * 6 + j * 0.45, rr = (0.6 + j * 0.2) * k; disc(add(p, mul(fa(a), rr)), 0.45 * k, METAL_L); } } }                                        // a scroll compressor
    if (B.r === 2) { const W = [0.92, 0.97, 1, 1];
      if (R === "A") for (let j = -2; j <= 2; j++) { const p = S(j * 3.4, 15); plate(p, rectPts(1.4, 1.2), W, 0, k, 0.9); line(add(p, [-1 * k, 0]), add(p, [1 * k, 0]), [0.3, 0.45, 0.55, 1], 0.7 * k); }       // a row of white vents
      if (R === "B") for (let j = -1; j <= 1; j++) { const p = S(j * 5, 15); disc(p, 2 * k, OUTLINE); disc(p, 1.7 * k, W); disc(p, 0.8 * k, [0.3, 0.45, 0.55, 1]); }                                                                              // white vent domes
      if (R === "C") for (let j = 0; j < 3; j++) { const p = S((j - 1) * 5.4, 15); for (let q = 0; q < 4; q++) line(add(p, [-1.8 * k, (q - 1.5) * 0.9 * k]), add(p, [1.8 * k, (q - 1.5) * 0.9 * k]), W, 0.8 * k); } }                      // white louvres
  },
  paths: [], retrofits: [],
};

// ---- Option tables ---------------------------------------------------------------------------------------------------------------------------------------
const T = (a, b, c) => [["A", ...a], ["B", ...b], ["C", ...c]].map(([key, name, desc]) => ({ key, name, desc }));
P2.paths = [
  { name: "Slowing", theme: "the corners: four stations rebuilt at every step, bigger and colder; the mastery adds gold", steps: [
    { name: "Colder Gas", cost: 120, effect: "Slow 28%", options: T(["Coolant Tanks", "Each corner gets a small banded coolant tank."], ["Frost Vaults", "Each corner gets a small frosted vault."], ["Ice Crystals", "Each corner gets an ice crystal."]) },
    { name: "Sub-Zero Gas", cost: 210, effect: "Slow 35%", options: T(["Bigger Tanks", "The corner tanks are replaced by bigger, banded tanks."], ["Bigger Vaults", "The corner vaults are replaced by bigger vaults with a cooling cross."], ["Crystal Clusters", "The corner crystals are replaced by crystal clusters."]) },
    { name: "Permafrost", cost: 1705, effect: "Chilled enemies keep a permanent 10% slow (primary)", options: T(["Spire Tanks", "The corner tanks are replaced by tanks topped with a tall ice spire; chilled enemies keep a faint frost ring outside the range."], ["Permafrost Vaults", "The corner vaults are replaced by larger frost-rimed vaults; chilled enemies keep a faint frost ring outside the range."], ["Permafrost Clusters", "The corner clusters are replaced by larger clusters with a glowing core; chilled enemies keep a faint frost ring outside the range."]) },
    { name: "Deep Chill", cost: 2905, effect: "Slow 45%; permanent 15%", options: T(["Cryo Silos", "The corner tanks are replaced by tall cryo silos with a cooling spire."], ["Cryo Vaults", "The corner vaults are replaced by framed cryo vaults."], ["Glacier Clusters", "The corner clusters are replaced by tall glacier clusters."]) },
    { name: "Deep Freeze", cost: 8460, effect: "Slow 50%; permanent 20%; every 4th wave freezes enemies solid for 1 s (mastery)", options: T(["Gold-Banded Silos", "The corner silos get gold bands and a gold ring; every 4th wave freezes enemies in an ice block."], ["Gold-Framed Vaults", "The corner vaults get a gold frame and a gold ring; every 4th wave freezes enemies in an ice block."], ["Gold-Cored Glaciers", "The corner glaciers get gold cores and a gold ring; every 4th wave freezes enemies in an ice block."]) },
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
  { name: "Coolant Tank", cost: 80, effect: "The slow lasts 2.2 s (stacks with the permanent chill)", options: T(["Side Tank", "A frosted tank with bands on the left side."], ["Twin Tanks", "Two small frosted tanks on the left side."], ["Spherical Tank", "A frosted spherical tank on the left side."]) },
  { name: "Compressor", cost: 35, effect: "A wave every 1.7 s (stacks with the Speed path)", options: T(["Compressor Box", "A humming compressor box on the right side."], ["Piston Unit", "A pair of working pistons on the right side."], ["Scroll Compressor", "A spinning scroll compressor on the right side."]) },
  { name: "Deep Cold", cost: 75, effect: "Slow +5% (stacks with the Slowing path)", options: T(["Vent Row", "A row of frost-white vents along the bottom edge."], ["Vent Domes", "Three frost-white vent domes on the bottom edge."], ["Frost Louvres", "Three frost-white louvre vents on the bottom edge."]) },
];
