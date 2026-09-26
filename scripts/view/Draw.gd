extends RefCounted
## Procedural sci-fi vector art for towers, enemies and HUD glyphs. Every function draws onto the
## CanvasItem passed in, so the same art serves the battlefield and the UI icons.

const Towers = preload("res://data/towers.gd")
const Difficulty = preload("res://data/difficulty.gd")

const OUTLINE := Color(0.03, 0.04, 0.06, 0.95)
const METAL_D := Color(0.10, 0.115, 0.14)
const METAL := Color(0.18, 0.20, 0.24)
const METAL_L := Color(0.30, 0.33, 0.38)
const GOLD := Color(1.0, 0.78, 0.30)
const CYAN := Color(0.30, 0.88, 1.0)

## Main accent per tower; branches B and C (and the new towers' B and C) use SPEC_ALT.
const ACCENT := {
	"arrow": Color(0.30, 0.90, 1.00),
	"cannon": Color(1.00, 0.55, 0.20),
	"frost": Color(0.55, 0.85, 1.00),
	"sniper": Color(0.45, 1.00, 0.55),
	"tesla": Color(0.75, 0.50, 1.00),
	"laser": Color(1.00, 0.30, 0.35),
	"missile": Color(1.00, 0.85, 0.30),
	"amp": Color(1.00, 0.40, 0.85),
	"flak": Color(0.85, 1.00, 0.45),
	"sensor": Color(0.35, 1.00, 0.85),
	"gravity": Color(0.60, 0.45, 1.00),
	"nullifier": Color(0.78, 0.71, 1.00),
	"nova": Color(1.00, 0.70, 0.28),
	"drones": Color(0.62, 0.91, 0.44),
	"scrap": Color(0.95, 0.72, 0.42),
}
const SPEC_ALT := {
	"mint": Color(1.00, 0.84, 0.30),
	"collector": Color(0.95, 0.52, 0.30),
	"depot": Color(0.45, 0.88, 0.75),
	"flechette": Color(0.55, 1.00, 0.80),
	"buster": Color(0.95, 0.75, 0.45),
	"cryolock": Color(0.60, 0.70, 1.00),
	"nullslug": Color(0.80, 0.50, 1.00),
	"ionstorm": Color(0.45, 0.85, 1.00),
	"sweeper": Color(1.00, 0.75, 0.30),
	"cluster": Color(1.00, 0.55, 0.55),
	"suppression": Color(0.70, 0.70, 1.00),
	"dualpurpose": Color(0.60, 1.00, 0.65),
	"disruptor": Color(1.00, 0.85, 0.30),
	"well": Color(0.40, 0.90, 1.00),
	"dampener": Color(0.55, 0.85, 1.00),
	"feedback": Color(1.00, 0.50, 0.75),
	"pulsereactor": Color(1.00, 0.90, 0.40),
	"solarflare": Color(1.00, 0.45, 0.25),
	"bombers": Color(1.00, 0.60, 0.30),
	"hunters": Color(1.00, 0.35, 0.35),
	"shredder": Color(1.00, 0.35, 0.35),
	"napalm": Color(0.55, 1.00, 0.30),
	"shatter": Color(0.85, 0.60, 1.00),
	"lance": Color(0.30, 0.80, 1.00),
	"overload": Color(1.00, 0.90, 0.30),
	"focus": Color(1.00, 0.55, 0.90),
	"hellfire": Color(1.00, 0.40, 0.20),
	"array": Color(0.30, 1.00, 0.80),
	"burst": Color(1.00, 0.62, 0.35),
	"painter": Color(1.00, 0.35, 0.50),
	"crush": Color(0.92, 0.40, 1.00),
}

## Enemy chassis color and the glow color of its lights.
const ENEMY_BODY := {
	"grunt": Color(0.40, 0.42, 0.48),
	"runner": Color(0.30, 0.30, 0.32),
	"brute": Color(0.40, 0.37, 0.33),
	"swarmling": Color(0.12, 0.30, 0.16),
	"bat": Color(0.30, 0.32, 0.38),
	"shaman": Color(0.72, 0.78, 0.82),
	"phantom": Color(0.16, 0.20, 0.26),
	"aegis": Color(0.30, 0.36, 0.46),
	"hydra": Color(0.36, 0.30, 0.22),
	"jammer": Color(0.26, 0.28, 0.24),
	"juggernaut": Color(0.34, 0.12, 0.14),
	"warlord": Color(0.16, 0.08, 0.20),
	"locust": Color(0.30, 0.36, 0.22),
	"gunship": Color(0.30, 0.33, 0.30),
	"burrower": Color(0.40, 0.33, 0.24),
	"stalker": Color(0.22, 0.20, 0.30),
	"mender": Color(0.30, 0.38, 0.34),
	"rally": Color(0.40, 0.30, 0.22),
	"bulwark": Color(0.26, 0.32, 0.42),
	"rampart": Color(0.36, 0.34, 0.30),
	"leviathan": Color(0.22, 0.26, 0.32),
	"colossus": Color(0.30, 0.22, 0.18),
}
const ENEMY_COLOR := {
	"grunt": Color(1.00, 0.28, 0.22),
	"runner": Color(1.00, 0.80, 0.20),
	"brute": Color(1.00, 0.55, 0.15),
	"swarmling": Color(0.40, 1.00, 0.50),
	"bat": Color(1.00, 0.35, 0.25),
	"shaman": Color(0.30, 1.00, 0.60),
	"phantom": Color(0.55, 0.95, 1.00),
	"aegis": Color(0.40, 0.70, 1.00),
	"hydra": Color(1.00, 0.65, 0.25),
	"jammer": Color(0.90, 1.00, 0.30),
	"juggernaut": Color(1.00, 0.25, 0.20),
	"warlord": Color(1.00, 0.30, 0.80),
	"locust": Color(0.75, 1.00, 0.35),
	"gunship": Color(1.00, 0.45, 0.30),
	"burrower": Color(1.00, 0.70, 0.35),
	"stalker": Color(0.75, 0.55, 1.00),
	"mender": Color(0.35, 1.00, 0.60),
	"rally": Color(1.00, 0.60, 0.25),
	"bulwark": Color(0.45, 0.75, 1.00),
	"rampart": Color(1.00, 0.45, 0.35),
	"leviathan": Color(0.40, 0.85, 1.00),
	"colossus": Color(1.00, 0.50, 0.20),
}


static func accent(type: String, spec := "") -> Color:
	if SPEC_ALT.has(spec):
		return SPEC_ALT[spec]
	return ACCENT.get(type, CYAN)


# --- Geometry helpers ------------------------------------------------------------------------

