extends "res://scripts/ui/PopOut.gd"
## Intel pop-out: drops down from the top bar's NEXT strip with the next round's full breakdown:
## a summary (hostiles, HP scale, clear and early-call bonuses) and one row per enemy type with its
## count, traits and description. Enemy types appearing for the first time get a NEW tag.

const DrawControl = preload("res://scripts/ui/DrawControl.gd")
const Draw = preload("res://scripts/view/Draw.gd")
const Enemies = preload("res://data/enemies.gd")
const Waves = preload("res://data/waves.gd")

const ROW_H := 56.0

var hud
var screen
var _key := ""
var _list: Control


func _init(owner_hud) -> void:
	super(Rect2(318, 44, 480, 380), "INCOMING", Vector2(0, -24))
	hud = owner_hud
	screen = owner_hud.screen


func _build() -> void:
	_list = Control.new()
	_list.size = body.size
	_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(_list)


func refresh(_delta: float) -> void:
	var g = screen.game
	var key := "%d:%s:%s" % [g.wave, g.endless, g.is_over()]
	if key != _key:
		_key = key
		_fill()


static func traits(ed: Dictionary) -> Array:
	var out: Array = []
	if ed.get("boss", false):
		out.append(["BOSS", UiKit.BAD])
	if ed.get("flying", false):
		out.append(["FLYER", UiKit.BLUE])
	if ed.get("cloaked", false):
		out.append(["CLOAKED", Color(0.55, 0.95, 1.0)])
	if ed.has("shield"):
		out.append(["BARRIER", Color(0.5, 0.75, 1.0)])
	if ed.has("split_type"):
		out.append(["SPLITS", Color(1.0, 0.65, 0.25)])
	if ed.has("emp_interval"):
		out.append(["EMP", Color(0.9, 1.0, 0.3)])
	if ed.has("heal_pct"):
		out.append(["HEALER", Color(0.3, 1.0, 0.6)])
	if ed.has("burrow_interval"):
		out.append(["BURROWS", Color(0.8, 0.65, 0.4)])
	if ed.has("blink_interval"):
		out.append(["BLINKS", Color(0.75, 0.55, 1.0)])
	if ed.has("regen_pct"):
		out.append(["REGENERATES", Color(0.3, 1.0, 0.6)])
	if ed.has("aura_radius"):
		out.append(["HASTE AURA", Color(1.0, 0.6, 0.3)])
	if ed.has("grant_interval"):
		out.append(["BARRIER AURA", Color(0.5, 0.75, 1.0)])
	if ed.get("cc_immune", false) or ed.get("stun_immune", false):
		out.append(["UNSTOPPABLE" if ed.get("cc_immune", false) else "STUN IMMUNE", Color(1.0, 0.5, 0.4)])
	if ed.has("phases"):
		out.append(["PHASES", UiKit.BAD])
	if float(ed.get("armor", 0.0)) >= 4.0:
		out.append(["ARMOR %d" % int(ed.armor), UiKit.DIM])
	return out


## True when round `wave` is the first time `etype` appears in a run whose last round is `final`.
static func is_new(etype: String, wave: int, final := 0) -> bool:
	return Waves.first_round(etype, final) == wave


func _fill() -> void:
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()
	var g = screen.game
	var next: int = g.wave + 1
	if g.is_over():
		var msg := UiKit.wrap_label("The battle is over.", 440, 14, UiKit.DIM)
		msg.position = Vector2(16, 14)
		_list.add_child(msg)
		_resize(80.0)
		return
	var counts := {}
	var order: Array = []
	for grp in g.preview_wave(next):
		if not counts.has(grp.t):
			counts[grp.t] = 0
			order.append(grp.t)
		counts[grp.t] += int(grp.n)
	var total := 0
	for et in counts:
		total += int(counts[et])
	var summary := UiKit.hbox(16)
	summary.position = Vector2(16, 8)
	var title := "FINAL ROUND %d" % next if (not g.endless and next == g.final_round()) else "ROUND %d" % next
	summary.add_child(UiKit.label(title, 13, UiKit.BAD if title.begins_with("FINAL") else UiKit.ACCENT))
	summary.add_child(UiKit.label("%d hostiles" % total, 12, UiKit.TEXT))
	summary.add_child(UiKit.label("HP x%.1f  speed x%.2f" % [Waves.hp_scale(next), Waves.speed_scale(next)], 12, UiKit.TEXT))
	summary.add_child(UiKit.label("clear +%d cr" % Waves.clear_bonus(next), 12, UiKit.GOLD))
	summary.add_child(UiKit.label("call early +%d cr" % Waves.early_call_bonus(next), 12, UiKit.GOLD))
	_list.add_child(summary)
	var y := 38.0
	for et in order:
		var ed: Dictionary = Enemies.ENEMIES[et]
		var etype: String = et
		var boss: bool = ed.get("boss", false)
		var icon := DrawControl.new(func(ci): Draw.enemy(ci, etype, ci.size / 2.0, Vector2.RIGHT, float(ed.radius), Time.get_ticks_msec() / 1000.0, false, 0.0, 0.62 if boss else 1.1), Vector2(40, 40), true)
		icon.position = Vector2(12, y + 4)
		_list.add_child(icon)
		var head := UiKit.hbox(8)
		head.position = Vector2(62, y)
		head.add_child(UiKit.label("×%d" % counts[et], 16, UiKit.BAD if boss else UiKit.TEXT))
		head.add_child(UiKit.label(ed.name, 15, Draw.ENEMY_COLOR.get(etype, UiKit.TEXT)))
		var tags: Array = traits(ed)
		if is_new(etype, next, g.final_round()):
			tags.push_front(["NEW", UiKit.GOLD])
		for tg in tags:
			head.add_child(_tag(tg[0], tg[1]))
		_list.add_child(head)
		var bl := UiKit.label(ed.blurb, 11, UiKit.DIM)
		bl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bl.position = Vector2(62, y + 22)
		bl.size = Vector2(400, 30)
		_list.add_child(bl)
		y += ROW_H
	_resize(y + 8.0)


func _tag(text: String, col: Color) -> PanelContainer:
	var pc := PanelContainer.new()
	var sb := UiKit.box(Color(0, 0, 0, 0), col, 4, 1, 5.0)
	sb.content_margin_top = 0
	sb.content_margin_bottom = 0
	pc.add_theme_stylebox_override("panel", sb)
	pc.add_child(UiKit.label(text, 9, col))
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return pc


func _resize(content_h: float) -> void:
	var h := TITLE_H + content_h
	rect.size.y = h
	size.y = h
	for c in get_children():
		if c is Panel:
			c.size.y = h
	body.size.y = content_h
