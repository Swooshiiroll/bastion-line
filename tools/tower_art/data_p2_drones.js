// ---- Tower art second pass: Drone Bay (tower 9), round 1 -------------------------------------------------------
// Base: look A Rotor Pad Hangar (quadcopter drone), animation A Hunt and Circle. One parametric model with the lessons so
// far (owner, 2026-10-17/18): options swap parts rather than lay overlays over them; the bay is fixed (it never turns);
// every Power step changes the shots; masteries are gold; charge/timing comes from the engine's own clocks. The paths
// mostly change the DRONE (its gun, pods and racks), so the drone is drawn by this file: Power its guns and rounds,
// Weaponry its loadouts (missiles, bombs, laser, combined: the drone cycles through the unlocked ones, and a selector on
// the bay's panel shows which), Speed its rate of fire (rotary guns). The single Retrofit (the second drone, owner: max 2)
// is drawn as a second pad. Drones launch when the first enemy shows and never go home; with the lane clear they hover.
// Geometry (game px): hangar plate 26 x 26, landing pad r 7.4 at the centre; the quadcopter is 4.6 px arms, 2.6 px rotors,
// a 2.6 x 2 body and a chin gun forward.
const PAGE = { title: "Drone Bay: paths and Retrofits (second pass)", store: "bl-tower-art-p2-drones-r2" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], RED = [0.85, 0.2, 0.18, 1], ORANGE = [1, 0.55, 0.2, 1], CYAN = [0.4, 0.9, 1, 1];
const rotorD = (p, r, t, k) => { disc(p, r, [0.8, 0.85, 0.95, 0.12]); ring(p, r, [0.8, 0.86, 0.95, 0.35], 0.8); for (let q = 0; q < 2; q++) line(p, add(p, mul(fa(t * 40 + q * Math.PI), r * 0.95)), [0.85, 0.9, 1, 0.55], 1.1 * k_); };
let k_ = 1; // the scale rotorD draws its blades at (set per drone below)
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null);
const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const turn = (a, b, m) => { const d = fmod(b - a + Math.PI, TAU) - Math.PI; return a + Math.max(-m, Math.min(m, d)); };

// ---- Loadouts and fire rate --------------------------------------------------------------------------------------------
const typesOf = (B) => ["gun", ...["missile", "bomb", "laser"].slice(0, Math.min(3, B.lv[1])), ...(B.lv[1] >= 5 ? ["all"] : [])];
const SHOTS = [3, 3.5, 4, 5, 5.8, 7]; // shots per second by Speed level
const padsOf = (B) => (B.r < 0 ? [[0, 0]] : B.key("r0") === "C" ? [[-5, 3], [7, -6]] : [[-6.4, 0], [6.4, 0]]);
const padR = (B) => (B.r < 0 ? 7.4 : 5.2);

