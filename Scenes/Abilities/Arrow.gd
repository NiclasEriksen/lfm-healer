extends Node2D
export(float) var flytime = 0.5
var flown = 0.0
var start_pos = Vector2(0, 0)
var target = null
var effect_module = null
export(Vector2) var y_offset = Vector2(0, 0)

func _ready():
	set_process(true)

func _process(dt):
	if target:
		if target.get_ref():
			var target_node = target.get_ref()
			if flown < flytime:
				var target_pos = target_node.get_pos()
				var t = flown / flytime
				var newpos = start_pos + (target_pos - start_pos) * t - (1 - abs(cos(t * PI))) * y_offset
				set_pos(newpos)
				var a = get_pos().angle_to(target_pos)
				get_node("Sprite").set_rot(a)
				flown += dt
			else:
				if effect_module:
					if effect_module.get_ref() and target.get_ref().has_node("StatsModule"):
						target.get_ref().get_node("StatsModule").apply_effect(effect_module.get_ref(), null)
						# print("And doing dmg!")
				# print("There!")
				queue_free()
		else:
			queue_free()
	else:
		queue_free()

func init(t, em):
	var a = get_pos().angle_to(t.get_pos())
	get_node("Sprite").set_rot(a)
	start_pos = get_pos()
	target = weakref(t)
	effect_module = weakref(em)

func fly():
	pass
