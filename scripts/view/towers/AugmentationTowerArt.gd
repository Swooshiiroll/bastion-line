extends RefCounted
## Augmentation Tower art (tower rework, issue #59): a port of the confirmed second-pass page
## (design/tower_art_p2_20_augment.html, tools/tower_art/data_p2_augment.js) with the owner's picks hard-coded (every step the first option).
##
## `look` is the tower's look key "r|a|b|c": the Retrofit (-1 none, 0 wide aura, 1 amplified bonus, 2 remote link) and the depth of each path,
## 5 on the path that took its mastery. a = Energy Conversion (blue), b = Critical Hits (red, gold core), c = Ricochet (green). A hex-celled dome:
## at stock some cells flicker lavender; each path recolours flickering cells in its colour, more of the array each tier, a mastery fills it solid;
## deflector plates orbit the dome, one ring per path. The tower never turns; the cells, the orbit and the nanites are live.

const Draw = preload("res://scripts/view/Draw.gd")

const GOLD := Color(1.0, 0.78, 0.30)
const ENC := Color(0.32, 0.62, 1.0)
const CRITC := Color(1.0, 0.25, 0.22)
const RICOC := Color(0.40, 1.0, 0.50)
const COPPER := Color(0.78, 0.50, 0.28)
const FILL := [0.0, 0.15, 0.30, 0.45, 0.60, 1.0]


static func levels(look: String) -> Dictionary:
	var p := look.split("|")
	if p.size() < 4:
		return {"r": -1, "E": 0, "C": 0, "R": 0}
	return {"r": int(p[0]), "E": int(p[1]), "C": int(p[2]), "R": int(p[3])}


static func rnd(x: float) -> float:
	var v := sin(x * 12.9898) * 43758.5453
	return v - floor(v)


## The dome's hex cells inside radius `r`, nearest the centre first (positions in px at scale 1).
static func hex_cells(r: float, size: float) -> Array:
	var out: Array = []
	var step := size * 2.0
	for q in range(-5, 6):
		for rr in range(-5, 6):
			var x := (float(q) + float(rr) * 0.5) * step
			var y := float(rr) * step * 0.866
			if x * x + y * y > pow(r - size * 0.8, 2.0):
				continue
			out.append(Vector2(x, y))
	out.sort_custom(func(a, b): return a.length_squared() < b.length_squared())
	return out


