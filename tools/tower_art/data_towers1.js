// ---- Tower art page 1: towers 1-5, sleek high-tech sci-fi (owner, 2026-10-16) ----------------------------
// The earlier modern-military round (4 rounds) was scrapped by the owner; it's in git history.
const PAGE = { title: "Tower art page 1 (towers 1-5)", store: "bl-tower-art-1-scifi-v1" };

// ---- Shared effects (tile units scaled by s) ------------------------------------------------------------
const lerp = (a, b, u) => [a[0] + (b[0] - a[0]) * u, a[1] + (b[1] - a[1]) * u];
const decay = (since, len) => (since >= 0 && since < len ? 1 - since / len : 0);
function flashAt(p, aim, s, k, col) { if (k <= 0) return; const f = add(p, mul(fa(aim), s * 0.08));
  fill(f, [[0.5, 0], [0.05, 0.22], [-0.1, 0], [0.05, -0.22]], A([1, 0.95, 0.75, 1], k), aim, s * 0.5 * (0.7 + 0.3 * k)); glowDot(f, s * 0.12 * k, A(col || [1, 0.8, 0.4, 1], k)); }
function smokePuff(p, v, s, a) { if (v <= 0 || v >= 1) return; disc(add(p, [0, -v * s * 0.25]), s * (0.12 + v * 0.25), [0.65, 0.68, 0.72, (a || 0.4) * (1 - v)]); }
function blast(p, v, s, col, size) { if (v < 0 || v >= 1) return; const r = s * (size || 0.4);
  disc(p, r * (0.4 + v * 0.8), A([1, 0.8, 0.4, 1], 0.7 * (1 - v))); ring(p, r * (0.5 + v * 1.1), A(col || [1, 0.6, 0.2, 1], 0.8 * (1 - v)), 2); smokePuff(p, v, s, 0.3); }
function tracer(from, to, u, col, w, len) { const a = lerp(from, to, Math.max(0, u - (len || 0.12))), b = lerp(from, to, u); line(a, b, A(col, 0.95), w || 2); line(a, b, [1, 1, 0.95, 0.9], (w || 2) * 0.4); }
function lobbed(from, to, u, s, col, glow) { const p = lerp(from, to, u), h = Math.sin(Math.PI * u) * s * 1.1;
  ellipse(p, s * 0.07, s * 0.035, [0, 0, 0, 0.3]); disc(add(p, [0, -h]), s * 0.075 + 1, OUTLINE); disc(add(p, [0, -h]), s * 0.075, col); if (glow) glowDot(add(p, [0, -h]), s * 0.04, glow); }
function rocketAt(from, to, u, s, col, k) { const bend = (k % 2 ? 1 : -1) * (0.25 + 0.1 * k);
  const mid = add(lerp(from, to, 0.5), mul(orth(norm(sub(to, from))), s * bend)); const q = (x) => lerp(lerp(from, mid, x), lerp(mid, to, x), x);
  const p = q(u), pb = q(Math.max(0, u - 0.06)); for (let i = 1; i <= 5; i++) disc(q(Math.max(0, u - i * 0.04)), s * (0.025 + i * 0.01), [0.8, 0.82, 0.86, 0.32 - i * 0.05]);
  const dir = Math.atan2(p[1] - pb[1], p[0] - pb[0]); fill(p, [[0.6, 0], [-0.5, 0.16], [-0.5, -0.16]], [0.86, 0.88, 0.92, 1], dir, s * 0.18); glowDot(add(p, mul(fa(dir), -s * 0.1)), s * 0.05, col); }
function beam(from, to, w, col, k) { line(from, to, A(col, 0.35 * k), w * 2.6); line(from, to, A(col, 0.9 * k), w); line(from, to, A([1, 1, 1, 1], 0.85 * k), Math.max(1, w * 0.35)); glowDot(to, w * 1.4, A(col, k)); }
function firedBarrel(fx, i, len) { return fx.barrel === i && fx.barrelSince < (len || 0.12) ? 1 - fx.barrelSince / (len || 0.12) : 0; }

