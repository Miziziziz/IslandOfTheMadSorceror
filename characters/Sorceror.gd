extends KinematicBody2D

enum MainStates {IDLE, START_PHASE, END_PHASE, DEAD}
enum CombatStates {IDLE, CASTING_FIRE, CASTING_SHADOW}

var cur_main_state = MainStates.IDLE
var cur_combat_state = CombatStates.IDLE

onready var anim_player = $AnimationPlayer
onready var health_manager = $HealthManager

var detect_player_range = 200
var player = null

var facing_right = false

var hat = preload("res://characters/Hat.tscn")
var darkness_spell = preload("res://characters/DarknessSpell.tscn")
var fire_spell = preload("res://characters/FireSpell.tscn")

var start_phase_logic = {
	"idle_time": 1.0,
	"fire_cast_time": 1.0,
	"darkness_cast_time": 1.0,
	"pattern": ["fire", "darkness", "darkness", "fire", "darkness"]
}
var end_phase_logic = {
	"idle_time": 2.5,
	"fire_cast_time": 2.0,
	"darkness_cast_time": 4.0,
	"pattern": ["fire", "darkness", "darkness", "darkness", "fire", "darkness"]
}

var combat_state_time = 0
var combat_state_pattern_ind = 0

func _ready():
	$HealthManager.connect("dead", self, "switch_to_dead_state")

func _process(delta):
	if player == null:
		return
	if cur_main_state == MainStates.IDLE:
		if global_position.distance_squared_to(player.global_position) < detect_player_range * detect_player_range:
			switch_to_start_phase()
	elif cur_main_state == MainStates.START_PHASE:
		combat_state_time += delta
		process_start_phase()
		if health_manager.hp <= health_manager.max_hp / 2:
			switch_to_end_phase()
	elif cur_main_state == MainStates.END_PHASE:
		combat_state_time += delta
		process_end_phase()
		

func switch_to_start_phase():
	get_tree().call_group("boss_ui", "init", "Sorceror")
	combat_state_time = 0
	combat_state_pattern_ind = 0
	cur_main_state = MainStates.START_PHASE
	cur_combat_state = CombatStates.IDLE

func switch_to_end_phase():
	combat_state_time = 0
	combat_state_pattern_ind = 0
	cur_main_state = MainStates.END_PHASE
	cur_combat_state = CombatStates.IDLE
	anim_player.play("rage")
	var hat_inst = hat.instance()
	get_parent().add_child(hat_inst)
	hat_inst.global_position = $HatSpawnPoint.global_position

func switch_to_dead_state():
	cur_main_state = MainStates.DEAD
	anim_player.play("dead")
	$CollisionShape2D.disabled = true
	get_tree().call_group("boss_ui", "end_fight")

func process_start_phase():
	flip_if_needed(player.global_position - global_position)
	if cur_combat_state == CombatStates.IDLE:
		if combat_state_time > start_phase_logic["idle_time"]:
			combat_state_time = 0
			var action = get_next_action(start_phase_logic)
			if action == "fire":
				cur_combat_state = CombatStates.CASTING_FIRE
				anim_player.play("channel_fire")
			else:
				cur_combat_state = CombatStates.CASTING_SHADOW
				anim_player.play("channel_darkness")
				
	elif cur_combat_state == CombatStates.CASTING_FIRE:
		if combat_state_time > start_phase_logic["fire_cast_time"]:
			combat_state_time = 0
			anim_player.play("cast_fire")
	elif cur_combat_state == CombatStates.CASTING_SHADOW:
		if combat_state_time > start_phase_logic["darkness_cast_time"]:
			combat_state_time = 0
			anim_player.play("cast_darkness")
	
func process_end_phase():
	flip_if_needed(player.global_position - global_position)	
	if cur_combat_state == CombatStates.IDLE:
		if combat_state_time > end_phase_logic["idle_time"]:
			combat_state_time = 0
			var action = get_next_action(end_phase_logic)
			if action == "fire":
				cur_combat_state = CombatStates.CASTING_FIRE
				anim_player.play("cast_fire_fast")
			else:
				cur_combat_state = CombatStates.CASTING_SHADOW
				anim_player.play("cast_darkness_fast")
				
	elif cur_combat_state == CombatStates.CASTING_FIRE:
		if combat_state_time > end_phase_logic["fire_cast_time"]:
			combat_state_time = 0
			cur_combat_state = CombatStates.IDLE
			anim_player.play("rage")
	elif cur_combat_state == CombatStates.CASTING_SHADOW:
		if combat_state_time > end_phase_logic["darkness_cast_time"]:
			combat_state_time = 0
			cur_combat_state = CombatStates.IDLE
			anim_player.play("rage")

func get_next_action(phase_logic):
	var pattern = phase_logic["pattern"]
	var action = pattern[combat_state_pattern_ind]
	inc_pattern_ind(pattern)
	return action

func inc_pattern_ind(pattern):
	combat_state_pattern_ind += 1
	combat_state_pattern_ind %= pattern.size()

func cast_fire():
	if cur_main_state == MainStates.START_PHASE:
		cur_combat_state = CombatStates.IDLE
		combat_state_time = 0
		anim_player.play("idle")
	var fire_inst = fire_spell.instance()
	get_parent().add_child(fire_inst)
	fire_inst.global_position = global_position
	fire_inst.init(player)

func cast_darkness():
	if cur_main_state == MainStates.START_PHASE:
		cur_combat_state = CombatStates.IDLE
		combat_state_time = 0
		anim_player.play("idle")
	var darkness_inst = darkness_spell.instance()
	get_tree().get_root().add_child(darkness_inst)
	darkness_inst.global_position = global_position
	darkness_inst.travel_dir = (player.global_position - global_position).normalized()

func flip_if_needed(move_vec):
	if move_vec.x > 0 and !facing_right:
		flip()
	elif move_vec.x < 0 and facing_right:
		flip()

func flip():
	scale.x *= -1
	facing_right = !facing_right

func hit(dir):
	health_manager.hit(dir)
	get_tree().call_group("boss_ui", "update_hp", 1.0 * health_manager.hp / health_manager.max_hp)
	