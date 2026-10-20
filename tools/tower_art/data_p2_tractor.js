// ---- Tower art second pass: Tractor Tower (tower 19), round 3 on the redesigned base (every stage picked; the dish wider and thinner; Beam Sweep) (the dish drawn flat, straight from above) ---------------------------------------------------------------------------
// Base (owner, 2026-10-19, after "I want to completely redesign the tractor tower from scratch"): look B Armoured Dish, animation B Focus Beam
// (tools/tower_art/data_tractor_looks.js). The mechanic, paths, effects and names stay. The owner chose the parts:
//  - Path 1, Pull Distance, rebuilds the EMITTER SPIKE (a lance, a fork or a coil spike; longer each step; a rewind coil from Rewind; gold at Undo).
//  - Path 2, Recharge, rebuilds the BASE and its rams with capacitors that light up as it recharges (a cell ring, capacitor rams or battery banks); gold with a
//    second small dish at Dual Beam.
//  - Path 3, Grip, is the effect's strength (the owner, earlier round): it rebuilds the DISH'S ENERGY (a glowing rim, focus rings, or a lattice field), matched
//    in the beam and in the hold round the enemy, stronger each step; gold at Gravity Hammer.
// Each step rebuilds its part in the style picked for that step (the new design replaces the old one); masteries are gold; the agent runs the real rules.
// The first Retrofit slot offers three replacements for Twin Emitter (the owner asked for something else): Stasis Wake, Beam Sweep or Shock Field.
// Overlaps kept and stacking (the carpet rule): Longer Hold's +0.5 s with Stronger Beam's hold, Faster Recharge's -1 s with the Recharge path.
const PAGE = { title: "Tractor Tower: paths and Retrofits (second pass)", store: "bl-tower-art-p2-tractor-d8" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], COPPER = [0.78, 0.5, 0.28, 1], LOCKC = [1, 0.85, 0.3, 1], ARMOUR = [0.36, 0.39, 0.44, 1], HOTG = [1, 0.92, 0.6, 1], STASIS = [0.6, 0.85, 1, 1];
const rnd = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const enemyR = (s) => Math.max(4, Math.min(11, s * 0.12));
const nearestTo = (p, list) => { let best = null, bd = 1e9; for (const e of list) { const d = dist(e.p, p); if (d < bd) { bd = d; best = e; } } return best; };
function txt(p, str, col, px) { X.save(); X.font = "bold " + Math.round(px) + "px sans-serif"; X.textAlign = "center"; X.fillStyle = css(OUTLINE); X.fillText(str, p[0] + 1, p[1] + 1); X.fillStyle = css(col); X.fillText(str, p[0], p[1]); X.restore(); }
const gl = (col, g, u) => (g ? mix(col, GOLD, u ?? 0.75) : col);
const pk = (B, path, L) => (L > 0 ? B.key("p" + path + "s" + (L - 1)) : null);   // the style picked for the latest step bought on a path
const BACK = [80, 100, 120, 150, 190, 230], REW = [0, 0, 0, 3, 4, 5], RECH = [6, 5.2, 4.6, 3.8, 3.3, 3.3], SLEN = [13.4, 14.6, 15.6, 16.6, 17.6, 18.6], BASER = [9.4, 9.8, 10.2, 10.7, 11.1, 11.5];
const holdOf = (B) => (B.lv[0] >= 2 ? 1.8 : 1.5) + (B.r === 1 ? 0.5 : 0), rechOf = (B) => RECH[B.lv[1]] - (B.r === 2 ? 1 : 0);
// Where each beam leaves: 0 the spike's tip; 2 Dual Beam's small dish (aimed at its own target)
const TWIN = { sc: 0.58, x: 1.5, y: 6.4 };   // Dual Beam's twin dishes: scale and offset of each
function muzzleOf(B, m, c, aim, k, mem) { const len = SLEN[B.lv[0]];
  if (B.lv[1] >= 5) { const side = m === 2 ? 1 : -1, a = mem?.twinA?.[side] ?? aim; return P(P(c, aim, k, TWIN.x, side * TWIN.y), a, k * TWIN.sc, len - 0.4, 0); }   // Dual Beam: from each twin dish's antenna, at the angle it was drawn
  return P(c, aim, k, len - 0.4, 0); }
// The dish seen from straight above (owner, 2026-10-19: the tilted dish looked out of place): a thick armoured band curved round its focus F, cupped toward
// the aim, with crisp outlines, segment lines and rivets, like the other towers' flat top-down parts
const DF = 10, DR = 10, DSPAN = 1.45, DW = 2;   // round 3 (owner): "Widen the dish and make it thinner"
const SB = DF - DR + DW / 2 - 0.2;   // round 4 (owner): the spike starts on the dish's inner face, on a mounting hub
// Round 5 (owner): "Make it look more like an antenna than a cone": a slim rod from the hub to a feed head, held by two thin struts from the dish
function antennaRod(c, aim, k, x1, rodCol, strutCol, w) { const Q = (x, y) => P(c, aim, k, x, y), F = Q(DF, 0), mid = Q(SB + (x1 - SB) * 0.62, 0);
  for (const sg of [-1, 1]) { const e = add(F, mul(fa(aim + Math.PI + sg * 0.75), (DR - DW / 2) * k)); line(e, mid, OUTLINE, 1.5 * k); line(e, mid, strutCol, 0.7 * k); }
  bar(Q(SB, 0), Q(x1, 0), (w || 1.1) * k, rodCol); }
