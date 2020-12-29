extends ColorRect

onready var TurnStackLayout = $TurnStack;

var card_width;
var card_height;

const CARDS_TO_DISPLAY = 8;

func clear_self():
	for child in TurnStackLayout.get_children():
		TurnStackLayout.remove_child(child);

func make_texture_rect_card(texture, width, height, color):
	var result = null;
	if texture:
		result = TextureRect.new();
		result.self_modulate = color;
		result.expand = true;
		result.set_stretch_mode(5);
		result.texture = texture;
	else:
		result = ColorRect.new();
		result.color = color;

	result.rect_min_size = Vector2(card_width, card_height);
	return result;

func _ready():
	card_width = floor(TurnStackLayout.rect_size.x / CARDS_TO_DISPLAY);
	print(card_width);
	card_height = TurnStackLayout.rect_size.y;

	clear_self();
	for card in range(0, CARDS_TO_DISPLAY):
		TurnStackLayout.add_child(make_texture_rect_card(load("res://images/battle/portraits/isshin_test_turn_portrait.png"),
														 card_width, card_height,
														 Color.white));

func update_view_of_turns(turn_information):
	clear_self();
	# I can be more flexible with turn information later
	# by defining artifical cooldowns or something...

	# This is basically what happens when cooldown = 0, which means they
	# will be added on at the same position or something.
	for card in range(0, CARDS_TO_DISPLAY):
		var turn_actor = turn_information.participants[(card+turn_information.active_actor_index) % len(turn_information.participants)];

		TurnStackLayout.add_child(make_texture_rect_card(
			turn_actor.portrait_battle_icon,
			card_width, card_height,
			Color.green if turn_information.active_actor() == turn_actor else Color.white));
		
