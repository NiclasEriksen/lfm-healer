extends "res://Scenes/Modules/States/State.gd"

var ATTACK_DIST = 50

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func check_reqs():
	return (not statsmodule == null) and (not movemodule == null) and (not actorbasemodule == null)

func on_enter():
	ATTACK_DIST = statsmodule.get_actual("attack_range")

func update(dt):
	var target = brain.owner.get_target()
	if not target:
		brain.pop_state()
		return
	var p = brain.owner.get_body_pos()
	var tp = target.get_body_pos()
	var dist = p.distance_to(tp)
	if dist > ATTACK_DIST:
		brain.push_state("seek_target")
	else:
		brain.owner.attack(target)