function feedHead(q, k, col, glow, on) { disc(q, 1.7 * k, OUTLINE); disc(q, 1.3 * k, col); glowDot(q, (0.6 + 0.8 * on) * k, glow); }
function spikeHub(c, aim, k, col) { const q = P(c, aim, k, SB + 0.9, 0); plate(q, rectPts(1.1, 2.6), col, aim, k, 1.1); for (const sg of [-1, 1]) disc(P(c, aim, k, SB + 0.9, sg * 1.8), 0.45 * k, METAL_L); }
function dishArc(c, aim, k, armour, face, rivetCol) { const F = P(c, aim, k, DF, 0), a0 = aim + Math.PI - DSPAN, a1 = aim + Math.PI + DSPAN;
  arc(F, DR * k, a0, a1, OUTLINE, (DW + 1.6) * k); arc(F, DR * k, a0, a1, armour, DW * k); arc(F, (DR - DW * 0.28) * k, a0 + 0.04, a1 - 0.04, face, DW * 0.38 * k);
  for (let i = 0; i <= 6; i++) { const a = a0 + i * (a1 - a0) / 6; line(add(F, mul(fa(a), (DR - DW / 2) * k)), add(F, mul(fa(a), (DR + DW / 2) * k)), A(OUTLINE, 0.7), 0.8 * k); }
  for (let i = 0; i < 6; i++) { const a = a0 + (i + 0.5) * (a1 - a0) / 6; disc(add(F, mul(fa(a), (DR + DW * 0.28) * k)), 0.55 * k, rivetCol); }
  for (const a of [a0, a1]) { disc(add(F, mul(fa(a), DR * k)), (DW / 2 + 0.5) * k, OUTLINE); disc(add(F, mul(fa(a), DR * k)), DW / 2 * k, armour); }
  return F; }
const rimLine = (F, aim, k, col, w) => arc(F, (DR - DW / 2 - 0.3) * k, aim + Math.PI - DSPAN, aim + Math.PI + DSPAN, col, w * k);
const ell = (p, rx, ry, a, col, w) => { X.save(); X.strokeStyle = css(col); X.lineWidth = w; X.beginPath(); X.ellipse(p[0], p[1], Math.max(0.1, rx), Math.max(0.1, ry), a, 0, TAU); X.stroke(); X.restore(); };

// ---- Path 2, Recharge: the base and its rams, rebuilt each step with capacitors that light up as it recharges (a cell ring, capacitor rams, or battery banks) ------
function base(c, aim, k, B, t, col, ch) { const L = B.lv[1], st = pk(B, 1, L), g = L >= 5, r = BASER[L], gc = g ? GOLD : col, cap = gl(STEEL, g, 0.6), Q = (x, y) => P(c, aim, k, x, y);
  plate(c, ngon(10, 1, 0), gl(METAL, g, 0.45), aim, r * k, 1.3); rivets(c, ngon(10, 1, 0), aim, r * k, 0.84, 0.7 * k);
  if (st === "A") { const n = 8 + 2 * L, rr = r * 0.8; for (let i = 0; i < n; i++) { const a = aim + Math.PI + (i / (n - 1) - 0.5) * 2.7, q = add(c, mul(fa(a), rr * k)), lit = (i + 0.5) / n <= ch; plate(q, rectPts(0.8, 1.2 + 0.1 * L), lit ? gc : METAL_D, a, k, 0.8); if (lit) glowDot(q, 0.35 * k, gc); } }   // a ring of cells, lit in turn
  if (st === "C") { const n = [0, 1, 2, 3, 3, 4][L]; for (let i = 0; i < n; i++) { const q = Q(-r + 2.2, (i - (n - 1) / 2) * 4.4), lit = ch >= (i + 1) / (n + 0.01); plate(q, rectPts(1.9, 1.9), cap, aim, k, 1); plate(P(q, aim, k, -1.4, 0), rectPts(0.5, 0.9), lit ? gc : METAL_D, aim, k, 0.7); if (lit) glowDot(P(q, aim, k, 0.3, 0), 0.5 * k, gc); } }   // battery banks on the back
  if (L >= 4) for (const sg of [-1, 1]) { const q = Q(-r * 0.5, sg * r * 0.5); plate(q, rectPts(1.6, 0.5), [0.1, 0.1, 0.1, 1], aim + sg * 0.6, k, 0.8); fill(q, rectPts(1.2, 0.25), A(gc, 0.6 + 0.4 * Math.sin(t * 7 + sg)), aim + sg * 0.6, k); }   // Overclocked: glowing vents
  const nr = st === "B" ? [2, 2, 2, 3, 4, 4][L] : 2, ys = nr === 2 ? [-1, 1] : nr === 3 ? [-1, 0, 1] : [-1, -0.33, 0.33, 1], rw = 2.6 + (st === "B" ? 0.2 * L : 0);   // the rams (capacitor pistons in style B)
  for (const v of ys) { const a0 = Q(-6.5, 3.6 * v), a1 = Q(1, 4.4 * v); bar(a0, a1, rw * k, gl(METAL_D, g, 0.5)); bar(Q(-2.5, 4 * v), a1, 1.3 * k, gl(METAL_L, g, 0.6));
    if (st === "B") for (let j = 0; j < 3; j++) plate(lerp(a0, a1, 0.2 + j * 0.22), rectPts(0.45, rw * 0.55), ch * 3 > j + 0.5 ? gc : METAL_D, aim, k, 0.7); } }
function dualEmitter(c, aim, k, B, t, col, mm) { if (B.lv[1] < 5) return; const a2 = mm.aim2 ?? aim, q = P(c, aim, k, -4, -8.8), tip = add(q, mul(fa(a2), 4 * k));   // Dual Beam: a second small gold dish
  bar(q, tip, 1.2 * k, GOLD); const f2 = add(q, mul(fa(a2), 2.6 * k)); arc(f2, 2.6 * k, a2 + Math.PI - 1, a2 + Math.PI + 1, OUTLINE, 2.2 * k); arc(f2, 2.6 * k, a2 + Math.PI - 1, a2 + Math.PI + 1, dk(GOLD, 0.15), 1.4 * k); glowDot(tip, 0.7 * k, col); }   // a small flat gold dish

