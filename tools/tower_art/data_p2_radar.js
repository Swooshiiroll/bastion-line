// ---- Tower art second pass: Radar Tower (tower 14), round 1 ------------------------------------------------------
// Base: look A Dish Mast, animation B Sweep Beam (the sweep follows the dish). One parametric model built on the lessons so far: every
// step REBUILDS a part of the station (structure over decoration), the options swap that part's style, masteries turn gold, and the
// agent runs the real rules (ping rate, reveal time, range, radiation circle) so the preview shows what each step does.
// Layout (game px, top-down): a hub with the turning dish and feed horn (path 1, Power/Range); a phased-array panel on each edge,
// added south, north, east, west (path 2, Speed/Frequency); an analysis cabinet in each corner, added NW, NE, SE, SW (path 3, Unmasking).
// The Bigger Dish Retrofit's +20 px overlaps the path-1 range steps and the Signal Processor's longer reveal overlaps the reveal
// steps; both are kept and stack (the carpet rule). The radiation circle (path 1, step 3 on) only hurts revealed enemies (owner).
const PAGE = { title: "Radar Tower: paths and Retrofits (second pass)", store: "bl-tower-art-p2-radar-r12" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], RAD = [1, 0.3, 0.25, 1], DARKP = [0.12, 0.16, 0.16, 1];
const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const cloaked = (e) => e.i % 2 === 0;                                                // every other enemy is cloaked in the preview
function hideCloaked(e, s, t) { const r = Math.max(4, Math.min(11, s * 0.12)) + 2; disc(e.p, r, e.air ? [0.07, 0.09, 0.08, 0.82] : [0.16, 0.15, 0.13, 0.82]);
  ring(e.p, r - 1, [0.7, 0.9, 1, 0.18 + 0.1 * Math.sin(t * 9 + e.i)], 1); }
function revealMark(p, s, col, a) { const r = Math.max(4, Math.min(11, s * 0.12)) + 4;
  for (let i = 0; i < 4; i++) { const d = fa(Math.PI / 4 + i * Math.PI / 2), c0 = add(p, mul(d, r)); line(c0, add(c0, mul(rot(d, Math.PI * 0.75), r * 0.6)), A(col, a), 1.5); line(c0, add(c0, mul(rot(d, -Math.PI * 0.75), r * 0.6)), A(col, a), 1.5); } }
const rnd = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null);
const RNG = [160, 180, 200, 200, 220, 230], PER = [3, 2.7, 2.4, 2, 1.6, 1.6], DUR = [1, 1.1, 1.2, 1.3, 1.3, 1.3];
const rangePx = (B) => RNG[B.lv[0]] + (B.r === 0 ? 20 : 0);
const radPx = (B) => (B.lv[0] >= 5 ? 80 : B.lv[0] === 4 ? 70 : B.lv[0] === 3 ? 60 : 0);
const durOf = (B) => Math.max(DUR[B.lv[1]], B.lv[2] >= 3 ? 1.3 : 1) + (B.r === 1 ? 0.5 : 0);

// ---- A revealed enemy's mark grows with the unmasking path: rank tag, unmask diamond, track-lock tether, fake-check badge, gold lock --------
function markFor(p, s, col, a, l3, t, c) {
  const gold = l3 >= 5, mc = gold ? GOLD : col, r = Math.max(4, Math.min(11, s * 0.12)) + 4;
  if (l3 === 0) { revealMark(p, s, mc, a); return; }
  if (l3 === 1) { revealMark(p, s, mc, a); const q = add(p, [r + 3, -r + 1]); polyline([add(q, [-2, 1.4]), q, add(q, [2, 1.4])], A(mc, a), 1.4); polyline([add(q, [-2, 3.4]), add(q, [0, 2]), add(q, [2, 3.4])], A(mc, a), 1.4); return; }     // brackets and a rank tag
  if (l3 === 2) { outline(p, [[0, -1], [1, 0], [0, 1], [-1, 0]], A(mc, a), 1.5, 0, r * 1.05); outline(p, [[0, -1], [1, 0], [0, 1], [-1, 0]], A(mc, 0.4 * a), 1, 0, r * 1.4); return; }                          // a diamond frame
  if (l3 === 3) { ring(p, r * 1.1, A(mc, a), 1.5); arcSegments(p, r * 1.5, 3, 0.9, t * 2.4, A(mc, 0.8 * a), 1.4); line(c, p, A(mc, 0.25 * a), 1); return; }                                                    // a lock ring with a tether
  if (l3 === 4) { outline(p, ngon(6, 1), A(mc, a), 1.5, Math.PI / 6, r * 1.15); const q = add(p, [-r - 3, -r + 1]); ring(q, 2.6, A(mc, 0.8 * a), 1.1); polyline([add(q, [-1.2, 0.2]), add(q, [-0.3, 1.1]), add(q, [1.4, -1.0])], A(mc, a), 1.3); line(c, p, A(mc, 0.2 * a), 1); return; } // a hex frame with a fake-check badge
  ring(p, r * 1.1, A(GOLD, a), 1.6); ring(p, r * 1.5, A(GOLD, 0.6 * a), 1.2); arcSegments(p, r * 1.9, 4, 0.7, t * 1.6, A(GOLD, 0.8 * a), 1.4); line(c, p, A(GOLD, 0.3 * a), 1.2); }                                      // gold lock rings (they linger)

