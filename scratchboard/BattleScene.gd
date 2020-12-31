extends Node2D

enum {
	COMBAT_FINISHED_REASON_FLEE, # The winning party is the one that didn't flee.
	COMBAT_FINISHED_REASON_DEFEAT_OF, # The winning party is the last one standing.
	COMBAT_FINISHED_REASON_FORCED # There are no winners or losers.
	}
class CombatFinishReasonData:
	func _init(type, winner, loser):
		self.type = type;
		self.winning_party = winner;
		self.losing_party = loser;
		
	var type: int;
	var winning_party: Array;
	var losing_party: Array;

func combat_finished_flee(initiator, opponent):
	return CombatFinishReasonData.new(COMBAT_FINISHED_REASON_FLEE, opponent, initiator);
func combat_finished_defeated(initiator, opponent):
	return CombatFinishReasonData.new(COMBAT_FINISHED_REASON_DEFEAT_OF, initiator, opponent);
func combat_finished_force(initiator, opponent):
	return CombatFinishReasonData.new(COMBAT_FINISHED_REASON_FORCED, null, null);

signal combat_finished(combat_finished_information);

onready var battle_layer = $BattleLayer;
onready var battle_ui_layer = $BattleUILayer;

onready var left_side_participants = $BattleLayer/LeftSideParticipants;
onready var right_side_participants = $BattleLayer/RightSideParticipants;

onready var left_side_info = $BattleUILayer/LeftSidePartyInfo;
onready var right_side_info = $BattleUILayer/RightSidePartyInfo;

onready var battle_turn_widget = $BattleUILayer/TurnMeter;
onready var battle_log_widget = $BattleUILayer/Battlelog;

# MAKE THIS OF TYPE P.C.
var party_on_the_left;
var party_on_the_right;

const PartyMember = preload("res://game/PartyMember.gd");
const BattleTurnAction = preload("res://game/BattleTurnAction.gd");
const BattleTurnStatus = preload("res://game/BattleTurnStatus.gd");

# keep this stupid thing in sync... Cause no enum types or no public export anyways...
enum {BATTLE_TURN_ACTION_SKIP_TURN,
	  BATTLE_TURN_ACTION_USE_ITEM,
	  BATTLE_TURN_ACTION_DO_ATTACK,
	  BATTLE_TURN_ACTION_DO_ABILITY,
	  BATTLE_TURN_ACTION_FLEE}

func skip_turn(actor_self):
	return BattleTurnAction.new(BATTLE_TURN_ACTION_SKIP_TURN, actor_self);

func flee(actor_self):
	return BattleTurnAction.new(BATTLE_TURN_ACTION_FLEE, actor_self);

func ability(actor_self, actor_target, which_ability):
	var ability_action = BattleTurnAction.new(BATTLE_TURN_ACTION_DO_ABILITY,
											  actor_self);
	ability_action.actor_target = actor_target;
	ability_action.index = which_ability;

	return ability_action;

func use_item(actor_self, actor_target, which_item):
	var ability_action = BattleTurnAction.new(BATTLE_TURN_ACTION_USE_ITEM,
											  actor_self);
	ability_action.actor_target = actor_target;
	ability_action.index = which_item;

	return ability_action;

func attack(actor_self, actor_target, which_attack):
	var attack_action = BattleTurnAction.new(BATTLE_TURN_ACTION_DO_ATTACK,
											 actor_self);
	attack_action.actor_target = actor_target;
	attack_action.index = which_attack;

	return attack_action;

func push_message_to_battlelog(message):
	var new_label = Label.new();
	new_label.text = message;
	battle_log_widget.add_child(new_label);

var battle_information = BattleTurnStatus.new();

func begin_battle(left, right):
	party_on_the_left = left;
	party_on_the_right = right;

	left_side_info.update_with_party_information(party_on_the_left.party_members);
	right_side_info.update_with_party_information(party_on_the_right.party_members);

	battle_information.participants = [];
	battle_information.participants += party_on_the_left.party_members;
	battle_information.participants += party_on_the_right.party_members;

# TODO Special message log labels, with their own special lifetime to delete themselves.
const BATTLE_LOG_MESSAGE_CLEAR_TIME = 0.85;
var battle_log_timer_to_clear_next_message = 0;
func update_battlelog(delta):
	var messages_in_log = len(battle_log_widget.get_children());
	if messages_in_log > 0:
		if battle_log_timer_to_clear_next_message >= BATTLE_LOG_MESSAGE_CLEAR_TIME:
			var last = battle_log_widget.get_children()[messages_in_log-1];
			battle_log_widget.remove_child(last);
			battle_log_timer_to_clear_next_message = 0;
			battle_log_timer_to_clear_next_message += delta;
	else:
		battle_log_timer_to_clear_next_message = 0;

