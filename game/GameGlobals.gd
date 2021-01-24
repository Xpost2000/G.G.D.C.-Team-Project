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

# This could, and probably should be an array.
var main_game_screen;
var main_menu_screen;
var battle_screen;

var game_variables = []; # For reasons.

enum{ MAIN_GAME_SCENE,
	  MAIN_MENU_SCENE,
	  BATTLE_SCENE,
	  GAME_SCENE_TYPE_COUNT}
	
# I'm not deferring this cause I don't delete the
# scenes... Ever...
func switch_to_scene(scene):
	var scene_object;
	match scene:
		MAIN_GAME_SCENE: scene_object = main_game_screen;
		MAIN_MENU_SCENE: scene_object = main_menu_screen;
		BATTLE_SCENE: scene_object = battle_screen;

	if scene_object.has_method("on_enter"):
		scene_object.on_enter();

	var root = get_tree().get_root();
	var last_child = root.get_children()[-1];
	root.remove_child(last_child);
	root.add_child(scene_object);

func reload_scene(type):
	var old_scene = null;

	match type:
		MAIN_GAME_SCENE:
			old_scene = main_game_screen;
			main_game_screen = scene_main_game.instance();
		MAIN_MENU_SCENE:
			old_scene = main_menu_screen;
			main_menu_screen = scene_main_menu.instance();
		BATTLE_SCENE:
			old_scene = battle_screen;
			battle_screen = scene_battle.instance();

	if old_scene:
		old_scene.queue_free();

func get_scene(type):
	match type:
		MAIN_GAME_SCENE:
			if main_game_screen == null:
				reload_scene(type);
			return main_game_screen;
		MAIN_MENU_SCENE:
			if main_menu_screen == null:
				reload_scene(type);
			return main_menu_screen;
		BATTLE_SCENE:
			if battle_screen == null:
				reload_scene(type);
			return battle_screen;

func _ready():
	print("preloading all scenes at least once.");
	# I'm going to skip preloading the game. There's no point?
	for screen_type in range(MAIN_GAME_SCENE+1, GAME_SCENE_TYPE_COUNT):
		reload_scene(screen_type);

var playing_cutscene = null;
func _process(delta):
	if playing_cutscene:
		if paused():
			if playing_cutscene.is_playing():
				playing_cutscene.stop(false);
				print("stopping cause of pause");
		else:
			if not playing_cutscene.is_playing():
				playing_cutscene.play();
				print("resunming");

