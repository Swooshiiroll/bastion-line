// ---- Tower art page 1: towers 1-5, in the style of today's in-game towers (owner, 2026-10-16) -----------
// Dark gunmetal armour lit from the upper left (bevelled plates, rivets, shaded barrels and domes), the hex deck
// every tower stands on, and one glowing accent colour per tower, as in scripts/view/Draw.gd. Earlier rounds
// (modern military, then sleek sci-fi) were scrapped by the owner; they're in git history.
const PAGE = { title: "Tower art page 1 (towers 1-5)", store: "bl-tower-art-1-game-v1" };

// ---- Game units: drawings use Draw.gd's pixel sizes (a tile is 48 px), scaled to the preview ----------------
const G = (s) => s / 48;
const P = (c, aim, k, x, y) => add(c, rot([x * k, y * k], aim)); // x along the aim, y to the side, in game px
const AMMO = [0.4, 0.42, 0.25, 1], BORE = [0.04, 0.04, 0.05, 1], DARK_STRIPE = [0.06, 0.06, 0.06, 1];

// The hex deck every tower stands on (Draw._pad): bevelled armour, corner bolts, vents, status LEDs, the accent
// trim that breathes, and one tier pip.
function deck(c, k, col, t) {
  const hex = ngon(6, 1);
  ellipse(add(c, [0, 6 * k]), 21 * k, 9 * k, [0, 0, 0, 0.35]);
  fill(c, hex, OUTLINE, 0, 20.5 * k); plate(c, hex, lt(METAL_D, 0.05), 0, 19.2 * k, 1); fill(c, hex, METAL, 0, 15.6 * k);
  outline(c, hex, [0, 0, 0, 0.45], 1, 0, 15.6 * k); outline(c, hex, A(col, 0.5 + 0.2 * Math.sin(t * 2.2)), 1.35 * k, 0, 17.6 * k);
  for (const q of xform(c, hex, 0, 17.6 * k)) { disc(q, 1.5 * k, OUTLINE); disc(q, 1.0 * k, METAL_L); }
  for (let i = 0; i < 3; i++) { const y = c[1] - 13 * k + i * 2.2 * k; line([c[0] - 13.5 * k, y], [c[0] - 10 * k, y], [0, 0, 0, 0.5], 1); line([c[0] + 10 * k, y], [c[0] + 13.5 * k, y], [0, 0, 0, 0.5], 1); }
  disc(add(c, [-9 * k, 11 * k]), k, [0.4, 1, 0.5, fmod(t * 0.9, 2) < 0.12 ? 0.95 : 0.45]); disc(add(c, [9 * k, 11 * k]), k, A(col, 0.8));
  rect(c[0] - 3 * k, c[1] + 14.4 * k, 6 * k, 3.2 * k, OUTLINE); rect(c[0] - 2.4 * k, c[1] + 15 * k, 4.8 * k, 2 * k, col);
}
// Hazard striping along one side of a part, alternating accent and black (Draw._missile).
function hazard(c, aim, k, x0, x1, y, col, w) { const n = Math.max(2, Math.round((x1 - x0) / 2));
  for (let i = 0; i < n; i++) { const x = x0 + (x1 - x0) * (i + 0.5) / n; line(P(c, aim, k, x - 0.8, y), P(c, aim, k, x + 0.8, y), i % 2 ? DARK_STRIPE : A(col, 0.95), (w || 1.8) * k); } }
// A barrel's open end: dark bore that glows in the accent colour as it fires (Draw._flak).
function muzzleEnd(p, k, w, col, f) { disc(p, w * 0.6 * k, BORE); disc(p, w * 0.45 * k, A(col, Math.min(1, 0.3 + 3 * f))); if (f > 0) glowDot(p, (1.2 + 6 * f) * k, A(col, f)); }

// ---- Shared effects (s = preview px per tile) -------------------------------------------------------------
const lerp = (a, b, u) => [a[0] + (b[0] - a[0]) * u, a[1] + (b[1] - a[1]) * u];
const decay = (since, len) => (since >= 0 && since < len ? 1 - since / len : 0);
function firedBarrel(fx, i, len) { return fx.barrel === i && fx.barrelSince < (len || 0.12) ? 1 - fx.barrelSince / (len || 0.12) : 0; }
function smokePuff(p, v, s, a) { if (v <= 0 || v >= 1) return; disc(add(p, [0, -v * s * 0.25]), s * (0.1 + v * 0.22), [0.55, 0.57, 0.6, (a || 0.4) * (1 - v)]); }
function blast(p, v, s, col, size) { if (v < 0 || v >= 1) return; const r = s * (size || 0.4);
  disc(p, r * (0.35 + v * 0.7), A([1, 0.85, 0.5, 1], 0.75 * (1 - v))); ring(p, r * (0.5 + v * 1.1), A(col, 0.85 * (1 - v)), 2); smokePuff(p, v, s, 0.35); }
function spark(p, v, s, col) { if (v < 0.35) glowDot(p, s * 0.07 * (1 - v / 0.35), col); }
function tracer(from, to, u, col, w, len) { const a = lerp(from, to, Math.max(0, u - (len || 0.15))), b = lerp(from, to, u); line(a, b, A(col, 0.9), w || 2); line(a, b, [1, 1, 1, 0.8], (w || 2) * 0.4); }
function beam(from, to, w, col, k) { line(from, to, A(col, 0.3 * k), w * 2.6); line(from, to, A(col, 0.9 * k), w); line(from, to, [1, 1, 1, 0.8 * k], Math.max(1, w * 0.35)); glowDot(to, w * 1.3, A(col, k)); }
// A mortar shell: a dark round with a glowing fuse, arcing high; optional glowing trail.
function shell(from, to, u, s, col, z, trail) { const k = G(s) * (z || 1), arcH = (h) => Math.sin(Math.PI * h) * s * 0.85, p = lerp(from, to, u);
  ellipse(p, 3 * k, 1.5 * k, [0, 0, 0, 0.3]);
  if (trail) for (let i = 4; i >= 1; i--) { const v = Math.max(0, u - i * 0.035); disc(add(lerp(from, to, v), [0, -arcH(v)]), (1 + i * 0.45) * k, A(col, 0.32 - 0.06 * i)); }
  const a = add(p, [0, -arcH(u)]); orb(a, 2.6 * k, METAL_L); glowDot(a, 1.1 * k, col); }
