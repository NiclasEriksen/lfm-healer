extends HBoxContainer
var line_id = 0
signal actor_chosen(id, name)

func set_id(i):
	line_id = i

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _on_OptionButton_item_selected(ID):
	emit_signal("actor_chosen", line_id, get_node("OptionButton").get_item_text(ID))
