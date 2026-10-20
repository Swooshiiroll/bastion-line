// ---- Scrapyard base-look page (third restart, owner 2026-10-19: "Scrap the scrapyard design and start all over again") ----------------------------
// The owner's brief: the tower is three parts, a recycler/smelter (a tall furnace stack, the focal part), a junkyard and a warehouse. Each path will
// later rebuild one part (Passive Income the stack, Kill Income the junkyard, Discounts the warehouse). The three looks are the same three parts in
// three layouts; the three animations are picked separately. Every look names its parts' spots (look.parts, in units) so the animations can use them.
const PAGE = { title: "Scrapyard base look (three parts)", store: "bl-tower-art-scrap-parts-3" };
const rnd = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const distTo = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
function txt(p, str, col, px) { X.save(); X.font = "bold " + Math.round(px) + "px sans-serif"; X.textAlign = "center"; X.fillStyle = css(OUTLINE); X.fillText(str, p[0] + 1, p[1] + 1); X.fillStyle = css(col); X.fillText(str, p[0], p[1]); X.restore(); }
const GOLDC = [1, 0.78, 0.3, 1], RUST = [0.45, 0.3, 0.2, 1], BRICK = [0.55, 0.27, 0.2, 1], MOLTEN = [1, 0.55, 0.15, 1], HOTM = [1, 0.85, 0.45, 1];
const WOOD = [0.6, 0.43, 0.24, 1], DIRT = [0.27, 0.23, 0.19, 1], CONC = [0.29, 0.29, 0.3, 1], ROOF = [0.44, 0.47, 0.5, 1], DOOR = [0.8, 0.58, 0.2, 1], CRANE = [0.92, 0.7, 0.2, 1];
const payAge = (fx, t) => t - ((fx.mem || {}).last ?? -9);
function scrapPile(p, r, k, seed) { const pts = []; for (let i = 0; i < 9; i++) { const a = i * TAU / 9; pts.push([Math.cos(a) * r * (0.65 + 0.35 * rnd(seed + i)), Math.sin(a) * r * (0.65 + 0.35 * rnd(seed + i + 20))]); }
  ellipse(add(p, [k * 1.5, k * 2.5]), r * k, r * k * 0.5, [0, 0, 0, 0.3]); solid(p, pts, mix(RUST, METAL, 0.4), 0, k, 1);
  for (let i = 0; i < 5; i++) { const q = add(p, [(rnd(seed + i * 3) - 0.5) * r * k * 1.1, (rnd(seed + i * 5) - 0.5) * r * k * 0.9]); line(q, add(q, mul(fa(rnd(seed + i) * TAU), r * k * 0.35)), i % 2 ? METAL_L : RUST, 1.4 * k); } }
function coinPop(c, v, s, label) { for (let i = 0; i < 6; i++) { const d = fa(-Math.PI / 2 + (i - 2.5) * 0.35), p = add(add(c, mul(d, s * 0.5 * Math.min(1, v * 2))), [0, v * v * s * 0.4]); disc(p, s * 0.045 + 1, A(OUTLINE, 0.95 * (1 - v))); disc(p, s * 0.045, A(GOLDC, 1 - v)); }
  txt(add(c, [0, -s * 0.4 - v * s * 0.5]), label || "+100", A(GOLDC, Math.min(1, 2 - v * 2)), Math.max(11, s * 0.2)); }

