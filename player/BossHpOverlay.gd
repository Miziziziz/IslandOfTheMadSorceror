extends CanvasLayer

onready var start_width = $Panel/ColorRect.rect_size.x

func init(boss_name):
	$Panel.show()
	$Panel/Label.text = boss_name
	$Panel/ColorRect.rect_size.x = start_width

func update_hp(ratio):
	$Panel/ColorRect.rect_size.x = start_width * ratio

func end_fight():
	$Panel.hide()