extends Node

var movemodule = null
var statsmodule = null
var actorbasemodule = null
var brain = null
var name = ""

func check_reqs():
	return (not statsmodule == null) and (not movemodule == null) and (not actorbasemodule == null)

func on_enter():
	pass

func _ready():
	pass