// ---- The agent: the dish turns once per ping period; the wedge reveals cloaked enemies it passes; the radiation circle hurts revealed ones ---------------
function radarAgent(B) { return (m, t, info, s, col) => { if (!m.seen) { m.seen = {}; m.lock = {}; m.ang = 0; m.tt = t; }
  const dt = Math.min(0.1, Math.max(0, t - m.tt)); m.tt = t; const L1 = B.lv[0], L2 = B.lv[1], L3 = B.lv[2], constant = L2 >= 5, c = info.c;
  m.ang = fmod(m.ang + dt * TAU / PER[L2], TAU);
  const R = s * 3.3 * rangePx(B) / 160, ang = m.shown ?? m.ang, dur = durOf(B), rr = s * 3.3 * radPx(B) / 160, wc = constant ? GOLD : col;
  ring(c, R, A(wc, 0.14), 1); for (let i = 0; i < 24; i += 2) line(add(c, mul(fa(i * TAU / 24 + t * 0.05), R)), add(c, mul(fa((i + 1) * TAU / 24 + t * 0.05), R)), A(wc, 0.3), 1.2);
  if (rr > 0) { const rc = L1 >= 5 ? GOLD : RAD, pulse = 0.5 + 0.5 * Math.sin(t * 3); disc(c, rr, A(rc, 0.07 + 0.05 * pulse)); arcSegments(c, rr, 20, 0.22, t * 0.4, A(rc, 0.55), 1.3); ring(c, rr * 0.92, A(rc, 0.12), 1); }
  if (constant) { disc(c, R, A(GOLD, 0.05)); ring(c, R * (0.55 + 0.05 * Math.sin(t * 2)), A(GOLD, 0.2), 1); }
  else for (let i = 0; i < 6; i++) { const a0 = ang - i * 0.08; poly([c, add(c, mul(fa(a0 - 0.08), R)), add(c, mul(fa(a0), R))], A(col, 0.16 * (1 - i / 6))); }
  if (constant) for (const a of [ang, ang + Math.PI]) line(c, add(c, mul(fa(a), R)), A(GOLD, 0.6), 1);                            // Constant Track: a scan line for each dish                            // Constant Track: a scan line for each dish
  else line(c, add(c, mul(fa(ang), R)), A(wc, 0.7), 1.3);
  for (const e of info.all) { const d = dist(e.p, c), inR = d < R;
    if (!cloaked(e)) { if (rr > 0 && d < rr) radHit(e.p, s, t, e.i, L1); continue; }
    const b = fmod(Math.atan2(e.p[1] - c[1], e.p[0] - c[0]), TAU), dd = fmod(ang - b, TAU), hit = inR && (constant || dd < Math.max(0.2, 2 * TAU * dt / PER[L2]));
    if (hit) m.seen[e.i] = t + dur;
    if (L3 >= 5 && (m.seen[e.i] || 0) > t && !inR) m.lock[e.i] = t + 5;                                          // Total Exposure: they can't re-cloak for 5 s after leaving
    const until = Math.max(m.seen[e.i] || 0, m.lock[e.i] || 0);
    if (until > t) { markFor(e.p, s, col, Math.min(1, (until - t) * 2), L3, t, c); if (rr > 0 && d < rr) radHit(e.p, s, t, e.i, L1); } else hideCloaked(e, s, t); } }; }
function radHit(p, s, t, i, L1) { const r = Math.max(4, Math.min(11, s * 0.12)), rc = L1 >= 5 ? GOLD : RAD; disc(p, r * 1.6, A(rc, 0.22 + 0.15 * Math.sin(t * 14 + i)));
  for (let j = 0; j < 3; j++) { const a = t * 5 + i + j * 2.1; line(add(p, mul(fa(a), r * 0.7)), add(p, mul(fa(a), r * (1.3 + 0.4 * Math.sin(t * 9 + j)))), A(rc, 0.8), 1.2); } }

