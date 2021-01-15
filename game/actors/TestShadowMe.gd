extends "res://game/actors/GameActor.gd"

func _ready():
	set_walking_speed(400);
	var shadow = add_party_member_default("Shadow Me");
	shadow.load_battle_portrait("isshin_test");
	shadow.attacks = [PartyMember.PartyMemberAttack.new("JUST DIE", 10032, 1)];
	shadow.health = 9999;
	shadow.max_health = 9999;
	shadow.level = 69;
	# shadow.set_max_health(9999);
	# shadow.set_max_mana(9999);
	pass
