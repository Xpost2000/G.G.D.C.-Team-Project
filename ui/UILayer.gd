extends CanvasLayer
signal notify_finished_level_load_related_fading();

onready var stamina_bar = $SprintingStaminaBar;
onready var stamina_bar_max_dimensions = $SprintingStaminaBar.rect_size;
onready var ui_dimmer = $DimmerRect;
onready var inventory_ui = $InventoryUI;

var test_names = ["Dingle Berry", "Potato", "Fermented Yeast", "Salami"];
var test_inventory = ["test_item", "test_item"];
func _ready():
	inventory_ui.get_node("Inventory/InventoryItemList").fixed_icon_size = Vector2(32,32);
	inventory_ui.update_based_on_entity(test_inventory);
#   for inventory_item_name in test_inventory:
#       var item_info = ItemDatabase.get_item(inventory_item_name);
#   	inventory_ui.get_node("Inventory/InventoryItemList").add_item(item_info.name,
#                                                                     item_info.inventory_icon_path);

func _on_PlayerCharacter_report_sprinting_information(stamina_percent, can_sprint, _trying_to_sprint):
	if can_sprint:
		stamina_bar.color = Color.green;
	else:
		stamina_bar.color = Color.yellow;
		
	stamina_bar.set_size(Vector2(stamina_percent * stamina_bar_max_dimensions.x, 
								 stamina_bar_max_dimensions.y))

enum {DIMMER_NOT_FADING, DIMMER_FADE_REASON_LEVEL_LOADING};
var dimmer_fade_reason = DIMMER_NOT_FADING;
func _on_MainGameScreen_notify_ui_of_level_load():
	print("loading");
	ui_dimmer.begin_fade_in();
	dimmer_fade_reason = DIMMER_FADE_REASON_LEVEL_LOADING;
	pass # Replace with function body.

# Dirty, dirty, dirty
# But I'm only using this like once so whatever.
var fade_hold_timer = 0.0;
var fade_hold_timer_max = 0.5;
func _process(delta):
	match dimmer_fade_reason:
		DIMMER_NOT_FADING: 
			if ui_dimmer.finished_fade():
				ui_dimmer.disabled = true;
		DIMMER_FADE_REASON_LEVEL_LOADING:
			ui_dimmer.disabled = false;
			if ui_dimmer.finished_fade():
				if fade_hold_timer >= fade_hold_timer_max:
					emit_signal("notify_finished_level_load_related_fading");
					dimmer_fade_reason = DIMMER_NOT_FADING;
					ui_dimmer.begin_fade_out();
				fade_hold_timer += delta;
			else:
				fade_hold_timer = 0;
