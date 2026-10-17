// ---- Tower art second pass: Laser Tower (tower 3), round 1 ------------------------------------------------------
// Base: look A Lance Emitter, animation A Steady Beam (locks on first). One parametric model, with the lessons so far:
// options swap parts rather than lay overlays over them; extra emitters carry the other paths' details; the beam itself
// changes with the Power path (ramp, width, heat); only the turret turns (the deck kit stays put).
// Geometry (game px, x along the aim): hex hull r ~10, heat-sink fins on both flanks (x -3..-8, y 5..9), lance barrel
// from x 4 to its tip at x 21 with focusing rings at 8 / 12 / 16, a crystal at the tip, a capacitor orb at x -4.
const PAGE = { title: "Laser Tower: paths and Retrofits (second pass)", store: "bl-tower-art-p2-laser-r1" };
const GOLD = [1, 0.78, 0.3, 1], STEEL = [0.42, 0.45, 0.5, 1], COPPER = [0.78, 0.5, 0.28, 1], COOL = [0.35, 0.6, 0.9, 1];
const Kp = (B, pi, k) => (B.lv[pi] > k ? B.key("p" + pi + "s" + k) : null);
const rnd2 = (x) => { const v = Math.sin(x * 12.9898) * 43758.5453; return v - Math.floor(v); };

// ---- Numbers that drive the look -------------------------------------------------------------------------------
const rampTime = (B) => Math.min([3, 3, 2.2, 2.2, 1.8, 1.5][B.lv[0]], B.r === 2 ? 2.4 : 9);
const ceilingOf = (B) => [3, 3.5, 3.5, 5, 6, 8][B.lv[0]] + (B.r === 1 ? 0.5 : 0);
const beamsOf = (B) => [1, 2, 2, 3, 3, 4][B.lv[1]];
const extraPower = (B) => [1, 0.4, 0.6, 0.6, 0.75, 0.75][B.lv[1]];
const tipX = (B) => [21, 24, 27, 31, 34, 37][B.lv[2]];
const sideEmitters = (B) => [Kp(B, 1, 0), Kp(B, 1, 2), Kp(B, 1, 4)].includes("B");
const sideAt = (i) => [[2, -8.5], [2, 8.5], [6, -8.5]][i - 1];

// ---- Beams: width and heat grow with the ramp; Power's later steps whiten it; the mastery wraps it in gold ----------
function rampBeam(f, to, g, B, col, frac, s) { const ceil = ceilingOf(B), heat = Math.min(1, g * (ceil - 2) / 6);
  const w = (1.2 + 3.4 * g * ceil / 8) * Math.sqrt(frac), c2 = B.lv[0] >= 3 ? mix(col, WHITE, 0.55 * heat) : col;
  if (B.lv[0] >= 5 && g > 0.95) line(f, to, A(GOLD, 0.35), w * 3.2);
  beam(f, to, w, c2, 0.6 + 0.4 * g);
  if (Kp(B, 0, 3) === "C" && g > 0.6) for (let i = 0; i < 3; i++) { const q = lerp(f, to, fmod(i / 3 + s * 0.0001, 1) * 0.3); line(add(q, [0, -3]), add(q, [2, -7]), [1, 0.9, 0.8, 0.2 * heat], 1); } }
function extraLock(p, q, s, col) { const r0 = s * (0.35 - 0.18 * q); for (let i = 0; i < 4; i++) { const a0 = i * Math.PI / 2 + q * 4; arc(p, r0, a0, a0 + 0.7, A(col, 0.5 + 0.5 * q), 2); } }

