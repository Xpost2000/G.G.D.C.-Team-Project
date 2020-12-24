extends ColorRect

onready var inventory_item_list = $InventoryItemList;

onready var item_preview_widget = $ItemPreview;

func update_based_on_entity(thing):
	.please_error_out_because_this_isnt_done_yet();

func _ready():
	pass

func _on_InventoryItemList_item_activated(index):
	# empty for now.
	pass;

func _on_InventoryItemList_nothing_selected():
	item_preview_widget.set_information("Nothing!", "Can you believe that? Nothing at all!", null);

func _on_InventoryItemList_item_selected(index):
	var item_name = inventory_item_list.get_item_text(index);
	item_preview_widget.set_preview_name(item_name);
