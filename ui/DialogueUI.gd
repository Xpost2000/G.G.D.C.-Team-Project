extends Control

onready var dialogue_speaker_portrait = $DialogueCharacterPortrait;
onready var dialogue_text = $DialogueBackground/DialogueText;
onready var dialogue_speaker_name = $DialogueBackground/SpeakerTextLabelContainer/DialogueText;
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

func make_scene_linear(speaker, text, next):
	var new_dialogue_scene = DialogueScene.new();
	new_dialogue_scene.speaker = speaker;
	new_dialogue_scene.text = text;
	new_dialogue_scene.next_for_continue = next if next else "";
	new_dialogue_scene.choices = [];
	new_dialogue_scene.mood = "";
	return new_dialogue_scene;

func make_scene_branching(speaker, text, choices):
	var new_dialogue_scene = DialogueScene.new();
	new_dialogue_scene.speaker = speaker;
	new_dialogue_scene.text = text;
	new_dialogue_scene.next_for_continue = "";
	new_dialogue_scene.mood = "";
	new_dialogue_scene.choices = choices if choices else [];
	return new_dialogue_scene;


func open_test_dialogue():
	print("okay");
	scenes["start"] = make_scene_linear(make_node_speaker("PlayerCharacter"),
										"Tester besting dialogue",
										"next");
	scenes["next"] = make_scene_branching(make_node_speaker("PlayerCharacter"),
												   "This one has choices",
												   [DialogueChoice.new("Yep, for reals!", "meaningless"),
													DialogueChoice.new("Yay", "meaningless"),
													DialogueChoice.new("AISODOISADIOSADIOASD", "meaningless")]);
	scenes["meaningless"] = make_scene_linear(make_node_speaker("PlayerCharacter"),
											  "In the end... It was meaningless. Free will is an illusion.",
											  null);
	goto_scene("start");

func _ready():
	pass;

func goto_scene(scene):
	current_scene = scene;
	var current_scene_object = scenes[current_scene];
	if current_scene_object:
		dialogue_text.text = current_scene_object.text;

		match current_scene_object.speaker.type:
			DIALOGUE_SPEAKER_NODE_IN_LEVEL: pass; #TODO
			DIALOGUE_SPEAKER_MANUAL_SPECIFIED: pass; #TODO

		if current_scene_object.choices && len(current_scene_object.choices) > 0:
			dialogue_continue_prompt.hide();
			dialogue_choices_container.show();

			for dialogue_choice_container_child in dialogue_choices_container.get_children():
				dialogue_choices_container.remove_child(dialogue_choice_container_child);
			# add choices
		else:
			dialogue_choices_container.hide();
			dialogue_continue_prompt.show();

func _process(delta):
	pass;
