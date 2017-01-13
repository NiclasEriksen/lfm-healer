extends CanvasLayer

var hp_bar_scn = preload("res://Scenes/UI/HPBar.tscn")

func _ready():
	pass

func clear():
	for hpb in get_node("HPBars").get_children():
		hpb.free()

func draw_lines(p, col):
	get_node("LineDisplay").points = p
	get_node("LineDisplay").line_color = col
	get_node("LineDisplay").update()

func clear_lines():
	get_node("LineDisplay").points = []
	get_node("LineDisplay").update()

func add_hpbar(owner):
	var hpb = hp_bar_scn.instance()
	hpb.register(owner)
	get_node("HPBars").add_child(hpb)



func _on_Button_pressed():
	Globals.set("debug_mode", not Globals.get("debug_mode"))
