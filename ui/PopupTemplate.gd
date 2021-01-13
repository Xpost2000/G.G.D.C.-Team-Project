extends NinePatchRect

var active = false;

func _ready():
	hide();

func popup(text):
	$Text.text = text;
	show();
	active = true;

func handle_inputs(delta):
	# if Input.is_action_just_pressed("ui_cancel"):
	if Input.is_action_just_pressed("game_action_ui_pause"):
		close();

func close():
	active = false;
	get_parent().remove_child(self);
	queue_free();
