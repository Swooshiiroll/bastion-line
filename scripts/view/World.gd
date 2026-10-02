extends Node2D
## Puts one running Game on screen: fixed-step ticking, draw layers, visual effects from sim events,
## screen shake and mouse interaction with the field. Also used (non-interactive) as the menu backdrop.
## Layer order: terrain, lane lights (additive), ground fx (smoke, scorch), entities, beams (additive),
## fx (additive glow), overlay.

const Game = preload("res://scripts/core/Game.gd")
const Grid = preload("res://scripts/core/Grid.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const Terrain = preload("res://scripts/view/Terrain.gd")
const TerrainCache = preload("res://scripts/view/TerrainCache.gd")
const LaneFx = preload("res://scripts/view/LaneFx.gd")
const Scenery = preload("res://scripts/view/Scenery.gd")
const EntityLayer = preload("res://scripts/view/EntityLayer.gd")
const BeamLayer = preload("res://scripts/view/BeamLayer.gd")
const FxLayer = preload("res://scripts/view/FxLayer.gd")
const Overlay = preload("res://scripts/view/Overlay.gd")

const MAX_STEPS_PER_FRAME := 40
const SMOKE := Color(0.35, 0.36, 0.4, 0.7)

signal field_clicked(cell: Vector2i, button: int, shift: bool, pos: Vector2)

var game
var terrain
var lane_fx
var scenery
var ground_fx
var entities
var beams
var fx
var overlay

var base_pos := Vector2(0, 48)
## Battlefield zoom (1x shows the whole field) and pan. The zoomed field always fills its window.
const ZOOM_MIN := 1.0
const ZOOM_MAX := 2.5
const ZOOM_STEP := 1.15
const PAN_SPEED := 700.0
var zoom := 1.0
var pan := Vector2.ZERO
## Arrow-key panning; the game screen turns it off while a menu owns the keys.
var keys_enabled := true
var _dragging := false
var _drag_last := Vector2.ZERO
var _last_mouse: InputEvent = null
var interactive := true
var damage_numbers := true
var build_type := ""
var ability_target := ""
var selected_tower = null
var hover_cell := Vector2i(-1, -1)
var hover_pos := Vector2(-1000, -1000)
var hover_enemy = null
var mouse_in_field := false
var force_hover := Vector2i(-99, -99)
var anim_t := 0.0
var shake := 0.0
var _accum := 0.0
## Mouse position in field coordinates, tracked from motion events (works for any input source).
var _mouse := Vector2(-1000, -1000)


## `clip`: only this cell rectangle of the map is shown (the upgrade preview), so only it is baked.
func setup(g, clip := Rect2i()) -> void:
	game = g
	position = base_pos
	for child in get_children():
		child.queue_free()
	terrain = TerrainCache.new()
	terrain.grid = g.grid
	terrain.cleared = g.cleared
	terrain.clip = clip
	add_child(terrain)
	lane_fx = LaneFx.new()
	lane_fx.grid = g.grid
	lane_fx.game = g
	add_child(lane_fx)
	scenery = Scenery.new()
	scenery.world = self
	add_child(scenery)
	ground_fx = FxLayer.new()
	add_child(ground_fx)
	entities = EntityLayer.new()
	entities.world = self
	add_child(entities)
	beams = BeamLayer.new()
	beams.world = self
	add_child(beams)
	fx = FxLayer.new()
	var glow := CanvasItemMaterial.new()
	glow.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	fx.material = glow
	add_child(fx)
	overlay = Overlay.new()
	overlay.world = self
	add_child(overlay)
	_accum = 0.0
	selected_tower = null
	build_type = ""
	ability_target = ""


## Advances the simulation by real time `delta` at the given speed and returns the drained events.
func simulate(delta: float, speed: int) -> Array:
	_accum += delta * float(speed)
	var steps := 0
	while _accum >= Game.TICK:
		_accum -= Game.TICK
		game.tick(Game.TICK)
		steps += 1
		if steps >= MAX_STEPS_PER_FRAME:
			_accum = 0.0
			break
	var evs: Array = game.events
	game.events = []
	for ev in evs:
		_visual(ev)
	return evs


func _process(delta: float) -> void:
	anim_t += delta
	if game == null:
		return
	if interactive:
		if _last_mouse != null:
			_mouse = make_input_local(_last_mouse).position
		if keys_enabled:
			var dir := Vector2(float(Input.is_key_pressed(KEY_LEFT)) - float(Input.is_key_pressed(KEY_RIGHT)), float(Input.is_key_pressed(KEY_UP)) - float(Input.is_key_pressed(KEY_DOWN)))
			if dir != Vector2.ZERO:
				set_pan(pan + dir * PAN_SPEED * delta)
		var m := _mouse
		mouse_in_field = Rect2(Vector2.ZERO, Grid.field_size()).has_point(m) and not _over_ui()
		hover_pos = m
		hover_cell = Grid.world_to_cell(m) if mouse_in_field else Vector2i(-1, -1)
		hover_enemy = null
		if mouse_in_field:
			var best := 26.0 * 26.0
			for e in game.enemies:
				var d2: float = e.pos.distance_squared_to(m)
				var r: float = e.radius + 6.0
				if e.alive and not e.is_hidden() and d2 <= r * r and d2 < best:
					best = d2
					hover_enemy = e
	if force_hover.x > -99:
		mouse_in_field = true
		hover_cell = force_hover
		hover_pos = Grid.cell_center(force_hover)
	if selected_tower != null and not game.towers.has(selected_tower):
		selected_tower = null
	for p in game.projectiles:
		if p.alive and p.kind == "missile" and randf() < 0.7:
			ground_fx.burst(p.pos, Color(0.5, 0.5, 0.55, 0.5), 1, 12.0, 2.6, 0.5)
			fx.burst(p.pos, Color(1.0, 0.6, 0.25), 1, 20.0, 1.6, 0.18)
	if shake > 0.0:
		shake = maxf(0.0, shake - delta * 2.5)
		position = base_pos + pan + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 7.0 * float(bool(SaveManager.setting("screen_shake")))
	else:
		position = base_pos + pan
	scale = Vector2(zoom, zoom)
	entities.queue_redraw()
	overlay.refresh()


## Zooms by `factor` keeping the field point `at` (field coordinates) under the cursor.
func zoom_at(at: Vector2, factor: float) -> void:
	var screen_p := pan + at * zoom
	zoom = clampf(zoom * factor, ZOOM_MIN, ZOOM_MAX)
	set_pan(screen_p - at * zoom)


## Pans, keeping the zoomed field covering its whole window.
func set_pan(p: Vector2) -> void:
	var f := Grid.field_size()
	pan = Vector2(clampf(p.x, f.x * (1.0 - zoom), 0.0), clampf(p.y, f.y * (1.0 - zoom), 0.0))


func reset_view() -> void:
	zoom = 1.0
	pan = Vector2.ZERO

## Where a tower of `type` would go for a cursor at `p` (field coordinates) over `cell`: that tile, or
## for a 2x2 tower the top-left tile of the block centred on the cursor.
static func anchor_for(type: String, cell: Vector2i, p: Vector2) -> Vector2i:
	if type == "" or Game.size_of(type) == 1:
		return cell
	return Grid.world_to_cell(p - Vector2.ONE * Grid.TILE * 0.5)


## The anchor the build ghost is showing.
func build_anchor() -> Vector2i:
	return anchor_for(build_type, hover_cell, hover_pos)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		_last_mouse = event
		_mouse = make_input_local(event).position
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE and not event.pressed:
		_dragging = false
	if event is InputEventMouseMotion and _dragging:
		set_pan(pan + (event.position - _drag_last))
		_drag_last = event.position


func _unhandled_input(event: InputEvent) -> void:
	if not interactive or game == null:
		return
	if event is InputEventMouseButton and event.pressed:
		var m: Vector2 = make_input_local(event).position
		if not Rect2(Vector2.ZERO, Grid.field_size()).has_point(m):
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Menus (pause, research, Codex, tree) and HUD panels keep the wheel to themselves.
			if not keys_enabled or _over_ui():
				return
			zoom_at(m, ZOOM_STEP if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / ZOOM_STEP)
			get_viewport().set_input_as_handled()
			return
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			_dragging = true
			_drag_last = event.position
			get_viewport().set_input_as_handled()
			return
		field_clicked.emit(Grid.world_to_cell(m), event.button_index, event.shift_pressed, m)
		get_viewport().set_input_as_handled()


func _visual(ev: Dictionary) -> void:
	var acc := Draw.accent(str(ev.get("tower", "")), str(ev.get("spec", "")))
	match ev.type:
		"fire":
			match ev.tower:
				"cannon":
					fx.flash(ev.pos, 12.0, acc, 0.1)
					ground_fx.burst(ev.pos, SMOKE, 5, 40.0, 3.0, 0.5)
				"missile":
					fx.flash(ev.pos, 10.0, Color(1.0, 0.7, 0.3), 0.12)
					ground_fx.burst(ev.pos, SMOKE, 6, 50.0, 3.5, 0.7)
				_:
					fx.flash(ev.pos, 6.0, acc, 0.06)
		"arrow_hit":
			fx.burst(ev.pos, Color(1.0, 0.35, 0.35) if ev.get("shred", false) else Draw.ACCENT.arrow, 4, 60.0, 1.6, 0.25)
		"splash":
			var col := Color(0.55, 1.0, 0.3) if ev.get("burn", false) else Color(1.0, 0.55, 0.2)
			fx.ring(ev.pos, 6.0, ev.radius, col, 0.35, 3.0, true)
			fx.burst(ev.pos, col, 16, 150.0, 3.0, 0.45)
			ground_fx.burst(ev.pos, SMOKE, 8, 60.0, 4.0, 0.8)
			fx.flash(ev.pos, 20.0, col, 0.12)
			ground_fx.scorch(ev.pos, float(ev.radius) * 0.45)
			if ev.get("stun", false):
				fx.ring(ev.pos, float(ev.radius) * 0.5, float(ev.radius) * 1.15, Color(1.0, 0.92, 0.35), 0.4, 2.5)
			shake = maxf(shake, 0.06)
		"missile_hit":
			fx.flash(ev.pos, 14.0, Color(1.0, 0.7, 0.3), 0.1)
			fx.burst(ev.pos, Color(1.0, 0.6, 0.25), 10, 110.0, 2.4, 0.35)
			fx.ring(ev.pos, 4.0, ev.radius, Color(1.0, 0.75, 0.35), 0.25, 2.0)
		"chain":
			var ccol := Draw.ACCENT.tesla if str(ev.get("spec", "")) != "overload" else Draw.SPEC_ALT.overload
			fx.bolt(ev.points, ccol, 2.0 + float(ev.tier) * 0.5, 0.2)
			for p in ev.points:
				fx.flash(p, 7.0, ccol, 0.12)
		"tracer":
			var rcol := Draw.SPEC_ALT.lance if str(ev.get("spec", "")) == "lance" else Draw.ACCENT.sniper
			var tw := 3.0 + maxf(0.0, float(ev.get("width", 10.0)) - 10.0) * 0.45
			# The slug keeps going past what it hits, off the edge of the screen (visual only).
			var shot: Vector2 = ev.to - ev.from
			var far: Vector2 = ev.to if shot.length_squared() < 1.0 else ev.from + shot.normalized() * 4000.0
			if tw > 3.0:
				fx.tracer(ev.from, far, Color(rcol, 0.35), 0.3, tw * 2.2)
			fx.tracer(ev.from, far, rcol, 0.22, tw)
			fx.flash(ev.to, 9.0, rcol, 0.1)
			fx.flash(ev.from, 8.0, Color(1, 1, 1), 0.06)
		"frost":
			var fcol := Draw.SPEC_ALT.shatter if str(ev.get("spec", "")) == "shatter" else Draw.ACCENT.frost
			fx.ring(ev.pos, 12.0, ev.radius, fcol, 0.45, 2.0, true)
			fx.burst(ev.pos, fcol, 6, 70.0, 2.0, 0.5)
		"rubble_cleared":
			terrain.refresh()
			ground_fx.burst(ev.pos, Color(0.45, 0.4, 0.35, 0.9), 18, 90.0, 3.5, 0.7)
			fx.ring(ev.pos, 6.0, 30.0, Color(1.0, 0.8, 0.4), 0.3, 2.0)
		"gate":
			fx.ring(ev.pos, 8.0, 34.0, Color(1.0, 0.8, 0.35), 0.35, 2.5)
			fx.flash(ev.pos, 14.0, Color(1.0, 0.8, 0.35), 0.12)
		"flak_hit":
			fx.flash(ev.pos, 12.0, Color(1.0, 0.9, 0.6), 0.08)
			fx.burst(ev.pos, Color(0.35, 0.36, 0.34, 0.9), 8, 60.0, 3.0, 0.5)
			fx.ring(ev.pos, 4.0, float(ev.radius), Color(Draw.ACCENT.flak, 0.8), 0.22, 1.6)
		"flechette":
			# One trace per flechette, scattered across the cone at random lengths.
			var fcone := deg_to_rad(float(ev.cone)) * 0.5
			var faim := float(ev.aim)
			for k in int(ev.get("pellets", 6)):
				var fa := faim + randf_range(-fcone, fcone)
				var fend: Vector2 = ev.pos + Vector2.from_angle(fa) * float(ev.range) * randf_range(0.55, 1.0)
				fx.tracer(ev.pos + Vector2.from_angle(fa) * randf_range(6.0, 12.0), fend, Color(Draw.SPEC_ALT.flechette, 0.8), 0.12, 1.4)
			fx.flash(ev.pos + Vector2.from_angle(faim) * 12.0, 9.0, Draw.SPEC_ALT.flechette, 0.08)
		"suppress":
			fx.ring(ev.pos, 6.0, float(ev.radius), Color(0.75, 0.55, 1.0), 0.35, 1.8)
		"null_pulse":
			var ncol := Draw.accent("nullifier", str(ev.get("spec", "")))
			fx.ring(ev.pos, 8.0, float(ev.radius), ncol, 0.45, 3.0, true)
			fx.ring(ev.pos, float(ev.radius) * 0.4, float(ev.radius), Color(1, 1, 1, 0.5), 0.3, 1.2)
			fx.flash(ev.pos, 14.0, ncol, 0.12)
		"cascade":
			fx.ring(ev.pos, 4.0, float(ev.radius), Color(0.55, 0.8, 1.0), 0.3, 1.6)
			fx.burst(ev.pos, Color(0.55, 0.8, 1.0), 8, 90.0, 2.0, 0.3)
		"nova":
			var vcol := Color(0.55, 1.0, 0.3) if ev.get("burn", false) else Draw.accent("nova", str(ev.get("spec", "")))
			fx.flash(ev.pos, 22.0, Color(1.0, 0.95, 0.8), 0.12)
			fx.ring(ev.pos, 10.0, float(ev.radius), vcol, 0.4, 4.0, true)
			fx.ring(ev.pos, 6.0, float(ev.radius) * 0.7, Color(1.0, 0.9, 0.6), 0.3, 2.0)
			fx.burst(ev.pos, vcol, 14, 160.0, 2.6, 0.4)
			shake = maxf(shake, 0.05)
		"mini_nova":
			fx.flash(ev.pos, 12.0, Draw.ACCENT.nova, 0.1)
			fx.ring(ev.pos, 4.0, float(ev.radius), Draw.ACCENT.nova, 0.3, 2.0, true)
		"storm_tick":
			fx.ring(ev.pos, float(ev.radius) * 0.85, float(ev.radius), Color(Draw.SPEC_ALT.ionstorm, 0.5), 0.25, 1.4)
		"storm_zone":
			fx.flash(ev.pos, 18.0, Draw.SPEC_ALT.ionstorm, 0.15)
			fx.ring(ev.pos, 6.0, float(ev.radius), Draw.SPEC_ALT.ionstorm, 0.3, 2.0)
		"income":
			for p in ev.paid:
				if p[0].x < 0.0:
					continue
				fx.text(p[0] + Vector2(0, -24), "+%d" % int(p[1]), Color(1.0, 0.8, 0.3), 14, 1.4, 30.0)
				fx.burst(p[0], Color(1.0, 0.8, 0.3), 10, 70.0, 2.0, 0.5)
		"drone_shot":
			fx.tracer(ev.from, ev.to, Color(Draw.ACCENT.drones, 0.9), 0.08, 1.4)
			fx.flash(ev.to, 5.0, Draw.ACCENT.drones, 0.06)
		"drone_bomb", "bomblet":
			fx.flash(ev.pos, 12.0, Color(1.0, 0.65, 0.3), 0.1)
			fx.ring(ev.pos, 4.0, float(ev.radius), Color(1.0, 0.6, 0.25), 0.28, 2.0, true)
			fx.burst(ev.pos, Color(1.0, 0.55, 0.2), 8, 100.0, 2.2, 0.35)
			ground_fx.scorch(ev.pos, float(ev.radius) * 0.35)
		"gravity":
			var gcol := Draw.accent("gravity", str(ev.get("spec", "")))
			if ev.get("pull", false):
				fx.ring(ev.pos, 8.0, float(ev.radius), Color(gcol, 0.5), 0.45, 2.0)
				if ev.get("implode", false):
					fx.flash(ev.pos, 26.0, Color(1, 1, 1), 0.15)
					fx.burst(ev.pos, gcol, 20, 140.0, 2.6, 0.45)
					shake = maxf(shake, 0.2)
				return
			fx.ring(ev.pos, float(ev.radius), 8.0, gcol, 0.45, 3.0)
			fx.ring(ev.pos, float(ev.radius) * 0.6, 4.0, Color(gcol, 0.6), 0.35, 2.0)
			fx.flash(ev.pos, 16.0, gcol, 0.15)
			shake = maxf(shake, 0.08)
		"emp":
			var ecol := Draw.ENEMY_COLOR.jammer
			fx.ring(ev.pos, 6.0, float(ev.radius), ecol, 0.35, 2.5, true)
			fx.flash(ev.pos, 18.0, ecol, 0.12)
		"split":
			fx.burst(ev.pos, Draw.ENEMY_COLOR.hydra, 18, 120.0, 2.6, 0.45)
			fx.ring(ev.pos, 6.0, 34.0, Draw.ENEMY_COLOR.hydra, 0.3, 2.0)
		"shield_break":
			fx.burst(ev.pos, Color(0.55, 0.8, 1.0), 16, 130.0, 2.2, 0.4)
			fx.ring(ev.pos, 10.0, 30.0, Color(0.55, 0.8, 1.0), 0.25, 2.0)
		"execute":
			fx.flash(ev.pos, 22.0, Color(1.0, 0.25, 0.25), 0.15)
			fx.ring(ev.pos, 18.0, 4.0, Color(1.0, 0.3, 0.3), 0.25, 2.5)
			fx.text(ev.pos + Vector2(0, -22), "EXECUTED", Color(1.0, 0.4, 0.35), 12, 0.8, 24.0)
		"laser_lock":
			fx.flash(ev.pos, 10.0, Draw.ACCENT.laser, 0.1)
		"hit":
			if damage_numbers and float(ev.amount) >= 1.0:
				fx.text(ev.pos + Vector2(randf_range(-6.0, 6.0), -12.0), str(roundi(ev.amount)), Color(0.8, 0.95, 1.0), 12, 0.6, 26.0)
		"kill":
			var col: Color = Draw.ENEMY_COLOR.get(ev.enemy, Color.WHITE)
			if ev.boss:
				fx.burst(ev.pos, col, 60, 220.0, 4.0, 0.9)
				fx.burst(ev.pos, Color(1.0, 0.8, 0.4), 40, 160.0, 3.0, 0.8)
				fx.ring(ev.pos, 10.0, 130.0, Color(1.0, 0.8, 0.4), 0.6, 4.0)
				ground_fx.scorch(ev.pos, 40.0)
				shake = 1.0
			else:
				fx.burst(ev.pos, col, 12, 110.0, 2.4, 0.45)
				ground_fx.burst(ev.pos, Color(0.2, 0.22, 0.26, 0.9), 5, 70.0, 2.4, 0.9)
			if int(ev.bounty) > 0:
				fx.text(ev.pos + Vector2(0, -16), "+%d" % int(ev.bounty), Color(1.0, 0.8, 0.3), 22 if ev.boss else 12, 1.0, 34.0)
		"leak":
			fx.ring(ev.pos, 8.0, 60.0, Color(1.0, 0.3, 0.25), 0.4, 3.0)
			shake = maxf(shake, 0.35)
		"heal":
			if ev.active:
				fx.ring(ev.pos, 8.0, ev.radius, Draw.ENEMY_COLOR.shaman, 0.5, 2.0, true)
		"minions":
			var mcol: Color = Draw.ENEMY_COLOR.get(str(ev.get("enemy", "warlord")), Draw.ENEMY_COLOR.warlord)
			fx.burst(ev.pos, mcol, 20, 120.0, 3.0, 0.5)
			fx.ring(ev.pos, 10.0, 60.0, mcol, 0.4, 2.5)
		"burrow":
			ground_fx.burst(ev.pos, Color(0.45, 0.36, 0.26, 0.9), 12, 70.0, 3.0, 0.6)
		"blink":
			var bcol: Color = Draw.ENEMY_COLOR.stalker
			fx.tracer(ev.from, ev.pos, Color(bcol, 0.5), 0.25, 3.0)
			fx.flash(ev.from, 12.0, bcol, 0.12)
			fx.flash(ev.pos, 14.0, bcol, 0.15)
		"bulwark":
			fx.ring(ev.pos, 8.0, float(ev.radius), Draw.ENEMY_COLOR.bulwark, 0.4, 2.0, true)
		"phase":
			var pcol: Color = Draw.ENEMY_COLOR.get(str(ev.enemy), Color(1, 0.5, 0.2))
			fx.burst(ev.pos, Color(0.55, 0.55, 0.58), 30, 180.0, 3.5, 0.7)
			fx.burst(ev.pos, pcol, 24, 140.0, 3.0, 0.6)
			fx.ring(ev.pos, 12.0, 90.0, pcol, 0.5, 3.5)
			shake = maxf(shake, 0.6)
		"build":
			fx.burst(ev.pos, Draw.accent(str(ev.tower)), 16, 90.0, 2.2, 0.5)
			fx.ring(ev.pos, 6.0, 30.0, Draw.accent(str(ev.tower)), 0.3, 2.0)
		"upgrade":
			if bool(ev.get("mastery", false)):
				fx.burst(ev.pos, Color(1.0, 0.85, 0.4), 40, 170.0, 3.0, 0.8)
				fx.ring(ev.pos, 10.0, 70.0, Color(1.0, 0.85, 0.4), 0.6, 3.5)
				fx.ring(ev.pos, 4.0, 46.0, Draw.accent("", str(ev.get("spec", ""))), 0.45, 2.5)
				fx.text(ev.pos + Vector2(0, -28), "MASTERY", Color(1.0, 0.85, 0.4), 16, 1.3, 30.0)
				shake = maxf(shake, 0.25)
			fx.burst(ev.pos, Color(1.0, 0.85, 0.4), 22, 120.0, 2.5, 0.6)
			fx.ring(ev.pos, 8.0, 36.0, Color(1.0, 0.85, 0.4), 0.4, 2.5)
		"sell":
			fx.burst(ev.pos, Color(1.0, 0.8, 0.3), 16, 100.0, 2.5, 0.5)
			fx.text(ev.pos + Vector2(0, -16), "+%d" % int(ev.value), Color(1.0, 0.8, 0.3), 14, 1.0, 30.0)
		"boss_spawn":
			shake = maxf(shake, 0.4)
		"meteor_cast":
			fx.meteor(ev.pos, float(ev.delay), float(ev.radius))
		"meteor_impact":
			fx.tracer(Vector2(ev.pos.x, -60.0), ev.pos, Color(1.0, 0.6, 0.3), 0.35, 16.0)
			fx.tracer(Vector2(ev.pos.x, -60.0), ev.pos, Color(1.0, 0.95, 0.8), 0.25, 5.0)
			fx.flash(ev.pos, 60.0, Color(1.0, 0.8, 0.5), 0.2)
			fx.ring(ev.pos, 10.0, ev.radius * 1.3, Color(1.0, 0.55, 0.2), 0.55, 5.0, true)
			fx.burst(ev.pos, Color(1.0, 0.55, 0.15), 50, 260.0, 4.0, 0.8)
			ground_fx.burst(ev.pos, SMOKE, 24, 120.0, 6.0, 1.2)
			ground_fx.scorch(ev.pos, ev.radius * 0.7)
			shake = maxf(shake, 0.8)
		"warp":
			fx.warp(float(ev.duration))


## True while the mouse is over a HUD control (a bar or pop-out), so the field underneath
## doesn't highlight or show hover info.
func _over_ui() -> bool:
	var vp := get_viewport()
	if vp == null or not vp.has_method("gui_get_hovered_control"):
		return false
	return vp.call("gui_get_hovered_control") != null
