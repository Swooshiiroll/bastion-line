// ---- Tower art second pass: Magneto Tower (tower 18), round 3 (every stage picked; the innermost emitter ring always clears the coils) ------------------------------------------------------------------------------------------------
// Base: look F Stacked Coil Tower, animation F Drag Trails (tools/tower_art/data_towers4.js). The owner kept the names and chose the parts (2026-10-19):
//  - Path 1, Pull Strength, rebuilds the COIL STACK (thick windings, a tiered stack, or an iron yoke; bigger each step; gold at Absolute Pull).
//  - Path 2, Field Size, rebuilds the BASE into field emitters (emitter rings, pylons, or fold-out field plates; gold with an aurora at Magnetosphere).
//  - Path 3, Polarity, rebuilds the POLE CAP (a split red/blue pole, claws, or spikes); from Torn Plates the stripped plates cling round it; at Reverse
//    Polarity it turns gold and flips red/blue at each repel.
// Each step rebuilds its part in the style picked for that step (the new design replaces the old one); masteries are gold; the agent runs the real rules
// (the slow, the radius, the armour stripping, the repel every 4 s).
// Overlaps kept and stacking (the carpet rule): the Superconducting Coil's +5% slow with Pull Strength, the Field Stabiliser's +15 px with Field Size,
// the Pole Shoes' 30% less resistance with Pull Strength's heavy-role steps.
const PAGE = { title: "Magneto Tower: paths and Retrofits (second pass)", store: "bl-tower-art-p2-magneto-r3" };
const GOLD = [1, 0.78, 0.3, 1], COPPER = [0.78, 0.5, 0.28, 1], STEEL = [0.42, 0.45, 0.5, 1], RED = [0.85, 0.2, 0.2, 1], BLUEP = [0.28, 0.48, 0.95, 1], GREYP = [0.62, 0.64, 0.68, 1], FROST = [0.86, 0.95, 1, 1];
const rnd = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const enemyR = (s) => Math.max(4, Math.min(11, s * 0.12));
function txt(p, str, col, px) { X.save(); X.font = "bold " + Math.round(px) + "px sans-serif"; X.textAlign = "center"; X.fillStyle = css(OUTLINE); X.fillText(str, p[0] + 1, p[1] + 1); X.fillStyle = css(col); X.fillText(str, p[0], p[1]); X.restore(); }
const gl = (col, g, u) => (g ? mix(col, GOLD, u ?? 0.75) : col);
const SLOW = [25, 32, 35, 42, 48, 55], RADS = [120, 130, 140, 155, 170, 195], ARMR = [0, 2, 4, 4, 5, 5], SCALE = [1, 1.04, 1.08, 1.13, 1.17, 1.2];
const slowOf = (B) => SLOW[B.lv[0]] + (B.r === 0 ? 5 : 0), radOf = (B) => RADS[B.lv[1]] + (B.r === 1 ? 15 : 0);
const pk = (B, path, L) => (L > 0 ? B.key("p" + path + "s" + (L - 1)) : null);   // the style picked for the latest step bought on a path

