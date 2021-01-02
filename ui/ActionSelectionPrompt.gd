extends ColorRect

signal picked(index);
# There's no reason why this shouldn't be basically the same thing as PartyMemberSelectionForItemConsumption.gd
# Look into a way to merge these two so I can increase usability....

onready var selection_item_list = $Selections;

func open_prompt(items, heading_text="???"):
	$Heading.text = heading_text;

	selection_item_list.clear();

	for item in items:
		selection_item_list.add_item(item.get_item_list_string(), item.get_icon_texture());

func _on_Selections_item_activated(index):
	emit_signal("picked", index);

func _on_ClosePrompt_pressed():
	hide();
