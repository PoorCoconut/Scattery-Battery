extends Node
class_name EnemySpawner

signal enemy_spawned(enemy: Node)
signal all_enemies_spawned  # renamed from wave_finished — spawning done, enemies may still be alive
signal wave_cleared         # NEW — fires only when every spawned enemy is dead

@export var player: Node2D
@export var spawn_area: Rect2 = Rect2(0, 0, 320, 180)
@export var player_exclusion_radius: float = 40.0
@export var max_position_attempts: int = 30

var active_enemy_count: int = 0
var spawning_complete: bool = false

func spawn_wave(wave: Wave) -> void:
	active_enemy_count = 0
	spawning_complete = false
	
	var queue: Array[PackedScene] = wave.enemies.duplicate()
	
	if wave.spawn_all:
		for scene in queue:
			_spawn_enemy(scene)
		_finish_spawning()
		return
	
	while not queue.is_empty():
		var batch_size = min(wave.spawn_by, queue.size())
		for i in batch_size:
			_spawn_enemy(queue.pop_front())
		
		if not queue.is_empty():
			await get_tree().create_timer(wave.spawn_cooldown).timeout
	
	_finish_spawning()

func _finish_spawning() -> void:
	spawning_complete = true
	all_enemies_spawned.emit()
	_check_wave_cleared() # handles edge case: wave had 0 enemies, or they all died mid-spawn

func _spawn_enemy(scene: PackedScene) -> void:
	var enemy = scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = _get_valid_spawn_position()
	
	active_enemy_count += 1
	
	if enemy.has_node("HealthComponent"):
		var hp = enemy.get_node("HealthComponent")
		hp.died.connect(_on_enemy_died)
	
	enemy_spawned.emit(enemy)

func _on_enemy_died() -> void:
	active_enemy_count -= 1
	_check_wave_cleared()

func _check_wave_cleared() -> void:
	if spawning_complete and active_enemy_count <= 0:
		wave_cleared.emit()
		print("WAVE CLEARED!")

func _get_valid_spawn_position() -> Vector2:
	var pos = Vector2.ZERO
	for attempt in max_position_attempts:
		pos = Vector2(
			randf_range(spawn_area.position.x, spawn_area.end.x),
			randf_range(spawn_area.position.y, spawn_area.end.y)
		)
		if not player or pos.distance_to(player.global_position) >= player_exclusion_radius:
			return pos
	return pos
