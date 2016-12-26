extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var dragged_ability = null
var targeted_heal = load("res://Scenes/Abilities/TargetedHeal.tscn")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	set_process_input(true)

func _process(dt):
	pass

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if not dragged_ability:
				dragged_ability = targeted_heal.instance()
				dragged_ability.set_pos(event.pos)
				get_node("Effects").add_child(dragged_ability)
			else:
				dragged_ability.trigger()
				dragged_ability = null
		
		if event.button_index == BUTTON_LEFT and not event.pressed:
			dragged_ability.trigger()
			dragged_ability = null
	elif event.type == InputEvent.MOUSE_MOTION:
		if dragged_ability:
			dragged_ability.set_pos(event.pos)


func _on_Timer_timeout():
	var friendlies = get_tree().get_nodes_in_group("friendly")
	for f in friendlies:
		if f.get_node("StatsModule"):
			f.get_node("StatsModule").apply_effect(get_node("EffectModule"), null)