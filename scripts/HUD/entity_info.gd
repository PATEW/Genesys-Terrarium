extends Control

@onready var stat_list_name = $"Menu Box/HBoxContainer/Stat Values/Name"
@onready var stat_list_species = $"Menu Box/HBoxContainer/Stat Values/Species"
@onready var stat_list_health = $"Menu Box/HBoxContainer/Stat Values/Health"
@onready var stat_list_hunger = $"Menu Box/HBoxContainer/Stat Values/Hunger"
@onready var stat_list_thirst = $"Menu Box/HBoxContainer/Stat Values/Thirst"
@onready var stat_list_reproduction = $"Menu Box/HBoxContainer/Stat Values/Reproduction"



func _ready():
	self.visible = false

func open_and_update_menu(new_name: String, new_species: String, new_health: int, new_hunger: int, new_thirst: int, new_reproduction: int):
	stat_list_name.text = new_name
	stat_list_species.text = new_species
	stat_list_health.text = str(new_health)
	stat_list_hunger.text = str(new_hunger)
	stat_list_thirst.text = str(new_thirst)
	stat_list_reproduction.text = str(new_reproduction)
	
	self.visible = true


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		self.visible = false
