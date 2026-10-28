extends Node2D
## Draws everything that moves: plasma pools, towers (with smoothed aim), enemies, projectiles,
## status markers, HP bars and the boss bar.

const Draw = preload("res://scripts/view/Draw.gd")
const Grid = preload("res://scripts/core/Grid.gd")
const EnemyArt = preload("res://scripts/view/enemies/EnemyArt.gd")
const GunTurretArt = preload("res://scripts/view/towers/GunTurretArt.gd")
const MortarTowerArt = preload("res://scripts/view/towers/MortarTowerArt.gd")
const RocketSalvoArt = preload("res://scripts/view/towers/RocketSalvoArt.gd")
const AntiAircraftArt = preload("res://scripts/view/towers/AntiAircraftArt.gd")
const ArtilleryCannonArt = preload("res://scripts/view/towers/ArtilleryCannonArt.gd")
const DroneBayArt = preload("res://scripts/view/towers/DroneBayArt.gd")
const CasGunshipArt = preload("res://scripts/view/towers/CasGunshipArt.gd")
const MineLayerArt = preload("res://scripts/view/towers/MineLayerArt.gd")
const ChemicalPlantArt = preload("res://scripts/view/towers/ChemicalPlantArt.gd")
const CryoTowerArt = preload("res://scripts/view/towers/CryoTowerArt.gd")
const RadarTowerArt = preload("res://scripts/view/towers/RadarTowerArt.gd")
const ShockwaveGeneratorArt = preload("res://scripts/view/towers/ShockwaveGeneratorArt.gd")

## The ring and label colour of an elite (an enemy with modifiers).
const ELITE_COLOR := Color(1.0, 0.82, 0.30)
## A Siphon's drain (its aura, and the tint on towers inside it).
const SIPHON_COLOR := Color(0.72, 1.0, 0.25)
## The cross on a hologram a Radar's Illusion Filter marked as a fake.
const FAKE_MARK := Color(1.0, 0.3, 0.3, 0.8)
## How high Mortar and Artillery shells are lobbed at the middle of their flight, in tiles (as on the design pages, #90).
const MORTAR_ARC := 0.85
const ARTILLERY_ARC := 0.85

var world
## Microseconds spent per section of _draw, summed; tools/PerfProbe.gd reads and resets it.
static var timing := {}
static var timing_on := false
var _aim := {}
## Each extra gun's smoothed aim, per tower (the Gun Turret's flank guns turn on their own).
var _extra_aim := {}
## The CAS Gunship plane's eased heading, per tower.
var _heading := {}
var _font: Font


func _ready() -> void:
	_font = ThemeDB.fallback_font


