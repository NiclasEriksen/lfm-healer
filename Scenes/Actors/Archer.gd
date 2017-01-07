extends KinematicBody2D

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass



func _on_ActorBase_attack(target):
	if target.has_node("StatsModule") and has_node("Attack"):
		print("Attacking ", target)
		target.get_node("StatsModule").apply_effect(get_node("Attack"), null)
