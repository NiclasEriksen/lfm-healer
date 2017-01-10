extends HBoxContainer
onready var game = get_tree().get_root().get_node("Game")

func _ready():
	set_focus_mode(0)
	for c in get_children():
		c.set_focus_mode(0)
	set_process_input(true)
	set_process(true)
