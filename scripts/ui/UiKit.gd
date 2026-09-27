extends RefCounted
## Shared sci-fi look for every screen: a code-built Theme (holo-panel colors, angled corners,
## the Bahnschrift system font) plus small widget factories.

const BG := Color(0.03, 0.045, 0.07, 0.96)
const BG_LIGHT := Color(0.06, 0.09, 0.13, 1.0)
const BORDER := Color(0.13, 0.36, 0.48)
const TEXT := Color(0.86, 0.94, 1.0)
const DIM := Color(0.48, 0.60, 0.70)
const GOLD := Color(1.0, 0.78, 0.30)
const GOOD := Color(0.40, 1.0, 0.60)
const BAD := Color(1.0, 0.36, 0.40)
const BLUE := Color(0.40, 0.80, 1.0)
const ACCENT := Color(0.30, 0.88, 1.0)
const SCREEN := Vector2(1600, 900)


## The window's visible area in layout units. The project stretches with aspect "expand", so this
## is at least SCREEN and grows in whichever direction the window is wider or taller than 16:9.
static func view_size() -> Vector2:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return SCREEN
	return tree.root.get_visible_rect().size.max(SCREEN)


## Where the 1600×900 layout sits inside the window: every screen is designed at SCREEN and
## centred (Boot shifts the canvas and every CanvasLayer by this much).
static func view_offset() -> Vector2:
	return ((view_size() - SCREEN) / 2.0).floor()


## The whole window in layout coordinates (negative where it extends past the centred layout).
static func full_rect() -> Rect2:
	return Rect2(-view_offset(), view_size())


## Makes a Control (a child of a layout-sized parent at the origin) cover the whole window, and
## keeps it covering when the window is resized.
static func bleed(c: Control) -> void:
	var fit := func() -> void:
		if is_instance_valid(c):
			c.position = -view_offset()
			c.size = view_size()
	fit.call()
	c.tree_entered.connect(func(): c.get_viewport().size_changed.connect(fit))
	c.tree_exiting.connect(func():
		if c.get_viewport().size_changed.is_connected(fit):
			c.get_viewport().size_changed.disconnect(fit))

static var _theme: Theme = null
static var _font: Font = null


## Bahnschrift ships with Windows 10+; falls back to Segoe UI / Arial elsewhere.
## The UI font: Windows' Bahnschrift where it exists, else the bundled Barlow (SIL OFL, in fonts/),
## a similar DIN-style face, so Linux and other systems look the same everywhere.
## `--bundled-font` forces Barlow on Windows too, to preview it.
static func font() -> Font:
	if _font == null:
		if OS.has_feature("windows") and not ("--bundled-font" in OS.get_cmdline_user_args()):
			var f := SystemFont.new()
			f.font_names = PackedStringArray(["Bahnschrift", "Segoe UI", "Arial"])
			f.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
			_font = f
		else:
			var b: FontFile = load("res://fonts/Barlow-Medium.ttf")
			b.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
			_font = b
	return _font


