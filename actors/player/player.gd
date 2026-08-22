extends CharacterBody2D
class_name Player

#Components
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var charge_light: PointLight2D = $ChargeLight
@onready var charge_sfx: AudioStreamPlayer = $Sounds/ChargeSFX
@onready var battery_charge: Node2D = $BatteryCharge
@onready var charge3: TextureProgressBar = $"BatteryCharge/3Charge"
@onready var charge5: TextureProgressBar = $"BatteryCharge/5Charge"
@onready var charge8: TextureProgressBar = $"BatteryCharge/8Charge"
@onready var dash_marker: Node2D = $DashMarker
@onready var dash_line: Line2D = $DashLine
@onready var mod_component: PlayerModComponent = $ModComponent

#player variables
@export var SPEED = 100.0
@export var ACCELERATION = 50.0
@export var FRICTION = 80.0
@export var max_time = 1.5
@export var max_distance = 400.0

const MIN_LIGHT_SCALE = 0.01

var time_held = 0.0
var charging = false
var is_dashing = false
var dash_distance_traveled : float = 0.0

func _ready():
	KonamiManager.code_entered.connect(kon_code)
	hurtbox_component.connect("knockback_received", _on_knockback_received)
	hitbox_component.monitorable = false
	update_charge_bar()
	dash_marker.hide()
	dash_line.hide()
	mod_component.setup(self)

func _process(_delta: float) -> void:
	battery_charge.global_position = global_position

func _physics_process(delta):
	look_at(get_global_mouse_position())

	if Input.is_action_pressed("charge") and health_component.CUR_HP > 0:
		charging = true
		time_held = min(time_held + delta, max_time)
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		charge_sfx.pitch_scale = time_held / max_time
		charge_light.texture_scale = max(time_held / max_time, MIN_LIGHT_SCALE)

		_update_dash_preview()
	elif charging:
		charging = false
		var charge_ratio = time_held / max_time
		var dash_dir = (get_global_mouse_position() - global_position).normalized()
		time_held = 0.0
		dash_distance_traveled = 0.0

		dash_marker.hide()
		dash_line.hide()

		var dash_cost = mod_component.get_dash_cost()
		if dash_cost > 0:
			health_component.take_damage(dash_cost)

		if not mod_component.try_override_dash(dash_dir, charge_ratio):
			var params = mod_component.get_dash_params(charge_ratio)
			velocity = dash_dir * params.speed * charge_ratio
			SoundBank.play_sfx("dash")
			is_dashing = true
			hitbox_component.monitorable = true

		mod_component.on_dash_launched()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		charge_light.texture_scale = max(lerpf(charge_light.texture_scale, 0.0, 0.1), MIN_LIGHT_SCALE)
		charge_sfx.pitch_scale = lerpf(charge_sfx.pitch_scale, 0.0, 0.1)

	if is_dashing:
		dash_distance_traveled += velocity.length() * delta

	move_and_slide()

	if is_dashing and velocity.length() < 0.2:
		is_dashing = false
		hitbox_component.monitorable = false

	if velocity.length() < 0.2:
		hitbox_component.monitorable = false

func _update_dash_preview() -> void:
	var charge_ratio = time_held / max_time
	var dash_dir = (get_global_mouse_position() - global_position).normalized()
	var launch_speed = SPEED * charge_ratio

	var predicted_distance = (launch_speed * launch_speed) / (2.0 * FRICTION)
	predicted_distance = min(predicted_distance, max_distance)

	var landing_offset = dash_dir * predicted_distance

	dash_marker.global_position = global_position + landing_offset
	dash_marker.show()

	dash_line.show()
	dash_line.points = [Vector2.ZERO, dash_line.to_local(dash_marker.global_position)]

func _on_knockback_received(direction: Vector2, force: float) -> void:
	GameManager.do_camera_shake(3.0, 0.5)
	velocity += direction * force

func _on_health_component_hp_changed(new_hp: Variant, max_hp: Variant) -> void:
	Events.player_hp_updated.emit(new_hp, max_hp)
	SoundBank.play_sfx("player_hit", 0.8, 1.2)
	update_charge_bar(new_hp)
	mod_component.on_hp_changed(new_hp, max_hp)

func _on_health_component_died() -> void:
	SoundBank.play_sfx("fatal")
	GameManager.load_next_level("res://game_scenes/menus/ShopMenuComponent/mega_shop_menu_component.tscn")
	queue_free()

func update_charge_bar(cur_charge : int = health_component.CUR_HP):
	if health_component.MAX_HP == 3:
		charge3.value = cur_charge
		charge3.show()
		charge5.hide()
		charge8.hide()
	elif health_component.MAX_HP == 5:
		charge5.value = cur_charge
		charge3.hide()
		charge5.show()
		charge8.hide()
	elif health_component.MAX_HP == 8:
		charge8.value = cur_charge
		charge3.hide()
		charge5.hide()
		charge8.show()

func kon_code(code_name: String):
	if code_name == "health":
		if health_component.MAX_HP == 3: health_component.MAX_HP = 5
		elif health_component.MAX_HP == 5: health_component.MAX_HP = 8
		update_charge_bar()
	elif code_name == "damage":
		health_component.take_damage(1)

func _on_timer_timeout() -> void:
	if health_component.CUR_HP < health_component.MAX_HP:
		health_component.heal(1)
		update_charge_bar()
		SoundBank.play_sfx("click")
