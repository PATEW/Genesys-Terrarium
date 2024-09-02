extends Node
class_name rabbitidle

@export var rabbit: CharacterBody3D
@export var movespeed := 100.0

signal Transitioned

var move_direction : Vector3
var wander_time : float

func randomize_wander():
	rabbit.rotate(Vector3.UP, randf_range(-PI,PI))
	wander_time = randf_range(1, 3)

func Enter():
	randomize_wander()

func Exit():
	pass

func Do(delta: float):
	if rabbit:
		rabbit.velocity = -rabbit.global_transform.basis.z * movespeed
	
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()
