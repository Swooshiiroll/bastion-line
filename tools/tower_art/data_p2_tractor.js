// ---- Tower art second pass: Tractor Tower (tower 19), round 2 ----------------------------------------------------------------------------------------------------
// Base: look C Claw Emitter, animation C Spiral Lock (tools/tower_art/data_towers4.js). The owner kept the names and chose the parts (2026-10-19):
//  - Path 1, Pull Distance, rebuilds the BARREL (banded, lens or rail barrel; longer each step; a rewind coil from Rewind; gold at Undo).
//  - Path 2, Recharge, rebuilds the TURRET BODY with capacitors (drums, a cell ring or coil banks) that light up as it recharges; gold with a second emitter at Dual Beam.
//  - Path 3, Grip, is the STRENGTH OF THE EFFECT, not a physical part (round 2, owner): it rebuilds the beam, the lock bubble round the held enemy and the
//    emitter core between the claws (a braided beam, gravity rings, or a lattice cage), stronger each step; gold at Gravity Hammer. The base's claws stay as they were.
// Round 2 (owner's notes): Pull Distance gets four new ideas beside the picked banded barrel; Twin Emitter is replaced by one of three new Retrofit ideas.
// Each step rebuilds its part in the style picked for that step (the new design replaces the old one); masteries are gold; the agent runs the real rules (the hold
// time, the pull or rewind, the recharge, a second and third beam, the crush damage, the lift-and-slam stun, the grip lock, the once-a-round Undo).
// Overlaps kept and stacking (the carpet rule): Longer Hold's +0.5 s with Stronger Beam's hold, Faster Recharge's -1 s with the Recharge path.
const PAGE = { title: "Tractor Tower: paths and Retrofits (second pass)", store: "bl-tower-art-p2-tractor-r2" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], COPPER = [0.78, 0.5, 0.28, 1], LOCKC = [1, 0.85, 0.3, 1];
const rnd = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const enemyR = (s) => Math.max(4, Math.min(11, s * 0.12));
const nearestTo = (p, list) => { let best = null, bd = 1e9; for (const e of list) { const d = dist(e.p, p); if (d < bd) { bd = d; best = e; } } return best; };
function txt(p, str, col, px) { X.save(); X.font = "bold " + Math.round(px) + "px sans-serif"; X.textAlign = "center"; X.fillStyle = css(OUTLINE); X.fillText(str, p[0] + 1, p[1] + 1); X.fillStyle = css(col); X.fillText(str, p[0], p[1]); X.restore(); }
const gl = (col, g, u) => (g ? mix(col, GOLD, u ?? 0.75) : col);
const pk = (B, path, L) => (L > 0 ? B.key("p" + path + "s" + (L - 1)) : null);   // the style picked for the latest step bought on a path
const BACK = [80, 100, 120, 150, 190, 230], REW = [0, 0, 0, 3, 4, 5], RECH = [6, 5.2, 4.6, 3.8, 3.3, 3.3], BLEN = [12, 14, 15.5, 17, 18, 19], BODY = [8, 8.4, 8.8, 9.3, 9.7, 10];
const holdOf = (B) => (B.lv[0] >= 2 ? 1.8 : 1.5) + (B.r === 1 ? 0.5 : 0), rechOf = (B) => RECH[B.lv[1]] - (B.r === 2 ? 1 : 0);
// Where each beam leaves: 0 the main barrel (between the claws), 1 the Twin Emitter, 2 Dual Beam's second emitter (aimed at its own target)
function muzzleOf(B, m, c, aim, k, aim2) { const len = BLEN[B.lv[0]];
  if (m === 1) { const key = B.key("r0"); return key === "B" ? P(c, aim, k, -2.5, 6.4) : key === "C" ? P(c, aim, k, 12.4, -6.2) : P(c, aim, k, 12.4, 6.2); }
  if (m === 2) return add(P(c, aim, k, -3, -7), mul(fa(aim2 ?? aim), 4.4 * k));
  return P(c, aim, k, len + 4, 0); }

