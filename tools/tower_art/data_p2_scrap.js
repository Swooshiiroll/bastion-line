// ---- Tower art second pass: Scrapyard (tower 17), REDESIGNED FROM SCRATCH as a smelting works (owner, 2026-10-19) -----------------------------------
// Everything is new: the base look (a foundry: brick furnace, scrap conveyor, molten channel, ingot moulds, chimney) and all three paths. The
// model draws the whole yard at every level. Lessons carried over: every step REBUILDS a part in place (the new design replaces the old one),
// the options swap that part's style, masteries are gold, overlapping Retrofits are kept and stack (the carpet rule), and the agent runs the
// real rules (the payout at each clear, the kill bonus, the discount field). Layout (game px, a 2x2 yard, half-width 46):
//  - the furnace in the middle-left, fed by a scrap conveyor from the left edge, with a chimney;
//  - a molten channel from the furnace down to the casting strip along the bottom edge;
//  - Path 1 (Passive Income) rebuilds the casting strip (ingot moulds, a vault store or mint presses); gold at the Reserve Bank;
//  - Path 2 (Kill Income) rebuilds the furnace itself (a brick furnace, a blast furnace or a crucible works); wrecked enemies feed it;
//  - Path 3 (Discounts) rebuilds the supply strip down the left edge (chutes with crates, ore silos or a rail siding).
// Overlaps kept and stacking: the Second Crusher's +30 with the path-1 income, the Bigger Yard's +30 px with both field radii.
const PAGE = { title: "Scrapyard (smelting works): paths and Retrofits (second pass)", store: "bl-tower-art-p2-scrap-sw1" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], BRICK = [0.55, 0.27, 0.2, 1], SLAG = [0.16, 0.14, 0.13, 1], MOLTEN = [1, 0.55, 0.15, 1], HOTM = [1, 0.85, 0.45, 1], KILL = [1, 0.5, 0.2, 1], DISCC = [0.45, 0.82, 0.95, 1], YEL = [0.9, 0.7, 0.15, 1];
const rnd = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const INCOME = [100, 130, 165, 220, 270, 320], KILLPX = [0, 140, 150, 170, 190, 210], DISCPX = [0, 140, 150, 160, 175, 190], KBONUS = [0, 0.15, 0.25, 0.35, 0.45, 0.6], DOFF = ["", "-5%", "-10%", "-15%", "-20%", "-25%"];
const incomeOf = (B) => INCOME[B.lv[0]] + (B.r === 0 ? 30 : 0);
const killR = (B) => KILLPX[B.lv[1]] + (B.r === 1 && B.lv[1] > 0 ? 30 : 0), discR = (B) => DISCPX[B.lv[2]] + (B.r === 1 && B.lv[2] > 0 ? 30 : 0);
const FP = [-6, -4];                                                                                  // the furnace's centre (yard units)
function txt(p, str, col, px) { X.save(); X.font = "bold " + Math.round(px) + "px sans-serif"; X.textAlign = "center"; X.fillStyle = css(OUTLINE); X.fillText(str, p[0] + 1, p[1] + 1); X.fillStyle = css(col); X.fillText(str, p[0], p[1]); X.restore(); }
function coinPop(c, v, s) { for (let i = 0; i < 6; i++) { const d = fa(-Math.PI / 2 + (i - 2.5) * 0.35), p = add(add(c, mul(d, s * 0.5 * Math.min(1, v * 2))), [0, v * v * s * 0.4]); disc(p, s * 0.045 + 1, A(OUTLINE, 0.95 * (1 - v))); disc(p, s * 0.045, A(GOLD, 1 - v)); } }
const goldOr = (g, col) => (g ? GOLD : col);

