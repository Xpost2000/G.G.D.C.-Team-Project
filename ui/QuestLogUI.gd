extends Control

onready var quest_list = $Background/QuestList;
onready var title_label = $Background/Title;
onready var quest_description_label = $Background/QuestDescriptionBackground/QuestDescription;

var finished_quest = [];
var started_quests = [];

func add_started_quest(quest):
	print("started quest ", quest);
	started_quests.push_back(quest);
	quest_list.add_item(quest.name);

func add_finished_quest(quest):
	print("finished quest ", quest);

	var index_of_removed = started_quests.find(quest);
	quest_list.remove_item(index_of_removed);
	started_quests.remove(index_of_removed);

	finished_quest.push_back(quest);

func set_empty_information():
	quest_description_label.text = "";

func set_currently_active_quest(index):
	var current_quest = started_quests[index];

	quest_description_label.text = current_quest.long_description.strip_edges().strip_escapes();
	print("SET!");

func _ready():
	QuestsGlobal.connect("notify_begin_quest", self, "add_started_quest");
	QuestsGlobal.connect("notify_end_quest", self, "add_finished_quest");
	print("TODO ME");

	quest_list.connect("item_selected", self, "set_currently_active_quest");
	quest_list.connect("item_activated", self, "set_currently_active_quest");
	quest_list.connect("nothing_selected", self, "set_empty_information");

func _process(delta):
	pass;

func on_leave(to):
	GameGlobals.resume();
	hide();

func on_enter(from):
	GameGlobals.pause();
	show();

	quest_list.grab_focus();
	if quest_list.get_item_count():
		quest_list.select(0);
		set_currently_active_quest(0);
	else:
		set_empty_information();

func handle_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_parent().get_parent().toggle_quest_log();
	pass;
