// ---- Tower art page 3: towers 11-15, in the style of today's in-game towers (owner, 2026-10-16) ----------
// Shared style helpers come from game_style.js. Every tower here is a persistent agent (mines on the track, soaks,
// boosts, pings, cold waves) rather than a turret firing shots.
const PAGE = { title: "Tower art page 3 (towers 11-15)", store: "bl-tower-art-3-game-v3" };

const rnd = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const distTo = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const nearestTo = (p, list) => { let best = null, bd = 1e9; for (const e of list) { const d = distTo(e.p, p); if (d < bd) { bd = d; best = e; } } return best; };
const FROST = [0.8, 0.92, 1, 1], ACID = [0.55, 1, 0.3, 1];

// ---- Mine Layer: mines tossed onto the track wait there and go off when a ground enemy rolls over them ----------
function mineAgent(cfg) { return (m, t, info, s, col) => { const k = G(s), laneY = info.H * 0.8;
  if (!m.mines) { m.mines = []; m.lastToss = t - 1; m.n = 0; }
  const pick = () => [s * 0.25 + Math.random() * (info.W - s * 0.5), laneY + (Math.random() - 0.5) * s * 0.3]; // random spots along and across the track (owner)
  if (!m.next) m.next = pick(); m.aimAt = m.next;
  if (t - m.lastToss >= 1.5 && m.mines.filter((q) => !q.boom).length < 6) { m.n++; m.mines.push({ to: m.next, t0: t, from: add(info.c, mul(norm(sub(m.next, info.c)), s * 0.3)), n: m.n }); m.lastToss = t; m.next = pick(); }
  for (const q of m.mines) { const age = t - q.t0;
    if (q.boom) { cfg.boom(q.to, (t - q.boom) / 0.6, s, col, q.n); continue; }
    if (age < cfg.flight) { cfg.fly(q.from, q.to, age / cfg.flight, s, col, info.look, t); continue; }
    if (cfg.land && age < cfg.flight + 0.3) cfg.land(q.to, (age - cfg.flight) / 0.3, s);
    info.look.mine(q.to, k, t, col, fmod(t * 1.6 + q.n * 0.37, 1) < 0.25, cfg.armed);
    for (const e of info.ens) if (distTo(e.p, q.to) < s * 0.15) { q.boom = t; break; } }
  m.mines = m.mines.filter((q) => !q.boom || t - q.boom < 0.6); }; }

// ---- Chemical Plant: sprays one enemy at a time; soaked enemies are skipped until the chemical wears off ----------
function soakAgent(cfg) { return (m, t, info, s, col) => {
  if (!m.soak) { m.soak = {}; m.last = -9; }
  const free = info.ens.filter((e) => !(m.soak[e.i] > t)), tg = nearestTo(info.c, free);
  if (tg) m.aimAt = tg.p.slice();
  if (tg && !m.shot && t - m.last >= 1.5) { m.last = t; m.shot = { t0: t, id: tg.i }; }
  if (m.shot) { const age = t - m.shot.t0, e = info.ens.find((x) => x.i === m.shot.id);
    if (!e) m.shot = null; else if (age >= cfg.flight) { m.soak[e.i] = t + 4; m.shot = null; } else cfg.shot(info.muzzleAt(0, info.aim), e.p, age / cfg.flight, s, col, t); }
  for (const e of info.ens) if (m.soak[e.i] > t) cfg.soaked(e.p, (m.soak[e.i] - t) / 4, s, col, t, e.i); }; }

// ---- Boost Tower: no attack; it boosts the towers around it ---------------------------------------------------
const MATES = [[[1.15, -0.25], [0.30, 0.90, 1.00, 1]], [[1.0, 0.72], [1.00, 0.55, 0.20, 1]], [[-0.85, 0.78], [1.00, 0.30, 0.35, 1]]];
const matesOf = (info) => MATES.map(([o, col]) => ({ p: add(info.c, mul(o, info.s)), col }));
function mateTower(p, k, col, t, boosted, bcol) { deck(p, k * 0.75, col, t); const aim = -0.5 + Math.sin(t * 0.7 + p[0]) * 0.4;
  bar(p, P(p, aim, k * 0.75, 15, 0), 3 * k * 0.75, METAL_L); plate(p, ngon(8, 1, Math.PI / 8), METAL_L, aim, 6.5 * k * 0.75, 1); orb(p, 3.4 * k * 0.75, METAL); glowDot(p, 1 * k, col);
  if (boosted > 0) for (let i = 0; i < 2; i++) { const q = add(p, [0, -(16 + i * 3.4) * k * 0.75]); polyline([add(q, [-2.6 * k, 1.6 * k]), q, add(q, [2.6 * k, 1.6 * k])], A(bcol, boosted), 1.6 * k); } }

// ---- Radar Tower: cloaked enemies (every other one) stay hidden until a ping reveals them for a moment ------------
const cloaked = (e) => e.i % 2 === 0;
function hideCloaked(e, s, t) { const r = Math.max(4, Math.min(11, s * 0.12)) + 2; disc(e.p, r, e.air ? [0.07, 0.09, 0.08, 0.82] : [0.16, 0.15, 0.13, 0.82]);
  ring(e.p, r - 1, [0.7, 0.9, 1, 0.18 + 0.1 * Math.sin(t * 9 + e.i)], 1); }
function revealMark(p, s, col, a) { const r = Math.max(4, Math.min(11, s * 0.12)) + 4;
  for (let i = 0; i < 4; i++) { const d = fa(Math.PI / 4 + i * Math.PI / 2), c0 = add(p, mul(d, r)); line(c0, add(c0, mul(rot(d, Math.PI * 0.75), r * 0.6)), A(col, a), 1.5); line(c0, add(c0, mul(rot(d, -Math.PI * 0.75), r * 0.6)), A(col, a), 1.5); } }
const sweepAngle = (info, t) => (info.look.dishAngle ? info.look.dishAngle(t) : t * TAU / 3); // the sweep follows the dish (owner)
function radarAgent(cfg) { return (m, t, info, s, col) => { if (!m.seen) m.seen = {};
  cfg.draw(m, t, info, s, col);
  for (const e of info.all) { if (!cloaked(e)) continue; const until = m.seen[e.i] || 0;
    if (cfg.hits(m, t, info, s, e)) m.seen[e.i] = t + 1;
    if (until > t) revealMark(e.p, s, col, Math.min(1, (until - t) * 2)); else hideCloaked(e, s, t); } }; }

// ---- Cryo Tower: a cold wave every 2 s; enemies it reaches are chilled (slowed; the preview doesn't slow them) ----
function chillMark(p, s, a) { const r = Math.max(4, Math.min(11, s * 0.12)); disc(p, r + 1, A([0.6, 0.85, 1, 1], 0.6 * a)); ring(p, r + 2, A([0.75, 0.92, 1, 1], 0.9 * a), 1.4); for (let i = 0; i < 3; i++) { const d = fa(i * Math.PI / 3); line(sub(p, mul(d, r * 0.7)), add(p, mul(d, r * 0.7)), [1, 1, 1, 0.75 * a], 1); } }
function coldAgent(cfg) { return (m, t, info, s, col) => { if (!m.cold) { m.cold = {}; m.wave = t; }
  if (t - m.wave >= 2) m.wave = t;
  const R = s * 2.3, u = (t - m.wave) / cfg.travel; cfg.draw(info.c, Math.min(1, u), R, s, col, t, u);
  for (const e of info.ens) if (u <= 1 && distTo(e.p, info.c) < R * u) m.cold[e.i] = t + 1.8;
  for (const e of info.ens) if ((m.cold[e.i] || 0) > t) chillMark(e.p, s, Math.min(1, (m.cold[e.i] - t) * 1.5)); }; }