// ---- Path 1, Pull Strength: the coil stack, rebuilt each step (thick windings, a tiered stack, or an iron yoke) -------------------------------------------------
function coilStack(c, k, B, t, col) { const L = B.lv[0], st = pk(B, 0, L), g = L >= 5, cu = g ? GOLD : COPPER, R0 = 12 * SCALE[L], steel = gl(STEEL, g, 0.6), iron = g ? dk(GOLD, 0.45) : METAL_D;
  const nt = [3, 4, 4, 5, 5, 6][L], tiers = st === "B" ? Array.from({ length: nt }, (_, i) => [R0 - i * (R0 - 4.4) / (nt - 1), Math.max(1.8, 3.4 - i * 0.3)]) : [[R0, 3.2], [R0 * 0.717, 2.8], [R0 * 0.45, 2.4]];
  const wm = st === "A" ? 1 + 0.12 * L : 1;
  if (st === "C") { const yw = 1.4 + 0.5 * L, yr = R0 + 1.4 + yw / 2, n = 12 + 2 * L; ring(c, yr * k, OUTLINE, (yw + 1.4) * k); ring(c, yr * k, iron, yw * k);             // the iron yoke under the stack, laminated
    for (let i = 0; i < n; i++) { const a = i * TAU / n; line(add(c, mul(fa(a), (yr - yw / 2) * k)), add(c, mul(fa(a), (yr + yw / 2) * k)), A(OUTLINE, 0.6), 0.8 * k); }
    if (L >= 4) disc(c, R0 * k, A(g ? GOLD : col, 0.22 + 0.1 * Math.sin(t * 4))); }                                                                        // Dense Field (C): flux glows between the coils
  tiers.forEach(([r, w], i) => { const ww = w * wm; ring(c, r * k, OUTLINE, (ww + 1.4) * k); ring(c, r * k, cu, ww * k);
    if (st === "A") { const n = Math.round(r * 2.2); for (let j = 0; j < n; j++) { const a = j * TAU / n + i * 0.1; line(add(c, mul(fa(a), (r - ww * 0.45) * k)), add(c, mul(fa(a), (r + ww * 0.45) * k)), dk(cu, 0.3), 0.6 * k); } if (L >= 3) ring(c, r * k, dk(cu, 0.35), 0.7 * k); }
    if (st === "C") ring(c, (r - ww * 0.28) * k, iron, ww * 0.32 * k);
    arc(c, r * k, Math.PI * 1.05, Math.PI * 1.6, lt(cu, 0.4), ww * 0.35 * k);
    if (L >= 4 && st !== "C") { const a0 = t * (2.2 + 0.6 * i) + i * 2; arc(c, r * k, a0, a0 + 0.7, A(g ? [1, 0.95, 0.7, 1] : lt(col, 0.35), 0.85), ww * 0.5 * k); } });                  // Dense Field: current runs round the windings
  if (L >= 2) { if (st === "A") for (let i = 0; i < 4; i++) { const a = i * Math.PI / 2 + Math.PI / 4, e = add(c, mul(fa(a), (R0 + 1.8) * k)); bar(add(c, mul(fa(a), 3.4 * k)), e, 1.4 * k, steel); disc(e, 0.9 * k, METAL_L); }   // clamp straps
    if (st === "B") for (let i = 0; i < 3; i++) { const a = i * TAU / 3 - Math.PI / 2, e = add(c, mul(fa(a), (R0 + 2.6) * k)); bar(e, add(c, mul(fa(a), 3 * k)), 1.2 * k, steel); plate(e, rectPts(1.4, 1.4), iron, a, k, 1); }   // a three-legged brace
    if (st === "C") for (let i = 0; i < 12; i++) { const a = i * TAU / 12 + 0.13; plate(add(c, mul(fa(a), (R0 + 3.6 + 0.5 * L) * k)), rectPts(1, 0.8), iron, a, k, 0.8); } }                  // grip teeth on the yoke
  return R0; }

// The coil stack's outer edge in units (straps, braces and yoke teeth included), for each style and step
function coilOuter(B) { const L = B.lv[0], st = pk(B, 0, L), R0 = 12 * SCALE[L];
  if (st === "A") return Math.max(R0 + 1.6 * (1 + 0.12 * L) + 0.7, L >= 2 ? R0 + 2.7 : 0);
  if (st === "B") return R0 + (L >= 2 ? 3.3 : 2.4);
  if (st === "C") return Math.max(R0 + 2.8 + 0.5 * L + 0.7, L >= 2 ? R0 + 4.4 + 0.5 * L : 0);
  return R0 + 2.3; }

