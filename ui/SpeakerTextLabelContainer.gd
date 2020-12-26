extends ColorRect
onready var speaker_name_label = $SpeakerName;

func _process(delta):
	rect_size = speaker_name_label.rect_size;
