extends Node;

# Shove any global variable or state here?
var action_paused = false;

func paused():
	return action_paused;

func toggle_pause():
	if action_paused:
		resume();
	else:
		pause();

func pause():
	action_paused = true;
func resume():
	action_paused = false;
