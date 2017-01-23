extends HBoxContainer
onready var game = get_tree().get_root().get_node("Game")

func _ready():
	set_focus_mode(0)
	set_size(get_parent().get_size())
	for c in get_children():
		c.set_focus_mode(0)
		c.get_node("Sprite").set_pos(c.get_size() / 2)
	set_process_input(true)
	set_process(true)
#	scale_properly()
