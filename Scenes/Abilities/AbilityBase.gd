extends Node2D

var active = false
var slot = 0
var z_offset = 0

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func get_slot():
	return slot

func set_slot(s):
	slot = s

func _ready():
	if has_node("Area2D/CollisionShape2D"):
		z_offset = get_node("Area2D/CollisionShape2D").get_shape().get_radius()
	set_process(true)

func _process(dt):
	if active:
		set_z(get_pos().y + z_offset)

func set_active(val):
	if val:
		get_node("Sprite").show()
	else:
		get_node("Sprite").hide()
	active = val

func get_game_pos(p):
	var t = get_tree().get_root().get_node("Game/Camera2D").get_global_transform()
	return t.xform(get_pos())
