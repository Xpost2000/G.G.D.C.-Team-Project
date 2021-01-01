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

const PartyMemberStatBlock = preload("res://game/PartyMemberStatBlock.gd");

var party_icon: Texture;
var portrait_battle_icon: Texture;

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
	self.stats = PartyMemberStatBlock.new();

	self.abilities = [];
	self.attacks = [];

func load_battle_portrait(name):
	self.portrait_battle_icon = load("res://images/battle/portraits/" + name + "_turn_portrait.png");

func load_party_icon(name):
	self.party_icon = load("res://images/party-icons/" + name + "_icon.png");

func random_attack_index():
	if len(attacks) > 0:
		return randi() % len(attacks);
	else:
		return -1;

func dead():
	return health <= 0;

func take_damage(amount):
	health -= amount;

func handle_ability(ability):
	print("TOIDOASOIDIOSDIOSADIOASDIOSADOISAOID");

func award_experience(amount):
	experience += amount;

	#TODO this should be a loop
	if experience >= experience_to_next:
		var remainder = experience_to_next - experience;
		level += 1;
		experience = remainder;
