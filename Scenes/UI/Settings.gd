extends WindowDialog
signal load_map
var maps = {}
var data = {}


func _ready():
	var dm = Globals.get("debug_mode")
	var cm = Globals.get("chill_mode")
	var as = Globals.get("autospawn")
	var sf = Globals.get("show_fps")
	if get_tree().get_root().has_node("Game"):
#		maps = get_tree().get_root().get_node("Game").maplist_node.get_maps()
		var game = get_tree().get_root().get_node("Game")
		game.maplist_node.generate_mapdict()
		maps = game.maplist_node.mapdict
		data = game.userdata.load_data("Settings")
		dm = data["debug_mode"]
		as = data["autospawn"]
		sf = data["show_fps"]
	get_node("HBoxContainer/VBoxContainer/CheckBox").set_pressed(dm)
	get_node("HBoxContainer/VBoxContainer/CheckBox2").set_pressed(cm)
	get_node("HBoxContainer/VBoxContainer/CheckBox3").set_pressed(as)
	get_node("HBoxContainer/VBoxContainer/CheckBox4").set_pressed(sf)
	for m in maps:
		get_node("HBoxContainer/VBoxContainer/HBoxContainer/MapList").add_item(m)
func _on_CheckBox_toggled( pressed ):
	data["debug_mode"] = pressed
	Globals.set("debug_mode", pressed)

func _on_CheckBox2_toggled( pressed ):
	Globals.set("chill_mode", pressed)

func _on_CheckBox3_toggled( pressed ):
	data["autospawn"] = pressed
	Globals.set("autospawn", pressed)

func _on_CheckBox4_toggled( pressed ):
	data["show_fps"] = pressed
	Globals.set("show_fps", pressed)

func _on_Button_pressed():	# Cancel
	hide()

func _on_Save_pressed():
	if get_tree().get_root().has_node("Game"):
		var game = get_tree().get_root().get_node("Game")
		game.userdata.save_data("Settings", data)
	hide()

func _on_Load_pressed():
	var m = get_node("HBoxContainer/VBoxContainer/HBoxContainer/MapList").get_text()
	emit_signal("load_map", maps[m])
