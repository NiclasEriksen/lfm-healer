extends "res://Scenes/Modules/States/State.gd"
var EVADE_MIN = 128

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func update(dt):
	var target = brain.owner.get_target()
	if not target:
		brain.pop_state()
		return
	if brain.owner.get_body_pos().distance_to(target.get_body_pos()) < EVADE_MIN:
		movemodule.set_direction(movemodule.flee(target.get_body_pos()).normalized())
		movemodule.move(movemodule.get_direction() * 1.5, dt)
	else:
		brain.owner.set_target(null)
		brain.pop_state()
