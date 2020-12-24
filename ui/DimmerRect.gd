extends ColorRect

export(float) var dimmer_max_time = 1.0;
export(float) var dimmer_timer = 0;
export(bool) var fade_in = true;
export(bool) var disabled = false;

func finished_fade():
	return dimmer_timer >= dimmer_max_time;

func begin_fade_in():
	fade_in = true;
	dimmer_timer = 0;

func begin_fade_out():
	fade_in = false;
	dimmer_timer = 0;

func _process(delta):
	if !disabled:
		if fade_in:
			color.a = dimmer_timer / dimmer_max_time;
		else:
			color.a = 1.0 - (dimmer_timer/dimmer_max_time);
		dimmer_timer += delta;
		dimmer_timer = clamp(dimmer_timer, 0.0, dimmer_max_time);
