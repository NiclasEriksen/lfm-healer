extends CanvasLayer

var hp_bar_scn = preload("res://Scenes/UI/HPBar.tscn")
var titleflash = preload("res://Scenes/UI/TitleFlash.tscn")
var currently_flashing = null

func _ready():
	pass

func clear():
	for hpb in get_node("HPBars").get_children():
		hpb.free()

func draw_lines(points, col):
	var adj_p = []
	for p in points:
		adj_p.append(
			p / get_tree().get_root().get_node("Game/Camera2D").get_zoom()
		)
	get_node("LineDisplay").points = adj_p
	get_node("LineDisplay").line_color = col
	get_node("LineDisplay").update()

func clear_lines():
	get_node("LineDisplay").points = []
	get_node("LineDisplay").update()

func add_hpbar(owner):
	var hpb = hp_bar_scn.instance()
	hpb.register(owner)
	get_node("HPBars").add_child(hpb)

func _on_Button2_pressed():
	get_tree().set_pause(
		not get_tree().is_paused()
	)

func flash_message(title, sub, duration):
	if not duration:
		duration = 5
	if currently_flashing:
		if currently_flashing.get_ref():
			currently_flashing.get_ref().queue_free()
	var tf = titleflash.instance()
	tf.set_duration(duration)
	var rw = Globals.get("display/width")
	var rh = Globals.get("display/height")
	tf.set_pos(Vector2(rw / 2, rh / 6))
	tf.set_main_text(title)
	tf.set_sub_text(sub)
	currently_flashing = weakref(tf)
	tf.connect("done_flashed", self, "flash_ended")
	add_child(tf)

func flash_ended():
	if currently_flashing:
		if currently_flashing.get_ref():
			currently_flashing.get_ref().queue_free()

func _on_RestartButton_pressed():
	get_tree().get_root().get_node("Game").newgame()

func _on_Game_spell_cd_changed( spell_id, pts ):
	if has_node("AbilityBar"):
		get_node("AbilityBar").update_spell_cd(spell_id, pts)


func _on_ChillMode_toggled( pressed ):
	Globals.set("chill_mode", pressed)


func _on_Button_toggled( pressed ):
	Globals.set("debug_mode", pressed)
