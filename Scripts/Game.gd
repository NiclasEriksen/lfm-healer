extends Node2D

var dragged_ability = false
var maplist_node = preload("res://Scripts/MapList.gd").new()
export(int, 2, 50, 1) var select_sensitivity = 20
var spells = [
	load("res://Scenes/Abilities/TargetedHeal.tscn"),
	load("res://Scenes/Abilities/AreaHeal.tscn"),
	load("res://Scenes/Abilities/ChainHeal.tscn"),
	null
]
var tank_actor = load("res://Scenes/Actors/Tank.tscn")
var archer_actor = load("res://Scenes/Actors/Archer.tscn")
var rogue_actor = load("res://Scenes/Actors/Rogue.tscn")
var mage_actor = load("res://Scenes/Actors/Mage.tscn")
var enemy_actor = load("res://Scenes/Actors/TestEnemy.tscn")
var death_splat = load("res://Scenes/Effects/DeathSplat.tscn")
var actor_types = ["tank", "archer", "rogue", "mage", "enemy"]
onready var cam = get_node("Camera2D")
var spell1_cd = 0.0
var spell2_cd = 0.0
var spell3_cd = 0.0
var spell4_cd = 0.0
var max_spell1_cd = 0.0
var max_spell2_cd = 1.5
var max_spell3_cd = 3.0
var max_spell4_cd = 2.0
signal spell_cd_changed(spell_id, pts)

func _ready():
	set_process(true)
	set_process_unhandled_input(true)
	newgame()

func add_all_spells():
	var i = 1
	for s in spells:
		if s:
			s = s.instance()
		else:
			i += 1
			continue
		if s.get_icon():
			get_node("HUD").set_button_ability(i, s.get_icon())
		i += 1

func load_map(m):
	var m_path = maplist_node.get_map_dir() + m
	var mapnode = load(m_path).instance()
	mapnode.set_name("Map")
	if has_node("Map"):
		get_node("Map").free()
	else:
		print("No map node present? :S")
	add_child(mapnode)
	move_child(mapnode, 0)
	newgame()

func newgame():
	cleanup()
	if has_node("HUD"):
		add_all_spells()
		get_node("HUD").flash_message("Begynner", "nei men se der ja", 3)
	spawn_actor("enemy", "enemy")
	spawn_actor("enemy", "enemy")
	spawn_actor("enemy", "enemy")
	spawn_actor("enemy", "enemy")
	spawn_actor("enemy", "enemy")
	spawn_actor("enemy", "enemy")
#	spawn_actor("mage", "enemy")
#	spawn_actor("archer", "friendly")
	spawn_actor("archer", "friendly")
	spawn_actor("mage", "friendly")
#	spawn_actor("rogue", "friendly")
	spawn_actor("rogue", "friendly")
#	spawn_actor("tank", "friendly")
#	spawn_actor("mage", "friendly")
#	spawn_actor("archer", "friendly")
#	spawn_actor("archer", "friendly")
#	spawn_actor("archer", "friendly")
#	spawn_actor("archer", "friendly")
#	spawn_actor("archer", "friendly")

func cleanup():
	dragged_ability = null
	spell1_cd = 0.0
	spell2_cd = 0.0
	spell3_cd = 0.0
	spell4_cd = 0.0
	for s in range(spells.size()):
		emit_signal("spell_cd_changed", s, 0)
	get_node("HUD").clear()
	if Globals.get("debug_mode"):
		print("Freeing ", get_node("Objects").get_child_count())
	if get_node("Objects").get_child_count():
		for o in get_node("Objects").get_children():
			o.free()
	if Globals.get("debug_mode"):
		print("Freeing ", get_node("Actors").get_child_count())
	if Globals.get("debug_mode"):
		print("Freeing ", get_node("Effects").get_child_count())
	if get_node("Effects").get_child_count():
		for e in get_node("Effects").get_children():
			e.free()
	if get_node("Actors").get_child_count():
		for a in get_node("Actors").get_children():
			a.free()

func _process(dt):
	var friendlies = get_tree().get_nodes_in_group("friendly")
	if not friendlies.size():
		print("All friendly players dead, restarting.")
		newgame()
		return
	var enemies = get_tree().get_nodes_in_group("enemy")
	if not enemies.size():
		print("All enemy players dead, restarting.")
		newgame()
		return

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

