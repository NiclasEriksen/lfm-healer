extends WindowDialog

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var dm = Globals.get("debug_mode")
	var cm = Globals.get("chill_mode")
	var as = Globals.get("autospawn")
	get_node("HBoxContainer/VBoxContainer/CheckBox").set_pressed(dm)
	get_node("HBoxContainer/VBoxContainer/CheckBox2").set_pressed(cm)
	get_node("HBoxContainer/VBoxContainer/CheckBox3").set_pressed(as)


func _on_CheckBox_toggled( pressed ):
	Globals.set("debug_mode", pressed)

func _on_CheckBox2_toggled( pressed ):
	Globals.set("chill_mode", pressed)

func _on_CheckBox3_toggled( pressed ):
	Globals.set("autospawn", pressed)


func _on_Button_pressed():
	hide()
