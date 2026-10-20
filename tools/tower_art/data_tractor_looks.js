// ---- Tractor Tower base-look page (redesign, owner 2026-10-19: "I want to completely redesign the tractor tower from scratch") ----------------------------------------
// Scope (owner): the art and the upgrade art start over; the mechanic, the paths, their effects and their names stay. Direction (owner): a dish on a mast,
// as two dish looks plus one wildcard, and three new animations to pick. The tower grabs one enemy, holds it 1.5 s while hauling it back 80 px, lets go and
// recharges (6 s; the preview shortens it). The preview can't move enemies, so the held one is hidden and redrawn where the beam drags it.
const PAGE = { title: "Tractor Tower base look (redesign)", store: "bl-tower-art-tractor-looks-7" };
const distTo = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const enemyR = (s) => Math.max(4, Math.min(11, s * 0.12));
const nearestTo = (p, list) => { let best = null, bd = 1e9; for (const e of list) { const d = distTo(e.p, p); if (d < bd) { bd = d; best = e; } } return best; };
const DISH = [0.82, 0.85, 0.88, 1], DISH_IN = [0.66, 0.7, 0.75, 1], ARMOUR = [0.36, 0.39, 0.44, 1];
const CYCLE = 4; // the real recharge is 6 s; the preview shortens it
// The tractor cycle (the confirmed mechanic): grab the nearest enemy in range, hold and haul it back, drop it, recharge. cfg.beam draws the beam, cfg.held the hold.
function tractorAgent(cfg) { return (m, t, info, s, col) => { const back = s * 80 / 48;
  if (!m.state) { m.state = "ready"; m.t0 = t; }
  if (m.state === "ready") { const e = nearestTo(info.c, info.ens.filter((x) => distTo(x.p, info.c) < s * 3.3 && x.p[0] > s * 0.6)); if (e) { m.state = "hold"; m.t0 = t; m.id = e.i; m.p0 = e.p.slice(); m.air = e.air; } }
  if (m.state === "hold" || m.state === "drop") { const e = info.all.find((x) => x.i === m.id), u = Math.min(1, (t - m.t0) / 1.5);
    if (!e) { m.state = "cool"; m.t0 = t; return; }
    const held = add(m.p0, [-back * ease(u), m.air ? Math.sin(t * 6) * 2 : 0]);
    if (m.state === "hold") { m.aimAt = held; disc(e.p, enemyR(s) + 2, e.air ? [0.072, 0.093, 0.08, 0.92] : [0.16, 0.15, 0.13, 0.92]);
      cfg.beam(info.muzzleAt(0, info.aim), held, u, s, col, t, info); for (let i = 1; i <= 2; i++) { X.save(); X.globalAlpha = 0.25 / i; drawEnemy({ ...e, p: add(held, [i * 5, 0]) }, s); X.restore(); }
      drawEnemy({ ...e, p: held }, s); if (cfg.held) cfg.held(held, s, col, t); if (u >= 1) { m.state = "drop"; m.t0 = t; m.final = held; } }
    else { const v = (t - m.t0) / 0.4; X.save(); X.globalAlpha = Math.max(0, 1 - v); drawEnemy({ ...e, p: m.final }, s); X.restore(); disc(e.p, enemyR(s) + 2, A(e.air ? [0.072, 0.093, 0.08, 1] : [0.16, 0.15, 0.13, 1], 0.92 * Math.max(0, 1 - v))); if (v >= 1) { m.state = "cool"; m.t0 = t; } } }
  if (m.state === "cool") { m.aimAt = null; if (t - m.t0 > CYCLE - 1.9) m.state = "ready"; }
  m.charge = m.state === "cool" ? Math.min(1, (t - m.t0) / (CYCLE - 1.9)) : m.state === "ready" ? 1 : 0; }; }
// A dish seen from above, tilted to face along the aim: a foreshortened ellipse (rx along the aim, ry across it)
function dishFace(dc, aim, k, rx, ry, rim, face, ribs) { oval(dc, rx * k, ry * k, aim, rim, 1.4); oval(add(dc, rot([0.8 * k, 0], aim)), (rx - 1) * k, (ry - 1.4) * k, aim, face, 0);
  for (let i = 0; i < ribs; i++) { const th = i * TAU / ribs; line(dc, add(dc, rot([Math.cos(th) * (rx - 0.4) * k, Math.sin(th) * (ry - 0.6) * k], aim)), A(METAL_D, 0.45), 0.6 * k); }
  oval(dc, rx * 0.5 * k, ry * 0.5 * k, aim, A(METAL_D, 0.18), 0); }

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

