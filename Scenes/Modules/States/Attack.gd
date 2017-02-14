extends "res://Scenes/Modules/States/State.gd"

var attack_dist = 50
var attack_cd	= 0.5

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func check_reqs():
	return (not statsmodule == null) and (not movemodule == null) and (not actorbasemodule == null)

func on_enter():
	pass
#	attack_dist = statsmodule.get_actual("attack_range")
#	attack_speed = statsmodule.get_actual("attack_speed")

func update(dt):
	var attack_dist = statsmodule.get_actual("attack_range")
	var attack_speed = statsmodule.get_actual("attack_speed")
	var target = brain.owner.get_target()
	var stunned = statsmodule.is_stunned()
	if not target:
		brain.pop_state()
		return
	var p = brain.owner.get_body_pos()
	var tp = target.get_body_pos()
	var dist = p.distance_to(tp)
	if dist > attack_dist:
		brain.push_state("seek_target")
	else:
		if attack_cd <= 0 and not stunned:
			brain.owner.attack(target)
			attack_cd = attack_speed
		else:
			attack_cd -= dt