func _draw() -> void:
	var g = world.game
	if g == null:
		return
	var t: float = world.anim_t
	for pool in g.pools:
		_pool(pool, t)
	for c in g.smokes:
		if c.get("look", "") == "smoke":
			_smoke(c, t)
	# Turrets' static layers come from Draw's sprite cache here (see Draw.dyn).
	var t0 := Time.get_ticks_usec()
	Draw.turret_cache = true
	for tw in g.towers:
		var key: int = tw.get_instance_id()
		var cur: float = _aim.get(key, -PI / 2.0)
		if tw.target != null and tw.target.alive:
			# Fast traverse and the Swivel Mount (#85) turn quicker; neither changes the fire rate.
			var fast: bool = bool(tw.stats().get("turn_fast", false)) or bool(tw.stats().get("swivel", false))
			cur = lerp_angle(cur, (tw.target.pos - tw.pos).angle(), 0.6 if fast else 0.35)
		if tw.type == "mortar_tower":
			# It points where its shell will land (the lead point, #110), which the game keeps in its aim.
			cur = lerp_angle(float(_aim.get(key, cur)), tw.aim, 0.35)
		elif tw.type == "artillery_cannon":
			# It points at the spot it shells, not at an enemy.
			cur = lerp_angle(cur, (tw.aim_point - tw.pos).angle(), 0.35)
		elif tw.type == "laser_tower":
			# The game turns it (its beams wait until it faces the target), so the lance and the beam agree (#90).
			cur = tw.aim
		elif tw.type == "mine_layer":
			# It turns toward the spot it throws at next.
			cur = lerp_angle(cur, tw.aim, 0.2)
		_aim[key] = cur
		var extra: Array = []
		if tw.type == "gun_turret":
			extra = _extra_aims(tw, key, cur)
		elif tw.type == "magneto_tower":
			extra = [tw.pulse_count]
		elif tw.type == "tractor_tower":
			var rech := float(tw.stats().get("recharge", 6.0))
			var holding := float(tw.gun_cds.get("hold_left", 0.0)) > 0.0
			# The charge meter drains over the hold and refills over the recharge (#110).
			var hold_frac: float = float(tw.gun_cds.get("hold_left", 0.0)) / maxf(float(tw.gun_cds.get("hold_total", 1.0)), 0.01)
			extra = [clampf(hold_frac, 0.0, 1.0) if holding else clampf(1.0 - tw.cooldown / maxf(rech, 0.1), 0.0, 1.0), 1.0 if holding else 0.0]
		elif tw.type == "shockwave_generator":
			extra = [g.time - float(tw.gun_cds.get("wave_t", -9.0))]
		elif tw.type == "radar_tower":
			extra = [3.0 if tw.stats().get("constant", false) else float(tw.stats().get("ping_every", 3.0))]
		elif tw.type == "scrapyard":
			extra = [g.time - float(tw.gun_cds.get("paid_t", -99.0))]
		elif tw.type == "cryo_tower":
			extra = [clampf(tw.fire_flash / 0.3, 0.0, 1.0)]
		elif tw.type == "chemical_plant":
			# Constant Spray's head points where the jet is in its sweep (#104), not along the smoothed aim.
			extra = [float(tw.gun_cds.get("spray_a", cur))]
		elif tw.type == "mine_layer" or tw.type == "mortar_tower":
			extra = [tw.pulse_count]
		elif tw.type == "drone_bay":
			extra = [tw.available_loadouts().find(tw.loadout), tw.wing.is_empty()]
		elif tw.type == "tesla_tower":
			extra = [clampf(1.0 - tw.cooldown * tw.eff_rate(), 0.0, 1.0)]
		elif tw.type == "railgun":
			extra = [clampf(1.0 - tw.cooldown * tw.eff_rate(), 0.0, 1.0), tw.pulse_count, g.time - float(tw.gun_cds.get("shot_t", -99.0))]
		elif tw.type == "artillery_cannon":
			extra = [ArtilleryCannonArt.types(ArtilleryCannonArt.levels(tw.look_key())).find(tw.shell), tw.pulse_count]
		elif tw.type == "anti_aircraft_turret":
			extra = [tw.pulse_count]
		elif tw.type == "rocket_salvo":
			extra = [RocketSalvoArt.ready_of(tw.cooldown, 1.0 / maxf(tw.eff_rate(), 0.001)), g.time - float(tw.gun_cds.get("salvo_t", -99.0))]
		elif tw.type == "laser_tower":
			extra = [clampf(tw.ramp / float(tw.stats().ramp_time), 0.0, 1.0) if tw.beam_on else 0.0]
		Draw.tower(self, tw.type, tw.tier, tw.pos, cur, 1.0 if tw.size <= 1 else 1.8, t + float(tw.cell.x) * 0.3, tw.fire_flash, tw.spec, "", extra)
		if tw.disabled > 0.0:
			Draw.tower_offline(self, tw.pos, t)
		elif tw.debuff_rate > 0.0 or tw.debuff_range > 0.0:
			# Drained by a Siphon: a violet tint and a down arrow.
			Draw.disc(self, tw.pos, 16.0, Color(SIPHON_COLOR, 0.12))
			var ap: Vector2 = tw.pos + Vector2(-14, -14)
			Draw.poly(self, PackedVector2Array([ap + Vector2(-3, -2), ap + Vector2(3, -2), ap + Vector2(0, 3)]), SIPHON_COLOR)
		# Boosted: the small boost dot (the chevrons were removed, #110).
		if tw.buff_dmg > 0.0:
			Draw.disc(self, tw.pos + Vector2(14, -14), 3.0, Draw.OUTLINE)
			Draw.disc(self, tw.pos + Vector2(14, -14), 2.2, Draw.ACCENT.boost_tower)
	Draw.turret_cache = false
	var t1 := Time.get_ticks_usec()
	if timing_on:
		timing.towers = int(timing.get("towers", 0)) + t1 - t0

	var layers := draw_order(g.enemies)
	var ground: Array = layers[0]
	var air: Array = layers[1]
	for i in g.mines.size():
		var m: Dictionary = g.mines[i]
		MineLayerArt.laid(self, m.pos, m.get("from", m.pos), g.time - float(m.get("t0", -99.0)), t, m.source.spec, Draw.ACCENT.mine_layer, fmod(t * 1.6 + float(i) * 0.37, 1.0) < 0.25)
	for e in ground:
		_enemy(e, t)
		_radar_marks(e)
		if e.soak_timer > 0.0:
			_soak_fx(e, t)
		if e.perm_slow > 0.0:
			Draw.ring(self, e.pos, e.radius + 3.0, Color(0.75, 0.92, 1.0, 0.35), 1.0)
	for p in g.projectiles:
		if p.alive:
			_projectile(p)
	for e in air:
		_enemy(e, t)
		_radar_marks(e)
	for tw in g.towers:
		if not tw.wing.is_empty() or tw.type == "cas_gunship":
			_wing(tw, t)
	var t2 := Time.get_ticks_usec()
	if timing_on:
		timing.enemies = int(timing.get("enemies", 0)) + t2 - t1
	for e in ground:
		_hp_bar(e)
	for e in air:
		_hp_bar(e)
	_boss_bar(g)
	if timing_on:
		timing.bars = int(timing.get("bars", 0)) + Time.get_ticks_usec() - t2
		timing.frames = int(timing.get("frames", 0)) + 1


## The living enemies in drawing order: [ground, sorted top to bottom; air, with bosses last so a Leviathan flies
## over the Locusts it launches].
static func draw_order(enemies: Array) -> Array:
	var ground: Array = []
	var air: Array = []
	var air_bosses: Array = []
	for e in enemies:
		if e.alive:
			(ground if not e.flying else (air_bosses if e.boss else air)).append(e)
	ground.sort_custom(func(a, b): return a.pos.y < b.pos.y)
	air.append_array(air_bosses)
	return [ground, air]


## The angle a tower is drawn at (it eases toward its target), so beams leave the part as drawn.
func aim_of(tw) -> float:
	return float(_aim.get(tw.get_instance_id(), tw.aim))