// ---- Path 2, Field Size: the base rebuilt into field emitters (emitter rings, pylons, or fold-out field plates); gold with an aurora at Magnetosphere -----------
function fieldBase(c, k, B, t, col, over) { const L = B.lv[1], st = pk(B, 1, L), g = L >= 5, fc = g ? GOLD : col, steel = gl(STEEL, g, 0.6); if (!st || over !== (st === "A")) return;
  if (g && !over) for (let i = 0; i < 3; i++) { const a0 = t * 0.4 + i * TAU / 3; arc(c, 23 * k, a0, a0 + 1.4, A([1, 0.9, 0.55, 1], 0.35), 2.4 * k); arc(c, 21.8 * k, -a0, -a0 + 1, A(lt(col, 0.3), 0.3), 1.6 * k); }
  if (st === "A") { const n = [0, 1, 2, 2, 3, 3][L], nodes = 6 + 2 * L, r0 = Math.min(19.5, Math.max(17, coilOuter(B) + 1.2)), rs = Array.from({ length: n }, (_, j) => r0 + j * 2.4);   // round 3 (owner): the innermost ring always clears the coils
    if (g) for (let i = 0; i < 3; i++) { const a0 = t * 0.4 + i * TAU / 3; arc(c, (rs[n - 1] + 1.2) * k, a0, a0 + 1.4, A([1, 0.9, 0.55, 1], 0.35), 2.4 * k); }
    if (L >= 3) for (let i = 0; i < 6; i++) bar(add(c, mul(fa(i * Math.PI / 3), rs[0] * k)), add(c, mul(fa(i * Math.PI / 3), rs[n - 1] * k)), 1.2 * k, steel);       // struts between the rings
    rs.forEach((r, j) => { ring(c, r * k, OUTLINE, 2.6 * k); ring(c, r * k, steel, 1.6 * k); for (let i = 0; i < nodes; i++) { const a = i * TAU / nodes + j * 0.2 + t * 0.2 * (j % 2 ? -1 : 1), q = add(c, mul(fa(a), r * k)); disc(q, 1.1 * k, OUTLINE); glowDot(q, 0.7 * k, fc); } }); }
  if (st === "B") { const n = [0, 3, 4, 6, 6, 8][L], h = 1.6 + 0.35 * L, r = 19.5, ps = Array.from({ length: n }, (_, i) => add(c, mul(fa(i * TAU / n + Math.PI / 6), r * k)));
    if (L >= 3) ps.forEach((q, i) => { const q2 = ps[(i + 1) % n], pts = [q]; for (let j = 1; j < 6; j++) pts.push(add(lerp(q, q2, j / 6), mul(orth(norm(sub(q2, q))), (rnd(j + i * 7 + Math.floor(t * 12)) - 0.5) * 2.4 * k))); pts.push(q2); polyline(pts, A(fc, 0.3), 2.4 * k); polyline(pts, A(lt(fc, 0.3), 0.8), 0.8 * k); });   // arcs link the pylons
    ps.forEach((q, i) => { const a = i * TAU / n + Math.PI / 6; disc(add(q, [k, 1.4 * k]), (h + 0.6) * k, [0, 0, 0, 0.3]); disc(q, (h + 0.8) * k, OUTLINE); disc(q, h * k, steel); ring(q, h * 0.6 * k, gl(COPPER, g, 0.7), 0.8 * k); glowDot(q, (0.7 + 0.2 * L) * k, fc);
      if (L >= 4) { arc(q, (h + 1.4) * k, a - 1, a + 1, OUTLINE, 2 * k); arc(q, (h + 1.4) * k, a - 1, a + 1, steel, 1 * k); } }); }                                         // dishes from Great Field
  if (st === "C") { const ext = 1.6 + 1.1 * L; for (let i = 0; i < 6; i++) { const a = i * Math.PI / 3 + Math.PI / 6, q = add(c, mul(fa(a), (16.6 + ext / 2) * k)), pts = [[-ext / 2, -4.2], [ext / 2, -4.2 - ext * 0.35], [ext / 2, 4.2 + ext * 0.35], [-ext / 2, 4.2]];
      plate(q, pts, gl(METAL_L, g, 0.5), a, k, 1.1); line(add(q, rot([0, -3.6 * k], a)), add(q, rot([0, 3.6 * k], a)), A(fc, 0.6 + 0.3 * Math.sin(t * 3 + i)), 1 * k);
      if (L >= 4) plate(add(q, rot([ext * 0.12 * k, 0], a)), pts.map(([x, y]) => [x * 0.55, y * 0.6]), gl(STEEL, g, 0.6), a, k, 1); } } }                                // a second layer from Great Field

