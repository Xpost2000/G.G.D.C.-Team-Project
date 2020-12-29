const PartyMemberStatBlock = preload("res://game/PartyMemberStatBlock.gd");

var party_icon: Texture;

var name: String;
var health: int;
var max_health: int;

var defense: int;

# of their respective types...
var abilities: Array;
var attacks: Array;

var level: int;
var experience: int;
var experience_to_next: int;

var stats: PartyMemberStatBlock;

func _init(name, health, defense):
	self.name = name;
	self.health = health;
	self.max_health = health;
	self.defense = defense;

	self.level = 1;
	self.experience = 0;
	self.experience_to_next = 150;

	self.party_icon = load("res://images/party-icons/unknown_character_icon.png");
	self.stats = PartyMemberStatBlock.new();

	self.abilities = [];
	self.attacks = [];

func load_party_icon(name):
	self.party_icon = load("res://images/party-icons/" + name + "_icon.png");

func dead():
	return health <= 0;

func take_damage(amount):
	health -= amount;

func award_experience(amount):
	experience += amount;

	#TODO this should be a loop
	if experience >= experience_to_next:
		var remainder = experience_to_next - experience;
		level += 1;
		experience = remainder;

class PartyMemberAttack:
	var name: String;
	var type: int;
	var magnitude: int;
	# 0 - 1.0
	var accuracy: float;

class PartyMemberAbility:
	var name: String;
	var description: String;
	var type: int;
	var magnitude: int;
	# 0 - 1.0
	var accuracy: float;