// A rocket as the in-game loaded missiles look: pale body, red nose, grey fins, a hot exhaust and a smoke trail.
function missile(p, dir, k, col) {
  for (const sg of [-1, 1]) fill(p, [[-1.5, sg * 1.1], [-4.2, sg * 2.8], [-4.6, sg * 2.8], [-4.2, sg * 1.1]], METAL_L, dir, k);
  solid(p, [[4.6, 0], [2.7, 1.35], [-4.2, 1.35], [-4.2, -1.35], [2.7, -1.35]], [0.86, 0.88, 0.92, 1], dir, k, 0.8);
  fill(p, [[4.6, 0], [2.9, 1.35], [2.9, -1.35]], [1, 0.32, 0.25, 1], dir, k); glowDot(add(p, mul(fa(dir), -5 * k)), 1.2 * k, col); }
function rocketPath(from, to, u, s, col, idx, z, bendK) { const k = G(s) * (z || 1), bend = (bendK ?? 1) * (idx % 2 ? 1 : -1) * (0.28 + 0.1 * (idx % 3)) * s;
  const mid = add(lerp(from, to, 0.5), mul(orth(norm(sub(to, from))), bend)), q = (x) => lerp(lerp(from, mid, x), lerp(mid, to, x), x);
  for (let i = 6; i >= 1; i--) disc(q(Math.max(0, u - i * 0.035)), (1.2 + i * 0.55) * k, [0.62, 0.64, 0.66, 0.34 - i * 0.045]);
  const p = q(u), pb = q(Math.max(0, u - 0.04)); missile(p, Math.atan2(p[1] - pb[1], p[0] - pb[0]), k, col); }
// Loaded rocket noses showing in the tube mouths; they're gone after a salvo and slide back in as it reloads.
function noses(c, aim, k, tubes, fx, r) { const ready = fx.ready ?? 1; if (ready <= 0.05) return;
  for (const [x, y] of tubes) { const p = P(c, aim, k, x, y); orb(p, (r || 1.7) * k * ready, [0.86, 0.88, 0.92, 1]); disc(add(p, mul(fa(aim), 0.5 * k)), (r || 1.7) * 0.45 * k * ready, [1, 0.32, 0.25, 1]); } }

