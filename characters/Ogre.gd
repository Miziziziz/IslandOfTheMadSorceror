extends KinematicBody2D

enum States {IDLE, CHASING, ATTACKING, DEAD}
var cur_state = States.IDLE
var player = null

onready var anim_player = $AnimationPlayer
onready var growl_player = $GrowlPlayer
onready var attack_warn_player = $AttackWarnPlayer
onready var death_player = $DeathPlayer

var spot_player_range = 150
var attack_range = 70

var move_speed = 50
var facing_right = true

var key = preload("res://items/Key.tscn")

onready var bludgeon = $Graphics/MainArmBase/ArmAnimPivot/ArmBack/Bludgeon
onready var target = $Graphics/MainArmBase/TargetBase/Target
func _ready():
	$HealthManager.connect("dead", self, "die")

var delta = 0
func _process(d):
	delta = d
	if player == null:
		return
	
	if cur_state == States.IDLE:
		process_idle_state()
	elif cur_state == States.ATTACKING:
		process_attack_state() 
	
	if cur_state == States.DEAD:
		set_bludgeon_final_rest_pos()
	elif cur_state != States.ATTACKING:
		set_bludgeon_rest_pos()
	
var final_rest_pos = Vector2()
func set_bludgeon_final_rest_pos():
	bludgeon.goal_pos = final_rest_pos

func set_bludgeon_rest_pos():
	bludgeon.goal_pos = bludgeon.get_node("BludgeonHead").global_position

func set_bludgeon_attack_pos():
	bludgeon.goal_pos = target.global_position

func switch_to_idle_state():
	cur_state = States.IDLE
	anim_player.play("idle")

var first_spot = true
func switch_to_chase_state():
	if first_spot:
		growl_player.play()
		get_tree().call_group("boss_ui", "init", "Ogre")
		first_spot = false
	cur_state = States.CHASING
	anim_player.play("walk")

func switch_to_attack_state():
	cur_state = States.ATTACKING
	anim_player.play("idle")

func process_idle_state():
	if player_is_in_spot_range():
		switch_to_chase_state()

var attack_timer = 0
var attack_time = 2.0
var rest_time = 2.0
var growled_this_iter = false

func process_attack_state():
	if !player_is_in_attack_range() and (anim_player.current_animation != "attack" or !anim_player.is_playing()):
		switch_to_chase_state()
	
	flip_if_needed(player.global_position - global_position)
	attack_timer += delta
	if attack_timer < attack_time:
		if anim_player.current_animation != "attack":
			anim_player.play("attack")
			growled_this_iter = false
		set_bludgeon_attack_pos()
		attack()
		move_towards_player()
	elif attack_timer > attack_time and attack_timer < attack_time + rest_time:
		if anim_player.current_animation != "idle":
			anim_player.play("idle")
		if attack_timer > attack_time + rest_time - 0.5 and not growled_this_iter:
			growled_this_iter = true
			attack_warn_player.play()
		set_bludgeon_rest_pos()
	elif attack_timer > attack_time + rest_time:
		attack_timer = 0
		
var last_bodies = []
func attack():
	var bodies = bludgeon.get_overlapping_bodies()
	bodies += bludgeon.get_node("BludgeonHead").get_overlapping_bodies()
	for body in bodies:
		if body.has_method("hit") and body != self and not body in last_bodies:
			body.hit(body.global_position - global_position)
	last_bodies = bodies

func _physics_process(delta):
	if cur_state != States.CHASING:
		return
	
	var move_vec = move_towards_player()
	flip_if_needed(move_vec)
	if player_is_in_attack_range():
		switch_to_attack_state()
	if !player_is_in_spot_range():
		switch_to_idle_state()

func move_towards_player():
	var move_vec = (player.global_position - global_position).normalized() * move_speed
	move_and_slide(move_vec, Vector2())
	return move_vec

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
	bludgeon.scale.x *= -1

func hit(dir):
	$HealthManager.hit(dir)
	get_tree().call_group("boss_ui", "update_hp", 1.0 * $HealthManager.hp / $HealthManager.max_hp)

func die():
	cur_state = States.DEAD
	$CollisionShape2D.disabled = true
	anim_player.play("death")
	final_rest_pos = bludgeon.get_node("BludgeonHead").global_position
	get_tree().call_group("boss_ui", "end_fight")
	
	var key_inst = key.instance()
	get_tree().get_root().add_child(key_inst)
	key_inst.global_position = global_position
	death_player.play()
	
