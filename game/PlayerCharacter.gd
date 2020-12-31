#TODO Rename this to Actor or something.
extends KinematicBody2D

# our main issue, is that these guys don't represent one.
# This is a PARTY, not a singular entity. That's the main thing we
# have to figure out.

signal transitioning_to_another_level(player, level_transition);
signal report_sprinting_information(stamina_percent, can_sprint, trying_to_sprint);
# of course I should just be reporting the player in any case...
signal report_inventory_contents(player, player_inventory);
signal report_party_info_to_ui(party_members, amount_of_gold);
signal test_open_conversation;

const SPRINTING_STAMINA_MAX = 75;
const STAMINA_REGENERATION_COOLDOWN_TIME = 1.66; # seconds

var stamina_regeneration_cooldown_timer = 0.0;
var sprinting_stamina = SPRINTING_STAMINA_MAX;

const PartyMember = preload("res://game/PartyMember.gd");

var party_members = [];
var inventory = [];

var gold = 0;

func all_members_dead():
	for party_member in party_members:
		if !party_member.dead():
			return false;
	return true;

func add_party_member_default(name):
	party_members.push_back(PartyMember.new(name, 100, 100));

func add_party_member(party_member):
	party_members.push_back(party_member);

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

func _ready():
	add_party_member_default("Mr. Protagonist");
	add_party_member_default("Mr. Deuteragonist");
	inventory = [["healing_grass", 15],
				 ["healing_pod", 5]];
	pass;

func movement_direction_vector():
	var movement_direction = Vector2.ZERO;

	# consider based off main party member.
	if !party_members[0].dead():
		if Input.is_action_pressed("ui_left"):
			movement_direction.x = -1;
		elif Input.is_action_pressed("ui_right"):
			movement_direction.x = 1;

		if Input.is_action_pressed("ui_up"):
			movement_direction.y = -1;
		elif Input.is_action_pressed("ui_down"):
			movement_direction.y = 1;

	return movement_direction.normalized();

const SPRINTING_SPEED = 512;
const WALKING_SPEED = SPRINTING_SPEED/2;

func can_sprint():
	return (sprinting_stamina > 0.0) && (stamina_regeneration_cooldown_timer <= 0.0);

func get_party_member(index):
	# later I'll do checking.
	return party_members[index];

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

var sprinting = false;

func handle_interact_key(delta):
	emit_signal("test_open_conversation");

func _physics_process(delta):
	if !GameGlobals.paused():
		var movement_direction = movement_direction_vector();
		sprinting = Input.is_action_pressed("game_sprinting_action");
		var velocity = movement_direction * (SPRINTING_SPEED 
		if sprinting && can_sprint() else WALKING_SPEED);

		handle_sprinting(sprinting && (movement_direction.length() != 0), delta);
		velocity = move_and_slide(velocity, Vector2.UP);

		if Input.is_action_just_pressed("game_interact_action"):
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
