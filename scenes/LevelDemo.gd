extends "res://scenes/SceneBase.gd"

func handle_process(delta):
	AudioGlobal.looped_play_music("snd/bg1soundtrack/the_beregost_night.ogg", true);
