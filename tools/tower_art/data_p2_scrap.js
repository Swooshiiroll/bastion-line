// ---- Tower art second pass: Scrapyard (tower 17), round 3, on the confirmed Production Line base (owner, 2026-10-19) ---------------------------------------------
// Round 2 (the owner's picks and notes): Hydraulic Shear is renamed Sorting Line (new options, on the main belt); the Retrofits are renamed Hammer Mill (was Second
// Crusher), Faster Loading (was Bigger Yard: a second conveyor and crane feed the furnace) and Surplus (was Weighbridge: two extra crates). Effects unchanged.
// Round 3 (the owner's notes): the Sorting Line becomes a Laser Cutter (new options, on the main belt); Surplus's two crates stand left of the crate stack.
// Base: look B Production Line, animation B Melt and Pour (tools/tower_art/data_scrap_parts.js). The tower is three parts, and each path rebuilds one of them
// around the machine its step names (the owner's names, 2026-10-19):
//  - Path 1, Passive Income: the furnace stack (Firebrick Lining, Forced Bellows, Blast Furnace, Arc Furnace, Gold Foundry).
//  - Path 2, Kill Income: the junkyard (Tow Hook, Magnet Crane, Laser Cutter, Car Crusher, Breaker's Yard); the orange kill ring widens.
//  - Path 3, Discounts: the warehouse (Parts Shelves, Pallet Racks, Forklift Bay, Loading Dock, Parts Exchange); the blue discount ring widens.
// Every step rebuilds its part big and visibly (the owner: the old upgrades were too subtle); earlier picks carry as details; masteries are gold.
// Overlaps kept and stacking (the carpet rule): the Hammer Mill's +30 with the Passive Income path, Faster Loading's +30 px with both field radii.
const PAGE = { title: "Scrapyard (production line): paths and Retrofits (second pass)", store: "bl-tower-art-p2-scrap-pl5" };
const GOLD = [1, 0.78, 0.3, 1], RUST = [0.45, 0.3, 0.2, 1], BRICK = [0.55, 0.27, 0.2, 1], MOLTEN = [1, 0.55, 0.15, 1], HOTM = [1, 0.85, 0.45, 1], STEEL = [0.42, 0.45, 0.5, 1];
const WOOD = [0.6, 0.43, 0.24, 1], DIRT = [0.27, 0.23, 0.19, 1], CONC = [0.29, 0.29, 0.3, 1], ROOF = [0.44, 0.47, 0.5, 1], DOOR = [0.8, 0.58, 0.2, 1], CRANE = [0.92, 0.7, 0.2, 1];
const LASER = [1, 0.22, 0.18, 1], KILL = [1, 0.5, 0.2, 1], DISCC = [0.45, 0.82, 0.95, 1], ARCC = [0.72, 0.88, 1, 1], CERAM = [0.8, 0.72, 0.6, 1], LOADS = [[0.35, 0.55, 0.8, 1], [0.4, 0.65, 0.4, 1], [0.75, 0.45, 0.3, 1], [0.85, 0.7, 0.3, 1]];
const rnd = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const INCOME = [100, 130, 165, 220, 270, 320], KILLPX = [0, 140, 150, 170, 190, 210], DISCPX = [0, 140, 150, 160, 175, 190], KBONUS = [0, 0.15, 0.25, 0.35, 0.45, 0.6], DOFF = ["", "-5%", "-10%", "-15%", "-20%", "-25%"];
const incomeOf = (B) => INCOME[B.lv[0]] + (B.r === 0 ? 30 : 0);
const killR = (B) => KILLPX[B.lv[1]] + (B.r === 1 && B.lv[1] > 0 ? 30 : 0), discR = (B) => DISCPX[B.lv[2]] + (B.r === 1 && B.lv[2] > 0 ? 30 : 0);
const gl = (col, g, u) => (g ? mix(col, GOLD, u ?? 0.75) : col);
const pick = (B, path, L) => (i) => (L > i ? B.key("p" + path + "s" + i) : null);   // the option picked at step i of a path, or null if not bought
const STACKR = [14, 14.5, 15, 16, 16.5, 17];

// ---- Shared drawing (copies of the base's helpers; a pass-2 file can't see the base's scope) ------------------------------------------------------------------------
function txt(p, str, col, px) { X.save(); X.font = "bold " + Math.round(px) + "px sans-serif"; X.textAlign = "center"; X.fillStyle = css(OUTLINE); X.fillText(str, p[0] + 1, p[1] + 1); X.fillStyle = css(col); X.fillText(str, p[0], p[1]); X.restore(); }
function scrapPile(p, r, k, seed, g) { const pts = [], body = gl(mix(RUST, METAL, 0.4), g, 0.55); for (let i = 0; i < 9; i++) { const a = i * TAU / 9; pts.push([Math.cos(a) * r * (0.65 + 0.35 * rnd(seed + i)), Math.sin(a) * r * (0.65 + 0.35 * rnd(seed + i + 20))]); }
  ellipse(add(p, [k * 1.5, k * 2.5]), r * k, r * k * 0.5, [0, 0, 0, 0.3]); solid(p, pts, body, 0, k, 1);
  for (let i = 0; i < 5; i++) { const q = add(p, [(rnd(seed + i * 3) - 0.5) * r * k * 1.1, (rnd(seed + i * 5) - 0.5) * r * k * 0.9]); line(q, add(q, mul(fa(rnd(seed + i) * TAU), r * k * 0.35)), g ? (i % 2 ? HOTM : GOLD) : i % 2 ? METAL_L : RUST, 1.4 * k); } }
function wreck(p, ang, k, sq = 1) { const kk = k * sq, o = (x, y) => add(p, rot([x * kk, y * kk], ang)), body = dk(mix(RUST, METAL, 0.3), Math.min(0.5, (sq - 1) * 3));
  for (const sg of [-1, 1]) plate(o(0, sg * 7.4), rectPts(12, 2), [0.13, 0.12, 0.12, 1], ang, kk, 1);
  plate(p, rectPts(11, 6), body, ang, kk, 1.3); disc(o(-2, 0), 3.8 * kk, OUTLINE); disc(o(-2, 0), 3.1 * kk, [0.05, 0.05, 0.05, 1]); ring(o(-2, 0), 3.5 * kk, RUST, 1.2 * kk);
  line(o(5, -3.5), o(9, 1), [0.3, 0.14, 0.1, 1], 1.2 * kk); line(o(4, 1), o(7, 4.5), [0.3, 0.14, 0.1, 1], 1.2 * kk); }
function crates(p, cols, rows, k, g) { const w = gl(WOOD, g, 0.6); for (let r = 0; r < rows; r++) for (let q = 0; q < cols; q++) { const c = add(p, [(q - (cols - 1) / 2) * 6.4 * k, (r - (rows - 1) / 2) * 6.4 * k]); plate(c, rectPts(2.9, 2.9), w, 0, k, 1); line(add(c, [-2.2 * k, -2.2 * k]), add(c, [2.2 * k, 2.2 * k]), dk(w, 0.35), 0.8 * k); } }
function conveyor(a, b, t, k, g) { const d = norm(sub(b, a)), n = orth(d), L = dist(a, b);
  line(a, b, OUTLINE, 8 * k); line(a, b, g ? dk(GOLD, 0.15) : METAL, 6.6 * k); line(a, b, [0.14, 0.13, 0.12, 1], 4.2 * k);
  for (let j = 0; j < Math.floor(L / (3 * k)); j++) { const u = fmod(j * 3 * k / L + t * 0.35, 1), q = lerp(a, b, u); line(add(q, mul(n, 2 * k)), add(q, mul(n, -2 * k)), [0.42, 0.4, 0.37, 1], 0.9 * k); }
  for (const e of [a, b]) { disc(e, 3.4 * k, OUTLINE); disc(e, 2.7 * k, g ? GOLD : METAL_L); disc(e, 1 * k, METAL_D); } }
function chunk(p, sc, seed, k, col, cube) { const c2 = col || mix([0.72, 0.46, 0.3, 1], METAL_L, 0.2 + 0.4 * rnd(seed));
  if (cube) { plate(p, rectPts(2.5, 2.5), c2, seed * 0.2, k * sc, 1); line(add(p, [-1.6 * k * sc, 0]), add(p, [1.6 * k * sc, 0]), A(OUTLINE, 0.4), 0.7 * k); return; }
  const pts = []; for (let i = 0; i < 6; i++) { const a = i * TAU / 6; pts.push([Math.cos(a) * 3.1 * (0.7 + 0.3 * rnd(seed + i)), Math.sin(a) * 3.1 * (0.7 + 0.3 * rnd(seed + i + 9))]); }
  fill(p, pts, c2, seed, k * sc); outline(p, pts, OUTLINE, 1.2, seed, k * sc); line(add(p, mul(fa(seed), -1.2 * k * sc)), add(p, mul(fa(seed), 1.2 * k * sc)), [1, 1, 1, 0.35], 0.9 * k * sc); }
function yardFloor(c, k, col, t) { ellipse(add(c, [0, 8 * k]), 44 * k, 16 * k, [0, 0, 0, 0.3]); plate(c, rectPts(46, 46), lt(METAL_D, 0.04), 0, k, 1.3); fill(c, rectPts(44, 44), CONC, 0, k);
  for (let i = -3; i <= 3; i++) { line(add(c, [i * 12 * k, -44 * k]), add(c, [i * 12 * k, 44 * k]), [0, 0, 0, 0.1], 0.8 * k); line(add(c, [-44 * k, i * 12 * k]), add(c, [44 * k, i * 12 * k]), [0, 0, 0, 0.1], 0.8 * k); }
  outline(c, rectPts(44, 44), A(col, 0.4 + 0.15 * Math.sin(t * 2.2)), 1.3 * k, 0, k); }
