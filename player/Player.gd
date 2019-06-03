extends KinematicBody2D

enum States {NORMAL, ATTACKING, ROLLING, DEAD, CUTSCENE}
enum Directions {UP, RIGHT, DOWN, LEFT, NONE}

var cur_state = States.NORMAL
var cur_attack_dir = Directions.NONE

var move_speed = 120
var last_move_direction = Vector2(1, 0)
var roll_speed = 200
var roll_start_time = 0.0
var time_stopped_rolling = -2.0
var roll_rest_time = 0.1

var time_attacked = -2.0
var attack_rest_time = 0.1

var has_key = false

onready var anim_player = $AnimationPlayer
onready var slash_player = $SlashPlayer
onready var death_player = $DeathPlayer
onready var hurt_player = $HurtPlayer
onready var roll_player = $RollPlayer

var facing_right = true

func _ready():
	$HealthManager.connect("dead", self, "die")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	for n in get_tree().get_nodes_in_group("need_player_ref"):
		n.player = self

func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if cur_state == States.DEAD:
		if Input.is_action_just_pressed("restart"):
			restart()
		return
	if cur_state == States.CUTSCENE:
		return
	
	var cur_time = OS.get_ticks_msec() / 1000.0
	if cur_attack_dir != Directions.NONE and cur_time - time_attacked > attack_rest_time:
			cur_state = States.ATTACKING
			attack()
			time_attacked = cur_time

	update_attack_input()

func _physics_process(_delta):
	if cur_state == States.NORMAL or cur_state == States.ATTACKING:
		if Input.is_action_just_pressed("roll") and OS.get_ticks_msec() / 1000.0 - time_stopped_rolling > roll_rest_time:
			cur_state = States.ROLLING
			roll_start_time = OS.get_ticks_msec() / 1000.0
			
	if cur_state == States.NORMAL:
		process_movement()
	elif cur_state == States.ROLLING:
		process_rolling()

func update_attack_input():
	if Input.is_action_just_pressed("attack_down"):
		cur_attack_dir = Directions.DOWN
	elif Input.is_action_just_pressed("attack_up"):
		cur_attack_dir = Directions.UP
	elif Input.is_action_just_pressed("attack_right"):
		cur_attack_dir = Directions.RIGHT
	elif Input.is_action_just_pressed("attack_left"):
		cur_attack_dir = Directions.LEFT
	else:
		cur_attack_dir = Directions.NONE

func process_rolling():
	attempt_to_play_anim("roll")
	if OS.get_ticks_msec() / 1000.0 - roll_start_time> anim_player.current_animation_length:
		cur_state = States.NORMAL
		time_stopped_rolling = OS.get_ticks_msec() / 1000.0
	var move_vec = get_move_vec()
	if move_vec == Vector2():
		move_vec = last_move_direction
	
	move_vec *= roll_speed
	move_and_slide(move_vec, Vector2())
	flip_if_needed(move_vec)

func process_movement():
	var move_vec = get_move_vec() * move_speed
	move_and_slide(move_vec, Vector2())
	
	flip_if_needed(move_vec)
	if move_vec != Vector2():
		attempt_to_play_anim("walk")
	else:
		attempt_to_play_anim("idle")

func get_move_vec():
	var move_vec = Vector2()
	if Input.is_action_pressed("move_down"):
		move_vec.y += 1
	if Input.is_action_pressed("move_up"):
		move_vec.y -= 1
	if Input.is_action_pressed("move_right"):
		move_vec.x += 1
	if Input.is_action_pressed("move_left"):
		move_vec.x -= 1
	
	if move_vec != Vector2():
		last_move_direction = move_vec
	return move_vec.normalized()

func flip_if_needed(move_vec):
	if move_vec.x > 0 and !facing_right:
		flip()
	elif move_vec.x < 0 and facing_right:
		flip()

func attack():
	var bodies = []
	if cur_attack_dir == Directions.RIGHT:
		if !facing_right:
			flip()
		bodies = $RightSlashBody.get_overlapping_bodies()
		anim_player.play("slash_right")
	elif cur_attack_dir == Directions.LEFT:
		if facing_right:
			flip()
		bodies = $RightSlashBody.get_overlapping_bodies()
		anim_player.play("slash_right")
	elif cur_attack_dir == Directions.DOWN:
		bodies = $DownSlashBody.get_overlapping_bodies()
		anim_player.play("slash_down")
	else:
		bodies = $UpSlashBody.get_overlapping_bodies()
		anim_player.play("slash_up")
	var hit_something = false
	for body in bodies:
		if body.has_method("hit") and body != self:
			hit_something = true
			body.hit(body.global_position - global_position)
	if !hit_something:
		slash_player.stop()
		slash_player.play()

func attempt_to_play_anim(anim):
	if anim_player.current_animation != anim:
		anim_player.play(anim)

func flip():
	scale.x *= -1
	facing_right = !facing_right

func return_to_normal_state():
	cur_state = States.NORMAL

func hit(dir):
	if cur_state == States.ROLLING:
		return
	$HealthManager.hit(dir)
	if cur_state != States.DEAD:
		hurt_player.play()

func heal():
	var did_heal = $HealthManager.heal()
	if did_heal:
		$HealPlayer.play()
	return did_heal

func give_key():
	has_key = true
	$PlayerUI/KeyGraphics.show()
	$KeyPlayer.play()

func remove_key():
	has_key = false
	$PlayerUI/KeyGraphics.hide()

func die():
	if cur_state == States.DEAD:
		return
	$PlayerUI/YouDiedDisplay.show()
	cur_state = States.DEAD
	anim_player.play("die")
	var bs = $Graphics/BloodSplatter
	bs.show()
	bs.one_shot = false
	bs.emitting = true
	death_player.play()

func restart():
	get_tree().reload_current_scene()