// ---- The model -----------------------------------------------------------------------------------------------------
function crystal(p, aim, k, col, g, z, gold) { solid(p, [[3.8, 0], [0, 2.8], [-3.8, 0], [0, -2.8]].map((q) => mul(q, z)), A(gold ? GOLD : col, 0.85), aim, k, 1); glowDot(p, (0.8 + 1.8 * g) * k * z, WHITE); }
function prism(p, aim, k, col, g, n, clear, gold) { const tri = ngon(n, 3.6, aim); solid(p, tri, A(clear ? mix(col, WHITE, 0.7) : col, 0.75), 0, k, 1); if (gold) outline(p, tri, GOLD, 1.2 * k, 0, k); glowDot(p, (0.9 + 1.5 * g) * k, WHITE); }
function emitterKit(p, aim, k, col, g, B, t) { // the side emitters carry Power's heat and Range's sleeve
  plate(p, rectPts(3.4, 2.2), METAL_L, aim, k, 1); bar(p, add(p, mul(fa(aim), 6 * k)), 1.6 * k, METAL);
  if (B.lv[0] >= 1) line(add(p, mul(fa(aim), 1 * k)), add(p, mul(fa(aim), 5 * k)), A(col, 0.3 + 0.6 * g), 0.9 * k);
  if (B.lv[2] >= 1) ring(add(p, mul(fa(aim), 5 * k)), 1.4 * k, METAL_L, 0.8 * k);
  if (B.lv[1] >= 5) ring(add(p, mul(fa(aim), 6.4 * k)), 1.4 * k, GOLD, 0.9 * k);
  glowDot(add(p, mul(fa(aim), 6.4 * k)), (0.6 + 1 * g) * k, col); }