function dirt(c, x0, y0, x1, y1, k, seed) { fill(add(c, [(x0 + x1) / 2 * k, (y0 + y1) / 2 * k]), rectPts((x1 - x0) / 2, (y1 - y0) / 2), DIRT, 0, k);
  for (let i = 0; i < 14; i++) disc(add(c, [(x0 + (x1 - x0) * rnd(seed + i)) * k, (y0 + (y1 - y0) * rnd(seed + i + 40)) * k]), (0.5 + rnd(seed + i + 80)) * k, [0.2, 0.17, 0.14, 1]); }
function smoke(p, R, t, k, n) { for (let i = 0; i < n; i++) { const u = fmod(t * 0.32 + i / n, 1); disc(add(p, [(R * 0.2 + u * 14) * k, -(R * 0.15 + u * 24) * k]), (2 + u * 6) * k, A([0.5, 0.48, 0.46, 1], 0.42 * (1 - u))); } }
function truck(p, ang, k, col, len) { const o = (x, y) => add(p, rot([x * k, y * k], ang)); fill(add(p, [1.5 * k, 2 * k]), [[-len - 2, -3.8], [len + 4, -3.8], [len + 4, 3.8], [-len - 2, 3.8]], [0, 0, 0, 0.28], ang, k);
  plate(o(-2, 0), rectPts(len, 3.6), col, ang, k, 1.2); for (let j = 1; j < 4; j++) line(o(-2 - len + j * len * 0.5, -3.2), o(-2 - len + j * len * 0.5, 3.2), A(OUTLINE, 0.35), 0.7 * k);
  plate(o(len + 1.4, 0), rectPts(2.4, 3.2), dk(col, 0.12), ang, k, 1.2); fill(o(len + 2.6, 0), rectPts(0.8, 2.4), [0.55, 0.75, 0.9, 0.85], ang, k); }
function forklift(p, ang, k, col, load) { const o = (x, y) => add(p, rot([x * k, y * k], ang)); plate(p, rectPts(2.2, 1.6), col, ang, k, 1); disc(o(-0.8, 0), 0.8 * k, OUTLINE); line(o(2.2, -1.5), o(2.2, 1.5), METAL_D, 0.9 * k);
  for (const y of [-0.8, 0.8]) line(o(2.2, y), o(4.4, y), METAL_L, 0.7 * k); if (load) plate(o(3.4, 0), rectPts(1.4, 1.4), load, ang, k, 0.9); }
function zap(a, b, seed, w, t, k) { const pts = [a], n = orth(norm(sub(b, a))); for (let j = 1; j < 5; j++) pts.push(add(lerp(a, b, j / 5), mul(n, (rnd(seed + j + Math.floor(t * 14) * 3.1) - 0.5) * 2.2 * k))); pts.push(b); polyline(pts, A(ARCC, 0.35), w * 2.6); polyline(pts, [0.95, 0.98, 1, 1], w); }

