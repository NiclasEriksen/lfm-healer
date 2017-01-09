extends Sprite

# class member variables go here, for example:
export(float) var linger_time = 30.0
var lingered = 0.0
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	var anim_length = get_node("AnimationPlayer").get_animation("Splat").get_length()
	get_node("AnimationPlayer").set_speed(anim_length / linger_time)
	get_node("AnimationPlayer").play("Splat")
	if randf() > 0.5:
		set_flip_h(true)
	if randf() > 0.5:
		set_flip_v(true)
	if randf() > 0.66:
		set_frame(2)
	elif randf() > 0.33:
		set_frame(1)

func _fixed_process(dt):
	if lingered >= linger_time:
		queue_free()
	else:
#		set_opacity(1 - lingered / linger_time)
		lingered += dt
