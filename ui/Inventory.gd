extends ColorRect

onready var inventory_item_list = $InventoryItemList;
onready var item_preview_widget = $ItemPreview;

var currently_observing_thing = null;
var currently_observing_inventory = null;

func update_based_on_entity(thing, inventory):
	 # for now I'm assuming these are arrays
	inventory_item_list.clear();
	currently_observing_inventory = inventory;
	currently_observing_thing = thing;

	for inventory_item_entry in inventory:
		var item_info = ItemDatabase.get_item(inventory_item_entry[0]);
		inventory_item_list.add_item(item_info.name + " x" + str(inventory_item_entry[1]),
									 item_info.inventory_icon);

func _ready():
	pass

func _on_InventoryItemList_item_activated(index):
	var inventory_item_entry_information = currently_observing_inventory[index];
	if inventory_item_entry_information[1] > 0:
		inventory_item_entry_information[1] -= 1;
		ItemDatabase.apply_item_to(currently_observing_thing, inventory_item_entry_information[0]);
		print("prompt for usage on item");
	else:
		currently_observing_inventory.erase(inventory_item_entry_information);


func _on_InventoryItemList_nothing_selected():
	item_preview_widget.set_information("Nothing!", "Can you believe that? Nothing at all!", null);

func _on_InventoryItemList_item_selected(index):
	var inventory_item_entry_information = currently_observing_inventory[index];
	item_preview_widget.set_information_based_on_item(inventory_item_entry_information[0]);