static func xform(center: Vector2, pts: PackedVector2Array, rot: float, s: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(pts.size())
	for i in pts.size():
		out[i] = center + (pts[i] * s).rotated(rot)
	return out


static func ngon(n: int, r: float, phase := 0.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a := phase + TAU * float(i) / float(n)
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts


static func box(length: float, half_w: float, back := 0.0) -> PackedVector2Array:
	return PackedVector2Array([Vector2(-back, -half_w), Vector2(length, -half_w), Vector2(length, half_w), Vector2(-back, half_w)])


static func fill(ci: CanvasItem, center: Vector2, pts: PackedVector2Array, color: Color, rot := 0.0, s := 1.0) -> void:
	ci.draw_colored_polygon(xform(center, pts, rot, s), color)


static func outline(ci: CanvasItem, center: Vector2, pts: PackedVector2Array, color: Color, width: float, rot := 0.0, s := 1.0) -> void:
	var p := xform(center, pts, rot, s)
	p.append(p[0])
	ci.draw_polyline(p, color, width, true)


## Filled polygon with a dark outline. `line_w` is in pixels, independent of the polygon scale `s`.
static func solid(ci: CanvasItem, center: Vector2, pts: PackedVector2Array, color: Color, rot := 0.0, s := 1.0, line_w := 1.2) -> void:
	fill(ci, center, pts, color, rot, s)
	outline(ci, center, pts, OUTLINE, line_w, rot, s)


static func ellipse(ci: CanvasItem, center: Vector2, rx: float, ry: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 18:
		var a := TAU * float(i) / 18.0
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	ci.draw_colored_polygon(pts, color)


static func glow_dot(ci: CanvasItem, c: Vector2, r: float, color: Color) -> void:
	ci.draw_circle(c, r * 2.2, Color(color, 0.18))
	ci.draw_circle(c, r * 1.4, Color(color, 0.35))
	ci.draw_circle(c, r, color)
	ci.draw_circle(c, r * 0.45, Color(1, 1, 1, 0.9))


static func ring(ci: CanvasItem, center: Vector2, r: float, color: Color, width := 1.5) -> void:
	ci.draw_arc(center, r, 0.0, TAU, 32, color, width, true)


static func arc_segments(ci: CanvasItem, c: Vector2, r: float, count: int, gap: float, rot: float, color: Color, width: float) -> void:
	var span := TAU / float(count)
	for i in count:
		var a0 := rot + span * float(i) + gap * 0.5
		ci.draw_arc(c, r, a0, a0 + span - gap, 8, color, width, true)


# --- Towers ----------------------------------------------------------------------------------

static func tower(ci: CanvasItem, type: String, tier: int, c: Vector2, aim: float, s := 1.0, t := 0.0, flash := 0.0, spec := "") -> void:
	var acc := accent(type, spec)
	if tier >= 4:
		mastery_ring(ci, c, s, acc, t)
	_pad(ci, c, s, acc, tier, t)
	match type:
		"arrow":
			_pulse(ci, c, aim, s, tier, t, flash, spec, acc)
		"cannon":
			_mortar(ci, c, aim, s, tier, flash, spec, acc)
		"frost":
			_cryo(ci, c, s, tier, t, flash, spec, acc)
		"sniper":
			_rail(ci, c, aim, s, tier, flash, spec, acc)
		"tesla":
			_arc(ci, c, s, tier, t, flash, spec, acc)
		"laser":
			_laser(ci, c, aim, s, tier, t, flash, spec, acc)
		"missile":
			_missile(ci, c, aim, s, tier, flash, spec, acc)
		"flak":
			_flak(ci, c, aim, s, tier, t, flash, spec, acc)
		"sensor":
			_sensor(ci, c, s, tier, t, spec, acc)
		"gravity":
			_gravity(ci, c, s, tier, t, flash, spec, acc)
		"amp":
			_amp(ci, c, s, tier, t, spec, acc)
		"nullifier":
			_nullifier(ci, c, s, tier, t, flash, spec, acc)
		"nova":
			_nova(ci, c, s, tier, t, flash, spec, acc)
		"drones":
			_drone_bay(ci, c, s, tier, t, spec, acc)
		"scrap":
			_scrapyard(ci, c, s, tier, t, spec, acc)


## --- Shading helpers: light comes from the upper left. ------------------------------------

const LIGHT := Vector2(-0.6, -0.8)


## A shaded ball or dome: outline, base, a lit face offset toward the light, a rim highlight
## and a small specular glint.
static func orb(ci: CanvasItem, p: Vector2, r: float, col: Color, s := 1.0) -> void:
	ci.draw_circle(p, r + 1.1 * s, OUTLINE)
	ci.draw_circle(p, r, col.darkened(0.3))
	ci.draw_circle(p + LIGHT * r * 0.12, r * 0.8, col)
	ci.draw_arc(p, r * 0.72, PI * 1.05, PI * 1.6, 10, col.lightened(0.35), maxf(0.8, r * 0.16), true)
	ci.draw_circle(p + LIGHT * r * 0.45, maxf(0.6, r * 0.13), Color(1, 1, 1, 0.55))


## A bevelled plate: outlined polygon, a lighter inset face, lit edges toward the light and
## shadowed edges away from it.
static func plate(ci: CanvasItem, c: Vector2, pts: PackedVector2Array, col: Color, rot := 0.0, s := 1.0, line_w := 1.2) -> void:
	var p := xform(c, pts, rot, s)
	var closed := p.duplicate()
	closed.append(p[0])
	ci.draw_colored_polygon(p, col.darkened(0.22))
	var centre := Vector2.ZERO
	for q in p:
		centre += q
	centre /= float(p.size())
	var inset := PackedVector2Array()
	for q in p:
		inset.append(centre + (q - centre) * 0.8)
	ci.draw_colored_polygon(inset, col)
	for i in p.size():
		var a := p[i]
		var b := p[(i + 1) % p.size()]
		var m := (a + b) * 0.5 - centre
		var lit := m.normalized().dot(LIGHT) > 0.15
		var dark := m.normalized().dot(LIGHT) < -0.15
		if lit:
			ci.draw_line(a.lerp(centre, 0.1), b.lerp(centre, 0.1), col.lightened(0.45), maxf(0.8, line_w * 0.8), true)
		elif dark:
			ci.draw_line(a.lerp(centre, 0.1), b.lerp(centre, 0.1), col.darkened(0.5), maxf(0.8, line_w * 0.8), true)
	ci.draw_polyline(closed, OUTLINE, line_w, true)


## Small rivets at a polygon's (scaled-in) corners; `r` is the rivet radius in pixels.
static func rivets(ci: CanvasItem, c: Vector2, pts: PackedVector2Array, rot: float, s: float, inset := 0.72, r := 0.9) -> void:
	for q in xform(c, pts, rot, s):
		var p: Vector2 = c + (q - c) * inset
		ci.draw_circle(p, r + 0.3, OUTLINE)
		ci.draw_circle(p, r, METAL_L.lightened(0.15))


## A thick shaded bar from a to b (barrels, rails, struts).
static func bar(ci: CanvasItem, a: Vector2, b: Vector2, w: float, col: Color) -> void:
	var d := (b - a).normalized()
	var n := d.orthogonal()
	if n.dot(LIGHT) < 0.0:
		n = -n
	ci.draw_line(a, b, OUTLINE, w + 1.6, true)
	ci.draw_line(a, b, col.darkened(0.25), w, true)
	ci.draw_line(a + n * w * 0.18, b + n * w * 0.18, col, w * 0.55, true)
	ci.draw_line(a + n * w * 0.3, b + n * w * 0.3, col.lightened(0.4), maxf(0.6, w * 0.16), true)


## A glowing strip light.
static func strip(ci: CanvasItem, a: Vector2, b: Vector2, w: float, col: Color) -> void:
	ci.draw_line(a, b, Color(col, 0.25), w * 2.6, true)
	ci.draw_line(a, b, col, w, true)
	ci.draw_line(a, b, Color(1, 1, 1, 0.6), maxf(0.5, w * 0.35), true)


static func rect_pts(hw: float, hh: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(-hw, -hh), Vector2(hw, -hh), Vector2(hw, hh), Vector2(-hw, hh)])



## The hex deck every tower stands on: bevelled armour, corner bolts, vents, status LEDs,
## an accent trim that breathes, and tier pips (gold from the specialization on).
static func _pad(ci: CanvasItem, c: Vector2, s: float, acc: Color, tier: int, t: float) -> void:
	ellipse(ci, c + Vector2(0, 6) * s, 21.0 * s, 9.0 * s, Color(0, 0, 0, 0.35))
	var hex := ngon(6, 1.0)
	fill(ci, c, hex, OUTLINE, 0.0, 20.5 * s)
	plate(ci, c, hex, METAL_D.lightened(0.05), 0.0, 19.2 * s, 1.0)
	fill(ci, c, hex, METAL, 0.0, 15.6 * s)
	outline(ci, c, hex, Color(0, 0, 0, 0.45), 1.0, 0.0, 15.6 * s)
	var pulse := 0.5 + 0.2 * sin(t * 2.2)
	outline(ci, c, hex, Color(acc, pulse), (1.0 + 0.35 * float(tier)) * s, 0.0, 17.6 * s)
	for q in xform(c, hex, 0.0, 17.6 * s):
		ci.draw_circle(q, 1.5 * s, OUTLINE)
		ci.draw_circle(q, 1.0 * s, METAL_L)
	for k in 3:
		var y := c.y - 13.0 * s + float(k) * 2.2 * s
		ci.draw_line(Vector2(c.x - 13.5 * s, y), Vector2(c.x - 10.0 * s, y), Color(0, 0, 0, 0.5), 1.0)
		ci.draw_line(Vector2(c.x + 10.0 * s, y), Vector2(c.x + 13.5 * s, y), Color(0, 0, 0, 0.5), 1.0)
	var blink := fmod(t * 0.9, 2.0) < 0.12
	ci.draw_circle(c + Vector2(-9.0, 11.0) * s, 1.0 * s, Color(0.4, 1.0, 0.5, 0.95 if blink else 0.45))
	ci.draw_circle(c + Vector2(9.0, 11.0) * s, 1.0 * s, Color(acc, 0.8))
	for i in tier:
		var x := (float(i) - float(tier - 1) / 2.0) * 6.5
		var pip := Rect2(c + Vector2(x - 2.4, 15.0) * s, Vector2(4.8, 2.0) * s)
		ci.draw_rect(pip.grow(0.6), OUTLINE)
		ci.draw_rect(pip, GOLD if tier >= 3 else acc)


## Pulse Turret: an armoured dome turret firing energy bolts from coil-wrapped emitters (two from
## tier 2). Gatling Pulse spins a shrouded barrel cluster; Shredder launches spinning saw discs.
static func _pulse(ci: CanvasItem, c: Vector2, aim: float, s: float, tier: int, t: float, flash: float, spec: String, acc: Color) -> void:
	var d := Vector2.from_angle(aim)
	var n := d.orthogonal()
	var recoil := clampf(flash / 0.12, 0.0, 1.0) * 2.5 * s
	var m4 := tier >= 4
	# Power cell at the back, three charge bars.
	plate(ci, c - d * 8.0 * s, rect_pts(3.4, 5.0), METAL_D.lightened(0.1), aim, s, 1.0)
	for k in 3:
		var bp := c - d * (9.5 - float(k) * 1.6) * s
		ci.draw_line(bp - n * 3.2 * s, bp + n * 3.2 * s, Color(acc, 0.55 + 0.4 * float(k == 2)), 1.0 * s)
	if spec == "gatling":
		var hub := c + d * 6.0 * s - d * recoil
		plate(ci, hub + d * 2.0 * s, rect_pts(3.5, 5.4), METAL_D.lightened(0.08), aim, s, 1.0)
		var count := 6 if m4 else 4
		var spin := t * (32.0 if flash > 0.0 else 3.0)
		for k in count:
			var ph := spin + TAU * float(k) / float(count)
			var off: Vector2 = n * sin(ph) * 3.7 * s
			var shade := 0.5 - 0.5 * cos(ph)
			var p0: Vector2 = hub + d * 5.0 * s + off
			bar(ci, p0, p0 + d * 10.0 * s, 1.8 * s, METAL_L.lerp(METAL_D, shade))
		var ring_p := hub + d * 12.0 * s
		bar(ci, ring_p - n * 5.2 * s, ring_p + n * 5.2 * s, 1.8 * s, GOLD if m4 else METAL_L)
		ring_p = hub + d * 7.0 * s
		bar(ci, ring_p - n * 5.2 * s, ring_p + n * 5.2 * s, 1.4 * s, METAL_L)
		glow_dot(ci, hub + d * 16.0 * s, (0.8 + flash * 9.0) * s, acc)
		if m4:
			var drum := c + n * 8.5 * s - d * 2.0 * s
			orb(ci, drum, 4.6 * s, METAL, s)
			ring(ci, drum, 3.0 * s, Color(GOLD, 0.8), 1.0 * s)
			ci.draw_line(drum - n * 3.0 * s, hub - n * 1.0 * s, Color(GOLD, 0.6), 1.2 * s, true)
	elif spec == "shredder":
		var b0 := c - d * recoil
		plate(ci, b0 + d * 7.5 * s, rect_pts(7.5, 3.2), METAL_L, aim, s, 1.0)
		var discs := [0.0] if not m4 else [-4.2, 4.2]
		for off in discs:
			var saw: Vector2 = b0 + d * 16.0 * s + n * float(off) * s
			var teeth := PackedVector2Array()
			var spin := t * 16.0
			for i in 16:
				teeth.append(Vector2.from_angle(spin + TAU * float(i) / 16.0) * (5.8 if i % 2 == 0 else 4.2))
			solid(ci, saw, teeth, acc, 0.0, s, 1.0)
			ci.draw_arc(saw, 3.4 * s, spin, spin + 2.0, 8, Color(1, 1, 1, 0.35), 1.0 * s, true)
			orb(ci, saw, 1.9 * s, METAL_L, s)
	else:
		var count := 1 if tier <= 1 else 2
		for k in count:
			var off := 0.0 if count == 1 else (float(k) * 2.0 - 1.0) * 3.8
			var b0: Vector2 = c + n * off * s - d * recoil
			var length := 15.0 + float(tier)
			bar(ci, b0, b0 + d * length * s, 3.6 * s, METAL_L)
			for r in 2:
				var p: Vector2 = b0 + d * (8.0 + float(r) * 4.0) * s
				bar(ci, p - n * 3.2 * s, p + n * 3.2 * s, 1.6 * s, METAL_D.lightened(0.15))
				ci.draw_line(p - n * 2.6 * s, p + n * 2.6 * s, Color(acc, 0.95), 0.8 * s, true)
			ci.draw_circle(b0 + d * length * s, 1.9 * s, OUTLINE)
			glow_dot(ci, b0 + d * (length + 0.5) * s, (1.2 + flash * 7.0) * s, acc)
	var head := ngon(8, 1.0, PI / 8.0)
	plate(ci, c, head, METAL_L, aim, 8.2 * s, 1.2)
	orb(ci, c, 4.6 * s, METAL, s)
	rivets(ci, c, ngon(4, 1.0, PI / 4.0), aim, 8.2 * s, 0.8, 0.8 * s)
	glow_dot(ci, c + d * 1.4 * s, 1.5 * s, acc)
	if m4:
		ring(ci, c, 6.8 * s, Color(GOLD, 0.85), 1.1 * s)


## Plasma Mortar: a stout armoured tube aimed at the sky (seen from above: its glowing bore) on a
## bolted turntable, fed by plasma canisters. Siege Mortar braces on four hydraulic legs; Plasma
## Burn carries green incendiary tanks.
static func _mortar(ci: CanvasItem, c: Vector2, aim: float, s: float, tier: int, flash: float, spec: String, acc: Color) -> void:
	var d := Vector2.from_angle(aim)
	var n := d.orthogonal()
	var kick := clampf(flash / 0.12, 0.0, 1.0)
	var siege := spec == "siege"
	var burn := spec == "napalm"
	var m4 := tier >= 4
	var plasma := Color(0.55, 1.0, 0.3) if burn else acc
	if siege:
		for k in 4:
			var ld := Vector2.from_angle(aim + PI / 4.0 + float(k) * PI / 2.0)
			bar(ci, c + ld * 8.0 * s, c + ld * 18.0 * s, 3.2 * s, METAL_D.lightened(0.1))
			bar(ci, c + ld * 9.0 * s, c + ld * 14.0 * s, 1.4 * s, METAL_L)
			plate(ci, c + ld * 18.5 * s, rect_pts(2.2, 2.2), METAL_L, aim + PI / 4.0 + float(k) * PI / 2.0, s, 1.0)
	var table := ngon(10, 1.0)
	plate(ci, c, table, METAL_D.lightened(0.08), aim, 12.6 * s, 1.2)
	rivets(ci, c, ngon(8, 1.0), aim, 12.6 * s, 0.86, 0.7 * s)
	var tanks := 1 if tier <= 1 else 2
	if burn:
		tanks = 3 if m4 else 2
	for k in tanks:
		var side := 0.0 if tanks == 1 else (float(k) / float(tanks - 1) * 2.0 - 1.0)
		var tp: Vector2 = c - d * 7.5 * s + n * side * 8.0 * s
		orb(ci, tp, 3.4 * s, plasma.darkened(0.15), s)
		ci.draw_line(tp - n * 3.0 * s, tp + n * 3.0 * s, Color(0.08, 0.08, 0.08, 0.8), 0.9 * s)
	var tube_r := (6.2 + 0.6 * float(tier) + (1.8 if siege else 0.0)) * s
	var mouth := c + d * (4.0 - 3.0 * kick) * s
	ci.draw_line(c, mouth, OUTLINE, tube_r * 2.0 + 2.0 * s, true)
	ci.draw_line(c, mouth, METAL, tube_r * 2.0, true)
	orb(ci, mouth, tube_r, METAL_L, s)
	for k in mini(tier, 3):
		ring(ci, mouth, tube_r * (0.92 - 0.1 * float(k)), Color(GOLD, 0.85) if m4 and k == 0 else Color(0, 0, 0, 0.35), 1.1 * s)
	ci.draw_circle(mouth, tube_r * 0.62, OUTLINE)
	ci.draw_circle(mouth, tube_r * 0.56, Color(0.03, 0.03, 0.04))
	ci.draw_circle(mouth, tube_r * 0.5, Color(plasma, 0.3 + 0.5 * kick))
	ci.draw_arc(mouth, tube_r * 0.38, 0.0, TAU, 14, Color(plasma, 0.6), 1.0 * s, true)
	glow_dot(ci, mouth, tube_r * 0.24, plasma)
	if m4 and siege:
		arc_segments(ci, mouth, tube_r + 4.0 * s, 6, 0.5, aim, Color(GOLD, 0.75), 1.4 * s)


## Cryo Emitter: a slowly turning snowflake crystal over a frosted coolant core, venting cold
## mist from armoured vents. Stasis Field adds a projector halo; Shatter Field grows ice shards.
static func _cryo(ci: CanvasItem, c: Vector2, s: float, tier: int, t: float, flash: float, spec: String, acc: Color) -> void:
	var m4 := tier >= 4
	var glow := clampf(0.14 + 0.08 * sin(t * 3.0) + flash, 0.0, 0.6)
	ci.draw_circle(c, 15.0 * s, Color(acc, glow))
	var vents := 3 if tier <= 1 else 6
	for k in vents:
		var a := TAU * float(k) / float(vents) + PI / 6.0
		var vd := Vector2.from_angle(a)
		plate(ci, c + vd * 11.8 * s, rect_pts(2.6, 2.4), METAL_L, a, s, 1.0)
		ci.draw_line(c + vd * 13.6 * s + vd.orthogonal() * 1.6 * s, c + vd * 13.6 * s - vd.orthogonal() * 1.6 * s, Color(acc, 0.9), 0.9 * s)
		var puff := fmod(t * 0.5 + float(k) * 0.37, 1.0)
		ci.draw_circle(c + vd * (15.0 + 5.0 * puff) * s, (1.4 + 2.2 * puff) * s, Color(0.9, 0.97, 1.0, 0.35 * (1.0 - puff)))
	if spec == "stasis":
		ring(ci, c, 16.8 * s, Color(acc, 0.7), 1.6 * s)
		arc_segments(ci, c, 16.8 * s, 4, 0.9, -t * 0.9, Color(1, 1, 1, 0.55), 2.0 * s)
		for k in 4:
			ci.draw_circle(c + Vector2.from_angle(-t * 0.9 + float(k) * PI / 2.0) * 16.8 * s, 1.3 * s, Color(1, 1, 1, 0.9))
	if spec == "shatter":
		for i in 6:
			var a := TAU * float(i) / 6.0 + t * 0.4
			var tip := c + Vector2.from_angle(a) * 17.5 * s
			var b1 := c + Vector2.from_angle(a + 0.2) * 11.0 * s
			var b2 := c + Vector2.from_angle(a - 0.2) * 11.0 * s
			ci.draw_colored_polygon(PackedVector2Array([tip, b1, b2]), Color(acc, 0.85))
			ci.draw_line(tip, b1.lerp(b2, 0.5), Color(1, 1, 1, 0.6), 0.8 * s, true)
	orb(ci, c, 9.0 * s, METAL, s)
	ci.draw_circle(c, 7.4 * s, Color(acc, 0.28))
	var rot := t * 0.5
	var arm := (7.4 + 0.5 * float(tier)) * s
	var ice := Color(0.93, 0.98, 1.0)
	for k in 6:
		var dv := Vector2.from_angle(rot + TAU * float(k) / 6.0)
		var tip := c + dv * arm
		ci.draw_line(c, tip, OUTLINE, 3.2 * s, true)
		ci.draw_line(c, tip, ice, 1.8 * s, true)
		ci.draw_line(c, tip, Color(acc, 0.7), 0.6 * s, true)
		for f in [0.45, 0.72]:
			var mid: Vector2 = c + dv * arm * float(f)
			var bl := arm * (0.36 if f < 0.6 else 0.24)
			for sgn in [-1.0, 1.0]:
				ci.draw_line(mid, mid + dv.rotated(0.85 * sgn) * bl, ice, 1.2 * s, true)
		ci.draw_circle(tip, (1.3 if m4 else 0.9) * s, GOLD if m4 else ice)
	glow_dot(ci, c, 2.0 * s, acc)


## Railgun: twin conductor rails wrapped in magnetic coil bands, fed by a capacitor bank with
## charge lights. Deadeye adds a long-range scope; Piercing Rail widens the channel and burns hotter.
static func _rail(ci: CanvasItem, c: Vector2, aim: float, s: float, tier: int, flash: float, spec: String, acc: Color) -> void:
	var d := Vector2.from_angle(aim)
	var n := d.orthogonal()
	var recoil := clampf(flash / 0.12, 0.0, 1.0) * 3.0 * s
	var m4 := tier >= 4
	var lance := spec == "lance"
	var length := (21.0 + 3.0 * float(tier) + (4.0 if lance else 0.0) + (5.0 if spec == "deadeye" else 0.0)) * s
	var gap := (3.0 + (1.2 if lance else 0.0)) * s
	for side in [-1.0, 1.0]:
		var cap: Vector2 = c - d * 8.0 * s + n * side * 6.6 * s
		plate(ci, cap, rect_pts(4.2, 2.6), METAL_D.lightened(0.12), aim, s, 1.0)
		for k in 3:
			ci.draw_circle(cap - d * (2.4 - float(k) * 2.4) * s, 0.8 * s, Color(acc, 0.35 + 0.6 * float(k == int(fmod(Time.get_ticks_msec() / 250.0, 3.0)))))
	var b0 := c - d * (7.0 * s + recoil)
	for side in [-1.0, 1.0]:
		var off: Vector2 = n * side * gap
		bar(ci, b0 + off, b0 + off + d * length, 2.4 * s, METAL_L)
	strip(ci, b0 + d * 5.0 * s, b0 + d * length, (1.4 if lance else 0.9) * s, Color(acc, minf(1.0, (0.55 if lance else 0.35) + 3.0 * flash)))
	var coils := mini(2 + tier, 6)
	for k in coils:
		var p := b0 + d * length * (0.3 + 0.62 * float(k) / float(coils))
		bar(ci, p - n * (gap + 2.8 * s), p + n * (gap + 2.8 * s), 2.0 * s, GOLD if m4 else acc.darkened(0.25))
	plate(ci, c, rect_pts(6.0, 5.4), METAL_L, aim, s, 1.2)
	rivets(ci, c, rect_pts(6.0, 5.4), aim, s, 0.72, 0.8 * s)
	if spec == "deadeye":
		var scope := c + n * 7.2 * s + d * 3.0 * s
		bar(ci, scope - d * 5.0 * s, scope + d * 6.0 * s, 2.4 * s, METAL_L)
		ci.draw_circle(scope + d * 6.4 * s, 1.5 * s, OUTLINE)
		glow_dot(ci, scope + d * 6.4 * s, 1.1 * s, Color(1.0, 0.3, 0.3))
	glow_dot(ci, c, 1.6 * s, acc)
	if flash > 0.02:
		glow_dot(ci, b0 + d * (length + 2.0 * s), 3.5 * s * clampf(flash / 0.12, 0.0, 1.0), acc)


## Arc Coil: a Tesla coil from above: polished toroid rings around a charged spire, charge nodes
## studding the rim and sparks leaping inward. Storm Coil adds three satellite coils; Overload
## thickens the toroid and adds nodes.
static func _arc(ci: CanvasItem, c: Vector2, s: float, tier: int, t: float, flash: float, spec: String, acc: Color) -> void:
	var m4 := tier >= 4
	var overload := spec == "overload"
	if spec == "storm":
		for k in 3:
			var sp := c + Vector2.from_angle(TAU * float(k) / 3.0 - PI / 2.0 + t * 0.2) * 15.5 * s
			ci.draw_line(c, sp, Color(0, 0, 0, 0.4), 2.0 * s)
			orb(ci, sp, 3.2 * s, METAL_L, s)
			glow_dot(ci, sp, 1.2 * s, acc)
			if fmod(t * 3.0 + float(k), 1.0) < 0.3:
				ci.draw_polyline(PackedVector2Array([sp, sp.lerp(c, 0.5) + Vector2(2, -2) * s, c + (sp - c).normalized() * 9.0 * s]), Color(acc, 0.8), 1.0 * s, true)
	plate(ci, c, ngon(8, 1.0, PI / 8.0), METAL_D.lightened(0.05), 0.0, 12.8 * s, 1.2)
	var rings := 1 if tier <= 1 else 2
	var tw := (3.8 if overload else 3.0) * s
	for k in rings:
		var r := (9.4 - float(k) * 3.4) * s
		ci.draw_arc(c, r, 0.0, TAU, 32, OUTLINE, tw + 1.6 * s, true)
		ci.draw_arc(c, r, 0.0, TAU, 32, METAL.lightened(0.05), tw, true)
		ci.draw_arc(c, r - tw * 0.15, PI * 0.95, PI * 1.75, 12, METAL_L.lightened(0.3), tw * 0.35, true)
		ci.draw_arc(c, r + tw * 0.15, PI * -0.05, PI * 0.7, 12, Color(0, 0, 0, 0.35), tw * 0.3, true)
	var nodes := 6 if overload else 4
	for k in nodes:
		var np := c + Vector2.from_angle(TAU * float(k) / float(nodes) + PI / 4.0) * 9.4 * s
		orb(ci, np, (1.5 if overload else 1.1) * s, GOLD if m4 else acc, s)
	var orb_p := c + Vector2(0, -1) * s
	var pulse := 0.5 + 0.5 * sin(t * 5.0)
	ci.draw_circle(orb_p, (4.5 + 2.0 * pulse + 5.0 * flash) * s, Color(acc, 0.22))
	orb(ci, orb_p, 2.8 * s, acc.lightened(0.2), s)
	glow_dot(ci, orb_p, (1.6 + 0.3 * float(tier)) * s, acc)
	for i in tier + 1:
		var a := t * 6.0 + float(i) * 2.4
		var p1 := orb_p + Vector2.from_angle(a) * 3.0 * s
		var p2 := c + Vector2.from_angle(a + 0.4) * 9.4 * s
		var mid := (p1 + p2) / 2.0 + Vector2.from_angle(a + 2.0) * 2.0 * s
		ci.draw_polyline(PackedVector2Array([p1, mid, p2]), Color(acc, 0.85), 1.1 * s, true)
		ci.draw_polyline(PackedVector2Array([p1, mid, p2]), Color(1, 1, 1, 0.5), 0.4 * s, true)


## Laser Lance: a sleek armoured hull with heat-sink fins, a long lance barrel with focusing
## rings, and an emitter crystal at the tip. Prism Array ends in a splitting prism; Focus Lens in
## one big lens.
static func _laser(ci: CanvasItem, c: Vector2, aim: float, s: float, tier: int, t: float, flash: float, spec: String, acc: Color) -> void:
	var d := Vector2.from_angle(aim)
	var n := d.orthogonal()
	var m4 := tier >= 4
	var lit := clampf(flash / 0.05, 0.0, 1.0)
	if tier >= 2:
		for side in [-1.0, 1.0]:
			for k in 3:
				var fp: Vector2 = c - d * (3.0 + 2.5 * float(k)) * s
				bar(ci, fp + n * side * 5.0 * s, fp + n * side * 9.0 * s, 1.3 * s, METAL_L)
	var hull := PackedVector2Array([Vector2(7, 0), Vector2(1, 6), Vector2(-9, 5), Vector2(-11, 0), Vector2(-9, -5), Vector2(1, -6)])
	plate(ci, c, hull, METAL_L, aim, s, 1.2)
	ci.draw_line(c - d * 8.0 * s, c + d * 3.0 * s, Color(0, 0, 0, 0.35), 1.0 * s)
	var length := (19.0 + 2.0 * float(tier)) * s
	bar(ci, c + d * 4.0 * s, c + d * length, 3.0 * s, METAL)
	strip(ci, c + d * 5.0 * s, c + d * length, 0.6 * s, Color(acc, 0.35 + 0.6 * lit))
	var rings := 2 if tier <= 1 else 3
	for k in rings:
		var p := c + d * (8.0 + float(k) * 4.0) * s
		bar(ci, p - n * 3.2 * s, p + n * 3.2 * s, 1.5 * s, GOLD if m4 else acc.darkened(0.2))
	var tip := c + d * length
	match spec:
		"prism":
			var tri := PackedVector2Array([Vector2(5, 0), Vector2(-3, 4.5), Vector2(-3, -4.5)])
			solid(ci, tip, tri, Color(acc, 0.6), aim, s, 1.0)
			ci.draw_line(tip + d * 4.0 * s, tip - d * 2.0 * s + n * 3.0 * s, Color(1, 1, 1, 0.6), 0.8 * s, true)
			var beams := 5 if m4 else 3
			for k in beams:
				var ang := (float(k) - float(beams - 1) / 2.0) * 0.35
				glow_dot(ci, tip + d.rotated(ang) * 5.5 * s, (1.1 + lit) * s, acc)
		"focus":
			orb(ci, tip, 4.8 * s, acc.darkened(0.2), s)
			glow_dot(ci, tip, (2.6 + lit) * s, acc)
			ring(ci, tip, 6.6 * s, Color(GOLD if m4 else acc, 0.6 + 0.3 * sin(t * 8.0)), 1.2 * s)
		_:
			var dia := PackedVector2Array([Vector2(3.8, 0), Vector2(0, 2.8), Vector2(-3.8, 0), Vector2(0, -2.8)])
			solid(ci, tip, dia, Color(acc, 0.85), aim, s, 1.0)
			ci.draw_line(tip - d * 2.0 * s + n * 1.0 * s, tip + d * 2.0 * s, Color(1, 1, 1, 0.7), 0.8 * s, true)
			glow_dot(ci, tip, (0.8 + 1.5 * lit) * s, Color(1, 1, 1))
	orb(ci, c - d * 4.0 * s, 2.2 * s, acc.darkened(0.3), s)


## Missile Battery: an armoured launcher with hazard striping, a hatch and panel lines, its tubes
## showing the warheads waiting to fire. Swarm Pods packs a grid of small missiles; Hellfire
## carries two heavy finned warheads.
static func _missile(ci: CanvasItem, c: Vector2, aim: float, s: float, tier: int, flash: float, spec: String, acc: Color) -> void:
	var d := Vector2.from_angle(aim)
	var n := d.orthogonal()
	var m4 := tier >= 4
	plate(ci, c, rect_pts(9.5, 9.5), METAL_L, aim, s, 1.3)
	fill(ci, c, rect_pts(7.8, 7.8), METAL, aim, s)
	rivets(ci, c, rect_pts(9.5, 9.5), aim, s, 0.9, 0.8 * s)
	for side in [-1.0, 1.0]:
		for k in 4:
			var hp: Vector2 = c - d * (7.2 - 2.0 * float(k)) * s + n * side * 8.7 * s
			ci.draw_line(hp - d * 0.8 * s, hp + d * 0.8 * s, Color(acc, 0.95) if k % 2 == 0 else Color(0.06, 0.06, 0.06), 1.8 * s)
	var tubes: Array = []
	var tube_r := 2.4
	match spec:
		"swarm":
			var rows := 3 if m4 else 2
			for row in rows:
				for col in 3:
					tubes.append(Vector2(-4.0 + 4.2 * float(row), -5.0 + 5.0 * float(col)))
			tube_r = 1.8
		"hellfire":
			tubes = [Vector2(0, -4.2), Vector2(0, 4.2)]
			tube_r = 3.6 if m4 else 3.3
		_:
			var count := 2 if tier <= 1 else 3
			for i in count:
				tubes.append(Vector2(0, (float(i) - float(count - 1) / 2.0) * 5.2))
	var ready := 1.0 - clampf(flash / 0.15, 0.0, 1.0)
	for tp in tubes:
		var p: Vector2 = c + d * tp.x * s + n * tp.y * s
		ci.draw_circle(p, (tube_r + 0.9) * s, OUTLINE)
		ci.draw_circle(p, (tube_r + 0.3) * s, METAL_L)
		ci.draw_circle(p, tube_r * s, Color(0.04, 0.04, 0.05))
		if ready > 0.05:
			orb(ci, p, tube_r * 0.72 * s, Color(0.86, 0.88, 0.92, ready), s * 0.6)
			ci.draw_circle(p, tube_r * 0.32 * s, Color(1.0, 0.32, 0.25, ready))
		if spec == "hellfire":
			for f in 4:
				var fd := Vector2.from_angle(float(f) * PI / 2.0 + PI / 4.0)
				ci.draw_line(p + fd * tube_r * 0.8 * s, p + fd * (tube_r + 1.8) * s, GOLD if m4 else METAL_L, 1.2 * s)
	var hatch := c - d * 6.6 * s
	ci.draw_rect(Rect2(hatch - Vector2(1.6, 1.6) * s, Vector2(3.2, 3.2) * s), OUTLINE)
	glow_dot(ci, hatch, 1.1 * s, acc)


## Amplifier Pylon: a tripod mast on hydraulic legs broadcasting power in expanding rings.
## Overclock spins a geared rotor; Targeting Array mounts a tracking dish with crosshairs.
static func _amp(ci: CanvasItem, c: Vector2, s: float, tier: int, t: float, spec: String, acc: Color) -> void:
	var m4 := tier >= 4
	for k in 2:
		var ph := fmod(t * 0.6 + float(k) * 0.5, 1.0)
		ci.draw_arc(c, (8.0 + 12.0 * ph) * s, 0.0, TAU, 32, Color(acc, 0.5 * (1.0 - ph)), 1.4 * s, true)
	for k in 3:
		var ld := Vector2.from_angle(TAU * float(k) / 3.0 - PI / 2.0)
		bar(ci, c + ld * 5.0 * s, c + ld * 14.5 * s, 3.0 * s, METAL_D.lightened(0.12))
		bar(ci, c + ld * 6.0 * s, c + ld * 11.0 * s, 1.3 * s, METAL_L)
		orb(ci, c + ld * 14.5 * s, 2.3 * s, METAL_L, s)
		if tier >= 2:
			glow_dot(ci, c + ld * 12.0 * s, 1.0 * s, acc)
	if spec == "overclock":
		var teeth := PackedVector2Array()
		for i in 20:
			teeth.append(Vector2.from_angle(t * 2.5 + TAU * float(i) / 20.0) * (11.0 if i % 2 == 0 else 9.4))
		solid(ci, c, teeth, GOLD if m4 else METAL_L, 0.0, s, 1.0)
		ci.draw_arc(c, 10.0 * s, PI * 1.0, PI * 1.6, 10, Color(1, 1, 1, 0.3), 1.0 * s, true)
	orb(ci, c, 7.6 * s, METAL, s)
	ring(ci, c, 5.2 * s, METAL_L, 1.4 * s)
	ring(ci, c, 3.8 * s, Color(0, 0, 0, 0.4), 0.8 * s)
	if spec == "array":
		var dd := Vector2.from_angle(t * 0.7)
		ci.draw_arc(c + dd * 2.0 * s, 7.0 * s, dd.angle() - 1.1, dd.angle() + 1.1, 10, OUTLINE, 3.6 * s, true)
		ci.draw_arc(c + dd * 2.0 * s, 7.0 * s, dd.angle() - 1.1, dd.angle() + 1.1, 10, GOLD if m4 else METAL_L, 2.2 * s, true)
		for k in 4:
			var cd := Vector2.from_angle(float(k) * PI / 2.0)
			ci.draw_line(c + cd * 2.5 * s, c + cd * 5.5 * s, Color(acc, 0.9), 1.0 * s)
	var pulse := 0.5 + 0.5 * sin(t * 4.0)
	ci.draw_circle(c, (3.2 + 1.2 * pulse + 0.4 * float(tier)) * s, Color(acc, 0.35))
	glow_dot(ci, c, (2.0 + 0.3 * float(tier)) * s, acc)


## Flak Battery: an anti-air mount with shrouded autocannons, an ammo box feeding them and a
## tracking radar. Sky Shredder adds barrels; Proximity Burst mounts one heavy gun.
static func _flak(ci: CanvasItem, c: Vector2, aim: float, s: float, tier: int, t: float, flash: float, spec: String, acc: Color) -> void:
	var d := Vector2.from_angle(aim)
	var n := d.orthogonal()
	var recoil := clampf(flash / 0.1, 0.0, 1.0) * 2.5 * s
	var barrels: Array = [-2.6, 2.6]
	var bw := 1.8
	var bl := 15.0 + float(tier)
	if spec == "skyshred":
		barrels = [-4.2, -1.4, 1.4, 4.2] if tier >= 4 else [-3.6, -1.2, 1.2, 3.6]
		bw = 1.4
	elif spec == "burst":
		barrels = [0.0] if tier < 4 else [-2.8, 2.8]
		bw = 3.4 if tier < 4 else 2.8
		bl += 2.0
	var base := c - d * recoil
	for off in barrels:
		var o: Vector2 = n * float(off) * s
		bar(ci, base + o, base + o + d * bl * s, bw * s, METAL_L)
		ci.draw_circle(base + o + d * bl * s, bw * 0.6 * s, Color(0.05, 0.05, 0.05))
		ci.draw_circle(base + o + d * bl * s, bw * 0.45 * s, Color(acc, 0.3 + 3.0 * flash))
	bar(ci, base + d * 6.0 * s - n * 5.0 * s, base + d * 6.0 * s + n * 5.0 * s, 1.6 * s, METAL_D.lightened(0.15))
	var body := PackedVector2Array([Vector2(8, -6), Vector2(8, 6), Vector2(-7, 8), Vector2(-9, 0), Vector2(-7, -8)])
	plate(ci, c, body, METAL_L, aim, s, 1.2)
	rivets(ci, c, body, aim, s, 0.7, 0.7 * s)
	var ammo := c - d * 3.0 * s - n * 6.5 * s
	plate(ci, ammo, rect_pts(2.5, 2.0), Color(0.4, 0.42, 0.25), aim, s, 1.0)
	var dish := c - d * 6.0 * s + n * 5.0 * s
	ci.draw_arc(dish, 3.2 * s, t * 3.0, t * 3.0 + PI, 8, OUTLINE, 2.6 * s, true)
	ci.draw_arc(dish, 3.2 * s, t * 3.0, t * 3.0 + PI, 8, Color(acc, 0.9), 1.4 * s, true)
	glow_dot(ci, c + d * 2.0 * s, 1.5 * s, acc)


## Sensor Array: a turning radar dish on a braced mast, sweeping a scan wedge. Deep Scan fits a
## bigger dish; Target Painter adds laser designators.
static func _sensor(ci: CanvasItem, c: Vector2, s: float, tier: int, t: float, spec: String, acc: Color) -> void:
	var sweep := t * (2.4 if spec == "painter" else 1.4)
	var reach := (14.0 + 1.5 * float(tier) + (4.0 if spec == "deepscan" else 0.0)) * s
	var wedge := PackedVector2Array([c])
	for k in 7:
		wedge.append(c + Vector2.from_angle(sweep - 0.6 + 0.1 * float(k)) * reach)
	ci.draw_colored_polygon(wedge, Color(acc, 0.16))
	ci.draw_line(c, c + Vector2.from_angle(sweep) * reach, Color(acc, 0.8), 1.4 * s, true)
	plate(ci, c, ngon(8, 1.0, PI / 8.0), METAL, 0.0, 9.2 * s, 1.1)
	arc_segments(ci, c, 6.0 * s, 4, 0.5, -t * 0.8, Color(acc, 0.7), 1.2 * s)
	var dd := Vector2.from_angle(sweep)
	var dc := c + dd * 2.0 * s
	var dr := (6.5 + (1.5 if spec == "deepscan" else 0.0)) * s
	ci.draw_arc(dc, dr, sweep - 1.1, sweep + 1.1, 12, OUTLINE, 3.8 * s, true)
	ci.draw_arc(dc, dr, sweep - 1.1, sweep + 1.1, 12, METAL_L, 2.4 * s, true)
	ci.draw_arc(dc, dr - 0.8 * s, sweep - 0.9, sweep + 0.2, 8, METAL_L.lightened(0.35), 0.8 * s, true)
	for sgn in [-1.0, 1.0]:
		ci.draw_line(c, dc + Vector2.from_angle(sweep + 0.9 * sgn) * dr, Color(0.1, 0.12, 0.14), 1.0 * s, true)
	bar(ci, c, dc + dd * 4.0 * s, 1.4 * s, METAL_L)
	glow_dot(ci, dc + dd * 4.5 * s, 1.4 * s, acc)
	if spec == "painter":
		for k in 3:
			var a := sweep + PI + (float(k) - 1.0) * 0.5
			ci.draw_line(c, c + Vector2.from_angle(a) * 12.0 * s, Color(acc, 0.55), 1.0 * s, true)
	if tier >= 4:
		ring(ci, c, reach + 2.0 * s, Color(acc, 0.3 + 0.2 * sin(t * 3.0)), 1.0 * s)


## Graviton Projector: a containment ring of emitters around a pinned singularity, with space
## spiralling in. Repulsor pushes chevrons outward; Crush Field bristles with inward spikes.
static func _gravity(ci: CanvasItem, c: Vector2, s: float, tier: int, t: float, flash: float, spec: String, acc: Color) -> void:
	var pulse := clampf(flash / 0.35, 0.0, 1.0)
	plate(ci, c, ngon(12, 1.0), METAL_D, 0.0, 13.2 * s, 1.2)
	for k in 6:
		var ep := c + Vector2.from_angle(TAU * float(k) / 6.0 + t * 0.2) * 11.0 * s
		orb(ci, ep, 1.6 * s, METAL_L, s)
		ci.draw_circle(ep, 0.8 * s, Color(acc, 0.9))
	for k in 3:
		var ph := fmod(t * 0.7 + float(k) / 3.0, 1.0)
		var rr := lerpf(10.5, 4.0, ph) + pulse * 6.0
		ci.draw_arc(c, rr * s, 0.0, TAU, 20, Color(acc, 0.25 + 0.5 * ph), 1.2 * s, true)
	var spin := -t * (2.0 if spec == "crush" else 1.2)
	arc_segments(ci, c, (8.6 + float(tier) * 0.3) * s, 3 if spec != "crush" else 6, 0.6, spin, Color(acc, 0.9), 1.8 * s)
	if spec == "repulsor":
		for k in 4:
			var a := TAU * float(k) / 4.0 + t * 0.5
			var p := c + Vector2.from_angle(a) * 15.5 * s
			var dd := Vector2.from_angle(a)
			ci.draw_polyline(PackedVector2Array([p - dd.orthogonal() * 2.5 * s - dd * 1.5 * s, p + dd * 1.5 * s, p + dd.orthogonal() * 2.5 * s - dd * 1.5 * s]), Color(acc, 0.85), 1.4 * s, true)
	if spec == "crush":
		for k in 6:
			var a := TAU * float(k) / 6.0 - t * 0.4
			ci.draw_line(c + Vector2.from_angle(a) * 15.0 * s, c + Vector2.from_angle(a) * 8.0 * s, Color(acc, 0.7), 1.3 * s, true)
	ci.draw_circle(c, (4.8 + 1.5 * pulse) * s, Color(acc, 0.35))
	ci.draw_circle(c, (4.0 + 1.5 * pulse) * s, Color(0.01, 0.0, 0.04))
	ci.draw_arc(c, (4.2 + 1.5 * pulse) * s, t * 3.0, t * 3.0 + 4.0, 12, Color(1, 1, 1, 0.7), 0.8 * s, true)
	ci.draw_circle(c, 1.0 * s, Color(1, 1, 1, 0.8))


## Nullifier: three dampening prongs aimed at a pinned void sphere inside a rotating hex field.
## Purge Emitter adds red strip bands, Dampener concentric silence waves, Feedback Loop return arrows.
static func _nullifier(ci: CanvasItem, c: Vector2, s: float, tier: int, t: float, flash: float, spec: String, acc: Color) -> void:
	var pulse := clampf(flash / 0.3, 0.0, 1.0)
	plate(ci, c, ngon(8, 1.0, PI / 8.0), METAL_D, 0.0, 12.8 * s, 1.2)
	var field := ngon(6, 1.0, t * 0.4)
	outline(ci, c, field, Color(acc, 0.35 + 0.3 * pulse), 1.2 * s, 0.0, (10.5 + float(tier) * 0.6 + pulse * 5.0) * s)
	for k in 3:
		var a := TAU * float(k) / 3.0 - PI / 2.0
		var d := Vector2.from_angle(a)
		var prong := PackedVector2Array([c + d * 12.0 * s + d.orthogonal() * 3.2 * s, c + d * 5.8 * s, c + d * 12.0 * s - d.orthogonal() * 3.2 * s])
		ci.draw_colored_polygon(prong, METAL_L)
		ci.draw_polyline(prong + PackedVector2Array([prong[0]]), OUTLINE, 1.0 * s, true)
		if spec == "purge":
			ci.draw_line(c + d * 10.0 * s + d.orthogonal() * 2.2 * s, c + d * 10.0 * s - d.orthogonal() * 2.2 * s, Color(1.0, 0.35, 0.35), 1.4 * s, true)
		glow_dot(ci, c + d * 6.4 * s, 1.1 * s, acc)
	if spec == "dampener":
		for k in 2:
			var ph := fmod(t * 0.8 + float(k) * 0.5, 1.0)
			ci.draw_arc(c, (6.0 + ph * 9.0) * s, 0.0, TAU, 24, Color(acc, 0.5 * (1.0 - ph)), 1.0 * s, true)
	if spec == "feedback":
		for k in 2:
			var a0 := t * 1.6 + PI * float(k)
			ci.draw_arc(c, 9.0 * s, a0, a0 + 1.9, 10, Color(acc, 0.85), 1.4 * s, true)
			var tip := c + Vector2.from_angle(a0 + 1.9) * 9.0 * s
			var dd := Vector2.from_angle(a0 + 1.9 + PI / 2.0)
			ci.draw_polyline(PackedVector2Array([tip - dd * 2.0 * s + dd.orthogonal() * 2.0 * s, tip + dd * 1.5 * s, tip - dd * 2.0 * s - dd.orthogonal() * 2.0 * s]), Color(acc, 0.85), 1.2 * s, true)
	ci.draw_circle(c, (4.4 + 1.2 * pulse) * s, Color(acc, 0.3))
	ci.draw_circle(c, 3.6 * s, Color(0.02, 0.01, 0.05))
	ci.draw_arc(c, 3.8 * s, -t * 2.0, -t * 2.0 + 3.5, 10, Color(1, 1, 1, 0.75), 0.8 * s, true)
	if tier >= 2:
		ci.draw_circle(c, 1.0 * s, Color(acc.lightened(0.4), 0.9))


## Nova Reactor: a vented housing around a fusion core inside containment rings. Supernova carries a
## larger, hotter core; Pulse Reactor a spinning ring of emitters; Solar Flare curling flame tongues.
static func _nova(ci: CanvasItem, c: Vector2, s: float, tier: int, t: float, flash: float, spec: String, acc: Color) -> void:
	var pulse := clampf(flash / 0.35, 0.0, 1.0)
	plate(ci, c, ngon(10, 1.0, 0.0), METAL_D, 0.0, 13.0 * s, 1.2)
	for k in 4:
		var a := TAU * float(k) / 4.0 + PI / 4.0
		plate(ci, c + Vector2.from_angle(a) * 10.4 * s, rect_pts(0.22, 0.12), METAL, a, 10.0 * s, 1.0)
		ci.draw_line(c + Vector2.from_angle(a) * 9.4 * s, c + Vector2.from_angle(a) * 11.6 * s, Color(acc, 0.6 + 0.4 * pulse), 1.0 * s, true)
	var rings := 1 + mini(tier, 3)
	for k in rings:
		var rr := (5.8 + float(k) * 1.8) * s
		arc_segments(ci, c, rr, 4, 0.35, t * (0.8 + float(k) * 0.3) * (1.0 if k % 2 == 0 else -1.0), Color(acc, 0.5), 1.0 * s)
	if spec == "pulsereactor":
		for k in 6:
			var a := -t * 3.0 + TAU * float(k) / 6.0
			glow_dot(ci, c + Vector2.from_angle(a) * 8.6 * s, 0.9 * s, acc)
	if spec == "solarflare":
		for k in 3:
			var a := t * 0.9 + TAU * float(k) / 3.0
			var pts := PackedVector2Array()
			for i in 5:
				var f := float(i) / 4.0
				pts.append(c + Vector2.from_angle(a + sin(t * 4.0 + f * 3.0) * 0.4 * f) * (5.0 + f * 9.0) * s)
			ci.draw_polyline(pts, Color(1.0, 0.6, 0.2, 0.75), 1.4 * s, true)
	var core := (3.6 + (1.4 if spec == "supernova" else 0.0) + 0.3 * float(tier) + 2.0 * pulse) * s
	ci.draw_circle(c, core * 1.7, Color(acc, 0.18 + 0.2 * pulse))
	ci.draw_circle(c, core, acc.lightened(0.15))
	ci.draw_circle(c, core * 0.55, Color(1.0, 0.97, 0.85))


## Drone Bay: a hangar pad with a landing ring, a launch rail and an antenna, drones docked on its
## corners. Interceptors are slim darts, Bomber Wing carries heavy pods, Hunter-Killers red scanners.
static func _drone_bay(ci: CanvasItem, c: Vector2, s: float, tier: int, t: float, spec: String, acc: Color) -> void:
	plate(ci, c, rect_pts(1.0, 1.0), METAL_D, 0.0, 12.6 * s, 1.3)
	ring(ci, c, 7.4 * s, Color(acc, 0.55), 1.2 * s)
	ci.draw_line(c + Vector2(-2.6, -2.6) * s, c + Vector2(-2.6, 2.6) * s, Color(acc, 0.7), 1.1 * s)
	ci.draw_line(c + Vector2(2.6, -2.6) * s, c + Vector2(2.6, 2.6) * s, Color(acc, 0.7), 1.1 * s)
	ci.draw_line(c + Vector2(-2.6, 0) * s, c + Vector2(2.6, 0) * s, Color(acc, 0.7), 1.1 * s)
	bar(ci, c + Vector2(9.0, 9.0) * s, c + Vector2(9.0, -4.0) * s, 1.0 * s, METAL_L)
	if fmod(t * 1.3, 1.0) < 0.4:
		glow_dot(ci, c + Vector2(9.0, -4.8) * s, 1.1 * s, Color(1.0, 0.3, 0.3))
	var docked := mini(1 + tier, 4)
	var corners := [Vector2(-9, -9), Vector2(9, -9), Vector2(-9, 9), Vector2(9, 9)]
	for k in docked:
		drone(ci, c + corners[k] * s * 0.95, Vector2.UP, s * 0.8, t + float(k), spec, acc)


## Scrapyard: a salvage pad with a heap of wreckage, a crane swinging a magnet over it and a credit
## chip that glows brighter with each tier. Credit Mint adds a coin press and a stack of credits,
## Scrap Collector a heavier magnet crane over a conveyor, Supply Depot strapped supply crates.
static func _scrapyard(ci: CanvasItem, c: Vector2, s: float, tier: int, t: float, spec: String, acc: Color) -> void:
	var m4 := tier >= 4
	plate(ci, c, rect_pts(1.0, 1.0), METAL_D, 0.0, 12.6 * s, 1.3)
	# The heap: overlapping wreck plates, some rusted.
	var heap := [[Vector2(-5.5, 4.0), 4.2, 0.3, METAL], [Vector2(-2.0, 6.0), 3.6, 1.1, Color(0.42, 0.27, 0.18)],
		[Vector2(-7.0, 7.0), 3.0, 2.0, METAL_L], [Vector2(-3.5, 2.2), 2.6, 0.7, Color(0.36, 0.30, 0.26)],
		[Vector2(-8.4, 2.0), 2.4, 1.6, Color(0.46, 0.30, 0.20)]]
	for h in heap:
		plate(ci, c + h[0] * s, ngon(5, 1.0, h[2]), h[3], 0.0, float(h[1]) * s, 0.9)
	ci.draw_line(c + Vector2(-9.0, 5.5) * s, c + Vector2(-4.0, 8.5) * s, Color(0.65, 0.66, 0.7), 0.8 * s)
	if spec == "collector":
		# A conveyor strip feeding the heap, rollers turning.
		plate(ci, c + Vector2(3.0, 8.0) * s, rect_pts(0.75, 0.16), METAL, 0.0, 10.0 * s, 1.0)
		for k in 4:
			var rx := -3.5 + fmod(t * 6.0 + float(k) * 2.5, 10.0)
			ci.draw_line(c + Vector2(rx, 6.8) * s, c + Vector2(rx, 9.2) * s, Color(acc, 0.8), 0.9 * s)
	if spec == "depot":
		# Two strapped supply crates.
		for cr in [[Vector2(5.5, 6.0), 3.6], [Vector2(9.0, 2.5), 2.8]]:
			plate(ci, c + cr[0] * s, rect_pts(1.0, 1.0), Color(0.36, 0.30, 0.22), 0.0, float(cr[1]) * s, 1.0)
			ci.draw_line(c + (cr[0] + Vector2(-cr[1], 0)) * s, c + (cr[0] + Vector2(cr[1], 0)) * s, acc, 1.0 * s)
			ci.draw_line(c + (cr[0] + Vector2(0, -cr[1])) * s, c + (cr[0] + Vector2(0, cr[1])) * s, acc, 1.0 * s)
	if spec == "mint":
		# A coin press stamping over a stack of credits.
		for k in mini(2 + tier, 5):
			var cp := c + Vector2(6.5, 7.5 - float(k) * 1.5) * s
			ellipse(ci, cp, 3.2 * s, 1.3 * s, OUTLINE)
			ellipse(ci, cp + Vector2(0, -0.2) * s, 2.8 * s, 1.0 * s, GOLD.darkened(0.1 if k % 2 == 0 else 0.25))
		var stamp := absf(sin(t * 3.0))
		bar(ci, c + Vector2(6.5, -2.0) * s, c + Vector2(6.5, 1.0 + 2.0 * stamp) * s, 2.4 * s, METAL_L)
		plate(ci, c + Vector2(6.5, 1.4 + 2.0 * stamp) * s, rect_pts(1.0, 0.35), METAL, 0.0, 3.6 * s, 0.9)
	# The crane: a mast in the top-right corner, a boom and a swinging magnet over the heap.
	var mast := c + Vector2(8.0, -8.0) * s
	orb(ci, mast, 2.6 * s, METAL_L, s)
	var swing := sin(t * 0.9) * 0.35
	var tip := mast + Vector2.from_angle(PI * 0.78 + swing) * (15.0 if spec == "collector" else 13.0) * s
	bar(ci, mast, tip, (2.4 if spec == "collector" else 1.8) * s, METAL_L)
	ci.draw_line(tip, tip + Vector2(0, 3.5) * s, OUTLINE, 0.8 * s)
	var mag_r := (3.2 if spec == "collector" else 2.4) * s
	ci.draw_circle(tip + Vector2(0, 4.5) * s, mag_r + 0.8 * s, OUTLINE)
	ci.draw_circle(tip + Vector2(0, 4.5) * s, mag_r, Color(acc, 0.9) if spec == "collector" else METAL)
	ci.draw_arc(tip + Vector2(0, 4.5) * s, mag_r * 0.6, PI, TAU, 8, Color(1, 1, 1, 0.35), 0.8 * s, true)
	# The credit chip: brighter with each tier, gold once mastered.
	var chip := c + Vector2(-8.0, -8.0) * s
	var pulse := 0.5 + 0.5 * sin(t * 2.5)
	ci.draw_circle(chip, (2.6 + 0.4 * float(tier) + pulse) * s, Color(GOLD if m4 else acc, 0.22))
	fill(ci, chip, ngon(6, 1.0, PI / 6.0), OUTLINE, 0.0, 3.4 * s)
	fill(ci, chip, ngon(6, 1.0, PI / 6.0), GOLD if m4 or spec == "mint" else acc, 0.0, 2.7 * s)
	ci.draw_circle(chip, 0.9 * s, Color(1, 1, 0.9))

## A single drone (also drawn in flight by the entity layer).
static func drone(ci: CanvasItem, p: Vector2, facing: Vector2, s: float, t: float, spec: String, acc: Color, bomber := false) -> void:
	var n := facing.orthogonal()
	if bomber or spec == "bombers":
		plate(ci, p, rect_pts(0.5, 0.4), METAL, facing.angle(), 6.0 * s, 1.0)
		ci.draw_circle(p + facing * 1.0 * s, 1.6 * s, Color(0.1, 0.1, 0.1))
		glow_dot(ci, p - facing * 2.2 * s, 0.8 * s, Color(1.0, 0.55, 0.2))
		return
	for k in 4:
		var a := facing.angle() + PI / 4.0 + TAU * float(k) / 4.0
		var tip := p + Vector2.from_angle(a) * 3.2 * s
		ci.draw_line(p, tip, METAL_L, 0.9 * s, true)
		ci.draw_arc(tip, 1.4 * s, t * 30.0, t * 30.0 + 2.4, 5, Color(0.85, 0.9, 1.0, 0.6), 0.6 * s, true)
	var body := PackedVector2Array([p + facing * 2.6 * s, p + n * 1.5 * s - facing * 1.4 * s, p - n * 1.5 * s - facing * 1.4 * s])
	ci.draw_colored_polygon(body, METAL.lightened(0.1) if spec != "interceptors" else acc.darkened(0.3))
	glow_dot(ci, p + facing * 1.2 * s, 0.7 * s, Color(1.0, 0.25, 0.25) if spec == "hunters" else acc)


## EMP overlay for a tower a Jammer knocked offline.
static func tower_offline(ci: CanvasItem, c: Vector2, t: float) -> void:
	var col := Color(0.9, 1.0, 0.3)
	ci.draw_circle(c, 17.0, Color(0.05, 0.06, 0.02, 0.45))
	for k in 3:
		var a := t * 7.0 + float(k) * 2.1
		var p0 := c + Vector2.from_angle(a) * 6.0
		var p1 := c + Vector2.from_angle(a + 0.5) * 12.0 + Vector2(sin(t * 40.0 + float(k)) * 2.0, 0)
		var p2 := c + Vector2.from_angle(a + 0.2) * 17.0
		ci.draw_polyline(PackedVector2Array([p0, p1, p2]), Color(col, 0.8), 1.3, true)
	arc_segments(ci, c, 19.0, 4, 0.8, t * 3.0, Color(col, 0.6), 1.2)


# --- Enemies ---------------------------------------------------------------------------------

## An ellipse rotated by `rot` (radians), as a filled polygon.
static func oval(ci: CanvasItem, c: Vector2, rx: float, ry: float, rot: float, color: Color, outline_w := 0.0) -> void:
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * float(i) / 20.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry).rotated(rot))
	if outline_w > 0.0:
		var big := PackedVector2Array()
		for p in pts:
			big.append(c + (p - c) * (1.0 + outline_w / maxf(rx, ry)))
		ci.draw_colored_polygon(big, OUTLINE)
	ci.draw_colored_polygon(pts, color)


