extends Node2D
var owner = null
export(Vector2) var friendly_scale = Vector2(1.5, 1.5)
export(Vector2) var enemy_scale = Vector2(0.75, 0.75)
export(Texture) var friendly_texture = null
export(Texture) var enemy_texture = null
var old_val = null
var cam = null

func _ready():
	set_process(true)
	cam = get_tree().get_root().get_node("Game/Camera2D")

func register(owner):
	self.owner = weakref(owner)
	if "enemy" in owner.get_groups():
		if enemy_texture:
			get_node("TextureProgress").set_progress_texture(enemy_texture)
		set_scale(enemy_scale)
	elif "friendly" in owner.get_groups():
		if friendly_texture:
			get_node("TextureProgress").set_progress_texture(friendly_texture)
		set_scale(friendly_scale)
	#print(self, owner, "HEEET")
	#set_value(owner.get("hp") / owner.get("max_hp") * 100.0)

func _process(delta):
	if owner.get_ref():
		var o = owner.get_ref()
		if not o.has_node("StatsModule"):
			queue_free()
			return
		if "enemy" in o.get_groups():
			set_scale(enemy_scale)
		elif "friendly" in o.get_groups():
			set_scale(friendly_scale)
		var pos = o.get_pos()
		var val = (o.get_node("StatsModule").get("hp") / o.get_node("StatsModule").get_actual("max_hp")) * 100.0
		if o.get_node("HPBarPos"):
			pos = cam.get_viewport().get_canvas_transform().xform(pos + o.get_node("HPBarPos").get_pos())
			set_pos(pos + o.get_node("HPBarPos").get_pos())
			#print(pos, o.get_node("HPBarPos").get_pos())
		else:
			set_pos(pos)
		if not old_val == val:
			self.old_val = val
			get_node("TextureProgress").set_value(val)
			get_node("AnimationPlayer").play("val_change")
	else:
		queue_free()
