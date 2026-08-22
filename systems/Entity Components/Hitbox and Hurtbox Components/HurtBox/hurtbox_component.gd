extends Area2D
class_name HurtboxComponent

signal knockback_received(direction: Vector2, force: float)

@export var health_component: HealthComponent
@export var movement_component: MovementComponent
@export var weight: float = 10.0
@export var iframe : float = 0.3
var is_invincible: bool = false

## Optional. If set, called with the incoming damage BEFORE it's applied.
## Return true to fully block the hit (no damage/knockback, but still triggers i-frames).
var damage_block_check: Callable

func _on_area_entered(area: Area2D) -> void:
	if is_invincible:
		return
	if not area is HitboxComponent:
		return

	var hitbox = area as HitboxComponent

	if damage_block_check.is_valid() and damage_block_check.call(hitbox.damage):
		hitbox.emit_hit_landed(global_position)
		await _do_iframes()
		return

	is_invincible = true
	if health_component:
		health_component.take_damage(hitbox.damage)

	var knockback_dir = (global_position - hitbox.global_position).normalized()
	var final_knockback = max(0.0, hitbox.knockback_force - weight)

	if movement_component:
		movement_component.apply_knockback(knockback_dir * final_knockback)

	knockback_received.emit(knockback_dir, final_knockback)
	hitbox.emit_hit_landed(global_position)

	await _do_iframes()

func _do_iframes() -> void:
	is_invincible = true
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	await get_tree().create_timer(iframe).timeout
	if not is_instance_valid(self) or not is_inside_tree():
		return
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
	is_invincible = false
