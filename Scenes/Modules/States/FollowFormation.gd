extends "res://Scenes/Modules/States/State.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func on_enter():
	movemodule.set_walk_path([])

func update(dt):
	var party = brain.owner.get_party()
	var ar = statsmodule.get_actual("attack_range") * 2
	var target = actorbasemodule.get_closest_enemy(ar)
	if target:
		brain.owner.set_target(target)
		if not brain.owner.is_healer():
			brain.push_state("attack")
		return
	
	if not party:
		brain.pop_state()
		return
	if party.is_leader(brain.owner.get_party_index()):
		brain.pop_state()
		return
#	movemodule.set_direction(party.get_orientation())
	var af = Vector2()
	if party.is_in_the_way(brain.owner):
		var leader_pos = party.get_leader_pos()
		af = movemodule.evade(leader_pos, party.get_orientation())
	var fp = party.lookup_formation_pos(brain.owner.get_party_index())
	var dist = fp - brain.owner.get_body_pos()
	var d = (dist.normalized() + af.normalized()).normalized()
	movemodule.set_direction(d)
	if dist.length() > 4:
		if dist.length() > 16:
			d = (movemodule.arrive(fp).normalized() + af.normalized()).normalized()
		d = movemodule.steer(d) * 2
#				move_and_slide(((d * formation.get_form_velocity())))
		movemodule.move(d, dt)
	else:
		movemodule.move(d, dt, dist.length())