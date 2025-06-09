extends Node
class_name HealthComponent

signal health_changed(new_health: float)
signal died()

@export var anim_tree : AnimationTree
@export var death_animation_duration : float = 3.0

@export var max_health : float = 100.0:
	set(value):
		max_health = max(0.0, value)
		if current_health > max_health:
			current_health = max_health
		health_changed.emit(current_health)

var current_health : float:
	set(value):
		var old_health = current_health
		current_health = clamp(value, 0.0, max_health)
		if current_health != old_health:
			health_changed.emit(current_health)
			if current_health <= 0.0 and old_health > 0.0:
				died.emit()

var is_dead: bool = false

@onready var enemy = get_parent()

func _ready():
	current_health = max_health
	died.connect(die)

func take_damage(amount: float, hit_source_position: Vector3 = Vector3.ZERO): # NEW: Added hit_source_position
	if is_dead:
		return

	if amount <= 0:
		return
	
	current_health -= amount
	if enemy:
		# Calculate direction from the hit source TO the enemy for stagger
		var stagger_direction = hit_source_position.direction_to(enemy.global_position)
		enemy.hit(stagger_direction)

func die():
	if is_dead:
		return
	is_dead = true
	if anim_tree:
		anim_tree.set("parameters/conditions/die", true)
	await get_tree().create_timer(death_animation_duration).timeout
	get_parent().queue_free()
