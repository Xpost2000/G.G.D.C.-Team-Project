extends Resource;
class_name PartyMember
# TODO metadata for AI usage.

# not necessarily ATTACKS, just for now.
enum {ATTACK_VISUAL_PHYSICAL_BUMP,
	  ATTACK_VISUAL_WATER_GUN,
	  ATTACK_VISUAL_HOLY_FLAME,
	  ATTACK_VISUAL_FLAME,
	  ATTACK_VISUAL_HEALING}
class PartyMemberAttack:
	func _init(name, magnitude, accuracy, cost=0, visual_id=ATTACK_VISUAL_PHYSICAL_BUMP):
		self.name = name;
		self.magnitude = magnitude;
		self.accuracy = accuracy;
		self.visual_id = visual_id;
		self.cost = cost;

	var name: String;
	var visual_id: int;
	var type: int;
	var magnitude: int;
	# 0 - 1.0
	var accuracy: float;
	var cost: int;

	func get_icon_texture():
		return null;
	func get_item_list_string():
		return self.name;

enum {ABILITY_TYPE_NONE, ABILITY_TYPE_HEAL, ABILITY_TYPE_BUFF_STRENGTH}
# TODO metadata for AI usage.
class PartyMemberAbility:
	func _init(name, description, magnitude, accuracy, cost, type, visual_id=ATTACK_VISUAL_WATER_GUN):
		self.name = name;
		self.description = description;
		self.magnitude = magnitude;
		self.accuracy = accuracy;
		self.cost = cost;
		self.type = type;
		self.visual_id = visual_id;

	var name: String;
	var description: String;
	var type: int;
	var cost: int;
	var magnitude: int;
	var visual_id: int;
	# 0 - 1.0
	var accuracy: float;

	func get_icon_texture():
		return null;
	func get_item_list_string():
		return self.name + " :: " + self.description;

const PartyMemberStatBlock = preload("res://game/PartyMemberStatBlock.gd");

export(Texture) var party_icon: Texture = load("res://images/party-icons/unknown_character_icon.png");
export(Texture) var portrait_battle_icon: Texture = load("res://images/party-icons/unknown_character_turn_portrait.png");
var battle_sprite_scene: Resource;

export(String) var name: String;

export(int) var max_health: int = 100 setget set_new_maximum_health;
var health: int = max_health;

export(int) var max_mana_points: int = 100 setget set_new_maximum_mana;
var mana_points: int = max_mana_points;

func set_new_maximum_health(value: int):
	max_health = value;
	health = value;
	
func set_new_maximum_mana(value: int):
	max_mana_points = value;
	mana_points = value;
	
export(int) var defense: int = 10;

# of their respective types...
var abilities: Array;
export(Array) var attacks: Array;

export(int) var level: int = 1;
var experience: int = 0;
var experience_to_next: int = 0;

var hurt_sounds: Array;
var death_sound: String;

export(Resource) var stats: Resource = PartyMemberStatBlock.new();

func load_battle_sprite(path):
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
	self.stats.strength *= 1.05;
	self.stats.dexterity *= 1.10;
	self.stats.constitution *= 1.25;
	self.stats.willpower *= 1.16;
	self.stats.intelligence *= 1.16;
	# self.stats.charisma *= 1.5;
	self.stats.luck += 2;
	self.level += 1;

	self.max_health += int(self.stats.constitution * 0.20 + 10) + (self.level);
	self.max_mana_points += int(self.stats.intelligence * 0.20);

	self.health = self.max_health;
	self.mana_points = self.max_mana_points;
	self.defense += 4;

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

			self.experience_to_next *= 1.6;
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
	amount -= ((defense+(stats.dexterity/2)) * 0.25);
	health -= max(0, amount);

	if health <= 0 and death_sound:
		AudioGlobal.play_sound(death_sound);
	elif health > 0:
		if len(hurt_sounds) > 0:
			var random_sound = hurt_sounds[randi() % len(hurt_sounds)];
			print(random_sound);
			AudioGlobal.play_sound(random_sound);

func damage_amount(base):
	base *= int((0.4 + stats.strength * 0.03) + (stats.dexterity * 0.02));
	base += randi() % int(30+(stats.strength*0.5));
	return base;

func handle_ability(ability):
	match ability.type:
		ABILITY_TYPE_NONE:
			print("? How did this happen");
			pass;
		ABILITY_TYPE_HEAL:
			health += ability.magnitude;
			pass;
		ABILITY_TYPE_BUFF_STRENGTH:
			print("Strength buff for n turns?")
			pass;
		
