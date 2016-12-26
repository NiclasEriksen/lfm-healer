extends CanvasLayer

var hp_bar_scn = preload("res://Scenes/UI/HPBar.tscn")

func _ready():
	pass

func add_hpbar(owner):
	var hpb = hp_bar_scn.instance()
	hpb.register(owner)
	get_node("HPBars").add_child(hpb)

