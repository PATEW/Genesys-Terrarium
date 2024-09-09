extends CharacterBody3D

@export var entity_name: String = ""
@export var entity_health: int = 100
@export var entity_hunger: int = 100
@export var entity_thirst: int = 100
@export var entity_reproduction: int = 0

@export var move_speed := 100.0
@export var stop_distance := 1

var move_direction : Vector3
var wander_time : float

var current_grass_target = null

signal rabbit_clicked(name: String, species: String, health: int, hunger: int, thirst: int, reproduction: int)

@onready var entity_info = $"../entity_info"
@onready var state_chart = $StateChart

func _ready():
	rabbit_clicked.connect(entity_info.open_and_update_menu)

func _physics_process(_delta):
	move_and_slide()

func _on_clickable_area_input_event(_camera, event, _event_position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Rabbit clicked")
			rabbit_clicked.emit(entity_name, "Rabbit", entity_health, entity_hunger, entity_thirst, entity_reproduction)


func _on_food_sensor_area_area_entered(area):
	current_grass_target = area.get_parent()
	state_chart.send_event("grass_entered")


func _on_idle_state_processing(delta):
	velocity = -global_transform.basis.z * move_speed
	
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()

func randomize_wander():
	rotate(Vector3.UP, randf_range(-PI,PI))
	wander_time = randf_range(1, 3)


func _on_idle_state_entered():
	randomize_wander()


func _on_observing_state_processing(delta):
	look_at(current_grass_target.global_position)
	var direction = current_grass_target.global_position - global_position
	var distance = direction.length()

	if distance > stop_distance:
		# Move towards the grass
		velocity = direction.normalized() * move_speed
	else:
		# Stop when close enough
		velocity = Vector3.ZERO
