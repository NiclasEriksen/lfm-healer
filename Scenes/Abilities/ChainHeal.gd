extends Node2D
var targets = []
var active = false
onready var hud = get_tree().get_root().get_node("Game").get_node("HUD")
var healeffect = load("res://Scenes/Effects/HealEffect2.tscn")
export var max_jump_range = 200
export var max_jumps = 3
var slot = 0

func get_slot():
	return slot

func set_slot(s):
	slot = s

func _ready():
	set_process(true)

func get_target():
	var candidates = get_node("Area2D").get_overlapping_bodies()
	var closest_candidate = null
	var closest = 500
	for f in candidates:
		if f.is_in_group("friendly"):
			var dist = abs(f.get_pos().distance_to(get_pos()))
			if dist < closest:
				closest = dist
				closest_candidate = f
	return closest_candidate

func get_chain(start_target):
	var last_target = start_target
	var chain_targets = []
	chain_targets.append(start_target)
	var friendlies = get_tree().get_nodes_in_group("friendly")
	var jumps = 0
	while jumps < max_jumps:
		var closest = max_jump_range
		var candidate = null
		for friend in friendlies:
			if not friend in chain_targets:
				if not friend.get_node("ActorBase").healthy:
					var dist = abs(friend.get_pos().distance_to(last_target.get_pos()))
					if dist <= max_jump_range and dist < closest:
						closest = dist
						candidate = friend
		if candidate:
			last_target = candidate
			chain_targets.append(candidate)
			jumps += 1
		else:
			break
	return chain_targets

func _process(delta):
	if active:
		var target = get_target()
		if target:
			targets = get_chain(target)
		else:
			targets = []
		var points = []
		for t in targets:
			points.append(t.get_global_pos())
			t.get_node("ActorBase").get_node("Selected").set_enabled(true)
#		hud.update()
		hud.draw_lines(points, Color(0.2,0.9,0.1,0.5))

func set_active(val):
#	get_node("Particles2D").set_emitting(val)
#	get_node("Particles2D2").set_emitting(val)
	if val:
		get_node("Sprite").show()
	else:
		get_node("Sprite").hide()
	active = val

func trigger():
	var target = get_target()
	if target:
		targets = get_chain(target)
	else:
		targets = []
	for target in targets:
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
	hud.clear_lines()
	queue_free()
