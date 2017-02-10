extends "res://Scenes/Abilities/AbilityBase.gd"
var targets = []
onready var hud = get_tree().get_root().get_node("Game").get_node("HUD")
var healeffect = load("res://Scenes/Effects/NatureHealEffect.tscn")
export var max_jump_range = 200
export var max_jumps = 3

func _ready():
	set_process(true)

func get_target():
	var candidates = get_node("Area2D").get_overlapping_bodies()
	var closest_candidate = null
	var closest = 100
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
			friend.set_highlighted(false)
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
		var friendlies = get_tree().get_nodes_in_group("friendly")
		for friend in friendlies:
			friend.set_highlighted(false)
		var target = get_target()
		if target:
			targets = get_chain(target)
		else:
			targets = []
		var points = []
		for t in targets:
			points.append(t.get_body_pos())
			t.set_highlighted(true)
#		hud.update()
		hud.draw_lines(points, Color(0.2,0.9,0.1,0.5))

func trigger():
	var targets_hit = false
	var target = get_target()
	if target:
		targets = get_chain(target)
	else:
		targets = []
	for target in targets:
		targets_hit = true
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
	return targets_hit
