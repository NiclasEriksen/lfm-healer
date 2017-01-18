tool
extends KinematicBody2D
var alliances = ["friendly", "enemy"]
export(String, "friendly", "enemy") var alliance = "friendly" setget change_allegiance, get_allegiance
export(String, FILE, "*.tscn") var projectile = null setget set_projectile, get_projectile
export(String, FILE, "*.tscn") var hit_effect = null setget set_hit_effect, get_hit_effect
var hit_effect_scene = null
var projectile_scene = null


func change_allegiance(a):
	if Globals.get("debug_mode"):
		print("Setting alliance to ", a)
	alliance = a
	add_to_group(alliance, true)
	for a in alliances:
		if not a == alliance:
			if is_in_group(a):
				remove_from_group(a)

func get_allegiance():
	return alliance

func set_hit_effect(e):
	if e:
		hit_effect_scene = load(e)
	else:
		hit_effect_scene = load("res://Scenes/Effects/HitSplat.tscn")

func get_hit_effect(e):
	return hit_effect

func set_projectile(p):
	projectile = p
	if p:
		projectile_scene = load(p)

func get_projectile():
	return projectile

func _on_ActorBase_attack(target):
	if Globals.get("debug_mode"):
		print("No attack method defined for ", self, ", using default.")
	if target.has_node("StatsModule") and has_node("Attack"):
		if Globals.get("debug_mode"):
			print(self, " attacking ", target)
		var sm = null
		if has_node("StatsModule"):
			sm = get_node("StatsModule")
		target.get_node("StatsModule").apply_effect(get_node("Attack"), sm)

func _on_ActorBase_attack_effect(target):
	pass

func get_body_pos():
	if has_node("CollisionShape2D"):
		return get_pos() + get_node("CollisionShape2D").get_pos()
	return get_pos()

func fire_projectile(target):
	if projectile and has_node("Attack") and target.has_node("StatsModule"):
		var a = projectile_scene.instance()
		var dist_scale = get_body_pos().distance_to(target.get_body_pos()) / get_node("StatsModule").get_actual("attack_range")
		a.set_pos(get_body_pos())
		a.set_alliance(get_allegiance())
		if has_node("Debuff"):
			a.init(target, get_node("Attack"), get_node("Debuff"))
		elif has_node("StatusEffect"):
			a.init(target, get_node("Attack"), get_node("StatusEffect"))
		else:
			a.init(target, get_node("Attack"), null)
		a.set_owner(self)
		a.flytime = a.flytime * dist_scale
		a.y_offset = a.y_offset * dist_scale
		get_tree().get_root().get_node("Game/Objects").add_child(a)
	else:
		print("Actor tried to shoot a projectile, but none has been configured.")

func _ready():
	# Connect signals
	if has_node("ActorBase"):
		get_node("ActorBase").connect("attack", self, "_on_ActorBase_attack")
		get_node("ActorBase").connect("attack", self, "_on_ActorBase_attack_effect")
		if has_node("MoveModule"):
			get_node("MoveModule").connect("moved", get_node("ActorBase"), "_on_MoveModule_moved")
			get_node("MoveModule").connect("stalled", get_node("ActorBase"), "_on_MoveModule_stalled")
			get_node("ActorBase").connect("targeted_enemy", get_node("MoveModule"), "_on_ActorBase_targeted_enemy")
			get_node("ActorBase").connect("cleared_target", get_node("MoveModule"), "_on_ActorBase_cleared_target")
