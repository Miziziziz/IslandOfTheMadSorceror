extends Control

var ind = 0

func _ready():
	ind = get_child_count() - 1

func hurt():
	if ind < 0:
		return
	get_child(ind).set_empty()
	ind -= 1

func heal():
	if ind >= get_child_count() - 1:
		return
	ind += 1
	get_child(ind).set_full()
