extends HBoxContainer

var stat = null
var owner = null
var value = null
var min_value = 0
onready var minus_node = get_node("HBoxContainer/Minus")
onready var plus_node = get_node("HBoxContainer/Plus")
signal value_changed(origin)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func init(o, s, val):
	owner = o
	stat = s
	value = val
	min_value = value
	get_node("HBoxContainer/Minus").set_disabled(true)
	get_node("HBoxContainer/Minus").set_opacity(0.5)
	var txt = stat
	if txt.begins_with("base_"):
		txt.erase(0, 5)
	get_node("Stat").set_text(str(txt))
	update_value()

func update_value():
	get_node("HBoxContainer/Amount").set_text(str(value))
	if not minus_node:
		return
	if value <= min_value:
		minus_node.set_disabled(true)
		minus_node.set_opacity(0.5)
	else:
		minus_node.set_disabled(false)
		minus_node.set_opacity(1)

	if owner.points > 0:
		plus_node.set_disabled(false)
		plus_node.set_opacity(1)
	else:
		plus_node.set_disabled(true)
		plus_node.set_opacity(0.5)

func _on_Minus_button_down():
	if value <= min_value:
		return
	get_node("AnimationPlayer").play("decrease")
	value -= 1
	owner.points += 1
	emit_signal("value_changed", self)

func _on_Plus_button_down():
	if owner.points > 0:
		get_node("AnimationPlayer").play("increase")
		value += 1
		owner.points -= 1
	emit_signal("value_changed", self)
