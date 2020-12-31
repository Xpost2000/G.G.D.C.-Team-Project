extends Node;

# Shove any global variable or state here?
var action_paused = false;

func paused():
	return action_paused;

func toggle_pause():
	if action_paused:
		resume();
	else:
		pause();

func pause():
	action_paused = true;
func resume():
	action_paused = false;

onready var scene_main_game = preload("res://main_scene/MainGameScreen.tscn");
onready var scene_main_menu = preload("res://main_scene/MainMenuScene.tscn");
onready var scene_battle = preload("res://main_scene/GameBattleScene.tscn");

var main_game_screen;
var main_menu_screen;
var battle_screen;

enum{ MAIN_GAME_SCENE,
	  MAIN_MENU_SCENE,
	  BATTLE_SCENE }
	
# I'm not deferring this cause I don't delete the
# scenes... Ever...
func switch_to_scene(scene):
	var scene_object;
	match scene:
		MAIN_GAME_SCENE: scene_object = main_game_screen;
		MAIN_MENU_SCENE: scene_object = main_menu_screen;
		BATTLE_SCENE: scene_object = battle_screen;

	var root = get_tree().get_root();
	var last_child = root.get_children()[-1];
	root.remove_child(last_child);
	root.add_child(scene_object);

func _ready():
	print("preloading all scenes at least once.");
	main_game_screen = scene_main_game.instance();
	main_menu_screen = scene_main_menu.instance();
	battle_screen = scene_battle.instance();
