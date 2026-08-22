extends Node2D

@onready var glaster_baster_spawns: Node2D = $GlasterBasterSpawns
@onready var pillar_spawner: Node2D = $PillarSpawner
var glaster_baster_weighted_spawn : Array[int] = [1, 1, 1, 1, 2, 2, 2, 3, 3, 5]
var glaster_baster_path : PackedScene = preload("uid://d0pjxrdorsv0y")
var pillar_path : PackedScene = preload("uid://buu7amv76l5he")

func _on_glaster_baster_timer_timeout() -> void:
	var baster_num = glaster_baster_weighted_spawn[randi_range(0, glaster_baster_weighted_spawn.size()-1)]
	var spawns = glaster_baster_spawns.get_children()
	print("glaster baster timed out. Possible glaster baster:", baster_num)
	if randi_range(1, 4) == 1:
		for i in baster_num:
			var spawn = spawns[randi_range(0, spawns.size() - 1)]
			var glaster_baster = glaster_baster_path.instantiate()
			glaster_baster.global_position = spawn.global_position
			self.add_child(glaster_baster)
			print("glaster baster added at position: ", glaster_baster.global_position)

func _on_pillar_timer_timeout() -> void:
	var pillar = pillar_path.instantiate()
	print("pillar timed out")
	if randi_range(1, 5) == 1: #Roll for chance
		self.add_child(pillar)
		pillar.global_position = pillar_spawner.global_position
		print("pillar added")
	else:
		print("pillar failed chance")