// ---- The drone: a quadcopter whose gun, pods and racks follow the picks -------------------------------------------------
function drawDrone(B, p, dir, k, t, col, st, spin) {
  k_ = k; const D = (x, y) => P(p, dir, k, x, y), gold = B.lv[0] >= 5;
  const P1 = Kp(B, 0, 0), P2 = Kp(B, 0, 1), P3 = Kp(B, 0, 2), P4 = Kp(B, 0, 3), PM = Kp(B, 0, 4), W1 = Kp(B, 1, 0), W2 = Kp(B, 1, 1), W3 = Kp(B, 1, 2), W4 = Kp(B, 1, 3), WM = Kp(B, 1, 4);
  const S1 = Kp(B, 2, 0), S2 = Kp(B, 2, 1), S3 = Kp(B, 2, 2), S4 = Kp(B, 2, 3), SM = Kp(B, 2, 4), hardW = B.lv[1] >= 4 ? 1.25 : 1;
  const frameC = PM === "A" ? GOLD : METAL_D, rotC = PM === "B" ? GOLD : null;
  for (let i = 0; i < 4; i++) { const q = add(p, mul(fa(dir + Math.PI / 4 + i * Math.PI / 2), 4.6 * k)); bar(p, q, 1 * k, frameC);
    if (P4 === "A") line(add(p, mul(fa(dir + Math.PI / 4 + i * Math.PI / 2), 1.4 * k)), add(p, mul(fa(dir + Math.PI / 4 + i * Math.PI / 2), 4.3 * k)), METAL_L, 0.5 * k);
  }
  // body, with the Power parts
  plate(p, rectPts(2.6, 2), PM === "A" ? lt(GOLD, 0.1) : METAL_L, dir, k, 0.9);
  if (P1 === "B") for (const sg of [-1, 1]) plate(D(-0.4, sg * 2.8), rectPts(1.1, 0.8), METAL_D, dir, k, 0.8);
  if (P1 === "C") for (const sg of [-1, 1]) plate(D(0.2, sg * 1.2), rectPts(1.6, 0.5), STEEL, dir, k, 0.7);
  if (P2 === "B") plate(D(-1.8, 0), rectPts(0.9, 1.1), AMMO, dir, k, 0.8);
  if (P3 === "A") glowDot(D(2.4, 0), 0.55 * k, CYAN);
  if (P3 === "B") glowDot(D(-1, 0.6), 0.45 * k, fmod(t * 3, 1) < 0.5 ? [0.4, 1, 0.5, 1] : [0.2, 0.4, 0.25, 1]);
  if (P3 === "C") plate(D(1.9, 0), rectPts(0.5, 1.4), [0.1, 0.1, 0.14, 1], dir, k, 0.7);
  if (P4 === "B") ring(p, 3 * k, A(METAL_L, 0.9), 0.9 * k);
  if (P4 === "C") { line(D(-2.4, -1.8), D(2.4, 1.8), METAL_L, 0.6 * k); line(D(-2.4, 1.8), D(2.4, -1.8), METAL_L, 0.6 * k); }
  // The gun: one barrel, a rotary cluster (Rotary Guns, picked option), per Power and Speed parts
  const fire = st && st.fire && st.wp !== "laser" && st.wp !== "bomb" ? 1 : 0, sp = (st ? st.t : t) * (fire ? 30 : 3);
  const barrelC = PM === "C" ? GOLD : SM === "A" ? GOLD : METAL, bw = (0.9 + (P1 === "A" ? 0.5 : 0)) * k;
  const rot = S3 === "A" || S3 === "B" || S3 === "C";
  if (rot) { const n = S3 === "B" ? 6 : 3, gys = S3 === "C" ? [-1, 1] : [0];
    for (const gy of gys) { for (let j = 0; j < n; j++) { const a = sp + j * TAU / n, off = Math.sin(a) * 0.55; bar(D(1.6, gy * 1.1 + off), D(4.4, gy * 1.1 + off), 0.45 * k, barrelC); } disc(D(1.8, gy * 1.1), 0.9 * k, OUTLINE); disc(D(1.8, gy * 1.1), 0.65 * k, METAL_L); } }
  else bar(D(1.5, 0), D(4.2 + (P1 === "A" ? 0.4 : 0), 0), bw, barrelC);
  if (P2 === "A") bar(D(2.2, 0), D(3.2, 0), bw * 0.98, ORANGE); // a slim hot shroud, the same width as the barrel it wraps
  if (P2 === "C") ring(D(4.3, 0), 0.9 * k, STEEL, 0.9 * k);
  if (S1 === "A") for (let j = 0; j < 2; j++) line(D(2 + j * 0.8, -0.9), D(2 + j * 0.8, 0.9), STEEL, 0.5 * k);
  if (S1 === "B") polyline([D(-1.5, -1.3), D(-0.6, -1.6), D(0.3, -1.0), D(1.2, -1.3)], METAL_L, 0.6 * k);
  if (S1 === "C") glowDot(D(-2, -1.3), 0.4 * k, [0.4, 1, 0.5, 1]);
  if (S2 === "A") for (const sg of [-1, 1]) line(D(-0.5, sg * 1.2), D(1.8, sg * 0.6), STEEL, 0.6 * k);
  if (S2 === "B") for (const sg of [-1, 1]) bar(D(-1.2, sg * 1.7), D(1, sg * 0.5), 0.7 * k, METAL_D);
  if (S2 === "C") for (const sg of [-1, 1]) { disc(D(-1, sg * 1.8), 0.6 * k, STEEL); }
  if (S4 === "A") plate(D(-1.4, 1.4), rectPts(0.8, 0.5), METAL_D, dir, k, 0.7);
  if (S4 === "A") glowDot(D(-1.4, 1.4), 0.3 * k, fmod(t * 6, 1) < 0.5 ? ORANGE : A(ORANGE, 0.3));
  if (S4 === "B") disc(D(-2.4, 0), 0.9 * k, METAL_D);
  if (S4 === "C") for (let j = 0; j < 3; j++) line(D(2.2 + j * 0.5, -1.3), D(2.2 + j * 0.5, 1.3), A(ORANGE, 0.9), 0.5 * k);
  if (SM === "B") ring(p, 3.4 * k, A(GOLD, 0.85), 0.8 * k);
  if (SM === "C") for (const sg of [-1, 1]) line(D(-1, sg * 1.5), D(1.4, sg * 1.1), GOLD, 0.7 * k);
  // Weaponry: pods, racks and emitters
  const wl = (cc) => (WM ? GOLD : cc);
  if (W1 === "A") for (const sg of [-1, 1]) { bar(D(0.6, sg * 2.4), D(-0.8, sg * 2.4), (1.1 * hardW) * k, METAL); disc(D(0.7, sg * 2.4), 0.5 * k, wl(RED)); }
  if (W1 === "B") for (let j = -1; j <= 1; j++) { bar(D(-0.6, j * 0.9), D(1, j * 0.9), 0.55 * k * hardW, METAL_D); disc(D(1.1, j * 0.9), 0.35 * k, wl(RED)); }
  if (W1 === "C") for (const sg of [-1, 1]) { bar(D(-1.4, sg * 0.8), D(0.4, sg * 0.8), 0.8 * k * hardW, METAL); disc(D(0.5, sg * 0.8), 0.4 * k, wl(RED)); }
  if (W2 === "A") plate(D(-0.2, 0), rectPts(1.3, 0.7), METAL_D, dir, k, 0.7);
  if (W2 === "B") for (const sg of [-1, 1]) { orb(D(-0.8, sg * 3.3), 0.85 * k * hardW, METAL_D); }
  if (W2 === "C") { line(D(-1.2, 0), D(1, 0), [0, 0, 0, 0.6], 0.5 * k); line(D(0, -1), D(0, 1), [0, 0, 0, 0.6], 0.5 * k); }
  if (W3 === "A") disc(D(2.2, 0.9), 0.45 * k, A(CYAN, 0.6 + 0.4 * (st && st.wp === "laser" ? 1 : 0)));
  if (W3 === "B") bar(D(1.4, -1), D(4.4, -1), 0.45 * k, [0.3, 0.55, 0.65, 1]);
  if (W3 === "C") { disc(D(2.2, -0.9), 0.55 * k, OUTLINE); disc(D(2.2, -0.9), 0.4 * k, A(CYAN, 0.8)); }
  if (W4 === "A") for (const sg of [-1, 1]) disc(D(0.6, sg * 2.4), 0.2 * k, [1, 1, 1, 0.9]);
  if (W4 === "B") for (const sg of [-1, 1]) line(D(-0.6, sg * 1.8), D(0.6, sg * 2.4), STEEL, 0.5 * k);
  if (W4 === "C") for (let j = 0; j < 3; j++) glowDot(D(-2.3, -0.8 + j * 0.8), 0.25 * k, A([0.5, 1, 0.5, 1], 0.7));
  if (WM === "A") for (const sg of [-1, 1]) ring(D(0.6, sg * 2.4), 0.8 * k, GOLD, 0.7 * k);
  if (WM === "B") for (let j = -1; j <= 1; j++) disc(D(1.1, j * 0.9), 0.25 * k, GOLD);
  if (WM === "C") for (const sg of [-1, 1]) line(D(0, sg * 1.8), D(0, sg * 3.2), GOLD, 0.8 * k);
  glowDot(D(1.2, 0), 0.8 * k, gold ? GOLD : col);
  // The rotors turn above the arms and the body, so they are drawn last (owner: the body was drawing on top of them)
  for (let i = 0; i < 4; i++) { const q = add(p, mul(fa(dir + Math.PI / 4 + i * Math.PI / 2), 4.6 * k)); rotorD(q, 2.6 * k, t * (spin ?? 1), k); if (rotC) ring(q, 2.6 * k, A(rotC, 0.9), 0.9 * k); }
  if (fire && st.flash) glowDot(D(4.6, 0), (0.6 + 1.2 * st.flash) * k, gold ? GOLD : col);
}

