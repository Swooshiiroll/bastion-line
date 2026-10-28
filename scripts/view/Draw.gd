extends RefCounted
## Procedural sci-fi vector art for towers, enemies and HUD glyphs. Every function draws onto the
## CanvasItem passed in, so the same art serves the battlefield and the UI icons.

const Towers = preload("res://data/towers.gd")
const GunTurretArt = preload("res://scripts/view/towers/GunTurretArt.gd")
const MortarTowerArt = preload("res://scripts/view/towers/MortarTowerArt.gd")
const RocketSalvoArt = preload("res://scripts/view/towers/RocketSalvoArt.gd")
const LaserTowerArt = preload("res://scripts/view/towers/LaserTowerArt.gd")
const AntiAircraftArt = preload("res://scripts/view/towers/AntiAircraftArt.gd")
const ArtilleryCannonArt = preload("res://scripts/view/towers/ArtilleryCannonArt.gd")
const RailgunArt = preload("res://scripts/view/towers/RailgunArt.gd")
const TeslaTowerArt = preload("res://scripts/view/towers/TeslaTowerArt.gd")
const DroneBayArt = preload("res://scripts/view/towers/DroneBayArt.gd")
const CasGunshipArt = preload("res://scripts/view/towers/CasGunshipArt.gd")
const MineLayerArt = preload("res://scripts/view/towers/MineLayerArt.gd")
const ChemicalPlantArt = preload("res://scripts/view/towers/ChemicalPlantArt.gd")
const CryoTowerArt = preload("res://scripts/view/towers/CryoTowerArt.gd")
const BoostTowerArt = preload("res://scripts/view/towers/BoostTowerArt.gd")
const RadarTowerArt = preload("res://scripts/view/towers/RadarTowerArt.gd")
const ShockwaveGeneratorArt = preload("res://scripts/view/towers/ShockwaveGeneratorArt.gd")
const ScrapyardArt = preload("res://scripts/view/towers/ScrapyardArt.gd")
const MagnetoTowerArt = preload("res://scripts/view/towers/MagnetoTowerArt.gd")
const TractorTowerArt = preload("res://scripts/view/towers/TractorTowerArt.gd")
const AugmentationTowerArt = preload("res://scripts/view/towers/AugmentationTowerArt.gd")
const Difficulty = preload("res://data/difficulty.gd")
const EnemyArt = preload("res://scripts/view/enemies/EnemyArt.gd")

const OUTLINE := Color(0.03, 0.04, 0.06, 0.95)
const METAL_D := Color(0.10, 0.115, 0.14)
const METAL := Color(0.18, 0.20, 0.24)
const METAL_L := Color(0.30, 0.33, 0.38)
const GOLD := Color(1.0, 0.78, 0.30)
const CYAN := Color(0.30, 0.88, 1.0)

## Main accent per tower.
const ACCENT := {
	"gun_turret": Color(0.30, 0.90, 1.00),
	"mortar_tower": Color(1.00, 0.55, 0.20),
	"rocket_salvo": Color(1.00, 0.85, 0.30),
	"laser_tower": Color(1.00, 0.30, 0.35),
	"anti_aircraft_turret": Color(0.85, 1.00, 0.45),
	"artillery_cannon": Color(1.00, 0.55, 0.20),
	"railgun": Color(0.45, 0.80, 1.00),
	"tesla_tower": Color(0.75, 0.50, 1.00),
	"drone_bay": Color(0.62, 0.91, 0.44),
	"cas_gunship": Color(0.62, 0.85, 1.00),
	"mine_layer": Color(1.00, 0.35, 0.40),
	"chemical_plant": Color(0.55, 1.00, 0.30),
	"cryo_tower": Color(0.55, 0.85, 1.00),
	"boost_tower": Color(1.00, 0.40, 0.85),
	"radar_tower": Color(0.35, 1.00, 0.85),
	"shockwave_generator": Color(1.00, 0.70, 0.28),
	"scrapyard": Color(0.95, 0.72, 0.42),
	"magneto_tower": Color(0.60, 0.45, 1.00),
	"tractor_tower": Color(0.78, 0.71, 1.00),
	"augmentation_tower": Color(0.32, 0.62, 1.00),
}

## Each enemy's hull colour and the glow of its lights, from its confirmed art (design/enemy_art.md).
const ENEMY_BODY := {
	"grunt": Color(0.30, 0.38, 0.52),
	"runner": Color(0.78, 0.72, 0.58),
	"brute": Color(0.86, 0.68, 0.16),
	"swarmling": Color(0.68, 0.48, 0.32),
	"bat": Color(0.24, 0.48, 0.48),
	"shaman": Color(0.45, 0.80, 0.60),
	"phantom": Color(0.32, 0.46, 0.47),
	"aegis": Color(0.90, 0.86, 0.74),
	"hydra": Color(0.55, 0.22, 0.18),
	"jammer": Color(0.15, 0.16, 0.18),
	"juggernaut": Color(0.26, 0.27, 0.30),
	"warlord": Color(0.55, 0.38, 0.26),
	"locust": Color(0.44, 0.50, 0.26),
	"gunship": Color(0.22, 0.27, 0.42),
	"burrower": Color(0.45, 0.32, 0.20),
	"stalker": Color(0.24, 0.25, 0.28),
	"mender": Color(0.10, 0.40, 0.31),
	"rally": Color(0.50, 0.32, 0.74),
	"bulwark": Color(0.88, 0.85, 0.76),
	"rampart": Color(0.58, 0.58, 0.55),
	"leviathan": Color(0.30, 0.36, 0.22),
	"colossus": Color(0.86, 0.68, 0.16),
	"needle": Color(0.90, 0.93, 0.96),
	"fury": Color(0.20, 0.12, 0.14),
	"shrike": Color(0.90, 0.90, 0.92),
	"titan": Color(0.70, 0.50, 0.27),
	"siphon": Color(0.22, 0.18, 0.44),
	"blackout": Color(0.38, 0.40, 0.44),
	"capacitor": Color(0.88, 0.88, 0.84),
	"shifter": Color(0.72, 0.75, 0.79),
	"wraith": Color(0.14, 0.13, 0.18),
	"masquerade": Color(0.42, 0.20, 0.40),
	"decoy": Color(0.33, 0.35, 0.37),
	"mirage": Color(0.80, 0.82, 0.87),
}
const ENEMY_COLOR := {
	"grunt": Color(0.95, 0.97, 1.00),
	"runner": Color(1.00, 0.60, 0.30),
	"brute": Color(1.00, 0.45, 0.15),
	"swarmling": Color(1.00, 0.72, 0.25),
	"bat": Color(1.00, 0.70, 0.35),
	"shaman": Color(0.35, 1.00, 0.55),
	"phantom": Color(0.55, 1.00, 0.92),
	"aegis": Color(1.00, 0.78, 0.35),
	"hydra": Color(1.00, 0.55, 0.30),
	"jammer": Color(0.35, 0.65, 1.00),
	"juggernaut": Color(1.00, 0.25, 0.20),
	"warlord": Color(1.00, 0.72, 0.25),
	"locust": Color(1.00, 0.92, 0.30),
	"gunship": Color(1.00, 0.25, 0.20),
	"burrower": Color(1.00, 0.72, 0.25),
	"stalker": Color(1.00, 0.50, 0.15),
	"mender": Color(0.40, 1.00, 0.62),
	"rally": Color(1.00, 0.82, 0.30),
	"bulwark": Color(0.55, 0.80, 1.00),
	"rampart": Color(1.00, 0.70, 0.20),
	"leviathan": Color(1.00, 0.92, 0.30),
	"colossus": Color(1.00, 0.45, 0.15),
	"needle": Color(0.50, 0.75, 1.00),
	"fury": Color(1.00, 0.25, 0.75),
	"shrike": Color(0.35, 0.95, 1.00),
	"titan": Color(0.35, 0.95, 1.00),
	"siphon": Color(0.72, 1.00, 0.25),
	"blackout": Color(0.72, 0.42, 1.00),
	"capacitor": Color(1.00, 0.95, 0.60),
	"shifter": Color(0.30, 0.95, 0.85),
	"wraith": Color(0.85, 0.82, 1.00),
	"masquerade": Color(0.85, 0.50, 1.00),
	"decoy": Color(1.00, 0.30, 0.70),
	"mirage": Color(0.40, 0.95, 1.00),
}


