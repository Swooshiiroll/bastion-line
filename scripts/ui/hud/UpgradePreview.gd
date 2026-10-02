extends Control
## The upgrade preview (design/upgrade_rework.md §4): a live, looping demo of one upgrade.
## - The scene: a sandbox Game on the test range (data/maps.gd "range") in the current sector's
##   look, with the tower beside the lane at the node's upgrade state. It's drawn by a World inside
##   a SubViewport, so it uses the game's own art and effects.
## - Every few seconds a group of enemies picked to show the upgrade off walks the lane
##   (UpgradeRules.enemies_for).
## The sandbox is a separate Game with a fixed seed: it never touches the real game's state.

const Game = preload("res://scripts/core/Game.gd")
const World = preload("res://scripts/view/World.gd")
const Grid = preload("res://scripts/core/Grid.gd")
const UpgradeRules = preload("res://scripts/core/UpgradeRules.gd")
const UiKit = preload("res://scripts/ui/UiKit.gd")
const Enemies = preload("res://data/enemies.gd")

## Cells of the test range shown: 16 x 8, the 2:1 shape of the preview, around the tower; the
## lane (row 8) runs through the middle.
const CLIP := Rect2i(8, 4, 16, 8)
const TOWER_CELL := Vector2i(15, 7)
const BIG_TOWER_CELL := Vector2i(15, 6)
const PARTNER_CELL := Vector2i(17, 7)
## Seconds between groups, and the gap between enemies in a group (px along the lane).
const LOOP := 7.0
const GAP := 34.0
## The SubViewport renders at twice the control's size so it stays sharp on a stretched window.
const OVERSAMPLE := 2.0

var game
var world
var tower
var enemies: Array = []
var _view: SubViewport
var _tex: TextureRect
var _hp_mult := 1.0
var _wave_at := -999.0
var _caption: Label


func _init(size_px: Vector2) -> void:
	custom_minimum_size = size_px
	size = size_px
	clip_contents = true


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.04, 0.06, 0.9)
	bg.size = size
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_view = SubViewport.new()
	_view.size = Vector2i((size * OVERSAMPLE).ceil())
	_view.disable_3d = true
	_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_view)
	_tex = TextureRect.new()
	_tex.texture = _view.get_texture()
	# Expand mode first: with the default, the rect grows to the (oversampled) texture size.
	_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_tex.stretch_mode = TextureRect.STRETCH_SCALE
	_tex.size = size
	_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tex)
	_caption = UiKit.label("", 13, UiKit.DIM, HORIZONTAL_ALIGNMENT_CENTER)
	_caption.size = Vector2(size.x, 20)
	_caption.position = Vector2(0, size.y / 2.0 - 10.0)
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_caption)


## Plays node `id` of real tower `t` from real game `real`. "" shows `note` instead (an unreachable
## node).
func show_node(real, t, id: String, note := "") -> void:
	_clear()
	if id == "":
		_caption.text = note
		return
	_caption.text = ""
	var g = Game.new("range", 1, real.difficulty, real.research)
	# The test range takes the current sector's look.
	g.grid.def = (g.grid.def as Dictionary).duplicate(true)
	g.grid.def.theme = str(real.map_def.theme)
	g.gold = 1 << 30
	g.lives = 1 << 20
	g.max_lives = g.lives
	var big: bool = int(t.size) > 1
	var tw = g.place_tower(t.type, BIG_TOWER_CELL if big else TOWER_CELL)
	if tw == null:
		_caption.text = "Preview unavailable"
		return
	var st := UpgradeRules.preview_state(t, id)
	tw.trunk = st.trunk
	tw.depth = st.depth
	tw.started = st.started
	tw.mastered = st.mastered
	tw.mode = t.mode
	tw.priority = t.priority
	tw.invalidate()
	var node := UpgradeRules.node_for(t.type, id)
	var partner: bool = UpgradeRules.needs_partner(tw)
	if partner:
		g.place_tower("arrow", PARTNER_CELL)
	enemies = UpgradeRules.enemies_for(node, partner or tw.hits_air(), partner or tw.hits_ground())
	_hp_mult = real.hp_mult_for(maxi(1, int(real.wave)))
	g.state = Game.State.WAVE
	game = g
	tower = tw
	world = World.new()
	world.interactive = false
	world.keys_enabled = false
	world.base_pos = Vector2.ZERO
	_view.add_child(world)
	world.setup(g, CLIP)
	# Frame the clip: zoom so its width fills the view, pan so its corner is the view's origin.
	world.zoom = float(_view.size.x) / (float(CLIP.size.x) * Grid.TILE)
	world.pan = -Vector2(CLIP.position) * Grid.TILE * world.zoom
	world.damage_numbers = true
	_wave_at = -999.0


func _clear() -> void:
	if world != null:
		world.queue_free()
	world = null
	game = null
	tower = null
	enemies = []


func _process(delta: float) -> void:
	if game == null:
		return
	# A new group every LOOP seconds (sooner if the lane is empty).
	if game.time - _wave_at >= LOOP or (game.enemies.is_empty() and game.spawn_queue.is_empty() and game.time - _wave_at >= 2.0):
		_wave_at = game.time
		# The group starts just left of the shown part of the lane, already spaced out, so it walks
		# straight into view (the range's lane starts a long way off to the left).
		var entry := (float(CLIP.position.x) - 0.5) * Grid.TILE
		for i in enemies.size():
			var type: String = enemies[i]
			var boss := bool(Enemies.ENEMIES[type].get("boss", false))
			var e = game.spawn_enemy(type, 0, maxf(0.0, entry - float(i) * GAP), _hp_mult * (0.2 if boss else 1.0), 0)
			game.enemies.append(e)
	world.simulate(minf(delta, 0.1), 1)
	# The sandbox never finishes its "wave": clearing the field drops it back into build state.
	if game.state != Game.State.WAVE:
		game.state = Game.State.WAVE
