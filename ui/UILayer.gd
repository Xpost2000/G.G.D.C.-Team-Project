extends CanvasLayer
signal notify_finished_level_load_related_fading();
signal set_game_action_pause_state(value);

onready var stamina_bar = $SprintingStaminaBar;
onready var stamina_bar_max_dimensions = $SprintingStaminaBar.rect_size;
onready var ui_dimmer = $DimmerRect;
onready var inventory_ui = $InventoryUI;
onready var party_member_information_holder = $PartyMemberInformation;
onready var dialogue_ui = $DialogueUI;

func _ready():
	inventory_ui.get_node("Inventory/InventoryItemList").fixed_icon_size = Vector2(32,32);

func _on_PlayerCharacter_report_party_info_to_ui(party_members, amount_of_gold):
	party_member_information_holder.update_with_party_information(party_members, amount_of_gold);

func _on_PlayerCharacter_report_inventory_contents(player, player_inventory):
	inventory_ui.update_based_on_entity(player, player_inventory);

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

var showing_inventory = false;

func _process(delta):
	if Input.is_action_just_pressed("game_action_open_inventory"):
		toggle_inventory();

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

	if !showing_inventory:
		inventory_ui.hide();
		inventory_ui.set_process(false);
	else:
		inventory_ui.show();
		inventory_ui.set_process(true);

func show_inventory():
	showing_inventory = true;
	emit_signal("set_game_action_pause_state", true);

func close_inventory():
	showing_inventory = false;
	emit_signal("set_game_action_pause_state", false);

func toggle_inventory():
	if showing_inventory:
		close_inventory();
	else:
		show_inventory();

func _on_Inventory_prompt_for_item_usage_selection(party_members, item_name):
	pass # Replace with function body.

func _on_MainGameScreen_ask_ui_to_open_test_dialogue():
	dialogue_ui.open_test_dialogue();
