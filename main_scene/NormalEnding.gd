extends Node2D

func _ready():
	pass

var timer = 0;
func _process(delta):
	timer += delta;
	if timer >= 10.0:
		GameGlobals.switch_to_scene(GameGlobals.MAIN_MENU_SCENE);
