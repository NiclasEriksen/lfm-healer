extends "res://Scenes/Modules/States/State.gd"

var SEEK_DIST = 150
var ATTACK_DIST = 50

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func check_reqs():
	return (not statsmodule == null) and (not movemodule == null) and (not actorbasemodule == null)

func on_enter():
	movemodule.set_walk_path([])
	if not brain.owner.get_target():
		brain.pop_state()

func update(dt):
	var target = brain.owner.get_target()
	if not target:
		brain.pop_state()
		return
	var p = brain.owner.get_body_pos()
	var dist = target.get_body_pos().distance_to(p)
	if dist > SEEK_DIST:
		movemodule.set_walk_path([])
		brain.push_state("follow_path")
	elif dist <= statsmodule.get_actual("attack_range"):
		brain.pop_state()
	else:
#		print("Seeking target, dist: ", dist)
		var dir = (target.get_body_pos() - p).normalized()
		movemodule.set_direction(dir)
		if movemodule.AVOID_COLLISION:
			dir = movemodule.steer(dir)
		movemodule.move(dir, dt)
