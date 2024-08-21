extends Control

var self_opened = false

func _ready():
	self.visible = false

func toggle_menu():
	self_opened = !self_opened
	if self_opened:
		self.visible = true
	else:
		self.visible = false

func _on_rabbit_input_event(camera, event, event_position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("r1 click")
			toggle_menu()

func _on_rabbit_2_input_event(camera, event, event_position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("r2 click")
			toggle_menu()
