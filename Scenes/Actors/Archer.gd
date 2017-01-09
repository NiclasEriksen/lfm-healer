extends KinematicBody2D
var arrow = preload("res://Scenes/Objects/Arrow.tscn")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass



func _on_ActorBase_attack(target):
	if target.has_node("StatsModule") and has_node("Attack"):
		# print("Attacking ", target)
		var a = arrow.instance()
		var dist_scale = get_pos().distance_to(target.get_pos()) / get_node("StatsModule").get("base_attack_range")
		a.set_pos(get_pos())
		a.init(target, get_node("Attack"))
		a.flytime = a.flytime * dist_scale
		a.y_offset = a.y_offset * dist_scale
		get_tree().get_root().get_node("Game/Objects").add_child(a)
		# target.get_node("StatsModule").apply_effect(get_node("Attack"), null)
