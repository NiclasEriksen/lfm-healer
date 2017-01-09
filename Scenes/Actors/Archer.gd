extends "res://Scripts/Actor.gd"
var arrow = preload("res://Scenes/Objects/Arrow.tscn")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass



func _on_ActorBase_attack(target):
	fire_projectile(target)
