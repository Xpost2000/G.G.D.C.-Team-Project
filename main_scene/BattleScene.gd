extends Node2D
# also welcome to monster file.
# TODO: AOE attacks?

# TODO when I'm back on emacs, when the hell did I decide party_on_the_* was a good idea?
# I guess when I was just testing stuff out but I'm probably not changing things too much since it's
# not really necessary.

var table_of_hit_sounds = ["snd/hit0.wav", "snd/hit1.wav", "snd/hit2.wav", "snd/hit3.wav"];
func play_random_hit_sound():
	var index = randi() % len(table_of_hit_sounds);
	AudioGlobal.play_sound(table_of_hit_sounds[index]);

enum {
	COMBAT_FINISHED_REASON_FLEE, # The winning party is the one that didn't flee.
	COMBAT_FINISHED_REASON_DEFEAT_OF, # The winning party is the last one standing.
	COMBAT_FINISHED_REASON_FORCED # There are no winners or losers.
	}
signal combat_finished(combat_finished_information);

const BloodParticleSystemPrefab = preload("res://game/misc_entities/BloodParticleSystem.tscn");

onready var battle_layer = $BattleLayer;
onready var battle_ui_layer = $BattleUILayer;

onready var left_side_participants = $BattleLayer/LeftSideParticipants;
onready var right_side_participants = $BattleLayer/RightSideParticipants;

onready var left_side_info = $BattleUILayer/LeftSidePartyInfo;
onready var right_side_info = $BattleUILayer/RightSidePartyInfo;

onready var battle_turn_widget = $BattleUILayer/TurnMeter;
onready var battle_turn_widget_head_label = $BattleUILayer/TurnMeter/Head;
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

func finished_bump_animation(anim_name, animation_player, attack_action):
	remove_child(animation_player);
	animation_player.queue_free();
	attack_action.marked_done = true;
	print("play animation")

func remove_particle_system_and_timer(timer, particle_system):
	remove_child(timer);
	remove_child(particle_system);
	timer.queue_free();
	particle_system.queue_free();

const DIRECTION_MAGNITUDE = 1.56;
func entity_take_damage(target, damage):
	print("PREPARE TO DIE");
	target.take_damage(damage);
	# TODO, probably don't make a new instance each time.
	var new_particle_system = BloodParticleSystemPrefab.instance();
	var target_information = participant_side_and_index_of_actor(target);
	var target_battle_sprite = target_information[0][target_information[1]];
	new_particle_system.global_position = target_battle_sprite.global_position;
	new_particle_system.emitting = true;
	new_particle_system.one_shot = true;
	var new_timer = Timer.new();
	new_timer.connect("timeout", self, "remove_particle_system_and_timer", [new_timer, new_particle_system]);
	add_child(new_timer);
	new_timer.wait_time = 10; # a good enough time based on my settings.
	new_timer.start();
	if target_information[0] == right_side_participants.get_children():
		new_particle_system.direction = Vector2(DIRECTION_MAGNITUDE, 0);
	else:
		new_particle_system.direction = Vector2(-DIRECTION_MAGNITUDE, 0);
	add_child(new_particle_system);
	play_random_hit_sound();

