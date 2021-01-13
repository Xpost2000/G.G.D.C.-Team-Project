extends CanvasLayer
# TODO: UI should attempt to have more fine grained control over it's widgets

signal notify_finished_level_load_related_fading();

onready var stamina_bar = $SprintingStaminaBar;
onready var stamina_bar_max_dimensions = $SprintingStaminaBar.rect_size;
onready var ui_dimmer = $DimmerRect;
onready var inventory_ui = $States/InventoryUI;
onready var shopping_ui = $States/InventoryShoppingUI;
onready var death_ui = $States/DeathScreenUI;
onready var pause_ui = $States/PauseScreenUI;
onready var party_member_information_holder = $PartyMemberInformation;
onready var dialogue_ui = $States/DialogueUI;

onready var levelup_ui_container = $States/LevelUpUI;
onready var levelup_ui = $States/LevelUpUI/LevelUpLayoutContainer/LevelUpResults;

# god this is stupid
var player_reference = null;
var reference_to_game_scene = null;

enum {UI_STATE_GAME,
	  UI_STATE_INVENTORY,
	  UI_STATE_SHOPPING,
	  UI_STATE_DEATH,
	  UI_STATE_PAUSE,
	  UI_STATE_DIALOGUE,
	  UI_STATE_LEVELUPS};
var current_state = UI_STATE_GAME;

func _ready():
	inventory_ui.get_node("Inventory/InventoryItemList").fixed_icon_size = Vector2(32,32);
	reference_to_game_scene = get_parent().get_node("GameLayer");
	dialogue_ui.reference_to_game_scene = reference_to_game_scene;

	$States/PauseScreenUI/VBoxContainer/Resume.connect("pressed", self, "_on_PauseUI_Resume_pressed");
	$States/PauseScreenUI/VBoxContainer/ReturnToTitle.connect("pressed", self, "_on_PauseUI_ReturnToTitle_pressed");
	$States/PauseScreenUI/VBoxContainer/Quit.connect("pressed", self, "_on_PauseUI_Quit_pressed");

	$States/DeathScreenUI/Selections/Restart.connect("pressed", self, "_on_Restart_pressed");
	$States/DeathScreenUI/Selections/Menu.connect("pressed", self, "_on_Menu_pressed");
	$States/DeathScreenUI/Selections/Quit.connect("pressed", self, "_on_Quit_pressed");

func _on_LevelUpResults_notify_finished():
	if current_state == UI_STATE_LEVELUPS:
		set_state(UI_STATE_GAME);

func _on_PlayerCharacter_handle_party_member_level_ups(party_members):
	set_state(UI_STATE_LEVELUPS);
	levelup_ui.open_with(party_members);
	pass;

func _on_PlayerCharacter_report_party_info_to_ui(party_members, amount_of_gold):
	party_member_information_holder.update_with_party_information(party_members, amount_of_gold);

func _on_PlayerCharacter_report_inventory_contents(player, player_inventory):
	shopping_ui.gold_counter.text = str(player.gold) + " gp";
	player_reference = player;
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

func _on_PauseUI_Resume_pressed():
	set_state(UI_STATE_GAME);

func _on_PauseUI_ReturnToTitle_pressed():
	GameGlobals.switch_to_scene(1);

func _on_PauseUI_Quit_pressed():
	get_tree().quit();

# Dirty, dirty, dirty
# But I'm only using this like once so whatever.
var fade_hold_timer = 0.0;
var fade_hold_timer_max = 0.5;

func _any_popups_open():
	var popups = $Popups.get_children();
	var result = false;
	for popup in popups:
		result = result or popup.active;
	return result and len(popups);

# this is a stupid way to "defer" the results to the next frame
var any_open_popups = false;
func any_popups_open():
	return any_open_popups;

const PopupTemplate = preload("res://ui/PopupTemplate.tscn");
func _real_add_popup(text):
	var popup = PopupTemplate.instance();
	$Popups.add_child(popup);
	$Popups.get_children()[-1].popup(text);
	
func add_popup(text):
	call_deferred("_real_add_popup", text);

func _process(delta):
	# Still hardcoding certain transitions which I'm not proud of.
	# set_process_of_all_states(!any_popups_open());
	any_open_popups = _any_popups_open();
	if !any_popups_open():
		if Input.is_action_just_pressed("ui_page_down"):
			# shopping_ui.open_from_inventory();
			toggle_shop();

		if Input.is_action_just_pressed("game_action_ui_pause"):
			if current_state != UI_STATE_LEVELUPS:
				toggle_pause();

		if current_state != UI_STATE_PAUSE:
			if Input.is_action_just_pressed("game_action_open_inventory"):
				toggle_inventory();

			# TODO USE BETTER FADE FROM LIKE TWEEN
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
	else:
		# handle last popup only
		# also yes this is weird, this calls for a refactor later.
		GameGlobals.pause();
		$Popups.get_children()[-1].handle_inputs(delta);
		if !_any_popups_open():
			GameGlobals.resume();
			
