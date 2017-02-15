tool
extends Node2D

onready var root = get_tree().get_root().get_node("Game")
export(Texture) var spritesheet = null setget set_sprite_texture, get_sprite_texture
export(bool) var has_attack_anim = true
export(bool) var has_death_anim = false
export(bool) var has_special_anim = false
export(Vector2) var tile_dimensions = Vector2(5, 5) setget set_tile_dimensions
export(float, 0, 1, 0.05) var STEALTH_OPACITY = 0.3 setget set_stealth_opacity, get_stealth_opacity
var death_effect = preload("res://Scenes/Effects/DeathEffect.tscn")
onready var stats = get_parent().get_node("StatsModule")
onready var movement = get_parent().get_node("MoveModule")
onready var parent = get_parent()
var MIN_SEEK_DIST = 180
signal attack
signal death(pos)
signal enemy_in_personal_space(enemy)
var healthy = true
var flip_cd = 0.0
var state_change_cd = 0.0
var enabled = true
onready var animations = get_node("AnimationPlayer")
onready var sprite = get_node("Sprite")
onready var shield_sprite = get_node("Shield")


func set_stealth_opacity(v):
	STEALTH_OPACITY = v

func get_stealth_opacity():
	return STEALTH_OPACITY

func enable_shield(c):
	if shield_sprite:
		if not shield_sprite.is_visible():
			shield_sprite.set_modulate(c)
			shield_sprite.show()

func disable_shield():
	if shield_sprite:
		shield_sprite.hide()

func _ready():
	if not get_tree().is_editor_hint():
		set_process(true)
		set_fixed_process(true)

		parent = get_parent()
		if parent.has_node("MoveModule"):
			movement = parent.get_node("MoveModule")

		if parent.has_node("StatsModule"):
			if Globals.get("debug_mode"):
				print("Statsmodule found.")
			stats = parent.get_node("StatsModule")
			stats.connect("stealth_broken", self, "on_stealth_broken")
			stats.connect("critical_hit", self, "on_critical_hit")
			var shape = CircleShape2D.new()
			shape.set_radius(stats.get_actual("attack_range"))
			get_node("AttackRange/CollisionShape2D").set_shape(shape)
			root.get_node("HUD").add_hpbar(get_parent())
		if has_node("Selected") and parent.has_node("CollisionShape2D"):
			get_node("Selected").set_offset(parent.get_node("CollisionShape2D").get_pos())
		if has_node("Highlight") and parent.has_node("CollisionShape2D"):
			get_node("Highlight").set_offset(parent.get_node("CollisionShape2D").get_pos())
		if has_node("State") and parent.has_node("CollisionShape2D"):
			get_node("State").set_texture_offset(parent.get_node("CollisionShape2D").get_pos())
#		if parent.has_node("CollisionShape2D"):
#			make_light_occluder()
		if has_node("Sprite") and has_node("Shield"):
			var stex = get_node("Sprite").get_texture()
			var h = stex.get_height() / tile_dimensions.y
			var s = h / get_node("Shield").get_texture().get_height() * 2
			get_node("Shield").set_scale(Vector2(s, s))


func make_light_occluder():
	var cr = parent.get_node("CollisionShape2D").get_shape().get_radius()
	var pos = parent.get_node("CollisionShape2D").get_pos()
	var va = []
	for i in range(24):
		va.append(pos + Vector2(0, cr).rotated(i * PI / 12))
	var lo = OccluderPolygon2D.new()
	lo.set_polygon(va)
	lo.set_cull_mode(2)
	get_node("LightOccluder2D").set_occluder_polygon(lo)

func _draw():
	if Globals.get("debug_mode") and not get_tree().is_editor_hint():
		var t = parent.get_target()
		if t:
			var te_pos = t.get_body_pos() - parent.get_body_pos()
			var col = Color(0.1, 0.4, 0.9, 0.75)
			if "enemy" in parent.get_groups():
				col = Color(0.9, 0.1, 0.4, 0.75)
			draw_line(Vector2(0, 0), te_pos * get_scale(), col, 1.0)