// ---- Path 1: the furnace stack, rebuilt around each step's machine; returns true when it has a lid (the scrap then drops through a charging hole) -------------
function stackModel(S, B, t, age, k) {
  const L = B.lv[0], g = L >= 5, K = pick(B, 0, L), K1 = K(0), K2 = K(1), K3 = K(2), K4 = K(3), K5 = K(4);
  const p = S(0, -8), P = (x, y) => add(p, [x * k, y * k]), R = STACKR[L], pay = decay(age, 1.4), fl = 0.5 + 0.5 * Math.sin(t * 6.3) * Math.sin(t * 2.1 + 1);
  const shell = gl(BRICK, g, 0.55), band = g ? GOLD : METAL, bandL = g ? lt(GOLD, 0.25) : METAL_L, steel = gl(STEEL, g, 0.7), dark = g ? dk(GOLD, 0.55) : METAL_D, melt = g ? mix(MOLTEN, GOLD, 0.6) : MOLTEN, tall = L >= 3 ? 1.35 : 1;
  disc(add(p, [R * 0.5 * tall * k, R * 0.6 * tall * k]), R * 1.05 * k, [0, 0, 0, 0.32]);                                   // the tallest part: the longest shadow (longer once it's a blast furnace)
  // ---- step 3, the Blast Furnace: what stands around it (two hot-blast stoves, a skip hoist, or a steel frame with a downcomer)
  if (K3 === "A") for (const sx of [-1, 1]) { const q = P(sx * 10, -27), r = 6.2; bar(q, P(sx * 4, -R + 2), 2.6 * k, steel); disc(add(q, [2 * k, 2.6 * k]), r * k, [0, 0, 0, 0.3]); disc(q, (r + 1.2) * k, OUTLINE); disc(q, r * k, steel); disc(add(q, [-1.2 * k, -1.2 * k]), r * 0.62 * k, lt(steel, 0.18)); ring(q, r * 0.8 * k, bandL, 1.1 * k); glowDot(q, 0.8 * k, A(melt, 0.6 + 0.4 * fl)); }
  if (K3 === "B") { const a = P(9, 30), b = P(2, R * 0.2), d = norm(sub(b, a)), n = orth(d), len = dist(a, b);
    for (const sg of [-1, 1]) { line(add(a, mul(n, sg * 2.2 * k)), add(b, mul(n, sg * 2.2 * k)), OUTLINE, 2 * k); line(add(a, mul(n, sg * 2.2 * k)), add(b, mul(n, sg * 2.2 * k)), steel, 1.1 * k); }
    for (let j = 1; j < len / (3 * k); j++) { const q = lerp(a, b, j * 3 * k / len); line(add(q, mul(n, -2.2 * k)), add(q, mul(n, 2.2 * k)), dark, 0.8 * k); }
    plate(lerp(a, b, (0.5 - 0.5 * Math.cos(t * 0.9)) * 0.82), rectPts(2.2, 1.8), gl(CRANE, g, 0.5), Math.atan2(d[1], d[0]), k, 1); }
  if (K3 === "C") { const F = R + 3.4, cs = [[-F, -F], [F, -F], [F, F], [-F, F]]; for (let i = 0; i < 4; i++) bar(P(...cs[i]), P(...cs[(i + 1) % 4]), 2.2 * k, steel); for (const q of cs) plate(P(...q), rectPts(2.4, 2.4), dark, 0, k, 1.1);
    bar(P(3, -R + 3), P(4, -R - 10), 3.2 * k, steel); const dc = P(4, -R - 12); disc(dc, 5 * k, OUTLINE); disc(dc, 4.2 * k, steel); ring(dc, 2.6 * k, bandL, 1 * k); disc(dc, 1.4 * k, dark); }
  // ---- step 2, the Forced Bellows: its air supply (twin bellows, a side blower or a bustle-pipe ring), bigger once it's a blast furnace
  const bs = L >= 3 ? 1.25 : 1;
  if (K2 === "A") [-2.6, -0.5].forEach((a, i) => { const q = add(p, mul(fa(a), (R + 6 * bs) * k)), sq = 0.6 + 0.4 * (0.5 + 0.5 * Math.sin(t * 3 + i * Math.PI)), d = a + Math.PI, o = (x, y) => add(q, rot([x * k * bs, y * k * bs], d)), lc = gl([0.5, 0.32, 0.2, 1], g, 0.5);
      bar(o(2, 0), add(p, mul(fa(a), (R - 1) * k)), 1.6 * k, steel); fill(q, [[-5, -4 * sq], [2, -1.3], [2, 1.3], [-5, 4 * sq]], lc, d, k * bs); outline(q, [[-5, -4 * sq], [2, -1.3], [2, 1.3], [-5, 4 * sq]], OUTLINE, 1.2, d, k * bs);
      for (const x of [-3.4, -1.8, -0.2]) { const h = 1.3 + (4 * sq - 1.3) * (2 - x) / 7; line(o(x, -h), o(x, h), dk(lc, 0.35), 0.8 * k); } plate(o(-5.6, 0), rectPts(0.8, 4.2 * sq), gl(WOOD, g, 0.5), d, k * bs, 1); });
  if (K2 === "B") { const a = -0.75, q = add(p, mul(fa(a), (R + 7 * bs) * k)), r = 5.2 * bs; bar(q, add(p, mul(fa(a), (R - 1) * k)), 3 * k, steel); disc(q, (r + 1.2) * k, OUTLINE); disc(q, r * k, dark);
    for (let j = 0; j < 5; j++) fill(q, [[0.6, -0.5], [r * 0.9, -1.4], [r * 0.9, 1.4], [0.6, 0.5]], bandL, t * 14 + j * TAU / 5, k); disc(q, 1.4 * k, steel); ring(q, r * k, band, 1.2 * k); }
  if (K2 === "C") { const rr = R + 3 + (bs - 1) * 4; bar(add(p, mul(fa(-0.75), rr * k)), add(p, mul(fa(-0.75), (rr + 9) * k)), 3.2 * k, steel);
    for (let j = 0; j < 8; j++) { const a = j * TAU / 8 + 0.2; bar(add(p, mul(fa(a), rr * k)), add(p, mul(fa(a), (R - 0.5) * k)), 1.5 * k, steel); } ring(p, rr * k, OUTLINE, 4.6 * k); ring(p, rr * k, steel, 3.2 * k); ring(p, rr * k, lt(steel, 0.2), 0.9 * k); }
  // ---- the stack; step 1, the Firebrick Lining, sets its shell (a thick glowing brick shell, hex refractory tiles, or a double wall with glowing slits)
  disc(p, (R + 1.6) * k, OUTLINE); disc(p, R * k, K1 === "B" ? gl(CERAM, g, 0.5) : shell);
  if (!K1) for (let i = 0; i < 26; i++) { const a = i * TAU / 26; line(add(p, mul(fa(a), R * 0.8 * k)), add(p, mul(fa(a), R * k)), [0.32, 0.15, 0.1, 1], 1 * k); }
  if (K1 === "A") { ring(p, R * 0.82 * k, A(melt, 0.25 + 0.3 * fl), 0.9 * k); for (let c2 = 0; c2 < 2; c2++) { const r0 = c2 ? 0.82 : 0.66, r1 = c2 ? 1 : 0.82, n = c2 ? 34 : 28; for (let i = 0; i < n; i++) { const a = (i + 0.5 * c2) * TAU / n; line(add(p, mul(fa(a), R * r0 * k)), add(p, mul(fa(a), R * r1 * k)), A(melt, 0.35 + 0.35 * fl), 0.8 * k); } } }
  if (K1 === "B") for (const [rf, n] of [[0.9, 26], [0.75, 21]]) for (let i = 0; i < n; i++) { const a = i * TAU / n + rf; outline(add(p, mul(fa(a), R * rf * k)), ngon(6, 1.55, a), dk(CERAM, 0.35), 0.9 * k, 0, k); }
  if (K1 === "C") { ring(p, (R - 1.4) * k, steel, 2.6 * k); ring(p, R * 0.78 * k, [0.07, 0.05, 0.04, 1], 2.4 * k); for (let i = 0; i < 8; i++) { const a = i * TAU / 8 + 0.2; arc(p, R * 0.78 * k, a, a + 0.3, A(HOTM, 0.55 + 0.4 * fl), 1.3 * k); } }
  ring(p, (R - 0.7) * k, band, 1.8 * k);
  const inR = K1 ? 0.66 : 0.8; disc(p, R * inR * k, lt(K1 === "B" ? gl(CERAM, g, 0.5) : shell, 0.1)); ring(p, R * inR * k, bandL, 1.6 * k); for (let i = 0; i < 8; i++) disc(add(p, mul(fa(i * TAU / 8 + 0.2), R * inR * k)), 0.8 * k, lt(bandL, 0.15));
  // ---- step 4, the Arc Furnace: the top is rebuilt (a domed lid with three electrodes, a tilting vessel under electrode arms, or a ring of electrodes round a plasma core)
  const lid = K4 === "A";
  if (lid) { const lr = R * 0.64;
    ring(p, (lr + 0.6) * k, A(melt, 0.45 + 0.35 * fl), 2 * k); disc(p, (lr + 0.2) * k, OUTLINE); disc(p, lr * k, steel); disc(add(p, [-lr * 0.18 * k, -lr * 0.18 * k]), lr * 0.62 * k, lt(steel, 0.12)); ring(p, lr * 0.8 * k, band, 1.1 * k);
    for (const F of feeds(B)) { const h = S(...lidHole(F, R)); disc(h, 2.6 * k, OUTLINE); disc(h, 2.1 * k, mix([0.35, 0.08, 0.03, 1], melt, 0.5 + 0.3 * fl)); }
    const es = [0, 1, 2].map((i) => add(p, mul(fa(-Math.PI / 2 + i * TAU / 3), R * 0.26 * k))); for (let i = 0; i < 3; i++) if (rnd(i + Math.floor(t * 12) * 1.7) > 0.3) zap(es[i], es[(i + 1) % 3], i * 7, 0.9 * k, t, k);
    for (const e of es) { disc(e, 2.3 * k, OUTLINE); disc(e, 1.9 * k, g ? dk(GOLD, 0.3) : [0.24, 0.24, 0.26, 1]); disc(add(e, [-0.5 * k, -0.5 * k]), 0.7 * k, [1, 1, 1, 0.35]); glowDot(e, (0.6 + 0.4 * fl) * k, ARCC); } }
  else if (K4 === "B") { const vc = P(Math.sin(t * 0.6) * 1.4, 0); disc(p, R * 0.66 * k, dark); oval(vc, R * 0.62 * k, R * 0.54 * k, 0, gl(STEEL, g, 0.6), 1.4); oval(vc, R * 0.46 * k, R * 0.4 * k, 0, mix([0.35, 0.08, 0.03, 1], melt, 0.55 + 0.3 * fl + 0.2 * pay), 0); glowDot(vc, (1.6 + 1.6 * pay) * k, HOTM);
    const mast = P(-R - 4, R * 0.35); plate(mast, rectPts(2.4, 2.4), dark, 0, k, 1.2); const es = [-1, 0, 1].map((i) => add(vc, mul(fa(Math.PI + i * 0.9), R * 0.24 * k)));
    es.forEach((e, i) => { polyline([mast, add(lerp(mast, e, 0.5), [0, 3 * k]), e], A(OUTLINE, 0.8), 1.4 * k); bar(mast, e, 1.4 * k, steel); disc(e, 1.9 * k, OUTLINE); disc(e, 1.5 * k, g ? dk(GOLD, 0.3) : [0.24, 0.24, 0.26, 1]); if (rnd(i + Math.floor(t * 12) * 2.3) > 0.35) zap(e, add(e, [(rnd(i + Math.floor(t * 9)) - 0.5) * 6 * k, 3 * k]), i * 11, 0.8 * k, t, k); }); }
  else if (K4 === "C") { disc(p, R * 0.63 * k, dark); ring(p, R * 0.63 * k, OUTLINE, 1.2 * k); const pc = R * (0.3 + 0.04 * fl + 0.06 * pay); disc(p, pc * 1.5 * k, A(ARCC, 0.25)); disc(p, pc * k, mix(ARCC, [1, 1, 1, 1], 0.5 + 0.3 * fl)); glowDot(p, (1.8 + 1.5 * pay) * k, [1, 1, 1, 1]);
    for (let i = 0; i < 6; i++) { const e = add(p, mul(fa(i * TAU / 6 + 0.3), R * 0.52 * k)); if (rnd(i + Math.floor(t * 13) * 1.9) > 0.3) zap(e, p, i * 5, 0.8 * k, t, k); disc(e, 1.9 * k, OUTLINE); disc(e, 1.5 * k, g ? dk(GOLD, 0.3) : [0.24, 0.24, 0.26, 1]); } }
  else { disc(p, R * 0.63 * k, dark); ring(p, R * 0.63 * k, OUTLINE, 1.2 * k); disc(p, R * 0.5 * k, mix([0.35, 0.08, 0.03, 1], melt, 0.45 + 0.3 * fl + 0.25 * pay)); ring(p, R * 0.56 * k, A(melt, 0.25 + 0.2 * fl + 0.4 * pay), 2 * k);
    disc(p, R * (0.24 + 0.05 * fl + 0.1 * pay) * k, A(HOTM, 0.9)); glowDot(p, (2 + 2.2 * pay) * k, HOTM);
    if (K3 === "B") { ring(p, R * 0.56 * k, OUTLINE, 3 * k); ring(p, R * 0.56 * k, steel, 1.8 * k); for (let i = 0; i < 4; i++) bar(add(p, mul(fa(i * Math.PI / 2 + 0.4), R * 0.56 * k)), add(p, mul(fa(i * Math.PI / 2 + 0.4), R * 0.66 * k)), 1.2 * k, steel); } }   // the charging bell's rim
  // ---- the mastery, Gold Foundry: everything above is gold; option A adds glints running round the rim (B and C are drawn by foundryExtra)
  if (g) { ring(p, (R + 0.4) * k, A(GOLD, 0.9), 1.2 * k); if (K5 === "A") { const a = t * 1.3; arc(p, R * k, a, a + 0.7, [1, 1, 0.85, 0.9], 1.6 * k); arc(p, R * 0.63 * k, -a, -a + 0.5, [1, 1, 0.85, 0.8], 1.2 * k); } }
  return lid; }
function foundryExtra(S, B, t, k) { if (B.lv[0] < 5) return; const K5 = B.key("p0s4");
  if (K5 === "B") { const q = S(14, 10), r = 5.4, tap = S(10.4, 5.4); disc(add(q, [1.5 * k, 2 * k]), (r + 1) * k, [0, 0, 0, 0.3]); disc(q, (r + 1.2) * k, OUTLINE); disc(q, r * k, dk(GOLD, 0.35));
    for (let i = 0; i < 8; i++) { const a = t * 0.6 + i * TAU / 8, m = add(q, mul(fa(a), r * 0.7 * k)); fill(m, rectPts(1.5, 0.9), i % 3 ? GOLD : HOTM, a + Math.PI / 2, k); outline(m, rectPts(1.5, 0.9), OUTLINE, 0.8, a + Math.PI / 2, k); }
    disc(q, 1.6 * k, GOLD); line(tap, add(q, mul(norm(sub(tap, q)), r * 0.7 * k)), A(HOTM, 0.9), 1.4 * k); }
  if (K5 === "C") { const pv = S(22, -20), bk = S(17, -14), on = 0.5 + 0.5 * Math.sin(t * 1.2); bar(pv, bk, 1.6 * k, GOLD); disc(pv, 1.4 * k, dk(GOLD, 0.3)); disc(bk, 3 * k, OUTLINE); disc(bk, 2.6 * k, dk(GOLD, 0.2)); disc(bk, 1.7 * k, mix(GOLD, HOTM, 0.5));
    line(add(bk, [0, 1.6 * k]), S(17, -8.6), A(HOTM, 0.5 + 0.5 * on), (0.8 + 0.8 * on) * k); glowDot(S(17, -8.6), (0.6 + 0.6 * on) * k, HOTM); } }

