extends Node
class_name WaveManager

signal wave_started(wave: Wave)
signal wave_completed

@export var waves: Array[Wave] = []
@export var spawner: EnemySpawner
#@export var asteroid_spawner: AsteroidSpawner

var current_wave: Wave

func start_random_wave() -> void:
	var pool: Array[Wave]
	pool = waves
	#match GameManager.difficulty:
		#"e": pool = easy_waves
		#"m": pool = medium_waves
		#"h": pool = hard_waves
		#"b": pool = boss_waves
		#_:
			#push_warning("Unknown difficulty: " + GameManager.difficulty)
			#return
	
	if pool.is_empty():
		push_warning("No waves detected")
		return
	
	current_wave = pool[randi() % pool.size()]
	wave_started.emit(current_wave)
	
	#asteroid_spawner.spawn_belt(current_wave)
	spawner.spawn_wave(current_wave)
	await spawner.wave_cleared
	#if GameManager.difficulty == "b":
		#Events.complete_game.emit()
	wave_completed.emit()