// ---- Path 2, Recharge: the turret body, rebuilt each step with capacitors that light up as it recharges (drums, a cell ring, or coil banks) -------------------------
function body(c, aim, k, B, t, col, ch, mm) { const L = B.lv[1], st = pk(B, 1, L), g = L >= 5, r = BODY[L], gc = g ? GOLD : col, cap = gl(STEEL, g, 0.6);
  if (st === "B") { const n = 6 + 2 * L, rr = r + 1.8; ring(c, rr * k, OUTLINE, (2.6 + 0.2 * L) * k); for (let i = 0; i < n; i++) { const a0 = aim + Math.PI + i * TAU / n + 0.05, a1 = a0 + TAU / n - 0.1; arc(c, rr * k, a0, a1, (i + 0.5) / n <= ch ? gc : METAL_D, (1.6 + 0.2 * L) * k); } }   // a ring of cells, lighting cell by cell
  plate(c, ngon(8, 1, Math.PI / 8), gl(METAL_L, g, 0.45), aim, r * k, 1.2); rivets(c, ngon(8, 1, Math.PI / 8), aim, r * k, 0.82, 0.7 * k);
  if (L >= 4) for (const sg of [-1, 1]) { const q = P(c, aim, k, -r * 0.62, sg * r * 0.42); plate(q, rectPts(1.6, 0.5), [0.1, 0.1, 0.1, 1], aim, k, 0.8); fill(q, rectPts(1.2, 0.25), A(gc, 0.6 + 0.4 * Math.sin(t * 7 + sg)), aim, k); }   // Overclocked: glowing vents
  if (st === "A") { const n = [0, 2, 2, 3, 4, 4][L], dr = 1.8 + 0.25 * L; for (let i = 0; i < n; i++) { const q = P(c, aim, k, -r * 0.42, (i - (n - 1) / 2) * dr * 2.3), lit = Math.min(1, Math.max(0, ch * n - i));
      disc(q, (dr + 0.6) * k, OUTLINE); disc(q, dr * k, cap); ring(q, dr * 0.75 * k, dk(cap, 0.3), 0.6 * k); disc(q, dr * 0.55 * k, mix(METAL_D, gc, lit)); if (lit >= 1) glowDot(q, 0.5 * k, gc); } }   // capacitor drums on the back
  if (st === "C") { const n = [0, 1, 1, 2, 2, 3][L], h = 1.8 + 0.25 * L; for (const sg of [-1, 1]) for (let i = 0; i < n; i++) { const q = P(c, aim, k, -1 - i * 4.4, sg * (r + 1.4)), lit = ch >= (i + 1) / (n + 0.01);
      plate(q, rectPts(1.9, h), cap, aim, k, 1); for (let j = -1; j <= 1; j++) line(P(q, aim, k, j * 0.9, -h + 0.4), P(q, aim, k, j * 0.9, h - 0.4), gl(COPPER, g, 0.6), 0.6 * k); if (lit) glowDot(q, 0.6 * k, gc); } }   // coil banks on the sides
  if (g) { const a2 = mm.aim2 ?? aim, q = P(c, aim, k, -3, -7), tip = add(q, mul(fa(a2), 4.4 * k)); disc(q, 2.8 * k, OUTLINE); disc(q, 2.3 * k, dk(GOLD, 0.2)); bar(q, tip, 1.5 * k, GOLD); glowDot(tip, 0.7 * k, col); } }   // Dual Beam: a second gold emitter

// ---- Path 1, Pull Distance: the barrel, rebuilt each step, longer each step: banded (A, the round 1 pick) or one of four new ideas (round 2): telescoping
// sleeves (D), a dish emitter (E), a coil barrel (F) or forked prongs (G); a rewind coil turns backwards at its tip from Rewind; gold at Undo
function barrel(c, aim, k, B, t, col) { const L = B.lv[0], st = pk(B, 0, L), g = L >= 5, len = BLEN[L], bc = gl(METAL, g, 0.7), bl = g ? GOLD : METAL_L, Q = (x, y) => P(c, aim, k, x, y);
  if (!st) { bar(c, Q(len, 0), 4 * k, METAL); return; }
  if (st === "A") { bar(c, Q(len, 0), (4 + 0.2 * L) * k, bc); for (let i = 0; i <= L; i++) plate(Q(5 + i * (len - 7) / L, 0), rectPts(0.7, 2.6 + 0.12 * L), bl, aim, k, 0.9); }
  if (st === "D") { const n = 1 + Math.min(L, 4); for (let i = 0; i < n; i++) { const x0 = 2 + i * (len - 2) / n, x1 = 2 + (i + 1) * (len - 2) / n, w = 5.2 - i * 0.6; bar(Q(x0, 0), Q(x1, 0), w * k, i % 2 ? lt(bc, 0.08) : bc); plate(Q(x1 - 0.4, 0), rectPts(0.6, w * 0.62), bl, aim, k, 0.9); } }   // telescoping sleeves
  if (st === "E") { const fq = Q(len - 1, 0), dr = 4 + 0.7 * L, back = add(fq, mul(fa(aim + Math.PI), dr * k)); bar(c, back, 3.4 * k, bc);
    for (const sg of [-1, 1]) bar(add(fq, mul(fa(aim + Math.PI + sg * 1.05), dr * k)), fq, 0.8 * k, bl);
    arc(fq, dr * k, aim + Math.PI - 1.15, aim + Math.PI + 1.15, OUTLINE, 3.4 * k); arc(fq, dr * k, aim + Math.PI - 1.15, aim + Math.PI + 1.15, gl(METAL_L, g, 0.7), 2.2 * k); arc(fq, (dr - 0.6) * k, aim + Math.PI - 0.9, aim + Math.PI + 0.4, A([1, 1, 1, 0.5], 0.6), 0.7 * k);
    bar(back, fq, 1 * k, bc); glowDot(fq, 0.8 * k, g ? GOLD : col); }   // a parabolic dish with a feed horn at its focus
  if (st === "F") { bar(c, Q(len, 0), 3.4 * k, bc); const n = 2 + L, lit = Math.floor(fmod(t * 4, n)); for (let i = 0; i < n; i++) { const q = Q(4 + i * (len - 5) / (n - 1), 0); plate(q, rectPts(0.9, 2.9), i === lit ? (g ? HOTG : lt(col, 0.3)) : gl(COPPER, g, 0.7), aim, k, 0.9); } }   // coils pulsing toward the muzzle
  if (st === "G") { plate(Q(3, 0), rectPts(2.4, 2.6), bc, aim, k, 1.1); const sp = 2 + 0.3 * L; for (const sg of [-1, 1]) bar(Q(3, sg * 1.4), Q(len, sg * sp), 1.7 * k, bc);
    const pts = []; for (let j = 0; j <= 6; j++) { const x = len - 5 + j * 5 / 6; pts.push(Q(x, (j % 2 ? 1 : -1) * sp * 0.6 * (0.5 + 0.5 * rnd(j + Math.floor(t * 14))))); } polyline(pts, A(g ? GOLD : col, 0.4), 2.2 * k); polyline(pts, A([0.9, 1, 1, 1], 0.9), 0.7 * k); }   // forked prongs with a crackling arc
  if (L >= 3) { const q = Q(len - 3.6, 0), n = g ? 2 : 1; for (let j = 0; j < n; j++) { const rr = 3 + 0.4 * (L - 3) + j * 1.4, sp = (j ? 3 : -2.5) * t;   // the rewind coil (two counter-turning gold ones at Undo)
      ring(q, rr * k, OUTLINE, 2 * k); ring(q, rr * k, g ? GOLD : lt(col, 0.2), 1.1 * k); for (let i = 0; i < 8; i++) { const a = sp + i * Math.PI / 4; line(add(q, mul(fa(a), rr * 0.55 * k)), add(q, mul(fa(a), rr * 0.85 * k)), g ? HOTG : col, 0.8 * k); } } } }
