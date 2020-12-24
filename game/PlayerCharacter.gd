extends KinematicBody2D

signal report_sprinting_information(stamina_percent, can_sprint, trying_to_sprint);

const SPRINTING_STAMINA_MAX = 75;
const STAMINA_REGENERATION_COOLDOWN_TIME = 1.66; # seconds

var stamina_regeneration_cooldown_timer = 0.0;

var health = 100;
var sprinting_stamina = SPRINTING_STAMINA_MAX;

var strength = 10;
var dexterity = 10;
var constitution = 10;
var willpower = 10;
var intelligence = 10;
var charisma = 10;
var luck = -10;

func _ready():
	pass

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

func _physics_process(delta):
	var movement_direction = movement_direction_vector();
	var sprinting = Input.is_action_pressed("game_sprinting_action");
	var velocity = movement_direction * (SPRINTING_SPEED 
	if sprinting && can_sprint() else WALKING_SPEED);
	
	if sprinting && can_sprint():
		sprinting_stamina -= delta * 55.0;
		if sprinting_stamina <= 0:
			stamina_regeneration_cooldown_timer = STAMINA_REGENERATION_COOLDOWN_TIME;
	else:
		sprinting_stamina += delta * 25;

	if stamina_regeneration_cooldown_timer > 0:
		stamina_regeneration_cooldown_timer -= delta;
	
	sprinting_stamina = clamp(sprinting_stamina, 0, SPRINTING_STAMINA_MAX);
	velocity = move_and_slide(velocity, Vector2.UP);
	
	emit_signal("report_sprinting_information", 
				float(sprinting_stamina)/float(SPRINTING_STAMINA_MAX),
				can_sprint(), 
				sprinting);
