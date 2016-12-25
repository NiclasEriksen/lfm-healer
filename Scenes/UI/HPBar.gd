extends Node2D
var owner = null
var old_val = null

func _ready():
	set_process(true)

func register(owner):
	self.owner = weakref(owner)
	#print(self, owner, "HEEET")
	#set_value(owner.get("hp") / owner.get("max_hp") * 100.0)

func _process(delta):
	if owner.get_ref():
		var o = owner.get_ref()
		var pos = o.get_pos()
		var val = (o.stats.get("hp") / o.stats.get("max_hp")) * 100.0
		if o.get_node("HPBarPos"):
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