const HOTG = [1, 0.92, 0.6, 1];

// ---- The base's three claws (they close on a hold), and Path 3, Grip, as the effect's strength: the emitter core between the claws grows each step, in the
// grip style picked (a braided swirl, gravity rings, or a lattice cage); gold at Gravity Hammer. The beam and the bubble are drawn by the agent (gripBeam, gripBubble).
function claws(c, aim, k, B, t, col, held) { const L = B.lv[2], st = pk(B, 2, L), g = L >= 5, len = BLEN[B.lv[0]], Q = (x, y) => P(c, aim, k, x, y), cc = g ? GOLD : col;
  for (const sg of [-1, 0, 1]) bar(Q(len - 1, sg * 2.6), Q(len + 5 - held, sg * (3.6 - 2.4 * held)), 1.3 * k, METAL_L);
  const q = Q(len + 2.6, 0), cr = 0.8 + 0.3 * L; glowDot(q, (cr + 0.2 * Math.sin(t * 6)) * k, cc);
  if (st === "A") for (let i = 0; i < 1 + Math.ceil(L / 2); i++) { const a0 = t * 5 + i * TAU / (1 + Math.ceil(L / 2)); arc(q, (cr + 1.4) * k, a0, a0 + 1.4, A(cc, 0.8), 0.8 * k); }   // a braided swirl
  if (st === "B") for (let i = 0; i < Math.min(L, 3); i++) { const u = fmod(t * 0.8 + i / 3, 1); ring(q, (cr + 3.6 * (1 - u)) * k, A(cc, 0.6 * u), 0.8 * k); }   // gravity rings closing in
  if (st === "C") outline(q, ngon(6, 1, t * 0.6), A(cc, 0.85), 0.9 * k, 0, (cr + 1.6) * k); }   // a small lattice cage

// ---- The Retrofits: the Twin Emitter's second barrel, Longer Hold's capacitor, Faster Recharge's cooling ------------------------------------------------------------
function retroUnder(c, aim, k, B, t, col) { if (B.r === 1 && B.key("r1") === "A") { ring(c, 12.6 * k, OUTLINE, 3 * k); ring(c, 12.6 * k, METAL_D, 2 * k); for (let i = 0; i < 8; i++) { const a0 = i * TAU / 8 + 0.08; arc(c, 12.6 * k, a0, a0 + TAU / 8 - 0.16, A(col, 0.35 + 0.3 * Math.sin(t * 3 + i)), 1 * k); } }   // a hold capacitor ring on the deck
  if (B.r === 2 && B.key("r2") === "B") for (const sx of [-1, 1]) { const q = add(c, [sx * 14 * k, 7 * k]); plate(q, rectPts(2.6, 4.6), METAL_L, 0, k, 1); for (let j = -3; j <= 3; j++) line(add(q, [-2 * k, j * 1.2 * k]), add(q, [2 * k, j * 1.2 * k]), METAL_D, 0.6 * k); } }   // radiator panels on the deck
