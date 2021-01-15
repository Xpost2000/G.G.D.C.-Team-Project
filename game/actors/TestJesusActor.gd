extends "res://game/actors/GameActor.gd"

func _ready():
	set_walking_speed(100);
	var father = add_party_member_default("The Father");
	father.load_battle_portrait("isshin_test");
	father.load_battle_sprite("res://scratchboard/sprites/TheFatherBattleSprite.tscn"); 

	var son = add_party_member_default("The Son");
	son.load_battle_sprite("res://scratchboard/sprites/TheSonBattleSprite.tscn");
	son.load_battle_portrait("sekijo_test");

	var spirit = add_party_member_default("The Holy Spirit");
	spirit.load_battle_sprite("res://scratchboard/sprites/TheHolySpiritBattleSprite.tscn");
	spirit.load_battle_portrait("genichiro_test");
	experience_value = 200;

	# Optimally we'd be dealing with data from a loot list or something
	add_item("test_item");
	add_item("healing_grass", 99);
	pass
