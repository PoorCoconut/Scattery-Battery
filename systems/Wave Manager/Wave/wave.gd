extends Resource
class_name Wave

@export var enemies: Array[PackedScene] = []
@export var spawn_all: bool = false
@export var spawn_by: int = 1
@export var spawn_cooldown: float = 1.0

@export_group("Asteroid Belt")
@export var has_asteroid_belt: bool = false
#@export var small_asteroid_scene: PackedScene = preload("uid://do8jf8y45s7pp")
#@export var big_asteroid_scene: PackedScene = preload("uid://c16bthglkir5v")
@export var small_asteroid_count: int = 5
@export var big_asteroid_count: int = 2
@export var asteroid_speed_min: float = 20.0
@export var asteroid_speed_max: float = 40.0
