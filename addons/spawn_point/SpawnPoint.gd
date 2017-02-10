tool
extends Position2D

export(String, FILE, "*.tscn") var actor_scene setget set_actor_scene, get_actor_scene
export(float, 0, 300, 0.1) var spawn_delay = 0 setget set_spawn_delay, get_spawn_delay
var loaded_scene = null
var display_scene = null

func set_actor_scene(as):
	actor_scene = as
	if as:
		loaded_scene = load(as)
		update_display()

func get_actor_scene():
	return actor_scene

func set_spawn_delay(t):
	spawn_delay = t

func get_spawn_delay():
	return spawn_delay

func _enter_tree():
	var s = Sprite.new()
	s.set_name("Sprite")
	add_child(s)
	var l = Label.new()
	l.set_name("Label")
	add_child(l)
	l.set_align(HALIGN_CENTER)
	l.set_autowrap(true)
	l.set_clip_text(true)
	l.set_size(Vector2(70, 16))
	l.set_pos(Vector2(-35, -24))
	update_display()

func _ready():
	set_process(true)
	if not get_tree().is_editor_hint():
		hide()
#	else:
#		if loaded_scene:
#			update_display()

func update_display():
	if not loaded_scene:
		return
	display_scene = loaded_scene.instance()
	if display_scene.has_node("ActorBase/Sprite"):
		var s = display_scene.get_node("ActorBase/Sprite")
		var tex = s.get_texture()
		var vf = s.get_vframes()
		var hf = s.get_hframes()
		get_node("Sprite").set_texture(tex)
		get_node("Sprite").set_vframes(vf)
		get_node("Sprite").set_hframes(hf)
		get_node("Sprite").set_frame(0)
		get_node("Label").set_text(display_scene.get_name())

func place(p):
	pass

func _process(dt):
	pass
#	update_display()
#	update()

func _draw():
	pass
#	draw_circle(Vector2(), 30, Color(1, 0, 0, 1))
