// ---- Colours and vectors (mirrors Draw.gd) -------------------------------------------------
const OUTLINE = [0.03, 0.04, 0.06, 0.95], METAL_D = [0.10, 0.115, 0.14, 1], METAL = [0.18, 0.20, 0.24, 1], METAL_L = [0.30, 0.33, 0.38, 1];
const LIGHT = [-0.6, -0.8];
const WHITE = [1, 1, 1, 1];
const A = (c, a) => [c[0], c[1], c[2], a];
const dk = (c, k) => [c[0] * (1 - k), c[1] * (1 - k), c[2] * (1 - k), c[3] ?? 1];
const lt = (c, k) => [c[0] + (1 - c[0]) * k, c[1] + (1 - c[1]) * k, c[2] + (1 - c[2]) * k, c[3] ?? 1];
const mix = (a, b, k) => [a[0] + (b[0] - a[0]) * k, a[1] + (b[1] - a[1]) * k, a[2] + (b[2] - a[2]) * k, (a[3] ?? 1) + ((b[3] ?? 1) - (a[3] ?? 1)) * k];
const css = c => `rgba(${Math.round(c[0] * 255)},${Math.round(c[1] * 255)},${Math.round(c[2] * 255)},${c[3] ?? 1})`;
const add = (a, b) => [a[0] + b[0], a[1] + b[1]];
const sub = (a, b) => [a[0] - b[0], a[1] - b[1]];
const mul = (a, k) => [a[0] * k, a[1] * k];
const fa = a => [Math.cos(a), Math.sin(a)];
const orth = v => [v[1], -v[0]];
const dot = (a, b) => a[0] * b[0] + a[1] * b[1];
const norm = v => { const l = Math.hypot(v[0], v[1]) || 1; return [v[0] / l, v[1] / l]; };
const rot = (p, r) => [p[0] * Math.cos(r) - p[1] * Math.sin(r), p[0] * Math.sin(r) + p[1] * Math.cos(r)];
const TAU = Math.PI * 2;
const clamp01 = x => Math.max(0, Math.min(1, x));
const ease = x => { x = clamp01(x); return x * x * (3 - 2 * x); };
const fmod = (a, b) => ((a % b) + b) % b;

