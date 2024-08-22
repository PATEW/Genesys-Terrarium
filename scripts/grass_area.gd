extends Area3D

class_name GrassArea

@export var min_grass: int = 1
@export var max_grass: int = 5
@export var grass_area_timeout: float = 5
@export var spawn_active: bool = true

var grass_scene = preload("res://scenes/grass.tscn")

var spawnArea: CylinderShape3D
var origin: Vector3
# Called when the node enters the scene tree for the first time.
func _ready():
	for children in get_children():
		if children is CollisionShape3D:
			spawnArea = children.shape
			origin = children.global_position
			
	setup_timer()
	
func setup_timer():
	var timer = Timer.new()
	timer.connect("timeout", Callable(self, "_on_grass_spawner_timer_timeout"))
	timer.set_wait_time(grass_area_timeout)
	timer.set_one_shot(false)
	add_child(timer)
	timer.start()


func get_random_pos():
	var radius = spawnArea.radius
	var height = spawnArea.height
	
	var angle = randf() * TAU
	
	var distance = sqrt(randf()) * radius
	var x = cos(angle) * distance
	var z = sin(angle) * distance
	
	return Vector3(x,height/2,z) + origin

func _on_grass_spawner_timer_timeout():
	if spawn_active:
		spawn_grass()

func spawn_grass():

	var num_grass = randi_range(min_grass, max_grass)
	
	for i in range(num_grass):
		var grass = grass_scene.instantiate()
		var grass_shape = grass.get_aabb().size
		
		
		var random_pos = get_random_pos()
		var grass_pos = Vector3(random_pos.x - grass_shape.x, random_pos.y / 2, random_pos.z - grass_shape.z) 
		
		add_child(grass)
		grass.global_position = grass_pos
