extends Node
export(String, DIR) var maps_directory = "res://Scenes/Maps/" setget set_map_dir, get_map_dir

func set_map_dir(d):
	maps_directory = d

func get_map_dir():
	return maps_directory

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func get_maps():
	if not maps_directory:
		print("No map directory set in MapList!")
		return []
	var dir = Directory.new()
	var mapfiles = []
	if dir.open(maps_directory) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
#		print("_--------------------------_")
#		print("Beginning to read directory.")
#		print("First file name: ", file_name)
#		print("_--------------------------_")
		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				print("Filename: ", file_name)
				if file_name.ends_with("scn"):
					var ffn = file_name
					ffn = ffn.replace(".converted.scn", "")
					mapfiles.append(ffn)

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

	return mapfiles
