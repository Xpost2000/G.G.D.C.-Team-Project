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
func build_based_on_player(player):
	print("TODO");
	pass;
func build_stat_container_view(stats):
	for child in stat_container.get_children():
		stat_container.remove_child(child);

	for label in stats.get_as_labels():
		stat_container.add_child(label);

func _ready():
	var test_stats = PartyMemberStatBlock.new();
	build_stat_container_view(test_stats);
	pass
