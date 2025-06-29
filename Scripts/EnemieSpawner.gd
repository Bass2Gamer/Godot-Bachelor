extends Node

	 
@export var spawn_interval: float = 2.0   

@export var player: Node

func _ready() -> void: 

func spawn_enemies() -> void:
	if enemy_scene == null:
		push_error("enemy_scene is not assigned!")
		return
	if spawn_points.is_empty():
		push_error("spawn_points array is empty!")
		return
	if player == null:
		push_error("Player node is not assigned!")
		return

		enemy.player_path = player.get_path()
		if i < spawn_count - 1:
			await get_tree().create_timer(spawn_interval).timeout