// ---- Path 3, Polarity: the pole cap, rebuilt each step (a split red/blue pole, claws, or spikes); the torn plates cling round it from Torn Plates ---------------------
function poleCap(c, k, B, t, col, mm) { const L = B.lv[2], st = pk(B, 2, L), g = L >= 5, flip = g && (mm.flips || 0) % 2 === 1, rc = flip ? BLUEP : RED, bc = flip ? RED : BLUEP, rim = g ? GOLD : METAL_L, fl = g ? decay(t - (mm.rep ?? -9), 0.6) : 0;
  if (!st) { orb(c, 3 * k, RED); glowDot(c, (1 + 0.5 * Math.sin(t * 5)) * k, col); return; }
  const r = 3 + 0.55 * L;
  if (L >= 3) { const n = 4 + 2 * (L - 3); for (let i = 0; i < n; i++) { const a = i * TAU / n + 0.3; plate(add(c, mul(fa(a), (r + 3) * k)), [[-1.8, -1.2], [1.8, -1], [1.4, 1.2], [-1.5, 1.1]], gl(GREYP, g, 0.4), a + rnd(i), k, 0.9); } }
  if (st === "A") { const sp = L >= 3 ? t * 0.8 : 0.6, half = (a0, cc) => { const pts = [c]; for (let j = 0; j <= 12; j++) pts.push(add(c, mul(fa(a0 + j * Math.PI / 12), r * k))); poly(pts, cc); };
    disc(c, (r + 0.9) * k, OUTLINE); half(sp, rc); half(sp + Math.PI, bc); disc(add(c, [-r * 0.3 * k, -r * 0.3 * k]), r * 0.3 * k, [1, 1, 1, 0.3]);
    bar(add(c, mul(fa(sp), (r + 0.5) * k)), add(c, mul(fa(sp + Math.PI), (r + 0.5) * k)), (0.8 + 0.15 * L) * k, rim); if (L >= 2) ring(c, (r + 1.4) * k, rim, 0.9 * k); }
  if (st === "B") { const n = [0, 3, 3, 4, 5, 6][L], len = 2.8 + 0.45 * L + (L >= 2 ? 1 : 0); orb(c, r * 0.75 * k, rc);
    for (let i = 0; i < n; i++) { const a = i * TAU / n + 0.4, p0 = add(c, mul(fa(a), r * 0.6 * k)), p1 = add(c, mul(fa(a), (r + len) * k)), p2 = add(c, mul(fa(a + 0.5), (r + len * 0.55) * k));
      polyline([p0, p1, p2], OUTLINE, 3 * k); polyline([p0, p1, p2], gl(STEEL, g, 0.7), 1.8 * k); disc(p2, 1 * k, i % 2 ? bc : rc); } }
  if (st === "C") { const n = 4 + L, len = 2.8 + 0.6 * L; for (let i = 0; i < n; i++) { const a = i * TAU / n, pts = [[r * 0.5, -1.2], [r + len, 0], [r * 0.5, 1.2]]; fill(c, pts, i % 2 ? bc : rc, a, k); outline(c, pts, OUTLINE, 1, a, k); }
    orb(c, r * 0.6 * k, rim); }
  if (fl) glowDot(c, (r + 3 * fl) * k, A(flip ? BLUEP : RED, fl));
  glowDot(c, (0.8 + 0.4 * Math.sin(t * 5)) * k, g ? GOLD : col); }

// ---- The Retrofits: the Superconducting Coil frosts the coils, the Field Stabiliser steadies the field, the Pole Shoes sit by the cap ---------------------------------
function stabiliser(c, k, B, t, under) { if (B.r !== 1) return; const key = B.key("r1"); if (under !== (key !== "C")) return;
  if (key === "A") { ring(c, 21.6 * k, OUTLINE, 2.4 * k); ring(c, 21.6 * k, METAL, 1.4 * k); for (let i = 0; i < 3; i++) { const q = add(c, mul(fa(i * TAU / 3 + 0.5), 21.6 * k)); disc(q, 2.6 * k, OUTLINE); disc(q, 2.1 * k, METAL_D); line(add(q, mul(fa(t * 6 + i), -1.8 * k)), add(q, mul(fa(t * 6 + i), 1.8 * k)), METAL_L, 1 * k); } }   // a gyro ring
  if (key === "B") for (let i = 0; i < 3; i++) { const a = i * TAU / 3, q = add(c, mul(fa(a), 18.2 * k)); plate(q, rectPts(3.4, 2.6), METAL_D, a + Math.PI / 2, k, 1.2); hazard(q, a + Math.PI / 2, k, -3, 3, 0, [0.95, 0.75, 0.2, 1], 1); }   // ballast blocks on the deck's corners
  if (key === "C") { const r = 12 * SCALE[B.lv[0]] - 0.6; for (let i = 0; i < 8; i++) { const a0 = i * TAU / 8 + t * 0.25; arc(add(c, [1.2 * k, 1.8 * k]), r * k, a0, a0 + 0.55, [0, 0, 0, 0.25], 2.4 * k); arc(c, r * k, a0, a0 + 0.55, OUTLINE, 2.6 * k); arc(c, r * k, a0, a0 + 0.55, [0.22, 0.2, 0.24, 1], 1.6 * k); } } }   // a floating ferrite halo
