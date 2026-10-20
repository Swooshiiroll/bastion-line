// ---- Tower art second pass: Tractor Tower (tower 19), round 1 ----------------------------------------------------------------------------------------------------
// Base: look C Claw Emitter, animation C Spiral Lock (tools/tower_art/data_towers4.js). The owner kept the names and chose the parts (2026-10-19):
//  - Path 1, Pull Distance, rebuilds the BARREL (banded, lens or rail barrel; longer each step; a rewind coil from Rewind; gold at Undo).
//  - Path 2, Recharge, rebuilds the TURRET BODY with capacitors (drums, a cell ring or coil banks) that light up as it recharges; gold with a second emitter at Dual Beam.
//  - Path 3, Grip, rebuilds the CLAWS at the barrel's tip (clamp claws, pincers or a ring clamp); gold at Gravity Hammer.
// Each step rebuilds its part in the style picked for that step (the new design replaces the old one); masteries are gold; the agent runs the real rules (the hold
// time, the pull or rewind, the recharge, a second and third beam, the crush damage, the lift-and-slam stun, the grip lock, the once-a-round Undo).
// Overlaps kept and stacking (the carpet rule): the Twin Emitter's beam with Dual Beam's (three beams), Longer Hold's +0.5 s with Stronger Beam's hold,
// Faster Recharge's -1 s with the Recharge path.
const PAGE = { title: "Tractor Tower: paths and Retrofits (second pass)", store: "bl-tower-art-p2-tractor-r1" };
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

// ---- Path 1, Pull Distance: the barrel, rebuilt each step (banded, lens or rail), longer each step; a rewind coil turns backwards at its tip from Rewind -----------
function barrel(c, aim, k, B, t, col) { const L = B.lv[0], st = pk(B, 0, L), g = L >= 5, len = BLEN[L], bc = gl(METAL, g, 0.7), bl = g ? GOLD : METAL_L;
  if (!st) { bar(c, P(c, aim, k, len, 0), 4 * k, METAL); return; }
  if (st === "A") { bar(c, P(c, aim, k, len, 0), (4 + 0.2 * L) * k, bc); for (let i = 0; i <= L; i++) plate(P(c, aim, k, 5 + i * (len - 7) / L, 0), rectPts(0.7, 2.6 + 0.12 * L), bl, aim, k, 0.9); }
  if (st === "B") { bar(c, P(c, aim, k, len, 0), 3.2 * k, bc); const n = 1 + Math.ceil(L / 2); for (let i = 0; i < n; i++) { const q = P(c, aim, k, 6 + i * (len - 8) / Math.max(1, n - 1), 0), lr = 2.3 + 0.2 * L; disc(q, (lr + 0.6) * k, OUTLINE); disc(q, lr * k, A(lt(col, 0.45), 0.9)); ring(q, lr * k, bl, 0.8 * k); disc(add(q, [-0.5 * k, -0.5 * k]), lr * 0.35 * k, [1, 1, 1, 0.5]); } }
  if (st === "C") { for (const sg of [-1, 1]) bar(P(c, aim, k, 2, sg * (1.8 + 0.1 * L)), P(c, aim, k, len, sg * (1.8 + 0.1 * L)), (1.5 + 0.1 * L) * k, bc); line(P(c, aim, k, 3, 0), P(c, aim, k, len, 0), A(col, 0.55 + 0.25 * Math.sin(t * 6)), 1 * k);
    for (let x = 4; x < len; x += 3) bar(P(c, aim, k, x, -2), P(c, aim, k, x, 2), 0.7 * k, bl); }
  if (L >= 3) { const q = P(c, aim, k, len - 3.6, 0), n = g ? 2 : 1; for (let j = 0; j < n; j++) { const rr = 3 + 0.4 * (L - 3) + j * 1.4, sp = (j ? 3 : -2.5) * t;   // the rewind coil (two counter-turning gold ones at Undo)
      ring(q, rr * k, OUTLINE, 2 * k); ring(q, rr * k, g ? GOLD : lt(col, 0.2), 1.1 * k); for (let i = 0; i < 8; i++) { const a = sp + i * Math.PI / 4; line(add(q, mul(fa(a), rr * 0.55 * k)), add(q, mul(fa(a), rr * 0.85 * k)), g ? HOTG : col, 0.8 * k); } } } }
