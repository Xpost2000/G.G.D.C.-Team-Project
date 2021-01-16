extends Node;
signal notify_begin_quest(quest_info);
signal notify_end_quest(quest_info);

# Basically I'm wishing Quests were closures.
class Quest:
	const GameActor = preload("res://game/actors/GameActor.gd");
	func __initialize__(name, description):
		self.name = name;
		self.description = description;
		self.finished = false;
		self.quester = null
		
	var name: String;
	var description: String;

	var finished: bool;
	var quester: GameActor;

	func handle_reward():
		pass;

	func considered_completed():
		return true;

class TestDieQuest extends Quest:
	var player: GameActor;

	func _init(player):
		__initialize__("Die For Me!", "Mind trying out some death for me? K THX BYE!");
		self.quester = player;

	func considered_completed():
		return self.quester.all_members_dead();

	func handle_reward():
		print("REWARD FOR DEATH!@");

class OpenInventoryQuest extends Quest:
	var player: GameActor;
	var notified: bool;

	func _notified_set():
		self.notified = true;

	func _init(player):
		__initialize__("TUTORIAL: Open your inventory!", "You can do this by pressing the I key!");
		self.quester = player;
		self.quester.connect("opened_inventory", self, "_notified_set");

	func considered_completed():
		return self.notified;

	func handle_reward():
		print("REWARD FOR DEATH!@");

var active_quests = [];

func _ready():
	pass;

func begin_quest(quest):
	print("start quest!");
	emit_signal("notify_begin_quest", quest);
	active_quests.push_back(quest);

func end_quest(quest_index):
	print("end_quest");
	emit_signal("notify_end_quest", active_quests[quest_index]);
	active_quests[quest_index].finished = true;

func _process(delta):
	for quest in active_quests:
		if quest.finished:
			active_quests.erase(quest);

	for quest_index in len(active_quests):
		if active_quests[quest_index].considered_completed():
			end_quest(quest_index);
