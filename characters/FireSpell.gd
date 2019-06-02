extends KinematicBody2D

func init(player):
	for child in get_children():
		if "player" in child:
			child.player = player
	var move_vec = player.global_position - global_position
	move_and_collide(move_vec)

func _process(delta):
	if get_child_count() <= 1:
		queue_free()