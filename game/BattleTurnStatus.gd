const BattleTurnAction = preload("res://game/BattleTurnAction.gd");

var decided_action: BattleTurnAction;
var active_actor_index: int;
# This doesn't care about sides... Just give it in the order of initiative.
var participants: Array;

func _init():
	self.active_actor_index = 0;
	self.participants = [];
	self.decided_action = null;

func advance_actor():
	active_actor_index += 1;
	active_actor_index %= len(participants);

	while active_actor().dead():
		active_actor_index += 1;
		active_actor_index %= len(participants);

	decided_action = null;

func active_actor():
	return participants[active_actor_index];