static func theme() -> Theme:
	if _theme != null:
		return _theme
	var t := Theme.new()
	t.default_font = font()
	t.default_font_size = 16
	t.set_stylebox("normal", "Button", box(Color(0.05, 0.09, 0.13), BORDER))
	var hover := box(Color(0.07, 0.15, 0.21), ACCENT)
	hover.shadow_color = Color(ACCENT, 0.25)
	hover.shadow_size = 6
	t.set_stylebox("hover", "Button", hover)
	t.set_stylebox("pressed", "Button", box(Color(0.03, 0.06, 0.09), GOLD))
	t.set_stylebox("disabled", "Button", box(Color(0.035, 0.05, 0.07), Color(0.09, 0.16, 0.2)))
	var focus := box(Color(0, 0, 0, 0), GOLD, 6, 2)
	focus.draw_center = false
	t.set_stylebox("focus", "Button", focus)
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", Color(1, 1, 1))
	t.set_color("font_pressed_color", "Button", GOLD)
	t.set_color("font_focus_color", "Button", TEXT)
	t.set_color("font_disabled_color", "Button", Color(0.3, 0.4, 0.48))
	t.set_stylebox("panel", "Panel", box(BG, BORDER, 0))
	var modal := box(BG, ACCENT, 10, 1, 18.0)
	modal.shadow_color = Color(ACCENT, 0.18)
	modal.shadow_size = 14
	t.set_stylebox("panel", "PanelContainer", modal)
	t.set_color("font_color", "Label", TEXT)
	t.set_color("font_outline_color", "Label", Color(0, 0, 0, 0.85))
	t.set_color("font_color", "CheckBox", TEXT)
	t.set_color("font_hover_color", "CheckBox", Color(1, 1, 1))
	t.set_color("font_pressed_color", "CheckBox", TEXT)
	t.set_color("font_hover_pressed_color", "CheckBox", Color(1, 1, 1))
	t.set_color("font_focus_color", "CheckBox", TEXT)
	var empty := StyleBoxEmpty.new()
	for s in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
		t.set_stylebox(s, "CheckBox", empty)
	var on_icon := _check_icon(true)
	var off_icon := _check_icon(false)
	for n in ["checked", "checked_disabled"]:
		t.set_icon(n, "CheckBox", on_icon)
	for n in ["unchecked", "unchecked_disabled"]:
		t.set_icon(n, "CheckBox", off_icon)
	t.set_stylebox("panel", "TooltipPanel", box(Color(0.06, 0.07, 0.09, 0.98), BORDER, 4, 1, 8.0))
	t.set_color("font_color", "TooltipLabel", TEXT)
	t.set_stylebox("slider", "HSlider", box(Color(0.2, 0.22, 0.28), BORDER, 3, 1, 3.0))
	t.set_stylebox("grabber_area", "HSlider", box(ACCENT, ACCENT, 3, 0, 3.0))
	t.set_stylebox("grabber_area_highlight", "HSlider", box(BLUE, BLUE, 3, 0, 3.0))
	_theme = t
	return t


static func box(bg: Color, border: Color, radius := 6, border_w := 1, margin := 10.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_w)
	# Smoothly rounded corners, the same on all four.
	s.set_corner_radius_all(int(radius * 1.3))
	s.corner_detail = 8
	s.content_margin_left = margin
	s.content_margin_right = margin
	s.content_margin_top = margin * 0.45
	s.content_margin_bottom = margin * 0.45
	s.anti_aliasing = true
	return s


static func button(text: String, cb: Callable, min_size := Vector2(0, 36), focusable := false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	if not focusable:
		b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func():
		var sfx = (Engine.get_main_loop() as SceneTree).root.get_node_or_null("Sfx")
		if sfx != null:
			sfx.play("click", -8.0, 0.0)
	)
	b.pressed.connect(cb)
	return b


