extends "res://Scripts/Actor.gd"

onready var game = get_tree().get_root().get_node("Game")
signal spell_cd_changed(spell_id, pts)
export(String, FILE, "*.tscn") var ability_1_scene = null setget set_ability_1_scene
export(String, FILE, "*.tscn") var ability_2_scene = null setget set_ability_2_scene
export(String, FILE, "*.tscn") var ability_3_scene = null setget set_ability_3_scene
export(String, FILE, "*.tscn") var ability_4_scene = null setget set_ability_4_scene
var ability_1 = null
var ability_2 = null
var ability_3 = null
var ability_4 = null
var spell1_cd = 0.0
var spell2_cd = 0.0
var spell3_cd = 0.0
var spell4_cd = 0.0
var last_mp = 100.0
var last_max_mp = 100.0
var max_spell1_cd = 0.0
var max_spell2_cd = 0.0
var max_spell3_cd = 0.0
var max_spell4_cd = 0.0
onready var cast_range_tween = get_node("CastRangeTween")
signal healer_death
signal mp_changed(new_val)

func get_ability(i):
	if i == 1:
		return ability_1
	if i == 2:
		return ability_2
	if i == 3:
		return ability_3
	if i == 4:
		return ability_4
	else:
		print("No ability with number \"", i, "\".")
		return null

func set_ability_1_scene(scn):
	ability_1_scene = scn

func set_ability_2_scene(scn):
	ability_2_scene = scn

func set_ability_3_scene(scn):
	ability_3_scene = scn

func set_ability_4_scene(scn):
	ability_4_scene = scn

func is_casting():
	return game.dragged_ability

func _ready():
	reset()
	if Globals.get("debug_mode"):
		print("Loading abilities...")
	if ability_1_scene:
		ability_1 = load(ability_1_scene)
		var tmp = ability_1.instance()
		max_spell1_cd = tmp.get_cooldown()
		tmp.free()
	if ability_2_scene:
		ability_2 = load(ability_2_scene)
		var tmp = ability_2.instance()
		max_spell2_cd = tmp.get_cooldown()
		tmp.free()
	if ability_3_scene:
		ability_3 = load(ability_3_scene)
		var tmp = ability_3.instance()
		max_spell3_cd = tmp.get_cooldown()
		tmp.free()
	if ability_4_scene:
		ability_4 = load(ability_4_scene)
		var tmp = ability_4.instance()
		max_spell4_cd = tmp.get_cooldown()
		tmp.free()
	set_process(true)

func check_mp():
	if not stats_node:
		return
	var max_mp = stats_node.get_actual("max_mp")
	var mp = stats_node.get("mp")
	if mp != last_mp or max_mp != last_max_mp:
		var val = mp / max_mp * 100
		emit_signal("mp_changed", val)

func reset():
	spell1_cd = 0.0
	spell2_cd = 0.0
	spell3_cd = 0.0
	spell4_cd = 0.0
	emit_signal("spell_cd_changed", 1, 0)
	emit_signal("spell_cd_changed", 2, 0)
	emit_signal("spell_cd_changed", 3, 0)
	emit_signal("spell_cd_changed", 4, 0)

func _process(dt):
#	if game.dragged_ability:
#		get_node("Sprite").set_rot(get_pos().angle_to_point(game.dragged_ability.get_pos()) + PI)
#	else:
#		get_node("Sprite").set_rot(PI / 2)
	if party:
		get_tree().get_root().get_node("Game/Camera2D").set_pos(party.get_pos())
	else:
		get_tree().get_root().get_node("Game/Camera2D").set_pos(get_global_pos())
	update_cooldowns(dt)
	check_mp()

func cast(a):
	set_cooldown(a.get_slot(), a.get_cooldown())
	if stats_node:
		stats_node.apply_mp_cost(a.get_cost())

func can_afford(s):
	if not stats_node:
		return true
	if s.get_cost() <= stats_node.get("mp"):
		return true
	return false

func get_cooldown(i):
	if i == 1:
		return spell1_cd
	if i == 2:
		return spell2_cd
	if i == 3:
		return spell3_cd
	if i == 4:
		return spell4_cd
	return 0.0

func set_cooldown(i, cd):
	if i == 1:
		spell1_cd = cd
	if i == 2:
		spell2_cd = cd
	if i == 3:
		spell3_cd = cd
	if i == 4:
		spell4_cd = cd

func update_cooldowns(dt):
	if spell1_cd > 0:
		emit_signal("spell_cd_changed", 1, spell1_cd / max_spell1_cd * 100)
		spell1_cd -= dt
	else:
		if spell1_cd < 0:
			emit_signal("spell_cd_changed", 1, 0)
		spell1_cd = 0
	if spell2_cd > 0:
		emit_signal("spell_cd_changed", 2, spell2_cd / max_spell2_cd * 100)
		spell2_cd -= dt
	else:
		if spell2_cd < 0:
			emit_signal("spell_cd_changed", 2, 0)
		spell2_cd = 0
	if spell3_cd > 0:
		emit_signal("spell_cd_changed", 3, spell3_cd / max_spell3_cd * 100)
		spell3_cd -= dt
	else:
		if spell3_cd < 0:
			emit_signal("spell_cd_changed", 3, 0)
		spell3_cd = 0
	if spell4_cd > 0:
		emit_signal("spell_cd_changed", 4, spell4_cd / max_spell4_cd * 100)
		spell4_cd -= dt
	else:
		if spell4_cd < 0:
			emit_signal("spell_cd_changed", 4, 0)
		spell4_cd = 0

func attack(t):
	# Override attack method for healer.
	pass

func _on_ActorBase_death( pos ):
	emit_signal("healer_death")

func _on_start_dragging(a):
	var cr = get_node("CastRange")
	print(cr.get_opacity())
	var s = a.cast_range / cr.get_texture().get_size().x
	cr.set_scale(Vector2(s * 2, s * 2))
	if cr.get_opacity() == 0.1:
		return
	cast_range_tween.interpolate_property(
		cr, "visibility/opacity", cr.get_opacity(), 0.1, (0.1 - cr.get_opacity()) * 5, 0, 0)
	cast_range_tween.start()


func _on_stop_dragging():
	var cr = get_node("CastRange")
	print(cr.get_opacity())
	if cr.get_opacity() == 0:
		return
	if cast_range_tween.is_active():
		cast_range_tween.stop(cr, "visibility/opacity")
	cast_range_tween.interpolate_property(
		cr, "visibility/opacity", cr.get_opacity(), 0, cr.get_opacity() * 5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	cast_range_tween.start()
	add_child(cast_range_tween)
	print(cast_range_tween)
