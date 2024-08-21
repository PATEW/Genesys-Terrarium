extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	$Rabbit.rabbit_clicked.connect($entity_info.open_and_update_menu)
	$Rabbit2.rabbit_clicked.connect($entity_info.open_and_update_menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