// ---- Drawing primitives (one-to-one with Draw.gd) ------------------------------------------
let X = null; // current 2D context
function disc(c, r, col) { if (r <= 0) return; X.fillStyle = css(col); X.beginPath(); X.arc(c[0], c[1], r, 0, TAU); X.fill(); }
function arc(c, r, a0, a1, col, w) { X.strokeStyle = css(col); X.lineWidth = w > 0 ? w : 1; X.beginPath(); X.arc(c[0], c[1], Math.max(0.01, r), a0, a1); X.stroke(); }
function ring(c, r, col, w = 1.5) { arc(c, r, 0, TAU, col, w); }
function line(a, b, col, w = 1) { X.strokeStyle = css(col); X.lineWidth = w > 0 ? w : 1; X.beginPath(); X.moveTo(a[0], a[1]); X.lineTo(b[0], b[1]); X.stroke(); }
function polyline(pts, col, w = 1) { if (pts.length < 2) return; X.strokeStyle = css(col); X.lineWidth = w > 0 ? w : 1; X.beginPath(); X.moveTo(pts[0][0], pts[0][1]); for (let i = 1; i < pts.length; i++) X.lineTo(pts[i][0], pts[i][1]); X.stroke(); }
function poly(pts, col) { X.fillStyle = css(col); X.beginPath(); X.moveTo(pts[0][0], pts[0][1]); for (let i = 1; i < pts.length; i++) X.lineTo(pts[i][0], pts[i][1]); X.closePath(); X.fill(); }
function xform(c, pts, r, s) { return pts.map(p => add(c, rot(mul(p, s), r))); }
function fill(c, pts, col, r = 0, s = 1) { poly(xform(c, pts, r, s), col); }
function outline(c, pts, col, w, r = 0, s = 1) { const p = xform(c, pts, r, s); p.push(p[0]); polyline(p, col, w); }
function solid(c, pts, col, r = 0, s = 1, lw = 1.2) { fill(c, pts, col, r, s); outline(c, pts, OUTLINE, lw, r, s); }
function ellipse(c, rx, ry, col) { X.fillStyle = css(col); X.beginPath(); X.ellipse(c[0], c[1], Math.max(0.01, rx), Math.max(0.01, ry), 0, 0, TAU); X.fill(); }
function rect(x, y, w, h, col) { X.fillStyle = css(col); X.fillRect(x, y, w, h); }
function ngon(n, r, ph = 0) { const o = []; for (let i = 0; i < n; i++) { const a = ph + TAU * i / n; o.push([Math.cos(a) * r, Math.sin(a) * r]); } return o; }
function rectPts(hw, hh) { return [[-hw, -hh], [hw, -hh], [hw, hh], [-hw, hh]]; }
function glowDot(c, r, col) { disc(c, r * 2.2, A(col, 0.18 * (col[3] ?? 1))); disc(c, r * 1.4, A(col, 0.35 * (col[3] ?? 1))); disc(c, r, col); disc(c, r * 0.45, [1, 1, 1, 0.9 * (col[3] ?? 1)]); }
function arcSegments(c, r, count, gap, rt, col, w) { const span = TAU / count; for (let i = 0; i < count; i++) { const a0 = rt + span * i + gap * 0.5; arc(c, r, a0, a0 + span - gap, col, w); } }
function orb(p, r, col) {
  disc(p, r + 1.1, OUTLINE); disc(p, r, dk(col, 0.3)); disc(add(p, mul(LIGHT, r * 0.12)), r * 0.8, col);
  arc(p, r * 0.72, Math.PI * 1.05, Math.PI * 1.6, lt(col, 0.35), Math.max(0.8, r * 0.16));
  disc(add(p, mul(LIGHT, r * 0.45)), Math.max(0.6, r * 0.13), [1, 1, 1, 0.55]);
}
function plate(c, pts, col, r = 0, s = 1, lw = 1.2) {
  const p = xform(c, pts, r, s);
  poly(p, dk(col, 0.22));
  let ce = [0, 0]; for (const q of p) ce = add(ce, q); ce = mul(ce, 1 / p.length);
  poly(p.map(q => add(ce, mul(sub(q, ce), 0.8))), col);
  for (let i = 0; i < p.length; i++) {
    const a = p[i], b = p[(i + 1) % p.length];
    const m = norm(sub(mul(add(a, b), 0.5), ce));
    const d = dot(m, LIGHT);
    const a1 = add(a, mul(sub(ce, a), 0.1)), b1 = add(b, mul(sub(ce, b), 0.1));
    if (d > 0.15) line(a1, b1, lt(col, 0.45), Math.max(0.8, lw * 0.8));
    else if (d < -0.15) line(a1, b1, dk(col, 0.5), Math.max(0.8, lw * 0.8));
  }
  const cl = p.slice(); cl.push(p[0]); polyline(cl, OUTLINE, lw);
}
function rivets(c, pts, r, s, inset = 0.72, rr = 0.9) { for (const q of xform(c, pts, r, s)) { const p = add(c, mul(sub(q, c), inset)); disc(p, rr + 0.3, OUTLINE); disc(p, rr, lt(METAL_L, 0.15)); } }
function bar(a, b, w, col) {
  const d = norm(sub(b, a)); let n = orth(d); if (dot(n, LIGHT) < 0) n = mul(n, -1);
  line(a, b, OUTLINE, w + 1.6); line(a, b, dk(col, 0.25), w);
  line(add(a, mul(n, w * 0.18)), add(b, mul(n, w * 0.18)), col, w * 0.55);
  line(add(a, mul(n, w * 0.3)), add(b, mul(n, w * 0.3)), lt(col, 0.4), Math.max(0.6, w * 0.16));
}
function strip(a, b, w, col) { line(a, b, A(col, 0.25 * (col[3] ?? 1)), w * 2.6); line(a, b, col, w); line(a, b, [1, 1, 1, 0.6 * (col[3] ?? 1)], Math.max(0.5, w * 0.35)); }
function oval(c, rx, ry, r, col, ow = 0) {
  const pts = []; for (let i = 0; i < 20; i++) { const a = TAU * i / 20; pts.push(add(c, rot([Math.cos(a) * rx, Math.sin(a) * ry], r))); }
  if (ow > 0) poly(pts.map(p => add(c, mul(sub(p, c), 1 + ow / Math.max(rx, ry)))), OUTLINE);
  poly(pts, col);
}
function shadedOval(c, rx, ry, r, col) {
  const m = Math.min(rx, ry);
  oval(c, rx, ry, r, dk(col, 0.3), 1.3); oval(add(c, mul(LIGHT, m * 0.12)), rx * 0.8, ry * 0.78, r, col);
  disc(add(c, mul(LIGHT, m * 0.5)), Math.max(0.6, m * 0.14), [1, 1, 1, 0.45]);
}
function limb(pts, w, col) { polyline(pts, OUTLINE, w + 1.4); polyline(pts, col, w); for (let i = 1; i < pts.length - 1; i++) { disc(pts[i], w * 0.75 + 0.4, OUTLINE); disc(pts[i], w * 0.75, lt(col, 0.25)); } }

