extends "res://game/actors/GameActor.gd"
const GameActor = preload("res://game/actors/GameActor.gd");

onready var _stupid_sprite = $CharacterSprite;

# our main issue, is that these guys don't represent one.
# This is a PARTY, not a singular entity. That's the main thing we
# have to figure out.
signal transitioning_to_another_level(player, level_transition);
signal report_sprinting_information(stamina_percent, can_sprint, trying_to_sprint);
signal report_inventory_contents(player, player_inventory);
signal report_party_info_to_ui(party_members, amount_of_gold);
signal request_to_open_battle(left, right);
signal test_open_conversation;

# temporary lazy
enum {SPRITE_DIRECTION_UP,
	  SPRITE_DIRECTION_DOWN,
	  SPRITE_DIRECTION_RIGHT,
	  SPRITE_DIRECTION_LEFT}
var sprites = null;
# temporary lazy

func _ready():
	sprites = [
		load("res://images/overworld/actors/protag/up.png"),
		load("res://images/overworld/actors/protag/down.png"),
		load("res://images/overworld/actors/protag/right.png"),
		load("res://images/overworld/actors/protag/left.png")
		];

	var protag = add_party_member_default("Mr. Protagonist");
	protag.load_battle_portrait("sekijo_test");
	protag.attacks.push_back(PartyMember.PartyMemberAttack.new("Quick Slash", 45, 1.0));
	var deutag = add_party_member_default("Mr. Deuteragonist");
	deutag.attacks.push_back(PartyMember.PartyMemberAttack.new("Watergun!", 56, 1.0));
	deutag.load_battle_portrait("sekiro_test");
	inventory = [["healing_grass", 15],
				 ["healing_pod", 5]];
	gold = 350;

func movement_direction_vector():
	var movement_direction = Vector2.ZERO;

	if Input.is_action_pressed("ui_up"):
		movement_direction.y = -1;
		_stupid_sprite.texture = sprites[SPRITE_DIRECTION_UP];
	elif Input.is_action_pressed("ui_down"):
		movement_direction.y = 1;
		_stupid_sprite.texture = sprites[SPRITE_DIRECTION_DOWN];

	if Input.is_action_pressed("ui_left"):
		movement_direction.x = -1;
		_stupid_sprite.texture = sprites[SPRITE_DIRECTION_LEFT];
	elif Input.is_action_pressed("ui_right"):
		movement_direction.x = 1;
		_stupid_sprite.texture = sprites[SPRITE_DIRECTION_RIGHT];

	return movement_direction.normalized();

func handle_interact_key(delta):
	emit_signal("test_open_conversation");

func override_physics_process(delta):
	var sprinting = Input.is_action_pressed("game_sprinting_action");
	if !GameGlobals.paused() && !all_members_dead():
		handle_movement(sprinting,
						movement_direction_vector(),
						delta);

		if Input.is_action_just_pressed("game_interact_action"):
			print(GameGlobals.paused());
			handle_interact_key(delta);
		battle_cooldown += delta;
			
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


const BATTLE_COOLDOWN_MAX_TIME = 2.0;
var battle_cooldown = BATTLE_COOLDOWN_MAX_TIME;

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
		if parent is GameActor && battle_cooldown >= BATTLE_COOLDOWN_MAX_TIME && !parent.all_members_dead():
			print("Another actor.");
			print("I humbly request a battle with this one.");
			emit_signal("request_to_open_battle", self, parent);
			battle_cooldown = 0;
		else:
			print("Unknown parent or too many battles at once... Or they're a corpse.");

func _on_InteractableArea_area_exited(area):
	if area.name == "InteractableArea":
		print("i'm leaving you.")