const TOWERS = [
  // 1. Gun Turret ---------------------------------------------------------------------------------------
  { id: "gun", num: 1, name: "Gun Turret", cls: "Assault", weapon: "Ballistic", hits: "both", color: [0.30, 0.90, 1.00, 1],
    desc: "A basic rotating machine gun turret. \"It's a machine gun, Private!\" Steady medium rounds; the cheap starter. (Colour: today's Pulse Turret cyan.)",
    looks: [
      { key: "A", name: "Shielded Gun Mount", muzzle: 20 / 48, theme: "A square armoured gun body behind an angled gun shield; one heavy barrel with cooling-jacket rings pokes through, fed by a belt from a side ammo box.",
        draw(c, aim, s, fx, t, col) { const k = G(s), r = fx.recoil * 2.5; deck(c, k, col, t);
          plate(P(c, aim, k, -4, -9.5), rectPts(3.4, 2.4), AMMO, aim, k, 1); line(P(c, aim, k, -2, -7.5), P(c, aim, k, 2, -3), A([1, 0.78, 0.3, 1], 0.75), 1.3 * k);
          bar(P(c, aim, k, 4 - r, 0), P(c, aim, k, 20 - r, 0), 3.4 * k, METAL_L);
          for (const x of [12, 15.5]) { bar(P(c, aim, k, x - r, -2.6), P(c, aim, k, x - r, 2.6), 1.5 * k, lt(METAL_D, 0.15)); line(P(c, aim, k, x - r, -2), P(c, aim, k, x - r, 2), A(col, 0.95), 0.8 * k); }
          muzzleEnd(P(c, aim, k, 20 - r, 0), k, 3.4, col, fx.flash);
          plate(c, rectPts(6.5, 6.5), METAL_L, aim, k, 1.2); rivets(c, rectPts(6.5, 6.5), aim, k, 0.75, 0.8 * k);
          plate(P(c, aim, k, 8, 0), [[1.6, -7.5], [1.6, 7.5], [-1.4, 6], [-1.4, -6]], lt(METAL_L, 0.05), aim, k, 1.1);
          orb(P(c, aim, k, -2, 2.5), 2.4 * k, METAL); glowDot(P(c, aim, k, -1.2, 2.5), 1.1 * k, col); } },
      { key: "B", name: "Twin Gun Nest", muzzle: 18 / 48, muzzles: [[18 / 48, -4 / 48], [18 / 48, 4 / 48]], theme: "An armoured dome turret with a gun on each flank, firing alternately; two belt feeds run back to ammo boxes behind the dome.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t);
          for (const y of [-6.5, 6.5]) plate(P(c, aim, k, -8.5, y), rectPts(2.6, 3), AMMO, aim, k, 1);
          [-4, 4].forEach((y, i) => { const r = firedBarrel(fx, i, 0.14) * 2.5; bar(P(c, aim, k, 2 - r, y), P(c, aim, k, 18 - r, y), 2.6 * k, METAL_L);
            bar(P(c, aim, k, 11 - r, y - 2), P(c, aim, k, 11 - r, y + 2), 1.3 * k, lt(METAL_D, 0.15)); muzzleEnd(P(c, aim, k, 18 - r, y), k, 2.6, col, firedBarrel(fx, i, 0.08)); });
          for (const y of [-4.5, 4.5]) line(P(c, aim, k, -6.5, y * 1.4), P(c, aim, k, -1, y), A([1, 0.78, 0.3, 1], 0.7), 1.1 * k);
          plate(c, ngon(8, 1, Math.PI / 8), METAL_L, aim, 7.4 * k, 1.2); orb(c, 5 * k, METAL); rivets(c, ngon(4, 1, Math.PI / 4), aim, 7.4 * k, 0.82, 0.75 * k);
          strip(P(c, aim, k, 2.5, -2), P(c, aim, k, 2.5, 2), 0.8 * k, col); } },
      { key: "C", name: "Rotary Gun", muzzle: 20 / 48, theme: "A four-barrel rotary gun in a shrouded cluster that spins up while firing, a drum magazine on its flank and a cooling vent block behind.",
        draw(c, aim, s, fx, t, col) { const k = G(s), r = fx.recoil * 1.5; deck(c, k, col, t); const spin = t * (fx.recoil > 0 || fx.flash > 0 ? 30 : 3);
          plate(P(c, aim, k, -8, 0), rectPts(3, 5.5), lt(METAL_D, 0.1), aim, k, 1); for (let i = 0; i < 3; i++) line(P(c, aim, k, -9.5 + i * 1.5, -4), P(c, aim, k, -9.5 + i * 1.5, 4), A(col, 0.5 + 0.4 * (i === 2)), 0.9 * k);
          const bs = [0, 1, 2, 3].map((i) => ({ y: Math.sin(spin + i * TAU / 4) * 3.4, z: Math.cos(spin + i * TAU / 4) })).sort((a, b) => a.z - b.z);
          for (const b of bs) bar(P(c, aim, k, 5 - r, b.y), P(c, aim, k, 19 - r, b.y), 1.8 * k, mix(METAL_D, METAL_L, 0.5 + 0.5 * b.z));
          for (const x of [8, 18]) bar(P(c, aim, k, x - r, -4.8), P(c, aim, k, x - r, 4.8), 1.6 * k, METAL_L);
          muzzleEnd(P(c, aim, k, 20 - r, 0), k, 3, col, fx.flash);
          orb(P(c, aim, k, -1, 8.5), 4.2 * k, METAL); ring(P(c, aim, k, -1, 8.5), 2.8 * k, A(col, 0.7), 1 * k);
          plate(c, ngon(6, 1, 0), METAL_L, aim, 6.8 * k, 1.2); orb(c, 3.6 * k, METAL); glowDot(P(c, aim, k, 1.2, 0), 1.2 * k, col); } },
    ],
    anims: [
      { key: "A", name: "Single Shots", desc: "Steady single rounds: the barrel kicks back, the bore flashes cyan and a tracer streaks to the target.", period: 0.8, flight: 0.18,
        fx: (since) => ({ recoil: decay(since, 0.15), flash: decay(since, 0.08) }), shot: (f, to, u, s, col) => tracer(f, to, u, col, 2.2, 0.25), impact: (to, v, s, col) => spark(to, v, s, col) },
      { key: "B", name: "Three-Round Burst", desc: "Quick three-round bursts with a pause between; each round kicks the barrel.", period: 1.4, burst: 3, gap: 0.09, flight: 0.16,
        fx: (since) => { const on = since < 0.3 && fmod(since, 0.09) < 0.05 ? 1 : 0; return { recoil: on * 0.7, flash: on }; },
        shot: (f, to, u, s, col) => tracer(f, to, u, col, 1.8, 0.22), impact: (to, v, s, col) => spark(to, v, s, col) },
      { key: "C", name: "Rapid Stream", desc: "A fast, steady stream of rounds; light recoil, the bore glowing constantly and sparks dancing on the target.", period: 0.2, flight: 0.15,
        fx: (since) => ({ recoil: decay(since, 0.1) * 0.5, flash: 0.35 + 0.65 * decay(since, 0.06) }), shot: (f, to, u, s, col) => tracer(f, to, u, col, 1.4, 0.2),
        impact: (to, v, s, col) => { if (v < 0.25) disc(add(to, mul(fa(v * 40), s * 0.1 * v * 4)), 1.3, A([1, 0.9, 0.6, 1], 1 - v * 4)); } },
    ] },

  // 2. Mortar Tower -------------------------------------------------------------------------------------
  { id: "mortar", num: 2, name: "Mortar Tower", cls: "Assault", weapon: "Explosive", hits: "ground", color: [1.00, 0.55, 0.20, 1],
    desc: "Lobs high-explosive shells at nearby enemies. \"Tools.\" Short range, heavy splash, ground only. (Colour: today's Plasma Mortar orange.)",
    looks: [
      { key: "A", name: "Turntable Mortar", muzzle: 8 / 48, theme: "A stout armoured tube angled at the sky (from above: its wide bore) on a bolted turntable, two shell canisters racked behind it.",
        draw(c, aim, s, fx, t, col) { const k = G(s), r = fx.recoil * 2; deck(c, k, col, t);
          disc(c, 12.5 * k, OUTLINE); disc(c, 11.5 * k, lt(METAL_D, 0.08)); ring(c, 9.5 * k, [0, 0, 0, 0.4], 1);
          for (let i = 0; i < 8; i++) { const q = add(c, mul(fa(i * TAU / 8), 10.6 * k)); disc(q, 1.1 * k, OUTLINE); disc(q, 0.7 * k, METAL_L); }
          for (const y of [-5, 5]) { orb(P(c, aim, k, -7, y), 2.6 * k, mix(METAL_L, col, 0.3)); disc(P(c, aim, k, -7, y), 0.9 * k, A(col, 0.8)); }
          bar(P(c, aim, k, -2 - r, 0), P(c, aim, k, 8 - r, 0), 9 * k, METAL_L); const b = P(c, aim, k, 8 - r, 0);
          disc(b, 5.6 * k, OUTLINE); disc(b, 5 * k, METAL_L); ring(b, 4.3 * k, lt(METAL_L, 0.3), 0.8 * k); disc(b, 3.5 * k, BORE); disc(b, 2.6 * k, A(col, 0.25 + 0.75 * fx.flash)); if (fx.flash > 0) glowDot(b, 3 * k * fx.flash, col); } },
      { key: "B", name: "Twin-Tube Mortar", muzzle: 7 / 48, muzzles: [[7 / 48, -5 / 48], [7 / 48, 5 / 48]], theme: "Two mortar tubes side by side on an armoured sled with hydraulic elevation rams; they fire one after the other.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t);
          plate(c, rectPts(9, 11), METAL_L, aim, k, 1.2); rivets(c, rectPts(9, 11), aim, k, 0.85, 0.75 * k); hazard(c, aim, k, -8, 8, -11.6, col, 1.4);
          for (const y of [-5, 5]) bar(P(c, aim, k, -8, y), P(c, aim, k, -1, y), 2 * k, lt(METAL_D, 0.2));
          [-5, 5].forEach((y, i) => { const f = firedBarrel(fx, i, 0.2), b = P(c, aim, k, 7 - f * 1.5, y);
            disc(b, 4.6 * k, OUTLINE); disc(b, 4.1 * k, METAL); ring(b, 3.5 * k, lt(METAL_L, 0.2), 0.8 * k); disc(b, 2.8 * k, BORE); disc(b, 2 * k, A(col, 0.25 + 0.75 * f)); if (f > 0) glowDot(b, 2.6 * k * f, col); });
          glowDot(P(c, aim, k, -4, 0), 1.2 * k, col); } },
      { key: "C", name: "Braced Siege Mortar", muzzle: 9 / 48, theme: "A heavy mortar braced on four hydraulic legs with foot pads, a recoil spade behind and a big bore; the whole mount dips when it fires.",
        draw(c, aim, s, fx, t, col) { const k = G(s), r = fx.recoil * 2.5; deck(c, k, col, t);
          for (let i = 0; i < 4; i++) { const a = Math.PI / 4 + i * Math.PI / 2, f = P(c, aim, k, Math.cos(a) * 15, Math.sin(a) * 15);
            bar(P(c, aim, k, Math.cos(a) * 6, Math.sin(a) * 6), f, 3 * k, lt(METAL_D, 0.12)); bar(P(c, aim, k, Math.cos(a) * 7, Math.sin(a) * 7), P(c, aim, k, Math.cos(a) * 11, Math.sin(a) * 11), 1.3 * k, METAL_L);
            plate(f, rectPts(2, 2), METAL_L, aim, k, 0.9); }
          plate(P(c, aim, k, -10, 0), [[1.5, -5], [1.5, 5], [-1.5, 4], [-1.5, -4]], METAL_L, aim, k, 1); hazard(c, aim, k, -11, -9, 0, col, 1);
          plate(c, ngon(8, 1, Math.PI / 8), METAL, aim, 8.5 * k, 1.2);
          bar(P(c, aim, k, -1 - r, 0), P(c, aim, k, 9 - r, 0), 11 * k, METAL_L); const b = P(c, aim, k, 9 - r, 0);
          disc(b, 6.8 * k, OUTLINE); disc(b, 6.2 * k, METAL_L); ring(b, 5.4 * k, lt(METAL_L, 0.3), 1 * k); disc(b, 4.4 * k, BORE); disc(b, 3.3 * k, A(col, 0.25 + 0.75 * fx.flash)); if (fx.flash > 0) glowDot(b, 3.6 * k * fx.flash, col); } },
    ],
    anims: [
      { key: "A", name: "High Lob", desc: "One shell arcs high with a smoke puff at the bore and lands in an orange blast.", period: 2.2, flight: 1.0,
        fx: (since) => ({ recoil: decay(since, 0.3), flash: decay(since, 0.18) }),
        shot: (f, to, u, s, col) => { if (u < 0.35) smokePuff(f, u / 0.35, s, 0.5); shell(f, to, u, s, col); }, impact: (to, v, s, col) => blast(to, v, s, col, 0.45) },
      { key: "B", name: "Double Tap", desc: "Two shells in quick succession, each bore kicking in turn; two smaller blasts.", period: 2.4, burst: 2, gap: 0.35, flight: 0.95,
        fx: (since) => ({ recoil: decay(since, 0.25) + decay(since - 0.35, 0.25), flash: decay(since, 0.15) + decay(since - 0.35, 0.15) }),
        shot: (f, to, u, s, col) => { if (u < 0.3) smokePuff(f, u / 0.3, s, 0.4); shell(f, to, u, s, col, 0.85); }, impact: (to, v, s, col) => blast(to, v, s, col, 0.35) },
      { key: "C", name: "Heavy Shell", desc: "A slow, heavy shell with a glowing trail, a big kick and a long smoke plume; a wide blast with a shock ring.", period: 3.0, flight: 1.3,
        fx: (since) => ({ recoil: decay(since, 0.5), flash: decay(since, 0.3) }),
        shot: (f, to, u, s, col) => { if (u < 0.5) smokePuff(f, u / 0.5, s * 1.3, 0.55); shell(f, to, u, s, col, 1.35, true); },
        impact: (to, v, s, col) => { blast(to, v, s, col, 0.6); if (v < 0.6) ring(to, s * (0.3 + v * 1.4), A([1, 0.9, 0.7, 1], 0.6 * (1 - v / 0.6)), 1.4); } },
    ] },

  // 3. Laser Tower --------------------------------------------------------------------------------------
  { id: "laser", num: 3, name: "Laser Tower", cls: "Assault", weapon: "Energy", hits: "both", color: [1.00, 0.30, 0.35, 1],
    desc: "A high-energy laser emitter on a rotating turret. \"It does more than just blind the enemy, that's for sure.\" A ramping beam that melts armour; it fires only once locked on. (Colour: today's Laser Lance red.)",
    looks: [
      { key: "A", name: "Lance Emitter", muzzle: 21 / 48, theme: "A hexagonal armoured hull with heat-sink fins on both flanks, a long lance barrel with focusing rings and a red light strip, and an emitter crystal at the tip.",
        draw(c, aim, s, fx, t, col) { const k = G(s), g = fx.glow || 0; deck(c, k, col, t);
          for (const y of [-1, 1]) for (let i = 0; i < 3; i++) bar(P(c, aim, k, -3 - 2.5 * i, y * 5), P(c, aim, k, -3 - 2.5 * i, y * 9), 1.3 * k, METAL_L);
          plate(c, [[7, 0], [1, 6], [-9, 5], [-11, 0], [-9, -5], [1, -6]], METAL_L, aim, k, 1.2);
          bar(P(c, aim, k, 4, 0), P(c, aim, k, 21, 0), 3 * k, METAL); strip(P(c, aim, k, 5, 0), P(c, aim, k, 21, 0), 0.6 * k, A(col, 0.35 + 0.6 * g));
          for (const x of [8, 12, 16]) bar(P(c, aim, k, x, -3.2), P(c, aim, k, x, 3.2), 1.5 * k, dk(col, 0.2));
          const tip = P(c, aim, k, 21, 0); solid(tip, [[3.8, 0], [0, 2.8], [-3.8, 0], [0, -2.8]], A(col, 0.85), aim, k, 1); glowDot(tip, (0.8 + 1.8 * g) * k, [1, 1, 1, 1]);
          orb(P(c, aim, k, -4, 0), 2.2 * k, dk(col, 0.3)); } },
      { key: "B", name: "Twin-Prong Emitter", muzzle: 16 / 48, theme: "Two conductor prongs reach forward from a capacitor block with charge bars; a red crystal floats between the prong tips and the beam leaves from it.",
        draw(c, aim, s, fx, t, col) { const k = G(s), g = fx.glow || 0; deck(c, k, col, t);
          plate(P(c, aim, k, -5, 0), rectPts(5, 7), METAL_L, aim, k, 1.2); rivets(P(c, aim, k, -5, 0), rectPts(5, 7), aim, k, 0.8, 0.7 * k);
          for (let i = 0; i < 3; i++) line(P(c, aim, k, -8 + i * 2, -4.5), P(c, aim, k, -8 + i * 2, 4.5), A(col, 0.4 + 0.2 * i + 0.4 * g), 1 * k);
          for (const y of [-4, 4]) { bar(P(c, aim, k, 0, y), P(c, aim, k, 18, y * 0.8), 2.4 * k, METAL); bar(P(c, aim, k, 3, y), P(c, aim, k, 6, y), 3 * k, dk(col, 0.25)); glowDot(P(c, aim, k, 18, y * 0.8), 0.8 * k, A(col, 0.5 + 0.5 * g)); }
          const cr = P(c, aim, k, 15 + Math.sin(t * 3) * 0.5, 0); arc(cr, 3.2 * k, aim - 1.5 + t * 2, aim + 1.5 + t * 2, A(col, 0.3 + 0.6 * g), 0.9 * k);
          solid(cr, [[2.6, 0], [0, 2], [-2.6, 0], [0, -2]], A(lt(col, 0.2), 0.9), aim, k, 0.9); glowDot(cr, (0.8 + 1.6 * g) * k, [1, 1, 1, 1]);
          orb(P(c, aim, k, -5, 0), 2.6 * k, METAL); glowDot(P(c, aim, k, -5, 0), 1 * k, col); } },
      { key: "C", name: "Focus Lens", muzzle: 17 / 48, theme: "A round armoured housing on a short, wide barrel ending in one big red focusing lens inside a pulsing ring; cooling ribs wrap the housing.",
        draw(c, aim, s, fx, t, col) { const k = G(s), g = fx.glow || 0; deck(c, k, col, t);
          for (let i = 0; i < 6; i++) { const a = aim + Math.PI * 0.55 + i * Math.PI * 0.18; bar(add(c, mul(fa(a), 7.5 * k)), add(c, mul(fa(a), 10.5 * k)), 1.6 * k, METAL_L); }
          bar(P(c, aim, k, 2, 0), P(c, aim, k, 13, 0), 6 * k, METAL); for (const x of [7, 10.5]) bar(P(c, aim, k, x, -3.8), P(c, aim, k, x, 3.8), 1.4 * k, dk(col, 0.2));
          orb(c, 8 * k, METAL_L); ring(c, 5.4 * k, METAL, 1.4 * k); ring(c, 4 * k, [0, 0, 0, 0.4], 0.8 * k); glowDot(c, 1.3 * k, col);
          const lens = P(c, aim, k, 15, 0); orb(lens, 4.6 * k, dk(col, 0.2)); glowDot(lens, (1.6 + 1.6 * g) * k, col); ring(lens, 6.2 * k, A(col, 0.45 + 0.35 * Math.sin(t * 8) * (0.4 + 0.6 * g)), 1.1 * k); } },
    ],
    anims: [
      { key: "A", name: "Steady Beam", lock: 0.6, desc: "Locks on first (a reticle closes on the target), then a steady red beam holds on it while the barrel's light strip glows full.", beam: true, period: 1,
        fx: (lock, p, on) => ({ glow: on ? 0.9 : 0 }), shot: (f, to, lock, s, col) => beam(f, to, 2.4 + 0.3 * Math.sin(lock * 30), col, 0.9) },
      { key: "B", name: "Pulse Beam", lock: 0.6, desc: "Locks on first, then fires in rapid pulses: the beam flares and dims four times a second, the emitter flashing with each pulse.", beam: true, period: 1,
        fx: (lock, p, on) => ({ glow: on ? 0.4 + 0.6 * (fmod(lock * 4, 1) < 0.5 ? 1 : 0) : 0 }),
        shot: (f, to, lock, s, col) => { const pl = fmod(lock * 4, 1) < 0.5; beam(f, to, pl ? 3 : 1.2, col, pl ? 1 : 0.45); if (pl) glowDot(f, s * 0.06, [1, 1, 1, 0.9]); } },
      { key: "C", name: "Ramp Burn", lock: 0.6, desc: "Locks on first, then the beam starts thin and thickens the longer it holds, with molten sparks spraying off the target.", beam: true, period: 1,
        fx: (lock, p, on) => ({ glow: on ? Math.min(1, 0.25 + lock / 2.5) : 0 }),
        shot: (f, to, lock, s, col, k, t) => { const g = Math.min(1, lock / 2.5); beam(f, to, 1.2 + g * 3.4, col, 0.6 + 0.4 * g);
          for (let i = 0; i < 2 + Math.round(g * 5); i++) { const a = t * 9 + i * 1.3, q = fmod(t * 3 + i * 0.2, 1); disc(add(to, mul(fa(a), s * 0.3 * q)), 1.4, A([1, 0.8, 0.5, 1], 1 - q)); } } },
    ] },

  // 4. Rocket Salvo -------------------------------------------------------------------------------------
  { id: "rocket", num: 4, name: "Rocket Salvo", cls: "Assault", weapon: "Explosive", hits: "both", color: [1.00, 0.85, 0.30, 1],
    desc: "Launches a volley of rockets at oncoming enemies. \"Instead of shooting bullets, it shoots very angry telephone poles that hate absolutely everything.\" Spread salvos, one rocket per enemy. (Colour: today's Missile Battery yellow.) All three launchers lie horizontal, rockets leaving from the front.",
    looks: [
      { key: "A", name: "Box Pod Launcher", muzzle: 11 / 48, muzzles: [[11 / 48, -5 / 48], [11 / 48, 0], [11 / 48, 5 / 48], [11 / 48, 0]], theme: "One armoured box pod lying along the aim, hazard-striped flanks and panel lines, three tube mouths across its front with the loaded rocket noses showing.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t); disc(c, 8 * k, OUTLINE); disc(c, 7.2 * k, METAL_D);
          plate(c, rectPts(11, 8.5), METAL_L, aim, k, 1.3); fill(c, rectPts(8.6, 6.4), METAL, aim, k); rivets(c, rectPts(11, 8.5), aim, k, 0.88, 0.8 * k);
          hazard(c, aim, k, -8, 8, -8.2, col); hazard(c, aim, k, -8, 8, 8.2, col);
          for (const x of [-3, 3]) line(P(c, aim, k, x, -6), P(c, aim, k, x, 6), [0, 0, 0, 0.35], 1);
          [-5, 0, 5].forEach((y, i) => { const p = P(c, aim, k, 10.5, y); disc(p, 2.4 * k, OUTLINE); disc(p, 2 * k, BORE); const f = firedBarrel(fx, i, 0.25) + (i === 1 ? firedBarrel(fx, 3, 0.25) : 0); if (f > 0) glowDot(p, 2.4 * k * f, col); });
          noses(c, aim, k, [[11, -5], [11, 0], [11, 5]], fx, 1.6); const h = P(c, aim, k, -8.5, 0); rect(h[0] - 1.6 * k, h[1] - 1.6 * k, 3.2 * k, 3.2 * k, OUTLINE); glowDot(h, 1.1 * k, col); } },
      { key: "B", name: "Twin Side Pods", muzzle: 9 / 48, muzzles: [[9 / 48, -12 / 48], [9 / 48, 12 / 48], [9 / 48, -8 / 48], [9 / 48, 8 / 48]], theme: "A domed gunner turret with a horizontal two-tube pod on each side arm, like an air-defence vehicle; the pods fire left, right, left, right.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t);
          for (const y of [-1, 1]) { bar(c, P(c, aim, k, 0, y * 10), 2.6 * k, METAL_L); plate(P(c, aim, k, 0, y * 10), rectPts(9, 3.8), METAL_L, aim, k, 1.1); hazard(c, aim, k, -7, 3, y * 13.4, col, 1.2);
            for (const x of [-4, 0, 4]) line(P(c, aim, k, x, y * 7), P(c, aim, k, x, y * 13), [0, 0, 0, 0.35], 1); }
          [[-12, 0], [12, 1], [-8, 2], [8, 3]].forEach(([y, i]) => { const p = P(c, aim, k, 8.5, y); disc(p, 1.9 * k, OUTLINE); disc(p, 1.5 * k, BORE); const f = firedBarrel(fx, i, 0.25); if (f > 0) glowDot(p, 2 * k * f, col); });
          noses(c, aim, k, [[9, -12], [9, 12], [9, -8], [9, 8]], fx, 1.3);
          plate(c, ngon(8, 1, Math.PI / 8), METAL_L, aim, 6.5 * k, 1.2); orb(c, 4.4 * k, METAL); plate(P(c, aim, k, 3.5, 0), rectPts(1, 2.4), [0.25, 0.4, 0.45, 1], aim, k, 0.6); } },
      { key: "C", name: "Quad Rail Pods", muzzle: 12 / 48, muzzles: [[12 / 48, -7.5 / 48], [12 / 48, 7.5 / 48], [12 / 48, -2.5 / 48], [12 / 48, 2.5 / 48]], theme: "Four slim round launch pods side by side on a cross frame, each holding one big rocket; a hazard-striped blast deflector behind.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t);
          plate(P(c, aim, k, -11, 0), rectPts(1.6, 11), METAL_L, aim, k, 1); hazard(c, aim, k, -12, -10, 0, col, 1.2);
          for (const x of [-4, 6]) bar(P(c, aim, k, x, -11), P(c, aim, k, x, 11), 2.4 * k, lt(METAL_D, 0.15));
          [[-7.5, 0], [7.5, 1], [-2.5, 2], [2.5, 3]].forEach(([y, i]) => { bar(P(c, aim, k, -8, y), P(c, aim, k, 11, y), 4.4 * k, METAL_L); const p = P(c, aim, k, 11.5, y);
            disc(p, 2.2 * k, OUTLINE); disc(p, 1.8 * k, BORE); const f = firedBarrel(fx, i, 0.25); if (f > 0) glowDot(p, 2.2 * k * f, col); });
          noses(c, aim, k, [[12, -7.5], [12, 7.5], [12, -2.5], [12, 2.5]], fx, 1.5); orb(c, 2.6 * k, METAL); glowDot(c, 1 * k, col); } },
    ],
    anims: [
      { key: "A", name: "Ripple Salvo", desc: "Four rockets leave one after another, each from its own tube, curving onto separate enemies on smoke trails; the tubes reload.", period: 2.6, burst: 4, gap: 0.16, multi: true, flight: 0.85,
        fx: (since) => ({ ready: since < 0.6 ? 0 : Math.min(1, (since - 0.6) / 1.2) }), shot: (f, to, u, s, col, k) => rocketPath(f, to, u, s, col, k), impact: (to, v, s, col) => blast(to, v, s, col, 0.35) },
      { key: "B", name: "Full Volley", desc: "Every tube fires at once in a burst of smoke behind the launcher; the rockets fan out together.", period: 2.6, burst: 4, gap: 0.02, multi: true, flight: 0.85,
        fx: (since) => ({ ready: since < 0.5 ? 0 : Math.min(1, (since - 0.5) / 1.4) }),
        shot: (f, to, u, s, col, k) => { if (u < 0.45) smokePuff(f, u / 0.45, s * 1.2, 0.45); rocketPath(f, to, u, s, col, k); }, impact: (to, v, s, col) => blast(to, v, s, col, 0.35) },
      { key: "C", name: "Heavy Rockets", desc: "Two big rockets, one per pair of tubes, flying nearly straight and hitting harder; heavy blasts.", period: 2.6, burst: 2, gap: 0.3, multi: true, flight: 0.7,
        fx: (since) => ({ ready: since < 0.7 ? 0 : Math.min(1, (since - 0.7) / 1.2) }),
        shot: (f, to, u, s, col, k) => rocketPath(f, to, u, s, col, k, 1.4, 0.3), impact: (to, v, s, col) => blast(to, v, s, col, 0.55) },
    ] },

  // 5. Anti-Aircraft Turret -----------------------------------------------------------------------------
  { id: "aa", num: 5, name: "Anti-Aircraft Turret", cls: "Assault", weapon: "Ballistic", hits: "air", color: [0.85, 1.00, 0.45, 1],
    desc: "A fully automatic anti-aircraft gun. \"We don't need a gun, or a nug!\" A direct-hit autocannon, air only. (Colour: today's Flak Battery lime.)",
    looks: [
      { key: "A", name: "Twin Autocannon", muzzle: 20 / 48, muzzles: [[20 / 48, -2.8 / 48], [20 / 48, 2.8 / 48]], theme: "Two long autocannon barrels in shrouds on an armoured mount, an ammo box feeding them and a tracking radar sweeping behind.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t);
          [-2.8, 2.8].forEach((y, i) => { const f = firedBarrel(fx, i, 0.12), r = f * 2.5; bar(P(c, aim, k, 2 - r, y), P(c, aim, k, 20 - r, y), 1.9 * k, METAL_L); muzzleEnd(P(c, aim, k, 20 - r, y), k, 1.9, col, f); });
          bar(P(c, aim, k, 6, -5), P(c, aim, k, 6, 5), 1.6 * k, lt(METAL_D, 0.15));
          const body = [[8, -6], [8, 6], [-7, 8], [-9, 0], [-7, -8]]; plate(c, body, METAL_L, aim, k, 1.2); rivets(c, body, aim, k, 0.7, 0.7 * k);
          plate(P(c, aim, k, -3, -9), rectPts(2.5, 2), AMMO, aim, k, 1);
          const d = P(c, aim, k, -6, 5); arc(d, 3.2 * k, t * 3, t * 3 + Math.PI, OUTLINE, 2.6 * k); arc(d, 3.2 * k, t * 3, t * 3 + Math.PI, A(col, 0.9), 1.4 * k); glowDot(P(c, aim, k, 2, 0), 1.5 * k, col); } },
      { key: "B", name: "Quad Flak Mount", muzzle: 18 / 48, muzzles: [[18 / 48, -6.5 / 48], [18 / 48, 6.5 / 48], [18 / 48, -3.5 / 48], [18 / 48, 3.5 / 48]], theme: "A wide mount with four barrels in two pairs, a gunner's dome in the middle and a radar dish turning at the back.",
        draw(c, aim, s, fx, t, col) { const k = G(s); deck(c, k, col, t);
          [[-6.5, 0], [6.5, 1], [-3.5, 2], [3.5, 3]].forEach(([y, i]) => { const f = firedBarrel(fx, i, 0.12), r = f * 2.2; bar(P(c, aim, k, 4 - r, y), P(c, aim, k, 18 - r, y), 1.5 * k, METAL_L); muzzleEnd(P(c, aim, k, 18 - r, y), k, 1.5, col, f); });
          for (const x of [7, 12]) bar(P(c, aim, k, x, -8), P(c, aim, k, x, 8), 1.3 * k, lt(METAL_D, 0.15));
          plate(c, rectPts(7, 10), METAL_L, aim, k, 1.2); rivets(c, rectPts(7, 10), aim, k, 0.8, 0.7 * k); for (const y of [-8.5, 8.5]) plate(P(c, aim, k, -2, y), rectPts(3, 1.6), AMMO, aim, k, 0.9);
          orb(c, 3.8 * k, METAL); glowDot(P(c, aim, k, 1.4, 0), 1.1 * k, col);
          const d = P(c, aim, k, -9.5, 0); disc(d, 2.6 * k, OUTLINE); disc(d, 2 * k, METAL); line(d, add(d, mul(fa(t * 2.5), 4 * k)), METAL_L, 1.8 * k); glowDot(add(d, mul(fa(t * 2.5), 4 * k)), 0.9 * k, col); } },
      { key: "C", name: "Heavy Flak Cannon", muzzle: 23 / 48, theme: "One long heavy cannon with a slotted muzzle brake and recoil springs, a big ammo crate, and a stereo rangefinder bar across the back.",
        draw(c, aim, s, fx, t, col) { const k = G(s), r = fx.recoil * 3; deck(c, k, col, t);
          bar(P(c, aim, k, -7, -12), P(c, aim, k, -7, 12), 2.2 * k, METAL); for (const y of [-12, 12]) { orb(P(c, aim, k, -7, y), 1.9 * k, METAL_L); glowDot(P(c, aim, k, -6.2, y), 0.8 * k, col); }
          bar(P(c, aim, k, 2 - r, 0), P(c, aim, k, 21 - r, 0), 3.6 * k, METAL_L); for (const x of [6, 8]) ring(P(c, aim, k, x - r * 0.5, 0), 2.6 * k, METAL_L, 1 * k);
          plate(P(c, aim, k, 21.5 - r, 0), rectPts(1.6, 2.8), METAL, aim, k, 1); line(P(c, aim, k, 21.5 - r, -2.8), P(c, aim, k, 21.5 - r, 2.8), [0, 0, 0, 0.5], 0.8 * k);
          muzzleEnd(P(c, aim, k, 23 - r, 0), k, 2.6, col, fx.flash);
          plate(c, ngon(8, 1, Math.PI / 8), METAL_L, aim, 7.5 * k, 1.2); rivets(c, ngon(8, 1, Math.PI / 8), aim, 7.5 * k, 0.82, 0.6 * k); plate(P(c, aim, k, -1, 9.5), rectPts(4, 2.6), AMMO, aim, k, 1);
          orb(c, 3.6 * k, METAL); glowDot(P(c, aim, k, 1.2, 0), 1.2 * k, col); } },
    ],
    anims: [
      { key: "A", name: "Alternating Barrels", desc: "The barrels fire in turn, each kicking back as its tracer leaves it; small flashes on the flyer.", period: 0.38, flight: 0.22,
        fx: (since) => ({ recoil: decay(since, 0.12), flash: decay(since, 0.07) }), shot: (f, to, u, s, col) => tracer(f, to, u, col, 1.8, 0.22), impact: (to, v, s, col) => spark(to, v, s, col) },
      { key: "B", name: "Flak Bursts", desc: "Shells fly up in pairs and burst beside the flyer in dark smoke puffs with an orange flash, as proximity flak does.", period: 0.9, burst: 2, gap: 0.12, flight: 0.3,
        fx: (since) => ({ recoil: decay(since, 0.12) + decay(since - 0.12, 0.12), flash: decay(since, 0.07) + decay(since - 0.12, 0.07) }),
        shot: (f, to, u, s, col) => { const p = lerp(f, to, u); disc(p, 2, OUTLINE); disc(p, 1.4, col); },
        impact: (to, v, s, col) => { const p = add(to, [s * 0.12, -s * 0.08]); if (v < 0.2) glowDot(p, s * 0.1 * (1 - v * 5), [1, 0.7, 0.3, 1]); disc(add(p, [0, -v * s * 0.15]), s * (0.1 + v * 0.18), [0.22, 0.22, 0.24, 0.65 * (1 - v)]); } },
      { key: "C", name: "Lead Stream", desc: "A long, fast stream of tracers walked onto the flyer, the barrels hammering in turn.", period: 0.12, flight: 0.25,
        fx: (since) => ({ recoil: decay(since, 0.08) * 0.6, flash: decay(since, 0.06) }), shot: (f, to, u, s, col) => tracer(f, to, u, col, 1.3, 0.3), impact: (to, v, s, col) => spark(to, v, s * 0.7, col) },
    ] },
];
const DEFAULTS = {};
