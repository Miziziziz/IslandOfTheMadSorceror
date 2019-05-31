extends Particles2D

var delete_after_time = 4.0
var time = 0.0

func _process(delta):
	time += delta
	if time > delete_after_time:
		queue_free()