function frost(c, k, B, t, R0) { if (B.r !== 0) return; const key = B.key("r0");
  if (key === "A") { ring(c, R0 * k, A(FROST, 0.45), 1.6 * k); for (let i = 0; i < 46; i++) { const a = rnd(i) * TAU, r = R0 * (0.35 + 0.65 * rnd(i + 7)); disc(add(c, mul(fa(a), r * k)), (0.35 + 0.4 * rnd(i + 3)) * k, A(FROST, 0.8)); } }   // white rime on the coils
  if (key === "B") { ring(c, (R0 + 2.2) * k, A(FROST, 0.3), 3.6 * k); ring(c, (R0 + 2.2) * k, A(FROST, 0.85), 0.8 * k); bar(add(c, mul(fa(2.4), (R0 + 2.2) * k)), add(c, mul(fa(2.4), 18 * k)), 1.4 * k, [0.55, 0.75, 0.9, 1]); }   // a cryo jacket with a coolant line
  if (key === "C") for (let i = 0; i < 9; i++) { const u = fmod(t * 0.35 + i / 9, 1), a = i * TAU / 9 + rnd(i) * 0.5; disc(add(c, mul(fa(a), (R0 * 0.8 + u * 10) * k)), (1.2 + u * 3) * k, A(FROST, 0.35 * (1 - u))); } }   // cold vapour spilling off
function poleShoes(c, k, B, t) { if (B.r !== 2) return; const key = B.key("r2"), r = 3 + 0.55 * B.lv[2];
  if (key === "A") for (const sx of [-1, 1]) { const q = add(c, [sx * (r + 3.2) * k, 0]); plate(q, [[-1.6, -2.6], [1.6, -2.2], [1.6, 2.2], [-1.6, 2.6]], METAL_D, sx > 0 ? Math.PI : 0, k, 1.1); }   // two iron shoes flanking the cap
  if (key === "B") { ring(c, (r + 3) * k, OUTLINE, 2.4 * k); ring(c, (r + 3) * k, METAL_D, 1.5 * k); for (let i = 0; i < 4; i++) plate(add(c, mul(fa(i * Math.PI / 2), (r + 3) * k)), rectPts(1, 1), METAL, i * Math.PI / 2, k, 1); }   // a shoe ring with lugs
  if (key === "C") for (let i = 0; i < 4; i++) { const a = i * Math.PI / 2 + Math.PI / 4; plate(add(c, mul(fa(a), (r + 3.4) * k)), [[-1.8, -1.4], [1.8, -0.7], [1.8, 0.7], [-1.8, 1.4]], METAL_D, a + Math.PI, k, 1); } }   // shoe plates pointing in

