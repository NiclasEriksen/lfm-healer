extends Node2D
export(float) var flytime = 0.5
var flown = 0.0
var start_pos = Vector2(0, 0)
var target = null
var target_pos = Vector2(0, 0)
var effect_module = null
var dot_module = null
var status_module = null
var alliance = null
var owner = null setget set_owner, get_owner
export(Vector2) var y_offset = Vector2(0, 0)

func set_owner(o):
	owner = weakref(o)

func get_owner():
	return owner.get_ref()

func _ready():
	set_fixed_process(true)

func _fixed_process(dt):
	if target:
		if target.get_ref():
			var target_node = target.get_ref()
			target_pos = target_node.get_body_pos()
			if flown >= flytime:
				var o = get_owner()
				var origin_module = null
				if o:
					origin_module = o.stats_node
				if effect_module:
					if effect_module.get_ref() and target_node.has_node("StatsModule"):
						target_node.get_node("StatsModule").apply_effect(effect_module.get_ref(), origin_module)
				if dot_module:
					if dot_module.get_ref() and target_node.stats_node:
						var dm = dot_module.get_ref().duplicate()
						if o:
							dm.set_unique_ref(o.get_instance_ID())
						target_node.stats_node.apply_effect(dm, origin_module)
				if status_module:
					if dot_module.get_ref() and target_node.stats_node:
						var dm = dot_module.get_ref().duplicate()
						if o:
							dm.set_unique_ref(o.get_instance_ID())

						target_node.get_node("StatsModule").apply_effect(dm, origin_module)

						# print("And doing dmg!")
				# print("There!")
	if flown < flytime:
		fly(dt)
	else:
		queue_free()


func init(t, em, dm):
	var a = (t.get_pos() - get_pos()).angle() + PI / 2
	get_node("Sprite").set_rot(a)
	start_pos = get_pos()
	target_pos = t.get_pos()
	target = weakref(t)
	if has_node("Trail"):
		get_node("Trail").set_emit_timeout(flytime * 0.75)
		get_node("Trail").set_lifetime(flytime / 2)
	effect_module = weakref(em)
	if dm:
		dot_module = weakref(dm)

func set_alliance(a):
	alliance = a

func fly(dt):
	var t = flown / flytime
	var newpos = start_pos + (target_pos - start_pos) * t
	var x_osc = PI * t
	var yoff = (sin(x_osc) * y_offset).rotated(newpos.angle())
	newpos -= yoff
	set_pos(newpos)
	set_z(newpos.y)
	var a = (target_pos - start_pos).angle() + PI + cos(x_osc) * (PI / 12) + PI / 2
	get_node("Sprite").set_rot(a)
	flown += dt