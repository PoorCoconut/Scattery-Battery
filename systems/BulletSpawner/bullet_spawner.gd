extends Node2D
class_name BulletSpawner

## Dynamic bullet pattern spawner. Drag a bullet scene in, tune the
## exports, call start_firing() / stop_firing() and it handles the rest.

enum PatternType {
	FAN,             # bullets spread across `spread_degrees`, centered on aim direction
	SPIRAL,          # full-circle pattern that rotates a bit more each shot
	FOUR_DIRECTION,  # fixed compass directions (N, NE, E, SE, S, SW, W, NW)
}

# --- Bullet setup ---
@export var bullet_scene: PackedScene ## The bullet to spawn (e.g. Bullet.tscn)
@export var bullet_parent: Node ## Where spawned bullets get added. Defaults to current scene root if left empty.
@export var auto_fire : bool = false

# --- Pattern shape ---
@export_group("Pattern")
@export var pattern_type: PatternType = PatternType.FAN
@export var bullet_count: int = 8 ## Bullets spawned per shot
@export var spread_degrees: float = 45.0 ## FAN: total spread angle. SPIRAL: rotation added per shot.

# --- Timing ---
@export_group("Timing")
@export var explosion: bool = false ## true = spawn all bullets in a shot at once. false = one by one.
@export var delay_between_bullets: float = 0.05 ## Gap between bullets within one shot (ignored if explosion or bullet_count <= 1)
@export var shots_per_round: int = 1 ## How many shots make up one round
@export var cooldown: float = 1.0 ## Delay after a full round before the next one starts

# --- Aiming ---
@export_group("Aiming")
@export var target: Node2D ## Optional. If set, FAN/SPIRAL aim toward this target instead of the spawner's rotation.
@export var rotation_offset_degrees: float = 90.0 ## Corrects for bullets whose forward is local "up" (-Y) instead of "right" (+X). Set to 0 if your bullet moves along +X.

signal bullet_spawned(bullet: Node)
signal shot_fired
signal round_fired

var _is_firing: bool = false
var _spiral_angle: float = 0.0

# Fixed compass directions in degrees (Godot: 0 = right/E, 90 = down/S)
const _COMPASS_DEGREES := [-90.0, -45.0, 0.0, 45.0, 90.0, 135.0, 180.0, -135.0] # N, NE, E, SE, S, SW, W, NW

func _ready() -> void:
	if auto_fire:
		start_firing()

func start_firing() -> void:
	if _is_firing:
		return
	_is_firing = true
	_fire_loop()


func stop_firing() -> void:
	_is_firing = false


func _fire_loop() -> void:
	while _is_firing:
		for shot in shots_per_round:
			if not _is_firing:
				return
			await _spawn_pattern()
			shot_fired.emit()

		round_fired.emit()

		if not _is_firing:
			return
		if cooldown > 0.0:
			await get_tree().create_timer(cooldown).timeout


func _spawn_pattern() -> void:
	var angles := _get_pattern_angles()

	if explosion or angles.size() <= 1:
		for angle in angles:
			_spawn_bullet(angle)
	else:
		for angle in angles:
			_spawn_bullet(angle)
			if delay_between_bullets > 0.0:
				await get_tree().create_timer(delay_between_bullets).timeout

	if pattern_type == PatternType.SPIRAL:
		_spiral_angle += deg_to_rad(spread_degrees)


func _get_base_angle() -> float:
	if target:
		return (target.global_position - global_position).angle()
	return rotation


func _get_pattern_angles() -> Array[float]:
	match pattern_type:
		PatternType.FAN:
			return _fan_angles()
		PatternType.SPIRAL:
			return _spiral_angles()
		PatternType.FOUR_DIRECTION:
			return _four_direction_angles()
	return []


func _fan_angles() -> Array[float]:
	var base_angle := _get_base_angle()
	var angles: Array[float] = []

	if bullet_count <= 1:
		angles.append(base_angle)
		return angles

	var spread_rad := deg_to_rad(spread_degrees)
	for i in bullet_count:
		var t := float(i) / float(bullet_count - 1)
		angles.append(base_angle - spread_rad * 0.5 + spread_rad * t)
	return angles


func _spiral_angles() -> Array[float]:
	var base_angle := _get_base_angle()
	var angles: Array[float] = []
	var count := maxi(bullet_count, 1)

	for i in count:
		angles.append(base_angle + _spiral_angle + (TAU / count) * i)
	return angles


func _four_direction_angles() -> Array[float]:
	var count: int = clampi(bullet_count, 1, _COMPASS_DEGREES.size())
	var angles: Array[float] = []

	for i in count:
		# evenly pick `count` directions out of the 8 available, keeps it symmetric
		var idx := int(round(i * _COMPASS_DEGREES.size() / float(count))) % _COMPASS_DEGREES.size()
		angles.append(deg_to_rad(_COMPASS_DEGREES[idx]))
	return angles


func _spawn_bullet(angle: float) -> void:
	if not bullet_scene:
		push_warning("BulletSpawner: no bullet_scene assigned")
		return

	var bullet := bullet_scene.instantiate()
	var parent := bullet_parent if bullet_parent else get_tree().current_scene
	parent.add_child(bullet)

	bullet.global_position = global_position
	# rotation_offset_degrees corrects for bullets that move along -transform.y (local "up")
	# instead of +transform.x (local "right") — see player_bullet.gd's -transform.y velocity.
	bullet.rotation = angle + deg_to_rad(rotation_offset_degrees)

	# Support either a set_direction() method or a `direction` var on the bullet.
	# This is the actual world-space movement vector, so it's NOT offset —
	# only the visual `rotation` needs correcting.
	if bullet.has_method("set_direction"):
		bullet.set_direction(Vector2.RIGHT.rotated(angle))
	elif "direction" in bullet:
		bullet.direction = Vector2.RIGHT.rotated(angle)

	bullet_spawned.emit(bullet)
