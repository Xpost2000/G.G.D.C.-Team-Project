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
	protag.max_health = 1000;
	protag.health = 1000;

	protag.stats.strength = 72;
	protag.stats.dexterity = 45;
	protag.stats.constitution = 35;
	protag.stats.luck = 1;
	protag.defense = 35;

	protag.max_mana_points = 120;
	protag.mana_points = 120;

	protag.load_battle_portrait("sekijo_test");
	protag.attacks.push_back(PartyMember.PartyMemberAttack.new("Quick Slash", 50, 1.0));
	protag.attacks.push_back(PartyMember.PartyMemberAttack.new("Power Attack!", 100, 0.75, 25));
	protag.attacks.push_back(PartyMember.PartyMemberAttack.new("All In!", 350, 0.15, 25));

	var deutag = add_party_member_default("Mr. Deuteragonist");
	deutag.max_health = 700;
	deutag.health = 700;

	deutag.stats.strength = 60;
	deutag.stats.dexterity = 50;
	deutag.stats.intelligence = 45;
	deutag.stats.constitution = 50;
	deutag.stats.luck = 25;
	deutag.defense = 40;

	deutag.max_mana_points = 300;
	deutag.mana_points = 300;

	deutag.attacks.push_back(PartyMember.PartyMemberAttack.new("Watergun!", 56, 1.0, 0, PartyMember.ATTACK_VISUAL_WATER_GUN));
	deutag.attacks.push_back(PartyMember.PartyMemberAttack.new("Aqua Cannon!", 80, 0.7, 0, PartyMember.ATTACK_VISUAL_WATER_GUN));
	deutag.attacks.push_back(PartyMember.PartyMemberAttack.new("Quick Slash", 40, 1.0));
	deutag.attacks.push_back(PartyMember.PartyMemberAttack.new("Crush!", 85, 0.90));
	deutag.abilities.push_back(PartyMember.PartyMemberAbility.new("Heal!", "You could use some patching up anyways...", 95, 1.0, 15, PartyMember.ABILITY_TYPE_HEAL, PartyMember.ATTACK_VISUAL_HEALING));
	deutag.abilities.push_back(PartyMember.PartyMemberAbility.new("Greater Heal!", "You could use some patching up anyways...", 200, 1.0, 55, PartyMember.ABILITY_TYPE_HEAL, PartyMember.ATTACK_VISUAL_HEALING));
	deutag.load_battle_portrait("sekiro_test");
	inventory = [["test_lantern", 1],
				 ["healing_grass", 15],
				 ["healing_pod", 15]];
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
	pass;

func override_physics_process(delta):
	var sprinting = Input.is_action_pressed("game_sprinting_action");
	var movement_result = false;
	if !GameGlobals.paused() && !all_members_dead():
		movement_result = handle_movement(sprinting,
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
				sprinting && movement_result);
	emit_signal("report_party_info_to_ui",
				party_members, gold)
	$Torchlight.energy = (sin(float(OS.get_ticks_msec() / 1000.0) * 5 + 15)+1) * 0.10 + 0.60;

const LevelTransitionClass = preload("res://game/LevelTransition.gd");

# This is a stupid variable to prevent a potentially stupid bug.
# This would be solved by a state machine, but it's too early to marry ourselves
# to that, and it would take more time than doing this.
var just_transitioned_from_other_level = false;


const BATTLE_COOLDOWN_MAX_TIME = 2.0;
var battle_cooldown = BATTLE_COOLDOWN_MAX_TIME;

func _on_InteractableArea_area_entered(area):
	if can_think():
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