// ---- Path 2: the junkyard's ground (the heaps, the hauled-in wreck and the press); the crane and the Sorting Line are in the feed line --------------------------------
function junkGround(S, B, t, k) {
  const L = B.lv[1], g = L >= 5, K = pick(B, 1, L), K1 = K(0), K3 = K(2), K4 = K(3), K5 = K(4), steel = gl(STEEL, g, 0.7), dark = g ? dk(GOLD, 0.55) : METAL_D, yel = gl(CRANE, g, 0.6);
  if (g && K5 === "C") { const pts = [S(-44.5, -44.5), S(-14.5, -44.5), S(-14.5, 44.5), S(-44.5, 44.5)]; for (let i = 0; i < 4; i++) { const a = pts[i], b = pts[(i + 1) % 4], n = Math.round(dist(a, b) / (3 * k)); for (let j = 0; j < n; j += 2) line(lerp(a, b, j / n), lerp(a, b, (j + 1) / n), GOLD, 1.4 * k); } }
  scrapPile(S(-31, -30), 8, k, 2, g && K5 === "B"); scrapPile(S(-33, 0), 9, k, 13, g && K5 === "B");
  // ---- step 1, the Tow Hook: the wreck is hauled in (by a tow truck, a winch post or a hook-and-chain gantry); step 4's flat press crushes it where it lies
  const hc = fmod(t / 6, 1), haul = hc < 0.7 ? ease(hc / 0.7) : 1 - ease((hc - 0.7) / 0.3), wy = 34; let wx = -32, lift = 0;
  if (K1 === "A") wx = -36 + 5 * haul; if (K1 === "B") wx = -34 + 4 * haul; if (K1 === "C") lift = Math.max(0, Math.sin(t * 0.8)); if (K4 === "A") wx = -30;
  let sq = 1; if (K4 === "A") { const pc = fmod(t / 3, 1); sq = 1 + 0.14 * (pc < 0.3 ? ease(pc / 0.3) : pc < 0.7 ? 1 : 1 - ease((pc - 0.7) / 0.3)); }
  ellipse(add(S(wx, wy), [(1.5 + 4 * lift) * k, (2.5 + 4 * lift) * k]), 13 * k, 7 * k, [0, 0, 0, 0.3]);
  if (K1 === "A") { truck(S(-9, 42), 0, k, yel, 3.5); bar(S(-14.5, 42), S(-17.5, 42), 1.4 * k, steel); line(S(-17.5, 42), S(wx + 11, wy), METAL_L, 0.9 * k); }
  if (K1 === "B") { const wp = S(-41, 25); line(wp, S(wx - 10, wy - 2), METAL_L, 0.9 * k); disc(wp, 3 * k, OUTLINE); disc(wp, 2.5 * k, dark); for (let j = 0; j < 4; j++) line(wp, add(wp, mul(fa(t * 4 * (hc < 0.7 ? 1 : -1) + j * Math.PI / 2), 2.3 * k)), yel, 0.9 * k); }
  wreck(S(wx, wy - 2 * lift), 0.05, k * (1 + 0.06 * lift), sq);
  if (K1 === "C") { const a = S(-44, wy), b = S(-20, wy); for (const q of [a, b]) for (const sg of [-1, 1]) bar(q, add(q, [0, sg * 4 * k]), 1.4 * k, steel); bar(a, b, 2.2 * k, yel); line(S(-32, wy), S(-32, wy - 2 * lift), METAL_L, 1 * k); disc(S(-32, wy - 2 * lift), 1.2 * k, METAL_D); }
  if (K4 === "A") { const q = S(wx, wy), pr = sq - 1; for (const sx of [-1, 1]) plate(add(q, [sx * 14 * k, 0]), rectPts(2, 5), dark, 0, k, 1.2); for (const sy of [-1, 1]) bar(add(q, [-14 * k, sy * 4.4 * k]), add(q, [14 * k, sy * 4.4 * k]), 2 * k, steel);
    fill(q, rectPts(12, 6.4), A(steel, 0.25 + 2.5 * pr), 0, k); disc(q, 2.4 * k, OUTLINE); disc(q, 1.9 * k, steel); }
  // ---- the mastery, Breaker's Yard: a gold x2 sign for bosses
  if (g) { const q = S(-22, -41); plate(q, rectPts(4.4, 2.4), dk(GOLD, 0.3), 0, k, 1); txt(add(q, [0, 1.3 * k]), "x2", GOLD, Math.max(8, 3.2 * k)); } }

// ---- The feed lines: a crane loads a belt that drops the scrap into the furnace, one piece per 3.2 s cycle. Path 2 rebuilds the main line's crane and adds the
// Sorting Line and the Car Crusher to its belt; the Faster Loading Retrofit adds a second line from the top heap, half a cycle out of step (twice the feed).
const FEED = { pv: [-36, 13], heap: [-33, 0], b0: [-24, 20], rails: [-43, -13, -8, 35], ofs: 0 };   // round 5: the rails run on past the Hammer Mill (owner)
const FEED2 = { pv: [-29.3, -20.8], heap: [-31, -30], b0: [-22, -22], rails: [-43, -13, -40, -14], ofs: 1.6 };
const MOUTH = [0, -8], FEND = 9.5, FT = 3.2, FBELT = 0.35;
const feeds = (B) => (B.r === 1 ? [FEED, FEED2] : [FEED]);
const lidHole = (F, R) => add(MOUTH, mul(norm(sub(F.b0, MOUTH)), R * 0.42));
function magnetHead(q, mr, k, g, carry, halo) { if (carry) chunk(add(q, [mr * 0.5 * k, mr * 0.6 * k]), 1, carry, k);
  if (halo) disc(q, (mr + 2.2) * k, A(GOLD, 0.3)); disc(q, (mr + 0.7) * k, OUTLINE); disc(q, mr * k, g ? dk(GOLD, 0.25) : METAL_D); ring(q, mr * 0.62 * k, g ? GOLD : KILL, 1 * k); disc(q, mr * 0.3 * k, g ? GOLD : METAL_L); if (carry) glowDot(q, 0.7 * k, [0.7, 0.9, 1, 0.9]); }
// ---- Kill Income step 3, the Laser Cutter (round 3, the owner's note; was the Sorting Line, before that the Hydraulic Shear), on the main belt:
// a laser gantry sweeping across the belt, a cutting table beside it, or a laser turret that tracks the scrap riding up
function laserCutter(S, F, dir, key, t, k, g) { const Q = add(F.b0, mul(dir, 12.5)), n = [-dir[1], dir[0]], ang = Math.atan2(dir[1], dir[0]), P = (u) => S(...u), steel = gl(STEEL, g, 0.7), dark = g ? dk(GOLD, 0.55) : METAL_D;
  const beam = (a, b, w = 1) => { line(P(a), P(b), A(LASER, 0.3), 4 * w * k); line(P(a), P(b), LASER, 1.4 * w * k); line(P(a), P(b), [1, 0.88, 0.82, 0.95], 0.5 * w * k); };
  const sparks = (p, seed) => { for (let j = 0; j < 7; j++) { const q = t * 2.6 + j / 7, u = fmod(q, 1), a = rnd(Math.floor(q) * 5 + j + seed) * TAU; disc(P(add(p, mul(fa(a), u * 4.5))), (1.1 * (1 - u) + 0.25) * k, [1, 0.75 + 0.2 * rnd(j), 0.35, 1 - u]); } glowDot(P(p), 0.9 * k, [1, 0.6, 0.5, 1]); };
  if (key === "A") { const l1 = add(Q, mul(n, -7)), l2 = add(Q, mul(n, 7)), hx = Math.sin(t * 2.4) * 2.6, hd = add(Q, mul(n, hx)); 
    const pu = 0.6 + 0.4 * Math.sin(t * 9); const cq = add(Q, mul(dir, -3.2)); beam(add(cq, mul(n, -4.2)), add(cq, mul(n, 4.2)), 0.6 + 0.4 * pu); for (const sg of [-1, 1]) sparks(add(cq, mul(n, sg * 4.2 * Math.sin(t * 2.4))), 21 + sg);                                   // a glowing cut line across the belt
    for (const q of [l1, l2]) plate(P(q), rectPts(2.4, 2.4), dark, ang, k, 1.2); bar(P(l1), P(l2), 3.4 * k, gl(STEEL, g, 0.6)); plate(P(hd), rectPts(2.4, 2.6), gl(CRANE, g, 0.6), ang, k, 1.2); disc(P(hd), 1.1 * k, LASER); glowDot(P(hd), 0.8 * k, LASER); sparks(hd, 3); }   // the head sweeps along the gantry
  if (key === "B") { const T0 = add(Q, mul(n, 10.5)), u = fmod(t / 3, 1), cx = -4 + 8 * u, hd = add(add(T0, mul(dir, cx)), mul(n, Math.sin(u * TAU * 2) * 2));
    fill(add(P(T0), [1.5 * k, 2 * k]), rectPts(6.2, 4.6), [0, 0, 0, 0.3], ang, k); plate(P(T0), rectPts(6.2, 4.6), dark, ang, k, 1.2);
    for (let j = -2; j <= 2; j++) line(P(add(add(T0, mul(dir, j * 2.3)), mul(n, -4))), P(add(add(T0, mul(dir, j * 2.3)), mul(n, 4))), A(METAL_L, 0.45), 0.6 * k);
    fill(P(T0), rectPts(4.6, 3.2), mix(RUST, METAL_L, 0.45), ang, k); const cutPts = []; for (let j = 0; j <= 20; j++) { const v = j / 20 * u; cutPts.push(P(add(add(T0, mul(dir, -4 + 8 * v)), mul(n, Math.sin(v * TAU * 2) * 2)))); } polyline(cutPts, A(LASER, 0.35), 2.4 * k); polyline(cutPts, A(LASER, 0.95), 1 * k);
    bar(P(add(add(T0, mul(dir, cx)), mul(n, -4.8))), P(add(add(T0, mul(dir, cx)), mul(n, 4.8))), 1.6 * k, gl(STEEL, g, 0.6)); plate(P(hd), rectPts(1.3, 1.3), gl(CRANE, g, 0.6), ang, k, 1); sparks(hd, 9);
    chunk(P(add(Q, mul(n, 5))), 0.6, 4, k); }   // a cutting table beside the belt: the head traces a cut through a plate
  if (key === "C") { const base = add(Q, mul(n, 10)), aim = add(F.b0, mul(dir, 8 + 9 * (0.5 + 0.5 * Math.sin(t * 1.6)))), a = Math.atan2(aim[1] - base[1], aim[0] - base[0]), muz = add(base, mul(fa(a), 5.4));
    disc(add(P(base), [1.5 * k, 2 * k]), 4.6 * k, [0, 0, 0, 0.3]); disc(P(base), 4.6 * k, OUTLINE); disc(P(base), 4 * k, dark); ring(P(base), 3.2 * k, gl(METAL_L, g, 0.6), 0.9 * k); bar(P(base), P(muz), 2.6 * k, steel); plate(P(base), rectPts(2.8, 2.2), gl(CRANE, g, 0.6), a, k, 1.1); glowDot(P(muz), 0.8 * k, LASER);
    beam(muz, aim, 1.2); sparks(aim, 17); } }   // a laser turret tracking the scrap on the belt
