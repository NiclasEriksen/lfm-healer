extends Camera2D

func _ready():
	reset_zoom()

func reset_zoom():
	set_center()
	set_zoom(get_full_zoom_level())

func set_center():
	var render_size = Vector2(Globals.get("render_width"), Globals.get("render_height"))
	set_pos(render_size / 2)

func zoom_in():
	set_zoom(get_zoom() * 0.9)

func zoom_out():
	set_zoom(get_zoom() * 1.1)

func get_full_zoom_level():
	var render_size = Vector2(Globals.get("render_width"), Globals.get("render_height"))
	var screen_size = Vector2(Globals.get("display/width"), Globals.get("display/height"))
#	return render_size / get_global_transform().xform(render_size)
	return render_size / screen_size
