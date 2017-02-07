extends "res://Scenes/Modules/States/State.gd"

var SEEK_DIST = 180
var path = []

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func check_reqs():
	return (not statsmodule == null) and (not movemodule == null) and (not actorbasemodule == null)

func on_enter():
	pass

func update(dt):
	var target = brain.owner.get_target()
	if not target:
		brain.pop_state()
		return
	var tp = target.get_body_pos()
	var p = brain.owner.get_body_pos()
	var dist = p.distance_to(tp)
	if dist <= SEEK_DIST:
		brain.pop_state()
		return
	
