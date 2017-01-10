extends Node2D

var dragged_ability = false
var targeted_heal = load("res://Scenes/Abilities/TargetedHeal.tscn")
var area_heal = load("res://Scenes/Abilities/AreaHeal.tscn")
var chain_heal = load("res://Scenes/Abilities/ChainHeal.tscn")
var tank_actor = load("res://Scenes/Actors/Tank.tscn")
var archer_actor = load("res://Scenes/Actors/Archer.tscn")
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
	spawn_actor("enemy")
	spawn_actor("enemy")
	spawn_actor("enemy")
	spawn_actor("tank")
	spawn_actor("tank")
	spawn_actor("tank")
	spawn_actor("archer")
	spawn_actor("archer")

func cleanup():
	dragged_ability = null
	if Globals.get("debug_mode"):
		print("Freeing ", get_node("Objects").get_child_count())
	for o in get_node("Objects").get_children():
		o.free()
	if Globals.get("debug_mode"):
		print("Freeing ", get_node("Actors").get_child_count())
	for a in get_node("Actors").get_children():
		a.free()
	if Globals.get("debug_mode"):
		print("Freeing ", get_node("Effects").get_child_count())
	for e in get_node("Effects").get_children():
		e.free()

func _process(dt):
	var friendlies = get_tree().get_nodes_in_group("friendly")
	if not friendlies.size():
		print("ALL DED")
		newgame()

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


func spawn_actor(actor_type):
	var actor = null
	var p = Vector2(0, 0)
	if actor_type == "tank":
		p = get_node("Map/FriendlySpawn").get_pos()
		actor = tank_actor.instance()
	elif actor_type == "enemy":
		p = get_node("Map/EnemySpawn").get_pos()
		actor = enemy_actor.instance()
	elif actor_type == "archer":
		p = get_node("Map/FriendlySpawn").get_pos()
		actor = archer_actor.instance()

	p += Vector2(0, rand_range(-200, 200))

	if actor:
		if Globals.get("debug_mode"):
			print("Spawning actor: ", actor_type)
		actor.set_pos(p)
		actor.get_node("ActorBase").connect("death", self, "on_actor_death")
		get_node("Actors").add_child(actor)
	else:
		print("No actor by that identifier found: ", actor_type)

func on_actor_death(p):
	print("DIED?!")
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
	spawn_actor("enemy")
	spawn_actor("enemy")
	spawn_actor("enemy")
#	var friendlies = get_tree().get_nodes_in_group("friendly")
#	for f in friendlies:
#		if f.get_node("StatsModule"):
#			f.get_node("StatsModule").apply_effect(get_node("EffectModule"), null)
#	var enemies = get_tree().get_nodes_in_group("enemy")
#	for e in enemies:
#		if e.get_node("StatsModule"):
#			e.get_node("StatsModule").apply_effect(get_node("EffectModule"), null)
