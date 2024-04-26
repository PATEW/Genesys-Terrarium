extends CharacterBody3D

@export var min_speed: int = 1
@export var max_speed: int = 10
@export var rotation_speed: float = 1.7

var target_rotation_y: float = 0.0

func _ready():
	randomize()

func _process(delta):
	if rotation.y != target_rotation_y:
		# Smoothly interpolate the rotation towards the target
		rotation.y = lerp_angle(rotation.y, target_rotation_y, rotation_speed * delta)
		if abs(rotation.y - target_rotation_y) < 0.01:  # Check if close enough to target
			rotation.y = target_rotation_y  # Correct any minor floating point errors

	# Update the velocity and move only after rotation is done
	if rotation.y == target_rotation_y:
		var random_speed = randi_range(min_speed, max_speed)
		velocity = Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * random_speed
		
	# Ensure move_and_slide uses the updated built-in velocity
	move_and_slide()

func _on_timer_timeout():
	target_rotation_y = randf_range(-PI, PI)
