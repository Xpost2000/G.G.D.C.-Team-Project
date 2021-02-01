extends "res://game/actors/GameActor.gd"

var plot_important = 1234;

var battle_music = "snd/planescapesoundtrack/theme.ogg"

func _ready():
	set_walking_speed(100);
	var father = add_party_member_default("The Father");
	father.load_battle_portrait("isshin_test");
	father.load_battle_sprite("res://scratchboard/sprites/TheFatherBattleSprite.tscn"); 
	father.attacks.push_back(PartyMember.PartyMemberAttack.new("Judgement!", 991823, 0.1, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	father.attacks.push_back(PartyMember.PartyMemberAttack.new("Penance.", 25, 0.8, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	father.attacks.push_back(PartyMember.PartyMemberAttack.new("Testament.", 25, 1, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	father.defense = 35;
	father.max_health = 1200;
	father.health = 1200;
	father.stats.strength = 150;
	father.stats.dexterity = 40;
	father.stats.constitution = 600;
	father.death_sound = "snd/vo/SOLARG07.WAV";
	father.hurt_sounds = ["snd/vo/SOLARF04.WAV"];

	var son = add_party_member_default("The Son");
	son.max_health = 2000;
	son.health = 2250;
	son.defense = 250;
	son.level = 25;
	son.stats.strength = 150;
	son.stats.dexterity = 100;
	son.stats.constitution = 450;

	son.load_battle_sprite("res://scratchboard/sprites/TheSonBattleSprite.tscn");
	son.load_battle_portrait("sekijo_test");
	son.attacks.push_back(PartyMember.PartyMemberAttack.new("Repent!", 24, 1.0, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	son.attacks.push_back(PartyMember.PartyMemberAttack.new("Sinner!", 30, 0.3, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	son.hurt_sounds = ["snd/vo/SOLARF04.WAV"];
	son.death_sound = "snd/vo/SOLARF06.WAV";

	var spirit = add_party_member_default("The Holy Spirit");
	spirit.load_battle_sprite("res://scratchboard/sprites/TheHolySpiritBattleSprite.tscn");
	spirit.load_battle_portrait("genichiro_test");
	experience_value = 1;

	spirit.attacks.push_back(PartyMember.PartyMemberAttack.new("Holy Flame.", 20, 1.0, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
	spirit.attacks.push_back(PartyMember.PartyMemberAttack.new("Soul Rend.", 30, 0.9, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));

	spirit.defense = 45;
	spirit.max_health = 1000;
	spirit.health = 1000;
	spirit.stats.strength = 400;
	spirit.stats.dexterity = -100;
	spirit.death_sound = "snd/vo/SOLARG07.WAV";
	spirit.hurt_sounds = ["snd/vo/SOLARF04.WAV"];
