extends "res://Scenes/Modules/States/State.gd"
var SEEK_DIST = 180



func _ready():
	pass

func check_reqs():
	return (not actorbasemodule == null)

func on_enter():
	pass

func update(dt):
	var t = brain.owner.get_target()
	if t:
		brain.push_state("attack")
		return
	var target_group = "enemy"
	if "enemy" in brain.owner.get_groups():
		target_group = "friendly"
	
	brain.owner.set_target(
		actorbasemodule.get_closest_enemy(brain.get_tree().get_nodes_in_group(target_group), SEEK_DIST * 6)
	)
