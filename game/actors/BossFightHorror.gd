extends "res://game/actors/GameActor.gd"

func _ready():
	set_walking_speed(0);
	var spectre_a = add_party_member_default("Spectre");
	spectre_a.load_battle_portrait("isshin_test");
	spectre_a.load_battle_sprite("res://scratchboard/sprites/SpectreBattleSprite.tscn"); 
	spectre_a.attacks.push_back(PartyMember.PartyMemberAttack.new("Judgement!", 1, 1.0, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));

	var boss = add_party_member_default("Horror");
	boss.load_battle_sprite("res://scratchboard/sprites/HorrorBattleSprite.tscn");
	boss.load_battle_portrait("sekijo_test");
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Haunt", 1, 1.0, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));

	var spectre_b = add_party_member_default("Spectre");
	spectre_b.load_battle_sprite("res://scratchboard/sprites/SpectreBattleSprite.tscn");
	spectre_b.load_battle_portrait("genichiro_test");
	experience_value = 9500;
	spectre_b.attacks.push_back(PartyMember.PartyMemberAttack.new("Holy Flame...", 1, 1.0, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