// ---- The agent: one or two drones that launch on the first enemy, circle and fire, and hover when the lane clears ---------
function droneAgent(B) { return (m, t, info, s, col) => { const k = G(s), dt = Math.min(0.1, Math.max(0, t - (m.t ?? t))); m.t = t;
  const pads = padsOf(B); const types = typesOf(B), wp = types[Math.floor(t / 4) % types.length]; m.weapon = wp;
  if (!m.list) m.list = pads.map(([x, y], i) => ({ p: add(info.c, [x * k, y * k]), dir: -Math.PI / 2, shots: [], last: { gun: -9, missile: -9, bomb: -9 }, alt: 0, out: false, anchor: null, i }));
  const taken = new Set(), P1 = Kp(B, 0, 0), P2 = Kp(B, 0, 1), P3 = Kp(B, 0, 2), P4 = Kp(B, 0, 3), PM = Kp(B, 0, 4), hardW = B.lv[1] >= 4 ? 1.25 : 1; const WM = Kp(B, 1, 4);
  const tcol = PM ? GOLD : P2 ? ORANGE : col, tw = 1.3 + 0.3 * B.lv[0], gap = 1 / SHOTS[B.lv[2]];
  for (const d of m.list) { let foe = null, bd = 1e9;
    for (const e of info.ens) { if (taken.has(e.i) && info.ens.length > 1) continue; const dd = dist(e.p, d.p); if (dd < bd) { bd = dd; foe = e; } }
    if (foe) { taken.add(foe.i); d.out = true; m.out = true; }
    if (!d.out) continue;
    if (foe) d.anchor = null; else if (!d.anchor) d.anchor = d.p.slice();
    const w = foe ? { p: add(foe.p, mul(fa(t * 2.4 + d.i * Math.PI), s * 0.4)), face: Math.atan2(foe.p[1] - d.p[1], foe.p[0] - d.p[0]), fire: dist(d.p, foe.p) < s * 0.8 }
      : { p: add(d.anchor, [Math.sin(t * 2.2 + d.i) * s * 0.05 + (d.i ? s * 0.12 : 0), Math.sin(t * 3 + d.i) * s * 0.04]), face: t * 0.8 + d.i * 2, speed: 1 };
    const dv = sub(w.p, d.p), L = Math.hypot(dv[0], dv[1]), sp = (w.speed || 2.6) * s * dt;
    d.p = L <= sp ? w.p.slice() : add(d.p, mul(dv, sp / L));
    const pad = s * 0.22; d.p = [Math.max(pad, Math.min(info.W - pad, d.p[0])), Math.max(pad, Math.min(info.H - pad, d.p[1]))];
    d.dir = turn(d.dir, w.face ?? (L > 2 ? Math.atan2(dv[1], dv[0]) : d.dir), 9 * dt);
    const useGun = wp === "gun" || wp === "all", useMis = wp === "missile" || wp === "all", useBomb = wp === "bomb", useLas = wp === "laser" || wp === "all";
    d.laser = !!(foe && w.fire && useLas);
    if (foe && w.fire) {
      if (useGun && t - d.last.gun >= gap) { d.last.gun = t; d.shots.push({ type: "gun", t0: t, from: d.p.slice(), id: foe.i, to0: foe.p.slice() }); }
      if (useMis && t - d.last.missile >= 0.9) { d.last.missile = t; d.shots.push({ type: "missile", t0: t, from: d.p.slice(), id: foe.i, to0: foe.p.slice() }); }
      if (useBomb && t - d.last.bomb >= 1.4) { d.last.bomb = t; d.shots.push({ type: "bomb", t0: t, from: d.p.slice(), id: foe.i, to0: foe.p.slice() }); } }
    d.shots = d.shots.filter((q) => t - q.t0 < 1);
    for (const q of d.shots) { const e = info.ens.find((x) => x.i === q.id), to = e ? e.p : q.to0, el = t - q.t0;
      if (q.type === "gun") { const u = el / 0.15; if (u < 1) { tracer(q.from, to, u, tcol, tw, 0.35); if (P3 || PM) tracer(q.from, to, u, [1, 1, 1, 1], tw * 0.4, 0.35); if (P4) tracer(add(q.from, [0, 2]), add(to, [0, 2]), u, A(tcol, 0.8), tw * 0.6, 0.3); } else if (u < 2.6) spark(to, (u - 1) * 0.6, s * 0.6 * (P1 ? 1.2 : 1), tcol); }
      else if (q.type === "missile") { const u = el / 0.5, big = hardW; if (u < 1) { const hp = lerp(q.from, to, u); for (let j = 4; j >= 1; j--) disc(lerp(q.from, to, Math.max(0, u - j * 0.05)), (0.9 + j * 0.3) * k * big, [0.7, 0.72, 0.75, 0.3 - 0.05 * j]); plate(hp, rectPts(1.4, 0.55), [0.85, 0.85, 0.88, 1], Math.atan2(to[1] - q.from[1], to[0] - q.from[0]), k * big, 0.7); glowDot(hp, 0.5 * k, ORANGE); }
        else blast(to, Math.min(0.99, (u - 1) * 1.2), s, WM || PM ? GOLD : col, 0.2 * big); }
      else if (q.type === "bomb") { const u = el / 0.5, big = hardW; if (u < 1) { const bp = add(to, [0, -(1 - u) * (1 - u) * s * 0.45]); ellipse(to, 2 * k, 0.9 * k, [0, 0, 0, 0.25 * u]); orb(bp, 1.4 * k * big * (0.7 + 0.5 * u), METAL_D); disc(add(bp, [0, -k * 1.1]), 0.4 * k, [1, 0.3, 0.2, 1]); } else blast(to, Math.min(0.99, (u - 1) * 1.2), s, WM || PM ? GOLD : col, 0.32 * big); } }
    if (d.laser) { const tgt = foe ? foe.p : d.p; beam(add(d.p, mul(fa(d.dir), 4 * k)), tgt, 1.3 * k * hardW, WM || PM ? GOLD : CYAN, 0.85); }
    const z = 1 + 0.35 * d.alt; ellipse(add(d.p, [k * 4, k * 7]), 4 * k * z, 1.8 * k * z, [0, 0, 0, 0.2]);
    const fl = Math.max(0, 1 - Math.min(t - d.last.gun, 0.12) / 0.12) * (t - d.last.gun < 0.12 ? 1 : 0);
    drawDrone(B, d.p, d.dir, k * z, t, col, { fire: t - d.last.gun < 0.15 || d.laser || t - d.last.missile < 0.15, wp, t, flash: fl }, 1); } }; }