// ---- The agent: the payout at each (preview) clear, kill coins from wrecked enemies in the field, and the two field rings -------------------------------
function scrapAgent(B) { return (m, t, info, s, col) => { if (!m.pays) { m.pays = []; m.last = t; m.kills = []; m.kt = t; }
  const L1 = B.lv[0], L2 = B.lv[1], L3 = B.lv[2], c = info.c, k = G(s), furn = add(c, [FP[0] * k, FP[1] * k]);
  if (t - m.last >= 4) { m.last = t; m.pays.push(t); } m.pays = m.pays.filter((q) => t - q < 1.8);
  if (L2 > 0) { const R = s * killR(B) / 48; ring(c, R, A(KILL, 0.2), 1.2); for (let i = 0; i < 24; i += 2) line(add(c, mul(fa(i * TAU / 24 + t * 0.03), R)), add(c, mul(fa((i + 1) * TAU / 24 + t * 0.03), R)), A(KILL, 0.34), 1.2); }
  if (L3 > 0) { const R = s * discR(B) / 48; ring(c, R, A(DISCC, 0.2), 1.2); for (let i = 1; i < 24; i += 2) line(add(c, mul(fa(i * TAU / 24 - t * 0.03), R)), add(c, mul(fa((i + 1) * TAU / 24 - t * 0.03), R)), A(DISCC, 0.34), 1.2); txt(add(c, [R * 0.7, -R * 0.7]), DOFF[L3], A(DISCC, 0.9), Math.max(10, s * 0.14)); }
  if (L2 > 0 && t - m.kt >= 1.7) { const near = info.all.filter((e) => !e.air && dist(e.p, c) < s * killR(B) / 48); if (near.length) { const e = near[Math.floor(rnd(Math.floor(t) + 1) * near.length)]; m.kills.push({ t0: t, p: e.p.slice() }); m.kt = t; m.feed = t; } }
  m.kills = m.kills.filter((q) => t - q.t0 < 1);
  for (const q of m.kills) { const v = (t - q.t0) / 1, gc = L2 >= 5 ? GOLD : MOLTEN; if (v < 0.25) { const r = Math.max(4, Math.min(11, s * 0.12)); glowDot(q.p, r * (1 - v / 0.25), [1, 0.9, 0.7, 1]); ring(q.p, r + v * 40, A(KILL, 1 - v / 0.25), 1.6); }
    const p = add(lerp(q.p, furn, Math.min(1, v * 1.1)), [0, -Math.sin(Math.PI * Math.min(1, v)) * s * 0.4]); disc(p, s * 0.05 + 1, OUTLINE); disc(p, s * 0.05, gc);
    if (v < 0.55) txt(add(q.p, [0, -s * 0.22 - v * s * 0.3]), "+" + Math.round(5 * (1 + KBONUS[L2])), A(gc, 1 - v * 1.8), Math.max(9, s * 0.15)); }
  for (const q of m.pays) { const v = (t - q) / 1.6; if (v > 1) continue; const cp = add(c, [0, 30 * k]); coinPop(cp, v, s); if (v < 0.3) glowDot(cp, s * 0.3 * (1 - v / 0.3), HOTM);
    txt(add(cp, [0, -s * 0.45 - v * s * 0.5]), "+" + incomeOf(B), A(GOLD, Math.min(1, 2 - v * 2)), Math.max(11, s * 0.2));
    if (L1 >= 5 && v > 0.1) txt(add(cp, [s * 0.5, -s * 0.25 - v * s * 0.4]), "+3%", A([0.8, 1, 0.6, 1], Math.min(1, 2 - v * 2)), Math.max(9, s * 0.14)); } }; }