// One feed line. style: null = the grab, "A" = one-boom magnet crane, "B" = twin-boom magnet crane, "C" = overhead bridge magnet. main: the line path 2 rebuilds.
function feedLine(S, B, t, k, lid, F, style, main) {
  const L = B.lv[1], g = L >= 5, K3 = main && L > 2 ? B.key("p1s2") : null, K4 = main && L > 3 ? B.key("p1s3") : null, K5 = L > 4 ? B.key("p1s4") : null, tt = t - F.ofs;
  const dir = norm(sub(MOUTH, F.b0)), e = sub(MOUTH, mul(dir, FEND)), Lu = dist(F.b0, e), Lp = add(F.b0, mul(dir, 2.5)), v = FBELT * Lu, ride = (Lu - 2.5) / v, n = Math.floor(tt / FT), tgt = lid ? lidHole(F, STACKR[B.lv[0]]) : MOUTH;
  const steel = gl(STEEL, g, 0.7), yel = gl(CRANE, g, 0.7), dark = g ? dk(GOLD, 0.55) : METAL_D, cube = K4 === "B", rl = K4 === "C";
  conveyor(S(...F.b0), S(...e), t, k, g);
  for (let i = 0; i < 4; i++) { const m = n - i, a = tt - (m + 0.56) * FT, sd = m * 1.7 + 1 + F.ofs * 5; if (a < 0) continue;
    if (a < ride) { const dd = a * v + 2.5; chunk(S(...add(F.b0, mul(dir, dd))), rl && dd > 7 ? 0.75 : 1, sd, k, null, cube || (rl && dd > 7)); }
    else { const u = (a - ride) / 0.4; if (u < 1) chunk(S(...lerp(e, tgt, ease(u))), 1 - 0.65 * u, sd, k, mix([0.72, 0.46, 0.3, 1], MOLTEN, u), cube); else if (u < 2.5) glowDot(S(...tgt), (1.4 + 2.2 * (1 - (u - 1) / 1.5)) * k, A(HOTM, 1 - (u - 1) / 1.5)); } }
  // ---- step 4, the Car Crusher on the belt: a baler at its foot (the scrap leaves as cubes) or two crushing rollers across it (the flat press is in junkGround)
  if (K4 === "B") { const q = S(-27, 23), pr = 0.5 + 0.5 * Math.sin(t * 2.2); plate(q, rectPts(5.4, 4.4), dark, -0.86, k, 1.3); fill(q, rectPts(3.6, 2.8), [0.1, 0.09, 0.09, 1], -0.86, k); plate(add(q, rot([(-2.4 + 2 * pr) * k, 0], -0.86)), rectPts(0.8, 2.6), steel, -0.86, k, 1); }
  if (rl) { const nn = orth(dir); for (const sg of [-1, 1]) { const r0 = S(...add(add(F.b0, mul(dir, 6)), mul(nn, sg * 4.4))); disc(r0, 3.2 * k, OUTLINE); disc(r0, 2.7 * k, steel); for (let j = 0; j < 6; j++) line(r0, add(r0, mul(fa(t * 6 * sg + j * Math.PI / 3), 2.5 * k)), dark, 0.9 * k); } }
  if (K3) laserCutter(S, F, dir, K3, t, k, g);
  // ---- the crane: grab at the heap, swing, drop on the belt's foot, swing back
  const ph = fmod(tt / FT, 1), sw = ph < 0.14 ? 0 : ph < 0.5 ? ease((ph - 0.14) / 0.36) : ph < 0.6 ? 1 : 1 - ease((ph - 0.6) / 0.4), op = ph < 0.14 ? 1 - ph / 0.14 : ph < 0.5 ? 0 : ph < 0.6 ? (ph - 0.5) / 0.1 : 1;
  const carry = ph > 0.06 && ph < 0.56 ? n * 1.7 + 1 + F.ofs * 5 : 0, mr = main ? [0, 0, 3, 3.4, 3.8, 4.2][L] : 3.4, halo = g && K5 === "A";
  if (style === "C") { const tp = lerp(F.heap, Lp, sw), q = S(...tp), [x0, x1, y0, y1] = F.rails;
    for (const x of [x0, x1]) { line(S(x, y0), S(x, y1), OUTLINE, 2.6 * k); line(S(x, y0), S(x, y1), steel, 1.4 * k); for (const y of [y0, y1]) plate(S(x, y), rectPts(1.6, 0.9), dark, 0, k, 1); }
    bar(S(x0, tp[1]), S(x1, tp[1]), 2.6 * k, yel); for (const x of [x0, x1]) plate(S(x, tp[1]), rectPts(2, 2.6), dark, 0, k, 1);
    plate(q, rectPts(2.8, 2.2), dark, 0, k, 1); magnetHead(q, mr, k, g, carry, halo); return; }
  const pv = S(...F.pv), aH = Math.atan2(F.heap[1] - F.pv[1], F.heap[0] - F.pv[0]), aL = Math.atan2(Lp[1] - F.pv[1], Lp[0] - F.pv[0]), rH = dist(F.pv, F.heap), rL = dist(F.pv, Lp), a = aH + (aL - aH) * sw, reach = rH + (rL - rH) * sw, tip = add(pv, mul(fa(a), reach * k));
  disc(add(pv, [1.5 * k, 2 * k]), 5.4 * k, [0, 0, 0, 0.3]); disc(pv, (style === "B" ? 6.2 : 5.4) * k, OUTLINE); disc(pv, (style === "B" ? 5.4 : 4.6) * k, dk(yel, 0.15));
  if (style === "B") { const nn = orth(fa(a)); for (const sg of [-1, 1]) bar(add(pv, mul(nn, sg * 1.8 * k)), add(tip, mul(nn, sg * 1.2 * k)), 1.8 * k, yel); } else bar(pv, tip, 2.6 * k, yel);
  plate(pv, rectPts(3.2, 2.6), dark, a, k, 1.1);
  if (style) magnetHead(tip, mr, k, g, carry, halo);
  else { if (carry) chunk(tip, 1, carry, k); for (let i = 0; i < 4; i++) { const b = a + i * TAU / 4 + Math.PI / 4; line(tip, add(tip, mul(fa(b), (2.2 + 1.6 * op) * k)), METAL_L, 1.3 * k); } disc(tip, 1.6 * k, METAL_D); } }

