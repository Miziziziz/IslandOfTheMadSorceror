extends Area2D

export var message = ""
export var trigger_end = false

func _ready():
	connect("body_entered", self, "show_message")
	connect("body_exited", self, "hide_message")
	$CanvasLayer/Control/Label.text = message

func show_message(body):
	if body.name == "Player":
		$CanvasLayer/Control.show()
		if trigger_end:
			body.cur_state = body.States.CUTSCENE
			$CanvasLayer/ColorRect/AnimationPlayer.play("fade_in")

func hide_message(body):
	if body.name == "Player":
		$CanvasLayer/Control.hide()
		