function retroOver(c, aim, k, B, t, col, held) { const r = BODY[B.lv[1]], Q = (x, y) => P(c, aim, k, x, y);
  if (B.r === 0) { const key = B.key("r0"), q = Q(-2.5, 6.4);                                                     // round 2: the replacement for Twin Emitter
    if (key === "A") { disc(q, 3.2 * k, OUTLINE); disc(q, 2.7 * k, METAL_D); ring(q, 1.9 * k, A([0.6, 0.85, 1, 1], 0.6 + 0.3 * Math.sin(t * 3)), 1 * k); glowDot(q, 0.7 * k, [0.6, 0.85, 1, 1]); }   // a stasis coil
    if (key === "B") for (const sg of [-1, 1]) fill(Q(4.5, sg * 3), [[-1.8, 0], [1.6, -0.4 * sg], [1.2, 1.4 * sg], [-1.6, 0.8 * sg]], METAL_L, aim, k);   // sweep vanes on the barrel
    if (key === "C") { bar(q, Q(-2.5, 9.4), 0.9 * k, METAL); orb(Q(-2.5, 9.4), 1.6 * k, [0.55, 0.6, 0.75, 1]); for (let j = 0; j < 2; j++) { const a = rnd(Math.floor(t * 12) + j) * TAU; line(Q(-2.5, 9.4), add(Q(-2.5, 9.4), mul(fa(a), 2.4 * k)), A([0.8, 0.9, 1, 1], 0.8), 0.7 * k); } } }   // a shock node on a post
  if (B.r === 1) { const key = B.key("r1");
    if (key === "B") { const q = Q(-r - 1.6, 0); plate(q, rectPts(1.6, 3.6), METAL_D, aim, k, 1); for (let j = -2; j <= 2; j++) line(Q(-r - 2.6, j * 1.2), Q(-r - 0.6, j * 1.2), A(col, 0.5 + 0.3 * Math.sin(t * 3 + j)), 0.6 * k); }   // a hold battery
    if (key === "C") for (const x of [4, 6.4]) plate(Q(x, 0), rectPts(0.8, 3.4), COPPER, aim, k, 0.9); }   // hold coils round the barrel's base
  if (B.r === 2) { const key = B.key("r2");
    if (key === "A") for (let j = -3; j <= 3; j++) bar(Q(-r + 1, j * 1.5), Q(-r - 3.4, j * 2.1), 0.9 * k, METAL_L);   // cooling fins fanned at the back
    if (key === "C") { const q = Q(-r + 2.6, -3.6); disc(q, 2.8 * k, OUTLINE); disc(q, 2.4 * k, METAL_D); for (let j = 0; j < 4; j++) fill(q, [[0.4, -0.4], [2.1, -0.9], [2.1, 0.9], [0.4, 0.4]], METAL_L, t * 12 + j * Math.PI / 2, k); disc(q, 0.7 * k, METAL); } } }   // a fan vent

// ---- The agent: Spiral Lock (a twisting double-helix beam and a glowing bubble) with the real rules ---------------------------------------------------------------------
function gripBeam(f, to, s, col, t, w, L3, st, g) { const c2 = g ? GOLD : col, d = norm(sub(to, f)), o = orth(d), Lb = dist(f, to), strands = st === "A" ? [2, 3, 3, 4, 4, 5][L3] : 2, amp = s * 0.06 * w * (1 + (st === "A" ? 0.1 * L3 : 0)), lw = (1.3 + (st === "A" ? 0.2 * L3 : 0)) * w;
  if (st === "C") { line(f, to, A(c2, 0.12), (8 + 1.5 * L3) * w); for (const sg of [-1, 1]) line(add(f, mul(o, sg * (2 + 0.3 * L3) * w)), add(to, mul(o, sg * (4 + 0.6 * L3) * w)), A(c2, 0.5), 1); }   // a sheath round the beam
  for (let k2 = 0; k2 < strands; k2++) { const ph = k2 * TAU / strands, pts = []; for (let i = 0; i <= 24; i++) { const q = i / 24; pts.push(add(add(f, mul(d, Lb * q)), mul(o, Math.sin(q * 14 - t * 10 + ph) * amp))); } polyline(pts, A(c2, 0.75), lw); }
  line(f, to, A(c2, 0.25), (3 + (st ? 0.5 * L3 : 0)) * w);
  if (st === "B") for (let i = 0; i < 1 + L3; i++) { const q = fmod(-t * 0.9 + i / (1 + L3), 1), p = add(f, mul(d, Lb * q)); X.strokeStyle = css(A(c2, 0.8)); X.lineWidth = 1.3; X.beginPath(); X.ellipse(p[0], p[1], 2.5 + 0.3 * L3, (5 + 0.8 * L3) * w, Math.atan2(d[1], d[0]), 0, TAU); X.stroke(); } }   // gravity rings reeling in
function gripBubble(p, s, col, t, L3, st, g) { const c2 = g ? GOLD : col, rr = enemyR(s) + 6 + (st ? 0.6 * L3 : 0);
  disc(p, rr, A(c2, 0.12 + (st ? 0.02 * L3 : 0))); ring(p, rr, A(c2, 0.6 + 0.2 * Math.sin(t * 8)), 1.4 + (st === "A" ? 0.3 * L3 : 0)); arc(p, rr - 2, Math.PI * 1.1, Math.PI * 1.5, [1, 1, 1, 0.6], 1);
  if (st === "B") for (let i = 0; i < Math.min(L3, 3); i++) { const q = fmod(t * 0.8 + i / 3, 1); ring(p, rr * (1.6 - 0.6 * q), A(c2, 0.5 * q), 1.2); }
  if (st === "C") { outline(p, ngon(6, 1, t * 0.5), A(c2, 0.85), 1.4, 0, rr + 2); for (let i = 0; i < 4 + L3; i++) { const a = i * TAU / (4 + L3) + t * 0.5; line(add(p, mul(fa(a), rr - 3)), add(p, mul(fa(a), rr + 2)), A(c2, 0.6), 1); } } }
