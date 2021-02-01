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

func open_shop(_asdf):
	if _asdf.name == "InteractableArea":
		var game_layer = get_parent().get_parent().get_parent();
		game_layer.get_node("UILayer").toggle_shop("shop_files/test_stock.json");
		
func add_note(_asdf):
	if _asdf.name == "InteractableArea":
		var game_layer = get_parent().get_parent().get_parent();
		var player = game_layer.player_node;
		game_layer.find_node("UILayer").queue_popup("Note added.");
		player.add_item("plot_scrap", 1);
		$Entities/Note/InteractableArea/CollisionShape2D.disabled = true;
		$Entities/Note.hide();
	
func _ready():
	# Not nim, I didn't want to make a full minigame.
	$Entities/NimDoorLock.connect("area_entered", self, "open_minigame_dlg");
	$Entities/Merchant/InteractableArea.connect("area_entered", self, "open_shop");
	$Entities/Note/InteractableArea.connect("area_entered", self, "add_note");

var showed_note = false;
func handle_process(delta):
	var cultists = [$KnightOfTheCult, $KnightOfTheCult2, $KnightOfTheCult3];
	var all_dead = true;
	for cultist in cultists:
		if not cultist.all_members_dead():
			all_dead = false;
			break;

	if all_dead:
		if not showed_note:
			$Entities/Note/InteractableArea/CollisionShape2D.disabled = false;
			$Entities/Note.show();
			var game_layer = get_parent().get_parent().get_parent();
			game_layer.find_node("UILayer").queue_popup("A note drops from the pocket of one of the cultists...");
			showed_note = true;
			
