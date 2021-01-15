extends Control


func _ready():
	pass

func on_leave(to):
	GameGlobals.pause();
	show();

func on_enter(from):
	GameGlobals.resume();
	hide();

func handle_process(delta):
	pass;