## A shaded oval: outline, base, lit face toward the light, glint.
static func shaded_oval(ci: CanvasItem, c: Vector2, rx: float, ry: float, rot: float, col: Color, s := 1.0) -> void:
	oval(ci, c, rx, ry, rot, col.darkened(0.3), 1.3 * s)
	oval(ci, c + LIGHT * minf(rx, ry) * 0.12, rx * 0.8, ry * 0.78, rot, col)
	ci.draw_circle(c + LIGHT * minf(rx, ry) * 0.5, maxf(0.6, minf(rx, ry) * 0.14), Color(1, 1, 1, 0.45))


## A jointed limb: segments with a joint dot at each bend.
static func limb(ci: CanvasItem, pts: PackedVector2Array, w: float, col: Color) -> void:
	ci.draw_polyline(pts, OUTLINE, w + 1.4, true)
	ci.draw_polyline(pts, col, w, true)
	for i in range(1, pts.size() - 1):
		ci.draw_circle(pts[i], w * 0.75 + 0.4, OUTLINE)
		ci.draw_circle(pts[i], w * 0.75, col.lightened(0.25))


static func enemy(ci: CanvasItem, type: String, c: Vector2, facing: Vector2, r: float, t: float, slowed := false, flash := 0.0, s := 1.0, hidden := false) -> void:
	var body: Color = ENEMY_BODY.get(type, METAL)
	var glow: Color = ENEMY_COLOR.get(type, Color.WHITE)
	var rr := r * s
	var ang := facing.angle()
	var n := facing.orthogonal()
	if not (type in ["bat", "locust", "gunship", "leviathan"]) and not hidden:
		ellipse(ci, c + Vector2(0, rr * 0.75), rr * 1.1, rr * 0.45, Color(0, 0, 0, 0.3))
	match type:
		"grunt":
			# Drone: a hovering combat disc with side thrusters, an armour ring, a gun and one red optic.
			ci.draw_circle(c, rr * 1.2, Color(glow, 0.07))
			for side in [-1.0, 1.0]:
				var pod: Vector2 = c + n * side * rr * 0.95
				plate(ci, pod, rect_pts(0.5, 0.24), METAL_D.lightened(0.1), ang, rr, 1.0)
				strip(ci, pod - facing * rr * 0.55 - n * rr * 0.12, pod - facing * rr * 0.55 + n * rr * 0.12, 0.8 * s, Color(0.4, 0.8, 1.0))
			bar(ci, c + facing * rr * 0.3, c + facing * rr * 1.3, 2.0 * s, METAL_L)
			ci.draw_circle(c + facing * rr * 1.3, 1.1 * s, Color(0.05, 0.05, 0.05))
			orb(ci, c, rr * 0.86, body, s)
			arc_segments(ci, c, rr * 0.64, 6, 0.35, ang, body.darkened(0.35), 1.4 * s)
			ci.draw_circle(c + facing * rr * 0.12, rr * 0.4, OUTLINE)
			ci.draw_circle(c + facing * rr * 0.12, rr * 0.33, Color(0.15, 0.03, 0.03))
			glow_dot(ci, c + facing * rr * 0.12, rr * 0.2, glow)
			ci.draw_circle(c + facing * rr * 0.12 + LIGHT * rr * 0.15, rr * 0.07, Color(1, 1, 1, 0.8))
		"runner":
			# Skitter: a fast spider-bot on six jointed legs, with an armoured abdomen and mandibles.
			for i in 3:
				for side in [-1.0, 1.0]:
					var ph := t * 20.0 + float(i) * 2.1 + (PI if side > 0.0 else 0.0)
					var root: Vector2 = c + facing * (1.0 - float(i)) * rr * 0.35 + n * side * rr * 0.28
					var knee: Vector2 = root + n * side * rr * 0.7 + facing * ((1.0 - float(i)) * 0.35 + 0.22 * sin(ph)) * rr
					var foot: Vector2 = knee + n * side * rr * 0.3 + facing * ((1.0 - float(i)) * 0.45) * rr
					limb(ci, PackedVector2Array([root, knee, foot]), 1.0 * s, METAL_L)
			shaded_oval(ci, c - facing * rr * 0.35, rr * 0.56, rr * 0.43, ang, body, s)
			for k in 2:
				var sp := c - facing * rr * (0.2 + 0.25 * float(k))
				ci.draw_line(sp - n * rr * 0.35, sp + n * rr * 0.35, Color(0, 0, 0, 0.45), 1.0 * s, true)
			strip(ci, c - facing * rr * 0.65, c - facing * rr * 0.1, 0.8 * s, glow)
			orb(ci, c + facing * rr * 0.35, rr * 0.35, body.lightened(0.15), s)
			for side in [-1.0, 1.0]:
				ci.draw_line(c + facing * rr * 0.6 + n * side * rr * 0.12, c + facing * rr * 0.85 + n * side * rr * 0.04, METAL_L, 1.0 * s, true)
				glow_dot(ci, c + facing * rr * 0.5 + n * side * rr * 0.14, rr * 0.08, glow)
		"brute":
			# Siege Mech: a stomping biped with hydraulic legs, riveted armour and two shoulder cannons.
			for side in [-1.0, 1.0]:
				var step := sin(t * 5.0 + (PI if side > 0.0 else 0.0)) * rr * 0.35
				var hip: Vector2 = c + n * side * rr * 0.45
				var knee: Vector2 = hip + n * side * rr * 0.2 + facing * step * 0.5
				var foot: Vector2 = hip + n * side * rr * 0.15 + facing * step
				limb(ci, PackedVector2Array([hip, knee, foot]), 3.0 * s, METAL_D.lightened(0.1))
				plate(ci, foot, rect_pts(0.32, 0.2), METAL_L, ang, rr, 1.0)
			var hull := ngon(6, 1.0)
			plate(ci, c, hull, body, ang, rr * 0.84, 1.6)
			rivets(ci, c, hull, ang, rr * 0.84, 0.78, 0.6 * s)
			fill(ci, c, rect_pts(0.3, 0.42), body.darkened(0.15), ang, rr)
			for side in [-1.0, 1.0]:
				var sh: Vector2 = c + n * side * rr * 0.78
				plate(ci, sh, rect_pts(0.34, 0.3), METAL_L, ang, rr, 1.2)
				bar(ci, sh + facing * rr * 0.2, sh + facing * rr * 1.15, 2.4 * s, METAL_L)
				ci.draw_circle(sh + facing * rr * 1.15, 1.4 * s, Color(0.05, 0.05, 0.05))
				ci.draw_circle(sh + facing * rr * 1.15, 0.8 * s, Color(glow, 0.9))
			var visor := c + facing * rr * 0.42
			strip(ci, visor - n * rr * 0.28, visor + n * rr * 0.28, 1.6 * s, glow)
		"swarmling":
			# Nanite: a tiny cloud of machines orbiting a glowing core.
			ci.draw_circle(c, rr * 1.7, Color(glow, 0.13))
			for k in 4:
				var p := c + Vector2.from_angle(t * 7.0 + TAU * float(k) / 4.0) * rr * 0.78
				var dia := PackedVector2Array([Vector2(0.5, 0), Vector2(0, 0.35), Vector2(-0.5, 0), Vector2(0, -0.35)])
				solid(ci, p, dia, body.lightened(0.35), t * 7.0, rr, 0.8)
				ci.draw_circle(p, rr * 0.11, glow)
			orb(ci, c, rr * 0.34, body.lightened(0.2), s)
			glow_dot(ci, c, rr * 0.18, glow)
		"bat":
			# Strike Drone: a quad-rotor attack drone: X-frame arms, four spinning rotors, a gimballed
			# camera up front, twin weapon pods and blinking navigation lights.
			ellipse(ci, c + Vector2(0, rr * 2.4), rr * 1.3, rr * 0.4, Color(0, 0, 0, 0.2))
			for k in 4:
				var a := ang + PI / 4.0 + TAU * float(k) / 4.0
				var tip := c + Vector2.from_angle(a) * rr * 1.2
				bar(ci, c, tip, 1.8 * s, METAL_D.lightened(0.15))
				ci.draw_circle(tip, rr * 0.62, Color(0.8, 0.86, 0.95, 0.12))
				ci.draw_arc(tip, rr * 0.62, 0.0, TAU, 16, Color(0.8, 0.86, 0.95, 0.35), 0.8 * s, true)
				var spin := t * 38.0 * (1.0 if k % 2 == 0 else -1.0)
				for b in 2:
					var bd := Vector2.from_angle(spin + float(b) * PI)
					ci.draw_line(tip, tip + bd * rr * 0.58, Color(0.85, 0.9, 1.0, 0.55), 1.2 * s, true)
				orb(ci, tip, rr * 0.17, METAL_L, s)
				var nav := Color(1.0, 0.25, 0.25) if k < 2 else Color(0.3, 1.0, 0.45)
				if fmod(t * 1.5 + float(k) * 0.25, 1.0) < 0.35:
					glow_dot(ci, c + Vector2.from_angle(a) * rr * 0.72, rr * 0.08, nav)
			var fuselage := PackedVector2Array([Vector2(0.62, 0), Vector2(0.35, 0.36), Vector2(-0.5, 0.3), Vector2(-0.62, 0), Vector2(-0.5, -0.3), Vector2(0.35, -0.36)])
			plate(ci, c, fuselage, body, ang, rr, 1.2)
			for side in [-1.0, 1.0]:
				var pod: Vector2 = c + n * side * rr * 0.34 + facing * rr * 0.1
				bar(ci, pod, pod + facing * rr * 0.45, 1.6 * s, METAL_L)
			var cam := c + facing * rr * 0.42
			orb(ci, cam, rr * 0.2, METAL, s)
			glow_dot(ci, cam + facing * rr * 0.06, rr * 0.09, glow)
			strip(ci, c - facing * rr * 0.35 - n * rr * 0.12, c - facing * rr * 0.35 + n * rr * 0.12, 0.7 * s, glow)
		"shaman":
			# Repair Bot: a tracked medic unit with two welding arms and an emissive repair cross.
			ci.draw_arc(c, rr * 2.0 + sin(t * 3.0) * 2.0, 0.0, TAU, 28, Color(glow, 0.25), 2.0, true)
			for side in [-1.0, 1.0]:
				var tr: Vector2 = c + n * side * rr * 0.82
				plate(ci, tr, rect_pts(0.66, 0.2), METAL_D.lightened(0.1), ang, rr, 1.0)
				for k in 3:
					var lp: Vector2 = tr + facing * (fmod(t * 8.0 + float(k) * 0.45, 1.3) - 0.65) * rr
					ci.draw_line(lp - n * rr * 0.16, lp + n * rr * 0.16, Color(0, 0, 0, 0.45), 0.9 * s)
				var sh: Vector2 = c + facing * rr * 0.35 + n * side * rr * 0.5
				var elbow: Vector2 = sh + facing * rr * 0.55 + n * side * rr * 0.45
				var claw: Vector2 = elbow + facing * rr * 0.55 - n * side * rr * 0.12 + facing * sin(t * 6.0 + side) * rr * 0.08
				limb(ci, PackedVector2Array([sh, elbow, claw]), 1.6 * s, METAL_L)
				ci.draw_arc(claw, rr * 0.16, ang - 1.2, ang + 1.2, 6, METAL_L, 1.4 * s, true)
				if fmod(t * 2.0 + (0.5 if side > 0.0 else 0.0), 1.0) < 0.15:
					glow_dot(ci, claw + facing * rr * 0.12, rr * 0.12, glow)
			orb(ci, c, rr * 0.8, body, s)
			ci.draw_rect(Rect2(c - Vector2(rr * 0.4, rr * 0.13), Vector2(rr * 0.8, rr * 0.26)), Color(glow, 0.3).lerp(glow, 0.8))
			ci.draw_rect(Rect2(c - Vector2(rr * 0.13, rr * 0.4), Vector2(rr * 0.26, rr * 0.8)), glow)
			ci.draw_rect(Rect2(c - Vector2(rr * 0.05, rr * 0.3), Vector2(rr * 0.1, rr * 0.6)), Color(1, 1, 1, 0.55))
			var ant := c - facing * rr * 0.6 + n * rr * 0.55
			ci.draw_line(ant, ant - facing * rr * 0.6 + n * rr * 0.3, METAL_L, 1.2 * s, true)
			glow_dot(ci, ant - facing * rr * 0.6 + n * rr * 0.3, 1.3 * s, glow)
		"phantom":
			# Cloaked: only a faint heat-shimmer outline until a Sensor Array reveals it.
			var a := 0.2 + 0.08 * sin(t * 7.0) if hidden else 1.0
			var blade := PackedVector2Array([Vector2(1.4, 0), Vector2(0.1, 0.55), Vector2(-0.9, 1.0), Vector2(-0.5, 0), Vector2(-0.9, -1.0), Vector2(0.1, -0.55)])
			if hidden:
				var ripple := fmod(t * 1.3, 1.0)
				ci.draw_arc(c, rr * (1.0 + 0.8 * ripple), 0.0, TAU, 18, Color(0.8, 0.95, 1.0, 0.22 * (1.0 - ripple)), 1.0 * s, true)
				outline(ci, c, blade, Color(glow, a), 1.2 * s, ang, rr)
				outline(ci, c + n * sin(t * 11.0) * 1.5 * s, blade, Color(glow, a * 0.5), 1.0 * s, ang, rr * 1.08)
			else:
				plate(ci, c, blade, body, ang, rr, 1.2)
				ci.draw_line(c - facing * rr * 0.4, c + facing * rr * 1.1, Color(glow, 0.5), 1.0 * s, true)
				for side in [-1.0, 1.0]:
					glow_dot(ci, c + facing * rr * 0.35 + n * side * rr * 0.28, rr * 0.13, glow)
					strip(ci, c - facing * rr * 0.75 + n * side * rr * 0.55, c - facing * rr * 0.55 + n * side * rr * 0.4, 0.8 * s, glow)
				ring(ci, c, rr * 1.3, Color(glow, 0.35 + 0.2 * sin(t * 5.0)), 1.0 * s)
		"aegis":
			# Aegis Walker: a four-legged walker behind a curved shield plate (its barrier projector).
			for k in 4:
				var la := ang + PI / 4.0 + float(k) * PI / 2.0
				var ld := Vector2.from_angle(la)
				var step := sin(t * 6.0 + float(k) * PI / 2.0) * rr * 0.18
				var knee := c + ld * rr * 0.75 + facing * step
				var foot := knee + ld * rr * 0.35
				limb(ci, PackedVector2Array([c + ld * rr * 0.3, knee, foot]), 2.0 * s, METAL_L)
			var hull3 := ngon(6, 1.0, PI / 6.0)
			plate(ci, c, hull3, body, ang, rr * 0.74, 1.4)
			rivets(ci, c, hull3, ang, rr * 0.74, 0.75, 0.55 * s)
			orb(ci, c - facing * rr * 0.25, rr * 0.2, glow.darkened(0.3), s)
			glow_dot(ci, c - facing * rr * 0.25, rr * 0.12, glow)
			var sc := c + facing * rr * 0.2
			ci.draw_arc(sc, rr * 0.95, ang - 0.95, ang + 0.95, 16, OUTLINE, 5.6 * s, true)
			ci.draw_arc(sc, rr * 0.95, ang - 0.95, ang + 0.95, 16, METAL_L, 3.8 * s, true)
			ci.draw_arc(sc, rr * 0.88, ang - 0.8, ang + 0.1, 10, METAL_L.lightened(0.35), 1.0 * s, true)
			for k in 3:
				var hp := sc + Vector2.from_angle(ang + (float(k) - 1.0) * 0.55) * rr * 0.95
				ci.draw_circle(hp, 0.9 * s, Color(glow, 0.9))
			ci.draw_arc(sc, rr * 1.04, ang - 0.9, ang + 0.9, 16, Color(glow, 0.8), 1.2 * s, true)
		"hydra":
			# Hydra Frame: an armoured body with three swaying serpent heads (it splits apart when killed).
			shaded_oval(ci, c - facing * rr * 0.3, rr * 0.52, rr * 0.48, ang, body, s)
			ring(ci, c - facing * rr * 0.3, rr * 0.3, body.darkened(0.35), 1.3 * s)
			glow_dot(ci, c - facing * rr * 0.3, rr * 0.1, glow)
			for k in 3:
				var base_a := ang + (float(k) - 1.0) * 0.7
				var pts := PackedVector2Array()
				for i in 5:
					var f := float(i) / 4.0
					var sway := sin(t * 4.0 + float(k) * 1.7 - f * 2.0) * rr * 0.22 * f
					pts.append(c + Vector2.from_angle(base_a) * rr * (0.05 + 1.05 * f) + Vector2.from_angle(base_a + PI / 2.0) * sway)
				ci.draw_polyline(pts, OUTLINE, 5.0 * s, true)
				ci.draw_polyline(pts, body.lightened(0.15), 3.2 * s, true)
				for i in range(1, 4):
					ci.draw_circle(pts[i], 1.0 * s, body.darkened(0.25))
				var hd := (pts[4] - pts[3]).normalized()
				var headp := pts[4] + hd * rr * 0.12
				var skull := PackedVector2Array([Vector2(0.6, 0), Vector2(0.05, 0.38), Vector2(-0.4, 0.3), Vector2(-0.4, -0.3), Vector2(0.05, -0.38)])
				plate(ci, headp, skull, body.lightened(0.1), hd.angle(), rr * 0.5, 1.0)
				var jaw := hd.orthogonal() * rr * 0.1 * (1.0 + sin(t * 8.0 + float(k)))
				ci.draw_line(headp + hd * rr * 0.28 + jaw, headp + hd * rr * 0.1, METAL_L, 1.0 * s, true)
				glow_dot(ci, headp + hd * rr * 0.06, rr * 0.1, glow)
		"jammer":
			# Jammer: a tracked electronic-warfare rig with a spinning dish, a mast and EMP rings.
			var ping := fmod(t * 0.9, 1.0)
			ci.draw_arc(c, rr * (1.2 + 1.4 * ping), 0.0, TAU, 24, Color(glow, 0.35 * (1.0 - ping)), 1.5 * s, true)
			for side in [-1.0, 1.0]:
				var tr: Vector2 = c + n * side * rr * 0.72
				plate(ci, tr, rect_pts(0.8, 0.22), METAL_D.lightened(0.08), ang, rr, 1.0)
				for k in 3:
					var lp: Vector2 = tr + facing * (fmod(t * 6.0 + float(k) * 0.5, 1.5) - 0.75) * rr
					ci.draw_line(lp - n * rr * 0.16, lp + n * rr * 0.16, Color(0, 0, 0, 0.45), 0.9 * s)
			orb(ci, c, rr * 0.72, body, s)
			var dir := Vector2.from_angle(t * 2.5)
			ci.draw_arc(c, rr * 0.55, t * 2.5 - 0.9, t * 2.5 + 0.9, 8, OUTLINE, 3.6 * s, true)
			ci.draw_arc(c, rr * 0.55, t * 2.5 - 0.9, t * 2.5 + 0.9, 8, METAL_L, 2.2 * s, true)
			bar(ci, c, c + dir * rr * 0.9, 1.2 * s, METAL_L)
			glow_dot(ci, c + dir * rr * 0.9, rr * 0.14, glow)
			glow_dot(ci, c, rr * 0.18, glow)
		"juggernaut":
			# Dreadnought: a super-heavy tank: wheeled treads, armour skirts, a riveted hull and a
			# twin-cannon turret with muzzle brakes.
			var roll := fmod(t * 20.0, 6.0)
			for side in [-1.0, 1.0]:
				var tread: Vector2 = c + n * side * rr * 0.8
				plate(ci, tread, rect_pts(1.2, 0.3), METAL_D.lightened(0.05), ang, rr, 1.4)
				for k in 6:
					var lp := tread + facing * (-rr * 1.1 + fmod(float(k) * rr * 0.4 + roll, rr * 2.3))
					ci.draw_line(lp - n * rr * 0.26, lp + n * rr * 0.26, METAL_L, 1.1 * s)
				for k in 4:
					var wp := tread + facing * (float(k) - 1.5) * rr * 0.6
					ci.draw_circle(wp, rr * 0.12, Color(0, 0, 0, 0.35))
			var hull2 := PackedVector2Array([Vector2(1.05, -0.45), Vector2(1.05, 0.45), Vector2(0.6, 0.62), Vector2(-0.95, 0.62), Vector2(-1.05, 0.4), Vector2(-1.05, -0.4), Vector2(-0.95, -0.62), Vector2(0.6, -0.62)])
			plate(ci, c, hull2, body, ang, rr * 0.82, 1.8)
			rivets(ci, c, hull2, ang, rr * 0.82, 0.85, 0.7 * s)
			for side in [-1.0, 1.0]:
				var bp: Vector2 = c + n * side * rr * 0.16
				bar(ci, bp, bp + facing * rr * 1.25, 3.2 * s, METAL_L)
				plate(ci, bp + facing * rr * 1.22, rect_pts(0.12, 0.1), METAL_L, ang, rr, 1.0)
			orb(ci, c, rr * 0.44, body.lightened(0.15), s)
			ring(ci, c, rr * 0.28, body.darkened(0.35), 1.4 * s)
			for side in [-1.0, 1.0]:
				glow_dot(ci, c - facing * rr * 0.62 + n * side * rr * 0.45, 1.6 * s, glow)
		"warlord":
			# Overmind: a hive-mind brain with glowing folds and veins, trailing control tentacles.
			for i in 6:
				var a := ang + PI + (float(i) - 2.5) * 0.45
				var wave := sin(t * 3.0 + float(i)) * 0.35
				var tp := PackedVector2Array([c + Vector2.from_angle(a) * rr * 0.75, c + Vector2.from_angle(a + wave) * rr * 1.3, c + Vector2.from_angle(a + wave * 2.0) * rr * 1.75])
				ci.draw_polyline(tp, OUTLINE, 4.5 * s, true)
				ci.draw_polyline(tp, body.lightened(0.3), 2.8 * s, true)
				for p in tp:
					ci.draw_circle(p, 1.1 * s, body.lightened(0.45))
				glow_dot(ci, tp[2], 1.4 * s, glow)
			var pulse := 0.5 + 0.5 * sin(t * 3.0)
			ci.draw_circle(c, rr * (1.12 + 0.08 * pulse), Color(glow, 0.12))
			for side in [-1.0, 1.0]:
				shaded_oval(ci, c + n * side * rr * 0.36, rr * 0.9, rr * 0.5, ang, body.lightened(0.12), s)
			ci.draw_line(c - facing * rr * 0.85, c + facing * rr * 0.85, OUTLINE, 2.4 * s, true)
			for side in [-1.0, 1.0]:
				for k in 3:
					var fc: Vector2 = c + n * side * rr * 0.38 + facing * (float(k) - 1.0) * rr * 0.5
					ci.draw_arc(fc, rr * 0.22, ang + (0.3 if side > 0.0 else PI + 0.3), ang + (2.8 if side > 0.0 else PI + 2.8), 8, Color(glow, 0.35 + 0.4 * pulse), 1.4 * s, true)
				var vein := PackedVector2Array([c + n * side * rr * 0.1 - facing * rr * 0.6, c + n * side * rr * 0.5 - facing * rr * 0.1, c + n * side * rr * 0.3 + facing * rr * 0.55])
				ci.draw_polyline(vein, Color(glow, 0.3 + 0.3 * pulse), 0.8 * s, true)
			orb(ci, c + facing * rr * 0.9, rr * 0.2, glow.darkened(0.4), s)
			glow_dot(ci, c + facing * rr * 0.9, rr * 0.13, glow)
		"locust":
			# Locust: a tiny winged micro-drone: two pairs of flickering wings over a slim body.
			ellipse(ci, c + Vector2(0, rr * 2.6), rr * 0.9, rr * 0.3, Color(0, 0, 0, 0.18))
			var flap := 0.55 + 0.45 * sin(t * 60.0)
			for side in [-1.0, 1.0]:
				for k in 2:
					var root: Vector2 = c + facing * rr * (0.25 - 0.45 * float(k))
					var tip: Vector2 = root + n * side * rr * (1.5 * flap + 0.3) - facing * rr * 0.35
					ci.draw_line(root, tip, Color(0.85, 0.95, 0.8, 0.45), 1.6 * s, true)
			shaded_oval(ci, c - facing * rr * 0.1, rr * 0.9, rr * 0.42, ang, body, s)
			glow_dot(ci, c + facing * rr * 0.6, rr * 0.3, glow)
		"gunship":
			# Gunship: an armored heavy flyer: twin ducted fans, a plated hull, a chin turret with twin
			# barrels and a tail boom with a stabilizer.
			ellipse(ci, c + Vector2(0, rr * 2.0), rr * 1.4, rr * 0.4, Color(0, 0, 0, 0.22))
			bar(ci, c - facing * rr * 0.4, c - facing * rr * 1.35, 2.4 * s, METAL_D.lightened(0.12))
			plate(ci, c - facing * rr * 1.35, rect_pts(0.1, 0.42), METAL, ang, rr, 1.0)
			for side in [-1.0, 1.0]:
				var fan: Vector2 = c + n * side * rr * 0.95 - facing * rr * 0.1
				ci.draw_circle(fan, rr * 0.5, OUTLINE)
				ci.draw_circle(fan, rr * 0.44, METAL_D)
				var spin: float = t * 30.0 * side
				for b in 3:
					var bd := Vector2.from_angle(spin + TAU * float(b) / 3.0)
					ci.draw_line(fan, fan + bd * rr * 0.4, Color(0.8, 0.85, 0.95, 0.5), 1.4 * s, true)
				ring(ci, fan, rr * 0.47, METAL_L, 1.6 * s)
				glow_dot(ci, fan - facing * rr * 0.5, rr * 0.08, Color(1.0, 0.25, 0.25) if side < 0.0 else Color(0.3, 1.0, 0.45))
			var hullg := PackedVector2Array([Vector2(0.95, 0), Vector2(0.55, 0.5), Vector2(-0.6, 0.55), Vector2(-0.85, 0.2), Vector2(-0.85, -0.2), Vector2(-0.6, -0.55), Vector2(0.55, -0.5)])
			plate(ci, c, hullg, body, ang, rr * 0.8, 1.6)
			rivets(ci, c, hullg, ang, rr * 0.8, 0.72, 0.6 * s)
			ci.draw_line(c - facing * rr * 0.4, c + facing * rr * 0.45, Color(0, 0, 0, 0.35), 1.0 * s, true)
			var tur := c + facing * rr * 0.55
			for side in [-1.0, 1.0]:
				bar(ci, tur + n * side * rr * 0.1, tur + n * side * rr * 0.1 + facing * rr * 0.6, 1.8 * s, METAL_L)
			orb(ci, tur, rr * 0.22, METAL, s)
			glow_dot(ci, c + facing * rr * 0.2, rr * 0.1, glow)
		"burrower":
			# Burrower: a drill-nosed mole bot on treads. Underground, only a moving mound of earth
			# and the drill tip show.
			if hidden:
				var dirt := Color(0.42, 0.33, 0.24)
				shaded_oval(ci, c, rr * 1.15, rr * 0.8, ang, dirt, s)
				for k in 5:
					var a := ang + TAU * float(k) / 5.0 + t * 0.5
					ci.draw_circle(c + Vector2.from_angle(a) * rr * (0.85 + 0.15 * sin(t * 9.0 + float(k))), 1.4 * s, dirt.lightened(0.2))
				ci.draw_line(c + facing * rr * 0.6, c + facing * rr * 1.05, METAL_L, 2.0 * s, true)
				glow_dot(ci, c + facing * rr * 0.2, rr * 0.12, Color(glow, 0.6))
			else:
				for side in [-1.0, 1.0]:
					var tr: Vector2 = c + n * side * rr * 0.72
					plate(ci, tr, rect_pts(0.7, 0.2), METAL_D.lightened(0.08), ang, rr, 1.0)
					for k in 3:
						var lp: Vector2 = tr + facing * (fmod(t * 7.0 + float(k) * 0.45, 1.35) - 0.68) * rr
						ci.draw_line(lp - n * rr * 0.15, lp + n * rr * 0.15, Color(0, 0, 0, 0.45), 0.9 * s)
				shaded_oval(ci, c - facing * rr * 0.15, rr * 0.7, rr * 0.58, ang, body, s)
				for k in 2:
					var sp := c - facing * rr * (0.05 + 0.3 * float(k))
					ci.draw_line(sp - n * rr * 0.5, sp + n * rr * 0.5, Color(0, 0, 0, 0.35), 1.0 * s, true)
				var drill := PackedVector2Array([Vector2(1.45, 0), Vector2(0.5, 0.42), Vector2(0.5, -0.42)])
				plate(ci, c, drill, METAL_L, ang, rr, 1.2)
				for k in 3:
					var f := fmod(t * 5.0 + float(k) / 3.0, 1.0)
					var x := 0.55 + 0.8 * f
					var hw := 0.42 * (1.45 - x) / 0.95
					ci.draw_line(c + facing * rr * x - n * rr * hw, c + facing * rr * (x + 0.12) + n * rr * hw, Color(0, 0, 0, 0.45), 1.0 * s, true)
				glow_dot(ci, c - facing * rr * 0.2, rr * 0.14, glow)
		"stalker":
			# Blink Stalker: a lean digitigrade biped with a blade-shaped head and a shimmering
			# teleport afterimage trailing behind it.
			var echo := fmod(t * 1.1, 1.0)
			var ghost := PackedVector2Array([Vector2(1.1, 0), Vector2(0.2, 0.45), Vector2(-0.7, 0.3), Vector2(-0.7, -0.3), Vector2(0.2, -0.45)])
			outline(ci, c - facing * rr * (0.6 + 1.2 * echo), ghost, Color(glow, 0.45 * (1.0 - echo)), 1.0 * s, ang, rr)
			for side in [-1.0, 1.0]:
				var ph := t * 12.0 + (PI if side > 0.0 else 0.0)
				var hip: Vector2 = c + n * side * rr * 0.3
				var knee: Vector2 = hip + n * side * rr * 0.45 + facing * rr * (0.45 + 0.25 * sin(ph))
				var foot: Vector2 = knee + n * side * rr * 0.1 - facing * rr * (0.55 - 0.3 * sin(ph))
				limb(ci, PackedVector2Array([hip, knee, foot]), 1.3 * s, METAL_L)
			plate(ci, c, ghost, body, ang, rr * 0.8, 1.1)
			strip(ci, c - facing * rr * 0.45, c + facing * rr * 0.55, 0.8 * s, glow)
			glow_dot(ci, c + facing * rr * 0.6, rr * 0.16, glow)
		"mender":
			# Mender Hulk: a hulking repair frame with a nanite core; green seams pulse as it mends.
			var pulse := 0.5 + 0.5 * sin(t * 4.0)
			for side in [-1.0, 1.0]:
				var sh: Vector2 = c + n * side * rr * 0.72 + facing * rr * 0.1
				var fist: Vector2 = sh + facing * rr * (0.55 + 0.1 * sin(t * 3.0 + side)) + n * side * rr * 0.15
				limb(ci, PackedVector2Array([sh, fist]), 3.0 * s, METAL_L)
				orb(ci, fist, rr * 0.2, METAL, s)
			shaded_oval(ci, c, rr * 0.85, rr * 0.75, ang, body, s)
			var plates := ngon(8, 1.0, PI / 8.0)
			outline(ci, c, plates, body.darkened(0.35), 1.4 * s, ang, rr * 0.6)
			for k in 4:
				var a := ang + PI / 4.0 + float(k) * PI / 2.0
				ci.draw_line(c + Vector2.from_angle(a) * rr * 0.25, c + Vector2.from_angle(a) * rr * 0.7, Color(glow, 0.35 + 0.5 * pulse), 1.2 * s, true)
			orb(ci, c, rr * 0.3, glow.darkened(0.45), s)
			glow_dot(ci, c, rr * (0.14 + 0.05 * pulse), glow)
		"rally":
			# Rally Beacon: a wheeled signal mast with a rotating siren and overdrive pulses.
			var ping := fmod(t * 1.4, 1.0)
			ci.draw_arc(c, rr * (1.1 + 1.6 * ping), 0.0, TAU, 24, Color(glow, 0.4 * (1.0 - ping)), 1.6 * s, true)
			for k in 4:
				var wp: Vector2 = c + Vector2.from_angle(ang + PI / 4.0 + float(k) * PI / 2.0) * rr * 0.72
				ci.draw_circle(wp, rr * 0.22, OUTLINE)
				ci.draw_circle(wp, rr * 0.16, METAL_D.lightened(0.15))
			var hexr := ngon(6, 1.0, 0.0)
			plate(ci, c, hexr, body, ang, rr * 0.62, 1.3)
			bar(ci, c, c - facing * rr * 0.1 + Vector2(0, -rr * 0.9), 1.6 * s, METAL_L)
			var top := c - facing * rr * 0.1 + Vector2(0, -rr * 0.9)
			orb(ci, top, rr * 0.22, METAL, s)
			var beam := Vector2.from_angle(t * 6.0)
			ci.draw_line(top, top + beam * rr * 0.9, Color(glow, 0.5), 2.0 * s, true)
			glow_dot(ci, top, rr * 0.16, glow)
		"bulwark":
			# Bulwark: a squat projector with three emitter prongs spinning barrier shards around it.
			for k in 3:
				var a := ang + TAU * float(k) / 3.0
				var pr: Vector2 = c + Vector2.from_angle(a) * rr * 0.85
				bar(ci, c, pr, 2.2 * s, METAL_L)
				orb(ci, pr, rr * 0.16, METAL, s)
				glow_dot(ci, pr, rr * 0.08, glow)
			orb(ci, c, rr * 0.62, body, s)
			ring(ci, c, rr * 0.4, body.darkened(0.35), 1.3 * s)
			glow_dot(ci, c, rr * 0.18, glow)
			var shard := ngon(6, 1.0, PI / 6.0)
			for k in 3:
				var a := t * 1.4 + TAU * float(k) / 3.0 + PI / 3.0
				var sp: Vector2 = c + Vector2.from_angle(a) * rr * 1.2
				fill(ci, sp, shard, Color(glow, 0.2), a, rr * 0.3)
				outline(ci, sp, shard, Color(glow, 0.8), 1.0 * s, a, rr * 0.3)
		"rampart":
			# Rampart: a siege fortress on wide treads: a crenellated bastion hull, a battering ram and
			# armor spikes. Nothing moves it off course.
			var roll := fmod(t * 14.0, 5.0)
			for side in [-1.0, 1.0]:
				var tread: Vector2 = c + n * side * rr * 0.82
				plate(ci, tread, rect_pts(1.05, 0.26), METAL_D.lightened(0.05), ang, rr, 1.3)
				for k in 5:
					var lp := tread + facing * (-rr * 0.95 + fmod(float(k) * rr * 0.42 + roll, rr * 2.0))
					ci.draw_line(lp - n * rr * 0.22, lp + n * rr * 0.22, METAL_L, 1.0 * s)
			var hullr := rect_pts(0.78, 0.66)
			plate(ci, c, hullr, body, ang, rr, 1.8)
			for cx in [-1.0, 1.0]:
				for cy in [-1.0, 1.0]:
					plate(ci, c + facing * cx * rr * 0.62 + n * cy * rr * 0.5, rect_pts(0.16, 0.16), body.lightened(0.12), ang, rr, 1.1)
			rivets(ci, c, hullr, ang, rr, 0.7, 0.7 * s)
			bar(ci, c + facing * rr * 0.7, c + facing * rr * 1.25, 4.0 * s, METAL_L)
			var ram := PackedVector2Array([Vector2(0.2, 0), Vector2(-0.05, 0.3), Vector2(-0.05, -0.3)])
			plate(ci, c + facing * rr * 1.2, ram, METAL_L.lightened(0.1), ang, rr, 1.0)
			orb(ci, c, rr * 0.28, body.darkened(0.2), s)
			glow_dot(ci, c, rr * 0.13, glow)
		"leviathan":
			# Leviathan: a colossal flying carrier: a long armored hull with swept fins, launch bays
			# that light up, a turning radar mast and a bank of engines.
			ellipse(ci, c + Vector2(0, rr * 1.6), rr * 1.5, rr * 0.45, Color(0, 0, 0, 0.25))
			for side in [-1.0, 1.0]:
				var fin := PackedVector2Array([Vector2(0.2, 0.3 * side), Vector2(-0.55, 1.15 * side), Vector2(-0.85, 1.05 * side), Vector2(-0.6, 0.3 * side)])
				plate(ci, c, fin, body.darkened(0.15), ang, rr, 1.4)
			var hulll := PackedVector2Array([Vector2(1.25, 0), Vector2(0.85, 0.36), Vector2(-0.95, 0.42), Vector2(-1.15, 0.2), Vector2(-1.15, -0.2), Vector2(-0.95, -0.42), Vector2(0.85, -0.36)])
			plate(ci, c, hulll, body, ang, rr, 2.0)
			rivets(ci, c, hulll, ang, rr, 0.8, 0.8 * s)
			for k in 3:
				var bay: Vector2 = c + facing * rr * (0.45 - 0.42 * float(k))
				var lit := fmod(t * 0.8 + float(k) * 0.33, 1.0) < 0.3
				plate(ci, bay, rect_pts(0.12, 0.22), glow if lit else METAL_D, ang, rr, 1.0)
			for side in [-1.0, 0.0, 1.0]:
				var eng: Vector2 = c - facing * rr * 1.15 + n * side * rr * 0.22
				glow_dot(ci, eng, rr * (0.08 + 0.02 * sin(t * 20.0 + side)), Color(0.4, 0.8, 1.0))
			var mast := c + facing * rr * 0.75
			orb(ci, mast, rr * 0.13, METAL_L, s)
			var dish := Vector2.from_angle(t * 2.2)
			ci.draw_line(mast - dish * rr * 0.2, mast + dish * rr * 0.2, METAL_L, 2.0 * s, true)
			glow_dot(ci, c + facing * rr * 1.1, rr * 0.07, glow)
		"colossus":
			# Colossus: a four-legged walking fortress with layered armor, a molten core and twin
			# shoulder cannons.
			for k in 4:
				var la := ang + PI / 4.0 + float(k) * PI / 2.0
				var ld := Vector2.from_angle(la)
				var step := sin(t * 2.5 + float(k) * PI / 2.0) * rr * 0.14
				var knee := c + ld * rr * 0.85 + facing * step
				var foot := knee + ld * rr * 0.35
				limb(ci, PackedVector2Array([c + ld * rr * 0.4, knee, foot]), 5.0 * s, METAL_L)
				orb(ci, knee, rr * 0.12, METAL, s)
				ellipse(ci, foot, rr * 0.16, rr * 0.1, METAL_D)
			var core := 0.5 + 0.5 * sin(t * 2.0)
			var hullc := ngon(8, 1.0, PI / 8.0)
			plate(ci, c, hullc, body, ang, rr * 0.72, 2.0)
			outline(ci, c, hullc, body.darkened(0.4), 2.0 * s, ang, rr * 0.52)
			rivets(ci, c, hullc, ang, rr * 0.72, 0.82, 0.9 * s)
			for side in [-1.0, 1.0]:
				var gun: Vector2 = c + n * side * rr * 0.5
				bar(ci, gun, gun + facing * rr * 0.95, 4.0 * s, METAL_L)
				orb(ci, gun, rr * 0.18, body.lightened(0.15), s)
			ci.draw_circle(c, rr * 0.36, OUTLINE)
			ci.draw_circle(c, rr * 0.3, Color(glow.darkened(0.5), 1.0))
			glow_dot(ci, c, rr * (0.18 + 0.04 * core), glow)
		_:
			ci.draw_circle(c, rr, body)
	if slowed and not hidden:
		ci.draw_circle(c, rr * 1.12, Color(0.55, 0.85, 1.0, 0.28))
		ring(ci, c, rr * 1.12, Color(0.7, 0.95, 1.0, 0.6), 1.0 * s)
	if flash > 0.0 and not hidden:
		ci.draw_circle(c, rr, Color(1, 1, 1, clampf(flash * 8.0, 0.0, 0.6)))


