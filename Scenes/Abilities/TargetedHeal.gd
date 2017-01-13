extends Node2D
var target = null
var active = false
var healeffect = load("res://Scenes/Effects/HealEffect3.tscn")

func _ready():
	set_process(true)

func _process(delta):
	if active:
		set_target()

func set_target():
	var candidates = get_node("Area2D").get_overlapping_bodies()
	var closest_candidate = null
	var closest = 500
	for f in candidates:
		if not "friendly" in f.get_groups():
			continue
		var dist = abs(f.get_pos().distance_to(get_pos()))
		if dist < closest:
			closest = dist
			closest_candidate = f
	if closest_candidate:
		target = closest_candidate
		target.get_node("ActorBase").get_node("Selected").set_enabled(true)
	else:
		target = null


func set_active(val):
	get_node("Particles2D").set_emitting(val)
	get_node("Particles2D2").set_emitting(val)
	if val:
		get_node("Sprite").show()
	else:
		get_node("Sprite").hide()
	active = val

func trigger():
	set_target()
	if target:
		if target.get_node("StatsModule"):
			target.get_node(
				"StatsModule"
			).apply_effect(
				get_node("EffectModule"), null
				)
			target.get_node("ActorBase").on_heal()
			var he = healeffect.instance()
			he.set_pos(target.get_body_pos())
			he.set_z(target.get_z())
			get_tree().get_root().get_node("Game/Effects").add_child(he)
	queue_free()
