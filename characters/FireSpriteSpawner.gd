extends Node2D

var spawn_time = 1.5
var cur_time = 0
var fire_sprite = preload("res://characters/FlameSprite.tscn")
var player = null

func _process(delta):
	cur_time += delta
	if cur_time > spawn_time:
		var inst = fire_sprite.instance()
		get_parent().get_parent().add_child(inst)
		inst.global_position = global_position
		inst.player = player
		queue_free()
