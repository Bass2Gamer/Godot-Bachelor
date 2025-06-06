extends Node
class_name HealthComponent

signal health_changed(new_health: float)
signal died()

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

func _ready():
	current_health = max_health
	died.connect(die)

func take_damage(amount: float):
	if is_dead:
		return

	if amount <= 0:
		return
	
	current_health -= amount
	print("Took damage: ", amount, ", Current Health: ", current_health)

func heal(amount: float):
	if amount <= 0:
		return
	current_health += amount
	print("Healed: ", amount, ", Current Health: ", current_health)

func get_health_percentage() -> float:
	if max_health == 0: return 0.0
	return current_health / max_health

func die():
	if is_dead:
		return
	is_dead = true
	print("Enemy died!")
	get_parent().queue_free()
