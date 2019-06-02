extends Area2D

var travel_dir = Vector2()
var move_speed = 150
var life_span = 12.0
var cur_life = 0.0
var hit_player = false

func _physics_process(delta):
	cur_life += delta
	if cur_life > life_span:
		queue_free()
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.has_method("hit") and body.name == "Player" and !hit_player:
			body.hit(body.global_position - global_position)
			hit_player = true
	
	global_position += travel_dir * move_speed * delta