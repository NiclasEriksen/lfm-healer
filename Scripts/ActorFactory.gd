extends Node

var actors = {
	"tank": preload("res://Scenes/Actors/Tank.tscn"),
	"archer": preload("res://Scenes/Actors/Archer.tscn"),
	"rogue": preload("res://Scenes/Actors/Rogue.tscn"),
	"mage": preload("res://Scenes/Actors/Mage.tscn"),
	"healer": preload("res://Scenes/Actors/Healer.tscn"),
	"testenemy": preload("res://Scenes/Actors/TestEnemy.tscn"),
	"member": preload("res://Scenes/Actors/Member.tscn"),
	"blub": preload("res://Scenes/Actors/Blub.tscn"),
}
var game = get_parent()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func spawn_actor(actor_type, alliance):
	if not actors.has(actor_type):
		print("No such actor: ", actor_type)
		return
	var actor = actors[actor_type].instance()
	var p = Vector2(0, 0)
	var p_to = Vector2(0, 0)

	if alliance == "friendly":
		if Globals.get("chill_mode") and actor:
			# Triple level
			actor.get_node("StatsModule").set_level(10)
		p = game.map.get_spawn_pos(alliance)
		p_to= game.map.get_spawn_pos("enemy")
	elif alliance == "enemy":
		p = game.map.get_spawn_pos(alliance)
		p_to = game.map.get_spawn_pos("friendly")
		var scr_h = Globals.get("render_height")
		p += Vector2(0, rand_range(-(scr_h / 10), scr_h / 10))

	if actor:
		if Globals.get("debug_mode"):
			print("Spawning actor: ", actor_type)
		actor.change_allegiance(alliance)
		actor.set_pos(p)
		actor.set_z(p.y)
		var body_p = actor.get_body_pos()
		if actor.has_node("MoveModule"):
			var path = game.map.get_simple_path(body_p, p_to)
			actor.get_node("MoveModule").set_walk_path(path)
#		actor.get_node("ActorBase").connect("death", actor, "on_actor_death")
		game.get_node("Actors").add_child(actor)
	else:
		print("No actor by that identifier found: ", actor_type)
