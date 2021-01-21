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

func _on_Inventory_prompt_for_item_usage_selection(party_members, item_entry_information):
	item_use_inventory_entry = item_entry_information;
	var item_entry = ItemDatabase.get_item(item_use_inventory_entry[0]);
	if not (item_entry.implementation is ItemDatabase.MiscItemImplementation):
		party_member_selection_widget.show();
		party_member_selection_widget.open_prompt(party_members, "Use on who?");
		inventory_widget.modulate = Color(0.5, 0.5, 0.5);
		$Inventory/StupidBlocker.show();
	else:
		print("not using misc item");

func _on_PartyMemberSelection_picked_party_member(party_member_object, index_of_party_member):
	party_member_selection_widget.hide();
	emit_signal("close", [CLOSE_REASON_USED, index_of_party_member, item_use_inventory_entry]);
	inventory_widget.modulate = Color(1, 1, 1);
	$Inventory/StupidBlocker.hide();

func _on_PartyMemberSelection_cancel_selection():
	party_member_selection_widget.hide();
	emit_signal("close", [CLOSE_REASON_CANCEL]);
	inventory_widget.modulate = Color(1, 1, 1);
	$Inventory/StupidBlocker.hide();

func on_leave(to):
	GameGlobals.resume();
	hide();

func on_enter(from):
	GameGlobals.pause();
	show();
	inventory_widget.currently_selected = 0;
	inventory_widget_item_list.grab_focus();

func handle_process(delta):
	if Input.is_action_just_pressed("game_action_open_inventory") or Input.is_action_just_pressed("ui_cancel"):
		get_parent().get_parent().toggle_inventory();
