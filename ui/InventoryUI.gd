extends Control

enum {CLOSE_REASON_CANCEL, CLOSE_REASON_USED}
signal close(reason);

onready var inventory_widget = $Inventory;
onready var inventory_widget_item_list = $Inventory/InventoryItemList;
onready var party_member_selection_widget = $PartyMemberSelection;

var item_use_inventory_entry = null;

func _ready():
	party_member_selection_widget.hide();

func inventory_owner():
	return $Inventory.currently_observing_thing;

func update_based_on_entity(thing, inventory):
	$Inventory.update_based_on_entity(thing, inventory);

var last_selected_index = 0;
func open_selection_menu():
	party_member_selection_widget.show();
	inventory_widget.modulate = Color(0.5, 0.5, 0.5);
	$Inventory/StupidBlocker.show();
	if inventory_widget_item_list.is_anything_selected():
		last_selected_index = inventory_widget.currently_selected;

func inventory_item_list_focus_on(index):
	inventory_widget.currently_selected = index;
	inventory_widget_item_list.grab_focus();

func close_selection_menu():
	party_member_selection_widget.hide();
	inventory_widget.modulate = Color(1, 1, 1);
	$Inventory/StupidBlocker.hide();
	inventory_item_list_focus_on(last_selected_index);

func _on_Inventory_prompt_for_item_usage_selection(party_members, item_entry_information):
	item_use_inventory_entry = item_entry_information;
	var item_entry = ItemDatabase.get_item(item_use_inventory_entry[0]);
	if not (item_entry.implementation is ItemDatabase.MiscItemImplementation):
		open_selection_menu();
		party_member_selection_widget.open_prompt(party_members, "Use on who?");
	else:
		print("not using misc item");

func _on_PartyMemberSelection_picked_party_member(party_member_object, index_of_party_member):
	emit_signal("close", [CLOSE_REASON_USED, index_of_party_member, item_use_inventory_entry]);
	close_selection_menu();

func _on_PartyMemberSelection_cancel_selection():
	emit_signal("close", [CLOSE_REASON_CANCEL]);
	close_selection_menu();

func on_leave(to):
	GameGlobals.resume();
	hide();

func on_enter(from):
	get_parent().get_parent().player_reference.emit_signal("opened_inventory");
	GameGlobals.pause();
	show();
	inventory_item_list_focus_on(0);

func handle_process(delta):
	if not $Inventory/StupidBlocker.is_visible():
		inventory_widget_item_list.grab_focus();

	if Input.is_action_just_pressed("game_action_open_inventory") or Input.is_action_just_pressed("ui_cancel"):
		if party_member_selection_widget.is_visible():
			close_selection_menu();
		else:
			get_parent().get_parent().toggle_inventory();
