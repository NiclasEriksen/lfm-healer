tool
extends Navigation2D
export(String, FILE) var mapfile = null setget set_mapfile

func set_mapfile(newmap):
	if newmap:
		var tex = load(newmap)
		get_node("Sprite").set_texture(tex)
	mapfile = newmap

func set_spawn_pos():
	var es = get_node("EnemySpawn")
	var fs = get_node("FriendlySpawn")
	var ry = Globals.get("render_height")
	var rx = Globals.get("render_width")
	es.set_pos(Vector2(rx - (rx / 10), ry / 2))
	fs.set_pos(Vector2(rx / 8, ry / 2))

func _ready():
	set_spawn_pos()