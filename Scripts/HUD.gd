extends CanvasLayer

var hp_bar_scn = preload("res://Scenes/UI/HPBar.tscn")
var titleflash = preload("res://Scenes/UI/TitleFlash.tscn")
onready var fps = get_node("FPS")
var currently_flashing = null
onready var ability_bar = get_node("AbilityBar")
export(int) var fps_refresh_delay = 0.5
var fps_delay = 0.0
signal kill_pressed

func _ready():
	var actor_options = get_parent().get_actor_types()
	set_process(true)
	for t in actor_options:
		get_node("Actortype").add_item(t)
	get_node("Allegiance").add_item("friendly")
	get_node("Allegiance").add_item("enemy")

func _process(delta):
	if Globals.get("show_fps"):
		fps.show()
		if fps_delay <= 0:
			fps.set_text(str(int(1.0 / delta)))
			fps_delay = fps_refresh_delay
		else:
			fps_delay -= delta
	else:
		fps.hide()
		fps_delay = 0


func clear():
	for hpb in get_node("HPBars").get_children():
		hpb.free()

func set_button_ability(btn, tex):
	var ab = get_node("AbilityBar")
	var b_node_name = "VBoxContainer/HBoxContainer/Ability" + str(btn)
	if ab.has_node(b_node_name):
		var b_node = ab.get_node(b_node_name)
		b_node.get_node("Sprite").set_scale(b_node.get_size() / tex.get_size() * 0.8)
		b_node.get_node("Sprite").set_texture(tex)
	else:
		print("no... ", b_node_name)
#	if not typeof(btn) == int:
#		print("btn has to be an integer, not adding ability.")
	

func draw_lines(points, col):
	get_node("LineDisplay").points = points
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
	get_tree().get_root().get_node("Game").newgame(true)

func _on_Game_spell_cd_changed( spell_id, pts ):
	if has_node("AbilityBar"):
		get_node("AbilityBar").update_spell_cd(spell_id, pts)

func _on_ChillMode_toggled( pressed ):
	Globals.set("chill_mode", pressed)


func _on_Button_pressed():
#	Globals.set("debug_mode", pressed)
	get_node("SettingsLayer/Settings").popup_centered()


func _on_Kill_pressed():
	emit_signal("kill_pressed")


func _on_Spawn_pressed():
	var t = get_node("Actortype").get_text()
	var a = get_node("Allegiance").get_text()
	get_parent().spawn_actor(t, a)


func _on_Settings_load_map(m):
	get_parent().load_map(m)


func _on_Healer_spell_cd_changed( spell_id, pts ):
	if ability_bar:
		ability_bar.update_spell_cd(spell_id, pts)

func _on_Healer_mp_changed(val):
	get_node("ManaBar").set_value(val)
