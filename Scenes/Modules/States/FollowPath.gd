extends "res://Scenes/Modules/States/State.gd"

var SEEK_DIST = 150
var map = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func check_reqs():
	return (not statsmodule == null) and (not movemodule == null) and (not actorbasemodule == null)

func on_enter():
	map = brain.get_tree().get_root().get_node("Game/Map")
	if brain.owner.get_target():
		movemodule.set_walk_path(map.get_simple_path(brain.owner.get_body_pos(), brain.owner.get_target().get_body_pos()))
		return
	elif movemodule.get_walk_path().size():
		return
	brain.pop_state()

func update(dt):
	var target = brain.owner.get_target()
	var p = brain.owner.get_body_pos()
	if target:
		var tp = target.get_body_pos()
		var dist = p.distance_to(tp)
		if dist <= SEEK_DIST:
			brain.pop_state()
			return
	if not movemodule.get_walk_path().size():
		brain.pop_state()
		return
	movemodule.set_direction(check_path())
	movemodule.move(movemodule.get_direction(), dt)

func check_path():
	var current_pos = brain.owner.get_body_pos()
	var path = movemodule.get_walk_path()
	if current_pos.distance_to(path[0]) <= movemodule.PATH_REACH_TRESHOLD:
		path.remove(0)
	movemodule.set_walk_path(path)
	if path.size():
		return (path[0] - current_pos).normalized()
	return movemodule.get_direction()
