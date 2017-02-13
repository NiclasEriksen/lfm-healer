tool
extends KinematicBody2D
var alliances = ["friendly", "enemy"]
export(String, "friendly", "enemy") var alliance = "friendly" setget change_allegiance, get_allegiance
export(String, FILE, "*.tscn") var projectile = null setget set_projectile, get_projectile
export(String, FILE, "*.tscn") var hit_effect = null setget set_hit_effect, get_hit_effect
var hit_effect_scene = null
var projectile_scene = null
var target = null setget set_target, get_target
var selected = false setget set_selected, is_selected
var highlighted = false setget set_highlighted, is_highlighted
var stats_node = null
var move_node = null
var attack_node = null
var actorbase_node = null
var brain_node = null
var statuseffect_node = null
var debuff_node = null
export(NodePath) var party = null setget set_party, get_party
export(int) var party_index = -1 setget set_party_index, get_party_index
var party_leader = false setget set_leader, is_leader
var healer = false

func get_brain():
	return brain_node

func set_target(t):
	if t:
		target = weakref(t)
		actorbase_node.emit_signal("targeted_enemy", t)
	else:
		actorbase_node.emit_signal("cleared_target")
		target = null

func get_target():
	if target:
		if target.get_ref():
			return target.get_ref()
		target = null
	return null

func set_healer(v):
	healer = v

func is_healer():
	return healer

func set_leader(v):
	party_leader = v

func is_leader():
	return party_leader

func set_party(p):
	if p:
		party = p
		set_party_index(p.register_unit())

func get_party():
	return party

func is_in_party():
	return party != null

func set_party_index(i):
	party_index = i

func get_party_index():
	return party_index

func set_selected(v):
	selected = v

func is_selected():
	return selected

func set_highlighted(v):
	highlighted = v

func is_highlighted():
	return highlighted

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


func attack(target):
	if Globals.get("debug_mode"):
		print("No attack method defined for ", self, ", using default.")
	if target.stats_node and attack_node:
		if Globals.get("debug_mode"):
			print(self, " attacking ", target)
		target.stats_node.apply_effect(attack_node, stats_node)

func _on_ActorBase_attack_effect(target):
	pass

func get_body_pos():
	if move_node:
		return get_pos() + move_node.get_pos()
	elif has_node("CollisionShape2D"):
		return get_pos() + get_node("CollisionShape2D").get_pos()
	return get_pos()

func fire_projectile(target):
	if projectile and attack_node and target.stats_node:
		var a = projectile_scene.instance()
		var dist_scale = get_body_pos().distance_to(target.get_body_pos()) / stats_node.get_actual("attack_range")
		a.set_pos(get_body_pos())
		a.set_alliance(get_allegiance())
		if debuff_node:
			a.init(target, attack_node, debuff_node)
		elif statuseffect_node:
			a.init(target, attack_node, statuseffect_node)
		else:
			a.init(target, attack_node, null)
		a.set_owner(self)
		a.flytime = a.flytime * dist_scale
		a.y_offset = a.y_offset * dist_scale
		get_tree().get_root().get_node("Game/Objects").add_child(a)
	else:
		print("Actor tried to shoot a projectile, but none has been configured.")

func _ready():
	# Connect signals
	if has_node("ActorBase"):
		actorbase_node = get_node("ActorBase")
		get_node("ActorBase").connect("attack", self, "_on_ActorBase_attack_effect")
		if has_node("MoveModule"):
			move_node = get_node("MoveModule")
			move_node.connect("moved", get_node("ActorBase"), "_on_MoveModule_moved")
			move_node.connect("stalled", get_node("ActorBase"), "_on_MoveModule_stalled")
			get_node("ActorBase").connect("targeted_enemy", move_node, "_on_ActorBase_targeted_enemy")
			get_node("ActorBase").connect("cleared_target", move_node, "_on_ActorBase_cleared_target")
		if has_node("StatsModule"):
			stats_node = get_node("StatsModule")
		if has_node("Attack"):
			attack_node = get_node("Attack")
		if has_node("StatusEffect"):
			statuseffect_node = get_node("StatusEffect")
		if has_node("Debuff"):
			debuff_node = get_node("Debuff")
		if has_node("Brain"):
			brain_node = get_node("Brain")

func _on_ThreatTable_aggro( target ):
	if has_method("set_target"):
		set_target(target)
		return
	print("No method set_target")