static func draw(ci: CanvasItem, c: Vector2, _aim: float, s: float, t: float, _flash: float, look: String, acc: Color, _extra: Array) -> void:
	var L := levels(look)
	var k := s
	var col := acc
	var dome_r := 12.0 + 0.25 * float(L.E)
	var cells := hex_cells(dome_r, 2.2)
	var hexp := Draw.ngon(6, 1.0, PI / 6.0)
	var ge: bool = L.E >= 5
	# --- Cached: the Retrofit's parts, the dome and its cell outlines, the crit core. ---
	if L.r == 0:
		Draw.ring(ci, c, 18.6 * k, Color(col, 0.55), 1.0 * k)
		for i in 6:
			Draw.disc(ci, c + Vector2.from_angle(float(i) * PI / 3.0) * 18.6 * k, 0.5 * k, Color(col, 0.8))
	Draw.orb(ci, c, dome_r * k, Draw.METAL_L, k)
	for p in cells:
		Draw.outline(ci, c + p * k, hexp, Color(Draw.METAL, 0.7), 0.8 * k, 0.0, 2.2 * k)
	if ge:
		Draw.ring(ci, c, dome_r * k, GOLD, 1.4 * k)
	if L.C > 0:
		# The crit core: a targeting lens in gold, bigger each step, a precision ring from Precision Matrix.
		var r := 2.2 + 0.45 * float(L.C)
		var gc: bool = L.C >= 5
		Draw.disc(ci, c, (r + 0.9) * k, Draw.OUTLINE)
		Draw.disc(ci, c, (r + 0.2) * k, GOLD if gc else Draw.METAL_D)
		Draw.disc(ci, c, r * 0.75 * k, Color(GOLD.lightened(0.25), 0.9))
		for i in 4:
			var a := float(i) * PI / 2.0
			Draw.line(ci, c + Vector2.from_angle(a) * r * 0.35 * k, c + Vector2.from_angle(a) * r * 0.8 * k, Color(Draw.OUTLINE, 0.7), 0.6 * k)
	if L.r == 2:
		var q := c + Vector2(0, 15.5) * k
		Draw.plate(ci, q, Draw.rect_pts(1.8, 1.2), Draw.METAL_D, 0.0, k, 1.0)
	# --- Live: the cell lights, the orbiting deflectors, the nanites, the halo. ---
	Draw.dyn(true)
	var bk := floorf(t * 8.0)
	var n := cells.size()
	if L.E == 0 and L.C == 0 and L.R == 0:
		for p in cells:
			if rnd(roundf(p.x * 7.0 + p.y * 13.0) + floorf(t * 3.0)) > 0.75:
				Draw.outline(ci, c + p * k, hexp, Color(col, 0.95), 0.8 * k, 0.0, 2.2 * k)
	else:
		var layer: Array = []
		layer.resize(n)
		layer.fill(0)
		var paths: Array = []
		if L.E > 0:
			paths.append({"L": L.E, "col": ENC, "kind": 0})
		if L.C > 0:
			paths.append({"L": L.C, "col": CRITC, "kind": 1})
		if L.R > 0:
			paths.append({"L": L.R, "col": RICOC, "kind": 2})
		paths.sort_custom(func(a, b): return a.L > b.L)
		for pa in paths:
			var f: float = FILL[pa.L]
			var solid: bool = pa.L >= 5
			var pc: Color = pa.col
			for i in n:
				if not solid:
					var pick := false
					match int(pa.kind):
						0:
							var reg := maxi(1, int(ceil(f * float(n) * 1.6)))
							pick = i < reg and rnd(float(i) * 7.31 + bk) < f * float(n) / float(reg)
						1:
							pick = rnd(float(i) * 3.1 + bk * 1.7 + 50.0) < f
						_:
							pick = rnd(float(i) * 5.7 + bk * 2.3 + 99.0) < f
					if not pick:
						continue
				var cp: Vector2 = cells[i]
				if int(layer[i]) == 0:
					Draw.fill(ci, c + cp * k, hexp, Color(pc, 0.8 if solid else 0.85), 0.0, 2.0 * k)
					Draw.outline(ci, c + cp * k, hexp, pc.lightened(0.45 if solid else 0.35), 0.9 * k, 0.0, 2.2 * k)
				else:
					Draw.fill(ci, c + cp * k, hexp, Color(pc, 0.95), 0.0, 1.15 * k)
				layer[i] = int(layer[i]) + 1
	# The deflectors: one ring of orbiting plates per path, in its colour, more of them each step.
	var rings: Array = []
	for pr in [[L.E, ENC], [L.C, CRITC], [L.R, RICOC]]:
		if int(pr[0]) > 0:
			rings.append(pr)
	for i in rings.size():
		var lv: int = rings[i][0]
		var pc2: Color = rings[i][1]
		var cnt: int = [0, 2, 3, 4, 5, 6][lv]
		var rr: float = 14.4 + float(i) * 1.9 + (1.0 if rings.size() == 1 else 0.0)
		var sp := (-1.0 if i % 2 == 1 else 1.0) * t * (0.6 + 0.1 * float(lv))
		var trim: Color = GOLD if lv >= 5 else pc2.lightened(0.3)
		for j in cnt:
			var a2 := sp + float(j) * TAU / float(cnt)
			var rad := rr + (sin(t * 5.0 + float(j)) * 0.6 if lv >= 5 else 0.0)
			Draw.arc(ci, c, rad * k, a2 - 0.3, a2 + 0.3, 6, Draw.OUTLINE, 3.0 * k)
			Draw.arc(ci, c, rad * k, a2 - 0.3, a2 + 0.3, 6, Draw.METAL.lerp(pc2, 0.55), 2.0 * k)
			Draw.arc(ci, c, (rad - 0.55) * k, a2 - 0.26, a2 + 0.26, 6, trim, 0.6 * k)
	if ge:
		for i in 2:
			var ia: Vector2 = cells[int(rnd(floorf(t * 8.0) + float(i)) * float(n)) % n]
			var ib: Vector2 = cells[int(rnd(floorf(t * 8.0) + float(i) + 9.0) * float(n)) % n]
			var pa2: Vector2 = c + ia * k
			var pb2: Vector2 = c + ib * k
			var pts := PackedVector2Array([pa2])
			for j in range(1, 5):
				pts.append(pa2.lerp(pb2, float(j) / 5.0) + (pb2 - pa2).normalized().orthogonal() * (rnd(float(j) + float(i) * 7.0 + floorf(t * 14.0)) - 0.5) * 2.4 * k)
			pts.append(pb2)
			Draw.polyline(ci, pts, Color(ENC.lightened(0.4) if i == 1 else ENC, 0.9), 0.8 * k)
	for i in 6:
		Draw.glow_dot(ci, c + Vector2.from_angle(t * 1.5 + float(i)) * (6.0 + 6.0 * fmod(t * 0.5 + float(i) / 6.0, 1.0)) * k, 0.5 * k, col)
	if L.r == 1:
		for i in 8:
			var ha := t * 0.5 + float(i) * TAU / 8.0
			Draw.arc(ci, c, 9.4 * k, ha, ha + 0.3, 5, GOLD, 0.9 * k)
	if L.C > 0:
		Draw.glow_dot(ci, c, (0.6 + 0.25 * float(L.C)) * k, GOLD)
	if L.r == 2:
		Draw.glow_dot(ci, c + Vector2(0, 15.1) * k, 0.8 * k, Color(RICOC, 1.0 if fmod(t * 1.5, 1.0) < 0.3 else 0.35))
	Draw.dyn(false)
