extends Node2D

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
var max_spell1_cd = 0.0
var max_spell2_cd = 0.0
var max_spell3_cd = 0.0
var max_spell4_cd = 0.0

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

func _ready():
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
	if game.dragged_ability:
		get_node("Sprite").set_rot(get_pos().angle_to_point(game.dragged_ability.get_pos()) + PI)
	else:
		get_node("Sprite").set_rot(PI / 2)
	update_cooldowns(dt)

func use_ability(i):
	var ability = get_ability(i)
	if not ability:
		return
	ability = ability.instance()

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
