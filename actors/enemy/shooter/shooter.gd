extends CharacterBody2D

@onready var bullet_spawner: BulletSpawner = $BulletSpawner
@onready var health_component: HealthComponent = $HealthComponent

func _process(delta: float) -> void:
	if bullet_spawner.target:
		look_at(bullet_spawner.target.global_position)


func _on_health_component_hp_changed(new_hp: Variant, max_hp: Variant) -> void:
	pass # Replace with function body.

func _on_health_component_died() -> void:
	Events.enemy_died.emit()
	queue_free()
