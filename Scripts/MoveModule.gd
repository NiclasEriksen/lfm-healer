tool
extends Node2D

var direction = Vector2(0, 0)
export(bool) var AVOID_COLLISION = false setget set_avoid_collision, get_avoid_collision
export(float, 0, 1, 0.1) var AVOID_FORCE = 0.5 setget set_avoid_force, get_avoid_force
export(float, 1, 128, 1) var RAYCAST_LENGTH = 30.0 setget set_raycast_length, get_raycast_length
export(float, 0, 1, 0.1) var STALL_TRESHOLD = 0.1 setget set_stall_treshold, get_stall_treshold
export(float) var PATH_REACH_TRESHOLD = 16.0 setget set_reach_treshold, get_reach_treshold
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
	set_fixed_process(true)

func _draw():
	if Globals.get("debug_mode") and not get_tree().is_editor_hint():
		draw_line(Vector2(0, 0), (steer(get_direction()) * 30), Color(0.2, 0.9, 0.1), 2.0)
		draw_line(Vector2(0, 0), (get_direction() * 30), Color(0.8, 0.4, 0.1), 3.0)
		if raycast:
			var col = Color(1, 0.7, 0.7)
			if raycast.is_colliding():
				col = Color(1, 0.4, 0.4)
			draw_line(raycast.get_pos(), raycast.get_cast_to(), col)
		if path.size():
			var start = Vector2(0, 0)
			for p in path:
				var p_rel = (p - parent.get_body_pos())
				draw_line(start, p_rel, Color(0.3, 0.3, 0.3, 0.5), 3.0)
				start = p_rel

func _fixed_process(dt):
	if parent:
		if parent.has_node("StatsModule") and not get_tree().is_editor_hint():
			if parent.get_node("StatsModule").is_stunned():
				return
		if parent.has_node("ActorBase"):
			if parent.get_node("ActorBase").attacking:
				return
		update_raycast()
		var dir = direction
		if target:
			set_walk_path([])
			dir = seek_target(target)
		elif path.size():
			dir = check_path(dir)
		set_direction(dir)
		if AVOID_COLLISION:
			dir = steer(dir)
		if not get_tree().is_editor_hint():
			move(dir, dt)
			parent.set_z(parent.get_body_pos().y)

func move(dir, dt):
	if stats:
		dir *= get_node(get_stat_node()).get_actual("movement_speed") * 10 * dt
	else:
		dir *= BASE_MOVEMENT_SPEED * dt

	if parent:
		var moved = parent.move_and_slide(dir)
		if moved.length() > dir.length() * STALL_TRESHOLD:
			emit_signal("moved")
		else:
			emit_signal("stalled")
	update()

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

func check_path(dir):
	var current_pos = get_global_pos()
	if parent:
		current_pos = parent.get_body_pos()
	if current_pos.distance_to(path[0]) <= PATH_REACH_TRESHOLD:
		path.remove(0)
	if path.size():
		return (path[0] - current_pos).normalized()
	print("No path.")
	return Vector2(0, 0)

func seek_target(target):
	if not target.get_ref():
		target = null
		return Vector2(0, 0)
	var p = get_pos()
	if parent:
		p = parent.get_body_pos()
	return (target.get_ref().get_body_pos() - p).normalized()

func _on_ActorBase_targeted_enemy( enemy ):
	target = enemy
	if enemy.get_ref() and raycast:
		raycast.add_exception(enemy.get_ref())


func _on_ActorBase_cleared_target():
	if target.get_ref() and raycast:
		raycast.remove_exception(target.get_ref())
	target = null