// ---- The agent: Drag Trails (trails and pull arrows inside the field, the edge glowing) plus the real rules: the slow tag, the field radius, the armour
// plates flying to the cap (with -N), the cracked plates that stay off from Torn Plates, and the repel every 4 s at Reverse Polarity (enemies flung, stunned) ---
function magAgent(B) { return (m, t, info, s, col) => { if (m.rep === undefined) { m.rep = t; m.flips = 0; m.strip = {}; }
  const L3 = B.lv[2], g3 = L3 >= 5, c = info.c, R = s * radOf(B) / 48, eR = enemyR(s), arm = ARMR[L3];
  if (g3 && t - m.rep >= 4) { m.rep = t; m.flips++; }
  const rv = g3 ? decay(t - m.rep, 0.7) : 0, pc = m.flips % 2 ? BLUEP : RED;
  ring(c, R, A(B.lv[1] >= 5 ? GOLD : col, 0.45), 2); ring(c, R - 3, A(col, 0.15), 3);
  txt(add(c, [R * 0.72, -R * 0.72]), "-" + slowOf(B) + "%", A(lt(col, 0.3), 0.9), Math.max(10, s * 0.14));
  if (rv) { ring(c, R * (1 - rv * 0.7), A(pc, rv), 3); disc(c, R, A(pc, 0.08 * rv)); }
  for (const e of info.all) { const d = dist(e.p, c);
    if (d > R) { if (L3 >= 3 && m.strip[e.i]) { polyline([add(e.p, [-eR * 0.55, -eR * 0.35]), add(e.p, [-eR * 0.05, eR * 0.2]), add(e.p, [eR * 0.2, -eR * 0.25]), add(e.p, [eR * 0.6, eR * 0.1])], A([0.95, 0.95, 1, 1], 0.85), 1.2); } continue; }   // Torn Plates: the cracks stay
    const dir = norm(sub(c, e.p)), q = add(e.p, mul(dir, eR + 3));
    for (let i = 1; i <= 4; i++) disc(sub(e.p, [i * eR * 0.6, 0]), eR * (1 - i * 0.15), A(col, 0.25 - i * 0.05));
    line(q, add(q, mul(dir, s * 0.12)), A(col, 0.85), 1.6); fill(add(q, mul(dir, s * 0.12)), [[3, 0], [-1, 2.2], [-1, -2.2]], A(col, 0.85), Math.atan2(dir[1], dir[0]), 1);
    if (arm) { m.strip[e.i] = true; const u = fmod(t * 0.9 + e.i * 0.37, 1), p = lerp(e.p, c, ease(u)); if (u < 0.92) { const pl = [[-2.2, -1.4], [2.2, -1.1], [1.8, 1.4], [-1.9, 1.2]]; fill(p, pl, A(lt(GREYP, 0.15), 1 - u * 0.4), u * 5 + e.i, 1.7); outline(p, pl, A(OUTLINE, 1 - u * 0.4), 1, u * 5 + e.i, 1.7); }
      if (u < 0.35) txt(add(e.p, [0, -eR - 4 - u * 12]), "-" + arm, A([0.8, 0.85, 1, 1], 1 - u / 0.35), Math.max(9, s * 0.13)); }
    if (rv) { const o = add(e.p, mul(dir, -rv * s * 0.25)); disc(o, eR, A(pc, 0.35 * rv)); for (let j = 0; j < 4; j++) disc(add(o, mul(fa(t * 6 + j * TAU / 4), eR + 3)), 1.2, A([1, 1, 0.6, 1], rv)); } } }; }

// ---- The model ----------------------------------------------------------------------------------------------------------------------------------------------------
const P2 = {
  tower: "magneto", look: "F", anim: "F",
  intro: "Round 3, your note: the innermost emitter ring now always sits just outside the coil stack as it grows, and the rings are drawn over the coils, so the field is always visible; the Ferrite Halo now floats over the outer coil, inside the rings. Round 2: every stage is picked (all A: thick windings, emitter rings, the split pole; Retrofits Frost Rime, Ferrite Halo and Shoe Ring) and drawn as one build. Round 1 on the confirmed Stacked Coil Tower, with the names kept (your choice). Each path rebuilds one part, in the style you pick for each step, and the new design replaces the old one: Pull Strength rebuilds the coil stack (thick windings, a tiered stack, or an iron yoke; bigger each step; current runs round it at Dense Field; gold at Absolute Pull); Field Size rebuilds the base into field emitters (emitter rings, pylons, or fold-out field plates; gold with an aurora at Magnetosphere); Polarity rebuilds the pole cap (a split red/blue pole, claws, or spikes); from Torn Plates the stripped armour plates cling round it, and at Reverse Polarity it turns gold and flips red/blue at each repel. The preview runs the real rules: the slow tag and field radius grow, plates fly off enemies to the cap with -2, -4 or -5, stripped enemies stay cracked after leaving from Torn Plates, and the field flips to repel every 4 s at the mastery. Overlapping Retrofits are kept and stack (the carpet rule).",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: magAgent(B) }; },
  muzzleAt(B, m, kk, c) { return c; },
  model(c, aim, s, fx, t, col, info, B) { const k = G(s), mm = fx.mem || {};
    deck(c, k, col, t);
    stabiliser(c, k, B, t, true);
    fieldBase(c, k, B, t, col, false);
    const R0 = coilStack(c, k, B, t, col);
    frost(c, k, B, t, R0);
    stabiliser(c, k, B, t, false);
    fieldBase(c, k, B, t, col, true);                                                     // the emitter rings, over the coils (round 3)
    poleShoes(c, k, B, t);
    poleCap(c, k, B, t, col, mm); },
  paths: [], retrofits: [],
};

