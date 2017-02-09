extends Node2D
var owner = null
export(Vector2) var friendly_scale = Vector2(1, 1)
export(Vector2) var enemy_scale = Vector2(0.75, 0.75)
var current_scale = null
export(Texture) var healer_texture = null
export(Texture) var friendly_texture = null
export(Texture) var enemy_texture = null
var offset = Vector2(0, 0)
var old_val = null
var cam = null
onready var progress_bar = get_node("TextureProgress")
onready var panel = get_node("Panel")

func _ready():
	set_process(true)
	cam = get_tree().get_root().get_node("Game/Camera2D")

func register(owner):
	self.owner = weakref(owner)
	if "enemy" in owner.get_groups():
		if enemy_texture:
			get_node("TextureProgress").set_progress_texture(enemy_texture)
		current_scale = enemy_scale
		set_scale(current_scale)
	elif "friendly" in owner.get_groups():
		if healer_texture and owner.is_healer():
			get_node("TextureProgress").set_progress_texture(healer_texture)
			current_scale = friendly_scale * 1.2
			set_scale(current_scale)
		elif friendly_texture:
			get_node("TextureProgress").set_progress_texture(friendly_texture)
			current_scale = friendly_scale
			set_scale(current_scale)
	if owner.has_node("HPBarPos"):
		offset = owner.get_node("HPBarPos").get_pos()
	#print(self, owner, "HEEET")
	#set_value(owner.get("hp") / owner.get("max_hp") * 100.0)

func _process(delta):
	if owner.get_ref():
		var o = owner.get_ref()
		var stats = null
		if o.has_node("StatsModule"):
			stats = o.get_node("StatsModule")
		else:
			remove()
			return
		set_scale(current_scale)
		if "enemy" in o.get_groups():
			if stats.is_stealthed():
				hide()
			else:
				show()
		var pos = o.get_pos()
		var val = (stats.get("hp") / stats.get_actual("max_hp")) * 100.0
		pos = cam.get_viewport().get_canvas_transform().xform(pos)
		set_pos(pos + offset)
		set_z(pos.y)
		if not old_val == val:
			self.old_val = val
			progress_bar.set_value(val)
			get_node("AnimationPlayer").play("val_change")
		if Globals.get("debug_mode") and panel:
			show_panel(stats)
		elif o.is_selected() and panel:
			show_panel(stats)
		else:
			hide_panel()
	else:
		remove()

func show_panel(stats):
	panel.show()
	var o = owner.get_ref()
	var state = o.get_brain().get_current_state().name
	var lvl = stats.get_level()
	var hp = stats.get("hp")
	var maxhp = stats.get_actual("max_hp")
	var dmg = stats.get_actual("damage")
	panel.get_node("State/Value").set_text(str(state))
	panel.get_node("Level/Value").set_text(str(lvl))
	panel.get_node("HP/Value").set_text(str(int(hp)))
	panel.get_node("HPMAX/Value").set_text(str(int(maxhp)))
	panel.get_node("DMG/Value").set_text(str(int(dmg)))

func hide_panel():
	panel.hide()


func remove():
	if not get_node("AnimationPlayer").get_current_animation() == "remove":
		get_node("AnimationPlayer").play("remove")
