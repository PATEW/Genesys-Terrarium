extends Node
class_name rabbitfollow

@export var rabbit: CharacterBody3D
@export var move_speed := 2.0  # Reduced speed for smoother movement
@export var stop_distance := 1  # Distance at which the rabbit stops

var target: Area3D
signal Transitioned

func Enter():
	print("now in follow state")

func Exit():
	pass

func Do(_delta: float):
	target = owner.get("current_target") #returns null instance
	var direction = target.global_position - rabbit.global_position
	var distance = direction.length()

	if distance > stop_distance:
		# Move towards the grass
		rabbit.velocity = direction.normalized() * move_speed
	else:
		# Stop when close enough
		rabbit.velocity = Vector3.ZERO
		print("Rabbit reached the grass")
