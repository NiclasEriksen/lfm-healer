extends Node2D
var target = null
var active = false

func _ready():
	set_process(true)

func _process(delta):
	if active:
		var candidates = get_node("Area2D").get_overlapping_bodies()
		var closest_candidate = null
		var closest = 500
		for f in candidates:
			var dist = abs(f.get_pos().distance_to(get_pos()))
			if dist < closest:
				closest = dist
				closest_candidate = f
		if closest_candidate:
			target = closest_candidate
			target.get_node("Selected").set_enabled(true)
		else:
			target = null

func trigger():
	if target:
		if target.get_node("StatsModule"):
			target.get_node(
				"StatsModule"
			).apply_effect(
				get_node("EffectModule"), null
				)
	queue_free()
