tool

extends Resource
class_name PartyMemberAttack
enum AttackVisualId {
	  PHYSICAL_BUMP,
	  PROJECTILE
	}

# not necessarily ATTACKS, just for now.
func make(name, magnitude, accuracy, cost=0, visual_id=AttackVisualId.PHYSICAL_BUMP):
	self.name = name;
	self.magnitude = magnitude;
	self.accuracy = accuracy;
	self.visual_id = visual_id;
	self.cost = cost;
	return self;

# I hope this actually works since it would be convenient to not set it yourself.
func set_projectile_scene(scene):
	if scene:
		self.visual_id = AttackVisualId.PROJECTILE;
		projectile = scene;
	else:
		self.visual_id = AttackVisualId.PHYSICAL_BUMP;
		projectile = null;

export(PackedScene) var projectile: PackedScene = null setget set_projectile_scene;
export(PackedScene) var projectile_impact: PackedScene = null;

export(String) var name: String;
export(AttackVisualId) var visual_id: int;
export(int) var type: int;
export(int) var magnitude: int;
# 0 - 1.0
export(float, 0.0, 1.0) var accuracy: float;
export(int) var cost: int;

func get_icon_texture():
	return null;
func get_item_list_string():
	return self.name;
