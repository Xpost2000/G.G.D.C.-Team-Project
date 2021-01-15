extends Control
signal try_to_purchase_item(item)

onready var gold_counter = $GoldCounterContainer/GoldCount;

func open_from_inventory(inventory):
	$Inventory.update_based_on_inventory(inventory);

func _on_Inventory_prompt_for_item_usage(item_info):
	print("want to buy something");
	emit_signal("try_to_purchase_item", item_info);

func _ready():
	pass

func on_leave(to):
	GameGlobals.resume();
	hide();

func on_enter(from):
	GameGlobals.pause();
	show();

func handle_process(delta):
	if Input.is_action_just_pressed("game_action_open_inventory"):
		get_parent().get_parent().toggle_shop("shop_files/test_stock.json");