// ---- Path 3: the warehouse, rebuilt shorter (its end becomes a yard for the dock) and around each step's machine ---------------------------------------------------
function wareP(p, hw, hh, ang, nDoor, age, k, o) { const O = (x, y) => add(p, rot([x * k, y * k], ang)), op = age < 0.4 ? ease(age / 0.4) : age < 1.4 ? 1 : 1 - ease(Math.min(1, (age - 1.4) / 0.4)), roof = o.roof || ROOF, t = o.t || 0, dx = (i) => (i - (nDoor - 1) / 2) * (hw * 2 - 6) / nDoor;
  fill(add(p, [2.5 * k, 3.5 * k]), rectPts(hw, hh), [0, 0, 0, 0.3], ang, k);
  for (let i = 0; i < nDoor; i++) { fill(O(dx(i), hh + 1.4), rectPts(4.4, 2.4), CONC, ang, k); hazard(O(dx(i), hh + 3.6), ang, k, -4, 4, 0, DOOR, 1); }
  plate(p, rectPts(hw, hh), roof, ang, k, 1.5);
  const x0 = o.open >= 1 ? -hw : o.open > 0 ? 0 : hw;                                                                         // the roof is off from local x0 to the end
  if (x0 < hw) { const a = x0 + 1.2, b = hw - 1.2, cx = (a + b) / 2, hx = (b - a) / 2, shelf = o.rack === "shelf", rows = shelf ? [-5.2, 5.2] : [-5.6, -2.6, 2.6, 5.6];
    fill(O(cx, 0), rectPts(hx, hh - 1.2), [0.15, 0.15, 0.16, 1], ang, k);
    rows.forEach((y, ri) => { fill(O(cx, y), rectPts(hx - 0.4, shelf ? 1.3 : 1.2), gl(METAL_D, o.gold, 0.6), ang, k);
      for (let x = a + 1.4, j = 0; x < b - 1; x += shelf ? 1.9 : 2.8, j++) { const col = o.goldStock ? GOLD : LOADS[Math.floor(rnd(j * 3.1 + ri * 7) * 4)]; if (shelf) disc(O(x, y), 0.55 * k, col); else { fill(O(x, y), rectPts(1.1, 0.9), col, ang, k); outline(O(x, y), rectPts(1.1, 0.9), OUTLINE, 0.7, ang, k); } } });
    if (o.rack === "stacker") { const sx = cx + Math.sin(t * 0.5) * hx * 0.8; bar(O(sx, -hh + 0.8), O(sx, hh - 0.8), 1.4 * k, gl(CRANE, o.gold, 0.6)); plate(O(sx, Math.sin(t * 1.3) * 3), rectPts(1.4, 1.2), METAL_D, ang, k, 1); }
    for (let x = a + 6; x < b; x += 8) line(O(x, -hh + 0.6), O(x, hh - 0.6), A(gl(METAL_L, o.gold, 0.6), 0.8), 0.9 * k);
    outline(O(cx, 0), rectPts(hx, hh - 1.2), OUTLINE, 1, ang, k); }
  const r1 = Math.min(hw, x0);
  if (r1 > -hw + 3) { for (let x = -hw + 2.2; x < r1 - 1; x += 2.2) line(O(x, -hh + 0.9), O(x, hh - 0.9), dk(roof, 0.2), 0.8 * k); bar(O(-hw + 0.8, 0), O(r1 - 0.8, 0), 1.8 * k, lt(roof, 0.12));
    for (const x of [-hw + (r1 + hw) * 0.25, -hw + (r1 + hw) * 0.75]) fill(O(x, -hh * 0.5), rectPts(2.8, 1.8), [0.7, 0.86, 0.96, 0.55], ang, k); }
  for (let i = 0; i < nDoor; i++) { const d = O(dx(i), hh - 0.2); fill(d, rectPts(3.6, 1.3), mix(DOOR, [0.04, 0.04, 0.04, 1], op), ang, k); outline(d, rectPts(3.6, 1.3), OUTLINE, 1, ang, k);
    if (op < 0.9) for (const j of [-0.5, 0.5]) line(O(dx(i) - 3.2, hh - 0.2 + j), O(dx(i) + 3.2, hh - 0.2 + j), A(dk(DOOR, 0.4), 1 - op), 0.7 * k); }
  if (o.gold) outline(p, rectPts(hw + 0.3, hh + 0.3), GOLD, 1.3 * k, ang, k); }
function wareModel(S, B, t, age, k) {
  const L = B.lv[2], g = L >= 5, K = pick(B, 2, L), K1 = K(0), K2 = K(1), K3 = K(2), K4 = K(3), K5 = K(4);
  if (!L) { wareP(S(33, 0), 40, 9.5, Math.PI / 2, 4, age, k, { t }); surplus(S, B, k, false); return; }
  const fleet = g && K5 === "C", stock = g && K5 === "B", fc = fleet ? GOLD : CRANE, cc = (i) => (stock ? GOLD : LOADS[((i % 4) + 4) % 4]);
  const open = K2 === "A" || K2 === "C" ? 1 : K1 === "A" ? 0.5 : 0, rack = K2 === "A" ? "pallet" : K2 === "C" ? "stacker" : "shelf";
  wareP(S(33, -10), 30, 9.5, Math.PI / 2, 3, age, k, { open, rack, t, gold: g, goldStock: stock, roof: g && K5 === "A" ? mix(ROOF, GOLD, 0.7) : ROOF });
  // ---- step 1: half the roof off over shelves (drawn by wareP), a lean-to of shelves at the shed's end, or a parts cage in the yard
  if (K1 === "B") { const q = S(33, 21.6); plate(q, rectPts(9.5, 1.6), lt(ROOF, 0.08), 0, k, 1.1); for (let j = -3; j <= 3; j++) disc(add(q, [j * 2.6 * k, 0.4 * k]), 0.55 * k, cc(j + 3)); }
  if (K1 === "C") { const q = S(16, 17); fill(q, rectPts(3.6, 3.6), [0.15, 0.15, 0.16, 1], 0, k); for (let j = 0; j < 4; j++) disc(add(q, [((j % 2) - 0.5) * 3.2 * k, (Math.floor(j / 2) - 0.5) * 3.2 * k]), 0.8 * k, cc(j));
    for (let j = -3; j <= 3; j++) { line(add(q, [j * 1.2 * k, -3.6 * k]), add(q, [j * 1.2 * k, 3.6 * k]), A(METAL_L, 0.5), 0.6 * k); line(add(q, [-3.6 * k, j * 1.2 * k]), add(q, [3.6 * k, j * 1.2 * k]), A(METAL_L, 0.5), 0.6 * k); } outline(q, rectPts(3.6, 3.6), gl(METAL_L, g, 0.6), 1.2 * k, 0, k); }
  // ---- step 2: racks inside (wareP), or pallet stacks outside the doors
  if (K2 === "B") [[18, 2], [14, 26]].forEach(([x, y], i) => { const q = S(x, y); plate(q, rectPts(3, 3), WOOD, 0, k, 1); plate(add(q, [-0.4 * k, -0.4 * k]), rectPts(2.4, 2.4), cc(i), 0, k, 1); plate(add(q, [-0.8 * k, -0.8 * k]), rectPts(1.7, 1.7), lt(cc(i + 1), 0.1), 0, k, 1); });
  // ---- step 3, the Forklift Bay: a forklift running pallets out, a charging bay with two forklifts, or automated carts on a painted loop
  if (K3 === "A") { const c6 = fmod(t / 6, 1), out = c6 < 0.5, u = out ? ease(c6 / 0.5) : 1 - ease((c6 - 0.5) / 0.5), a = S(20.5, 8), b = S(11, 23), hd = Math.atan2(b[1] - a[1], b[0] - a[0]) + (out ? 0 : Math.PI); forklift(lerp(a, b, u), hd, k, fc, out ? cc(1) : null); }
  if (K3 === "B") { const q = S(17, 38); fill(q, rectPts(5.4, 4.6), [0.22, 0.22, 0.24, 1], 0, k); hazard(add(q, [0, -4.6 * k]), 0, k, -5, 5, 0, DOOR, 1); for (const sx of [-2.6, 2.6]) { forklift(add(q, [sx * k, 0.8 * k]), -Math.PI / 2, k, fc, null); glowDot(add(q, [sx * k, 4 * k]), 0.6 * k, [0.4, 1, 0.5, 0.6 + 0.4 * Math.sin(t * 3 + sx)]); } }
  if (K3 === "C") { const loop = [[12, 10], [22, 10], [22, 32], [12, 32]]; for (let i = 0; i < 4; i++) { const a2 = S(...loop[i]), b2 = S(...loop[(i + 1) % 4]); for (let j = 0; j < 8; j += 2) line(lerp(a2, b2, j / 8), lerp(a2, b2, (j + 1) / 8), A(DOOR, 0.6), 0.8 * k); }
    for (let c3 = 0; c3 < 3; c3++) { const u = fmod(t * 0.12 + c3 / 3, 1) * 4, i = Math.floor(u), a2 = loop[i], b2 = loop[(i + 1) % 4], q = S(...lerp(a2, b2, u - i)), hd = Math.atan2(b2[1] - a2[1], b2[0] - a2[0]); plate(q, rectPts(1.8, 1.3), fc, hd, k, 1); fill(add(q, rot([0.4 * k, 0], hd)), rectPts(0.9, 0.9), cc(c3), hd, k); } }
  // ---- step 4, the Loading Dock at the shed's end: a truck backed in, a rail siding with a wagon, or two trucks at levelled ramps
  if (K4 === "A") { plate(S(33, 25), rectPts(9, 1.2), CONC, 0, k, 1); hazard(S(33, 26.4), 0, k, -8, 8, 0, DOOR, 1); truck(S(33, 35), Math.PI / 2, k, fleet ? GOLD : [0.35, 0.45, 0.6, 1], 6); }
  if (K4 === "B") { plate(S(33, 25), rectPts(9, 1.2), CONC, 0, k, 1); for (const y of [36.6, 41.4]) { line(S(24, y), S(46, y), OUTLINE, 1.6 * k); line(S(24, y), S(46, y), METAL_L, 0.8 * k); } for (let x = 25; x < 46; x += 2.6) line(S(x, 35.4), S(x, 42.6), WOOD, 0.9 * k);
    const wx = 34 + Math.sin(t * 0.3) * 2; plate(S(wx, 39), rectPts(8.5, 4.4), fleet ? dk(GOLD, 0.2) : [0.5, 0.3, 0.22, 1], 0, k, 1.3); for (let j = -2; j <= 2; j++) line(S(wx + j * 3.4, 35.2), S(wx + j * 3.4, 42.8), A(OUTLINE, 0.5), 0.8 * k); }
  if (K4 === "C") for (const x of [28, 38]) { plate(S(x, 25), rectPts(3.6, 1.2), lt(CONC, 0.1), 0, k, 1); truck(S(x, 35), Math.PI / 2, k, fleet ? GOLD : [0.6, 0.35, 0.3, 1], 4.6); }
  surplus(S, B, k, stock); }
