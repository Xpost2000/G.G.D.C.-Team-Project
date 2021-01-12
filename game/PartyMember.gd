# TODO metadata for AI usage.
class PartyMemberAttack:
	func _init(name, magnitude, accuracy):
		self.name = name;
		self.magnitude = magnitude;
		self.accuracy = accuracy;

	var name: String;
	var type: int;
	var magnitude: int;
	# 0 - 1.0
	var accuracy: float;

	func get_icon_texture():
		return null;
	func get_item_list_string():
		return self.name;

enum {ABILITY_TYPE_NONE}
# TODO metadata for AI usage.
class PartyMemberAbility:
	func _init(name, description, magnitude, accuracy, cost):
		self.name = name;
		self.description = description;
		self.magnitude = magnitude;
		self.accuracy = accuracy;
		self.cost = cost;

	var name: String;
	var description: String;
	var type: int;
	var cost: int;
	var magnitude: int;
	# 0 - 1.0
	var accuracy: float;

	func get_icon_texture():
		return null;
	func get_item_list_string():
		return self.name + " :: " + self.description;

const PartyMemberStatBlock = preload("res://game/PartyMemberStatBlock.gd");

var party_icon: Texture;
var portrait_battle_icon: Texture;
var battle_sprite_scene: Resource;

var name: String;
var health: int;
var max_health: int;

var mana_points: int;
var max_mana_points: int;

var defense: int;

# of their respective types...
var abilities: Array;
var attacks: Array;

var level: int;
var experience: int;
var experience_to_next: int;

var stats: PartyMemberStatBlock;

func _init(name, health, defense, mana=100):
	self.name = name;
	self.health = health;
	self.max_health = health;
	self.defense = defense;

	self.mana_points = mana;
	self.max_mana_points = mana;

	self.level = 1;
	self.experience = 0;
	self.experience_to_next = 150;

	self.party_icon = load("res://images/party-icons/unknown_character_icon.png");
	self.portrait_battle_icon = load("res://images/party-icons/unknown_character_turn_portrait.png");
	self.battle_sprite_scene = load("res://scratchboard/sprites/ProtagonistBattleSprite.tscn");
	self.stats = PartyMemberStatBlock.new();

	self.abilities = [];
	self.attacks = [];

func load_battle_sprite(path):
	# TODO(jerry): path
	self.battle_sprite_scene = load(path);

func load_battle_portrait(name):
	self.portrait_battle_icon = load("res://images/battle/portraits/" + name + "_turn_portrait.png");

func load_party_icon(name):
	self.party_icon = load("res://images/party-icons/" + name + "_icon.png");

func random_attack_index():
	if len(attacks) > 0:
		return randi() % len(attacks);
	else:
		return -1;

func do_levelup():
	self.stats.strength *= 1.5;
	self.stats.dexterity *= 1.5;
	self.stats.constitution *= 1.5;
	self.stats.willpower *= 1.5;
	self.stats.intelligence *= 1.5;
	self.stats.charisma *= 1.5;
	self.stats.luck *= 1.5;
	self.level += 1;

func award_experience(amount):
	self.experience += amount;
	
	var done_leveling = false;
	var levels_gained = 0;
	while !done_leveling:
		if self.experience >= self.experience_to_next:
			print("expecting level up!");
			var remainder = self.experience - self.experience_to_next;
			self.experience = remainder;
			levels_gained += 1;

			self.experience_to_next *= 1.55;
		else:
			done_leveling = true;
			print("gained ", levels_gained, " levels");

	var original_stat_block_and_level = [level, stats.duplicate()];
	for level in range(levels_gained):
		do_levelup();

	if levels_gained > 0:
		return [self, original_stat_block_and_level];
	else:
		return null;

func dead():
	return health <= 0;

func take_damage(amount):
	health -= amount;

func handle_ability(ability):
	print("TOIDOASOIDIOSDIOSADIOASDIOSADOISAOID");
