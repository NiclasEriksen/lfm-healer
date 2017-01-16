tool
extends Node2D

onready var root = get_tree().get_root().get_node("Game")
export(Texture) var spritesheet = null setget set_sprite_texture
export(bool) var has_attack_anim = true
export(bool) var has_death_anim = false
export(bool) var has_special_anim = false
export(Vector2) var tile_dimensions = Vector2(5, 5) setget set_tile_dimensions
var death_effect = preload("res://Scenes/Effects/DeathEffect.tscn")
onready var stats = get_parent().get_node("StatsModule")
onready var movement = get_parent().get_node("MoveModule")
onready var parent = get_parent()
signal attack
signal death(pos)
signal targeted_enemy(enemy)
signal cleared_target()
var target_enemy = null
var healthy = true
#onready var RAYCAST_LENGTH = 3 * get_parent().get_node("CollisionShape2D").get_shape().get_radius()
var attack_cd = 0.0
var flip_cd = 0.0
var state_change_cd = 0.0
var idle_time = 0.0
var idle = false
var attacking = false
var enabled = true

func _ready():
	if not get_tree().is_editor_hint():
		set_process(true)
		set_fixed_process(true)
		parent = get_parent()
		if has_node("MoveModule"):
			movement = get_node("MoveModule")
		if get_parent().has_node("StatsModule"):
			if Globals.get("debug_mode"):
				print("Statsmodule found.")
			stats = get_parent().get_node("StatsModule")
			var shape = CircleShape2D.new()
			shape.set_radius(stats.get_actual("attack_range"))
			get_node("AttackRange/CollisionShape2D").set_shape(shape)
			root.get_node("HUD").add_hpbar(get_parent())
		if has_node("Selected") and get_parent().has_node("CollisionShape2D"):
			get_node("Selected").set_texture_offset(get_parent().get_node("CollisionShape2D").get_pos())
		if has_node("State") and get_parent().has_node("CollisionShape2D"):
			get_node("State").set_texture_offset(get_parent().get_node("CollisionShape2D").get_pos())

func _draw():
	if Globals.get("debug_mode") and not get_tree().is_editor_hint():
		if target_enemy:
			if target_enemy.get_ref():
				var te_pos = target_enemy.get_ref().get_body_pos() - parent.get_body_pos()
				var col = Color(0.1, 0.4, 0.9, 0.75)
				if "enemy" in parent.get_groups():
					col = Color(0.9, 0.1, 0.4, 0.75)
				draw_line(Vector2(0, 0), te_pos * get_scale(), col, 1.0)

func _process(dt):
	#get_node("AttackRange/CollisionShape2D").get_shape().set_radius(stats.get("base_attack_range"))
	if enabled:
		if stats:
			check_death()
			check_healthy()
		check_target()
		if target_enemy:
			if target_enemy.get_ref():
				if movement:
					movement.set_direction((target_enemy.get_ref().get_body_pos() - parent.get_body_pos()).normalized())
			else:
				target_enemy = null
				emit_signal("cleared_target")
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

		if attack_cd <= 0:
			if target_enemy:
				if attacking and target_enemy.get_ref():
					attack_cd = 0.5
					if stats:
						attack_cd = stats.get_actual("attack_speed")
						# print(self.attack_cd)
					else:
						print("No statsmodule?! ", self)
					emit_signal("attack", target_enemy.get_ref())
		else:
			self.attack_cd -= dt

func _fixed_process(dt):
#	if not attacking and enabled:
	update()

func set_sprite_texture(tex):
	spritesheet = tex
	if has_node("Sprite"):
		get_node("Sprite").set_texture(tex)
		get_node("Sprite").set_hframes(int(tile_dimensions.x))
		get_node("Sprite").set_vframes(int(tile_dimensions.y))

func set_tile_dimensions(td):
	tile_dimensions = td
	if has_node("Sprite"):
		get_node("Sprite").set_hframes(int(tile_dimensions.x))
		get_node("Sprite").set_vframes(int(tile_dimensions.y))

func check_target():
	var ar = get_node("AttackRange/CollisionShape2D").get_shape().get_radius()
	if not target_enemy:
		attacking = false
		check_in_range()
		return
	if target_enemy.get_ref():
		var te = target_enemy.get_ref()
		var dist = parent.get_body_pos().distance_to(te.get_body_pos())
		if dist <= ar:
			on_attack()
		elif dist < 80:
			attacking = false
		else:
			attacking = false
	else:
		emit_signal("cleared_target")
		target_enemy = null

func check_death():
	if stats.get("hp") <= 0:
		on_death()
		emit_signal("death", parent.get_body_pos())

func check_healthy():
	if stats.get("hp") < stats.get("max_hp"):
		healthy = false
	else:
		healthy = true