func _pool(pool, t: float) -> void:
	var r: float = pool.r
	var k := clampf(float(pool.t) / 0.6, 0.0, 1.0)
	var col := Color(0.55, 1.0, 0.3)
	Draw.disc(self, pool.pos, r, Color(0.15, 0.35, 0.05, 0.35 * k))
	Draw.disc(self, pool.pos, r * (0.7 + 0.08 * sin(t * 9.0)), Color(col, 0.18 * k))
	Draw.arc(self, pool.pos, r, 0.0, TAU, 32, Color(col, 0.6 * k), 1.5, true)
	for i in 4:
		var a := t * 1.5 + float(i) * 1.7
		Draw.disc(self, pool.pos + Vector2(cos(a), sin(a * 1.3)) * r * 0.5, 2.5, Color(col, 0.5 * k))


## What a Radar shows on an enemy: corner brackets while a cloaked one is revealed (gold while Total Exposure holds it), and a
## red cross on a hologram the Illusion Filter marked as a fake.
func _radar_marks(e) -> void:
	if e.cloaked and (e.reveal_timer > 0.0 or e.track_timer > 0.0):
		var col: Color = RadarTowerArt.GOLD if e.track_timer > 0.0 else Draw.ACCENT.radar_tower
		RadarTowerArt.reveal_mark(self, e.pos, e.radius + 4.0, col, minf(1.0, maxf(e.reveal_timer, e.track_timer) * 2.0))
	if e.fake_marked:
		var k: float = e.radius * 0.7
		Draw.line(self, e.pos + Vector2(-k, -k), e.pos + Vector2(k, k), FAKE_MARK, 2.0)
		Draw.line(self, e.pos + Vector2(-k, k), e.pos + Vector2(k, -k), FAKE_MARK, 2.0)


## A Mortar's Smoke Shell cloud (#85): drifting grey puffs over the area that slows, thinning out as it ends.
func _smoke(c, t: float) -> void:
	var r: float = c.r
	var k := clampf(float(c.t) / 0.8, 0.0, 1.0)
	var at: Vector2 = c.pos
	var seed_a := at.x * 0.13 + at.y * 0.07
	for i in 7:
		var a := seed_a + float(i) * TAU / 7.0 + t * 0.25
		var off := Vector2(cos(a), sin(a)) * r * (0.32 + 0.1 * sin(t * 0.9 + float(i)))
		var pr := r * (0.38 + 0.06 * sin(t * 1.3 + float(i) * 1.7))
		Draw.disc(self, at + off, pr, Color(0.7, 0.72, 0.74, 0.2 * k))
	Draw.disc(self, at, r * 0.45, Color(0.78, 0.8, 0.82, 0.22 * k))


func _enemy(e, t: float) -> void:
	var hidden: bool = e.is_hidden()
	# Its look reacts to the game (an EMP, a heal, a blink, its cloak...); a Mirage's hologram is a flickering copy,
	# a disguised Masquerade a Drone with a purple eye, and a burrowed Burrower shows only inside a Radar ping.
	var st := EnemyArt.state(e)
	if e.burrowed:
		st.pinged = world.game._radar_covers(e.pos)
	Draw.enemy(self, e.type, e.pos, e.facing, e.radius, t + float(e.id) * 0.37, e.slow_amount > 0.0, e.hit_flash, 1.0, hidden, st)
	if hidden or e.hologram:
		return
	var d: Dictionary = e.def
	if d.has("siphon_radius") and not e.silenced():
		Draw.arc(self, e.pos, float(d.siphon_radius), 0.0, TAU, 48, Color(SIPHON_COLOR, 0.14 + 0.06 * sin(t * 3.0)), 1.5, true)
	if e.elite:
		# An elite: a pulsing gold ring (its label sits over its health bar).
		Draw.ring(self, e.pos, e.radius + 4.0, Color(ELITE_COLOR, 0.55 + 0.25 * sin(t * 3.0 + float(e.id))), 1.6)
	if d.has("aura_radius"):
		Draw.arc(self, e.pos, float(d.aura_radius), 0.0, TAU, 48, Color(Draw.ENEMY_COLOR.rally, 0.16 + 0.08 * sin(t * 4.0)), 1.5, true)
	if d.has("regen_pct") and e.type != "mender" and e.since_hit >= float(d.regen_delay) and e.hp < e.max_hp:
		Draw.arc_segments(self, e.pos, e.radius + 5.0, 3, 0.8, t * 3.0, Color(Draw.ENEMY_COLOR.mender, 0.85), 1.6)
	if e.haste > 0.0:
		for k in 3:
			var off: Vector2 = e.facing.orthogonal() * (float(k) - 1.0) * e.radius * 0.5
			draw_line(e.pos - e.facing * e.radius * 1.2 + off, e.pos - e.facing * e.radius * 2.0 + off, Color(Draw.ENEMY_COLOR.rally, 0.6), 1.2, true)
	Draw.enemy_status(self, e, t)


