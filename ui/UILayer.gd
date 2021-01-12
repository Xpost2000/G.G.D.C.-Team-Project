extends CanvasLayer
signal notify_finished_level_load_related_fading();
# signal request_to_use_item(item_index); Might end up using? For now no.

onready var stamina_bar = $SprintingStaminaBar;
onready var stamina_bar_max_dimensions = $SprintingStaminaBar.rect_size;
onready var ui_dimmer = $DimmerRect;
onready var inventory_ui = $InventoryUI;
onready var death_ui = $DeathScreenUI;
onready var pause_ui = $PauseScreenUI;
onready var party_member_information_holder = $PartyMemberInformation;
onready var dialogue_ui = $DialogueUI;
onready var levelup_ui = $LevelUpResults;

var reference_to_game_scene = null;

enum {UI_STATE_GAME, UI_STATE_INVENTORY, UI_STATE_DEATH, UI_STATE_PAUSE, UI_STATE_DIALOGUE, UI_STATE_LEVELUPS};
var current_state = UI_STATE_GAME;

func _ready():
	inventory_ui.get_node("Inventory/InventoryItemList").fixed_icon_size = Vector2(32,32);
	reference_to_game_scene = get_parent().get_node("GameLayer");
	dialogue_ui.reference_to_game_scene = reference_to_game_scene;

func _on_LevelUpResults_notify_finished():
	set_state(UI_STATE_GAME);

func _on_PlayerCharacter_handle_party_member_level_ups(party_members):
	set_state(UI_STATE_LEVELUPS);
	levelup_ui.open_with(party_members);
	pass;

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

func _process(delta):
	# Still hardcoding certain transitions which I'm not proud of.
	if Input.is_action_just_pressed("game_action_ui_pause"):
		if current_state != UI_STATE_LEVELUPS:
			if current_state != UI_STATE_PAUSE:
				set_state(UI_STATE_PAUSE);
			else:
				set_state(UI_STATE_GAME);

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

func set_state(state):
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
			inventory_ui.show();
			print("SHOW ME HISTY");
			pass;
		UI_STATE_DEATH:
			GameGlobals.pause();
			death_ui.show();
			pass;
		UI_STATE_PAUSE:
			GameGlobals.pause();
			pause_ui.show();
			pass;
		UI_STATE_DIALOGUE:
			GameGlobals.pause();
			dialogue_ui.show();
			pass;
		UI_STATE_LEVELUPS:
			GameGlobals.pause();
			levelup_ui.show();
			pass;

func leave_state(state):
	match state:
		UI_STATE_GAME:
			pass;
		UI_STATE_INVENTORY:
			inventory_ui.hide();
			print("CLOSE ME");
			pass;
		UI_STATE_DEATH:
			GameGlobals.resume();
			death_ui.hide();
			pass;
		UI_STATE_PAUSE:
			GameGlobals.resume();
			pause_ui.hide();
			pass;
		UI_STATE_DIALOGUE:
			GameGlobals.resume();
			dialogue_ui.hide();
			pass;
		UI_STATE_LEVELUPS:
			GameGlobals.resume();
			levelup_ui.hide();
			pass;

func show_death(val):
	if val:
		set_state(UI_STATE_DEATH);

func show_inventory():
	set_state(UI_STATE_INVENTORY);

func close_inventory():
	set_state(UI_STATE_GAME);


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
