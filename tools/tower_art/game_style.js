// ---- Shared in-game tower style for the tower art pages (mirrors scripts/view/Draw.gd) ----------------------------
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

