extends KinematicBody2D

enum States {IDLE, CHASING, ATTACKING, DEAD}
var cur_state = States.IDLE
var player = null

onready var anim_player = $AnimationPlayer

var spot_player_range = 150
var attack_range = 20

var attack_rate = 0.8
var last_attack_time = -2.0

var move_speed = 50
var facing_right = true

var flame_sprite = preload("res://characters/FlameSprite.tscn")

func _process(delta):
	if player == null:
		return
	
	if cur_state == States.IDLE:
		process_idle_state()
	elif cur_state == States.ATTACKING:
		process_attack_state() 

func switch_to_idle_state():
	cur_state = States.IDLE
	anim_player.play("idle")

func switch_to_chase_state():
	cur_state = States.CHASING
	anim_player.play("walk")

func switch_to_attack_state():
	cur_state = States.ATTACKING
	anim_player.play("idle")

func process_idle_state():
	if player_is_in_spot_range():
		switch_to_chase_state()

func process_attack_state():
	if !player_is_in_attack_range() and (anim_player.current_animation != "attack" or !anim_player.is_playing()):
		switch_to_chase_state()
	
	flip_if_needed(player.global_position - global_position)
	
	var cur_time = OS.get_ticks_msec() / 1000.0
	if cur_time - last_attack_time > attack_rate:
		attempt_attack()
		last_attack_time = cur_time

var attack_dir = Vector2()
var attack_arc = 0.9
func attempt_attack():
	anim_player.play("attack")
	attack_dir = player.global_position - global_position

func perform_attack():
	var new_attack_dir = player.global_position - global_position
	var d = (new_attack_dir).dot(attack_dir)
	if d > attack_arc and player_is_in_attack_range():
		player.hit(new_attack_dir)

func _physics_process(delta):
	if cur_state != States.CHASING:
		return
	
	var move_vec = (player.global_position - global_position).normalized() * move_speed
	move_and_slide(move_vec, Vector2())
	
	flip_if_needed(move_vec)
	if player_is_in_attack_range():
		switch_to_attack_state()
	if !player_is_in_spot_range():
		switch_to_idle_state()

func player_is_in_attack_range():
	return global_position.distance_squared_to(player.global_position) < attack_range * attack_range

func player_is_in_spot_range():
	return global_position.distance_squared_to(player.global_position) < spot_player_range * spot_player_range

func flip_if_needed(move_vec):
	if move_vec.x > 0 and !facing_right:
		flip()
	elif move_vec.x < 0 and facing_right:
		flip()

func flip():
	scale.x *= -1
	facing_right = !facing_right

func hit(dir):
	cur_state = States.DEAD
	$CollisionShape2D.disabled = true
	anim_player.play("death")
	$HealthManager.hit(dir)
	var fs = flame_sprite.instance()
	get_tree().get_root().add_child(fs)
	fs.global_position = global_position
	fs.player = player
