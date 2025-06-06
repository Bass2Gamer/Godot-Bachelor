extends Node
class_name CameraController

signal set_cam_rotation(_cam_rotation : float)
@export var player : CharacterBody3D
@onready var yaw_node = $CamYaw
@onready var pitch_node = $CamYaw/CamPitch
@onready var spring_arm = $CamYaw/CamPitch/SpringArm3D
@onready var camera = $CamYaw/CamPitch/SpringArm3D/Camera3D

@export_group("Camera Settings")
@export var yaw : float = 0
@export var pitch : float = 0
@export var yaw_sensitivity : float = 0.07
@export var pitch_sensitivity : float = 0.07
@export var yaw_acceleration : float = 15
@export var pitch_acceleration : float = 15
@export var pitch_max : float = 75
@export var pitch_min : float = -55

var tween : Tween

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spring_arm.add_excluded_object(player.get_rid())

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += event.relative.y * pitch_sensitivity

func _physics_process(delta):
	pitch = clamp(pitch, pitch_min, pitch_max)
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
	set_cam_rotation.emit(yaw_node.rotation.y)
	
func _on_set_movement_state(_movement_state : MovementState):
	if player.is_attacking:
		return
	set_fov(_movement_state.camera_fov)

func set_fov(value : float):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(camera, "fov", value, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
