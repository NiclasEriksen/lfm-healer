extends RigidBody2D

onready var root = get_tree().get_root().get_node("Game")
var stats = null
var target_enemy = null
var target_enemy_path = null
var path = []

func _ready():
	set_process(true)
	if get_node("StatsModule"):
		stats = get_node("StatsModule")
		root.get_node("HUD").add_hpbar(self)

func _process(dt):
	check_death()
	check_target()
	if path.size():
#		stats.get("movement_speed")
		testmove((path[0] - get_pos()).normalized() * stats.get("base_movement_speed") * dt)
		if get_pos().distance_to(path[0]) < 1.0:
			path.remove(0)
	else:
		teststop()
		check_in_range()

func check_target():
	if target_enemy:
		if not root.get_node("Actors").has_node(target_enemy_path):
			target_enemy = null
	if target_enemy:
		if get_pos().distance_to(target_enemy.get_pos()) < 50:
			teststop()
	else:
		check_in_range()

func check_death():
	if stats.get("hp") <= 0:
		queue_free()

func check_in_range():
	var ar = 50
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
		if dist < closest:
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
	get_node("AnimationPlayer").play("Heal")

func testmove(dir):
	if dir.x > 0:
		get_node("Sprite").set_flip_h(false)
	elif dir.x < 0:
		get_node("Sprite").set_flip_h(true)
	if dir.x or dir.y:
		if not get_node("AnimationPlayer").get_current_animation() == "walk":
			get_node("AnimationPlayer").play("walk")
		set_pos(get_pos() + dir)
	else:
		if not get_node("AnimationPlayer").get_current_animation() == "idle":
			get_node("AnimationPlayer").play("idle")

func teststop():
	clear_path()
	if not get_node("AnimationPlayer").get_current_animation() == "idle":
		get_node("AnimationPlayer").play("idle")

