extends "res://scenes/SceneBase.gd"

func fire_id_handled(data):
	if data == "PassedPuzzle1":
		print("HANDLE PUZZLE PASS!");
		$Entities/SkullAltar.texture = load("res://images/skull_altar_holy_ending.png");
		$Entities/HolyEndingBoss.show();
		$Entities/HolyEndingBoss/InteractableArea/Radius.disabled = false;
		$Entities/HorrorBoss.hide();
		$Entities/HorrorBoss/InteractableArea/Radius.disabled = true;
		AudioGlobal.pause_music();

	if data == "FailedPuzzle1":
		$Entities/SkullAltar/Area2D/CollisionShape2D.disabled = true;
		AudioGlobal.pause_music();

	if data == "PassedPuzzle2":
		$Entities/ForceFieldA/StaticBody2D/CollisionShape2D.set_deferred("disabled", true);
		$Entities/ForceFieldA/PuzzleZone/CollisionShape2D.set_deferred("disabled", true);
		$Entities/ForceFieldA.hide();

func open_minigame_dlg(_asdf):
	var game_layer = get_parent().get_parent().get_parent();
	game_layer.emit_signal("ask_ui_to_open_dialogue", "riddle.json");

	var dialogue_ui = game_layer.get_node("UILayer/States/DialogueUI");
	dialogue_ui.connect("fire_id", self, "fire_id_handled");

func open_other_minigame_dlg(_asdf):
	var game_layer = get_parent().get_parent().get_parent();
	var player = game_layer.player_node;

	var cool = false;
	for item in player.inventory:
		if item[0] == "modron_cube":
			cool = true;
			break;
	if cool:
		game_layer.emit_signal("ask_ui_to_open_dialogue", "modron.json");

		var dialogue_ui = game_layer.get_node("UILayer/States/DialogueUI");
		dialogue_ui.connect("fire_id", self, "fire_id_handled");

func check_if_openable(_asdf):
	var game_layer = get_parent().get_parent().get_parent();
	var player = game_layer.player_node;

	var cool = false;
	for item in player.inventory:
		if item[0] == "key_item":
			cool = true;
			break;
	if cool:
		$Entities/ForceFieldB/StaticBody2D/CollisionShape2D.set_deferred("disabled", true);
		$Entities/ForceFieldB.hide();
	
func _ready():
	# Not nim, I didn't want to make a full minigame.
	$Entities/SkullAltar/Area2D.connect("area_entered", self, "open_minigame_dlg");
	$Entities/ForceFieldA/PuzzleZone.connect("area_entered", self, "open_other_minigame_dlg");
	$Entities/ForceFieldB/PuzzleZone.connect("area_entered", self, "check_if_openable");

	$Entities/HolyEndingBoss/InteractableArea/Radius.disabled = true;
	$Entities/HorrorBoss/InteractableArea/Radius.disabled = false;

func create_fade_dimmer(color, hang_time=0):
	var new_fade_dimmer = DimmerRect.new();

	new_fade_dimmer.disabled = false;
	new_fade_dimmer.rect_size = Vector2(1280, 720);
	new_fade_dimmer.color = color
	new_fade_dimmer.hang_max_time = hang_time;

	return new_fade_dimmer;
func delete_dimmer(dimmer):
	var battle_ui_layer = get_parent().get_parent().get_parent().find_node("UILayer");
	battle_ui_layer.remove_child(dimmer);
	dimmer.queue_free();

var triggered_ending_setup = false;

# A little dirty for endings, also it's abrupt since we don't allow anything else to happen.
func _process(delta):
	AudioGlobal.looped_play_music("snd/planescapesoundtrack/ravel_theme.ogg", true);
	if not triggered_ending_setup:
		if $Entities/HolyEndingBoss.all_members_dead():
			print("holy end");
			var new_fade_dimmer = create_fade_dimmer(Color(0, 0, 0, 0), 1.55);

			new_fade_dimmer.begin_fade_in();
			var battle_ui_layer = get_parent().get_parent().get_parent().find_node("UILayer");
			battle_ui_layer.allow_think = false;
			battle_ui_layer.really_hide_all();
			battle_ui_layer.add_child(new_fade_dimmer);

			new_fade_dimmer.connect("finished", self, "delete_dimmer", [new_fade_dimmer]);
			new_fade_dimmer.connect("finished", GameGlobals, "switch_to_scene", [GameGlobals.ALTERNATE_ENDING_SCENE]);

			triggered_ending_setup = true;
		elif $Entities/HorrorBoss.all_members_dead():
			print("normal end");
			var new_fade_dimmer = create_fade_dimmer(Color(0, 0, 0, 0), 1.55);

			new_fade_dimmer.begin_fade_in();
			var battle_ui_layer = get_parent().get_parent().get_parent().find_node("UILayer");
			battle_ui_layer.allow_think = false;
			battle_ui_layer.really_hide_all();
			battle_ui_layer.add_child(new_fade_dimmer);

			new_fade_dimmer.connect("finished", self, "delete_dimmer", [new_fade_dimmer]);
			new_fade_dimmer.connect("finished", GameGlobals, "switch_to_scene", [GameGlobals.NORMAL_ENDING_SCENE]);
			triggered_ending_setup = true;