static func accent(type: String, _spec := "") -> Color:
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
	if _skip and not _drawing():
		return
	poly(ci, xform(center, pts, rot, s), color)


# --- Fast shapes -------------------------------------------------------------------------------
# In the Compatibility renderer, draw_circle, draw_arc and draw_colored_polygon each allocate GPU
# buffers as they're recorded (12-30 µs apiece), and the battlefield records thousands of them a
# frame. These draw the same shapes from cached disc and ring textures, quad primitives and line
# segments instead (0.5-2 µs). Use them for anything drawn every frame.

const _TEX_SIZES := [8, 16, 32, 64, 128, 256]
static var _discs := {}
static var _rings := {}
static var _glows := {}
## Slow draw calls made through the fallbacks below (non-convex polygons, long polylines);
## tools/PerfProbe.gd reads and resets it to keep them on a budget.
static var slow_calls := 0
## Ring stroke widths (in texels) that get their own texture; others snap to the nearest, so a
## pulsing or growing ring reuses a few textures instead of making a new one every frame.
const _RING_TEXELS := [2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96, 127]


## Texture size for a shape of radius `r`, with room for up to 3x screen scale (zoom and stretch).
static func _tex_size(r: float) -> int:
	for size in _TEX_SIZES:
		if float(size) >= r * 6.0:
			return size
	return _TEX_SIZES[-1]


## A white disc, or a ring `width` texels wide, filling a size×size texture with 1-texel soft edges.
## Solid runs are filled a row span at a time; only edge texels are computed one by one.
static func _shape_texture(size: int, width := 0) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_LA8)
	var half := float(size) * 0.5
	var outer := half - 1.0
	var inner := outer - float(width) if width > 0 else -1.0
	var white := Color(1, 1, 1, 1)
	for y in size:
		var dy := float(y) + 0.5 - half
		if absf(dy) > outer + 0.5:
			continue
		var xo := sqrt(maxf(0.0, (outer + 0.5) * (outer + 0.5) - dy * dy))
		var x0 := maxi(0, floori(half - xo) - 1)
		var x1 := mini(size - 1, ceili(half + xo))
		# Opaque spans: inside outer - 0.5 and (for rings) outside inner + 0.5.
		var so := sqrt(maxf(0.0, (outer - 0.5) * (outer - 0.5) - dy * dy)) if absf(dy) < outer - 0.5 else -1.0
		var si := sqrt(maxf(0.0, (inner + 0.5) * (inner + 0.5) - dy * dy)) if inner >= 0.0 and absf(dy) < inner + 0.5 else -1.0
		for x in range(x0, x1 + 1):
			var dx := float(x) + 0.5 - half
			var ax := absf(dx)
			if so >= 0.0 and ax < so - 1.0 and (si < 0.0 or ax > si + 1.0):
				img.set_pixel(x, y, white)
				continue
			var d := sqrt(dx * dx + dy * dy)
			var al := clampf(outer - d + 0.5, 0.0, 1.0)
			if inner >= 0.0:
				al = minf(al, clampf(d - inner + 0.5, 0.0, 1.0))
			if al > 0.0:
				img.set_pixel(x, y, Color(1, 1, 1, al))
	return ImageTexture.create_from_image(img)


## The coloured layers of glow_dot in white: three nested discs (radii 1, 1.4/2.2 and 1/2.2 of
## the texture's) at alpha 0.18, 0.35 and 1, composited, with 1-texel soft edges.
static func _glow_texture(size: int) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_LA8)
	var half := float(size) * 0.5
	var outer := half - 1.0
	for y in size:
		for x in size:
			var d := Vector2(float(x) + 0.5 - half, float(y) + 0.5 - half).length()
			var keep := 1.0
			for layer in [[1.0, 0.18], [1.4 / 2.2, 0.35], [1.0 / 2.2, 1.0]]:
				var cover := clampf(outer * float(layer[0]) - d + 0.5, 0.0, 1.0)
				keep *= 1.0 - cover * float(layer[1])
			if keep < 1.0:
				img.set_pixel(x, y, Color(1, 1, 1, 1.0 - keep))
	return ImageTexture.create_from_image(img)


## Artwork whose only animation is turning (a saw, a snowflake): `painter` draws it once about
## (0, 0) within ±`half`; after that it's stamped rotated by `rot` about `c`. `key` must
## identify everything the painter depends on.
static func spinning(ci: CanvasItem, key: String, c: Vector2, half: Vector2, rot: float, painter: Callable) -> void:
	if _skip and not _drawing():
		return
	var tex: Texture2D = _sprites.get(key)
	if tex == null and not _sprites.has(key):
		tex = _bake_sprite(half, painter)
		_sprites[key] = tex
	if tex == null:
		ci.draw_set_transform(c, rot, Vector2.ONE)
		painter.call(ci, Vector2.ZERO)
		ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	_stamp_rotated(ci, tex, c, half, rot, Color(1, 1, 1))


## Stamps a cached sprite rotated by `rot` about `c`.
static func _stamp_rotated(ci: CanvasItem, tex: Texture2D, c: Vector2, half: Vector2, rot: float, tint: Color) -> void:
	ci.draw_set_transform(c, rot, Vector2.ONE)
	ci.draw_texture_rect(tex, Rect2(-half, half * 2.0), false, tint)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## --- Sprite cache: static artwork drawn once into a texture and stamped after that. ------------
## Cached at 3x so it stays sharp at full zoom on a stretched window. The first frame a key is
## used the texture is still empty (the viewport renders at the end of that frame).
const SPRITE_SCALE := 3.0
const DrawNode = preload("res://scripts/view/DrawNode.gd")
static var _sprites := {}
static var _sprite_host: Node = null


## Stamps the artwork `painter` draws around (0, 0) within ±`half`, centred on `c`, tinted by
## `tint`. `key` must identify everything the painter depends on.
static func cached(ci: CanvasItem, key: String, c: Vector2, half: Vector2, painter: Callable, tint := Color(1, 1, 1)) -> void:
	var tex: Texture2D = _sprites.get(key)
	if tex == null:
		tex = _bake_sprite(half, painter)
		if tex == null:
			painter.call(ci, c)
			return
		_sprites[key] = tex
	ci.draw_texture_rect(tex, Rect2(c - half, half * 2.0), false, tint)


