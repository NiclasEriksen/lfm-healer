extends Node2D

var dragged_ability = false
var spells = [
	load("res://Scenes/Abilities/TargetedHeal.tscn"),
	load("res://Scenes/Abilities/AreaHeal.tscn"),
	load("res://Scenes/Abilities/ChainHeal.tscn"),
	null
]
var tank_actor = load("res://Scenes/Actors/Tank.tscn")
var archer_actor = load("res://Scenes/Actors/Archer.tscn")
var mage_actor = load("res://Scenes/Actors/Mage.tscn")
var enemy_actor = load("res://Scenes/Actors/TestEnemy.tscn")
var death_splat = load("res://Scenes/Effects/DeathSplat.tscn")
onready var cam = get_node("Camera2D")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	set_process_input(true)
	newgame()

func newgame():
	cleanup()
	spawn_actor("enemy", "enemy")
	spawn_actor("enemy", "enemy")
	spawn_actor("enemy", "enemy")
	spawn_actor("archer", "enemy")
	spawn_actor("archer", "enemy")
	spawn_actor("mage", "enemy")
	spawn_actor("tank", "friendly")
	spawn_actor("tank", "friendly")
	spawn_actor("tank", "friendly")
	spawn_actor("mage", "friendly")
	spawn_actor("archer", "friendly")

func cleanup():
	dragged_ability = null
	get_node("HUD").clear()
	if Globals.get("debug_mode"):
		print("Freeing ", get_node("Objects").get_child_count())
	if get_node("Objects").get_child_count():
		for o in get_node("Objects").get_children():
			o.free()
	if Globals.get("debug_mode"):
		print("Freeing ", get_node("Actors").get_child_count())
	if get_node("Actors").get_child_count():
		for a in get_node("Actors").get_children():
			a.free()
	if Globals.get("debug_mode"):
		print("Freeing ", get_node("Effects").get_child_count())
	if get_node("Effects").get_child_count():
		for e in get_node("Effects").get_children():
			e.free()

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

	for f in friendlies:
		f.get_node("ActorBase").get_node("Selected").set_enabled(false)

func _input(event):
	#event = make_input_local(event)
	if event.type == InputEvent.SCREEN_TOUCH:
#		if event.pressed:
#			if not dragged_ability:
#				dragged_ability = targeted_heal.instance()
#				dragged_ability.set_pos(event.pos)
#				get_node("Effects").add_child(dragged_ability)
#			else:
#				dragged_ability.trigger()
#				dragged_ability = null
		
		if not event.pressed and dragged_ability:
			dragged_ability.trigger()
			dragged_ability = false
	elif event.type == InputEvent.SCREEN_DRAG:
		if dragged_ability:
			if not dragged_ability.active:
				dragged_ability.set_active(true)
			dragged_ability.set_pos(event.pos)
	elif event.type == InputEvent.KEY:
		if event.pressed and event.scancode == KEY_F12:
			Globals.set("debug_mode", not Globals.get("debug_mode"))


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
	elif actor_type == "mage":
		actor = mage_actor.instance()

	if alliance == "friendly":
		p = get_node("Map/FriendlySpawn").get_pos()
		p_to= get_node("Map/EnemySpawn").get_pos()
	elif alliance == "enemy":
		p = get_node("Map/EnemySpawn").get_pos()
		p_to = get_node("Map/FriendlySpawn").get_pos()
	p += Vector2(0, rand_range(-150, 150))

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
	spawn_actor("enemy", "enemy")
#	var friendlies = get_tree().get_nodes_in_group("friendly")
#	for f in friendlies:
	# t.set_wait_time(1.0)


func _on_AbilityBar_ability_tapped(slot):
	var pos = get_global_mouse_pos()
	var spell = self.spells[slot - 1]
	spawn_ability(spell, pos)


func spawn_ability(ability, pos):
	if ability:
		self.dragged_ability = ability.instance()
		self.dragged_ability.set_pos(pos)
		self.dragged_ability.set_active(false)
		self.get_node("Effects").add_child(self.dragged_ability)
