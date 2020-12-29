extends Node2D

onready var battle_layer = $BattleLayer;
onready var battle_ui_layer = $BattleUILayer;

func _ready():
	pass

# TODO, scuffy
var on_opponent = false;
func _on_Area2D_input_event(viewport, event, shape_index):
	if on_opponent:
		if event is InputEventMouseButton:
			print("open menu! Or close");

func _on_Area2D_mouse_entered():
	print("touchy!");
	on_opponent = true;