// ---- Palettes (existing from Draw.gd ENEMY_BODY / ENEMY_COLOR; new ones are drafts) ----------
const PAL = {
  grunt: [[0.40, 0.42, 0.48, 1], [1.00, 0.28, 0.22, 1]], runner: [[0.30, 0.30, 0.32, 1], [1.00, 0.80, 0.20, 1]],
  brute: [[0.40, 0.37, 0.33, 1], [1.00, 0.55, 0.15, 1]], swarmling: [[0.12, 0.30, 0.16, 1], [0.40, 1.00, 0.50, 1]],
  bat: [[0.30, 0.32, 0.38, 1], [1.00, 0.35, 0.25, 1]], phantom: [[0.16, 0.20, 0.26, 1], [0.55, 0.95, 1.00, 1]],
  aegis: [[0.30, 0.36, 0.46, 1], [0.40, 0.70, 1.00, 1]], hydra: [[0.36, 0.30, 0.22, 1], [1.00, 0.65, 0.25, 1]],
  jammer: [[0.26, 0.28, 0.24, 1], [0.90, 1.00, 0.30, 1]], locust: [[0.30, 0.36, 0.22, 1], [0.75, 1.00, 0.35, 1]],
  gunship: [[0.30, 0.33, 0.30, 1], [1.00, 0.45, 0.30, 1]], burrower: [[0.40, 0.33, 0.24, 1], [1.00, 0.70, 0.35, 1]],
  stalker: [[0.22, 0.20, 0.30, 1], [0.75, 0.55, 1.00, 1]], rampart: [[0.36, 0.34, 0.30, 1], [1.00, 0.45, 0.35, 1]],
  // new (draft)
  needle: [[0.22, 0.24, 0.28, 1], [0.94, 0.95, 0.97, 1]], fury: [[0.25, 0.17, 0.24, 1], [1.00, 0.25, 0.75, 1]],
  shrike: [[0.34, 0.36, 0.40, 1], [0.20, 0.90, 0.80, 1]], titan: [[0.28, 0.29, 0.32, 1], [1.00, 0.45, 0.10, 1]],
  siphon: [[0.26, 0.28, 0.24, 1], [0.90, 1.00, 0.30, 1]], blackout: [[0.24, 0.26, 0.22, 1], [0.95, 1.00, 0.45, 1]],
  capacitor: [[0.22, 0.24, 0.22, 1], [0.85, 1.00, 0.35, 1]], shifter: [[0.27, 0.25, 0.20, 1], [1.00, 0.88, 0.55, 1]],
  wraith: [[0.12, 0.11, 0.24, 1], [0.86, 0.88, 1.00, 1]], masq: [[0.30, 0.20, 0.32, 1], [1.00, 0.40, 0.55, 1]],
  decoy: [[0.30, 0.31, 0.33, 1], [1.00, 0.75, 0.30, 1]], mirage: [[0.20, 0.24, 0.30, 1], [0.80, 0.70, 1.00, 1]],
};
const FLYERS = new Set(["bat", "locust", "gunship", "shrike"]);
const SELF_SHADOW = new Set(["siphon"]); // hovers: draws its own offset shadow
let TELL = "dots";

