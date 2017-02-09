extends Camera2D
export var scroll_spd = 100

func _ready():
	reset_zoom()
	set_process_input(true)
	set_process(true)

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				zoom_in()
			elif event.button_index == BUTTON_WHEEL_DOWN:
				zoom_out()

func _process(dt):
	var vel = Vector2()
	if Input.is_action_pressed("camera_left"):
		vel -= Vector2(scroll_spd, 0)
	if Input.is_action_pressed("camera_right"):
		vel += Vector2(scroll_spd, 0)
	if Input.is_action_pressed("camera_up"):
		vel -= Vector2(0, scroll_spd)
	if Input.is_action_pressed("camera_down"):
		vel += Vector2(0, scroll_spd)
	pan(vel.clamped(scroll_spd) * dt)

func pan(vel):
	set_offset(get_offset() + vel)

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
