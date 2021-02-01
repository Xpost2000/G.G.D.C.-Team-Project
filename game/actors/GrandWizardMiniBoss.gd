extends "res://game/actors/GameActor.gd"

func cultist_grand_wizard():
	var new_orc = add_party_member_default("The Grand Wizard");
	new_orc.stats.strength = 80 + (randi() % 30);
	new_orc.stats.dexterity = 40 + (randi() % 10)+1;
	new_orc.stats.constitution = 120;
	new_orc.stats.luck = 5;
	new_orc.stats.charisma = 0;

	new_orc.max_mana_points = 300;
	new_orc.mana_points = new_orc.max_mana_points;

	new_orc.max_health = 1750;
	new_orc.health = new_orc.max_health;

	new_orc.defense = 35;

	new_orc.level = 9;

	new_orc.load_battle_sprite("res://scratchboard/sprites/EliteCultistBattleSprite.tscn");
	new_orc.load_battle_portrait("sekijo_test");

	new_orc.attacks.push_back(PartyMember.PartyMemberAttack.new("Punch", 55, 0.8, 0));
	new_orc.attacks.push_back(PartyMember.PartyMemberAttack.new("Punch", 65, 0.7, 0));
	new_orc.attacks.push_back(PartyMember.PartyMemberAttack.new("Punch", 65, 0.7, 0));
	new_orc.attacks.push_back(PartyMember.PartyMemberAttack.new("Demonic Retribution!", 95, 0.9, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	new_orc.attacks.push_back(PartyMember.PartyMemberAttack.new("Papercut!", 250, 0.2, 0));

	return new_orc;

func _ready():
	set_walking_speed(0);
	cultist_grand_wizard();
	experience_value = 15000;
	# Optimally we'd be dealing with data from a loot list or something
	inventory = [["divine_grass", 3],
				 ["key_item", 1]];
	pass