# fun....
func create_attack_bump_animation(attacker, target, attack):
	var attacker_information = participant_side_and_index_of_actor(attacker);
	var target_information = participant_side_and_index_of_actor(target);
	var attacker_battle_sprite = attacker_information[0][attacker_information[1]];
	var target_battle_sprite = target_information[0][target_information[1]];

	var attack_bump = Animation.new();
	attack_bump.length = 2.25;
	var target_color_track_index = attack_bump.add_track(0);
	var self_method_track_index = attack_bump.add_track(2);
	var attacker_position_track_index = attack_bump.add_track(0);

	attack_bump.track_set_path(target_color_track_index, String(target_battle_sprite.get_path()) + ":self_modulate");
	attack_bump.track_set_path(attacker_position_track_index, String(attacker_battle_sprite.get_path()) + ":global_position");
	attack_bump.track_set_path(self_method_track_index, String(self.get_path()));

	attack_bump.track_set_interpolation_type(attacker_position_track_index, Animation.INTERPOLATION_LINEAR);
	attack_bump.track_set_interpolation_type(target_color_track_index, Animation.INTERPOLATION_CUBIC);
	attack_bump.track_insert_key(target_color_track_index, 0, Color(1, 1, 1));
	attack_bump.track_insert_key(attacker_position_track_index, 0, attacker_battle_sprite.global_position);
	var direction_between_target_and_attacker = (target_battle_sprite.global_position - attacker_battle_sprite.global_position).normalized(); 
	var position_right_before_attack = target_battle_sprite.global_position - (direction_between_target_and_attacker * 45);
	attack_bump.track_insert_key(attacker_position_track_index, 0.5, position_right_before_attack);
	attack_bump.track_insert_key(attacker_position_track_index, 0.9, position_right_before_attack);
	attack_bump.track_insert_key(target_color_track_index, 0.89, Color(1, 1, 1));
	attack_bump.track_insert_key(attacker_position_track_index, 0.98, target_battle_sprite.global_position);
	attack_bump.track_insert_key(target_color_track_index, 1.02, Color(1, 0, 0));
	# Did I have to make another track to have same time?
	attack_bump.track_insert_key(self_method_track_index, 1.03, {"method": "entity_take_damage", "args": [target, attack.magnitude]});
	attack_bump.track_insert_key(self_method_track_index, 1.02, {"method": "begin_camera_shake", "args": [0.45, 25]});
	# s
	attack_bump.track_insert_key(attacker_position_track_index, 1.18, position_right_before_attack);
	attack_bump.track_insert_key(target_color_track_index, 1.18, Color(1, 1, 1));
	attack_bump.track_insert_key(attacker_position_track_index, 1.5, position_right_before_attack);
	attack_bump.track_insert_key(attacker_position_track_index, 2.0, attacker_battle_sprite.global_position);
	attack_bump.value_track_set_update_mode(target_color_track_index, Animation.UPDATE_CONTINUOUS);
	attack_bump.value_track_set_update_mode(attacker_position_track_index, Animation.UPDATE_CONTINUOUS);

	return attack_bump;

func attack(actor_self, actor_target, which_attack):
	var attack_action = BattleTurnAction.new(BATTLE_TURN_ACTION_DO_ATTACK,
											 actor_self);
	attack_action.actor_target = actor_target;
	attack_action.index = which_attack;

	populate_participants_with_sprites(left_side_participants, party_on_the_left.party_members);

	var animation_player = AnimationPlayer.new();
	add_child(animation_player);
	animation_player.add_animation("temporary_bump_hit", create_attack_bump_animation(actor_self, actor_target, actor_self.attacks[which_attack]));
	animation_player.play("temporary_bump_hit");
	animation_player.connect("animation_finished", self, "finished_bump_animation", [animation_player, attack_action]);

	battle_log_widget.push_message(actor_self.name + " performs " + actor_self.attacks[which_attack].name);

	return attack_action;

var battle_information = BattleTurnStatus.new();

func populate_participants_with_sprites(side, party_members):
	for child in side.get_children():
		side.remove_child(child);

	var y_cursor = 0;
	for party_member in party_members:
		var new_sprite = party_member.battle_sprite_scene.instance();
		new_sprite.position.y = y_cursor;

		y_cursor += new_sprite.frames.get_frame("idle", 0).get_size().y * 1.56;
		side.add_child(new_sprite);

func begin_battle(left, right):
	party_on_the_left = left;
	party_on_the_right = right;

	left_side_info.update_with_party_information(party_on_the_left.party_members);
	right_side_info.update_with_party_information(party_on_the_right.party_members);

	battle_information.participants = [];
	battle_information.participants += party_on_the_left.party_members;
	battle_information.participants += party_on_the_right.party_members;

	populate_participants_with_sprites(left_side_participants, party_on_the_left.party_members);
	populate_participants_with_sprites(right_side_participants, party_on_the_right.party_members);

	focused_party = party_on_the_left;


# Technically... This doesn't matter to me... What I really care about
# is the "brain" controller.
# For now I'm ALWAYS assuming the player side is on the left, which is why I'm doing
# this...
# Ideally, I'd start the battle and pass "controller_type" to the sides so that way we can have
# the player on the left side or something.

# when the hell is neither going to happen?
enum {BATTLE_SIDE_NEITHER, BATTLE_SIDE_RIGHT, BATTLE_SIDE_LEFT};

