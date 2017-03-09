extends Node2D

var active = false
export(int, 0, 3) var slot = 0
export(float, 0, 60, 0.1) var cooldown = 0.5
export(float, 0, 500) var cost = 0 setget set_cost, get_cost
export(int, 25, 500) var cast_range = 200
export(String, "target", "instant") var ability_type = "target"
var z_offset = 0
var prev_highlighted = []
export(Texture) var ability_icon = null setget set_icon, get_icon

func set_cost(v):
	cost = v

func get_cost():
	return cost

func get_cooldown():
	return cooldown

func set_icon(tex):
	ability_icon = tex

func get_icon():
	return ability_icon

func get_slot():
	return slot

func set_slot(s):
	slot = s

func trigger():
	pass

func _ready():
	if has_node("Area2D/CollisionShape2D"):
		z_offset = get_node("Area2D/CollisionShape2D").get_shape().get_radius()
	set_process(true)
	set_fixed_process(true)
	
func _fixed_process(delta):
	for a in prev_highlighted:
		if a.get_ref():
			a.get_ref().queue_set_highlighted(false)
			print("queueing")
		prev_highlighted.erase(a)

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
