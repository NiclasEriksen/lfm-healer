extends "res://Scenes/Modules/States/State.gd"

func on_enter():
	pass

func check_reqs():
	return not (statsmodule == null)

func _ready():
	pass

func update(dt):
	if not statsmodule.is_stunned():
		brain.pop_state()
