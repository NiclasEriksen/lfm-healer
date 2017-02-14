extends Node

export(float, 0, 5, 0.1) var dmg_scale = 1
export(float, 0, 5, 0.1) var heal_scale = 0.5
export(int, 0, 100, 1) var aggro_treshold = 10
export(float, 0.1, 5, 0.1) var refresh_timeout = 0.5
var current_top = null
var registry = {}
var ref_registry = {}
signal aggro(target)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	if not "enemy" in get_parent().get_groups():
		queue_free()
		return
	if get_parent().has_node("StatsModule"):
		var sm = get_parent().get_node("StatsModule")
		sm.connect("dmg_taken", self, "add_dmg_threat")
	connect("aggro", get_parent(), "on_ThreatTable_aggro")
	get_node("Refresh").set_wait_time(refresh_timeout)
	set_process(true)

func add_threat(origin, amount):
	var ur = origin.get_instance_ID()
	if registry.has(ur):
		registry[ur] += amount
	else:
		registry[ur] = amount
	if not ref_registry.has(ur):
		ref_registry[ur] = weakref(origin)

func add_dmg_threat(origin, amount):
	add_threat(origin, amount * dmg_scale)

func add_heal_threat(origin, amount):
	add_threat(origin, amount * heal_scale)

func clear_threat(origin):
	var ur = origin.get_instance_ID()
	if registry.has(ur):
		registry[ur] = 0

func get_top():
	var highest = 0
	var candidate = null
	for t in registry:
		if registry[t] > highest:
			if get_actor(t):
				highest = registry[t]
				candidate = t
			else:
				ref_registry.erase(t)
				registry.erase(t)
	return candidate

func get_actor(ur):
	var a = null
	if ref_registry.has(ur):
		a = ref_registry[ur].get_ref()
	return a

func _process(dt):
	pass
#	add_dmg_threat(self, 10 * dt)

func _on_Refresh_timeout():
	var top = get_top()
	if not top:
		return
	
	if top == current_top:
		return
	if current_top and registry.has(current_top):
		var ct_threat = registry[current_top]
		var t_threat = registry[top]
		if t_threat * (1.0 + aggro_treshold / 100.0) >= ct_threat:
			current_top = top
			emit_signal("aggro", get_actor(top))
			return
	current_top = top
	emit_signal("aggro", get_actor(top))


func _on_ThreatTable_aggro( target ):
	print("Aggroed ", target)