static func _bake_sprite(half: Vector2, painter: Callable, scale := SPRITE_SCALE) -> Texture2D:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return null
	if _sprite_host == null or not is_instance_valid(_sprite_host):
		_sprite_host = Node.new()
		_sprite_host.name = "SpriteCache"
		tree.root.add_child.call_deferred(_sprite_host)
	var view := SubViewport.new()
	view.size = Vector2i((half * 2.0 * scale).ceil())
	view.transparent_bg = true
	view.disable_3d = true
	view.render_target_update_mode = SubViewport.UPDATE_ONCE
	var node := DrawNode.new()
	node.draw_fn = func(n: CanvasItem): painter.call(n, Vector2.ZERO)
	view.add_child(node)
	_sprite_host.add_child.call_deferred(view)
	# Only once the viewport is in the tree does it have a canvas to transform.
	view.set_deferred("canvas_transform", Transform2D(0.0, Vector2(scale, scale), 0.0, half * scale))
	return view.get_texture()


## Draws a size-`size` shape texture so its outer edge lands on radius (rx, ry) around `c`.
static func _stamp(ci: CanvasItem, tex: Texture2D, size: int, c: Vector2, rx: float, ry: float, color: Color) -> void:
	if _skip and not _drawing():
		return
	var k := float(size) * 0.5 / (float(size) * 0.5 - 1.0)
	ci.draw_texture_rect(tex, Rect2(c.x - rx * k, c.y - ry * k, rx * k * 2.0, ry * k * 2.0), false, color)


## draw_circle, fast. Unfilled circles draw as a ring.
static func disc(ci: CanvasItem, c: Vector2, r: float, color: Color, filled := true, width := -1.0, _aa := false) -> void:
	if _skip and not _drawing():
		return
	if r <= 0.0:
		return
	if not filled:
		ring(ci, c, r, color, width if width > 0.0 else 1.0)
		return
	var size := 8 if r <= 1.33 else 16 if r <= 2.66 else 32 if r <= 5.33 else 64 if r <= 10.66 else 128 if r <= 21.33 else 256
	var tex: Texture2D = _discs.get(size)
	if tex == null:
		tex = _shape_texture(size)
		_discs[size] = tex
	var k := r * float(size) / (float(size) - 2.0)
	ci.draw_texture_rect(tex, Rect2(c.x - k, c.y - k, k * 2.0, k * 2.0), false, color)


## A full ring of radius `r` (to the middle of its stroke), `width` wide. Rings too thin for the
## texture fall back to a line loop.
static func ring(ci: CanvasItem, center: Vector2, r: float, color: Color, width := 1.5) -> void:
	if _skip and not _drawing():
		return
	var w := maxf(width, 1.0)
	var outer := r + w * 0.5
	var size := _tex_size(outer)
	var want := w / outer * (float(size) * 0.5 - 1.0)
	if want < 1.5:
		arc(ci, center, r, 0.0, TAU, 32, color, width, true, true)
		return
	var texels: int = _RING_TEXELS[-1]
	for q in _RING_TEXELS:
		if float(q) >= want * 0.92:
			texels = q
			break
	var key := size * 1000 + texels
	if not _rings.has(key):
		_rings[key] = _shape_texture(size, texels)
	_stamp(ci, _rings[key], size, center, outer, outer, color)


## draw_arc, fast: full circles become rings, partial arcs a few antialiased line segments.
static func arc(ci: CanvasItem, c: Vector2, r: float, a0: float, a1: float, points: int, color: Color, width := -1.0, aa := false, as_lines := false) -> void:
	if _skip and not _drawing():
		return
	var span := a1 - a0
	if absf(span) >= TAU - 0.001 and not as_lines:
		ring(ci, c, r, color, width if width > 0.0 else 1.0)
		return
	var n := clampi(ceili(absf(span) * r / 6.0), 1, maxi(points - 1, 1))
	var prev := c + Vector2(cos(a0), sin(a0)) * r
	for i in range(1, n + 1):
		var a := a0 + span * float(i) / float(n)
		var p := c + Vector2(cos(a), sin(a)) * r
		ci.draw_line(prev, p, color, width, aa)
		prev = p


## draw_colored_polygon, fast for convex shapes (drawn as quads); others fall back to the polygon.
static func poly(ci: CanvasItem, pts: PackedVector2Array, color: Color) -> void:
	if _skip and not _drawing():
		return
	var n := pts.size()
	if n < 3:
		return
	var turn := 0.0
	for i in n:
		var a := pts[i]
		var b := pts[(i + 1) % n]
		var d := pts[(i + 2) % n]
		var cr := (b - a).cross(d - b)
		if absf(cr) < 1e-6:
			continue
		if turn == 0.0:
			turn = signf(cr)
		elif signf(cr) != turn:
			slow_calls += 1
			ci.draw_colored_polygon(pts, color)  # raw-draw-ok: non-convex fallback
			return
	var cols := PackedColorArray([color])
	var none := PackedVector2Array()
	var i := 1
	while i < n - 1:
		if i + 2 < n:
			ci.draw_primitive(PackedVector2Array([pts[0], pts[i], pts[i + 1], pts[i + 2]]), cols, none)
			i += 2
		else:
			ci.draw_primitive(PackedVector2Array([pts[0], pts[i], pts[i + 1]]), cols, none)
			i += 1


## draw_polyline, fast for short lines (separate segments); long ones stay one polyline.
static func polyline(ci: CanvasItem, pts: PackedVector2Array, color: Color, width := -1.0, aa := false) -> void:
	if _skip and not _drawing():
		return
	if pts.size() > 9:
		slow_calls += 1
		ci.draw_polyline(pts, color, width, aa)  # raw-draw-ok: long-line fallback
		return
	for k in pts.size() - 1:
		ci.draw_line(pts[k], pts[k + 1], color, width, aa)


static func line(ci: CanvasItem, a: Vector2, b: Vector2, color: Color, width := -1.0, aa := false) -> void:
	if _skip and not _drawing():
		return
	ci.draw_line(a, b, color, width, aa)


static func rect(ci: CanvasItem, r: Rect2, color: Color, filled := true, width := -1.0) -> void:
	if _skip and not _drawing():
		return
	ci.draw_rect(r, color, filled, width)


# --- Turret cache --------------------------------------------------------------------------------
# A turret is drawn as alternating static and live layers. Statements between dyn(true) and
# dyn(false) (recoil, glows, spinning parts) are live; everything else is static, baked once per
# look into one texture per layer, and stamped rotated to the aim. Baking happens at 8 aim angles
# so the upper-left lighting stays close; the remainder of the aim is a rotation of the stamp.
# Only the battlefield turns this on (turret_cache); elsewhere towers draw in full.

static var turret_cache := false
enum { _FULL, _COUNT, _BAKE, _LIVE }
static var _mode := _FULL
static var _skip := false
static var _in_dyn := false
static var _seg := 0
static var _bake_seg := 0
static var _seg_used := {}
static var _turrets := {}
static var _live := {}
const AIMED := ["gun_turret", "mortar_tower", "rocket_salvo", "laser_tower", "anti_aircraft_turret", "railgun", "mine_layer", "tractor_tower"]
## The aim of each extra gun of the tower being drawn (gun 0 is the main one); set by tower().
static var _extra: Array = []
const TURRET_BUCKETS := 8
const TURRET_SCALE := 2.5


## Marks the start (true) or end (false) of a live part of a turret.
static func dyn(on: bool) -> void:
	match _mode:
		_COUNT:
			_in_dyn = on
			if not on:
				_seg += 1
		_BAKE:
			if on:
				_skip = true
			else:
				_seg += 1
				_skip = _seg != _bake_seg
		_LIVE:
			if on:
				_skip = false
			else:
				_seg += 1
				_skip = true
				_stamp_turret(_seg)


