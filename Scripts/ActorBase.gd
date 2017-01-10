tool
extends Node2D

onready var root = get_tree().get_root().get_node("Game")
export(Texture) var spritesheet = null setget set_sprite_texture
var death_effect = preload("res://Scenes/Effects/DeathEffect.tscn")
onready var stats = get_parent().get_node("StatsModule")
onready var parent = get_parent()
signal attack
signal death(pos)
var target_enemy = null
var target_enemy_path = null
var healthy = true
var direction = Vector2(0, 0)
var attack_cd = 0.0
var flip_cd = 0.0
var state_change_cd = 0.0
var idle_time = 0.0
var idle = false
var attacking = false
var path = []

func _ready():
	if not get_tree().is_editor_hint():
		set_process(true)
		set_fixed_process(true)
		parent = get_parent()
		setup_raycast()
		check_los()
		if get_parent().get_node("StatsModule"):
			if Globals.get("debug_mode"):
				print("Statsmodule found.")
			stats = get_parent().get_node("StatsModule")
			var shape = CircleShape2D.new()
			shape.set_radius(stats.get_actual("attack_range"))
			get_node("AttackRange/CollisionShape2D").set_shape(shape)
			root.get_node("HUD").add_hpbar(get_parent())
		if get_node("Selected") and get_parent().get_node("CollisionShape2D"):
			get_node("Selected").set_texture_offset(get_parent().get_node("CollisionShape2D").get_pos())
#	if spritesheet:
#		get_node("Sprite").set_texture(spritesheet)

func _draw():
	if Globals.get("debug_mode") and not get_tree().is_editor_hint():
		draw_line(Vector2(0, 0), direction * 30, Color(0.8, 0.4, 0.1), 3.0)
		for rc in ["RayCast2DLeft", "RayCast2DCenter", "RayCast2DRight"]:
			draw_line(get_node(rc).get_pos(), get_node(rc).get_cast_to(), Color(1, 0.7, 0.7))
		if target_enemy:
			if root.get_node("Actors").has_node(target_enemy_path):
				var te_pos = target_enemy.get_pos() - parent.get_pos()
				var col = Color(0.1, 0.4, 0.9, 0.75)
				if "enemy" in parent.get_groups():
					col = Color(0.9, 0.1, 0.4, 0.75)
				draw_line(Vector2(0, 0), te_pos, col, 1.0)

func _process(dt):
	#get_node("AttackRange/CollisionShape2D").get_shape().set_radius(stats.get("base_attack_range"))
	if stats:
		check_death()
		check_healthy()
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

	if idle:
		idle_time += dt
		if idle_time > 2.0:
			idle_time = 0
			check_in_range()
	else:
		if idle_time > 0:
			idle_time -= dt
		else:
			idle_time = 0
	
	if flip_cd > 0.0:
		flip_cd -= dt
	if state_change_cd > 0.0:
		state_change_cd -= dt
	update_state()
	
	if not get_tree().is_editor_hint():
		if parent:
			parent.set_z(get_pos().y)
	if self.attack_cd <= 0:
		if self.attacking and self.target_enemy:
			self.attack_cd = 0.5
			if self.stats:
				self.attack_cd = self.stats.get_actual("attack_speed")
			emit_signal("attack", self.target_enemy)
	else:
		self.attack_cd -= dt

func _fixed_process(dt):
	if not attacking:
		var movement = direction
		if stats:
			movement *= stats.get_actual("movement_speed")
		else:
			movement *= 100
#		if not parent.test_move(parent.get_transform(), movement):
#			on_walk()
#		else:
#			on_idle()
#		if parent.test_move(parent.get_transform(), movement):
#			movement = movement.slide(parent.get_collision_normal())
#		if idle:
#			check_los()
		var moved = parent.move_and_slide(movement)
		if moved.length() > movement.length() / 5:
			on_walk()
		else:
			# check_los()
			parent.move_and_slide(direction * moved.length())
			on_idle()
	update()

