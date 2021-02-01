extends "res://game/actors/GameActor.gd"

var plot_important = 1234;

func _ready():
	set_walking_speed(0);
	var spectre_a = add_party_member_default("Spectre");
	spectre_a.load_battle_portrait("isshin_test");
	spectre_a.load_battle_sprite("res://scratchboard/sprites/SpectreBattleSprite.tscn"); 
	spectre_a.attacks.push_back(PartyMember.PartyMemberAttack.new("Haunt", 15, 1.0, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	spectre_a.attacks.push_back(PartyMember.PartyMemberAttack.new("Spirit Axe Cleave", 38, 0.8, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));

	spectre_a.health = 1000;
	spectre_a.defense = 35;
	spectre_a.stats.strength = 150;
	spectre_a.stats.dexterity = 150;

	var boss = add_party_member_default("Horror");
	boss.load_battle_sprite("res://scratchboard/sprites/HorrorBattleSprite.tscn");
	boss.load_battle_portrait("sekijo_test");
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Haunt", 35, 0.7, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Apathy", 38, 0.6, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Tail Swipe", 10, 1.0, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Insanity", 27, 0.60, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Torment", 60, 0.20, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	boss.health = 1700;
	boss.defense = 20;
	boss.stats.strength = 270;
	boss.stats.dexterity = 250;

	var spectre_b = add_party_member_default("Spectre");
	spectre_b.load_battle_sprite("res://scratchboard/sprites/SpectreBattleSprite.tscn");
	spectre_b.load_battle_portrait("genichiro_test");
	experience_value = 1;
	spectre_b.attacks.push_back(PartyMember.PartyMemberAttack.new("Haunt", 15, 1.0, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	spectre_b.attacks.push_back(PartyMember.PartyMemberAttack.new("Spirit Axe Cleave", 38, 0.8, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));

	spectre_b.health = 1000;
	spectre_b.defense = 35;
	spectre_b.stats.strength = 100;
	spectre_b.stats.dexterity = 150;