const HOTG = [1, 0.92, 0.6, 1];

// ---- Path 3, Grip: the claws at the barrel's tip, rebuilt each step (clamp claws, pincers, or a ring clamp); they close on a hold --------------------------------------
function claws(c, aim, k, B, t, col, held) { const L = B.lv[2], st = pk(B, 2, L), g = L >= 5, len = BLEN[B.lv[0]], cc = gl(METAL_L, g, 0.75), w = 1.3 + 0.25 * L, ext = 5 + 0.6 * L, Q = (x, y) => P(c, aim, k, x, y);
  if (!st || st === "A") { const n = st && L >= 2 ? 4 : 3; for (let i = 0; i < n; i++) { const sg = n === 3 ? i - 1 : (i - 1.5) / 1.5, b = Q(len - 1, sg * 2.6), tp = Q(len + ext - held, sg * (3.6 + 0.4 * L) * (1 - 0.6 * held));
      bar(b, tp, w * k, cc); if (st && L >= 2) for (let j = 1; j <= 2; j++) disc(lerp(b, tp, j / 3), 0.5 * k, dk(cc, 0.3)); if (st && L >= 3) { disc(tp, (0.9 + 0.1 * L) * k, OUTLINE); disc(tp, (0.6 + 0.1 * L) * k, g ? GOLD : col); } } }
  if (st === "B") for (const sg of [-1, 1]) { const pts = [Q(len - 1, sg * 2.4), Q(len + ext * 0.55, sg * (4.4 + 0.4 * L) * (1 - 0.45 * held)), Q(len + ext, sg * 1.4 * (1 - 0.6 * held))];
      polyline(pts, OUTLINE, (w * 1.5 + 1.4) * k); polyline(pts, cc, w * 1.5 * k); if (L >= 2) for (let j = 0; j < 3; j++) { const q = lerp(pts[1], pts[2], 0.2 + j * 0.25); disc(q, 0.55 * k, dk(cc, 0.35)); } if (L >= 3) { disc(pts[2], 0.9 * k, OUTLINE); disc(pts[2], 0.6 * k, g ? GOLD : col); } }
  if (st === "C") { const n = [0, 3, 3, 4, 4, 5][L], q = Q(len + 3.6, 0), rr = (3.6 + 0.3 * L) * (1 - 0.35 * held); bar(Q(len - 1, 0), q, 1.8 * k, gl(STEEL, g, 0.6));
    for (let i = 0; i < n; i++) { const a0 = aim + i * TAU / n + 0.25, a1 = a0 + TAU / n - 0.5; arc(q, rr * k, a0, a1, OUTLINE, (w + 1.4) * k); arc(q, rr * k, a0, a1, cc, w * k); if (L >= 2) disc(add(q, mul(fa((a0 + a1) / 2), (rr - w * 0.6) * k)), 0.5 * k, dk(cc, 0.35)); } }
  if (L >= 4) { const q = Q(len - 2.6, 0); plate(q, rectPts(1.1, 1), g ? GOLD : LOCKC, aim, k, 0.8); arc(add(q, rot([-1.1 * k, 0], aim)), 0.7 * k, aim + Math.PI / 2, aim + Math.PI * 1.5, OUTLINE, 0.6 * k); }   // Grip Lock: a lock on the claws
  if (g) glowDot(Q(len + 3.6, 0), (1.2 + 0.5 * Math.sin(t * 5)) * k, A(GOLD, 0.8)); }

