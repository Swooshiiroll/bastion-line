// ---- Tower art second pass: Augmentation Tower (tower 20), round 1 ---------------------------------------------------------------------------------------------
// Base: look F Nanite Hive, animation D Nanite Swarm (tools/tower_art/data_towers4.js). The owner kept the names and chose the parts (2026-10-19):
//  - Path 1, Energy Conversion, rebuilds the DOME: its hex cells charge cyan, a quarter more each step (charged cells, plasma veins, or big capacitor panels);
//    gold-rimmed with crackling arcs at Overcharge.
//  - The cells (round 4, owner's design): at stock some flicker lavender; each path recolours flickering cells in its colour (Energy blue, Critical Hits red,
//    Ricochet green), more of the array each tier; paths overlap; a mastery fills the array solid in its colour.
//  - Path 3, Ricochet, builds green deflectors ORBITING the dome (plates, orbs, or a mirror ring), more each step; gold-trimmed and wobbling at Pinball.
// Each step rebuilds its part in the style picked for that step; masteries are gold; the agent runs the real rules (energy shots, crits and their multiplier,
// ricochet bounces, the aura's reach, Remote Link's half-strength reach).
// Overlaps kept and stacking (the carpet rule): Amplified Bonus's +5% crit chance with the Critical Hits path.
const PAGE = { title: "Augmentation Tower: paths and Retrofits (second pass)", store: "bl-tower-art-p2-augment-r5" };
const GOLD = [1, 0.78, 0.3, 1], ENC = [0.32, 0.62, 1, 1], CRITC = [1, 0.25, 0.22, 1], RICOC = [0.4, 1, 0.5, 1], COPPER = [0.78, 0.5, 0.28, 1];
const rnd = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const nearestTo = (p, list) => { let best = null, bd = 1e9; for (const e of list) { const d = dist(e.p, p); if (d < bd) { bd = d; best = e; } } return best; };
function txt(p, str, col, px) { X.save(); X.font = "bold " + Math.round(px) + "px sans-serif"; X.textAlign = "center"; X.fillStyle = css(OUTLINE); X.fillText(str, p[0] + 1, p[1] + 1); X.fillStyle = css(col); X.fillText(str, p[0], p[1]); X.restore(); }
const pk = (B, path, L) => (L > 0 ? B.key("p" + path + "s" + (L - 1)) : null);   // the style picked for the latest step bought on a path
const ENERGY = [0, 25, 50, 75, 100, 100], CRIT = [5, 8, 11, 15, 18, 22], RICO = [0, 10, 20, 30, 40, 50];
const critCh = (B) => CRIT[B.lv[1]] + (B.r === 1 ? 5 : 0), critX = (B) => (B.lv[1] >= 5 ? 3 : B.lv[1] >= 3 ? 2.5 : 2), auraOf = (B) => (B.r === 0 ? 144 : 96);

// ---- Path 1, Energy Conversion: the dome; a growing share of its cells charge cyan (charged cells, plasma veins, or big capacitor panels) --------------------------
function hexCells(R, size) { const out = [], step = size * 2; for (let q = -5; q <= 5; q++) for (let r = -5; r <= 5; r++) { const x = (q + r * 0.5) * step, y = r * step * 0.866; if (x * x + y * y > (R - size * 0.8) ** 2) continue; out.push([x, y]); } return out.sort((a, b) => a[0] ** 2 + a[1] ** 2 - b[0] ** 2 - b[1] ** 2); }
function dome(c, k, B, t, col) { const L = B.lv[0], g = L >= 5, R = 12 + 0.25 * L, cs = hexCells(R, 2.2);
  orb(c, R * k, METAL_L);
  for (const [x, y] of cs) outline(add(c, [x * k, y * k]), ngon(6, 1, Math.PI / 6), A(METAL, 0.7), 0.8 * k, 0, 2.2 * k);
  if (g) { ring(c, R * k, GOLD, 1.4 * k); for (let i = 0; i < 2; i++) { const a = cs[Math.floor(rnd(Math.floor(t * 8) + i) * cs.length)], b = cs[Math.floor(rnd(Math.floor(t * 8) + i + 9) * cs.length)], pa = add(c, [a[0] * k, a[1] * k]), pb = add(c, [b[0] * k, b[1] * k]), pts = [pa];
      for (let j = 1; j < 5; j++) pts.push(add(lerp(pa, pb, j / 5), mul(orth(norm(sub(pb, pa))), (rnd(j + i * 7 + Math.floor(t * 14)) - 0.5) * 2.4 * k))); pts.push(pb); polyline(pts, A(i ? lt(ENC, 0.4) : ENC, 0.9), 0.8 * k); } }   // Overcharge: a gold rim and blue arcs (round 5: no gold on the array)
  for (let i = 0; i < 6; i++) glowDot(add(c, mul(fa(t * 1.5 + i), (6 + 6 * fmod(t * 0.5 + i / 6, 1)) * k)), 0.5 * k, col); }   // the nanites (base)

