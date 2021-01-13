extends ColorRect
signal notify_finished;

func _on_LevelUpResults_notify_finished():
	emit_signal("notify_finished");

func _ready():
	pass
