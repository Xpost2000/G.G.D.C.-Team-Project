extends Node2D

onready var battle_layer = $BattleLayer;
onready var battle_ui_layer = $BattleUILayer;

onready var left_side_participants = $BattleLayer/LeftSideParticipants;
onready var right_side_participants = $BattleLayer/RightSideParticipants;

var party_on_the_left;
var party_on_the_right;

const PartyMember = preload("res://game/PartyMember.gd");
onready var party_member_card_prefab = preload("res://ui/PartyMemberCard.tscn");

func _ready():
	# stupid filler test data
	party_on_the_right = [
		PartyMember.new("Genichiro Ashina", 150, 100),
		PartyMember.new("Isshin Ashina", 450, 100),
		];

	party_on_the_left = [
		PartyMember.new("Sekijo", 150, 100),
		PartyMember.new("Sekiro", 150, 100),
		];

	party_on_the_left[0].attacks = [PartyMember.PartyMemberAttack.new("Vertical Slash", 67, 1),
									PartyMember.PartyMemberAttack.new("Thrust", 90, 0.6)];
	party_on_the_left[0].abilities = [PartyMember.PartyMemberAbility.new("Ashina Cross", "Mushin art", 240, 1.0, 150),
									  PartyMember.PartyMemberAbility.new("Whirlwind Slash", "Art", 75, 0.95, 25)];
	party_on_the_left[1].attacks = [PartyMember.PartyMemberAttack.new("Nightjar Slash", 80, 0.8),
									PartyMember.PartyMemberAttack.new("Shadowfall", 90, 0.75)];
	party_on_the_left[1].abilities = [PartyMember.PartyMemberAbility.new("Ashina Cross", "Mushin art", 240, 1.0, 150),
									  PartyMember.PartyMemberAbility.new("Shinobi Axe of the Monkey", "Prosethetic", 90, 0.75, 300)];

	party_on_the_right[0].attacks = [PartyMember.PartyMemberAttack.new("Vertical Slash", 67, 1),
									 PartyMember.PartyMemberAttack.new("Bow Fire", 120, 0.8)];
	party_on_the_right[0].abilities = [PartyMember.PartyMemberAbility.new("Lightning of Tomoe", "Mushin art", 999, 0.1, 900),
									   PartyMember.PartyMemberAbility.new("Spiral Cloud Passage", "Art", 255, 0.95, 25)];
	party_on_the_right[1].attacks = [PartyMember.PartyMemberAttack.new("Ashina Cross", 240, 0.8),
									 PartyMember.PartyMemberAttack.new("Dragonflash", 140, 0.95)];
	party_on_the_right[1].abilities = [PartyMember.PartyMemberAbility.new("Dragonslash", "Mushin art", 440, 1.0, 350),
									   PartyMember.PartyMemberAbility.new("One Mind", "Death", 600, 1.5, 300)];
	pass

# TODO, scuffy
var on_opponent = false;
func _on_Area2D_input_event(viewport, event, shape_index):
	if on_opponent:
		if event is InputEventMouseButton:
			print("open menu! Or close");

func _on_Area2D_mouse_entered():
	print("touchy!");
	on_opponent = true;