## A Drone Bay's drones in flight, with a faint shadow below each.
func _wing(tw, t: float) -> void:
	var acc := Draw.accent(tw.type, tw.spec)
	if tw.type == "cas_gunship":
		if tw.plane_pos == Vector2.INF:
			return
		# The heading eases round, so the plane banks into a new course rather than snapping to it.
		var key: int = tw.get_instance_id()
		var hd := lerp_angle(float(_heading.get(key, tw.plane_heading)), tw.plane_heading, 0.12)
		_heading[key] = hd
		CasGunshipArt.plane(self, tw.plane_pos, hd, 1.0 if tw.size <= 1 else 1.8, t, tw.spec, acc, tw.fire_flash > 0.0 and tw.disabled <= 0.0)
		return
	if tw.disabled > 0.0:
		return
	for i in tw.wing.size():
		var dr: Dictionary = tw.wing[i]
		var tg = dr.target
		var face := -PI / 2.0
		if tg != null and tg.alive and tg.pos.distance_squared_to(dr.pos) > 1.0:
			face = (tg.pos - dr.pos).angle()
		var lift := sin(t * 5.0 + float(i)) * 1.5
		Draw.ellipse(self, dr.pos + Vector2(0, 9), 4.0, 1.6, Color(0, 0, 0, 0.22))
		DroneBayArt.drone(self, dr.pos + Vector2(0, lift), face, 1.25, t + float(i), tw.spec, acc)


## Turns each extra gun toward the enemy its shots go at (the main aim when it has none).
func _extra_aims(tw, key: int, main: float) -> Array:
	var aims: Array = _extra_aim.get(key, [main, main, main])
	for i in range(1, 3):
		var want := main
		if i < tw.shot_targets.size() and tw.shot_targets[i] != null and tw.shot_targets[i].alive:
			var mount := Vector2(1.0, -10.5 if i == 1 else 10.5)
			var mp: Vector2 = tw.pos + Vector2.from_angle(main) * mount.x + Vector2(-sin(main), cos(main)) * mount.y
			want = (tw.shot_targets[i].pos - mp).angle()
		aims[i] = lerp_angle(float(aims[i]), want, 0.3)
	_extra_aim[key] = aims
	return aims


func _projectile(p) -> void:
	if p.hold > 0.0:
		return
	match p.kind:
		"missile":
			# A finned missile with a red warhead, a flaring motor and a smoke trail.
			var d: Vector2 = p.vel.normalized() if p.vel.length_squared() > 1.0 else Vector2.RIGHT
			var n := d.orthogonal()
			for k in 4:
				var sp2: Vector2 = p.pos - d * (9.0 + 4.0 * float(k))
				Draw.disc(self, sp2, 1.5 + 0.8 * float(k), Color(0.6, 0.6, 0.65, 0.22 - 0.045 * float(k)))
			Draw.disc(self, p.pos - d * 6.5, 3.0, Color(1.0, 0.55, 0.2, 0.35))
			Draw.disc(self, p.pos - d * 6.0, 1.8, Color(1.0, 0.85, 0.5, 0.95))
			for sgn in [-1.0, 1.0]:
				Draw.poly(self, PackedVector2Array([p.pos - d * 2.5 + n * sgn * 1.4, p.pos - d * 5.5 + n * sgn * 3.6, p.pos - d * 5.5 + n * sgn * 1.4]), Color(0.45, 0.47, 0.52))
			draw_line(p.pos - d * 5.0, p.pos + d * 3.5, Draw.OUTLINE, 3.6, true)
			draw_line(p.pos - d * 5.0, p.pos + d * 3.5, Color(0.85, 0.88, 0.92), 2.4, true)
			Draw.disc(self, p.pos + d * 4.2, 1.5, Color(1.0, 0.3, 0.25))
		"gun_turret":
			_gun_round(p)
		"mortar_tower":
			_mortar_shell(p)
		"rocket_salvo":
			_salvo_rocket(p)
		"anti_aircraft_turret":
			_aa_round(p)
		"artillery_cannon":
			_artillery_shell(p)
		_:
			var d: Vector2 = (p.target_pos - p.pos).normalized()
			if d == Vector2.ZERO:
				d = Vector2.RIGHT
			var col := Color(1.0, 0.35, 0.35) if p.shred > 0.0 else Draw.ACCENT.gun_turret
			draw_line(p.pos - d * 14.0, p.pos, Color(col, 0.2), 6.0, true)
			draw_line(p.pos - d * 11.0, p.pos, Color(col, 0.5), 3.2, true)
			draw_line(p.pos - d * 8.0, p.pos, col, 1.8, true)
			Draw.disc(self, p.pos, 2.4, Color(col, 0.6))
			Draw.disc(self, p.pos, 1.5, Color(1, 1, 1))


