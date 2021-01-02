extends Control

enum {CLOSE_REASON_CANCEL, CLOSE_REASON_USED}
signal close(reason);

onready var inventory_widget = $Inventory;
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
	party_member_selection_widget.show();
	party_member_selection_widget.open_prompt(party_members, "Use on who?");
	# disable inventory...

func _on_PartyMemberSelection_picked_party_member(party_member_object, index_of_party_member):
	party_member_selection_widget.hide();
	emit_signal("close", [CLOSE_REASON_USED, index_of_party_member, item_use_inventory_entry]);

func _on_PartyMemberSelection_cancel_selection():
	party_member_selection_widget.hide();
	emit_signal("close", [CLOSE_REASON_CANCEL]);
