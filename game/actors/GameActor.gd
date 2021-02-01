extends KinematicBody2D
signal handle_party_member_level_ups(members);

# for some tutorial quests maybe?
signal opened_inventory;

const SPRINTING_STAMINA_MAX = 75;
const STAMINA_REGENERATION_COOLDOWN_TIME = 1.66; # seconds

var stamina_regeneration_cooldown_timer = 0.0;
var sprinting_stamina = SPRINTING_STAMINA_MAX;

const PartyMember = preload("res://game/PartyMember.gd");

var SPRINTING_SPEED = 512;
var WALKING_SPEED = SPRINTING_SPEED/2;

func set_walking_speed(walking_speed):
	WALKING_SPEED = walking_speed;
	SPRINTING_SPEED = WALKING_SPEED * 2;

func set_sprinting_speed(sprinting_speed):
	SPRINTING_SPEED = sprinting_speed;
	WALKING_SPEED = SPRINTING_SPEED / 2;

var party_members = [];
var inventory = [];

var gold = 0;
var experience_value = 1;

func update_from_dictionary_data(data):
	global_position = Vector2(data["position"][0], data["position"][1]);
	inventory = data["inventory"];
	gold = data["gold"];

func dictionary_data():
	# TODO party members
	var dictionary_of_important_properties = {
		"position": [global_position.x, global_position.y],
		"inventory": inventory,
		"gold": gold
		};

	return dictionary_of_important_properties;

func all_members_dead():
	for party_member in party_members:
		if !party_member.dead():
			return false;
	return true;

func add_party_member_default(name):
	var new_member = PartyMember.new(name, 100, 100)
	party_members.push_back(new_member);
	return new_member;

func add_party_member(party_member):
	party_members.push_back(party_member);
	return party_member;

# -1 means all.
func find_item_of_name_in_inventory(item_name):
	var index_of_item_to_remove = -1;
	for item in inventory:
		if item[0] == item_name:
			index_of_item_to_remove = inventory.find(item);
			break;
	return index_of_item_to_remove;
	
func remove_item_from_inventory(item_name, amount=-1):
	var index_of_item_to_remove = find_item_of_name_in_inventory(item_name);
	if amount == -1:
		inventory[index_of_item_to_remove][1] = 0;
	else:
		inventory[index_of_item_to_remove][1] -= 1;

	if inventory[index_of_item_to_remove][1] <= 0:
		inventory.erase(inventory[index_of_item_to_remove]);

func add_item(item_name, amount=1):
	var index_of_item = find_item_of_name_in_inventory(item_name);

	if index_of_item == -1:
		inventory.append([item_name, amount]);
	else:
		inventory[index_of_item][1] += 1;

func can_sprint():
	return (sprinting_stamina > 0.0) && (stamina_regeneration_cooldown_timer <= 0.0);

func get_party_member(index):
	# later I'll do checking.
	return party_members[index];

func random_living_party_member():
	while true:
		var index = randi() % len(party_members);
		var party_member = party_members[index];
		if not party_member.dead():
			return party_member;

func index_of_first_alive_party_member(): 
	for index in len(party_members):
		var party_member = party_members[index];
		if !party_member.dead():
			return index;
	return -1;

func award_experience(amount):
	var leveled_up_party_members = [];
	for party_member in party_members:
		var stat_diff = party_member.award_experience(amount);
		if stat_diff:
			leveled_up_party_members.push_back(stat_diff);

	if len(leveled_up_party_members) > 0:
		emit_signal("handle_party_member_level_ups", leveled_up_party_members);

func first_alive_party_member():
	return get_party_member(index_of_first_alive_party_member());

func handle_sprinting(sprinting, delta):
	if sprinting && can_sprint():
		sprinting_stamina -= delta * 55.0;
		if sprinting_stamina <= 0:
			stamina_regeneration_cooldown_timer = STAMINA_REGENERATION_COOLDOWN_TIME;
	else:
		sprinting_stamina += delta * 25;
		
	if stamina_regeneration_cooldown_timer > 0:
		stamina_regeneration_cooldown_timer -= delta;
		
	sprinting_stamina = clamp(sprinting_stamina, 0, SPRINTING_STAMINA_MAX);

