extends Node2D

var LEADER_SIGHT_RADIUS = 24
var AHEAD_LENGTH = 32
var RC_MARGIN = 8
var leader = 0
var min_scale = Vector2(0.5, 0.5)
var max_scale = Vector2(2, 1.5)
var default_scale = Vector2(0.85, 0.85)
var formation_size = Vector2(100, 100)
var formation_scale = default_scale setget set_scale, get_scale
var orientation = Vector2() setget set_orientation, get_orientation
var velocity = 50 setget set_velocity, get_velocity
var form_velocity = velocity * 1.5
var formations = {
	1:[Vector2(0, 0)],
	2:[Vector2(-0.25, 0), Vector2(0.25, 0)],
	3:[Vector2(0, 0), Vector2(-0.35, -0.25), Vector2(0.35, -0.25)],
	4:[Vector2(0, 0), Vector2(-0.30, -0.25), Vector2(0.30, -0.25), Vector2(0, -0.50)],
	5:[Vector2(0, 0), Vector2(-0.40, -0.25), Vector2(0.40, -0.25), Vector2(0.20, -0.60), Vector2(-0.20, -0.60)]
}
var formation_positions = []
var max_unit_count = 5
var registered_units = []
var formation_map = {0:false, 1:false, 2:false, 3:false, 4:false}
onready var rc_left = get_node("RayCastLeft")
onready var rc_right = get_node("RayCastRight")
var RAYCAST_LENGTH = 50

func set_scale(v):
	formation_scale = v

func get_scale():
	return formation_scale

func set_orientation(o):
	orientation = o
	if rc_left and rc_right:
		rc_left.set_cast_to(o * RAYCAST_LENGTH)
		rc_right.set_cast_to(o * RAYCAST_LENGTH)
#		rc_left.set_rot(o.angle())
#		rc_right.set_rot(o.angle())

func get_orientation():
	return orientation

func set_velocity(v):
	velocity = v
	form_velocity = v * 1.5

func get_velocity():
	return velocity

func get_form_velocity():
	return form_velocity

func get_unit_count():
	var counter = 0
	for p in formation_map:
		if formation_map[p]:
			counter += 1
	return counter

func set_leader(i):
	leader = i

func is_leader(i):
	return leader == i

func get_leader_pos():
	return get_formation_pos(0)

func get_ahead_pos():
	return get_pos() + get_orientation() * AHEAD_LENGTH

func is_in_the_way(u):
	return get_ahead_pos().distance_to(u.get_pos()) <= LEADER_SIGHT_RADIUS or (get_global_pos() + get_leader_offset()).distance_to(u.get_pos()) <= LEADER_SIGHT_RADIUS

func get_formation_pos(i):
	var p = get_global_transform()[2]
	var angle = get_orientation().angle()
	if i >= 0 and i < formation_positions.size():
		return p + (formation_positions[i] * formation_size * get_scale()).rotated(angle)
	else:
		print("There's no formation position available for ", i, ".")
		return Vector2()

func get_leader_offset():
	return (formation_positions[0] * formation_size * get_scale()).rotated(get_orientation().angle())

func lookup_formation_pos(i):
	if i == leader:
		return get_formation_pos(0)
	var counter = 1
	for p in formation_map:
		if formation_map[p]:
			if p == leader:
				continue
			if i == p:
				return get_formation_pos(counter)
			counter += 1
	return Vector2()

func register_unit():
	for p in formation_map:
		if not formation_map[p]:
			formation_map[p] = true
			if get_unit_count() == 1:
				leader = p
			select_formation()
			return p
	print("No more room!")
	return -1

func unregister_unit(i):
	formation_map[i] = false
	if i == leader:
		if get_unit_count() > 0:
			for f in formation_map:
				if formation_map[f]:
					leader = f
					break
		else:
			print("No unit to give leader to.")
	select_formation()

func select_formation():
	var c = get_unit_count()
	if formations.has(c):
		formation_positions = formations[c]
	else:
		print("No formation for ", c, " units.")

func adjust_shape(dt):
	var new_scale = get_scale()
	if rc_left.is_colliding() or rc_right.is_colliding():
		if new_scale.x > min_scale.x:
			new_scale *= Vector2(1 - 0.1 * dt, 1)
		else:
			new_scale.x = min_scale.x
		if new_scale.y < max_scale.y:
			new_scale *= Vector2(1, 1 + 0.1 * dt)
		else:
			new_scale.y = max_scale.y
		set_scale(new_scale)
	else:
		if new_scale.x < default_scale.x:
			new_scale *= Vector2(1 + 0.03 * dt, 1)
		else:
			new_scale.x = default_scale.x
		if new_scale.y > default_scale.y:
			new_scale *= Vector2(1, 1 - 0.03 * dt)
		else:
			new_scale.y = default_scale.y
		set_scale(new_scale)

func adjust_raycasts():
	var left_most = Vector2()
	var right_most = Vector2()
	for fp in formation_positions:
		if fp.x < left_most.x:
			left_most = fp
		elif fp.x > right_most.x:
			right_most = fp
	var angle = get_orientation().angle()
	var lm = (left_most * formation_size * get_scale() - Vector2(RC_MARGIN, 0)).rotated(angle)
	var rm = (right_most * formation_size * get_scale() + Vector2(RC_MARGIN, 0)).rotated(angle)
	rc_left.set_pos(lm)
	rc_right.set_pos(rm)

func _fixed_process(delta):
#	set_pos(get_pos() + (get_orientation() * velocity * delta))
	if rc_left and rc_right:
		adjust_raycasts()
		adjust_shape(delta)
	update()

func _ready():
	formation_map = {0:false, 1:false, 2:false, 3:false, 4:false}
	set_fixed_process(true)

func _draw():
	if Globals.get("debug_mode"):
		draw_set_transform(Vector2(), 0, Vector2(1, 1))
		var rcl = get_node("RayCastLeft")
		var rcr = get_node("RayCastRight")
		var angle = get_orientation().angle()
		if rcl.is_colliding():
			draw_line(rcl.get_pos(), rcl.get_pos() + rcl.get_cast_to(), Color(0.8, 0.4, 0.8, 0.9), 3)
		else:
			draw_line(rcl.get_pos(), rcl.get_pos() + rcl.get_cast_to(), Color(0.3, 0.3, 0.9, 0.7), 2)
		if rcr.is_colliding():
			draw_line(rcr.get_pos(), rcr.get_pos() + rcr.get_cast_to(), Color(0.8, 0.4, 0.8, 0.9), 3)
		else:
			draw_line(rcr.get_pos(), rcr.get_pos() + rcr.get_cast_to(), Color(0.3, 0.3, 0.9, 0.7), 2)
		for fp in formation_positions:
			draw_circle((fp * formation_size * get_scale()).rotated(angle), 10, Color(0.8, 0.2, 0.2, 0.5))
		draw_line(Vector2(), get_orientation() * 30, Color(0.6, 0.6, 0.0), 2)
		draw_set_transform_matrix(get_global_transform().inverse())
		draw_line(get_global_pos(), get_ahead_pos(), Color(0.2, 0.8, 0.5), 1)
