extends Node2D

func set_full():
	$EmptyBar.hide()
	$FullBar.show()

func set_empty():
	$EmptyBar.show()
	$FullBar.hide()