extends Area2D


onready var b_links = []
var link_count = 0
var seg_len = 2
onready var goal_pos = $BludgeonHead.global_position

func _ready():
	b_links = get_children()
	link_count = get_child_count()

func _physics_process(delta):
	#skip first one
	var start_pos = b_links[0].global_position
	for i in range(5):
		process_links(range(link_count - 1, -1, -1), goal_pos)
		process_links(range(link_count), start_pos)

func process_links(ind_range, g_pos):
	var last_link = null
	for i in ind_range:
		var link = b_links[i]
		if last_link == null:
			last_link = link
			link.global_position = g_pos
			continue
		var last_pos = last_link.global_position
		var cur_pos = link.global_position
		var dir = cur_pos - last_pos
		var dis = dir.length()
		last_link.global_rotation = dir.angle() + PI / 2.0
		if dis <= seg_len:
			last_link = link
			continue
		
		dir /= dis
		link.global_position = last_pos + dir * seg_len
		last_link = link
		