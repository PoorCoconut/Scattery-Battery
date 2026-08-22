extends CharacterBody2D

@export var SPEED : float = 50.0
@export var ACCELERATION : float = 10.0
@onready var health_component: HealthComponent = $HealthComponent
var player : Player

func _ready() -> void:
	if get_tree().get_first_node_in_group("player"):
		player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	move_and_slide()

func _on_health_component_hp_changed(new_hp: Variant, max_hp: Variant) -> void:
	SoundBank.play_sfx("metal_hit")

func _on_health_component_died() -> void:
	SoundBank.play_sfx("enemy_hit")
	Events.enemy_died.emit()
	queue_free()

func _on_hurtbox_component_knockback_received(direction: Vector2, force: float) -> void:
	velocity += direction * force
