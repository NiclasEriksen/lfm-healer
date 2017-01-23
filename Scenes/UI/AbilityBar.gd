extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal ability_tapped(slot)

func _ready():
	get_node("VBoxContainer").set_size(get_size())


func update_spell_cd(id, val):
	var a_node = null
	if id == 1:
		a_node = get_node("VBoxContainer/HBoxContainer/Ability1")
	if id == 2:
		a_node = get_node("VBoxContainer/HBoxContainer/Ability2")
	if id == 3:
		a_node = get_node("VBoxContainer/HBoxContainer/Ability3")
	if id == 4:
		a_node = get_node("VBoxContainer/HBoxContainer/Ability4")

	if a_node:
		a_node.get_node("ProgressBar").set_val(val)
		if val == 0:
			a_node.get_node("AnimationPlayer").play("ready")
func _on_Ability1_button_down():
	emit_signal("ability_tapped", 1)

func _on_Ability2_button_down():
	emit_signal("ability_tapped", 2)

func _on_Ability3_button_down():
	emit_signal("ability_tapped", 3)

func _on_Ability4_button_down():
	emit_signal("ability_tapped", 4)