const SAME_SIDE_INDEX = 0;
const OPPOSING_SIDE_INDEX = 1;
func get_party_pairs(side):
	match side:
		BATTLE_SIDE_LEFT: return [party_on_the_left, party_on_the_right];
		BATTLE_SIDE_RIGHT: return [party_on_the_right, party_on_the_left];
	return null;

func get_party_from_side(side):
	match side:
		BATTLE_SIDE_LEFT: return party_on_the_left;
		BATTLE_SIDE_RIGHT: return party_on_the_right;
	return null;
	
func participant_side_and_index_of_actor(actor):
	if actor in party_on_the_right.party_members:
		return [right_side_participants.get_children(), party_on_the_right.party_members.find(actor)];
	elif actor in party_on_the_left.party_members:
		return [left_side_participants.get_children(), party_on_the_left.party_members.find(actor)];

func whose_side_is_active(active_actor):
	if active_actor in party_on_the_right.party_members:
		return BATTLE_SIDE_RIGHT;
	elif active_actor in party_on_the_left.party_members:
		return BATTLE_SIDE_LEFT;
	
	return BATTLE_SIDE_NEITHER;

func advance_actor():
	battle_information.advance_actor();
	battle_log_widget.push_message("The turn goes to " + battle_information.active_actor().name);

# This shouldn't be here.
const ARTIFICIAL_THINKING_TIME_MAX = 1.0;
var artificial_thinking_time = 0;

const GameActor = preload("res://game/actors/GameActor.gd");
const PlayerCharacter = preload("res://game/actors/PlayerCharacter.gd");

# a stupid helper function
func finish_battle(reason, winner, loser):
	emit_signal("combat_finished", reason, winner, loser);
	GameGlobals.switch_to_scene(0);

func report_inventory_of_active_party():
	var active_actor = battle_information.active_actor();
	var active_party = get_party_pairs(whose_side_is_active(active_actor))[0];
	# inventory_ui.update_based_on_entity(active_party, active_party.inventory);

var camera_shake_timer_length = 0;
var camera_shake_timer = 0;
var camera_shake_strength = 0;

func begin_camera_shake(length, magnitude):
	camera_shake_timer_length = length;
	camera_shake_timer = 0;
	camera_shake_strength = magnitude;

func handle_camera_shake(delta):
	if camera_shake_timer <= camera_shake_timer_length:
		$Camera2D.offset = Vector2(rand_range(-camera_shake_strength, camera_shake_strength),
								   rand_range(-camera_shake_strength, camera_shake_strength));
		camera_shake_timer += delta;
	else:
		$Camera2D.offset = Vector2.ZERO;
	
var focused_party = null;
var focused_party_member_index = 0;

func recalculate_party_member_index(changing_to_party):
	var percent = float(focused_party_member_index)/(len(focused_party.party_members)-1);
	return int((len(changing_to_party.party_members)-1) * percent);

