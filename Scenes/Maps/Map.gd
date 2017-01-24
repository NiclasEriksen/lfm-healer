tool
extends Navigation2D
export(String, FILE) var mapfile = null setget set_mapfile
var spawnlist = []
var spawn_wait = 0.0

func is_done_spawning():
	return not bool(spawnlist.size())

func set_mapfile(newmap):
	if newmap:
		if has_node("Sprite"):
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

func load_spawnlist():
	var fn = get_filename()
	if fn.ends_with(".converted.scn"):
		fn = fn.replace(".converted.scn", "")
	print("Filename: ", fn)
	var json_path = fn.replace(".tscn", ".json")
	print("JSON path: ", json_path)
	var file = File.new()
	file.open(json_path, file.READ)
	var text = file.get_as_text()
	var dict = {}
	dict.parse_json(text)
	file.close()
	if "spawnlist" in dict:
		spawnlist = dict["spawnlist"]

func _ready():
	spawn_wait = 0.0
	spawnlist = []
	load_spawnlist()
	set_spawn_pos()
	set_process(true)
#	print(get_node("NavigationPolygonInstance2").get_navigation_polygon().get_vertices())

func _process(dt):
	if spawnlist.size():
		if spawn_wait > 0.0:
			spawn_wait -= dt
		else:
			get_parent().spawn_actor(spawnlist[0][0], "enemy")
			if spawnlist.size() > 1:
				spawn_wait = spawnlist[1][1]
			spawnlist.remove(0)
