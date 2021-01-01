extends Label

var original_position;
var sine_input = 0;
func _ready():
	original_position = rect_global_position;

func _process(delta):
	sine_input += delta;
	rect_global_position.y = sin(sine_input*2) * 30 + original_position.y + 20;
