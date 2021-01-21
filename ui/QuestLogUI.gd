extends Control

var finished_quest = [];
func add_finished_quest(quest):
	print("finished quest ", quest);
	finished_quest.push_back(quest);

func _ready():
	# QuestsGlobal.connect("notify_begin_quest", self, "");
	QuestsGlobal.connect("notify_end_quest", self, "add_finished_quest");
	print("TODO ME");
	pass;

func _process(delta):
	pass;

func on_leave(to):
	GameGlobals.resume();
	hide();

func on_enter(from):
	GameGlobals.pause();
	show();

func handle_process(delta):
	pass;
