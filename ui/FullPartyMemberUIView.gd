extends ColorRect

onready var icon_label = $Icon;
onready var name_label = $Name;
onready var level_label = $Level;
onready var max_health_label = $StatContainer/MaxHealth;
onready var max_mana_label = $StatContainer/MaxMana;
onready var max_defense_label = $StatContainer/MaxDefense;
onready var experience_to_next_label = $StatContainer/ExperienceToNext;
onready var stat_container = $StatContainer/StatContainer;

const PartyMemberStatBlock = preload("res://game/PartyMemberStatBlock.gd");
# TODO fill in more
func build_based_on_party_member(member):
	name_label.text = member.name;
	max_health_label.text = "HP: " + str(member.health) + "/" + str(member.max_health);
	max_mana_label.text = "MP: " + str(member.mana_points) + "/" + str(member.max_mana_points);
	max_defense_label.text = "DEF: " + str(member.defense);
	experience_to_next_label.text = "XP: " + str(member.experience) + "/" + str(member.experience_to_next);
	build_stat_container_view(member.level, member.stats);

func build_stat_container_view(level, stats):
	level_label.text = "Level: " + str(level);
	for child in stat_container.get_children():
		stat_container.remove_child(child);

	for label in stats.get_as_labels():
		stat_container.add_child(label);

func _ready():
	var test_stats = PartyMemberStatBlock.new();
	build_stat_container_view(0, test_stats);
	pass
