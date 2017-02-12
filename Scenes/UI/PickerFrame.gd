extends Container

var points = []
var selected_point = 0
onready var origin = Vector2(get_size().x / 2, get_size().y)
var leader_texture = load("res://Assets/UI/hp_mid_blue.png")
var pos_texture = load("res://Assets/UI/hp_mid.png")

func set_points(l):
	points = l

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)

func _process(delta):
	update_sprite_pos()
	for c in get_children():
		c.hide()
	for i in range(points.size()):
		get_sprite(i + 1).show()
		get_node("Label" + str(i + 1)).show()
	update()

func get_sprite(i):
	return get_node("Sprite" + str(i))

func update_sprite_pos():
	var i = 1
	for p in points:
		get_sprite(i).set_pos(origin + p)
		get_node("Label" + str(i)).set_pos(origin + p - Vector2(32, 64))
		i += 1

func update_sprite_texture(id, tex):
	get_sprite(id).set_texture(tex)

func clear_sprite(id):
	var tex = pos_texture
	if id == 1:
		tex = leader_texture
	var s = get_sprite(id)
	s.set_scale(Vector2(1, 1))
	s.set_texture(tex)
	s.set_vframes(1)
	s.set_hframes(1)

func _draw():
	pass
#	var oc = Color(1, 0.3, 0.3)
#	var dc = Color(0.3, 1, 0.3)
#	var i = 0
#	var c = oc
#	for p in points:
#		c = oc
#		if i == selected_point:
#			c = dc
#		elif i == 0:
#			c = Color(1, 0, 0)
#		draw_circle(origin + p, 24, c)
#		i += 1
#		c = Color(1, 0, 0)
