extends Node
class_name PlayerModComponent

@export var kinetic_damage_per_distance : float = 50.0
@export var jolt_damage : int = 1
@export var jolt_radius : float = 80.0
@export var jolt_tick_interval : float = 0.4
@export var jolt_knockback_force : float = 60.0
@export var siphon_heal_amount : int = 1
@export var shield_cost_multiplier : int = 3
@export var panic_radius : float = 150.0
@export var spike_speed_bonus : float = 10.0
@export var spike_distance_bonus : float = 20.0
@export var warp_delay : float = 0.25
@export var recursive_speed_mult : float = 0.6
@export var recursive_distance_mult : float = 0.5
@export var momentum_step : float = 0.15
@export var momentum_max_bonus : float = 0.6
@export var chain_window_ms : int = 1000


var player : Player
var equipped : Dictionary = {"head": "", "heart": "", "thrust": ""}

var default_hitbox_damage : int = 1
var jolt_timer : float = 0.0
var last_known_hp : int = 0
var hp_initialized : bool = false
var chain_count : int = 0
var last_dash_time_ms : int = -999999
var spike_stacks : int = 0

## Emit these for anything that wants to react visually to a mod's live state.
## shield_active: true while Weave Light Shields is equipped AND has enough charge to block a hit.
signal shield_active_changed(is_active: bool)
## One-shot pulse — fire your VFX/sfx off this, don't treat it as a persistent state.
signal panic_surge_triggered
signal spike_stacks_changed(stacks: int)

func setup(p: Player) -> void:
	player = p
	default_hitbox_damage = player.hitbox_component.damage
	Events.mod_equipped.connect(_on_mod_equipped)
	Events.mod_unequipped.connect(_on_mod_unequipped)
	Events.enemy_died.connect(_on_enemy_died)
	_load_from_save()

func _load_from_save() -> void:
	_apply_mod("head", SaveManager.equipped_head)
	_apply_mod("heart", SaveManager.equipped_heart)
	_apply_mod("thrust", SaveManager.equipped_thrust)

func _on_mod_equipped(category: String, id: String) -> void:
	_apply_mod(category, id)

func _on_mod_unequipped(category: String, id: String) -> void:
	_remove_mod(category, id)
	equipped[category] = ""

func _apply_mod(category: String, id: String) -> void:
	if id == "":
		return
	equipped[category] = id
	match id:
		"heart_weavelightshields":
			player.hurtbox_component.damage_block_check = Callable(self, "_try_shield_block")
			_update_shield_state()
		_:
			pass

func _remove_mod(category: String, id: String) -> void:
	match id:
		"heart_weavelightshields":
			player.hurtbox_component.damage_block_check = Callable()
			shield_active_changed.emit(false)
		"head_kineticram":
			player.hitbox_component.damage = default_hitbox_damage
		_:
			pass

func _process(delta: float) -> void:
	if player == null:
		return

	# --- head_kineticram: damage scales with distance dashed so far ---
	if equipped["head"] == "head_kineticram" and player.is_dashing:
		player.hitbox_component.damage = default_hitbox_damage + int(player.dash_distance_traveled / kinetic_damage_per_distance)
	elif player.hitbox_component.damage != default_hitbox_damage and not player.is_dashing:
		player.hitbox_component.damage = default_hitbox_damage

	# --- head_joltemitter: periodic AoE damage while charging ---
	if equipped["head"] == "head_joltemitter" and player.charging:
		jolt_timer += delta
		if jolt_timer >= jolt_tick_interval:
			jolt_timer = 0.0
			_jolt_pulse()
	else:
		jolt_timer = 0.0

func _jolt_pulse() -> void:
	for enemy in player.get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(player.global_position) > jolt_radius:
			continue

		if "health_component" in enemy and enemy.health_component:
			enemy.health_component.take_damage(jolt_damage)

		if "movement_component" in enemy and enemy.movement_component:
			var knockback_dir = (enemy.global_position - player.global_position).normalized()
			enemy.movement_component.apply_knockback(knockback_dir * jolt_knockback_force)

