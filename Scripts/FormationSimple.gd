extends Node2D

var LEADER_SIGHT_RADIUS = 30
var AHEAD_LENGTH = 42
var leader = 0
var formation_scale = 1 setget set_scale, get_scale
var orientation = Vector2() setget set_orientation, get_orientation
var velocity = 50 setget set_velocity, get_velocity
var form_velocity = velocity * 1.5
var formations = {
	1:[Vector2(0, 0)],
	2:[Vector2(-25, 0), Vector2(25, 0)],
	3:[Vector2(0, 0), Vector2(-35, -25), Vector2(35, -25)],
	4:[Vector2(0, 0), Vector2(-30, -25), Vector2(30, -25), Vector2(0, -50)],
	5:[Vector2(0, 0), Vector2(-40, -25), Vector2(40, -25), Vector2(20, -60), Vector2(-20, -60)]
}
var formation_positions = []
var max_unit_count = 5
var registered_units = []
var formation_map = {0:false, 1:false, 2:false, 3:false, 4:false}

func set_scale(v):
	formation_scale = v

func get_scale():
	return formation_scale

func set_orientation(o):
	orientation = o

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
	if i >= 0 and i < formation_positions.size():
		return p + formation_positions[i].rotated(get_orientation().angle()) * get_scale()
	else:
		print("There's no formation position available for ", i, ".")
		return Vector2()

func get_leader_offset():
	return formation_positions[0].rotated(get_orientation().angle())

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

func _fixed_process(delta):
#	set_pos(get_pos() + (get_orientation() * velocity * delta))
	update()

func _ready():
	formation_map = {0:false, 1:false, 2:false, 3:false, 4:false}
	set_fixed_process(true)

func _draw():
	if Globals.get("debug_mode"):
		draw_set_transform(Vector2(), 0, Vector2(1, 1))
		for fp in formation_positions:
			draw_circle(fp.rotated(get_orientation().angle()) * get_scale(), 10, Color(0.8, 0.2, 0.2, 0.5))
		draw_line(Vector2(), get_orientation() * 30, Color(0.6, 0.6, 0.0), 2)
		draw_set_transform_matrix(get_global_transform().inverse())
		draw_line(get_global_pos(), get_ahead_pos(), Color(0.2, 0.8, 0.5), 1)
