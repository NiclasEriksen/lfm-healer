extends Node2D
var targets = []
var active = false
var healeffect = load("res://Scenes/Effects/HealEffect1.tscn")

func _ready():
	set_process(true)

func _process(delta):
	if active:
		for target in get_node("Area2D").get_overlapping_bodies():
			if "friendly" in target.get_groups():
				target.get_node("ActorBase").get_node("Selected").set_enabled(true)

func set_active(val):
#	get_node("Particles2D").set_emitting(val)
#	get_node("Particles2D2").set_emitting(val)
	if val:
		get_node("Sprite").show()
	else:
		get_node("Sprite").hide()
	active = val

func trigger():
	targets = get_node("Area2D").get_overlapping_bodies()
	for target in targets:
		if "friendly" in target.get_groups():
			if target.has_node("StatsModule"):
				target.get_node(
					"StatsModule"
				).apply_effect(
					get_node("BuffModule"), null
					)
				target.get_node(
					"StatsModule"
				).apply_effect(
					get_node("EffectModule"), null
					)
				var he = healeffect.instance()
				he.set_pos(target.get_body_pos())
				he.set_z(target.get_z())
				get_tree().get_root().get_node("Game/Effects").add_child(he)

	queue_free()
