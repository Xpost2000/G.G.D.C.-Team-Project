extends VBoxContainer

const MESSAGE_LIFETIME_MAX = 2.5;

# Yes I suppose you could make a timer along with the message as a callback...
class LabelWithLifetime extends Label:
	func _init(text):
		self.text = text;
		self.lifetime = MESSAGE_LIFETIME_MAX;

	func _process(delta):
		self.lifetime -= delta;
		self.set("custom_colors/font_color", Color(1, 1, 1, self.lifetime / MESSAGE_LIFETIME_MAX));

	func dead():
		return self.lifetime <= 0.0;

	var lifetime: float;

func push_message(message):
	var message_label = LabelWithLifetime.new(message);
	add_child(message_label);

func _process(delta):
	for message in get_children():
		if message.dead():
			remove_child(message);
