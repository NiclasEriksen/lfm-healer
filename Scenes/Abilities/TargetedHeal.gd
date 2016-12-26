extends Node2D

func _ready():
	pass

func trigger():
	for f in get_node("Area2D").get_overlapping_bodies():
		if f.get_node("StatsModule"):
			f.get_node("StatsModule").apply_effect(get_node("EffectModule"), null)
	queue_free()
