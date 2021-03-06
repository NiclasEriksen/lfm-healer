extends Node2D
export(float) var flytime = 0.5
var flown = 0.0
var start_pos = Vector2(0, 0)
var target = null
var target_pos = Vector2(0, 0)
var effect_module = null
var dot_module = null
var alliance = null
var explode_effect = load("res://Scenes/Effects/ExplodeEffect.tscn")
export(Vector2) var y_offset = Vector2(0, 0)
var owner = null setget set_owner, get_owner

func set_owner(o):
	owner = weakref(o)

func get_owner():
	return owner.get_ref()

func _ready():
	set_fixed_process(true)

func _fixed_process(dt):
	if flown >= flytime:
		if target:
			if target.get_ref():
				if effect_module and alliance:
					if effect_module.get_ref():
						var om = get_owner().stats_node
						var targets = get_node("Area2D").get_overlapping_bodies()
						var blast_targets = get_node("BlastZone").get_overlapping_bodies()
						for target in blast_targets:
							if alliance in target.get_groups():
								pass
							else:
								if target.has_node("StatsModule"):
									var em = effect_module.get_ref().duplicate()
									if not target in targets:
										em.set_amount(em.get_amount() / 2)
									target.get_node("StatsModule").apply_effect(em, om)
									if dot_module:
										var dm = dot_module.get_ref().duplicate()
										target.get_node("StatsModule").apply_effect(dm, om)
	if flown < flytime:
		fly(dt)
	else:
		explode(get_pos())
		queue_free()


func explode(p):
	var ef = explode_effect.instance()
	ef.set_pos(p)
	if target.get_ref():
		ef.set_z(target.get_ref().get_z())

	get_tree().get_root().get_node("Game/Effects").add_child(ef)

func init(t, em, dm):
#	var a = (t.get_pos() - get_pos()).angle() + PI / 2
#	get_node("Sprite").set_rot(a)
	start_pos = get_pos()
	target_pos = t.get_pos()
	target = weakref(t)
	if has_node("Trail"):
		get_node("Trail").set_emit_timeout(flytime / 2)
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
	var a = (target_pos - start_pos).angle() + PI + cos(x_osc) * (PI / 12) + PI / 2
	set_rot(a)

	set_pos(newpos)
	set_z(newpos.y)

	flown += dt
