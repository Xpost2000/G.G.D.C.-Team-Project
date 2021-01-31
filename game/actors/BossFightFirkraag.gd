extends "res://game/actors/GameActor.gd"

func _ready():
	set_walking_speed(0);
	var boss = add_party_member_default("Red Dragon (Firkraag)");
	boss.load_battle_sprite("res://scratchboard/sprites/FirkraagBattleSprite.tscn");
	boss.load_battle_portrait("sekijo_test");
	boss.attacks.push_back(PartyMember.PartyMemberAttack.new("Dragon Claw!", 1, 1.0, 0, PartyMember.ATTACK_VISUAL_HOLY_FLAME));
