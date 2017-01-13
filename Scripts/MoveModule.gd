tool
extends Node2D

var direction = Vector2(0, 0)
export(bool) var AVOID_COLLISION = false setget set_avoid_collision, get_avoid_collision
export(float, 0, 1, 0.1) var AVOID_FORCE = 0.5 setget set_avoid_force, get_avoid_force
export(float, 1, 128, 0.5) var RAYCAST_LENGTH = 60.0 setget set_raycast_length, get_raycast_length
export(float, 0, 1, 0.1) var STALL_TRESHOLD
signal stalled
var parent = null
var raycast = null

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

func get_raycast_length():
	return RAYCAST_LENGTH

func _ready():
	parent = get_parent()
	setup_raycast()
	update(0)

func update(dt):
	update_raycast()
	var dir = direction
	if AVOID_COLLISION:
		dir = steer(dir)
	move(dir)

func move(dir):
	parent.move_and_slide(dir)

func setup_raycast():
	raycast = get_node("RayCast2D")
	raycast.set_enabled(true)
	raycast.add_exception(parent)
	raycast.set_pos(parent.get_body_pos())

func update_raycast():
	var v = get_direction() * RAYCAST_LENGTH
	raycast.set_cast_to(v)

func steer(dir):
	return dir
