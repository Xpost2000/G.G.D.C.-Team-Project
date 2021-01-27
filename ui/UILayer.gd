extends CanvasLayer

# Again not great code, but whatever, it's simple and easy to edit.

signal notify_finished_level_load_related_fading();

onready var stamina_bar = $SprintingStaminaBar;
onready var stamina_bar_max_dimensions = $SprintingStaminaBar.rect_size;

# god this is stupid
var player_reference = null;
var reference_to_game_scene = null;

onready var inventory_ui = $States/InventoryUI;
onready var shopping_ui = $States/InventoryShoppingUI;
onready var party_member_information_holder = $PartyMemberInformation;
onready var dialogue_ui = $States/DialogueUI;
onready var levelup_ui = $States/LevelUpUI;
onready var quest_log_ui = $States/QuestLogUI;

const MAX_PARTY_MEMBER_INFO_VIEW_TIME = 0.75;
const MAX_PARTY_MEMBER_VIEW_TIME_PADDING = 1.25;
var party_member_info_view_timer = 0;

const MAX_SPRINT_TIMER_VIEW_TIME = 0.5;
const MAX_SPRINT_TIMER_VIEW_TIME_PADDING = 0.85;
var sprint_bar_view_timer = 0;

var allow_think = true;

enum {UI_STATE_GAME,
	  UI_STATE_INVENTORY,
	  UI_STATE_SHOPPING,
	  UI_STATE_DEATH,
	  UI_STATE_PAUSE,
	  UI_STATE_DIALOGUE,
	  UI_STATE_QUEST_LOG,
	  UI_STATE_LEVELUPS};
onready var states = {
	UI_STATE_GAME: null,
	UI_STATE_INVENTORY: inventory_ui,
	UI_STATE_SHOPPING: shopping_ui,
	UI_STATE_DEATH: $States/DeathScreenUI,
	UI_STATE_PAUSE: $States/PauseScreenUI,
	UI_STATE_DIALOGUE: dialogue_ui,
	UI_STATE_QUEST_LOG: quest_log_ui, 
	UI_STATE_LEVELUPS: levelup_ui
	};

var current_state = UI_STATE_GAME;

var shown = true;
# var hide_exceptions = [$States/PauseScreenUI, $States/DeathScreenUI, dialogue_ui];
func show_all():
	shown = true;
	for child in get_children():
		child.show();
		$States.show();
		$Popups.show();
func hide_all():
	shown = false;
	for child in get_children():
		child.hide();
		$States.show();
		$Popups.show();

func toggle_show():
	if shown:
		hide_all();
	else:
		show_all();

func _handle_quest_start(quest_info):
	queue_popup("Quest Taken: " + quest_info.name);
	queue_popup(quest_info.description);

func _handle_quest_end(quest_info):
	queue_popup("Quest Completed: " + quest_info.name);
	queue_popup("Wait for your reward!");
	
func _ready():
	inventory_ui.get_node("Inventory/InventoryItemList").fixed_icon_size = Vector2(32,32);
	reference_to_game_scene = get_parent().get_node("GameLayer");
	player_reference = reference_to_game_scene.find_node("PlayerCharacter");
	dialogue_ui.reference_to_game_scene = reference_to_game_scene;
	
	QuestsGlobal.connect("notify_begin_quest", self, "_handle_quest_start");
	QuestsGlobal.connect("notify_end_quest", self, "_handle_quest_end");

func _on_LevelUpResults_notify_finished():
	if current_state == UI_STATE_LEVELUPS:
		set_state(UI_STATE_GAME);

func _on_PlayerCharacter_handle_party_member_level_ups(party_members):
	set_state(UI_STATE_LEVELUPS);
	levelup_ui.get_node("LevelUpLayoutContainer/LevelUpResults").open_with(party_members);
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
		if _trying_to_sprint:
			sprint_bar_view_timer = MAX_SPRINT_TIMER_VIEW_TIME + MAX_SPRINT_TIMER_VIEW_TIME_PADDING;
	else:
		stamina_bar.color = Color.yellow;
		if _trying_to_sprint:
			sprint_bar_view_timer = MAX_SPRINT_TIMER_VIEW_TIME * 1.5 + MAX_SPRINT_TIMER_VIEW_TIME_PADDING * 2;
		
	stamina_bar.set_size(Vector2(stamina_percent * stamina_bar_max_dimensions.x, 
								 stamina_bar_max_dimensions.y))

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

func _on_level_load_initial_fade_out(dimmer):
	dimmer.hang_time = 0;
	dimmer.disconnect("finished", self, "_on_level_load_initial_fade_out");

	dimmer.begin_fade_out();

	dimmer.connect("finished", self, "delete_dimmer", [dimmer]);
	emit_signal("notify_finished_level_load_related_fading");

func _on_MainGameScreen_notify_ui_of_level_load():
	var new_fade_dimmer = create_fade_dimmer(Color(0, 0, 0, 0), 0.15);

	new_fade_dimmer.begin_fade_in();
	new_fade_dimmer.connect("finished", self, "_on_level_load_initial_fade_out", [new_fade_dimmer]);

	add_child(new_fade_dimmer);

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