// ---- The crates (the base's 2x2 stack); the Surplus Retrofit (round 2, renamed from Weighbridge) adds two, to the left of the stack (round 3, the owner's note)
function surplus(S, B, k, stock) { crates(B.r === 2 ? S(0.8, 32) : S(4, 32), B.r === 2 ? 3 : 2, 2, k, stock); }
// ---- The Hammer Mill Retrofit (round 2, renamed from Second Crusher; the owner picked the hammer mill), by the belt's foot, with a chute onto the belt
function crusher2(S, B, t, k) { if (B.r !== 0) return; const R = B.key("r0"), p = S(-9, 27);
  bar(S(-13, 24), S(-18.8, 13.9), 2.6 * k, METAL);                                                                            // its chute onto the belt
  if (R === "A") { plate(p, rectPts(6, 4.6), METAL_L, 0, k, 1.3); fill(p, rectPts(4.6, 3.2), [0.1, 0.09, 0.09, 1], 0, k); const j = 1 + 2.6 * (0.5 + 0.5 * Math.sin(t * 4)); fill(add(p, [-4.6 * k, 0]), [[0, -3.2], [j, 0], [0, 3.2]], STEEL, 0, k); fill(add(p, [4.6 * k, 0]), [[0, -3.2], [-j, 0], [0, 3.2]], STEEL, 0, k); }
  if (R === "B") { plate(p, rectPts(6, 4.6), METAL_D, 0, k, 1.2); for (const sx of [-1, 1]) { const q = add(p, [sx * 2.8 * k, 0]); disc(q, 2.7 * k, OUTLINE); disc(q, 2.3 * k, METAL_L); for (let j = 0; j < 6; j++) line(q, add(q, mul(fa(t * 5 * sx + j * Math.PI / 3), 2.2 * k)), STEEL, 0.9 * k); } }
  if (R === "C") { plate(p, rectPts(6, 4.6), METAL_D, 0, k, 1.2); disc(p, 3.8 * k, OUTLINE); disc(p, 3.3 * k, METAL); for (let j = 0; j < 4; j++) { const a = t * 9 + j * Math.PI / 2; bar(p, add(p, mul(fa(a), 4 * k)), 1.1 * k, METAL_L); disc(add(p, mul(fa(a), 4 * k)), 0.9 * k, STEEL); } } }

// ---- The agent: Melt and Pour (embers, and at each payout the core flares and a coin fountain vents with the real income), the kill ring and the discount ring ---------
function scrapAgent(B) { return (m, t, info, s, col) => { if (!m.pays) { m.pays = []; m.last = t; m.kills = []; m.kt = t; }
  const L1 = B.lv[0], L2 = B.lv[1], L3 = B.lv[2], c = info.c, k = G(s), M = add(c, [0, -8 * k]), J = add(c, [-30 * k, 0]);
  if (t - m.last >= 4) { m.last = t; m.pays.push(t); } m.pays = m.pays.filter((q) => t - q < 1.6);
  for (let i = 0; i < 8; i++) { const q = t * 0.9 + i / 8, u = fmod(q, 1), dx = (rnd(Math.floor(q) * 7 + i) - 0.5) * s * 0.35; disc(add(M, [dx * u, -u * s * 0.55]), 1.4 * (1 - u) + 0.3, [1, 0.7, 0.3, 1 - u]); }
  if (L2 > 0) { const R = s * killR(B) / 48; ring(c, R, A(KILL, 0.2), 1.2); for (let i = 0; i < 24; i += 2) line(add(c, mul(fa(i * TAU / 24 + t * 0.03), R)), add(c, mul(fa((i + 1) * TAU / 24 + t * 0.03), R)), A(KILL, 0.34), 1.2); }
  if (L3 > 0) { const R = s * discR(B) / 48; ring(c, R, A(DISCC, 0.2), 1.2); for (let i = 1; i < 24; i += 2) line(add(c, mul(fa(i * TAU / 24 - t * 0.03), R)), add(c, mul(fa((i + 1) * TAU / 24 - t * 0.03), R)), A(DISCC, 0.34), 1.2); txt(add(c, [R * 0.7, -R * 0.7]), DOFF[L3], A(DISCC, 0.9), Math.max(10, s * 0.14)); }
  if (L2 > 0 && t - m.kt >= 1.7) { const near = info.all.filter((e) => !e.air && dist(e.p, c) < s * killR(B) / 48); if (near.length) { const e = near[Math.floor(rnd(Math.floor(t) + 1) * near.length)]; m.kills.push({ t0: t, p: e.p.slice() }); m.kt = t; } }
  m.kills = m.kills.filter((q) => t - q.t0 < 1);
  for (const q of m.kills) { const v = (t - q.t0) / 1, gc = L2 >= 5 ? GOLD : KILL; if (v < 0.25) { const r = Math.max(4, Math.min(11, s * 0.12)); glowDot(q.p, r * (1 - v / 0.25), [1, 0.9, 0.7, 1]); ring(q.p, r + v * 40, A(KILL, 1 - v / 0.25), 1.6); }
    const p = add(lerp(q.p, J, Math.min(1, v * 1.1)), [0, -Math.sin(Math.PI * Math.min(1, v)) * s * 0.4]); disc(p, s * 0.05 + 1, OUTLINE); disc(p, s * 0.05, gc);
    if (v < 0.55) txt(add(q.p, [0, -s * 0.22 - v * s * 0.3]), "+" + Math.round(5 * (1 + KBONUS[L2])), A(gc, 1 - v * 1.8), Math.max(9, s * 0.15)); }
  for (const q of m.pays) { const v = (t - q) / 1.6; if (v > 1) continue; if (v < 0.25) glowDot(M, s * 0.22 * (1 - v / 0.25), HOTM);
    for (let i = 0; i < 6; i++) { const d = fa(-Math.PI / 2 + (i - 2.5) * 0.35), p = add(add(M, mul(d, s * 0.5 * Math.min(1, v * 2))), [0, v * v * s * 0.4]); disc(p, s * 0.045 + 1, A(OUTLINE, 0.95 * (1 - v))); disc(p, s * 0.045, A(GOLD, 1 - v)); }
    txt(add(M, [0, -s * 0.4 - v * s * 0.5]), "+" + incomeOf(B), A(GOLD, Math.min(1, 2 - v * 2)), Math.max(11, s * 0.2));
    if (L1 >= 5 && v > 0.1) txt(add(M, [s * 0.5, -s * 0.25 - v * s * 0.4]), "+3%", A([0.8, 1, 0.6, 1], Math.min(1, 2 - v * 2)), Math.max(9, s * 0.14)); } }; }

// ---- The model: the whole production line at every level ---------------------------------------------------------------------------------------------------------------
const P2 = {
  tower: "scrap", look: "B", anim: "B", sBuild: 112, sCard: 64,                                  // a 2x2 tower: smaller previews so the whole yard fits
  intro: "Round 5: your note: the bridge magnet's rails now run on past the Hammer Mill (with end stops beyond it), so the rail plainly passes over the mill. Round 4: every stage is picked (the Laser Cutter is the Laser Gantry) and drawn as one build. Round 3: your notes. The Sorting Line becomes a Laser Cutter (same effect), with three ideas on the main belt: a laser gantry sweeping across the belt, a laser cutting table beside it, or a laser turret tracking the scrap; Surplus's two extra crates now stand to the left of the crate stack (the tow truck moved down a little to clear them). Everything else is picked. Round 2: your picks are drawn as one build. Your notes: Hydraulic Shear is now the Sorting Line, with three new ideas on the main belt (a picking gantry, a drum magnet or a sorting screen, each sorting scrap into three bins); the Second Crusher is now the Hammer Mill; the Bigger Yard is now Faster Loading (a second conveyor and crane feed the furnace from the top heap, taking turns with the main line), with three crane styles to pick; the Weighbridge is now Surplus (two more crates), with three ways to show them. Effects are unchanged. Each path rebuilds one part (the furnace stack, the junkyard, the warehouse); masteries are gold; overlapping Retrofits are kept and stack (the carpet rule). Unpicked stages show option A in the build preview.",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: scrapAgent(B) }; },
  muzzleAt(B, m, kk, c) { return c; },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), mm = fx.mem || {}, age = t - (mm.last ?? -9), S = (x, y) => add(c, [x * k, y * k]), g1 = B.lv[0] >= 5;
    yardFloor(c, k, col, t); dirt(c, -44, -44, -15, 44, k, 5);
    junkGround(S, B, t, k);
    wareModel(S, B, t, age, k);
    conveyor(S(10, -8), S(23, -8), t, k, g1);                                                      // the ingot belt, with ingots sliding to the warehouse (gold at the Gold Foundry)
    for (let i = 0; i < 2; i++) { const q = lerp(S(10, -8), S(23, -8), fmod(t * 0.35 + i / 2, 1)), ic = g1 ? GOLD : [0.82, 0.62, 0.45, 1]; fill(q, rectPts(2.2, 1.3), ic, 0, k); outline(q, rectPts(2.2, 1.3), OUTLINE, 1, 0, k); }
    const lid = stackModel(S, B, t, age, k);
    foundryExtra(S, B, t, k);
    crusher2(S, B, t, k);
    feedLine(S, B, t, k, lid, FEED, B.lv[1] > 1 ? B.key("p1s1") : null, true);
    if (B.r === 1) { const fk = B.key("r1"); feedLine(S, B, t, k, lid, FEED2, fk === "A" ? null : fk === "B" ? "A" : "C", false); }   // Faster Loading: the second line
    smoke(S(0, -8), STACKR[B.lv[0]], t, k, 6 + B.lv[0]);
  },
  paths: [], retrofits: [],
};

