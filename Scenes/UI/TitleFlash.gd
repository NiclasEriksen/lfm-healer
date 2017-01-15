extends Container

signal done_flashed

func set_main_text(msg):
	get_node("MainLabel").set_text(msg)

func set_sub_text(msg):
	get_node("SubLabel").set_text(msg)

func _ready():
	get_node("AnimationPlayer").play("flash")

func set_duration(val):
	get_node("AnimationPlayer").set_speed(get_node("AnimationPlayer").get_speed() / val)

func _on_AnimationPlayer_finished():
	emit_signal("done_flashed")
