extends Control

var reference_to_game_scene = null;

enum {DIALOGUE_TERMINATION_REASON_DEFAULT}
class DialogueTerminationReason:
	var type: int;

func dialogue_terminate_normal():
	var termination_reason = DialogueTerminationReason.new();
	termination_reason.type = DIALOGUE_TERMINATION_REASON_DEFAULT;
	return termination_reason;

signal notify_dialogue_terminated(reason_of_termination);

onready var dialogue_speaker_portrait = $DialogueCharacterPortrait;
onready var dialogue_text = $DialogueBackground/DialogueText;
onready var dialogue_speaker_name = $DialogueBackground/SpeakerTextLabelContainer/SpeakerName;
onready var dialogue_choices_container = $DialogueBackground/ChoicesContainer;
onready var dialogue_continue_prompt = $DialogueBackground/ContinuePrompt;

var scenes = {};
var current_scene = "start";

enum {DIALOGUE_SPEAKER_NODE_IN_LEVEL,
	  DIALOGUE_SPEAKER_MANUAL_SPECIFIED}
class DialogueSpeaker:
	var type: int;
	var node_name: String; # The main complexity is that the "node" is actually a party of things...

	var name: String;
	# This path is relative to
	# res://images/portraits/*
	var speaker_portrait_path: String;

func make_node_speaker(node_name):
	var new_dialogue_speaker = DialogueSpeaker.new();
	new_dialogue_speaker.type = DIALOGUE_SPEAKER_NODE_IN_LEVEL;
	new_dialogue_speaker.node_name = node_name;
	return new_dialogue_speaker;

func make_manual_speaker(name, speaker_portrait_path):
	var new_dialogue_speaker = DialogueSpeaker.new();
	new_dialogue_speaker.type = DIALOGUE_SPEAKER_MANUAL_SPECIFIED;
	new_dialogue_speaker.name = name;
	new_dialogue_speaker.speaker_portrait_path = speaker_portrait_path;
	return new_dialogue_speaker;

class DialogueChoice:
	func _init(text, next):
		self.text = text;
		self.next = next;

	var text: String;
	var next: String;
	# TODO actions!

class DialogueScene:
	var speaker: DialogueSpeaker;
	var text: String;

	# Should always be lowercase. Preferably not a string...
	# but whatever.
	# When this is null, just use the "neutral" mood.
	var mood: String;
	
	var next_for_continue: String;
	var choices: Array;

func make_scene_linear(speaker, text, next, mood=""):
	var new_dialogue_scene = DialogueScene.new();
	new_dialogue_scene.speaker = speaker;
	new_dialogue_scene.text = text;
	new_dialogue_scene.next_for_continue = next if next else "";
	new_dialogue_scene.choices = [];
	new_dialogue_scene.mood = mood;
	return new_dialogue_scene;

func make_scene_branching(speaker, text, choices, mood=""):
	var new_dialogue_scene = DialogueScene.new();
	new_dialogue_scene.speaker = speaker;
	new_dialogue_scene.text = text;
	new_dialogue_scene.next_for_continue = "";
	new_dialogue_scene.mood = mood;
	new_dialogue_scene.choices = choices if choices else [];
	return new_dialogue_scene;

func is_linear():
	var current_scene_object = scenes[current_scene];
	return len(current_scene_object.choices) == 0;

# I don't really like having these "safety hatch" variables
# but they don't really hurt to add, and it's a fast fix.
var initial_opening = false;

# always assume in dialogue_files/
func load_dialogue_from_file(filename):
	var file_contents = Utilities.read_entire_file_as_string("dialogue_files/" + file_name);
	print("TODO TODO TODO");
	.error_out_please();