// ---- Existing enemies, ported from Draw.enemy ------------------------------------------------
const DRAW = {};
DRAW.grunt = (c, f, n, ang, rr, t, b, g) => {
  disc(c, rr * 1.2, A(g, 0.07));
  for (const side of [-1, 1]) { const pod = add(c, mul(n, side * rr * 0.95)); plate(pod, rectPts(0.5, 0.24), lt(METAL_D, 0.1), ang, rr, 1.0); strip(sub(sub(pod, mul(f, rr * 0.55)), mul(n, rr * 0.12)), add(sub(pod, mul(f, rr * 0.55)), mul(n, rr * 0.12)), 0.8, [0.4, 0.8, 1.0, 1]); }
  bar(add(c, mul(f, rr * 0.3)), add(c, mul(f, rr * 1.3)), 2.0, METAL_L); disc(add(c, mul(f, rr * 1.3)), 1.1, [0.05, 0.05, 0.05, 1]);
  orb(c, rr * 0.86, b); arcSegments(c, rr * 0.64, 6, 0.35, ang, dk(b, 0.35), 1.4);
  const e = add(c, mul(f, rr * 0.12)); disc(e, rr * 0.4, OUTLINE); disc(e, rr * 0.33, [0.15, 0.03, 0.03, 1]); glowDot(e, rr * 0.2, g); disc(add(e, mul(LIGHT, rr * 0.15)), rr * 0.07, [1, 1, 1, 0.8]);
};
DRAW.runner = (c, f, n, ang, rr, t, b, g) => {
  for (let i = 0; i < 3; i++) for (const side of [-1, 1]) {
    const ph = t * 20 + i * 2.1 + (side > 0 ? Math.PI : 0);
    const root = add(add(c, mul(f, (1 - i) * rr * 0.35)), mul(n, side * rr * 0.28));
    const knee = add(add(root, mul(n, side * rr * 0.7)), mul(f, ((1 - i) * 0.35 + 0.22 * Math.sin(ph)) * rr));
    const foot = add(add(knee, mul(n, side * rr * 0.3)), mul(f, (1 - i) * 0.45 * rr));
    limb([root, knee, foot], 1.0, METAL_L);
  }
  shadedOval(sub(c, mul(f, rr * 0.35)), rr * 0.56, rr * 0.43, ang, b);
  for (let k = 0; k < 2; k++) { const sp = sub(c, mul(f, rr * (0.2 + 0.25 * k))); line(sub(sp, mul(n, rr * 0.35)), add(sp, mul(n, rr * 0.35)), [0, 0, 0, 0.45], 1.0); }
  strip(sub(c, mul(f, rr * 0.65)), sub(c, mul(f, rr * 0.1)), 0.8, g);
  orb(add(c, mul(f, rr * 0.35)), rr * 0.35, lt(b, 0.15));
  for (const side of [-1, 1]) { line(add(add(c, mul(f, rr * 0.6)), mul(n, side * rr * 0.12)), add(add(c, mul(f, rr * 0.85)), mul(n, side * rr * 0.04)), METAL_L, 1.0); glowDot(add(add(c, mul(f, rr * 0.5)), mul(n, side * rr * 0.14)), rr * 0.08, g); }
};
DRAW.brute = (c, f, n, ang, rr, t, b, g) => {
  for (const side of [-1, 1]) {
    const step = Math.sin(t * 5 + (side > 0 ? Math.PI : 0)) * rr * 0.35;
    const hip = add(c, mul(n, side * rr * 0.45)), knee = add(add(hip, mul(n, side * rr * 0.2)), mul(f, step * 0.5)), foot = add(add(hip, mul(n, side * rr * 0.15)), mul(f, step));
    limb([hip, knee, foot], 3.0, lt(METAL_D, 0.1)); plate(foot, rectPts(0.32, 0.2), METAL_L, ang, rr, 1.0);
  }
  const hull = ngon(6, 1.0); plate(c, hull, b, ang, rr * 0.84, 1.6); rivets(c, hull, ang, rr * 0.84, 0.78, 0.6);
  fill(c, rectPts(0.3, 0.42), dk(b, 0.15), ang, rr);
  for (const side of [-1, 1]) { const sh = add(c, mul(n, side * rr * 0.78)); plate(sh, rectPts(0.34, 0.3), METAL_L, ang, rr, 1.2); bar(add(sh, mul(f, rr * 0.2)), add(sh, mul(f, rr * 1.15)), 2.4, METAL_L); disc(add(sh, mul(f, rr * 1.15)), 1.4, [0.05, 0.05, 0.05, 1]); disc(add(sh, mul(f, rr * 1.15)), 0.8, A(g, 0.9)); }
  const v = add(c, mul(f, rr * 0.42)); strip(sub(v, mul(n, rr * 0.28)), add(v, mul(n, rr * 0.28)), 1.6, g);
};
DRAW.swarmling = (c, f, n, ang, rr, t, b, g) => {
  disc(c, rr * 1.7, A(g, 0.13));
  for (let k = 0; k < 4; k++) { const p = add(c, mul(fa(t * 7 + TAU * k / 4), rr * 0.78)); solid(p, [[0.5, 0], [0, 0.35], [-0.5, 0], [0, -0.35]], lt(b, 0.35), t * 7, rr, 0.8); disc(p, rr * 0.11, g); }
  orb(c, rr * 0.34, lt(b, 0.2)); glowDot(c, rr * 0.18, g);
};
DRAW.bat = (c, f, n, ang, rr, t, b, g) => {
  ellipse(add(c, [0, rr * 2.4]), rr * 1.3, rr * 0.4, [0, 0, 0, 0.2]);
  for (let k = 0; k < 4; k++) {
    const a = ang + Math.PI / 4 + TAU * k / 4, tip = add(c, mul(fa(a), rr * 1.2));
    bar(c, tip, 1.8, lt(METAL_D, 0.15)); disc(tip, rr * 0.62, [0.8, 0.86, 0.95, 0.12]); ring(tip, rr * 0.62, [0.8, 0.86, 0.95, 0.35], 0.8);
    const spin = t * 38 * (k % 2 === 0 ? 1 : -1);
    for (let q = 0; q < 2; q++) line(tip, add(tip, mul(fa(spin + q * Math.PI), rr * 0.58)), [0.85, 0.9, 1.0, 0.55], 1.2);
    orb(tip, rr * 0.17, METAL_L);
    const nav = k < 2 ? [1, 0.25, 0.25, 1] : [0.3, 1, 0.45, 1];
    if (fmod(t * 1.5 + k * 0.25, 1) < 0.35) glowDot(add(c, mul(fa(a), rr * 0.72)), rr * 0.08, nav);
  }
  plate(c, [[0.62, 0], [0.35, 0.36], [-0.5, 0.3], [-0.62, 0], [-0.5, -0.3], [0.35, -0.36]], b, ang, rr, 1.2);
  for (const side of [-1, 1]) { const pod = add(add(c, mul(n, side * rr * 0.34)), mul(f, rr * 0.1)); bar(pod, add(pod, mul(f, rr * 0.45)), 1.6, METAL_L); }
  const cam = add(c, mul(f, rr * 0.42)); orb(cam, rr * 0.2, METAL); glowDot(add(cam, mul(f, rr * 0.06)), rr * 0.09, g);
  strip(sub(sub(c, mul(f, rr * 0.35)), mul(n, rr * 0.12)), add(sub(c, mul(f, rr * 0.35)), mul(n, rr * 0.12)), 0.7, g);
};
DRAW.locust = (c, f, n, ang, rr, t, b, g) => {
  ellipse(add(c, [0, rr * 2.6]), rr * 0.9, rr * 0.3, [0, 0, 0, 0.18]);
  const flap = 0.55 + 0.45 * Math.sin(t * 60);
  for (const side of [-1, 1]) for (let k = 0; k < 2; k++) { const root = add(c, mul(f, rr * (0.25 - 0.45 * k))); const tip = sub(add(root, mul(n, side * rr * (1.5 * flap + 0.3))), mul(f, rr * 0.35)); line(root, tip, [0.85, 0.95, 0.8, 0.45], 1.6); }
  shadedOval(sub(c, mul(f, rr * 0.1)), rr * 0.9, rr * 0.42, ang, b); glowDot(add(c, mul(f, rr * 0.6)), rr * 0.3, g);
};
DRAW.gunship = (c, f, n, ang, rr, t, b, g) => {
  ellipse(add(c, [0, rr * 2.0]), rr * 1.4, rr * 0.4, [0, 0, 0, 0.22]);
  bar(sub(c, mul(f, rr * 0.4)), sub(c, mul(f, rr * 1.35)), 2.4, lt(METAL_D, 0.12)); plate(sub(c, mul(f, rr * 1.35)), rectPts(0.1, 0.42), METAL, ang, rr, 1.0);
  for (const side of [-1, 1]) {
    const fan = sub(add(c, mul(n, side * rr * 0.95)), mul(f, rr * 0.1));
    disc(fan, rr * 0.5, OUTLINE); disc(fan, rr * 0.44, METAL_D);
    for (let q = 0; q < 3; q++) line(fan, add(fan, mul(fa(t * 30 * side + TAU * q / 3), rr * 0.4)), [0.8, 0.85, 0.95, 0.5], 1.4);
    ring(fan, rr * 0.47, METAL_L, 1.6); glowDot(sub(fan, mul(f, rr * 0.5)), rr * 0.08, side < 0 ? [1, 0.25, 0.25, 1] : [0.3, 1, 0.45, 1]);
  }
  const hull = [[0.95, 0], [0.55, 0.5], [-0.6, 0.55], [-0.85, 0.2], [-0.85, -0.2], [-0.6, -0.55], [0.55, -0.5]];
  plate(c, hull, b, ang, rr * 0.8, 1.6); rivets(c, hull, ang, rr * 0.8, 0.72, 0.6);
  line(sub(c, mul(f, rr * 0.4)), add(c, mul(f, rr * 0.45)), [0, 0, 0, 0.35], 1.0);
  const tur = add(c, mul(f, rr * 0.55));
  for (const side of [-1, 1]) bar(add(tur, mul(n, side * rr * 0.1)), add(add(tur, mul(n, side * rr * 0.1)), mul(f, rr * 0.6)), 1.8, METAL_L);
  orb(tur, rr * 0.22, METAL); glowDot(add(c, mul(f, rr * 0.2)), rr * 0.1, g);
};
DRAW.rampart = (c, f, n, ang, rr, t, b, g) => {
  const roll = fmod(t * 14, 5);
  for (const side of [-1, 1]) { const tread = add(c, mul(n, side * rr * 0.82)); plate(tread, rectPts(1.05, 0.26), lt(METAL_D, 0.05), ang, rr, 1.3); for (let k = 0; k < 5; k++) { const lp = add(tread, mul(f, -rr * 0.95 + fmod(k * rr * 0.42 + roll, rr * 2.0))); line(sub(lp, mul(n, rr * 0.22)), add(lp, mul(n, rr * 0.22)), METAL_L, 1.0); } }
  const hull = rectPts(0.78, 0.66); plate(c, hull, b, ang, rr, 1.8);
  for (const cx of [-1, 1]) for (const cy of [-1, 1]) plate(add(add(c, mul(f, cx * rr * 0.62)), mul(n, cy * rr * 0.5)), rectPts(0.16, 0.16), lt(b, 0.12), ang, rr, 1.1);
  rivets(c, hull, ang, rr, 0.7, 0.7);
  bar(add(c, mul(f, rr * 0.7)), add(c, mul(f, rr * 1.25)), 4.0, METAL_L); plate(add(c, mul(f, rr * 1.2)), [[0.2, 0], [-0.05, 0.3], [-0.05, -0.3]], lt(METAL_L, 0.1), ang, rr, 1.0);
  orb(c, rr * 0.28, dk(b, 0.2)); glowDot(c, rr * 0.13, g);
};
DRAW.jammer = (c, f, n, ang, rr, t, b, g) => {
  const ping = fmod(t * 0.9, 1); arc(c, rr * (1.2 + 1.4 * ping), 0, TAU, A(g, 0.35 * (1 - ping)), 1.5);
  for (const side of [-1, 1]) { const tr = add(c, mul(n, side * rr * 0.72)); plate(tr, rectPts(0.8, 0.22), lt(METAL_D, 0.08), ang, rr, 1.0); for (let k = 0; k < 3; k++) { const lp = add(tr, mul(f, (fmod(t * 6 + k * 0.5, 1.5) - 0.75) * rr)); line(sub(lp, mul(n, rr * 0.16)), add(lp, mul(n, rr * 0.16)), [0, 0, 0, 0.45], 0.9); } }
  orb(c, rr * 0.72, b); const dir = fa(t * 2.5);
  arc(c, rr * 0.55, t * 2.5 - 0.9, t * 2.5 + 0.9, OUTLINE, 3.6); arc(c, rr * 0.55, t * 2.5 - 0.9, t * 2.5 + 0.9, METAL_L, 2.2);
  bar(c, add(c, mul(dir, rr * 0.9)), 1.2, METAL_L); glowDot(add(c, mul(dir, rr * 0.9)), rr * 0.14, g); glowDot(c, rr * 0.18, g);
};
DRAW.stalker = (c, f, n, ang, rr, t, b, g) => {
  const echo = fmod(t * 1.1, 1);
  const ghost = [[1.1, 0], [0.2, 0.45], [-0.7, 0.3], [-0.7, -0.3], [0.2, -0.45]];
  outline(sub(c, mul(f, rr * (0.6 + 1.2 * echo))), ghost, A(g, 0.45 * (1 - echo)), 1.0, ang, rr);
  for (const side of [-1, 1]) {
    const ph = t * 12 + (side > 0 ? Math.PI : 0);
    const hip = add(c, mul(n, side * rr * 0.3)), knee = add(add(hip, mul(n, side * rr * 0.45)), mul(f, rr * (0.45 + 0.25 * Math.sin(ph)))), foot = sub(add(knee, mul(n, side * rr * 0.1)), mul(f, rr * (0.55 - 0.3 * Math.sin(ph))));
    limb([hip, knee, foot], 1.3, METAL_L);
  }
  plate(c, ghost, b, ang, rr * 0.8, 1.1); strip(sub(c, mul(f, rr * 0.45)), add(c, mul(f, rr * 0.55)), 0.8, g); glowDot(add(c, mul(f, rr * 0.6)), rr * 0.16, g);
};
DRAW.burrower = (c, f, n, ang, rr, t, b, g, o) => {
  if (o.hidden) {
    const dirt = [0.42, 0.33, 0.24, 1]; shadedOval(c, rr * 1.15, rr * 0.8, ang, dirt);
    for (let k = 0; k < 5; k++) { const a = ang + TAU * k / 5 + t * 0.5; disc(add(c, mul(fa(a), rr * (0.85 + 0.15 * Math.sin(t * 9 + k)))), 1.4, lt(dirt, 0.2)); }
    line(add(c, mul(f, rr * 0.6)), add(c, mul(f, rr * 1.05)), METAL_L, 2.0); glowDot(add(c, mul(f, rr * 0.2)), rr * 0.12, A(g, 0.6)); return;
  }
  for (const side of [-1, 1]) { const tr = add(c, mul(n, side * rr * 0.72)); plate(tr, rectPts(0.7, 0.2), lt(METAL_D, 0.08), ang, rr, 1.0); for (let k = 0; k < 3; k++) { const lp = add(tr, mul(f, (fmod(t * 7 + k * 0.45, 1.35) - 0.68) * rr)); line(sub(lp, mul(n, rr * 0.15)), add(lp, mul(n, rr * 0.15)), [0, 0, 0, 0.45], 0.9); } }
  shadedOval(sub(c, mul(f, rr * 0.15)), rr * 0.7, rr * 0.58, ang, b);
  for (let k = 0; k < 2; k++) { const sp = sub(c, mul(f, rr * (0.05 + 0.3 * k))); line(sub(sp, mul(n, rr * 0.5)), add(sp, mul(n, rr * 0.5)), [0, 0, 0, 0.35], 1.0); }
  plate(c, [[1.45, 0], [0.5, 0.42], [0.5, -0.42]], METAL_L, ang, rr, 1.2);
  for (let k = 0; k < 3; k++) { const fr = fmod(t * 5 + k / 3, 1), x = 0.55 + 0.8 * fr, hw = 0.42 * (1.45 - x) / 0.95; line(sub(add(c, mul(f, rr * x)), mul(n, rr * hw)), add(add(c, mul(f, rr * (x + 0.12))), mul(n, rr * hw)), [0, 0, 0, 0.45], 1.0); }
  glowDot(sub(c, mul(f, rr * 0.2)), rr * 0.14, g);
};
DRAW.phantom = (c, f, n, ang, rr, t, b, g, o) => {
  const blade = [[1.4, 0], [0.1, 0.55], [-0.9, 1.0], [-0.5, 0], [-0.9, -1.0], [0.1, -0.55]];
  if (o.hidden) {
    const a = 0.2 + 0.08 * Math.sin(t * 7), rp = fmod(t * 1.3, 1);
    arc(c, rr * (1 + 0.8 * rp), 0, TAU, [0.8, 0.95, 1.0, 0.22 * (1 - rp)], 1.0);
    outline(c, blade, A(g, a), 1.2, ang, rr); outline(add(c, mul(n, Math.sin(t * 11) * 1.5)), blade, A(g, a * 0.5), 1.0, ang, rr * 1.08); return;
  }
  plate(c, blade, b, ang, rr, 1.2); line(sub(c, mul(f, rr * 0.4)), add(c, mul(f, rr * 1.1)), A(g, 0.5), 1.0);
  for (const side of [-1, 1]) { glowDot(add(add(c, mul(f, rr * 0.35)), mul(n, side * rr * 0.28)), rr * 0.13, g); strip(add(sub(c, mul(f, rr * 0.75)), mul(n, side * rr * 0.55)), add(sub(c, mul(f, rr * 0.55)), mul(n, side * rr * 0.4)), 0.8, g); }
  ring(c, rr * 1.3, A(g, 0.35 + 0.2 * Math.sin(t * 5)), 1.0);
};
DRAW.aegis = (c, f, n, ang, rr, t, b, g) => {
  for (let k = 0; k < 4; k++) { const ld = fa(ang + Math.PI / 4 + k * Math.PI / 2), step = Math.sin(t * 6 + k * Math.PI / 2) * rr * 0.18; const knee = add(add(c, mul(ld, rr * 0.75)), mul(f, step)); limb([add(c, mul(ld, rr * 0.3)), knee, add(knee, mul(ld, rr * 0.35))], 2.0, METAL_L); }
  const hull = ngon(6, 1.0, Math.PI / 6); plate(c, hull, b, ang, rr * 0.74, 1.4); rivets(c, hull, ang, rr * 0.74, 0.75, 0.55);
  orb(sub(c, mul(f, rr * 0.25)), rr * 0.2, dk(g, 0.3)); glowDot(sub(c, mul(f, rr * 0.25)), rr * 0.12, g);
  const sc = add(c, mul(f, rr * 0.2));
  arc(sc, rr * 0.95, ang - 0.95, ang + 0.95, OUTLINE, 5.6); arc(sc, rr * 0.95, ang - 0.95, ang + 0.95, METAL_L, 3.8); arc(sc, rr * 0.88, ang - 0.8, ang + 0.1, lt(METAL_L, 0.35), 1.0);
  for (let k = 0; k < 3; k++) disc(add(sc, mul(fa(ang + (k - 1) * 0.55), rr * 0.95)), 0.9, A(g, 0.9));
  arc(sc, rr * 1.04, ang - 0.9, ang + 0.9, A(g, 0.8), 1.2);
  const hex = ngon(6, 1.0, t * 0.6); fill(c, hex, [0.4, 0.7, 1.0, 0.15], 0, rr + 6); outline(c, hex, [0.55, 0.8, 1.0, 0.75], 1.4, 0, rr + 6); // barrier (enemy_status)
};
DRAW.hydra = (c, f, n, ang, rr, t, b, g) => {
  shadedOval(sub(c, mul(f, rr * 0.3)), rr * 0.52, rr * 0.48, ang, b); ring(sub(c, mul(f, rr * 0.3)), rr * 0.3, dk(b, 0.35), 1.3); glowDot(sub(c, mul(f, rr * 0.3)), rr * 0.1, g);
  for (let k = 0; k < 3; k++) {
    const ba = ang + (k - 1) * 0.7, pts = [];
    for (let i = 0; i < 5; i++) { const q = i / 4, sway = Math.sin(t * 4 + k * 1.7 - q * 2) * rr * 0.22 * q; pts.push(add(add(c, mul(fa(ba), rr * (0.05 + 1.05 * q))), mul(fa(ba + Math.PI / 2), sway))); }
    polyline(pts, OUTLINE, 5.0); polyline(pts, lt(b, 0.15), 3.2); for (let i = 1; i < 4; i++) disc(pts[i], 1.0, dk(b, 0.25));
    const hd = norm(sub(pts[4], pts[3])), hp = add(pts[4], mul(hd, rr * 0.12));
    plate(hp, [[0.6, 0], [0.05, 0.38], [-0.4, 0.3], [-0.4, -0.3], [0.05, -0.38]], lt(b, 0.1), Math.atan2(hd[1], hd[0]), rr * 0.5, 1.0);
    const jaw = mul(orth(hd), rr * 0.1 * (1 + Math.sin(t * 8 + k))); line(add(add(hp, mul(hd, rr * 0.28)), jaw), add(hp, mul(hd, rr * 0.1)), METAL_L, 1.0); glowDot(add(hp, mul(hd, rr * 0.06)), rr * 0.1, g);
  }
};

// ---- New enemies (draft designs) ---------------------------------------------------------------
