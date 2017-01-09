tool
extends KinematicBody2D
var alliances = ["friendly", "enemy"]
export(String, "friendly", "enemy") var alliance = "friendly" setget change_allegiance, get_allegiance
export(String, FILE, "*.tscn") var projectile = null setget set_projectile, get_projectile
var projectile_scene = null

func change_allegiance(a):
	if Globals.get("debug_mode"):
		print("Setting alliance to ", a)
	alliance = a
	add_to_group(alliance, true)
	for a in alliances:
		if not a == alliance:
			if is_in_group(a):
				remove_from_group(a, true)

func get_allegiance():
	return alliance

func set_projectile(p):
	projectile = p
	if p:
		projectile_scene = load(p)

func get_projectile():
	return projectile

func _on_ActorBase_attack(target):
	print("No attack method defined for ", self)

func fire_projectile(target):
	if projectile and has_node("Attack") and target.has_node("StatsModule"):
		var a = projectile_scene.instance()
		var dist_scale = get_pos().distance_to(target.get_pos()) / get_node("StatsModule").get("base_attack_range")
		a.set_pos(get_pos())
		a.init(target, get_node("Attack"))
		a.flytime = a.flytime * dist_scale
		a.y_offset = a.y_offset * dist_scale
		get_tree().get_root().get_node("Game/Objects").add_child(a)
	else:
		print("Actor tried to shoot a projectile, but none has been configured.")

func _ready():
	pass
