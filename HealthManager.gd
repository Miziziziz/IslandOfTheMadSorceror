extends Node2D

export var max_hp = 5
var hp = max_hp

var blood_splatter = preload("res://BloodSplatter.tscn")

signal dead
signal hit
signal heal

func _ready():
	hp = max_hp

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

func heal():
	if hp >= max_hp:
		return false
	hp += 1
	emit_signal("heal")
	return true