// ---- The three parts ----------------------------------------------------------------------------------------------------------------------------------
// The furnace stack (recycler/smelter): the tallest part, so it casts the longest shadow; brick and steel bands step in towards a glowing mouth.
// Intake chutes feed it from the sides; smoke rises from it (drawn last, over everything). It flares at each payout.
function stack(p, R, chutes, t, age, k) { const pay = decay(age, 1.4), fl = 0.5 + 0.5 * Math.sin(t * 6.3) * Math.sin(t * 2.1 + 1);
  disc(add(p, [R * 0.5 * k, R * 0.6 * k]), R * 1.05 * k, [0, 0, 0, 0.32]);
  for (const a of chutes) { const o = add(p, mul(fa(a), (R + 9) * k)), i = add(p, mul(fa(a), (R - 2) * k)); bar(o, i, 4.4 * k, METAL); line(o, i, METAL_D, 1.4 * k); plate(o, rectPts(4, 4), METAL_D, a, k, 1.2); fill(o, rectPts(2.5, 2.5), [0.08, 0.07, 0.07, 1], a, k); }
  disc(p, (R + 1.6) * k, OUTLINE); disc(p, R * k, BRICK);
  for (let i = 0; i < 26; i++) { const a = i * TAU / 26; line(add(p, mul(fa(a), R * 0.8 * k)), add(p, mul(fa(a), R * k)), [0.32, 0.15, 0.1, 1], 1 * k); }
  ring(p, (R - 0.7) * k, METAL, 1.8 * k);
  disc(p, R * 0.8 * k, lt(BRICK, 0.1)); ring(p, R * 0.8 * k, METAL_L, 1.6 * k); for (let i = 0; i < 8; i++) disc(add(p, mul(fa(i * TAU / 8 + 0.2), R * 0.8 * k)), 0.8 * k, lt(METAL_L, 0.15));
  disc(p, R * 0.63 * k, METAL_D); ring(p, R * 0.63 * k, OUTLINE, 1.2 * k);
  disc(p, R * 0.5 * k, mix([0.35, 0.08, 0.03, 1], MOLTEN, 0.45 + 0.3 * fl + 0.25 * pay)); ring(p, R * 0.56 * k, A(MOLTEN, 0.25 + 0.2 * fl + 0.4 * pay), 2 * k);
  disc(p, R * (0.24 + 0.05 * fl + 0.1 * pay) * k, A(HOTM, 0.9)); glowDot(p, (2 + 2.2 * pay) * k, HOTM); }
function smoke(p, R, t, k) { for (let i = 0; i < 6; i++) { const u = fmod(t * 0.32 + i / 6, 1); disc(add(p, [(R * 0.2 + u * 14) * k, -(R * 0.15 + u * 24) * k]), (2 + u * 6) * k, A([0.5, 0.48, 0.46, 1], 0.42 * (1 - u))); } }
// The junkyard: dirt ground, scrap heaps, a stripped tank hulk and a grab crane that swings over the heaps.
function dirt(c, x0, y0, x1, y1, k, seed) { fill(add(c, [(x0 + x1) / 2 * k, (y0 + y1) / 2 * k]), rectPts((x1 - x0) / 2, (y1 - y0) / 2), DIRT, 0, k);
  for (let i = 0; i < 14; i++) disc(add(c, [(x0 + (x1 - x0) * rnd(seed + i)) * k, (y0 + (y1 - y0) * rnd(seed + i + 40)) * k]), (0.5 + rnd(seed + i + 80)) * k, [0.2, 0.17, 0.14, 1]); }
function wreck(p, ang, k) { const o = (x, y) => add(p, rot([x * k, y * k], ang));
  for (const sg of [-1, 1]) plate(o(0, sg * 7.4), rectPts(12, 2), [0.13, 0.12, 0.12, 1], ang, k, 1);
  plate(p, rectPts(11, 6), mix(RUST, METAL, 0.3), ang, k, 1.3); disc(o(-2, 0), 3.8 * k, OUTLINE); disc(o(-2, 0), 3.1 * k, [0.05, 0.05, 0.05, 1]); ring(o(-2, 0), 3.5 * k, RUST, 1.2 * k);
  line(o(5, -3.5), o(9, 1), [0.3, 0.14, 0.1, 1], 1.2 * k); line(o(4, 1), o(7, 4.5), [0.3, 0.14, 0.1, 1], 1.2 * k); }
