extends HBoxContainer
signal notify_finished;

onready var before_card = $Before;
onready var after_card = $After;

var list_of_members = [];

func _ready():
	pass

var current_party_member_index = -1;
func open_with(party_members):
	list_of_members = party_members;
	current_party_member_index = -1;
	show_next_party_member();

func show_next_party_member():
	current_party_member_index += 1;
	if current_party_member_index < len(list_of_members):
		var info = list_of_members[current_party_member_index];

		before_card.build_based_on_party_member(info[0]);
		before_card.build_stat_container_view(info[1][0], info[1][1]);
		after_card.build_based_on_party_member(info[0]);
		return true;
	else:
		return false;
	

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if !show_next_party_member():
			emit_signal("notify_finished");
