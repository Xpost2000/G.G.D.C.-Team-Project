extends "res://game/actors/GameActor.gd"

func _ready():
	set_walking_speed(0);
	var boss = add_party_member_default("Red Dragon (Firkraag)");
	boss.load_battle_sprite("res://scratchboard/sprites/FirkraagBattleSprite.tscn");
	boss.load_battle_portrait("firkraag");

	experience_value = 27500;
	boss.max_health = 3200;
	boss.health = 3200;

	boss.stats.strength = 200;
	boss.stats.dexterity = 120;
	boss.stats.constitution = 450;
	boss.defense = 439;
	boss.level = 40;

	# Artificially increasing the chances Firkraag will do a non KO move. Since Dragon Breath and Talon Streak are 1HKO
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Dragon Claw!", 50, 0.65, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Dragon Claw!", 50, 0.65, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Dragon Claw!", 50, 0.65, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Flame Breath!", 59, 0.60, 0, PartyMember.ATTACK_VISUAL_FLAME));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Swipe!", 30, 0.8, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Dragon Bite!", 20, 0.7, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Wing Buffer!", 20, 0.7, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Talon Streak!", 100, 0.5, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Firkraag's Dragon Breath!", 100, 0.70, 0, PartyMember.ATTACK_VISUAL_FLAME));

	inventory = [["healing_grass", 30],
				 ["healing_pod", 30],
				 ["divine_grass", 5],
				 ["dragon_heart", 1]];

	boss.hurt_sounds = ["snd/vo/FIRKRA04.WAV",
						"snd/vo/FIRKRA05.WAV",
						"snd/vo/FIRKRA03.WAV"];
	boss.death_sound = "snd/vo/FIRKRA06.WAV";
	gold = 12500;
