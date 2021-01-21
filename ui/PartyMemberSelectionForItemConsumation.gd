# I meant ITEM_CONSUMPTION... Oh well it's kind of funny I guess.
extends NinePatchRect;
# I don't know why I would need the index but I guess it's insurance?
signal picked_party_member(object, index);
signal cancel_selection;

onready var selection_item_list = $Selections;

var reference_to_party_member_list = null;

func open_prompt(party_members, heading_text="Who?"):
	$Heading.text = heading_text;

	reference_to_party_member_list = party_members;
	selection_item_list.clear();

	for party_member in party_members:
		selection_item_list.add_item(party_member.name, null);
	selection_item_list.grab_focus();
	selection_item_list.select(0);

func _on_Selections_item_selected(index):
	# dummy
	pass;
	
func _on_Selections_item_activated(index):
	emit_signal("picked_party_member", reference_to_party_member_list[index], index);

func _on_CancelUsage_pressed():
	emit_signal("cancel_selection");