## The Gun Turret's round (the confirmed art): a tracer (long from Range 2, orange with Incendiary Rounds, a gold streak at the
## Power mastery) and a bullet that hardens with each Power step: brass, a steel tip, a dark AP round with a yellow band, a
## white-hot tungsten core, and at the mastery a slim sabot dart.
func _gun_round(p) -> void:
	var lv := GunTurretArt.levels(str(p.look))
	var d: Vector2 = (p.target_pos - p.pos).normalized()
	if d == Vector2.ZERO:
		d = Vector2.RIGHT
	var col: Color = Color(1.0, 0.55, 0.2) if lv.r == 2 else Draw.ACCENT.gun_turret
	if p.crit:
		col = Draw.GOLD
	var back: float = clampf(p.traveled, 0.0, 6.0 if lv.R < 2 else 36.0)
	draw_line(p.pos - d * back, p.pos, Color(col, 0.3), 3.4, true)
	draw_line(p.pos - d * back, p.pos, Color(col, 0.95), 1.4, true)
	draw_line(p.pos - d * back * 0.9, p.pos, Color(1, 1, 1, 0.7), 0.5, true)
	if lv.P >= 5:
		draw_line(p.pos - d * minf(back, 12.0), p.pos, Color(Draw.GOLD, 0.8), 1.1, true)
	if lv.P < 1:
		return
	var a := d.angle()
	var o := d.orthogonal()
	if lv.P >= 5:
		Draw.poly(self, PackedVector2Array([p.pos + d * 3.0, p.pos - d * 2.6 + o * 0.35, p.pos - d * 2.6 - o * 0.35]), Color(0.88, 0.89, 0.92))
		return
	var body := Color(0.16, 0.15, 0.15) if lv.P >= 3 else Color(0.86, 0.68, 0.32)
	Draw.solid(self, p.pos, PackedVector2Array([Vector2(2.2, 0), Vector2(1.3, 0.6), Vector2(-1.8, 0.6), Vector2(-1.8, -0.6), Vector2(1.3, -0.6)]), body, a, 1.0, 0.6)
	if lv.P >= 2:
		Draw.poly(self, PackedVector2Array([p.pos + d * 2.2, p.pos + d * 1.1 + o * 0.6, p.pos + d * 1.1 - o * 0.6]), Color(0.66, 0.69, 0.74))
	if lv.P >= 3:
		draw_line(p.pos - d * 0.9 + o * 0.6, p.pos - d * 0.9 - o * 0.6, Color(1, 0.85, 0.2), 0.7, true)
	if lv.P >= 4:
		Draw.glow_dot(self, p.pos - d * 1.8, 0.45, Color(1, 0.95, 0.85))


## The Artillery Cannon's shell (the confirmed art): lobbed high, it changes with each Power step (bigger, dark with a yellow band, long
## and slim with a steel tip, gold at the mastery), and carries the mark of its type: an incendiary flame, shrapnel studs, concussion
## rings, or all three bands for the combined shell. A heavy round (Shell Magazine) is bigger with a red band.
func _artillery_shell(p) -> void:
	var lv := ArtilleryCannonArt.levels(str(p.look))
	var frac := clampf(p.traveled / maxf(p.total, 1.0), 0.0, 1.0)
	var h := ARTILLERY_ARC * Grid.TILE
	var heavy: bool = p.crit
	var z := (1.2 if lv.P >= 1 else 1.0) * (1.25 if lv.r == 2 else 1.0) * (1.35 if heavy else 1.0)
	var r := 2.6 * z
	Draw.ellipse(self, p.pos, 3.0 * z, 1.5 * z, Color(0, 0, 0, 0.3))
	# It leaves the muzzle along the barrel and is lobbed on an arc, pointing the way it flies (#90).
	var sp := lob_point(p.start, p.pos, frac, frac, h)
	var d := lob_heading(p.start, p.pos, frac, h)
	var o := d.orthogonal()
	var kind := String(p.shell)
	var tc: Color = ArtilleryCannonArt.TYPE_COLORS.get(kind, Color(1.0, 0.55, 0.2)) if kind != "he" else (Draw.GOLD if lv.P >= 5 else Color(1.0, 0.55, 0.2))
	if kind != "he" or lv.P >= 5:
		for k in 4:
			var f := frac - 0.035 * float(k + 1)
			if f <= 0.0:
				break
			Draw.disc(self, lob_point(p.start, p.pos, frac, f, h), (0.9 + float(k + 1) * 0.4) * z, Color(tc, 0.34 - 0.06 * float(k + 1)))
	var body := ArtilleryCannonArt.body_color(lv)
	# Long Penetrators make it a long slim round with a steel tip; its bands fit across that body.
	var long: bool = lv.P >= 4
	var half_w := r * 0.5 if long else r * 0.9
	if long:
		Draw.bar(self, sp - d * r * 1.9, sp + d * r * 0.9, r * 1.05, body)
		Draw.poly(self, PackedVector2Array([sp + d * r * 2.4, sp + d * r * 0.9 + o * r * 0.4, sp + d * r * 0.9 - o * r * 0.4]), ArtilleryCannonArt.STEEL)
	else:
		Draw.orb(self, sp, r, body)
	if lv.P >= 5:
		Draw.ring(self, sp, r * 0.55, Draw.GOLD, 0.8)
	if lv.P >= 3:
		draw_line(sp + o * half_w, sp - o * half_w, ArtilleryCannonArt.YEL, 1.0, true)
	if lv.P >= 2:
		for i in 3:
			draw_line(sp + Vector2.from_angle(float(i) * 1.05 + 0.5) * r * 0.3, sp + Vector2.from_angle(float(i) * 1.05 + 0.5) * r * 0.95, Color(0, 0, 0, 0.45), 0.6, true)
	if heavy:
		# A heavy round from the Shell Magazine: a red band toward its tail.
		var bp := sp - d * r * (1.2 if long else 0.45)
		var bw := r * 0.5 if long else r * 0.85
		draw_line(bp + o * bw, bp - o * bw, ArtilleryCannonArt.RED, 1.1, true)
	var imp := 1.5 if lv.X >= 4 else 1.0
	match kind:
		"incendiary":
			Draw.ring(self, sp, r * 0.8, ArtilleryCannonArt.FIRE, 0.9 * imp)
			Draw.disc(self, sp - d * r * 1.1, r * 0.5, Color(ArtilleryCannonArt.FIRE, 0.7))
		"shrapnel":
			for i in 6:
				draw_line(sp + Vector2.from_angle(float(i) * TAU / 6.0 + 0.3) * r * 0.95, sp + Vector2.from_angle(float(i) * TAU / 6.0 + 0.3) * r * (1.3 + 0.2 * (imp - 1.0)), ArtilleryCannonArt.SHRAP, 0.8, true)
		"concussion":
			Draw.ring(self, sp, r * 1.15, Color(ArtilleryCannonArt.CONC, 0.8), 0.8 * imp)
			Draw.ring(self, sp, r * 1.5, Color(ArtilleryCannonArt.CONC, 0.4), 0.7)
		"combined":
			Draw.ring(self, sp, r * 0.45, ArtilleryCannonArt.FIRE, 0.8)
			Draw.ring(self, sp, r * 0.75, ArtilleryCannonArt.SHRAP, 0.8)
			Draw.ring(self, sp, r * 1.05, ArtilleryCannonArt.CONC, 0.8)
	Draw.glow_dot(self, sp, 1.1, tc)