## Called by every drawing leaf while _skip is set: never draws, but a dry run notes which static
## layers have something in them.
static func _drawing() -> bool:
	if _mode == _COUNT and not _in_dyn:
		_seg_used[_seg] = true
	return false


static func _cached_turret(ci: CanvasItem, type: String, tier: int, c: Vector2, aim: float, s: float, t: float, flash: float, spec: String, acc: Color) -> bool:
	var rot := aim if AIMED.has(type) else 0.0
	var bucket := posmod(roundi(rot / TAU * float(TURRET_BUCKETS)), TURRET_BUCKETS)
	var base_rot := float(bucket) * TAU / float(TURRET_BUCKETS)
	var key := "%s|%d|%s|%s|%.2f|%d" % [type, tier, spec, acc.to_html(), s, bucket]
	var e = _turrets.get(key)
	if e == null:
		e = _new_turret(ci, type, tier, base_rot, s, spec, acc)
		_turrets[key] = e
	if Engine.get_frames_drawn() < int(e.ready_at):
		return false
	_live = {"ci": ci, "e": e, "c": c, "rot": rot - base_rot}
	_mode = _LIVE
	_seg = 0
	_skip = true
	_stamp_turret(0)
	_turret(ci, type, tier, c, aim, s, t, flash, spec, acc)
	_mode = _FULL
	_skip = false
	_live = {}
	return true


static func _new_turret(ci: CanvasItem, type: String, tier: int, base_rot: float, s: float, spec: String, acc: Color) -> Dictionary:
	_mode = _COUNT
	_seg = 0
	_skip = true
	_in_dyn = false
	_seg_used = {}
	_turret(ci, type, tier, Vector2.ZERO, base_rot, s, 0.0, 0.0, spec, acc)
	var used: Array = _seg_used.keys()
	_mode = _FULL
	_skip = false
	_in_dyn = false
	var half := Vector2.ONE * 32.0 * s
	var texs := {}
	var ready := Engine.get_frames_drawn() + 2
	for k in used:
		var seg: int = k
		var tex := _bake_sprite(half, func(n: CanvasItem, _o: Vector2): _bake_turret_layer(n, seg, type, tier, base_rot, s, spec, acc), TURRET_SCALE)
		if tex == null:
			ready = 1 << 62
		texs[seg] = tex
	return {"tex": texs, "half": half, "ready_at": ready}


static func _bake_turret_layer(n: CanvasItem, seg: int, type: String, tier: int, base_rot: float, s: float, spec: String, acc: Color) -> void:
	_mode = _BAKE
	_bake_seg = seg
	_seg = 0
	_skip = seg != 0
	_turret(n, type, tier, Vector2.ZERO, base_rot, s, 0.0, 0.0, spec, acc)
	_mode = _FULL
	_skip = false


static func _stamp_turret(seg: int) -> void:
	var e: Dictionary = _live.e
	if not e.tex.has(seg):
		return
	var ci: CanvasItem = _live.ci
	var half: Vector2 = e.half
	ci.draw_set_transform(_live.c, _live.rot, Vector2.ONE)
	ci.draw_texture_rect(e.tex[seg], Rect2(-half, half * 2.0), false)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func outline(ci: CanvasItem, center: Vector2, pts: PackedVector2Array, color: Color, width: float, rot := 0.0, s := 1.0) -> void:
	if _skip and not _drawing():
		return
	var p := xform(center, pts, rot, s)
	p.append(p[0])
	polyline(ci, p, color, width, true)


## Filled polygon with a dark outline. `line_w` is in pixels, independent of the polygon scale `s`.
static func solid(ci: CanvasItem, center: Vector2, pts: PackedVector2Array, color: Color, rot := 0.0, s := 1.0, line_w := 1.2) -> void:
	if _skip and not _drawing():
		return
	fill(ci, center, pts, color, rot, s)
	outline(ci, center, pts, OUTLINE, line_w, rot, s)


static func ellipse(ci: CanvasItem, center: Vector2, rx: float, ry: float, color: Color) -> void:
	if _skip and not _drawing():
		return
	var size := _tex_size(maxf(rx, ry))
	if not _discs.has(size):
		_discs[size] = _shape_texture(size)
	_stamp(ci, _discs[size], size, center, rx, ry, color)


static func glow_dot(ci: CanvasItem, c: Vector2, r: float, color: Color) -> void:
	if _skip and not _drawing():
		return
	# The three coloured layers (alpha 0.18 to 2.2r, 0.35 to 1.4r, 1 to r) are one texture.
	var big := r * 2.2
	var size := 8 if big <= 1.33 else 16 if big <= 2.66 else 32 if big <= 5.33 else 64 if big <= 10.66 else 128 if big <= 21.33 else 256
	var tex: Texture2D = _glows.get(size)
	if tex == null:
		tex = _glow_texture(size)
		_glows[size] = tex
	var k := big * float(size) / (float(size) - 2.0)
	ci.draw_texture_rect(tex, Rect2(c.x - k, c.y - k, k * 2.0, k * 2.0), false, color)
	disc(ci, c, r * 0.45, Color(1, 1, 1, 0.9))


static func arc_segments(ci: CanvasItem, c: Vector2, r: float, count: int, gap: float, rot: float, color: Color, width: float) -> void:
	if _skip and not _drawing():
		return
	var span := TAU / float(count)
	for i in count:
		var a0 := rot + span * float(i) + gap * 0.5
		arc(ci, c, r, a0, a0 + span - gap, 8, color, width, true)


# --- Towers ----------------------------------------------------------------------------------

## `spec` shapes the model; `tint_spec` (default: the same) picks its accent colour, so a tower can
## show branch details while keeping its stock colour until its primary locks in.
static func tower(ci: CanvasItem, type: String, tier: int, c: Vector2, aim: float, s := 1.0, t := 0.0, flash := 0.0, spec := "", tint_spec := "~", extra: Array = []) -> void:
	_extra = extra
	var acc := accent(type, spec if tint_spec == "~" else tint_spec)
	if tier >= 4:
		mastery_ring(ci, c, s, acc, t)
	_pad(ci, c, s, acc, tier, t)
	if turret_cache and _mode == _FULL and _cached_turret(ci, type, tier, c, aim, s, t, flash, spec, acc):
		return
	_turret(ci, type, tier, c, aim, s, t, flash, spec, acc)


static func _turret(ci: CanvasItem, type: String, tier: int, c: Vector2, aim: float, s: float, t: float, flash: float, spec: String, acc: Color) -> void:
	match type:
		"gun_turret":
			GunTurretArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"mortar_tower":
			MortarTowerArt.draw(ci, c, aim, s, t, flash, spec, acc)
		"rocket_salvo":
			RocketSalvoArt.draw(ci, c, aim, s, t, flash, spec, acc)
		"laser_tower":
			LaserTowerArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"anti_aircraft_turret":
			AntiAircraftArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"artillery_cannon":
			ArtilleryCannonArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"railgun":
			RailgunArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"tesla_tower":
			TeslaTowerArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"drone_bay":
			DroneBayArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"cas_gunship":
			CasGunshipArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"mine_layer":
			MineLayerArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"chemical_plant":
			ChemicalPlantArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"cryo_tower":
			CryoTowerArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"boost_tower":
			BoostTowerArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"radar_tower":
			RadarTowerArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"shockwave_generator":
			ShockwaveGeneratorArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"scrapyard":
			ScrapyardArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"magneto_tower":
			MagnetoTowerArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"tractor_tower":
			TractorTowerArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)
		"augmentation_tower":
			AugmentationTowerArt.draw(ci, c, aim, s, t, flash, spec, acc, _extra)


