// ---- Tower art page 1: towers 1-5 ------------------------------------------------------------------------
const PAGE = { title: "Tower art page 1 (towers 1-5)", store: "bl-tower-art-1-v1" };

// Shared effects (tile units scaled by s).
const lerp = (a, b, u) => [a[0] + (b[0] - a[0]) * u, a[1] + (b[1] - a[1]) * u];
const decay = (since, len) => (since >= 0 && since < len ? 1 - since / len : 0);
function flashAt(p, aim, s, k, col) { if (k <= 0) return; const f = add(p, mul(fa(aim), s * 0.08));
  fill(f, [[0.5, 0], [0.05, 0.22], [-0.1, 0], [0.05, -0.22]], A([1, 0.92, 0.6, 1], k), aim, s * 0.5 * (0.7 + 0.3 * k)); glowDot(f, s * 0.12 * k, A(col || [1, 0.8, 0.4, 1], k)); }
function smokePuff(p, v, s, a) { if (v <= 0 || v >= 1) return; disc(add(p, [0, -v * s * 0.25]), s * (0.12 + v * 0.25), [0.6, 0.6, 0.6, (a || 0.4) * (1 - v)]); }
function blast(p, v, s, col, size) { if (v < 0 || v >= 1) return; const r = s * (size || 0.4);
  disc(p, r * (0.4 + v * 0.8), A([1, 0.75, 0.3, 1], 0.7 * (1 - v))); ring(p, r * (0.5 + v * 1.1), A(col || [1, 0.6, 0.2, 1], 0.8 * (1 - v)), 2); smokePuff(p, v, s, 0.35); }
function tracer(from, to, u, col, w, len) { const a = lerp(from, to, Math.max(0, u - (len || 0.12))), b = lerp(from, to, u); line(a, b, A(col, 0.95), w || 2); line(a, b, [1, 1, 0.9, 0.9], (w || 2) * 0.4); }
function lobbed(from, to, u, s, col) { const p = lerp(from, to, u), h = Math.sin(Math.PI * u) * s * 1.1;
  ellipse(p, s * 0.07, s * 0.035, [0, 0, 0, 0.3]); disc(add(p, [0, -h]), s * 0.075 + 1, OUTLINE); disc(add(p, [0, -h]), s * 0.075, col); }
function rocketAt(from, to, u, s, col, k) { const bend = (k % 2 ? 1 : -1) * (0.25 + 0.1 * k);
  const mid = add(lerp(from, to, 0.5), mul(orth(norm(sub(to, from))), s * bend)); const q = (x) => lerp(lerp(from, mid, x), lerp(mid, to, x), x);
  const p = q(u), pb = q(Math.max(0, u - 0.06)); for (let i = 1; i <= 5; i++) disc(q(Math.max(0, u - i * 0.04)), s * (0.03 + i * 0.012), [0.75, 0.75, 0.75, 0.35 - i * 0.05]);
  const dir = Math.atan2(p[1] - pb[1], p[0] - pb[0]); fill(p, [[0.6, 0], [-0.5, 0.18], [-0.5, -0.18]], col, dir, s * 0.18); glowDot(add(p, mul(fa(dir), -s * 0.1)), s * 0.05, [1, 0.7, 0.3, 1]); }
function beam(from, to, w, col, k) { line(from, to, A(col, 0.35 * k), w * 2.6); line(from, to, A(col, 0.9 * k), w); line(from, to, A([1, 1, 1, 1], 0.85 * k), Math.max(1, w * 0.35)); glowDot(to, w * 1.4, A(col, k)); }
function barrel(c, aim, s, x0, x1, w, col, off) { const o = mul(orth(fa(aim)), (off || 0) * s); bar(add(add(c, o), mul(fa(aim), x0 * s)), add(add(c, o), mul(fa(aim), x1 * s)), w * s, col); }
function sandbags(c, s, r, n) { for (let i = 0; i < n; i++) { const a = i * TAU / n; plate(add(c, mul(fa(a), r * s)), [[0.16, 0], [0.12, 0.09], [-0.12, 0.09], [-0.16, 0], [-0.12, -0.09], [0.12, -0.09]], [0.55, 0.5, 0.38, 1], a + Math.PI / 2, s, 0.8); } }

