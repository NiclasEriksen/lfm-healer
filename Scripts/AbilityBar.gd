extends HBoxContainer
onready var game = get_tree().get_root().get_node("Game")


func _ready():
	set_process_input(true)
	set_process(true)


func _input(event):
	pass

func _on_Ability1_button_down():
	var pos = get_pos() + Vector2(get_node("Ability1").get_size() / 2)
	game.dragged_ability = game.targeted_heal.instance()
	game.dragged_ability.set_pos(pos)
	game.dragged_ability.set_active(false)
	game.get_node("Effects").add_child(game.dragged_ability)