// ---- Path 3, Grip: the dish's energy, stronger each step, in crisp lines (a bright rim with emitter nodes, focus arcs closing on the focus, or hex cells along the band)
function dish(c, aim, k, B, t, col, on) { const L = B.lv[2], st = pk(B, 2, L), g = L >= 5, ec = g ? GOLD : col, arm = gl(ARMOUR, g, 0.5), a0 = aim + Math.PI - DSPAN, a1 = aim + Math.PI + DSPAN, ri = DR - DW / 2;
  const F = dishArc(c, aim, k, arm, lt(arm, 0.14), g ? GOLD : METAL_L);
  if (st === "C") { const n = 4 + 2 * L; for (let i = 0; i < n; i++) { const a = a0 + (i + 0.5) * (a1 - a0) / n; outline(add(F, mul(fa(a), DR * k)), ngon(6, 1, a), A(ec, 0.6 + 0.3 * Math.sin(t * 3 + i)), 0.7 * k, 0, Math.min(1.5, 10 / n) * k); } }   // hex cells along the band
  if (st === "B") { const n = 1 + Math.min(L, 3); for (let i = 0; i < n; i++) { const u = fmod(t * 0.8 + i / n, 1), r = (ri - 0.8) * (1 - 0.75 * u), sp = DSPAN * (1 - 0.3 * u); arc(F, r * k, aim + Math.PI - sp, aim + Math.PI + sp, A(ec, 0.35 + 0.55 * u), (0.8 + 0.12 * L) * k); } }   // focus arcs closing on the focus
  rimLine(F, aim, k, A(ec, 0.45 + 0.5 * on + 0.1 * Math.sin(t * 4)), 1.2 + (st === "A" ? 0.35 * L : st ? 0.12 * L : 0));
  if (st === "A") { const n = 2 + L; for (let i = 0; i < n; i++) { const q = add(F, mul(fa(a0 + (i + 0.5) * (a1 - a0) / n), (ri - 0.3) * k)); disc(q, (0.6 + 0.08 * L) * k, OUTLINE); glowDot(q, (0.4 + 0.06 * L) * k, ec); } } }   // emitter nodes along a brighter rim

// ---- Path 1, Pull Distance: the emitter spike, rebuilt each step (a lance, a fork, or a coil spike), longer each step; a rewind coil turns backwards from Rewind ------
function spike(c, aim, k, B, t, col, on) { const L = B.lv[0], st = pk(B, 0, L), g = L >= 5, len = SLEN[L], sc = gl(METAL_L, g, 0.75), Q = (x, y) => P(c, aim, k, x, y), tip = Q(len - 0.4, 0);
  if (st === "B") { const sp = 1.6 + 0.25 * L; antennaRod(c, aim, k, SB + 3, sc, gl(METAL_L, g, 0.6), 1.2); for (const sg of [-1, 1]) { bar(Q(SB + 2.6, sg * 0.4), Q(len - 0.6, sg * sp), 0.9 * k, sc); feedHead(Q(len - 0.6, sg * sp), k * 0.7, gl(METAL, g, 0.6), g ? GOLD : col, on); } spikeHub(c, aim, k, gl(METAL_D, g, 0.5));   // two slim prongs
    const pts = []; for (let j = 0; j <= 6; j++) { const x = len - 5 + j * 5 / 6; pts.push(Q(x, (j % 2 ? 1 : -1) * sp * 0.55 * (0.5 + 0.5 * rnd(j + Math.floor(t * 14))))); } polyline(pts, A(g ? GOLD : col, 0.4), 2.2 * k); polyline(pts, A([0.9, 1, 1, 1], 0.9), 0.7 * k); }   // a fork with a crackling arc
  else { antennaRod(c, aim, k, len - 0.8, sc, gl(METAL_L, g, 0.6)); spikeHub(c, aim, k, gl(METAL_D, g, 0.5));
    if (st === "A") for (let i = 0; i <= L; i++) { const x = SB + 2 + i * (len - SB - 5) / Math.max(1, L); plate(Q(x, 0), rectPts(0.45, 1.1), gl(STEEL, g, 0.6), aim, k, 0.8); }   // steel collars on the rod
    if (st === "C") { const n = 2 + L, lit = Math.floor(fmod(t * 4, n)); for (let i = 0; i < n; i++) { const x = SB + 2.5 + i * (len - SB - 5.5) / (n - 1); plate(Q(x, 0), rectPts(0.55, 1.25), i === lit ? (g ? HOTG : lt(col, 0.3)) : gl(COPPER, g, 0.7), aim, k, 0.8); } } }   // coils lit toward the tip
  if (L >= 3) { const q = Q(SB + (len - SB) * 0.5, 0), n = 1; for (let j = 0; j < n; j++) { const rr = 2.6 + 0.4 * (Math.min(L, 4) - 3), sp = -2.5 * t;   // the rewind coil (round 6, owner: at Undo it keeps Long Rewind's size, in gold)
      ring(q, rr * k, OUTLINE, 2 * k); ring(q, rr * k, g ? GOLD : lt(col, 0.2), 1.1 * k); for (let i = 0; i < 8; i++) { const a = sp + i * Math.PI / 4; line(add(q, mul(fa(a), rr * 0.55 * k)), add(q, mul(fa(a), rr * 0.85 * k)), g ? HOTG : col, 0.8 * k); } } }
  const nibG = g || B.lv[2] >= 5, nib = nibG ? GOLD : METAL, glow = nibG ? GOLD : col;   // round 6 (owner): the antenna's nib is gold at Gravity Hammer
  if (st !== "B") feedHead(tip, k, nib, glow, on);
  else if (nibG) for (const sg of [-1, 1]) feedHead(Q(len - 0.6, sg * (1.6 + 0.25 * L)), k * 0.7, nib, glow, on); }