const segDist = (p, a, b) => { const ab = sub(b, a), u = Math.max(0, Math.min(1, ((p[0] - a[0]) * ab[0] + (p[1] - a[1]) * ab[1]) / (ab[0] * ab[0] + ab[1] * ab[1] || 1))); return dist(p, add(a, mul(ab, u))); };
function spiralBeam(f, to, s, col, t, w) { const d = norm(sub(to, f)), o = orth(d), L = dist(f, to); for (const ph of [0, Math.PI]) { const pts = []; for (let i = 0; i <= 24; i++) { const q = i / 24; pts.push(add(add(f, mul(d, L * q)), mul(o, Math.sin(q * 14 - t * 10 + ph) * s * 0.06 * w))); } polyline(pts, A(col, 0.75), 1.3 * w); } line(f, to, A(col, 0.25), 3 * w); }
function tractorAgent2(B) { return (m, t, info, s, col) => {
  const L1 = B.lv[0], L3 = B.lv[2], hold = holdOf(B), cool = 2.1 * rechOf(B) / 6, back = s * BACK[L1] / 48, range = s * 160 / 48, eR = enemyR(s);
  const beams = [{ f: 1, m: 0 }]; if (B.lv[1] >= 5) beams.push({ f: 1 / 3, m: 2 });
  const gst = pk(B, 2, L3), g3 = L3 >= 5, rk = B.r === 0 ? B.key("r0") : null; if (!m.wakes) m.wakes = [];
  if (!m.b || m.b.length !== beams.length) { m.b = beams.map(() => ({ state: "ready", t0: t })); m.slams = []; m.n = 0; }
  beams.forEach((bm, bi) => { const q = m.b[bi];
    if (q.state === "ready") { const used = m.b.filter((x) => x.state === "hold" || x.state === "drop").map((x) => x.id), e = nearestTo(info.c, info.ens.filter((x) => dist(x.p, info.c) < range && x.p[0] > s * 0.6 && !used.includes(x.i)));
      if (e) { Object.assign(q, { state: "hold", t0: t, id: e.i, p0: e.p.slice(), air: e.air, undo: false }); if (bi === 0) { m.n++; q.undo = L1 >= 5 && m.n % 3 === 0; } } }
    if (q.state === "hold" || q.state === "drop") { const e = info.all.find((x) => x.i === q.id); if (!e) { q.state = "cool"; q.t0 = t; return; }
      const u = Math.min(1, (t - q.t0) / hold), dx = Math.max(0, q.undo ? q.p0[0] - s * 0.5 : Math.min(back * bm.f, q.p0[0] - s * 0.5)),   /* kept on the preview: an Undo goes to the left edge */ lift = L3 >= 3 && !q.air ? Math.max(0, Math.sin(Math.PI * Math.min(1, u * 1.1))) : 0;
      const held = add(q.p0, [-dx * ease(u), (q.air ? Math.sin(t * 6) * 2 : 0) - lift * s * 0.14]);
      if (q.state === "hold") { if (bi === 0) m.aimAt = held; if (bm.m === 2) m.aim2 = Math.atan2(held[1] - info.c[1], held[0] - info.c[0]);
        disc(e.p, eR + 2, e.air ? [0.072, 0.093, 0.08, 0.92] : [0.16, 0.15, 0.13, 0.92]);                                                              // hide the real one: it's drawn where the beam drags it
        const from = info.muzzleAt(bm.m, info.aim); gripBeam(from, held, s, q.undo ? GOLD : col, t, bm.f < 1 ? 0.6 : 1, L3, gst, g3);
        if (rk === "B") for (const o of info.all) if (o.i !== q.id && segDist(o.p, from, held) < eR + 8) { ring(o.p, eR + 4, A([0.6, 0.85, 1, 1], 0.7), 1.2); txt(add(o.p, [0, -eR - 6]), "-30%", A([0.6, 0.85, 1, 1], 0.9), Math.max(8, s * 0.11)); }   // Beam Sweep
        if (rk === "C") for (const o of info.all) if (o.i !== q.id && dist(o.p, held) < s * 40 / 48 + eR) { const pts = [held]; for (let j = 1; j < 5; j++) pts.push(add(lerp(held, o.p, j / 5), mul(orth(norm(sub(o.p, held))), (rnd(j + o.i + Math.floor(t * 18)) - 0.5) * 8))); pts.push(o.p); polyline(pts, A([0.8, 0.9, 1, 1], 0.85), 1); }   // Shock Field
        if (lift) ellipse(add(held, [0, lift * s * 0.14 + eR * 0.8]), eR * (1.2 - 0.3 * lift), eR * 0.45, [0, 0, 0, 0.35]);
        if (REW[L1] && bi === 0) { for (let i = 1; i <= 4; i++) { X.save(); X.globalAlpha = 0.22 - i * 0.04; drawEnemy({ ...e, p: lerp(held, q.p0, i / 5) }, s); X.restore(); }   // Rewind: a trail of its past positions and a backwards clock
          const a0 = -t * 4; arc(held, eR + 9, a0, a0 + 4.6, A(q.undo ? GOLD : col, 0.85), 1.6); fill(add(held, mul(fa(a0), eR + 9)), [[0, -2.6], [2.6, 0], [0, 2.6]], A(q.undo ? GOLD : col, 0.85), a0 - Math.PI / 2, 1);
          txt(add(held, [0, -eR - 13]), q.undo ? "UNDO" : "-" + REW[L1] + "s", q.undo ? GOLD : lt(col, 0.3), Math.max(9, s * 0.14)); }
        else for (let i = 1; i <= 2; i++) { X.save(); X.globalAlpha = 0.25 / i; drawEnemy({ ...e, p: add(held, [i * 5, 0]) }, s); X.restore(); }
        drawEnemy({ ...e, p: held }, s);
        gripBubble(held, s, col, t, L3, gst, g3);   // the Spiral Lock bubble, by grip style and strength
        if (L3 >= 2) { const v = fmod(t * 2 + bi * 0.3, 1); txt(add(held, [eR + 6, -eR - 2 - v * 10]), "-15", A([1, 0.6, 0.5, 1], 1 - v), Math.max(8, s * 0.12)); for (let j = 0; j < 3; j++) disc(add(held, mul(fa(rnd(Math.floor(t * 10) + j + bi) * TAU), eR + 2)), 1.1, [1, 0.85, 0.5, 1]); }   // Crushing Grip
        if (L3 >= 4) { const lq = add(held, [-eR - 7, -eR - 4]); fill(lq, rectPts(2.6, 2.2), LOCKC, 0, 1); outline(lq, rectPts(2.6, 2.2), OUTLINE, 1, 0, 1); arc(add(lq, [0, -2.2]), 1.8, Math.PI, TAU, LOCKC, 1.2); }   // Grip Lock: barrier and abilities off
        if (u >= 1) { q.state = "drop"; q.t0 = t; q.final = held; if (rk === "A") m.wakes.push({ id: q.id, t0: t }); if (L3 >= 3 && !q.air) m.slams.push({ t0: t, p: held.slice(), r: s * (L3 >= 5 ? 80 : 50) / 48, stun: L3 >= 5 ? 0.8 : 0.4, g: L3 >= 5 }); } }
      else { const v = (t - q.t0) / 0.4; X.save(); X.globalAlpha = Math.max(0, 1 - v); drawEnemy({ ...e, p: q.final }, s); X.restore(); disc(e.p, eR + 2, A(e.air ? [0.072, 0.093, 0.08, 1] : [0.16, 0.15, 0.13, 1], 0.92 * Math.max(0, 1 - v))); if (v >= 1) { q.state = "cool"; q.t0 = t; } } }
    if (q.state === "cool") { if (bi === 0) m.aimAt = null; if (t - q.t0 > cool) q.state = "ready"; } });
  // Stasis Wake: a released enemy stays slowed 40% for 2 s
  m.wakes = m.wakes.filter((w) => t - w.t0 < 2.4); for (const w of m.wakes) { const e = info.all.find((x) => x.i === w.id); if (!e || t - w.t0 < 0.4) continue; const a = 1 - (t - w.t0 - 0.4) / 2; ring(e.p, eR + 4, A([0.6, 0.85, 1, 1], 0.8 * a), 1.6); txt(add(e.p, [0, -eR - 6]), "-40%", A([0.6, 0.85, 1, 1], a), Math.max(8, s * 0.11)); }
  // Lift and Drop / Gravity Hammer: the slam rings out and stuns everything inside it (gold, wider and with barrier shards at the mastery)
  m.slams = m.slams.filter((sl) => t - sl.t0 < sl.stun + 0.6);
  for (const sl of m.slams) { const v = (t - sl.t0) / 0.5, sc = sl.g ? GOLD : col; if (v < 1) { ring(sl.p, sl.r * ease(v), A(sc, 1 - v), 3); disc(sl.p, sl.r * ease(v), A(sc, 0.1 * (1 - v))); if (sl.g) for (let j = 0; j < 8; j++) disc(add(sl.p, mul(fa(j * TAU / 8 + 0.3), sl.r * ease(v) * 0.8)), 1.6, A(GOLD, 1 - v)); }
    if (t - sl.t0 < sl.stun) for (const e of info.all) if (!e.air && dist(e.p, sl.p) < sl.r) for (let j = 0; j < 3; j++) disc(add(e.p, add([0, -eR - 4], mul(fa(t * 6 + j * TAU / 3), eR * 0.6))), 1.3, [1, 1, 0.6, 1]); }
  m.state = m.b[0].state; m.charge = m.b[0].state === "cool" ? Math.min(1, (t - m.b[0].t0) / cool) : m.b[0].state === "ready" ? 1 : 0; }; }