// ---- Option tables (names and effects as in design/tower_roster.md) ----------------------------------------------------------------------------------------------
const T = (a, b, c) => [["A", ...a], ["B", ...b], ["C", ...c]].map(([key, name, desc]) => ({ key, name, desc }));
P2.paths = [
  { name: "Pull Strength", theme: "the coil stack: rebuilt each step in the style you pick (thick windings, a tiered stack, or an iron yoke), bigger each step; gold at Absolute Pull", steps: [
    { name: "Stronger Coil", cost: 295, effect: "Slow 32%", options: T(["Thick Windings", "The coils are rewound thicker, striped with dense copper windings."], ["Fourth Coil", "The stack is rebuilt with a fourth, smaller coil on top."], ["Iron Yoke", "The stack is rebuilt on a laminated iron yoke, each coil with an iron core band."]) },
    { name: "Heavy Grip", cost: 565, effect: "Slow 35%; heavy roles resist a quarter less", options: T(["Clamped Windings", "Thicker windings again, clamped by four steel straps."], ["Braced Stack", "Four coils held in a three-legged steel brace."], ["Toothed Yoke", "A wider yoke with iron grip teeth round its rim."]) },
    { name: "Mass Lock", cost: 2060, effect: "Slow 42%; heavy roles resist half as much (primary)", options: T(["Double Windings", "The coils are rebuilt bigger, with double-banded windings and straps."], ["Five-Tier Stack", "The stack is rebuilt bigger with five coils in the brace."], ["Laminated Yoke", "A bigger, wider laminated yoke with more teeth."]) },
    { name: "Dense Field", cost: 2450, effect: "Slow 48%", options: T(["Charged Windings", "Current runs visibly round every winding in violet pulses."], ["Charged Stack", "Five coils, current running round each one."], ["Flux Core", "Violet flux glows between the coils over the iron yoke."]) },
    { name: "Absolute Pull", cost: 13630, effect: "Slow 55%; no role resists: Tanks and bosses are slowed fully (mastery)", options: T(["Gold Windings", "The windings and straps turn gold, with gold current running round them."], ["Gold Stack", "Six gold coils in a gold brace."], ["Gold Yoke", "A gold yoke and gold coils with gold flux glowing between them."]) },
  ] },
  { name: "Field Size", theme: "the base: rebuilt each step into field emitters in the style you pick (emitter rings, pylons, or fold-out field plates); gold with an aurora at Magnetosphere", steps: [
    { name: "Wider Coil", cost: 180, effect: "130 px", options: T(["Emitter Ring", "A ring of glowing emitter nodes circles the deck."], ["Three Pylons", "Three field pylons stand round the deck."], ["Field Plates", "Six field plates fold out from the deck's edges."]) },
    { name: "Field Extender", cost: 395, effect: "140 px", options: T(["Twin Emitter Rings", "Two counter-turning rings of emitter nodes."], ["Four Pylons", "Four bigger field pylons."], ["Longer Plates", "The field plates reach further out."]) },
    { name: "Broad Field", cost: 1290, effect: "155 px (primary)", options: T(["Strutted Rings", "The two rings are rebuilt on six struts, with more nodes."], ["Arc Pylons", "Six pylons, linked by crackling field arcs."], ["Wide Plates", "The plates are rebuilt wider and longer again."]) },
    { name: "Great Field", cost: 2845, effect: "170 px", options: T(["Triple Rings", "Three strutted emitter rings."], ["Dish Pylons", "Six linked pylons with dishes facing out."], ["Layered Plates", "Each plate gets a second layer."]) },
    { name: "Magnetosphere", cost: 10645, effect: "195 px (mastery)", options: T(["Gold Rings", "Three gold emitter rings under a gold aurora."], ["Gold Pylons", "Eight gold pylons linked by arcs, under a gold aurora."], ["Gold Plates", "Gold layered plates under a gold aurora."]) },
  ] },
  { name: "Polarity", theme: "the pole cap: rebuilt each step in the style you pick (a split red/blue pole, claws, or spikes); plates fly off enemies to it; from Torn Plates the torn plates cling round it; gold, flipping red/blue on each repel, at Reverse Polarity", steps: [
    { name: "Plate Puller", cost: 360, effect: "Enemies in the field lose 2 armour while inside", options: T(["Split Pole", "The red cap is rebuilt as a split red-and-blue pole; armour plates fly off enemies to it (-2)."], ["Pole Claws", "Three hooked claws round a red core; plates fly to it (-2)."], ["Pole Spikes", "A crown of five red and blue spikes; plates fly to it (-2)."]) },
    { name: "Plate Ripper", cost: 720, effect: "4 armour", options: T(["Ringed Split Pole", "A bigger split pole inside a steel ring (-4)."], ["Long Claws", "Three longer claws (-4)."], ["Six Spikes", "Six longer spikes (-4)."]) },
    { name: "Torn Plates", cost: 1440, effect: "Pulled armour is gone for good, even after they leave (primary)", options: T(["Turning Split Pole", "The split turns slowly; the torn plates cling round the cap, and stripped enemies stay cracked after they leave."], ["Four Claws", "Four claws; the torn plates cling round the cap, and stripped enemies stay cracked."], ["Seven Spikes", "Seven spikes; the torn plates cling round the cap, and stripped enemies stay cracked."]) },
    { name: "Deep Pull", cost: 2160, effect: "5 armour", options: T(["Great Split Pole", "A bigger turning split pole with more torn plates round it (-5)."], ["Five Claws", "Five claws and more torn plates (-5)."], ["Eight Spikes", "Eight spikes and more torn plates (-5)."]) },
    { name: "Reverse Polarity", cost: 9600, effect: "Every 4 s the field flips to repel: enemies are flung into each other for impact damage and a 0.3 s stun (mastery)", options: T(["Gold Split Pole", "A gold-rimmed split pole whose halves swap red and blue at each repel."], ["Gold Claws", "Six gold claws round a core that swaps red and blue at each repel."], ["Gold Spikes", "A gold crown of spikes that swap red and blue at each repel."]) },
  ] },
];
P2.retrofits = [
  { name: "Superconducting Coil", cost: 210, effect: "Slow 25% to 30% (+5%, stacks with Pull Strength); the coil frosts over", options: T(["Frost Rime", "White rime frosts the coils."], ["Cryo Jacket", "A frosted jacket rings the coils, fed by a coolant line."], ["Cold Vapour", "Cold vapour spills off the coils."]) },
  { name: "Field Stabiliser", cost: 280, effect: "+15 px radius (stacks with Field Size)", options: T(["Gyro Ring", "A steel ring round the deck with three spinning gyros."], ["Ballast Blocks", "Three heavy striped ballast blocks on the deck's corners."], ["Ferrite Halo", "A broken ring of dark ferrite floats round the coils, turning slowly."]) },
  { name: "Pole Shoes", cost: 135, effect: "Heavy roles resist 30% less (stacks with Pull Strength)", options: T(["Iron Shoes", "Two iron pole shoes flank the cap."], ["Shoe Ring", "An iron ring with four lugs round the cap."], ["Shoe Plates", "Four iron shoe plates point in at the cap."]) },
];

// ---- Round 2 picks (owner, 2026-10-19): every stage picked -------------------------------------------------------------------------------------------------------
P2.picks = { p0s0: "A", p0s1: "A", p0s2: "A", p0s3: "A", p0s4: "A", p1s0: "A", p1s1: "A", p1s2: "A", p1s3: "A", p1s4: "A", p2s0: "A", p2s1: "A", p2s2: "A", p2s3: "A", p2s4: "A", r0: "A", r1: "C", r2: "B" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { const pk = P2.picks["p" + pi + "s" + k]; if (pk) st.options = st.options.filter((o) => o.key === pk); }));
P2.retrofits.forEach((rf, ri) => { const pk = P2.picks["r" + ri]; if (pk) rf.options = rf.options.filter((o) => o.key === pk); });