## The Anti-Aircraft Turret's round (the confirmed art): a tracer (thinner and longer with High-Velocity Rounds) and a brass bullet that
## becomes a dark flak shell from Flak Rounds, bigger at Flak Shells, with an orange fuse ring.
func _aa_round(p) -> void:
	var lv := AntiAircraftArt.levels(str(p.look))
	var d: Vector2 = (p.target_pos - p.pos).normalized()
	if d == Vector2.ZERO:
		d = Vector2.RIGHT
	var col: Color = Draw.ACCENT.anti_aircraft_turret
	var back: float = clampf(p.traveled, 0.0, 36.0 if lv.R >= 4 else 18.0)
	var w := 1.4 if lv.R >= 4 else 1.8
	draw_line(p.pos - d * back, p.pos, Color(col, 0.3), w * 2.0, true)
	draw_line(p.pos - d * back, p.pos, Color(col, 0.95), w * 0.8, true)
	draw_line(p.pos - d * back * 0.9, p.pos, Color(1, 1, 1, 0.7), 0.5, true)
	if lv.P >= 2:
		var r := 1.6 if lv.P >= 3 else 1.25
		Draw.disc(self, p.pos, r + 0.4, Draw.OUTLINE)
		Draw.disc(self, p.pos, r, AntiAircraftArt.DARKR)
		Draw.ring(self, p.pos, r * 0.7, AntiAircraftArt.ORANGE, 0.5)
	elif lv.R >= 1:
		Draw.solid(self, p.pos, PackedVector2Array([Vector2(2.2, 0), Vector2(1.3, 0.6), Vector2(-1.8, 0.6), Vector2(-1.8, -0.6), Vector2(1.3, -0.6)]), AntiAircraftArt.BRASS, d.angle(), 1.0, 0.6)


## A Rocket Salvo rocket (the confirmed art): a finned rocket whose warhead changes with each Power step (red, orange-banded,
## yellow-banded dark AP, gold), seeker blue from Seeker Heads, a booster stage shed early with Booster Stage, grey trails
## with Smoke Trails, longer with Long Burn. A rocket still waiting in its tube isn't drawn.
func _salvo_rocket(p) -> void:
	if p.hold > 0.0:
		return
	var lv := RocketSalvoArt.levels(str(p.look))
	var d: Vector2 = p.vel.normalized() if p.vel.length_squared() > 1.0 else Vector2.RIGHT
	var o := d.orthogonal()
	var z := 1.2 if lv.P >= 3 else 1.0
	var smoky: bool = lv.r == 1
	var trail := 10 if lv.R >= 4 else 6
	for i in trail:
		Draw.disc(self, p.pos - d * (3.0 + float(i) * 2.6) * z, (1.2 + float(i) * 0.55) * (1.4 if smoky else 1.0), Color(0.42, 0.43, 0.45, 0.5 - float(i) * 0.04) if smoky else Color(0.62, 0.64, 0.66, 0.34 - float(i) * 0.045))
	var a := d.angle()
	if lv.R >= 1 and p.traveled < 80.0:
		Draw.solid(self, p.pos - d * 6.0 * z, PackedVector2Array([Vector2(1.6, 1.1), Vector2(-2.4, 1.1), Vector2(-2.4, -1.1), Vector2(1.6, -1.1)]), RocketSalvoArt.STEEL, a, z, 0.6)
	for sg in [-1.0, 1.0]:
		Draw.poly(self, PackedVector2Array([p.pos + (d * -1.5 + o * sg * 1.1) * z, p.pos + (d * -4.2 + o * sg * 2.8) * z, p.pos + (d * -4.6 + o * sg * 2.8) * z, p.pos + (d * -4.2 + o * sg * 1.1) * z]), RocketSalvoArt.STEEL if lv.P >= 2 else Draw.METAL_L)
	var body: Color = RocketSalvoArt.DARKR if lv.P >= 4 else RocketSalvoArt.PALE
	Draw.solid(self, p.pos, PackedVector2Array([Vector2(4.6, 0), Vector2(2.7, 1.35), Vector2(-4.2, 1.35), Vector2(-4.2, -1.35), Vector2(2.7, -1.35)]), body, a, z, 0.8)
	var nose: Color = RocketSalvoArt.SEEK if lv.R >= 2 else (Draw.GOLD if lv.P >= 5 else (RocketSalvoArt.ORANGE if lv.P >= 2 else RocketSalvoArt.RED))
	Draw.poly(self, PackedVector2Array([p.pos + d * (5.6 if lv.P >= 1 else 4.6) * z, p.pos + (d * 2.9 + o * 1.35) * z, p.pos + (d * 2.9 - o * 1.35) * z]), nose)
	if lv.P >= 4:
		draw_line(p.pos - d * 1.2 * z + o * 1.35 * z, p.pos - d * 1.2 * z - o * 1.35 * z, RocketSalvoArt.YEL, 0.7, true)
	if lv.r == 2:
		draw_line(p.pos + d * 0.6 * z + o * 1.35 * z, p.pos + d * 0.6 * z - o * 1.35 * z, RocketSalvoArt.ORANGE, 0.8, true)
	Draw.glow_dot(self, p.pos - d * 5.0 * z, 1.2 * z, Color(1.0, 0.7, 0.35))


