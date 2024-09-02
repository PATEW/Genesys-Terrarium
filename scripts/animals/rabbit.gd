extends CharacterBody3D

@export var entity_name: String = ""
@export var entity_health: int = 100
@export var entity_hunger: int = 100
@export var entity_thirst: int = 100
@export var entity_reproduction: int = 0

signal rabbit_clicked(name: String, species: String, health: int, hunger: int, thirst: int, reproduction: int)

@onready var entity_info = $"../entity_info"
@onready var state_manager = $"State Manager"

var current_target: Area3D

func _ready():
	rabbit_clicked.connect(entity_info.open_and_update_menu)

func _physics_process(_delta):
	move_and_slide()
	
	if velocity.length() > 0:
		pass
		#play hop animation

func _on_clickable_area_input_event(_camera, event, _event_position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Rabbit clicked")
			rabbit_clicked.emit(entity_name, "Rabbit", entity_health, entity_hunger, entity_thirst, entity_reproduction)



#func _on_food_sensor_area_body_entered(body):
	#if body.is_in_group("Grass"):
		#print("init touch")
		#state_manager.rabbitidle.emit_signal("Transitioned", state_manager.rabbitidle, "rabbitfollow", body)


func _on_food_sensor_area_area_entered(area):
	print("hello")
	current_target = area
	state_manager.rabbitidle.emit_signal("Transitioned", state_manager.rabbitidle, "rabbitfollow")
