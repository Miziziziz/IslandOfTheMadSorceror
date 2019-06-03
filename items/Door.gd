extends StaticBody2D

export var is_open = true
export var dont_close = false
var is_setting_up = true

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
	if !is_setting_up:
		$OpenPlayer.play()
	is_setting_up = false

func close():
	$Open.hide()
	$Closed.show()
	$CollisionShape2D.disabled = false
	
	if !is_setting_up and is_open:
		$ClosePlayer.play()
	is_open = false
	is_setting_up = false

func close_check(body):
	if dont_close:
		return
	if body.name == "Player":
		call_deferred("close")

func open_check(body):
	if body.name == "Player" and body.has_key and !is_open:
		call_deferred("open")
		body.remove_key()