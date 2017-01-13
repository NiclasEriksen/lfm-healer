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


func _on_Button2_pressed():
	get_tree().set_pause(
		not get_tree().is_paused()
	)


func _on_RestartButton_pressed():
	get_tree().get_root().get_node("Game").newgame()


func _on_Game_spell_cd_changed( spell_id, pts ):
	if has_node("AbilityBar"):
		get_node("AbilityBar").update_spell_cd(spell_id, pts)
