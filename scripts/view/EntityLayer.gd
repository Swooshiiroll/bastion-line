extends Node2D
## Draws everything that moves: plasma pools, towers (with smoothed aim), enemies, projectiles,
## status markers, HP bars and the boss bar.

const Draw = preload("res://scripts/view/Draw.gd")
const Grid = preload("res://scripts/core/Grid.gd")

var world
## Microseconds spent per section of _draw, summed; tools/PerfProbe.gd reads and resets it.
static var timing := {}
static var timing_on := false
var _aim := {}
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
	# Turrets' static layers come from Draw's sprite cache here (see Draw.dyn).
	var t0 := Time.get_ticks_usec()
	Draw.turret_cache = true
	for tw in g.towers:
		var key: int = tw.get_instance_id()
		var cur: float = _aim.get(key, -PI / 2.0)
		if tw.target != null and tw.target.alive:
			cur = lerp_angle(cur, (tw.target.pos - tw.pos).angle(), 0.35)
		_aim[key] = cur
		Draw.tower(self, tw.type, tw.tier, tw.pos, cur, 1.0 if tw.size <= 1 else 1.8, t + float(tw.cell.x) * 0.3, tw.fire_flash, tw.spec, tw.shown_spec)
		if tw.disabled > 0.0:
			Draw.tower_offline(self, tw.pos, t)
		if tw.buff_dmg > 0.0:
			Draw.disc(self, tw.pos + Vector2(14, -14), 3.0, Draw.OUTLINE)
			Draw.disc(self, tw.pos + Vector2(14, -14), 2.2, Draw.ACCENT.amp)
	Draw.turret_cache = false
	var t1 := Time.get_ticks_usec()
	if timing_on:
		timing.towers = int(timing.get("towers", 0)) + t1 - t0

	var ground: Array = []
	var air: Array = []
	for e in g.enemies:
		if e.alive:
			(air if e.flying else ground).append(e)
	ground.sort_custom(func(a, b): return a.pos.y < b.pos.y)
	for e in ground:
		_enemy(e, t)
	for p in g.projectiles:
		if p.alive:
			_projectile(p)
	for e in air:
		_enemy(e, t)
	for tw in g.towers:
		if not tw.wing.is_empty():
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


func _enemy(e, t: float) -> void:
	var hidden: bool = e.is_hidden()
	Draw.enemy(self, e.type, e.pos, e.facing, e.radius, t + float(e.id) * 0.37, e.slow_amount > 0.0, e.hit_flash, 1.0, hidden)
	if hidden:
		return
	var d: Dictionary = e.def
	if d.has("aura_radius"):
		Draw.arc(self, e.pos, float(d.aura_radius), 0.0, TAU, 48, Color(Draw.ENEMY_COLOR.rally, 0.16 + 0.08 * sin(t * 4.0)), 1.5, true)
	if d.has("regen_pct") and e.since_hit >= float(d.regen_delay) and e.hp < e.max_hp:
		Draw.arc_segments(self, e.pos, e.radius + 5.0, 3, 0.8, t * 3.0, Color(Draw.ENEMY_COLOR.mender, 0.85), 1.6)
	if e.haste > 0.0:
		for k in 3:
			var off: Vector2 = e.facing.orthogonal() * (float(k) - 1.0) * e.radius * 0.5
			draw_line(e.pos - e.facing * e.radius * 1.2 + off, e.pos - e.facing * e.radius * 2.0 + off, Color(Draw.ENEMY_COLOR.rally, 0.6), 1.2, true)
	Draw.enemy_status(self, e, t)


## A Drone Bay's drones in flight, with a faint shadow below each.
func _wing(tw, t: float) -> void:
	var acc := Draw.accent(tw.type, tw.spec)
	for i in tw.wing.size():
		var d: Dictionary = tw.wing[i]
		var p: Vector2 = d.pos
		var facing := Vector2.UP
		var tg = d.target
		if tg != null and tg.alive and tg.pos.distance_squared_to(p) > 1.0:
			facing = (tg.pos - p).normalized()
		var bob := sin(t * 5.0 + float(i)) * 1.5
		Draw.ellipse(self, p + Vector2(0, 9), 4.0, 1.6, Color(0, 0, 0, 0.22))
		Draw.drone(self, p + Vector2(0, bob), facing, 1.25, t + float(i), tw.spec, acc, d.kind == "bomber")

func _projectile(p) -> void:
	match p.kind:
		"cannon":
			# A plasma shell arcing up and down: ground shadow, a glowing trail behind it.
			var frac := clampf(p.traveled / p.total, 0.0, 1.0)
			var lift := sin(frac * PI) * minf(34.0, p.total * 0.22)
			Draw.ellipse(self, p.pos + Vector2(0, 3), 4.0 + 2.0 * (1.0 - lift / 34.0), 2.0, Color(0, 0, 0, 0.3))
			var sp: Vector2 = p.pos - Vector2(0, lift)
			var col := Color(0.55, 1.0, 0.3) if p.burn_dps > 0.0 else Color(1.0, 0.55, 0.2)
			var back: Vector2 = (p.start - p.pos).normalized() if p.start.distance_squared_to(p.pos) > 1.0 else Vector2.LEFT
			for k in 4:
				var tp: Vector2 = sp + back * (4.0 + 3.5 * float(k)) + Vector2(0, float(k) * 1.5)
				Draw.disc(self, tp, 3.4 - 0.7 * float(k), Color(col, 0.35 - 0.08 * float(k)))
			Draw.disc(self, sp, 7.0, Color(col, 0.22))
			Draw.disc(self, sp, 4.8, Draw.OUTLINE)
			Draw.disc(self, sp, 4.2, col)
			Draw.disc(self, sp + Vector2(-1.2, -1.2), 1.8, Color(1, 1, 0.9))
		"flak":
			var fd: Vector2 = (p.target_pos - p.pos).normalized()
			if fd == Vector2.ZERO:
				fd = Vector2.RIGHT
			draw_line(p.pos - fd * 10.0, p.pos, Color(Draw.ACCENT.flak, 0.3), 4.0, true)
			draw_line(p.pos - fd * 6.0, p.pos, Color(1.0, 0.9, 0.6, 0.6), 1.4, true)
			Draw.disc(self, p.pos, 3.0, Draw.OUTLINE)
			Draw.disc(self, p.pos, 2.3, Color(0.8, 0.75, 0.5))
			Draw.disc(self, p.pos + fd * 0.8, 1.1, Color(1.0, 0.4, 0.3))
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
		_:
			var d: Vector2 = (p.target_pos - p.pos).normalized()
			if d == Vector2.ZERO:
				d = Vector2.RIGHT
			var col := Color(1.0, 0.35, 0.35) if p.shred > 0.0 else Draw.ACCENT.arrow
			draw_line(p.pos - d * 14.0, p.pos, Color(col, 0.2), 6.0, true)
			draw_line(p.pos - d * 11.0, p.pos, Color(col, 0.5), 3.2, true)
			draw_line(p.pos - d * 8.0, p.pos, col, 1.8, true)
			Draw.disc(self, p.pos, 2.4, Color(col, 0.6))
			Draw.disc(self, p.pos, 1.5, Color(1, 1, 1))


func _hp_bar(e) -> void:
	if e.boss or e.is_hidden():
		return
	var shielded: bool = e.max_shield > 0.0 and e.shield < e.max_shield
	if e.hp >= e.max_hp and not shielded:
		return
	var w: float = e.radius * 2.0 + 6.0
	var p := Vector2(e.pos.x - w / 2.0, e.pos.y - e.radius - (14.0 if e.flying else 9.0))
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
