extends "res://game/actors/GameActor.gd"

func _ready():
	set_walking_speed(0);
	var boss = add_party_member_default("Red Dragon (Firkraag)");
	boss.load_battle_sprite("res://scratchboard/sprites/FirkraagBattleSprite.tscn");
	boss.load_battle_portrait("sekijo_test");

	experience_value = 27500;
	boss.max_health = 2240;
	boss.health = 2240;

	boss.stats.strength = 220;
	boss.stats.dexterity = 120;
	boss.stats.constitution = 450;
	boss.defense = 37;
	boss.level = 40;

	# Artificially increasing the chances Firkraag will do a non KO move. Since Dragon Breath and Talon Streak are 1HKO
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Dragon Claw!", 60, 0.72, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Dragon Claw!", 60, 0.72, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Dragon Claw!", 60, 0.76, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Dragon Claw!", 60, 0.72, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Flame Breath!", 62, 0.60, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Swipe!", 30, 0.8, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Dragon Bite!", 20, 0.8, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Wing Buffer!", 20, 0.8, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Talon Streak!", 100, 0.5, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Firkraag's Dragon Breath!", 100, 0.70, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));

	inventory = [["healing_grass", 30],
				 ["healing_pod", 30],
				 ["divine_grass", 5],
				 ["dragon_heart", 1]];
