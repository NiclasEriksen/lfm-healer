extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal ability_tapped(slot)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func update_spell_cd(id, val):
	var box = get_node("HBoxContainer")
	if id == 1:
		box.get_node("Ability1").get_node("ProgressBar").set_val(val)
	if id == 2:
		box.get_node("Ability2").get_node("ProgressBar").set_val(val)
	if id == 3:
		box.get_node("Ability3").get_node("ProgressBar").set_val(val)
	if id == 4:
		box.get_node("Ability4").get_node("ProgressBar").set_val(val)

func _on_Ability1_button_down():
	emit_signal("ability_tapped", 1)

func _on_Ability2_button_down():
	emit_signal("ability_tapped", 2)

func _on_Ability3_button_down():
	emit_signal("ability_tapped", 3)

func _on_Ability4_button_down():
	emit_signal("ability_tapped", 4)