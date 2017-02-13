extends Node

var module_type = null
var origin_module = null

func set_origin_module(om):
	origin_module = weakref(om)

func get_origin_module(om):
	if origin_module:
		return origin_module.get_ref()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