// ---- The model ---------------------------------------------------------------------------------------------------------------------------------------
const P2 = {
  tower: "scrap", look: "A", anim: "A", sBuild: 112, sCard: 64,                                 // a 2x2 yard: smaller previews so the whole yard fits
  intro: "Round 1 of the redesign: a fresh Smelting Works (the old Magnet Yard and every old upgrade design are gone). A brick furnace with a glowing mouth is fed by a scrap conveyor and breathes smoke from its chimney; a molten channel runs down to a casting strip of ingot moulds, and at each payout the channel flares and the ingots flash gold. Path 1 (Passive Income) rebuilds the casting strip (ingot moulds, a vault store or mint presses; gold at the Reserve Bank). Path 2 (Kill Income) rebuilds the furnace itself (a bigger brick furnace, a blast furnace or a crucible works), widens the orange kill ring, and wrecked enemies in it feed the furnace a coin with the bonus. Path 3 (Discounts) rebuilds the supply strip down the left edge (chutes with crates, ore silos or a rail siding) and widens the blue discount ring. The Retrofits add a second crusher, a wider wall or a salvage crane. Overlapping Retrofits are kept and stack (the carpet rule). Unpicked steps show option A.",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: scrapAgent(B) }; },
  muzzleAt(B, m, kk, c) { return c; },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), mm = fx.mem || {}, pour = decay(t - (mm.last ?? -9), 1.4), fed = decay(t - (mm.feed ?? -9), 0.8), L1 = B.lv[0], L2 = B.lv[1], L3 = B.lv[2], S = (x, y) => add(c, [x * k, y * k]), R = B.r >= 0 ? B.key("r" + B.r) : null, g1 = L1 >= 5, g2 = L2 >= 5, g3 = L3 >= 5;
    // ---- the Bigger Yard: a second, wider wall round the works -----------------------------------------------------------------------------------------------------
    if (B.r === 1) {
      const pts = [S(-54, -54), S(54, -54), S(54, 54), S(-54, 54), S(-54, -54)];
      if (R === "A") { polyline(pts, OUTLINE, 5 * k); polyline(pts, mix(BRICK, SLAG, 0.4), 3.4 * k); polyline(pts, A(MOLTEN, 0.35 + 0.2 * pour), 1 * k); }
      if (R === "B") { polyline(pts, OUTLINE, 3 * k); polyline(pts, METAL_L, 1.6 * k); for (let i = -5; i <= 5; i++) for (const sg of [-1, 1]) { line(S(i * 10.8, sg * 54), S(i * 10.8, sg * 54 - sg * 6), STEEL, 1.1 * k); line(S(sg * 54, i * 10.8), S(sg * 54 - sg * 6, i * 10.8), STEEL, 1.1 * k); } }
      if (R === "C") { polyline(pts, OUTLINE, 2.4 * k); polyline(pts, A(STEEL, 0.9), 1.1 * k); for (let i = -5; i <= 5; i++) for (const sg of [-1, 1]) { disc(S(i * 10.8, sg * 54), 1.5 * k, METAL_D); disc(S(sg * 54, i * 10.8), 1.5 * k, METAL_D); } } }
    // ---- the yard floor: dark slag with a hazard-striped edge --------------------------------------------------------------------------------------------------------
    ellipse(add(c, [0, 8 * k]), 44 * k, 16 * k, [0, 0, 0, 0.3]); plate(c, rectPts(46, 46), lt(METAL_D, 0.03), 0, k, 1.3); fill(c, rectPts(44, 44), SLAG, 0, k);
    for (let j = 0; j < 22; j++) { const a0 = -44 + j * 4, cc = j % 2 ? YEL : [0.08, 0.07, 0.06, 1]; line(S(a0, -44.5), S(a0 + 4, -44.5), cc, 2.2 * k); line(S(a0, 44.5), S(a0 + 4, 44.5), cc, 2.2 * k); line(S(-44.5, a0), S(-44.5, a0 + 4), cc, 2.2 * k); line(S(44.5, a0), S(44.5, a0 + 4), cc, 2.2 * k); }
    for (let i = 0; i < 9; i++) disc(S(-36 + i * 9 + rnd(i) * 3, -40 + rnd(i + 9) * 80), (0.8 + rnd(i + 3)) * k, A(MOLTEN, 0.08));
    // ---- the scrap conveyor from the left edge into the furnace --------------------------------------------------------------------------------------------------------
    plate(S(-33, FP[1]), rectPts(13.5, 2.6), METAL_D, 0, k, 1.1); for (let j = 0; j < 4; j++) { const x = -46 + fmod(t * 8 + j * 7, 27); plate(S(x, FP[1] + (j % 2 ? 0.6 : -0.5)), rectPts(1.6 + (j % 3) * 0.4, 1.2), mix(BRICK, STEEL, 0.4 + 0.15 * (j % 2)), j, k, 0.8); }
    for (let j = 0; j < 6; j++) line(S(-45 + j * 4.5 + fmod(t * 4, 4.5), FP[1] - 2.6), S(-43.5 + j * 4.5 + fmod(t * 4, 4.5), FP[1] - 1.6), A(STEEL, 0.6), 0.8 * k);
    // ---- the molten channel from the furnace to the casting strip (flares at each payout) ---------------------------------------------------------------------------------
    { const pts = [S(2, 2), S(8, 10), S(8, 24)]; polyline(pts, OUTLINE, 4.6 * k); polyline(pts, mix(BRICK, SLAG, 0.5), 3.4 * k); polyline(pts, A(MOLTEN, 0.45 + 0.5 * pour), 2 * k); if (pour > 0.2) polyline(pts, A(HOTM, pour), 1 * k); }
    // ---- Path 3: the supply strip down the left edge, rebuilt each step (chutes with crates, ore silos or a rail siding) ----------------------------------------------------
    if (L3 > 0) { const key = B.key("p2s" + (L3 - 1)), n = [0, 2, 3, 4, 5, 6][L3], ac = g3 ? GOLD : DISCC;
      if (key === "A") for (let q = 0; q < n; q++) { const p = S(-37, 8 + q * 6.2); plate(p, rectPts(6, 2.4), METAL_D, 0, k, 1); fill(add(p, [-6 * k, 0]), [[0, -2.2], [2.2, -1.2], [2.2, 1.2], [0, 2.2]], METAL_L, 0, k); for (let j = 0; j < 2 + (q % 2); j++) plate(add(p, [(-2 + j * 3.2) * k, 0]), rectPts(1.3, 1.4), mix(YEL, BRICK, 0.4 + 0.15 * j), 0, k, 0.8); if (q === n - 1) glowDot(add(p, [5 * k, 0]), 0.45 * k, ac); }   // chutes with crates
      if (key === "B") for (let q = 0; q < n; q++) { const p = S(-37 + (q % 2) * 5.6, 8 + q * 5.6); disc(p, 2.9 * k + 0.9 * k, OUTLINE); disc(p, 2.9 * k, METAL_L); ring(p, 1.9 * k, STEEL, 0.9 * k); disc(p, 0.9 * k, ac); }   // ore silos
      if (key === "C") { for (const dx of [-1.6, 1.6]) line(S(-37 + dx, 8), S(-37 + dx, 8 + 6 * n + 2), STEEL, 1.1 * k); for (let j = 0; j < 3 + n; j++) line(S(-39.4, 9 + j * 6 * n / (3 + n)), S(-34.6, 9 + j * 6 * n / (3 + n)), A(BRICK, 0.9), 1.4 * k);
        const wy = 9 + fmod(t * (3 + n), 6 * n - 3); plate(S(-37, wy), rectPts(2.6, 2.8), g3 ? dk(GOLD, 0.45) : mix(METAL_L, DISCC, 0.3), 0, k, 1); glowDot(S(-37, wy + 2.8), 0.4 * k, ac); }   // a rail siding with a wagon
      if (g3) outline(S(-37, 8 + 3 * n), rectPts(7, 3 * n + 2), A(GOLD, 0.85), 1.4 * k, 0, k); }
    // ---- Path 1: the casting strip along the bottom edge, rebuilt each step (ingot moulds, a vault store or mint presses) --------------------------------------------------
    { const key = L1 > 0 ? B.key("p0s" + (L1 - 1)) : "-", n = [3, 4, 5, 6, 7, 8][L1], ac = goldOr(g1, HOTM), ing = (p, w, h, a0) => { const hot = Math.max(pour, 0.0); fill(p, rectPts(w, h), mix([0.4, 0.38, 0.36, 1], g1 ? GOLD : MOLTEN, Math.max(0.15, hot)), 0, k); line(add(p, [-w * k, -h * 0.4 * k]), add(p, [w * k, -h * 0.4 * k]), A([1, 1, 1, 1], 0.35 + 0.4 * hot), 0.8 * k); };
      if (key === "-" || key === "A") { for (let q = 0; q < n; q++) { const x = -28 + (q + 0.5) * 56 / n, p = S(x, 33), w = 4.2 - n * 0.15; plate(p, rectPts(w + 0.8, 2.8), METAL_D, 0, k, 1); ing(p, w, 2, q); }
        if (L1 >= 3) { polyline([S(-30, 27), S(30, 27)], A(OUTLINE, 0.7), 2 * k); polyline([S(-30, 27), S(30, 27)], g1 ? GOLD : A(METAL_L, 0.9), 1.1 * k); } }   // a row of ingot moulds (a canopy rail from step 3)
      if (key === "B") { const w = [0, 14, 18, 22, 26, 30][L1]; plate(S(0, 34), rectPts(w, 6), g1 ? dk(GOLD, 0.45) : METAL_D, 0, k, 1.3); const nd = 1 + Math.floor(L1 / 2); for (let q = 0; q < nd; q++) { const p = S((q - (nd - 1) / 2) * w * 0.9, 34); disc(p, 4.2 * k + 1 * k, OUTLINE); disc(p, 4.2 * k, g1 ? dk(GOLD, 0.3) : METAL_L); ring(p, 2.9 * k, ac, 1.1 * k); for (let j = 0; j < 4; j++) line(p, add(p, mul(fa(j * Math.PI / 2 + pour * 1.6), 2.6 * k)), ac, 1.2 * k); disc(p, 0.8 * k, METAL); }
        for (let q = 0; q < 2 + L1; q++) ing(S(-w * 0.95 + q * 2.6, 39.4), 1.1, 0.8, q); if (g1) outline(S(0, 34), rectPts(w + 1.4, 7.4), A(GOLD, 0.85), 1.4 * k, 0, k); }   // a vault store with round doors and stacked ingots
      if (key === "C") { const np = [0, 2, 3, 3, 4, 4][L1]; for (let q = 0; q < np; q++) { const x = (q - (np - 1) / 2) * 15, p = S(x, 33); plate(p, rectPts(5, 5), g1 ? dk(GOLD, 0.45) : METAL_D, 0, k, 1.2); const ph = pour * 2.2; plate(add(p, [0, (-1.5 + ph) * k]), rectPts(3, 1.6), STEEL, 0, k, 1); bar(add(p, [0, -5 * k]), add(p, [0, (-1.5 + ph) * k]), 1.4 * k, METAL); for (let j = 0; j < 3; j++) ellipse(add(p, [(5.6 + (j % 2) * 0.4) * k, (-1 + j * 1.2) * k]), 1.3 * k, 0.6 * k, A(g1 ? GOLD : dk(GOLD, 0.2 * j), 1)); if (g1) glowDot(add(p, [0, 4 * k]), 0.4 * k, GOLD); } }   // mint presses stamping coins
    }
    // ---- Path 2: the furnace, rebuilt each step (a bigger brick furnace, a blast furnace or a crucible works); gold at the mastery ---------------------------------------
    { const key = L2 > 0 ? B.key("p1s" + (L2 - 1)) : "A", rf = [11, 12.5, 14, 15.5, 17, 18.5][L2], F = S(FP[0], FP[1]), flame = 0.5 + 0.5 * Math.sin(t * 7), mo = goldOr(g2, MOLTEN), mh = goldOr(g2, HOTM);
      if (key === "A") { disc(F, rf * k + 1.4 * k, OUTLINE); disc(F, rf * k, BRICK); for (let q = 0; q < 18 + L2 * 2; q++) { const a = q * TAU / (18 + L2 * 2); line(add(F, mul(fa(a), rf * 0.62 * k)), add(F, mul(fa(a), rf * 0.98 * k)), A([0.3, 0.14, 0.1, 1], 0.9), 1 * k); } ring(F, rf * 0.8 * k, A([0.75, 0.4, 0.28, 1], 0.9), 1.2 * k);
        disc(F, rf * 0.52 * k, OUTLINE); disc(F, rf * 0.46 * k, mix([0.4, 0.1, 0.04, 1], mo, 0.4 + 0.3 * flame + 0.3 * fed)); disc(F, rf * (0.2 + 0.05 * flame) * k, A(mh, 0.9)); glowDot(F, (1 + 1.4 * fed) * k, mh); if (L2 >= 3) ring(F, rf * 0.98 * k, goldOr(g2, STEEL), 1.8 * k); }   // a brick furnace (a steel band from step 3)
      if (key === "B") { plate(F, rectPts(rf * 0.92, rf * 0.92), BRICK, 0, k, 1.4); plate(F, rectPts(rf * 0.72, rf * 0.72), mix(BRICK, SLAG, 0.4), 0, k, 1); for (let q = 0; q < 2 + Math.floor(L2 / 2); q++) { const yy = (-rf * 0.5 + q * rf / (1 + Math.floor(L2 / 2))) * k, w = 0.6 + 0.4 * Math.sin(t * 9 + q * 2); bar(add(F, [-rf * 1.2 * k, yy]), add(F, [-rf * 0.9 * k, yy]), 1.6 * k, goldOr(g2, METAL_L)); rect(F[0] - rf * 0.55 * k, F[1] + yy - 0.7 * k, rf * 1.1 * k, 1.4 * k, A(mo, 0.5 + 0.4 * w)); }
        disc(F, rf * 0.34 * k, OUTLINE); disc(F, rf * 0.28 * k, mix([0.4, 0.1, 0.04, 1], mo, 0.5 + 0.5 * flame)); glowDot(F, (0.8 + 1.2 * fed) * k, mh); }   // a blast furnace with bellows pipes and fire slits
      if (key === "C") { disc(F, rf * 0.55 * k, OUTLINE); disc(F, rf * 0.5 * k, mix(BRICK, SLAG, 0.4)); disc(F, rf * 0.32 * k, mix([0.4, 0.1, 0.04, 1], mo, 0.45 + 0.4 * flame + 0.2 * fed)); glowDot(F, (0.8 + 1.2 * fed) * k, mh); const nc = [0, 2, 3, 4, 5, 6][L2];
        for (let q = 0; q < Math.max(nc, 1); q++) { const a = q * TAU / Math.max(nc, 1) + 0.4, cp = add(F, mul(fa(a), rf * 0.92 * k)), la = a + Math.sin(t * 0.8 + q) * 0.3; disc(cp, 2.4 * k + 0.8 * k, OUTLINE); disc(cp, 2.4 * k, METAL_D); disc(cp, 1.7 * k, mix([0.4, 0.1, 0.04, 1], mo, 0.5 + 0.4 * Math.sin(t * 3 + q))); bar(add(F, mul(fa(a), rf * 0.5 * k)), cp, 1.2 * k, goldOr(g2, METAL)); line(cp, add(cp, mul(fa(la), 3.6 * k)), goldOr(g2, METAL_L), 1 * k); } }   // a crucible works: crucibles on arms round a central pit
      if (g2) ring(F, rf * 1.12 * k, A(GOLD, 0.8), 1.4 * k);
      const ch = add(F, [rf * 0.78 * k, -rf * 0.8 * k]); disc(ch, 3.4 * k + 0.9 * k, OUTLINE); disc(ch, 3.4 * k, METAL_D); disc(ch, 1.9 * k, [0.05, 0.05, 0.05, 1]); for (let q = 0; q < 4; q++) { const u = fmod(t * 0.5 + q / 4, 1); disc(add(ch, [u * 3 * k, -u * 14 * k]), (1 + u * 2.4) * k, A([0.5, 0.48, 0.46, 1], 0.55 * (1 - u))); } }
    // ---- the Retrofits: a second crusher (top-left), the Bigger Yard (the wall, above) or a salvage crane (top edge) ----------------------------------------------------------
    const thump = decay(t - (mm.last ?? -9), 0.35);
    if (B.r === 0) { const p = S(-33, -28);
      if (R === "A") { plate(p, rectPts(10, 6), METAL_L, 0, k, 1.3); const j = 2.4 + 2.6 * (1 - thump); fill(add(p, [-6 * k, 0]), [[0, -4], [j, 0], [0, 4]], STEEL, 0, k); fill(add(p, [6 * k, 0]), [[0, -4], [-j, 0], [0, 4]], STEEL, 0, k); glowDot(add(p, [0, -4.6 * k]), 0.5 * k, col); }
      if (R === "B") { plate(p, rectPts(10, 6), METAL_D, 0, k, 1.2); for (const sx of [-1, 1]) { const q = add(p, [sx * 3.4 * k, 0]); disc(q, 3 * k, OUTLINE); disc(q, 2.6 * k, METAL_L); for (let j = 0; j < 6; j++) line(q, add(q, mul(fa(t * 5 * sx + j * Math.PI / 3), 2.5 * k)), STEEL, 0.9 * k); } }
      if (R === "C") { plate(p, rectPts(10, 6), METAL_D, 0, k, 1.2); disc(p, 4.4 * k, OUTLINE); disc(p, 3.8 * k, METAL); for (let j = 0; j < 4; j++) { const a = t * 9 + j * Math.PI / 2; bar(p, add(p, mul(fa(a), 4.8 * k)), 1.2 * k, METAL_L); disc(add(p, mul(fa(a), 4.8 * k)), 1 * k, STEEL); } } }
    if (B.r === 2) { const p = S(8, -41), sw = Math.sin(t * 0.8);
      if (R === "A") { bar(S(-24, -41), S(40, -41), 2 * k, METAL_D); const hx = add(p, [sw * 12 * k, 0]); plate(hx, rectPts(2.4, 1.6), YEL, 0, k, 1); line(hx, add(hx, [0, 6 * k]), METAL_D, 0.9 * k); disc(add(hx, [0, 6 * k]), 1.6 * k, METAL_L); }
      if (R === "B") { disc(p, 3.6 * k, OUTLINE); disc(p, 3 * k, METAL); const a = sw * 1.1, tip = add(p, mul(fa(a), 20 * k)); bar(p, tip, 2.2 * k, YEL); disc(tip, 2 * k, METAL_L); line(tip, add(tip, [0, 5 * k]), METAL_D, 0.9 * k); }
      if (R === "C") { plate(p, rectPts(7, 3.4), METAL_L, 0, k, 1.2); const a = 0.4 + sw * 0.4, tip = add(add(p, [-3 * k, 0]), mul(fa(a), 16 * k)); bar(add(p, [-3 * k, 0]), tip, 2.2 * k, YEL); line(tip, add(tip, [0, 4 * k]), METAL_D, 0.9 * k); fill(add(tip, [0, 4 * k]), [[-1.6, 0], [1.6, 0], [0.8, 2.6], [-0.8, 2.6]], METAL_L, 0, k); for (const sx of [-1, 1]) disc(add(p, [sx * 4.4 * k, 2 * k]), 1.3 * k, METAL_D); } }
  },
  paths: [], retrofits: [],
};

