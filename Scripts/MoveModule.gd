tool
extends Node2D

var direction = Vector2(0, 0)
export(bool) var AVOID_COLLISION = false setget set_avoid_collision, get_avoid_collision
var AVOID_FORCE = 0.4 setget set_avoid_force, get_avoid_force
export(float, 1, 128, 1) var RAYCAST_LENGTH = 30.0 setget set_raycast_length, get_raycast_length
export(float, 0, 1, 0.1) var STALL_TRESHOLD = 0.1 setget set_stall_treshold, get_stall_treshold
var SEEK_TRESHOLD = 100
var SLOW_RADIUS = 32
var max_velocity = 50
export(float) var PATH_REACH_TRESHOLD = 4.0 setget set_reach_treshold, get_reach_treshold
signal stalled
signal moved
var stalling = false
var parent = null
var target = null
var stats = null
export(NodePath) var stats_node = null setget set_stat_node, get_stat_node
export(float) var BASE_MOVEMENT_SPEED = 250 setget set_base_ms, get_base_ms
var raycast = null
var path = []


func set_direction(newdir):
	direction = newdir

func get_direction():
	return direction

func is_stalling():
	return stalling

func set_avoid_collision(val):
	AVOID_COLLISION = val

func get_avoid_collision():
	return AVOID_COLLISION

func set_avoid_force(val):
	AVOID_FORCE = val

func get_avoid_force():
	return AVOID_FORCE

func set_raycast_length(val):
	RAYCAST_LENGTH = val
	if raycast:
		update_raycast()

func get_raycast_length():
	return RAYCAST_LENGTH

func set_stall_treshold(val):
	STALL_TRESHOLD = val

func get_stall_treshold():
	return STALL_TRESHOLD

func set_reach_treshold(val):
	PATH_REACH_TRESHOLD = val

func get_reach_treshold():
	return PATH_REACH_TRESHOLD

func set_walk_path(p):
	path = p

func get_walk_path():
	if get_tree().is_editor_hint():
		return []
	else:
		return path

func set_stat_node(s):
	stats_node = s
	if s:
		if has_node(s):
			stats = get_node(s)

func get_stat_node():
	return stats_node

func set_base_ms(ms):
	BASE_MOVEMENT_SPEED = ms

func get_base_ms():
	return BASE_MOVEMENT_SPEED

func _ready():
	parent = get_parent()
	if stats_node:
		stats = get_node(stats_node)
	setup_raycast()
#	set_fixed_process(true)

func _draw():
	if Globals.get("debug_mode") and not get_tree().is_editor_hint():
		draw_line(Vector2(0, 0), (steer(get_direction()) * 30), Color(0.2, 0.9, 0.1), 2.0)
		draw_line(Vector2(0, 0), (get_direction() * 30), Color(0.8, 0.4, 0.1), 3.0)
		if raycast:
			var col = Color(1, 0.7, 0.7)
			if raycast.is_colliding():
				col = Color(1, 0.4, 0.4)
			draw_line(raycast.get_pos(), raycast.get_pos() + raycast.get_cast_to(), col)
		if path.size():
			var start = Vector2(0, 0)
			for p in path:
				var p_rel = (p - parent.get_body_pos())
				draw_line(start, p_rel, Color(0.3, 0.3, 0.3, 0.5), 3.0)
				start = p_rel

func move(dir, dt, vel=0):
	max_velocity = get_node(get_stat_node()).get_actual("movement_speed") * 10
	if vel:
		dir = dir.normalized() * vel
	elif stats:
		dir *= max_velocity * dt
	else:
		dir *= BASE_MOVEMENT_SPEED * dt

	if parent:
		var moving = true
		if parent.is_healer():
			if parent.is_casting():
				moving = false
				emit_signal("stalled")
		if moving:
			var moved = parent.move_and_slide(dir)
			if moved.length() > dir.length() * STALL_TRESHOLD:
				emit_signal("moved")
			else:
				emit_signal("stalled")
			parent.set_z(parent.get_body_pos().y)
			var party = parent.get_party()
			if party:
				if party.is_leader(parent.get_party_index()):
					party.set_pos(parent.get_body_pos() - party.get_leader_offset())
					party.set_orientation(dir.normalized())
	update()

func arrive(p):
	var desired_velocity = p - parent.get_body_pos()
	var dist = desired_velocity.length()
	if dist < SLOW_RADIUS:
		desired_velocity = desired_velocity.normalized() * max_velocity * (dist / SLOW_RADIUS)
	else:
		desired_velocity = desired_velocity.normalized() * max_velocity
	return desired_velocity

func evade(t, d):
	var distance = t - parent.get_body_pos()
	var ahead = distance.length() / max_velocity
	var future_pos = t + (d * max_velocity) * ahead
#	print(t, "   ", future_pos)
	return flee(future_pos)

func flee(p):
	var desired_velocity = (parent.get_body_pos() - p).normalized() * max_velocity
#	evade_vector = desired_velocity
#	return desired_velocity - get_direction()
	return desired_velocity

func setup_raycast():
	raycast = get_node("RayCast2D")
	raycast.set_enabled(true)
	raycast.add_exception(parent)
	raycast.set_pos(Vector2(0, 0))

func update_raycast():
	if raycast:
		var v = get_direction() * RAYCAST_LENGTH
		raycast.set_cast_to(v)
	else:
		print("No raycast to update")

func steer(dir):
	var adjusted_angle = Vector2()
	if not get_tree().is_editor_hint() and raycast:
		if raycast.is_colliding():
			var c = raycast.get_collider()
			if not c:
				return dir
			var a = Vector2(0, 0)
			var realpos = parent.get_body_pos() + raycast.get_cast_to()
			if c extends KinematicBody2D:
				a = realpos - c.get_body_pos()
			else:
				a = realpos - c.get_pos()
			a = a.normalized()
			adjusted_angle = (a * AVOID_FORCE).normalized()

	return (dir + adjusted_angle).normalized()

func _on_Actor_targeted_enemy( enemy ):
	target = weakref(enemy)
	if raycast:
		raycast.add_exception(enemy)

func _on_Actor_cleared_target(t):
	if not target:
		return
	if target.get_ref() and raycast:
		raycast.remove_exception(target.get_ref())
	target = null

func _on_Timer_timeout():
	update_raycast()
