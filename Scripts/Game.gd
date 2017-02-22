extends Node2D

var dragged_ability = false
var maplist_node = preload("res://Scripts/MapList.gd").new()
export(int, 2, 50, 1) var select_sensitivity = 20
var actory = preload("res://Scripts/ActorFactory.gd").new()
var death_splat = load("res://Scenes/Effects/DeathSplat.tscn")
onready var cam = get_node("Camera2D")
var map = null
var userdata = preload("res://Scripts/UserDataManager.gd").new()
var healer = null
signal cleared_ability
signal dragging_ability(a)

func get_actor_types():
	var l = []
	for k in actory.actors:
		l.append(k)
	return l

func get_actor_scene(n):
	if actory.actors.has(n):
		return actory.actors[n]
	return

func _ready():
	add_child(userdata)
	var sd = userdata.load_data("Settings")
	for s in sd:
		Globals.set(s, sd[s])
	var fd = userdata.load_data("Formations")
	actory.game = self
	set_process(true)
	set_process_unhandled_input(true)
	load_map("Mountain.tscn")
#	newgame(false)

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
	cleanup()
	print("Loading map \"", m, "\"...")
	var m_path = maplist_node.get_map_dir() + m
	var mapnode = load(m_path).instance()
	mapnode.set_name("Map")
	if has_node("Map"):
		get_node("Map").free()
	else:
		print("No map node present? :S")
#		return
	add_child(mapnode)
	move_child(mapnode, 0)
	map = mapnode
	get_node("Camera2D").set_limit(2, mapnode.get_map_size().x)
	get_node("Camera2D").set_limit(3, mapnode.get_map_size().y)
	print("Done.")
	newgame(false)

func spawn_healer():
	if has_node("Healer"):
#		print("Healer alive.")
		get_node("Healer").free()
	var hn = actory.actors["healer"].instance()
	hn.set_healer(true)
	hn.connect("spell_cd_changed", get_node("HUD"), "_on_Healer_spell_cd_changed")
	hn.connect("healer_death", self, "_on_Healer_death")
	connect("cleared_ability", hn, "_on_stop_dragging")
	connect("dragging_ability", hn, "_on_start_dragging")
	hn.set_name("Healer")
	add_child(hn)
	healer = hn

func newgame(clean):
	if clean:
		cleanup()
	spawn_healer()
	print("Starting new game...")
	map = get_node("Map")

	if not map.get_spawnlist().size() and not map.spawnpoints.size():
		print("Spawnlist is empty! Enabling autospawn.")
		Globals.set("autospawn", true)
		spawn_actor("testenemy", "enemy")

	if has_node("HUD"):
		add_all_spells()
		var mapname = "\"" + map.get_map_title() + "\""
		get_node("HUD").flash_message("Starting round..", "Current map: " + mapname, 3)
	spawn_party()
	map.start()

func spawn_party():
	spawn_actor("tank", "friendly")
	spawn_actor("rogue", "friendly")
	spawn_actor("archer", "friendly")
	spawn_actor("mage", "friendly")
	get_node("Party").set_scale(Vector2(0.85, 0.85))
	get_node("Party").set_pos(map.get_spawn_pos("friendly"))
	for f in get_tree().get_nodes_in_group("friendly"):
		f.add_to_group("party")
		f.set_party(get_node("Party"))
		if f.get_party_index() == 0:
#			f.set_leader(true)
			f.set_pos(f.get_party().lookup_formation_pos(0))
			f.get_party().orientation = f.move_node.get_direction()
			f.get_party().desired_orientation = f.move_node.get_direction()
#		print(p, "          ", f.get_pos())
	for f in get_tree().get_nodes_in_group("friendly"):
		if f.get_party_index() == 0 and f.has_node("Brain"):
			f.get_node("Brain").push_state("follow_path")
		elif f.has_node("Brain"):
			f.get_node("Brain").push_state("follow_formation")
		var p = f.get_party().lookup_formation_pos(f.get_party_index())
		f.set_pos(p)

func gameover():
	if healer:
		get_node("HUD").flash_message("", "Round ended, restarting...", 2)
	else:
		get_node("HUD").flash_message("", "Healer died, you suck...", 2)
	get_tree().set_pause(true)
	var t = Tween.new()
	t.set_pause_mode(2)
	t.interpolate_callback(self, 2, "newgame", true)
	t.interpolate_callback(get_tree(), 2, "set_pause", false)
	t.interpolate_callback(t, 2.1, "queue_free")
	t.start()
	add_child(t)

func get_path_to_end(pos):
	if not map:
		return []
	var end = map.get_spawn_pos("enemy")
	return map.get_simple_path(pos, end)

func cleanup():
	print("Resetting game state and clearing objects...")
	dragged_ability = null
	emit_signal("cleared_ability")
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
		get_node("Actors").free()
		var a = Node.new()
		a.set_name("Actors")
		add_child(a)
		move_child(a, 2)
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
	elif friendlies.size() == 1 and friendlies[0].is_healer():
		print("Only healer left...")
		gameover()
		return
	var enemies = get_tree().get_nodes_in_group("enemy")
	if not enemies.size():
		if get_node("Map").is_done_spawning():
			print("All enemy players dead, restarting.")
			gameover()
			return
	update()

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
			dragged_ability = null
			emit_signal("cleared_ability")
		if event.pressed:
			select_actor(event.pos)
	elif event.type == InputEvent.SCREEN_DRAG:
		if dragged_ability:
			if not dragged_ability.active:
				dragged_ability.set_active(true)
			var hpos = healer.get_body_pos()
			if not hpos.distance_to(event.pos) > dragged_ability.cast_range:
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

func _draw():
#	if Globals.get("debug_mode"):
	pass

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
	actory.spawn_actor(actor_type, alliance)

func on_actor_death(a):
	if "enemy" in a.get_groups():
		for pm in get_tree().get_nodes_in_group("party"):
			pm.stats_node.add_xp(5)
	var ds = death_splat.instance()
	ds.set_pos(a.get_body_pos())
	get_node("Objects").add_child(ds)
	a.queue_free()


func _on_Healer_death():
	healer = null
	gameover()

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
		spawn_actor("testenemy", "enemy")
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
		emit_signal("dragging_ability", dragged_ability)
		self.dragged_ability.set_pos(pos)
		self.dragged_ability.set_active(false)
		
		self.get_node("Effects").add_child(self.dragged_ability)
	elif ability.ability_type == "instant":
		self.get_node("Effects").add_child(ability)
		ability.trigger()
		if not Globals.get("debug_mode"):
			healer.set_cooldown(ability.get_slot(), ability.get_cooldown())


func _on_HUD_kill_pressed():
	var allactors = get_tree().get_nodes_in_group("friendly") + get_tree().get_nodes_in_group("enemy")
	for a in allactors:
		if a.is_selected():
			a.actorbase_node.on_death()