// ---- The Retrofits: the Twin Emitter's second barrel, Longer Hold's capacitor, Faster Recharge's cooling ------------------------------------------------------------
function retroUnder(c, aim, k, B, t, col) { if (B.r === 1 && B.key("r1") === "A") { ring(c, 12.6 * k, OUTLINE, 3 * k); ring(c, 12.6 * k, METAL_D, 2 * k); for (let i = 0; i < 8; i++) { const a0 = i * TAU / 8 + 0.08; arc(c, 12.6 * k, a0, a0 + TAU / 8 - 0.16, A(col, 0.35 + 0.3 * Math.sin(t * 3 + i)), 1 * k); } }   // a hold capacitor ring on the deck
  if (B.r === 2 && B.key("r2") === "B") for (const sx of [-1, 1]) { const q = add(c, [sx * 14 * k, 7 * k]); plate(q, rectPts(2.6, 4.6), METAL_L, 0, k, 1); for (let j = -3; j <= 3; j++) line(add(q, [-2 * k, j * 1.2 * k]), add(q, [2 * k, j * 1.2 * k]), METAL_D, 0.6 * k); } }   // radiator panels on the deck
function retroOver(c, aim, k, B, t, col, held) { const r = BODY[B.lv[1]], Q = (x, y) => P(c, aim, k, x, y);
  if (B.r === 0) { const key = B.key("r0");
    if (key === "A" || key === "C") { const y = key === "A" ? 6.2 : -6.2; plate(Q(1.5, y), rectPts(2, 1.8), METAL_L, aim, k, 1); bar(Q(2, y), Q(11, y), 2.4 * k, METAL); for (const sg of [-1, 1]) bar(Q(10.5, y + sg * 1.2), Q(13.6 - held, y + sg * 2.2 * (1 - 0.5 * held)), 0.9 * k, METAL_L); glowDot(Q(12.4, y), 0.7 * k, col); }   // a second barrel with small claws
    if (key === "B") { const q = Q(-2.5, 6.4); disc(q, 3.4 * k, OUTLINE); disc(q, 2.9 * k, METAL); arc(q, 2.9 * k, aim - 1.2, aim + 1.2, METAL_L, 1 * k); glowDot(q, 0.8 * k, col); } }   // a rear dish
  if (B.r === 1) { const key = B.key("r1");
    if (key === "B") { const q = Q(-r - 1.6, 0); plate(q, rectPts(1.6, 3.6), METAL_D, aim, k, 1); for (let j = -2; j <= 2; j++) line(Q(-r - 2.6, j * 1.2), Q(-r - 0.6, j * 1.2), A(col, 0.5 + 0.3 * Math.sin(t * 3 + j)), 0.6 * k); }   // a hold battery
    if (key === "C") for (const x of [4, 6.4]) plate(Q(x, 0), rectPts(0.8, 3.4), COPPER, aim, k, 0.9); }   // hold coils round the barrel's base
  if (B.r === 2) { const key = B.key("r2");
    if (key === "A") for (let j = -3; j <= 3; j++) bar(Q(-r + 1, j * 1.5), Q(-r - 3.4, j * 2.1), 0.9 * k, METAL_L);   // cooling fins fanned at the back
    if (key === "C") { const q = Q(-r + 2.6, -3.6); disc(q, 2.8 * k, OUTLINE); disc(q, 2.4 * k, METAL_D); for (let j = 0; j < 4; j++) fill(q, [[0.4, -0.4], [2.1, -0.9], [2.1, 0.9], [0.4, 0.4]], METAL_L, t * 12 + j * Math.PI / 2, k); disc(q, 0.7 * k, METAL); } } }   // a fan vent