static func label(text: String, size := 16, color := TEXT, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func wrap_label(text: String, width: float, size := 14, color := TEXT) -> Label:
	var l := label(text, size, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(width, 0)
	return l


static func panel(rect: Rect2, bg := BG, radius := 0) -> Panel:
	var p := Panel.new()
	p.position = rect.position
	p.size = rect.size
	p.add_theme_stylebox_override("panel", box(bg, BORDER, radius))
	return p


## A full-screen root Control for a CanvasLayer, with the shared theme applied.
static func root() -> Control:
	var c := Control.new()
	c.theme = theme()
	c.position = Vector2.ZERO
	c.size = SCREEN
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


## Animated full-screen starfield with a faint holo grid, for menu backgrounds.
static func starfield() -> Control:
	var script: GDScript = load("res://scripts/ui/DrawControl.gd")
	var fn := func(ci: Control) -> void:
		var t := Time.get_ticks_msec() / 1000.0
		var full := full_rect()
		ci.draw_rect(full, Color(0.015, 0.02, 0.035))
		var rng := RandomNumberGenerator.new()
		rng.seed = 90210
		var count := int(260.0 * full.size.x * full.size.y / (SCREEN.x * SCREEN.y))
		for i in count:
			var p := full.position + Vector2(rng.randf() * full.size.x, rng.randf() * full.size.y)
			var depth := rng.randf()
			p.x = full.position.x + fmod(p.x - full.position.x - t * (4.0 + 18.0 * depth) + full.size.x * 4.0, full.size.x)
			var tw := 0.55 + 0.45 * sin(t * (1.0 + 2.0 * depth) + float(i))
			var col := Color(0.7, 0.85, 1.0, (0.25 + 0.6 * depth) * tw)
			ci.draw_circle(p, 0.6 + 1.3 * depth, col)
		var gx := full.position.x - fposmod(full.position.x, 64.0)
		while gx <= full.end.x:
			ci.draw_line(Vector2(gx, full.position.y), Vector2(gx, full.end.y), Color(ACCENT, 0.025), 1.0)
			gx += 64.0
		var gy := full.position.y - fposmod(full.position.y, 64.0)
		while gy <= full.end.y:
			ci.draw_line(Vector2(full.position.x, gy), Vector2(full.end.x, gy), Color(ACCENT, 0.025), 1.0)
			gy += 64.0
	var c: Control = script.new(fn, SCREEN, true)
	return c


## Full-screen click-eating dimmer used behind modals.
static func dimmer(alpha := 0.6) -> ColorRect:
	var r := ColorRect.new()
	r.color = Color(0, 0, 0, alpha)
	r.mouse_filter = Control.MOUSE_FILTER_STOP
	bleed(r)
	r.ready.connect(func():
		var a := r.color.a
		r.color.a = 0.0
		r.create_tween().tween_property(r, "color:a", a, OPEN_TIME))
	return r


static func vbox(sep := 8) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	return v


static func hbox(sep := 8) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	return h


## A modal panel that sizes itself to its content and stays centred on screen.
static func centered_panel(width: float) -> PanelContainer:
	var p := PanelContainer.new()
	p.custom_minimum_size = Vector2(width, 0)
	p.resized.connect(func():
		p.position = ((SCREEN - p.size) / 2.0).floor()
		p.pivot_offset = p.size / 2.0)
	p.ready.connect(func(): animate_in(p))
	return p


const OPEN_TIME := 0.14
const CLOSE_TIME := 0.12


## Opening animation for a menu panel: fades in while growing slightly into place.
static func animate_in(c: Control) -> void:
	c.modulate.a = 0.0
	c.scale = Vector2(0.96, 0.96)
	var tw := c.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "modulate:a", 1.0, OPEN_TIME)
	tw.tween_property(c, "scale", Vector2.ONE, OPEN_TIME)


## Closing animation for a menu or overlay: stops taking clicks, fades out, then frees itself.
## Callers drop their reference first, so the game treats it as closed straight away.
static func dismiss(n: CanvasItem) -> void:
	if not is_instance_valid(n) or n.is_queued_for_deletion():
		return
	n.propagate_call("set", ["mouse_filter", Control.MOUSE_FILTER_IGNORE])
	var tw := n.create_tween()
	tw.tween_property(n, "modulate:a", 0.0, CLOSE_TIME)
	tw.tween_callback(n.queue_free)


static func _check_icon(checked: bool) -> ImageTexture:
	var n := 20
	var img := Image.create_empty(n, n, false, Image.FORMAT_RGBA8)
	for y in n:
		for x in n:
			var edge := x < 2 or y < 2 or x >= n - 2 or y >= n - 2
			var inner := x >= 5 and y >= 5 and x < n - 5 and y < n - 5
			if edge:
				img.set_pixel(x, y, Color(0.55, 0.6, 0.7))
			elif checked and inner:
				img.set_pixel(x, y, GOLD)
			else:
				img.set_pixel(x, y, Color(0.1, 0.11, 0.14))
	return ImageTexture.create_from_image(img)
