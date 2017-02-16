extends Node
var user_dir = "user://"
var defaults = {
	"Settings": "res://Scripts/Default/Settings.json",
	"Formations": "res://Scripts/Default/Formations.json",
}

func _ready():
	var d = load_data("Formations")
	save_data("Formations", d)

func populate_with_default(type):
	print("Populating '", type, "' with default configuration.")
	var default_file = File.new()

	if default_file.open(defaults[type], File.READ) != 0:
		print("Error reading default userdata!")
		return {}

	var d = {}
	d.parse_json(default_file.get_as_text())
	save_data(type, d)
	return d

func load_data(type):
	var filename = type + ".json"
	var file = File.new()

	if not file.file_exists(user_dir + filename):
		print("No file saved!")
		if defaults.has(type):
			return populate_with_default(type)
		else:
			return {}

	if file.open(user_dir + filename, File.READ) != 0:
		print("Error opening file")
		if defaults.has(type):
			return populate_with_default(type)
		else:
			return {}

	var data = {}
	data.parse_json(file.get_line())
	return data

func save_data(type, data):
	var filename = type + ".json"
	var file = File.new()

	if file.open(user_dir + filename, File.WRITE) != 0:
		print("Error opening file")
		return

	file.store_line(data.to_json())
	file.close()

	return data
