extends NinePatchRect
signal finished;

var box_tweener;

var active = false;
var closing = false;
const TRANSITION_TIME = 0.8;

onready var final_width = rect_size.x;
onready var height = rect_size.y;

func _ready():
	box_tweener = Tween.new();
	add_child(box_tweener);

	rect_size.x = 0;
	hide();

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

func handle_inputs(delta):
	if Input.is_action_just_pressed("game_action_ui_pause"):
		if !box_tweener.is_active():
			close();
		else:
			if closing:
				_close_actions(null, null);
			else:
				box_tweener.seek(box_tweener.get_runtime());
			box_tweener.stop_all();

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
	box_tweener.start();
	box_tweener.connect("tween_completed", self, "_close_actions");
	closing = true;