func _unhandled_input(event):
	event = make_input_local(event)
	if event.type == InputEvent.SCREEN_TOUCH:
		if not event.pressed and dragged_ability:
			var i = dragged_ability.get_slot()
			if Globals.get("chill_mode"):
				i = 0	# No cooldowns.
			var hit = dragged_ability.trigger()
			if hit:
				if i == 1:
					spell1_cd = max_spell1_cd
				elif i == 2:
					spell2_cd = max_spell2_cd
				elif i == 3:
					spell3_cd = max_spell3_cd
				elif i == 4:
					spell4_cd = max_spell4_cd
			dragged_ability = false
		if event.pressed:
			select_actor(event.pos)
	elif event.type == InputEvent.SCREEN_DRAG:
		if dragged_ability:
			if not dragged_ability.active:
				dragged_ability.set_active(true)
			dragged_ability.set_pos(event.pos)
	elif event.type == InputEvent.KEY:
		if event.pressed and event.scancode == KEY_F12:
			Globals.set("debug_mode", not Globals.get("debug_mode"))
		elif event.pressed and event.scancode == KEY_PLUS:
			get_node("Camera2D").zoom_in()
		elif event.pressed and event.scancode == KEY_MINUS:
			get_node("Camera2D").zoom_out()
#		elif event.pressed and event.scancode == KEY_UP:
#			get_node("Camera2D").set_pos(get_node("Camera2D").get_pos() + Vector2(0, -50))
#		elif event.pressed and event.scancode == KEY_DOWN:
#			get_node("Camera2D").set_pos(get_node("Camera2D").get_pos() + Vector2(0, 50))

func select_actor(p):
	var closest = null
	var closest_dist = select_sensitivity
	var n = get_tree().get_nodes_in_group("friendly") + get_tree().get_nodes_in_group("enemy")
	for actor in n:
		actor.set_selected(false)
		if p.distance_to(actor.get_pos()) <= closest_dist:
			closest = actor
			closest_dist = p.distance_to(actor.get_pos())
	if closest:
		closest.set_selected(true)

func spawn_actor(actor_type, alliance):
	var actor = null
	var p = Vector2(0, 0)
	var p_to = Vector2(0, 0)
	if actor_type == "tank":
		actor = tank_actor.instance()
	elif actor_type == "enemy":
		actor = enemy_actor.instance()
	elif actor_type == "archer":
		actor = archer_actor.instance()
	elif actor_type == "rogue":
		actor = rogue_actor.instance()
	elif actor_type == "mage":
		actor = mage_actor.instance()

	if alliance == "friendly":
		if Globals.get("chill_mode") and actor:
			# Triple level
			actor.get_node("StatsModule").set_level(10)
		p = get_node("Map/FriendlySpawn").get_pos()
		p_to= get_node("Map/EnemySpawn").get_pos()
	elif alliance == "enemy":
		p = get_node("Map/EnemySpawn").get_pos()
		p_to = get_node("Map/FriendlySpawn").get_pos()
	var scr_h = Globals.get("render_height")
	p += Vector2(0, rand_range(-(scr_h / 4), scr_h / 4))

	if actor:
		if Globals.get("debug_mode"):
			print("Spawning actor: ", actor_type)
		actor.change_allegiance(alliance)
		actor.set_pos(p)
		if actor.has_node("MoveModule"):
			var path = get_node("Map").get_simple_path(p, p_to)
			actor.get_node("MoveModule").set_walk_path(path)
		actor.get_node("ActorBase").connect("death", self, "on_actor_death")
		get_node("Actors").add_child(actor)
	else:
		print("No actor by that identifier found: ", actor_type)

func on_actor_death(p):
	var ds = death_splat.instance()
	ds.set_pos(p)
	get_node("Objects").add_child(ds)
	

func _on_Timer_timeout():
#	rand_seed(randi())
#	if randf() > 0.5:
#		if randf() > 0.8:
#			spawn_actor("archer")
#		else:
#			spawn_actor("tank")
#	if get_tree().get_nodes_in_group("enemy").size() < 10:
	if Globals.get("autospawn"):
		if Globals.get("chill_mode"):
			if randf() > 0.75:
				return
		spawn_actor("enemy", "enemy")
#	var friendlies = get_tree().get_nodes_in_group("friendly")
#	for f in friendlies:
	# t.set_wait_time(1.0)


func _on_AbilityBar_ability_tapped(slot):
	if get_tree().is_paused():
		return
	var pos = get_local_mouse_pos()
	if slot == 1:
		if spell1_cd > 0:
			return
	elif slot == 2:
		if spell2_cd > 0:
			return
	elif slot == 3:
		if spell3_cd > 0:
			return
	elif slot == 4:
		if spell4_cd > 0:
			return

	var spell = self.spells[slot - 1]
	if spell:
		spell = spell.instance()
		spell.set_slot(slot)
		spawn_ability(spell, pos)

func get_game_pos(p):
	var t = get_node("Camera2D").get_global_transform()
	return t.xform(p)

func spawn_ability(ability, pos):
	dragged_ability = ability
	self.dragged_ability.set_pos(pos)
	self.dragged_ability.set_active(false)
	
	self.get_node("Effects").add_child(self.dragged_ability)


func _on_HUD_kill_pressed():
	var actors = get_tree().get_nodes_in_group("friendly") + get_tree().get_nodes_in_group("enemy")
	for a in actors:
		if a.is_selected():
			a.queue_free()