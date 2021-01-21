extends Control

const FullPartyMemberUIView = preload("res://ui/FullPartyMemberStatInfo.tscn");

func _ready():
	$VBoxContainer/Resume.connect("pressed", self, "_on_Resume_pressed");
	$VBoxContainer/ReturnToTitle.connect("pressed", self, "_on_ReturnToTitle_pressed");
	$VBoxContainer/Quests.connect("pressed", self, "_on_Quests_pressed");
	$VBoxContainer/Quit.connect("pressed", self, "_on_Quit_pressed");
	$VBoxContainer/Inventory.connect("pressed", self, "_on_Inventory_pressed");

func _on_Inventory_pressed():
	get_parent().get_parent().set_state(get_parent().get_parent().UI_STATE_INVENTORY);

func _on_Resume_pressed():
	get_parent().get_parent().set_state(get_parent().get_parent().UI_STATE_GAME);

func _on_ReturnToTitle_pressed():
	GameGlobals.switch_to_scene(1);

func _on_Quests_pressed():
	get_parent().get_parent().set_state(get_parent().get_parent().UI_STATE_QUEST_LOG);

func _on_Quit_pressed():
	get_tree().quit();

var last_focused_widget = null;
func on_leave(to):
	last_focused_widget = $VBoxContainer.get_focus_owner();

	GameGlobals.resume();
	hide();
	print("un_pause");

func on_enter(from):
	GameGlobals.pause();
	show();
	print("pause");

	if from == get_parent().get_parent().UI_STATE_GAME:
		$VBoxContainer/Resume.grab_focus();
	else:
		if last_focused_widget:
			last_focused_widget.grab_focus();


	var player = get_parent().get_parent().player_reference;

	for child in $HBoxContainer.get_children():
		$HBoxContainer.remove_child(child);

	for party_member in player.party_members:
		var new_card = FullPartyMemberUIView.instance();
		$HBoxContainer.add_child(new_card);

	# I'm going to be honest I have no reason to believe why I need to do this after...
	var children = $HBoxContainer.get_children();
	for child_index in len(children):
		children[child_index].build_based_on_party_member(player.get_party_member(child_index));


func handle_process(delta):
	if Input.is_action_just_pressed("game_action_ui_pause") or Input.is_action_just_pressed("ui_cancel"):
		get_parent().get_parent().toggle_pause();
