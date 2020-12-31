extends KinematicBody2D

const SPRINTING_STAMINA_MAX = 75;
const STAMINA_REGENERATION_COOLDOWN_TIME = 1.66; # seconds

var stamina_regeneration_cooldown_timer = 0.0;
var sprinting_stamina = SPRINTING_STAMINA_MAX;

const PartyMember = preload("res://game/PartyMember.gd");

var SPRINTING_SPEED = 512;
var WALKING_SPEED = SPRINTING_SPEED/2;

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

func handle_movement(sprinting, direction, delta):
	if !GameGlobals.paused():
		var velocity = direction * (SPRINTING_SPEED if sprinting && can_sprint() else WALKING_SPEED);
		handle_sprinting(sprinting && (direction.length() != 0), delta);
		velocity = move_and_slide(velocity, Vector2.UP);

		return velocity;
	else:
		return Vector2(0, 0);
