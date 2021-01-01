extends Control

signal notify_just_closed;

onready var inventory_widget = $Inventory;
onready var party_member_selection_widget = $PartyMemberSelection;

func _ready():
	party_member_selection_widget.hide();

func update_based_on_entity(thing, inventory):
	$Inventory.update_based_on_entity(thing, inventory);

func _on_Inventory_prompt_for_item_usage_selection(party_members, item_to_be_using):
	party_member_selection_widget.show();
	party_member_selection_widget.open_prompt(party_members, item_to_be_using);

func _on_PartyMemberSelection_ask_to_close_prompt():
	party_member_selection_widget.hide();
	emit_signal("notify_just_closed");
