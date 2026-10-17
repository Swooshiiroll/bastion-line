// ---- Tower art page 2: towers 6-10, in the style of today's in-game towers (owner, 2026-10-16) -----------
// Shared style helpers (deck, hazard, muzzleEnd, shell, missile...) come from game_style.js.
const PAGE = { title: "Tower art page 2 (towers 6-10)", store: "bl-tower-art-2-game-v3" };

// ---- Page 2 effects ---------------------------------------------------------------------------------------
const rnd = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
// A jagged lightning bolt from a to b that re-rolls its kinks every `seed` change.
function bolt(a, b, col, w, seed, jit) { const n = 7, d = sub(b, a), o = orth(norm(d)), L = Math.hypot(d[0], d[1]), pts = [a];
  for (let i = 1; i < n; i++) pts.push(add(lerp(a, b, i / n), mul(o, (rnd(seed + i * 7.3) - 0.5) * L * (jit || 0.28))));
  pts.push(b); polyline(pts, A(col, 0.28 * (col[3] ?? 1)), w * 3); polyline(pts, col, w); polyline(pts, [1, 1, 1, 0.85 * (col[3] ?? 1)], Math.max(0.6, w * 0.4)); return pts; }
// The enemies a chain jumps to after its first target: nearest unvisited within reach, `n` times.
function chain(first, ens, n, reach) { const out = [first], used = new Set();
  for (const e of ens) if (Math.hypot(e.p[0] - first[0], e.p[1] - first[1]) < 2) used.add(e.i);
  let cur = first;
  for (let j = 0; j < n; j++) { let best = null, bd = reach;
    for (const e of ens) { if (used.has(e.i)) continue; const d = Math.hypot(e.p[0] - cur[0], e.p[1] - cur[1]); if (d < bd) { bd = d; best = e; } }
    if (!best) break; used.add(best.i); out.push(best.p); cur = best.p; }
  return out; }
// Enemies on a railgun's line past the muzzle, nearest first.
function onLine(from, to, ens, s) { const d = norm(sub(to, from)), o = orth(d);
  return ens.map((e) => { const w = sub(e.p, from); return { p: e.p, along: dot(w, d), off: Math.abs(dot(w, o)) }; }).filter((h) => h.along > 0 && h.off < s * 0.2).sort((a, b) => a.along - b.along); }
const farPoint = (from, to, W) => add(from, mul(norm(sub(to, from)), W * 1.6));
const COPPER = [0.78, 0.5, 0.28, 1], CERAMIC = [0.86, 0.85, 0.8, 1];

// ---- Drones and aircraft (drawn by the looks, flown by the animations) ------------------------------------
function rotor(p, r, t, k) { disc(p, r, [0.8, 0.85, 0.95, 0.12]); ring(p, r, [0.8, 0.86, 0.95, 0.35], 0.8); for (let q = 0; q < 2; q++) line(p, add(p, mul(fa(t * 40 + q * Math.PI), r * 0.95)), [0.85, 0.9, 1, 0.55], 1.1 * k); }
function planeShadow(p, heading, k, span, len) { const q = add(p, [k * 10, k * 16]); fill(q, rectPts(len * 0.5, 2.6), [0, 0, 0, 0.14], heading, k); fill(q, rectPts(2.4, span * 0.5), [0, 0, 0, 0.14], heading, k); }
function gunDoor(p, heading, k, fx, col, x) { if (fx.flash > 0) glowDot(P(p, heading, k, x || 1, 3.2), (0.8 + 2.4 * fx.flash) * k, col); } // the guns are inside: only the muzzle flash shows at the side door

// ---- Drones that stay out: once launched the drone never goes home; it hunts, and idles when the lane is clear ----
const turnTo = (a, b, m) => { const d = fmod(b - a + Math.PI, TAU) - Math.PI; return a + Math.max(-m, Math.min(m, d)); };
const distTo = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
function droneAgent(cfg) { return (m, t, info, s, col) => { const k = G(s), dt = Math.min(0.1, Math.max(0, t - (m.t ?? t))); m.t = t;
  if (!m.p) { m.p = info.c.slice(); m.dir = -Math.PI / 2; m.shots = []; m.last = -9; m.alt = 0; }
  let foe = null, bd = 1e9; for (const e of info.ens) { const d = distTo(e.p, m.p); if (d < bd) { bd = d; foe = e; } }
  if (foe) m.out = true; if (!m.out) return;
  if (foe) m.anchor = null; else if (!m.anchor) m.anchor = m.p.slice();
  const w = foe ? cfg.engage(m, t, foe.p, info, s) : cfg.idle(m, t, info, s);
  const d = sub(w.p, m.p), L = Math.hypot(d[0], d[1]), sp = (w.speed || 2.6) * s * dt;
  m.p = L <= sp ? w.p.slice() : add(m.p, mul(d, sp / L));
  const pad = s * 0.22; m.p = [Math.max(pad, Math.min(info.W - pad, m.p[0])), Math.max(pad, Math.min(info.H - pad, m.p[1]))]; // stays in view
  m.dir = turnTo(m.dir, w.face ?? (L > 2 ? Math.atan2(d[1], d[0]) : m.dir), 9 * dt); m.alt += ((w.alt || 0) - m.alt) * Math.min(1, dt * 3);
  if (foe && w.fire && t - m.last >= (w.rate || 0.33)) { m.last = t; m.shots.push({ t0: t, from: m.p.slice(), id: foe.i, to0: foe.p.slice() }); }
  m.shots = m.shots.filter((q) => t - q.t0 < 0.4);
  for (const q of m.shots) { const e = info.ens.find((x) => x.i === q.id), to = e ? e.p : q.to0, u = (t - q.t0) / 0.15;
    if (u < 1) tracer(q.from, to, u, col, 1.3, 0.35); else spark(to, (u - 1) * 0.6, s * 0.6, col); }
  if (w.draw) w.draw(m, t, s, col);
  const z = 1 + 0.35 * m.alt; ellipse(add(m.p, [k * (4 + 10 * m.alt), k * (7 + 14 * m.alt)]), 4 * k * z, 1.8 * k * z, [0, 0, 0, 0.2 - 0.08 * m.alt]);
  info.look.drone(m.p, m.dir, k * z, t, col); }; }
const faceTo = (m, fp) => Math.atan2(fp[1] - m.p[1], fp[0] - m.p[0]);
const CAS_Z = 2.0; // the gunship flies high: drawn this much bigger than ground scale (owner: "way larger")