func setup_raycast():
	for rc in ["RayCast2DLeft", "RayCast2DCenter", "RayCast2DRight"]:
		get_node(rc).add_exception(parent)
		get_node(rc).set_pos(parent.get_node("CollisionShape2D").get_pos())
		get_node(rc).add_exception(get_node("AttackRange/CollisionShape2D"))


func check_los():
	if not get_tree().is_editor_hint():
		var rcc = get_node("RayCast2DCenter")
		var rcl = get_node("RayCast2DLeft")
		var rcr = get_node("RayCast2DRight")
		var r = parent.get_node("CollisionShape2D").get_shape().get_radius()
		for rc in [rcc, rcl, rcr]:
			rc.set_enabled(true)
		for i in range(4):
			var angle = direction.angle() * 2 + PI / 8 * i
			var success = true
			rcl.set_pos((rcc.get_pos() - Vector2(r, 0).rotated(angle)))
			rcr.set_pos((rcc.get_pos() + Vector2(r, 0).rotated(angle)))
			rcc.set_cast_to((rcc.get_pos() + Vector2(0, 2*r).rotated(angle)))
			rcl.set_cast_to((rcl.get_pos() + Vector2(0, 2*r).rotated(angle)))
			rcr.set_cast_to((rcr.get_pos() + Vector2(0, 2*r).rotated(angle)))
			for rc in [rcl, rcc, rcr]:
				rc.force_raycast_update()
				if rc.is_colliding():
					success = false
					break
			if success:
				set_direction(Vector2(cos(angle), sin(angle)))
			else:
				success = true
				var opp_angle = -angle
				rcl.set_pos((rcc.get_pos() - Vector2(r, 0).rotated(opp_angle)))
				rcr.set_pos((rcc.get_pos() + Vector2(r, 0).rotated(opp_angle)))
				rcc.set_cast_to((rcc.get_pos() + Vector2(0, 2*r).rotated(opp_angle)))
				rcl.set_cast_to((rcl.get_pos() + Vector2(0, 3*r).rotated(opp_angle)))
				rcr.set_cast_to((rcr.get_pos() + Vector2(0, 3*r).rotated(opp_angle)))
				for rc in [rcl, rcc, rcr]:
					rc.force_raycast_update()
					if rc.is_colliding():
						success = false
						break
				if success:
					set_direction(Vector2(cos(angle), sin(angle)))
		rcc.set_enabled(false)
		rcl.set_enabled(false)
		rcr.set_enabled(false)

func test_angle(rc, a):
	var dir = direction.rotated(deg2rad(a)) * 50
	rc.set_cast_to(dir)
	rc.force_raycast_update()
	return not rc.is_colliding()

func set_sprite_texture(tex):
	spritesheet = tex
	if get_node("Sprite"):
		get_node("Sprite").set_texture(tex)

func set_direction(dir):
	direction = dir

func check_target():
	var ar = get_node("AttackRange/CollisionShape2D").get_shape().get_radius()
	if target_enemy:
		if not root.get_node("Actors").has_node(target_enemy_path):
			target_enemy = null
	if target_enemy:
		var dist = parent.get_pos().distance_to(target_enemy.get_pos())
		if dist < ar:
			clear_path()
			on_attack()
			# on_idle()
		elif dist < 400:
			attacking = false
			clear_path()
		else:
			attacking = false
	else:
		attacking = false
		check_in_range()

func check_death():
	if stats.get("hp") <= 0:
		on_death()
		emit_signal("death", parent.get_pos())

func check_healthy():
	if stats.get("hp") < stats.get("max_hp"):
		healthy = false
	else:
		healthy = true

func get_pos():
	if parent:
		return parent.get_pos()
	else:
		return Vector2(0, 0)

func move(v):
	if not get_tree().is_editor_hint():
		if parent:
			return parent.move(v)
	else:
		return Vector2(0, 0)

