// ---- Scrapyard base-look page (restart, owner 2026-10-19: "Back to the drawing board") ------------------------------------------------------------
// Three new, clearly different looks for the 2x2 Scrapyard, each simple and bold with one clear focal element, and three payout animations.
// The directions are the owner's: an armoured vault depot, a wreck breaker's yard and a (simpler) smeltworks.
const PAGE = { title: "Scrapyard base look (restart)", store: "bl-tower-art-scrap-looks-1" };
const rnd = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };
const distTo = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const enemyR = (s) => Math.max(4, Math.min(11, s * 0.12));
function txt(p, str, col, px) { X.save(); X.font = "bold " + Math.round(px) + "px sans-serif"; X.textAlign = "center"; X.fillStyle = css(OUTLINE); X.fillText(str, p[0] + 1, p[1] + 1); X.fillStyle = css(col); X.fillText(str, p[0], p[1]); X.restore(); }
const GOLDC = [1, 0.78, 0.3, 1], COPPER = [0.78, 0.5, 0.28, 1], RUST = [0.45, 0.3, 0.2, 1], BRICK = [0.55, 0.27, 0.2, 1], MOLTEN = [1, 0.55, 0.15, 1], HOTM = [1, 0.85, 0.45, 1];
function scrapPile(p, r, k, seed) { const pts = []; for (let i = 0; i < 9; i++) { const a = i * TAU / 9; pts.push([Math.cos(a) * r * (0.65 + 0.35 * rnd(seed + i)), Math.sin(a) * r * (0.65 + 0.35 * rnd(seed + i + 20))]); }
  ellipse(add(p, [k * 1.5, k * 2.5]), r * k, r * k * 0.5, [0, 0, 0, 0.3]); solid(p, pts, mix(RUST, METAL, 0.4), 0, k, 1);
  for (let i = 0; i < 5; i++) { const q = add(p, [(rnd(seed + i * 3) - 0.5) * r * k * 1.1, (rnd(seed + i * 5) - 0.5) * r * k * 0.9]); line(q, add(q, mul(fa(rnd(seed + i) * TAU), r * k * 0.35)), i % 2 ? METAL_L : RUST, 1.4 * k); } }
function coinPop(c, v, s) { for (let i = 0; i < 6; i++) { const d = fa(-Math.PI / 2 + (i - 2.5) * 0.35), p = add(add(c, mul(d, s * 0.5 * Math.min(1, v * 2))), [0, v * v * s * 0.4]); disc(p, s * 0.045 + 1, A(OUTLINE, 0.95 * (1 - v))); disc(p, s * 0.045, A(GOLDC, 1 - v)); }
  txt(add(c, [0, -s * 0.4 - v * s * 0.5]), "+100", A(GOLDC, Math.min(1, 2 - v * 2)), Math.max(11, s * 0.2)); }
function scrapAgent(cfg) { return (m, t, info, s, col) => { if (!m.pays) { m.pays = []; m.last = t; }
  if (t - m.last >= 4) { m.last = t; m.pays.push(t); } m.pays = m.pays.filter((q) => t - q < 1.6);
  if (cfg.extra) cfg.extra(m, t, info, s, col);
  for (const q of m.pays) { const v = (t - q) / 1.6; cfg.pay(info.c, v, s, col, t); } }; }

