// ---- Tower art second pass: Tesla Tower (tower 8), round 1 ----------------------------------------------------
// Base: look B Twin Toroid, animation C Corona Burst. One parametric model with the lessons so far (owner, 2026-10-17):
// options swap parts rather than lay overlays over them; the deck kit is static (this tower never turns); every Power
// step changes the arc; masteries are gold; charge timing comes from the engine's own fire clock (view.last), so the
// charge fills in exactly one recharge. All three Retrofits overlap a path step and are kept, their stats stacking (the
// carpet rule): Bigger Disk adds to High Voltage and Taller Coil, Grounding Rods add a jump to Extra Jump, Insulated
// Coils take 0.15 s off the recharge on top of the Speed path.
// Geometry (game px, from the tower's centre): outer toroid R 11 (4 wide) with eight charge nodes, inner toroid R 6.5
// (3 wide), a spire orb r 3.2; the arcs start at the centre.
const PAGE = { title: "Tesla Tower: paths and Retrofits (second pass)", store: "bl-tower-art-p2-tesla-r2" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], COPPER = [0.78, 0.5, 0.28, 1], CERAM = [0.86, 0.85, 0.8, 1];
const YEL = [1, 0.85, 0.3, 1], ORANGE = [1, 0.55, 0.2, 1], MIST = [0.7, 0.62, 0.85, 1];
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null); // the option used at path pi, step k (or null)
function zbolt(a, b, col, w, seed, jit) { const n = 7, d = sub(b, a), o = orth(norm(d)), L = Math.hypot(d[0], d[1]), pts = [a];
  for (let i = 1; i < n; i++) pts.push(add(lerp(a, b, i / n), mul(o, (rnd2(seed + i * 7.3) - 0.5) * L * (jit || 0.28))));
  pts.push(b); polyline(pts, A(col, 0.28 * (col[3] ?? 1)), w * 3); polyline(pts, col, w); polyline(pts, [1, 1, 1, 0.85 * (col[3] ?? 1)], Math.max(0.6, w * 0.4)); return pts; }
function chainOf(first, ens, n, reach) { const out = [first], used = new Set();
  for (const e of ens) if (Math.hypot(e.p[0] - first[0], e.p[1] - first[1]) < 2) used.add(e.i);
  let cur = first;
  for (let j = 0; j < n; j++) { let best = null, bd = reach;
    for (const e of ens) { if (used.has(e.i)) continue; const d = Math.hypot(e.p[0] - cur[0], e.p[1] - cur[1]); if (d < bd) { bd = d; best = e; } }
    if (!best) break; used.add(best.i); out.push(best.p); cur = best.p; }
  return out; }

// ---- Stats the look follows: jumps, recharge, arc falloff, storms -----------------------------------------------------
const jumpsOf = (B) => [3, 3, 4, 5, 6, 7][B.lv[1]] + (B.r === 1 ? 1 : 0);
const RATE = [1.25, 1.11, 1.0, 0.71, 0.625, 0.476]; // seconds per arc: 0.8, 0.9, 1.0, 1.4, 1.6, 2.1 arcs/s
const periodOf = (B) => Math.max(0.4, RATE[B.lv[2]] - (B.r === 2 ? 0.15 : 0));
const ratioOf = (B) => [0.85, 0.85, 0.85, 0.85, 0.92, 0.97][B.lv[0]]; // what each jump keeps of the arc
const flightOf = (B) => (B.lv[1] >= 3 ? 2.0 : B.lv[2] >= 5 ? 0.45 : 0.3);

