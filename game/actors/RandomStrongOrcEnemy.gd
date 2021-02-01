extends "res://game/actors/GameActor.gd"

func orc_armored():
	var new_orc = add_party_member_default("Orc");
	new_orc.stats.strength = 140 + (randi() % 80);
	new_orc.stats.dexterity = 80 + (randi() % 10)+1;
	new_orc.stats.constitution = 120;
	new_orc.stats.luck = 5;
	new_orc.stats.charisma = 0;

	new_orc.max_mana_points = 300;
	new_orc.mana_points = new_orc.max_mana_points;

	new_orc.max_health = 500 + randi() % 350 + 50;
	new_orc.health = new_orc.max_health;

	new_orc.defense = 300;

	new_orc.level = 11;

	new_orc.load_battle_sprite("res://scratchboard/sprites/ArmoredOrcBattleSprite.tscn");
	new_orc.load_battle_portrait("sekijo_test");

	new_orc.attacks.push_back(PartyMember.PartyMemberAttack.new("Sword Slash", 50, 0.8, 0));
	new_orc.attacks.push_back(PartyMember.PartyMemberAttack.new("Sword Thrust", 95, 0.7, 0));

	return new_orc;
	
func orc_unarmed():
	var new_orc = add_party_member_default("Orc");
	new_orc.stats.strength = 130 + (randi() % 80);
	new_orc.stats.dexterity = 40 + (randi() % 10)+1;
	new_orc.stats.constitution = 120;
	new_orc.stats.luck = 5;
	new_orc.stats.charisma = 0;

	new_orc.max_mana_points = 300;
	new_orc.mana_points = new_orc.max_mana_points;

	new_orc.max_health = 345 + randi() % 150 + 80;
	new_orc.health = new_orc.max_health;

	new_orc.defense = 150;

	new_orc.level = 9;

	new_orc.load_battle_sprite("res://scratchboard/sprites/OrcBattleSprite.tscn");
	new_orc.load_battle_portrait("sekijo_test");

	new_orc.attacks.push_back(PartyMember.PartyMemberAttack.new("Punch", 45, 0.8, 0));
	new_orc.attacks.push_back(PartyMember.PartyMemberAttack.new("Strong Punch", 75, 0.50, 0));
	new_orc.attacks.push_back(PartyMember.PartyMemberAttack.new("Clobber Combo!", 350, 0.3, 0));

	return new_orc;

func orc_mage():
	var new_orc = add_party_member_default("Orc Mage");
	new_orc.stats.strength = 80 + (randi() % 40);
	new_orc.stats.dexterity = 10 + (randi() % 10)+1;
	new_orc.stats.constitution = 90;
	new_orc.stats.luck = 5;
	new_orc.stats.intelligence = 30;
	new_orc.stats.charisma = 0;

	new_orc.max_mana_points = 300;
	new_orc.mana_points = new_orc.max_mana_points;

	new_orc.max_health = 400 + randi() % 300;
	new_orc.health = new_orc.max_health;

	new_orc.defense = 15;

	new_orc.level = 7;

	new_orc.load_battle_sprite("res://scratchboard/sprites/OrcBattleSprite.tscn");
	new_orc.load_battle_portrait("sekijo_test");

	new_orc.attacks.push_back(PartyMember.PartyMemberAttack.new("Punch", 25, 0.9, 0));
	new_orc.attacks.push_back(PartyMember.PartyMemberAttack.new("Strong Punch", 45, 0.6, 0));
	new_orc.attacks.push_back(PartyMember.PartyMemberAttack.new("Water Blast!", 50, 0.95, 0, PartyMember.ATTACK_VISUAL_WATER_GUN));

	return new_orc;

func _ready():
	set_walking_speed(50);
	var orcs_generated = (randi() % 4) + 1;

	for orc in orcs_generated:
		match randi() % 5:
			0: orc_unarmed();
			1: orc_mage();
			2: orc_armored();
			3: orc_mage();
			4: orc_unarmed();

	experience_value = 2000 * orcs_generated + (randi() % 2500);
	# Optimally we'd be dealing with data from a loot list or something
	inventory = [["healing_grass", 10],
				 ["healing_pod", 5]];
	pass
