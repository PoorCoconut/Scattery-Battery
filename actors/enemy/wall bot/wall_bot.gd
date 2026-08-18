extends CharacterBody2D
class_name EnemyWallBot

@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent

func _ready() -> void:
	pass

func _on_health_component_hp_changed(new_hp: Variant, max_hp: Variant) -> void:
	pass # Replace with function body.

func _on_health_component_died() -> void:
	queue_free()