## --- Shading helpers: light comes from the upper left. ------------------------------------

const LIGHT := Vector2(-0.6, -0.8)


## A shaded ball or dome: outline, base, a lit face offset toward the light, a rim highlight
## and a small specular glint.
static func orb(ci: CanvasItem, p: Vector2, r: float, col: Color, s := 1.0) -> void:
	if _skip and not _drawing():
		return
	disc(ci, p, r + 1.1 * s, OUTLINE)
	disc(ci, p, r, col.darkened(0.3))
	disc(ci, p + LIGHT * r * 0.12, r * 0.8, col)
	arc(ci, p, r * 0.72, PI * 1.05, PI * 1.6, 10, col.lightened(0.35), maxf(0.8, r * 0.16), true)
	disc(ci, p + LIGHT * r * 0.45, maxf(0.6, r * 0.13), Color(1, 1, 1, 0.55))


## A bevelled plate: outlined polygon, a lighter inset face, lit edges toward the light and
## shadowed edges away from it.
static func plate(ci: CanvasItem, c: Vector2, pts: PackedVector2Array, col: Color, rot := 0.0, s := 1.0, line_w := 1.2) -> void:
	if _skip and not _drawing():
		return
	var p := xform(c, pts, rot, s)
	var closed := p.duplicate()
	closed.append(p[0])
	poly(ci, p, col.darkened(0.22))
	var centre := Vector2.ZERO
	for q in p:
		centre += q
	centre /= float(p.size())
	var inset := PackedVector2Array()
	for q in p:
		inset.append(centre + (q - centre) * 0.8)
	poly(ci, inset, col)
	for i in p.size():
		var a := p[i]
		var b := p[(i + 1) % p.size()]
		var m := (a + b) * 0.5 - centre
		var lit := m.normalized().dot(LIGHT) > 0.15
		var dark := m.normalized().dot(LIGHT) < -0.15
		if lit:
			line(ci, a.lerp(centre, 0.1), b.lerp(centre, 0.1), col.lightened(0.45), maxf(0.8, line_w * 0.8), true)
		elif dark:
			line(ci, a.lerp(centre, 0.1), b.lerp(centre, 0.1), col.darkened(0.5), maxf(0.8, line_w * 0.8), true)
	polyline(ci, closed, OUTLINE, line_w, true)


## Small rivets at a polygon's (scaled-in) corners; `r` is the rivet radius in pixels.
static func rivets(ci: CanvasItem, c: Vector2, pts: PackedVector2Array, rot: float, s: float, inset := 0.72, r := 0.9) -> void:
	if _skip and not _drawing():
		return
	for q in xform(c, pts, rot, s):
		var p: Vector2 = c + (q - c) * inset
		disc(ci, p, r + 0.3, OUTLINE)
		disc(ci, p, r, METAL_L.lightened(0.15))


## A thick shaded bar from a to b (barrels, rails, struts).
static func bar(ci: CanvasItem, a: Vector2, b: Vector2, w: float, col: Color) -> void:
	if _skip and not _drawing():
		return
	var d := (b - a).normalized()
	var n := d.orthogonal()
	if n.dot(LIGHT) < 0.0:
		n = -n
	line(ci, a, b, OUTLINE, w + 1.6, true)
	line(ci, a, b, col.darkened(0.25), w, true)
	line(ci, a + n * w * 0.18, b + n * w * 0.18, col, w * 0.55, true)
	line(ci, a + n * w * 0.3, b + n * w * 0.3, col.lightened(0.4), maxf(0.6, w * 0.16), true)


## A glowing strip light.
static func strip(ci: CanvasItem, a: Vector2, b: Vector2, w: float, col: Color) -> void:
	if _skip and not _drawing():
		return
	line(ci, a, b, Color(col, 0.25), w * 2.6, true)
	line(ci, a, b, col, w, true)
	line(ci, a, b, Color(1, 1, 1, 0.6), maxf(0.5, w * 0.35), true)


static func rect_pts(hw: float, hh: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(-hw, -hh), Vector2(hw, -hh), Vector2(hw, hh), Vector2(-hw, hh)])



## The hex deck every tower stands on: bevelled armour, corner bolts, vents, status LEDs,
## an accent trim that breathes, and tier pips (gold from the specialization on).
static func _pad(ci: CanvasItem, c: Vector2, s: float, acc: Color, tier: int, t: float) -> void:
	# Static plating below the lit rim, the rim (a white stroke tinted live), then rivets and vents.
	var half := Vector2(24.0, 24.0) * s
	var si := roundi(s * 100.0)
	var ka := 1000000 + si
	var kr := 2000000 + si * 10 + tier
	var kb := 3000000 + si
	if not _sprites.has(kr):
		var w := (1.0 + 0.35 * float(tier)) * s
		_sprites[kr] = _bake_sprite(half, func(n: CanvasItem, o: Vector2): outline(n, o, ngon(6, 1.0), Color(1, 1, 1), w, 0.0, 17.6 * s))
		if not _sprites.has(ka):
			_sprites[ka] = _bake_sprite(half, func(n: CanvasItem, o: Vector2): _pad_base(n, o, s))
			_sprites[kb] = _bake_sprite(half, func(n: CanvasItem, o: Vector2): _pad_rivets(n, o, s))
	var base: Texture2D = _sprites[ka]
	if base == null:
		_pad_base(ci, c, s)
		outline(ci, c, ngon(6, 1.0), Color(acc, 0.5 + 0.2 * sin(t * 2.2)), (1.0 + 0.35 * float(tier)) * s, 0.0, 17.6 * s)
		_pad_rivets(ci, c, s)
	else:
		var r := Rect2(c - half, half * 2.0)
		ci.draw_texture_rect(base, r, false)
		ci.draw_texture_rect(_sprites[kr], r, false, Color(acc, 0.5 + 0.2 * sin(t * 2.2)))
		ci.draw_texture_rect(_sprites[kb], r, false)
	var blink := fmod(t * 0.9, 2.0) < 0.12
	disc(ci, c + Vector2(-9.0, 11.0) * s, 1.0 * s, Color(0.4, 1.0, 0.5, 0.95 if blink else 0.45))
	disc(ci, c + Vector2(9.0, 11.0) * s, 1.0 * s, Color(acc, 0.8))
	for i in tier:
		var x := (float(i) - float(tier - 1) / 2.0) * 6.5
		var pip := Rect2(c + Vector2(x - 2.4, 15.0) * s, Vector2(4.8, 2.0) * s)
		rect(ci, pip.grow(0.6), OUTLINE)
		rect(ci, pip, GOLD if tier >= 3 else acc)


static func _pad_base(ci: CanvasItem, c: Vector2, s: float) -> void:
	ellipse(ci, c + Vector2(0, 6) * s, 21.0 * s, 9.0 * s, Color(0, 0, 0, 0.35))
	var hex := ngon(6, 1.0)
	fill(ci, c, hex, OUTLINE, 0.0, 20.5 * s)
	plate(ci, c, hex, METAL_D.lightened(0.05), 0.0, 19.2 * s, 1.0)
	fill(ci, c, hex, METAL, 0.0, 15.6 * s)
	outline(ci, c, hex, Color(0, 0, 0, 0.45), 1.0, 0.0, 15.6 * s)


