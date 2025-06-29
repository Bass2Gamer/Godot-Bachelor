extends Node

@export var enemy_scene: PackedScene       
@export var spawn_points: Array[Node] = []  
@export var spawn_count: int = 5           
@export var spawn_interval: float = 2.0   

@export var player: Node                   # Reference to the player node

func _ready() -> void:
	spawn_enemies()  

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

	for i in range(spawn_count):
		var sp :Node = spawn_points.pick_random()
		var enemy := enemy_scene.instantiate()

		# Position / transform copy
		if sp is Node3D and enemy is Node3D:
			enemy.global_transform = sp.global_transform
		elif sp is Node2D and enemy is Node2D:
			enemy.global_position = sp.global_position

		# Pass the player NodePath to the enemy
		enemy.player_path = player.get_path()

		add_child(enemy)

		if i < spawn_count - 1:
			await get_tree().create_timer(spawn_interval).timeout
