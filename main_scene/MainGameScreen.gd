extends Node2D
# Signals might be not needed...
signal notify_ui_of_level_load();
signal ask_ui_to_open_test_dialogue();

onready var game_layer = $GameLayer;
onready var ui_layer = $UILayer;
onready var level_information = $GameLayer/LevelInformation;
onready var player_node = $GameLayer/PersistentThings/PlayerCharacter;

func _ready():
	randomize();

func load_new_level_scene(name):
	var loaded_scene = load(name).instance();

	for child in level_information.get_children():
		level_information.remove_child(child);
	level_information.add_child(loaded_scene);
	return loaded_scene;
	
const LevelTransitionClass = preload("res://game/LevelTransition.gd");
func setup_new_level_scene(player, level_transition, loaded_scene):
	var landmark_node = loaded_scene.find_node("Entities").find_node(level_transition.landmark_node);
	
	if landmark_node:
		if landmark_node is LevelTransitionClass:
			player.just_transitioned_from_other_level = true;
		player_node.position = landmark_node.position;

var player_load_context_info;
var level_transition_load_context_info;

func _on_PlayerCharacter_transitioning_to_another_level(player, level_transition):
	level_transition_load_context_info = level_transition;
	player_load_context_info = player;

	emit_signal("notify_ui_of_level_load");


func _on_UILayer_notify_finished_level_load_related_fading():
	var level_transition = level_transition_load_context_info;
	var player = player_load_context_info;
	
	var full_scene_path = "res://scenes/" + level_transition.scene_to_transition_to + ".tscn";
	var loaded_scene = load_new_level_scene(full_scene_path);
	setup_new_level_scene(player, level_transition, loaded_scene);

func _on_PlayerCharacter_test_open_conversation():
	emit_signal("ask_ui_to_open_test_dialogue");
	print("open test convo");

func _on_PlayerCharacter_request_to_open_battle(left, right):
	print("starting fight")
	pass;

func _process(delta):
	if Input.is_action_just_pressed("ui_end"):
		GameGlobals.switch_to_scene(2);

	if player_node.all_members_dead():
		player_node.self_paused = true;
		# stupid but whatever.
		ui_layer.show_death(true);
	else:
		ui_layer.show_death(false);
		