## Small status markers: armor shred, vulnerability, stun.
static func enemy_status(ci: CanvasItem, e, t: float) -> void:
	var r: float = e.radius
	if e.shield > 0.0 and e.max_shield > 0.0:
		var f: float = e.shield / e.max_shield
		var hex := ngon(6, 1.0, t * 0.6)
		fill(ci, e.pos, hex, Color(0.4, 0.7, 1.0, 0.07 + 0.08 * f), 0.0, r + 6.0)
		outline(ci, e.pos, hex, Color(0.55, 0.8, 1.0, 0.3 + 0.45 * f), 1.4, 0.0, r + 6.0)
	if e.armor_shred > 0.0 and e.armor > 0.0:
		var p: Vector2 = e.pos + Vector2(r * 0.7, -r * 0.7)
		ci.draw_line(p + Vector2(-3, -3), p + Vector2(3, 3), Color(1.0, 0.35, 0.35), 1.6, true)
		ci.draw_line(p + Vector2(-1, -4), p + Vector2(4, 1), Color(1.0, 0.35, 0.35), 1.6, true)
	if e.vuln_timer > 0.0:
		arc_segments(ci, e.pos, r + 4.0, 4, 0.9, t * 2.0, Color(0.85, 0.6, 1.0, 0.8), 1.4)
	if e.stun_timer > 0.0:
		for i in 3:
			var a := t * 9.0 + TAU * float(i) / 3.0
			ci.draw_circle(e.pos + Vector2(cos(a) * r * 0.9, -r - 4.0 + sin(a) * 2.0), 1.8, Color(1.0, 0.92, 0.3))
	# Silenced (suppressed or jammed): a struck-through ring over the head.
	if e.silenced():
		var sp: Vector2 = e.pos + Vector2(-r * 0.7, -r - 3.0)
		ci.draw_arc(sp, 3.2, 0.0, TAU, 12, Color(0.75, 0.55, 1.0, 0.9), 1.3, true)
		ci.draw_line(sp + Vector2(-2.3, 2.3), sp + Vector2(2.3, -2.3), Color(0.75, 0.55, 1.0, 0.9), 1.3, true)
	# Exposed (immunities stripped): a dashed white ring.
	if e.exposed():
		arc_segments(ci, e.pos, r + 7.0, 6, 0.5, -t * 1.5, Color(1, 1, 1, 0.55), 1.1)
	# Armor broken: a cracked plate.
	if e.armor_break_timer > 0.0 and e.armor > 0.0:
		var bp: Vector2 = e.pos + Vector2(-r * 0.75, r * 0.55)
		ci.draw_rect(Rect2(bp - Vector2(3, 3), Vector2(6, 6)), Color(0.55, 0.55, 0.6, 0.9))
		ci.draw_polyline(PackedVector2Array([bp + Vector2(-2, -3), bp + Vector2(0.5, -0.5), bp + Vector2(-1, 1), bp + Vector2(2, 3)]), Color(1.0, 0.45, 0.2), 1.1, true)
	# Burning: flickering flame tongues.
	if e.dot_timer > 0.0 and e.dot_dps > 0.0:
		for i in 3:
			var fx := (float(i) - 1.0) * r * 0.45
			var h := 4.0 + 2.0 * sin(t * 14.0 + float(i) * 2.0)
			var fb: Vector2 = e.pos + Vector2(fx, -r * 0.3)
			ci.draw_colored_polygon(PackedVector2Array([fb + Vector2(-1.8, 0), fb + Vector2(0, -h), fb + Vector2(1.8, 0)]), Color(1.0, 0.55, 0.15, 0.75))