const TOWERS = [
  // 11. Mine Layer --------------------------------------------------------------------------------------
  { id: "mines", num: 11, name: "Mine Layer", cls: "Defense", weapon: "Explosive", hits: "ground", color: [1.00, 0.40, 0.25, 1],
    desc: "Manufactures and tosses explosive mines onto the track that explode when an enemy passes over them. \"You know it's a party when the high-speed confetti start flying in every direction.\" Ground and burrowed enemies set them off; up to 20 on the track (the preview caps at 6). Mines land at random spots along and across the track (round 3). The look sets the fabricator and its mine. (Colour: a new red-orange; no in-game counterpart.)",
    looks: [
      { key: "A", name: "Arm Fabricator", muzzle: 0.3, theme: "A boxy fabricator with a press hatch and a throwing arm that swings round to fling each new mine. Mine: a flat disc with a blinking red-orange light.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, sw = decay(t - (mm.lastToss ?? -9), 0.35); deck(c, k, col, t);
          plate(c, rectPts(10, 10), METAL_L, 0, k, 1.3); fill(c, rectPts(7.4, 7.4), METAL, 0, k); rivets(c, rectPts(10, 10), 0, k, 0.86, 0.8 * k); hazard(c, 0, k, -7, 7, 10.6, col, 1.3);
          plate(add(c, [-4.5 * k, -4.5 * k]), rectPts(2.4, 2.4), METAL_D, 0, k, 0.9); glowDot(add(c, [-4.5 * k, -4.5 * k]), 0.8 * k, A(col, 0.6 + 0.4 * Math.sin(t * 6)));
          const a = aim - sw * 1.6, tip = P(c, a, k, 13, 0); bar(c, tip, 2.4 * k, METAL_L); orb(c, 2.8 * k, METAL); if (t - (mm.lastToss ?? -9) > 0.5) this.mine(tip, k * 0.85, t, col, false); },
        mine(p, k, t, col, blink) { ellipse(add(p, [k * 0.8, k * 1.6]), 4 * k, 1.8 * k, [0, 0, 0, 0.3]); disc(p, 4 * k, OUTLINE); disc(p, 3.4 * k, METAL); ring(p, 2.4 * k, METAL_L, 0.8 * k); glowDot(p, (blink ? 1.4 : 0.7) * k, A(col, blink ? 1 : 0.55)); } },
      { key: "B", name: "Mine Mortar", muzzle: 0.3, theme: "A round armoured fabricator with a short launch tube that pops mines out in an arc, a feed hopper behind. Mine: a wide anti-tank pancake mine with four bolts.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, kick = decay(t - (mm.lastToss ?? -9), 0.25); deck(c, k, col, t);
          disc(c, 12 * k, OUTLINE); disc(c, 11.2 * k, METAL_L); disc(c, 9 * k, METAL); plate(P(c, aim, k, -8, 0), rectPts(3, 4), AMMO, aim, k, 1);
          bar(P(c, aim, k, -kick * 2, 0), P(c, aim, k, 10 - kick * 2, 0), 6 * k, METAL_L); const b = P(c, aim, k, 10 - kick * 2, 0); disc(b, 3.6 * k, OUTLINE); disc(b, 3 * k, BORE); if (kick > 0) smokePuff(b, 1 - kick, s * 0.6, 0.5);
          glowDot(P(c, aim, k, -1, 0), 1.1 * k, col); },
        mine(p, k, t, col, blink) { ellipse(add(p, [k * 0.8, k * 1.6]), 5 * k, 2 * k, [0, 0, 0, 0.3]); disc(p, 5 * k, OUTLINE); disc(p, 4.4 * k, AMMO); ring(p, 3.2 * k, dk(AMMO, 0.3), 0.8 * k);
          for (let i = 0; i < 4; i++) disc(add(p, mul(fa(Math.PI / 4 + i * Math.PI / 2), 3.6 * k)), 0.6 * k, METAL_L); glowDot(p, (blink ? 1.4 : 0.7) * k, A(col, blink ? 1 : 0.55)); } },
      { key: "C", name: "Conveyor Catapult", muzzle: 0.3, theme: "A long catapult beam on the turret, fed by a short conveyor of ready mines that tick along. Mine: a hexagonal mine with three sensor prongs.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, sw = decay(t - (mm.lastToss ?? -9), 0.3); deck(c, k, col, t);
          plate(add(c, [-6 * k, 9 * k]), rectPts(9, 2.4), METAL_D, 0, k, 1); for (let i = 0; i < 3; i++) this.mine(add(c, [(-12 + fmod(t * 4, 4) + i * 5) * k, 9 * k]), k * 0.5, t, col, false);
          plate(c, ngon(8, 1, Math.PI / 8), METAL_L, aim, 8 * k, 1.2); const tip = P(c, aim - sw * 2.2, k, 15, 0); bar(P(c, aim - sw * 2.2, k, -6, 0), tip, 2.2 * k, METAL_L);
          plate(P(c, aim - sw * 2.2, k, -6, 0), rectPts(2, 3), METAL_D, aim - sw * 2.2, k, 0.9); orb(c, 2.6 * k, METAL); glowDot(c, 1 * k, col); if (t - (mm.lastToss ?? -9) > 0.5) this.mine(tip, k * 0.8, t, col, false); },
        mine(p, k, t, col, blink) { ellipse(add(p, [k * 0.8, k * 1.6]), 4 * k, 1.8 * k, [0, 0, 0, 0.3]); for (let i = 0; i < 3; i++) line(p, add(p, mul(fa(-Math.PI / 2 + i * TAU / 3), 5.2 * k)), METAL_L, 0.8 * k);
          plate(p, ngon(6, 1, 0), METAL, 0, 3.6 * k, 0.9); glowDot(p, (blink ? 1.4 : 0.7) * k, A(col, blink ? 1 : 0.55)); } },
      { key: "D", name: "Drum Dispenser", muzzle: 0.3, theme: "A big rotating drum magazine that clicks round one slot per mine, feeding a short chute arm that flicks it out. Mine: a small sphere with six contact prongs.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, since = t - (mm.lastToss ?? -9), sw = decay(since, 0.3), step = Math.floor((mm.n || 0)) + Math.min(1, since / 0.4); deck(c, k, col, t);
          disc(c, 12 * k, OUTLINE); disc(c, 11.2 * k, METAL_L); for (let i = 0; i < 6; i++) { const q = add(c, mul(fa(step * TAU / 6 + i * TAU / 6), 7.5 * k)); disc(q, 2.6 * k, BORE); if (i) this.mine(q, k * 0.55, t, col, false); }
          orb(c, 3.4 * k, METAL); const tip = P(c, aim - sw * 1.4, k, 15, 0); bar(c, tip, 2.6 * k, METAL); glowDot(c, 1.1 * k, col); if (since > 0.5) this.mine(tip, k * 0.8, t, col, false); },
        mine(p, k, t, col, blink) { ellipse(add(p, [k * 0.8, k * 1.6]), 3.6 * k, 1.6 * k, [0, 0, 0, 0.3]); for (let i = 0; i < 6; i++) { const d = fa(i * TAU / 6); line(add(p, mul(d, 2.6 * k)), add(p, mul(d, 4.4 * k)), METAL_L, 0.9 * k); disc(add(p, mul(d, 4.4 * k)), 0.6 * k, METAL_L); }
          orb(p, 3 * k, METAL); glowDot(p, (blink ? 1.3 : 0.6) * k, A(col, blink ? 1 : 0.55)); } },
      { key: "E", name: "Twin Press Factory", muzzle: 0.3, theme: "Two stamping presses that thump down in turn on a riveted factory block, and a gantry arm that picks up each fresh mine and flicks it out. Mine: a square box mine with a pressure plate on top.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, since = t - (mm.lastToss ?? -9), sw = decay(since, 0.3); deck(c, k, col, t);
          plate(c, rectPts(12, 9), METAL_L, 0, k, 1.3); rivets(c, rectPts(12, 9), 0, k, 0.86, 0.8 * k); hazard(c, 0, k, -10, 10, 9.6, col, 1.2);
          for (const [x, ph] of [[-6, 0], [6, 0.75]]) { const down = fmod(t * 0.67 + ph, 1.5) < 0.2; plate(add(c, [x * k, -2 * k]), rectPts(3.4, 3.4), down ? METAL : lt(METAL_L, 0.1), 0, k, 1); if (down) glowDot(add(c, [x * k, -2 * k]), 1 * k, col); }
          const tip = P(c, aim - sw * 1.8, k, 14, 0); bar(c, tip, 1.8 * k, METAL); plate(c, rectPts(2, 2), METAL_D, aim, k, 0.9); if (since > 0.5) this.mine(tip, k * 0.8, t, col, false); },
        mine(p, k, t, col, blink) { ellipse(add(p, [k * 0.8, k * 1.6]), 4 * k, 1.8 * k, [0, 0, 0, 0.3]); plate(p, rectPts(3.6, 3.6), AMMO, 0, k, 0.9); fill(p, rectPts(2, 2), dk(AMMO, 0.3), 0, k); glowDot(add(p, [2.4 * k, -2.4 * k]), (blink ? 1.2 : 0.6) * k, A(col, blink ? 1 : 0.55)); } },
      { key: "F", name: "Rail Launcher", muzzle: 0.3, theme: "A short magnetic rail launcher on a round mount that snaps each mine out along its rails, a stack of canisters loaded behind. Mine: a squat canister with a glowing band.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, since = t - (mm.lastToss ?? -9), fl = decay(since, 0.2); deck(c, k, col, t);
          disc(c, 10 * k, OUTLINE); disc(c, 9.2 * k, METAL); for (let i = 0; i < 3; i++) this.mine(P(c, aim, k, -6, (i - 1) * 4.2), k * 0.55, t, col, false);
          for (const y of [-2.6, 2.6]) bar(P(c, aim, k, -2, y), P(c, aim, k, 15, y), 1.8 * k, METAL_L); for (const x of [3, 9]) bar(P(c, aim, k, x, -4), P(c, aim, k, x, 4), 1.4 * k, dk(col, 0.2));
          strip(P(c, aim, k, 0, 0), P(c, aim, k, 15, 0), 0.6 * k, A(col, 0.3 + 0.7 * fl)); if (since > 0.5) this.mine(P(c, aim, k, 6, 0), k * 0.7, t, col, false); glowDot(c, 1 * k, col); },
        mine(p, k, t, col, blink) { ellipse(add(p, [k * 0.8, k * 1.6]), 4 * k, 1.8 * k, [0, 0, 0, 0.3]); disc(p, 3.6 * k, OUTLINE); disc(p, 3.1 * k, METAL_L); ring(p, 2.2 * k, A(col, blink ? 1 : 0.5), 0.9 * k); disc(p, 1.2 * k, METAL); } },
    ],
    anims: [
      { key: "A", name: "Lob and Blink", desc: "Each mine arcs onto the track, lands with a puff of dust and blinks slowly until an enemy rolls over it: an orange blast.", period: 1, flight: 1, fx: () => ({}),
        persist: mineAgent({ flight: 0.6, fly: (f, to, u, s, col, look, t) => { const p = add(lerp(f, to, u), [0, -Math.sin(Math.PI * u) * s * 0.6]); look.mine(p, G(s) * 0.85, t, col, false); },
          land: (p, v, s) => smokePuff(p, v, s * 0.6, 0.35), boom: (p, v, s, col) => blast(p, v, s, col, 0.45) }) },
      { key: "B", name: "Skip Toss", desc: "Mines are thrown low and skip twice along the ground before settling; they go off in a ring of shrapnel.", period: 1, flight: 1, fx: () => ({}),
        persist: mineAgent({ flight: 0.75, fly: (f, to, u, s, col, look, t) => { const h = u < 0.5 ? Math.sin(Math.PI * u / 0.5) * 0.35 : u < 0.8 ? Math.sin(Math.PI * (u - 0.5) / 0.3) * 0.12 : Math.sin(Math.PI * (u - 0.8) / 0.2) * 0.05;
            look.mine(add(lerp(f, to, Math.min(1, u * 1.05)), [0, -h * s]), G(s) * 0.85, t, col, false); },
          boom: (p, v, s, col) => { blast(p, v, s, col, 0.35); for (let i = 0; i < 10; i++) line(add(p, mul(fa(i * TAU / 10), s * 0.1 + v * s * 0.5)), add(p, mul(fa(i * TAU / 10), s * 0.18 + v * s * 0.6)), [1, 0.85, 0.5, 1 - v], 1.3); } }) },
      { key: "C", name: "Confetti Charge", desc: "Mines arc in and arm with a spinning light; when one goes off it's a blast of high-speed confetti in every direction.", period: 1, flight: 1, fx: () => ({}),
        persist: mineAgent({ flight: 0.6, fly: (f, to, u, s, col, look, t) => look.mine(add(lerp(f, to, u), [0, -Math.sin(Math.PI * u) * s * 0.6]), G(s) * 0.85, t, col, false),
          land: (p, v, s) => ring(p, s * 0.2 * v, [1, 1, 1, 0.5 * (1 - v)], 1),
          boom: (p, v, s, col, n) => { blast(p, v, s, col, 0.3); const cs = [[1, 0.3, 0.35, 1], [0.3, 0.9, 1, 1], [1, 0.85, 0.3, 1], [0.6, 1, 0.4, 1], [1, 0.45, 0.85, 1]];
            for (let i = 0; i < 16; i++) { const d = fa(rnd(n * 13 + i) * TAU), q = add(add(p, mul(d, s * (0.2 + 0.9 * rnd(i + n)) * v)), [0, v * v * s * 0.3]); fill(q, rectPts(1.6, 0.8), A(cs[i % 5], 1 - v), v * 12 + i, 1); } } }) },
    ] },

  // 12. Chemical Plant ----------------------------------------------------------------------------------
  { id: "chem", num: 12, name: "Chemical Plant", cls: "Support", weapon: "Chemical", hits: "both", color: [0.55, 1.00, 0.30, 1],
    desc: "A chemical manufacturing facility that produces and sprays chemicals on nearby enemies. \"Known to cause cancer in the state of California.\" It sprays one enemy at a time; soaked enemies drip and fizz and are skipped until the soak wears off (4 s). (Colour: today's Plasma Burn acid green.)",
    looks: [
      { key: "A", name: "Tank Farm Sprayer", muzzle: 16 / 48, theme: "Two round chemical tanks with sight-glass bands, piped into a central turret with a long spray nozzle; hazard striping on the pipe run.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t);
          for (const q of [[-8, -7], [-8, 7]]) { const p = add(c, mul(q, k)); orb(p, 5 * k, METAL_L); arc(p, 3.4 * k, 0.2, Math.PI - 0.2, A(col, 0.75), 1.4 * k); bar(p, c, 1.5 * k, METAL); }
          hazard(c, 0, k, -12, -4, 0, col, 1.2); plate(c, ngon(8, 1, Math.PI / 8), METAL_L, aim, 6.4 * k, 1.2);
          bar(c, P(c, aim, k, 15, 0), 2.4 * k, METAL); plate(P(c, aim, k, 15, 0), [[1.6, -2.2], [1.6, 2.2], [-1, 1.2], [-1, -1.2]], METAL_L, aim, k, 0.9); orb(c, 3.2 * k, METAL); glowDot(c, 1 * k, col); } },
      { key: "B", name: "Vat Works", muzzle: 15 / 48, theme: "A small works building with two open vats of bubbling green chemical and a swivel spray cannon with a wide flared nozzle.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); plate(c, rectPts(11, 10), METAL_L, 0, k, 1.3); rivets(c, rectPts(11, 10), 0, k, 0.86, 0.8 * k);
          for (const x of [-5.5, 5.5]) { const p = add(c, [x * k, 4.5 * k]); disc(p, 3.6 * k, OUTLINE); disc(p, 3.1 * k, dk(col, 0.45)); for (let i = 0; i < 2; i++) { const b = fmod(t * 1.3 + i * 0.5 + x, 1); disc(add(p, [(rnd(Math.floor(t * 1.3 + i * 0.5 + x)) - 0.5) * 3 * k, 0]), (0.5 + b) * k, A(lt(col, 0.4), 1 - b)); } }
          bar(P(c, aim, k, -2, 0), P(c, aim, k, 12, 0), 3.4 * k, METAL); plate(P(c, aim, k, 13.5, 0), [[1.8, -3.4], [1.8, 3.4], [-1.4, 1.6], [-1.4, -1.6]], METAL_L, aim, k, 0.9);
          orb(P(c, aim, k, -2, 0), 3.4 * k, METAL_L); glowDot(P(c, aim, k, -2, 0), 1 * k, col); } },
      { key: "C", name: "Pressure Sphere", muzzle: 14 / 48, theme: "One big pressurised sphere with two gauges, bolted bands and a stubby twin-hose nozzle on top that turns to spray.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); orb(c, 11 * k, METAL_L); ring(c, 8 * k, METAL, 1.2 * k); for (let i = 0; i < 8; i++) { const q = add(c, mul(fa(i * TAU / 8), 9.6 * k)); disc(q, 0.8 * k, OUTLINE); disc(q, 0.5 * k, METAL_L); }
          for (const [x, y] of [[-6, -5], [6, -5]]) { const g = add(c, [x * k, y * k]); disc(g, 2 * k, OUTLINE); disc(g, 1.6 * k, [0.9, 0.9, 0.85, 1]); line(g, add(g, mul(fa(-2 + Math.sin(t * 2 + x) * 0.4), 1.4 * k)), [0.8, 0.1, 0.1, 1], 0.6 * k); }
          for (const y of [-1.6, 1.6]) bar(P(c, aim, k, 0, y), P(c, aim, k, 13, y), 1.4 * k, METAL); orb(c, 3.4 * k, METAL); glowDot(c, 1.1 * k, col); } },
      { key: "D", name: "Cooling Tower Works", muzzle: 15 / 48, theme: "A squat hyperbolic cooling tower steaming green vapour beside a pump house, with a spray turret on the pump house roof.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); const ct = add(c, [-5 * k, -4 * k]); disc(ct, 8 * k, OUTLINE); disc(ct, 7.3 * k, lt(METAL_L, 0.1)); disc(ct, 5.2 * k, dk(col, 0.6)); ring(ct, 6.3 * k, METAL, 0.9 * k);
          for (let i = 0; i < 3; i++) { const v = fmod(t * 0.5 + i / 3, 1); disc(add(ct, [v * 3 * k, -v * 9 * k]), (2 + v * 3) * k, A(lt(col, 0.5), 0.25 * (1 - v))); }
          const ph = add(c, [6 * k, 5 * k]); plate(ph, rectPts(5, 5), METAL_L, 0, k, 1.1); bar(ph, add(ph, mul(fa(aim), 10 * k)), 2.2 * k, METAL); orb(ph, 2.6 * k, METAL); glowDot(ph, 0.9 * k, col); bar(ct, ph, 1.2 * k, METAL); } },
      { key: "E", name: "Barrel Yard Sprayer", muzzle: 15 / 48, theme: "A ring of hazard-striped chemical drums round a hose-reel turret; a hose runs from the drums to a long lance nozzle.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t);
          for (let i = 0; i < 6; i++) { const q = add(c, mul(fa(i * TAU / 6 + Math.PI / 6), 11 * k)); disc(q, 3.4 * k, OUTLINE); disc(q, 2.9 * k, i % 2 ? [0.9, 0.75, 0.15, 1] : METAL_L); arc(q, 2.2 * k, 0, Math.PI, DARK_STRIPE, 0.9 * k); disc(q, 0.9 * k, dk(col, 0.3)); }
          disc(c, 6 * k, OUTLINE); disc(c, 5.3 * k, METAL); ring(c, 3.6 * k, A(col, 0.6), 1.2 * k); bar(c, P(c, aim, k, 15, 0), 1.6 * k, METAL_L); glowDot(c, 1 * k, col); } },
      { key: "F", name: "Distillery Columns", muzzle: 14 / 48, theme: "Three tall distillation columns with ladder rings, joined by pipes to a central still with a gooseneck spray nozzle.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t);
          for (let i = 0; i < 3; i++) { const q = add(c, mul(fa(-Math.PI / 2 + i * TAU / 3), 10 * k)); bar(c, q, 1.4 * k, METAL); orb(q, 4 * k, METAL_L); ring(q, 2.8 * k, METAL, 0.8 * k); glowDot(q, 0.9 * k, A(col, 0.5 + 0.5 * Math.sin(t * 2 + i))); }
          orb(c, 5 * k, mix(METAL_L, col, 0.15)); bar(c, P(c, aim, k, 6, 0), 2.4 * k, METAL); bar(P(c, aim, k, 6, 0), P(c, aim, k, 13, 0), 1.6 * k, METAL); glowDot(c, 1.1 * k, col); } },
    ],
    anims: [
      { key: "A", name: "Acid Stream", desc: "A green arc of acid droplets streams onto the target; it drips and fizzes while soaked, and the turret moves on to the next dry enemy.", period: 1, flight: 1, fx: () => ({}),
        persist: soakAgent({ flight: 0.5, shot: (f, to, u, s, col, t) => { for (let i = 0; i < 9; i++) { const q = Math.min(u * 1.6, 1) - i * 0.06; if (q < 0) continue; const p = add(lerp(f, to, q), [0, -Math.sin(Math.PI * q) * s * 0.25]); disc(p, 1.4 + 0.3 * (i % 2), A(col, 0.9 - i * 0.06)); } },
          soaked: (p, a, s, col, t, n) => { disc(p, s * 0.14, A(col, 0.3 * Math.min(1, a * 3))); for (let i = 0; i < 2; i++) { const d = fmod(t * 1.5 + i * 0.5 + n * 0.3, 1); disc(add(p, [(i - 0.5) * s * 0.1, d * s * 0.18]), 1.2, A(col, (1 - d) * Math.min(1, a * 3))); }
            for (let i = 0; i < 3; i++) { const b = fmod(t * 2 + i * 0.33 + n, 1); ring(add(p, [(rnd(i + n) - 0.5) * s * 0.18, -b * s * 0.15]), 1 + b * 1.5, A(lt(col, 0.4), (1 - b) * Math.min(1, a * 3)), 0.8); } } }) },
      { key: "B", name: "Mist Puff", desc: "A ball of green mist flies out and bursts into a clinging cloud around the target, which stays wreathed in mist while soaked.", period: 1, flight: 1, fx: () => ({}),
        persist: soakAgent({ flight: 0.45, shot: (f, to, u, s, col) => { const p = lerp(f, to, u); for (let i = 0; i < 3; i++) disc(add(p, mul(fa(i * 2.1 + u * 6), s * 0.04)), s * (0.06 + u * 0.05), A(col, 0.35)); },
          soaked: (p, a, s, col, t, n) => { const al = Math.min(1, a * 3); for (let i = 0; i < 4; i++) disc(add(p, mul(fa(t * 0.8 + i * 1.6 + n), s * 0.1)), s * (0.08 + 0.02 * Math.sin(t * 3 + i)), A(col, 0.18 * al)); } }) },
      { key: "C", name: "Gel Glob", desc: "A fat glob of chemical gel is lobbed onto the target and splats, leaving it coated in dripping goo while soaked.", period: 1, flight: 1, fx: () => ({}),
        persist: soakAgent({ flight: 0.55, shot: (f, to, u, s, col) => { const p = add(lerp(f, to, u), [0, -Math.sin(Math.PI * u) * s * 0.45]); disc(p, s * 0.06 + 1, OUTLINE); disc(p, s * 0.06, col); disc(add(p, [-s * 0.02, -s * 0.02]), s * 0.02, [1, 1, 1, 0.6]); },
          soaked: (p, a, s, col, t, n) => { const al = Math.min(1, a * 3), r = Math.max(4, Math.min(11, s * 0.12)); arc(p, r + 1, Math.PI * 1.1, Math.PI * 1.9, A(col, 0.85 * al), 3);
            for (let i = 0; i < 3; i++) { const d = fmod(t * 0.9 + i * 0.33 + n * 0.2, 1); line(add(p, [(i - 1) * r * 0.6, -r * 0.6]), add(p, [(i - 1) * r * 0.6, -r * 0.6 + d * s * 0.2]), A(col, al * (1 - d)), 1.6); } } }) },
    ] },

  // 13. Boost Tower -------------------------------------------------------------------------------------
  { id: "boost", num: 13, name: "Boost Tower", cls: "Support", weapon: "None", hits: "none", color: [1.00, 0.40, 0.85, 1],
    desc: "Towers in range are amped up and given stat boosts. \"Are you feeling it now Mr. Krabs?\" It attacks nothing; the preview puts three towers around it (a Gun Turret, Mortar and Laser stand-in) and shows them boosted with chevrons. Its real reach is 3 tiles. (Colour: today's Amplifier Pylon magenta; close to the CAS Gunship's pink.)",
    looks: [
      { key: "A", name: "Beacon Mast", muzzle: 0, fixed: true, theme: "A tripod mast on hydraulic legs crowned with a ring of beacon lights that chase round it, a glowing core in the middle.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t);
          for (let i = 0; i < 3; i++) { const d = fa(-Math.PI / 2 + i * TAU / 3); bar(add(c, mul(d, 4 * k)), add(c, mul(d, 14 * k)), 2.8 * k, lt(METAL_D, 0.12)); orb(add(c, mul(d, 14 * k)), 2 * k, METAL_L); }
          orb(c, 7.4 * k, METAL); ring(c, 5.6 * k, METAL_L, 1.2 * k); for (let i = 0; i < 8; i++) { const on = fmod(t * 8 - i, 8) < 2; glowDot(add(c, mul(fa(i * TAU / 8), 5.6 * k)), (on ? 1 : 0.5) * k, A(col, on ? 1 : 0.4)); }
          glowDot(c, (2 + 0.5 * Math.sin(t * 4)) * k, col); } },
      { key: "B", name: "Emitter Array", muzzle: 0, fixed: true, theme: "A low hub with three small emitter dishes on arms, turning slowly and pulsing in turn toward the towers around it.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); plate(c, ngon(6, 1, 0), METAL_L, t * 0.2, 8 * k, 1.2);
          for (let i = 0; i < 3; i++) { const a = t * 0.5 + i * TAU / 3, p = add(c, mul(fa(a), 11 * k)); bar(c, p, 1.8 * k, METAL); arc(p, 3.6 * k, a - 1.2, a + 1.2, OUTLINE, 3 * k); arc(p, 3.6 * k, a - 1.2, a + 1.2, METAL_L, 1.8 * k);
            glowDot(p, (0.8 + 0.8 * (fmod(t - i * 0.4, 1.2) < 0.3)) * k, col); }
          orb(c, 4 * k, METAL); glowDot(c, 1.6 * k, col); } },
      { key: "C", name: "Broadcast Antenna", muzzle: 0, fixed: true, theme: "A square lattice antenna tower with stacked ring lights that light up bottom to top, and a spinning top rotor.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); const sq = [[-9, -9], [9, -9], [9, 9], [-9, 9]].map((q) => add(c, mul(q, k)));
          for (let i = 0; i < 4; i++) bar(sq[i], sq[(i + 1) % 4], 1.6 * k, METAL_L); bar(sq[0], sq[2], 1 * k, METAL); bar(sq[1], sq[3], 1 * k, METAL);
          for (let i = 0; i < 3; i++) ring(c, (7.5 - i * 2.2) * k, A(col, fmod(t * 2, 3) >= i ? 0.95 : 0.25), 1.1 * k);
          const d = fa(t * 4); bar(sub(c, mul(d, 6 * k)), add(c, mul(d, 6 * k)), 1.4 * k, METAL_L); glowDot(c, 1.3 * k, col); } },
      { key: "D", name: "Holo Projector", muzzle: 0, fixed: true, theme: "A flat projector disc throwing a slowly spinning holographic triangle and ring above it, flickering in magenta.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); disc(c, 10 * k, OUTLINE); disc(c, 9.3 * k, METAL); ring(c, 7 * k, METAL_L, 1.2 * k);
          const fl = 0.75 + 0.25 * Math.sin(t * 23) * Math.sin(t * 7); outline(c, ngon(3, 1, t * 0.8), A(col, 0.75 * fl), 1.4 * k, 0, 9 * k); ring(c, (5 + Math.sin(t * 2)) * k, A(col, 0.5 * fl), 1 * k); glowDot(c, 1.6 * k, col); } },
      { key: "E", name: "Capacitor Obelisk", muzzle: 0, fixed: true, theme: "A square obelisk banded with stacked capacitor rings that charge up one by one, crackling at the tip when full.",
        draw(c, aim, s, fx, t, col) { const k = G(s), lvl = fmod(t * 1.5, 5); deck(c, k, col, t); plate(c, rectPts(8, 8), METAL_L, Math.PI / 4, k, 1.3);
          for (let i = 0; i < 4; i++) outline(c, rectPts(7 - i * 1.6, 7 - i * 1.6), A(col, lvl > i ? 0.95 : 0.2), 1.2 * k, Math.PI / 4, k);
          if (lvl > 4) for (let i = 0; i < 3; i++) { const a = rnd(Math.floor(t * 20) + i) * TAU; line(c, add(c, mul(fa(a), 4 * k)), A(lt(col, 0.4), 0.9), 0.8 * k); } glowDot(c, (1 + 0.4 * lvl) * k, col); } },
      { key: "F", name: "Signal Drum", muzzle: 0, fixed: true, theme: "A big round drum emitter, its membrane rings rippling outward on each beat, braced by three struts.",
        draw(c, aim, s, fx, t, col) { const k = G(s), beat = fmod(t * 1.2, 1); deck(c, k, col, t); for (let i = 0; i < 3; i++) { const d = fa(Math.PI / 2 + i * TAU / 3); bar(add(c, mul(d, 9 * k)), add(c, mul(d, 14 * k)), 2 * k, METAL); }
          disc(c, 11 * k, OUTLINE); disc(c, 10.3 * k, METAL_L); disc(c, 8.6 * k, METAL_D); for (let i = 0; i < 3; i++) { const r = fmod(beat + i / 3, 1); ring(c, (2 + 6.4 * r) * k, A(col, 0.8 * (1 - r)), 1.1 * k); }
          glowDot(c, (1.2 + 0.8 * (1 - beat)) * k, col); } },
    ],
    anims: [
      { key: "A", name: "Pulse Rings", desc: "Magenta rings ripple out from the tower; as each ring reaches a tower, its chevrons flash and it glows for a moment.", period: 1, flight: 1, fx: () => ({}),
        persist: (m, t, info, s, col) => { const R = s * 1.6, u = fmod(t, 1.5) / 1.5;
          ring(info.c, R, A(col, 0.18), 1); for (const q of [u, fmod(u + 0.5, 1)]) ring(info.c, R * q, A(col, 0.6 * (1 - q)), 2);
          for (const mt of matesOf(info)) { const d = distTo(mt.p, info.c) / R, hit = Math.max(0, 1 - Math.abs(u - d) * 6, 1 - Math.abs(fmod(u + 0.5, 1) - d) * 6); mateTower(mt.p, G(s), mt.col, t, 0.45 + 0.55 * hit, col); if (hit > 0) glowDot(mt.p, s * 0.1 * hit, A(col, 0.6 * hit)); } } },
      { key: "B", name: "Link Beams", desc: "Thin magenta beams link the tower to each tower it boosts, with bright packets flowing along them; the chevrons glow steadily.", period: 1, flight: 1, fx: () => ({}),
        persist: (m, t, info, s, col) => { for (const mt of matesOf(info)) { mateTower(mt.p, G(s), mt.col, t, 1, col); line(info.c, mt.p, A(col, 0.3), 3); line(info.c, mt.p, A(col, 0.8), 1);
          for (let i = 0; i < 2; i++) glowDot(lerp(info.c, mt.p, fmod(t * 0.8 + i * 0.5, 1)), s * 0.03, col); } } },
      { key: "C", name: "Aura Field", desc: "A steady translucent aura surrounds the tower with a slowly turning edge; boosted towers inside get a glowing outline and rising sparkles.", period: 1, flight: 1, fx: () => ({}),
        persist: (m, t, info, s, col) => { const R = s * 1.6; disc(info.c, R, A(col, 0.07)); arcSegments(info.c, R, 12, 0.18, t * 0.3, A(col, 0.55), 1.6);
          for (const mt of matesOf(info)) { ring(mt.p, s * 0.32, A(col, 0.5 + 0.2 * Math.sin(t * 3)), 1.5); mateTower(mt.p, G(s), mt.col, t, 0.9, col);
            for (let i = 0; i < 3; i++) { const q = fmod(t * 0.7 + i / 3 + mt.p[0], 1); glowDot(add(mt.p, [(rnd(i + mt.p[1]) - 0.5) * s * 0.4, -q * s * 0.4]), s * 0.015, A(col, 1 - q)); } } } },
      { key: "D", name: "Chevron Rain", desc: "Every couple of seconds a glowing chevron drops onto each boosted tower from above and lands with a flash, stacking with the others.", period: 1, flight: 1, fx: () => ({}),
        persist: (m, t, info, s, col) => { matesOf(info).forEach((mt, i) => { const u = fmod(t * 0.5 + i * 0.25, 1); mateTower(mt.p, G(s), mt.col, t, u > 0.4 ? 1 : 0.5, col);
          if (u < 0.4) { const q = add(mt.p, [0, -(16 * G(s) * 0.75) - (1 - u / 0.4) * s * 0.6]); polyline([add(q, [-3 * G(s), 2 * G(s)]), q, add(q, [3 * G(s), 2 * G(s)])], A(col, 0.9), 2); } else if (u < 0.5) glowDot(mt.p, s * 0.12 * (1 - (u - 0.4) * 10), col); }); } },
      { key: "E", name: "Power Cables", desc: "Glowing cables run along the ground from the tower to each boosted tower, with pulses of power travelling down them; the decks light up as each pulse arrives.", period: 1, flight: 1, fx: () => ({}),
        persist: (m, t, info, s, col) => { matesOf(info).forEach((mt, i) => { const mid = add(lerp(info.c, mt.p, 0.5), [0, s * 0.15]), pts = []; for (let j = 0; j <= 10; j++) { const u = j / 10; pts.push(lerp(lerp(info.c, mid, u), lerp(mid, mt.p, u), u)); }
          polyline(pts, OUTLINE, 3.2); polyline(pts, METAL, 2); const q = fmod(t * 0.9 + i * 0.3, 1); glowDot(pts[Math.floor(q * 10)], s * 0.035, col); mateTower(mt.p, G(s), mt.col, t, q > 0.85 ? 1 : 0.55, col); if (q > 0.85) ring(mt.p, s * 0.3, A(col, (q - 0.85) * 6), 1.5); }); } },
      { key: "F", name: "Overcharge Sparks", desc: "Magenta arcs jump from the tower to each boosted tower in turn; the struck tower crackles and its barrel glows hot for a moment.", period: 1, flight: 1, fx: () => ({}),
        persist: (m, t, info, s, col) => { const mates = matesOf(info), cur = Math.floor(t * 1.5) % mates.length, u = fmod(t * 1.5, 1);
          mates.forEach((mt, i) => { const on = i === cur; mateTower(mt.p, G(s), mt.col, t, on ? 1 : 0.5, col);
            if (on && u < 0.35) { const pts = [info.c]; for (let j = 1; j < 6; j++) pts.push(add(lerp(info.c, mt.p, j / 6), mul(orth(norm(sub(mt.p, info.c))), (rnd(Math.floor(t * 30) + j) - 0.5) * s * 0.25))); pts.push(mt.p);
              polyline(pts, A(col, 0.3), 4); polyline(pts, col, 1.6); polyline(pts, [1, 1, 1, 0.8], 0.6); }
            if (on) glowDot(add(mt.p, [s * 0.15, -s * 0.08]), s * 0.05 * (1 - u), [1, 0.6, 0.3, 1]); }); } },
    ] },

  // 14. Radar Tower -------------------------------------------------------------------------------------
  { id: "radar", num: 14, name: "Radar Tower", cls: "Utility", weapon: "Energy", hits: "both", color: [0.35, 1.00, 0.85, 1],
    desc: "Detects and alerts nearby towers of stealthy or otherwise hidden enemies. \"I've lost the bleeps, I've lost the sweeps, and I've lost the creeps.\" In the preview every other enemy is cloaked (a faint shimmer) until a ping reveals it for 1 s, marked with brackets. (Colour: today's Sensor Array teal.)",
    looks: [
      { key: "A", name: "Dish Mast", muzzle: 0, fixed: true, theme: "A braced mast carrying a big parabolic dish that turns steadily, a feed horn at its focus.",
        dishAngle: (t) => t * TAU / 3,
        draw(c, aim, s, fx, t, col) { const k = G(s), a = this.dishAngle(t); deck(c, k, col, t); for (let i = 0; i < 4; i++) { const d = fa(Math.PI / 4 + i * Math.PI / 2); bar(add(c, mul(d, 3 * k)), add(c, mul(d, 12 * k)), 2 * k, lt(METAL_D, 0.12)); }
          orb(c, 4 * k, METAL); arc(c, 10 * k, a - 1.1, a + 1.1, OUTLINE, 4.6 * k); arc(c, 10 * k, a - 1.1, a + 1.1, METAL_L, 3 * k); arc(c, 9.6 * k, a - 0.9, a - 0.1, lt(METAL_L, 0.4), 0.9 * k);
          line(c, add(c, mul(fa(a), 6 * k)), METAL_L, 1 * k); glowDot(add(c, mul(fa(a), 6 * k)), 1 * k, col); } },
      { key: "B", name: "Phased Array Block", muzzle: 0, fixed: true, theme: "A square block faced with flat phased-array panels whose tiles light up in sweeping sequence, a small whip antenna on top.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); plate(c, rectPts(11, 11), METAL_L, 0, k, 1.3);
          for (let i = 0; i < 4; i++) for (let j = 0; j < 4; j++) { const on = fmod(t * 3 - (i + j) * 0.25, 2) < 0.4; rect(c[0] + (-8 + i * 4.2) * k, c[1] + (-8 + j * 4.2) * k, 3.4 * k, 3.4 * k, on ? A(col, 0.85) : [0.12, 0.16, 0.16, 1]); }
          bar(c, add(c, [3 * k, -13 * k]), 0.9 * k, METAL_L); glowDot(add(c, [3 * k, -13 * k]), 0.9 * k, col); } },
      { key: "C", name: "Twin Dish Rotor", muzzle: 0, fixed: true, theme: "A rotor arm turning on a hub with a small dish at each end facing outward, sweeping twice per turn.",
        dishAngle: (t) => t * TAU / 3,
        draw(c, aim, s, fx, t, col) { const k = G(s), a = this.dishAngle(t); deck(c, k, col, t); plate(c, ngon(8, 1, Math.PI / 8), METAL, 0, 7 * k, 1.2);
          for (const sg of [-1, 1]) { const d = fa(a + (sg > 0 ? 0 : Math.PI)), p = add(c, mul(d, 10 * k)); bar(c, p, 2 * k, METAL_L); const pa = Math.atan2(d[1], d[0]);
            arc(p, 3.6 * k, pa - 1.2, pa + 1.2, OUTLINE, 3 * k); arc(p, 3.6 * k, pa - 1.2, pa + 1.2, METAL_L, 1.8 * k); glowDot(p, 0.8 * k, col); }
          orb(c, 3 * k, METAL_L); glowDot(c, 1 * k, col); } },
    ],
    anims: [
      { key: "A", name: "Ping Ring", desc: "Every 3 s a teal ring expands across the radar's range; each cloaked enemy it passes is revealed with brackets for a second.", period: 1, flight: 1, fx: () => ({}),
        persist: radarAgent({ draw: (m, t, info, s, col) => { const u = fmod(t, 3) / 1.2; if (u < 1) { ring(info.c, s * 3.3 * u, A(col, 0.7 * (1 - u)), 2); ring(info.c, s * 3.3 * u - 4, A(col, 0.25 * (1 - u)), 4); } },
          hits: (m, t, info, s, e) => { const u = fmod(t, 3) / 1.2; return u < 1 && Math.abs(distTo(e.p, info.c) - s * 3.3 * u) < s * 0.15; } }) },
      { key: "B", name: "Sweep Beam", desc: "A sweep wedge turns round the tower once every 3 s, following the dish (round 2), like a radar screen; cloaked enemies light up with brackets as it passes over them.", period: 1, flight: 1, fx: () => ({}),
        persist: radarAgent({ draw: (m, t, info, s, col) => { const a = sweepAngle(info, t), R = s * 3.3; for (let i = 0; i < 6; i++) { const a0 = a - i * 0.08; poly([info.c, add(info.c, mul(fa(a0 - 0.08), R)), add(info.c, mul(fa(a0), R))], A(col, 0.16 * (1 - i / 6))); } line(info.c, add(info.c, mul(fa(a), R)), A(col, 0.7), 1.3); },
          hits: (m, t, info, s, e) => { const a = fmod(sweepAngle(info, t), TAU), b = fmod(Math.atan2(e.p[1] - info.c[1], e.p[0] - info.c[0]), TAU), d = fmod(a - b, TAU); return d < 0.15; } }) },
      { key: "C", name: "Pulse Burst", desc: "Every 3 s the whole range flashes in a grid pattern at once; revealed enemies get brackets and a link line back to the radar, alerting the towers.", period: 1, flight: 1, fx: () => ({}),
        persist: radarAgent({ draw: (m, t, info, s, col) => { const u = fmod(t, 3); if (u < 0.35) { const a = 1 - u / 0.35, R = s * 3.3; disc(info.c, R, A(col, 0.08 * a)); for (let i = -3; i <= 3; i++) { line(add(info.c, [i * s * 0.5, -R]), add(info.c, [i * s * 0.5, R]), A(col, 0.18 * a), 1); line(add(info.c, [-R, i * s * 0.5]), add(info.c, [R, i * s * 0.5]), A(col, 0.18 * a), 1); } }
            for (const e of info.all) if (cloaked(e) && (m.seen[e.i] || 0) > t) line(info.c, e.p, A(col, 0.35 * Math.min(1, (m.seen[e.i] - t) * 2)), 1); },
          hits: (m, t, info, s, e) => fmod(t, 3) < 0.05 }) },
    ] },

  // 15. Cryo Tower --------------------------------------------------------------------------------------
  { id: "cryo", num: 15, name: "Cryo Tower", cls: "Support", weapon: "Field", hits: "both", color: [0.55, 0.85, 1.00, 1],
    desc: "Produces a wave of sub-zero gas that stunts the mobility of enemies within range. \"...a snowball fight in the middle of a heatwave.\" A cold wave every 2 s; every enemy it reaches is chilled (frosted) and slowed (the preview doesn't slow them). No damage at stock. (Colour: today's Cryo Emitter ice blue.)",
    looks: [
      { key: "A", name: "Vent Tank", muzzle: 0, fixed: true, theme: "A squat frosted tank with four armoured vents round it that breathe white gas as each wave goes out; frost rings its rim.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, puff = decay(t - (mm.wave ?? -9), 0.6); deck(c, k, col, t);
          for (let i = 0; i < 4; i++) { const d = fa(Math.PI / 4 + i * Math.PI / 2), p = add(c, mul(d, 11 * k)); plate(p, rectPts(2.6, 3.4), METAL_L, Math.PI / 4 + i * Math.PI / 2, k, 1); for (let j = 0; j < 3; j++) line(add(p, mul(rot(d, Math.PI / 2), (j - 1) * 1.6 * k)), add(add(p, mul(rot(d, Math.PI / 2), (j - 1) * 1.6 * k)), mul(d, 1.5 * k)), A(FROST, 0.6), 0.8 * k); if (puff > 0) smokePuff(add(p, mul(d, 3 * k)), 1 - puff, s * 0.6, 0.55); }
          orb(c, 8 * k, mix(METAL_L, FROST, 0.25)); ring(c, 8 * k, A(FROST, 0.55), 1.2 * k); ring(c, 4.5 * k, METAL, 1 * k); glowDot(c, (1.4 + 1.2 * puff) * k, col); } },
      { key: "B", name: "Compressor Block", muzzle: 0, fixed: true, theme: "A square compressor housing with a big fan grille spinning on top, coolant pipes round its sides and frost built up on the corners.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, puff = decay(t - (mm.wave ?? -9), 0.6); deck(c, k, col, t); plate(c, rectPts(11.5, 11.5), METAL_L, 0, k, 1.3);
          for (const q of [[-1, -1], [1, -1], [1, 1], [-1, 1]]) disc(add(c, mul(q, 10 * k)), 2.4 * k, A(FROST, 0.7));
          disc(c, 8.4 * k, OUTLINE); disc(c, 7.8 * k, METAL_D); for (let i = 0; i < 5; i++) { const a = t * (6 + 10 * puff) + i * TAU / 5; fill(c, [[1.4, 0], [7, 1.8], [7, -1.4]], METAL_L, a, k); }
          ring(c, 7.8 * k, METAL, 1.2 * k); orb(c, 1.8 * k, METAL); glowDot(c, (1 + puff) * k, col); bar(add(c, [-11.5 * k, -6 * k]), add(c, [-11.5 * k, 6 * k]), 1.4 * k, mix(METAL_L, FROST, 0.4)); } },
      { key: "C", name: "Cryo Spire", muzzle: 0, fixed: true, theme: "A tall ice-blue frost crystal standing in an armoured collar, coolant lines feeding it, a cold glow pulsing inside with each wave.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, puff = decay(t - (mm.wave ?? -9), 0.8); deck(c, k, col, t);
          for (let i = 0; i < 3; i++) { const d = fa(Math.PI / 2 + i * TAU / 3); bar(add(c, mul(d, 7 * k)), add(c, mul(d, 14 * k)), 1.4 * k, mix(METAL_L, FROST, 0.4)); }
          disc(c, 9 * k, OUTLINE); disc(c, 8.3 * k, METAL); ring(c, 7 * k, METAL_L, 1.2 * k);
          solid(c, [[0, -7], [3.4, -2], [2.6, 5], [0, 7], [-2.6, 5], [-3.4, -2]], A(mix(FROST, col, 0.3), 0.85), 0, k, 1); line(add(c, [0, -6 * k]), add(c, [0, 6 * k]), [1, 1, 1, 0.6], 0.8 * k);
          glowDot(c, (1.2 + 2 * puff) * k, FROST); } },
    ],
    anims: [
      { key: "A", name: "Gas Wave", desc: "A ring of white freezing fog rolls out to the edge of range every 2 s; enemies it touches frost over.", period: 1, flight: 1, fx: () => ({}),
        persist: coldAgent({ travel: 1.1, draw: (c, u, R, s, col, t, raw) => { if (raw > 1.2) return; const r = R * u, a = 1 - Math.min(1, raw);
          for (let i = 0; i < 16; i++) disc(add(c, mul(fa(i * TAU / 16 + t * 0.3), r)), s * (0.1 + 0.05 * Math.sin(i * 3 + t)), A(FROST, 0.35 * a)); ring(c, r, A(FROST, 0.4 * a), 2); } }) },
      { key: "B", name: "Frost Burst", desc: "A fast, sharp cold flash rings out with ice shards flying outward; chilled enemies sparkle with ice crystals.", period: 1, flight: 1, fx: () => ({}),
        persist: coldAgent({ travel: 0.45, draw: (c, u, R, s, col, t, raw) => { if (raw > 1.3) return; const r = R * u, a = 1 - Math.min(1, raw / 1.3);
          ring(c, r, A([1, 1, 1, 1], 0.7 * a), 2.5); ring(c, r * 0.92, A(col, 0.5 * a), 1.5);
          for (let i = 0; i < 12; i++) { const d = fa(i * TAU / 12 + 0.2), p = add(c, mul(d, r)); line(p, add(p, mul(d, s * 0.12)), A(FROST, a), 1.4); } } }) },
      { key: "C", name: "Creeping Mist", desc: "Cold mist pours out and creeps slowly to the edge of range, lingering in drifting puffs; each wave brightens it.", period: 1, flight: 1, fx: () => ({}),
        persist: coldAgent({ travel: 1.8, draw: (c, u, R, s, col, t, raw) => { const a = 0.55 + 0.45 * (1 - Math.min(1, raw / 2));
          for (let i = 0; i < 22; i++) { const ang = rnd(i) * TAU + t * 0.1 * (i % 2 ? 1 : -1), rr = R * Math.min(u, rnd(i + 9)), p = add(c, mul(fa(ang), rr));
            disc(p, s * (0.12 + 0.04 * Math.sin(t * 1.5 + i)), A(FROST, 0.16 * a)); } } }) },
      { key: "D", name: "Snow Squall", desc: "Snowflakes spiral out from the tower in a swirling squall that fills the range; enemies caught in it are dusted white.", period: 1, flight: 1, fx: () => ({}),
        persist: coldAgent({ travel: 1.3, draw: (c, u, R, s, col, t, raw) => { const a = raw > 1.5 ? 0.3 : 1 - 0.7 * Math.min(1, raw / 1.5);
          for (let i = 0; i < 26; i++) { const rr = R * fmod(rnd(i) + t * 0.35, 1), ang = rnd(i + 5) * TAU + rr / R * 4 + t * 0.6, p = add(c, mul(fa(ang), rr));
            const f = 1.2 + rnd(i + 2) * 1.6; for (let j = 0; j < 3; j++) { const d = fa(j * Math.PI / 3 + t); line(sub(p, mul(d, f)), add(p, mul(d, f)), A([1, 1, 1, 1], 0.7 * a), 0.8); } } } }) },
      { key: "E", name: "Ice Spike Ring", desc: "A ring of ice spikes bursts up out of the ground and races outward, then melts away behind the front.", period: 1, flight: 1, fx: () => ({}),
        persist: coldAgent({ travel: 0.9, draw: (c, u, R, s, col, t, raw) => { if (raw > 1.6) return;
          for (let j = 0; j < 3; j++) { const back = u - j * 0.12; if (back <= 0) continue; const r = R * back, a = Math.max(0, 1 - (raw - back) * 1.4) * (1 - j * 0.3);
            for (let i = 0; i < 18; i++) { const d = fa(i * TAU / 18 + j * 0.17), p = add(c, mul(d, r)); fill(p, [[0, -s * 0.12], [s * 0.035, 0], [-s * 0.035, 0]], A(mix(FROST, [1, 1, 1, 1], 0.4), a), 0, 1); } } } }) },
      { key: "F", name: "Fog Jets", desc: "Four jets of dense freezing fog blast out of the vents in a cross and spread sideways until they fill the range.", period: 1, flight: 1, fx: () => ({}),
        persist: coldAgent({ travel: 1.2, draw: (c, u, R, s, col, t, raw) => { if (raw > 1.8) return; const a = 1 - Math.min(1, raw / 1.8);
          for (let j = 0; j < 4; j++) { const d = fa(Math.PI / 4 + j * Math.PI / 2); for (let i = 0; i < 7; i++) { const q = (i + 1) / 7; if (q > u) break; const spread = q * q * R * 0.5; for (const sg of [-1, 0, 1]) disc(add(add(c, mul(d, R * q)), mul(orth(d), sg * spread)), s * (0.08 + q * 0.12), A(FROST, 0.18 * a)); } } } }) },
    ] },
];
const DEFAULTS = { mines: { look: "F", anim: "C" }, chem: { look: "F", anim: "A" }, boost: { look: "F", anim: "F" }, radar: { look: "A", anim: "B" }, cryo: { look: "B", anim: "C" } };
