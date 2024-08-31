extends Node

const TIMER_LIMIT = 2.0

var timer = 0.0
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer+=delta
	if timer > TIMER_LIMIT:
		timer = 0.0
		print("FPS: "+str(Engine.get_frames_per_second()))
	pass
