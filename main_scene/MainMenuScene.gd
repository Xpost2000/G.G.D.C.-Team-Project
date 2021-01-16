extends Node2D

const SAVE_PATH = "saves/";

onready var notifier_background = $NotifierBackground;
onready var save_games_widget = $SaveGamesWidget;
onready var notifier_content = $NotifierBackground/Content;
onready var notifier_title = $NotifierBackground/Title;

func _ready():
	pass;

var thing = "copyrighted-test-content/snd/012.ogg";

func _process(delta):
	AudioGlobal.looped_play_music(thing);

# maybe do a fancy fade out.

enum{ MAIN_GAME_SCENE,
	  MAIN_MENU_SCENE,
	  BATTLE_SCENE,
	  GAME_SCENE_TYPE_COUNT}

func start_game():
	GameGlobals.resume();
	GameGlobals.reload_scene(MAIN_GAME_SCENE);
	GameGlobals.reload_scene(BATTLE_SCENE);
	GameGlobals.switch_to_scene(0);
	AudioGlobal.pause_music();

func _on_StartGameButton_pressed():
	start_game();

func _on_LoadGameButton_pressed():
	# AudioGlobal.play_sound("copyrighted-test-content/snd/see.ogg");
	thing = "copyrighted-test-content/snd/013.ogg";
	print("load game?");
	open_save_games_widget(SAVE_PATH);

func _on_OptionsButton_pressed():
	thing = "copyrighted-test-content/snd/012.ogg";
	# AudioGlobal.play_sound("copyrighted-test-content/snd/almalexia.ogg");
	print("options?");
	open_notification("Options Are Not Done!",
					  """
					  This is probably out of scope outside of maybe
					  sound settings.... Who knows?
					  """);

func _on_AboutGameButton_pressed():
	thing = "copyrighted-test-content/snd/012.ogg";
	print("team credits!");
	open_notification("Game Credits",
					  """
					  This game by these people with their best attempt.
					  @xpost2000, @Swaw - Gameplay Programmers
					  
					  @Adrianna, @B̸̨͋Ĩ̴͘R̶̈́̕D̸̯̂L̵̂̚Ö̵́̇R̷̐̔Ď̸̕, 
					  @hunk, @missy, @amie - Artist

					  @everyone - Writing and Design
					  """);

func _on_QuitGame_pressed():
	get_tree().quit();

# both buttons are hooked to this signal... There's no reason
# to really separate it...
func _on_NotifierBackground_Close_pressed():
	notifier_background.hide();
	save_games_widget.hide();

func open_notification(title, text):
	notifier_background.show();
	save_games_widget.hide();
	notifier_title.text = title;
	notifier_content.text = text;

func valid_save_file_names(path):
	var result = [];
	var potential_save_files = Utilities.get_file_names_of_directory(path); 
	for save_file in potential_save_files:
		if ".game_save" in save_file:
			result.push_back(save_file);
	return result;
	

func _on_VBoxContainer_item_activated(index):
	var save_files = valid_save_file_names(SAVE_PATH);
	print(save_files[index]);
	start_game();
	GameGlobals.get_scene(GameGlobals.MAIN_GAME_SCENE).load_from_dictionary(Utilities.read_json_no_check("saves/" + save_files[index]));
	pass;

func open_save_games_widget(save_path):
	notifier_background.hide();
	save_games_widget.show();

	var potential_save_files = valid_save_file_names(save_path);
	var vbox_container = save_games_widget.get_node("VBoxContainer");

	vbox_container.clear();

	for save_file in potential_save_files:
		if ".game_save" in save_file:
			vbox_container.add_item(save_file, null);
