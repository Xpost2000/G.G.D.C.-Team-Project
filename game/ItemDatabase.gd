extends Node;
enum {ITEM_TYPE_MISC, ITEM_TYPE_CONSUMABLE, ITEM_TYPE_WEAPON, ITEM_TYPE_ARMOR};

class Item:
	func _init(type, name, description, inventory_icon_path, inventory_preview_image_path, sell_value):
		self.type = type;
		self.name = name;
		self.description = description;
		self.inventory_icon = load("res://" + inventory_icon_path);
		self.inventory_preview_image = load("res://" + inventory_preview_image_path);
		self.sell_value = sell_value;
	
	var name: String;
	var description: String;
	var inventory_icon: Texture;
	var inventory_preview_image: Texture;
	var sell_value: int;
	var type: int;	

var items_dictionary = {};

func _ready():
	items_dictionary["test_item"] = Item.new(ITEM_TYPE_MISC, 
											"Golden Pantaloons", 
											"Obligatory BG2:SOA reference", 
											"images/inventory-icons/dumpy_sword.png", 
											"images/inventory-icons/previews/preview_golden_pantaloons.png",
											5000);
	
func get_item(name):
	return items_dictionary[name];
