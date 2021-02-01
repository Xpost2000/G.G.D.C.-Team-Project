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
		thing.health = min(thing.health, thing.max_health);

	var heal_power: int;

class StrengthBoosterItemImplementation extends ItemImplementationDetails:
	func _init(power):
		self.heal_power = power;

	func apply_to(thing):
		thing.stat.strength += self.heal_power;
		thing.stat.dexterity += self.heal_power;
		thing.stat.constitution += self.heal_power;

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
	items_dictionary["test_lantern"] = Item.new("Augite of Souls", 
											 "An iredescent stone fueled by souls. Changes color depending on the nature of nearby souls. Crafted by Geri, known for his magic handicrafts, and close acquaintance with Sage Freke the Visionary. Widely carried by travelers, who depend on its ease of use and light weight.", 
											 "images/inventory-icons/aos-des-ico.png", 
											 "images/inventory-icons/previews/aos-des.png",
												200);
	items_dictionary["healing_grass"] = Item.new("Healing Grass",
												 "A basic healing item",
												 "images/inventory-icons/dumpy_sword.png", 
												 "images/inventory-icons/previews/preview_golden_pantaloons.png",
												 100, HealingItemImplementation.new(370));

	items_dictionary["healing_pod"] = Item.new("Healing Pod",
											   "A slightly stronger basic healing item",
											   "images/inventory-icons/dumpy_sword.png", 
											   "images/inventory-icons/previews/preview_golden_pantaloons.png",
											   250, HealingItemImplementation.new(540));

	items_dictionary["stimpak"] = Item.new("Stimpak",
										   "Wait... This shouldn't be here...",
										   "images/inventory-icons/dumpy_sword.png", 
										   "images/inventory-icons/previews/preview_golden_pantaloons.png",
										   450, HealingItemImplementation.new(750));

	items_dictionary["divine_grass"] = Item.new("Divine Grass",
												"Imparted blessing of an ancient goddess into a sweet grass.",
												"images/inventory-icons/dumpy_sword.png", 
												"images/inventory-icons/previews/preview_golden_pantaloons.png",
												3500, HealingItemImplementation.new(9999));

	items_dictionary["dragon_heart"] = Item.new("Heart of A Red Dragon",
												"The heart of Firkraag. A great red dragon.",
												"images/inventory-icons/dumpy_sword.png", 
												"images/inventory-icons/previews/preview_golden_pantaloons.png",
												3500, StrengthBoosterItemImplementation.new(450));
	items_dictionary["plot_scrap"] = Item.new("Note", 
											  "Right, Middle, Left, Right, Left, Right, Right...", 
											  "images/inventory-icons/dumpy_sword.png", 
											  "images/inventory-icons/previews/preview_golden_pantaloons.png",
											  0);
	items_dictionary["plot_scrap1"] = Item.new("Quest Note!", 
											   "This memo speaks of a small detachment of cultists nearby... Deal with them to the south.", 
											   "images/inventory-icons/dumpy_sword.png", 
											   "images/inventory-icons/previews/preview_golden_pantaloons.png",
											   0);

	items_dictionary["modron_cube"] = Item.new("Modron Toy", 
											   "An action figure that resembles a modron... Wait how do you even know what that is?", 
											   "images/inventory-icons/dumpy_sword.png", 
											   "images/inventory-icons/previews/preview_golden_pantaloons.png",
											   0);

	items_dictionary["key_item"] = Item.new("Key", 
											"An old key... Might be useful...", 
											"images/inventory-icons/dumpy_sword.png", 
											"images/inventory-icons/previews/preview_golden_pantaloons.png",
											0);
func apply_item_to(thing, item_name):
	var item_to_apply = get_item(item_name);
	item_to_apply.implementation.apply_to(thing);
	
func get_item(name):
	return items_dictionary[name];
