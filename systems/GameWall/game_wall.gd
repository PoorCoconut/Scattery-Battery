extends Node2D

@export var wall_knockback : float = 80.0
@onready var north_wall: HitboxComponent = $NorthWall
@onready var west_wall: HitboxComponent = $WestWall
@onready var east_wall: HitboxComponent = $EastWall
@onready var south_wall: HitboxComponent = $SouthWall

func _ready() -> void:
	north_wall.knockback_force = wall_knockback
	west_wall.knockback_force = wall_knockback
	east_wall.knockback_force = wall_knockback
	south_wall.knockback_force = wall_knockback
