extends "res://Scripts/Actor.gd"


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func attack(target):
	fire_projectile(target)