func open_test_dialogue():
	print("okay");
	scenes["start"] = make_scene_linear(make_node_speaker("PlayerCharacter"),
										"This is a linear scene. This is referring to the fact we only go one direction... As in continue...",
										"next");
	scenes["next"] = make_scene_branching(make_node_speaker("PlayerCharacter"),
												   "This one has choices",
												   [DialogueChoice.new("Yep, for reals!", "meaningless"),
													DialogueChoice.new("Yay", "meaningless"),
													DialogueChoice.new("AISODOISADIOSADIOASD", "meaningless")]);
	scenes["meaningless"] = make_scene_linear(make_node_speaker("PlayerCharacter"),
											  "In the end... It was meaningless. Free will is an illusion.",
											  "differ");

	scenes["differ"] = make_scene_linear(make_manual_speaker("???", "testerbester"),
										 "Really? I don't quite think so.",
										 "optimistic",
										 "happy");

	scenes["optimistic"] = make_scene_linear(make_manual_speaker("???", "testerbester"),
										 "You have to be more optimistic sometimes.",
										 "sorry");

	scenes["sorry"] = make_scene_linear(make_node_speaker("PlayerCharacter"),
										"Dude just shut up. Let me act emo and edgy.",
										"dick");

	scenes["dick"] = make_scene_linear(make_manual_speaker("???", "testerbester"),
									   "You don't have to be such a dick about it.",
									   null, "angry");
	goto_scene("start");
	initial_opening = true;

func _ready():
	hide();

func goto_scene(scene):
	current_scene = scene;
	if !current_scene.empty():
		if current_scene in scenes:
			var current_scene_object = scenes[current_scene];
			dialogue_text.text = current_scene_object.text;

			var mood = current_scene_object.mood if !current_scene_object.mood.empty() else "neutral";

			match current_scene_object.speaker.type:
				DIALOGUE_SPEAKER_NODE_IN_LEVEL:
					var node_in_question = reference_to_game_scene.find_node(current_scene_object.speaker.node_name)
					if node_in_question:
						# assume is player and look for party name.
						# for more final reasons, I'd subclass the node and
						# check those nodes manually, so I can do dispatch
						# based on type to find the best name
						dialogue_speaker_name.text = node_in_question.get_party_member(0).name;
						var requested_texture = load("res://images/portraits/protagonist/" + mood + ".png");
						if requested_texture:
							dialogue_speaker_portrait.texture = requested_texture;
						else:
							dialogue_speaker_portrait.texture = load("res://images/portraits/protagonist/neutral.png");
					else:
						dialogue_speaker_name.text = "???";
					pass;
				DIALOGUE_SPEAKER_MANUAL_SPECIFIED:
					dialogue_speaker_name.text = current_scene_object.speaker.name;
					var requested_texture = load("res://images/portraits/" + current_scene_object.speaker.speaker_portrait_path + "/" + mood + ".png");
					if requested_texture:
						dialogue_speaker_portrait.texture = requested_texture;
					else:
						dialogue_speaker_portrait.texture = ("res://images/portraits/" + current_scene_object.speaker.speaker_portrait_path + "/neutral.png");
					pass;

			if current_scene_object.choices && len(current_scene_object.choices) > 0:
				dialogue_continue_prompt.hide();
				dialogue_choices_container.show();

				for dialogue_choice_container_child in dialogue_choices_container.get_children():
					dialogue_choices_container.remove_child(dialogue_choice_container_child);
				# add choices
				for dialogue_choice in current_scene_object.choices:
					var choice_button = Button.new();
					choice_button.text = dialogue_choice.text;
					choice_button.connect("pressed", self, "goto_scene", [dialogue_choice.next]);
					dialogue_choices_container.add_child(choice_button);
			else:
				dialogue_choices_container.hide();
				dialogue_continue_prompt.show();
	else:
		emit_signal("notify_dialogue_terminated", dialogue_terminate_normal());

func _process(delta):
	if !initial_opening:
		if current_scene in scenes:
			var current_scene_object = scenes[current_scene];
			if is_linear() && Input.is_action_just_pressed("game_interact_action"):
				goto_scene(current_scene_object.next_for_continue);
	else:
		initial_opening = false;