# --- HUD glyphs ------------------------------------------------------------------------------

static func shield(ci: CanvasItem, c: Vector2, size: float, col: Color) -> void:
	var r := size
	var pts := PackedVector2Array([
		c + Vector2(-r * 0.85, -r * 0.8), c + Vector2(0, -r * 1.05), c + Vector2(r * 0.85, -r * 0.8),
		c + Vector2(r * 0.8, r * 0.1), c + Vector2(0, r * 1.05), c + Vector2(-r * 0.8, r * 0.1),
	])
	ci.draw_colored_polygon(pts, Color(col, 0.35))
	var closed := pts.duplicate()
	closed.append(pts[0])
	ci.draw_polyline(closed, col, 2.0, true)
	ci.draw_line(c + Vector2(0, -r * 0.6), c + Vector2(0, r * 0.6), col, 1.6, true)


static func coin(ci: CanvasItem, c: Vector2, r: float) -> void:
	var hex := ngon(6, 1.0, PI / 6.0)
	fill(ci, c, hex, OUTLINE, 0.0, r + 1.2)
	fill(ci, c, hex, Color(1.0, 0.72, 0.22), 0.0, r)
	outline(ci, c, hex, Color(0.6, 0.38, 0.08), 1.2, 0.0, r * 0.62)
	ci.draw_circle(c, r * 0.22, Color(1, 1, 0.85))