func check_in_range():
	if not get_tree().is_editor_hint():
		var ar = get_node("AttackRange/CollisionShape2D").get_shape().get_radius()
		var target_group = "enemy"
		if "enemy" in parent.get_groups():
			target_group = "friendly"
		var target_enemy_node = get_closest_enemy(get_tree().get_nodes_in_group(target_group))
		if target_enemy_node and movement:
			target_enemy = weakref(target_enemy_node)
			emit_signal("targeted_enemy", target_enemy)
			if parent.get_body_pos().distance_to(target_enemy_node.get_body_pos()) > ar:
				var path = root.get_node("Map").get_simple_path(parent.get_body_pos(), target_enemy_node.get_body_pos())
				movement.set_walk_path(path)

func get_closest_enemy(enemies):
	var closest_candidate = null
	var closest = 2000
	for e in enemies:
		var dist = abs(e.get_body_pos().distance_to(parent.get_body_pos()))
		if target_enemy:
			if e == target_enemy.get_ref():
				continue
		if dist < closest:
			closest = dist
			closest_candidate = e
	return closest_candidate

func on_heal():
	get_node("EffectPlayer").play("Heal")

func on_attack():
	attacking = true
	idle = false
	if not get_node("AnimationPlayer").get_current_animation() == "attack" or not get_node("AnimationPlayer").is_playing():
		if not get_node("AnimationPlayer").get_current_animation() == "idle":
			get_node("AnimationPlayer").set_speed(1)
			get_node("AnimationPlayer").play("idle")

func on_death():
	enabled = false
	parent.get_node("StatsModule").queue_free()
	parent.get_node("CollisionShape2D").queue_free()
	for g in parent.get_groups():
		parent.remove_from_group(g)
	if Globals.get("debug_mode"):
		print(self, " died.")
	var de = death_effect.instance()
	de.set_pos(parent.get_body_pos())
	if has_death_anim:
		var tex = get_node("Sprite").get_texture()
		var hf = get_node("Sprite").get_hframes()
		var vf = get_node("Sprite").get_vframes()
		de.set_texture(tex, hf, vf)
	#	de.get_node("Sprite").set_texture(get_node("DeathSprite").get_texture())
	root.get_node("Effects").add_child(de)
	parent.queue_free()


func on_idle():
	idle = true
	if state_change_cd <= 0:
		if not get_node("AnimationPlayer").get_current_animation() == "idle" or not get_node("AnimationPlayer").get_current_animation() == "attack":
			get_node("Sprite").set_rot(0)
			get_node("AnimationPlayer").play("idle")
			get_node("AnimationPlayer").set_speed(1)
			state_change_cd = 0.3

func on_walk():
	idle = false
	if state_change_cd <= 0:
		if not get_node("AnimationPlayer").get_current_animation() == "walk" and not get_node("AnimationPlayer").get_current_animation() == "attack":
			get_node("Sprite").set_rot(0)
			if parent:
				if parent.has_node("StatsModule"):
					var ms = parent.get_node("StatsModule").get_actual("movement_speed") / 180.0
					get_node("AnimationPlayer").set_speed(ms)
			get_node("AnimationPlayer").play("walk")
			state_change_cd = 0.3


func update_state():
	if flip_cd <= 0.0:
		flip_cd = 0.3
		if target_enemy:
			if target_enemy.get_ref():
				var te = target_enemy.get_ref()
				if te.get_body_pos().x > parent.get_body_pos().x:
					set_scale(Vector2(1, 1))
				else:
					set_scale(Vector2(-1, 1))
	
	if Globals.get("debug_mode") and not get_tree().is_editor_hint():
		get_node("State").set_enabled(true)
		if attacking:
			get_node("State").set_color(Color(1.0, 0, 0))
		elif idle:
			get_node("State").set_color(Color(0.5, 0.5, 0))
		else:
			get_node("State").set_color(Color(0, 1, 0))
	else:
		get_node("State").set_enabled(false)

func _on_AttackRange_body_enter( body ):
	if target_enemy:
		if target_enemy.get_ref():
			var r = get_node("AttackRange/CollisionShape2D").get_shape().get_radius()
			if parent.get_body_pos().distance_to(target_enemy.get_ref().get_body_pos()) <= r:
				return
	var target_group = "enemy"
	if "enemy" in parent.get_groups():
		target_group = "friendly"
	if target_group in body.get_groups():
		if movement:
			movement.set_walk_path([])
		target_enemy = weakref(body)
		emit_signal("targeted_enemy", target_enemy)

func _on_ActorBase_attack(tar):
	if has_attack_anim:
		get_node("AnimationPlayer").play("attack")
	else:
		get_node("EffectPlayer").play("attack")

func on_hit(tar):
	get_node("EffectPlayer").play("hit")
	var he = null
	if parent.hit_effect_scene:
		he = parent.hit_effect_scene.instance()
	if he:
		he.set_z(parent.get_z() + 1)
		he.set_pos(parent.get_body_pos())

		if he.has_node("Particles2D") and tar:
			he.get_node("Particles2D").set_param(
				he.get_node("Particles2D").PARAM_DIRECTION,
				(parent.get_body_pos() - tar.get_body_pos()).angle()
			)

		get_tree().get_root().get_node("Game/Effects").add_child(he)

func _on_MoveModule_stalled():
	on_idle()


func _on_MoveModule_moved():
	on_walk()
