const PartyMember = preload("res://game/PartyMember.gd");

enum {BATTLE_TURN_ACTION_SKIP_TURN,
	  BATTLE_TURN_ACTION_USE_ITEM,
	  BATTLE_TURN_ACTION_DO_ATTACK,
	  BATTLE_TURN_ACTION_DO_ABILITY,
	  BATTLE_TURN_ACTION_FLEE}

func _init(type, actor_self):
	self.actor_self = actor_self;
	self.type = type;
	self.actor_target = null;
	self.index = 0;

var type: int;
var index: int;
var actor_self: PartyMember;
var actor_target: PartyMember;
var marked_done = false;

# We'd really just be checking if an animation
# or special effect finished or something.
func done():
	match type:
		BATTLE_TURN_ACTION_SKIP_TURN: return true;
		BATTLE_TURN_ACTION_USE_ITEM: pass;
		BATTLE_TURN_ACTION_DO_ATTACK: return marked_done; 
		BATTLE_TURN_ACTION_DO_ABILITY: pass;
		BATTLE_TURN_ACTION_FLEE: pass;
	return true;
