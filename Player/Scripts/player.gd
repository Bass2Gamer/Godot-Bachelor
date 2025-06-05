extends CharacterBody3D

signal pressed_jump(jump_state : JumpState)
signal set_movement_state(_movement_state: MovementState)
signal set_movement_direction(_movement_direction: Vector3)

@export var jump_states : Dictionary
@export var movement_states : Dictionary

var movement_direction : Vector3

func _input(event):
	if event.is_action("movement"):
		movement_direction.x = Input.get_action_strength("left") - Input.get_action_strength("right")
		movement_direction.z = Input.get_action_strength("forward") - Input.get_action_strength("backwards")

		if is_movement_ongoing():
			set_movement_state.emit(movement_states["run"])
		else:
			set_movement_state.emit(movement_states["idle"])

func _ready():
	set_movement_state.emit(movement_states["idle"])

func _physics_process(delta):
	if is_movement_ongoing():
		set_movement_direction.emit(movement_direction)

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			pressed_jump.emit(jump_states["ground_jump"])

func is_movement_ongoing() -> bool:
	return abs(movement_direction.x) > 0 or abs(movement_direction.z) > 0
