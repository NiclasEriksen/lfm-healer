extends HBoxContainer

var actor_instance = null
signal selected(a)

func _ready():
	select(false)

func init(a):
	actor_instance = a.instance()
	var stex = actor_instance.get_node("ActorBase/Sprite").get_texture()
	var vf = actor_instance.get_node("ActorBase/Sprite").get_vframes()
	var hf = actor_instance.get_node("ActorBase/Sprite").get_hframes()
	var s = get_node("Button/Sprite")
	s.set_texture(stex)
	s.set_vframes(vf)
	s.set_hframes(hf)
	s.set_frame(0)
	refresh()

func refresh():
	var name = actor_instance.actor_name
	get_node("Details/Name").set_text(name)
	var lvl = actor_instance.get_node("StatsModule").get_level()
	var ap = actor_instance.get_node("StatsModule").attribute_points
	get_node("Details/HBoxContainer/lvl").set_text("Level " + str(lvl))
	if ap > 0:
		get_node("Details/HBoxContainer/ap").show()
		get_node("Details/HBoxContainer/ap").set_text("(" + str(ap) + ")")
	else:
		get_node("Details/HBoxContainer/ap").hide()

func select(val):
	if val:
		get_node("SelectContainer").show()
	else:
		get_node("SelectContainer").hide()

func _on_Button_pressed():
	emit_signal("selected", actor_instance)
	select(true)
