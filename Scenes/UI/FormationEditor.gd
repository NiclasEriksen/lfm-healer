extends HBoxContainer

onready var selector = get_node("PickerContainer/PickerFrame")
onready var selector_size = selector.get_size()
var opt_line = preload("res://Scenes/UI/OptionLine.tscn")
var dragging = false
var drag_index = 0

var actor_slots = [null, null, null, null, null]

var formations = {
	1:[Vector2(0, 0)],
	2:[Vector2(-0.25, 0), Vector2(0.25, 0)],
	3:[Vector2(0, 0), Vector2(-0.35, -0.25), Vector2(0.35, -0.25)],
	4:[Vector2(0, 0), Vector2(-0.30, -0.25), Vector2(0.30, -0.25), Vector2(0, -0.50)],
	5:[Vector2(0, 0), Vector2(-0.40, -0.25), Vector2(0.40, -0.25), Vector2(0.20, -0.60), Vector2(-0.20, -0.60)]
}
var actors = {
	"tank": preload("res://Scenes/Actors/Tank.tscn"),
	"archer": preload("res://Scenes/Actors/Archer.tscn"),
	"rogue": preload("res://Scenes/Actors/Rogue.tscn"),
	"mage": preload("res://Scenes/Actors/Mage.tscn"),
	"testenemy": preload("res://Scenes/Actors/TestEnemy.tscn"),
	"member": preload("res://Scenes/Actors/Member.tscn"),
	"blub": preload("res://Scenes/Actors/Blub.tscn"),
	"healer": preload("res://Scenes/Actors/Healer.tscn"),
}
var selected_formation = 5


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	populate_formation_list()
	update_options()

func update_options():
	var cc = get_node("ChoiceContainer/Choices")
	for c in cc.get_children():
		c.queue_free()
	var positions = formations[selected_formation].size()
	for p in range(positions):
		var ol = opt_line.instance()
		ol.set_id(p)
		ol.get_node("Label").set_text("Pos. " + str(p + 1))
		ol.connect("actor_chosen", self, "on_actor_chosen")
		ol.get_node("OptionButton").add_item("none")
		var i = 1
		for o in actors:
			ol.get_node("OptionButton").add_item(o)
			if o == actor_slots[p]:
				ol.get_node("OptionButton").select(i)
			i += 1
		cc.add_child(ol)

func set_selected_formation(i):
	if formations.has(i):
		if not i == selected_formation:
			selected_formation = i
			populate_formation_list()
			update_options()
	else:
		print("No such formation: ", i)

func populate_formation_list():
	var cn = get_node("ChoiceContainer/Title/Formations")
	cn.clear()
	for f in formations:
		cn.add_item(str(f))
	cn.select(selected_formation - 1)

func _process(dt):
	update()
	var p = []
	for fp in formations[selected_formation]:
		p.append(fp * selector_size)
	selector.set_points(p)

func _on_PickerFrame_input_event(ev):
	var spos = ev.pos / selector_size
	var fpos = Vector2(-0.5 + spos.x, -1 + spos.y)
	if ev.type == InputEvent.MOUSE_BUTTON:
		if ev.pressed:
#			print("x: ", spos.x, "  y: ", spos.y)
			var i = 0
			for fp in formations[selected_formation]:
				if fp.distance_to(fpos) < 0.1:
					drag_index = i
					selector.selected_point = i
					dragging = true
				i += 1
		else:
			dragging = false
	if ev.type == InputEvent.MOUSE_MOTION and dragging:
		if spos.x < 0:
			fpos.x = -0.5
		if spos.x > 1:
			fpos.x = 0.5
		if spos.y < 0:
			fpos.y = -1
		if spos.y > 1:
			fpos.y = 0
		formations[selected_formation][drag_index] = fpos

func _draw():
	pass
#	draw_set_transform_matrix(selector.get_transform())
#	var o = Vector2(selector_size.x / 2, selector_size.y)
#	var c = Color(1, 0.3, 0.3)
#	for p in formations[5]:
#		draw_circle(o + p * selector_size, 8, c)
#		c = Color(1, 0, 0)

func on_actor_chosen(id, name):
	if name == "none":
		actor_slots[id] = null
		selector.clear_sprite(id + 1)
		return
	actor_slots[id] = name
	var a = actors[name].instance()
	var tex = a.get_node("ActorBase").get_sprite_texture()
	var td = a.get_node("ActorBase").get_tile_dimensions()
	if not tex:
		return
	var s = selector.get_sprite(id + 1)
	s.set_texture(tex)
	s.set_hframes(td.x)
	s.set_vframes(td.y)
	s.set_frame(0)
	s.set_scale(Vector2(3, 3))

#	print("Chose ", id, " with name ", name)

func _on_Formations_item_selected( ID ):
	set_selected_formation(ID + 1)