static func _pad_rivets(ci: CanvasItem, c: Vector2, s: float) -> void:
	for q in xform(c, ngon(6, 1.0), 0.0, 17.6 * s):
		disc(ci, q, 1.5 * s, OUTLINE)
		disc(ci, q, 1.0 * s, METAL_L)
	for k in 3:
		var y := c.y - 13.0 * s + float(k) * 2.2 * s
		line(ci, Vector2(c.x - 13.5 * s, y), Vector2(c.x - 10.0 * s, y), Color(0, 0, 0, 0.5), 1.0)
		line(ci, Vector2(c.x + 10.0 * s, y), Vector2(c.x + 13.5 * s, y), Color(0, 0, 0, 0.5), 1.0)


## Distance from a Laser Lance's centre to the tip of its barrel, at drawing scale `s`.
static func laser_barrel_length(tier: int, s: float) -> float:
	return (19.0 + 2.0 * float(tier)) * s

## A single drone (also drawn in flight by the entity layer).
static func drone(ci: CanvasItem, p: Vector2, facing: Vector2, s: float, t: float, spec: String, acc: Color, bomber := false) -> void:
	if _skip and not _drawing():
		return
	var n := facing.orthogonal()
	if bomber or spec == "bombers":
		plate(ci, p, rect_pts(0.5, 0.4), METAL, facing.angle(), 6.0 * s, 1.0)
		disc(ci, p + facing * 1.0 * s, 1.6 * s, Color(0.1, 0.1, 0.1))
		glow_dot(ci, p - facing * 2.2 * s, 0.8 * s, Color(1.0, 0.55, 0.2))
		return
	for k in 4:
		var a := facing.angle() + PI / 4.0 + TAU * float(k) / 4.0
		var tip := p + Vector2.from_angle(a) * 3.2 * s
		line(ci, p, tip, METAL_L, 0.9 * s, true)
		arc(ci, tip, 1.4 * s, t * 30.0, t * 30.0 + 2.4, 5, Color(0.85, 0.9, 1.0, 0.6), 0.6 * s, true)
	var body := PackedVector2Array([p + facing * 2.6 * s, p + n * 1.5 * s - facing * 1.4 * s, p - n * 1.5 * s - facing * 1.4 * s])
	poly(ci, body, METAL.lightened(0.1) if spec != "interceptors" else acc.darkened(0.3))
	glow_dot(ci, p + facing * 1.2 * s, 0.7 * s, Color(1.0, 0.25, 0.25) if spec == "hunters" else acc)


## EMP overlay for a tower a Jammer knocked offline.
static func tower_offline(ci: CanvasItem, c: Vector2, t: float) -> void:
	var col := Color(0.9, 1.0, 0.3)
	disc(ci, c, 17.0, Color(0.05, 0.06, 0.02, 0.45))
	for k in 3:
		var a := t * 7.0 + float(k) * 2.1
		var p0 := c + Vector2.from_angle(a) * 6.0
		var p1 := c + Vector2.from_angle(a + 0.5) * 12.0 + Vector2(sin(t * 40.0 + float(k)) * 2.0, 0)
		var p2 := c + Vector2.from_angle(a + 0.2) * 17.0
		polyline(ci, PackedVector2Array([p0, p1, p2]), Color(col, 0.8), 1.3, true)
	arc_segments(ci, c, 19.0, 4, 0.8, t * 3.0, Color(col, 0.6), 1.2)


# --- Enemies ---------------------------------------------------------------------------------

## An ellipse rotated by `rot` (radians), as a filled polygon.
static func oval(ci: CanvasItem, c: Vector2, rx: float, ry: float, rot: float, color: Color, outline_w := 0.0) -> void:
	if _skip and not _drawing():
		return
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * float(i) / 20.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry).rotated(rot))
	if outline_w > 0.0:
		var big := PackedVector2Array()
		for p in pts:
			big.append(c + (p - c) * (1.0 + outline_w / maxf(rx, ry)))
		poly(ci, big, OUTLINE)
	poly(ci, pts, color)


## A shaded oval: outline, base, lit face toward the light, glint.
static func shaded_oval(ci: CanvasItem, c: Vector2, rx: float, ry: float, rot: float, col: Color, s := 1.0) -> void:
	if _skip and not _drawing():
		return
	oval(ci, c, rx, ry, rot, col.darkened(0.3), 1.3 * s)
	oval(ci, c + LIGHT * minf(rx, ry) * 0.12, rx * 0.8, ry * 0.78, rot, col)
	disc(ci, c + LIGHT * minf(rx, ry) * 0.5, maxf(0.6, minf(rx, ry) * 0.14), Color(1, 1, 1, 0.45))


## A jointed limb: segments with a joint dot at each bend.
static func limb(ci: CanvasItem, pts: PackedVector2Array, w: float, col: Color) -> void:
	if _skip and not _drawing():
		return
	polyline(ci, pts, OUTLINE, w + 1.4, true)
	polyline(ci, pts, col, w, true)
	for i in range(1, pts.size() - 1):
		disc(ci, pts[i], w * 0.75 + 0.4, OUTLINE)
		disc(ci, pts[i], w * 0.75, col.lightened(0.25))


## One enemy, in its confirmed art (scripts/view/enemies). `r` is its hit radius (the size of the slow and hit
## overlays); the look itself is drawn at its design size times `s`. `st` is EnemyArt.state(e) for an enemy on the
## field (it times the look's effects); leave it empty for a preview.
static func enemy(ci: CanvasItem, type: String, c: Vector2, facing: Vector2, r: float, t: float, slowed := false, flash := 0.0, s := 1.0, hidden := false, st := {}) -> void:
	if not EnemyArt.has(type):
		disc(ci, c, r * s, ENEMY_BODY.get(type, METAL))
		return
	EnemyArt.draw(ci, type, c, facing, t, s, st)
	var rr := r * s
	if slowed and not hidden:
		disc(ci, c, rr * 1.12, Color(0.55, 0.85, 1.0, 0.28))
		ring(ci, c, rr * 1.12, Color(0.7, 0.95, 1.0, 0.6), 1.0 * s)
	if flash > 0.0 and not hidden:
		disc(ci, c, rr, Color(1, 1, 1, clampf(flash * 8.0, 0.0, 0.6)))


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
		line(ci, p + Vector2(-3, -3), p + Vector2(3, 3), Color(1.0, 0.35, 0.35), 1.6, true)
		line(ci, p + Vector2(-1, -4), p + Vector2(4, 1), Color(1.0, 0.35, 0.35), 1.6, true)
	if e.vuln_timer > 0.0:
		arc_segments(ci, e.pos, r + 4.0, 4, 0.9, t * 2.0, Color(0.85, 0.6, 1.0, 0.8), 1.4)
	if e.stun_timer > 0.0:
		for i in 3:
			var a := t * 9.0 + TAU * float(i) / 3.0
			disc(ci, e.pos + Vector2(cos(a) * r * 0.9, -r - 4.0 + sin(a) * 2.0), 1.8, Color(1.0, 0.92, 0.3))
	# Silenced (suppressed or jammed): a struck-through ring over the head.
	if e.silenced():
		var sp: Vector2 = e.pos + Vector2(-r * 0.7, -r - 3.0)
		arc(ci, sp, 3.2, 0.0, TAU, 12, Color(0.75, 0.55, 1.0, 0.9), 1.3, true)
		line(ci, sp + Vector2(-2.3, 2.3), sp + Vector2(2.3, -2.3), Color(0.75, 0.55, 1.0, 0.9), 1.3, true)
	# Exposed (immunities stripped): a dashed white ring.
	if e.exposed():
		arc_segments(ci, e.pos, r + 7.0, 6, 0.5, -t * 1.5, Color(1, 1, 1, 0.55), 1.1)
	# Armor broken: a cracked plate.
	if e.armor_break_timer > 0.0 and e.armor > 0.0:
		var bp: Vector2 = e.pos + Vector2(-r * 0.75, r * 0.55)
		rect(ci, Rect2(bp - Vector2(3, 3), Vector2(6, 6)), Color(0.55, 0.55, 0.6, 0.9))
		polyline(ci, PackedVector2Array([bp + Vector2(-2, -3), bp + Vector2(0.5, -0.5), bp + Vector2(-1, 1), bp + Vector2(2, 3)]), Color(1.0, 0.45, 0.2), 1.1, true)
	# Burning: flickering flame tongues licking up from its top edge, so they show above the body (#85).
	if e.dot_timer > 0.0 and e.dot_dps > 0.0:
		for i in 3:
			var fx := (float(i) - 1.0) * r * 0.5
			var h := 7.0 + 3.0 * sin(t * 14.0 + float(i) * 2.0)
			var fb: Vector2 = e.pos + Vector2(fx, -r * 0.55)
			poly(ci, PackedVector2Array([fb + Vector2(-2.8, 0), fb + Vector2(0, -h), fb + Vector2(2.8, 0)]), Color(1.0, 0.45, 0.1, 0.85))
			poly(ci, PackedVector2Array([fb + Vector2(-1.3, 0), fb + Vector2(0, -h * 0.55), fb + Vector2(1.3, 0)]), Color(1.0, 0.85, 0.3, 0.9))