func _process(dt):
	#get_node("AttackRange/CollisionShape2D").get_shape().set_radius(stats.get("base_attack_range"))
	if enabled:
		var stunned = false
		if stats:
			check_death()
			check_healthy()
			stunned = stats.is_stunned()
		
		if flip_cd > 0.0:
			flip_cd -= dt
		if state_change_cd > 0.0:
			state_change_cd -= dt
		update_animations()
		update_state()

func _fixed_process(dt):
#	if not attacking and enabled:
	update()

func set_sprite_texture(tex):
	spritesheet = tex
	if not has_node("Sprite"):
		pass
	else:
		var s = get_node("Sprite")
		s.set_texture(tex)
		s.set_hframes(int(tile_dimensions.x))
		s.set_vframes(int(tile_dimensions.y))
#		var scale = 320 / tex.get_width()
#		s.set_scale(Vector2(scale, scale))

func get_sprite_texture():
	return spritesheet

func set_tile_dimensions(td):
	tile_dimensions = td
	if has_node("Sprite"):
		get_node("Sprite").set_hframes(int(tile_dimensions.x))
		get_node("Sprite").set_vframes(int(tile_dimensions.y))

func get_tile_dimensions():
	return tile_dimensions

func get_closest_enemy(dist=0):
	var target_group = "enemy"
	if "enemy" in parent.get_groups():
		target_group = "friendly"
	var enemies = get_tree().get_nodes_in_group(target_group)
	var closest_candidate = null
	var closest = dist
	var stealth_dist = stats.get_actual("attack_range") * 0.8
	for e in enemies:
		var dist = abs(e.get_body_pos().distance_to(parent.get_body_pos()))
		if e.stats_node:
			if e.stats_node.is_stealthed() and dist > stealth_dist:
				continue
			elif e.stats_node.is_stealthed():
				e.stats_node.emit_signal("stealth_broken")
		if dist < closest:
			closest = dist
			closest_candidate = e
	return closest_candidate

func check_death():
	if stats.get("hp") <= 0:
		on_death()

func check_healthy():
	if stats.get("hp") < stats.get("max_hp"):
		healthy = false
	else:
		healthy = true

func update_state():
	var stunned = false
	var stealthed = false
	var shielded = false
	if stats:
		stunned = stats.is_stunned()
		stealthed = stats.is_stealthed()
		shielded = stats.is_invulnerable()
	if not stunned:
		if flip_cd <= 0.0:
			flip_cd = 0.3
			var t = parent.get_target()
			if t:
				if t.get_body_pos().x > parent.get_body_pos().x:
					set_scale(Vector2(1, 1))
				else:
					set_scale(Vector2(-1, 1))
			else:
				if movement:
					if movement.get_direction().x > 0:
						set_scale(Vector2(1, 1))
					else:
						set_scale(Vector2(-1, 1))
	else:
		on_stunned()

	if stealthed:
		if "enemy" in parent.get_groups():
			set_opacity(0)
		else:
			set_opacity(STEALTH_OPACITY)
			get_node("Stealth").show()
			get_node("Stealth/Particles2D").set_emitting(true)
	else:
		get_node("Stealth").hide()
		get_node("Stealth/Particles2D").set_emitting(false)
		set_opacity(1.0)

	if shielded:
		enable_shield(Color(1, 0.9, 0.7, 0.5))
	else:
		disable_shield()

	if parent.is_selected():
		get_node("Selected").show()
	else:
		get_node("Selected").hide()
	if parent.is_highlighted():
		get_node("Highlight").show()
	else:
		get_node("Highlight").hide()

	if Globals.get("debug_mode") and not get_tree().is_editor_hint():
		get_node("State").set_enabled(true)
	else:
		get_node("State").set_enabled(false)

func _on_Actor_attack(tar):
	if has_attack_anim:
		animations.play("attack")
	else:
		get_node("HealParticles").set_emitting(false)
		get_node("EffectPlayer").play("attack")