function craneArm(p, a, reach, op, k, carry) { const tip = add(p, mul(fa(a), reach * k));
  disc(add(p, [1.5 * k, 2 * k]), 5.4 * k, [0, 0, 0, 0.3]); disc(p, 5.4 * k, OUTLINE); disc(p, 4.6 * k, dk(CRANE, 0.15));
  bar(p, tip, 2.6 * k, CRANE); plate(p, rectPts(3.2, 2.6), METAL_D, a, k, 1.1); if (carry) chunk(tip, 1, carry, k);
  for (let i = 0; i < 4; i++) { const b = a + i * TAU / 4 + Math.PI / 4; line(tip, add(tip, mul(fa(b), (2.2 + 1.6 * op) * k)), METAL_L, 1.3 * k); } disc(tip, 1.6 * k, METAL_D); }
function crane(p, reach, a0, t, k) { craneArm(p, a0 + Math.sin(t * 0.45) * 0.9, reach, 0.5 + 0.5 * Math.sin(t * 0.9), k, 0); }
function chunk(p, sc, seed, k, col) { const pts = []; for (let i = 0; i < 6; i++) { const a = i * TAU / 6; pts.push([Math.cos(a) * 3.1 * (0.7 + 0.3 * rnd(seed + i)), Math.sin(a) * 3.1 * (0.7 + 0.3 * rnd(seed + i + 9))]); }
  fill(p, pts, col || mix([0.72, 0.46, 0.3, 1], METAL_L, 0.2 + 0.4 * rnd(seed)), seed, k * sc); outline(p, pts, OUTLINE, 1.2, seed, k * sc); line(add(p, mul(fa(seed), -1.2 * k * sc)), add(p, mul(fa(seed), 1.2 * k * sc)), [1, 1, 1, 0.35], 0.9 * k * sc); }
// The feed line (round 3, owner): the crane grabs scrap off the heap and drops it on the foot of the belt; each piece rides up and falls off the top
// into the furnace mouth with a flare. One piece per crane cycle (T s); everything is a function of t, so the crane and the belt always agree.
const FEED = { pv: [-36, 13], heap: [-33, 0], b0: [-24, 20], mouth: [0, -8], end: 9.5, T: 3.2, belt: 0.35 };
function feedLine(S, k, t) { const F = FEED, dir = norm(sub(F.mouth, F.b0)), e = sub(F.mouth, mul(dir, F.end)), Lu = distTo(F.b0, e), L = add(F.b0, mul(dir, 2.5)), v = F.belt * Lu, ride = (Lu - 2.5) / v, n = Math.floor(t / F.T);
  conveyor(S(...F.b0), S(...e), t, k);
  for (let i = 0; i < 4; i++) { const m = n - i, a = t - (m + 0.56) * F.T, sd = m * 1.7 + 1; if (a < 0) continue;
    if (a < ride) chunk(S(...add(L, mul(dir, a * v))), 1, sd, k);
    else { const u = (a - ride) / 0.4; if (u < 1) chunk(S(...lerp(e, F.mouth, ease(u))), 1 - 0.65 * u, sd, k, mix([0.72, 0.46, 0.3, 1], MOLTEN, u));
      else if (u < 2.5) glowDot(S(...F.mouth), (1.4 + 2.2 * (1 - (u - 1) / 1.5)) * k, A(HOTM, 1 - (u - 1) / 1.5)); } }
  const ph = fmod(t / F.T, 1), aH = Math.atan2(F.heap[1] - F.pv[1], F.heap[0] - F.pv[0]), aL = Math.atan2(L[1] - F.pv[1], L[0] - F.pv[0]), rH = distTo(F.pv, F.heap), rL = distTo(F.pv, L);
  const sw = ph < 0.14 ? 0 : ph < 0.5 ? ease((ph - 0.14) / 0.36) : ph < 0.6 ? 1 : 1 - ease((ph - 0.6) / 0.4), op = ph < 0.14 ? 1 - ph / 0.14 : ph < 0.5 ? 0 : ph < 0.6 ? (ph - 0.5) / 0.1 : 1;
  craneArm(S(...F.pv), aH + (aL - aH) * sw, rH + (rL - rH) * sw, op, k, ph > 0.06 && ph < 0.56 ? n * 1.7 + 1 : 0); }
