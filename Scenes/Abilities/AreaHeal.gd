extends "res://Scenes/Abilities/AbilityBase.gd"
var targets = []
var healeffect = load("res://Scenes/Effects/HealEffect1.tscn")

func get_slot():
	return slot

func set_slot(s):
	slot = s

func _ready():
	var d = get_node("Area2D/CollisionShape2D").get_shape().get_radius() * 2
	var s = d / get_node("Sprite").get_texture().get_width()
	get_node("Sprite").set_scale(Vector2(s, s))
	set_process(true)

func _process(delta):
	if active:
		for f in get_tree().get_nodes_in_group("friendly"):
			f.set_highlighted(false)
		for target in get_node("Area2D").get_overlapping_bodies():
			if "friendly" in target.get_groups():
				target.set_highlighted(true)


func trigger():
	targets = get_node("Area2D").get_overlapping_bodies()
	var targets_hit = false
	for target in targets:
		if "friendly" in target.get_groups():
			target.set_highlighted(false)
			if target.has_node("StatsModule"):
				targets_hit = true
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
	return targets_hit
