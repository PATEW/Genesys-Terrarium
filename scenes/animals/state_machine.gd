extends Node

@export var initial_state: Node

var current_state: Node
var states : Dictionary = {}

@onready var rabbitidle = $rabbitidle
@onready var rabbitfollow = $rabbitfollow

func _ready():
	for child in get_children():
		if child is Node:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
	
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.Do(delta)

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.Exit()
	print("trans")
	new_state.Enter()
	current_state = new_state
