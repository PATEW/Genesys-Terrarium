extends CharacterBody3D

@export var entity_name: String = ""
@export var entity_health: int = 100
@export var entity_hunger: int = 100
@export var entity_thirst: int = 100
@export var entity_reproduction: int = 0
@export var min_speed: float = 1.0
@export var max_speed: float = 10.0
@export var movement_duration: float = 3.0
@export var hop_height: float = 1.0
@export var hop_duration: float = 0.5

var current_speed: float = 0.0
var is_moving: bool = false
var base_y: float = 1.5
var new_radian_angle: float = 0.0

signal rabbit_clicked(name: String, species: String, health: int, hunger: int, thirst: int, reproduction: int)

@onready var hop_tween: Tween
@onready var entity_info = $"../entity_info"

func _ready():
	rabbit_clicked.connect(entity_info.open_and_update_menu)
	begin_moving()

func begin_moving():
	new_radian_angle = randf_range(-PI,PI)
	global_rotate(Vector3.UP, new_radian_angle)
	current_speed = randf_range(min_speed, max_speed)
	var time_walking_timer = get_tree().create_timer(5)
	time_walking_timer.timeout.connect(stop_moving)
	play_animation("hop")
	is_moving = true

func stop_moving():
	is_moving = false
	play_animation("idle")
	var time_waiting_timer = get_tree().create_timer(5)
	time_waiting_timer.timeout.connect(begin_moving)

func _physics_process(_delta):
	if is_moving:
		var direction = Vector3(sin(rotation.y), 0, cos(rotation.y))
		velocity = direction * current_speed * -1
		move_and_slide()
	else:
		velocity = Vector3.ZERO

func play_animation(anim_name: String):
	if anim_name == "hop":
		if hop_tween:
			hop_tween.kill()
		hop_tween = create_tween().set_loops()
		hop_tween.tween_property(self, "transform:origin:y", base_y + hop_height, hop_duration / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		hop_tween.tween_property(self, "transform:origin:y", base_y, hop_duration / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	elif anim_name == "idle":
		if hop_tween:
			hop_tween.kill()
		create_tween().tween_property(self, "transform:origin:y", base_y, 0.1)

func _on_clickable_area_input_event(_camera, event, _event_position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Rabbit clicked")
			rabbit_clicked.emit(entity_name, "Rabbit", entity_health, entity_hunger, entity_thirst, entity_reproduction)


func _on_food_sensor_area_area_entered(_area):
	print("touching grass")