// ---- The arc: a thick white-cored bolt with side branches that chains; Power thickens it; the storm lingers -------------
function teslaShot(f, to, u, s, col, B, info) { const k = G(s), pts = chainOf(to, info.ens, jumpsOf(B), s * 1.5), seed = Math.floor(info.t * 25), tt = u * flightOf(B);
  const P2s = Kp(B, 0, 1), P3 = Kp(B, 0, 2), PM = Kp(B, 0, 4), c0 = PM ? GOLD : col, w0 = 3.2 + 0.3 * B.lv[0], ratio = ratioOf(B);
  if (tt < 0.3) { const a = 1 - (tt / 0.3) * 0.5;
    const main = zbolt(add(f, mul(norm(sub(to, f)), 8 * k)), to, A(lt(c0, 0.3), a), w0, seed);
    for (const j of [2, 4]) zbolt(main[j], add(main[j], mul(fa(rnd2(seed + j) * TAU), s * 0.3)), A(c0, 0.7 * a), 1.2, seed + j * 5);
    for (let i = 1; i < pts.length; i++) zbolt(pts[i - 1], pts[i], A(c0, a), Math.max(0.8, (w0 - 0.6) * Math.pow(ratio, i)), seed + i * 11);
    for (const p of pts) glowDot(p, s * 0.06 * a, [1, 1, 1, 1]);
    // Overload Circuits: short yellow EMP crackles at every hit
    if (B.lv[0] >= 2) for (const p of pts) for (let j = 0; j < 3; j++) zbolt(p, add(p, mul(fa(rnd2(seed + j * 3 + p[0]) * TAU), s * 0.1)), A(YEL, 0.8 * a), 0.9, seed + j * 13); }
  // Arc Stun: a halo spins round every enemy hit
  if (B.lv[0] >= 3 && tt < 0.7) for (const p of pts) { const v = tt / 0.7; ring(p, s * (0.07 + 0.05 * v), A(c0, 0.8 * (1 - v)), 1.4); for (let j = 0; j < 3; j++) disc(add(p, mul(fa(j * TAU / 3 + tt * 8), s * (0.07 + 0.05 * v))), 1.4, A(c0, 1 - v)); }
  // Storm Field: each landing leaves a crackling storm that fades over 2 s (bigger and gold at the mastery)
  if (B.lv[1] >= 3 && tt < 2) { const fade = 1 - tt / 2, R = (B.lv[1] >= 5 ? 30 : 25) * k, sc = B.lv[1] >= 5 ? GOLD : col;
    for (const p of pts) { disc(p, R, A(sc, 0.1 * fade)); ring(p, R, A(sc, 0.5 * fade), 1);
      for (let j = 0; j < 3; j++) { const sd = Math.floor(info.t * 12) + j * 5 + p[0]; zbolt(add(p, mul(fa(rnd2(sd) * TAU), R * 0.25)), add(p, mul(fa(rnd2(sd + 1) * TAU), R * 0.9)), A(sc, 0.6 * fade), 0.8, sd); } } } }

