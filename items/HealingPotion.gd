extends Area2D

func _ready():
	connect("body_entered", self, "heal")

func heal(body):
	if body.name == "Player":
		if body.heal():
			queue_free()