// ---- The model: the bay (fixed), its pads, the panel, and the docked drones ----------------------------------------------
const P2 = {
  tower: "drones", look: "A", anim: "A",
  intro: "Round 1: three options for every step and the Retrofit, drawn as one model so the paths combine. The paths change the drone itself: Power its guns and tracer rounds (thicker, hot orange, white-cored, double, gold), Weaponry its loadouts (missile pods, bomb racks, a laser: the drone cycles through the unlocked ones every few seconds and the bay's panel shows which is loaded), Speed its rate of fire (rotary guns). The Retrofit (the second drone, max 2) is a second pad. Drones launch on the first enemy and hover when the lane clears. Unpicked steps show option A.",
  mods(B) { return { period: 1, flight: 1, multi: false, persist: droneAgent(B) }; },
  muzzleAt(B, m, kk, c) { return c; },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), S = (x, y) => add(c, [x * k, y * k]), pads = padsOf(B), pr = padR(B), list = fx.mem && fx.mem.list;
    deck(c, k, col, t);
    plate(c, rectPts(13, 13), METAL_D, 0, k, 1.3); rivets(c, rectPts(13, 13), 0, k, 0.88, 0.8 * k);
    pads.forEach(([x, y], i) => { const q = S(x, y); ring(q, pr * k, A(col, 0.6), 1.2 * k); for (const dx of [-pr * 0.35, pr * 0.35]) line(add(q, [dx * k, -pr * 0.35 * k]), add(q, [dx * k, pr * 0.35 * k]), A(col, 0.75), 1.1 * k); line(add(q, [-pr * 0.35 * k, 0]), add(q, [pr * 0.35 * k, 0]), A(col, 0.75), 1.1 * k); });
    bar(S(10, 10), S(10, -3), 1 * k, METAL_L); if (fmod(t * 1.3, 1) < 0.4) glowDot(S(10, -3.8), 1.1 * k, [1, 0.3, 0.3, 1]);
    // The Retrofit's second pad: twin pads, a divider wall, or a bunker with a hatch
    const ry = B.r >= 0 ? B.key("r0") : null;
    if (ry === "B") { plate(S(0, 0), rectPts(0.7, 7.5), METAL_L, 0, k, 1); for (let i = 0; i < 3; i++) glowDot(S(0, -4 + i * 4), 0.5 * k, A(col, 0.8)); }
    if (ry === "C") { const q = S(7, -6); plate(q, rectPts(5, 4.2), METAL_L, 0, k, 1.1); rivets(q, rectPts(5, 4.2), 0, k, 0.8, 0.5 * k); const open = list && list[1] && list[1].out ? 1 : 0; plate(add(q, [open * 6 * k, 0]), rectPts(2.4, 3.6), METAL, 0, k, 0.9); hazard(c, 0, k, 3, 11, -9.6, col, 0.8); }
    // The loadout selector on the bay's panel (from Missiles): a dot for every unlocked loadout, the loaded one pointed at
    if (B.lv[1] >= 1) { const q = S(-9.5, 9), T = typesOf(B), cur = Math.max(0, T.indexOf((fx.mem && fx.mem.weapon) || "gun")), wc = { gun: [0.85, 0.85, 0.85, 1], missile: RED, bomb: ORANGE, laser: CYAN, all: GOLD };
      disc(q, 3.6 * k, OUTLINE); disc(q, 3 * k, METAL); T.forEach((tt, i) => { const a = -Math.PI / 2 + i * TAU / T.length; glowDot(add(q, mul(fa(a), 1.9 * k)), 0.6 * k, wc[tt]); });
      line(q, add(q, mul(fa(-Math.PI / 2 + cur * TAU / T.length), 1.7 * k)), WHITE, 0.9 * k); if (B.lv[1] >= 5) ring(q, 3.6 * k, GOLD, 1 * k); }
    // Docked drones sit on their pads; drones that have launched are drawn by the agent
    pads.forEach(([x, y], i) => { const out = list && list[i] && list[i].out; if (!out && !(ry === "C" && i === 1)) drawDrone(B, S(x, y), -Math.PI / 2, k, t, col, { fire: false, wp: "gun", t }, 0.4); });
  },
  paths: [
    { name: "Power", theme: "harder-hitting drones; each step changes the guns and rounds", steps: [
      { name: "Heavier Guns", cost: 150, effect: "20 damage", options: [
        { key: "A", name: "Heavy Chin Gun", desc: "A thicker, longer chin gun; the tracers are thicker." },
        { key: "B", name: "Ammo Pods", desc: "Two small ammo pods either side of the drone; the tracers are thicker." },
        { key: "C", name: "Armour Plates", desc: "Steel armour strips over the body; the tracers are thicker." } ] },
      { name: "Hot Loads", cost: 300, effect: "24 damage", options: [
        { key: "A", name: "Hot Barrel Shroud", desc: "An orange-hot shroud on the gun; the tracers glow hot orange." },
        { key: "B", name: "Ammo Box", desc: "An ammo box on the back; hot orange tracers." },
        { key: "C", name: "Muzzle Ring", desc: "A steel ring on the muzzle; hot orange tracers." } ] },
      { name: "Combat Firmware", cost: 900, effect: "30 damage (primary)", options: [
        { key: "A", name: "Sensor Eye", desc: "A glowing sensor eye on the nose; the tracers get a white core." },
        { key: "B", name: "Firmware Lamp", desc: "A blinking green firmware lamp on top; white-cored tracers." },
        { key: "C", name: "Targeting Visor", desc: "A dark targeting visor across the nose; white-cored tracers." } ] },
      { name: "Assault Frames", cost: 1800, effect: "36 damage", options: [
        { key: "A", name: "Frame Rails", desc: "Steel rails along each arm; a second, fainter tracer line." },
        { key: "B", name: "Armour Skirt", desc: "An armoured ring round the body; a second tracer line." },
        { key: "C", name: "Roll Cage", desc: "Crossed cage bars over the body; a second tracer line." } ] },
      { name: "Elite Drones", cost: 3600, effect: "42 damage (mastery)", options: [
        { key: "A", name: "Gold Frame", desc: "A gold frame and gold-trimmed body; gold tracers." },
        { key: "B", name: "Gold Rotors", desc: "Gold rings round all four rotors; gold tracers." },
        { key: "C", name: "Gold Gun", desc: "A gold gun barrel; gold tracers." } ] },
    ] },
    { name: "Weaponry", theme: "loadouts you switch between (the drone cycles through the unlocked ones in the preview)", steps: [
      { name: "Micro-Missiles", cost: 60, effect: "Unlocks missiles: slower shots with a 25 px blast", options: [
        { key: "A", name: "Wing Pods", desc: "A missile pod under each wing with a red nose; the drone fires missiles that leave a smoke trail." },
        { key: "B", name: "Pylon Rack", desc: "A rack of three missiles under the belly; missiles with a smoke trail." },
        { key: "C", name: "Mini Launchers", desc: "Two short launchers on the back; missiles with a smoke trail." } ] },
      { name: "Bomb Racks", cost: 120, effect: "Unlocks bombs: heavy ground-only drops with a 40 px blast", options: [
        { key: "A", name: "Belly Bomb Rack", desc: "A bomb rack plate under the belly; the drone drops bombs that fall and burst." },
        { key: "B", name: "Wing Bombs", desc: "A bomb hung under each wing; bombs fall and burst." },
        { key: "C", name: "Bomb Bay Doors", desc: "Crossed bay doors under the belly; bombs fall and burst." } ] },
      { name: "Drone Laser", cost: 290, effect: "Unlocks laser: energy damage that ignores armour (primary)", options: [
        { key: "A", name: "Laser Emitter", desc: "A cyan emitter lens under the nose; the drone fires a laser beam." },
        { key: "B", name: "Laser Cannon", desc: "A slim cyan laser cannon beside the gun; a laser beam." },
        { key: "C", name: "Prism Lens", desc: "A ringed prism lens on the nose; a laser beam." } ] },
      { name: "Upgraded Loadouts", cost: 865, effect: "Every loadout 25% stronger", options: [
        { key: "A", name: "Larger Pods", desc: "Brighter pod tips; bigger missiles, bombs and beams." },
        { key: "B", name: "Reinforced Pylons", desc: "Struts under the pods; bigger missiles, bombs and beams." },
        { key: "C", name: "Ammo Counters", desc: "Three green ammo counter lamps; bigger missiles, bombs and beams." } ] },
      { name: "Full Kit", cost: 3360, effect: "A combined loadout: guns, missiles and laser together (mastery)", options: [
        { key: "A", name: "Gold Hardpoints", desc: "Gold rings round the pods; the combined loadout fires guns, missiles and a gold laser together." },
        { key: "B", name: "Gold Racks", desc: "Gold rack heads; the combined loadout fires everything together." },
        { key: "C", name: "Gold Pylon Wings", desc: "Gold wing pylons; the combined loadout fires everything together." } ] },
    ] },
    { name: "Speed", theme: "rate of fire", steps: [
      { name: "Fast Cycling", cost: 100, effect: "3.5 shots/s", options: [
        { key: "A", name: "Cooling Fins", desc: "Cooling fins on the gun." },
        { key: "B", name: "Feed Spring", desc: "A feed spring coiled along the side of the gun." },
        { key: "C", name: "Ready Lamp", desc: "A green ready lamp on the body." } ] },
      { name: "Twin Feed", cost: 200, effect: "4 shots/s", options: [
        { key: "A", name: "Twin Belts", desc: "Two ammo belts either side of the gun." },
        { key: "B", name: "Dual Chutes", desc: "Two feed chutes into the gun." },
        { key: "C", name: "Feed Gears", desc: "Two feed gears either side of the body." } ] },
      { name: "Rotary Guns", cost: 800, effect: "5 shots/s (primary)", options: [
        { key: "A", name: "Three-Barrel Rotary", desc: "The chin gun becomes a three-barrel rotary that spins up as it fires." },
        { key: "B", name: "Six-Barrel Gatling", desc: "A six-barrel gatling that spins as it fires." },
        { key: "C", name: "Twin Rotaries", desc: "Two three-barrel rotary guns side by side that spin as they fire." } ] },
      { name: "Overclocked Feed", cost: 1280, effect: "5.8 shots/s", options: [
        { key: "A", name: "Overclock Chip", desc: "A chip box with an orange pulse lamp on the body." },
        { key: "B", name: "Booster Motor", desc: "A motor housing at the tail." },
        { key: "C", name: "Heat Fins", desc: "Glowing orange fins on the barrel." } ] },
      { name: "Storm Drones", cost: 3840, effect: "7 shots/s (mastery)", options: [
        { key: "A", name: "Gold Barrels", desc: "Gold gun barrels." },
        { key: "B", name: "Storm Halo", desc: "A gold halo ring round the drone." },
        { key: "C", name: "Gold Belts", desc: "Gold ammo belts either side of the body." } ] },
    ] },
  ],
  retrofits: [
    { name: "Second Hangar", cost: 3200, effect: "Launches the second drone (max 2)", options: [
      { key: "A", name: "Twin Pads", desc: "Two landing pads side by side; the second drone launches from the second pad." },
      { key: "B", name: "Divided Pads", desc: "Two pads split by a lamp-lit divider wall." },
      { key: "C", name: "Bunker Hatch", desc: "A second pad in a small bunker with a sliding hatch that opens as its drone launches." } ] },
  ],
};
// ---- Round 2 (owner's picks, 2026-10-18): every stage shows only the pick; no notes.
P2.intro = "Round 2: all your picks drawn as one model, nothing left to choose. Use the build preview to check combinations; the second drone appears with the Retrofit.";
P2.picks = { p0s0: "A", p0s1: "A", p0s2: "B", p0s3: "A", p0s4: "A", p1s0: "A", p1s1: "A", p1s2: "A", p1s3: "B", p1s4: "C", p2s0: "C", p2s1: "A", p2s2: "A", p2s3: "A", p2s4: "A", r0: "A" };
P2.paths.forEach((pa, pi) => pa.steps.forEach((st, k) => { const pk = P2.picks["p" + pi + "s" + k]; if (pk) st.options = st.options.filter((o) => o.key === pk); }));
P2.retrofits.forEach((rf, ri) => { const pk = P2.picks["r" + ri]; if (pk) rf.options = rf.options.filter((o) => o.key === pk); });