// ---- The model ----------------------------------------------------------------------------------------------------------------------------------------------
const PSLOT = [[0, 12.2, 0], [0, -12.2, Math.PI], [12.8, 0, -Math.PI / 2], [-12.8, 0, Math.PI / 2]];     // panel slots: S, N, E, W (x, y, rotation: facing outward)
const CSLOT = [[-7.4, -7.4], [7.4, -7.4], [7.4, 7.4], [-7.4, 7.4]];                                                          // cabinet slots: NW, NE, SE, SW
const P2 = {
  tower: "radar", look: "A", anim: "B",
  intro: "Round 12: the bright scan line now lines up with the dish (your screenshot): it was drawn a frame ahead of the dish, which showed as the line sitting off to one side whenever the page ran slowly; the line and beam are now drawn at the angle the dish was drawn at. Round 11: the scan-line changes of rounds 9 and 10 are reverted (the scan lines and the sweep beam are back to starting at the centre of the tower, as in round 8); the gold antenna lights from round 9 stay. Round 10: every scan line, not just Constant Track's, starts at the antenna light, and the sweep beam is centred on its scan line (it used to trail behind it); an enemy is revealed as the line passes over its middle (your notes). Round 9: with Constant Track both antenna lights are gold (the first dish's light stayed teal when no emitter was fitted), and each dish's scan line starts at its antenna light instead of the centre of the tower (your notes). Round 8: the spars holding the dishes and the antenna arms are grey on both dishes (only the dishes are gold), the curved arrays read grey with small gold lamps, and the second dish's light is drawn on top in gold (your notes). Round 7: every stage is picked and your notes are applied: the Constant Track ring is grey, its dishes and the emitter are gold, both dishes have a scan line and the array bodies are grey with gold lights; the trackers have no light cones. Use the build preview to check combinations. Round 6: three struts join the dish to the centre mast; the Twin Prong Emitter is one solid V; the double radar moved to the Path 2 mastery (Constant Track builds a second gold dish), so the Path 1 mastery shows its three options again, with the twin dish replaced by a gold feed tripod. Round 5: the tracking turrets are smaller again and sit inside the deck, and the radar dish is thinner (your notes). Round 4: the tracking turrets are smaller, nothing sits under them, and the mastery only turns their blue accents gold (your notes); the three mastery options differ by a gold wall, a glowing gold lamp or a twin barrel. Round 3: your picks drawn with your note applied: the tracking turret stays from Track Lock on, the Illusion Filter builds onto it (a lens ring) and the Total Exposure mastery shows three gold turret builds (still to pick). Round 2: your Path 1 and Path 2 picks are drawn; Path 3 is redesigned (your note): instead of adding a cabinet at a time, all four corner stations are rebuilt to a new design at every step, and the mark on a revealed enemy changes style rather than gaining extras. The Signal Processor shows its three options again. Round 1: every step rebuilds a part of the station. Path 1 (Power/Range) owns the centre: a bigger dish, a taller mast, then a radiation emitter (with a faint red inner circle that only hurts revealed enemies), heat-sinks or capacitors, and a gold microwave array. Path 2 (Speed/Frequency) adds a phased-array panel on each edge (south, north, east, west) and the dish turns faster to match the ping rate; the mastery turns them gold with a constant reveal. Path 3 (Unmasking) adds an analysis cabinet in each corner (NW, NE, SE, SW) and the marks on revealed enemies grow with each step (rank tag, unmask diamond, track-lock tether, fake-check badge, gold lock). The Retrofits rebuild the dish, the hub or the mast. Overlapping Retrofits are kept and stack (the carpet rule). Unpicked steps show option A.",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: radarAgent(B) }; },
  muzzleAt(B, m, kk, c) { return c; },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), mm = fx.mem || {}, ang = mm.ang ?? t * TAU / 3, L1 = B.lv[0], L2 = B.lv[1], L3 = B.lv[2], S = (x, y) => add(c, [x * k, y * k]), R = B.r >= 0 ? B.key("r" + B.r) : null;
    if (fx.mem) fx.mem.shown = ang;                                                    // the agent draws its scan line at the angle the dish was drawn at (the model runs a frame before the agent, so a slow frame rate would leave the line ahead of the dish)
    deck(c, k, col, t);
    // ---- Path 2: a phased-array panel on each edge; the tiles light in sequence at the ping rate ------------------------------------------------------------
    const gold2 = L2 >= 5, lc2 = gold2 ? GOLD : col, ph = t * (2.2 + 0.5 * L2);
    if (gold2) { const key = B.key("p1s4");
      if (key === "A") ring(c, 10.2 * k, A(STEEL, 0.95), 1.4 * k);   // a grey cable ring
      if (key === "C") for (let i = 0; i < 4; i++) { const a0 = i * Math.PI / 2 + Math.PI / 4 - 0.5, a1 = a0 + 1; arc(c, 12.2 * k, a0, a1, OUTLINE, 3.4 * k); arc(c, 12.2 * k, a0, a1, GOLD, 1.8 * k); } }
    for (let i = 0; i < 4; i++) { if (L2 <= i) break; const key = B.key("p1s" + i), [x, y, rt] = PSLOT[i], p = S(x, y), lw = (lx, ly) => add(p, mul(rot([lx, ly], rt), k));
      const tile = (lx, ly, on) => fill(lw(lx, ly), [[-0.75, -0.75], [0.75, -0.75], [0.75, 0.75], [-0.75, 0.75]], on ? A(lc2, 0.95) : DARKP, rt, k);
      if (key === "A") { plate(p, rectPts(5.2, 1.9), METAL_L, rt, k, 1.1); for (let j = 0; j < 5; j++) tile(-4 + j * 2, 0.1, gold2 || fmod(ph - j * 0.35, 2) < 0.7); }
      if (key === "B") { const pts = []; for (let j = 0; j < 5; j++) { const a = -0.85 + j * 0.425; pts.push(lw(5.6 * Math.sin(a), 3.2 * Math.cos(a) - 1.8)); }
        polyline(pts, OUTLINE, 3.6 * k); polyline(pts, METAL_L, 2.2 * k); pts.forEach((q, j) => { disc(q, 1 * k, DARKP); if (gold2) disc(q, 0.62 * k, GOLD); else if (fmod(ph - j * 0.35, 2) < 0.7) glowDot(q, 0.75 * k, lc2); }); }
      if (key === "C") { plate(p, rectPts(5, 1.7), METAL_D, rt, k, 1.1); for (let j = 0; j < 4; j++) { const on = gold2 || fmod(ph - j * 0.4, 2) < 0.7; line(lw(-3.8 + j * 2.5, -1.2), lw(-2.6 + j * 2.5, 1.2), on ? A(lc2, 0.95) : STEEL, 1.4 * k); } }
      if (gold2 && B.key("p1s4") === "B") { outline(p, rectPts(5.9, 2.5), GOLD, 1.6, rt, k); for (const [ex, ey] of [[-5.9, -2.5], [5.9, -2.5], [5.9, 2.5], [-5.9, 2.5]]) disc(lw(ex, ey), 0.7 * k, GOLD); }
      if (gold2) disc(lw(0, 2.4), 0.4 * k, GOLD); }
    // ---- Path 3: the four corner stations are REBUILT at every step (a new design replaces the old one in all four corners); the mastery makes them gold ---
    const gold3 = L3 >= 5, lc3 = gold3 ? GOLD : col, key3 = L3 > 0 ? B.key("p2s" + (L3 - 1)) : null;
    if (L3 > 0) { const seen = mm.seen || {}, hot = (info.all || []).filter((e) => cloaked(e) && (seen[e.i] || 0) > t), sz = [0, 2.6, 3, 3.4, 3.8, 4.2][L3];
      if (gold3 && key3 === "A") { const pts = CSLOT.map(([x, y]) => S(x * 1.05, y * 1.05)); pts.push(pts[0]); polyline(pts, OUTLINE, 3.6 * k); polyline(pts, GOLD, 2 * k); }   // a gold wall joins the four citadels
      CSLOT.forEach(([x, y], i) => { const p = S(x, y), out = norm([x, y]), oa = Math.atan2(out[1], out[0]), body = gold3 ? dk(GOLD, 0.45) : METAL_L, trim = gold3 ? GOLD : STEEL;
        const near = hot.length ? hot.reduce((a, b) => (dist(a.p, p) < dist(b.p, p) ? a : b)) : null, ta = near ? Math.atan2(near.p[1] - p[1], near.p[0] - p[0]) : t * 1.2 + i * 1.6;
        if (L3 === 1) {
          if (key3 === "A") { plate(p, rectPts(sz * 0.8, sz), body, 0, k, 1.2); for (let j = 0; j < 4; j++) { const on = fmod(t * 3 + j * 0.6 + i, 2) < 1; rect(p[0] - 1.6 * k, p[1] - (1.5 - j * 0.9) * k, 3.2 * k, 0.55 * k, on ? lc3 : DARKP); } }                               // a server rack
          if (key3 === "B") { plate(p, rectPts(sz, sz * 0.8), body, 0, k, 1.2); rect(p[0] - 1.9 * k, p[1] - 1.4 * k, 3.8 * k, 2.8 * k, DARKP); const pts = []; for (let j = 0; j <= 10; j++) pts.push(add(p, [(-1.8 + j * 0.36) * k, Math.sin(j * 1.1 + t * 4 + i) * 0.9 * k])); polyline(pts, lc3, 0.9 * k); }         // a scope console
          if (key3 === "C") { bar(p, add(p, mul(out, 3.2 * k)), 1.3 * k, METAL); const q = add(p, mul(out, 3.4 * k)); for (let j = 0; j < 3; j++) arc(q, 1.9 * k, oa - 1 + t * 3 + j * 2.1, oa - 0.5 + t * 3 + j * 2.1, lc3, 1.3 * k); disc(p, 1.6 * k, OUTLINE); disc(p, 1.2 * k, METAL_L); } }  // an antenna post with spinning cups
        if (L3 === 2) {
          if (key3 === "A") { plate(p, rectPts(sz, sz), body, 0, k, 1.3); plate(p, rectPts(sz * 0.6, sz * 0.6), METAL_D, 0, k, 0.9); bar(p, add(p, mul(out, 4.4 * k)), 0.8 * k, METAL_L); glowDot(add(p, mul(out, 4.6 * k)), 0.6 * k, lc3); for (const [ex, ey] of [[-1, -1], [1, -1], [1, 1], [-1, 1]]) disc(add(p, [ex * sz * 0.8 * k, ey * sz * 0.8 * k]), 0.45 * k, trim); }  // a decoder tower
          if (key3 === "B") { disc(p, sz * k + 1.2 * k, OUTLINE); disc(p, sz * k, body); const q = add(p, mul(out, 1.8 * k)); arc(q, 2.6 * k, oa - 1.1, oa + 1.1, OUTLINE, 2.6 * k); arc(q, 2.6 * k, oa - 1.1, oa + 1.1, METAL_L, 1.5 * k); line(p, add(p, mul(out, 1.8 * k)), METAL, 0.9 * k); glowDot(p, 0.55 * k, lc3); }  // a dish pod
          if (key3 === "C") { disc(p, 2 * k, OUTLINE); disc(p, 1.6 * k, body); const m2 = add(p, mul(out, 8 * k)); bar(p, m2, 0.9 * k, METAL_L); for (let j = 0; j < 4; j++) { const q = add(p, mul(out, (2.6 + j * 1.4) * k)), o = orth(out); line(add(q, mul(o, (2.4 - j * 0.45) * k)), add(q, mul(o, -(2.4 - j * 0.45) * k)), METAL_L, 0.9 * k); } } }                      // a yagi mast
        if (L3 >= 3) {                                                                                  // the tracking turret stays from Track Lock on; later steps build onto it
          const ts = B.key("p2s2"), tsz = [0, 0, 0, 2.1, 2.2, 2.3][L3], k4 = L3 === 4 ? B.key("p2s3") : null, k5 = L3 === 5 ? B.key("p2s4") : null, tb = METAL_L, tt = gold3 ? GOLD : lc3;
          if (k4 === "B") { disc(p, tsz * k + 1.8 * k, OUTLINE); disc(p, tsz * k + 1.4 * k, A(lc3, 0.28)); ring(p, tsz * k + 1.4 * k, METAL_L, 1 * k); ring(p, tsz * k + 0.7 * k, A(lc3, 0.8), 0.7 * k); arc(p, tsz * k + 1.05 * k, t * 0.8 + i, t * 0.8 + i + 1.1, [1, 1, 1, 0.55], 1 * k); }   // Lens Ring: a big glass ring round the turret
          if (k4 === "C") for (let g = 0; g < 4; g++) { const a0 = g * Math.PI / 2 + Math.PI / 4 - 0.55; arc(p, tsz * k + 1.3 * k, a0, a0 + 1.1, OUTLINE, 2.2 * k); arc(p, tsz * k + 1.3 * k, a0, a0 + 1.1, A(lc3, 0.9), 1 * k); }   // Filter Gate: four grille shields round the turret
          // Gold Citadel: no base under the turrets; the gold wall joins the four (drawn above)
          if (k5 === "B") { ring(p, tsz * k + 1.1 * k, GOLD, 0.9 * k); glowDot(add(p, mul(fa(ta + Math.PI), tsz * 0.5 * k)), (0.55 + 0.2 * Math.sin(t * 4 + i)) * k, GOLD); }   // a gold lamp glows on the turret (no beam)
          // Gold Obelisk: no base; the turret gets a twin barrel (below)
          let mz;
          if (ts === "A") { disc(p, tsz * k + 1.2 * k, OUTLINE); disc(p, tsz * k, tb); ring(p, tsz * 0.78 * k, STEEL, 1 * k); mz = add(p, mul(fa(ta), 3 * k)); bar(p, mz, 1.2 * k, METAL_L); if (k5 === "C") { const o = orth(fa(ta)); bar(add(p, mul(o, 0.9 * k)), add(mz, mul(o, 0.9 * k)), 0.8 * k, METAL_L); } }                 // a tracking turret that follows a revealed enemy
          else if (ts === "B") { disc(p, tsz * k + 1.2 * k, OUTLINE); orb(p, tsz * k, tb); for (let j = 0; j < 3; j++) { const a = t * 2 + i + j * TAU / 3; line(p, add(p, mul(fa(a), (tsz + 1.6) * k)), tt, 1.1 * k); } mz = add(p, mul(fa(ta), 2.6 * k)); bar(p, mz, 1 * k, METAL_L); }             // a radar dome with a tracking arm
          else { plate(p, rectPts(tsz * 0.7, tsz * 0.7), tb, Math.PI / 4, k, 1.2); orb(p, tsz * 0.62 * k, METAL); disc(p, tsz * 0.32 * k, DARKP); mz = add(p, mul(fa(ta), tsz * 0.14 * k)); }    // an eye pylon
          if (ts !== "C") glowDot(mz, 0.6 * k, tt); else glowDot(mz, (0.55 + 0.15 * Math.sin(t * 6)) * k, tt);
          if (k4 === "A") { fill(mz, [[0, -1.6], [2, 1.2], [-2, 1.2]], A(lc3, 0.5), ta + Math.PI / 2, k); outline(mz, [[0, -1.6], [2, 1.2], [-2, 1.2]], lc3, 1, ta + Math.PI / 2, k); } }   // Prism: a prism on the muzzle
        });  // the corner stations
    }
    // ---- Path 1: the centre. Footing, then the mast (step 2), the Retrofit hub, the emitter kit (steps 3 and 4), the hub and the dish ----------------
    const gold1 = L1 >= 5, dc = (gold1 || gold2) ? GOLD : METAL_L, rD = 10 + [0, 1.2, 2, 2.2, 3, 3.4][L1] + (B.r === 0 ? 1.2 : 0), mast = Kp(B, 0, 1);
    plate(c, ngon(6, 1), METAL_D, 0, 7 * k, 1.2); ring(c, 6.2 * k, A(OUTLINE, 0.6), 1 * k);
    if (mast === "A") { plate(c, rectPts(3.2, 3.2), METAL, Math.PI / 4, k, 1); line(S(-2.2, -2.2), S(2.2, 2.2), METAL_L, 0.9 * k); line(S(2.2, -2.2), S(-2.2, 2.2), METAL_L, 0.9 * k);
      for (const [gx, gy] of [[-6.4, -6.4], [6.4, -6.4], [6.4, 6.4], [-6.4, 6.4]]) line(c, S(gx, gy), A(STEEL, 0.9), 0.8 * k); }
    if (mast === "B") { for (let i = 0; i < 3; i++) { const d = fa(-Math.PI / 2 + i * TAU / 3), e = add(c, mul(d, 7.4 * k)); bar(c, e, 1.7 * k, METAL); disc(e, 1.1 * k, METAL_L); } ring(c, 4.4 * k, METAL_L, 1.1 * k); }
    if (mast === "C") { disc(c, 6.6 * k, OUTLINE); disc(c, 6.1 * k, METAL_D); ring(c, 5 * k, METAL_L, 1 * k); ring(c, 3.7 * k, METAL, 1 * k); for (let i = 0; i < 8; i++) line(add(c, mul(fa(i * TAU / 8), 3.7 * k)), add(c, mul(fa(i * TAU / 8), 6.1 * k)), STEEL, 0.8 * k); }
    if (B.r === 1) { if (R === "A") { ring(c, 4.9 * k, METAL_L, 1.8 * k); for (let i = 0; i < 8; i++) { const q = add(c, mul(fa(i * TAU / 8 + 0.2), 4.9 * k)); disc(q, 0.8 * k, OUTLINE); disc(q, 0.55 * k, fmod(t * 2 + i * 0.3, 1.5) < 0.6 ? col : DARKP); } }
      if (R === "B") { plate(c, rectPts(3, 3), METAL_L, 0, k, 1.2); plate(c, rectPts(2.4, 2.4), METAL_D, 0, k, 0.9); for (let i = 0; i < 3; i++) line(c, add(c, mul(fa(t * 6 + i * TAU / 3), 2.1 * k)), METAL_L, 0.9 * k); glowDot(S(2.2, -2.2), 0.4 * k, col); }
      if (R === "C") { for (let i = 0; i < 3; i++) { const h = 3.8 - i * 0.9; plate(c, rectPts(h, h), i % 2 ? METAL_D : METAL_L, i * 0.26, k, 1); } glowDot(c, 0.8 * k, col); } }
    if (B.r === 2) { if (R === "A") { bar(c, S(0, -13.4), 1.6 * k, METAL); for (let i = 0; i < 3; i++) line(S(-2.2 + i * 0.4, -5 - i * 3), S(2.2 - i * 0.4, -5 - i * 3), METAL_L, 1 * k); glowDot(S(0, -14), (0.7 + 0.3 * Math.sin(t * 4)) * k, [1, 0.3, 0.3, 1]); }
      if (R === "B") { plate(c, rectPts(4, 4), METAL_L, Math.PI / 4, k, 1.2); plate(c, rectPts(2.8, 2.8), METAL_D, Math.PI / 4, k, 0.9); for (let i = 0; i < 4; i++) { const d = fa(Math.PI / 4 + i * Math.PI / 2); bar(add(c, mul(d, 3 * k)), add(c, mul(d, 7 * k)), 1.2 * k, METAL); disc(add(c, mul(d, 3 * k)), 0.5 * k, YELLOW_W); } }
      if (R === "C") for (let i = 0; i < 4; i++) { const d = fa(Math.PI / 4 + i * Math.PI / 2), q = add(c, mul(d, 5.6 * k)); bar(c, q, 1.3 * k, METAL); disc(q, 1.2 * k, OUTLINE); const on = Math.floor(t * 4) % 4 === i; disc(q, 0.9 * k, on ? [1, 1, 1, 1] : DARKP); if (on) glowDot(q, 0.9 * k, [1, 1, 1, 1]); } }
    // path 1, steps 3 and 4: the emitter kit
    const fp = add(c, mul(fa(ang), 6.2 * k)), em = Kp(B, 0, 2), hp = Kp(B, 0, 3), ec = (gold1 || gold2) ? GOLD : RAD;
    if (hp === "A") for (let i = 0; i < 4; i++) { const d = fa(Math.PI / 4 + i * Math.PI / 2 + 0.3), q = add(c, mul(d, 4.2 * k)); plate(q, rectPts(1.1, 1.8), METAL_D, Math.atan2(d[1], d[0]), k, 0.9); for (let j = -1; j <= 1; j++) line(add(q, mul(orth(d), j * 0.8 * k)), add(add(q, mul(orth(d), j * 0.8 * k)), mul(d, 1.8 * k)), METAL_L, 0.7 * k); }
    if (hp === "B") for (let i = 0; i < 3; i++) { const q = add(c, mul(fa(Math.PI / 2 + i * TAU / 3 + 0.5), 4.8 * k)); disc(q, 1.7 * k, OUTLINE); disc(q, 1.4 * k, METAL_D); ring(q, 1.1 * k, A(ec, 0.9), 0.8 * k); glowDot(q, 0.45 * k, ec); }
    if (hp === "C") { const a = add(c, [-5.6 * k, 0]), b = add(c, [5.6 * k, 0]); for (const q of [a, b]) { bar(add(q, [0, 1.8 * k]), add(q, [0, -1.8 * k]), 1.3 * k, METAL); disc(add(q, [0, -2 * k]), 0.9 * k, METAL_L); }
      const pts = [add(a, [0, -2 * k])]; for (let j = 1; j < 6; j++) pts.push(add(lerp(add(a, [0, -2 * k]), add(b, [0, -2 * k]), j / 6), [0, (rnd(Math.floor(t * 20) + j) - 0.5) * 2.4 * k])); pts.push(add(b, [0, -2 * k])); polyline(pts, A(ec, 0.35), 3); polyline(pts, ec, 1.1); }
    if (L1 >= 5) { const mk = B.key("p0s4");
      if (mk === "A") for (let i = 0; i < 8; i++) { const a = i * TAU / 8 + 0.2, q = add(c, mul(fa(a), 6.8 * k)); fill(q, [[-0.4, -0.8], [1.8, -1.5], [1.8, 1.5], [-0.4, 0.8]], GOLD, a, k); }
      if (mk === "C") { disc(c, 5.8 * k, OUTLINE); disc(c, 5.3 * k, dk(GOLD, 0.5)); for (let i = -1; i <= 1; i++) { line(S(i * 1.9, -5), S(i * 1.9, 5), GOLD, 0.8 * k); line(S(-5, i * 1.9), S(5, i * 1.9), GOLD, 0.8 * k); } ring(c, 5.3 * k, GOLD, 1.2 * k); } }
    orb(c, 4 * k, METAL); glowDot(c, 1.1 * k, gold1 ? GOLD : col);
    // the dish (turning) and its feed
    const dsk = Kp(B, 0, 0), wd = 1.7 * k;
    for (const sg of [-1, 0, 1]) { const a = ang + sg * 0.85; bar(c, add(c, mul(fa(a), (rD - 0.2) * k)), 1.1 * k, METAL_L); }                          // three struts join the dish to the mast
    if (L2 >= 5) { const a2 = ang + Math.PI, r2 = rD * 0.95, f2 = add(c, mul(fa(a2), 6.2 * k));                                                                  // Constant Track: a second, gold dish opposite the first
      for (const sg of [-1, 0, 1]) { const a = a2 + sg * 0.85; bar(c, add(c, mul(fa(a), (r2 - 0.2) * k)), 1.1 * k, METAL_L); }
      arc(c, r2 * k, a2 - 1.1, a2 + 1.1, OUTLINE, 3 * k); arc(c, r2 * k, a2 - 1.1, a2 + 1.1, GOLD, 1.7 * k); line(c, f2, METAL_L, 1 * k); }
    if (dsk === "B") { arc(c, (rD - 0.8) * k, ang - 1.1, ang + 1.1, A(OUTLINE, 0.7), 1.2 * k);
      for (let j = 0; j < 5; j++) { const a0 = ang - 1.1 + j * 0.44 + 0.03; arc(c, rD * k, a0, a0 + 0.38, OUTLINE, 3 * k); arc(c, rD * k, a0, a0 + 0.38, dc, wd); }
      for (let j = 0; j <= 5; j++) { const a = ang - 1.1 + j * 0.44; line(add(c, mul(fa(a), rD * k)), add(c, mul(fa(a), (rD - 2.6) * k)), A(STEEL, 0.9), 0.9 * k); } }
    else if (dsk === "C") { arc(c, rD * k, ang - 1.1, ang + 1.1, OUTLINE, 2.6 * k); arc(c, rD * k, ang - 1.1, ang + 1.1, dc, 1 * k); arc(c, (rD - 1.9) * k, ang - 1.1, ang + 1.1, dc, 1 * k);
      for (let j = 0; j <= 10; j++) { const a = ang - 1.1 + j * 0.22; line(add(c, mul(fa(a), rD * k)), add(c, mul(fa(a + 0.11), (rD - 1.9) * k)), A(dc, 0.8), 0.8 * k); } }
    else { arc(c, rD * k, ang - 1.1, ang + 1.1, OUTLINE, 3 * k); arc(c, rD * k, ang - 1.1, ang + 1.1, dc, wd); arc(c, (rD - 0.3) * k, ang - 0.9, ang - 0.1, lt(dc, 0.4), 0.6 * k); }
    if (B.r === 0) { if (R === "A") { arc(c, (rD + 1.8) * k, ang - 1.1, ang + 1.1, OUTLINE, 2 * k); arc(c, (rD + 1.8) * k, ang - 1.1, ang + 1.1, dc, 0.9 * k); }
      if (R === "B") for (const sg of [-1, 1]) { const a = ang + sg * 1.1; fill(add(c, mul(fa(a), rD * k)), [[0, -1.8], [3.2, 0], [0, 1.8]], dc, a + (sg > 0 ? Math.PI * 0.5 : -Math.PI * 0.5) - sg * 0.1, k); }
      if (R === "C") { arc(c, rD * 0.6 * k, ang - 1.1, ang + 1.1, OUTLINE, 2.4 * k); arc(c, rD * 0.6 * k, ang - 1.1, ang + 1.1, dc, 1.2 * k); } }
    line(c, fp, METAL_L, 1 * k);
    if (L1 >= 5 && B.key("p0s4") === "B") { for (const sg of [-1, 0, 1]) bar(add(c, mul(fa(ang + sg * 0.9), rD * k)), fp, 0.9 * k, GOLD); fill(fp, [[0, -1.2], [3.4, -2.6], [3.4, 2.6], [0, 1.2]], GOLD, ang, k); }   // Gold Feed Tripod
    if (em === "A") fill(fp, [[0, -0.9], [3.2, -2.3], [3.2, 2.3], [0, 0.9]], (gold1 || gold2) ? GOLD : lt(RAD, 0.1), ang, k);
    if (em === "B") { const pts = []; for (let j = 0; j <= 8; j++) pts.push(add(add(c, mul(fa(ang), (5 + j * 0.55) * k)), mul(orth(fa(ang)), (j % 2 ? 1.2 : -1.2) * k))); polyline(pts, OUTLINE, 3 * k); polyline(pts, ec, 1.4 * k); }
    if (em === "C") { const u = fa(ang), v = orth(u), P0 = add(c, mul(u, 5 * k)), Tp = add(add(c, mul(u, 8.4 * k)), mul(v, 2.6 * k)), Tm = add(add(c, mul(u, 8.4 * k)), mul(v, -2.6 * k)),
        vp = [P0, Tp, add(Tp, mul(v, -1.4 * k)), add(P0, mul(u, 2.6 * k)), add(Tm, mul(v, 1.4 * k)), Tm];                                                       // one solid V, not two bars
      polyline([...vp, vp[0]], OUTLINE, 2 * k); poly(vp, (gold1 || gold2) ? GOLD : lt(RAD, 0.1)); }
    if (L2 >= 5) glowDot(add(c, mul(fa(ang + Math.PI), 6.2 * k)), 0.9 * k, GOLD);                                                  // the second dish's light, on top
    glowDot(add(c, mul(fa(ang), (em ? 7.6 : 6.2) * k)), (em ? 0.9 + 0.3 * Math.sin(t * 6) : 0.9) * k, em ? ec : L2 >= 5 ? GOLD : col);
  },
  paths: [], retrofits: [],
};
const YELLOW_W = [1, 0.9, 0.4, 1];

