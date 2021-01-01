extends Node;

# Yeah, inheritance is the way to go here.
# Keeping my own type enum is a horrendous idea, and I don't
# know why I keep writing in a C style here.
#
# To be fair this just means I wish we had tagged unions.
#

# This is the "specific data"
# cause of the way gdscript works... I might have to
# put this into multiple files so I can check these as types.
class ItemImplementationDetails:
	func apply_to(thing):
		print("apply item base.");

class MiscItemImplementation extends ItemImplementationDetails:
	func apply_to(thing):
		print("misc item apply");

class HealingItemImplementation extends ItemImplementationDetails:
	func _init(power):
		self.heal_power = power;

	func apply_to(thing):
		thing.health += self.heal_power;
		print("healing item");

	var heal_power: int;

class Item:
	func _init(name,
			   description,
			   inventory_icon_path,
			   inventory_preview_image_path,
			   sell_value,
			   implementation_details = MiscItemImplementation.new()):
		self.name = name;
		self.description = description;
		self.inventory_icon = load("res://" + inventory_icon_path);
		self.inventory_preview_image = load("res://" + inventory_preview_image_path);
		self.sell_value = sell_value;
		self.implementation = implementation_details;
	
	var name: String;
	var description: String;
	var inventory_icon: Texture;
	var inventory_preview_image: Texture;
	var sell_value: int;
	var implementation: ItemImplementationDetails;

var items_dictionary = {};

func _ready():
	items_dictionary["test_item"] = Item.new("Golden Pantaloons", 
											 "Obligatory BG2:SOA reference", 
											 "images/inventory-icons/dumpy_sword.png", 
											 "images/inventory-icons/previews/preview_golden_pantaloons.png",
											 5000);
	items_dictionary["healing_grass"] = Item.new("Healing Grass",
												 "A basic healing item",
												 "images/inventory-icons/dumpy_sword.png", 
												 "images/inventory-icons/previews/preview_golden_pantaloons.png",
												 100, HealingItemImplementation.new(15));

	items_dictionary["healing_pod"] = Item.new("Healing Pod",
											   "A slightly stronger basic healing item",
											   "images/inventory-icons/dumpy_sword.png", 
											   "images/inventory-icons/previews/preview_golden_pantaloons.png",
											   250, HealingItemImplementation.new(30));
func apply_item_to(thing, item_name):
	var item_to_apply = get_item(item_name);
	item_to_apply.implementation.apply_to(thing);
	
func get_item(name):
	return items_dictionary[name];
