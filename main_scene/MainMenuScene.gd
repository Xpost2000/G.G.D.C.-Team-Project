extends Node2D

onready var notifier_background = $NotifierBackground;
onready var notifier_content = $NotifierBackground/Content;
onready var notifier_title = $NotifierBackground/Title;

func _ready():
	pass

var thing = "copyrighted-test-content/snd/012.ogg";

func _process(delta):
	AudioGlobal.looped_play_music(thing);

# maybe do a fancy fade out.

enum{ MAIN_GAME_SCENE,
	  MAIN_MENU_SCENE,
	  BATTLE_SCENE,
	  GAME_SCENE_TYPE_COUNT}

func _on_StartGameButton_pressed():
	GameGlobals.reload_scene(MAIN_GAME_SCENE);
	GameGlobals.reload_scene(BATTLE_SCENE);
	GameGlobals.switch_to_scene(0);

func _on_LoadGameButton_pressed():
	thing = "copyrighted-test-content/snd/013.ogg";
	print("load game?");
	open_notification("Load Game Not Done!",
					  """
					  Do we even have time to do this?
					  
					  I'd be pretty grateful if anyone could do this, but
					  this is probably out of scope.
					  """);

func _on_OptionsButton_pressed():
	thing = "copyrighted-test-content/snd/012.ogg";
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

func _on_NotifierBackground_Close_pressed():
	notifier_background.hide();

func open_notification(title, text):
	notifier_background.show();
	notifier_title.text = title;
	notifier_content.text = text;
