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
## A critical hit: its damage is already multiplied; the hit effect marks it.
var crit := false
## The firing tower's look key (a reworked tower), so the round is drawn to match: its Power step, its Retrofit.
var look := ""
## Mortar Tower: this shell leaves a smoke cloud where it lands (Smoke Shells).
var smoke := false
## Flies to `target_pos` as fired and doesn't follow its target (a Mortar shell lobbed at a lead point, #85).
var fixed := false
## Rocket Salvo: seconds before this rocket leaves its tube (a rippling salvo), homing / re-targeting / never-miss, and the
## Retrofits' trails and burning ground.
var hold := 0.0
## Artillery Cannon: the shell type this round carries ("he", "incendiary", "shrapnel", "concussion", "combined").
var shell := "he"
var homing := false
var retarget := false
var never_miss := false
var smoke_slow := 0.0
var smoke_time := 0.0
var smoke_acc := 0.0
var ground_burn := 0.0
var ground_burn_time := 0.0
