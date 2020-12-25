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

const SPRINTING_STAMINA_MAX = 75;
const STAMINA_REGENERATION_COOLDOWN_TIME = 1.66; # seconds

var stamina_regeneration_cooldown_timer = 0.0;

class PartyMemberStatBlock:
	func _init():
		self.dexterity = 10;
		self.constitution = 10;
		self.willpower = 10;
		self.intelligence = 10;
		self.charisma = 10;
		self.luck = 10;

	var strength: int;
	var dexterity: int;
	var constitution: int;
	var willpower: int;
	var intelligence: int;
	var charisma: int;
	var luck: int;

class PartyMember:
	func _init(name, health, defense):
		self.name = name;
		self.health = health;
		self.max_health = health;
		self.defense = defense;

		self.level = 1;
		self.experience = 0;
		self.experience_to_next = 150;

		self.party_icon = load("res://images/party-icons/unknown_character_icon.png");
		self.stats = PartyMemberStatBlock.new();

	var party_icon: Texture;

	var name: String;
	var health: int;
	var max_health: int;

	var defense: int;

	var level: int;
	var experience: int;
	var experience_to_next: int;

	var stats: PartyMemberStatBlock;

var sprinting_stamina = SPRINTING_STAMINA_MAX;

var party_members = [];
var inventory = [];

var gold = 0;

func add_party_member_default(name):
	party_members.push_back(PartyMember.new(name, 100, 100));

func add_party_member(party_member):
	pass;

func _ready():
	add_party_member_default("Mr. Protagonist");
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

var self_paused = false;
var sprinting = false;

func _physics_process(delta):
	if !self_paused:
		var movement_direction = movement_direction_vector();
		sprinting = Input.is_action_pressed("game_sprinting_action");
		var velocity = movement_direction * (SPRINTING_SPEED 
		if sprinting && can_sprint() else WALKING_SPEED);

		handle_sprinting(sprinting, delta);
		velocity = move_and_slide(velocity, Vector2.UP);
		
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

func _on_UILayer_set_game_action_pause_state(value):
	self_paused = value;
