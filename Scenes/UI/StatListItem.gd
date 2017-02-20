extends HBoxContainer

var stat = null
var value = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func init(s, val):
	stat = s
	value = val
	var txt = stat
	if txt.begins_with("base_"):
		txt.erase(0, 5)
	get_node("Stat").set_text(str(txt))
	update_value()

func update_value():
	get_node("HBoxContainer/Amount").set_text(str(value))

func _on_Minus_button_down():
	value -= 1
	update_value()

func _on_Plus_button_down():
	value += 1
	update_value()