## Research-node glyphs for the Research Lab (see `icon` in data/research.gd).
static func research_glyph(ci: CanvasItem, icon: String, c: Vector2, r: float, col: Color, t := 0.0) -> void:
	var w := maxf(1.4, r * 0.16)
	match icon:
		"damage":
			for k in 2:
				var y := (0.25 - 0.55 * float(k)) * r
				ci.draw_polyline(PackedVector2Array([c + Vector2(-0.55 * r, y + 0.35 * r), c + Vector2(0, y - 0.1 * r), c + Vector2(0.55 * r, y + 0.35 * r)]), col, w, true)
		"range":
			ci.draw_circle(c + Vector2(-0.45 * r, 0.35 * r), w * 0.9, col)
			for k in 2:
				ci.draw_arc(c + Vector2(-0.45 * r, 0.35 * r), (0.45 + 0.42 * float(k)) * r, -PI / 2.0, 0.0, 10, col, w, true)
		"rate":
			for k in 2:
				var x := (-0.45 + 0.5 * float(k)) * r
				ci.draw_polyline(PackedVector2Array([c + Vector2(x, -0.5 * r), c + Vector2(x + 0.4 * r, 0), c + Vector2(x, 0.5 * r)]), col, w, true)
		"blast":
			ci.draw_circle(c, 0.28 * r, col)
			for k in 8:
				var d := Vector2.from_angle(TAU * float(k) / 8.0 + PI / 8.0)
				ci.draw_line(c + d * 0.45 * r, c + d * 0.8 * r, col, w * 0.8, true)
		"slow":
			for k in 3:
				var d := Vector2.from_angle(PI / 2.0 + PI * float(k) / 3.0) * 0.72 * r
				ci.draw_line(c - d, c + d, col, w, true)
			ci.draw_circle(c, w, col)
		"chain":
			ci.draw_polyline(PackedVector2Array([c + Vector2(-0.6, -0.55) * r, c + Vector2(0.05, -0.1) * r, c + Vector2(-0.15, 0.15) * r, c + Vector2(0.6, 0.6) * r]), col, w, true)
			ci.draw_circle(c + Vector2(-0.6, -0.55) * r, w * 1.1, col)
			ci.draw_circle(c + Vector2(0.6, 0.6) * r, w * 1.1, col)
		"credits":
			var hex := ngon(6, 1.0, PI / 6.0)
			outline(ci, c, hex, col, w, 0.0, 0.62 * r)
			ci.draw_line(c + Vector2(0, -0.32 * r), c + Vector2(0, 0.32 * r), col, w, true)
		"shield":
			shield(ci, c, 0.62 * r, col)
		"push":
			ci.draw_circle(c + Vector2(0.5 * r, 0), 0.22 * r, col)
			for k in 2:
				var x := (0.15 - 0.4 * float(k)) * r
				ci.draw_polyline(PackedVector2Array([c + Vector2(x + 0.25 * r, -0.5 * r), c + Vector2(x - 0.15 * r, 0), c + Vector2(x + 0.25 * r, 0.5 * r)]), col, w, true)
		"salvage":
			ci.draw_arc(c, 0.55 * r, -PI * 0.1, PI * 1.35, 16, col, w, true)
			var tip := c + Vector2.from_angle(-PI * 0.1) * 0.55 * r
			ci.draw_polyline(PackedVector2Array([tip + Vector2(-0.32, -0.12) * r, tip, tip + Vector2(0.08, -0.34) * r]), col, w, true)
		"uplink":
			ci.draw_arc(c + Vector2(0, 0.1 * r), 0.6 * r, PI * 1.15, PI * 1.85, 10, col, w, true)
			ci.draw_line(c + Vector2(0, 0.1 * r), c + Vector2(0, 0.65 * r), col, w, true)
			var pulse := fmod(t * 0.8, 1.0)
			ci.draw_arc(c + Vector2(0, -0.2 * r), (0.3 + 0.5 * pulse) * r, PI * 1.3, PI * 1.7, 8, Color(col, 1.0 - pulse), w * 0.7, true)
			ci.draw_circle(c + Vector2(0, -0.2 * r), w, col)
		"mastery":
			var pts := PackedVector2Array()
			for k in 8:
				var a := -PI / 2.0 + TAU * float(k) / 8.0
				pts.append(c + Vector2.from_angle(a) * (0.78 if k % 2 == 0 else 0.3) * r)
			ci.draw_colored_polygon(pts, Color(col, 0.35))
			var closed := pts.duplicate()
			closed.append(pts[0])
			ci.draw_polyline(closed, col, w * 0.8, true)
			ci.draw_circle(c, 0.14 * r, Color(1, 1, 1, 0.9))