// ---- Path 2, Critical Hits: a gold core crowning the dome (a targeting lens, a tracking eye, or a crystal star), bigger each step; all gold at the mastery --------
function core(c, k, B, t, col, look) { const L = B.lv[1], st = pk(B, 1, L), g = L >= 5; if (!st) return; const r = 2.2 + 0.45 * L;
  if (st === "A") { disc(c, (r + 0.9) * k, OUTLINE); disc(c, (r + 0.2) * k, g ? GOLD : METAL_D); disc(c, r * 0.75 * k, A(lt(GOLD, 0.25), 0.9)); for (let i = 0; i < 4; i++) { const a = i * Math.PI / 2; line(add(c, mul(fa(a), r * 0.35 * k)), add(c, mul(fa(a), r * 0.8 * k)), A(OUTLINE, 0.7), 0.6 * k); }
    if (L >= 3) { arcSegments(c, (r + 1.7) * k, 6 + L, 0.25, t * 0.6, OUTLINE, 1.8 * k); arcSegments(c, (r + 1.7) * k, 6 + L, 0.25, t * 0.6, GOLD, 1 * k); } }   // a targeting lens, then a precision matrix
  if (st === "B") { oval(c, r * 1.5 * k, r * 0.85 * k, look, g ? GOLD : [0.92, 0.92, 0.88, 1], 1.2); const ir = add(c, mul(fa(look), r * 0.3 * k)); disc(ir, r * 0.58 * k, GOLD); if (L >= 3) ring(ir, r * 0.42 * k, dk(GOLD, 0.35), 0.6 * k); disc(ir, r * 0.25 * k, OUTLINE); disc(add(ir, [-r * 0.15 * k, -r * 0.15 * k]), r * 0.1 * k, [1, 1, 1, 0.8]); }   // a tracking eye
  if (st === "C") { const n = 4 + L, pts = []; for (let i = 0; i < n * 2; i++) { const a = t * 0.4 + i * Math.PI / n, rr = i % 2 ? r * 0.45 : r + 1; pts.push([Math.cos(a) * rr, Math.sin(a) * rr]); } fill(c, pts, g ? GOLD : lt(GOLD, 0.1), 0, k); outline(c, pts, OUTLINE, 1, 0, k);
    for (let i = 0; i < n; i++) line(c, add(c, mul(fa(t * 0.4 + i * 2 * Math.PI / n), (r + 1) * k)), A([1, 1, 1, 0.45], 0.6), 0.6 * k); }   // a crystal star
  glowDot(c, (0.6 + 0.25 * L) * k, GOLD); }

// ---- Path 2, Critical Hits, round 2 (owner: "Change the design idea"): instead of a core, gold around and over the dome, more each step (a swirling gold swarm,
// a crown of gold needles round its rim, gold reticle brackets framing it, or gold strike tendrils curling out of it); brighter and denser at Executioner Link
function critOuter(c, k, B, t, col) { const L = B.lv[1], st = pk(B, 1, L), g = L >= 5; if (!st) return; const R = 12 + 0.25 * B.lv[0], gc = g ? lt(GOLD, 0.15) : GOLD;
  if (st === "E") { const n = 2 + 2 * L; for (let i = 0; i < n; i++) { const a = i * TAU / n + 0.2, len = 3 + 0.45 * L, pts = [[R - 0.6, -0.9], [R + len, 0], [R - 0.6, 0.9]]; fill(c, pts, gc, a, k); outline(c, pts, OUTLINE, 0.8, a, k); if (g) glowDot(add(c, mul(fa(a), (R + len) * k)), 0.45 * k, GOLD); } }   // a crown of gold needles
  if (st === "F") { const n = L >= 3 ? 6 : 4, rr = R + 2.4 - 0.15 * L + 0.4 * Math.sin(t * 3), w = (0.9 + 0.12 * L) * k; for (let i = 0; i < n; i++) { const a = t * 0.4 + i * TAU / n, span = 0.42;
      arc(c, rr * k, a - span, a + span, OUTLINE, w + 1.2 * k); arc(c, rr * k, a - span, a + span, gc, w); for (const e of [a - span, a + span]) { const p0 = add(c, mul(fa(e), rr * k)); line(p0, add(c, mul(fa(e), (rr - 1.6) * k)), OUTLINE, w + 1 * k); line(p0, add(c, mul(fa(e), (rr - 1.6) * k)), gc, w); } } }   // reticle brackets
  if (st === "G") { const n = 1 + L; for (let i = 0; i < n; i++) { const a0 = i * TAU / n + 0.4, pts = []; for (let j = 0; j <= 10; j++) { const u = j / 10, r = R - 1 + u * (4 + 0.5 * L), a = a0 + Math.sin(t * 2 + i + u * 3) * 0.35 * u + u * 0.6; pts.push(add(c, mul(fa(a), r * k))); }
      polyline(pts, OUTLINE, 2 * k); polyline(pts, gc, 1.1 * k); glowDot(pts[pts.length - 1], (0.5 + 0.06 * L) * k, GOLD); } } }   // strike tendrils
