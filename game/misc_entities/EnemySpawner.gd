# stupid enemy spawner
extends Node2D
export(PackedScene) var enemy_scene = null;
var existing_enemy_instance = null;

onready var timer = $SpawnTimer;

var wait_until_tick = false;
func spawn_enemy_on_timeout():
	var new_enemy = enemy_scene.instance();
	new_enemy.global_position = global_position;
	existing_enemy_instance = new_enemy;
	get_parent().add_child(new_enemy);

	wait_until_tick = false;
	timer.stop();

func should_spawn_enemy():
	if existing_enemy_instance:
		return existing_enemy_instance.all_members_dead() && !wait_until_tick;
	else:
		return !wait_until_tick;

func _ready():
	timer.one_shot = true;
	timer.connect("timeout", self, "spawn_enemy_on_timeout");

func _process(delta):
	timer.paused = GameGlobals.paused();
	if should_spawn_enemy():
		timer.start();
		wait_until_tick = true;
