extends Node3D

var grass_area =  preload("res://scenes/grass_area.tscn")


func _ready():
	grass_area.instantiate()
