extends CharacterBody2D

@export var SPEED : float = 100.0
@export var ACCELERATION : float = 100.0

func _physics_process(delta: float) -> void:
	velocity = velocity.lerp(Vector2.LEFT * SPEED, delta * ACCELERATION)
	move_and_slide()

func _on_on_screen_screen_exited() -> void:
	queue_free()

func _on_health_component_died() -> void:
	queue_free()