// ---- The agent: Spiral Lock (a twisting double-helix beam and a glowing bubble) with the real rules ---------------------------------------------------------------------
function spiralBeam(f, to, s, col, t, w) { const d = norm(sub(to, f)), o = orth(d), L = dist(f, to); for (const ph of [0, Math.PI]) { const pts = []; for (let i = 0; i <= 24; i++) { const q = i / 24; pts.push(add(add(f, mul(d, L * q)), mul(o, Math.sin(q * 14 - t * 10 + ph) * s * 0.06 * w))); } polyline(pts, A(col, 0.75), 1.3 * w); } line(f, to, A(col, 0.25), 3 * w); }
function tractorAgent2(B) { return (m, t, info, s, col) => {
  const L1 = B.lv[0], L3 = B.lv[2], hold = holdOf(B), cool = 2.1 * rechOf(B) / 6, back = s * BACK[L1] / 48, range = s * 160 / 48, eR = enemyR(s);
  const beams = [{ f: 1, m: 0 }]; if (B.r === 0) beams.push({ f: 0.5, m: 1 }); if (B.lv[1] >= 5) beams.push({ f: 1 / 3, m: 2 });
  if (!m.b || m.b.length !== beams.length) { m.b = beams.map(() => ({ state: "ready", t0: t })); m.slams = []; m.n = 0; }
  beams.forEach((bm, bi) => { const q = m.b[bi];
    if (q.state === "ready") { const used = m.b.filter((x) => x.state === "hold" || x.state === "drop").map((x) => x.id), e = nearestTo(info.c, info.ens.filter((x) => dist(x.p, info.c) < range && x.p[0] > s * 0.6 && !used.includes(x.i)));
      if (e) { Object.assign(q, { state: "hold", t0: t, id: e.i, p0: e.p.slice(), air: e.air, undo: false }); if (bi === 0) { m.n++; q.undo = L1 >= 5 && m.n % 3 === 0; } } }
    if (q.state === "hold" || q.state === "drop") { const e = info.all.find((x) => x.i === q.id); if (!e) { q.state = "cool"; q.t0 = t; return; }
      const u = Math.min(1, (t - q.t0) / hold), dx = Math.max(0, q.undo ? q.p0[0] - s * 0.5 : Math.min(back * bm.f, q.p0[0] - s * 0.5)),   /* kept on the preview: an Undo goes to the left edge */ lift = L3 >= 3 && !q.air ? Math.max(0, Math.sin(Math.PI * Math.min(1, u * 1.1))) : 0;
      const held = add(q.p0, [-dx * ease(u), (q.air ? Math.sin(t * 6) * 2 : 0) - lift * s * 0.14]);
      if (q.state === "hold") { if (bi === 0) m.aimAt = held; if (bm.m === 2) m.aim2 = Math.atan2(held[1] - info.c[1], held[0] - info.c[0]);
        disc(e.p, eR + 2, e.air ? [0.072, 0.093, 0.08, 0.92] : [0.16, 0.15, 0.13, 0.92]);                                                              // hide the real one: it's drawn where the beam drags it
        spiralBeam(info.muzzleAt(bm.m, info.aim), held, s, q.undo ? GOLD : col, t, bm.f < 1 ? 0.6 : 1);
        if (lift) ellipse(add(held, [0, lift * s * 0.14 + eR * 0.8]), eR * (1.2 - 0.3 * lift), eR * 0.45, [0, 0, 0, 0.35]);
        if (REW[L1] && bi === 0) { for (let i = 1; i <= 4; i++) { X.save(); X.globalAlpha = 0.22 - i * 0.04; drawEnemy({ ...e, p: lerp(held, q.p0, i / 5) }, s); X.restore(); }   // Rewind: a trail of its past positions and a backwards clock
          const a0 = -t * 4; arc(held, eR + 9, a0, a0 + 4.6, A(q.undo ? GOLD : col, 0.85), 1.6); fill(add(held, mul(fa(a0), eR + 9)), [[0, -2.6], [2.6, 0], [0, 2.6]], A(q.undo ? GOLD : col, 0.85), a0 - Math.PI / 2, 1);
          txt(add(held, [0, -eR - 13]), q.undo ? "UNDO" : "-" + REW[L1] + "s", q.undo ? GOLD : lt(col, 0.3), Math.max(9, s * 0.14)); }
        else for (let i = 1; i <= 2; i++) { X.save(); X.globalAlpha = 0.25 / i; drawEnemy({ ...e, p: add(held, [i * 5, 0]) }, s); X.restore(); }
        drawEnemy({ ...e, p: held }, s);
        disc(held, eR + 6, A(col, 0.12)); ring(held, eR + 6, A(col, 0.6 + 0.2 * Math.sin(t * 8)), 1.4); arc(held, eR + 4, Math.PI * 1.1, Math.PI * 1.5, [1, 1, 1, 0.6], 1);   // the Spiral Lock bubble
        if (L3 >= 2) { const v = fmod(t * 2 + bi * 0.3, 1); txt(add(held, [eR + 6, -eR - 2 - v * 10]), "-15", A([1, 0.6, 0.5, 1], 1 - v), Math.max(8, s * 0.12)); for (let j = 0; j < 3; j++) disc(add(held, mul(fa(rnd(Math.floor(t * 10) + j + bi) * TAU), eR + 2)), 1.1, [1, 0.85, 0.5, 1]); }   // Crushing Grip
        if (L3 >= 4) { const lq = add(held, [-eR - 7, -eR - 4]); fill(lq, rectPts(2.6, 2.2), LOCKC, 0, 1); outline(lq, rectPts(2.6, 2.2), OUTLINE, 1, 0, 1); arc(add(lq, [0, -2.2]), 1.8, Math.PI, TAU, LOCKC, 1.2); }   // Grip Lock: barrier and abilities off
        if (u >= 1) { q.state = "drop"; q.t0 = t; q.final = held; if (L3 >= 3 && !q.air) m.slams.push({ t0: t, p: held.slice(), r: s * (L3 >= 5 ? 80 : 50) / 48, stun: L3 >= 5 ? 0.8 : 0.4, g: L3 >= 5 }); } }
      else { const v = (t - q.t0) / 0.4; X.save(); X.globalAlpha = Math.max(0, 1 - v); drawEnemy({ ...e, p: q.final }, s); X.restore(); disc(e.p, eR + 2, A(e.air ? [0.072, 0.093, 0.08, 1] : [0.16, 0.15, 0.13, 1], 0.92 * Math.max(0, 1 - v))); if (v >= 1) { q.state = "cool"; q.t0 = t; } } }
    if (q.state === "cool") { if (bi === 0) m.aimAt = null; if (t - q.t0 > cool) q.state = "ready"; } });
  // Lift and Drop / Gravity Hammer: the slam rings out and stuns everything inside it (gold, wider and with barrier shards at the mastery)
  m.slams = m.slams.filter((sl) => t - sl.t0 < sl.stun + 0.6);
  for (const sl of m.slams) { const v = (t - sl.t0) / 0.5, sc = sl.g ? GOLD : col; if (v < 1) { ring(sl.p, sl.r * ease(v), A(sc, 1 - v), 3); disc(sl.p, sl.r * ease(v), A(sc, 0.1 * (1 - v))); if (sl.g) for (let j = 0; j < 8; j++) disc(add(sl.p, mul(fa(j * TAU / 8 + 0.3), sl.r * ease(v) * 0.8)), 1.6, A(GOLD, 1 - v)); }
    if (t - sl.t0 < sl.stun) for (const e of info.all) if (!e.air && dist(e.p, sl.p) < sl.r) for (let j = 0; j < 3; j++) disc(add(e.p, add([0, -eR - 4], mul(fa(t * 6 + j * TAU / 3), eR * 0.6))), 1.3, [1, 1, 0.6, 1]); }
  m.state = m.b[0].state; m.charge = m.b[0].state === "cool" ? Math.min(1, (t - m.b[0].t0) / cool) : m.b[0].state === "ready" ? 1 : 0; }; }