// The warehouse: a long shed with a corrugated roof, a ridge and skylights; roll-up doors on its local +y side open at each payout.
function warehouse(p, hw, hh, ang, nDoor, age, k) { const o = (x, y) => add(p, rot([x * k, y * k], ang)), op = age < 0.4 ? ease(age / 0.4) : age < 1.4 ? 1 : 1 - ease(Math.min(1, (age - 1.4) / 0.4));
  fill(add(p, [2.5 * k, 3.5 * k]), rectPts(hw, hh), [0, 0, 0, 0.3], ang, k);
  for (let i = 0; i < nDoor; i++) { const x = (i - (nDoor - 1) / 2) * (hw * 2 - 6) / nDoor, d = o(x, hh + 1.4); fill(d, rectPts(4.4, 2.4), CONC, ang, k); hazard(o(x, hh + 3.6), ang, k, -4, 4, 0, DOOR, 1); }
  plate(p, rectPts(hw, hh), ROOF, ang, k, 1.5);
  for (let x = -hw + 2.2; x < hw - 1; x += 2.2) line(o(x, -hh + 0.9), o(x, hh - 0.9), dk(ROOF, 0.2), 0.8 * k);
  bar(o(-hw + 0.8, 0), o(hw - 0.8, 0), 1.8 * k, lt(ROOF, 0.12));
  for (const x of [-hw * 0.5, hw * 0.5]) fill(o(x, -hh * 0.5), rectPts(2.8, 1.8), [0.7, 0.86, 0.96, 0.55], ang, k);
  for (let i = 0; i < nDoor; i++) { const x = (i - (nDoor - 1) / 2) * (hw * 2 - 6) / nDoor, d = o(x, hh - 0.2); fill(d, rectPts(3.6, 1.3), mix(DOOR, [0.04, 0.04, 0.04, 1], op), ang, k); outline(d, rectPts(3.6, 1.3), OUTLINE, 1, ang, k);
    if (op < 0.9) for (const j of [-0.5, 0.5]) line(o(x - 3.2, hh - 0.2 + j), o(x + 3.2, hh - 0.2 + j), A(dk(DOOR, 0.4), 1 - op), 0.7 * k); } }
function crates(p, cols, rows, k) { for (let r = 0; r < rows; r++) for (let q = 0; q < cols; q++) { const c = add(p, [(q - (cols - 1) / 2) * 6.4 * k, (r - (rows - 1) / 2) * 6.4 * k]); plate(c, rectPts(2.9, 2.9), WOOD, 0, k, 1); line(add(c, [-2.2 * k, -2.2 * k]), add(c, [2.2 * k, 2.2 * k]), dk(WOOD, 0.35), 0.8 * k); } }
function conveyor(a, b, t, k) { const d = norm(sub(b, a)), n = orth(d), L = distTo(a, b);
  line(a, b, OUTLINE, 8 * k); line(a, b, METAL, 6.6 * k); line(a, b, [0.14, 0.13, 0.12, 1], 4.2 * k);
  for (let j = 0; j < Math.floor(L / (3 * k)); j++) { const u = fmod(j * 3 * k / L + t * 0.35, 1), q = lerp(a, b, u); line(add(q, mul(n, 2 * k)), add(q, mul(n, -2 * k)), [0.42, 0.4, 0.37, 1], 0.9 * k); }
  for (const e of [a, b]) { disc(e, 3.4 * k, OUTLINE); disc(e, 2.7 * k, METAL_L); disc(e, 1 * k, METAL_D); } }
