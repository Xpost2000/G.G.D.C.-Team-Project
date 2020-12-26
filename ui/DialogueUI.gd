extends Control

onready var dialogue_text = $DialogueBackground/DialogueText;
onready var dialogue_speaker_name = $DialogueBackground/SpeakerTextLabelContainer/DialogueText;
onready var dialogue_choices_container = $DialogueBackground/ChoicesContainer;
onready var dialogue_continue_prompt = $DialogueBackground/ContinuePrompt;

var scenes = [];
var current_scene = "start";

func open_test_dialogue():
	print("okay");

func _ready():
	pass;

func _process(delta):
	pass;