const OLIVE = [0.33, 0.37, 0.24, 1], GUNMETAL = [0.26, 0.28, 0.3, 1], STEEL = [0.42, 0.45, 0.48, 1], DARK = [0.13, 0.14, 0.15, 1];

const TOWERS = [
  // 1. Gun Turret ---------------------------------------------------------------------------------------
  { id: "gun", num: 1, name: "Gun Turret", cls: "Assault", weapon: "Ballistic", hits: "both", color: [1, 0.78, 0.3, 1],
    desc: "A basic rotating machine gun turret. \"It's a machine gun, Private!\" Steady medium rounds; the cheap starter.",
    looks: [
      { key: "A", name: "Sandbag MG Nest", muzzle: 0.62, theme: "A ring of sandbags around a tripod machine gun with an ammo box; the gun swivels on the tripod.",
        draw(c, aim, s, fx, t, col) { sandbags(c, s, 0.36, 9); disc(c, s * 0.2, DARK);
          for (const a of [0.9, 3, 5.1]) line(c, add(c, mul(fa(a + aim * 0.2), s * 0.26)), GUNMETAL, 2);
          const r = fx.recoil * 0.06; barrel(c, aim, s, -0.12 - r, 0.6 - r, 0.07, GUNMETAL); plate(add(c, mul(fa(aim), -r * s)), rectPts(0.16, 0.09), OLIVE, aim, s, 0.8);
          plate(add(c, mul(orth(fa(aim)), s * 0.14)), rectPts(0.08, 0.06), [0.45, 0.42, 0.2, 1], aim, s, 0.6); flashAt(add(c, mul(fa(aim), (0.62 - r) * s)), aim, s, fx.flash); } },
      { key: "B", name: "Armoured Turret", muzzle: 0.66, theme: "A squat hexagonal armoured turret with a front shield plate and a single heavy barrel; riveted, olive drab.",
        draw(c, aim, s, fx, t, col) { plate(c, ngon(6, 0.44), DARK, 0, s, 1); const r = fx.recoil * 0.07;
          barrel(c, aim, s, 0.1, 0.66 - r, 0.085, GUNMETAL); disc(add(c, mul(fa(aim), (0.66 - r) * s)), s * 0.06, DARK);
          plate(c, ngon(6, 0.3, aim), OLIVE, 0, s, 1.1); rivets(c, ngon(6, 0.3, aim), 0, s, 0.8, 0.8);
          plate(add(c, mul(fa(aim), s * 0.24)), rectPts(0.06, 0.2), lt(OLIVE, 0.1), aim, s, 0.9); disc(c, s * 0.07, A(col, 0.8)); flashAt(add(c, mul(fa(aim), (0.66 - r) * s)), aim, s, fx.flash); } },
      { key: "C", name: "Remote Weapon Station", muzzle: 0.6, theme: "A compact remote weapon station on a pedestal: boxy gun cradle, camera/sensor block and a belt feed from the side box.",
        draw(c, aim, s, fx, t, col) { plate(c, rectPts(0.4, 0.4), DARK, 0, s, 1); disc(c, s * 0.24, GUNMETAL); const r = fx.recoil * 0.05;
          barrel(c, aim, s, 0, 0.6 - r, 0.06, DARK); plate(c, rectPts(0.22, 0.13), STEEL, aim, s, 1);
          plate(add(c, mul(orth(fa(aim)), -s * 0.17)), rectPts(0.09, 0.06), DARK, aim, s, 0.8); glowDot(add(add(c, mul(orth(fa(aim)), -s * 0.17)), mul(fa(aim), s * 0.07)), s * 0.03, A(col, 0.9));
          plate(add(c, mul(orth(fa(aim)), s * 0.18)), rectPts(0.1, 0.08), OLIVE, aim, s, 0.8); flashAt(add(c, mul(fa(aim), (0.6 - r) * s)), aim, s, fx.flash); } },
    ],
    anims: [
      { key: "A", name: "Recoil Kick", desc: "One heavy round at a time: the gun kicks back, a sharp muzzle flash, a tracer streak.", period: 0.83, flight: 0.18,
        fx: (since) => ({ recoil: decay(since, 0.18), flash: decay(since, 0.07) }), shot: (f, to, u, s, col) => tracer(f, to, u, col, 2.2, 0.25), impact: (to, v, s) => { if (v < 0.3) glowDot(to, s * 0.08 * (1 - v * 3), [1, 0.9, 0.5, 1]); } },
      { key: "B", name: "Burst Rattle", desc: "Short three-round bursts: rapid flashes and a light shake, three tracers per burst.", period: 1.4, burst: 3, gap: 0.09, flight: 0.16,
        fx: (since) => { const k = since < 0.3 ? (Math.sin(since * 70) > 0 ? 1 : 0) : 0; return { recoil: since < 0.3 ? 0.5 * k : 0, flash: since < 0.3 ? k : 0 }; },
        shot: (f, to, u, s, col) => tracer(f, to, u, col, 1.6, 0.2), impact: (to, v, s) => { if (v < 0.25) glowDot(to, s * 0.06, [1, 0.9, 0.5, 1]); } },
      { key: "C", name: "Tracer Line", desc: "Each shot leaves a long glowing tracer line that lingers briefly; spent casings flick out the side.", period: 0.83, flight: 0.14,
        fx: (since) => ({ recoil: decay(since, 0.12), flash: decay(since, 0.06) }),
        shot: (f, to, u, s, col) => { line(f, lerp(f, to, u), A(col, 0.5 * (1 - u * 0.5)), 1.4); tracer(f, to, u, col, 2, 0.15); },
        impact: (to, v, s, col) => { if (v < 0.4) { glowDot(to, s * 0.07, A(col, 1 - v * 2.5)); } } },
    ] },

  // 2. Mortar Tower -------------------------------------------------------------------------------------
  { id: "mortar", num: 2, name: "Mortar Tower", cls: "Assault", weapon: "Explosive", hits: "ground", color: [1, 0.55, 0.2, 1],
    desc: "Lobs high-explosive shells at nearby enemies. \"Toob.\" Short range, heavy splash, ground only.",
    looks: [
      { key: "A", name: "Mortar Pit", muzzle: 0.18, theme: "A sandbagged pit with a stubby mortar tube on a baseplate and bipod, and a crate of shells.",
        draw(c, aim, s, fx, t, col) { sandbags(c, s, 0.38, 10); disc(c, s * 0.28, [0.2, 0.18, 0.14, 1]); plate(c, ngon(8, 0.16), GUNMETAL, 0, s, 0.8);
          const sink = fx.recoil * 0.04; disc(add(c, mul(fa(aim), s * 0.1)), s * (0.11 - sink), OUTLINE); disc(add(c, mul(fa(aim), s * 0.1)), s * (0.09 - sink), OLIVE); disc(add(c, mul(fa(aim), s * 0.1)), s * 0.05, DARK);
          plate(add(c, [s * 0.22, s * 0.2]), rectPts(0.09, 0.06), [0.45, 0.38, 0.22, 1], 0.3, s, 0.7); smokePuff(add(c, mul(fa(aim), s * 0.12)), 1 - fx.flash, s, 0.5); } },
      { key: "B", name: "Armoured Mortar Carrier", muzzle: 0.2, theme: "A small tracked armoured box with an open roof hatch; the mortar tube pokes up through it.",
        draw(c, aim, s, fx, t, col) { for (const y of [-0.36, 0.36]) plate(add(c, [0, y * s]), rectPts(0.42, 0.08), DARK, 0, s, 0.8);
          plate(c, rectPts(0.38, 0.3), OLIVE, 0, s, 1.2); rivets(c, rectPts(0.38, 0.3), 0, s, 0.85, 0.8); plate(c, rectPts(0.18, 0.18), dk(OLIVE, 0.3), 0, s, 0.9);
          const sink = fx.recoil * 0.03; disc(add(c, mul(fa(aim), s * 0.08)), s * (0.1 - sink), OUTLINE); disc(add(c, mul(fa(aim), s * 0.08)), s * (0.075 - sink), GUNMETAL); disc(add(c, mul(fa(aim), s * 0.08)), s * 0.04, DARK);
          smokePuff(add(c, mul(fa(aim), s * 0.1)), 1 - fx.flash, s, 0.5); } },
      { key: "C", name: "Turret Mortar", muzzle: 0.5, theme: "An automated breech-loading mortar turret: a boxy armoured turret with a thick short barrel that elevates to fire.",
        draw(c, aim, s, fx, t, col) { plate(c, ngon(8, 0.44), DARK, Math.PI / 8, s, 1); const r = fx.recoil * 0.08;
          plate(c, rectPts(0.3, 0.26), [0.4, 0.36, 0.28, 1], aim, s, 1.2); barrel(c, aim, s, 0.15, 0.5 - r, 0.14, GUNMETAL); disc(add(c, mul(fa(aim), (0.5 - r) * s)), s * 0.08, DARK);
          plate(add(c, mul(fa(aim), -s * 0.12)), rectPts(0.08, 0.2), dk(OLIVE, 0.1), aim, s, 0.8); glowDot(add(c, mul(fa(aim), -s * 0.2)), s * 0.03, A(col, 0.9)); flashAt(add(c, mul(fa(aim), (0.5 - r) * s)), aim, s, fx.flash); } },
    ],
    anims: [
      { key: "A", name: "Tube Drop", desc: "A thunk, a puff of smoke from the tube, and the shell arcs high before bursting on the pack.", period: 1.67, flight: 0.9,
        fx: (since) => ({ recoil: decay(since, 0.2), flash: decay(since, 0.5) }), shot: (f, to, u, s) => lobbed(f, to, u, s, [0.25, 0.27, 0.22, 1]), impact: (to, v, s, col) => blast(to, v, s, col, 0.55) },
      { key: "B", name: "Hard Thump", desc: "The whole tower jolts down on firing and a dust ring kicks out around it; the shell lands with a heavy blast.", period: 1.67, flight: 0.9,
        fx: (since) => ({ recoil: decay(since, 0.35), flash: decay(since, 0.3) }),
        shot: (f, to, u, s) => { lobbed(f, to, u, s, [0.25, 0.27, 0.22, 1]); }, impact: (to, v, s, col) => { blast(to, v, s, col, 0.65); ring(to, s * (0.3 + v), A([0.6, 0.5, 0.35, 1], 0.5 * (1 - v)), 3); } },
      { key: "C", name: "Flash and Smoke", desc: "A bright muzzle flash and a lingering smoke cloud drifting off the tube; a trail of smoke follows the shell.", period: 1.67, flight: 0.9,
        fx: (since) => ({ recoil: decay(since, 0.15), flash: decay(since, 0.9) }),
        shot: (f, to, u, s) => { for (let i = 1; i < 6; i++) { const w = Math.max(0, u - i * 0.04); const p = lerp(f, to, w); disc(add(p, [0, -Math.sin(Math.PI * w) * s * 1.1]), s * 0.04, [0.7, 0.7, 0.7, 0.3]); } lobbed(f, to, u, s, [0.25, 0.27, 0.22, 1]); },
        impact: (to, v, s, col) => blast(to, v, s, col, 0.55) },
    ] },

  // 3. Laser Tower --------------------------------------------------------------------------------------
  { id: "laser", num: 3, name: "Laser Tower", cls: "Assault", weapon: "Energy", hits: "both", color: [1, 0.28, 0.32, 1],
    desc: "A high-energy laser emitter on a rotating turret. \"It does more than just blind the enemy, that's for sure.\" A ramping beam that melts armour.",
    looks: [
      { key: "A", name: "Lens Turret", muzzle: 0.5, theme: "A rounded turret with one big circular focusing lens at the front and cooling fins down the sides.",
        draw(c, aim, s, fx, t, col) { plate(c, ngon(10, 0.42), DARK, 0, s, 1); plate(c, [[0.32, 0], [0.18, 0.26], [-0.26, 0.24], [-0.32, 0], [-0.26, -0.24], [0.18, -0.26]], STEEL, aim, s, 1.2);
          for (const sg of [-1, 1]) for (let i = 0; i < 3; i++) line(add(c, rot([(-0.2 + i * 0.12) * s, sg * 0.25 * s], aim)), add(c, rot([(-0.2 + i * 0.12) * s, sg * 0.32 * s], aim)), DARK, 2);
          const lp = add(c, mul(fa(aim), s * 0.34)); disc(lp, s * 0.16, OUTLINE); disc(lp, s * 0.13, mix(DARK, col, 0.3 + 0.7 * fx.glow)); glowDot(lp, s * (0.05 + 0.08 * fx.glow), A(col, 0.5 + 0.5 * fx.glow)); } },
      { key: "B", name: "Emitter Spire", muzzle: 0.42, theme: "A slim spire with stacked focusing rings, topped by a pivoting emitter head; the rings glow brighter as the beam ramps.",
        draw(c, aim, s, fx, t, col) { plate(c, ngon(6, 0.36), DARK, 0, s, 1); for (let i = 0; i < 3; i++) ring(c, s * (0.3 - i * 0.07), A(mix(STEEL, col, fx.glow * (0.4 + i * 0.2)), 0.9), 2.2);
          plate(c, [[0.42, 0], [0.1, 0.12], [-0.12, 0.08], [-0.12, -0.08], [0.1, -0.12]], STEEL, aim, s, 1); glowDot(add(c, mul(fa(aim), s * 0.4)), s * (0.04 + 0.06 * fx.glow), A(col, 0.6 + 0.4 * fx.glow)); } },
      { key: "C", name: "Mirror Dish", muzzle: 0.3, theme: "A concave mirror dish on a yoke that focuses the beam forward through a central prism.",
        draw(c, aim, s, fx, t, col) { plate(c, rectPts(0.38, 0.38), DARK, 0, s, 1); disc(c, s * 0.12, GUNMETAL);
          const d = add(c, mul(fa(aim), s * 0.04)); arc(d, s * 0.34, aim - 1.2, aim + 1.2, STEEL, s * 0.12); arc(d, s * 0.34, aim - 1.2, aim + 1.2, lt(STEEL, 0.4), s * 0.04);
          bar(add(c, mul(fa(aim), -s * 0.2)), add(c, mul(fa(aim), s * 0.22)), s * 0.05, GUNMETAL); fill(add(c, mul(fa(aim), s * 0.24)), ngon(4, 0.07), A(mix(STEEL, col, fx.glow), 1), aim, s); glowDot(add(c, mul(fa(aim), s * 0.26)), s * 0.06 * (0.5 + fx.glow), A(col, 0.8)); } },
    ],
    anims: [
      { key: "A", name: "Ramp Glow", desc: "The beam starts thin and thickens and whitens the longer it holds a target; the lens brightens with it.", beam: true, period: 1,
        fx: (lock, p, on) => ({ glow: on ? Math.min(1, 0.2 + lock / 3) : 0 }), shot: (f, to, lock, s, col) => beam(f, to, 1.5 + Math.min(1, lock / 3) * 3, col, 0.6 + Math.min(1, lock / 3) * 0.4) },
      { key: "B", name: "Pulse Hum", desc: "A steady beam with energy pulses travelling down it and expanding rings at the emitter.", beam: true, period: 1,
        fx: (lock, p, on) => ({ glow: on ? 0.6 + 0.4 * Math.sin(lock * 10) : 0 }),
        shot: (f, to, lock, s, col) => { beam(f, to, 2.4, col, 0.85); for (let i = 0; i < 3; i++) glowDot(lerp(f, to, fmod(lock * 1.6 + i / 3, 1)), s * 0.05, A([1, 1, 1, 1], 0.9)); ring(f, s * 0.1 * (1 + fmod(lock * 3, 1)), A(col, 1 - fmod(lock * 3, 1)), 1.5); } },
      { key: "C", name: "Heat Shimmer", desc: "The beam burns with sparks and armour flakes spraying off the target; heat vents glow on the tower.", beam: true, period: 1,
        fx: (lock, p, on) => ({ glow: on ? Math.min(1, 0.3 + lock / 2) : 0 }),
        shot: (f, to, lock, s, col, k, t) => { beam(f, to, 2.2 + Math.min(1, lock / 3) * 2, col, 0.9); for (let i = 0; i < 5; i++) { const a = t * 9 + i * 1.3, q = fmod(t * 3 + i * 0.2, 1); disc(add(to, mul(fa(a), s * 0.3 * q)), 1.4, A([1, 0.8, 0.4, 1], 1 - q)); } } },
    ] },

  // 4. Rocket Salvo -------------------------------------------------------------------------------------
  { id: "rocket", num: 4, name: "Rocket Salvo", cls: "Assault", weapon: "Explosive", hits: "both", color: [1, 0.85, 0.3, 1],
    desc: "Launches a volley of rockets at oncoming enemies. \"Instead of shooting bullets, it shoots very angry telephone poles that hate absolutely everything.\" Spread salvos, one rocket per enemy.",
    looks: [
      { key: "A", name: "Box Launcher", muzzle: 0.42, theme: "A boxy launcher pod with a 3x2 grid of tube mouths on a rotating base, like a truck-mounted rocket system.",
        draw(c, aim, s, fx, t, col) { disc(c, s * 0.4, DARK); disc(c, s * 0.32, GUNMETAL); const r = fx.recoil * 0.04;
          plate(add(c, mul(fa(aim), -r * s)), rectPts(0.36, 0.26), OLIVE, aim, s, 1.2);
          for (let i = 0; i < 3; i++) for (let j = 0; j < 2; j++) { const p = add(c, rot([(0.2 - r) * s, (-0.15 + i * 0.15) * s], aim)); disc(add(p, mul(orth(fa(aim)), (j - 0.5) * 0 * s)), s * 0.05, (i + j + Math.floor(t)) % 7 === 0 ? DARK : DARK); }
          for (let i = 0; i < 3; i++) { const p = add(c, rot([(0.28 - r) * s, (-0.15 + i * 0.15) * s], aim)); disc(p, s * 0.055, OUTLINE); disc(p, s * 0.04, mix(DARK, col, fx.flash * 0.6)); } } },
      { key: "B", name: "Rail Launcher", muzzle: 0.45, theme: "Open launch rails on a swivel mount with the rockets visible on them; a blast shield behind.",
        draw(c, aim, s, fx, t, col) { plate(c, ngon(8, 0.4), DARK, 0, s, 1); plate(add(c, mul(fa(aim), -s * 0.26)), rectPts(0.05, 0.3), STEEL, aim, s, 0.9);
          for (const y of [-0.16, 0, 0.16]) { bar(add(c, rot([-0.2 * s, y * s], aim)), add(c, rot([0.42 * s, y * s], aim)), s * 0.04, GUNMETAL);
            if (fx.flash < 0.5) fill(add(c, rot([0.12 * s, y * s], aim)), [[0.3, 0], [-0.25, 0.06], [-0.25, -0.06]], col, aim, s); } } },
      { key: "C", name: "Pod Turret", muzzle: 0.4, theme: "A round turret carrying two cylindrical rocket pods on its flanks, with a sensor head in the middle.",
        draw(c, aim, s, fx, t, col) { plate(c, ngon(10, 0.4), DARK, 0, s, 1); plate(c, ngon(10, 0.2, aim), GUNMETAL, 0, s, 1); glowDot(add(c, mul(fa(aim), s * 0.12)), s * 0.035, A(col, 0.9));
          for (const sg of [-1, 1]) { const pc = add(c, mul(orth(fa(aim)), sg * s * 0.27)); plate(pc, rectPts(0.24, 0.1), OLIVE, aim, s, 1);
            for (const y of [-0.04, 0.04]) { const p = add(pc, rot([0.2 * s, y * s], aim)); disc(p, s * 0.035, mix(DARK, col, fx.flash * 0.6)); } } } },
    ],
    anims: [
      { key: "A", name: "Ripple Fire", desc: "Rockets leave the tubes one after another, each with its own puff of smoke, curving onto separate enemies.", period: 2.5, burst: 3, gap: 0.14, multi: true, flight: 0.8,
        fx: (since) => ({ recoil: since < 0.45 ? 0.5 : 0, flash: since < 0.45 ? (Math.sin(since * 40) > 0 ? 1 : 0.3) : 0 }), shot: (f, to, u, s, col, k) => rocketAt(f, to, u, s, col, k), impact: (to, v, s, col) => blast(to, v, s, col, 0.35) },
      { key: "B", name: "Salvo Blast", desc: "All three launch together in one big backblast cloud behind the launcher.", period: 2.5, burst: 3, gap: 0, multi: true, flight: 0.8,
        fx: (since) => ({ recoil: decay(since, 0.3), flash: decay(since, 0.25) }),
        shot: (f, to, u, s, col, k) => { if (k === 0 && u < 0.4) disc(sub(f, mul(norm(sub(to, f)), s * 0.6 * (0.5 + u))), s * (0.15 + u * 0.4), [0.7, 0.7, 0.7, 0.4 * (1 - u * 2.5)]); rocketAt(f, to, u, s, col, k); },
        impact: (to, v, s, col) => blast(to, v, s, col, 0.4) },
      { key: "C", name: "Elevate and Fire", desc: "The launcher rocks up to elevate before each salvo, fires, then settles back down.", period: 2.5, burst: 3, gap: 0.1, multi: true, flight: 0.8,
        fx: (since, p) => ({ recoil: since < 0.6 ? Math.sin(since / 0.6 * Math.PI) : 0, flash: since < 0.3 ? 1 : 0 }),
        shot: (f, to, u, s, col, k) => rocketAt(f, to, u, s, col, k), impact: (to, v, s, col) => blast(to, v, s, col, 0.35) },
    ] },

  // 5. Anti-Aircraft Turret -----------------------------------------------------------------------------
  { id: "aa", num: 5, name: "Anti-Aircraft Turret", cls: "Assault", weapon: "Ballistic", hits: "air", color: [0.85, 1, 0.45, 1],
    desc: "A fully automatic anti-aircraft gun. \"We don't need a gun, or a nug!\" A direct-hit autocannon, air only.",
    looks: [
      { key: "A", name: "Twin Autocannon", muzzle: 0.68, theme: "Twin long barrels on an open mount with a gunner's seat and ammo clips stacked on top.",
        draw(c, aim, s, fx, t, col) { plate(c, ngon(8, 0.42), DARK, 0, s, 1); disc(c, s * 0.26, GUNMETAL); const r = fx.recoil * 0.06;
          for (const off of [-0.09, 0.09]) barrel(c, aim, s, 0, 0.68 - (off > 0 ? r : 0), 0.055, STEEL, off);
          plate(c, rectPts(0.18, 0.2), OLIVE, aim, s, 1); plate(add(c, mul(fa(aim), -s * 0.18)), rectPts(0.06, 0.08), [0.45, 0.4, 0.3, 1], aim, s, 0.7);
          flashAt(add(add(c, mul(orth(fa(aim)), 0.09 * s)), mul(fa(aim), (0.68 - r) * s)), aim, s, fx.flash); } },
      { key: "B", name: "Quad Mount", muzzle: 0.58, theme: "Four heavy machine guns on one swivel mount with a central sight; a wall of tracers.",
        draw(c, aim, s, fx, t, col) { plate(c, ngon(8, 0.4), DARK, Math.PI / 8, s, 1); plate(c, rectPts(0.18, 0.3), OLIVE, aim, s, 1.1);
          for (const off of [-0.22, -0.1, 0.1, 0.22]) barrel(c, aim, s, -0.05, 0.58 - fx.recoil * 0.04, 0.045, GUNMETAL, off);
          glowDot(add(c, mul(fa(aim), s * 0.1)), s * 0.035, A(col, 0.9)); flashAt(add(c, mul(fa(aim), 0.6 * s)), aim, s, fx.flash); } },
      { key: "C", name: "Radar Gun", muzzle: 0.62, theme: "A boxy self-contained turret with two side-mounted autocannons and a spinning search radar on the back.",
        draw(c, aim, s, fx, t, col) { plate(c, rectPts(0.4, 0.4), DARK, 0, s, 1); plate(c, rectPts(0.26, 0.22), OLIVE, aim, s, 1.2);
          for (const sg of [-1, 1]) barrel(c, aim, s, 0.1, 0.62 - fx.recoil * 0.05, 0.05, STEEL, sg * 0.27);
          const rp = add(c, mul(fa(aim), -s * 0.18)); line(add(rp, mul(fa(t * 4), s * 0.16)), add(rp, mul(fa(t * 4), -s * 0.16)), STEEL, s * 0.06); disc(rp, s * 0.04, col);
          flashAt(add(add(c, mul(orth(fa(aim)), 0.27 * s)), mul(fa(aim), 0.62 * s)), aim, s, fx.flash); } },
    ],
    anims: [
      { key: "A", name: "Skyward Bursts", desc: "Paired shots with flashes; each round bursts in a small black puff near the flyer.", period: 0.8, burst: 2, gap: 0.08, flight: 0.28,
        fx: (since) => ({ recoil: decay(since, 0.12), flash: decay(since, 0.08) }), shot: (f, to, u, s, col) => tracer(f, to, u, col, 1.8, 0.2),
        impact: (to, v, s) => { if (v < 0.8) disc(add(to, [0, -v * 4]), s * (0.08 + v * 0.18), [0.12, 0.12, 0.12, 0.6 * (1 - v)]); } },
      { key: "B", name: "Hosepipe", desc: "A near-continuous stream of tracers hosed across the sky.", period: 0.4, burst: 2, gap: 0.12, flight: 0.25,
        fx: (since) => ({ recoil: since < 0.3 ? 0.4 : 0, flash: Math.sin(since * 50) > 0 ? 1 : 0.3 }), shot: (f, to, u, s, col) => tracer(f, to, u, col, 1.5, 0.3),
        impact: (to, v, s, col) => { if (v < 0.3) glowDot(to, s * 0.05, col); } },
      { key: "C", name: "Track and Fire", desc: "The gun tracks smoothly, then fires a sharp pair; spent casings spray out and the radar keeps sweeping.", period: 0.8, burst: 2, gap: 0.05, flight: 0.25,
        fx: (since) => ({ recoil: decay(since, 0.15), flash: decay(since, 0.06) }),
        shot: (f, to, u, s, col, k) => { tracer(f, to, u, col, 2, 0.18); if (u < 0.3) disc(add(f, mul(orth(norm(sub(to, f))), s * (0.2 + u))), 1.5, [0.9, 0.75, 0.3, 1 - u * 3]); },
        impact: (to, v, s) => { if (v < 0.5) ring(to, s * (0.05 + v * 0.3), [1, 0.9, 0.6, 1 - v * 2], 1.5); } },
    ] },
];

const DEFAULTS = {};