const TOWERS = [
  // 6. Artillery Cannon ---------------------------------------------------------------------------------
  { id: "artillery", num: 6, name: "Artillery Cannon", cls: "Assault", weapon: "Explosive", hits: "ground", color: [0.50, 0.60, 1.00, 1], spot: { x: 0.74, y: 0.8 },
    desc: "A large-bore cannon that fires high-explosive shells very long distances. \"It's not DiGiorno...\" You aim it at a spot on the track (the marker); it shells that spot on a loop and never tracks enemies. (Colour: a new blue; no in-game counterpart.)",
    looks: [
      { key: "A", name: "Field Gun", muzzle: 27 / 48, theme: "A long-barrelled field gun on a bolted turntable behind a gun shield, two split trails braced out behind; the barrel ends in a muzzle brake.",
        draw(c, aim, s, fx, t, col) { const k = G(s), r = fx.recoil * 4; deck(c, k, col, t);
          for (const y of [-1, 1]) { bar(P(c, aim, k, -2, y * 4), P(c, aim, k, -15, y * 10), 2.6 * k, lt(METAL_D, 0.12)); plate(P(c, aim, k, -15, y * 10), rectPts(2.2, 1.6), METAL_L, aim, k, 0.9); }
          disc(c, 9 * k, OUTLINE); disc(c, 8.2 * k, lt(METAL_D, 0.1)); for (let i = 0; i < 6; i++) { const q = add(c, mul(fa(i * TAU / 6), 7 * k)); disc(q, 0.9 * k, OUTLINE); disc(q, 0.6 * k, METAL_L); }
          bar(P(c, aim, k, -r, 0), P(c, aim, k, 25 - r, 0), 3.6 * k, METAL_L); bar(P(c, aim, k, -r, 0), P(c, aim, k, 10 - r, 0), 5.2 * k, METAL);
          plate(P(c, aim, k, 25.5 - r, 0), rectPts(1.8, 3), METAL, aim, k, 1); muzzleEnd(P(c, aim, k, 27 - r, 0), k, 3, col, fx.flash);
          plate(P(c, aim, k, 6, 0), [[1.4, -7], [1.4, 7], [-1.2, 5.5], [-1.2, -5.5]], METAL_L, aim, k, 1.1);
          orb(P(c, aim, k, -3, 0), 3 * k, METAL); glowDot(P(c, aim, k, -2.4, 0), 1 * k, col); } },
      { key: "B", name: "Casemate Howitzer", muzzle: 22 / 48, theme: "A boxy armoured casemate with hazard-striped flanks; a short, fat howitzer barrel through a mantlet, with recoil cylinders riding above it.",
        draw(c, aim, s, fx, t, col) { const k = G(s), r = fx.recoil * 3; deck(c, k, col, t);
          bar(P(c, aim, k, 6 - r, 0), P(c, aim, k, 22 - r, 0), 5.2 * k, METAL_L);
          for (const y of [-3.6, 3.6]) bar(P(c, aim, k, 8 - r * 0.5, y), P(c, aim, k, 16 - r * 0.5, y), 1.8 * k, METAL);
          muzzleEnd(P(c, aim, k, 22 - r, 0), k, 4.4, col, fx.flash);
          plate(c, rectPts(10, 9), METAL_L, aim, k, 1.3); fill(c, rectPts(7.6, 6.6), METAL, aim, k); rivets(c, rectPts(10, 9), aim, k, 0.86, 0.8 * k);
          hazard(c, aim, k, -9, -2, -9.6, col); hazard(c, aim, k, -9, -2, 9.6, col); for (const x of [-4, 2]) line(P(c, aim, k, x, -6), P(c, aim, k, x, 6), [0, 0, 0, 0.35], 1);
          plate(P(c, aim, k, 9.5, 0), rectPts(1.4, 4.6), METAL_D, aim, k, 1); glowDot(P(c, aim, k, -6.5, 0), 1.2 * k, col); } },
      { key: "C", name: "Long Tom", muzzle: 30 / 48, theme: "An extra-long, slim barrel with support collars on a round mount braced by four outrigger legs, a heavy counterweight block at the back.",
        draw(c, aim, s, fx, t, col) { const k = G(s), r = fx.recoil * 4; deck(c, k, col, t);
          for (let i = 0; i < 4; i++) { const f = add(c, mul(fa(aim + Math.PI / 4 + i * Math.PI / 2), 16 * k)); bar(c, f, 2.4 * k, lt(METAL_D, 0.12)); plate(f, rectPts(1.8, 1.8), METAL_L, aim, k, 0.9); }
          plate(P(c, aim, k, -9, 0), rectPts(3.5, 5.5), METAL, aim, k, 1.1); for (const x of [-10, -8]) line(P(c, aim, k, x, -4), P(c, aim, k, x, 4), [0, 0, 0, 0.4], 1);
          disc(c, 7 * k, OUTLINE); disc(c, 6.3 * k, METAL_D);
          bar(P(c, aim, k, -2 - r, 0), P(c, aim, k, 30 - r, 0), 2.6 * k, METAL_L); for (const x of [10, 19]) bar(P(c, aim, k, x - r, -2.6), P(c, aim, k, x - r, 2.6), 1.3 * k, lt(METAL_D, 0.15));
          muzzleEnd(P(c, aim, k, 30 - r, 0), k, 2.6, col, fx.flash); orb(c, 3.4 * k, METAL_L); glowDot(c, 1.1 * k, col); } },
      { key: "D", name: "Self-Propelled Gun", muzzle: 26 / 48, theme: "A tracked gun: two armoured treads fixed on the deck and a big angular turret on top that turns, its long barrel with a fume-extractor bulge.",
        draw(c, aim, s, fx, t, col) { const k = G(s), r = fx.recoil * 3.5; deck(c, k, col, t);
          for (const x of [-11, 11]) { plate(add(c, [x * k, 0]), rectPts(3, 14), lt(METAL_D, 0.06), 0, k, 1.1); for (let i = 0; i < 7; i++) line(add(c, [(x - 2.6) * k, (-12 + i * 4) * k]), add(c, [(x + 2.6) * k, (-12 + i * 4) * k]), [0, 0, 0, 0.45], 1); }
          bar(P(c, aim, k, 4 - r, 0), P(c, aim, k, 26 - r, 0), 3.2 * k, METAL_L); bar(P(c, aim, k, 14 - r, 0), P(c, aim, k, 18 - r, 0), 4.8 * k, METAL);
          muzzleEnd(P(c, aim, k, 26 - r, 0), k, 3.2, col, fx.flash);
          const hull = [[7, -6], [7, 6], [-6, 8], [-9, 0], [-6, -8]]; plate(c, hull, METAL_L, aim, k, 1.2); rivets(c, hull, aim, k, 0.72, 0.7 * k);
          orb(P(c, aim, k, -3, -3.5), 2 * k, METAL); glowDot(P(c, aim, k, -2.4, -3.5), 0.9 * k, col); hazard(c, aim, k, -5, 4, 7.2, col, 1.2); } },
      { key: "E", name: "Twin-Barrel Battery", muzzle: 24 / 48, muzzles: [[24 / 48, -4 / 48], [24 / 48, 4 / 48]], theme: "Two heavy barrels side by side on a wide armoured mount with muzzle brakes, firing one after the other; a hazard-striped counterweight behind.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t);
          plate(P(c, aim, k, -9, 0), rectPts(2, 6), METAL, aim, k, 1); hazard(c, aim, k, -10.5, -7.5, 0, col, 1);
          plate(c, rectPts(8, 10), METAL_L, aim, k, 1.3); rivets(c, rectPts(8, 10), aim, k, 0.84, 0.75 * k);
          [-4, 4].forEach((y, i) => { const f = firedBarrel(fx, i, 0.3), r = f * 3.5; bar(P(c, aim, k, 4 - r, y), P(c, aim, k, 23 - r, y), 2.8 * k, METAL_L);
            plate(P(c, aim, k, 23 - r, y), rectPts(1.3, 2.2), METAL, aim, k, 0.9); muzzleEnd(P(c, aim, k, 24.2 - r, y), k, 2.4, col, f); });
          glowDot(P(c, aim, k, -3, 0), 1.2 * k, col); } },
      { key: "F", name: "Rammer Howitzer", muzzle: 25 / 48, theme: "A howitzer on a long cradle with a hydraulic rammer behind the breech that slams forward after each shot, and a tray of shells on the side.",
        draw(c, aim, s, fx, t, col) { const k = G(s), r = fx.recoil * 3.5; deck(c, k, col, t);
          plate(P(c, aim, k, -3, 0), rectPts(13, 4.2), METAL, aim, k, 1.1);
          bar(P(c, aim, k, -r, 0), P(c, aim, k, 25 - r, 0), 3.8 * k, METAL_L); for (const x of [8, 14]) bar(P(c, aim, k, x - r, -3), P(c, aim, k, x - r, 3), 1.4 * k, lt(METAL_D, 0.15));
          muzzleEnd(P(c, aim, k, 25 - r, 0), k, 3.8, col, fx.flash);
          bar(P(c, aim, k, -15, 0), P(c, aim, k, -6 - 6 * fx.recoil, 0), 1.6 * k, METAL_L); plate(P(c, aim, k, -15, 0), rectPts(1.6, 3), METAL_D, aim, k, 0.9);
          plate(P(c, aim, k, -6, -7.5), rectPts(5, 2.2), AMMO, aim, k, 0.9); for (const x of [-9, -6, -3]) orb(P(c, aim, k, x, -7.5), 1.3 * k, mix(METAL_L, col, 0.25));
          plate(c, ngon(8, 1, Math.PI / 8), METAL_L, aim, 6 * k, 1.1); orb(c, 3 * k, METAL); glowDot(c, 1 * k, col); } },
    ],
    anims: [
      { key: "A", name: "Shell on the Mark", desc: "A heavy shell arcs high over the map and lands on the marker in a big blast; smoke rolls from the muzzle.", period: 4, flight: 1.5,
        fx: (since) => ({ recoil: decay(since, 0.45), flash: decay(since, 0.2) }),
        shot: (f, to, u, s, col) => { if (u < 0.3) smokePuff(f, u / 0.3, s * 1.2, 0.5); shell(f, to, u, s, col, 1.2); }, impact: (to, v, s, col) => blast(to, v, s, col, 0.55) },
      { key: "B", name: "Muzzle Blast", desc: "A huge muzzle flash kicks a dust ring out around the gun; the shell flies with a glowing trail and hits with a shock ring.", period: 4, flight: 1.5,
        fx: (since) => ({ recoil: decay(since, 0.5), flash: decay(since, 0.35) }),
        shot: (f, to, u, s, col, kk, t, info) => { if (u < 0.3) { const v = u / 0.3; ring(info.c, s * (0.35 + v * 0.9), [0.55, 0.5, 0.42, 0.5 * (1 - v)], 3); smokePuff(f, v, s * 1.5, 0.55); } shell(f, to, u, s, col, 1.2, true); },
        impact: (to, v, s, col) => { blast(to, v, s, col, 0.6); if (v < 0.6) ring(to, s * (0.3 + v * 1.4), A([1, 0.95, 0.8, 1], 0.6 * (1 - v / 0.6)), 1.4); } },
      { key: "C", name: "Plunging Shell", desc: "The shell climbs out of sight; its shadow grows on the marker, a whistle streak drops in, and it lands in a blast that throws debris.", period: 4, flight: 1.5,
        fx: (since) => ({ recoil: decay(since, 0.45), flash: decay(since, 0.2) }),
        shot: (f, to, u, s, col) => { const k = G(s);
          if (u < 0.35) { const v = u / 0.35, p = add(f, [0, -v * s * 1.6]); orb(p, 2.4 * k * (1 - 0.4 * v), METAL_L); glowDot(p, 1 * k, col); if (v < 0.6) smokePuff(f, v / 0.6, s, 0.5); }
          else { const v = (u - 0.35) / 0.65; ellipse(to, (1 + 3 * v) * k, (0.5 + 1.5 * v) * k, [0, 0, 0, 0.15 + 0.35 * v]);
            if (v > 0.7) { const w = (v - 0.7) / 0.3, p = add(to, [0, -(1 - w) * s * 1.2]); line(add(p, [0, -s * 0.3]), p, [1, 1, 1, 0.5], 1); orb(p, 2.6 * k, METAL_L); glowDot(p, 1.1 * k, col); } } },
        impact: (to, v, s, col) => { blast(to, v, s, col, 0.6); for (let i = 0; i < 7; i++) disc(add(to, mul(fa(i * 0.9 + 0.3), s * 0.55 * v)), 1.6, [0.5, 0.45, 0.4, 1 - v]); } },
      { key: "D", name: "Walking Barrage", desc: "A salvo of three shells walked along the track through the marker, one after another, each landing a little further on.", period: 4, burst: 3, gap: 0.35, flight: 1.5,
        fx: (since) => ({ recoil: Math.max(decay(since, 0.3), decay(since - 0.35, 0.3), decay(since - 0.7, 0.3)), flash: Math.max(decay(since, 0.15), decay(since - 0.35, 0.15), decay(since - 0.7, 0.15)) }),
        shot: (f, to, u, s, col, kk, t, info) => { if (u < 0.25) smokePuff(f, u / 0.25, s, 0.45); shell(f, add(to, [(info.sh.k - 1) * s * 0.45, 0]), u, s, col); },
        impact: (to, v, s, col, info) => blast(add(to, [(info.sh.k - 1) * s * 0.45, 0]), v, s, col, 0.42) },
      { key: "E", name: "Air Burst", desc: "The shell bursts in the air above the marker and showers fragments down onto the track below.", period: 4, flight: 1.4,
        fx: (since) => ({ recoil: decay(since, 0.45), flash: decay(since, 0.2) }),
        shot: (f, to, u, s, col) => { if (u < 0.3) smokePuff(f, u / 0.3, s * 1.2, 0.5); shell(f, add(to, [0, -s * 0.55]), u, s, col, 1.1); },
        impact: (to, v, s, col) => { const air = add(to, [0, -s * 0.55]); if (v < 0.25) glowDot(air, s * 0.18 * (1 - v * 4), [1, 0.85, 0.5, 1]); disc(add(air, [0, -v * s * 0.1]), s * (0.12 + v * 0.2), [0.3, 0.3, 0.32, 0.5 * (1 - v)]);
          for (let i = 0; i < 10; i++) { const e = add(to, [(rnd(i) - 0.5) * s * 0.9, (rnd(i + 3) - 0.5) * s * 0.3]); disc(lerp(air, e, Math.min(1, v * 1.6)), 1.4, A(i % 2 ? col : [1, 0.85, 0.5, 1], 1 - v)); } } },
      { key: "F", name: "Spotter and Strike", desc: "A small spotting round lands first and puffs coloured smoke on the marker; a second later the heavy shell follows it in.", period: 4, burst: 2, gap: 1.0, flight: 1.4,
        fx: (since) => ({ recoil: Math.max(decay(since, 0.2) * 0.5, decay(since - 1, 0.45)), flash: Math.max(decay(since, 0.1) * 0.5, decay(since - 1, 0.2)) }),
        shot: (f, to, u, s, col, kk, t, info) => { if (info.sh.k === 1 && u < 0.3) smokePuff(f, u / 0.3, s * 1.2, 0.5); shell(f, to, u, s, col, info.sh.k ? 1.3 : 0.6, info.sh.k === 1); },
        impact: (to, v, s, col, info) => { if (info.sh.k === 0) disc(add(to, [0, -v * s * 0.3]), s * (0.12 + v * 0.3), A(col, 0.45 * (1 - v))); else blast(to, v, s, col, 0.6); } },
    ] },

  // 7. Railgun ------------------------------------------------------------------------------------------
  { id: "railgun", num: 7, name: "Railgun", cls: "Assault", weapon: "Ballistic", hits: "both", color: [0.45, 1.00, 0.55, 1],
    desc: "A large cannon with magnetically polarized rails that launch a large projectile extremely far, extremely fast. \"Known to cause cancer in the state of California.\" The slug pierces every enemy on its line, weaker after each (the hit flashes shrink). (Colour: today's Railgun green.)",
    looks: [
      { key: "A", name: "Twin-Rail Turret", muzzle: 27 / 48, theme: "Two long rails wrapped in coil bands on a riveted turret, capacitor banks on both flanks whose lights fill as it charges; a green strip glows between the rails.",
        draw(c, aim, s, fx, t, col) { const k = G(s), r = fx.recoil * 3, ch = fx.charge ?? 1; deck(c, k, col, t);
          for (const y of [-1, 1]) { plate(P(c, aim, k, -8, y * 7), rectPts(4.2, 2.6), lt(METAL_D, 0.12), aim, k, 1); for (let i = 0; i < 3; i++) disc(P(c, aim, k, -10.4 + i * 2.4, y * 7), 0.8 * k, A(col, ch * 3 > i + 0.5 ? 0.95 : 0.25)); }
          for (const y of [-3, 3]) bar(P(c, aim, k, -6 - r, y), P(c, aim, k, 26 - r, y), 2.4 * k, METAL_L);
          strip(P(c, aim, k, -1 - r, 0), P(c, aim, k, 26 - r, 0), 0.9 * k, A(col, Math.min(1, 0.25 + 0.5 * ch + 3 * fx.flash)));
          for (const x of [4, 10, 16, 22]) bar(P(c, aim, k, x - r, -5.6), P(c, aim, k, x - r, 5.6), 2 * k, dk(col, 0.3));
          plate(c, rectPts(6, 5.4), METAL_L, aim, k, 1.2); rivets(c, rectPts(6, 5.4), aim, k, 0.72, 0.8 * k); glowDot(c, 1.6 * k, col);
          if (fx.flash > 0) glowDot(P(c, aim, k, 28 - r, 0), 3.5 * k * fx.flash, col); } },
      { key: "B", name: "Sealed Accelerator", muzzle: 25 / 48, theme: "One thick armoured barrel housing with a glowing slot down its length and heavy coil collars, fed by a big round capacitor drum whose ring fills with charge.",
        draw(c, aim, s, fx, t, col) { const k = G(s), r = fx.recoil * 2.5, ch = fx.charge ?? 1; deck(c, k, col, t);
          bar(P(c, aim, k, -4 - r, 0), P(c, aim, k, 24 - r, 0), 8 * k, METAL); strip(P(c, aim, k, -2 - r, 0), P(c, aim, k, 23 - r, 0), 0.8 * k, A(col, Math.min(1, 0.2 + 0.6 * ch + 3 * fx.flash)));
          for (const x of [3, 10, 17]) bar(P(c, aim, k, x - r, -5.4), P(c, aim, k, x - r, 5.4), 2.6 * k, METAL_L);
          muzzleEnd(P(c, aim, k, 24.5 - r, 0), k, 4, col, fx.flash);
          const dr = P(c, aim, k, -8, 0); orb(dr, 6.5 * k, METAL_L); ring(dr, 4.4 * k, METAL_D, 1.6 * k); arc(dr, 4.4 * k, -Math.PI / 2, -Math.PI / 2 + TAU * ch, A(col, 0.95), 1.4 * k); glowDot(dr, 1.4 * k, col); } },
      { key: "C", name: "Split Rails", muzzle: 26 / 48, theme: "Two rails set wide apart with bare copper windings strung between them that light up as it charges, a heavy breech block, and a side scope.",
        draw(c, aim, s, fx, t, col) { const k = G(s), r = fx.recoil * 3, ch = fx.charge ?? 1; deck(c, k, col, t);
          for (let i = 0; i < 9; i++) { const x = 2 + i * 2.6 - r; line(P(c, aim, k, x, -4.2), P(c, aim, k, x + 1, 4.2), mix(COPPER, col, ch * 3 > i / 3 ? 0.7 : 0), 1.1 * k); }
          for (const y of [-5, 5]) bar(P(c, aim, k, -4 - r, y), P(c, aim, k, 26 - r, y), 2.6 * k, METAL_L);
          plate(P(c, aim, k, -4, 0), rectPts(5, 7.5), METAL_L, aim, k, 1.2); rivets(P(c, aim, k, -4, 0), rectPts(5, 7.5), aim, k, 0.78, 0.7 * k);
          const sc = P(c, aim, k, 0, -10); bar(add(sc, mul(fa(aim), -5 * k)), add(sc, mul(fa(aim), 6 * k)), 2.2 * k, METAL_L); glowDot(add(sc, mul(fa(aim), 6.4 * k)), 1 * k, [1, 0.3, 0.3, 1]);
          glowDot(P(c, aim, k, -4, 0), 1.4 * k, col); if (fx.flash > 0) glowDot(P(c, aim, k, 27 - r, 0), 3.5 * k * fx.flash, col); } },
    ],
    anims: [
      { key: "A", name: "Snap Shot", desc: "The capacitors fill, then a straight green line snaps through the target and on across the map, every enemy on it flashing, smaller each time.", period: 2.5, flight: 0.3,
        fx: (since) => ({ recoil: decay(since, 0.3), flash: decay(since, 0.15), charge: Math.min(1, since / 2.3) }),
        shot: (f, to, u, s, col, kk, t, info) => { const e = farPoint(f, info.sh.to0, info.W); beam(f, e, 2.6 * (1 - u * 0.6), col, 1 - u);
          onLine(f, info.sh.to0, info.ens, s).forEach((h, i) => glowDot(h.p, s * 0.12 * Math.pow(0.6, i) * (1 - u), [1, 1, 1, 1])); } },
      { key: "B", name: "Hypersonic Slug", desc: "A bright slug streaks out with a shock cone behind it, punching through the line of enemies one after another.", period: 2.5, flight: 0.35,
        fx: (since) => ({ recoil: decay(since, 0.3), flash: decay(since, 0.15), charge: Math.min(1, since / 2.3) }),
        shot: (f, to, u, s, col, kk, t, info) => { const e = farPoint(f, info.sh.to0, info.W), d = norm(sub(e, f)), p = lerp(f, e, u), o = orth(d);
          line(f, p, A(col, 0.4), 1.2); for (const sg of [-1, 1]) line(p, add(sub(p, mul(d, s * 0.3)), mul(o, sg * s * 0.12)), A([1, 1, 1, 1], 0.6), 1);
          glowDot(p, s * 0.05, col); const L = Math.hypot(e[0] - f[0], e[1] - f[1]);
          onLine(f, info.sh.to0, info.ens, s).forEach((h, i) => { const w = u - h.along / L; if (w > 0 && w < 0.25) glowDot(h.p, s * 0.13 * Math.pow(0.6, i) * (1 - w * 4), [1, 1, 1, 1]); }); } },
      { key: "C", name: "Ion Trail", desc: "The shot leaves a crackling ion trail along its line that lingers and fades, hurting everything on it.", period: 2.5, flight: 1.0,
        fx: (since) => ({ recoil: decay(since, 0.3), flash: decay(since, 0.15), charge: Math.min(1, since / 2.3) }),
        shot: (f, to, u, s, col, kk, t, info) => { const e = farPoint(f, info.sh.to0, info.W), a = 1 - u; beam(f, e, u < 0.15 ? 2.6 : 1.4, col, u < 0.15 ? 1 : 0.6 * a);
          for (let i = 0; i < 6; i++) { const q = fmod(i / 6 + t * 0.7, 1), p = lerp(f, e, q * 0.6), o = mul(orth(norm(sub(e, f))), s * 0.08); bolt(sub(p, o), add(p, o), A(col, 0.7 * a), 0.8, Math.floor(t * 20) + i); }
          if (u < 0.2) onLine(f, info.sh.to0, info.ens, s).forEach((h, i) => glowDot(h.p, s * 0.12 * Math.pow(0.6, i), [1, 1, 1, 1])); } },
    ] },

  // 8. Tesla Tower --------------------------------------------------------------------------------------
  { id: "tesla", num: 8, name: "Tesla Tower", cls: "Assault", weapon: "Energy", hits: "both", color: [0.75, 0.50, 1.00, 1],
    desc: "A large metal disk mounted atop of a large tower that generates high-voltage electrical arcs that damage incoming enemies. \"It was built in a cave with a box of scraps.\" Chain lightning: it hits one enemy and jumps to three more nearby. Seen from above, the disk is the top of the tower; it doesn't turn. (Colour: today's Arc Coil purple.)",
    looks: [
      { key: "A", name: "Disk Coil", muzzle: 0, fixed: true, theme: "A broad metal disk crowning the tower, copper coil windings showing around it, four ceramic insulator posts at the corners and charge nodes on the rim.",
        draw(c, aim, s, fx, t, col) { const k = G(s), g = fx.glow || 0; deck(c, k, col, t);
          for (let i = 0; i < 4; i++) { const q = add(c, mul(fa(Math.PI / 4 + i * Math.PI / 2), 14 * k)); disc(q, 2.6 * k, OUTLINE); orb(q, 2 * k, CERAMIC); }
          disc(c, 12.5 * k, OUTLINE); disc(c, 11.8 * k, METAL_D); for (let i = 0; i < 4; i++) ring(c, (9.6 + i * 0.6) * k, dk(COPPER, 0.15 * (i % 2)), 0.7 * k);
          orb(c, 8.5 * k, METAL_L); ring(c, 6 * k, METAL, 1 * k);
          for (let i = 0; i < 6; i++) glowDot(add(c, mul(fa(i * TAU / 6), 8 * k)), (0.6 + 0.6 * g) * k, A(col, 0.5 + 0.5 * g));
          glowDot(c, (1.4 + 1.6 * g) * k, col); if (g > 0.3) for (let i = 0; i < 3; i++) { const a = rnd(Math.floor(t * 15) + i) * TAU; bolt(add(c, mul(fa(a), 8 * k)), add(c, mul(fa(a + 0.6), 11 * k)), A(col, g), 0.8, t * 15 + i); } } },
      { key: "B", name: "Twin Toroid", muzzle: 0, fixed: true, theme: "Two polished toroid rings stacked around a charged spire, the outer one studded with charge nodes; sparks leap inward between them.",
        draw(c, aim, s, fx, t, col) { const k = G(s), g = fx.glow || 0; deck(c, k, col, t);
          for (const [R, w] of [[11, 4], [6.5, 3]]) { ring(c, R * k, OUTLINE, (w + 1.4) * k); ring(c, R * k, METAL_L, w * k); arc(c, R * k, Math.PI * 1.05, Math.PI * 1.6, lt(METAL_L, 0.4), w * 0.35 * k); }
          for (let i = 0; i < 8; i++) { const q = add(c, mul(fa(i * TAU / 8 + Math.PI / 8), 11 * k)); disc(q, 1.2 * k, OUTLINE); glowDot(q, (0.6 + 0.5 * g) * k, A(col, 0.6 + 0.4 * g)); }
          orb(c, 3.2 * k, METAL); glowDot(c, (1.6 + 1.8 * g) * k, col);
          for (let i = 0; i < 2; i++) { const a = rnd(Math.floor(t * 12) + i * 3) * TAU; bolt(add(c, mul(fa(a), 8.6 * k)), add(c, mul(fa(a + 0.2), 4 * k)), A(col, 0.4 + 0.6 * g), 0.7, t * 12 + i); } } },
      { key: "C", name: "Lattice Mast", muzzle: 0, fixed: true, theme: "A cross-braced steel lattice mast with a smaller disk crown, four grounding rods at its feet that spark when it fires.",
        draw(c, aim, s, fx, t, col) { const k = G(s), g = fx.glow || 0; deck(c, k, col, t);
          const sq = [[-11, -11], [11, -11], [11, 11], [-11, 11]].map((q) => add(c, mul(q, k)));
          for (let i = 0; i < 4; i++) bar(sq[i], sq[(i + 1) % 4], 1.8 * k, METAL_L); bar(sq[0], sq[2], 1.2 * k, METAL); bar(sq[1], sq[3], 1.2 * k, METAL);
          for (const q of sq) { orb(q, 1.8 * k, METAL_L); const rd = add(q, mul(norm(sub(q, c)), 3.5 * k)); bar(q, rd, 1 * k, COPPER); if (g > 0.3 && rnd(Math.floor(t * 20) + q[0]) > 0.4) glowDot(rd, 1.2 * k, col); }
          orb(c, 6 * k, METAL_L); ring(c, 4.2 * k, METAL, 0.9 * k); glowDot(c, (1.3 + 1.6 * g) * k, col); } },
      { key: "D", name: "Mushroom Cap", muzzle: 0, fixed: true, theme: "One huge domed cap covering the tower, banded with copper ribs, little arcs crawling over its surface as it charges.",
        draw(c, aim, s, fx, t, col) { const k = G(s), g = fx.glow || 0; deck(c, k, col, t);
          disc(c, 13.8 * k, OUTLINE); orb(c, 13 * k, METAL_L); for (let i = 0; i < 12; i++) { const a = i * TAU / 12; line(add(c, mul(fa(a), 4.5 * k)), add(c, mul(fa(a), 12.4 * k)), A(COPPER, 0.75), 0.9 * k); }
          ring(c, 8.5 * k, A(COPPER, 0.8), 1 * k); ring(c, 4.5 * k, METAL, 1.2 * k); glowDot(c, (1.6 + 1.8 * g) * k, col);
          for (let i = 0; i < 2 + Math.round(g * 3); i++) { const a = rnd(Math.floor(t * 14) + i * 5) * TAU; bolt(add(c, mul(fa(a), 5 * k)), add(c, mul(fa(a + 0.5), 11 * k)), A(col, 0.35 + 0.65 * g), 0.8, t * 14 + i); } } },
      { key: "E", name: "Triple Spire", muzzle: 0, fixed: true, theme: "Three small coil spires in a triangle joined by a ring, arcs leaping between their tips; the strike leaves from the middle node.",
        draw(c, aim, s, fx, t, col) { const k = G(s), g = fx.glow || 0; deck(c, k, col, t); ring(c, 8.5 * k, OUTLINE, 3 * k); ring(c, 8.5 * k, METAL, 1.8 * k);
          const tips = [0, 1, 2].map((i) => add(c, mul(fa(-Math.PI / 2 + i * TAU / 3), 8.5 * k)));
          for (const q of tips) { disc(q, 3.8 * k, OUTLINE); orb(q, 3.1 * k, METAL_L); ring(q, 2 * k, A(COPPER, 0.9), 0.8 * k); glowDot(q, (0.8 + 0.8 * g) * k, col); }
          for (let i = 0; i < 3; i++) bolt(tips[i], tips[(i + 1) % 3], A(col, 0.35 + 0.6 * g), 0.9, Math.floor(t * 18) + i * 3, 0.2);
          orb(c, 2.4 * k, METAL); glowDot(c, (1.2 + 1.6 * g) * k, col); } },
      { key: "F", name: "Spark Gap", muzzle: 0, fixed: true, theme: "Two big electrode balls on insulator posts face each other across a spark gap; a bolt crackles between them all the time and flares when it fires.",
        draw(c, aim, s, fx, t, col) { const k = G(s), g = fx.glow || 0; deck(c, k, col, t); plate(c, rectPts(13, 6), METAL_D, 0, k, 1.2);
          for (const x of [-1, 1]) { bar(add(c, [x * 13 * k, 5 * k]), add(c, [x * 8 * k, 0]), 1.6 * k, CERAMIC); bar(add(c, [x * 13 * k, -5 * k]), add(c, [x * 8 * k, 0]), 1.6 * k, CERAMIC); orb(add(c, [x * 8 * k, 0]), 4.4 * k, METAL_L); glowDot(add(c, [x * 8 * k, 0]), (0.8 + g) * k, col); }
          bolt(add(c, [-4 * k, 0]), add(c, [4 * k, 0]), A(lt(col, 0.2 * g), 0.55 + 0.45 * g), 1 + 1.6 * g, Math.floor(t * 24), 0.5); glowDot(c, (1 + 1.6 * g) * k, col); } },
    ],
    anims: [
      { key: "A", name: "Chain Arc", desc: "A jagged purple bolt leaps from the disk to the target and on to three more nearby enemies in an instant, each jump a little thinner.", period: 1.25, flight: 0.22,
        fx: (since) => ({ glow: decay(since, 0.3) }),
        shot: (f, to, u, s, col, kk, t, info) => { const k = G(s), pts = chain(to, info.ens, 3, s * 1.5), seed = Math.floor(t * 30), a = 1 - u * 0.6;
          bolt(add(f, mul(norm(sub(to, f)), 8 * k)), to, A(col, a), 2.4, seed); for (let i = 1; i < pts.length; i++) bolt(pts[i - 1], pts[i], A(col, a), 2.4 * Math.pow(0.8, i), seed + i * 11);
          for (const p of pts) glowDot(p, s * 0.06, A([1, 1, 1, 1], a)); } },
      { key: "B", name: "Jumping Arc", desc: "The bolt hits the target, then visibly hops enemy to enemy, one jump at a time.", period: 1.25, flight: 0.5,
        fx: (since) => ({ glow: decay(since, 0.5) }),
        shot: (f, to, u, s, col, kk, t, info) => { const k = G(s), pts = chain(to, info.ens, 3, s * 1.5), seed = Math.floor(t * 30), n = pts.length, step = Math.floor(u * (n + 0.5));
          if (step === 0) bolt(add(f, mul(norm(sub(to, f)), 8 * k)), to, col, 2.4, seed);
          else if (step < n) bolt(pts[step - 1], pts[step], col, 2.4 * Math.pow(0.8, step), seed + step);
          glowDot(pts[Math.min(step, n - 1)], s * 0.07, [1, 1, 1, 1]); } },
      { key: "C", name: "Corona Burst", desc: "Sparks crawl over the disk as it charges, then a thick white-cored bolt with side branches strikes and chains; the disk glows after.", period: 1.25, flight: 0.3,
        fx: (since, p) => ({ glow: Math.max(decay(since, 0.5), since > p - 0.45 ? Math.min(1, (since - (p - 0.45)) / 0.45) : 0) }),
        shot: (f, to, u, s, col, kk, t, info) => { const k = G(s), pts = chain(to, info.ens, 3, s * 1.5), seed = Math.floor(t * 25), a = 1 - u * 0.5;
          const main = bolt(add(f, mul(norm(sub(to, f)), 8 * k)), to, A(lt(col, 0.3), a), 3.4, seed);
          for (const j of [2, 4]) bolt(main[j], add(main[j], mul(fa(rnd(seed + j) * TAU), s * 0.3)), A(col, 0.7 * a), 1.2, seed + j * 5);
          for (let i = 1; i < pts.length; i++) bolt(pts[i - 1], pts[i], A(col, a), 2.6 * Math.pow(0.8, i), seed + i * 11); glowDot(to, s * 0.09 * a, [1, 1, 1, 1]); } },
    ] },

  // 9. Drone Bay ----------------------------------------------------------------------------------------
  { id: "drones", num: 9, name: "Drone Bay", cls: "Assault", weapon: "Deployable", hits: "both", color: [0.62, 0.91, 0.44, 1], waves: { on: 6, off: 4 },
    desc: "Houses combat drones that hunt after enemies. \"The military really took the idea of same-day delivery and ran with it.\" One drone at stock (the Retrofit adds the second); it hunts anywhere on the map. Once launched it never goes home: with no enemies around it idles (owner). The preview clears the lane every few seconds to show the idle. The look sets the bay and the drone; the animation sets how it fights and idles. (Colour: today's Drone Bay green.)",
    looks: [
      { key: "A", name: "Rotor Pad Hangar", muzzle: 0, fixed: true, theme: "A squat armoured hangar with a marked landing pad on its roof and a blinking antenna; its drone is a quadcopter with a small chin gun.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); plate(c, rectPts(13, 13), METAL_D, 0, k, 1.3); rivets(c, rectPts(13, 13), 0, k, 0.88, 0.8 * k);
          ring(c, 7.4 * k, A(col, 0.6), 1.2 * k); for (const x of [-2.6, 2.6]) line(add(c, [x * k, -2.6 * k]), add(c, [x * k, 2.6 * k]), A(col, 0.75), 1.1 * k); line(add(c, [-2.6 * k, 0]), add(c, [2.6 * k, 0]), A(col, 0.75), 1.1 * k);
          bar(add(c, [10 * k, 10 * k]), add(c, [10 * k, -3 * k]), 1 * k, METAL_L); if (fmod(t * 1.3, 1) < 0.4) glowDot(add(c, [10 * k, -3.8 * k]), 1.1 * k, [1, 0.3, 0.3, 1]);
          if (fx.docked !== false) this.drone(c, -Math.PI / 2, k, t, col, 0.4); },
        drone(p, dir, k, t, col, spin) { for (let i = 0; i < 4; i++) { const q = add(p, mul(fa(dir + Math.PI / 4 + i * Math.PI / 2), 4.6 * k)); bar(p, q, 1 * k, METAL_D); rotor(q, 2.6 * k, t * (spin ?? 1), k); }
          plate(p, rectPts(2.6, 2), METAL_L, dir, k, 0.9); bar(add(p, mul(fa(dir), 1.5 * k)), add(p, mul(fa(dir), 4.2 * k)), 0.9 * k, METAL); glowDot(add(p, mul(fa(dir), 1.2 * k)), 0.8 * k, col); } },
      { key: "B", name: "Jet Silo", muzzle: 0, fixed: true, theme: "A round armoured silo whose six iris doors spiral open to launch; its drone is a small delta-wing jet with a glowing exhaust.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); disc(c, 12.5 * k, OUTLINE); disc(c, 11.6 * k, METAL); ring(c, 10.4 * k, METAL_L, 1.2 * k);
          const open = fx.docked === false ? 1 : 0; disc(c, 9.6 * k, BORE);
          for (let i = 0; i < 6; i++) { const a = i * TAU / 6 + open * 0.5; fill(c, [[0, 0], [9.6 * Math.cos(a), 9.6 * Math.sin(a)], [9.6 * Math.cos(a + TAU / 6), 9.6 * Math.sin(a + TAU / 6)]].map((q) => mul(q, 1 - open * 0.55)), i % 2 ? METAL_L : lt(METAL_L, 0.08), 0, k); }
          for (let i = 0; i < 4; i++) glowDot(add(c, mul(fa(i * Math.PI / 2 + Math.PI / 4), 11 * k)), 0.8 * k, A(col, 0.8));
          if (fx.docked !== false) this.drone(c, -Math.PI / 2, k, t, col); },
        drone(p, dir, k, t, col) { glowDot(add(p, mul(fa(dir), -4 * k)), 1.4 * k, col); plate(p, [[4.6, 0], [-3.2, 3.8], [-2.2, 0], [-3.2, -3.8]], METAL_L, dir, k, 0.9); fill(p, [[2.4, 0], [0, 0.9], [0, -0.9]], [0.25, 0.4, 0.45, 1], dir, k); } },
      { key: "C", name: "Tilt-Rotor Hangar", muzzle: 0, fixed: true, theme: "A long hangar with a sliding door and runway stripes on the apron; its drone is a little tilt-rotor with a wing and two big rotors.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); plate(add(c, [-3 * k, 0]), rectPts(9, 12), METAL_D, 0, k, 1.3); for (const y of [-6, 0, 6]) line(add(c, [-11 * k, y * k]), add(c, [5 * k, y * k]), [0, 0, 0, 0.35], 1);
          const door = fx.docked === false ? 6 : 0; plate(add(c, [6 * k, door * k]), rectPts(1.6, 7), METAL_L, 0, k, 1); hazard(c, 0, k, 9, 14, 0, col, 1.4);
          if (fx.docked !== false) this.drone(add(c, [-3 * k, 0]), -Math.PI / 2, k, t, col, 0.3); },
        drone(p, dir, k, t, col, spin) { bar(add(p, mul(orth(fa(dir)), 5.5 * k)), add(p, mul(orth(fa(dir)), -5.5 * k)), 1.6 * k, METAL_L);
          for (const sg of [-1, 1]) rotor(add(p, mul(orth(fa(dir)), sg * 5.5 * k)), 3.2 * k, t * (spin ?? 1), k);
          plate(p, [[3.6, 0], [1.6, 1.3], [-3.6, 1], [-3.6, -1], [1.6, -1.3]], METAL, dir, k, 0.9); glowDot(add(p, mul(fa(dir), 2.4 * k)), 0.8 * k, col); } },
    ],
    anims: [
      { key: "A", name: "Hunt and Circle", desc: "Circles its prey firing short bursts. Idle: hovers where it is, bobbing and slowly turning.", period: 1, flight: 1, fx: () => ({}),
        persist: droneAgent({ engage: (m, t, fp, info, s) => ({ p: add(fp, mul(fa(t * 2.4), s * 0.4)), face: faceTo(m, fp), fire: distTo(m.p, fp) < s * 0.8 }),
          idle: (m, t, info, s) => ({ p: add(m.anchor, [0, Math.sin(t * 3) * s * 0.04]), face: t * 0.8, speed: 1 }) }) },
      { key: "B", name: "Strafing Dives", desc: "Fast back-and-forth passes over its prey, firing as it crosses. Idle: flies a slow figure-eight where it stopped.", period: 1, flight: 1, fx: () => ({}),
        persist: droneAgent({ engage: (m, t, fp, info, s) => { const d0 = norm(sub(fp, info.c)), sw = Math.sin(t * 3.2); return { p: add(add(fp, mul(d0, sw * s * 0.8)), mul(orth(d0), s * 0.15)), speed: 4, fire: Math.abs(sw) < 0.45, rate: 0.12 }; },
          idle: (m, t, info, s) => ({ p: add(m.anchor, [Math.sin(t * 0.8) * s * 0.6, Math.sin(t * 1.6) * s * 0.25]), speed: 1.5 }) }) },
      { key: "C", name: "Stand-off Hover", desc: "Hovers at a distance, firing steady aimed single shots. Idle: drifts in a slow small circle.", period: 1, flight: 1, fx: () => ({}),
        persist: droneAgent({ engage: (m, t, fp, info, s) => ({ p: add(add(fp, mul(norm(sub(m.p, fp)), s * 0.85)), [0, Math.sin(t * 3) * s * 0.04]), face: faceTo(m, fp), fire: true, rate: 0.45 }),
          idle: (m, t, info, s) => ({ p: add(m.anchor, mul(fa(t * 0.7), s * 0.3)), speed: 1.2 }) }) },
      { key: "D", name: "Weave Run", desc: "Closes in weaving side to side, hosing a continuous stream. Idle: patrols up and down along the track.", period: 1, flight: 1, fx: () => ({}),
        persist: droneAgent({ engage: (m, t, fp, info, s) => { const dd = norm(sub(m.p, fp)); return { p: add(add(fp, mul(dd, s * 0.45)), mul(orth(dd), Math.sin(t * 6) * s * 0.25)), face: faceTo(m, fp), speed: 3, fire: true, rate: 0.12 }; },
          idle: (m, t, info, s) => ({ p: [info.W * (0.5 + 0.38 * Math.sin(t * 0.35)), info.H * 0.62], speed: 1.4 }) }) },
      { key: "E", name: "Pounce", desc: "Waits high above its prey (bigger, its shadow far off), then swoops down through it in a fast firing dive. Idle: climbs high and circles wide.", period: 1, flight: 1, fx: () => ({}),
        persist: droneAgent({ engage: (m, t, fp, info, s) => { const cyc = fmod(t, 2.4); return cyc < 1.5 ? { p: add(fp, mul(norm(sub(m.p, fp)), s * 0.9)), alt: 1, face: faceTo(m, fp) } : { p: add(fp, mul(norm(sub(fp, m.p)), s * 0.6)), alt: 0, speed: 6, fire: true, rate: 0.08 }; },
          idle: (m, t, info, s) => ({ p: add(m.anchor, mul(fa(t * 0.5), s * 0.55)), alt: 1, speed: 1.6 }) }) },
      { key: "F", name: "Overwatch Orbit", desc: "Circles its prey at long range, firing steadily. Idle: hovers and sweeps a searchlight around, scanning.", period: 1, flight: 1, fx: () => ({}),
        persist: droneAgent({ engage: (m, t, fp, info, s) => ({ p: add(fp, mul(fa(t * 1.1), s * 0.65)), face: faceTo(m, fp), fire: true, rate: 0.22 }),
          idle: (m, t, info, s) => ({ p: m.anchor, face: t * 1.5, speed: 1, draw: (mm, tt, ss, col) => poly([mm.p, add(mm.p, mul(fa(mm.dir - 0.3), ss * 0.9)), add(mm.p, mul(fa(mm.dir + 0.3), ss * 0.9))], A(col, 0.14)) }) }) },
    ] },

  // 10. CAS Gunship -------------------------------------------------------------------------------------
  { id: "cas", num: 10, name: "CAS Gunship", cls: "Assault", weapon: "Deployable", hits: "both", color: [1.00, 0.45, 0.70, 1], orbit: { x: 0.66, y: 0.58, r: 0.75, w: 0.35 },
    desc: "A large slow-flying cargo plane carrying a wide range of weaponry. \"Yeah, I hate that feeling.\" The tower stands anywhere; the gunship circles the point you designate and side-fires its built-in gatling at enemies under its orbit (shown smaller than the real 90 px orbit to fit). It flies high, so it's drawn much bigger than the ground, its shadow far below (owner). The look sets the ground station and the plane. (Colour: a new pink; no in-game counterpart.)",
    looks: [
      { key: "A", name: "Airfield Beacon + Four-Engine Gunship", muzzle: 0, fixed: true, theme: "Station: a hardstand with runway markings and a pulsing guidance beacon. Plane: a big high-wing cargo gunship with four engines; the gatling fires from inside its side door (round 3: no gun showing on top).",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); plate(c, rectPts(12, 12), METAL_D, 0, k, 1.2); for (let i = 0; i < 4; i++) rect(c[0] - 1 * k, c[1] + (-10 + i * 5) * k, 2 * k, 2.6 * k, [0.85, 0.85, 0.8, 0.8]);
          bar(add(c, [7 * k, 7 * k]), add(c, [7 * k, -2 * k]), 1.2 * k, METAL_L); const pu = fmod(t * 1.2, 1); glowDot(add(c, [7 * k, -2.8 * k]), (0.9 + 0.6 * (1 - pu)) * k, col); ring(add(c, [7 * k, -2.8 * k]), (1.5 + 5 * pu) * k, A(col, 0.6 * (1 - pu)), 1); },
        door(p, h, s) { return P(p, h, G(s) * CAS_Z, 1, 3.2); },
        plane(p, h, s, fx, t, col) { const k = G(s) * CAS_Z; planeShadow(p, h, k, 36, 26);
          bar(P(p, h, k, -12, 0), P(p, h, k, 13, 0), 5 * k, METAL_L); plate(P(p, h, k, -11, 0), rectPts(1.6, 6.5), METAL, h, k, 0.9);
          plate(P(p, h, k, 2, 0), rectPts(2.4, 18), METAL_L, h, k, 1); for (const y of [-12, -6, 6, 12]) { orb(P(p, h, k, 4, y), 1.6 * k, METAL); rotor(P(p, h, k, 6, y), 2.6 * k, t, k); }
          gunDoor(p, h, k, fx, col); glowDot(P(p, h, k, 12, 0), 0.8 * k, col); glowDot(P(p, h, k, 2, -18), 0.7 * k, [1, 0.25, 0.25, 1]); glowDot(P(p, h, k, 2, 18), 0.7 * k, [0.3, 1, 0.45, 1]); } },
      { key: "B", name: "Control Tower + Twin-Boom Gunship", muzzle: 0, fixed: true, theme: "Station: a small round control tower with a turning radar arm. Plane: a twin-boom gunship, short podded fuselage, two engines and a tail joining the booms.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); orb(c, 9 * k, METAL_L); ring(c, 6.5 * k, METAL, 1.2 * k); fill(c, rectPts(5, 5), [0.25, 0.4, 0.45, 0.9], t * 0.3, k);
          const d = fa(t * 2); line(c, add(c, mul(d, 8 * k)), METAL_D, 2 * k); glowDot(add(c, mul(d, 8 * k)), 0.9 * k, col); glowDot(c, 1.1 * k, col); },
        door(p, h, s) { return P(p, h, G(s) * CAS_Z, 2, 3.2); },
        plane(p, h, s, fx, t, col) { const k = G(s) * CAS_Z; planeShadow(p, h, k, 30, 24);
          for (const y of [-5, 5]) bar(P(p, h, k, 3, y), P(p, h, k, -12, y), 1.8 * k, METAL); plate(P(p, h, k, -12, 0), rectPts(1.4, 6.5), METAL_L, h, k, 0.9);
          plate(P(p, h, k, 2, 0), rectPts(2.6, 15), METAL_L, h, k, 1); for (const y of [-5, 5]) { orb(P(p, h, k, 4, y), 1.9 * k, METAL); rotor(P(p, h, k, 6.4, y), 3 * k, t, k); }
          bar(P(p, h, k, -3, 0), P(p, h, k, 9, 0), 5.4 * k, METAL_L); gunDoor(p, h, k, fx, col, 2); glowDot(P(p, h, k, 8.5, 0), 0.8 * k, col); } },
      { key: "C", name: "Uplink Dish + Tilt-Wing Lifter", muzzle: 0, fixed: true, theme: "Station: a satellite uplink dish that turns to follow the gunship. Plane: a boxy tilt-wing heavy lifter with four big rotors.",
        draw(c, aim, s, fx, t, col, info) { const k = G(s); deck(c, k, col, t); plate(c, rectPts(8, 8), METAL, 0, k, 1.1);
          const a = info && info.orbit ? Math.atan2(info.orbit[1] - c[1], info.orbit[0] - c[0]) : 0; arc(c, 8 * k, a - 1.1, a + 1.1, OUTLINE, 3.6 * k); arc(c, 8 * k, a - 1.1, a + 1.1, METAL_L, 2.2 * k);
          line(c, add(c, mul(fa(a), 6 * k)), METAL_L, 1 * k); glowDot(add(c, mul(fa(a), 6 * k)), 1 * k, col); },
        door(p, h, s) { return P(p, h, G(s) * CAS_Z, 0, 3.2); },
        plane(p, h, s, fx, t, col) { const k = G(s) * CAS_Z; planeShadow(p, h, k, 32, 22);
          plate(P(p, h, k, 1, 0), rectPts(10, 3.6), METAL_L, h, k, 1); plate(P(p, h, k, -10, 0), rectPts(1.4, 5.5), METAL, h, k, 0.9);
          plate(P(p, h, k, 3, 0), rectPts(2, 16), METAL, h, k, 0.9); for (const y of [-14, -7, 7, 14]) rotor(P(p, h, k, 3.5, y), 3.4 * k, t, k);
          gunDoor(p, h, k, fx, col, 0); glowDot(P(p, h, k, 10, 0), 0.8 * k, col); } },
      { key: "D", name: "Hardened Bunker + Flying Wing", muzzle: 0, fixed: true, theme: "Station: a low hardened bunker with a hazard-striped blast door. Plane: a broad flying wing with engines buried in its trailing edge and a gun pod under the inner wing.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); plate(c, rectPts(12, 8), METAL_L, 0, k, 1.3); fill(c, rectPts(9.5, 5.6), METAL, 0, k); rivets(c, rectPts(12, 8), 0, k, 0.86, 0.8 * k);
          plate(add(c, [0, 8.5 * k]), rectPts(6, 1.4), METAL_D, 0, k, 1); hazard(c, 0, k, -5.5, 5.5, 10.6, col, 1.2); glowDot(add(c, [8 * k, -4 * k]), 1 * k, col); },
        door(p, h, s) { return P(p, h, G(s) * CAS_Z, -1, 3.2); },
        plane(p, h, s, fx, t, col) { const k = G(s) * CAS_Z; planeShadow(p, h, k, 40, 16);
          const wing = [[8, 0], [-5, 20], [-9, 18], [-4, 0], [-9, -18], [-5, -20]]; plate(p, wing, METAL_L, h, k, 1.1); line(P(p, h, k, 6, 0), P(p, h, k, -4, 0), [0, 0, 0, 0.3], 1);
          for (const y of [-9, -4, 4, 9]) glowDot(P(p, h, k, -6.5, y), 0.9 * k, col); gunDoor(p, h, k, fx, col, -1); glowDot(P(p, h, k, -6, -19), 0.7 * k, [1, 0.25, 0.25, 1]); glowDot(P(p, h, k, -6, 19), 0.7 * k, [0.3, 1, 0.45, 1]); } },
      { key: "E", name: "Radar Mast + Six-Engine Heavy", muzzle: 0, fixed: true, theme: "Station: a braced lattice radar mast with a turning antenna bar. Plane: a long heavy gunship with six engines on a very wide wing and a tall tail.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); const sq = [[-6, -6], [6, -6], [6, 6], [-6, 6]].map((q) => add(c, mul(q, k)));
          for (let i = 0; i < 4; i++) bar(sq[i], sq[(i + 1) % 4], 1.4 * k, METAL_L); bar(sq[0], sq[2], 1 * k, METAL); bar(sq[1], sq[3], 1 * k, METAL);
          const d = fa(t * 1.6); bar(sub(c, mul(d, 9 * k)), add(c, mul(d, 9 * k)), 2 * k, METAL_L); glowDot(add(c, mul(d, 9 * k)), 0.9 * k, col); orb(c, 2.2 * k, METAL); },
        door(p, h, s) { return P(p, h, G(s) * CAS_Z, 3, 3.2); },
        plane(p, h, s, fx, t, col) { const k = G(s) * CAS_Z; planeShadow(p, h, k, 44, 32);
          bar(P(p, h, k, -16, 0), P(p, h, k, 16, 0), 5.6 * k, METAL_L); plate(P(p, h, k, -15, 0), rectPts(1.8, 8), METAL, h, k, 0.9);
          plate(P(p, h, k, 3, 0), rectPts(2.8, 22), METAL_L, h, k, 1); for (const y of [-18, -12, -6, 6, 12, 18]) { orb(P(p, h, k, 5, y), 1.5 * k, METAL); rotor(P(p, h, k, 7, y), 2.4 * k, t, k); }
          gunDoor(p, h, k, fx, col, 3); glowDot(P(p, h, k, 15.5, 0), 0.8 * k, col); } },
      { key: "F", name: "Command Post + Jet Gunship", muzzle: 0, fixed: true, theme: "Station: an armoured octagonal command post with two whip antennas. Plane: a swept-wing jet transport with two pod engines under the wings and a T-tail.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); plate(c, ngon(8, 1, Math.PI / 8), METAL_L, 0, 10 * k, 1.3); fill(c, ngon(8, 1, Math.PI / 8), METAL, 0, 7.4 * k);
          for (const x of [-5, 5]) { line(add(c, [x * k, 0]), add(c, [(x + 2) * k, -12 * k]), METAL_L, 0.9 * k); if (fmod(t + x * 0.1, 1.2) < 0.3) glowDot(add(c, [(x + 2) * k, -12 * k]), 0.9 * k, col); }
          glowDot(c, 1.2 * k, col); },
        door(p, h, s) { return P(p, h, G(s) * CAS_Z, 4, 3.2); },
        plane(p, h, s, fx, t, col) { const k = G(s) * CAS_Z; planeShadow(p, h, k, 34, 30);
          for (const sg of [-1, 1]) plate(p, [[5, sg * 2], [-5, sg * 17], [-8, sg * 17], [-2, sg * 2]], METAL_L, h, k, 1);
          bar(P(p, h, k, -14, 0), P(p, h, k, 15, 0), 4.6 * k, METAL_L); plate(P(p, h, k, -13, 0), rectPts(1.4, 6), METAL, h, k, 0.9);
          for (const y of [-8, 8]) { bar(P(p, h, k, 1, y), P(p, h, k, -4, y), 2.6 * k, METAL); glowDot(P(p, h, k, -4.6, y), 1 * k, col); }
          gunDoor(p, h, k, fx, col, 4); glowDot(P(p, h, k, 14.5, 0), 0.8 * k, col); } },
    ],
    anims: [
      { key: "A", name: "Gatling Stream", desc: "A steady stream of gatling rounds pours from the side door onto enemies under the orbit, the door flashing.", period: 0.2, flight: 0.18,
        fx: (since) => ({ flash: decay(since, 0.08) }), shot: (f, to, u, s, col) => tracer(f, to, u, col, 1.5, 0.3), impact: (to, v, s, col) => spark(to, v, s * 0.7, col) },
      { key: "B", name: "Burst Sweeps", desc: "Six-round bursts walked across the enemies under the orbit, a pause between bursts.", period: 1.2, burst: 6, gap: 0.06, multi: true, flight: 0.2,
        fx: (since) => ({ flash: since < 0.36 && fmod(since, 0.06) < 0.03 ? 1 : 0 }), shot: (f, to, u, s, col) => tracer(f, to, u, col, 1.5, 0.3), impact: (to, v, s, col) => spark(to, v, s * 0.7, col) },
      { key: "C", name: "Brass Rain", desc: "The gatling streams while spent brass casings tumble from the door down toward the ground.", period: 0.2, flight: 0.2,
        fx: (since) => ({ flash: decay(since, 0.08) }),
        shot: (f, to, u, s, col, kk) => { tracer(f, to, u, col, 1.5, 0.3); const q = add(f, [(kk % 2 ? 1 : -1) * u * s * 0.15 + rnd(kk + f[0]) * s * 0.1, u * s * 0.5]); disc(q, 1.2, [1, 0.78, 0.3, 1 - u]); },
        impact: (to, v, s, col) => spark(to, v, s * 0.7, col) },
    ] },
];
const DEFAULTS = { artillery: { look: "F", anim: "A" }, railgun: { look: "B", anim: "A" }, tesla: { look: "B", anim: "C" }, drones: { look: "A", anim: "A" }, cas: { look: "A", anim: "A" } };
