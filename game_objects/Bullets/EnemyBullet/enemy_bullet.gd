extends CharacterBody2D
class_name EnemyBullet

@export var hitbox_component : HitboxComponent
@export var SPEED : float = 20.0
var ROTA : float
var DMG : int = 1

func _ready() -> void:
	hitbox_component.damage = DMG
	rotation = ROTA

func _physics_process(_delta: float) -> void:
	velocity = -transform.y * (SPEED)
	move_and_slide()

func _on_visible_on_screen_screen_exited() -> void:
	queue_free()

func _on_hitbox_component_hit_landed(_recoil_direction: Vector2) -> void:
	queue_free()
