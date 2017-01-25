extends "res://Scenes/Abilities/AbilityBase.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	pass

func trigger():
	var se = get_node("StatusEffect")
	for f in get_tree().get_nodes_in_group("friendly"):
		if f.stats_node:
			f.stats_node.apply_effect(se.duplicate(), null)
	queue_free()
