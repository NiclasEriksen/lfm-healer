extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_ActorBase_attack(target):
	if target.has_node("StatsModule") and has_node("Attack"):
		if Globals.get("debug_mode"):
			print(self, " attacking ", target)
		target.get_node("StatsModule").apply_effect(get_node("Attack"), null)
