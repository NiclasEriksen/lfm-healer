extends CanvasLayer

var hp_bar_scn = preload("res://Scenes/UI/HPBar.tscn")
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func add_hpbar(owner):
	var hpb = hp_bar_scn.instance()
	hpb.register(owner)
	get_node("HPBars").add_child(hpb)

