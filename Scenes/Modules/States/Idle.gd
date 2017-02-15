extends "res://Scenes/Modules/States/State.gd"
var SEEK_DIST = 180

func _ready():
	pass

func check_reqs():
	return (not actorbasemodule == null) and (not movemodule == null)

func on_enter():
	pass

func update(dt):
	var t = brain.owner.get_target()
	if t:
		brain.push_state("attack")
		return
	t = actorbasemodule.get_closest_enemy(SEEK_DIST * 2)
	if t:
		brain.owner.set_target(
			actorbasemodule.get_closest_enemy(SEEK_DIST * 2)
		)
		return
	if brain.owner.is_leader():
		var p = brain.owner.get_tree().get_root().get_node("Game").get_path_to_end(brain.owner.get_body_pos())
		movemodule.set_walk_path(p)
		brain.push_state("follow_path")
