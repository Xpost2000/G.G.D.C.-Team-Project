extends Node2D
# Signals might be not needed...
signal notify_ui_of_level_load();
signal ask_ui_to_open_dialogue(filepath);

onready var game_layer = $GameLayer;
onready var ui_layer = $UILayer;
onready var level_information = $GameLayer/LevelInformation;
onready var player_node = $GameLayer/PersistentThings/PlayerCharacter;

func _generate_quest_from_name_type(quest_name):
	match quest_name:
		"test_die_quest":
			var new_quest = QuestsGlobal.TestDieQuest.new(player_node);
			return new_quest;
		"open_your_inventory":
			var new_quest = QuestsGlobal.OpenInventoryQuest.new(player_node);
			return new_quest;

func handle_hi_bro(data):
	print("HI ASIDOSAIODOIDAS");

func handle_add_item(data):
	ui_layer.add_popup(ItemDatabase.get_item(data).name + " received!");
	player_node.add_item(data);

func handle_start_quest(data):
	print("handling!");
	QuestsGlobal.begin_quest(_generate_quest_from_name_type(data));

func load_from_dictionary(data):
	print("LOAD ME");
	var full_scene_path = "res://scenes/" + data["current_level_scene"] + ".tscn";
	load_new_level_scene(full_scene_path);

	player_node.update_from_dictionary_data(data["actors"]["PlayerCharacter"]);
	for actor in get_tree().get_nodes_in_group("Actors"):
		if actor.name in data["actors"]:
			actor.update_from_dictionary_data(data["actors"][actor.name]);

func serialize_as_dictionary():
	var actors = {"PlayerCharacter": player_node.dictionary_data()};

	for actor in get_tree().get_nodes_in_group("Actors"):
		actors[actor.name] = actor.dictionary_data();

	var result = {
		"current_level_scene": find_node("LevelInformation").get_children()[0].name,
		"actors": actors
		};

	return result;

func write_save_game():
	Utilities.write_entire_file_from_string("saves/save.game_save", JSON.print(serialize_as_dictionary()));

func _ready():
	var battle_screen = GameGlobals.get_scene(2);
	battle_screen.connect("combat_finished", self, "_on_BattleScreen_finished");
	randomize();

	for handlable_response in ["add_item", "start_quest"]:
		$UILayer/States/DialogueUI.connect(handlable_response,
										   self,
										   "handle_" + handlable_response);

enum {
	COMBAT_FINISHED_REASON_FLEE, # The winning party is the one that didn't flee.
	COMBAT_FINISHED_REASON_DEFEAT_OF, # The winning party is the last one standing.
	COMBAT_FINISHED_REASON_FORCED # There are no winners or losers.
	}
func _on_BattleScreen_finished(type, a, b):
	match type:
		COMBAT_FINISHED_REASON_FLEE:
			print("cowardly flee");
			ui_layer.add_popup("You ran like a coward");
			pass;
		COMBAT_FINISHED_REASON_DEFEAT_OF:
			print("someone died");
			if a == player_node:
				print("yay we won! Show a neat widget");

				# this would benefit from coroutines

				player_node.award_experience(b.experience_value);
				ui_layer.queue_popup("You gain " + str(b.experience_value) + " XP!");

				if len(b.inventory):
					for item in b.inventory:
						var obtained_item = item;
						ui_layer.queue_popup("You get: x" + str(obtained_item[1]) + " " + ItemDatabase.get_item(obtained_item[0]).name);
						player_node.add_item(obtained_item[0], obtained_item[1]);
			else:
				print("We lost");
			pass;
		COMBAT_FINISHED_REASON_FORCED:
			# b, a
			print("forceful ejection");
			pass;

var loaded_levels = {};
func load_new_level_scene(name):
	var loaded_scene = null;

	if name in loaded_levels:
		loaded_scene = loaded_levels[name];
	else:
		loaded_scene = load(name).instance();
		loaded_levels[name] = loaded_scene;

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

	print("MOV")
	emit_signal("notify_ui_of_level_load");


func _on_UILayer_notify_finished_level_load_related_fading():
	var level_transition = level_transition_load_context_info;
	var player = player_load_context_info;
	
	var full_scene_path = "res://scenes/" + level_transition.scene_to_transition_to + ".tscn";
	var loaded_scene = load_new_level_scene(full_scene_path);
	setup_new_level_scene(player, level_transition, loaded_scene);

func _open_battle(left, right):
	print("starting fight")
	GameGlobals.switch_to_scene(2);
	GameGlobals.battle_screen.begin_battle(left, right);

func _on_PlayerCharacter_request_to_open_battle(left, right):
	call_deferred("_open_battle", left, right);

func _process(delta):
	ui_layer.show_death(player_node.all_members_dead());
		