# --- HUD glyphs ------------------------------------------------------------------------------

static func shield(ci: CanvasItem, c: Vector2, size: float, col: Color) -> void:
	if _skip and not _drawing():
		return
	var r := size
	var pts := PackedVector2Array([
		c + Vector2(-r * 0.85, -r * 0.8), c + Vector2(0, -r * 1.05), c + Vector2(r * 0.85, -r * 0.8),
		c + Vector2(r * 0.8, r * 0.1), c + Vector2(0, r * 1.05), c + Vector2(-r * 0.8, r * 0.1),
	])
	poly(ci, pts, Color(col, 0.35))
	var closed := pts.duplicate()
	closed.append(pts[0])
	polyline(ci, closed, col, 2.0, true)
	line(ci, c + Vector2(0, -r * 0.6), c + Vector2(0, r * 0.6), col, 1.6, true)


static func coin(ci: CanvasItem, c: Vector2, r: float) -> void:
	if _skip and not _drawing():
		return
	var hex := ngon(6, 1.0, PI / 6.0)
	fill(ci, c, hex, OUTLINE, 0.0, r + 1.2)
	fill(ci, c, hex, Color(1.0, 0.72, 0.22), 0.0, r)
	outline(ci, c, hex, Color(0.6, 0.38, 0.08), 1.2, 0.0, r * 0.62)
	disc(ci, c, r * 0.22, Color(1, 1, 0.85))


## Research-node glyphs for the Research Lab (see `icon` in data/research.gd).
static func research_glyph(ci: CanvasItem, icon: String, c: Vector2, r: float, col: Color, t := 0.0) -> void:
	if _skip and not _drawing():
		return
	var w := maxf(1.4, r * 0.16)
	match icon:
		"damage":
			for k in 2:
				var y := (0.25 - 0.55 * float(k)) * r
				polyline(ci, PackedVector2Array([c + Vector2(-0.55 * r, y + 0.35 * r), c + Vector2(0, y - 0.1 * r), c + Vector2(0.55 * r, y + 0.35 * r)]), col, w, true)
		"range":
			disc(ci, c + Vector2(-0.45 * r, 0.35 * r), w * 0.9, col)
			for k in 2:
				arc(ci, c + Vector2(-0.45 * r, 0.35 * r), (0.45 + 0.42 * float(k)) * r, -PI / 2.0, 0.0, 10, col, w, true)
		"rate":
			for k in 2:
				var x := (-0.45 + 0.5 * float(k)) * r
				polyline(ci, PackedVector2Array([c + Vector2(x, -0.5 * r), c + Vector2(x + 0.4 * r, 0), c + Vector2(x, 0.5 * r)]), col, w, true)
		"blast":
			disc(ci, c, 0.28 * r, col)
			for k in 8:
				var d := Vector2.from_angle(TAU * float(k) / 8.0 + PI / 8.0)
				line(ci, c + d * 0.45 * r, c + d * 0.8 * r, col, w * 0.8, true)
		"slow":
			for k in 3:
				var d := Vector2.from_angle(PI / 2.0 + PI * float(k) / 3.0) * 0.72 * r
				line(ci, c - d, c + d, col, w, true)
			disc(ci, c, w, col)
		"chain":
			polyline(ci, PackedVector2Array([c + Vector2(-0.6, -0.55) * r, c + Vector2(0.05, -0.1) * r, c + Vector2(-0.15, 0.15) * r, c + Vector2(0.6, 0.6) * r]), col, w, true)
			disc(ci, c + Vector2(-0.6, -0.55) * r, w * 1.1, col)
			disc(ci, c + Vector2(0.6, 0.6) * r, w * 1.1, col)
		"credits":
			var hex := ngon(6, 1.0, PI / 6.0)
			outline(ci, c, hex, col, w, 0.0, 0.62 * r)
			line(ci, c + Vector2(0, -0.32 * r), c + Vector2(0, 0.32 * r), col, w, true)
		"shield":
			shield(ci, c, 0.62 * r, col)
		"push":
			disc(ci, c + Vector2(0.5 * r, 0), 0.22 * r, col)
			for k in 2:
				var x := (0.15 - 0.4 * float(k)) * r
				polyline(ci, PackedVector2Array([c + Vector2(x + 0.25 * r, -0.5 * r), c + Vector2(x - 0.15 * r, 0), c + Vector2(x + 0.25 * r, 0.5 * r)]), col, w, true)
		"salvage":
			arc(ci, c, 0.55 * r, -PI * 0.1, PI * 1.35, 16, col, w, true)
			var tip := c + Vector2.from_angle(-PI * 0.1) * 0.55 * r
			polyline(ci, PackedVector2Array([tip + Vector2(-0.32, -0.12) * r, tip, tip + Vector2(0.08, -0.34) * r]), col, w, true)
		"uplink":
			arc(ci, c + Vector2(0, 0.1 * r), 0.6 * r, PI * 1.15, PI * 1.85, 10, col, w, true)
			line(ci, c + Vector2(0, 0.1 * r), c + Vector2(0, 0.65 * r), col, w, true)
			var pulse := fmod(t * 0.8, 1.0)
			arc(ci, c + Vector2(0, -0.2 * r), (0.3 + 0.5 * pulse) * r, PI * 1.3, PI * 1.7, 8, Color(col, 1.0 - pulse), w * 0.7, true)
			disc(ci, c + Vector2(0, -0.2 * r), w, col)
		"mastery":
			var pts := PackedVector2Array()
			for k in 8:
				var a := -PI / 2.0 + TAU * float(k) / 8.0
				pts.append(c + Vector2.from_angle(a) * (0.78 if k % 2 == 0 else 0.3) * r)
			poly(ci, pts, Color(col, 0.35))
			var closed := pts.duplicate()
			closed.append(pts[0])
			polyline(ci, closed, col, w * 0.8, true)
			disc(ci, c, 0.14 * r, Color(1, 1, 1, 0.9))


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
		disc(ci, c, r * 1.25, Color(edge, 0.12))
	fill(ci, c, hex, OUTLINE, 0.0, r + 2.0)
	fill(ci, c, hex, fill_c, 0.0, r)
	outline(ci, c, hex, edge, edge_w, 0.0, r)
	if double:
		outline(ci, c, hex, Color(edge, 0.5), 1.0, 0.0, r - 4.0)
	return glyph


