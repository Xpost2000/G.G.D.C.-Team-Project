extends "res://game/actors/GameActor.gd"

func cultist():
	var new_orc = add_party_member_default("Cultist");
	new_orc.stats.strength = 20 + (randi() % 30);
	new_orc.stats.dexterity = 20 + (randi() % 10)+1;
	new_orc.stats.constitution = 50;
	new_orc.stats.luck = 5;
	new_orc.stats.charisma = 0;

	new_orc.max_mana_points = 300;
	new_orc.mana_points = new_orc.max_mana_points;

	new_orc.max_health = 100 + randi() % 150 + 20;
	new_orc.health = new_orc.max_health;

	new_orc.defense = 10;

	new_orc.level = 11;

	new_orc.load_battle_sprite("res://scratchboard/sprites/CultistBattleSprite.tscn");
	new_orc.load_battle_portrait("sekijo_test");

	new_orc.attacks.push_back(PartyMemberAttack.new().make("Slap", 20, 1, 0));
	new_orc.attacks.push_back(PartyMemberAttack.new().make("Kick", 25, 1, 0));

	return new_orc;
	
func cultist_grand_wizard():
	var new_orc = add_party_member_default("Grand Wizard");
	new_orc.stats.strength = 80 + (randi() % 30);
	new_orc.stats.dexterity = 40 + (randi() % 10)+1;
	new_orc.stats.constitution = 120;
	new_orc.stats.luck = 5;
	new_orc.stats.charisma = 0;

	new_orc.max_mana_points = 300;
	new_orc.mana_points = new_orc.max_mana_points;

	new_orc.max_health = 500 + randi() % 100 + 20;
	new_orc.health = new_orc.max_health;

	new_orc.defense = 15;

	new_orc.level = 9;

	new_orc.load_battle_sprite("res://scratchboard/sprites/EliteCultistBattleSprite.tscn");
	new_orc.load_battle_portrait("sekijo_test");

	new_orc.attacks.push_back(PartyMemberAttack.new().make("Punch", 45, 1, 0));
	new_orc.attacks.push_back(PartyMemberAttack.new().make("Punch", 45, 1, 0));
	new_orc.attacks.push_back(PartyMemberAttack.new().make("Punch", 45, 1, 0));
	new_orc.attacks.push_back(PartyMemberAttack.new().make("Papercut!", 250, 0.2, 0));

	return new_orc;

func _ready():
	set_walking_speed(50);
	var orcs_generated = (randi() % 4) + 1;

	for orc in orcs_generated:
		match randi() % 3:
			0: cultist();
			1: cultist();
			2: cultist_grand_wizard();

	experience_value = 1100 * orcs_generated + (randi() % 1000);
	# Optimally we'd be dealing with data from a loot list or something
	inventory = [["healing_grass", 5],
				 ["healing_pod", 1]];
	gold = 500 + randi() % 500;
	pass
