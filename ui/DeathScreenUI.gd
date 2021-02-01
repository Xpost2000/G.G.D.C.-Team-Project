extends Control

func _on_Restart_pressed():	
	GameGlobals.resume();
	GameGlobals.reload_scene(GameGlobals.MAIN_GAME_SCENE);
	GameGlobals.reload_scene(GameGlobals.BATTLE_SCENE);
	GameGlobals.switch_to_scene(GameGlobals.MAIN_GAME_SCENE);
	QuestsGlobal.reset_all_quests();
	AudioGlobal.pause_music();

	GameGlobals.get_scene(GameGlobals.MAIN_GAME_SCENE).current_level_node().play_cutscene("Introduction");

func _on_Menu_pressed():
	GameGlobals.switch_to_scene(1);

func _on_Quit_pressed():
	get_tree().quit();

func _ready():
	$Selections/Restart.connect("pressed", self, "_on_Restart_pressed");
	$Selections/Menu.connect("pressed", self, "_on_Menu_pressed");
	$Selections/Quit.connect("pressed", self, "_on_Quit_pressed");
	pass

func on_leave(to):
	GameGlobals.resume();
	hide();

func on_enter(from):
	GameGlobals.pause();
	show();
	$Selections/Restart.grab_focus();

func handle_process(delta):
	pass;
