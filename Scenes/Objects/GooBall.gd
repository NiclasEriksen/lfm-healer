extends Node2D
export(float) var flytime = 1
var flown = 0.0
var start_pos = Vector2(-6, -48)
var target = null
var target_pos = Vector2(0, 0)
var effect_module = null
var dot_module = null
var status_module = null
var explode_effect = load("res://Scenes/Effects/PoisonSplash.tscn")
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
				if effect_module:
					if effect_module.get_ref() and target.get_ref().has_node("StatsModule"):
						target.get_ref().get_node("StatsModule").apply_effect(effect_module.get_ref(), null)
				if dot_module:
					if dot_module.get_ref() and target.get_ref().has_node("StatsModule"):
						var dm = dot_module.get_ref().duplicate()
						if owner.get_ref():
							dm.set_unique_ref(owner.get_ref().get_instance_ID())
						target.get_ref().get_node("StatsModule").apply_effect(dm, null)
				if status_module:
					if dot_module.get_ref() and target.get_ref().has_node("StatsModule"):
						var dm = dot_module.get_ref().duplicate()
						if owner.get_ref():
							dm.set_unique_ref(owner.get_ref().get_instance_ID())

						target.get_ref().get_node("StatsModule").apply_effect(dm, null)

						# print("And doing dmg!")
				# print("There!")
	if flown < flytime:
		fly(dt)
	else:
		explode(get_pos())
		queue_free()


func init(t, em, dm):
	var a = (t.get_pos() - get_pos()).angle() + PI / 2
	get_node("Sprite").set_rot(a)
	start_pos += get_pos()
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

func explode(p):
	var ef = explode_effect.instance()
	ef.set_pos(p)
	if target.get_ref():
		ef.set_z(target.get_ref().get_z())

	get_tree().get_root().get_node("Game/Effects").add_child(ef)

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