function critTop(c, k, B, t, col) { const L = B.lv[1], st = pk(B, 1, L); if (st !== "D") return; const g = L >= 5, n = 6 + 4 * L, vr = 3 + 1.3 * L;   // a swirling gold swarm (a vortex from Precision Matrix)
  for (let i = 0; i < n; i++) { const u = fmod(i / n + t * 0.15, 1), a = i * 2.39996 + t * (1.2 + (L >= 3 ? 1.5 * (1 - u) : 0)), r = (2 + vr * (L >= 3 ? u : rnd(i))) * k; const q = add(c, mul(fa(a), r)), sr = (0.7 + (g ? 0.15 : 0)) * k; disc(q, sr + 0.5 * k, A(OUTLINE, 0.8)); disc(q, sr, GOLD); }
  glowDot(c, (0.6 + 0.2 * L) * k, GOLD); }

// ---- The cell lights (round 4, the owner's design): at stock some cells flicker lavender; each path recolours the flickering cells in its colour (Energy
// blue, Critical Hits red, Ricochet green), more of the array each tier; different paths overlap (the later one shows as an inner hex); a mastery fills it solid
const FILL = [0, 0.15, 0.3, 0.45, 0.6, 1];
function cellLights(c, k, B, t, col) { const R = 12 + 0.25 * B.lv[0], cs = hexCells(R, 2.2), N = cs.length, hex = ngon(6, 1, Math.PI / 6), Pc = (i) => add(c, [cs[i][0] * k, cs[i][1] * k]), bk = Math.floor(t * 8), layer = new Array(N).fill(0);
  const L1 = B.lv[0], L2 = B.lv[1], L3 = B.lv[2], st1 = pk(B, 0, L1), st2 = pk(B, 1, L2);
  if (!L1 && !L2 && !L3) { cs.forEach(([x, y], i) => { if (rnd(Math.round(x * 7 + y * 13) + Math.floor(t * 3)) > 0.75) outline(Pc(i), hex, A(col, 0.95), 0.8 * k, 0, 2.2 * k); }); return; }   // stock: the base's lavender flicker
  const paths = [];
  if (L1) paths.push({ L: L1, col: ENC, pick: (i, f) => { const reg = Math.max(1, Math.ceil(f * N * 1.6)); return i < reg && rnd(i * 7.31 + bk) < f * N / reg; } });   // Energy: a growing patch round the centre
  if (L2) paths.push({ L: L2, col: CRITC, pick: (i, f) => { if (st2 === "B") { const c0 = Math.floor(rnd(Math.floor(t * 3) * 5.1) * N), r2 = (cs[i][0] - cs[c0][0]) ** 2 + (cs[i][1] - cs[c0][1]) ** 2; return r2 < (f * 220) * (0.4 + 0.6 * fmod(t * 3, 1)); }
      if (st2 === "C") { const sx = (fmod(t * 0.8, 1) * 2 - 1) * 14; return Math.abs(cs[i][0] - sx) < 1 + f * 12 && rnd(i + bk * 1.3) > 0.25; }
      return rnd(i * 3.1 + bk * 1.7 + 50) < f; } });   // Critical Hits: scattered, bursts, or a sweep
  if (L3) paths.push({ L: L3, col: RICOC, pick: (i, f) => rnd(i * 5.7 + bk * 2.3 + 99) < f });   // Ricochet: scattered
  paths.sort((a, b) => b.L - a.L);   // a solid (mastery) path first, so the others' flickers overlap it
  for (const p of paths) { const f = FILL[p.L], solid = p.L >= 5;
    for (let i = 0; i < N; i++) { if (!solid && !p.pick(i, f)) continue;
      if (layer[i] === 0) { fill(Pc(i), hex, A(p.col, solid ? 0.8 : 0.85), 0, 2.0 * k); outline(Pc(i), hex, lt(p.col, solid ? 0.45 : 0.35), 0.9 * k, 0, 2.2 * k); }   // round 5 (owner): no gold edges on the array
      else { fill(Pc(i), hex, A(p.col, 0.95), 0, 1.15 * k); outline(Pc(i), hex, OUTLINE, 0.6, 0, 1.15 * k); }   // an overlap: the second colour as an inner hex
      layer[i]++; } } }

