extends AudioStreamPlayer

var main_track = preload("res://audio/music/Desert_Caravan.ogg")
var boss_track = preload("res://audio/music/Hollywood_Traffic_Jam.ogg")
var win_track = preload("res://audio/music/Digital_Memories.ogg")

func play_boss_track(body):
	if stream == boss_track or stream == win_track:
		return
	stream = boss_track
	volume_db = -6
	play()

func play_win_track():
	if stream == win_track:
		return
	stream = win_track
	volume_db = 0
	play()

func stop_playing(body):
	stop()