// ---- Option tables ---------------------------------------------------------------------------------------------------------------------------------------
const T = (a, b, c) => [["A", ...a], ["B", ...b], ["C", ...c]].map(([key, name, desc]) => ({ key, name, desc }));
P2.paths = [
  { name: "Passive Income", theme: "the casting strip along the bottom edge: rebuilt at every step; gold at the Reserve Bank", steps: [
    { name: "Stamping Press", cost: 525, effect: "130 per round", options: T(["Ingot Moulds", "The casting strip is rebuilt with four ingot moulds; the channel feeds them at each payout."], ["Vault Store", "The casting strip is rebuilt as a small vault store with a round door and stacked ingots."], ["Mint Presses", "The casting strip is rebuilt with two mint presses that stamp coins at each payout."]) },
    { name: "Vault Doors", cost: 1225, effect: "165 per round", options: T(["Ingot Moulds", "The casting strip is rebuilt with five bigger moulds."], ["Vault Store", "The vault store is rebuilt wider, with more stacked ingots."], ["Mint Presses", "The casting strip is rebuilt with three mint presses."]) },
    { name: "Credit Mint", cost: 3850, effect: "220 per round (primary)", options: T(["Canopy Moulds", "The casting strip is rebuilt with six moulds under a canopy rail."], ["Twin Vault", "The vault store is rebuilt wider with two round doors."], ["Mint Row", "The casting strip is rebuilt with three bigger mint presses."]) },
    { name: "Treasury Link", cost: 7000, effect: "270 per round", options: T(["Long Mould Row", "The casting strip is rebuilt with seven moulds."], ["Big Twin Vault", "The vault store is rebuilt wider again."], ["Four Presses", "The casting strip is rebuilt with four mint presses."]) },
    { name: "Reserve Bank", cost: 27440, effect: "320 per round, plus 3% interest on banked credits at each clear (mastery)", options: T(["Gold Mould Row", "Eight moulds of gold ingots under a gold canopy; each payout adds a +3% interest tag."], ["Gold Vault Bank", "The vault store turns gold, with gold doors and ingots; each payout adds a +3% interest tag."], ["Gold Mint Row", "The four mint presses turn gold and stamp gold coins; each payout adds a +3% interest tag."]) },
  ] },
  { name: "Kill Income", theme: "the furnace: rebuilt at every step, hotter and bigger; the orange kill-field ring widens and wrecked enemies feed the furnace", steps: [
    { name: "Scrap Collector", cost: 345, effect: "Enemies destroyed within 140 px pay 15% more", options: T(["Brick Furnace", "The furnace is rebuilt in brick with a hotter mouth; wrecked enemies in the field pay +15%."], ["Blast Furnace", "The furnace is rebuilt as a square blast furnace with two bellows pipes; wrecked enemies in the field pay +15%."], ["Crucible Works", "The furnace is rebuilt as a crucible works with two crucibles on arms; wrecked enemies in the field pay +15%."]) },
    { name: "Magnet Cranes", cost: 625, effect: "+25%; 150 px", options: T(["Bigger Brick Furnace", "The furnace is rebuilt bigger."], ["Bigger Blast Furnace", "The furnace is rebuilt bigger, with three bellows pipes."], ["Three Crucibles", "The works is rebuilt bigger, with three crucibles."]) },
    { name: "Sorting Line", cost: 2095, effect: "+35%; 170 px (primary)", options: T(["Banded Furnace", "The furnace is rebuilt bigger, with a steel band."], ["Big Blast Furnace", "The furnace is rebuilt bigger, with more slits."], ["Four Crucibles", "The works is rebuilt bigger, with four crucibles."]) },
    { name: "Smelter", cost: 5720, effect: "+45%; 190 px", options: T(["Great Furnace", "The furnace is rebuilt bigger again."], ["Great Blast Furnace", "The furnace is rebuilt bigger again."], ["Five Crucibles", "The works is rebuilt bigger, with five crucibles."]) },
    { name: "Reclamation Plant", cost: 28945, effect: "+60%; 210 px; bosses pay double (mastery)", options: T(["Gold Furnace", "The furnace's mouth turns molten gold, with a gold rim; the field coins turn gold."], ["Gold Blast Furnace", "The blast furnace glows molten gold, with a gold rim; the field coins turn gold."], ["Gold Crucible Works", "Six gold crucibles pour molten gold, with a gold rim; the field coins turn gold."]) },
  ] },
  { name: "Discounts", theme: "the supply strip down the left edge: rebuilt at every step; the blue discount ring widens and shows the percentage off", steps: [
    { name: "Supply Depot", cost: 190, effect: "Towers within 140 px upgrade for 5% less", options: T(["Supply Chutes", "Two chutes with crates are built on the left edge; towers nearby upgrade 5% cheaper."], ["Ore Silos", "Two ore silos are built on the left edge; towers nearby upgrade 5% cheaper."], ["Rail Siding", "A short rail siding with a wagon is built on the left edge; towers nearby upgrade 5% cheaper."]) },
    { name: "Bulk Orders", cost: 495, effect: "10% off upgrades; 150 px", options: T(["More Chutes", "Three chutes with crates."], ["More Silos", "Three ore silos."], ["Longer Siding", "A longer siding, with a faster wagon."]) },
    { name: "Procurement Office", cost: 2035, effect: "15% off upgrades, 5% off builds; 160 px (primary)", options: T(["Four Chutes", "Four chutes with crates."], ["Four Silos", "Four ore silos."], ["Long Siding", "A long siding, with a faster wagon."]) },
    { name: "Freight Rail", cost: 3865, effect: "20% off upgrades; 175 px", options: T(["Five Chutes", "Five chutes with crates."], ["Five Silos", "Five ore silos."], ["Freight Siding", "A freight siding, with a faster wagon."]) },
    { name: "Forward Command", cost: 20935, effect: "25% off upgrades, 10% off builds; 190 px; towers in the field sell back for everything spent on them (mastery)", options: T(["Gold-Framed Chutes", "Six chutes with a gold frame and a gold light."], ["Gold-Framed Silos", "Six silos with gold hearts inside a gold frame."], ["Gold-Framed Siding", "A long siding with a gold frame and a gold wagon."]) },
  ] },
];
P2.retrofits = [
  { name: "Second Crusher", cost: 525, effect: "+30 income per round (stacks with the Passive Income path)", options: T(["Jaw Crusher", "A second crusher with steel jaws that close at each payout, in the top-left corner."], ["Roller Crusher", "Two spinning rollers in the top-left corner."], ["Hammer Mill", "A spinning hammer mill in the top-left corner."]) },
  { name: "Bigger Yard", cost: 260, effect: "+30 px to its fields (stacks with the Kill and Discount paths)", options: T(["Slag Wall", "A second, wider wall of slag brick with a glowing seam surrounds the works."], ["Pipe Fence", "A second, wider steel fence with posts surrounds the works."], ["Bollard Fence", "A second, wider rail with round bollards surrounds the works."]) },
  { name: "Salvage Crane", cost: 260, effect: "Towers sold in its field refund 15% more", options: T(["Overhead Gantry", "An overhead gantry beam with a trolley and hook across the top edge."], ["Jib Crane", "A jib crane with a swinging boom on the top edge."], ["Crane Truck", "A crane truck with a swinging boom on the top edge."]) },
];
