// ---- Tower art second pass: Railgun (tower 7), round 1 -----------------------------------------------------------
// Base: look B Sealed Accelerator, animation A Snap Shot. One parametric model with the lessons so far (owner, 2026-10-17):
// options swap parts rather than lay overlays over them; the deck kit is static and only the rail housing turns; every
// extra rail carries every detail; each Power step changes the shot; masteries are gold; mouths no bigger than their
// housing; hubs and drums above the housing. Overlapping Retrofits stack (the carpet rule): Capacitor Coils take 0.3 s
// off the recharge on top of the Speed path, and Penetrator Tips take 10% off the falloff on top of Penetrator Core.
// Geometry (game px, x along the aim, y to the side): housing x -4 to 24, 8 wide; collars at 3, 10, 17; capacitor drum
// r 6.5 at x -8; the slug is a thin bright line (a Snap Shot) with a slug head, hitting every enemy on its line.
const PAGE = { title: "Railgun: paths and Retrofits (second pass)", store: "bl-tower-art-p2-railgun-r2" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], COPPER = [0.78, 0.5, 0.28, 1], RED = [0.85, 0.2, 0.18, 1];
const ORANGE = [1, 0.55, 0.2, 1], TUNG = [0.2, 0.21, 0.24, 1], CERAM = [0.86, 0.85, 0.8, 1];
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null); // the option used at path pi, step k (or null)
function onLine(from, to, ens, s) { const d = norm(sub(to, from)), o = orth(d);
  return ens.map((e) => { const w = sub(e.p, from); return { p: e.p, along: dot(w, d), off: Math.abs(dot(w, o)) }; }).filter((h) => h.along > 0 && h.off < s * 0.2).sort((a, b) => a.along - b.along); }
const farPoint = (from, to, W) => add(from, mul(norm(sub(to, from)), W * 1.6));
function zag(a, b, col, w, seed) { const n = 7, d = sub(b, a), o = orth(norm(d)), L = Math.hypot(d[0], d[1]), pts = [a];
  for (let i = 1; i < n; i++) pts.push(add(add(a, mul(d, i / n)), mul(o, (rnd2(seed + i * 1.7) - 0.5) * L * 0.25))); pts.push(b); polyline(pts, col, w); }

// ---- Rails: one housing, or two (Twin Rails); lengths from Extended Rails and the Longer Rails Retrofit ---------------
function railsOf(B) { const S = B.lv[1];
  if (S >= 5) { const st = Kp(B, 1, 4); if (st === "B") return { w: 5.6, pos: [[2.5, -5], [-2.5, 5]] }; if (st === "C") return { w: 4.6, pos: [[0, -7.5], [0, 7.5]], wind: true }; return { w: 6.4, pos: [[0, -3.5], [0, 3.5]], clamps: true }; }
  return { w: 8 + (Kp(B, 0, 0) === "A" ? 1.6 : 0) + (B.r === 1 && B.key("r1") === "B" ? 1.2 : 0), pos: [[0, 0]] }; }
const lenOf = (B) => 24 + (B.lv[1] >= 2 ? ({ A: 4, B: 0, C: 3 }[Kp(B, 1, 1)] || 0) : 0) + (B.r === 1 ? 3 : 0);
// Recharge (s): the Speed path, minus the Capacitor Coils Retrofit (stacked), plus Overcharge's longer charge.
const RECH = [2.5, 2.2, 2.2, 1.6, 1.35, 1.2];
const periodOf = (B) => Math.max(0.8, RECH[B.lv[1]] - (B.r === 0 ? 0.3 : 0)) + (B.lv[0] >= 5 ? 0.8 : B.lv[0] >= 3 ? 0.5 : 0);
// Falloff per enemy pierced: 40%, Penetrator Core 25%, Hot Rail 15%, Ion Cannon none; the Penetrator Tips take 10% off (stacked).
const falloffOf = (B) => (B.lv[2] >= 5 ? 0 : Math.max(0, [0.4, 0.4, 0.25, 0.25, 0.15][B.lv[2]] - (B.r === 2 ? 0.1 : 0)));

