extends NinePatchRect;
signal finished;

signal any_key_pressed;

var box_tweener;

var active = false;
var closing = false;
const TRANSITION_TIME = 0.8;

onready var final_width = rect_size.x;
onready var height = rect_size.y;

func _ready():
	box_tweener = Tween.new();
	add_child(box_tweener);

	$Text.visible_characters = 0;
	rect_size.x = 0;
	hide();

	connect("any_key_pressed", self, "any_key_pressed");

func popup(text):
	$Text.text = text;
	show();
	box_tweener.interpolate_property(self, "rect_size",
									 Vector2(0, height),
									 Vector2(final_width, height),
									 TRANSITION_TIME, Tween.TRANS_SINE,
									 Tween.EASE_IN_OUT);
	box_tweener.interpolate_property($Text, "rect_size",
									 Vector2(0, height),
									 Vector2(final_width, height),
									 TRANSITION_TIME, Tween.TRANS_SINE,
									 Tween.EASE_IN_OUT);
	box_tweener.interpolate_property($Text, "visible_characters",
									 0, len($Text.text),
									 TRANSITION_TIME, Tween.TRANS_SINE,
									 Tween.EASE_IN_OUT);
	box_tweener.start();
	active = true;

func _input(event):
	if (event is InputEventKey or event is InputEventJoypadButton) and event.is_pressed():
		emit_signal("any_key_pressed");

func any_key_pressed():
	if !box_tweener.is_active():
		close();
	else:
		if closing:
			_close_actions(null, null);
		else:
			box_tweener.seek(box_tweener.get_runtime());
		box_tweener.stop_all();
	

func handle_inputs(delta):
	pass;

func _close_actions(_a, _b):
	active = false;
	emit_signal("finished");
	get_parent().remove_child(self);
	queue_free();
	
func close():
	box_tweener.remove_all();

	box_tweener.interpolate_property(self, "rect_size",
									 Vector2(final_width, height),
									 Vector2(0, height),
									 TRANSITION_TIME, Tween.TRANS_SINE,
									 Tween.EASE_IN_OUT);
	box_tweener.interpolate_property($Text, "rect_size",
									 Vector2(final_width, height),
									 Vector2(0, height),
									 TRANSITION_TIME, Tween.TRANS_SINE,
									 Tween.EASE_IN_OUT);
	box_tweener.interpolate_property($Text, "visible_characters",
									 len($Text.text),
									 0,
									 TRANSITION_TIME, Tween.TRANS_SINE,
									 Tween.EASE_IN_OUT);
	box_tweener.interpolate_property(self, "modulate",
									 Color(1, 1, 1, 1),
									 Color(1, 1, 1, 0),
									 TRANSITION_TIME, Tween.TRANS_SINE,
									 Tween.EASE_IN_OUT);
	box_tweener.start();
	box_tweener.connect("tween_completed", self, "_close_actions");
	closing = true;
