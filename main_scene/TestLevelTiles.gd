extends TileMap
signal notify_camera_of_level_bounds(level_bounds, tile_size);

func _ready():
	var bounds = get_used_rect();
	emit_signal("notify_camera_of_level_bounds", bounds, 64);
