extends CanvasLayer

onready var stamina_bar = $SprintingStaminaBar;
onready var stamina_bar_max_dimensions = $SprintingStaminaBar.rect_size;

func _process(_delta):
	pass;

func _on_PlayerCharacter_report_sprinting_information(stamina_percent, can_sprint, _trying_to_sprint):
	if can_sprint:
		stamina_bar.color = Color.green;
	else:
		stamina_bar.color = Color.yellow;
		
	stamina_bar.set_size(Vector2(stamina_percent * stamina_bar_max_dimensions.x, 
								 stamina_bar_max_dimensions.y))
