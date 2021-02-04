extends "res://game/actors/GameActor.gd"

func orc_armored():
	var new_orc = add_party_member_default("Orc");
	new_orc.stats.strength = 80 + (randi() % 30);
	new_orc.stats.dexterity = 40 + (randi() % 10)+1;
	new_orc.stats.constitution = 120;
	new_orc.stats.luck = 5;
	new_orc.stats.charisma = 0;

	new_orc.max_mana_points = 300;
	new_orc.mana_points = new_orc.max_mana_points;

	new_orc.max_health = 300 + randi() % 150 + 20;
	new_orc.health = new_orc.max_health;

	new_orc.defense = 160;

	new_orc.level = 11;

	new_orc.load_battle_sprite("res://scratchboard/sprites/ArmoredOrcBattleSprite.tscn");
	new_orc.load_battle_portrait("sekijo_test");

	new_orc.attacks.push_back(PartyMemberAttack.new().make("Sword Slash", 30, 1, 0));
	new_orc.attacks.push_back(PartyMemberAttack.new().make("Sword Thrust", 45, 1, 0));

	new_orc.hurt_sounds = ["snd/vo/OGRIL08.WAV"];
	new_orc.death_sound = "snd/vo/OGRIL09.WAV";

	return new_orc;
	
func orc_unarmed():
	var new_orc = add_party_member_default("Orc");
	new_orc.stats.strength = 80 + (randi() % 30);
	new_orc.stats.dexterity = 40 + (randi() % 10)+1;
	new_orc.stats.constitution = 120;
	new_orc.stats.luck = 5;
	new_orc.stats.charisma = 0;

	new_orc.max_mana_points = 300;
	new_orc.mana_points = new_orc.max_mana_points;

	new_orc.max_health = 205 + randi() % 100 + 20;
	new_orc.health = new_orc.max_health;

	new_orc.defense = 65;

	new_orc.level = 9;

	new_orc.load_battle_sprite("res://scratchboard/sprites/OrcBattleSprite.tscn");
	new_orc.load_battle_portrait("sekijo_test");

	new_orc.attacks.push_back(PartyMemberAttack.new().make("Punch", 25, 1, 0));
	new_orc.attacks.push_back(PartyMemberAttack.new().make("Strong Punch", 55, 0.50, 0));
	new_orc.attacks.push_back(PartyMemberAttack.new().make("Clobber Combo!", 150, 0.5, 0));

	new_orc.hurt_sounds = ["snd/vo/OGRIL08.WAV"];
	new_orc.death_sound = "snd/vo/OGRIL09.WAV";

	return new_orc;

func orc_mage():
	var new_orc = add_party_member_default("Orc Mage");
	new_orc.stats.strength = 40 + (randi() % 20);
	new_orc.stats.dexterity = 10 + (randi() % 10)+1;
	new_orc.stats.constitution = 90;
	new_orc.stats.luck = 5;
	new_orc.stats.intelligence = 30;
	new_orc.stats.charisma = 0;

	new_orc.max_mana_points = 300;
	new_orc.mana_points = new_orc.max_mana_points;

	new_orc.max_health = 200 + randi() % 100;
	new_orc.health = new_orc.max_health;

	new_orc.defense = 55;

	new_orc.level = 7;

	new_orc.load_battle_sprite("res://scratchboard/sprites/OrcBattleSprite.tscn");
	new_orc.load_battle_portrait("sekijo_test");

	new_orc.attacks.push_back(PartyMemberAttack.new().make("Punch", 15, 0.9, 0));
	new_orc.attacks.push_back(PartyMemberAttack.new().make("Strong Punch", 25, 0.6, 0));
	new_orc.attacks.push_back(PartyMemberAttack.new().make("Water Blast!", 30, 0.95, 0, PartyMemberAttack.AttackVisualId.PROJECTILE));

	new_orc.death_sound = "snd/vo/OGREM09.WAV";
	new_orc.hurt_sounds = ["snd/vo/OGRIL08.WAV"];

	return new_orc;

func initialize():
	set_walking_speed(50);
	var orcs_generated = (randi() % 4) + 1;

	for orc in orcs_generated:
		match randi() % 3:
			0: orc_unarmed();
			1: orc_armored();
			2: orc_mage();

	experience_value = 1200 * orcs_generated + (randi() % 2000);
	# Optimally we'd be dealing with data from a loot list or something
	inventory = [["healing_grass", 10],
				 ["healing_pod", 5]];

	gold = 200 + randi() % 500;
