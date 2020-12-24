extends ColorRect

onready var member_portrait = $CardLayout/Portrait;
onready var member_stats_health_label = $CardLayout/MemberInfo/MemberStats/Health;
onready var member_stats_defense_label = $CardLayout/MemberInfo/MemberStats/Defense;
onready var member_stats_experience_label = $CardLayout/MemberInfo/MemberStats/Experience;

var reference_to_party_member = null;

func set_target(thing):
	reference_to_party_member = thing;
	
func _process(_delta):
	member_portrait;
	member_stats_health_label;
	member_stats_defense_label;
	member_stats_experience_label;
