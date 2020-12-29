extends ColorRect

onready var member_portrait = $CardLayout/Portrait;
onready var member_name = $CardLayout/MemberInfo/MemberName;
onready var member_stats_health_label = $CardLayout/MemberInfo/MemberStats/Health;
onready var member_stats_mana_label = $CardLayout/MemberInfo/MemberStats/Mana;
onready var member_stats_defense_label = $CardLayout/MemberInfo/MemberStats/Defense;
onready var member_stats_experience_label = $CardLayout/MemberInfo/MemberStats/Experience;

var reference_to_party_member = null;

func set_target(thing):
	reference_to_party_member = thing;
	
func _process(_delta):
	if reference_to_party_member:
		member_name.text = reference_to_party_member.name + " (LVL " + str(reference_to_party_member.level) + ")";
		member_portrait.texture = reference_to_party_member.party_icon;
		member_stats_health_label.text = "HEALTH: " + str(reference_to_party_member.health) + "/" + str(reference_to_party_member.max_health);
		member_stats_mana_label.text = "MANA: " + str(reference_to_party_member.mana_points) + "/" + str(reference_to_party_member.max_mana_points);
		member_stats_defense_label.text = "DEFENSE: " + str(reference_to_party_member.defense);
		member_stats_experience_label.text = "XP: " + str(reference_to_party_member.experience) + "/" + str(reference_to_party_member.experience_to_next);