// ---- Sleek high-tech vocabulary: smooth light shells, dark inset panels, glowing seams and cores ----------
const SHELL = [0.8, 0.83, 0.87, 1], SHELL_D = [0.55, 0.59, 0.64, 1], INSET = [0.12, 0.14, 0.18, 1], CORE_D = [0.07, 0.08, 0.11, 1];
const at = (c, aim, s, x, y) => add(c, rot([x * s, y * s], aim)); // x along the aim, y to the side
function capsule(a, b, w, col) { bar(a, b, w + 2, OUTLINE); bar(a, b, w, col); bar(a, b, w * 0.35, lt(col, 0.25)); }
function barrelS(c, aim, s, x0, x1, w, y, col) { capsule(at(c, aim, s, x0, y), at(c, aim, s, x1, y), w * s, col || SHELL_D); }
function seam(a, b, col, k) { line(a, b, A(col, 0.3 * (k ?? 1)), 3); line(a, b, A(col, 0.95 * (k ?? 1)), 1.1); }
function hoverBase(c, s, col, t, r) { const R = (r || 0.42) * s; ellipse(add(c, [0, R * 0.25]), R, R * 0.55, [0, 0, 0, 0.35]);
  disc(c, R + 1, OUTLINE); disc(c, R, INSET); ring(c, R * 0.82, A(col, 0.35 + 0.25 * Math.sin(t * 2)), 1.6); }
function sleekPlate(c, pts, col, aim, s) { plate(c, pts, col, aim, s, 1.1); outline(c, pts.map((q) => mul(q, 0.82)), A(lt(col, 0.4), 0.7), 1, aim, s); }
function muzzleRing(p, s, col, k) { ring(p, s * 0.05, A(col, 0.5 + 0.5 * k), 1.6); if (k > 0) glowDot(p, s * 0.07 * k, A(col, k)); }