func set_state(state):
	if current_state != state:
		var previous_state = current_state;
		leave_state(previous_state);
		enter_state(state);
		current_state = state;

func enter_state(state):
	match state:
		UI_STATE_GAME:
			GameGlobals.resume();
			pass;
		UI_STATE_INVENTORY:
			GameGlobals.pause();
			inventory_ui.show();
			pass;
		UI_STATE_SHOPPING:
			GameGlobals.pause();
			shopping_ui.show();
			pass;
		UI_STATE_DEATH:
			GameGlobals.pause();
			death_ui.show();
			pass;
		UI_STATE_PAUSE:
			GameGlobals.pause();
			pause_ui.show();
			print("pause");
			pass;
		UI_STATE_DIALOGUE:
			GameGlobals.pause();
			dialogue_ui.show();
			pass;
		UI_STATE_LEVELUPS:
			GameGlobals.pause();
			levelup_ui_container.show();
			pass;

func leave_state(state):
	match state:
		UI_STATE_GAME:
			pass;
		UI_STATE_INVENTORY:
			GameGlobals.resume();
			inventory_ui.hide();
			pass;
		UI_STATE_SHOPPING:
			GameGlobals.resume();
			shopping_ui.hide();
			pass;
		UI_STATE_DEATH:
			GameGlobals.resume();
			death_ui.hide();
			pass;
		UI_STATE_PAUSE:
			GameGlobals.resume();
			pause_ui.hide();
			print("un_pause");
			pass;
		UI_STATE_DIALOGUE:
			GameGlobals.resume();
			dialogue_ui.hide();
			pass;
		UI_STATE_LEVELUPS:
			GameGlobals.resume();
			levelup_ui_container.hide();
			pass;

func show_death(val):
	if val:
		set_state(UI_STATE_DEATH);

func show_inventory():
	set_state(UI_STATE_INVENTORY);

func close_inventory():
	set_state(UI_STATE_GAME);

func toggle_pause():
	if current_state == UI_STATE_PAUSE:
		print("close");
		set_state(UI_STATE_GAME);
	else:
		print("open");
		set_state(UI_STATE_PAUSE);

func toggle_shop():
	if current_state == UI_STATE_SHOPPING:
		set_state(UI_STATE_GAME);
	else:
		set_state(UI_STATE_SHOPPING);

func toggle_inventory():
	if current_state == UI_STATE_INVENTORY:
		print("CLOSE");
		close_inventory();
	else:
		print("SHOW");
		show_inventory();

func _on_MainGameScreen_ask_ui_to_open_dialogue(filepath):
	set_state(UI_STATE_DIALOGUE);
	dialogue_ui.open_dialogue(filepath);

enum {DIALOGUE_TERMINATION_REASON_DEFAULT}
func _on_DialogueUI_notify_dialogue_terminated(reason):
	match reason.type:
		DIALOGUE_TERMINATION_REASON_DEFAULT: pass;
	set_state(UI_STATE_GAME);

enum {CLOSE_REASON_CANCEL, CLOSE_REASON_USED}
func _on_InventoryUI_close(reason):
	match reason[0]:
		CLOSE_REASON_CANCEL: pass;
		CLOSE_REASON_USED:
			var targetting = inventory_ui.inventory_owner().get_party_member(reason[1]);
			reason[2][1] -= 1;
			ItemDatabase.apply_item_to(targetting, reason[2][0]);

func _on_InventoryShoppingUI_try_to_purchase_item(item):
	var item_info = ItemDatabase.get_item(item[0]);
	if item_info.sell_value > player_reference.gold:
		add_popup("This item is too expensive!");
	else:
		add_popup("Purchased!");
		player_reference.gold -= item_info.sell_value;
		player_reference.add_item(item[0]);

# Referring to death screen if anyone asks.
enum{ MAIN_GAME_SCENE,
	  MAIN_MENU_SCENE,
	  BATTLE_SCENE,
	  GAME_SCENE_TYPE_COUNT}

func _on_Restart_pressed():	
	GameGlobals.reload_scene(MAIN_GAME_SCENE);
	GameGlobals.reload_scene(BATTLE_SCENE);
	GameGlobals.switch_to_scene(0);

func _on_Menu_pressed():
	GameGlobals.switch_to_scene(1);

func _on_Quit_pressed():
	get_tree().quit();