// ---- The Retrofits: the Twin Emitter's replacement (a stasis coil, sweep vanes, or a shock node), Longer Hold's capacitor, Faster Recharge's cooling ---------------
function retroUnder(c, aim, k, B, t, col) { if (B.r === 1 && B.key("r1") === "A") { ring(c, 13 * k, OUTLINE, 3 * k); ring(c, 13 * k, METAL_D, 2 * k); for (let i = 0; i < 8; i++) { const a0 = i * TAU / 8 + 0.08; arc(c, 13 * k, a0, a0 + TAU / 8 - 0.16, A(col, 0.35 + 0.3 * Math.sin(t * 3 + i)), 1 * k); } }   // a hold capacitor ring
  if (B.r === 2 && B.key("r2") === "B") for (const sx of [-1, 1]) { const q = add(c, [sx * 14.4 * k, 7 * k]); plate(q, rectPts(2.6, 4.6), METAL_L, 0, k, 1); for (let j = -3; j <= 3; j++) line(add(q, [-2 * k, j * 1.2 * k]), add(q, [2 * k, j * 1.2 * k]), METAL_D, 0.6 * k); } }   // radiator panels
function retroOver(c, aim, k, B, t, col) { const r = BASER[B.lv[1]], Q = (x, y) => P(c, aim, k, x, y);
  if (B.r === 0) { const key = B.key("r0"), q = Q(-4, 8.6);
    if (key === "A") { disc(q, 3.2 * k, OUTLINE); disc(q, 2.7 * k, METAL_D); ring(q, 1.9 * k, A(STASIS, 0.6 + 0.3 * Math.sin(t * 3)), 1 * k); glowDot(q, 0.7 * k, STASIS); }   // a stasis coil
    if (key === "B") for (const sg of [-1, 1]) { const pts = [[0, -1], [3.4, 0], [0, 1]]; fill(Q(9.6, sg * 11.2), pts, METAL_L, aim, k); outline(Q(9.6, sg * 11.2), pts, OUTLINE, 0.8, aim, k); }   // sweep vanes at the dish's ends
    if (key === "C") { bar(q, Q(-4, 11.2), 0.9 * k, METAL); orb(Q(-4, 11.2), 1.6 * k, [0.55, 0.6, 0.75, 1]); for (let j = 0; j < 2; j++) { const a = rnd(Math.floor(t * 12) + j) * TAU; line(Q(-4, 11.2), add(Q(-4, 11.2), mul(fa(a), 2.4 * k)), A([0.8, 0.9, 1, 1], 0.8), 0.7 * k); } } }   // a shock node on a post
  if (B.r === 1) { const key = B.key("r1");
    if (key === "B") { const q = Q(-r - 1.6, 0); plate(q, rectPts(1.6, 3.6), METAL_D, aim, k, 1); for (let j = -2; j <= 2; j++) line(Q(-r - 2.6, j * 1.2), Q(-r - 0.6, j * 1.2), A(col, 0.5 + 0.3 * Math.sin(t * 3 + j)), 0.6 * k); }   // a hold battery
    if (key === "C") for (const x of [SB + 2.6, SB + 4.2]) plate(Q(x, 0), rectPts(0.6, 2.2), COPPER, aim, k, 0.9); }   // hold coils round the spike's base
  if (B.r === 2) { const key = B.key("r2");
    if (key === "A") for (let j = -3; j <= 3; j++) bar(Q(-r + 1, j * 1.5), Q(-r - 3.4, j * 2.1), 0.9 * k, METAL_L);   // cooling fins
    if (key === "C") { const q = Q(-r + 3, 6.6); disc(q, 2.8 * k, OUTLINE); disc(q, 2.4 * k, METAL_D); for (let j = 0; j < 4; j++) fill(q, [[0.4, -0.4], [2.1, -0.9], [2.1, 0.9], [0.4, 0.4]], METAL_L, t * 12 + j * Math.PI / 2, k); disc(q, 0.7 * k, METAL); } } }   // a fan vent

// ---- The agent: Focus Beam (a tight bright beam, rings sliding down it toward the dish, the enemy shaking in the grip), by Grip style and strength, with the real
// rules: the hold time, the pull or rewind, the recharge, Dual Beam's second beam, -15 crush, the lift-and-slam stun, the grip lock, the Undo, and the new Retrofit ----
function gripBeam(f, to, s, col, t, w, L3, st, g) { const c2 = g ? GOLD : col, d = norm(sub(to, f)), Lb = dist(f, to), a = Math.atan2(d[1], d[0]), bw = (1.6 + (st === "A" ? 0.35 * L3 : st ? 0.15 * L3 : 0)) * w;
  if (st === "C") { const o = orth(d); for (const sg of [-1, 1]) line(add(f, mul(o, sg * 2.5 * w)), add(to, mul(o, sg * (4 + 0.5 * L3) * w)), A(c2, 0.5), 1); for (let i = 1; i < 8; i++) { const p = add(f, mul(d, Lb * i / 8)), hw = (2.5 + (1.5 + 0.5 * L3) * i / 8) * w; line(add(p, mul(o, hw)), sub(p, mul(o, hw)), A(c2, 0.35), 0.8); } }   // a lattice sheath
  strip(f, to, bw, c2);
  const nr = 4 + (st === "B" ? L3 : 0), rs = st === "B" ? 1 + 0.12 * L3 : 1; for (let i = 0; i < nr; i++) { const q = 1 - fmod(t * 0.9 + i / nr, 1), p = add(f, mul(d, Lb * q)); ell(p, 2.4 * rs, 6.5 * rs * w, a, A(c2, 0.85), 1.4); } }
