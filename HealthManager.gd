extends Node2D

export var max_hp = 5
var hp = max_hp

var blood_splatter = preload("res://BloodSplatter.tscn")

signal dead
signal hit

func hit(dir: Vector2):
	emit_signal("hit")
	var bs = blood_splatter.instance()
	get_tree().get_root().add_child(bs)
	bs.global_position = global_position
	bs.global_rotation = dir.angle()
	bs.emitting = true
	bs.get_node("Particles2D").emitting = true
	hp -= 1
	if hp <= 0:
		emit_signal("dead")