// ---- Option tables: [name, desc] per option, per stage ---------------------------------------------------------------------------------------------
const T = (a, b, c) => [["A", ...a], ["B", ...b], ["C", ...c]].map(([key, name, desc]) => ({ key, name, desc }));
P2.paths = [
  { name: "Power / Range", theme: "the centre: the dish grows, the mast rises, then the radiation emitter and the gold microwave array", steps: [
    { name: "Bigger Array", cost: 305, effect: "180 px radius", options: T(["Solid Dish", "The dish is rebuilt larger as one solid reflector; the range ring widens."], ["Ribbed Dish", "The dish is rebuilt larger from ribbed segments; the range ring widens."], ["Mesh Dish", "The dish is rebuilt larger as an open double-rim mesh; the range ring widens."]) },
    { name: "Tall Mast", cost: 685, effect: "200 px radius", options: T(["Guyed Lattice Mast", "A square lattice mast with four guy wires is built under the dish; the dish grows again."], ["Tripod Mast", "A three-legged tripod with a ring brace is built under the dish; the dish grows again."], ["Tiered Tower", "A tiered cylindrical tower is built under the dish; the dish grows again."]) },
    { name: "Radiation Emitter", cost: 585, effect: "Radiation circle: 15 energy damage/s within 60 px of revealed enemies (primary)", options: T(["Horn Emitter", "A microwave horn at the dish's focus; a faint red circle of radiation appears round the tower."], ["Coil Emitter", "A red coil at the dish's focus; a faint red circle of radiation appears round the tower."], ["Twin Prong Emitter", "Two prongs from the hub to the focus; a faint red circle of radiation appears round the tower."]) },
    { name: "High-Power Emitter", cost: 3995, effect: "220 px radius; radiation 25/s within 70 px", options: T(["Finned Heat Sinks", "Four finned heat sinks are built round the hub; the red circle widens."], ["Capacitor Bank", "Three glowing capacitor drums are built round the hub; the red circle widens."], ["Arc Pylons", "Two arcing pylons are built either side of the hub; the red circle widens."]) },
    { name: "Microwave Array", cost: 6440, effect: "230 px radius; radiation 40/s within 80 px (mastery)", options: T(["Horn Ring", "The dish turns gold and a ring of eight gold horns is built round the hub; the red circle turns gold."], ["Gold Feed Tripod", "The dish turns gold and three gold struts hold a big gold horn at its focus; the red circle turns gold."], ["Gold Lattice Array", "The dish turns gold and a gold lattice array is built over the hub; the red circle turns gold."]) },
  ] },
  { name: "Speed / Frequency", theme: "the edges: a phased-array panel on each edge, then gold with a constant reveal", steps: [
    { name: "Faster Sweep", cost: 255, effect: "A ping every 2.7 s, revealing for 1.1 s", options: T(["Tile Panel", "A tile panel is built on the south edge; the dish turns faster."], ["Curved Array", "A curved array is built on the south edge; the dish turns faster."], ["Louvre Panel", "A louvre panel is built on the south edge; the dish turns faster."]) },
    { name: "Pulse Compression", cost: 640, effect: "Every 2.4 s, for 1.2 s", options: T(["Tile Panel", "A tile panel is built on the north edge; the dish turns faster."], ["Curved Array", "A curved array is built on the north edge; the dish turns faster."], ["Louvre Panel", "A louvre panel is built on the north edge; the dish turns faster."]) },
    { name: "Rapid Sweep", cost: 2070, effect: "Every 2 s, for 1.3 s (primary)", options: T(["Tile Panel", "A tile panel is built on the east edge; the dish turns faster."], ["Curved Array", "A curved array is built on the east edge; the dish turns faster."], ["Louvre Panel", "A louvre panel is built on the east edge; the dish turns faster."]) },
    { name: "Phased Array", cost: 4485, effect: "Every 1.6 s, for 1.3 s", options: T(["Tile Panel", "A tile panel is built on the west edge; the dish turns at full speed."], ["Curved Array", "A curved array is built on the west edge; the dish turns at full speed."], ["Louvre Panel", "A louvre panel is built on the west edge; the dish turns at full speed."]) },
    { name: "Constant Track", cost: 10350, effect: "Constant: everything hidden in range stays revealed (mastery)", options: T(["Gold Cable Ring", "Every panel turns gold and is tied by a gold cable ring, and a second gold dish is built opposite the first; the sweep is replaced by a steady gold field and the reveal never lapses."], ["Gold Frames", "Every panel turns gold in a gold frame, and a second gold dish is built opposite the first; the sweep is replaced by a steady gold field and the reveal never lapses."], ["Gold Bridges", "Every panel turns gold and is bridged by gold arcs, and a second gold dish is built opposite the first; the sweep is replaced by a steady gold field and the reveal never lapses."]) },
  ] },
  { name: "Unmasking", theme: "the corners: all four corner stations are rebuilt to a new design at every step, and the mark on a revealed enemy changes style", steps: [
    { name: "Signal Analysis", cost: 230, effect: "Pings expose the Decoy Beacon's fake rank", options: T(["Server Racks", "The four corners get small server racks with lamp rows; revealed enemies get brackets and a rank tag."], ["Scope Consoles", "The four corners get scope consoles with live traces; revealed enemies get brackets and a rank tag."], ["Antenna Posts", "The four corners get antenna posts with spinning cups; revealed enemies get brackets and a rank tag."]) },
    { name: "Disguise Breaker", cost: 460, effect: "Pings unmask the Masquerade early", options: T(["Decoder Towers", "The corner racks are replaced by taller decoder towers with whip antennas; revealed enemies get a diamond frame instead of brackets."], ["Dish Pods", "The corner consoles are replaced by round dish pods; revealed enemies get a diamond frame instead of brackets."], ["Yagi Masts", "The corner posts are replaced by long yagi masts; revealed enemies get a diamond frame instead of brackets."]) },
    { name: "Track Lock", cost: 1930, effect: "Reveals last 1.3 s (primary)", options: T(["Tracking Turrets", "The corner towers are replaced by round tracking turrets that turn to follow revealed enemies; the mark becomes a lock ring with a tether."], ["Radar Domes", "The corner pods are replaced by radar domes with turning prongs; the mark becomes a lock ring with a tether."], ["Eye Pylons", "The corner masts are replaced by eye pylons whose pupils follow revealed enemies; the mark becomes a lock ring with a tether."]) },
    { name: "Illusion Filter", cost: 2390, effect: "Pings mark Mirage holograms as fakes", options: T(["Turret Prisms", "Each tracking turret gets a glass prism on its muzzle that splits the beam; the mark becomes a hex frame with a fake-check badge."], ["Turret Lens Rings", "Each tracking turret is ringed by a big glass lens; the mark becomes a hex frame with a fake-check badge."], ["Turret Filter Gates", "Each tracking turret is ringed by four grille shields; the mark becomes a hex frame with a fake-check badge."]) },
    { name: "Total Exposure", cost: 3590, effect: "Revealed enemies can't re-cloak, re-disguise or re-burrow for 5 s after leaving range (mastery)", options: T(["Gold Wall", "Each tracking turret's blue accents turn gold and a gold wall joins the four; the marks become gold lock rings that linger after the enemy leaves."], ["Gold Lamp", "Each tracking turret's blue accents turn gold and a gold lamp glows on it; the marks become gold lock rings that linger after the enemy leaves."], ["Twin Barrel", "Each tracking turret's blue accents turn gold and it gains a twin barrel; the marks become gold lock rings that linger after the enemy leaves."]) },
  ] },
];
P2.retrofits = [
  { name: "Bigger Dish", cost: 305, effect: "+20 radius (stacks with the range steps)", options: T(["Outer Rim", "The dish gains a second outer rim; the range ring widens."], ["Flared Ends", "The dish gains flared ends; the range ring widens."], ["Sub-Reflector", "The dish gains a concentric sub-reflector; the range ring widens."]) },
  { name: "Signal Processor", cost: 575, effect: "Each reveal lasts 1.5 s (stacks with the reveal steps)", options: T(["Chip Ring", "A ring of blinking chips is built round the hub; brackets stay longer."], ["Fan Box", "A cooled processor box with a spinning fan is built on the hub; brackets stay longer."], ["Chip Stack", "A stack of three rotated chip plates is built on the hub; brackets stay longer."]) },
  { name: "Early Warning", cost: 230, effect: "Shows the next wave's hidden enemies in the wave preview", options: T(["Beacon Mast", "A tall mast with a red beacon is built north of the hub."], ["Lookout Tower", "A square lookout tower with four legs is built on the hub."], ["Strobe Pylons", "Four strobing pylons are built round the hub."]) },
];

// ---- Round 2 (owner's picks, 2026-10-19). Path 3 and the Signal Processor are unpicked: they show their options again.
P2.picks = { p0s0: "A", p0s1: "C", p0s2: "C", p0s3: "B", p0s4: "A", p1s0: "B", p1s1: "B", p1s2: "B", p1s3: "B", p1s4: "A", p2s0: "B", p2s1: "A", p2s2: "A", p2s3: "B", p2s4: "B", r0: "C", r1: "A", r2: "B" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { const pk = P2.picks["p" + pi + "s" + k]; if (pk) st.options = st.options.filter((o) => o.key === pk); }));
P2.retrofits.forEach((rf, ri) => { const pk = P2.picks["r" + ri]; if (pk) rf.options = rf.options.filter((o) => o.key === pk); });
