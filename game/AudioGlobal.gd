extends Node;

var music_resources = {};
var sound_effect_resources = {};

const SOUND_CHANNELS = 16;
var free_sound_channel = 0;
var sound_effect_channels = [];

const DEFAULT_MAX_VOLUME_DB = -10.0;

var music_channel = null;

func load_music(filepath):
	var resource = null;
	if !(filepath in music_resources):
		music_resources[filepath] = load("res://" + filepath);

	resource = music_resources[filepath];
	return resource;

func load_sound(filepath):
	var resource = null;
	if !(filepath in sound_effect_resources):
		sound_effect_resources[filepath] = load("res://" + filepath);

	resource = sound_effect_resources[filepath];
	return resource;

func _ready():
	for channel in range(SOUND_CHANNELS):
		var new_channel = AudioStreamPlayer.new();
		add_child(new_channel);
		sound_effect_channels.append(new_channel);

	music_channel = AudioStreamPlayer.new();
	add_child(music_channel);

func play_sound(filepath, volume=DEFAULT_MAX_VOLUME_DB, channel_index=-1):
	var channel = null;
	if channel_index == -1:
		channel = sound_effect_channels[free_sound_channel];

		free_sound_channel += 1;
		free_sound_channel %= SOUND_CHANNELS;
	else:
		channel = sound_effect_channels[channel_index];
	

	channel.stream = load_sound(filepath);
	channel.volume_db = volume;
	channel.play();

func is_channel_playing(index):
	return sound_effect_channels[index].playing;

func is_music_playing():
	return music_channel.playing;

func play_music(filepath, volume=DEFAULT_MAX_VOLUME_DB):
	var music = load_music(filepath);
	music_channel.stream = music;
	music_channel.volume_db = volume;
	music_channel.play();
	print(music);
	print(music_channel.playing);
	print(music_channel.stream_paused);
	
