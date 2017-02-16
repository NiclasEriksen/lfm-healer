extends WindowDialog
signal load_map
var maps = {}


func _ready():
	var dm = Globals.get("debug_mode")
	var cm = Globals.get("chill_mode")
	var as = Globals.get("autospawn")
	var sf = Globals.get("show_fps")
	get_node("HBoxContainer/VBoxContainer/CheckBox").set_pressed(dm)
	get_node("HBoxContainer/VBoxContainer/CheckBox2").set_pressed(cm)
	get_node("HBoxContainer/VBoxContainer/CheckBox3").set_pressed(as)
	get_node("HBoxContainer/VBoxContainer/CheckBox4").set_pressed(sf)
	if get_tree().get_root().has_node("Game"):
#		maps = get_tree().get_root().get_node("Game").maplist_node.get_maps()
		get_tree().get_root().get_node("Game").maplist_node.generate_mapdict()
		maps = get_tree().get_root().get_node("Game").maplist_node.mapdict
	for m in maps:
		get_node("HBoxContainer/VBoxContainer/HBoxContainer/MapList").add_item(m)
func _on_CheckBox_toggled( pressed ):
	Globals.set("debug_mode", pressed)

func _on_CheckBox2_toggled( pressed ):
	Globals.set("chill_mode", pressed)

func _on_CheckBox3_toggled( pressed ):
	Globals.set("autospawn", pressed)

func _on_CheckBox4_toggled( pressed ):
	Globals.set("show_fps", pressed)

func _on_Button_pressed():
	hide()

func _on_Load_pressed():
	var m = get_node("HBoxContainer/VBoxContainer/HBoxContainer/MapList").get_text()
	emit_signal("load_map", maps[m])