function gripBubble(p, s, col, t, L3, st, g) { const c2 = g ? GOLD : col, rr = enemyR(s) + 3 + (st ? 0.5 * L3 : 0);
  if (st === "A") disc(p, rr, A(c2, 0.08 + 0.03 * L3)); ring(add(p, [Math.sin(t * 40), 0]), rr, A(c2, 0.7), 1.2 + (st === "A" ? 0.35 * L3 : 0));
  if (st === "B") for (let i = 0; i < Math.min(L3, 3); i++) { const q = fmod(t * 0.8 + i / 3, 1); ring(p, rr * (1.7 - 0.7 * q), A(c2, 0.55 * q), 1.2); }
  if (st === "C") { outline(p, ngon(6, 1, t * 0.5), A(c2, 0.85), 1.4, 0, rr + 3); for (let i = 0; i < 4 + L3; i++) { const a = i * TAU / (4 + L3) + t * 0.5; line(add(p, mul(fa(a), rr - 2)), add(p, mul(fa(a), rr + 3)), A(c2, 0.6), 1); } } }
const segDist = (p, a, b) => { const ab = sub(b, a), u = Math.max(0, Math.min(1, ((p[0] - a[0]) * ab[0] + (p[1] - a[1]) * ab[1]) / (ab[0] * ab[0] + ab[1] * ab[1] || 1))); return dist(p, add(a, mul(ab, u))); };
function tractorAgent2(B) { return (m, t, info, s, col) => {
  const L1 = B.lv[0], L3 = B.lv[2], hold = holdOf(B), cool = 2.1 * rechOf(B) / 6, back = s * BACK[L1] / 48, range = s * 160 / 48, eR = enemyR(s);
  const beams = [{ f: 1, m: 0 }]; if (B.lv[1] >= 5) beams.push({ f: 1 / 3, m: 2 });
  const gst = pk(B, 2, L3), g3 = L3 >= 5, rk = B.r === 0 ? B.key("r0") : null; if (!m.wakes) m.wakes = [];
  if (!m.b || m.b.length !== beams.length) { m.b = beams.map(() => ({ state: "ready", t0: t })); m.slams = []; m.n = 0; }
  beams.forEach((bm, bi) => { const q = m.b[bi];
    if (q.state === "ready") { const used = m.b.filter((x) => x.state === "hold" || x.state === "drop").map((x) => x.id), e = nearestTo(info.c, info.ens.filter((x) => dist(x.p, info.c) < range && x.p[0] > s * 0.6 && !used.includes(x.i)));
      if (e) { Object.assign(q, { state: "hold", t0: t, id: e.i, p0: e.p.slice(), air: e.air, undo: false }); if (bi === 0) { m.n++; q.undo = L1 >= 5 && m.n % 3 === 0; } } }
    if (q.state === "hold" || q.state === "drop") { const e = info.all.find((x) => x.i === q.id); if (!e) { q.state = "cool"; q.t0 = t; return; }
      const u = Math.min(1, (t - q.t0) / hold), dx = Math.max(0, q.undo ? q.p0[0] - s * 0.5 : Math.min(back * bm.f, q.p0[0] - s * 0.5)), lift = L3 >= 3 && !q.air ? Math.max(0, Math.sin(Math.PI * Math.min(1, u * 1.1))) : 0;   // kept on the preview
      const held = add(q.p0, [-dx * ease(u), (q.air ? Math.sin(t * 6) * 2 : 0) - lift * s * 0.14]);
      if (q.state === "hold") { if (bi === 0) m.aimAt = held; if (bm.m === 2) m.at2 = held;
        disc(e.p, eR + 2, e.air ? [0.072, 0.093, 0.08, 0.92] : [0.16, 0.15, 0.13, 0.92]);                                                              // hide the real one: it's drawn where the beam drags it
        const from = info.muzzleAt(bm.m, info.aim); gripBeam(from, held, s, q.undo ? GOLD : col, t, beams.length > 1 ? 0.72 : 1, L3, gst, g3);   // a smaller beam from each twin dish at Dual Beam
        if (rk === "B") for (const o of info.all) if (o.i !== q.id && segDist(o.p, from, held) < eR + 8) { ring(o.p, eR + 4, A(STASIS, 0.7), 1.2); txt(add(o.p, [0, -eR - 6]), "-30%", A(STASIS, 0.9), Math.max(8, s * 0.11)); }   // Beam Sweep
        if (rk === "C") for (const o of info.all) if (o.i !== q.id && dist(o.p, held) < s * 40 / 48 + eR) { const pts = [held]; for (let j = 1; j < 5; j++) pts.push(add(lerp(held, o.p, j / 5), mul(orth(norm(sub(o.p, held))), (rnd(j + o.i + Math.floor(t * 18)) - 0.5) * 8))); pts.push(o.p); polyline(pts, A([0.8, 0.9, 1, 1], 0.85), 1); }   // Shock Field
        if (lift) ellipse(add(held, [0, lift * s * 0.14 + eR * 0.8]), eR * (1.2 - 0.3 * lift), eR * 0.45, [0, 0, 0, 0.35]);
        if (REW[L1] && bi === 0) { for (let i = 1; i <= 4; i++) { X.save(); X.globalAlpha = 0.22 - i * 0.04; drawEnemy({ ...e, p: lerp(held, q.p0, i / 5) }, s); X.restore(); }   // Rewind: a trail of past positions and a backwards clock
          const a0 = -t * 4; arc(held, eR + 9, a0, a0 + 4.6, A(q.undo ? GOLD : col, 0.85), 1.6); fill(add(held, mul(fa(a0), eR + 9)), [[0, -2.6], [2.6, 0], [0, 2.6]], A(q.undo ? GOLD : col, 0.85), a0 - Math.PI / 2, 1);
          txt(add(held, [0, -eR - 13]), q.undo ? "UNDO" : "-" + REW[L1] + "s", q.undo ? GOLD : lt(col, 0.3), Math.max(9, s * 0.14)); }
        else for (let i = 1; i <= 2; i++) { X.save(); X.globalAlpha = 0.25 / i; drawEnemy({ ...e, p: add(held, [i * 5, 0]) }, s); X.restore(); }
        drawEnemy({ ...e, p: held }, s);
        gripBubble(held, s, col, t, L3, gst, g3);
        if (L3 >= 2) { const v = fmod(t * 2 + bi * 0.3, 1); txt(add(held, [eR + 6, -eR - 2 - v * 10]), "-15", A([1, 0.6, 0.5, 1], 1 - v), Math.max(8, s * 0.12)); for (let j = 0; j < 3; j++) disc(add(held, mul(fa(rnd(Math.floor(t * 10) + j + bi) * TAU), eR + 2)), 1.1, [1, 0.85, 0.5, 1]); }   // Crushing Grip
        if (L3 >= 4) { const lq = add(held, [-eR - 7, -eR - 4]); fill(lq, rectPts(2.6, 2.2), LOCKC, 0, 1); outline(lq, rectPts(2.6, 2.2), OUTLINE, 1, 0, 1); arc(add(lq, [0, -2.2]), 1.8, Math.PI, TAU, LOCKC, 1.2); }   // Grip Lock
        if (u >= 1) { q.state = "drop"; q.t0 = t; q.final = held; if (rk === "A") m.wakes.push({ id: q.id, t0: t }); if (L3 >= 3 && !q.air) m.slams.push({ t0: t, p: held.slice(), r: s * (L3 >= 5 ? 80 : 50) / 48, stun: L3 >= 5 ? 0.8 : 0.4, g: L3 >= 5 }); } }
      else { const v = (t - q.t0) / 0.4; X.save(); X.globalAlpha = Math.max(0, 1 - v); drawEnemy({ ...e, p: q.final }, s); X.restore(); disc(e.p, eR + 2, A(e.air ? [0.072, 0.093, 0.08, 1] : [0.16, 0.15, 0.13, 1], 0.92 * Math.max(0, 1 - v))); if (v >= 1) { q.state = "cool"; q.t0 = t; } } }
    if (q.state === "cool") { if (bi === 0) m.aimAt = null; else m.at2 = null; if (t - q.t0 > cool) q.state = "ready"; } });
  m.wakes = m.wakes.filter((w) => t - w.t0 < 2.4); for (const w of m.wakes) { const e = info.all.find((x) => x.i === w.id); if (!e || t - w.t0 < 0.4) continue; const a = 1 - (t - w.t0 - 0.4) / 2; ring(e.p, eR + 4, A(STASIS, 0.8 * a), 1.6); txt(add(e.p, [0, -eR - 6]), "-40%", A(STASIS, a), Math.max(8, s * 0.11)); }   // Stasis Wake
  m.slams = m.slams.filter((sl) => t - sl.t0 < sl.stun + 0.6);
  for (const sl of m.slams) { const v = (t - sl.t0) / 0.5, sc = sl.g ? GOLD : col; if (v < 1) { ring(sl.p, sl.r * ease(v), A(sc, 1 - v), 3); disc(sl.p, sl.r * ease(v), A(sc, 0.1 * (1 - v))); if (sl.g) for (let j = 0; j < 8; j++) disc(add(sl.p, mul(fa(j * TAU / 8 + 0.3), sl.r * ease(v) * 0.8)), 1.6, A(GOLD, 1 - v)); }
    if (t - sl.t0 < sl.stun) for (const e of info.all) if (!e.air && dist(e.p, sl.p) < sl.r) for (let j = 0; j < 3; j++) disc(add(e.p, add([0, -eR - 4], mul(fa(t * 6 + j * TAU / 3), eR * 0.6))), 1.3, [1, 1, 0.6, 1]); }   // the slam's stun
  m.state = m.b[0].state; m.charge = m.b[0].state === "cool" ? Math.min(1, (t - m.b[0].t0) / cool) : m.b[0].state === "ready" ? 1 : 0; }; }

