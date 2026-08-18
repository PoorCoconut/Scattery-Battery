extends CharacterBody2D
class_name Player

#Components
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent

@onready var charge_light: PointLight2D = $ChargeLight

#player variables
@export var SPEED = 100.0
@export var ACCELERATION = 50.0
@export var FRICTION = 5.0
@export var max_time = 1.5
@export var max_distance = 400.0

var time_held = 0.0
var charging = false

func _ready():
	hurtbox_component.connect("knockback_received", _on_knockback_received)

func _physics_process(delta):
	look_at(get_global_mouse_position())
	if Input.is_action_pressed("ui_accept"):
		charging = true
		time_held = min(time_held + delta, max_time)
	elif charging:
		charging = false
		var charge_ratio = time_held / max_time
		var dash_dir = (get_global_mouse_position() - global_position).normalized()
		velocity = dash_dir * SPEED * charge_ratio
		time_held = 0.0
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move_and_slide()


func _on_knockback_received(direction: Vector2, force: float) -> void:
	velocity += direction * force