const TOWERS = [
  { id: "scrap", num: 17, name: "Scrapyard", cls: "Utility", weapon: "None", hits: "none", size: 2, center: [0.3, 0.4], color: [0.95, 0.72, 0.42, 1],
    desc: "Various collections of scrap metal sold at a profit. \"One mans toxic waste is another mans potpourri\" A 2x2 yard; it attacks nothing and pays 100 credits at each round's clear (the preview pays every 4 s). Restart: three new looks, each with one bold focal element. (Colour: today's Scrapyard copper.)",
    looks: [
      { key: "A", name: "Armoured Vault Depot", muzzle: 0, fixed: true, theme: "A hardened compound: thick armoured walls with corner bunkers and a sliding gate, a searchlight sweeping the yard, and one huge round vault door in the middle, with a weighbridge and crushed-metal bales beside it.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, pay = decay(t - (mm.last ?? -9), 1.3), S = (x, y) => add(c, [x * k, y * k]);
          ellipse(add(c, [0, 8 * k]), 44 * k, 16 * k, [0, 0, 0, 0.3]); plate(c, rectPts(46, 46), lt(METAL_D, 0.05), 0, k, 1.4); fill(c, rectPts(41, 41), [0.2, 0.2, 0.21, 1], 0, k);
          for (const [x, y, w, h] of [[0, -43.5, 46, 2.6], [-43.5, 0, 2.6, 46], [43.5, 0, 2.6, 46], [-30, 43.5, 16, 2.6], [30, 43.5, 16, 2.6]]) { plate(S(x, y), rectPts(w, h), METAL, 0, k, 1.2); rivets(S(x, y), rectPts(w, h), 0, k, 0.84, 0.7 * k); }
          plate(S(-9.5, 43.5), rectPts(6, 1.8), METAL_L, 0, k, 1); plate(S(9.5, 43.5), rectPts(6, 1.8), METAL_L, 0, k, 1); hazard(S(0, 43.5), 0, k, -3, 3, 0, col, 1.6);
          for (const [x, y] of [[-43, -43], [43, -43], [-43, 43], [43, 43]]) { plate(S(x, y), ngon(8, 1, Math.PI / 8), METAL_L, 0, 6 * k, 1.3); disc(S(x, y), 2.4 * k, METAL_D); }
          const sp = S(43, -43), sa = Math.atan2(c[1] - sp[1], c[0] - sp[0]) + Math.sin(t * 0.8) * 0.8; poly([sp, add(sp, mul(fa(sa - 0.13), 62 * k)), add(sp, mul(fa(sa + 0.13), 62 * k))], [1, 1, 0.85, 0.1]); glowDot(sp, 1.1 * k, [1, 1, 0.85, 1]);
          const vc = S(0, -8); plate(vc, ngon(8, 1, Math.PI / 8), METAL_L, 0, 26 * k, 1.5); plate(vc, ngon(8, 1, Math.PI / 8), METAL, 0, 22.4 * k, 1.1); rivets(vc, ngon(8, 1, Math.PI / 8), 0, 26 * k, 0.9, 0.9 * k);
          disc(vc, 16.4 * k, OUTLINE); disc(vc, 15.4 * k, METAL_D); ring(vc, 13 * k, METAL_L, 1.8 * k); ring(vc, 9.6 * k, METAL, 1.2 * k); for (let i = 0; i < 12; i++) disc(add(vc, mul(fa(i * TAU / 12 + 0.2), 14.2 * k)), 0.9 * k, lt(METAL_L, 0.1));
          const wa = pay * 2.8 + 0.3; for (let i = 0; i < 6; i++) { const e = add(vc, mul(fa(wa + i * Math.PI / 3), 8 * k)); line(vc, e, METAL_L, 1.8 * k); disc(e, 1.3 * k, METAL_L); } disc(vc, 2.8 * k, METAL); glowDot(vc, (1 + 1.6 * pay) * k, A(GOLDC, 0.4 + 0.6 * pay)); glowDot(S(0, -34.5), 0.9 * k, pay > 0.05 ? GOLDC : [0.4, 1, 0.5, 1]);
          const wb = S(-26, 30); plate(wb, rectPts(15, 4.2), METAL_D, 0, k, 1.2); for (let i = -6; i <= 6; i++) line(add(wb, [i * 2.2 * k, -3 * k]), add(wb, [i * 2.2 * k, 3 * k]), [0, 0, 0, 0.3], 1); plate(S(-43, 30), rectPts(2.6, 3.4), METAL_L, 0, k, 1); glowDot(S(-43, 28.4), 0.5 * k, col);
          for (const [x, y] of [[22, 32], [31, 32], [26.5, 24.5]]) { plate(S(x, y), rectPts(4.2, 3.8), mix(RUST, METAL, 0.3), 0, k, 1.1); line(S(x - 4.2, y), S(x + 4.2, y), METAL_D, 1 * k); } } },
      { key: "B", name: "Wreck Breaker's Yard", muzzle: 0, fixed: true, theme: "A half-stripped tank hulk lying in the middle of a hazard-lined yard, its turret gone, a gantry with a cutting torch working over it in a spray of sparks, a drone hull and a pile of stripped plates in the corners.",
        draw(c, aim, s, fx, t, col) { const k = G(s), S = (x, y) => add(c, [x * k, y * k]), ang = -0.12, tc = S(0, 4), o = (x, y) => add(tc, rot([x * k, y * k], ang));
          ellipse(add(c, [0, 8 * k]), 44 * k, 16 * k, [0, 0, 0, 0.3]); plate(c, rectPts(46, 46), lt(METAL_D, 0.04), 0, k, 1.3); fill(c, rectPts(44, 44), [0.24, 0.22, 0.2, 1], 0, k); outline(c, rectPts(44, 44), A(col, 0.5 + 0.2 * Math.sin(t * 2.2)), 1.4 * k, 0, k);
          for (const y of [-30, 40]) hazard(S(0, y), 0, k, -40, 40, 0, col, 1.4);
          for (const sg of [-1, 1]) { plate(o(0, sg * 15), rectPts(29, 3.8), [0.13, 0.12, 0.12, 1], ang, k, 1.2); for (let j = -13; j <= 13; j += 2.6) line(o(j, sg * 12.6), o(j, sg * 17.4), [0.32, 0.3, 0.27, 1], 0.9 * k); }
          plate(tc, rectPts(26, 13.5), mix(RUST, METAL, 0.35), ang, k, 1.5); plate(o(10, -2.5), rectPts(8, 6), [0.1, 0.09, 0.09, 1], ang, k, 1); plate(o(-14, 3.5), rectPts(6, 5), [0.1, 0.09, 0.09, 1], ang, k, 1);
          disc(o(-3, 0), 8 * k, OUTLINE); disc(o(-3, 0), 7 * k, [0.05, 0.05, 0.05, 1]); ring(o(-3, 0), 7.6 * k, RUST, 1.8 * k); for (let i = 0; i < 6; i++) { const a = i * TAU / 6 + 0.3; line(add(o(-3, 0), mul(fa(a), 7.8 * k)), add(o(-3, 0), mul(fa(a), 9.6 * k)), mix(RUST, METAL_L, 0.3), 1.4 * k); }
          for (let i = -2; i <= 2; i++) line(o(14.5, i * 2.2), o(18.5, i * 2.2 + 0.7), [0.3, 0.14, 0.1, 1], 1.2 * k);
          bar(S(-36, -22), S(-14, -28), 3.2 * k, METAL_D); disc(S(-36, -22), 2 * k, METAL_D);
          const gx = Math.sin(t * 0.7) * 22, tip = o(gx, -2); bar(S(-44, -39), S(44, -39), 2.4 * k, METAL_D); for (const x of [-44, 44]) { plate(S(x, -36), rectPts(1.8, 4), METAL_L, 0, k, 1); } plate(S(gx, -39), rectPts(3, 2), METAL_L, 0, k, 1); line(S(gx, -39), tip, METAL_D, 1.2 * k); disc(tip, 1.2 * k, METAL);
          glowDot(tip, (0.8 + 0.3 * Math.sin(t * 40)) * k, [0.8, 0.9, 1, 1]); for (let i = 0; i < 9; i++) { const q = fmod(t * 3 + i / 9, 1), a = -Math.PI / 2 + (rnd(Math.floor(t * 3 + i / 9) + i) - 0.5) * 2.4; disc(add(tip, mul(fa(a), q * s * 0.22)), 1.2 * (1 - q) + 0.4, [1, 0.8, 0.4, 1 - q]); }
          const dr = S(30, 28); plate(dr, rectPts(7, 4.4), mix(RUST, METAL, 0.45), 0.3, k, 1.2); for (let i = 0; i < 4; i++) { const a = 0.3 + Math.PI / 4 + i * Math.PI / 2, e = add(dr, mul(fa(a), 9 * k)); bar(dr, e, 1.4 * k, METAL_D); ring(e, 3 * k, RUST, 1.2 * k); }
          scrapPile(S(-28, 28), 11, k, 5); scrapPile(S(-30, 10), 6, k, 12); } },
      { key: "C", name: "Smeltworks", muzzle: 0, fixed: true, theme: "One big smelter with a glowing crucible mouth and a single smoking chimney; a ladle arm swings out and pours into a stack of gold ingots at each payout. Nothing else.",
        draw(c, aim, s, fx, t, col) { const k = G(s), mm = fx.mem || {}, age = t - (mm.last ?? -9), pay = decay(age, 1.4), S = (x, y) => add(c, [x * k, y * k]), F = S(-10, -2);
          ellipse(add(c, [0, 8 * k]), 44 * k, 16 * k, [0, 0, 0, 0.3]); plate(c, rectPts(46, 46), lt(METAL_D, 0.03), 0, k, 1.3); fill(c, rectPts(44, 44), [0.16, 0.14, 0.13, 1], 0, k); outline(c, rectPts(44, 44), A(MOLTEN, 0.3 + 0.2 * Math.sin(t * 2.2)), 1.4 * k, 0, k);
          disc(F, 24 * k + 1.6 * k, OUTLINE); disc(F, 24 * k, BRICK); for (let i = 0; i < 28; i++) { const a = i * TAU / 28; line(add(F, mul(fa(a), 16 * k)), add(F, mul(fa(a), 23.4 * k)), [0.3, 0.14, 0.1, 1], 1.1 * k); } ring(F, 18.5 * k, [0.75, 0.4, 0.28, 1], 1.4 * k); ring(F, 23 * k, METAL, 2 * k);
          const fl = 0.5 + 0.5 * Math.sin(t * 6); disc(F, 13 * k, OUTLINE); disc(F, 12 * k, mix([0.4, 0.1, 0.04, 1], MOLTEN, 0.45 + 0.35 * fl + 0.2 * pay)); disc(F, (5 + 1.4 * fl) * k, A(HOTM, 0.9)); glowDot(F, (2 + 1.6 * pay) * k, HOTM);
          const ch = S(8, -34); disc(ch, 6.6 * k, OUTLINE); disc(ch, 5.8 * k, METAL_D); disc(ch, 3.2 * k, [0.05, 0.05, 0.05, 1]); for (let i = 0; i < 5; i++) { const u = fmod(t * 0.5 + i / 5, 1); disc(add(ch, [u * 5 * k, -u * 20 * k]), (1.6 + u * 4) * k, A([0.5, 0.48, 0.46, 1], 0.55 * (1 - u))); }
          const pv = S(14, 12), a0 = Math.PI * 0.82, a1 = 0.45, sw = age < 0.5 ? ease(age / 0.5) : age < 1.1 ? 1 : 1 - ease(Math.min(1, (age - 1.1) / 0.5)), ba = a0 + (a1 - a0) * sw, tipL = add(pv, mul(fa(ba), 24 * k));
          disc(pv, 3.4 * k, OUTLINE); disc(pv, 2.8 * k, METAL); bar(pv, tipL, 2.4 * k, [0.85, 0.65, 0.2, 1]); disc(tipL, 3.4 * k, OUTLINE); disc(tipL, 2.8 * k, METAL_D); disc(tipL, 1.8 * k, mix([0.4, 0.1, 0.04, 1], MOLTEN, 0.7));
          if (sw > 0.9 && age < 1.1) line(tipL, S(30, 24), A(MOLTEN, 0.95), 1.8 * k);
          const ig = S(30, 28); for (let r = 0; r < 3; r++) for (let q = 0; q <= 2 - r; q++) { const p = add(ig, [(q - (2 - r) / 2) * 7.6 * k, -r * 3.6 * k]); fill(p, [[-3.4, -1.7], [3.4, -1.7], [2.6, 1.7], [-2.6, 1.7]], mix([0.9, 0.7, 0.2, 1], HOTM, 0.5 * pay), 0, k); outline(p, [[-3.4, -1.7], [3.4, -1.7], [2.6, 1.7], [-2.6, 1.7]], OUTLINE, 1 * k, 0, k); }
          glowDot(add(ig, [0, -3 * k]), (0.8 + 2 * pay) * k, A(GOLDC, 0.3 + 0.7 * pay)); scrapPile(S(-30, 32), 8, k, 3); } },
    ],
    anims: [
      { key: "A", name: "Round Payout", desc: "At each round's clear a spray of credit coins pops out of the yard with a floating +100, and the yard's focal part (the vault wheel, the ingots or the smelter) reacts.", period: 1, flight: 1, fx: () => ({}),
        persist: scrapAgent({ pay: (c, v, s, col) => coinPop(c, v, s, col) }) },
      { key: "B", name: "Sparks and Sale", desc: "Cutting sparks fly all the time; at the payout a stack of credits flashes on the yard and the +100 rises from it.", period: 1, flight: 1, fx: () => ({}),
        persist: scrapAgent({ extra: (m, t, info, s) => { for (let i = 0; i < 6; i++) { const q = fmod(t * 2.2 + i / 6, 1), o = add(info.c, [(rnd(Math.floor(t * 2.2 + i / 6) + i) - 0.5) * s * 1.2, (rnd(i + 3) - 0.5) * s]); disc(add(o, mul(fa(-1.2 - i * 0.3), q * s * 0.2)), 1.2, [1, 0.8, 0.4, 1 - q]); } },
          pay: (c, v, s, col) => { if (v < 0.3) glowDot(c, s * 0.3 * (1 - v / 0.3), GOLDC); for (let j = 0; j < 4; j++) ellipse(add(c, [0, -j * s * 0.05]), s * 0.12, s * 0.05, A(dk(GOLDC, 0.2), 1 - v)); txt(add(c, [0, -s * 0.45 - v * s * 0.5]), "+100", A(GOLDC, Math.min(1, 2 - v * 2)), Math.max(11, s * 0.2)); } }) },
      { key: "C", name: "Wreck Collector", desc: "Shows the kill bonus too: an enemy wrecked near the yard bursts and its scrap flies into the yard as a coin; the round payout pops +100.", period: 1, flight: 1, fx: () => ({}),
        persist: scrapAgent({ extra: (m, t, info, s, col) => { const near = info.all.filter((e) => !e.air && distTo(e.p, info.c) < s * 3.1);
            if (near.length && (!m.kill || t - m.kill.t0 > 1.5)) { const e = near[Math.floor(rnd(Math.floor(t)) * near.length)]; m.kill = { t0: t, p: e.p.slice() }; }
            if (m.kill) { const v = (t - m.kill.t0) / 1.0; if (v < 0.3) blast(m.kill.p, v / 0.3, s, col, 0.25); if (v < 1) { const p = add(lerp(m.kill.p, info.c, v), [0, -Math.sin(Math.PI * v) * s * 0.5]); disc(p, s * 0.05 + 1, OUTLINE); disc(p, s * 0.05, GOLDC); if (v < 0.5) txt(add(m.kill.p, [0, -s * 0.25 - v * s * 0.3]), "+5", A(GOLDC, 1 - v * 2), Math.max(9, s * 0.15)); } } },
          pay: (c, v, s, col) => coinPop(c, v, s, col) }) },
    ] },
];
const DEFAULTS = { scrap: { look: "A", anim: "B" } };
