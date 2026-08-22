extends CanvasLayer

@onready var blink: AnimationPlayer = $Blink

func _ready():
	Events.player_hp_updated.connect(_on_player_hp_updated)
	$Control/WarnSprite.hide()

func _on_player_hp_updated(current_hp: float, max_hp: float):
	if current_hp == 1:
		blink.play("blink")
		SoundBank.play_sfx("danger")
	elif current_hp == 0:
		SoundBank.play_sfx("power_down")
