extends Node2D

onready var game = get_tree().get_root().get_node("Game")

func _ready():
	set_process(true)
	
func _process(dt):
	if game.dragged_ability:
		get_node("Sprite").set_rot(
			get_pos().angle_to_point(game.dragged_ability.get_pos()) + PI
		)
	else:
		get_node("Sprite").set_rot(PI / 2)