## A skill-tree hex node (Research Lab and the upgrade tree). `state`:
## owned (gold), ready (pulsing accent), short (can't afford), locked, gone (branch not taken).
## Returns the colour to draw the node's glyph in.
static func skill_hex(ci: CanvasItem, c: Vector2, r: float, state: String, acc: Color, t: float, double := false) -> Color:
	var hex := ngon(6, 1.0, PI / 6.0)
	var fill_c := Color(0.05, 0.07, 0.1)
	var edge := Color(0.25, 0.32, 0.4)
	var glyph := Color(0.35, 0.42, 0.5)
	var edge_w := 1.5
	match state:
		"owned":
			fill_c = acc.darkened(0.62)
			edge = GOLD
			glyph = Color(1, 0.93, 0.7)
			edge_w = 2.4
		"ready":
			fill_c = Color(0.07, 0.11, 0.15)
			edge = Color(acc, 0.65 + 0.35 * sin(t * 4.0))
			glyph = acc
			edge_w = 2.2
		"short":
			fill_c = Color(0.06, 0.08, 0.11)
			edge = Color(acc, 0.45)
			glyph = Color(acc, 0.6)
		"gone":
			fill_c = Color(0.04, 0.05, 0.07)
			edge = Color(0.18, 0.23, 0.29)
			glyph = Color(0.25, 0.3, 0.36)
	if state == "owned" or state == "ready":
		ci.draw_circle(c, r * 1.25, Color(edge, 0.12))
	fill(ci, c, hex, OUTLINE, 0.0, r + 2.0)
	fill(ci, c, hex, fill_c, 0.0, r)
	outline(ci, c, hex, edge, edge_w, 0.0, r)
	if double:
		outline(ci, c, hex, Color(edge, 0.5), 1.0, 0.0, r - 4.0)
	return glyph


