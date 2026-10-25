extends "res://scripts/ui/PopOut.gd"
## The Retrofit pop-out of the reworked towers (issue #59): three options side by side, each with a preview of the tower
## wearing it, its price and its effect. Click one (or press 1-3) to buy it; the choice is locked, and the panel closes.

const DrawControl = preload("res://scripts/ui/DrawControl.gd")
const Draw = preload("res://scripts/view/Draw.gd")

## Gaps around and between the three option cards; the cards share the rest of the width (and stay inside the border, #87).
const EDGE := 14.0
const GAP := 6.0
const TOP := 40.0

var hud
var screen
var tower
var buttons: Array = []


func _init(owner_hud, t) -> void:
	super(Rect2(404, 200, 800, 410), "RETROFIT: CHOOSE ONE", Vector2(0, -16))
	hud = owner_hud
	screen = owner_hud.screen
	tower = t
	title_color = Draw.accent(t.type)


func _build() -> void:
	var t = tower
	body.add_child(_note("One Retrofit per tower, and the choice is locked. Press 1, 2 or 3, or click an option."))
	var opts: Array = t.retrofit_options()
	var col_w := (rect.size.x - 2.0 * EDGE - 2.0 * GAP) / 3.0
	var card_h := body.size.y - TOP - 12.0
	for i in opts.size():
		var o: Dictionary = opts[i]
		var look: String = t.look_key(i)
		var b := UiKit.button("", Callable(self, "_pick").bind(i), Vector2(col_w, card_h))
		b.size = Vector2(col_w, card_h)
		b.position = Vector2(EDGE + float(i) * (col_w + GAP), TOP)
		b.clip_contents = true
		b.tooltip_text = "%s\n%s" % [o.name, o.blurb]
		var icon := DrawControl.new(func(ci): Draw.tower(ci, t.type, 2, ci.size / 2.0, -PI / 2.0, 2.6, Time.get_ticks_msec() / 1000.0, 0.0, look, look), Vector2(150, 130), true)
		icon.position = Vector2((col_w - 150.0) / 2.0, 8)
		b.add_child(icon)
		var name_l := UiKit.label(str(o.name), 16, UiKit.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
		name_l.position = Vector2(8, 142)
		name_l.size = Vector2(col_w - 16, 22)
		b.add_child(name_l)
		var cost_l := UiKit.label("%d cr   [%d]" % [t.retrofit_cost(i), i + 1], 14, UiKit.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
		cost_l.position = Vector2(8, 166)
		cost_l.size = Vector2(col_w - 16, 20)
		b.add_child(cost_l)
		var blurb := UiKit.wrap_label(str(o.blurb), col_w - 28, 12, Color(UiKit.TEXT, 0.88))
		blurb.position = Vector2(14, 196)
		# A long effect is cut at the card's foot with "..."; the tooltip has all of it.
		blurb.max_lines_visible = int((card_h - 196.0 - 8.0) / 18.0)
		blurb.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		b.add_child(blurb)
		body.add_child(b)
		buttons.append(b)


func _note(text: String) -> Label:
	var l := UiKit.label(text, 12, UiKit.DIM)
	l.position = Vector2(16, 10)
	return l


func _pick(i: int) -> void:
	screen.buy_retrofit(i)


func refresh(_delta: float) -> void:
	var g = screen.game
	if tower == null or tower.retrofit >= 0 or not g.towers.has(tower):
		screen.close_popout("retrofit")
		return
	for i in buttons.size():
		(buttons[i] as Button).disabled = g.gold < tower.retrofit_cost(i) or g.is_over()