// ---- Path 3, Ricochet: green deflectors orbiting the dome (plates, orbs, or a mirror ring), more each step; gold-trimmed and wobbling at Pinball -----------------
function plateRing(c, k, L, pc, R, dir, t, g) { const n = [0, 2, 3, 4, 5, 6][L], sp = dir * t * (0.6 + 0.1 * L), trim = g ? GOLD : lt(pc, 0.3);
  for (let i = 0; i < n; i++) { const a = sp + i * TAU / n, rr = R + (g ? Math.sin(t * 5 + i) * 0.6 : 0); arc(c, rr * k, a - 0.3, a + 0.3, OUTLINE, 3 * k); arc(c, rr * k, a - 0.3, a + 0.3, mix(METAL, pc, 0.55), 2 * k); arc(c, (rr - 0.55) * k, a - 0.26, a + 0.26, trim, 0.6 * k); } }
function orbit(c, k, B, t, col) { const rings = [[B.lv[0], ENC], [B.lv[1], CRITC], [B.lv[2], RICOC]].filter(([L]) => L > 0);   // Energy blue, Critical Hits red, Ricochet green
  rings.forEach(([L, pc], i) => plateRing(c, k, L, pc, 14.4 + i * 1.9 + (rings.length === 1 ? 1 : 0), i % 2 ? -1 : 1, t, L >= 5)); }

// ---- The Retrofits: Wide Aura (the aura's reach), Amplified Bonus (by the core), Remote Link (a relay) --------------------------------------------------------------
function retro(c, k, B, t, col, over) { if (B.r < 0 || over !== (B.r === 1)) return; const key = B.key("r" + B.r);   // Amplified Bonus draws over the dome (round 3)
  if (B.r === 0) { if (key === "A") { ring(c, 18.6 * k, A(col, 0.55), 1 * k); for (let i = 0; i < 6; i++) glowDot(add(c, mul(fa(i * Math.PI / 3), 18.6 * k)), 0.6 * k, col); }   // an aura ring
    if (key === "B") for (let i = 0; i < 3; i++) { const q = add(c, mul(fa(i * TAU / 3 - Math.PI / 2), 17.4 * k)); disc(q, 1.9 * k, OUTLINE); disc(q, 1.5 * k, METAL); glowDot(q, (0.6 + 0.2 * Math.sin(t * 4 + i)) * k, col); }   // aura pylons
    if (key === "C") for (let i = 0; i < 3; i++) { const a = i * TAU / 3 + Math.PI / 6, q = add(c, mul(fa(a), 16.6 * k)); plate(q, rectPts(2.6, 0.9), METAL_D, a + Math.PI / 2, k, 0.9); fill(q, rectPts(2, 0.4), A(col, 0.6 + 0.3 * Math.sin(t * 3 + i)), a + Math.PI / 2, k); } }   // aura vents
  if (B.r === 1) { if (key === "A") for (const r of [5.2, 6.4]) { ring(c, r * k, OUTLINE, 1.4 * k); ring(c, r * k, COPPER, 0.8 * k); }   // amplifier coils round the core
    if (key === "B") arcSegments(c, 9.4 * k, 8, 0.3, t * 0.5, GOLD, 0.9 * k);   // a gold halo
    if (key === "C") for (let i = 0; i < 4; i++) { const a = i * Math.PI / 2 + Math.PI / 4; fill(c, [[11, -1], [14.5, 0], [11, 1]], GOLD, a, k); outline(c, [[11, -1], [14.5, 0], [11, 1]], OUTLINE, 0.8, a, k); } }   // booster fins
  if (B.r === 2) { if (key === "A") { const q = add(c, [-14 * k, 9 * k]); disc(q, 2.6 * k, OUTLINE); disc(q, 2.1 * k, METAL); arc(q, 2.2 * k, -2.4, -0.6, METAL_L, 1 * k); glowDot(q, 0.6 * k, RICOC); }   // a relay dish
    if (key === "B") for (const sx of [-1, 1]) { const b = add(c, [sx * 11 * k, -10 * k]), tip = add(b, [sx * 3 * k, -4 * k]); line(b, tip, OUTLINE, 1.6 * k); line(b, tip, METAL_L, 0.8 * k); glowDot(tip, 0.5 * k, A(RICOC, fmod(t * 2 + sx, 1) < 0.5 ? 1 : 0.3)); }   // relay antennae
    if (key === "C") { const q = add(c, [0, 15.5 * k]); plate(q, rectPts(1.8, 1.2), METAL_D, 0, k, 1); glowDot(add(q, [0, -0.4 * k]), 0.8 * k, A(RICOC, fmod(t * 1.5, 1) < 0.3 ? 1 : 0.35)); } } }   // a link beacon

