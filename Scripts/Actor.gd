extends RigidBody2D

onready var root = get_tree().get_root().get_node("Game")
var stats = null

func _ready():
	if get_node("StatsModule"):
		stats = get_node("StatsModule")
		root.get_node("HUD").add_hpbar(self)
