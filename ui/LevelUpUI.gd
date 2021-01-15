extends ColorRect
signal notify_finished;

func _on_LevelUpResults_notify_finished():
	emit_signal("notify_finished");

func _ready():
	pass

func on_leave(to):
	GameGlobals.resume();
	hide();

func on_enter(from):
	GameGlobals.pause();
	show();

func handle_process(delta):
	pass;
