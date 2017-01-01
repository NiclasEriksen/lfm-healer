extends RigidBody2D

onready var root = get_tree().get_root().get_node("Game")
var stats = null

func _ready():
	if get_node("StatsModule"):
		stats = get_node("StatsModule")
		root.get_node("HUD").add_hpbar(self)

func on_heal():
	get_node("AnimationPlayer").play("Heal")

func testmove(dir):
	if dir.x > 0:
		get_node("Sprite").set_flip_h(false)
	elif dir.x < 0:
		get_node("Sprite").set_flip_h(true)
	if dir.x or dir.y:
		if not get_node("AnimationPlayer").get_current_animation() == "walk":
			get_node("AnimationPlayer").play("walk")
		set_pos(get_pos() + dir)
	else:
		if not get_node("AnimationPlayer").get_current_animation() == "idle":
			get_node("AnimationPlayer").play("idle")
