extends Node2D
var targets = []
var active = false

func _ready():
	set_process(true)

func _process(delta):
	if active:
		targets = get_node("Area2D").get_overlapping_bodies()
		for target in targets:
			target.get_node("Selected").set_enabled(true)

func set_active(val):
#	get_node("Particles2D").set_emitting(val)
#	get_node("Particles2D2").set_emitting(val)
	if val:
		get_node("Sprite").show()
	else:
		get_node("Sprite").hide()
	active = val

func trigger():
	for target in targets:
		if target.get_node("StatsModule"):
			target.get_node(
				"StatsModule"
			).apply_effect(
				get_node("EffectModule"), null
				)
	queue_free()
