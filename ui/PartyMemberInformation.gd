extends VBoxContainer

onready var party_member_card_prefab = preload("res://ui/PartyMemberCard.tscn");
func remove_all_children():
	for child in get_children():
		remove_child(child);

func update_with_party_information(party_members, amount_of_gold=0):
	remove_all_children();

	for party_member in party_members:
		var new_card = party_member_card_prefab.instance();
		new_card.set_target(party_member);

		add_child(new_card);
