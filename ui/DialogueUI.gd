extends Control

# action signals
signal add_item(data);
signal hi_bro(data);
signal start_quest(data);
# end of action signals

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
		self.action_responses = [];

	func add_response(name, data):
		action_responses.push_back([name, data]);

	var text: String;
	var next: String;
	# TODO actions!
	var action_responses: Array;

class DialogueScene:
	var speaker: DialogueSpeaker;
	var text: String;

	# Should always be lowercase. Preferably not a string...
	# but whatever.
	# When this is null, just use the "neutral" mood.
	var mood: String;
	var voice_clip: String;
	
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

func parse_scene_speaker(speaker_data):
	if speaker_data["type"] == "NodeSpeaker":
		return make_node_speaker(speaker_data["speaker"]);
	else:
		return make_manual_speaker(speaker_data["speaker"], speaker_data["portrait"]);

func parse_scene_choices(choices_data):
	if choices_data:
		var new_choices = [];

		for choice in choices_data:
			var choice_text = choice["text"];
			var choice_next_branch = Utilities.dictionary_get_optional(choice, "next", "");

			var new_choice = DialogueChoice.new(choice_text, choice_next_branch);
			new_choice.action_responses = Utilities.dictionary_get_optional(choice, "actions", []);
			new_choices.push_back(new_choice);

		return new_choices;
	else:
		return null;

func load_dialogue_from_file(file_name):
	# always assume in dialogue_files/
	var json_results = Utilities.read_json_no_check("dialogue_files/" + file_name);

	var new_scenes = {};
	for scene in json_results:
		var current_scene_dictionary = json_results[scene];

		var scene_speaker = parse_scene_speaker(current_scene_dictionary["speaker"]);
		var scene_text = current_scene_dictionary["text"];

		var scene_next = Utilities.dictionary_get_optional(current_scene_dictionary, "next");
		var scene_choices = parse_scene_choices(Utilities.dictionary_get_optional(current_scene_dictionary, "choices"));

		var new_scene_to_push = null;

		if scene_choices:
			new_scene_to_push = make_scene_branching(scene_speaker, scene_text, scene_choices);
		else:
			new_scene_to_push = make_scene_linear(scene_speaker, scene_text, scene_next);

		new_scene_to_push.voice_clip = Utilities.dictionary_get_optional(current_scene_dictionary, "voice", "");
		new_scenes[scene] = new_scene_to_push;
	return new_scenes;	

func open_dialogue(path):
	scenes = load_dialogue_from_file(path);

	goto_scene("start");
	initial_opening = true;

	AudioGlobal.play_music("copyrighted-test-content/snd/bg2tobeas.ogg");

func open_test_dialogue():
	open_dialogue("testerbester.json")

func _ready():
	hide();

func _handle_selecting_dialogue_choice(choice):
	for responses in choice.action_responses:
		print("firing " + responses[0]);
		emit_signal(responses[0], responses[1]);
	goto_scene(choice.next);

func setup_focus():
	if len(dialogue_choices_container.get_children()):
		# dirty little thing to deal with popups stealing all the focus.
		var any_already_selected = false;
		for child in dialogue_choices_container.get_children():
			if child.has_focus():
				any_already_selected = true;
				break;
		if !any_already_selected:
			dialogue_choices_container.get_children()[0].call_deferred("grab_focus");
			print("grab focus for choice!");
	else:
		dialogue_continue_prompt.grab_focus();

func goto_scene(scene):
	current_scene = scene;
	if !current_scene.empty():
		if current_scene in scenes:
			var current_scene_object = scenes[current_scene];
			dialogue_text.text = current_scene_object.text;

			if !current_scene_object.voice_clip.empty():
				AudioGlobal.play_sound(current_scene_object.voice_clip, AudioGlobal.DEFAULT_MAX_VOLUME_DB, 0);

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
					choice_button.connect("pressed", self, "_handle_selecting_dialogue_choice", [dialogue_choice]);
					dialogue_choices_container.add_child(choice_button);
			else:
				dialogue_choices_container.hide();
				dialogue_continue_prompt.show();
			# setup_focus();
	else:
		emit_signal("notify_dialogue_terminated", dialogue_terminate_normal());
		AudioGlobal.stop_sound(0);

func on_leave(to):
	GameGlobals.resume();
	hide();

func on_enter(from):
	GameGlobals.pause();
	show();
	setup_focus();

func continue_to_next_scene():
	if is_linear() and current_scene in scenes:
		var current_scene_object = scenes[current_scene];
		goto_scene(current_scene_object.next_for_continue);

func handle_process(delta):
	if !initial_opening:
		setup_focus();
		if Input.is_action_just_pressed("game_interact_action"):
			continue_to_next_scene();
	else:
		initial_opening = false;