// ---- The agent: Nanite Swarm (nanite specks drift to each tower in range and cling round it, tinted by the effects it gets) plus the real rules: energy shots
// (cyan, a share by Energy Conversion), crits (gold, ×2 to ×3, more often as the chance rises), ricochets (green, chaining at Pinball), the aura's reach, and
// Remote Link's half-strength tower at twice the reach --------------------------------------------------------------------------------------------------------------
function critBurst2(p, v, s, x) { if (v >= 1) return; glowDot(p, s * 0.1 * (1 - v), GOLD); for (let i = 0; i < 6; i++) { const d = fa(i * TAU / 6 + 0.3); line(add(p, mul(d, s * (0.06 + 0.2 * v))), add(p, mul(d, s * (0.12 + 0.24 * v))), A(GOLD, 1 - v), 1.4); } txt(add(p, [0, -s * 0.22 - v * s * 0.2]), "CRIT ×" + x, A(GOLD, 1 - v), Math.max(9, s * 0.15)); }
function augAgent(B) { return (m, t, info, s, col) => { if (!m.shots) { m.shots = []; m.n = 0; m.last = {}; }
  const L1 = B.lv[0], L3 = B.lv[2], c = info.c, R = s * auraOf(B) / 48, k = G(s), tints = [col]; if (L1) tints.push(ENC); if (B.lv[1]) tints.push(GOLD); if (L3) tints.push(RICOC);
  ring(c, R, A(col, 0.3), 1.2);
  const mates = matesOf(info).map((mt) => ({ ...mt, f: 1 })); if (B.r === 2) { mates.push({ p: add(c, mul([-1.9, -0.8], s)), col: [0.95, 0.85, 0.4, 1], f: 0.5 }); ring(c, R * 2, A(col, 0.15), 1); }
  const critEvery = Math.max(2, Math.round(30 / critCh(B)));
  mates.forEach((mt, i) => { const foe = nearestTo(mt.p, info.ens), aim = foe ? Math.atan2(foe.p[1] - mt.p[1], foe.p[0] - mt.p[0]) : undefined;
    for (let j = 0; j < 6; j++) { const q = fmod(t * 0.5 + j / 6 + i * 0.13, 1), pp = add(lerp(c, mt.p, q), mul(fa(t * 3 + j * 2), s * 0.05)); disc(pp, 1.1, A(tints[j % tints.length], 0.8 * mt.f)); }
    mateTower(mt.p, k, mt.col, t, 0, col, aim);
    for (let j = 0; j < 5; j++) disc(add(mt.p, mul(fa(t * 2.4 + j * 1.3 + i), s * 0.2)), 1, A(tints[j % tints.length], 0.85 * mt.f));
    if (mt.f < 1) txt(add(mt.p, [0, -s * 0.36]), "half", A(col, 0.8), Math.max(8, s * 0.11));
    if (foe && fmod(t * 1.2 + i * 0.33, 1) < 0.02 && t - (m.last[i] ?? -9) > 0.5) { m.last[i] = t; m.n++; const j = m.n; m.shots.push({ t0: t, from: P(mt.p, aim, k * 0.75, 15, 0), id: foe.i, crit: j % critEvery === 0, energy: L1 >= 4 || (j % 4) < L1, rico: (j % 10) < L3 }); } });
  m.shots = m.shots.filter((q) => t - q.t0 < 1.2);
  for (const q of m.shots) { const e = info.all.find((x) => x.i === q.id); if (!e) continue; const u = (t - q.t0) / 0.18, sc = q.crit ? GOLD : q.energy ? ENC : [1, 0.9, 0.7, 1];
    if (u < 1) { tracer(q.from, e.p, u, sc, q.crit ? 2.2 : q.energy ? 1.8 : 1.4, 0.3); continue; }
    const v = (u - 1) * 0.18 / 0.6; if (q.crit) critBurst2(e.p, v, s, critX(B)); else spark(e.p, v, s * 0.6, sc);
    if (q.energy && L1 >= 5 && v < 0.6) txt(add(e.p, [s * 0.18, -s * 0.12 - v * s * 0.2]), "+10%", A(ENC, 1 - v / 0.6), Math.max(8, s * 0.12));
    if (q.rico && v < 1) { let from = e.p, used = [e.i], hops = L3 >= 5 ? 2 : 1;   // the bounce (and a second at Pinball)
      for (let h = 0; h < hops; h++) { const o = nearestTo(from, info.all.filter((x) => !used.includes(x.i) && dist(x.p, from) < s * 60 / 48 * 1.6)); if (!o) break; const w = Math.min(1, Math.max(0, v * 2.5 - h)); if (w <= 0) break;
        line(from, lerp(from, o.p, w), A(RICOC, 0.9), 1.4); if (w >= 1) spark(o.p, Math.min(0.99, v * 2.5 - h - 1), s * 0.5, RICOC); used.push(o.i); from = o.p; } } } }; }

