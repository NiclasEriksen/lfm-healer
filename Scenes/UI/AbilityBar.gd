extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal ability_tapped(slot)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_Ability1_button_down():
	emit_signal("ability_tapped", 1)

func _on_Ability2_button_down():
	emit_signal("ability_tapped", 2)

func _on_Ability3_button_down():
	emit_signal("ability_tapped", 3)

func _on_Ability4_button_down():
	emit_signal("ability_tapped", 4)