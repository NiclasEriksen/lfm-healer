tool
extends Node2D

export(Vector2) var size = Vector2(512, 288) setget set_size, get_size

func set_size(s):
	size = s
	if not get_tree():
		return
	if get_tree().is_editor_hint():
		get_node("TextureFrame").set_size(s)
		var m = get_node("TextureFrame").get_material()
		m.set_shader_param("screen_width", s.x)
		m.set_shader_param("screen_height", s.y)

func get_size():
	return size

func enable():
	pass

func disable():
	pass

func _ready():
	if get_tree().is_editor_hint():
		hide()
	else:
		show()

