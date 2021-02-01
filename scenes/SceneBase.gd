# This file soley exists to facilitate cutscenes, and maybe some other important thingies.
# extends YSort;
extends CanvasModulate;
onready var main_game_scene = GameGlobals.get_scene(GameGlobals.MAIN_GAME_SCENE);

func _set_cutscene_start(_animation_name, cutscene):
	GameGlobals.playing_cutscene = cutscene;

# I cannot think of a different way to do this.
func _mark_start_of_cutscene():
	main_game_scene.disable_ui();
	_remove_player_control();

func _remove_player_control():
	main_game_scene.disable_player_control();

func _set_player_position_to(where: Vector2):
	main_game_scene.player_node.global_position = where;

func _set_entity_position_to(entity_name: String, where: Vector2):
	var target = find_node("Entities/" + entity_name);
	target.global_position = where;

const GameActor = preload("res://game/actors/GameActor.gd");
func _move_player_to(goal: Vector2, relative = false):
	if relative:
		main_game_scene.player_node.action_walk_to(main_game_scene.player_node.global_position+goal);
	else:
		main_game_scene.player_node.action_walk_to(goal);

func _move_entity_to(entity_name: String, goal: Vector2, relative = false):
	var target = find_node("Entities/" + entity_name);
	if relative:
		target.action_walk_to(target.global_position+goal);
	else:
		target.action_walk_to(goal);

func _open_dialogue(what: String):
	main_game_scene.emit_signal("ask_ui_to_open_dialogue", what);

const DimmerRect = preload("res://ui/DimmerRect.gd");
func create_fade_dimmer(color, hang_time=0):
	var new_fade_dimmer = DimmerRect.new();

	new_fade_dimmer.disabled = false;
	new_fade_dimmer.rect_size = Vector2(1280, 720);
	new_fade_dimmer.color = color
	new_fade_dimmer.hang_max_time = hang_time;

	return new_fade_dimmer;
	
func delete_dimmer(dimmer):
	remove_child(dimmer);
	dimmer.queue_free();
	
func __begin_the_fade_out(dimmer):
	dimmer.hang_time = 0;
	dimmer.disconnect("finished", self, "__begin_the_fade_out")
	dimmer.begin_fade_out();
	dimmer.connect("finished", self, "delete_dimmer", [dimmer]);

func _do_fade_out(color: Color, hang_time=0):
	var dimmer = create_fade_dimmer(color, hang_time);
	dimmer.begin_fade_out();
	dimmer.connect("finished", self, "delete_dimmer", [dimmer]);
	main_game_scene.find_node("UILayer").add_child(dimmer);

func _do_fade_in_and_out(color: Color, hang_time=0):
	var dimmer = create_fade_dimmer(color, hang_time);
	dimmer.begin_fade_in();
	dimmer.connect("finished", self, "__begin_the_fade_out", [dimmer]);
	main_game_scene.find_node("UILayer").add_child(dimmer);

func _enable_player_control():
	main_game_scene.enable_player_control();

func _mark_end_of_cutscene():
	main_game_scene.enable_ui();
	_enable_player_control();
	GameGlobals.playing_cutscene = null;
	resume_all_entities();

func halt_all_entities():
	for entity in $Entities.get_children():
		if entity is GameActor:
			entity.disable_think();

func resume_all_entities():
	for entity in $Entities.get_children():
		if entity is GameActor:
			entity.enable_think();

func _ready():
	if $Cutscenes:
		$Cutscenes.connect("animation_started", self, "_set_cutscene_start", [$Cutscenes]);

func play_cutscene(name):
	$Cutscenes.play(name);
	halt_all_entities();

func handle_process(delta):
	pass;

func _process(delta):
	handle_process(delta);