# Technically... This doesn't matter to me... What I really care about
# is the "brain" controller.
# For now I'm ALWAYS assuming the player side is on the left, which is why I'm doing
# this...
# Ideally, I'd start the battle and pass "controller_type" to the sides so that way we can have
# the player on the left side or something.
enum {BATTLE_SIDE_NEITHER, BATTLE_SIDE_RIGHT, BATTLE_SIDE_LEFT};

func whose_side_is_active(active_actor):
	if active_actor in party_on_the_right.party_members:
		return BATTLE_SIDE_RIGHT;
	elif active_actor in party_on_the_left.party_members:
		return BATTLE_SIDE_LEFT;
	
	return BATTLE_SIDE_NEITHER;

func advance_actor():
	battle_information.advance_actor();
	push_message_to_battlelog("The turn goes to " + battle_information.active_actor().name);
	
const ARTIFICIAL_THINKING_TIME_MAX = 1.0;
var artificial_thinking_time = 0;
func _process(delta):
	if Input.is_action_just_pressed("ui_home"):
		GameGlobals.switch_to_scene(0);
	if !battle_information.decided_action:
		var active_actor = battle_information.active_actor();

		match whose_side_is_active(active_actor):
			BATTLE_SIDE_NEITHER: pass;
			BATTLE_SIDE_RIGHT:
				if artificial_thinking_time >= ARTIFICIAL_THINKING_TIME_MAX:
					# battle_information.decided_action = skip_turn(active_actor);
					battle_information.decided_action = attack(active_actor,
															   party_on_the_left.party_members[0],
															   active_actor.random_attack_index());
					artificial_thinking_time = 0;
					print("beep boop robot thoughts");
				else:
					artificial_thinking_time += delta;
			BATTLE_SIDE_LEFT:
				if Input.is_action_just_pressed("ui_end"):
					battle_information.decided_action = skip_turn(active_actor);
	else:
		print("Doing turn action.");

		var turn_action	= battle_information.decided_action;
		var current_actor = turn_action.actor_self;
		var target_actor = turn_action.actor_target;
		
		match turn_action.type:
			BATTLE_TURN_ACTION_SKIP_TURN:
				push_message_to_battlelog("Skipping turn...");
			BATTLE_TURN_ACTION_USE_ITEM:
				push_message_to_battlelog("Using item");
				# WHOOPS, THIS DOESN'T WORK BECAUSE I ONLY PASS THE RAW PARTY MEMBER ARRAY.
				# I SHOULD PASS THE ENTIRE PARTY INFO (gold and inventory).
				# var selected_item = current_actor.get_item
			BATTLE_TURN_ACTION_DO_ATTACK:
				push_message_to_battlelog("attacking something");
				# TODO figure out how I would do animation based on this.
				var selected_attack = current_actor.attacks[turn_action.index];
				push_message_to_battlelog(current_actor.name + " performs " + selected_attack.name);
				# insert plays animation!
				# TODO randomized attack hit chance or whatevers.
				target_actor.take_damage(selected_attack.magnitude);
			BATTLE_TURN_ACTION_DO_ABILITY: 
				push_message_to_battlelog("using ability");
				# TODO figure out how I would do animation based on this.
				var selected_ability = current_actor.abilities[turn_action.index];
				push_message_to_battlelog(current_actor.name + " performs " + selected_ability.name);
				# insert plays animation!
				# TODO randomized ability hit chance or whatevers. (unless it's like a friendly)
				target_actor.handle_ability(selected_ability);
			BATTLE_TURN_ACTION_FLEE: 
				# this would emit a signal...
				push_message_to_battlelog("fleeing from fight!");

				var initiator = null;
				var opponent = null;
				match whose_side_is_active(current_actor):
					BATTLE_SIDE_RIGHT:
						initiator = party_on_the_right;
						opponent = party_on_the_left.party_members;
					BATTLE_SIDE_LEFT:
						initiator = party_on_the_left;
						opponent = party_on_the_right.party_members;

				# TODO PartyMembers might want to know that they're part of a party...
				emit_signal("combat_finished", combat_finished_flee(initiator, opponent));

		# Check if the battle can end for any other reasons here...
		# mainly, the only other reason is if EVERYONE on a party is dead.

		# Basically this.
		# if party_on_the_right.all_members_dead():
		# if party_on_the_left.all_members_dead():

		if battle_information.decided_action.done():
			advance_actor();
		else:
			print("not done!");
			
				
	battle_turn_widget.update_view_of_turns(battle_information);
	update_battlelog(delta);


# TODO, scuffy
var on_opponent = false;
func _on_Area2D_input_event(viewport, event, shape_index):
	if on_opponent:
		if event is InputEventMouseButton:
			print("open menu! Or close");

func _on_Area2D_mouse_entered():
	print("touchy!");
	on_opponent = true;
