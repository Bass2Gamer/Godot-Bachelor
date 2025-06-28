extends CharacterBody3D

var player = null
var state_machine

@export var speed = 4.0
@export var attack_range = 1.6
@export var player_path : NodePath
@export var hit_stagger : float = 8.0
@export var hit_animation_duration : float = 0.5

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $Skeleton_Warrior/AnimationTree

#func _ready():

#func _process(delta):

func _target_in_range():
	return global_position.distance_to(player.global_position) < attack_range

func _hit_finished():
	if global_position.distance_to(player.global_position) < attack_range + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)

func hit(dir):
	velocity += dir * hit_stagger
	
	if anim_tree:
		anim_tree.set("parameters/conditions/hit", true)
		
		await get_tree().create_timer(hit_animation_duration).timeout
		anim_tree.set("parameters/conditions/hit", false)
