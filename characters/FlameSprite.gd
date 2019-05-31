extends KinematicBody2D

var can_attack = false
var attack_range = 8

var hop_rate = 0.8
var hop_time_waited = 0.0

enum States {HOPPING, IDLE, DEAD}

var cur_state = States.IDLE
var player = null
var facing_right = false
var hop_dir = Vector2()
var move_speed = 50

func _process(delta):
	if can_attack and player_is_in_attack_range():
		attack()
		can_attack = false

func attack():
	player.hit(player.global_position - global_position)

func player_is_in_attack_range():
	return global_position.distance_squared_to(player.global_position) < attack_range * attack_range

func _physics_process(delta):
	hop_time_waited += delta
	if cur_state == States.IDLE and hop_time_waited > hop_rate:
		cur_state = States.HOPPING
		hop()
	elif cur_state == States.HOPPING:
		move_and_slide(hop_dir * move_speed, Vector2())

func hop():
	var move_vec = (player.global_position - global_position).normalized()
	flip_if_needed(move_vec)
	hop_dir = move_vec
	$AnimationPlayer.play("hop")
	can_attack = true

func complete_hop():
	cur_state = States.IDLE
	hop_time_waited = 0.0

func flip_if_needed(move_vec):
	if move_vec.x > 0 and !facing_right:
		flip()
	elif move_vec.x < 0 and facing_right:
		flip()

func flip():
	scale.x *= -1
	facing_right = !facing_right

func hit(dir):
	$AnimationPlayer.play("death")
	$CollisionShape2D.disabled = true
	cur_state = States.DEAD