// ---- The model ----------------------------------------------------------------------------------------------------------------------------------------------------
const P2 = {
  tower: "tractor", look: "C", anim: "C",
  intro: "Round 1 on the confirmed Claw Emitter, with the names kept (your choice). Each path rebuilds one part, in the style you pick for each step, and the new design replaces the old one: Pull Distance rebuilds the barrel (banded, lens or rail; longer each step; a rewind coil turning backwards at its tip from Rewind; gold with two counter-turning coils at Undo); Recharge rebuilds the turret body with capacitors that light up as it recharges (drums on its back, a ring of cells round it, or coil banks on its sides; glowing vents from Overclocked Emitter; gold with a second emitter at Dual Beam); Grip rebuilds the claws at the barrel's tip (clamp claws, pincers or a ring clamp; teeth from Crushing Grip, lifting pads from Lift and Drop, a lock from Grip Lock; gold at Gravity Hammer). The preview runs the real rules: the hold time, the pull (or a rewind with a trail of past positions and -3s, -4s, -5s; a gold UNDO every third grab at the mastery), the recharge, the second and third beams, -15 crush damage, the lift-and-slam stun ring (gold and wider at Gravity Hammer) and the grip lock. Overlapping Retrofits are kept and stack (the carpet rule).",
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
P2.paths = [
  { name: "Pull Distance", theme: "the barrel: rebuilt each step in the style you pick (banded, lens or rail), longer each step; a rewind coil from Rewind; gold at Undo", steps: [
    { name: "Longer Haul", cost: 185, effect: "100 px pull", options: T(["Banded Barrel", "The barrel is rebuilt longer, ringed with steel bands."], ["Lens Barrel", "A longer barrel strung with glowing focusing lenses."], ["Rail Barrel", "A longer barrel of twin rails with a glowing groove between them."]) },
    { name: "Stronger Beam", cost: 535, effect: "120 px; holds 1.8 s", options: T(["Heavy Banded Barrel", "Longer and thicker, with more bands."], ["Two-Lens Barrel", "Longer, with two bigger lenses."], ["Wide Rails", "Longer, wider rails with more cross-ties."]) },
    { name: "Rewind", cost: 1840, effect: "Sends the enemy back to where it was 3 s ago (primary)", options: T(["Banded Rewind", "Longer again, with a rewind coil turning backwards at the tip; the held enemy leaves a trail of its past positions and shows -3s."], ["Lens Rewind", "Three lenses and a rewind coil at the tip; the trail and -3s."], ["Rail Rewind", "Longer rails and a rewind coil at the tip; the trail and -3s."]) },
    { name: "Long Rewind", cost: 2945, effect: "Back 4 s", options: T(["Long Banded Rewind", "Longer, with a bigger rewind coil (-4s)."], ["Long Lens Rewind", "Longer, with a bigger rewind coil (-4s)."], ["Long Rail Rewind", "Longer, with a bigger rewind coil (-4s)."]) },
    { name: "Undo", cost: 9215, effect: "Back 5 s; once per round, sends one non-boss enemy back to the start of its current track segment (mastery)", options: T(["Gold Banded Barrel", "A gold barrel with two counter-turning gold rewind coils; every third grab is a gold UNDO that sends the enemy far back."], ["Gold Lens Barrel", "Gold lenses and two gold rewind coils; the gold UNDO."], ["Gold Rail Barrel", "Gold rails and two gold rewind coils; the gold UNDO."]) },
  ] },
  { name: "Recharge", theme: "the turret body: rebuilt each step with capacitors in the style you pick (drums, a cell ring, or coil banks) that light up as it recharges; gold with a second emitter at Dual Beam", steps: [
    { name: "Quick Release", cost: 175, effect: "Recharge 5.2 s", options: T(["Capacitor Drums", "Two capacitor drums on the turret's back light up as it recharges."], ["Cell Ring", "A ring of cells round the turret lights up cell by cell as it recharges."], ["Coil Banks", "A coil bank on each side of the turret glows when charged."]) },
    { name: "Capacitor Bank", cost: 345, effect: "4.6 s", options: T(["Bigger Drums", "Two bigger drums on a bigger turret."], ["Denser Cell Ring", "A wider ring with more cells."], ["Bigger Coil Banks", "Bigger coil banks on a bigger turret."]) },
    { name: "Rapid Lock", cost: 1265, effect: "3.8 s (primary)", options: T(["Three Drums", "Three drums, lighting in turn."], ["Cell Ring", "A wider ring of cells again."], ["Double Coil Banks", "Two coil banks on each side."]) },
    { name: "Overclocked Emitter", cost: 2200, effect: "3.3 s", options: T(["Four Drums, Vented", "Four drums, and the turret's back glows through two vents."], ["Vented Cell Ring", "The widest ring of cells, and glowing vents."], ["Vented Coil Banks", "Two coil banks a side, and glowing vents."]) },
    { name: "Dual Beam", cost: 10035, effect: "A second beam on another enemy, at a third of the pull (mastery)", options: T(["Gold Drums", "Gold drums, and a second gold emitter on the turret holds another enemy."], ["Gold Cell Ring", "A gold ring of cells, and the second gold emitter."], ["Gold Coil Banks", "Three gold coil banks a side, and the second gold emitter."]) },
  ] },
  { name: "Grip", theme: "the claws at the barrel's tip: rebuilt each step in the style you pick (clamp claws, pincers, or a ring clamp); they close on a hold; gold at Gravity Hammer", steps: [
    { name: "Firm Grip", cost: 190, effect: "Heavy roles resist half as much", options: T(["Clamp Claws", "Thicker clamp claws that spread wider."], ["Pincers", "Two big pincer jaws."], ["Ring Clamp", "A three-segment ring clamp that closes round the target."]) },
    { name: "Crushing Grip", cost: 270, effect: "The held enemy takes 15 energy damage/s", options: T(["Toothed Claws", "Four toothed claws; the held enemy throws sparks and -15s."], ["Toothed Pincers", "Toothed pincers; sparks and -15s."], ["Toothed Clamp", "A toothed ring clamp; sparks and -15s."]) },
    { name: "Lift and Drop", cost: 1075, effect: "Ground enemies are lifted, then slammed down, stunning everything within 50 px for 0.4 s (primary)", options: T(["Lifting Claws", "Longer claws with glowing lift pads; held ground enemies rise, then slam down in a stunning ring."], ["Lifting Pincers", "Longer pincers with lift pads; the lift and the slam ring."], ["Four-Segment Clamp", "A four-segment clamp; the lift and the slam ring."]) },
    { name: "Grip Lock", cost: 1610, effect: "The held enemy's barrier and abilities switch off while held", options: T(["Locked Claws", "A lock on the claws; held enemies show a padlock (barrier and abilities off)."], ["Locked Pincers", "A lock on the pincers; the padlock."], ["Locked Clamp", "A lock on the clamp; the padlock."]) },
    { name: "Gravity Hammer", cost: 5365, effect: "The slam stuns everything within 80 px for 0.8 s and shatters barriers (mastery)", options: T(["Gold Claws", "Gold claws with a gravity glow; the slam ring turns gold, wider, with barrier shards."], ["Gold Pincers", "Gold pincers; the gold slam."], ["Gold Clamp", "A five-segment gold clamp; the gold slam."]) },
  ] },
];
P2.retrofits = [
  { name: "Twin Emitter", cost: 575, effect: "A second, weaker beam holds another enemy at half the pull (stacks with Dual Beam: three beams)", options: T(["Side Barrel", "A second, smaller barrel with claws alongside the main one."], ["Rear Dish", "A small dish emitter on the turret's side."], ["Twin Claws", "A second claw barrel on the other side."]) },
  { name: "Longer Hold", cost: 140, effect: "Holds for 2 s (+0.5 s, stacks with Stronger Beam)", options: T(["Hold Capacitor Ring", "A glowing capacitor ring on the deck round the turret."], ["Hold Battery", "A battery pack on the turret's back."], ["Hold Coils", "Two copper coils round the barrel's base."]) },
  { name: "Faster Recharge", cost: 230, effect: "Recharges in 5 s (-1 s, stacks with Recharge)", options: T(["Cooling Fins", "Cooling fins fanned out at the turret's back."], ["Radiator Panels", "Two radiator panels on the deck."], ["Fan Vent", "A spinning fan vent on the turret."]) },
];