const SelectionOptionsMenu = preload("res://ui/BattleSelectionOptions.tscn");
var last_created_selection_menu = null;
func _process(delta):
	if party_on_the_left and party_on_the_right:
		if !battle_information.decided_action:
			var active_actor = battle_information.active_actor();
			var party = get_party_from_side(whose_side_is_active(active_actor));

			var parties = get_party_pairs(whose_side_is_active(active_actor));
			report_inventory_of_active_party();

			if party is GameActor:
				if party is PlayerCharacter:
					battle_turn_widget_head_label.text = "YOUR TURN";

					if Input.is_action_just_pressed("ui_up"):
						focused_party_member_index -= 1;
					if Input.is_action_just_pressed("ui_down"):
						focused_party_member_index += 1;
					if Input.is_action_just_pressed("ui_right"):
						focused_party_member_index = recalculate_party_member_index(party_on_the_right);
						focused_party = party_on_the_right;
					if Input.is_action_just_pressed("ui_left"):
						focused_party_member_index = recalculate_party_member_index(party_on_the_left);
						focused_party = party_on_the_left;
					if Input.is_action_just_pressed("ui_accept"):
						if last_created_selection_menu:
							last_created_selection_menu.queue_free();

						var new_selection_menu = SelectionOptionsMenu.instance();

						var participants_side = left_side_participants if focused_party == party_on_the_left else right_side_participants;
						var focused_party_member = participants_side.get_children()[focused_party_member_index];

						var direction = Vector2.ZERO;
						if focused_party == party_on_the_left:
							direction = Vector2(1, 0);
						else:
							direction = Vector2(-1, 0);

						new_selection_menu.rect_position = focused_party_member.global_position + (direction * 85);
						battle_ui_layer.add_child(new_selection_menu);
						last_created_selection_menu = new_selection_menu;

					if focused_party_member_index <= 0:
						focused_party_member_index = 0;
					elif focused_party_member_index >= len(focused_party.party_members):
						focused_party_member_index = len(focused_party.party_members)-1;

					highlight_actor(focused_party.party_members[focused_party_member_index]);
				else:
					battle_turn_widget_head_label.text = "AI THINKING...";
					if artificial_thinking_time >= ARTIFICIAL_THINKING_TIME_MAX:
						var attack_index = active_actor.random_attack_index();

						if attack_index != -1:
							battle_information.decided_action = attack(active_actor,
																	   parties[OPPOSING_SIDE_INDEX].first_alive_party_member(),
																	   attack_index);
						else:
							battle_information.decided_action = skip_turn(active_actor);

						artificial_thinking_time = 0;
						print("beep boop robot thoughts");
					else:
						artificial_thinking_time += delta;
		else:
			var turn_action	= battle_information.decided_action;
			var current_actor = turn_action.actor_self;
			var target_actor = turn_action.actor_target;

			var parties = get_party_pairs(whose_side_is_active(current_actor));

			# fix messages.
			match turn_action.type:
				BATTLE_TURN_ACTION_SKIP_TURN:
					battle_log_widget.push_message("Skipping turn...");
				BATTLE_TURN_ACTION_USE_ITEM:
					battle_turn_widget_head_label.text = "USE ITEM!";
					battle_log_widget.push_message("Using item");

					var item_to_use = parties[0].inventory[turn_action.index];
					item_to_use[1] -= 1;
					ItemDatabase.apply_item_to(turn_action.actor_target, item_to_use[0]);
				BATTLE_TURN_ACTION_DO_ATTACK: battle_turn_widget_head_label.text = "ATTACKING!";
				BATTLE_TURN_ACTION_DO_ABILITY: 
					battle_turn_widget_head_label.text = "ABILITY!";
					battle_log_widget.push_message("using ability");
					# TODO figure out how I would do animation based on this.
					var selected_ability = current_actor.abilities[turn_action.index];
					battle_log_widget.push_message(current_actor.name + " performs " + selected_ability.name);
					# insert plays animation!
					# TODO randomized ability hit chance or whatevers. (unless it's like a friendly)
					target_actor.handle_ability(selected_ability);
				BATTLE_TURN_ACTION_FLEE: 
					battle_turn_widget_head_label.text = "COWARD!";
					# this would emit a signal...
					battle_log_widget.push_message("fleeing from fight!");

					finish_battle(COMBAT_FINISHED_REASON_FLEE, parties[0], parties[1]);

			if battle_information.decided_action.done():
				# TODO: do death fade out or something!
				if party_on_the_right.all_members_dead():
					finish_battle(COMBAT_FINISHED_REASON_DEFEAT_OF, party_on_the_left, party_on_the_right);
				elif party_on_the_left.all_members_dead():
					finish_battle(COMBAT_FINISHED_REASON_DEFEAT_OF, party_on_the_right, party_on_the_left);

				advance_actor();


		handle_camera_shake(delta);
		battle_turn_widget.update_view_of_turns(battle_information);

func filter_for_non_dead(party_members):
	var result = [];
	for party_member in party_members:
		if !party_member.dead():
			result.push_back(party_member);
	return result;

var last_highlighted_actor = null;
func unhighlight_last_actor_when_present():
	if last_highlighted_actor:
		last_highlighted_actor.self_modulate = Color(1, 1, 1);

func highlight_actor(actor):
	var actor_information = participant_side_and_index_of_actor(actor);
	var actor_battle_sprite = actor_information[0][actor_information[1]];
	unhighlight_last_actor_when_present();
	actor_battle_sprite.self_modulate = Color(1, 1, 0);
	last_highlighted_actor = actor_battle_sprite;