## A soaked enemy (Chemical Plant): a pool of the plant's acid under it, dripping and fizzing; armour flakes fall from it (Corrosive Acid),
## gel coats it with the Slowing path.
func _soak_fx(e, t: float) -> void:
	var src = e.soak_source
	var lv := ChemicalPlantArt.levels(str(src.spec)) if src != null else {"r": -1, "A": 0, "S": 0, "G": 0}
	var ac := ChemicalPlantArt.acid_color(lv, Draw.ACCENT.chemical_plant)
	var a := minf(1.0, e.soak_timer * 3.0)
	var p: Vector2 = e.pos
	Draw.disc(self, p, 14.0, Color(ac, 0.3 * a))
	for i in 2:
		var d := fmod(t * 1.5 + float(i) * 0.5 + float(e.id) * 0.3, 1.0)
		Draw.disc(self, p + Vector2((float(i) - 0.5) * 10.0, d * 18.0), 1.2, Color(ac, (1.0 - d) * a))
	for i in 3 + (2 if lv.A >= 2 else 0):
		var b := fmod(t * 2.0 + float(i) * 0.33 + float(e.id), 1.0)
		Draw.ring(self, p + Vector2((sin(float(i) * 2.1 + float(e.id)) * 9.0), -b * 15.0), 1.0 + b * 1.5, Color(ac.lightened(0.4), (1.0 - b) * a), 0.8)
	if lv.G >= 1:
		Draw.arc(self, p, e.radius + 1.0, PI * 1.1, PI * 1.9, 8, Color(ChemicalPlantArt.GELC, (0.5 + 0.1 * float(lv.G)) * a), 2.0 + float(lv.G) * 0.8)


## The Mortar Tower's shell (the confirmed art, #90): lobbed on an arc and pointing along it, with a faint trail that follows
## the arc. Each Power step changes it (bigger, a steel nose, dark with a yellow band, a blinking fuse, fins and a gold ring at
## the mastery); bigger with Fat Shells, scored with Fragmentation Sleeves, gold at the Blast mastery, banded grey with Smoke Shells.
func _mortar_shell(p) -> void:
	var lv := MortarTowerArt.levels(str(p.look))
	var frac := clampf(p.traveled / maxf(p.total, 1.0), 0.0, 1.0)
	var h := MORTAR_ARC * Grid.TILE
	var sp := lob_point(p.start, p.pos, frac, frac, h)
	var d := lob_heading(p.start, p.pos, frac, h)
	var o := d.orthogonal()
	var a := d.angle()
	var z := (1.2 if lv.P >= 1 else 1.0) * (1.2 if lv.B >= 1 else 1.0)
	var r := 2.6 * z
	Draw.ellipse(self, p.pos, 3.0 * z, 1.5 * z, Color(0, 0, 0, 0.3))
	# A faint trail along the arc it has flown.
	for k in 4:
		var f := frac - (4.0 + 3.5 * float(k)) / maxf(p.total, 1.0)
		if f <= 0.0:
			break
		Draw.disc(self, lob_point(p.start, p.pos, frac, f, h), 2.4 - 0.45 * float(k), Color(1.0, 0.55, 0.2, 0.28 - 0.06 * float(k)))
	var body: Color = Draw.GOLD if lv.B >= 5 else (MortarTowerArt.SMOKE if p.smoke else (MortarTowerArt.DARKSHELL if lv.P >= 3 else Draw.METAL_L))
	if lv.P >= 5:
		for sg in [-1.0, 1.0]:
			Draw.poly(self, Draw.xform(sp, PackedVector2Array([Vector2(-0.6, sg * 0.8), Vector2(-1.8, sg * 1.8), Vector2(-1.8, sg * 0.8)]), a, z), MortarTowerArt.STEEL)
	if lv.P >= 2:
		Draw.poly(self, Draw.xform(sp + d * r * 0.7, PackedVector2Array([Vector2(1.6, 0), Vector2(0, 1), Vector2(0, -1)]), a, z), MortarTowerArt.STEEL)
	Draw.orb(self, sp, r, body)
	if lv.P >= 3:
		Draw.line(self, sp + o * r * 0.9, sp - o * r * 0.9, Color(0.4, 0.4, 0.4) if p.smoke else MortarTowerArt.YEL, 0.9, true)
	if lv.P >= 5:
		Draw.ring(self, sp, r * 0.55, Draw.GOLD, 0.8)
	if lv.r == 2:
		Draw.ring(self, sp, r * 0.85, Color(0.42, 0.42, 0.44), 0.9)
	if lv.B >= 2:
		for i in 3:
			Draw.line(self, sp + Vector2.from_angle(float(i) * 1.05 + 0.5) * r * 0.3, sp + Vector2.from_angle(float(i) * 1.05 + 0.5) * r * 0.95, Color(0, 0, 0, 0.45), 0.6, true)
	var blink := fmod(frac * 8.0, 1.0) < 0.5 if lv.P >= 4 else true
	Draw.glow_dot(self, sp, 1.1, Color(1.0, 0.55, 0.2) if blink else Color(1.0, 0.55, 0.2, 0.3))


