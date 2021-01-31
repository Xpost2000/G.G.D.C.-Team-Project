extends "res://scenes/SceneBase.gd"

func fire_id_handled(data):
	if data == "PassedPuzzle1":
		$Entities/NimDoorLock/CollisionShape2D.disabled = true;

func open_minigame_dlg(_asdf):
	if _asdf.name != "TransitionPlaceholder":
		var game_layer = get_parent().get_parent().get_parent();
		game_layer.emit_signal("ask_ui_to_open_dialogue", "nim-game.json");

		var dialogue_ui = game_layer.get_node("UILayer/States/DialogueUI");
		dialogue_ui.connect("fire_id", self, "fire_id_handled");
	
func _ready():
	# Not nim, I didn't want to make a full minigame.
	$Entities/NimDoorLock.connect("area_entered", self, "open_minigame_dlg");
