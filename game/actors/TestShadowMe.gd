extends "res://game/GameActor.gd"

const TIME_UNTIL_NEXT_THINK = 6.0;
var think_timer = TIME_UNTIL_NEXT_THINK;

func force_next_think():
	think_timer = TIME_UNTIL_NEXT_THINK;

class ThinkAction:
	func _init(type):
		self.type = type;
		
	var type: int;
	var walk_direction: Vector2;

enum{ ACTION_TYPE_NOTHING,
	  ACTION_TYPE_WALK_IN_DIRECTION,
	  ACTION_TYPE_COUNT };

func nothing_action():
	return ThinkAction.new(ACTION_TYPE_NOTHING);
	
func walk_action(direction):
	var new_action = ThinkAction.new(ACTION_TYPE_WALK_IN_DIRECTION);
	new_action.walk_direction = direction;
	return new_action;

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
func _process(delta):
	if !all_members_dead():
		if think_timer >= TIME_UNTIL_NEXT_THINK:
			thought_action = decide_new_action();
			think_timer = 0;

		think_timer += delta;

func _physics_process(delta):
	if !all_members_dead():
		match thought_action.type:
			ACTION_TYPE_NOTHING: pass;
			ACTION_TYPE_WALK_IN_DIRECTION:
				var successful_move = handle_movement(false, thought_action.walk_direction, delta);
				if !successful_move:
					force_next_think();

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
