extends Area2D

func _ready():
	connect("body_entered", self, "give_key")

func give_key(body):
	if body.name == "Player":
		if !body.has_key:
			body.give_key()
			queue_free()