const TOWERS = [
  { id: "tractor", num: 19, name: "Tractor Tower", cls: "Defense", weapon: "Energy", hits: "both", color: [0.40, 0.95, 1.00, 1],
    desc: "A dish-mounted emitter that locks a tractor beam onto a single enemy and hauls it back down the track before letting go. \"You're my friend now.\" It grabs one enemy, holds it 1.5 s while dragging it back 80 px, lets go, then recharges (6 s; the preview shortens it). Redesign: two dish-on-a-mast looks and one wildcard, and three new animations. (Colour: cyan.)",
    looks: [
      { key: "A", name: "Radio Telescope", muzzle: 12 / 48, theme: "A big white mesh dish on a lattice mast, like a radio telescope, tilting to face its target; three struts hold a feed horn at its focus, where the beam leaves, and a counterweight hangs off the back.",
        draw(c, aim, s, fx, t, col) { const k = G(s), on = fx.mem?.state === "hold" ? 1 : 0, Q = (x, y) => P(c, aim, k, x, y); deck(c, k, col, t);
          const mp = Q(-3, 0); plate(mp, rectPts(5.6, 5.6), METAL_D, aim, k, 1.2); for (const sg of [-1, 1]) line(add(mp, rot([-5 * k, -5 * sg * k], aim)), add(mp, rot([5 * k, 5 * sg * k], aim)), METAL_L, 0.9 * k);   // the lattice mast
          plate(Q(-9.4, 0), rectPts(2.4, 4.2), METAL, aim, k, 1.2); bar(Q(-7, 0), Q(-3, 0), 1.4 * k, METAL_L);                                                // the counterweight
          dishFace(Q(3, 0), aim, k, 4.6, 12, DISH, DISH_IN, 16);
          const F = Q(12, 0); for (const sg of [-1, 1]) line(Q(3.4, sg * 11.2), F, OUTLINE, 1.6 * k), line(Q(3.4, sg * 11.2), F, METAL_L, 0.8 * k); line(Q(4, 0), F, METAL_L, 0.8 * k);
          disc(F, 2 * k, OUTLINE); disc(F, 1.5 * k, METAL); glowDot(F, (0.8 + 0.9 * on + 0.2 * Math.sin(t * 5)) * k, col); } },
      { key: "B", name: "Armoured Dish", muzzle: 13 / 48, theme: "A solid armoured dish of riveted steel segments raised on twin hydraulic rams over a heavy round base; a long emitter spike juts from its centre, and its rim glows cyan when it locks on.",
        draw(c, aim, s, fx, t, col) { const k = G(s), on = fx.mem?.state === "hold" ? 1 : 0, Q = (x, y) => P(c, aim, k, x, y); deck(c, k, col, t);
          plate(c, ngon(32, 1, 0), METAL, aim, 9.4 * k, 1.3); ring(c, 9.4 * 0.72 * k, A(OUTLINE, 0.35), 0.8 * k); rivets(c, ngon(10, 1, 0), aim, 9.4 * k, 0.84, 0.7 * k);   // a round platform (owner)
          for (const sg of [-1, 1]) { bar(Q(-6.5, sg * 3.6), Q(1, sg * 4.4), 2.6 * k, METAL_D); bar(Q(-2.5, sg * 4), Q(1, sg * 4.4), 1.3 * k, METAL_L); }                   // twin hydraulic rams
          const F = dishArc(c, aim, k, ARMOUR, lt(ARMOUR, 0.14), METAL_L); rimLine(F, aim, k, A(col, 0.45 + 0.5 * on + 0.1 * Math.sin(t * 4)), 1.2);   // the flat dish (round 3); its rim glows on a lock
          antennaRod(c, aim, k, 12.6, METAL_L, METAL_L); spikeHub(c, aim, k, METAL_D); feedHead(Q(12.8, 0), k, METAL, col, on); } },
      { key: "C", name: "Gravity Ring Projector", muzzle: 6 / 48, theme: "Wildcard: no dish. Three nested gimbal rings float over a pedestal, tilting and turning round a glowing emitter crystal that points at the target.",
        draw(c, aim, s, fx, t, col) { const k = G(s), on = fx.mem?.state === "hold" ? 1 : 0; deck(c, k, col, t); orb(c, 5 * k, METAL);
          for (let j = 0; j < 3; j++) { const rr = 14 - j * 3.4, tilt = 0.25 + 0.7 * Math.abs(Math.cos(t * (0.7 + 0.25 * j) + j * 1.3)), a = aim + Math.PI / 2 + j * 0.5 + t * 0.2 * (j % 2 ? -1 : 1);
            X.save(); for (const [w, cc] of [[2.8, OUTLINE], [1.6, j === 1 ? lt(METAL_L, 0.1) : METAL_L]]) { X.strokeStyle = css(cc); X.lineWidth = w * k; X.beginPath(); X.ellipse(c[0], c[1], rr * k, rr * tilt * k, a, 0, TAU); X.stroke(); } X.restore();
            for (const th of [0, Math.PI]) glowDot(add(c, rot([Math.cos(th) * rr * k, Math.sin(th) * rr * tilt * k], a)), 0.6 * k, col); }
          fill(c, [[-1.5, -1.8], [6.4, 0], [-1.5, 1.8]], lt(col, 0.2), aim, k); outline(c, [[-1.5, -1.8], [6.4, 0], [-1.5, 1.8]], OUTLINE, 1, aim, k); glowDot(c, (1.2 + 0.9 * on) * k, col); } },
    ],
    anims: [
      { key: "A", name: "Light Cone", desc: "A wide, soft cone of cyan light opens from the dish onto the enemy; bright scan lines run back up the cone toward the tower as the enemy glides back with fading afterimages.", period: 1, flight: 1, fx: () => ({}),
        persist: tractorAgent({ beam: (f, to, u, s, col, t) => { const d = norm(sub(to, f)), o = orth(d), w0 = s * 0.2, w1 = enemyR(s) + 4, L = distTo(f, to);
            poly([add(f, mul(o, w0)), add(to, mul(o, w1)), sub(to, mul(o, w1)), sub(f, mul(o, w0))], A(col, 0.16)); line(add(f, mul(o, w0)), add(to, mul(o, w1)), A(col, 0.5), 1); line(sub(f, mul(o, w0)), sub(to, mul(o, w1)), A(col, 0.5), 1);
            for (let i = 0; i < 4; i++) { const q = 1 - fmod(t * 0.9 + i / 4, 1), p = add(f, mul(d, L * q)), w = w0 + (w1 - w0) * q; line(add(p, mul(o, w)), sub(p, mul(o, w)), A(lt(col, 0.3), 0.6 * q + 0.1), 1.2); } } }) },
      { key: "B", name: "Focus Beam", desc: "A tight, bright beam fires from the emitter; glowing rings slide down it from the enemy to the dish as if reeling it in, and the enemy shakes in the grip.", period: 1, flight: 1, fx: () => ({}),
        persist: tractorAgent({ beam: (f, to, u, s, col, t) => { strip(f, to, 1.6, col); const d = norm(sub(to, f)), L = distTo(f, to);
            for (let i = 0; i < 4; i++) { const q = 1 - fmod(t * 0.9 + i / 4, 1), p = add(f, mul(d, L * q)); X.save(); X.strokeStyle = css(A(col, 0.85)); X.lineWidth = 1.4; X.beginPath(); X.ellipse(p[0], p[1], 2.4, 6.5, Math.atan2(d[1], d[0]), 0, TAU); X.stroke(); X.restore(); } },
          held: (p, s, col, t) => ring(add(p, [Math.sin(t * 40), 0]), enemyR(s) + 3, A(col, 0.7), 1.2) }) },
      { key: "C", name: "Tractor Waves", desc: "Curved wave fronts ripple out from the dish to the enemy, and chevrons run back along the beam toward the tower; the held enemy sits in rippling rings.", period: 1, flight: 1, fx: () => ({}),
        persist: tractorAgent({ beam: (f, to, u, s, col, t) => { const d = norm(sub(to, f)), L = distTo(f, to), a = Math.atan2(d[1], d[0]); line(f, to, A(col, 0.25), 2);
            for (let i = 0; i < 4; i++) { const q = fmod(t * 1.1 + i / 4, 1); arc(f, L * q, a - 0.22, a + 0.22, A(col, 0.7 * (1 - q) + 0.15), 1.6); }
            for (let i = 0; i < 5; i++) { const q = 1 - fmod(t * 1.4 + i / 5, 1), p = add(f, mul(d, L * q)); polyline([add(p, rot([3, -3], a)), p, add(p, rot([3, 3], a))], A(lt(col, 0.3), 0.85), 1.3); } },
          held: (p, s, col, t) => { for (let i = 0; i < 3; i++) { const q = fmod(t * 1.3 + i / 3, 1); ring(p, enemyR(s) + 3 + q * 9, A(col, 0.7 * (1 - q)), 1.2); } } }) },
    ] },
];
// Round 2 (owner, 2026-10-19): look B Armoured Dish, animation B Focus Beam; the page shows only the picks. Round 3: the dish is redrawn flat, straight from above.
TOWERS[0].looks = TOWERS[0].looks.filter((l) => l.key === "B"); TOWERS[0].anims = TOWERS[0].anims.filter((a) => a.key === "B");
const DEFAULTS = { tractor: { look: "B", anim: "B" } };