// ---- The shot: a line through every enemy on it, with a slug head; Power thickens and tints it; the trail lingers -------
function railShot(f, to, u, s, col, B, info) { const e = farPoint(f, info.sh.to0, info.W), d = norm(sub(e, f)), o = orth(d), L = Math.hypot(e[0] - f[0], e[1] - f[1]), k = G(s);
  const P1 = Kp(B, 0, 0), P2 = Kp(B, 0, 1), P3 = Kp(B, 0, 2), P4 = Kp(B, 0, 3), PM = Kp(B, 0, 4), ion = B.lv[2] >= 3, fall = falloffOf(B);
  const tc = PM ? GOLD : col, w0 = 2.2 + 0.45 * B.lv[0], a = ion ? (u < 0.15 ? 1 : 0.55 * (1 - u)) : 1 - u * 0.9;
  beam(f, e, w0 * (ion && u >= 0.15 ? 0.55 : 1 - u * 0.5), tc, a);
  if (P2) for (const sg of [-1, 1]) line(add(f, mul(o, sg * w0 * 0.9)), add(e, mul(o, sg * w0 * 0.9)), A(RED, 0.5 * a), 0.8);
  if (P4) line(f, e, A([1, 1, 1, 1], 0.7 * a), 0.8);
  if (P3 && u < 0.3) for (const sg of [-1, 1]) line(add(f, mul(o, sg * w0 * 1.4)), add(lerp(f, e, 0.25), mul(o, sg * w0 * 1.1)), A(tc, 0.5 * (1 - u / 0.3)), 1);
  // The slug head runs ahead of the line: dark and pointed with the Penetrator Tips.
  const hp = lerp(f, e, Math.min(1, u * 3)), dk = B.r === 2;
  if (u < 0.34) { bar(sub(hp, mul(d, s * 0.07)), hp, (1.6 + 0.3 * B.lv[0]) * k * 0.55, dk ? TUNG : [1, 1, 1, 1]); if (dk) fill(add(hp, mul(d, s * 0.02)), [[1.8, 0], [0, 0.7], [0, -0.7]], dk ? STEEL : tc, Math.atan2(d[1], d[0]), k); glowDot(hp, 0.9 * k, tc); }
  // Hits: each enemy on the line flashes, smaller after each (the falloff); Shatter cracks them; the ion trail keeps burning.
  onLine(f, info.sh.to0, info.ens, s).forEach((h, i) => { const w = (u - h.along / L) / (ion ? 1 : 0.25), sz = s * 0.13 * Math.pow(1 - fall, i);
    if (ion ? (u * 1 > h.along / L && u < 0.9) : (w > 0 && w < 1)) glowDot(h.p, sz * (ion ? 0.6 : 1 - w * 0.9), PM ? GOLD : [1, 1, 1, 1]);
    if (B.lv[2] >= 1 && (ion ? u > h.along / L : w > 0 && w < 1)) for (let j = 0; j < 4; j++) { const an = j * TAU / 4 + 0.5; line(add(h.p, mul(fa(an), sz * 0.3)), add(h.p, mul(fa(an + 0.25), sz * 0.8)), A(Kp(B, 2, 0) ? ORANGE : [1, 1, 1, 1], 0.7), 1); } });
  if (ion && u > 0.1) for (let i = 0; i < 6; i++) { const q = fmod(i / 6 + u * 0.7, 1), p = lerp(f, e, q * 0.6), oo = mul(o, s * 0.08); zag(sub(p, oo), add(p, oo), A(PM ? GOLD : col, 0.7 * (1 - u)), 0.8, Math.floor(u * 20) + i); } }