func check_in_range():
	if not get_tree().is_editor_hint():
		var ar = get_node("AttackRange/CollisionShape2D").get_shape().get_radius()
		var target = "enemy"
		if "enemy" in parent.get_groups():
			target = "friendly"
		target_enemy = get_closest_enemy(get_tree().get_nodes_in_group(target))
		if target_enemy:
			target_enemy_path = target_enemy.get_path()
			if get_pos().distance_to(target_enemy.get_pos()) > ar:
				path = root.get_node("Map").get_simple_path(get_pos(), target_enemy.get_pos())
		else:
			target_enemy_path = null

func get_closest_enemy(enemies):
	var closest_candidate = null
	var closest = 2000
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

func on_attack():
	attacking = true
	idle = false
	get_node("AnimationPlayer").play("idle")


func on_death():
	if Globals.get("debug_mode"):
		print(self, " died.")
	var de = death_effect.instance()
	de.set_pos(get_pos())
#	de.get_node("Sprite").set_texture(get_node("DeathSprite").get_texture())
	root.get_node("Effects").add_child(de)
	parent.queue_free()

func on_idle():
	idle = true
	if state_change_cd <= 0:
		if not get_node("AnimationPlayer").get_current_animation() == "idle" or not get_node("AnimationPlayer").get_current_animation() == "attack":
			get_node("Sprite").set_rot(0)
			get_node("AnimationPlayer").play("idle")
			state_change_cd = 0.3

func on_walk():
	idle = false
	if state_change_cd <= 0:
		if not get_node("AnimationPlayer").get_current_animation() == "walk" or not get_node("AnimationPlayer").get_current_animation() == "attack":
			get_node("Sprite").set_rot(0)
			get_node("AnimationPlayer").play("walk")
			state_change_cd = 0.3


func update_state():
	if flip_cd <= 0.0:
		flip_cd = 0.3
		if target_enemy:
			if target_enemy.get_pos().x > get_pos().x:
				set_scale(Vector2(1, 1))
#				get_node("Sprite").set_flip_h(false)
			else:
				set_scale(Vector2(-1, 1))
#				get_node("Sprite").set_flip_h(true)
		else:
			if direction.x > 0:
				set_scale(Vector2(-1, 1))
#				get_node("Sprite").set_flip_h(false)
			elif direction.x < 0:
				set_scale(Vector2(1, 1))
#				get_node("Sprite").set_flip_h(true)
	if Globals.get("debug_mode") and not get_tree().is_editor_hint():
		get_node("State").set_enabled(true)
		if attacking:
			get_node("State").set_color(Color(1.0, 0, 0))
		elif idle:
			get_node("State").set_color(Color(0.5, 0.5, 0))
		else:
			get_node("State").set_color(Color(0, 1, 0))

func _on_AttackRange_body_enter( body ):
	if target_enemy:
		if root.get_node("Actors").has_node(target_enemy_path):
			var r = get_node("AttackRange/CollisionShape2D").get_shape().get_radius()
			if get_pos().distance_to(target_enemy.get_pos()) <= r:
				return
	var target_group = "enemy"
	if "enemy" in parent.get_groups():
		target_group = "friendly"
	if target_group in body.get_groups():
		clear_path()
		target_enemy = body
		target_enemy_path = body.get_path()

func _on_ActorBase_attack(tar):
	get_node("EffectPlayer").play("attack")

func on_hit(tar):
	var he = null
	if parent.hit_effect_scene:
		he = parent.hit_effect_scene.instance()
	if he:
		he.set_z(parent.get_z())
		he.set_pos(self.get_pos())
		get_tree().get_root().get_node("Game/Effects").add_child(he)

		if he.has_node("Particles2D") and tar:
#			he.set_rot(tar.get_pos().angle_to(get_pos()))
			he.get_node("Particles2D").set_param(
				he.get_node("Particles2D").PARAM_DIRECTION,
				get_pos().angle_to(tar.get_pos()) - PI / 2
			)
#			he.set_rot(tar.get_pos().angle_to(get_pos()))