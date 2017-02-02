extends Node2D

var dragged_ability = false
var maplist_node = preload("res://Scripts/MapList.gd").new()
export(int, 2, 50, 1) var select_sensitivity = 20
var tank_actor = load("res://Scenes/Actors/Tank.tscn")
var archer_actor = load("res://Scenes/Actors/Archer.tscn")
var rogue_actor = load("res://Scenes/Actors/Rogue.tscn")
var mage_actor = load("res://Scenes/Actors/Mage.tscn")
var enemy_actor = load("res://Scenes/Actors/TestEnemy.tscn")
var death_splat = load("res://Scenes/Effects/DeathSplat.tscn")
var actor_types = ["tank", "archer", "rogue", "mage", "enemy"]
onready var cam = get_node("Camera2D")
onready var map = get_node("Map")
onready var healer = get_node("Healer")

func _ready():
	set_process(true)
	set_process_unhandled_input(true)
	newgame(false)

func add_all_spells():
	if not healer:
		print("No healer?")
		return
	for i in range(1, 5):
		var s = healer.get_ability(i)
		if s:
			s = s.instance()
		else:
			continue
		if s.get_icon():
			get_node("HUD").set_button_ability(i, s.get_icon())
		s.free()

func load_map(m):
	print("Loading map \"", m, "\"...")
	var m_path = maplist_node.get_map_dir() + m
	var mapnode = load(m_path).instance()
	mapnode.set_name("Map")
	if has_node("Map"):
		get_node("Map").free()
	else:
		print("No map node present? :S")
		return
	add_child(mapnode)
	move_child(mapnode, 0)
	map = mapnode
	print("Done.")
	newgame(true)

func newgame(clean):
	if clean:
		cleanup()
	print("Starting new game...")
	map = get_node("Map")
	if not map.get_spawnlist().size():
		print("Spawnlist is empty! Enabling autospawn.")
		Globals.set("autospawn", true)
		spawn_actor("enemy", "enemy")

	if has_node("HUD"):
		add_all_spells()
		var mapname = "\"" + map.get_map_title() + "\""
		get_node("HUD").flash_message("Starting round..", "Current map: " + mapname, 3)
	spawn_party()

func spawn_party():
	spawn_actor("tank", "friendly")
	spawn_actor("rogue", "friendly")
	spawn_actor("rogue", "friendly")
	spawn_actor("archer", "friendly")
	spawn_actor("mage", "friendly")
	get_node("Party").set_scale(Vector2(0.85, 0.85))
	get_node("Party").set_pos(map.get_spawn_pos("friendly"))
	for f in get_tree().get_nodes_in_group("friendly"):
		f.set_party(get_node("Party"))
		if f.get_party_index() == 0:
#			f.set_leader(true)
			f.set_pos(f.get_party().lookup_formation_pos(0))
			f.move_node.set_direction(
				f.move_node.check_path(f.move_node.get_direction())
			)
			f.get_party().set_orientation(f.move_node.get_direction())
#		print(p, "          ", f.get_pos())
	for f in get_tree().get_nodes_in_group("friendly"):
		var p = f.get_party().lookup_formation_pos(f.get_party_index())
		f.set_pos(p)

func gameover():
	get_tree().set_pause(true)
	get_node("HUD").flash_message("", "Round ended, restarting...", 2)
	var t = Tween.new()
	t.set_pause_mode(2)
	t.interpolate_callback(self, 2, "newgame", true)
	t.interpolate_callback(get_tree(), 2, "set_pause", false)
	t.interpolate_callback(t, 2.1, "queue_free")
	t.start()
	add_child(t)

func cleanup():
	print("Resetting game state and clearing objects...")
	healer.reset()
	dragged_ability = null
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
	if has_node("Map"):
		get_node("Map")._ready()
	if has_node("Party"):
		get_node("Party")._ready()
	print("Done.")

func _process(dt):
#	if game_over:
#		if game_over_timer > 0:
#			game_over_timer -= dt
#		else:
#			game_over = false
#			newgame()
	var friendlies = get_tree().get_nodes_in_group("friendly")
	if not friendlies.size():
		print("All friendly players dead, restarting.")
		gameover()
		return
	var enemies = get_tree().get_nodes_in_group("enemy")
	if not enemies.size():
		if get_node("Map").is_done_spawning():
			print("All enemy players dead, restarting.")
			gameover()
			return

func _unhandled_input(event):
	event = make_input_local(event)
	if event.type == InputEvent.SCREEN_TOUCH:
		if not event.pressed and dragged_ability:
			var i = dragged_ability.get_slot()
			if Globals.get("chill_mode"):
				i = 0	# No cooldowns.
			var hit = dragged_ability.trigger()
			if hit and not Globals.get("debug_mode"):
				healer.set_cooldown(i, dragged_ability.get_cooldown())
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
		p = map.get_spawn_pos(alliance)
		p_to= map.get_spawn_pos("enemy")
	elif alliance == "enemy":
		p = map.get_spawn_pos(alliance)
		p_to = map.get_spawn_pos("friendly")
		var scr_h = Globals.get("render_height")
		p += Vector2(0, rand_range(-(scr_h / 10), scr_h / 10))

	if actor:
		if Globals.get("debug_mode"):
			print("Spawning actor: ", actor_type)
		actor.change_allegiance(alliance)
		actor.set_pos(p)
		var body_p = actor.get_body_pos()
		if actor.has_node("MoveModule"):
			var path = map.get_simple_path(body_p, p_to)
			actor.get_node("MoveModule").set_walk_path(path)
		actor.get_node("ActorBase").connect("death", self, "on_actor_death")
		actor.get_node("ActorBase").connect("death", actor, "on_actor_death")
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
			if randf() > 0.5:
				return
		spawn_actor("enemy", "enemy")
#	var friendlies = get_tree().get_nodes_in_group("friendly")
#	for f in friendlies:
	# t.set_wait_time(1.0)


func _on_AbilityBar_ability_tapped(slot):
	if get_tree().is_paused():
		return
	var pos = get_local_mouse_pos()
	if healer.get_cooldown(slot) > 0:
		return

#	var spell = self.spells[slot - 1]
	var spell = healer.get_ability(slot)
	if spell:
		spell = spell.instance()
		spell.set_slot(slot)
		spawn_ability(spell, pos)

func get_game_pos(p):
	var t = get_node("Camera2D").get_global_transform()
	return t.xform(p)

func spawn_ability(ability, pos):
	if ability.ability_type == "target":
		dragged_ability = ability
		self.dragged_ability.set_pos(pos)
		self.dragged_ability.set_active(false)
		
		self.get_node("Effects").add_child(self.dragged_ability)
	elif ability.ability_type == "instant":
		self.get_node("Effects").add_child(ability)
		ability.trigger()
		if not Globals.get("debug_mode"):
			healer.set_cooldown(ability.get_slot(), ability.get_cooldown())


func _on_HUD_kill_pressed():
	var actors = get_tree().get_nodes_in_group("friendly") + get_tree().get_nodes_in_group("enemy")
	for a in actors:
		if a.is_selected():
			a.actorbase_node.on_death()
