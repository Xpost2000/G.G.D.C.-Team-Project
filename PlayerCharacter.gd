extends KinematicBody2D

var health = 100;

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
	
func _physics_process(delta):
	var movement_direction = movement_direction_vector();
	var velocity = movement_direction * WALKING_SPEED;
	
	velocity = move_and_slide(velocity, Vector2.UP);
