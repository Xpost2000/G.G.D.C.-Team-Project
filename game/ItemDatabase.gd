extends Node;
#
# We will only consider consumable items at this point to be simpler.
#
enum {
	ITEM_TYPE_MISC,
	ITEM_TYPE_HEALING_ITEM,
	ITEM_TYPE_STAT_BOOSTING_ITEM,
	};

class Item:
	func _init(type,
			   name,
			   description,
			   inventory_icon_path,
			   inventory_preview_image_path,
			   sell_value,
			   magnitude):
		self.type = type;
		self.name = name;
		self.description = description;
		self.inventory_icon = load("res://" + inventory_icon_path);
		self.inventory_preview_image = load("res://" + inventory_preview_image_path);
		self.sell_value = sell_value;
		self.magnitude = magnitude;
	
	var name: String;
	var description: String;
	var inventory_icon: Texture;
	var inventory_preview_image: Texture;
	var sell_value: int;
	var type: int;	
	var magnitude: float;

var items_dictionary = {};

func _ready():
	items_dictionary["test_item"] = Item.new(ITEM_TYPE_MISC, 
											"Golden Pantaloons", 
											"Obligatory BG2:SOA reference", 
											"images/inventory-icons/dumpy_sword.png", 
											"images/inventory-icons/previews/preview_golden_pantaloons.png",
											 5000,
											 1.0);
	items_dictionary["healing_grass"] = Item.new(ITEM_TYPE_HEALING_ITEM,
												 "Healing Grass",
												 "A basic healing item",
												 "images/inventory-icons/dumpy_sword.png", 
												 "images/inventory-icons/previews/preview_golden_pantaloons.png",
												 100,
												 15);

	items_dictionary["healing_pod"] = Item.new(ITEM_TYPE_HEALING_ITEM,
											   "Healing Pod",
											   "A slightly stronger basic healing item",
											   "images/inventory-icons/dumpy_sword.png", 
											   "images/inventory-icons/previews/preview_golden_pantaloons.png",
											   250,
											   30);
	
func get_item(name):
	return items_dictionary[name];
