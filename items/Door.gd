extends StaticBody2D

export var is_open = true

func _ready():
	if is_open:
		open()
	else:
		close()
	
	$CloseDoorBehind.connect("body_entered", self, "close_check")
	$OpenIfHaveKey.connect("body_entered", self, "open_check")

func open():
	$Open.show()
	$Closed.hide()
	$CollisionShape2D.disabled = true
	is_open = true

func close():
	$Open.hide()
	$Closed.show()
	$CollisionShape2D.disabled = false
	is_open = false

func close_check(body):
	if body.name == "Player":
		call_deferred("close")

func open_check(body):
	if body.name == "Player" and body.has_key and !is_open:
		call_deferred("open")
		body.remove_key()