// ---- The model ----------------------------------------------------------------------------------------------------------------------------------------------------
const P2 = {
  tower: "tractor", look: "C", anim: "C",
  intro: "Round 2, your notes. Pull Distance: four new barrel ideas beside your banded barrel (telescoping sleeves, a dish emitter, a coil barrel, forked prongs). Grip is now the strength of the effect, not a physical part: the base claws stay, and each step rebuilds the beam, the lock bubble and the emitter core between the claws (a braided beam, gravity rings, or a lattice cage), stronger each step. Twin Emitter is replaced: pick one of three new Retrofits (Stasis Wake, Beam Sweep or Shock Field), each with its own effect. Recharge (the cell ring), Longer Hold (the battery) and Faster Recharge (the fan vent) are picked. Round 1 on the confirmed Claw Emitter, with the names kept (your choice). Each path rebuilds one part, in the style you pick for each step, and the new design replaces the old one: Pull Distance rebuilds the barrel (banded, lens or rail; longer each step; a rewind coil turning backwards at its tip from Rewind; gold with two counter-turning coils at Undo); Recharge rebuilds the turret body with capacitors that light up as it recharges (drums on its back, a ring of cells round it, or coil banks on its sides; glowing vents from Overclocked Emitter; gold with a second emitter at Dual Beam); Grip rebuilds the claws at the barrel's tip (clamp claws, pincers or a ring clamp; teeth from Crushing Grip, lifting pads from Lift and Drop, a lock from Grip Lock; gold at Gravity Hammer). The preview runs the real rules: the hold time, the pull (or a rewind with a trail of past positions and -3s, -4s, -5s; a gold UNDO every third grab at the mastery), the recharge, the second and third beams, -15 crush damage, the lift-and-slam stun ring (gold and wider at Gravity Hammer) and the grip lock. Overlapping Retrofits are kept and stack (the carpet rule).",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: tractorAgent2(B) }; },
  muzzleAt(B, m, kk, c, aim, s, info) { return muzzleOf(B, m, c, aim, G(s), info?.view?.mem?.aim2); },
  model(c, aim, s, fx, t, col, info, B) { const k = G(s), mm = fx.mem || {}, held = mm.state === "hold" ? 1 : 0, ch = mm.charge ?? 1;
    deck(c, k, col, t);
    retroUnder(c, aim, k, B, t, col);
    body(c, aim, k, B, t, col, ch, mm);
    barrel(c, aim, k, B, t, col);
    claws(c, aim, k, B, t, col, held);
    retroOver(c, aim, k, B, t, col, held);
    glowDot(P(c, aim, k, 13, 0), 1.2 * k, B.lv[0] >= 5 ? GOLD : col); orb(c, 3 * k, B.lv[1] >= 5 ? GOLD : METAL); },
  paths: [], retrofits: [],
};