## Small padlock glyph.
static func lock(ci: CanvasItem, c: Vector2, s: float, col: Color) -> void:
	ci.draw_rect(Rect2(c + Vector2(-4, -1) * s, Vector2(8, 6.5) * s), col)
	ci.draw_arc(c + Vector2(0, -1) * s, 2.6 * s, PI, TAU, 8, col, 1.5 * s, true)


## Tier-4 mastery aura: a slow gold segmented ring around the tower pad.
static func mastery_ring(ci: CanvasItem, c: Vector2, s: float, acc: Color, t: float) -> void:
	arc_segments(ci, c, 23.0 * s, 6, 0.55, t * 0.7, Color(GOLD, 0.75), 1.6 * s)
	arc_segments(ci, c, 25.5 * s, 3, 1.4, -t * 1.1, Color(acc, 0.5), 1.2 * s)


static func heart(ci: CanvasItem, c: Vector2, size: float, col: Color) -> void:
	shield(ci, c, size, col)


static func star(ci: CanvasItem, c: Vector2, r: float, filled: bool) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI / 2.0 + TAU * float(i) / 10.0
		pts.append(c + Vector2(cos(a), sin(a)) * (r if i % 2 == 0 else r * 0.45))
	if filled:
		ci.draw_circle(c, r * 1.1, Color(GOLD, 0.15))
		ci.draw_colored_polygon(pts, GOLD)
	else:
		ci.draw_colored_polygon(pts, Color(0.12, 0.15, 0.2))
	var closed := pts.duplicate()
	closed.append(pts[0])
	ci.draw_polyline(closed, OUTLINE if filled else Color(0.3, 0.42, 0.52), 1.5, true)


static func stars(ci: CanvasItem, c: Vector2, r: float, count: int, total := 3) -> void:
	for i in total:
		star(ci, c + Vector2((float(i) - float(total - 1) / 2.0) * r * 2.3, 0), r, i < count)


## A sector medal for a difficulty mode: ribbon tails in the mode's colour, a gold-rimmed disc and
## one chevron per mode tier (Easy 1 ... Cataclysm 5). Unearned medals are a dim grey outline.
static func medal(ci: CanvasItem, c: Vector2, r: float, mode: String, earned: bool, t := 0.0) -> void:
	var tier := maxi(1, Difficulty.ORDER.find(mode) + 1)
	var col: Color = Difficulty.DIFFICULTIES.get(mode, Difficulty.DIFFICULTIES.medium).color
	if not earned:
		col = Color(0.26, 0.31, 0.37)
	var tail := col.darkened(0.3) if earned else Color(0.2, 0.24, 0.29)
	for s in [-1.0, 1.0]:
		ci.draw_colored_polygon(PackedVector2Array([
			c + Vector2(s * r * 0.1, r * 0.2), c + Vector2(s * r * 0.72, r * 0.35),
			c + Vector2(s * r * 0.62, r * 1.35), c + Vector2(s * r * 0.38, r * 1.08), c + Vector2(s * r * 0.08, r * 1.3),
		]), tail)
	var rim := Color(1.0, 0.8, 0.35) if earned else Color(0.33, 0.38, 0.44)
	ci.draw_circle(c, r, OUTLINE)
	ci.draw_circle(c, r * 0.92, rim.darkened(0.35))
	ci.draw_circle(c, r * 0.8, rim)
	ci.draw_circle(c, r * 0.66, col.darkened(0.15) if earned else Color(0.11, 0.14, 0.18))
	var mark := Color(1, 1, 1, 0.95) if earned else Color(0.38, 0.44, 0.5)
	var w := r * 0.36
	for i in tier:
		var y := (float(i) - float(tier - 1) / 2.0) * r * 0.22
		ci.draw_polyline(PackedVector2Array([c + Vector2(-w, y + r * 0.09), c + Vector2(0, y - r * 0.09), c + Vector2(w, y + r * 0.09)]), mark, maxf(1.3, r * 0.09), true)
	if earned:
		ci.draw_arc(c, r * 0.72, -2.5 + 0.15 * sin(t * 2.0), -1.3 + 0.15 * sin(t * 2.0), 10, Color(1, 1, 1, 0.5), maxf(1.0, r * 0.07), true)



static func ability_icon(ci: CanvasItem, id: String, c: Vector2, r: float, t: float) -> void:
	match id:
		"meteor":
			var col := Color(1.0, 0.45, 0.2)
			ci.draw_line(c + Vector2(0, -r * 1.2), c + Vector2(0, r * 0.3), Color(col, 0.4), r * 0.55, true)
			ci.draw_line(c + Vector2(0, -r * 1.2), c + Vector2(0, r * 0.3), Color(1, 0.85, 0.6), r * 0.18, true)
			ring(ci, c + Vector2(0, r * 0.35), r * 0.55 + sin(t * 6.0) * 1.5, col, 2.0)
			ci.draw_line(c + Vector2(-r * 0.8, r * 0.35), c + Vector2(-r * 0.35, r * 0.35), col, 1.6, true)
			ci.draw_line(c + Vector2(r * 0.35, r * 0.35), c + Vector2(r * 0.8, r * 0.35), col, 1.6, true)
		"warp":
			ci.draw_circle(c, r * 0.95, Color(0.45, 0.35, 1.0, 0.25 + 0.1 * sin(t * 3.0)))
			ci.draw_arc(c, r * 0.8, 0.0, TAU, 32, Color(0.75, 0.68, 1.0), 2.5, true)
			ci.draw_line(c, c + Vector2.from_angle(t * 0.8 - PI / 2.0) * r * 0.6, Color(1, 1, 1), 2.5, true)
			ci.draw_line(c, c + Vector2.from_angle(t * 0.1 - PI / 2.0) * r * 0.4, Color(1, 1, 1), 3.0, true)
			for i in 12:
				var a := TAU * float(i) / 12.0
				ci.draw_circle(c + Vector2.from_angle(a) * r * 0.8, 1.4, Color(0.9, 0.85, 1.0))
