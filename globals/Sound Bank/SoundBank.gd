extends Node

#Store sound effects here...
var sfx_dict : Dictionary = {
	"danger" : preload("uid://cvxmlpnctucsx"),
	"destroy" : preload("uid://bmlmpydjbnl6r"),
	"escape" : preload("uid://b0h7kyrqpkmxj"),
	"fatal" : preload("uid://ch0dvswv8fj05"),
	"gen_hit" : preload("uid://b3smvdgy7uqml"),
	"metal_hit" : preload("uid://dqipikmbnsfwk"),
	"player_hit" : preload("uid://f7np8jg7dr6"),
	"prison" : preload("uid://qa7axtu2pfd2"),
	"start" : preload("uid://bm18jy4s4tf4y"),
	"success" : preload("uid://c43la73evymb"),
	
	"battery" : preload("uid://vsmhu521y5w4"),
	"battery_charge" : preload("uid://cb1e7wigxjm2i"),
	"enemy_hit" : preload("uid://dnbrm1iaxasw"),
	"crit" : preload("uid://q7mqtaddudw4"),
	"dash" : preload("uid://ci1ss662w0agh"),
	"drone" : preload("uid://88ku5eraoc3r"),
	"laser" : preload("uid://f3qx4kf3lro2"),
	"magic" : preload("uid://csebftvp74gnw"),
	"battery_low" : preload("uid://cdi6j37xwwdxo"),
	"power_up": preload("uid://djrvt7msr42aq"),
	"power_down": preload("uid://v5drntaa3oid"),
	"click" : preload("uid://b3g60bwmnbg34"),
	
	"menu" : preload("uid://c7tpsrsweownr")
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func play_sfx(sfx_name : String, min_pitch : float = 0.7, max_pitch : float = 1.2, spawn_pos : Vector2 = Vector2.ZERO) -> void:
	#Check if sound exists
	if not sfx_dict.has(sfx_name):
		push_error("GameManager: SFX '" + sfx_name + "' not found in dictionary.")
		return
		
	#Create an audio player
	var sfx_player = AudioStreamPlayer2D.new()
	
	#Give it the specific sound from the dictionary and set its position
	sfx_player.stream = sfx_dict[sfx_name]
	sfx_player.global_position = spawn_pos
	sfx_player.pitch_scale = randf_range(min_pitch, max_pitch) #Change these values for more variation of the sounds
	sfx_player.bus = "SFX"
	
	#Add it to the GameManager, play it, and queue_free when done
	add_child(sfx_player)
	sfx_player.finished.connect(sfx_player.queue_free)
	sfx_player.play()
