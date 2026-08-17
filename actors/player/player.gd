extends CharacterBody2D
class_name Player

#Components
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent

@export var SPEED : float = 100
@export var ACCELERATION : float = 50
@export var FRICTION : float = 5
@export var MAX_TIME : float = 1.5
@export var MAX_DISTANCE : float = 400.0

var time_held : float = 0.0
var distance_to : float = 0.0
var thrusting : bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	var mouse_dir = (get_global_mouse_position() - global_position).normalized()
	var can_still_thrust = time_held < MAX_TIME and distance_to < MAX_DISTANCE
	
	if Input.is_action_pressed("ui_accept") and can_still_thrust:
		thrusting = true
		time_held += delta
		
		velocity = velocity.move_toward(mouse_dir * SPEED, ACCELERATION * delta)
		distance_to += velocity.length() * delta
	else:
		thrusting = false
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	if not Input.is_action_pressed("ui_accept") and velocity.length() < 1.0:
		time_held = 0.0
		distance_to = 0
	move_and_slide()