## Where a lobbed shell is drawn at fraction `f` of its flight (0 at `start`, `frac` where its ground point `pos` is now): along
## the ground from start through pos, lifted on an arc `h` px high at the middle.
static func lob_point(start: Vector2, pos: Vector2, frac: float, f: float, h: float) -> Vector2:
	var ground := start + (pos - start) * (f / frac) if frac > 0.001 else start
	return ground - Vector2(0, sin(f * PI) * h)


## Which way a lobbed shell is heading on screen (up the arc, then down it), for its nose and bands.
static func lob_heading(start: Vector2, pos: Vector2, frac: float, h: float) -> Vector2:
	var ahead := lob_point(start, pos, frac, frac, h)
	var behind := lob_point(start, pos, frac, maxf(0.0, frac - 0.03), h)
	if ahead.distance_squared_to(behind) > 0.0001:
		return (ahead - behind).normalized()
	var flat := pos - start
	return flat.normalized() if flat.length_squared() > 0.0001 else Vector2.RIGHT


func _hp_bar(e) -> void:
	if e.boss or e.is_hidden():
		return
	var w: float = e.radius * 2.0 + 6.0
	var p := Vector2(e.pos.x - w / 2.0, e.pos.y - e.radius - (14.0 if e.flying else 9.0))
	if e.elite:
		# The elite's label: its modifiers, over the bar.
		var lw := 120.0
		var lp := Vector2(e.pos.x - lw / 2.0, p.y - (7.0 if e.max_shield > 0.0 else 3.0))
		draw_string_outline(_font, lp, e.elite_label, HORIZONTAL_ALIGNMENT_CENTER, lw, 9, 3, Color(0, 0, 0, 0.85))
		draw_string(_font, lp, e.elite_label, HORIZONTAL_ALIGNMENT_CENTER, lw, 9, ELITE_COLOR)
	var shielded: bool = e.max_shield > 0.0 and e.shield < e.max_shield
	if e.hp >= e.max_hp and not shielded:
		return
	var f := clampf(e.hp / e.max_hp, 0.0, 1.0)
	draw_rect(Rect2(p - Vector2(1, 1), Vector2(w + 2, 5)), Color(0, 0, 0, 0.8))
	draw_rect(Rect2(p, Vector2(w * f, 3)), Color(1.0, 0.25, 0.3).lerp(Color(0.3, 0.95, 1.0), f))
	if e.max_shield > 0.0:
		var sf := clampf(e.shield / e.max_shield, 0.0, 1.0)
		draw_rect(Rect2(p - Vector2(1, 5), Vector2(w + 2, 4)), Color(0, 0, 0, 0.8))
		draw_rect(Rect2(p - Vector2(0, 4), Vector2(w * sf, 2)), Color(0.5, 0.8, 1.0))


func _boss_bar(g) -> void:
	var boss = null
	for e in g.enemies:
		if e.alive and e.boss and (boss == null or e.hp > boss.hp):
			boss = e
	if boss == null:
		return
	var w := 420.0
	var p := Vector2((Grid.field_size().x - w) / 2.0, 10.0)
	var f := clampf(boss.hp / boss.max_hp, 0.0, 1.0)
	var glow: Color = Draw.ENEMY_COLOR.get(boss.type, Color(1, 0.3, 0.3))
	draw_rect(Rect2(p - Vector2(3, 3), Vector2(w + 6, 22)), Color(0, 0, 0, 0.75))
	draw_rect(Rect2(p - Vector2(3, 3), Vector2(w + 6, 22)), Color(glow, 0.6), false, 1.0)
	draw_rect(Rect2(p, Vector2(w, 16)), Color(glow.darkened(0.8), 0.9))
	draw_rect(Rect2(p, Vector2(w * f, 16)), Color(glow, 0.85))
	draw_rect(Rect2(p, Vector2(w * f, 4)), Color(1, 1, 1, 0.35))
	for i in range(1, 10):
		draw_line(p + Vector2(w * i / 10.0, 0), p + Vector2(w * i / 10.0, 16), Color(0, 0, 0, 0.4), 1.0)
	var label := "%s   %d / %d" % [str(boss.def.name).to_upper(), ceili(boss.hp), ceili(boss.max_hp)]
	draw_string_outline(_font, p + Vector2(0, 13), label, HORIZONTAL_ALIGNMENT_CENTER, w, 13, 4, Color(0, 0, 0, 0.9))
	draw_string(_font, p + Vector2(0, 13), label, HORIZONTAL_ALIGNMENT_CENTER, w, 13, Color(1, 0.95, 0.95))
	Draw.arc(self, boss.pos, boss.radius + 7.0 + sin(world.anim_t * 6.0) * 2.0, 0.0, TAU, 36, Color(glow, 0.7), 2.0, true)