// ---- The model ---------------------------------------------------------------------------------------------------
const P2 = {
  tower: "railgun", look: "B", anim: "A",
  intro: "Round 1: three options for every step and Retrofit, drawn as one model so the paths combine: options swap parts instead of covering them, the deck kit is fixed and only the rail housing turns, Twin Rails carry every detail on both housings, every Power step changes the shot, and masteries are gold. The carpet rule applies: all three Retrofits overlap a path step and are kept, their stats stacking. The build preview fires at enemies on a line. Unpicked steps show option A.",
  mods(B) { const per = periodOf(B), ion = B.lv[2] >= 3;
    return { period: per, flight: ion ? 1.0 : 0.35, multi: false,
      shot: (f, to, u, s, col, kk, t, info) => railShot(f, to, u, s, col, B, info) }; },
  muzzleAt(B, m, kk, c, aim, s, info) { const T = railsOf(B), k = G(s), i = m % T.pos.length, [x, y] = T.pos[i]; return P(c, aim, k, x + lenOf(B) + 2, y); },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), T = railsOf(B), n = T.pos.length, L = lenOf(B), since = fx.barrelSince ?? 9, per = periodOf(B), ch = Math.min(1, since / (per * 0.92)), fl = decay(since, 0.15), shots = fx.shots || 0;
    const S = (x, y) => P(c, 0, k, x, y), last = (shots - 1 + n * 1000) % n;
    const P1 = Kp(B, 0, 0), P2 = Kp(B, 0, 1), P3 = Kp(B, 0, 2), P4 = Kp(B, 0, 3), PM = Kp(B, 0, 4), S1 = Kp(B, 1, 0), S2 = Kp(B, 1, 1), S3 = Kp(B, 1, 2), S4 = Kp(B, 1, 3), SM = Kp(B, 1, 4);
    const X1 = Kp(B, 2, 0), X2 = Kp(B, 2, 1), X3 = Kp(B, 2, 2), X4 = Kp(B, 2, 3), XM = Kp(B, 2, 4), R = B.r >= 0 ? B.key("r" + B.r) : null;
    deck(c, k, col, t);
    // -- Fixed deck kit (never turns) --------------------------------------------------------------------------------
    if (P1 === "B") { plate(S(-13, -11), rectPts(4.2, 2.4), AMMO, 0, k, 0.9); for (let i = 0; i < 3; i++) bar(S(-15.4 + i * 2.4, -11), S(-14 + i * 2.4, -11), 1.6 * k, B.lv[0] >= 5 ? GOLD : METAL_L); }
    // Fast Capacitors (round 2 ideas): a coolant loop to the drum, a spark gap that sparks faster as it charges, a cable reel
    const dcen = P(c, aim, k, -8, 0);
    if (S1 === "A") { plate(S(-13, 11), rectPts(2.8, 2.2), [0.25, 0.5, 0.58, 1], 0, k, 1); const a0 = S(-10.5, 10.4); line(a0, dcen, [0.3, 0.55, 0.62, 1], 1.6 * k);
      for (let j = 0; j < 3; j++) glowDot(lerp(a0, dcen, fmod(t * (0.4 + 1.2 * ch) + j / 3, 1)), 0.6 * k, [0.5, 0.85, 1, 1]); }
    if (S1 === "B") { plate(S(-13, 11.5), rectPts(3.2, 1.2), METAL_D, 0, k, 1); for (const x of [-14.4, -11.6]) { bar(S(x, 10.6), S(x, 8.6), 1 * k, METAL_L); disc(S(x, 8.4), 0.6 * k, STEEL); }
      if (ch > 0.12) zag(S(-14.4, 8.4), S(-11.6, 8.4), A([0.9, 1, 1, 1], 0.5 + 0.5 * ch), 1 * k, Math.floor(t * (6 + 14 * ch))); }
    if (S1 === "C") { const q = S(-13, 10.5), sp = t * (1 + 9 * ch); disc(q, 3.4 * k, OUTLINE); disc(q, 3 * k, METAL_D); ring(q, 2.2 * k, A(col, 0.3 + 0.5 * ch), 0.8 * k); for (let i = 0; i < 3; i++) line(add(q, mul(fa(sp + i * TAU / 3), 0.6 * k)), add(q, mul(fa(sp + i * TAU / 3), 2.6 * k)), METAL_L, 1 * k); orb(q, 0.9 * k, METAL); line(add(q, [2.4 * k, -1 * k]), dcen, [0.15, 0.15, 0.18, 1], 1.5 * k); }
    // Rapid Capacitors C: a charge reservoir whose level climbs as it charges. Special: etching tank (Shatter B), core magazine (Core B), ion grid (Trail C)
    if (S3 === "C") { bar(S(14, -7), S(14, -12.5), 3.8 * k, METAL_L); bar(S(14, -7.6), S(14, -7.6 - 4.4 * ch), 2 * k, A(PM ? GOLD : col, 0.9)); ring(S(14, -12.5), 1.6 * k, METAL_D, 0.9 * k); }
    if (X1 === "B") { plate(S(6, 12.4), rectPts(3, 1.8), [0.35, 0.55, 0.15, 1], 0, k, 1); line(S(3, 11.4), S(0, 6), [0.15, 0.2, 0.1, 1], 1 * k); }
    if (X2 === "B") { plate(S(14, 11), rectPts(4.4, 2.4), AMMO, 0, k, 0.9); for (let i = 0; i < 4; i++) bar(S(11 + i * 0.4, 9.2 + i * 0.9), S(16.4 + i * 0.4, 9.2 + i * 0.9), 0.7 * k, i % 2 ? STEEL : TUNG); }
    if (X3 === "C") { plate(S(6, 12.4), rectPts(3.6, 2.2), METAL_D, 0, k, 1); for (let i = -1; i <= 1; i++) line(S(6 + i * 2, 10.8), S(6 + i * 2, 14), A(col, 0.3 + 0.6 * ch), 0.8 * k); for (const y of [11.8, 13]) line(S(2.8, y), S(9.2, y), A(col, 0.3 + 0.6 * ch), 0.8 * k); }
    if (R === "C" && B.r === 0) for (let i = 0; i < 3; i++) { disc(S(-6 + i * 3, -12.6), 1.6 * k, OUTLINE); disc(S(-6 + i * 3, -12.6), 1.2 * k, COPPER); ring(S(-6 + i * 3, -12.6), 1.2 * k, A(col, 0.3 + 0.7 * ch), 0.8 * k); }
    if (B.r === 2 && R === "C") { plate(S(-6, 12.6), rectPts(4.6, 1.4), AMMO, 0, k, 0.9); for (let i = 0; i < 3; i++) { bar(S(-9 + i * 3, 12.6), S(-7.4 + i * 3, 12.6), 1.2 * k, TUNG); fill(S(-6.8 + i * 3, 12.6), [[1.2, 0], [0, 0.6], [0, -0.6]], STEEL, 0, k); } }
    if (P3 === "A") for (const sg of [-1, 1]) { const q0 = S(-2, sg * 11.5), q1 = S(3, sg * 11.5); bar(q0, q1, 3.4 * k, METAL_L); bar(q0, add(q0, [1.2 * k, 0]), 3.4 * k, METAL_D); ring(lerp(q0, q1, 0.5), 1.2 * k, A(col, 0.3 + 0.7 * ch), 0.9 * k); line(add(q0, [0, -sg * 2 * k]), S(-1, sg * 8), METAL_D, 1 * k); }
    if (P3 === "C") for (const sg of [-1, 1]) { bar(S(-14.5, sg * 9.5), S(-14.5, sg * 12), 1.8 * k, METAL_L); disc(S(-14.5, sg * 9), 1 * k, A(PM ? GOLD : col, 0.4 + 0.6 * ch)); }
    // -- The rails (the housing turns); each carries the same details ---------------------------------------------------
    const hot = false, colr = PM === "A" ? GOLD : P1 === "C" ? TUNG : hot ? mix(METAL_L, ORANGE, 0.5) : METAL_L;
    for (let i = 0; i < n; i++) { const [xo, y] = T.pos[i], r = (i === last ? decay(since, 0.3) : 0) * 2.5, w = T.w * k, hw = T.w * 0.68, x0 = xo - 4 - r, x1 = xo + L - r, Pt = (x, yy) => P(c, aim, k, x, y + (yy || 0));
      const across = (x, h, cc, lw) => line(add(Pt(x - r, 0), mul(orth(fa(aim)), h * k)), add(Pt(x - r, 0), mul(orth(fa(aim)), -h * k)), cc, lw * k);
      if (T.wind) for (let j = 0; j < 9; j++) { const x = xo + 2 + j * 2.8 - r; line(P(c, aim, k, x, y - 3), P(c, aim, k, x + 1, 0), mix(COPPER, col, ch * 3 > j / 3 ? 0.7 : 0), 0.9 * k); }
      // The housing as a tube: a flat-ended body shaded like a cylinder (a bright upper edge, a dark lower edge), so it reads
      // as a barrel rather than a bar; the open mouth is drawn at its end below.
      const cen = Pt((x0 + x1) / 2, 0), ox = mul(orth(fa(aim)), 1);
      const tel = S2 === "A", xe = tel ? x1 - 4 : x1; // Telescoping Barrel: a narrower inner tube slides out of the housing
      plate(Pt((x0 + xe) / 2, 0), rectPts((xe - x0) / 2, T.w / 2), METAL, aim, k, 1.1);
      if (tel) { plate(Pt((xe + x1) / 2 - 0.2, 0), rectPts((x1 - xe) / 2 + 0.2, T.w * 0.35), lt(METAL, 0.06), aim, k, 1.1); line(Pt(xe, 0), Pt(x1, 0), A(dk(METAL, 0.3), 0.5), w * 0.2); }
      line(Pt(x0, 0), Pt(xe, 0), A(dk(METAL, 0.3), 0.55), w * 0.3); // underside shade
      line(add(Pt(x0, 0), mul(ox, -w * 0.32)), add(Pt(xe, 0), mul(ox, -w * 0.32)), A(lt(METAL, 0.22), 0.8), w * 0.14); // highlight along the top
      // Slot strip, then the Power/Special marks on the housing
      strip(Pt(xo - 2 - r, 0), Pt(xo + L - 1 - r, 0), 0.8 * k * (n > 1 ? 0.8 : 1), A(PM ? GOLD : col, Math.min(1, 0.2 + 0.6 * ch + 3 * (i === last ? fl : 0))));
      if (P2 === "A") line(Pt(xo + 2 - r, hw * 0.55), Pt(xo + L - 4 - r, hw * 0.55), RED, 1.4 * k);
      if (P2 === "B") { across(xo + 12, T.w * 0.54, RED, 1.1); across(xo + 13.6, T.w * 0.54, RED, 0.8); }
      if (P2 === "C") for (const sg of [-1, 1]) plate(Pt(xo + 10 - r, sg * (T.w * 0.6)), rectPts(4.2, 1), RED, aim, k, 0.9);
      // Rangefinder (B): a box with twin lenses on the housing's side. Guide Rails (C): two slim rails alongside that run on past the mouth.
      if (S2 === "B") { const q = Pt(xo + 4 - r, -T.w * 0.78); plate(q, rectPts(3.6, 1.7), METAL_D, aim, k, 1); for (const sg of [-1, 1]) glowDot(Pt(xo + 6.4 - r, -T.w * 0.78 + sg * 0.8), 0.55 * k, sg > 0 ? [1, 0.3, 0.3, 1] : A(col, 0.5 + 0.5 * ch)); for (let j = 0; j < 4; j++) line(Pt(xo + 1.6 + j * 0.9 - r, -T.w * 0.78 - 1.2), Pt(xo + 1.6 + j * 0.9 - r, -T.w * 0.78 - (j % 2 ? 1.9 : 2.5)), METAL_L, 0.6 * k); }
      if (S2 === "C") for (const sg of [-1, 1]) { const yy = sg * (T.w * 0.5 + 1.2); bar(Pt(xo + 4 - r, yy), Pt(xo + L + 2 - r, yy), 1.2 * k, METAL_L); for (const x of [8, 14, 20]) line(Pt(xo + x - r, yy), Pt(xo + x - r, sg * T.w * 0.5), METAL_D, 0.9 * k); }
      if (R === "A" && B.r === 0) for (let j = 0; j < 5; j++) { const x = xo + 2 + j * 4 - r; line(Pt(x, -hw * 0.5), Pt(x + 1.6, hw * 0.5), mix(COPPER, col, ch * 5 > j ? 0.7 : 0), 1.1 * k); }
      if (B.r === 1 && R === "A") for (const sg of [-1, 1]) line(Pt(xo - 2 - r, sg * hw * 0.78), Pt(xo + L - 3 - r, sg * hw * 0.78), METAL_L, 1.1 * k);
      if (B.r === 1 && R === "C") for (const x of [xo + 6, xo + 14]) across(x, hw * 0.86, METAL_L, 1.1);
      // Collars (tungsten, hot or gold as the picks say), at the base positions plus one by the muzzle for longer housings
      const band = (x) => { plate(Pt(xo + x - r, 0), rectPts(1.2, T.w * 0.6), colr, aim, k, 1); line(add(Pt(xo + x - r - 0.5, 0), mul(ox, -T.w * 0.5 * k)), add(Pt(xo + x - r - 0.5, 0), mul(ox, T.w * 0.5 * k)), A(lt(colr, 0.25), 0.7), 0.8 * k); };
      for (const x of [3, 10, 17]) band(x);
      if (L > 24) band(S2 === "A" ? L - 4 : L - 3.6);
      // Overcharge B, the Spiral Coil: a copper helix round the rear of the housing that lights up turn by turn as it charges
      if (P3 === "B") for (let j = 0; j < 6; j++) { const x = xo + 0 + j * 2.1 - r; line(Pt(x, -T.w * 0.5), Pt(x + 1.8, T.w * 0.5), mix(COPPER, PM ? GOLD : col, ch * 6 > j ? 0.75 : 0), 1.3 * k); }
      if (PM === "C") for (let j = 0; j < 5; j++) { const a = aim + (j - 2) * 0.5, q = Pt(xo + L - 1 - r, 0); line(add(q, mul(fa(a), 1 * k)), add(q, mul(fa(a), 3.2 * k)), GOLD, 1.1 * k); }
      if (P4 === "A") plate(Pt(xo + L - 1.2 - r, 0), rectPts(1.4, hw * 0.9), METAL_L, aim, k, 1);
      if (P4 === "C") fill(Pt(xo + L + 0.6 - r, 0), [[3.2, 0], [0, 1.4], [0, -1.4]], mix(METAL_L, col, 0.2), aim, k);
      if (B.r === 2 && R === "B") fill(Pt(xo + L + 0.6 - r, 0), [[2.6, 0], [0, 1], [0, -1]], TUNG, aim, k);
      if (SM) ring(Pt(xo + L + 0.4 - r, 0), hw * 0.38 * k, GOLD, 1.1 * k);
      // Supercapacitors (round 2 ideas): field rings, copper bus bars, a cryo jacket
      if (S4 === "A") for (const x of [6.5, 13.5, 20.5]) across(xo + x, T.w * 0.56, A(PM ? GOLD : col, 0.3 + 0.7 * ch), 1.1);
      if (S4 === "B") for (const sg of [-1, 1]) { line(Pt(xo + 0 - r, sg * T.w * 0.58), Pt(xo + L - 6 - r, sg * T.w * 0.58), COPPER, 1.3 * k); for (let j = 0; j < 4; j++) disc(Pt(xo + 2 + j * 5 - r, sg * T.w * 0.58), 0.6 * k, lt(COPPER, 0.25)); }
      if (S4 === "C") { plate(Pt(xo + 4.5 - r, 0), rectPts(4.5, T.w * 0.6), [0.55, 0.75, 0.9, 1], aim, k, 1); for (let j = 0; j < 5; j++) disc(Pt(xo + 1 + j * 1.8 - r, ((j * 7) % 5 - 2) * T.w * 0.18), 0.45 * k, [0.92, 0.97, 1, 0.9]); }
      // Rapid Capacitors B: a spine of small capacitor discs along the housing that light in sequence as it charges
      if (S3 === "B") for (let j = 0; j < 5; j++) { const q = Pt(xo + 2 + j * 3 - r, -T.w * 0.72); disc(q, 1.1 * k, OUTLINE); disc(q, 0.8 * k, ch * 5 > j ? A(PM ? GOLD : col, 0.95) : METAL_D); }
      // Shatter Rounds (round 2 ideas): resonator fork (A), impact studs (C)
      if (X1 === "A") { const v = Math.sin(t * 40) * 0.3 * (ch > 0.9 ? 1 : 0); plate(Pt(xo + L + 0.4 - r, 0), rectPts(0.8, 1.6), METAL_L, aim, k, 0.9); for (const sg of [-1, 1]) bar(Pt(xo + L + 1 - r, sg * 1.4), Pt(xo + L + 4.4 - r, sg * (1.9 + v)), 0.8 * k, METAL_L); }
      if (X1 === "C") for (let j = 0; j < 6; j++) disc(Pt(xo + L - 8 + (j % 3) * 2.2 - r, (j < 3 ? -1 : 1) * T.w * 0.3), 0.7 * k, lt(METAL_L, 0.2));
      // Penetrator Core (round 2 ideas): drill tip (A), lance prongs (C)
      if (X2 === "A") { fill(Pt(xo + L + 0.4 - r, 0), [[4.4, 0], [0, 1.5], [0, -1.5]], STEEL, aim, k); for (let j = 0; j < 2; j++) line(Pt(xo + L + 0.8 + j * 1.4 - r, -1.2 + j * 0.5), Pt(xo + L + 1.8 + j * 1.4 - r, 1.2 - j * 0.5), [0, 0, 0, 0.55], 0.7 * k); }
      if (X2 === "C") { for (const sg of [-1, 1]) line(Pt(xo + L - 5 - r, sg * T.w * 0.5), Pt(xo + L + 3.5 - r, sg * 0.4), METAL_L, 1 * k); line(Pt(xo + L - r, 0), Pt(xo + L + 4.4 - r, 0), STEEL, 0.9 * k); }
      // Ionised Trail (round 2 ideas): ion fins (A), a plasma tube (B)
      if (X3 === "A") for (const sg of [-1, 1]) { fill(Pt(xo + L - 7 - r, sg * T.w * 0.5), [[0, 0], [6, 0], [1.8, sg * 2.6]], METAL_D, aim, k); line(Pt(xo + L - 5.2 - r, sg * T.w * 0.5 + sg * 1.4), Pt(xo + L - 1 - r, sg * T.w * 0.5), A(PM ? GOLD : col, 0.5 + 0.4 * Math.sin(t * 5)), 1 * k); }
      if (X3 === "B") { const a0 = Pt(xo + 2 - r, T.w * 0.62), a1 = Pt(xo + L - 3 - r, T.w * 0.62); bar(a0, a1, 1.8 * k, [0.18, 0.22, 0.22, 1]); for (let j = 0; j < 5; j++) glowDot(lerp(a0, a1, fmod(t * 0.9 + j / 5, 1)), 0.5 * k, PM ? GOLD : col); }
      // Hot Rail (round 2 ideas): glowing rail edges (A), steam vents (B), a heat-fin block (C)
      if (X4 === "A") for (const sg of [-1, 1]) { line(Pt(xo - 2 - r, sg * T.w * 0.5), Pt(xo + L - 1 - r, sg * T.w * 0.5), A(ORANGE, 0.25), 3 * k); line(Pt(xo - 2 - r, sg * T.w * 0.5), Pt(xo + L - 1 - r, sg * T.w * 0.5), A(ORANGE, 0.95), 1.2 * k); }
      if (X4 === "B") for (const x of [7, 14]) { plate(Pt(xo + x - r, 0), rectPts(0.9, 1.1), METAL_D, aim, k, 0.9); for (let j = 0; j < 2; j++) { const v = fmod(t * 0.7 + j * 0.5 + x * 0.1, 1); disc(add(Pt(xo + x - r, 0), [0, -v * 6 * k]), (0.8 + v * 1.4) * k, [0.8, 0.82, 0.84, 0.5 * (1 - v)]); } }
      if (X4 === "C") { plate(Pt(xo + 10 - r, -T.w * 0.7), rectPts(6, 1.4), METAL_D, aim, k, 1); for (let j = 0; j < 4; j++) line(Pt(xo + 5.4 + j * 2.4 - r, -T.w * 0.7 - 1.1), Pt(xo + 5.4 + j * 2.4 - r, -T.w * 0.7 + 1.1), A(ORANGE, 0.95), 1 * k); }
      // Ion Cannon (round 2 ideas): a gold spine (B), a gold emitter funnel (C); the gold lens ring (A) is on the mouth below
      if (XM === "B") { plate(Pt(xo + L - 8 - r, -T.w * 0.12), rectPts(6, 0.8), GOLD, aim, k, 0.9); for (let j = 0; j < 4; j++) line(Pt(xo + L - 12 + j * 2.4 - r, -T.w * 0.12 - 0.8), Pt(xo + L - 12 + j * 2.4 - r, -T.w * 0.12 + 0.8), [0, 0, 0, 0.5], 0.7 * k); }
      if (XM === "C") fill(Pt(xo + L - 2.6 - r, 0), [[0, T.w * -0.34], [2.6, T.w * -0.52], [2.6, T.w * 0.52], [0, T.w * 0.34]], GOLD, aim, k);
      // The mouth: no bigger than the housing
      // The open mouth: a lip ring squashed along the aim, the dark bore inside, and the charge glow (never wider than the housing)
      { const mp = Pt(xo + L - r, 0), ry = T.w * 0.5 * k * (S2 === "A" ? 0.7 : 1), mc = PM ? GOLD : col, f = i === last ? fl : 0;
        oval(mp, ry * 0.5, ry * 1.04, aim, lt(METAL_L, 0.08), 1.2); oval(add(mp, mul(fa(aim), 0.5 * k)), ry * 0.36, ry * 0.76, aim, BORE);
        oval(add(mp, mul(fa(aim), 0.8 * k)), ry * 0.22, ry * 0.5, aim, A(mc, 0.3 + 0.7 * Math.max(ch * 0.4, f)));
        if (XM === "A") { oval(add(mp, mul(fa(aim), 0.2 * k)), ry * 0.62, ry * 1.06, aim, GOLD, 1.8); oval(add(mp, mul(fa(aim), 0.6 * k)), ry * 0.36, ry * 0.76, aim, BORE); oval(add(mp, mul(fa(aim), 0.9 * k)), ry * 0.22, ry * 0.5, aim, A(mc, 0.3 + 0.7 * Math.max(ch * 0.4, f))); }
        if (f > 0) glowDot(add(mp, mul(fa(aim), 1.5 * k)), (1.2 + 5 * f) * k, A(mc, f)); } }
    if (T.clamps) for (const x of [3, 10, 17]) plate(P(c, aim, k, x, 0), rectPts(1.2, 3.5 + T.w * 0.62), colr, aim, k, 1);
    // -- Capacitor drum(s): above the housing, with the charge ring ----------------------------------------------------
    const big = false, two = false, rd = two ? (big ? 5.4 : 4.4) : big ? 7.6 : 6.5, dpos = two ? [[-8, -5.6], [-8, 5.6]] : [[-8, 0]];
    for (const [dx, dy] of dpos) { const dr = P(c, aim, k, dx, dy); orb(dr, rd * k, METAL_L); ring(dr, rd * 0.68 * k, METAL_D, 1.6 * k);
      arc(dr, rd * 0.68 * k, -Math.PI / 2, -Math.PI / 2 + TAU * ch, A(PM || SM ? GOLD : col, 0.95), 1.4 * k); // Kingslayer: the charge-up arc goes gold (owner's note), not the whole drum
      if (P4 === "B") arc(dr, rd * 0.9 * k, -Math.PI / 2, -Math.PI / 2 + TAU * ch, A(PM ? GOLD : col, 0.8), 1 * k);
      if (S3 === "A") { for (let j = 0; j < 8; j++) { const a = j * TAU / 8; line(add(dr, mul(fa(a), rd * 0.9 * k)), add(dr, mul(fa(a), (rd + 1.6) * k)), METAL_L, 1 * k); } ring(dr, (rd + 1.5) * k, A(col, 0.3 + 0.7 * ch), 1.1 * k); }
      if (SM === "C") for (let j = 0; j < 3; j++) disc(add(dr, mul(fa(j * TAU / 3 + t * 0.4), rd * 0.34 * k)), 0.6 * k, GOLD);
      if (B.r === 0 && R === "B") for (let j = 0; j < 10; j++) { const a = j * TAU / 10; line(add(dr, mul(fa(a), (rd - 0.4) * k)), add(dr, mul(fa(a + 0.5), (rd + 0.8) * k)), mix(COPPER, col, ch), 1 * k); }
      glowDot(dr, 1.4 * k, col); }
    // Overcharge C, the Arc Pylons: sparks jump from the pylon tips to the drum as the shot charges
    if (P3 === "C") for (const sg of [-1, 1]) for (let j = 0; j < 2; j++) if (ch > 0.15 + j * 0.3) zag(S(-14.5, sg * 9), add(P(c, aim, k, -8, 0), mul(fa(aim + (sg > 0 ? 1.9 : -1.9)), 4 * k)), A(PM ? GOLD : col, 0.5 + 0.5 * ch), 0.9 * k, Math.floor(t * 14) + j + sg * 5);
  }
};
const TANK2 = [0.2, 0.35, 0.3, 1];
// The Retrofits' keys, as this model reads them (B.r is the Retrofit index; its option key is read in the model)
P2.paths = [
  { name: "Power", theme: "bigger charged shots and bonus damage against bosses; each step changes the shot", steps: [
    { name: "Dense Slugs", cost: 345, effect: "+30 damage (120)", options: [
      { key: "A", name: "Heavy Housing", desc: "A thicker housing swaps the barrel housing; the shot's line is thicker." },
      { key: "B", name: "Slug Rack", desc: "A rack of dense slugs on the deck; the shot's line is thicker." },
      { key: "C", name: "Tungsten Collars", desc: "Dark tungsten collars swap the steel ones; the shot's line is thicker." } ] },
    { name: "Boss Rounds", cost: 275, effect: "×1.5 damage to bosses", options: [
      { key: "A", name: "Red Boss Stripe", desc: "A red stripe along the housing; the shot carries red edge lines." },
      { key: "B", name: "Boss Marker Ring", desc: "Two thin red rings hugging the housing; the shot carries red edge lines." },
      { key: "C", name: "Boss Plates", desc: "Red plates flank the housing; the shot carries red edge lines." } ] },
    { name: "Overcharge", cost: 2260, effect: "200 damage, a 3 s recharge (primary)", options: [
      { key: "A", name: "Pressure Tanks", desc: "Two pressure tanks on the deck, one either side, whose gauge rings glow as the shot charges; the shot fans out at the muzzle." },
      { key: "B", name: "Spiral Coil", desc: "A copper coil spiralling round the back of the housing that lights up turn by turn as it charges; the shot fans out at the muzzle." },
      { key: "C", name: "Arc Pylons", desc: "Two pylons by the drum that throw sparks across to it as the shot charges; the shot fans out at the muzzle." } ] },
    { name: "Kill Charge", cost: 5125, effect: "240 damage; ×2 to bosses", options: [
      { key: "A", name: "Muzzle Cap", desc: "A heavy plate at the muzzle; the shot has a white core." },
      { key: "B", name: "Dual Charge Ring", desc: "A second charge ring round the drum; the shot has a white core." },
      { key: "C", name: "Lance Tip", desc: "A pointed lance on the muzzle; the shot has a white core." } ] },
    { name: "Kingslayer", cost: 6465, effect: "280 damage per charged shot (3.3 s); ×2.5 to bosses (mastery)", options: [
      { key: "A", name: "Gold Collars", desc: "Gold collars; a gold shot with gold hit flashes." },
      { key: "B", name: "Gold Drum Ring", desc: "A gold ring round the drum with a gold charge arc; a gold shot." },
      { key: "C", name: "Gold Crown", desc: "A gold crown of prongs at the muzzle; a gold shot." } ] },
  ] },
  { name: "Range/Speed", theme: "mostly faster recharge", steps: [
    { name: "Fast Capacitors", cost: 140, effect: "Recharge 2.2 s", options: [
      { key: "A", name: "Coolant Loop", desc: "A small coolant tank on the deck with a pipe to the drum; blue coolant beads flow along it faster as it charges." },
      { key: "B", name: "Spark Gap", desc: "Two electrodes on the deck with a spark that jumps between them, quicker and brighter as it charges." },
      { key: "C", name: "Cable Reel", desc: "A cable reel on the deck, spinning faster as it charges, with its cable running to the drum." } ] },
    { name: "Extended Rails", cost: 245, effect: "+40 range (420)", options: [
      { key: "A", name: "Telescoping Barrel", desc: "A narrower inner tube slides out of the housing's end, with a step ring at the joint; the mouth is on the narrower tube." },
      { key: "B", name: "Rangefinder", desc: "A rangefinder box with twin lenses and scale ticks on the housing's side (one red, one charge-coloured)." },
      { key: "C", name: "Guide Rails", desc: "Two slim guide rails alongside the housing with cross-struts, running on a little past the mouth." } ] },
    { name: "Rapid Capacitors", cost: 1930, effect: "Recharge 1.6 s (primary)", options: [
      { key: "A", name: "Drum Cage", desc: "A cage of struts and a glowing outer ring round the capacitor drum that brightens as it charges." },
      { key: "B", name: "Capacitor Spine", desc: "A spine of five small capacitor discs along the housing that light one after another as it charges." },
      { key: "C", name: "Charge Reservoir", desc: "A tall reservoir on the deck whose glowing level climbs as it charges." } ] },
    { name: "Supercapacitors", cost: 2610, effect: "Recharge 1.35 s", options: [
      { key: "A", name: "Field Rings", desc: "Thin glowing field rings between the collars that brighten as it charges." },
      { key: "B", name: "Bus Bars", desc: "Copper bus bars with bolts along both sides of the housing." },
      { key: "C", name: "Cryo Jacket", desc: "A frosted pale-blue jacket round the back of the housing, flecked with frost." } ] },
    { name: "Twin Rails", cost: 5000, effect: "Two rails firing in turn: a slug every 1.2 s (mastery)", options: [
      { key: "A", name: "Parallel Rails", desc: "Two housings running directly side by side, joined by clamps at the collars, each with every detail, firing in turn; gold rings at the muzzles." },
      { key: "B", name: "Staggered Pair", desc: "Two housings, one forward and one back; gold rings at the muzzles." },
      { key: "C", name: "Split Rails", desc: "Two slim housings set wide apart with copper windings between; gold rings." } ] },
  ] },
  { name: "Special Effects", theme: "armour shatter, less falloff, an ionised trail", steps: [
    { name: "Shatter Rounds", cost: 60, effect: "Each hit strips 2 armour permanently", options: [
      { key: "A", name: "Resonator Fork", desc: "A two-pronged fork just past the mouth that buzzes when the shot is charged; hits crack orange." },
      { key: "B", name: "Etching Tank", desc: "An acid-green etching tank on the deck with a hose to the housing; hits crack orange." },
      { key: "C", name: "Impact Studs", desc: "Two rows of steel studs on the front of the housing; hits crack orange." } ] },
    { name: "Penetrator Core", cost: 260, effect: "Falloff per enemy 40% to 25%", options: [
      { key: "A", name: "Drill Tip", desc: "A steel drill cone with cut grooves on the mouth." },
      { key: "B", name: "Core Magazine", desc: "A rack of long, slim penetrator cores on the deck." },
      { key: "C", name: "Lance Prongs", desc: "Three slim prongs converging ahead of the mouth into a needle." } ] },
    { name: "Ionised Trail", cost: 1535, effect: "The line burns for 2 s: 30 energy damage/s to every enemy on it (primary)", options: [
      { key: "A", name: "Ion Fins", desc: "Two angled fins either side of the front of the housing with glowing edges; the line lingers and crackles." },
      { key: "B", name: "Plasma Tube", desc: "A dark glass tube along the housing's side with glowing plasma flowing forward; the line lingers and crackles." },
      { key: "C", name: "Ion Grid", desc: "A glowing grid panel on the deck; the line lingers and crackles." } ] },
    { name: "Hot Rail", cost: 3685, effect: "Shatter 4 armour; trail 45/s; falloff 15%", options: [
      { key: "A", name: "Glowing Rail Edges", desc: "The housing's side edges glow orange-hot." },
      { key: "B", name: "Steam Vents", desc: "Two short vent pipes on the housing that puff steam." },
      { key: "C", name: "Heat-Fin Block", desc: "A fin block alongside the housing with glowing orange fins." } ] },
    { name: "Ion Cannon", cost: 6920, effect: "Shatter 6; trail 50/s; no falloff (mastery)", options: [
      { key: "A", name: "Gold Lens Ring", desc: "A gold lens ring round the mouth; gold shot, every hit flashes at full size down the line." },
      { key: "B", name: "Gold Spine", desc: "A gold dorsal spine along the housing; gold shot, full-size hits." },
      { key: "C", name: "Gold Emitter Funnel", desc: "A flared gold emitter funnel behind the mouth; gold shot, full-size hits." } ] },
  ] },
];
P2.retrofits = [
  { name: "Capacitor Coils", cost: 140, effect: "Recharge 2.5 to 2.2 s (stacks with Fast Capacitors)", options: [
    { key: "A", name: "Housing Coils", desc: "Copper coils along the housing that light as it charges." },
    { key: "B", name: "Drum Coils", desc: "A copper coil cage round the drum that lights as it charges." },
    { key: "C", name: "Coil Stack", desc: "A stack of copper coil cans on the deck that glow as it charges." } ] },
  { name: "Longer Rails", cost: 265, effect: "+15 damage (105), +30 range (410)", options: [
    { key: "A", name: "Rail Ridges", desc: "A longer housing with raised rail ridges along its sides." },
    { key: "B", name: "Heavy Housing", desc: "A longer, thicker housing." },
    { key: "C", name: "Rail Rings", desc: "A longer housing with two extra rings." } ] },
  { name: "Penetrator Tips", cost: 65, effect: "Falloff per enemy 40% to 30% (stacks with Penetrator Core)", options: [
    { key: "A", name: "Dark Slug Heads", desc: "The slug head is dark and pointed as it leaves the muzzle." },
    { key: "B", name: "Tip Insert", desc: "A pointed dark insert in the muzzle; the slug head is dark and pointed as it leaves." },
    { key: "C", name: "Tip Rack", desc: "A rack of pointed dark slugs on the deck; the slug head is dark and pointed." } ] },
];
P2.picks = {};

// ---- Round 2 (owner's picks and notes, 2026-10-18): picked stages show only the pick (re-described where a note changed
// it); stages the owner asked for more ideas on show three new options.
P2.intro = "Round 2: your picks drawn as one model with your notes applied: Kingslayer now turns only the charge-up arc and the centreline gold (not the drum), and the parallel Twin Rails run directly side by side, joined by clamps. New ideas for Fast Capacitors, Rapid Capacitors, Supercapacitors and every Special Effects tier; Longer Rails keeps its three options. Use the build preview to check combinations.";
P2.picks = { p0s0: "C", p0s1: "B", p0s2: "C", p0s3: "B", p0s4: "B", p1s1: "A", p1s4: "A", r0: "A", r2: "A" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { const pk = P2.picks["p" + pi + "s" + k]; if (pk) st.options = st.options.filter((o) => o.key === pk); }));
P2.retrofits.forEach((rf, ri) => { const pk = P2.picks["r" + ri]; if (pk) rf.options = rf.options.filter((o) => o.key === pk); });
P2.paths[0].steps[4].options[0].desc = "From your note: only the charge-up arc and the green centreline turn gold, not the whole drum; a gold shot with gold hit flashes.";