// ---- Option tables (names and effects as in design/tower_roster.md) ----------------------------------------------------------------------------------------------
const T = (a, b, c) => [["A", ...a], ["B", ...b], ["C", ...c]].map(([key, name, desc]) => ({ key, name, desc }));
const TK = (...o) => o.map(([key, name, desc]) => ({ key, name, desc }));
P2.paths = [
  { name: "Pull Distance", theme: "the barrel: rebuilt each step, longer each step; the banded barrel (your round 1 pick) and four new ideas (telescoping sleeves, a dish emitter, a coil barrel, forked prongs); a rewind coil from Rewind; gold at Undo", steps: [
    { name: "Longer Haul", cost: 185, effect: "100 px pull", options: TK(["A", "Banded Barrel", "The barrel is rebuilt longer, ringed with steel bands (your round 1 pick)."], ["D", "Telescoping Barrel", "The barrel is rebuilt as two telescoping sleeves, each narrower than the last."], ["E", "Dish Emitter", "The barrel is cut short and ends in a parabolic dish with a feed horn at its focus."], ["F", "Coil Barrel", "The barrel is wound with copper coils that light in turn toward the muzzle."], ["G", "Forked Prongs", "The barrel splits into two prongs with an arc crackling between them."]) },
    { name: "Stronger Beam", cost: 535, effect: "120 px; holds 1.8 s", options: TK(["A", "Heavy Banded Barrel", "Longer and thicker, with more bands."], ["D", "Three Sleeves", "Longer, three telescoping sleeves."], ["E", "Wider Dish", "A wider dish."], ["F", "More Coils", "Longer, with four coils."], ["G", "Longer Prongs", "Longer prongs, spread wider."]) },
    { name: "Rewind", cost: 1840, effect: "Sends the enemy back to where it was 3 s ago (primary)", options: TK(["A", "Banded Rewind", "Longer again, with a rewind coil turning backwards at the tip; the held enemy leaves a trail of its past positions and shows -3s."], ["D", "Telescoping Rewind", "Four sleeves and the rewind coil; the trail and -3s."], ["E", "Rewind Dish", "A deeper dish and the rewind coil; the trail and -3s."], ["F", "Coil Rewind", "Five coils and the rewind coil; the trail and -3s."], ["G", "Prong Rewind", "Longer prongs and the rewind coil; the trail and -3s."]) },
    { name: "Long Rewind", cost: 2945, effect: "Back 4 s", options: TK(["A", "Long Banded Rewind", "Longer, with a bigger rewind coil (-4s)."], ["D", "Five Sleeves", "Five sleeves and a bigger rewind coil (-4s)."], ["E", "Great Dish", "The widest dish and a bigger rewind coil (-4s)."], ["F", "Six Coils", "Six coils and a bigger rewind coil (-4s)."], ["G", "Great Prongs", "The longest prongs and a bigger rewind coil (-4s)."]) },
    { name: "Undo", cost: 9215, effect: "Back 5 s; once per round, sends one non-boss enemy back to the start of its current track segment (mastery)", options: TK(["A", "Gold Banded Barrel", "A gold barrel with two counter-turning gold rewind coils; every third grab is a gold UNDO."], ["D", "Gold Sleeves", "Gold sleeves and two gold rewind coils; the gold UNDO."], ["E", "Gold Dish", "A gold dish and two gold rewind coils; the gold UNDO."], ["F", "Gold Coils", "Gold coils and two gold rewind coils; the gold UNDO."], ["G", "Gold Prongs", "Gold prongs with a gold arc and two gold rewind coils; the gold UNDO."]) },
  ] },
  { name: "Recharge", theme: "the turret body: rebuilt each step with capacitors in the style you pick (drums, a cell ring, or coil banks) that light up as it recharges; gold with a second emitter at Dual Beam", steps: [
    { name: "Quick Release", cost: 175, effect: "Recharge 5.2 s", options: T(["Capacitor Drums", "Two capacitor drums on the turret's back light up as it recharges."], ["Cell Ring", "A ring of cells round the turret lights up cell by cell as it recharges."], ["Coil Banks", "A coil bank on each side of the turret glows when charged."]) },
    { name: "Capacitor Bank", cost: 345, effect: "4.6 s", options: T(["Bigger Drums", "Two bigger drums on a bigger turret."], ["Denser Cell Ring", "A wider ring with more cells."], ["Bigger Coil Banks", "Bigger coil banks on a bigger turret."]) },
    { name: "Rapid Lock", cost: 1265, effect: "3.8 s (primary)", options: T(["Three Drums", "Three drums, lighting in turn."], ["Cell Ring", "A wider ring of cells again."], ["Double Coil Banks", "Two coil banks on each side."]) },
    { name: "Overclocked Emitter", cost: 2200, effect: "3.3 s", options: T(["Four Drums, Vented", "Four drums, and the turret's back glows through two vents."], ["Vented Cell Ring", "The widest ring of cells, and glowing vents."], ["Vented Coil Banks", "Two coil banks a side, and glowing vents."]) },
    { name: "Dual Beam", cost: 10035, effect: "A second beam on another enemy, at a third of the pull (mastery)", options: T(["Gold Drums", "Gold drums, and a second gold emitter on the turret holds another enemy."], ["Gold Cell Ring", "A gold ring of cells, and the second gold emitter."], ["Gold Coil Banks", "Three gold coil banks a side, and the second gold emitter."]) },
  ] },
  { name: "Grip", theme: "the strength of the effect (round 2, your note: not a physical claw or clamp): the beam, the lock bubble round the held enemy and the emitter core between the claws, stronger each step, in the style you pick (a braided beam, gravity rings, or a lattice cage); gold at Gravity Hammer", steps: [
    { name: "Firm Grip", cost: 190, effect: "Heavy roles resist half as much", options: T(["Braided Beam", "The beam braids into three strands and the bubble's ring thickens; the core between the claws swirls."], ["Gravity Rings", "Rings reel in along the beam and close round the held enemy."], ["Lattice Cage", "A sheath wraps the beam and a turning lattice cage closes round the held enemy."]) },
    { name: "Crushing Grip", cost: 270, effect: "The held enemy takes 15 energy damage/s", options: T(["Crushing Braid", "Three thicker strands and a heavier bubble; the held enemy throws sparks and -15s."], ["Crushing Rings", "More rings, closing tighter; sparks and -15s."], ["Crushing Cage", "A denser cage; sparks and -15s."]) },
    { name: "Lift and Drop", cost: 1075, effect: "Ground enemies are lifted, then slammed down, stunning everything within 50 px for 0.4 s (primary)", options: T(["Lifting Braid", "Four strands; held ground enemies rise, then slam down in a stunning ring."], ["Lifting Rings", "Four rings; the lift and the slam ring."], ["Lifting Cage", "A wider cage; the lift and the slam ring."]) },
    { name: "Grip Lock", cost: 1610, effect: "The held enemy's barrier and abilities switch off while held", options: T(["Locking Braid", "Four heavy strands; held enemies show a padlock (barrier and abilities off)."], ["Locking Rings", "Five rings; the padlock."], ["Locking Cage", "A denser cage; the padlock."]) },
    { name: "Gravity Hammer", cost: 5365, effect: "The slam stuns everything within 80 px for 0.8 s and shatters barriers (mastery)", options: T(["Gold Braid", "Five gold strands and a gold bubble; the slam ring turns gold, wider, with barrier shards."], ["Gold Rings", "Gold rings and bubble; the gold slam."], ["Gold Cage", "A gold cage and sheath; the gold slam."]) },
  ] },
];
P2.retrofits = [
  { name: "New Retrofit (replaces Twin Emitter)", cost: 575, effect: "Pick one of three new ideas; each option is its own Retrofit and effect (the price is set by the pricing formula once you pick)", options: T(["Stasis Wake", "After release, the enemy stays slowed 40% for 2 s (a -40% ring follows it). A stasis coil on the turret's side."], ["Beam Sweep", "While holding, the beam slows every other enemy it crosses by 30%. Sweep vanes on the barrel."], ["Shock Field", "The held enemy shocks every enemy within 40 px for 10 damage/s. A shock node on a post on the turret."]) },
  { name: "Longer Hold", cost: 140, effect: "Holds for 2 s (+0.5 s, stacks with Stronger Beam)", options: T(["Hold Capacitor Ring", "A glowing capacitor ring on the deck round the turret."], ["Hold Battery", "A battery pack on the turret's back."], ["Hold Coils", "Two copper coils round the barrel's base."]) },
  { name: "Faster Recharge", cost: 230, effect: "Recharges in 5 s (-1 s, stacks with Recharge)", options: T(["Cooling Fins", "Cooling fins fanned out at the turret's back."], ["Radiator Panels", "Two radiator panels on the deck."], ["Fan Vent", "A spinning fan vent on the turret."]) },
];

// ---- Round 2 picks (owner, 2026-10-19): Recharge all B, Longer Hold B, Faster Recharge C; Pull Distance, Grip and the new Retrofit are open --------------------------
P2.picks = { p1s0: "B", p1s1: "B", p1s2: "B", p1s3: "B", p1s4: "B", r1: "B", r2: "C" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { const pk = P2.picks["p" + pi + "s" + k]; if (pk) st.options = st.options.filter((o) => o.key === pk); }));
P2.retrofits.forEach((rf, ri) => { const pk = P2.picks["r" + ri]; if (pk) rf.options = rf.options.filter((o) => o.key === pk); });
