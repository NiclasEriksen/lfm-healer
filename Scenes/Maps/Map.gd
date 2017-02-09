tool
extends Navigation2D
export(String, FILE) var mapfile = null setget set_mapfile
export(String) var map_title = "No name." setget set_map_title, get_map_title
var map_size = Vector2()
var spawnlist = []
var spawn_wait = 0.0

func get_spawn_pos(alliance):
	if alliance == "friendly":
		return get_node("FriendlySpawn").get_pos()
	elif alliance == "enemy":
		return get_node("EnemySpawn").get_pos()
	else:
		print("No spawn point.")
		return Vector2(Globals.get("render_width") / 2, Globals.get("render_height") / 2)

func get_map_size():
	return map_size

func set_map_title(t):
	map_title = t

func get_map_title():
	return map_title

func is_done_spawning():
	return not bool(spawnlist.size())

func set_mapfile(newmap):
	if newmap:
		if has_node("Sprite"):
			var tex = load(newmap)
			map_size = Vector2(tex.get_width(), tex.get_height())
			get_node("Sprite").set_texture(tex)
	mapfile = newmap

func set_spawn_pos():
	var es = get_node("EnemySpawn")
	var fs = get_node("FriendlySpawn")
	var ry = Globals.get("render_height")
	var rx = Globals.get("render_width")
	es.set_pos(Vector2(rx - (rx / 10), ry / 2))
	fs.set_pos(Vector2(rx / 8, ry / 2))

func load_spawnlist():
	var fn = get_filename().replace(".converted.scn", "")
#	print("Filename: ", fn)
	var json_path = fn.replace(".tscn", ".json")
#	print("JSON path: ", json_path)
	var file = File.new()
	file.open(json_path, file.READ)
	var text = file.get_as_text()
	var dict = {}
	dict.parse_json(text)
	file.close()
	if "spawnlist" in dict:
		spawnlist = dict["spawnlist"]

func get_spawnlist():
	return spawnlist

func _ready():
	spawn_wait = 0.0
	spawnlist = []
	var tex = get_node("Sprite").get_texture()
	map_size = Vector2(tex.get_width(), tex.get_height())
	load_spawnlist()
#	set_spawn_pos()
	set_process(true)
#	print(get_node("NavigationPolygonInstance2").get_navigation_polygon().get_vertices())

func _process(dt):
	if get_tree().is_editor_hint():
		return
	if spawnlist.size():
		if spawn_wait > 0.0:
			spawn_wait -= dt
		else:
			get_parent().spawn_actor(spawnlist[0][0], "enemy")
			if spawnlist.size() > 1:
				spawn_wait = spawnlist[1][1]
			spawnlist.remove(0)