// The yard floor: a concrete slab with a copper edge; the junkyard sits on dirt patches.
function yardFloor(c, k, col, t) { ellipse(add(c, [0, 8 * k]), 44 * k, 16 * k, [0, 0, 0, 0.3]); plate(c, rectPts(46, 46), lt(METAL_D, 0.04), 0, k, 1.3); fill(c, rectPts(44, 44), CONC, 0, k);
  for (let i = -3; i <= 3; i++) { line(add(c, [i * 12 * k, -44 * k]), add(c, [i * 12 * k, 44 * k]), [0, 0, 0, 0.1], 0.8 * k); line(add(c, [-44 * k, i * 12 * k]), add(c, [44 * k, i * 12 * k]), [0, 0, 0, 0.1], 0.8 * k); }
  outline(c, rectPts(44, 44), A(col, 0.4 + 0.15 * Math.sin(t * 2.2)), 1.3 * k, 0, k); }

// ---- The payout agent (shared by the three animations): it pays every 4 s in the preview; cfg.extra runs every frame; W(u) maps units to the page.
function scrapAgent(cfg) { return (m, t, info, s, col) => { if (!m.pays) { m.pays = []; m.last = t; }
  if (t - m.last >= 4) { m.last = t; m.pays.push(t); } m.pays = m.pays.filter((q) => t - q < 1.6);
  const P = info.look.parts || { junk: [0, 0], mouth: [0, 0], door: [0, 0] }, W = (u) => add(info.c, mul(u, s / 48));
  if (cfg.extra) cfg.extra(m, t, info, s, col, P, W);
  for (const q of m.pays) cfg.pay((t - q) / 1.6, s, col, P, W, info); }; }