## Small padlock glyph.
static func lock(ci: CanvasItem, c: Vector2, s: float, col: Color) -> void:
	if _skip and not _drawing():
		return
	rect(ci, Rect2(c + Vector2(-4, -1) * s, Vector2(8, 6.5) * s), col)
	arc(ci, c + Vector2(0, -1) * s, 2.6 * s, PI, TAU, 8, col, 1.5 * s, true)


## Tier-4 mastery aura: a slow gold segmented ring around the tower pad.
static func mastery_ring(ci: CanvasItem, c: Vector2, s: float, acc: Color, t: float) -> void:
	if _skip and not _drawing():
		return
	# Two segmented rings turning opposite ways: cached in white, rotated and tinted live.
	var half := Vector2(28.0, 28.0) * s
	var ka := 4000000 + roundi(s * 100.0)
	var kb := 5000000 + roundi(s * 100.0)
	if not _sprites.has(ka):
		_sprites[ka] = _bake_sprite(half, func(n: CanvasItem, o: Vector2): arc_segments(n, o, 23.0 * s, 6, 0.55, 0.0, Color(1, 1, 1), 1.6 * s))
		_sprites[kb] = _bake_sprite(half, func(n: CanvasItem, o: Vector2): arc_segments(n, o, 25.5 * s, 3, 1.4, 0.0, Color(1, 1, 1), 1.2 * s))
	if _sprites[ka] == null:
		arc_segments(ci, c, 23.0 * s, 6, 0.55, t * 0.7, Color(GOLD, 0.75), 1.6 * s)
		arc_segments(ci, c, 25.5 * s, 3, 1.4, -t * 1.1, Color(acc, 0.5), 1.2 * s)
		return
	_stamp_rotated(ci, _sprites[ka], c, half, t * 0.7, Color(GOLD, 0.75))
	_stamp_rotated(ci, _sprites[kb], c, half, -t * 1.1, Color(acc, 0.5))


static func heart(ci: CanvasItem, c: Vector2, size: float, col: Color) -> void:
	if _skip and not _drawing():
		return
	shield(ci, c, size, col)


static func star(ci: CanvasItem, c: Vector2, r: float, filled: bool) -> void:
	if _skip and not _drawing():
		return
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI / 2.0 + TAU * float(i) / 10.0
		pts.append(c + Vector2(cos(a), sin(a)) * (r if i % 2 == 0 else r * 0.45))
	if filled:
		disc(ci, c, r * 1.1, Color(GOLD, 0.15))
		poly(ci, pts, GOLD)
	else:
		poly(ci, pts, Color(0.12, 0.15, 0.2))
	var closed := pts.duplicate()
	closed.append(pts[0])
	polyline(ci, closed, OUTLINE if filled else Color(0.3, 0.42, 0.52), 1.5, true)


static func stars(ci: CanvasItem, c: Vector2, r: float, count: int, total := 3) -> void:
	if _skip and not _drawing():
		return
	for i in total:
		star(ci, c + Vector2((float(i) - float(total - 1) / 2.0) * r * 2.3, 0), r, i < count)


## A sector medal for a difficulty mode: ribbon tails in the mode's colour, a gold-rimmed disc and
## one chevron per mode tier (Easy 1 ... Cataclysm 5). Unearned medals are a dim grey outline.
static func medal(ci: CanvasItem, c: Vector2, r: float, mode: String, earned: bool, t := 0.0) -> void:
	if _skip and not _drawing():
		return
	var tier := maxi(1, Difficulty.ORDER.find(mode) + 1)
	var col: Color = Difficulty.DIFFICULTIES.get(mode, Difficulty.DIFFICULTIES.medium).color
	if not earned:
		col = Color(0.26, 0.31, 0.37)
	var tail := col.darkened(0.3) if earned else Color(0.2, 0.24, 0.29)
	for s in [-1.0, 1.0]:
		poly(ci, PackedVector2Array([
			c + Vector2(s * r * 0.1, r * 0.2), c + Vector2(s * r * 0.72, r * 0.35),
			c + Vector2(s * r * 0.62, r * 1.35), c + Vector2(s * r * 0.38, r * 1.08), c + Vector2(s * r * 0.08, r * 1.3),
		]), tail)
	var rim := Color(1.0, 0.8, 0.35) if earned else Color(0.33, 0.38, 0.44)
	disc(ci, c, r, OUTLINE)
	disc(ci, c, r * 0.92, rim.darkened(0.35))
	disc(ci, c, r * 0.8, rim)
	disc(ci, c, r * 0.66, col.darkened(0.15) if earned else Color(0.11, 0.14, 0.18))
	var mark := Color(1, 1, 1, 0.95) if earned else Color(0.38, 0.44, 0.5)
	var w := r * 0.36
	for i in tier:
		var y := (float(i) - float(tier - 1) / 2.0) * r * 0.22
		polyline(ci, PackedVector2Array([c + Vector2(-w, y + r * 0.09), c + Vector2(0, y - r * 0.09), c + Vector2(w, y + r * 0.09)]), mark, maxf(1.3, r * 0.09), true)
	if earned:
		arc(ci, c, r * 0.72, -2.5 + 0.15 * sin(t * 2.0), -1.3 + 0.15 * sin(t * 2.0), 10, Color(1, 1, 1, 0.5), maxf(1.0, r * 0.07), true)



static func ability_icon(ci: CanvasItem, id: String, c: Vector2, r: float, t: float) -> void:
	if _skip and not _drawing():
		return
	match id:
		"meteor":
			var col := Color(1.0, 0.45, 0.2)
			line(ci, c + Vector2(0, -r * 1.2), c + Vector2(0, r * 0.3), Color(col, 0.4), r * 0.55, true)
			line(ci, c + Vector2(0, -r * 1.2), c + Vector2(0, r * 0.3), Color(1, 0.85, 0.6), r * 0.18, true)
			ring(ci, c + Vector2(0, r * 0.35), r * 0.55 + sin(t * 6.0) * 1.5, col, 2.0)
			line(ci, c + Vector2(-r * 0.8, r * 0.35), c + Vector2(-r * 0.35, r * 0.35), col, 1.6, true)
			line(ci, c + Vector2(r * 0.35, r * 0.35), c + Vector2(r * 0.8, r * 0.35), col, 1.6, true)
		"warp":
			disc(ci, c, r * 0.95, Color(0.45, 0.35, 1.0, 0.25 + 0.1 * sin(t * 3.0)))
			arc(ci, c, r * 0.8, 0.0, TAU, 32, Color(0.75, 0.68, 1.0), 2.5, true)
			line(ci, c, c + Vector2.from_angle(t * 0.8 - PI / 2.0) * r * 0.6, Color(1, 1, 1), 2.5, true)
			line(ci, c, c + Vector2.from_angle(t * 0.1 - PI / 2.0) * r * 0.4, Color(1, 1, 1), 3.0, true)
			for i in 12:
				var a := TAU * float(i) / 12.0
				disc(ci, c + Vector2.from_angle(a) * r * 0.8, 1.4, Color(0.9, 0.85, 1.0))