// ---- The model ----------------------------------------------------------------------------------------------------------------------------------------------------
const P2 = {
  tower: "tractor", look: "B", anim: "B",
  intro: "Round 8, your note (\"that can independently rotate\"): the twin dishes at Dual Beam each turn on their own pivot to face their own target, and face forward when idle. Round 7, your note (\"I meant two dishes\"): at Dual Beam the dish is rebuilt as two smaller dishes side by side, each with its own antenna, its own Grip energy and nib, each firing a smaller beam; the second holds another enemy at a third of the pull. Round 6, your notes: at Undo the rewind coil keeps Long Rewind's size (one gold coil); at Dual Beam the antenna ends in two nibs side by side and fires two smaller beams, the second holding another enemy (the separate small dish is gone); at Gravity Hammer the antenna's nib turns gold. Round 5, your note: the spike is now an antenna, not a cone: a slim rod from the hub to a feed head, held by two thin struts from the dish (the lance's collars and the coil spike's coils sit along the rod; the fork is two slim prongs with feed heads). Round 4, your note: the spike (the dish's antenna) now starts on the dish's inner face, bolted to a mounting hub, instead of floating in front of it. Round 3: every stage is picked (Pull Distance all A, the lance; Recharge all A, the cell ring; Grip all B, the focus rings; Beam Sweep, the hold capacitor ring, the fan vent) and drawn as one build. Your note: the dish is wider and thinner. Beam Sweep replaces Twin Emitter in the spec at 175 credits (proposed: the formula's step-1 price for about a 15% gain). Round 2, your note (the tilted dish looked out of place): the dish is redrawn flat, straight from above like the other towers: a thick armoured band cupped toward the target round its focus, with crisp outlines, segments and rivets; Grip's energy is drawn in crisp lines too (a brighter rim with emitter nodes, focus arcs closing on the focus, or hex cells along the band). Nothing else changed. Round 1 on the redesigned base, the Armoured Dish with the Focus Beam; the names and effects stay. Each path rebuilds one part, in the style you pick for each step, and the new design replaces the old one: Pull Distance rebuilds the emitter spike (a lance with steel collars, a fork with a crackling arc, or a coil spike lighting toward its tip; longer each step; a rewind coil turning backwards from Rewind; gold with two counter-turning coils at Undo); Recharge rebuilds the base and its rams with capacitors that light up as it recharges (a ring of cells, capacitor rams with charge bands, or battery banks; glowing vents from Overclocked Emitter; gold with a second small dish at Dual Beam); Grip is the effect's strength (your note): it rebuilds the dish's energy (a glowing rim, focus rings closing across the face, or a hex lattice field), matched in the beam (thicker, more rings, or a lattice sheath) and the hold round the enemy, stronger each step; gold at Gravity Hammer. The first Retrofit slot offers three replacements for Twin Emitter: Stasis Wake, Beam Sweep or Shock Field. The preview runs the real rules: the hold time, the pull (or the rewind with a trail of past positions and -3s, -4s, -5s; a gold UNDO every third grab at the mastery), the recharge, Dual Beam's second beam, -15 crush, the lift-and-slam stun ring, the padlock, and the new Retrofit's effect. Overlapping Retrofits are kept and stack (the carpet rule).",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: tractorAgent2(B) }; },
  muzzleAt(B, m, kk, c, aim, s, info) { return muzzleOf(B, m, c, aim, G(s), info?.view?.mem); },
  model(c, aim, s, fx, t, col, info, B) { const k = G(s), mm = fx.mem || {}, on = mm.state === "hold" ? 1 : 0, ch = mm.charge ?? 1;
    deck(c, k, col, t);
    retroUnder(c, aim, k, B, t, col);
    base(c, aim, k, B, t, col, ch);
    if (B.lv[1] >= 5) { mm.twinA = mm.twinA || {}; for (const sg of [-1, 1]) { const c2 = P(c, aim, k, TWIN.x, sg * TWIN.y), tg = sg < 0 ? mm.aimAt : mm.at2, a = tg ? Math.atan2(tg[1] - c2[1], tg[0] - c2[0]) : aim;   // Dual Beam: two smaller dishes side by side (round 7),
      mm.twinA[sg] = a; disc(c2, 2.2 * k, OUTLINE); disc(c2, 1.7 * k, METAL_D); dish(c2, a, k * TWIN.sc, B, t, col, sg < 0 ? on : (mm.at2 ? 1 : 0)); spike(c2, a, k * TWIN.sc, B, t, col, sg < 0 ? on : (mm.at2 ? 1 : 0)); } }   // each turning on its own pivot to face its own target (round 8)
    else { dish(c, aim, k, B, t, col, on); spike(c, aim, k, B, t, col, on); }
    retroOver(c, aim, k, B, t, col);
    },
  paths: [], retrofits: [],
};