// ---- Option tables (the owner's names, 2026-10-19; effects and prices as confirmed) ----------------------------------------------------------------------------------
const T = (a, b, c) => [["A", ...a], ["B", ...b], ["C", ...c]].map(([key, name, desc]) => ({ key, name, desc }));
P2.paths = [
  { name: "Passive Income", theme: "the furnace stack: rebuilt around each step's machine and a little bigger each step; gold at the Gold Foundry", steps: [
    { name: "Firebrick Lining", cost: 525, effect: "130 per round", options: T(["Glowing Firebrick", "The stack is relined with a thick two-course firebrick shell; its joints glow orange with the heat."], ["Hex Refractory Tiles", "The stack is relined with pale hexagonal refractory tiles."], ["Double Wall", "The stack is rebuilt with a steel outer wall and a dark cooling gap; glowing slits show the fire inside."]) },
    { name: "Forced Bellows", cost: 1225, effect: "165 per round", options: T(["Twin Bellows", "Two big leather bellows on either side pump air into the stack, squeezing in turn."], ["Side Blower", "A fan housing bolted to the stack's side; its blades spin and a duct feeds the fire."], ["Bustle Pipe", "A thick pipe ring circles the stack, with eight tuyeres blowing air into it."]) },
    { name: "Blast Furnace", cost: 3850, effect: "220 per round (primary)", options: T(["Hot-Blast Stoves", "The stack is rebuilt taller as a blast furnace, with two round hot-blast stoves behind it piping in hot air; the bellows grow."], ["Skip Hoist", "The stack is rebuilt taller as a blast furnace; a skip car runs up an inclined hoist to a charging bell on its top."], ["Steel Frame", "The stack is rebuilt taller inside a square steel frame, with a downcomer pipe to a dust catcher."]) },
    { name: "Arc Furnace", cost: 7000, effect: "270 per round", options: T(["Electrode Lid", "The top is rebuilt as a domed lid with three graphite electrodes; arcs crackle between them, and the scrap drops in through a charging hole."], ["Tilting Vessel", "The top is rebuilt as a vessel that rocks gently, with three electrodes on arms from a mast; arcs spark down into it."], ["Plasma Ring", "Six electrodes ring the mouth and arc into a white-hot plasma core."]) },
    { name: "Gold Foundry", cost: 27440, effect: "320 per round, plus 3% interest on banked credits at each clear (mastery)", options: T(["Gold Shell", "The whole stack turns gold, with glints running round its rim; the ingots turn gold; each payout adds a +3% tag."], ["Gold Casting Wheel", "The stack turns gold and pours into a turning wheel of gold ingot moulds; each payout adds a +3% tag."], ["Gold Ladle", "The stack turns gold and a ladle pours a gold stream onto the ingot belt; each payout adds a +3% tag."]) },
  ] },
  { name: "Kill Income", theme: "the junkyard: rebuilt around each step's machine; the orange kill ring widens and wrecked enemies send coins into the junkyard; gold at the Breaker's Yard", steps: [
    { name: "Tow Hook", cost: 345, effect: "Enemies destroyed within 140 px pay 15% more", options: T(["Tow Truck", "A tow truck hauls the wreck into the yard on a cable, over and over."], ["Winch Post", "A winch post drags the wreck in on a cable; its drum turns."], ["Chain Gantry", "A gantry stands over the wreck and lifts it on a hook and chain."]) },
    { name: "Magnet Crane", cost: 625, effect: "+25%; 150 px", options: T(["Electromagnet", "The grab crane is rebuilt with a big round electromagnet that lifts the scrap."], ["Twin-Boom Magnet", "The crane is rebuilt heavier, with two booms carrying the magnet."], ["Bridge Magnet", "The crane is replaced by an overhead bridge spanning the junkyard; its trolley magnet carries the scrap to the belt."]) },
    { name: "Laser Cutter", cost: 2095, effect: "+35%; 170 px (primary)", options: T(["Laser Gantry", "A gantry straddles the main belt; its laser head sweeps across and cuts the scrap riding under it, in a spray of sparks."], ["Cutting Table", "A laser cutting table beside the main belt: a gantry head traces a glowing cut through a scrap plate."], ["Laser Turret", "A laser turret on a post beside the main belt tracks the scrap riding up and cuts it with a red beam."]) },
    { name: "Car Crusher", cost: 5720, effect: "+45%; 190 px", options: T(["Flat Press", "A press frame over the wreck flattens it again and again."], ["Baler", "A baler at the foot of the belt packs the scrap into cubes that ride up into the furnace."], ["Crushing Rollers", "Two rollers across the belt crush each piece flat on its way up."]) },
    { name: "Breaker's Yard", cost: 28945, effect: "+60%; 210 px; bosses pay double (mastery)", options: T(["Gold Crane", "The crane and every junkyard machine turn gold and the magnet glows; a gold x2 sign for bosses; the field coins turn gold."], ["Gold Heaps", "The machines turn gold and so do the scrap heaps; a gold x2 sign; the field coins turn gold."], ["Gold Fence", "The machines turn gold and a gold fence rings the junkyard; a gold x2 sign; the field coins turn gold."]) },
  ] },
  { name: "Discounts", theme: "the warehouse: rebuilt shorter, with a yard at its end, and around each step's machine; the blue discount ring widens and shows the percentage off; gold at the Parts Exchange", steps: [
    { name: "Parts Shelves", cost: 190, effect: "Towers within 140 px upgrade for 5% less", options: T(["Open-Roof Shelves", "The warehouse is rebuilt shorter with half its roof off, showing rows of parts shelves."], ["Shelf Lean-To", "The warehouse is rebuilt shorter, with a lean-to of parts shelves at its end."], ["Parts Cage", "The warehouse is rebuilt shorter, with a mesh parts cage in the yard by its doors."]) },
    { name: "Pallet Racks", cost: 495, effect: "10% off upgrades; 150 px", options: T(["High-Bay Racks", "The whole roof comes off: four rows of pallet racks loaded with coloured goods."], ["Pallet Stacks", "Stacked pallets of goods stand in the yard outside the doors."], ["Stacker Crane", "The roof comes off over open racks, with a stacker crane running up and down the aisle."]) },
    { name: "Forklift Bay", cost: 2035, effect: "15% off upgrades, 5% off builds; 160 px (primary)", options: T(["Forklift Run", "A forklift carries pallets out of the doors to the yard and drives back."], ["Charging Bay", "A charging bay with two forklifts parked at glowing chargers."], ["Automated Carts", "Three small carts run a painted loop through the yard."]) },
    { name: "Loading Dock", cost: 3865, effect: "20% off upgrades; 175 px", options: T(["Truck Dock", "A loading dock at the warehouse's end with a truck backed in."], ["Rail Siding", "A rail siding at the warehouse's end with a freight wagon."], ["Twin Ramps", "Two levelled ramps with a truck at each."]) },
    { name: "Parts Exchange", cost: 20935, effect: "25% off upgrades, 10% off builds; 190 px; towers in the field sell back for everything spent on them (mastery)", options: T(["Gold Roof", "The warehouse's frame and roof turn gold."], ["Gold Stock", "The frame turns gold and every shelf, pallet and crate is stocked in gold."], ["Gold Fleet", "The frame turns gold and so do the forklifts, carts and trucks."]) },
  ] },
];
P2.retrofits = [
  { name: "Hammer Mill", cost: 525, effect: "+30 income per round (stacks with the Passive Income path)", options: T(["Jaw Crusher", "A jaw crusher beside the foot of the belt chews scrap down a chute onto the belt."], ["Roller Crusher", "Two spinning rollers in a housing feed a chute onto the belt."], ["Hammer Mill", "A spinning hammer mill feeds a chute onto the belt."]) },
  { name: "Faster Loading", cost: 260, effect: "+30 px to its fields (stacks with the Kill and Discount paths)", options: T(["Second Grab Crane", "A second conveyor runs from the top heap into the furnace, loaded by a second grab crane; the two lines take turns, so the furnace is fed twice as often."], ["Second Magnet Crane", "The second conveyor is loaded by a second magnet crane, like the main one."], ["Second Bridge Magnet", "The second conveyor is loaded by a second overhead bridge magnet over the top heap."]) },
  { name: "Surplus", cost: 260, effect: "Towers sold in its field refund 15% more", options: [{ key: "A", name: "Crates to the Left", desc: "Two more crates stand to the left of the crate stack (your note)." }] },
];

// ---- Round 4 picks (owner, 2026-10-19): every stage picked (Laser Cutter A, the Laser Gantry); Surplus is the owner's note ------------------------------------------
P2.picks = { p0s0: "A", p0s1: "B", p0s2: "A", p0s3: "C", p0s4: "A", p1s0: "A", p1s1: "C", p1s2: "A", p1s3: "A", p1s4: "A", p2s0: "A", p2s1: "C", p2s2: "A", p2s3: "C", p2s4: "C", r0: "C", r1: "A", r2: "A" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { const pk = P2.picks["p" + pi + "s" + k]; if (pk) st.options = st.options.filter((o) => o.key === pk); }));
P2.retrofits.forEach((rf, ri) => { const pk = P2.picks["r" + ri]; if (pk) rf.options = rf.options.filter((o) => o.key === pk); });