// ---- The model: this tower never turns, so every part is drawn in a fixed place ---------------------------------------
const P2 = {
  tower: "tesla", look: "B", anim: "C",
  intro: "Round 1: three options for every step and Retrofit, drawn as one model so the paths combine: options swap parts instead of covering them, the tower never turns, every Power step changes the arc (thicker, yellow EMP crackles, a stun halo, gold at the mastery), Range/Chaining adds jumps and a lingering storm, and Speed fires faster up to near-constant lightning. The charge fills in exactly one recharge. The carpet rule applies: all three Retrofits overlap a path step and are kept, their stats stacking. The build preview chains between enemies. Unpicked steps show option A.",
  mods(B) { const per = periodOf(B);
    return { period: per, flight: flightOf(B), multi: false, shot: (f, to, u, s, col, kk, t, info) => teslaShot(f, to, u, s, col, B, info) }; },
  muzzleAt(B, m, kk, c) { return c; },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), per = periodOf(B), g = fx.glow || 0, V = info && info.view, live = V && typeof V.last === "number" && typeof info.t === "number",
      since = live ? Math.max(0, info.t - V.last) : 9, ch = Math.min(1, since / per), S = (x, y) => add(c, [x * k, y * k]), pol = (r, a) => add(c, mul(fa(a), r * k));
    const P1 = Kp(B, 0, 0), P2s = Kp(B, 0, 1), P3 = Kp(B, 0, 2), P4 = Kp(B, 0, 3), PM = Kp(B, 0, 4), R1 = Kp(B, 1, 0), R2 = Kp(B, 1, 1), R3 = Kp(B, 1, 2), R4 = Kp(B, 1, 3), RM = Kp(B, 1, 4);
    const S1 = Kp(B, 2, 0), S2 = Kp(B, 2, 1), S3 = Kp(B, 2, 2), S4 = Kp(B, 2, 3), SM = Kp(B, 2, 4), R = B.r >= 0 ? B.key("r" + B.r) : null;
    const gold = (flag) => (flag ? GOLD : null), nodeCol = PM === "C" ? GOLD : col;
    deck(c, k, col, t);
    // -- Fixed deck kit ---------------------------------------------------------------------------------------------------
    if (P2s === "C") { plate(S(8.5, 12.6), rectPts(3, 2.2), METAL_D, 0, k, 1); glowDot(S(8.5, 12.6), 0.8 * k, fmod(t * 2, 1) < 0.5 ? YEL : A(YEL, 0.3)); }
    if (P3 === "C") for (const sg of [-1, 1]) { plate(S(sg * 13.5, 0), rectPts(2.2, 4), METAL_D, 0, k, 1); for (let i = 0; i < 3; i++) disc(S(sg * 13.5, -2.4 + i * 2.4), 0.8 * k, A(col, ch * 3 > i + 0.3 ? 0.95 : 0.25)); }
    if (P4 === "C") for (let i = 0; i < 4; i++) { const a = Math.PI / 4 + i * Math.PI / 2; bar(pol(13, a), pol(16.6, a), 1.3 * k, COPPER); }
    if (R2 === "B") { }
    if (S1 === "A") for (let i = 0; i < 3; i++) { plate(S(-7.8 + i * 2.6, 13), rectPts(1, 1.8), METAL_D, 0, k, 0.9); bar(S(-7.8 + i * 2.6, 14.4), S(-7.8 + i * 2.6, 14.4 - 2.6 * Math.min(1, Math.max(0, ch * 3 - i))), 1 * k, A(col, 0.95)); }
    if (S1 === "C") { const q = S(-7.5, 12.6); disc(q, 3 * k, OUTLINE); disc(q, 2.5 * k, METAL_D); for (let i = 0; i < 6; i++) ring(q, (0.7 + i * 0.28) * k, mix(COPPER, col, ch * 6 > i ? 0.6 : 0), 0.7 * k); }
    if (S2 === "A") { const q = S(7.5, 12.6); disc(q, 3.2 * k, OUTLINE); disc(q, 2.7 * k, METAL_D); line(q, add(q, mul(fa(-Math.PI * 0.85 + ch * Math.PI * 0.7), 2.4 * k)), WHITE, 1 * k); }
    if (S2 === "C") { bar(S(7.5, 11), S(7.5, 15), 3.4 * k, METAL_L); bar(S(7.5, 14.6), S(7.5, 14.6 - 3.6 * ch), 1.8 * k, A(col, 0.9)); }
    if (S3 === "A") for (const sg of [-1, 1]) { bar(S(sg * 14, -2), S(sg * 14, 4), 3.4 * k, METAL_L); bar(S(sg * 14, 3.6), S(sg * 14, 3.6 - 5.2 * ch), 1.8 * k, A(col, 0.9)); }
    if (S3 === "C") { for (const x of [-5, -1.4]) { bar(S(x, -11), S(x, -13.4), 1 * k, METAL_L); disc(S(x, -13.6), 0.6 * k, STEEL); } if (ch > 0.25) zbolt(S(-5, -13.6), S(-1.4, -13.6), A([0.9, 1, 1, 1], 0.4 + 0.5 * ch), 1 * k, Math.floor(t * (6 + 14 * ch))); }
    if (S4 === "A") { plate(S(0, 14.4), rectPts(3.2, 1.6), METAL_D, 0, k, 1); glowDot(S(1.6, 14.4), 0.7 * k, fmod(t * (2 + 4 * ch), 1) < 0.5 ? ORANGE : A(ORANGE, 0.3)); }
    if (S4 === "B") for (const sg of [-1, 1]) { plate(S(0, sg * 14.6), rectPts(3.4, 1.4), METAL_D, 0, k, 1); for (let i = 0; i < 4; i++) line(S(-2.4 + i * 1.6, sg * 14.6 - 1.1), S(-2.4 + i * 1.6, sg * 14.6 + 1.1), A(ORANGE, 0.7), 0.8 * k); }
    if (SM === "C") for (let i = 0; i < 3; i++) { plate(S(-7.8 + i * 2.6, 13), rectPts(1, 1.8), GOLD, 0, k, 0.9); bar(S(-7.8 + i * 2.6, 14.4), S(-7.8 + i * 2.6, 12.4), 1 * k, A(YEL, 0.95)); }
    if (R2 === "A" || R2 === "C") { }
    if (B.r === 1 && R === "A") for (const [x, y] of [[-8, -12.5], [8, -12.5], [-8, 12.5], [8, 12.5]]) { bar(S(x, y), S(x * 1.2, y * 1.15), 1.4 * k, METAL_L); orb(S(x * 1.22, y * 1.17), 1.1 * k, COPPER); if (g > 0.3 && rnd2(Math.floor(t * 20) + x) > 0.4) glowDot(S(x * 1.25, y * 1.2), 1 * k, col); }
    if (B.r === 1 && R === "B") for (let i = 0; i < 12; i++) { const a = i * TAU / 12 + 0.26; line(pol(13.8, a), pol(15.6, a), METAL_L, 1.1 * k); }
    if (B.r === 1 && R === "C") { const qs = [[-8.5, -13.5], [8.5, -13.5], [8.5, 13.5], [-8.5, 13.5]].map((q) => S(q[0], q[1])); for (let i = 0; i < 4; i++) { disc(qs[i], 1 * k, COPPER); line(qs[i], qs[(i + 1) % 4], A(COPPER, 0.6), 0.8 * k); } }
    if (B.r === 2 && R === "B") for (const [x, y] of [[-8.5, -12.5], [8.5, -12.5]]) { bar(S(x, y), S(x, y + 3), 1.8 * k, CERAM); disc(S(x, y), 1.2 * k, CERAM); }
    // -- The disk and toroids ----------------------------------------------------------------------------------------------
    if (B.r === 0) { const ky = B.key("r0"); disc(c, 14.2 * k, OUTLINE); disc(c, 13.6 * k, METAL_D); if (ky === "B") rivets(c, ngon(12, 1, 0), 0, 13.6 * k, 0.9, 0.7 * k); ring(c, 13.8 * k, A(col, ky === "A" ? 0.2 + 0.4 * g : ky === "C" ? 0.6 : 0.15), (ky === "C" ? 1.8 : 1.2) * k); if (ky === "A") ring(c, 14.8 * k, A(col, 0.1 + 0.25 * g), 1.4 * k); }
    const outerC = PM === "B" ? mix(METAL_L, GOLD, 0.45) : P4 === "A" ? lt(METAL_L, 0.12) : METAL_L;
    for (const [Rr, w] of [[11, 4], [6.5, 3]]) { ring(c, Rr * k, OUTLINE, (w + 1.4) * k); ring(c, Rr * k, Rr > 8 ? outerC : (P4 === "A" ? lt(METAL_L, 0.12) : METAL_L), w * k); arc(c, Rr * k, Math.PI * 1.05, Math.PI * 1.6, lt(METAL_L, 0.4), w * 0.35 * k); }
    if (PM === "B") ring(c, 11 * k, A(GOLD, 0.9), 1.2 * k);
    if (P4 === "A") for (const Rr of [11, 6.5]) arc(c, (Rr + 0.9) * k, Math.PI * 1.15, Math.PI * 1.45, WHITE, 0.8 * k);
    if (P1 === "B") for (let i = 0; i < 28; i++) { const a = i * TAU / 28; line(pol(8.9, a), pol(13.1, a + 0.1), COPPER, 0.9 * k); }
    if (R1 === "A") for (let i = 0; i < 3; i++) ring(c, (5.6 + i * 0.8) * k, i % 2 ? dk(COPPER, 0.15) : COPPER, 0.8 * k);
    if (S2 === "B") for (let i = 0; i < 8; i++) { const a = i * TAU / 8 + 0.2; line(pol(8.2, a), pol(9.8, a), STEEL, 1.2 * k); }
    if (S4 === "C") ring(c, 8.8 * k, A(ORANGE, 0.5 + 0.4 * ch), 1.3 * k);
    if (P2s === "A") for (let i = 0; i < 4; i++) { const q = pol(6.5, i * Math.PI / 2 + 0.4); disc(q, 1.5 * k, OUTLINE); glowDot(q, 0.9 * k, YEL); }
    if (P2s === "B") for (let i = 0; i < 8; i++) { const a = i * TAU / 8 + 0.4; polyline([pol(8, a), pol(8.8, a + 0.08), pol(9.6, a)], A(YEL, 0.85), 0.9 * k); }
    if (P4 === "B") for (let i = 0; i < 4; i++) { const a = i * Math.PI / 2 + 0.78; bar(pol(8, a), pol(9.5, a), 1.6 * k, METAL_L); }
    if (R3 === "A") for (let i = 0; i < 12; i++) { const a = i * TAU / 12; glowDot(pol(15.2, a), 0.6 * k, A(col, 0.4 + 0.5 * Math.sin(t * 3 + i))); }
    if (R3 === "B") for (const [x, y] of [[-9, -12.5], [9, -12.5], [-9, 12.5], [9, 12.5]]) { disc(S(x, y), 1.5 * k, OUTLINE); disc(S(x, y), 1.1 * k, METAL_D); for (let j = 0; j < 2; j++) { const v = fmod(t * 0.6 + j * 0.5 + x * 0.1, 1); disc(add(S(x, y), [0, -v * 5 * k]), (1 + v * 1.6) * k, A(MIST, 0.45 * (1 - v))); } }
    if (R3 === "C") for (let i = 0; i < 6; i++) { const a = i * TAU / 6 + 0.5, p0 = pol(13.6, a), p1 = pol(15.8, a); line(p0, p1, METAL_L, 1.1 * k); if (rnd2(Math.floor(t * 14) + i) > 0.5) glowDot(p1, 0.7 * k, col); }
    if (R4 === "A") { ring(c, 15.8 * k, METAL_D, 1.4 * k); for (let i = 0; i < 4; i++) disc(pol(15.8, i * Math.PI / 2), 1 * k, METAL_L); }
    if (R4 === "B") for (let i = 0; i < 4; i++) { const a = Math.PI / 4 + i * Math.PI / 2; bar(pol(14, a), pol(16.4, a), 1.5 * k, METAL_L); if (rnd2(Math.floor(t * 16) + i) > 0.4) glowDot(pol(16.8, a), 0.8 * k, col); }
    if (R4 === "C") for (let i = 0; i < 4; i++) { const a = Math.PI / 4 + i * Math.PI / 2; line(pol(12.2, a), pol(16.4, a), A(col, 0.4 + 0.4 * g), 0.9 * k); line(pol(14.6, a - 0.15), pol(14.6, a + 0.15), A(col, 0.5), 0.9 * k); }
    if (RM === "A") { ring(c, 15.8 * k, A(GOLD, 0.9), 1.4 * k); for (let i = 0; i < 8; i++) disc(pol(15.8, i * TAU / 8), 1 * k, GOLD); }
    if (RM === "B") for (let i = 0; i < 4; i++) { const a = Math.PI / 4 + i * Math.PI / 2; bar(pol(14, a), pol(16.4, a), 1.8 * k, GOLD); glowDot(pol(16.8, a), 0.8 * k, YEL); }
    if (RM === "C") for (let i = 0; i < 8; i++) { const a = i * TAU / 8; fill(pol(8.4, a), [[0, -0.9], [2.6, 0], [0, 0.9]], GOLD, a, k); }
    if (R2 === "A") for (let i = 0; i < 4; i++) { const a = Math.PI / 4 + i * Math.PI / 2, q = pol(14.6, a); plate(q, rectPts(1.2, 1.2), METAL_D, a, k, 0.9); glowDot(q, 0.6 * k, A(col, 0.3 + 0.7 * g)); }
    if (R2 === "B") for (let i = 0; i < 4; i++) { const a = i * Math.PI / 2; polyline([pol(12.6, a), pol(14.4, a), pol(15.8, a + 0.18)], METAL_L, 1 * k); polyline([pol(14.4, a), pol(15.8, a - 0.18)], METAL_L, 1 * k); }
    if (R2 === "C") for (const [x, y] of [[-9, -12.5], [9, -12.5]]) { ring(S(x, y), 2 * k, METAL_L, 1 * k); glowDot(S(x, y), (0.5 + g) * k, A(col, 0.5 + 0.5 * g)); }
    if (R2 === "C") { }
    if (P3 === "A") for (let i = 0; i < 4; i++) { const a = i * Math.PI / 2; bar(pol(12.6, a), pol(16, a), 1.4 * k, METAL_L); glowDot(pol(16.4, a), 0.7 * k, [0.8, 0.95, 1, 1]); }
    if (P3 === "B") for (let i = 0; i < 4; i++) { const a = Math.PI / 4 + i * Math.PI / 2; arc(c, 13.4 * k, a - 0.38, a + 0.38, METAL_L, 2.2 * k); }
    if (S2 === "C") { }
    if (B.r === 2 && R === "A") for (let i = 0; i < 4; i++) { const a = i * Math.PI / 2 + 0.78; plate(pol(6.5, a), rectPts(1.1, 1.6), CERAM, a, k, 0.9); }
    if (B.r === 2 && R === "C") for (let i = 0; i < 4; i++) { const a = i * Math.PI / 2 + 0.4; arc(c, 6.5 * k, a - 0.3, a + 0.3, CERAM, 3.4 * k); }
    if (S3 === "B") for (let i = 0; i < 8; i++) { const a = i * TAU / 8, on = ch * 8 > i; line(pol(8.2, a), pol(9.6, a), on ? A(col, 0.95) : METAL_D, 1.4 * k); }
    // -- Charge nodes, spire, sparks ---------------------------------------------------------------------------------------
    for (let i = 0; i < 8; i++) { const q = pol(11, i * TAU / 8 + Math.PI / 8); if (P1 === "A") { disc(q, 2.1 * k, OUTLINE); orb(q, 1.7 * k, METAL_L); glowDot(q, (0.9 + 0.5 * g) * k, A(nodeCol, 0.6 + 0.4 * g)); } else { disc(q, 1.2 * k, OUTLINE); glowDot(q, (0.6 + 0.5 * g) * k, A(nodeCol, 0.6 + 0.4 * g)); } }
    if (P1 === "C") { orb(c, 4.8 * k, METAL); ring(c, 3.4 * k, METAL_L, 1 * k); for (let i = 0; i < 4; i++) line(pol(1.6, i * Math.PI / 2), pol(3.6, i * Math.PI / 2), METAL_L, 1 * k); }
    else orb(c, 3.2 * k, METAL);
    if (PM === "A") { orb(c, 3.4 * k, GOLD); for (let i = 0; i < 6; i++) { const a = i * TAU / 6 + 0.3; fill(pol(3.2, a), [[0, -0.8], [3, 0], [0, 0.8]], GOLD, a, k); } }
    if (S1 === "B") arc(c, 4.8 * k, -Math.PI / 2, -Math.PI / 2 + TAU * ch, A(PM ? GOLD : col, 0.95), 1.4 * k);
    if (SM === "A") { ring(c, 4.6 * k, GOLD, 1.3 * k); for (let i = 0; i < 6; i++) disc(pol(4.6, i * TAU / 6 + t * 0.6), 0.8 * k, GOLD); }
    if (SM === "B") for (let i = 0; i < 8; i++) line(pol(8.2, i * TAU / 8), pol(9.6, i * TAU / 8), GOLD, 1.6 * k);
    glowDot(c, (1.6 + 1.8 * g) * k, PM ? GOLD : col);
    for (let i = 0; i < 2 + (B.lv[2] >= 5 ? 3 : 0); i++) { const a = rnd2(Math.floor(t * 12) + i * 3) * TAU; zbolt(pol(8.6, a), pol(4, a + 0.2), A(PM ? GOLD : col, 0.4 + 0.6 * g), 0.7, t * 12 + i); }
  },
  paths: [
    { name: "Power/Damage", theme: "raw voltage: harder arcs, stun and the EMP overload; each step changes the arc", steps: [
      { name: "High Voltage", cost: 125, effect: "+8 damage (40)", options: [
        { key: "A", name: "Fat Nodes", desc: "The eight charge nodes on the outer ring swap for bigger, glowing nodes; the arc is thicker." },
        { key: "B", name: "Copper Winding", desc: "Copper wire wound round the outer toroid; the arc is thicker." },
        { key: "C", name: "Voltage Spire", desc: "A bigger spire at the centre with spokes and a ring; the arc is thicker." } ] },
      { name: "Overload Circuits", cost: 100, effect: "×2 damage to Disruptors; a hit cancels a Capacitor's charge", options: [
        { key: "A", name: "EMP Nodes", desc: "Four yellow EMP nodes on the inner ring; the arc throws yellow crackles at every hit." },
        { key: "B", name: "Circuit Traces", desc: "Glowing yellow circuit traces between the rings; yellow crackles at every hit." },
        { key: "C", name: "Fuse Box", desc: "A fuse box on the deck with a blinking yellow lamp; yellow crackles at every hit." } ] },
      { name: "Arc Stun", cost: 1020, effect: "48 damage; arcs stun for 0.3 s (bosses 0.1 s) (primary)", options: [
        { key: "A", name: "Stun Rods", desc: "Four rods round the outer ring with blue-white tips; a stun halo spins round every enemy hit." },
        { key: "B", name: "Shock Plates", desc: "Four curved shock plates outside the outer ring; a stun halo spins round every hit." },
        { key: "C", name: "Capacitor Banks", desc: "Two capacitor banks either side of the deck whose lamps light as it charges; a stun halo on every hit." } ] },
      { name: "Clean Conduction", cost: 1705, effect: "54 damage; only 8% lost per jump", options: [
        { key: "A", name: "Polished Rings", desc: "Both rings get a bright polished edge; the arc keeps more power on each jump." },
        { key: "B", name: "Conduction Bars", desc: "Four bars join the outer ring to the inner; the arc keeps more power on each jump." },
        { key: "C", name: "Ground Straps", desc: "Four copper ground straps run from the ring to the deck corners; the arc keeps more power on each jump." } ] },
      { name: "Lightning Rod", cost: 4310, effect: "60 damage; 3% lost per jump; stun 0.5 s (mastery)", options: [
        { key: "A", name: "Gold Rod", desc: "A gold spire with gold spikes at the centre; a gold arc and gold stun halos." },
        { key: "B", name: "Gold Outer Ring", desc: "A gold inlay round the outer ring; a gold arc." },
        { key: "C", name: "Gold Nodes", desc: "All the charge nodes turn gold; a gold arc." } ] },
    ] },
    { name: "Range/Chaining", theme: "the storm field: more reach, more jumps, and storms where arcs land", steps: [
      { name: "Taller Coil", cost: 70, effect: "+20 range (160)", options: [
        { key: "A", name: "Extra Windings", desc: "Three copper windings on the inner ring." },
        { key: "B", name: "Antenna Spike", desc: "A tall antenna spike with a tip lamp at the centre." },
        { key: "C", name: "Coil Stack", desc: "A stack of tiers rising from the centre." } ] },
      { name: "Extra Jump", cost: 155, effect: "4 jumps", options: [
        { key: "A", name: "Jump Relays", desc: "Four jump relay boxes outside the outer ring that glow as the arc fires; the arc chains one more time." },
        { key: "B", name: "Forked Antennas", desc: "Four forked antennas outside the outer ring; the arc chains one more time." },
        { key: "C", name: "Relay Coils", desc: "Two relay coils in the deck corners that flare on each arc; the arc chains one more time." } ] },
      { name: "Storm Field", cost: 2260, effect: "5 jumps; each arc leaves a 25 px storm for 2 s (primary)", options: [
        { key: "A", name: "Storm Rim", desc: "A rim of twelve twinkling lamps; every landing leaves a crackling storm that fades over two seconds." },
        { key: "B", name: "Cloud Vents", desc: "Four vents in the corners puffing violet mist; a lingering storm at every landing." },
        { key: "C", name: "Static Rods", desc: "Six thin rods round the ring that spark; a lingering storm at every landing." } ] },
      { name: "Wide Storm", cost: 2390, effect: "+20 range (180); 6 jumps", options: [
        { key: "A", name: "Wide Rim Ring", desc: "A wide ring round the deck with four nodes; the arc chains again." },
        { key: "B", name: "Outer Pylons", desc: "Four outer pylons with spark tips; the arc chains again." },
        { key: "C", name: "Spark Lattice", desc: "Four glowing cross lines out to the deck's edge; the arc chains again." } ] },
      { name: "Tempest", cost: 8140, effect: "7 jumps; storms of 14/s, 30 px (mastery)", options: [
        { key: "A", name: "Gold Storm Ring", desc: "A gold ring with eight gold nodes round the deck; bigger gold storms." },
        { key: "B", name: "Gold Pylons", desc: "Four gold pylons with yellow tips; bigger gold storms." },
        { key: "C", name: "Gold Crown", desc: "A crown of eight gold points round the inner ring; bigger gold storms." } ] },
    ] },
    { name: "Speed", theme: "faster discharges, continuous at the top", steps: [
      { name: "Quick Recharge", cost: 60, effect: "0.9 arcs/s", options: [
        { key: "A", name: "Charge Cells", desc: "Three cells in the corner that fill one after another as it charges." },
        { key: "B", name: "Charge Arc", desc: "A ring round the spire that fills as it charges." },
        { key: "C", name: "Coil Spool", desc: "A spool in the corner whose copper winding lights turn by turn as it charges." } ] },
      { name: "Fast Capacitor", cost: 125, effect: "1.0 arcs/s", options: [
        { key: "A", name: "Rate Dial", desc: "A dial in the corner whose needle swings as it charges." },
        { key: "B", name: "Cooling Fins", desc: "Cooling fins round the inner ring." },
        { key: "C", name: "Capacitor Can", desc: "A can in the corner whose glowing level climbs as it charges." } ] },
      { name: "Rapid Discharge", cost: 995, effect: "1.4 arcs/s (primary)", options: [
        { key: "A", name: "Twin Capacitors", desc: "Two big capacitors either side whose glowing levels climb as it charges." },
        { key: "B", name: "Discharge Spokes", desc: "Eight spokes between the rings that light one after another as it charges." },
        { key: "C", name: "Spark Gap", desc: "Two electrodes in the corner that spark quicker as it charges." } ] },
      { name: "Overclocked Coil", cost: 995, effect: "1.6 arcs/s", options: [
        { key: "A", name: "Overclock Chip", desc: "A chip box with an orange pulse lamp that races as it charges." },
        { key: "B", name: "Heat Sinks", desc: "Two finned heat sinks glowing orange top and bottom." },
        { key: "C", name: "Second Inner Ring", desc: "An extra orange ring between the toroids that brightens as it charges." } ] },
      { name: "Continuous Discharge", cost: 4980, effect: "2.1 arcs/s: near-constant lightning (mastery)", options: [
        { key: "A", name: "Gold Capacitor Crown", desc: "A gold ring with gold nodes round the spire; sparks crawl across the toroids all the time." },
        { key: "B", name: "Gold Spokes", desc: "Eight gold spokes between the rings; sparks crawl all the time." },
        { key: "C", name: "Gold Cells", desc: "A row of gold cells in the corner; sparks crawl all the time." } ] },
    ] },
  ],
  retrofits: [
    { name: "Bigger Disk", cost: 120, effect: "+4 damage (36), +15 range (155) (stacks with High Voltage and Taller Coil)", options: [
      { key: "A", name: "Corona Disk", desc: "A larger dark disk under the toroids with a corona that flares as the arc fires." },
      { key: "B", name: "Riveted Plate", desc: "A larger riveted disk under the toroids." },
      { key: "C", name: "Halo Disk", desc: "A larger disk with a steady glowing halo ring." } ] },
    { name: "Grounding Rods", cost: 65, effect: "+1 jump (4) (stacks with Extra Jump)", options: [
      { key: "A", name: "Corner Rods", desc: "Four grounding rods in the deck corners that spark when the arc fires." },
      { key: "B", name: "Spike Ring", desc: "A ring of twelve earthing spikes round the deck." },
      { key: "C", name: "Stakes and Wire", desc: "Four stakes in the corners joined by a copper wire." } ] },
    { name: "Insulated Coils", cost: 70, effect: "An arc every 1.1 s (stacks with the Speed path)", options: [
      { key: "A", name: "Ceramic Blocks", desc: "Four white ceramic insulator blocks on the inner ring." },
      { key: "B", name: "Insulator Posts", desc: "Two white insulator posts in the top corners." },
      { key: "C", name: "Ceramic Sleeves", desc: "Four white ceramic sleeves round the inner ring." } ] },
  ],
};
// ---- Round 2 (owner's picks, 2026-10-18): every stage shows only the pick; no notes.
P2.intro = "Round 2: all your picks drawn as one model, nothing left to choose. Use the build preview to check combinations; the charge indicators fill in exactly one recharge.";
P2.picks = { p0s0: "A", p0s1: "B", p0s2: "A", p0s3: "C", p0s4: "C", p1s0: "A", p1s1: "A", p1s2: "A", p1s3: "A", p1s4: "B", p2s0: "A", p2s1: "B", p2s2: "B", p2s3: "C", p2s4: "B", r0: "A", r1: "C", r2: "A" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { const pk = P2.picks["p" + pi + "s" + k]; if (pk) st.options = st.options.filter((o) => o.key === pk); }));
P2.retrofits.forEach((rf, ri) => { const pk = P2.picks["r" + ri]; if (pk) rf.options = rf.options.filter((o) => o.key === pk); });
