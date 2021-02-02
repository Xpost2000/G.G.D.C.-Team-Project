extends Resource
class_name PartyMemberAttack

# not necessarily ATTACKS, just for now.
enum AttackVisualId {
	  PHYSICAL_BUMP,
	  WATER_GUN,
	  HOLY_FLAME,
	  FLAME,
	  HEALING
	}
	
func make(name, magnitude, accuracy, cost=0, visual_id=AttackVisualId.PHYSICAL_BUMP):
	self.name = name;
	self.magnitude = magnitude;
	self.accuracy = accuracy;
	self.visual_id = visual_id;
	self.cost = cost;

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
