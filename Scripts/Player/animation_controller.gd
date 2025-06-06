extends Node

@export var animation_tree : AnimationTree
@export var player : CharacterBody3D
@export var sword_hitbox : Area3D

var on_floor_blend : float = 1
var on_floor_blend_target : float = 1

var tween : Tween

func _ready():
	if sword_hitbox:
		sword_hitbox.monitoring = false
		sword_hitbox.monitorable = false

func _physics_process(delta):
	on_floor_blend_target = 1 if player.is_on_floor() else 0
	on_floor_blend = lerp(on_floor_blend, on_floor_blend_target, 10 * delta)
	animation_tree["parameters/Blend2/blend_amount"] = on_floor_blend

func _jump(jump_state : JumpState):
	animation_tree["parameters/" + jump_state.animation_name + "/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func _on_set_movement_state(_movement_state : MovementState):
	if player.is_attacking:
		return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(animation_tree, "parameters/movement_blend/blend_position", _movement_state.id, 0.25)
	tween.parallel().tween_property(animation_tree, "parameters/movement_anim_speed/scale", _movement_state.animation_speed, 0.7)

func _on_attack_triggered():
	animation_tree["parameters/AttackOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func enable_sword_hitbox():
	if sword_hitbox:
		sword_hitbox.monitoring = true
		sword_hitbox.monitorable = true

func disable_sword_hitbox():
	if sword_hitbox:
		sword_hitbox.monitoring = false
		sword_hitbox.monitorable = false