const TOWERS = [
  { id: "scrap", num: 17, name: "Scrapyard", cls: "Utility", weapon: "None", hits: "none", size: 2, center: [0.3, 0.4], color: [0.95, 0.72, 0.42, 1],
    desc: "Various collections of scrap metal sold at a profit. \"One mans toxic waste is another mans potpourri\" A 2x2 tower of three parts: a recycler/smelter (a tall furnace stack), a junkyard and a warehouse. It attacks nothing and pays 100 credits at each round's clear (the preview pays every 4 s). The three looks are the same parts in three layouts. Later, each path rebuilds one part: Passive Income the stack, Kill Income the junkyard, Discounts the warehouse. (Colour: today's Scrapyard copper.)",
    looks: [
      { key: "A", name: "Central Stack", muzzle: 0, fixed: true, parts: { junk: [-30, 4], mouth: [2, -6], door: [23, -6] },
        theme: "The furnace stack stands in the middle of the yard, fed by two chutes from the junkyard that wraps the left and bottom edges (heaps, a tank hulk, a grab crane). A long warehouse runs down the right side, its roll-up doors facing the stack.",
        draw(c, aim, s, fx, t, col) { const k = G(s), age = payAge(fx, t), S = (x, y) => add(c, [x * k, y * k]);
          yardFloor(c, k, col, t); dirt(c, -44, -44, -18, 44, k, 3); dirt(c, -18, 20, 22, 44, k, 9);
          scrapPile(S(-31, -30), 9, k, 1); scrapPile(S(-32, -4), 7, k, 7); scrapPile(S(10, 33), 7, k, 11); wreck(S(-8, 33), -0.1, k); crane(S(-31, 24), 17, -0.5, t, k);
          warehouse(S(34, -6), 30, 9, Math.PI / 2, 3, age, k); crates(S(34, 36), 2, 1, k);
          stack(S(2, -6), 16, [Math.PI * 0.97, Math.PI * 0.68], t, age, k); smoke(S(2, -6), 16, t, k); } },
      { key: "B", name: "Production Line", muzzle: 0, fixed: true, parts: { junk: [-30, 0], mouth: [0, -8], door: [22, -8] },
        theme: "Left to right: in the junkyard a grab crane lifts scrap off a heap and drops it on the foot of a conveyor; each piece rides up the belt and falls off the top into the furnace stack's glowing mouth. A short ingot belt runs from the stack into a tall warehouse on the right.",
        draw(c, aim, s, fx, t, col) { const k = G(s), age = payAge(fx, t), S = (x, y) => add(c, [x * k, y * k]);
          yardFloor(c, k, col, t); dirt(c, -44, -44, -15, 44, k, 5);
          scrapPile(S(-31, -30), 8, k, 2); scrapPile(S(-33, 0), 9, k, 13); wreck(S(-32, 34), 0.05, k);
          warehouse(S(33, 0), 40, 9.5, Math.PI / 2, 4, age, k); crates(S(4, 32), 2, 2, k);
          conveyor(S(10, -8), S(23, -8), t, k);
          stack(S(0, -8), 14, [], t, age, k);
          feedLine(S, k, t);                                                                                        // round 3 (owner): crane -> belt -> furnace, all drawn over the stack
          smoke(S(0, -8), 14, t, k); } },
      { key: "C", name: "Yard Corner", muzzle: 0, fixed: true, parts: { junk: [10, 18], mouth: [-29, -29], door: [14, -22] },
        theme: "The warehouse runs along the top edge with its doors facing down, and the furnace stack stands in the top-left corner, fed by chutes from the open junkyard that fills the bottom-right (heaps, a tank hulk, a big grab crane).",
        draw(c, aim, s, fx, t, col) { const k = G(s), age = payAge(fx, t), S = (x, y) => add(c, [x * k, y * k]);
          yardFloor(c, k, col, t); dirt(c, -12, -14, 44, 44, k, 4); dirt(c, -44, 10, -12, 44, k, 8);
          scrapPile(S(-30, 30), 9, k, 3); scrapPile(S(34, 4), 7, k, 17); scrapPile(S(30, 34), 8, k, 21); wreck(S(4, 8), 0.3, k); crane(S(10, 30), 21, Math.PI * 1.1, t, k);
          warehouse(S(14, -34), 30, 9.5, 0, 4, age, k); crates(S(-34, -2), 2, 1, k);
          stack(S(-29, -29), 14, [Math.PI * 0.25, Math.PI * 0.55], t, age, k); smoke(S(-29, -29), 14, t, k); } },
    ],
    anims: [
      { key: "A", name: "Scrap Flow", desc: "Scrap bits arc from the junkyard into the stack and ingots slide from the stack to the warehouse, all the time; at each round's clear the warehouse doors roll up, a crate ships out and +100 rises.", period: 1, flight: 1, fx: () => ({}),
        persist: scrapAgent({ extra: (m, t, info, s, col, P, W) => { const k = s / 48;
            for (let i = 0; i < 3; i++) { const u = fmod(t * 0.45 + i / 3, 1), p = add(lerp(W(P.junk), W(P.mouth), u), [0, -Math.sin(Math.PI * u) * s * 0.3]), al = u > 0.85 ? (1 - u) / 0.15 : 1; disc(p, 2.4 * k + 1, A(OUTLINE, al)); disc(p, 2.4 * k, A(mix(RUST, METAL_L, 0.3 + 0.3 * rnd(i)), al)); }
            for (let i = 0; i < 2; i++) { const u = fmod(t * 0.5 + i / 2, 1), p = lerp(W(P.mouth), W(P.door), u), al = Math.min(1, u * 5, (1 - u) * 5); fill(p, rectPts(2.4, 1.3), A(GOLDC, al), 0, k); outline(p, rectPts(2.4, 1.3), A(OUTLINE, al), 1, 0, k); } },
          pay: (v, s, col, P, W) => { const k = s / 48, D = W(P.door), dir = norm(sub(W(P.mouth), D)), p = add(D, mul(dir, s * 0.3 * ease(Math.min(1, v * 2)))), al = Math.min(1, 2 - v * 2);
            plate(p, rectPts(3.4, 3.4), A(WOOD, al), 0, k, 1); glowDot(p, 1.2 * k, A(GOLDC, al)); txt(add(p, [0, -s * 0.3 - v * s * 0.5]), "+100", A(GOLDC, al), Math.max(11, s * 0.2)); } }) },
      { key: "B", name: "Melt and Pour", desc: "Embers rise from the stack's mouth all the time; at each round's clear its core flares white-hot and a fountain of coins vents from it with +100.", period: 1, flight: 1, fx: () => ({}),
        persist: scrapAgent({ extra: (m, t, info, s, col, P, W) => { const M = W(P.mouth); for (let i = 0; i < 8; i++) { const q = t * 0.9 + i / 8, u = fmod(q, 1), dx = (rnd(Math.floor(q) * 7 + i) - 0.5) * s * 0.35; disc(add(M, [dx * u, -u * s * 0.55]), 1.4 * (1 - u) + 0.3, [1, 0.7, 0.3, 1 - u]); } },
          pay: (v, s, col, P, W) => { const M = W(P.mouth); if (v < 0.25) glowDot(M, s * 0.22 * (1 - v / 0.25), HOTM); coinPop(M, v, s); } }) },
      { key: "C", name: "Wreck to Coin", desc: "Shows the kill bonus too: an enemy wrecked near the yard bursts, its hulk flies into the junkyard, and a coin with +5 jumps out of the stack; the round payout pops +100 over the warehouse.", period: 1, flight: 1, fx: () => ({}),
        persist: scrapAgent({ extra: (m, t, info, s, col, P, W) => { const near = info.all.filter((e) => !e.air && distTo(e.p, info.c) < s * 3.1);
            if (near.length && (!m.kill || t - m.kill.t0 > 2)) { const e = near[Math.floor(rnd(Math.floor(t)) * near.length)]; m.kill = { t0: t, p: e.p.slice() }; }
            if (m.kill) { const v = (t - m.kill.t0) / 0.9, J = W(P.junk), M = W(P.mouth);
              if (v < 0.33) blast(m.kill.p, v / 0.33, s, col, 0.25);
              if (v < 1) { const p = add(lerp(m.kill.p, J, v), [0, -Math.sin(Math.PI * v) * s * 0.5]); fill(p, rectPts(3.2, 2), mix(RUST, METAL, 0.3), v * 6, s / 48); outline(p, rectPts(3.2, 2), OUTLINE, 1, v * 6, s / 48); }
              const w = (t - m.kill.t0 - 0.9) / 0.9; if (w > 0 && w < 1) { const p = add(M, [w * s * 0.15, -Math.sin(Math.PI * Math.min(1, w * 1.2)) * s * 0.45]); disc(p, s * 0.05 + 1, A(OUTLINE, 1 - w * 0.5)); disc(p, s * 0.05, A(GOLDC, 1 - w * 0.5)); txt(add(p, [0, -s * 0.12]), "+5", A(GOLDC, 1 - w), Math.max(9, s * 0.15)); } } },
          pay: (v, s, col, P, W) => coinPop(W(P.door), v, s) }) },
    ] },
];
// Round 3 (owner): "Move the crane to where it can move scrap to the conveyer belt where it can be fall off the conveyer belt into the furnace".
// Round 2 (owner, 2026-10-19): look B Production Line, animation B Melt and Pour; note "Make sure the crane bar is over top of the smelter" (the crane is now drawn after the stack).
TOWERS[0].looks = TOWERS[0].looks.filter((l) => l.key === "B"); TOWERS[0].anims = TOWERS[0].anims.filter((a) => a.key === "B");
const DEFAULTS = { scrap: { look: "B", anim: "B" } };
