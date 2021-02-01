extends "res://game/actors/GameActor.gd"

var plot_important = 1234;
var battle_music = "snd/planescapesoundtrack/fortress_battle.ogg"

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
	spectre_a.death_sound = "snd/vo/SMSPID06.WAV";
	spectre_a.hurt_sounds = ["snd/vo/SMSPID03.WAV",
							 "snd/vo/SMSPID02.WAV"];

	var boss = add_party_member_default("Horror");
	boss.load_battle_sprite("res://scratchboard/sprites/HorrorBattleSprite.tscn");
	boss.load_battle_portrait("sekijo_test");
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Haunt", 35, 0.7, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Apathy", 38, 0.6, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Tail Swipe", 10, 1.0, 0));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Insanity", 27, 0.60, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Torment", 60, 0.20, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	boss.health = 2300;
	boss.defense = 250;
	boss.stats.strength = 270;
	boss.stats.dexterity = 250;

	boss.death_sound = "snd/vo/SLAY07.WAV";
	boss.hurt_sounds = ["snd/vo/SLAY01.WAV",
						"snd/vo/SLAY05.WAV",
						"snd/vo/SNAKE06.WAV",
						"snd/vo/ABISH08.WAV"
						"snd/vo/SLAY06.WAV"];

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

	spectre_b.death_sound = "snd/vo/SMSPID06.WAV";
	spectre_b.hurt_sounds = ["snd/vo/SMSPID03.WAV",
							 "snd/vo/SMSPID02.WAV"];
