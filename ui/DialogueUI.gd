extends Control

onready var dialogue_speaker_portrait = $DialogueCharacterPortrait;
onready var dialogue_text = $DialogueBackground/DialogueText;
onready var dialogue_speaker_name = $DialogueBackground/SpeakerTextLabelContainer/DialogueText;
onready var dialogue_choices_container = $DialogueBackground/ChoicesContainer;
onready var dialogue_continue_prompt = $DialogueBackground/ContinuePrompt;

var scenes = [];
var current_scene = "start";

enum {DIALOGUE_SPEAKER_NODE_IN_LEVEL,
	  DIALOGUE_SPEAKER_MANUAL_SPECIFIED}
class DialogueSpeaker:
	var type: int;
	var node_name: String;

	var name: String;
	# This path is relative to
	# res://images/portraits/*
	var speaker_portrait_path: String;

	func node_speaker(node_name):
		var new_dialogue_speaker = DialogueSpeaker.new();
		new_dialogue_speaker.type = DIALOGUE_SPEAKER_NODE_IN_LEVEL;
		new_dialogue_speaker.node_name = node_name;
		return new_dialogue_speaker;

	func node_manual(name, speaker_portrait_path):
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
	func scene_linear(speaker, text, next):
		var new_dialogue_scene = DialogueScene.new();
		new_dialogue_scene.speaker = speaker;
		new_dialogue_scene.text = text;
		new_dialogue_scene.next_for_continue = next;
		new_dialogue_scene.choices = null;
		new_dialogue_scene.mood = null;
		return new_dialogue_scene;

	func scene_branching(speaker, text, choices):
		var new_dialogue_scene = DialogueScene.new();
		new_dialogue_scene.speaker = speaker;
		new_dialogue_scene.text = text;
		new_dialogue_scene.next_for_continue = null;
		new_dialogue_scene.mood = null;
		new_dialogue_scene.choices = choices;
		return new_dialogue_scene;

	var speaker: DialogueSpeaker;
	var text: String;

	# Should always be lowercase. Preferably not a string...
	# but whatever.
	# When this is null, just use the "neutral" mood.
	var mood: String;
	
	var next_for_continue: String;
	var choices: Array;

func open_test_dialogue():
	print("okay");

func _ready():
	pass;

func _process(delta):
	pass;
