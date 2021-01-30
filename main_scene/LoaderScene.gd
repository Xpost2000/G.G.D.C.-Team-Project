extends Node2D

var show_disclaimer_timer = 0;

onready var disclaimer_label = $Disclaimer;
const TIME_UNTIL_NEXT_CHARACTER = 0.075;
onready var total_time_to_elapse = len(disclaimer_label.text) * TIME_UNTIL_NEXT_CHARACTER;

func _ready():
	disclaimer_label.visible_characters = 0;

func _process(delta):
	if show_disclaimer_timer >= TIME_UNTIL_NEXT_CHARACTER:
		disclaimer_label.visible_characters += 1;
		show_disclaimer_timer = 0;
	else:
		show_disclaimer_timer += delta;

	if disclaimer_label.visible_characters == len(disclaimer_label.text):
		GameGlobals.switch_to_scene(1);
