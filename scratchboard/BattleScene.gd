extends Node2D

onready var battle_layer = $BattleLayer;
onready var battle_ui_layer = $BattleUILayer;

onready var left_side_participants = $BattleLayer/LeftSideParticipants;
onready var right_side_participants = $BattleLayer/RightSideParticipants;

onready var left_side_info = $BattleUILayer/LeftSidePartyInfo;
onready var right_side_info = $BattleUILayer/RightSidePartyInfo;

onready var battle_turn_widget = $BattleUILayer/TurnMeter;

var party_on_the_left;
var party_on_the_right;

const PartyMember = preload("res://game/PartyMember.gd");

class BattleTurnStatus:
	var active_actor_index: int;
	# This doesn't care about sides... Just give it in the order of initiative.
	var participants: Array;

	func _init():
		self.active_actor_index = 0;
		self.participants = [];

	func advance_actor():
		active_actor_index += 1;
		active_actor_index %= len(participants);

	func active_actor():
		return participants[active_actor_index];

var battle_information = BattleTurnStatus.new();

func _ready():
	# stupid filler test data
	party_on_the_right = [
		PartyMember.new("Genichiro Ashina", 150, 100),
		PartyMember.new("Isshin Ashina", 450, 100),
		];

	party_on_the_left = [
		PartyMember.new("Sekijo", 150, 100),
		PartyMember.new("Sekiro", 150, 100)
		];

	party_on_the_left[0].load_battle_portrait("sekiro_test");
	party_on_the_left[1].load_battle_portrait("sekijo_test");

	party_on_the_right[0].load_battle_portrait("genichiro_test");
	party_on_the_right[1].load_battle_portrait("isshin_test");

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
	
	left_side_info.update_with_party_information(party_on_the_left);
	right_side_info.update_with_party_information(party_on_the_right);

	battle_information.participants += party_on_the_left;
	battle_information.participants += party_on_the_right;
	battle_turn_widget.update_view_of_turns(battle_information);

# TODO, scuffy
var on_opponent = false;
func _on_Area2D_input_event(viewport, event, shape_index):
	if on_opponent:
		if event is InputEventMouseButton:
			print("open menu! Or close");

func _on_Area2D_mouse_entered():
	print("touchy!");
	on_opponent = true;
