extends Node

const save_file_path : String = "user://save_game.dat"

#Place to-be-saved variable names here EXACTLY
var save_keys := [
	"scrap",
	"hp_upgrade", "damage_upgrade", "weight_upgrade", "battery_upgrade",
	"ram_mod", "jolt_mod", "siphon_mod",
	"shield_mod", "panic_mod", "spike_mod",
	"warp_mod", "skitter_mod", "engi_mod",
	"equipped_head", "equipped_heart", "equipped_thrust"]

#Resource variables
var scrap : int = 0

##Shop Items
#Player Stats
var hp_upgrade : int = 0
var damage_upgrade : int = 0
var weight_upgrade : int = 0
var battery_upgrade : int = 0

##Modular Upgrades (owned flags)
#Head
var ram_mod : bool = false
var jolt_mod : bool = false
var siphon_mod : bool = false

#Heart
var shield_mod : bool = false
var panic_mod : bool = false
var spike_mod : bool = false

#Thrust
var warp_mod : bool = false
var skitter_mod : bool = false
var engi_mod : bool = false

##Currently equipped item_id per category ("" = nothing equipped)
var equipped_head : String = ""
var equipped_heart : String = ""
var equipped_thrust : String = ""

func _ready() -> void:
	check_game_data()
	pass

func check_game_data():
	if FileAccess.file_exists(save_file_path):
		print("SAVE FILE EXISTS")
	else:
		print("NO SAVE FILE FOUND")

func save_game_data():
	var save_data := {}
	for key in save_keys:
		var value = get(key)
		if value == null:
			push_error("Save key '%s' doesn't match any variable!" % key)
		save_data[key] = value
	
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		print("SAVING GAME DATA...")
		file.store_var(save_data)
		file.close()

func load_game_data():
	if not FileAccess.file_exists(save_file_path):
		print("ERROR LOADING: NO SAVE FILE FOUND!")
		return
	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if file:
		print("LOADING GAME DATA...")
		var save_data = file.get_var()
		file.close()
		if save_data is Dictionary:
			for key in save_keys:
				if save_data.has(key):
					set(key, save_data[key])
					print(key + " ", save_data[key])

func delete_game_data():
	if FileAccess.file_exists(save_file_path):
		var result := DirAccess.remove_absolute(save_file_path)
		print("FILE DELETED!" if result == OK else "FAILED TO DELETE FILE. ERROR CODE: %s" % result)
	else:
		print("ERROR DELETING: NO SAVE FILE FOUND!")
