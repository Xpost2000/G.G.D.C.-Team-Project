extends CanvasModulate; # thankfully no cutscenes required.

# TODO GOLD HOARD

func fire_id_handled(data):
	if data == "FightDragon":
		$Entities/FirkraagEnt/FightStarter/CollisionShape2D.disabled = true;
		var game_layer = get_parent().get_parent().get_parent();
		game_layer._open_battle(game_layer.player_node, $Entities/FirkraagBossEnt, "snd/bg2soundtrack/battle_dragon.ogg", "res://scenes/battle_backgrounds/DomainOfTheDragonBattleBkg.tscn", false);


func open_dialogue_dragon(_asdf):
	if _asdf.name == "InteractableArea":
		var game_layer = get_parent().get_parent().get_parent();
		game_layer.emit_signal("ask_ui_to_open_dialogue", "firkraag-asleep.json");

		var dialogue_ui = game_layer.get_node("UILayer/States/DialogueUI");
		dialogue_ui.connect("fire_id", self, "fire_id_handled");

var original_zoom;
func entered_camera_zoom_zone(area):
	if area.name == "InteractableArea":
		var game_layer = get_parent().get_parent().get_parent();
		original_zoom = game_layer.camera.zoom;
		$Entities/CameraZoomResizer/CameraTweener.interpolate_property(
			game_layer.camera,
			"zoom", original_zoom, Vector2(2.5, 2.5), 1.0,
			Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
			);
		$Entities/CameraZoomResizer/CameraTweener.start();
		AudioGlobal.play_sound("snd/ambient/wind1.wav", -30);

func exited_camera_zoom_zone(area):
	if area.name == "InteractableArea":
		var game_layer = get_parent().get_parent().get_parent();
		$Entities/CameraZoomResizer/CameraTweener.interpolate_property(
			game_layer.camera,
			"zoom", game_layer.camera.zoom, original_zoom, 1.0,
			Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
			);
		$Entities/CameraZoomResizer/CameraTweener.start();
		AudioGlobal.play_sound("snd/ambient/wind1.wav", -30);

	
func _ready():
	# Not nim, I didn't want to make a full minigame.
	$Entities/FirkraagEnt/FightStarter.connect("area_entered", self, "open_dialogue_dragon");
	$Entities/CameraZoomResizer.connect("area_entered", self, "entered_camera_zoom_zone");
	$Entities/CameraZoomResizer.connect("area_exited", self, "exited_camera_zoom_zone");

func _process(delta):
	AudioGlobal.looped_play_music("snd/bg1soundtrack/ever_deeper.ogg");
	if $Entities/FirkraagBossEnt.all_members_dead():
		$Entities/FirkraagEnt.texture = load("res://images/dead_firkraag.png");