// ---- The model ----------------------------------------------------------------------------------------------------------------------------------------------------
const P2 = {
  tower: "augment", look: "F", anim: "D",
  intro: "Round 5: every stage is picked (all A; Wide Aura A, Amplified Bonus B, Remote Link C). Your notes: no gold on the array (a solid array keeps a lighter edge in its own colour; Overcharge's arcs are blue); every path now has a ring of orbiting plates in its colour, like Ricochet's (Energy blue, Critical Hits red, Ricochet green), more plates each tier, the rings nesting and turning in turn. Round 4, your design for the cells: at stock some flicker lavender; each path recolours the flickering cells in its own colour (Energy blue, Critical Hits red, Ricochet green), lighting more of the array each tier; different paths overlap (the second colour shows as an inner hex); a path's mastery fills the whole array solid in its colour, with the other path still flickering over it. Critical Hits picks how its red spreads (scattered, bursts, or a sweep). The deflector plates and the rest stay as picked. Round 3, your notes: Energy's charged cells flicker blue; Critical Hits is now the dome's cells flickering red (on solid cells too), more each step, in three ways (random flickers, bursts spreading from a cell, or a sweep across the dome), gold-edged at Executioner Link; Ricochet's cells flicker green, a flash hopping from cell to cell like a bounce, beside the deflector plates; Amplified Bonus's parts (the gold halo too) now draw over the dome, where they show. Round 2, your picks and note: Energy Conversion (charged cells), Ricochet (deflector plates) and Wide Aura (the aura ring) are picked. Critical Hits gets a new idea, four ways at every step: a swirling gold nanite swarm over the dome (a vortex from Precision Matrix), a crown of gold needles round its rim, gold reticle brackets framing it, or gold strike tendrils curling out of it, more each step and brightest at Executioner Link. Amplified Bonus and Remote Link are open. Round 1 on the confirmed Nanite Hive, with the names kept (your choice). Each path rebuilds one part, in the style you pick for each step: Energy Conversion rebuilds the dome, a quarter more of its cells charging cyan each step (charged cells, plasma veins spreading from the centre, or big capacitor panels; gold-rimmed with crackling arcs at Overcharge); Critical Hits crowns the dome with a gold core (a targeting lens with a turning precision ring from Precision Matrix, a tracking eye, or a turning crystal star), bigger each step, all gold at Executioner Link; Ricochet builds green deflectors orbiting the dome (plates, orbs, or a segmented mirror ring), more each step, gold-trimmed and wobbling at Pinball. The preview runs the real rules: the nanites drifting to each tower are tinted by the effects it gets; shots turn cyan as Energy Conversion grows (+10% at Overcharge); crits land gold with their multiplier (×2, ×2.5, ×3) and come more often as the chance grows; ricochets bounce green to a nearby enemy (twice at Pinball); Wide Aura widens the ring; Remote Link adds a tower at twice the reach that gets half strength. Overlapping Retrofits are kept and stack (the carpet rule).",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: augAgent(B) }; },
  muzzleAt(B, m, kk, c) { return c; },
  model(c, aim, s, fx, t, col, info, B) { const k = G(s), foe = nearestTo(c, info?.all || []), look = foe ? Math.atan2(foe.p[1] - c[1], foe.p[0] - c[0]) : 0;
    deck(c, k, col, t);
    retro(c, k, B, t, col, false);
    dome(c, k, B, t, col);
    cellLights(c, k, B, t, col);
    orbit(c, k, B, t, col);
    retro(c, k, B, t, col, true); },
  paths: [], retrofits: [],
};