const P2 = {
  tower: "laser", look: "A", anim: "A",
  intro: "Round 1: three options for every step and Retrofit, as one model. The beam itself changes with the Power path (it ramps wider and hotter, whitening at Overdrive, wrapped in gold at the mastery); Multi-Target adds beams that lock and ramp on their own targets; Range swaps in a longer lance. Only the turret turns. Unpicked steps show option A.",
  mods(B) { return { shot: (f, to, lock, s, col, kk, t, info) => {
      const g = Math.min(1, lock / rampTime(B)); if (info) info.view.ramp = g; rampBeam(f, to, g, B, col, 1, s);
      const nb = beamsOf(B); if (nb < 2 || !info) return; const v = info.view; v.locks ||= {}; const k = G(s), aim = info.aim, c = info.c;
      for (let i = 1; i < nb; i++) { const e = info.order && info.order[i]; if (!e) continue; v.locks[e.i] ??= t; for (const id in v.locks) if (!info.order.some((x) => x.i == id)) delete v.locks[id];
        const held = t - v.locks[e.i], on = held >= 0.6, origin = sideEmitters(B) ? add(P(c, aim, k, ...sideAt(i)), mul(fa(aim), 6.4 * k)) : add(P(c, aim, k, tipX(B), 0), mul(orth(fa(aim)), (i % 2 ? 1 : -1) * 1.2 * k));
        if (!on) { line(origin, e.p, A(col, 0.25), 1); extraLock(e.p, held / 0.6, s, col); continue; }
        const g2 = B.lv[1] >= 5 ? Math.min(1, (held - 0.6) / rampTime(B)) : g; rampBeam(origin, e.p, g2, B, col, extraPower(B), s); } } }; },
  muzzleAt(B, m, kk, c, aim, s) { return P(c, aim, G(s), tipX(B), 0); },
  model(c, aim, s, fx, t, col, info, B) {
    const k = G(s), on = (fx.glow || 0) > 0, g = on ? (info.view.ramp ?? 0.3) : 0, tip = tipX(B), gold = B.lv[0] >= 5;
    const kp = (pi, kk) => Kp(B, pi, kk), S = (x, y) => P(c, 0, k, x, y);
    deck(c, k, col, t);
    // Deck kit (fixed): the Capacitor Bank's drums or stack.
    if (B.r === 0) { const st = B.key("r0");
      if (st === "A") for (const [x, y] of [[-12, -6], [-12, 6]]) { disc(S(x, y), 3 * k, OUTLINE); disc(S(x, y), 2.6 * k, METAL); ring(S(x, y), 1.8 * k, A(col, 0.3 + 0.7 * g), 1 * k); }
      if (st === "B") { plate(S(-12.5, 0), rectPts(2.4, 6.5), METAL, 0, k, 1); for (let i = 0; i < 4; i++) line(S(-14, -4.5 + i * 3), S(-11, -4.5 + i * 3), A(col, g * 4 > i ? 0.95 : 0.25), 1.2 * k); }
      if (st === "C") { ring(c, 13.5 * k, OUTLINE, 3 * k); ring(c, 13.5 * k, METAL, 2 * k); ring(c, 13.5 * k, A(col, 0.2 + 0.6 * g), 0.8 * k); } }
    // Heat-sink fins on the flanks (the Heat Sinks Retrofit and Thermal Lock B make them bigger).
    const finL = B.r === 1 && B.key("r1") === "A" ? 12 : kp(0, 3) === "B" ? 11 : 9, finN = B.r === 1 ? 4 : 3;
    for (const y of [-1, 1]) for (let i = 0; i < finN; i++) bar(P(c, aim, k, -3 - 2.3 * i, y * 5), P(c, aim, k, -3 - 2.3 * i, y * finL), 1.3 * k, gold && kp(0, 4) === "C" ? GOLD : METAL_L);
    if (B.r === 1 && B.key("r1") === "B") for (const y of [-7.5, 7.5]) { plate(P(c, aim, k, -6, y), rectPts(3.4, 1.6), METAL, aim, k, 1); for (let i = 0; i < 4; i++) line(P(c, aim, k, -8.5 + i * 1.6, y - 1.2), P(c, aim, k, -8.5 + i * 1.6, y + 1.2), [0, 0, 0, 0.4], 0.7 * k); }
    if (B.r === 1 && B.key("r1") === "C") { const fp = P(c, aim, k, -7, 0); disc(fp, 3.4 * k, OUTLINE); disc(fp, 3 * k, METAL); for (let i = 0; i < 4; i++) line(fp, add(fp, mul(fa(t * 10 + i * Math.PI / 2), 2.7 * k)), METAL_L, 1 * k); }
    // The hull.
    plate(c, [[7, 0], [1, 6], [-9, 5], [-11, 0], [-9, -5], [1, -6]], METAL_L, aim, k, 1.2);
    if (kp(0, 0) === "C") for (const y of [-3, 3]) line(P(c, aim, k, -8, y), P(c, aim, k, -2, y), A([1, 0.5, 0.2, 1], 0.3 + 0.6 * g * (0.6 + 0.4 * Math.sin(t * 20 + y))), 1.2 * k);
    if (kp(0, 1) === "B") { plate(P(c, aim, k, -1, -4), rectPts(4, 0.9), BORE, aim, k, 0.8); line(P(c, aim, k, -4.5, -4), P(c, aim, k, -4.5 + 7 * g, -4), A(col, 0.95), 1.2 * k); }
    if (kp(0, 2) === "C") for (const y of [-2.2, 2.2]) bar(P(c, aim, k, -4, y), P(c, aim, k, 5, y * 0.4), 0.9 * k, COPPER);
    // The lance: swapped longer along the Range path (rings spread along it), on the hull.
    bar(P(c, aim, k, 4, 0), P(c, aim, k, tip, 0), (kp(2, 2) === "A" ? 2.6 : 3) * k, METAL);
    if (kp(2, 2) === "C") for (const y of [-2.2, 2.2]) bar(P(c, aim, k, 6, y), P(c, aim, k, tip - 2, y), 0.9 * k, METAL_L);
    if (kp(2, 2) === "B") for (const y of [-1, 1]) bar(P(c, aim, k, 2, y * 5), P(c, aim, k, tip * 0.6, y * 1.6), 1 * k, STEEL);
    strip(P(c, aim, k, 5, 0), P(c, aim, k, tip, 0), 0.6 * k, A(col, 0.35 + 0.6 * g));
    if (kp(0, 2) === "B") strip(P(c, aim, k, 5, 1), P(c, aim, k, tip - 1, 1), 0.5 * k, A(col, 0.35 + 0.6 * g));
    const ringXs = [8, 12, 16].map((x) => 4 + (x - 4) * (tip - 4) / 17), ringCol = gold && kp(0, 4) === "A" ? GOLD : B.lv[2] >= 5 && kp(2, 4) !== "C" ? GOLD : dk(col, 0.2);
    for (const x of ringXs) bar(P(c, aim, k, x, -3.2), P(c, aim, k, x, 3.2), 1.5 * k, ringCol);
    if (kp(2, 1) === "A") for (const x of ringXs) bar(P(c, aim, k, x + 1.6, -2.6), P(c, aim, k, x + 1.6, 2.6), 1 * k, METAL_L);
    if (kp(2, 1) === "B") plate(P(c, aim, k, tip - 6, 0), rectPts(2, 2.4), METAL_L, aim, k, 1);
    if (kp(2, 1) === "C") ring(P(c, aim, k, tip - 2, 0), 2.6 * k, METAL_L, 1 * k);
    if (kp(2, 0) === "B") bar(P(c, aim, k, tip - 4, 0), P(c, aim, k, tip - 0.5, 0), 4.2 * k, METAL_L);
    if (kp(2, 0) === "C") bar(P(c, aim, k, -2, -2.4), P(c, aim, k, tip * 0.7, -2.4), 0.8 * k, METAL_L);
    if (kp(0, 1) === "A") { const q = P(c, aim, k, tip - 3, 0); ring(q, 3 * k, METAL_L, 1 * k); arc(q, 3 * k, t * 6, t * 6 + 1.4, A(col, 0.9), 1 * k); }
    if (kp(0, 3) === "A") bar(P(c, aim, k, 7, 0), P(c, aim, k, tip - 4, 0), 4.4 * k, A(COOL, 0.9));
    if (kp(0, 0) === "B") for (let x = 6; x < tip - 3; x += 1.4) line(P(c, aim, k, x, -2), P(c, aim, k, x + 0.7, 2), A([1, 0.45, 0.2, 1], 0.4 + 0.6 * g), 0.9 * k);
    if (kp(2, 3) === "B") for (const y of [-1, 1]) plate(P(c, aim, k, tip - 8, y * 3), [[2, 0], [-2, y * 2.4], [-2, 0]], STEEL, aim, k, 0.9);
    if (kp(2, 3) === "C") { plate(P(c, aim, k, 3, 4.5), rectPts(2, 1.4), METAL, aim, k, 0.9); glowDot(P(c, aim, k, 5, 4.5), 0.6 * k, [1, 0.3, 0.3, 1]); }
    if (B.lv[2] >= 5 && kp(2, 4) === "B") { bar(P(c, aim, k, -4, -6), P(c, aim, k, 12, -6), 2.4 * k, METAL); ring(P(c, aim, k, 12, -6), 1.6 * k, GOLD, 1 * k); }
    // The tip: crystal, or a prism / fork when the Multi-Target path splits the beam.
    const tp = P(c, aim, k, tip, 0), M = B.lv[1], mk = kp(1, M >= 5 ? 4 : M >= 3 ? 2 : 0);
    if (M >= 1 && !sideEmitters(B)) { if (kp(1, 0) === "C" && M < 3) { for (const y of [-1.8, 1.8]) crystal(P(c, aim, k, tip, y), aim, k, col, g, 0.6); }
      else prism(tp, aim, k, col, g, M >= 5 ? 4 : 3, kp(1, 3) === "A", M >= 5);
      if (kp(1, 1) === "A") ring(tp, 4.6 * k, METAL_L, 0.9 * k); if (kp(1, 1) === "C") outline(tp, ngon(6, 5.2, aim), METAL_L, 1.2 * k, 0, k);
      if (kp(1, 3) === "C") for (const y of [-1, 1]) bar(P(c, aim, k, tip - 3, y * 3.4), P(c, aim, k, tip + 1, y * 3.4), 0.8 * k, COOL);
      if (M >= 5 && kp(1, 4) === "C") for (let i = 0; i < 4; i++) solid(add(tp, mul(fa(aim + i * Math.PI / 2 + t), 6 * k)), ngon(3, 1.2, t), A(GOLD, 0.9), 0, k, 0.6); }
    else crystal(tp, aim, k, col, g, kp(0, 0) === "A" ? 1.3 : 1, gold && kp(0, 4) === "A");
    if (B.lv[2] >= 5 && kp(2, 4) === "C") { orb(tp, 4.2 * k, mix(col, WHITE, 0.3)); ring(tp, 4.4 * k, GOLD, 1.2 * k); glowDot(tp, (1 + 1.6 * g) * k, WHITE); }
    if (B.r === 2) { const st = B.key("r2"); ell2(tp, aim, k, st === "A" ? 5 : 4, col, g); if (st === "B") ell2(P(c, aim, k, tip - 3, 0), aim, k, 3.4, col, g); if (st === "C") ring(tp, 6 * k, A(col, 0.5 + 0.4 * Math.sin(t * 6)), 1.2 * k); }
    if (M >= 1 && sideEmitters(B)) for (let i = 1; i < beamsOf(B); i++) emitterKit(P(c, aim, k, ...sideAt(i)), aim, k, col, g, B, t);
    // The capacitor orb; Overdrive A's core and the Annihilator B core glow with the ramp.
    orb(P(c, aim, k, -4, 0), (kp(0, 2) === "A" ? 3 : 2.2) * k, dk(col, 0.3)); if (kp(0, 2) === "A") glowDot(P(c, aim, k, -4, 0), (0.8 + 1.4 * g) * k, mix(col, WHITE, 0.4));
    if (gold && kp(0, 4) === "B") { ring(P(c, aim, k, -4, 0), 3.4 * k, GOLD, 1.2 * k); glowDot(P(c, aim, k, -4, 0), (1 + 1.6 * g) * k, [1, 0.9, 0.6, 1]); }
  },
  paths: [
    { name: "Power", theme: "a faster, higher ramp; the beam grows wider and hotter", steps: [
      { name: "Hotter Emitter", cost: 60, effect: "Ramp ceiling x3.5", options: [
        { key: "A", name: "Hot Crystal", desc: "A bigger emitter crystal at the tip; the beam ramps wider." },
        { key: "B", name: "Glow Coils", desc: "Coils wrapped round the lance glow red-hot as the beam ramps." },
        { key: "C", name: "Heat Vents", desc: "Vents on the hull flicker orange as the beam ramps." } ] },
      { name: "Quick Focus", cost: 60, effect: "Ramp time 3 to 2.2 s", options: [
        { key: "A", name: "Focus Ring", desc: "A spinning focus ring near the tip." },
        { key: "B", name: "Charge Bar", desc: "A charge bar on the hull that fills as the beam ramps." },
        { key: "C", name: "Fast Focus", desc: "No new part: the beam reaches full width visibly faster." } ] },
      { name: "Overdrive", cost: 815, effect: "Ramp ceiling x5 (primary)", options: [
        { key: "A", name: "Overdrive Core", desc: "A bigger capacitor core that glows with the ramp; the beam whitens as it heats." },
        { key: "B", name: "Twin Strips", desc: "A second light strip along the lance; the beam whitens as it heats." },
        { key: "C", name: "Power Cables", desc: "Copper power cables from the core to the lance; the beam whitens as it heats." } ] },
      { name: "Thermal Lock", cost: 1425, effect: "Ceiling x6; ramp time 1.8 s", options: [
        { key: "A", name: "Coolant Jacket", desc: "A blue coolant jacket on the lance." },
        { key: "B", name: "Big Heat Sinks", desc: "Longer heat-sink fins on the flanks." },
        { key: "C", name: "Heat Haze", desc: "The air shimmers above the beam once it's hot." } ] },
      { name: "Annihilator", cost: 5535, effect: "Ceiling x8 in 1.5 s: the boss killer (mastery)", options: [
        { key: "A", name: "Gold Lance", desc: "A gold crystal and gold focusing rings; at full ramp the beam is wrapped in gold." },
        { key: "B", name: "Annihilator Core", desc: "A gold-ringed core blazing with the ramp; at full ramp the beam is wrapped in gold." },
        { key: "C", name: "Gold Heat Sinks", desc: "Gold heat-sink fins; at full ramp the beam is wrapped in gold." } ] },
    ] },
    { name: "Multi-Target", theme: "prism split: more beams, each locking on its own target", steps: [
      { name: "Beam Splitter", cost: 200, effect: "A second beam on another target at 40% power", options: [
        { key: "A", name: "Splitter Prism", desc: "A prism at the tip splits off a thinner second beam." },
        { key: "B", name: "Side Emitter", desc: "A small emitter on the flank fires the second beam (it carries the main lance's details)." },
        { key: "C", name: "Fork Tip", desc: "Twin crystals at the tip, one per beam." } ] },
      { name: "Tuned Splitter", cost: 200, effect: "The second beam at 60%", options: [
        { key: "A", name: "Tuning Ring", desc: "A ring round the prism; the second beam thickens." },
        { key: "B", name: "Thicker Beam", desc: "No new part: the second beam thickens." },
        { key: "C", name: "Prism Housing", desc: "A hexagonal housing round the prism; the second beam thickens." } ] },
      { name: "Prism", cost: 1190, effect: "3 beams (extras at 60%) (primary)", options: [
        { key: "A", name: "Big Prism", desc: "A bigger triangular prism at the tip splits three beams." },
        { key: "B", name: "Twin Side Emitters", desc: "An emitter on each flank fires the extra beams." },
        { key: "C", name: "Prism Cluster", desc: "A clustered prism at the tip splits three beams." } ] },
      { name: "Clear Prism", cost: 1190, effect: "Extra beams at 75%", options: [
        { key: "A", name: "Clear Crystal", desc: "The prism turns clear and bright." },
        { key: "B", name: "Brighter Beams", desc: "No new part: the extra beams brighten and thicken." },
        { key: "C", name: "Prism Coolers", desc: "Blue cooling bars either side of the prism." } ] },
      { name: "Prism Array", cost: 5950, effect: "4 beams (extras at 75%); each ramps on its own target (mastery)", options: [
        { key: "A", name: "Gold Prism Array", desc: "A four-faced gold-edged prism; each beam ramps on its own target." },
        { key: "B", name: "Quad Emitters", desc: "Three gold-tipped flank emitters plus the lance; each beam ramps on its own." },
        { key: "C", name: "Prism Halo", desc: "Four gold prism shards orbit the tip; each beam ramps on its own." } ] },
    ] },
    { name: "Range/Targeting", theme: "a longer lance (kept mid-range)", steps: [
      { name: "Extended Optics", cost: 50, effect: "+15 range (165)", options: [
        { key: "A", name: "Longer Lance", desc: "The lance is swapped for a longer one; the rings spread along it." },
        { key: "B", name: "Optic Sleeve", desc: "A longer lance with a thick optic sleeve at the tip." },
        { key: "C", name: "Sight Rail", desc: "A longer lance with a sight rail along it." } ] },
      { name: "Collimator", cost: 100, effect: "+15 range (180)", options: [
        { key: "A", name: "Collimator Rings", desc: "A second ring beside each focusing ring." },
        { key: "B", name: "Collimator Box", desc: "A collimator box on the lance near the tip." },
        { key: "C", name: "Iris Ring", desc: "An iris ring just behind the tip." } ] },
      { name: "Lance", cost: 395, effect: "+30 range (210) (primary)", options: [
        { key: "A", name: "Slim Lance", desc: "A longer, slimmer lance." },
        { key: "B", name: "Braced Lance", desc: "A longer lance braced from the hull." },
        { key: "C", name: "Rail Lance", desc: "A longer lance between twin rails." } ] },
      { name: "Long Lance", cost: 795, effect: "+30 range (240)", options: [
        { key: "A", name: "Even Longer", desc: "The lance grows again." },
        { key: "B", name: "Stabiliser Fins", desc: "A longer lance with stabiliser fins." },
        { key: "C", name: "Rangefinder", desc: "A longer lance with a rangefinder on the hull." } ] },
      { name: "Deep Lance", cost: 2115, effect: "280 range (mastery)", options: [
        { key: "A", name: "Gold Rings", desc: "The longest lance, with gold focusing rings." },
        { key: "B", name: "Targeting Scope", desc: "The longest lance, gold rings, and a gold-ringed targeting scope." },
        { key: "C", name: "Deep Lens", desc: "The longest lance ending in a big gold-rimmed lens." } ] },
    ] },
  ],
  retrofits: [
    { name: "Capacitor Bank", cost: 160, effect: "+8 damage per second (25 to 33)", options: [
      { key: "A", name: "Capacitor Drums", desc: "Two capacitor drums on the deck that pulse as the beam ramps." },
      { key: "B", name: "Capacitor Stack", desc: "A capacitor stack on the deck whose bars light up with the ramp." },
      { key: "C", name: "Capacitor Ring", desc: "A ring capacitor round the deck that brightens with the ramp." } ] },
    { name: "Heat Sinks", cost: 60, effect: "Ramp ceiling x3 to x3.5", options: [
      { key: "A", name: "Long Fins", desc: "Four longer cooling fins on each flank." },
      { key: "B", name: "Radiator Blocks", desc: "Finned radiator blocks on both flanks." },
      { key: "C", name: "Cooling Fan", desc: "A spinning fan at the back of the hull." } ] },
    { name: "Focusing Lens", cost: 15, effect: "Ramp time 3 to 2.4 s", options: [
      { key: "A", name: "Big Lens", desc: "A big glowing lens on the emitter." },
      { key: "B", name: "Double Lens", desc: "Two lenses along the tip." },
      { key: "C", name: "Lens Ring", desc: "A lens with a pulsing focus ring." } ] },
  ],
};
function ell2(p, aim, k, r, col, g) { oval(p, r * 0.6 * k, r * k, aim, A(mix(col, WHITE, 0.4), 0.55 + 0.3 * g)); ring(p, r * k, OUTLINE, 1); glowDot(p, (0.8 + g) * k, WHITE); }