func handle_movement(sprinting, direction, delta):
	if !GameGlobals.paused():
		direction = direction.normalized();
		var velocity = direction * (SPRINTING_SPEED if sprinting && can_sprint() else WALKING_SPEED);
		handle_sprinting(sprinting && (direction.length() != 0), delta);
		var slide_velocity = move_and_slide(velocity, Vector2.UP);

		return (slide_velocity == velocity) && velocity.length() > 0;
	else:
		return true;

var allow_manual_processing = true;

func can_think():
	return allow_manual_processing && !all_members_dead();
func enable_think():
	allow_manual_processing = true;
func disable_think():
	allow_manual_processing = false;

func _physics_process(delta):
	if can_think():
		override_physics_process(delta);
	else:
		# in the case of AI, this will be identical behavior for them...
		# print("MOVE!");
		execute_actions(delta);

	if all_members_dead():
		hide();

func _process(delta):
	if can_think():
		override_process(delta);

# TODO put this in another file!
const TIME_UNTIL_NEXT_THINK = 6.0;
var think_timer = TIME_UNTIL_NEXT_THINK;

func force_next_think():
	think_timer = TIME_UNTIL_NEXT_THINK;
	thought_action = nothing_action();

class ThinkAction:
	func _init(type):
		self.type = type;
		
	var type: int;
	var walk_direction: Vector2; # or location if that's the case

enum{ ACTION_TYPE_NOTHING,
	  ACTION_TYPE_WALK_IN_DIRECTION,
	  ACTION_TYPE_WALK_TO,
	  ACTION_TYPE_COUNT };
# 349.713
# -61
func nothing_action():
	return ThinkAction.new(ACTION_TYPE_NOTHING);
	
func walk_action(direction):
	var new_action = ThinkAction.new(ACTION_TYPE_WALK_IN_DIRECTION);
	new_action.walk_direction = direction;
	return new_action;

func walk_to(where):
	var new_action = ThinkAction.new(ACTION_TYPE_WALK_TO);
	new_action.walk_direction = where;
	return new_action;

func _action_walk_to(where):
	thought_action = walk_to(where);
	print("setting action");

func action_walk_to(where):
	call_deferred("_action_walk_to", where);

func decide_new_action():
	var type = randi() % ACTION_TYPE_COUNT;
	match type:
		ACTION_TYPE_NOTHING:
			return nothing_action();
		ACTION_TYPE_WALK_IN_DIRECTION:
			print("I believe I will walk.")
			var directions = [Vector2(-1, -1), Vector2(-1, 0),
							  Vector2(1, 0), Vector2(1, -1),
							  Vector2(1, 1), Vector2(0, 1),
							  Vector2(0, -1), Vector2(-1, 1)];
			var new_walk_action = walk_action(directions[randi() % 8]);
			return new_walk_action;

var thought_action = nothing_action();
func execute_actions(delta):
	if thought_action:
		match thought_action.type:
			ACTION_TYPE_NOTHING: pass;
			ACTION_TYPE_WALK_TO: 
				var real_direction = (thought_action.walk_direction - global_position).normalized();
				var successful_move = handle_movement(false, real_direction, delta);

				# Should really be called "about" there... Hopefully no
				if !successful_move or (global_position.distance_to(thought_action.walk_direction) < 10):
					force_next_think();
				pass;
			ACTION_TYPE_WALK_IN_DIRECTION:
				var successful_move = handle_movement(false, thought_action.walk_direction, delta);
				if !successful_move:
					force_next_think();

func override_physics_process(delta):
	execute_actions(delta);

func override_process(delta):
	if think_timer >= TIME_UNTIL_NEXT_THINK:
		thought_action = decide_new_action();
		think_timer = 0;

	think_timer += delta;
