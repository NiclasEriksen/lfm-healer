extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var dragged_ability = false
var targeted_heal = load("res://Scenes/Abilities/TargetedHeal.tscn")
onready var cam = get_node("Camera2D")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	set_process_input(true)

func _process(dt):
	var friendlies = get_tree().get_nodes_in_group("friendly")
	for f in friendlies:
		f.get_node("Selected").set_enabled(false)


func _input(event):
	#event = make_input_local(event)
	if event.type == InputEvent.SCREEN_TOUCH:
#		if event.pressed:
#			if not dragged_ability:
#				dragged_ability = targeted_heal.instance()
#				dragged_ability.set_pos(event.pos)
#				get_node("Effects").add_child(dragged_ability)
#			else:
#				dragged_ability.trigger()
#				dragged_ability = null
		
		if not event.pressed and dragged_ability:
			dragged_ability.trigger()
			dragged_ability = false
	elif event.type == InputEvent.SCREEN_DRAG:
		if dragged_ability:
			dragged_ability.set_pos(event.pos)


func _on_Timer_timeout():
	var friendlies = get_tree().get_nodes_in_group("friendly")
	for f in friendlies:
		if f.get_node("StatsModule"):
			f.get_node("StatsModule").apply_effect(get_node("EffectModule"), null)
