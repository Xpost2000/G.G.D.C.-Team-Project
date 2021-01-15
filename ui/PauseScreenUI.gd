extends Control


func _ready():
	pass

func on_leave(to):
	GameGlobals.resume();
	hide();
	print("un_pause");

func on_enter(from):
	GameGlobals.pause();
	show();
	print("pause");

func handle_process(delta):
	if Input.is_action_just_pressed("game_action_ui_pause"):
		get_parent().get_parent().toggle_pause();
