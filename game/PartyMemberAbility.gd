extends Resource
class_name PartyMemberAbility

enum AbilityVisualId {
	  PHYSICAL_BUMP,
	  WATER_GUN,
	  HOLY_FLAME,
	  FLAME,
	  HEALING
	}

enum AbilityType {
	NONE, 
	HEAL, 
	STRENGTH
	}
	
func make(name, description, magnitude, accuracy, cost, type, visual_id=0):
	self.name = name;
	self.description = description;
	self.magnitude = magnitude;
	self.accuracy = accuracy;
	self.cost = cost;
	self.type = type;
	self.visual_id = visual_id;
	return self;

export(String) var name: String;
export(String) var description: String;
export(AbilityType) var type: int;
export(int) var cost: int;
export(int) var magnitude: int;
export(AbilityVisualId) var visual_id: int;
# 0 - 1.0
export(float, 0.0, 1.0) var accuracy: float;

func get_icon_texture():
	return null;
func get_item_list_string():
	return self.name + " :: " + self.description;
