extends Control
## Yes/no modal.

const UiKit = preload("res://scripts/ui/UiKit.gd")

var message := ""
var on_yes: Callable
var on_no: Callable
var yes_text := "Yes"
var no_text := "Cancel"


func _init(msg: String, yes_cb: Callable, no_cb: Callable, yes_label := "Yes", no_label := "Cancel") -> void:
	message = msg
	on_yes = yes_cb
	on_no = no_cb
	yes_text = yes_label
	no_text = no_label


func _ready() -> void:
	position = Vector2.ZERO
	size = UiKit.SCREEN
	theme = UiKit.theme()
	add_child(UiKit.dimmer(0.6))
	var p := UiKit.centered_panel(460.0)
	add_child(p)
	var v := UiKit.vbox(16)
	p.add_child(v)
	var msg := UiKit.wrap_label(message, 420, 16)
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(msg)
	var row := UiKit.hbox(12)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	var no := UiKit.button(no_text, func(): on_no.call(), Vector2(170, 40), true)
	var yes := UiKit.button(yes_text, func(): on_yes.call(), Vector2(170, 40), true)
	row.add_child(no)
	row.add_child(yes)
	v.add_child(row)
	no.grab_focus.call_deferred()
