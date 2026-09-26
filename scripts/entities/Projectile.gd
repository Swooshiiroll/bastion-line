extends RefCounted
## A travelling shot: pulse bolt, mortar shell or homing missile. Carries the effects it applies on hit.

var kind := ""
var pos := Vector2.ZERO
var start := Vector2.ZERO
var vel := Vector2.ZERO
var target = null
var target_pos := Vector2.ZERO
var speed := 600.0
var damage := 0.0
var splash := 0.0
var tier := 1
var source = null
var alive := true
var traveled := 0.0
var total := 1.0
var life := 0.0
var air_mult := 1.0
var shred := 0.0
var shred_max := 0.0
var burn_dps := 0.0
var burn_time := 0.0
var stun := 0.0