const TOWERS = [
  // 1. Gun Turret ---------------------------------------------------------------------------------------
  { id: "gun", num: 1, name: "Gun Turret", cls: "Assault", weapon: "Ballistic", hits: "both", color: [1, 0.72, 0.25, 1],
    desc: "A basic rotating machine gun turret. \"It's a machine gun, Private!\" Steady medium rounds; the cheap starter.",
    looks: [
      { key: "A", name: "Capsule Sentry", muzzle: 0.64, theme: "A smooth white capsule head on a hovering ring, one slim barrel with a glowing muzzle ring, amber seams along the shell.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t); const r = fx.recoil * 0.06;
          barrelS(c, aim, s, 0.05, 0.62 - r, 0.07, 0); muzzleRing(at(c, aim, s, 0.62 - r, 0), s, col, fx.flash);
          capsule(at(c, aim, s, -0.2, 0), at(c, aim, s, 0.14, 0), s * 0.32, SHELL); seam(at(c, aim, s, -0.16, 0.1), at(c, aim, s, 0.1, 0.1), col); seam(at(c, aim, s, -0.16, -0.1), at(c, aim, s, 0.1, -0.1), col);
          glowDot(at(c, aim, s, 0.12, 0), s * 0.035, A(col, 0.9)); flashAt(at(c, aim, s, 0.62 - r, 0), aim, s, fx.flash, col); } },
      { key: "B", name: "Wedge Sentinel", muzzle: 0.66, theme: "A sharp arrowhead turret with two blade fins flanking the barrel, dark inset panels and a bright sensor slit.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t); const r = fx.recoil * 0.06;
          for (const sg of [-1, 1]) sleekPlate(at(c, aim, s, 0.12, sg * 0.17), [[0.3, 0], [-0.2, sg * 0.06], [-0.18, -sg * 0.05]], SHELL_D, aim, s);
          barrelS(c, aim, s, 0, 0.66 - r, 0.07, 0, SHELL); sleekPlate(c, [[0.3, 0], [-0.22, 0.24], [-0.12, 0], [-0.22, -0.24]], SHELL, aim, s);
          fill(at(c, aim, s, 0.06, 0), rectPts(0.03, 0.09), A(col, 0.6 + 0.4 * fx.flash), aim, s); flashAt(at(c, aim, s, 0.66 - r, 0), aim, s, fx.flash, col); } },
      { key: "C", name: "Orb Gunner", muzzle: 0.6, theme: "A glossy sphere that floats above its base ring; the barrel slides out of a slot in the orb.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t, 0.38); const r = fx.recoil * 0.07, h = Math.sin(t * 2) * s * 0.02, o = add(c, [0, -h]);
          barrelS(o, aim, s, 0.1, 0.6 - r, 0.06, 0); disc(o, s * 0.25 + 1, OUTLINE); disc(o, s * 0.25, SHELL); disc(add(o, mul(LIGHT, s * 0.08)), s * 0.1, lt(SHELL, 0.5));
          arc(o, s * 0.2, aim - 0.5, aim + 0.5, A(col, 0.9), 2.4); glowDot(at(o, aim, s, 0.16, 0), s * 0.04, A(col, 0.9)); flashAt(at(o, aim, s, 0.6 - r, 0), aim, s, fx.flash, col); } },
    ],
    anims: [
      { key: "A", name: "Slide Recoil", desc: "The barrel slides back into its housing on each shot, the muzzle ring flares, and a tracer streaks out.", period: 0.83, flight: 0.18,
        fx: (since) => ({ recoil: decay(since, 0.18), flash: decay(since, 0.08) }), shot: (f, to, u, s, col) => tracer(f, to, u, col, 2.2, 0.25), impact: (to, v, s, col) => { if (v < 0.3) glowDot(to, s * 0.08 * (1 - v * 3), col); } },
      { key: "B", name: "Heat Build", desc: "Steady single rounds; the barrel glows hotter with each shot and vents a puff of heat when it cools.", period: 0.83, flight: 0.18,
        fx: (since) => ({ recoil: decay(since, 0.12), flash: decay(since, 0.07) }),
        shot: (f, to, u, s, col) => { tracer(f, to, u, col, 2, 0.22); if (u < 0.25) glowDot(f, s * 0.08 * (1 - u * 4), A([1, 0.4, 0.2, 1], 0.6)); },
        impact: (to, v, s, col) => { if (v < 0.3) glowDot(to, s * 0.07, col); } },
      { key: "C", name: "Burst Cycle", desc: "Short three-round bursts, the seams pulsing with each round.", period: 1.4, burst: 3, gap: 0.09, flight: 0.16,
        fx: (since) => { const k = since < 0.3 ? (Math.sin(since * 70) > 0 ? 1 : 0) : 0; return { recoil: since < 0.3 ? 0.5 * k : 0, flash: since < 0.3 ? k : 0 }; },
        shot: (f, to, u, s, col) => tracer(f, to, u, col, 1.6, 0.2), impact: (to, v, s, col) => { if (v < 0.25) glowDot(to, s * 0.06, col); } },
    ] },

  // 2. Mortar Tower -------------------------------------------------------------------------------------
  { id: "mortar", num: 2, name: "Mortar Tower", cls: "Assault", weapon: "Explosive", hits: "ground", color: [1, 0.5, 0.18, 1],
    desc: "Lobs high-explosive shells at nearby enemies. \"Toob.\" Short range, heavy splash, ground only.",
    looks: [
      { key: "A", name: "Iris Dome", muzzle: 0.1, theme: "A smooth white dome whose iris petals open to lob each shell, then close; orange glow inside when open.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t); const open = fx.flash; disc(c, s * 0.34 + 1, OUTLINE); disc(c, s * 0.34, SHELL);
          disc(add(c, mul(LIGHT, s * 0.1)), s * 0.14, lt(SHELL, 0.5)); const ir = s * (0.06 + 0.12 * open); disc(c, ir + 1.5, OUTLINE); disc(c, ir, mix(CORE_D, col, 0.5 + 0.5 * open));
          for (let i = 0; i < 6; i++) { const a = i * TAU / 6 + open * 0.6; line(add(c, mul(fa(a), ir)), add(c, mul(fa(a + 0.7), s * 0.26)), A(SHELL_D, 0.9), 1.4); } } },
      { key: "B", name: "Hover Mortar", muzzle: 0.32, theme: "A short, fat launcher pod floating over its base, angled up, with glowing magnetic rings around the tube.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t); const dip = fx.recoil * s * 0.05, o = add(c, [0, dip - Math.sin(t * 2) * s * 0.02]);
          capsule(at(o, aim, s, -0.18, 0), at(o, aim, s, 0.26, 0), s * 0.3, SHELL); for (const x of [0.02, 0.14]) ring(at(o, aim, s, x, 0), s * 0.15, A(col, 0.5 + 0.5 * fx.flash), 1.6);
          disc(at(o, aim, s, 0.28, 0), s * 0.1, CORE_D); glowDot(at(o, aim, s, 0.28, 0), s * 0.06 * (0.3 + fx.flash), A(col, 0.9)); } },
      { key: "C", name: "Accelerator Cradle", muzzle: 0.42, theme: "A sleek angled tube in a two-arm cradle with a ring accelerator at the muzzle; panels light up in sequence before each shot.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t); for (const sg of [-1, 1]) sleekPlate(at(c, aim, s, -0.02, sg * 0.2), rectPts(0.18, 0.05), SHELL_D, aim, s);
          const r = fx.recoil * 0.06; barrelS(c, aim, s, -0.15, 0.4 - r, 0.17, 0, SHELL); ring(at(c, aim, s, 0.38 - r, 0), s * 0.12, A(col, 0.6 + 0.4 * fx.flash), 2.2);
          for (let i = 0; i < 3; i++) glowDot(at(c, aim, s, -0.08 + i * 0.12, 0), s * 0.025, A(col, 0.3 + 0.7 * fx.flash)); flashAt(at(c, aim, s, 0.42 - r, 0), aim, s, fx.flash * 0.6, col); } },
    ],
    anims: [
      { key: "A", name: "Lob and Glow", desc: "A soft launch thump; the shell arcs high trailing a faint glow and bursts in an orange flash on the pack.", period: 1.67, flight: 0.9,
        fx: (since) => ({ recoil: decay(since, 0.2), flash: decay(since, 0.5) }), shot: (f, to, u, s, col) => lobbed(f, to, u, s, [0.86, 0.88, 0.92, 1], A(col, 0.8)), impact: (to, v, s, col) => blast(to, v, s, col, 0.55) },
      { key: "B", name: "Charge Sequence", desc: "Lights race up the tube before each shot; a bright launch flash, then a heavy blast ring.", period: 1.67, flight: 0.9,
        fx: (since, p) => ({ recoil: decay(since, 0.25), flash: since < 0.3 ? 1 - since / 0.3 : since > p - 0.5 ? (since - (p - 0.5)) / 0.5 : 0 }),
        shot: (f, to, u, s, col) => lobbed(f, to, u, s, [0.86, 0.88, 0.92, 1], A(col, 0.8)), impact: (to, v, s, col) => { blast(to, v, s, col, 0.6); ring(to, s * (0.3 + v), A(col, 0.5 * (1 - v)), 3); } },
      { key: "C", name: "Vent Plume", desc: "Each shot vents a pale plume from the launcher that drifts away; a ghost trail follows the shell.", period: 1.67, flight: 0.9,
        fx: (since) => ({ recoil: decay(since, 0.15), flash: decay(since, 0.9) }),
        shot: (f, to, u, s, col) => { for (let i = 1; i < 6; i++) { const w = Math.max(0, u - i * 0.04); const p = lerp(f, to, w); disc(add(p, [0, -Math.sin(Math.PI * w) * s * 1.1]), s * 0.035, A(col, 0.25)); } lobbed(f, to, u, s, [0.86, 0.88, 0.92, 1], A(col, 0.8)); },
        impact: (to, v, s, col) => blast(to, v, s, col, 0.55) },
    ] },

  // 3. Laser Tower --------------------------------------------------------------------------------------
  { id: "laser", num: 3, name: "Laser Tower", cls: "Assault", weapon: "Energy", hits: "both", color: [1, 0.25, 0.35, 1],
    desc: "A high-energy laser emitter on a rotating turret. \"It does more than just blind the enemy, that's for sure.\" A ramping beam that melts armour; it fires only once locked on.",
    looks: [
      { key: "A", name: "Prism Head", muzzle: 0.44, theme: "A tapered white head with a faceted prism lens at its tip; a red seam runs from the core to the lens.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t); sleekPlate(c, [[0.34, 0], [0.1, 0.18], [-0.24, 0.2], [-0.3, 0], [-0.24, -0.2], [0.1, -0.18]], SHELL, aim, s);
          seam(at(c, aim, s, -0.2, 0), at(c, aim, s, 0.3, 0), col, 0.4 + 0.6 * fx.glow); fill(at(c, aim, s, 0.38, 0), ngon(4, 0.08), A(mix(SHELL_D, col, fx.glow), 1), aim, s);
          glowDot(at(c, aim, s, 0.4, 0), s * (0.04 + 0.07 * fx.glow), A(col, 0.5 + 0.5 * fx.glow)); } },
      { key: "B", name: "Floating Focus Rings", muzzle: 0.46, theme: "A glowing core with two rings floating in front of it, one behind the other; the beam threads through both rings.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t); disc(c, s * 0.18 + 1, OUTLINE); disc(c, s * 0.18, SHELL); glowDot(c, s * (0.06 + 0.06 * fx.glow), A(col, 0.6 + 0.4 * fx.glow));
          for (const x of [0.26, 0.4]) { const q = at(c, aim, s, x, 0); const w = s * (x > 0.3 ? 0.08 : 0.11); line(add(q, mul(orth(fa(aim)), w)), add(q, mul(orth(fa(aim)), -w)), OUTLINE, s * 0.07); line(add(q, mul(orth(fa(aim)), w)), add(q, mul(orth(fa(aim)), -w)), mix(SHELL, col, fx.glow * 0.7), s * 0.05); } } },
      { key: "C", name: "Crystal Spire", muzzle: 0.34, theme: "A slim white spire capped by a glowing crystal that pivots to aim; light pulses up the spire.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t, 0.36); disc(c, s * 0.2 + 1, OUTLINE); disc(c, s * 0.2, SHELL); disc(c, s * 0.12, SHELL_D);
          for (let i = 0; i < 3; i++) ring(c, s * (0.06 + i * 0.05), A(col, (0.2 + 0.6 * fx.glow) * (fmod(t * 2 - i * 0.3, 1))), 1.2);
          fill(at(c, aim, s, 0.14, 0), [[0.24, 0], [0, 0.09], [-0.12, 0], [0, -0.09]], A(mix([0.6, 0.2, 0.3, 1], col, 0.5 + 0.5 * fx.glow), 1), aim, s); glowDot(at(c, aim, s, 0.32, 0), s * (0.04 + 0.06 * fx.glow), A(col, 0.8)); } },
    ],
    anims: [
      { key: "A", name: "Ramp Glow", lock: 0.6, desc: "Locks on first (a reticle closes on the target), then the beam starts thin and thickens and whitens the longer it holds; the emitter brightens with it.", beam: true, period: 1,
        fx: (lock, p, on) => ({ glow: on ? Math.min(1, 0.2 + lock / 3) : 0 }), shot: (f, to, lock, s, col) => beam(f, to, 1.5 + Math.min(1, lock / 3) * 3, col, 0.6 + Math.min(1, lock / 3) * 0.4) },
      { key: "B", name: "Pulse Train", lock: 0.6, desc: "Locks on first, then a steady beam with bright pulses racing down it and rings rippling at the emitter.", beam: true, period: 1,
        fx: (lock, p, on) => ({ glow: on ? 0.6 + 0.4 * Math.sin(lock * 10) : 0 }),
        shot: (f, to, lock, s, col) => { beam(f, to, 2.4, col, 0.85); for (let i = 0; i < 3; i++) glowDot(lerp(f, to, fmod(lock * 1.6 + i / 3, 1)), s * 0.05, A([1, 1, 1, 1], 0.9)); ring(f, s * 0.1 * (1 + fmod(lock * 3, 1)), A(col, 1 - fmod(lock * 3, 1)), 1.5); } },
      { key: "C", name: "Melt Sparks", lock: 0.6, desc: "Locks on first, then the beam burns with sparks and armour flakes spraying off the target as it ramps.", beam: true, period: 1,
        fx: (lock, p, on) => ({ glow: on ? Math.min(1, 0.3 + lock / 2) : 0 }),
        shot: (f, to, lock, s, col, k, t) => { beam(f, to, 2.2 + Math.min(1, lock / 3) * 2, col, 0.9); for (let i = 0; i < 5; i++) { const a = t * 9 + i * 1.3, q = fmod(t * 3 + i * 0.2, 1); disc(add(to, mul(fa(a), s * 0.3 * q)), 1.4, A([1, 0.85, 0.6, 1], 1 - q)); } } },
    ] },

  // 4. Rocket Salvo -------------------------------------------------------------------------------------
  { id: "rocket", num: 4, name: "Rocket Salvo", cls: "Assault", weapon: "Explosive", hits: "both", color: [1, 0.86, 0.3, 1],
    desc: "Launches a volley of rockets at oncoming enemies. \"Instead of shooting bullets, it shoots very angry telephone poles that hate absolutely everything.\" Spread salvos, one rocket per enemy.",
    looks: [
      { key: "A", name: "Flush-Cell Wing", muzzle: 0.3, muzzles: [[0.3, -0.18], [0.3, 0], [0.3, 0.18]], theme: "A smooth swept wing-shaped launcher with rocket cells set flush into its leading edge behind sliding covers.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t); sleekPlate(c, [[0.32, 0], [0.18, 0.3], [-0.22, 0.26], [-0.14, 0], [-0.22, -0.26], [0.18, -0.3]], SHELL, aim, s);
          [-0.18, 0, 0.18].forEach((y, i) => { const q = at(c, aim, s, 0.28 - Math.abs(y) * 0.5, y); disc(q, s * 0.05, CORE_D); glowDot(q, s * 0.03, A(col, 0.3 + 0.7 * firedBarrel(fx, i, 0.3))); });
          seam(at(c, aim, s, -0.12, 0), at(c, aim, s, 0.2, 0), col, 0.6); } },
      { key: "B", name: "Floating Cell Array", muzzle: 0.3, muzzles: [[0.24, -0.16], [0.24, 0], [0.24, 0.16], [0.06, -0.16], [0.06, 0], [0.06, 0.16]], theme: "A thin slab of six launch cells floating above the base, tilting toward its target; each cell glows as its rocket leaves.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t); const o = add(c, [0, -Math.sin(t * 2) * s * 0.02]); sleekPlate(o, rectPts(0.2, 0.28), SHELL, aim, s);
          [[0.24, -0.16], [0.24, 0], [0.24, 0.16], [0.06, -0.16], [0.06, 0], [0.06, 0.16]].forEach((q, i) => { const p = at(o, aim, s, q[0] - 0.08, q[1]); fill(p, rectPts(0.05, 0.05), CORE_D, aim, s); glowDot(p, s * 0.03, A(col, 0.25 + 0.75 * firedBarrel(fx, i, 0.35))); }); } },
      { key: "C", name: "Twin Nacelles", muzzle: 0.42, muzzles: [[0.42, -0.24], [0.42, 0.24]], theme: "Two smooth nacelle pods on short arms either side of a rounded core, like engine pods; rockets leave the nacelles alternately.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t); for (const y of [-0.24, 0.24]) { line(c, at(c, aim, s, 0, y), SHELL_D, s * 0.06); capsule(at(c, aim, s, -0.2, y), at(c, aim, s, 0.4, y), s * 0.15, SHELL); }
          [-0.24, 0.24].forEach((y, i) => { disc(at(c, aim, s, 0.42, y), s * 0.05, CORE_D); glowDot(at(c, aim, s, 0.42, y), s * 0.035, A(col, 0.3 + 0.7 * firedBarrel(fx, i, 0.3))); });
          disc(c, s * 0.15 + 1, OUTLINE); disc(c, s * 0.15, SHELL_D); glowDot(c, s * 0.05, A(col, 0.8)); } },
    ],
    anims: [
      { key: "A", name: "Ripple Launch", desc: "Rockets leave the cells one after another, each with a puff of vapour, curving onto separate enemies.", period: 2.5, burst: 3, gap: 0.14, multi: true, flight: 0.8,
        fx: (since) => ({ recoil: since < 0.45 ? 0.5 : 0, flash: since < 0.45 ? 1 : 0 }), shot: (f, to, u, s, col, k) => rocketAt(f, to, u, s, col, k), impact: (to, v, s, col) => blast(to, v, s, col, 0.35) },
      { key: "B", name: "Full Salvo", desc: "Every rocket launches at once in a bright flash and a vapour cloud behind the launcher.", period: 2.5, burst: 3, gap: 0, multi: true, flight: 0.8,
        fx: (since) => ({ recoil: decay(since, 0.3), flash: decay(since, 0.25) }),
        shot: (f, to, u, s, col, k) => { if (k === 0 && u < 0.4) disc(sub(f, mul(norm(sub(to, f)), s * 0.6 * (0.5 + u))), s * (0.15 + u * 0.4), [0.8, 0.82, 0.86, 0.35 * (1 - u * 2.5)]); rocketAt(f, to, u, s, col, k); },
        impact: (to, v, s, col) => blast(to, v, s, col, 0.4) },
      { key: "C", name: "Cover Slide", desc: "The cell covers slide open, the rockets launch in a quick ripple, and the covers close again.", period: 2.5, burst: 3, gap: 0.1, multi: true, flight: 0.8,
        fx: (since, p) => ({ recoil: 0, flash: since < 0.6 ? 1 : since > p - 0.3 ? 1 : 0 }), shot: (f, to, u, s, col, k) => rocketAt(f, to, u, s, col, k), impact: (to, v, s, col) => blast(to, v, s, col, 0.35) },
    ] },

  // 5. Anti-Aircraft Turret -----------------------------------------------------------------------------
  { id: "aa", num: 5, name: "Anti-Aircraft Turret", cls: "Assault", weapon: "Ballistic", hits: "air", color: [0.75, 1, 0.4, 1],
    desc: "A fully automatic anti-aircraft gun. \"We don't need a gun, or a nug!\" A direct-hit autocannon, air only.",
    looks: [
      { key: "A", name: "Twin-Barrel Pod", muzzle: 0.66, muzzles: [[0.66, 0.1], [0.66, -0.1]], theme: "A rounded white pod from which two long slim barrels flow forward; lime seams trace the barrels.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t); [-0.1, 0.1].forEach((y, i) => barrelS(c, aim, s, 0, 0.64 - firedBarrel(fx, i) * 0.06, 0.06, -y));
          capsule(at(c, aim, s, -0.18, 0), at(c, aim, s, 0.12, 0), s * 0.36, SHELL); seam(at(c, aim, s, -0.12, 0), at(c, aim, s, 0.08, 0), col);
          [-0.1, 0.1].forEach((y, i) => flashAt(at(c, aim, s, 0.66, -y), aim, s, firedBarrel(fx, i, 0.08), col)); } },
      { key: "B", name: "Quad Spinner", muzzle: 0.6, muzzles: [[0.6, 0.15], [0.6, 0.05], [0.6, -0.05], [0.6, -0.15]], theme: "Four slim barrels in a tight cluster on a smooth head, the cluster spinning like a rotary gun.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t); for (let i = 0; i < 4; i++) { const y = 0.15 - i * 0.1; barrelS(c, aim, s, 0.05, 0.58 - firedBarrel(fx, i) * 0.04, 0.045, y); }
          sleekPlate(c, rectPts(0.18, 0.24), SHELL, aim, s); ring(at(c, aim, s, 0.2, 0), s * 0.12, A(col, 0.7), 1.6);
          for (let i = 0; i < 4; i++) flashAt(at(c, aim, s, 0.6, 0.15 - i * 0.1), aim, s, firedBarrel(fx, i, 0.08), col); } },
      { key: "C", name: "Tracker Dome", muzzle: 0.6, muzzles: [[0.6, 0.26], [0.6, -0.26]], theme: "A sensor dome turret with a barrel on each flank; a lime tracking light sweeps across the dome.",
        draw(c, aim, s, fx, t, col) { hoverBase(c, s, col, t); [-0.26, 0.26].forEach((y, i) => barrelS(c, aim, s, 0.05, 0.58 - firedBarrel(fx, i) * 0.05, 0.055, -y));
          disc(c, s * 0.26 + 1, OUTLINE); disc(c, s * 0.26, SHELL); arc(c, s * 0.18, t * 3, t * 3 + 0.8, A(col, 0.9), 2.2); glowDot(at(c, aim, s, 0.18, 0), s * 0.04, A(col, 0.9));
          [-0.26, 0.26].forEach((y, i) => flashAt(at(c, aim, s, 0.6, -y), aim, s, firedBarrel(fx, i, 0.08), col)); } },
    ],
    anims: [
      { key: "A", name: "Alternating Barrels", desc: "The barrels fire in turn, each kicking back on its own shot; small dark bursts near the flyer.", period: 0.4, burst: 1, flight: 0.26,
        fx: (since) => ({ recoil: decay(since, 0.1), flash: decay(since, 0.06) }), shot: (f, to, u, s, col) => tracer(f, to, u, col, 1.8, 0.22),
        impact: (to, v, s) => { if (v < 0.6) disc(add(to, [0, -v * 3]), s * (0.06 + v * 0.14), [0.15, 0.15, 0.18, 0.6 * (1 - v)]); } },
      { key: "B", name: "Paired Bursts", desc: "All barrels fire a quick pair together, then pause; bright tracer pairs streak up.", period: 0.9, burst: 2, gap: 0.06, flight: 0.25,
        fx: (since) => ({ recoil: decay(since, 0.15), flash: decay(since, 0.1) }), shot: (f, to, u, s, col) => tracer(f, to, u, col, 1.8, 0.2),
        impact: (to, v, s, col) => { if (v < 0.4) ring(to, s * (0.05 + v * 0.3), A(col, 1 - v * 2.5), 1.5); } },
      { key: "C", name: "Lead Stream", desc: "A steady stream aimed ahead of the flyer that sweeps onto it.", period: 0.25, burst: 1, flight: 0.3,
        fx: (since) => ({ recoil: decay(since, 0.08), flash: decay(since, 0.05) }),
        shot: (f, to, u, s, col) => { const lead = add(to, [s * 0.6 * (1 - u), 0]); tracer(f, lead, u, col, 1.6, 0.25); },
        impact: (to, v, s, col) => { if (v < 0.3) glowDot(to, s * 0.05, col); } },
    ] },
];

const DEFAULTS = {};
