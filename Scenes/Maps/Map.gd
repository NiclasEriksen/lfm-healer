tool
extends Navigation2D
export(String, FILE) var mapfile = null setget set_mapfile

func set_mapfile(newmap):
	if newmap:
		var tex = load(newmap)
		get_node("Sprite").set_texture(tex)
	mapfile = newmap

func _ready():
	pass