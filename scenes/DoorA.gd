# Doors should be animated sprites...
extends Sprite

# I have no idea on why setting a variable needs to be deferred.
func open_door():
	print("change image or play some animation");
	$Collider/Shape.set_deferred("disabled", true);
	$InteractRegion/Shape.set_deferred("disabled", true);

func close_door():
	print("change image or play some animation");
	$Collider/Shape.set_deferred("disabled", false);
	$InteractRegion/Shape.set_deferred("disabled", false);

const GameActor = preload("res://game/actors/GameActor.gd");
const PlayerCharacter = preload("res://game/actors/PlayerCharacter.gd");
func _on_InteractRegion_area_entered(area):
	if area.name == "InteractableArea":
		var parent = area.get_parent();
		if parent is GameActor:
			open_door();
			print("open sesame, no keys yet!", $Collider/Shape.disabled, $InteractRegion/Shape.disabled);

func _ready():
	pass