func on_hit(tar):
	if stats:
		stats.emit_signal("stealth_broken")
	get_node("HealParticles").set_emitting(false)
	get_node("EffectPlayer").play("hit")
	var he = null
	if parent.hit_effect_scene:
		he = parent.hit_effect_scene.instance()
	if he:
		he.set_z(parent.get_z() + 1)
		he.set_pos(parent.get_body_pos())

		if he.has_node("Particles2D") and tar:
			he.get_node("Particles2D").set_param(
				0,
				(parent.get_body_pos() - tar.get_body_pos()).angle()
			)

		get_tree().get_root().get_node("Game/Effects").add_child(he)

func on_stealth_broken():
	set_opacity(1)

func on_critical_hit():
	# get_node("EffectPlayer").play("crit")
	pass

func _on_MoveModule_stalled():
	on_idle()

func _on_MoveModule_moved():
	on_walk()

func _on_Brain_entered_state(state):
	if state == "idle":
		on_idle()

func _on_PersonalSpace_body_enter(body):
	if body extends KinematicBody2D and not parent.get_allegiance() in body.get_groups():
		emit_signal("enemy_in_personal_space", body)

func update_animations():
	if not parent:
		return
	var brain = parent.get_brain()
	if not brain:
		return
	var state = brain.get_current_state()
	if not state:
		return
	state = state.name
	var cur_anim = animations.get_current_animation()
	if state == "idle":
		if not cur_anim == "idle":
			animations.play("idle")
	elif state == "seek_target":
		if not cur_anim == "walk":
			animations.play("walk")
		elif not animations.is_playing():
			animations.play("walk")
	elif state == "follow_path":
		if not cur_anim == "walk":
			animations.play("walk")
		elif not animations.is_playing():
			animations.play("walk")
	elif state == "follow_formation":
		if not cur_anim == "walk":
			animations.play("walk")
		elif not animations.is_playing():
			animations.play("walk")
	elif state == "attack":
		if not cur_anim == "attack" and not animations.is_playing():
			animations.play("idle")
		elif cur_anim == "attack" and animations.is_playing():
			pass
		elif not cur_anim == "idle":
			animations.play("idle")
	elif state == "dead":
		pass
	elif state == "reviving":
		pass
	elif state == "evade":
		if not cur_anim == "walk":
			animations.play("walk")
		elif not animations.is_playing():
			animations.play("walk")
	elif state == "stunned":
		pass
	elif state == "celebrating":
		pass

func on_heal():
	get_node("EffectPlayer").play("Heal")

func on_attack():
	if stats:
		stats.emit_signal("stealth_broken")

	if not animations.get_current_animation() == "attack" or not animations.is_playing():
		if not animations.get_current_animation() == "idle":
			animations.play("idle")

func on_death():
	enabled = false
	emit_signal("death", parent.get_body_pos())
	parent.get_node("StatsModule").queue_free()
	parent.get_node("CollisionShape2D").queue_free()
	if parent.is_in_party():
		parent.get_party().unregister_unit(parent.get_party_index())
	for g in parent.get_groups():
		parent.remove_from_group(g)
	if Globals.get("debug_mode"):
		print(self, " died.")
	var de = death_effect.instance()
	de.set_pos(parent.get_pos())
	de.set_z(parent.get_z() - 8)
	if has_death_anim:
		var tex = sprite.get_texture()
		var hf = sprite.get_hframes()
		var vf = sprite.get_vframes()
		de.set_scale(sprite.get_scale() * get_scale())
		de.set_texture(tex, hf, vf)
	root.get_node("Effects").add_child(de)
	parent.queue_free()

func on_idle():
	animations.set_speed(1)
	var cur_anim = animations.get_current_animation()
	if state_change_cd <= 0:
		if not cur_anim == "idle" or not cur_anim == "attack":
			sprite.set_rot(0)
			animations.play("idle")
			state_change_cd = 0.3

func on_walk():
	if stats and not (animations.get_current_animation() == "attack" and animations.is_playing()):
		var ms = stats.get_actual("movement_speed") / 80
		animations.set_speed(ms)
	if not animations.get_current_animation() == "walk" and not (animations.get_current_animation() == "attack" and animations.is_playing()):
		sprite.set_rot(0)
		animations.play("walk")

func on_stunned():
	animations.stop()
	animations.set_current_animation("idle")