var _popup_queue = [];
func queue_popup(text):
	_popup_queue.push_back(text);
	
func add_popup(text):
	call_deferred("_real_add_popup", text);

func handle_game_state_ui(delta):
	party_member_information_holder.show();
	stamina_bar.show();

	if party_member_info_view_timer > 0.0:
		party_member_info_view_timer -= delta;

	if sprint_bar_view_timer > 0.0:
		sprint_bar_view_timer -= delta;

	party_member_information_holder.modulate = Color(1, 1, 1, 1.0 if party_member_info_view_timer/MAX_PARTY_MEMBER_INFO_VIEW_TIME > 1.0 else party_member_info_view_timer/MAX_PARTY_MEMBER_INFO_VIEW_TIME);
	stamina_bar.modulate = Color(1, 1, 1, 1.0 if sprint_bar_view_timer/MAX_SPRINT_TIMER_VIEW_TIME > 1.0 else sprint_bar_view_timer/MAX_SPRINT_TIMER_VIEW_TIME);

# I'm sure I can insert a call_deferred somewhere maybe.
# This is way easier to do.
func handle_process(delta):
	any_open_popups = _any_popups_open();
	if !any_popups_open():
		if len(_popup_queue) > 0:
			add_popup(_popup_queue.pop_front());
		else:
			if current_state == UI_STATE_GAME:
				# This is hacky... But it's simple.
				if shown:
					handle_game_state_ui(delta);

				if Input.is_action_just_pressed("game_action_ui_pause"):
					toggle_pause();

				if allow_think:
					if Input.is_action_just_pressed("ui_page_up"):
						get_parent().write_save_game();
						add_popup("Saved game!");

					if Input.is_action_just_pressed("ui_page_down"):
						toggle_shop("shop_files/test_stock.json");

					if Input.is_action_just_pressed("game_action_open_inventory"):
						toggle_inventory();

					if Input.is_action_just_pressed("game_interact_action"):
						print(" I SEE!")
						set_state(UI_STATE_DIALOGUE);
						dialogue_ui.open_dialogue("testerbester.json");

					if Input.is_action_pressed("game_action_show_info"):
						party_member_info_view_timer = MAX_PARTY_MEMBER_INFO_VIEW_TIME + MAX_PARTY_MEMBER_VIEW_TIME_PADDING;
			else:
				party_member_information_holder.hide();
				stamina_bar.hide();
				if states[current_state]:
					states[current_state].handle_process(delta);
	else:
		# handle last popup only
		# also yes this is weird, this calls for a refactor later.
		GameGlobals.pause();

		# gah.
		if len(_popup_queue) > 0:
			$Popups.get_children()[0].connect("finished", self, "add_popup", [_popup_queue.pop_front()]);
		else:
			if !$Popups.get_children()[0].is_connected("finished", GameGlobals, "resume"):
				if current_state == UI_STATE_GAME:
					$Popups.get_children()[0].connect("finished", GameGlobals, "resume");
					$Popups.get_children()[-1].handle_inputs(delta);
					$Popups.get_children()[-1].grab_focus();

func set_state(state):
	if current_state != state:
		var previous_state = current_state;
		leave_state(previous_state, state);
		enter_state(state);
		current_state = state;

func enter_state(state):
	if state != UI_STATE_GAME:
		if states[state]:
			states[state].on_enter(current_state);

	match state:
		UI_STATE_GAME:
			GameGlobals.resume();
			pass;

func leave_state(state, leaving_to):
	if state != UI_STATE_GAME:
		if states[state]:
			states[state].on_leave(leaving_to);

	match state:
		UI_STATE_GAME:
			pass;

func show_death(val):
	if val:
		set_state(UI_STATE_DEATH);

func show_inventory():
	set_state(UI_STATE_INVENTORY);

func close_inventory():
	set_state(UI_STATE_PAUSE);

func toggle_pause():
	if current_state == UI_STATE_PAUSE:
		print("close");
		set_state(UI_STATE_GAME);
	else:
		print("open");
		set_state(UI_STATE_PAUSE);

func toggle_quest_log():
	if current_state == UI_STATE_QUEST_LOG:
		set_state(UI_STATE_PAUSE);
	else:
		set_state(UI_STATE_QUEST_LOG);

func toggle_shop(shop_path):
	if current_state == UI_STATE_SHOPPING:
		set_state(UI_STATE_GAME);
	else:
		set_state(UI_STATE_SHOPPING);
		shopping_ui.open_from_inventory(Utilities.read_json_no_check(shop_path));

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
	if !any_popups_open() and len(_popup_queue) <= 0:
		var item_info = ItemDatabase.get_item(item[0]);
		if item_info.sell_value > player_reference.gold:
			add_popup("This item is too expensive!");
		else:
			add_popup("Purchased!");
			player_reference.gold -= item_info.sell_value;
			player_reference.add_item(item[0]);
