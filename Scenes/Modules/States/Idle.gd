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
	brain.owner.set_target(
		actorbasemodule.get_closest_enemy(SEEK_DIST * 6)
	)
