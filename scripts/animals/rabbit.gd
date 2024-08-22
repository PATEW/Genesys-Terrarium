extends CharacterBody3D

# Stats
@export var entity_name: String = ""
@export var entity_health: int = 100
@export var entity_hunger: int = 100
@export var entity_thirst: int = 100
@export var entity_reproduction: int = 0
@export var min_speed: float = 1.0
@export var max_speed: float = 10.0
@export var movement_duration: float = 3.0  # Duration of movement in seconds
@export var hop_height: float = 1.0  # Maximum height of the hop
@export var hop_duration: float = 0.5  # Duration of a single hop

var current_speed: float = 0.0
var is_moving: bool = true
var base_y: float = 0.0  # Store the base Y position

signal rabbit_clicked(name: String, species: String, health: int, hunger: int, thirst: int, reproduction: int)

@onready var walk_timer = $walk_timer
@onready var stop_timer = $stop_timer
@onready var hop_tween: Tween

@onready var entity_info = $"../entity_info"

func _ready():
	rabbit_clicked.connect(entity_info.open_and_update_menu)
	randomize()
	walk_timer.wait_time = movement_duration
	walk_timer.one_shot = false
	walk_timer.autostart = true
	walk_timer.timeout.connect(on_walk_timer_timeout)
	
	stop_timer.one_shot = true
	stop_timer.timeout.connect(resume_movement)
	
	base_y = global_transform.origin.y
	pick_new_direction()

func _physics_process(_delta):
	if is_moving:
		move_forward()

func move_forward():
	var direction = Vector3(sin(rotation.y), 0, cos(rotation.y))
	velocity = direction * current_speed * -1
	move_and_slide()

func pick_new_direction():
	rotation.y = randf_range(-PI, PI)
	current_speed = randf_range(min_speed, max_speed)
	play_animation("hop")

func on_walk_timer_timeout():
	if randf() < 0.5:  # 50% chance to stop
		stop_movement()
	else:
		pick_new_direction()

func stop_movement():
	is_moving = false
	velocity = Vector3.ZERO
	stop_timer.wait_time = randf_range(1.0, 3.0)
	stop_timer.start()
	play_animation("idle")

func resume_movement():
	is_moving = true
	pick_new_direction()

func play_animation(anim_name: String):
	if anim_name == "hop":
		hop_animation()
	elif anim_name == "idle":
		stop_hop_animation()

func hop_animation():
	if hop_tween:
		hop_tween.kill()
	
	hop_tween = create_tween().set_loops()
	hop_tween.tween_property(self, "transform:origin:y", base_y + hop_height, hop_duration / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	hop_tween.tween_property(self, "transform:origin:y", base_y, hop_duration / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func stop_hop_animation():
	if hop_tween:
		hop_tween.kill()
	
	# Ensure the rabbit is at its base height
	var tween = create_tween()
	tween.tween_property(self, "transform:origin:y", base_y, 0.1)

func _on_clickable_area_input_event(_camera, event, _event_position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Rabbit clicked")
			rabbit_clicked.emit(entity_name, "Rabbit", entity_health, entity_hunger, entity_thirst, entity_reproduction)
