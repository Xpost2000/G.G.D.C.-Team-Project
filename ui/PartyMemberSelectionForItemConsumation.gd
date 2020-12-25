# I meant ITEM_CONSUMPTION... Oh well it's kind of funny I guess.
extends ColorRect

signal ask_to_close_prompt;

onready var selection_item_list = $Selections;

var reference_to_party_member_list = null;
var item_to_be_using = null;

func open_prompt(party_members, item_to_use):
	reference_to_party_member_list = party_members;
	selection_item_list.clear();
	item_to_be_using = item_to_use;

	for party_member in party_members:
		selection_item_list.add_item(party_member.name, null);

func _on_Selections_item_activated(index):
	var character_to_use_item_on = reference_to_party_member_list[index];
	ItemDatabase.apply_item_to(character_to_use_item_on,
							   item_to_be_using);

	emit_signal("ask_to_close_prompt");
