extends "res://game/GameActor.gd"
const GameActor = preload("res://game/GameActor.gd");

# our main issue, is that these guys don't represent one.
# This is a PARTY, not a singular entity. That's the main thing we
# have to figure out.
signal transitioning_to_another_level(player, level_transition);
signal report_sprinting_information(stamina_percent, can_sprint, trying_to_sprint);
signal report_inventory_contents(player, player_inventory);
signal report_party_info_to_ui(party_members, amount_of_gold);
signal request_to_open_battle(left, right);
signal test_open_conversation;

func _ready():
	add_party_member_default("Mr. Protagonist");
	add_party_member_default("Mr. Deuteragonist");
	inventory = [["healing_grass", 15],
				 ["healing_pod", 5]];
	pass;

func movement_direction_vector():
	var movement_direction = Vector2.ZERO;

	if Input.is_action_pressed("ui_left"):
		movement_direction.x = -1;
	elif Input.is_action_pressed("ui_right"):
		movement_direction.x = 1;

	if Input.is_action_pressed("ui_up"):
		movement_direction.y = -1;
	elif Input.is_action_pressed("ui_down"):
		movement_direction.y = 1;

	return movement_direction.normalized();

func handle_interact_key(delta):
	emit_signal("test_open_conversation");

func _physics_process(delta):
	var sprinting = Input.is_action_pressed("game_sprinting_action");
	if !GameGlobals.paused() && !all_members_dead():
		handle_movement(sprinting,
						movement_direction_vector(),
						delta);

		if Input.is_action_just_pressed("game_interact_action"):
			print(GameGlobals.paused());
			handle_interact_key(delta);
			
	emit_signal("report_inventory_contents",
				self, inventory);
	emit_signal("report_sprinting_information", 
				float(sprinting_stamina)/float(SPRINTING_STAMINA_MAX),
				can_sprint(), 
				sprinting);
	emit_signal("report_party_info_to_ui",
				party_members, gold)

const LevelTransitionClass = preload("res://game/LevelTransition.gd");

# This is a stupid variable to prevent a potentially stupid bug.
# This would be solved by a state machine, but it's too early to marry ourselves
# to that, and it would take more time than doing this.
var just_transitioned_from_other_level = false;
func _on_InteractableArea_area_entered(area):
	if area is LevelTransitionClass:
		if just_transitioned_from_other_level:
			just_transitioned_from_other_level = false;
		else:
			emit_signal("transitioning_to_another_level", self, area);
	# I would make another node just to check the type explicitly...
	# but I'll settle for this since it takes less time.
	if area.name == "InteractableArea":
		var parent = area.get_parent();
		if parent is GameActor:
			print("Another actor.");
			print("I humbly request a battle with this one.");
			emit_signal("request_to_open_battle", self, parent);
		else:
			print("Unknown parent");
