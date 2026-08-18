extends Node

const save_file_path : String = "user://save_game.dat"

#Place to-be-saved variable names here EXACTLY
var save_keys := ["scrap", "sum_booshi"]

#Resource variables
var scrap : int = 0
var sum_booshi : bool = false

func _ready() -> void:
	save_game_data()

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
