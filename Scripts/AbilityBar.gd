extends HBoxContainer
onready var game = get_tree().get_root().get_node("Game")


func _ready():
	set_process_input(true)
	set_process(true)


func _input(event):
	pass

func spawn_ability(ability, pos):
	game.dragged_ability = ability.instance()
	game.dragged_ability.set_pos(pos)
	game.dragged_ability.set_active(false)
	game.get_node("Effects").add_child(game.dragged_ability)

func _on_Ability1_button_down():
	var pos = get_node("Ability1").get_global_pos() + Vector2(get_node("Ability1").get_size() / 2)
	spawn_ability(game.targeted_heal, pos)


func _on_Ability2_button_down():
	var pos = get_node("Ability2").get_global_pos() + Vector2(get_node("Ability2").get_size() / 2)
	spawn_ability(game.area_heal, pos)


func _on_Ability3_button_down():
	var pos = get_node("Ability3").get_global_pos() + Vector2(get_node("Ability3").get_size() / 2)
	spawn_ability(game.chain_heal, pos)
