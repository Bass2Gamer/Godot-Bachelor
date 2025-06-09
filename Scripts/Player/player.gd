extends CharacterBody3D

signal pressed_jump(jump_state : JumpState)
signal set_movement_state(_movement_state: MovementState)
signal set_movement_direction(_movement_direction: Vector3)
signal attack_triggered()
signal player_hit()

@export var jump_states : Dictionary
@export var movement_states : Dictionary
@export var attack_duration : float = 0.5
@export var player_damage : float = 20.0
@export var hit_stagger : float = 8.0

var movement_direction : Vector3

var is_attacking : bool = false
var enemies_hit_this_swing : Array[Node]

@onready var attack_timer = Timer.new()

@export var sword_hitbox : Area3D

func _ready():
	set_movement_state.emit(movement_states["idle"])
	add_child(attack_timer)
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)

	if sword_hitbox:
		sword_hitbox.body_entered.connect(_on_sword_hitbox_body_entered)
		sword_hitbox.monitoring = false
		sword_hitbox.monitorable = false

func _input(event):
	if event.is_action("movement"):
		movement_direction.x = Input.get_action_strength("left") - Input.get_action_strength("right")
		movement_direction.z = Input.get_action_strength("forward") - Input.get_action_strength("backwards")

		if not is_attacking:
			var movement_active = is_movement_ongoing()
			if movement_active:
				set_movement_state.emit(movement_states["run"])
			else:
				set_movement_state.emit(movement_states["idle"])
	
	if event.is_action_pressed("attack"):
		if not is_attacking and is_on_floor():
			is_attacking = true
			attack_triggered.emit()
			set_movement_state.emit(movement_states["idle"])
			
			enemies_hit_this_swing.clear()
			
			attack_timer.start(attack_duration)

func _physics_process(delta):
	if is_movement_ongoing():
		set_movement_direction.emit(movement_direction)
	else:
		set_movement_direction.emit(Vector3.ZERO)

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			pressed_jump.emit(jump_states["ground_jump"])

func is_movement_ongoing() -> bool:
	return abs(movement_direction.x) > 0 or abs(movement_direction.z) > 0

func _on_attack_timer_timeout():
	is_attacking = false
	var movement_active = is_movement_ongoing()
	if movement_active:
		set_movement_state.emit(movement_states["run"])
	else:
		set_movement_state.emit(movement_states["idle"])

func _on_sword_hitbox_body_entered(body: Node3D):
	var health_comp = body.get_node_or_null("HealthComponent")
	
	if health_comp and health_comp is HealthComponent and not health_comp.is_dead and not enemies_hit_this_swing.has(body):
		health_comp.take_damage(player_damage, global_position)
		enemies_hit_this_swing.append(body)

func hit(dir):
	emit_signal("player_hit")
	velocity += dir * hit_stagger