# --- head_siphondrill: heal on enemy kill ---
func _on_enemy_died() -> void:
	if equipped["head"] == "head_siphondrill":
		player.health_component.heal(siphon_heal_amount)
		player.update_charge_bar()

# --- heart_weavelightshields: consume battery instead of taking damage ---
func _try_shield_block(damage: int) -> bool:
	var cost = damage * shield_cost_multiplier
	if player.health_component.CUR_HP > cost:
		player.health_component.take_damage(cost)
		player.update_charge_bar()
		return true
	return false

func _update_shield_state() -> void:
	if equipped["heart"] != "heart_weavelightshields":
		shield_active_changed.emit(false)
		return
	var can_block = player.health_component.CUR_HP > shield_cost_multiplier
	shield_active_changed.emit(can_block)

# --- heart_panicsurge / heart_spikecore: react to HP changes ---
func on_hp_changed(new_hp: int, max_hp: int) -> void:
	if not hp_initialized:
		last_known_hp = new_hp
		hp_initialized = true
		_update_shield_state()
		return

	if new_hp < last_known_hp:
		_on_player_damaged()

	# "Battery zero" is CUR_HP == 0 specifically — the player is alive but
	# immobile at this point. death_val (-1) is the actual death threshold,
	# handled separately by HealthComponent.died, not here.
	if new_hp == 0 and last_known_hp != 0:
		_on_battery_zero()

	last_known_hp = new_hp
	_update_shield_state()

func _on_player_damaged() -> void:
	if equipped["heart"] == "heart_spikecore":
		player.SPEED += spike_speed_bonus
		player.max_distance += spike_distance_bonus
		player.health_component.MAX_HP = max(1, player.health_component.MAX_HP - 1)
		spike_stacks += 1
		spike_stacks_changed.emit(spike_stacks)

func _on_battery_zero() -> void:
	if equipped["heart"] == "heart_panicsurge":
		for bullet in player.get_tree().get_nodes_in_group("bullets"):
			if is_instance_valid(bullet) and bullet.global_position.distance_to(player.global_position) <= panic_radius:
				bullet.queue_free()
		panic_surge_triggered.emit()

# --- thrust mods: dash cost / params / overrides ---
func get_dash_cost() -> int:
	if equipped["thrust"] == "thrust_recursivetreads":
		return 0 if chain_count % 2 == 1 else 1
	return 1

func get_dash_params(_charge_ratio: float) -> Dictionary:
	var speed = player.SPEED
	var distance = player.max_distance

	match equipped["thrust"]:
		"thrust_recursivetreads":
			speed *= recursive_speed_mult
			distance *= recursive_distance_mult
		"thrust_momentumengine":
			var bonus = min(chain_count * momentum_step, momentum_max_bonus)
			speed *= (1.0 + bonus)
			distance *= (1.0 + bonus)

	return {"speed": speed, "distance": distance}

func try_override_dash(dash_dir: Vector2, charge_ratio: float) -> bool:
	if equipped["thrust"] == "thrust_warpcog":
		_do_warp(dash_dir, charge_ratio)
		return true
	return false

func _do_warp(dash_dir: Vector2, charge_ratio: float) -> void:
	var launch_speed = player.SPEED * charge_ratio
	var distance = (launch_speed * launch_speed) / (2.0 * player.FRICTION)
	distance = min(distance, player.max_distance)

	var target = player.global_position + dash_dir * distance

	await player.get_tree().create_timer(warp_delay).timeout
	if not is_instance_valid(player):
		return

	player.global_position = target
	player.hitbox_component.monitorable = true
	SoundBank.play_sfx("dash")

	await player.get_tree().create_timer(0.05).timeout
	if is_instance_valid(player):
		player.hitbox_component.monitorable = false

func on_dash_launched() -> void:
	var now = Time.get_ticks_msec()
	if now - last_dash_time_ms <= chain_window_ms:
		chain_count += 1
	else:
		chain_count = 0
	last_dash_time_ms = now
