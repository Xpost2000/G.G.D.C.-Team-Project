extends Node2D

onready var level_information = $LevelInformation;
onready var player_node = $PersistentThings/PlayerCharacter;
onready var ui_layer = $UILayer;

func load_new_level_scene(name):
	var loaded_scene = load(name).instance();

	for child in level_information.get_children():
		level_information.remove_child(child);
	level_information.add_child(loaded_scene);
	return loaded_scene;
	
func _on_PlayerCharacter_transitioning_to_another_level(player, level_transition):
	var full_scene_path = "res://scenes/" + level_transition.scene_to_transition_to + ".tscn";
	var loaded_scene = load_new_level_scene(full_scene_path);
	
	var landmark_node = loaded_scene.find_node("Entities").find_node(level_transition.landmark_node);
	
	if landmark_node:
		player.just_transitioned_from_other_level = true;
		player_node.position = landmark_node.position;
		print(landmark_node.name)
		print(landmark_node.position);
		print(landmark_node.get_position());
