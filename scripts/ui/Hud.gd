extends CanvasLayer
## In-game HUD: a thin top bar, a context bottom bar, and pop-out menus (shop, upgrade tree,
## research, intel) that open on demand, plus banners and toasts over the battlefield.
## GameScreen owns the game rules for opening/closing; this layer builds and refreshes the pieces.

const UiKit = preload("res://scripts/ui/UiKit.gd")
const TopBar = preload("res://scripts/ui/hud/TopBar.gd")
const BottomBar = preload("res://scripts/ui/hud/BottomBar.gd")
const ShopPanel = preload("res://scripts/ui/hud/ShopPanel.gd")
const UpgradeTreePanel = preload("res://scripts/ui/hud/UpgradeTreePanel.gd")
const TowerPanel = preload("res://scripts/ui/hud/TowerPanel.gd")
const IntelPanel = preload("res://scripts/ui/hud/IntelPanel.gd")
const ResearchPopOut = preload("res://scripts/ui/hud/ResearchPopOut.gd")
const KnowledgePopOut = preload("res://scripts/ui/hud/KnowledgePopOut.gd")
const SpawnerPanel = preload("res://scripts/ui/hud/SpawnerPanel.gd")
## Pop-outs that pause the battle while open.
const PAUSING := ["research", "codex"]
## The tower panel follows the selection (GameScreen._sync_side_panel), so "close everything" and
## "is anything open" leave it out: Esc closes the other pop-outs first, then deselects.
const FOLLOWS_SELECTION := ["tower"]

## Battlefield rect on screen (World.base_pos and the grid size).
const FIELD := Rect2(32, 40, 1536, 768)

var screen
var root: Control
var top
var bottom
var start_btn: Button
var hovered_build := ""
var lives_flash := 0.0
var popouts := {}

var _pop_root: Control
var _dim: ColorRect
var banner: Label
var banner_sub: Label
var banner_t := 0.0
var toasts: VBoxContainer


func _ready() -> void:
	layer = 5
	root = UiKit.root()
	add_child(root)
	top = TopBar.new()
	top.hud = self
	top.screen = screen
	root.add_child(top)
	bottom = BottomBar.new()
	bottom.hud = self
	bottom.screen = screen
	root.add_child(bottom)
	start_btn = bottom.start_btn
	# Toasts sit under the pop-outs so they never cover a pop-out's title strip.
	toasts = UiKit.vbox(4)
	toasts.position = FIELD.position + Vector2(12, 10)
	toasts.size = Vector2(460, 200)
	toasts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(toasts)
	_dim = UiKit.dimmer(0.6)
	_dim.visible = false
	root.add_child(_dim)
	_pop_root = Control.new()
	_pop_root.size = UiKit.SCREEN
	_pop_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_pop_root)
	banner = UiKit.label("", 46, UiKit.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	banner.position = Vector2(FIELD.position.x, 360)
	banner.size = Vector2(FIELD.size.x, 64)
	banner.add_theme_constant_override("outline_size", 12)
	banner.modulate.a = 0.0
	root.add_child(banner)
	banner_sub = UiKit.label("", 18, UiKit.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	banner_sub.position = Vector2(FIELD.position.x, 424)
	banner_sub.size = Vector2(FIELD.size.x, 30)
	banner_sub.add_theme_constant_override("outline_size", 6)
	banner_sub.modulate.a = 0.0
	root.add_child(banner_sub)
	# Start the start button's text etc. in a sane state.
	refresh(0.0)


# --- Pop-outs --------------------------------------------------------------------------------

func is_open(kind: String) -> bool:
	return popouts.has(kind)


func any_open() -> bool:
	return popouts.keys().any(func(k): return not FOLLOWS_SELECTION.has(k))


## `arg` is kind-specific: the Codex entry to open on.
func open(kind: String, arg := "") -> void:
	if is_open(kind):
		return
	var p
	match kind:
		"shop":
			p = ShopPanel.new(self)
		"tower":
			var st = screen.world.selected_tower
			if st == null:
				return
			var tower_side := arg if arg != "" else "right"
			if tower_side == "left":
				# The Spawner lives on the left edge too; the tower you picked wins that slot.
				close("spawner")
			p = TowerPanel.new(self, st, tower_side)
		"tree":
			var t = screen.world.selected_tower
			if t == null:
				return
			p = UpgradeTreePanel.new(self, t)
		"intel":
			p = IntelPanel.new(self)
		"research":
			p = ResearchPopOut.new(self)
		"codex":
			p = KnowledgePopOut.new(self, arg)
		"spawner":
			if not screen.game.sandbox:
				return
			var tp = popouts.get("tower")
			if tp != null and tp.side == "left":
				screen.close_popout("tower")
			p = SpawnerPanel.new(self)
		_:
			return
	p.close_requested.connect(func(): screen.close_popout(kind))
	popouts[kind] = p
	_pop_root.add_child(p)
	_dim.visible = is_open("research") or is_open("codex")


func close(kind: String) -> void:
	if not is_open(kind):
		return
	var p = popouts[kind]
	popouts.erase(kind)
	p.dismiss()
	if kind == "shop" and not is_open("shop"):
		hovered_build = ""
	_dim.visible = is_open("research") or is_open("codex")


## True while a pop-out that pauses the battle is open.
func pausing_open() -> bool:
	return PAUSING.any(func(k): return is_open(k))


func close_all() -> void:
	for kind in popouts.keys():
		if not FOLLOWS_SELECTION.has(kind):
			close(kind)


func popout(kind: String):
	return popouts.get(kind)


# --- Feedback --------------------------------------------------------------------------------

func show_banner(text: String, sub := "", color := UiKit.GOLD) -> void:
	banner.text = text
	banner.add_theme_color_override("font_color", color)
	banner_sub.text = sub
	banner_t = 2.4


## Keeps the current banner up for at least `seconds`.
func hold_banner(seconds: float) -> void:
	banner_t = maxf(banner_t, seconds)


func toast(text: String, color := UiKit.TEXT) -> void:
	var l := UiKit.label(text, 15, color)
	l.add_theme_constant_override("outline_size", 5)
	l.set_meta("life", 2.8)
	toasts.add_child(l)
	while toasts.get_child_count() > 5:
		var old := toasts.get_child(0)
		toasts.remove_child(old)
		old.queue_free()


func flash_lives() -> void:
	lives_flash = 0.6


# --- Per-frame refresh -----------------------------------------------------------------------

func refresh(delta: float) -> void:
	lives_flash = maxf(0.0, lives_flash - delta)
	top.refresh(delta)
	bottom.refresh(delta)
	# Toasts sit top-left over the field; a tower panel on the left pushes them to its right.
	var side_panel = popouts.get("tower")
	toasts.position.x = (TowerPanel.LEFT_X + TowerPanel.W + 16.0) if side_panel != null and side_panel.side == "left" else FIELD.position.x + 12.0
	if is_open("tree"):
		var tp = popouts.tree
		if screen.world.selected_tower != tp.tower or not screen.game.towers.has(tp.tower):
			screen.close_popout("tree")
	for kind in popouts:
		popouts[kind].refresh(delta)
	banner_t = maxf(0.0, banner_t - delta)
	var a := clampf(banner_t / 0.6, 0.0, 1.0)
	banner.modulate.a = a
	banner_sub.modulate.a = a
	for l in toasts.get_children():
		var life: float = float(l.get_meta("life", 0.0)) - delta
		l.set_meta("life", life)
		l.modulate.a = clampf(life / 0.6, 0.0, 1.0)
		if life <= 0.0:
			toasts.remove_child(l)
			l.queue_free()
