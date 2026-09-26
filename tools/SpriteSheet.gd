extends Node2D
## Renders every tower (tier 1, tier 2, each branch's specialization and its mastery) and every
## enemy onto one sheet (laid out at 1600×900, scaled to the screen), saves it to res://screenshots/sprite_sheet.png and quits.
## Launch with:  godot --path <project> -- --sprite-sheet [--anim]
## With --anim the sheet stays open and animates instead of saving.

const Draw = preload("res://scripts/view/Draw.gd")
const Towers = preload("res://data/towers.gd")
const TowerTrees = preload("res://data/tower_trees.gd")
const Enemies = preload("res://data/enemies.gd")
const UiKit = preload("res://scripts/ui/UiKit.gd")

const T_SCALE := 1.25
const CELL := Vector2(57, 57)
const ORIGIN := Vector2(142, 34)
const E_ORIGIN := Vector2(636, 24)
const E_CELL := Vector2(159, 214)
const E_COLS := 6

var t := 1.3
var animate := false
var _font: Font


func _ready() -> void:
	_font = UiKit.font()
	scale = Vector2.ONE * (UiKit.SCREEN.x / 1600.0)
	animate = "--anim" in OS.get_cmdline_user_args()
	if not animate:
		_save.call_deferred()


func _process(delta: float) -> void:
	if animate:
		t += delta
		queue_redraw()


func _save() -> void:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://screenshots/"))
	var path := ProjectSettings.globalize_path("res://screenshots/sprite_sheet.png")
	print("sprite sheet: ", error_string(img.save_png(path)))
	get_tree().quit()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, UiKit.SCREEN), Color(0.08, 0.1, 0.13))
	var heads := ["T1", "T2", "Spec A", "Mast. A", "Spec B", "Mast. B", "Spec C", "Mast. C"]
	for i in heads.size():
		_text(ORIGIN + Vector2(i * CELL.x, -18), heads[i], 11, Color(0.6, 0.7, 0.8), CELL.x)
	for row in Towers.ORDER.size():
		var type: String = Towers.ORDER[row]
		var y := ORIGIN.y + row * CELL.y + CELL.y / 2.0
		_text(Vector2(8, y - 8), str(TowerTrees.TREES[type].name), 12, Draw.accent(type), 128, HORIZONTAL_ALIGNMENT_LEFT)
		var cols := [[1, ""], [2, ""]]
		for br in TowerTrees.TREES[type].branches:
			cols.append([3, str(br.id)])
			cols.append([4, str(br.id)])
		for i in cols.size():
			var c := Vector2(ORIGIN.x + i * CELL.x + CELL.x / 2.0, y)
			draw_rect(Rect2(c - CELL / 2.0 + Vector2(2, 2), CELL - Vector2(4, 4)), Color(0.12, 0.15, 0.19))
			Draw.tower(self, type, cols[i][0], c, -PI / 3.0, T_SCALE, t + float(i) * 0.4, 0.0, cols[i][1])
	for i in Enemies.ORDER.size():
		var et: String = Enemies.ORDER[i]
		var ed: Dictionary = Enemies.ENEMIES[et]
		var c := E_ORIGIN + Vector2((i % E_COLS) * E_CELL.x + E_CELL.x / 2.0, (i / E_COLS) * E_CELL.y + 90.0)
		draw_rect(Rect2(c - Vector2(E_CELL.x / 2.0 - 3, 86), Vector2(E_CELL.x - 6, E_CELL.y - 10)), Color(0.12, 0.15, 0.19))
		var s := clampf(30.0 / float(ed.radius), 1.0, 3.8)
		Draw.enemy(self, et, c, Vector2.RIGHT.rotated(-0.3), float(ed.radius), t + float(i), false, 0.0, s)
		_text(c + Vector2(-E_CELL.x / 2.0, 104), str(ed.name), 12, Draw.ENEMY_COLOR.get(et, Color.WHITE), E_CELL.x)


func _text(p: Vector2, s: String, size: int, col: Color, width: float, align := HORIZONTAL_ALIGNMENT_CENTER) -> void:
	draw_string(_font, p + Vector2(0, size), s, align, width, size, col)