// ---- Option tables (names and effects as in design/tower_roster.md) ----------------------------------------------------------------------------------------------
const T = (a, b, c) => [["A", ...a], ["B", ...b], ["C", ...c]].map(([key, name, desc]) => ({ key, name, desc }));
const TK = (...o) => o.map(([key, name, desc]) => ({ key, name, desc }));
P2.paths = [
  { name: "Energy Conversion", theme: "a ring of blue plates orbiting the dome, more each tier (round 5), and the dome's cells flicker blue, a growing patch round the centre, more each tier (round 4, your design); Overcharge fills every cell solid blue, in the style you pick (charged cells, plasma veins, or big capacitor panels); gold-rimmed with arcs at Overcharge", steps: [
    { name: "Charged Rounds", cost: 105, effect: "25% of nearby towers' damage counts as energy", options: T(["Charged Cells", "The flickering cells round the dome's centre turn blue, more each tier; a share of the shots fly blue."], ["Plasma Veins", "Cyan plasma veins spread from the dome's centre through a quarter of its cells."], ["Capacitor Panels", "The dome is rebuilt with big hex panels, a quarter of them charged cyan."]) },
    { name: "Plasma Coating", cost: 205, effect: "50%", options: T(["Half-Charged Dome", "Half the cells glow cyan; half the shots fly cyan."], ["Spreading Veins", "The veins reach half the cells."], ["Half-Charged Panels", "Half the panels charge."]) },
    { name: "Energy Weave", cost: 410, effect: "75% (primary)", options: T(["Woven Dome", "Three quarters of the cells glow."], ["Woven Veins", "The veins reach three quarters of the cells."], ["Woven Panels", "Three quarters of the panels charge."]) },
    { name: "Full Conversion", cost: 820, effect: "100%: every nearby tower's damage is energy, so even Ballistic and Explosive towers can hurt the Wraith", options: T(["Full Dome", "Every cell glows cyan; every shot flies cyan."], ["Full Veins", "The veins reach every cell."], ["Full Panels", "Every panel is charged."]) },
    { name: "Overcharge", cost: 4375, effect: "100% energy, plus +10% bonus energy damage (mastery)", options: T(["Gold Charged Dome", "Every cell is solid blue, under a gold rim with arcs crackling over it; hits show +10%."], ["Gold Veins", "Gold-rimmed, the veins everywhere, with arcs; +10%."], ["Gold Panels", "Gold-rimmed charged panels with arcs; +10%."]) },
  ] },
  { name: "Critical Hits", theme: "a ring of red plates orbiting the dome, more each tier (round 5), and the dome's cells flicker red, more of the array each tier, in the style you pick (scattered, bursts spreading from a cell, or a sweep across the dome), overlapping other paths' colours (round 4, your design); Executioner Link fills every cell solid red", steps: [
    { name: "Targeting Assist", cost: 80, effect: "8% crit chance", options: T(["Scattered Red", "Scattered cells flicker red."], ["Red Bursts", "Red flickers burst outward from one cell to its neighbours."], ["Red Sweep", "A red band sweeps across the dome, flickering the cells it passes."]) },
    { name: "Weak-Point Scan", cost: 165, effect: "11%", options: T(["More Red", "More cells flicker red."], ["Bigger Bursts", "Bigger bursts."], ["Wider Sweep", "A wider band."]) },
    { name: "Precision Matrix", cost: 1260, effect: "15%; crits do ×2.5 (primary)", options: T(["Red Array", "Nearly half the array flickers red; crits show ×2.5."], ["Wide Bursts", "Wide bursts; crits show ×2.5."], ["Broad Sweep", "A broad band; crits show ×2.5."]) },
    { name: "Lethal Matrix", cost: 985, effect: "18%", options: T(["Dense Red", "Most of the array flickers red."], ["Wider Bursts", "Wider bursts."], ["Broader Sweep", "A broader band."]) },
    { name: "Executioner Link", cost: 7440, effect: "22%; crits do ×3 (mastery)", options: T(["Solid Red", "Every cell is solid red, edged in gold; crits show ×3."], ["Solid Red", "Every cell is solid red, edged in gold; crits show ×3."], ["Solid Red", "Every cell is solid red, edged in gold; crits show ×3."]) },
  ] },
  { name: "Ricochet", theme: "green deflectors orbiting the dome, and the dome's cells flickering green, more each tier (round 4, your design); Pinball fills every cell solid green; in the style you pick (plates, orbs, or a mirror ring), more each step; gold-trimmed and wobbling at Pinball", steps: [
    { name: "Deflector Rounds", cost: 135, effect: "10% of hits bounce to another enemy within 60 px at 50% damage", options: T(["Deflector Plates", "Two curved green deflector plates orbit the dome; one hit in ten bounces green."], ["Bounce Orbs", "Two green orbs orbit the dome."], ["Mirror Ring", "A segmented mirror ring turns round the dome, glinting."]) },
    { name: "Bounce Coating", cost: 275, effect: "20%", options: T(["Three Plates", "Three plates; two hits in ten bounce."], ["Three Orbs", "Three orbs."], ["Finer Mirror Ring", "More mirror segments."]) },
    { name: "Ricochet Field", cost: 1205, effect: "30%; bounces at 70% (primary)", options: T(["Four Plates", "Four plates, orbiting faster."], ["Ringed Orbs", "Four orbs on a green ring."], ["Fast Mirror Ring", "More segments, turning faster."]) },
    { name: "Chain Bounce", cost: 1530, effect: "40%", options: T(["Five Plates", "Five plates."], ["Five Orbs", "Five orbs."], ["Dense Mirror Ring", "A dense mirror ring."]) },
    { name: "Pinball", cost: 7660, effect: "50%; a bounce can bounce again (mastery)", options: T(["Gold Plates", "Six gold-trimmed plates that wobble as they orbit; bounces chain twice."], ["Gold Orbs", "Six gold-ringed orbs, wobbling; bounces chain twice."], ["Gold Mirror Ring", "A gold mirror ring; bounces chain twice."]) },
  ] },
];
P2.retrofits = [
  { name: "Wide Aura", cost: 170, effect: "A 3-tile radius (144 px)", options: T(["Aura Ring", "A glowing aura ring round the deck with six nodes."], ["Aura Pylons", "Three small aura pylons on the deck."], ["Aura Vents", "Three glowing aura vents in the deck."]) },
  { name: "Amplified Bonus", cost: 135, effect: "The stock crit chance doubles to 10% (+5%, stacks with Critical Hits)", options: T(["Amplifier Coils", "Two copper coils round the core."], ["Gold Halo", "A broken gold halo turns over the dome."], ["Booster Fins", "Four gold booster fins round the dome."]) },
  { name: "Remote Link", cost: 75, effect: "Towers up to twice its radius away get its effects at half strength", options: T(["Relay Dish", "A small relay dish on the deck; a far tower shows 'half'."], ["Relay Antennae", "Two blinking relay antennae."], ["Link Beacon", "A blinking link beacon on the deck."]) },
];

// ---- Round 5 picks (owner, 2026-10-20): every stage picked ------------------------------------------------------------------------------------------------------
P2.picks = { p0s0: "A", p0s1: "A", p0s2: "A", p0s3: "A", p0s4: "A", p1s0: "A", p1s1: "A", p1s2: "A", p1s3: "A", p1s4: "A", p2s0: "A", p2s1: "A", p2s2: "A", p2s3: "A", p2s4: "A", r0: "A", r1: "B", r2: "C" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { const pk = P2.picks["p" + pi + "s" + k]; if (pk) st.options = st.options.filter((o) => o.key === pk); }));
P2.retrofits.forEach((rf, ri) => { const pk = P2.picks["r" + ri]; if (pk) rf.options = rf.options.filter((o) => o.key === pk); });