// ---- Option tables (names and effects as in design/tower_roster.md) ----------------------------------------------------------------------------------------------
const T = (a, b, c) => [["A", ...a], ["B", ...b], ["C", ...c]].map(([key, name, desc]) => ({ key, name, desc }));
P2.paths = [
  { name: "Pull Distance", theme: "the emitter spike: rebuilt each step in the style you pick (a lance, a fork, or a coil spike), longer each step; a rewind coil from Rewind; gold at Undo", steps: [
    { name: "Longer Haul", cost: 185, effect: "100 px pull", options: T(["Lance Spike", "The spike is rebuilt longer and slimmer, ringed with steel collars."], ["Forked Spike", "The spike splits into two prongs with an arc crackling between them."], ["Coil Spike", "The spike is wound with copper coils that light in turn toward the tip."]) },
    { name: "Stronger Beam", cost: 535, effect: "120 px; holds 1.8 s", options: T(["Long Lance", "Longer, with more collars."], ["Wide Fork", "Longer prongs, spread wider."], ["Long Coil Spike", "Longer, with more coils."]) },
    { name: "Rewind", cost: 1840, effect: "Sends the enemy back to where it was 3 s ago (primary)", options: T(["Rewind Lance", "Longer again, with a rewind coil turning backwards round it; the held enemy leaves a trail of its past positions and shows -3s."], ["Rewind Fork", "Longer prongs and the rewind coil; the trail and -3s."], ["Rewind Coil Spike", "More coils and the rewind coil; the trail and -3s."]) },
    { name: "Long Rewind", cost: 2945, effect: "Back 4 s", options: T(["Long Rewind Lance", "Longer, with a bigger rewind coil (-4s)."], ["Long Rewind Fork", "Longer, with a bigger rewind coil (-4s)."], ["Long Rewind Coil Spike", "Longer, with a bigger rewind coil (-4s)."]) },
    { name: "Undo", cost: 9215, effect: "Back 5 s; once per round, sends one non-boss enemy back to the start of its current track segment (mastery)", options: T(["Gold Lance", "A gold antenna with a gold rewind coil (Long Rewind's size); every third grab is a gold UNDO."], ["Gold Fork", "A gold fork with a gold arc and a gold rewind coil; the gold UNDO."], ["Gold Coil Spike", "Gold coils and a gold rewind coil; the gold UNDO."]) },
  ] },
  { name: "Recharge", theme: "the base and its rams: rebuilt each step with capacitors in the style you pick (a cell ring, capacitor rams, or battery banks) that light up as it recharges; gold with a second small dish at Dual Beam", steps: [
    { name: "Quick Release", cost: 175, effect: "Recharge 5.2 s", options: T(["Cell Ring", "A ring of capacitor cells round the back of the base lights up cell by cell as it recharges."], ["Capacitor Rams", "The rams are rebuilt as capacitor pistons whose charge bands fill as it recharges."], ["Battery Bank", "A battery on the base's back lights up when charged."]) },
    { name: "Capacitor Bank", cost: 345, effect: "4.6 s", options: T(["Bigger Cell Ring", "More cells on a bigger base."], ["Heavier Rams", "Thicker capacitor rams on a bigger base."], ["Two Batteries", "Two batteries, lighting in turn."]) },
    { name: "Rapid Lock", cost: 1265, effect: "3.8 s (primary)", options: T(["Full Cell Ring", "More cells again."], ["Three Rams", "Three capacitor rams."], ["Three Batteries", "Three batteries."]) },
    { name: "Overclocked Emitter", cost: 2200, effect: "3.3 s", options: T(["Vented Cell Ring", "More cells, and glowing vents in the base."], ["Four Rams, Vented", "Four capacitor rams and glowing vents."], ["Vented Batteries", "Three batteries and glowing vents."]) },
    { name: "Dual Beam", cost: 10035, effect: "A second beam on another enemy, at a third of the pull (mastery)", options: T(["Gold Cell Ring", "A gold base with gold cells; the dish is rebuilt as two smaller dishes side by side, each turning on its own pivot to face its own target, each with its own antenna and smaller beam; the second holds another enemy."], ["Gold Rams", "Four gold capacitor rams, and the twin dishes with their smaller beams."], ["Gold Batteries", "Four gold batteries, and the twin dishes with their smaller beams."]) },
  ] },
  { name: "Grip", theme: "the effect's strength (your note: not a physical claw or clamp): the dish's energy, matched in the beam and in the hold round the enemy, in the style you pick (a glowing rim, focus rings, or a lattice field), stronger each step; gold at Gravity Hammer", steps: [
    { name: "Firm Grip", cost: 190, effect: "Heavy roles resist half as much", options: T(["Glowing Rim", "The dish's rim glows brighter, with a halo; the beam thickens; the held enemy sits in a glowing ring."], ["Focus Rings", "Rings of light close inward across the dish; more rings slide down the beam and close round the held enemy."], ["Lattice Field", "A hex energy lattice spreads over the dish; the beam gets a lattice sheath and the held enemy a turning cage."]) },
    { name: "Crushing Grip", cost: 270, effect: "The held enemy takes 15 energy damage/s", options: T(["Burning Rim", "A brighter, wider rim and a thicker beam; the held enemy throws sparks and -15s."], ["Tight Focus Rings", "More rings, closing tighter; sparks and -15s."], ["Dense Lattice", "A denser lattice and cage; sparks and -15s."]) },
    { name: "Lift and Drop", cost: 1075, effect: "Ground enemies are lifted, then slammed down, stunning everything within 50 px for 0.4 s (primary)", options: T(["Blazing Rim", "The rim blazes; held ground enemies rise, then slam down in a stunning ring."], ["Lifting Rings", "Four rings; the lift and the slam ring."], ["Lifting Lattice", "A finer lattice; the lift and the slam ring."]) },
    { name: "Grip Lock", cost: 1610, effect: "The held enemy's barrier and abilities switch off while held", options: T(["Locked Rim", "The widest rim; held enemies show a padlock (barrier and abilities off)."], ["Locked Rings", "Five rings; the padlock."], ["Locked Lattice", "The finest lattice; the padlock."]) },
    { name: "Gravity Hammer", cost: 5365, effect: "The slam stuns everything within 80 px for 0.8 s and shatters barriers (mastery)", options: T(["Gold Rim", "A gold rim and beam, and the antenna's nib turns gold; the slam ring turns gold, wider, with barrier shards."], ["Gold Rings", "Gold focus rings, and the antenna's nib turns gold; the gold slam."], ["Gold Lattice", "A gold lattice and cage, and the antenna's nib turns gold; the gold slam."]) },
  ] },
];
P2.retrofits = [
  { name: "Beam Sweep", cost: 175, effect: "While holding, the beam slows every other enemy it crosses by 30% (replaces Twin Emitter; your pick)", options: T(["Stasis Wake", "After release, the enemy stays slowed 40% for 2 s (a -40% ring follows it). A stasis coil on the base's side."], ["Beam Sweep", "While holding, the beam slows every other enemy it crosses by 30%. Sweep vanes on the dish's rim."], ["Shock Field", "The held enemy shocks every enemy within 40 px for 10 damage/s. A shock node on a post on the base."]) },
  { name: "Longer Hold", cost: 140, effect: "Holds for 2 s (+0.5 s, stacks with Stronger Beam)", options: T(["Hold Capacitor Ring", "A glowing capacitor ring on the deck round the base."], ["Hold Battery", "A battery pack on the base's back."], ["Hold Coils", "Two copper coils round the spike's base."]) },
  { name: "Faster Recharge", cost: 230, effect: "Recharges in 5 s (-1 s, stacks with Recharge)", options: T(["Cooling Fins", "Cooling fins fanned out at the base's back."], ["Radiator Panels", "Two radiator panels on the deck."], ["Fan Vent", "A spinning fan vent on the base."]) },
];

// ---- Round 3 picks (owner, 2026-10-19): every stage picked; Beam Sweep replaces Twin Emitter ---------------------------------------------------------------
P2.picks = { p0s0: "A", p0s1: "A", p0s2: "A", p0s3: "A", p0s4: "A", p1s0: "A", p1s1: "A", p1s2: "A", p1s3: "A", p1s4: "A", p2s0: "B", p2s1: "B", p2s2: "B", p2s3: "B", p2s4: "B", r0: "B", r1: "A", r2: "C" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { const pk = P2.picks["p" + pi + "s" + k]; if (pk) st.options = st.options.filter((o) => o.key === pk); }));
P2.retrofits.forEach((rf, ri) => { const pk = P2.picks["r" + ri]; if (pk) rf.options = rf.options.filter((o) => o.key === pk); });
