extends NinePatchRect;

signal prompt_for_item_usage_selection(party_members, item_name);
signal prompt_for_item_usage(item_name);

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
		if len(inventory_item_entry) == 2:
			inventory_item_list.add_item(item_info.name + " x" + str(inventory_item_entry[1]),
										 item_info.inventory_icon);
		else:
			# special cased for shops which hold INFINITE items
			inventory_item_list.add_item(item_info.name + " - " + str(item_info.sell_value) + " gp", item_info.inventory_icon);

func update_based_on_inventory(inventory):
	update_based_on_entity(null, inventory);

func _ready():
	update_based_on_inventory([["healing_grass"],
							   ["healing_pod"]]);
	pass

func _process(delta):
	# This is probably not safe to do. 
	if currently_observing_thing && currently_observing_inventory:
		for inventory_item_entry_information in currently_observing_inventory:
			if len(inventory_item_entry_information) == 2 and inventory_item_entry_information[1] <= 0:
				currently_observing_inventory.erase(inventory_item_entry_information);

func _on_InventoryItemList_item_activated(index):
	var inventory_item_entry_information = currently_observing_inventory[index];

	if currently_observing_thing:
		if (len(currently_observing_thing.party_members) == 1):
			if len(inventory_item_entry_information) == 2:
				inventory_item_entry_information[1] -= 1;
			ItemDatabase.apply_item_to(currently_observing_thing.get_party_member(0),
										inventory_item_entry_information[0]);
		else:
			emit_signal("prompt_for_item_usage_selection",
						currently_observing_thing.party_members,
						inventory_item_entry_information);
	else:
		emit_signal("prompt_for_item_usage", inventory_item_entry_information);


func _on_InventoryItemList_nothing_selected():
	item_preview_widget.set_information("Nothing!", "Can you believe that? Nothing at all!", null);

func _on_InventoryItemList_item_selected(index):
	var inventory_item_entry_information = currently_observing_inventory[index];
	item_preview_widget.set_information_based_on_item(inventory_item_entry_information[0]);
