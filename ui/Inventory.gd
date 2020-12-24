extends ColorRect

onready var inventory_item_list = $InventoryItemList;
onready var item_preview_widget = $ItemPreview;

var currently_observing_inventory = null;

func update_based_on_entity(thing_inventory):
	 # for now I'm assuming these are arrays
	inventory_item_list.clear();
	currently_observing_inventory = thing_inventory;
	for inventory_item_name in thing_inventory:
		 var item_info = ItemDatabase.get_item(inventory_item_name);
		 inventory_item_list.add_item(item_info.name,
									  item_info.inventory_icon);

func _ready():
	pass

func _on_InventoryItemList_item_activated(index):
	# empty for now.
	pass;

func _on_InventoryItemList_nothing_selected():
	item_preview_widget.set_information("Nothing!", "Can you believe that? Nothing at all!", null);

func _on_InventoryItemList_item_selected(index):
	var inventory_item_entry_information = currently_observing_inventory[index];
	item_preview_widget.set_information_based_on_item(inventory_item_entry_information);
