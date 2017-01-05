extends KinematicBody2D

onready var root = get_tree().get_root().get_node("Game")
var death_effect = preload("res://Scenes/Effects/DeathEffect.tscn")
var stats = null
var target_enemy = null
var target_enemy_path = null
var direction = Vector2(0, 0)
var flip_cd = 0.0
var idle_time = 0.0
var idle = false
var path = []

func _ready():
	set_process(true)
	if get_node("StatsModule"):
		stats = get_node("StatsModule")
		root.get_node("HUD").add_hpbar(self)
	if get_node("Selected"):
		get_node("Selected").set_texture_offset(get_node("CollisionShape2D").get_pos())

func _process(dt):
	check_death()
	check_target()
	if path.size():
#		stats.get("movement_speed")
		set_direction((path[0] - get_pos()).normalized())
		if get_pos().distance_to(path[0]) < 1.0:
			path.remove(0)
	elif target_enemy:
		set_direction((target_enemy.get_pos() - get_pos()).normalized())
	else:
		check_in_range()


	var rotate_angle = 0
	if target_enemy.get_pos().y > get_pos().y:
		rotate_angle = 45
	else:
		rotate_angle = -45
	if direction.x < 0:
		rotate_angle *= -1

	if idle:
		idle_time += dt
		if idle_time > 1.0:
			check_in_range()
		if idle_time > 0.5:
#			var nudge_dir = randf()
			set_direction((target_enemy.get_pos() - get_pos()).normalized().rotated(deg2rad(rotate_angle)))
	else:
		if idle_time > 0:
			idle_time -= dt
			set_direction((target_enemy.get_pos() - get_pos()).normalized().rotated(deg2rad(rotate_angle)))
		else:
			idle_time = 0

	# set_rot(direction.angle() - deg2rad(90))
	var movement = direction * stats.get("base_movement_speed") * dt
	var moved = move(movement)
	if moved.length() < movement.length() / 10:
		on_walk()
	else:
		on_idle()
	
	if flip_cd > 0.0:
		flip_cd -= dt
	update_state()
	
	set_z(get_pos().y)

func set_direction(dir):
	direction = dir

func check_target():
	var ar = get_node("AttackRange/CollisionShape2D").get_shape().get_radius()
	if target_enemy:
		if not root.get_node("Actors").has_node(target_enemy_path):
			target_enemy = null
	if target_enemy:
		if get_pos().distance_to(target_enemy.get_pos()) < ar:
			clear_path()
			on_idle()
		elif get_pos().distance_to(target_enemy.get_pos()) < 250:
			clear_path()
	else:
		check_in_range()

func check_death():
	if stats.get("hp") <= 0:
		on_death()

func check_in_range():
	var ar = get_node("AttackRange/CollisionShape2D").get_shape().get_radius()
	var target = "enemy"
	if "enemy" in get_groups():
		target = "friendly"
	target_enemy = get_closest_enemy(get_tree().get_nodes_in_group(target))
	if target_enemy:
		target_enemy_path = target_enemy.get_path()
		if get_pos().distance_to(target_enemy.get_pos()) > ar:
			path = root.get_node("TestMap").get_simple_path(get_pos(), target_enemy.get_pos())
	else:
		target_enemy_path = null

func get_closest_enemy(enemies):
	var closest_candidate = null
	var closest = 1000
	for e in enemies:
		var dist = abs(e.get_pos().distance_to(get_pos()))
		if e == target_enemy:
			pass
		elif dist < closest:
			closest = dist
			closest_candidate = e
	return closest_candidate

func clear_path():
#	var p2d = get_node("Path2D")
#	for i in range(p2d.get_point_count()):
#		p2d.remove_point(i)
	path = []

func set_path(p):
	path = p

func on_heal():
	get_node("EffectPlayer").play("Heal")

func on_death():
	print("Died.")
	var de = death_effect.instance()
	de.set_pos(get_pos())
#	de.get_node("Sprite").set_texture(get_node("DeathSprite").get_texture())
	root.get_node("Effects").add_child(de)
	queue_free()

func on_idle():
	idle = true
	if not get_node("AnimationPlayer").get_current_animation() == "idle":
		get_node("AnimationPlayer").play("idle")

func on_walk():
	idle = false
	if not get_node("AnimationPlayer").get_current_animation() == "walk":
		get_node("AnimationPlayer").play("walk")

func update_state():
	if flip_cd <= 0.0:
		flip_cd = 0.3
		if target_enemy:
			if target_enemy.get_pos().x > get_pos().x:
				get_node("Sprite").set_flip_h(false)
			else:
				get_node("Sprite").set_flip_h(true)
		else:
			if direction.x > 0:
				get_node("Sprite").set_flip_h(false)
			elif direction.x < 0:
				get_node("Sprite").set_flip_h(true)

func _on_AttackRange_body_enter( body ):
	if target_enemy:
		if root.get_node("Actors").has_node(target_enemy_path):
			var r = get_node("AttackRange/CollisionShape2D").get_shape().get_radius()
			if get_pos().distance_to(target_enemy.get_pos()) <= r:
				return
	var target_group = "enemy"
	if "enemy" in get_groups():
		target_group = "friendly"
	if target_group in body.get_groups():
		clear_path()
		target_enemy = body
		target_enemy_path = body.get_path()
