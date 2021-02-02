extends Resource;
class_name PartyMember

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

export(Array) var abilities: Array;
export(Array) var attacks: Array;

export(int) var level: int = 1;
var experience: int = 0;
var experience_to_next: int = 175;

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

const PartyMemberAbility = preload("res://game/PartyMemberAbility.gd");
func handle_ability(ability):
	match ability.type:
		PartyMemberAbility.AbilityType.NONE:
			print("? How did this happen");
			pass;
		PartyMemberAbility.AbilityType.HEAL:
			health += ability.magnitude;
			pass;
		PartyMemberAbility.AbilityType.BUFF_STRENGTH:
			print("Strength buff for n turns?")
			pass;
		
