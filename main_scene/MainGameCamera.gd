extends Camera2D

var current_level_bounds = null;
var bounding_by_level = true;

func set_new_bounds_from_rectangle(rectangle):
	if rectangle:
		limit_top = rectangle.position.y;
		limit_left = rectangle.position.x;
		limit_right = rectangle.end.x;
		limit_bottom = rectangle.end.y;
	else:
		limit_top = -10000000;
		limit_left = -10000000;
		limit_right = 10000000;
		limit_bottom = 1000000;

func notify_camera_of_level_bounds(level_bounds, tile_size):
	current_level_bounds = Rect2(
		level_bounds.position * tile_size,
		level_bounds.size * tile_size
	);

func _process(_delta):
	if bounding_by_level:
		set_new_bounds_from_rectangle(current_level_bounds);
	else:
		set_new_bounds_from_rectangle(null);
