extends NinePatchRect

var box_tweener;

var active = false;
const TRANSITION_TIME = 0.8;

func _ready():
	box_tweener = Tween.new();
	add_child(box_tweener);

	hide();

func popup(text):
	$Text.text = text;
	show();
	var final_width = rect_size.x;
	var height = rect_size.y;
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

func _close_actions(_a, _b):
	active = false;
	get_parent().remove_child(self);
	queue_free();
	
func close():
	var final_width = rect_size.x;
	var height = rect_size.y;

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
